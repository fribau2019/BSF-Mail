{-----------------------------------------------}
{ This program writes the checksum word of      }
{ checksum.exe in offset $12 of the EXE header  }
{ of the same program -Jose- (1:163/513.3)      }
{-----------------------------------------------}
program writcsum;
uses DOS;
type
  arr256 = array[0..255] of byte;
var
  f : file;
  csum    : word;
  block   : arr256;
  numread : word;
function cmem(var block:arr256; siz:word): word;
var
  r : registers;
begin
  r.ax:= $121C;
  r.ds:= seg(block);
  r.si:= ofs(block);
  r.cx:= siz;
  r.dx:= 0;
  Intr($2F,r);
  cmem:= r.dx;
end;
begin
  if lo(dosversion) < 3 then begin
    writeln('Dos must be 3+...');
    halt;
  end;
  assign(f,'BSFMAIL.EXE');
  {$I-} reset(f,1); {$I+}
  if ioresult <> 0 then begin
    writeln('Cannot find file checksum.exe');
    halt;
  end;
  seek(f,$1B); {skip header...}
  csum:= 0;
  repeat       {calculate checksum word}
    blockread(f,block,sizeof(block),numread);
    inc(csum,cmem(block,numread));
  until eof(f) or (numread < sizeof(block));
  seek(f,$12); {seek checksum word in exe header}
  blockwrite(f,csum,sizeof(csum));
  close(f);
end.
