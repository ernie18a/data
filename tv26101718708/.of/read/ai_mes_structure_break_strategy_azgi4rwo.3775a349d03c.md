Calculation: Confirmed pivot high/low = high/low of a chart bar that is respectively greater/less than the highs/lows of the same configurable number of bars on each side; confirm it only after the right-side bars have closed and retain the most recently confirmed value of each kind.
Calculation: Higher-timeframe EMA = EMA of higher-timeframe closes, using the last completed higher-timeframe bar, including the bar completing at the current chart bar close.
Calculation: Session membership = the chart bar's opening time in America/New_York is within either enabled configured daily session, inclusive of its start and exclusive of its end.
Calculation: Session trade count = number of entry signals since the start of the current session window; reset to zero when the current bar enters either enabled window from outside that window.
Calculation: Long stop = latest confirmed pivot low at the long signal minus a configured price buffer; long target = long signal close + (long signal close − long stop) × a configured reward-to-risk ratio. Retain both levels for the trade.
Calculation: Short stop = latest confirmed pivot high at the short signal plus a configured price buffer; short target = short signal close − (short stop − short signal close) × a configured reward-to-risk ratio. Retain both levels for the trade.
Long: close > latest confirmed pivot high AND previous close <= the current latest confirmed pivot high AND close > higher-timeframe EMA AND RSI of close > configured RSI threshold AND volume > SMA of volume × configured multiplier AND session membership = true AND session trade count < configured limit AND position side = flat.
Short: close < latest confirmed pivot low AND previous close >= the current latest confirmed pivot low AND close < higher-timeframe EMA AND RSI of close < configured RSI threshold AND volume > SMA of volume × configured multiplier AND session membership = true AND session trade count < configured limit AND position side = flat.
Long: close > higher-timeframe EMA.
Short: close <= higher-timeframe EMA.
Long: RSI of close > configured RSI threshold.
Short: RSI of close <= configured RSI threshold.
Exit: long, low <= long stop OR high >= long target OR (session membership = false AND previous bar session membership = true).
Exit: short, high >= short stop OR low <= short target OR (session membership = false AND previous bar session membership = true).