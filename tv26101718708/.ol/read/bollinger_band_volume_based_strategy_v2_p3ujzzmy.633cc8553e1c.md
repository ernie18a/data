Calculation: Buying volume = 0 when high = low; otherwise volume × (close − low) / (high − low)
Calculation: Selling volume = 0 when high = low; otherwise volume × (high − close) / (high − low)
Calculation: Daily average volume = SMA of chart-bar volume
Calculation: Bollinger upper bands = SMA(close, lookback) + multiplier × standard deviation(close, lookback), using the same lookback and multipliers in ascending order for the 1, 1.5, and 2 standard-deviation bands
Calculation: Candle position condition = (low + 1 − (prior bar open − prior bar close) / (prior bar high − prior bar low)) < open
Long: Supertrend turns bullish
Long: Buying volume > selling volume AND buying volume > daily average volume AND open > the 2-standard-deviation Bollinger upper band AND Supertrend is bullish AND candle position condition
Short: Supertrend turns bearish
Short: low < SMA(close, medium lookback) AND low < lower Bollinger band at 1 standard deviation AND close < lower Bollinger band at 1.5 standard deviations AND SMA(close, long lookback) crosses below SMA(close, longer lookback) AND selling volume > buying volume AND selling volume > daily average volume
Short: SMA(close, very short lookback) < SMA(close, short lookback) AND SMA(close, short lookback) < SMA(close, medium lookback) AND SMA(close, medium lookback) < SMA(close, long lookback) AND selling volume > buying volume AND selling volume > daily average volume AND Supertrend is bearish AND high < SMA(close, medium lookback) AND close < lower Bollinger band at 1 standard deviation AND high < lower Bollinger band at 1.5 standard deviations AND RSI(14) > 30
Exit: Long, RSI(14) > 80 AND close > entry price × 1.004
Exit: Long, close < entry price × 0.91
Exit: Long, open > the 2-standard-deviation Bollinger upper band AND close > entry price × 1.004
Exit: Long, Supertrend is bearish
Exit: Short, RSI(14) < 20 AND close < entry price × 0.996
Exit: Short, high < the 2-standard-deviation Bollinger lower band AND close < entry price × 0.996
Exit: Short, Supertrend is bullish
Exit: Short, open < the 2-standard-deviation Bollinger lower band AND close < entry price × 0.996