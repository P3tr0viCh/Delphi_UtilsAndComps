unit Utils_Debug;

interface

{$DEBUGINFO OFF}

uses
   Windows, Forms, SysUtils, Utils_FileIni, Utils_Files, Utils_Date;

procedure DebugWriteString(const S: String);

implementation

type
   THandleException = class
   public
      procedure DoException(Sender: TObject; E: Exception);
   end;

var
   DebugFile: TextFile;
   OldOnException: TExceptionEvent;
   HandleException: THandleException;

procedure DebugWriteString(const S: String);
begin
   WriteLn(DebugFile, MyFormatTime(GetDateTime, True) + ' => ' + S);
end;

procedure THandleException.DoException(Sender: TObject; E: Exception);
begin
   DebugWriteString('***  Application Exception: ' + E.Message + ' (Sender: ' + Sender.ClassName + ')');
   If Assigned(OldOnException) then OldOnException(Sender, E)
   else Application.ShowException(Exception(ExceptObject))
end;

initialization
   HandleException:=THandleException.Create;
   OldOnException:=Application.OnException;
   Application.OnException:=HandleException.DoException;
   AssignFile(DebugFile, FileInAppDir(OnlyFileName(Application.ExeName) + ' - Debug.ini'));
   Rewrite(DebugFile);
   DebugWriteString('*****  Start Program  *****');

finalization
   DebugWriteString('*****  Close Program  *****');
   CloseFile(DebugFile);
   HandleException.Free;

end.

