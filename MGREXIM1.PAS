UNIT MGRExIm1;

{$I E:\SOURCE~1\PASCAL\NETMAIL\LANGAGE.DIR}
Interface

  Procedure CreeHUB(Name : String);

Implementation

Uses CRT,
     DOS,
     BSFConst,
     BSFUtils,
     MGRVaria,
     MGRDeflt;

{-------------------------------------------------------------------------}
Procedure CreeHUB(Name : String);
TYPE
 (*.MAP*)
  Carte = Record
           Conf    : Word;
           Tag     : Byte;
           SendAll : Boolean;
           Exportro: Boolean;
           Ansi    : Boolean;
           BSFCode : LongInt;
          End;
 (*.PNT*)
  Pointeur = LongInt;
 (*.DAT*)
  Forme  = (Both, Out, Ine, None);
  Config = Record
            NomBBS        : String[80];
            Telephone     : String[20];
            QWKPath,
            REPPath,
            Pack,
            UnPack        : String[80];
            HostSysOpName : String[80];
            XLate         : Forme;
            HostTag       : Array[0..9] Of String[70];
            OrgTag        : Array[0..9] Of String[70];
            Report        : String[80];
            Net           : Array[0..9] Of String[20];
            Extra         : Array[0..280] Of Byte;
           End;


Var MAP : Array[0..Register] Of Carte;
    MP  : File Of Carte;
    PNT : Array[0..Register] Of Pointeur;
    PT  : File Of Pointeur;
    DAT : Config;
    DT  : File Of Config;
    Rec : Word;

Begin;
 If Not FileExists(Name+'.MAP') Then
  Begin;
   FillChar(MAP, SizeOf(Map), #00);
   Assign(MP, Name+'.MAP');
   ReWrite(MP);
   Reset(MP);
   For Rec := 0 To Register Do
    Begin;
     Seek(MP, Rec);
     Write(MP, MAP[Rec]);
    End;
   Close(MP);
  End;

 If Not FileExists(Name+'.PNT') Then
  Begin;
   FillChar(PNT, SizeOf(PNT), #00);
   Assign(PT, Name+'.PNT');
   ReWrite(PT);
   Reset(PT);
   For Rec := 0 To Register Do
    Begin;
     Seek(PT, Rec);
     Write(PT, PNT[Rec]);
    End;
   Close(PT);
  End;

 If Not FileExists(Name+'.DAT') Then
  Begin;
   FillChar(DAT, SizeOf(DAT), #00);
   Assign(DT, Name+'.DAT');
   ReWrite(DT);
   Reset(DT);
   Seek(DT, 0);
   Write(DT, DAT);
   Close(DT);
  End;

End;
{-------------------------------------------------------------------------}

END.