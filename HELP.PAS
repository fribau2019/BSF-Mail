UNIT HELP;

Interface

 Procedure HelpMain;
 Procedure HelpOptionConfig;

Implementation
Uses DOS, CRT, RMDOOR;
{--------------------------------------------------------------------------}

Procedure HelpOptionConfig;
Var C : Char;

Begin;

 RmWriteln(''); RmWriteln('');
 RmWrite(' Which Help Do You Want (A-Z) : ');

 C := Upcase(RmReadKey);


 RmWriteln('');

 Case C of

  'A' : Begin;
         RmSetColor(10,0);
         RmWriteln('');
         RmWriteln(' INCLUDE THE WELCOME SCREEN :');
         RmSetColor(11,0);
         RmWriteln('');
         RmWriteln('   If This Option is set to YES, a copy of the Welcome screen (the screen');
         RmWriteln('    you see when you first log into the BBS) will be included in every');
         RmWriteln('    packet you download.');
         RmWriteln('');
         RmSetColor(15,0);
         RmWriteln('Press ENTER to continue...');
         Repeat until RmReadKey = #13;
       End;

  'B' : Begin;
         RmSetColor(10,0);
         RmWriteln('');
         RmWriteln(' INCLUDE NEW BULLETINS : ');
         RmSetColor(11,0);
         RmWriteln('');
         RmWriteln('   If this option is set to YES, all NEW bulletins will be added to your');
         RmWriteln('    mail packet.');
         RmWriteln('');
         RmSetColor(15,0);
         RmWriteln('Press ENTER to continue...');
         Repeat until RmReadKey = #13;
         End;

  'D' : Begin;
         RmSetColor(10,0);
         RmWriteln('');
         RmWriteln(' INCLUDE NEWS FILES : ');
         RmSetColor(11,0);
         RmWriteln('');
         RmWriteln('   If this option is set to YES, all updated NEWS files will be added to');
         Rmwriteln('    your mail packet.');
         RmWriteln('');
         RmSetColor(15,0);
         RmWriteln('Press ENTER to continue...');
         Repeat until RmReadKey = #13;
         End;
  'F' : Begin;
         RmSetColor(10,0);
         RmWriteln('');
         RmWriteln(' MAKE SMALL CONTROL.DAT : ');
         RmSetColor(11,0);
         RmWriteln('');
         RmWriteln('');
         RmSetColor(15,0);
         RmWriteln('Press ENTER to continue...');
         Repeat until RmReadKey = #13;
         End;

  'H' : Begin;
         RmSetColor(10,0);
         RmWriteln('');
         RmWriteln(' SEND USER INFORMATION : ');
         RmSetColor(11,0);
         RmWriteln('');
         RmWriteln('   BSFMail can include information on the current status of your BBS');
         RmWriteln('    membership inside a mail packet. However, this takes extra space');
         RmWriteln('    and causes a slightly longer download time. If you want this');
         RmWriteln('    information to be sent, set this option to YES.');
         RmWriteln('');
         RmSetColor(15,0);
         RmWriteln('Press ENTER to continue...');
         Repeat until RmReadKey = #13;
         End;
  'G' : Begin;
         RmSetColor(10,0);
         RmWriteln('');
         RmWriteln(' SEND NDX FILES :');
         RmSetColor(11,0);
         RmWriteln('');
         RmWriteln('   Most readers require an index (NDX) file for each conference that has');
         RmWriteln('    mail. If you are downloading mail for the sole purpose of netmail, the');
         RmWriteln('    index files is often not required and this option can be set to YES to');
         RmWriteln('    reduce transfer time.');
         RmWriteln('');
         RmSetColor(15,0);
         RmWriteln('Press ENTER to continue...');
         Repeat until RmReadKey = #13;
         End;

  'E' : Begin;
         RmSetColor(10,0);
         RmWriteln('');
         RmWriteln(' INCLUDE THE GOODBYE SCREEN :');
         RmSetColor(11,0);
         RmWriteln('');
         RmWriteln('   If This Option is set to YES, a copy of the Goodbye screen (the screen');
         RmWriteln('    you see when you log out to the BBS) will be included in every');
         RmWriteln('    packet you download.');
         RmWriteln('');
         RmSetColor(15,0);
         RmWriteln('Press ENTER to continue...');
         Repeat until RmReadKey = #13;
       End;

 End;

