Calculation: Trend state = on chart bars, for EMA crossover method set bullish when EMA(close, fast lookback) > EMA(close, slow lookback), bearish when EMA(close, fast lookback) < EMA(close, slow lookback); for slow EMA slope method set bullish when EMA(close, slow lookback) > EMA(close, slow lookback)[slope lookback], bearish when it is lower; otherwise retain the prior state; fast lookback is shorter than slow lookback; initial state is neutral
Calculation: Resistance = (most recent confirmed pivot high of CCI(hlc3, CCI lookback), using separate left and right pivot lookbacks, minus pivot buffer) × CCI scale parameter × mean deviation(hlc3, CCI lookback) + SMA(hlc3, CCI lookback)
Calculation: Support = (most recent confirmed pivot low of CCI(hlc3, CCI lookback), using separate left and right pivot lookbacks, plus pivot buffer) × CCI scale parameter × mean deviation(hlc3, CCI lookback) + SMA(hlc3, CCI lookback)
Calculation: Running ATR maximum = ATR(ATR lookback) if the T1 close sampled on chart bars differs from its previous chart-bar value, otherwise max(ATR(ATR lookback), prior running ATR maximum); initialize at zero
Calculation: Stored ATR maximum = prior chart-bar running ATR maximum if the T1 close sampled on chart bars differs from its previous chart-bar value, otherwise prior stored ATR maximum; initialize at zero
Calculation: ATR base = max(ATR(ATR lookback), stored ATR maximum); ATR is calculated on chart bars, and the T1 close is sampled on chart bars from the still-forming T1 bar in real time and the last completed T1 bar historically
Calculation: Stop distance = ATR base × stop multiplier, evaluated on the entry-signal bar
Calculation: Target distance = ATR base × target multiplier, evaluated on the entry-signal bar
Calculation: Long stop = entry-signal bar close − stop distance; hold while long
Calculation: Long target = entry-signal bar close + target distance; hold while long
Calculation: Short stop = entry-signal bar close + stop distance; hold while short
Calculation: Short target = entry-signal bar close − target distance; hold while short
Long: trend filter disabled OR trend state bullish; lowest(low, entry lookback) < Support; close > open; close > Support
Short: trend filter disabled OR trend state bearish; highest(high, entry lookback) > Resistance; close < open; close < Resistance
Exit: long, low ≤ Long stop OR high ≥ Long target
Exit: short, high ≥ Short stop OR low ≤ Short target