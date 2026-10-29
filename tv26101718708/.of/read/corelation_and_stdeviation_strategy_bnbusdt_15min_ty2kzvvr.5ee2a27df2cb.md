Calculation: P = linear regression of close over lookback L
Calculation: G = sum, over Parabolic SAR, Supertrend, RSI, MFI, Balance of Power, Chande Momentum Oscillator, Center of Gravity, ADX, Stochastic, SWMA, Williams %R, TSI, Intraday Intensity, NVI, PVI, OBV, Accumulation/Distribution, Price-Volume Trend, True Range, VWAP, Williams Accumulation/Distribution, SMA, EMA, CCI, Chop Zone, Ease of Movement, DPO, Advance-Decline Line, Bull-Bear Power, and smoothed high, low, open, and close, of each indicator's standard deviation over L × its correlation with P over L × the standard deviation over L of (indicator − its 5-bar Bollinger basis with 4 standard deviations); for SAR and Supertrend omit the final standard-deviation factor. For the SMA and EMA indicators, use the L-bar average minus the 200-bar SMA as the indicator.
Calculation: C = G × correlation(G, P, L)
Calculation: V = correlation(G, P, L) × standard deviation(G, L)
Calculation: D = change(G, 2 bars)
Calculation: R = 100 × change(D, 2 bars) / D[1]
Calculation: CC = C × correlation(C, P, L)
Calculation: CV = correlation(C, P, L) × standard deviation(C, L)
Calculation: SD = V × correlation(V, P, L)
Calculation: SV = correlation(V, P, L) × standard deviation(V, L)
Calculation: E = change(C, 2 bars)
Calculation: Q = (change(E, 1 bar)) × correlation(change(C, 1 bar), P, L)^3 × standard deviation(change(C, 1 bar), L)
Calculation: F = change(V, L)
Calculation: H = change(F, 1 bar)
Calculation: U = standard deviation(CC, L) × correlation(CC, P, L)
Calculation: W = standard deviation(SD, L) × correlation(SD, P, L)
Calculation: X = standard deviation(CC, L) × correlation(CC, P, L) × correlation(CC, P, L)
Calculation: Y = standard deviation(SV, L) × correlation(SV, P, L)
Long: P is falling over the short falling-price lookback AND standard deviation(CV, L) crosses below 0
Long: P is falling over the short falling-price lookback AND W crosses 0
Long: P is falling over the short falling-price lookback AND R, 100 × change(change(CC, 2 bars), 2 bars) / change(CC, 2 bars)[1], and 100 × change(change(SV, 2 bars), 2 bars) / change(SV, 2 bars)[1] each cross 0
Long: P is falling over the short falling-price lookback AND D, change(CC, 2 bars), and F each cross 0
Long: P is falling over the short falling-price lookback AND C, V, and D each cross 0
Long: P is falling over the short falling-price lookback AND D, change(CC, 2 bars), and change(SV, 2 bars) each cross the other
Long: flat position AND one of the first three Long conditions AND selected lower-point price < prior rolling-low turning point
Long: long position AND one of the first four Long conditions AND short moving average of hl2 < average entry price × 0.99
Long: long position AND last Long crossover condition AND short moving average of hl2 < average entry price
Exit: long, sell Supertrend changes from bullish to bearish OR bearish Supertrend with any Long condition, AND profit target line < short moving average of hl2 AND prior rolling-high turning point and rolling-low turning point exist
Exit: long, short SMA of close > minimum entry price × (1 + swing-profit threshold) AND intermediate selling is enabled AND both rolling turning points exist AND average entry price > short moving average of hl2