Calculation: T1 volume spike = T1 volume > SMA(volume, volume lookback) * spike multiplier, calculated on T1 bars including the current, possibly forming, T1 bar
Calculation: T2 price bin = [low + r * (high - low) / bin count, low + (r + 1) * (high - low) / bin count), for each integer r from zero to bin count minus one, using the displayed T2 candle's high and low
Calculation: Bullish spike count per T2 price bin = count of T1 volume spikes within the displayed T2 candle whose close is greater than or equal to open and falls in that bin
Calculation: Bearish spike count per T2 price bin = count of T1 volume spikes within the displayed T2 candle whose close is less than open and falls in that bin
Long: T1 volume spike AND T1 close >= T1 open
Short: T1 volume spike AND T1 close < T1 open
Long: On chart bars, for each displayed T2 candle (current forming or last completed), T2 close >= T2 open
Short: On chart bars, for each displayed T2 candle (current forming or last completed), T2 close < T2 open
Long: Bullish spike count per T2 price bin >= imbalance threshold
Short: Bearish spike count per T2 price bin >= imbalance threshold AND bullish spike count per T2 price bin < imbalance threshold