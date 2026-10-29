Calculation: Cumulative deviation at rung k = first deviation × (1 + step multiplier + … + step multiplier^(k−1))
Long: Flat AND previous host-bar entry RSI from the lower timeframe < entry threshold AND current sampled entry RSI ≥ entry threshold
Long: Long position open AND fewer than the maximum safety orders filled AND close ≤ base entry price × (1 − cumulative deviation at next rung / 100)
Exit: Long, close ≥ average entry price × (1 + minimum profit / 100) AND previous host-bar exit RSI from the lower timeframe > exit threshold AND current sampled exit RSI ≤ exit threshold