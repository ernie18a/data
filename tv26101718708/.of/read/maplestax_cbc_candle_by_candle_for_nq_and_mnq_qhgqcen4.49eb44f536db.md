Calculation: CBC state = Start bearish. On each bar, change to bearish if the prior state is bullish AND close < prior bar low; change to bullish if the prior state is bearish AND close > prior bar high; otherwise retain the prior state. Calculate independently on the chart timeframe and higher timeframe.
Calculation: Opening range = For each session, accumulate the highest high and lowest low of chart bars during its opening range; retain those levels until the next opening range for that session.
Long: Chart-timeframe CBC state = bullish AND prior chart-bar CBC state = bearish
Short: Chart-timeframe CBC state = bearish AND prior chart-bar CBC state = bullish
Long: Higher-timeframe CBC state of the last completed higher-timeframe bar changes from bearish to bullish; on historical bars, deliver the change at the end of the following higher-timeframe bar
Short: Higher-timeframe CBC state of the last completed higher-timeframe bar changes from bullish to bearish; on historical bars, deliver the change at the end of the following higher-timeframe bar
Long: Chart-timeframe CBC state = bullish
Short: Chart-timeframe CBC state = bearish
Long: Chart-timeframe CBC state = bullish AND CBC state of the still-forming higher-timeframe bar = bullish
Short: Chart-timeframe CBC state = bearish AND CBC state of the still-forming higher-timeframe bar = bearish
Long: Shorter-lookback EMA of close >= longer-lookback EMA of close
Short: Shorter-lookback EMA of close < longer-lookback EMA of close
Long: Shorter-lookback EMA of close >= longer-lookback EMA of close, both calculated on the still-forming higher-timeframe bar
Short: Shorter-lookback EMA of close < longer-lookback EMA of close, both calculated on the still-forming higher-timeframe bar
Long: Close > daily VWAP of typical price
Short: Close <= daily VWAP of typical price
Long: Close > long-term EMA of close
Short: Close <= long-term EMA of close
Long: Close > current session's opening-range high
Short: Close < current session's opening-range low