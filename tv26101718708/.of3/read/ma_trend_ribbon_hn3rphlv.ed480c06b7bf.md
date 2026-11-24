Calculation: Fast MA = selected MA(source, shorter lookback) calculated on T1 and mapped to chart bars, using the latest available T1 value including its still-forming value
Calculation: Slow MA = the same selected MA(source, longer lookback) calculated on T1 and mapped to chart bars, using the latest available T1 value including its still-forming value
Long: Fast MA crosses above Slow MA OR Fast MA > Fast MA[1] AND Fast MA[1] <= Fast MA[2]
Short: Fast MA crosses below Slow MA OR Fast MA <= Fast MA[1] AND Fast MA[1] > Fast MA[2]