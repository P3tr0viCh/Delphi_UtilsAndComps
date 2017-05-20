unit Utils_Files;

interface

//{$DEBUGINFO OFF}
//{$WARNINGS OFF}

uses
  Winapi.Windows, Vcl.Forms, Vcl.Graphics, Winapi.ShellAPI, SysUtils,
  Winapi.ActiveX, Winapi.ShlObj, System.Win.Registry, INIFiles, Classes,
  Vcl.Dialogs, Vcl.Controls, Winapi.MMSystem, Winapi.PsAPI, Winapi.TlHelp32,
  Utils_Masks, Utils_Misc, System.Win.ComObj;

resourcestring
  rsADToDrive       = 'Нет доступа к %s' + #13#10#13#10 + 'Устройство не готово';

  rsErrorFileNotFound = 'Файл "%s" не существует или не доступен в данный момент';

  rsWinDir          = '%WINDIR%';          // C:\WINDOWS
  rsSystemRoot      = '%SYSTEMROOT%';      // C:\WINDOWS
  rsDesktop         = '%DESKTOP%';        // C:\Documents and Settings\Администратор\Рабочий стол
  rsAllDesktop      = '%ALLDESKTOP%';      // C:\Documents and Settings\All Users\Рабочий стол
  rsUserProfile     = '%USERPROFILE%';    // C:\Documents and Settings\Администратор
  rsAllUserProfile  = '%ALLUSERSPROFILE%';// C:\Documents and Settings\All Users
  rsPersonal        = '%PERSONAL%';        // C:\Documents and Settings\Администратор\Мои документы
  rsAllPersonal     = '%ALLPERSONAL%';    // C:\Documents and Settings\All Users\Мои документы
  rsPictures        = '%PICTURES%';        // C:\Documents and Settings\Администратор\Мои рисунки
  rsAllPictures     = '%ALLPICTURES%';    // C:\Documents and Settings\All Users\Мои рисунки
  rsMusic           = '%MUSIC%';          // C:\Documents and Settings\Администратор\Моя музыка
  rsAllMusic        = '%ALLMUSIC%';        // C:\Documents and Settings\All Users\Моя музыка
  rsSystem          = '%SYSTEM%';          // C:\WINDOWS\System32
  rsProgramFiles    = '%PROGRAMFILES%';    // C:\Program Files
  rsTemp            = '%TEMP%';            // C:\WINDOWS\Temp

const
  SHFMT_OPT_FULL     = $0001;
  SHFMT_OPT_SYSONLY  = $0002;
  SHFMT_ID_DEFAULT   = $FFFF;

  SHFMT_NOFORMAT     = $FFFFFFFD;
  SHFMT_CANCEL       = $FFFFFFFE;
  SHFMT_ERROR        = $FFFFFFFF;


  CSIDL_MUSIC            = $000D;
  CSIDL_WINDOWS          = $0024;
  CSIDL_SYSTEM          = $0025;
//  CSIDL_SYSTEM        = $0029;
  CSIDL_PROGRAMFILES    = $0026;
  CSIDL_PICTURES        = $0027;
  CSIDL_COMMONPERSONAL  = $002E;
  CSIDL_COMMONMUSIC      = $0035;
  CSIDL_COMMONPICTURES  = $0036;
  CSIDL_RESOURCES        = $0038;


type
  PShellFileInfo = ^TShellFileInfo;
  TShellFileInfo = record
    ParentFolder: IShellFolder;
    RelativeID: PItemIDList;
    AbsoluteID: PItemIDList;
    FileName: String;
  end;

  TShellFileList = class(TList)
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  private
    function Get(Index: Integer): PShellFileInfo;
    procedure Put(Index: Integer; const Value: PShellFileInfo);
  public
    property Items[Index: Integer]: PShellFileInfo read Get write Put; default;
  end;

  TOnFindFile       = procedure (AShellFileInfo: PShellFileInfo) of object;
  TOnFindFilesCount = procedure (AFileCount: Integer) of object;
  TOnChangeFolder   = procedure (AFolder: String) of object;
  TOnOpenFolder     = procedure of object;

  TFOFunction = (foCopy, foDelete, foMove, foRename);

function GetFileIcon(const FileName: String; SmallIcon: Boolean): HICON;
function GetFileIconIndex(const FileName: String; Large: Boolean = True; Open: Boolean = False): Integer;
function GetSysImageList(const SmallIcon: Boolean): THandle;
function GetFileDisplayName(const FileName: String): String;
function GetFileTypeName(const FileName: String): String;
function GetVolumeInfo(const Drive: Char; var VolumeName, FileSystemName: String;
        var VolumeSerialNum, MaxComponentLen, FileSystemFlags: DWORD): Boolean;
function GetVolumeName(const Drive: Char): String;
function GetDriveFreeSpace(const Drive: Char; var FreeSpace, TotalSpace: Int64): Boolean;

function SHOperationFile(FromNames, ToNames: String; FOFunction: TFOFunction; AllowUndo: Boolean = True;
  Flags: FILEOP_FLAGS = 0; WindowHandle: HWND = 0): Boolean;
function SHDeleteFile(Files: String; AllowUndo: Boolean = True; WindowHandle: HWND = 0): Boolean;
function SHDeleteFileSilent(Files: String; WindowHandle: HWND = 0): Boolean;

