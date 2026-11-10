Calculation: Price RSI = RSI of a selected price source.
Calculation: Candle RSI = RSI of (open + high + low + close) / 4, using the same length as Price RSI.
Calculation: Fast and slow double-smoothed RSI = 2 × EMA(Candle RSI) − EMA(EMA(Candle RSI)), using respectively the fast and slow EMA lengths; the fast length is shorter than the slow length. The reference RSI EMA is EMA(Candle RSI) using the RSI length.
Calculation: Dynamic RSI upper and lower bounds = respectively the rounded mean of Price RSI values strictly above the upper threshold and strictly below the lower threshold, over their respective lookbacks including the current bar and the bar at the lookback offset. A bound is undefined when no value qualifies.
Calculation: Stochastic K = a selected SMA, EMA, or WMA of 100 × (Price RSI − lowest dynamic RSI lower bound) / (highest dynamic RSI upper bound − lowest dynamic RSI lower bound), with the extrema taken over the RSI length. Stochastic D = SMA of K using a separate smoothing length.
Calculation: Price movement extrema = for each chart bar and each index i descending from the price lookback to zero, initialize both extrema to the current bar's high and low at i = lookback; otherwise set the high extremum to high[i] if high[i] > high[i+1], or to the preceding chart bar's high-extremum value at that loop iteration; set the low extremum to low[i] if low[i] < low[i+1], or to the preceding chart bar's low-extremum value at that loop iteration. Use the final extrema after the loop.
Calculation: Dip = close < open[price lookback] AND price movement high extremum > open[price lookback] AND price movement low extremum < open[price lookback] AND price movement high extremum > open[1] AND price movement low extremum < open[1] AND close[1] < open[1].
Calculation: Peak = close > open[price lookback] AND price movement high extremum > open[price lookback] AND price movement low extremum > open[price lookback] AND price movement high extremum > open[1] AND price movement low extremum < open[1] AND close[1] > open[1].
Calculation: Connors buy = shorter close SMA < longer close SMA AND longer close SMA > close AND Price RSI ≤ oversold threshold AND Dip AND datetime is within the configured date window. Connors sell = shortest close SMA > intermediate close SMA AND open > longest close SMA AND Price RSI ≥ overbought threshold AND Peak AND datetime is within the configured date window; the intermediate and longest SMAs are the shorter and longer SMAs used in Connors buy.
Calculation: MACD buy = MACD line > signal line AND Price RSI < dynamic RSI lower bound AND close < open[price lookback] AND datetime is within the configured date window. MACD sell = MACD line < signal line AND Price RSI > dynamic RSI upper bound AND close > open[price lookback] AND datetime is within the configured date window. MACD uses the fast and slow EMA lengths and the RSI length as its signal length.
Calculation: Reverse RSI buy = Price RSI crosses above the oversold threshold AND close > open[price lookback] AND datetime is within the configured date window. Reverse RSI sell = Price RSI crosses below the overbought threshold AND close < open[price lookback] AND datetime is within the configured date window.
Calculation: Default RSI buy = Price RSI < oversold threshold AND Dip AND datetime is within the configured date window. Default RSI sell = Price RSI > overbought threshold AND Peak AND datetime is within the configured date window.
Calculation: Stochastic buy = K crosses above D AND datetime is within the configured date window. Stochastic sell = K crosses below D AND datetime is within the configured date window.
Long: Fast double-smoothed RSI crosses below the reference RSI EMA AND datetime is within the configured date window.
Short: Fast double-smoothed RSI crosses above slow double-smoothed RSI AND datetime is within the configured date window.
Long: Fast double-smoothed RSI > slow double-smoothed RSI.
Short: Fast double-smoothed RSI < slow double-smoothed RSI.
Long: K > oversold threshold AND D < overbought threshold AND K > D AND K > K[1] AND D > D[1].
Short: K < overbought threshold AND D > oversold threshold AND K < D AND K < K[1] AND D < D[1].
Long: Connors buy.
Short: Connors sell.
Long: Connors mode is enabled AND close > intermediate close SMA AND close < longest close SMA AND Price RSI ≤ oversold threshold.
Short: Connors mode is enabled AND close < intermediate close SMA AND close > longest close SMA AND Price RSI ≤ overbought threshold AND the Connors-mode long coloring condition is false.
Long: MACD line > signal line AND K > the oscillator midpoint AND Price RSI > the oscillator midpoint.
Short: MACD line < signal line AND K < the oscillator midpoint AND Price RSI < the oscillator midpoint.
Long: MACD buy.
Short: MACD sell.
Long: Reverse RSI buy.
Short: Reverse RSI sell.
Long: Default RSI buy.
Short: Default RSI sell.
Long: Stochastic buy.
Short: Stochastic sell.
Long: Position is flat AND long trading is enabled AND Candle RSI > Price RSI AND K < D AND the selected entry condition is true. Select the first enabled mode in this order: reverse RSI buy, MACD buy, Connors buy, stochastic buy; if none is enabled, select default RSI buy.
Short: Position is flat AND short trading is enabled AND Candle RSI < Price RSI AND D < K AND the selected entry condition is true. Select the first enabled mode in this order: reverse RSI sell, MACD sell, Connors sell, stochastic sell; if none is enabled, select default RSI sell.
Exit: long, low ≤ entry price × (1 − stop-loss fraction) OR high ≥ entry price × (1 + take-profit fraction).
Exit: short, high ≥ entry price × (1 + stop-loss fraction) OR low ≤ entry price × (1 − take-profit fraction).
Exit: long, long trading is enabled AND Candle RSI > Price RSI AND D > K AND the selected exit condition is true. Select the first enabled mode in this order: reverse RSI sell, MACD sell, Connors sell; if none is enabled, select default RSI sell.
Exit: short, short trading is enabled AND Candle RSI < Price RSI AND K > D AND the selected exit condition is true. Select the first enabled mode in this order: reverse RSI buy, MACD buy, Connors buy; if none is enabled, select default RSI buy.