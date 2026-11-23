Calculation: BodyRatio = |close - open| / (high - low)
Calculation: BullImbalance = close > open AND BodyRatio >= body-to-range threshold AND volume >= volume spike multiplier * SMA(volume, imbalance lookback) AND SMA(close, shorter lookback) > SMA(close, longer lookback)
Calculation: BearImbalance = close < open AND BodyRatio >= body-to-range threshold AND volume >= volume spike multiplier * SMA(volume, imbalance lookback) AND SMA(close, shorter lookback) < SMA(close, longer lookback)
Calculation: SwingLow = Lowest(low, imbalance lookback)[swing offset]
Calculation: SwingHigh = Highest(high, imbalance lookback)[swing offset]
Calculation: SessionOK = session filter disabled OR (London session enabled AND datetime[1] in London window) OR (New York session enabled AND datetime[1] in New York window)
Calculation: HtfMA = SMA(close, T1 lookback, T1, last completed bar)
Long: BullImbalance[1] AND NOT BullImbalance[2] AND (liquidity sweep filter disabled OR (Lowest(low, sweep window)[1] < SwingLow AND close[1] > SwingLow)) AND SessionOK AND (divergence filter disabled OR (low[1] < low[1 + imbalance lookback] AND RSI(close, RSI length)[1] > RSI(close, RSI length)[1 + imbalance lookback])) AND (T1 alignment filter disabled OR close(T1, last completed bar) > HtfMA)
Short: BearImbalance[1] AND NOT BearImbalance[2] AND (liquidity sweep filter disabled OR (Highest(high, sweep window)[1] > SwingHigh AND close[1] < SwingHigh)) AND SessionOK AND (divergence filter disabled OR (high[1] > high[1 + imbalance lookback] AND RSI(close, RSI length)[1] < RSI(close, RSI length)[1 + imbalance lookback])) AND (T1 alignment filter disabled OR close(T1, last completed bar) < HtfMA)
Exit: long, dynamic re-entry zone enabled AND low <= entry price - stop loss ATR multiplier * ATR(ATR period, entry bar)
Exit: short, dynamic re-entry zone enabled AND high >= entry price + stop loss ATR multiplier * ATR(ATR period, entry bar)