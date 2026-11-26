Calculation: Opening-range high = highest T1 high from the first bar of the configured opening session through the current bar; reset at each session start
Calculation: Opening-range low = lowest T1 low from the first bar of the configured opening session through the current bar; reset at each session start
Calculation: Opening-range width = opening-range high − opening-range low
Calculation: Fib extension at ratio p = opening-range high + p × opening-range width for long, or opening-range low − p × opening-range width for short; first, second, and final extension ratios are separate parameters
Calculation: Long retest setup = 0 when high exceeds the long first extension or a long retest fires; 1 when a qualified long breakout fires; otherwise the prior value
Calculation: Short retest setup = 0 when low falls below the short first extension or a short retest fires; 1 when a qualified short breakout fires; otherwise the prior value
Calculation: Tracked long entry = qualified long breakout when retest is disabled, or long retest when retest is enabled
Calculation: Tracked short entry = qualified short breakout when retest is disabled, or short retest when retest is enabled
Calculation: Long trailing reference = opening-range high on a qualified long breakout bar; otherwise, high on a tracked long-entry bar; thereafter the greater of current high and prior reference while long, resetting when flat
Calculation: Short trailing reference = opening-range low on a qualified short breakout bar; otherwise, low on a tracked short-entry bar; thereafter the lesser of current low and prior reference while short, resetting when flat
Calculation: Long trailing stop = long trailing reference − initial-stop multiple × ATR(ATR lookback) sampled at tracked entry until the first extension is exceeded; then subtract first stop-offset ratio × opening-range width; after the second extension is exceeded, subtract second stop-offset ratio × opening-range width; each reached stage persists until flat or re-entry
Calculation: Short trailing stop = short trailing reference + initial-stop multiple × ATR(ATR lookback) sampled at tracked entry until the first extension is exceeded; then add first stop-offset ratio × opening-range width; after the second extension is exceeded, add second stop-offset ratio × opening-range width; each reached stage persists until flat or re-entry
Long: close crosses above opening-range high AND bar is outside the opening session AND inside the trading session
Short: close crosses below opening-range low AND bar is outside the opening session AND inside the trading session
Long: MA(source 1, type 1, shortest lookback) > MA(source 2, type 2, next-longer lookback) > MA(source 3, type 3, next-longer lookback) > MA(source 4, type 4, longest lookback) AND high < long first extension AND close crosses above opening-range high AND bar is inside the trading session and backtest interval
Short: MA(source 1, type 1, shortest lookback) < MA(source 2, type 2, next-longer lookback) < MA(source 3, type 3, next-longer lookback) < MA(source 4, type 4, longest lookback) AND low > short first extension AND close crosses below opening-range low AND bar is inside the trading session and backtest interval
Long: prior-bar long retest setup = 1 AND low < opening-range high
Short: prior-bar short retest setup = 1 AND high > opening-range low
Exit: Long, low < prior-bar long trailing stop AND long position was active on the prior bar AND bar is inside the backtest interval
Exit: Short, high > prior-bar short trailing stop AND short position was active on the prior bar AND bar is inside the backtest interval
Exit: Long, high reaches the long first extension AND long position is active AND bar is inside the backtest interval
Exit: Long, high reaches the long second extension AND long position is active AND bar is inside the backtest interval
Exit: Long, high reaches the long final extension AND long position is active AND bar is inside the backtest interval
Exit: Short, low reaches the short first extension AND short position is active AND bar is inside the backtest interval
Exit: Short, low reaches the short second extension AND short position is active AND bar is inside the backtest interval
Exit: Short, low reaches the short final extension AND short position is active AND bar is inside the backtest interval
Exit: Long, forced-close session is active AND long position was active on the prior bar AND bar is inside the backtest interval
Exit: Short, forced-close session is active AND short position was active on the prior bar AND bar is inside the backtest interval