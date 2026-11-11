Calculation: RSI pivot low = a chart bar whose RSI is lower than or equal to RSI on each of a configurable number of preceding bars and lower than RSI on each of a configurable number of following bars; confirm it only after the following bars have closed.
Calculation: RSI pivot high = a chart bar whose RSI is higher than or equal to RSI on each of a configurable number of preceding bars and higher than RSI on each of a configurable number of following bars; confirm it only after the following bars have closed.
Calculation: Higher-timeframe running delta = sum of chart-bar volume for bars with close > open minus volume for bars with close < open since the start of the forming higher-timeframe bar.
Long: A chart-bar RSI pivot low is confirmed AND its RSI > RSI at the preceding RSI pivot low AND its low < low at the preceding RSI pivot low.
Short: A chart-bar RSI pivot high is confirmed AND its RSI < RSI at the preceding RSI pivot high AND its high > high at the preceding RSI pivot high.
Long: A new higher-timeframe bar begins AND the last completed higher-timeframe bar has close > open AND the preceding completed higher-timeframe bar has close < open AND the last completed bar's close >= the preceding bar's open AND its open <= the preceding bar's close.
Short: A new higher-timeframe bar begins AND the last completed higher-timeframe bar has close < open AND the preceding completed higher-timeframe bar has close > open AND the last completed bar's close <= the preceding bar's open AND its open >= the preceding bar's close.
Long: A new higher-timeframe bar begins AND the last completed higher-timeframe bar's lower wick > a configurable fraction of its high-low range AND its absolute close-open body < a smaller configurable fraction of its high-low range.
Short: A new higher-timeframe bar begins AND the last completed higher-timeframe bar's upper wick > a configurable fraction of its high-low range AND its absolute close-open body < a smaller configurable fraction of its high-low range.
Long: Chart-bar RSI > the midpoint of its scale.
Short: Chart-bar RSI <= the midpoint of its scale.
Long: A forming or completed higher-timeframe bar's close >= its open.
Short: A forming or completed higher-timeframe bar's close < its open.
Long: The forming higher-timeframe bar's running delta >= 0.
Short: The forming higher-timeframe bar's running delta < 0.