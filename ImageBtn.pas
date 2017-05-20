unit ImageBtn;

interface

{$DEBUGINFO OFF}

uses
  Windows, Messages, SysUtils, Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Buttons, Vcl.StdCtrls, CustomImageBtn;

type
	TImageBtn = class(TCustomImageBtn)
	private
		FActive: Boolean;
		FModalResult: TModalResult;
		FCancel: Boolean;
		FDefault: Boolean;
		FCanDblClick: Boolean;
		procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;
		procedure CMFocusChanged(var Message: TCMFocusChanged); message CM_FOCUSCHANGED;
		procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
		procedure SetDefault(const Value: Boolean);
		procedure SetCanDblClick(const Value: Boolean);
	protected
		procedure DrawItem(const DrawItemStruct: TDrawItemStruct); override;
		function  GetImageWidth: Integer; override;
		procedure CreateWnd; override;
	public
		constructor Create(AOwner: TComponent); override;
		procedure Click; override;
	published
		property CanDblClick: Boolean read FCanDblClick write SetCanDblClick default False;
		property ModalResult: TModalResult read FModalResult write FModalResult default 0;
		property Cancel: Boolean read FCancel write FCancel default False;
		property Default: Boolean read FDefault write SetDefault default False;
   end;

	TImageBtnNF = class(TCustomImageBtnNF)
	private
	protected
		function  GetImageWidth: Integer; override;
		procedure Paint; override;
	public
	published
      property OnDblClick;
	end;

implementation

uses Utils_Misc;

function TImageBtn.GetImageWidth: Integer;
begin
	Result:=Bitmap.Width div 4;
end;

procedure TImageBtn.DrawItem(const DrawItemStruct: TDrawItemStruct);
var
	BtnState: Integer;
   DestRect, SourceRect: TRect;
   IsDown, IsFocus, IsEnabled: Boolean;
begin
	With DrawItemStruct do
   	begin
			Canvas.Handle:=hDC;
			IsDown:=IsValueInWord(itemState, ODS_SELECTED);
			IsFocus:=IsValueInWord(itemState, ODS_FOCUS);
         IsEnabled:=not IsValueInWord(itemState, ODS_DISABLED);
      end;
   If IsEnabled then
      begin
      	If IsDown then BtnState:=2
         else
         	begin
               If MouseOnBtn or IsFocus then BtnState:=1 else BtnState:=0;
            end;
      end
   else
      BtnState:=3;

   SourceRect:=Bounds(Width * BtnState, Height * State, Width, Height);
   DestRect:=ClientRect;
   If Bitmap.Empty or (csDesigning in ComponentState) then
      begin
         Canvas.Brush.Color:=clBtnFace;
         Canvas.FillRect(DestRect);
         Canvas.Pen.Style:=psDot;
         Canvas.Brush.Style:=bsClear;
         Canvas.Rectangle(0, 0, Width, Height);
      end
   else
      Canvas.CopyRect(DestRect, Bitmap.Canvas, SourceRect);
   Canvas.Handle:=0;
end;

procedure TImageBtn.Click;
var
	Form: TCustomForm;
begin
	Form:=GetParentForm(Self);
   If Form <> nil then Form.ModalResult:=ModalResult;
   inherited Click;
end;

procedure TImageBtn.CNCommand(var Message: TWMCommand);
begin
   Case Message.NotifyCode of
   BN_CLICKED: Click;
   BN_DOUBLECLICKED: If FCanDblClick then DblClick;
   end;
end;

constructor TImageBtn.Create(AOwner: TComponent);
begin
	inherited;
   ControlStyle:=[csOpaque];
   FActive:=False;
end;

procedure TImageBtn.CMDialogKey(var Message: TCMDialogKey);
begin
	With Message do
   	If (((CharCode = VK_RETURN) and FActive) or
      	 ((CharCode = VK_ESCAPE) and FCancel)) and
          (KeyDataToShiftState(Message.KeyData) = []) and CanFocus then
          begin
          	Click;     
            Result:=1;
          end
      else
      	inherited;
end;

procedure TImageBtn.CMFocusChanged(var Message: TCMFocusChanged);
begin
	With Message do
   	If Sender is TImageBtn then
      	FActive:=Sender = Self
      else
      	FActive:=FDefault;
   inherited;
end;

procedure TImageBtn.SetDefault(const Value: Boolean);
var
	Form: TCustomForm;
begin
	FDefault:=Value;
   If HandleAllocated then
   	begin
      	Form:=GetParentForm(Self);
         If Form <> nil then
         	Form.Perform(CM_FOCUSCHANGED, 0, LongInt(Form.ActiveControl));
      end;
end;

procedure TImageBtn.CreateWnd;
begin
	inherited CreateWnd;
   FActive:=FDefault;
end;

procedure TImageBtn.SetCanDblClick(const Value: Boolean);
begin
	FCanDblClick:=Value;
   If FCanDblClick then ControlStyle:=ControlStyle + [csDoubleClicks]
   					 else ControlStyle:=ControlStyle - [csDoubleClicks];
end;

function TImageBtnNF.GetImageWidth: Integer;
begin
	Result:=Bitmap.Width div 4;
end;

procedure TImageBtnNF.Paint;
var
	BtnState: Integer;
	DestRect, SourceRect: TRect;
begin
	If Enabled then
      begin
      	If (csLButtonDown in ControlState) and MouseOnBtn then BtnState:=2
         else
         	begin
               If MouseOnBtn then BtnState:=1 else BtnState:=0;
				end;
      end
   else
      BtnState:=3;

   SourceRect:=Bounds(Width * BtnState, 0, Width,  Height);
   DestRect:=ClientRect;
   If Bitmap.Empty or (csDesigning in ComponentState) then
      begin
         Canvas.Brush.Color:=clBtnFace;
         Canvas.FillRect(DestRect);
         Canvas.Pen.Style:=psDot;
         Canvas.Brush.Style:=bsClear;
         Canvas.Rectangle(0, 0, Width, Height);
      end
   else
		Canvas.CopyRect(DestRect, Bitmap.Canvas, SourceRect);
end;

end.


