Calculation: OBV state = initially neutral; set bullish when PercentRank(abs(OBV - selected moving average(OBV, moving-average lookback)), strength lookback), treating unavailable ranks as zero, meets the strength threshold and OBV is above that average; set bearish when it meets the same threshold and OBV is below that average; otherwise retain the prior state; accept a change only after the minimum spacing since the prior accepted change.
Calculation: entry window = starts or resets on each accepted OBV-state change, remains active while bars since that change are less than or equal to the confirmation-wait parameter, and clears upon entry or after that limit.
Calculation: regression slope t-statistic = Correlation(close, bar sequence, regression lookback) * sqrt((regression lookback - 2) / max(denominator-floor parameter, 1 - Correlation(close, bar sequence, regression lookback)^2)); use zero when correlation is unavailable.
Calculation: trailing stop = on a long entry bar, min(entry-bar high - ATR multiple * ATR(ATR lookback), entry-bar low - minimum price increment); on each later long bar, max(previous stop, highest high since entry - ATR multiple * current ATR(ATR lookback)); on a short entry bar, max(entry-bar low + ATR multiple * ATR(ATR lookback), entry-bar high + minimum price increment); on each later short bar, min(previous stop, lowest low since entry + ATR multiple * current ATR(ATR lookback)).
Long: OBV state is bullish.
Short: OBV state is bearish.
Long: OBV state is bullish AND regression slope t-statistic >= trend threshold.
Short: OBV state is bearish AND regression slope t-statistic <= -trend threshold.
Long: entry window is active AND position is flat AND OBV state is bullish AND regression slope t-statistic >= trend threshold.
Short: entry window is active AND position is flat AND OBV state is bearish AND regression slope t-statistic <= -trend threshold.
Exit: long, (bars since entry > 0 AND low <= prior-bar trailing stop) OR (flip-reversal option is enabled AND OBV state changes to bearish).
Exit: short, (bars since entry > 0 AND high >= prior-bar trailing stop) OR (flip-reversal option is enabled AND OBV state changes to bullish).