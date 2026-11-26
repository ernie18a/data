Calculation: ADX(length, T) = SMA(100 * abs(+DI(length, T) - -DI(length, T)) / max(+DI(length, T) + -DI(length, T), denominator-floor parameter), length), calculated on T bars
Calculation: ADX strength tier(T) = 2 if ADX(length, T) >= strong ADX threshold; otherwise 1 if ADX(length, T) >= base ADX threshold; otherwise 0, calculated on T bars and sampled on chart bars from the still-forming current T bar
Calculation: Strong timeframe count = number of T1, T2, and T3 whose ADX strength tier is 2
Calculation: MTF state(T1, T2, T3) = FULL BULL when +DI(length) > -DI(length) on all three timeframes and all three strength tiers are 2; BUILDING BULL when +DI(length) > -DI(length) on all three, tier(T3) >= tier(T2) >= tier(T1), strong timeframe count >= 1, and the tiers are not all 2; WEAK BULL when +DI(length) > -DI(length) on all three, strong timeframe count <= 1, and not (tier(T3) >= tier(T2) >= tier(T1) and strong timeframe count >= 1 and the tiers are not all 2); FULL BEAR, BUILDING BEAR, and WEAK BEAR use the same tier conditions with -DI(length) > +DI(length) on all three; MIXED otherwise, evaluated on chart bars using the still-forming current bar of each timeframe
Long: +DI(length) > -DI(length) on the current chart bar
Short: -DI(length) > +DI(length) on the current chart bar
Long: background-bias display enabled AND +DI(length) > -DI(length) AND ADX(length) >= strong ADX threshold
Short: background-bias display enabled AND -DI(length) > +DI(length) AND ADX(length) >= strong ADX threshold
Long: readout display enabled AND +DI(length) - -DI(length) >= DI-neutrality threshold
Short: readout display enabled AND -DI(length) - +DI(length) >= DI-neutrality threshold
Long: MTF display enabled AND +DI(length, T1, current still-forming T1 bar) > -DI(length, T1, current still-forming T1 bar), sampled on chart bars
Short: MTF display enabled AND -DI(length, T1, current still-forming T1 bar) > +DI(length, T1, current still-forming T1 bar), sampled on chart bars
Long: MTF display enabled AND +DI(length, T2, current still-forming T2 bar) > -DI(length, T2, current still-forming T2 bar), sampled on chart bars
Short: MTF display enabled AND -DI(length, T2, current still-forming T2 bar) > +DI(length, T2, current still-forming T2 bar), sampled on chart bars
Long: MTF display enabled AND +DI(length, T3, current still-forming T3 bar) > -DI(length, T3, current still-forming T3 bar), sampled on chart bars
Short: MTF display enabled AND -DI(length, T3, current still-forming T3 bar) > +DI(length, T3, current still-forming T3 bar), sampled on chart bars
Long: MTF display enabled AND MTF state(T1, T2, T3) is FULL BULL, BUILDING BULL, or WEAK BULL
Short: MTF display enabled AND MTF state(T1, T2, T3) is FULL BEAR, BUILDING BEAR, or WEAK BEAR
Long: current chart bar confirmed AND MTF state(T1, T2, T3) differs from its prior chart-bar value AND (MTF state is FULL BULL OR strict-alerts setting is disabled AND MTF state is BUILDING BULL or WEAK BULL)
Short: current chart bar confirmed AND MTF state(T1, T2, T3) differs from its prior chart-bar value AND (MTF state is FULL BEAR OR strict-alerts setting is disabled AND MTF state is BUILDING BEAR or WEAK BEAR)