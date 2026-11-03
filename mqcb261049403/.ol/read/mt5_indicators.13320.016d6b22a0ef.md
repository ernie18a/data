Calculation: Smoothed momentum = JMA-smoothed difference between a shorter-lookback and a longer-lookback weighted filter of close
Long: Smoothed momentum > 0 AND Smoothed momentum >= previous bar's smoothed momentum
Short: Smoothed momentum < 0 AND Smoothed momentum <= previous bar's smoothed momentum
Exit: long, Smoothed momentum > 0 AND Smoothed momentum < previous bar's smoothed momentum
Exit: short, Smoothed momentum < 0 AND Smoothed momentum > previous bar's smoothed momentum