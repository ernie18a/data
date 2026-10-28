Calculation: Volume z-score = (volume − its moving average) / its standard deviation over the same lookback
Calculation: Learned agent weight = start at 0.5; for each eligible agent vote, after the outcome horizon update W to clamp(W + learning rate × (win − W), 0.05, 1), where win is 1 if the vote-direction close move from its vote close is at least the required ATR multiple (ATR measured at the horizon), otherwise 0. Trend and momentum votes are eligible when their nonzero direction changes; volume votes are eligible on every nonzero bar.
Calculation: Weighted vote sum = trend vote × its learned weight + momentum vote × its learned weight + volume vote × its learned weight; use weight 1 for each agent if learned weighting is disabled.
Long: short-period EMA of close > long-period EMA of close
Long: RSI of close > its upper threshold
Long: volume z-score ≥ its threshold AND close > open
Long: at least the configured minimum number of agents vote long AND weighted vote sum > 0 AND previous consensus is not long
Short: short-period EMA of close < long-period EMA of close
Short: RSI of close < its lower threshold
Short: volume z-score ≥ its threshold AND close < open
Short: at least the configured minimum number of agents vote short AND weighted vote sum < 0 AND previous consensus is not short