UNIT BSFProto;


{$I LANGAGE.DIR}

Interface

 Procedure Protocole;

Implementation

 Uses BSFCOMM,
      BSFConst;


TYPE
  ConfigurationProtocoles = RECORD
                        Lettre      : String[01];
                        Name        : String[20];
                        Send        : String[60];
                        Receive     : String[60];
  End;

{--------------------------------------------------------------}
Function Protoc(Point, Posis : Byte; BsfMailDir : String) : String;
VAR
    Proto      : ConfigurationProtocoles;
    Protocol   : File Of ConfigurationProtocoles;

Begin;
 Assign(Protocol, BsfMailDir+'BSFPROTO.DAT');
 Reset(Protocol);
 Seek(Protocol, Posis);
 Read(Protocol, Proto);
 Close(Protocol);

 If ( (Proto.Lettre >= 'A') And (Proto.Lettre <= 'Z')) Then Else Proto.Lettre := '';

 Protoc := '';
 If Point = 1 Then Protoc := Proto.Lettre;
 If Point = 2 Then Protoc := Proto.Name;
 If Point = 3 Then Protoc := Proto.Receive;
 If Point = 4 Then Protoc := Proto.Send;

End;
{--------------------------------------------------------------}
Procedure Protocole;

VAR
    Proto      : Array[0..9] Of ConfigurationProtocoles;
    Protocol   : File Of ConfigurationProtocoles;
    Rec        : Integer;
    Fin        : Boolean;
    C          : Char;

Begin;
  RmClrscr;
  RmSetColor(14,0);
 {$IFDEF ENGLISH}
  RmWriteln('                            AVAILABLE PROTOCOLE');
 {$ELSE}
  RmWriteln('                     PROTOCOLE DE TRANSFERT DISPONIBLE');
 {$ENDIF}

  RmSetcolor(11,0);
  RmWriteln('');
  RmWriteln('');
  RmWriteln('');

 {$IFDEF ENGLISH}
  RmWriteln(' Current Protocol : ' + Protoc(2, User.Protocol, Config.BsfMailDir));
 {$ELSE}
  RmWriteln(' Protocole De Transfert Actuel : ' + Protoc(2, User.Protocol, Config.BsfMailDir));
 {$ENDIF}

  RmWriteln('');
  RmSetcolor(15,0);

  Assign(Protocol, Config.BsfMailDir+'BSFPROTO.DAT');
  Reset(Protocol);
  For Rec := 0 To 9 Do
   Begin;
    Seek(Protocol, Rec);
    Read(Protocol, Proto[Rec]);
    If ( (Proto[Rec].Lettre >= 'A') And (Proto[Rec].Lettre <= 'Z'))
        Then RmWriteLn('   '+Proto[Rec].Lettre+' ---> '+Proto[Rec].Name);
      End;
     Close(Protocol);

  RmSetColor(15,0);
  RmWriteln('');
  RmWriteln('');

 {$IFDEF ENGLISH}
  RmWrite(' Enter Choice (<Enter> To Quit) : ');
 {$ELSE}
  RmWrite(' Entrez Votre Choix (<Enter> Pour Quitter) : ');
 {$ENDIF}

 Fin := False;
 Repeat
  Repeat
   C := Upcase(RmReadKey);
  Until (((C >= 'A') And (C <= 'Z') Or (C = #13))) ;

  For Rec := 0 To 9 Do
   If C = Protoc(1, Rec, Config.BsfMailDir) Then
    If Rec <> User.Protocol Then
    Begin;
     User.Protocol := Rec;
     RmWriteln('');

    {$IFDEF ENGLISH}
     RmWriteln(' þþþ New Protocol : ' + Proto[Rec].Name +' þþþ');
     RmWriteln('');
     RmWrite(' Enter Choice (<Enter> To Quit) : ');
    {$ELSE}
     RmWriteln(' þþþ Nouveau Mode De Compression : '+ Proto[Rec].Name +' þþþ');
     RmWriteln('');
     RmWrite(' Entrez Votre Choix (<Enter> Pour Quitter) : ');
    {$ENDIF}

    End;

  If C = #13 then Fin := True;

 Until Fin = True;

End;

END.