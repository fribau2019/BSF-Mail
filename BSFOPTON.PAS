Unit BSFOpton;


{$I LANGAGE.DIR}


Interface

 Procedure OptionConfig;


Implementation
 Uses BSFCOMM,
      BSFConst,
      BSFHelp;

{---------------------------------------------------------------------------}
Function YN(Debut : Boolean) : String;

Begin;
{$IFDEF ENGLISH}
  If Debut = True  Then YN := 'YES';
  If Debut = False Then YN := 'NO ';
{$ELSE}
  If Debut = True  Then YN := 'OUI';
  If Debut = False Then YN := 'NON';
{$ENDIF}
End;


{---------------------------------------------------------------------------}
{$IFDEF ENGLISH}
Procedure VisuOption(Choix : Byte);
Begin;

If Choix = 0 Then Begin;

  RmClrScr;
  RmSetColor(14,0);
  RmWriteln('                            AVAILABLE OPTIONS');


  If Ansicolor = True Then
   Begin;
    RmSetColor(11,0);
    RmGotoXY(2,5);   RmWriteln('A. Include The Welcome Screen ...        H. Send User Informations .......');
    RmGotoXY(2,6);   RmWriteln('B. Include Bulletins ............        I. Use Current Date/Time ........');
    RmgotoXY(2,7);   RmWriteln('C. Include The SysOp News .......        J. Prescan QWK During Event .....');
    RmGotoXY(2,8);   RmWriteln('D. Include New Files ............        K. Repeat Prescan ...............');
{  RmgotoXY(2,9);   RmWriteln('E. Include Goodbye Screen........       *L. Include Download Files Listing');
   RmGotoXY(2,10);  RmWriteln('F. Use Small CONTROL.DAT File....       *M. Allow Attached File Upload....');
   RmGotoXY(2,11);  RmWriteln('G. Send NDX Files................       *N. Allow Attached File Downloaded');
 }
    RmgotoXY(2,9);   RmWriteln('E. Include Goodbye Screen .......');
    RmGotoXY(2,10);  RmWriteln('F. Use Small CONTROL.DAT File ...');
    RmGotoXY(2,11);  RmWriteln('G. Send NDX Files ...............');


    RmSetcolor(11,0);
    RmGotoXY(36,5);  RmWrite(YN(User.Welcome));
    RmGotoXY(36,6);  RmWrite(YN(User.Bulletin));
    RmGotoXY(36,7);  RmWrite(YN(User.News));
    RmGotoXY(36,8);  RmWrite(YN(User.NewFiles));
    RmGotoXY(36,9);  RmWrite(YN(User.Goodbye));
    RmGotoXY(36,10); RmWrite(YN(User.SmallControl));
    RmGotoXY(36,11); RmWrite(YN(User.NDXFiles));
    RmGotoXY(77,5);  RmWrite(YN(User.SendUserInf));
    RmGotoXY(77,6);  RmWrite(YN(User.UseCurentDate));
    RmGotoXY(77,7);  RmWrite(YN(User.Prescan));
    RmGotoXY(77,8);  RmWrite(YN(User.RepeatScan));
{  RmGotoXY(77,9);  RmWrite(YN(User.DownloadFiles));
   RmGotoXY(77,10); RmWrite(YN(User.AllowFileUpld));
   RmGotoXY(77,11); RmWrite(YN(User.AllowFileDown)); }
    RmSetColor(15,0);
  End;

  If Ansicolor = False Then
   Begin;
     RmWriteln('');
     RmWriteln('A. Include The Welcome Screen ... '+YN(User.Welcome)     +'   H. Send User Informations ....... '
       +YN(User.SendUserInf));
     RmWriteln('B. Include Bulletins ............ '+YN(User.Bulletin)    +'   I. Use Current Date/Time ........ '
       +YN(User.UseCurentDate));
     RmWriteln('C. Include The SysOp News ....... '+YN(User.News)        +'   J. Prescan QWK During Event ..... '
       +YN(User.Prescan));
     RmWriteln('D. Include New Files ............ '+YN(User.NewFiles)    +'   K. Repeat Prescan ............... '
       +YN(User.RepeatScan));
     RmWriteln('E. Include Goodbye Screen ....... '+YN(User.Goodbye) ); {   +'  *L. Include Download Files Listing '
       +YN(User.DownloadFiles));                                                                                  }
     RmWriteln('F. Use Small CONTROL.DAT File ... '+YN(User.SmallControl));{+'  *M. Allow Attached File Upload.... '
       +YN(User.AllowFileUpld));                                                                                  }
     RmWriteln('G. Send NDX Files ............... '+YN(User.NDXFiles));  {  +'  *N. Allow Attached File Downloaded '
       +YN(User.AllowFileDown));                                                                                  }
  End;
 End;

