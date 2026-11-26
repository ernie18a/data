Calculation: Percent change(x) = 100 × (x - x[n]) / x[n], using the same comparison lookback n for price and futures open interest on chart bars, including the current forming bar
Calculation: Buildup class = Neutral if abs(price percent change) < minimum price-change threshold OR abs(futures OI percent change) < minimum OI-change threshold; otherwise Long Buildup if both changes are positive, Short Buildup if price change is negative and OI change is positive, Short Covering if price change is positive, and Long Unwinding otherwise
Calculation: Buildup vote = positive full-weight vote for Long Buildup, positive mild-weight vote for Short Covering, negative full-weight vote for Short Buildup, negative mild-weight vote for Long Unwinding, and zero for Neutral
Calculation: Core trend score = the sum of five votes: close above the shorter-lookback EMA contributes positive vote weight and otherwise negative vote weight; the shorter-lookback EMA above the longer-lookback EMA contributes positive vote weight and otherwise negative vote weight; RSI above its upper threshold contributes positive vote weight, below its lower threshold contributes negative vote weight, and otherwise zero; Supertrend up contributes positive vote weight and otherwise negative vote weight; +DI above -DI contributes positive vote weight and otherwise negative vote weight
Calculation: OI-adjusted trend score = core trend score + buildup vote × buildup influence weight when OI buildup is enabled; otherwise core trend score
Calculation: Sector breadth = breadth multiplier × (number of sector indices with bullish trend - number with bearish trend) / number of sector indices
Calculation: Stock buildup breadth = breadth multiplier × (Long Buildup count × full-weight vote + Short Covering count × mild-weight vote - Short Buildup count × full-weight vote - Long Unwinding count × mild-weight vote) / number of selected stock rows
Calculation: Overall market score = mean of the available market-index OI-adjusted trend score, sector breadth, and stock buildup breadth
Long: market index close > EMA(close, shorter lookback)
Short: market index close <= EMA(close, shorter lookback)
Long: EMA(market index close, shorter lookback) > EMA(market index close, longer lookback)
Short: EMA(market index close, shorter lookback) <= EMA(market index close, longer lookback)
Long: RSI(market index close, RSI lookback) > upper RSI threshold
Short: RSI(market index close, RSI lookback) < lower RSI threshold
Long: Supertrend(market index high, low, close, multiplier, ATR lookback) direction is up
Short: Supertrend(market index high, low, close, multiplier, ATR lookback) direction is down
Long: +DI(market index high, low, close, DMI lookback) > -DI(market index high, low, close, DMI lookback)
Short: +DI(market index high, low, close, DMI lookback) <= -DI(market index high, low, close, DMI lookback)
Long: core trend score >= trend-score threshold AND ADX(DMI lookback) >= minimum trend-strength threshold
Short: core trend score <= -trend-score threshold AND ADX(DMI lookback) >= minimum trend-strength threshold
Long: OI-adjusted trend score >= trend-score threshold AND ADX(DMI lookback) >= minimum trend-strength threshold
Short: OI-adjusted trend score <= -trend-score threshold AND ADX(DMI lookback) >= minimum trend-strength threshold
Long: Buildup class is Long Buildup OR Short Covering
Short: Buildup class is Short Buildup OR Long Unwinding
Long: overall market score >= market-score threshold AND (market-index ADX >= minimum trend-strength threshold OR overall market score >= low-ADX override threshold)
Short: overall market score <= -market-score threshold AND (market-index ADX >= minimum trend-strength threshold OR overall market score <= -low-ADX override threshold)