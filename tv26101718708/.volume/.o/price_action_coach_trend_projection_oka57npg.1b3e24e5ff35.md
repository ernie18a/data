Calculation: Short-term, medium-term, and long-term EMA = exponential moving averages of close, with progressively longer lookbacks
Calculation: Trend slope = current linear-regression value of close over the trend lookback minus its value on the prior bar
Calculation: Recent high/low = highest high / lowest low over the trend lookback
Calculation: Volume ratio = volume divided by its moving average
Calculation: Resistance/support = highest high / lowest low over the breakout lookback, excluding the current bar
Calculation: Bullish divergence = low < low from several bars ago AND RSI > RSI from those bars ago AND RSI below the lower divergence threshold
Calculation: Bearish divergence = high > high from several bars ago AND RSI < RSI from those bars ago AND RSI above the upper divergence threshold
Calculation: Bullish engulfing = close > open AND prior close < prior open AND close > prior open AND open < prior close
Calculation: Bearish engulfing = close < open AND prior close > prior open AND close < prior open AND open > prior close
Calculation: Hammer = lower wick > body size multiplied by a wick threshold AND upper wick < body size AND close > open
Calculation: Shooting star = upper wick > body size multiplied by a wick threshold AND lower wick < body size AND close < open
Calculation: Double bottom/top = the latest two confirmed pivot lows/highs are within a proximity threshold AND a new pivot low/high is confirmed
Calculation: Breakout/breakdown = close > resistance / close < support AND prior close <= resistance / >= support AND volume ratio exceeds a surge threshold
Long: close > short-term EMA OR close > medium-term EMA OR close > long-term EMA OR short-term EMA > medium-term EMA OR RSI > midpoint and RSI < upper bullish threshold OR trend slope > 0 OR close > prior bar's recent high OR low > prior bar's recent low AND that prior recent low > the recent low from a trend-lookback-bars-ago OR volume ratio exceeds a surge threshold AND close > open OR bullish engulfing OR hammer OR double bottom OR bullish divergence OR breakout
Short: close < short-term EMA OR close < medium-term EMA OR close < long-term EMA OR short-term EMA < medium-term EMA OR RSI < midpoint and RSI > lower bearish threshold OR RSI > upper overbought threshold OR trend slope < 0 OR close < prior bar's recent low OR volume ratio exceeds a surge threshold AND close < open OR bearish engulfing OR shooting star OR double top OR bearish divergence OR breakdown