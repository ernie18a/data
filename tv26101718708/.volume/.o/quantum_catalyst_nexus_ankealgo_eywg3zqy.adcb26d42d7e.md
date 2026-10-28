Calculation: Bullish MSS = close crosses above the last confirmed swing high and exceeds it by more than ATR multiplied by a threshold
Calculation: Bearish MSS = close crosses below the last confirmed swing low and exceeds it by more than ATR multiplied by a threshold
Calculation: Relative volume = current volume / rolling average volume
Calculation: Delta flow = (((close - low) - (high - close)) / max(high - low, minimum price increment)) * 100
Calculation: Smoothed delta = EMA of delta flow
Calculation: Bullish pressure = close > open AND delta flow > 0 AND smoothed delta > 0
Calculation: Bearish pressure = close < open AND delta flow < 0 AND smoothed delta < 0
Calculation: Bull impulse = body / candle range >= threshold AND close > fast EMA
Calculation: Bear impulse = body / candle range >= threshold AND close < fast EMA
Calculation: Fast and slow EMA = EMA of (high + low + close) / 3, with the slow EMA using a longer lookback than the fast EMA
Calculation: Higher-timeframe bullish bias = fast EMA >= slow EMA AND smoothed delta >= 0
Calculation: Higher-timeframe bearish bias = fast EMA <= slow EMA AND smoothed delta <= 0
Calculation: Bull score = 2 for bullish MSS, plus 1 each for relative volume >= threshold, bullish pressure, bull impulse, fast EMA > slow EMA, and higher-timeframe bullish bias (or disabled higher-timeframe filter)
Calculation: Bear score = 2 for bearish MSS, plus 1 each for relative volume >= threshold, bearish pressure, bear impulse, fast EMA < slow EMA, and higher-timeframe bearish bias (or disabled higher-timeframe filter)
Long: bullish MSS AND higher-timeframe bullish bias (or higher-timeframe filter disabled) AND bull score >= minimum score
Short: bearish MSS AND higher-timeframe bearish bias (or higher-timeframe filter disabled) AND bear score >= minimum score