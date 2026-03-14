CONST register = 800;

TYPE

       Conference1 = Record
                        Attribut : Array[0..Register] Of Byte;
       End;

       Conference2 = Record
                        Attribut : Array[0..Register] Of Byte;
       End;

       Users1   = Record
                   Name           : String[40];
                   Protocol       : Char;
                   Compression    : Char;
                   Welcome        : Boolean;
                   Bulletin       : Boolean;
                   UploadFiles    : Boolean;
                   DownloadFiles  : Boolean;
                   Prescan        : Boolean;
                   UseCurentDate  : Boolean;
                   News           : Boolean;
                   SmallControl   : Boolean;
                   SendUserInf    : Boolean;
                   NDXFiles       : Boolean;
                   RepDownScan    : Boolean;
                   Goodbye        : Boolean;
                   AllowFileUpld  : Boolean;
                   AllowFileDown  : Boolean;
                   XPertMode      : Boolean;
                   Conf           : Conference1;
                   NbPageSysOp    : Integer;
                   NbMessDown     : LongInt;
                   NbMessUpld     : LongInt;
                   NbConnection   : Longint;
                   LastQWKDate    : String[8];
                   LastQWKTime    : String[5];
                   NewFiles       : Boolean;
                   Extra          : Array[0..201] Of Byte;
  End;

       Users2   = Record
                   Name           : String[40];
                   Protocol       : Byte;
                   Compression    : Byte;
                   Welcome        : Boolean;
                   Bulletin       : Boolean;
                   UploadFiles    : Boolean;
                   DownloadFiles  : Boolean;
                   Prescan        : Boolean;
                   UseCurentDate  : Boolean;
                   News           : Boolean;
                   SmallControl   : Boolean;
                   SendUserInf    : Boolean;
                   NDXFiles       : Boolean;
                   RepDownScan    : Boolean;
                   Goodbye        : Boolean;
                   AllowFileUpld  : Boolean;
                   AllowFileDown  : Boolean;
                   XPertMode      : Boolean;
                   Conf           : Conference2;
                   NbPageSysOp    : Integer;
                   NbMessDown     : LongInt;
                   NbMessUpld     : LongInt;
                   NbConnection   : Longint;
                   LastQWKDate    : String[8];
                   LastQWKTime    : String[5];
                   NewFiles       : Boolean;
                   Extra          : Array[0..201] Of Byte;
  End;

(* NETMAIL.CFG *)
       ConfigurationDoor1 = RECORD

                        BBSName     : String[30];
                        BBSID       : String[8];
                        SysOpName   : String[30];
                        BBSCity     : String[30];
                        BBSPhone    : String[30];
                        SFDir       : String[60];
                        WorkDir     : String[60];
                        LocalQWK    : String[60];
                        WelcomeDir  : String[60];
                        NewsDir     : String[60];
                        GoodByeDir  : String[60];
                        CommBaud    : String[15];
                        AddFiles    : String[10];
                        GoodBye     : String[10];
                        InvConf     : String[10];
                        SepUsage    : String[10];
                        SysPrio     : String[10];
                        ActualSpeed : String[10];
                        SysOpLevel  : String[10];
                        MaxConf     : String[10];
                        PathLog     : String[60];
                        DirDoor     : String[60];

       End;
VAR
      User1    : Users1;
      USR1     : File Of Users1;

      User2    : Users2;
      USR2     : File Of Users2;

      Rec      : Integer;
      I        : Integer;

      Fil      : File;

(*-------------------------------------------------------------------------*)
Procedure NETUSER;
Begin;
 Writeln;
 Writeln(' þ Converting Your NETUSERS.DAT to NETMAIL Version 1.00à012');

 Assign(USR1, 'NETUSERS.DAT');
 {$I-} Reset(USR1); {$I+}
 If IoResult <> 0 Then Begin;
                        Writeln(' þ NETUSERS.DAT Not Found þ ');
                        Halt(1);
                       End;
 Assign(USR2, 'NETUSERS.222');
 {$I-} Reset(USR2); {$I+}
 If IoResult = 0 Then Begin;
                        Writeln(' þ NETUSERS.222 Already Exist ! þ ');
{                       Halt(2); }
                       End;
 ReWrite(USR2);

 Rec := 0;

 Repeat
 Seek(USR1, Rec);
 Read(USR1, User1);

