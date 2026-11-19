Calculation: Recent bullish trigger = a chart bar within the trigger-window parameter chart bars had close cross above EMA(close, chart EMA lookback) AND RSI(close, RSI lookback) > RSI midpoint parameter
Calculation: Recent bearish trigger = a chart bar within the trigger-window parameter chart bars had close cross below EMA(close, chart EMA lookback) AND RSI(close, RSI lookback) < RSI midpoint parameter
Calculation: T1 bullish state = on chart bars, using values calculated on the current T1 bar, which may still be forming, T1 close > EMA(close, T1 EMA lookback) AND EMA(close, T1 EMA lookback) > EMA(close, T1 EMA lookback, T1 slope-lookback bars ago)
Calculation: T1 bearish state = on chart bars, using values calculated on the current T1 bar, which may still be forming, T1 close < EMA(close, T1 EMA lookback) AND EMA(close, T1 EMA lookback) < EMA(close, T1 EMA lookback, T1 slope-lookback bars ago)
Calculation: T2 bullish state = on chart bars, using values calculated on the current T2 bar, which may still be forming, T2 close > EMA(close, T2 EMA lookback) AND EMA(close, T2 EMA lookback) > EMA(close, T2 EMA lookback, T2 slope-lookback bars ago)
Calculation: T2 bearish state = on chart bars, using values calculated on the current T2 bar, which may still be forming, T2 close < EMA(close, T2 EMA lookback) AND EMA(close, T2 EMA lookback) < EMA(close, T2 EMA lookback, T2 slope-lookback bars ago)
Calculation: Bullish cascade = Recent bullish trigger AND T1 bullish state AND T2 bullish state
Calculation: Bearish cascade = Recent bearish trigger AND T1 bearish state AND T2 bearish state
Calculation: Full-cascade score = round(min(all active levels × points-per-level parameter + score-bonus parameter when chart RSI(close, RSI lookback) > upper score-RSI parameter OR chart RSI(close, RSI lookback) < lower score-RSI parameter, score-cap parameter))
Long: Chart close crosses above EMA(close, chart EMA lookback) AND RSI(close, RSI lookback) > RSI midpoint parameter
Short: Chart close crosses below EMA(close, chart EMA lookback) AND RSI(close, RSI lookback) < RSI midpoint parameter
Long: Recent bullish trigger
Short: Recent bearish trigger AND NOT Recent bullish trigger
Long: T1 bullish state
Short: T1 bearish state
Long: T2 bullish state
Short: T2 bearish state
Long: T1 bullish state AND T2 bullish state
Short: T1 bearish state AND T2 bearish state
Long: RSI(close, RSI lookback) > upper score-RSI parameter
Short: RSI(close, RSI lookback) < lower score-RSI parameter
Long: Bullish cascade
Short: Bearish cascade
Long: Chart bar is confirmed AND Bullish cascade is true AND Bullish cascade was false on the prior chart bar AND Full-cascade score >= signal-score threshold parameter AND chart bar index minus the last signal chart bar index, initially zero, >= cooldown parameter
Short: Chart bar is confirmed AND Bearish cascade is true AND Bearish cascade was false on the prior chart bar AND Full-cascade score >= signal-score threshold parameter AND chart bar index minus the last signal chart bar index, initially zero, >= cooldown parameter