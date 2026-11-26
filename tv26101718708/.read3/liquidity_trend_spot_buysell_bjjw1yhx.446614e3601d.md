Calculation: liquidity = US M2 + EU M2 * EUR-to-USD rate + JP M2 / USD-to-JPY rate + CN M2 / USD-to-CNY rate + GB M2 * GBP-to-USD rate + CA M2 / USD-to-CAD rate, each series at its last completed T1 close, on chart bars
Calculation: momentum = ROC(SMA(liquidity, smoothing length), impulse window)
Calculation: impulse score = (momentum - SMA(momentum[1], z-score window)) / sample STDEV(momentum[1], z-score window)
Calculation: band regime = 1 if impulse score > regime threshold, -1 if impulse score < -regime threshold, otherwise band regime[1]
Calculation: confirmed(s, n) = s if s equals the same nonzero value on each of the last n bars, otherwise confirmed(s, n)[1]
Calculation: regime = confirmed(band regime, confirmation length) if nonzero, otherwise band regime
Calculation: impulse direction = confirmed(sign(impulse score - impulse score[impulse lag]), impulse confirmation length)
Calculation: projected impulse = SMA(impulse score, projection smoothing length)[projection lead]
Calculation: trend price = chart close or market-leader close, selected by trend source parameter
Calculation: leg vote = 1 if (liquidity leg enabled AND regime = 1) OR (trend leg enabled AND RMA(trend price, shorter trend length) > RMA(trend price, longer trend length)), otherwise 0
Calculation: bars since last position change = BARSSINCE(position side changed)
Long: leg vote = 1 AND bars since last position change >= minimum hold
Long: impulse direction crosses above 0
Long: projected impulse > 0
Long: RMA(trend price, shorter trend length) > RMA(trend price, longer trend length)
Short: impulse direction crosses below 0
Short: projected impulse < 0
Short: RMA(trend price, shorter trend length) <= RMA(trend price, longer trend length)
Exit: long, leg vote = 0 AND bars since last position change >= minimum hold