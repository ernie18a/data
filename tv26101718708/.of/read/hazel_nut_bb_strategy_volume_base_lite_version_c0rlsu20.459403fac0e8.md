Calculation: Bollinger bands = selected SMA, EMA, or VWMA of close as basis, plus and minus a multiplier times the standard deviation of close over the same lookback; average volume uses the same lookback.
Calculation: Volume flow = either (1) buy volume = volume × (close − low) / (high − low) and sell volume = volume × (high − close) / (high − low), with each equal to half of volume when high = low; or (2) sum lower-timeframe up and down volumes within the chart bar, classifying each lower-timeframe bar by close versus open, then by close versus the previous close when equal, and otherwise retaining the previous classification. Use completed lower-timeframe bars and include the lower-timeframe bar still forming when evaluating a forming chart bar. Total volume = buy volume + sell volume; delta = buy volume − sell volume.
Calculation: Volume pressure = change in the EMA of cumulative delta divided by ATR; use zero when ATR is unavailable or zero.
Calculation: Normalized bandwidth = (current Bollinger bandwidth − lowest bandwidth) / (highest bandwidth − lowest bandwidth) over a lookback, where bandwidth = (upper band − lower band) / basis; use zero when the highest and lowest bandwidth are equal.
Calculation: Band position = (close − lower band) / (upper band − lower band); use one-half when band width is not positive.
Calculation: Valid history = count of chart bars with valid volume flow; the required history is the greater of the Bollinger lookback and bandwidth lookback.
Calculation: Reversal effort = absolute value of close − open divided by high − low.
Calculation: Initial stop = signal-bar close minus an ATR multiple for a long, or plus that multiple for a short; reset it on each entry signal.
Calculation: Breakout trailing stop = initially the initial stop, then the maximum of its previous value and close minus a trailing ATR multiple for a long, or the minimum of its previous value and close plus that multiple for a short; reset it on each breakout entry signal.
Long: Valid history > required history AND close > previous upper band AND total volume > average total volume × breakout volume multiplier AND normalized bandwidth <= squeeze threshold on the current bar or any bar in a recent lookback AND delta > 0 AND volume pressure > positive breakout pressure threshold.
Short: Valid history > required history AND close < previous lower band AND total volume > average total volume × breakout volume multiplier AND normalized bandwidth <= squeeze threshold on the current bar or any bar in the same recent lookback AND delta < 0 AND volume pressure < negative breakout pressure threshold.
Long: Valid history > required history AND band position < lower reversal threshold AND total volume > average total volume × reversal volume multiplier AND ((high > low AND reversal effort < effort threshold) OR delta > 0) AND volume pressure > negative reversal pressure threshold.
Short: Valid history > required history AND band position > upper reversal threshold AND total volume > average total volume × reversal volume multiplier AND ((high > low AND reversal effort < effort threshold) OR delta < 0) AND volume pressure < positive reversal pressure threshold.
Long: Band position > upper band boundary AND volume pressure > high positive dashboard pressure threshold.
Short: Band position > upper band boundary AND volume pressure < negative dashboard pressure threshold.
Long: Band position > upper band boundary AND volume pressure >= negative dashboard pressure threshold AND volume pressure <= high positive dashboard pressure threshold.
Long: Band position >= upper proximity threshold AND band position <= upper band boundary AND volume pressure > positive dashboard pressure threshold.
Short: Band position >= upper proximity threshold AND band position <= upper band boundary AND volume pressure < negative dashboard pressure threshold.
Long: Band position > lower proximity threshold AND band position < upper proximity threshold AND volume pressure > high positive dashboard pressure threshold.
Short: Band position > lower proximity threshold AND band position < upper proximity threshold AND volume pressure < high negative dashboard pressure threshold.
Long: Band position > lower band boundary AND band position <= lower proximity threshold AND volume pressure > positive dashboard pressure threshold.
Short: Band position > lower band boundary AND band position <= lower proximity threshold AND volume pressure < negative dashboard pressure threshold.
Short: Band position <= lower band boundary AND volume pressure < high negative dashboard pressure threshold.
Long: Band position <= lower band boundary AND volume pressure > positive dashboard pressure threshold.
Short: Band position <= lower band boundary AND volume pressure >= high negative dashboard pressure threshold AND volume pressure <= positive dashboard pressure threshold.
Exit: long, breakout entry type AND low <= breakout trailing stop.
Exit: short, breakout entry type AND high >= breakout trailing stop.
Exit: long, reversal entry type AND (low <= initial stop OR (selected current basis or upper band > latest entry price AND high >= selected current basis or upper band)).
Exit: short, reversal entry type AND (high >= initial stop OR (selected current basis or lower band < latest entry price AND low <= selected current basis or lower band)).