User2.Name          := User1.Name;
User2.Protocol      := 0;
User2.Compression   := 0;
User2.Welcome       := User1.Welcome;
User2.Bulletin      := User1.Bulletin;
User2.UploadFiles   := User1.UploadFiles;
User2.DownloadFiles := User1.DownloadFiles;
User2.Prescan       := User1.Prescan;
User2.UseCurentDate := User1.UseCurentDate;
User2.News          := User1.News;
User2.SmallControl  := User1.SmallControl;
User2.SendUserInf   := User1.SendUserInf;
User2.NDXFiles      := User1.NDXFiles;
User2.RepDownScan   := User1.RepDownScan;
User2.Goodbye       := User1.Goodbye    ;
User2.AllowFileUpld := User1.AllowFileUpld;
User2.AllowFileDown := User1.AllowFiledown;
User2.XpertMode     := User1.XPertmode;
User2.NbPageSysOp   := User1.NbPageSysOp;
User2.NbMessDown    := User1.NbMessDown;
User2.NbMessUpld    := User1.NbMessUpld;
User2.NbConnection  := User1.NbConnection;
User2.LastQWKDate   := User1.LastQWKDate;
User2.LastQWKTime   := User1.LastQWKTime;
User2.NewFiles      := User1.NewFiles;

For I := 0 To Register Do Begin;
                       User2.Conf.Attribut[I] := User1.Conf.Attribut[I];
                     End;
For I := 0 To 201 Do User2.Extra[I]         := User1.Extra[I];


 Seek(USR2, FileSize(USR2));
 Write(USR2, User2);
 Inc(Rec);

Until Rec = FileSize(USR1);

 Close(USR1);
 Close(USR2);

 Writeln('   þ Processing Done With ',Rec,' Users Processed...');

End;
(*-------------------------------------------------------------------------*)
(*-------------------------------------------------------------------------*)
Procedure NETCONFIG;
VAR CFG : Text;
    Config : ConfigurationDoor1;
Begin;
 Writeln;
 Writeln(' þ Converting Your NETCONFIG.CFG to NETMAIL Version 1.00à012');
  Assign(CFG, 'NETMAIL.CFG');
 {$I-} Reset(CFG); {$I+}
 If Ioresult <> 0 Then Rewrite(CFG)
    Else Begin;
          ReadLn(CFG);
          ReadLn(CFG, Config.DirDoor);
          ReadLn(CFG, Config.BBSName);
          ReadLn(CFG, Config.SysOpName);
          ReadLn(CFG, Config.CommBaud);
          ReadLn(CFG, Config.BBSID);
          ReadLn(CFG, Config.BBSCity);
          ReadLn(CFG, Config.BBSPhone);
          ReadLn(CFG, Config.WorkDir);
          ReadLn(CFG, Config.LocalQWK);
          ReadLn(CFG, Config.WelcomeDir);
          ReadLn(CFG, Config.NewsDir);
          ReadLn(CFG, Config.GoodByeDir);
          ReadLn(CFG, Config.AddFiles);
          ReadLn(CFG, Config.Goodbye);
          ReadLn(CFG, Config.InvConf);
          ReadLn(CFG, Config.SepUsage);
          ReadLn(CFG, Config.SysPrio);
          ReadLn(CFG, Config.ActualSpeed);
          ReadLn(CFG, Config.SysOpLevel);
          ReadLn(CFG, Config.PathLog);
          ReadLn(CFG, Config.SFDir);
         End;

 ReWrite(CFG);
          WriteLn(CFG, 'QWK');
          WriteLn(CFG, Config.DirDoor);
          WriteLn(CFG, Config.BBSName);
          WriteLn(CFG, Config.SysOpName);
          Writeln(CFG, Config.CommBaud);
          WriteLn(CFG, Config.BBSID);
          WriteLn(CFG, Config.BBSCity);
          WriteLn(CFG, Config.BBSPhone);
          WriteLn(CFG, Config.WorkDir);
          WriteLn(CFG, Config.LocalQWK);
          WriteLn(CFG, Config.WelcomeDir);
          WriteLn(CFG, Config.NewsDir);
          WriteLn(CFG, Config.GoodByeDir);
          WriteLn(CFG, Config.AddFiles);
          WriteLn(CFG, Config.Goodbye);
          WriteLn(CFG, Config.SysOpLevel);
          WriteLn(CFG, Config.PathLog);
          Writeln(CFG, Config.SfDir);
 {$I-} Close(CFG); {$I+}
  If IoResult <> 0 Then ;

       End;

(*-------------------------------------------------------------------------*)
(*-------------------------------------------------------------------------*)

Begin;

 Writeln('Processing Conversion From Netmail Version 1.00à009 To Netmail Version 1.00à012');
 If ParamCount = 0 Then Begin;
                         NetUser;
                         NetConfig;
                        End
 Else NetConfig;

 Writeln;
 Writeln('Processing Finish...');
 Writeln(' Have a nice day....');

 If ParamCount = 0 Then Begin;
 Assign(Fil, 'NETUSERS.DAT');
 Erase(Fil);
 Assign(Fil, 'NETUSERS.222');
 Rename(Fil, 'NETUSERS.DAT');
 End;
End.