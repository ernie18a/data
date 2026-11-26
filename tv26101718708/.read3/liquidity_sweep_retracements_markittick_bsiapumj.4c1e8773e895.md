Long: low < Lowest(low, lookback)[1] AND close > Lowest(low, lookback)[1] AND close > open
Long: on each chart bar, last completed T1 close > last completed T1 SMA(close, lookback), with both values calculated on T1 bars
Short: high > Highest(high, lookback)[1] AND close < Highest(high, lookback)[1] AND close < open
Short: on each chart bar, last completed T1 close <= last completed T1 SMA(close, lookback), with both values calculated on T1 bars