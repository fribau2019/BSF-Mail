UNIT FREDUNIT;

Interface
Uses DOS, CRT, NetLog, RmDoor, VariaNet;

 Function NombreConfActive : Integer;
 Function Exist( sExp: STRING ): BOOLEAN;
 Function Blanc(SST: String) : String;
 Function CMajMin(Chaine : String) : String;
 Function NodeSys(Point : Byte; SFDir : String) : String;
 Function Compres(Point : Byte; Posis : Byte) : String;
 Function PosComp(Lettre : Char) : Byte;
 Function Protoc(Point : Byte; Posis : Byte) : String;
 Function PosProto(Lettre : Char) : Byte;
 Function SFMSG(Rec : Integer) : String;
 Function NomIDX(Rec : Integer) : String;
 Function YN(Debut : Boolean) : String;
 Function Caff(Debut : Integer): String;
 Function MAJ(S : String) : String;
 Function IntToStr(I: Longint): String;
 Function StrToInt(I: String) : LongInt;
 Function Time : String;
 Function Date(Nombre : Byte) : String;
 Function ConvertSFToNET ( A : String) : String;
 function Day_diff(day_1, month_1, year_1, day_2, month_2, year_2: integer) : longint;
 function Valid_date(day, month, year: integer) : boolean;
 Function Nubase(numin : LongInt; base, numplaces : Byte) : String;
 Function HexToInt(HE : String) : Byte;
 Function Downcase( Carac : Char) : Char;
 Function MajMin(Chaine : String) : String;
 Function Flags(Numero : Byte) : String;
 Function NewsFiles(SFDIR : String; Sec : Integer; Date : String) : Integer;
 Procedure LectureFicheUser(RecUser : Integer);
 Procedure EffaceSecour;
 Procedure RealToMsb (preal : real; var B : Bsingle);
 Procedure Pause;
 Procedure BIP1;

Implementation
Var F   : Integer;
    S   : Longint;
    Nom : String[8];
    Ligne : String[78];

{---------------------------------------------------------------------------}


{---------------------------------------------------------------------------}
Function NombreConfActive : Integer;
Begin;
  TotalCf := 0;
  For I := 0 To Register Do If User.Conf.Attribut[I] <> 0 Then Inc(TotalCf);
  If TotalCf = 0 Then Begin;
                       RmWriteln(''); RmWriteln('þþþ Please Select Conference First ! þþþ'); RmWriteln('');
                       Delay(1300);
                      End;
  NombreConfActive := TotalCf-1;
End;

{---------------------------------------------------------------------------}
Procedure LectureFicheUSer(RecUser : Integer);
Begin;
(* Lecture De La Fiche User *)
  Assign(USR, 'NETUSERS.DAT');
   Reset(USR);
   Seek(USR, RecUser);
   Read(USR, User);
  Close(USR);
