Calculation: Bands = a selected moving average of close, plus and minus a multiplier times the standard deviation of close; the moving average and standard deviation have independently configurable lookbacks.
Calculation: Band width = upper band minus lower band; its baseline is a simple moving average of band width.
Calculation: Valid long signal = open < lower band AND close > lower band AND RSI of close crossed above its neutral level on the current bar or within a configurable number of preceding bars AND (high-volatility filter disabled OR band width <= baseline × (1 + volatility factor)) AND (low-volatility filter disabled OR band width >= baseline × (1 - volatility factor)) AND (date filter disabled OR datetime outside the inclusive excluded date interval) AND (session filter disabled OR datetime inside the configured session).
Calculation: Valid short signal = open > upper band AND close < upper band AND RSI of close crossed below its neutral level on the current bar or within a configurable number of preceding bars AND (high-volatility filter disabled OR band width <= baseline × (1 + volatility factor)) AND (low-volatility filter disabled OR band width >= baseline × (1 - volatility factor)) AND (date filter disabled OR datetime outside the inclusive excluded date interval) AND (session filter disabled OR datetime inside the configured session).
Calculation: Signal direction = the direction of the most recent valid signal, initially neither direction; a direction change occurs when the current valid signal differs from the preceding bar's signal direction.
Calculation: Saved stop and target = when a valid long signal occurs and the preceding bar's position is short or flat, save close - ATR × stop multiplier and close + ATR × stop multiplier × reward multiplier; when a valid short signal occurs and the preceding bar's position is long or flat, save close + ATR × stop multiplier and close - ATR × stop multiplier × reward multiplier. Retain these values until replaced.
Calculation: Trailing stop = initialize on the same signals as the saved stop: lowest low over the trailing lookback minus ATR × stop multiplier for a long signal, or highest high over the trailing lookback plus ATR × stop multiplier for a short signal. While long, update to the maximum of the current long trailing value, the saved trailing stop, and its previous-bar value; while short, update to the minimum of the corresponding short trailing value, the saved trailing stop, and its previous-bar value. Clear it when the position changes from nonzero to flat.
Long: Valid long signal.
Short: Valid short signal.
Exit: long, short trading enabled AND valid short signal AND signal direction changes.
Exit: short, long trading enabled AND valid long signal AND signal direction changes.
Exit: long, take profit enabled AND high >= saved target.
Exit: short, take profit enabled AND low <= saved target.
Exit: long, fixed stop enabled AND low <= saved stop.
Exit: short, fixed stop enabled AND high >= saved stop.
Exit: long, fixed stop disabled AND trailing stop enabled AND low <= trailing stop.
Exit: short, fixed stop disabled AND trailing stop enabled AND high >= trailing stop.
Exit: long, fixed stop disabled AND trailing stop disabled AND signal direction changes AND low <= upper band.
Exit: short, fixed stop disabled AND trailing stop disabled AND signal direction changes AND high >= lower band.