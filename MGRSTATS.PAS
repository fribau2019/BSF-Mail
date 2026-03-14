UNIT MGRStats;

{$I LANGAGE.DIR}

Interface

 Procedure Statistiques;

Implementation

 Uses CRT,
      BSFUtils,
      MGRVaria;

Var
    NbConnect,
    NbPacketDownload,
    NbPacketUpload,
    NbMsgDownload,
    NbMsgUpload,
    NbPageSys,
    NbProto,
    NbComp,
    NbConf              : LongInt;
    User                : Users;
    USR                 : File Of Users;
    I                   : Integer;
    C                   : Char;

{-------------------------------------------------------------------------}
Procedure LectureCFG;
Var CFG : Text;
    C   : Char;
Begin;
{Lecture NETMAIL.CFG [Fichier Texte]}
 Assign(CFG, ConfigPathName);
 Reset(CFG);
 ReadLn(CFG, Config.BSFMailDir);
 ReadLn(CFG, Config.BBSName);
 ReadLn(CFG, Config.BBSID);
 ReadLn(CFG, Config.BBSCity);
 ReadLn(CFG, Config.BBSPhone);
 ReadLn(CFG, Config.LocalQWK);
 ReadLn(CFG, Config.WelcomeDir);
 ReadLn(CFG, Config.NewsDir);
 ReadLn(CFG, Config.GoodByeDir);
 ReadLn(CFG, C);
  If C = 'Y' Then Config.AddFiles := True Else Config.AddFiles := False;
 ReadLn(CFG, C);
  If C = 'Y' Then Config.Goodbye := True Else Config.Goodbye := False;
 Readln(CFG, Config.PathLog);
 Readln(CFG, Config.SFDIR);
 Close(CFG);
End;
{-------------------------------------------------------------------------}
Procedure Statistiques;
Begin;

 NbPacketDownload := 0;
 NbPacketUpload   := 0;
 NbMsgDownload    := 0;
 NbMsgUpload      := 0;
 NbConnect        := 0;
 NbPageSys        := 0;
 NbProto          := 0;
 NbComp           := 0;
 NbConf           := 0;

 LecTureCFG;
 TextBackGround(0);
 ClrScr;
 TextColor(14);
 GotoXY(36,1);
 Writeln('STATISTIQUES');
 TextColor(11);


 Assign(USR, Config.BSFMailDir+'BSFUSERS.DAT');
 {$I-} Reset(USR); {$I+}
 If Ioresult <> 0 Then Begin;
                        Writeln;
                        Writeln('þ BSFUSERS.DAT Not Found !');
                        Delay(2500);
                        EXit;
                       End;
 Writeln;
{$IFDEF ENGLISH}
 Writeln('þ Number Of Users : ',Filesize(USR));
{$ELSE}
 Writeln('þ Nombre De Users : ',Filesize(USR));
{$ENDIF}
 For I := 0 To FileSize(USR)-1 Do
  Begin;
   Seek(USR, I);
   Read(USR, User);
   NbConnect        := NbConnect        + User.NbConnection;
   NbMsgDownload    := NbMsgDownload    + User.NbMessDown;
   NbMsgUpload      := NbMsgUpload      + User.NbMessUpld;
   NbPageSys        := NbPageSys        + User.NbPageSysOp;
   NbPacketDownload := NbPacketDownload + User.NbDownPacket;
   NbPacketUpload   := NbPacketUpload   + User.NbUpldPacket;
  End;
 Close(USR);
{$IFDEF ENGLISH}

 Writeln('þ Total Of Connection : ',NbConnect);
 Writeln;
 Writeln('þ Number Of Packets Downloaded  : ',NbPacketDownload);
 Writeln('þ Number Of Packets Uploaded    : ',NbPacketUpload);
 Writeln('þ Number Of Messages Downloaded : ',NbMsgdownload);
 Writeln('þ Number Of Messages Uploaded   : ',NbMsgUpload);
 Writeln('þ Number Of Page SysOp          : ',NbPageSys);
 Writeln;
 Writeln;
 Writeln;
 CurSorOff;
 Write('Press <Q>uit ');
{$ELSE}

 Writeln('þ Total De Connection : ',NbConnect);
 Writeln;
 Writeln('þ Nombre De Paquets Downloaded  : ',NbPacketDownload);
 Writeln('þ Nombre De Paquets Uploaded    : ',NbPacketUpload);
 Writeln('þ Numbre De Messages Downloaded : ',NbMsgdownload);
 Writeln('þ Nombre De Messages Uploaded   : ',NbMsgUpload);
 Writeln('þ Nombre D''Appel Au SysOp       : ',NbPageSys);
 Writeln;
 Writeln;
 Writeln;
 CurSorOn;
 Write('Pressez <Q>uit : ');
{$ENDIF}
 C := ' ';
 Repeat
  C := Upcase(ReadKey);
 Until C in ['Q', #13, #27];

End;


End.
