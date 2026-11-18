Calculation: smoothed rate of change = EMA(ROC(chart-bar close, rate-of-change lookback), half the rate-of-change lookback)
Long: Heikin-Ashi open of T1's still-forming bar, sampled on chart bars < Heikin-Ashi close of T1's still-forming bar, sampled on chart bars AND (smoothed rate of change > movement threshold / 2 OR smoothed rate of change < -movement threshold / 2)
Short: Heikin-Ashi open of T1's still-forming bar, sampled on chart bars > Heikin-Ashi close of T1's still-forming bar, sampled on chart bars AND (smoothed rate of change > movement threshold / 2 OR smoothed rate of change < -movement threshold / 2)
Long: Heikin-Ashi open of T1's still-forming bar, sampled on chart bars < Heikin-Ashi close of T1's still-forming bar, sampled on chart bars
Short: Heikin-Ashi open of T1's still-forming bar, sampled on chart bars >= Heikin-Ashi close of T1's still-forming bar, sampled on chart bars
Calculation: latest long-condition time = latest chart-bar datetime satisfying the long-entry condition, or zero if none
Calculation: latest short-condition time = latest chart-bar datetime satisfying the short-entry condition, or zero if none
Long: crossover(latest long-condition time, latest short-condition time)
Short: crossover(latest short-condition time, latest long-condition time)
Calculation: latest long-signal time = latest chart-bar datetime satisfying crossover(latest long-condition time, latest short-condition time), or zero if none
Calculation: latest short-signal time = latest chart-bar datetime satisfying crossover(latest short-condition time, latest long-condition time), or zero if none
Calculation: captured long-signal open = chart-bar open on a long-signal bar, otherwise its prior value, initially zero
Calculation: captured short-signal open = chart-bar open on a short-signal bar, otherwise its prior value, initially zero
Exit: long, barssince(captured long-signal open != captured long-signal open[1]) > 0 AND ((latest long-signal time > latest short-signal time AND chart-bar low <= entry price * (1 - stop-loss parameter)) OR chart-bar high >= entry price * (1 + take-profit parameter))
Exit: short, barssince(captured short-signal open != captured short-signal open[1]) > 0 AND ((latest short-signal time > latest long-signal time AND chart-bar high >= entry price * (1 + stop-loss parameter)) OR chart-bar low <= entry price * (1 - take-profit parameter))