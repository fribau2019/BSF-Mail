UNIT BSFError;
{$I \SOURCE~1\PASCAL\NETMAIL\LANGAGE.DIR}

Interface

 Procedure CheckRTError(BsfmailDir : String; Fichier : Byte);

Implementation

Uses Dos,
     BSFUtils;

FUNCTION ExtendedError: String ;
  VAR
    Regs : Registers ;
  BEGIN
    FillChar(Regs,Sizeof(Regs),#0) ;
    Regs.AH := $59 ;
    MSDos(Regs) ;
    CASE Regs.AX OF
     {$IFDEF ENGLISH}
      $20 : ExtendedError := 'Share Violation' ;
      $21 : ExtendedError := 'Lock Violation' ;
      $23 : ExtendedError := 'FCB Unavailable' ;
      $24 : ExtendedError := 'Sharing Buffer Overflow' ;
      ELSE  ExtendedError := 'Extended Error ' + HexStr(Regs.AX) ;
     {$ELSE}
      $20 : ExtendedError := 'Violation Du Share' ;
      $21 : ExtendedError := 'Violation D''un Fichier Ferm‚' ;
      $23 : ExtendedError := 'FCB Non Disponible' ;
      $24 : ExtendedError := 'D‚bordement Du Buffer Du Share' ;
      ELSE  ExtendedError := 'Erreur Etendue ' + HexStr(Regs.AX) ;
     {$ENDIF}
    END ;
  END ;


FUNCTION ErrorMsg(Err : Integer): String ;
BEGIN
  CASE Err OF
  {$IFDEF ENGLISH}
      1 : ErrorMsg := 'Invalid Function Number';
      2 : ErrorMsg := 'File Not Found';
      3 : ErrorMsg := 'Path Not Found';
      4 : ErrorMsg := 'Too Many Open Files';
      5 : ErrorMsg := 'File Access Denied';
      6 : ErrorMsg := 'Invalid File Handle';

     12 : ErrorMsg := 'Invalid File Access Code';

     15 : ErrorMsg := 'Invalid Drive Number';
     16 : ErrorMsg := 'Cannot Remove Current Directory';
     17 : ErrorMsg := 'Cannot Rename Across Drives';
     18 : ErrorMsg := 'No More Files';

    100 : ErrorMsg := 'Disk Read Past End Of File';
    101 : ErrorMsg := 'Disk Full';
    102 : ErrorMsg := 'File Not Assigned';
    103 : ErrorMsg := 'File Not Open';
    104 : ErrorMsg := 'File Not Open For Input';
    105 : ErrorMsg := 'File Not Open For Output';
    106 : ErrorMsg := 'Invalid Numeric Format';

    150 : ErrorMsg := 'Disk is write protected';
    151 : ErrorMsg := 'Unknown Unit';
    152 : ErrorMsg := 'Drive Not Ready';
    153 : ErrorMsg := 'Unknown command';
    154 : ErrorMsg := 'CRC Error in data';
    155 : ErrorMsg := 'Bad drive request structure length';
    156 : ErrorMsg := 'Disk seek error';
    157 : ErrorMsg := 'Unknown media type';
    158 : ErrorMsg := 'Sector not found';
    159 : ErrorMsg := 'Printer out of paper';
    160 : ErrorMsg := 'Device write fault';
    161 : ErrorMsg := 'Device read fault';
    162 : ErrorMsg := 'Hardware failure';

    163 : ErrorMsg := ExtendedError ;

    200 : ErrorMsg := 'Division by zero';
    201 : ErrorMsg := 'Range check error';
    202 : ErrorMsg := 'Stack overflow error';
    203 : ErrorMsg := 'Heap overflow error';
    204 : ErrorMsg := 'Invalid pointer operation';
    205 : ErrorMsg := 'Floating point overflow';
    206 : ErrorMsg := 'Floating point underflow';
    207 : ErrorMsg := 'Invalid floating point operation';
    208 : ErrorMsg := 'Overlay manager not installed';
    209 : ErrorMsg := 'Overlay file read error';
    210 : ErrorMsg := 'Object not initialized';
    211 : ErrorMsg := 'Call to abstract method';
    212 : ErrorMsg := 'Stream registration error';
    213 : ErrorMsg := 'Collection index out of range';
    214 : ErrorMsg := 'Collection overflow error';
    215 : ErrorMsg := 'Arithmetic overflow error';
    216 : ErrorMsg := 'General protection fault';
  {$ELSE}
      1 : ErrorMsg := 'Num‚ro De Fonction Invalide';
      2 : ErrorMsg := 'Fichier Non Trouv‚';
      3 : ErrorMsg := 'R‚pertoire Non Trouv‚';
      4 : ErrorMsg := 'Trop De Fichiers Ouverts';
      5 : ErrorMsg := 'AccŠs Fichier Interdit';
      6 : ErrorMsg := 'Nom De Fichier Hors Syntaxe DOS';

     12 : ErrorMsg := 'Code D''AccŠs Fichier Invalide';

     15 : ErrorMsg := 'Num‚ro De Lecteur Invalide';
     16 : ErrorMsg := 'Impossible D''Enlever Le R‚pertoire Courant';
     17 : ErrorMsg := 'Impossible De Renommer Un Fichier Et Son Chemin D''AccŠs';
     18 : ErrorMsg := 'Plus De Fichiers';

    100 : ErrorMsg := 'Erreur De Leccture Fichier';
    101 : ErrorMsg := 'Plus De Place Sur Le Lecteur';
    102 : ErrorMsg := 'Fichier Non Assign‚';
    103 : ErrorMsg := 'Fichier Non Ouvert';
    104 : ErrorMsg := 'Fichier Non Ouvert Pour Ecriture';
    105 : ErrorMsg := 'Fichier Non Ouvert Pour Lecture';
    106 : ErrorMsg := 'Valeur Num‚rique Invalide';

    150 : ErrorMsg := 'Lecteur Prot‚g‚ En Lecture';
    151 : ErrorMsg := 'Lecteur Inconnu';
    152 : ErrorMsg := 'Lecteurr Non Prˆt';
    153 : ErrorMsg := 'Commande Inconnue';
    154 : ErrorMsg := 'CRC Erreur Dans Les Donn‚es';
    155 : ErrorMsg := 'Structure De Communication Du Lecteur Faux';
    156 : ErrorMsg := 'Erreur De Positionnement Du Lecteur';
    157 : ErrorMsg := 'Type De Lecteur Inconnu';
    158 : ErrorMsg := 'Sectors Non Trouv‚s';
    159 : ErrorMsg := 'Fin De Papier Imprimante D‚tect‚e';
    160 : ErrorMsg := 'Erreur D''Ecriture P‚riph‚rique';
    161 : ErrorMsg := 'Erreur De Lecture P‚riph‚rique';
    162 : ErrorMsg := 'Erreur Mat‚riel';

    163 : ErrorMsg := ExtendedError ;

    200 : ErrorMsg := 'Division Par Z‚ro';
    201 : ErrorMsg := 'Variable Tabbleau Hors Norme';
    202 : ErrorMsg := 'D‚bordement De La Pile';
    203 : ErrorMsg := 'Erreur De Block M‚moire';
    204 : ErrorMsg := 'Op‚ration Pointeur Invalide';
    205 : ErrorMsg := 'D‚bordement De Virgule Flottante';
    206 : ErrorMsg := 'D‚bordement Inverse De Virgule Flottante';
    207 : ErrorMsg := 'Op‚ration En Virgule Flottante Invalide';
    208 : ErrorMsg := 'Gestionnaire Overlay Non Install‚';
    209 : ErrorMsg := 'Erreur De Lecture Du Fichier Overlay';
    210 : ErrorMsg := 'Object Non Initialis‚';
    211 : ErrorMsg := 'Call to abstract method';
    212 : ErrorMsg := 'Stream registration error';
    213 : ErrorMsg := 'Collection index out of range';
    214 : ErrorMsg := 'Collection overflow error';
    215 : ErrorMsg := 'D‚bordement Du Calcul Arithm‚tique';
    216 : ErrorMsg := 'Faute De Protection G‚n‚rale';
  {$ENDIF}
  END ;
END ;




Procedure CheckRTError(BsfmailDir : String; Fichier : Byte);
Var
 F : Text ;

Begin
If Ioresult <> 0 Then ;
 Assign(F,BSFMailDir+'BSFERROR.LOG') ;
 {$I-} Reset(F) ; {$I+}
 IF IOResult <> 0 THEN Rewrite(F) Else Append(F);

 Write(F, Date(0)+' '+Time+' ') ;
 If Fichier = 0 Then Write(F,'þ BSFMAIL RunTime Error ',ExitCode,' at ');
 If Fichier = 1 Then Write(F,'þ BSFMGR  RunTime Error ',ExitCode,' at ');
 Write(F,HexStr(Seg(ErrorAddr^)) + ':') ;
 Write(F,HexStr(Ofs(ErrorAddr^)) + ': ') ;
 Writeln(F,ErrorMsg(ExitCode)) ;
 Close(F) ;

 ErrorAddr := Nil ;
End;



End.