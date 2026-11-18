Calculation: Power(C) = sum over each pair of C with each of the other seven major currencies of sign * close of the pair, where sign is +1 if C is the pair's base currency and -1 if C is its quote currency, and close is divided by D if the pair's other currency is JPY
Long: M = trend AND Power(base) > EMA(Power(base), P) AND Power(quote) < EMA(Power(quote), P)
Short: M = trend AND Power(base) < EMA(Power(base), P) AND Power(quote) > EMA(Power(quote), P)
Long: M = counter-trend AND Power(base) < EMA(Power(base), P) AND Power(quote) > EMA(Power(quote), P)
Short: M = counter-trend AND Power(base) > EMA(Power(base), P) AND Power(quote) < EMA(Power(quote), P)