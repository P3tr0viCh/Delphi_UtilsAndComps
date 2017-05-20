unit Utils_Base64;

interface

{$DEBUGINFO OFF}

function Encrypt(const S: AnsiString; Key: Word): AnsiString;  // Кодировать
function Decrypt(const S: AnsiString; Key: Word): AnsiString;  // Декодировать

implementation

const
  C1 = 52845;
  C2 = 22719;

function Decode(const S: AnsiString): AnsiString;
const
  Map: array[AnsiChar] of Byte = (
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 62, 0, 0, 0, 63, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61,
    0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
    21, 22, 23, 24, 25, 0, 0, 0, 0, 0, 0, 26, 27, 28, 29, 30,
    31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50,
    51, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
var
  i: LongInt;
begin
  case Length(S) of
  2: begin
    i := Map[S[1]] + (Map[S[2]] shl 6);
    SetLength(Result, 1);
    Move(I, Result[1], Length(Result))
  end;
  3: begin
    i := Map[S[1]] + (Map[S[2]] shl 6) + (Map[S[3]] shl 12);
    SetLength(Result, 2);
    Move(I, Result[1], Length(Result))
  end;
  4: begin
    i := Map[S[1]] + (Map[S[2]] shl 6) + (Map[S[3]] shl 12) + (Map[S[4]] shl 18);
    SetLength(Result, 3);
    Move(I, Result[1], Length(Result))
  end;
  end;
end;

function Encode(const S: AnsiString): AnsiString;
const
  Map: array[0..63] of AnsiChar = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
var
  i: LongInt;
begin
  i :=  0;
  Move(S[1], i, Length(S));
  case Length(S) of
  1: Result := Map[i mod 64] + Map[(i shr 6) mod 64];
  2: Result := Map[i mod 64] + Map[(i shr 6) mod 64] + Map[(i shr 12) mod 64];
  3: Result := Map[i mod 64] + Map[(i shr 6) mod 64] + Map[(i shr 12) mod 64] + Map[(i shr 18) mod 64]
  end;
end;

function PrePostProcess(const S: AnsiString; DoPre: Boolean): AnsiString;
const
  X: array[Boolean] of Byte = (3, 4);
var
  SS: AnsiString;
begin
  SS := S;
  Result := '';
  while SS <> '' do
    begin
      if DoPre then Result := Result + Decode(Copy(SS, 1, X[DoPre]))
               else Result := Result + Encode(Copy(SS, 1, X[DoPre]));
      Delete(SS, 1, X[DoPre]);
    end;
end;

function InternalDecryptEncrypt(const S: AnsiString; Key: Word; DoDecrypt: Boolean): AnsiString;
var
  i: Word;
  Seed: Word;
begin
  Result := S;
  Seed := Key;
  for i := 1 to Length(Result) do
    begin
      Result[i] := AnsiChar(Byte(Result[i]) xor (Seed shr 8));
      if DoDecrypt then Seed := Byte(S[i]) + Seed
                   else Seed := Byte(Result[i]) + Seed;
      Seed := Seed * Word(C1) + Word(C2)
    end;
end;

function Decrypt(const S: AnsiString; Key: Word): AnsiString;
begin
  Result := InternalDecryptEncrypt(PrePostProcess(S, True), Key, True);
end;

function Encrypt(const S: AnsiString; Key: Word): AnsiString;
begin
  Result := PrePostProcess(InternalDecryptEncrypt(S, Key, False), False);
end;

end.
