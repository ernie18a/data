Calculation: Timeframe bullish bias = forming timeframe bar high > previous completed timeframe bar high AND forming timeframe bar low >= previous completed timeframe bar low; use a higher or lower timeframe than the chart timeframe, with the latest available lower-timeframe bar when applicable.
Calculation: Timeframe bearish bias = forming timeframe bar low < previous completed timeframe bar low AND forming timeframe bar high <= previous completed timeframe bar high; use a higher or lower timeframe than the chart timeframe, with the latest available lower-timeframe bar when applicable.
Calculation: Session bullish accuracy = percentage of completed bars with bullish bias whose close >= open, accumulated from the start of the data for a particular session hour or for all session hours combined. Calculate bias from each completed bar and its preceding bar on a higher or lower timeframe than the chart timeframe.
Calculation: Session bearish accuracy = percentage of completed bars with bearish bias whose close < open, accumulated from the start of the data for the same session hour or for all session hours combined. Calculate bias from each completed bar and its preceding bar on the same timeframe as session bullish accuracy.
Long: Forming timeframe bar close >= forming timeframe bar open, using a higher or lower timeframe than the chart timeframe and the latest available lower-timeframe bar when applicable.
Long: Timeframe bullish bias.
Long: Forming timeframe bar close >= its timeframe EMA, using a higher or lower timeframe than the chart timeframe and the latest available lower-timeframe bar when applicable.
Long: Forming timeframe bar close >= chart-timeframe session VWAP, using a higher or lower timeframe than the chart timeframe and the latest available lower-timeframe bar when applicable.
Long: Count of selected timeframes with bullish bias > count of selected timeframes with bearish bias.
Long: Session bullish accuracy >= session bearish accuracy + edge threshold OR session bullish accuracy is available AND session bearish accuracy is unavailable, for an individual session hour.
Long: Session bullish accuracy >= session bearish accuracy + edge threshold, for all session hours combined.
Short: Forming timeframe bar close < forming timeframe bar open, using a higher or lower timeframe than the chart timeframe and the latest available lower-timeframe bar when applicable.
Short: Timeframe bearish bias.
Short: Forming timeframe bar close < its timeframe EMA, using a higher or lower timeframe than the chart timeframe and the latest available lower-timeframe bar when applicable.
Short: Forming timeframe bar close < chart-timeframe session VWAP, using a higher or lower timeframe than the chart timeframe and the latest available lower-timeframe bar when applicable.
Short: Count of selected timeframes with bearish bias > count of selected timeframes with bullish bias.
Short: Session bearish accuracy >= session bullish accuracy + edge threshold AND session bullish accuracy < session bearish accuracy + edge threshold OR session bearish accuracy is available AND session bullish accuracy is unavailable, for an individual session hour.
Short: Session bearish accuracy >= session bullish accuracy + edge threshold AND session bullish accuracy < session bearish accuracy + edge threshold, for all session hours combined.