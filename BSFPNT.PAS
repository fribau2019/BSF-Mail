Unit BSFPNT;


{$I LANGAGE.DIR}


Interface

 Procedure UploadPointeur (MaxConf : Integer);

Implementation

Uses Dos,
     Crt,
     BSFCRC32,
     BSFConst,
     BSFComm,
     BSFLog,
     BSFUtils,
     BSFSwap;


Const TempDir : String[8] = '00000000';


TYPE
(* BBSID.PNT *)
  Pointeurs = Record
               Position : LongInt;
              End;
(* SFMSG[X].LMR *)
LastMessage   = Record
                  LMsgRed : LongInt;
                End;

VAR PNT        : File Of Pointeurs;
    Point      : Pointeurs;
    X,
    I          : Integer;
    LM         : File Of LastMessage;
    LMR        : LastMessage;
    DirInfo    : SearchRec;
    Fichier    : File;
    C          : Char;
    Chaine     : String[80];
    Commande   : String;
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
    Erase(Fichier1);
    MovingFile := True;
  End;
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
Function SFMSG(Rec : Integer) : String;
Begin;
 If Rec < 9  Then SFMSG := 'SFMSG0'+IntToStr(Rec+1)
  Else SFMSG := 'SFMSG'+IntToStr(Rec+1);
