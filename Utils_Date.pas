unit Utils_Date;

{$DEBUGINFO OFF}

interface

uses Winapi.Windows, SysUtils, Classes, System.Win.Registry, Winapi.RegStr, DateUtils;

const
  Hour    = 1 / 24;
  Minute  = 1 / (24 * 60);
  Second  = 1 / SecsPerDay;

function ReturnSecondStay(TimeAlarm, TimeNow: TDateTime): LongWord;
function ReturnTimeStay(TimeAlarm, TimeNow: TDateTime): String;
function ExtractHMSFromMS(const MilliSeconds: Int64): TSystemTime;
function GetDateTime: TSystemTime;
function SysDateToStr(const SystemTime: TSystemTime;
  const LongDate: Boolean = True): String;
function SysTimeToStr(const SystemTime: TSystemTime;
  const NoSeconds: Boolean = True): String;

function DOfWeek(SystemDate: TSystemTime): Byte;
function FirstDOfWeek(SystemDate: TSystemTime): Byte;
function DayOfYear(SystemDate: TSystemTime): Word;
function DayOfYearInDate(ADayOfYear, AYear: Word): TSystemTime;
procedure DateDiff(Date1, Date2: TDateTime; var Days, Months, Years: Integer);

function STimeToDT(const SystemTime: TSystemTime): TDateTime;
function SDateToDT(const SystemTime: TSystemTime): TDateTime;
function STToDT(const SystemTime: TSystemTime): TDateTime;
function DTToST(DateTime: TDateTime): TSystemTime;
function DTToMSec(DateTime: TDateTime): LongWord;

function MyFormatTime(const SystemTime: TSystemTime; WithMSec: Boolean = False): String;
function MyFormatDate(const SystemTime: TSystemTime): String;
function FormatDate(const Format: String; const SystemTime: TSystemTime): String;
function FormatTime(const Format: String; const SystemTime: TSystemTime): String;
function EncodeSystemDate(const Year, Month, Day: Word): TSystemTime;
function GetTimeZoneDisplayName: String;

function EasterOrthodox(Year: Integer): TSystemTime;
function EasterCatholic(Year: Integer): TSystemTime;

implementation

uses Utils_Misc, Utils_Str;

function ReturnSecondStay(TimeAlarm, TimeNow: TDateTime): LongWord;
var
  vHour, vMin, vSec, vMSec: Word;
begin
  if TimeAlarm > TimeNow then TimeAlarm := TimeAlarm - TimeNow
                         else TimeAlarm := 1 - (TimeNow - TimeAlarm);
  DecodeTime(TimeAlarm, vHour, vMin, vSec, vMSec);
  Result := vHour * 3600 + vMin * 60 +vSec;
end;

function ReturnTimeStay(TimeAlarm, TimeNow: TDateTime): String;
var
  vHour, vMin, vSec, vMSec: Word;
begin
  if TimeAlarm > TimeNow then TimeAlarm := TimeAlarm - TimeNow
                         else TimeAlarm := 1 - (TimeNow - TimeAlarm);
  DecodeTime(TimeAlarm, vHour, vMin, vSec, vMSec);
  Result := IToS_0(vHour) + ':' + IToS_0(vMin) + ':' + IToS_0(vSec + 1);
end;

function ExtractHMSFromMS(const MilliSeconds: Int64): TSystemTime;
const
  MSInDay  = 86400000;
  MSInHour = 3600000;
  MSInMin  = 60000;
  MSInSec  = 1000;
var
  MS: Int64;
begin
  MS := MilliSeconds;
  with Result do
    begin
      wDay := MS div MSInDay;
      MS := MS - (wDay * MSInDay);
      wHour := MS div MSInHour;
      MS := MS - (wHour * MSInHour);
      wMinute := MS div MSInMin;
      MS := MS - (wMinute * MSInMin);
      wSecond := MS div MSInSec;
      wMilliseconds := MS - (wSecond * MSInSec);
    end;
end;
                                        
function GetDateTime: TSystemTime;
begin
  GetLocalTime(Result);
end;

function FormatDate(const Format: String; const SystemTime: TSystemTime): String;
var
  P: PChar;
  Flags: Integer;
  Buffer: array[0..255] of Char;
begin
  if Format = '' then begin P := nil; Flags := DATE_LONGDATE; end
                 else begin P := PChar(Format); Flags := 0; end;
  SetString(Result, Buffer, GetDateFormat(LOCALE_USER_DEFAULT,
    Flags, @SystemTime, P, Buffer, SizeOf(Buffer)) - 1);
