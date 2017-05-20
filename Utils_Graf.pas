unit Utils_Graf;

interface

{$DEBUGINFO OFF}

uses
  Winapi.Windows, Vcl.Forms, Winapi.Messages, SysUtils, Classes,
  Vcl.Graphics, Vcl.Menus, Vcl.Imaging.JPEG, Vcl.Themes, System.UITypes;

resourcestring
  rsExtBMP   = '.BMP';
  rsExtJPEG  = '.JPG';
  rsErrorExt = 'Неправильный формат файла (%s).'#13#10#13#10'Разрешено использовать только Bitmap (*.bmp) и JPEG (*.jpg)';

type
  TJPEGBitmap = class(TBitmap)
  public
    procedure LoadFromFile(const FileName: string); override;
    procedure LoadFromResourceName(Instance: THandle; const ResName: String);
  end;

const
  PaletteMask 	= $02000000;

  DefaultColorCount = 40;
  DefaultColors: array[0..DefaultColorCount - 1] of TIdentMapEntry = (
    (Value: $000000; Name: 'Черный'),
    (Value: $003399; Name: 'Коричневый'),
    (Value: $003333; Name: 'Оливковый'),
    (Value: $003300; Name: 'Темно-зеленый'),
    (Value: $663300; Name: 'Темно-сизый'),
    (Value: $800000; Name: 'Темно-синий'),
    (Value: $993333; Name: 'Индиго'),
    (Value: $333333; Name: 'Серый 80%'),

    (Value: $000080; Name: 'Темно красный'),
    (Value: $0066FF; Name: 'Оранжевый'),
    (Value: $008080; Name: 'Коричнево-зеленый'),
    (Value: $008000; Name: 'Зеленый'),
    (Value: $808000; Name: 'Сине-зеленый'),
    (Value: $FF0000; Name: 'Синий'),
    (Value: $996666; Name: 'Сизый'),
    (Value: $808080; Name: 'Серый 50%'),

    (Value: $0000FF; Name: 'Красный'),
    (Value: $0099FF; Name: 'Светло-оранжевый'),
    (Value: $00CC99; Name: 'Травяной'),
    (Value: $669933; Name: 'Изумрудный'),
    (Value: $CCCC33; Name: 'Темно-бирюзовый'),
    (Value: $FF6633; Name: 'Темно-голубой'),
    (Value: $800080; Name: 'Фиолетовый'),
    (Value: $969696; Name: 'Серый 40%'),

    (Value: $FF00FF; Name: 'Лиловый'),
    (Value: $00CCFF; Name: 'Золотистый'),
    (Value: $00FFFF; Name: 'Желтый'),
    (Value: $00FF00; Name: 'Ярко-зеленый'),
    (Value: $FFFF00; Name: 'Бирюзовый'),
    (Value: $FFCC00; Name: 'Голубой'),
    (Value: $663399; Name: 'Вишневый'),
    (Value: $C0C0C0; Name: 'Серый 25%'),

    (Value: $CC99FF; Name: 'Розовый'),
    (Value: $99CCFF; Name: 'Светло-коричневый'),
    (Value: $99FFFF; Name: 'Светло-желтый'),
    (Value: $CCFFCC; Name: 'Бледно-зеленый'),
    (Value: $FFFFCC; Name: 'Светло-бирюзовый'),
    (Value: $FFCC99; Name: 'Бледно-голубой'),
    (Value: $FF99CC; Name: 'Сиреневый'),
    (Value: $FFFFFF; Name: 'Белый'));

  SysColorCount = 27;
  SysColors: array[0..SysColorCount - 1] of TIdentMapEntry = (
    (Value: clScrollBar; Name: 'Полоса прокрутки'),
    (Value: clBackground; Name: 'Рабочий стол'),
    (Value: clActiveCaption; Name: 'Заголовок активного окна (цвет 1)'),
    (Value: clGradientActiveCaption; Name: 'Заголовок активного окна (цвет 2)'),
    (Value: clInactiveCaption; Name: 'Заголовок неактивного окна (цвет 1)'),
    (Value: clGradientInactiveCaption; Name: 'Заголовок неактивного окна (цвет 2)'),
    (Value: clMenu; Name: 'Строка меню'),
    (Value: clMenuText; Name: 'Текст меню'),
    (Value: clHighlight; Name: 'Выделенный пункт меню'),
    (Value: clHighlightText; Name: 'Текст выделенного пункта меню'),
    (Value: clWindow; Name: 'Окно'),
    (Value: clWindowFrame; Name: 'Рамка окна'),
    (Value: clWindowText; Name: 'Текст в окне'),
    (Value: clCaptionText; Name: 'Текст активного заголовка'),
    (Value: clInactiveCaptionText; Name: 'Текст неактивного заголовка'),
    (Value: clActiveBorder; Name: 'Граница активного окна'),
    (Value: clInactiveBorder; Name: 'Граница неактивного окна'),
    (Value: clAppWorkSpace; Name: 'Рабочая область приложения'),
    (Value: clBtnFace; Name: 'Рельефные объекты'),
    (Value: clBtnText; Name: 'Текст рельефных объектов'),
    (Value: clBtnShadow; Name: 'Тень рельефных объектов'),
    (Value: clBtnHighlight; Name: 'Выделение рельефных объектов'),
    (Value: clGrayText; Name: 'Текст недоступных объектов'),
    (Value: clInfoText; Name: 'Текст всплывающей подсказки'),
    (Value: clInfoBk; Name: 'Всплывающая подсказка'),
    (Value: cl3DDkShadow; Name: '3D тень'),
    (Value: cl3DLight; Name: '3D свет'));

  HTMLColorsCount = 140;
  HTMLColorsNames: array[0..HTMLColorsCount - 1] of String = (
    'Aliceblue', 'Antiquewhite', 'Aqua', 'Aquamarine', 'Azure',
    'Beige', 'Bisque', 'Black', 'Blanchedalmond', 'Blue',
    'Blueviolet', 'Brown', 'Burlywood', 'Cadetblue', 'Chartreuse',
    'Chocolate', 'Coral', 'Cornflowerblue', 'Cornsilk', 'Crimson',
    'Cyan', 'Darkblue', 'Darkcyan', 'Darkgoldenrod', 'Darkgray',
    'Darkgreen', 'Darkkhaki', 'Darkmagenta', 'Darkolivegreen', 'Darkorange',
    'Darkorchid', 'Darkred', 'Darksalmon', 'Darkseagreen', 'Darkslateblue',
    'Darkslategray', 'Darkturquoise', 'Darkviolet', 'Deeppink', 'Deepskyblue',
    'Dimgray', 'Dodgerblue', 'Firebrick', 'Floralwhite', 'Forestgreen',
    'Fuchsia', 'Gainsboro', 'Ghostwhite', 'Gold', 'Goldenrod',
    'Gray', 'Green', 'Greenyellow', 'Honeydew', 'Hotpink',
    'Indianred', 'Indigo', 'Ivory', 'Khaki', 'Lavendar',
    'Lavenderblush', 'Lawngreen', 'Lemonchiffon', 'Lightblue', 'Lightcoral',
    'Lightcyan', 'Lightgoldenrodyellow', 'Lightgreen', 'Lightgrey', 'Lightpink',
    'Lightsalmon', 'Lightseagreen', 'Lightskyblue', 'Lightslategray', 'Lightsteelblue',
    'Lightyellow', 'Lime', 'Limegreen', 'Linen', 'Magenta',
    'Maroon', 'Mediumauqamarine', 'Mediumblue', 'Mediumorchid', 'Mediumpurple',
    'Mediumseagreen', 'Mediumslateblue', 'Mediumspringgreen', 'Mediumturquoise', 'Mediumvioletred',
    'Midnightblue', 'Mintcream', 'Mistyrose', 'Moccasin', 'Navajowhite',
    'Navy', 'Oldlace', 'Olive', 'Olivedrab', 'Orange',
    'Orangered', 'Orchid', 'Palegoldenrod', 'Palegreen', 'Paleturquoise',
    'Palevioletred', 'Papayawhip', 'Peachpuff', 'Peru', 'Pink',
    'Plum', 'Powderblue', 'Purple', 'Red', 'Rosybrown',
    'Royalblue', 'Saddlebrown', 'Salmon', 'Sandybrown', 'Seagreen',
    'Seashell', 'Sienna', 'Silver', 'Skyblue', 'Slateblue',
    'Slategray', 'Snow', 'Springgreen', 'Steelblue', 'Tan',
    'Teal', 'Thistle', 'Tomato', 'Turquoise', 'Violet',
    'Wheat', 'White', 'Whitesmoke', 'Yellow', 'YellowGreen');

  HTMLColorsValues: array[0..HTMLColorsCount - 1] of String = (
    'F0F8FF', 'FAEBD7', '00FFFF', '7FFFD4', 'F0FFFF',
    'F5F5DC', 'FFE4C4', '000000', 'FFEBCD', '0000FF',
    '8A2BE2', 'A52A2A', 'DEB887', '5F9EA0', '7FFF00',
    'D2691E', 'FF7F50', '6495ED', 'FFF8DC', 'DC143C',
    '00FFFF', '00008B', '008B8B', 'B8860B', 'A9A9A9',
    '006400', 'BDB76B', '8B008B', '556B2F', 'FF8C00',
    '9932CC', '8B0000', 'E9967A', '8FBC8F', '483D8B',
    '2F4F4F', '00CED1', '9400D3', 'FF1493', '00BFFF',
    '696969', '1E90FF', 'B22222', 'FFFAF0', '228B22',
    'FF00FF', 'DCDCDC', 'F8F8FF', 'FFD700', 'DAA520',
    '808080', '008000', 'ADFF2F', 'F0FFF0', 'FF69B4',
    'CD5C5C', '4B0082', 'FFFFF0', 'F0E68C', 'E6E6FA',
    'FFF0F5', '7CFC00', 'FFFACD', 'ADD8E6', 'F08080',
    'E0FFFF', 'FAFAD2', '90EE90', 'D3D3D3', 'FFB6C1',
    'FFA07A', '20B2AA', '87CEFA', '778899', 'B0C4DE',
    'FFFFE0', '00FF00', '32CD32', 'FAF0E6', 'FF00FF',
    '800000', '66CDAA', '0000CD', 'BA55D3', '9370D8',
    '3CB371', '7B68EE', '00FA9A', '48D1CC', 'C71585',
    '191970', 'F5FFFA', 'FFE4E1', 'FFE4B5', 'FFDEAD',
    '000080', 'FDF5E6', '808000', '688E23', 'FFA500',
    'FF4500', 'DA70D6', 'EEE8AA', '98FB98', 'AFEEEE',
    'D87093', 'FFEFD5', 'FFDAB9', 'CD853F', 'FFC0CB',
    'DDA0DD', 'B0E0E6', '800080', 'FF0000', 'BC8F8F',
    '4169E1', '8B4513', 'FA8072', 'F4A460', '2E8B57',
    'FFF5EE', 'A0522D', 'C0C0C0', '87CEEB', '6A5ACD',
    '708090', 'FFFAFA', '00FF7F', '4682B4', 'D2B48C',
    '008080', 'D8BFD8', 'FF6347', '40E0D0', 'EE82EE',
    'F5DEB3', 'FFFFFF', 'F5F5F5', 'FFFF00', '9ACD32');

