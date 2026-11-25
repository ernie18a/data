Calculation: fast EMA = EMA(close, shorter lookback)
Calculation: slow EMA = EMA(close, longer lookback)
Calculation: second EMA = EMA(close, separate second-MA lookback)
Calculation: PSAR = ParabolicSAR(step parameter, maximum-step parameter)
Long: selected trading day AND signal reversal disabled AND close[0] > PSAR[0] AND close[1] < PSAR[1] AND fast EMA[0] > slow EMA[0] AND close[0] > second EMA[0]
Long: selected trading day AND signal reversal enabled AND close[0] < PSAR[0] AND close[1] > PSAR[1] AND fast EMA[0] < slow EMA[0] AND close[0] < second EMA[0]
Short: selected trading day AND signal reversal disabled AND close[0] < PSAR[0] AND close[1] > PSAR[1] AND fast EMA[0] < slow EMA[0] AND close[0] < second EMA[0]
Short: selected trading day AND signal reversal enabled AND close[0] > PSAR[0] AND close[1] < PSAR[1] AND fast EMA[0] > slow EMA[0] AND close[0] > second EMA[0]