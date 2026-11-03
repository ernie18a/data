Calculation: Structure bars = last completed bars of a higher timeframe; bias bars = last completed bars of a still higher timeframe. Map each higher-timeframe result to chart bars with lookahead disabled.
Calculation: Swing high and swing low = latest confirmed symmetric pivot high and low on structure bars, using a longer lookback than the internal pivots. Internal high and internal low = latest confirmed symmetric pivot high and low on structure bars, using a shorter lookback. Each pivot uses equal numbers of left and right bars.
Calculation: Structure trend = initially neutral; on each structure bar, set bullish when close exceeds the internal high for the first time since that pivot was confirmed, and set bearish when close falls below the internal low for the first time since that pivot was confirmed. Process the high break before the low break. Reset the corresponding first-break flag whenever a new pivot is confirmed.
Calculation: Bias trend = initially neutral; on each bias bar, set bullish if close exceeds its latest confirmed symmetric pivot high, and set bearish if close falls below its latest confirmed symmetric pivot low. Process the high comparison before the low comparison; otherwise retain the previous trend.
Calculation: Low sweep = structure-bar low < swing low minus the maximum of a price-proportional threshold and an ATR-proportional threshold AND close > swing low AND lower wick > a fraction of the bar range. High sweep = structure-bar high > swing high plus the same maximum threshold AND close < swing high AND upper wick > the same fraction of the bar range. ATR is calculated on structure bars.
Calculation: Confirmed low sweep = a newly confirmed swing low > the lowest low of all low sweeps since the preceding confirmed low sweep; clear that stored low after confirmation. Confirmed high sweep = a newly confirmed swing high < the highest high of all high sweeps since the preceding confirmed high sweep; clear that stored high after confirmation. Include a sweep on the current structure bar before checking confirmation.
Calculation: Active bullish shift = initially false; set true when a confirmed low sweep and a first break above the internal high occur on the same mapped chart bar AND bias trend is bullish or neutral AND active bullish shift is false. Save the internal high as its level and set active bearish shift false. Set active bullish shift false when chart close < its saved level. Active bearish shift is symmetric, using a confirmed high sweep, first break below the internal low, bearish or neutral bias, and chart close > its saved level; process bullish activation before bearish activation and process deactivations after activations.
Long: Bias trend = bullish
Short: Bias trend = bearish
Long: Structure trend = bullish
Short: Structure trend = bearish
Long: First break above the internal high = true AND the mapped bullish break event on the previous chart bar = false
Short: First break below the internal low = true AND the mapped bearish break event on the previous chart bar = false
Long: Low sweep = true AND (low sweep on the previous chart bar = false OR (confirmed low sweep = false AND confirmed high sweep = false))
Short: High sweep = true AND (high sweep on the previous chart bar = false OR (confirmed low sweep = false AND confirmed high sweep = false AND low sweep = false))
Long: Confirmed low sweep = true
Short: Confirmed high sweep = true
Long: Active bullish shift = true
Short: Active bearish shift = true