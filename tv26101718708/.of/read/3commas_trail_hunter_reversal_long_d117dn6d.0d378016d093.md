Calculation: MA cross-under = the shorter-lookback SMA or EMA of close crosses below the longer-lookback average of the same type, computed on the selected signal timeframe. For a higher timeframe, use the last completed bar; for a lower timeframe, use the last completed lower-timeframe bar within each chart bar.
Calculation: CCI cross-under = CCI of close crosses below its threshold, computed on its independently selected signal timeframe. For a higher timeframe, use the last completed bar; for a lower timeframe, use the last completed lower-timeframe bar within each chart bar.
Long: CCI cross-under occurs.
Short: MA cross-under occurs.
Long: Position is flat AND either enabled signal occurs now AND each enabled signal occurred within the keep-alive window measured in chart bars, including the current bar.
Long: Position is flat AND either MA cross-under or CCI cross-under occurs, when the OR combination mode is selected.
Exit: long, low <= entry-signal bar close × (1 − stop-loss fraction), when stop loss is enabled.
Exit: long, high >= entry-signal bar close × (1 + take-profit fraction), when trailing is disabled.
Exit: long, high has reached entry-signal bar close × (1 + take-profit fraction) since entry AND price falls to or below the highest price since trailing activation minus the trailing distance, when trailing is enabled. The trailing distance is the entry-signal bar close × trailing fraction, rounded to the nearest price tick with a minimum of one tick.