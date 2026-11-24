Calculation: Candle body = abs(close − open)
Calculation: Upper wick = high − max(open, close)
Calculation: Lower wick = min(open, close) − low
Calculation: Bullish engulfing = close > open AND close[1] < open[1] AND close >= open[1] AND open <= close[1] AND candle body >= candle body[1] * engulfing body ratio
Calculation: Bearish engulfing = close < open AND close[1] > open[1] AND close <= open[1] AND open >= close[1] AND candle body >= candle body[1] * engulfing body ratio
Calculation: Hammer = lower wick >= candle body * pin wick ratio AND upper wick <= candle body * opposite wick ratio AND candle body > 0
Calculation: Shooting star = upper wick >= candle body * pin wick ratio AND lower wick <= candle body * opposite wick ratio AND candle body > 0
Calculation: Bullish Day pattern = (engulfing enabled AND bullish engulfing) OR (pin bars enabled AND hammer)
Calculation: Bearish Day pattern = (engulfing enabled AND bearish engulfing) OR (pin bars enabled AND shooting star)
Calculation: Bullish structure = latest confirmed pivot high > preceding confirmed pivot high AND latest confirmed pivot low > preceding confirmed pivot low; pivots use chart bars and pivot left/right lookbacks
Calculation: Bearish structure = latest confirmed pivot high < preceding confirmed pivot high AND latest confirmed pivot low < preceding confirmed pivot low; pivots use chart bars and pivot left/right lookbacks
Calculation: Bullish Day trend = at least the trend confirmation threshold of: EMA(close, shorter EMA lookback, T1, last completed bar) > EMA(close, longer EMA lookback, T1, last completed bar); bullish structure; EMA(close, longer EMA lookback, T1, last completed bar), sampled on chart bars, > its value trend-slope lookback chart bars ago
Calculation: Bearish Day trend = at least the trend confirmation threshold of: EMA(close, shorter EMA lookback, T1, last completed bar) < EMA(close, longer EMA lookback, T1, last completed bar); bearish structure; EMA(close, longer EMA lookback, T1, last completed bar), sampled on chart bars, < its value trend-slope lookback chart bars ago
Calculation: Bullish Day pullback = lowest(low, pullback lookback) <= EMA(close, shorter EMA lookback) + ATR(ATR lookback) * EMA touch tolerance AND pullback depth >= ATR(ATR lookback) * minimum pullback depth AND pullback depth <= (highest(high, twice the pullback lookback) − lowest(low, twice the pullback lookback)) * maximum pullback fraction, where pullback depth = highest(high, pullback lookback) − lowest(low, pullback lookback)
Calculation: Bearish Day pullback = highest(high, pullback lookback) >= EMA(close, shorter EMA lookback) − ATR(ATR lookback) * EMA touch tolerance AND pullback depth >= ATR(ATR lookback) * minimum pullback depth AND pullback depth <= (highest(high, twice the pullback lookback) − lowest(low, twice the pullback lookback)) * maximum pullback fraction, where pullback depth = highest(high, pullback lookback) − lowest(low, pullback lookback)
Calculation: Day long stop = at entry, min(lowest(low, pullback lookback) − ATR(ATR lookback) * structural buffer, entry price − ATR(ATR lookback) * Day stop-floor multiplier)
Calculation: Day short stop = at entry, max(highest(high, pullback lookback) + ATR(ATR lookback) * structural buffer, entry price + ATR(ATR lookback) * Day stop-floor multiplier)
Calculation: Scalp long stop = at entry, min(lowest(low, extreme lookback) − ATR(ATR lookback) * structural buffer, entry price − ATR(ATR lookback) * Scalp stop-floor multiplier)
Calculation: Scalp short stop = at entry, max(highest(high, extreme lookback) + ATR(ATR lookback) * structural buffer, entry price + ATR(ATR lookback) * Scalp stop-floor multiplier)
Calculation: Long risk = entry price − mode-specific long stop
Calculation: Short risk = mode-specific short stop − entry price
Calculation: Long first target = at entry, Day mode: entry price + long risk * Day target risk multiple; Scalp mode: Bollinger basis(close, band lookback)
Calculation: Short first target = at entry, Day mode: entry price − short risk * Day target risk multiple; Scalp mode: Bollinger basis(close, band lookback)
Calculation: Day long second target = at entry, entry price + long risk * Day second-target risk multiple
Calculation: Day short second target = at entry, entry price − short risk * Day second-target risk multiple
Calculation: Long R:R = (long first target − entry price) / long risk when long risk > 0, else zero
Calculation: Short R:R = (entry price − short first target) / short risk when short risk > 0, else zero
Long: Day mode AND (strict-close mode disabled OR current chart bar confirmed) AND bullish Day pattern[1] AND bullish Day pullback[1] AND bullish Day trend[1] AND high > high[1] AND long R:R >= minimum accepted R:R AND chart bars since previous signal >= mode-specific minimum spacing AND signals since chart-date boundary < mode-specific signal limit
Short: Day mode AND (strict-close mode disabled OR current chart bar confirmed) AND bearish Day pattern[1] AND bearish Day pullback[1] AND bearish Day trend[1] AND low < low[1] AND short R:R >= minimum accepted R:R AND chart bars since previous signal >= mode-specific minimum spacing AND signals since chart-date boundary < mode-specific signal limit
Long: Scalp mode AND (strict-close mode disabled OR current chart bar confirmed) AND pin bars enabled AND low[1] <= Bollinger lower band(close, band lookback, deviation multiplier)[1] AND RSI(close, RSI lookback)[1] <= oversold threshold AND hammer[1] AND close > Bollinger lower band(close, band lookback, deviation multiplier) AND long R:R >= minimum accepted R:R AND chart bars since previous signal >= Scalp minimum spacing AND signals since chart-date boundary < Scalp signal limit
Short: Scalp mode AND (strict-close mode disabled OR current chart bar confirmed) AND pin bars enabled AND high[1] >= Bollinger upper band(close, band lookback, deviation multiplier)[1] AND RSI(close, RSI lookback)[1] >= overbought threshold AND shooting star[1] AND close < Bollinger upper band(close, band lookback, deviation multiplier) AND short R:R >= minimum accepted R:R AND chart bars since previous signal >= Scalp minimum spacing AND signals since chart-date boundary < Scalp signal limit
Exit: long, low <= entry-set mode-specific long stop
Exit: short, high >= entry-set mode-specific short stop
Exit: long, (Day mode AND high >= entry-set Day long first target) OR (Scalp mode AND high >= entry-set Scalp long target)
Exit: short, (Day mode AND low <= entry-set Day short first target) OR (Scalp mode AND low <= entry-set Scalp short target)
Exit: long, Day mode AND high >= entry-set Day long second target
Exit: short, Day mode AND low <= entry-set Day short second target
Exit: long, Day mode AND first target reached AND second target not reached AND close < EMA(close, trail EMA lookback)
Exit: short, Day mode AND first target reached AND second target not reached AND close > EMA(close, trail EMA lookback)