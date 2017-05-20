unit GradPanel; {Matt}

interface

uses
	Winapi.Windows, Winapi.Messages, SysUtils, Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Utils_Graf;

type
	TTextPosition = (tpTopLeft, tpTopCentre, tpTopRight,
                     tpLeftUp, tpLeftDown, tpCentre, tpRightUp, tpRightDown,
                     tpCentreUp, tpCentreDown,
                     tpBottomLeft, tpBottomCentre, tpBottomRight, tpUser);

	TGradientPanel = class(TCustomPanel)
	private
   	FNotPaint: Boolean;
		FFillDirection: TFillDirection;
		FStartColor, FEndColor: TColor;
		FTextPosition: TTextPosition;
		FTextX, FTextY, FTextAngle: Integer;
		procedure SetEndColor(col: TColor);
		procedure SetFillDirection(dir: TFillDirection);
		procedure SetStartColor(col: TColor);
		procedure SetTextPosition(pos: TTextPosition);
		procedure SetTextX(x: Integer);
		procedure SetTextY(y: Integer);
		procedure SetTextAngle(a: Integer);
	protected
		procedure Paint; override;
		procedure CMFontChanged (var Message: TMessage); message CM_FONTCHANGED;
		procedure CMTextChanged (var Message: TMessage); message CM_TEXTCHANGED;
	public
		constructor Create(aOwner: TComponent); override;
		procedure StartUpdate;
      procedure EndUpdate; 
      property Canvas;
	published
		property ColorEnd: TColor read FEndColor write SetEndColor;
		property FillDirection: TFillDirection read FFillDirection write SetFillDirection;
		property ColorStart: TColor read FStartColor write SetStartColor;
		property TextX: Integer read FTextX write SetTextX;
		property TextY: Integer read FTextY write SetTextY;
		property TextAngle: Integer read FTextAngle write SetTextAngle;
		property TextPosition: TTextPosition read FTextPosition write SetTextPosition;

    property Align;
    property Anchors;
    property AutoSize;
    property BiDiMode;
    property BorderStyle;
    property Caption;
    property Constraints;
    property Ctl3D;
    property UseDockManager default True;
    property DockSite;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property FullRepaint;
    property Font;
    property Locked;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnCanResize;
    property OnClick;
    property OnConstrainedResize;
    property OnContextPopup;
    property OnDockDrop;
    property OnDockOver;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetSiteInfo;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
	end;

implementation

constructor TGradientPanel.Create(AOwner: TComponent);
begin
	inherited Create(AOwner);
   StartUpdate;
	Caption:=Name;
	SetBounds(Left, Top, 200, 100);
	FStartColor:=clActiveCaption;
   FEndColor:=clGradientActiveCaption;
	FTextPosition:=tpTopLeft;
   FFillDirection:=fdLeftToRight;
	With Font do
   	begin
			Name:='Tahoma';
         Size:=18;
         Color:=clWhite;
      end;
   EndUpdate;
end;

procedure TGradientPanel.SetFillDirection(dir: TFillDirection);
begin
	FFillDirection:=dir;
	Invalidate;
end;

procedure TGradientPanel.SetStartColor(col: TColor);
begin
	FStartColor:=col;
	Invalidate;
end;

procedure TGradientPanel.SetEndColor(col: TColor);
begin
	FEndColor:=col;
	Invalidate;
end;

procedure TGradientPanel.SetTextPosition(pos: TTextPosition);
begin
	FTextPosition:=pos;
	Invalidate;
end;

procedure TGradientPanel.SetTextX(x: Integer);
begin
	FTextX:=x;
	Invalidate;
end;

procedure TGradientPanel.SetTextY(y: Integer);
begin
	FTextY:=y;
	Invalidate;
end;

procedure TGradientPanel.SetTextAngle(a: Integer);
begin
	FTextAngle:=a;
	Invalidate;
end;

procedure TGradientPanel.CMFontChanged(var Message: TMessage);
begin
	If Parent <> nil then Invalidate;
end;

procedure TGradientPanel.CMTextChanged(var Message: TMessage);
begin
	If Parent <> nil then Invalidate;
end;

procedure TGradientPanel.Paint;
var
	X, Y, W, H, Angle: Integer;
begin
	If FNotPaint then Exit;
   If FStartColor = FEndColor then
		begin
			Canvas.Brush.Color:=FStartColor;
			Canvas.FillRect(Rect(0, 0, Width, Height));
		end
   else
   	GradientFill2(Canvas, FStartColor, FEndColor,
      	0, 0, Width, Height, FFillDirection);
   If Caption = '' then Exit;
   With Canvas do
      begin
         Font:=Self.Font;
         W:=TextWidth(Caption);
         H:=TextHeight(Caption);
      end;
   Case FTextPosition of
   tpTopLeft:
      begin
         Angle:=0;
         X:=6 + FTextX;
         Y:=FTextY;
      end;
   tpTopCentre:
      begin
         Angle:=0;
         X:=((ClientWidth - W) div 2) + FTextX;
         Y:=FTextY;
      end;
   tpTopRight:
      begin
         Angle:=0;
         X:=ClientWidth - W + FTextX;
         Y:=FTextY;
      end;
   tpBottomLeft:
      begin
         Angle:=0;
         X:=6 + FTextX;
         Y:=ClientHeight - H + FTextY;
      end;
   tpBottomCentre:
      begin
         Angle:=0;
         X:=((ClientWidth - W) div 2) + FTextX;
         Y:=ClientHeight - H + FTextY;
      end;
   tpBottomRight:
      begin
         Angle:=0;
         X:=ClientWidth - W + FTextX;
         Y:=ClientHeight - H + FTextY;
      end;
   tpCentre:
      begin
         Angle:=0;
         X:=((ClientWidth - W) div 2) + FTextX;
         Y:=((ClientHeight - H) div 2) + FTextY;
      end;
   tpLeftUp:
      begin
         Angle:=90;
         X:=FTextX;
         Y:=ClientHeight - 6 + FTextY;
      end;
   tpLeftDown:
      begin
         Angle:=270;
         X:=H + FTextX;
         Y:=6 + FTextY;
      end;
   tpRightUp:
      begin
         Angle:=90;
         X:=ClientWidth - H + FTextX;
         Y:=ClientHeight - 6 + FTextY;
      end;
   tpRightDown:
      begin
         Angle:=270;
         X:=ClientWidth + FTextX;
         Y:=6 + FTextY;
      end;
   tpCentreUp:
      begin
         Angle:=90;
         X:=((ClientWidth - H) div 2) + FTextX;
         Y:=ClientHeight - 6 + FTextY;
      end;
   tpCentreDown:
      begin
         Angle:=270;
         X:=((ClientWidth + H) div 2) + FTextX;
         Y:=6 + FTextY;
      end;
   tpUser:
      begin
         Angle:=FTextAngle;
         X:=FTextX;
         Y:=FTextY;
      end;
   else
      begin
         Angle:=0;
         X:=0;
         Y:=0;
      end;
   end;
   DrawTextAngle(Canvas, X, Y, Angle, Caption);
end;

procedure TGradientPanel.EndUpdate;
begin
	FNotPaint:=False;
end;

procedure TGradientPanel.StartUpdate;
begin
	FNotPaint:=True;
end;

end.
