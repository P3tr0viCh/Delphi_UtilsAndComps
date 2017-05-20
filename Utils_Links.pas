unit Utils_Links;

interface

{$DEBUGINFO OFF}
{$WARNINGS OFF}

uses
	Windows, ShellAPI, SysUtils, ActiveX, ShlObj, Classes, ComObj, Forms;

resourcestring
   rsOKCreateLink    = 'Ярлыки для программы созданы';
   rsErrorCreateLink = 'Произошла ошибка при сохранении ярлыков для программы.' + sLineBreak +
                       'Возможно, у вас отсутствуют необходимые права';

function CreateLink(const LinkFileName, FileName: String;
                     Arguments   : String = '';
                     Description : String = '';
                     IconLocation: String = '';
                     IconIndex   : Integer = 0;
                     WorkingDir  : String = '';
                     HotKey      : Word = 0;
                     ShowCmd     : Integer = 0): Boolean;

function ReadLink(const LinkFileName: String;
                  var FileName, WorkingDir, Arguments: String;
                  var HotKey      : Word;
                  var ShowCmd     : Integer;
                  var IconLocation: String;
                  var IconIndex   : Integer;
                  var Description : String): Boolean;

function CreateLinkToSelf(FolderName: String = ''): Boolean;
function ReadFileNameFromLink(const LinkFileName: String; WithArguments: Boolean = True): String;

function DefaultStartFolder: String;
function IsLink(const FileName: String): Boolean;

implementation

uses Utils_Misc, Utils_Files;

function CreateLink;
var
	MyObject : IUnknown;
	MySLink  : IShellLink;
	MyPFile  : IPersistFile;
	WFileName: WideString;
begin
	MyObject:=CreateComObject(CLSID_ShellLink);
	MySLink:=MyObject as IShellLink;
	MyPFile:=MyObject as IPersistFile;
   If WorkingDir   = '' then WorkingDir:=ExtractFilePath(FileName);
   If Description  = '' then Description:=GetFileDescription(FileName);
   If IconLocation = '' then IconLocation:=FileName;
	With MySLink do
		begin
			SetPath(PChar(FileName));
			SetWorkingDirectory(PChar(WorkingDir));
			SetArguments(PChar(Arguments));
			SetHotkey(HotKey);
			SetShowCmd(ShowCmd);
			SetIconLocation(PChar(IconLocation), IconIndex);
			SetDescription(PChar(Description));
		end;
   If IsLink(LinkFileName) then WFileName:=LinkFileName
                           else WFileName:=LinkFileName + '.lnk';
	Result:=MyPFile.Save(PWChar(WFileName), False) = S_OK;
end;

function ReadLink;
var
	MyObject : IUnknown;
	MySLink  : IShellLink;
	MyPFile  : IPersistFile;
	WFileName: WideString;
	Buffer   : PChar;
	pfd      : TWin32FindData;
begin
	MyObject:=CreateComObject(CLSID_ShellLink);
	MySLink:=MyObject as IShellLink;
	MyPFile:=MyObject as IPersistFile;
	WFileName:=LinkFileName;
	Result:=MyPFile.Load(PWChar(WFileName), STGM_READ) = S_OK;
	If not Result then Exit;
	Buffer:=AllocMem(MAX_PATH);
	Try
		With MySLink do
			begin
				GetPath(Buffer, MAX_PATH, pfd, 0);
				FileName:=String(Buffer);
				FillChar(Buffer^, MAX_PATH, 0);
				GetArguments(Buffer, MAX_PATH);
				Arguments:=String(Buffer);
				FillChar(Buffer^, MAX_PATH, 0);
				GetHotkey(HotKey);
				GetShowCmd(ShowCmd);
				GetIconLocation(Buffer, MAX_PATH, IconIndex);
				IconLocation:=String(Buffer);
				FillChar(Buffer^, MAX_PATH, 0);
				GetWorkingDirectory(Buffer, MAX_PATH);
				WorkingDir:=String(Buffer);
				FillChar(Buffer^, MAX_PATH, 0);
				GetDescription(Buffer, MAX_PATH);
				Description:=String(Buffer);
			end;
	finally
		FreeMem(Buffer);
	end;
end;

function CreateLinkToSelf(FolderName: String = ''): Boolean;
begin
   If FolderName = '' then FolderName:=DefaultStartFolder
   else
      if FolderName[1] = '+' then
         FolderName:=SlashSep(DefaultStartFolder, Copy(FolderName, 2, MAXINT));
   Result:=CreateDirectories(FolderName);
   If Result then Result:=CreateLink(SlashSep(FolderName, Application.Title), Application.ExeName);
end;

function ReadFileNameFromLink(const LinkFileName: String; WithArguments: Boolean = True): String;
var
   FileName, WorkingDir, Arguments: String;
   HotKey      : Word;
   ShowCmd     : Integer;
   IconLocation: String;
   IconIndex   : Integer;
   Description : String;
begin
   If ReadLink(LinkFileName, FileName, WorkingDir, Arguments, HotKey, ShowCmd,
      IconLocation, IconIndex, Description) then
      begin
         Result:=FileName;
         If WithArguments then Result:=Result + ' ' + Arguments;
      end
   else
      Result:='';
end;

function DefaultStartFolder: String;
begin
   If IsWinNT then Result:=GetSpecialFolderPath(CSIDL_COMMON_PROGRAMS)
              else Result:=GetSpecialFolderPath(CSIDL_PROGRAMS);
   Result:=SlashSep(Result, 'П3тр0виЧъ');
end;

function IsLink(const FileName: String): Boolean;
begin
   Result:=AnsiLowerCase(ExtractFileExt(FileName)) = '.lnk';
end;

{$WARNINGS ON}

end.
