Calculation: EMA slope angle = atan((EMA(close) - EMA(close) a slope-lookback number of bars ago) / ((highest high - lowest low over a range lookback) / range lookback * slope lookback)) in degrees; undefined when the high-low range is zero.
Calculation: Bollinger %B = (close - lower Bollinger Band) / (upper Bollinger Band - lower Bollinger Band); use 0.5 when the band width is zero.
Calculation: Smoothed volume delta = EMA of (2 * close - high - low) / (high - low), using zero when high equals low.
Long: RSI of close > its SMA OR RSI of close > 50.
Short: RSI of close <= its SMA AND RSI of close <= 50 AND (RSI of close < its SMA OR RSI of close < 50).
Long: MACD histogram >= 0 AND previous MACD histogram is available.
Short: MACD histogram < 0 AND previous MACD histogram is available.
Long: EMA slope angle >= nonnegative reference angle OR EMA slope angle > 0.
Short: EMA slope angle < 0.
Long: Shorter-lookback moving average of OBV > longer-lookback moving average of OBV; both use the same selectable moving-average type.
Short: Shorter-lookback moving average of OBV < longer-lookback moving average of OBV; both use the same selectable moving-average type.
Long: Close > Supertrend line.
Short: Close <= Supertrend line.
Long: Close > session VWAP.
Short: Close <= session VWAP.
Long: +DI > -DI AND ADX is available.
Short: +DI <= -DI AND ADX is available.
Long: Bollinger %B >= 0.5.
Short: Bollinger %B < 0.5.
Long: Stochastic RSI K > D OR K > 50.
Short: Stochastic RSI K <= D AND K <= 50 AND (K < D OR K < 50).
Long: Smoothed volume delta > 0.
Short: Smoothed volume delta < 0.