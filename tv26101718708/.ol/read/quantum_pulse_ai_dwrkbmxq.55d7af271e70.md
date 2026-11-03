Calculation: k-NN bullish and bearish confidence = form a feature vector from (shorter-lookback moving average − longer-lookback moving average) / (2 × ATR), (close − daily anchored VWAP) / (3 × ATR), (Hull moving average − its value two bars earlier) / (1.5 × ATR), and min(1, volume / 20-bar average volume / 3); clamp the first three features to [−1, 1]. Compare each current vector with vectors from prior bars in the memory lookback using Euclidean distance, and select the k nearest. Label each neighbor bullish when its close four bars after its feature bar is greater than its close eight bars after it, bearish when less, otherwise neutral. Each confidence is the corresponding vote count divided by k, including neutral neighbors in the denominator.
Long: shorter-lookback moving average > longer-lookback moving average
Short: shorter-lookback moving average < longer-lookback moving average
Long: close > daily anchored VWAP AND shorter-lookback moving average > daily anchored VWAP
Short: close < daily anchored VWAP AND shorter-lookback moving average < daily anchored VWAP
Long: Hull moving average > its value two bars earlier AND close > Hull moving average
Short: Hull moving average < its value two bars earlier AND close < Hull moving average
Long: Supertrend direction is bullish
Short: Supertrend direction is bearish
Long: shorter-lookback moving average crosses above longer-lookback moving average
Short: shorter-lookback moving average crosses below longer-lookback moving average
Long: shorter-lookback moving average crosses above daily anchored VWAP
Short: shorter-lookback moving average crosses below daily anchored VWAP
Long: ADX > trend-strength threshold AND bullish k-NN confidence >= confidence threshold AND close > daily anchored VWAP AND bullish k-NN state was false on the prior bar AND last emitted signal side is not long
Short: ADX > trend-strength threshold AND bearish k-NN confidence >= confidence threshold AND close < daily anchored VWAP AND bearish k-NN state was false on the prior bar AND last emitted signal side is not short
Long: AI engine disabled AND ADX > trend-strength threshold AND volume / 20-bar average volume > relative-volume threshold AND shorter-lookback moving average > longer-lookback moving average AND close > daily anchored VWAP AND shorter-lookback moving average > daily anchored VWAP AND Hull moving average > its value two bars earlier AND close > Hull moving average AND Supertrend direction is bullish AND baseline long state was false on the prior bar AND last emitted signal side is not long
Short: AI engine disabled AND ADX > trend-strength threshold AND volume / 20-bar average volume > relative-volume threshold AND shorter-lookback moving average < longer-lookback moving average AND close < daily anchored VWAP AND shorter-lookback moving average < daily anchored VWAP AND Hull moving average < its value two bars earlier AND close < Hull moving average AND Supertrend direction is bearish AND baseline short state was false on the prior bar AND last emitted signal side is not short