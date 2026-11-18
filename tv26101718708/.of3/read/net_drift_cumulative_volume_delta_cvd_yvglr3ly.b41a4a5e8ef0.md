Calculation: bar delta = volume when close > open, otherwise -volume
Calculation: cumulative volume delta = cumulative sum of bar delta
Long: cumulative volume delta >= EMA(cumulative volume delta, fast lookback)
Long: cumulative volume delta crosses above EMA(cumulative volume delta, fast lookback) AND cumulative volume delta = highest(cumulative volume delta, fast lookback)
Short: cumulative volume delta < EMA(cumulative volume delta, fast lookback)
Exit: long, cumulative volume delta >= EMA(cumulative volume delta, fast lookback) AND SMA(volume, short volume lookback) < SMA(volume, long volume lookback) * volume-drying multiplier AND (cumulative volume delta < highest(cumulative volume delta, fast lookback) OR bar delta - bar delta[1] < 0)