If Choix = 1 Then
If Ansicolor = True Then Begin;
   RmSetcolor(11,0);
   RmGotoXY(36,5);  RmWrite(YN(User.Welcome));
   RmGotoXY(36,6);  RmWrite(YN(User.Bulletin));
   RmGotoXY(36,7);  RmWrite(YN(User.News));
   RmGotoXY(36,8);  RmWrite(YN(User.NewFiles));
   RmGotoXY(36,9);  RmWrite(YN(User.Goodbye));
   RmGotoXY(36,10); RmWrite(YN(User.SmallControl));
   RmGotoXY(36,11); RmWrite(YN(User.NDXFiles));
   RmGotoXY(77,5);  RmWrite(YN(User.SendUserInf));
   RmGotoXY(77,6);  RmWrite(YN(User.UseCurentDate));
   RmGotoXY(77,7);  RmWrite(YN(User.Prescan));
   RmGotoXY(77,8);  RmWrite(YN(User.RepeatScan));
{  RmGotoXY(77,9);  RmWrite(YN(User.DownloadFiles));
   RmGotoXY(77,10); RmWrite(YN(User.AllowFileUpld));
   RmGotoXY(77,11); RmWrite(YN(User.AllowFileDown)); }
   RmSetColor(15,0);
End;

End;
{---------------------------------------------------------------------------}
{$ELSE}
Procedure VisuOption(Choix : Byte);
Begin;

If Choix = 0 Then Begin;
  RmClrScr;
  RmSetColor(14,0);
  RmWriteln('                           OPTIONS DISPONIBLES');

  If Ansicolor = True Then Begin;
   RmSetColor(11,0);
   RmGotoXY(2,5);   RmWriteln('A. Inclure Page De Pr‚sentation..        H. Envoyer Les Informations User.');
   RmGotoXY(2,6);   RmWriteln('B. Inclure Les Bulletins.........        I. Utiliser Date/Heure Actuelle..');
   RmgotoXY(2,7);   RmWriteln('C. Inclure La Lettre Du SysOp....        J. Prescan QWK Durant Une Event..');
   RmGotoXY(2,8);   RmWriteln('D. Inclure Les Nouveaux Fichiers.        K. R‚p‚ter Prescan...............');
{  RmgotoXY(2,9);   RmWriteln('E. Inclure La Page De Fin........       *L. Include Download Files Listing');
   RmGotoXY(2,10);  RmWriteln('F. Utiliser Un Petit CONTROL.DAT.       *M. Allow Attached File Upload....');
   RmGotoXY(2,11);  RmWriteln('G. Envoyer Les Fichiers NDX......       *N. Allow Attached File Downloaded');
 }

   RmgotoXY(2,9);   RmWriteln('E. Inclure La Page De Fin........');
   RmGotoXY(2,10);  RmWriteln('F. Utiliser Un Petit CONTROL.DAT.');
   RmGotoXY(2,11);  RmWriteln('G. Envoyer Les Fichiers NDX......');

   RmSetcolor(11,0);
   RmGotoXY(36,5);  RmWrite(YN(User.Welcome));
   RmGotoXY(36,6);  RmWrite(YN(User.Bulletin));
   RmGotoXY(36,7);  RmWrite(YN(User.News));
   RmGotoXY(36,8);  RmWrite(YN(User.NewFiles));
   RmGotoXY(36,9);  RmWrite(YN(User.Goodbye));
   RmGotoXY(36,10); RmWrite(YN(User.SmallControl));
   RmGotoXY(36,11); RmWrite(YN(User.NDXFiles));
   RmGotoXY(77,5);  RmWrite(YN(User.SendUserInf));
   RmGotoXY(77,6);  RmWrite(YN(User.UseCurentDate));
   RmGotoXY(77,7);  RmWrite(YN(User.Prescan));
   RmGotoXY(77,8);  RmWrite(YN(User.RepeatScan));
{  RmGotoXY(77,9);  RmWrite(YN(User.DownloadFiles));
   RmGotoXY(77,10); RmWrite(YN(User.AllowFileUpld));
   RmGotoXY(77,11); RmWrite(YN(User.AllowFileDown)); }
   RmSetColor(15,0);
  End;

  If Ansicolor = False Then Begin;
     RmWriteln('');
     RmWriteln('A. Inclure Page De Pr‚sentation.. '+YN(User.Welcome)     +'   H. Envoyer Les Informations User. '
       +YN(User.SendUserInf));
     RmWriteln('B. Inclure Les Bulletins......... '+YN(User.Bulletin)    +'   I. Utiliser Date/Heure Actuelle.. '
       +YN(User.UseCurentDate));
     RmWriteln('C. Inclure La Lettre Du SysOp.... '+YN(User.News)        +'   J. Prescan QWK Durant Une Event.. '
       +YN(User.Prescan));
     RmWriteln('D. Inclure Les Nouveaux Fichiers. '+YN(User.NewFiles)    +'   K. R‚p‚ter Prescan............... '
       +YN(User.UploadFiles));
     RmWriteln('E. Include La Page De Fin........ '+YN(User.Goodbye)  );{   +'  *L. Include Download Files Listing '
       +YN(User.DownloadFiles));                                                                                   }
     RmWriteln('F. Utiliser Un Petit CONTROL.DAT. '+YN(User.SmallControl));{+'  *M. Allow Attached File Upload.... '
       +YN(User.AllowFileUpld));                                                                                   }
     RmWriteln('G. Envoyez Les Fichiers NDX...... '+YN(User.NDXFiles)  );{  +'  *N. Allow Attached File Downloaded '
       +YN(User.AllowFileDown));                                                                                   }
  End;
 End;

