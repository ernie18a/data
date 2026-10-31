Calculation: Raw Hull series = 2 × moving average of the selected OHLC-derived price over floor(N/2) bars − moving average of the same price over N bars, using the same selected smoothing method for both.
Calculation: Smoothed Hull series = moving average of the raw Hull series over floor(sqrt(N)) bars, using the same smoothing method. Calculate both series on the selected chart, higher, or lower timeframe, using the last completed bar or the still-forming bar according to the selected signal-bar setting; previous means the immediately preceding bar of that timeframe.
Long: Raw Hull series > smoothed Hull series AND previous raw Hull series <= previous smoothed Hull series
Long: Raw Hull series > smoothed Hull series
Short: Raw Hull series < smoothed Hull series AND previous raw Hull series >= previous smoothed Hull series
Short: Raw Hull series < smoothed Hull series
Exit: long, raw Hull series < smoothed Hull series OR low <= entry price − stop-loss distance OR high >= entry price + take-profit distance
Exit: short, raw Hull series > smoothed Hull series OR high >= entry price + stop-loss distance OR low <= entry price − take-profit distance