Calculation: Source = a selected price series derived from the available bar fields, consistently used for the EMAs and Bollinger Bands.
Calculation: Vegas EMAs = shorter- and longer-lookback EMAs of Source, calculated either on the chart timeframe or on a higher timeframe; for higher-timeframe historical bars use the last completed bar, and for a realtime bar use the still-forming bar.
Calculation: Confirmed pivot low or high = a low or high that is the corresponding extreme over specified numbers of bars on its left and right, detected on the bar that completes the right-hand window.
Calculation: Bollinger bandwidth = (upper Bollinger Band - lower Bollinger Band) / Bollinger middle band, using Source.
Calculation: Delta = volume if close > open, negative volume if close < open, otherwise zero.
Long: close > the filter EMA of Source OR close > the shorter-lookback EMA of Source in the short, Vegas, medium, or long channel.
Short: close <= the filter EMA of Source OR close <= the shorter-lookback EMA of Source in the short, Vegas, medium, or long channel.
Long: close > the longer-lookback Vegas EMA AND the shorter-lookback Vegas EMA > the longer-lookback Vegas EMA AND close > the filter EMA.
Short: close < the shorter-lookback Vegas EMA AND the shorter-lookback Vegas EMA < the longer-lookback Vegas EMA.
Long: close > the shortest-lookback SMA of close AND the shortest-lookback SMA > the middle-lookback SMA AND the middle-lookback SMA > the longest-lookback SMA.
Short: close < the shortest-lookback SMA of close AND the shortest-lookback SMA < the middle-lookback SMA AND the middle-lookback SMA < the longest-lookback SMA.
Long: close crosses above the upper Bollinger Band AND Bollinger bandwidth > the expansion threshold AND previous-bar Bollinger bandwidth >= the squeeze threshold.
Short: close crosses below the lower Bollinger Band AND Bollinger bandwidth > the expansion threshold AND previous-bar Bollinger bandwidth >= the squeeze threshold.
Long: volume > previous-bar volume.
Short: volume <= previous-bar volume.
Long: Delta > zero.
Short: Delta <= zero.
Long: a low pivot is confirmed using the order-block pivot windows.
Short: a high pivot is confirmed using the order-block pivot windows.
Long: a low pivot is confirmed using the structure pivot windows AND close > the shorter-lookback Vegas EMA AND volume > a threshold multiple of the volume SMA.
Short: a high pivot is confirmed using the structure pivot windows AND close < the longer-lookback Vegas EMA AND volume > a threshold multiple of the volume SMA.
Long: a low pivot is confirmed using the structure pivot windows AND close < the longer-lookback Vegas EMA.
Short: a high pivot is confirmed using the structure pivot windows AND close > the shorter-lookback Vegas EMA.
Long: a low pivot is confirmed using longer pivot windows than the structure pivot windows AND close > the shorter-lookback Vegas EMA.
Short: a high pivot is confirmed using longer pivot windows than the structure pivot windows AND close < the longer-lookback Vegas EMA.
Long: a low pivot is confirmed using the structure pivot windows AND close > the shorter-lookback Vegas EMA AND previous close < the previous shorter-lookback Vegas EMA.
Short: a high pivot is confirmed using the structure pivot windows AND close < the longer-lookback Vegas EMA AND previous close > the previous longer-lookback Vegas EMA.
Short: a high pivot is confirmed using the liquidity pivot windows AND no high pivot was confirmed using those windows on the previous bar.
Long: low > the high two bars earlier AND the previous bar's low <= the high three bars earlier.
Short: high < the low two bars earlier AND the previous bar's high >= the low three bars earlier.