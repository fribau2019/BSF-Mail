UNIT BSFCompr;

{$I LANGAGE.DIR}

Interface

 Procedure Compression;

Implementation

 Uses BSFCOMM,
      BSFUtils,
      BSFConst;

TYPE
  ConfigurationCompresssion = RECORD
                        Lettre      : String[01];
                        Name        : String[03];
                        DeCompress  : String[60];
                        Compress    : String[60];
  End;


{------------------------------------------------------------------------}
Function Compres(Point, Posis : Byte; BsfMailDir : String) : String;

VAR Comp        : ConfigurationCompresssion;
    Compress    : File Of  ConfigurationCompresssion;


Begin;
 Assign(Compress, BsfMailDir+'BSFCOMP.DAT');
 Reset(Compress);
 Seek(Compress, Posis);
 Read(Compress, Comp);
 Close(Compress);

 If ( (Comp.Lettre >= 'A') And (Comp.Lettre <= 'Z')) Then Else Comp.Lettre := '';

 Compres := '';
 If Point = 0 Then Compres := IntToStr(FileSize(Compress)-1);
 If Point = 1 Then Compres := Comp.Lettre;
 If Point = 2 Then Compres := Comp.Name;
 If Point = 3 Then Compres := Comp.DeCompress;
 If Point = 4 Then Compres := Comp.Compress;

End;
{------------------------------------------------------------------------}
Procedure Compression;
Var Rec : Integer;

VAR
    Fin         : Boolean;
    C           : Char;
    Comp        : Array[0..9] Of ConfigurationCompresssion;
    Compress    : File Of  ConfigurationCompresssion;

Begin;

  RmClrscr;
  RmSetColor(14,0);
 {$IFDEF ENGLISH}
  RmWriteln('                           AVAILABLE COMPRESSION MODE');
 {$ELSE}
  RmWriteln('                         MODE DE COMPRESSION DISPONIBLE');
 {$ENDIF}
  RmSetcolor(11,0);
  RmWriteln('');
  RmWriteln('');
  RmWriteln('');
  RmWriteln('');
 {$IFDEF ENGLISH}
  RmWriteln(' Current Compression Mode : '+ Compres(2, User.Compression, Config.BsfMailDir));
 {$ELSE}
  RmWriteln(' Mode De Compression Actuel : '+ Compres(2, User.Compression, Config.BsfMailDir));
 {$ENDIF}
  RmWriteln('');
  RmSetcolor(15,0);


  Assign(Compress, Config.BsfMailDir+'BSFCOMP.DAT');
  Reset(Compress);
  For Rec := 0 To 9 Do
   Begin;
    Seek(Compress, Rec);
    Read(Compress, Comp[Rec]);
    If ( (Comp[Rec].Lettre >= 'A') And (Comp[Rec].Lettre <= 'Z'))
     Then RmWriteLn('   '+Comp[Rec].Lettre+' ---> '+Comp[Rec].Name)
   End;
  Close(Compress);

  RmSetColor(15,0);
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
   Until ( (C >= 'A') And (C <= 'Z') Or (C = #13) ) ;

   For Rec := 0 To 9 Do
    If C = Comp[Rec].Lettre Then
    If Rec <> User.Compression Then
    Begin;
     User.Compression := Rec;
     RmWriteln('');
    {$IFDEF ENGLISH}
     RmWriteln(' þþþ New Compression Mode : '+Comp[Rec].Name+' þþþ');
     RmWriteln('');
     RmWrite(' Enter Choice (<Enter> To Quit) : ');
    {$ELSE}
     RmWriteln(' þþþ Nouveau Mode De Compression : '+Comp[Rec].Name+' þþþ');
     RmWriteln('');
     RmWrite(' Entrez Votre Choix (<Enter> Pour Quitter) : ');
    {$ENDIF}

    End;

   If C = #13 Then Fin := True;

  Until Fin = True;

End;

END.