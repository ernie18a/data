Calculation: Smoothed speed = Jurik moving average of the momentum of a Jurik moving average of the FATL of a selected OHLC-derived price; momentum is the current first average minus its value a lookback ago. The two Jurik averages have independently configurable lengths and phases.
Long: Chart-timeframe smoothed speed > its previous-bar value.
Short: Chart-timeframe smoothed speed < its previous-bar value.
Long: The chart bar is the first bar of a higher-timeframe bar AND smoothed speed of the still-forming higher-timeframe bar >= 0.
Short: The chart bar is the first bar of a higher-timeframe bar AND smoothed speed of the still-forming higher-timeframe bar < 0.