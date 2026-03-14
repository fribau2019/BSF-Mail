Unit MGRUser1;

{$I LANGAGE.DIR}

Interface

 Procedure SelectConf(RecUser : Integer;
                      SFDIR,
                      RepMail,
                      BsfMailDir : String;
                      RecBSF     : Integer);

Implementation

Uses Crt,
     MGRDeflt,
     MGRVaria,
     BSFConst,
     BSFUtils;


TYPE
  MsgSystem     = Record
                  MSec           : Integer;
                  NetMailConf    : Boolean;
                  MDesc          : String[29];
                  MSub           : String[10];
                  MEqual,
                  PublicMsgConf,
                  AllowDelete,
                  PackUnReceived : Boolean;
                  DaysOld        : Word;
                  DelOldThdMsg   : Boolean;
                  NoOfLines      : Word;
                  OneExtra       : Boolean;
                  PrivSec        : Array[1..5] Of Integer;
                  MsgEntrySec    : Word;
                  Extra          : Array[1..44] Of Byte;
                  AllowNetRoute,
                  MarkAsSent     : Boolean;
                  NetIDName      : String[15];
                End;


  MessageIdx    = Record
                   FromWhoCRC,
                   ToWhoCRC,
                   MsgNumber,
                   OrgMsgNumber   : LongInt;
  End;

(* SFMSG[X].LMR *)
  LastMessage   = Record
                   LMsgRed : LongInt;
                  End;

(* NETCONF.DEF             *)
   DefaultConference = Record
                        Default : Boolean;
                        Force   : Boolean;
                        Extra   : Array[0..9] Of Byte;
                       End;

VAR
 PointIDX   : MessageIDX;
 IDX        : File Of MessageIDX;
 Lower,
 Higher     : Longint;
 X          : Integer;
 I          : Integer;
 LM         : File Of LastMessage;
 LMR        : LastMessage;
 Conf       : Word;
 NBPage     : Word;
 NPage      : Byte;
 B          : Char;
 D          : String[15];
 C          : String[20];
 Ligne      : String[79];
 Code       : Integer;
 nomconf    : String[29];
 MsgS       : File Of MsgSystem;
 Msg        : MsgSystem;
 CodeConf   : Array[0..Register] Of Integer;
 Default    : Array[0..Register, 1..2] Of Boolean;
 Def        : File Of DefaultConference;
 Deff       : DefaultConference;
 ConfLower,
 ConfHigher : Word;


{-----------------------------------------------------------------------}
Function TestChaine(C : String) : Boolean;
Var COP : Integer;
    Bon : Boolean;
Begin;
  Bon := False;
  COP := 1;
  Repeat
   If C[COP] In ['0'..'9',' '] Then Bon := True Else Bon := False;
   Inc(COP);
  Until ( (Bon = False) Or (COP = Length(C)+1));

  If Bon = True Then TestChaine := True;
  If Bon = False Then TestChaine := False;
End;
{-----------------------------------------------------------------------}
Function Test : Boolean;
Var Alors : Boolean;

Function Pass(Conf : Integer) : Boolean;
Var Ok : Boolean;
    J     : Integer;
Begin;
 J := 0;
 Ok := False;
 Repeat
  If Conf = CodeConf[J]+1 Then Ok := True Else Inc(J);
 Until ( (Ok = True) Or (J = Register));
 Pass := Ok;
End;

Begin;
 Alors := True;
 If ( (Conf >= 1) And (Conf <= FileSize(MsgS)))
  Then Alors := True
  Else Alors := false;
 If Alors = True Then
  If Conf >= CodeConf[NPage*26]+1
   Then Alors := True
   Else Alors := false;
 If Alors = True Then
  If ( (NPage < NbPage) And (Conf <= CodeConf[NPage*26+26]))
   Then Alors := True
   Else
   If ( (NPage +1 = NbPage) And (Conf <= FileSize(MsgS)))
    Then Alors := True
    Else Alors := False;
 If Pass(Conf) = False
  Then Alors := False;
 Test := Alors;
