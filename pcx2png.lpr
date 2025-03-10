program pcx2png;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Windows, Interfaces, Classes, Graphics, SysUtils, fpimage, fpreadPCX, IntfGraphics;

const PROG = 'pcx2png';
      VERSION = '1.0';

function Convert(InName, OutName: String): Integer;
var Img: TGraphic;
    Ext: String;
    Bmp: TBitmap;
    Laz: TFPMemoryImage;
    Reader: TFPReaderPCX;
    x,y: Integer;
    Col: TFPColor;
    P: PByteArray;
    R,G,B,A: Byte;
begin
  Result := 0;

  try
     Reader := TFPReaderPCX.Create;
     Laz := TFPMemoryImage.Create(1, 1);
     Laz.LoadFromFile(InName, Reader);

     Bmp := TBitmap.Create;
     Bmp.SetSize(Laz.Width, Laz.Height);
     Bmp.PixelFormat := pf32bit;

     for y:=0 to Bmp.Height-1 do begin
       P := Bmp.Scanline[y];

       for x:=0 to Bmp.Width-1 do begin
         Col := Laz.Colors[x, y];

         R := Col.Red   shr 8;
         G := Col.Green shr 8;
         B := Col.Blue  shr 8;
         A := Col.Alpha shr 8;

         P^[4*x  ] := B;
         P^[4*x+1] := G;
         P^[4*x+2] := R;
         P^[4*x+3] := A;
       end;
     end;

    Reader.Free;
    Laz.Free;
  except
    Writeln('Conversion error');
    Exit(1);
  end;

  Ext := LowerCase(ExtractFileExt(OutName));

  if Ext = '.bmp' then Img := TBitmap.Create
  else if Ext = '.jpg' then Img := TJPEGImage.Create
  else if Ext = '.ppm' then Img := TPortableAnyMapGraphic.Create
  else if Ext = '.png' then Img := TPortableNetworkGraphic.Create;

  Img.Assign(Bmp);
  Bmp.Free;

  Img.SaveToFile(OutName);
  Img.Free;
end;

begin
  if (ParamCount <> 2) then begin
    Writeln('===================================================');
    Writeln('  ', PROG, ' - .PCX to .PNG image converter');
    Writeln('  github.com/Xelitan/', PROG);
    Writeln('  version: ', VERSION);
    Writeln('  license: GNU LGPL'); //like BGRA
    Writeln('===================================================');
    Writeln('  Usage: ', PROG, ' INPUT OUTPUT');
    Writeln('  Output format is guessed from extension.');
    Writeln('  Supported: bmp,jpg,png,ppm');
    ExitCode := 0;
    Exit;
  end;

  ExitCode := Convert(ParamStr(1), ParamStr(2));
end.



