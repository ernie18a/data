Calculation: Pivot = (high + low + close) / 3 of the previous completed higher-timeframe bar
Calculation: R1 = 2 × Pivot − low of the previous completed higher-timeframe bar
Calculation: R2 = Pivot + (high − low) of the previous completed higher-timeframe bar
Calculation: S1 = 2 × Pivot − high of the previous completed higher-timeframe bar
Calculation: S2 = Pivot − (high − low) of the previous completed higher-timeframe bar
Calculation: S3 = low − 2 × (high − Pivot) of the previous completed higher-timeframe bar
Calculation: ATR = average true range
Long: low <= S2 AND close > S2
Short: high >= R1 AND close < R1
Exit: long, low <= S3 − 0.3 × ATR OR high >= Pivot OR high >= R1 OR high >= R2
Exit: short, high >= R2 OR low <= S1 OR low <= S2 OR low <= S3