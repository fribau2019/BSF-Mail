{$M 65000,0,262144}

{$I \SOURCE~1\PASCAL\NETMAIL\LANGAGE.DIR}

USES
     CRT,              {Unit CRT}
     DOS,              {Unit DOS}
     MGRFade,          {Unit MGR-Fade        - Fade In & Out }
     MGRCompr,         {Unit MGR-Compression - Type De Compacteurs}
     MGRProto,         {Unit MGR-Protocoles  - Protocoles De Transfert}
     MGRConfs,         {Unit MGR-Conferences - Choix Des Conferences}
     MGRUsers,         {Unit MGR-Users       - Fiches Users}

     MGRCfg,           {Unit MGR-Config      - Configuration Des .CFG}
     MGRStats,         {Unit MGR-Stats       - Stats Sur Les Users}
     MGRHelp,          {Unit MGR-Help        - Maintenance Des Aides}
     MGRExImp,         {UNIT MGR-(Ex/Im)port - Maintenance Des Echanges}
     BSFUtils,
     BSFError,
     MGRMenu,
     MGRDeflt,
     MGRVaria;         {Unit MGR-Variables   - Variables}

CONST DernierePos : Byte = 0;

Var C              : Char;
    Rec            : Byte;
    Y              : Byte;

Procedure Error1;
Begin;
 Writeln;
 Writeln;
 Writeln(' ş R‚pertoire Et/Ou Fichier Non Valide ');
 Halt(2);
End;

Procedure Error2;
Begin;
 Writeln;
 Writeln;
 Writeln(' ş R‚pertoire Non Valide ');
 Halt(2);
End;
{---------------------------------------------------------------------}
Procedure Error;
Begin;
 TextColor(15);
 TextBackGround(0);
 Writeln;
 Writeln;
 Writeln;
{$IFDEF ENGLISH}
 Writeln(' BSFMGR For (C)BSFMAIL By Frederic Ribau - 1995');
 Writeln;

 If ConfigPathName = '' Then
  Begin;
   Writeln(' ş BSFMAIL Environment Not Setting ...');
   If Not FileExists('BSFMAIL.CFG') Then
   Writeln(' şConfig Name Not Present !');
  End;
{$ELSE}
 Writeln(' BSFMGR Pour (C)BSFMAIL Par Frederic Ribau - 1995');
 Writeln;
 If ConfigPathName = '' Then
  Begin;
   Writeln(' ş Environnement BSFMAIL Non D‚finie ...');
   If Not FileExists('BSFMAIL.CFG') Then
   Writeln(' ş Fichier De Configuration Absent !');
  End;
{$ENDIF}
 Writeln;
 Write(^g);
{  Delay(1500); }
End;
{---------------------------------------------------------------------}
Function Passe : Boolean;
Begin;
 If Not _ConfigOk Then
  Begin;
   CurSorOff;
   Passe := False;
   GotoXY(3, Hi(WindMax)-3);
  {$IFDEF ENGLISH}
   Write(' şşş Not Enought Parameters To Run This Function şşş');
  {$ELSE}
   Write(' şşş Pas Assez De Parametres Pour Acceder A Cette Fonction şşş');
  {$ENDIF}
   Delay(1500);
  End;
 If _ConfigOk Then If Not FileExists(ConfigPathName) Then
  Begin;
   CurSorOff;
   Passe := False;
   GotoXY(3, Hi(WindMax)-3);
  {$IFDEF ENGLISH}
   Write(' şşş Not Enought Parameters To Run This Function şşş');
  {$ELSE}
   Write(' şşş Pas Assez De Parametres Pour Acceder A Cette Fonction şşş');
  {$ENDIF}
   Delay(1500);
  End
 Else Passe := True;
End;
{---------------------------------------------------------------------}
Procedure NonDisponible;
Begin;
 GotoXY(23, Hi(WindMax)-1);
 TextColor(11);
 TextBackGround(1);
 Writeln(' FONCTION NON ENCORE DISPONIBLE ');
 TextBackGround(0);
 Delay(1500);
