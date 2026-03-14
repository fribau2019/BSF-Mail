UNIT BSFUpld;

{$I D:\SOURCE~1\PASCAL\NETMAIL\LANGAGE.DIR}

Interface

 Procedure NetUpload (Auto : Boolean);

Implementation

USES CRT,
     DOS,
     BSFCOMM,
     BSFConst,
     BSFLog,
     BSFSwap,
     BSFCRC32,
     BSFUtils;

CONST TempDir        : String[8] = '0000000';
      MsgPourBSFMAIL : Boolean = False;
TYPE
(* SFMSG[x].DAT *)
  MessageBody = Record
                   Msg : String[127];
  End;
(* MESSAGE.MSG *)
  MessageDAT    = record
                   msgstatus     : char;
                   msgnum        : String[7];
                   date          : String[8];
                   time          : String[5];
                   msgto         : String[25];
                   msgfrom       : String[25];
                   msgsubj       : String[25];
                   msgpswd       : String[12];
                   refnum        : String[8];
                   numblks       : String[6];
                   kill          : Char;
                   confnum       : word;
                   blank         : word;
                   ntwktag       : String[3];
 End;

(* SFMSG[x].IDX *)
  MessageIdx    = Record
                   FromWhoCRC,
                   ToWhoCRC,
                   MsgNumber,
                   OrgMsgNumber   : LongInt;
  End;

(* SFMSG[x].PTR *)
  MessagePtr    = Record
                          MDate            : String[17];
                          FromWho,
                          ToWho,
                          OrgTo            : String[30];
                          Subject          : String[40];
                          NetMail,
                          MsgSent,
                          Available,
                          ThreadMsg,
                          ThreadStart,
                          Private,Deleted,
                          Received         : Boolean;
                          Where,
                          NumberofRecords  : Word;
                          Conference       : Integer;
                          MsgNumber,
                          OrgMsgNumber     : LongInt;
                          QWK_ID           : String[8];
                          QWK_Delete_Org   : Boolean;
                          DupChkCRC        : LongInt;
                          FireNetReserved  : Array[0..26] Of Char;
                          NetRoute         : String[16];
                          Extra            : Array[0..23] Of Byte;
                        End;
VAR
    PointPTR   : MessagePTR;
    PTR        : File Of MessagePTR;
    PointIDX   : MessageIDX;
    IDX        : File Of MessageIDX;
    PointDAT   : MessageBody;
    DAT        : File Of MessageBody;
    MSG        : MessageDAT;
    Mail       : File;
    Del        : Byte;
    IPos,
    Position   : Integer;
    Buf        : Array[1..128] Of Char;
    J,
    I          : Integer;
    Sortie     : Array[1..150] Of String[127];
    Chaine     : String[128];
    VCRC32     : LongInt;
    NbOfMsg    : Word;
    NbOfImp    : Word;
    NbOfTra    : Word;
    NbOfRej    : Word;
    C          : Char;
    DirInfo    : SearchRec;
    Fichier    : File;
{---------------------------------------------------------------------------}
Procedure UpdateFicheSFUSer(NbUpload : Word);

TYPE
UserDefaults  = (HotKey,Reserved,Pause);
(* SFUSERS.DAT *)
SFUsers         = Record
                  UserName,
                  CallingFrom      : String[30];
                  Password,
                  TimeDate         : String[14];
                  PhoneNumber      : String[12];
                  BirthDate        : String[8];
                  SecurityLevel    : Integer;
                  Uploads,
                  Downloads,
                  TotalUK,
                  TotalDK          : LongInt;
                  TimesOn,
                  TimeLeft,
                  Last_M_Conf,
                  Last_F_Area,
                  TransPro         : Integer;
                  Defaults         : Set Of UserDefaults;
                  FirstLogDate     : String[8];
                  SubscriptionDate : LongInt;
                  ConfQueue        : Array[0..97] Of Byte;
                  QWK_BBS_ID       : String[8];
                  AllowPurge,
                  BadLastOff,
                  ScrollBack,
                  Xpert,
                  LockedOut,
                  Deleted          : Boolean;
                  Linelen,
                  Pagelen,
                  OnToday,
                  Illegal,
                  DLToday,
                  ForeGround,
                  FreeDLToday      : Byte;
                  ChatsAllowed     : Byte;
                  DLBytes          : LongInt;
                  NewFCheck        : String[8];
                  OrgSecurity      : Integer;
                  ChatsUsed,
                  ExtraByte        : Byte;
                  FileStr          : String[12];
                  FileArea         : Word;
                  DeleteFile       : Boolean;
                  MsgsLeft         : Word;
                  Extra            : Array[1..3] Of Byte;
                End;

VAR SFU    : File Of SFUsers;
    SFUSER : SFUSers;
Begin;
  Assign(SFU, Config.WorkDir+'SFUSERS.DAT');
  {$I-} Reset(SFU); {$I+}
  If Ioresult <> 0 Then Exit;
  Seek(SFU, User.SFNumero);
  Read(SFU, SFUSER);
  SFUSER.MsgsLeft := SFUSER.MsgsLeft + NbUpload;
  Seek(SFU, User.SFNumero);
  Write(SFU, SFUSER);
  Close(SFU);
End;
{---------------------------------------------------------------------------}
Procedure UpdateSFSystem(NbUpload : Word);
TYPE
(* SFSYSTEM.DAT *)
SysRec        = Record
                  NoInputTime   : Byte;
                  CallsToday,
                  MsgToday,
                  UpToday,
                  DownToday,
                  DailyLimit,
                  DailyLogons,
                  LogonLimit,
                  SysopSecurity,
                  NUS,
                  NUTL          : Word;
                  UpDskSpace    : LongInt;
                  MaxUsers      : Word;
                  FileDescAmt   : Byte;
                  SrchRomSFFILE : Boolean;
                  DoorsAmt      : Integer;
                  Callernum     : LongInt;
                  LastDate      : String[8];
                  StartDate     : String[18];
                  DOSPassword   : String[28];
                  SysopName,
                  SysMsgName    : String[30];
                  USPhone,
                  ConvertDesc,
                  HeySysop,
                  AddUpedBy,
                  CommentQue    : Boolean;
                  NumberOfNodes,
                  NUCallers2Day : Byte;
                  BootUpTests,
                  ScanAllMsg,
                  OfferDefault  : Boolean;
                  ViolationSec  : Integer;
                  NUBirthDate,
                  CompFileSrch,
                  DrRetPassword,
                  RIPAvailable,
                  UseIntl       : Boolean;
                  ExtraBytes    : Array[0..84] Of Byte;
                End;
