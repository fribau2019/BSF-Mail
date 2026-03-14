UNIT MGRProto;

{$I LANGAGE.DIR}

Interface

 Procedure EditProtocole;

Implementation

 Uses CRT,
      BSFUtils,
      MGRDeflt,
      MGRVaria;

Var Rec        : Word;
    ProtoCol   : File Of ConfigurationProtocoles;
    Proto      : Array[1..10] Of ConfigurationProtocoles;
    Chaine     : String[61];
    Xpos,
    YPos,
    Ypos1      : Byte;
    C          : Char;
    Modif      : Boolean;

{-------------------------------------------------------------------------}
Function Remplie(S : String; B : Byte) : String;
Begin;
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
 Writeln(' [Num] [Letter] [Protocol Name......................................] [Dl] [Up]');
{$ELSE}
 Writeln(' [Num] [Lettre] [Nom Du Protocol.....] [Download........] [Upload..........]');
{$ENDIF}
 Write(' ==============================================================================');

 Window(4,4,80,I);
 TextBackGround(0); Textcolor(11); ClrScr;

{Affichage Des Protocoles List‚s}
 For Rec := 1 To 10 Do
  Begin;
   GotoXY(1,Rec);
   Write(Rec:2,'      ',Proto[Rec].Lettre,'     ',Remplie(Proto[Rec].Name,20),
    '   ',Remplie(Proto[Rec].Send,16),'   ',Remplie(Proto[Rec].Receive,16));
  End;

End;
{-------------------------------------------------------------------------}
Procedure EditProtocole;

 Const X : Array[1..4] Of Byte = (28,25,18,18);

Begin;

 If LoadConfiguration(Config) = False Then Exit;

 Assign(Protocol,  Config.BSFMailDir+'BSFPROTO.DAT');
 {$I-} Reset(Protocol); {$I+}
 If IoResult <> 0 Then
  Begin;
   Rewrite(Protocol);
   For Rec := 1 To 10 Do
    Begin;
     Seek(Protocol, Rec-1);
     FillChar(Proto[Rec].Lettre , 01 , ' ');
     FillChar(Proto[Rec].Name   , 21 , ' ');
     FillChar(Proto[Rec].Send   , 61 , ' ');
     FillChar(Proto[Rec].Receive, 61 , ' ');
     Write(Protocol, Proto[Rec]);
    End;
  End
 Else
  For Rec := 1 To 10 Do
   Begin;
    Seek(Protocol, Rec-1);
    Read(Protocol, Proto[Rec]);
   End;
 Close(Protocol);

 Cadre;

 YPos  := 1;
 XPos  := 1;
 Modif := False;

