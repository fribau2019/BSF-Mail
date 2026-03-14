UNIT MGRCFG;

{$I E:\SOURCE~1\PASCAL\NETMAIL\LANGAGE.DIR}

Interface

 Procedure DoorConfig;

Implementation

Uses Dos,
     Crt,
     BSFUtils,
     MGRCFG1,
     MGRMenu,
     MGRVaria;

{$IFDEF ENGLISH}
 Const XBarre : Array[1..4] Of String = ( ' Edit Config File ',
                                          ' Create New Config ',
                                          ' Delete Config ',
                                          ' Quit ');
{$ELSE}
 Const XBarre : Array[1..4] Of String = ( '  Editer Un CFG   ',
                                          ' Cr‚er Nouveau CFG ',
                                          '  Effacer CFG  ',
                                          ' Quit ');
{$ENDIF}
       Xpos : Array[1..4] Of Byte = (4,26,49,68);


VAR MENU    : ARRAY [1..24] Of String[12];
    Chaine  : String[12];
    DirInfo : SearchRec;
    Max     : Byte;
    C       : Char;
    X,
    Y       : Byte;
    CFG     : File;


{-------------------------------------------------------------------------}
Procedure AfficheCFG(Max : Byte);
Var I : Byte;
Begin;
 WriteCenter('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿',5);
 If Max > 0 Then
  For I := 1 To Max Do
   Begin;
    WriteCenter('³                 ³', 5+I);
    TextColor(11);
    WriteCenter(Menu[I], 5+I);
    TextColor(15);
   End;
 WriteCenter('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ',6+Max);
End;
{-------------------------------------------------------------------------}
Procedure CadreCFG;
Begin;
 CursorOff;
 TextBackGround(0); TextColor(14); ClrScr;
{$IFDEF ENGLISH}
 WriteCenter('þþþ CONFIGURATION EDITOR þþþ',1);
{$ELSE}
 WriteCenter('þþþ EDITEUR DE CONFIGURATION þþþ',1);
{$ENDIF}
 TextColor(11);

{Recherche Les CFG De BSFMAIL}
  FindFirst('*.CFG', Archive, DirInfo);
  Max := 1;
  While ( (DosError = 0) Or (Max >=24) ) do
  begin
    Menu[Max] := DirInfo.Name;
    FindNext(DirInfo);
    Inc(Max);
  End;
  Dec(Max);

{Affiche Le Menu En Bas De L'Ecran}
 TextColor(11);
 GotoXY(1,Hi(WindMax)-3);
 Writeln('  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  ÚÄÄÄÄÄÄ¿');
 Writeln('  ³',XBarre[1],'³  ³',XBarre[2],'³  ³',XBarre[3],'³  ³',XBarre[4],'³');
 Writeln('  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  ÀÄÄÄÄÄÄÙ');

{Affiche Les CFG dans un Cadre}
 AfficheCFG(Max);
 X := 1; Y := 1;

End;
{-------------------------------------------------------------------------}
Procedure DoorConfig;

Begin;

 CadreCFG;

 Repeat

  {Inverse Barre CFG}
   TextColor(15); TextBackGround(3);
   If Max > 0 Then
   WriteCenter(OrdonneCenter(Menu[Y], 17), Y+5);

  {Inverse Barre Commande}
   TextColor(15); TextBackGround(3);
   GotoXY(Xpos[X], Hi(WindMax)-2);
   Write(XBarre[X]);

  Repeat
   C := Upcase(ReadKey);
  Until C In ['Q', #27, #72, #80, #75, #77, #13];

  Case C Of
   #77 : Begin;                                 {Fleche Droite}
          TextColor(11); TextBackGround(0);
          GotoXY(Xpos[X], Hi(WindMax)-2);
          Write(XBarre[X]);
          Inc(X);
         End;
   #75 : Begin;                                 {Fleche Gauche}
          TextColor(11); TextBackGround(0);
          GotoXY(Xpos[X], Hi(WindMax)-2);
          Write(XBarre[X]);
          Dec(X);
         End;
   #80 : Begin;                                 {Fleche Bas}
          TextColor(11); TextBackGround(0);
          If Max > 0 Then
           WriteCenter(OrdonneCenter(Menu[Y], 17), Y+5);
          Inc(Y);
         End;
   #72 : Begin;                                 {Fleche Haut}
          TextColor(11); TextBackGround(0);
          If Max > 0 Then
           WriteCenter(OrdonneCenter(Menu[Y], 17), Y+5);
          Dec(Y);
         End;
   #13 : Case X Of
          1 : If Max > 0 Then Begin;
                               DoorConfigue(Menu[Y]);
                               CadreCFG;
                              End;
          2 : Begin;
               CursorOn;
               TextColor(11); TextBackGround(0);
               GotoXY(15, (Hi(WindMax) Div 2) - 2); Write('±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±');
               GotoXY(15, (Hi(WindMax) Div 2) - 1); Write('±                                                     ±');
               GotoXY(15, (Hi(WindMax) Div 2)    ); Write('± Veuillez Entrer Un Nom De Config (.CFG) :           ±');
               GotoXY(15, (Hi(WindMax) Div 2) + 1); Write('±                                                     ±');
               GotoXY(15, (Hi(WindMax) Div 2) + 2); Write('±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±');
               GotoXY(59, Hi(WindMax) Div 2);
               Chaine := GetString(8, '', '±');
               If Chaine <> '' Then DoorConfigue(Chaine+'.CFG');
               CadreCFG;
              End;
          3 : If Max >=1 Then
              Begin;
               CursorOn;
               TextColor(11); TextBackGround(0);
               Chaine := Menu[Y] + '             ';
               GotoXY(15, (Hi(WindMax) Div 2) - 2); Write('±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±');
               GotoXY(15, (Hi(WindMax) Div 2) - 1); Write('±                                             ±');
               GotoXY(15, (Hi(WindMax) Div 2)    ); Write('± Effacez Le Fichier ',Chaine,' - (o/N) :   ±');
               GotoXY(15, (Hi(WindMax) Div 2) + 1); Write('±                                             ±');
               GotoXY(15, (Hi(WindMax) Div 2) + 2); Write('±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±');
               GotoXY(59, Hi(WindMax) Div 2);
               Repeat
                C := Upcase(ReadKey);
               Until C in ['O', 'Y', 'N', #13, #27];
               Case C Of
                'O',
                'Y' : Begin;
                       Assign(CFG, Menu[Y]);
                       Erase(CFG);
                      End;
               End;
               C := ' ';
               CadreCFG;
              End;

          4 : C := #27;
         End;
  End;

   If X > 4    Then X := 1;
   If X < 1    Then X := 4;
   If Y > Max  Then Y := 1;
   If Y < 1    Then Y := Max;
   If Max = 0  Then Y := 1;

 Until C in ['Q', #27];
End;

END.