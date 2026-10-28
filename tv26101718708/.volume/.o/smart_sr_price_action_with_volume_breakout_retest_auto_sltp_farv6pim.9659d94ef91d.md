Calculation: Confirmed pivot high = a bar whose high is greater than the highs of the preceding and following pivot-length bars; resistance = the most recent confirmed pivot high
Calculation: Confirmed pivot low = a bar whose low is lower than the lows of the preceding and following pivot-length bars; support = the most recent confirmed pivot low
Calculation: Resistance zone = resistance × (1 ± zone-buffer percentage); support zone = support × (1 ± zone-buffer percentage)
Calculation: Candle body = absolute value of close − open; upper wick = high − max(close, open); lower wick = min(close, open) − low
Calculation: Average volume = simple moving average of volume over the volume lookback
Long: close is within the support zone AND lower wick > candle body × wick-ratio parameter AND close > open AND volume > average volume × volume-multiplier parameter
Short: close is within the resistance zone AND upper wick > candle body × wick-ratio parameter AND close < open AND volume > average volume × volume-multiplier parameter