Calculation: upper = high of the last completed higher-timeframe period − (high − low) × (100 − trading-range percent) / 200
Calculation: lower = low of the last completed higher-timeframe period + (high − low) × (100 − trading-range percent) / 200
Calculation: SMA = simple moving average of close, using chart-timeframe bars when the SMA switch is off or higher-timeframe bars when it is on; use the last completed higher-timeframe bar
Calculation: long stop = upper − (upper − lower) × stop-range percent / 100; set on entry
Calculation: short stop = lower + (upper − lower) × stop-range percent / 100; set on entry
Calculation: ATR offset = EMA of chart-timeframe true range × ATR multiplier
Long: within the configured date window AND no trade yet in the current higher-timeframe period AND flat AND upper > SMA AND close > upper
Short: within the configured date window AND no trade yet in the current higher-timeframe period AND flat AND lower < SMA AND close < lower
Exit: Long, low ≤ long stop OR high ≥ close + ATR offset
Exit: Short, high ≥ short stop OR low ≤ close − ATR offset