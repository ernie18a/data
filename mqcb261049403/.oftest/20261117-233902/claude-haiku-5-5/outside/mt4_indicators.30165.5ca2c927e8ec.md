Calculation: Power(C) = (sum of close prices of the seven pairs containing currency C, each with sign + when C is the base currency and - when C is the quote currency, and each JPY-quoted pair divided by K1) / 7
Long: Mode = M1, Power(base currency) > EMA(Power(base currency), P1) AND Power(quote currency) < EMA(Power(quote currency), P1)
Short: Mode = M1, Power(base currency) < EMA(Power(base currency), P1) AND Power(quote currency) > EMA(Power(quote currency), P1)
Long: Mode = M2, Power(base currency) < EMA(Power(base currency), P1) AND Power(quote currency) > EMA(Power(quote currency), P1)
Short: Mode = M2, Power(base currency) > EMA(Power(base currency), P1) AND Power(quote currency) < EMA(Power(quote currency), P1)