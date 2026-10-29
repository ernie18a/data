Calculation: Williams %R trend state = Set bearish when Williams %R is below the lower threshold, set bullish when it is above the upper threshold, and otherwise retain the prior state; the lower threshold is below the upper threshold.
Long: On the indicator timeframe’s last completed signal bar, trend state changes from bearish to bullish
Short: On the indicator timeframe’s last completed signal bar, trend state changes from bullish to bearish
Exit: long, trend state changes from bullish to bearish OR price falls to the configured stop-loss level OR price rises to the configured take-profit level
Exit: short, trend state changes from bearish to bullish OR price rises to the configured stop-loss level OR price falls to the configured take-profit level