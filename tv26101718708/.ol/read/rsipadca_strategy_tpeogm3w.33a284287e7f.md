Long: RSI crosses above its oversold threshold AND close < simple moving average of close
Long: low <= initial long signal close × (1 − configured drop percentage), for each of five progressively deeper drop percentages below the initial signal close
Long: first bar of a new higher-timeframe week (weekly bar still forming) AND a long position is open AND close < average position entry price
Calculation: Average position entry price = position-size-weighted average entry price
Calculation: All-position take-profit = average position entry price × (1 + configured all-position take-profit percentage)
Calculation: Individual long take-profit limit = entry-layer price + current close × configured per-position take-profit percentage when close < all-position take-profit; otherwise all-position take-profit
Exit: Long, high >= individual long take-profit limit for an initial or price-averaging entry
Exit: Long, high >= all-position take-profit for a weekly DCA entry