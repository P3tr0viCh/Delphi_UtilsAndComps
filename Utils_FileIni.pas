unit Utils_FileIni;

interface

{$DEBUGINFO OFF}

uses Winapi.Windows, SysUtils, Controls, Classes, Forms, Graphics, IniFiles,
  System.Types;

resourcestring
  rsOptions     = 'Options';
  rsIsReadOnly  = '#P3TR0VICHTEMP#';
  rsINIReadOnly = 'Не удалось сохранить настройки, так как INI-файл "%s" доступен только для чтения';

type
  TFileIni = class(TIniFile)
  private
  public
    function  ReadString(const Section, Ident, Default: String): String; override;
    procedure WriteString(const Section, Ident, Value: String); override;
    procedure ReadSection(const Section: String; Strings: TStrings); override;
    procedure ReadSections(Strings: TStrings); override;
    procedure ReadSectionValues(const Section: String; Strings: TStrings); override;
    procedure EraseSection(const Section: String); override;
    procedure DeleteKey(const Section, Ident: String); override;
    procedure UpdateFile; override;

    function  ReadPoint(const Section, Ident: String; Default: TPoint): TPoint;
    procedure WritePoint(const Section, Ident: String; Value: TPoint);
    function  ReadRect(const Section, Ident: String; Default: TRect): TRect;
    procedure WriteRect(const Section, Ident: String; Value: TRect);

    procedure ReadBounds(const Control: TControl; const Section, Ident: String; Default: TRect);
    procedure WriteBounds(const Control: TControl; const Section, Ident: String);

    procedure ReadPosition(const Control: TControl; const Section, Ident: String);
    procedure WritePosition(const Control: TControl; const Section, Ident: String);

    procedure ReadFormBounds(const Form: TForm; Section: String = '');
    procedure WriteFormBounds(const Form: TForm; Section: String = '');

    procedure ReadFormPosition(const Form: TForm; Section: String = '');
    procedure WriteFormPosition(const Form: TForm; Section: String = '');

    procedure ReadFont(const Section, Ident: String; Value: TFont);
    procedure WriteFont(const Section, Ident: String; Value: TFont);

    procedure ReadSectionOnlyValues(const Section: string; Strings: TStrings);

    function IsReadOnly: Boolean;
  end;

function CreateINIFile(FileName: String = ''): TFileIni;

implementation

uses Utils_Misc, Utils_Str, Utils_Files;

function CreateINIFile(FileName: String = ''): TFileIni;
begin
  if FileName = '' then FileName := ChangeFileExt(Application.ExeName, '.ini')
  else
    begin
      if ExtractFileExt(FileName)  = '' then FileName := FileName + '.ini';
      if ExtractFilePath(FileName) = '' then FileName := FileInAppDir(FileName);
    end;
  Result := TFileIni.Create(FileName);
end;

function TFileIni.IsReadOnly: Boolean;
begin
  WriteString(rsIsReadOnly, rsIsReadOnly, rsIsReadOnly);
  Result := ReadString(rsIsReadOnly, rsIsReadOnly, 'XX') <> rsIsReadOnly;
  if not Result then EraseSection(rsIsReadOnly);
end;

procedure TFileIni.DeleteKey(const Section, Ident: String);
begin
  try
    inherited;
  except
  end;
end;

procedure TFileIni.EraseSection(const Section: string);
begin
  try
    inherited;
  except
  end;
end;

procedure TFileIni.ReadBounds(const Control: TControl; const Section, Ident: String; Default: TRect);
begin
  with Control, ReadRect(Section, Ident, Default) do
    SetBounds(Left, Top, Right, Bottom);
end;

procedure TFileIni.WriteBounds(const Control: TControl; const Section, Ident: String);
begin
  with Control do WriteRect(Section, Ident, Rect(Left, Top, Width, Height));
end;

procedure TFileIni.ReadPosition(const Control: TControl; const Section, Ident: String);
begin
  with Control, ReadPoint(Section, Ident, Point(Left, Top)) do
    SetBounds(X, Y, Width, Height);
end;

procedure TFileIni.WritePosition(const Control: TControl; const Section, Ident: String);
begin
  with Control do WritePoint(Section, Ident, Point(Left, Top));
end;

function TFileIni.ReadPoint(const Section, Ident: String; Default: TPoint): TPoint;
var
  PointStr: String;
