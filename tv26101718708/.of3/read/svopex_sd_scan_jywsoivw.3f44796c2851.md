Calculation: BaseCount = number of consecutive bars ending at the current bar where ABS(close - open) < BaseBodyPct * ATR(ATRLen)
Calculation: HighProbe = high if UseWicks, else max(open, close)
Calculation: LowProbe = low if UseWicks, else min(open, close)
Calculation: ZoneFormed = up if BaseCount[1] = 0 AND close[1] - open[1] > ExplMult * ATR(ATRLen)[1] AND 0 < BaseCount[2] <= BaseMax; down if BaseCount[1] = 0 AND open[1] - close[1] > ExplMult * ATR(ATRLen)[1] AND 0 < BaseCount[2] <= BaseMax; otherwise none
Calculation: DemandZones = list of (top, bottom); each bar: if ZoneFormed = up, append (top = Highest(high, BaseCount)[2], bottom = Lowest(low, BaseCount)[2]); if the list holds more than MaxZones zones, remove the oldest; the bar's conditions use this list; then remove each zone with LowProbe <= top - (top - bottom) * BreakPct / 100
Calculation: SupplyZones = list of (top, bottom); each bar: if ZoneFormed = down, append (top = Highest(high, BaseCount)[2], bottom = Lowest(low, BaseCount)[2]); if the list holds more than MaxZones zones, remove the oldest; the bar's conditions use this list; then remove each zone with HighProbe >= bottom + (top - bottom) * BreakPct / 100
Calculation: DemandBarsAgo = BarsSince(some zone in DemandZones has HighProbe >= bottom AND LowProbe <= top), infinite if never
Calculation: SupplyBarsAgo = BarsSince(some zone in SupplyZones has HighProbe >= bottom AND LowProbe <= top), infinite if never
Calculation: DemandInside = some zone in DemandZones has bottom <= close <= top
Calculation: SupplyInside = some zone in SupplyZones has bottom <= close <= top
Calculation: DemandNear = some zone in DemandZones has top < close <= top + NearMult * ATR(ATRLen)
Calculation: SupplyNear = some zone in SupplyZones has bottom - NearMult * ATR(ATRLen) <= close < bottom
Long: ZoneFormed = up
Long: DemandInside AND NOT SupplyInside
Long: DemandNear AND NOT DemandInside AND NOT SupplyInside AND NOT SupplyNear AND DemandBarsAgo > WasInLookback
Long: DemandBarsAgo <= WasInLookback AND NOT DemandInside AND NOT SupplyInside AND NOT SupplyNear AND (DemandNear OR NOT (SupplyBarsAgo <= WasInLookback AND SupplyBarsAgo <= DemandBarsAgo))
Short: ZoneFormed = down
Short: SupplyInside
Short: SupplyNear AND NOT SupplyInside AND NOT DemandInside AND SupplyBarsAgo > WasInLookback
Short: SupplyBarsAgo <= WasInLookback AND NOT SupplyInside AND NOT DemandInside AND (SupplyNear OR (NOT DemandNear AND (DemandBarsAgo > WasInLookback OR SupplyBarsAgo <= DemandBarsAgo)))