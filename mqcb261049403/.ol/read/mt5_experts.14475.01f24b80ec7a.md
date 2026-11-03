Calculation: CCI_NR = (typical price − second configurable smoothing of the first configurable smoothing of typical price) / [(0.015 / period) × max(sum over the period bars of |each bar’s typical price − current second-smoothed value|, sensitivity × period × point)]
Long: CCI_NR on the latest completed indicator-timeframe bar > upper level AND CCI_NR on the preceding completed indicator-timeframe bar ≤ upper level
Short: CCI_NR on the latest completed indicator-timeframe bar < lower level AND CCI_NR on the preceding completed indicator-timeframe bar ≥ lower level
Exit: long, CCI_NR on the second most recent completed indicator-timeframe bar < middle level
Exit: short, CCI_NR on the second most recent completed indicator-timeframe bar > middle level