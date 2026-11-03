Calculation: For each timeframe, let Δ be the close-to-close change on each of the last N bars. Let U be the sum of positive Δ values, D the sum of absolute negative Δ values, u_i the running sum of consecutive positive Δ values ending at bar i (zero if Δ_i ≤ 0), and d_i the running sum of consecutive absolute negative Δ values ending at bar i (zero if Δ_i ≥ 0). Trend upper = U − sum(d_i); trend lower = D − sum(u_i).
Long: Trend upper > trend lower on the chart timeframe
Long: Trend upper > trend lower on a higher timeframe, using its bar still forming
Short: Trend upper < trend lower on the chart timeframe
Short: Trend upper < trend lower on a higher timeframe, using its bar still forming