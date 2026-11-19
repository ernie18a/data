Calculation: Opening-range high = highest high of chart-timeframe bars during the opening-range session, finalized when that session ends
Calculation: Opening-range low = lowest low of chart-timeframe bars during the opening-range session, finalized when that session ends
Calculation: ORB midpoint = (opening-range high + opening-range low) / 2
Calculation: Long stop = for continuation entries, ORB midpoint or opening-range low as selected by the continuation-stop parameter; for reversals, lowest low from the first below-range breakout through the reversal-entry bar
Calculation: Short stop = for continuation entries, ORB midpoint or opening-range high as selected by the same continuation-stop parameter; for reversals, highest high from the first above-range breakout through the reversal-entry bar
Calculation: Long risk = entry-signal bar close - long stop
Calculation: Short risk = short stop - entry-signal bar close
Calculation: Long target = entry-signal bar close + long risk × target-risk multiple
Calculation: Short target = entry-signal bar close - short risk × target-risk multiple
Long: Continuation entries enabled AND opening-range session ended AND chart bar is in the trade window AND position is flat AND current T1 period has no earlier post-range close outside the opening range AND close > opening-range high AND long risk > minimum tick size
Short: Continuation entries enabled AND opening-range session ended AND chart bar is in the trade window AND position is flat AND current T1 period has no earlier post-range close outside the opening range AND close < opening-range low AND short risk > minimum tick size
Long: Reversal entries enabled AND chart bar is in the trade window AND the first post-range close outside the opening range in the current T1 period occurred while flat and was below the opening-range low AND no reversal has occurred in the current T1 period AND opening-range low < close < opening-range high AND (continuation entries are disabled OR reversal after continuation closes is enabled OR a short position is open) AND long risk > minimum tick size
Short: Reversal entries enabled AND chart bar is in the trade window AND the first post-range close outside the opening range in the current T1 period occurred while flat and was above the opening-range high AND no reversal has occurred in the current T1 period AND opening-range low < close < opening-range high AND (continuation entries are disabled OR reversal after continuation closes is enabled OR a long position is open) AND short risk > minimum tick size
Exit: Long, low <= long stop OR high >= long target OR (trade window ends AND session-end closing is enabled)
Exit: Short, high >= short stop OR low <= short target OR (trade window ends AND session-end closing is enabled)