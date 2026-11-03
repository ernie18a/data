Calculation: Confirmed pivot high = a high greater than the highs of the configured number of bars before and after it; track the latest three unbroken confirmed pivot highs
Calculation: Confirmed pivot low = a low lower than the lows of the configured number of bars before and after it; track the latest three unbroken confirmed pivot lows
Calculation: Moving average = the configured SMA, EMA, WMA, VWMA, or HMA of close
Calculation: Long stop = configured ATR stop (current low minus smoothed true range times multiplier), candle stop (low a configured number of bars ago), or fixed distance below entry price
Calculation: Short stop = configured ATR stop (current high plus smoothed true range times multiplier), candle stop (high a configured number of bars ago), or fixed distance above entry price
Calculation: Long target = entry price + configured risk-reward multiple × (entry price − long stop)
Calculation: Short target = entry price − configured risk-reward multiple × (short stop − entry price)
Long: close > any tracked unbroken confirmed pivot high AND (moving-average filter disabled OR close > moving average) AND (time filter disabled OR bar close time is within the configured inclusive session) AND long stop < close AND position is flat
Short: close < any tracked unbroken confirmed pivot low AND (moving-average filter disabled OR close < moving average) AND (time filter disabled OR bar close time is within the configured inclusive session) AND short stop > close AND position is flat
Exit: long, low ≤ long stop OR high ≥ long target
Exit: short, high ≥ short stop OR low ≤ short target