type
  TFillDirection = (fdTopToBottom, fdBottomToTop, fdLeftToRight, fdRightToLeft);

function  CreateBitmapRgn(Bitmap: TBitmap; TransColor: TColor): HRGN;

procedure Line(ACanvas: TCanvas; X1, Y1, X2, Y2: Integer);
procedure GradientFill2(ACanvas: TCanvas; StartColor, EndColor: TColor;
  ALeft, ATop, AWidth, AHeight: Integer; FillDirection: TFillDirection);
procedure DrawTextAngle(ACanvas: TCanvas; X, Y: Integer; Angle: Integer; S: String);

function  HTMLColorNameToHTMLColorValue(HTMLColor: String; var HTMLColorValue: String): Boolean;
function  HTMLColorValueToHTMLColorName(HTMLColorValue: String; var HTMLColor: String): Boolean;
function  ColorToHTMLColor(Color: TColor): String;
function  HTMLColorToColor(HTMLColor: String): TColor;

function  PaletteColor(Color: TColor): Longint;
procedure StretchBltTransparent(DstDC: HDC; DstX, DstY, DstW, DstH: Integer;
  SrcDC: HDC; SrcX, SrcY, SrcW, SrcH: Integer; Palette: HPalette; TransparentColor: TColorRef);
procedure StretchBitmapTransparent(Dest: TCanvas; Bitmap: TBitmap;
  TransparentColor: TColor; DstX, DstY, DstW, DstH, SrcX, SrcY, SrcW, SrcH: Integer);
