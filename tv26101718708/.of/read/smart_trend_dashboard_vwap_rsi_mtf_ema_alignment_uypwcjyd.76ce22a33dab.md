Calculation: RSI = relative strength index of close, using the same lookback on each of four configured timeframes; use each requested timeframe’s current bar, which may still be forming, and may be higher or lower than the chart timeframe.
Calculation: EMA = exponential moving average of close, using the same lookback on each of four configured timeframes; use each requested timeframe’s current bar, which may still be forming, and may be higher or lower than the chart timeframe.
Calculation: Bullish score = count of these eight conditions that are true: RSI >= 50 on each of the four configured timeframes; chart close > EMA on each of the four configured timeframes.
Calculation: Daily VWAP = volume-weighted average of HLC3 since the start of the current day.
Calculation: Weekly VWAP = volume-weighted average of HLC3 since the start of the current week.
Long: Bullish score >= 6 OR (RSI >= 50 AND close > EMA) on any one of the four configured timeframes OR close > Daily VWAP OR close > Weekly VWAP
Short: Bullish score < 4 OR (RSI < 50 AND close < EMA) on any one of the four configured timeframes OR close < Daily VWAP OR close < Weekly VWAP