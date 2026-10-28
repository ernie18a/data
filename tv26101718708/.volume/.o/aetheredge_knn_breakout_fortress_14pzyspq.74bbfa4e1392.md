Calculation: Active zones = on each refresh bar, cluster the high, low, and close values from the lookback window into K price clusters using volume weights (close weight ×1.2), quantile-seeded centroids, and repeated nearest-centroid assignment and weighted-mean updates; retain clusters with at least the minimum density and omit centers within 0.7 ATR of an existing unbroken zone
Calculation: Zone bounds = cluster center ± half the zone-width parameter × ATR(14)
Calculation: Resistance zone = a zone whose center was above close when created; support zone = a zone whose center was not above close when created
Calculation: Volume surge = volume > 20-bar SMA(volume) × volume multiplier
Long: An unbroken resistance zone has close > its upper bound + ATR(14) × break-buffer parameter AND volume surge
Short: An unbroken support zone has close < its lower bound − ATR(14) × break-buffer parameter AND volume surge