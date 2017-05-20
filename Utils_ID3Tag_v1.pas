unit Utils_ID3Tag_v1;

interface

{$WARN SYMBOL_PLATFORM OFF}
{$WARN UNIT_PLATFORM OFF}
{$DEBUGINFO OFF}

uses
	Windows, SysUtils, Classes, Graphics, Forms, Dialogs, ComObj,
	StdCtrls, ExtCtrls, Controls;

resourcestring
	rsMP3Ext    = '.mp3';

const
	LEN_ID3TAG 	= 128;

	MAX_GENRES = 148;
	GenresArray: array [0..MAX_GENRES] of TIdentMapEntry = (
		(Value: 0;		Name: 'Blues'),
		(Value: 1;		Name: 'Classic Rock'),
		(Value: 2;		Name: 'Country'),
		(Value: 3;		Name: 'Dance'),
		(Value: 4;		Name: 'Disco'),
		(Value: 5;		Name: 'Funk'),
		(Value: 6;		Name: 'Grunge'),
		(Value: 7;		Name: 'Hip-Hop'),
		(Value: 8;		Name: 'Jazz'),
		(Value: 9;		Name: 'Metal'),
		(Value: 10;		Name: 'New Age'),
		(Value: 11;		Name: 'Oldies'),
		(Value: 12;		Name: 'Other'),
		(Value: 13;		Name: 'Pop'),
		(Value: 14;		Name: 'R&B'),
		(Value: 15;		Name: 'Rap'),
		(Value: 16;		Name: 'Reggae'),
		(Value: 17;		Name: 'Rock'),
		(Value: 18;		Name: 'Techno'),
		(Value: 19;		Name: 'Industrial'),
		(Value: 20;		Name: 'Alternative'),
		(Value: 21;		Name: 'Ska'),
		(Value: 22;		Name: 'Death Metal'),
		(Value: 23;		Name: 'Pranks'),
		(Value: 24;		Name: 'Soundtrack'),
		(Value: 25;		Name: 'Euro-Techno'),
		(Value: 26;		Name: 'Ambient'),
		(Value: 27;		Name: 'Trip-Hop'),
		(Value: 28;		Name: 'Vocal'),
		(Value: 29;		Name: 'Jazz+Funk'),
		(Value: 30;		Name: 'Fusion'),
		(Value: 31;		Name: 'Trance'),
		(Value: 32;		Name: 'Classical'),
		(Value: 33;		Name: 'Instrumental'),
		(Value: 34;		Name: 'Acid'),
		(Value: 35;		Name: 'House'),
		(Value: 36;		Name: 'Game'),
		(Value: 37;		Name: 'Sound Clip'),
		(Value: 38;		Name: 'Gospel'),
		(Value: 39;		Name: 'Noise'),
		(Value: 40;		Name: 'AlternRock'),
		(Value: 41;		Name: 'Bass'),
		(Value: 42;		Name: 'Soul'),
		(Value: 43;		Name: 'Punk'),
		(Value: 44;		Name: 'Space'),
		(Value: 45;		Name: 'Meditative'),
		(Value: 46;		Name: 'Instrumental Pop'),
		(Value: 47;		Name: 'Instrumental Rock'),
		(Value: 48;		Name: 'Ethnic'),
		(Value: 49;		Name: 'Gothic'),
		(Value: 50;		Name: 'Darkwave'),
		(Value: 51;		Name: 'Techno-Industrial'),
		(Value: 52;		Name: 'Electronic'),
		(Value: 53;		Name: 'Pop-Folk'),
		(Value: 54;		Name: 'Eurodance'),
		(Value: 55;		Name: 'Dream'),
		(Value: 56;		Name: 'Southern Rock'),
		(Value: 57;		Name: 'Comedy'),
		(Value: 58;		Name: 'Cult'),
		(Value: 59;		Name: 'Gangsta Rap'),
		(Value: 60;		Name: 'Top 40'),
		(Value: 61;		Name: 'Christian Rap'),
		(Value: 62;		Name: 'Pop/Funk'),
		(Value: 63;		Name: 'Jungle'),
		(Value: 64;		Name: 'Native American'),
		(Value: 65;		Name: 'Cabaret'),
		(Value: 66;		Name: 'New Wave'),
		(Value: 67;		Name: 'Psychedelic'),
		(Value: 68;		Name: 'Rave'),
		(Value: 69;		Name: 'Showtunes'),
		(Value: 70;		Name: 'Trailer'),
		(Value: 71;		Name: 'Lo-Fi'),
		(Value: 72;		Name: 'Tribal'),
		(Value: 73;		Name: 'Acid Punk'),
		(Value: 74;		Name: 'Acid Jazz'),
		(Value: 75;		Name: 'Polka'),
		(Value: 76;		Name: 'Retro'),
		(Value: 77;		Name: 'Musical'),
		(Value: 78;		Name: 'Rock & Roll'),
		(Value: 79;		Name: 'Hard Rock'),
		(Value: 80;		Name: 'Folk'),
		(Value: 81;		Name: 'Folk/Rock'),
		(Value: 82;		Name: 'National Folk'),
		(Value: 83;		Name: 'Swing'),
		(Value: 84;		Name: 'Fast-Fusion'),
		(Value: 85;		Name: 'Bebob'),
		(Value: 86;		Name: 'Latin'),
		(Value: 87;		Name: 'Revival'),
		(Value: 88;		Name: 'Celtic'),
		(Value: 89;		Name: 'Bluegrass'),
		(Value: 90;		Name: 'Avantgarde'),
		(Value: 91;		Name: 'Gothic Rock'),
		(Value: 92;		Name: 'Progressive Rock'),
		(Value: 93;		Name: 'Psychedelic Rock'),
		(Value: 94;		Name: 'Symphonic Rock'),
		(Value: 95;		Name: 'Slow Rock'),
		(Value: 96;		Name: 'Big Band'),
		(Value: 97;		Name: 'Chorus'),
		(Value: 98;		Name: 'Easy Listening'),
		(Value: 99;		Name: 'Acoustic'),
		(Value: 100;	Name: 'Humour'),
		(Value: 101;	Name: 'Speech'),
		(Value: 102;	Name: 'Chanson'),
		(Value: 103;	Name: 'Opera'),
		(Value: 104;	Name: 'Chamber Music'),
		(Value: 105;	Name: 'Sonata'),
		(Value: 106;	Name: 'Symphony'),
		(Value: 107;	Name: 'Booty Bass'),
		(Value: 108;	Name: 'Primus'),
		(Value: 109;	Name: 'Porn Groove'),
		(Value: 110;	Name: 'Satire'),
		(Value: 111;	Name: 'Slow Jam'),
		(Value: 112;	Name: 'Club'),
		(Value: 113;	Name: 'Tango'),
		(Value: 114;	Name: 'Samba'),
		(Value: 115;	Name: 'Folklore'),
		(Value: 116;	Name: 'Ballad'),
		(Value: 117;	Name: 'Power Ballad'),
		(Value: 118;	Name: 'Rhythmic Soul'),
		(Value: 119;	Name: 'Freestyle'),
		(Value: 120;	Name: 'Duet'),
		(Value: 121;	Name: 'Punk Rock'),
		(Value: 122;	Name: 'Drum Solo'),
		(Value: 123;	Name: 'A Cappella'),
		(Value: 124;	Name: 'Euro-House'),
		(Value: 125;	Name: 'Dance Hall'),
		(Value: 126;	Name: 'Goa'),
		(Value: 127;	Name: 'Drum & Bass'),
		(Value: 128;	Name: 'Club-House'),
		(Value: 129;	Name: 'Hardcore'),
		(Value: 130;	Name: 'Terror'),
		(Value: 131;	Name: 'Indie'),
		(Value: 132;	Name: 'BritPop'),
		(Value: 133;	Name: 'Negerpunk'),
		(Value: 134;	Name: 'Polsk Punk'),
		(Value: 135;	Name: 'Beat'),
		(Value: 136;	Name: 'Christian Gangsta Rap'),
		(Value: 137;	Name: 'Heavy Metal'),
		(Value: 138;	Name: 'Black Metal'),
		(Value: 139;	Name: 'Crossover'),
		(Value: 140;	Name: 'Contemporary Christian'),
		(Value: 141;	Name: 'Christian Rock'),
		(Value: 142;	Name: 'Merengue'),
		(Value: 143;	Name: 'Salsa'),
		(Value: 144;	Name: 'Thrash Metal'),
		(Value: 145;	Name: 'Anime'),
		(Value: 146;	Name: 'JPop'),
		(Value: 147;	Name: 'Synthpop'),
		(Value: 255;	Name: ' '));

