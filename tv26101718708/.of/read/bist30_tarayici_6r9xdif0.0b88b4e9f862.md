Calculation: Morning star = the current bar closes above its open and above the midpoint of the bar two bars ago; that earlier bar closed below its open; the intervening bar’s body is less than half the earlier bar’s body
Calculation: Bullish engulfing = the current bar closes above its open, closes above the previous bar’s open, and opens at or below the previous bar’s close; the previous bar closed below its open
Calculation: Bullish harami = the current bar closes above its open and the previous bar closes below its open; the current bar’s high is below the previous bar’s high and its low is above the previous bar’s low
Calculation: Pin bar = the current bar has a nonzero range, a lower wick longer than twice its body, and an upper wick no longer than one quarter of its range
Calculation: Doji = the current bar has a nonzero range and a body no larger than one tenth of its range
Calculation: Stop = the lower of the current bar’s low and the 13-bar SMA, minus half the ATR
Calculation: First target = the pivot from the previous completed higher-timeframe bar plus 0.618 times that bar’s high-minus-low range; pivot = (high + low + close) / 3
Calculation: Risk/reward = (first target − close) / (close − stop)
Long: SMA(5) > SMA(8) AND SMA(8) > SMA(13) AND close > SMA(13) AND low <= SMA(8) + ATR × tolerance AND close >= SMA(13) − ATR × tolerance AND (Morning star OR Bullish engulfing OR Bullish harami OR Pin bar OR Doji) AND (close − stop) / close × 100 >= minimum risk percentage AND Risk/reward >= minimum risk/reward
Exit: long, NOT (SMA(5) > SMA(8) AND SMA(8) > SMA(13) AND close > SMA(13))