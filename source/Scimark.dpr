program Scimark;
{$APPTYPE CONSOLE}
{$ifndef VER150}
  {$FINITEFLOAT OFF}  // need to find out when this was introduced. With D7 it does not compile.
{$endif}

uses
  SysUtils,
  Constants in 'Constants.pas',
  Array2D in 'Array2D.pas',
  FFT in 'FFT.pas',
  LU in 'LU.pas',
  Random in 'Random.pas',
  MonteCarlo in 'MonteCarlo.pas',
  SOR in 'SOR.pas',
  SparseCompRow in 'SparseCompRow.pas',
  Stopwatch in 'Stopwatch.pas',
  Kernel in 'Kernel.pas';

procedure DisplayUsage;
begin
  Writeln('Usage: [-large/-huge] [minimum_time]');
end;

var
  min_time: Double;
  FFT_N, SOR_N, Sparse_M, Sparse_Nz, LU_N: integer;
  res: array [0 .. 5] of Double;
  R: PRandom;

begin
  try
    min_time := RESOLUTION_DEFAULT;
    if ParamCount > 2 then
    begin
      DisplayUsage;
      Exit;
    end;
    if ParamCount = 2 then
    begin
      min_time := StrToFloatDef(ParamStr(2), RESOLUTION_DEFAULT);
    end;
    if FindCmdLineSwitch('large', True) = True Then
    begin
      FFT_N := LG_FFT_SIZE;
      SOR_N := LG_SOR_SIZE;
      Sparse_M := LG_SPARSE_SIZE_M;
      Sparse_Nz := LG_SPARSE_SIZE_nz;
      LU_N := LG_LU_SIZE;
    end
    else if FindCmdLineSwitch('huge', True) = True Then
    begin
      FFT_N := HG_FFT_SIZE;
      SOR_N := HG_SOR_SIZE;
      Sparse_M := HG_SPARSE_SIZE_M;
      Sparse_Nz := HG_SPARSE_SIZE_nz;
      LU_N := HG_LU_SIZE;
    end
    else
    begin
      FFT_N := FFT_SIZE;
      SOR_N := SOR_SIZE;
      Sparse_M := SPARSE_SIZE_M;
      Sparse_Nz := SPARSE_SIZE_nz;
      LU_N := LU_SIZE;
    end;
    Writeln('**                                                               **');
    Writeln('** SciMark2a Numeric Benchmark, see http://math.nist.gov/scimark **');
    Writeln('**                                                               **');
    Writeln('** Delphi Port, see http://svn.code.sf.net/p/scimarkfordelphi/code/     **');
    Writeln('**                                                               **');
    {$ifdef VER150}
    Writeln('Compiled with Delphi 7 32-Bit');
    {$endif}
    {$ifdef VER210}
    Writeln('Compiled with Delphi 2010 32-Bit');
    {$endif}

    {$ifdef WIN32}
      if CompilerVersion=28 then Writeln('Compiled with Delphi XE7 32-Bit');
      if CompilerVersion=30 then Writeln('Compiled with Delphi XE10 Seattle 32-Bit');
      if CompilerVersion=31 then Writeln('Compiled with Delphi XE10.1 Berlin 32-Bit');
      if CompilerVersion=32 then Writeln('Compiled with Delphi XE10.2.3 Tokyo 32-Bit');
      if CompilerVersion=33 then Writeln('Compiled with Delphi XE10.3.3 Rio 32-Bit');
      if CompilerVersion=34 then Writeln('Compiled with Delphi XE10.4 Sydney 32-Bit');
    {$endif}
    {$ifdef WIN64}
      if CompilerVersion=28 then Writeln('Compiled with Delphi XE7 64-Bit');
      if CompilerVersion=30 then Writeln('Compiled with Delphi XE10 Seattle 64-Bit');
      if CompilerVersion=31 then Writeln('Compiled with Delphi XE10.1 Berlin 64-Bit');
      if CompilerVersion=32 then Writeln('Compiled with Delphi XE10.2.3 Tokyo 64-Bit');
      if CompilerVersion=33 then Writeln('Compiled with Delphi XE10.3.3 Rio 64-Bit');
      if CompilerVersion=34 then Writeln('Compiled with Delphi XE10.4 Sydney 64-Bit');
    {$endif}

    Writeln(Format('Mininum running time = %.2f seconds', [min_time]));
    R := new_Random_seed(RANDOM_SEED);
    res[1] := kernel_measureFFT(FFT_N, min_time, R);
    res[2] := kernel_measureSOR(SOR_N, min_time, R);
    res[3] := kernel_measureMonteCarlo(min_time, R);
    res[4] := kernel_measureSparseMatMult(Sparse_M, Sparse_Nz, min_time, R);
    res[5] := kernel_measureLU(LU_N, min_time, R);
    res[0] := (res[1] + res[2] + res[3] + res[4] + res[5]) / 5;
    Writeln(Format('Composite Score MFlops: %8.2f', [res[0]]));
    Writeln(Format('FFT             Mflops: %8.2f    (N=%d)', [res[1], FFT_N]));
    Writeln(Format('SOR             Mflops: %8.2f    (%d x %d)', [res[2], SOR_N, SOR_N]));
    Writeln(Format('MonteCarlo:     Mflops: %8.2f', [res[3]]));
    Writeln(Format('Sparse matmult  Mflops: %8.2f    (N=%d, nz=%d)', [res[4], SPARSE_SIZE_M, SPARSE_SIZE_nz]));
    Writeln(Format('LU              Mflops: %8.2f    (M=%d, N=%d)', [res[5], LU_SIZE, LU_SIZE]));
    Random_delete(R);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
