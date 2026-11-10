Calculation: Higher-timeframe series = higher-timeframe OHLC values merged onto chart bars with lookahead off; each chart bar receives the latest completed higher-timeframe bar available at its close.
Calculation: Comparison high and low = the higher-timeframe high and low series, respectively, shifted back one chart bar; comparison midpoint = (comparison high + comparison low) / 2.
Calculation: Confirmation count = the number of consecutive chart bars, ending at the current bar, for which the specified comparison is true; reset to zero when it is false.
Long: Confirmation count for close > comparison high equals the confirmation threshold OR confirmation count for close > comparison midpoint equals the confirmation threshold.
Short: Confirmation count for close < comparison low equals the confirmation threshold OR confirmation count for close < comparison midpoint equals the confirmation threshold.
Long: Higher-timeframe series close >= open AND higher-timeframe series low > higher-timeframe series high two chart bars earlier.
Short: Higher-timeframe series close < open AND higher-timeframe series high < higher-timeframe series low two chart bars earlier.