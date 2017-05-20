unit Utils_SQL;

interface

uses
  System.SysUtils, Vcl.Forms, Data.DB, Data.Win.ADODB, System.Variants,
  Utils_Files, Utils_Misc, Utils_Str;

resourcestring
  rsConnectionMDB = 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=%s;Persist Security Info=False;User ID=%s;Jet OLEDB:Database Password="%s";';

  rsDateTimeFormatMDB  = '#M"/"d"/"yyyy" "h":"m":"s#';

  rsErrorMDBNotExists = 'База данных "%s" не найдена';

  rsSQLNull      = 'NULL';

procedure UseADOQuery(Q: TADOQuery);

function ConnectToMDB(ADOConnection: TADOConnection;
  AFileName: TFileName = ''; AUserName: String = ''; AUserPass: String = ''): Boolean;

procedure SQLOpen(ASQLString: String);
procedure SQLExec(ASQLString: String);
function  SQLGetCount(ASQLString: String): Integer;

function  SQLFormatValue(AValue: Variant): String;
function  SQLFormatValues(AValues: array of Variant): String;

function  DTToMDBStr(ADateTime: TDateTime): String;

implementation

var
  ADOQuery: TADOQuery;

procedure UseADOQuery(Q: TADOQuery);
begin
  ADOQuery := Q;
end;

function ConnectToMDB(ADOConnection: TADOConnection;
  AFileName: TFileName = ''; AUserName: String = ''; AUserPass: String = ''): Boolean;
begin
  if AFileName = '' then
    AFileName := ChangeFileExt(Application.ExeName, '.mdb');
  if AUserName = '' then
    AUserName := 'Admin';

  Result := FileExists(AFileName);
  if not Result then
    begin
      MsgBoxErr(Format(rsErrorMDBNotExists, [AFileName]));
      Exit;
    end;

  ADOConnection.ConnectionString := Format(rsConnectionMDB,
    [AFileName, AUserName, AUserPass]);
  try
    ADOConnection.Open;
  except
    on E: Exception do MsgBoxErr(E.Message);
  end;

  Result := ADOConnection.Connected;
end;

procedure SQLOpen(ASQLString: String);
begin
  ADOQuery.SQL.Text := ASQLString;
//  MsgBox(ASQLString); Exit;
  ADOQuery.Open;
end;

procedure SQLExec(ASQLString: String);
begin
  ADOQuery.SQL.Text := ASQLString;
//  Clipboard.AsText := ASQLString;
//  MsgBox(ASQLString); Exit;
  ADOQuery.ExecSQL;
end;

function  SQLGetCount(ASQLString: String): Integer;
begin
//  MsgBox(ASQLString); Exit;
  SQLOpen(ASQLString);
  try
    Result := ADOQuery.Fields[0].AsInteger;
  finally
    ADOQuery.Close;
  end;
end;

function  SQLFormatValue(AValue: Variant): String;
begin
  Result := VarToStr(AValue);
  case VarType(AValue) of
  varDate:   Result := DTToMDBStr(VarToDateTime(AValue));
  varUString,
  varString: //if Result <> rsSQLNull then
      Result := AddQuotes(
        StringReplace(StringReplace(StringReplace(Result,
          '\',  '\\',  [rfReplaceAll]),
          '"',  '\"',  [rfReplaceAll]),
          '''', '\''', [rfReplaceAll]));
  varDouble:  Result := StringReplace(Result, COMMA, DOT, []);
  varNull:    Result := rsSQLNull;
  end;
end;

function  SQLFormatValues(AValues: array of Variant): String;
var
  I: Integer;
begin
  Result := '';
  for I := Low(AValues) to High(AValues) do
    Result := ConcatStrings(Result, SQLFormatValue(AValues[i]), ', ');
end;

function  DTToMDBStr(ADateTime: TDateTime): String;
begin
  Result := FormatDateTime(rsDateTimeFormatMDB, ADateTime);
end;

end.
