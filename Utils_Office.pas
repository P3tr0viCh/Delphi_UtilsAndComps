unit Utils_Office; // TODO: OnPercent Max Count

interface

uses Windows, Forms, SysUtils, Controls, ComCtrls, Variants, OleServer, Utils_Str, Utils_Misc,
   Utils_KAndM, Utils_Date, WordXP, ExcelXP, DateUtils;

{$DEBUGINFO OFF}

function  ExcelColIntToChar(Value: Integer): String;
function  ExcelRowColToStr(Row, Col: Integer): String;
function  ExcelGetRange(ExcelWorksheet: TExcelWorksheet; Row1, Col1: Integer; Row2: Integer = -1; Col2: Integer = -1): ExcelRange;
procedure ExcelWrite(ExcelWorksheet: TExcelWorksheet; Row, Col: Integer; Value: String);
procedure ExcelPageSetupMargin(ExcelApplication: TExcelApplication; ExcelWorksheet: TExcelWorksheet;
   ALeft, ARight, ATop, ABottom: Double);

function CalendarOnMonthInWord(Year: Word; Month: Byte; AddMonth, AddWeek: Boolean;
	OnPercent: TOnPercentNotify = nil; OnStop: TOnStopNotify = nil;
	WordApplication: TWordApplication = nil; WordDocument: TWordDocument = nil): Boolean;

implementation

function ExcelColIntToChar(Value: Integer): String;
var
   I: Integer;
begin
   I := Trunc(Value / 26);
   if Value > 26 then Result := Chr(I + 64) + Chr(Value - (I * 26) + 64)
                 else Result := Chr(Value + 64);
end;

function ExcelRowColToStr(Row, Col: Integer): String;
begin
   Result := ExcelColIntToChar(Col) + IToS(Row);
end;

function ExcelGetRange(ExcelWorksheet: TExcelWorksheet; Row1, Col1: Integer; Row2: Integer = -1; Col2: Integer = -1): ExcelRange;
var
   Cell1, Cell2: String;
begin
   Cell1 := ExcelRowColToStr(Row1, Col1);
   if (Row2 = -1) or (Col2 = -1) then
      Cell2 := Cell1
   else
      Cell2 := ExcelRowColToStr(Row2, Col2);
   Result := ExcelWorksheet.Range[Cell1, Cell2];
end;

procedure ExcelWrite(ExcelWorksheet: TExcelWorksheet; Row, Col: Integer; Value: String);
begin
   ExcelGetRange(ExcelWorksheet, Row, Col).Formula := Value;
end;

procedure ExcelPageSetupMargin(ExcelApplication: TExcelApplication; ExcelWorksheet: TExcelWorksheet;
   ALeft, ARight, ATop, ABottom: Double);
begin
   with ExcelWorksheet.PageSetup, ExcelApplication do
      begin
         LeftMargin := CentimetersToPoints(ALeft);
         RightMargin := CentimetersToPoints(ARight);
         TopMargin := CentimetersToPoints(ATop);
         BottomMargin := CentimetersToPoints(ABottom);
      end;
end;

function CalendarOnMonthInWord;
const
	FontName		= 'Courier New';
	ITrue			= Integer(True);
	IFalse		= Integer(False);
	FontItalic	= ITrue;
	CBorders:	array[0..3] of LongWord = (wdBorderTop, wdBorderLeft, wdBorderBottom, wdBorderRight);
	MaxAction:	array[Boolean, Boolean] of Integer = ((63, 70), (67, 75));
var
   ADate: TDate;
	MonthOffset, Action,
	Col, AddCol, Row, AddRow, i: Integer;
	XVar1, XVar2, XVar3: OleVariant;
	MainResult,
	WA, WD: Boolean;

	function DoStep: Boolean;
	begin
		Result := False;
		if Assigned(OnPercent) then OnPercent(Percent(Action, MaxAction[AddMonth, AddWeek]));
		Inc(Action);
		ProcMess;
		if Assigned(OnStop) then OnStop(Result) else Result := IsKey(VK_ESCAPE);
		MainResult := not Result;
		if Result then
			begin
				XVar1 := wdDoNotSaveChanges;
				if WD then WordDocument.Close(XVar1);
{				if WordApplication.Documents.Count = 0 then
					begin
						if WA then WordApplication.Quit(XVar1);
					end
				else}
					WordApplication.Visible := True;
			end;
	end;
