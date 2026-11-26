Calculation: Latest fractal high = high[2] when high[2] > high[1], high, high[3], and high[4]; otherwise the previous latest fractal high
Calculation: Latest fractal low = low[2] when low[2] < low[1], low, low[3], and low[4]; otherwise the previous latest fractal low
Calculation: Bullish fractal cross = fractal S/R cross enabled AND close crosses above the latest fractal high
Calculation: Bearish fractal cross = fractal S/R cross enabled AND close crosses below the latest fractal low
Calculation: Bullish pin bar = pin-bar pattern enabled AND open > low + (high - low) × pin-bar wick fraction AND close > low + (high - low) × pin-bar wick fraction
Calculation: Bearish pin bar = pin-bar pattern enabled AND open < high - (high - low) × pin-bar wick fraction AND close < high - (high - low) × pin-bar wick fraction
Calculation: Dark Cloud Cover = pattern enabled AND close[1] > open[1] AND abs(close[1] - open[1]) / (high[1] - low[1]) ≥ body-range threshold parameter AND close < open AND abs(close - open) / (high - low) ≥ body-range threshold parameter AND open ≥ close[1] AND close > open[1] AND close < (open[1] + close[1]) / 2
Calculation: Piercing Line = pattern enabled AND close[1] < open[1] AND abs(open[1] - close[1]) / (high[1] - low[1]) ≥ body-range threshold parameter AND close > open AND abs(close - open) / (high - low) ≥ body-range threshold parameter AND open ≤ close[1] AND close < open[1] AND close > (open[1] + close[1]) / 2
Calculation: Bearish Harami = pattern enabled AND close[1] > open[1] AND open > close AND open ≤ close[1] AND low ≥ open[1] AND open - close < close[1] - open[1] AND high < high[1] AND low > low[1]
Calculation: Bullish Harami = pattern enabled AND open[1] > close[1] AND close > open AND close ≤ open[1] AND high ≤ open[1] AND close - open < open[1] - close[1] AND high < high[1] AND low > low[1]
Calculation: Bearish Engulfing = pattern enabled AND close[1] > open[1] AND close < open AND close ≤ low[1] AND open ≥ close[1]
Calculation: Bullish Engulfing = pattern enabled AND close[1] < open[1] AND close > open AND close ≥ high[1] AND open ≤ close[1]
Calculation: Bullish CM reversal pin bar = reversal-pin-bar pattern enabled AND open > high - (high - low) × (1 - reversal-pin-bar wick fraction) AND close > high - (high - low) × (1 - reversal-pin-bar wick fraction) AND low ≤ lowest(low, reversal-pin-bar lookback)
Calculation: Bearish CM reversal pin bar = reversal-pin-bar pattern enabled AND open < high - (high - low) × reversal-pin-bar wick fraction AND close < high - (high - low) × reversal-pin-bar wick fraction AND high ≥ highest(high, reversal-pin-bar lookback)
Calculation: Bullish shaved bar = shaved-bar pattern enabled AND close ≥ high - (high - low) × shaved-bar close fraction
Calculation: Bearish shaved bar = shaved-bar pattern enabled AND close ≤ low + (high - low) × shaved-bar close fraction
Calculation: Inside bar = inside-bar pattern enabled AND high < high[1] AND low > low[1]
Calculation: Outside bar = outside-bar pattern enabled AND high > high[1] AND low < low[1]
Calculation: Bullish alert filter = (MACD confirmation disabled OR ((MACD line(close, fast lookback, slow lookback) > 0 AND MACD line(close, fast lookback, slow lookback) > its prior value) OR (MACD line(close, fast lookback, slow lookback) ≤ 0 AND MACD line(close, fast lookback, slow lookback) ≥ its prior value))) AND (trend filter disabled OR selected moving average type(selected source, MA lookback) > its prior value)
Calculation: Bearish alert filter = (MACD confirmation disabled OR ((MACD line(close, fast lookback, slow lookback) > 0 AND MACD line(close, fast lookback, slow lookback) ≤ its prior value) OR (MACD line(close, fast lookback, slow lookback) ≤ 0 AND MACD line(close, fast lookback, slow lookback) < its prior value))) AND (trend filter disabled OR selected moving average type(selected source, MA lookback) < its prior value)
Long: Bullish CM reversal pin bar
Short: Bearish CM reversal pin bar
Long: Bullish shaved bar
Short: Bearish shaved bar
Long: (bullish alert filter AND (bullish fractal cross OR bullish engulfing OR bullish harami OR bullish pin bar OR piercing line OR inside bar OR outside bar OR bullish shaved bar)) OR bullish CM reversal pin bar
Short: (bearish alert filter AND (bearish fractal cross OR bearish engulfing OR bearish harami OR bearish pin bar OR dark cloud cover OR inside bar OR outside bar OR bearish shaved bar)) OR bearish CM reversal pin bar
Long: bullish alert filter AND NOT (bullish CM reversal pin bar OR bearish CM reversal pin bar OR bearish shaved bar OR inside bar OR outside bar) AND (bullish harami OR bullish engulfing OR piercing line OR bullish fractal cross OR bullish pin bar)
Short: bearish alert filter AND NOT (bullish CM reversal pin bar OR bearish CM reversal pin bar OR bullish shaved bar OR inside bar OR outside bar) AND (bearish harami OR bearish engulfing OR dark cloud cover OR bearish fractal cross OR bearish pin bar)
Long: On chart bars, close of the still-forming T2 bar crosses above open of the still-forming T1 bar OR (chart-bar close > open of the still-forming T1 bar AND (bullish pin bar OR piercing line OR bullish harami OR bullish engulfing OR bullish fractal cross) AND position is flat)
Short: On chart bars, close of the still-forming T2 bar crosses below open of the still-forming T1 bar OR (chart-bar close < open of the still-forming T1 bar AND (bearish pin bar OR dark cloud cover OR bearish harami OR bearish engulfing OR bearish fractal cross) AND position is flat)