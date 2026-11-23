Calculation: CloseLocation = (close - low) / (high - low), or 0.5 when high = low
Calculation: AuctionDelta = sum(volume * (2 * CloseLocation - 1)) / sum(volume), summed over the bars of the forming auction
Calculation: Control = anchored VWAP of (high + low + close) / 3 weighted by volume, anchored at the start of the forming auction
Calculation: Auction POC = midpoint of the price bin holding the most volume, where the forming auction's range from its lowest low to its highest high is split into profile rows equal bins and each bar's volume is spread evenly over the bins its high-to-low range covers
Calculation: Settled POC = Auction POC at the most recent auction settlement
Calculation: BelowCount = number of consecutive bars ending at the current bar with close < Settled POC
Calculation: AboveCount = number of consecutive bars ending at the current bar with close > Settled POC
Calculation: Warm = number of samples in the forming auction >= warm-up count
Calculation: RelVolume = volume / SMA(volume, average lookback)
Calculation: RelRange = (high - low) / SMA(high - low, average lookback)
Calculation: Absorption = RelVolume >= volume multiple AND RelRange <= range multiple
Calculation: KineticRaw = volume * abs(close - close[1])
Calculation: KineticFuel = (KineticRaw - lowest(KineticRaw, fuel lookback)) / (highest(KineticRaw, fuel lookback) - lowest(KineticRaw, fuel lookback)), or 0 when highest(KineticRaw, fuel lookback) = lowest(KineticRaw, fuel lookback)
Long: close crosses above Settled POC AND BelowCount[1] >= acceptance bars AND AuctionDelta > 0 AND KineticFuel >= fuel floor
Long: AuctionDelta crosses above delta trigger AND AuctionDelta > 0 AND close > Control AND Warm AND KineticFuel >= fuel floor
Long: Absorption AND CloseLocation >= 0.5
Short: close crosses below Settled POC AND AboveCount[1] >= acceptance bars AND AuctionDelta < 0 AND KineticFuel >= fuel floor
Short: AuctionDelta crosses below minus delta trigger AND AuctionDelta < 0 AND close < Control AND Warm AND KineticFuel >= fuel floor
Short: Absorption AND CloseLocation < 0.5