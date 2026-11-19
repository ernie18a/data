Calculation: Clamp(x) = max(0, min(1, x))
Calculation: Safe ATR = max(ATR(ATR lookback), minimum price increment)
Calculation: Impulse percentage = 100 * (highest(high, impulse lookback) - lowest(low, impulse lookback)) / max(lowest(low, impulse lookback), minimum price increment)
Calculation: Bullish retracement percentage = 100 * (highest(high, impulse lookback) - close) / max(highest(high, impulse lookback) - lowest(low, impulse lookback), minimum price increment)
Calculation: Bearish retracement percentage = 100 * (close - lowest(low, impulse lookback)) / max(highest(high, impulse lookback) - lowest(low, impulse lookback), minimum price increment)
Calculation: Flag range percentage = 100 * (highest(high, flag length) - lowest(low, flag length)) / max(close, minimum price increment)
Calculation: Flag slope angle = degrees(atan(LinReg(close, flag length, current endpoint) - LinReg(close, flag length, preceding endpoint)))
Calculation: Demand zone low = lowest(low, zone lookback)
Calculation: Demand zone high = demand zone low + safe ATR * zone thickness ATR
Calculation: Supply zone high = highest(high, zone lookback)
Calculation: Supply zone low = supply zone high - safe ATR * zone thickness ATR
Calculation: Demand found = lowestbars(low, zone lookback) <= zone freshness bars
Calculation: Supply found = highestbars(high, zone lookback) <= zone freshness bars
Calculation: Bull flag found = impulse percentage >= minimum impulse percentage AND bullish retracement percentage <= maximum retracement percentage AND flag range percentage <= maximum flag range percentage AND flag slope angle <= maximum flag slope angle
Calculation: Bear flag found = impulse percentage >= minimum impulse percentage AND bearish retracement percentage <= maximum retracement percentage AND flag range percentage <= maximum flag range percentage AND flag slope angle >= -maximum flag slope angle
Calculation: Demand active = demand found AND close > demand zone low AND (close-out requirement is disabled OR close > demand zone high)
Calculation: Supply active = supply found AND close < supply zone high AND (close-out requirement is disabled OR close < supply zone low)
Calculation: Bull flag active = bull flag found AND close > lowest(low, flag length)
Calculation: Bear flag active = bear flag found AND close < highest(high, flag length)
Calculation: Bull flag confidence = (Clamp(impulse weight * Clamp((impulse percentage - minimum impulse percentage) / (minimum impulse percentage * impulse normalization multiplier)) + retracement weight * Clamp(1 - bullish retracement percentage / (maximum retracement percentage * retracement normalization multiplier)) + range weight * Clamp(1 - flag range percentage / (maximum flag range percentage * range normalization multiplier)) + slope weight * (1 - Clamp(abs(max(flag slope angle, 0)) / slope penalty scale))) ^ flag score exponent
Calculation: Bear flag confidence = (Clamp(impulse weight * Clamp((impulse percentage - minimum impulse percentage) / (minimum impulse percentage * impulse normalization multiplier)) + retracement weight * Clamp(1 - bearish retracement percentage / (maximum retracement percentage * retracement normalization multiplier)) + range weight * Clamp(1 - flag range percentage / (maximum flag range percentage * range normalization multiplier)) + slope weight * (1 - Clamp(abs(min(flag slope angle, 0)) / slope penalty scale))) ^ flag score exponent
Calculation: Demand confidence = (Clamp(freshness weight * Clamp(1 - lowestbars(low, zone lookback) / (zone freshness bars * freshness score scale)) + distance weight * Clamp((close - demand zone high) / (safe ATR * zone distance ATR scale)) + zone depth weight * Clamp((close - demand zone low) / max(safe ATR * zone depth ATR scale, minimum price increment))) ^ zone score exponent
Calculation: Supply confidence = (Clamp(freshness weight * Clamp(1 - highestbars(high, zone lookback) / (zone freshness bars * freshness score scale)) + distance weight * Clamp((supply zone low - close) / (safe ATR * zone distance ATR scale)) + zone depth weight * Clamp((supply zone high - close) / max(safe ATR * zone depth ATR scale, minimum price increment))) ^ zone score exponent
Calculation: Selected signal = On each enabled T1/T2, choose the highest-confidence found setup, breaking ties in the order demand, supply, bull flag, bear flag; multiply its confidence by the inactive confidence multiplier if it is inactive; then choose the setup with the higher resulting confidence across enabled T1/T2, breaking ties in favor of T1. Compute on T1/T2 bars, using the still-forming bar in real time and the last completed bar historically; return values to chart bars.
Calculation: An active setup exists = any demand, supply, bull flag, or bear flag setup is active on an enabled T1/T2
Long: Selected signal is demand or bull flag AND (an active setup exists OR invalidated setups are shown)
Short: Selected signal is supply or bear flag AND (an active setup exists OR invalidated setups are shown)