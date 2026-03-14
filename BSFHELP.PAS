UNIT BSFHELP;

{$I LANGAGE.DIR}

Interface

  Procedure Help(Main : Char; Second : Char);
  Procedure HelpMain;
  Procedure HelpOption;
  Procedure HelpConference;

Implementation

Uses BSFComm,
     BSFUtils,
     BSFConst,
     Dos,
     Crt;

CONST MsgFileName : String = 'BSFMAIL.HLP';

TYPE
  HelpMess = Record
              OptMan : Char;
              OptSec : Char;
              NbOfLn : Byte;
              Entete : String[60];
              Msg    : Array[1..15] Of String[72];
             End;
Var Hp  : HelpMess;
    Hlp : File Of HelpMess;


{--------------------------------------------------------------------------}
Procedure Help(Main : Char; Second : Char);
Var Rec    : Byte;
    Trouve : Boolean;
Begin;

 Assign(Hlp,Config.BSFMailDir+MsgFileName);
 Reset(Hlp);
 Trouve := False;
 Rec := 0;
 Repeat
  Seek(Hlp, Rec);
  Read(Hlp, Hp);
  If ( (Hp.OptMan = Upcase(Main)) And (Hp.OptSec = Upcase(Second)) ) Then Trouve := True
   Else Inc(Rec);
 Until ( Trouve Or (Rec >= FileSize(Hlp)));

 If Not Trouve Then
   Begin;
    RmWriteln('');
    RmWriteln('');
   {$IFDEF ENGLISH}
    RmWriteln(' þþþ This Help Is Not Available þþþ');
   {$ELSE}
    RmWriteln(' þþþ Cette Aide N''Est Pas Disponible þþþ');
   {$ENDIF}
    Delay(1500);
    Exit;
   End;

 If Trouve Then
  Begin;
   RmSetColor(14,0);
   RmWriteln(RTrim(Hp.Entete,' ')+' ');
   RmSetColor(11,0);
   RmWriteln('');

   For Rec := 1 To Hp.NbOfLn Do RmWriteln('  '+Hp.Msg[Rec]);

   RmWriteln('');
   RmSetColor(15,0);
   RmWrite(' <Enter> ');
   RmReadKey;
  End;
  Close(Hlp);
End;
{---------------------------------------------------------------------------}
Procedure HelpMain;
Var C : Char;
Begin;
 RmWriteln('');
  If Not FileExists(Config.BSFMailDir+MsgFileName) Then
   Begin;
    RmWriteln('');
   {$IFDEF ENGLISH}
    RmWriteln(' þþþ Help Not Available þþþ');
   {$ELSE}
    RmWriteln(' þþþ Aide Non Disponible þþþ');
   {$ENDIF}
    Delay(1500);
    Exit;
   End;

{$IFDEF ENGLISH}
 RmWrite(' Help On Which Command ? : ');
{$ELSE}
 RmWrite(' Aide Sur Quelle Commande ? : ');
{$ENDIF}

 Repeat
  C := Upcase(RmReadKey);
 Until C In ['D','U','Y','M','X','G','Q','O','C','P','S','R','T',#13];

 If C <> #13 Then Help('M', C);
End;
{---------------------------------------------------------------------------}
Procedure HelpOption;
Var C : Char;
Begin;
 RmWriteln('');
  If Not FileExists(Config.BSFMailDir+MsgFileName) Then
   Begin;
    RmWriteln('');
   {$IFDEF ENGLISH}
    RmWriteln(' þþþ Help Not Available þþþ');
   {$ELSE}
    RmWriteln(' þþþ Aide Non Disponible þþþ');
   {$ENDIF}
    Delay(1500);
    Exit;
   End;

{$IFDEF ENGLISH}
 RmWrite(' Help On Which Command ? : ');
{$ELSE}
 RmWrite(' Aide Sur Quelle Commande ? : ');
{$ENDIF}

 Repeat
  C := Upcase(RmReadKey);
 Until C In ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','Q',#13];

 If C <> #13 Then Help('O', C);
End;
{---------------------------------------------------------------------------}
Procedure HelpConference;
Var S : String;
    Rec    : Byte;
    Trouve : Boolean;
    Page   : Byte;

Begin;
 RmWriteln('');
  If Not FileExists(Config.BSFMailDir+MsgFileName) Then
   Begin;
    RmWriteln('');
   {$IFDEF ENGLISH}
    RmWriteln(' þþþ Help Not Available þþþ');
   {$ELSE}
    RmWriteln(' þþþ Aide Non Disponible þþþ');
   {$ENDIF}
    Delay(1500);
    Exit;
   End;


 Assign(Hlp,Config.BSFMailDir+MsgFileName);
 Reset(Hlp);
 Trouve := False;
 Rec := 0;
 Repeat
  Seek(Hlp, Rec);
  Read(Hlp, Hp);
  If Hp.OptMan = 'S'Then Trouve := True
   Else Inc(Rec);
 Until ( Trouve Or (Rec >= FileSize(Hlp)));

 If Not Trouve Then
   Begin;
    Close(Hlp);
    RmWriteln('');
    RmWriteln('');
   {$IFDEF ENGLISH}
    RmWriteln(' þþþ This Help Is Not Available þþþ');
   {$ELSE}
    RmWriteln(' þþþ Cette Aide N''Est Pas Disponible þþþ');
   {$ENDIF}
    Delay(1500);
    Exit;
   End;

 If Trouve Then
  Begin;
   Page := StrToInt(Hp.OptSec);
   Repeat
    S := IntToStr(Page);
    Help('S', S[1]);
    Dec(Page);
   Until Page <= 1;
  End;

End;
{---------------------------------------------------------------------------}
End.


