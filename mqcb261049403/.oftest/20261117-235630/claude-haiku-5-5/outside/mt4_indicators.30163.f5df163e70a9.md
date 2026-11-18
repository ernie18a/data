Calculation: CurrencyPower(C) = sum over the seven pairs containing C of (close of pair × sign), where sign is +1 if C is the base currency and −1 if C is the quote currency, and the close of the pair whose other currency is JPY is divided by P2
Long: Mode = P3 AND CurrencyPower(base) > EMA(CurrencyPower(base), P1) AND CurrencyPower(quote) < EMA(CurrencyPower(quote), P1)
Short: Mode = P3 AND CurrencyPower(base) < EMA(CurrencyPower(base), P1) AND CurrencyPower(quote) > EMA(CurrencyPower(quote), P1)
Long: Mode = P4 AND CurrencyPower(base) < EMA(CurrencyPower(base), P1) AND CurrencyPower(quote) > EMA(CurrencyPower(quote), P1)
Short: Mode = P4 AND CurrencyPower(base) > EMA(CurrencyPower(base), P1) AND CurrencyPower(quote) < EMA(CurrencyPower(quote), P1)