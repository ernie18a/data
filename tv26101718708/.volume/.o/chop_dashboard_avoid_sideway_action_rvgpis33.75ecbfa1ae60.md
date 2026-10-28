Calculation: Delta = volume × (close − open) ÷ max(high − low, minimum price increment)
Calculation: Flow EMA = EMA(Delta)
Calculation: Delta threshold = EMA(abs(Delta)) × multiplier
Calculation: High volume = volume > SMA(volume) × multiplier
Calculation: Trend up = close > EMA(close); trend down = close < EMA(close)
Calculation: Supertrend bull = previous bar's direction < 0; bear = previous bar's direction > 0
Calculation: Supertrend buy flip = previous bar's direction > 0 AND current direction < 0; sell flip = previous bar's direction < 0 AND current direction > 0
Calculation: CHOP = 100 × log10(SMA(ATR(1)) × lookback ÷ max(highest high − lowest low, minimum price increment)) ÷ log10(lookback); choppy = CHOP > threshold
Calculation: Impulse = abs(close − open) > EMA(abs(close − open)) × multiplier AND ATR(shorter lookback) > ATR(longer lookback) × multiplier
Calculation: Buy score = 1 for each true condition: Delta > Delta threshold; Flow EMA > 0; High volume AND Delta > 0; Trend up; Supertrend bull. Add 2 if Impulse AND close > open. Subtract 1 if choppy.
Calculation: Sell score = 1 for each true condition: Delta < −Delta threshold; Flow EMA < 0; High volume AND Delta < 0; Trend down; Supertrend bear. Add 2 if Impulse AND close < open. Subtract 1 if choppy.
Long: buy score ≥ 6 AND buy score > sell score OR buy score ≥ 3 AND NOT (buy score ≥ 6 AND buy score > sell score) OR Supertrend buy flip
Short: sell score ≥ 6 AND sell score > buy score OR sell score ≥ 3 AND NOT (sell score ≥ 6 AND sell score > buy score) OR Supertrend sell flip