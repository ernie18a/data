Long: RSI(close, 2) <= 20 AND close >= SMA(close, 200) AND EMA(close, 20) != 0
Short: RSI(close, 2) >= 80 AND close <= SMA(close, 200) AND EMA(close, 80) != 0
Exit: long, EMA(close, 80) != 0 AND RSI(close, 2) >= 80
Exit: short, low <= EMA(close, 20) AND RSI(close, 2) <= 10
Exit: long or short, price reaches the configured take-profit or stop-loss distance from entry price, or the configured trailing-stop condition is met
Long: RSI(close, lookback) <= oversold threshold on both the current bar and previous bar AND volume on each of those bars >= volume on its preceding bar
Short: RSI(close, lookback) >= overbought threshold on both the current bar and previous bar AND volume on each of those bars >= volume on its preceding bar
Calculation: MACD histogram = (SMA(close, fast lookback) - SMA(close, slow lookback)) - SMA(MACD, signal lookback)
Long: SMA(close, slow lookback) > SMA(close, very-long lookback) AND MACD histogram crosses above 0 AND MACD > 0 AND SMA(close, fast lookback) > SMA(close, slow lookback) AND close from one slow-lookback ago > SMA(close, very-long lookback)
Short: SMA(close, slow lookback) < SMA(close, very-long lookback) AND MACD histogram crosses below 0 AND MACD < 0 AND SMA(close, fast lookback) < SMA(close, slow lookback) AND close from one slow-lookback ago < SMA(close, very-long lookback)
Long: close > fast, slow, and very-long SMA AND slow SMA is rising
Short: close < fast, slow, and very-long SMA AND slow SMA is falling
Long: fast SMA > slow SMA AND very-long SMA is rising AND close > slow SMA
Short: fast SMA < slow SMA AND very-long SMA is falling AND close < slow SMA
Long: very-long SMA is rising
Short: very-long SMA is falling
Long: EMA(close, 12) - EMA(close, 26) is greater than its value on the previous bar
Short: EMA(close, 12) - EMA(close, 26) is less than or equal to its value on the previous bar
Long: close > EMA(close, lookback) AND (low <= EMA(close, lookback) AND open > EMA(close, lookback) OR open < EMA(close, lookback) AND close > EMA(close, lookback))
Short: close < EMA(close, lookback) AND (high >= EMA(close, lookback) AND open < EMA(close, lookback) OR open > EMA(close, lookback) AND close < EMA(close, lookback))
Long: bullish engulfing pattern, where current close-open > -2 × previous close-open AND previous close-open < 0 AND current close-open > 0 AND close-open two bars ago < 0
Short: bearish engulfing pattern, where -(current close-open) > 2 × previous close-open AND previous close-open > 0 AND current close-open < 0 AND close-open two bars ago > 0
Long: doji-up pattern, where (close-open)×10 < abs(close-open) AND high-low > abs(close-open)×10 AND previous close-open < 0
Short: doji-down pattern, where (close-open)×10 < abs(close-open) AND high-low > abs(close-open)×10 AND previous close-open > 0
Long: bullish dragonfly doji, where (close-open)×10 < abs(close-open) AND lower wick×10 < abs(close-open) AND upper wick > 5×abs(close-open) AND previous close-open < 0
Short: bearish dragonfly doji, where (close-open)×10 < abs(close-open) AND upper wick×10 < abs(close-open) AND lower wick > 5×abs(close-open) AND previous close-open > 0
Long: three-up pattern, where current and prior two close-open values each exceed twice their respective absolute values
Short: same-down pattern, where (close-open)×2 < abs(close-open) AND high-low > 10×abs(close-open) AND previous close-open > 0
Calculation: Bullish/bearish doji-harami = current candle is a doji wholly inside the previous candle's body; for bullish, the previous candle is bearish and the current candle is bullish or near-doji; for bearish, the previous candle is bullish and the current candle is bearish or near-doji. Use Heikin-Ashi OHLC on the chart timeframe; require each selected prior candle's body to exceed the configured minimum size when nonzero, and require current body and both wicks to satisfy the configured doji proportions.
Long: bullish doji-harami OR bullish doji, with the configured prior-bar count bearish
Short: bearish doji-harami OR bearish doji, with the configured prior-bar count bullish
Calculation: Isolated-bottom marker = a low two bars ago is below the lows now, one, three, and four bars ago AND the high now exceeds the greater of the highs two and three bars ago, while the previous high is below that greater high; OR the previous low is below the lows now, two, and three bars ago AND the high now exceeds the greater of the high two bars ago and previous high
Calculation: Isolated-peak marker = a high two bars ago is above the highs now, one, three, and four bars ago AND the low now is below the lesser of the lows two and three bars ago, while the previous low is above that lesser low; OR the previous high is above the highs now, two, and three bars ago AND the low now is below the lesser of the low two bars ago and previous low
Long: isolated-bottom marker
Short: isolated-peak marker
Calculation: PPO = SMA(100 × (EMA(close, fast lookback) - EMA(close, slow lookback)) / EMA(close, slow lookback), smoothing lookback)
Calculation: Bullish PPO divergence = a price trough is lower than the prior qualifying trough while its PPO trough is higher, or PPO and price trough divergences meet the script's short-term or long-term trough filters; qualifying troughs are local minima, with equal-low plateaus allowed, and short-term price/oscillator pivots must be within 3 bars and price extrema within a 4-bar filter; long-term comparisons use the configured lookback.
Calculation: Bearish PPO divergence = a price peak is higher than the prior qualifying peak while its PPO peak is lower, or PPO and price peak divergences meet the script's short-term or long-term peak filters; qualifying peaks are local maxima, with equal-high plateaus allowed, and short-term price/oscillator pivots must be within 3 bars and price extrema within a 4-bar filter; long-term comparisons use the configured lookback.
Long: bullish PPO divergence
Short: bearish PPO divergence
Calculation: Oversold/overbought marker uses RSI(close, lookback) <= oversold threshold / >= overbought threshold, respectively, and volume on the marked bar >= volume on the preceding bar.
Calculation: Bullish cloud color = Ichimoku leading span A >= leading span B; bearish cloud color = leading span A < leading span B, using chart-timeframe bars.
Long: bullish cloud color
Short: bearish cloud color