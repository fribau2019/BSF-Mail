UNIT MGRCompr;

{$I LANGAGE.DIR}

Interface

 Procedure EditCompression;

Implementation

 Uses CRT,
      BSFUtils,
      MGRDeflt,
      MGRVaria;

Var Rec         : Word;
    Compression : File Of ConfigurationCompression;
    Compres     : Array[1..10] Of ConfigurationCompression;
    Chaine      : String[61];
    Xpos,
    YPos,
    Ypos1       : Byte;
    C           : Char;
    Modif       : Boolean;

{-------------------------------------------------------------------------}
Function Remplie(S : String; B : Byte) : String;
Begin;
 If Length(S) = B Then
   Remplie := S
 Else
 If Length(S) < B Then
  Repeat
   S := S + ' ';
  Until Length(S) >= B
 Else
  Begin;
   Delete(S, B-2, 60);
   S := S +'...';
  End;

 Remplie := S;
End;
{-------------------------------------------------------------------------}
Procedure Cadre;
Var I : Byte;
Begin;
 TextColor(15); TextBackGround(0); ClrScr;
 I := Hi(WindMax);

 ClrScr;
 Window(1,1,80,2);
 TextBackGround(1); Textcolor(15);
 ClrScr;
 GotoXY(1,1);
{$IFDEF ENGLISH}
 Writeln(' [Num] [Letter] [Format] [Compression...........] [Decompression...........]');
{$ELSE}
 Writeln(' [Num] [Lettre] [Format] [Compression...........] [Decompression...........]');
{$ENDIF}
 Write(' ==============================================================================');

 Window(4,4,80,I);
 TextBackGround(0); Textcolor(11); ClrScr;

{Affichage Des Protocoles List‚s}
 For Rec := 1 To 10 Do
  Begin;
   GotoXY(1,Rec);
   Write(Rec:2,'      ',Compres[Rec].Lettre,'      ',Remplie(Compres[Rec].Name,03),
    '     ',Remplie(Compres[Rec].Compression,22),'   ',Remplie(Compres[Rec].Decompression,22));
  End;
End;
{-------------------------------------------------------------------------}
Procedure EditCompression;

 Const X : Array[1..4] Of Byte = (31,31,23,23);

Begin;

 If LoadConfiguration(Config) = False Then Exit;

 Assign(Compression,  Config.BSFMailDir+'BSFCOMP.DAT');
 {$I-} Reset(Compression); {$I+}
 If IoResult <> 0 Then
  Begin;
   Rewrite(Compression);
   For Rec := 1 To 10 Do
    Begin;
     Seek(Compression, Rec-1);
     FillChar(Compres[Rec].Lettre       , 01 , ' ');
     FillChar(Compres[Rec].Name         , 03 , ' ');
     FillChar(Compres[Rec].Compression  , 60 , ' ');
     FillChar(Compres[Rec].Decompression, 60 , ' ');
     Write(Compression, Compres[Rec]);
    End;
  End
 Else
  For Rec := 1 To 10 Do
   Begin;
    Seek(Compression, Rec-1);
    Read(Compression, Compres[Rec]);
   End;
 Close(Compression);

 Cadre;

 YPos  := 1;
 XPos  := 1;
 Modif := False;

