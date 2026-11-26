Calculation: EMA direction(T_i,L_j) = +1 if the close of T_i is greater than EMA(close,L_j) on T_i, otherwise -1; calculate on T_i bars and map to chart bars, using the still-forming T_i bar in realtime and the latest completed T_i bar historically.
Calculation: Score = Σ(i=1..7,j=1..5) W_i_j × EMA direction(T_i,L_j), where T1…T7 are the requested timeframes ordered by increasing duration, L1…L5 are separate lookback parameters ordered by increasing length, and each W_i_j is a distinct positive coefficient parameter.
Long: EMA direction(T_i,L_j) = +1, independently for each i=1..7 and j=1..5
Short: EMA direction(T_i,L_j) = -1, independently for each i=1..7 and j=1..5
Long: Score > 0
Short: Score < 0
Long: Score > 0 AND EMA direction(T3,L2) = +1 AND EMA direction(T3,L3) = +1 AND EMA direction(T2,L2) = +1
Short: Score < 0 AND EMA direction(T3,L2) = -1 AND EMA direction(T3,L3) = -1 AND EMA direction(T2,L2) = -1