End;
{---------------------------------------------------------------------}
{$IFDEF UNREGISTERED}
Procedure NonEnregistree;
Begin;
 GotoXY(24, Hi(WindMax)-1);
 TextColor(11);
 TextBackGround(1);
 Writeln(' VERSION ENREGISTREE SEULEMENT ');
 TextBackGround(0);
 Delay(1500);
End;
{$ENDIF}
{---------------------------------------------------------------------}
Procedure Cadre;
Begin;
 TextBackGRound(0); TextColor(15);
 Window(1,1,80,25); ClrScr;
 Window(1,1,80,50); ClrSCr;
 TextBackGround(1); TextColor(11);
 GotoXY(16,1); Write('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
{$IFDEF ENGLISH}
 GotoXY(16,2); Write('³ BSF Manager Version '+version+' For Spitfire 3.5 ³');
 GotoXY(16,3); Write('³    For BSFMAIL Version '+Netmail+' And More    ³');
 GotoXY(16,4); Write('³       (C)  '+Date+' ş Frederic Ribau        ³');
 GotoXY(16,5); Write('³             Versailles, France             ³');
{$ELSE}
 GOTOXY(16,2); Write('³ BSF Manager Version '+version+' Pour Spitfire 3.5 ³');
 GOTOXY(16,3); Write('³   Pour BSFMAIL Version '+Netmail+' Et Plus !    ³');
 GOTOXY(16,4); Write('³       (C)  '+Date+' ş Fr‚d‚ric Ribau         ³');
 GOTOXY(16,5); Write('³             Versailles, France           ');
{$IFDEF REGISTERED}
 Write('(R)³');
{$ELSE}
 Write('   ³');
{$ENDIF}
{$ENDIF}
 GOTOXY(16,6); Write('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
 TextColor(15); TextBackGround(0);
 WriteCenter('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿',11);
 For Rec := 1 To 10 Do
  Begin;
   TextColor(15);
   WriteCenter('³                                       ³', 11+Rec);
   TextColor(11);
   WriteCenter(Menu[Rec], 11+Rec);
  End;
 WriteCenter('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ',12+Rec);
End;

{---------------------------------------------------------------------}
{$F+}
Procedure ExitBSFMGR;
Begin;
 IF ErrorAddr <> Nil Then CheckRTError(Config.BSFMailDir, 1);
End;
{$F-}
{---------------------------------------------------------------------}
Begin;

 Exitproc     := @ExitBSFMGR;

 ClrScr;
 ConfigPathName := '';

{ Recherche commande environnement BSFMAIL}
 Swapvectors;
  ConfigPathName := GetEnv('BSFMAIL');
 Swapvectors;

{Si Commande non trouv‚}
 If ConfigPathName = '' Then Error;

  CursorOff;
  If FileExists(ConfigPathName) Then LoadConfiguration(Config);

  Cadre;
  Y := 1;

 Repeat

   TextColor(15); TextBackGround(3);
   WriteCenter(OrdonneCenter(Menu[Y],39),11+Y);

  Repeat
   C := Upcase(ReadKey);
  Until C In ['Q', #27, #72, #80, #13];

  Case C Of

   #80 : Begin;                                 {Fleche Bas}
          TextColor(11); TextBackGround(0);
          WriteCenter(OrdonneCenter(Menu[Y],39),11+Y);
          Inc(Y);
         End;

   #72 : Begin;                                 {Fleche Haut}
          TextColor(11); TextBackGround(0);
          WriteCenter(OrdonneCenter(Menu[Y],39),11+Y);
          Dec(Y);
         End;

   #13 : Begin;
          Case Y Of
           01 : DoorConfig;
           02 : UserEditor;
           03 : ConferenceEditor;
           04 : NonDisponible;{ConfigImportExport;}
           05 : EditProtocole;
           06 : EditCompression;
           07 : NonDisponible;
           08 : ConfigurationAide;
           09 : Statistiques;
           10 : C := #27;
          End;
         CursorOff;
         If Y < 10 Then Cadre;
         End;
  End;

  If Y > 10 Then Y := 01;
  If Y < 01 Then Y := 10;

 Until C in ['Q', #27];
  CursorOn;
  TextBackGround(0); TextColor(15);
  ClrScr;
End.