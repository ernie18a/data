Calculation: Momentum = 100 × (exponential moving average of close / simple moving average of close − 1), using the same lookback for both averages; evaluated on the configured indicator timeframe, which may be higher or lower than the chart timeframe, using completed bars.
Long: Momentum > upper level OR (Momentum > upper level AND the immediately preceding Momentum <= upper level)
Short: Momentum < lower level OR (Momentum < lower level AND the immediately preceding Momentum <= lower level)
Exit: long, Momentum < lower level
Exit: short, Momentum > upper level