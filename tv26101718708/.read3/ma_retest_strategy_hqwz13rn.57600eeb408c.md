Calculation: Spread = ABS(EMA(source, fast length) - EMA(source, slow length))
Calculation: Chop filter passed = Spread >= min spread multiple * ATR(ATR length) AND Spread >= percentile nearest rank(Spread, percentile lookback, percentile threshold)
Calculation: Long confirm = EMA(source, fast length) > EMA(source, slow length) AND close crosses above EMA(source, fast length) AND low[n] <= EMA(source, fast length)[n] for some n from 0 to pierce window - 1 AND Chop filter passed AND bar index > slow length + swing lookback AND Short confirm[n] is false for every n from 1 to cooldown bars
Calculation: Short confirm = EMA(source, fast length) < EMA(source, slow length) AND close crosses below EMA(source, fast length) AND high[n] >= EMA(source, fast length)[n] for some n from 0 to pierce window - 1 AND Chop filter passed AND bar index > slow length + swing lookback AND Long confirm[n] is false for every n from 1 to cooldown bars
Calculation: Long stop = MAX(entry price * (1 - max risk % / 100), stop method level), where stop method level by stop method is ATR: entry price - ATR(ATR length) * ATR stop multiple; percent: entry price * (1 - stop % / 100); swing: MAX(LOWEST(low, swing lookback), entry price - ATR(ATR length) * swing cap multiple); ATR and LOWEST are evaluated at entry bar
Calculation: Short stop = MIN(entry price * (1 + max risk % / 100), stop method level), where stop method level by stop method is ATR: entry price + ATR(ATR length) * ATR stop multiple; percent: entry price * (1 + stop % / 100); swing: MIN(HIGHEST(high, swing lookback), entry price + ATR(ATR length) * swing cap multiple); ATR and HIGHEST are evaluated at entry bar
Long: Long confirm AND position side is not long AND Long stop < close
Short: Short confirm AND position side is not short AND Short stop > close
Exit: long, low <= Long stop OR high >= entry price + (entry price - Long stop) * R-multiple OR bars since entry > timeout bars
Exit: short, high >= Short stop OR low <= entry price - (Short stop - entry price) * R-multiple OR bars since entry > timeout bars
Exit: long, Short confirm
Exit: short, Long confirm