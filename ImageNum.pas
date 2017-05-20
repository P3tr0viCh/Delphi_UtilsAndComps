unit ImageNum;

interface

{$DEBUGINFO OFF}

uses
  Windows, Messages, SysUtils, Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Utils_Graf;

type
	TImageNum = class(TGraphicControl)
	private
		FBitmap: TJPEGBitmap;
      FDrawing: Boolean;
      FCaption: String;
      FOnMouseEnter: TNotifyEvent;
      FOnMouseLeave: TNotifyEvent;
      procedure BitmapChanged(Sender: TObject);
      procedure SetBitmap(Value: TJPEGBitmap);

     	procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
      procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    	procedure SetCaption(const Value: String);
  	protected
    	procedure Paint; override;
		function GetWidth: Integer;
		function GetCharWidth: Integer;
      procedure DoBounds;
      function DestRect(Pos: Integer): TRect;
      function SourceRect(_Char: Char): TRect;
      property AutoSize;
  	public
   	constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
    	function GetTextLen: Integer;
    	procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
  	published
      property Bitmap: TJPEGBitmap read FBitmap write SetBitmap;
      property Caption: String read FCaption write SetCaption;
      property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
      property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
      property Align;
      property Anchors;
      property Constraints;
      property Enabled;
      property ParentShowHint;
      property PopupMenu;
      property ShowHint;
      property Visible;
      property OnClick;
      property OnContextPopup;
      property OnDblClick;
      property OnDragDrop;
      property OnDragOver;
      property OnEndDock;
      property OnEndDrag;
      property OnMouseDown;
      property OnMouseMove;
      property OnMouseUp;
      property OnStartDock;
      property OnStartDrag;
  	end;

implementation

constructor TImageNum.Create(AOwner: TComponent);
begin
  	Inherited;
  	ControlStyle:=ControlStyle + [csReplicatable, csOpaque];
   FBitmap:=TJPEGBitmap.Create;
  	FBitmap.OnChange:=BitmapChanged;
   Width:=20;
   Height:=20;
   Caption:='00';
end;

destructor TImageNum.Destroy;
begin
	FBitmap.Free;
  	Inherited;
end;

procedure TImageNum.CMMouseEnter(var Message: TMessage);
begin
   Inherited;
   If Assigned(FOnMouseEnter) then FOnMouseEnter(Self);
end;

procedure TImageNum.CMMouseLeave(var Message: TMessage);
begin
   Inherited;
   If Assigned(FOnMouseLeave) then FOnMouseLeave(Self);
end;

function TImageNum.GetCharWidth: Integer;
begin
	Result:=(Bitmap.Width div 12);
end;

function TImageNum.GetTextLen: Integer;
begin
	Result:=Length(FCaption);
end;

function TImageNum.GetWidth: Integer;
begin
	Result:=GetTextLen * GetCharWidth;
end;

procedure TImageNum.DoBounds;
begin
   SetBounds(Left, Top, 20, 20);
  	If not FDrawing then Invalidate;
end;

procedure TImageNum.BitmapChanged(Sender: TObject);
begin
	DoBounds;
end;

procedure TImageNum.SetCaption(const Value: String);
begin
  	If FCaption = Value then Exit;
   FCaption:=Value;
   DoBounds;
end;

function TImageNum.DestRect(Pos: Integer): TRect;
var
	CharWidth: Integer;
begin
	CharWidth:=GetCharWidth;
   Result:=Bounds(CharWidth * Pos, 0,
   					CharWidth, Bitmap.Height);
end;

function TImageNum.SourceRect(_Char: Char): TRect;
var
	CharWidth, Pos: Integer;
begin
	CharWidth:=GetCharWidth;
	Case _Char of
   '0'..'9':	Pos:=Ord(_Char) - 48;
   '-':			Pos:=10;
   else			Pos:=11;
   end;
   Result:=Bounds(CharWidth * Pos, 0, CharWidth, Bitmap.Height);;
end;

procedure TImageNum.Paint;
var
  	Save: Boolean;
   i: Integer;
begin
   If csDesigning in ComponentState then
   	with inherited Canvas do
   		begin
   			Pen.Style:=psDot;
   			Brush.Style:=bsClear;
   			Rectangle(0, 0, Width, Height);
   		end;
   Save:=FDrawing;
   FDrawing:=True;
   Try
   	If GetTextLen = 0 then Exit;
   	For i:=0 to GetTextLen - 1 do
      	begin
   			with inherited Canvas do
					CopyRect(DestRect(i), Bitmap.Canvas, SourceRect(FCaption[i + 1]));
			end;
	finally
		FDrawing:=Save;
	end;
end;

procedure TImageNum.SetBitmap(Value: TJPEGBitmap);
begin
	FBitmap.Assign(Value);
end;

procedure TImageNum.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
 	If Bitmap.Height > 0 then AHeight:=Bitmap.Height;
	If Bitmap.Width > 0 then AWidth:=GetWidth;
  	Inherited;
end;

end.
