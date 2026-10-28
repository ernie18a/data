Calculation: Active-interval volume profile = divide the high-low range of the current, still-forming higher-timeframe interval into equal bins; add each chart bar’s full volume to every bin its high-low range overlaps.
Calculation: Point of Control (POC) = midpoint of the bin with the greatest volume in the active-interval volume profile.
Calculation: Value Area High/Low (VAH/VAL) = expand from the POC bin, adding the adjacent bin with greater volume each time, until included volume reaches 70% of total profile volume; use the highest included bin’s top as VAH and the lowest included bin’s bottom as VAL.
Calculation: High-Volume Nodes (HVNs) = the three bins with the greatest volume in the active-interval volume profile.
Calculation: Smart-money-weighted profile imbalance = for each bin, sum volume multiplied by candle direction (+1 when close > open, otherwise −1) and by [1 + 0.3 × NVI change / max(|previous NVI|, 1)], where NVI changes by the close’s percentage change when volume decreases and otherwise stays unchanged. Sum bin volume with nonnegative signed volume as up volume and the rest as down volume; imbalance is |up volume − down volume| / (up volume + down volume).
Long: For any of the three active-interval HVNs, low < HVN bottom AND close > HVN top
Long: Current active-interval POC > previous chart bar’s active-interval POC
Long: Up volume > down volume AND smart-money-weighted profile imbalance >= threshold AND previous chart bar’s imbalance < threshold
Long: close > VAH AND previous chart bar’s close <= previous chart bar’s VAH
Short: For any of the three active-interval HVNs, high > HVN top AND close < HVN bottom
Short: Current active-interval POC < previous chart bar’s active-interval POC
Short: Down volume > up volume AND smart-money-weighted profile imbalance >= threshold AND previous chart bar’s imbalance < threshold
Short: close < VAL AND previous chart bar’s close >= previous chart bar’s VAL