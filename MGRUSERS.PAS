UNIT MGRUsers;

{$I LANGAGE.DIR}

Interface

 Procedure UserEditor;

Implementation

 USES Crt,
      Dos,
      MGRDeflt,
      BSFUtils,
      MGRMenu,
      MGRUser1,
      MGRVaria;

Var Fin    : Boolean;
    I      : Integer;
    Reponse : String[40];


{-------------------------------------------------------------------------}
Function VerifieNumeroUser(Position : Word) : Boolean;

Var SFCALL : File Of UsersSF;
    SF     : UsersSF;

Begin;
  Assign(SFCALL, Config.WorkDir+'SFUSERS.DAT');
  {$I-} Reset(SFCALL); {$I+}
  If Ioresult <> 0 Then
   Begin;
    ClrScr;
    Writeln;
   {$IFDEF ENGLISH}
    Writeln(' þ SFUSERS.DAT not Found !');
   {$ELSE}
    Writeln(' þ Fichier SFUSERS.DAT non trouv‚ !');
   {$ENDIF}
    Halt(1);
   End;



  If Position < FileSize(SFCALL) Then
   Begin;
    Seek(SFCALL, Position);
    Read(SFCALL, SF);
    Close(SFCALL);
    If MAJ(User.Name) = MAJ(SF.UserName) Then VerifieNumeroUser := True
                                         Else VerifieNumeroUser := False;
   End
  Else VerifieNumeroUser := False;
End;
{-------------------------------------------------------------------------}
Function CheckingUSer : Word;
Var SFCALL : File Of UsersSF;
    SF     : UsersSF;
    Trouve : Boolean;

Begin;
  Assign(SFCALL, Config.WorkDir+'SFUSERS.DAT');
  {$I-} Reset(SFCALL); {$I+}
  If Ioresult <> 0 Then Begin;
                         ClrScr;
                         Writeln;
                        {$IFDEF ENGLISH}
                         Writeln(' þ SFUSERS.DAT not Found !');
                        {$ELSE}
                         Writeln(' þ Fichier SFUSERS.DAT non trouv‚ !');
                        {$ENDIF}
                         Halt(1);
                        End;
 I := 0;
 Trouve := False;
 Repeat
  Seek(SFCALL, I);
  Read(SFCALL, SF);
  If MAJ(SF.UserName) = MAJ(User.Name) Then Trouve := True;
 Inc(I);
 Until ( (I>=FileSize(SFCALL)) Or ( Trouve ) );

 Close(SFCALL);

 If MAJ(SF.UserName) = MAJ(User.Name) Then CheckingUser := I
                                      Else CheckingUser := 65535;

End;
{-------------------------------------------------------------------------}
Procedure Default;
Begin;

   User.Name           := '';
   User.Protocol       := 0;
   User.Compression    := 0;
   User.Welcome        := False;
   User.Bulletin       := False;
   User.UploadFiles    := False;
   User.DownloadFiles  := False;
   User.Prescan        := False;
   User.UseCurentDate  := False;
   User.News           := False;
   User.SmallControl   := False;
   User.SendUserInf    := False;
   User.NDXFiles       := True;
   User.RepeatScan    := False;
   User.Goodbye        := False;
   User.AllowFileUpld  := False;
   User.AllowFileDown  := False;
   User.XPertMode      := False;


   For I := 0 To Register Do User.Conf.Attribut[I] := 0;

   User.NbPageSysOp    := 0;
   User.NbMessDown     := 0;
   User.NbMessUpld     := 0;
   User.NbConnection   := 0;
   User.LastQWKDate    := 'N/A';
   User.LastQWKTime    := '00:00';
   User.NewFiles       := False;
   User.SFNumero       := 0;
   User.NetStatus      := False;


End;
{-------------------------------------------------------------------------}
Procedure UserEditor;
  Var Rec    : Integer;
      I      : Integer;
      D,
      C      : Char;
      X      : Byte;
      Variable : String;
      MsgUsr   : String[40];

      Nombre : Integer;
      RecToDel : Integer;
      NewNetUser : File Of Users;
      ConfActive,
      ConfNetMail : Word;
      F           : File;


