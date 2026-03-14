UNIT BSFTests;

{$I LANGAGE.DIR}

Interface

 Procedure TestFile;
 Procedure TestBSFMAIL;

Implementation

Uses BSFConst,
     BSFLog,
     BSFUtils,
     BSFComm;


CONST
     {$IFDEF ENGLISH}
      MSG01 = ' þ File ';
      MSG02 = ' Not Found !';
      MSG03 = ' Please Create It Now !!!';
      MSG04 = ' : Ok';
     {$ELSE}
      MSG01 = ' þ Fichier ';
      MSG02 = ' Non Trouv‚ !';
      MSG03 = ' Veuillez Le Cr‚er Maintenant !!!';
      MSG04 = ' : Ok';
     {$ENDIF}


Procedure Test(Chemin : String);
Begin;
 If Not FileExists(Chemin) Then
  Begin;
   Writeln(Msg01+MAJ(Chemin)+Msg02);
   Writeln(MSG03);
   FileNotFound(Chemin);
   Halt(1);
  End
 Else
  Writeln(MSG01+MAJ(Chemin)+MSG04);
End;

Procedure Test1(Chemin : String);
Begin;
 If Not FileExists(Chemin) Then
  Begin;
   Writeln(Msg01+MAJ(Chemin)+Msg02);
   FileNotFound(Chemin);
  End
 Else
  Writeln(MSG01+MAJ(Chemin)+MSG04);
End;


Procedure TestFile;
Begin;
 Test(ConfigPathName);
 Test(Config.BsfMailDir +'BSFCOMP.DAT');
 Test(Config.BsfMailDir +'BSFCONF.DAT');
 Test1(Config.BsfMailDir+'BSFCONF.DEF');
 Test1(Config.BsfMailDir+'BSFMAIL.HLP');
 Test(Config.BsfMailDir +'BSFPROTO.DAT');
 Test1(Config.BsfMailDir+'BSFUSERS.DAT');
End;

Procedure TestBSFMAIL;
Begin;
End;



End.