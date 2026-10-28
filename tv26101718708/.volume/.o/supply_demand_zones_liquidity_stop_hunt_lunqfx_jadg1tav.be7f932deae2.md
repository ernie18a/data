Calculation: Confirmed swing high/low = a high/low that is the highest/lowest across equal configurable numbers of bars before and after it, confirmed after the later bars close
Calculation: Supply/demand zone = a band centered on a confirmed swing high/low, respectively, with height equal to chart-bar ATR times a configurable multiplier
Calculation: Selected zones = the most recent configurable number of confirmed swing zones still within a configurable rolling chart-bar lookback
Calculation: For each selected zone, zone volume = sum of volume on bars whose (high + low + close) / 3 is inside the zone; classify volume as buy when close >= open, otherwise sell; a touch is a transition from outside to inside
Calculation: Zone liquidity score = rounded zone volume divided by the largest selected-zone volume, times 100; fresh = touch count <= 1
Calculation: Buy-side bias = total demand-zone volume >= total supply-zone volume; sell-side bias = total supply-zone volume > total demand-zone volume
Long: Buy-side bias AND price's (high + low + close) / 3 is inside a fresh demand zone AND its liquidity score >= 70 AND demand-zone buy volume > sell volume
Short: Sell-side bias AND price's (high + low + close) / 3 is inside a fresh supply zone AND its liquidity score >= 70 AND supply-zone sell volume > buy volume
Exit: long, close < the demand-zone lower boundary OR high >= the lower boundary of the next supply zone above
Exit: short, close > the supply-zone upper boundary OR low <= the upper boundary of the next demand zone below