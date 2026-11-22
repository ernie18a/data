Calculation: ProfitTargetPrice(position side) = (average entry price if take profit type is total volume, else entry price) x (1 + take profit) if position side is long, or x (1 - take profit) if position side is short
Calculation: TrailingPeak(position side) = if long, highest high from the first bar since entry with high >= ProfitTargetPrice(long) through the current bar; if short, lowest low from the first bar since entry with low <= ProfitTargetPrice(short) through the current bar; undefined if no such bar
Calculation: MaxSafetyDeviation(price deviation, safety step scale, max safety count) = sum over i from 1 to max safety count of price deviation x safety step scale^(i - 1)
Calculation: LongSafetyLevel(entry price, i, price deviation, safety step scale) = entry price x product over k from 1 to i of (1 - price deviation x safety step scale^(k - 1))
Calculation: ShortSafetyLevel(entry price, i, price deviation, safety step scale) = entry price x product over k from 1 to i of (1 + price deviation x safety step scale^(k - 1))
Long: position side is flat AND datetime >= start time AND datetime <= end time
Short: position side is flat AND datetime >= start time AND datetime <= end time
Long: position side is flat AND datetime >= start time AND datetime <= end time AND RSI(close, RSI length, T1, last completed bar) < RSI threshold
Short: position side is flat AND datetime >= start time AND datetime <= end time AND RSI(close, RSI length, T1, last completed bar) > RSI threshold
Long: position side is flat AND datetime >= start time AND datetime <= end time AND TechnicalRatings(high, low, close, volume, T1, last completed bar) > strong bound
Long: position side is flat AND datetime >= start time AND datetime <= end time AND TechnicalRatings(high, low, close, volume, T1, last completed bar) > weak bound
Short: position side is flat AND datetime >= start time AND datetime <= end time AND TechnicalRatings(high, low, close, volume, T1, last completed bar) < -strong bound
Short: position side is flat AND datetime >= start time AND datetime <= end time AND TechnicalRatings(high, low, close, volume, T1, last completed bar) < -weak bound
Long: position side is long AND low <= LongSafetyLevel(entry price, i, price deviation, safety step scale) AND lowest low since entry before this bar > LongSafetyLevel(entry price, i, price deviation, safety step scale) for some safety index i from 1 to max safety count
Short: position side is short AND high >= ShortSafetyLevel(entry price, i, price deviation, safety step scale) AND highest high since entry before this bar < ShortSafetyLevel(entry price, i, price deviation, safety step scale) for some safety index i from 1 to max safety count
Exit: long, trailing take profit = 0 AND high >= ProfitTargetPrice(long)
Exit: short, trailing take profit = 0 AND low <= ProfitTargetPrice(short)
Exit: long, trailing take profit > 0 AND low <= TrailingPeak(long) x (1 - trailing take profit)
Exit: short, trailing take profit > 0 AND high >= TrailingPeak(short) x (1 + trailing take profit)
Exit: long, low < entry price x (1 - stop loss) AND stop loss > MaxSafetyDeviation(price deviation, safety step scale, max safety count) AND (trailing take profit = 0 OR TrailingPeak(long) is undefined)
Exit: short, high > entry price x (1 + stop loss) AND stop loss > MaxSafetyDeviation(price deviation, safety step scale, max safety count) AND (trailing take profit = 0 OR TrailingPeak(short) is undefined)