If Choix = 1 Then
If Ansicolor = True Then Begin;
   RmSetcolor(11,0);
   RmGotoXY(36,5);  RmWrite(YN(User.Welcome));
   RmGotoXY(36,6);  RmWrite(YN(User.Bulletin));
   RmGotoXY(36,7);  RmWrite(YN(User.News));
   RmGotoXY(36,8);  RmWrite(YN(User.NewFiles));
   RmGotoXY(36,9);  RmWrite(YN(User.Goodbye));
   RmGotoXY(36,10); RmWrite(YN(User.SmallControl));
   RmGotoXY(36,11); RmWrite(YN(User.NDXFiles));
   RmGotoXY(77,5);  RmWrite(YN(User.SendUserInf));
   RmGotoXY(77,6);  RmWrite(YN(User.UseCurentDate));
   RmGotoXY(77,7);  RmWrite(YN(User.Prescan));
   RmGotoXY(77,8);  RmWrite(YN(User.RepeatScan));
{  RmGotoXY(77,9);  RmWrite(YN(User.DownloadFiles));
   RmGotoXY(77,10); RmWrite(YN(User.AllowFileUpld));
   RmGotoXY(77,11); RmWrite(YN(User.AllowFileDown)); }
   RmSetColor(15,0);
End;

End;
{$ENDIF}
{---------------------------------------------------------------------------}
Procedure OptionConfig;

VAR Fin        : Boolean;
    C          : Char;
Begin;

  Fin := False;

  VisuOption(0);

Repeat

 RmWriteln('');
 RmSetColor(15,0);
 If Ansicolor Then RmGotoXY(1,15);

{$IFDEF ENGLISH}
 RmWrite(' Option To Change (A-I), <Z> To Relist, <Q> To Quit (?=Help) : ');
{$ELSE}
 RmWrite(' Option A Changer (A-I), <Z> Relister, <Q> Pour Quitter (?=Aide) : ');
{$ENDIF}

 Repeat
   C := Upcase(Rmreadkey);
  Until C In ['A','B','C','D','E','F','G','H','I','J','K','Q','Z','?'];

 If AnsiColor = False Then RmWrite(C);

 Case C Of

       'A' : User.Welcome       := NOT User.WelCome;
       'B' : User.Bulletin      := NOT User.Bulletin;
       'C' : User.News          := NOT User.News;
       'D' : User.NewFiles      := NOT User.NewFiles;
       'E' : User.Goodbye       := NOT User.Goodbye;
       'F' : User.SmallControl  := NOT User.SmallControl;
       'G' : User.NDXFiles      := NOT User.NDXFiles;
       'H' : User.SendUserInf   := NOT User.SendUserInf;
       'I' : User.UseCurentDate := NOT User.UseCurentDate;
       'J' : User.Prescan       := NOT User.Prescan;
       'K' : User.RepeatScan    := NOT User.RepeatScan;
{       'L' : User.DownloadFiles := NOT User.DownloadFiles;
       'M' : User.AllowFileUpld := NOT User.AllowFileUpld;
       'N' : User.AllowFileDown := NOT User.AllowFileDown; }
       '?' : Begin;
              {$IFDEF ENGLISH}
              RmWriteln('Help');
              {$ELSE}
              RmWriteln('Aide');
              {$ENDIF}
              HelpOption;
              VisuOption(0);
             End;
       'Z' : VisuOption(0);
       'Q' : Fin := True;

 End;

 If AnsiColor Then  VisuOption(1);

Until Fin = True;

End;


END.