Calculation: raw stochastic = 100 * (close - lowest low over the last stochastic lookback bars including the current bar) / (highest high over the same bars - lowest low over the same bars)
Calculation: fast line = simple moving average of raw stochastic over the fast smoothing length bars
Calculation: slow line = simple moving average of fast line over the slow smoothing length bars, where slow smoothing length is independent of fast smoothing length
Calculation: reversal state = 1 if close[2] < close[1] AND close > close[1] AND fast line < slow line AND fast line > threshold; -1 if close[2] > close[1] AND close < close[1] AND fast line > slow line AND fast line < threshold; otherwise previous reversal state
Calculation: pivot = (high + low + close of the last completed pivot timeframe bar) / 3
Calculation: resistance level = 2 * pivot - low of the last completed pivot timeframe bar
Calculation: support level = 2 * pivot - high of the last completed pivot timeframe bar
Calculation: pivot state = 1 if close > resistance level; -1 if close < support level; otherwise previous pivot state
Long: reversal state == 1 AND pivot state == 1
Short: reversal state == -1 AND pivot state == -1
Exit: long, reversal state != 1 OR pivot state != 1
Exit: short, reversal state != -1 OR pivot state != -1