Calculation: Bar buy and sell volume = Choose either geometric or intrabar volume splitting. Geometric: buy volume = volume * (close - low) / (high - low), or volume / 2 when high = low; sell volume = volume - buy volume. Intrabar: sum lower-timeframe up volume and down volume within the chart bar, including the lower-timeframe bar still forming; classify each lower-timeframe bar by close versus open, or, when equal, close versus the preceding lower-timeframe close, carrying forward the preceding classification on a tie.
Calculation: Modeled price-level volume = For each chart bar with positive range, distribute its buy and sell volumes over its low-to-high range as separate truncated normal distributions with respective means (low + close) / 2 and (close + high) / 2 and common standard deviation (high - low) / a concentration parameter. A flat bar places its volume at its close. Price-row volume is the distribution's mass in the row's price band.
Calculation: Window = The most recent qualifying chart bars, including the current bar, whose price ranges overlap a parameterized price-row frame centered on the current close, searched back up to a parameterized limit. Window buy and sell volumes at each row are the sums of modeled row volumes from those bars. Window POC is the row with the greatest combined volume, choosing the lowest row on a tie.
Calculation: Profile = Either the most recent parameterized number of chart bars including the current bar, or the union of the current occurrence of each selected session while forming and its last completed occurrence otherwise. Sum each included bar's modeled buy and sell densities separately, and sample them at evenly spaced prices from the profile low to the profile high. Profile POC is the sample with the greatest combined density, choosing the lowest sample on a tie. Profile POC buy and sell volumes are the modeled volumes in a price band centered on that sample.
Calculation: Profile overlap = Integrate the pointwise minimum of the profile buy and sell densities after normalizing each by its own total profile volume; add the matched minimum normalized masses of flat bars at each shared price. Profile tilt = (total profile buy volume - total profile sell volume) / (total profile buy volume + total profile sell volume).
Long: close >= open.
Short: close < open.
Long: close >= previous close.
Short: close < previous close.
Long: current bar buy volume >= current bar sell volume AND their sum > 0.
Short: current bar buy volume < current bar sell volume AND their sum > 0.
Long: window total buy volume >= window total sell volume.
Short: window total buy volume < window total sell volume.
Long: window buy volume at the window POC > window sell volume at the window POC.
Short: window sell volume at the window POC > window buy volume at the window POC.
Long: profile POC buy volume > profile POC sell volume.
Short: profile POC sell volume > profile POC buy volume.
Long: profile overlap < an overlap threshold AND profile tilt >= a nonnegative tilt threshold.
Short: profile overlap < an overlap threshold AND profile tilt < the nonnegative tilt threshold AND profile tilt <= the negative tilt threshold.
Long: at either the nearest window row above or below the window POC with an imbalance, window buy volume at that row > 0 AND window buy volume at that row > a threshold multiple of window sell volume one row below.
Short: at either the nearest window row above or below the window POC with an imbalance, window sell volume at that row > 0 AND window sell volume at that row > a threshold multiple of window buy volume one row above AND the buy imbalance condition at that row is false.
Long: at either the nearest profile sample above or below the profile POC with an imbalance, buy density at that sample > 0 AND buy density at that sample > the same threshold multiple of sell density one sample below.
Short: at either the nearest profile sample above or below the profile POC with an imbalance, sell density at that sample > 0 AND sell density at that sample > the same threshold multiple of buy density one sample above AND the buy imbalance condition at that sample is false.
Long: at a selected window imbalance row, a window bar's modeled buy volume at that row > 0 AND its modeled buy volume at that row > the same threshold multiple of its modeled sell volume one row below, with both rows inside that bar's range.
Short: at a selected window imbalance row, a window bar's modeled sell volume at that row > 0 AND its modeled sell volume at that row > the same threshold multiple of its modeled buy volume one row above, with both rows inside that bar's range.