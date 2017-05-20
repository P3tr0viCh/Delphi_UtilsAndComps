unit Utils_Log;

interface

uses
  Winapi.Windows, System.SysUtils, System.StrUtils, Vcl.Forms, Utils_Files;

resourcestring
  rsDateTimeFormatLog      = 'yyyy"-"mm"-"dd" "hh":"nn":"ss';
  rsDateTimeFormatFileName = 'yyyy"-"mm"-"dd" "hh"-"nn"-"ss';
  rsLogExt = '.log';
  rsLogPath = 'log';

const
  SPACE = ' ';
  MaxLogSize = 1024 * 1024;
  INVALID_SET_FILE_POINTER = DWORD(-1);

procedure WriteToLog(S: String);
procedure WriteToLogForm(AShow: Boolean; AFormName: String);

implementation

procedure WriteToLog(S: String);
var
  LogFile: THandle;
  LogPath, LogFileName: String;
  dwSize: DWORD;
  Buffer: array[1..1024] of AnsiChar;
  NU: Cardinal;
  I: Integer;
  SS: AnsiString;
  DateTime: TDateTime;
begin
  try // except
    DateTime := Now;
    LogPath := ExtractFilePath(Application.ExeName) + rsLogPath;
    if not DirectoryExists(LogPath) then CreateDir(LogPath);
    
    LogFileName := SlashSep(LogPath, 
      ChangeFileExt(ExtractFileName(Application.ExeName), rsLogExt));

    LogFile := CreateFile(PChar(LogFileName),
      GENERIC_READ, FILE_SHARE_READ, nil, OPEN_ALWAYS,
      FILE_ATTRIBUTE_NORMAL, 0);

    dwSize := 0;
    if LogFile <> INVALID_HANDLE_VALUE then
      try
        dwSize := GetFileSize(LogFile, nil);
      finally
        CloseHandle(LogFile);
      end;

    if dwSize > MaxLogSize then
      MoveFile(PChar(LogFileName), 
        PChar(SlashSep(LogPath, OnlyFileName(Application.ExeName) + SPACE + 
          FormatDateTime(rsDateTimeFormatFileName, DateTime) + rsLogExt)));

    LogFile := CreateFile(PChar(LogFileName),
      GENERIC_WRITE, FILE_SHARE_READ, nil, OPEN_ALWAYS,
      FILE_ATTRIBUTE_NORMAL or FILE_ATTRIBUTE_COMPRESSED, 0);
      
    if LogFile <> INVALID_HANDLE_VALUE then
      try
        SS := AnsiString(FormatDateTime(rsDateTimeFormatLog, DateTime) + '; ' +
          ReplaceStr(S, sLineBreak, SPACE) +  sLineBreak);

        for I := 1 to Length(SS) do Buffer[I] := SS[I];
                                            
        if SetFilePointer(LogFile, 0, nil, FILE_END) <> INVALID_SET_FILE_POINTER then
          WriteFile(LogFile, Buffer, Length(SS), NU, nil);
      finally
        CloseHandle(LogFile);
      end;
  except
  end;
end;

procedure WriteToLogForm(AShow: Boolean; AFormName: String);
// show (close): Имя формы
begin
  AFormName := ': ' + AFormName;
  if AShow then AFormName := 'show'  + AFormName
           else AFormName := 'close' + AFormName;
  WriteToLog(AFormName);
end;

end.
