Calculation: selected Heikin-Ashi SuperTrend direction = fast-multiplier direction in fast mode, otherwise slow-multiplier direction; both use ATR of Heikin-Ashi true range with the ATR lookback.
Calculation: timeframe bias(Tn) = close >= EMA(close, EMA lookback), calculated on Tn bars and sampled onto chart bars with lookahead off, using the forming Tn bar in real time.
Calculation: bullish score = count of bullish timeframe biases for T1–T6, RSI(close, RSI lookback) above its bullish threshold, and Heikin-Ashi close > Heikin-Ashi open.
Calculation: bearish score = count of bearish timeframe biases for T1–T6, RSI(close, RSI lookback) below its bearish threshold, and Heikin-Ashi close < Heikin-Ashi open.
Long: selected Heikin-Ashi SuperTrend direction is bullish.
Short: selected Heikin-Ashi SuperTrend direction is bearish.
Long: primary signals are enabled, mode selects flip signals, and selected Heikin-Ashi SuperTrend direction changes from bearish to bullish, with no selected-impact news event within the enabled blackout window and no enabled macro buy block.
Short: primary signals are enabled, mode selects flip signals, and selected Heikin-Ashi SuperTrend direction changes from bullish to bearish, with no selected-impact news event within the enabled blackout window and no enabled macro sell block.
Long: primary signals are enabled, mode selects filter signals, selected Heikin-Ashi SuperTrend direction is bullish, high > highest(high, breakout lookback)[1], and the last filter signal was not long; apply the enabled news and macro buy filters.
Short: primary signals are enabled, mode selects filter signals, selected Heikin-Ashi SuperTrend direction is bearish, low < lowest(low, breakout lookback)[1], and the last filter signal was not short; apply the enabled news and macro sell filters.
Long: confirmation signals are enabled, selected Heikin-Ashi SuperTrend direction is bullish, Heikin-Ashi close >= Heikin-Ashi open, the consecutive bullish Heikin-Ashi run is no longer than the early-run parameter, abs(Heikin-Ashi close − Heikin-Ashi open) >= body-ATR parameter × ATR(Heikin-Ashi true range, ATR lookback), abs(Heikin-Ashi close − Heikin-Ashi open) >= body-range parameter × max(Heikin-Ashi high − Heikin-Ashi low, minimum price increment), lower wick <= tail parameter × max(Heikin-Ashi high − Heikin-Ashi low, minimum price increment), at least the confirmation-gap parameter chart bars have passed since the previous qualifying confirmation setup, and there is no primary signal on this or the previous chart bar.
Short: confirmation signals are enabled, selected Heikin-Ashi SuperTrend direction is bearish, Heikin-Ashi close < Heikin-Ashi open, the consecutive bearish Heikin-Ashi run is no longer than the early-run parameter, abs(Heikin-Ashi close − Heikin-Ashi open) >= body-ATR parameter × ATR(Heikin-Ashi true range, ATR lookback), abs(Heikin-Ashi close − Heikin-Ashi open) >= body-range parameter × max(Heikin-Ashi high − Heikin-Ashi low, minimum price increment), upper wick <= tail parameter × max(Heikin-Ashi high − Heikin-Ashi low, minimum price increment), at least the confirmation-gap parameter chart bars have passed since the previous qualifying confirmation setup, and there is no primary signal on this or the previous chart bar.
Exit: long, target has not previously been hit and high >= entry price + target-one multiplier × ATR(Heikin-Ashi true range, ATR lookback) at entry.
Exit: long, target has not previously been hit and high >= entry price + target-two multiplier × ATR(Heikin-Ashi true range, ATR lookback) at entry.
Exit: long, target has not previously been hit and high >= entry price + target-three multiplier × ATR(Heikin-Ashi true range, ATR lookback) at entry.
Exit: short, target has not previously been hit and low <= entry price − target-one multiplier × ATR(Heikin-Ashi true range, ATR lookback) at entry.
Exit: short, target has not previously been hit and low <= entry price − target-two multiplier × ATR(Heikin-Ashi true range, ATR lookback) at entry.
Exit: short, target has not previously been hit and low <= entry price − target-three multiplier × ATR(Heikin-Ashi true range, ATR lookback) at entry.
Long: for each of T1–T6 separately, timeframe bias(Tn) is bullish.
Short: for each of T1–T6 separately, timeframe bias(Tn) is bearish.
Long: a majority of timeframe biases T1–T3 are bullish.
Short: a majority of timeframe biases T1–T3 are bearish.
Long: a majority of timeframe biases T4–T6 are bullish.
Short: a majority of timeframe biases T4–T6 are bearish.
Long: bullish score >= bearish score and max(bullish score, bearish score) >= the minimum judge score.
Short: bearish score > bullish score and max(bullish score, bearish score) >= the minimum judge score.
Long: structure marks are enabled and close > the latest stored qualifying confirmed pivot high; a new confirmed pivot replaces it if higher or if the stored pivot exceeds the stale-age parameter, and the pivot clears after the break.
Short: structure marks are enabled and close < the latest stored qualifying confirmed pivot low; a new confirmed pivot replaces it if lower or if the stored pivot exceeds the stale-age parameter, and the pivot clears after the break.
Long: weekly COT noncommercial net position (long positions − short positions), sampled onto chart bars with lookahead off, is greater than its prior value.
Short: weekly COT noncommercial net position (long positions − short positions), sampled onto chart bars with lookahead off, is less than or equal to its prior value.
Long: the enabled macro filter allows buying: for DXY or US10Y selection, the selected T6 external close is above its chart-bar EMA(mapped T6 close, macro lookback); for Both, at least one is not above its EMA. Missing external values count as not above.
Short: the enabled macro filter allows selling: for DXY or US10Y selection, the selected T6 external close is above its chart-bar EMA(mapped T6 close, macro lookback); for Both, at least one is above its EMA. Missing external values count as not above.
Long: no selected-impact news event has chart-bar datetime within the enabled blackout interval from event time minus the before-window to event time plus the after-window.
Short: no selected-impact news event has chart-bar datetime within the enabled blackout interval from event time minus the before-window to event time plus the after-window.