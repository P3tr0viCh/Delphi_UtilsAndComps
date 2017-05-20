unit AboutFrm; // Version 5.1.0 from 2014.09.30

interface

{$DEBUGINFO OFF}

uses Winapi.Windows, Winapi.Messages, Classes, Graphics, Controls, Forms,
  System.UITypes, ExtCtrls, StdCtrls, GradPanel;

resourcestring
  rsEULA1 = '• Распространяется свободно (FREEWARE).';
  rsEULA2 = '• Поставляется "КАК ЕСТЬ", то есть автор не дает никаких гарантий работоспособности программы, ' +
            'а также не несет никакой ответственности за любой прямой, косвенный или иной ущерб, ' +
            'понесенный в результате ее использования.'#13#10 +
            'Вы используете это программное обеспечение на свой риск.';
  rsEULA3 = '• ЗАПРЕЩЕНО любое изменение, адаптирование, перевод, дизассемблирование данной программы.';
  rsEULA4 = '• ЗАПРЕЩЕНО распространение программы в коммерческих целях без согласования с автором.';

  rsLicenses = 'Othr_Lic.htm';

procedure ShowAbout(iFontSize:    Integer = 26;
                    bLineBreak:   Byte = MAXBYTE;
                    bVersionPos:  Byte = 3;
                    sDate:        String = #0;
                    pPicture:     TPicture = nil;
                    sAddComp:     String = #0;
                    sVersion:     String = #0;
                    sAppName:     String = #0;
                    sCopyright:   String = #0;
                    sText:        String = #0;
                    hIcon:        HICON = 0);

implementation

uses Utils_KAndM, Utils_Misc, Utils_Graf, SysUtils, Utils_Files, Utils_Str;

