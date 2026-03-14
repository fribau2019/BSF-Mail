{$A+,B+,D+,E+,F+,G-,L+,N-,O-,R-,S-,V+,X+,I+}
{$M 16384,0,655360}
UNIT BSFCOMM;

{$I D:\SOURCE~1\PASCAL\NETMAIL\LANGAGE.DIR}
{--------------------------------------------------------------------------}
                                  Interface
{--------------------------------------------------------------------------}
USES Crt,
     Dos,
     Int,
     Fossil,
     BSFConst,
     BSFScrn,
     BSFUtils,         {Unit Test       - Fonctions Elementaires}
     BSFAnsi,          {Unit Ansi       - Display ANSI Type Form}
     BSFSwap;          {Unit SWAP       - Swap XMS/EMS/File }


Const
  _HangUp         : Boolean = False; {False = Bip}
  _Color          : Boolean = True; {Couleur Ou Mono}
  _MaxWindows     : Byte = 3;
  _Windows        : byte = 0;       {Choix De La Fenetre Stats}
  VideoMax        : Word = 25;      {Nombre De Colonne A L'Affichage}
  UseFossil       : Boolean = False;
  Register        = 800;
  Local           : Boolean = False;

Type
  Temps = Record
           Heure   : Shortint;
           Minute  : Integer;
           Seconde : ShortInt;
          End;


Var
  ConfigPathName  : String;     { Environnement Variable BSFMAIL}
  InforUser       : Boolean;

  phonenumber     :  string[20];{ Phone of user}
  seclevel        : integer;    { Security Of User}
  Username        : string[60]; { name of the user online     }
  userfirstname   : string[50]; { first name of the user online     }
  userbaudrate    : longint;    { Speed user connect}
  ansicolor       : boolean;    { True if caller use ANSI }
  callingfrom     :  string[60];{ User calling From}
  errorcorrecting : boolean;    { true if caller is in error correcting connection}
  lockedrate      : boolean;    { true if modem lock his port comm}

  SecondeLeft     :     Byte;    {Variable Seconde Pour Test Display}
  TotalTemps      :     Word;    {Temps Impartie Pour Cette Session}
  Teps            :    Temps;
  LastMinKey      :     Byte;    { Temps Clavier}
  minutesleft     :    Temps;    { Number of minute left to user}
  minuteson       :    Temps;    { Number of minute on to user}
  Tps             :    Temps;    { Heure D'arrive Du User Dans La Door}


  comport         :    byte;   { comm port 0-6 }
  baudrate        : LongInt;   { current connect speed }
  online          : boolean;   { whether it's a local/remote login }
  foreground      :    byte;   { foreground color, so you can check and change... }
  background      :    byte;   { background color so you can check and change... }
  stop            : boolean;   { variable used for some stop procedures. }
  modemonly       : boolean;   { if true then output will only be sent to the modem}
  localkey        : boolean;   { this boolean will be true when a key }
                               {  is pressed and it happend to be a }
                               {  local key, this makes it easier to }
                               {  support special sysop keys without }
                               {  having to rebuild several procedures }

function  softinit: boolean;   { will initialize the fossil, true if sucessful }
function  carrier : boolean;   {carrier on or off }

procedure rmclrscr;               {modem equivalent of clrscr}
procedure rmclreol;               {modem equivalent of clreol}
{function  rmdetectansi : Boolean; {Detect If remote has Ansi.Sys Support}
procedure rmgotoxy(x,y: byte);    {modem equivalent of gotoxy}
function  rmkeypressed: boolean;  {modem equivalent of keypressed}
procedure rmwrite(s: string);     {modem equivalent of write}
procedure rmwritei(s: integer);   {modem equivalent of write for an integer}
procedure rmwriteln(s: string);   {modem equivalent of writeln}
procedure rmsetcolor(f,b : byte); {color in fore and background}
procedure rmdisplayfile( fname : string; Pause : Boolean); {display a file with hotkeys in set hotkeys}
function  rmreadkey: char;        {modem equivalent of readkey}
function  rmreads : string; {read a word with max number of chars = len}
procedure rmhangup;               {hang up the modem!}

procedure autoansidetect;         {detect if remote has user.ansi support}
procedure purgeinbuffer;          {purge input buffer}
Function  DataAvailable : Boolean;

{other helpfull functions and procedures}

procedure trim(var s: string); {trim all leading and trailing #0 and #32}
function  byte_set(b,bit: byte): boolean; {checks to see if bit is set in b}
function  lz(w: word): string; {aka leading zero, adds a 0 before one digit numbers, handy for dates!                   }
procedure chat(full,direct: boolean); {inline fullscreen chatter. if full is   }
                                  {False, then it will go into normal mode, If
                                  {Direct is true, then it will not display the}
                                  {Chat reason (since there won't be one)      }
Procedure DisplayStat;            {show sysop status window}
{--------------------------------------------------------------------------}
                                 Implementation
{--------------------------------------------------------------------------}
var
  _countline  : boolean;
  _linecount  :    byte;
  _pausecount :    byte;
  _checktime  : boolean;

  promptcolor :    byte;
  timeoutmin,
  lastmin     :    byte;

{--------------------------------------------------------------------------}
Function FormatHeure(H, M, S, C : LongInt) : String;
Var SS : String;
Begin;

 If H < 10 Then SS := '0'       +IntToStr(H) Else SS :=           IntToStr(H);
 If M < 10 Then SS := SS+':'+'0'+IntToStr(M) Else SS := SS + ':' + IntToStr(M);
 If S < 10 Then SS := SS+':'+'0'+IntToStr(S) Else SS := SS + ':' + IntToStr(S);

 If C >= 1 Then Begin;
                 Delete(SS, 1, 3);
                 If Length(SS) = 5 Then SS := '0'+SS;
                End;

 FormatHeure := SS;
End;
{--------------------------------------------------------------------------}
Procedure FlushOutPut;
Begin;
 If Online Then
  If Comport > 0 Then
   If UseFossil Then F_FlushOutPut;
End;
{--------------------------------------------------------------------------}
Function DataAvailable : Boolean;
begin
  if usefossil then DataAvailable := F_DataAvailable
   else DataAvailable := I_DataAvailable;
end;
{--------------------------------------------------------------------------}
Function RmDetectAnsi : Boolean;
 Begin;
  ModemOnly := True;
  Ansicolor := false;
  RmWrite(#27+'[6n');
  RmWrite(rep(#08,4));
  If DataAvailable then
   Ansicolor := RmReadKey = 'R'
  Else
   Ansicolor := True;
  RmDetectAnsi := AnsiColor;
  If DataAvailable Then PurgeInBuffer;
  ModemOnly := False;
End;
{--------------------------------------------------------------------------}
Procedure RmSetColor(f,b : byte);
Begin;
 If AnsiColor = True Then
  Begin;
   RmWrite(BSFAnsi.AnsiColor(F, B));
   Delay(2);
   TextColor(F);
   TextBackGround(B);
  End;
End;
{--------------------------------------------------------------------------}
Procedure RmWritei(S : integer);
Begin;
 If UseFossil Then
  F_WritePort(IntToStr(S))
 Else
  I_WritePort(IntToStr(S));
 If Not ModemOnly Then Write(S);
End;
{--------------------------------------------------------------------------}
Function Carrier : Boolean;
Var Ok : Boolean;
Begin
  If Online Then
   If Not _Hangup Then
    Begin;
     If UseFossil Then Ok := F_Carrier
      Else Ok := I_Carrier;
     If Not Ok Then
      Begin;
       Write(^g);
       Writeln;
       {$IFDEF ENGLISH}
       Writeln(' þþþ LOST Of CARRIER Detected...');
       Writeln(' þþþ Returning To BBS...');
       {$ELSE}
       Writeln(' þþþ PERTE DE PORTEUSE D‚tect‚e...');
       Writeln(' þþþ Retour Au BBS...');
       {$ENDIF}
       Halt(1);
      End
    End
   Else
   Ok := True;
 Carrier := Ok;
End;
{--------------------------------------------------------------------------}
Procedure Displaystat;

Var X,Y: byte;

Begin
    If _Windows > _MaxWindows Then _Windows := 0;


    If ( (_Windows = 0) And (Not Local) ) Then
       Begin;
        x := wherex;
        y := wherey;
        window(1,VideoMax,80,VideoMax+1);
        If _Color Then
         Begin;
          textcolor(White);
          textbackground(Blue);
         End
        Else
         Begin;
          textcolor(Black);
          textbackground(White);
         End;
        gotoxy(1,1);
      {$IFDEF ENGLISH}
        write('Name : ',UserName);
        write(rep(' ',47-wherex));
        If Ansicolor Then Write(' [ANSI]') Else Write('[ASCII]');
        write(Rep(' ',62-wherex));
        Write('Time On   : '+FormatHeure(0, MinutesOn.Minute, MinutesOn.Seconde,1));
        clreol;
        gotoxy(1,2);
        write('Security Level : ',SecLevel);
        write(rep(' ',27-wherex));
        write('[F1] Change Menu');
        write(rep(' ',45-wherex));
        if Online Then Write('BaudRate : ',comport,':',userbaudrate)
         else write('(Local Mode)');
        write(rep(' ',62-wherex));
        write('Time Left : '+FormatHeure(0, MinutesLeft.Minute, MinutesLeft.Seconde,1));
        clreol;
        window(1,1,80,VideoMax-1);
        textattr := 7;
        gotoxy(x,y);
       {$ELSE}
        write('Nom : ',username);
        write(rep(' ',47-wherex));
        If Ansicolor Then Write(' [ANSI]') Else Write('[ASCII]');
        write(Rep(' ',57-wherex));
        Write('Temps Connect‚ : '+FormatHeure(0, MinutesOn.Minute, MinutesOn.Seconde,1));
        clreol;
        gotoxy(1,2);
        write('S‚curit‚ : ',SecLevel);
        write(rep(' ',19-wherex));
        write('[F1] Pour Changer');
        write(rep(' ',39-wherex));
        if Online Then Write('Vitesse : ',comport,':',userbaudrate)
         else write('(Mode Local)');
        write(rep(' ',57-wherex));
        write('Temps Restant  : '+FormatHeure(0, MinutesLeft.Minute, MinutesLeft.Seconde,1));
        clreol;
        window(1,1,80,VideoMax-1);
        textattr := 7;
        gotoxy(x,y);
       {$ENDIF}
       End;

    If ( (_Windows = 1) And (Not Local) ) Then
       Begin;
        x := wherex;
        y := wherey;
        window(1,VideoMax,80,VideoMax+1);
        If _Color Then
         Begin;
          textcolor(White);
          textbackground(Blue);
         End
        Else
         Begin;
          textcolor(Black);
          textbackground(White);
         End;
        gotoXY(1,1);
        clreol;
       {$IFDEF ENGLISH}
        Write(' [F1] Change Menu    [F2] Quit To BBS   [F3] Give 5 Min.   [F4] Take 5 Min.');
        gotoXY(1,2);
        clreol;
        Write(' [F5] Jump To DOS    [F6] Hang Up       [F10] Chat Mode');
       {$ELSE}
        Write(' [F1] Pour Changer   [F2] Retour Au BBS [F3] Donne 5 Min.  [F4] Prend 5 Min.');
        gotoXY(1,2);
        clreol;
        Write(' [F5] Aller Sous DOS [F6] Raccrocher    [F10] Discuter');
       {$ENDIF}
        window(1,1,80,VideoMax-1);
        textattr := 7;
        gotoxy(x,y);
       End;

    If ( (_Windows = 2) And (Not Local) ) Then
       Begin;
        x := wherex;
        y := wherey;
        window(1,VideoMax,80,VideoMax+1);
        If _Color Then
         Begin;
          textcolor(White);
          textbackground(Blue);
         End
        Else
         Begin;
          textcolor(Black);
          textbackground(White);
         End;
        gotoXY(1,1);
        clreol;
       {$IFDEF ENGLISH}
        Write('Msg D/U : ',User.NbMessDown,'/',User.NbMessUpld);
        Write(rep(' ',25-wherex));
        Write('Page SysOp : ',User.NbPageSysOp);
        Write(rep(' ',46-wherex));
        Write('Connect : ',User.NbConnection);
        Write(rep(' ',70-wherex));
        If User.Prescan Then Write('[PRESCAN]');
        gotoXY(1,2);
        clreol;
        Write('Packet D/U : ',User.NbDownPacket,'/',User.NbUpldPacket);
        Write(rep(' ',25-wherex));
        Write('Last QWK : ',User.LastQWKDate+' '+User.LastQWKTime);
        Write(rep(' ',69-wherex));
        If _Color Then TextColor(White+Blink) Else TextColor(Black+Blink);
        If User.NetStatus Then Write('[NETSTATUS]');
       {$ELSE}
        Write('Msg D/U : ',User.NbMessDown,'/',User.NbMessUpld);
        Write(rep(' ',25-wherex));
        Write('Appel SysOp : ',User.NbPageSysOp);
        Write(rep(' ',46-wherex));
        Write('Connect : ',User.NbConnection);
        Write(rep(' ',70-wherex));
        If User.Prescan Then Write('[PRESCAN]');
        gotoXY(1,2);
        clreol;
        Write('Packet D/U : ',User.NbDownPacket,'/',User.NbUpldPacket);
        Write(rep(' ',25-wherex));
        Write('Dernier QWK : ',User.LastQWKDate+' '+User.LastQWKTime);
        Write(rep(' ',69-wherex));
        If _Color Then TextColor(White+Blink) Else TextColor(Black+Blink);
        If User.NetStatus Then Write('[NETSTATUS]');
       {$ENDIF}
        window(1,1,80,VideoMax-1);
        textattr := 7;
        gotoxy(x,y);
       End;

End;
{--------------------------------------------------------------------------}
Procedure NoKeyboardActivity;
Var oldfore,oldback: byte;
  Begin
   Oldfore := Foreground;
   Oldback := Background;
   RmSetColor(12,0);
   Rmwriteln('');
   Rmwriteln('');
  {$IFDEF ENGLISH}
   Rmwriteln('Inactivity Time Keyboard Detected...');
   Rmwriteln('Please Call Back Later !');
  {$ELSE}
   Rmwriteln('Inactivit‚ Du Temps Clavier D‚tect‚e...');
   Rmwriteln('Veuillez Rappeler Plus Tard !');
  {$ENDIF}
   RmSetColor(OldFore, OldBack);
   RmHangup;
End;
{--------------------------------------------------------------------------}
Function lz(w: word): string; {Convertie Un Chiffre En String Avec 0 Si < 10}
 Var s: string;
  begin
    str(w,s);
    if length(s) < 2 then s := '0'+s;
    lz := s;
End;
{--------------------------------------------------------------------------}
Function byte_set(b,bit: byte): boolean;
  var v: byte;
  begin
    v := 1 shl bit;
    byte_set := v = v and b;
End;
{--------------------------------------------------------------------------}
procedure trim(var s: string);
  begin
    while (s[1] in [' ',#0]) do delete(s,1,1);
    while (s[length(s)] in [' ',#0]) do delete(s,length(s),1);
end;
{--------------------------------------------------------------------------}
procedure checkcarrier;
Var Ok : Boolean;
  begin
   if usefossil then Ok := f_Carrier
   else Ok := I_Carrier;
  if Ok = False then carrier;
end;
{--------------------------------------------------------------------------}
  procedure promptcontinue;
  var
    cnt: byte;
    s  : string;
    ch : char;
    oldf: byte;
    oldb: byte;

  begin
    oldf := foreground;
    oldb := background;
    RmSetColor(PromptColor, 0);
    rmwrite('More [Y/n]');
    ch := #255;
    repeat
      if rmkeypressed then ch := rmreadkey;
      ch := upcase(ch);
    until ch in [#13,'Y','N'];
    stop := ch = 'N';
    _linecount := 0;
    rmwrite(rep(#08,10)+rep(#32,10)+rep(#08,10));
    RmSetColor(Oldf, Oldb);
end;
{--------------------------------------------------------------------------}
procedure clickcounter;
  begin
    inc(_linecount);
    if _linecount = _pausecount then promptcontinue;
end;
{--------------------------------------------------------------------------}
Procedure rmwrite(s: string);
  Begin
   If Online Then
    If Comport > 0 Then
     If usefossil then F_WritePort(s)
     Else I_WritePort(s);
   If Not modemonly Then If AnsiColor Then BsfAnsi.AnsiWrite(S) Else Write(S);
End;
{--------------------------------------------------------------------------}
Procedure rmwriteln(s: string);
  begin
   If Online Then
    If Comport > 0 Then
     If usefossil then F_WritePort(s+#13#10)
      Else I_WritePort(s+#13#10);
   If Not ModemOnly Then If Ansicolor Then BSFAnsi.AnsiWriteln(s) Else WriteLn(S);
   If _countline then clickcounter;
End;
{--------------------------------------------------------------------------}
Procedure purgeinbuffer;
begin
  If Online Then
   If Comport > 0 Then
    If usefossil Then F_PurgeInput
    Else I_PurgeInput;
end;
{--------------------------------------------------------------------------}
Function portpressed: boolean;
 begin
    Portpressed := false;
    If Online Then
     If UseFossil Then
      PortPressed := F_DataAvailable
     Else
      PortPressed := I_DataAvailable;
End;
{--------------------------------------------------------------------------}
Procedure Jumptodos;  {Drop To DOS}
  var x,y: byte;
  begin
    y := wherey;
    x := wherex;
    rmsetcolor(15,0);
    rmwriteln('');
    TextColor(White);
    TextBackGround(Black);
    Window(1,VideoMax,80,VideoMax+1);
    GotoXY(1,1); ClrEol;
    GotoXY(1,2); ClrEol;
    OpenWindow(1,1,Hi(WindMax), Lo(WindMax));
    {$IFDEF ENGLISH}
    RmWriteLn('Sysop Is Jumping To DOS, Please Wait...');
    {$ELSE}
    RmWriteLn('Le Sysop Est Sous DOS, Merci D''attendre...');
    {$ENDIF}
    RmGotoXY(x,y);
    textattr := 7;
    Writeln;
    DosError := DosShell ('',
                          '',
                          USE_ALL,
                          $ffff,
                          false);
    CloseWindow;
    displaystat;
    rmgotoxy(x,y);
    rmsetcolor(15,0);
    rmwriteln('');
    {$IFDEF ENGLISH}
    rmwriteln('Sysop Has Returned, Thank You For Waiting.');
    {$ELSE}
    RmWriteLn('Le Sysop Est Revenu, Merci D''Avoir Attendu.');
    {$ENDIF}
    rmgotoxy(x,y);
    LastMinKey := 0;

End;
{--------------------------------------------------------------------------}
Procedure DiffTempsArrive(Var MinutesOn   : Temps;
                          Var MinutesLeft : Temps;
                          Var Teps        : Temps);
Var
  H, M, S, Hund       : Word;
  HH, MM, SS,
  Heure,  Min,  Sec   : LongInt;
  TTl, Temps1, Temps2 : LongInt;
Begin;
 GetTime(h,m,s,hund);

 TePS.Heure   := h;
 TePS.Minute  := M;
 TePS.Seconde := S;

 HH    := h;         MM    := m;           SS    := S;
 heure := Tps.Heure; Min   := Tps.Minute; Sec   := tps.Seconde;

 Temps1 := Heure*3600 + Min*60 + Sec;
 Temps2 := HH*3600 + MM*60 + SS;

 If Temps2 >= Temps1 Then TTl := Temps2 - Temps1
                     Else TTl := 86400 - Temps2 - Temps1;

 MinutesOn.Minute  := TTl Div 60;
 MinutesOn.Seconde := TTl Mod 60;

 MinutesLeft.Minute  := (TotalTemps*60-TTl) Div 60;
 MinutesLeft.Seconde := (TotalTemps*60-TTl) Mod 60;

End;
{--------------------------------------------------------------------------}
Procedure CheckTime;
Begin;
If _CheckTime Then
 Begin;
  DiffTempsArrive(MinutesOn, MinutesLeft, Teps);

  If SecondeLeft <> Teps.Seconde Then
   Begin;

    DisplayStat;
    Secondeleft := Teps.Seconde;

    Inc(LastMinKey);

  {V‚rification Temps}
     {Clock Clavier}
      If LastMinKey = 180 Then NoKeyboardActivity;
      If LastMinKey = 120 Then
       If InForUser = False Then
        Begin;
         InforUser  := True;
         RmWriteln('');
        {$IFDEF ENGLISH}
         RmWriteln(' You Have 1 Minute Left Before Log Off...');
        {$ELSE}
         RmWriteln(' Il Vous Reste 1 Minute Avant D''Etre D‚connect‚...');
        {$ENDIF}
       End;

     { Si le temps est nul}
      If _CheckTime Then
       If ( (MinutesLeft.Minute <= 0) And (MinutesLeft.Seconde <=0)) Then
        Begin;
         RmSetColor(12,0);
         RmWriteln('');
         RmWriteln('');
         {$IFDEF ENGLISH}
         RmWriteln(' þ Time Has Expired...Please, Call Back Tomorrow !');
         {$ELSE}
         RmWriteln(' þ Temps Expir‚... Merci De Rappeler Demain !');
         {$ENDIF}
         RmHangup;
        End;


  End;
 End;
End;
{--------------------------------------------------------------------------}
Function RmKeyPressed: boolean;
Begin

 If Online Then
  If Comport > 0 Then
   If UseFossil Then
    Begin;
     F_FlushOutPut;
     F_PurgeInput;
    End
   Else
    I_PurgeInput;

 CheckTime;

 RmKeyPressed := Keypressed Or Portpressed;
 LastMinKey := 0;
End;
{--------------------------------------------------------------------------}
Function rmreadkey: char;
 Var
    Ch         : Char;

 Begin

    Repeat
     CheckTime;
    Until Keypressed Or DataAvailable;

    If (Online and DataAvailable) then
     begin
      checkcarrier;
      if usefossil then Ch := F_readkeyfromport
      else Ch := I_Readkeyfromport;
      LocalKey := false;
     end
    else
     Begin;
       Ch := #255;
       Ch := ReadKey;
     If ch = #0 Then
      Begin;
       Ch := ReadKey;
       Case Ch Of
       {F1    : Change Screen Stat}
        #59 : Begin;
               Inc(_Windows);
               If _Windows > _MaxWindows-1 Then _Windows := 0;
               DisplayStat;
              End;
       {F2    : Quit To BBS}
        #60 : Begin;
               RmSetColor(14,0);
               RmWriteln('');
               RmWriteln('');
              {$IFDEF ENGLISH}
               RmWriteln(' þ Quit To BBS þ');
              {$ELSE}
               RmWriteln(' þ Retour Au BBS þ');
              {$ENDIF}
               RmWriteln('');
               Delay(100);
               Halt(0);
              End;
       {F3 : Increase Time}
        #61 : Begin;
               TotalTemps := TotalTemps + 5;
               _Windows := 0;
               DisplayStat;
              End;
       {F4 : Decrease Time}
        #62 : Begin;
               TotalTemps := TotalTemps - 5;
               If MinutesLeft.Minute <= 0 Then MinutesLeft.Minute := 0;
               _Windows := 0;
               DisplayStat;
              End;
       {F5    : Jump To DOS}
        #63 : JumpToDos;
       {F6    : HangUp }
        #64 : RmHangup;
       {F10    : Mode Chat}
        #68 : Chat(True, True);
       End;
        Ch := #00;
      End
       Else localKey := True;
   End;
 RmReadKey := Ch;
 LastMinKey := 0;
End;
{--------------------------------------------------------------------------}
Function RmReads : String;
 Var ch : char;
      s  : string;
  begin
    s := '';
    ch := #0;
    Repeat

     Ch := RmReadKey;

     If (ch = #08) and (length(s) > 0) then
       Begin
        Delete(s,length(s),1);
        RmWrite(#08#32#08);
       End;
      If ((ch <> #08) and (ch <> #13)   and
          (ch  > #31) and (ch  < #127)) then
       Begin
        s := s + ch;
        RmWrite(ch);
       End;
    until ch = #13;
  RmReads := s;
  LastMinKey := 0;
End;
{--------------------------------------------------------------------------}
procedure rmclrscr;
  Begin
    ModemOnly := true;
    If Ansicolor = true then
     Begin;
      RmWrite(BsfAnsi.ANSICLRSCR);
      ClrScr;
      FlushOutput;
     End
    Else
     Begin;
      RmWrite(#12);
      ClrScr;
     End;
    Modemonly := False;
    DisplayStat;
  end;
{--------------------------------------------------------------------------}
procedure rmclreol;
  begin
    modemonly := true;
    if ansicolor then
     Begin;
      Rmwrite(BsfAnsi.AnsiClrEol);
      Clreol;
     End;
    modemonly := false;
  end;
{--------------------------------------------------------------------------}
procedure autoansidetect;
  var
    ch :    char;
    j  : longint;

  begin
    FlushOutPut;
    ansicolor := false;
    If online then
     begin
      modemonly := true;
      rmwrite(#27+'[6n');
      rmwrite(rep(#08,4));
      Delay(50);
      modemonly := false;
      if portpressed then
       begin
        ch := rmreadkey;
        ansicolor := ch = 'R';
      end;
    end
    else ansicolor := False;
  If DataAvailable Then If RmKeypressed Then;
  end;
{--------------------------------------------------------------------------}
procedure rmgotoxy(x,y: byte);
  begin
    if not online then
     gotoxy(x,y)
    else
     if ansicolor then
      begin
      gotoxy(x,y);
      modemonly := true;
      rmwrite(BsfAnsi.AnsiGotoXY(x,y));
      Delay(2);
      modemonly := false;
    end
     else
      begin
       GotoXY(X,y);
       if y > wherey then rmwrite(rep(#10,wherey-y));
       if x > wherex then rmwrite(rep(#32,wherex-x));
       if x < wherex then rmwrite(rep(#08,x-wherex));
     end;
  end;
{--------------------------------------------------------------------------}
Procedure RmDisplayFile( FName : String; Pause : Boolean);
Var
 S  : String;
 F  : Text;

Begin
 If FName <> '' Then
  Begin
   Assign(F,FName);
   {$I-} Reset(F); {$I+}
   If IOResult = 0 then
    Begin
     ModemOnly := False;
     Repeat
      S := '';
      ReadLn(F,S);
      RmWriteLn(S);
     Until Eof(F);
     Close(F);
    End
   Else
   {$IFDEF ENGLISH}
    Writeln('Error: ',fname, ' Not Found !');
   {$ELSE}
    Writeln('Erreur : ',Fname, ' Non Trouv‚ !');
   {$ENDIF}
  End;
 Delay(100);
End;
{--------------------------------------------------------------------------}
Procedure RmHangUp;
Begin
 Begin;
 If Online Then
  If Comport > 0 Then
   If UseFossil then
    Begin;
     _Hangup := True;
     F_LowerDTR;
     If F_Carrier Then F_Hangup;
    End
   Else
    Begin;
     _Hangup := True;
     If I_Carrier Then I_Hangup;
    End
  Else
 Else
  Begin;
   RmSetColor(14,0);
   RmWriteln('');
   RmWriteln('');
  {$IFDEF ENGLISH}
   RmWriteln(' þ Quit To BBS þ');
  {$ELSE}
   RmWriteln(' þ Retour Au BBS þ');
  {$ENDIF}
   RmWriteln('');
  End;
 Delay(100);
 Halt(0);
 End;
End;
{--------------------------------------------------------------------------}
procedure chat(full,direct: boolean);
  const
    infocolor = 14;
    dsz    : string[4] = #24'B00';
    dszcnt : byte = 1;

  var
    sysopscreen   : array[2..11] of string[80];
    userscreen    : array[13..22] of string[80];
    normalline    : string[80];
    sysopx,sysopy :       byte;
    userx,usery   :       byte;
    ch            :       char;
    sysopchat     :       byte;
    userchat      :       byte;
    starttime     :    longint;
    endtime       :    longint;
    hour, min,
    sec, hund     :       word;
    chatlog       :       text;
    x,y           :       Byte;


    procedure scrollsysopscreen;
    var cnt: byte;
    begin
      for cnt := 2 to 6 do sysopscreen[cnt] := sysopscreen[cnt+5];
      for cnt := 7 to 11 do fillchar(
        sysopscreen[cnt], sizeof(sysopscreen[cnt]), 0
      );
      for cnt := 11 downto 2 do begin
        rmgotoxy(1,cnt);
        rmclreol;
        if cnt < 7 then rmwriteln(sysopscreen[cnt]);
      end;
      sysopy := 7;
    end;


    procedure wrapsysopscreen;
    var cnt: byte;
    begin
      cnt := 81;
      repeat
        dec(cnt);
      until (sysopscreen[sysopy-1][cnt] = #32) or (cnt = 1);
      if cnt > 1 then begin
        sysopscreen[sysopy] := copy(sysopscreen[sysopy-1],cnt+1,80-cnt);
        delete(sysopscreen[sysopy-1],cnt,80-cnt);
        rmgotoxy(cnt,sysopy-1);
        rmwrite(rep(#32,81-cnt));
        rmgotoxy(1,sysopy);
        rmwrite(sysopscreen[sysopy]);
      end;
    end;



    procedure scrolluserscreen;
    var cnt: byte;
    begin
      for cnt := 13 to 17 do userscreen[cnt] := userscreen[cnt+5];
      for cnt := 18 to 22 do fillchar(
        userscreen[cnt], sizeof(userscreen[cnt]), 0
      );
      for cnt := 22 downto 13 do begin
        rmgotoxy(1,cnt);
        rmclreol;
        if cnt < 18 then rmwriteln(userscreen[cnt]);
      end;
      usery := 18;
    end;



    procedure clearsysopscreen;
    var cnt : byte;
    begin
      for cnt := 2 to 11 do fillchar(
        sysopscreen[cnt], sizeof(sysopscreen[cnt]), 0
      );
      for cnt := 11 downto 2 do begin
        rmgotoxy(1,cnt);
        rmclreol;
      end;
      sysopy := 2;
    end;



    procedure clearuserscreen;
    var cnt : byte;
    begin
      for cnt := 13 to 22 do fillchar(
        userscreen[cnt], sizeof(userscreen[cnt]), 0
      );
      for cnt := 22 downto 13 do begin
        rmgotoxy(1,cnt);
        rmclreol;
      end;
      usery := 13;
    end;



    procedure wrapuserscreen;
    var cnt: byte;
    begin
      cnt := 81;
      repeat
        dec(cnt);
      until (userscreen[usery-1][cnt] = #32) or (cnt = 1);
      if cnt > 1 then begin
        userscreen[usery] := copy(userscreen[usery-1],cnt+1,80-cnt);
        delete(userscreen[usery-1],cnt,80-cnt);
        rmgotoxy(cnt,usery-1);
        rmwrite(rep(#32,81-cnt));
        rmgotoxy(1,usery);
        rmwrite(userscreen[usery]);
      end;
    end;



    procedure wordwrapnormal;
    var cnt: byte;
    begin
      cnt := 81;
      repeat
        dec(cnt);
      until (normalline[cnt] = #32) or (cnt = 1);
      if cnt > 1 then begin
        normalline := copy(normalline,cnt+1,80-cnt);
        rmgotoxy(cnt,WhereY);
        rmwrite(rep(#32,81-cnt));
        rmwrite(normalline);
      end;
    end;

    procedure redrawscreen(sysop: boolean);
    var cnt: byte;
    begin
      if sysop then
       begin
        modemonly := true;
        clrscr;
        textcolor(15);
        textbackground(1);
        clreol;
        write(#32+Config.sysopname);
        gotoxy(1,12);
        clreol;
        write(#32+username);
        gotoxy(1,23);
        clreol;
        textcolor(14);
        {$IFDEF ENGLISH}
        write('Press Ctrl + R to re-draw screen and Ctrl + W to clear your screen');
        {$ELSE}
        write('Pressez Ctrl+R Pour Raffraichir L''Ecran et Ctrl+W Pour Effacer Votre Ecran');
        {$ENDIF}
        textbackground(0); gotoxy(1,2); textcolor(14); gotoxy(1,2);
        for cnt := 2 to sysopy do writeln(sysopscreen[cnt]);
        textcolor(3); gotoxy(1,13);
        for cnt := 13 to usery do writeln(userscreen[cnt]);
      end else begin
        rmclrscr;
        RmSetcolor(15,1);
        rmclreol;
        rmwrite(#32+Config.sysopname);
        rmgotoxy(1,12);
        rmclreol;
        rmwrite(#32+username);
        rmgotoxy(1,23);
        rmclreol;
        RmSetcolor(14,1);
        {$IFDEF ENGLISH}
        rmwrite('Press Ctrl + R to re-draw screen and Ctrl + W to clear your screen');
        {$ELSE}
        Rmwrite('Pressez Ctrl+R Pour Raffraichir L''Ecran et Ctrl+W Pour Effacer Votre Ecran');
        {$ENDIF}
        RmSetColor(14,0);
        rmgotoxy(1,2);
        for cnt := 2 to sysopy do rmwriteln(sysopscreen[cnt]);
        RmSetColor(3,0);
        rmgotoxy(1,13);
        for cnt := 13 to usery do rmwriteln(userscreen[cnt]);
      end;
      if sysop then rmgotoxy(length(sysopscreen[sysopy])+1,sysopy) else
        rmgotoxy(length(userscreen[usery])+1,usery);
     end;

  begin
    gettime(hour,min,sec,hund);
    starttime := hour*60+min;
    displaystat;
    sysopchat := 14;
    userchat  := 3;
    ch := #255;
    RmsetColor(InfoColor, 0);

    if ansicolor and full then
     begin
      RmSetColor(15,0);
      rmclrscr;
      RmSetColor(15,1);
      rmclreol;
      rmwrite(#32+Config.sysopname+' (SysOp)');
      rmgotoxy(1,12);
      rmclreol;
      rmwrite(#32+username+' (User)');
      rmgotoxy(1,23);
      rmclreol;
      RmSetColor(14,1);
      {$IFDEF ENGLISH}
      RmWrite('Press <Ctrl+R> To Re-Draw Screen / <Ctrl+W> To Clear Your Screen / <Esc> To Quit');
      {$ELSE}
      RmWrite('<Ctrl+R> Raffraichir Ecran / <Ctrl+W> Effacer Ecran / <Esc> Pour Quitter');
      {$ENDIF}
      RmSetcolor(14,0);
      rmgotoxy(1,2);
      sysopy := 2;
      usery  := 13;
      fillchar(sysopscreen,sizeof(sysopscreen),0);
      fillchar(userscreen ,sizeof(userscreen) ,0);

      repeat

          ch := rmreadkey;

          if localkey then
           begin

            begin
              displaystat;

              if foreground <> sysopchat then RmSetColor(sysopchat,0);
               if ((wherex <> length(sysopscreen[sysopy])+1) or
                   (wherey <> sysopy))
                then rmgotoxy(length(sysopscreen[sysopy])+1,sysopy);

              if (ch = #08) then
               begin
                if ((length(sysopscreen[sysopy]) = 0) and (sysopy > 2))
                 then
                  begin
                   Dec(sysopy);
                   if length(sysopscreen[sysopy]) = 80 then
                   begin
                    rmgotoxy(80,sysopy);
                    rmwrite(#32);
                    rmgotoxy(80,sysopy);
                   end
                  else
                   begin
                    rmgotoxy(length(sysopscreen[sysopy])+1,sysopy);
                    delete(sysopscreen[sysopy],length(sysopscreen[sysopy]),1);
                    rmwrite(#08#32#08);
                   end;
                  end
                   else
                    if length(sysopscreen[sysopy]) > 0 then
                     begin
                      delete(sysopscreen[sysopy],length(sysopscreen[sysopy]),1);
                      rmwrite(#08#32#08);
                     end;
                 end;

              If (ch > #27) and (ch <> #255) then
               begin
                sysopscreen[sysopy] := sysopscreen[sysopy] + ch; rmwrite(ch);
                if length(sysopscreen[sysopy]) = 80 then
                 begin
                  if sysopy = 11 then scrollsysopscreen
                   else inc(sysopy);
                  if sysopscreen[sysopy-1][80] > #32 then wrapsysopscreen;
                 end;
               end;

               if ch = #23 then clearsysopscreen;
               if ch = #18 then redrawscreen(true);

               if ch = #25 then
                begin
                 sysopscreen[sysopy] := '';
                 rmgotoxy(1,sysopy);
                 rmclreol;
                end;

               if ch = #13 then
                begin
                 if sysopy = 11 then scrollsysopscreen
                  else inc(sysopy);
                 rmgotoxy(1,sysopy);
                end;
            end;
          end
           else
            begin

             if foreground <> userchat then RmSetColor(userchat,0);

             if ((WhereX <> length(userscreen[usery])+1) or (WhereY <> usery))
              then rmgotoxy(length(userscreen[usery])+1,usery);

             if (ch = #08) then
              begin
               if (length(userscreen[usery]) = 0) and (usery > 13) then
                 begin
                  dec(usery);
                  if length(userscreen[usery]) = 80 then
                   begin
                    rmgotoxy(80,usery);
                    rmwrite(#32);
                    rmgotoxy(80,usery);
                   end
                  else
                   begin
                    rmgotoxy(length(userscreen[usery])+1,usery);
                    delete(userscreen[usery],length(userscreen[usery]),1);
                    rmwrite(#08#32#08);
                   end;
                 end
               else
                 if length(userscreen[usery]) > 0 then
                  begin
                   delete(userscreen[usery],length(userscreen[usery]),1);
                   rmwrite(#08#32#08);
                  end;
              end;


             If ((ch <> #08) and (ch <> #13) and
                (ch > #27) and (ch <> #255)) then
                 begin
                  userscreen[usery] := userscreen[usery] + ch;
                  rmwrite(ch);

                  if length(userscreen[usery]) = 80 then
                   begin
                    if usery = 22 then scrolluserscreen
                     else inc(usery);
                    if userscreen[usery-1][80] > #32 then wrapuserscreen;
                   end;
                 end;

                 if ch = #13 then
                  begin
                   if usery = 22 then scrolluserscreen
                    else inc(usery);
                   rmgotoxy(1,usery);
                  end;

                 if ch = #18 then redrawscreen(false);
                 if ch = #23 then clearuserscreen;
                 if ch = #25 then
                  begin
                   userscreen[usery] := '';
                   rmgotoxy(1,usery);
                   rmclreol;
                  end;
                 if ch = #27 then ch := #255;
          end;
      until (ch = #27) and (localkey);
     ClrScr;
    End

  Else

(* Mode ASCII *)
    begin
     RmClrScr;
     Writeln('ESC To Quit !');
     {$IFDEF ENGLISH}
     rmwriteln('Hi '+username+', This Is Your Favorite SysOp.');
     {$ELSE}
     RmWriteln('Bonjour '+UserName+', C''est Votre SysOp Favori.');
     {$ENDIF}
     RmWriteln('');
     normalline := '';
     Repeat
        ch := rmreadkey;

        if localkey then
         if (foreground <> sysopchat) then RmsetColor(sysopchat,0)
          else
         if (foreground <> userchat) then RmSetColor(userchat,0);

        if (ch = #08) and (length(normalline) > 0) then
         begin
          delete(normalline,length(normalline),1);
          rmwrite(#08#32#08);
         end;

        if ((ch <> #08) and (ch <> #13) and
           (length(normalline) < 80)    and
           (ch > #31) and (ch < #127)) then
            begin
             normalline := normalline + ch;
             if length(normalline) = 80 then wordwrapnormal;
             rmwrite(ch);
            end;

        if (ch = #13) then
          begin
           rmwriteln('');
           normalline := '';
          end;

     until (ch = #27) and (localkey);
    RmClrScr;
  end;

    RmWriteLn('');
    {$IFDEF ENGLISH}
    RmWriteLn(' þ Chat Finished... Press <ENTER> Now !');
    {$ELSE}
    RmWriteLn(' þ Chat Finit... Pressez <ENTER> Maintenant !');
    {$ENDIF}
    LastMinKey := 0;
    Displaystat;
End;
{--------------------------------------------------------------------------}
function softinit: boolean;
{Var Cp : ComType;
    Bp : BaudType;}

Begin
  SoftInit := false;
  If Online Then
   If Comport > 0 Then
    Begin;
{
    Case Comport Of
     1 : Cp := com1;
     2 : Cp := com2;
     3 : Cp := com3;
     4 : Cp := com4;
     5 : Cp := com5;
     6 : Cp := com6;
    End;


    If BaudRate =   110 Then Bp := b110;
    If BaudRate =   150 Then Bp := b150;
    If BaudRate =   300 Then Bp := b300;
    If BaudRate =   600 Then Bp := b600;
    If BaudRate =  1200 Then Bp := b1200;
    If BaudRate =  2400 Then Bp := b2400;
    If BaudRate =  4800 Then Bp := b4800;
    If BaudRate =  9600 Then Bp := b9600;
    If BaudRate = 19200 Then Bp := b19200;
    If BaudRate = 38400 Then Bp := b38400;
    If BaudRate = 57600 Then Bp := b57600;
    If BaudRate =115200 Then Bp := b115200;
 }
  If Usefossil Then F_Initport(comport,baudrate,8,'N',1)
  {             Else I_Initport(cp,bp,d8,None,s1); }
               Else I_Initport(comport,baudrate,8,'N',1);
  If Usefossil Then Softinit := F_Porton(Comport)
               Else SoftInit := true;
    End
   Else
  Else SoftInit := True;
End;
{--------------------------------------------------------------------------}
Procedure DisplayResult;
Begin;
 TextColor(11);
 TextBackGround(0);
 Writeln('BSFMAIL For (C)Spitfire By Frederic Ribau - 1994/1995');

 Writeln;
 {$IFDEF ENGLISH}
 If Not Online Then Writeln(' þ Local Mode');
 If Online Then If UseFossil Then Writeln(' þ Fossil Driver Detected');
 If Online Then Writeln(' þ Comport  : ',Comport);
 If Online Then Writeln(' þ BaudRate : ',BaudRate);
 {$ELSE}
 If Not Online Then Writeln(' þ Mode Local');
 If Online Then If UseFossil Then Writeln(' þ Fossil Driver Detect‚');
 If Online Then Writeln(' þ Port Comm : ',Comport);
 If Online Then Writeln(' þ Vitesse : ',BaudRate);
 {$ENDIF}

End;
{--------------------------------------------------------------------------}
Function MAJ(S : String) : String;
Var F : Byte;
Begin;
For F := 1 to Length(s) do
  s[F] := UpCase(s[F]);
  MAJ := S;
End;
{-------------------------------------------------------------------------}
Procedure TempsArrive;
Var Hund : Word;
    H, M, S : Word;
begin
  GetTime(H,M,S,hund);
  Tps.Heure := H;
  Tps.Minute := M;
  Tps.Seconde := S;
end;
{-------------------------------------------------------------------------}
Procedure ConfigNoFound(Partie : Byte);
Begin;
 Writeln;
 Writeln('BSFMAIL For (C)Spitfire By Frederic Ribau - 1995');
 Writeln;
{$IFDEF ENGLISH}
 If Partie = 1 Then
  If Not Local Then Writeln('  þþþ '+Config.SfDir+'DOOR.SYS Not Found þþþ')
               Else Writeln('  þþþ '+Config.BsfMailDir+'DOOR.SYS Not Found þþþ')
 If Partie = 2 Then Writeln('  þþþ Environment BSFMAIL Not Found þþþ');
 If Partie = 3 Then Writeln('  þþþ Config '+ConfigPathName+' Not Found þþþ');
 If Partie = 4 Then Writeln('  þþþ '+Config.BSFMailDir+'DOOR.SYS Not Found þþþ');
{$ELSE}
 If Partie = 1 Then
  If Not Local Then Writeln('  þþþ '+Config.SfDir+'DOOR.SYS Non Trouv‚ þþþ')
               Else Writeln('  þþþ '+Config.BSFMailDir+'DOOR.SYS Non Trouv‚ þþþ');

 If Partie = 2 Then
                   Begin;
                    Writeln('  þþþ Variable D''Environnement BSFMAIL Non Trouv‚ þþþ');
                    Writeln;
                    Writeln('  Syntaxe : Set <Repertoire BSFMAIL>\<Nom du fichier config de BSFMAIL>');
                    Writeln;
                    Writeln('  Exemple : Set C:\BSFMAIL\BSFMAIL.CFG');
                   End;
 If Partie = 3 Then Writeln('  þþþ Configiration '+ConfigPathName+' Non Trouv‚ þþþ');
 If Partie = 4 Then Writeln('  þþþ '+Config.BSFMailDir+'DOOR.SYS Non Trouv‚ þþþ');
{$ENDIF}
 Write(^g);
 Delay(1500);
End;
{--------------------------------------------------------------------------}
Procedure ReadDoorSys;
Var  F : Text;
     S : String;
     I : Integer;

Begin;
 Local := False;

 If POS('LOCAL'   , MAJ(ParamStr(1))) > 0 Then Local := True;
 If POS('DOWNLOAD', MAJ(ParamStr(1))) > 0 Then Local := True;
 If POS('UPLOAD'  , MAJ(ParamStr(1))) > 0 Then Local := True;
 If POS('PRESCAN' , MAJ(ParamStr(1))) > 0 Then Local := True;
 If POS('VERIFY'  , MAJ(ParamStr(1))) > 0 Then Local := True;

 If Not Local Then
  If FileExists(Config.SFDir+'DOOR.SYS') = false Then
  Begin;
   ConfigNoFound(1);
   Halt(1);
  End
 Else
 Else
   If FileExists(Config.BSFMailDir+'DOOR.SYS') = false Then
  Begin;
   Writeln(Config.BSFMAILDir);
   Delay(15);

   ConfigNoFound(1);
   Halt(4);
  End;

 If Not Local Then Assign(f,Config.SFDir+'DOOR.SYS');
 If     Local Then Assign(f,Config.BSFMailDir+'DOOR.SYS');
 Reset(f);
 Readln(f,s); comport := StrToInt(copy(s, 4, 1));
  If Comport = 0 Then Online := False;
 Readln(f,s); userbaudrate := StrToInt(s);
 Readln(f);   readln(f);
 Readln(f,s); baudrate := StrToInt(S);
 Readln(f);   readln(f); readln(f); readln(f);
 Readln(f,s); username := s;
 Readln(f,s); callingfrom := s;
 Readln(f,s); phonenumber := s;
 Readln(f);   readln(f);
 Readln(f,s); seclevel := StrToInt(s);
 Readln(f);
 Readln(f);
 Readln(f);
 Readln(f,s); MinutesLeft.Minute := StrToInt(S);
 Readln(F,s); If POS(MAJ(S),'GR') > 0 Then AnsiColor := True Else AnsiColor := False;
 Close(f);
end;
{--------------------------------------------------------------------------}
Procedure ReadConfig;
TYPE
(* SFSYSTEM.DAT *)
SysRec        = Record
                  NoInputTime   : Byte;
                  CallsToday,
                  MsgToday,
                  UpToday,
                  DownToday,
                  DailyLimit,
                  DailyLogons,
                  LogonLimit,
                  SysopSecurity,
                  NUS,
                  NUTL          : Word;
                  UpDskSpace    : LongInt;
                  MaxUsers      : Word;
                  FileDescAmt   : Byte;
                  SrchRomSFFILE : Boolean;
                  DoorsAmt      : Integer;
                  Callernum     : LongInt;
                  LastDate      : String[8];
                  StartDate     : String[18];
                  DOSPassword   : String[28];
                  SysopName,
                  SysMsgName    : String[30];
                  USPhone,
                  ConvertDesc,
                  HeySysop,
                  AddUpedBy,
                  CommentQue    : Boolean;
                  NumberOfNodes,
                  NUCallers2Day : Byte;
                  BootUpTests,
                  ScanAllMsg,
                  OfferDefault  : Boolean;
                  ViolationSec  : Integer;
                  NUBirthDate,
                  CompFileSrch,
                  DrRetPassword,
                  RIPAvailable,
                  UseIntl       : Boolean;
                  ExtraBytes    : Array[0..84] Of Byte;
                End;

(* SFNODE.DAT *)
  NodeSysRec    = Record
                            DirectScrn,
                            ShowResult    : Boolean;
                            RamDrive      : Char;
                            PrinterOn,
                            AnsiAvl,
                            Private,
                            SecondPassword,
                            Page_On       : Boolean;
                            MinimumBaud   : Word;
                            MsgInfo,
                            NewFileInfo,
                            SoftControl,
                            AvailableBoo  : Boolean;
                            CorrectionMsg : String[3];
                            WorkPath,
                            DisplayPath,
                            ExtranPath,
                            MsgPath       : String[28];
                            ModInitStr    : String[56];
                            ComPort       : Word;
                            RingNo,
                            Node          : Byte;
                            MaxBaud,
                            ExtraLong     : LongInt;
                            TimeComp      : Real;
                            LastDate      : String[8];
                            PrivateSec    : Integer;
                            HangUpDelay   : Byte;
                            UseHiSpeed,
                            AvailBoolean  : Boolean;
                            IRQ1,
                            IRQ2,
                            IRQ3,
                            IRQ4,
                            IRQ5,
                            IRQ6,
                            IRQ7,
                            IRQ8          : Byte;
                            BreakLen      : Word;
                            FaxConnectMsg : String[7];
                            PreInitStr    : String[6];
                            SubChgSec     : Word;
                            StartWarn     : Byte;
                            ExtraBytes    : Array[0..3] Of Byte;
                            ColorMonitor  : Boolean;
                            OffHookStr    : String[6];
                            ComBase       : Array[1..8] Of Word;
                            AnswerStr     : String[30];
                            NewExtra      : Array[0..201] Of Byte;
End;

Var  F          : Text;
     S          : String;
     MNode      : NodeSysRec;
     MNodeF     : File Of NodeSysRec;
     SNode      : SysRec;
     SNodeF     : File Of SysRec;

Begin;


 ConfigPathName := '';
 Swapvectors;
  ConfigPathName := GetEnv('BSFMAIL');
 Swapvectors;

 If ConfigPathName = '' Then Begin;
                              ConfigNoFound(2);
                              Halt(1);
                             End;

 If FileExists(ConfigPathName) = False Then Begin;
                                             ConfigNoFound(3);
                                             Halt(1);
                                            End;

 Assign(F, ConfigPathName);
 Reset(F);
 ReadLn(f,s); If Copy(S, Length(s), 1) <> '\' then S := S + '\'; Config.BSFMailDir := S;
 ReadLn(f,s); Config.BBSName    := S;
 ReadLn(f,s); Config.BBSID      := S;
 ReadLn(f,s); Config.BBSCity    := S;
 ReadLn(f,s); Config.BBSPhone   := S;
 ReadLn(f,s); If Copy(S, Length(s), 1) <> '\' then S := S + '\'; Config.LocalQWK := S;
 ReadLn(f,s); Config.WelcomeDir := S;
 ReadLn(f,s); Config.NewsDir    := S;
 ReadLn(f,s); Config.GoodbyeDir := S;
 ReadLn(f,s); If MAJ(Copy(S, 1, 1)) = 'Y' Then Config.AddFiles := True Else Config.AddFiles := False;
 ReadLn(f,s); If MAJ(Copy(S, 1, 1)) = 'Y' Then Config.Goodbye  := True Else Config.Goodbye  := False;
 ReadLn(f,s); Config.PathLog    := S;
 ReadLn(f,s); If Copy(S, Length(s), 1) <> '\' then S := S + '\'; Config.SFDir := S;
 ReadLn(f,s); If Copy(S, Length(s), 1) <> '\' then S := S + '\'; Config.PrescanDir := S;
 Close(f);

 {Lecture Du SFNODE.DAT}
 Assign(MNodeF, Config.SfDir+'SFNODE.DAT');
 {$I-} Reset(MnodeF); {$I+}
 If Ioresult <> 0 Then
  Begin;
   Writeln;
  {$IFDEF ENGLISH}
   Writeln('Unable to Find File : ' + Config.SfDir+'SFNODE.DAT');
  {$ELSE}
   Writeln('Impossible De Trouver Le Fichier : '+ Config.SfDir+'SFNODE.DAT');
  {$ENDIF}
   Writeln;
   Write(^g);
   Halt(1);
  End;

 Seek(MnodeF, 0);
 Read(MnodeF, Mnode);
 Config.BaudComm   := Mnode.MaxBaud;
 Config.WorkDir    := Mnode.WorkPath;
 Config.MsgDir     := Mnode.MsgPath;
 Config.DisplayDir := Mnode.DisplayPath;
 Close(MnodeF);

 {Lecture Du SFSYSTEM.DAT}
 Assign(SNodeF, Config.WorkDir+'SFSYSTEM.DAT');
 {$I-} Reset(SNodeF); {$I+}
 If Ioresult <> 0 Then
  Begin;
   Writeln;
  {$IFDEF ENGLISH}
   Writeln('Unable to Find File : '+ Config.WorkDir+'SFSYSTEM.DAT');
  {$ELSE}
   Writeln('Impossible De Trouver Le Fichier : '+ Config.WorkDir+'SFSYSTEM.DAT');
  {$ENDIF}
   Writeln;
   Write(^g);
   Halt(1);
  End;
 Seek(SNodeF, 0);
 Read(SNodeF, SNode);
  Config.SysOpLevel := SNode.SysOpSecurity;
  Config.SysOpName  := SNode.SysMsgName;
 Close(SNodeF);

 ReadDoorSys;
end;
{--------------------------------------------------------------------------}
{--------------------------------------------------------------------------}
{--------------------------------------------------------------------------}
{--------------------------------------------------------------------------}
{--------------------------------------------------------------------------}
{--------------------------------------------------------------------------}
{--------------------------------------------------------------------------}
{--------------------------------------------------------------------------}
{--------------------------------------------------------------------------}
{--------------------------------------------------------------------------}
{--------------------------------------------------------------------------}
{--------------------------------------------------------------------------}
Begin;
  If LastMode = Mono Then _Color := False Else _Color := True;
  VideoMax := Hi(WindMax);
  foreground  :=    15;
  background  :=     0;
  modemonly   := false;
  _CheckTime  := True;
  _windows    :=     0;
  _countline  := False;
  _linecount  :=     0;
  _pausecount :=     0;
  stop        := False;
  timeoutmin  :=     1;
  comport     :=     2;
  LastMinKey  :=     0;
  online      :=  True;
  fillchar(Config.sysopname,sizeof(Config.sysopname),#0);
  ClrScr;
  ReadConfig;
  TempsArrive;
  UseFOSSIL := F_FossilPresent;
  SoftInit;
  If ParamCount > 0 Then Local := True;
  If Online Then _Checktime:= True Else _CheckTime := False;
  TotalTemps := MinutesLeft.Minute;
  DisplayResult;
  DisplayStat;
END.
