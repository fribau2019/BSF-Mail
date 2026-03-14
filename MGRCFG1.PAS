UNIT MGRCFG1;

{$I E:\SOURCE~1\PASCAL\NETMAIL\LANGAGE.DIR}

Interface

 Procedure DoorConfigue(Name : String);

Implementation

Uses Dos,
     Crt,
     BSFUtils,
     MGRMenu;

VAR Rec : Byte;
    Chaine  : String;
    C       : Char;
    Cfg     : Text;
    Modif   : Boolean;
    Config  : Array[1..14] Of String[80];
    XY      : Byte;

{-------------------------------------------------------------------------}
Procedure DoorConfigue(Name : String);

 Const XPos : Array[1..14] Of Byte = (18,18,18,18,18,18,18,18,26,26,26,26,43,43);
       YPos : Array[1..14] Of Byte = (03,04,05,06,08,09,10,11,13,14,15,16,18,19);
       Cpos : Array[1..14] Of Byte = (02,03,04,05,13,01,06,14,07,08,09,12,10,11);

Begin;

{Lecture NETMAIL.CFG [Fichier Texte]}
 Assign(CFG, Name);
 {$I-} Reset(CFG); {$I+}
 If Ioresult = 0 Then
  Begin;
   For Rec := 1 To 14 Do ReadLn(CFG, Config[Rec]);
   Close(CFG);
  End;

 Modif := False;
 CurSorOff;
 XY := 1;

 TextBackGround(0); ClrScr;
 GotoXY(1,1); TextColor(14); TextBackGround(1); ClrEol;
{$IFDEF ENGLISH}
 WriteCenter('CONFIGURATION EDITOR : '+Name,1);
{$ELSE}
 WriteCenter('EDITEUR DE CONFIGURATION : '+Name,1);
{$ENDIF}
 TextColor(15); TextBackGround(0);

 For Rec := 1 To 14 Do WriteXY(1,ChoixCFG[Rec].Y+2,' '+ChoixCFG[Rec].Name+Config[Rec]);

Repeat

 GotoXY(Xpos[XY], Ypos[XY]);
 TextColor(15); TextBackGround(3);
 If Length(Config[Cpos[XY]]) > 0 Then Write(Config[Cpos[XY]])
                                {$IFDEF ENGLISH}
                                 Else Write('* Empty *');
                                {$ELSE}
                                 Else Write('* Vide *');
                                {$ENDIF}

 Repeat
  C := Upcase(ReadKey);
 Until C In ['Q', #27, #72, #80, #13];

 GotoXY(Xpos[XY], Ypos[XY]);
 TextColor(11); TextBackGround(0);
 If Length(Config[Cpos[XY]]) > 0 Then Write(Config[Cpos[XY]])
                                {$IFDEF ENGLISH}
                                 Else Write('         ');
                                {$ELSE}
                                 Else Write('        ');
                                {$ENDIF}


 Case C Of
   #80 : Inc(XY);
   #72 : Dec(XY);
   #13 : Begin;
          CursorOn;
          GotoXY(Xpos[XY], Ypos[XY]);
          If XY in [1..12] Then Chaine := GetString(ChoixCFG[Cpos[XY]].Len, Config[Cpos[XY]], '±');
          If XY in [2,5..12] Then Chaine := MAJ(Chaine);
          If XY in [13..14] Then If Config[Cpos[XY]] = 'N' Then Config[Cpos[XY]] := 'Y' Else Config[Cpos[XY]] := 'N';
          If XY in [1..4,12] Then
           If Chaine <> '' Then Config[Cpos[XY]] := Chaine;
          If XY in [4..8] Then
           Begin;
            If Length(Chaine) > 0 Then
             If Copy(Chaine,Length(Chaine),1) = '\' Then Else Chaine := Chaine + '\';
            If CheckDir(Chaine) Then Config[Cpos[XY]] := Chaine;
           End;
          If XY in [9..11] Then
           If FileExists(Chaine) Then Config[Cpos[XY]] := Chaine;
          GotoXY(Xpos[XY], Ypos[XY]);
          Write(' ': ChoixCFG[Cpos[XY]].Len);
          Modif := True;
          CursorOff;
         End;
 End;

 If XY > 14 Then XY := 14;
 If XY < 01 Then XY := 01;

Until C in ['Q', #27];

 If Modif Then
  Begin;
   TextColor(11);
   TextBackGround(0);
   GotoXY(20, (Hi(WindMax) Div 2) - 2); Write('±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±');
   GotoXY(20, (Hi(WindMax) Div 2) - 1); Write('±                                    ±');
   GotoXY(20, (Hi(WindMax) Div 2)    ); Write('± Sauvez Les Modifications (O/n):    ±');
   GotoXY(20, (Hi(WindMax) Div 2) + 1); Write('±                                    ±');
   GotoXY(20, (Hi(WindMax) Div 2) + 2); Write('±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±');
   GotoXY(54, Hi(WindMax) Div 2);
   Repeat
    C := Upcase(ReadKey);
   Until C in ['O', 'Y', 'N', #27, #13];
   Case C Of
    #13,
    'O',
    'Y' : Begin;
           Assign(CFG, Name);
           {$I-} Reset(CFG); {$I+}
           If Ioresult <> 0 Then ReWrite(CFG);
           Rewrite(CFG);
           For Rec := 1 To 14 Do Writeln(CFG, Config[Rec]);
           Close(CFG);
          End;
   End;
  End;
End;
END.