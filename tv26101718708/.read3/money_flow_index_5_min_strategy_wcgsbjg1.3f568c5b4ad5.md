Calculation: Bullish setup = MFI(close, MFI lookback)[1] = upper MFI boundary AND close > open AND abs(close - open) > (high - low) * body-size threshold AND (trend filter disabled OR close > SMA(close, trend lookback))
Calculation: Bearish setup = short mode enabled AND MFI(close, MFI lookback)[1] = lower MFI boundary AND close < open AND abs(close - open) > (high - low) * body-size threshold AND (trend filter disabled OR close <= SMA(close, trend lookback))
Long: (reverse trades disabled AND (direct position reversal enabled OR position flat) AND Bullish setup) OR (reverse trades enabled AND (direct position reversal enabled OR position flat) AND Bearish setup)
Short: (reverse trades enabled AND (direct position reversal enabled OR position flat) AND Bullish setup) OR (reverse trades disabled AND (direct position reversal enabled OR position flat) AND Bearish setup)
Calculation: Long stop = if stop type is swing, lowest(low, swing lookback) on the most recent position-size-change bar * (1 - stop increment); if stop type is ATR, OHLC4 - ATR(ATR lookback) * ATR multiple on that bar; otherwise, the current UTC day-start bar's low * (1 - stop increment)
Calculation: Short stop = if stop type is swing, highest(high, swing lookback) on the most recent position-size-change bar * (1 + stop increment); if stop type is ATR, OHLC4 + ATR(ATR lookback) * ATR multiple on that bar; otherwise, the current UTC day-start bar's high * (1 + stop increment)
Calculation: Long target = entry price + (entry price - Long stop) * risk/reward multiple
Calculation: Short target = entry price - (Short stop - entry price) * risk/reward multiple
Calculation: Long trailing stop = current bar high + Long stop - long entry-bar high, ratcheted upward to the greater of this value and the previous long trailing stop
Calculation: Short trailing stop = current bar low + Short stop - short entry-bar low, ratcheted downward to the lesser of this value and the previous short trailing stop
Calculation: Elapsed minutes since most recent position-size change = current bar time minus the time of the most recent position-size change, in minutes
Exit: long, stop/target exits enabled AND ((trailing stop enabled AND low <= Long trailing stop) OR (trailing stop disabled AND low <= Long stop) OR high >= Long target)
Exit: short, stop/target exits enabled AND ((trailing stop enabled AND high >= Short trailing stop) OR (trailing stop disabled AND high >= Short stop) OR low <= Short target)
Exit: long, timed exit enabled AND Elapsed minutes since most recent position-size change = exit interval
Exit: short, timed exit enabled AND Elapsed minutes since most recent position-size change = exit interval