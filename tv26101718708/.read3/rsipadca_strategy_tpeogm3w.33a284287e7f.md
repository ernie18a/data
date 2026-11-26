Calculation: Initial PA reference price = close on the first-entry signal bar
Calculation: Lower PA reference price = first-entry signal close × (1 − its separate layer-drop percentage / 100)
Calculation: All-position take-profit price = average position entry price × (1 + all-position take-profit percentage / 100)
Calculation: PA-layer exit limit = if current close < all-position take-profit price, PA reference price + current close × per-position take-profit percentage / 100; otherwise all-position take-profit price
Long: RSI(close, RSI lookback) crosses above the oversold threshold AND close < SMA(close, moving-average lookback) AND no open trades
Long: Exactly one open trade AND low <= second-layer PA reference price
Long: Exactly two open trades AND low <= third-layer PA reference price
Long: Exactly three open trades AND low <= fourth-layer PA reference price
Long: Exactly four open trades AND low <= fifth-layer PA reference price
Long: Exactly five open trades AND low <= sixth-layer PA reference price
Long: DCA enabled AND the current, still-forming T1 bar's timestamp changes, sampled on chart bars
Long: DCA enabled AND the current, still-forming T1 bar's timestamp changes, sampled on chart bars AND a long position is open AND close < average position entry price
Exit: Long, for each PA-layer position, high >= PA-layer exit limit
Exit: Long, for a DCA position, high >= all-position take-profit price