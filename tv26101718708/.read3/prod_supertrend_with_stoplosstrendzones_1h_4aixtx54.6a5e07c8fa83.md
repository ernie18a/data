Calculation: TrendStop = on chart bars, if close > highest(high, trend lookback)[1] - WMA(ATR(1), trend lookback)[1] * trend multiplier AND close > lowest(low, trend lookback)[1] + WMA(ATR(1), trend lookback)[1] * trend multiplier, use the first threshold; else if close < the second threshold AND close < the first threshold, use the second threshold; otherwise use the previous TrendStop, or 0 if unavailable
Calculation: Selected fast DEMA = if close > TrendStop, DEMA(close, uptrend short lookback, T1, last completed bar); otherwise DEMA(close, normal short lookback, T1, last completed bar); each T1 series is sampled on chart bars and indexed T1/chart-interval ratio chart bars back
Calculation: Selected slow DEMA = if close > TrendStop, DEMA(close, uptrend long lookback, T1, last completed bar); otherwise DEMA(close, normal long lookback, T1, last completed bar); each T1 series is sampled on chart bars and indexed T1/chart-interval ratio chart bars back
Long: crossover(Selected slow DEMA, Selected fast DEMA)
Long: datetime >= start datetime parameter AND crossover(Selected slow DEMA, Selected fast DEMA)
Long: Selected slow DEMA > Selected fast DEMA
Short: Selected slow DEMA < Selected fast DEMA
Exit: Long, unrealized loss > stop-loss percentage of equity AND unrealized loss <= let-it-ride percentage of equity
Exit: Long, (crossunder(Selected slow DEMA, Selected fast DEMA) OR crossover(TrendStop, close)) AND NOT (unrealized loss > stop-loss percentage of equity AND unrealized loss <= let-it-ride percentage of equity)