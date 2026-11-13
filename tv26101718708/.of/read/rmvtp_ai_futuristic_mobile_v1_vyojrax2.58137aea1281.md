Calculation: TFScore(timeframe) = computed on bars of that timeframe: w_t*T + w_m*M + w_c*C + w_v*T*V. T = sign(close - EMA(close, mid period)). M = sign(close - close n bars ago). C = +1 if (close-open)/(high-low) > c_thr, -1 if < -c_thr, else 0 (0 if high==low). V = 1 if volume/SMA(volume) >= v_hi, 0.5 if that ratio >= 1 (and < v_hi), else 0 (0 if the SMA is 0), with v_hi > 1. Weights: w_t > w_m > w_c = w_v, all positive, sum = 1.
Calculation: FinalScore = weighted sum of TFScore over five timeframes TF1<TF2<TF3<TF4<TF5 (ascending length, all higher than or equal to the chart timeframe; each uses the bar still forming, i.e. the bar of that timeframe containing the current chart bar). Weights are positive and sum to 1. They increase from TF1 to TF4, TF5 weight is below TF4 and above TF2, and TF1 has the lowest weight.
Calculation: EMA_fast, EMA_mid = EMA of close on the chart timeframe, EMA_fast period shorter than EMA_mid period.
Long: FinalScore >= S_strong (S_strong > 0) AND close > EMA_mid AND EMA_fast > EMA_mid
Short: FinalScore <= -S_strong AND close < EMA_mid AND EMA_fast < EMA_mid
Long: FinalScore > 0
Short: FinalScore < 0