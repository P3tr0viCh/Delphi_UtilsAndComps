unit Utils_Misc;

{$DEBUGINFO OFF}
{$WARNINGS OFF}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, Vcl.Graphics, System.Classes,
  Vcl.Forms, Vcl.StdCtrls, Vcl.ComCtrls, Winapi.ShellAPI, System.Math,
  Vcl.Controls, Vcl.Menus, Vcl.ExtCtrls, System.Win.Registry, System.StrUtils,
  System.IniFiles, Winapi.WinSock, Vcl.ClipBrd, System.Types;

type
  TOnStopNotify = procedure (var Stop: Boolean) of object;
  TOnPercentNotify = procedure (const Percent: Double) of object;

function  MsgBox(sMessage: String = 'Groovy!!';
                 iType: UINT = MB_OK or MB_ICONINFORMATION;
                 sCaption: String = '';
                 hHWND: HWND = 1;
                 wLanguage: Word = $00400): Integer; overload;
function  MsgBox(iValue: Integer;
            iType: UINT = MB_OK or MB_ICONINFORMATION;
            sCaption: String = '';
            hHWND: HWND = 1;
            wLanguage: Word = $00400): Integer; overload;
function  MsgBox(fValue: Extended;
            iType: UINT = MB_OK or MB_ICONINFORMATION;
            sCaption: String = '';
            hHWND: HWND = 1;
            wLanguage: Word = $00400): Integer; overload;
function  MsgBox(bValue: Boolean;
            iType: UINT = MB_OK or MB_ICONINFORMATION;
            sCaption: String = '';
            hHWND: HWND = 1;
            wLanguage: Word = $00400): Integer; overload;
procedure MsgBoxErr(sMessage: String = 'Error !?!'; hHWND: HWND = 1);
function  MsgBoxYesNo(sMessage: String = ''; DefaultNo: Boolean = True; hHWND: HWND = 1): Boolean;

function  DisableCtrlAltDel(Disable: Boolean): Boolean;
procedure Delay(mSecs: LongWord);
function  Percent(Number, Max: Double): Double; overload;
function  Percent(Number, Max: Integer): Integer; overload;
function  IncDecEx(Value: Integer; MaxValue: Byte; DoInc: Boolean): Integer;
function  IsNumber(const S: String; CanMinus: Boolean = True; CanFloat: Boolean = False): Boolean;
function  CheckKeyIsNumeral(var AKey: Char; CanFloat, CanNegative: Boolean;
  AddChars: TSysCharSet): Boolean;
procedure StayOnTop(Form: TForm; const OnTop: Boolean);
procedure ShowErrorBox(Error: Cardinal = 0; AddStr: String = ''; hHWND: HWND = 1);
procedure SetPriority(const ClassPriority: LongWord; const ThreadPriority: Integer);
procedure ShowWaitCursor;
procedure RestoreCursor;
procedure CopyToClipBoard(S: String);
function  CompareBool(const A, B: Boolean): TValueRelationship;

function  ComboBoxText(ComboBox: TComboBox): String;
function  ComboBoxTextFirstValue(ComboBox: TComboBox): Boolean;
function  ComboBoxInteger(ComboBox: TComboBox): Integer;
procedure ComboBoxSelect(ComboBox: TComboBox; AText: String; Default: Integer = -1);

procedure AssignMenuItem(FromItem, ToItem: TMenuItem);
function  CopyMenuItem(FromItem: TMenuItem): TMenuItem;
procedure ModifyMenuItemAsHelp(MenuItem: TMenuItem);

procedure StartTimer(var FirstTick: LongWord);
function  GetStopTimer(FirstTick: LongWord): String;
procedure StopTimer(S: String; FirstTick: LongWord);
procedure RestartTimer(Timer: TTimer);
function  GetCPUSpeed: String;
function  GetTotalPhys: String;
procedure SwitchToThisWindow(Wnd: HWnd; Restore: Bool); far; stdcall;
procedure SetCurPosToCenter(Control: TControl);
procedure ProcMess;

procedure SetSaverActive(Active: Boolean);
function  GetSaverName: String;

function  GetAutoRun(Params: String = ''; FileName: String = ''): TCheckBoxState;
procedure SetAutoRun(AutoRun: TCheckBoxState; Params: String = ''; FileName: String = '');

function  UserName: String;
function  ComputerName: String;
function  GetLocalIP: String;