procedure DrawBitmapTransparent(Dest: TCanvas; DstX, DstY: Integer; Bitmap: TBitmap; TransparentColor: TColor);

procedure FillOpacity(Canvas: TCanvas; DestRect: TRect; FillColor: TColor);
procedure FillFullRect(Bitmap: TBitmap; FillColor: TColor);

procedure TileCanvas(Canvas, TileCanvas: TCanvas; Width, Height, TileWidth, TileHeight: Integer);
procedure TileBitmap(Bitmap, TileBitmap: TBitmap);
procedure TileBitmapOnForm(Form: TForm; TileBitmap: TBitmap);

procedure ResizeRect(const RealWidth, RealHeight: Integer; var NewWidth, NewHeight: Integer);
procedure ResizeBitmap(Bitmap: TBitmap; var NewWidth, NewHeight: Integer; UpdateBounds: Boolean);

procedure XPMenuItem_Draw(Sender: TObject; MenuBMP: TBitmap; ACanvas: TCanvas; ARect: TRect;
  State: TOwnerDrawState; CheckBox: Boolean = False; Disabled: Boolean = False);
procedure XPMenuItem_DrawLine(Sender: TObject; MenuBMP: TBitmap; ACanvas: TCanvas; ARect: TRect; Dot: Boolean = True);
procedure XPMenuItem_Measure(Sender: TObject; MenuBMP: TBitmap; var Width, Height: Integer);

procedure DrawBorder(Canvas: TCanvas; Height, Width: Integer; BorderColor: TColor;
  BorderWidth: Byte = 1; TransColor: TColor = clBlue);

function AverageColor(FirstColor, SecondColor: TColor): TColor;
function InvertColor(Color: TColor): TColor;
function IsLightColor(Color: TColor): Boolean;
function GetLightColor(Color: TColor): TColor;

procedure LoadJPEGFromResource(Picture: TPicture; Instance: THandle; const ResName: String);
procedure LoadJPEGFromFileName(Bitmap: TBitmap; const FileName: String);

implementation

uses Utils_Str, Utils_Misc, Types;

function CreateBitmapRgn(Bitmap: TBitmap; TransColor: TColor): HRGN;
var
  X, Y: Integer;
  XStart: Integer;
begin
  Result := 0;
  with Bitmap do
    for Y := 0 to Height - 1 do
      begin
        X := 0;
        while X < Width do
          begin
            while (X < Width) and (Canvas.Pixels[X, Y] = TransColor) do Inc(X);
            if X >= Width then Break;
            XStart := X;
            while (X < Width) and (Canvas.Pixels[X, Y] <> TransColor) do Inc(X);
            if Result = 0 then
              Result := CreateRectRgn(XStart, Y, X, Y + 1)
            else
              CombineRgn(Result, Result,
            CreateRectRgn(XStart, Y, X, Y + 1), RGN_OR);
            ProcMess;
          end;
      end;
end;

procedure Line(ACanvas: TCanvas; X1, Y1, X2, Y2: Integer);
begin
  with ACanvas do
    begin
      MoveTo(X1, Y1);
      LineTo(X2, Y2);
    end;
end;

procedure GradientFill2(ACanvas: TCanvas; StartColor, EndColor: TColor;
  ALeft, ATop, AWidth, AHeight: Integer; FillDirection: TFillDirection);
var
  X, C1, C2, R1, G1, B1: Integer;
  DR, DG, DB, DH: Real;
