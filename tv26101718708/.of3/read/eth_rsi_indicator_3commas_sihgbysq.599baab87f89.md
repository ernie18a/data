Calculation: safety-order trigger = base entry price × (1 − rung-specific deviation parameter / 100), with a separate deviation parameter for each rung in ascending order
Calculation: blended average entry = sum(filled-order quote sizes) / sum(filled-order quote sizes / their fill prices), using a separate size parameter for the base order and each safety-order rung
Long: flat AND RSI(close, lookback, T1, last completed bar; sampled on chart bars) < threshold
Long: long position AND fewer than the maximum safety-order count filled AND chart-bar close ≤ safety-order trigger for the next unfilled rung
Exit: long, chart-bar close ≥ blended average entry × (1 + take-profit percentage / 100)