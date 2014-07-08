unit SparseCompRow;

interface

uses Array2D;

function SparseCompRow_num_flops(N, nz, num_iterations: integer): double;

procedure SparseCompRow_matmult(M: integer; y: PDoubleArray; val: PDoubleArray;
  row, col: PIntegerArray; x: PDoubleArray; NUM_ITERATIONS: integer);

implementation

function SparseCompRow_num_flops(N, nz, num_iterations: integer): double;
var
  actual_nz: integer;
begin
  actual_nz := (nz div N) * N;
  result := actual_nz * 2 * num_iterations;
end;

procedure SparseCompRow_matmult(M: integer; y: PDoubleArray; val: PDoubleArray;
  row, col: PIntegerArray; x: PDoubleArray; NUM_ITERATIONS: integer);
var
  reps, r, i: integer;
  sum: double;
begin
  for reps := 0 to NUM_ITERATIONS - 1 do
  begin
    for r := 0 to M - 1 do
    begin
      sum := 0.0;
      for i := row[r] to row[r + 1] - 1 do
        sum := sum + x[col[i]] * val[i];

      y[r] := sum;
    end;
  end;
end;

end.
