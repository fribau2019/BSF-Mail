{$A+,B+,D+,E+,G-,I+,L+,N-,O-,R-,S-,V+,X+,F+}
{$M 20000,16384,655360}
Program BSFMail;

{$I \SOURCE~1\PASCAL\NETMAIL\LANGAGE.DIR}

Uses Crt,           {Unit CRT                                        }
     Dos,           {Unit DOS                                        }
     BsfCRC32,      {Unit BSFCRC32   - Calcul De CRC 32              }
     BSFComm,       {Unit BSFDOOR    - Gestion Des Comm             *}
     BSFConst,      {Unit CONSTANT   - Constantes De BSFMail         }
     BSFMnScn,      {Unit MAINSCREEN - Ecran De BSFMail             *}
     BSFOpton,      {Unit OPTION     - Configuration Pour User      *}
     BSFCompr,      {Unit NETCOMP    - Configuration Compression    *}
     BSFProto,      {Unit NETPROTO   - Configuration Protocoles     *}
     BSFConfs,      {Unit NETCONF    - Configuration Conferences    *}
     BSFLog,        {Unit NETLOG     - Log                           }
     BSFSize,       {Unit NETSIZE    - Configuration Taille Packet  *}
     BSFTests,      {Unit NETTEST    - Test De Presence De Fichiers  }
     BSFDown,       {Unit NETDOWN    - Procedure Download           *}
     BSFUpld,       {Unit UPLOAD     - Procedure Upload             *}
     BSFPnt,        {Unit BSFPNT     - Upload Des Pointeurs         *}
     BSFSwap,       {Unit SWAP       - Swap XMS/EMS/File             }
     BSFHelp,       {Unit BSFHELP    - Help On Command              *}
     BSFVerif,      {Unit BSFVERIFY  - Verification Des Users        }
     BSFError,      {Unit BSFERROR   - RunTime Errors Librairie     *}
     BSFUtils;      {Util BSFUTILS   - Utilitaires Pour BSFMAIL      }

(*-------------------------------------------------------------------------*)
Procedure TestMem;

FUNCTION Dosmem : LONGINT;
Type
  MCBrec = RECORD
             location   : Char; {----'M' is normal block, 'Z' is last block }
             ProcessID,
             allocation : WORD; {----Number of 16 Bytes paragraphs allocated}
             reserved   : ARRAY[1..11] OF Byte;
           END;

  PSPrec = RECORD
             int20h,
             EndofMem        : WORD;
             Reserved1       : BYTE;
             Dosdispatcher   : ARRAY[1..5] OF BYTE;
             Int22h,
             Int23h,
             INT24h          : POINTER;
             ParentPSP       : WORD;
             HandleTable     : ARRAY[1..20] OF BYTE;
             EnvSeg          : WORD; {----Segment of Environment}
             Reserved2       : LONGINT;
             HandleTableSize : WORD;
             HandleTableAddr : POINTER;
             Reserved3       : ARRAY[1..23] OF BYTE;
             Int21           : WORD;
             RetFar          : BYTE;
             Reserved4       : ARRAY[1..9] OF BYTE;
             DefFCB1         : ARRAY[1..36] OF BYTE;
             DefFCB2         : ARRAY[1..20] OF BYTE;
             Cmdlength       : BYTE;
             Cmdline         : ARRAY[1..127] OF BYTE;
           END;

Var
  pmcb   : ^MCBrec;
  emcb   : ^MCBrec;
  psp    : ^PSPrec;
  dmem   : LONGINT;

Begin
   psp:=PTR(PrefixSeg,0);      {----PSP given by TP var                }
  pmcb:=Ptr(PrefixSeg-1,0);    {----Programs MCB 1 paragraph before PSP}
  emcb:=Ptr(psp^.envseg-1,0);  {----Environment MCB 1 paragraph before
                                    envseg                             }
  dosmem:=LONGINT(pmcb^.allocation+emcb^.allocation+1)*16;
End; {of DOSmem}


Begin;
 If Dosmem <= 300000 Then
  Begin;
   ClrScr;
   Writeln;
 {$IFDEF ENGLISH}
   Writeln(' þ Not Enough Memory ....');
   Writeln;
   Writeln(' Memory Available : ',Dosmem,' Octets');
   Writeln(' Memory Need      : 300 000 Octets');
  {$ELSE}
   Writeln(' þ Pas Assez De M‚moire ....');
   Writeln;
   Writeln(' M‚moire Disponible : ',Dosmem,' Octets');
   Writeln(' M‚moire N‚cessaire : 300 000 Octets');
  {$ENDIF}
   Delay(1000);
   Halt(1);
   End;
