Calculation: RSI Z-Score = (RSI of a configurable price source − a configurable moving average of RSI) ÷ the standard deviation of RSI, using the moving average lookback
Calculation: Long threshold = adaptive mode: standard deviation of RSI Z-Score over the moving average lookback × configurable long multiplier; fixed mode: configurable long level
Calculation: Short threshold = adaptive mode: −standard deviation of RSI Z-Score over the moving average lookback × configurable short multiplier; fixed mode: configurable short level
Long: RSI Z-Score crosses above the long threshold at bar close
Short: RSI Z-Score crosses below the short threshold at bar close
Exit: long, RSI Z-Score crosses below the short threshold at bar close