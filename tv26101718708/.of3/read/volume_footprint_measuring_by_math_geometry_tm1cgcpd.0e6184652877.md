Calculation: BuyVolume = volume * (close - low) / (high - low)
Calculation: SellVolume = volume * (high - close) / (high - low)
Calculation: Window = most recent window-length bars with volume > 0 whose high-low range overlaps the levels within view-width ticks of the current close
Calculation: Profile = most recent profile-period bars
Calculation: DisplayRange(scope) = levels within view-width ticks of the current close if scope is the current bar or Window, else levels from the lowest low to the highest high of Profile
Calculation: BuyDensity(price, scope) = sum over bars in scope of BuyVolume * normal density at price with mean (low + close) / 2 and standard deviation (high - low) / volume concentration, truncated to [low, high] and renormalized
Calculation: SellDensity(price, scope) = sum over bars in scope of SellVolume * normal density at price with mean (close + high) / 2 and standard deviation (high - low) / volume concentration, truncated to [low, high] and renormalized
Calculation: BuyAt(level, scope) = integral of BuyDensity(price, scope) over the one-tick band centered on level
Calculation: SellAt(level, scope) = integral of SellDensity(price, scope) over the one-tick band centered on level
Calculation: POC(scope) = level in DisplayRange(scope) that maximizes BuyAt(level, scope) + SellAt(level, scope)
Calculation: BuyImbalance(level, scope) = level and the level one tick below are in DisplayRange(scope) AND BuyAt(level, scope) > SellAt(level one tick below, scope) * imbalance ratio
Calculation: SellImbalance(level, scope) = level and the level one tick above are in DisplayRange(scope) AND SellAt(level, scope) > BuyAt(level one tick above, scope) * imbalance ratio
Calculation: FirstImbalance(level, scope) = level != POC(scope) AND (BuyImbalance(level, scope) OR SellImbalance(level, scope)) AND no level strictly between level and POC(scope) has BuyImbalance or SellImbalance
Calculation: Overlap = integral over price of min(BuyDensity(price, Profile) / sum of BuyVolume over Profile, SellDensity(price, Profile) / sum of SellVolume over Profile)
Calculation: BalanceTilt = 100 * (sum of BuyVolume over Profile - sum of SellVolume over Profile) / (sum of BuyVolume over Profile + sum of SellVolume over Profile)
Long: BuyVolume >= SellVolume AND volume > 0
Short: SellVolume > BuyVolume
Long: sum of BuyVolume over Window >= sum of SellVolume over Window
Short: sum of SellVolume over Window > sum of BuyVolume over Window
Long: Overlap < balance overlap threshold AND BalanceTilt >= balance tilt threshold
Short: Overlap < balance overlap threshold AND BalanceTilt <= -balance tilt threshold
Long: for some level, FirstImbalance(level, Window) AND BuyImbalance(level, Window)
Short: for some level, FirstImbalance(level, Window) AND BuyImbalance(level, Window) = false
Long: for some level, FirstImbalance(level, Window) AND BuyImbalance(level, current bar)
Short: for some level, FirstImbalance(level, Window) AND SellImbalance(level, current bar)
Long: for some level, FirstImbalance(level, Profile) AND BuyImbalance(level, Profile)
Short: for some level, FirstImbalance(level, Profile) AND BuyImbalance(level, Profile) = false