Calculation: Medium-cycle upper and lower bands = the delayed RMA of close over the medium lookback, plus or minus the medium multiplier times ATR over half that lookback; delay the RMA by one quarter of the medium lookback.
Calculation: Long entry line = medium-cycle upper band + entry offset.
Calculation: Short entry line = medium-cycle lower band − entry offset.
Calculation: Supertrend 1 and Supertrend 2 = Supertrend values using separate ATR lookbacks and factors; Supertrend 2 uses a longer ATR lookback and larger factor than Supertrend 1.
Calculation: Long stop line = Supertrend 1 − Renko box size × stop bricks.
Calculation: Short stop line = Supertrend 1 + Renko box size × stop bricks.
Calculation: Long trailing stop = highest high since long entry − hard stop distance.
Calculation: Short trailing stop = lowest low since short entry + hard stop distance.
Long: (previous close ≤ previous long entry line AND close > long entry line AND position is flat or short) OR (Supertrend 1 is bullish AND Supertrend 2 is bullish).
Short: (previous close ≥ previous short entry line AND close < short entry line AND position is flat or long) OR (Supertrend 1 is bearish AND Supertrend 2 is bearish).
Exit: long, (previous close ≥ previous long stop line AND close < long stop line) OR (hard stop is enabled AND low ≤ long trailing stop).
Exit: short, (previous close ≤ previous short stop line AND close > short stop line) OR (hard stop is enabled AND high ≥ short trailing stop).