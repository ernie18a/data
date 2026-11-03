Calculation: Moving averages = independently selectable SMA, EMA, RMA, or WMA of close, with a shorter lookback for the fast average and a longer lookback for the slow average.
Calculation: Long bias = fast moving average > Bollinger middle band AND fast moving average > slow moving average.
Calculation: Short bias = fast moving average < Bollinger middle band AND fast moving average < slow moving average.
Calculation: Armed direction = while flat, arm long or short when the corresponding bias becomes true after being false on the previous bar; replace any existing arm with the new direction. Cancel the arm when its bias becomes false, its age in bars reaches the setup-validity parameter, or an entry occurs. An arm can enter on its creation bar; a failed ATR filter leaves it armed. Do not create or use an arm on an exit bar.
Calculation: Long stop = lower Bollinger band at entry; if trailing is enabled, after each subsequent bar without an exit, update it to the maximum of its previous value and the current lower band.
Calculation: Short stop = upper Bollinger band at entry; if trailing is enabled, after each subsequent bar without an exit, update it to the minimum of its previous value and the current upper band.
Long: Position is flat at the start of the bar AND fast moving average crosses above the Bollinger middle band OR slow moving average AND long bias is false.
Short: Position is flat at the start of the bar AND fast moving average crosses below the Bollinger middle band OR slow moving average AND short bias is false.
Long: Position is flat AND long bias becomes true after being false on the previous bar AND no long entry occurs on the same bar.
Short: Position is flat AND short bias becomes true after being false on the previous bar AND no short entry occurs on the same bar.
Long: Armed direction is long AND close > Bollinger middle band AND (ATR filter is disabled OR (close - Bollinger middle band <= maximum distance parameter * ATR AND high - low <= maximum range parameter * ATR)).
Short: Armed direction is short AND close < Bollinger middle band AND (ATR filter is disabled OR (Bollinger middle band - close <= maximum distance parameter * ATR AND high - low <= maximum range parameter * ATR)).
Long: Armed direction is long AND close > Bollinger middle band AND ATR filter is enabled AND (close - Bollinger middle band > maximum distance parameter * ATR OR high - low > maximum range parameter * ATR).
Short: Armed direction is short AND close < Bollinger middle band AND ATR filter is enabled AND (Bollinger middle band - close > maximum distance parameter * ATR OR high - low > maximum range parameter * ATR).
Exit: Long, low <= long stop OR high >= current upper Bollinger band OR (early exit is enabled AND slow moving average crosses below Bollinger middle band).
Exit: Short, high >= short stop OR low <= current lower Bollinger band OR (early exit is enabled AND slow moving average crosses above Bollinger middle band).