type
	TID3Tag = record
		Artist, Title, Album: ShortString;
		GenreID: Byte;
		Year, Comment: ShortString;
		Track: Byte;
		TagExists: Boolean;
	end;

	TID3Title = (mpAll, mpArtist, mpTitle, mpAlbum, mpGenre, mpYear, mpComment, mpTrack);
	TID3Titles = set of TID3Title;

const
	DefaultID3Tag: TID3Tag = (Artist: ''; Title: ''; Album: '';
									  GenreID: 12; Year: ''; Comment: ''; Track: 0; TagExists: False);

function  GenreIDToGenre(GenreID: Byte): String;
function  GenreToGenreID(Genre: String): Byte;
procedure GetGenresStrings(Genres: TStrings);
function  FindGenreIDInStrings(GenreID: Byte; Genres: TStrings): Integer;

procedure ClearID3Tag(var ID3Tag: TID3Tag);
procedure CheckID3Tag(var ID3Tag: TID3Tag);
function  GetID3Title(ID3Tag: TID3Tag; ID3Title: TID3Title): String;
function  GetID3TitleDef(ID3Title: TID3Title): String;

procedure ReadID3Tag(const FileName: String; var ID3Tag: TID3Tag);
procedure RemoveID3Tag(const FileName: String);
procedure SaveID3Tag(const FileName: String; var ID3Tag: TID3Tag; Save: TID3Titles = [mpAll]);

