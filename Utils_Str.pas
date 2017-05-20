unit Utils_Str;

//{$DEBUGINFO OFF}

interface

uses
    System.SysUtils, Winapi.Windows, Vcl.Graphics, Vcl.Forms, Winapi.ShellAPI,
    Vcl.Controls, Vcl.Menus, Classes, SysConst, StrUtils, Masks, Types, UITypes;

const
  TAB         = #9;
  DOT         = '.';
  SPACE       = ' ';
  COMMA       = ',';
  COLON       = ':';
  SEMICOLON   = ';';
  EQUAL       = '=';
  QUOTE       = '''';
  DBLQUOTE    = '"';

resourcestring
  rsIncorrectFileName = '/ \ : * ? " < > |';

type
  TByteSet = set of Byte;

function InsertString(const ATo: String; AWhat: String): String;
function ConcatStrings(const S1, S2, Separator: String): String;
function FormatString(const S: String; const DateTime: TSystemTime): String;
function AddLineBreak(const S: String): String;
function FormatBytes(Bytes: Int64): String;
function FormatHerzs(Herzs: Int64): String;
function FormatInteger(I: Integer; F: String): String;

function StringBeginUpper(S: String): String;
function StringAsInSentence(S: String): String;
function StringFirstSignUpper(S: String): String;

function AddQuotes(S: String; Quotes: String = DBLQUOTE; DoReverse: Boolean = False): String;
function DelQuotes(S: String; Quotes: String = DBLQUOTE): String;

function ReplaceS(S, NewPattern: String): String;
function DeleteAllChar(S: String; C: Char): String;
function DoubleHotkeyPrefix(S: String): String;
function EncryptDecrypt(const S: String; Key: Word): String;
procedure EncryptDecryptStrings(var StringList: TStringList; Key: Word);
function Delete0_32Chars(const S: String): String;
function LoadSystemString(FileName: String; Index: Integer): String;
function LoadStringFromComdlg32(Index: Integer): String;
function LoadStringFromShell32(Index: Integer): String;

function  PosPlace(Substr: String; S: String; Place: Integer): Integer;
procedure SplitStr(S: String; const SplitString: String; const SplitPlace: Integer; var FirstHalf, SecondHalf: String);

function  SToI(const S: String): Integer;
function  SToI_Def(const S: String; const Default: Integer = 0): Integer;
function  SToB(const S: String): Byte;
function  IToS(Value: Integer): String;
function  IToS_0(Value: Integer; ZeroCount: Integer = 1): String;

function  SToBool(const S: String; RTrue: String = 'True'; RFalse: String = 'False'): Boolean;
function  BoolToS(Value: Boolean; RTrue: String = 'True'; RFalse: String = 'False'): String;

function  StrToPoint(S: String): TPoint;
function  PointToStr(P: TPoint): String;

function  StrToRect(S: String): TRect;
function  RectToStr(R: TRect): String;

procedure StrToFont(const S: String; Font: TFont);
function  FontToStr(Font: TFont): String;

function  StrToURL(const S: AnsiString): AnsiString;

function  StringToSet(const S: String; StartValue, EndValue: Integer): TByteSet;
function  SetToString(const S: TByteSet): String;

function  WinShortCutToText(ShortCut: TShortCut; IsWinKey: Boolean): String;
function  TextToWinShortCut(Text: String; var IsWinKey: Boolean): TShortCut;
procedure StringsLoadFromResourceName(Strings: TStrings; Instance: THandle; const ResName: String);
function  ReadStringFromStrings(Strings: TStringList; Section, Ident: String): String;

function  ValueToCase(Value: Integer): Byte;

function  ConcatNameAndValue(AName, AValue: String): String;
procedure AddNamesOrValues(ItemsTo, ItemsFrom: TStrings; AddNames: Boolean);
function  GetIndexOfValue(Items: TStrings; AValue: String): Integer;

implementation

uses Utils_Date, Utils_Misc;

function InsertString(const ATo: String; AWhat: String): String;
var
	Position: Integer;
begin
	Result := ATo;
	Position := Pos('%s', Result);
	Insert(AWhat, Result, Position + 2);
	Delete(Result, Position, 2);
end;

function ConcatStrings(const S1, S2, Separator: String): String;
begin
	if (S1 = '') and (S2 = '') then Result := ''
	else
		if S1 = '' then Result := S2
		else
			if S2 = '' then Result := S1
			else
				Result := S1 + Separator + S2;
end;

function FormatString(const S: String; const DateTime: TSystemTime): String;
var
	i: Integer;
	SubStr, TempStr: String;
	TempDate: TDateTime;
	OnlyDays: Boolean;
                                     
	procedure AddToResult(AddS: String; IncValue: Integer = 1);
	begin
		Result := Result + AddS;
		Inc(i, IncValue);
	end;

	procedure CalcDateDiff;
	var
		Days, Months, Years: Integer;
		SysDate: TSystemTime;
	begin
    if OnlyDays then
      SysDate := EncodeSystemDate(0, 0, Abs(Trunc(TempDate - Date)))
    else
      begin
        DateDiff(TempDate, Date, Days, Months, Years);
        SysDate := EncodeSystemDate(Years, Months, Days);
      end;
    SubStr := MyFormatDate(SysDate);
	end;

begin
	Result := '';
	if S = '' then Exit;
	i := 1;
	while i < Length(S) do
		begin
			if S[i] = '%' then
				case S[i + 1] of
				'N', 'n':	AddToResult(sLineBreak);
				'B', 'b':	AddToResult(TAB);
				'U', 'u':	AddToResult(UserName);
				'C', 'c':	AddToResult(ComputerName);
				'T', 't':	AddToResult(SysTimeToStr(DateTime));
				'D', 'd':	AddToResult(SysDateToStr(DateTime, True));
				'S', 's':	AddToResult(SysDateToStr(DateTime, False));
				'F', 'f':	begin
									OnlyDays := S[i + 1] = 'f';
									SplitStr(Copy(S, i + 2, MaxInt), SPACE, 0, SubStr, TempStr);
									Inc(i, Length(SubStr) + 1);
									try
										TempDate := StrToDate(SubStr);
										CalcDateDiff;
									except
										on E: Exception do SubStr := '[' + E.Message + ']';
									end;
									AddToResult(SubStr, 0);
								end;
				else			AddToResult(S[i], 0);
				end
			else				AddToResult(S[i], 0);
			Inc(i);
		end;
	AddToResult(S[i], 0);
end;

function AddLineBreak(const S: String): String;
begin
  Result := StringReplace(S, '/n', sLineBreak, [rfReplaceAll, rfIgnoreCase]);
end;

function FormatBytes(Bytes: Int64): String;
const
  kb = 1024;
  Mb = 1048576;
  Gb = 1073741824;
  Tb = 1099511627776;
  BytesArray: array[0..4] of String = ('б', 'Кб', 'Мб', 'Гб', 'Тб');
var
  i: Byte;
  DivBytes: Extended;
begin
  if (Bytes div Tb) <> 0 then i := 4
  else
    if (Bytes div Gb) <> 0 then i := 3
    else
      if (Bytes div Mb) <> 0 then i := 2
      else
        if (Bytes div kb) <> 0 then i := 1
        else i := 0;
  case i of
  1: DivBytes := Bytes / kb;
  2: DivBytes := Bytes / Mb;
  3: DivBytes := Bytes / Gb;
  4: DivBytes := Bytes / Tb;
  else
    DivBytes := 0;
  end;
  if i = 0 then Result := IToS(Bytes) else Result := FloatToStrF(DivBytes, ffFixed, 18, 1);
  Result := Result + SPACE + BytesArray[i];
end;

function FormatHerzs(Herzs: Int64): String;
const
  kHz = 1000;
  MHz = 1000000;
  GHz = 1000000000;
  THz = 1000000000000;
  HerzsArray: array[0..4] of String = ('Гц', 'КГц', 'МГц', 'ГГц', 'ТГц');
var
  i: Byte;
  DivHerzs: Extended;
begin
  if (Herzs div THz) <> 0 then i := 4
  else
    if (Herzs div GHz) <> 0 then i := 3
    else
      if (Herzs div MHz) <> 0 then i := 2
      else
        if (Herzs div kHz) <> 0 then i := 1
        else i := 0;
  case i of
  1: DivHerzs := Herzs / kHz;
  2: DivHerzs := Herzs / MHz;
  3: DivHerzs := Herzs / GHz;
  4: DivHerzs := Herzs / THz;
  else
    DivHerzs := 0;
  end;
  if i = 0 then Result := IToS(Herzs) else Result := FloatToStrF(DivHerzs, ffFixed, 18, 2);
  Result := Result + SPACE + HerzsArray[i];
end;

function FormatInteger(I: Integer; F: String): String;
var
  S1, S2, Mask, Fmt: String;
begin
  Result := IToS(I);
  try
    SplitStr(F, SEMICOLON, 0, S1, S2);
    while S1 <> '' do
      begin
        SplitStr(S1, COMMA, 0, Mask, Fmt);
        if MatchesMask(ReverseString(Result), ReverseString(Mask)) then
          begin
            Result := Result + Fmt;
            Break;
          end;
        SplitStr(S2, SEMICOLON, 0, S1, S2);
      end;
  except
  end;
end;

function StringBeginUpper(S: String): String;
const
  FirstSigns	= [' ', '('];
var
	i, L: Integer;
begin
  if S = '' then Exit;
  L := Length(S);
  SetLength(Result, L);
  Result[1] := AnsiUpperCase(S[1])[1];
  for i := 2 to L do
    if CharInSet(S[i - 1], FirstSigns) then Result[i] := AnsiUpperCase(S[i])[1]
    else Result[i] := AnsiLowerCase(S[i])[1];
end;

function StringAsInSentence(S: String): String;
var
	i, L: Integer;
begin
  if S = '' then Exit;
  L := Length(S);
  SetLength(Result, L);
  Result[1] := AnsiUpperCase(S[1])[1];
  Result[2] := AnsiLowerCase(S[2])[1];
  for i := 3 to L do
    if (S[i - 1] = ' ') and (S[i - 2] = '.') then
      Result[i] := AnsiUpperCase(S[i])[1]
    else
      Result[i] := AnsiLowerCase(S[i])[1];
end;

function StringFirstSignUpper(S: String): String;
begin
  if S = '' then Exit;
  Result := AnsiLowerCase(S);
  Result[1] := AnsiUpperCase(Result[1])[1];
end;

function AddQuotes(S: String; Quotes: String = DBLQUOTE; DoReverse: Boolean = False): String;
begin
  Result := Quotes + S;
  if DoReverse then Quotes := ReverseString(Quotes);
  Result := Result + Quotes;
end;

function DelQuotes(S: String; Quotes: String = DBLQUOTE): String;
var
  LS, LQ: Integer;
begin
  LS := Length(S);
  LQ := Length(Quotes);
  if LS < (2 * LQ) then Result := S
  else
    begin
      if (Copy(S, 1, LQ) = Quotes) and
         ((Copy(S, LS - LQ + 1, LQ) = ReverseString(Quotes)) or
         (Copy(S, LS - LQ + 1, LQ) = Quotes)) then
        Result := Copy(S, LQ + 1, LS - 2 * LQ)
      else
        Result := S;
    end;
end;

function ReplaceS(S, NewPattern: String): String; // AnsiReplaceText, StringReplace
//		S := 'I am pEtrOvich, PETROVICH-!, PETROVICH?'
//		NewPattern := 'Petrovich'
//		Result => I am Petrovich, PETROVICH-!, Petrovich?
const
	FirstSigns	= [' ', '(', ''''];
	LastSigns	= [' ', '.', ',', '!', '?', ')', '''', ':', ';'];
var
  Offset: Integer;
  DoReplace: Boolean;
  SearchStr, Patt, NewStr: string;
begin
  SearchStr := AnsiUpperCase(S);
  Patt := AnsiUpperCase(NewPattern);
  NewStr := S;
  Result := '';
  while SearchStr <> '' do
    begin
      Offset := AnsiPos(Patt, SearchStr);
      if Offset = 0 then
        begin
          Result := Result + NewStr;
          Break;
        end;

      if Offset > 1 then
        DoReplace := CharInSet(SearchStr[Offset - 1], FirstSigns)
      else
        DoReplace := True;

      if Offset <> (Length(SearchStr) - Length(Patt) + 1) then
        DoReplace := DoReplace and
          CharInSet(SearchStr[Offset + Length(Patt)], LastSigns);

      if DoReplace then
        Result := Result + Copy(NewStr, 1, Offset - 1) + NewPattern
      else
        Result := Result + Copy(NewStr, 1, Offset + Length(Patt) - 1);

      NewStr := Copy(NewStr, Offset + Length(NewPattern), MaxInt);
      SearchStr := Copy(SearchStr, Offset + Length(Patt), MaxInt);
    end;
end;

function DeleteAllChar(S: String; C: Char): String;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(S) do
    if S[i] <> C then
      Result := Result + S[i];
end;

function DoubleHotkeyPrefix(S: String): String;
begin
  Result := StringReplace(S, '&', '&&', [rfReplaceAll]);
end;

function EncryptDecrypt(const S: String; Key: Word): String;
var
	i: Integer;
begin
  Result := S;
  for i := 1 to Length(S) do
    begin
      if (S[i] = ' ') or (S[i] > #32) then
        Result[i] := Char(Byte(S[i]) xor ((Key + i shl 8) shr 8));
    end;
end;

procedure EncryptDecryptStrings(var StringList: TStringList; Key: Word);
var
	i: Integer;
begin
  for i := 0 to StringList.Count - 1 do
    StringList[i] := EncryptDecrypt(StringList[i], Key);
end;

function Delete0_32Chars(const S: String): String;
var
	i: Integer;
begin
  Result := S;
  for i := Length(S) downto 1 do
    if (Result[i] <= #32) and (Result[i] <> ' ') then
      Delete(Result, i, 1);
end;

function LoadSystemString(FileName: String; Index: Integer): String;
var
  DllHandle: HINST;
  P: PChar;
  I: Integer;
begin
  GetMem(P, 1024);
  DllHandle := LoadLibrary(PChar(FileName));
  try
    LoadString(DllHandle, Index, P, 1024);
    Result := String(P);
    I := Pos('%c', Result);
    if I > 0 then Result[I + 1] := 's';
  finally
    FreeLibrary(DllHandle);
    FreeMem(P);
  end;
end;

function LoadStringFromComdlg32(Index: Integer): String;
begin
	Result := LoadSystemString('COMDLG32.DLL', Index);
end;

function LoadStringFromShell32(Index: Integer): String;
begin
	Result := LoadSystemString('SHELL32.DLL', Index);
end;

function SToI(const S: String): Integer;
var
	Code: Integer;
begin
  Val(S, Result, Code);
  if Code <> 0 then
    raise EConvertError.Create('Строка не является целым числом.' + #13#10 +
          'Ошибка в ' + IntToStr(Code) + ' позиции.');
end;

function SToI_Def(const S: String; const Default: Integer = 0): Integer;
begin
  try
    Result := SToI(S);
  except
    Result := Default;
  end;
end;

function SToB(const S: String): Byte;
var
	i: Integer;
begin
  i := SToI(S);
  if i > 255 then Result := 255
  else
    if i < 0 then Result := 0
    else Result := i;
end;

function IToS(Value: Integer): String;
begin
  Result := IntToStr(Value);
end;

function IToS_0(Value: Integer; ZeroCount: Integer = 1): String;
begin
	Result := IToS(Value);
	while Length(Result) < ZeroCount + 1 do Result := '0' + Result;
end;

function BoolToS(Value: Boolean; RTrue: String = 'True'; RFalse: String = 'False'): String;
begin
	if Value then Result := RTrue else Result := RFalse;
end;

function SToBool(const S: String; RTrue: String = 'True'; RFalse: String = 'False'): Boolean;
begin
	if AnsiSameText(S, RTrue) then Result := True
	else
		if AnsiSameText(S, RFalse) then Result := False
		else
{$IFDEF VER150}
			raise EConvertError.CreateResFmt(@SInvalidBoolean, [S]);
{$ELSE}
			Result := False;
{$ENDIF}
end;

function PosPlace(Substr: String; S: String; Place: Integer): Integer;
var
	i, P: Integer;
begin
	Result := 0;
	if S = '' then Exit;
	if Substr = '' then Exit;
	for i := 0 to Place do
		begin
			P := Pos(Substr, S);
			if P = 0 then Break;
			Delete(S, 1, P);
			Result := Result + P;
		end;
end;

procedure SplitStr(S: String; const SplitString: String; const SplitPlace: Integer; var FirstHalf, SecondHalf: String);
var
	P: Integer;
begin
	FirstHalf := S; SecondHalf := '';
	if S = '' then Exit;
	P := PosPlace(SplitString, S, SplitPlace);
	if P <> 0 then
		begin
			FirstHalf := Copy(S, 1, P - 1);
			SecondHalf := Copy(S, P + Length(SplitString), MaxInt);
		end;
end;

function StrToPoint(S: String): TPoint;
var
	FirstHalf, SecondHalf: String;
begin
	Result := Point(0, 0);
	if S = '' then Exit;
	try
		SplitStr(S, COMMA, 0, FirstHalf, SecondHalf);
		Result.x := StrToInt(FirstHalf);
		Result.y := StrToInt(SecondHalf);
	except
		raise Exception.Create('Строка ''' + S + ''' не является записью TPoint');
	end;
end;

function PointToStr(P: TPoint): String;
begin
	with P do Result := IToS(x) + COMMA + IToS(y);
end;

function StrToRect(S: String): TRect;
var
	FirstHalf, SecondHalf: String;
begin
	Result := Rect(0, 0, 0, 0);
	if S = '' then Exit;
	try
		SplitStr(S, COMMA, 0, FirstHalf, SecondHalf);
		Result.Left := StrToInt(FirstHalf);
		SplitStr(SecondHalf, COMMA, 0, FirstHalf, SecondHalf);
		Result.Top := StrToInt(FirstHalf);
		SplitStr(SecondHalf, COMMA, 0, FirstHalf, SecondHalf);
		Result.Right := StrToInt(FirstHalf);
		Result.Bottom := StrToInt(SecondHalf);
	except
		raise Exception.Create('Строка ''' + S + ''' не является записью TRect');
	end;
end;

function RectToStr(R: TRect): String;
begin
	with R do Result := IToS(Left) + COMMA + IToS(Top) + COMMA + IToS(Right) + COMMA + IToS(Bottom);
end;

procedure StrToFont(const S: String; Font: TFont);
var
	intFontStyle: Byte;
	FontStyle: TFontStyles;
	FirstHalf, SecondHalf: String;
begin
	if S = '' then Exit;
	with Font do
		try
			SplitStr(S, COMMA, 0, FirstHalf, SecondHalf);
			Name := FirstHalf;
			SplitStr(SecondHalf, COMMA, 0, FirstHalf, SecondHalf);
			CharSet := StrToInt(FirstHalf);
			SplitStr(SecondHalf, COMMA, 0, FirstHalf, SecondHalf);
			Color := StrToInt(FirstHalf);
			SplitStr(SecondHalf, COMMA, 0, FirstHalf, SecondHalf);
			Size := StrToInt(FirstHalf);
			intFontStyle := StrToInt(SecondHalf);
			Move(intFontStyle, FontStyle, 1);
			Style := FontStyle;
		except
			raise Exception.Create('Строка ''' + S + ''' не является записью TFont');
		end;
end;

function FontToStr(Font: TFont): String;
var
  intFontStyle: Byte;
  FontStyle: TFontStyles;
begin
  with Font do begin
    FontStyle := Style;
    Move(FontStyle, intFontStyle, 1);
    Result := Name + COMMA + IToS(Charset) + COMMA + IToS(Color) + COMMA + IToS(Size) + COMMA + IToS(intFontStyle);
  end;
end;

function StrToURL(const S: AnsiString): AnsiString;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(S) do
    if CharInSet(S[i], ['0'..'9', 'A'..'Z', 'a'..'z']) then Result := Result + S[i]
    else Result := Result + '%' + AnsiString(IntToHex(Ord(S[i]), 2));
end;

function WinShortCutToText(ShortCut: TShortCut; IsWinKey: Boolean): String;
begin
  Result := ShortCutToText(ShortCut);
  if (Result <> '') and IsWinKey then Result := 'Win+' + Result;
end;

function TextToWinShortCut(Text: String; var IsWinKey: Boolean): TShortCut;
begin
  IsWinKey := Pos('Win+', Text) <> 0;
  if IsWinKey then Delete(Text, 1, 4);
  Result := TextToShortCut(Text);
end;

procedure StringsLoadFromResourceName(Strings: TStrings; Instance: THandle; const ResName: String);
var
	Stream: TCustomMemoryStream;
begin
	Stream := TResourceStream.Create(Instance, ResName, PChar('TEXT'));
	try
		Strings.LoadFromStream(Stream);
	finally
		Stream.Free;
	end;
end;

function ReadStringFromStrings(Strings: TStringList; Section, Ident: String): String;
var
	S: String;
	SectionIndex, Index, P: Integer;
begin
	Result := '';
	SectionIndex := Strings.IndexOf('[' + Section + ']');
	if SectionIndex = -1 then Exit;
	for Index := SectionIndex to Strings.Count - 1 do
		begin
			S := Strings[Index];
			P := AnsiPos('=', S);
			if (P <> 0) and (AnsiCompareText(Copy(S, 1, P - 1), Ident) = 0) then
				begin
					Result := Copy(S, P + 1, MaxInt);
					Break;
				end;
		end;
end;

function ValueToCase(Value: Integer): Byte;
begin
	Value := Abs(Value);
	if Value in [11..14] then Result := 2
	else
		case Value mod 10 of
		1:			  Result := 0;
		2, 3, 4:	Result := 1;
		else 		  Result := 2;
		end;
end;

function StringToSet(const S: String; StartValue, EndValue: Integer): TByteSet;
var
	S1, S2: String;
	Value: Integer;
begin
	Result := [];
	if S = '' then Exit;
	S2 := S;
	repeat
		SplitStr(S2, ',', 0, S1, S2);
		try
			Value := SToI(S1);
			if Value in [StartValue..EndValue] then Include(Result, Value);
		except
			Result := [];
			Exit;
		end;
	until S2 = '';
end;

function SetToString(const S: TByteSet): String;
var
	Value: Byte;
begin
	Result := '';
	if S = [] then Exit;
	for Value := Low(Byte) to High(Byte) do
		if Value in S then
			Result := ConcatStrings(Result, IToS(Value), COMMA);
end;

function ConcatNameAndValue(AName, AValue: String): String;
begin
  Result := AName + '=' + AValue;
end;

procedure AddNamesOrValues(ItemsTo, ItemsFrom: TStrings; AddNames: Boolean);
var
  i: Integer;
begin
  ItemsTo.Clear;
  for i := 0 to ItemsFrom.Count - 1 do
    if AddNames then
      ItemsTo.Add(ItemsFrom.Names[i])
    else
      ItemsTo.Add(ItemsFrom.ValueFromIndex[i]);
end;

function GetIndexOfValue(Items: TStrings; AValue: String): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Items.Count - 1 do
    if Items.ValueFromIndex[i] = AValue then
      begin
        Result := i;
        Break;
      end;
end;

end.