function  SmallFileVersion(AFileVersion: String): String;
function  GetFileVerInfo(const FileName: String; var FileVersionInfo: TVSFixedFileInfo;
  var CompanyName, FileDescription, FileVersion,
    InternalName, LegalCopyright, OriginalFilename,
    ProductName, ProductVersion: String): Boolean;
function  GetFileVersion(const FileName: String; const SmallFormat: Boolean = True): String;
function  GetFileDescription(const FileName: String): String;

procedure AnimateShowForm(Form: TForm);
procedure AnimateHideForm(Form: TForm);
procedure CenterForm(AForm, AParentForm: TForm);
function  GetClsName(ClassHandle: HWND): String;
function  GetShellTrayHandle: HWND;
function  GetStartButtonHandle: HWND;
procedure HideStartButton(Visible: Boolean);
function  GetChildHandle(ParentHandle: HWND; ChildClass: String): HWND;
function  GetChildHandleByIndex(ParentHandle: HWND; ChildIndex: Integer): HWND;
function  FindWindowByCaption(Caption: String): HWND;
function  ApplicationAlreadyRun(AClassName, AWindowName: String): Boolean;

function  IsIntersectRect(const A, B: TRect): Boolean;

function  SetWallpaper(const FileName: String): Boolean;

function  IsValueInWord(AWord: DWORD; AValue: DWORD): Boolean;
function  Sign0(const AValue: Integer): TValueSign;

procedure SelectListItem(ListItem: TListItem; OnlyThis: Boolean = False);
procedure AddSubItemsToListItem(ListItem: TListItem; Count: Integer);
procedure ListViewUnSelectAll(ListView: TListView);
procedure ListViewInvertSelection(ListView: TListView);
procedure RethinkNumbers(ListView: TListView);
function  FindSubItemByText(ListView: TListView; ASubItemIndex: Integer;
   Text: String; AExcludeIndex: Integer): Integer;

procedure SelectTreeNode(TreeNode: TTreeNode);
function  FindNodeByText(TreeView: TTreeView; Text: String): TTreeNode;

function  GeneratePassword(const AInternSmall, AInternBig, AEngSmall, AEngBig,
  ANumbers, AOther: Boolean; ALength: Integer): String;

function IsWinNT: Boolean;
function IsWin2KOrGreat: Boolean;
function IsWinXPOrGreat: Boolean;
function ExitWin(AFlags: UINT): Boolean;

implementation

uses Utils_Date, Utils_Str, Utils_Files, Masks;

procedure SwitchToThisWindow(Wnd: HWnd; Restore: Bool); far; stdcall; external user32 name 'SwitchToThisWindow';

function MsgBox(sMessage: String = 'Groovy!!';
          iType: UINT = MB_OK or MB_ICONINFORMATION;
          sCaption: String = '';
          hHWND: HWND = 1;
          wLanguage: Word = $00400): Integer;
begin
  if sCaption = '' then sCaption := Application.Title;
  if hHWND = 1 then
    begin
      if Assigned(Screen.ActiveForm) then
        begin
          if (fsModal in Screen.ActiveForm.FormState) or
             (Screen.ActiveForm = Application.MainForm) then
            hHWND := Screen.ActiveForm.Handle
          else
            hHWND := Application.Handle;
        end
      else
        hHWND := Application.Handle;
    end;
  Result := MessageBoxEx(hHWND, PChar(sMessage), PChar(sCaption), iType, wLanguage);
end;

function MsgBox(iValue: Integer;
           iType: UINT = MB_OK or MB_ICONINFORMATION;
           sCaption: String = '';
           hHWND: HWND = 1;
           wLanguage: Word = $00400): Integer;
begin
  Result := MsgBox(IToS(iValue), iType, sCaption, hHWND, wLanguage);
end;

function MsgBox(fValue: Extended;
          iType: UINT = MB_OK or MB_ICONINFORMATION;
          sCaption: String = '';
          hHWND: HWND = 1;
          wLanguage: Word = $00400): Integer;
begin
  Result := MsgBox(FormatFloat(',0.00', fValue), iType, sCaption, hHWND, wLanguage);
end;

function MsgBox(bValue: Boolean;
          iType: UINT = MB_OK or MB_ICONINFORMATION;
          sCaption: String = '';
          hHWND: HWND = 1;
          wLanguage: Word = $00400): Integer;
begin
  Result := MsgBox(BoolToS(bValue), iType, sCaption, hHWND, wLanguage);
