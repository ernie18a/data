Calculation: ConsHigh = highest high of the prior N bars, excluding the current bar; ConsLow = lowest low of the same prior N bars
Calculation: Consolidating = (ConsHigh - ConsLow) / previous close < range threshold
Calculation: AvgVol = simple moving average of volume
Calculation: ObvStrong = OBV > simple moving average of OBV (lookback equals N)
Calculation: Watch bar = close > ConsHigh AND volume > AvgVol * spike multiplier AND ((Consolidating on the previous bar AND ObvStrong) OR close > open * (1 + big-move threshold))
Long: an earlier Watch bar is still active AND the current bar is not itself a Watch bar AND current high > high of that Watch bar. Enter at the Watch bar high. The Watch stays active until it triggers an entry, is replaced by a newer Watch bar, or any later bar has close < that bar's ConsLow (the cancelling bar cannot enter). Evaluate the cancel check before the entry check on each bar.
Exit: long, close crosses below a trend line (simple moving average of close, or alternatively a shorter-length exponential moving average of close)
Exit: long, close < open AND volume > AvgVol * dump multiplier (dump multiplier > spike multiplier)
Exit: long, bearish engulfing: close < open AND previous close > previous open AND close < previous low AND open > previous high
Exit: long (optional stop), price falls to or below the ConsLow recorded on the Watch bar that led to the entry