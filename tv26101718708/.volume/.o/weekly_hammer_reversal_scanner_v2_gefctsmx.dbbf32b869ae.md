Calculation: body = absolute difference between the current weekly open and close
Calculation: candle range = current weekly high minus low
Calculation: safe body = maximum of body and minimum tick size
Calculation: lower wick = minimum of current weekly open and close minus current weekly low
Calculation: upper wick = current weekly high minus maximum of current weekly open and close
Calculation: close position = (current weekly close − low) / candle range when range > 0, otherwise 0
Calculation: hammer = lower wick ≥ safe body × lower-wick ratio AND upper wick ≤ safe body × upper-wick ratio AND candle range > 0 AND body / candle range ≤ maximum body fraction AND close position ≥ minimum close position
Calculation: downtrend = previous completed weekly close < close from the configured number of completed weekly bars ago
Calculation: near support = absolute distance from current weekly low to the 20-week SMA of close, as a percentage of that SMA, ≤ MA tolerance OR the same distance to the 50-week SMA of close ≤ MA tolerance
Calculation: volume pass = current weekly volume ≥ its weekly volume SMA × volume multiplier
Calculation: RSI pass = current weekly RSI ≤ maximum RSI
Calculation: weekly hammer setup = hammer AND (downtrend filter disabled OR downtrend) AND (MA filter disabled OR near support) AND (volume filter disabled OR volume pass) AND (RSI filter disabled OR RSI pass)
Calculation: setup score = 3 if hammer else 0, plus 1 if downtrend else 0, plus 2 if near support else 0, plus 1 if current weekly volume > its weekly volume SMA else 0, plus 1 if current weekly RSI < 50 else 0, plus 2 if close position ≥ 0.75 else 0
Long: weekly hammer setup
Long: weekly hammer setup AND setup score ≥ high-quality score threshold