Calculation: Kaufman’s Efficiency Ratio = 100 × (current close − close N bars ago) / sum of absolute close-to-close changes over the last N bars
Calculation: Long trailing stop = highest value since long entry of (bar low − ATR buffer)
Calculation: Short trailing stop = lowest value since short entry of (bar high + ATR buffer)
Calculation: Initial risk = ATR buffer on the long entry bar
Long: Kaufman’s Efficiency Ratio > 0
Short: Kaufman’s Efficiency Ratio < 0 AND true range > 14-bar ATR AND volume > 5-bar volume SMA
Exit: long, bar low <= long trailing stop
Exit: short, bar high >= short trailing stop
Exit: long, Kaufman’s Efficiency Ratio <= 0 AND (close >= entry price + first profit multiple × initial risk OR close >= entry price + second profit multiple × initial risk OR close >= entry price + third profit multiple × initial risk), with targets checked in order and each checked only after the prior target
Exit: short, short entry condition is false AND (close <= entry price − first profit multiple × initial risk OR close <= entry price − second profit multiple × initial risk OR close <= entry price − third profit multiple × initial risk), with targets checked in order and each checked only after the prior target