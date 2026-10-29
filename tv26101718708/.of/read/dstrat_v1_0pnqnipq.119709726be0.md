Calculation: Chart SMMA = recursively smooth chart close, initialized with its lookback SMA; each later value = (previous SMMA × (lookback − 1) + close) / lookback.
Calculation: Upper band = chart SMMA + chart close standard deviation × multiplier; standard deviation lookback is longer than the chart SMMA lookback.
Calculation: Lower band = chart SMMA × (1 − percentage / 100).
Calculation: Daily trend SMMA = recursively smooth the higher-timeframe close SMA, using the same lookback for both; initialize with the first SMA value, then use (previous value × (lookback − 1) + current SMA) / lookback. Use the last completed higher-timeframe bar. Its lookback is shorter than the chart SMMA lookback.
Long: close crosses below the lower band AND daily trend SMMA is greater than its value on the previous chart bar AND position is flat.
Exit: Long, low ≤ entry price × (1 − stop percentage / 100).
Exit: Long, close crosses above the upper band.