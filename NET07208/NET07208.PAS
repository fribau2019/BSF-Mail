CONST register = 800;

TYPE

       ConfigurationCompression = RECORD
                        Lettre      : String[01];
                        Name        : String[03];
                        Compress    : String[60];
                        Decompress  : String[60];
       End;

       ConfigurationProtocoles1 = RECORD
                        Lettre      : String[01];
                        Name        : String[20];
                        Send        : String[60];
                        Receive     : String[60];
       End;

       Conference2 = Record
                        Attribut : Array[0..Register] Of Byte;
                        Pointeur : Array[0..Register] Of LongInt;
                        Netmail  : Array[0..Register] Of Boolean;
                        Extra    : Array[0..50] Of Byte;
       End;

       Conference1 = Record
                        Attribut : Array[0..255] Of Integer;
                        Pointeur : Array[0..255] Of LongInt;
                        Netmail  : Array[0..255] Of Boolean;
                        Extra    : Array[0..50] Of Byte;
       End;

       Users1    = Record
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
                        XperMode       : Boolean;
                        Conf           : Conference1;
                        NET            : Array[0..20] Of Boolean;
                        NbPageSysOp    : Integer;
                        NbMessDown     : LongInt;
                        NbMessUpld     : LongInt;
                        NbConnection   : Longint;
                        LastQWKDate    : String[8];
                        LastQWKTime    : String[5];
                        NewFiles       : Boolean;
                        Extra          : Array[0..199] Of Byte;
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
      Ligne       : String[78];
      Protocol1   : Array[0..9] Of ConfigurationProtocoles1;
      Proto1      : Text;
      Protocol2   : ConfigurationProtocoles1;
      Proto2      : File Of ConfigurationProtocoles1;

      Compression1   : Array[0..9] Of ConfigurationCompression;
      Compres1      : Text;
      Compression2   : ConfigurationCompression;
      Compres2      : File Of ConfigurationCompression;

      User1    : Users1;
      USR1     : File Of Users1;
      User2    : Users2;
      USR2     : File Of Users2;
      Rec      : Integer;
      I        : Integer;

(*-------------------------------------------------------------------------*)
Procedure NETUSER;
Begin;
 Writeln;
 Writeln(' þ Changing Your NETUSERS.DAT');


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
User2.XpertMode      := User1.XPermode;
For I := 0 To 50  Do User2.Conf.Extra[I] := 0;
For I := 0 To Register Do Begin;
                       User2.Conf.Attribut[I] := User1.Conf.Attribut[I];
                       User2.Conf.Pointeur[I] := User1.Conf.Pointeur[I];
                       User2.Conf.Netmail[I]  := User1.Conf.Netmail[I];
                     End;
For I := 256 To Register Do Begin;
                       User2.Conf.Attribut[I] := 0;
                       User2.Conf.Pointeur[I] := 0;
                       User2.Conf.Netmail[I]  := False;
                     End;
User2.NbPageSysOp   := User1.NbPageSysOp;
User2.NbMessDown    := User1.NbMessDown;
User2.NbMessUpld    := User1.NbMessUpld;
User2.NbConnection  := User1.NbConnection;
User2.LastQWKDate   := User1.LastQWKDate;
User2.LastQWKTime   := User1.LastQWKTime;
User2.NewFiles      := User1.NewFiles;
 For I := 0 To 201 Do User2.Extra[I]         := 0;

 Seek(USR2, FileSize(USR2));
 Write(USR2, User2);
 Inc(Rec);

Until Rec = FileSize(USR1);

 Close(USR1);
 Close(USR2);

 Writeln('   þ Processing Done With ',Rec,' Users Processed...');

