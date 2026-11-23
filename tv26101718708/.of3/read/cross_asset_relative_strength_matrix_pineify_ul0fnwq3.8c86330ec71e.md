Calculation: Coherence(x, window) = efficiency weight * KaufmanER(LN(x), window) + agreement weight * A, where A = 0.5 * (1 + m) if LN(x) >= LN(x[window]), else 0.5 * (1 - m), and m = SUM(SIGN(LN(x) - LN(x[1])), window) / window
Calculation: Score(x, window) = W / (1 + ABS(W)) * (base weight + consistency weight * Coherence(x, window)), where W = (LN(x) - LN(x[window])) / SQRT(SUM((LN(x) - LN(x[1]))^2, window))
Calculation: PoolSize = number of basket assets for which Score(asset close, window) is defined
Calculation: Edge = Score(focus asset close, window) - mean of Score(asset close, window) over basket assets with defined Score, if PoolSize >= minimum pool size, otherwise undefined
Calculation: Standing = 0 if Edge is undefined, else 1 + number of basket assets for which Score(asset close, window) is greater than Score(focus asset close, window)
Calculation: Timely(x) = Score(x, window) is defined AND x's source received a new bar at most max stale bars chart bars ago
Calculation: TimelyCount = number of basket assets for which Timely(asset close) is true
Long: Edge crosses above 0 AND Timely(focus asset close) AND TimelyCount >= minimum pool size AND the bar is completed
Short: Edge crosses below 0 AND Timely(focus asset close) AND TimelyCount >= minimum pool size AND the bar is completed
Long: Standing <= rank cutoff AND Standing[1] > rank cutoff AND Timely(focus asset close) AND TimelyCount >= minimum pool size AND the bar is completed
Short: Standing > PoolSize - rank cutoff AND Standing[1] <= PoolSize[1] - rank cutoff AND Timely(focus asset close) AND TimelyCount >= minimum pool size AND the bar is completed
Long: Edge > 0 AND Timely(focus asset close) AND Coherence(focus asset close, window) >= consistency floor
Short: Edge < 0 AND Timely(focus asset close) AND Coherence(focus asset close, window) >= consistency floor