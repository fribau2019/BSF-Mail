{$F-}

Unit BSFSwap;

Interface

Uses
  Dos, checkpat;

const

{e Return codes (only upper byte significant) }

   RC_PREPERR   = $0100;
   RC_NOFILE    = $0200;
   RC_EXECERR   = $0300;
   RC_ENVERR    = $0400;
   RC_SWAPERR   = $0500;
   RC_REDIRERR  = $0600;

{e Swap method and option flags }


   USE_EMS      =  $01;
   USE_XMS      =  $02;
   USE_FILE     =  $04;
   EMS_FIRST    =  $00;
   XMS_FIRST    =  $10;
   HIDE_FILE    =  $40;
   NO_PREALLOC  = $100;
   CHECK_NET    = $200;

   USE_ALL      = USE_EMS or USE_XMS or USE_FILE or CHECK_NET;


type
    filename = string [81];
    string128 = string [128];
    pstring = ^string;


function DosShell (xfn: string; pars: string; spawn: integer;
                  needed: word; newenv: boolean): integer;


   {>e
      The EXEC function.

      Parameters:

         xfn      is a string containing the name of the file
                  to be executed. If the string is empty,
                  the COMSPEC environment variable is used to
                  load a copy of COMMAND.COM or its equivalent.
                  If the filename does not include a path, the
                  current PATH is searched after the default.
                  If the filename does not include an extension,
                  the path is scanned for a COM, EXE, or BAT file 
                  in that order.

         pars     The program parameters.

         spawn    If 0, the function will terminate after the 
                  EXECed program returns, the function will not return.

                  NOTE: If the program file is not found, the function
                        will always return with the appropriate error 
                        code, even if 'spawn' is 0.

                  If non-0, the function will return after executing the
                  program. If necessary (see the "needed" parameter),
                  memory will be swapped out before executing the program.
                  For swapping, spawn must contain a combination of the
                  following flags:

                     USE_EMS  ($01)  - allow EMS swap
                     USE_XMS  ($02)  - allow XMS swap
                     USE_FILE ($04)  - allow File swap

                  The order of trying the different swap methods can be
                  controlled with one of the flags

                     EMS_FIRST ($00) - EMS, XMS, File (default)
                     XMS_FIRST ($10) - XMS, EMS, File

                  If swapping is to File, the attribute of the swap file
                  can be set to "hidden", so users are not irritated by
                  strange files appearing out of nowhere with the flag

                     HIDE_FILE ($40) - create swap file as hidden

                  and the behaviour on Network drives can be changed with

                     NO_PREALLOC (0x100) - don't preallocate
                     CHECK_NET (0x200)   - don't preallocate if file on net.

                  This checking for Network is mainly to compensate for
                  a strange slowdown on Novell networks when preallocating
                  a file. You can either set NO_PREALLOC to avoid allocation
                  in any case, or let the prep_swap routine decide whether
                  to do preallocation or not depending on the file being
                  on a network drive (this will only work with DOS 3.1 or 
                  later).

         needed   The memory needed for the program in paragraphs (16 Bytes).
                  If not enough memory is free, the program will
                  be swapped out.
                  Use 0 to never swap, $ffff to always swap.
                  If 'spawn' is 0, this parameter is irrelevant.

         newenv   If this parameter is FALSE, the environment
                  of the spawned program is a copy of the parent's
                  environment. If it is TRUE, a new environment
                  is created which includes the modifications from
                  previous 'putenv' calls.

      Return value:

         $0000..00FF: The EXECed Program's return code

         $0101:       Error preparing for swap: no space for swapping
         $0102:       Error preparing for swap: program too low in memory

         $0200:       Program file not found
         $0201:       Program file: Invalid drive
         $0202:       Program file: Invalid path
         $0203:       Program file: Invalid name
         $0204:       Program file: Invalid drive letter
         $0205:       Program file: Path too long
         $0206:       Program file: Drive not ready
         $0207:       Batchfile/COMMAND: COMMAND.COM not found
         $0208:       Error allocating temporary buffer

         $03xx:       DOS-error-code xx calling EXEC

         $0400:       Error allocating environment buffer

         $0500:       Swapping requested, but prep_swap has not
                       been called or returned an error.
         $0501:       MCBs don't match expected setup
         $0502:       Error while swapping out

         $0600:       Redirection syntax error
         $06xx:       DOS error xx on redirection

   The function pointed to by "spawn_check" will be called immediately 
   before doing the actual swap/exec, provided that

      - the preparation code did not detect an error, and
      - "spawn_check" is not NIL.

   The function definition is
      function name (cmdbat: integer; swapping: integer; var execfn: string; 
                     var progpars: string): integer;

   The parameters passed to this function are

      cmdbat      1: Normal EXE/COM file
                  2: Executing BAT file via COMMAND.COM
                  3: Executing COMMAND.COM (or equivalent)

      swapping    < 0: Exec, don't swap
                    0: Spawn, don't swap
                  > 0: Spawn, swap

      execfn      the file name to execute (complete with path)

      progpars    the program parameter string

   If the routine returns anything other than 0, the swap/exec will
   not be executed, and do_exec will return with this code.

   You can use this function to output messages (for example, the
   usual "enter EXIT to return" message when loading COMMAND.COM)
   and to do clean-up and additional checking.

   CAUTION: If swapping is > 0, the routine may not modify the 
   memory layout, i.e. it may not call any memory allocation or
   deallocation routines.

   "spawn_check" is initialized to NIL.
<}

type
   spawn_check_proc = function (cmdbat: integer; swapping: integer;
                                var execfn: string; var progpars: string)
                               : integer;
var
   spawn_check: spawn_check_proc;

{>e
   The 'swap_prep' variable can be accessed from the spawn_check
   call-back routine for additional information on the nature and
   parameters of the swap. This variable will ONLY hold useful
   information if the 'swapping' parameter to spawn_check is > 0.
   The contents of this variable may not be changed.

   The 'swapmethod' field will contain one of the flags USE_FILE,
   USE_XMS, or USE_EMS.

   Note that the 'swapfilename' field contains a zero-terminated string
   with no prefixed length byte, not a Pascal string.
<}

type
   prep_block = record
                  xmm: longint;           {e XMM entry address }
                                          {d Einsprungadresse XMM }
                  first_mcb: integer;     {e Segment of first MCB }
                                          {d Segment des ersten MCB }
                  psp_mcb: integer;       {e Segment of MCB of our PSP }
                                          {d Segment des MCB unseres PSP }
                  env_mcb: integer;       {e MCB of Environment segment }
                                          {d MCB des Umgebungsvariablenblocks }
                  noswap_mcb: integer;    {e MCB that may not be swapped }
                                          {d MCB der nicht Ausgelagert wird }
                  ems_pageframe: integer; {e EMS page frame address }
                                          {d EMS-Seiten-Adresse }
                  handle: integer;        {e EMS/XMS/File handle }
                                          {d Handle fÅr EMS/XMS/Datei }
                  total_mcbs: integer;    {e Total number of MCBs }
                                          {d Gesamtzahl MCBs }
                  swapmethod: byte;       {e Method for swapping }
                                          {d Auslagerungsmethode }
                  swapfilename: array [0..80] of char;
                                          {e Swap file name if swapping to file }
                                          {d Auslagerungsdateiname }
                  end;

