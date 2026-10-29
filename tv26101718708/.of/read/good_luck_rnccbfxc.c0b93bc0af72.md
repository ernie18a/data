Calculation: Fast EMA = EMA of close with a shorter lookback than the slow EMA
Calculation: Slow EMA = EMA of close with a longer lookback than the fast EMA
Calculation: Confirmed pivot low = the low at the center of equal-length preceding and following windows is lower than every other low in those windows
Calculation: Confirmed pivot high = the high at the center of equal-length preceding and following windows is higher than every other high in those windows
Long: (close > fast EMA AND previous close <= previous fast EMA AND fast EMA > slow EMA) OR (close > fast EMA AND fast EMA > previous fast EMA) OR (low > high two bars ago) OR confirmed pivot low
Short: (close < fast EMA AND previous close >= previous fast EMA AND fast EMA < slow EMA) OR (close < fast EMA AND fast EMA < previous fast EMA) OR (high < low two bars ago) OR confirmed pivot high
Exit: long, close < slow EMA OR short-entry condition OR low <= entry price - ATR * stop multiplier
Exit: short, close > slow EMA OR long-entry condition OR high >= entry price + ATR * stop multiplier