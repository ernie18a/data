Calculation: Today open = open of the current higher-timeframe daily bar, including while it is forming
Calculation: Yesterday high/low = high/low of the last completed higher-timeframe daily bar
Calculation: This week high/low = highest high/lowest low so far in the current, still-forming higher-timeframe weekly bar
Calculation: Last week high = high of the last completed higher-timeframe weekly bar
Calculation: Pre-market high/low = highest high/lowest low of lower-timeframe chart bars from 04:00 to 09:29, locked at the regular-session open
Calculation: Session VWAP = cumulative (high + low + close) / 3 weighted by volume, reset each day, using chart-timeframe bars
Calculation: Up/down volume ratio = sum of chart-timeframe volume on bars closing above the previous close divided by sum on bars closing below it, over one lookback
Calculation: Relative volume = current chart-timeframe relative volume; in intraday at-time mode, compare cumulative session volume with its historical average at the same time of day, with realtime adjustment enabled
Calculation: Bullish engulfing = a bullish daily candle whose body engulfs the prior bearish daily candle's body, is at least 1.10 times its body size, and meets the source's body-to-range filters
Calculation: Dragonfly doji = daily candle body <= 5% of range, lower wick >= 65% of range, and upper wick <= 5% of range
Calculation: Morning star = three daily candles: a substantial bearish first candle, a middle body <= 25% of the first body, then a bullish third candle closing at or above 55% of the first body's way up from its bottom, with the source's body-to-range filter
Calculation: Piercing line = substantial bearish daily candle followed by a bullish candle opening below its low and closing at or above the prior body's midpoint but below its open, with the source's body-to-range filters
Calculation: Hammer = daily candle body <= 28% of range, lower wick >= 2 times body, upper wick <= 8% of range, body in the upper 45% of range, following a bearish daily candle
Calculation: Bullish harami = substantial bearish daily candle followed by a bullish candle whose body is inside the prior body and <= 60% of its size
Calculation: Three white soldiers = three consecutive bullish daily candles with rising closes, prescribed overlapping opens, and each candle body >= 55% of its range with close in the top 20%
Long: close >= Today open AND close >= Session VWAP
Long: close >= Today open AND close >= Session VWAP AND Relative volume >= configured bullish minimum AND Up/down volume ratio >= configured bullish minimum
Long: any of Bullish engulfing, Dragonfly doji, Morning star, Piercing line, Hammer, Bullish harami, or Three white soldiers is true on the completed higher-timeframe daily bar
Long: close crosses above any of Today open, Yesterday high, Yesterday low, Pre-market high, Pre-market low, Session VWAP, This week high, This week low, or Last week high
Short: close < Today open AND close < Session VWAP
Short: close < Today open AND close < Session VWAP AND Relative volume >= configured bearish minimum AND Up/down volume ratio <= configured bearish maximum
Short: close crosses below any of Today open, Yesterday high, Yesterday low, Pre-market high, Pre-market low, Session VWAP, This week high, This week low, or Last week high