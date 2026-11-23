Calculation: TrendT1 = SuperTrend(T1 bars, last completed T1 bar, MA, period, multiplier, confirm bars), read on chart bars, with parameter set k0 if mode = Y1, else k1 if chart < T4, else k2 if chart < T3, else k3
Long: TrendT1 = 1 AND TrendT1[1] = -1
Short: TrendT1 = -1 AND TrendT1[1] = 1
Long: TrendT1 = 1
Short: TrendT1 = -1
Calculation: N = pivot period (manual) if mode = Y1; otherwise pivot period (T2) if chart is T2, pivot period (T3) if chart is T3, pivot period (T4) if chart is T4, and none otherwise
Calculation: (Pr, PVL, PVH) = (close, close, close) if source = X1; otherwise (hl2, low, high)
Calculation: Div(O, low) = (p, kind) on chart bars, with c = bar - N: p is the first of the last pivot memory pivot lows of PVL before c, most recent first, with min separation < c - p <= max bars, where kind = regular if Pr(c) < PVL(p) and O(c) > O(p), or hidden if Pr(c) > PVL(p) and O(c) < O(p), and no bar b with p < b < c has Pr(b) below the line from (p, PVL(p)) to (c, Pr(c)) or O(b) below the line from (p, O(p)) to (c, O(c))
Calculation: Div(O, high) = (p, kind) on chart bars, with c = bar - N: p is the first of the last pivot memory pivot highs of PVH before c, most recent first, with min separation < c - p <= max bars, where kind = regular if Pr(c) > PVH(p) and O(c) < O(p), or hidden if Pr(c) < PVH(p) and O(c) > O(p), and no bar b with p < b < c has Pr(b) above the line from (p, PVH(p)) to (c, Pr(c)) or O(b) above the line from (p, O(p)) to (c, O(c))
Calculation: Votes(side, kind) = max over p of the number of O in {MACD line(close, fast, slow, signal), MACD histogram(close, fast, slow, signal), RSI(close, RSI length), SMA(Stoch(close, high, low, stoch length), smoothing length), CCI(close, CCI length), Momentum(close, momentum length), OBV(close, volume), VWMACD(close, volume, vw fast, vw slow), CMF(high, low, close, volume, CMF length), MFI(close, volume, MFI length), external series E} with Div(O, side) = (p, kind)
Long: PivotLow(PVL, N, N) confirmed on this bar AND Votes(low, regular) >= min count
Long: PivotLow(PVL, N, N) confirmed on this bar AND Votes(low, hidden) >= min count
Short: PivotHigh(PVH, N, N) confirmed on this bar AND Votes(high, regular) >= min count
Short: PivotHigh(PVH, N, N) confirmed on this bar AND Votes(high, hidden) >= min count
Calculation: H = T5 if chart < T5; T6 if T5 <= chart <= T7; T4 if T7 < chart < T4; T3 if chart is T4; T2 otherwise
Calculation: SwingHigh, SwingHighTime = high and bar time of the latest PivotHigh(high, pivot left, pivot right) confirmed by this bar, on H bars
Calculation: SwingLow, SwingLowTime = low and bar time of the latest PivotLow(low, pivot left, pivot right) confirmed by this bar, on H bars
Calculation: Structure = -1 if Structure[1] = 1 and close < SwingLow; +1 if Structure[1] = -1 and close > SwingHigh; otherwise Structure[1]; starting at +1; on H bars
Calculation: BullSetupT = bar time of the nearest i in 1..lookback with close[i] < open[i] and time[i] <= SwingLowTime, if Structure[1] = -1, Structure = 1, and low[i] > high[i+2] and close[i+1] > open[i+1] for some i in 1..lookback; otherwise none; on H bars, read on chart bars as last completed H bar
Calculation: BearSetupT = bar time of the nearest i in 1..lookback with close[i] > open[i] and time[i] <= SwingHighTime, if Structure[1] = 1, Structure = -1, and high[i] < low[i+2] and close[i+1] < open[i+1] for some i in 1..lookback; otherwise none; on H bars, read on chart bars as last completed H bar
Long: BullSetupT != none AND BullSetupT != time of previously marked setup
Short: BearSetupT != none AND BearSetupT != time of previously marked setup