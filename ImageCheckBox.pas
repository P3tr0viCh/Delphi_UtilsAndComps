unit ImageCheckBox;

interface

{$DEBUGINFO OFF}

uses
  Windows, Messages, SysUtils, Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, CustomImageBtn;

type
	TImageCheckBox = class(TCustomImageBtn)
	private
		FState: TCheckBoxState;
		FAllowGrayed: Boolean;
		procedure SetState(const Value: TCheckBoxState);
		procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
	protected
		procedure DrawItem(const DrawItemStruct: TDrawItemStruct); override;
		function GetChecked: Boolean; override;
		procedure SetChecked(Value: Boolean); override;
		function  GetImageWidth: Integer; override;
		procedure Toggle; virtual;
	public
		procedure Click; override;
	published
		property Checked;
		property AllowGrayed: Boolean read FAllowGrayed write FAllowGrayed default False;
		property State: TCheckBoxState read FState write SetState default cbUnchecked;
	end;

	TImageCheckBoxNF = class(TCustomImageBtnNF)
	private
		FAllowGrayed: Boolean;
		FState: TCheckBoxState;
		procedure SetState(const Value: TCheckBoxState);
		procedure SetChecked(const Value: Boolean);
		function GetChecked: Boolean;
	protected
		function  GetImageWidth: Integer; override;
		procedure Paint; override;
		procedure Toggle; virtual;
	public
		constructor Create(AOwner: TComponent); override;
		procedure Click; override;
		procedure DblClick; override;
	published
		property Checked: Boolean read GetChecked write SetChecked default False;
		property AllowGrayed: Boolean read FAllowGrayed write FAllowGrayed default False;
		property State: TCheckBoxState read FState write SetState default cbUnchecked;
	end;

implementation

uses Utils_Misc;

procedure TImageCheckBox.Click;
begin
	inherited Changed;
	inherited Click;
end;

procedure TImageCheckBox.CNCommand(var Message: TWMCommand);
begin
	Case Message.NotifyCode of
	BN_CLICKED: 		Toggle;
	BN_DOUBLECLICKED:	Toggle;
	end;
end;

procedure TImageCheckBox.DrawItem(const DrawItemStruct: TDrawItemStruct);
var
	BtnState: Integer;
	DestRect, SourceRect: TRect;
	IsDown, IsFocus, IsEnabled: Boolean;
begin
	With DrawItemStruct do
		begin
			Canvas.Handle:=hDC;
			IsDown:=		IsValueInWord(itemState, ODS_SELECTED);
			IsFocus:=	IsValueInWord(itemState, ODS_FOCUS);
			IsEnabled:=	not IsValueInWord(itemState, ODS_DISABLED);
		end;

	If IsEnabled then
		begin
			If IsDown then BtnState:=6
			else
				begin
					Case State of
					cbChecked: 		BtnState:=0;
					cbUnchecked:	BtnState:=2;
					else				BtnState:=4;
					end;
					If MouseOnBtn or IsFocus then Inc(BtnState);
				end;
		end
	else
		BtnState:=7;

	SourceRect:=Bounds(Width * BtnState, 0, Width,  Height);

	DestRect:=ClientRect;
	Canvas.Brush.Color:=clBtnFace;
	Canvas.FillRect(DestRect);
	If Bitmap.Empty or (csDesigning in ComponentState) then
		begin
			Canvas.Pen.Style:=psDot;
			Canvas.Brush.Style:=bsClear;
			Canvas.Rectangle(0, 0, Width, Height);
		end
	else
		Canvas.CopyRect(DestRect, Bitmap.Canvas, SourceRect);

	Canvas.Handle:=0;
end;

function TImageCheckBox.GetChecked: Boolean;
begin
	Result:=State = cbChecked;
end;

function TImageCheckBox.GetImageWidth: Integer;
begin
	Result:=Bitmap.Width div 8;
end;

procedure TImageCheckBox.SetChecked(Value: Boolean);
begin
	If Value then State:=cbChecked else State:=cbUnchecked;
end;

procedure TImageCheckBox.SetState(const Value: TCheckBoxState);
begin
	If FState <> Value then
		begin
			FState:=Value;
			If HandleAllocated then
				SendMessage(Handle, BM_SETCHECK, Integer(FState), 0);
			Invalidate;
			If not ClicksDisabled then Click;
		end;
end;

procedure TImageCheckBox.Toggle;
begin
	Case State of
	cbUnchecked:	If AllowGrayed then State:=cbGrayed else State:=cbChecked;
	cbChecked:		State:=cbUnchecked;
	cbGrayed:		State:=cbChecked;
	end;
end;

procedure TImageCheckBoxNF.Click;
begin
	Toggle;
	inherited Click;
end;

constructor TImageCheckBoxNF.Create(AOwner: TComponent);
begin
	inherited;
	FAllowGrayed:=False;
	FState:=cbUnchecked;
end;

procedure TImageCheckBoxNF.DblClick;
begin
	Toggle;
	inherited Click;
end;

function TImageCheckBoxNF.GetChecked: Boolean;
begin
	Result:=State = cbChecked;
end;

function TImageCheckBoxNF.GetImageWidth: Integer;
begin
	Result:=Bitmap.Width div 8;
end;

procedure TImageCheckBoxNF.Paint;
var
	BtnState: Integer;
	DestRect, SourceRect: TRect;
begin
	If Enabled then
		begin
			If (csLButtonDown in ControlState) then BtnState:=6
			else
				begin
					Case State of
					cbUnchecked:	BtnState:=0;
					cbChecked:		BtnState:=2;
					else				BtnState:=4;
					end;
					If MouseOnBtn then Inc(BtnState);
				end;
		end
	else
		BtnState:=7;

	SourceRect:=Bounds(Width * BtnState, 0, Width,  Height);

	DestRect:=ClientRect;
	Canvas.Brush.Color:=clBtnFace;
	Canvas.FillRect(DestRect);
	If Bitmap.Empty or (csDesigning in ComponentState) then
		begin
			Canvas.Pen.Style:=psDot;
			Canvas.Brush.Style:=bsClear;
			Canvas.Rectangle(0, 0, Width, Height);
		end
	else
		Canvas.CopyRect(DestRect, Bitmap.Canvas, SourceRect);
end;

procedure TImageCheckBoxNF.SetChecked(const Value: Boolean);
begin
	If Value then State:=cbChecked else State:=cbUnchecked;
end;

procedure TImageCheckBoxNF.SetState(const Value: TCheckBoxState);
begin
	If FState <> Value then
		begin
			FState:=Value;
			Invalidate;
		end;
end;

procedure TImageCheckBoxNF.Toggle;
begin
	Case State of
	cbUnchecked:	If AllowGrayed then State:=cbGrayed else State:=cbChecked;
	cbChecked:		State:=cbUnchecked;
	cbGrayed:		State:=cbChecked;
	end;
end;

end.
