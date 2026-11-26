Calculation: SMA slope = (SMA(close, moving-average lookback) - SMA(close, moving-average lookback)[slope lookback]) / ATR(ATR lookback)
Calculation: Bullish displacement = close > open AND abs(close - open) / ATR(ATR lookback) >= displacement threshold
Calculation: Bearish displacement = close < open AND abs(close - open) / ATR(ATR lookback) >= displacement threshold
Calculation: Latest confirmed swing high = most recent confirmed PivotHigh(high, swing lookback, swing lookback)
Calculation: Latest confirmed swing low = most recent confirmed PivotLow(low, swing lookback, swing lookback)
Calculation: Swing break direction = prior direction, initially neutral; set bullish when close crosses above the latest confirmed swing high, then set bearish when close crosses below the latest confirmed swing low
Calculation: Bullish BOS = close crosses above the latest confirmed swing high AND prior swing break direction is not bearish
Calculation: Bullish CHoCH = close crosses above the latest confirmed swing high AND prior swing break direction is bearish
Calculation: Bearish BOS = close crosses below the latest confirmed swing low AND prior swing break direction is not bullish
Calculation: Bearish CHoCH = close crosses below the latest confirmed swing low AND prior swing break direction is bullish
Calculation: Recent bullish BOS = bars since Bullish BOS <= BOS/CHoCH memory
Calculation: Recent bearish BOS = bars since Bearish BOS <= BOS/CHoCH memory
Calculation: Recent bullish CHoCH = bars since Bullish CHoCH <= BOS/CHoCH memory
Calculation: Recent bearish CHoCH = bars since Bearish CHoCH <= BOS/CHoCH memory
Calculation: Bullish FVG = low > high[FVG gap offset]
Calculation: Bearish FVG = high < low[FVG gap offset]
Calculation: Recent bullish FVG = bars since Bullish FVG <= FVG memory
Calculation: Recent bearish FVG = bars since Bearish FVG <= FVG memory
Calculation: Bullish order block active = the latest saved bullish order block, updated on bullish displacement to the nearest preceding bearish candle within the order-block search lookback if one exists, is within the order-block maximum age and close >= its low
Calculation: Bearish order block active = the latest saved bearish order block, updated on bearish displacement to the nearest preceding bullish candle within the order-block search lookback if one exists, is within the order-block maximum age and close <= its high
Calculation: Bullish swing structure = latest confirmed swing high > preceding confirmed swing high AND latest confirmed swing low > preceding confirmed swing low
Calculation: Bearish swing structure = latest confirmed swing high < preceding confirmed swing high AND latest confirmed swing low < preceding confirmed swing low
Calculation: Regime score = clamp((price score weight if close > SMA(close, moving-average lookback), negative price score weight if close < SMA(close, moving-average lookback), otherwise 0) + (slope score weight if SMA slope > slope ATR threshold, negative slope score weight if SMA slope < -slope ATR threshold, otherwise 0) + (displacement score weight if Bullish displacement, negative displacement score weight if Bearish displacement, otherwise 0) + (relative-volume score weight if RVOL(volume, relative-volume lookback) >= relative-volume threshold AND close > open, negative relative-volume score weight if RVOL(volume, relative-volume lookback) >= relative-volume threshold AND close < open, otherwise 0) + (swing-structure score weight if Bullish swing structure, negative swing-structure score weight if Bearish swing structure, otherwise 0) + (BOS score weight if Recent bullish BOS AND NOT Recent bearish BOS, negative BOS score weight if Recent bearish BOS AND NOT Recent bullish BOS, otherwise 0) + (CHoCH score weight if Recent bullish CHoCH AND NOT Recent bearish CHoCH, negative CHoCH score weight if Recent bearish CHoCH AND NOT Recent bullish CHoCH, otherwise 0) + (ADX score weight if ADX(DMI length, ADX smoothing) >= ADX threshold AND +DI > -DI AND close > SMA(close, moving-average lookback), negative ADX score weight if ADX(DMI length, ADX smoothing) >= ADX threshold AND -DI > +DI AND close < SMA(close, moving-average lookback), otherwise 0) + (FVG score weight if Recent bullish FVG AND NOT Recent bearish FVG, negative FVG score weight if Recent bearish FVG AND NOT Recent bullish FVG, otherwise 0) + (order-block score weight if Bullish order block active AND NOT Bearish order block active, negative order-block score weight if Bearish order block active AND NOT Bullish order block active, otherwise 0), -regime score cap, regime score cap)
Calculation: Raw regime = +2 if Regime score >= strong-bull threshold; otherwise +1 if Regime score >= bull threshold; otherwise -2 if Regime score <= strong-bear threshold; otherwise -1 if Regime score <= bear threshold; otherwise 0
Calculation: Confirmed regime = change to a different Raw regime only after it remains the candidate for the regime confirmation lookback; otherwise retain the prior confirmed regime
Long: Bullish BOS
Long: Bullish CHoCH
Long: Recent bullish BOS AND NOT Recent bearish BOS
Long: Recent bullish CHoCH AND NOT Recent bearish CHoCH
Long: Recent bullish FVG AND NOT Recent bearish FVG
Long: Bullish order block active AND NOT Bearish order block active
Long: Confirmed regime > 0
Long: Confirmed regime changes to a positive regime
Short: Bearish BOS
Short: Bearish CHoCH
Short: Recent bearish BOS AND NOT Recent bullish BOS
Short: Recent bearish CHoCH AND NOT Recent bullish CHoCH
Short: Recent bearish FVG AND NOT Recent bullish FVG
Short: Bearish order block active AND NOT Bullish order block active
Short: Confirmed regime < 0
Short: Confirmed regime changes to a negative regime