end;

procedure MsgBoxErr(sMessage: String = 'Error !?!'; hHWND: HWND = 1);
begin
  MsgBox(sMessage, MB_OK or MB_ICONERROR, 'Îøèáêà', hHWND);
end;

procedure ShowErrorBox(Error: Cardinal = 0; AddStr: String = ''; hHWND: HWND = 1);
begin
  if Error = 0 then Error := GetLastError;
  if AddStr = '' then AddStr := SysErrorMessage(Error)
  else
    if Pos('%s', AddStr) = 0 then AddStr := AddStr + SysErrorMessage(Error)
    else
      AddStr := Format(AddStr, [SysErrorMessage(Error)]);
  MsgBoxErr(AddStr, hHWND);
end;

function MsgBoxYesNo(sMessage: String = ''; DefaultNo: Boolean = True; hHWND: HWND = 1): Boolean;
var // True if YES
  uType: DWORD;
begin
  if sMessage = '' then sMessage := 'To Be Or Not To Be?';
  uType := MB_YESNO or MB_ICONQUESTION;
  if DefaultNo then uType := uType or MB_DEFBUTTON2;
  Result := MsgBox(sMessage, uType, '', hHWND) = ID_YES;
end;

function DisableCtrlAltDel(Disable: Boolean): Boolean;
var
  Param: Integer;
begin
  Result := SystemParametersInfo(SPI_SCREENSAVERRUNNING, Ord(Disable), @Param, 0);
end;

procedure Delay(mSecs: LongWord);
var
  FirstTick: LongWord;
begin
  FirstTick := GetTickCount;
  repeat
    ProcMess;
  until (GetTickCount - FirstTick) >= mSecs;
end;

function Percent(Number, Max: Double): Double;
begin
  if (Number = 0) or (Max = 0) then Result := 0
  else Result := (Number / Max) * 100;
end;

function  Percent(Number, Max: Integer): Integer;
begin
  if (Number = 0) or (Max = 0) then Result := 0
  else Result := Round((Number / Max) * 100);
end;

function IncDecEx(Value: Integer; MaxValue: Byte; DoInc: Boolean): Integer;
begin
  if DoInc then
    begin
      if Value < MaxValue then Inc(Value) else Value := 0;
    end
  else
    begin
      if Value > 0 then Dec(Value) else Value := MaxValue;
    end;
  Result := Value;
end;

function IsNumber(const S: String; CanMinus: Boolean = True; CanFloat: Boolean = False): Boolean;
var
  i: Integer;
  Int: TSysCharSet;
  DS: AnsiString;
begin
  Int := ['0'..'9'];
  DS  :=  FormatSettings.DecimalSeparator;
  if CanMinus then Include(Int, '-');
  if CanFloat then Include(Int, DS[1]);
  Result := S <> '';
  if Result then Result := Pos('-', S) in [0, 1];
  if Result and CanFloat then
    Result := PosEx(DS[1], S, Pos(DS[1], S) + 1) = 0;
  if Result then
    for i := 1 to Length(S) do
      if not CharInSet(S[i], Int) then
        begin
          Result := False;
          Break;
        end;
end;

function CheckKeyIsNumeral(var AKey: Char; CanFloat, CanNegative: Boolean;
  AddChars: TSysCharSet): Boolean;
begin
  Result := True;
  if CharInSet(AKey, ['0'..'9', Chr(VK_BACK)]) then Exit;
  if CharInSet(AKey, AddChars) then Exit;

  if CanFloat then
    begin
      if CharInSet(AKey, [',', '.']) then
        begin
          AKey := FormatSettings.DecimalSeparator;
          Exit;
        end;
    end;
  if CanNegative then
    begin
      if AKey = '-' then Exit;
    end;
  Result := False;
  AKey := #0;
  Beep;
end;

procedure StayOnTop(Form: TForm; const OnTop: Boolean);
const
  TopMosts: array[Boolean] of HWND = (HWND_NOTOPMOST, HWND_TOPMOST);
