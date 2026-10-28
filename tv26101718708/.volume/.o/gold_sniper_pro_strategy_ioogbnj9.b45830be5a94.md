Calculation: ATR filter = current ATR is at least the simple moving average of ATR over the same lookback multiplied by a configurable factor
Long: RSI crosses above its oversold threshold AND close > fast EMA AND ATR filter AND (if enabled, volume > its moving average)
Long: RSI < a threshold AND close > fast EMA AND close crosses above fast EMA AND ATR filter
Long: fast EMA crosses above slow EMA AND RSI < a threshold AND ATR filter
Short: RSI crosses below its overbought threshold AND close < fast EMA AND ATR filter AND (if enabled, volume > its moving average)
Short: RSI > a threshold AND close < fast EMA AND close crosses below fast EMA AND ATR filter
Short: fast EMA crosses below slow EMA AND RSI > a threshold AND ATR filter