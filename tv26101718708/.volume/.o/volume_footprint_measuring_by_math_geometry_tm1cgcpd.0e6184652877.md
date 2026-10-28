Calculation: Bar buy volume = volume × (close − low) / (high − low); when high = low, split volume equally. Bar sell volume = volume − bar buy volume.
Calculation: Buy/sell volume by price = distribute each bar’s buy/sell volume over its high–low range as truncated Gaussian curves; buy center = (low + close) / 2, sell center = (close + high) / 2, and both use standard deviation (high − low) / concentration. A zero-range bar contributes its volume at its price.
Calculation: Profile OVL = shared area of the buy and sell profile curves after each is normalized to unit total area.
Calculation: Profile tilt = 100 × (total buy volume − total sell volume) / (total buy volume + total sell volume).
Long: For a price row, buy volume at that row > sell volume one row below × imbalance threshold.
Short: For a price row, sell volume at that row > buy volume one row above × imbalance threshold.
Long: For the current-timeframe profile over the selected lookback, OVL < balance boundary AND profile tilt ≥ tilt threshold.
Short: For the current-timeframe profile over the selected lookback, OVL < balance boundary AND profile tilt ≤ −tilt threshold.