Calculation: Candle stochastic index = 100 times the three-stage smoothed difference between a selected price on the current bar and another selected price on the bar at the start of the momentum lookback, divided by the identically three-stage smoothed difference between the highest high and lowest low over that lookback; use zero when the smoothed range is zero. Each successive smoothing stage has its own period and uses the same selected smoothing method.
Calculation: Signal index = candle stochastic index on the selected indicator timeframe, which may be higher or lower than the chart timeframe; use the last completed indicator bar or the still-forming indicator bar according to the selected signal-bar setting. Previous values refer to preceding indicator bars.
Long: Chart-timeframe candle stochastic index > 0 AND chart-timeframe candle stochastic index > its previous value
Long: Chart-timeframe candle stochastic index < 0 AND chart-timeframe candle stochastic index > its previous value
Short: Chart-timeframe candle stochastic index > 0 AND chart-timeframe candle stochastic index < its previous value
Short: Chart-timeframe candle stochastic index < 0 AND chart-timeframe candle stochastic index < its previous value
Long: Zero-crossing mode AND signal index > 0 AND previous signal index <= 0
Short: Zero-crossing mode AND signal index < 0 AND previous signal index >= 0
Long: Direction-change mode AND signal index > previous signal index AND previous signal index <= signal index two bars earlier
Short: Direction-change mode AND signal index < previous signal index AND previous signal index >= signal index two bars earlier
Exit: long, zero-crossing mode AND signal index < 0
Exit: short, zero-crossing mode AND signal index > 0
Exit: long, direction-change mode AND signal index < previous signal index
Exit: short, direction-change mode AND signal index > previous signal index
Exit: long, low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance
Exit: short, high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance