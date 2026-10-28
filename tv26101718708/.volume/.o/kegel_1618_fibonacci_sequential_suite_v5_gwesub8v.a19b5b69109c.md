Calculation: Confirmed pivot high/low = a high/low greater/less than the highs/lows of the configured number of bars on both sides; use only after the bars on both sides have completed
Calculation: Fibonacci price level = swing start + (swing end − swing start) × configured ratio
Calculation: Bullish/bearish sequential count = consecutive bars whose close is respectively above/below the close four bars earlier; reset on the opposite comparison or equality
Calculation: Average volume = simple moving average of volume over the configured lookback
Calculation: Doji = candle range > 0 AND absolute(close − open) / (high − low) < configured maximum body fraction
Long: close crosses above the latest confirmed pivot high
Short: close crosses below the latest confirmed pivot low
Long: low < latest confirmed pivot low AND close > latest confirmed pivot low AND low is the lowest low over twice the pivot lookback
Short: high > latest confirmed pivot high AND close < latest confirmed pivot high AND high is the highest high over twice the pivot lookback
Long: close > close four bars earlier for 6, 9, or 11 consecutive bars, OR close > close four bars earlier for 7, 8, 9, or 13 consecutive bars
Short: close < close four bars earlier for 6, 9, or 11 consecutive bars, OR close < close four bars earlier for 7, 8, 9, or 13 consecutive bars
Long: close > the low of a bullish 13-count bar
Short: close < the high of a bearish 13-count bar
Long: low > high two bars earlier
Short: high < low two bars earlier
Long: a bullish structure break AND a bearish candle occurs within the prior 1 to 15 bars after the broken swing low
Short: a bearish structure break AND a bullish candle occurs within the prior 1 to 15 bars after the broken swing high
Long: a bullish structure break AND volume > average volume × configured spike multiplier
Short: a bearish structure break AND volume > average volume × configured spike multiplier
Long: volume one bar earlier > current average volume × configured multiplier AND close one bar earlier > open one bar earlier AND current candle is a doji
Short: volume one bar earlier > current average volume × configured multiplier AND close one bar earlier < open one bar earlier AND current candle is a doji
Long: a bullish structure-break setup is active, price has reached the 1.618 extension and returned to the swing end, no position is open, low <= the configured entry Fibonacci level, AND (a bullish liquidity sweep occurred within the prior 20 bars OR a sweep is not required)
Short: a bearish structure-break setup is active, price has reached the 1.618 extension and returned to the swing end, no position is open, high >= the configured entry Fibonacci level, AND (a bearish liquidity sweep occurred within the prior 20 bars OR a sweep is not required)
Exit: long, high >= the configured take-profit Fibonacci level OR low <= the swing start
Exit: short, low <= the configured take-profit Fibonacci level OR high >= the swing start