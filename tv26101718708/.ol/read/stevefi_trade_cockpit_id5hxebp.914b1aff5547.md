Calculation: AGG = weighted aggregate of CANSLIM, relative strength, price confirmation, trend, pivot, 52-week distance, EWave, volume, mean reversion, accumulation/distribution, Stochastic, invalidation, and target scores; use the weights defined for those components in READ.
Calculation: Price confirmation = a higher low between the two latest confirmed pivot lows AND close above the fast EMA AND close above the prior bar’s high AND close above open.
Calculation: Invalidation level = the low of the detected impulse; the impulse runs from a confirmed pivot low to a later confirmed pivot high.
Calculation: Stochastic rollover = Stochastic K and D are both above the overbought threshold AND K crosses below D.
Calculation: Mean reversion stretched = (close − fast EMA) / ATR is above the stretched threshold.
Long: AGG >= trigger threshold AND price confirmation AND close >= invalidation level AND NOT mean reversion stretched.
Long: AGG >= watch threshold AND AGG < trigger threshold AND close >= invalidation level.
Exit: Long, close < invalidation level OR AGG >= trim threshold AND (Stochastic rollover OR mean reversion stretched).