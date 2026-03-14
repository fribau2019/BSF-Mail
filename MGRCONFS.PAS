UNIT MGRConfs;

{$I E:\SOURCE~1\PASCAL\NETMAIL\LANGAGE.DIR}

Interface

 Procedure ConferenceEditor;

Implementation

Uses CRT,
     BSFConst,
     BSFUtils,
     MGRVaria,
     MGRDeflt;

Var Modif  : Boolean;

{-------------------------------------------------------------------------}
Function YON(S : Boolean) : String;
Begin;
 {$IFDEF ENGLISH}
  If S Then Yon := 'Yes' Else Yon := '   ';
 {$ELSE}
  If S Then Yon := 'Oui' Else Yon := '   ';
 {$ENDIF}
End;
{-------------------------------------------------------------------------}
Function ReBlanc(S : String; Lng : Byte) : String;
Var I : Byte;
Begin;
 If Length(S) < Lng Then
  Repeat
   S := S + ' ';
  Until Length(S) >= Lng;
 ReBlanc := S;
End;
{-------------------------------------------------------------------------}
Function Blanc(SST: String) : String;
Var I : Integer;
    TAT : String;
Begin;
 Blanc := '';
 TAT   := '';
for i := 1 to Length(SST) do
  If SST[i] <> ' ' Then TAT := TAT + SST[I];
  Blanc := TAT;
End;
{-------------------------------------------------------------------------}
Procedure ConferenceEditor;

 Const SetXpos : Array[1..5] Of Byte = (7,14,56,70,76);

 Type DirConference = Record
          Security     : Word;
          SpitfireName : String[40];
          BSFMAILID    : String[12];
          Default      : Boolean;
          Force        : Boolean;
      End;


 Var
     DirConf : Array[0..Register] of DirConference;
     MSysF   : File Of MsgSystem;
     MSys    : MsgSystem;
     Rec     : Integer;
     NbConf  : Word;
     YMax    : Byte;
     DivPos  : ShortInt;
     YPos,
     XPos    : Byte;
     NoConf  : Word;
     Chaine  : String[40];
     C       : Char;
     Conferen: Text;
     Def     : File Of ConfigurationConferenceParDefault;
     Deflt   : ConfigurationConferenceParDefault;
     I       : Integer;


Begin;

 If LoadConfiguration(Config) = False Then Exit;

 TextBackGround(0); TextColor(15);
 ClrScr;

{Lecture Fichiers SFMCONF.DAT Dans Repertoire SPITFIRE [Fichier DAT]}
 Assign(MSysF, Config.SFDir+'SFMCONF.DAT');
 Reset(MSysF);
 For Rec := 0 To FileSize(MSysF)-1 Do
  Begin;
   Seek(MSysF, Rec);
   Read(MSysF, Msys);
   DirConf[Rec].Security     := MSys.MSec;
   DirConf[Rec].SpitfireName := MSys.MDesc;
  End;
 NbConf := FileSize(MSysF)-1;
 Close(MSysF);

{Lecture Fichiers BSFCONF.DAT [Fichier Texte]}
 Assign(Conferen, Config.BSFMailDir+'BSFCONF.DAT');
 {$I-} Reset(Conferen); {$I+}
 If Ioresult <> 0 Then
  Begin;
   Rewrite(Conferen);
    For Rec := 0 To NbConf Do
     Begin;
      DirConf[Rec].BSFMAILID := Blanc(DirConf[Rec].SpitfireName);
      WriteLn(Conferen,DirConf[Rec].BSFMAILID);
     End
  End
 Else
  For Rec := 0 To NbConf Do
   Begin;
    ReadLn(Conferen, Chaine);
    DirConf[Rec].BSFMAILID := Chaine;
   End;
 Close(Conferen);

