Calculation: RVOL = volume / SMA(volume, longer lookback), or 0 if SMA(volume, longer lookback) is 0
Calculation: Expansion = ROC(volume, 1), or 0 if volume[1] is 0
Calculation: BuyPressure = rawBuy / (rawBuy + rawSell), or 0.5 if rawBuy + rawSell is 0, where rawBuy = body weight * (close >= open ? abs(close - open) / range : 0) + location weight * (close - low) / range, rawSell = body weight * (close < open ? abs(close - open) / range : 0) + location weight * (high - close) / range, range = max(high - low, minimum range floor)
Calculation: Exhaustion = RVOL >= exhaustion RVOL threshold AND Expansion < exhaustion expansion limit
Calculation: BuyBurst = volume > SMA(volume, longer lookback) AND EMA(volume, shorter lookback) > SMA(volume, longer lookback) AND RVOL >= burst RVOL threshold AND Expansion >= burst expansion threshold AND BuyPressure >= minimum body pressure AND NOT Exhaustion
Calculation: SellBurst = volume > SMA(volume, longer lookback) AND EMA(volume, shorter lookback) > SMA(volume, longer lookback) AND RVOL >= burst RVOL threshold AND Expansion >= burst expansion threshold AND (1 - BuyPressure) >= minimum body pressure AND NOT Exhaustion
Calculation: VolumeStart = LOWEST(RVOL[1], quiet lookback) <= quiet RVOL maximum AND RVOL >= start RVOL threshold AND Expansion >= start expansion threshold AND volume >= HIGHEST(volume[1], previous-volume lookback) * break ratio AND (NOT bull-candle filter OR close >= open) AND (NOT volume-trend filter OR EMA(volume, shorter lookback) > SMA(volume, longer lookback)) AND (NOT buy-pressure filter OR BuyPressure >= start minimum buy pressure) AND NOT Exhaustion
Long: BuyBurst AND NOT VolumeStart
Long: BuyBurst
Short: SellBurst AND NOT VolumeStart
Short: SellBurst