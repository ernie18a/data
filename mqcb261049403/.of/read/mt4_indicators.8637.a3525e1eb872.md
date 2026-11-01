Calculation: Index [0] denotes the current chart bar and [n] denotes n chart bars earlier; indicator values use the same indexing. All indicators use the chart timeframe and its current bar. Crosses above means the previous value was strictly below the previous reference and the current value is at or above the current reference; crosses below means the previous value was strictly above and the current value is at or below.
Calculation: Alligator lines are smoothed moving averages of median price, shifted forward; the jaw uses the longest period and shift, the teeth intermediate values, and the lips the shortest values. The lower Gator value is minus the absolute difference between the displayed teeth and lips.
Calculation: Upper and lower fractal values are the high and low of a confirmed fractal bar, respectively, and are zero when that bar has no corresponding fractal.
Calculation: MACD uses a shorter and a longer exponential moving average of close; its signal is a simple moving average of the MACD main line. MACD histogram is the main line minus its signal.
Calculation: Persistent direction for ADX, close EMA, RVI and stochastic main-versus-signal is the direction of the most recent qualifying comparison for that indicator, initially neutral.
Long: Acceleration/Deceleration[0] >= 0 AND Acceleration/Deceleration[0] > [1] > [2], OR Acceleration/Deceleration[0] <= 0 AND Acceleration/Deceleration[0] > [1] > [2] > [3].
Short: Acceleration/Deceleration[0] <= 0 AND Acceleration/Deceleration[0] < [1] < [2], OR Acceleration/Deceleration[0] >= 0 AND Acceleration/Deceleration[0] < [1] < [2] < [3].
Long: Accumulation/Distribution[0] >= Accumulation/Distribution[1] AND close[0] <= close[1] AND NOT (Accumulation/Distribution[0] <= Accumulation/Distribution[1] AND close[0] >= close[1]).
Short: Accumulation/Distribution[0] <= Accumulation/Distribution[1] AND close[0] >= close[1].
Long: Each Alligator line[2] <= its value[1] <= its value[0] AND upper fractal[2] >= Alligator teeth[0].
Short: Each Alligator line[2] >= its value[1] >= its value[0] AND lower fractal[2] <= Alligator teeth[0].
Long: Lower Gator[3] > lower Gator[2] > lower Gator[1] > lower Gator[0] AND NOT (each Alligator line[2] >= its value[1] >= its value[0] AND lower fractal[2] <= Alligator teeth[0]).
Short: Lower Gator[3] > lower Gator[2] > lower Gator[1] > lower Gator[0] AND each Alligator line[2] >= its value[1] >= its value[0] AND lower fractal[2] <= Alligator teeth[0].
Long: Persistent ADX direction = long; update it to long when +DI[0] > -DI[0] AND ADX[0] >= ADX threshold AND ADX[0] > ADX[1].
Short: Persistent ADX direction = short; update it to short when -DI[0] > +DI[0] AND ADX[0] >= ADX threshold AND ADX[0] > ADX[1].
Long: ATR[0] >= ATR threshold.
Long: Awesome Oscillator[2], [1] and [0] > 0 AND Awesome Oscillator[1] < [2] AND [1] < [0], OR Awesome Oscillator[1] < 0 AND [0] > 0.
Short: Awesome Oscillator[2], [1] and [0] < 0 AND Awesome Oscillator[1] > [2] AND [1] > [0], OR Awesome Oscillator[1] > 0 AND [0] < 0.
Long: Bears Power[2] < Bears Power[1] < Bears Power[0] < 0.
Short: Bulls Power[2] > Bulls Power[1] > Bulls Power[0] > 0.
Long: Close crosses above the lower Bollinger Band of close.
Short: Close crosses below the upper Bollinger Band of close.
Long: Typical-price CCI crosses above either its positive threshold or its negative threshold.
Short: Typical-price CCI crosses below either its negative threshold or its positive threshold.
Long: DeMarker crosses above its lower threshold.
Short: DeMarker crosses below its upper threshold.
Long: Close crosses above the lower envelope of a shifted simple moving average of close.
Short: Close crosses below the upper envelope of a shifted simple moving average of close.
Long: Simple-moving-average Force Index of close < 0.
Short: Simple-moving-average Force Index of close > 0.
Long: Close crosses above Ichimoku Senkou Span B AND close[0] > Senkou Span A[0].
Short: Close crosses below Ichimoku Senkou Span B AND close[0] < Senkou Span A[0].
Long: Ichimoku Tenkan-sen crosses above Kijun-sen.
Short: Ichimoku Tenkan-sen crosses below Kijun-sen.
Long: Close[1] < close[Kijun period + 1] AND close[0] >= close[Kijun period] AND close[0] is strictly between the displayed Ichimoku Senkou spans.
Short: Close[1] > close[Kijun period + 1] AND close[0] <= close[Kijun period] AND close[0] is strictly between the displayed Ichimoku Senkou spans.
Long: Money Flow Index crosses above its lower threshold.
Short: Money Flow Index crosses below its upper threshold.
Long: Persistent close EMA direction = long; update it to long when EMA[2] < EMA[1] < EMA[0].
Short: Persistent close EMA direction = short; update it to short when EMA[2] > EMA[1] > EMA[0].
Long: MACD main crosses above its signal OR MACD main crosses above zero.
Short: MACD main crosses below its signal OR MACD main crosses below zero.
Long: MACD histogram[4], [3], [2], [1] and [0] < 0 AND histogram[4] >= [3] >= [2] <= [1] <= [0].
Short: MACD histogram[4], [3], [2], [1] and [0] > 0 AND histogram[4] <= [3] <= [2] >= [1] >= [0].
Long: MACD histogram[2] <= histogram[1] <= histogram[0] AND histogram[2] < histogram[0].
Short: MACD histogram[2] >= histogram[1] >= histogram[0].
Long: Close crosses above Parabolic SAR.
Short: Close crosses below Parabolic SAR.
Long: RSI of close crosses above its lower threshold.
Short: RSI of close crosses below its upper threshold.
Long: Persistent RVI direction = long; update it to long when RVI main crosses above its signal.
Short: Persistent RVI direction = short; update it to short when RVI main crosses below its signal.
Long: Standard deviation of close around its simple moving average[2] <= its value[1] <= its value[0].
Long: Stochastic main crosses above its lower threshold AND persistent stochastic main-versus-signal direction = long; update that direction to long when the main line crosses above its signal.
Short: Stochastic main crosses below its upper threshold AND persistent stochastic main-versus-signal direction = short; update that direction to short when the main line crosses below its signal. Stochastic uses high-low range and exponential signal smoothing.
Long: Williams Percent Range crosses above its lower threshold.
Short: Williams Percent Range crosses below its upper threshold.