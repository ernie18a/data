Calculation: Selected zones = the latest zone-count confirmed swing highs and lows.
Calculation: Supply zone = the interval centered on a confirmed swing high with half-width equal to current-bar ATR(ATR lookback parameter) × zone-height parameter / 2.
Calculation: Demand zone = the interval centered on a confirmed swing low with half-width equal to current-bar ATR(ATR lookback parameter) × zone-height parameter / 2.
Calculation: Zone buy volume = sum(volume) over scan-lookback bars where (high + low + close) / 3 is within the zone and close >= open.
Calculation: Zone sell volume = sum(volume) over scan-lookback bars where (high + low + close) / 3 is within the zone and close < open.
Calculation: Zone total volume = zone buy volume + zone sell volume.
Calculation: Zone LIQ score = the rounded percentage of zone total volume relative to the greatest zone total volume among selected zones.
Calculation: Zone is fresh = the count of transitions from typical price outside the zone to typical price inside it over scan-lookback bars does not exceed the fresh-touch limit parameter.
Calculation: Liquidity bias = demand-side when selected demand-zone total volume >= selected supply-zone total volume; otherwise supply-side.
Long: close >= open.
Short: close < open.
Long: confirmed pivot low(low, swing lookback, swing lookback).
Short: confirmed pivot high(high, swing lookback, swing lookback).
Long: at least one selected demand zone exists.
Short: at least one selected supply zone exists.
Long: at least one selected zone exists AND liquidity bias is demand-side.
Short: at least one selected zone exists AND liquidity bias is supply-side.
Long: liquidity bias is demand-side AND a fresh demand zone has LIQ score >= long minimum LIQ parameter AND zone buy volume > zone sell volume AND close[1] > the zone's upper boundary AND low <= the zone's upper boundary AND high >= the zone's lower boundary.
Short: liquidity bias is supply-side AND a fresh supply zone has LIQ score >= short minimum LIQ parameter AND zone sell volume > zone buy volume AND close[1] < the zone's lower boundary AND high >= the zone's lower boundary AND low <= the zone's upper boundary.
Exit: Long, low < the lower boundary of the demand zone used for entry OR high >= the lower boundary of the nearest selected supply zone above the entry price.
Exit: Short, high > the upper boundary of the supply zone used for entry OR low <= the upper boundary of the nearest selected demand zone below the entry price.