function ProcessFileName(FileName: String): TID3Tag;
function CreateFileName(ID3Tag: TID3Tag; ID3Title: array of TID3Title;
	Default: Boolean = False): String;
function IsMP3Ext(const FileName: String): Boolean;
function IsMP3File(const FileName: String): Boolean;

implementation

uses Utils_Misc, Utils_Files, Utils_Str;

function GenreIDToGenre(GenreID: Byte): String;
var
	i: Byte;
begin
	Result:='Other';
	For i:=0 to MAX_GENRES do
		if GenresArray[i].Value = GenreID then
			begin
				Result:=GenresArray[i].Name;
				Break;
			end;
end;

function GenreToGenreID(Genre: String): Byte;
var
	i: Byte;
begin
	Result:=12;
	For i:=0 to MAX_GENRES do
		if AnsiSameText(GenresArray[i].Name, Genre) then
			begin
				Result:=GenresArray[i].Value;
				Break;
			end;
end;

procedure GetGenresStrings(Genres: TStrings);
var
	i: Integer;
begin
	If Genres = nil then Exit;
	Genres.Clear;
	For i:=0 to MAX_GENRES do
      Genres.AddObject(GenresArray[i].Name, TObject(GenresArray[i].Value));
end;

function FindGenreIDInStrings(GenreID: Byte; Genres: TStrings): Integer;
var
	i: Integer;
begin
	Result:=-1;
	If Genres = nil then Exit;
	For i:=0 to Genres.Count - 1 do
		if Byte(Genres.Objects[i]) = GenreID then
			begin
				Result:=i;
				Break;
			end;
end;

procedure ClearID3Tag(var ID3Tag: TID3Tag);
begin
	ID3Tag:=DefaultID3Tag;
end;

procedure CheckID3Tag(var ID3Tag: TID3Tag);
begin
   With ID3Tag do
      begin
         Title:= 	TrimRight(Copy(Title,  1, 30));
         Artist:= TrimRight(Copy(Artist, 1, 30));
         Album:= 	TrimRight(Copy(Album,  1, 30));
         Year:=  	TrimRight(Copy(Year,   1, 4));
         Comment:=TrimRight(Copy(Comment, 1,	28));
         If GenreID > MAX_GENRES then GenreID:=12;
      end;
