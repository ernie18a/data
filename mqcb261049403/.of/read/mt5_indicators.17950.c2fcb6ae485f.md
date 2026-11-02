Calculation: Candle strength = either absolute close minus open or high minus low, multiplied by either volume or 1, according to the selected options.
Long: Chart-bar candle strength > threshold AND close >= open.
Short: Chart-bar candle strength > threshold AND close < open.
Long: Candle strength of the chart bar at the configured alert lag > threshold AND that bar's close < open.
Short: Candle strength of the chart bar at the configured alert lag > threshold AND that bar's close >= open.
Long: Candle strength of the still-forming higher-timeframe bar, sampled at the first chart bar of that higher-timeframe bar and held until the next higher-timeframe bar, > threshold AND its close >= open.
Short: Candle strength of the still-forming higher-timeframe bar, sampled at the first chart bar of that higher-timeframe bar and held until the next higher-timeframe bar, > threshold AND its close < open.