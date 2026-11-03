Calculation: Fast EMA, slower EMA, medium SMA, and long SMA are ordered from shortest to longest lookback.
Calculation: Rising fast EMA = fast EMA is above its value several bars earlier.
Calculation: Rising medium SMA = its percentage change over a multi-bar lookback is positive.
Calculation: Reclaim of an average = close is above that average, but was not above it several bars earlier.
Calculation: Loss of an average = close is below that average, but was not below it several bars earlier.
Calculation: Bullish stack = fast EMA > slower EMA > medium SMA > long SMA.
Calculation: Bearish stack = fast EMA < slower EMA < medium SMA < long SMA.
Calculation: Near an average = absolute percentage distance from price to that average is below a configurable proximity threshold.
Calculation: Bullish long-SMA approach = medium SMA is at or below long SMA, medium SMA is rising, and the two averages are near.
Calculation: Bearish long-SMA approach = medium SMA is above long SMA, medium SMA is falling, and the two averages are near.
Calculation: Bullish medium-SMA approach = slower EMA is at or below medium SMA, fast EMA > slower EMA, slower EMA is rising, and the two averages are near.
Calculation: Pullback above slower EMA = close is above slower EMA and its percentage distance above it is within a configurable range that may extend slightly below the average.
Calculation: Reversal = reclaim of either slower EMA or medium SMA, or loss of either slower EMA or medium SMA.
Calculation: Breakout = medium SMA crosses above long SMA, medium SMA approaches long SMA bullishly or bearishly, or price is above medium SMA and near long SMA while at or below it.
Calculation: Early trend = not Reversal, not Breakout, and either fast EMA > slower EMA with slower EMA crossing above medium SMA, bullish medium-SMA approach, or fast EMA at or below slower EMA with slower EMA at or below medium SMA after being above it several bars earlier.
Calculation: Trend continuation = not Reversal, not Breakout, not Early trend, and either Bullish stack, Pullback above slower EMA, close above fast EMA with Rising fast EMA and Bullish stack, or Bearish stack.
Long: Reclaim of slower EMA OR reclaim of medium SMA OR (not Reversal AND (medium SMA crosses above long SMA OR Bullish long-SMA approach OR close > medium SMA AND close is at or below long SMA AND price is near long SMA)) OR Early trend with fast EMA > slower EMA and slower EMA crossing above medium SMA OR Early trend with Bullish medium-SMA approach OR Trend continuation with Bullish stack OR Trend continuation with Pullback above slower EMA OR Trend continuation with close > fast EMA and Rising fast EMA and Bullish stack
Short: Loss of slower EMA OR loss of medium SMA OR (not Reversal AND (medium SMA crosses below long SMA OR Bearish long-SMA approach)) OR Early trend with fast EMA at or below slower EMA and slower EMA at or below medium SMA after being above it several bars earlier OR Trend continuation with Bearish stack