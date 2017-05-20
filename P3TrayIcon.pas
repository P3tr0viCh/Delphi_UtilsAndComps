unit P3TrayIcon;

interface

{$DEBUGINFO OFF}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.ComCtrls,
  Vcl.Dialogs, Winapi.ShellAPI, Vcl.Menus;

var
	WM_TASKBARCREATED: Cardinal;

const
	WM_ICONMESSAGE = WM_USER + 81;

   NIF_INFO = $10;
   NOTIFYICON_VERSION = 3;
   NIM_SETVERSION = $00000004;
   NIM_SETFOCUS = $00000003;
   NIIF_INFO = $00000001;
   NIIF_WARNING = $00000002;
   NIIF_ERROR = $00000003;

   NIN_BALLOONSHOW = WM_USER + 2;
   NIN_BALLOONHIDE = WM_USER + 3;
   NIN_BALLOONTIMEOUT = WM_USER + 4;
   NIN_BALLOONUSERCLICK = WM_USER + 5;
   NIN_SELECT = WM_USER + 0;
   NINF_KEY = $1;
   NIN_KEYSELECT = NIN_SELECT or NINF_KEY;

type
  TTrayIconDblClick = procedure(Sender: TObject;
										  Button: TMouseButton;
										  Shift: TShiftState) of object;
  TInfoIcon   = (iiNone, iiInfo, iiError, iiWarning);

  PNewNotifyIconData = ^TNewNotifyIconData;
  TDUMMYUNIONNAME    = record
    case Integer of
      0: (uTimeout: UINT);
      1: (uVersion: UINT);
  end;

  TNewNotifyIconData = record
    cbSize: DWORD;
    Wnd: HWND;
    uID: UINT;
    uFlags: UINT;
    uCallbackMessage: UINT;
    hIcon: HICON;
    szTip: array [0..127] of Char;        //Version 5.0 is 128 chars, old ver is 64 chars
    //Version 5.0
    dwState: DWORD;
    dwStateMask: DWORD;
    szInfo: array [0..255] of Char;
    DUMMYUNIONNAME: TDUMMYUNIONNAME;
    szInfoTitle: array [0..63] of Char;
    dwInfoFlags: DWORD;
  end;

  TP3TrayIcon = class(TComponent)
  private
	 FIconData: TNewNotifyIconData;
	 FHookWindow: THandle;
	 FIcon: TIcon;
	 FTip: string;
	 FVisible: Boolean;
	 FEnabled: Boolean;
	 FPopupMenu: TPopupMenu;
	 FOnDblClick: TTrayIconDblClick;
	 FOnMouseDown, FOnMouseUp: TMouseEvent;
	 FOnMouseMove: TMouseMoveEvent;
	 FBeepOnDisabled: Boolean;
    FInfo: string;
    FInfoTitle: String;
    FOnBalloonHide: TNotifyEvent;
    FOnBalloonTimeOut: TNotifyEvent;
    FOnBalloonClick: TNotifyEvent;
    FOnBalloonShow: TNotifyEvent;
	 procedure WndProc(var Message: TMessage);
	 procedure SetIcon(AIcon: TIcon);
	 procedure SetTip(ATip: string);
	 procedure SetVisible(AValue: Boolean);
	 procedure AddIcon;
	 procedure DeleteIcon;
	 procedure ModifyIcon;
	 procedure PopupAtCursor(Button: TMouseButton; X, Y: Integer);
	 procedure IconChanged(Sender: TObject);
	 procedure SetIconID(const Value: LongWord);
    function  GetInfoIcon: TInfoIcon;
    procedure SetInfoIcon(const Value: TInfoIcon);
    procedure SetInfo(const Value: String);
    procedure SetInfoTitle(const Value: String);
    function  GetTimeout: LongWord;
    procedure SetTimeout(const Value: LongWord);
  protected
	 procedure Loaded; override;
	 function  GetShiftState: TShiftState;
	 procedure MouseDown(Button: TMouseButton; X, Y: Integer); dynamic;
	 procedure MouseUp(Button: TMouseButton; X, Y: Integer); dynamic;
	 procedure DblClick(Button: TMouseButton); dynamic;
	 procedure MouseMove(X, Y: Integer); dynamic;

	 procedure BalloonShow; dynamic;
	 procedure BalloonHide; dynamic;
	 procedure BalloonTimeOut; dynamic;
	 procedure BalloonClick; dynamic;
  public
	 constructor Create(AOwner: TComponent); override;
	 destructor Destroy; override;

    procedure ShowBalloonTip;
  published
	 property Icon: TIcon read FIcon write SetIcon;
	 property Tip: String read FTip write SetTip;
	 property Info: String read FInfo write SetInfo;
    property InfoTitle: String read FInfoTitle write SetInfoTitle;
    property TimeOut: LongWord read GetTimeout write SetTimeout default 3000;
    property InfoIcon: TInfoIcon read GetInfoIcon write SetInfoIcon default iiInfo;
	 property IconID: LongWord read FIconData.uID write SetIconID default 0;
	 property Visible: Boolean read FVisible write SetVisible default True;
	 property Enabled: Boolean read FEnabled write FEnabled default True;
	 property PopupMenu: TPopupMenu read FPopupMenu write FPopupMenu;
	 property BeepOnDisabled: Boolean read FBeepOnDisabled write FBeepOnDisabled default True;

	 property OnDblClick: TTrayIconDblClick read FOnDblClick write FOnDblClick;
	 property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
	 property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;
	 property OnMouseMove: TMouseMoveEvent read FOnMouseMove write FOnMouseMove;

	 property OnBalloonShow:      TNotifyEvent read FOnBalloonShow    write FOnBalloonShow;
	 property OnBalloonHide:      TNotifyEvent read FOnBalloonHide    write FOnBalloonHide;
	 property OnBalloonTimeOut:   TNotifyEvent read FOnBalloonTimeOut write FOnBalloonTimeOut;
	 property OnBalloonClick:     TNotifyEvent read FOnBalloonClick   write FOnBalloonClick;
  end;

