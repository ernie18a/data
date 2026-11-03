Calculation: Major swing high = highest high over the selected lookback, excluding the current bar
Calculation: Major swing low = lowest low over the selected lookback, excluding the current bar
Calculation: Institutional volume = current volume > selected multiplier × 20-bar simple moving average of volume
Calculation: Anchored VWAP = volume-weighted average of HLC3 since the selected anchor period began
Calculation: Outer VWAP bands = anchored VWAP ± selected band multiplier × band basis; band basis is either the standard deviation distance from anchored VWAP or 1% of anchored VWAP, according to the selected mode
Long: low < major swing low AND close > major swing low AND close > open AND (low <= lower outer VWAP band OR prior bar low <= prior bar lower outer VWAP band) AND institutional volume
Short: high > major swing high AND close < major swing high AND close < open AND (high >= upper outer VWAP band OR prior bar high >= prior bar upper outer VWAP band) AND institutional volume