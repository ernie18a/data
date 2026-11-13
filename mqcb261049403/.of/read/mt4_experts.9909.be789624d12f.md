Calculation: SAR(tf,k) = Parabolic SAR with identical parameters on every timeframe tf; k=0 is the still-forming bar of tf, k=1 is the last completed bar of tf. H(tf,k) and L(tf,k) = high and low of that same bar.
Calculation: Three timeframes S < M < L (S shortest, L longest), all higher than the chart timeframe.
Calculation: Spread = max(SAR(S,0), SAR(M,0), SAR(L,0)) - min(SAR(S,0), SAR(M,0), SAR(L,0)).
Calculation: FlipUp(tf) = SAR(tf,1) > H(tf,1) AND SAR(tf,0) < L(tf,0). FlipDown(tf) = SAR(tf,1) < L(tf,1) AND SAR(tf,0) > H(tf,0).
Calculation: Stop level, evaluated once per chart bar. Long: initial = entry price - fixed stop distance; if SAR(M,0) >= entry price AND SAR(M,0) > stop then stop = SAR(M,0). Short: initial = entry price + fixed stop distance; if SAR(M,0) <= entry price AND SAR(M,0) < stop then stop = SAR(M,0).
Long: flat AND Spread <= fixed threshold AND SAR(tf,0) < L(tf,0) for all of S, M, L AND FlipUp(tf) is true for at least one of S, M, L
Short: flat AND Spread <= fixed threshold AND SAR(tf,0) > H(tf,0) for all of S, M, L AND FlipDown(tf) is true for at least one of S, M, L
Exit: long, chart low <= stop level OR chart high >= entry price + fixed target distance OR (SAR(M,1) < chart-timeframe low of the last completed bar AND SAR(M,0) > chart-timeframe high of the forming bar)
Exit: short, chart high >= stop level OR chart low <= entry price - fixed target distance OR (SAR(M,1) > chart-timeframe high of the last completed bar AND SAR(M,0) < chart-timeframe low of the forming bar)