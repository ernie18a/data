Calculation: Previous-day high/low = high/low of the last completed bar on a timeframe higher than the chart timeframe
Calculation: Adjusted ADX = (ADX − baseline) × scale
Calculation: Long stop = entry price − initial risk until target 1 is reached; entry price after target 1; entry price + target 1 distance after target 2; entry price + target 2 distance after target 3
Long: (previous bar close ≤ previous-day high AND close > previous-day high OR previous bar close ≤ previous-day low AND close > previous-day low) AND adjusted ADX > strength threshold AND +DI > −DI AND adjusted ADX > the highest adjusted ADX of the preceding lookback bars AND within the configured entry window
Exit: long, low ≤ long stop OR high ≥ entry price + maximum profit OR time > configured entry-window end