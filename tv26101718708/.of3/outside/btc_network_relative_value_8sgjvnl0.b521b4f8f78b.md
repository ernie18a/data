Calculation: Network investment value = sqrt(abs(nz(T1 miner revenue, 1) * nz(T1 hashrate, 1) / max(nz(T1 network difficulty, 1), 1)))
Calculation: Log price-to-network value = log(if Network investment value > 0 then BTC closing price / Network investment value else BTC closing price)
Calculation: BTC network valuation Z-score = if StDev(SMA(Log price-to-network value, P2), P1) != 0 then (SMA(Log price-to-network value, P2) - SMA(SMA(Log price-to-network value, P2), P1)) / StDev(SMA(Log price-to-network value, P2), P1) else 0
Long: BTC network valuation Z-score <= -1
Exit: long, BTC network valuation Z-score >= 2