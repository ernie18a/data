Calculation: Standard Range Filter bullish = source > Range Filter(source, range period, multiplier) AND the filter has risen since its last fall
Calculation: Standard Range Filter bearish = source < Range Filter(source, range period, multiplier) AND the filter has fallen since its last rise
Calculation: DW Range Filter bullish = DW Range Filter direction is rising
Calculation: DW Range Filter bearish = DW Range Filter direction is falling
Calculation: Rational quadratic kernel bullish = Rational quadratic kernel regression(source, lookback, relative weighting, start bar) > its prior value
Calculation: Rational quadratic kernel bearish = Rational quadratic kernel regression(source, lookback, relative weighting, start bar) < its prior value
Calculation: DMI bullish = +DI > -DI AND ADX satisfies the selected ADX mode and threshold
Calculation: DMI bearish = -DI > +DI AND ADX satisfies the selected ADX mode and threshold
Calculation: Trendline breakout bullish = close crosses above the descending pivot-high trendline within the signal-expiry lookback
Calculation: Trendline breakout bearish = close crosses below the ascending pivot-low trendline within the signal-expiry lookback
Calculation: Range Detector bullish = close > detected range high
Calculation: Range Detector bearish = close < detected range low
Calculation: Heiken-Ashi Candlestick Oscillator bullish = oscillator > 0
Calculation: Heiken-Ashi Candlestick Oscillator bearish = oscillator < 0
Calculation: Donchian Trend Ribbon bullish = close > prior Donchian high, retaining the prior direction otherwise
Calculation: Donchian Trend Ribbon bearish = close < prior Donchian low, retaining the prior direction otherwise
Calculation: ROC bullish = ROC(source, lookback) > 0
Calculation: ROC bearish = ROC(source, lookback) < 0
Calculation: TDFI bullish = TDFI(price, its separate lookback and smoothing parameters) > upper filter
Calculation: TDFI bearish = TDFI(price, its separate lookback and smoothing parameters) < lower filter
Calculation: DPO bullish = DPO(close, lookback, centered setting) > 0
Calculation: DPO bearish = DPO(close, lookback, centered setting) < 0
Calculation: Two-EMA bullish = fast EMA crosses above slow EMA, or the selected lookback mode detects that cross at its lookback and fast EMA remains above slow EMA
Calculation: Two-EMA bearish = fast EMA crosses below slow EMA, or the selected lookback mode detects that cross at its lookback and fast EMA remains below slow EMA
Calculation: Three-EMA bullish = fastest EMA > middle EMA > slowest EMA
Calculation: Three-EMA bearish = fastest EMA < middle EMA < slowest EMA
Calculation: Chandelier Exit bullish = Chandelier Exit direction is long
Calculation: Chandelier Exit bearish = Chandelier Exit direction is short
Calculation: Stochastic bullish = smoothed %K crosses above %D, with the selected option's oversold restriction if enabled, or %K > %D in the direction mode
Calculation: Stochastic bearish = smoothed %K crosses below %D, with the selected option's overbought restriction if enabled, or %K < %D in the direction mode
Calculation: Vortex bullish = +VI > -VI in simple mode, or the selected advanced bullish Vortex conditions hold
Calculation: Vortex bearish = +VI < -VI in simple mode, or the selected advanced bearish Vortex conditions hold
Calculation: STC bullish = STC >= upper band
Calculation: STC bearish = STC <= lower band
Calculation: Wolfpack bullish = (fast EMA(close) - slow EMA(close)) * 1.001 > 0
Calculation: Wolfpack bearish = (fast EMA(close) - slow EMA(close)) * 1.001 < 0
Calculation: B-Xtrender bullish = short-term smoothed trend is rising in short-term mode; otherwise it is rising AND short-term trend is positive and rising AND long-term trend is positive and rising
Calculation: B-Xtrender bearish = short-term smoothed trend is falling in short-term mode; otherwise it is falling AND short-term trend is negative and falling AND long-term trend is negative and falling
Calculation: Bull Bear Power Trend bullish = its bullish histogram is positive, and in follow-trend mode its trend value is at least the trend threshold
Calculation: Bull Bear Power Trend bearish = its bearish histogram is negative, and in follow-trend mode its trend value is at most the negative trend threshold
Calculation: QQE bullish = selected QQE line or bar condition is bullish
Calculation: QQE bearish = selected QQE line or bar condition is bearish
Calculation: MACD bullish = MACD > signal line, and in zero-line mode MACD > 0
Calculation: MACD bearish = MACD < signal line, and in zero-line mode MACD < 0
Calculation: TSI bullish = TSI > signal line, and in zero-line mode TSI > signal line AND TSI > 0
Calculation: TSI bearish = TSI < signal line, and in zero-line mode TSI < signal line AND TSI < 0
Calculation: RSI bullish = RSI > its moving average, RSI crosses upward out of the oversold level, or RSI > its selected level, according to the selected mode
Calculation: RSI bearish = RSI < its moving average, RSI crosses downward out of the overbought level, or RSI < its selected level, according to the selected mode
Calculation: Chaikin Money Flow bullish = Chaikin Money Flow > 0
Calculation: Chaikin Money Flow bearish = Chaikin Money Flow < 0
Calculation: Volatility Oscillator bullish = close - open > standard deviation(close - open, lookback)
Calculation: Volatility Oscillator bearish = close - open < -standard deviation(close - open, lookback)
Calculation: SSL Channel bullish = SSL up line > SSL down line
Calculation: SSL Channel bearish = SSL up line < SSL down line
Calculation: Awesome Oscillator bullish = AO > 0 in zero-line mode, AC > its prior value AND AC > 0 in AC zero-line mode, or AC > its prior value in AC momentum mode
Calculation: Awesome Oscillator bearish = AO < 0 in zero-line mode, AC < its prior value AND AC < 0 in AC zero-line mode, or AC < its prior value in AC momentum mode
Calculation: Supertrend bullish = Supertrend direction is up
Calculation: Supertrend bearish = Supertrend direction is down
Calculation: Half Trend bullish = Half Trend direction is up
Calculation: Half Trend bearish = Half Trend direction is down
Calculation: Waddah Attar Explosion bullish = positive MACD change times sensitivity > Bollinger Band width AND Bollinger Band width and positive MACD change exceed the dead zone
Calculation: Waddah Attar Explosion bearish = absolute negative MACD change times sensitivity > Bollinger Band width AND Bollinger Band width and that absolute change exceed the dead zone
Calculation: Hull Suite bullish = Hull value > its value two bars ago
Calculation: Hull Suite bearish = Hull value < its value two bars ago
Calculation: BB Oscillator bullish = selected entering-band or exiting-band bullish conditions hold
Calculation: BB Oscillator bearish = selected entering-band or exiting-band bearish conditions hold
Calculation: Ichimoku bullish = conversion line > base line AND leading span A > leading span B AND close exceeds both spans at the displaced comparison and both spans 50 bars ago
Calculation: Ichimoku bearish = conversion line < base line AND leading span A < leading span B AND close is below both spans at the displaced comparison and both spans 50 bars ago
Calculation: VWAP bullish = close > VWAP
Calculation: VWAP bearish = close < VWAP
Calculation: SuperIchi bullish = Tenkan > Kijun AND Senkou A > Senkou B AND close exceeds both spans at the displaced comparison and both spans 50 bars ago
Calculation: SuperIchi bearish = Tenkan < Kijun AND Senkou A < Senkou B AND close is below both spans at the displaced comparison and both spans 50 bars ago
Calculation: CCI bullish = CCI > upper level
Calculation: CCI bearish = CCI < lower level
Calculation: McGinley bullish = close > McGinley Dynamic
Calculation: McGinley bearish = close < McGinley Dynamic
Calculation: EMA filter bullish = close > EMA(close, filter lookback)
Calculation: EMA filter bearish = close < EMA(close, filter lookback)
Calculation: RSI moving-average direction bullish = RSI moving average >= its prior value
Calculation: RSI moving-average direction bearish = RSI moving average <= its prior value
Calculation: RSI limit bullish = RSI >= long limit
Calculation: RSI limit bearish = RSI <= short limit
Calculation: RSI moving-average limit bullish = RSI moving average >= long limit
Calculation: RSI moving-average limit bearish = RSI moving average <= short limit
Calculation: Parabolic SAR bullish = close > Parabolic SAR
Calculation: Parabolic SAR bearish = close < Parabolic SAR
Calculation: Choppiness filter = Choppiness Index < threshold
Calculation: Damiani filter = volatility ratio > threshold, with the selected threshold mode's additional condition
Calculation: Volume filter in volume-above-average mode = volume > SMA(volume, lookback) for both directions
Calculation: Volume filter in simple mode bullish = up volume > prior up volume
Calculation: Volume filter in simple mode bearish = down volume < prior down volume
Calculation: Volume filter in delta mode bullish = volume delta > 0 AND volume delta > prior volume delta
Calculation: Volume filter in delta mode bearish = volume delta < 0 AND volume delta < prior volume delta
Calculation: Long stop = most recent valid chart-bar pivot low; otherwise the most recent valid pivot low calculated on T1; otherwise close minus ATR(close, 14) times its multiplier when ATR fallback is enabled; otherwise close * (1 - fallback fraction)
Calculation: Short stop = most recent valid chart-bar pivot high; otherwise the most recent valid pivot high calculated on T1; otherwise close plus ATR(close, 14) times its multiplier when ATR fallback is enabled; otherwise close * (1 + fallback fraction)
Calculation: Long target = entry price + (entry price - long stop) * reward-risk parameter
Calculation: Short target = entry price - (short stop - entry price) * reward-risk parameter
Calculation: Selected leading bullish condition = the chosen leading mode's bullish condition: Range Filter, DMI, Rational Quadratic Kernel, Trendline Breakout, Range Detector, Heiken-Ashi Candlestick Oscillator, Donchian Trend Ribbon, ROC, TDFI, DPO, Two-EMA, Three-EMA, Chandelier Exit, Stochastic, Vortex, STC, Wolfpack, B-Xtrender, Bull Bear Power Trend, QQE, MACD, TSI, RSI, Chaikin Money Flow, Volatility Oscillator, SSL Channel, Awesome Oscillator, Supertrend, Half Trend, Waddah Attar Explosion, Hull Suite, BB Oscillator, Ichimoku, VWAP, SuperIchi, or CCI
Calculation: Selected leading bearish condition = the chosen leading mode's bearish condition, except the QQE leading mode uses the QQE bullish condition
Long: selected leading bullish condition AND every enabled long confirmation condition AND leading-long expiry counter <= signal-expiry parameter AND (alternate-signal mode is disabled OR the prior setup state is short)
Short: selected leading bearish condition AND every enabled short confirmation condition AND leading-short expiry counter <= signal-expiry parameter AND (alternate-signal mode is disabled OR the prior setup state is long)
Long: Supertrend direction changes from down to up
Short: Supertrend direction changes from up to down
Long: STC >= upper band
Short: STC <= lower band
Exit: long, low <= long stop OR high >= long target
Exit: short, high >= short stop OR low <= short target