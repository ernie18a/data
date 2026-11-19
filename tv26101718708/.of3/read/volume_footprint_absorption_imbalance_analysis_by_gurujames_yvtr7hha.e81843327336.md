Calculation: Buy volume = sum(volume of T1 bars within each chart bar where close > open) + 0.5 × sum(volume of T1 bars within each chart bar where close = open), including a T1 bar still forming
Calculation: Sell volume = sum(volume of T1 bars within each chart bar where close < open) + 0.5 × sum(volume of T1 bars within each chart bar where close = open), including a T1 bar still forming
Calculation: Total volume = buy volume + sell volume
Calculation: Average volume = SMA(total volume, lookback)
Long: total volume > average volume × absorption volume multiplier AND sell volume > buy volume AND close − low > high − close AND close >= open
Short: total volume > average volume × absorption volume multiplier AND buy volume > sell volume AND high − close > close − low AND close <= open
Long: close = high AND buy volume > 0 AND sell volume > 0 AND total volume > average volume × missed-auction volume multiplier
Short: close = low AND sell volume > 0 AND buy volume > 0 AND total volume > average volume × missed-auction volume multiplier
Long: total volume > average volume × imbalance volume multiplier AND close > open AND buy volume / (sell volume if positive, otherwise 1) >= imbalance ratio
Short: total volume > average volume × imbalance volume multiplier AND close < open AND sell volume / (buy volume if positive, otherwise 1) >= imbalance ratio