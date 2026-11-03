Calculation: Doji = open and close differ by less than the configured doji tolerance, using the source’s open-versus-close inequalities.
Calculation: Morning Doji Star = the candle two bars ago is bearish with body greater than 60% of its high-low range; the previous candle meets either configured tolerance inequality, with the close-below-range condition applying to the second inequality; the current candle is bullish and closes above the close two bars ago plus that bar’s high-low range.
Long: Doji AND close > EMA of close AND (max-loss filter disabled OR close − lowest low over the stop lookback < close × configured max-loss percentage)
Long: Morning Doji Star AND close > EMA of close AND (max-loss filter disabled OR close − lowest low over the stop lookback < close × configured max-loss percentage)
Exit: Long, low <= lowest low over the stop lookback (when lowest-low stop is selected)
Exit: Long, low <= entry price × (1 − configured stop-loss percentage) (when percentage stop is selected)
Exit: Long, high >= entry price × (1 + configured take-profit percentage)
Exit: Long, low <= active trailing stop; trailing activates when price reaches entry price plus the configured trailing threshold, then tracks the highest high since activation minus the configured trailing offset
Exit: Long, MFI crosses above its upper threshold