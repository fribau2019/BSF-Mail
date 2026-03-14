UNIT MGRExImp;

{$I E:\SOURCE~1\PASCAL\NETMAIL\LANGAGE.DIR}
Interface

 Procedure ConfigImportExport;

Implementation

Uses CRT,
     DOS,
     BSFConst,
     BSFUtils,
     MGRVaria,
     MGRDeflt,

     MGREXIM1;    {Cr‚ation D'un Nouveau HUB}



Var Modif  : Boolean;
    DirInfo: SearchRec;
    Posis  : Byte;
    MENU   : ARRAY [1..24] Of String;
    Max    : Shortint;
    X,
    Y      : Integer;


{-------------------------------------------------------------------------}
Procedure Cadre(Max : Byte);
Var Posis : Byte;
Begin;
 TextColor(15);
 TextBackGround(0);
 ClrScr;
 TextColor(14);

{$IFDEF ENGLISH}
 GotoXY(23,1);
 Writeln('þþþ CONFIGURATION EDITOR þþþ');
{$ELSE}
 GotoXY(21,1);
 Writeln('þþþ EDITEUR DE CONFIGURATION þþþ');
{$ENDIF}
 TextColor(11);
 TextBackGround(0);
 GotoXY(27,05);
 Write('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
 For Posis := 1 To Max+1 Do
  Begin;
   GotoXY(27,05+Posis);
   Write('³                 ³');
   GotoXY(31,05+Posis);
   TextColor(11);
   Write(Menu[Posis]);
   TextColor(15);
  End;
 GotoXY(27,05+Posis);
 Write('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');

 TextColor(11);
 GotoXY(1,Hi(WindMax)-3);
 Writeln('  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  ÚÄÄÄÄÄÄ¿');
{$IFDEF ENGLISH}
 Writeln('  ³ Edit Config BBS  ³  ³  Create New BBS   ³  ³ Delete Config ³  ³ Quit ³');
{$ELSE}
 Writeln('  ³  Editer Un BBS   ³  ³ Cr‚er Nouveau BBS ³  ³  Effacer BBS  ³  ³ Quit ³');
{$ENDIF}
 Writeln('  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  ÀÄÄÄÄÄÄÙ');

End;
{-------------------------------------------------------------------------}
Procedure Pop(MAX : Byte);

Var
    C 	: Char;
    Fin : Boolean;
    Chaine : String;

Begin;
 Y := 6;
 X := 4;
 Fin := False;
 Repeat
  TextBackGround(3);
  TextColor(11);
  GotoXY(28,Y);
  Write('   ',Menu[Y-05],Copy('                   ',1,14-Length(Menu[Y-05])));

  GotoXY(X, Hi(WindMax)-2);
 {$IFDEF ENGLISH}
  If X = 04 Then Writeln(' Edit Config File ');
  If X = 26 Then Writeln(' Create New Config ');
  If X = 49 Then Writeln(' Delete Config ');
  If X = 68 Then Writeln(' Quit ');
 {$ELSE}
  If X = 04 Then Writeln('   Editer Un BBS  ');
  If X = 26 Then Writeln(' Cr‚er Nouveau BBS ');
  If X = 49 Then Writeln('  Effacer BBS  ');
  If X = 68 Then Writeln(' Quit ');
 {$ENDIF}

   C := Upcase(Readkey);


   If C = #77 Then Begin;
			  TextBackGround(0);
			  TextColor(11);
                          GotoXY(X, Hi(WindMax)-2);
                         {$IFDEF ENGLISH}
                          If X = 04 Then Writeln(' Edit Config File ');
                          If X = 26 Then Writeln(' Create New Config ');
                          If X = 49 Then Writeln(' Delete Config ');
                          If X = 68 Then Writeln(' Quit ');
                         {$ELSE}
                          If X = 04 Then Writeln('   Editer Un BBS  ');
                          If X = 26 Then Writeln(' Cr‚er Nouveau BBS ');
                          If X = 49 Then Writeln('  Effacer BBS  ');
                          If X = 68 Then Writeln(' Quit ');
                         {$ENDIF}
                          Inc(X);
                   End;

   If C = #75 Then Begin;
			  TextBackGround(0);
			  TextColor(11);
                          GotoXY(X, Hi(WindMax)-2);
                         {$IFDEF ENGLISH}
                          If X = 04 Then Writeln(' Edit Config File ');
                          If X = 26 Then Writeln(' Create New Config ');
                          If X = 49 Then Writeln(' Delete Config ');
                          If X = 68 Then Writeln(' Quit ');
                         {$ELSE}
                          If X = 04 Then Writeln('   Editer Un BBS  ');
                          If X = 26 Then Writeln(' Cr‚er Nouveau BBS ');
                          If X = 49 Then Writeln('  Effacer BBS  ');
                          If X = 68 Then Writeln(' Quit ');
                         {$ENDIF}
                          Dec(X);
                   End;


   If C = #80 Then Begin;
			  TextBackGround(0);
			  TextColor(11);
			  GotoXY(28,Y);Write('   ',Menu[Y-05],Copy('                   ',1,14-Length(Menu[Y-05])));
			  Inc(Y);
		   End;
   If C = #72 Then Begin;
			  TextBackGround(0);
			  TextColor(11);
			  GotoXY(28,Y);Write('   ',Menu[Y-05],Copy('                   ',1,14-Length(Menu[Y-05])));
			  Dec(Y);
		   End;
   If C = #13 Then Begin;
   	            TextBackGround(0);
		    TextColor(11);
		    GotoXY(28,Y);Write('   ',Menu[Y-05],Copy('                   ',1,14-Length(Menu[Y-05])));
                    Fin := True;
                   End;

   If C = #27 Then Begin;
                    Y := 05+Max;
                    X := 0;
                    Fin := True;
                   End;

 If Y = 05 Then Y := 05+MAX;
 If Y = 06+MAX Then Y := 06;

 If X = 05 Then X := 26; If X = 27 Then X := 49;
 If X = 50 Then X := 68; If X = 69 Then X := 04;
 If X = 03 Then X := 68; If X = 25 Then X := 04;
 If X = 48 Then X := 26; If X = 67 Then X := 49;

 Until Fin = True;
 TextColor(15);
 TextBackGround(0);
 Y := Y - 5;
 If X = 04 Then X := 1;
 If X = 26 Then X := 2;
 If X = 49 Then X := 3;
 If X = 68 Then X := 0;

End;

{-------------------------------------------------------------------------}
Procedure ConfigImportExport;
Var C : Char;
Begin;
 Repeat
  Modif := False;
  CursorOff;
  FindFirst('*.MAP', Archive, DirInfo);
  Posis := 1;
  While DosError = 0 do
  begin
    Menu[Posis] := Copy(DirInfo.Name, 1, Pos('.', DirInfo.Name)-1);
    FindNext(DirInfo);
    Inc(Posis);
  End;
  Max := Posis-1;
  Cadre(MAX);
  If Max > 0 Then Pop(Max);

  cursoron;

  If X = 1 Then Write(^g); (*********************)

  If ( (X = 2) Or (Max = 0)) Then
   Begin;
    GotoXY(10, Hi(WindMax)-10);
    Menu[Max+1] := '';
   {$IFDEF ENGLISH}
    Write('Please Enter Config BBS ID (8 Caracteres) : ');
   {$ELSE}
    Write('Veuillez Entrer Un Nom De BBS ID (8 CaractŠres) : ');
   {$ENDIF}
    ReadLn(Menu[Max+1]);
    If Length(Menu[Max+1]) > 8 Then Menu[Max+1] := Copy(Menu[Max+1], 1, 8);
    If Menu[Max+1] <> '' Then Menu[Max+1] := MAJ(Menu[Max+1]);
    If Menu[Max+1] <> '' Then CreeHUB(Menu[Max+1]);
   End;

  If X = 3 Then
   Begin;
    GotoXY(13,Hi(WindMax)-7);
   {$IFDEF ENGLISH}
    Write('Delete '+Menu[Y]+' (Y/N) ? ');
   {$ELSE}
    Write('Effacer '+Menu[Y]+' (O/N) ? ');
   {$ENDIF}
    Repeat
     C := Upcase(ReadKey);
    Until C in ['Y','N','O',#27];

    Case C Of
     'O',
     'Y' : Begin;
            (***************************)
           End;
     #27,
     'N' :;
    End;
   End;

 Until X = 0;
End;


End.
