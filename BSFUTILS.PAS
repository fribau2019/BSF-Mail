UNIT BSFUtils;

Interface

 Procedure Delay(ms : Word);                      {*Remplacant Du Delay Du CRT.TPU}

 Function MAJ(S : String) : String;               {*Convertie Une Chaine En Majuscule}
 Function StrToInt (I : String) : LongInt;        {Convertie Une String En Longint}
 Function IntToStr( nNum: Longint): String;       {*Convertie Un LongInt En String}
 Function Reduce( s: STRING; c: CHAR ): STRING;   {*Enleve Les 'Char' Dans Une Chaine}
 Function CheckDir( Dir: STRING ) : BOOLEAN;
 Function Rep(ch: char;b: byte): string;         {return a string with filled with ch and with length b}

 Function FileExists(FileName : String) : Boolean;
 Function RTrim( s: STRING; c: CHAR ): STRING;
 Function LTrim( s: STRING; c: CHAR ): STRING;
 Function CMajMin(Chaines : String) : String;
 Function Date(Nombre : Byte) : String;
 Function Time : String;
 Function HexStr(w: Word): String ;
 Function nubase(numin : LongInt; base, numplaces : Byte) : String;
 Function HexToInt(HE : String) : Byte;

 Function GetString(Size : Byte ; Str: String;Fill : Char) : String;
 Function OrdonneCenter(S : String; Size : Byte) : String;

 Procedure CursorOff;
 Procedure CursorOn;
 Procedure FCopy(FIn, FOut : String);

 Procedure ReadInt(Old : Integer; Var I : Integer; X, Y, Lengt : Byte);
 Procedure WriteCenter(S : String; Y : Byte);
 Procedure WriteXY(x, y : Byte; S : String);

Implementation

 Uses Dos, Crt;

{-----------------------------------------------------------------------}
Function STRToInt (I : String) : LongInt;
Var S : LongInt;
    F : Integer;
Begin;
  Val(I, S, F);
  If F <> 0 Then StrToInt := 0;
  StrToInt := S;
End;
{-----------------------------------------------------------------------}
FUNCTION IntToStr( nNum: LONGINT): STRING;
VAR s: ^STRING;
BEGIN
     ASM
          mov     sp, bp
          push    ss
          push    WORD PTR @RESULT
     END;
    STR( nNum:0, s^ );
END;
{-----------------------------------------------------------------------}
FUNCTION RTrim( s: STRING; c: CHAR ): STRING;
BEGIN
      WHILE (LENGTH(s) > 0) AND (s[LENGTH(s)] = c) DO DEC(s[0]);
      RTrim := s;
END;
{---------------------------------------------------------------------------}
FUNCTION LTrim( s: STRING; c: CHAR ): STRING; Assembler;
ASM
      PUSH   DS
      LDS    SI, s
      XOR    AX, AX
      LODSB
      XCHG   AX, CX
      LES    DI, @Result
      INC    DI
      JCXZ   @@2

      MOV    BL, c
      CLD
@@1:  LODSB
      CMP    AL, BL
      LOOPE  @@1
      DEC    SI
      INC    CX
      REP    MOVSB

@@2:  XCHG   AX, DI
      MOV    DI, WORD PTR @Result
      SUB    AX, DI
      DEC    AX
      STOSB
      POP    DS
END;
{---------------------------------------------------------------------------}
Function FileExists(FileName : String) : Boolean;
Var
  DirInfo : SearchRec;
begin
  FindFirst(FileName, AnyFile, DirInfo);
  if (DosError = 0) then
    FileExists := True
  else
    FileExists := False;
end;
{-------------------------------------------------------------------------}
FUNCTION Reduce( s: STRING; c: CHAR ): STRING; Assembler;
ASM
      PUSH   DS
      CLD
      LDS    SI, s
      XOR    AX, AX
      LODSB
      XCHG   AX, CX
      LES    DI, @Result
      INC    DI
      JCXZ   @@3
      MOV    BL, c
@@1:  LODSB
      CMP    AL, BL
      JE     @@2
      STOSB
