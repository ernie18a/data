Calculation: RSI slope = current RSI − previous-bar RSI
Calculation: RSI acceleration = current RSI slope − previous-bar RSI slope
Calculation: Price range = high − low
Calculation: Compression = price range < simple moving average of price range × compression threshold
Long: RSI > its previous-bar rolling lowest value AND (low < previous-bar rolling lowest price OR price-delay filter disabled) AND (RSI slope > slope threshold AND RSI acceleration ≥ 0 OR slope filter disabled) AND (Compression OR compression filter disabled)
Long: Compression on the previous bar AND RSI slope > 1.5 × slope threshold
Long: A confirmed RSI pivot low has a higher RSI value than the preceding confirmed RSI pivot low, while its corresponding price low is lower, and the pivot gap is within the configured range
Long: The long lead condition AND (FAST mode OR close > previous-bar high)
Short: RSI < its previous-bar rolling highest value AND (high ≤ previous-bar rolling highest price OR price-delay filter disabled) AND (RSI slope < −slope threshold AND RSI acceleration ≤ 0 OR slope filter disabled) AND (Compression OR compression filter disabled)
Short: Compression on the previous bar AND RSI slope < −1.5 × slope threshold
Short: A confirmed RSI pivot high has a lower RSI value than the preceding confirmed RSI pivot high, while its corresponding price high is higher, and the pivot gap is within the configured range
Short: The short lead condition AND (FAST mode OR close < previous-bar low)