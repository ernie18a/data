Calculation: Channel bands = apply a linear weighted moving average twice to highs for the upper band and twice to lows for the lower band, using the same lookback for all four averages. The chart-timeframe bands include a configurable vertical price offset; the higher-timeframe bands have no offset and use the last completed higher-timeframe bar and its preceding bar.
Long: Chart close > chart upper band.
Short: Chart close < chart lower band.
Long: Higher-timeframe close > higher-timeframe upper band AND preceding higher-timeframe close <= its upper band.
Short: Higher-timeframe close < higher-timeframe lower band AND preceding higher-timeframe close >= its lower band.
Exit: long, higher-timeframe close < higher-timeframe lower band OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, higher-timeframe close > higher-timeframe upper band OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.