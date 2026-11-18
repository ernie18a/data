Calculation: Power(X) = sum of chart-timeframe close prices of the fixed pairs containing X, with sign + where X is the base currency and - where X is the quote currency
Long: Mode = M1, Power(base) > EMA(Power(base), N) AND Power(quote) < EMA(Power(quote), N)
Long: Mode = M2, Power(base) < EMA(Power(base), N) AND Power(quote) > EMA(Power(quote), N)
Short: Mode = M1, Power(base) < EMA(Power(base), N) AND Power(quote) > EMA(Power(quote), N)
Short: Mode = M2, Power(base) > EMA(Power(base), N) AND Power(quote) < EMA(Power(quote), N)