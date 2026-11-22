Calculation: asset-credit growth = ROC(average of the selected financial, real-estate, and optional additional asset-credit proxy closes, ROC lookback)
Calculation: productive-credit growth = ROC(productive-credit proxy close, ROC lookback)
Calculation: credit momentum = ROC(asset-credit growth, momentum lookback)
Calculation: credit acceleration = ROC(credit momentum, acceleration lookback)
Calculation: volume surge = broad-market volume > SMA(broad-market volume, lookback) * volume multiplier
Calculation: bubble score = min(score cap, min(score cap, max(score floor, PercentRank(asset-credit growth / productive-credit growth, twice the lookback) * bubble rank multiplier)) * (credit momentum > 0 AND volume surge ? bubble surge multiplier : 1))
Calculation: Minsky score = if credit acceleration > 0 AND bubble score > Minsky activation level, min(score cap, PercentRank(credit momentum, twice the lookback) * Minsky multiplier), otherwise PercentRank(credit momentum, twice the lookback)
Long: bubble score < productive rebound threshold AND productive-credit growth crosses above zero
Long: bubble score <= productive-lead level
Short: bubble score > productive-lead level
Short: bubble score > CF peak threshold AND asset-credit growth crosses below EMA(asset-credit growth, EMA lookback)
Short: Minsky score crosses above Minsky warning level
Short: bubble score > bubble alert threshold AND volume surge AND credit momentum > 0
Short: bubble score > bubble shading level AND volume surge AND credit momentum > 0
Short: bubble score > high bubble-risk label level
Short: Minsky score > Minsky shading level
Calculation: Financial credit-flow rate of change = ROC(average(financial-sector proxy close, real-estate proxy close, optional technology/speculation proxy close when enabled), P1)
Calculation: Productive activity rate of change = ROC(industrial proxy close, P1)
Calculation: Bubble score = min(P8, IF(ROC(Financial credit-flow rate of change, P5) > P12 AND broad-market volume > SMA(broad-market volume, P2) * P4, min(P8, max(P13, PercentRank(Financial credit-flow rate of change / Productive activity rate of change, P2 * P3) * P6)) * P7, min(P8, max(P13, PercentRank(Financial credit-flow rate of change / Productive activity rate of change, P2 * P3) * P6)))
Short: Bubble score > P9 AND Financial credit-flow rate of change crosses below EMA(Financial credit-flow rate of change, P10)
Long: Bubble score < P11 AND Productive activity rate of change crosses above P12