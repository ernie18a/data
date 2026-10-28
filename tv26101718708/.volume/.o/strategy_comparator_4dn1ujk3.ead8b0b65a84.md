Long: Always long
Short: Always short
Long: Bollinger Bands mean-reversion mode: close crosses above the lower band
Short: Bollinger Bands mean-reversion mode: close crosses below the upper band
Long: Bollinger Bands breakout mode: close > upper band
Short: Bollinger Bands breakout mode: close < lower band
Exit: long, Bollinger Bands exit-at-midline mode: close crosses above the middle band OR close crosses below the upper band
Exit: short, Bollinger Bands exit-at-midline mode: close crosses below the middle band OR close crosses above the lower band
Long: close > EMA basis + ATR × multiplier
Short: close < EMA basis − ATR × multiplier
Long: fast SMA >= slow SMA
Short: fast SMA < slow SMA
Long: MACD line >= signal line
Short: MACD line < signal line
Long: close > close N bars ago
Short: close < close N bars ago
Calculation: Donchian channel = highest high and lowest low over the lookback, excluding the current bar
Long: high > Donchian channel upper band
Short: low < Donchian channel lower band
Long: RSI crosses above the lower threshold
Short: RSI crosses below the upper threshold
Long: RSI > upper threshold
Short: RSI < lower threshold
Exit: long, RSI exit-at-threshold mode: RSI crosses above the upper threshold OR crosses below the upper threshold
Exit: short, RSI exit-at-threshold mode: RSI crosses below the lower threshold OR crosses above the lower threshold
Calculation: Random Walk Index directional score = (current high − low N bars ago − current high N bars ago + current low) / (range N bars ago × sqrt(N))
Long: fast Random Walk Index score > 0 AND slow score >= 0
Short: fast Random Walk Index score < 0 AND slow score <= 0
Long: current bar is an outside bar AND close > open
Short: current bar is an outside bar AND close < open
Long: close has risen for at least N consecutive bars
Short: close has fallen for at least N consecutive bars
Long: Supertrend direction is up
Short: Supertrend direction is down
Calculation: Composite rating score = average of the moving-average rating and oscillator rating; each moving-average rating is +1 when close is above its SMA/EMA, −1 when below, otherwise 0 (SMA and EMA lookbacks 10, 20, 30, 50, 100, 200; HMA 9; VWMA 20; plus Ichimoku rating); moving-average rating is their mean. Oscillator rating is the mean of RSI(14), Stochastic(14), CCI(20), ADX/DI(14), Awesome Oscillator(5,34), momentum(10), MACD(12,26,9), Stochastic RSI(14,3,3), Williams %R(14), Bulls/Bears Power(EMA 13), and Ultimate Oscillator(7,14,28) ratings, each assigned +1, −1, or 0 by its respective oversold/bullish or overbought/bearish conditions
Long: Composite rating score > threshold
Short: Composite rating score < −threshold
Long: close crosses above Parabolic SAR
Short: close crosses below Parabolic SAR
Long: slow stochastic %K crosses above %D while %K < oversold threshold
Short: slow stochastic %K crosses below %D while %K > overbought threshold
Calculation: Cumulative wick imbalance = sum over the lookback of (upper wick − lower wick) / (ATR × multiplier); upper and lower wicks are measured from the candle body to the respective high and low
Long: Cumulative wick imbalance > threshold
Short: Cumulative wick imbalance < −threshold
Exit: long, Cumulative wick imbalance crosses zero in either direction
Exit: short, Cumulative wick imbalance crosses zero in either direction