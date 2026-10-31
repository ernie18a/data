Calculation: Double moving average = 2 × shorter-period moving average of a selected OHLC-derived price − longer-period moving average of the same price, using the same selected averaging method and shared method parameters.
Calculation: Change = current double moving average − previous double moving average.
Calculation: Deviation threshold = population standard deviation of Change over a lookback including the current bar, multiplied by a threshold coefficient; round the threshold and current Change separately to the price decimal precision plus two decimal places.
Calculation: Higher-timeframe values = calculate the same double moving average, Change, and deviation thresholds on higher-timeframe bars, using the still-forming higher-timeframe bar as of the first chart bar in each higher-timeframe period; hold those values until the next higher-timeframe period.
Long: Double moving average > previous double moving average.
Short: Double moving average < previous double moving average.
Long: Rounded Change > smaller-coefficient deviation threshold AND rounded Change ≤ larger-coefficient deviation threshold.
Long: Rounded Change > larger-coefficient deviation threshold.
Short: Rounded Change < negative smaller-coefficient deviation threshold AND rounded Change ≥ negative larger-coefficient deviation threshold.
Short: Rounded Change < negative larger-coefficient deviation threshold.
Long: Higher-timeframe double moving average > previous higher-timeframe double moving average.
Short: Higher-timeframe double moving average < previous higher-timeframe double moving average.
Long: Higher-timeframe rounded Change > higher-timeframe smaller-coefficient deviation threshold AND higher-timeframe rounded Change ≤ higher-timeframe larger-coefficient deviation threshold.
Long: Higher-timeframe rounded Change > higher-timeframe larger-coefficient deviation threshold.
Short: Higher-timeframe rounded Change < negative higher-timeframe smaller-coefficient deviation threshold AND higher-timeframe rounded Change ≥ negative higher-timeframe larger-coefficient deviation threshold.
Short: Higher-timeframe rounded Change < negative higher-timeframe larger-coefficient deviation threshold.