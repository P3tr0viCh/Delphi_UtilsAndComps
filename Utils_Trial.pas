unit Utils_Trial;

interface

uses
   Windows, Forms, Classes, Controls, SysUtils, DateUtils;

{$IFDEF DEBUG}
function CreateTrialFile(AFileName, AInternalName, AVersion: String; ADate: TDate): Boolean;
function ReadFromTrialFile(AFileName: String; var AEXEName, AVersion: String; var ADate: TDate): Boolean;
{$ELSE}
   {$DEBUGINFO OFF}
{$ENDIF}
function KeyExpired: Boolean;

implementation

uses Utils_Files, Utils_Misc, Utils_Str, Utils_Date, Utils_Base64;

const
   BASEKEY = 36429;

function  DToS(ADate: TDate): String;
var
   AYear, AMonth, ADay,
   AHour, AMinute, ASecond, AMilliSecond: Word;
begin
   DecodeDateTime(ADate, AYear, AMonth, ADay, AHour, AMinute, ASecond, AMilliSecond);
   Result:=IToS_0(ADay) + '/' + IToS_0(AMonth) + '/' +  IToS_0(AYear);
end;

function  SToD(ADate: String): TDate;
var
   AYear, AMonth, ADay: String;
begin
   SplitStr(ADate, '/', 0, ADay,    ADate);
   SplitStr(ADate, '/', 0, AMonth,  AYear);
   Result:=EncodeDateTime(SToI(AYear), SToI(AMonth), SToI(ADay), 0, 0, 0, 0);
end;

function GetTrialFileName: String;
begin
   Result:=ChangeFileExt(Application.ExeName, '.key');
end;

{$IFDEF DEBUG}
function CreateTrialFile(AFileName, AInternalName, AVersion: String; ADate: TDate): Boolean;
begin
   Result:=True;
   Try
      With TStringList.Create do
         try
            Add(AInternalName);
            Add(AVersion);
            Add(DToS(ADate));
            Text:=Encrypt(Text, BASEKEY);
            Insert(0, 'Действителен до: ' + FormatDateTime('yyyy"-"mm"-"dd', ADate));
            SaveToFile(ChangeFileExt(AFileName, '.key'));
         finally
            Free;
         end;
   except
      Result:=False;
   end;
end;
{$ENDIF}

function ReadFromTrialFile(AFileName: String; var AEXEName, AVersion: String; var ADate: TDate): Boolean;
begin
   Result:=True;
   Try
      With TStringList.Create do
         try
            LoadFromFile(AFileName);
            Text:=Decrypt(Strings[1], BASEKEY);
            AEXEName:=Strings[0];
            AVersion:=Strings[1];
            ADate:=   SToD(Strings[2]);
         finally
            Free;
         end;
   except
      Result:=False;
   end;
end;

function CheckTrialExpired: Boolean;

   function CheckTrialNameAndVersionExpired(AEXEName, AVersion: String): Boolean;
   var
      FileVersionInfo: TVSFixedFileInfo;
      CompanyName, FileDescription, FileVersion,
      InternalName, LegalCopyright, OriginalFilename,
      ProductName, ProductVersion: String;
   begin
      Result:=GetFileVerInfo(Application.ExeName, FileVersionInfo, CompanyName, FileDescription, FileVersion,
                             InternalName, LegalCopyright, OriginalFilename, ProductName, ProductVersion);
      If Result then Result:=(AEXEName = InternalName) and (AVersion = FileVersion);
   end;

   function CheckTrialDateExpired(ADate: TDate): Boolean;
   begin
      Result:=(ADate - Date) > 0;
   end;

var
   AEXEName, AVersion: String;
   ADate: TDate;
begin
   Result:=ReadFromTrialFile(GetTrialFileName, AEXEName, AVersion, ADate);
   If Result then Result:=CheckTrialNameAndVersionExpired(AEXEName, AVersion);
   If Result then Result:=CheckTrialDateExpired(ADate);
   Result:=not Result;
end;

function KeyExpired: Boolean;
begin
   {$IFNDEF DEBUG}
   Result:=CheckTrialExpired;
   If Result then
      begin
         DeleteFile(GetTrialFileName);
         Application.Terminate;
      end;
   {$ELSE}
   Result:=False;
   {$ENDIF}
end;

end.
