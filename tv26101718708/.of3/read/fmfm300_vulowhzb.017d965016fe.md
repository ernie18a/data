Calculation: Braid spread = max(MA(close, shorter MA length, MA type), MA(open, middle MA length, MA type), MA(close, longer MA length, MA type)) - min(MA(close, shorter MA length, MA type), MA(open, middle MA length, MA type), MA(close, longer MA length, MA type))
Calculation: Braid minimum separation = ATR(braid ATR length) * separation percent / 100
Long: Supertrend(supertrend ATR length, supertrend factor) trend < 0
Short: Supertrend(supertrend ATR length, supertrend factor) trend > 0
Long: MA(close, shorter MA length, MA type) > MA(open, middle MA length, MA type) AND Braid spread > Braid minimum separation
Short: MA(open, middle MA length, MA type) > MA(close, shorter MA length, MA type) AND Braid spread > Braid minimum separation
Long: RSI(close, RSI length) > upper RSI threshold
Short: RSI(close, RSI length) < lower RSI threshold
Calculation: Bullish-candle pressure = IF(close > open, (close - open) * volume, 0)
Calculation: Bearish-candle pressure = IF(close < open, (open - close) * volume, 0)
Calculation: Demand share = 100 * SMA(Bullish-candle pressure, share length) / (SMA(Bullish-candle pressure, share length) + SMA(Bearish-candle pressure, share length)), or 50 when the denominator is 0
Long: Demand share > upper share threshold OR Demand share > lower share threshold
Short: 100 - Demand share > upper share threshold OR 100 - Demand share > lower share threshold
Long: close > open
Short: close < open
Calculation: Net volume = sum over T1, T2, T3 of (SUM(IF(close >= open, volume, 0), net volume lookback) - SUM(IF(close < open, volume, 0), net volume lookback)), each SUM on bars of that timeframe at its last completed bar
Long: Net volume >= 0
Short: Net volume < 0
Calculation: Latest bullish zone = lowest low from the bar of the latest high of ZigZag(zigzag length) through the first later bar whose close is above that high, recorded once per ZigZag high; the latest record is used
Calculation: Latest bearish zone = highest high from the bar of the latest low of ZigZag(zigzag length) through the first later bar whose close is below that low, recorded once per ZigZag low; the latest record is used
Long: close >= Latest bullish zone AND close <= Latest bullish zone + ATR(order block ATR length)
Short: close <= Latest bearish zone AND close >= Latest bearish zone - ATR(order block ATR length)
Calculation: Low slope = (low at latest pivot low - low at previous pivot low) / (bar index of latest pivot low - bar index of previous pivot low), where pivot lows = PivotLow(low, trendline pivot length, trendline pivot length)
Calculation: High slope = (high at latest pivot high - high at previous pivot high) / (bar index of latest pivot high - bar index of previous pivot high), where pivot highs = PivotHigh(high, trendline pivot length, trendline pivot length)
Long: Low slope > 0
Short: High slope < 0
Calculation: Dynamic VWAP = A / B, where A and B are exponentially weighted sums, with weight alpha = 1 - 0.5^(1 / APT length) per bar, of (high + low + close) / 3 * volume and of volume; both restart at the latest swing bar whenever the more recent of the latest highest high and the latest lowest low over swing period changes
Long: close > Dynamic VWAP
Short: close < Dynamic VWAP
Calculation: Band price(m) = open of the current T4 bar * (1 + m * STDEV((close - open) / open, stdev lookback)) on T4 bars, using the T4 bar still forming, fixed at the start of each T4 bar
Option: buy call, high crosses over Band price(call entry multiple) OR high crosses over m for any positive multiple m greater than alert multiple
Option: buy put, low crosses under Band price(m) for any negative multiple m