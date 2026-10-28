Calculation: Morning star = current bar is bullish; two bars earlier is bearish; the prior bar's body is less than half the two-bars-earlier body; current close is above the midpoint of the two-bars-earlier body
Calculation: Bullish engulfing = current bar is bullish, prior bar is bearish, current close is above prior open, and current open is at or below prior close
Calculation: Bullish harami = current bar is bullish and its high and low are inside the prior bar's range; prior bar is bearish
Calculation: Bullish pin bar = lower wick is more than twice the body and upper wick is at most one quarter of the range
Calculation: Doji = body is at most one tenth of the range
Calculation: Stop = min(current low, slow SMA) − half the current ATR
Calculation: First HTF target = prior completed target-timeframe pivot + 0.618 × prior completed target-timeframe range; pivot = (high + low + close) / 3 and range = high − low
Long: fast SMA > medium SMA > slow SMA AND close > slow SMA AND low ≤ medium SMA + ATR × configured pullback tolerance AND close ≥ slow SMA − ATR × configured pullback tolerance AND (any enabled bullish pattern is true) AND (volume filter disabled OR volume > its shorter-lookback SMA) AND (R/R filter disabled OR (close − Stop) / close ≥ configured minimum risk percentage AND (First HTF target − close) / (close − Stop) ≥ configured minimum R/R)
Exit: long, fast SMA ≤ medium SMA OR medium SMA ≤ slow SMA OR close ≤ slow SMA