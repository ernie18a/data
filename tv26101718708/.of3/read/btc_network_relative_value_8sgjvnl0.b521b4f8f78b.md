Calculation: network-work metric = sqrt(abs(nz(miner-revenue close of the current T1 bar, mapped onto chart bars, missing-value default) * nz(hashrate close of the current T1 bar, mapped onto chart bars, missing-value default) / max(nz(network-difficulty close of the current T1 bar, mapped onto chart bars, missing-value default), difficulty floor)))
Calculation: smoothed log relative price = SMA(log(if network-work metric > 0 then chart-bar close / network-work metric else chart-bar close), smoothing period, chart bars)
Calculation: relative-value Z-Score = if population StDev(smoothed log relative price, Z-score lookback, chart bars) != 0 then (smoothed log relative price - SMA(smoothed log relative price, Z-score lookback, chart bars)) / population StDev(smoothed log relative price, Z-score lookback, chart bars) else 0
Long: relative-value Z-Score <= undervaluation cutoff
Exit: long, relative-value Z-Score >= overvaluation cutoff
Calculation: Network investment value = sqrt(abs(nz(T1 miner revenue, 1) * nz(T1 hashrate, 1) / max(nz(T1 network difficulty, 1), 1)))
Calculation: Log price-to-network value = log(if Network investment value > 0 then BTC closing price / Network investment value else BTC closing price)
Calculation: BTC network valuation Z-score = if StDev(SMA(Log price-to-network value, P2), P1) != 0 then (SMA(Log price-to-network value, P2) - SMA(SMA(Log price-to-network value, P2), P1)) / StDev(SMA(Log price-to-network value, P2), P1) else 0
Long: BTC network valuation Z-score <= -1
Exit: long, BTC network valuation Z-score >= 2