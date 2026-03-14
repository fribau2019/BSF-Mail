UNIT MGRDeflt;

{$I LANGAGE.DIR}

Interface

Uses MGRVaria,
     BSFConst,
     BSFUtils;

 Function LoadConfiguration(Var Config : ConfigurationDoor) : Boolean;

Implementation

Uses DOS,
     CRT;

{-------------------------------------------------------------------------}
Procedure LoadConfig(Var Config : ConfigurationDoor);
{$I E:\SOURCE~1\PASCAL\NETMAIL\CONFIG.PAS}
{-------------------------------------------------------------------------}
Function LoadConfiguration(Var Config : ConfigurationDoor) : Boolean;
TYPE

(* SFNODE.DAT *)
  NodeSysRec    = Record
                   DirectScrn,
                   ShowResult    : Boolean;
                   RamDrive      : Char;
                   PrinterOn,
                   AnsiAvl,
                   Private,
                   SecondPassword,
                   Page_On       : Boolean;
                   MinimumBaud   : Word;
                   MsgInfo,
                   NewFileInfo,
                   SoftControl,
                   AvailableBoo  : Boolean;
                   CorrectionMsg : String[3];
                   WorkPath,
                   DisplayPath,
                   ExtranPath,
                   MsgPath       : String[28];
                   ModInitStr    : String[56];
                   ComPort       : Word;
                   RingNo,
                   Node          : Byte;
                   MaxBaud,
                   ExtraLong     : LongInt;
                   TimeComp      : Real;
                   LastDate      : String[8];
                   PrivateSec    : Integer;
                   HangUpDelay   : Byte;
                   UseHiSpeed,
                   AvailBoolean  : Boolean;
                   IRQ1,
                   IRQ2,
                   IRQ3,
                   IRQ4,
                   IRQ5,
                   IRQ6,
                   IRQ7,
                   IRQ8          : Byte;
                   BreakLen      : Word;
                   FaxConnectMsg : String[7];
                   PreInitStr    : String[6];
                   SubChgSec     : Word;
                   StartWarn     : Byte;
                   ExtraBytes    : Array[0..3] Of Byte;
                   ColorMonitor  : Boolean;
                   OffHookStr    : String[6];
                   ComBase       : Array[1..8] Of Word;
                   AnswerStr     : String[30];
                   NewExtra      : Array[0..201] Of Byte;
                  End;
Var
    SFNodeF : File Of NodeSysRec;
    SFNode  : NodeSysRec;
    ConfigF : Text;
    NomConf : String;
    C       : Char;

Begin;
(**** Charge le BSFMAIL.CFG ***)
 NomConf := '';

{ Recherche commande environnement BSFMAIL}
 Swapvectors;
  NomConf := GetEnv('BSFMAIL');
 Swapvectors;


 If Not FileExists(NomConf) Then
  Begin;
   TextColor(11); TextBackGround(0);
  {$IFDEF ENGLISH}
   WriteCenter('±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±');
   WriteCenter('±                                        ±');
   WriteCenter('± Please First Select DOOR CONFIGURATION ±');
   WriteCenter('±                                        ±');
   WriteCenter('±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±');
  {$ELSE}
   WriteCenter('±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±',(Hi(WindMax) Div 2) - 2);
   WriteCenter('±                                                           ±',(Hi(WindMax) Div 2) - 1);
   WriteCenter('± Veuillez S‚lectionner En Premier CONFIGURATION DE BSFMAIL ±',(Hi(WindMax) Div 2));
   WriteCenter('±                                                           ±',(Hi(WindMax) Div 2) + 1);
   WriteCenter('±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±',(Hi(WindMax) Div 2) + 2);
  {$ENDIF}
   Delay(1500);
   LoadConfiguration := False;
   Exit;
  End
 Else LoadConfig(Config);


(*** Charge Les Donn‚es Manquantes Du Config A Partir Du NodeSysRec ***)

 Assign(SfNodeF, Config.SFDir+'SFNODE.DAT');
 {$I-} Reset(SFNodeF); {$I+}
 If Ioresult <> 0 Then Begin;
                        Writeln(^g);
                       {$IFDEF ENGLISH}
                        Writeln('Please Select Again DOOR CONFIGURATION !');
                       {$ELSE}
                        Writeln('Veuillez Res‚lectionner La CONFIGURATION BSFMAIL !');
                       {$ENDIF}
                        Delay(1500);
                        LoadConfiguration := False;
                        Exit;
                       End;
 Seek(SFNodeF, 0);
 Read(SFNodeF, SFNode);
  Config.WorkDir := SFNode.WorkPath;
  Config.MsgDir  := SFNode.MsgPath;
 Close(SFNodeF);
 LoadConfiguration := True;
End;
{-------------------------------------------------------------------------}

End.