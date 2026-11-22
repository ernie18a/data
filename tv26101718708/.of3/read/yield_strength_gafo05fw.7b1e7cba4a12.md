Calculation: Pair yield spread = selected-maturity yield close for the base currency on the still-forming T1 bar minus selected-maturity yield close for the quote currency on the still-forming T1 bar
Long: On chart bars taking values from the still-forming T2 bar, EMA(pair yield spread, shorter lookback, T2) crosses above EMA(pair yield spread, longer lookback, T2)
Short: On chart bars taking values from the still-forming T2 bar, EMA(pair yield spread, shorter lookback, T2) crosses below EMA(pair yield spread, longer lookback, T2)
Long: On chart bars taking values from the still-forming T2 bar, EMA(pair yield spread, shorter lookback, T2) > EMA(pair yield spread, longer lookback, T2)
Short: On chart bars taking values from the still-forming T2 bar, EMA(pair yield spread, shorter lookback, T2) <= EMA(pair yield spread, longer lookback, T2)
Calculation: Yield spread = base-currency government bond yield (selected maturity, T1) − quote-currency government bond yield (selected maturity, T1)
Long: fast EMA of yield spread (fast EMA length parameter, T2) > slow EMA of yield spread (slow EMA length parameter, T2)
Short: fast EMA of yield spread (fast EMA length parameter, T2) ≤ slow EMA of yield spread (slow EMA length parameter, T2)