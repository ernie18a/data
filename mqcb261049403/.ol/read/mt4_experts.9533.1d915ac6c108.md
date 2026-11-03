Calculation: Upper/lower envelope = an exponential moving average of high, offset above/below it by the configured percentage deviation.
Calculation: Short EMA = exponential moving average of low with a shorter lookback than the long EMA; long EMA = exponential moving average of low with a longer lookback than the short EMA. Both use the current, still-forming chart-timeframe bar.
Long: 
Short: No open short position and no pending short-stop order AND short EMA > lower envelope AND long EMA > lower envelope AND close > lower envelope AND short EMA <= upper envelope AND long EMA <= upper envelope AND close <= upper envelope
Exit: short, short EMA < entry price AND long EMA < entry price AND close < entry price AND all three Parabolic SAR values < close AND short EMA > long EMA
Exit: short, high >= entry price + configured stop distance OR low <= entry price - configured take-profit distance