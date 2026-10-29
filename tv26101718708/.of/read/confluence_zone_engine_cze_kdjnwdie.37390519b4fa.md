Calculation: Pivot-anchored AVWAP = volume-weighted average of typical price (high + low + close) / 3 from each confirmed pivot high or low; calculate on the chart timeframe and on higher timeframes using their last completed bars.
Calculation: Anchored volume-profile levels = POC and the upper and lower edges of the 70% value area, calculated from volume since each confirmed pivot; calculate on chart-timeframe bars and include higher-timeframe levels only when enabled.
Calculation: Confluence zone = the largest cluster of chart-timeframe and enabled higher-timeframe AVWAP and volume-profile levels whose prices are within the clustering tolerance and whose weighted count meets the minimum; zone bounds are the cluster's lowest and highest levels, and its midpoint is their average.
Calculation: Zone bias = pivot-low contributor count − pivot-high contributor count, plus 1 if the zone midpoint is below close or −1 if above close when the midpoint is within 3 ATR(14) of close; otherwise add 0.
Long: A confluence zone forms AND zone bias ≥ 2
Short: A confluence zone forms AND zone bias ≤ −2
Long: A pending zone reaches the outcome lookback AND (close − zone midpoint) / zone midpoint × 100 > the directional outcome threshold
Short: A pending zone reaches the outcome lookback AND (close − zone midpoint) / zone midpoint × 100 < −the directional outcome threshold