End;
(*-------------------------------------------------------------------------*)
Procedure NETPROTO;
Begin;
 Writeln(' þ Changing Your NETPROTO.DAT');

 Assign(Proto1, 'NETPROTO.DAT');
 {$I-} Reset(Proto1); {$I+}
 If Ioresult <> 0 Then
    Else Begin;
          For Rec := 0 To 9 Do Begin;
                                 ReadLn(Proto1, Ligne);
                                 Protocol1[Rec].Lettre := Ligne;
                                 ReadLn(Proto1, Ligne);
                                 Protocol1[Rec].Name := Ligne;
                                 ReadLn(Proto1, Ligne);
                                 Protocol1[Rec].Receive := Ligne;
                                 ReadLn(Proto1, Ligne);
                                 Protocol1[Rec].Send := Ligne;
                                End;
         End;
 Close(Proto1);


 Assign(Proto2, 'NETPROTO.222');
 {$I-} Reset(Proto2); {$I+}
 If Ioresult <> 0 Then Rewrite(Proto2);

 For Rec := 0 To 9 Do Begin;
           Protocol2.Lettre  := Protocol1[Rec].Lettre;
           Protocol2.Name    := Protocol1[Rec].Name;
           Protocol2.Receive := Protocol1[Rec].Receive;
           Protocol2.Send    := Protocol1[Rec].Send;

         If  Protocol1[Rec].Lettre  = '' Then Protocol2.Lettre := #0;
         If  Protocol1[Rec].Name    = '' Then FillChar(Protocol2.Name   , 21 , #0);
         If  Protocol1[Rec].Receive = '' Then FillChar(Protocol2.Receive, 61 , #0);
         If  Protocol1[Rec].Send    = '' Then FillChar(Protocol2.Send   , 61 , #0);

           Seek(Proto2, Rec);
           Write(Proto2, Protocol2);

          End;

  Close(Proto2);



End;
(*-------------------------------------------------------------------------*)
Procedure NETCOMP;
Begin;
Writeln(' þ Changing Your NETCOMP.DAT');

 Assign(Compres1, 'NETCOMP.DAT');
 {$I-} Reset(Compres1); {$I+}
 If Ioresult <> 0 Then BEgin;
                        Writeln('  þ File NETCOMP.DAT Not Found !!!');
                        Writeln('  þ Halting....');
                        Write(^g);
                       End
    Else Begin;
          For Rec := 0 To 9 Do Begin;
                                 ReadLn(Compres1, Ligne);
                                 Compression1[Rec].Lettre := Ligne;
                                 ReadLn(Compres1, Ligne);
                                 Compression1[Rec].Name := Ligne;
                                 ReadLn(Compres1, Ligne);
                                 Compression1[Rec].Compress := Ligne;
                                 ReadLn(Compres1, Ligne);
                                 Compression1[Rec].Decompress := Ligne;
                                End;
         End;
  Close(Compres1);

 Assign(Compres2, 'NETCOMP.222');
 {$I-} Reset(Compres2); {$I+}
 If Ioresult <> 0 Then Rewrite(Compres2)
    Else Begin;
          For Rec := 0 To 9 Do Begin;
           Compression2.Lettre  := Compression1[Rec].Lettre;
           Compression2.Name    := Compression1[Rec].Name;
           Compression2.Compress := Compression1[Rec].Compress;
           Compression2.Decompress    := Compression1[Rec].DeCompress;

         If  Compression1[Rec].Lettre     = '' Then Compression2.Lettre := #0;
         If  Compression1[Rec].Name       = '' Then FillChar(Compression2.Name   , 21 , #0);
         If  Compression1[Rec].Compress   = '' Then FillChar(Compression2.Compress, 61 , #0);
         If  Compression1[Rec].Decompress = '' Then FillChar(Compression2.Decompress   , 61 , #0);

           Seek(Compres2, Rec);
           Write(Compres2, Compression2);
          End;
         End;
 Close(Compres2);

End;

(*-------------------------------------------------------------------------*)
(*-------------------------------------------------------------------------*)

Begin;

 Writeln('Processing Conversion From Netmail Version 1.00à007 To Netmail Version 1.00à008');

 NetUser;

 NetProto;

 NetComp;

 Writeln;
 Writeln('Processing Finish...');
 Writeln(' Please Rename Your NETxxxx.222 To NETxxxx.DAT');
 Writeln(' Have a nice day....');

End.