Calculation: Signal price = selected open, high, low, or close price of the configured reference instrument when reference-data mode is enabled, otherwise of the traded instrument
Long: RSI(Signal price, RSI period parameter) crosses above long RSI threshold parameter AND Signal price > SMA(Signal price, SMA period parameter) AND bar time is within the configured date range
Short: RSI(Signal price, RSI period parameter) crosses below short RSI threshold parameter AND Signal price < SMA(Signal price, SMA period parameter) AND bar time is within the configured date range
Exit: long, traded instrument price reaches the position's configured take-profit or stop-loss level
Exit: short, traded instrument price reaches the position's configured take-profit or stop-loss level