End;
{-----------------------------------------------------------------------}
Function SFMSG(Rec : Integer) : String;
Begin;

 If Rec < 9  Then SFMSG := 'SFMSG0'+IntToStr(Rec+1)
  Else SFMSG := 'SFMSG'+IntToStr(Rec+1);
 End;
{-----------------------------------------------------------------------}
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
{-----------------------------------------------------------------------}
Function Page(NbConf : Word) : Word;
Begin;
 Page := NbConf DIV 26;
 If (NbConf/26 - NbConf DIV 26) > 0 Then Page := NbConf DIV 26 + 1;
End;
{-----------------------------------------------------------------------}
Procedure Net(RepMail : String; Lo, Hi : Word);
Begin;
      For I := Lo To Hi Do
        If User.Conf.Attribut[I] = 0 Then User.Conf.Attribut[I] := 100
         Else If USer.Conf.Attribut[I] < 100 Then User.Conf.Attribut[I] := 101;
End;
{-----------------------------------------------------------------------}
Procedure NoNet(RepMail : String; Lo, Hi : Word);
Begin;
      For I := Lo To Hi Do
       If User.Conf.Attribut[I] = 101 Then User.Conf.Attribut[I] := 1
         Else User.Conf.Attribut[I] := 0;

End;
{-----------------------------------------------------------------------}
Procedure Size(RepMail : String; Lo, Hi : Word; Valeur : LongInt; Mode : Byte);
Begin;

  If ( (Valeur > 0) And (Mode = 0)) Then Exit;

  Writeln('');
 {$IFDEF ENGLISH}
  Writeln('Resetting Pointers, Please Wait...');
 {$ELSE}
  Writeln('Repositionnement Des Pointeurs, Veuillez Attendre...');
 {$ENDIF}
  Writeln('[0|||||||||||||||||25|||||||||||||||||50|||||||||||||||||75|||||||||||||||100]');
  Write(' ');

  For I := Lo To Hi Do
   Begin;
    For X := 1 To Trunc(I/Hi*76) - Trunc((I-1)/Hi*76) Do Write('°');
     If User.Conf.Attribut[I] In [1,2,3,4,101] Then
      Begin;

       Assign(IDX, RepMail+SFMSG(I)+'.IDX');
       Reset(IDX);
       If FileSize(IDX) > 0 Then
        Begin;

         Seek(IDX, 0);
         Read(IDX, PointIDX);
         Lower := PointIDX.MsgNumber;

         Seek(IDX, FileSize(IDX)-1);
         Read(IDX, PointIDX);
         Higher := PointIDX.MsgNumber;


       {Resize Par Rapport A Un Nombre : Valeur}
        If ( (Valeur > 0) And (Mode = 1) ) Then
         Begin;
          LMR.LMsgRed  := Higher - Valeur;
          If LMR.LMsgRed  < Lower Then LMR.LMsgRed := Lower;
         End;
       {Resize Sur Le Lower}
        If ( (Valeur = 0) And (Mode = 0) ) Then
         LMR.LMsgRed := Lower;
       {Resize Sur Le Higher}
        If ( (Valeur = 0) And (Mode = 1) ) Then
         LMR.LMsgRed := Higher;

        End
       Else
         LMR.LMsgRed  := 1;

       Close(IDX);

       Assign(LM, RepMail+SFMSG(I)+'.LMR');
       Reset(LM);
       Seek(LM, User.SFNumero);
       Write(LM, LMR);
       Close(LM);
      End;
   End;
End;
{-----------------------------------------------------------------------}
Procedure All(RepMail : String; Lo, Hi : Word);
Begin;
 For I := Lo To Hi Do
    If User.Conf.Attribut[I] <  99  Then User.Conf.Attribut[I] := 1
    Else User.Conf.Attribut[I] := 101;
End;
{-----------------------------------------------------------------------}
Procedure Perso(RepMail : String; Lo, Hi : Word);
Begin;
      For I := Lo To Hi Do
        If User.Conf.Attribut[I] <  99  Then User.Conf.Attribut[I] := 3;


End;
{-----------------------------------------------------------------------}
Procedure Yall(RepMail : String; Lo, Hi : Word);
Begin;
      For I := Lo To Hi Do
          If User.Conf.Attribut[I] < 99 Then User.Conf.Attribut[I] := 2;

