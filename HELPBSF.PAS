Program BsfHelp;

Uses Crt;

CONST MsgFileName : String = 'BSFMAIL.HLP';

TYPE
  HelpMess = Record
              OptMan : Char;
              OptSec : Char;
              NbOfLn : Byte;
              Entete : String[60];
              Msg    : Array[1..20] Of String[72];
             End;

Var Hp  : HelpMess;
    Hlp : File Of HelpMess;
    Rec : Word;
    C   : Char;
   InverseOn    : boolean;
   UpcaseOn     : boolean;
   ValidCharSet : set of char;

const
   esc = #27;
   DefaultSet = [' '..'}'];


Procedure Inverse;
begin
   textbackground(white);
   textcolor(black);
end;

Procedure UnderLine;
begin
   textbackground(white);
   textcolor(blue);
end;

Procedure Normal;
begin
   textbackground(black);
   textcolor(white);
end;


Procedure Goback;
begin
   GotoXY(WhereX,WhereY-1);
   ClrEol;
end;

Function Left( AnyString : string; Width : byte ) : string;
var
   len  : byte absolute AnyString;
   loop : byte;
begin
   while length( AnyString ) < Width do
      AnyString:=AnyString+' ';
   len:=Width;      { truncate AnyString if Needed }
   Left:=AnyString;
end;

Function Center( AnyString : string; Width : byte ) : string;
begin
   repeat
      if length( AnyString ) < Width
         then AnyString:=AnyString+' ';
      if length( AnyString ) < Width
         then AnyString:=' '+AnyString;
   until length( AnyString ) >= Width;
   Center:=AnyString;
end;


Function ReadString( Prompt : string; Width : byte; var Escape : boolean ) : string;
var
   NewString    : string;
   InKey,InKey2 : char;
   Start        : byte;
   index        : integer;
   InsertMode   : boolean;

   Procedure Display;
   begin
      GotoXY(Start,WhereY);
      if InverseOn
         then Inverse;
      write(left(NewString,Width));
      if InverseOn
         then Normal;
      GotoXY(Start+index,WhereY);
   end;

   Procedure StripSpaces( var AnyString : string );
   { decrease length of AnyString until a character until a char other than a space is found }
   begin
      while AnyString[ ord(AnyString[0]) ]=' ' do
         dec(AnyString[0]);
   end; { Procedure }



