Calculation: Smoothed bull power = a configurable moving average of (high minus a separately configured moving average of a configurable OHLC-derived price); the two averages have independent methods and lookbacks.
Calculation: Higher-timeframe bull-power state = compare smoothed bull power on the still-forming higher-timeframe bar with its preceding completed bar; sample the comparison on the first chart bar of each higher-timeframe bar and hold it for the remaining chart bars in that higher-timeframe bar.
Long: Chart-timeframe smoothed bull power > its previous-bar value.
Short: Chart-timeframe smoothed bull power < its previous-bar value.
Long: Higher-timeframe bull-power state indicates an increase.
Short: Higher-timeframe bull-power state indicates a decrease.
Long: Higher-timeframe bull-power state on the selected chart bar indicates an increase AND its state on the preceding chart bar indicates equality.
Short: Higher-timeframe bull-power state on the selected chart bar indicates equality AND its state on the preceding chart bar indicates an increase.