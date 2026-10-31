Calculation: Channel index = smooth (price - average price) / (coefficient × absolute value of (price - average price)) with the selected final smoothing method and lookback; use zero for the unsmoothed value when price equals average price. Average price uses the selected averaging method and lookback. Price is a selected OHLC price or derived OHLC price.
Calculation: Higher-timeframe channel index = channel index calculated on the higher timeframe's still-forming bar, sampled on the first chart bar of that higher-timeframe bar and held until the next higher-timeframe bar.
Long: Channel index > 0
Short: Channel index < 0
Long: Higher-timeframe channel index > 0
Short: Higher-timeframe channel index < 0
Long: Higher-timeframe channel index on the selected chart signal bar > upper threshold AND higher-timeframe channel index on the preceding chart bar <= upper threshold
Short: Higher-timeframe channel index on the selected chart signal bar < lower threshold AND higher-timeframe channel index on the preceding chart bar >= lower threshold