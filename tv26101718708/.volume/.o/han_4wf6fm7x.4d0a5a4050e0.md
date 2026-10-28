Calculation: Lowest low = lowest low over a lookback ending on the current bar
Calculation: Highest high = highest high over a lookback ending on the current bar
Calculation: Bullish pin bar = lower wick ≥ a long-body multiple, upper wick ≤ a small-body multiple, and candle range > half an ATR
Calculation: Bearish pin bar = upper wick ≥ a long-body multiple, lower wick ≤ a small-body multiple, and candle range > half an ATR
Calculation: Bullish engulfing = prior candle bearish, current candle bullish, current close > prior open, and current open < prior close
Calculation: Bearish engulfing = prior candle bullish, current candle bearish, current close < prior open, and current open > prior close
Calculation: Long stop = prior bar low − ATR-based offset
Calculation: Short stop = prior bar high + ATR-based offset
Calculation: Long target = entry price + reward multiple × (entry price − long stop)
Calculation: Short target = entry price − reward multiple × (short stop − entry price)
Long: close > SMA(close) AND low ≤ lowest low × proximity tolerance AND (bullish pin bar OR bullish engulfing) AND close > prior bar high AND volume ≥ short-term average volume × volume threshold AND bars since most recent entry > cooldown period
Short: close < SMA(close) AND high ≥ highest high × proximity tolerance AND (bearish pin bar OR bearish engulfing) AND close < prior bar low AND volume ≥ short-term average volume × volume threshold AND bars since most recent entry > cooldown period
Exit: long, low ≤ long stop OR high ≥ long target
Exit: short, high ≥ short stop OR low ≤ short target