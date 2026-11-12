Calculation: avg_range = mean of (high - low) over the most recent completed bars of a higher timeframe than the chart (excludes the bar still forming), evaluated at the placement hour of each day
Calculation: ref = price (close) of the first chart bar of the placement hour of the day
Calculation: up = ref + 0.5 * stop_dist; dn = ref - 0.5 * stop_dist; where stop_dist = avg_range * stop_pct and tp_dist = avg_range * tp_pct, with tp_pct > stop_pct
Long: current hour is at or after the placement hour and before the removal hour, same day, AND no position has been opened since the placement hour that day (if reversal is enabled, only no same-side entry yet) AND high >= up
Short: current hour is at or after the placement hour and before the removal hour, same day, AND no position has been opened since the placement hour that day (if reversal is enabled, only no same-side entry yet) AND low <= dn
Exit: long, low <= dn OR high >= up + tp_dist
Exit: short, high >= up OR low <= dn - tp_dist