implementation

uses Utils_Misc;

constructor TP3TrayIcon.Create(AOwner: TComponent);
begin
	inherited;
	FBeepOnDisabled:=True;
	ZeroMemory(@FIconData, SizeOf(FIconData));
   FIcon:=TIcon.Create;
   FIcon.OnChange:=IconChanged;
   FVisible:=True;
   FEnabled:=True;
   FHookWindow:=System.Classes.AllocateHWnd(WndProc);
	with FIconData do
 	 	begin
    		cbSize:=SizeOf(FIconData);
			Wnd:=FHookWindow;
			uID:=0;
    		uFlags:=NIF_TIP or NIF_ICON or NIF_MESSAGE;
    		uCallbackMessage:=WM_ICONMESSAGE;
         hIcon:=0;
                                       
         dwInfoFlags:=NIIF_INFO;
         DUMMYUNIONNAME.uTimeout:=3000;
  		end;
end;

destructor TP3TrayIcon.Destroy;
begin
   If FHookWindow <> 0 then System.Classes.DeallocateHWnd(FHookWindow);
   If (not (csDesigning in ComponentState)) and FVisible then DeleteIcon;
   FIcon.Free;
   inherited;
end;

procedure TP3TrayIcon.Loaded;
begin
  	inherited;
  	If csDesigning in ComponentState then Exit;
  	If FVisible then AddIcon;
end;

procedure TP3TrayIcon.WndProc(var Message: TMessage);
var
  	P: TPoint;
