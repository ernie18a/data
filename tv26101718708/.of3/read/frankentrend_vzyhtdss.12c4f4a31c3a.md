Calculation: MACD state = 1 when MACD(close, fast lookback, slow lookback) > SMA(MACD(close, fast lookback, slow lookback), signal lookback), -1 when it is lower, otherwise the prior MACD state (0 if unavailable)
Calculation: Upward-cross age = bars since close crosses above Supertrend(ATR lookback, multiplier) on chart bars
Calculation: Downward-cross age = bars since close crosses below Supertrend(ATR lookback, multiplier) on chart bars
Calculation: Adjusted downward-cross age = downward-cross age + 1 when upward-cross age = downward-cross age and close > Supertrend(ATR lookback, multiplier), otherwise downward-cross age
Calculation: Price move = 1 when close > close[1], -1 when close < close[1], otherwise 0
Calculation: Direction = price move when price move != 0 and price move != price move[1], otherwise prior direction (0 if unavailable)
Calculation: Wave = direction when direction != prior wave and (rising(close, trend lookback) or falling(close, trend lookback)), otherwise prior wave (0 if unavailable)
Calculation: Wave volume = prior wave volume + volume when wave = prior wave, otherwise volume (0 if unavailable)
Calculation: Up-wave volume = wave volume when wave = 1, otherwise 0
Calculation: Down-wave volume = 0 when wave = 1, -wave volume when wave = -1, otherwise wave volume
Long: MACD state > 0
Short: MACD state < 0
Long: Williams Vix Fix(close, low, lookback) >= SMA(Williams Vix Fix(close, low, lookback), band lookback) + deviation multiplier * standard deviation(Williams Vix Fix(close, low, lookback), band lookback) OR Williams Vix Fix(close, low, lookback) >= highest(Williams Vix Fix(close, low, lookback), percentile lookback) * percentile
Long: cross(Up-wave volume, Down-wave volume) AND Up-wave volume > Down-wave volume
Short: cross(Up-wave volume, Down-wave volume)
Long: Upward-cross age < Adjusted downward-cross age AND position size < position limit AND (Williams Vix Fix(close, low, lookback) >= SMA(Williams Vix Fix(close, low, lookback), band lookback) + deviation multiplier * standard deviation(Williams Vix Fix(close, low, lookback), band lookback) OR Williams Vix Fix(close, low, lookback) >= highest(Williams Vix Fix(close, low, lookback), percentile lookback) * percentile)
Long: Upward-cross age < Adjusted downward-cross age AND MACD(close, fast lookback, slow lookback) crosses above SMA(MACD(close, fast lookback, slow lookback), signal lookback) AND close < VWMA((open + high + low + close) / 4, lookback) - deviation AND (Williams Vix Fix(close, low, lookback) >= SMA(Williams Vix Fix(close, low, lookback), band lookback) + deviation multiplier * standard deviation(Williams Vix Fix(close, low, lookback), band lookback) OR Williams Vix Fix(close, low, lookback) >= highest(Williams Vix Fix(close, low, lookback), percentile lookback) * percentile)
Exit: long, Williams Vix Fix(close, low, lookback) < SMA(Williams Vix Fix(close, low, lookback), band lookback) + deviation multiplier * standard deviation(Williams Vix Fix(close, low, lookback), band lookback) AND Williams Vix Fix(close, low, lookback) < highest(Williams Vix Fix(close, low, lookback), percentile lookback) * percentile AND ((high < high[1] AND low < low[1]) OR close < low[1])
Exit: long, open profit < -loss threshold
Exit: long, Point & Figure close(close, traditional box size, reversal amount, current/forming chart-timeframe bar) <= Point & Figure close(close, traditional box size, reversal amount)[1]