Calculation: Prior-bar rolling high/low = highest high / lowest low over the lookback ending on the previous chart bar
Calculation: Upper/lower exhaustion zone = top/bottom configurable fraction of the chart-timeframe rolling range; rolling range = rolling high − rolling low
Calculation: ATR% = ATR / close × 100
Long: confirmed chart bar close > prior-bar rolling high AND (Bias Shift filters pass OR Golden filters pass); OR close > EMA + ATR × decision-zone threshold
Short: confirmed chart bar close < prior-bar rolling low AND (Bias Shift filters pass OR Golden filters pass); OR close < EMA − ATR × decision-zone threshold
Exit:
