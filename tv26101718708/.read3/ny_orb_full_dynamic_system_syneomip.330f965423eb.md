Calculation: Opening-range high = highest(high during the configured New York opening-range window for the current trading day)
Calculation: Opening-range low = lowest(low during the configured New York opening-range window for the current trading day)
Calculation: Opening-range range = opening-range high − opening-range low
Calculation: Stop distance = selected fixed stop distance in ticks, ATR(ATR lookback) × ATR stop multiplier, min(ATR(ATR lookback) × ATR stop multiplier, maximum ATR stop distance in ticks), or opening-range range × OR stop multiplier
Calculation: Breakeven trigger distance = selected fixed breakeven trigger distance in ticks or ATR(ATR lookback) × adaptive breakeven percentage
Calculation: Long stop price = entry price if breakeven is enabled and close >= entry price + breakeven trigger distance; otherwise entry price − stop distance
Calculation: Short stop price = entry price if breakeven is enabled and close <= entry price − breakeven trigger distance; otherwise entry price + stop distance
Calculation: Target distance = selected ATR(ATR lookback) or opening-range range × profit-target multiplier
Calculation: Long target price = entry price if breakeven is enabled and close >= entry price + breakeven trigger distance; otherwise entry price + target distance
Calculation: Short target price = entry price if breakeven is enabled and close <= entry price − breakeven trigger distance; otherwise entry price − target distance
Calculation: Trailing distance = selected fixed trailing distance in ticks or ATR(ATR lookback) × trailing ATR multiplier; after the breakeven trigger, use ATR(ATR lookback) × tightened ATR trailing multiplier when auto-tighten is enabled
Calculation: Long trailing stop = highest high since entry − trailing distance
Calculation: Short trailing stop = lowest low since entry + trailing distance
Calculation: Daily PnL = current-day realized gains adjusted for position side plus unrealized gain, position side × (close − entry price), expressed in ticks
Long: opening-range high exists AND close > opening-range high AND (confirmation filter disabled OR close[confirmation lookback] <= opening-range high) AND (second-break filter disabled OR an earlier close > opening-range high was followed by a later close <= opening-range high today) AND (RSI filter disabled OR RSI(close, RSI lookback) < RSI overbought threshold) AND (MACD filter disabled OR MACD line(close, fast lookback, slow lookback, signal smoothing) > MACD signal line(close, fast lookback, slow lookback, signal smoothing)) AND (VWAP filter disabled OR close > VWAP(close)) AND (trend filter disabled OR close > SMA(close, SMA lookback)) AND long trading is enabled AND datetime is within the configured entry window, inclusive, on an enabled weekday AND neither enabled daily limit has been hit today
Short: opening-range low exists AND close < opening-range low AND (confirmation filter disabled OR close[confirmation lookback] >= opening-range low) AND (second-break filter disabled OR an earlier close < opening-range low was followed by a later close >= opening-range low today) AND (RSI filter disabled OR RSI(close, RSI lookback) > RSI oversold threshold) AND (MACD filter disabled OR MACD line(close, fast lookback, slow lookback, signal smoothing) < MACD signal line(close, fast lookback, slow lookback, signal smoothing)) AND (VWAP filter disabled OR close < VWAP(close)) AND (trend filter disabled OR close < SMA(close, SMA lookback)) AND short trading is enabled AND datetime is within the configured entry window, inclusive, on an enabled weekday AND neither enabled daily limit has been hit today
Exit: Long, low <= long stop price
Exit: Short, high >= short stop price
Exit: Long, profit target is enabled AND high >= long target price
Exit: Short, profit target is enabled AND low <= short target price
Exit: Long, low <= long trailing stop
Exit: Short, high >= short trailing stop
Exit: Long, MA-cross exit is enabled AND close crosses below the selected SMA(close, SMA lookback) or VWAP(close) AND (profit target is disabled OR close < long target price)
Exit: Short, MA-cross exit is enabled AND close crosses above the selected SMA(close, SMA lookback) or VWAP(close) AND (profit target is disabled OR close > short target price)
Exit: Long, datetime is at or after the configured hard-exit time
Exit: Short, datetime is at or after the configured hard-exit time
Exit: Long, (daily profit limit is enabled AND daily PnL >= daily maximum profit) OR (daily loss limit is enabled AND daily PnL <= daily maximum loss)
Exit: Short, (daily profit limit is enabled AND daily PnL >= daily maximum profit) OR (daily loss limit is enabled AND daily PnL <= daily maximum loss)