end;

function FormatTime(const Format: String; const SystemTime: TSystemTime): String;
var
  P: PChar;
  Flags: Integer;
  Buffer: array[0..255] of Char;
begin
  Flags := 0;
  if Format = '' then P := nil else P := PChar(Format);
  SetString(Result, Buffer, GetTimeFormat(LOCALE_USER_DEFAULT,
    Flags, @SystemTime, P, Buffer, SizeOf(Buffer)) - 1);
end;

function SysDateToStr(const SystemTime: TSystemTime;
  const LongDate: Boolean = True): String;
const
  Formats: array[Boolean] of Integer = (DATE_SHORTDATE, DATE_LONGDATE);
var
  Buffer: array[0..255] of Char;
begin
  SetString(Result, Buffer, GetDateFormat(LOCALE_USER_DEFAULT,
    Formats[LongDate], @SystemTime, nil, Buffer, SizeOf(Buffer)) - 1);
end;

function SysTimeToStr(const SystemTime: TSystemTime;
  const NoSeconds: Boolean = True): String;
const
  Formats: array[Boolean] of Integer = (0, TIME_NOSECONDS);
var
  Buffer: array[0..255] of Char;
begin
  SetString(Result, Buffer, GetTimeFormat(LOCALE_USER_DEFAULT,
    Formats[NoSeconds], @SystemTime, nil, Buffer, SizeOf(Buffer)) - 1);
end;

function DOfWeek(SystemDate: TSystemTime): Byte;
// 1 - понедельник ...
begin
  Result := DayOfWeek(SystemTimeToDateTime(SystemDate));
  if Result = 1 then Result := 7 else Dec(Result);
end;

function FirstDOfWeek(SystemDate: TSystemTime): Byte;
begin
  SystemDate.wDay := 1;
  Result := DOfWeek(SystemDate);
end;

function DayOfYear(SystemDate: TSystemTime): Word;
var
  i: Byte;
begin
  Result := 0;
  with SystemDate do
    begin
      for i := 1 to wMonth - 1 do
        Inc(Result, DaysInAMonth(wYear, i));
      Inc(Result, wDay);
    end;
end;

function DayOfYearInDate(ADayOfYear, AYear: Word): TSystemTime;
begin
  Result := DTToST(EncodeDateDay(AYear, ADayOfYear));
end;

function STimeToDT(const SystemTime: TSystemTime): TDateTime;
begin
  with SystemTime do Result := EncodeTime(wHour, wMinute, wSecond, wMilliSeconds);
end;

function SDateToDT(const SystemTime: TSystemTime): TDateTime;
begin
  with SystemTime do Result := EncodeDate(wYear, wMonth, wDay);
end;

function STToDT(const SystemTime: TSystemTime): TDateTime;
begin
  with SystemTime do
    Result := EncodeDateTime(wYear, wMonth, wDay, wHour, wMinute, wSecond, wMilliseconds);
end;

function DTToST(DateTime: TDateTime): TSystemTime;
begin
  DateTimeToSystemTime(DateTime, Result);
end;

function DTToMSec(DateTime: TDateTime): LongWord;
begin                              
  Result := Round(MSecsPerDay * Abs(DateTime));
end;

function MyFormatTime(const SystemTime: TSystemTime; WithMSec: Boolean = False): String;
begin
  Result := '';
  with SystemTime do
    begin
//			if wHour > 0 then Result := IToS_0(wHour) + ':';
      Result := IToS_0(wHour) + ':' + IToS_0(wMinute) + ':' + IToS_0(wSecond);
      if WithMSec then Result := Result + '.' + IToS_0(wMilliseconds, 2);
  end;
end;

function MyFormatDate(const SystemTime: TSystemTime): String;
const
  StringArray: array[0..2, 0..2] of String =
    (('год', 'года', 'лет'), ('месяц', 'месяца', 'месяцев'), ('день', 'дня', 'дней'));
  SeparatorArray: array[Boolean] of String = (', ', ' и ');
begin
  Result := '';
  with SystemTime do
    begin
      if wYear <> 0 then
      Result := ConcatStrings('', IToS(wYear) + ' ' +
        StringArray[0, ValueToCase(wYear)], '');
      if wMonth <> 0 then
        Result := ConcatStrings(Result, IToS(wMonth)+ ' ' +
          StringArray[1, ValueToCase(wMonth)], SeparatorArray[wDay = 0]);
      if wDay <> 0 then
        Result := ConcatStrings(Result, IToS(wDay)	+ ' ' +
          StringArray[2, ValueToCase(wDay)], SeparatorArray[True]);
    end;