function GetWinDir: String;
function GetSysDir: String;
function GetTempDir: String;
function GetTemporaryFileName(Prefix: String; NoCreateFile: Boolean): String;
function GetSysFolder(AFolder: Integer): String;
function GetUserProfileFolder: String;
function GetAllUserProfileFolder: String;
function IntToCSIDL(Value: Integer): Integer;
function GetSpecialFolderPath(AFolder: Integer): String;
function GetProgramFilesDir: String;
function GetCommonName(const FileName: String; const DoExpand: Boolean): String;

function GetFileNameWithExt(Ext: String): String;
function AddBS(Dir: String): String;
function DelBS(Dir: String): String;
function SlashSep(const Path, S: String): String;
function CreateDirectories(Dir: string): Boolean;
function ShExecuteEx(const FileName: String): Boolean;
function ShellExecEx(const FileName, Params: String): HINST;
function ShellExecExAs(const FileName, Params: String): HINST;
function ShellExecExAsShift(const FileName, Params: String): HINST;
function ShellExec(const FileName: String): Boolean;
function RunProgram(const CommandLine: String; const AndWait: Boolean = False): Boolean;
function FolderExec(const FolderName: String; const Explore: Boolean): Boolean;
procedure DriveExec(const DriveName: String; const Explore: Boolean);
function OKExec(const Inst: HINST; FileName: String = ''): Boolean;
function FileWithoutExt(const FileName: String): String;
function OnlyFileName(const FileName: String): String;
function MinimizePath(const FileName: String; MaxLength: Integer; Canvas: TCanvas): String;
function GetDrives: String;
function DriveExists(const Drive: String): Boolean;
function Separate(FileName: String; var Params: String): String;
function IsCorrectFileName(const FileName: String): Boolean;
function CorrectFileName(const FileName: String; const IsRelative: Boolean): String;
function GetExistsDirectory(DirName: String): String;
function GetFullFileName(FileName: String): String;
function GetFileSizeStr(FileName: String): Int64;
function OpenCloseCD(CDDrive: Char; OpenCD: Boolean): Boolean;
function FileInAppDir(FileName: String): String;
function IsEmptyFolder(FolderName: String): Boolean;
function IsFolder(FolderName: String): Boolean;
function GetNonExistsFileName(FileName: String): String;
function IsExeFile(const FileName: String): Boolean;
function FindIsFile(SearchRec: TSearchRec; WithoutHidden: Boolean = True): Boolean;

function MsgFileAlreadyExists(const FileName: String): String;
function MsgFileNotExists(const FileName: String): String;
function MsgPathNotExists(const FileName: String): String;
function MsgNonExistingDrive(const Drive: Char): String;
function MsgInvalidDrive(const Drive: Char): String;
function MsgFileNameInvalid(const FileName: String): String;
function MsgFileReadOnly(const FileName: String): String;
function MsgCreateFile(const FileName: String): String;
function MsgBadFileName: String;

function ShellFindFiles(const FromName: Boolean;
  var FolderID: PItemIDList; var FolderName: String;
  ShellFileList: TShellFileList;
  Recursive, IncludeFolders, IncludeHidden, IncludeOnlyFileSystem, AddFoldersToEnd: Boolean;
  DesktopFolder: IShellFolder;
  IncludeMask, ExcludeMask: String;
  OnStopFind: TOnStopNotify;
  OnOpenFolder: TOnOpenFolder;
  OnFindFilesCount: TOnFindFilesCount;
  OnChangeFolder: TOnChangeFolder;
  OnFindFile: TOnFindFile;
  var FolderCount, HiddenCount: Integer): HRESULT;

function SHFormatDrive(hWnd : HWND; Drive, FormatID, Options : Integer): Integer; stdcall;

procedure CreateWin9xProcessList(var List: TStrings);
procedure CreateWinNTProcessList(var List: Tstrings);
procedure GetProcessList(var List: TStrings);
function  EXEIsRunning(AFileName: string; AFullPath: Boolean): Boolean;

implementation

uses Utils_KAndM, Utils_Str, Utils_Shl;

function SHFormatDrive; external 'shell32.dll';

function GetFileIcon(const FileName: String; SmallIcon: Boolean): HICON;
var
  Info: TSHFileInfo;
  Flags: LongWord;
begin
  FillChar(Info, SizeOf(TSHFileInfo), 0);
  if SmallIcon then Flags := SHGFI_SMALLICON else Flags := SHGFI_LARGEICON;
  SHGetFileInfo(PChar(FileName), 0, Info, SizeOf(TSHFileInfo), SHGFI_ICON or Flags);
  Result := CopyIcon(Info.hIcon);
end;

function GetFileIconIndex(const FileName: String; Large: Boolean = True; Open: Boolean = False): Integer;
var
  Flags: Integer;
  Info: TSHFileInfo;
