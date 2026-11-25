Calculation: first moving average = selected moving-average type(source 1, lookback 1)
Calculation: second moving average = selected moving-average type(source 2, lookback 2)
Calculation: third moving average = selected moving-average type(source 3, lookback 3)
Calculation: fourth moving average = selected moving-average type(source 4, lookback 4)
Calculation: fifth moving average = selected moving-average type(source 5, lookback 5)
Calculation: bullish moving-average state = the first moving average is enabled, close is above it, and each consecutively enabled moving average after it is below the preceding average; stop at the first disabled average
Calculation: bearish moving-average state = the first moving average is enabled, close is below it, and each consecutively enabled moving average after it is above the preceding average; stop at the first disabled average
Calculation: bullish moving-average alert = bullish moving-average state AND NOT bullish moving-average state[1]
Calculation: bearish moving-average alert = bearish moving-average state AND NOT bearish moving-average state[1]
Calculation: bullish Supertrend state = Supertrend(selected source, ATR lookback, ATR multiplier, ATR method, optional Heikin Ashi OHLC) is bullish
Calculation: bearish Supertrend state = Supertrend(selected source, ATR lookback, ATR multiplier, ATR method, optional Heikin Ashi OHLC) is bearish
Calculation: bullish Supertrend alert = bullish Supertrend state AND NOT bullish Supertrend state[1]
Calculation: bearish Supertrend alert = bearish Supertrend state AND NOT bearish Supertrend state[1]
Calculation: RSI value = RSI(selected source, lookback, optional Heikin Ashi source)
Calculation: bullish RSI state = RSI value < lower band
Calculation: bearish RSI state = RSI value > upper band
Calculation: bullish RSI alert = RSI value > lower band AND RSI value[1] < lower band
Calculation: bearish RSI alert = RSI value < upper band AND RSI value[1] > upper band
Calculation: Stochastic RSI K = SMA(Stochastic(RSI(source, RSI lookback), RSI(source, RSI lookback), RSI(source, RSI lookback), stochastic lookback), K smoothing)
Calculation: Stochastic RSI D = SMA(Stochastic RSI K, D smoothing)
Calculation: bullish Stochastic RSI state = Stochastic RSI K < lower band AND Stochastic RSI D < upper band
Calculation: bearish Stochastic RSI state = Stochastic RSI K > lower band AND Stochastic RSI D > upper band
Calculation: bullish Stochastic RSI alert = Stochastic RSI K crosses above Stochastic RSI D AND (band restriction is disabled OR Stochastic RSI K <= lower band)
Calculation: bearish Stochastic RSI alert = Stochastic RSI K crosses below Stochastic RSI D AND (band restriction is disabled OR Stochastic RSI K >= upper band)
Calculation: DI+ = positive directional movement smoothed with Wilder's method over the ADX lookback, divided by true range smoothed with Wilder's method over the same lookback, times 100
Calculation: DI- = negative directional movement smoothed with Wilder's method over the ADX lookback, divided by true range smoothed with Wilder's method over the same lookback, times 100
Calculation: ADX = SMA(100 * abs(DI+ - DI-) / (DI+ + DI-), ADX lookback)
Calculation: bullish DI state = DI+ > DI-
Calculation: bearish DI state = DI- > DI+
Calculation: bullish DI alert = bullish DI state AND NOT bullish DI state[1]
Calculation: bearish DI alert = bearish DI state AND NOT bearish DI state[1]
Calculation: configured bullish ADX condition = (mode is Entry AND type is DI+ and DI- AND bullish DI alert) OR (mode is Entry AND type is ADX and DI AND bullish DI alert AND ADX > threshold) OR (mode is Filter AND type is DI+ and DI- AND bullish DI state) OR (mode is Filter AND type is ADX and Threshold [Only Filter] AND ADX > threshold) OR (mode is Filter AND type is ADX and DI AND bullish DI state AND ADX > threshold)
Calculation: configured bearish ADX condition = (mode is Entry AND type is DI+ and DI- AND bearish DI alert) OR (mode is Entry AND type is ADX and DI AND bearish DI alert AND ADX > threshold) OR (mode is Filter AND type is DI+ and DI- AND bearish DI state) OR (mode is Filter AND type is ADX and Threshold [Only Filter] AND ADX > threshold) OR (mode is Filter AND type is ADX and DI AND bearish DI state AND ADX > threshold)
Calculation: Parabolic SAR = Parabolic SAR(start, increment, maximum)
Calculation: bullish SAR state = close >= Parabolic SAR
Calculation: bearish SAR state = close <= Parabolic SAR
Calculation: bullish SAR alert = bullish SAR state AND NOT bullish SAR state[1]
Calculation: bearish SAR alert = bearish SAR state AND NOT bearish SAR state[1]
Calculation: allowed entry time = (start-time filter is disabled OR datetime >= start time) AND (end-time filter is disabled OR datetime <= end time) AND datetime equals the bar time for the selected session and timezone AND the weekday's enable flag is true
Calculation: configured bullish moving-average condition = if mode is Entry, bullish moving-average alert; otherwise, bullish moving-average state
Calculation: configured bearish moving-average condition = if mode is Entry, bearish moving-average alert; otherwise, bearish moving-average state
Calculation: configured bullish Supertrend condition = if mode is Entry, bullish Supertrend alert; otherwise, bullish Supertrend state
Calculation: configured bearish Supertrend condition = if mode is Entry, bearish Supertrend alert; otherwise, bearish Supertrend state
Calculation: configured bullish RSI condition = if mode is Entry, bullish RSI alert; otherwise, bullish RSI state
Calculation: configured bearish RSI condition = if mode is Entry, bearish RSI alert; otherwise, bearish RSI state
Calculation: configured bullish Stochastic RSI condition = if mode is Entry, bullish Stochastic RSI alert; otherwise, bullish Stochastic RSI state
Calculation: configured bearish Stochastic RSI condition = if mode is Entry, bearish Stochastic RSI alert; otherwise, bearish Stochastic RSI state
Calculation: configured bullish SAR condition = if mode is Entry, bullish SAR alert; otherwise, bullish SAR state
Calculation: configured bearish SAR condition = if mode is Entry, bearish SAR alert; otherwise, bearish SAR state
Long: bullish moving-average alert
Short: bearish moving-average alert
Long: bullish Supertrend alert
Short: bearish Supertrend alert
Long: bullish RSI alert
Short: bearish RSI alert
Long: bullish Stochastic RSI alert
Short: bearish Stochastic RSI alert
Long: (type is DI+ and DI- AND bullish DI state) OR (type is ADX and Threshold [Only Filter] AND ADX > threshold) OR (type is ADX and DI AND bullish DI state AND ADX > threshold)
Short: (type is DI+ and DI- AND bearish DI state) OR (type is ADX and DI AND bearish DI state AND ADX > threshold)
Long: bullish SAR state
Short: bearish SAR state
Long: allowed entry time AND at least one indicator module is enabled AND every enabled module's configured bullish condition holds
Short: allowed entry time AND at least one indicator module is enabled AND every enabled module's configured bearish condition holds
Calculation: initial long stop at entry = for Fixed % or Custom, entry price - entry price * stop percentage; for Fixed $, entry price - fixed amount; for ATR, entry-bar low - ATR(stop lookback) * stop multiplier; for Last High/Low, last confirmed pivot low(low, left lookback, right lookback)
Calculation: initial short stop at entry = for Fixed % or Custom, entry price + entry price * stop percentage; for Fixed $, entry price + fixed amount; for ATR, entry-bar high + ATR(stop lookback) * stop multiplier; for Last High/Low, last confirmed pivot high(high, left lookback, right lookback)
Calculation: long stop = when trailing stop is enabled and the composite long signal is false, max(previous long stop, close - (entry price - initial long stop)); otherwise initial long stop
Calculation: short stop = when trailing stop is enabled and the composite short signal is false, min(previous short stop, close + (initial short stop - entry price)); otherwise initial short stop
Calculation: long target at entry = for Fixed %, entry price + entry price * target percentage; for Fixed $, entry price + fixed amount; for Ratio 1:X, entry price + (entry price - initial long stop) * ratio; for ATR, entry-bar high + ATR(target lookback) * target multiplier; for Custom, entry price + entry price * target percentage
Calculation: short target at entry = for Fixed %, entry price - entry price * target percentage; for Fixed $, entry price - fixed amount; for Ratio 1:X, entry price - (initial short stop - entry price) * ratio; for ATR, entry-bar low - ATR(target lookback) * target multiplier; for Custom, entry price - entry price * target percentage
Exit: long, (stop loss enabled AND low <= long stop) OR (take profit enabled AND high >= long target)
Exit: short, (stop loss enabled AND high >= short stop) OR (take profit enabled AND low <= short target)