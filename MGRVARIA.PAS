UNIT MGRVaria;

Interface

Uses BSFConst;

CONST Register = BSFConst.Register;
      Version  = BSFConst.MGRReg;
      Netmail  = BSFConst.Version;
      Date     = BSFConst.DDate;
      _ConfigOk : Boolean = True;
      ConfigPathName : String = 'C:\BSFMAIL\BSFMAIL.CFG';

TYPE

{$I BSFUSERS.LST}

(* NETLANG.DAT *)
       ConfigurationLangue = Record
                               Langue : String[40];
                               Default : Boolean;
                              End;

(* NETLANG.00x *)
       ConfigurationLangage = Record
                              Command : String[60];
                              End;

(* NETHELP.00x *)
       ConfigurationHelp    = Record
                               Tile : String[60];
                               Description : Array[0..9] Of String[70];
                              End;

(* NETCOMP.DAT *)
       ConfigurationCompression = RECORD
                        Lettre        : String[01];
                        Name          : String[03];
                        Compression   : String[60];
                        Decompression : String[60];
       End;

(* NETPROTO.DAT *)
       ConfigurationProtocoles = RECORD
                        Lettre      : String[01];
                        Name        : String[20];
                        Receive     : String[60];
                        Send        : String[60];
       End;




(* NETCONF.DAT *)
       ConfigurationConference = RECORD
                        Name        : String[13];
       End;
(* NETCONF.DEF *)
       ConfigurationConferenceParDefault = Record
                        Default : Boolean;
                        Force   : Boolean;
                        Extra   : Array[0..9] Of Byte;
       End;


(* SFMSG[x].IDX *)
  MessageIdx    = Record
                   FromWhoCRC,
                   ToWhoCRC,
                   MsgNumber,
                   OrgMsgNumber   : LongInt;
  End;

(* --- *)
  PrivSecArray  = Array[1..5] Of Integer;

  Conference = Record
                Attribut : Array[0..Register] Of Byte;
               End;

(* SFMAREA.DAT *)
  MsgSystem     = Record
                   MSec           : Integer;
                   NetMailConf    : Boolean;
                   MDesc          : String[40];
                   MEqual,
                   PublicMsgConf,
                   AllowDelete,
                   PackUnReceived : Boolean;
                   DaysOld        : Word;
                   DelOldThdMsg   : Boolean;
                   NoOfLines      : Word;
                   OneExtra       : Boolean;
                   PrivSec        : PrivSecArray;
                   MsgEntrySec    : Word;
                   Extra          : Array[1..44] Of Byte;
                   AllowNetRoute,
                   MarkAsSent     : Boolean;
                   NetIDName      : String[15];
                  End;


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

(* SFMSG[X].LMR *)
LastMessage   = Record
                  LMsgRed : LongInt;
                End;

Var Config : ConfigurationDoor;
    User   : Users;
    USR    : File Of Users;

Implementation
End.