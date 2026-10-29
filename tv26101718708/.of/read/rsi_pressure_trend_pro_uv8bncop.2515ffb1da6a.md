Calculation: RSI fast and RSI core = relative strength index of close, with the fast lookback shorter than the core lookback
Calculation: RSI moving averages = fast and slow moving averages of RSI core, with the fast lookback shorter than the slow lookback
Calculation: Pressure Composite = smoothed weighted average of RSI core, its recent-range position, z-score-normalized fast-minus-slow EMA spread, z-score-normalized short-term RSI rate of change, its Bollinger-band position, and its relative-volume-weighted average; scale each component to 0–100
Calculation: Smoothed pressure = EMA of Pressure Composite
Calculation: Pressure regime = bullish when smoothed pressure reaches the upper threshold, bearish when it reaches the lower threshold, otherwise retain the previous regime
Calculation: Pressure trail = EMA of hlc3 minus ATR times a volatility multiplier in a bullish regime, or plus that amount in a bearish regime; the multiplier increases with the absolute distance of smoothed pressure from 50
Calculation: Confirmed RSI swing pivots = RSI swing highs or lows confirmed after reversal by a minimum swing size; pair each with the price high or low on that pivot bar
Calculation: RSI divergence = compare consecutive same-side confirmed RSI swing pivots and their paired price pivots
Long: RSI fast > its upper neutral threshold
Long: RSI core > its upper neutral threshold
Long: RSI core >= upper envelope trigger
Long: RSI fast moving average >= slow moving average
Long: RSI core fast moving average >= slow moving average
Long: Pressure Composite fast moving average >= slow moving average
Long: smoothed pressure >= upper regime threshold AND close >= bullish pressure trail minus the ATR tolerance
Long: smoothed pressure <= lower regime threshold AND close > bearish pressure trail plus the ATR tolerance
Long: price pivot low < previous price pivot low AND RSI pivot low > previous RSI pivot low
Long: price pivot low > previous price pivot low AND RSI pivot low < previous RSI pivot low
Short: RSI fast < its lower neutral threshold
Short: RSI core < its lower neutral threshold
Short: RSI core <= lower envelope trigger
Short: RSI fast moving average < slow moving average
Short: RSI core fast moving average < slow moving average
Short: Pressure Composite fast moving average < slow moving average
Short: smoothed pressure <= lower regime threshold AND close <= bearish pressure trail plus the ATR tolerance
Short: smoothed pressure >= upper regime threshold AND close < bullish pressure trail minus the ATR tolerance
Short: price pivot high > previous price pivot high AND RSI pivot high < previous RSI pivot high
Short: price pivot high < previous price pivot high AND RSI pivot high > previous RSI pivot high