var
   swap_prep: prep_block;

{ ------------------------------------------------------------------------- }

procedure putenv (envvar: string);
{  Adds a string to the environment. Note that the change to the
   environment is valid for an exec'ed process only, and only if you
   set the 'newenv' parameter in do_exec to TRUE. }


function envcount: integer;
function envstr (index: integer): string;
function getenv (envvar: string): string;

{ Replacement functions for the environment handling functions in the
  DOS unit. All three functions work exactly like their DOS-unit
  counterparts, except that they recognize the changes to the child
  environment produced by 'putenv'. }



{===========================================================================}

Implementation

{>e
   Define REDIRECT to support redirection.
   CAUTION: The definition in 'spawn.asm' must match this definition!!
<}

{$DEFINE REDIRECT}

const
   swap_filename = '$BSFMAIL.BSF';

   {e internal flags for prep_swap }

   CREAT_TEMP      = $0080;
   DONT_SWAP_ENV   = $4000;

   ERR_COMSPEC     = -7;
   ERR_NOMEM       = -8;

   spaces: set of #9..' ' = [#9, ' '];

type
   stringptr = ^string;
   stringarray = array [0..10000] of stringptr;
   stringarrptr = ^stringarray;
   bytearray = array [0..30000] of byte;
   bytearrayptr = ^bytearray;

var
   envptr: stringarrptr;   { Pointer to the changed environment }
   envcnt: integer;        { Count of environment strings }
   cmdpath: string;
   cmdpars: string;
   drive: string [3];
   dir: string [67];
   name: string [9];
   ext: string [5];


{$L spawnp}
function do_spawn (swapping: integer;
                   var xeqfn; var cmdtail; envlen: word;
                   var env
{$IFDEF REDIRECT}
                   ;stdin: pstring; stdout: pstring; stderr: pstring
{$ENDIF}
                   ): integer; external;

function prep_swap (method: integer; var swapfn): integer; external;


{ helper routine }

function strpbrk (par, pattern: string): integer;
   { find position of any one of the characters in 'pattern' in string 'par' }
   var
      i: integer;
   begin
   for i := 1 to length (par) do
      if pos (par [i], pattern) > 0
         then begin
         strpbrk := i;
         exit;
         end;
   strpbrk := 0;
   end;
     
{ Environment routines }

function envcount: integer;

   { Returns count of strings in environment. }

   var
      cnt: integer;
   begin
   if envptr = nil { If not yet changed }
      then envcount := dos.envcount
      else envcount := envcnt;
   end;


function envstr (index: integer): string;

   { Returns environment string 'index' }

   begin
   if envptr = nil { If not yet changed }
      then envstr := dos.envstr (index)
      else if (index <= 0) or (index >= envcnt)
      then envstr := ''
      else if envptr^ [index - 1] = nil
      then envstr := ''
      else envstr := envptr^ [index - 1]^;
   end;


function name_eq (var n1, n2: string): boolean;

   { Compares search string 'n1' with environment string 'n2'.
     Case is insignificant. }

   var
      i: integer;
      eq: boolean;
   begin
   i := 1;
   eq := false;
   while (i <= length (n1)) and (i <= length (n2)) and
         (upcase (n1 [i]) = upcase (n2 [i])) do
      i := i + 1;
   name_eq := (i > length (n1)) and (i <= length (n2)) and (n2 [i] = '=');
   end;


function searchenv (var str: string): integer;

   { Search for environment string, returns index in 'envptr' array.
     Assumes 'envptr' is not NIL. }

   var
      idx: integer;
      found: boolean;
   begin
   idx := 0;
   found := false;

   while (idx < envcnt) and not found do
      begin
      if envptr^ [idx] <> nil
         then found := name_eq (str, envptr^ [idx]^);
      idx := idx + 1;
      end;
   if not found
      then searchenv := -1
      else searchenv := idx - 1;
   end;


function getenv (envvar: string): string;

   { Returns value of environment string specified by name. }

   var
      strp: stringptr;
      eq: integer;
   begin
   if envptr = nil { If not yet changed }
      then getenv := dos.getenv (envvar)
      else begin
      eq := searchenv (envvar);
      if eq < 0
         then getenv := ''
         else begin
         strp := envptr^ [eq];
         eq := pos ('=', strp^);
         getenv := copy (strp^, eq + 1, length (strp^) - eq);
         end;
      end;
   end;


procedure init_envptr;

   { Initialise 'envptr' array. Called when 'putenv' is used for the
     first time. Copies all environment strings into heap storage,
     and builds an array of pointers to this strings. }

   var
      i: integer;
      str: string [255];
   begin
   envcnt := dos.envcount;
   getmem (envptr, envcnt * sizeof (stringptr));
   if envptr = nil
      then exit;
   for i := 0 to envcnt - 1 do
      begin
      str := dos.envstr (i + 1);
      getmem (envptr^ [i], length (str) + 1);
      if envptr^ [i] <> nil
         then envptr^ [i]^ := str;
      end;
   end;


procedure putenv (envvar: string);

   { Adds the string 'envvar' to the environment, or changes the
     environment string if the name is already present. }

   var
      idx, eq: integer;
      help: stringarrptr;
      tmpvar : string;
   begin
   if envptr = nil
      then init_envptr;
   if envptr = nil
      then exit;

   eq := pos ('=', envvar);
   if eq = 0
      then exit;
   for idx := 1 to eq do
      envvar [idx] := upcase (envvar [idx]);
   tmpvar := copy (envvar, 1, eq - 1); { Copy the portion up to "=" }

   idx := searchenv (tmpvar);
   if idx >= 0
      then begin
      freemem (envptr^ [idx], length (envptr^ [idx]^) + 1);

      if eq >= length (envvar)
         then envptr^ [idx] := nil
         else begin
         getmem (envptr^ [idx], length (envvar) + 1);
         if envptr^ [idx] <> nil
            then envptr^ [idx]^ := envvar;
         end;
      end
      else if eq < length (envvar)
      then begin
      getmem (help, (envcnt + 1) * sizeof (stringptr));
      if help = nil
         then exit;
      move (envptr^, help^, envcnt * sizeof (stringptr));
      freemem (envptr, envcnt * sizeof (stringptr));
      envptr := help;
      getmem (envptr^ [envcnt], length (envvar) + 1);
      if envptr^ [envcnt] <> nil
         then envptr^ [envcnt]^ := envvar;
      envcnt := envcnt + 1;
      end;
   end;