begin
  SetWindowPos(Form.Handle, TopMosts[OnTop], 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
end;

procedure SetPriority(const ClassPriority: LongWord; const ThreadPriority: Integer);
begin
  SetPriorityClass(GetCurrentProcess, ClassPriority);
  SetThreadPriority(GetCurrentThread, ThreadPriority);
end;

procedure ShowWaitCursor;
begin
  Screen.Cursor := crHourGlass;
  ProcMess;
end;

procedure RestoreCursor;
begin
  Screen.Cursor := crDefault;
end;

procedure CopyToClipBoard(S: String);
begin
  Clipboard.AsText := S;
end;

function CompareBool(const A, B: Boolean): TValueRelationship;
begin
  if A < B then Result := LessThanValue
  else
    if A > B then Result := GreaterThanValue
    else Result := EqualsValue;
end;

function ComboBoxText(ComboBox: TComboBox): String;
begin
  with ComboBox do
    begin
      if (ItemIndex >= 0) and (ItemIndex < Items.Count) then
        Result := Items[ItemIndex]
      else
        Result := '';
    end;
end;

function  ComboBoxTextFirstValue(ComboBox: TComboBox): Boolean;
begin
  with ComboBox do
    begin
      Result := Items.Count > 0;
      if Result then Result := Text = Items[0];
    end;
end;

function ComboBoxInteger(ComboBox: TComboBox): Integer;
begin
  with ComboBox do
    Result := Integer(Items.Objects[ItemIndex]);
end;

procedure ComboBoxSelect(ComboBox: TComboBox; AText: String; Default: Integer = -1);
begin
  with ComboBox do
    begin
      ItemIndex := Items.IndexOf(AText);
      if ItemIndex = -1 then ItemIndex := Default;
    end;
end;

procedure AssignMenuItem(FromItem, ToItem: TMenuItem);
begin
  with ToItem do
    begin
      OnClick := FromItem.OnClick;
      OnAdvancedDrawItem := FromItem.OnAdvancedDrawItem;
      OnDrawItem := FromItem.OnDrawItem;
      OnMeasureItem := FromItem.OnMeasureItem;
      RadioItem := FromItem.RadioItem;
      Break := FromItem.Break;
      if Assigned(FromItem.Action) then
        begin
          Action := FromItem.Action;
          Exit;
        end;
      Caption := FromItem.Caption;
      Hint := FromItem.Hint;
      Checked := FromItem.Checked;
      Enabled := FromItem.Enabled;
      GroupIndex := FromItem.GroupIndex;
      ImageIndex := FromItem.ImageIndex;
      ShortCut := FromItem.ShortCut;
      Tag := FromItem.Tag;
      Visible := FromItem.Visible;
    end;
end;

function CopyMenuItem(FromItem: TMenuItem): TMenuItem;
begin
  Result := TMenuItem.Create(FromItem.Owner);
  AssignMenuItem(FromItem, Result);
end;

procedure ModifyMenuItemAsHelp(MenuItem: TMenuItem);
begin
  ModifyMenu(MenuItem.Parent.Handle, MenuItem.MenuIndex,
    MF_BYPOSITION or MF_POPUP or MF_HELP, MenuItem.Handle, PChar(MenuItem.Caption));
end;

procedure StartTimer(var FirstTick: LongWord);
begin
  FirstTick := GetTickCount;
end;

function  GetStopTimer(FirstTick: LongWord): String;
begin
  Result := FormatFloat('0,# msec.', GetTickCount - FirstTick);
end;

procedure StopTimer(S: String; FirstTick: LongWord);
begin
  MsgBox(S + GetStopTimer(FirstTick));
end;

procedure RestartTimer(Timer: TTimer);
begin
  Timer.Enabled := False;
  Timer.Enabled := True;
end;

function GetCPUSpeed: String;
const
  DelayTime = 500;
var
  TimerHi, TimerLo: DWORD;
  PriorityClass, Priority: Integer;
begin
  PriorityClass := GetPriorityClass(GetCurrentProcess);
  Priority := GetThreadPriority(GetCurrentThread);
  SetPriorityClass(GetCurrentProcess, REALTIME_PRIORITY_CLASS);
  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_TIME_CRITICAL);
  Sleep(10);
  asm
    dw 310Fh
    mov TimerLo, eax
    mov TimerHi, edx
  end;
  Sleep(DelayTime);
  asm
    dw 310Fh
    sub eax, TimerLo
    sbb edx, TimerHi
    mov TimerLo, eax
    mov TimerHi, edx
  end;
  SetThreadPriority(GetCurrentThread, Priority);
  SetPriorityClass(GetCurrentProcess, PriorityClass);
  Result := FormatHerzs(Round(1000.0 * TimerLo / (DelayTime)));
end;

function GetTotalPhys: String;
var
  MS: TMemoryStatus;
