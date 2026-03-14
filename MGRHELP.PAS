UNIT MGRHelp;

Interface

 Procedure ConfigurationAide;


Implementation


Uses Crt,
     MGRDeflt,
     MGRVaria,
     BsfUtils;

CONST MsgFileName : String = 'BSFMAIL.HLP';

TYPE
  HelpMess = Record
              OptMan : Char;                      {Code CaractŠre Principale}
              OptSec : Char;                      {Code CaractŠre Secondaire}
              NbOfLn : Byte;                      {Nombre De Ligne}
              Entete : String[60];                {Nom de L'entˆte}
              Msg    : Array[1..15] Of String[72];{Message D'aide}
             End;

Var Hlp : File Of HelpMess;
    Hp  : HelpMess;
    Rec : ShortInt;
    C   : Char;

{--------------------------------------------------------------------------}
Procedure Visual(Rec : Word);
Var I : Integer;
    L : Byte;
Begin;

 ClrScr;

 GotoXY(30,1);
 TextColor(14);
 Write('MAINTENANCE DES AIDES');

 GotoXY(1,1);
 TextColor(3);
 Write('Aide [',Rec,' Sur ',FileSize(Hlp),']');

 TextColor(11);
 GotoXY(1,3);  Write(' þ Code Principal : '+Hp.OptMan);
 GotoXY(25,3); Write(' þ Code Secondaire : '+Hp.OptSec);
 GotoXY(49,3); Write(' þ Nombre De Lignes  : ',Hp.NbOfLn);
 GotoXY(1,5);  Write(' þ Entˆte : '+Hp.Entete);
 L := 6;

 For I := 1 To 15 Do
  Begin;
   If I < 10 Then Begin;
                   TextColor(03);
                   GotoXY(2, I+L);
                   Write('0',I,' (');
                  End
             Else
                  Begin;
                   TextColor(03);
                   GotoXY(2, I+L);
                   Write(I,' (');
                  End;
  TextColor(14);
  GotoXY(6,I+L);  Write(Hp.Msg[I]);
  TextColor(03);
  GotoXY(78,I+L); Write(')');
  TextColor(14);
 End;
End;
{--------------------------------------------------------------------------}
FUNCTION AllTrim( str : STRING ) : STRING;
BEGIN
     IF LENGTH( Str ) > 0 THEN
         AllTrim := LTrim(RTrim(str, ' '), ' ')
     ELSE
         AllTrim := Str;
END;
{--------------------------------------------------------------------------}
Function CalculNbOfLn : Byte;
Var I : Byte;
    Stop : Boolean;
Begin;
 Stop := False;
 I := 15;
 Repeat
  If Length(AllTrim(Hp.Msg[I])) <= 0 Then Dec(I)
   Else Stop := true;
 Until (Stop Or (I <= 0));
 CalculNbOfLn := I;
End;
{--------------------------------------------------------------------------}
Function InputTableau(MAJ : Boolean) : String;
CONST Inserte : Boolean = True;

Var C      : Char;
    X,Y,
    Pos    : Byte;
    Ln     : Byte;

Begin;
 CurSorOn;
 Pos := 1;
 TextColor(11);
 TextBackGround(1);
 Hp.Msg[Pos] := RTrim(Hp.Msg[Pos], ' ');
 X := 6;
 Y := 6;

 TextColor(11);

 TextBackGround(0);
 GotoXY(2,23); Write('ALT-C : Nettoie Ligne / ALT-I : Insert Ligne / ALT-D : Efface Ligne');
 GotoXY(2,24); Write('ENTER : Sauve         / ESC   : Annule');

 TextBackGround(1);
 GotoXY(6, 6+Pos);
 Write(Hp.Msg[Pos]+Rep(' ', (72-Length(Hp.Msg[Pos]))));
 GotoXY(6, 6+Pos);
 Repeat

  TextColor(11);
  TextBackGround(0);

  GotoXY(72,3); Write('  ');
  GotoXY(72,3); Write(CalculNbOfLn);
  Hp.NbOfln := CalculNbOfLn;

  If Inserte Then Begin;
                   GotoXY(70, 1);
                   Write('[INS]');
                  End
             Else Begin;
                   GotoXY(70, 1);
                   Write('     ');
                  End;

  TextColor(11);
  TextBackGround(1);
  GotoXY(X,6+Pos);

  C := ReadKey;
  If MAJ Then C := Upcase(C);
  Case C Of


   #0  : Begin;
          C := ReadKey;
          Case C Of
           #46 : Begin;                         {Efface La Ligne : ALT C}
                  Hp.Msg[Pos] := '';
                  GotoXY(6, 6+Pos);
                  Write(Hp.Msg[Pos]+Rep(' ', (72-Length(Hp.Msg[Pos]))));
                 End;

           #23 : If Hp.NbOfLn In [0..14] Then  {Insertion D'une Ligne : ALT I}
                 Begin;
                  For Ln := 14 DownTo Pos Do Hp.Msg[Ln+1] := Hp.Msg[Ln];
                  Hp.Msg[Pos] := '';
                  TextBackGround(0);
                  TextColor(14);
                  For Ln := 1 To 15 Do Begin;
                                        GotoXY(6,6+Ln);
                                        Write(Hp.Msg[Ln]+Rep(' ', 72-Length(Hp.Msg[Ln])));
                                       End;
                  TextBackGround(1);
                  TextColor(11);
                  GotoXY(6, 6+Pos);
                  Write(Hp.Msg[Pos]+Rep(' ', (72-Length(Hp.Msg[Pos]))));
                 End;

           #32 : Begin;                         {Effacement d'une Ligne : ALT D}
                  For Ln := Pos To 14 Do Hp.Msg[Ln] := Hp.Msg[Ln+1];
                  Hp.Msg[15] := '';
                  TextBackGround(0);
                  TextColor(14);
                  For Ln := 1 To 15 Do Begin;
                                        GotoXY(6,6+Ln);
                                        Write(Hp.Msg[Ln]+Rep(' ', 72-Length(Hp.Msg[Ln])));
                                       End;
                  TextBackGround(1);
                  TextColor(11);
                  GotoXY(6, 6+Pos);
                  Write(Hp.Msg[Pos]+Rep(' ', (72-Length(Hp.Msg[Pos]))));
                 End;

           #77 : Begin;                         {FlŠche Droite}
                  Inc(X);
                  If X > 77 Then Dec(X);
                 End;
           #75 : Begin;                         {FlŠche Gauche}
                  Dec(X);
                  If X < 6 Then X := 6;
                 End;
           #72 : Begin;                         {FlŠche Haut}
                  TextColor(14);
                  TextBackGround(0);
                  GotoXY(6, 6+Pos);
                  Write(Hp.Msg[Pos]+Rep(' ', (72-Length(Hp.Msg[Pos]))));
                  Dec(Pos);
                  If Pos < 1  Then Pos := 1;
                  Hp.Msg[Pos] := RTrim(Hp.Msg[Pos], ' ');
                  TextColor(11);
                  TextBackGround(1);
                  GotoXY(6, 6+Pos);
                  Write(Hp.Msg[Pos]+Rep(' ', (72-Length(Hp.Msg[Pos]))));
                 End;
           #80 : Begin;                         {FlŠche Bas}
                  TextColor(14);
                  TextBackGround(0);
                  GotoXY(6, 6+Pos);
                  Write(Hp.Msg[Pos]+Rep(' ', (72-Length(Hp.Msg[Pos]))));
                  Inc(Pos);
                  If Pos > 15 Then Pos := 15;
                  Hp.Msg[Pos] := RTrim(Hp.Msg[Pos], ' ');
                  TextColor(11);
                  TextBackGround(1);
                  GotoXY(6, 6+Pos);
                  Write(Hp.Msg[Pos]+Rep(' ', (72-Length(Hp.Msg[Pos]))));
                 End;
           #71 : X := 6;                       {FlŠche Home}
           #79 : Begin;                         {FlŠche Fin}
                  If Length(Hp.Msg[Pos]) < 72 Then X := 6+Length(Hp.Msg[Pos])
                   Else X := 6+Length(Hp.Msg[Pos])-1;
                 End;
           #73 : Begin;                          {FlŠche PgUp}
                  TextColor(14);
                  TextBackGround(0);
                  GotoXY(6, 6+Pos);
                  Write(Hp.Msg[Pos]+Rep(' ', (72-Length(Hp.Msg[Pos]))));
                  Pos := 1;
                  Hp.Msg[Pos] := RTrim(Hp.Msg[Pos], ' ');
                  TextColor(11);
                  TextBackGround(1);
                  GotoXY(6, 6+Pos);
                  Write(Hp.Msg[Pos]+Rep(' ', (72-Length(Hp.Msg[Pos]))));
                 End;
           #81 : Begin;                           {FlŠche PgDown}
                  TextColor(14);
                  TextBackGround(0);
                  GotoXY(6, 6+Pos);
                  Write(Hp.Msg[Pos]+Rep(' ', (72-Length(Hp.Msg[Pos]))));
                  Pos := 15;
                  Hp.Msg[Pos] := RTrim(Hp.Msg[Pos], ' ');
                  TextColor(11);
                  TextBackGround(1);
                  GotoXY(6, 6+Pos);
                  Write(Hp.Msg[Pos]+Rep(' ', (72-Length(Hp.Msg[Pos]))));
                 End;
           #83 :  Begin;                        {Supprime}
                   X := WhereX;
                   Y := WhereY;
                   If Length(Hp.Msg[Pos]) > 0 Then Delete(Hp.Msg[Pos], X-5, 1);
                   GotoXY(6,6+Pos); Write(Hp.Msg[Pos]+Rep(' ', (72-Length(Hp.Msg[Pos]))));
                  End;
           #82 : Inserte := Not Inserte;          {Insert}
          End;
         End;
   #08 : Begin;                                 {Delete}
          X := WhereX;
          Y := WhereY;
          If Length(Hp.Msg[Pos]) > 0 Then Delete(Hp.Msg[Pos], X-6, 1);
          GotoXY(6,6+Pos); Write(Hp.Msg[Pos]+Rep(' ', (72-Length(Hp.Msg[Pos]))));
          Dec(X);
          If X < 6 Then X := 6;
         End;
   #32..#255 : Begin;
                If Not Inserte Then
                   If X in [6..77]
                   Then
                    Begin;
                     If X-5 In [0..Length(Hp.Msg[Pos])]
                     Then Hp.Msg[Pos][X-5] := C
                     Else
                      If Length(Hp.Msg[Pos]) = 0
                      Then
                       If X > 6
                       Then Hp.Msg[Pos] := Rep(' ', X-5)+C
                       Else Hp.Msg[Pos] := C
                      Else Hp.Msg[Pos] := Hp.Msg[Pos] + Rep(' ',X - Length(Hp.Msg[Pos])-6) + C;
                     Write(c);
                     Inc(X);
                     If X > 77 Then Dec(X);
                    End
                   Else
                   Else
                    Begin;
                     If X In [0..Length(Hp.Msg[Pos])-1]
                     Then
                      If Length(Hp.Msg[Pos]) > 0
                      Then Insert(C, Hp.Msg[Pos], X-5)
                      Else Hp.Msg[Pos] := C
                     Else Hp.Msg[Pos] := Hp.Msg[Pos] + Rep(' ',X - Length(Hp.Msg[Pos])-6) + C;
                     GotoXY(6,6+Pos);
                     Write(Hp.Msg[Pos]+Rep(' ', (72-Length(Hp.Msg[Pos]))));
                     Inc(X);
                     If X > 77 Then Dec(X);
                   End;
               End;
  End;

 If X-6 > Length(Hp.Msg[Pos]) Then X := Length(Hp.Msg[Pos])+6;

 Until C In [#27, #13];

 If C = #13 Then Begin;
                  Seek(Hlp, Rec);
                  Write(Hlp, Hp);
                 End;
 TextColor(15);
 TextBackGround(0);
End;
{--------------------------------------------------------------------------}
Procedure AjouteEnregistrement;
Begin;
 FillChar(Hp, SizeOf(Hp), #00);
 Seek(Hlp, FileSize(Hlp));
 Write(Hlp, Hp);
 Rec := FileSize(Hlp)-1;


End;
{--------------------------------------------------------------------------}
{--------------------------------------------------------------------------}
Procedure ConfigurationAide;
Begin;

 If Not LoadConfiguration(Config) Then Exit;

 CurSorOff;
 TextBackGround(0);
 Textcolor(11);
 ClrScr;

 Assign(Hlp,Config.BSFMailDir+MsgFileName);
 {$I-} Reset(Hlp); {$I+}
 If IoResult <> 0 Then Begin;
                        ReWrite(Hlp);
                        Seek(Hlp, 0);
                        Write(Hlp, Hp);
                       End;
 Rec := 0;
 Repeat

  Repeat
   Seek(Hlp, Rec);
   Read(Hlp, Hp);
   Visual(Rec+1);
   TextColor(11);
   GotoXY(2,23); Write('[+/-], E)dit, A)joute, D)Efface :');
   C := Upcase(ReadKey);
  Until C In ['+', '-', 'E', 'A', 'D', #13, #27];

  Case C Of
    #13,
    '+' : Inc(Rec);
    '-' : Dec(Rec);
    'A' : AjouteEnregistrement;
{   'D' : EffaceEnregistrement;}
    'E' : InputTableau(False);
  End;

  If Rec < 0               Then Rec := FileSize(Hlp)-1;
  If Rec > FileSize(Hlp)-1 Then Rec := 0;

 Until C = #27;

 Close(Hlp);

End;

END.