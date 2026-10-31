Calculation: First smoothed RSI = a configurable moving average of RSI of a configurable OHLC-derived price.
Calculation: Second smoothed RSI = a second configurable moving average applied to the first smoothed RSI, with independently configurable method and lookback.
Long: First smoothed RSI > second smoothed RSI on the chart timeframe.
Short: First smoothed RSI < second smoothed RSI on the chart timeframe.
Long: On a higher timeframe, first smoothed RSI > second smoothed RSI on the last completed bar AND first smoothed RSI <= second smoothed RSI on the preceding bar.
Short: On a higher timeframe, first smoothed RSI < second smoothed RSI on the last completed bar AND first smoothed RSI >= second smoothed RSI on the preceding bar.
Exit: long, first smoothed RSI < second smoothed RSI on the last completed higher-timeframe bar.
Exit: short, first smoothed RSI > second smoothed RSI on the last completed higher-timeframe bar.
Exit: long, low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance.
Exit: short, high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance.