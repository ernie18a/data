Calculation: Session VWAP = cumulative sum of typical price times volume divided by cumulative volume, reset at each trading session; typical price is (high + low + close) / 3.
Calculation: Premarket high and low = highest high and lowest low accumulated during the current premarket session, retained until the next premarket session begins.
Calculation: Opening range high and low = highest high and lowest low from the first regular-session bar through bars whose opening times precede the configured opening-range end.
Calculation: Buy-volume percentage = 100 × (close - low) / (high - low) when high > low and volume > 0; otherwise 50.
Long: close > session VWAP
Short: close <= session VWAP
Long: shorter EMA of close > longer EMA of close
Short: shorter EMA of close <= longer EMA of close
Long: close > shorter SMA of close
Short: close <= shorter SMA of close
Long: close > longer SMA of close
Short: close <= longer SMA of close
Long: close > close of the last completed higher-timeframe bar
Short: close <= close of the last completed higher-timeframe bar
Long: buy-volume percentage >= 50
Short: buy-volume percentage < 50
Long: close crosses above the high of the last completed higher-timeframe bar
Short: close crosses below the low of the last completed higher-timeframe bar
Long: close crosses above the premarket high
Short: close crosses below the premarket low
Long: regular session is active AND opening range has ended AND close crosses above the opening range high
Short: regular session is active AND opening range has ended AND close crosses below the opening range low
Long: close crosses above session VWAP
Short: close crosses below session VWAP