End;

{--------------------------------------------------------------------------}
Procedure HelpMain;

Var C : Char;

Begin;

 RmWriteln(''); RmWriteln('');
 RmWrite(' Which Help Do You Want : ');

 C := Upcase(RmReadKey);


 RmWriteln('');


 Case C Of

 'O' : Begin;
         RmSetColor(10,0);
         RmWriteln('');
         RmWriteln(' CONFIGURATION OPTION HELP :');
         RmSetColor(11,0);
         RmWriteln('');
         RmWriteln('   This option will bring you to a sub-menu which contains various');
         RmWriteln('    parameters used to tailor BSFMail to your needs. For help on each');
         RmWriteln('    individual setting option, use the ''O''ptions command and then');
         RmWriteln('    ask for ?]Help.');
         RmWriteln('');
         RmSetColor(15,0);
         RmWriteln('Press ENTER to continue...');
         Repeat until RmReadKey = #13;
       End;
 'C' :  Begin;
         RmSetColor(10,0);
         RmWriteln('');
         RmWriteln(' COMPRESSION MODE HELP :');
         RmSetColor(11,0);
         RmWriteln('');
         RmWriteln('   In order to cut down on transfer time, BSFMail compresses your messages.');
         RmWriteln('    In order to extract your messages after transmission, you will need a ');
         RmWriteln('    supported compression program (such as PKZIP).');
         RmWriteln('');
         RmWriteln('   Most of these programs are available as ShareWare and can be downloaded');
         RmWriteln('    from your local BBS');
         RmWriteln('');
         RmWriteln('   A Shareware program cannot be continuously used for free after an initial');
         RmWriteln('    trial period. Please read the ShareWare notices included with any program');
         RmWriteln('    downloaded and donate where appropriate.');
         RmWriteln('');
         RmWriteln('   This option allows tou select which compression method tu use.');
         RmWriteln('');
         RmSetColor(15,0);
         RmWriteln('Press ENTER to continue...');
         Repeat until RmReadKey = #13;
       End;

 'P' :;

 'S' : Begin;
         RmSetColor(10,0);
         RmWriteln('');
         RmWriteln(' SELECT MESSAGE CONFERENCES HELP :');
         RmSetColor(11,0);
         RmWriteln('');
         RmWriteln('   This option is used to tell BSFMail what conference you want scanned for');
         RmWriteln('    mail and what type of mail you want. Conferences can be selected by');
         RmWriteln('    number. When you select a conference, you will be asked if you want to');
         RmWriteln('    scan for [P]ersonal messages, [A]ll messages, [Y]ours and at ''All'' or');
         RmWriteln('    [N]one for deselect the conference. Selecting [P]ersonal allows you to');
         RmWriteln('    download mail addressed to you, [A]ll will send you every message,');
         RmWriteln('    [Y]ours will send to you all messages adressed to you and at ''All''.');
         RmWriteln('');
         RmWriteln('   Ranges of conferences can be modified by entering of the following :');
         RmWriteln(' þ [ALL] : Select all the conference allowed by the sysop for you.');
         RmWriteln('            If the command [ALL] if alone, default conference scan is for');
         RmWriteln('            ALL, you can also select all the conference with the type you');
         RmWriteln('            want, simply put after the [ALL] :');
         RmWriteln('              - [PERSO] if you want all conference personal');
         RmWriteln('              - [YALL] for personal message and at ''ALL''');
         RmWriteln('              - [NET] for take all conference which Net Status');
         RmWriteln('              - [NONET] for deselect all conference which Net Status');

         RmWriteln('');
         RmSetColor(15,0);
         RmWriteln('Press ENTER to continue...');
         Repeat until RmReadKey = #13;
         RmWriteln('');
         RmSetColor(11,0);

         RmWriteln('              - [SIZE #] to set msg pointers.');
         RmWriteln('                    Also, # can be : - numbers : Set pointers back from');
         RmWriteln('                                                  the highest msg number');
         RmWriteln('                                     - [HIGH]  : Set Higher pointers');
         RmWriteln('                                     - [LOW]   : Set Lower  Pointers');
         RmWriteln('        For Example, you can have : - ALL');
         RmWriteln('                                    - ALL PERSO');
         RmWriteln('                                    - ALL SIZE 100');
         RmWriteln('                                    - ALL SIZE HIGH');
         RmWriteln('');
         RmWriteln(' þ [#1..#2] : Select Conference From #1 to #2. Option Are :');
         RmWriteln('                 - [NONE]  : To deselect conference from #1 to #2');
         RmWriteln('                 - [ALL]   : To select scan conference at ''All''');
         RmWriteln('                 - [YALL]  : For your message and at ''All''');
         RmWriteln('                 - [PERSO] : For your personal messages');
         RmWriteln('                 - [SIZE !]: To set msg pointers.');
         RmWriteln('                    Also, ! can be : - numbers : Set pointers back from');
         RmWriteln('                                                  the highest msg number');
         RmWriteln('                                     - [HIGH]  : Set Higher pointers');
         RmWriteln('                                     - [LOW]   : Set Lower  Pointers');
         RmWriteln('');
         RmSetColor(15,0);
         RmWriteln('Press ENTER to continue...');
         Repeat until RmReadKey = #13;
         RmWriteln('');
         RmSetColor(11,0);
         RmWriteln('        For Example, you can have : - 1..15 ALL');
         RmWriteln('                                    - 1..17 PERSO');
         RmWriteln('                                    - 1..10 SIZE LOW');
         RmWriteln('');
         RmWriteln(' þ [RESET] : To Deselect all conferences');

         RmWriteln('');
         RmSetColor(15,0);
         RmWriteln('Press ENTER to continue...');
         Repeat until RmReadKey = #13;
       End;


 'D' : Begin;
         RmSetColor(10,0);
         RmWriteln('');
         RmWriteln(' DOWNLOAD MAIL PACKET HELP :');
         RmSetColor(11,0);
         RmWriteln('');
         RmWriteln('   This option will create a message packet for you to download. In order');
         RmWriteln('    for this command to work correctly, please select which conferences you');
         RmWriteln('    would like scanned for messages by using the S]elect conferences option');
         RmWriteln('    in the main menu.');
         RmWriteln('');
         RmSetColor(15,0);
         RmWriteln('Press ENTER to continue...');
         Repeat until RmReadKey = #13;
       End;


 'U' :  Begin;
         RmSetColor(10,0);
         RmWriteln('');
         RmWriteln(' UPLOAD MAIL PACKET HELP :');
         RmSetColor(11,0);
         RmWriteln('');
         RmWriteln('   This option allows you to send a collection of messages that you have');
         RmWriteln('    created offline using compatible message reader.');
         RmWriteln('');
         RmWriteln('   Before you upload, be sure you have the correct transfer protocol');
         RmWriteln('    selection.');
         RmWriteln('');
         RmSetColor(15,0);
         RmWriteln('Press ENTER to continue...');
         Repeat until RmReadKey = #13;
       End;

 'M' :  Begin;
         RmSetColor(10,0);
         RmWriteln('');
         RmWriteln(' COLOR MODE TOGGLE HELP :');
         RmSetColor(11,0);
         RmWriteln('');
         RmWriteln('   If you are using a monochrome display, or dislike the colors BSFMail sends');
         RmWriteln('    in its screen, you may use this option to turn off colors.');
         RmWriteln('');
         RmWriteln('   The ''M'' command is a toggle in that it will switch from monochrome mode to');
         RmWriteln('    color mode or from color mode to monochrome mode.');

         RmWriteln('');
         RmSetColor(15,0);
         RmWriteln('Press ENTER to continue...');
         Repeat until RmReadKey = #13;
       End;


 'X' :  Begin;
         RmSetColor(10,0);
         RmWriteln('');
         RmWriteln(' EXPERT MODE TOGGLE HELP :');
         RmSetColor(11,0);
         RmWriteln('');
         RmWriteln('   The ''X'' command will suppress the display of the menus and informative');
         RmWriteln('    prompts found in BSFMail.');
         RmWriteln('');
         RmWriteln('   As this is a toggle, it will switch from least informative prompting to ');
         RmWriteln('    most informative prompting or from most informative to least informative.');
         RmWriteln('');
         RmSetColor(15,0);
         RmWriteln('Press ENTER to continue...');
         Repeat until RmReadKey = #13;
       End;

 'G' :;

 'Q' :;

 End;

End;
{--------------------------------------------------------------------------}

End.