Calculation: Open-to-close decline = open[lookback] − close[1] on T1 bars
Calculation: Close-to-open rise = close[1] − open[lookback] on T1 bars
Calculation: Distance above lowest = close[1] − Lowest(low, lookback, T1, last completed bar)
Calculation: Distance below highest = Highest(high, lookback, T1, last completed bar) − close[1]
Long: On each new T1 bar, (Open-to-close decline > channel-open-close threshold AND Distance above lowest < rollback threshold − channel-rollback threshold) OR (Close-to-open rise > channel-open-close threshold AND Distance below highest > rollback threshold + channel-rollback threshold)
Short: On each new T1 bar, (Close-to-open rise > channel-open-close threshold AND Distance below highest < rollback threshold − channel-rollback threshold) OR (Open-to-close decline > channel-open-close threshold AND Distance above lowest > rollback threshold + channel-rollback threshold)