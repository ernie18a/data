Calculation: TFScore = for one bar series, score = w1*sign(close - EMA(close, main length)) + w2*sign(close - close[momentum lookback]) + w3*candleScore + w4*sign(close - EMA(close, main length))*volScore, with w1..w4 positive and w1 the largest. candleScore = +1 if (close-open)/(high-low) > t, -1 if < -t, else 0 (0 if high=low), with t > 0. volScore = 1 if volume/SMA(volume) >= a high threshold, 0.5 if volume/SMA(volume) >= 1, else 0 (high threshold > 1).
Calculation: FinalScore = weighted sum of TFScore computed on five fixed timeframes T1<T2<T3<T4<T5, each independent of the chart timeframe. For each timeframe, use the bar containing the current chart bar, still forming and including the current chart bar's data. Weights are positive and sum to 1. The weight is smallest on T1 and largest on T4, and the weight of T5 is below that of T4 and above that of T3.
Calculation: EMAfast, EMAmain = EMA of close on the chart timeframe, with EMAfast using a shorter length than EMAmain.
Long: FinalScore >= strong threshold AND close > EMAmain AND EMAfast > EMAmain
Long: FinalScore > 0
Short: FinalScore <= -strong threshold AND close < EMAmain AND EMAfast < EMAmain
Short: FinalScore < 0