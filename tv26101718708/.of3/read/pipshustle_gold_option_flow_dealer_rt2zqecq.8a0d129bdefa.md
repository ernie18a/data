Calculation: Bullish sweep = low < Lowest(low[1], sweep lookback) AND close > Lowest(low[1], sweep lookback)
Calculation: Bearish sweep = high > Highest(high[1], sweep lookback) AND close < Highest(high[1], sweep lookback)
Calculation: Bullish reclaim = Bullish sweep AND close > open
Calculation: Bearish reclaim = Bearish sweep AND close < open
Calculation: High volume = volume > SMA(volume, volume-average lookback) * volume multiplier
Calculation: Active dealer = High volume AND close <= VWAP(hlc3) + ATR(ATR lookback) * dealer-zone width AND close >= VWAP(hlc3) - ATR(ATR lookback) * dealer-zone width
Calculation: Bull score = count of true conditions among Bullish sweep, Bullish reclaim, close > VWAP(hlc3) AND close > EMA(close, shorter EMA lookback), High volume, EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback), close > open AND ABS(close - open) > ATR(ATR lookback) * displacement multiplier, and Active dealer
Calculation: Bear score = count of true conditions among Bearish sweep, Bearish reclaim, close < VWAP(hlc3) AND close < EMA(close, shorter EMA lookback), High volume, EMA(close, shorter EMA lookback) < EMA(close, longer EMA lookback), close < open AND ABS(close - open) > ATR(ATR lookback) * displacement multiplier, and Active dealer
Long: Bullish sweep
Long: Bullish sweep AND Bullish reclaim AND Bull score >= minimum score AND (trend filter disabled OR EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback)) AND (no prior long signal OR bars since prior long signal > cooldown bars) AND chart bar confirmed
Long: After a bearish sweep level has been set, close crosses above the most recent high of a bearish sweep
Short: Bearish sweep
Short: Bearish sweep AND Bearish reclaim AND Bear score >= minimum score AND (trend filter disabled OR EMA(close, shorter EMA lookback) < EMA(close, longer EMA lookback)) AND (no prior short signal OR bars since prior short signal > cooldown bars) AND chart bar confirmed
Short: After a bullish sweep level has been set, close crosses below the most recent low of a bullish sweep