@@2:  LOOP   @@1
@@3:  XCHG   AX, DI
      MOV    DI, WORD PTR @Result
      SUB    AX, DI
      DEC    AX
      STOSB
      POP    DS
END;
{-----------------------------------------------------------------------}
Procedure Delay(ms : Word); Assembler;
Asm {machine independent Delay Function}
  mov ax, 1000;
  mul ms;
  mov cx, dx;
  mov dx, ax;
  mov ah, $86;
  int $15;
end;
{-----------------------------------------------------------------------}
Function MAJ(S:string):string; assembler;
ASM
    push ds
    lds  si,s
    les  di,@result
    lodsb
    stosb
    xor  ch,ch
    mov  cl,al
    jcxz @empty
  @upperLoop:
    lodsb
    cmp  al,'a'
    jb   @cont
    cmp  al,'z'
    ja   @cont
    sub  al,' '
  @cont:
    stosb
    loop @UpperLoop
  @empty:
    pop  ds
End;
{-----------------------------------------------------------------------}
Function CMajMin(Chaines : String) : String;
Var F, II, I : Integer;
Begin;
 Chaines[1] := UpCase(Chaines[1]);
 F := 2;
 Repeat

 II := Ord(Chaines[F]);

 If ( (II>=65) And (II<=90)) Then Chaines[F] := Chr(II+32) Else Chaines[F] := Chr(II);

 If II = 32 Then Begin;
                 Inc(F);
                 I := Ord(Chaines[F]);
                 If ( (II>=65) And (II<=90)) Then Chaines[F] :=  Upcase(Chr(II));
                End;
 Inc(F);
 Until F > Length(Chaines);
 CMajMin := Chaines;
End;
{---------------------------------------------------------------------------}
Procedure CursorOff;
Begin;
 ASM;
    Mov Ah,01h;
    Mov Ch,20h;
    Int 10h;
 end;
end;
{---------------------------------------------------------------------}
Procedure CursorOn;
Begin;
 ASM;
    Mov Ah,01h;
    Mov Cl,7;
    Mov Ch,6;
    Int 10h;
 end;
end;
{---------------------------------------------------------------------}
FUNCTION CheckDir( Dir: STRING ) : BOOLEAN;
VAR
   fHandle: FILE;
   wAttr: WORD;
BEGIN
     WHILE Dir[LENGTH(Dir)] = '\' DO DEC( Dir[0] );
     Dir := Dir + '\.';
     ASSIGN( fHandle, Dir );
     GETFATTR( fHandle, wAttr );
     CheckDir := ( (wAttr AND DIRECTORY) = DIRECTORY );
END;
{---------------------------------------------------------------------}
Function Date(Nombre : Byte) : String;
var
  y, m, d, dow : word;
  aa, mm, jj : String[4];
begin
  GetDate(y,m,d,dow);
  If Nombre = 1 Then AA := IntToStr(y);
  If Nombre = 0 Then Begin;
                       AA := IntToStr(y);
                       AA := Copy(AA,3,2);
                       If y < 10 Then AA := '0'+AA;
                      End;
  MM := IntToStr(m); If m < 10 Then MM := '0'+MM;
  JJ := IntToStr(d); If d < 10 Then JJ := '0'+JJ;

  Date := MM+'-'+JJ+'-'+AA;
End;
{---------------------------------------------------------------------}
Function Time : String;

var
  h, m, s, hund : Word;
  HH, MM, SS : String[2];

begin
  GetTime(h,m,s,hund);

  HH := IntToStr(h); If H < 10 Then HH := '0'+HH;
  MM := IntToStr(m); If m < 10 Then mm := '0'+mm;
  SS := IntToStr(s); If s < 10 Then ss := '0'+ss;

  Time := HH+':'+MM+':'+SS;
