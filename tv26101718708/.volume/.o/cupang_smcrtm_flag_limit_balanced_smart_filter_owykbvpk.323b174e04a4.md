Calculation: bullish setup quality score = weighted points for the bullish base-and-breakout pattern, breakout body dominance, breakout range expansion versus the base range, and alignment with the longer-term EMA trend
Calculation: bearish setup quality score = weighted points for the bearish base-and-breakout pattern, breakout body dominance, breakout range expansion versus the base range, and alignment with the longer-term EMA trend
Calculation: long stop level = base candle low minus an ATR buffer
Calculation: short stop level = base candle high plus an ATR buffer
Calculation: long target level = long entry price plus the larger of (long entry price minus long stop level) and an ATR-based minimum risk, multiplied by the risk/reward ratio
Calculation: short target level = short entry price minus the larger of (short stop level minus short entry price) and an ATR-based minimum risk, multiplied by the risk/reward ratio
Long: base candle range <= an ATR multiple AND breakout candle closes above the base candle high AND breakout candle closes above its open AND breakout body / breakout range >= a minimum ratio AND bullish setup quality score >= a minimum score AND price reaches the base candle high
Short: base candle range <= an ATR multiple AND breakout candle closes below the base candle low AND breakout candle closes below its open AND breakout body / breakout range >= a minimum ratio AND bearish setup quality score >= a minimum score AND price reaches the base candle low
Exit: long, close < long stop level OR high >= long target level
Exit: short, close > short stop level OR low <= short target level