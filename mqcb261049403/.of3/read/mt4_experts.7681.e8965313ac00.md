Calculation: Pivots = floor pivot points(T3, last completed bar), rounded to instrument price precision; read on chart bars
Calculation: R0.5 = round((Pivots.PP + Pivots.R1)/2, instrument price precision)
Calculation: S0.5 = round((Pivots.PP + Pivots.S1)/2, instrument price precision)
Calculation: R1.5 = round((Pivots.R1 + Pivots.R2)/2, instrument price precision)
Calculation: S1.5 = round((Pivots.S1 + Pivots.S2)/2, instrument price precision)
Calculation: R2.5 = round((Pivots.R2 + Pivots.R3)/2, instrument price precision)
Calculation: S2.5 = round((Pivots.S2 + Pivots.S3)/2, instrument price precision)
Long: on chart bars, close(T1, last completed bar) >= open(T1, last completed bar) AND there exists L in {Pivots.PP, R0.5, Pivots.R1, R1.5, Pivots.R2, R2.5, Pivots.S1, S0.5} such that open(T1, second-last completed bar) <= L AND close(T1, second-last completed bar) >= L
Short: on chart bars, close(T1, last completed bar) <= open(T1, last completed bar) AND there exists L in {Pivots.PP, S0.5, Pivots.S1, S1.5, Pivots.S2, S2.5, Pivots.R1, R0.5} such that open(T1, second-last completed bar) >= L AND close(T1, second-last completed bar) <= L
Long: on chart bars, close(T2, last completed bar) >= open(T2, last completed bar) AND there exists L in {Pivots.PP, R0.5, Pivots.R1, R1.5, Pivots.R2, R2.5, Pivots.S1, S0.5} such that low(T2, third-last completed bar) <= L AND close(T2, third-last completed bar) >= L AND low(T2, second-last completed bar) <= L AND close(T2, second-last completed bar) >= L
Short: on chart bars, close(T2, last completed bar) <= open(T2, last completed bar) AND there exists L in {Pivots.PP, S0.5, Pivots.S1, S1.5, Pivots.S2, S2.5, Pivots.R1, R0.5} such that high(T2, third-last completed bar) >= L AND close(T2, third-last completed bar) <= L AND high(T2, second-last completed bar) >= L AND close(T2, second-last completed bar) <= L
Exit: long, (position age > holding-time threshold AND position profit >= 0) OR (datetime is Friday AND hour equals configured close hour AND minute is within the configured close-minute interval)
Exit: short, (position age > holding-time threshold AND position profit >= 0) OR (datetime is Friday AND hour equals configured close hour AND minute is within the configured close-minute interval)