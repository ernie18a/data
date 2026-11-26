Calculation: Active fan = the latest retained accepted fan, updated only on a completed chart bar when four confirmed pivots of the same type are available; a bullish fan uses the four latest Pivot Low(low, pivot length) pivots with strictly ascending prices and strictly increasing origin-to-pivot slopes, and a bearish fan uses the four latest Pivot High(high, pivot length) pivots with strictly descending prices and increasingly negative origin-to-pivot slopes; at formation, the first-leg price move as a percentage of the origin price must exceed the minimum leg percentage, and the origin must be within the maximum fan lookback; retain the fan until another valid fan is established
Calculation: Leg 3 fan line(k) = active fan origin price + (active fan latest pivot price − active fan origin price) / (active fan latest pivot bar − active fan origin bar) × (chart bar index k − active fan origin bar)
Long: on a completed chart bar, the active fan is bullish AND close[1] > Leg 3 fan line(bar index − 1) AND close[2] ≤ Leg 3 fan line(bar index − 2) AND (volume filter disabled OR volume > SMA(volume, volume lookback) × volume multiplier) AND (HTF filter disabled OR close[1] > the close of the last completed T1 bar, sampled on chart bars)
Short: on a completed chart bar, the active fan is bearish AND close[1] < Leg 3 fan line(bar index − 1) AND close[2] ≥ Leg 3 fan line(bar index − 2) AND (volume filter disabled OR volume > SMA(volume, volume lookback) × volume multiplier) AND (HTF filter disabled OR close[1] < the close of the last completed T1 bar, sampled on chart bars)
Calculation: Long risk distance at a long signal = entry price − max(min(second-latest fan pivot low, latest fan pivot low) − ATR(ATR lookback)[1] × stop buffer, entry price − ATR(ATR lookback)[1] × maximum stop distance in ATRs)
Calculation: Short risk distance at a short signal = min(max(second-latest fan pivot high, latest fan pivot high) + ATR(ATR lookback)[1] × stop buffer, entry price + ATR(ATR lookback)[1] × maximum stop distance in ATRs) − entry price
Calculation: Long target 1 = entry price + long risk distance × first target multiple, set at the long signal
Calculation: Long target 2 = entry price + long risk distance × second target multiple, set at the long signal
Calculation: Long target 3 = entry price + long risk distance × third target multiple, set at the long signal
Calculation: Short target 1 = entry price − short risk distance × first target multiple, set at the short signal
Calculation: Short target 2 = entry price − short risk distance × second target multiple, set at the short signal
Calculation: Short target 3 = entry price − short risk distance × third target multiple, set at the short signal
Exit: long, high ≥ long target 1
Exit: long, high ≥ long target 2
Exit: long, high ≥ long target 3
Exit: short, low ≤ short target 1
Exit: short, low ≤ short target 2
Exit: short, low ≤ short target 3