End;
{---------------------------------------------------------------------------}
Procedure EffaceSecour;
Var F : File;
Begin;
  {$I-}
  Close(LM);
  Close(DataM);
  Close(IDX);
  Close(NdXf);
  Close(PTR);
  Close(Msgs);
  Close(Message);
  Close(Perso);
  {$I+}
  If IoResult <> 0 Then;

  {$I-} MkDir('$$$NET$$'); {$I-}
  If Ioresult = 0 Then Begin;
                        RmDir('$$$NET$$');
                        Exit;
                       End
  Else Begin;
  Repeat
   FindFirst('$$$NET$$\*.*', Archive, DirInfo);
  While DosError = 0 Do Begin;
                        Assign(F, '$$$NET$$\'+DirInfo.Name);
                        Erase(F);
                        FindNext(DirInfo);
                        End;
  Until DosError <> 0;
  RmDir('$$$NET$$');
       End;
End;
{---------------------------------------------------------------------------}
Procedure realtomsb (preal : real; var b : Bsingle);
var
         r : array [0 .. 5] of byte absolute preal;
Begin
         b [3] := r [0];
         move (r [3], b [0], 3);
End;
{---------------------------------------------------------------------------}
Function ConvertSFToNET ( A : String) : String;

Begin;

 For F := 0 To Length(A) Do If Ord(A[F]) = 1 Then A[F] := 'ã' Else A[F] := A[F];

   If Length(A) < 127 Then A := A + Copy('                                                                ',1, 127-Length(A));
   If Length(A) < 127 Then A := A + Copy('                                                                ',1, 127-Length(A));
   If Length(A) < 127 Then A := A + Copy('                                                                ',1, 127-Length(A));
   If Length(A) < 127 Then A := A + Copy('                                                                ',1, 127-Length(A));
   If Length(A) < 127 Then A := A + Copy('                                                                ',1, 127-Length(A));
   If Length(A) < 127 Then A := A + Copy('                                                                ',1, 127-Length(A));
   If Length(A) < 127 Then A := A + Copy('                                                                ',1, 127-Length(A));

   ConvertSFToNet := A;

End;

{---------------------------------------------------------------------------}
Function YN(Debut : Boolean) : String;

Begin;
  If Debut = True  Then YN := 'YES';
  If Debut = False Then YN := 'NO ';
End;

{---------------------------------------------------------------------------}
Function Caff(Debut : Integer): String;

Begin;
 If Debut < 0   Then Caff := '  ';
 If Debut = 0   Then Caff := '  ';
 If Debut = 1   Then Caff := ' A';
 If Debut = 2   Then Caff := ' Y';
 If Debut = 3   Then Caff := ' P';
 If Debut = 100 Then Caff := 'N ';
 If Debut = 101 Then Caff := 'NA';
End;

{-------------------------------------------------------------------------}
Function MAJ(S : String) : String;
Begin;
For F := 1 to Length(s) do
  s[F] := UpCase(s[F]);
  MAJ := S;
End;
{---------------------------------------------------------------------------}
Function STRToInt (I : String) : LongINt;
Begin;
  Val(I, S, F);
  If F <> 0 Then StrToInt := 0;
  StrToInt := S;
End;
{---------------------------------------------------------------------------}
function IntToStr(I: Longint): String;
var
 S: string[11];
begin
 Str(I, S);
 IntToStr := S;
end;

{-------------------------------------------------------------------------}

Function Time : String;

var
  h, m, s, hund : Word;
  HH, MM, SS : String[2];

begin
  GetTime(h,m,s,hund);

  HH := IntToStr(h); If H < 10 Then HH := '0'+HH;
  MM := IntToStr(m); If m < 10 Then mm := '0'+mm;
  SS := IntToStr(s); If s < 10 Then ss := '0'+ss;

  Time := HH+':'+MM+':'+SS;
end;

{-------------------------------------------------------------------------}
Function Date(Nombre : Byte) : String;
var
  y, m, d, dow : word;
  aa, mm, jj : String[4];
begin
  GetDate(y,m,d,dow);
  If Nombre = 1 Then AA := IntToStr(y);
  If Nombre = 0 Then Begin;
                       AA := IntToStr(y);
                       AA := Copy(AA,3,2);
                       If y < 10 Then AA := '0'+AA;
                      End;
  MM := IntToStr(m); If m < 10 Then MM := '0'+MM;
  JJ := IntToStr(d); If d < 10 Then JJ := '0'+JJ;

  Date := MM+'-'+JJ+'-'+AA;
End;

{---------------------------------------------------------------------------}
Function Date1 : String;
var
  y, m, d, dow : word;
  aa, mm, jj : String[4];
begin
  GetDate(y,m,d,dow);
  AA := IntToStr(y); If y < 10 Then AA := '0'+AA; AA := Copy(AA,3,2);
  MM := IntToStr(m); If m < 10 Then MM := '0'+MM;
  JJ := IntToStr(d); If d < 10 Then JJ := '0'+JJ;

  Date1 := MM+'-'+JJ+'-'+AA;
End;

{---------------------------------------------------------------------------}
Procedure Pause;
Begin;
 Repeat Until Keypressed;
End;

{---------------------------------------------------------------------------}
function serial_day(day, month, year: integer) : longint;
var  m, y : longint;
   begin
      if month > 2 then begin
         m := month - 3;
         y := year;
      end
      else begin
         m := month + 9;
         y := year - 1;
      end;

      serial_day :=
         ((y div 100) * 146097) div 4 +
         ((y mod 100) * 1461) div 4 +
         (153 * m + 2) div 5 + day;
   end;



function day_diff(day_1, month_1, year_1, day_2, month_2, year_2: integer)
   : longint;

   begin
   day_diff := serial_day(day_2, month_2, year_2) -
      serial_day(day_1, month_1, year_1);
   end;
{---------------------------------------------------------------------------}
Procedure BIP1;

Begin;
Write(^g);
End;
{---------------------------------------------------------------------------}
function leap_year(year: integer) : integer;

   begin
   if year and 3 <> 0 then leap_year := 0
   else if year mod 100 <> 0 then leap_year := 1
   else if year mod 400 <> 0 then leap_year := 0
   else leap_year := 1;
   end;

function ordinal_day (day, month, year: integer) : integer;

   var od: integer;
   begin
   if month < 3 then
      month := month + 10
   else
      month := month - 2;
   od := (306 * month - 2) div 10 - 30;
   if od < 306 then
      ordinal_day := od + 59 + leap_year(year) + day
   else
      ordinal_day := od - 306 + day;
   end;

procedure from_ordinal_day (ordinal_day, year: integer;
    var day, month: integer);
   var lyf, adj_mo: integer;
   begin
   lyf := leap_year(year) + 60;
   if ordinal_day < lyf then
      ordinal_day := ordinal_day + 305
   else
      ordinal_day := ordinal_day - lyf;
   adj_mo := (ordinal_day * 10 + 4) div 306 + 1;
   day := ordinal_day - ((adj_mo * 306 - 2) div 10 - 30) + 1;
   if adj_mo < 11 then
      month := adj_mo + 2
   else
      month := adj_mo - 10;
   end;


function valid_date(day, month, year: integer) : boolean;
   var od, m, d: integer;
   begin
   od := ordinal_day(day, month, year);
   if (od > 366) or (od < 1) then
      valid_date := false
   else begin
      from_ordinal_day(od, year, d, m);
      if (d = day) and (m = month) then valid_date := true
      else valid_date := false
   end;
   end;
{---------------------------------------------------------------------------}
Function nubase(numin : LongInt; base, numplaces : Byte) : String;
Var
  tmpstr    : String;
  remainder : Byte;
  negatize  : Boolean;
begin
  negatize := (numin < 0);              { Record if it's a negative number }
  if negatize then
    numin := abs(numin);                { convert to positive For calcs }
  tmpstr[0] := Char(numplaces);         { set length of the output String }

  While numplaces > 0 do
  begin                                 { Loop: fills each space in String }
    remainder := numin mod base;        { get next "digit" (under new base) }
    if remainder > 9 then
      tmpstr[numplaces] := Char(remainder + 64 - 9)   { convert to letter }
     else
      tmpstr[numplaces] := Char(remainder + 48);      { use number as is }
    numin := numin div base;            { reduce dividend For next "pass" }
    numplaces := numplaces - 1;         { go to "next" position in String }
  end;                                  { end of loop }

  { The following: if we've run out of room on the String, or if it's a
    negative number and there's not enough space For the "minus" sign,
    convert the output String to all asterisks. }

  if (numin <> 0) or (negatize and (tmpstr[1] <> '0')) then
    For numplaces := 1 to Byte(tmpstr[0]) do
      tmpstr[numplaces] := '*';

  { add minus sign }

  if negatize and (tmpstr[1] = '0') then
    tmpstr[1] := '-';

  nubase := tmpstr;
end;


{---------------------------------------------------------------------------}
Function HexToInt(HE : String) : Byte;
VAR
 H1, H2 : Integer;
 H      : String[1];
Begin;
  H := Copy(He, 1,1);
  H :=MAJ(H);
  If H = '0' Then H1 := 0;
  If H = '1' Then H1 := 1;
  If H = '2' Then H1 := 2;
  If H = '3' Then H1 := 3;
  If H = '4' Then H1 := 4;
  If H = '5' Then H1 := 5;
  If H = '6' Then H1 := 6;
  If H = '7' Then H1 := 7;
  If H = '8' Then H1 := 8;
  If H = '9' Then H1 := 9;
  If H = 'A' Then H1 := 10;
  If H = 'B' Then H1 := 11;
  If H = 'C' Then H1 := 12;
  If H = 'D' Then H1 := 13;
  If H = 'E' Then H1 := 14;
  If H = 'F' Then H1 := 15;
  H := Copy(He, 2,1);
  H :=MAJ(H);
  If H = '0' Then H2 := 0;
  If H = '1' Then H2 := 1;
  If H = '2' Then H2 := 2;
  If H = '3' Then H2 := 3;
  If H = '4' Then H2 := 4;
  If H = '5' Then H2 := 5;
  If H = '6' Then H2 := 6;
  If H = '7' Then H2 := 7;
  If H = '8' Then H2 := 8;
  If H = '9' Then H2 := 9;
  If H = 'A' Then H2 := 10;
  If H = 'B' Then H2 := 11;
  If H = 'C' Then H2 := 12;
  If H = 'D' Then H2 := 13;
  If H = 'E' Then H2 := 14;
  If H = 'F' Then H2 := 15;

  HexToInt := (H1+1)*(H2+1)-1;

End;

{---------------------------------------------------------------------------}
Function Downcase( Carac : Char) : Char;
Begin;
  F := Ord(Carac);
  If ( (F>=65) And (F<=90)) Then Downcase := Chr(F+32) Else Downcase := Chr(F);
End;
{---------------------------------------------------------------------------}
Function MajMin(Chaine : String) : String;
Var I : Integer;
Begin;
 Chaine[1] := Upcase(Chaine[1]);
 For F := 2 To Length(Chaine) Do Begin;
                                  I := Ord(Chaine[F]);
                                  If ( (I>=65) And (I<=90)) Then
                                   Chaine[F] := Chr(I+32)
                                  Else
                                   Chaine[F] := Chr(I);
                                 End;
 MajMin := Chaine;
End;
{---------------------------------------------------------------------------}
Function CMajMin(Chaine : String) : String;
Var I : Integer;
Begin;
 Chaine[1] := UpCase(Chaine[1]);
 F := 2;
 Repeat

 I := Ord(Chaine[F]);

 If ( (I>=65) And (I<=90)) Then Chaine[F] := Chr(I+32) Else Chaine[F] := Chr(I);

 If I = 32 Then Begin;
                 Inc(F);
                 I := Ord(Chaine[F]);
                 If ( (I>=65) And (I<=90)) Then Chaine[F] :=  Upcase(Chr(I));
                End;
  WriteLn(Chaine);
 Inc(F);
 Until F >= Length(Chaine);
End;


{---------------------------------------------------------------------------}
Function NomIDX(Rec : Integer) : String;
Begin;
 Nom := '';
 If Rec < 9  Then Nom := '00'+IntToStr(Rec+1);
 If Rec >=9  Then If Rec < 99 Then Nom := '0'+IntToStr(Rec+1);
 If Rec >=99 Then Nom := IntToStr(Rec+1);
 NomIDX := Nom;
End;
{---------------------------------------------------------------------------}
Function SFMSG(Rec : Integer) : String;
Begin;
 Nom := '';
 If Rec < 9  Then Nom := 'SFMSG0'+IntToStr(Rec+1)
  Else Nom := 'SFMSG'+IntToStr(Rec+1);
 SFMSG := Nom;
End;

{---------------------------------------------------------------------------}
Function Flags(Numero : Byte) : String;
Begin;
 If Numero < 0   Then Flags := ' NONE';
 If Numero = 0   Then Flags := ' NONE';
 If Numero = 1   Then Flags := ' ALL ';
 If Numero = 2   Then Flags := 'P/ALL';
 If Numero = 3   Then Flags := 'PERSO';
 If Numero = 101 Then Flags := ' NET ';
 If Numero > 101 Then Flags := ' NONE';
End;
{---------------------------------------------------------------------------}
Function Protoc(Point : Byte; Posis : Byte) : String;
TYPE
  ConfigurationProtocoles = RECORD
                        Lettre      : String[01];
                        Name        : String[20];
                        Send        : String[60];
                        Receive     : String[60];
  End;
VAR
    Proto      : ConfigurationProtocoles;
    Protocol   : File Of ConfigurationProtocoles;

Begin;
 Assign(Protocol, 'NETPROTO.DAT');
 {$I-} Reset(Protocol); {$I+}
 If Ioresult <> 0 Then Begin;
                        Writeln(' File NETPROTO.DAT Not Found !');
                        Writeln(' Halting ...');
                        Halt(1);
                       End
    Else Begin;
{$I-}     Seek(Protocol, Posis);
          Read(Protocol, Proto); {$I+}
         End;
 {$I-} Close(Protocol); {$I+}
 If Ioresult <> 0 Then ;

 If ( (Proto.Lettre >= 'A') And (Proto.Lettre <= 'Z')) Then Else Proto.Lettre := '';

 Protoc := '';
 If Point = 1 Then Protoc := Proto.Lettre;
 If Point = 2 Then Protoc := Proto.Name;
 If Point = 3 Then Protoc := Proto.Receive;
 If Point = 4 Then Protoc := Proto.Send;

End;
{---------------------------------------------------------------------------}
Function PosProto(Lettre : Char) : Byte;
Var B : Byte;
Begin;
B := 0;
F := 0;
Repeat;
 If Protoc(1,F) = Lettre Then B := F;
Inc(F);
Until F >= 11;

 PosProto := B;

End;
{---------------------------------------------------------------------------}

Function Compres(Point : Byte; Posis : Byte) : String;
TYPE
  ConfigurationCompresssion = RECORD
                        Lettre      : String[01];
                        Name        : String[03];
                        DeCompress  : String[60];
                        compress    : String[60];
  End;

VAR Comp        : ConfigurationCompresssion;
    Compress    : File Of  ConfigurationCompresssion;

Begin;
 Assign(Compress, 'NETCOMP.DAT');
 {$I-} Reset(Compress); {$I+}
 If Ioresult <> 0 Then Else Begin;
 {$I-}   Seek(Compress, Posis);
         Read(Compress, Comp); {$I+}
         End;
 If ( (Comp.Lettre >= 'A') And (Comp.Lettre <= 'Z')) Then Else Comp.Lettre := '';

 Compres := '';
 If Point = 0 Then Compres := IntToStr(FileSize(Compress)-1);
 If Point = 1 Then Compres := Comp.Lettre;
 If Point = 2 Then Compres := Comp.Name;
 If Point = 3 Then Compres := Comp.DeCompress;
 If Point = 4 Then Compres := Comp.Compress;
 {$I-} Close(Compress); {$I+}
 If Ioresult <> 0 Then ;
End;
{---------------------------------------------------------------------------}
Function PosComp(Lettre : Char) : Byte;
Var B : Byte;
Begin;
B := 0;
F := 0;
Repeat;
 If Compres(1,F) = Lettre Then B := F;
Inc(F);
Until F >= 11;

 PosComp := B;

End;

{---------------------------------------------------------------------------}
Function NodeSys(Point : Byte; SFDir : String) : String;
TYPE
(* SFNODE.DAT *)
  NodeSysRec    = Record
                            DirectScrn,
                            ShowResult    : Boolean;
                            RamDrive      : Char;
                            PrinterOn,
                            AnsiAvl,
                            Private,
                            SecondPassword,
                            Page_On       : Boolean;
                            MinimumBaud   : Word;
                            MsgInfo,
                            NewFileInfo,
                            SoftControl,
                            AvailableBoo  : Boolean;
                            CorrectionMsg : String[3];
                            WorkPath,
                            DisplayPath,
                            ExtranPath,
                            MsgPath       : String[28];
                            ModInitStr    : String[56];
                            ComPort       : Word;
                            RingNo,
                            Node          : Byte;
                            MaxBaud,
                            ExtraLong     : LongInt;
                            TimeComp      : Real;
                            LastDate      : String[8];
                            PrivateSec    : Integer;
                            HangUpDelay   : Byte;
                            UseHiSpeed,
                            AvailBoolean  : Boolean;
                            IRQ1,
                            IRQ2,
                            IRQ3,
                            IRQ4,
                            IRQ5,
                            IRQ6,
                            IRQ7,
                            IRQ8          : Byte;
                            BreakLen      : Word;
                            FaxConnectMsg : String[7];
                            PreInitStr    : String[6];
                            SubChgSec     : Word;
                            StartWarn     : Byte;
                            ExtraBytes    : Array[0..3] Of Byte;
                            ColorMonitor  : Boolean;
                            OffHookStr    : String[6];
                            ComBase       : Array[1..8] Of Word;
                            AnswerStr     : String[30];
                            NewExtra      : Array[0..201] Of Byte;
End;

VAR
    MNode      : NodeSysRec;
    MNodeF     : File Of NodeSysRec;

Begin;

 If Copy(SfDir,Length(SFDir),1) <> '\' Then SFDir := SfDir +'\';

 Assign(MNodeF, SfDir+'SFNODE.DAT');
 {$I-} Reset(MnodeF); {$I+}
 If IoResult <> 0 Then Begin;
                        ClrSCr;
                        Writeln(Sfdir+'SFNODE.DAT Not Found !!!');
                        Writeln('   HALTING !!!...:-((((((');
                        Halt(3);
                       End;
 Seek(MnodeF, 0);
 Read(MnodeF, Mnode);
 Ligne := '';
 If Point = 1 Then Ligne := Mnode.MsgPath;
 If Point = 2 Then Ligne := Mnode.DisplayPath;
 Close(MnodeF);

 If Copy(Ligne,Length(Ligne),1) <> '\' Then Ligne := Ligne +'\';

 NodeSys := '';
 NodeSys := Ligne;

End;
{---------------------------------------------------------------------------}
Function VisuNewsFiles(Dir : String; Rec : Integer; Description : String; Date:String) : Integer;
CONST Tiret = '====================================================================';
Var SFFILES : Text;
    Ligne   : String;
    Suivante: Boolean;
    Fichier : Boolean;
    Nombre,
    Day_1,
    Month_1,
    Year_1,
    Day_2,
    Month_2,
    Year_2  : Integer;
    NEWFILES : Text;

Begin;
 Nombre := 0;
 Assign(NEWFILES, '$$$NET$$\NEWFILES.DAT');
 Append(NewFiles);

 Fichier  := False;
 Suivante := False;
 Month_2 := StrToInt (Copy(Date, 1, 2));
 Day_2   := StrToInt (Copy(Date, 4, 2));
 Year_2  := StrToInt (Copy(Date, 7, 2));

 Assign(SFFILES, Dir+'SFFILES.BBS');
 {$I-} Reset(SFFILES); {$I+}
 If Ioresult <> 0 Then Exit;

 Repeat
  Ligne := '';
  ReadLn(SFFILES, Ligne);
   If Copy(Ligne, 18,1) = ',' Then
   If Copy(Ligne, 26,1) = '-' Then
   If Copy(Ligne, 29,1) = '-' Then Begin;
                                    Suivante := False;
                                    Month_1  := StrToInt(Copy(Ligne, 24, 2));
                                    Day_1    := StrToInt(Copy(Ligne, 27, 2));
                                    Year_1   := StrToInt(Copy(Ligne, 30, 2));
                                     If Day_Diff(day_2, month_2, year_2, day_1, month_1, year_1) >= 0 Then
                                      Begin;
                                       Inc(Nombre);
                                       If Fichier = False Then
                                         Begin;
                                          Writeln(NewFiles);
                                          Writeln(NewFiles);
                                          Writeln(NewFiles,Rec,') '+Description);
                                          Writeln(NewFiles,Copy(Tiret, 1, Length( IntToStr(Rec)+') '+Description)));
                                          Writeln(NewFiles);
                                         End;
Repeat
If Length(Ligne) > 0 Then
If Pos('', Ligne) <= 0 Then Begin;

                             If ( (Copy(Ligne, 18,1) = ',') And (Copy(Ligne, 26,1) = '-')
                              And (Copy(Ligne, 29,1) = '-') ) Then Writeln(NewFiles, Ligne)
                              Else Begin;
                                    Writeln(NewFiles, Ligne);
                                   End;
                             Ligne := '';
                            End;
If Length(Ligne) > 0 Then
If Pos('', Ligne) > 0 Then Begin;

                             If Pos('', Ligne) > 1 Then Begin;
                                                          WriteLn(NewFiles,Copy(Ligne, 1, Pos('', Ligne)-1));
                                                          Delete(Ligne, 1, Pos('', Ligne)-1);
                                                         End;

                             If Pos('', Ligne) = 1 Then Begin;
                                                          Delete(Ligne, 1, 1);
                                                          Ligne := '                                 '+Ligne;
                                                          If Length(Copy(Ligne, 1, Pos('', Ligne))) > 0 Then
                                                          WriteLn(NewFiles,Copy(Ligne, 1, Pos('', Ligne)-1));
                                                          Delete(Ligne, 1, Pos('', Ligne)-1);
                                                         End;
                            End;

Until Ligne = '';
                                       Suivante := True;
                                       Fichier := True;
                                      End;
                                   End;



If Copy(Ligne, 1, 1) = '' Then If Suivante = True Then
Repeat
If Length(Ligne) > 0 Then
If Pos('', Ligne) <= 0 Then Begin;
                             If ( (Copy(Ligne, 18,1) = ',') And (Copy(Ligne, 26,1) = '-')
                              And (Copy(Ligne, 29,1) = '-') ) Then Writeln(NewFiles, Ligne)
                              Else Begin;
                                    Writeln(NewFiles, Ligne);
                                   End;
                             Ligne := '';
                            End;
If Length(Ligne) > 0 Then
If Pos('', Ligne) > 0 Then Begin;
                             If Pos('', Ligne) > 1 Then Begin;
                                                          WriteLn(NewFiles,Copy(Ligne, 1, Pos('', Ligne)-1));
                                                          Delete(Ligne, 1, Pos('', Ligne)-1);
                                                         End;

                             If Pos('', Ligne) = 1 Then Begin;
                                                          Delete(Ligne, 1, 1);
                                                          Ligne := '                                 '+Ligne;
                                                          If Length(Copy(Ligne, 1, Pos('', Ligne))) > 0 Then
                                                          WriteLn(NewFiles,Copy(Ligne, 1, Pos('', Ligne)-1));
                                                          Delete(Ligne, 1, Pos('', Ligne)-1);
                                                         End;
                            End;

Until Ligne = '';
 Until Eof(SFFILES);
 Close(NewFiles);
 Close(SFFILES);

 VisuNewsFiles := Nombre;
End;

Function NewsFiles(SFDIR : String; Sec : Integer; Date : String) : Integer;
TYPE
FileSystem    = Record
                  FSec          : Integer;
                  FDesc         : String[40];
                  FilePath,
                  UploadPath    : String[60];
                  ShowToAll,
                  FEqual,
                  CDRom,
                  SearchArea,
                  FreeDLArea    : Boolean;
                  PrivSec       : Array[1..5] Of Integer;
                  Extra         : Array[1..76] Of Byte;
                End;


Var SFS : File Of FileSystem;
    SF  : FileSystem;
    Rec : Integer;
    Entete : String;
    NEWFILES : Text;
    Nombre   : Integer;

Begin;

 If Date = 'N/A' Then Date := Date1;

 Nombre := 0;
 Assign(SFS, SFDIR+'SFFAREA.DAT');
 {$I-} Reset(SFS); {$I+}
 If Ioresult <> 0 Then Begin;
                        Writeln(' þþþ File SFFAREA.DAT Not Found In Directory '+SFDIR);
                        Exit;
                       End;
 Rec := 0;

 Assign(NEWFILES, '$$$NET$$\NEWFILES.DAT');
 {$I-} Reset(NEWFILES); {$I+}
 If Ioresult <> 0 Then ReWrite(NewFiles);
 Rewrite(NewFiles);
 Writeln(NewFiles,'                    þþþ  New Files Since '+Copy(Date, 1, 2)+'/'+Copy(Date, 4, 2)+'/'+Copy(Date, 7, 2)
  +'  þþþ');
 Close(NewFiles);

 Repeat
  Seek(SFS, Rec);
  Read(SFS, SF);
   If SF.Cdrom = False Then
   If ( (SF.ShowToAll = True) Or (SF.FSec <= Sec) ) Then
    Nombre := Nombre + VisuNewsFiles(Sf.Filepath, Rec+1, SF.FDesc, Date);
  Inc(Rec);
 Until Rec = FileSize(SFS);
 Close(SFS);

 NewsFiles := Nombre;

End;
{-------------------------------------------------------------------------}
Function Blanc(SST: String) : String;
Var I : Integer;
    TAT : String;
Begin;
 Blanc := '';
 TAT   := '';
for i := 1 to Length(SST) do
  If SST[i] <> ' ' Then TAT := TAT + SST[I];
  Blanc := TAT;
End;
{-------------------------------------------------------------------------}
FUNCTION Exist( sExp: STRING ): BOOLEAN;
VAR s : SearchRec;
BEGIN
     FINDFIRST( sExp, AnyFile, s );
     Exist := (DOSError = 0);
END;


{---------------------------------------------------------------------------}
{---------------------------------------------------------------------------}
{---------------------------------------------------------------------------}
{---------------------------------------------------------------------------}
{---------------------------------------------------------------------------}
{---------------------------------------------------------------------------}
{---------------------------------------------------------------------------}

END.