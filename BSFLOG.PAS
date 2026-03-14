UNIT BSFLog;

{$I D:\SOURCE~1\PASCAL\NETMAIL\LANGAGE.DIR}

Interface

 Procedure Intro;
 Procedure OptionLog;
 Procedure CompresLog;
 Procedure ProtoLog;
 Procedure ConfLog;
 Procedure PointLog;
 Procedure SizeLog;
 Procedure LangLog;
 Procedure DownLog;
 Procedure DownPersoLog;
 Procedure GraphLog;
 Procedure ExpertLog;
 Procedure LogOffLog;
 Procedure QuitLog;
 Procedure ScanMail(Nombre : Integer);
 Procedure ScanBulletins(Nombre : Integer);
 Procedure ScanFiles(Nombre : Integer);
 Procedure ScanNews;
 Procedure ScanAbort;
 Procedure SuccessTransfert;
 Procedure ProblemTransfert;
 Procedure AutoMode;
 Procedure QuitDoor;
 Procedure UpldLog;
 Procedure LostCarrier;
 Procedure TooMuchQWK;
 Procedure SuccessDecompacting;
 Procedure ProblemDecompacting;
 Procedure EnterPublic(MsgTo, Conf : String);
 Procedure EnterPrive(MsgTo, Conf : String);
 Procedure BadPacket;
 Procedure FileNotFound(Name : String);
 Procedure PathNotFound(Path : String);
 Procedure ParamInconnu;
 Procedure AddConf(Conf : Word);
 Procedure DropConf(Conf : Word);
 Procedure ResetConf(Conf : Word; Number : LongInt);
 Procedure DeleteUSer;


Implementation

 Uses Dos,
      BSFConst,
      BSFUtils,
      BSFComm;

