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