{ Routines to search for files }

function tryext (var fn: string): integer;

   { Try '.COM', '.EXE', and '.BAT' on current filename, modify filename if found. }

   var
      nfn: filename;
      ok: boolean;
   begin
   tryext := 1;
   nfn := fn + '.COM';
   ok := exists (nfn);
   if not ok
      then begin
      nfn := fn + '.EXE';
      ok := exists (nfn);
      end;
   if not ok
      then begin
      tryext := 2;
      nfn := fn + '.BAT';
      ok := exists (nfn);
      end;
   if not ok
      then tryext := 0
      else fn := nfn;
   end;


function findfile (var fn: string): integer;

   { Try to find the file 'fn' in the current path. Modifies the filename
     accordingly. }

   var
      path: string;
      i, j: integer;
      hasext, found, check: integer;
   begin
   if fn = ''
      then begin
      if cmdpath = ''
         then findfile := ERR_COMSPEC
         else findfile := 3;
      exit;
      end;

   check := checkpath (fn, INF_NODIR, drive, dir, name, ext, fn);
   if check < 0
      then begin
      findfile := check;
      exit;
      end;

   if ((check and HAS_WILD) <> 0) or ((check and HAS_FNAME) = 0)
      then begin
      findfile := ERR_FNAME;
      exit;
      end;

   if (check and HAS_EXT) <> 0
      then begin
      for i := 1 to length (ext) do
         ext [i] := upcase (ext [i]);
      if ext = '.BAT'
         then hasext := 2
         else hasext := 1;
      end
      else hasext := 0;

   if hasext <> 0
      then begin
      if (check and FILE_EXISTS) <> 0
         then found := hasext
         else found := 0;
      end
      else found := tryext (fn);

   if (found <> 0) or ((check and (HAS_PATH or HAS_DRIVE)) <> 0)
      then begin
      findfile := found;
      exit;
      end;

   path := getenv ('PATH');
   i := 1;
   while (found = 0) and (i <= length (path)) do
      begin
      j := 0;
      while (path [i] <> ';') and (i <= length (path)) do
         begin
         j := j + 1;
         fn [j] := path [i];
         i := i + 1;
         end;
      i := i + 1;
      if (j > 0)
         then begin
         if not (fn [j] in ['\', '/'])
            then begin
            j := j + 1;
            fn [j] := '\';
            end;
         fn [0] := chr (j);
         fn := fn + name + ext;
         check := checkpath (fn, INF_NODIR, drive, dir, name, ext, fn);
         if hasext <> 0
            then begin
            if (check and FILE_EXISTS) <> 0
               then found := hasext
               else found := 0;
            end
            else found := tryext (fn);
         end;
      end;
   findfile := found;
   end; { findfile }


{>e 
   Get name and path of the command processor via the COMSPEC
   environmnt variable. Any parameters after the program name
   are copied and inserted into the command line.
<}
{>d
   Namen und Pfad des Kommandoprozessors Åber die COMSPEC-Umgebungs-
   Variable bestimmen. Parameter nach dem Programmnamen werden kopiert
   und in die Kommandozeile eingefÅgt.
<}

procedure getcmdpath;
   var
      i, found: integer;
   begin
   if length (cmdpath) > 0
      then exit;
   cmdpath := getenv ('COMSPEC');
   cmdpars := '';
   found := 0;

   if cmdpath <> ''
      then begin
      i := 1;
      while (i <= length (cmdpath)) and (cmdpath [i] in spaces) do
         inc (i);
      if i > 1
         then begin
         cmdpath := copy (cmdpath, i, 255);
         i := 1;
         end;

      i := strpbrk (cmdpath, ';,=+/"[]|<> '#9);
      if i <> 0
         then begin
         cmdpars := copy (cmdpath, i, 128);
         cmdpath [0] := chr (i - 1);
         i := 1;
         while (i <= length (cmdpars)) and (cmdpars [i] in spaces) do
            inc (i);
         if i > 1
            then cmdpars := copy (cmdpars, i, 128);
         if cmdpars <> ''
            then cmdpars := cmdpars + ' ';
         end;
      found := findfile (cmdpath);
      end;

   if found = 0
      then begin
      cmdpath := 'COMMAND.COM';
      cmdpars := '';
      found := findfile (cmdpath);
      if found = 0
         then cmdpath := '';
      end;
   end;


function tempdir (var outfn: filename): boolean;

   { Set temporary file path.
     Read "TMP/TEMP" environment. If empty or invalid, clear path.
     If TEMP is drive or drive+backslash only, return TEMP.
     Otherwise check if given path is a valid directory.
   }
   var
      stmp: array [0..3] of filename;
      i, res: integer;

   begin
   stmp [0] := getenv ('TMP');
   stmp [1] := getenv ('TEMP');
   stmp [2] := '.\';
   stmp [3] := '\';

   for i := 0 to 3 do
      if length (stmp [i]) <> 0
         then begin
         outfn := stmp [i];
         res := checkpath (outfn, 0, drive, dir, name, ext, outfn);
         if (res > 0) and ((res and IS_DIR) <> 0) and ((res and IS_READ_ONLY) = 0)
            then begin
            tempdir := true;
            exit;
            end;
         end;
   tempdir := false;
   end;


{$IFDEF REDIRECT}

function parse_redirect (var par: string; idx: integer;
                         var stdin, stdout, stderr: pstring): boolean;
   var
      ch: char;
      fnp: pstring;
      fn: string;
      app, i, beg, fne: integer;

   begin
   i := idx;
   par [length (par) + 1] := #0;

   repeat
      app := 0;
      ch := par [i];
      beg := i;
      i := i + 1;
      if ch <> '<'
         then begin
         if par [i] = '&'
            then begin
            ch := '&';
            inc (i);
            end;
         if par [i] = '>'
            then begin
            app := 1;
            inc (i);
            end;
         end;

      while (i <= length (par)) and (par [i] in spaces) do
         inc (i);
      fn := copy (par, i, 255);
      fne := strpbrk (fn, ';,=+/"[]|<> '#9);
      if fne = 0
         then fne := length (fn) + 1;
      par := copy (par, 1, beg - 1) + copy (fn, fne, 255);
      i := beg;
      fn [0] := chr (fne - 1);
      if (fne = 0) or (length (fn) = 0)
         then begin
         parse_redirect := false;
         exit;
         end;
      
      getmem (fnp, length (fn) + app + 2);
      if fnp = NIL
         then begin
         parse_redirect := false;
         exit;
         end;
      if app <> 0
         then fnp^ := '>' + fn
         else fnp^ := fn;
      fnp^ [length (fnp^) + 1] := #0;

      case ch of
         '<':  if stdin <> NIL
                  then begin
                  parse_redirect := false;
                  exit;
                  end
               else stdin := fnp;

         '>':  if stdout <> NIL
                  then begin
                  parse_redirect := false;
                  exit;
                  end
               else stdout := fnp;

         '&':  if stderr <> NIL
                  then begin
                  parse_redirect := false;
                  exit;
                  end
               else stderr := fnp;
         end;

      i := strpbrk (fn, '<>');
   until (i <= 0);

   par [length (par) + 1] := #0;
   parse_redirect := true;
   end;

{$ENDIF}


function DosShell(xfn: string; pars: string; spawn: integer;
                  needed: word; newenv: boolean): integer;
   label
      exit;
   var
      cmdbat: integer;
      swapfn: filename;
      avail: word;
      regs: registers;
      envlen, einx: word;
      idx, len, rc: integer;
      envp: bytearrayptr;
      swapping: integer;
{$IFDEF REDIRECT}
      stdin, stdout, stderr: pstring;
{$ENDIF}
   begin
{$IFDEF REDIRECT}
   stdin := NIL; stdout := NIL; stderr := NIL;
{$ENDIF}

   getcmdpath;
   envlen := 0;

   { First, check if the file to execute exists. }

   cmdbat := findfile (xfn);
   if cmdbat <= 0
      then begin
      DosShell := RC_NOFILE or -cmdbat;
      goto exit;
      end;

   if cmdbat > 1   { COMMAND.COM or Batch file }
      then begin
      if length (cmdpath) = 0
         then begin
         DosShell:= RC_NOFILE or -ERR_COMSPEC;
         goto exit;
         end;

      if cmdbat = 2
         then pars := cmdpars + '/c ' + xfn + ' ' + pars
         else pars := cmdpars + pars;
      xfn := cmdpath;
      end;

{$IFDEF REDIRECT}
   idx := strpbrk (pars, '<>');
   if idx > 0
      then if not parse_redirect (pars, idx, stdin, stdout, stderr)
         then begin
         DosShell := RC_REDIRERR;
         goto exit;
         end;
{$ENDIF}

   { Now create a copy of the environment if the user wants it, and
     if the environment has been changed. }

   if newenv and (envptr <> nil)
      then begin
      for idx := 0 to envcnt - 1 do
         envlen := envlen + length (envptr^ [idx]^) + 1;
      if envlen > 0
         then begin
         envlen := envlen + 1;
         getmem (envp, envlen);
         if envp = nil
            then begin
            DosShell := RC_ENVERR;
            goto exit;
            end;
         einx := 0;
         for idx := 0 to envcnt - 1 do
            begin
            len := length (envptr^ [idx]^);
            move (envptr^ [idx]^ [1], envp^ [einx], len);
            envp^ [einx + len] := 0;
            einx := einx + len + 1;
            end;
         envp^ [einx] := 0;
         end;
      end;

   if spawn = 0
      then swapping := -1
      else begin

      { Determine amount of free memory }
      with regs do
         begin
         ax := $4800;
         bx := $ffff;
         msdos (regs);
         avail := regs.bx;
         end;

      { No swapping if available memory > needed }

      if needed < avail
         then swapping := 0
         else begin

         { Swapping necessary, use 'TMP' or 'TEMP' environment variable
           to determine swap file path if defined. }

         swapping := spawn;
         if (spawn and USE_FILE) <> 0
            then begin
            if not tempdir (swapfn)
               then begin
               spawn := spawn xor USE_FILE;
               swapping := spawn;
               end
               else begin
               if (dosversion and $ff) >= 3
                  then swapping := swapping or CREAT_TEMP
                  else begin
                  swapfn := swapfn + swap_filename;
                  len := length (swapfn);
                  while exists (swapfn) do
                     begin
                  	if (swapfn [len] >= 'Z')
                        then len := len - 1;
                  	if (swapfn [len] = '.')
                        then len := len - 1;
                  	swapfn [len] := succ (swapfn [len]);
                  	end;
                  end;
               swapfn [length (swapfn) + 1] := #0;
               end;
            end;
         end;
      end;

   { All set up, ready to go. }

   if swapping > 0
      then begin
      if envlen = 0
         then swapping := swapping or DONT_SWAP_ENV;

      rc := prep_swap (swapping, swapfn);
      if rc < 0
         then begin
         DosShell := RC_PREPERR or -rc;
         goto exit;
         end;
      end;

   xfn [length (xfn) + 1] := #0;
   pars [length (pars) + 1] := #0;

   if @spawn_check <> NIL
      then begin
      rc := spawn_check (cmdbat, swapping, xfn, pars);
      if rc <> 0
         then begin
         DosShell := rc;
         goto exit;
         end;
      end;

   swapvectors;
{$IFDEF REDIRECT}
   DosShell := do_spawn (swapping, xfn, pars, envlen, envp^, stdin, stdout, stderr);
{$ELSE}
   DosShell := do_spawn (swapping, xfn, pars, envlen, envp^);
{$ENDIF}
   swapvectors;

   { Free the environment buffer if it was allocated. }

exit:
   if envlen > 0
      then freemem (envp, envlen);
{$IFDEF REDIRECT}
   if stdin <> NIL
      then freemem (stdin, length (stdin^) + 2);
   if stdout <> NIL
      then freemem (stdout, length (stdout^) + 2);
   if stderr <> NIL
      then freemem (stderr, length (stderr^) + 2);
{$ENDIF}
   end;


{ Initialisation for environment processing }

Begin
envptr := nil;
envcnt := 0;
cmdpath := '';
@spawn_check := nil;
End.

(*

Interface

Uses
  Dos,
  Checkpat;

const

{e Return codes (only upper byte significant) }
{d Fehlercodes (nur das obere Byte signifikant) }

   RC_PREPERR   = $0100;
   RC_NOFILE    = $0200;
   RC_EXECERR   = $0300;
   RC_ENVERR    = $0400;
   RC_SWAPERR   = $0500;
   RC_REDIRERR  = $0600;

{e Swap method and option flags }
{d Auslagerungsmethoden ond Optionen }

   USE_EMS      =  $01;
   USE_XMS      =  $02;
   USE_FILE     =  $04;
   EMS_FIRST    =  $00;
   XMS_FIRST    =  $10;
   HIDE_FILE    =  $40;
   NO_PREALLOC  = $100;
   CHECK_NET    = $200;

   USE_ALL      = USE_EMS or USE_XMS or USE_FILE or CHECK_NET;


type
    filename = string [81];
    string128 = string [128];
    pstring = ^string;


function DosShell (xfn: string; pars: string; spawn: integer;
                  needed: word; newenv: boolean): integer;

   {>e
      The EXEC function.

      Parameters:

         xfn      is a string containing the name of the file
                  to be executed. If the string is empty,
                  the COMSPEC environment variable is used to
                  load a copy of COMMAND.COM or its equivalent.
                  If the filename does not include a path, the
                  current PATH is searched after the default.
                  If the filename does not include an extension,
                  the path is scanned for a COM, EXE, or BAT file 
                  in that order.

         pars     The program parameters.

         spawn    If 0, the function will terminate after the 
                  EXECed program returns, the function will not return.

                  NOTE: If the program file is not found, the function
                        will always return with the appropriate error 
                        code, even if 'spawn' is 0.

                  If non-0, the function will return after executing the
                  program. If necessary (see the "needed" parameter),
                  memory will be swapped out before executing the program.
                  For swapping, spawn must contain a combination of the
                  following flags:

                     USE_EMS  ($01)  - allow EMS swap
                     USE_XMS  ($02)  - allow XMS swap
                     USE_FILE ($04)  - allow File swap

                  The order of trying the different swap methods can be
                  controlled with one of the flags

                     EMS_FIRST ($00) - EMS, XMS, File (default)
                     XMS_FIRST ($10) - XMS, EMS, File

                  If swapping is to File, the attribute of the swap file
                  can be set to "hidden", so users are not irritated by
                  strange files appearing out of nowhere with the flag

                     HIDE_FILE ($40) - create swap file as hidden

                  and the behaviour on Network drives can be changed with

                     NO_PREALLOC (0x100) - don't preallocate
                     CHECK_NET (0x200)   - don't preallocate if file on net.

                  This checking for Network is mainly to compensate for
                  a strange slowdown on Novell networks when preallocating
                  a file. You can either set NO_PREALLOC to avoid allocation
                  in any case, or let the prep_swap routine decide whether
                  to do preallocation or not depending on the file being
                  on a network drive (this will only work with DOS 3.1 or 
                  later).

         needed   The memory needed for the program in paragraphs (16 Bytes).
                  If not enough memory is free, the program will
                  be swapped out.
                  Use 0 to never swap, $ffff to always swap. 
                  If 'spawn' is 0, this parameter is irrelevant.

         newenv   If this parameter is FALSE, the environment
                  of the spawned program is a copy of the parent's
                  environment. If it is TRUE, a new environment
                  is created which includes the modifications from
                  previous 'putenv' calls.

      Return value:

         $0000..00FF: The EXECed Program's return code

         $0101:       Error preparing for swap: no space for swapping
         $0102:       Error preparing for swap: program too low in memory

         $0200:       Program file not found
         $0201:       Program file: Invalid drive
         $0202:       Program file: Invalid path
         $0203:       Program file: Invalid name
         $0204:       Program file: Invalid drive letter
         $0205:       Program file: Path too long
         $0206:       Program file: Drive not ready
         $0207:       Batchfile/COMMAND: COMMAND.COM not found
         $0208:       Error allocating temporary buffer

         $03xx:       DOS-error-code xx calling EXEC

         $0400:       Error allocating environment buffer

         $0500:       Swapping requested, but prep_swap has not 
                       been called or returned an error.
         $0501:       MCBs don't match expected setup
         $0502:       Error while swapping out

         $0600:       Redirection syntax error
         $06xx:       DOS error xx on redirection
   <}

   {>d
      Die EXEC Funktion.

      Parameter:

         xfn      ist ein String mit dem Namen der auszufÅhrenden Datei.
                  Ist der String leer, wird die COMSPEC Umgebungsvariable
                  benutzt um COMMAND.COM oder das Equivalent zu laden.
                  Ist kein Pfad angegeben, wird nach dem aktuellen Pfad
                  der in der PATH Umgebungsvariablen angegebene Pfad
                  durchsucht.
                  Ist kein Dateityp angegeben, wird der Pfad nach
                  einer COM oder EXE Datei (in dieser Reihenfolge) abgesucht.

         pars     Die Kommandozeile

         spawn    Wenn 0, wird der Programmlauf beendet wenn das
                  aufgerufene Programm zurÅckkehrt, die Funktion kehrt
                  nicht zurÅck.

                  HINWEIS: Wenn die auszufÅhrende Datei nicht gefunden
                        wird, kehrt die Funktion mit einem Fehlercode
                        zurÅck, auch wenn der 'spawn' Parameter 0 ist.

                  Wenn nicht 0, kehrt die Funktion nach AusfÅhrung des
                  Programms zurÅck. Falls notwendig (siehe den Parameter
                  "needed") wird der Programmspeicherbereich vor Aufruf
                  ausgelagert.
                  Zur Auslagerung mu· der Parameter eine Kombination der
                  folgenden Flags enthalten:

                     USE_EMS  ($01)  - Auslagerung auf EMS zulassen
                     USE_XMS  ($02)  - Auslagerung auf XMS zulassen
                     USE_FILE ($04)  - Auslagerung auf Datei zulassen

                  Die Reihenfolge der Versuche, auf die verschiedenen
                  Medien auszulagern kann mit einem der folgenden
                  Flags beeinflu·t werden:

                     EMS_FIRST ($00) - EMS, XMS, Datei (Standard)
                     XMS_FIRST ($10) - XMS, EMS, Datei

                  Wenn die Auslagerung auf Datei erfolgt, kann das
                  Attribut dieser Datei auf "hidden" gesetzt werden,
                  damit der Benutzer nicht durch unversehends auftauchende
                  Dateien verwirrt wird:

                     HIDE_FILE ($40) - Auslagerungsdatei "hidden" erzeugen

                  Au·erdem kann das Verhalten auf Netzwerk-Laufwerken 
                  beeinflu·t werden mit

                     NO_PREALLOC (0x100) - nicht PrÑallozieren
                     CHECK_NET (0x200)   - nicht PrÑallozieren wenn Netz.

                  Diese PrÅfung auf Netzwerk ist hauptsÑchlich sinnvoll
                  fÅr Novell Netze, bei denen eine PrÑallozierung eine
                  erhebliche Verzîgerung bewirkt. Sie kînnen entweder mit
                  NO_PREALLOC eine PrÑallozierung in jedem Fall ausschlie·en,
                  oder die Entscheidung mit CHECK_NET prep_swap Åberlassen.
                  In diesem Fall wird nicht prÑalloziert wenn die Datei
                  auf einem Netzwerk-Laufwerk liegt (funktioniert nur
                  mit DOS Version 3.1 und spÑteren).

         needed   Der zur AusfÅhrung des Programms benîtigte Speicher
                  in Paragraphen (16 Bytes). Wenn nicht ausreichend 
                  freier Speicher vorhanden ist, wird der Programm-
                  speicherbereich ausgelagert.
                  Bei Angabe von 0 wird nie ausgelagert, bei Angabe
                  von $ffff wird immer ausgelagert.
                  Ist der Parameter 'spawn' 0, hat 'needed' keine Bedeutung.

         newenv   Bestimmt die dem gerufenen Programm zu Åbergebenden
                  Umgebungsvariablen. Ist der Parameter FALSE,
                  wird eine Kopie der Vater-Umgebung benutzt,
                  d.h. da· Aufrufe von "putenv" keinen Effekt haben.
                  Ist er TRUE, wird eine neue Umgebung mit den 
                  Modifikationen aus 'putenv' Åbergeben.

      Liefert:

         $0000..00FF: RÅckgabewert des aufgerufenen Programms

         $0101:       Fehler bei Vorbereitung zum Auslagern -
                       kein Speicherplatz in XMS/EMS/Datei
         $0102:       Fehler bei Vorbereitung zum Auslagern -
                       der Programmcode ist zu nah am Beginn des
                       Programms.

         $0200:       AuszufÅhrende Programmdatei nicht gefunden
         $0201:       Programmdatei: UngÅltiges Laufwerk
         $0202:       Programmdatei: UngÅltiger Pfad
         $0203:       Programmdatei: UngÅltiger Dateiname
         $0204:       Programmdatei: UngÅltiger Laufwerksbuchstabe
         $0205:       Programmdatei: Pfad zu lang
         $0206:       Programmdatei: Laufwerk nicht bereit
         $0207:       Batchfile/COMMAND: COMMAND.COM nicht gefunden
         $0208:       Fehler beim allozieren eines temporÑren Puffers

         $03xx:       DOS-Fehler-Code xx bei Aufruf von EXEC

         $0400:       Fehler beim allozieren der Umgebungsvariablenkopie

         $0500:       Auslagerung angefordert, aber prep_swap wurde nicht
                       aufgerufen oder lieferte einen Fehler
         $0501:       MCBs entsprechen nicht dem erwarteten Aufbau
         $0502:       Fehler beim Auslagern

         $0600:      Redirection Syntaxfehler
         $06xx:      DOS-Fehler xx bei Redirection
   <}

procedure putenv (envvar: string);
{  Adds a string to the environment. Note that the change to the
   environment is valid for an exec'ed process only, and only if you
   set the 'newenv' parameter in do_exec to TRUE. }


function envcount: integer;
function envstr (index: integer): string;
function getenv (envvar: string): string;

{ Replacement functions for the environment handling functions in the
  DOS unit. All three functions work exactly like their DOS-unit
  counterparts, except that they recognize the changes to the child
  environment produced by 'putenv'. }



{===========================================================================}

Implementation

{>e
   Define REDIRECT to support redirection.
   CAUTION: The definition in 'spawn.asm' must match this definition!!
<}
{>d
   Definieren Sie REDIRECT um Dateiumleitung zu untertÅtzen.
   ACHTUNG: Die Definition in 'spawn.asm' mu· mit dieser Definition 
   Åbereinstimmen!!
<}

{$DEFINE REDIRECT}

const
   swap_filename = '$$AAAAAA.AAA';

   {e internal flags for prep_swap }
   {d interne Flags fÅr prep_swap }

   CREAT_TEMP      = $0080;
   DONT_SWAP_ENV   = $4000;

   ERR_COMSPEC     = -7;
   ERR_NOMEM       = -8;

   spaces: set of #9..' ' = [#9, ' '];

type
   stringptr = ^string;
   stringarray = array [0..10000] of stringptr;
   stringarrptr = ^stringarray;
   bytearray = array [0..30000] of byte;
   bytearrayptr = ^bytearray;

var
   envptr: stringarrptr;   { Pointer to the changed environment }
   envcnt: integer;        { Count of environment strings }
   cmdpath: string;
   cmdpars: string;
   drive: string [3];
   dir: string [67];
   name: string [9];
   ext: string [5];


{$L spawnp}
function do_spawn (swapping: integer;
                   var xeqfn; var cmdtail; envlen: word;
                   var env
{$IFDEF REDIRECT}
                   ;stdin: pstring; stdout: pstring; stderr: pstring
{$ENDIF}
                   ): integer; external;

function prep_swap (method: integer; var swapfn): integer; external;

{ Environment routines }

function envcount: integer;

   { Returns count of strings in environment. }

   var
      cnt: integer;
   begin
   if envptr = nil { If not yet changed }
      then envcount := dos.envcount
      else envcount := envcnt;
   end;


function envstr (index: integer): string;

   { Returns environment string 'index' }

   begin
   if envptr = nil { If not yet changed }
      then envstr := dos.envstr (index)
      else if (index <= 0) or (index >= envcnt)
      then envstr := ''
      else if envptr^ [index - 1] = nil
      then envstr := ''
      else envstr := envptr^ [index - 1]^;
   end;


function name_eq (var n1, n2: string): boolean;

   { Compares search string 'n1' with environment string 'n2'.
     Case is insignificant. }

   var
      i: integer;
      eq: boolean;
   begin
   i := 1;
   eq := false;
   while (i <= length (n1)) and (i <= length (n2)) and
         (upcase (n1 [i]) = upcase (n2 [i])) do
      i := i + 1;
   name_eq := (i > length (n1)) and (i <= length (n2)) and (n2 [i] = '=');
   end;


function searchenv (var str: string): integer;

   { Search for environment string, returns index in 'envptr' array.
     Assumes 'envptr' is not NIL. }

   var
      idx: integer;
      found: boolean;
   begin
   idx := 0;
   found := false;

   while (idx < envcnt) and not found do
      begin
      if envptr^ [idx] <> nil
         then found := name_eq (str, envptr^ [idx]^);
      idx := idx + 1;
      end;
   if not found
      then searchenv := -1
      else searchenv := idx - 1;
   end;


function getenv (envvar: string): string;

   { Returns value of environment string specified by name. }

   var
      strp: stringptr;
      eq: integer;
   begin
   if envptr = nil { If not yet changed }
      then getenv := dos.getenv (envvar)
      else begin
      eq := searchenv (envvar);
      if eq < 0
         then getenv := ''
         else begin
         strp := envptr^ [eq];
         eq := pos ('=', strp^);
         getenv := copy (strp^, eq + 1, length (strp^) - eq);
         end;
      end;
   end;


procedure init_envptr;

   { Initialise 'envptr' array. Called when 'putenv' is used for the
     first time. Copies all environment strings into heap storage,
     and builds an array of pointers to this strings. }

   var
      i: integer;
      str: string [255];
   begin
   envcnt := dos.envcount;
   getmem (envptr, envcnt * sizeof (stringptr));
   if envptr = nil
      then exit;
   for i := 0 to envcnt - 1 do
      begin
      str := dos.envstr (i + 1);
      getmem (envptr^ [i], length (str) + 1);
      if envptr^ [i] <> nil
         then envptr^ [i]^ := str;
      end;
   end;


procedure putenv (envvar: string);

   { Adds the string 'envvar' to the environment, or changes the
     environment string if the name is already present. }

   var
      idx, eq: integer;
      help: stringarrptr;
   begin
   if envptr = nil
      then init_envptr;
   if envptr = nil
      then exit;

   eq := pos ('=', envvar);
   if eq = 0
      then exit;
   for idx := 1 to eq do
      envvar [idx] := upcase (envvar [idx]);

   idx := searchenv (envvar);
   if idx >= 0
      then begin
      freemem (envptr^ [idx], length (envptr^ [idx]^) + 1);

      if eq >= length (envvar)
         then envptr^ [idx] := nil
         else begin
         getmem (envptr^ [idx], length (envvar) + 1);
         if envptr^ [idx] <> nil
            then envptr^ [idx]^ := envvar;
         end;
      end
      else if eq < length (envvar)
      then begin
      getmem (help, (envcnt + 1) * sizeof (stringptr));
      if help = nil
         then exit;
      move (envptr^, help^, envcnt * sizeof (stringptr));
      freemem (envptr, envcnt * sizeof (stringptr));
      envptr := help;
      getmem (envptr^ [envcnt], length (envvar) + 1);
      if envptr^ [envcnt] <> nil
         then envptr^ [envcnt]^ := envvar;
      envcnt := envcnt + 1;
      end;
   end;



{ Routines to search for files }

function tryext (var fn: string): integer;

   { Try '.COM', '.EXE', and '.BAT' on current filename, modify filename if found. }

   var
      nfn: filename;
      ok: boolean;
   begin
   tryext := 1;
   nfn := fn + '.COM';
   ok := exists (nfn);
   if not ok
      then begin
      nfn := fn + '.EXE';
      ok := exists (nfn);
      end;
   if not ok
      then begin
      tryext := 2;
      nfn := fn + '.BAT';
      ok := exists (nfn);
      end;
   if not ok
      then tryext := 0
      else fn := nfn;
   end;


function findfile (var fn: string): integer;

   { Try to find the file 'fn' in the current path. Modifies the filename
     accordingly. }

   var
      path: string;
      i, j: integer;
      hasext, found, check: integer;
   begin
   if fn = ''
      then begin
      if cmdpath = ''
         then findfile := ERR_COMSPEC
         else findfile := 3;
      exit;
      end;

   check := checkpath (fn, drive, dir, name, ext, fn);
   if check < 0
      then begin
      findfile := check;
      exit;
      end;

   if ((check and HAS_WILD) <> 0) or ((check and HAS_FNAME) = 0)
      then begin
      findfile := ERR_FNAME;
      exit;
      end;

   if (check and HAS_EXT) <> 0
      then begin
      for i := 1 to length (ext) do
         ext [i] := upcase (ext [i]);
      if ext = '.BAT'
         then hasext := 2
         else hasext := 1;
      end
      else hasext := 0;

   if hasext <> 0
      then begin
      if (check and FILE_EXISTS) <> 0
         then found := hasext
         else found := 0;
      end
      else found := tryext (fn);

   if (found <> 0) or ((check and (HAS_PATH or HAS_DRIVE)) <> 0)
      then begin
      findfile := found;
      exit;
      end;

   path := getenv ('PATH');
   i := 1;
   while (found = 0) and (i <= length (path)) do
      begin
      j := 0;
      while (path [i] <> ';') and (i <= length (path)) do
         begin
         j := j + 1;
         fn [j] := path [i];
         i := i + 1;
         end;
      i := i + 1;
      if (j > 0)
         then begin
         if not (fn [j] in ['\', '/'])
            then begin
            j := j + 1;
            fn [j] := '\';
            end;
         fn [0] := chr (j);
         fn := fn + name + ext;
         check := checkpath (fn, drive, dir, name, ext, fn);
         if hasext <> 0
            then begin
            if (check and FILE_EXISTS) <> 0
               then found := hasext
               else found := 0;
            end
            else found := tryext (fn);
         end;
      end;
   findfile := found;
   end; { findfile }


{>e 
   Get name and path of the command processor via the COMSPEC
   environmnt variable. Any parameters after the program name
   are copied and inserted into the command line.
<}
{>d
   Namen und Pfad des Kommandoprozessors Åber die COMSPEC-Umgebungs-
   Variable bestimmen. Parameter nach dem Programmnamen werden kopiert
   und in die Kommandozeile eingefÅgt.
<}

procedure getcmdpath;
   var
      i, found: integer;
   begin
   if length (cmdpath) > 0
      then exit;
   cmdpath := getenv ('COMSPEC');
   cmdpars := '';
   found := 0;

   if cmdpath <> ''
      then begin
      i := 1;
      while (i <= length (cmdpath)) and (cmdpath [i] in spaces) do
         inc (i);
      if i > 1
         then begin
         cmdpath := copy (cmdpath, i, 255);
         i := 1;
         end;

      i := pos (';,=+/"[]|<> '#9, cmdpath);
      if i <> 0
         then begin
         cmdpars := copy (cmdpath, i, 128);
         cmdpath [0] := chr (i - 1);
         i := 1;
         while (i <= length (cmdpars)) and (cmdpars [i] in spaces) do
            inc (i);
         if i > 1
            then cmdpars := copy (cmdpars, i, 128);
         if cmdpars <> ''
            then cmdpars := cmdpars + ' ';
         end;
      found := findfile (cmdpath);
      end;

   if found = 0
      then begin
      cmdpath := 'COMMAND.COM';
      cmdpars := '';
      found := findfile (cmdpath);
      if found = 0
         then cmdpath := '';
      end;
   end;


function tempdir (var outfn: filename): boolean;

   { Set temporary file path.
     Read "TMP/TEMP" environment. If empty or invalid, clear path.
     If TEMP is drive or drive+backslash only, return TEMP.
     Otherwise check if given path is a valid directory.
   }
   var
      stmp: array [0..3] of filename;
      i, res: integer;

   begin
   stmp [0] := getenv ('TMP');
   stmp [1] := getenv ('TEMP');
   stmp [2] := '.\';
   stmp [3] := '\';

   for i := 0 to 3 do
      if length (stmp [i]) <> 0
         then begin
         outfn := stmp [i];
         res := checkpath (outfn, drive, dir, name, ext, outfn);
         if (res > 0) and ((res and IS_DIR) <> 0) and ((res and IS_READ_ONLY) = 0)
            then begin
            tempdir := true;
            exit;
            end;
         end;
   tempdir := false;
   end;


{$IFDEF REDIRECT}

function parse_redirect (var par: string; idx: integer;
                         var stdin, stdout, stderr: pstring): boolean;
   var
      ch: char;
      fnp: pstring;
      fn: string;
      app, i, fne: integer;

   begin
   i := idx;
   par [length (par) + 1] := #0;

   repeat
      app := 0;
      ch := par [i];
      i := i + 1;
      if ch <> '<'
         then begin
         if par [i] = '&'
            then begin
            ch := '&';
            inc (i);
            end;
         if par [i] = '>'
            then begin
            app := 1;
            inc (i);
            end;
         end;

      while (i <= length (par)) and (par [i] in spaces) do
         inc (i);
      fn := copy (par, i, 255);
      fne := pos (';,=+/"[]|<> '#9, fn);
      if fne = 0
         then fne := length (fn) + 1;
      i := i + fne - 1;
      fn [0] := chr (fne - 1);
      if (fne = 0) or (length (fn) = 0)
         then begin
         parse_redirect := false;
         exit;
         end;
      
      getmem (fnp, length (fn) + app + 2);
      if fnp = NIL
         then begin
         parse_redirect := false;
         exit;
         end;
      if app <> 0
         then fnp^ := '>' + fn
         else fnp^ := fn;
      fnp^ [length (fnp^) + 1] := #0;

      case ch of
         '<':  if stdin <> NIL
                  then begin
                  parse_redirect := false;
                  exit;
                  end
               else stdin := fnp;

         '>':  if stdout <> NIL
                  then begin
                  parse_redirect := false;
                  exit;
                  end
               else stdout := fnp;

         '&':  if stderr <> NIL
                  then begin
                  parse_redirect := false;
                  exit;
                  end
               else stderr := fnp;
         end;

      while (i <= length (par)) and (par [i] in spaces) do
         inc (i);

   until (i > length (par)) or (par [i] <> '>') and (par [i] <> '<');

   par [idx] := #0;
   par [0] := chr (idx - 1);
   parse_redirect := true;
   end;

{$ENDIF}


function DosShell (xfn: string; pars: string; spawn: integer;
                  needed: word; newenv: boolean): integer;
   label
      exit;
   var
      swapfn: filename;
      avail: word;
      regs: registers;
      envlen, einx: word;
      idx, len, rc: integer;
      envp: bytearrayptr;
      swapping: integer;
{$IFDEF REDIRECT}
      stdin, stdout, stderr: pstring;
{$ENDIF}
   begin
{$IFDEF REDIRECT}
   stdin := NIL; stdout := NIL; stderr := NIL;
{$ENDIF}

   getcmdpath;
   envlen := 0;

   { First, check if the file to execute exists. }

   rc := findfile (xfn);
   if rc <= 0
      then begin
      DosShell := RC_NOFILE or -rc;
      goto exit;
      end;

   if rc > 1   { COMMAND.COM or Batch file }
      then begin
      if length (cmdpath) = 0
         then begin
         DosShell := RC_NOFILE or -ERR_COMSPEC;
         goto exit;
         end;

      if rc = 2
         then pars := cmdpars + '/c ' + xfn + ' ' + pars
         else pars := cmdpars + pars;
      xfn := cmdpath;
      end;

{$IFDEF REDIRECT}
   idx := pos ('<', pars);
   len := pos ('>', pars);
   if len > idx
      then idx := len;
   if idx > 0
      then if not parse_redirect (pars, idx, stdin, stdout, stderr)
         then begin
         DosShell := RC_REDIRERR;
         goto exit;
         end;
{$ENDIF}

   { Now create a copy of the environment if the user wants it, and
     if the environment has been changed. }

   if newenv and (envptr <> nil)
      then begin
      for idx := 0 to envcnt - 1 do
         envlen := envlen + length (envptr^ [idx]^) + 1;
      if envlen > 0
         then begin
         envlen := envlen + 1;
         getmem (envp, envlen);
         if envp = nil
            then begin
            DosShell := RC_ENVERR;
            goto exit;
            end;
         einx := 0;
         for idx := 0 to envcnt - 1 do
            begin
            len := length (envptr^ [idx]^);
            move (envptr^ [idx]^ [1], envp^ [einx], len);
            envp^ [einx + len] := 0;
            einx := einx + len + 1;
            end;
         envp^ [einx] := 0;
         end;
      end;

   if spawn = 0
      then swapping := -1
      else begin

      { Determine amount of free memory }
      with regs do
         begin
         ax := $4800;
         bx := $ffff;
         msdos (regs);
         avail := regs.bx;
         end;

      { No swapping if available memory > needed }

      if needed < avail
         then swapping := 0
         else begin

         { Swapping necessary, use 'TMP' or 'TEMP' environment variable
           to determine swap file path if defined. }

         swapping := spawn;
         if (spawn and USE_FILE) <> 0
            then begin
            if not tempdir (swapfn)
               then begin
               spawn := spawn xor USE_FILE;
               swapping := spawn;
               end
               else begin
               if (dosversion and $ff) >= 3
                  then swapping := swapping or CREAT_TEMP
                  else begin
                  swapfn := swapfn + swap_filename;
                  len := length (swapfn);
                  while exists (swapfn) do
                     begin
                  	if (swapfn [len] >= 'Z')
                        then len := len - 1;
                  	if (swapfn [len] = '.')
                        then len := len - 1;
                  	swapfn [len] := succ (swapfn [len]);
                  	end;
                  end;
               swapfn [length (swapfn) + 1] := #0;
               end;
            end;
         end;
      end;

   { All set up, ready to go. }

   if swapping > 0
      then begin
      if envlen = 0
         then swapping := swapping or DONT_SWAP_ENV;

      rc := prep_swap (swapping, swapfn);
      if rc < 0
         then begin
         DosShell := RC_PREPERR or -rc;
         goto exit;
         end;
      end;

   xfn [length (xfn) + 1] := #0;
   pars [length (pars) + 1] := #0;
   swapvectors;
{$IFDEF REDIRECT}
   DosShell := do_spawn (swapping, xfn, pars, envlen, envp^, stdin, stdout, stderr);
{$ELSE}
   DosShell := do_spawn (swapping, xfn, pars, envlen, envp^);
{$ENDIF}
   swapvectors;

   { Free the environment buffer if it was allocated. }

exit:
   if envlen > 0
      then freemem (envp, envlen);
{$IFDEF REDIRECT}
   if stdin <> NIL
      then freemem (stdin, length (stdin^) + 2);
   if stdout <> NIL
      then freemem (stdout, length (stdout^) + 2);
   if stderr <> NIL
      then freemem (stderr, length (stderr^) + 2);
{$ENDIF}
   end;


{ Initialisation for environment processing }

Begin
envptr := nil;
envcnt := 0;
cmdpath := '';
End.


*)