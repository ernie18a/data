Calculation: ATR = average true range
Calculation: Fast EMA = exponential moving average of close with a shorter lookback than the slow EMA
Calculation: Slow EMA = exponential moving average of close with a longer lookback than the fast EMA
Calculation: Range high = highest high over the range lookback
Calculation: Range low = lowest low over the range lookback
Calculation: Bullish signal bar = high > low AND high - low <= ATR × maximum bar-size multiple AND abs(close - open) / (high - low) >= minimum body-to-range ratio AND close > open AND (close - low) / (high - low) >= minimum close-strength ratio
Calculation: Bearish signal bar = high > low AND high - low <= ATR × maximum bar-size multiple AND abs(close - open) / (high - low) >= minimum body-to-range ratio AND close < open AND (high - close) / (high - low) >= minimum close-strength ratio
Calculation: Bullish trigger = bullish signal bar AND high > previous bar high
Calculation: Bearish trigger = bearish signal bar AND low < previous bar low
Calculation: Long trend-pullback count = reset to 0 whenever fast EMA is not above slow EMA, fast EMA is not above its value at the slope lookback, or close is not above slow EMA; while all three comparisons hold, set a pending pullback when low <= fast EMA, then increment the count on a bullish trigger with a pending pullback and clear the pending pullback
Calculation: Short trend-pullback count = reset to 0 whenever fast EMA is not below slow EMA, fast EMA is not below its value at the slope lookback, or close is not below slow EMA; while all three comparisons hold, set a pending pullback when high >= fast EMA, then increment the count on a bearish trigger with a pending pullback and clear the pending pullback
Long: bullish signal bar
Long: low <= fast EMA has occurred during the current uptrend and a bullish trigger occurs
Long: NOT in range AND fast EMA > slow EMA AND fast EMA > its value at the slope lookback AND close > slow EMA AND a bullish trigger follows a pending pullback AND long trend-pullback count >= 2
Long: in range AND close <= range low + (range high - range low) × edge-zone fraction AND bullish trigger
Short: bearish signal bar
Short: high >= fast EMA has occurred during the current downtrend and a bearish trigger occurs
Short: NOT in range AND fast EMA < slow EMA AND fast EMA < its value at the slope lookback AND close < slow EMA AND a bearish trigger follows a pending pullback AND short trend-pullback count >= 2
Short: in range AND close >= range high - (range high - range low) × edge-zone fraction AND bearish trigger
Calculation: In range = NOT (fast EMA > slow EMA AND fast EMA > its value at the slope lookback AND close > slow EMA) AND NOT (fast EMA < slow EMA AND fast EMA < its value at the slope lookback AND close < slow EMA) AND range high - range low <= ATR × maximum range-height multiple