begin
  with ACanvas do
    begin
      Brush.Style := bsSolid;
      if FillDirection in [fdTopToBottom, fdBottomToTop] then
        begin
          DH := (AHeight - ATop)/ 256;
          if FillDirection = fdTopToBottom then
            begin
              C1 := ColorToRGB(StartColor);
              C2 := ColorToRGB(EndColor);
            end
          else
            begin
              C1 := ColorToRGB(EndColor);
              C2 := ColorToRGB(StartColor);
          end;
          R1 := GetRValue(C1);
          G1 := GetGValue(C1);
          B1 := GetBValue(C1);
          DR := (GetRValue(C2) - R1) / 256;
          DG := (GetGValue(C2) - G1) / 256;
          DB := (GetBValue(C2) - B1) / 256;
          for X := 0 to 255 do
            begin
              Brush.Color := RGB(R1 + Round(DR * X),
                G1 + Round(DG * X), B1 + Round(DB * X));
              FillRect(Rect(ALeft,  ATop + Round(X * DH),
                AWidth, ATop + Round((X + 1) * DH)));
            end;
        end
      else // if FillDirection in [fdTopToBottom, fdBottomToTop]
      if FillDirection in [fdLeftToRight, fdRightToLeft] then
        begin
        DH := (AWidth - ALeft)/ 256;
        if FillDirection = fdLeftToRight then
          begin
            C1 := ColorToRGB(StartColor);
            C2 := ColorToRGB(EndColor);
          end
        else
          begin
            C1 := ColorToRGB(EndColor);
            C2 := ColorToRGB(StartColor);
          end;
        R1 := GetRValue(C1);
        G1 := GetGValue(C1);
        B1 := GetBValue(C1);
        DR := (GetRValue(C2) - R1) / 256;
        DG := (GetGValue(C2) - G1) / 256;
        DB := (GetBValue(C2) - B1) / 256;
        for X := 0 to 255 do
          begin
            Brush.Color := RGB(R1 + Round(DR * X),
              G1 + Round(DG * X), B1 + Round(DB * X));
            FillRect(Rect(ALeft + Round(X * DH), ATop,
              ALeft + Round((X + 1) * DH), AHeight));
          end;
        end; // if FillDirection in [fdLeftToRight, fdRightToLeft]
    end;
end;

procedure DrawTextAngle(ACanvas: TCanvas;
	X, Y: Integer; Angle: Integer; S: String);
var
  lf: TLogFont;
  hFnt, hOldFnt: HFont;
begin
  with ACanvas do
    begin
      FillChar(lf, SizeOf(lf), 0);
      StrPCopy(lf.lfFaceName, Font.Name);
      lf.lfCharSet := Font.Charset;
      lf.lfHeight := Font.Height;
      if fsBold in Font.Style then lf.lfWeight := fw_Bold
                              else lf.lfWeight := fw_Normal;
      lf.lfItalic := Integer(fsItalic in Font.Style);
      lf.lfUnderline := Integer(fsUnderline in Font.Style);
      lf.lfStrikeOut := Integer(fsStrikeout in Font.Style);
      lf.lfEscapement := Angle * 10;
      hFnt := CreateFontIndirect(lf);
      hOldFnt := SelectObject(Handle, hFnt);
      SetTextColor(Handle, ColorToRGB(Font.Color));
      SetBkMode(Handle, Transparent);
      TextOut(X, Y, S);
      SelectObject(Handle, hOldFnt);
      DeleteObject(hFnt);
    end;
end;

function  HTMLColorNameToHTMLColorValue(HTMLColor: String; var HTMLColorValue: String): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to HTMLColorsCount - 1 do
    if SameText(HTMLColorsNames[i], HTMLColor) then
      begin
        Result := True;
        HTMLColorValue := HTMLColorsValues[i];
        Exit;
      end;
end;

function  HTMLColorValueToHTMLColorName(HTMLColorValue: String; var HTMLColor: String): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to HTMLColorsCount - 1 do
    if SameText(HTMLColorsValues[i], HTMLColorValue) then
      begin
        Result := True;
        HTMLColor := HTMLColorsNames[i];
        Exit;
      end;
end;

function ColorToHTMLColor(Color: TColor): String;
var
  RGBColor: TColorRef;
begin
  RGBColor := ColorToRGB(Color);
  Result := Format('%.2x%.2x%.2x',
    [GetRValue(RGBColor), GetGValue(RGBColor), GetBValue(RGBColor)]);
  HTMLColorValueToHTMLColorName(Result, Result);
end;

function  HTMLColorToColor(HTMLColor: String): TColor;
begin
  if HTMLColor = '' then begin Result := clBlack; Exit; end;
  HTMLColorNameToHTMLColorValue(HTMLColor, HTMLColor);
  HTMLColor := '$00' + Copy(HTMLColor, 5, 2) +
    Copy(HTMLColor, 3, 2) + Copy(HTMLColor, 1, 2);
  Result := StrToIntDef(HTMLColor, clBlack);
end;

function PaletteColor(Color: TColor): Longint;
begin
  Result := ColorToRGB(Color) or PaletteMask;
end;

procedure StretchBltTransparent(DstDC: HDC; DstX, DstY, DstW, DstH: Integer;
  SrcDC: HDC; SrcX, SrcY, SrcW, SrcH: Integer; Palette: HPalette;
  TransparentColor: TColorRef);
var
  Color: TColorRef;
  bmAndBack, bmAndObject, bmAndMem, bmSave: HBitmap;
  bmBackOld, bmObjectOld, bmMemOld, bmSaveOld: HBitmap;
  MemDC, BackDC, ObjectDC, SaveDC: HDC;
  palDst, palMem, palSave, palObj: HPalette;