VAR SysF    : File Of SysRec;
    Sys     : SysRec;
Begin;
  Assign(SysF, Config.WorkDir+'SFSYSTEM.DAT');
  {$I-} Reset(SysF); {$I+}
  If Ioresult <> 0 Then Exit;
  Seek(SysF, 0);
  Read(SysF, Sys);
  Sys.MsgToday := Sys.MsgToday + NbUpload;
  Seek(SysF, 0);
  Write(SysF, Sys);
  Close(SysF);
End;
{---------------------------------------------------------------------------}
Function SFMSG(Rec : Integer) : String;
Begin;
 If Rec < 10  Then SFMSG := 'SFMSG0'+IntToStr(Rec)
  Else SFMSG := 'SFMSG'+IntToStr(Rec);
End;
{---------------------------------------------------------------------------}
Function DateTime : String;

TYPE  Treg = 0..$D;     { range for time/date register addresses    }
      To23 = 0..23;     { range for hours                           }
      To59 = 0..59;     { range for minutes and seconds             }
VAR   Yr, Mth, Day, DoW, Hr, Min, Sec : BYTE;
      Resultat : String;

FUNCTION RTCbusy:BOOLEAN; BEGIN { RTC time/date being updated?... }
    Port[$70] := $A;;  RTCbusy := (Port[$71] AND 128) = 128;
  END {RTCbusy};

FUNCTION ReadReg (Reg:Treg):BYTE; BEGIN { read an RTC register... }
    IF Reg IN [0..9] THEN REPEAT {wait} UNTIL NOT RTCbusy;
    Port[$70] := Reg;;  ReadReg := Port[$71];
  END {ReadReg};

PROCEDURE WriteReg (Reg:Treg; Data:BYTE); { write RTC reg... }
  VAR temp:BYTE; BEGIN
    IF Reg IN [0..9] THEN BEGIN { time/date reg? }
      REPEAT {wait} UNTIL NOT RTCbusy;
      Port[$70] := $B;; temp := Port[$71];; Port[$71] := temp OR $80;
    END{IF};
    Port[$70] := Reg;;  Port[$71] := Data;
    IF Reg IN [0..9] THEN BEGIN
      Port[$70] := $B;;  Port[$71] := temp AND NOT $80;
    END{IF};
  END {WriteReg};

FUNCTION BCD2Bin (BCD:BYTE):BYTE; BEGIN { xlate BCD to binary... }
    BCD2Bin := (BCD AND $0F) + ((BCD SHR 4) * 10);
  END {BCD2Bin};
FUNCTION Bin2BCD (Bin:BYTE):BYTE; BEGIN { xlate binary to BCD... }
    Bin2BCD := (Bin MOD 10) OR BYTE((Bin DIV 10) SHL 4);
  END {Bin2BCD};

PROCEDURE GetTime (VAR Hr,Min,Sec:BYTE);
  VAR temp:BYTE; BEGIN
    Sec := ReadReg(0);;  Min := ReadReg(2);
    Hr := ReadReg(4);;  temp := Hr;;  Hr := Hr AND NOT $80;
    IF (ReadReg($B) AND 4) <> 4 THEN BEGIN { xlate BCD to bin... }
      Sec := BCD2Bin(Sec);; Min := BCD2Bin(Min);; Hr := BCD2Bin(Hr);
    END{IF};
    IF (ReadReg($B) AND 2) <> 2 THEN  { RTC in 12-hr mode?... }
      IF (temp AND 128) = 128  { P.M.? }
        THEN BEGIN IF (Hr < 12) THEN INC(Hr,12); END
        ELSE IF Hr = 12 THEN Hr := 0;
  END {GetTime};

PROCEDURE SetTime (Hr:To23; Min,Sec:To59);
  VAR temp:BYTE; BEGIN
    temp := BYTE(Hr);
    IF (ReadReg($B) AND 2) <> 2 THEN  { RTC in 12-hr mode?... }
      IF (Hr > 12) THEN DEC(Hr,12) ELSE IF Hr = 0 THEN Hr := 12;
    IF (ReadReg($B) AND 4) <> 4 THEN BEGIN { RTC wants BCD format... }
      Hr := Bin2BCD(Hr);; Min := Bin2BCD(Min);; Sec := Bin2BCD(Sec);
    END{IF};
    IF ((ReadReg($B) AND 2)<>2) AND (temp > 11) THEN Hr := Hr OR $80;
    WriteReg(0,Sec);; WriteReg(2,Min);; WriteReg(4,Hr);
  END {SetTime};

PROCEDURE GetDate (VAR Yr,Mth,Day:BYTE); BEGIN
    Day := ReadReg(7);;  Mth := ReadReg(8);;  Yr := ReadReg(9);
    IF (ReadReg($B) AND 4) <> 4 THEN BEGIN { xlate BCD to binay... }
      Day := BCD2Bin(Day);; Mth := BCD2Bin(Mth);; Yr := BCD2Bin(Yr);
    END; {IF}
  END {GetDate};