begin
  MS.dwLength := SizeOf(TMemoryStatus);
  GlobalMemoryStatus(MS);
  Result := FormatBytes(MS.dwTotalPhys);
end;

procedure SetCurPosToCenter(Control: TControl);
var
  EndPoint: TPoint;
begin
  if Control <> nil then
    with Control, Control.ClientToScreen(Point(Width div 2, Height div 2)) do
      EndPoint := Point(X, Y)
  else
    with Screen do EndPoint := Point(Width div 2, Height div 2);
  SetCursorPos(EndPoint.x, EndPoint.y)
end;

procedure ProcMess;
begin
  Application.ProcessMessages;
end;

procedure SetSaverActive(Active: Boolean);
begin
  SystemParametersInfo(SPI_SETSCREENSAVEACTIVE, UINT(Active), nil, SPIF_UPDATEINIFILE);
end;

{function GetSaverActive: Boolean;
begin
  SystemParametersInfo(SPI_GETSCREENSAVEACTIVE, 0, @Result, SPIF_UPDATEINIFILE);
end;}

function  GetSaverName: String;
begin
  with TRegistry.Create do
    try
      OpenKeyReadOnly('Control Panel\Desktop');
      Result := ReadString('SCRNSAVE.EXE');
    finally
      Free;
    end;
end;

function  GetAutoRun(Params: String = ''; FileName: String = ''): TCheckBoxState;
var
  ProgPath: String;
begin
  if Params <> '' then Params := ' /' + Params;
  if FileName = '' then FileName := Application.ExeName;
  with TRegistry.Create do
    try
      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Run', False) then
        begin
          ProgPath := ReadString(OnlyFileName(FileName));
          if ProgPath = '' then Result := cbUnchecked
          else
            begin
              if AnsiSameStr(ProgPath, AddQuotes(FileName) + Params) then
                Result := cbChecked
              else
                Result := cbGrayed;
            end
        end
      else
        Result := cbGrayed;
    finally
      Free;
    end;
end;

procedure SetAutoRun(AutoRun: TCheckBoxState; Params: String = ''; FileName: String = '');
var
  ProgName: String;
begin
  if AutoRun = cbGrayed then Exit;
  if FileName = '' then FileName := Application.ExeName;
  ProgName := OnlyFileName(FileName);
  if Params <> '' then Params := ' /' + Params;
  with TRegistry.Create do
    try
      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Run', False) then
        begin
          if AutoRun = cbChecked then
            WriteString(ProgName, AddQuotes(FileName) + Params)
          else
            DeleteValue(ProgName);
        end;
    finally
      Free;
    end;
end;

function UserName: String;
var
  Buffer: PChar;
  BufSize: DWORD;
begin
  MsgBox('TODO: ERROR FUNCTION'); Exit;
  BufSize := 127;
  GetMem(Buffer, BufSize);
  try
    if GetUserName(Buffer, BufSize) then Result := String(Buffer) else Result := '';
  finally
    FreeMem(Buffer);
  end;
end;

function ComputerName: String;
var
  Buffer: array[0..Pred(MAX_COMPUTERNAME_LENGTH + 1)] of WideChar;
  Size: DWORD;
begin
  Size := SizeOf(Buffer);
  if GetComputerName(Buffer, Size) then
    Result := String(Buffer)
  else
    Result := '';
end;

function GetLocalIP: String;
const
  WSVer = $101;
var
  wsaData: TWSAData;
  P: PHostEnt;
  Buf: array [0..127] of Char;
begin
  Result := '';
  if WSAStartup(WSVer, wsaData) <> 0 then Exit;
  try
    if GetHostName(@Buf, 128) <> 0 then Exit;
    P := GetHostByName(@Buf);
    if P <> nil then Result := inet_ntoa(PInAddr(p^.h_addr_list^)^);
  finally
    WSACleanup;
  end;
end;

function  SmallFileVersion(AFileVersion: String): String;
var
  S1, S2, S3: String;
begin
  SplitStr(AFileVersion, DOT, 1, S1, S2);
  SplitStr(S2, DOT, 0, S2, S3);
  if S3 = '0' then
    begin
      S3 := '';
      if S2 = '0' then S2 := '';
    end;
  Result := S1 + S2 + S3;
end;

function GetFileVerInfo(const FileName: String; var FileVersionInfo: TVSFixedFileInfo;
  var CompanyName, FileDescription, FileVersion,
    InternalName, LegalCopyright, OriginalFilename,
    ProductName, ProductVersion: String): Boolean;
