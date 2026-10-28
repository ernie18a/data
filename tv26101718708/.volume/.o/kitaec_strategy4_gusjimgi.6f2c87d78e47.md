Calculation: EMA-based zero-lag line = EMA(close, length 1) + (EMA(close, length 1) − EMA(EMA(close, length 1), length 2)
Calculation: RMA-based zero-lag line = RMA(close, length 1) + (RMA(close, length 1) − RMA(RMA(close, length 1), length 2)
Long: Previous completed bar’s RMA-based zero-lag line < its EMA-based zero-lag line AND datetime > configured start timestamp AND datetime < configured end timestamp
Short: Previous completed bar’s RMA-based zero-lag line > its EMA-based zero-lag line AND datetime > configured start timestamp AND datetime < configured end timestamp