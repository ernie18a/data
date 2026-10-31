Calculation: Smoothed power = a moving average of ((high + low) / 2 - a separately parameterized moving average of a selected bar price); the two moving averages have independently selectable methods and lookbacks.
Calculation: Projected higher-timeframe power = smoothed power calculated on the higher-timeframe bar still forming at the start of each higher-timeframe interval, then held constant on subsequent chart bars until the next interval. Its projected direction is the direction of that higher-timeframe power compared with its preceding higher-timeframe bar.
Long: Chart-timeframe smoothed power > its previous-bar value.
Short: Chart-timeframe smoothed power < its previous-bar value.
Long: Projected higher-timeframe direction is rising AND its direction on the preceding chart bar was falling.
Short: Projected higher-timeframe direction is falling AND its direction on the preceding chart bar was rising.