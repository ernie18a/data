Calculation: VAWMA(x, lookback) = SUM(x[n] * volume[n] * (lookback - n), n = 0..lookback-1) / SUM(volume[n] * (lookback - n), n = 0..lookback-1)
Calculation: StochRSI D = SMA(selected MA(StochRSI(source, RSI lookback, stochastic lookback), K smoothing), D smoothing)
Calculation: Upper-anchor AVWAP = AVWAP(selected high or HLC3 source, volume, from the latest StochRSI D cross down from overbought)
Calculation: Lower-anchor AVWAP = AVWAP(selected low or HLC3 source, volume, from the latest StochRSI D cross up from oversold)
Long: position is flat or short AND selected alert price (open or close) > Upper-anchor AVWAP AND bar time is within the configured date range AND (trend filter disabled OR close > selected SMA or EMA(close, trend lookback, T1, current T1 bar still forming, sampled on chart bars)) AND (volume filter disabled OR volume > SMA(volume, volume lookback) * volume multiplier) AND (cooldown disabled OR no prior exit OR elapsed chart bars since exit >= cooldown lookback)
Short: short trading enabled AND position is flat or long AND selected alert price (open or close) < Lower-anchor AVWAP AND bar time is within the configured date range AND (trend filter disabled OR close < selected SMA or EMA(close, trend lookback, T1, current T1 bar still forming, sampled on chart bars)) AND (volume filter disabled OR volume > SMA(volume, volume lookback) * volume multiplier) AND (cooldown disabled OR no prior exit OR elapsed chart bars since exit >= cooldown lookback)
Exit: Long, selected alert price (open or close) < Lower-anchor AVWAP AND (minimum hold disabled OR elapsed chart bars since entry >= minimum-hold lookback)
Exit: Short, selected alert price (open or close) > Upper-anchor AVWAP AND (minimum hold disabled OR elapsed chart bars since entry >= minimum-hold lookback)
Exit: Long, ATR stop enabled AND low <= close on the long-entry signal bar - ATR(lookback) on that bar * ATR multiplier
Exit: Short, ATR stop enabled AND high >= close on the short-entry signal bar + ATR(lookback) on that bar * ATR multiplier
Exit: Long, partial take profit enabled AND high >= entry price * (1 + target percentage)
Exit: Short, partial take profit enabled AND low <= entry price * (1 - target percentage)
Exit: Long, bar time is outside the configured date range AND prior bar time was within it
Exit: Short, bar time is outside the configured date range AND prior bar time was within it