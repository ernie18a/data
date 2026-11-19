Calculation: MFI change = MFI(hlc3, lookback) - MFI(hlc3, lookback)[1]; on T1, T2, and T3, calculate on their own bars and use the lookahead-off values on chart bars (the forming source bar in real time and the latest completed source bar historically)
Long: MFI change > 0
Short: MFI change < 0
Long: MFI(hlc3, lookback) crosses below the oversold-threshold parameter, then crosses above it, pulls back while remaining above it, then crosses above the high reached on the preceding rebound
Short: MFI(hlc3, lookback) crosses above the overbought-threshold parameter, then crosses below it, rebounds while remaining below it, then crosses below the low reached on the preceding decline
Long: MFI change > 0 on chart bars, T1 bars, and T2 bars, and on T3 bars when required by the alignment-mode parameter, and this bullish alignment was false on the previous chart bar
Short: MFI change <= 0 on chart bars, T1 bars, and T2 bars, and on T3 bars when required by the alignment-mode parameter, and this bearish alignment was false on the previous chart bar