begin
  PointStr := ReadString(Section, Ident, '');
  if PointStr = '' then Result := Default
  else
    try
      Result := StrToPoint(PointStr);
    except
      Result := Default;
    end;
end;

function TFileIni.ReadRect(const Section, Ident: String; Default: TRect): TRect;
var
  RectStr: String;
begin
  RectStr := ReadString(Section, Ident, '');
  if RectStr = '' then Result := Default
  else
    try
      Result := StrToRect(RectStr);
    except
      Result := Default;
    end;
end;

procedure TFileIni.ReadSection(const Section: string; Strings: TStrings);
begin
  try
    inherited;
  except
  end;
end;

procedure TFileIni.ReadSections(Strings: TStrings);
begin
  try
    inherited;
  except
  end;
end;

procedure TFileIni.ReadSectionValues(const Section: String; Strings: TStrings);
begin
  try
    inherited;
  except
  end;
end;

function TFileIni.ReadString(const Section, Ident, Default: String): String;
begin
  try
    Result := DelQuotes(inherited ReadString(Section, Ident, Default));
  except
    Result := Default;
  end;
end;

procedure TFileIni.WriteString(const Section, Ident, Value: String);
const
  BadChars1: TSysCharSet = ([' ', '=']);
  BadChars2: TSysCharSet = (['"', '''']);
var
  L: Integer;
  S: String;
begin
  S := Value;
  L := Length(S);
  if L > 0 then
    begin
      if CharInSet(S[1], BadChars1) or CharInSet(S[L], BadChars1) then
        S := AddQuotes(S)
      else
        if CharInSet(S[1], BadChars2) or CharInSet(S[L], BadChars2) then
          S := AddQuotes(S, DBLQUOTE + DBLQUOTE);
    end;
  try
    inherited WriteString(Section, Ident, S);
  except
  end;
end;

procedure TFileIni.UpdateFile;
begin
  try
    inherited;
  except
  end;
end;

procedure TFileIni.WritePoint(const Section, Ident: String; Value: TPoint);
begin
  WriteString(Section, Ident, PointToStr(Value));
end;

procedure TFileIni.WriteRect(const Section, Ident: String; Value: TRect);
begin
  WriteString(Section, Ident, RectToStr(Value));
end;

procedure TFileIni.ReadFormBounds(const Form: TForm; Section: String = '');
begin
  if Section = '' then Section := Form.Name;
  with Form do
    ReadBounds(Form, Section, 'Position',
      Rect((Screen.Width - Width) div 2, (Screen.Height - Height) div 2,
        Width, Height));
  Form.MakeFullyVisible();
  if ReadBool(Section, 'Maximized', False) then
    Form.WindowState := wsMaximized;
end;

procedure TFileIni.WriteFormBounds(const Form: TForm; Section: String = '');
begin
  if Section = '' then Section := Form.Name;
  if Form.WindowState = wsMaximized then
    WriteBool(Section, 'Maximized', True)
  else
    begin
      WriteBool(Section, 'Maximized', False);
      WriteBounds(Form, Section, 'Position');
    end;
end;

procedure TFileIni.ReadFormPosition(const Form: TForm; Section: String = '');
begin
  if Section = '' then Section := Form.Name;
  with Form do SetBounds((Screen.Width - Width) div 2,
    (Screen.Height - Height) div 2, Width, Height);
  ReadPosition(Form, Section, 'Position');
  Form.MakeFullyVisible;
end;

procedure TFileIni.WriteFormPosition(const Form: TForm; Section: String = '');
begin
  if Section = '' then Section := Form.Name;
  WritePosition(Form, Section, 'Position');
end;

procedure TFileIni.ReadSectionOnlyValues(const Section: string; Strings: TStrings);
var
  i: Integer;
begin
  Strings.Clear;
  ReadSectionValues(Section, Strings);
  for i := 0 to Strings.Count - 1 do
    Strings[i] := Copy(Strings[i], Pos('=', Strings[i]) + 1, MaxInt);
end;

procedure TFileIni.ReadFont(const Section, Ident: String; Value: TFont);
begin
  try
    StrToFont(ReadString(Section, Ident, ''), Value);
  except
  end;
end;

procedure TFileIni.WriteFont(const Section, Ident: String; Value: TFont);
begin
  WriteString(Section, Ident, FontToStr(Value));
end;

end.
