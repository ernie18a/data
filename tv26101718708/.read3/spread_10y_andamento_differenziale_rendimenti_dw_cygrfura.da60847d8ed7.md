Calculation: yield spread = (yield series 1 close on the still-forming T1 bar − yield series 2 close on the still-forming T1 bar) × basis-point conversion factor, sampled on chart bars
Calculation: comparison spread = spread[1] for the chart-bar comparison mode, or spread on the last completed T2 bar for the T2 comparison mode
Long: yield spread >= comparison spread
Short: yield spread < comparison spread
Long: abs(close − EMA(close, lookback)) <= close × tolerance AND yield spread >= spread threshold
Calculation: yield spread = (US 10-year yield − German 10-year yield) × 100
Long: yield spread on T1 ≥ previous yield spread on T1
Short: yield spread on T1 < previous yield spread on T1
Long: |close − EMA(close, period parameter)| ≤ close × proximity parameter AND yield spread ≥ spread threshold parameter