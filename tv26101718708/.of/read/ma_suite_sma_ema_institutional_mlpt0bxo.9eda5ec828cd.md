Calculation: Moving-average input = a selected OHLC price; calculate each SMA or EMA on chart bars or on the last completed bar of a higher timeframe.
Calculation: Higher-timeframe anchor = SMA of higher-timeframe closes using the last completed bar, optionally smoothed with an SMA over chart bars.
Long: Shorter-lookback SMA crosses above longer-lookback SMA.
Short: Shorter-lookback SMA crosses below longer-lookback SMA.
Long: Close > long-lookback SMA.
Short: Close <= long-lookback SMA.
Long: Shorter-lookback SMA > longer-lookback SMA.
Short: Shorter-lookback SMA <= longer-lookback SMA.
Long: Close >= any displayed SMA, EMA, or higher-timeframe anchor.
Short: Close < any displayed SMA, EMA, or higher-timeframe anchor.