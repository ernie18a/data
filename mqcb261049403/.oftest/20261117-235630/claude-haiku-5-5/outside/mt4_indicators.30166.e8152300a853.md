Calculation: Power(X) = (-sum of Close(p) over the six pairs p quoted in X + Close(q)/P1) / 7, where q is the pair based on X
Long: trend mode AND Power(base) > EMA(Power(base), N) AND Power(quote) < EMA(Power(quote), N)
Short: trend mode AND Power(base) < EMA(Power(base), N) AND Power(quote) > EMA(Power(quote), N)
Long: counter-trend mode AND Power(base) < EMA(Power(base), N) AND Power(quote) > EMA(Power(quote), N)
Short: counter-trend mode AND Power(base) > EMA(Power(base), N) AND Power(quote) < EMA(Power(quote), N)