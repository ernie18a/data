Calculation: Candle momentum = the difference between a selected price of the current bar and a second selected price of the bar at the momentum lookback offset, counting the current bar as the first bar, smoothed successively three times with the same selected moving-average method and independently chosen smoothing periods. Calculate it on the chart timeframe for indicator markings and on a higher timeframe for trading decisions; for the latter use the last completed higher-timeframe bar, or the still-forming higher-timeframe bar when configured to do so. Prior values refer to preceding bars of the same timeframe.
Long: Chart-timeframe candle momentum > 0 AND chart-timeframe candle momentum != its previous value
Short: Chart-timeframe candle momentum < 0 AND chart-timeframe candle momentum != its previous value
Long: Higher-timeframe candle momentum > 0 AND its previous value <= 0
Short: Higher-timeframe candle momentum < 0 AND its previous value >= 0
Long: Higher-timeframe candle momentum > its previous value AND its previous value <= its value two bars ago
Short: Higher-timeframe candle momentum < its previous value AND its previous value >= its value two bars ago
Exit: long, higher-timeframe candle momentum < 0
Exit: short, higher-timeframe candle momentum > 0
Exit: long, higher-timeframe candle momentum < its previous value
Exit: short, higher-timeframe candle momentum > its previous value
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance