Calculation: Evaluation bars = chart bars or bars aggregated to a selected higher or lower timeframe. For a higher timeframe, use the last completed bar; for a lower timeframe, use the last completed lower-timeframe bar within each chart bar.
Calculation: Momentum = linear regression value at the current bar of close minus the average of (1) the average of the highest high and lowest low over the lookback and (2) the SMA of close over the same lookback, using that lookback for the regression. Replace unavailable prior momentum values with zero.
Calculation: Squeeze fired = the current Bollinger lower band is below the lower wide Keltner band OR the current Bollinger upper band is above the upper wide Keltner band, AND on the previous bar the Bollinger lower band was at or above the lower wide Keltner band OR the Bollinger upper band was at or below the upper wide Keltner band. Both bands use the same SMA of close and lookback; Bollinger width is a standard-deviation multiple and Keltner width is a multiple of the SMA of true range.
Calculation: Live direction = on a squeeze fire, long if momentum > 0, short if momentum < 0, otherwise idle; on subsequent bars, retain the direction only while momentum remains on its original side of zero and the selected rollover rule has not occurred. A new squeeze fire takes precedence. For long, rollover is either one consecutive momentum decline, two consecutive momentum declines, or momentum <= 0; for short, rollover is either one consecutive momentum rise, two consecutive momentum rises, or momentum >= 0. Select one rollover rule.
Long: Squeeze fired AND momentum > 0.
Short: Squeeze fired AND momentum < 0.
Long: Live direction is long AND momentum >= previous momentum.
Short: Live direction is short AND momentum <= previous momentum.
Long: Momentum > 0 AND momentum >= previous momentum.
Short: Momentum < 0 AND momentum <= previous momentum.
Long: Each enabled moving average is greater than the next longer moving average, using the same selected price source and SMA, EMA, or DEMA type; if the fourth moving average is disabled, the fifth is also excluded from this comparison.
Short: Each enabled moving average is less than the next longer moving average, using the same selected price source and SMA, EMA, or DEMA type; if the fourth moving average is disabled, the fifth is also excluded from this comparison.
Long: ADX >= threshold AND positive directional indicator > negative directional indicator, using the same lookback for directional indicators and ADX smoothing.
Short: ADX >= threshold AND positive directional indicator <= negative directional indicator, using the same lookback for directional indicators and ADX smoothing.
Exit: long, previous live direction is long AND squeeze has not fired AND (momentum <= 0 OR the selected long rollover rule has occurred).
Exit: short, previous live direction is short AND squeeze has not fired AND (momentum >= 0 OR the selected short rollover rule has occurred).