Calculation: QWMA(series, N) = sum over k=0..N-1 of w_k*series[t-k] / sum over k=0..N-1 of w_k, with w_k=(N-k)^speed (speed is a fixed non-negative exponent shared by all QWMA calculations; the newest bar has the largest weight)
Calculation: MACD = QWMA(close, fast N) - QWMA(close, slow N), where fast N is shorter than slow N
Calculation: Signal = QWMA(MACD, signal N), signal N is typically shorter than slow N
Long: MACD > Signal OR (MACD == Signal AND previous bar's state was long)
Short: MACD < Signal OR (MACD == Signal AND previous bar's state was short)