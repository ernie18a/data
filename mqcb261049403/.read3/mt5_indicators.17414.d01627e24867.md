Calculation: Velocity = sum(selected price[k] * (N-k)^2) / sum((N-k)^2) - sum(selected price[k] * (N-k)) / sum(N-k), for k from 0 through min(N-1, available bars-1), where N is the velocity lookback
Calculation: Trend state = bullish if current Velocity > prior upper trailing band, bearish if current Velocity < prior lower trailing band, otherwise prior Trend state; initial state is neutral
Calculation: Upper trailing band = MA(Velocity, center lookback, selected moving average method) + StdDev(Velocity, deviation lookback, sample correction) * deviation multiplier, capped at the prior upper trailing band when Trend state is bearish and this value is higher
Calculation: Lower trailing band = MA(Velocity, center lookback, selected moving average method) - StdDev(Velocity, deviation lookback, sample correction) * deviation multiplier, capped at the prior lower trailing band when Trend state is bullish and this value is lower
Long: Trend state is bullish
Short: Trend state is bearish