end;

function GetID3Title(ID3Tag: TID3Tag; ID3Title: TID3Title): String;
begin
	With ID3Tag do
      Case ID3Title of
      mpArtist:	Result:=Artist;
      mpTitle:		Result:=Title;
      mpAlbum:		Result:=Album;
      mpGenre:		Result:=GenreIDToGenre(GenreID);
      mpYear:		Result:=Year;
      mpComment:	Result:=Comment;
		mpTrack:		If Track = 0 then Result:='' else Result:=IToS(Track);
		else			Result:='';
      end;
end;

function GetID3TitleDef(ID3Title: TID3Title): String;
begin
	Case ID3Title of
	mpAll:      Result:='Все';
	mpArtist:	Result:='Исполнитель';
	mpTitle:		Result:='Название';
	mpAlbum:		Result:='Альбом';
	mpGenre:		Result:='Жанр';
	mpYear:		Result:='Год';
   mpComment:	Result:='Комментарий';
	mpTrack:		Result:='Дорожка';
	else			Result:='';
	end;
end;

procedure ReadID3Tag(const FileName: String; var ID3Tag: TID3Tag);
var
	i: Integer;
	FileStream: TFileStream;
	ID3: array[0..LEN_ID3TAG - 1] of Char;
	Attrs: Integer;
	FileReadOnly: Boolean;
begin
	ClearID3Tag(ID3Tag);
	Attrs:=FileGetAttr(FileName);
	FileReadOnly:=IsValueInWord(Attrs, faReadOnly);
	If FileReadOnly then OleCheck(FileSetAttr(FileName, Attrs - faReadOnly));
	Try
		FileStream:=TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
		With FileStream do
			Try
				If Size < LEN_ID3TAG then Exit;
				Seek(-LEN_ID3TAG, soEnd);
				Read(ID3, LEN_ID3TAG);
			finally
				Free;
			end;
		For i:=0 to LEN_ID3TAG - 2 do // Last Char = Genre
			begin
				If ID3[i] < #32 then
					Case i of
		{Track}	125, 126: 	If ID3[125] <> #0 then ID3[i]:=Space;
					else
						ID3[i]:=Space;
					end;
			end;
		With ID3Tag do
			begin
				TagExists:=Copy(ID3, 1, 3) = 'TAG';
				If TagExists then
					begin
						Title:= 	TrimRight(Copy(ID3, 4,	30));
						Artist:=	TrimRight(Copy(ID3, 34, 30));
						Album:= 	TrimRight(Copy(ID3, 64, 30));
						Year:=  	TrimRight(Copy(ID3, 94, 4));
                  Comment:=TrimRight(Copy(ID3, 98,	28));
                  Track:=Ord(ID3[126]);
						GenreID:=Ord(ID3[127]);
						If GenreID > MAX_GENRES then GenreID:=12;
					end;
			end;
	finally
		If FileReadOnly then OleCheck(FileSetAttr(FileName, Attrs));
	end;
end;

procedure RemoveID3Tag(const FileName: String);
var
	Tag: array[1..3] of Char;
	FileStream: TFileStream;
	Attrs: Integer;
	FileReadOnly: Boolean;
begin
	Attrs:=FileGetAttr(FileName);
	FileReadOnly:=IsValueInWord(Attrs, faReadOnly);
	If FileReadOnly then OleCheck(FileSetAttr(FileName, Attrs - faReadOnly));
	Try
		FileStream:=TFileStream.Create(FileName, fmOpenReadWrite or fmShareExclusive);
		With FileStream do
			Try
				If Size >= LEN_ID3TAG then
					begin
						Seek(-LEN_ID3TAG, soEnd);
						Read(Tag, 3);
						If Tag = 'TAG' then
							begin
								Seek(-LEN_ID3TAG, soEnd);
								If not SetEndOfFile(FileStream.Handle) then OleError(GetLastError);
							end;
					end;
			finally
				Free;
			end;
	finally
		If FileReadOnly then OleCheck(FileSetAttr(FileName, Attrs));
	end;
