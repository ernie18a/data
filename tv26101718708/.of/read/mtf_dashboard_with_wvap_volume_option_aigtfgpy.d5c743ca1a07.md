Calculation: VWAP = daily-session-anchored (reset at each new day) volume-weighted average of (high+low+close)/3
Calculation: MidRSI = RSI of close on a mid timeframe, computed from bars aggregated from chart bars, using the still-forming bar of that timeframe; SlowRSI = same on a timeframe longer than the mid timeframe
Calculation: EMA_fast, EMA_slow, EMA_trend = EMAs of close with lookbacks fast < slow < trend
Calculation: Score = count of true among: close > EMA_trend; EMA_fast > EMA_slow; EMA_slow > EMA_trend; MidRSI > 50; SlowRSI > 50
Long: Score >= 4
Long: close >= VWAP
Short: Score <= 2
Short: close < VWAP