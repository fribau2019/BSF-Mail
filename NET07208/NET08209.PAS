CONST register = 800;

TYPE

       Conference1 = Record
                        Attribut : Array[0..Register] Of Byte;
                        Pointeur : Array[0..Register] Of LongInt;
                        Netmail  : Array[0..Register] Of Boolean;
                        Extra    : Array[0..50] Of Byte;
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
 Writeln(' þ Converting Your NETUSERS.DAT to NETMAIL Version 1.00à009');

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
User2.Protocol      := User1.Protocol;
User2.Compression   := User1.Compression;
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
(*-------------------------------------------------------------------------*)

Begin;

 Writeln('Processing Conversion From Netmail Version 1.00à007 To Netmail Version 1.00à008');

 NetUser;

 Writeln;
 Writeln('Processing Finish...');
 Writeln(' Please Rename Your NETxxxx.222 To NETxxxx.DAT');
 Writeln(' Have a nice day....');

 Assign(Fil, 'NETUSERS.DAT');
 Erase(Fil);

 Assign(Fil, 'NETUSERS.222');
 Rename(Fil, 'NETUSERS.DAT');

End.