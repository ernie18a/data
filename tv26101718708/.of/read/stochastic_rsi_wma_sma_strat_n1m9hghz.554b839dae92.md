Calculation: Stochastic RSI %K = smoothed stochastic of RSI(close)
Calculation: Stochastic RSI %D = smoothed average of %K
Calculation: Entry swing low/high = lowest low/highest high over the lookback, sampled at entry
Calculation: Entry ATR = ATR sampled at entry
Calculation: Long stop = entry swing low − (entry ATR / 5 × stop expander)
Calculation: Short stop = entry swing high + (entry ATR / 5 × stop expander)
Calculation: Long target = entry price + (entry price − entry swing low) + (entry ATR / 5 × target expander)
Calculation: Short target = entry price − (entry swing high − entry price) − (entry ATR / 5 × target expander)
Calculation: Long trailing stop = the greater of its prior value and current high − initial (entry price − long stop) − (first long-position bar high − entry price)
Calculation: Short trailing stop = the lesser of its prior value and current low + initial (short stop − entry price) + (entry price − first short-position bar low)
Long: %K crosses above %D AND %K is below the oversold threshold AND chart-timeframe SMA(close, short lookback) > chart-timeframe WMA(close, long lookback) AND higher-timeframe SMA(close, short lookback) > higher-timeframe WMA(close, long lookback), with the higher-timeframe calculations using the still-forming bar
Short: %K crosses below %D AND %K is above the overbought threshold AND chart-timeframe SMA(close, short lookback) < chart-timeframe WMA(close, long lookback) AND higher-timeframe SMA(close, short lookback) < higher-timeframe WMA(close, long lookback), with the higher-timeframe calculations using the still-forming bar
Exit: Long, low <= long stop OR high >= long target
Exit: Short, high >= short stop OR low <= short target