end;
{---------------------------------------------------------------------}
FUNCTION HexStr(w: Word): String ;
  CONST
    HexChars : Array [0..$F] of Char = '0123456789ABCDEF' ;
  BEGIN
    HexStr := HexChars[Hi(w) shr 4]
            + HexChars[Hi(w) and $F]
            + HexChars[Lo(w) shr 4]
            + HexChars[Lo(w) and $F] ;
  END ;
{---------------------------------------------------------------------}
function rep(ch: char;b: byte): string;
  var s: string;
  begin
    fillchar(s,sizeof(s),ch);
    s[0] := chr(b);
    rep := s;
end;
{--------------------------------------------------------------------------}
Procedure EnvoieBAT(S : String);
Var MMM : Text;
Begin;
 Assign(MMM, 'ERROR.LOG');
 {$I-} Reset(MMM); {$I+}
 If ioresult <> 0 Then Rewrite(MMM);
 Append(MMM);
 Writeln(MMM, S);
 Writeln(S);
 Close(MMM);
End;
{--------------------------------------------------------------------------}
Function nubase(numin : LongInt; base, numplaces : Byte) : String;
Var
  tmpstr    : String;
  remainder : Byte;
  negatize  : Boolean;
begin
  negatize := (numin < 0);
  if negatize then
    numin := abs(numin);
  tmpstr[0] := Char(numplaces);
  While numplaces > 0 do
  begin
    remainder := numin mod base;
    if remainder > 9 then
      tmpstr[numplaces] := Char(remainder + 64 - 9)
     else
      tmpstr[numplaces] := Char(remainder + 48);
    numin := numin div base;
    numplaces := numplaces - 1;
  End;
  If (numin <> 0) or (negatize and (tmpstr[1] <> '0')) then
    For numplaces := 1 to Byte(tmpstr[0]) do
      tmpstr[numplaces] := '*';
  If negatize and (tmpstr[1] = '0') then
    tmpstr[1] := '-';
  nubase := tmpstr;
end;
{-------------------------------------------------------------------------}
Function HexToInt(HE : String) : Byte;
VAR
 H1, H2 : Byte;
 H      : String[1];
Begin;
  H := Copy(He, 1,1);
  H :=MAJ(H);
  If H = '0' Then H1 := 0;  If H = '1' Then H1 := 1;  If H = '2' Then H1 := 2;
  If H = '3' Then H1 := 3;  If H = '4' Then H1 := 4;  If H = '5' Then H1 := 5;
  If H = '6' Then H1 := 6;  If H = '7' Then H1 := 7;  If H = '8' Then H1 := 8;
  If H = '9' Then H1 := 9;  If H = 'A' Then H1 := 10; If H = 'B' Then H1 := 11;
  If H = 'C' Then H1 := 12; If H = 'D' Then H1 := 13; If H = 'E' Then H1 := 14;
  If H = 'F' Then H1 := 15;
  H := Copy(He, 2,1);
  H :=MAJ(H);
  If H = '0' Then H2 := 0;  If H = '1' Then H2 := 1;  If H = '2' Then H2 := 2;
  If H = '3' Then H2 := 3;  If H = '4' Then H2 := 4;  If H = '5' Then H2 := 5;
  If H = '6' Then H2 := 6;  If H = '7' Then H2 := 7;  If H = '8' Then H2 := 8;
  If H = '9' Then H2 := 9;  If H = 'A' Then H2 := 10; If H = 'B' Then H2 := 11;
  If H = 'C' Then H2 := 12; If H = 'D' Then H2 := 13; If H = 'E' Then H2 := 14;
  If H = 'F' Then H2 := 15;
  HexToInt := (H1+1)*(H2+1)-1;
End;
{-------------------------------------------------------------------------}
Procedure FCopy(FIn, FOut : String);
Var
  FromF, ToF: file;
  NumRead, NumWritten: Word;
  FBuf: array[1..2048] of Char;
begin
  Assign(FromF, FIn);
  Reset(FromF, 1);
  Assign(ToF, Fout);
  Rewrite(ToF, 1);
  repeat
    BlockRead(FromF, FBuf, SizeOf(FBuf), NumRead);
    BlockWrite(ToF, FBuf, NumRead, NumWritten);
  until (NumRead = 0) or (NumWritten <> NumRead);
  Close(FromF);
  Close(ToF);
