Calculation: POC midpoint = (min(upper price of the footprint POC row, high) + max(lower price of the footprint POC row, low)) / 2
Long: close > open AND (footprint delta < 0 OR close > POC midpoint)
Short: close < open AND (footprint delta >= 0 OR close < POC midpoint)