begin
  BackDC := CreateCompatibleDC(DstDC);
  ObjectDC := CreateCompatibleDC(DstDC);
  MemDC := CreateCompatibleDC(DstDC);
  SaveDC := CreateCompatibleDC(DstDC);
  bmAndObject := CreateBitmap(SrcW, SrcH, 1, 1, nil);
  bmAndBack := CreateBitmap(SrcW, SrcH, 1, 1, nil);
  bmAndMem := CreateCompatibleBitmap(DstDC, DstW, DstH);
  bmSave := CreateCompatibleBitmap(DstDC, SrcW, SrcH);
  bmBackOld := SelectObject(BackDC, bmAndBack);
  bmObjectOld := SelectObject(ObjectDC, bmAndObject);
  bmMemOld := SelectObject(MemDC, bmAndMem);
  bmSaveOld := SelectObject(SaveDC, bmSave);
  palDst := 0; palMem := 0; palSave := 0; palObj := 0;
  if Palette <> 0 then
    begin
      palDst := SelectPalette(DstDC, Palette, True);
      RealizePalette(DstDC);
      palSave := SelectPalette(SaveDC, Palette, False);
      RealizePalette(SaveDC);
      palObj := SelectPalette(ObjectDC, Palette, False);
      RealizePalette(ObjectDC);
      palMem := SelectPalette(MemDC, Palette, True);
      RealizePalette(MemDC);
    end;
  SetMapMode(SrcDC, GetMapMode(DstDC));
  SetMapMode(SaveDC, GetMapMode(DstDC));
  BitBlt(SaveDC, 0, 0, SrcW, SrcH, SrcDC, SrcX, SrcY, SRCCOPY);
  Color := SetBkColor(SaveDC, PaletteColor(TransparentColor));
  BitBlt(ObjectDC, 0, 0, SrcW, SrcH, SaveDC, 0, 0, SRCCOPY);
  SetBkColor(SaveDC, Color);
  BitBlt(BackDC, 0, 0, SrcW, SrcH, ObjectDC, 0, 0, NOTSRCCOPY);
  BitBlt(MemDC, 0, 0, DstW, DstH, DstDC, DstX, DstY, SRCCOPY);
  StretchBlt(MemDC, 0, 0, DstW, DstH, ObjectDC, 0, 0, SrcW, SrcH, SRCAND);
  BitBlt(SaveDC, 0, 0, SrcW, SrcH, BackDC, 0, 0, SRCAND);
  StretchBlt(MemDC, 0, 0, DstW, DstH, SaveDC, 0, 0, SrcW, SrcH, SRCPAINT);
  BitBlt(DstDC, DstX, DstY, DstW, DstH, MemDC, 0, 0, SRCCOPY);
  if Palette <> 0 then
    begin
      SelectPalette(MemDC, palMem, False);
      SelectPalette(ObjectDC, palObj, False);
      SelectPalette(SaveDC, palSave, False);
      SelectPalette(DstDC, palDst, True);
    end;
  DeleteObject(SelectObject(BackDC, bmBackOld));
  DeleteObject(SelectObject(ObjectDC, bmObjectOld));
  DeleteObject(SelectObject(MemDC, bmMemOld));
  DeleteObject(SelectObject(SaveDC, bmSaveOld));
  DeleteDC(MemDC);
  DeleteDC(BackDC);
  DeleteDC(ObjectDC);
  DeleteDC(SaveDC);
end;

procedure StretchBitmapTransparent(Dest: TCanvas; Bitmap: TBitmap;
  TransparentColor: TColor; DstX, DstY, DstW, DstH, SrcX, SrcY,
  SrcW, SrcH: Integer);
var
  CanvasChanging: TNotifyEvent;
  Temp: TBitmap;
begin
  if DstW <= 0 then DstW := Bitmap.Width;
  if DstH <= 0 then DstH := Bitmap.Height;
  if (SrcW <= 0) or (SrcH <= 0) then
    begin
      SrcX := 0; SrcY := 0;
      SrcW := Bitmap.Width;
      SrcH := Bitmap.Height;
    end;
  if not Bitmap.Monochrome then
    SetStretchBltMode(Dest.Handle, STRETCH_DELETESCANS);
  CanvasChanging := Bitmap.Canvas.OnChanging;
  try
    Bitmap.Canvas.OnChanging := nil;
    Temp := Bitmap;
    if TransparentColor = clNone then
      begin
        StretchBlt(Dest.Handle, DstX, DstY, DstW, DstH, Temp.Canvas.Handle,
          SrcX, SrcY, SrcW, SrcH, Dest.CopyMode);
      end
    else
      begin
        if Temp.Monochrome then TransparentColor := clWhite
        else TransparentColor := ColorToRGB(TransparentColor);
    StretchBltTransparent(Dest.Handle, DstX, DstY, DstW, DstH,
      Temp.Canvas.Handle, SrcX, SrcY, SrcW, SrcH, Temp.Palette,
      TransparentColor);
    end;
  finally
    Bitmap.Canvas.OnChanging := CanvasChanging;
  end;
end;

procedure DrawBitmapTransparent(Dest: TCanvas; DstX, DstY: Integer;
  Bitmap: TBitmap; TransparentColor: TColor);
begin
  StretchBitmapTransparent(Dest, Bitmap, TransparentColor, DstX, DstY,
    Bitmap.Width, Bitmap.Height, 0, 0, Bitmap.Width, Bitmap.Height);
end;

procedure XPMenuItem_Draw(Sender: TObject; MenuBMP: TBitmap; ACanvas: TCanvas; ARect: TRect;
	State: TOwnerDrawState; CheckBox: Boolean = False; Disabled: Boolean = False);
