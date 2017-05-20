unit Utils_Dlgs;

interface

uses Windows, Messages, SysUtils, CommDlg, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls;

function InputString(const ACaption, APrompt: String;
	var Value: String;
	EditColor: TColor = clWindow;
	EditFontColor: TColor = clWindowText): Boolean;
function OpenFileDlg(var AFileName: String; AFilter: String = ''): Boolean;
function SaveFileDlg(var AFileName: String; AFilter: String = ''): Boolean;

implementation

function InputString(const ACaption, APrompt: String;
	var Value: String;
	EditColor: TColor = clWindow;
   EditFontColor: TColor = clWindowText): Boolean;
var
	Form: TForm;
	Edit: TEdit;
begin
	Result:=False;
	Form:=TForm.Create(Application);
	With Form do
		try
			With Font do
            begin
               Assign(Application.MainForm.Font);
               Size:=8;
            end;
//			BorderStyle:=bsDialog;
			BorderStyle:=bsSizeToolWin;
         If ACaption = '' then Caption:=Application.MainForm.Caption else Caption:=ACaption;
			ClientWidth:=250;
			ClientHeight:=90;
			With Constraints do
				begin
					MinHeight:=Height;
					MaxHeight:=Height;
               MinWidth:=200;
				end;
			Position:=poScreenCenter;
			Edit:=TEdit.Create(Form);
			With Edit do
				begin
					Parent:=Form;
               Color:=EditColor;
               Font.Color:=EditFontColor;
					SetBounds(8, 27, 238, 21);
               Anchors:=[akLeft, akRight, akTop];
					Text:=Value;
					SelectAll;
				end;
			With TLabel.Create(Form) do
				begin
					Parent:=Form;
					SetBounds(8, 8, 50, 13);
					Caption:=APrompt;
               FocusControl:=Edit;
				end;
			With TBevel.Create(Form) do
				begin
					Parent:=Form;
					Shape:=bsFrame;
					SetBounds(4, 4, 242, 52);
					Anchors:=[akLeft, akRight, akTop];
				end;
			With TButton.Create(Form) do
				begin
					Parent:=Form;
					Caption:='OK';
					ModalResult:=mrOk;
					Default:=True;
					SetBounds(8, 60, 75, 25);
				end;
			With TButton.Create(Form) do
				begin
					Parent:=Form;
					Caption:='Отмена';
					ModalResult:=mrCancel;
					Cancel:=True;
					SetBounds(85, 60, 75, 25);
				end;
			If ShowModal = mrOk then
				begin
					Value:=Edit.Text;
					Result:=True;
				end;
		finally
			Form.Free;
		end;
end;

function OpenFileDlg(var AFileName: String; AFilter: String = ''): Boolean;
begin
	If AFilter = '' then AFilter:='Все файлы|*.*|Программы (exe, com)|*.exe;*.com|Картинки (bmp, jpg)|*.bmp;*.jpg';
	With TOpenDialog.Create(Application) do
		try
			Filter:=AFilter;
			Options:=[ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing, ofNoDereferenceLinks];
			FileName:=AFileName;
			Result:=Execute;
			If Result then AFileName:=FileName;
		finally
         Free;
      end;
end;

function SaveFileDlg(var AFileName: String; AFilter: String = ''): Boolean;
begin
	If AFilter = '' then AFilter:='Все файлы|*.*|Программы (exe, com)|*.exe;*.com|Картинки (bmp, jpg)|*.bmp;*.jpg';
	With TSaveDialog.Create(Application) do
		try
			Filter:=AFilter;
			Options:=[ofOverwritePrompt, ofHideReadOnly, ofEnableSizing, ofNoDereferenceLinks];
			FileName:=AFileName;
			Result:=Execute;
			If Result then AFileName:=FileName;
		finally
         Free;
      end;
end;

end.
