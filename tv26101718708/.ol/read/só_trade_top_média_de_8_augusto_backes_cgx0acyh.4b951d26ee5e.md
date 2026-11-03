Calculation: Moving average = configured SMA or EMA of closes on a higher timeframe, using only its last completed bars
Calculation: Bullish engulfing = current close > current open AND previous close < previous open AND current close >= previous open AND current open <= previous close
Calculation: Bullish hammer = 2 × abs(close − open) < min(close, open) − low AND high − max(close, open) < abs(close − open) AND close > open
Calculation: Bullish closing reversal = low < previous low AND low < low two bars ago AND close > previous close AND close > open
Calculation: Bearish engulfing = current close < current open AND previous close > previous open AND current close <= previous open AND current open >= previous close
Calculation: Bearish hammer = 2 × abs(close − open) < high − max(close, open) AND min(close, open) − low < abs(close − open) AND close < open
Calculation: Bearish closing reversal = high > previous high AND high > high two bars ago AND close < previous close AND close < open
Long: (bullish engulfing OR bullish hammer OR bullish closing reversal) AND close > moving average AND (rare-signal filter disabled OR open > moving average)
Exit: Long, (bearish engulfing OR bearish hammer OR bearish closing reversal) AND close < moving average AND (rare-signal filter disabled OR open < moving average)