begin
   InsertMode:=false;
   Start:=WhereX;
   index:=0;
   NewString:=Prompt;
   Display;
   index:=1;
   if UpCaseOn
      then Inkey:=UpCase(ReadKey)
      else InKey:=ReadKey;
   if InKey=#0
      then begin
         InKey2:=ReadKey;
         if InKey2 in [#77,#82]
            then NewString:=Prompt
            else NewString:='';
         if Inkey2=#82
            then begin
               InsertMode:=true;
               index:=0;
            end;
      end { then }
      else if InKey in ValidCharSet
         then NewString:=InKey
         else begin
            NewString:='';
            index:=0;
         end;
   if InKey=esc
      then begin
         ReadString:=Prompt;
         Escape:=true;
         ValidCharSet:=defaultSet;
         exit;
      end;
   if InKey=#13
      then begin
         Escape:=false;
         ReadString:=Prompt;
         ValidCharSet:=DefaultSet;
         exit;
      end;
   Display;
   repeat
     if UpCaseOn
        then Inkey:=Upcase(readkey)
        else InKey:=ReadKey;
     if (InKey in ValidCharSet)
       then begin
           if not InsertMode
              then Delete(NewString,index+1,1);
           insert(InKey,NewString,index+1);
           if index<> Width then inc(index)
        end;
     if (length(NewString)<>0) and (InKey=#8)  { backspace }
        then begin
           Delete(NewString,index,1);
           if index<>0
              then dec(index);
        end;
     if InKey=#0
        then begin
           InKey:=ReadKey;
           case InKey of
              #77 : if (index<>length(NewString)) and (' ' in ValidCharSet)
                     then inc(index)
                     else if (index+1<>Width) and (' ' in ValidCharSet)
                        then begin
                           NewString:=NewString+' ';
                           inc(index);
                        end;
              #75 : if index<>0
                       then if length(NewString)+1<>index
                          then dec(index)
                          else if NewString[index]=' '
                             then begin
                                NewString[0]:=succ(NewString[0]);
                                dec(index);
                             end
                             else dec(index);
              #83 : if length(NewString)>0 then Delete(NewString,index+1,1);
              #82 : if InsertMode
                       then InsertMode:=false
                       else InsertMode:=true;
           end; { case }
        end; { then }
     if Length(NewString)>width then dec( NewString[0] );
     if index >= width then dec(index);
     Display;
   until (InKey=#13) or (InKey=esc);
   ValidCharSet:=DefaultSet;
   if not ( (InKey=esc) or (length(NewString)=0))
      then begin
         StripSpaces(NewString);
         ReadString:=NewString
      end
      else ReadString:=Prompt;
   if InKey=esc
      then Escape:=true
      else Escape:=false;

end; { Procedure }

Function ReadNum( Prompt : real; Width : byte; var Escape : boolean ) : real;
var
   NewString : string;
   code      : integer;
   OldNum    : real;
   Start     : byte;
begin
   OldNum:=Prompt;
   Start:=WhereX;
   repeat
      GotoXY(Start,WhereY);
      str( Prompt:0:2, NewString );
      ValidCharSet:=['0'..'9','.','-',' '];
      NewString:=ReadString( NewString, Width, Escape );
      val(NewString,Prompt,code);
   until Escape or (code=0);
   if Escape or (code<>0)
      then ReadNum:=OldNum
      else ReadNum:=Prompt;
end;

Function ReadInt( Prompt : longint; Width : byte; var Escape : boolean ) : longint;
var
   NewString : string;
   code      : integer;
   OldNum    : longint;
   Start     : byte;
begin
   OldNum:=Prompt;
   Start:=WhereX;
   repeat
      GotoXY(Start,WhereY);
      str( Prompt, NewString );
      ValidCharSet:=['0'..'9','-',' '];
      NewString:=ReadString( NewString, Width, Escape );
      val(NewString,Prompt,code);
   until Escape or (code=0);
   if Escape
      then ReadInt:=OldNum
      else ReadInt:=Prompt;
end;


Function Spaces(NumSpaces : Byte) : String; Assembler;

Asm
  LES    DI, @Result
  CLD
  MOV    AL, NumSpaces
  xor    AH, AH
  STOSB
  XCHG   AX, CX
  JCXZ   @Exit
  MOV    AL, ' '
  SHR    CX, 1
  JNC    @Even
  STOSB
@Even:  REP    STOSW
@Exit:
end;  { Spaces }

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

FUNCTION RTrim( s: STRING; c: CHAR ): STRING;
BEGIN
      WHILE (LENGTH(s) > 0) AND (s[LENGTH(s)] = c) DO DEC(s[0]);
      RTrim := s;
END;


FUNCTION AllTrim( str : STRING ) : STRING;
BEGIN
     IF LENGTH( Str ) > 0 THEN
         AllTrim := LTrim(RTrim(str, ' '), ' ')
     ELSE
         AllTrim := Str;
END;


Function CalculNbOfLn : Byte;
Var I : Byte;
    Stop : Boolean;
Begin;
 Stop := False;
 I := 20;
 Repeat
  If Length(AllTrim(Hp.Msg[I])) <= 0 Then Dec(I)
   Else Stop := true;
 Until (Stop Or (I < 0));
 CalculNbOfLn := I;
End;


Procedure Visual(Rec : Word);
Var I : Integer;
Begin;
 ClrScr;
 Writeln('Help [',Rec,' Of ',FileSize(Hlp),']');
 GotoXY(2,3); Write(' þ Option Principal  : '+Hp.OptMan);
 GotoXY(2,4); Write(' þ Option Secondaire : '+Hp.OptSec);
 HP.NbOfLn := CalculNbOfLn;
 GotoXY(2,5); Write(' þ Nombre De Lignes  : ',HP.NbOfLn);
 GotoXY(2,7); Write(' þ Entˆte : '+Hp.Entete);
 For I := 1 To 20 Do
  Begin;
   If I < 10 Then Begin; GotoXY(2, I+10); Write('0',I,' ('); End
    Else Begin; GotoXY(2, I+10); Write(I,' ('); End;
   GotoXY(6,I+10); Write(Hp.Msg[I]);
   GotoXY(78,I+10); Write(')');
  End;
End;


Procedure AjouteEnregistrement;
Var Escape : Boolean;
    Ligne  : Byte;
Begin;
 Textcolor(15);
 Seek(Hlp, Rec);
 Write(Hlp, Hp);
 Seek(Hlp, FileSize(Hlp));
 Write(Hlp, Hp);
 Rec := FileSize(Hlp)-1;
 Fillchar(Hp, 1, #32);
 Visual(Rec);
 UpcaseOn:=True;
 FillChar(Hp.OptMan, 1, ' ');
 GotoXY(25, 3); Hp.OptMan := ReadKey; Write(Hp.OptMan);
 GotoXY(25, 4); Hp.OptSec := ReadKey; Write(Hp.OptSec);
 UpcaseOn:=False;
 GotoXY(14,7); Hp.Entete := ReadString(Hp.Entete, 60, Escape);
 Hp.Entete := Hp.Entete + '                                                                                    ';
 GotoXY(14, 7); Write(Hp.Entete);

 Ligne := 1;
 Repeat
  GotoXY(6, Ligne+10); Hp.Msg[Ligne] := ReadString(Hp.Msg[Ligne], 72, Escape);
   Hp.Msg[Ligne] := Hp.Msg[Ligne] + '                                                                          ';
  GotoXY(6, Ligne+10); Write(Hp.Msg[Ligne]);
  Inc(Ligne);
 Until ( (Escape = True) Or (Ligne >= 21));

 If Hp.OptMan <> ' ' Then
  If Hp.OptMan <> #13 Then
  Begin;
   Seek(Hlp, Rec);
   Write(Hlp, Hp);
  End;

End;

Procedure EditEnregistrement;
Var Escape : Boolean;
    Ligne  : Byte;
    S      : String;
Begin;
 Textcolor(15);
 UpcaseOn:=True;
 GotoXY(25, 3); S := ReadString(Hp.OptMan, 1, Escape);
 Hp.OptMan := S[1]; GotoXY(25, 3); Write(Hp.OptMan);
 GotoXY(25, 4); S := ReadString(Hp.OptSec, 1, Escape);
 Hp.OptSec := S[1]; GotoXY(25, 4); Write(Hp.OptSec);
 UpcaseOn:=False;
 GotoXY(14,7); Hp.Entete := ReadString(Hp.Entete, 60, Escape);
 Hp.Entete := Hp.Entete + Spaces(72);
 GotoXY(14, 7); Write(Hp.Entete);

 Ligne := 1;
 Repeat
  GotoXY(6, Ligne+10); Hp.Msg[Ligne] := ReadString(Hp.Msg[Ligne], 72, Escape);
   Hp.Msg[Ligne] := Hp.Msg[Ligne] + Spaces(72);
  GotoXY(6, Ligne+10); Write(Hp.Msg[Ligne]);
  Inc(Ligne);
 Until ( (Escape = True) Or (Ligne >= 21));


 Seek(Hlp, Rec);
 Write(Hlp, Hp);

End;

Begin;
 InverseOn:=true;
 UpcaseOn:=false;
 ValidCharSet:=DefaultSet;


 Assign(Hlp, MsgFileName);
 {$I-} Reset(Hlp); {$I+}
 If IoResult <> 0 Then Begin;
                        ReWrite(Hlp);
                        Seek(Hlp, 0);
                        Write(Hlp, Hp);
                       End;
 Rec := 0;
 Repeat
  Repeat
   Seek(Hlp, Rec);
   Read(Hlp, Hp);
   Visual(Rec+1);
   C := Upcase(ReadKey);
  Until C In ['+', '-', 'E', 'A', #27];

  Case C Of
    '+' : Inc(Rec);
    '-' : Dec(Rec);
    'A' : AjouteEnregistrement;
    'E' : EditEnregistrement;
  End;

  If Rec > FileSize(Hlp)-1 Then Rec := FileSize(Hlp)-1;
  If Rec < 0               Then Rec := 0;

 Until C = #27;

 Close(Hlp);
End.