Calculation: UpperBreakout = Highest(high, lookback)[1] + ATR(ATR length) * entry buffer
Calculation: LowerBreakout = Lowest(low, lookback)[1] - ATR(ATR length) * entry buffer
Calculation: ChannelRange = UpperBreakout - LowerBreakout
Calculation: StopDistance = Max(ATR(ATR length) * stop ATR multiple, ChannelRange * stop width fraction)
Calculation: TargetDistance = Max(ATR(ATR length) * target ATR multiple, ChannelRange * target width fraction)
Calculation: VolRatio = ATR(ATR length) / SMA(ATR(ATR length), volatility average length)
Calculation: AvgVolSpread = SMA(volume * (high - low), PVSRA length)
Long: position side is flat AND bar is closed AND close >= UpperBreakout AND close[1] < UpperBreakout[1] AND close > EMA(close, EMA length) AND VolRatio >= volatility minimum AND VolRatio <= volatility maximum
Long: position side is flat AND high >= UpperBreakout AND high[1] < UpperBreakout[1] AND close > EMA(close, EMA length) AND VolRatio >= volatility minimum AND VolRatio <= volatility maximum
Short: position side is flat AND bar is closed AND close <= LowerBreakout AND close[1] > LowerBreakout[1] AND close < EMA(close, EMA length) AND VolRatio >= volatility minimum AND VolRatio <= volatility maximum
Short: position side is flat AND low <= LowerBreakout AND low[1] > LowerBreakout[1] AND close < EMA(close, EMA length) AND VolRatio >= volatility minimum AND VolRatio <= volatility maximum
Long: close >= open AND (volume >= SMA(volume, PVSRA length) * climax multiple OR volume * (high - low) >= AvgVolSpread * climax multiple OR volume >= SMA(volume, PVSRA length) * rising multiple)
Short: close < open AND (volume >= SMA(volume, PVSRA length) * climax multiple OR volume * (high - low) >= AvgVolSpread * climax multiple OR volume >= SMA(volume, PVSRA length) * rising multiple)
Exit: long, bar index > entry bar index AND low <= entry price - StopDistance at entry bar
Exit: long, bar index > entry bar index AND VolRatio at entry bar >= trailing threshold AND Highest(high) over bars after entry bar >= entry price + TargetDistance at entry bar AND low <= Highest(close - StopDistance) from target-reached bar onward
Exit: short, bar index > entry bar index AND high >= entry price + StopDistance at entry bar
Exit: short, bar index > entry bar index AND VolRatio at entry bar >= trailing threshold AND Lowest(low) over bars after entry bar <= entry price - TargetDistance at entry bar AND high >= Lowest(close + StopDistance) from target-reached bar onward