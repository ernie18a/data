Calculation: Return = either log(price source / previous price source) or (price source - previous price source) / max(abs(previous price source), epsilon); on the first bar use the current price source as the previous source.
Calculation: Residual = optionally EMA-smoothed volume minus expected volume, where expected volume is the rolling mean of smoothed volume multiplied by absolute return divided by the rolling mean of absolute return; if the latter mean is zero, use the rolling mean of smoothed volume as expected volume.
Calculation: Residual Z = (residual - rolling mean of residual) / rolling population standard deviation of residual, using the same window as expected volume; use zero when the standard deviation is zero.
Calculation: Buy block = residual Z >= positive block threshold AND return > 0 AND bars since the previous buy block >= cooldown; initialize the previous buy block index to -10000.
Calculation: Sell block = residual Z >= positive block threshold AND return < 0 AND bars since the previous sell block >= cooldown; initialize the previous sell block index to -10000.
Calculation: Session block counts = counts of buy blocks and sell blocks since the start of the current daily session, including the current bar.
Calculation: Cumulative implied delta = cumulative sum of residual on buy blocks minus residual on sell blocks, starting at zero.
Long: Buy block = true
Short: Sell block = true
Long: Session buy block count >= session sell block count
Short: Session buy block count < session sell block count
Long: Cumulative implied delta > 0
Short: Cumulative implied delta < 0
Long: Most recent buy block index > most recent sell block index
Short: Most recent sell block index > most recent buy block index