Calculation: Pivot = (previous completed higher-timeframe bar high + low + close) / 3
Calculation: Long entry level = Pivot + metric × Point
Calculation: Short entry level = Pivot − metric × Point
Calculation: Long stop = Pivot − 2 × metric × Point
Calculation: Short stop = Pivot + 2 × metric × Point
Calculation: Long target = max(previous completed higher-timeframe bar close + 1.1 × (high − low) / 2, Pivot − 2 × metric × Point − 20 × Point)
Calculation: Short target = min(previous completed higher-timeframe bar close − 1.1 × (high − low) / 2, Pivot − 2 × metric × Point − 20 × Point)
Long: Previous close < Long entry level AND close ≥ Long entry level AND hour(datetime) is within the configured trading hours AND no matching open long or short position exists
Short: Previous close > Short entry level AND close ≤ Short entry level AND hour(datetime) is within the configured trading hours AND no matching open long or short position exists
Exit: Long, close ≤ active stop OR close ≥ Long target OR hour(datetime) is outside the configured trading hours
Exit: Short, close ≥ active stop OR close ≤ Short target OR hour(datetime) is outside the configured trading hours