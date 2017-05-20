unit Utils_Shl;

interface

{$DEBUGINFO OFF}

uses
	Winapi.Windows, System.Classes, Winapi.ShlObj, Winapi.ShellAPI, Winapi.ActiveX,
	System.Win.ComObj;

resourcestring
   rsVerbDefault     = 'default';
   rsVerbOpen        = 'open';
   rsVerbRename      = 'rename';
   rsVerbCopy        = 'copy';
   rsVerbCut         = 'cut';
   rsVerbPaste       = 'paste';
   rsVerbDelete      = 'delete';
   rsVerbProperties  = 'properties';
   
const
	E_DRIVENOTREADY	= HRESULT($800704C7);
	E_ACCESSDENIED		= E_DRIVENOTREADY;

   IID_IPersistFile: TGUID = (
      D1:$0000010B;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
   IID_IDataObject: TGUID = (
      D1:$0000010E;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
   IID_IDropTarget: TGUID = (
      D1:$00000122;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));

function 	GetDisplayName(ShellFolder: IShellFolder; RelativeID: PItemIDList; Flags: DWORD): String;
function 	GetSHIconIndex(AbsoluteID: PItemIDList; Open: Boolean = False): Integer;
function 	GetShellIconIndex(ShellFolder: IShellFolder; RelativeID: PItemIDList;
	Open: Boolean = False; Async: Boolean = False): Integer;

function 	GetShellFileSize(ShellFolder: IShellFolder; RelativeID: PItemIDList): Int64;

function 	Shl_IsAttributes(ShellFolder: IShellFolder; RelativeID: PItemIDList;
				Attributes: UINT): Boolean;
function 	AttrFolder(ShellFolder: IShellFolder; RelativeID: PItemIDList): Boolean;
function 	AttrGhosted(ShellFolder: IShellFolder; RelativeID: PItemIDList): Boolean;
function 	AttrLink(ShellFolder: IShellFolder; RelativeID: PItemIDList): Boolean;
function 	AttrShare(ShellFolder: IShellFolder; RelativeID: PItemIDList): Boolean;
function 	AttrHidden(ShellFolder: IShellFolder; RelativeID: PItemIDList): Boolean;
function 	AttrFileSystem(ShellFolder: IShellFolder; RelativeID: PItemIDList): Boolean;

function 	FileNameToID(ShellFolder: IShellFolder; AOwner: HWND;
									FileName: String; out NewID: PItemIDList): HResult;
function 	IDToFileName(ID: PItemIDList): String;

procedure	DisposePIDL(var ID: PItemIDList);
function 	CopyITEMID(Malloc: IMalloc; ID: PItemIDList): PItemIDList;
function 	NextPIDL(IDList: PItemIDList): PItemIDList;
function 	GetPIDLSize(IDList: PItemIDList): Integer;
procedure 	StripLastID(IDList: PItemIDList);
function 	AbsoluteIDToRelative(IDList: PItemIDList): PItemIDList;
function 	CreatePIDL(Size: Integer): PItemIDList;
function 	CopyPIDL(IDList: PItemIDList): PItemIDList;
function 	ConcatPIDLs(IDList1, IDList2: PItemIDList): PItemIDList;
function  	GetPIDLLevel(IDList: PItemIdList): Integer;
function    ComparePIDLs(DesktopFolder: IShellFolder; IDList1, IDList2: PItemIDList): Boolean;

function    GetFileNamesFromHandle(h: HGLOBAL): TStrings;
function    GetFileNamesFromDataObject(lpdobj: IDataObject): TStrings;

implementation

uses Utils_Misc;

function GetDisplayName(ShellFolder: IShellFolder; RelativeID: PItemIDList; Flags: DWORD): String;
var
   P: PChar;
   StrRet: TStrRet;
begin
	Result:='';
	ShellFolder.GetDisplayNameOf(RelativeID, Flags, StrRet);
   Case StrRet.uType of
   STRRET_CSTR:
//   	SetString(Result, StrRet.cStr, lStrLen(StrRet.cStr)); 2013.12.11 XE3
   	SetString(Result, StrRet.cStr, SizeOf(StrRet.cStr));
   STRRET_OFFSET:
   	begin
      	P:=@RelativeID.mkid.abID[StrRet.uOffset - SizeOf(RelativeID.mkid.cb)];
         SetString(Result, P, RelativeID.mkid.cb - StrRet.uOffset);
      end;
   STRRET_WSTR:
   	Result:=StrRet.pOleStr;
  	end;
{   If IsValueInWord(Flags, SHGDN_FORPARSING) and (Pos('::{', Result) = 1) then
      Result:=GetDisplayName(ShellFolder, RelativeID, SHGDN_NORMAL);}
end;

function GetSHIconIndex(AbsoluteID: PItemIDList; Open: Boolean = False): Integer;
var
  	FileInfo: TSHFileInfo;
   Flags: Integer;
begin
	FillChar(FileInfo, SizeOf(FileInfo), #0);
   Flags:=SHGFI_PIDL or SHGFI_SYSICONINDEX or SHGFI_ICON;
   If Open then Flags:=Flags or SHGFI_OPENICON;
   SHGetFileInfo(PChar(AbsoluteID), 0, FileInfo, SizeOf(FileInfo), Flags);
   Result:=FileInfo.iIcon;
end;

function GetShellIconIndex(ShellFolder: IShellFolder; RelativeID: PItemIDList;
	Open: Boolean = False; Async: Boolean = False): Integer;
const
	ShellOpenFlag: array[Boolean] of UINT = (GIL_FORSHELL, GIL_OPENICON);
var
   ISI: IShellIcon;
   Flags: UINT;
begin
   Try
      ISI:=ShellFolder as IShellIcon;
      Flags:=ShellOpenFlag[Open];
      If Async then Flags:=Flags or GIL_ASYNC;
   	If ISI.GetIconOf(RelativeID, Flags, Result) = S_FALSE then Result:=-1;
   except 
   	Result:=-1;
   end;
end;

function GetShellFileSize(ShellFolder: IShellFolder; RelativeID: PItemIDList): Int64;
var
   FileData: TWin32FindData;
begin
   FillChar(FileData, SizeOf(FileData), #0);
   If SHGetDataFromIDList(ShellFolder, RelativeID, SHGDFIL_FINDDATA,
      @FileData, SizeOf(FileData)) = NOERROR then
      begin
   		With FileData do Result:=(nFileSizeHigh * MAXDWORD) + nFileSizeLow;
      end
   else
   	Result:=0;
end;

function	Shl_IsAttributes(ShellFolder: IShellFolder; RelativeID: PItemIDList;
	Attributes: UINT): Boolean;
var
	Flags: UINT;
begin
	Flags:=Attributes;
   OleCheck(ShellFolder.GetAttributesOf(1, RelativeID, Flags));
   Result:=Attributes and Flags <> 0;
end;

function AttrFolder(ShellFolder: IShellFolder; RelativeID: PItemIDList): Boolean;
begin
   Result:=Shl_IsAttributes(ShellFolder, RelativeID, SFGAO_FOLDER);
end;

function AttrGhosted(ShellFolder: IShellFolder; RelativeID: PItemIDList): Boolean;
begin
   Result:=Shl_IsAttributes(ShellFolder, RelativeID, SFGAO_GHOSTED);
end;

function AttrLink(ShellFolder: IShellFolder; RelativeID: PItemIDList): Boolean;
begin
   Result:=Shl_IsAttributes(ShellFolder, RelativeID, SFGAO_LINK);
end;

function AttrShare(ShellFolder: IShellFolder; RelativeID: PItemIDList): Boolean;
begin
   Result:=Shl_IsAttributes(ShellFolder, RelativeID, SFGAO_SHARE);
end;

function AttrHidden(ShellFolder: IShellFolder; RelativeID: PItemIDList): Boolean;
begin
   Result:=Shl_IsAttributes(ShellFolder, RelativeID, SFGAO_HIDDEN);
end;

function AttrFileSystem(ShellFolder: IShellFolder; RelativeID: PItemIDList): Boolean;
begin
   Result:=Shl_IsAttributes(ShellFolder, RelativeID, SFGAO_FILESYSTEM or SFGAO_FILESYSANCESTOR);
end;

function FileNameToID(ShellFolder: IShellFolder; AOwner: HWND;
	FileName: String; out NewID: PItemIDList): HResult;
var
   P: PWideChar;
   Flags, NumChars: LongWord;
begin
   NumChars:=Length(FileName);
   Flags:=0;
   P:=StringToOleStr(FileName);
   Result:=ShellFolder.ParseDisplayName(AOwner, nil, P, NumChars, NewID, Flags);
end;

function IDToFileName(ID: PItemIDList): String;
var
   tmp: Array[0..MAX_PATH] of Char;
begin
   If SHGetPathFromIdList(ID, @Tmp) then Result:=String(@Tmp) else Result:='';
end;

procedure DisposePIDL(var ID: PItemIDList);
var
  	Malloc: IMalloc;
begin
	If ID = nil then Exit;
   OleCheck(SHGetMalloc(Malloc));
   Malloc.Free(ID);
   ID:=nil;
end;

function CopyITEMID(Malloc: IMalloc; ID: PItemIDList): PItemIDList;
begin
	Result:=Malloc.Alloc(ID^.mkid.cb + SizeOf(ID^.mkid.cb));
   CopyMemory(Result, ID, ID^.mkid.cb + SizeOf(ID^.mkid.cb));
end;

function GetPIDLSize(IDList: PItemIDList): Integer;
begin
  	Result:=0;
   If Assigned(IDList) then
   	begin
      	Result:=SizeOf(IDList^.mkid.cb);
    		While IDList^.mkid.cb <> 0 do
         	begin
            	Result:=Result + IDList^.mkid.cb;
               IDList:=NextPIDL(IDList);
            end;
      end;
end;

function NextPIDL(IDList: PItemIDList): PItemIDList;
begin
	Result:=IDList;
   Inc(PChar(Result), IDList^.mkid.cb);
end;

procedure StripLastID(IDList: PItemIDList);
var
	MarkerID: PItemIDList;
begin
	MarkerID:=IDList;
   If Assigned(IDList) then
   	begin
      	While IDList.mkid.cb <> 0 do
         	begin
            	MarkerID:=IDList;
               IDList:=NextPIDL(IDList);
            end;
         MarkerID.mkid.cb:=0;
      end;
end;

function AbsoluteIDToRelative(IDList: PItemIDList): PItemIDList;
begin
   Result:=CopyPIDL(IDList);
   If Assigned(IDList) then
      begin

      end;
end;

function CreatePIDL(Size: Integer): PItemIDList;
var
	Malloc: IMalloc;
   HR: HResult;
begin
	Result:=nil;
   HR:=SHGetMalloc(Malloc);
   If Failed(HR) then Exit;
   Try
   	Result:=Malloc.Alloc(Size);
      If Assigned(Result) then FillChar(Result^, Size, 0);
	finally
  	end;
end;

function CopyPIDL(IDList: PItemIDList): PItemIDList;
var
	Size: Integer;
begin
	Size:=GetPIDLSize(IDList);
   Result:=CreatePIDL(Size);
   If Assigned(Result) then CopyMemory(Result, IDList, Size);
end;

function ConcatPIDLs(IDList1, IDList2: PItemIDList): PItemIDList;
var
	cb1, cb2: Integer;
begin
	If Assigned(IDList1) then
   	cb1:=GetPIDLSize(IDList1) - SizeOf(IDList1^.mkid.cb)
   else
   	cb1:=0;
   cb2:=GetPIDLSize(IDList2);
   Result:=CreatePIDL(cb1 + cb2);
   If Assigned(Result) then
   	begin
      	If Assigned(IDList1) then CopyMemory(Result, IDList1, cb1);
    		CopyMemory(PChar(Result) + cb1, IDList2, cb2);
  		end;
end;

function GetPIDLLevel(IDList: PItemIdList): Integer;
begin
   Result:=0;
   If not Assigned(IDList) then Exit;
   While (IDList^.mkId.cb <> 0) and (Result < 200) do
   	begin
   		Inc(Result);
         IDList:=PItemIDList(@IDList^.mkId.abID[IDList^.mkId.cb - 2]);
      end;
end;

function ComparePIDLs(DesktopFolder: IShellFolder; IDList1, IDList2: PItemIDList): Boolean;
begin
   Result:=DesktopFolder.CompareIDs(0, IDList1, IDList2) = 0;
end;

function GetFileNamesFromHandle(h: HGLOBAL): TStrings;
var
   num, i: Integer;
   FFileName: array [0..MAX_PATH] of Char;
begin
   Result:=nil;
   If h = 0 then Exit;
   num:=DragQueryFile(h, $FFFFFFFF, nil, 0);
   If num <= 0 then Exit;
   Result:=TStringList.Create;
   For i:=0 to num - 1 do
      begin
         If Failed(DragQueryFile(h, i, FFileName, SizeOf(FFileName))) then Break;
         Result.Add(FFileName);
      end;
end;

function GetFileNamesFromDataObject(lpdobj: IDataObject): TStrings;
var
   StgMedium: TStgMedium;
   FormatEtc: TFormatEtc;
   hr       : HResult;
begin
   Result:=nil;
   If not Assigned(lpdobj) then Exit;
   With FormatEtc do
      begin
         cfFormat:=CF_HDROP;
         ptd     :=nil;
         dwAspect:=DVASPECT_CONTENT;
         lindex  :=-1;
         tymed   :=TYMED_HGLOBAL;
      end;
   hr:=lpdobj.GetData(FormatEtc, StgMedium);
   If Failed(hr) then Exit;
   Result:=GetFileNamesFromHandle(StgMedium.hGlobal);
   ReleaseStgMedium(StgMedium);
end;

end.
