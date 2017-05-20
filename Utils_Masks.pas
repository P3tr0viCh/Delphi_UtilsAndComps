unit Utils_Masks;

interface

uses SysUtils, Classes, Masks, Utils_Misc;

type
  TMultiMask = class(TCollectionItem)
    FMask: TMask;
  public
    destructor Destroy; override;
  end;

procedure CreateMasks(ACol: TCollection; AStr: String);
function  MultiMatches(Masks: TCollection; N: String): Boolean;

implementation

procedure CreateMasks(ACol: TCollection; AStr: String);
var
   P: TMultiMask;
   i: Integer;
   S: String;
begin
	i:=1; S:='';
   Acol.Clear;
   While i <= Length(AStr) do
      begin
         Case AnsiChar(AStr[i]) of
         ' ':	begin
                  If S = '' then Inc(i)
                  else
                     begin
                        S:=S + AStr[i];
                        If i = Length(AStr) then
                           begin
                              While AnsiLastChar(S)^ = ' ' do
                                 S:=Copy(S, 1, Length(S)-1);
                              P:=TMultiMask(ACol.Add);
                              P.FMask:=TMask.Create(S);
                              Exit;
                           end
                        else Inc(i);
                     end;
               end;
         ';':	begin
                  While AnsiLastChar(S)^ = ' ' do
                     S:=Copy(S, 1, Length(S) - 1);
                  P:=TMultiMask(ACol.Add);
                  P.FMask:=TMask.Create(S);
                  S:='';
                  If i = Length(AStr) then Exit else Inc(i);
               end;
         else
            begin
               S:=S + AStr[i];
               If i = Length(AStr) then
                  begin
                     While AnsiLastChar(S)^ = ' ' do
                        S:=Copy(S, 1, Length(S)-1);
                     P:=TMultiMask(ACol.Add);
                     P.FMask:=TMask.Create(S);
                     Exit;
                  end
               else Inc(i);
            end;
         end;
	end;
end;

function MultiMatches(Masks: TCollection; N: String): Boolean;
var
   i: Integer;
begin
   Result:=True; 
   For i:=0 to Masks.Count - 1 do
     if TMultiMask(Masks.Items[i]).FMask.Matches(N) then Exit;
   Result:=False;
end;

destructor TMultiMask.Destroy;
begin
  if Assigned(FMask) then FMask.Free;
  inherited;
end;

end.
