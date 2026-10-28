Calculation: Fast, mid, and slow EMAs = EMAs of close with progressively longer lookbacks
Calculation: Trend strength = ADX, clamped to its configured range and scaled to a score contribution
Calculation: Bull trend = fast EMA > mid EMA AND mid EMA > slow EMA AND close > mid EMA
Calculation: Bear trend = fast EMA < mid EMA AND mid EMA < slow EMA AND close < mid EMA
Calculation: Bull VWAP context = close > session VWAP AND session VWAP > its prior-bar value
Calculation: Bear VWAP context = close < session VWAP AND session VWAP < its prior-bar value
Calculation: Bull momentum = MACD histogram > 0 AND RSI > its bullish threshold AND positive directional index > negative directional index
Calculation: Bear momentum = MACD histogram < 0 AND RSI < its bearish threshold AND negative directional index > positive directional index
Calculation: Pressure = EMA of ((close - open) / max(high - low, minimum price increment) × volume) divided by EMA of the absolute value of that quantity, scaled and clamped to a bounded range
Calculation: Volume impulse = volume / SMA(volume, volume lookback)
Calculation: Bid pressure = pressure > bullish pressure threshold AND volume impulse > its threshold
Calculation: Ask pressure = pressure < bearish pressure threshold AND volume impulse > its threshold
Calculation: Bullish absorption = low < prior low AND close > open AND pressure > prior pressure AND volume impulse > its absorption threshold
Calculation: Bearish absorption = high > prior high AND close < open AND pressure < prior pressure AND volume impulse > its absorption threshold
Calculation: Weighted auction price = SMA(typical price × volume, auction lookback) / SMA(volume, auction lookback), where typical price = (high + low + close) / 3
Calculation: Auction deviation = standard deviation of typical price over the auction lookback
Calculation: Value high and low = weighted auction price ± auction deviation × deviation multiplier
Calculation: Auction discount = close < value low AND close > low + (high - low) × range-location threshold
Calculation: Auction premium = close > value high AND close < high - (high - low) × range-location threshold
Calculation: Auction reclaim = close > value low AND prior close <= prior value low
Calculation: Auction rejection = close < value high AND prior close >= prior value high
Calculation: Bullish displacement = absolute(close - open) > ATR × displacement multiplier AND volume impulse > its threshold
Calculation: Bearish displacement = bullish displacement
Calculation: Bullish break of structure = close crosses above the latest confirmed pivot high AND bullish displacement
Calculation: Bearish break of structure = close crosses below the latest confirmed pivot low AND bearish displacement
Calculation: Sweep of low = low < latest confirmed pivot low AND close > latest confirmed pivot low
Calculation: Sweep of high = high > latest confirmed pivot high AND close < latest confirmed pivot high
Calculation: Bullish gap = low > high two bars earlier AND close > open
Calculation: Bearish gap = high < low two bars earlier AND close < open
Calculation: Structure bias = +1 after a bullish break of structure; -1 after a bearish break; otherwise retain its prior value
Calculation: Bullish structure = structure bias is +1 OR sweep of low OR bullish gap
Calculation: Bearish structure = structure bias is -1 OR sweep of high OR bearish gap
Calculation: Volatility expansion = percentile rank of ATR as a percentage of close over the regime lookback exceeds its expansion threshold
Calculation: Confirmed higher-timeframe EMA = EMA of close on the configured higher timeframe, taken from its last completed bar
Calculation: Long higher-timeframe pass = higher-timeframe filter is disabled OR close > confirmed higher-timeframe EMA
Calculation: Short higher-timeframe pass = higher-timeframe filter is disabled OR close < confirmed higher-timeframe EMA
Calculation: Long score = weighted sum of bull trend, bull VWAP context, bull momentum, bid pressure, bullish absorption, bullish structure, (auction discount OR auction reclaim), long higher-timeframe pass, (volatility expansion AND NOT auction premium), and trend strength; clamp to score range
Calculation: Short score = weighted sum of bear trend, bear VWAP context, bear momentum, ask pressure, bearish absorption, bearish structure, (auction premium OR auction rejection), short higher-timeframe pass, (volatility expansion AND NOT auction discount), and trend strength; clamp to score range
Long: current bar is completed AND long score >= long score threshold AND long score > short score + dominance margin AND long higher-timeframe pass AND NOT auction premium
Short: current bar is completed AND short score >= short score threshold AND short score > long score + dominance margin AND short higher-timeframe pass AND NOT auction discount
Exit: long, current bar is completed AND (short score > long score OR close < mid EMA OR (auction premium AND pressure < 0))
Exit: short, current bar is completed AND (long score > short score OR close > mid EMA OR (auction discount AND pressure > 0))