// ver. 2.0 from 2006.05.05
var
  MenuItem: TMenuItem;
  Selected: Boolean;
  TopLevel: Boolean;
  MenuBMPWidth: Integer;

  procedure FillSelectedRect(FllRect: TRect);
  begin
    Inc(FllRect.Left, MenuBMPWidth);
    ACanvas.FillRect(FllRect);
  end;

  procedure DoDrawText(TxtRect: TRect);
  var
    P: Integer;
    S1, S2: String;
    OldColor: TColor;

    procedure SubDrawText(Text: String; Left: Boolean);
    var
      Flags: UINT;
    begin
      if Left then Flags := DT_LEFT else Flags := DT_RIGHT;
      Flags := Flags or DT_SINGLELINE or DT_VCENTER or DT_EXPANDTABS;
      if IsWin2KOrGreat and (odNoAccel in State) then
        Flags := Flags or DT_HIDEPREFIX;
      DrawText(ACanvas.Handle, PChar(Text), -1, TxtRect, Flags);
    end;
  begin
    with MenuItem, ACanvas do
    begin
    if not (Enabled or Disabled) then Font.Color := clGrayText;
    if Disabled then Font.Color := clBlack;
    if Default then Font.Style := [fsBold];
    if TopLevel then
      Inc(TxtRect.Left, 7)
    else
      Inc(TxtRect.Left, MenuBMPWidth + 10);
    P := Pos(TAB, Caption);
    if P = 0 then
      begin
        S1 := Caption;
        if ShortCut = 0 then S2 := '' else S2 := ShortCutToText(ShortCut);
      end
    else
      begin
        S1 := Copy(Caption, 1, P);
        S2 := Copy(Caption, P + 1, MAXINT);
      end;
    Brush.Style := bsClear;
    if not (Enabled or Disabled) then
      begin
        OldColor := Font.Color;
        Font.Color := clBtnHighlight;
        OffsetRect(TxtRect, 1, 1);
        SubDrawText(S1, True);
        if S2 <> '' then
          begin
            Dec(TxtRect.Right, 15);
            SubDrawText(S2, False);
            Inc(TxtRect.Right, 15);
          end;
        OffsetRect(TxtRect, -1, -1);
        Font.Color := OldColor;
      end;
    SubDrawText(S1, True);
    if S2 <> '' then
      begin
        Dec(TxtRect.Right, 15);
        SubDrawText(S2, False);
      end;
    end;
  end;

  procedure DoDrawIcon(IcnRect: TRect);
  var
    State: Integer;
    Detail: TThemedButton;
    Details: TThemedElementDetails;

    procedure ImageListDraw(IcnRect: TRect);
    begin
      with MenuItem do
        begin
          if GetImageList = nil then Exit;
          if Selected and Enabled and not (Checked or Disabled) then
            begin
              Dec(IcnRect.Left); Dec(IcnRect.Top);
              GetImageList.Draw(ACanvas, IcnRect.Left, IcnRect.Top,
                ImageIndex, False);
            end;
          GetImageList.Draw(ACanvas, IcnRect.Left, IcnRect.Top,
            ImageIndex, Enabled or Disabled);
        end;
    end;
  begin
    with IcnRect do
      begin
        Top := Top + (MenuBMP.Height - 16) div 2 - 1;
        Bottom := Top + 16;
        Left := Left + (MenuBMPWidth - 16) div 2 - 1;
        Right := Left + 16;
      end;
    with MenuItem do
      begin
        if (Checked or RadioItem or CheckBox) and (ImageIndex = -1) then
          begin
            if StyleServices.Enabled then
              begin
                if RadioItem then
                  begin
                    if Checked then
                      begin
                        if Enabled then
                          begin
                            if Selected then Detail := tbRadioButtonCheckedHot
                                        else Detail := tbRadioButtonCheckedNormal;
                          end
                        else
                          begin
                            Detail := tbRadioButtonCheckedDisabled;
                          end
                      end
                    else // if Checked then
                      begin
                        if Enabled then
                          begin
                            if Selected then Detail := tbRadioButtonUncheckedHot
                                        else Detail := tbRadioButtonUncheckedNormal;
                          end
                        else
                          begin
                            Detail := tbRadioButtonUncheckedDisabled;
                          end;
                      end;
                  end
                else // if RadioItem then
                  begin
                    if Checked then
                      begin
                        if Enabled then
                          begin
                            if Selected then Detail := tbCheckBoxCheckedHot
                                        else Detail := tbCheckBoxCheckedNormal;
                          end
                        else
                          begin
                            Detail := tbCheckBoxCheckedDisabled;
                          end
                      end
                    else // if Checked then
                      begin
                        if Enabled then
                          begin
                            if Selected then Detail := tbCheckBoxUncheckedHot
                                        else Detail := tbCheckBoxUncheckedNormal;
                          end
                        else
                          begin
                            Detail := tbCheckBoxUncheckedDisabled;
                          end;
                      end;
                  end;
                Details := StyleServices.GetElementDetails(Detail);
                StyleServices.DrawElement(ACanvas.Handle, Details, IcnRect);
              end
            else // // if StyleServices.Enabled then
              begin
                if RadioItem then State := DFCS_BUTTONRADIO
                             else State := DFCS_BUTTONCHECK;
                if Selected then State := State or DFCS_HOT;
                if Checked then State := State or DFCS_CHECKED;
                if not Enabled then State := State or DFCS_INACTIVE;
                DrawFrameControl(ACanvas.Handle, IcnRect, DFC_BUTTON, State);
              end;
          end
        else // if (Checked or RadioItem or CheckBox)
          ImageListDraw(IcnRect);
      end;
  end;

  procedure DoSelectedRect(SelRect: TRect);
  begin
    if not TopLevel then Inc(SelRect.Left, MenuBMPWidth - 1);
    ACanvas.FrameRect(SelRect);
  end;

  procedure DoCheckedRect(ChkRect: TRect);
  begin
    if (MenuItem.ImageIndex = -1) or CheckBox then Exit;
    Inc(ChkRect.Left, 2);
    Inc(ChkRect.Top);
    Dec(ChkRect.Bottom);
    ChkRect.Right := 23;
    ACanvas.FrameRect(ChkRect);
  end;

  procedure DoDrawLeftRect(LftRect: TRect);
  begin
    if TopLevel then Exit;
    LftRect.Right := LftRect.Left + MenuBMPWidth;
    ACanvas.CopyRect(LftRect, MenuBMP.Canvas,
      Rect(0, 0, MenuBMPWidth, MenuBMP.Height));
  end;