Const
 {$IFDEF ENGLISH}
  MSG01     = ' þ File ';
  MSG02     = ' Not Found !';
  MSG03     = ' þ Directory ';
  MSG04     = ' þ Parameter : "';
  MSG05     = '" Unknown !';
  Message00 = '     --- Door BSF-Mail version '+Version+' opened at ';
  Message0A = '          By ';
  Message01 = '          þ User configuration selected.';
  Message02 = '          þ Compression used selected.';
  Message03 = '          þ Protocol used selected.';
  Message04 = '          þ Conference selected.';
  Message05 = '          þ Upload pointeur selected.';
  Message06 = '          þ Size of packet selected.';
  Message07 = '          þ Language selected.';
  Message08 = '          þ Download packet selected.';
  Message09 = '          þ Upload packet selected.';
  Message10 = '          þ Download personal packet selected.';
  Message1A = '            ú Scanning messages conferences : ';
  Message1B = '            ú Scanning new bulletins :';
  Message1C = '            ú Scanning new files :';
  Message1D = '            ú Scanning newsletter SysOp.';
  Message1E = ' Found ';
  Message1F = ' messages.';
  Message1G = ' bulletins.';
  Message1H = ' files.';
  Message1I = '            ú Scanning messages conferences : Abort By User !';
  Message1J = '            ú Successful transfering packet';
  Message1K = '            ú Problem during transfert';
  Message11 = '          þ Graphic mode selected.';
  Message12 = '          þ Expert mode selected.';
  Message13 = '          þ Log off selected.';
  Message14 = '          þ Quit to BBS selected.';
  Message15 = '          þ Page sysop selected.';
  Message16 = '          þ Last documentation selected.';
  Message17 = '     --- Door BSF-Mail version '+Version+' closed at ';
  Message18 = '          þ Automatic Mode';
  Message20 = '          þþþþþ Lost Of Carrier Detected þþþþþ';
  Message21 = '          þ To Muck QWK In Local Directory';
  Message22 = '            ú Successful decompacting packet';
  Message2A = '            ú Problem for decompacting packet';
  Message2B = '             ú Private message to ';
  Message2C = '             ú Public message to ';
  Message2D = ' in conference ';
  Message2E = '            ú Bad packet format/signature';
  Message2F = '             ú Add Conf‚rence #';
  Message2G = '             ú Drop Conf‚rence #';
  Message30 = '             ú Conf‚rence ';
  Message31 = ': Pointor To #';
  Message40 = ' Verify BSF-Users Database';
  Message41 = ' þ Deleting ';
 {$ELSE}
  MSG01     = ' þ Fichier ';
  MSG02     = ' Non Trouv‚ !';
  MSG03     = ' þ R‚pertoire ';
  MSG04     = ' þ ParamŠtre : "';
  MSG05     = '" Inconnu !';
  Message00 = '     --- Door BSF-Mail Version '+Version+' Ouverte A ';
  Message0A = '          Par ';
  Message01 = '          þ Configuration Utilisateur S‚lectionn‚e.';
  Message02 = '          þ Mode De Compression S‚lectionn‚.';
  Message03 = '          þ Protocole De Transfert S‚lectionn‚.';
  Message04 = '          þ S‚lection Des Conf‚rences S‚lectionn‚e.';
  Message05 = '          þ Upload Pointeurs S‚lectionn‚.';
  Message06 = '          þ Taille Des Paquets S‚lectionn‚e.';
  Message07 = '          þ Langue S‚lectionn‚e.';
  Message08 = '          þ Download Paquet S‚lectionn‚.';
  Message09 = '          þ Upload Paquet S‚lectionn‚.';
  Message10 = '          þ Download Paquet Personnel S‚lectionn‚.';
  Message1A = '            ú Scanne Des Messages    :';
  Message1B = '            ú Scanne Des Bulletins   :';
  Message1C = '            ú Scanne Des Nv Fichiers :';
  Message1D = '            ú Scanne Nvlle Du SysOp.';
  Message1E = ' Trouv‚ ';
  Message1F = ' Messages.';
  Message1G = ' Bulletins.';
  Message1H = ' Fichiers.';
  Message1I = '            ú Scanne Des Messages : Stopper Par User !';
  Message1J = '            ú Transfert Du Paquet R‚ussi';
  Message1K = '            ú ProblŠme Durant Le Transfert';
  Message11 = '          þ Mode Graphique S‚lectionn‚.';
  Message12 = '          þ Mode Expert S‚lectionn‚.';
  Message13 = '          þ D‚connection S‚lectionn‚e.';
  Message14 = '          þ Retour Au BBS S‚lectionn‚.';
  Message15 = '          þ Appel SysOp S‚lectionn‚.';
  Message16 = '          þ DerniŠre Documentation S‚lectionn‚.';
  Message17 = '     --- Door BSF-Mail Version '+Version+' Ferm‚e A ';
  Message18 = '          þ Mode Automatique';
  Message20 = '          þþþþþ Perte De Porteuse D‚tect‚e þþþþþ';
  Message21 = '          þ Trop De QWK Dans Le R‚pertoire Local !';
  Message22 = '            ú D‚compression du Paquet R‚ussie';
  Message2A = '            ú ProblŠme Durant La D‚compr‚sion Du Paquet';
  Message2B = ': Message Priv‚ A ';
  Message2C = ': Message Public A ';
  Message2D = ' Dans Conf‚rence ';
  Message2E = '            ú Mauvais Format/Signature Du Paquet';
  Message2F = ': Rajout';
  Message2G = ': EnlŠvement';
  Message30 = '             ú Conf‚rence ';
  Message31 = ': Pointeur A #';
  Message40 = ' V‚rification De La Base Users';
  Message41 = ' þ Effacement De La Fiche De ';
 {$ENDIF}

{-------------------------------------------------------------------------}
Procedure Intro;
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  {$I-} Reset(LOG); {$I+}
  If Ioresult <> 0 Then ReWrite(Log)
                   Else Append(LOG);
  Writeln(LOG, Message00+Date(1)+' '+Time);
  Writeln(LOG, Message0A+User.Name);
  Close(LOG);
End;

Procedure OptionLog;
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message01);
  Close(LOG);
End;

Procedure CompresLog;
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message02);
  Close(LOG);
End;

Procedure ProtoLog;
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message03);
  Close(LOG);
End;

Procedure ConfLog;
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message04);
  Close(LOG);
End;