{Lecture Fichier BSFCONF.DEF [Fichier DAT]}
 Assign(Def, Config.BSFMailDir+'BSFCONF.DEF');
 {$I-} Reset(DEF); {$I+}
 If Ioresult <> 0 Then
  Begin;
   ReWrite(DEF);
   For Rec := 0 To Register Do
    Begin;
     Deflt.Default  := False;
      DirConf[Rec].Default := False;
     Deflt.Force    := False;
      DirConf[Rec].Force := False;
     Deflt.Extra[0] := 0;
     Deflt.Extra[1] := 0;
     Deflt.Extra[2] := 0;
     Deflt.Extra[3] := 0;
     Deflt.Extra[4] := 0;
     Deflt.Extra[5] := 0;
     Deflt.Extra[6] := 0;
     Deflt.Extra[7] := 0;
     Deflt.Extra[8] := 0;
     Deflt.Extra[9] := 0;
     Seek(Def, Rec);
     Write(Def, Deflt);
    End;
  End
 Else
  For Rec := 0 To Register Do
   Begin;
    Seek(Def, Rec);
    Read(Def, Deflt);
    DirConf[Rec].Force   := Deflt.Force;
    DirConf[Rec].Default := Deflt.Default;
   End;
 Close(Def);

 Modif := False;
 YMax := Hi(WindMax) + 1;

 ClrScr;
 Window(1,1,80,2);
 TextBackGround(1);
 Textcolor(15);
 ClrScr;
 GotoXY(1,1);
{$IFDEF ENGLISH}
 Writeln('[Num] [Sec] [Spitfire Conference Name................] [BSFMAIL-ID] [DEF] [FOR]');
{$ELSE}
 Writeln('[Num] [Sec] [Nom De La Conf‚rence Spitfire...........] [BSFMAIL-ID] [DEF] [FOR]');
{$ENDIF}
 Write('===============================================================================');


 Window(1,3,80,YMax);
 TextBackGround(0);
 Textcolor(11);
 ClrScr;


 DivPos := 0;
 CurSorOff;
 Repeat
   TextColor(11);
   TextBackGround(0);

   {Ecran De Depart}
   Rec := 1;
   ClrScr;
   Repeat
    GotoXY(1, Rec+1);
     Write((((Hi(WindMax)-2)*DivPos))+Rec:4,' ',DirConf[(((Hi(WindMax)-2)*DivPos))+Rec-1].Security:5,'   ',
      DirConf[(((Hi(WindMax)-2)*DivPos))+Rec-1].SpitFireName);
    GotoXY(56, Rec+1);
     Write(DirConf[(((Hi(WindMax)-2)*DivPos))+Rec-1].BSFMAILID);
    GotoXY(70, Rec+1);
     Write(YON(DirConf[(((Hi(WindMax)-2)*DivPos))+Rec-1].Default));
    GotoXY(76, Rec+1);
     Write(YON(DirConf[(((Hi(WindMax)-2)*DivPos))+Rec-1].Force));
    Inc(Rec);
   Until ( (Rec >= Hi(WindMax)-1) Or ( (((Hi(WindMax)-2)*DivPos))+Rec > NbConf));

   XPos   := 1; YPos := 2;
   NoConf := ((Hi(WindMax)-2)*DivPos)+Ypos-2;

   TextColor(0); TextBackGround(3);
   GotoXY(SetXpos[Xpos], Ypos);
   Write(DirConf[NoConf].Security:4);


   Repeat

     C := Upcase(ReadKey);

     GotoXY(SetXpos[Xpos], Ypos);
     TextColor(11); TextBackGround(0);
      If Xpos = 1 Then Write(DirConf[NoConf].Security:4);
      If Xpos = 2 Then Write(Reblanc(DirConf[NoConf].SpitfireName,40));
      If Xpos = 3 Then Write(Reblanc(DirConf[NoConf].BsfmailID,12));
      If Xpos = 4 Then Write(YON(DirConf[NoConf].Default));
      If Xpos = 5 Then Write(YON(DirConf[NoConf].Force));

     Case C of
      '+' : Inc(DivPos);
      '-' : Dec(DivPos);
      #77 : Inc(Xpos);
      #75 : Dec(Xpos);
      #80 : Inc(Ypos);
      #72 : Dec(Ypos);
      #73 : Ypos := 2;
      #71 : Begin; Xpos := 1; Ypos := 2; End;
      #79 : Begin; Xpos := 1; Ypos := Hi(Windmax)-1; End;
      #81 : Begin; Xpos := 5; Ypos := Hi(Windmax)-1; End;
      #13 : Begin;
             CursorOn;
             If Xpos = 1 Then
              Begin;
               TextColor(15); TextBackGround(3);
               GotoXY(SetXpos[Xpos], Ypos); Write('    ');
               ReadInt(DirConf[NoConf].Security, I, SetXpos[Xpos], Ypos, 4);
               If ( (I >= 0) And (I <= 9999) ) Then DirConf[NoConf].Security := I;
               TextColor(0);
               GotoXY(SetXpos[Xpos], Ypos); Write(DirConf[NoConf].Security:4);
               Modif := True;
              End;
             If Xpos = 2 Then
              Begin;
               TextColor(15); TextBackGround(3);
               GotoXY(SetXpos[Xpos], Ypos);
               Chaine := DirConf[NoConf].SpitfireName;
               Chaine := GetString(40, Chaine, '±');
               DirConf[NoConf].SpitfireName := Chaine;
               Modif := True;
              End;
             If Xpos = 3 Then
              Begin;
               TextColor(15); TextBackGround(3);
               GotoXY(SetXpos[Xpos], Ypos);
               Chaine := DirConf[NoConf].BSFMAILID;
               Chaine := GetString(12, Chaine, '±');
               DirConf[NoConf].BSFMAILID := Chaine;
               Modif := True;
              End;
             If Xpos = 4 Then
              Begin;
               DirConf[NoConf].DeFault := NOT DirConf[NoConf].Default;
               Modif := True;
              End;
             If Xpos = 5 Then
              Begin;
               DirConf[NoConf].Force   := NOT DirConf[NoConf].Force;
               Modif := True;
              End;
             CursorOff;
            End;
     End;

     If DivPos < 0 Then DivPos := 0;
     If (DivPos * Hi(WindMax)) - 2 > NbConf Then Dec(DivPos);
     If Xpos > 5 Then Xpos := 5;
     If Xpos < 1 Then Xpos := 1;
     If YPos > Hi(WindMax)-1 Then Dec(Ypos);
     If ((Hi(WindMax)-2)*DivPos)+Ypos-1 > NbConf Then Dec(Ypos);
     If Ypos < 2 Then Ypos := 2;

     NoConf := ((Hi(WindMax)-2)*DivPos)+Ypos-2;
     GotoXY(SetXpos[Xpos], Ypos);

     TextColor(0); TextBackGround(3);
      If Xpos = 1 Then Write(DirConf[NoConf].Security:4);
      If Xpos = 2 Then Write(Reblanc(DirConf[NoConf].SpitfireName,40));
      If Xpos = 3 Then Write(Reblanc(DirConf[NoConf].BsfmailID,12));
      If Xpos = 4 Then Write(YON(DirConf[NoConf].Default));
      If Xpos = 5 Then Write(YON(DirConf[NoConf].Force));


   Until C in ['+', '-', 'Q', #27];


 Until C in ['Q', #27];

 CurSorOn;


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
           {Ecriture Fichier SFMCONF.DAT Dans Repertoire SPITFIRE [Fichier DAT]}
            Assign(MSysF, Config.SFDir+'SFMCONF.DAT');
            Reset(MSysF);
            For Rec := 0 To NbConf Do
             Begin;
              MSys.MSec  := DirConf[Rec].Security;
              MSys.MDesc := DirConf[Rec].SpitfireName;
              Seek(MSysF, Rec);
              Write(MSysF, Msys);
             End;
            Close(MSysF);

           {Lecture Fichiers BSFCONF.DAT [Fichier Texte]}
            Assign(Conferen, Config.BSFMailDir+'BSFCONF.DAT');
            Reset(Conferen);
            Rewrite(Conferen);
            For Rec := 0 To NbConf Do
             WriteLn(Conferen, DirConf[Rec].BSFMAILID);
            Close(Conferen);

           {Lecture Fichier BSFCONF.DEF [Fichier DAT]}
           Assign(Def, Config.BSFMailDir+'BSFCONF.DEF');
           Reset(DEF);
           For Rec := 0 To Register Do
            Begin;
             Deflt.Force   := DirConf[Rec].Force;
             Deflt.Default := DirConf[Rec].Default;
             Seek(Def, Rec);
             Write(Def, Deflt);
            End;
           Close(Def);


          End;
   End;
  End;
End;


End.