Repeat

   TextColor(15); TextBackGround(3);
   GotoXY(Xpos, Ypos);
   Write(YPos:2,'      ',Compres[YPos].Lettre,'      ',Remplie(Compres[YPos].Name,03),
    '     ',Remplie(Compres[YPos].Compression,22),'   ',Remplie(Compres[YPos].Decompression,22));

   Repeat
    C := Upcase(ReadKey);
   Until C In ['Q', #27, #72, #80, #13];

  Case C Of

   #80 : Begin;                                 {Fleche Bas}
          TextColor(11); TextBackGround(0);
          GotoXY(1, Ypos);
          Write(YPos:2,'      ',Compres[YPos].Lettre,'      ',Remplie(Compres[YPos].Name,03),
          '     ',Remplie(Compres[YPos].Compression,22),'   ',Remplie(Compres[YPos].Decompression,22));
          Inc(YPos);
         End;
   #72 : Begin;                                 {Fleche Haut}
          TextColor(11); TextBackGround(0);
          GotoXY(1, Ypos);
          Write(YPos:2,'      ',Compres[YPos].Lettre,'      ',Remplie(Compres[YPos].Name,03),
          '     ',Remplie(Compres[YPos].Compression,22),'   ',Remplie(Compres[YPos].Decompression,22));
          Dec(YPos);
         End;
   #13 : Begin;
          TextBackGround(0);
          C := ' ';
          GotoXY(5, (Hi(WindMax) Div 2)-5); Write('±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±');
          GotoXY(5, (Hi(WindMax) Div 2)-4); Write('±                                                                 ±');
          GotoXY(5, (Hi(WindMax) Div 2)-3); Write('± Lettre Du Compacteur  :                                         ±');
          GotoXY(5, (Hi(WindMax) Div 2)-2); Write('± Format De Compression :                                         ±');
          GotoXY(5, (Hi(WindMax) Div 2)-1); Write('± Compression   :                                                 ±');
          GotoXY(5, (Hi(WindMax) Div 2)  ); Write('± Decompression :                                                 ±');
          GotoXY(5, (Hi(WindMax) Div 2)+1); Write('±                                                                 ±');
          GotoXY(5, (Hi(WindMax) Div 2)+2); Write('±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±');
          GotoXY(31, (Hi(WindMax) Div 2)-3); Write(Compres[Ypos].Lettre);
          GotoXY(31, (Hi(WindMax) Div 2)-2); Write(Compres[Ypos].Name);
          GotoXY(23, (Hi(WindMax) Div 2)-1); Write(Compres[Ypos].Compression);
          GotoXY(23, (Hi(WindMax) Div 2)  ); Write(Compres[Ypos].Decompression);

          YPos1 := 1;

          Repeat

          TextColor(15); TextBackGround(3);
          GotoXY(X[YPos1], (Hi(WindMax) Div 2)-4+YPos1);
          If YPos1 = 1 Then Write(Compres[Ypos].Lettre);
          If YPos1 = 2 Then If Compres[Ypos].Name <> ''          Then Write(Compres[Ypos].Name)
                                                                 Else Write('              ');
          If YPos1 = 3 Then If Compres[Ypos].Compression <> ''   Then Write(Compres[Ypos].Compression)
                                                                 Else Write('              ');
          If YPos1 = 4 Then If Compres[Ypos].Decompression <> '' Then Write(Compres[Ypos].Decompression)
                                                                 Else Write('              ');
          Repeat
           C := Upcase(ReadKey);
          Until C In ['Q', #27, #72, #80, #13];

          TextColor(11); TextBackGround(0);
          GotoXY(X[YPos1], (Hi(WindMax) Div 2)-4+YPos1);

          If YPos1 = 1 Then Write(Compres[Ypos].Lettre);
          If YPos1 = 2 Then If Compres[Ypos].Name <> ''          Then Write(Compres[Ypos].Name)
                                                                 Else Write('              ');
          If YPos1 = 3 Then If Compres[Ypos].Compression <> ''   Then Write(Compres[Ypos].Compression)
                                                                 Else Write('              ');
          If YPos1 = 4 Then If Compres[Ypos].Decompression <> '' Then Write(Compres[Ypos].Decompression)
                                                                 Else Write('              ');


          Case C Of
           #80 : Inc(YPos1);
           #72 : Dec(YPos1);
           #13 : Begin;
                  CurSorOn;
                  GotoXY(X[YPos1], (Hi(WindMax) Div 2)-4+YPos1);
                  If YPos1 = 1 Then Compres[Ypos].Lettre  := MAJ(GetString(1, Compres[YPos].Lettre, '±'));
                  If YPos1 = 2 Then Compres[Ypos].Name    := GetString(03, Compres[YPos].Name, '±');
                  If YPos1 = 3 Then Compres[Ypos].Compression    := GetString(47, Compres[YPos].Compression, '±');
                  If YPos1 = 4 Then Compres[Ypos].Decompression  := GetString(47, Compres[YPos].Decompression, '±');
                  CursorOff;
                  Modif := True;
                 End;
          End;

          If YPos1 < 1 Then YPos1 := 1;
          If YPos1 > 4 Then YPos1 := 4;

          Until  C in ['Q', #27];

          C := ' ';
          Cadre;
         End;

  End;

  If YPos < 1  Then YPos := 1;
  If YPos > 10 Then YPos := 10;


Until C In ['Q', #27];

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
           Assign(Compression,  Config.BSFMailDir+'BSFCOMP.DAT');
           Reset(Compression);
           For Rec := 1 To 10 Do
            Begin;
             Seek(Compression, Rec-1);
             Write(Compression, Compres[Rec]);
            End;
           Close(Compression);
          End;
   End;
  End;
End;
END.