end;

function EncodeSystemDate(const Year, Month, Day: Word): TSystemTime;
begin
  with Result do
    begin
      wYear := Year;
      wMonth := Month;
      wDay := Day;
    end;
end;

function GetTimeZoneDisplayName: String;
var
  REGSTR_TIME_ZONES: String;
var
  TimeZones: TStringList;
  i: Integer;
begin
  Result := 'Unknown';
  with TRegistry.Create(KEY_READ) do
    try
      RootKey := HKEY_LOCAL_MACHINE;
      if not OpenKeyReadOnly(REGSTR_PATH_CURRENT_CONTROL_SET +
        '\TimeZoneInformation') then Exit;

      Result := ReadString('DaylightName');
      CloseKey;
      REGSTR_TIME_ZONES := 'Software\Microsoft\Windows';
      if IsWinNT then REGSTR_TIME_ZONES := REGSTR_TIME_ZONES + ' NT';
      REGSTR_TIME_ZONES := REGSTR_TIME_ZONES + '\CurrentVersion\Time Zones';
      if not OpenKeyReadOnly(REGSTR_TIME_ZONES) then Exit;

      TimeZones := TStringList.Create;
      try
        GetKeyNames(TimeZones);
        for i := 0 to TimeZones.Count - 1 do
          begin
            CloseKey;
            if OpenKeyReadOnly(REGSTR_TIME_ZONES + '\' + TimeZones[i]) then
              begin
                if ReadString('Dlt') = Result then
                  begin
                    Result := ReadString('Display');
                    Break;
                  end;
              end;
          end;
      finally
        TimeZones.Free;
      end;
    finally
      Free;
    end;
end;

function EasterOrthodox(Year: Integer): TSystemTime;
// (Ж.Меес, "Астрономические формулы для калькуляторов", М., "Мир", 1988,
// ссылка взята из [1])
const
  JulianToGregorian: array[Boolean] of Byte = (13, 14 {с 1 марта 2100 года});
var
  A, B, C, D, E, Z: Word;
begin
  A := Year mod 4;
  B := Year mod 7;
  C := Year mod 19;
  D := (19 * C + 15) mod 30;
  E := (2 * A + 4 * B - D + 34) mod 7;
  Z := D + E;
  if Year > 1917 then Inc(Z, JulianToGregorian[Year > 2099]);
  with Result do
    begin
      wYear := Year;
      wMonth := 3 + (Z + 21) div 31;
      wDay := (Z + 21) mod 31 + 1;
    end;
end;

function EasterCatholic(Year: Integer): TSystemTime;
// (Алгоритм Oudin (1940) взят из "Explanatory Supplement to the
// Astronomical Almanac")
var
  Century, G, K, I, J, L: Word;
begin
  Century := Year div 100;
  G := Year mod 19;
  K := (Century - 17) div 25;
  I := (Century - Century div 4 - (Century - K) div 3 + 19 * G + 15) mod 30;
  I := I - (I div 28) * (1 - (I div 28) * (29 div (I + 1)) * ((21 - G) div 11));
  J := (Year + Year div 4 + I + 2 - Century + Century div 4) mod 7;
  L := I - J;
  with Result do
    begin
      wYear := Year;
      wMonth := 3 + (L + 40) div 44;
      wDay := L + 28 - 31 * (wMonth div 4);
    end;
end;

procedure DateDiff(Date1, Date2: TDateTime; var Days, Months, Years: Integer);
var
  TempDate: TDateTime;
  Day1, Day2, Month1, Month2, Year1, Year2: Word;
begin
  if Date1 > Date2 then
    begin
      TempDate := Date1; Date1 := Date2; Date2 := TempDate;
    end;
  DecodeDate(Date1, Year1, Month1, Day1);
  DecodeDate(Date2, Year2, Month2, Day2);
  if Day2 < Day1 then
    begin
      Dec(Month2);
      if Month2 = 0 then
        begin
          Month2 := 12;
          Dec(Year2);
        end;
      Inc(Day2, DaysInAMonth(Year2, Month2));
    end;
  Days := Day2 - Day1;
  if Month2 < Month1 then
    begin
      Inc(Month2, 12);
      Dec(Year2);
    end;
  Months := Month2 - Month1;
  Years := Year2 - Year1;
end;

end.

