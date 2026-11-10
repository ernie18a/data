Calculation: Smoothed Heikin-Ashi close = EMA of (open + high + low + close) / 4.
Calculation: Heikin-Ashi volume balance = cumulative sum of volume when smoothed Heikin-Ashi close is greater than its previous value, minus volume when it is less, and zero when equal; initialize at zero.
Long: Heikin-Ashi volume balance > its longer-period EMA.
Short: Heikin-Ashi volume balance < its longer-period EMA.
Long: Heikin-Ashi volume balance > its longer-period EMA AND its shorter-period EMA > its longer-period EMA.
Short: Heikin-Ashi volume balance < its longer-period EMA AND its shorter-period EMA < its longer-period EMA.