begin
	If (Message.Msg = WM_TASKBARCREATED) and FVisible then
		begin
			DeleteIcon;
         AddIcon;
			Exit;
		end;
	Case Message.Msg of
	WM_ICONMESSAGE:
		begin
			GetCursorPos(P);
			If Message.lParam = WM_MOUSEMOVE then
				MouseMove(P.x, P.y)
			else
				begin
               Case Message.lParam of
               NIN_BALLOONSHOW:        BalloonShow;
               NIN_BALLOONHIDE:        BalloonHide;
               NIN_BALLOONTIMEOUT:     BalloonTimeOut;
               NIN_BALLOONUSERCLICK:   BalloonClick;
               else
                  If FEnabled then
                     Case Message.lParam of
                     WM_LBUTTONDOWN: 	MouseDown(mbLeft, 	P.x, P.y);
                     WM_MBUTTONDOWN: 	MouseDown(mbMiddle, 	P.x, P.y);
                     WM_RBUTTONDOWN: 	MouseDown(mbRight, 	P.x, P.y);
                     WM_LBUTTONUP:   	MouseUp(mbLeft, 		P.x, P.y);
                     WM_MBUTTONUP:   	MouseUp(mbMiddle, 	P.x, P.y);
                     WM_RBUTTONUP:   	MouseUp(mbRight, 		P.x, P.y);
                     WM_LBUTTONDBLCLK: DblClick(mbLeft);
                     WM_MBUTTONDBLCLK: DblClick(mbMiddle);
                     WM_RBUTTONDBLCLK: DblClick(mbRight);
                     end
                  else
                     begin
                        SetForegroundWindow(Application.Handle);
                        Case Message.lParam of
                        WM_LBUTTONDOWN,	WM_MBUTTONDOWN,	WM_RBUTTONDOWN,
                        WM_LBUTTONDBLCLK,	WM_MBUTTONDBLCLK,	WM_RBUTTONDBLCLK: If BeepOnDisabled then Beep;
                        end;
                     end;
               end;
				end;
		end;
	WM_QUERYENDSESSION:
		begin
			Message.Result:=Integer(True);
			Application.Terminate;
		end;
	else Dispatch(Message);
	end;
end;

function TP3TrayIcon.GetShiftState: TShiftState;
begin
   Result:=[];
   If GetAsyncKeyState(VK_SHIFT)   < 0 then Include(Result, ssShift);
   If GetAsyncKeyState(VK_CONTROL) < 0 then Include(Result, ssCtrl);
   If GetAsyncKeyState(VK_MENU) 	  < 0 then Include(Result, ssAlt);
end;

procedure TP3TrayIcon.MouseMove(X, Y: Integer);
begin
	If Assigned(FOnMouseMove) then FOnMouseMove(Self, GetShiftState, X, Y);
end;

procedure TP3TrayIcon.MouseDown(Button: TMouseButton; X, Y: Integer);
begin
	SetForegroundWindow(Application.Handle);
	If Assigned(FOnMouseDown) then
		FOnMouseDown(Self, Button, GetShiftState, X, Y);
end;

procedure TP3TrayIcon.MouseUp(Button: TMouseButton; X, Y: Integer);
begin
	If Assigned(FOnMouseUp) then
		FOnMouseUp(Self, Button, GetShiftState, X, Y);
	PopupAtCursor(Button, X, Y);
end;

procedure TP3TrayIcon.PopupAtCursor(Button: TMouseButton; X, Y: Integer);
begin
	If Assigned(PopupMenu) then
		if PopupMenu.AutoPopup then
			if ((Button = mbLeft) and
				 (PopupMenu.TrackButton = tbLeftButton)) or
				((Button = mbRight) and
				 (PopupMenu.TrackButton = tbRightButton)) then
				begin
            	SetForegroundWindow(Application.MainForm.Handle);
					ProcMess;
					PopupMenu.PopupComponent:=Self;
					PopupMenu.Popup(X, Y);
				end;
end;

procedure TP3TrayIcon.DblClick(Button: TMouseButton);
begin
	SetForegroundWindow(Application.Handle);
	If Assigned(FOnDblClick) then FOnDblClick(Self, Button, GetShiftState);
end;

procedure TP3TrayIcon.SetIcon(AIcon: TIcon);
begin
	FIcon.Assign(AIcon);
end;

procedure TP3TrayIcon.SetTip(ATip: string);
begin
   If FTip = ATip then Exit;
   FTip:=ATip;
   If csDesigning in ComponentState then Exit;
   StrPLCopy(FIconData.szTip, ATip, SizeOf(FIconData.szTip) - 1);
   ModifyIcon;
end;

procedure TP3TrayIcon.SetVisible(AValue: Boolean);
begin
   FVisible:=AValue;
   If (csDesigning in ComponentState) then Exit;
   If FVisible then AddIcon else DeleteIcon;
