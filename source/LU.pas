unit LU;

interface

uses
  Array2D, SysUtils, Math;

function LU_num_flops(N: integer): double;
procedure LU_copy_matrix(M, N: integer; LU, A: PArrayofDoubleArray);
function LU_factor(M, N: integer; A: PArrayofDoubleArray; pivot: PIntegerArray): integer;

implementation

function LU_num_flops(N: integer): double;
begin
  { rougly 2/3*N^3 }
  Result := (2.0 * N * N * N / 3.0);
end;

procedure LU_copy_matrix(M, N: integer; LU, A: PArrayofDoubleArray);
Var
  i, j: integer;
begin
  for i := 0 to M - 1 do
    for j := 0 to N - 1 do
      LU[i][j] := A[i][j];
end;

function LU_factor(M, N: integer; A: PArrayofDoubleArray;
  pivot: PIntegerArray): integer;
Var
  minMN, j, i, jp, k, ii, jj: integer;
  ab, t, recp, AiiJ: double;
  ta, Aii, Aj: PDoubleArray;

begin
  minMN := IFTHEN(M < N, M, N);

  for j := 0 to minMN - 1 do
  begin
    { find pivot in column j and  test for singularity. }
    jp := j;

    t := abs(A[j][j]);
    for i := j + 1 to M - 1 do
    begin
      ab := abs(A[i][j]);
      if (ab > t) then
      begin
        jp := i;
        t := ab;
      end;
    end;

    pivot[j] := jp;

    { jp now has the index of maximum element }
    { of column j, below the diagonal }

    if (A[jp][j] = 0) then
      {$ifdef VER150}exit;{$else}exit(1);{$endif} { factorization failed because of zero pivot }

    if (jp <> j) then
    begin
      { swap rows j and jp }
      ta := A[j];
      A[j] := A[jp];
      A[jp] := ta;
    end;

    if (j < M - 1) then { compute elements j+1:M of jth column }
    begin
      { note A(j,j), was A(jp,p) previously which was }
      { guarranteed not to be zero (Label #1) }

      recp := 1.0 / A[j][j];

      for k := j + 1 to M - 1 do
        A[k][j] := A[k][j] * recp;
    end;

    if j < minMN - 1 then
    begin
      { rank-1 update to trailing submatrix:   E = E - x*y; }
      { E is the region A(j+1:M, j+1:N) }
      { x is the column vector A(j+1:M,j) }
      { y is row vector A(j,j+1:N) }

      for ii := j + 1 to M - 1 do
      begin
        Aii := A[ii];
        Aj := A[j];
        AiiJ := Aii[j];

        for jj := j + 1 to N - 1 do
          Aii[jj] := Aii[jj] - AiiJ * Aj[jj];

      end;
    end;
  end;

  Result := 0;
end;

end.
