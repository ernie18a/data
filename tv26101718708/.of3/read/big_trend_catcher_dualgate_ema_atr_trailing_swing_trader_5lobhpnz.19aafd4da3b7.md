Calculation: Basic = (crosses above(close, EMA(close, shorter lookback)) OR open > high[1]) AND volume > SMA(volume, volume lookback) * volume threshold
Calculation: Pending = Basic OR prior Pending; clear on crosses below(close, EMA(close, shorter lookback)) or bars since Basic > timeout before entry evaluation; clear for the next bar after Pending AND close > EMA(close, shorter lookback) AND close > EMA(close, longer lookback) AND flat
Calculation: Trailing stop = close > prior trailing stop ? max(prior trailing stop, highest(high - ATR(ATR lookback) * stop multiplier, trailing lookback)) : low - ATR(ATR lookback) * stop multiplier; treat a missing prior trailing stop as 0
Long: Pending AND (close <= EMA(close, longer lookback) OR close <= EMA(close, shorter lookback))
Long: Pending AND close > EMA(close, shorter lookback) AND close > EMA(close, longer lookback) AND flat
Long: ((close - average entry price) / average entry price) * 100 > gain threshold AND close > EMA(close, shorter lookback) AND close > EMA(close, longer lookback) AND position side is long AND open trade count < trade limit
Long: crosses below(low, EMA(close, shorter lookback)) AND close > EMA(close, shorter lookback) AND close > EMA(close, longer lookback) AND position side is long
Exit: long, close < trailing stop OR crosses below(close, EMA(close, longer lookback))