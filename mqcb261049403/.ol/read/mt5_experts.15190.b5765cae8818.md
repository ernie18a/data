Calculation: Mean candle body = simple moving average of close minus open over a configurable lookback.
Long: Chart-timeframe mean candle body > 0.
Short: Chart-timeframe mean candle body < 0.
Long: On a configurable indicator timeframe, which may be the chart timeframe or a higher or lower timeframe, mean candle body on the selected bar > 0 AND mean candle body on the immediately preceding bar < 0; the selected bar may be the last completed bar, an earlier completed bar, or the bar still forming.
Short: On the same selected indicator-timeframe bar, mean candle body < 0 AND mean candle body on the immediately preceding bar > 0.
Exit: long, mean candle body on the selected indicator-timeframe bar < 0.
Exit: short, mean candle body on the selected indicator-timeframe bar > 0.
Exit: long, low <= entry price minus the configured stop-loss distance OR high >= entry price plus the configured take-profit distance.
Exit: short, high >= entry price plus the configured stop-loss distance OR low <= entry price minus the configured take-profit distance.