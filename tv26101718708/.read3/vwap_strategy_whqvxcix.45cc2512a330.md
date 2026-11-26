Calculation: RTH VWAP price cross up = during RTH after its first bar, close crosses above RTH-session VWAP in close mode, or prior close < prior VWAP AND low <= current VWAP <= high AND close > current VWAP in wick mode
Calculation: RTH VWAP price cross down = during RTH after its first bar, close crosses below RTH-session VWAP in close mode, or prior close > prior VWAP AND low <= current VWAP <= high AND close < current VWAP in wick mode
Calculation: RTH VWAP cross count = number of configured-mode upward and downward RTH VWAP price crosses in the latest or previous trade session, reset at each RTH start
Calculation: Long reclaim state = reset at each RTH start, set when close > RTH VWAP in single-close mode or when close > RTH VWAP AND prior close > prior RTH VWAP in multi-close mode, reset after the configured consecutive-close acceptance below RTH VWAP
Calculation: Short reclaim state = reset at each RTH start, set when close < RTH VWAP in single-close mode or when close < RTH VWAP AND prior close < prior RTH VWAP in multi-close mode, reset after the configured consecutive-close acceptance above RTH VWAP
Calculation: Long pending setup = the high and low of the most recent qualifying long hold candle; becomes active on that candle and resets at RTH start, acceptance below RTH VWAP, failure of the long EMA condition or reclaim state, exit from the trade window or latest/previous trade session, or reaching the VWAP cross limit
Calculation: Short pending setup = the high and low of the most recent qualifying short hold candle; becomes active on that candle and resets at RTH start, acceptance above RTH VWAP, failure of the short EMA condition or reclaim state, exit from the trade window or latest/previous trade session, or reaching the VWAP cross limit
Calculation: Opening range high and low = high and low of the opening interval on T1 bars, read on chart bars from the last completed T1 bar historically or the current-forming T1 bar in real time
Long: During RTH in the latest or previous trade session, EMA(close, shorter lookback) crosses above EMA(close, longer lookback)
Short: During RTH in the latest or previous trade session, EMA(close, shorter lookback) crosses below EMA(close, longer lookback)
Long: RTH VWAP price cross up in the latest or previous trade session
Short: RTH VWAP price cross down in the latest or previous trade session
Long: During RTH in the latest or previous trade session and after its first bar, RTH-session VWAP crosses above second-session VWAP
Short: During RTH in the latest or previous trade session and after its first bar, RTH-session VWAP crosses below second-session VWAP
Long: During the trade window in RTH and the latest or previous trade session, RTH VWAP cross count < maximum-cross parameter AND Long reclaim state AND EMA(close, shorter lookback) > EMA(close, intermediate lookback) > EMA(close, longer lookback) AND each EMA is above its prior-bar value AND low <= RTH VWAP + touch-buffer parameter AND close > RTH VWAP AND (volume confirmation is disabled OR volume > prior-bar volume)
Short: During the trade window in RTH and the latest or previous trade session, RTH VWAP cross count < maximum-cross parameter AND Short reclaim state AND EMA(close, shorter lookback) < EMA(close, intermediate lookback) < EMA(close, longer lookback) AND each EMA is below its prior-bar value AND high >= RTH VWAP - touch-buffer parameter AND close < RTH VWAP AND (volume confirmation is disabled OR volume > prior-bar volume)
Long: Flat AND a pending long setup AND during the trade window in RTH and the latest or previous trade session AND RTH VWAP cross count < maximum-cross parameter AND rounded-to-tick risk from setup high + entry-offset parameter to setup low - stop-buffer parameter <= maximum-stop parameter AND entry level > stop level
Short: Flat AND a pending short setup AND during the trade window in RTH and the latest or previous trade session AND RTH VWAP cross count < maximum-cross parameter AND rounded-to-tick risk from setup high + stop-buffer parameter to setup low - entry-offset parameter <= maximum-stop parameter AND stop level > entry level
Exit: Long, low <= pending long setup low - stop-buffer parameter
Exit: Long, high >= entry price + profit-target parameter
Exit: Short, high >= pending short setup high + stop-buffer parameter
Exit: Short, low <= entry price - profit-target parameter
Long: For each context-panel market with an RTH VWAP status, close > its RTH-session VWAP
Short: For each context-panel market with an RTH VWAP status, close < its RTH-session VWAP
Long: For each context-panel market with a second-session VWAP status, close > its second-session VWAP
Short: For each context-panel market with a second-session VWAP status, close < its second-session VWAP
Long: For each context-panel market with a previous-RTH-VWAP status, close > its previous completed RTH VWAP
Short: For each context-panel market with a previous-RTH-VWAP status, close < its previous completed RTH VWAP
Long: For each context-panel market with an opening-range status, close > opening-range high
Short: For each context-panel market with an opening-range status, close < opening-range low