End;
{-------------------------------------------------------------------------}
Procedure MiseEnPlaceConfDefault;
Type
(* NETCONF.DEF *)
       ConfigurationConferenceParDefault = Record
                        Default : Boolean;
                        Force   : Boolean;
                        Extra   : Array[0..9] Of Byte;
       End;
Var
    Def     : File Of ConfigurationConferenceParDefault;
    Default : ConfigurationConferenceParDefault;
    Rec     : Word;
Begin;
 Assign(Def, Config.BsfMailDir+'BSFCONF.DEF');
 Reset(Def);
 For Rec := 0 To Register Do
  Begin;
   Seek(Def, Rec);
   Read(Def, Default);
   If ( Default.Default Or Default.Force ) Then User.Conf.Attribut[Rec] := 01
                                           Else User.Conf.Attribut[Rec] := 00;
  End;
 Close(Def);
End;
{-------------------------------------------------------------------------}
Procedure MiseEnPlaceDonneesUser;
Begin;
                         User.Name            := UserName;
                         User.Protocol        := 0;
                         User.Compression     := 0;
                         User.Welcome         := False;
                         User.Bulletin        := False;
                         User.UploadFiles     := False;
                         User.DownloadFiles   := False;
                         User.Prescan         := False;
                         User.UseCurentDate   := False;
                         User.News            := False;
                         User.SmallControl    := False;
                         User.SendUserInf     := False;
                         User.NDXFiles        := True;
                         User.RepeatScan      := False;
                         User.Goodbye         := False;
                         User.AllowFileUpld   := False;
                         User.AllowFileDown   := False;
                         User.XPertMode       := False;
                         User.NbPageSysOp     := 0;
                         User.NbMessDown      := 0;
                         User.NbMessUpld      := 0;
                         User.NbConnection    := 0;
                         User.LastQWKDate     := 'N/A';
                         User.LastQWKTime     := '00:00';
                         User.NetStatus       := False;
                         USer.NbMailConf      := 200;
                         User.NbMailTTle      := 1000;
                         User.NewFiles        := Config.AddFiles;
                         User.NbMailConf      := 0;
                         User.NbDownPacket    := 0;
                         User.NbUpldPacket    := 0;
                         FillChar(User.Extra , SizeOf(User.Extra) , #0);
                         FillChar(User.Extra1, SizeOf(User.Extra1), #0);
{                        FillChar(User.Conf  , SizeOf(User.Conf)  , #0); }

End;
{-------------------------------------------------------------------------}
Procedure RechercheFicheUser;
Var Fin     : Boolean;
    I       : Integer;
    Door    : Text;
    RePonse : String[10];

Begin;
 Fin     := False;
 RecUser := 0;
 Assign(USR, Config.BsfMailDir+'BSFUSERS.DAT');
 {$I-} Reset(USR); {$I+}
 If IoResult <> 0 Then
  Begin;
   Writeln;
  {$IFDEF ENGLISH}
   Writeln(' þ Creating User Database !');
  {$ELSE}
   Writeln(' þ Cr‚ation De La Base User !');
  {$ENDIF}
   Delay(500);
   ReWrite(USR);
   MiseEnPlaceDonneesUser;
   Seek(USR, 0);
   Write(USR, User);
   RecUSer := 1;
   Fin := True;
  End
 Else
  Begin;
  {$IFDEF ENGLISH}
   Writeln(' þ Searching User...');
  {$ELSE}
   Writeln(' þ Recherche De La Fiche User...');
  {$ENDIF}
  Repeat
(*Lecture De La Fiche Du User *)
   Seek(USR, RecUser);
   Read(USR, User);
   If Maj(User.Name) = Maj(UserName) Then Fin := True;
   Inc(RecUser);
  Until ( (Fin = True) Or (RecUser >= FileSize(USR)) );
  End;

 Config.RecMail := RecUser-1;

(* Si User Non Trouve, on Cree Une Nouvelle Fiche *)
 If Fin = False Then
  Begin;
  {$IFDEF ENGLISH}
   Writeln(' þ Adding New User.');
  {$ELSE}
   Writeln(' þ Ajoue D''Un User.');
  {$ENDIF}
   MiseEnPlaceDonneesUSer; {Nouvelle Fiche}
   If FileExists(Config.BsfMailDir+'BSFCONF.DEF') Then MiseEnPlaceConfDefault;
   Seek(USR, FileSize(USR));
   Write(USR, User);
   Config.RecMail := FileSize(USR)-1;

   If Ansicolor = True  Then
    If FileExists('BSFNUSER.CLR') = True
     Then RmDisplayFile('BSFNUSER.CLR', False)
    Else
     If FileExists('BSFNUSER.BBS') = True
      Then RmDisplayFile('BSFNUSER.BBS', False);

   If Ansicolor = False Then
    If FileExists('BSFNUSER.BBS') = True
     Then RmDisplayFile('BSFNUSER.BBS', False);
  End;

 Seek(USR, Config.RecMail);
 Write(USR, User);
 Close(USR);
End;
{-------------------------------------------------------------------------}
Procedure VerifieNumeroSF;
Var  F : Text;
     S : String;
     I : Word;
Begin;
 If Not Local Then Assign(f,Config.SFDir+'DOOR.SYS');
 If     Local Then Assign(f,Config.BSFMailDir+'DOOR.SYS');
 Reset(F);
 For I := 1 To 25 Do ReadLn(F);
 Readln(F,S); User.SFNumero := StrToInt(S);
 Close(F);
End;
{-------------------------------------------------------------------------}
Function MaxConf : Integer;
Var MsgS : File Of Array[1..126] Of Byte;
    Msg  : Array[1..126] Of Byte;

Begin;
 Assign(MsgS, Config.SFDir+'SFMCONF.DAT');
 Reset(Msgs);
 Maxconf := FileSize(MsgS)-1;
 Close(MSgs);
End;
{-------------------------------------------------------------------------}
Procedure LireFicheUserSF(Var SF : UsersSF);
Var SFCALL   : File Of UsersSF;
    IRec      : Word;
Begin;
 Assign(SFCALL, Config.WorkDir+'SFUSERS.DAT');
 {$I-} Reset(SFCALL); {$I+}
 If Ioresult <> 0 Then Halt(1);
 Seek(SFCALL, User.SFNumero);
 Read(SFCALL, SF);
 IRec := 0;
 If MAJ(User.Name) = MAJ(SF.Username) Then
  Repeat
  Seek(SFCALL, IRec);
  Read(SFCALL, SF);
  Inc(IRec)
  Until ( (MAJ(User.Name) = MAJ(SF.Username)) Or (IRec >= FileSize(SFCALL)) );

 If IRec >= FileSize(SFCALL) Then Halt(255)
  Else User.SFNUMERO := IRec - 1;
 Close(SFCALL);
End;
{---------------------------------------------------------------------------}
Function Main : Boolean;
Var C   : Char;
    par : string;
    i   : integer;
    Rec : Word;
    SF       : UsersSF;
    NewBBSID : String[08];
    LocalQWK : String;
    F        : File Of Byte;
    SizeFile : String;

Begin;
(*Ecriture Du LOG *)
 Intro;

(* Mode Automatique*)
 If POS('DOWNLOAD', MAJ(ParamStr(1))) > 0 Then
  Begin;
   AutoMode;
   DownLog;
   Download(True, False, False);
  End;

 If POS('PRESCAN', MAJ(ParamStr(1))) > 0 Then
  Begin;
   VerifyUsers;
   NewBBSID := Config.BBSID;
   LocalQWK := Config.LocalQWK;
   Assign(USR, Config.BsfMailDir+'BSFUSERS.DAT');
   Reset(USR);
   Rec :=  0;
   Repeat
   Seek(USR, Rec);
   Read(USR, User);
   If User.Prescan Then Begin;
                         LireFicheUserSF(SF);
                         UserName := User.Name;
                         Config.Recmail := Rec;
                         PhoneNumber := SF.PhoneNumber;
                         SecLevel    := SF.SecurityLevel;
                         CallingFrom := SF.CallingFrom;
                         Par := Copy(Config.PrescanDir, 1, Length(Config.PrescanDir)-1);
                         If FileExists(Par) Then Download(True, False, True);
                         Config.BBSID := NewBBSID;
                         Config.LocalQWK := LocalQWK;
                        End;
   Inc(Rec);
   Until Rec >= FileSize(USR);
   Close(USR);
  End;


  If POS('UPLOAD', MAJ(ParamStr(1))) > 0 Then
   Begin;
    AutoMode;
    UpldLog;
    NetUpload(True);
   End;

  If POS('VERIFY', MAJ(ParamStr(1))) > 0 Then VerifyUsers;

  If POS('LOCAL', MAJ(ParamStr(1))) > 0 Then Local := True;

  IF POS('TEST', MAJ(ParamStr(1))) > 0 Then TestBSFMAIL;


(* Si ParamŠtre Non Comprit !!! *)
 If ParamCount >= 1 Then If MAJ(ParamStr(1)) <> 'UPLOAD'
                    Then If MAJ(ParamStr(1)) <> 'DOWNLOAD'
                    Then If MAJ(ParamStr(1)) <> 'PRESCAN'
                    Then If MAJ(ParamStr(1)) <> 'LOCAL'
                    Then If MAJ(ParamStr(1)) <> 'VERIFY'
                    Then Begin;
                          Writeln;
                         {$IFDEF ENGLISH}
                          Writeln('  þ Unknown Command : '+MAJ(ParamStr(1)));
                         {$ELSE}
                          Writeln('  þ Commande Inconnue : '+MAJ(ParamStr(1)));
                         {$ENDIF}
                          ParamInconnu;
                          Write(^g);
                          Halt(1);
                         End;

(* Mode Manuel *)
 If ((ParamCount = 0) Or (POS('LOCAL', MAJ(ParamStr(1))) > 0)) Then
  Begin;
   Repeat

    If User.XpertMode = False Then
     Begin;
      DisplayWelcome(USer.SFNumero);

      If Ansicolor Then If FileExists(Config.BSFMailDir+'BSFMAIL.CLR')
       Then RmDisplayFile(Config.BSFMailDir+'BSFMAIL.CLR', False)
       Else AfficheMenuMainNormal;

      If Not Ansicolor Then If FileExists(Config.BSFMailDir+'BSFMAIL.BBS')
       Then RmDisplayFile(Config.BSFMailDir+'BSFMAIL.BBS', False)
       Else AfficheMenuMainNormal;

     End;



 RmSetColor(3,0);

 If User.Prescan Then
  If FileExists(Config.PrescanDir+IntToStr(Abs(CRC(UserName)))+'.QWK') Then
   Begin;
    Assign(F,Config.PrescanDir+IntToStr(Abs(CRC(UserName)))+'.QWK');
    Reset(F);
    SizeFile := IntToStr( (FileSize(F) Div 1024) );
    Close(F);
    RmWriteln('');
   {$IFDEF ENGLISH}
    RmWriteln('QWK PreScan Of '+SizeFile+' K Awaiting...<D> Download');
    RmWriteln(Rep(' ', Length(SizeFile))+'                             <R> Remove');
   {$ELSE}
    RmWriteln('Pr‚Scanne QWK De '+SizeFile+' K En Attente...<D> Pour Le Downloader');
    RmWriteln(Rep(' ', Length(SizeFile))+'                                 <R> Pour L''Effacer');
   {$ENDIF}
   End;

 RmSetColor(15,0);
 RmWriteln('');

 If Not Local Then
 {$IFDEF ENGLISH}
 RmWrite('('+IntToStr(MinutesLeft.Minute)+' min. left) BSFMail Command (?=Help): ')
 {$ELSE}
 If MinutesLeft.Minute > 1
  Then RmWrite('('+IntToStr(MinutesLeft.Minute)+' Min. Restantes) BSFMail Commande (?=Aide): ')
  Else RmWrite('('+IntToStr(MinutesLeft.Minute)+' Min. Restante) BSFMail Commande (?=Aide): ')
 {$ENDIF}
 Else
 {$IFDEF ENGLISH}
 RmWrite('(Local Mode) BSFMail Command (?=Help): ');
 {$ELSE}
 RmWrite('(Mode Local) BSFMail Commande (?=Aide): ');
 {$ENDIF}

 Repeat
  C := Upcase(RmReadKey);
 Until C In ['D','U','Y','M','X','G','Q','O','C','P','S','R','T','?',#13];

 Case C Of

    '?' : Begin;
           {$IFDEF ENGLISH}
           RmWriteln('Help');
           {$ELSE}
           RmWriteln('Aide');
           {$ENDIF}
           HelpMain;
          End;
    'D' : Begin;
          {$IFDEF ENGLISH}
           RmWriteln('Download Packet');
          {$ELSE}
           RmWriteln('Download Paquet');
          {$ENDIF}
           DownLog;
           Download(False, False, False);
          End;
    'U' : Begin;
          {$IFDEF ENGLISH}
           RmWriteln('Upload Packet');
          {$ELSE}
           RmWriteln('Upload Paquet');
          {$ENDIF}
           UpldLog;
           NetUpload(False);

          End;
    'Y' : Begin;
          {$IFDEF ENGLISH}
           RmWriteln('Download Your Personal Message');
          {$ELSE}
           RmWriteln('Download De Vos Messages Personnels');
          {$ENDIF}
           DownPersoLog;
           Download(False, True, False);
          End;
    'M' : Begin;
           {$IFDEF ENGLISH}
           RmWriteln('Graphic Mode On/Off');
           {$ELSE}
           RmWriteln('Mode Graphique On/Off');
           {$ENDIF}
           GraphLog;
           AnsiColor := NOT AnsiColor;
          End;
    'X' : Begin;
           {$IFDEF ENGLISH}
           RmWrite('Expert Mode On/Off');
           {$ELSE}
           RmWrite('Mode Expert On/Off');
           {$ENDIF}
           ExpertLog;
           User.XpertMode := NOT User.XPertMode;
          End;
    'G' : If Config.Goodbye Then
          Begin;
           {$IFDEF ENGLISH}
           RmWriteln('Goodbye');
           {$ELSE}
           RmWriteln('Au Revoir');
           {$ENDIF}
           LogOffLog;
           RmHangup;
          End;
    'O' : Begin;
           RmWriteln('Options');
           OptionLog;
           OptionConfig;
          End;
    'C' : Begin;
           {$IFDEF ENGLISH}
           RmWriteln('Compression Method');
           {$ELSE}
           RmWriteln('Methode De Compression');
           {$ENDIF}
           CompresLog;
           Compression;
          End;
    'P' : Begin;
           {$IFDEF ENGLISH}
           RmWriteln('Transfer Protocol');
           {$ELSE}
           RmWriteln('Protocol De Transfert');
           {$ENDIF}
           ProtoLog;
           Protocole;
          End;
    'S' : Begin;
           {$IFDEF ENGLISH}
           RmWriteln('Select Conferences');
           {$ELSE}
           RmWriteln('Selection Des Conf‚rences');
           {$ENDIF}
           ConfLog;
           SelectConf;
          End;
    'R' : Begin;
           If Not FileExists(Config.PrescanDir+IntToStr(Abs(CRC(UserName)))+'.QWK') Then
            {$IFDEF ENGLISH}
            RmWriteln('Upload Old Pointers')
            {$ELSE}
            RmWriteln('Upload Anciens Pointeurs')
            {$ENDIF}
           Else
            {$IFDEF ENGLISH}
            RmWriteln('Remove Prescan Packet');
            {$ELSE}
            RmWriteln('Effacement Prescan QWK');
            {$ENDIF}
           PointLog;
           UploadPointeur (MaxConf);
           End;
    'T' : Begin;
           {$IFDEF ENGLISH}
           RmWriteln('Size Of Packet');
           {$ELSE}
           RmWriteln('Taille Des Paquets');
           {$ENDIF}
           SizeLog;
           Size;
          End;
    'Q' : Begin;
           {$IFDEF ENGLISH}
           RmWriteln('Quit to BBS');
           {$ELSE}
           RmWriteln('Retour Au BBS');
           {$ENDIF}
           QuitLog;
          End;
    #13 :;
   End;
   RmWriteln('');
  Until C in ['Q', 'G'] ;
 End;
End;
{=========================================================================}
Procedure CheckCRC;
type
  arr256 = array[0..255] of byte;
var
  f : file;
  numread : word;
  block   : arr256;
  csum    : word;
  headercsum : word;
function cmem(var block:arr256; siz:word): word;
var
  r : registers;
begin
  r.ax:= $121C;
  r.ds:= seg(block);
  r.si:= ofs(block);
  r.cx:= siz;
  r.dx:= 0;
  Intr($2F,r);
  cmem:= r.dx;
end;
begin
  if lo(dosversion) < 3 then begin
    writeln('Dos must be 3+...');
    halt;
  end;
  assign(f,paramstr(0));
  reset(f,1);
  seek(f,$12);
  blockread(f,headercsum,2);
  seek(f,$1B);
  csum:= 0;
  repeat
    blockread(f,block,sizeof(block),numread);
    inc(csum,cmem(block,numread));
  until eof(f) or (numread < sizeof(block));
  if headercsum = csum then
   else
  Halt(255);
  Close(f);
End;
{=========================================================================}
Procedure Unregistered;

CONST {$IFDEF ENGLISH}
       CHAINE : String = ' UNREGISTERED VERSION';
      {$ELSE}
       CHAINE : String = 'VERSION NON ENREGISTREE';
      {$ENDIF}

Var I : Byte;

Begin;
 RmSetColor(7,0);
 RmWriteln('');
{$IFDEF ENGLISH}
 RmWriteln('           þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ');
{$ELSE}
 RmWriteln('           þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ');
{$ENDIF}
 RmWrite('           þþþ ');
 RmSetColor(12,0);
 For I := 1 To Length(Chaine) Do
  Begin;
   RmWrite(Chaine[I]+' ');
   BSFUtils.Delay(80);
  End;
 RmSetColor(7,0);
 RmWriteln(' þþþ');
{$IFDEF ENGLISH}
 RmWriteln('           þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ');
 RmSetColor(11,0);
 RmWriteln('           Please Help Your SysOp To Register This Shareware.');
 RmSetColor(7,0);
 RmWriteln('           þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ');
{$ELSE}
 RmWriteln('           þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ');
 RmSetColor(11,0);
 RmWriteln('           Veuillez Aider Votre SysOp A Enregistrer Ce Shareware.');
 RmSetColor(7,0);
 RmWriteln('           þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ');
{$ENDIF}

 RmWrite(^g);
 RmWriteLn('');
 RmSetColor(15,0);
 Delay(300);

End;
{=========================================================================}
{$F+}
Procedure ExitBSFMAIL;

Const TempDir    : String[8] = '0000000';
Var   DirInfo    : SearchRec;
      Fichier    : File;
      Y          : Byte;
Begin;

 IF ErrorAddr <> Nil Then CheckRTError(Config.BsfmailDir, 0);
 Y := WhereY;
 TextColor(White);
 TextBackGround(Black);
 Window(1,VideoMax,80,VideoMax+1);
 GotoXY(1,1); ClrEol;
 GotoXY(1,2); ClrEol;
 Window(1,1,80,VideoMax+1);
 GotoXY(1,Y+1);

 QuitDoor;

 If MAJ(ParamStr(1)) <> 'PRESCAN' Then
 If MAJ(ParamStr(1)) <> 'VERIFY'  Then
 Begin;
       Assign(USR, Config.BsfMailDir+'BSFUSERS.DAT');
       Reset(USR);
       Inc(User.NbConnection);
       Seek(USR, Config.RecMail);
       Write(USR, User);
       Close(USR);
      End;

 {$IFDEF UNREGISTERED}
  Writeln('');
  {$IFDEF ENGLISH}
   Writeln(' BSFMAIL is UNREGISTERED, Please REGISTER IT !');
  {$ELSE}
   Writeln(' BSFMAIL n''est pas ENREGISTRE, Veuillez l''ENREGISTRER !');
  {$ENDIF}
  Write(^g);
 {$ENDIF}

 TempDir := IntToStr(Abs(CRC(UserName)));
 {$I-} MkDir(Tempdir); {$I-}
 If Ioresult = 0 Then
  Begin;
   RmDir(Tempdir);
   Exit;
  End
 Else
  Begin;
   Repeat
    FindFirst(Tempdir+'\*.*', Archive, DirInfo);
   While DosError = 0 Do
    Begin;
     Assign(Fichier, TempDir+'\'+DirInfo.Name);
     {$I-} Close(Fichier); {$I+}
     If Ioresult <> 0 Then;
     Erase(Fichier);
     FindNext(DirInfo);
    End;
   Until DosError <> 0;
   RmDir(TempDir);
  End;
End;
{$F-}
{=========================================================================}
Begin;

{$IFDEF UNREGISTERED}
 RegistrationN := Config.BBSNAME;
 Unregistered;
 CheckCRC;
{$ENDIF}

 TestFile;

 TestMem;

 Exitproc     := @ExitBSFMAIL;

 RechercheFicheUser;
 VerifieNumeroSF;

 If Comport = 0 Then Main;

 If Comport <> 0 Then While ( (Carrier = True) And (Main = False) ) Do Main;

 If Comport <> 0 Then If Carrier = False Then LostCarrier;

End.

