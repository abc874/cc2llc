program CL2LLC;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Classes, System.SysUtils, System.IniFiles, Winapi.Windows;

{$SetPEFlags IMAGE_FILE_RELOCS_STRIPPED}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}


procedure Convert(const AFile: string);
var
  Ini: TIniFile;
  Lst: TStringList;
  Fmt: TFormatSettings;
  Section: string;
  Cnt,I: Integer;
  Start,Duration: Double;
begin
  // Numbers with decimal point (EN)!

  if (ParamCount > 0) and FileExists(AFile) then
  begin
    Fmt := TFormatSettings.Create('en');
    Lst := TStringList.Create;
    Ini := TIniFile.Create(AFile);
    try
      Cnt := Ini.ReadInteger('General', 'NoOfCuts', 0);

      Lst.Add('{ version: 1, cutSegments: [');

      for I := 0 to Pred(Cnt) do
      begin
        Section  := 'Cut' + IntToStr(I);
        Start    := StrToFloat(Ini.ReadString(Section, 'Start', '0'), Fmt);
        Duration := StrToFloat(Ini.ReadString(Section, 'Duration', '0'), Fmt);

        if (Start > 0) and (Duration > 0) then
          Lst.Add(Format('{ start: %.6f, end: %.6f },', [Start, Start + Duration], Fmt));
      end;

      Lst.Add('], }');

      Lst.SaveToFile(ChangeFileExt(AFile, '.llc'));
    finally
      Lst.Free;
      Ini.Free;
    end;
  end else
  begin
    Writeln('Syntax');
    Writeln('CL2LLC cutlistfile');
    Writeln('');
    Writeln('Press RETURN');
    Readln;
  end;
end;

begin
  try
    Convert(ParamStr(1));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