Procedure PointLog;
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message05);
  Close(LOG);
End;

Procedure SizeLog;
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message06);
  Close(LOG);
End;

Procedure LangLog;
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message07);
  Close(LOG);
End;

Procedure DownLog;
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message08);
  Close(LOG);
End;

Procedure DownPersoLog;
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message10);
  Close(LOG);
End;

Procedure GraphLog;
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message11);
  Close(LOG);
End;

Procedure ExpertLog;
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message12);
  Close(LOG);
End;

Procedure LogoffLog;
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message13);
  Close(LOG);
End;

Procedure QuitLog;
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message14);
  Close(LOG);
End;

Procedure ScanMail(Nombre : Integer);
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message1A+Message1E,Nombre,Message1F);
  Close(LOG);
End;

Procedure ScanBulletins(Nombre : Integer);
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message1B+Message1E,Nombre,Message1G);
  Close(LOG);
End;

Procedure ScanFiles(Nombre : Integer);
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message1C+Message1E,Nombre,Message1H);
  Close(LOG);
End;

Procedure DropConf(Conf : Word);
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message30+IntToStr(Conf)+Message2G);
  Close(LOG);
End;

Procedure AddConf(Conf : Word);
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message30+IntToStr(Conf)+Message2F);
  Close(LOG);
End;

Procedure ResetConf(Conf : Word; Number : LongInt);
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message30+IntToStr(Conf)+Message31+IntToStr(Number));
  Close(LOG);
End;

Procedure ScanNews;
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message1D);
  Close(LOG);
End;

Procedure ScanAbort;
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message1I);
  Close(LOG);
End;

Procedure SuccessTransfert;
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message1J);
  Close(LOG);
End;

Procedure ProblemTransfert;
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message1K);
  Close(LOG);
End;

Procedure AutoMode;
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message18);
  Close(LOG);
End;

Procedure QuitDoor;
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message17+Time);
  Close(LOG);
End;

Procedure UpldLog;
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message09);
  Close(LOG);
End;

Procedure LostCarrier;
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message20);
  Close(LOG);
End;

Procedure TooMuchQWK;
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message21);
  Close(LOG);
End;

Procedure SuccessDecompacting;
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message22);
  Close(LOG);
End;

Procedure ProblemDecompacting;
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message2A);
  Close(LOG);
End;

Procedure BadPacket;
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message2E);
  Close(LOG);
End;

Procedure EnterPublic(MsgTo, Conf : String);
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message30+Conf+Message2C+MsgTo);
  Close(LOG);
End;

Procedure EnterPrive(MsgTo, Conf : String);
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.PathLog);
  Append(LOG);
  Writeln(LOG, Message30+Conf+Message2B+MsgTo);
  Close(LOG);
End;

Procedure FileNotFound(Name : String);
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.BsfMailDir+'BSFERROR.LOG');
  {$I-} Append(LOG); {$I+}
  If Ioresult <> 0 Then Rewrite(LOG);
  Writeln(LOG, Date(0)+' '+Time+MSG01+Name+MSG02);
  Close(LOG);
 End;

Procedure PathNotFound(Path : String);
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.BsfMailDir+'BSFERROR.LOG');
  {$I-} Append(LOG); {$I+}
  If Ioresult <> 0 Then Rewrite(LOG);
  Writeln(LOG, Date(0)+' '+Time+MSG03+Path+MSG02);
  Close(LOG);
 End;

Procedure ParamInconnu;
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.BsfMailDir+'BSFERROR.LOG');
  {$I-} Append(LOG); {$I+}
  If Ioresult <> 0 Then Rewrite(LOG);
  Writeln(LOG, Date(0)+' '+Time+MSG04+ParamStr(1)+MSG05);
  Close(LOG);
 End;

Procedure DeleteUSer;
VAR Log  : Text;
 Begin;
  Assign(LOG, Config.BsfMailDir+'BSFUSERS.LOG');
  {$I-} Append(LOG); {$I+}
  If Ioresult <> 0 Then Rewrite(LOG);
  Writeln(LOG, Message41+User.Name);
  Close(LOG);
 End;



END.
