Calculation: Slope = (EMA(close, longer EMA length) - EMA(close, longer EMA length)[slope length]) / EMA(close, longer EMA length)[slope length]
Calculation: Volume ratio = volume / SMA(volume, volume length)
Calculation: Cross average = average of open[k] over k = 1 to target lookback where EMA(close, shorter EMA length)[k] crosses above EMA(close, longer EMA length)[k]
Calculation: Cross range = max(high[k] over k = 1 to target lookback where EMA(close, shorter EMA length)[k] > EMA(close, longer EMA length)[k]) - Cross average, undefined unless positive
Calculation: Near target = VPoC(VPoC lookback, VPoC levels) if VPoC > Cross average * (1 + VPoC premium), otherwise Cross average + near target fraction * Cross range
Calculation: Far target = Cross average + VPoC far multiple * (VPoC - Cross average) if VPoC > Cross average * (1 + VPoC premium), otherwise Cross average + Cross range
Calculation: Near target reached = at some bar since entry before the current bar, high >= highest Near target over entry through the bar before that bar
Calculation: T1 uptrend = EMA(close, shorter EMA length, T1, last completed bar) > EMA(close, longer EMA length, T1, last completed bar) AND EMA(close, longer EMA length, T1, last completed bar) >= EMA(close, longer EMA length, T1, last completed bar)[slope length]
Calculation: Near target recovery setup = EMA(close, shorter EMA length) > EMA(close, longer EMA length) AND close >= Near target * near zone lower factor AND close <= Near target * near zone upper factor AND Slope > 0 AND Slope > Slope[1] AND Slope[1] <= recovery slope ceiling AND Volume ratio >= low volume threshold AND Volume ratio >= Volume ratio[1] AND (Slope >= slope strength threshold OR Volume ratio >= volume strength threshold)
Long: EMA(close, shorter EMA length) crosses above EMA(close, longer EMA length) AND no position AND Near target is defined
Long: 0 < (EMA(close, longer EMA length) - EMA(close, shorter EMA length)) / EMA(close, longer EMA length) <= anticipate threshold AND EMA(close, shorter EMA length) > EMA(close, shorter EMA length)[1] AND no position AND Near target is defined
Long: EMA(close, shorter EMA length) crosses above EMA(close, longer EMA length) AND long position
Long: Near target recovery setup AND NOT Near target recovery setup[1]
Long: Bullish Engulfing OR Morning Star OR Piercing Line OR Hammer OR Bullish Harami
Short: EMA(close, shorter EMA length) crosses below EMA(close, longer EMA length) AND no position
Short: (Bearish Engulfing OR Evening Star OR Dark Cloud Cover OR Shooting Star OR Bearish Harami) AND no position
Exit: long, high >= highest Far target from entry through the previous bar
Exit: long, low <= entry price * (1 - stop percent) OR (low <= entry price AND Near target reached)
Exit: long, EMA(close, shorter EMA length) crosses below EMA(close, longer EMA length) AND NOT T1 uptrend
Exit: long, Slope < 0 AND Slope[1] < 0 AND Volume ratio < low volume threshold AND Volume ratio[1] < low volume threshold AND NOT T1 uptrend
Exit: long, (Bearish Engulfing OR Evening Star OR Dark Cloud Cover) AND NOT T1 uptrend