UNIT MGRMenu;

{$I LANGAGE.DIR}

Interface

 Procedure Logo;                             {Menu Principal}
 Procedure CadreMenu;                        {Menu Principal}
 Procedure AfficheUser(Rec        : Word;    {Menu USERS}
                       MaxRec     : Word;
                       ConfActive : Word;
                       ConfNetMail: Word);

Type  Choix = Record
               Name : String;
               Y    : Byte;
               Len  : Byte;
              End;



Const


{$IFDEF ENGLISH}
      Menu : Array [0..MaxMenu] Of String[37] = ('BSFMail Configuration '
				                ,'    Users Editor      '
					        ,' Conferences Editor   '
					        ,' Transfert Protocol   '
					        ,'  Compression Mode    '
(*					        ,'    Packet Size       ' *)
                                                ,'    Statistiques      '
					        ,'       End            ');


      ChoixCFG : Array['A'..'M'] Of String = ('Name Of BBS : '
                                             ,'Name Of BBS ID : '
                                             ,'BBS City/State : '
                                             ,'BBS Phone      : '
                                             ,'SF Directory        : '
                                             ,'BSFMail Directory   : '
                                             ,'Local QWK Directory : '
                                             ,'Path & Name For The Welcome Screen : '
                                             ,'Path & Name For The News           : '
                                             ,'Path & Name For The Goodbye Screen : '
                                             ,'Path & Name For The Usage Log      : '
                                             ,'Always Add New Files       : '
                                             ,'Allow Goodbye From BSFMAIL : ');

      YN : Array[False..True] Of String[3] = ('NO ','YES');
{$ELSE}


      Menu : Array [1..10] Of String[37] = ('Configuration De BSFMAIL',
                                            'Maintenance Des Utilisateurs',
		                            'Maintenance Des Conf‚rences',
                                            'Maintenance Des Imports/Exports',
		                            'Protocole De Transfert',
		                            'Mode De Compression',
		                            'Taille Des Paquets/Messages',
                                            'Maintenance Des Aides',
                                            'Statistiques G‚n‚rales',
		                            'Fin');


      ChoixCFG : Array[1..14] Of Choix = ((Name : 'Rep BSFMail   : '; Y : 7; Len : 60),
                                          (Name : 'Nom Du BBS    : '; Y : 1; Len : 30),
                                          (Name : 'Nom Du BBS ID : '; Y : 2; Len : 08),
                                          (Name : 'Ville Du BBS  : '; Y : 3; Len : 30),
                                          (Name : 'T‚l‚phone BBS : '; Y : 4; Len : 30),
                                          (Name : 'Rep Local QWK : '; Y : 8; Len : 60),
                                          (Name : 'Nom Page Pr‚sentation : '; Y :11; Len : 55),
                                          (Name : 'Nom Page Nouvelles    : '; Y :12; Len : 55),
                                          (Name : 'Nom Page De Fin       : '; Y :13; Len : 55),
                                          (Name : 'Toujours Ajouter Les Nouveaux Fichiers : '; Y :16; Len : 01),
                                          (Name : 'Autoriser La D‚connection Dans BSFMAIL : '; Y :17; Len : 01),
                                          (Name : 'Nom Fichier LOG       : '; Y :14; Len : 55),
                                          (Name : 'Rep Spitfire  : '; Y : 6; Len : 60),
                                          (Name : 'Rep Prescan   : '; Y : 9; Len : 60));



      YN : Array[False..True] Of String[3] = ('NON','OUI');

{$ENDIF}
Implementation

Uses CRT,
     MGRVaria;

