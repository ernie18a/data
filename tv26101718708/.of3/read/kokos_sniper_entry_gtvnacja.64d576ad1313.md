Calculation: upper channel boundary = EMA(high, channel lookback)
Calculation: lower channel boundary = EMA(low, channel lookback)
Calculation: ATR filter passes = (filter mode is clearing-bar strength AND TR(high, low, close[1]) >= selected RMA, SMA, EMA, or WMA of TR(high, low, close[1]) over the ATR lookback times the strength multiplier) OR (filter mode is dead-channel avoidance AND upper channel boundary - lower channel boundary >= selected RMA, SMA, EMA, or WMA of TR(high, low, close[1]) over the ATR lookback times the channel-width multiplier)
Calculation: bullish T1 bias = on chart bars using the last completed T1 bar: high - low is positive AND (min(open, close) - low) / (high - low) >= wick-rejection threshold AND close >= (high + low) / 2
Calculation: bearish T1 bias = on chart bars using the last completed T1 bar: high - low is positive AND (high - max(open, close)) / (high - low) >= wick-rejection threshold AND close <= (high + low) / 2
Calculation: candle containment = (body-only mode AND max(open, close) <= upper channel boundary AND min(open, close) >= lower channel boundary) OR (full-candle mode AND high <= upper channel boundary AND low >= lower channel boundary)
Calculation: early long signal = (clearing mode is cross AND close crosses above upper channel boundary OR clearing mode is over/under AND close > upper channel boundary) AND (bull ATR filter disabled OR ATR filter passes) AND (T1 bias filter disabled OR bullish T1 bias) AND (session filter disabled OR current chart bar is in an enabled session) AND signal position was not long on the preceding chart bar
Calculation: early short signal = (clearing mode is cross AND close crosses below lower channel boundary OR clearing mode is over/under AND close < lower channel boundary) AND (bear ATR filter disabled OR ATR filter passes) AND (T1 bias filter disabled OR bearish T1 bias) AND (session filter disabled OR current chart bar is in an enabled session) AND signal position was not short on the preceding chart bar
Calculation: smart long signal = signal position is long AND candle containment AND (bullish intent mode is bullish candle AND close > open OR bullish intent mode is close above previous high AND close > high[1] OR bullish intent mode is close above previous midline AND close > hl2[1])
Calculation: smart short signal = signal position is short AND candle containment AND (bearish intent mode is bearish candle AND close < open OR bearish intent mode is close below previous low AND close < low[1] OR bearish intent mode is close below previous midline AND close < hl2[1])
Calculation: setup window expired = trade window enabled AND the configured number of chart bars, counted from the latest early signal, has elapsed
Long: bullish T1 bias
Short: bearish T1 bias
Long: signal position is long
Short: signal position is short
Long: early long signal OR (flip alerts enabled AND early short signal)
Short: early short signal OR (flip alerts enabled AND early long signal)
Long: smart long signal OR (flip alerts enabled AND smart short signal)
Short: smart short signal OR (flip alerts enabled AND smart long signal)
Exit: long, (optional safety enabled AND low < lower channel boundary) OR setup window expired
Exit: short, (optional safety enabled AND high > upper channel boundary) OR setup window expired