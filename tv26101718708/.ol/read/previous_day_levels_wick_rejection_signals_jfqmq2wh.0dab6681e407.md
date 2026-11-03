Calculation: Previous-day low, close, high, and open = low, close, high, and open of the last completed daily bar (daily timeframe is higher than the chart timeframe)
Calculation: Real body = absolute difference between bar close and bar open
Calculation: Lower wick = min(bar open, bar close) − bar low
Calculation: Upper wick = bar high − max(bar open, bar close)
Long: (bar low < previous-day low OR bar low < previous-day close) AND bar close > the corresponding level AND real body > 0 AND lower wick >= real body × the minimum wick percentage / 100
Short: (bar high > previous-day high OR bar high > previous-day open) AND bar close < the corresponding level AND real body > 0 AND upper wick >= real body × the minimum wick percentage / 100