Begin;
  {$IFDEF ENGLISH}
   MsgUsr := 'þ Empty BSFMAIL Users DataBase þ';
  {$ELSE}
   MsgUsr := 'þ Base Utilisateurs BSFMAIL Vide þ';
  {$ENDIF}

 If LoadConfiguration(Config) = False Then Exit;

 Textcolor(11);
 Textbackground(0);
 Clrscr;


 Assign(USR, Config.BSFMailDir+'BSFUSERS.DAT');
 {$I-} Reset(USR);  {$I+}
 If IoResult <> 0 Then
  Begin;
   Writeln;
   GotoXY(40-( Length(Msgusr) Div 2), Hi(WindMax)-1);
   TextColor(11);
   TextBackGround(1);
  {$IFDEF ENGLISH}
   Writeln(' þ Empty BSFMAIL Users DataBase þ');
  {$ELSE}
   Writeln('þ Base Utilisateurs BSFMAIL Vide þ');
  {$ENDIF}
   TextBackGround(0);
   Write(^g);
   Delay(1500);
   Exit;
  End;

 Rec := 0;

 If FileSize(USR) = 0 Then ReWrite(USR);

 Seek(USR, Rec);
 Read(USR, User);

Repeat
 ClrScr;

 ConfActive := 0;
 For I := 0 To Register Do If User.Conf.Attribut[I] > 0 Then Inc(ConfActive);

 ConfNetMail := 0;
 For I := 0 To Register Do If User.Conf.Attribut[I] >= 100 Then Inc(ConfNetMail);

 AfficheUser(Rec, FileSize(USR), ConfActive, ConfNetmail);
{$IFDEF ENGLISH}
 GotoXY(1,16); Writeln('[------------------------------------------------------------------------------]');
 GotoXY(1,17); Writeln('  <N>..Name         <P>..Protocol       <C>..Compression     <F>..Conferences   ');
 GotoXY(1,18); Writeln('  <A>..Add User     <D>..Delete User    <+>..Next User       <->..Previous User ');
 GotoXY(1,19); Writeln('  <X>..Extra        <O>..Options        <S>..Search User     <Q>..Quit          ');
 GotoXY(1,20); Writeln('[------------------------------------------------------------------------------]');
 GotoXY(3,21); Write('Enter Your Choise : ');
{$ELSE}
 GotoXY(1,16); Writeln('[------------------------------------------------------------------------------]');
 GotoXY(1,17); Writeln('  <N>..Nom          <P>..Protocole      <C>..Compression     <F>..Conferences   ');
 GotoXY(1,18); Writeln('  <A>..Ajouter User <D>..Effacer User   <+>..User Suivant    <->..User Precedent');
 GotoXY(1,19); Writeln('  <X>..Extra        <O>..Options        <S>..Rechercher User <Q>..Quitter       ');
 GotoXY(1,20); Writeln('[------------------------------------------------------------------------------]');
 GotoXY(3,21); Write('Entrer Votre Choix : ');
{$ENDIF}


 Repeat
  C := Upcase(ReadKey);
 Until C in ['N','P','C','A','+','-','Q','X','O','F','D','S', #27];

 Case C Of
     'N' : Begin;
            GotoXY(01,WhereY); ClrEol;
            GotoXY(3,22);
            ClrEol;
            Write('Enter Name : ');
            Readln(Reponse);
            If Reponse <> '' Then User.Name := Reponse
             Else User.Name := User.Name;
           End;
     'P' : Begin;
            GotoXY(01,WhereY); ClrEol;
            GotoXY(3,22);
            ClrEol;
            Write('Enter Protocol Number : ');
            Repeat
              C := ReadKey;
            Until Upcase(C) In ['0'..'9', #13];
            X := StrToInt(C);
            If C <> #13 Then User.Protocol := X;
           End;
     'C' : Begin;
            GotoXY(01,WhereY); ClrEol;
            GotoXY(3,22);
            ClrEol;
            Write('Enter Compression Number : ');
            Repeat
             C := ReadKey;
            Until Upcase(C) In ['0'..'9', #13];
            X := StrToInt(C);
            If C <> #13 Then User.Compression := X;
           End;
     'A' : Begin;
            GotoXY(01,WhereY); ClrEol;
            Seek(USR, Rec);
            Write(USR, User);
            Default;
            GotoXY(3,22);
             Write(' User Name : ');
             ReadLn(User.Name);
            If User.Name <> '' Then Begin;
            Seek(USR, FileSize(USR));
            Write(USR, User);
            Rec := FileSize(USR)-1;
            End
             Else Begin;
                  Seek(USR, Rec);
                  Read(USR, User);
                 End;

           End;
     'D' : Begin;
            GotoXY(01,WhereY); ClrEol;
            GotoXY(3,22); Write(' Are You Sure (y/N) : ');
            Repeat
             D := Upcase(ReadKey);
            Until D In ['Y', 'N', #13];

            Case D Of
             'Y' : Begin;
                    Write(^g);
                    RecToDel := Rec;
                    Rec := FileSize(USR);
                    GotoXY(20,24);
                    Writeln(' User ', RecToDel+1,' Will Be Erased');

                    Assign(NewNetUser, Config.BSFMailDir+'BSFUSERS.$$$');
                   {$I-} Reset(NewNetUser); {$I+}
                    If IoResult <> 0 Then;
                    ReWrite(NewNetUser);
                    For I := 0 To Rec-1 Do
                     Begin;
                      Seek(USR, I);
                      Read(USR, User);
                      If I <> RecToDel Then Write(NewNetUser, User);
                     End;
                    Rec := RecToDel;
                    Close(NewNetUser);

                    Close(USR);
                    Erase(USR);

                    Assign(F, Config.BSFMailDir+'BSFUSERS.$$$');
                    Rename(F, Config.BSFMailDir+'BSFUSERS.DAT');

                    Assign(USR, Config.BSFMailDir+'BSFUSERS.DAT');
                    Reset(USR);
                    If Rec > FileSize(USR)-1 Then Rec := FileSize(USR)-1;
                    If FileSize(USR) = 0 Then Begin;
                                               Close(USR);
                                               Erase(USR);
                                               Exit;
                                              End;
                    Seek(USR, Rec);
                    Read(USR, User);
                   End;
             'N' :;
             #13 :;
            End;
           End;
     'X' : Begin;
            GotoXY(1,WhereY); ClrEol;
           {$IFDEF ENGLISH}
            GotoXY(1,WhereY);    Write(' þ Total Of Connection : ',User.NbConnection);
            GotoXY(1,WhereY+1);  Write(' þ Total Of Page SysOp : ',User.NbPageSysOp);
            GotoXY(42,WhereY-1); Write(' þ Number Of Packets Downloaded : ',User.NbDownPacket);
            GotoXY(42,WhereY+1); Write(' þ Number Of Packets Uploaded   : ',User.NbUpldPacket);
            GotoXY(1,WhereY+1);  Write(' þ Number Of Messages Downloaded : ',User.NbMessDown);
            GotoXY(1,WhereY+1);  Write(' þ Number Of Messages Uploaded   : ',User.NbMessUpld);
            GotoXY(70,WhereY+1); Write(' <Key>');
            Repeat Until Keypressed;
           {$ELSE}
            GotoXY(1,WhereY);    Write(' þ Total De Connection : ',User.NbConnection);
            GotoXY(1,WhereY+1);  Write(' þ Total De Page SysOp : ',User.NbPageSysOp);
            GotoXY(42,WhereY-1); Write(' þ Nombre De Paquets Download‚s : ',User.NbDownPacket);
            GotoXY(42,WhereY+1); Write(' þ Nombre De Paquets Upload‚s   : ',User.NbUpldPacket);
            GotoXY(1,WhereY+1);  Write(' þ Nombre De Messages Download‚s : ',User.NbMessDown);
            GotoXY(1,WhereY+1);  Write(' þ Nombre De Messages Upload‚s   : ',User.NbMessUpld);
            GotoXY(70,WhereY+1); Write(' <Touche>');
            Repeat Until Keypressed;
           {$ENDIF}
           End;

     'S' : Begin;
            GotoXY(01,WhereY); ClrEol;
            {$IFDEF ENGLISH}
            GotoXY(3,21); Write(' Enter Full Or Partial Name : ');
            {$ELSE}
            GotoXY(3,21); Write(' Entrer Le Nom En Entier Ou Partiellement : ');
            {$ENDIF}
            Variable := '';
            ReadLn(Variable);
            If Variable <> '' Then Begin;
                                    Variable := MAJ(Variable);
                                    I := 0;
                                    Repeat
                                     Seek(USR, I);
                                     Read(USR, User);
                                     C := 'N';
                                     If POS(Variable, MAJ(User.Name)) > 0 Then
                                       Begin;
                                        GotoXY(3, WhereY+2);
                                        {$IFDEF ENGLISH}
                                        Write('Are You Looking For '+User.Name+' ? (Y/n) : ');
                                        {$ELSE}
                                        Write('Rechercher-Vous '+User.Name+' ? (O/n) : ');
                                        {$ENDIF}
                                        Repeat
                                         C := Upcase(ReadKey);
                                        Until C In ['O', 'Y', 'N', #13];
                                        Case  C Of
                                         'Y','O' : Rec := I;
                                         'N' : ClrEol;
                                         #13 : Begin;
                                                Rec := I;
                                                C := 'Y';
                                               End;
                                       End;
                                     End;
                                     Inc(I);
                                    Until ( (C = 'Y') Or (I = FileSize(USR)) );

                                    IF I = FileSize(USR) Then Begin;
                                                               GotoXY(28, Hi(WindMax)-1);
                                                               TextColor(11);
                                                               TextBackGround(1);
                                                              {$IFDEF ENGLISH}
                                                               Writeln(' USER NOT FOUND ! ');
                                                              {$ELSE}
                                                               Writeln(' USER NON TROUVE ! ');
                                                              {$ENDIF}
                                                               TextBackGround(0);
                                                               Delay(1500);
                                                              End;

                                    If ( (C = 'N') Or (I=FileSize(USR)) ) Then
                                     Begin;
                                      Seek(USR, Rec);
                                      Read(USR, User);
                                     End;
                                   End;
           End;
     'O' : Begin;
            GotoXY(01,17); ClrEol;
            GotoXY(01,WhereY+1); ClrEol;
            GotoXY(01,WhereY+1); ClrEol;
            GotoXY(01,WhereY+1); ClrEol;
            GotoXY(01,WhereY+1); ClrEol;

{$IFDEF ENGLISH}
 GotoXY(03,17);       Write('A..Welcome Screen          F..Small CONTROL              K..Upload Files');
 GotoXY(03,WhereY+1); Write('B..Bulletins               G..Send NDX Files             L..Download Files');
 GotoXY(03,WhereY+1); Write('C..SysOp News              H..Send User Infos            M..Allow Files Upld');
 GotoXY(03,WhereY+1); Write('D..News Files Scan         I..Use Current Date           N..Allow Files Down');
 GotoXY(03,WhereY+1); Write('E..Goodbye Screen          J..Prescan                    O..Expert Mode');
 GotoXY(03,WhereY+1); Write('P..Netmail Status          Q..Repeat Prescan');
 GotoXY(01,WhereY+1); Write('[-----------------------------------------------------------------------------]');
{$ELSE}
 GotoXY(03,17);       Write('A..Ecran Presentation    F..Petit CONTROL.DAT      K..Uploader Fichiers');
 GotoXY(03,WhereY+1); Write('B..Bulletins             G..Envoie Fichiers NDX    L..Downloader Fichiers');
 GotoXY(03,WhereY+1); Write('C..Nouvelles Du SysOp    H..Envoie Infos Users     M..Autoriser Up Fichiers');
 GotoXY(03,WhereY+1); Write('D..Scan Nouveau Fichiers I..Utiliser Date Courante N..Autoriser Dn Fichiers');
 GotoXY(03,WhereY+1); Write('E..Ecran De Fin          J..Prescan Automatique    O..Mode Expert');
 GotoXY(03,WhereY+1); Write('P..Status NETMAIL        Q..Repeter Prescan');
 GotoXY(01,WhereY+1); Write('[-----------------------------------------------------------------------------]');
{$ENDIF}
     Repeat
        {$IFDEF ENGLISH}
        GotoXY(01, 24); Write('Enter Your Choise, <ENTER> To Quit : ');
        {$ELSE}
        GotoXY(01, 24); Write('Entrer Votre Choix, <ENTER> Pour Quitter: ');
        {$ENDIF}

           Repeat
             D := Upcase(ReadKey);
           Until D In ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q',#13,#27];

           Case D Of
            'A' : User.Welcome       := NOT USer.Welcome        ;
            'B' : User.Bulletin      := NOT USer.Bulletin       ;
            'C' : User.News          := NOT USer.News           ;
            'D' : User.NewFiles      := NOT USer.NewFiles       ;
            'E' : User.Goodbye       := NOT USer.Goodbye        ;
            'F' : User.SmallControl  := NOT USer.SmallControl   ;
            'G' : User.NDXFiles      := NOT USer.NDXFiles       ;
            'H' : User.SendUserInf   := NOT USer.SendUserInf    ;
            'I' : User.UseCurentDate := NOT USer.UseCurentDate  ;
            'J' : User.Prescan       := NOT USer.Prescan        ;
            'K' : User.UploadFiles   := NOT USer.UploadFiles    ;
            'L' : User.DownloadFiles := NOT USer.DownloadFiles  ;
            'M' : User.AllowFileUpld := NOT USer.AllowFileUpld  ;
            'N' : User.AllowFileDown := NOT USer.AllowFileDown  ;
            'O' : User.XpertMode     := NOT USer.XPertMode      ;
            'P' : User.NetStatus     := NOT User.NetStatus      ;
            'Q' : User.RepeatScan    := NOT User.RepeatScan     ;
          End;

     If D <> #13 Then  AfficheUser(Rec, FileSize(USR), ConfActive, ConfNetmail);

     Until D = #13;

            End;

     'F' : Begin;
            GotoXY(01,20); ClrEol;
            GotoXY(03,22); ClrEol;
            Writeln(' Verifing SF User #...');

            If VerifieNumeroUser(User.SfNumero)
             Then Begin;
                  SelectConf(User.SFNumero,
                             Config.SFDIR,
                             Config.MSGDir,
                             Config.BSFMailDir,
                             Rec);
                         Seek(USR, Rec);
                         Read(USR, User);
                  End
             Else Begin
                   User.SfNumero := CheckingUser-1;
                   If VerifieNumeroUser(User.SfNumero)
                   Then Begin
                         Seek(USR, Rec);
                         Write(USR, User);
                         SelectConf(USer.SFNumero,
                                    Config.SFDIR,
                                    Config.MSGDir,
                                    Config.BSFMailDir,
                                    Rec);
                         Seek(USR, Rec);
                         Read(USR, User);
                        End;
                  End;
            If User.SfNumero = 65534 Then
             Begin;
              Writeln;
              Write('   User Not Found : Deleted It (Y/N) ? ');
              D := ' ';
              Repeat
               D := Upcase(ReadKey);
              Until D In ['Y', 'N', #13];
              Case D Of
               'Y' : Begin;
                      Write(^g);
                      RecToDel := Rec;
                      Rec := FileSize(USR);
                      GotoXY(20,24);
                      Writeln(' User ', RecToDel+1,' Will Be Erased');

                      Assign(NewNetUser, Config.BSFMailDir+'BSFUSERS.$$$');
                      {$I-} Reset(NewNetUser); {$I+}
                      If IoResult <> 0 Then ReWrite(NewNetUser);
                      ReWrite(NewNetUser);
                      For I := 0 To Rec-1 Do
                       Begin;
                        Seek(USR, I);
                        Read(USR, User);
                        If I <> RecToDel Then Write(NewNetUser, User);
                       End;
                      Rec := RecToDel;
                      Close(NewNetUser);

                      Close(USR);
                      Erase(USR);

                      Assign(F, Config.BSFMailDir+'BSFUSERS.$$$');
                      Rename(F, Config.BSFMailDir+'BSFUSERS.DAT');

                      Assign(USR, Config.BSFMailDir+'BSFUSERS.DAT');
                      Reset(USR);
                      Seek(USR, Rec);
                      Read(USR, User);
                     End;
               'N' : ;
               #13 : ;
              End;
            End;
           End;
     '+' : Begin;
            Seek(USR, Rec); Write(USR, User);
            Inc(Rec);
            If Rec > FileSize(USR)-1 Then Rec := 0;
            Seek(USR, Rec);
            Read(USR, User);
           End;
     '-' : Begin;
            Seek(USR, Rec); Write(USR, User);
            Dec(Rec);
            If Rec < 0 Then Rec := FileSize(USR)-1;
            Seek(USR, Rec);
            Read(USR, User);
           End;

     'Q' : Begin;
            Seek(USR, Rec);
            Write(USR, User);
            Fin := True;
           End;

     #27 : Begin;
            Seek(USR, Rec);
            Write(USR, User);
            Fin := True;
           End;

 End;

Until Fin = True;


 Close(USR);
 If Ioresult <> 0 Then ;

 Fin := False;

End;

End.