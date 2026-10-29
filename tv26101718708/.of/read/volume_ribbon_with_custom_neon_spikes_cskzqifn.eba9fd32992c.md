Calculation: buy volume = volume × normalized max(close − low, 0) / (high − low), where a zero high − low is treated as 1 before calculating the shares
Calculation: sell volume = volume × normalized max(high − close, 0) / (high − low), where a zero high − low is treated as 1 before calculating the shares
Calculation: volume ribbon = moving average of buy volume − moving average of sell volume; both averages use the same lookback and selected moving-average type (SMA or EMA)
Calculation: volume average = SMA of volume using the same lookback as the buy-volume and sell-volume moving averages
Long: volume < 2 × volume average AND volume ribbon ≥ 0 OR volume ≥ 2 × volume average AND buy volume > sell volume
Short: volume < 2 × volume average AND volume ribbon < 0 OR volume ≥ 2 × volume average AND buy volume ≤ sell volume