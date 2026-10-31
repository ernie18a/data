Calculation: Direction line = smooth 2 × MA(price, floor(N/2)) − MA(price, N) with a second MA of length max(floor(sqrt(N)), 1); the two price MAs use the same method and phase, while the final MA may use a different method and phase. Price is a selected OHLC-derived price.
Long: Chart-timeframe direction line > its previous-bar value
Short: Chart-timeframe direction line < its previous-bar value
Long: Higher-timeframe direction line on any of the three selected consecutive bars >= its preceding higher-timeframe bar's value
Short: Higher-timeframe direction line on any of the three selected consecutive bars < its preceding higher-timeframe bar's value
Calculation: The three selected higher-timeframe bars start with the last completed bar or, when configured, the still-forming bar, and extend backward consecutively.