UNIT BSFSize;


{$I LANGAGE.DIR}


Interface

 Procedure Size;

Implementation
 Uses BSFCOMM,
      BSFUtils,
      BSFConst;



Procedure Size;
VAR
    Fin        : Boolean;
    C          : Char;
    Ligne      : String;

 Begin;


 Repeat
 Fin := False;

  RmClrscr;
  RmSetColor(14,0);
 {$IFDEF ENGLISH}
  RmWriteln('                            SIZE CONFIGURATION');
  RmSetcolor(11,0);
  RmWriteln('');
  RmWriteln('');
  RmWriteln('');
  RmWriteln(' Your Config At This Time Is :');
  RmWriteln('');
  Rmwriteln('   A... Maximum Messages Per Conference : '+IntToStr(User.NbMailConf));
  RmWriteln('   B... Maximum Messages Per Packet     : '+IntToStr(User.NbMailTTle));
  RmWriteln('');
  RmWriteln('');
  RmWriteln(' (0 For Unlimited Messages)');
  RmWriteln('');
  RmWriteln('');
  RmWriteln('');
  RmWrite(' Key (A or B) To Change, <ENTER> To Quit : ');
 {$ELSE}
  RmWriteln('                   CONFIGURATION DE LA TAILLE DES MESSAGES/PAQUETS');
  RmSetcolor(11,0);
  RmWriteln('');
  RmWriteln('');
  RmWriteln('');
  RmWriteln(' Votre Configuration Actuelle Est :');
  RmWriteln('');
  Rmwriteln('   A... Maximum Messages Par Conf‚rence : '+IntToStr(User.NbMailConf));
  RmWriteln('   B... Maximum Messages Par Paquet     : '+IntToStr(User.NbMailTTle));
  RmWriteln('');
  RmWriteln('');
  RmWriteln(' (0 Pour Messages Illimit‚s)');
  RmWriteln('');
  RmWriteln('');
  RmWriteln('');
  RmWrite(' Lettre (A ou B) Pour Changer, <ENTER> Pour Quitter : ');
 {$ENDIF}

  Repeat
   C := Upcase(RmReadKey);
  Until (((C >= 'A') And (C <= 'B') Or (C = #13))) ;

  Case C Of

   'A' : Begin;
          RmWriteln('');
          RmWriteln('');
         {$IFDEF ENGLISH}
          RmWrite(' Maximum Messages Per Conference : ');
         {$ELSE}
          RmWrite(' Maximum Messages Par Conf‚rence : ');
         {$ENDIF}
          Ligne := RmReadS;
          If Ligne <> '' Then Begin;
          User.NbMailConf := StrToInt(Ligne);
          If User.NbMailConf < 0 Then User.NbMailConf := 0;
          If User.NbMailTTle > 0 Then If User.NbMailConf > User.NbMailTTle Then User.NbMailConf := User.NbMailTTle;
          End;
         End;

   'B' : Begin;
          RmWriteln('');
          RmWriteln('');
         {$IFDEF ENGLISH}
          RmWrite(' Maximum Messages Per Packet : ');
         {$ELSE}
          RmWrite(' Maximum Messages Par Paquet : ');
         {$ENDIF}
          Ligne := RmReadS;
          If Ligne <> '' Then Begin;
          User.NbMailTTle := StrToInt(Ligne);
          If User.NbMailTTle < 0 Then User.NbMailConf := 0;
          If User.NbMailTTle > 0 Then If User.NbMailConf > User.NbMailTTle Then User.NbMailTTle := User.NbMailConf;
          End;
         End;
   #13 : Fin := True;
  End;
 Until Fin = True;

End;
END.

