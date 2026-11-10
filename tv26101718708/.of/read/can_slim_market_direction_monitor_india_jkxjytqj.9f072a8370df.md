Calculation: Percentage change = (close / previous close - 1) × 100.
Calculation: Distribution day = percentage change ≤ a negative threshold AND volume > previous volume.
Calculation: Stalling day = percentage change > 0 AND percentage change < a positive threshold AND volume > previous volume AND close < (high + low) / 2.
Calculation: Distribution count = sum of weights of active distribution and enabled stalling days; a distribution day has full weight and a stalling day has half weight. Add the current bar before removing events whose age exceeds the lookback or whose low has been exceeded by a specified rally percentage by the high of any subsequent bar.
Calculation: Rally day = a counter initially 0, with an initially unset rally low and its bar. On each bar, first, if close < the shorter-period SMA or close < the highest high over a lookback reduced by a percentage, and the rally low is unset or current low < rally low, set the rally low and its bar to the current low and bar and set the counter to 0. Next, if the counter is 0, the rally low is set, the current bar is later than its bar, and close > previous close, set the counter to 1; otherwise, if the counter ≥ 1, set the rally low and its bar to the current low and bar and the counter to 0 when low < rally low, or increment the counter when low ≥ rally low. Finally, if the counter exceeds the maximum follow-through day plus a separate expiry offset, set the counter to 0 and unset the rally low.
Calculation: Red phase = distribution count ≥ the higher count threshold OR (close ≤ the longer-period SMA AND that SMA ≤ its value a specified number of bars earlier).
Calculation: Green phase = distribution count < the lower count threshold AND close > the shorter-period SMA AND close > the longer-period SMA.
Long: Rally day ≥ the minimum follow-through day AND rally day ≤ the maximum follow-through day AND percentage change ≥ the follow-through gain threshold AND volume > previous volume.
Long: Green phase.
Long: Close > the shorter-period SMA OR close > the longer-period SMA.
Long: Shorter-period SMA > longer-period SMA.
Long: Close > a separate intermediate-period SMA AND that SMA > its value a specified number of bars earlier.
Long: Close / highest high over a separate lookback - 1 > the higher drawdown threshold.
Short: Distribution day OR enabled stalling day.
Short: Red phase.
Short: Close ≤ the shorter-period SMA OR close ≤ the longer-period SMA.
Short: Shorter-period SMA ≤ longer-period SMA.
Short: Close ≤ a separate intermediate-period SMA AND that SMA ≤ its value a specified number of bars earlier.
Short: Close / highest high over a separate lookback - 1 ≤ the lower drawdown threshold.
Exit: long, red phase.