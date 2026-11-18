Calculation: relative strength = (close / close[n]) / (comparison close / comparison close[n]) - 1, where n uses one parameter on chart timeframes other than T1 and T2, a separate parameter on T1, and another separate parameter on T2
Long: relative strength > 0
Short: relative strength <= 0
Long: relative-strength trend display enabled AND relative strength > relative strength[trend range]
Short: relative-strength trend display enabled AND relative strength <= relative strength[trend range]
Long: volume >= volume threshold AND (combined-condition mode disabled OR abs(ROC(close, ROC period)) >= ROC percentage threshold)
Long: open < low[1] AND low >= open * (1 - percentage threshold) AND high >= low[1] * (1 + percentage threshold)