Calculation: Climax(T) = volume[pivot length] > SMA(volume, volume lookback)[pivot length] * volume multiplier OR (high[pivot length] - low[pivot length]) > ATR(ATR lookback)[pivot length] * range multiplier
Calculation: Downtrend(T) = EMA(close, fast lookback) < EMA(close, slow lookback), where fast lookback < slow lookback
Calculation: Uptrend(T) = EMA(close, fast lookback) > EMA(close, slow lookback)
Calculation: Low pivot(T) = PivotLow(low, pivot length, pivot length)
Calculation: High pivot(T) = PivotHigh(high, pivot length, pivot length)
Calculation: SC(T) = Stage[1] == 0 AND Downtrend AND Low pivot defined AND Climax
Calculation: BC(T) = Stage[1] == 0 AND Uptrend AND High pivot defined AND Climax
Calculation: AR up(T) = High pivot defined AND (Stage[1] == 1 OR SC)
Calculation: AR down(T) = Low pivot defined AND (Stage[1] == -1 OR BC)
Calculation: Spring(T) = Low pivot < Climax level AND (Stage[1] == 2 OR (Stage[1] == 1 AND AR up))
Calculation: SOS(T) = High pivot > AR level AND (Stage[1] == 2 OR Stage[1] == 3)
Calculation: LPS(T) = Low pivot > Climax level AND (Stage[1] == 4 OR SOS)
Calculation: UTAD(T) = High pivot > Climax level AND (Stage[1] == -2 OR (Stage[1] == -1 AND AR down))
Calculation: SOW(T) = Low pivot < AR level AND (Stage[1] == -2 OR Stage[1] == -3)
Calculation: LPSY(T) = High pivot < Climax level AND (Stage[1] == -4 OR SOW)
Calculation: Climax level(T) = Low pivot if SC, else High pivot if BC, else Climax level[1]
Calculation: AR level(T) = High pivot if AR up, else Low pivot if AR down, else AR level[1]
Calculation: Next stage(T) = 5 if LPS, else 4 if SOS, else 3 if Spring, else 2 if AR up, else 1 if SC, else -5 if LPSY, else -4 if SOW, else -3 if UTAD, else -2 if AR down, else -1 if BC, else Stage[1]
Calculation: Breach(T) = Broken[1] OR (Next stage > 0 AND close < Climax level * (1 - invalidation percentage)) OR (Next stage < 0 AND close > Climax level * (1 + invalidation percentage))
Calculation: Stage(T) = 0 if (Next stage == 5 AND close > AR level * (1 + expiry percentage)) OR (Next stage == -5 AND close < AR level * (1 - expiry percentage)) OR (Breach AND ((Next stage > 0 AND Uptrend) OR (Next stage < 0 AND Downtrend))), else Next stage
Calculation: Broken(T) = Breach AND Stage != 0
Long: Spring(T1, last completed bar) AND NOT Spring(T1, last completed bar)[1]
Long: SOS(T1, last completed bar) AND NOT SOS(T1, last completed bar)[1]
Long: LPS(T1, last completed bar) AND NOT LPS(T1, last completed bar)[1]
Long: Spring(T2, last completed bar) AND NOT Spring(T2, last completed bar)[1]
Long: SOS(T2, last completed bar) AND NOT SOS(T2, last completed bar)[1]
Long: LPS(T2, last completed bar) AND NOT LPS(T2, last completed bar)[1]
Long: Spring(T3, last completed bar) AND NOT Spring(T3, last completed bar)[1]
Long: SOS(T3, last completed bar) AND NOT SOS(T3, last completed bar)[1]
Long: LPS(T3, last completed bar) AND NOT LPS(T3, last completed bar)[1]
Short: UTAD(T1, last completed bar) AND NOT UTAD(T1, last completed bar)[1]
Short: SOW(T1, last completed bar) AND NOT SOW(T1, last completed bar)[1]
Short: LPSY(T1, last completed bar) AND NOT LPSY(T1, last completed bar)[1]
Short: UTAD(T2, last completed bar) AND NOT UTAD(T2, last completed bar)[1]
Short: SOW(T2, last completed bar) AND NOT SOW(T2, last completed bar)[1]
Short: LPSY(T2, last completed bar) AND NOT LPSY(T2, last completed bar)[1]
Short: UTAD(T3, last completed bar) AND NOT UTAD(T3, last completed bar)[1]
Short: SOW(T3, last completed bar) AND NOT SOW(T3, last completed bar)[1]
Short: LPSY(T3, last completed bar) AND NOT LPSY(T3, last completed bar)[1]
Exit: long, Broken(T1, last completed bar) AND NOT Broken(T1, last completed bar)[1] AND Stage(T1, last completed bar) > 0
Exit: short, Broken(T1, last completed bar) AND NOT Broken(T1, last completed bar)[1] AND Stage(T1, last completed bar) < 0