End;
{-------------------------------------------------------------------------}
Function GetString(Size : Byte ; Str: String;Fill : Char) : String;

  Var
    CurrLen   : Byte absolute Str;
    X, Y,
    CurrPos   : Byte;
    Insert    : Boolean;
    I         : Integer;
    T         : Char;
    Old       : String;

  Begin   {GetString}
    Old     := Str;
    Insert  := True;
    X       := WhereX;                                 {X-pos of first char}
    Y       := WhereY;
    CurrLen := Length(Str);
    CurrPos := 0;                                 {position of current char}
    Repeat
      GotoXY(X,Y);
      Write(Str);
      For I := CurrLen+1 To Size Do
        Write(Fill);                                    {filler on screen}
      GotoXY(X+CurrPos,Y);
      T := ReadKey;
      If T = #0 Then             {special keys <-, ->, Ins, Home, End, Del}
        Begin   {If}
          T := ReadKey;
          Case T Of
            #75  : If CurrPos > 0 Then Dec(CurrPos);
            #77 : If (CurrPos < CurrLen) And
                          (CurrPos < Size) Then
                            Inc(CurrPos);
            #82   : Insert := Not Insert;
            #71  : CurrPos := 0;
            #79   : CurrPos := CurrLen;
            #83   : If CurrLen > CurrPos Then
                         Begin   {If}
                           For I := CurrPos+1 To CurrLen-1 Do
                             Str[I] := Str[I+1];
                           Dec(CurrLen)
                         End    {If}
          End    {Case T Of}
        End    {If}
      Else
        Begin   {Else}
          Case T Of
            #8       : If CurrPos > 0 Then                {delete currpos}
                         Begin   {If}
                           For I := CurrPos To CurrLen-1 Do
                             Str[i] := Str[i+1];
                           Dec(CurrPos);
                           Dec(CurrLen)
                         End;    {If}
            #32..'~'  : If CurrLen < Size Then          {add new character}
                         Begin   {If}
                           Inc(CurrPos);
                           If insert Then
                             Begin   {If}
                               For I := CurrLen DownTo CurrPos Do
                                 Str[i+1] := Str[i];
                               Inc(CurrLen)
                             End;
                           Str[CurrPos] := T
                         End;    {If}
          End;   {Case T Of}
        End;   {Else}
    Until (T = #13) or (T = #27);
    GotoXY(X, Y);
    For I := 1 To Size Do Write(' ');
    If T = #27 Then GetString := Old Else GetString := Str;
End;
{-------------------------------------------------------------------------}
Procedure ReadInt(Old : Integer; Var I : Integer; X, Y, Lengt : Byte);
Var S : String;
    C : Char;
Begin;
 S := '';
 GotoXY(X, Y);
 Repeat
  C := ReadKey;
  If C in ['0'..'9'] Then
   If Length(S) < Lengt Then
    Begin;
     S := S + C;
     Write(C);
    End;
 Until C in [#13, #27] ;
 If S = '' Then I := Old Else I := StrToInt(S);
 If C = #27 Then I := Old;
End;
{-------------------------------------------------------------------------}
Procedure WriteCenter(S : String; Y : Byte);
Begin;
 GotoXY( (Lo(WindMax) Div 2) - (Length(S) Div 2), Y);
 Write(S);
End;
{-------------------------------------------------------------------------}
Function OrdonneCenter(S : String; Size : Byte) : String;
Var C : String;
    L : Byte;
Begin;
 L := (Size - Length(S)) Div 2;
 C := '';
 Repeat
  C := C + ' ';
 Until Length(C) >= L;
 C := C + S;
 Repeat
  C := C + ' ';
 Until Length(C) >= Size;
 OrdonneCenter := C;
End;
{-------------------------------------------------------------------------}
Procedure WriteXY(x, y : Byte; S : String);
Begin;
 GotoXY(X,Y);
 Write(S);
End;

{-------------------------------------------------------------------------}
END.