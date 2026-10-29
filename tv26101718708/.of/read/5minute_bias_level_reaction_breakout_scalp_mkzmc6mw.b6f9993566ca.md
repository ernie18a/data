Calculation: ATR = average true range
Calculation: Swing high = highest pivot high confirmed after the specified number of bars on both sides
Calculation: Swing low = lowest pivot low confirmed after the specified number of bars on both sides
Calculation: Bullish bias = most recent close above the most recent confirmed swing high; bearish bias = most recent close below the most recent confirmed swing low; otherwise retain the prior bias, initially neutral
Calculation: Key level = most recent swing low in bullish bias; most recent swing high in bearish bias
Calculation: Long reaction = low <= key level + ATR-based proximity tolerance AND close > open AND (rejection-wick filter disabled OR (high - max(open, close)) > 0 AND (min(open, close) - low) / (high - low) >= minimum rejection-wick ratio)
Calculation: Short reaction = high >= key level - ATR-based proximity tolerance AND close < open AND (rejection-wick filter disabled OR (high - max(open, close)) / (high - low) >= minimum rejection-wick ratio)
Calculation: Long stop = min(reaction candle low, most recent swing low) - ATR-based stop buffer; long target = entry price + (entry price - long stop) * reward multiple
Calculation: Short stop = max(reaction candle high, most recent swing high) + ATR-based stop buffer; short target = entry price - (short stop - entry price) * reward multiple
Long: bullish bias AND long reaction while no setup is armed; OR an armed long setup with bullish bias, within the maximum wait bars, and (high >= reaction candle high for wick-break mode OR close >= reaction candle high for close-break mode), while no position is active and daily trades are below the daily cap
Short: bearish bias AND short reaction while no setup is armed; OR an armed short setup with bearish bias, within the maximum wait bars, and (low <= reaction candle low for wick-break mode OR close <= reaction candle low for close-break mode), while no position is active and daily trades are below the daily cap
Exit: long, high >= long target OR low <= long stop
Exit: short, low <= short target OR high >= short stop