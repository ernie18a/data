Calculation: Strength(C) = sum of closing prices of pairs with C as base, each divided by P2 when its quote currency is JPY, minus sum of closing prices of pairs with C as quote
Long: Mode = trend AND Strength(Base) > EMA(Strength(Base), P1) AND Strength(Quote) < EMA(Strength(Quote), P1)
Long: Mode = counter-trend AND Strength(Base) < EMA(Strength(Base), P1) AND Strength(Quote) > EMA(Strength(Quote), P1)
Short: Mode = trend AND Strength(Base) < EMA(Strength(Base), P1) AND Strength(Quote) > EMA(Strength(Quote), P1)
Short: Mode = counter-trend AND Strength(Base) > EMA(Strength(Base), P1) AND Strength(Quote) < EMA(Strength(Quote), P1)