Calculation: EMA crossover A signal = bullish when EMA(close, shorter lookback A) crosses above EMA(close, longer lookback A); bearish when EMA(close, shorter lookback A) crosses below EMA(close, longer lookback A)
Calculation: close/SMA crossover A signal = bullish when close crosses above SMA(close, shared SMA/Bollinger lookback); bearish when close crosses below it
Calculation: RSI outer-threshold signal = bullish when RSI(close, short RSI lookback) is below lower threshold A; bearish when it is above upper threshold A
Calculation: RSI re-entry signal = bullish when RSI(close, long RSI lookback) crosses above lower re-entry threshold; bearish when it crosses below upper re-entry threshold
Calculation: Bollinger excursion A signal = bullish when close is below the lower Bollinger Band(close, shared SMA/Bollinger lookback, width A); bearish when it is above the upper band
Calculation: prior-range breakout A signal = bullish when close > Highest(high, breakout lookback A)[1]; bearish when close < Lowest(low, breakout lookback A)[1]
Calculation: prior-range breakout B signal = bullish when close > Highest(high, breakout lookback B)[1]; bearish when close < Lowest(low, breakout lookback B)[1]
Calculation: MACD histogram zero-cross signal = bullish when MACD histogram(close, shared MACD parameters) crosses above zero; bearish when it crosses below zero
Calculation: Supertrend A reversal signal = bullish when Supertrend direction(configured factor A, configured ATR lookback A) changes from downtrend to uptrend; bearish when it changes from uptrend to downtrend
Calculation: Stochastic threshold-cross signal = bullish when SMA(Stochastic(high, low, close, stochastic lookback), smoothing lookback) crosses above lower threshold; bearish when it crosses below upper threshold
Calculation: inside-bar close-break signal = bullish when the previous bar is inside the bar before it and current close > previous bar high; bearish when the previous bar is inside the bar before it and current close < previous bar low
Calculation: close-sequence signal = bullish when closes decline consecutively over the configured run length; bearish when closes rise consecutively over the configured run length
Calculation: DMI trend-cross signal = bullish when ADX(DI lookback, ADX smoothing lookback) > ADX threshold and DI+(DI lookback) crosses above DI−(DI lookback); bearish when ADX exceeds the same threshold and DI− crosses above DI+
Calculation: Williams %R extreme signal = bullish when Williams %R(close, high, low, lookback) is below its lower threshold; bearish when it is above its upper threshold
Calculation: fresh-extreme reversal signal = bullish when previous bar low <= Lowest(low, shared ten-bar lookback)[2] and current close > previous bar high; bearish when previous bar high >= Highest(high, shared ten-bar lookback)[2] and current close < previous bar low
Calculation: gap-continuation signal = bullish when open > previous bar high and close > open; bearish when open < previous bar low and close < open
Calculation: EMA crossover B signal = bullish when EMA(close, shorter lookback B) crosses above EMA(close, longer lookback B); bearish when EMA(close, shorter lookback B) crosses below EMA(close, longer lookback B)
Calculation: close/SMA crossover B signal = bullish when close crosses above SMA(close, lookback B); bearish when close crosses below it
Calculation: RSI deep-threshold signal = bullish when RSI(close, short RSI lookback) is below lower threshold B; bearish when it is above upper threshold B
Calculation: RSI midpoint-cross signal = bullish when RSI(close, long RSI lookback) crosses above the midpoint threshold; bearish when it crosses below the same threshold
Calculation: Bollinger excursion B signal = bullish when close is below the lower Bollinger Band(close, shared SMA/Bollinger lookback, width B); bearish when it is above the upper band
Calculation: prior-range breakout C signal = bullish when close > Highest(high, shared ten-bar lookback)[1]; bearish when close < Lowest(low, shared ten-bar lookback)[1]
Calculation: MACD line/signal cross = bullish when MACD line(close, shared MACD parameters) crosses above its signal line; bearish when it crosses below its signal line
Calculation: Supertrend B reversal signal = bullish when Supertrend direction(configured factor B, configured ATR lookback B) changes from downtrend to uptrend; bearish when it changes from uptrend to downtrend
Calculation: selected long market filter = the chosen one of unrestricted; close > SMA(close, trend-filter lookback); PercentRank(ATR(high, low, close, shared ATR lookback) / close, volatility-rank lookback) < midpoint rank; ROC(close, momentum-filter lookback) > zero; the same PercentRank > midpoint rank; or close < SMA(close, trend-filter lookback)
Calculation: selected short market filter = the chosen one of unrestricted; close < SMA(close, trend-filter lookback); PercentRank(ATR(high, low, close, shared ATR lookback) / close, volatility-rank lookback) < midpoint rank; ROC(close, momentum-filter lookback) < zero; the same PercentRank > midpoint rank; or close > SMA(close, trend-filter lookback)
Calculation: entry permitted = force-flat mode disabled OR current bar datetime in the configured timezone is before the configured daily cutoff
Calculation: force-flat trigger = force-flat mode enabled AND current bar datetime in the configured timezone is at or after the configured daily cutoff
Long: bullish EMA crossover A signal AND selected long market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Short: bearish EMA crossover A signal AND selected short market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Long: bullish close/SMA crossover A signal AND selected long market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Short: bearish close/SMA crossover A signal AND selected short market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Long: bullish RSI outer-threshold signal AND selected long market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Short: bearish RSI outer-threshold signal AND selected short market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Long: bullish RSI re-entry signal AND selected long market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Short: bearish RSI re-entry signal AND selected short market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Long: bullish Bollinger excursion A signal AND selected long market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Short: bearish Bollinger excursion A signal AND selected short market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Long: bullish prior-range breakout A signal AND selected long market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Short: bearish prior-range breakout A signal AND selected short market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Long: bullish prior-range breakout B signal AND selected long market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Short: bearish prior-range breakout B signal AND selected short market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Long: bullish MACD histogram zero-cross signal AND selected long market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Short: bearish MACD histogram zero-cross signal AND selected short market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Long: bullish Supertrend A reversal signal AND selected long market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Short: bearish Supertrend A reversal signal AND selected short market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Long: bullish Stochastic threshold-cross signal AND selected long market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Short: bearish Stochastic threshold-cross signal AND selected short market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Long: bullish inside-bar close-break signal AND selected long market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Short: bearish inside-bar close-break signal AND selected short market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Long: bullish close-sequence signal AND selected long market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Short: bearish close-sequence signal AND selected short market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Long: bullish DMI trend-cross signal AND selected long market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Short: bearish DMI trend-cross signal AND selected short market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Long: bullish Williams %R extreme signal AND selected long market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Short: bearish Williams %R extreme signal AND selected short market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Long: bullish fresh-extreme reversal signal AND selected long market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Short: bearish fresh-extreme reversal signal AND selected short market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Long: bullish gap-continuation signal AND selected long market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Short: bearish gap-continuation signal AND selected short market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Long: bullish EMA crossover B signal AND selected long market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Short: bearish EMA crossover B signal AND selected short market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Long: bullish close/SMA crossover B signal AND selected long market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Short: bearish close/SMA crossover B signal AND selected short market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Long: bullish RSI deep-threshold signal AND selected long market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Short: bearish RSI deep-threshold signal AND selected short market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Long: bullish RSI midpoint-cross signal AND selected long market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Short: bearish RSI midpoint-cross signal AND selected short market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Long: bullish Bollinger excursion B signal AND selected long market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Short: bearish Bollinger excursion B signal AND selected short market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Long: bullish prior-range breakout C signal AND selected long market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Short: bearish prior-range breakout C signal AND selected short market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Long: bullish MACD line/signal cross AND selected long market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Short: bearish MACD line/signal cross AND selected short market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Long: bullish Supertrend B reversal signal AND selected long market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Short: bearish Supertrend B reversal signal AND selected short market filter AND entry permitted AND ATR(high, low, close, shared ATR lookback) is positive
Exit: Long, bars held >= holding duration A OR force-flat trigger
Exit: Long, bars held >= holding duration B OR force-flat trigger
Exit: Long, bars held >= holding duration C OR force-flat trigger
Exit: Short, bars held >= holding duration A OR force-flat trigger
Exit: Short, bars held >= holding duration B OR force-flat trigger
Exit: Short, bars held >= holding duration C OR force-flat trigger
Exit: Long, force-flat trigger OR low <= entry price − ATR(high, low, close, shared ATR lookback on entry signal bar) × shared distance scale × stop multiple A OR high >= entry price + ATR(high, low, close, shared ATR lookback on entry signal bar) × shared distance scale × target multiple A; if both levels are hit on one bar, apply the selected stop-first or target-first priority
Exit: Short, force-flat trigger OR high >= entry price + ATR(high, low, close, shared ATR lookback on entry signal bar) × shared distance scale × stop multiple A OR low <= entry price − ATR(high, low, close, shared ATR lookback on entry signal bar) × shared distance scale × target multiple A; if both levels are hit on one bar, apply the selected stop-first or target-first priority
Exit: Long, force-flat trigger OR low <= entry price − ATR(high, low, close, shared ATR lookback on entry signal bar) × shared distance scale × equal stop-and-target multiple B OR high >= entry price + ATR(high, low, close, shared ATR lookback on entry signal bar) × shared distance scale × the same multiple B; if both levels are hit on one bar, apply the selected stop-first or target-first priority
Exit: Short, force-flat trigger OR high >= entry price + ATR(high, low, close, shared ATR lookback on entry signal bar) × shared distance scale × equal stop-and-target multiple B OR low <= entry price − ATR(high, low, close, shared ATR lookback on entry signal bar) × shared distance scale × the same multiple B; if both levels are hit on one bar, apply the selected stop-first or target-first priority
Exit: Long, force-flat trigger OR low <= entry price − ATR(high, low, close, shared ATR lookback on entry signal bar) × shared distance scale × stop multiple C OR high >= entry price + ATR(high, low, close, shared ATR lookback on entry signal bar) × shared distance scale × target multiple C; if both levels are hit on one bar, apply the selected stop-first or target-first priority
Exit: Short, force-flat trigger OR high >= entry price + ATR(high, low, close, shared ATR lookback on entry signal bar) × shared distance scale × stop multiple C OR low <= entry price − ATR(high, low, close, shared ATR lookback on entry signal bar) × shared distance scale × target multiple C; if both levels are hit on one bar, apply the selected stop-first or target-first priority
Calculation: long trailing stop = entry price − ATR(high, low, close, shared ATR lookback on entry signal bar) × shared distance scale × trailing distance; after a bar does not hit the carried stop, the next stop is max(previous stop, close − ATR(high, low, close, shared ATR lookback on that bar) × shared distance scale × trailing distance)
Calculation: short trailing stop = entry price + ATR(high, low, close, shared ATR lookback on entry signal bar) × shared distance scale × trailing distance; after a bar does not hit the carried stop, the next stop is min(previous stop, close + ATR(high, low, close, shared ATR lookback on that bar) × shared distance scale × trailing distance)
Exit: Long, force-flat trigger OR current low <= the long trailing stop carried into this bar, tested before updating the stop from this bar's close
Exit: Short, force-flat trigger OR current high >= the short trailing stop carried into this bar, tested before updating the stop from this bar's close
Exit: Long, after at least one bar in the position, bearish EMA crossover A signal without its market filter OR force-flat trigger
Exit: Short, after at least one bar in the position, bullish EMA crossover A signal without its market filter OR force-flat trigger
Exit: Long, after at least one bar in the position, bearish close/SMA crossover A signal without its market filter OR force-flat trigger
Exit: Short, after at least one bar in the position, bullish close/SMA crossover A signal without its market filter OR force-flat trigger
Exit: Long, after at least one bar in the position, bearish RSI outer-threshold signal without its market filter OR force-flat trigger
Exit: Short, after at least one bar in the position, bullish RSI outer-threshold signal without its market filter OR force-flat trigger
Exit: Long, after at least one bar in the position, bearish RSI re-entry signal without its market filter OR force-flat trigger
Exit: Short, after at least one bar in the position, bullish RSI re-entry signal without its market filter OR force-flat trigger
Exit: Long, after at least one bar in the position, bearish Bollinger excursion A signal without its market filter OR force-flat trigger
Exit: Short, after at least one bar in the position, bullish Bollinger excursion A signal without its market filter OR force-flat trigger
Exit: Long, after at least one bar in the position, bearish prior-range breakout A signal without its market filter OR force-flat trigger
Exit: Short, after at least one bar in the position, bullish prior-range breakout A signal without its market filter OR force-flat trigger
Exit: Long, after at least one bar in the position, bearish prior-range breakout B signal without its market filter OR force-flat trigger
Exit: Short, after at least one bar in the position, bullish prior-range breakout B signal without its market filter OR force-flat trigger
Exit: Long, after at least one bar in the position, bearish MACD histogram zero-cross signal without its market filter OR force-flat trigger
Exit: Short, after at least one bar in the position, bullish MACD histogram zero-cross signal without its market filter OR force-flat trigger
Exit: Long, after at least one bar in the position, bearish Supertrend A reversal signal without its market filter OR force-flat trigger
Exit: Short, after at least one bar in the position, bullish Supertrend A reversal signal without its market filter OR force-flat trigger
Exit: Long, after at least one bar in the position, bearish Stochastic threshold-cross signal without its market filter OR force-flat trigger
Exit: Short, after at least one bar in the position, bullish Stochastic threshold-cross signal without its market filter OR force-flat trigger
Exit: Long, after at least one bar in the position, bearish inside-bar close-break signal without its market filter OR force-flat trigger
Exit: Short, after at least one bar in the position, bullish inside-bar close-break signal without its market filter OR force-flat trigger
Exit: Long, after at least one bar in the position, bearish close-sequence signal without its market filter OR force-flat trigger
Exit: Short, after at least one bar in the position, bullish close-sequence signal without its market filter OR force-flat trigger
Exit: Long, after at least one bar in the position, bearish DMI trend-cross signal without its market filter OR force-flat trigger
Exit: Short, after at least one bar in the position, bullish DMI trend-cross signal without its market filter OR force-flat trigger
Exit: Long, after at least one bar in the position, bearish Williams %R extreme signal without its market filter OR force-flat trigger
Exit: Short, after at least one bar in the position, bullish Williams %R extreme signal without its market filter OR force-flat trigger
Exit: Long, after at least one bar in the position, bearish fresh-extreme reversal signal without its market filter OR force-flat trigger
Exit: Short, after at least one bar in the position, bullish fresh-extreme reversal signal without its market filter OR force-flat trigger
Exit: Long, after at least one bar in the position, bearish gap-continuation signal without its market filter OR force-flat trigger
Exit: Short, after at least one bar in the position, bullish gap-continuation signal without its market filter OR force-flat trigger
Exit: Long, after at least one bar in the position, bearish EMA crossover B signal without its market filter OR force-flat trigger
Exit: Short, after at least one bar in the position, bullish EMA crossover B signal without its market filter OR force-flat trigger
Exit: Long, after at least one bar in the position, bearish close/SMA crossover B signal without its market filter OR force-flat trigger
Exit: Short, after at least one bar in the position, bullish close/SMA crossover B signal without its market filter OR force-flat trigger
Exit: Long, after at least one bar in the position, bearish RSI deep-threshold signal without its market filter OR force-flat trigger
Exit: Short, after at least one bar in the position, bullish RSI deep-threshold signal without its market filter OR force-flat trigger
Exit: Long, after at least one bar in the position, bearish RSI midpoint-cross signal without its market filter OR force-flat trigger
Exit: Short, after at least one bar in the position, bullish RSI midpoint-cross signal without its market filter OR force-flat trigger
Exit: Long, after at least one bar in the position, bearish Bollinger excursion B signal without its market filter OR force-flat trigger
Exit: Short, after at least one bar in the position, bullish Bollinger excursion B signal without its market filter OR force-flat trigger
Exit: Long, after at least one bar in the position, bearish prior-range breakout C signal without its market filter OR force-flat trigger
Exit: Short, after at least one bar in the position, bullish prior-range breakout C signal without its market filter OR force-flat trigger
Exit: Long, after at least one bar in the position, bearish MACD line/signal cross without its market filter OR force-flat trigger
Exit: Short, after at least one bar in the position, bullish MACD line/signal cross without its market filter OR force-flat trigger
Exit: Long, after at least one bar in the position, bearish Supertrend B reversal signal without its market filter OR force-flat trigger
Exit: Short, after at least one bar in the position, bullish Supertrend B reversal signal without its market filter OR force-flat trigger