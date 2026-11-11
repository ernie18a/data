Calculation: Chart bars = Heikin-Ashi bars derived from the input OHLC bars.
Calculation: Keltner Channel = EMA of chart-bar close plus or minus a multiplier times EMA of chart-bar true range, using the same lookback for both EMAs.
Calculation: Long trailing stop = chart-bar low on the entry-signal bar minus an initial-stop multiplier times ATR; on each bar while long, update it to the greater of its previous value and chart-bar low minus a trailing-stop multiplier times ATR.
Calculation: Short trailing stop = chart-bar high on the entry-signal bar plus an initial-stop multiplier times ATR; on each bar while short, update it to the lesser of its previous value and chart-bar high plus a trailing-stop multiplier times ATR.
Long: Chart-bar close > chart-bar open.
Short: Chart-bar close <= chart-bar open.
Long: Chart-bar close > shorter-term EMA of close AND chart-bar close > longer-term EMA of close.
Short: Chart-bar close <= shorter-term EMA of close OR chart-bar close <= longer-term EMA of close.
Short: Chart-bar close < shorter-term EMA of close AND chart-bar close < longer-term EMA of close.
Long: Position is flat AND chart-bar close > shorter-term EMA of close AND chart-bar close > longer-term EMA of close AND ADX > threshold AND chart-bar close crosses above the upper Keltner Channel AND bar time is within the configured entry session.
Short: Position is flat AND chart-bar close < shorter-term EMA of close AND chart-bar close < longer-term EMA of close AND ADX > threshold AND chart-bar close crosses below the lower Keltner Channel AND bar time is within the configured entry session.
Exit: long, chart-bar low <= long trailing stop OR bar time is within the configured end-of-session exit window.
Exit: short, chart-bar high >= short trailing stop OR bar time is within the configured end-of-session exit window.