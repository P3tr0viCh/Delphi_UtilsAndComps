unit Utils_Grid;

interface

uses SysUtils, Grids;

procedure InsertRow   (Sender: TStringGrid; ToIndex: Longint);
procedure DeleteRow   (Sender: TStringGrid; FromIndex: Longint);
procedure InsertColumn(Sender: TStringGrid; ToIndex: Longint);
procedure DeleteColumn(Sender: TStringGrid; FromIndex: Longint);

implementation

type
   TCSGrid = class(TStringGrid)
   private
   public
      procedure MoveRow   (FromIndex, ToIndex: Longint);
      procedure MoveColumn(FromIndex, ToIndex: Longint);
   end;

procedure TCSGrid.MoveRow(FromIndex,ToIndex: Longint);
begin
   RowMoved(FromIndex, ToIndex);
end;

procedure TCSGrid.MoveColumn(FromIndex, ToIndex: Longint);
begin
   ColumnMoved(FromIndex, ToIndex);
end;

procedure InsertRow(Sender: TStringGrid; ToIndex: Longint);
var
   xx, yy: Integer;
begin
   If ToIndex >= 0 then
      with TCSGrid(Sender) do
         if ToIndex <= RowCount then
            begin
               RowCount:=RowCount + 1;
               xx:=RowCount - 1;
               For yy:=0 to ColCount - 1 do
                  begin
                     Cells[yy, xx]:=' ';
                     Objects[yy, xx]:=nil;
                  end;
               If ToIndex < RowCount - 1 then
                  MoveRow(RowCount - 1, ToIndex);
            end;
end;

procedure DeleteRow(Sender: TStringGrid; FromIndex: Longint);
begin
   If FromIndex >= 0 then
      with TCSGrid(Sender) do
         if (RowCount > 0) and (FromIndex < RowCount) then
            begin
               If (FromIndex < RowCount - 1) then
                  MoveRow(FromIndex, RowCount - 1);
               Rows[RowCount - 1].Clear;
               RowCount:=RowCount - 1;
            end;
end;

procedure InsertColumn(Sender: TStringGrid; ToIndex: Longint);
var
   xx, yy: Integer;
begin
   If ToIndex >= 0 then
      with TCSGrid(Sender) do
         if (ToIndex <= ColCount) then
            begin
               ColCount:=ColCount + 1;
               xx:=ColCount - 1;
               Cols[xx].BeginUpdate;
               For yy:=0 to RowCount - 1 do
                  begin
                     Cells[xx,yy]:=' ';
                     Objects[xx,yy]:=nil;
                  end;
               Cols[xx].EndUpdate;
               If ToIndex < ColCount - 1 then
                  MoveColumn(ColCount - 1, ToIndex);
            end;
end;

procedure DeleteColumn(Sender: TStringGrid; FromIndex: Longint);
begin
   If FromIndex >= 0 then
      with TCSGrid(Sender) do
         if (ColCount > 0) and (FromIndex < ColCount) then
            begin
               If (FromIndex < ColCount - 1) then
                  MoveColumn(FromIndex, ColCount - 1);
               Cols[ColCount - 1].Clear;
               ColCount:=ColCount - 1;
            end;
end;

end.