Calculation: RSI = Wilder RSI of close, optionally smoothed by an EMA.
Calculation: MACD histogram = MACD line minus its signal EMA; MACD uses a shorter and a longer close EMA.
Calculation: VIDYA = recursively smooth a selectable price source with alpha = 2 / (VIDYA period + 1) × absolute CMO / 100; calculate CMO from rolling sums of positive and negative source changes, and initialize VIDYA to the source.
Calculation: OBV = cumulative volume added when close rises and subtracted when close falls; leave it unchanged when close is unchanged.
Long: (RSI > its midpoint AND RSI < overbought threshold) OR RSI <= oversold threshold
Short: (RSI < its midpoint AND RSI > oversold threshold) OR RSI >= overbought threshold
Long: (close EMA > its previous value AND MACD histogram > its previous value) OR (MACD histogram > 0 AND close EMA > its previous value AND NOT (close EMA < its previous value AND MACD histogram < its previous value)) OR (MACD histogram < 0 AND MACD histogram > its previous value AND MACD histogram > its value two bars ago AND close EMA >= its previous value)
Short: (close EMA < its previous value AND MACD histogram < its previous value) OR (MACD histogram < 0 AND close EMA < its previous value AND NOT (close EMA > its previous value AND MACD histogram > its previous value)) OR (MACD histogram > 0 AND MACD histogram < its previous value AND MACD histogram < its value two bars ago AND close EMA <= its previous value)
Long: VIDYA > its previous value AND close != VIDYA
Short: VIDYA < its previous value AND close != VIDYA
Long: volume >= low-volume fraction × longer volume SMA AND volume > shorter volume SMA AND OBV > its SMA AND OBV > its previous value
Short: volume >= low-volume fraction × longer volume SMA AND volume > shorter volume SMA AND OBV < its SMA AND OBV < its previous value
Long: (close > open AND absolute candle body > body-dominance fraction × candle range) OR (absolute candle body <= body-dominance fraction × candle range AND lower wick > wick threshold × candle range AND upper wick <= wick threshold × candle range)
Short: (close < open AND absolute candle body > body-dominance fraction × candle range) OR (absolute candle body <= body-dominance fraction × candle range AND upper wick > wick threshold × candle range AND lower wick <= wick threshold × candle range)