Calculation: Bullish ATR stop = rolling maximum of high − ATR multiplier × ATR(ATR lookback) over the stop lookback, raised to its prior value when the current trend is bullish; initially negative initialization magnitude.
Calculation: Bearish ATR stop = rolling minimum of low + ATR multiplier × ATR(ATR lookback) over the stop lookback, lowered to its prior value when the current trend is bearish; initially positive initialization magnitude.
Calculation: ATR stop trend = prior trend, set bullish if close > prior bearish ATR stop, then set bearish if close < prior bullish ATR stop; initially neutral.
Long: ATR stop trend is bullish on chart bars.
Short: ATR stop trend is bearish on chart bars.
Long: ATR stop trend calculated on T1 bars using the still-forming bar, sampled on chart bars, is bullish.
Short: ATR stop trend calculated on T1 bars using the still-forming bar, sampled on chart bars, is bearish.