begin
  FillChar(Info, SizeOf(Info), #0);
  Flags := SHGFI_SYSICONINDEX or SHGFI_ICON;
  if Open  then Flags := Flags or SHGFI_OPENICON;
  if Large  then Flags := Flags or SHGFI_LARGEICON
  else Flags := Flags or SHGFI_SMALLICON;
  SHGetFileInfo(PChar(FileName), 0, Info, SizeOf(Info), Flags);
  Result := Info.iIcon;
end;

function GetSysImageList(const SmallIcon: Boolean): THandle;
var
  Info: TSHFileInfo;
  Flags: LongWord;
  DrivesID: PItemIDList;
begin
  OleCheck(SHGetSpecialFolderLocation(Application.Handle, CSIDL_DRIVES, DrivesID));
  if SmallIcon then Flags := SHGFI_SMALLICON else Flags := SHGFI_LARGEICON;
  Result := SHGetFileInfo(PChar(DrivesID), 0, Info, SizeOf(Info),
    SHGFI_SYSICONINDEX or SHGFI_PIDL or Flags);
  DisposePIDL(DrivesID);
end;

function GetFileDisplayName(const FileName: String): String;
var
  Info: TSHFileInfo;
begin
  FillChar(Info, SizeOf(Info), #0);
  Result := FileName;
  if SHGetFileInfo(PChar(FileName), 0, Info, SizeOf(TSHFileInfo),
    SHGFI_DISPLAYNAME) <> 0 then
  Result := Info.szDisplayName;
end;

function GetFileTypeName(const FileName: String): String;
var
  Info: TSHFileInfo;
begin
  FillChar(Info, SizeOf(Info), #0);
  Result := FileName;
  if SHGetFileInfo(PChar(FileName), 0, Info, SizeOf(TSHFileInfo),
    SHGFI_TYPENAME) <> 0 then
  Result := Info.szTypeName;
end;

function GetVolumeInfo(const Drive: Char; var VolumeName, FileSystemName: String;
  var VolumeSerialNum, MaxComponentLen, FileSystemFlags: DWORD): Boolean;
var
  VName, FSName: PChar;
  VNameSize, FSNameSize,
  VSerNum, MaxCompLen, FSFlags: DWORD;
begin
  GetMem(VName, 256); GetMem(FSName, 256);
  try
    VNameSize := 255; FSNameSize := 255;
    Result := GetVolumeInformation(PChar(Drive + ':\'),
      VName, VNameSize, @VSerNum, MaxCompLen, FSFlags, FSName, FSNameSize);
    if Result then
      begin
        VolumeName := VName;
        FileSystemName := FSName;
        VolumeSerialNum := VSerNum;
        MaxComponentLen := MaxCompLen;
        FileSystemFlags := FSFlags;
      end;
  finally
    FreeMem(VName, 256); FreeMem(FSName, 256);
  end;
end;

function GetVolumeName(const Drive: Char): String;
var
  FSName: String;
  VSerNum, MaxCompLen, FSFlags: DWORD;
begin
  if not GetVolumeInfo(Drive, Result, FSName, VSerNum,
    MaxCompLen, FSFlags) then Result := 'Не готов';
end;

function GetDriveFreeSpace(const Drive: Char; var FreeSpace, TotalSpace: Int64): Boolean;
var
  OldErrorMode: Cardinal;
begin
  OldErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    Result := GetDiskFreeSpaceEx(PChar(Drive + ':\'), FreeSpace, TotalSpace, nil);
  finally
    SetErrorMode(OldErrorMode);
  end;
end;

function SHOperationFile(FromNames, ToNames: String; FOFunction: TFOFunction;
  AllowUndo: Boolean = True; Flags: FILEOP_FLAGS = 0; WindowHandle: HWND = 0): Boolean;
const
  Mode: array[TFOFunction] of UINT = (FO_COPY, FO_DELETE, FO_MOVE, FO_RENAME);
var
  SHFOS: TSHFileOpStruct;
begin
  if WindowHandle = 0 then WindowHandle := Application.MainForm.Handle;
  FillChar(SHFOS, SizeOf(TSHFileOpStruct), 0);
  with SHFOS do
    begin
      wnd := WindowHandle;
      wFunc := Mode[FOFunction];
      pFrom := PChar(FromNames + #0);
      pTo := PChar(ToNames + #0);
      fFlags := Flags or FOF_NOCONFIRMMKDIR;
      if AllowUndo then fFlags := fFlags or FOF_ALLOWUNDO;
    end;
  Result := (SHFileOperation(SHFOS) = 0) and not SHFOS.fAnyOperationsAborted;
end;

function SHDeleteFile(Files: String; AllowUndo: Boolean = True; WindowHandle: HWND = 0): Boolean;
begin
  Result := SHOperationFile(Files, '', foDelete, AllowUndo, 0, WindowHandle);
end;

function SHDeleteFileSilent(Files: String; WindowHandle: HWND = 0): Boolean;
begin
  Result := SHOperationFile(Files, '', foDelete, False, FOF_SILENT or FOF_NOCONFIRMATION or FOF_NOERRORUI, WindowHandle);
end;

function GetFileNameWithExt(Ext: String): String;
begin
  Result := ChangeFileExt(ParamStr(0), '.' + Ext)
end;

function AddBS(Dir: String): String;
begin
  Result := Dir;
  if Dir = '' then Exit;
  if not (Result[Length(Result)] = PathDelim) then Result := Result + PathDelim;
end;

function DelBS(Dir: String): String;
begin
  Result := Dir;
  if Length(Result) > 3 then
    if Result[Length(Result)] = PathDelim then
      SetLength(Result, Length(Result) - 1);
end;

function SlashSep(const Path, S: String): String;
begin
  Result := AddBS(Path) + S;
end;

function CreateDirectories(Dir: string): Boolean;
begin
  Result := True;
  Dir := DelBS(Dir);
  if (Length(Dir) < 3) or DirectoryExists(Dir) or
    (ExtractFilePath(Dir) = Dir) then Exit;
  Result := CreateDirectories(ExtractFilePath(Dir)) and CreateDir(Dir);
end;

function IntToCSIDL(Value: Integer): Integer;
const
  CSIDLS: array[1..39] of Integer =
    (CSIDL_DESKTOP, CSIDL_INTERNET, CSIDL_PROGRAMS,
    CSIDL_CONTROLS, CSIDL_PRINTERS, CSIDL_PERSONAL,
    CSIDL_FAVORITES, CSIDL_STARTUP, CSIDL_RECENT,
    CSIDL_SENDTO, CSIDL_BITBUCKET, CSIDL_STARTMENU,
    CSIDL_DESKTOPDIRECTORY, CSIDL_DRIVES, CSIDL_NETWORK,
    CSIDL_NETHOOD, CSIDL_FONTS, CSIDL_TEMPLATES,
    CSIDL_COMMON_STARTMENU, CSIDL_COMMON_PROGRAMS, CSIDL_COMMON_STARTUP,
    CSIDL_COMMON_DESKTOPDIRECTORY, CSIDL_APPDATA, CSIDL_PRINTHOOD,
    CSIDL_ALTSTARTUP, CSIDL_COMMON_ALTSTARTUP, CSIDL_COMMON_FAVORITES,
    CSIDL_INTERNET_CACHE, CSIDL_COOKIES, CSIDL_HISTORY,

    CSIDL_MUSIC, CSIDL_WINDOWS, CSIDL_SYSTEM,
    CSIDL_PROGRAMFILES, CSIDL_PICTURES, CSIDL_COMMONPERSONAL,
    CSIDL_COMMONMUSIC, CSIDL_COMMONPICTURES, CSIDL_RESOURCES);
begin
  Result := CSIDLS[Value];
end;

function GetSpecialFolderPath(AFolder: Integer): String;
var
  Path: array[0..MAX_PATH] of Char;
begin
  Result := '';
  if SHGetSpecialFolderPath(0, Path, AFolder, False) then Result := Path;
end;

function GetWinDir: String;
var
  Buffer: array[0..MAX_PATH] of Char;
begin
  SetString(Result, Buffer, GetWindowsDirectory(Buffer, SizeOf(Buffer)));
end;

function GetSysDir: String;
var
  Buffer: array[0..MAX_PATH] of Char;
begin
  SetString(Result, Buffer, GetSystemDirectory(Buffer, SizeOf(Buffer)));
end;

function GetTempDir: String;
begin
  SetLength(Result, MAX_PATH);
  GetTempPath(MAX_PATH, PChar(Result));
  GetLongPathName(PChar(Result), PChar(Result), MAX_PATH);
  SetLength(Result, StrLen(PChar(Result)));
end;

function GetTemporaryFileName(Prefix: String; NoCreateFile: Boolean): String;
var
  Buffer: PChar;
begin
  GetMem(Buffer, MAX_PATH);
  try
    if GetTempFileName(PChar(GetTempDir), PChar(Prefix), 0, Buffer) <> 0 then
      Result := Buffer
    else
      Result := '';
    if NoCreateFile and (Result <> '') then DeleteFile(Result);
  finally
    FreeMem(Buffer, MAX_PATH);
  end;
end;

function GetSysFolder(AFolder: Integer): String;
begin
  case AFolder of
  1: Result := GetSpecialFolderPath(CSIDL_DESKTOPDIRECTORY);
  2: Result := GetSpecialFolderPath(CSIDL_COMMON_DESKTOPDIRECTORY);
  else
    begin Result := ''; Exit; end;
  end;
  Result := DelBS(ExtractFilePath(Result));
end;

function GetUserProfileFolder: String;
begin
  Result := GetSysFolder(1);
end;

function GetAllUserProfileFolder: String;
begin
  Result := GetSysFolder(2);
end;

function GetCommonName(const FileName: String; const DoExpand: Boolean): String;
var
  i: Integer;
  RS1, RS2, S1, S2: String;
begin
  if FileName = '' then Exit;
  Result := Trim(FileName);
  for i := 1 to 14 do
    begin
      case i of
      1:  begin S1 := GetSysDir;                                            S2 := rsSystem;         end;
      2:  begin S1 := GetTempDir;                                           S2 := rsTemp;           end;
      3:  begin S1 := GetWinDir;                                            S2 := rsSystemRoot;     end;
      4:  begin S1 := GetSpecialFolderPath(CSIDL_PROGRAMFILES);             S2 := rsProgramFiles;   end;
      5:  begin S1 := GetSpecialFolderPath(CSIDL_DESKTOPDIRECTORY);         S2 := rsDesktop;        end;
      6:  begin S1 := GetSpecialFolderPath(CSIDL_COMMON_DESKTOPDIRECTORY);  S2 := rsAllDesktop;     end;
      7:  begin S1 := GetSpecialFolderPath(CSIDL_PICTURES);                 S2 := rsPictures;       end;
      8:  begin S1 := GetSpecialFolderPath(CSIDL_COMMONPICTURES);           S2 := rsAllPictures;    end;
      9:  begin S1 := GetSpecialFolderPath(CSIDL_MUSIC);                    S2 := rsMusic;          end;
      10: begin S1 := GetSpecialFolderPath(CSIDL_COMMONMUSIC);              S2 := rsAllMusic;        end;
      11: begin S1 := GetSpecialFolderPath(CSIDL_PERSONAL);                 S2 := rsPersonal;        end;
      12: begin S1 := GetSpecialFolderPath(CSIDL_COMMONPERSONAL);           S2 := rsAllPersonal;    end;
      13: begin S1 := GetUserProfileFolder;                                 S2 := rsUserProfile;    end;
      14: begin S1 := GetAllUserProfileFolder;                              S2 := rsAllUserProfile; end;
      else Exit;
      end;
      if S1 = '' then Continue;
      if DoExpand then begin RS1 := S2; RS2 := S1; end
      else begin RS1 := S1; RS2 := S2; end;
      Result := StringReplace(Result, RS1, RS2, [rfReplaceAll, rfIgnoreCase]);
    end;
end;

function GetProgramFilesDir: String;
begin
  with TRegistry.Create do
    try
      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKeyReadOnly('SOFTWARE\Microsoft\Windows\CurrentVersion') then
        begin
          Result := ReadString('ProgramFilesDir');
          if Result = '' then Result := 'C:\Program Files';
        end
      else
        Result := 'C:\Program Files';
    finally
      Free;
    end;
end;

function ShExecuteEx(const FileName: String): Boolean;
var
  ShellInfo: TShellExecuteInfo;
begin
  with ShellInfo do
    begin
      cbSize := SizeOf(TShellExecuteInfo);
      // fMask := SEE_MASK_IDLIST;
      Wnd := Application.Handle;
      lpFile := PChar(FileName);
      lpParameters := nil;
      lpDirectory := nil;
      nShow := SW_SHOWNORMAL;
      // lpIDList := ID;
    end;
  Result := ShellExecuteEx(@ShellInfo);
end;

function ShellExecEx(const FileName, Params: String): HINST;
begin
  Result := ShellExecute(Application.Handle, nil, PChar(FileName),
    PChar(Params), nil, SW_SHOWNORMAL);
end;

function ShellExecExAs(const FileName, Params: String): HINST;
begin
  Result := ShellExecute(Application.Handle, PChar('runas'), PChar(FileName),
    PChar(Params), nil, SW_SHOWNORMAL);
end;

function ShellExecExAsShift(const FileName, Params: String): HINST;
begin
  if IsShift then Result := ShellExecExAs(FileName, Params)
             else Result := ShellExecEx(FileName, Params);
end;

function OKExec(const Inst: HINST; FileName: String = ''): Boolean;
begin
  Result := Inst > 32;
  if not Result then
    begin
      if Inst = ERROR_ACCESS_DENIED then Exit;
      SetForegroundWindow(Application.Handle);
      if (Inst = ERROR_FILE_NOT_FOUND) and (FileName <> '') then
        MsgBoxErr(Format(rsErrorFileNotFound, [FileName]))
      else
        ShowErrorBox(GetLastError);
    end;
end;

function ShellExec(const FileName: String): Boolean;
begin
  Result := OKExec(ShellExecEx(FileName, ''), FileName);
end;

function FolderExec(const FolderName: String; const Explore: Boolean): Boolean;
const
  OpenExplore: array[Boolean] of String = ('open', 'explore');
begin
  Result := OKExec(ShellExecute(Application.Handle,
    PChar(OpenExplore[Explore]), PChar(FolderName), nil, nil, SW_SHOWNORMAL));
end;

procedure DriveExec(const DriveName: String; const Explore: Boolean);
const
  OpenExplore: array[Boolean] of String = ('open', 'explore');
var
  OK: Boolean;
begin
  repeat
    if DirectoryExists(DriveName) then
      begin
        OK := True;
        ShellExecute(Application.Handle,
          PChar(OpenExplore[Explore]), PChar(DriveName), nil, nil, SW_SHOWNORMAL);
      end
    else
      OK := MsgBox(Format(rsADToDrive, [DriveName]),
        MB_RETRYCANCEL or MB_ICONERROR) = ID_CANCEL;
  until OK;
end;

function FileWithoutExt(const FileName: String): String;
var
  PosDot: Integer;
begin
  Result := FileName;
  if Pos('.', FileName) = 0 then Exit;
  PosDot := Length(FileName);
  while (FileName[PosDot] <> '.') and (PosDot > 1) do Dec(PosDot);
  Result := Copy(FileName, 1, PosDot - 1);
end;

function OnlyFileName(const FileName: String): String;
begin
  if Length(FileName) > 3 then
    Result := FileWithoutExt(ExtractFileName(FileName))
  else
    Result := FileName;
end;

function MinimizePath(const FileName: String; MaxLength: Integer; Canvas: TCanvas): String;
const
  cThreeDot = '...';
var
  LenResult, CutFrom: Integer;
begin
  Result := FileName;
  CutFrom := -1;
  while Canvas.TextWidth(Result + cThreeDot) > MaxLength do
    begin
      LenResult := Length(Result);
      CutFrom := LenResult div 2;
      Delete(Result, CutFrom, 1);
    end;
  if CutFrom <> -1 then Insert(cThreeDot, Result, CutFrom);
end;

function GetDrives: String;
var
  i: Byte;
  LogicalDrives: DWORD;
begin
  Result := '';
  LogicalDrives := GetLogicalDrives;
  for i := 0 to 25 do
    if (LogicalDrives and (1 shl i)) > 0 then
      Result := Result + Chr(65 + i);
end;

function DriveExists(const Drive: String): Boolean;
var
  OK: Boolean;
begin
  Result := False;
  repeat
    if DirectoryExists(Drive) then
      begin
        OK := True;
        Result := True;
      end
    else
      OK := MsgBox(Format(rsADToDrive, [Drive]),
        MB_RETRYCANCEL or MB_ICONERROR) = ID_CANCEL;
  until OK;
end;

function Separate(FileName: String; var Params: String): String;
const
  Separator: array[Boolean] of Char = (' ', '"');
var
  i: Integer;
  FirstQuotes: Boolean;
begin
  FirstQuotes := FileName[1] = '"';
  if FirstQuotes then Delete(FileName, 1, 1);
  i := Pos(Separator[FirstQuotes], FileName);
  if i = 0 then i := Length(FileName) + 1;
  Result := Copy(FileName, 1, i - 1);
  Params := Copy(FileName, i + 1, Length(FileName));
  if FirstQuotes then Delete(Params, 1, 1);
end;

function GetFileSizeStr(FileName: String): Int64;
var
  FindHandle: THandle;
  FindData: TWin32FindData;
begin
  Result := -1;
  FindHandle := FindFirstFile(PChar(FileName), FindData);
  if FindHandle <> INVALID_HANDLE_VALUE then
    begin
      Winapi.Windows.FindClose(FindHandle);
      with FindData do
      Result := (nFileSizeHigh * MAXDWORD) + nFileSizeLow;
    end;
end;

function RunProgram(const CommandLine: String; const AndWait: Boolean = False): Boolean;
var
  si: STARTUPINFO;
  pi: PROCESS_INFORMATION;
  Code: DWORD;
begin
  Result := True;
  if CommandLine = '' then Exit;
  ZeroMemory(@si, SizeOf(si));
  si.cb := SizeOf(si);
  si.dwFlags := STARTF_USESHOWWINDOW;
  si.wShowWindow := SW_SHOWNORMAL;
  Result := CreateProcess(nil, PChar(CommandLine), nil, nil, False, 0, nil, nil, si, pi);
  if Result then
    begin
      if AndWait then
        repeat
          GetExitCodeProcess(pi.hProcess, Code);
          ProcMess;
        until Code <> STILL_ACTIVE;
      CloseHandle(pi.hProcess);
      CloseHandle(pi.hThread);
    end;
end;

function IsCorrectFileName(const FileName: String): Boolean;
var
  i: Integer;
begin
  Result := True;
  for i := 1 to Length(FileName) do
    if CharInSet(FileName[i], ['/', '\', ':', '*', '?', '"', '<', '>', '|']) then
      begin
        Result := False;
        Break;
      end;
end;

function CorrectFileName(const FileName: String; const IsRelative: Boolean): String;
var
  i: Integer;
begin
  Result := FileName;
  for i := 1 to Length(Result) do
    case Result[i] of
    '"', '|': Result[i] := '''';
    '/', '<': Result[i] := '(';
    '>':      Result[i] := ')';
    '*', '?':  Result[i] := '.';
    '\':      if IsRelative then Result[i] := ')';
    ':':      if IsRelative then Result[i] := '.';
    end;
end;

function GetExistsDirectory(DirName: String): String;
var
  UpDir: String;
begin
  while (not DirectoryExists(DirName)) and (DirName <> '') do
    begin
      UpDir := ExtractFileDir(DirName);
      if UpDir = DirName then DirName := '' else DirName := UpDir;
    end;
  Result := DirName;
end;

function GetFullFileName(FileName: String): String;
var
  FindHandle: THandle;
  FindData: TWin32FindData;
begin
  Result := DelBS(FileName);
  if Length(Result) <= 3 then Exit;
  FindHandle := FindFirstFile(PChar(Result), FindData);
  if FindHandle <> INVALID_HANDLE_VALUE then
    begin
      Winapi.Windows.FindClose(FindHandle);
      Result := SlashSep(GetFullFileName(ExtractFilePath(Result)),
      FindData.cFileName);
    end;
end;

function OpenCloseCD(CDDrive: Char; OpenCD: Boolean): Boolean;
// From Jan Peter Stotz
const
  CloseOpen: array[Boolean] of DWORD = (MCI_SET_DOOR_CLOSED, MCI_SET_DOOR_OPEN);
var
  Res: MCIERROR;
  OpenParm: TMCI_Open_Parms;
  Flags: DWORD;
  DeviceID: Word;
  S: String;
begin
  Result := False;
  S := CDDrive + ':';
  Flags := MCI_OPEN_TYPE or MCI_OPEN_ELEMENT;
  with OpenParm do
    begin
      dwCallback := 0;
      lpstrDeviceType := 'CDAudio';
      lpstrElementName := PChar(S);
    end;
  Res := mciSendCommand(0, MCI_OPEN, Flags, LongInt(@OpenParm));
  if Res <> 0 then Exit;
  DeviceID := OpenParm.wDeviceID;
  try
    Res := mciSendCommand(DeviceID, MCI_SET, CloseOpen[OpenCD], 0);
    if Res = 0 then Exit;
    Result := True;
  finally
    mciSendCommand(DeviceID, MCI_CLOSE, Flags, LongInt(@OpenParm));
  end;
end;

function MsgFileAlreadyExists(const FileName: String): String;
begin
  Result := Format(LoadStringFromComdlg32(257), [FileName]);
end;

function MsgFileNotExists(const FileName: String): String;
begin
  Result := Format(LoadStringFromComdlg32(391), [FileName]);
end;

function MsgPathNotExists(const FileName: String): String;
begin
  Result := Format(LoadStringFromComdlg32(392), [FileName + sLineBreak]);
end;

function MsgNonExistingDrive(const Drive: Char): String;
begin
  Result := Format(LoadStringFromComdlg32(387), [Drive]);
end;

function MsgInvalidDrive(const Drive: Char): String;
begin
  Result := Format(LoadStringFromComdlg32(388), [Drive]);
end;

function MsgFileNameInvalid(const FileName: String): String;
begin
  Result := Format(LoadStringFromComdlg32(393), [FileName]);
end;

function MsgFileReadOnly(const FileName: String): String;
begin
  Result := Format(LoadStringFromComdlg32(396), [FileName]);
end;

function MsgCreateFile(const FileName: String): String;
begin
  Result := Format(LoadStringFromComdlg32(402), [FileName]);
end;

function MsgBadFileName: String;
begin
  Result := LoadStringFromShell32(4109);
end;

function TShellFileList.Get(Index: Integer): PShellFileInfo;
begin
  Result := inherited Items[Index];
end;

procedure TShellFileList.Notify(Ptr: Pointer; Action: TListNotification);
begin
  if Action = lnDeleted then
    begin
      DisposePIDL(PShellFileInfo(Ptr)^.RelativeID);
      DisposePIDL(PShellFileInfo(Ptr)^.AbsoluteID);
    end;
end;

procedure TShellFileList.Put(Index: Integer; const Value: PShellFileInfo);
begin
  inherited Items[Index] := Value;
end;

function ShellFindFiles(const FromName: Boolean;
  var FolderID: PItemIDList; var FolderName: String;
  ShellFileList: TShellFileList;
  Recursive, IncludeFolders, IncludeHidden, IncludeOnlyFileSystem, AddFoldersToEnd: Boolean;
  DesktopFolder: IShellFolder;
  IncludeMask, ExcludeMask: String;
  OnStopFind: TOnStopNotify;
  OnOpenFolder: TOnOpenFolder;
  OnFindFilesCount: TOnFindFilesCount;
  OnChangeFolder: TOnChangeFolder;
  OnFindFile: TOnFindFile;
  var FolderCount, HiddenCount: Integer): HRESULT;
var
  Options: DWORD;
  ThisIsFolder: Boolean;
  IncludeMasks, ExcludeMasks: TCollection;
  FileCount: Integer;

  function NeedStop: Boolean;
  begin
    Result := False;
    if Assigned(OnStopFind) then OnStopFind(Result);
  end;

  function SubShellFindFiles(FolderID: PItemIDList; FirstEnter: Boolean = False): HResult;
  var
    NumIDs: LongWord;
    ID, AbsID: PItemIDList;
    EnumList: IEnumIDList;
    FileName, FullFileName: String;
    SubFolder: IShellFolder;

    procedure AddFile(DoAdd: Boolean);
    var
      ShellFileInfo: PShellFileInfo;
    begin
      if not DoAdd then begin Inc(HiddenCount); Exit; end;
      ShellFileInfo := New(PShellFileInfo);
      with ShellFileInfo^ do
        begin
          ParentFolder := SubFolder;
          RelativeID := CopyPIDL(ID); AbsoluteID := CopyPIDL(AbsID);
          FileName := FullFileName;
        end;
      Inc(FileCount);
      if Assigned(OnFindFile) then OnFindFile(ShellFileInfo);
      if Assigned(ShellFileList) then
        begin
          if ThisIsFolder xor AddFoldersToEnd then
            ShellFileList.Insert(0, ShellFileInfo)
          else
            ShellFileList.Add(ShellFileInfo);
        end
      else Dispose(ShellFileInfo);
      if Assigned(OnFindFilesCount) then OnFindFilesCount(FileCount);
    end;
    begin
      Result := NOERROR;
      if NeedStop then Exit;
      if GetPIDLLevel(FolderID) = 0 then
        SubFolder := DesktopFolder
      else
        Result := DesktopFolder.BindToObject(FolderID, nil, IID_IShellFolder, Pointer(SubFolder));
      if Result <> NOERROR then Exit;
      if FirstEnter then
        begin
          if Assigned(OnOpenFolder) then OnOpenFolder;
        end;
      Result := SubFolder.EnumObjects(Application.Handle, Options, EnumList);
      if Result <> NOERROR then Exit;
      while EnumList.Next(1, ID, NumIDs) = S_OK do
        try
          if NeedStop then Break;
          if not AttrFileSystem(SubFolder, ID) and IncludeOnlyFileSystem then Continue;
          AbsID := ConcatPIDLs(FolderID, ID);
          try
            FullFileName := GetDisplayName(SubFolder, ID, SHGDN_FORPARSING);
            if UpperCase(ExtractFileExt(FullFileName)) = '.ZIP' then
              ThisIsFolder := IsFolder(FullFileName)
            else
              ThisIsFolder := AttrFolder(SubFolder, ID);
            if ThisIsFolder then
              begin
                Inc(FolderCount);
                AddFile(IncludeFolders);
              end
            else
              begin
                FileName := ExtractFileName(FullFileName);
                AddFile(MultiMatches(IncludeMasks, FileName) and
                  not MultiMatches(ExcludeMasks, FileName));
              end;
            if ThisIsFolder and Recursive then
              begin
                if Assigned(OnChangeFolder) then OnChangeFolder(FullFileName);
                Result := SubShellFindFiles(AbsID);
              end;
          finally
            DisposePIDL(AbsID);
          end;
        finally
          DisposePIDL(ID);
        end;
    end;
begin
  if not Assigned(DesktopFolder) then OleCheck(SHGetDesktopFolder(DesktopFolder));
  if FromName then
    Result := FileNameToID(DesktopFolder, Application.Handle, FolderName, FolderID)
  else
    Result := NOERROR;
  try
    if Result <> NOERROR then Exit;
    FolderName := GetDisplayName(DesktopFolder, FolderID, SHGDN_FORPARSING);
    IncludeMasks := TCollection.Create(TMultiMask);
    ExcludeMasks := TCollection.Create(TMultiMask);
    try
      if IncludeMask = '' then IncludeMask := '*';
      CreateMasks(IncludeMasks, IncludeMask);
      CreateMasks(ExcludeMasks, ExcludeMask);
      Options := SHCONTF_FOLDERS or SHCONTF_NONFOLDERS;
      if IncludeHidden then Options := Options or SHCONTF_INCLUDEHIDDEN;
      FolderCount := 0; HiddenCount := 0; FileCount := 0;
      Result := SubShellFindFiles(FolderID, True);
    finally
      ExcludeMasks.Free;
      IncludeMasks.Free;
    end;
  finally
    if (Result <> NOERROR) and (Result <> E_ACCESSDENIED) then ShowErrorBox(Result);
  end;
end;

function FileInAppDir(FileName: String): String;
begin
  Result := SlashSep(ExtractFilePath(Application.ExeName), FileName);
end;

function IsEmptyFolder(FolderName: String): Boolean;
var
  Status: Integer;
  SearchRec: TSearchRec;
begin
  Result := True;
  Status := FindFirst(SlashSep(FolderName, '*.*'), faAnyFile, SearchRec);
  try
    while Status = 0 do
      begin
        if FindIsFile(SearchRec, False) then
          Status := FindNext(SearchRec)
        else
          begin
            Result := False;
            Status := -1;
          end;
        ProcMess;
      end;
  finally
    FindClose(SearchRec);
  end;
end;

function IsFolder(FolderName: String): Boolean;
begin
{$WARNINGS OFF}
  Result := IsValueInWord(FileGetAttr(FolderName), faDirectory);
{$WARNINGS ON}
end;

function GetNonExistsFileName(FileName: String): String;
var
  Count: LongWord;
  Ext: String;
begin
  Count := 0;
  Ext := ExtractFileExt(FileName);
  FileName := FileWithoutExt(FileName);
  repeat
    Result := FileName + '_' + IToS_0(Count, 1) + Ext;
    Inc(Count);
  until not FileExists(Result);
end;

function IsExeFile(const FileName: String): Boolean;
var
  Ext: String;
begin
  Ext := AnsiLowerCase(ExtractFileExt(FileName));
  Result := (Ext = '.exe') or (Ext = '.com');
end;

function FindIsFile(SearchRec: TSearchRec; WithoutHidden: Boolean = True): Boolean;
var
  Attr: Integer;
begin
  Attr := {faVolumeID or }faDirectory;
{$WARNINGS OFF}
  if WithoutHidden then Attr := Attr or faHidden;
{$WARNINGS ON}
  Result := (SearchRec.Name <> '.') and (SearchRec.Name <> '..') and
    not IsValueInWord(SearchRec.Attr, Attr);
end;

procedure CreateWin9xProcessList(var List: TStrings);
var
  hSnapShot: THandle;
  ProcInfo: TProcessEntry32;
begin
  hSnapShot := CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if (hSnapShot <> THandle(-1)) then
    begin
      ProcInfo.dwSize := SizeOf(ProcInfo);
      if (Process32First(hSnapshot, ProcInfo)) then
        begin
          List.Add(ProcInfo.szExeFile);
          while (Process32Next(hSnapShot, ProcInfo)) do
            List.Add(ProcInfo.szExeFile);
        end;
      CloseHandle(hSnapShot);
    end;
end;

procedure CreateWinNTProcessList(var List: TStrings);
var
  PIDArray: array [0..1023] of DWORD;
  cb: DWORD;
  i: Integer;
  ProcCount: Integer;
  hMod: HMODULE;
  hProcess: THandle;
  ModuleName: array [0..300] of Char;
begin
  EnumProcesses(@PIDArray, SizeOf(PIDArray), cb);
  ProcCount := cb div SizeOf(DWORD);
  for i := 0 to ProcCount - 1 do
    begin
      hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ,
        False, PIDArray[I]);
      if hProcess <> 0 then
        begin
          EnumProcessModules(hProcess, @hMod, SizeOf(hMod), cb);
          GetModuleFilenameEx(hProcess, hMod, ModuleName, SizeOf(ModuleName));
          List.Add(ModuleName);
          CloseHandle(hProcess);
        end;
    end;
end;

procedure GetProcessList(var List: TStrings);
begin
  if IsWinNT then CreateWinNTProcessList(List) else CreateWin9xProcessList(List);
end;

function EXEIsRunning(AFileName: string; AFullPath: Boolean): Boolean;
var
  i: Integer;
  ProcessList: TStrings;
  S: String;
begin
  Result := False;
  ProcessList := TStringList.Create;
  try
    GetProcessList(ProcessList);
    for i := 0 to ProcessList.Count - 1 do
      begin
        if AFullPath then S := ProcessList[i]
                     else S := ExtractFileName(ProcessList[i]);
        Result := AnsiCompareText(S, AFileName) = 0;
        if Result then Break;
      end;
  finally
    ProcessList.Free;
  end;
end;

end.