type
  TClickObject = class
  public
    MailAddress, MailSubject: String;
    procedure MouseEnter(Sender: TObject);
    procedure MouseLeave(Sender: TObject);
    procedure Click(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
  end;

var
  lblMemory, lblProc, lblMemoryValue, lblProcValue: TLabel;

procedure ShowAbout;
var
  Form: TForm;
  Button: TButton;
  PanelIcon: TPanel;
  PanelName: TGradientPanel;
  I, PosEMail: Integer;
  sCaption: String;
  FileVersionInfo: TVSFixedFileInfo;
  CompanyName, FileDescription, FileVersion,
  InternalName, LegalCopyright, OriginalFilename,
  ProductName, ProductVersion: String;
  ClickObject: TClickObject;
begin
  ShowWaitCursor;
  Randomize;
  if IsShift and IsCtrl then
    begin
      sAppName := 'Дураев'#13#10'Константин Петрович';
      sCopyright := #0;
      sCaption := 'Автор';
      sDate := '29 марта 1981 года';
      sVersion := '';
      iFontSize := 16;
      sAddComp := #0;
      pPicture := nil;
      sText := '';
      for I := 1 to 280 do
        if I mod 40 = 0 then sText := sText + sLineBreak
        else
          sText := sText + String(AnsiChar(Chr(Ord('А') + Random(Ord('Я') - Ord('А')))));
    end
  else
    begin
      GetFileVerInfo(Application.ExeName, FileVersionInfo, CompanyName,
        FileDescription, FileVersion, InternalName, LegalCopyright,
        OriginalFilename, ProductName, ProductVersion);

      sCaption := 'О программе...';
//      if sDate = #0 then sDate := rsCompileDate;
      if sDate = #0 then sDate := FormatDateTime('YYYY.MM.DD',
        FileDateToDateTime(PInteger(PImageNtHeaders(
          hInstance + DWORD(PImageDosHeader(hInstance)._lfanew)).OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_RESOURCE].VirtualAddress +
          hInstance + 4)^));

      if sVersion = #0 then
        begin
          sVersion := FileVersion;
          if IsValueInWord(FileVersionInfo.dwFileFlags, VS_FF_DEBUG) then
            sVersion := sVersion + ' (Debug build)'
          else
            if IsValueInWord(FileVersionInfo.dwFileFlags, VS_FF_PRERELEASE) then
              sVersion := sVersion + ' (RC)';
        end;

      if sAppName   = #0 then sAppName := ProductName;

      if sCopyright = #0 then sCopyright := LegalCopyright + '|@P3tr0viCh@mail.ru';

      if sText      = #0 then sText := rsEULA1 + #13#10 + rsEULA2 + #13#10 + rsEULA3 + #13#10 + rsEULA4;

      if bLineBreak <> MAXBYTE then
        begin
          I := PosPlace(SPACE, sAppName, bLineBreak);
          sAppName := Copy(sAppName, 1, I - 1) + sLineBreak +
            Copy(sAppName, I + 1, MAXINT);
        end;
    end; // if IsShift and IsCtrl

  if hIcon = 0 then hIcon := LoadIcon(hInstance, PChar('MAINICON'));

  ClickObject := TClickObject.Create;
  Form := TForm.Create(Application);// Owner;
  try
    with Form do
      begin
        ShowHint := True;
        with Font do
          begin
            Name := 'Arial';
            Size := 10;
          end;
        BorderStyle := bsDialog;
        Caption := sCaption;
        ClientHeight := 165;
        ClientWidth := 420;
      end;

    with TBevel.Create(Form) do
      begin
        Parent := Form;
        SetBounds(8, 14, 52, 52);
        Shape := bsFrame;
      end;

    PanelIcon := TPanel.Create(Form);
    with PanelIcon do
      begin
        Parent := Form;
        SetBounds(16, 22, 36, 36);
        Caption := '';
        BevelOuter := bvNone;
        BorderStyle := bsSingle;
        ParentBackground := False;
        Color := TColor(Random($FFFFFF));
      end;

    with TImage.Create(Form) do // Icon
      begin
        Parent := PanelIcon;
        Align := alClient;
        Transparent := True;
        Picture.Icon.Handle := hIcon;
      end;

    with TLabel.Create(Form) do // Copyright
      begin
        Tag := 1;
        Parent := Form;
        Font.Style := [fsBold];
        SetBounds(8, 80, 0, 0);
        PosEMail := Pos('|', sCopyright);
        if PosEMail = 0 then
          Caption := sCopyright
        else
          begin
            Caption := Copy(sCopyright, 1, PosEMail - 1);
            Hint := Copy(sCopyright, PosEMail + 1, MAXINT);
            Cursor := crHandPoint;
            OnMouseEnter := ClickObject.MouseEnter;
            OnMouseLeave := ClickObject.MouseLeave;
            if Hint[1] = '@' then
              begin
                Hint := Copy(Hint, 2, MAXINT);
                ClickObject.MailAddress := Hint;
                ClickObject.MailSubject := OriginalFilename + ' ' + FileVersion;
              end;
            OnClick := ClickObject.Click;
          end;
      end;

    with TLabel.Create(Form) do // Text
      begin
        Parent := Form;
        WordWrap := True;
        SetBounds(8, 100, Form.ClientWidth - 16, 0);
        Caption := sText;
        I := Top + Height;
        Form.ClientHeight := Form.ClientHeight + Height;
      end;

    if sAddComp <> #0 then
      begin
        with TBevel.Create(Form) do
          begin
            Parent := Form;
            SetBounds(7, I + 5, Form.ClientWidth - 15, 5);
            Shape := bsTopLine;
            I := Top + Height;
          end;

        with TLabel.Create(Form) do // Add Components
          begin
            Parent := Form;
            SetBounds(8, I, 0, 0);
            Caption := 'Программное обеспечение использует следующие компоненты:';
            I := Top + Height;
          end;

        with TLabel.Create(Form) do // Components
          begin
            Tag := 2;
            Parent := Form;
            Font.Style := [fsBold];
            SetBounds(8, I, 0, 0);
            Caption := sAddComp;
            Form.ClientHeight := Form.ClientHeight + Height + 12;
            if FileExists(FileInAppDir(rsLicenses)) then
              begin
                Cursor := crHandPoint;
                OnClick := ClickObject.Click;
                OnMouseEnter := ClickObject.MouseEnter;
                OnMouseLeave := ClickObject.MouseLeave;
              end;
          end;
        end
      else // if sAddComp <> #0
        Form.ClientHeight := Form.ClientHeight - 12;

    with TBevel.Create(Form) do
      begin
        Parent := Form;
        SetBounds(7, Form.ClientHeight - 43, Form.ClientWidth - 15, 5);
        Shape := bsTopLine;
      end;

    lblMemory := TLabel.Create(Form);
    with lblMemory do // Физическая ...
      begin
        Parent := Form;
        SetBounds(8, Form.ClientHeight - 38, 0, 0);
        Caption := 'Физическая память:';
        I := Width;
      end;

    lblMemoryValue := TLabel.Create(Form);
    with lblMemoryValue do // TotalPhys
      begin
        Parent := Form;
        Font.Style := [fsBold];
        SetBounds(I + 13, Form.ClientHeight - 38, 0, 0);
      end;

    lblProc := TLabel.Create(Form);
    with lblProc do // Процессор:
      begin
        Parent := Form;
        SetBounds(8, Form.ClientHeight - 22, 0, 0);
        Caption := 'Процессор:';
      end;

    lblProcValue := TLabel.Create(Form);
    with lblProcValue do // CPUSpeed
      begin
        Parent := Form;
        Font.Style := [fsBold];
        SetBounds(I + 13, Form.ClientHeight - 22, 0, 0);
      end;

    PanelName := TGradientPanel.Create(Form);
    with PanelName do
      begin
        Parent := Form;
        StartUpdate;
        SetBounds(68, 8, Form.ClientWidth - 76, 64);
        BorderStyle := bsSingle;
        if pPicture = nil then ColorStart := PanelIcon.Color
                          else ColorStart := clBlack;
        ColorEnd := clBlack;
        EndUpdate;
      end;

    if pPicture = nil then
      begin
        with TLabel.Create(Form) do // Application Name (1)
          begin
            Parent := PanelName;
            SetBounds(2, 2, Form.ClientWidth - 83, 58);
            Alignment := taCenter;
            AutoSize := False;
            Caption := sAppName;
            ParentColor := False;
            Color := clBlack;
            ParentFont := False;
            with Font do
              begin
                Charset := DEFAULT_CHARSET;
                Color := clBlack;
                Height := -51;
                Name := 'Courier New';
                Style := [fsBold, fsItalic];
                Size := iFontSize;
              end;
            Transparent := True;
            Layout := tlCenter;
            WordWrap := True;
          end;

        with TLabel.Create(Form) do // Application Name (2)
          begin
            Parent := PanelName;
            SetBounds(0, 0, Form.ClientWidth - 83, 58);
            Alignment := taCenter;
            AutoSize := False;
            Caption := sAppName;
            ParentColor := False;
            Color := clBlack;
            ParentFont := False;
            with Font do
              begin
                Charset := DEFAULT_CHARSET;
                Color := clWhite;
                Height := -51;
                Name := 'Courier New';
                Style := [fsBold, fsItalic];
                Size := iFontSize;
              end;
            Transparent := True;
            Layout := tlCenter;
            WordWrap := True;
          end;
      end // if pPicture = nil
    else
      begin
        with TImage.Create(Form) do
          begin
            Parent := PanelName;
            Align := alClient;
            Picture.Assign(pPicture);
          end;
      end;

    with TLabel.Create(Form) do // Date
      begin
        Parent := PanelName;
        Caption := sDate;
        with Font do
          begin
            Assign(Form.Font);
            Font.Style := [fsBold];
            Color := clWhite;
            Size := 8;
          end;
        Alignment := taRightJustify;
        case 3 of
        0:  SetBounds(2, 2, Width, Height);
        1:  SetBounds(2, PanelName.ClientHeight - Height - 2, Width, Height);
        2:  SetBounds(PanelName.ClientWidth - Width - 2, 2, Width, Height);
        else
          SetBounds(PanelName.ClientWidth - Width - 2,
            PanelName.ClientHeight - Height - 2, Width, Height);
        end;
        Transparent := True;
      end;

    with TLabel.Create(Form) do // Version
      begin
        Parent := PanelName;
        Caption := sVersion;
        with Font do
          begin
            Assign(Form.Font);
            Font.Style := [fsBold];
            Color := clWhite;
            Size := 8;
          end;
        case 2 of
        0:  SetBounds(2, 2, Width, Height);
        1:  SetBounds(2, PanelName.ClientHeight - Height - 2, Width, Height);
        2:  SetBounds(PanelName.ClientWidth - Width - 2, 2, Width, Height);
        else
          SetBounds(PanelName.ClientWidth - Width - 2,
            PanelName.ClientHeight - Height - 2, Width, Height);
        end;
        Transparent := True;
      end;

    Button := TButton.Create(Form);
    with Button do
      begin
        Parent := Form;
        Caption := 'OK';
        ModalResult := mrCancel;
        Cancel := True;
        SetBounds(Form.ClientWidth - 83, Form.ClientHeight - 34, 75, 26);
        TabOrder := 0;
      end;

    with TTimer.Create(Form) do
      begin
        OnTimer := ClickObject.TimerTimer;
        Interval := 1;
        Enabled := True;
      end;

    RestoreCursor;

    with Form do
      begin
        Left := (Screen.Width - Width) div 2;
        Top := (Screen.Height - Height) div 2;
        SetCurPosToCenter(Button);
        ShowModal;
      end;
  finally
    Form.Free;
    ClickObject.Free;
    lblMemory := nil;
    lblProc := nil;
    lblMemoryValue := nil;
    lblProcValue := nil;
  end;
end;

procedure TClickObject.Click(Sender: TObject);
begin
  ShowWaitCursor;
  try
    case TControl(Sender).Tag of
    1:  if MailAddress <> '' then
          ShellExecEx('mailto:' + MailAddress + '?subject=' + MailSubject, '')
        else
          MsgBox(TControl(Sender).Hint);
    2:  ShellExec(FileInAppDir(rsLicenses));
    end;
  finally
    RestoreCursor;
  end;
end;

procedure TClickObject.MouseEnter(Sender: TObject);
begin
  with TLabel(Sender).Font do
    begin
      Color := clHotLight;
      Style := Style + [fsUnderline];
    end;
end;

procedure TClickObject.MouseLeave(Sender: TObject);
begin
  with TLabel(Sender).Font do
    begin
      Color := clWindowText;
      Style := Style - [fsUnderline];
    end;
end;

procedure TClickObject.TimerTimer(Sender: TObject);
begin
  TTimer(Sender).Enabled := False;
  lblMemoryValue.Caption := GetTotalPhys;
  lblProcValue.Caption := GetCPUSpeed;
end;

end.