begin
	Result := True;
	Action := 1;
	WA := WordApplication	= nil;
	WD := WordDocument		= nil;
	if WA then WordApplication := TWordApplication.Create(Application);
	if WD then WordDocument := TWordDocument.Create(Application);
	try
   try
		WordApplication.Visible := False;
		if AddMonth	then AddRow := 1 else AddRow := 0;
		if AddWeek	then AddCol := 1 else AddCol := 0;
		with WordApplication, WordDocument do
			begin
				with Range do
					begin
						InsertAfter(StringToOleStr(
							FormatDate('Календарь на MMMM yyyy года', EncodeSystemDate(Year, Month, 1))));
						InsertParagraphAfter;
						if DoStep then Exit;
						XVar1 := Start;
						XVar2 := End_ - 1;
						with Range(XVar1, XVar2) do
							begin
								ParagraphFormat.FirstLineIndent := CentimetersToPoints(0);
								ParagraphFormat.Alignment := wdAlignParagraphCenter;
								if DoStep then Exit;
								Font.Name := FontName;
								Bold := ITrue;
								Underline := wdUnderlineSingle;
								Italic := FontItalic;
								if DoStep then Exit;
							end;
						InsertParagraphAfter;
					end; // with Range
				XVar1 := wdStory;
				Selection.EndKey(XVar1, EmptyParam);
				if DoStep then Exit;
				with Tables.Add(Selection.Range, 7 + AddRow, 7 + AddCol, EmptyParam, EmptyParam) do
					begin
						Range.Font.Name := FontName;
						Range.Italic := FontItalic;
						if DoStep then Exit;
						TopPadding := CentimetersToPoints(0.05);
						BottomPadding := TopPadding;
						if DoStep then Exit;
						LeftPadding := CentimetersToPoints(0.15);
						RightPadding := LeftPadding;
						if DoStep then Exit;
						AllowPageBreaks := True;
						XVar1 := wdAutoFitContent;
						AutoFitBehavior(XVar1);
						AllowAutoFit := True;
						if DoStep then Exit;
						with Rows do
							begin
								AllowBreakAcrossPages := Integer(False);
								Alignment := wdAlignRowCenter;
								WrapAroundText := Integer(True);
							end;
						if DoStep then Exit;
						with Range do
							begin
								Columns.PreferredWidthType := wdPreferredWidthPoints;
								Columns.PreferredWidth := CentimetersToPoints(0.7);
								ParagraphFormat.Alignment := wdAlignParagraphRight;
								Cells.VerticalAlignment := wdCellAlignVerticalCenter;
							end;
						if DoStep then Exit;
						for i := 0 to 3 do
							with Borders.Item(CBorders[i]) do
								begin
									LineStyle := wdLineStyleDouble;
									Color := wdColorBlack;
									if DoStep then Exit;
								end;
						for i := 1 to 1 + AddRow do
							with Rows.Item(i).Borders.Item(wdBorderBottom) do
								begin
									LineStyle := wdLineStyleSingle;
									Color := wdColorBlack;
									if DoStep then Exit;
								end;
						if AddWeek then
							with Columns.Item(1).Borders.Item(wdBorderRight) do
								begin
									LineStyle := wdLineStyleSingle;
									Color := wdColorBlack;
									if DoStep then Exit;
								end;
						Rows.Item(1 + AddRow).Shading.BackgroundPatternColor := wdColorGray15;
						if DoStep then Exit;
						if AddWeek then
							begin
								Columns.Item(1).Shading.BackgroundPatternColor := wdColorGray15;
								if DoStep then Exit;
							end;
						if AddMonth and AddWeek then
							begin
								Cell(1, 1).Shading.BackgroundPatternColor := wdColorAutomatic;
								if DoStep then Exit;
							end;
						for i := 1 + AddCol to 7 + AddCol do
							begin
								if i = 7 + AddCol then
									Cell(1 + AddRow, i).Range.InsertAfter(
                    StringToOleStr(FormatSettings.ShortDayNames[1]))
								else
									Cell(1 + AddRow, i).Range.InsertAfter(
                    StringToOleStr(FormatSettings.ShortDayNames[1 + i - AddCol]));
								if DoStep then Exit;
							end;
                  ADate := EncodeDate(Year, Month, 1);
						MonthOffset := DayOfWeek(ADate) - 2;
						if MonthOffset = -1 then MonthOffset := 6;
						if AddWeek then
							begin
								for i := 2 + AddRow to 7 + AddRow do
									begin
										if i <> 2 + AddRow then
											begin
												Row := 1 + (7 * (i - (2 + AddRow))) - MonthOffset;
												if Row > DaysInAMonth(Year, Month) then Break;
                                    ADate := EncodeDate(Year, Month, Row);
											end;
										Cell(i, 1).Range.InsertAfter(StringToOleStr(IToS(WeekOf(ADate))));
										if DoStep then Exit;
									end;
							end;
						Col := MonthOffset + AddCol;
						Row := 2 + AddRow;
						for i := 1 to DaysInAMonth(Year, Month) do
							begin
								if Col = 7 + AddCol then begin Col := 1 + AddCol; Inc(Row); end
								else Inc(Col);
								Cell(Row, Col).Range.InsertAfter(StringToOleStr(IToS(i)));
								if DoStep then Exit;
							end;
						Columns.Item(6 + AddCol).Select;
						XVar1 := wdSentence;
						XVar2 := 1;
						XVar3 := wdExtend;
						Selection.MoveRight(XVar1, XVar2, XVar3);
						Selection.Font.Bold := ITrue;
						if DoStep then Exit;
						if AddMonth then
							begin
								Rows.Item(1).Select;
								Selection.Cells.Merge;
								if DoStep then Exit;
								Selection.ParagraphFormat.Alignment := wdAlignParagraphCenter;
								if DoStep then Exit;
								Selection.InsertAfter(
                  StringToOleStr(FormatSettings.LongMonthNames[Month]));
								if DoStep then Exit;
							end;
					end; // with Tables
				XVar1 := wdStory;
				Selection.EndKey(XVar1, EmptyParam);
				if DoStep then Exit;
				with Range do
					begin
						InsertParagraphAfter;
						InsertParagraphAfter;
						InsertAfter(StringToOleStr('© П3тр0виЧъ'));
						InsertParagraphAfter;
						if DoStep then Exit;
					end;
				with Selection do
					begin
						XVar1 := wdStory;
						Selection.EndKey(XVar1, EmptyParam);
						if DoStep then Exit;
						XVar1 := wdWord;
						XVar2 := 1;
						XVar3 := wdMove;
						Selection.MoveLeft(XVar1, XVar2, XVar3);
						if DoStep then Exit;
						XVar1 := wdLine;
						XVar2 := wdExtend;
						Selection.HomeKey(XVar1, XVar2);
						if DoStep then Exit;
						Selection.Font.Name := FontName;
						Selection.Font.Italic := FontItalic;
						if DoStep then Exit;
						XVar1 := wdStory;
						Selection.HomeKey(XVar1, EmptyParam);
						if DoStep then Exit;
					end;
				UndoClear;
				if DoStep then Exit;
			end; // WordAppliation
		WordApplication.Visible := True;
		WordApplication.Activate;
		WordDocument.Activate;
   except
      on E: Exception do
         begin
		      MainResult := False;
            MsgBoxErr(E.Message);
         end;
   end;
	finally
		Result := MainResult;
		if WD then WordDocument.Free;
		if WA then WordApplication.Free;
	end;
end;

end.
