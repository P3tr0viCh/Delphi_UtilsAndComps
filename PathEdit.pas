unit PathEdit;

interface

{$DEBUGINFO OFF}

uses
	Messages, Windows, SysUtils, Classes, Vcl.Controls, Vcl.Forms, Vcl.Menus,
  Vcl.Graphics, Vcl.StdCtrls, Vcl.Dialogs, BrowseFolder;

type
  TPathButton = class(TButton)
  private
  protected
  public
    constructor Create(AOwner: TComponent); override;
    procedure Click; override;
  published
  end;

  TPathWhatShow = (wsOpenFile, wsOpenFolder, wsOther);

  TPathEdit = class(TEdit)
  private
    FButton: TPathButton;
    FOpenFileDialog: TOpenDialog;
    FOpenFolderDialog: TBrowseFolder;
    FWhatShow: TPathWhatShow;
    FRelativePath: Boolean;
    FOnFileNameChange: TNotifyEvent;
    procedure SetWhatShow(const Value: TPathWhatShow);
    procedure SetRelativePath(const Value: Boolean);
  protected
    procedure SetParent(AParent: TWinControl); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure CMVisiblechanged(var Message: TMessage); message CM_VISIBLECHANGED;
    procedure CMEnabledchanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMBidimodechanged(var Message: TMessage); message CM_BIDIMODECHANGED;
    procedure DoClick;
    procedure DoFileNameChange;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetBounds(ALeft: Integer; ATop: Integer; AWidth: Integer; AHeight: Integer); override;
  published
    property Button: TPathButton read FButton;
    property OpenFileDialog: TOpenDialog read FOpenFileDialog;
    property OpenFolderDialog: TBrowseFolder read FOpenFolderDialog;
    property WhatShow: TPathWhatShow read FWhatShow write SetWhatShow default wsOpenFile;
    property RelativePath: Boolean read FRelativePath write SetRelativePath default True;
    property OnFileNameChange: TNotifyEvent read FOnFileNameChange write FOnFileNameChange;
  end;

implementation

uses Vcl.ClipBrd, Utils_Misc, Utils_Str, Utils_Files;

procedure TPathEdit.CMBidimodechanged(var Message: TMessage);
begin
   inherited;
   FButton.BiDiMode:=BiDiMode;
end;

procedure TPathEdit.CMEnabledchanged(var Message: TMessage);
begin
   inherited;
   FButton.Enabled:=Enabled;
end;

procedure TPathEdit.CMVisiblechanged(var Message: TMessage);
begin
   inherited;
   FButton.Visible:=Visible;
end;

constructor TPathEdit.Create(AOwner: TComponent);
begin
   FButton:=TPathButton.Create(Self);

   FOpenFileDialog:=TOpenDialog.Create(Self);
   FOpenFileDialog.SetSubComponent(True);
   FOpenFileDialog.Options:=[ofHideReadOnly,ofPathMustExist,ofFileMustExist,
      ofEnableSizing,ofDontAddToRecent];
   FOpenFileDialog.Filter:='Все файлы|*.*';
   FOpenFileDialog.Name:='OpenFileDialog';

   FOpenFolderDialog:=TBrowseFolder.Create(Self);
   FOpenFolderDialog.SetSubComponent(True);
   FOpenFolderDialog.Position:=bpCenter;
   FOpenFolderDialog.Name:='OpenFolderDialog';

   FWhatShow:=wsOpenFile;
   FRelativePath:=True;
   inherited;
end;

destructor TPathEdit.Destroy;
begin
   FOpenFolderDialog.Free;
   FOpenFileDialog.Free;
   FButton.Free;
   inherited;
end;

procedure TPathEdit.DoClick;
begin
   Case WhatShow of
   wsOpenFile:
      With FOpenFileDialog do
         begin
            FileName:='';
            If Execute then begin Text:=FileName; DoFileNameChange; end;
         end;
   wsOpenFolder:
      With FOpenFolderDialog do
         begin
            Directory:=GetCommonName(Text, True);
            If Execute then begin Text:=Directory; DoFileNameChange; end;
         end;
   end;
   If Assigned(FButton.OnClick) then FButton.OnClick(Self);
   If FRelativePath then Text:=GetCommonName(Text, False);
   SetFocus;
end;

procedure TPathEdit.DoFileNameChange;
begin
   If Assigned(FOnFileNameChange) then FOnFileNameChange(Self);
end;

procedure TPathEdit.Notification(AComponent: TComponent; Operation: TOperation);
begin
   inherited Notification(AComponent, Operation);
   If Operation = opRemove then
      if AComponent = FButton then FButton:=nil
      else
         if AComponent = FOpenFileDialog then FOpenFileDialog:=nil
         else
            if AComponent = FOpenFolderDialog then FOpenFolderDialog:=nil;
end;

procedure TPathEdit.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  FButton.SetBounds(ALeft + AWidth, ATop + 1, AHeight - 2, AHeight - 2);
end;

procedure TPathEdit.SetParent(AParent: TWinControl);
begin
   inherited SetParent(AParent);
   If FButton = nil then Exit;
   FButton.Parent:=AParent;
   FButton.Visible:=True;
end;

procedure TPathButton.Click;
begin
   TPathEdit(Owner).DoClick;
end;

constructor TPathButton.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   Name:='PathButton';  { do not localize }
   SetSubComponent(True);
   Caption:='...';
end;

procedure TPathEdit.SetRelativePath(const Value: Boolean);
begin
   If FRelativePath = Value then Exit;
   FRelativePath:=Value;
   Text:=GetCommonName(Text, not FRelativePath);
end;

procedure TPathEdit.SetWhatShow(const Value: TPathWhatShow);
begin
   If FWhatShow = Value then Exit;
   FWhatShow:=Value;
end;

end.