type
  TLANGANDCODEPAGE = record
  wLanguage,
  wCodePage : Word;
  end;
  PLANGANDCODEPAGE = ^TLANGANDCODEPAGE;
var
  NU: DWORD;
  FVSize: DWORD;
  Data: Pointer;
  BufferLen: UINT;
  InfoPath: String;
  Translation: PLANGANDCODEPAGE;

  procedure VerQValueFS;
  var
    Buffer: PVSFixedFileInfo;
  begin
    Buffer := AllocMem(BufferLen);
    VerQueryValue(Data, PChar('\'#0), Pointer(Buffer), BufferLen);
    FileVersionInfo := Buffer^;
  end;

  function VerQValue(SubBlock: String): String;
  var
    Buffer: PChar;
  begin
    VerQueryValue(Data, PChar(InfoPath + SubBlock), Pointer(Buffer), BufferLen);
    if BufferLen <> 0 then Result := Buffer else Result := '';
  end;

begin
  FVSize := GetFileVersionInfoSize(PChar(FileName), NU);
  Result := FVSize <> 0;
  if Result then
    begin
      GetMem(Data, FVSize);
      try
        Result := GetFileVersionInfo(PChar(FileName), 0, FVSize, Data);
        if Result then
          begin
            Result := VerQueryValue(Data, '\VarFileInfo\Translation', Pointer(Translation), FVSize);
            if Result then
              InfoPath := '\StringFileInfo\'+
                IntToHex(Translation^.wLanguage,4) + IntToHex(Translation^.wCodePage,4) + '\'
            else
              InfoPath := '\StringFileInfo\040904E4\';
            BufferLen := SizeOf(TVSFixedFileInfo);
            VerQValueFS;
            BufferLen := 127;
            CompanyName := VerQValue('CompanyName');
            FileDescription := VerQValue('FileDescription');
            FileVersion := VerQValue('FileVersion');
            InternalName := VerQValue('InternalName');
            LegalCopyright := VerQValue('LegalCopyright');
            OriginalFilename := VerQValue('OriginalFilename');
            ProductName := VerQValue('ProductName');
            ProductVersion := VerQValue('ProductVersion');
          end;
      finally
        FreeMem(Data);
      end;
    end;
end;

function GetFileVersion(const FileName: String; const SmallFormat: Boolean = True): String;
var
  FileVersionInfo: TVSFixedFileInfo;
  CompanyName, FileDescription, FileVersion,
  InternalName, LegalCopyright, OriginalFilename,
  ProductName, ProductVersion: String;
begin
  Result := '';
  if GetFileVerInfo(FileName, FileVersionInfo, CompanyName, FileDescription, FileVersion,
    InternalName, LegalCopyright, OriginalFilename, ProductName, ProductVersion) then
    begin
      Result := FileVersion;
      if SmallFormat then Result := SmallFileVersion(Result);
      if IsValueInWord(FileVersionInfo.dwFileFlags, VS_FF_DEBUG) then
        Result := Result + ' (Debug build)';
    end;
end;

function  GetFileDescription(const FileName: String): String;
var
  FileVersionInfo: TVSFixedFileInfo;
  CompanyName, FileDescription, FileVersion,
  InternalName, LegalCopyright, OriginalFilename,
  ProductName, ProductVersion: String;
begin
  if GetFileVerInfo(FileName, FileVersionInfo, CompanyName, FileDescription, FileVersion,
    InternalName, LegalCopyright, OriginalFilename, ProductName, ProductVersion) then
    Result := FileDescription
  else
    Result := '';
end;

function GetClsName(ClassHandle: HWND): String;
var
  Buffer: array[0..127] of Char;
begin
  SetString(Result, Buffer, GetClassName(ClassHandle, Buffer, SizeOf(Buffer)));
end;

function GetShellTrayHandle: HWND;
begin
  Result := FindWindow(PChar('Shell_TrayWnd'), nil);
end;

function GetStartButtonHandle: HWND;
begin
  Result := GetChildHandle(GetShellTrayHandle, 'BUTTON');
end;

function GetChildHandle(ParentHandle: HWND; ChildClass: String): HWND;
// ChildClass in UPPERCASE
var
  Child: HWND;
begin
  Result := 0;
  Child := GetWindow(ParentHandle, GW_CHILD);
  while Child <> 0 do
    begin
      if UpperCase(GetClsName(Child)) = UpperCase(ChildClass) then
        begin
          Result := Child;
          Break;
        end;
      Child := GetWindow(Child, GW_HWNDNEXT);
    end;
end;

function GetChildHandleByIndex(ParentHandle: HWND; ChildIndex: Integer): HWND;
var
  Child: HWND;
  Index: Integer;
begin
  Result := 0;
  Index := 0;
  Child := GetWindow(ParentHandle, GW_CHILD);
  while Child <> 0 do
    begin
      if Index = ChildIndex then
        begin
          Result := Child;
          Break;
        end;
      Inc(Index);
      Child := GetWindow(Child, GW_HWNDNEXT);
    end;
end;

function FindWindowByCaption(Caption: String): HWND;
var
  TempHWND: HWND;
  Buffer: array[0..127] of Char;
begin
  Result := 0;
  TempHWND := GetWindow(Application.MainForm.Handle, GW_HWNDFIRST);
  while TempHWND <> 0 do
    begin
      GetWindowText(TempHWND, Buffer, SizeOf(Buffer));
      if MatchesMask(String(Buffer), Caption) then
        begin
          Result := TempHWND;
          Break;
        end;
      TempHWND := GetWindow(TempHWND, GW_HWNDNEXT);
    end;
end;

function ApplicationAlreadyRun(AClassName, AWindowName: String): Boolean;
var
  Handle: HWND;
begin
  Handle := FindWindow(PChar(AClassName), PChar(AWindowName));
  Result := Handle <> 0;
  if Result then SetForegroundWindow(Handle);
end;

procedure HideStartButton(Visible: Boolean);
begin
  ShowWindow(GetStartButtonHandle, Integer(Visible));
end;

function IsIntersectRect(const A, B: TRect): Boolean;
var
  NullRect: TRect;
begin
  Result := IntersectRect(NullRect, A, B);
end;

function SetWallpaper(const FileName: String): Boolean;
begin
  Result := SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, PChar(FileName), SPIF_UPDATEINIFILE);
end;

function IsValueInWord(AWord: DWORD; AValue: DWORD): Boolean;
begin
  Result := Bool(AWord and AValue);
end;

function Sign0(const AValue: Integer): TValueSign;
begin
  if AValue < 0 then Result := NegativeValue else Result := PositiveValue;
end;

procedure AnimateShowForm(Form: TForm);
var
  i: Integer;
  SaveAlphaBlend: Boolean;
begin
  SaveAlphaBlend := Form.AlphaBlend;
  Form.AlphaBlend := True;
  Form.AlphaBlendValue := 0;
  Form.Show;
  i := 0;
  while i < 255 do
    begin
      Form.AlphaBlendValue := i;
      Delay(10);
      Inc(i, 10);
    end;
  Form.AlphaBlend := SaveAlphaBlend;
end;

procedure AnimateHideForm(Form: TForm);
var
  i: Integer;
begin
  i := Form.AlphaBlendValue;
  repeat
    Form.AlphaBlendValue := i;
    Delay(10);
    Dec(i, 10);
  until i <= 0;
end;

procedure SelectListItem(ListItem: TListItem; OnlyThis: Boolean = False);
begin
  if Assigned(ListItem) then
    with ListItem do
      begin
        if OnlyThis then ListView.Selected := nil;
        Focused := True;
        Selected := True;
        MakeVisible(False);
      end;
end;

procedure SelectTreeNode(TreeNode: TTreeNode);
begin
  with TreeNode do
    begin
      Focused := True;
      Selected := True;
      MakeVisible;
    end;
  Delay(TTreeView(TreeNode.Owner.Owner).ChangeDelay + 50);
end;

function FindNodeByText(TreeView: TTreeView; Text: String): TTreeNode;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to TreeView.Items.Count - 1 do
    if TreeView.Items[i].Text = Text then
      begin
        Result := TreeView.Items[i];
        Break;
      end;
end;

procedure AddSubItemsToListItem(ListItem: TListItem; Count: Integer);
var
  i: Integer;
begin
  for i := 1 to Count do ListItem.SubItems.Add('');
end;

procedure ListViewUnSelectAll(ListView: TListView);
var
  i: Integer;
begin
  ListView.Items.BeginUpdate;
  try
    for i := 0 to ListView.Items.Count - 1 do ListView.Items[i].Selected := False;
  finally
    ListView.Items.EndUpdate;
  end;
end;

procedure ListViewInvertSelection(ListView: TListView);
var
  i: Integer;
begin
  ListView.Items.BeginUpdate;
  try
    for i := 0 to ListView.Items.Count - 1 do
      ListView.Items[i].Selected := not ListView.Items[i].Selected;
  finally
    ListView.Items.EndUpdate;
  end;
end;

procedure RethinkNumbers(ListView: TListView);
var
  i: Integer;
begin
  for i := 0 to ListView.Items.Count - 1 do
    ListView.Items[i].Caption := IToS(i + 1);
end;

function  FindSubItemByText(ListView: TListView; ASubItemIndex: Integer;
  Text: String; AExcludeIndex: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to ListView.Items.Count - 1 do
    begin
      if i = AExcludeIndex then Continue;
      if ListView.Items[i].SubItems[ASubItemIndex] = Text then
        begin
          Result := i;
          Break;
        end;
    end;
end;

function  GeneratePassword(const AInternSmall, AInternBig, AEngSmall, AEngBig,
  ANumbers, AOther: Boolean; ALength: Integer): String;
var
  SymbolsSet: array[Byte] of Char;
  i, SymbolsCount: Integer;

  procedure AddSymbol(ASymbol: Char);
  begin
    SymbolsSet[SymbolsCount] := ASymbol;
    Inc(SymbolsCount);
  end;
begin
  if ALength <= 0 then ALength := 5;
  if not (AInternSmall or AInternBig or AEngSmall or AEngBig or ANumbers or AOther) then
    begin
      Result := GeneratePassword(False, False, False, False, True, False, ALength);
      Exit;
    end;
  SymbolsCount := Low(Byte);
  for i := Low(Byte) to High(Byte) do
    case Char(i) of
    '0'..'9':      if ANumbers       then AddSymbol(Char(i));
    'a'..'z':      if AEngSmall      then AddSymbol(Char(i));
    'A'..'Z':      if AEngBig        then AddSymbol(Char(i));
    'à'..'ÿ', '¸': if AInternSmall   then AddSymbol(Char(i));
    'À'..'ß', '¨': if AInternBig     then AddSymbol(Char(i));
    '/', '*', '-', '+', '=', ',', '.', '''', '[', ']', '`', ';': // Without Shift
                   if AOther         then AddSymbol(Char(i));
    '~', '!', '@', '#', '$', '%', '^', '&', '(', ')', '_', '|', ':', '"', '?',
    '<', '>', '¹': // with Shift
                   if AOther and (AEngBig or AInternBig) then AddSymbol(Char(i));
    end;
  Result := '';
  Randomize;
  for i := 1 to ALength do
    Result := Result + SymbolsSet[Random(SymbolsCount)];
end;

function IsWinNT: Boolean;
begin
  Result := Win32Platform = VER_PLATFORM_WIN32_NT;
end;

function IsWin2KOrGreat: Boolean;
begin
  Result := (Win32MajorVersion > 4) and (Win32Platform = VER_PLATFORM_WIN32_NT);
end;

function IsWinXPOrGreat: Boolean;
begin
  Result := (Win32MajorVersion >= 5) and (Win32MinorVersion >= 1);
end;

function ExitWin(AFlags: UINT): Boolean;
var
  Handle: THandle;
  N: DWORD;
  Priv: TOKEN_PRIVILEGES;
  Dummy: PTokenPrivileges;
begin
  if IsWinNT then
    begin
      Result := OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES, Handle);
      if not Result then Exit;
      Result := LookupPrivilegeValue(nil, 'SeShutdownPrivilege', Priv.Privileges[0].Luid);
      if not Result then Exit;
      Priv.PrivilegeCount := 1;
      Priv.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
      Dummy := nil;
      Result := AdjustTokenPrivileges(Handle, False, Priv, 0, Dummy^, N);
      if not Result then Exit;
    end;
  Result := ExitWindowsEx(AFlags, 0);
end;

procedure CenterForm(AForm, AParentForm: TForm);
var
  P: TPoint;
begin
  if Assigned(AParentForm) then
    with AParentForm do
      P := Point(Left + (Width - AForm.Width) div 2, Top + (Height - AForm.Height) div 2)
  else
    with Screen.Monitors[0] do
      P := Point((Width - AForm.Width) div 2, (Height - AForm.Height) div 2);
  with P do AForm.SetBounds(X, Y, AForm.Width, AForm.Height);
end;

end.

