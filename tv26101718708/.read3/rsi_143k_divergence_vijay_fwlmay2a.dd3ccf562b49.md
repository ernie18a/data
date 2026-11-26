Calculation: Bullish divergence = the current confirmed low pivot in low and RSI(close, RSI lookback) and the previous paired confirmed low pivot, using the pivot lookback parameter on both sides, are separated by at least the minimum pivot separation parameter and at most the maximum pivot separation parameter, and the current pivot low is below the previous pivot low, the current pivot RSI is above the previous pivot RSI, and the current pivot RSI is below the overbought level minus a bullish RSI offset parameter
Calculation: Bearish divergence = the current confirmed high pivot in high and RSI(close, RSI lookback) and the previous paired confirmed high pivot, using the pivot lookback parameter on both sides, are separated by at least the minimum pivot separation parameter and at most the maximum pivot separation parameter, and the current pivot high is above the previous pivot high, the current pivot RSI is below the previous pivot RSI, and the current pivot RSI is above the oversold level plus a bearish RSI offset parameter
Calculation: Bullish setup = set on bullish divergence and cleared on bearish divergence, when its age exceeds the setup-duration parameter, or when either qualifying entry signal fires
Calculation: Bearish setup = set on bearish divergence and cleared on bullish divergence, when its age exceeds the setup-duration parameter, or when either qualifying entry signal fires; if both divergences occur on the same bar, bearish setup takes precedence
Long: RSI(close, RSI lookback) < oversold level
Short: RSI(close, RSI lookback) > overbought level
Long: RSI(close, RSI lookback) > EMA(RSI(close, RSI lookback), smoothing lookback)
Short: RSI(close, RSI lookback) <= EMA(RSI(close, RSI lookback), smoothing lookback)
Long: close > VWAP(hlc3)
Short: close <= VWAP(hlc3)
Long: Bullish divergence
Short: Bearish divergence
Long: Bullish setup is active
Short: Bearish setup is active
Long: Bullish setup is active AND RSI(close, RSI lookback) crosses above EMA(RSI(close, RSI lookback), smoothing lookback)
Short: Bearish setup is active AND RSI(close, RSI lookback) crosses below EMA(RSI(close, RSI lookback), smoothing lookback)
Long: Bullish setup is active AND RSI(close, RSI lookback) crosses above EMA(RSI(close, RSI lookback), smoothing lookback) AND (first-15-minute filter is disabled OR bar time in Asia/Kolkata is at or after 09:30) AND (VWAP filter is disabled OR close > VWAP(hlc3)) AND (volume filter is disabled OR volume >= SMA(volume, volume-average lookback) * volume multiplier)
Short: Bearish setup is active AND RSI(close, RSI lookback) crosses below EMA(RSI(close, RSI lookback), smoothing lookback) AND (first-15-minute filter is disabled OR bar time in Asia/Kolkata is at or after 09:30) AND (VWAP filter is disabled OR close < VWAP(hlc3)) AND (volume filter is disabled OR volume >= SMA(volume, volume-average lookback) * volume multiplier)