BEGIN {RClock}
  Resultat := '';
  GetTime (Hr,Min,Sec);;
  GetDate (Yr,Mth,Day);;

  If Mth < 10 Then Resultat := '0'+IntToStr(Mth)              Else Resultat := IntToStr(Mth);
  If Day < 10 Then Resultat := Resultat + '-0' +IntToStr(Day) Else Resultat := Resultat + '-' +IntToStr(Day);
  If Yr  < 10 Then Resultat := Resultat + '-0' +IntToStr(Yr)  Else Resultat := Resultat + '-' +IntToStr(Yr);

  Resultat := Resultat + ' ';

  If Hr < 10 Then Resultat := Resultat + '0' + IntToStr(Hr)  Else Resultat := Resultat + IntToStr(Hr);
  If Min< 10 Then Resultat := Resultat + ':0' + IntToStr(Min) Else Resultat := Resultat + ':' + IntToStr(Min);
  If Sec< 10 Then Resultat := Resultat + ':0' + IntToStr(Sec) Else Resultat := Resultat + ':' + IntToStr(Sec);

  DateTime := Resultat

END;
{---------------------------------------------------------------------------}
Function Compres(Point : Byte) : String;
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
 Assign(Compress, Config.BsfMailDir+'BSFCOMP.DAT');
 Reset(Compress);
 Seek(Compress, User.Compression);
 Read(Compress, Comp);
 Close(Compress);

 If ( (Comp.Lettre >= 'A') And (Comp.Lettre <= 'Z')) Then Else Comp.Lettre := '';

 Compres := '';
 If Point = 0 Then Compres := IntToStr(FileSize(Compress)-1);
 If Point = 1 Then Compres := Comp.Lettre;
 If Point = 2 Then Compres := Comp.Name;
 If Point = 3 Then Compres := Comp.DeCompress;
 If Point = 4 Then Compres := Comp.Compress;

End;
{---------------------------------------------------------------------------}
Function Protoc(Point : Byte) : String;
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
 Assign(Protocol,Config.BsfMailDir+ 'BSFPROTO.DAT');
 Reset(Protocol);
 Seek(Protocol, User.Protocol);
 Read(Protocol, Proto);
 Close(Protocol);

 If ( (Proto.Lettre >= 'A') And (Proto.Lettre <= 'Z')) Then Else Proto.Lettre := '';

 Protoc := '';
 If Point = 1 Then Protoc := Proto.Lettre;
 If Point = 2 Then Protoc := Proto.Name;
 If Point = 3 Then Protoc := Proto.Send;
 If Point = 4 Then Protoc := Proto.Receive;

End;
{---------------------------------------------------------------------------}
Function MovingFile(FileFrom, FileTo : String) : Boolean;
VAR
    Fichier1,
    Fichier2   : File;
    Buffe      : Array[1..2048] Of Char;
    NumRead,
    NumWritten : Word;

Begin;
 Assign(Fichier1, FileFrom);
 {$I-} Reset(Fichier1, 1); {$I+}
 If Ioresult <> 0 Then Begin;
                        MovingFile := False;
                        Exit;
                       End;

  Begin;
   Assign(Fichier2, FileTo);
   {$I-} Reset(Fichier2); {$I+}
   If IoResult <> 0 Then ReWrite(Fichier2, 1);
   ReWrite(Fichier2, 1);
   Repeat
    BlockRead(Fichier1, Buffe, SizeOf(Buffe), NumRead);
    BlockWrite(Fichier2, Buffe, NumRead, NumWritten);
   Until (NumRead = 0) or (NumWritten <> NumRead);
    Close(Fichier2);
    Close(Fichier1);
(*    {$I-} Erase(Fichier1); {$I+} *)
    If Ioresult <> 0 Then;
    MovingFile := True;
  End;
End;
{---------------------------------------------------------------------------}
Function TestFROMTO (Area : Word;FromWho, ToWho , Subject : String ; CRCMsg : LongInt) : Boolean;
TYPE

  MessageBody = Record
                   Msg : String[127];
  End;


  MessagePtr    = Record
                          MDate            : String[17];
                          FromWho,
                          ToWho,
                          OrgTo            : String[30];
                          Subject          : String[40];
                          NetMail,
                          MsgSent,
                          Available,
                          ThreadMsg,
                          ThreadStart,
                          Private,Deleted,
                          Received         : Boolean;
                          Where,
                          NumberofRecords  : Word;
                          Conference       : Integer;
                          MsgNumber,
                          OrgMsgNumber     : LongInt;
                          QWK_ID           : String[8];
                          QWK_Delete_Org   : Boolean;
                          DupChkCRC        : LongInt;
                          FireNetReserved  : Array[0..26] Of Char;
                          NetRoute         : String[16];
                          Extra            : Array[0..23] Of Byte;
                        End;
Var
    PointPTR   : MessagePTR;
    PTR        : File Of MessagePTR;
    LowMess    : Longint;
    PasseOk    : Boolean;
    PointDAT   : MessageBody;
    DAT        : File Of MessageBody;

Begin;

If FileExists(Config.MsgDir+SFMSG(Area)+'.PTR') Then
 Begin;
  PasseOk := True;
  Assign(PTR, Config.MsgDir+SFMSG(Area)+'.PTR');
  Reset(PTR);
  LowMess := (FileSize(Ptr)-1) Div 4;
  Repeat
   Seek(Ptr, LowMess);
   Read(PTR, PointPTR);
   If MAJ(Reduce(PointPTR.FromWho,' ')) = MAJ(Reduce(FromWho,' ')) Then
   If MAJ(Reduce(PointPTR.ToWho,' '))   = MAJ(Reduce(ToWho,' '))   Then
   If MAJ(Reduce(PointPTR.Subject,' ')) = MAJ(Reduce(Subject,' ')) Then
    Begin;
     Assign(DAT, Config.MsgDir+SFMSG(Area)+'.DAT');
     Reset(DAT);
     Seek(DAT, PointPTR.Where);
     Read(DAT, PointDAT);
     If CRC(PointDAT.Msg) = CRCMsg Then PasseOk := False;
     Close(DAT);
    End;
   Inc(LowMess);
  Until ( (LowMess >= FileSize(Ptr)) Or (PasseOk = False) );
 Close(PTR);
 TestFromTo := PasseOk;
 End
 Else TestFromTo := False;
