Calculation: Midnight open = open of the first chart bar on a new calendar day in the session timezone, if that bar opens before the configured cutoff; otherwise retain the previous midnight open.
Calculation: Prior range = high and low of the last completed bar of a selected higher timeframe.
Calculation: Equilibrium = (prior range high + prior range low) / 2.
Calculation: Range depth = (close - equilibrium) / (prior range high - prior range low), undefined when the range is zero.
Long: close > midnight open.
Short: close < midnight open.
Long: range depth <= negative neutral-band fraction.
Short: range depth >= neutral-band fraction AND range depth > negative neutral-band fraction.
Long: close >= prior range low AND close < equilibrium.
Short: close <= prior range high AND close >= equilibrium.