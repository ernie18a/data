Calculation: Anchored move = percentage change from the shared anchor
Calculation: Beta to benchmark = ordinary least-squares slope of symbol returns against benchmark returns, using prior completed bars of the chart timeframe
Calculation: Anchored residual score = (symbol anchored move − beta to benchmark × benchmark anchored move) ÷ (standard deviation of per-bar residuals × square root of bars since anchor)
Calculation: Damped residual score = residual score discounted when positive and the symbol is below its prior completed daily moving average
Calculation: Long-term benchmark correlation = correlation of symbol and benchmark returns over a longer lookback than the beta calculation
Calculation: One-bar residual score = per-bar symbol return minus beta to benchmark × benchmark return, standardized by the rolling standard deviation of per-bar residuals
Calculation: Benchmark downside score = benchmark anchored move divided by its own per-bar return standard deviation times the square root of bars since anchor
Long: Damped residual score exceeds the positive threshold for four consecutive chart bars AND long-term benchmark correlation is between the minimum-link and tracking cutoffs AND current symbol close is at its period high AND current benchmark close is below its period high
Long: Benchmark downside score is at or below the negative threshold AND symbol anchored move is at least zero AND long-term benchmark correlation is positive AND below the tracking cutoff
Long: One-bar residual score is at or above the positive outlier threshold AND long-term benchmark correlation is between the minimum-link and tracking cutoffs
Short: Damped residual score is below the negative threshold AND long-term benchmark correlation is between the minimum-link and tracking cutoffs
Short: One-bar residual score is at or below the negative outlier threshold AND long-term benchmark correlation is between the minimum-link and tracking cutoffs
Exit: Long, damped residual score is at or below zero