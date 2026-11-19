Calculation: log price = natural logarithm of close
Calculation: RSI value = RSI(log price, RSI lookback)
Calculation: MACD line and signal = MACD(log price, shorter EMA lookback, longer EMA lookback, signal EMA lookback)
Calculation: KST value and signal = KST(log price, four ROC lookbacks ordered shortest to longest, each with its own SMA smoothing lookback, weighted 1:2:3:4) and SMA(KST value, KST signal smoothing lookback)
Calculation: Trend SMAs = SMA(close, shorter lookback) and SMA(close, longer lookback), calculated on T1 bars using the still-forming T1 bar and sampled on each chart bar
Long: first chart bar of each uninterrupted run where the shorter Trend SMA > the longer Trend SMA AND RSI value > SMA(RSI value, RSI smoothing lookback) AND MACD line > MACD signal AND KST value > KST signal AND KST value < 0
Short: first chart bar of each uninterrupted run where the shorter Trend SMA < the longer Trend SMA AND RSI value < SMA(RSI value, RSI smoothing lookback) AND MACD line < MACD signal AND KST value < KST signal AND KST value > 0