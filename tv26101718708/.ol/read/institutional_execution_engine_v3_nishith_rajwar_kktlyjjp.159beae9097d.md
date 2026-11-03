Calculation: ATR = average true range over its configured lookback
Calculation: Efficiency ratio(n) = abs(close - close[n]) / (SMA(abs(close - close[1]), n) * n)
Calculation: Session VWAP = cumulative (HLC3 * volume) / cumulative volume since the configured session reset
Calculation: Supply POI = confirmed pivot high with a decline greater than ATR; zone is [pivot high - 0.2 * ATR, pivot high]
Calculation: Demand POI = confirmed pivot low with a rise greater than ATR; zone is [pivot low, pivot low + 0.2 * ATR]
Calculation: POI score = weighted tiers of pivot-bar volume / volume SMA, whether the pivot swept the preceding 10-bar high (supply) or low (demand), absolute pivot-to-VWAP distance / ATR, efficiency ratio at confirmation, and POI age; apply configured exponential time decay when enabled
Calculation: Regime gate = ATR percentile over its 100-bar rolling range is below 30 or above 60
Long: A new demand POI has score >= minimum score OR the highest-scoring active touched POI is demand, its score >= minimum score, regime gate passes, session permits entries, configured trade limit permits entry, no position is open, close > open, (zone high - low) / zone depth < 0.5, and close - (zone low - 0.2 * ATR) > 0
Short: A new supply POI has score >= minimum score OR the highest-scoring active touched POI is supply, its score >= minimum score, regime gate passes, session permits entries, configured trade limit permits entry, no position is open, close < open, (high - zone low) / zone depth < 0.5, and zone high + 0.2 * ATR - close > 0
Exit: long, low <= initial stop OR high >= initial target OR (high > entry price + ATR and low <= entry price)
Exit: short, high >= initial stop OR low <= initial target OR (low < entry price - ATR and high >= entry price)