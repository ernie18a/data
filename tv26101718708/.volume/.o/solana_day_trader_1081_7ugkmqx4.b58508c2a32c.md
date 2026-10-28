Calculation: Williams VIX Fix = 100 × (highest close over the lookback − low) / highest close over the lookback; armed when it fired within the arm window
Calculation: WVF fire = prior WVF was at or above its upper Bollinger band or range-high threshold, current WVF is below both, low > prior low, close > prior high, close > close at either configured downtrend lookback, and close > close at the strength lookback
Calculation: FVG = current low − high two bars earlier is positive and at least the configured percentage of current close
Calculation: VIDYA = adaptive moving average using the absolute Chande momentum ratio as its smoothing factor
Calculation: OBV slope = cumulative signed volume is greater than its value at the configured lookback; signed volume is volume when close ≥ open, otherwise negative volume
Calculation: Signed-volume DELTA = EMA of signed volume is positive; armed when true within its configured window from WVF
Calculation: TQI = mean of efficiency ratio, clipped ATR ratio quality, clipped distance-from-SMA quality, and clipped momentum quality
Calculation: VOL HI = ATR percentile rank over its rolling lookback is at or above the upper volatility cut
Calculation: Confluence score = weighted sum of armed EMA, VIDYA, OBV slope, DELTA, FVG, TQI-at-or-above-threshold, and VOL HI, minus weighted VOL LO; apply each enabled core and score toggle
Calculation: Tier = 0 unless WVF gate passes and score ≥ BASE floor; BASE if score is below SCALE floor; SCALE if score ≥ SCALE floor and ADX is not below the FULL threshold; FULL if score ≥ SCALE floor and ADX is below the FULL threshold
Calculation: Bollinger lower band = close SMA − configured multiplier × close standard deviation
Calculation: WVF Top = prior downside WVF was at or below its lower Bollinger band or range-low threshold, and current downside WVF is above both
Calculation: CVI = (close − lowest low) / (highest high − lowest low) over its lookback; CVI Top fires when prior CVI ≥ threshold and current CVI < threshold
Calculation: TQI Char-Flip = prior TQI > upper boundary and current TQI < lower boundary after the configured minimum trend age
Long: On the 15-minute, 30-minute, or 1-hour evaluation bars, an enabled tier changes to a positive value, its entry offset has elapsed, and its TQI is outside the enabled dead zone; with primary-15-minute-only enabled, only 15-minute tiers qualify; if the optional BTC FULL gate is enabled and BTC close ≤ its EMA, FULL is reduced to SCALE
Long: Support sweep marking fires when a support level (session low or lower Bollinger band) is swept by at least the configured ATR wick size, open or close is above that level, and within the reclaim window close is above the level and open with current or prior volume at least the configured multiple of its 20-bar average
Long: MBI bull marking fires when downside bias crosses below its prior value while above its bound and above upside bias
Long: BBAWE long marking fires when the fast EMA crosses above the Bollinger basis, close is above the basis, and the Awesome Oscillator is nonnegative and rising
Long: EMA bull marking when the 9-period EMA is above the 21-period EMA and the 9-period EMA is above its value five bars earlier
Long: MTF trend panel marks up when its score is > 0.5; score = +1 when close is above both that timeframe’s EMA and VWAP, −1 when below both, otherwise 0, plus 0.5 or −0.5 according to the sign of close minus its value three bars earlier, plus 0.5 when ATR exceeds its own longer-period SMA
Short: Resistance sweep marking fires when a resistance level (session high or upper Bollinger band) is swept by at least the configured ATR wick size, open or close is below that level, and within the reclaim window close is below the level and open with current or prior volume at least the configured multiple of its 20-bar average
Short: MBI bear marking fires when upside bias crosses below its prior value while above its bound and above downside bias
Short: BBAWE short marking fires when the fast EMA crosses below the Bollinger basis, close is below the basis, and the Awesome Oscillator is negative and falling
Short: EMA bear marking when the 9-period EMA is not above the 21-period EMA and the 9-period EMA is below its value five bars earlier
Short: MTF trend panel marks down when its score is < −0.5; score is calculated as defined above
Exit: long, close ≤ Bollinger lower band
Exit: long, WVF Top fires
Exit: long, CVI Top fires
Exit: long, TQI Char-Flip fires
Exit: long, one newly firing BB Break, WVF Top, or CVI Top while a trade is active and outside cooldown (reduce half); two distinct such signals within the exit window, or any one while sell-side liquidity is near, exits fully; Char-Flip while a trade is active exits fully