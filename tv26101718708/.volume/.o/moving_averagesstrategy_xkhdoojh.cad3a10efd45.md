Calculation: M = selected SMA, EMA, WMA, Hull MA, VWMA, RMA, or TEMA of close over lookback N on the selected resolution (chart resolution or custom); use the last completed bar historically and the bar still forming in real time
Long: M > M[lag] AND M[1] <= M[lag+1]
Short: M < M[lag] AND M[1] >= M[lag+1]