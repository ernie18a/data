Calculation: Bullish FVG = current low > high two bars earlier
Calculation: Bearish FVG = current high < low two bars earlier
Calculation: Bullish order block = previous bar closed below its open AND current close > previous high
Calculation: Bearish order block = previous bar closed above its open AND current close < previous low
Calculation: Bullish pin bar = lower wick >= 0.667 × bar range AND candle body <= 0.350 × bar range AND bar range > 0
Calculation: Bearish pin bar = upper wick >= 0.667 × bar range AND candle body <= 0.350 × bar range AND bar range > 0
Long: bullish pin bar OR (flat AND UTC hour within the London or New York kill zone AND close > slow EMA AND fast EMA > slow EMA AND close > VWAP when the VWAP filter is enabled AND RSI < overbought threshold AND (bullish FVG OR bullish order block OR previous bar was a bullish pin bar))
Short: bearish pin bar OR (flat AND UTC hour within the London or New York kill zone AND close < slow EMA AND fast EMA < slow EMA AND close < VWAP when the VWAP filter is enabled AND RSI > oversold threshold AND (bearish FVG OR bearish order block OR previous bar was a bearish pin bar))
Exit: long, low <= entry price - ATR × stop multiple OR high >= entry price + ATR × take-profit multiple
Exit: short, high >= entry price + ATR × stop multiple OR low <= entry price - ATR × take-profit multiple