Calculation: 20-period moving average = simple or exponential moving average of close, as configured
Calculation: 150-period SMA = simple moving average of close
Calculation: MACD line = short-period EMA of close minus long-period EMA of close; signal line = EMA of MACD line; histogram = MACD line minus signal line
Calculation: Volume average = simple moving average of volume
Calculation: Prior breakout high = highest high over the configured breakout lookback, excluding the current bar
Calculation: Prior annual high = highest high over the previous annual-length bar window, excluding the current bar
Calculation: Bullish confirmation candle = close > open AND close > previous high AND volume >= volume average times the configured confirmation-volume threshold
Calculation: Bullish engulfing = close > open AND previous open > previous close AND close > previous open AND open < previous close
Calculation: Hammer = lower wick >= 2 times body AND upper wick <= 0.5 times body AND body / full range < 0.4
Calculation: Morning star = open two bars ago > close two bars ago AND previous body < 0.4 times the body two bars ago AND close > open AND close > midpoint of the open and close two bars ago
Calculation: Bullish marubozu = close > open AND each wick <= 0.05 times body AND body / full range >= 0.92
Calculation: Inside-bar breakout = high one bar ago < high two bars ago AND low one bar ago > low two bars ago AND close > high one bar ago AND close > open
Calculation: Bearish engulfing = open > close AND previous close > previous open AND open > previous close AND close < previous open
Calculation: Shooting star = upper wick >= 2 times body AND lower wick <= 0.5 times body AND body / full range < 0.4
Calculation: Evening star = close two bars ago > open two bars ago AND previous body < 0.4 times the body two bars ago AND open > close AND close < midpoint of the open and close two bars ago
Calculation: Bearish marubozu = open > close AND each wick <= 0.05 times body AND body / full range >= 0.92
Long: low touches or falls within the configured tolerance above the 150-period SMA AND close > 150-period SMA AND bullish confirmation candle OR low falls below the 20-period moving average by at least the configured dip threshold AND close > 20-period moving average AND bullish confirmation candle AND (previous close < previous 20-period moving average OR previous low < previous 20-period moving average OR current low falls below the 20-period moving average by at least the configured dip threshold) AND 150-period SMA > its value 10 bars ago AND 20-period moving average > its value 3 bars ago OR close > prior breakout high AND close > open AND volume >= volume average times the configured breakout-volume threshold AND close >= configured proximity fraction of prior annual high OR bullish engulfing OR hammer OR morning star OR bullish marubozu OR inside-bar breakout
Short: bearish engulfing OR shooting star OR evening star OR bearish marubozu