Calculation: Confirmed pivot high or low = a high or low identified using the same lookback on each side; it becomes available only after the right-hand bars have completed.
Calculation: Trendline = the line through the two most recent confirmed pivot lows or highs, extended to the current and previous bars.
Calculation: Positive divergence = on confirmation of a pivot low, its low is below the preceding pivot low and an indicator at that pivot is above its value at the preceding pivot low, OR its low is above the preceding pivot low and the indicator is below its preceding value. Count qualifying indicators from MACD line, MACD histogram, RSI, stochastic, CCI, momentum, OBV, fast VWMA minus slow VWMA, CMF, and MFI.
Calculation: Negative divergence = on confirmation of a pivot high, its high is above the preceding pivot high and an indicator at that pivot is below its value at the preceding pivot high, OR its high is below the preceding pivot high and the indicator is above its preceding value. Count the same indicators as for positive divergence.
Long: Positive divergence count >= divergence threshold.
Short: Negative divergence count >= divergence threshold.
Long: Shorter-period micro EMA crosses above longer-period micro EMA AND, if candle confirmation is required, close > open.
Short: Shorter-period micro EMA crosses below longer-period micro EMA AND, if candle confirmation is required, close < open.
Long: Close crosses above the latest confirmed pivot high, using either the shorter or longer structure lookback.
Short: Close crosses below the latest confirmed pivot low, using either the shorter or longer structure lookback.
Long: The latest confirmed pivot high is below the preceding pivot high AND close crosses above their trendline, OR high crosses above their trendline when wick confirmation is selected.
Short: The latest confirmed pivot low is above the preceding pivot low AND close crosses below their trendline, OR low crosses below their trendline when wick confirmation is selected.

This is a partial framework: the main buy, reversal, order-block, warning, and exit decisions require additional definitions. Some main-buy configurations also depend on a separate benchmark series, which is unavailable under the specified backtest data fields.