end;

procedure SaveID3Tag(const FileName: String; var ID3Tag: TID3Tag; Save: TID3Titles = [mpAll]);
type
	String2	= array[0..1] 	of Char;
	String3	= array[0..2] 	of Char;
	String4 	= array[0..3] 	of Char;
	String30	= array[0..29]	of Char;
	String28	= array[0..27]	of Char;

	TID3 = packed record
		Tag:		String3;
		Title:	String30;
		Artist:	String30;
		Album:	String30;
		Year:		String4;
		Comment:	String28;
		Track:	String2;
		GenreID: Char;
	end;

var
	FileStream: TFileStream;
	Tag: String3;
	ID3: TID3;
	Attrs: Integer;
	FileReadOnly: Boolean;
	SaveTitle, SaveArtist, SaveAlbum, SaveYear, SaveComment, SaveTrack, SaveGenre: Boolean;

	procedure FillArray(var Dest: TID3; const ID3Tag: TID3Tag);

		procedure EmptyArray(var Destination: TID3);
			procedure EmptyString(var Destination: array of Char);
			var
				i: Integer;
			begin
				For i:=0 to High(Destination) do Destination[i]:=#0;
			end;
		begin
			EmptyString(Destination.Tag);
			EmptyString(Destination.Title);
			EmptyString(Destination.Artist);
			EmptyString(Destination.Album);
			EmptyString(Destination.Year);
			EmptyString(Destination.Comment);
			EmptyString(Destination.Track);
			Destination.GenreID:=#12;
		end;

		procedure InsertToArray(var Destination: array of Char; Source: String);
		var
			i: Integer;
		begin
			For i:=0 to Length(Source) - 1 do Destination[i]:=Source[i + 1];
		end;
	begin
		EmptyArray(Dest);
		With ID3Tag do
			begin
				InsertToArray(Dest.Tag, 'TAG');
				If SaveTitle	then InsertToArray(Dest.Title, 	Title);
				If SaveArtist 	then InsertToArray(Dest.Artist,	Artist);
				If SaveAlbum 	then InsertToArray(Dest.Album, 	Album);
				If SaveYear 	then InsertToArray(Dest.Year, 	Year);
				If SaveComment	then InsertToArray(Dest.Comment, Comment);
				If SaveTrack	then
					begin
						InsertToArray(Dest.Track, #0 + Chr(Track));
					end;
				If SaveGenre 	then Dest.GenreID:=Chr(GenreID);
			end;
	end;
begin
	If mpAll in Save then
		begin
			SaveTitle:=True; SaveArtist:=True;  SaveAlbum:=True;
			SaveYear:=True;  SaveComment:=True; SaveTrack:=True; SaveGenre:=True;
		end
	else
		begin
			SaveTitle:=mpTitle		in Save; SaveArtist:=mpArtist		in Save;
			SaveAlbum:=mpAlbum		in Save; SaveYear:=mpYear			in Save;
			SaveComment:=mpComment	in Save; SaveGenre:=mpGenre		in Save;
			SaveTrack:=mpTrack		in Save;
		end;
   CheckID3Tag(ID3Tag);
	FillArray(ID3, ID3Tag);

	Attrs:=FileGetAttr(FileName);
	FileReadOnly:=IsValueInWord(Attrs, faReadOnly);
	If FileReadOnly then OleCheck(FileSetAttr(FileName, Attrs - faReadOnly));
	Try
		FileStream:=TFileStream.Create(FileName, fmOpenReadWrite or fmShareExclusive);
		With FileStream do
			Try
				If Size >= LEN_ID3TAG then
					begin
						Seek(-LEN_ID3TAG, soEnd);
						Read(Tag, 3);
						ID3Tag.TagExists:=Tag = 'TAG';
						If ID3Tag.TagExists then Seek(-LEN_ID3TAG, soEnd)
												  else Seek(0, soEnd);
					end
				else
					begin
						Seek(0, soEnd);
						ID3Tag.TagExists:=False;
					end;
				If ID3Tag.TagExists then
					begin
						Write(ID3.Tag, 3);
						Seek(-LEN_ID3TAG + 3, soEnd);
						If SaveTitle	then Write(ID3.Title, 30)
											else Seek(-LEN_ID3TAG + 33, soEnd);
						If SaveArtist	then Write(ID3.Artist, 30)
											else Seek(-LEN_ID3TAG + 63, soEnd);
						If SaveAlbum	then Write(ID3.Album, 30)
											else Seek(-LEN_ID3TAG + 93, soEnd);
						If SaveYear		then Write(ID3.Year, 4)
											else Seek(-LEN_ID3TAG + 97, soEnd);
						If SaveComment	then Write(ID3.Comment, 28)
						               else Seek(-LEN_ID3TAG + 125, soEnd);
                  If SaveTrack 	then Write(ID3.Track, 2)
                                 else Seek(-LEN_ID3TAG + 127, soEnd);
						If SaveGenre 	then Write(ID3.GenreID, 1);
					end
				else
					Write(ID3, LEN_ID3TAG); // Tag not Exists
            ID3Tag.TagExists:=True;
			finally
				Free;
			end;
	finally
		If FileReadOnly then OleCheck(FileSetAttr(FileName, Attrs));
	end;
end;

function ProcessFileName(FileName: String): TID3Tag;
var
	P: Integer;
   OnlyName: String;
begin
   ClearID3Tag(Result);
	OnlyName:=OnlyFileName(FileName);
	With Result do
   	begin
   		P:=Pos(' - ', OnlyName);
         If P <> 0 then
            begin
               Artist:=Copy(Copy(OnlyName, 1, P - 1), 1, 30);
               Title:=Copy(Copy(OnlyName, P + 3, MaxInt), 1, 30);
            end
         else
            begin
               Artist:=Copy(ExtractFileName(DelBS(ExtractFilePath(FileName))), 1, 30);
               Title:=Copy(OnlyName, 1, 30);
            end;
         TagExists:=True;
      end;
end;

function CreateFileName(ID3Tag: TID3Tag; ID3Title: array of TID3Title;
	Default: Boolean = False): String;
const
	ID3Sep = ' - ';
var
	i: Integer;
   S: String;

   function GetS(Index: Integer): String;
   begin
   	If Default then Result:='[' + GetID3TitleDef(ID3Title[Index]) + ']'
   				  else Result:=GetID3Title(ID3Tag, ID3Title[Index]);
	end;

	function NeedAll: Boolean;
	var
		i: Integer;
	begin
		Result:=False;
		For i:=Low(ID3Title) to High(ID3Title) do
			if ID3Title[i] = mpAll then
				begin
					Result:=True;
					Break;
				end;
	end;

begin
	Result:='';
	If (SizeOf(ID3Title) = 0) or ((not ID3Tag.TagExists) and (not Default)) then Exit;
	If NeedAll then
		Result:=CreateFileName(ID3Tag, [mpArtist, mpTitle, mpAlbum, mpGenre, mpYear, mpComment, mpTrack], Default)
	else
		For i:=Low(ID3Title) to High(ID3Title) do
			begin
				S:=GetS(i);
				If S <> '' then
					begin
						If Result = '' then Result:=S else Result:=Result + ID3Sep + S;
					end;
			end;
end;

function IsMP3Ext(const FileName: String): Boolean;
begin
	Result:=CompareText(ExtractFileExt(FileName), rsMP3Ext) = 0;
end;

function IsMP3File(const FileName: String): Boolean;
begin
   Result:=FileExists(FileName) and IsMP3Ext(FileName);
end;

{
   The ID3 Information ver. 1 is stored in the last 128 bytes of an ID3 file.
   The ID3 has the following fields,
   and the offsets given here, are from 0-127

   Field       Length            Offsets
   -------------------------------------
	Tag           	3                	0-2
   Title     		30                3-32
   Artist       	30                33-62
   Album        	30                63-92
	Year          	4                	93-96
If Offset[125] = 0 then
	Comment      	28                97-124
	Track				1						126
else if
	Comment      	30                97-126
end if
	Genre         	1                	127
}

end.