End;
{---------------------------------------------------------------------------}
Procedure Efface;
Begin;
 Repeat
  FindFirst(TempDir+'\*.*', Archive, DirInfo);
 While DosError = 0 Do
  Begin;
   Assign(Fichier, TempDir+'\'+DirInfo.Name);
   {$I-} Close(Fichier); {$I+}
   If Ioresult <> 0 Then;
(*   Erase(Fichier); *)
   FindNext(DirInfo);
  End;
 Until DosError <> 0;
 {$I-} RmDir(TempDir); {$I+}
 If Ioresult <> 0 Then;
End;
{---------------------------------------------------------------------------}
Function LMR(Mode : Byte; Rec, Chiffre : Integer) : LongInt;
TYPE
(* SFMSG[X].LMR *)
LastMessage   = Record
                  LMsgRed : LongInt;
                End;

VAR
    LM         : File Of LastMessage;
    L          : LastMessage;

Begin;
  Assign(LM, Config.MsgDir+SFMSG(Rec)+'.LMR');
  {$I-} Reset(LM); {$I+}
  If Ioresult = 0 Then
   Begin;
    If FileSize(LM) > 0 Then
     If Mode = 0 Then {Lecture}
      Begin;
       Seek(LM, USer.SFNumero);
       Read(LM, L);
       LMR := L.LMSgRed;
      End;
     If Mode = 1 Then {Ecriture}
      Begin;
       Seek(LM, USer.SFNumero);
       Read(LM, L);
       L.LMSgRed := Chiffre;
       Seek(LM, USer.SFNumero);
       Write(LM, L);
      End;
    Close(LM);
   End
  Else
   Begin;
    LMR := 0;
   End;
End;
{---------------------------------------------------------------------------}
Function MsgBSFMAIL : String;
CONST
  {$IFDEF ENGLISH}
   MSG01 = 'Add ';
   MSG02 = 'Drop ';
   MSG03 = 'Conference';
   MSG04 = 'Unknown Command !';
   MSG05 = 'Pointors To ';
  {$ELSE}
   MSG01 = 'Rajout ';
   MSG02 = 'Enlvement ';
   MSG03 = 'De La Confrence';
   MSG04 = 'Commande Inconnue !';
   MSG05 = 'Pointeurs A ';
  {$ENDIF}
VAR S     : String;
    Passe : Boolean;
Begin;
 Passe := False;
 Inc(Position);
 If RTrim(Msg.MsgSubj, ' ') = 'ADD'  Then
  Begin;
   MsgBSFMAIL := MSG01+MSG03;
   If User.Conf.Attribut[Msg.ConfNum-1] < 100 Then User.Conf.Attribut[Msg.ConfNum-1] := 1
   Else User.Conf.Attribut[Msg.ConfNum-1] := 101;
   AddConf(Msg.ConfNum);
   Passe := True;
  End;
 If RTrim(Msg.MsgSubj, ' ') = 'DROP' Then
  Begin;
   MsgBSFMail  := MSG02+MSG03;
   If User.Conf.Attribut[Msg.ConfNum-1] < 100 Then User.Conf.Attribut[Msg.ConfNum-1] := 0
   Else User.Conf.Attribut[Msg.ConfNum-1] := 100;
   DropConf(Msg.ConfNum);
   Passe := True;
  End;

 If POS('RESET', RTrim(Msg.MsgSubj, ' ')) > 0 Then
  Begin;
   S := Reduce(Msg.MsgSubj, ' ');
   Delete(S, 1, 5);
   MsgBSFMail  := MSG05+S;
   LMR(1, Msg.ConfNum, StrToInt(S));
   ResetConf(Msg.ConfNum, StrToInt(S));
   Passe := True;
  End;

 If RTrim(Msg.MsgSubj, ' ') = 'CONFIG' Then
  Begin;
   FillChar(Chaine, SizeOf(Chaine), #32);
   Seek(Mail, Position);
   BlockRead(Mail, Buf, 1);
   S := Buf;
   S := Copy(S, 1, Pos('ใ', S)-1);
   If POS('ADD', MAJ(S)) > 0 Then
    Begin;
     Delete(S, 1, 4);
     MsgBSFMAIL := MSG01+MSG03;
     If User.Conf.Attribut[StrToInt(S)-1] < 100 Then User.Conf.Attribut[StrToInt(S)-1] := 1
     Else User.Conf.Attribut[StrToInt(S)-1] := 101;
     AddConf(StrToInt(S));
     Passe := True;
    End;
  If POS('DROP', MAJ(S)) > 0 Then
    Begin;
     Delete(S, 1, 4);
     MsgBSFMAIL := MSG02+MSG03;
     If User.Conf.Attribut[StrToInt(S)-1] < 100 Then User.Conf.Attribut[StrToInt(S)-1] := 0
     Else User.Conf.Attribut[StrToInt(S)-1] := 100;
     DropConf(StrToInt(S));
     Passe := True;
    End;
  If POS('RESET', MAJ(S)) > 0 Then
    Begin;
     Delete(S, 1, 5);
     Delete(S, 1, Pos(' ', S)+2);
     Reduce(S, ' ');
     MsgBSFMAIL := MSG05+S;
     LMR(1, Msg.ConfNum, StrToInt(S));
     ResetConf(Msg.ConfNum, StrToInt(S));
     Passe := True;
    End;
  End;
 If Not Passe Then MsgBSFMail  := MSG04;
 Inc(Position);
End;
{---------------------------------------------------------------------------}
Procedure NetUpload (Auto : Boolean);


Begin;
 RmClrSCr;

 NbOfMsg := 0;
 NbOfImp := 0;
 NbOfTra := 0;
 NbOfRej := 0;

 RmWriteln('');
 RmWriteln('');
 TempDir := IntToStr(Abs(CRC(UserName)));
(*Reception Du Packet *)
 {Local}
  If Comport = 0 Then
   Begin;
    Writeln;
   {$IFDEF ENGLISH}
    Writeln('þ Ready To Receive '+Config.BBSID+'.REP Locally...');
    Writeln;
    Write('þ File ('+Config.LocalQWK+Config.BBSID+'.REP) Ok ? (Y/n/Q]uit) : ');
   {$ELSE}
    Writeln('þ Prt A Recevoir '+Config.BBSID+'.REP Localement...');
    Writeln;
    Write('þ Fichier ('+Config.LocalQWK+Config.BBSID+'.REP) Ok ? (Y/n/Q]uitter) : ');
   {$ENDIF}
    C := ' ';
    If Auto = False Then
     Repeat
      C := Upcase(ReadKey);
     Until C In ['Y', 'N', 'Q', #13]
    Else C := 'Y';
     If C = #13 Then C := 'Y';
    Writeln(C);
    Case C Of
     'Y' : Begin;
            (* Creation Du Repertoire Temporaire *)
            {$I-} MkDir(TempDir); {$I+}
            If IoResult <> 0 Then
             Begin;
              Efface;
              {$I-} MkDir(TempDir); {$I+}
              If IoResult <> 0 Then;
             End
            Else
             Begin;
              If MovingFile(Config.LocalQWK+Config.BBSID+'.REP',TempDir+'\'+Config.BBSID+'.REP') = True Then
               Begin;
                Writeln;
               {$IFDEF ENGLISH}
                Writeln('þ Successfull Transfering '+Config.BBSID+'.REP');
               {$ELSE}
                Writeln('þ Transfert '+Config.BBSID+'.REP Russi');
               {$ENDIF}
                SuccessTransfert;
               End
              Else
               Begin;
                Writeln;
               {$IFDEF ENGLISH}
                Writeln('þ File '+Config.BBSID+'.REP Not Found In Directory '+Config.LocalQWK);
               {$ELSE}
                Writeln('þ Fichier '+Config.BBSID+'.REP Non Trouv Dans Le Rpertoire '+Config.LocalQWK);
               {$ENDIF}
                Delay(1000);
                ProblemTransfert;
                Efface;
                Exit;
               End;
             End;
            End;
     'N' : Begin;
            Writeln;
           {$IFDEF ENGLISH}
            Writeln('þ Please Write '+Config.BBSID+'.REP Directory :');
           {$ELSE}
            Writeln('þ Veuillez Ecrire Le Rpertoire O— Est '+Config.BBSID+'.REP :');
           {$ENDIF}
            chaine := '';
            ReadLn(Chaine);
            If Chaine = '' Then Exit
             Else
              Begin;
               (* Creation Du Repertoire Temporaire *)
               {$I-} MkDir(TempDir); {$I+}
               If IoResult <> 0 Then Else
                Begin;
                 If MovingFile(Chaine+Config.BBSID+'.REP',TempDir+'\'+Config.BBSID+'.REP') = True Then
                  Begin;
                   Writeln;
                  {$IFDEF ENGLISH}
                   Writeln('þ Successfull Transfering '+Config.BBSID+'.REP');
                  {$ELSE}
                   Writeln('þ Transfert '+Config.BBSID+'.REP Russi');
                  {$ENDIF}
                   SuccessTransfert;
                  End
                 Else
                  Begin;
                   Writeln;
                  {$IFDEF ENGLISH}
                   Writeln('þ File '+Config.BBSID+'.REP Not Found In Directory '+Chaine);
                  {$ELSE}
                   Writeln('þ Fichier '+Config.BBSID+'.REP Non Trouv Dans Le Rpertoire '+Chaine);
                  {$ENDIF}
                   ProblemTransfert;
                   Efface;
                   Exit;
                  End;
              End;
             End;
           End;
     'Q' : Begin;
            Efface;
            Exit;
           End;
    End;
   End;
 {Connect}
  If ( (Comport > 0) And (Carrier = True) ) Then
   Begin;
    (* Creation Du Repertoire Temporaire *)
    {$I-} MkDir(TempDir); {$I+}
    If IoResult <> 0 Then
     Begin;
      Efface;
      {$I-} MkDir(TempDir); {$I+}
      If IoResult <> 0 Then;
     End;

    {$IFDEF ENGLISH}
     RmWriteln('þ Ready To Receive '+Config.BBSID+'.REP With '+Protoc(2));
    {$ELSE}
     RmWriteln('þ Prt A Recevoir '+Config.BBSID+'.REP Avec '+Protoc(2));
    {$ENDIF}

    RmWriteln('');

    Chaine := Copy(Protoc(3), Pos(' ', Protoc(3)), Length(Protoc(3)));
    Chaine := Chaine + ' '+TempDir+'\'+Config.BBSID+'.REP';

    DosError := DosShell (Copy(Protoc(3), 1, Pos(' ', Protoc(3))),
                          Chaine,
                          USE_ALL,
                          $ffff,
                          false);

    Delay(2500);

    If DosError=0 Then
     Begin;
     {$IFDEF ENGLISH}
      Writeln('þ Successfull Transfering '+Config.BBSID+'.REP');
     {$ELSE}
      Writeln('þ Transfert '+Config.BBSID+'.REP Russi');
     {$ENDIF}
      SuccessTransfert;
     End
    Else
     Begin;
      ProblemTransfert;
      RmWriteln('');
      RmWriteln('');
     {$IFDEF ENGLISH}
      RmWriteln('þ Problem Uploading '+Config.BBSID+'.REP');
     {$ELSE}
      RmWriteln('þ Problme Durant L''Upload De '+Config.BBSID+'.REP');
     {$ENDIF}
      Efface;
      Delay(3000);
      Exit;
     End;
   End;

(*UNZIP Du Fichier JOSHUA.REP *)

   RmWriteln('');
  {$IFDEF ENGLISH}
   RmWriteln('þ Decompressing '+Config.BBSID+'.REP');
  {$ELSE}
   RmWriteln('þ Dcompactage De '+Config.BBSID+'.REP');
  {$ENDIF}


   Chaine := Copy(Compres(3), Pos(' ', Compres(3)), Length(Compres(3)));
   Chaine := Chaine +' '+TempDir+'\'+Config.BBSID+'.REP '+TempDir+'\ >Nul';


   DosError := DosShell (Copy(Compres(3), 1, Pos(' ', Compres(3))),
                         Chaine,
                         USE_ALL,
                         $ffff,
                         false);


   If DosError <> 0 Then
    Begin;
     RmWriteln('');
     RmWriteln('');
    {$IFDEF ENGLISH}
     RmWriteln('þ Problem For Decompacting File.');
     RmWriteln('þ Please Refer To The SysOp...');
    {$ELSE}
     RmWriteln('þ Problme Pour Dcompacter Le Fichier.');
     RmWriteln('þ Veullez En Rfrer Au SysOp...');
    {$ENDIF}
     Delay(3500);
     ProblemDecompacting;
     Efface;
     Exit;
    End
   Else SuccessDecompacting;

{Lecture Entete REP }
    RmWriteln('');
   {$IFDEF ENGLISH}
    RmWrite('þ Testing Signature Reply : ');
   {$ELSE}
    RmWrite('þ Test De La Signature : ');
   {$ENDIF}
    Assign(Mail, TempDir+'\'+Config.BBSID+'.MSG');
    {$I-} Reset(Mail); {$I+}
    If Ioresult <> 0 Then
     Begin;
     {$IFDEF ENGLISH}
      RmWriteln('Bad Type Packet !');
     {$ELSE}
      RmWriteln('Mauvais Type De Paquet !');
     {$ENDIF}
      BadPacket;
      Delay(3000);
      Efface;
      Exit;
     End
    Else
     Begin;
      Seek(Mail, 0);
      BlockRead(Mail, Buf, 1);
     End;

{Test Du REP/Destinataire}
   Chaine := Buf;
   If POS(Config.BBSID, Chaine) > 0 Then RmWriteln('OK !')
   Else
    Begin;
     BadPacket;
     RmWriteln('');
    {$IFDEF ENGLISH}
     RmWriteln('Wrong BBS Reply !');
    {$ELSE}
     RmWriteln('Mauvais Paquet De BBS !');
    {$ENDIF}
     Delay(3000);
     Efface;
     Exit;
    End;

{Affichage Logo}
  {$IFDEF ENGLISH}
   RmWriteln('');
   RmWriteln('');
   RmWriteln('ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป');
   RmWriteln('บ  BSF-Mail Offline And Mail Door For Spitfire 3.5        - UPLOAD -     บ');
   RmWriteln('วฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถ');
   RmWriteln('บ  Conf  Message To...             Message Subject...           Status   บ');
   RmWriteln('ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ');
   RmWriteln('');
  {$ELSE}
   RmWriteln('');
   RmWriteln('');
   RmWriteln('ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป');
   RmWriteln('บ  BSF-Mail Offline Et Mail Door Pour Spitfire 3.5        - UPLOAD -     บ');
   RmWriteln('วฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถ');
   RmWriteln('บ  Conf  Message Pour...           Sujet Du Message...          Status   บ');
   RmWriteln('ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ');
   RmWriteln('');
  {$ENDIF}

(* Debut De La Manip *)
   Position := 1;
   RePeat
   MsgPourBSFMAIL := False;
{Lecture De L'entete Du Message}
   FillChar(Chaine, SizeOf(Chaine), #32);
   Seek(Mail, Position);
   BlockRead(Mail, Buf, 1);
   Msg.MsgStatus := Buf[1];
   For I := 1 To 7  Do Chaine[I] := Buf[I+1];   Msg.MsgNum  := Chaine;
   For I := 1 To 8  Do Chaine[I] := Buf[I+8];   Msg.Date    := Chaine;
   For I := 1 To 5  Do Chaine[I] := Buf[I+16];  Msg.Time    := Chaine;
   For I := 1 To 25 Do Chaine[I] := Buf[I+21];  Msg.MsgTo   := Chaine;
   For I := 1 To 25 Do Chaine[I] := Buf[I+46];  Msg.MsgFrom := Chaine;
   For I := 1 To 25 Do Chaine[I] := Buf[I+71];  Msg.MsgSubj := Chaine;
   For I := 1 To 8  Do Chaine[I] := Buf[I+108]; Msg.RefNum  := Chaine;
   For I := 1 To 6  Do Chaine[I] := Buf[I+116]; Msg.NumBlks := Chaine;
   Msg.Kill      := Buf[123];
   Msg.ConfNum := Ord(Buf[125])*256 + Ord(Buf[124]);
   Msg.Ntwktag := '   ';

   MsgPourBSFMAIL := False;

   If MAJ(Rtrim(Msg.MsgTo, #32)) = 'BSFMAIL' Then MsgPourBSFMAIL := True;
   If MAJ(Rtrim(Msg.MsgTo, #32)) = 'QMAIL'   Then MsgPourBSFMAIL := True;

   If MsgPourBSFMAIL Then Inc(NbOfTra);
   Inc(NbOfMsg);

{Affichage}
   If Not MsgPourBSFMAIL Then
    If Msg.MsgStatus In ['*','+','~','`'] Then Chaine := '  ' Else Chaine := '   '
   Else Chaine := ' ๛ ';
   I := Msg.ConfNum;
   If Msg.ConfNum < 10   Then Chaine := Chaine + '  ' + IntToStr(I)+'.  ';
   If ( (Msg.ConfNum >= 10) And (Msg.ConfNum < 100) )  Then Chaine := Chaine + ' ' + IntToStr(I)+'.  ';
   If Msg.ConfNum >= 100 Then Chaine := Chaine + IntToStr(I)+'.  ';
   If Not MsgPourBSFMAIL
    Then Chaine := Chaine + Msg.MsgTo
    Else Chaine := Chaine + 'BSFMAIL' + Rep(' ', 19);
   If Length(Chaine) < 35 Then Chaine := Chaine + Rep(' ',40 - Length(Chaine));
   If Length(Chaine) > 35 Then Chaine := Copy(Chaine, 1, 35);

   If Not MsgPourBSFMAIL Then Chaine := Chaine + Msg.MsgSubj
    Else Begin;
         Chaine := Chaine + MsgBSFMAIL;
         Chaine := Chaine + Rep(' ', 66-Length(Chaine)) + 'Ok';
        End;
   If Not MsgPourBSFMAIL Then RmWrite(Chaine) Else RmWriteln(Chaine);

If Not MsgPourBSFMAIL Then Begin;

{Lecture Du Message Et Formatage En Spit}
   For I := 1 To 150 Do Sortie[I] := '';
   I := Position;
   Ipos := 1;
   For Position := I+1 To I+StrToInt(Reduce(Msg.NumBlks, ' '))-1 Do
    Begin;
     Seek(Mail, Position);
     Blockread(Mail, Buf, 1);
     Chaine := Buf;
   Repeat
     Del := Length(Sortie[Ipos]);
     Sortie[IPos] := Sortie[Ipos] + Chaine;
     If Length(Sortie[Ipos]) >= 127 Then Inc(Ipos);
     Delete(Chaine, 1, 127-Del);
    Until Length(Chaine) = 0;
   End;

(****************************************************************)
{Mise En Place Du Logo Netmail }
 {$IFDEF ENGLISH}
  {$IFDEF UNREGISTERED}
   Chaine := 'ใþþ BSFMail(C) v.'+Version+' þþ UNREGISTERED * '+Config.BBSName+'ใ';
  {$ELSE}
   Chaine := 'ใþþ BSFMail(C) v.'+Version+' þþ '+RegistrationR+ ' þ '+RegistrationN+'ใ';
  {$ENDIF}
 {$ELSE}
  {$IFDEF UNREGISTERED}
   Chaine := 'ใþþ BSFMail(C) v.'+Version+' þþ NON ENREGISTRE * '+Config.BBSName+'ใ';
  {$ELSE}
   Chaine := 'ใþþ BSFMail(C) v.'+Version+' þþ '+RegistrationR+ ' þ '+RegistrationN+'ใ';
  {$ENDIF}
 {$ENDIF}
(****************************************************************)
   Repeat
     Del := Length(Sortie[Ipos]);
     Sortie[IPos] := Sortie[Ipos] + Chaine;
     Delete(Chaine, 1, 127-Del);
     If Length(Sortie[Ipos]) >= 127 Then Inc(Ipos);
    Until Length(Chaine) = 0;
   Chaine := '';
{Derniere Chaine Pas Tout A Fait Vide >= + Blanc ! }
   If Length(Sortie[Ipos]) < 127 Then Sortie[Ipos] := Sortie[Ipos]+Rep(' ', 255);
   Inc(Position);
{Remplacement De ใ Par  Et Calcule Du Nombre De Records}
  I := 0;
  PointPtr.NumberOfRecords := 0;
  For Ipos := 1 To 150 Do
   Begin;
    For I := 1 To 127 Do If Sortie[Ipos][I] = 'ใ' Then Sortie[Ipos][I] := '';
    If Length(Sortie[Ipos]) > 0 Then Inc(PointPtr.NumberOfRecords);
   End;

(*** TEST CRC Du MAIL ***)

  If TestFromTo(Msg.ConfNum,
                Msg.MsgFrom,
                Msg.MsgTo,
                Msg.MsgSubj,
                CRC(Sortie[1]))     = False
     Then
      Begin;
          {$IFDEF ENGLISH} Writeln(' * Rejected *');
          {$ELSE}          Writeln('  * Rejet * ');
          {$ENDIF}
          Inc(NbOfRej);
      End
  Else
     Begin;
          Writeln('      Ok');

   If Msg.MsgStatus In ['*','+','~','`'] Then EnterPrive(Msg.MsgTo, IntToStr(Msg.ConfNum))
                                         Else EnterPublic(Msg.MsgTo, IntToStr(Msg.ConfNum));


(* Ecriture Du IDX *)
  Assign(IDX, Config.MsgDir+SFMSG(Msg.ConfNum)+'.IDX');
  {$I-} Reset(IDX); {$I+}
  If IoResult <> 0 Then Begin;
                         Writeln;
                         Writeln('>>> Unable To Find '+Config.MsgDir+SFMSG(Msg.ConfNum)+'.IDX');
                         Delay(2000);
                         Efface;
                         Exit;
                        End;
  If FileSize(IDX) = 0 Then
   Begin;
    Seek(IDX, 0);
    PointPTR.MsgNumber := 1
   End
  Else
    Begin;
     Seek(IDX, FileSize(IDX)-1);
     Read(IDX, PointIDX);
    End;
  PointIDX.FromWhoCRC := CRC(Msg.MsgFrom);
  PointIDX.ToWhoCRC   := CRC(Msg.MsgTo);
  Inc(PointIDX.MsgNumber);
  PointIDX.OrgMsgNumber := PointIDX.MsgNumber;
  Seek(IDX, FileSize(IDX));
  Write(IDX, PointIDX);
  {$I-} Close(IDX); {$I+}
  If Ioresult <> 0 Then;

 I := PointPTR.NumberOfRecords;

(* Ecriture Du DAT *)
  Assign(DAT, Config.MsgDir+SFMSG(Msg.ConfNum)+'.DAT');
  {$I-} Reset(DAT); {$I+}
  If IoResult <> 0 Then Begin;
                         Writeln;
                         Writeln('>>> Unable To Find '+Config.MsgDir+SFMSG(Msg.ConfNum)+'.DAT');
                         Delay(2000);
                         Efface;
                         Exit;
                        End;
  J := FileSize(DAT);
  For Ipos := 1 To PointPTR.NumberOfRecords Do
   Begin;
    PointDAT.Msg := Sortie[Ipos];
    Seek(DAT, FileSize(DAT));
    Write(DAT, PointDAT);
   End;
  {$I-} Close(DAT); {$I+}
  If Ioresult <> 0 Then;

(* Ecriture Du PTR *)
  Assign(PTR, Config.MsgDir+SFMSG(Msg.ConfNum)+'.PTR');
  {$I-} Reset(PTR); {$I+}
  If IoResult <> 0 Then Begin;
                         Writeln;
                         Writeln('>>> Unable To Find '+Config.MsgDir+SFMSG(Msg.ConfNum)+'.PTR');
                         Delay(2000);
                         Efface;
                         Exit;
                        End;
  If FileSize(PTR) = 0 Then
   Begin;
    PointPTR.Where           := J;
    PointPTR.MsgNumber       := 0;
    Seek(PTR, 0);
   End
  Else
   Begin;
    Seek(PTR, FileSize(PTR)-1);
    Read(PTR, PointPTR);
   End;

 {Mise En Place De Differents Points Du PTR}
   PointPTR.Where := J;
   PointPTR.NumberOfRecords := I;
   If Not User.NetStatus Then
   If User.UseCurentDate = False Then PointPTR.MDate := Msg.Date+' '+Msg.Time+':00'
                                 Else PointPTR.MDate := DateTime
                                 Else PointPTR.MDate := Msg.Date+' '+Msg.Time+':00';

   If User.NetStatus = False Then PointPTR.FromWho := CMajMin(UserName)
                             Else PointPTR.FromWho := CMajMin(Msg.MsgFrom);
    Msg.MsgTo := RTrim(Msg.MsgTo, #32);
   PointPTR.ToWho   := CMajMin(Msg.MsgTo);
    Msg.MsgTo := CMajMin(Msg.MsgTo);
   PointPTR.OrgTo   := RTrim(Msg.MsgTo, #32);
   PointPTR.SubJect := Msg.MsgSubj;
   PointPTR.MsgSent     := False;
   PointPTR.Available   := False;
   PointPTR.ThreadMsg   := False;
   PointPTR.ThreadStart := False;
    If Msg.MsgStatus = ' ' Then PointPTR.Private     := False;
    If Msg.MsgStatus = '-' Then PointPTR.Private     := False;
    If Msg.MsgStatus = '*' Then PointPTR.Private     := True;
    If Msg.MsgStatus = '+' Then PointPTR.Private     := True;
    If Msg.MsgStatus = '~' Then PointPTR.Private     := True;
    If Msg.MsgStatus = '`' Then PointPTR.Private     := True;
   PointPTR.Received    := False;
   PointPTR.Deleted     := False;
   PointPTR.Conference := StrToInt(Reduce(Msg.MsgNum,' '));
   PointPTR.OrgMsgNumber := StrToInt(Reduce(Msg.RefNum, ' '));
   PointPTR.QWK_ID := 'BSFMail ';
   PointPTr.QWK_Delete_Org := False;
   PointPTR.DupChkCRC := 0;
   FillChar(PointPTR.NetRoute, SizeOf(PointPTR.NetRoute), #0);
   If User.NetStatus Then
    For I := 0 To SizeOf(PointPTR.NetRoute)-2 Do PointPTR.NetRoute[I] := UserName[I+1];
   Inc(PointPTR.MsgNumber);

  Seek(PTR, FileSize(PTR));
  Write(PTR, PointPTR);
  {$I-} Close(PTR); {$I+}
  If Ioresult <> 0 Then;

  Inc(NbOfImp);
 End;
End;
  Until Position >= FileSize(Mail)-1;

Close(Mail);

 RmWriteln('');
 RmWriteln('');
{$IFDEF ENGLISH}
 If NbOfMsg <= 1 Then RmWriteln('þ '+IntToStr(NbOfMsg)+' Message Uploaded.')
  Else RmWriteln('þ '+IntToStr(NbOfMsg)+' Messages Uploaded.');
 If NbOfTra >= 1 Then
  If NbOfTra = 1 Then RmWriteln('þ '+IntToStr(NbOfTra)+' Command Processed.')
                 Else RmWriteln('þ '+IntToStr(NbOfTra)+' Commands Processed.');
 If NbOfImp <= 1 Then RmWriteln('þ '+IntToStr(NbOfImp)+' Message Imported.')
  Else RmWriteln('þ '+IntToStr(NbOfImp)+' Messages Imported.');
 If NbOfRej >= 1 Then
  If NbOfRej = 1 Then RmWriteln('þ '+IntToStr(NbOfRej)+' Message Rejeted.')
                 Else RmWriteln('þ '+IntToStr(NbOfRej)+' Messages Rejeted.');
 RmWriteln('');
 RmWriteln('þ Thank You.');
{$ELSE}
 If NbOfMsg <= 1 Then RmWriteln('þ '+IntToStr(NbOfMsg)+' Message Upload.')
  Else RmWriteln('þ '+IntToStr(NbOfMsg)+' Messages Uploads.');
 If NbOfTra >= 1 Then
  If NbOfTra = 1 Then RmWriteln('þ '+IntToStr(NbOfTra)+' Commande Traite.')
                 Else RmWriteln('þ '+IntToStr(NbOfTra)+' Commandes Traites.');
 If NbOfImp <= 1 Then RmWriteln('þ '+IntToStr(NbOfImp)+' Message Import.')
  Else RmWriteln('þ '+IntToStr(NbOfImp)+' Messages Imports.');
 If NbOfRej >= 1 Then
  If NbOfRej = 1 Then RmWriteln('þ '+IntToStr(NbOfRej)+' Message Rejet.')
                 Else RmWriteln('þ '+IntToStr(NbOfRej)+' Messages Rejets.');
 RmWriteln('');
 RmWriteln('þ Merci.');
{$ENDIF}

 User.NbMessUpld := User.NbMessUpld + NbOfImp;
 Inc(User.NbUpldPacket);


 UpdateFicheSFUser(NbOfImp);
 UpdateSFSystem(NbOfImp);
 If Not Local Then Delay(2000);
 Efface;

End;

END.