unit ImageRadioBtn;

interface

uses
  Windows, Messages, SysUtils, Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, CustomImageBtn;

type
   TImageRadioBtn = class(TCustomImageBtn)
   private
      FChecked: Boolean;
      procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
   protected
      procedure DrawItem(const DrawItemStruct: TDrawItemStruct); override;
      function  GetImageWidth: Integer; override;
      function GetChecked: Boolean; override;
      procedure SetChecked(Value: Boolean); override;
   public
   published
   	property Checked;
   end;

implementation

uses Utils_Misc;

procedure TImageRadioBtn.DrawItem(const DrawItemStruct: TDrawItemStruct);
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
      	If IsDown then BtnState:=4
         else
         	begin
            	If Checked then BtnState:=0 else BtnState:=2;
               If MouseOnBtn or IsFocus then Inc(BtnState);
            end;
      end
   else
      BtnState:=5;

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

function TImageRadioBtn.GetImageWidth: Integer;
begin
	Result:=Bitmap.Width div 6;
end;

function TImageRadioBtn.GetChecked: Boolean;
begin
	Result:=FChecked;
end;

procedure TImageRadioBtn.SetChecked(Value: Boolean);

   procedure TurnSiblingsOff;
   var
   	I: Integer;
   	Sibling: TControl;
   begin
      If Parent <> nil then
      	with Parent do
         	for I:=0 to ControlCount - 1 do
            	begin
               	Sibling:=Controls[I];
                  If (Sibling <> Self) and (Sibling is TImageRadioBtn) then
                  	TImageRadioBtn(Sibling).SetChecked(False);
               end;
   end;

begin
   If FChecked <> Value then
   	begin
      	FChecked:=Value;
         TabStop:=Value;
         If Value then
         	begin
            	TurnSiblingsOff;
               inherited Changed;
               If not ClicksDisabled then Click;
            end;
      end;
   Invalidate;
end;

procedure TImageRadioBtn.CNCommand(var Message: TWMCommand);
begin
   Case Message.NotifyCode of
   BN_CLICKED: SetChecked(True);
   BN_DOUBLECLICKED: DblClick;
   end;
end;

end.
