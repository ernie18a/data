Calculation: Session high and low = maximum high and minimum low of range-timeframe bars opening within the configured session on the current calendar day. The range timeframe may be higher, lower, or equal to the chart timeframe; include its still-forming bar if it opened during the session.
Calculation: Breakout bar = a bar opening after the session ends and before the end of the same calendar day. The breakout timeframe may be higher, lower, or equal to the chart timeframe; use the last completed bar for close confirmation or the still-forming bar for wick confirmation.
Calculation: Initial risk = entry price minus the selected initial stop for a long position, or the selected initial stop minus entry price for a short position. Capture the stop and any entry-time reference values when the position opens.
Long: On an allowed day, the first breakout bar of the day with close above the session high in close-confirmation mode OR high above the session high in wick-confirmation mode.
Short: On an allowed day, the first breakout bar of the day with close below the session low in close-confirmation mode OR low below the session low in wick-confirmation mode.
Long: After a bullish breakout on an allowed day, low below the session high AND close above the session high.
Short: After a bearish breakout on an allowed day, high above the session low AND close below the session low.
Exit: long, low at or below the entry breakout bar's low minus a buffer OR the entry session low minus a buffer OR entry price minus an ATR multiple captured at entry.
Exit: short, high at or above the entry breakout bar's high plus a buffer OR the entry session high plus a buffer OR entry price plus an ATR multiple captured at entry.
Exit: long, high at or above the entry session high plus the entry session range OR the high of the completed day preceding entry OR entry price plus a selected multiple of initial risk.
Exit: short, low at or below the entry session low minus the entry session range OR the low of the completed day preceding entry OR entry price minus a selected multiple of initial risk.
Exit: long, after a partial exit at a selected multiple of initial risk, low at or below entry price.
Exit: short, after a partial exit at a selected multiple of initial risk, high at or above entry price.