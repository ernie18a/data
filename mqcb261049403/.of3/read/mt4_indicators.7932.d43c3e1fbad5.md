Calculation: PriorClose = close of the last completed T1 bar, read on each chart bar
Long: current chart-bar close >= PriorClose + distance parameter × point size
Short: current chart-bar close <= PriorClose − distance parameter × point size
Long: current chart-bar close >= PriorClose
Short: current chart-bar close <= PriorClose
Long: open of the still-forming T1 bar >= PriorClose, read on each chart bar
Short: open of the still-forming T1 bar < PriorClose, read on each chart bar