{---------------------------------------------------------------------}
Procedure Logo;
Begin;
(*
  TextBackGround(1);
  TextColor(11);
  GOTOXY(16,1); Write('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
{$IFDEF ENGLISH}
  GOTOXY(16,2); Write('³ BSF Manager Version '+version+' For Spitfire 3.5 ³');
  GOTOXY(16,3); Write('³    For BSFMAIL Version '+Netmail+' And More    ³');
  GOTOXY(16,4); Write('³       (C)  '+Date+' þ Frederic Ribau        ³');
  GOTOXY(16,5); Write('³             Versailles, France             ³');
{$ELSE}
  GOTOXY(16,2); Write('³ BSF Manager Version '+version+' Pour Spitfire 3.5³');
  GOTOXY(16,3); Write('³   Pour BSFMAIL Version '+Netmail+' Et Plus !   ³');
  GOTOXY(16,4); Write('³       (C)  '+Date+' þ Fr‚d‚ric Ribau        ³');
  GOTOXY(16,5); Write('³             Versailles, France          ');
 {$IFDEF REGISTERED}
  Write('(R)³');
 {$ELSE}
  Write('   ³');
 {$ENDIF}
{$ENDIF}
  GOTOXY(16,6); Write('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
  TextColor(15);
  TextBackGround(0);
*)
End;
{---------------------------------------------------------------------}
Procedure CadreMenu ;
Begin;
(*
Var I,
    Blanc : Byte;

Begin;
 TextColor(11);
 TextBackGround(0);
 GotoXY(19,11); Write('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
 For I := 0 To MaxMenu Do
  Begin;
   GotoXY(19,12+I); Write('³                                       ³');
   Blanc := ((39 - Length(Menu[I,1])) Div 2);
   GotoXY(20+Blanc,12+I); Write(Menu[I,1]);
  End;
 GotoXY(19,13+MaxMenu); Write('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
*)
End;
{---------------------------------------------------------------------}
Procedure AfficheUser(Rec : Word; MaxRec : Word; ConfActive : Word; ConfNetMail : Word);
Begin;


 TextColor(14);
{$IFDEF ENGLISH}
 GotoXY(36,1);
 Writeln('USERS EDITOR');
{$ELSE}
 GotoXY(28,1);
 Writeln('MAINTENANCE UTILISATEURS');
{$ENDIF}

{$IFDEF ENGLISH}
 TextColor(3); GotoXY(2,1);Write('User #',Rec+1,' Of ', MaxRec);
 GotoXY(58,1); Write('SF User #',User.SfNumero+1);
 TextColor(15);
 GotoXY(1,2); ClrEol;
 GotoXY(1,2); Writeln('úLast QWK : ',User.LastQWKDate,' at ',User.LastQWKTime);

 GotoXY(1,3); Writeln('úName : ',User.name);
{$ELSE}
 TextColor(3); GotoXY(2,1);Write('User #',Rec+1,' Sur ', MaxRec);
 GotoXY(58,1); Write('SF User #',User.SfNumero+1);
 TextColor(15);
 GotoXY(1,2); ClrEol;
 GotoXY(1,2); Writeln('úDernier QWK : ',User.LastQWKDate,' … ',User.LastQWKTime);

 GotoXY(1,3); Writeln('úNom : ',User.name);
{$ENDIF}
 If USer.Netstatus = True Then Begin;
                                TextColor(0);
                                TextBackGround(3);
                                GotoXY(57,2);
                               {$IFDEF ENGLISH}
                                Write('NETMAIL STATUS');
                               {$ELSE}
                                Write('STATUS NETMAIL');
                               {$ENDIF}
                                TextColor(15);
                                TextBackGround(0);
                               End;


{$IFDEF ENGLISH}
 If User.Protocol > 9 Then User.Protocol := 0;
 GotoXY(01,5); Writeln('úProtocol         : ',User.Protocol);
 If User.Compression > 9 Then User.Compression := 0;
 GotoXY(28,5); Writeln('úCompression      : ',User.Compression);

 GotoXY(01,07); Writeln('úWelcome Screen   : ',YN[User.Welcome]);
 GotoXY(01,08); Writeln('úBulletins        : ',YN[User.Bulletin]);
 GotoXY(01,09); Writeln('úSysOp News       : ',YN[User.News]);
 GotoXY(01,10); Writeln('úNews Files Scan  : ',YN[User.NewFiles]);
 GotoXY(01,11); Writeln('úGoodbye Screen   : ',YN[User.Goodbye]);
 GotoXY(01,12); Writeln('úExpert Mode      : ',YN[USer.XpertMode]);
 GotoXY(28,07); Writeln('úSmall CONTROL.DAT: ',YN[User.SmallControl]);
 GotoXY(28,08); Writeln('úSend NDX Files   : ',YN[User.NDXFiles]);
 GotoXY(28,09); Writeln('úSend User Infos  : ',YN[User.SendUserInf]);
 GotoXY(28,10); Writeln('úUse Current Date : ',YN[User.UseCurentDate]);
 GotoXY(28,11); Writeln('úRepeat Prescan   : ',YN[User.RepeatScan]);
 GotoXY(28,12); Writeln('úPrescan          : ',YN[User.Prescan]);
 GotoXY(58,07); Writeln('úUpload Files     : ',YN[User.UploadFiles]);
 GotoXY(58,08); Writeln('úDownload Files   : ',YN[User.DownloadFiles]);
 GotoXY(58,09); Writeln('úAllow Files Upld : ',YN[User.AllowFileUpld]);
 GotoXY(58,10); Writeln('úAllow Files Down : ',YN[User.AllowFiledown]);

 GotoXY(01,13); If User.NbMailConf = 0 Then
       Writeln('úMails Per Conf   : ì')
  Else Writeln('úMails Per Conf   : ',USer.NbMailConf);

 GotoXY(28,13); If User.NbMailTtle = 0 Then
       Writeln('úMails Per Packet : ì')
  Else
       Writeln('úMails Per Packet : ',USer.NbMailTTle);



 GotoXY(1,15); ClrEol;
 GotoXY(8,15); Writeln('úConference Active   : ', ConfActive);

 GotoXY(43,15); If User.NetStatus Then Writeln('úNetMail Conf Active : ', ConfNetMail);
{$ELSE}
 If User.Protocol > 9 Then User.Protocol := 0;
 GotoXY(01,5); Writeln('úProtocole        : ',User.Protocol);
 If User.Compression > 9 Then User.Compression := 0;
 GotoXY(28,5); Writeln('úCompression      : ',User.Compression);

 GotoXY(01,07); Writeln('úEcran Pr‚sentatø : ',YN[User.Welcome]);
 GotoXY(01,08); Writeln('úBulletins        : ',YN[User.Bulletin]);
 GotoXY(01,09); Writeln('úEcran Nouvelles  : ',YN[User.News]);
 GotoXY(01,10); Writeln('úScan Nv Fichiers : ',YN[User.NewFiles]);
 GotoXY(01,11); Writeln('úEcran De Fin     : ',YN[User.Goodbye]);
 GotoXY(01,12); Writeln('úMode Expert      : ',YN[USer.XpertMode]);
 GotoXY(28,07); Writeln('úPetit CONTROL.DAT: ',YN[User.SmallControl]);
 GotoXY(28,08); Writeln('úEnvoie .NDX      : ',YN[User.NDXFiles]);
 GotoXY(28,09); Writeln('úEnvoie Infos User: ',YN[User.SendUserInf]);
 GotoXY(28,10); Writeln('úDate Courante    : ',YN[User.UseCurentDate]);
 GotoXY(28,11); Writeln('úPrescan          : ',YN[User.Prescan]);
 GotoXY(28,12); Writeln('úRepeat Prescan   : ',YN[User.RepeatScan]);
 GotoXY(58,07); Writeln('úUpload Fichiers  : ',YN[User.UploadFiles]);
 GotoXY(58,08); Writeln('úDownload Fichiers: ',YN[User.DownloadFiles]);
 GotoXY(58,09); Writeln('úAutorise Fich Ul : ',YN[User.AllowFileUpld]);
 GotoXY(58,10); Writeln('úAutorise Fich Dl : ',YN[User.AllowFiledown]);

 GotoXY(01,13); If User.NbMailConf = 0 Then
       Writeln('úMsgs Par Conf    : ì')
  Else Writeln('úMsgs Par Conf    : ',USer.NbMailConf);

 GotoXY(28,13); If User.NbMailTtle = 0 Then
       Writeln('úMsgs Par Paquet  : ì')
  Else
       Writeln('úMsgs Par Paquet  : ',USer.NbMailTTle);



 GotoXY(1,15); ClrEol;
 GotoXY(8,15); Writeln('úConf‚rences Actives   : ', ConfActive);

 GotoXY(43,15); If User.NetStatus Then Writeln('úConf‚rences Netmail Actives : ', ConfNetMail);

{$ENDIF}
End;


END.