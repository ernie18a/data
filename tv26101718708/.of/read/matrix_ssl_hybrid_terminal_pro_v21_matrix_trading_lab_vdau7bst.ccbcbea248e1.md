Calculation: Trend line = selectable moving average of a selectable price source; available types are SMA, EMA, DEMA, TEMA, WMA, HMA, LSMA, TMA and Kijun midpoint. Kijun midpoint is the average of the highest high and lowest low over the lookback. TMA is an SMA of an SMA, with respective lookbacks rounded up from half the length and rounded down from half the length plus one.
Calculation: Trend channel = trend line plus or minus EMA of true range, using the trend line lookback, multiplied by a channel multiplier.
Calculation: Volume pressure = volume greater than its SMA multiplied by a volume multiplier, with bullish pressure when close is greater than open and bearish pressure when close is less than open.
Calculation: Buy warning = bullish volume pressure OR MACD line crosses above its signal line OR RSI is above its bullish threshold AND above its previous value. Sell warning = bearish volume pressure OR MACD line crosses below its signal line OR RSI is below its bearish threshold AND below its previous value.
Calculation: Locked trend state = initially neutral; set bullish when close exceeds the upper trend channel plus ATR times a buffer multiplier for the confirmation lookback of consecutive bars AND, if momentum confirmation is enabled, RSI is above its midpoint OR MACD line is above its signal line OR bullish volume pressure is present. Set bearish when close is below the lower trend channel minus ATR times the buffer multiplier for the confirmation lookback of consecutive bars AND, if momentum confirmation is enabled, RSI is below its midpoint OR MACD line is below its signal line OR bearish volume pressure is present. Otherwise retain the previous state. Confirmation requires a preceding bar on which the respective channel condition was false.
Calculation: Signal direction = initially neutral; set long on a confirmed long signal and short on a confirmed short signal; retain it until the opposite confirmed signal. Evaluate the direction lock using the previous signal direction.
Calculation: Entry distance = absolute difference between close and trend line divided by ATR; use zero when ATR is not positive.
Calculation: SSL line = selectable moving average of highs and the same moving average of lows. Set its direction bullish when close is above the high average, bearish when close is below the low average, and otherwise retain its previous direction, initially neutral. Use the high average when bearish and the low average otherwise. Calculate the continuation SSL line independently with its own moving-average type and lookback.
Long: Locked trend state is bullish AND close is above the trend line AND signal direction is not long AND (entry-distance filter is disabled OR entry distance is at most its maximum) AND (warning filter is disabled OR buy warning is active).
Short: Locked trend state is bearish AND close is below the trend line AND signal direction is not short AND (entry-distance filter is disabled OR entry distance is at most its maximum) AND (warning filter is disabled OR sell warning is active).
Long: Buy warning is active.
Short: Sell warning is active.
Long: Close is above the upper trend channel plus ATR times the buffer multiplier.
Short: Close is below the lower trend channel minus ATR times the buffer multiplier.
Long: Locked trend state is bullish.
Short: Locked trend state is bearish.
Long: Close is above the SSL line OR close is above the continuation SSL line.
Short: Close is below the SSL line OR close is below the continuation SSL line.
Long: MACD line is above its signal line OR RSI is at least its bullish threshold OR bullish volume pressure is present.
Short: MACD line is below its signal line OR RSI is at most its bearish threshold OR bearish volume pressure is present.
Exit: long, close is below the trend line OR sell warning is active.
Exit: short, close is above the trend line OR buy warning is active.
Exit: long, ATR is positive AND close minus entry price is at least ATR times the take-profit multiplier.
Exit: short, ATR is positive AND entry price minus close is at least ATR times the take-profit multiplier.