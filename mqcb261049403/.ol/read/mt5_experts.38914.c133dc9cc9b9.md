Calculation: Fast MA = moving average with a shorter averaging period, calculated on a higher timeframe and sampled from the higher-timeframe bar containing the chart bar’s timestamp, including while that bar is still forming
Calculation: Slow MA = moving average with a longer averaging period, calculated on a higher timeframe and sampled from the higher-timeframe bar containing the chart bar’s timestamp, including while that bar is still forming
Long: Fast MA[1] < Slow MA[1] AND Fast MA[0] > Slow MA[0]
Short: Fast MA[1] > Slow MA[1] AND Fast MA[0] < Slow MA[0]
Exit: short, Fast MA[1] < Slow MA[1] AND Fast MA[0] > Slow MA[0]
Exit: long, Fast MA[1] > Slow MA[1] AND Fast MA[0] < Slow MA[0]