end;

procedure TP3TrayIcon.AddIcon;
begin
	If FIconData.hIcon <> 0 then Shell_NotifyIcon(NIM_ADD, @FIconData);
end;

procedure TP3TrayIcon.DeleteIcon;
begin
  	Shell_NotifyIcon(NIM_DELETE, @FIconData);
   SendMessage(GetChildHandle(GetChildHandle(GetShellTrayHandle, 'TRAYNOTIFYWND'), 'BUTTON'), WM_ENABLE, 0, 0);
end;

procedure TP3TrayIcon.ModifyIcon;
begin
  	Shell_NotifyIcon(NIM_MODIFY, @FIconData);
end;

procedure TP3TrayIcon.IconChanged(Sender: TObject);
begin
	If csDesigning in ComponentState then Exit;
   If FIcon.Empty then
   	begin
      	FIconData.hIcon:=0;
         DeleteIcon;
      end
   else
   	begin
         If FIconData.hIcon = 0 then
         	begin
      			FIconData.hIcon:=FIcon.Handle;
               If FVisible then AddIcon;
            end
         else
         	begin
      			FIconData.hIcon:=FIcon.Handle;
               If FVisible then ModifyIcon;
            end;
      end;
end;

procedure TP3TrayIcon.SetIconID(const Value: LongWord);
begin
	If FIconData.uID = Value then Exit;
	FIconData.uID:=Value;
	ModifyIcon;
end;

procedure TP3TrayIcon.ShowBalloonTip;
begin
   Visible:=True;
   With FIconData do
      begin
         uFlags:=uFlags or NIF_INFO;
         ModifyIcon;
         uFlags:=uFlags and not NIF_INFO;
      end;
end;

function TP3TrayIcon.GetInfoIcon: TInfoIcon;
begin
   Case FIconData.dwInfoFlags of
   NIIF_INFO:     Result:=iiInfo;
   NIIF_ERROR:    Result:=iiError;
   NIIF_WARNING:  Result:=iiWarning;
   else
      Result:=iiNone;
   end;
end;

procedure TP3TrayIcon.SetInfoIcon(const Value: TInfoIcon);
begin
   Case Value of
   iiInfo:    FIconData.dwInfoFlags:=NIIF_INFO;
   iiError:    FIconData.dwInfoFlags:=NIIF_ERROR;
   iiWarning:  FIconData.dwInfoFlags:=NIIF_WARNING;
   else
      FIconData.dwInfoFlags:=0;
   end;
end;

procedure TP3TrayIcon.SetInfo(const Value: String);
begin
   If FInfo = Value then Exit;
   FInfo:=Value;
   StrPLCopy(FIconData.szInfo, FInfo, SizeOf(FIconData.szInfo) - 1);
end;

procedure TP3TrayIcon.SetInfoTitle(const Value: String);
begin
   If FInfoTitle = Value then Exit;
   FInfoTitle:=Value;
   StrPLCopy(FIconData.szInfoTitle, InfoTitle, SizeOf(FIconData.szInfoTitle) - 1);
end;

procedure TP3TrayIcon.BalloonClick;
begin
   If Assigned(FOnBalloonClick) then FOnBalloonClick(Self);
end;

procedure TP3TrayIcon.BalloonHide;
begin
   If Assigned(FOnBalloonHide) then FOnBalloonHide(Self);
end;

procedure TP3TrayIcon.BalloonShow;
begin
   If Assigned(FOnBalloonShow) then FOnBalloonShow(Self);
end;

procedure TP3TrayIcon.BalloonTimeOut;
begin
   If Assigned(FOnBalloonTimeOut) then FOnBalloonTimeOut(Self);
end;

function TP3TrayIcon.GetTimeout: LongWord;
begin
   Result:=FIconData.DUMMYUNIONNAME.uTimeout
end;

procedure TP3TrayIcon.SetTimeout(const Value: LongWord);
begin
   FIconData.DUMMYUNIONNAME.uTimeout:=Value;
end;

initialization
  WM_TASKBARCREATED:=RegisterWindowMessage(PChar('TaskbarCreated')); // Th@nKs LmD!!!

end.
