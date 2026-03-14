{$O-}
Unit Fossil;
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
{                                                                       }
{     This FOSSIL Turbo Pascal v7.0 compatable Unit is copyright John   }
{   Stephenson, 1994.  This unit's source contains propertary secrets   }
{                                                                       }
{ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ}
{                Notes on Assembler returns with functions              }
{                                                                       }
{  AL: byte/char/shortint/boolean results                               }
{  AX: word/integer results                                             }
{  AX:DX: 4 byte results (pointer/longint)                              }
{  AX:BX:DX 6 byte results (real)                                       }
{อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

Interface
Uses dos, crt;
Type
  F_ary128 = array[1..128] of char;
  F_aryPtr = ^F_ary128;
  F_FossilInfoType = record
    size               : word;   { Size of the structure in bytes           }
    fosver, drvver     : byte;   { Fossil version, and Driver version       }
    ident              : F_AryPtr; { Far pointer to ASCII ID string           }
    inbuffer, infree,            { Size and free space of the input buffer  }
    outbuffer, outfree : word;   { Size and free space of the output buffer }
    width, height,               { Width and height of screen               }
    baud               : byte;   { Actual baud rate, computer to modem      }
  end;
Var
  F_comport   : word;
  F_Fosport   : word;
  F_FossilInfo: F_FossilInfoType;
  F_baudrate  : longint;

{ อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }
Function F_ReadKeyFromPort : Char;
Function F_StatusReq : Word;
Function F_Carrier : Boolean;
Function F_DataAvailable : Boolean;
Function F_FOSSILname(ComPortToCheck : word) : string;
Function F_PortOn(cp : word) : boolean;
Function F_FossilPresent : Boolean;
{ ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ }
Procedure F_PortOff(cp : word);
Procedure F_InitPort(Cp : word; Baud : Word; Charlength : byte; Parity : Char;
                     StopBits: Byte);
Procedure F_Blockwriteport(var data; lengthdata: word);
Procedure F_WritePort(Str : String);
Procedure F_RaiseDTR;
Procedure F_LowerDTR;
Procedure F_PurgeInput;
Procedure F_FlushOutput;
Procedure F_Hangup;
Procedure F_Sendbreak;
Procedure F_FlowControl(modemx, fossilx, rtscts : boolean);
Procedure F_CheckAhead(var c : char; var there : boolean);
Procedure F_Reboot(How : Byte);
{ อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ }


implementation
const magicnumber = $1954;
var
  loop : byte;
  resultword : word;

{ To initialize the modem.. Not to be confused with PortOn }
Procedure F_InitPort(Cp : word; Baud : Word; Charlength : byte; Parity : Char;
                   StopBits: Byte);
var temp : byte;
Begin
  F_comport := cp;
  F_fosport := pred(cp);
  temp := 0;  { Default of 19200 }

  Case Baud of           { 128, 64, 32... }
    19200 : Temp := 0;   { 000____ }
    38400 : Temp := 32;  { 001____ }
    300   : Temp := 64;  { 010____ }
    600   : temp := 96;  { 011____ }
    1200  : Temp := 128; { 100_____ }
    2400  : Temp := 160; { 101_____ }
    4800  : Temp := 192; { 110_____ }
    9600  : Temp := 224; { 111_____ }
  End;
  F_baudrate := baud;

  Case UpCase(Parity) of { 16, 8... }
{   'N' :;               { ___00___ }
    'O' : Inc(temp, 8);  { ___01___ }
    'E' : Inc(temp, 24); { ___11___ }
  End;
                                     { 4... }
  If StopBits = 2 then Inc(temp, 4); { _____1__ }
  { If StopBits = 1 then ;           { _____0__ }

  Case CharLength of  { 2, 1. }
    8 : inc(temp, 3); { ______11 }
    7 : inc(temp, 2); { ______10 }
  End;

  asm
    mov ah, $00
    mov al, temp
    mov dx, F_fosport
    int $14
  end;
End;

Function F_PortOn(cp : word) : boolean; Assembler;
asm
  mov ah, $04
  mov dx, cp
  dec dx
  int $14
  cmp ax, $1954  { Subtract 1954 from ax }
  je @yes        { Jump if equal ie they are the same }

  mov al, false  { No, fossil not present or there was an error }
  jmp @done

 @yes:
  mov al, true   { Yes, port was turned on okay }
 @done:
end;

{ Turn the Fossil off on the port.  Usally don't do this! }
Procedure F_PortOff(cp : word); assembler;
asm
  mov ah, 05h
  mov dx, cp
  dec dx
  int 14h
end;

Procedure F_Blockwriteport(var data; lengthdata: word); assembler;
{ To dump a variable of anything to the port }
Asm
  les di,Data                 { Get the address }
  mov cx,lengthdata           { Load length of data }
  jcxz @Done                  { If it's a empty go to the end }

 @loop:
  mov ah,01h                  { Function F_01h -- writeport }
  mov al,byte ptr [ES:DI]     { Load data from ES:DI }
  inc di                      { Increase DI }
  mov dx,F_fosport            { Store the port number }
  int 14h                     { Call the interrupt }
  loop @loop                  { Decrease CX and loop }
 @Done:
End;

Procedure F_WritePort(Str : string); assembler;
Asm
  les di,Str                  { Get the address }
  mov cl, byte ptr [ES:DI]    { Load data from ES:DI }
  xor ch,ch                   { Nulify the ah (so that cl will equal cx) }
  inc di                      { Get past the length of the string }
  jcxz @Done                  { If it's a empty string go to the end }

 @loop:
  mov ah,01h                  { Function F_01h -- writeport }
  mov al, byte ptr [ES:DI]    { Load data from ES:DI }
  inc di                      { Increase DI }
  mov dx,F_fosport            { Store the port number }
  int 14h                     { Call the interrupt }
  loop @loop                  { Decrease CX and loop }
 @Done:
End;

{ Same as readkey function, but from the port, return is in the AL }
Function F_ReadKeyFromPort : Char; Assembler;
asm
  mov ah, 02h
  mov dx, F_fosport
  int 14h
End;

Function F_StatusReq : Word; assembler;
{ AH[6:6] 1 = Output buffer empty        }
{ AH[5:5] 1 = Output buffer not full     }
{ AH[1:1] 1 = Input buffer overrun       }
{ AH[0:0] 1 = Characters in input buffer }
{ AL[7:7] 1 = Carrier Detect signal      }
asm
  mov AH, $03
  mov DX, F_fosport
  int $14
end;

Function F_Carrier : Boolean; assembler;
{ To detect carrier done in complete assembler code for added speed }
asm
  mov AH, $03
  mov DX, F_fosport
  int $14
  and ax, $80   { Just get the bit #7 (128) }
  cmp ax, $80   { Substract $80 from ax, and compare }

  je @yes       { If equal we have carrier }
  mov al, false { Set carrier to false }
  jmp @done
 @yes:
  mov al, true  { Set carrier to true }
 @done:
end;

Function F_DataAvailable : Boolean; assembler;
{ To figure out if there's data available, done in complete assembler code }
{ for added speed and reliabilty                                           }
asm
  mov AH, $03
  mov DX, F_fosport
  int $14
  and ax, $100  { just the 8th bit (256) }
  cmp ax, $100  { Subtract $100 (256) from ax }

  je @yes       { If equal jump to yes }
  mov al, false { Else set dataavailable to false }
  jmp @done     { Finish }
 @yes:
  mov al, true  { Then, set to yes }
 @done:
end;

{ To restore dtr, make sure you do this after lowering data terminal ready }
{ or modem will not send/recieve characters! }
Procedure F_RaiseDTR; assembler;
asm
  mov AH, $06
  mov AL, $01
  mov DX, F_fosport
  Int $14
End;

Procedure F_LowerDTR; assembler;
{ To hang up, some modem's don't like this! }
asm
  mov AH, $06
  mov AL, $00
  mov DX, F_fosport
  Int $14
End;

Procedure F_FlushOutput; assembler;
{ Wait for all buffer output to be output :) }
asm
  mov AH, $08
  mov DX, F_fosport
  Int $14
End;

Procedure F_PurgeInput; assembler;
{ Purges the input buffer -- Empties it into obilivion! }
asm
  mov AH, $0A
  mov DX, F_fosport
  Int $14
End;

Function F_FOSSILname(ComPortToCheck : word) : string;
{ Returns ASCII description of FOSSIL driver in use.                       }
{ Returns empty string if no FOSSIL was detected, note that detecting this }
{ way will help under DESQview, instead of the fossil present function.    }
{ Or just trying the porton function, and make sure it returns a true      }
Var
  i, j : word;
  temp : string;
  tempofs, tempseg : word;
Begin
  { Check from comport comporttocheck, to Comportcheck (just one IF com-    }
  { portcheck is not equal to 255), then from 0 to 15                       }
  j := pred(Comporttocheck);
  if (Comporttocheck = 255) then begin
    j := 0;
    Comporttocheck := 15;
  end;

  tempofs := ofs(F_FossilInfo);
  tempseg := seg(F_FossilInfo);
  repeat
    { Empty the fossil info and regs }
    fillchar(F_FossilInfo, sizeof(F_FossilInfo), 0);
    asm
      mov AH, 1Bh
      mov CX, 19
      mov DX, j
      mov DI, tempofs
      push ax
      mov AX, tempseg
      mov ES, ax
      pop ax
      int 14h
      mov resultword, AX
    end;

    temp := '';
    if resultword = sizeof(F_fossilinfo) then begin
      i := 1; while (F_FossilInfo.ident^[i] <> #0) and (i < 128) do inc(i);
      move(F_fossilinfo.ident^, temp[1], i);
      temp[0] := char(i);
    end
    else inc(j)
  until (temp <> '') or (j > pred(comporttocheck));
  F_FOSSILname := temp;
end;

Procedure F_Hangup;
Begin
  F_lowerdtr; { Drop DTR }
  delay(150);
  F_raisedtr;
  delay(1000);
  { If the modem can't handle DTR drops do the plain old ATH command! }
  if F_carrier then begin
    F_WritePort('+++');
    delay(1500);
    F_writeport('ATH'#13);
  end;
End;

Procedure F_CheckAhead(var c : char; var there : boolean); assembler;
Asm
  mov ah,0Ch
  mov dx,F_fosport
  int 14h
  xor bl,bl  { mov bl,False }
  cmp ax,0FFFFh
  je  @skip
  inc bl     { mov bl,True }
  les di,c
  stosb
@skip:
  les di,there
  mov al,bl
  stosb
End;

Procedure F_SendBreak; assembler;
Asm
  mov ah, $1a             { start sending break }
  mov al, $01
  mov dx, F_fosport
  int $14

  mov ax,1000             { Delay of 1000 ms }
  push ax
  call crt.delay

  mov ah, $1a             { stop sending break }
  mov al, $00
  mov dx, F_fosport
  int $14

  mov ah, $0A             { purge input buffer }
  mov dx, F_fosport
  int $14
end;

Procedure F_FlowControl(modemx, fossilx, rtscts : boolean);
var temp : byte;
begin
  temp := 0;
  if modemx then temp := temp and $1;
  if fossilx then temp := temp and $4;
  if rtscts then temp := temp and $2;
  asm
    mov ah, $07
    mov al, temp
    mov dx, F_fosport
    int $14
  end
end;

Procedure F_Reboot(How : Byte); Assembler;
Asm
  mov ah, $17
  mov al, how   { Determines cold or warm reboot }
  int $14
End;

Function F_Fossilpresent : boolean; Assembler;
asm
  mov ah, $04
  mov dx, $FF
  int $14
  cmp ax, $1954  { Subtract 1954 from ax }
  je @yes        { Jump if result = 0, ie they are the same }

  mov al, false  { No, fossil not present }
  jmp @done

 @yes:
  mov al, true   { Yes, there is a fossil }
 @done:
end;


end.
