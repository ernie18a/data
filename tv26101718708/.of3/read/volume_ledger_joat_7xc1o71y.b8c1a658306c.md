Calculation: Adjusted range = max(high - low, minimum tick)
Calculation: Relative volume = volume / SMA(volume, baseline lookback), or 1 if the average is not positive
Calculation: Normalized delta = ZScore(volume * (close - open) / adjusted range, normalization lookback)
Calculation: Range efficiency = adjusted range / SMA(adjusted range, baseline lookback), or 1 if the average is not positive
Calculation: Volatility score = ZScore(sqrt(max(EMA(log(volume / volume[1]) squared when both volumes are positive, otherwise 0, volatility lookback), 0)), normalization lookback)
Calculation: Participation score = EMA(delta weight * normalized delta + volume weight * (relative volume - 1) - churn weight * ZScore(relative volume / range efficiency, normalization lookback), smoothing lookback)
Calculation: Eligible zones = confirmed volume pivot highs using the pivot lookback on both sides whose relative volume at the pivot exceeds the volume threshold times the zone volume factor OR whose absolute normalized delta exceeds the pivot delta threshold OR whose volatility score exceeds the pivot volatility threshold; each zone is centered at HLC3 at the pivot, has half-width max(ATR at the pivot * zone ATR factor, minimum tick * tick width factor), and score max(relative volume at the pivot, zone score floor) + zone delta weight * absolute normalized delta at the pivot + zone volatility weight * max(volatility score at the pivot, 0); retain the newest zone storage limit and ignore zones older than the active zone lookback
Calculation: Active support and resistance = among eligible zones, choose the highest-score zone with its top below close for support and the highest-score zone with its bottom above close for resistance; ties choose the oldest retained zone; each zone's midpoint is its center, top is center plus half-width, and bottom is center minus half-width
Long: normalized delta > 0
Short: normalized delta < 0
Long: participation score > 0
Short: participation score < 0
Long: confirmed chart bar AND relative volume > ultra relative volume AND normalized delta > climax delta threshold AND participation score > 0
Short: confirmed chart bar AND relative volume > ultra relative volume AND normalized delta < -climax delta threshold AND participation score < 0
Long: confirmed chart bar AND relative volume > ultra relative volume AND range efficiency / relative volume < churn threshold AND normalized delta > 0
Short: confirmed chart bar AND relative volume > ultra relative volume AND range efficiency / relative volume < churn threshold AND normalized delta < 0
Long: confirmed chart bar AND active support exists AND low <= active support top AND close >= active support midpoint
Short: confirmed chart bar AND active resistance exists AND high >= active resistance bottom AND close <= active resistance midpoint