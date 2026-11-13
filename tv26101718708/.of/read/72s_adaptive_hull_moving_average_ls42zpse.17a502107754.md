Calculation: Plugged = one selected mode: (a) ATR(short lookback) > ATR(long lookback); or (b) HMA(RSI(volume, n), shorter lookback) > fixed threshold just below the RSI midpoint
Calculation: AdaptLen(minL, maxL) = running state L, initialized to (minL+maxL)/2; each bar, if Plugged then L = max(minL, L*(1-p)) else L = min(maxL, L*(1+p)), with p a small fixed fraction
Calculation: xHMA(L) = WMA(2*WMA(close, int(L/2)) - WMA(close, int(L)), int(sqrt(L)))
Calculation: MainHMA = xHMA(AdaptLen(minL, maxL)); MinorHMA = xHMA(AdaptLen(minL', maxL')) with minL' < minL and maxL' < maxL (shorter than main)
Calculation: Slope = round(degrees(atan((MainHMA - MainHMA[2]) / close * R / (HH - LL) * LL))), where HH = highest high and LL = lowest low over a slope lookback, R = fixed constant (positive when MainHMA rising, negative when falling)
Calculation: OuterUpper = MainHMA + 2*m*ATR(n); OuterLower = MainHMA - 2*m*ATR(n), with m a fixed multiplier
Long: (Slope >= flat AND Plugged) is true on this bar and was not true on the previous bar (flat = positive threshold)
Short: (Slope <= -flat AND Plugged) is true on this bar and was not true on the previous bar
Exit: long, (Slope >= flat AND NOT Plugged AND close < MinorHMA) is true on this bar and was not true on the previous bar OR (high > OuterUpper) is true on this bar and was not true on the previous bar
Exit: short, (Slope <= -flat AND NOT Plugged AND close > MinorHMA) is true on this bar and was not true on the previous bar OR (low < OuterLower) is true on this bar and was not true on the previous bar