begin
  MenuItem := Sender as TMenuItem;
  Selected := odSelected in State;
  TopLevel := MenuItem.GetParentComponent is TMainMenu;
  if TopLevel then MenuBMPWidth := 0 else MenuBMPWidth := MenuBMP.Width;
  if Disabled then
    begin
      ACanvas.Brush.Color := clSkyBlue;
      FillSelectedRect(ARect);
      DoDrawText(ARect);
      DoDrawLeftRect(ARect);
      DoDrawIcon(ARect);
    end
  else
  begin
    if Selected and MenuItem.Enabled then ACanvas.Brush.Color := clHighlight
    else
      begin
        if MenuItem.Default then ACanvas.Brush.Color := clMoneyGreen
        else
          if TopLevel then ACanvas.Brush.Color := clMenuBar
          else ACanvas.Brush.Color := clMenu;
      end;
    FillSelectedRect(ARect);
    DoDrawText(ARect);
    DoDrawLeftRect(ARect);
    DoDrawIcon(ARect);
    ACanvas.Brush.Color := clBlack;
    if Selected then DoSelectedRect(ARect);
    if MenuItem.Checked then DoCheckedRect(ARect);
  end;
end;

procedure XPMenuItem_DrawLine(Sender: TObject; MenuBMP: TBitmap;
  ACanvas: TCanvas; ARect: TRect; Dot: Boolean = True);
begin
  with ACanvas, ARect do
    begin
      if Dot then Pen.Style := psDot;
      Brush.Color := clMenu;
      FillRect(ARect);
      Pen.Color := clBtnShadow;
      Line(ACanvas, Left + MenuBMP.Width + 10, Top + 1, Right - 10, Top + 1);
      ARect.Right := ARect.Left + MenuBMP.Width;
      ACanvas.CopyRect(ARect, MenuBMP.Canvas, Rect(0, 0, MenuBMP.Width, 3));
    end;
end;

procedure XPMenuItem_Measure(Sender: TObject; MenuBMP: TBitmap; var Width, Height: Integer);
begin
  Inc(Width, MenuBMP.Width);
  if TMenuItem(Sender).GetImageList = nil then Inc(Width, MenuBMP.Width);
  if TMenuItem(Sender).IsLine then Height := 3 else Height := MenuBMP.Height;
end;

procedure DrawBorder(Canvas: TCanvas; Height, Width: Integer; BorderColor: TColor;
  BorderWidth: Byte = 1; TransColor: TColor = clBlue);
var
  Col, Row: Integer;

  procedure SubDrawBorder(i, j: Integer);
  var
    x, y: Integer;

    procedure ChangePixel(i, j: Integer);
    begin
      with Canvas do
        if Pixels[i, j] = TransColor then Pixels[i, j] := BorderColor;
    end;

  begin
    for x := i - BorderWidth to i + BorderWidth do
    for y := j - BorderWidth to j + BorderWidth do ChangePixel(x, y);
  end;

begin
  with Canvas do
    for Row := BorderWidth to Height - BorderWidth - 1 do
      for Col := BorderWidth to Width - BorderWidth - 1 do
        if (Pixels[Col, Row] <> TransColor) and
           (Pixels[Col, Row] <> BorderColor) then
          begin
            SubDrawBorder(Col, Row);
            ProcMess;
          end;
end;

function AverageColor(FirstColor, SecondColor: TColor): TColor;
begin
  Result := RGB((GetRValue(FirstColor) + GetRValue(SecondColor)) div 2,
    (GetGValue(FirstColor) + GetGValue(SecondColor)) div 2,
    (GetBValue(FirstColor) + GetBValue(SecondColor)) div 2);
end;

function InvertColor(Color: TColor): TColor;
begin
  Result := RGB(255 - GetRValue(Color), 255 - GetGValue(Color), 255 - GetBValue(Color));;
end;

function IsLightColor(Color: TColor): Boolean;
begin
  Result := (GetRValue(Color) <= GetRValue(clRed))   and
    (GetGValue(Color) <= GetGValue(clGreen)) and
    (GetBValue(Color) <= GetBValue(clBlue));
end;

function GetLightColor(Color: TColor): TColor;
begin
  if IsLightColor(Color) then Result := clWhite else Result := clBlack;
end;

procedure LoadJPEGFromResource(Picture: TPicture; Instance: THandle; const ResName: String);
var
  Stream: TCustomMemoryStream;
  JPEGImage: TJPEGImage;
begin
  Stream := TResourceStream.Create(Instance, ResName, PChar('JPEG'));
  JPEGImage := TJPEGImage.Create;
  try
    JPEGImage.LoadFromStream(Stream);
    Picture.Assign(JPEGImage);
  finally
    JPEGImage.Free;
    Stream.Free;
  end;
end;

