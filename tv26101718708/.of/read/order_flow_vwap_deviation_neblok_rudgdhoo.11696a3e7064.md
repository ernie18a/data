Calculation: Estimated buy and sell volume = for each completed lower-timeframe bar within the chart bar, allocate volume to buy as volume × (close − low) / (high − low), or half the volume if high = low; allocate the remainder to sell. Sum each allocation across the chart bar. If no lower-timeframe bars are available, apply the same allocation to the chart bar. The chart timeframe itself may be used instead of a lower timeframe.
Calculation: Bar delta = estimated buy volume − estimated sell volume.
Calculation: Anchored VWAP = sum of chart-bar source price × total estimated buy and sell volume divided by sum of total estimated buy and sell volume since the latest anchor reset; use the first source price after reset if total volume is zero. The source is a selectable price series. Reset at the start of a selectable calendar day, week, or month and at the first available bar.
Calculation: Upper and lower deviations = square roots of the anchored sums of estimated buy-volume-weighted and sell-volume-weighted squared differences between each chart-bar source price and the current anchored VWAP, respectively, divided by the corresponding anchored volume sums; use zero when the corresponding volume sum is zero.
Calculation: Upper and lower bands = anchored VWAP plus a multiplier × upper deviation and anchored VWAP minus a multiplier × lower deviation. The outer multiplier is larger than the inner multiplier; rejection signals use either the inner or outer bands.
Calculation: Anchored delta = sum of estimated buy volume − sum of estimated sell volume since the latest anchor reset.
Calculation: Band skew = upper deviation / lower deviation when lower deviation > 0, otherwise 1.
Calculation: Normalized displacement = (close − anchored VWAP) / upper deviation when close ≥ anchored VWAP and upper deviation > 0, or (close − anchored VWAP) / lower deviation when close < anchored VWAP and lower deviation > 0; otherwise zero.
Calculation: Profile row volumes = divide the high-to-low range of the most recent limited number of chart bars since the anchor reset into equal price rows. Allocate each bar's estimated buy and sell volumes to rows in proportion to overlap with its high-low range; allocate all to its row if the bar lies in one row or has zero range. Row total is row buy plus row sell volume; maximum row total is the largest row total.
Calculation: Profile row imbalance ratio = min(max(row buy volume, row sell volume) / max(min(row buy volume, row sell volume), a small positive floor), an upper cap).
Long: Low ≤ selected lower band AND close > selected lower band AND current bar is not the anchor reset bar AND bars since anchor reset ≥ warm-up parameter AND bars since previous long rejection > cooldown parameter AND (flow confirmation is disabled OR bar delta > 0).
Short: High ≥ selected upper band AND close < selected upper band AND current bar is not the anchor reset bar AND bars since anchor reset ≥ warm-up parameter AND bars since previous short rejection > cooldown parameter AND (flow confirmation is disabled OR bar delta < 0).
Long: Close crosses above outer upper band AND current bar is not the anchor reset bar.
Short: Close crosses below outer lower band AND current bar is not the anchor reset bar.
Long: Close crosses above anchored VWAP AND current bar is not the anchor reset bar.
Short: Close crosses below anchored VWAP AND current bar is not the anchor reset bar.
Long: Band skew > upper skew threshold.
Short: Band skew < lower skew threshold.
Long: Normalized displacement ≥ 0.
Short: Normalized displacement < 0.
Long: Normalized displacement ≥ outer band multiplier.
Short: Normalized displacement ≤ −outer band multiplier.
Long: Anchored delta ≥ 0.
Short: Anchored delta < 0.
Long: Profile range > 0 AND maximum row total > 0 AND row total > 0 AND row total ≥ maximum row total × minimum row-volume fraction AND row imbalance ratio ≥ imbalance threshold AND row buy volume ≥ row sell volume.
Short: Profile range > 0 AND maximum row total > 0 AND row total > 0 AND row total ≥ maximum row total × minimum row-volume fraction AND row imbalance ratio ≥ imbalance threshold AND row buy volume < row sell volume.