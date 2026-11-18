Calculation: ref-open = open of last completed bar of reference timeframe
Calculation: ref-close = close of last completed bar of reference timeframe
Long: ref-close > ref-open AND position side is flat AND current bar hour < entry hour
Short: ref-close < ref-open AND position side is flat AND current bar hour < entry hour
Exit: long, current bar hour >= market-close hour
Exit: short, current bar hour >= market-close hour