procedure LoadJPEGFromFileName(Bitmap: TBitmap; const FileName: String);
var
  Picture: TPicture;
  TempBitmap: TBitmap;
begin
  Picture := TPicture.Create;
  TempBitmap := TBitmap.Create;
  try
    TempBitmap.PixelFormat := Bitmap.PixelFormat;
    Picture.LoadFromFile(FileName);
    TempBitmap.Width := Picture.Graphic.Width;
    TempBitmap.Height := Picture.Graphic.Height;
    TempBitmap.Canvas.Draw(0, 0, Picture.Graphic);
    Bitmap.Assign(TempBitmap);
  finally
    TempBitmap.Free;
    Picture.Free;
  end;
end;

procedure TJPEGBitmap.LoadFromFile(const FileName: string);
var
  FileExt: String;
  OldOnChange: TNotifyEvent;
begin
  ShowWaitCursor;
  OldOnChange := OnChange;
  OnChange := nil;
  PixelFormat := pf32bit;
  try
    if not FileExists(FileName) then
      begin
        ReleaseHandle;
        Exit;
      end;
    FileExt := UpperCase(ExtractFileExt(FileName));
    if FileExt = rsExtBMP then inherited LoadFromFile(FileName)
    else
      if FileExt = rsExtJPEG then LoadJPEGFromFileName(Self, FileName)
      else
        MsgBoxErr(Format(rsErrorExt, [FileExt]));
  finally
    OnChange := OldOnChange;
    RestoreCursor;
    Changed(Self);
  end;
end;

procedure TJPEGBitmap.LoadFromResourceName(Instance: THandle; const ResName: String);
begin
//  LoadJPEGFromResource(Self, Instance, ResName);
end;

procedure FillOpacity(Canvas: TCanvas; DestRect: TRect; FillColor: TColor);
var
  i, j: Integer;
begin
  with Canvas, DestRect do
    for j := Top to Bottom do
      for i := Left to Right do
        if Odd(i) xor Odd(j) then Pixels[i, j] := FillColor;
end;

procedure FillFullRect(Bitmap: TBitmap; FillColor: TColor);
var
  OldColor: TColor;
begin
  with Bitmap.Canvas do
    begin
      OldColor := Brush.Color;
      Brush.Color := FillColor;
      FillRect(Rect(0, 0, Bitmap.Width, Bitmap.Height));
      Brush.Color := OldColor;
    end;
end;

procedure TileCanvas(Canvas, TileCanvas: TCanvas; Width, Height, TileWidth, TileHeight: Integer);
var
  R1, R2: TRect;
begin
  if (Width = 0) or (Height = 0) or (TileWidth = 0) or (TileHeight = 0) then Exit;
  R1 := Rect(0, 0, TileWidth, TileHeight);
  R2 := Rect(0, 0, TileWidth, TileHeight);
  while R1.Top < Height do
    begin
      OffsetRect(R1, -R1.Left, 0);
      while R1.Left < Width do
        begin
          Canvas.CopyRect(R1, TileCanvas, R2);
          OffsetRect(R1, TileWidth, 0);
        end;
      OffsetRect(R1, 0, TileHeight);
    end;
end;

procedure TileBitmap(Bitmap, TileBitmap: TBitmap);
begin
  TileCanvas(Bitmap.Canvas, TileBitmap.Canvas,
    Bitmap.Width, Bitmap.Height, TileBitmap.Width, TileBitmap.Height);
end;

procedure TileBitmapOnForm(Form: TForm; TileBitmap: TBitmap);
begin
  TileCanvas(Form.Canvas, TileBitmap.Canvas,
    Form.ClientWidth, Form.ClientHeight, TileBitmap.Width, TileBitmap.Height);
end;

procedure ResizeRect(const RealWidth, RealHeight: Integer; var NewWidth, NewHeight: Integer);
var
  w, h, cw, ch: Integer;
  xyaspect: Double;
begin
  w := RealWidth;
  h := RealHeight;
  cw := NewWidth;
  ch := NewHeight;
  if ((w > cw) or (h > ch)) and (w > 0) and (h > 0) then
    begin
      xyaspect := w / h;
      if w > h then
        begin
          w := cw;
          h := Trunc(cw / xyaspect);
          if h > ch then begin h := ch; w := Trunc(ch * xyaspect); end;
        end
      else
        begin
          h := ch;
          w := Trunc(ch * xyaspect);
          if w > cw then begin w := cw; h := Trunc(cw / xyaspect); end;
        end;
    end;
  NewWidth := w;
  NewHeight := h;
end;

procedure ResizeBitmap(Bitmap: TBitmap; var NewWidth, NewHeight: Integer; UpdateBounds: Boolean);
var
  TempBitmap: TBitmap;

  function GetRect: TRect;
  begin
    Result := Rect(0, 0, NewWidth, NewHeight);
    OffsetRect(Result, (Bitmap.Width - NewWidth) div 2,
      (Bitmap.Height - NewHeight) div 2);
  end;
begin
  TempBitmap := TBitmap.Create;
  try
    TempBitmap.Assign(Bitmap);
    Bitmap.Width := NewWidth;
    Bitmap.Height := NewHeight;
    ResizeRect(TempBitmap.Width, TempBitmap.Height, NewWidth, NewHeight);
    if UpdateBounds then
      begin
        Bitmap.Width := NewWidth;
        Bitmap.Height := NewHeight;
      end
    else
      FillFullRect(Bitmap, clBlack);
    if TempBitmap.Empty then Exit;
    Bitmap.Canvas.StretchDraw(GetRect, TempBitmap);
  finally
    TempBitmap.Free;
  end;
end;

end.
