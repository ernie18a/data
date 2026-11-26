Calculation: Short EMA = EMA(close, shorter EMA lookback) on chart bars
Calculation: Long EMA = EMA(close, longer EMA lookback) on chart bars
Calculation: Trend SMA = SMA(close, trend SMA lookback) on chart bars
Calculation: Volume average = SMA(volume, volume-average lookback) on chart bars
Calculation: RVOL = volume / Volume average when Volume average > 0, otherwise 1
Calculation: ATR value = ATR(ATR lookback) on chart bars
Calculation: VWAP value = VWAP((high + low + close) / 3) on chart bars
Calculation: Longer-lookback RSI = RSI(close, longer RSI lookback) on chart bars
Calculation: Shorter-lookback RSI = RSI(close, shorter RSI lookback) on chart bars
Calculation: HTF short EMA = EMA(close, shorter EMA lookback, T1), sampled on chart bars with lookahead off: prior completed T1 value before its historical close, completed value on its final chart bar, and the forming T1 value in real time
Calculation: HTF long EMA = EMA(close, longer EMA lookback, T1), sampled on chart bars with lookahead off: prior completed T1 value before its historical close, completed value on its final chart bar, and the forming T1 value in real time
Calculation: Uptrend filter = ADX(DMI lookback, DMI lookback) > trend ADX threshold AND +DI(DMI lookback) > -DI(DMI lookback) AND HTF short EMA > HTF long EMA
Calculation: Downtrend filter = ADX(DMI lookback, DMI lookback) > trend ADX threshold AND -DI(DMI lookback) > +DI(DMI lookback) AND HTF short EMA < HTF long EMA
Calculation: Range filter = ADX(DMI lookback, DMI lookback) < range ADX threshold
Calculation: Body size = abs(close - open)
Calculation: Upper wick = high - max(open, close)
Calculation: Lower wick = min(open, close) - low
Calculation: Large body = Body size > ATR value * minimum-body ATR multiplier
Calculation: Bullish reversal = (Lower wick > Body size * long-wick/body ratio AND Upper wick < Body size * short-wick/body ratio AND close > (high + low) / 2) OR (close > open AND close[1] < open[1] AND close > open[1] AND open <= close[1] AND Body size > Body size[1])
Calculation: Bearish reversal = (Upper wick > Body size * long-wick/body ratio AND Lower wick < Body size * short-wick/body ratio AND close < (high + low) / 2) OR (close < open AND close[1] > open[1] AND close < open[1] AND open >= close[1] AND Body size > Body size[1])
Calculation: Volume floor = volume > Volume average
Calculation: Opening-range high = highest high of chart bars in the configured opening-range session for the current trading day, using exchange time
Calculation: Opening-range low = lowest low of chart bars in the configured opening-range session for the current trading day, using exchange time
Calculation: ORB eligibility = opening range completed AND current chart bar outside the configured opening-range session AND chart bars since the first post-session bar <= breakout-validity parameter AND no ORB signal has fired that trading day
Calculation: Latest confirmed swing high = most recent confirmed pivot high of high, using the same swing lookback on each side, held until a newer pivot high confirms
Calculation: Latest confirmed swing low = most recent confirmed pivot low of low, using the same swing lookback on each side, held until a newer pivot low confirms
Calculation: Cooldown available = chart bars since the last long or short signal that passed cooldown >= cooldown lookback; initially available
Calculation: Initial risk = ATR value on the entry bar * stop ATR multiplier
Calculation: Long first target = entry price + Initial risk * first-target R multiple
Calculation: Short first target = entry price - Initial risk * first-target R multiple
Calculation: Long second target = entry price + Initial risk * second-target R multiple
Calculation: Short second target = entry price - Initial risk * second-target R multiple
Long: Uptrend filter AND ((low <= Short EMA OR abs(close - Short EMA) < ATR value * EMA-proximity ATR multiplier) AND close > Short EMA) AND Large body AND close > open AND RVOL >= RVOL threshold AND Longer-lookback RSI < RSI upper limit AND close < Long EMA + ATR value * trend-extension ATR multiplier
Long: ORB eligibility AND close > Opening-range high AND close > open AND RVOL >= RVOL threshold AND HTF short EMA > HTF long EMA
Long: close > Trend SMA AND Shorter-lookback RSI < RSI lower threshold AND close < Short EMA AND Bullish reversal AND Volume floor
Long: Cooldown available AND Uptrend filter AND close crosses above VWAP value AND close > open AND Volume floor AND Longer-lookback RSI < RSI upper limit
Long: Cooldown available AND Range filter AND close < VWAP value - ATR value * VWAP-deviation ATR multiplier AND Bullish reversal AND Volume floor
Long: Cooldown available AND the previous chart bar had low below its latest confirmed swing low and close above that level AND close > open AND close > Latest confirmed swing low AND Volume floor
Short: Downtrend filter AND ((high >= Short EMA OR abs(close - Short EMA) < ATR value * EMA-proximity ATR multiplier) AND close < Short EMA) AND Large body AND close < open AND RVOL >= RVOL threshold AND Longer-lookback RSI > RSI lower limit AND close > Long EMA - ATR value * trend-extension ATR multiplier
Short: ORB eligibility AND close < Opening-range low AND close < open AND RVOL >= RVOL threshold AND HTF short EMA < HTF long EMA
Short: close < Trend SMA AND Shorter-lookback RSI > RSI upper threshold AND close > Short EMA AND Bearish reversal AND Volume floor
Short: Cooldown available AND Downtrend filter AND close crosses below VWAP value AND close < open AND Volume floor AND Longer-lookback RSI > RSI lower limit
Short: Cooldown available AND Range filter AND close > VWAP value + ATR value * VWAP-deviation ATR multiplier AND Bearish reversal AND Volume floor
Short: Cooldown available AND the previous chart bar had high above its latest confirmed swing high and close below that level AND close < open AND close < Latest confirmed swing high AND Volume floor
Exit: Long, high >= Long second target OR (Long first target has been reached since entry AND low <= entry price) OR (Long first target has not been reached through this bar AND low <= entry price - Initial risk) OR bars held >= time-stop lookback
Exit: Short, low <= Short second target OR (Short first target has been reached since entry AND high >= entry price) OR (Short first target has not been reached through this bar AND high >= entry price + Initial risk) OR bars held >= time-stop lookback