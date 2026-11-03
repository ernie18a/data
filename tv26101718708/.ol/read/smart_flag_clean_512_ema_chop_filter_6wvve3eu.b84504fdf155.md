Calculation: Fast EMA = exponential moving average of close with a shorter lookback than Slow EMA
Calculation: Slow EMA = exponential moving average of close with a longer lookback than Fast EMA
Calculation: Trend SMA = simple moving average of close
Calculation: ATR = average true range
Calculation: Volume average = simple moving average of volume
Calculation: VWAP = volume-weighted average price
Calculation: EMA slope % = (current EMA − prior EMA) / prior EMA × 100
Calculation: Trend SMA slope % = (current Trend SMA − prior Trend SMA) / prior Trend SMA × 100
Calculation: Recent low = lowest low over the swing lookback
Calculation: Recent high = highest high over the swing lookback
Calculation: Room below ATR = (close − Recent low) / ATR
Calculation: Room above ATR = (Recent high − close) / ATR
Calculation: Body fraction = absolute(close − open) / (high − low)
Calculation: Bear rejection = close < open AND Body fraction ≥ 0.45 AND close ≤ low + 0.35 × (high − low)
Calculation: Bull rejection = close > open AND Body fraction ≥ 0.45 AND close ≥ high − 0.35 × (high − low)
Calculation: Bear aligned = Fast EMA < Slow EMA AND both EMA slope percentages are below the negative flat-slope threshold
Calculation: Bull aligned = Fast EMA > Slow EMA AND both EMA slope percentages are above the flat-slope threshold
Calculation: EMA flat = both absolute EMA slope percentages are at most the flat-slope threshold
Calculation: EMA tight = absolute(Fast EMA − Slow EMA) ≤ 0.10 × ATR
Calculation: Chop zone = EMA flat OR EMA tight
Calculation: Lower-high context = high < prior high AND prior high ≤ high two bars ago
Calculation: Higher-low context = low > prior low AND prior low ≥ low two bars ago
Calculation: Failed pop = high < Recent high AND close < open AND close < Fast EMA
Calculation: Lost fast EMA = close < Fast EMA AND close < Slow EMA
Calculation: Middle of range = close is above Recent low + 0.35 × (Recent high − Recent low) AND below Recent low + 0.65 × (Recent high − Recent low)
Calculation: Mean chop bar = absolute(close − Trend SMA) / ATR ≤ maximum distance threshold AND absolute Trend SMA slope % ≤ maximum slope threshold AND (candle-overlap requirement is disabled OR low ≤ Trend SMA ≤ high)
Calculation: Mean chop = chop filter enabled AND every bar in the mean-chop lookback has Mean chop bar true
Calculation: Volume okay = volume ≥ Volume average
Calculation: Volume strong = volume ≥ 1.20 × Volume average
Calculation: Short VWAP okay = VWAP filter disabled OR close < VWAP
Calculation: Long VWAP okay = VWAP filter disabled OR close > VWAP
Calculation: Trend short score = +1 Bear stack, +2 Bear aligned, +1 close < Trend SMA, +1 Trend SMA slope % ≤ 0, +1 Lower-high context, +1 Bear rejection, +1 Volume okay, +1 Volume strong, +1 Room below ATR ≥ minimum-room threshold, +1 Room below ATR ≥ strong-room threshold, +1 Short VWAP okay; subtract 2 Chop zone, 2 if Room below ATR < minimum-room threshold, and 3 Mean chop
Calculation: Reversal short score = +1 Bear stack, +1 Fast EMA slope % below negative flat-slope threshold, +1 Slow EMA slope % below negative flat-slope threshold, +1 Lower-high context, +1 Bear rejection, +1 Failed pop, +1 Lost fast EMA, +1 Volume okay, +1 Volume strong, +1 Room below ATR ≥ minimum-room threshold, +1 Room below ATR ≥ strong-room threshold, +1 Short VWAP okay; subtract 1 Chop zone, 1 Middle of range, 2 if Room below ATR < minimum-room threshold, and 3 Mean chop
Calculation: Long score = +1 Bull stack, +2 Bull aligned, +1 close > Trend SMA, +1 Trend SMA slope % ≥ 0, +1 Higher-low context, +1 Bull rejection, +1 Volume okay, +1 Volume strong, +1 Room above ATR ≥ minimum-room threshold, +1 Room above ATR ≥ strong-room threshold, +1 Long VWAP okay; subtract 2 Chop zone, 2 if Room above ATR < minimum-room threshold, and 3 Mean chop
Short: Fast EMA crosses below Slow EMA AND NOT Mean chop AND ((Trend short score ≥ 6 AND Bear aligned AND close < Trend SMA AND Room below ATR ≥ strong-room threshold AND NOT Chop zone AND Short VWAP okay) OR (Reversal short score ≥ 5 AND Bear stack AND Room below ATR ≥ minimum-room threshold AND NOT EMA flat AND Short VWAP okay))
Short: Fast EMA crosses below Slow EMA AND NOT Mean chop AND neither A short condition is true AND (Trend short score ≥ 4 OR Reversal short score ≥ 4)
Long: Fast EMA crosses above Slow EMA AND NOT Mean chop AND Long score ≥ 6 AND Bull aligned AND close > Trend SMA AND Room above ATR ≥ strong-room threshold AND NOT Chop zone AND Long VWAP okay
Long: Fast EMA crosses above Slow EMA AND NOT Mean chop AND A long condition is false AND Long score ≥ 4