End;
{-----------------------------------------------------------------------}
Procedure None(RepMail : String; Lo, Hi : Word);
Begin;
      For I := Lo To Hi Do
          If User.Conf.Attribut[I] < 99 Then User.Conf.Attribut[I] := 0
          Else User.Conf.Attribut[I] := 100;

End;
{-----------------------------------------------------------------------}
Procedure Chiffre(RepMail : String; NbConf : Word);
Begin;
{SI CHIFFRE SEULEMENT}
  Begin;
   Seek(MsgS, NbConf-1);
   Read(MsgS, Msg);

    Begin;

     GotoXY(1,19); ClrEol;
     GotoXY(1,20); ClrEol;
     GotoXY(1,21); ClrEol;
     GotoXY(1,22); ClrEol;

     GotoXY(1,19);

     Assign(IDX, RepMail+SFMSG(NbConf-1)+'.IDX');
     {$I-} Reset(IDX); {$I+}

     If ( (Ioresult = 0) And (FileSize(IDX) > 0) ) Then
      Begin;
       Seek(IDX, 0);
       Read(IDX, PointIDX);
       Lower := PointIDX.MsgNumber;
      {$IFDEF ENGLISH}
       WriteLn('þ Lowest Message  : ' + IntToStr(PointIDX.MsgNumber));
      {$ELSE}
       WriteLn('þ Bas Message     : ' + IntToStr(PointIDX.MsgNumber));
      {$ENDIF}
       Seek(IDX, FileSize(IDX)-1);
       Read(IDX, PointIDX);
       Higher := PointIDX.MsgNumber;
      {$IFDEF ENGLISH}
       WriteLn('þ Highest Message : ' + IntToStr(PointIDX.MsgNumber));
      {$ELSE}
       WriteLn('þ Haut Message    : ' + IntToStr(PointIDX.MsgNumber));
      {$ENDIF}
      End
     Else
      Begin;
       PointIDX.MsgNumber := 1;
      {$IFDEF ENGLISH}
       WriteLn('þ Lowest Message  : 1');
       Writeln('þ Highest Message : 1');
      {$ELSE}
       WriteLn('þ Bas Message    : 1');
       Writeln('þ Haut Message   : 1');
      {$ENDIF}
       Higher := 1;
       Lower  := 1;
      End;
      Close(IDX);

      Assign(LM, RepMail+SFMSG(NbConf-1)+'.LMR');
      {$I-} Reset(LM); {$I+}
      If Ioresult = 0 Then
       If FileSize(LM) > 0 Then
        Begin;
         Seek(LM, User.SFNumero);
         Read(LM, LMR);
        End;
      Close(LM);
    End;

    If LMR.LMsgRed > PointIDX.MsgNumber Then LMR.LMsgRed := PointIDX.MsgNumber;
   {$IFDEF ENGLISH}
    Writeln('þ Last Message    : ' + IntToStr(LMR.LMsgRed));
   {$ELSE}
    Writeln('þ Dernier Message : ' + IntToStr(LMR.LMsgRed));
   {$ENDIF}

    GotoXY(38,19); ClrEol;

     Begin;
        Write('P)erso, A)ll, Y)ours&All, N)et or Q)none: ');
        Repeat
         B := Upcase(ReadKey);
        Until B In ['P','A','Y','N','Q',#13, #27];
        Writeln(B);
     End;


   Case B Of
    'A' : If USer.Conf.Attribut[NbConf-1] < 100  Then User.Conf.Attribut[NbConf-1] := 1
            Else User.Conf.Attribut[NbConf-1] := 101;
    'Q' : If USer.Conf.Attribut[NbConf-1] < 100  Then User.Conf.Attribut[NbConf-1] := 0
            Else User.Conf.Attribut[NbConf-1] := 100;
    'N' : Begin;
           If USer.Conf.Attribut[NbConf-1] = 0  Then User.Conf.Attribut[NbConf-1] := 100;
           If User.Conf.Attribut[NbConf-1] In [1,2,3] Then User.Conf.Attribut[NbConf-1] := 101;
           If USer.Conf.Attribut[NbConf-1] = 100  Then User.Conf.Attribut[NbConf-1] := 0;
           If User.Conf.Attribut[NbConf-1] In [1,2,3] Then User.Conf.Attribut[NbConf-1] := 1;
          End;
    'Y' : User.Conf.Attribut[NbConf-1] := 2;
    'P' : User.Conf.Attribut[NbConf-1] := 3;
    #27,
    #13 :;
   End;

   D := '';

   If B in ['N','P','A','Y'] Then
    Begin;
     GotoXY(41,21); ClrEol;
     Write('Message # : ');
     ReadLn(D);
     Val(D, LMR.LMsgRed, Code);
     Writeln(Code);
     If Code = 0 Then
      Begin;
       If LMR.LMsgRed < Lower  Then LMR.LMsgRed := Lower;
       If LMR.LMsgRed > Higher Then LMR.LMsgRed := Higher;
       Assign(LM, RepMail+SFMSG(NbConf-1)+'.LMR');
       Reset(LM);
       Seek(LM, User.SFNumero);
       Write(LM, LMR);
       Close(LM);
      End;
    End;
  End;

End;
{-----------------------------------------------------------------------}
Procedure PageDePresentation;
Begin;
  ClrScr;
  TextColor(14);
  TextBackGround(0);
 {$IFDEF ENGLISH}
  Write('                          SELECTION CONFERENCES');
  TextColor(7);
  TextBackGround(0);
  Writeln('     Page '+IntToStr(NPage+1)+' Of '+IntToStr(NbPage));
 {$ELSE}
  Write('                        SELECTION DES CONFERENCES');
  TextColor(7);
  TextBackGround(0);
  Writeln('     Page '+IntToStr(NPage+1)+' De '+IntToStr(NbPage));
 {$ENDIF}

  TextColor(11);
  TextBackGround(0);
  Writeln('');


   For I := NPage*26 To NPage*26+25 Do

    If CodeConf[I] >= 0 Then
   Begin;
    Seek(MsgS, CodeConf[I]);
    Read(MsgS, Msg);

    Msg.MDesc := Msg.MDesc;

    If I-NPage*26 < 13 Then GotoXY(3, I-NPage*26+3)
     Else GotoXY(40, I-NPage*26-10);

    Write(Caff(User.Conf.Attribut[CodeConf[I]]));

    If CodeConf[I] <  9                            Then Write('   '+IntToStr(CodeConf[I]+1));
    If CodeConf[I] >= 9  Then If CodeConf[I] < 99  Then Write('  '+IntToStr(CodeConf[I]+1));
    If CodeConf[I] >= 99 Then If CodeConf[I] < 999 Then Write(' '+IntToStr(CodeConf[I]+1));
    Write('. '+Msg.MDesc);

  End;


 Writeln('');
 TextColor(15);
 TextBackGround(0);

 GotoXY(2,17);
{$IFDEF ENGLISH}
 Write('Command, <+/->, <Q>uit : ');
{$ELSE}
 Write('Commande, <+/->, <Q>uitter : ');
{$ENDIF}


End;
{-----------------------------------------------------------------------}
{-----------------------------------------------------------------------}
{-----------------------------------------------------------------------}
{-----------------------------------------------------------------------}
 Procedure SelectConf(RecUser : Integer;
                      SFDIR,
                      RepMail,
                      BsfMailDir : String;
                      RecBSF     : Integer);



Begin;
(*Lecture De La Fiche User : SPECIAL BSFMGR *)
 Assign(USR, BsfMailDir+'BSFUSERS.DAT');
 Reset(USR);
 Seek(USR, RecBSF);
 Read(USR, USer);

(* Lecture Du Fichier Des Conferences Par Default *)
 Assign(DEF, BsfMailDir+'BSFCONF.DEF');
 {$I-} Reset(DEF); {$I+}
 If IoResult = 0 Then
  Begin;
   For I := 0 To Register Do
    Begin;
     Seek(DEF, I);
     Read(DEF, Deff);
     Default[I, 1] := Deff.Default;
     Default[I, 2] := Deff.Force;
    End;
   Close(DEF);
  End;


(* Ouverture du Fichier SFMCONF.DAT *)
 Assign(MsgS, SfDir+'SFMCONF.DAT');
 Reset(MsgS);

 (* Mise En Memoire Des Conferences Disponibles Pour Le User *)
 For I := 0 To Register Do CodeConf[I] := -1;
 X := 0;
 NbPage := 0;
 For I := 0 To FileSize(MsgS)-1 Do
  Begin;
   Seek(MsgS, I);
   Read(MsgS, Msg);
    Begin;
     CodeConf[X] := I;
     Inc(NbPage);
     Inc(X);
    End;
  End;

 NbPage := Page(NbPage);
 NPage  := 0;

(* Debut Du Traitement *)
Repeat

 PageDePresentation;

 ReadLn(C);

 Val(C, Conf, Code);

{SI CHIFFRE SEULEMENT}
 If ( (Code = 0) And (Test = True)) Then Begin;
                                          Chiffre(RepMail, Conf);
                                          C := '';
                                         End;

  {------------------ FIN DE LA PARTIE NOMBRE -------------------------}


{SI DIFFERENT D'UN NOMBRE}
 If Code <> 0 Then
  If TestChaine(C) = False Then
   Begin;
    C := Reduce(C, ' ');

 {[ALL x]}
 If MAJ(Copy(C,1,3)) = 'ALL' Then
  Begin;
   Delete(C,1,3);

 {[ALL]}
 If Length(C) = 0 Then All(Repmail, 0, FileSize(MSGS)-1);

 {[ALL PERSO]}
 If MAJ(Copy(C,1,5)) = 'PERSO' Then Begin;
                                     Delete(C, 1,5);
                                     Perso(RepMail, 0, FileSize(MSGS)-1);
                                    End;
 {[ALL YALL]}
 If MAJ(Copy(C,1,5)) = 'YALL' Then Begin;
                                    Delete(C, 1,4);
                                    Yall(RepMail, 0, FileSize(MSGS)-1);
                                   End;

 {[ALL NONE]}
 If MAJ(Copy(C,1,5)) = 'NONE' Then Begin;
                                    Delete(C, 1,4);
                                    None(RepMail, 0, FileSize(MSGS)-1);
                                   End;

 {[ALL NET]}
 If MAJ(Copy(C,1,3)) = 'NET' Then Begin;
                                    Delete(C, 1,3);
                                    Net(RepMail, 0, FileSize(MSGS)-1);
                                   End;

 {[ALL NONET]}
 If MAJ(Copy(C,1,5)) = 'NONET' Then Begin;
                                     Delete(C, 1,5);
                                     NoNet(RepMail, 0, FileSize(MSGS)-1);
                                    End;


 {[ALL SIZE y]}
 If MAJ(Copy(C,1,4)) = 'SIZE' Then
  Begin;
   Delete(C, 1, 4);
    Ligne := '';
   If Length(C) > 0 Then
    If C[1] In ['0'..'9'] Then
     While ( (C<>'') And (C[1] In ['0'..'9']) ) Do
      Begin;
       Ligne := Ligne + C[1];
       Delete(C,1,1);
      End;


 {[ALL SIZE <rien>]}

 If Length(Ligne) = 0 Then
  If MAJ(Copy(C,1,3)) <> 'LOW' Then
   If MAJ(Copy(C,1,4)) <> 'HIGH' Then
    Begin;
     Writeln('');
    {$IFDEF ENGLISH}
     WriteLn('Error');
     Writeln('Syntaxe : ALL SIZE {LOW/HIGH/Number} ');
     Delay(1500);
    {$ELSE}
     Writeln('Erreur');
     Writeln('Syntaxe : ALL SIZE {LOW/HIGH/Nombre}');
     Delay(1500);
    {$ENDIF}
   End;

 {[ALL SIZE <Nombre>]}
 If Ligne <> '' Then If StrToInt(Ligne) > 0 Then Size(RepMail, 0, FileSize(MsgS)-1, StrToInt(Ligne), 1);

 {[ALL SIZE LOW]}
 If Ligne = '' Then
 If MAJ(Copy(C,1,3)) = 'LOW' Then Begin;
                                   Delete(C,1,3);
                                   Size(RepMail, 0, FileSize(MsgS)-1, 0, 0);
                                  End;
 {[ALL SIZE HIGH]}
 If Ligne = '' Then
 If MAJ(Copy(C,1,4)) = 'HIGH' Then Begin;
                                    Delete(C,1,4);
                                    Size(RepMail, 0, FileSize(MsgS)-1, 0, 1);
                                   End;

  End;
  End;

  {------------------ FIN DE LA PARTIE [ALL X] ------------------------}

{SI SEPARATEUR (..) }
 If POS('..', C) > 0 Then Begin;

 {Recherche De La 1er Et 2nd Chaine}
   Ligne := '';
   If C[1] In ['0'..'9'] Then
    While ( (C<>'') And (C[1] In ['0'..'9']) ) Do
     Begin;
      Ligne := Ligne + C[1];
      Delete(C,1,1);
     End;

   ConfLower := StrToInt(Ligne);
   Delete(C,1,2);
   Ligne := '';

   If C[1] In ['0'..'9'] Then
     While ( (C<>'') And (C[1] In ['0'..'9']) ) Do
      Begin;
       Ligne := Ligne + C[1];
       Delete(C,1,1);
      End;

   ConfHigher := StrToInt(Ligne);

   If ConfHigher < ConfLower Then Begin;
                                   Conf := ConfLower;
                                   ConfLower  := ConfHigher;
                                   ConfHigher := Conf;
                                  End;
   If ConfLower  < 1                 Then ConfLower  := 1;
   If ConfHigher > FileSize(MsgS)-1  Then ConfHigher := FileSize(MsgS)-1;


 {[#1..#2]}
   If Length(C) = 0 Then All(RepMail, ConfLower-1, ConfHigher-1);
 {[#1..#2]}
   If MAJ(Copy(C,1,3)) = 'ALL' Then Begin;
                                     Delete(C, 1, 3);
                                     All(RepMail, ConfLower-1, ConfHigher-1);
                                    End;
 {[#1..#2 NONE]}
   If MAJ(Copy(C,1,4)) = 'NONE' Then Begin;
                                      Delete(C, 1, 4);
                                      None(RepMail, ConfLower-1, ConfHigher-1);
                                     End;

 {[#1..#2 YALL]}
   If MAJ(Copy(C,1,4)) = 'YALL' Then Begin;
                                      Delete(C, 1, 4);
                                      Yall(RepMail, ConfLower-1, ConfHigher-1);
                                     End;
 {[#1..#2 PERSO]}
   If MAJ(Copy(C,1,5)) = 'PERSO' Then Begin;
                                      Delete(C, 1, 5);
                                      Perso(RepMail, ConfLower-1, ConfHigher-1);
                                     End;
 {[ALL NET]}
 If MAJ(Copy(C,1,3)) = 'NET' Then Begin;
                                    Delete(C, 1,3);
                                    Net(RepMail,  ConfLower-1, ConfHigher-1);
                                   End;

 {[ALL NONET]}
 If MAJ(Copy(C,1,5)) = 'NONET' Then Begin;
                                     Delete(C, 1,5);
                                     NoNet(RepMail,  ConfLower-1, ConfHigher-1);
                                    End;


 {[#1..#2] SIZE x]}
   If MAJ(Copy(C,1,4)) = 'SIZE' Then
    Begin;
     Delete(C,1,4);
     Ligne := '';
     If C[1] In ['0'..'9'] Then
      While ( (C<>'') And (C[1] In ['0'..'9']) ) Do
       Begin;
        Ligne := Ligne + C[1];
        Delete(C,1,1);
       End;

 If Length(Ligne) = 0 Then
  If MAJ(Copy(C,1,3)) <> 'LOW' Then
   If MAJ(Copy(C,1,4)) <> 'HIGH' Then
    Begin;
     Writeln('');
    {$IFDEF ENGLISH}
     WriteLn('Error');
     Writeln('Syntaxe : #1..#2 SIZE {LOW/HIGH/Nunber} ');
     Delay(1500);
    {$ELSE}
     Writeln('Erreur');
     Writeln('Syntaxe : #1..#2 SIZE {LOW/HIGH/Nombre}');
     Delay(1500);
    {$ENDIF}
   End;



 {[#1..#2 SIZE <Nombre>]}
 If Ligne <> '' Then If StrToInt(Ligne) > 0 Then Size(RepMail, ConfLower-1, ConfHigher-1, StrToInt(Ligne), 1);


 {[#1..#2] SIZE LOW]}
   If Ligne = '' Then
   If MAJ(Copy(C,1,3)) = 'LOW' Then Begin;
                                     Delete(C,1,3);
                                     Size(RepMail,ConfLower-1,ConfHigher-1, 0, 0);
                                    End;

 {[#1..#2] SIZE HIGH]}
   If MAJ(Copy(C,1,4)) = 'HIGH' Then Begin;
                                      Delete(C,1,4);
                                      Size(RepMail,ConfLower-1,ConfHigher-1, 0, 1);
                                     End;


   End;
 End;


  {--------------- FIN DE LA PARTIE [ALL SIZE X] ----------------------}

 {[RESET]}

  If MAJ(Copy(C,1,5)) = 'RESET' Then Begin;
                                      Delete(C, 1, 5);
                                      None(RepMail, 0, FileSize(MSGS)-1);
                                     End;


  {--------------- FIN DE LA PARTIE [RESET] ----------------------}

 {[DEFAULT]}
  If MAJ(Copy(C,1,7)) = 'DEFAULT' Then
   Begin;
    Delete(C,1,7);
    For I := 0 To FileSize(MSGS)-1 Do
     Begin;
      If Default[I, 1] = True Then
       If User.Conf.Attribut[I] < 100 Then User.Conf.Attribut[I] := 1
        Else
      Else User.Conf.Attribut[I] := 0;
     End;
   End;
End;


  {--------------- FIN DE LA PARTIE [DEFAULT] ----------------------}
{SOUS LA FORME [#1 #2 ... #n]} {Avec n >= 2}
 If Code <> 0 Then
  If TestChaine(C) = True Then
   If Pos('..', C) = 0 Then
    Begin;
     Repeat
      Code := StrToInt(Copy(C,1,Pos(' ',C)-1));
       If ( (Code > 0) And (Code <= FileSize(MsgS)-1) ) Then
         Begin;
          Chiffre(Repmail, Code);
          Delete(C, 1, Length(Copy(C,1,Pos(' ',C))));
         End
       Else Delete(C, 1, Length(Copy(C,1,Pos(' ',C))));
     Until ( (C = '') Or (Pos(' ', C) = 0)) ;

     If Length(C) > 0 Then Chiffre(Repmail, StrToInt(C));
     C := '';

    End;
  {--------------- FIN DE LA PARTIE [#1 #2 #3 ...] ----------------------}

{CHANGEMENT DE PAGE PAR [#x] }
  If Code <> 0 Then
   If C[1] = '#' Then
    Begin;
     If Length(C) = 1 Then
      Begin;
       Writeln('');
      {$IFDEF ENGLISH}
       Write('Which Page (1 To '+IntToStr(NbPage)+') : ');
      {$ELSE}
       Write('Quelle Page (1 A '+IntToStr(NbPage)+') : ');
      {$ENDIF}
       C := '';
       ReadLn(C);
      End;
      If Length(C) > 1 Then Delete(C, 1 , 1);
      C := Reduce(C, ' ');
      Code := StrToInt(C);
      If Code In [1..NbPage] Then NPage := Code-1;
      C := '';
    End;

  {-------------------- FIN DE LA PARTIE [#x] ----------------------------}

{CHANGEMENT DE PAGE}

 {[+]} If Code <> 0 Then If C = '+' Then Inc(NPage);
 {[-]} If Code <> 0 Then If C = '-' Then If NPage > 0 Then Dec(NPage);

  {------------------ FIN DE LA PARTIE [+/-] -----------------------------}

 If NPage = NbPage Then NPage := NBPage-1;

  {-------------------- FIN DU TRAITEMENT --------------------------------}



Until MAJ(C) = 'Q';

 Seek(USR, RecBSF);
 Write(USR, USer);
 Close(USR);

End;

End.

