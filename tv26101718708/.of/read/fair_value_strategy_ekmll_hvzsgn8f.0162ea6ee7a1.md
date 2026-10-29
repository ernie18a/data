Calculation: Net liquidity = central bank balance sheet − treasury general account − reverse repo balance, using the higher-timeframe bar still forming
Calculation: Index fair value = net liquidity / 1,000,000,000 / scalar − subtractor
Calculation: Diff = higher-timeframe index close − index fair value
Long: net liquidity > 0 AND previous chart bar’s diff > oversold threshold AND current diff < oversold threshold AND current bar is on or after the configured start date
Short: net liquidity > 0 AND previous chart bar’s diff < overbought threshold AND current diff > overbought threshold AND current bar is on or after the configured start date
Exit: long, short condition OR current bar’s date equals the configured close date
Exit: short, long condition OR current bar’s date equals the configured close date