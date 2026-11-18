Calculation: ref_close = close of the last completed bar of the reference timeframe
Calculation: ref_open = open of the last completed bar of the reference timeframe
Long: ref_close > ref_open AND position side = flat AND hour of current bar < entry hour parameter
Short: ref_close < ref_open AND position side = flat AND hour of current bar < entry hour parameter
Exit: long, hour of current bar > close hour parameter - close hour offset parameter
Exit: short, hour of current bar > close hour parameter - close hour offset parameter