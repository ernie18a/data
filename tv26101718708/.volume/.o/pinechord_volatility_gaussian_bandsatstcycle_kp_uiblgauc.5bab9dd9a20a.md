Calculation: Medium-cycle center = RMA(close, medium lookback / 2), delayed by medium lookback / 4 bars
Calculation: Medium-cycle top/bottom = medium-cycle center ± medium-cycle multiplier × ATR(medium lookback / 2)
Calculation: Long entry line = medium-cycle top + entry offset
Calculation: Short entry line = medium-cycle bottom − entry offset
Calculation: Supertrend 1 = ATR-based Supertrend using its own lookback and multiplier
Calculation: Long stop = Supertrend 1 − Renko box size × stop bricks
Calculation: Short stop = Supertrend 1 + Renko box size × stop bricks
Long: Previous close ≤ previous long entry line AND current close > current long entry line AND position is flat or short
Short: Previous close ≥ previous short entry line AND current close < current short entry line AND position is flat or long
Exit: long, previous close ≥ previous long stop AND current close < current long stop
Exit: short, previous close ≤ previous short stop AND current close > current short stop