Calculation: trend difference = fast smoothing(applied price, shorter lookback, fast method, fast phase, T1 bars, last completed bar) - slow smoothing(applied price, longer lookback, slow method, slow phase, T1 bars, last completed bar)
Long: trend difference crosses above deviation-limit parameter × point size
Short: trend difference crosses below negative deviation-limit parameter × point size
Exit: long, current datetime - entry datetime > holding-time parameter in minutes
Exit: short, current datetime - entry datetime > holding-time parameter in minutes