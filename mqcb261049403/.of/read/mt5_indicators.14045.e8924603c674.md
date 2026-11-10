Calculation: LSMA angle = a positive price-scale parameter times (LSMA of close at the more recent shift minus LSMA of close at the older shift) divided by the difference between the shifts. Both LSMAs use the same lookback.
Calculation: Higher-timeframe angle state = the LSMA angle and its preceding-bar value on the higher timeframe, using its still-forming bar; sample the state on the first chart bar of each higher-timeframe bar and carry it forward until the next higher-timeframe bar.
Long: Chart-timeframe LSMA angle > positive threshold AND chart-timeframe LSMA angle != its preceding-bar value
Short: Chart-timeframe LSMA angle < negative threshold AND chart-timeframe LSMA angle != its preceding-bar value
Long: Higher-timeframe angle state > positive threshold AND higher-timeframe angle state != its preceding higher-timeframe bar value
Short: Higher-timeframe angle state < negative threshold AND higher-timeframe angle state != its preceding higher-timeframe bar value