UNIT BSFConst;
{$I D:\SOURCE~1\PASCAL\NETMAIL\LANGAGE.DIR}


Interface


CONST
 Register      = 800;
 MGRReg        = '1.009';
 Version       = '1.00á09';
 Blanc         = '                                                                                                          ';
 CDATE         = '10/04/1996';
 DDATE         = '04/1996';
 CTIME         = '00:00';


{$IFDEF UNREGISTERED}
 {$IFDEF ENGLISH}
  RegistrationR = 'UNREGISTERED';
  RegistrationN : String = 'UNREGISTERED';
 {$ELSE}
  RegistrationR = 'NON ENREGISTRE';
  RegistrationN : String = 'NON ENREGISTRE';
 {$ENDIF}
{$ELSE}
 {$IFDEF BSF01}
  RegistrationR = 'BSF00001';
  RegistrationN = 'Frederic Ribau * Developer Of BSFMail';
 {$ELSE}
 {$IFDEF BSF02}
  RegistrationR = 'BSF00002';
  RegistrationN = 'OUT-TIME * Official Tester';
 {$ELSE}
 {$IFDEF BSF03}
  RegistrationR = 'BSF00003';
  RegistrationN = 'HILL-VALLEY * Official Tester';
 {$ENDIF}
 {$ENDIF}
 {$ENDIF}
{$ENDIF}

 MessageHeader : String[128] =
  'BSFMail Version '+Version+' / QWK-Compatible Mail Generated For Spitfire 3.5x By Frederic Ribau (JOSHUA '+
  'Software Corporation)     ';

Type
(* SFUSERS.DAT *)
UserDefaults  = (HotKey,Reserved,Pause);
UsersSF       = Record
                  UserName,
                  CallingFrom      : String[30];
                  Password,
                  TimeDate         : String[14];
                  PhoneNumber      : String[12];
                  BirthDate        : String[8];
                  SecurityLevel    : Integer;
                  Uploads,
                  Downloads,
                  TotalUK,
                  TotalDK          : LongInt;
                  TimesOn,
                  TimeLeft,
                  Last_M_Conf,
                  Last_F_Area,
                  TransPro         : Integer;
                  Defaults         : Set Of UserDefaults;
                  FirstLogDate     : String[8];
                  SubscriptionDate : LongInt;
                  ConfQueue        : Array[0..97] Of Byte;
                  QWK_BBS_ID       : String[8];
                  AllowPurge,
                  BadLastOff,
                  ScrollBack,
                  Xpert,
                  LockedOut,
                  Deleted          : Boolean;
                  Linelen,
                  Pagelen,
                  OnToday,
                  Illegal,
                  DLToday,
                  ForeGround,
                  FreeDLToday      : Byte;
                  ChatsAllowed     : Byte;
                  DLBytes          : LongInt;
                  NewFCheck        : String[8];
                  OrgSecurity      : Integer;
                  ChatsUsed,
                  ExtraByte        : Byte;
                  FileStr          : String[12];
                  FileArea         : Word;
                  DeleteFile       : Boolean;
                  MsgsLeft         : Word;
                  Extra            : Array[1..3] Of Byte;
                End;

  Conference = Record
                   Attribut : Array[0..Register] Of Byte;
               End;

{$I BSFUSERS.LST}

(* NETMAIL.CFG *)
       ConfigurationDoor = RECORD
                        BSFMailDir  : String[60];  {Config : #1  : Directorie De BSFMAIL}
                        BBSName     : String[30];  {Config : #2  : Nom Du BBS}
                        BBSID       : String[08];  {Config : #3  : ID Du BBS}
                        BBSCity     : String[30];  {Config : #4  : Ville Du BBS}
                        BBSPhone    : String[30];  {Config : #5  : Phone Du BBS}
                        LocalQWK    : String[60];  {Config : #6  : Repertoire QWK/REP}
                        WelcomeDir  : String[60];  {Config : #7  : Nom Et Dir Du Welcome}
                        NewsDir     : String[60];  {Config : #8  : Nom Et Dir De la lettre}
                        GoodByeDir  : String[60];  {Config : #9  : Nom Et Dir Du GoodBye}
                        AddFiles    : Boolean;     {Config : #10 : Ajouter New Files ?}
                        GoodBye     : Boolean;     {Config : #11 : Allow Goodbye In Door ?}
                        PathLog     : String[60];  {Config : #12 : Nom Du Log}
                        SFDir       : String[60];  {Config : #13 : Directorie De Spit}
                        PrescanDir  : String[60];  {Config : #14 : Directorie Du Prescan}
                        SysOpLevel  : Word;        {SFSYSTEM.DAT : Sec Du SysOp}
                        SysOpName   : String[30];  {SFSYSTEM.DAT : Nom Du SysOp}
                        BaudComm    : LongInt;     {SFNODE.DAT   : Port Comm Ouvert A}
                        WorkDir     : String[60];  {SFNODE.DAT   : Repertoire SF WORK}
                        MsgDir      : String[60];  {SFNODE.DAT   : Directorie De La Messagerie}
                        DisplayDir  : String[60];  {SFNODE.DAT   : Directorie Du Display}
                        RecMail     : Word;        {BSFUSERS.DAT : Rec Au Niveau De BSFMAIL}

       End;

Var User    : Users;
    USR     : File Of Users;
    Config  : ConfigurationDoor;   {Renseignement Configuration Generale}
    RecUser : Integer;             {Variable D'emplacement User-BSF}



Implementation

Begin;

End.


