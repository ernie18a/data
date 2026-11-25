Calculation: YangZhangVolatility(a) = Yang-Zhang volatility over sigma lookback bars ending at bar a, where a is bars back from the current bar
Calculation: Range(a) = High(a) - Low(a)
Calculation: Anchors = the first two bars at ages a >= basis offset + 1, scanned in increasing a, where Range(a) > Range(a + 1), followed by the bar at ages basis offset to basis offset + period lookback - 1 with the largest Range (most recent on ties), appended if not already listed and period maximum enabled
Calculation: Radius(m, c) = for the outer curve, (ln(High(m)) - ln(Low(m))) / (2 * YangZhangVolatility(age(m))); for the upper pin, (ln(High(m)) - ln(max(Open(m), Close(m)))) / (2 * YangZhangVolatility(age(m))); for the lower pin, (ln(min(Open(m), Close(m))) - ln(Low(m))) / (2 * YangZhangVolatility(age(m))), where m is an anchor and age(m) is bars back of bar m
Calculation: CosTheta(m, c, x) = cos(theta), where theta >= 0 solves Radius(m, outer) * theta + Radius(m, c) * sin(theta) = x, and x is bars after bar m
Calculation: CurvePrice(m, c, x) = exp(ln(Low(m)) + YangZhangVolatility(age(m)) * (Radius(m, outer) + Radius(m, c) * CosTheta(m, c, x))), where x is bars after bar m
Calculation: Soft(x) = max(0, 2 / (1 + exp(-x)) - 1)
Calculation: Band = contact tolerance factor * YangZhangVolatility(0) * close
Calculation: StopBand = stop tolerance factor * Band
Calculation: Score(m, c) = min(1, base * zone * conf), where base = outer base weight if c is the outer curve, else pin base intercept + pin base slope * Radius(m, c) / Radius(m, outer); p = CosTheta(m, c, age(m)); zone = 1 + (zone base + apex zone bonus * max(0, p)) * Soft(zone sharpness * (abs(p) - zone center)); conf = 1 + confluence gain * Soft(confluence sharpness * (n - 1)), where n = number of positive-radius curves (m', c') with abs(CurvePrice(m', c', age(m') - basis offset) - CurvePrice(m, c, age(m))) < Band
Calculation: LeadPrice = CurvePrice(m, c, age(m)) for the contact (m, c) with the highest Score(m, c), where a contact is a positive-radius curve with abs(close - CurvePrice(m, c, age(m))) < Band or low <= CurvePrice(m, c, age(m)) <= high on the current bar; ties go to the earliest in Anchors order, then outer, upper pin, lower pin; undefined when there is no contact
Long: close > LeadPrice OR close = LeadPrice AND low < LeadPrice
Short: close < LeadPrice OR close = LeadPrice AND low >= LeadPrice
Long: close - LeadPrice >= StopBand AND low <= LeadPrice
Short: LeadPrice - close >= StopBand AND high >= LeadPrice