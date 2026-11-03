Calculation: ATR = average true range over a configurable lookback
Calculation: Volume spike = current volume >= average volume over a configurable lookback × a configurable multiplier
Calculation: Bullish engulfing = candle body size >= ATR × a configurable multiplier AND close > open AND (close − low) / (high − low) >= a configurable threshold AND close > prior open AND open < prior close AND volume spike
Calculation: Bearish engulfing = candle body size >= ATR × a configurable multiplier AND close < open AND (close − low) / (high − low) <= a configurable threshold AND close < prior open AND open > prior close AND volume spike
Calculation: Low sweep = prior bar's low <= the highest low-lookback low AND current close > that highest low-lookback low
Calculation: High sweep = prior bar's high >= the highest high-lookback high AND current close < that highest high-lookback high
Calculation: Bullish fair value gap = current low > high two bars earlier AND the gap is at least a configurable fraction of close
Calculation: Bearish fair value gap = current high < low two bars earlier AND the gap is at least a configurable fraction of close
Calculation: Long score = capped sum of points for bullish higher-timeframe sweep bias, active session, volume spike, correlated-symbol low sweep, positive relative return versus the correlated symbol, unopposed bullish 1-hour fair value gap, bullish daily fair value gap, proximity to prior-day low, falling daily VIX, repeated low sweeps, bullish structure proximity, bullish engulfing at bullish structure (extra points), and bullish engulfing within a recent bullish fair value gap (extra points)
Calculation: Short score = capped sum of points for bearish higher-timeframe sweep bias, active session, volume spike, correlated-symbol high sweep, negative relative return versus the correlated symbol, unopposed bearish 1-hour fair value gap, bearish daily fair value gap, proximity to prior-day high, rising daily VIX, repeated high sweeps, bearish structure proximity, bearish engulfing at bearish structure (extra points), and bearish engulfing within a recent bearish fair value gap (extra points)
Long: Bullish engulfing
Long: Low sweep
Long: Bullish 1-hour fair value gap forms on a higher timeframe, using last completed bars
Long: Bullish daily fair value gap forms on a higher timeframe, using last completed bars
Long: Current close is within the most recent bullish fair value gap, formed within a configurable bar lookback, AND bullish engulfing
Long: Bullish engulfing AND close is within configurable ATR proximity of prior-day low, weekly open, daily open, midpoint of the most recent bullish 1-hour fair value gap, or midpoint of the most recent bullish daily fair value gap
Long: Close > the high of the prior configurable lookback AND open < that high AND candle body size >= ATR × a configurable multiplier AND volume spike AND an active consolidation range
Long: A low sweep has occurred AND close > the highest high of a configurable prior lookback, measured when the sweep occurred
Long: Low sweep AND long score >= configurable minimum score
Long: Low sweep AND long score > short score AND long score >= configurable threshold AND (long score >= configurable strong-score threshold OR long score >= configurable base-score threshold AND score difference >= configurable gap)
Long: High sweep AND long score > short score AND long score >= configurable threshold
Long: Long score >= configurable contrarian threshold AND short score <= configurable maximum
Long: Long score >= configurable maximum-confluence threshold
Short: Bearish engulfing
Short: High sweep
Short: Bearish 1-hour fair value gap forms on a higher timeframe, using last completed bars
Short: Bearish daily fair value gap forms on a higher timeframe, using last completed bars
Short: Current close is within the most recent bearish fair value gap, formed within a configurable bar lookback, AND bearish engulfing
Short: Bearish engulfing AND close is within configurable ATR proximity of prior-day high, weekly open, daily open, midpoint of the most recent bearish 1-hour fair value gap, or midpoint of the most recent bearish daily fair value gap
Short: Close < the low of the prior configurable lookback AND open > that low AND candle body size >= ATR × a configurable multiplier AND volume spike AND an active consolidation range
Short: A high sweep has occurred AND close < the low of a configurable prior lookback, measured when the sweep occurred
Short: High sweep AND short score >= configurable minimum score
Short: High sweep AND short score > long score AND short score >= configurable threshold AND (short score >= configurable strong-score threshold OR short score >= configurable base-score threshold AND score difference >= configurable gap)
Short: Low sweep AND short score > long score AND short score >= configurable threshold
Short: Short score >= configurable contrarian threshold AND long score <= configurable maximum
Short: Short score >= configurable maximum-confluence threshold
Exit: Long, close < the stop level set at the latest low sweep (prior lookback low − ATR × configurable multiplier)
Exit: Short, close > the stop level set at the latest high sweep (prior lookback high + ATR × configurable multiplier)