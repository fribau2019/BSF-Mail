UNIT BSFMnscn;

{$I LANGAGE.DIR}

Interface

 Procedure AfficheMenuMainNormal;
 Procedure DisplayWelcome(Rec : Integer);

Implementation

 Uses BSFCOMM,
      BSFConst;

Procedure AfficheMenuMainNormal;
Begin;
RmSetColor(14,0);
RmWriteln('                   ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
RmWriteln('                   ³  ÒÄ¿   ÖÄ¿ ÒÄÄ¿  ÖÄÒÄ¿ ÖÄÄ¿ ÄÒÄ Ò    ³');
RmWriteln('                   ³  ÇÄÁ¿  ÓÄ¿ ÇÄ    º º ³ ÇÄÄ´  º  º    ³');
RmWriteln('                   ³  ĞÄÄÙ ÓÄÄÙ Ğ     Ğ Ğ Á Ğ  Á ÄĞÄ ĞÄÄÙ ³');
RmWriteln('                   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
RmSetColor(11,0);
RmWriteln('');
{$IFDEF ENGLISH}
RmWriteln('      [D] Download Message Packet        [O] Configuration');
RmWriteln('      [U] Upload Message Packet          [C] Compression');
RmWriteln('      [Y] Your Personal Mail             [P] Transfer Protocol');
RmWriteln('      [M] Graphic Mode On/Off            [S] Select Conferences');
RmWriteln('      [X] Expert Mode On/Off             [R] Upload Your Pointers');
RmWriteln('      [G] Log Off                        [T] Size Of Packet');
RmWriteln('      [Q] Quit To BBS ');
{                  *[L] Choose your language');}
{RmWriteln('     *[A] Page The SysOp                ');
 RmWriteln('     *[W] The Last Documentation        ');}
{$ELSE}
RmWriteln('      [D] Download Des Messages          [O] Configuration');
RmWriteln('      [Y] Download Messages Personnels   [P] Protocole De Tranfert');
RmWriteln('      [U] Upload Des Messages            [C] Mode De Compression');
RmWriteln('      [M] Mode Graphique On/Off          [S] S‚lection Des Conf‚rences');
RmWriteln('      [X] Mode Expert On/Off             [R] Upload Pointeurs');
RmWriteln('      [G] D‚connection                   [T] Taille Des Paquets');
RmWriteln('      [Q] Retour Au BBS ');
{                  *[L] Choose your language');}
{RmWriteln('     *[A] Page The SysOp                ');
 RmWriteln('     *[W] The Last Documentation        ');}
{$ENDIF}

End;
{---------------------------------------------------------------------------}
Procedure DisplayWelcome(Rec : Integer);
Begin
  rmclrscr;
  rmsetcolor(15,0);
  rmwriteln('BSF-Mail Version '+Version);
  rmsetcolor(14,0);
  rmwriteln('Copyright (c) 1994 By Frederic Ribau');
  RmSetColor(11,0);
{$IFDEF REGISTERED}
 {$IFDEF ENGLISH}
   RmWriteln('Registered To : '+RegistrationN+' - '+RegistrationR);
   rmsetcolor(12,0);
   rmwriteln('Last Compilation : '+cdate+' a '+ctime);
 {$ELSE}
   RmWriteln('Enregistr‚ A : '+RegistrationN+' - '+RegistrationR);
   rmsetcolor(12,0);
   rmwriteln('DerniŠre Compilation : '+cdate+' … '+ctime);
 {$ENDIF}
{$ELSE}
 {$IFDEF ENGLISH}
   RmWriteln('UNREGISTERED To : '+RegistrationN+' - '+RegistrationR);
   rmsetcolor(12,0);
   rmwriteln('Last Compilation : '+cdate+' a '+ctime);
 {$ELSE}
   RmWriteln('NON ENREGISTRE A : '+RegistrationN+' - '+RegistrationR);
   rmsetcolor(12,0);
   rmwriteln('DerniŠre Compilation : '+cdate+' … '+ctime);
 {$ENDIF}
{$ENDIF}
  RmSetColor(15,0);
End;
{---------------------------------------------------------------------------}
End.