Repeat

   TextColor(15); TextBackGround(3);
   GotoXY(Xpos, Ypos);
   Write(Ypos:2,'      ',Proto[Ypos].Lettre,'     ',Remplie(Proto[Ypos].Name,20),
    '   ',Remplie(Proto[Ypos].Send,16),'   ',Remplie(Proto[Ypos].Receive,16));

   Repeat
    C := Upcase(ReadKey);
   Until C In ['Q', #27, #72, #80, #13];

  Case C Of

   #80 : Begin;                                 {Fleche Bas}
          TextColor(11); TextBackGround(0);
          GotoXY(1, Ypos);
          Write(Ypos:2,'      ',Proto[Ypos].Lettre,'     ',Remplie(Proto[Ypos].Name,20),
          '   ',Remplie(Proto[Ypos].Send,16),'   ',Remplie(Proto[Ypos].Receive,16));
          Inc(YPos);
         End;
   #72 : Begin;                                 {Fleche Haut}
          TextColor(11); TextBackGround(0);
          GotoXY(1, Ypos);
          Write(Ypos:2,'      ',Proto[Ypos].Lettre,'     ',Remplie(Proto[Ypos].Name,20),
          '   ',Remplie(Proto[Ypos].Send,16),'   ',Remplie(Proto[Ypos].Receive,16));
          Dec(YPos);
         End;
   #13 : Begin;
          TextBackGround(0);
          C := ' ';
          GotoXY(5, (Hi(WindMax) Div 2)-5); Write('±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±');
          GotoXY(5, (Hi(WindMax) Div 2)-4); Write('±                                                                 ±');
          GotoXY(5, (Hi(WindMax) Div 2)-3); Write('± Lettre Du Protocol :                                            ±');
          GotoXY(5, (Hi(WindMax) Div 2)-2); Write('± Nom Du Protocol :                                               ±');
          GotoXY(5, (Hi(WindMax) Div 2)-1); Write('± Download :                                                      ±');
          GotoXY(5, (Hi(WindMax) Div 2)  ); Write('± Upload   :                                                      ±');
          GotoXY(5, (Hi(WindMax) Div 2)+1); Write('±                                                                 ±');
          GotoXY(5, (Hi(WindMax) Div 2)+2); Write('±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±');
          GotoXY(28, (Hi(WindMax) Div 2)-3); Write(Proto[Ypos].Lettre);
          GotoXY(25, (Hi(WindMax) Div 2)-2); Write(Proto[Ypos].Name);
          GotoXY(18, (Hi(WindMax) Div 2)-1); Write(Proto[Ypos].Send);
          GotoXY(18, (Hi(WindMax) Div 2)  ); Write(Proto[Ypos].Receive);

          YPos1 := 1;

          Repeat

          TextColor(15); TextBackGround(3);
          GotoXY(X[YPos1], (Hi(WindMax) Div 2)-4+YPos1);
          If YPos1 = 1 Then Write(Proto[Ypos].Lettre);
          If YPos1 = 2 Then If Proto[Ypos].Name <> ''    Then Write(Proto[Ypos].Name)
                                                         Else Write('              ');
          If YPos1 = 3 Then If Proto[Ypos].Send <> ''    Then Write(Proto[Ypos].Send)
                                                         Else Write('              ');
          If YPos1 = 4 Then If Proto[Ypos].Receive <> '' Then Write(Proto[Ypos].Receive)
                                                         Else Write('              ');
          Repeat
           C := Upcase(ReadKey);
          Until C In ['Q', #27, #72, #80, #13];

          TextColor(11); TextBackGround(0);
          GotoXY(X[YPos1], (Hi(WindMax) Div 2)-4+YPos1);
          If YPos1 = 1 Then Write(Proto[Ypos].Lettre);
          If YPos1 = 2 Then If Proto[Ypos].Name <> ''    Then Write(Proto[Ypos].Name)
                                                         Else Write('              ');
          If YPos1 = 3 Then If Proto[Ypos].Send <> ''    Then Write(Proto[Ypos].Send)
                                                         Else Write('              ');
          If YPos1 = 4 Then If Proto[Ypos].Receive <> '' Then Write(Proto[Ypos].Receive)
                                                         Else Write('              ');


          Case C Of
           #80 : Inc(YPos1);
           #72 : Dec(YPos1);
           #13 : Begin;
                  CurSorOn;
                  GotoXY(X[YPos1], (Hi(WindMax) Div 2)-4+YPos1);
                  If YPos1 = 1 Then Proto[Ypos].Lettre  := MAJ(GetString(1, Proto[YPos].Lettre, '±'));
                  If YPos1 = 2 Then Proto[Ypos].Name    := GetString(20, Proto[YPos].Name, '±');
                  If YPos1 = 3 Then Proto[Ypos].Send    := GetString(52, Proto[YPos].Send, '±');
                  If YPos1 = 4 Then Proto[Ypos].Receive := GetString(52, Proto[YPos].Receive, '±');
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
           Assign(Protocol,  Config.BSFMailDir+'BSFPROTO.DAT');
           Reset(Protocol);
           For Rec := 1 To 10 Do
            Begin;
             Seek(Protocol, Rec-1);
             Write(Protocol, Proto[Rec]);
            End;
           Close(Protocol);
          End;
   End;
  End;
End;
END.
