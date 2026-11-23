Calculation: Clip(v, b) = MAX(-b, MIN(b, v))
Calculation: ZScore(v, n) = (v - SMA(v, n)) / STDEV(v, n), or 0 if STDEV(v, n) <= 0
Calculation: NNProb = sigmoid(output bias + sum_j(output weight_j * h_j)), where h_j = tanh(hidden bias_j + sum_i(hidden weight_ij * x_i)) over hidden neurons j, x1 = Clip(100 * (close - EMA(close, EMA shorter lookback)) / EMA(close, EMA shorter lookback), price bound) / price bound, x2 = Clip(100 * (EMA(close, EMA shorter lookback) - EMA(close, EMA longer lookback)) / EMA(close, EMA longer lookback), price bound) / price bound, x3 = (RSI(close, RSI lookback) - 50) / 50, x4 = Clip(ZScore(100 * ATR(ATR lookback) / close, z-score lookback), z-score bound) / z-score bound, x5 = Clip(ZScore(LN(volume / SMA(volume, volume lookback)), z-score lookback), z-score bound) / z-score bound, x6 = Clip(1000 * MACDHist(MACD shorter lookback, MACD longer lookback, MACD signal lookback) / close, MACD bound); after computing NNProb on each bar, all weights and biases take one gradient step with momentum (learning rate, momentum, L2 penalty) on binary cross-entropy of the previous bar's NNProb against label = (close > previous close), using the previous bar's x and h; initial weights are deterministic pseudo-random Xavier-uniform values and initial biases are zero
Calculation: Certainty = ABS(NNProb - 0.5) * 2
Calculation: Trained = bar index > warmup bars AND training steps > minimum training steps
Long: Trained AND Certainty > min certainty AND NNProb crosses above long threshold
Short: Trained AND Certainty > min certainty AND NNProb crosses below short threshold
Long: NNProb crosses above extreme bull level
Short: NNProb crosses below extreme bear level
Long: Trained AND NNProb > verdict long level AND Certainty > verdict certainty level
Short: Trained AND NNProb < verdict short level AND Certainty > verdict certainty level
Long: NNProb > label long level
Short: NNProb <= label short level
Long: Trained AND NNProb > 0.5
Short: Trained AND NNProb <= 0.5