End;
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

 If ( (Comp.Lettre >= 'A') And (Comp.Lettre <= 'Z')) Then
                                                     Else Comp.Lettre := '';

 Compres := '';

 If Point = 0 Then Compres := IntToStr(FileSize(Compress)-1); {Numero}
 If Point = 1 Then Compres := Comp.Lettre;                    {Lettre}
 If Point = 2 Then Compres := Comp.Name;                      {Nom}
 If Point = 3 Then Compres := Comp.DeCompress;                {Commande De D‚compression}
 If Point = 4 Then Compres := Comp.Compress;                  {Commande De Compression}
 If Point = 5 Then Compres := MAJ(Copy(Comp.Decompress, 1, Pos(' ', Comp.DeCompress))); {Nom De L'EXE Pour DeCompresser}
 If Point = 6 Then Compres := MAJ(Copy(Comp.compress, 1, Pos(' ', Comp.Compress)));     {Nom De L'EXE Pour Compresser}
End;
{---------------------------------------------------------------------------}

Procedure UploadPointeur (MaxConf : Integer);

Begin;

 (* Creation Du Repertoire Temporaire *)
  TempDir := IntToStr(Abs(CRC(UserName)));
  {$I-} MkDir(TempDir); {$I+}
  If IoResult <> 0 Then
   Begin;
    Repeat
     FindFirst(TempDir+'\*.*', Archive, DirInfo);
     While DosError = 0 Do
     Begin;
      Assign(Fichier, TempDir+'\'+DirInfo.Name);
      {$I-} Close(Fichier); {$I+}
      If Ioresult <> 0 Then;
      Erase(Fichier);
      FindNext(DirInfo);
     End;
    Until DosError <> 0;
    {$I-} MkDir(TempDir); {$I+}
    If IoResult <> 0 Then;
   End;

 RmClrSCr;
 RmWriteln('');
 RmWriteln('');


  If Not FileExists(Config.PrescanDir+TempDir+'.QWK') Then
   If Online Then
   {$IFDEF ENGLISH}
    RmWrite('þ Are You Sure You Want To Upload The File '+Config.BBSID+'.PNT (y/N) : ')
   {$ELSE}
    RmWrite('þ Etes-Vous S–r De Vouloir Uploader Le Fichier '+Config.BBSID+'.PNT (o/N) : ')
   {$ENDIF}
   Else
    Begin;
   {$IFDEF ENGLISH}
    Writeln('þ Ready To Receive '+Config.BBSID+'.PNT Locally...');
    Writeln;
    Write('þ Directory ('+Config.LocalQWK+Config.BBSID+'.PNT) Ok ? (Y/n/Q]uit) : ');
   {$ELSE}
    Writeln('þ Prˆt A Recevoir '+Config.BBSID+'.PNT Localement...');
    Writeln;
    Write('þ R‚pertoire ('+Config.LocalQWK+Config.BBSID+'.PNT) Ok ? (Y/n/Q]uitter) : ');
   {$ENDIF}
   End
  Else
   {$IFDEF ENGLISH}
    RmWrite('þ Are You Sure You Want To Remove The Prescan Packet (y/N) : ');
   {$ELSE}
    RmWrite('þ Etes-Vous S–r De Vouloir Effacer Le Paquet Pr‚scann‚ (o/N) : ');
   {$ENDIF}
  Repeat
   C := Upcase(RmReadKey);
  Until C in ['Y','O','N', #13, #27];
   RmWriteln(C);
   Case C Of
    'O',
    'Y' :;
    'N',
    #27,
    #13 : Exit;
   End;


(* Reception Du BBSID.PNT En Local *)
 If Not FileExists(Config.PrescanDir+TempDir+'.QWK') Then
  If Local Then
    Case C Of
     'O',
     'Y' : Begin;
            If MovingFile(Config.LocalQWK+Config.BBSID+'.PNT',TempDir+'\'+Config.BBSID+'.PNT') = True Then
             Begin;
              Writeln;
             {$IFDEF ENGLISH}
              Writeln('þ Successfull Transfering '+Config.BBSID+'.PNT');
             {$ELSE}
              Writeln('þ Transfert '+Config.BBSID+'.PNT R‚ussi');
             {$ENDIF}
              SuccessTransfert;
             End
            Else
             Begin;
              Writeln;
             {$IFDEF ENGLISH}
              Writeln('þ File '+Config.BBSID+'.PNT Not Found In Directory '+Config.LocalQWK);
             {$ELSE}
              Writeln('þ Fichier '+Config.BBSID+'.PNT Non Trouv‚ Dans Le R‚pertoire '+Config.LocalQWK);
             {$ENDIF}
              Delay(3000);
              ProblemTransfert;
              Repeat
              FindFirst(TempDir+'\*.*', Archive, DirInfo);
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
              Exit;
             End;
            End;

     'N' : Begin;
            Writeln;
           {$IFDEF ENGLISH}
            Writeln('þ Please Write '+Config.BBSID+'.PNT Directory :');
           {$ELSE}
            Writeln('þ Veuillez Ecrire Le R‚pertoire O— Est '+Config.BBSID+'.PNT :');
           {$ENDIF}
            Chaine := '';
            ReadLn(Chaine);
            If Copy(Chaine, Length(Chaine), 1) = '\' Then Else Chaine := Chaine + '\';
            If Chaine = '' Then Exit
             Else
              Begin;
               If IoResult <> 0 Then Else
                Begin;
                 If MovingFile(Chaine+Config.BBSID+'.PNT',TempDir+'\'+Config.BBSID+'.PNT') = True Then
                  Begin;
                   Writeln;
                  {$IFDEF ENGLISH}
                   Writeln('þ Successfull Transfering '+Config.BBSID+'.PNT');
                  {$ELSE}
                   Writeln('þ Transfert '+Config.BBSID+'.PNT R‚ussi');
                  {$ENDIF}
                   SuccessTransfert;
                  End
                 Else
                  Begin;
                   Writeln;
                  {$IFDEF ENGLISH}
                   Writeln('þ File '+Config.BBSID+'.PNT Not Found In Directory '+Chaine);
                  {$ELSE}
                   Writeln('þ Fichier '+Config.BBSID+'.PNT Non Trouv‚ Dans Le R‚pertoire '+Chaine);
                  {$ENDIF}
                   ProblemTransfert;
                   Repeat
                   FindFirst(TempDir+'\*.*', Archive, DirInfo);
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
                   Exit;
                  End;
              End;
             End;
           End;

     'Q' : Begin;
            Repeat
            FindFirst(TempDir+'\*.*', Archive, DirInfo);
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
            Exit;
           End;
    End
  Else
 Else
  Begin;
   RmWriteln('');
   RmWriteln('þ Resseting Old Pointeurs');

   Commande := Copy(Compres(3), Pos(' ', Compres(3)), length(Compres(3)));
   Commande := Commande + ' '+Config.PrescanDir+TempDir+'.QWK '+TempDir+'\ '+Config.BBSID+'.PNT >Nul';

   DosError := DosShell (Compres(5)+' ',Commande,USE_ALL,$ffff,false);
   If DosError <> 0 Then Begin;
                          Writeln;
                          Writeln('Error During De'+Compres(2)+'''ing... DOS ErrorLevel ', DosError);
                          Delay(1500);
                          Exit;
                         End;

  End;

(* Reception Du BBSID.PNT OnLine *)
 If Not FileExists(Config.PrescanDir+TempDir+'.QWK') Then
 If Not Local Then
  If ( (Comport > 0) And (Carrier = True) ) Then
   Begin;
    {$IFDEF ENGLISH}
     RmWriteln('þ Ready To Receive '+Config.BBSID+'.PNT With '+Protoc(2));
    {$ELSE}
     RmWriteln('þ Prˆt A Recevoir '+Config.BBSID+'.PNT Avec '+Protoc(2));
    {$ENDIF}

    RmWriteln('');
    Chaine := Copy(Protoc(3), Pos(' ', Protoc(3)), Length(Protoc(3)));
    Chaine := Chaine + ' '+TempDir+'\'+Config.BBSID+'.PNT';

    DosError := DosShell (Copy(Protoc(3), 1, Pos(' ', Protoc(3))),
                          Chaine,
                          USE_ALL,
                          $ffff,
                          false);

    Delay(2500);
    If DosError=0 Then
     Begin;
     {$IFDEF ENGLISH}
      Writeln('þ Successfull Transfering '+Config.BBSID+'.PNT');
     {$ELSE}
      Writeln('þ Transfert '+Config.BBSID+'.PNT R‚ussi');
     {$ENDIF}

      SuccessTransfert;
     End
    Else
     Begin;
      ProblemTransfert;
      RmWriteln('');
      RmWriteln('');
     {$IFDEF ENGLISH}
      RmWriteln('þ Problem Uploading '+Config.BBSID+'.PNT');
     {$ELSE}
      RmWriteln('þ ProblŠme Durant L''Upload De '+Config.BBSID+'.PNT');
     {$ENDIF}
      Repeat
      FindFirst(TempDir+'\*.*', Archive, DirInfo);
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
      Delay(3000);
      Exit;
     End;
   End;

   RmWriteln('');
  {$IFDEF ENGLISH}
   RmWriteLn('þ Resetting With Old Pointers...');
  {$ELSE}
   RmWriteLn('þ Mise En Place Des Anciens Pointeurs...');
  {$ENDIF}
   RmWriteln('');


   If Not FileExists(TempDir+'\'+Config.BBSID+'.PNT') Then
    Begin;
     RmWriteln('');
     RmWriteln('  Bad File Format.');
     RmWriteln('   Halting.');
     Repeat
     FindFirst(TempDir+'\*.*', Archive, DirInfo);
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
     Delay(3000);
     Exit;
    End;

(* Lecture Du BBSID.PNT *)
  Assign(PNT, TempDir+'\'+Config.BBSID+'.PNT');
  Reset(PNT);

(* Ouverture/Fermeture du fichier SFMSG[x].LMR *)
 {$IFDEF ENGLISH}
  RmWriteln('þ Resetting Pointers, Please Wait...');
 {$ELSE}
  RmWriteln('þ Repositionnement Des Pointeurs, Veuillez Attendre...');
 {$ENDIF}
  RmWriteLn(' ');
  RmWriteln('[0|||||||||||||||||25|||||||||||||||||50|||||||||||||||||75|||||||||||||||100]');
  RmWrite(' ');


  For I := 0 To MaxConf Do
   Begin;
    For X := 1 To Trunc(I/MaxConf*76) - Trunc((I-1)/MaxConf*76) Do RmWrite('°');
    If FileExists(Config.MsgDir+SFMSG(I)+'.LMR') = True Then
     Begin;
      Seek(PNT, I);
      Read(PNT, Point);
      If Point.Position > 0 Then
       Begin;
        Assign(LM, Config.MsgDir+SFMSG(I)+'.LMR');
        Reset(LM);
        Seek(LM, User.SFNumero);
        LMR.LmSgRed := Point.Position;
        Write(LM, LMR);
        Close(LM);
       End;
     End;
   End;
  Close(PNT);

  RmWriteln('');


 If FileExists(Config.PrescanDir+TempDir+'.QWK') Then
  Begin;
   Assign(Fichier, Config.PrescanDir+TempDir+'.QWK');
   Reset(Fichier);
   Close(Fichier);
   Erase(Fichier);
   RmWriteln('');
   RmWriteln('þ Fichier Prescan Effac‚ !');
   RmWriteln('');
  End;

  Repeat
  FindFirst(TempDir+'\*.*', Archive, DirInfo);
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

  Delay(1500);

End;


END.