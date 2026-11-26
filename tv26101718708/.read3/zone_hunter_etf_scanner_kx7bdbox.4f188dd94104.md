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
Calculation: Volatility floor = max(Average True Range of high, low, and close over the ATR lookback, minimum tick)
Calculation: Clamp = max(0, min(1, x))
Calculation: Impulse percentage = (highest high over the impulse lookback − lowest low over the impulse lookback) / max(lowest low over the impulse lookback, minimum tick) × 100
Calculation: Bullish retracement percentage = (highest high over the impulse lookback − close) / max(highest high over the impulse lookback − lowest low over the impulse lookback, minimum tick) × 100
Calculation: Bearish retracement percentage = (close − lowest low over the impulse lookback) / max(highest high over the impulse lookback − lowest low over the impulse lookback, minimum tick) × 100
Calculation: Flag range percentage = (highest high over the flag lookback − lowest low over the flag lookback) / max(close, minimum tick) × 100
Calculation: Flag slope angle = arctangent(linear regression of close over the flag lookback at offset 0 − linear regression of close over the flag lookback at offset 1) × 180 / pi
Calculation: Bullish flag found = impulse percentage ≥ minimum impulse percentage AND bullish retracement percentage ≤ maximum retracement percentage AND flag range percentage ≤ maximum flag range percentage AND flag slope angle ≤ bullish maximum slope angle
Calculation: Bearish flag found = impulse percentage ≥ minimum impulse percentage AND bearish retracement percentage ≤ maximum retracement percentage AND flag range percentage ≤ maximum flag range percentage AND flag slope angle ≥ bearish minimum slope angle
Calculation: Zone low = lowest low over the zone lookback
Calculation: Zone high = highest high over the zone lookback
Calculation: Zone low age = bars since the lowest low over the zone lookback
Calculation: Zone high age = bars since the highest high over the zone lookback
Calculation: Demand zone top = zone low + volatility floor × zone thickness ATR multiple
Calculation: Supply zone bottom = zone high − volatility floor × zone thickness ATR multiple
Calculation: Demand zone found = zone low age ≤ zone freshness bars
Calculation: Supply zone found = zone high age ≤ zone freshness bars
Calculation: Demand zone active = demand zone found AND (require close outside zone AND close > demand zone top AND close > zone low OR NOT require close outside zone AND close > zone low)
Calculation: Supply zone active = supply zone found AND (require close outside zone AND close < supply zone bottom AND close < zone high OR NOT require close outside zone AND close < zone high)
Calculation: Bullish flag active = bullish flag found AND close > lowest low over the flag lookback
Calculation: Bearish flag active = bearish flag found AND close < highest high over the flag lookback
Calculation: Impulse strength = Clamp((impulse percentage − minimum impulse percentage) / (minimum impulse percentage × impulse normalization multiple))
Calculation: Bullish retracement quality = Clamp(1 − bullish retracement percentage / (maximum retracement percentage × retracement normalization multiple))
Calculation: Bearish retracement quality = Clamp(1 − bearish retracement percentage / (maximum retracement percentage × retracement normalization multiple))
Calculation: Flag range quality = Clamp(1 − flag range percentage / (maximum flag range percentage × range normalization multiple))
Calculation: Bullish slope penalty = Clamp(abs(max(flag slope angle, 0)) / slope normalization angle)
Calculation: Bearish slope penalty = Clamp(abs(min(flag slope angle, 0)) / slope normalization angle)
Calculation: Demand freshness = Clamp(1 − zone low age / (zone freshness bars × freshness normalization multiple))
Calculation: Supply freshness = Clamp(1 − zone high age / (zone freshness bars × freshness normalization multiple))
Calculation: Demand distance = Clamp((close − demand zone top) / (volatility floor × distance ATR multiple))
Calculation: Supply distance = Clamp((supply zone bottom − close) / (volatility floor × distance ATR multiple))
Calculation: Demand proximity = Clamp((close − zone low) / max(volatility floor × proximity ATR multiple, minimum tick))
Calculation: Supply proximity = Clamp((zone high − close) / max(volatility floor × proximity ATR multiple, minimum tick))
Calculation: Bullish flag raw confidence = impulse weight × impulse strength + retracement weight × bullish retracement quality + range weight × flag range quality + slope weight × (1 − bullish slope penalty)
Calculation: Bearish flag raw confidence = impulse weight × impulse strength + retracement weight × bearish retracement quality + range weight × flag range quality + slope weight × (1 − bearish slope penalty)
Calculation: Demand zone raw confidence = freshness weight × demand freshness + distance weight × demand distance + proximity weight × demand proximity
Calculation: Supply zone raw confidence = freshness weight × supply freshness + distance weight × supply distance + proximity weight × supply proximity
Calculation: Bullish flag confidence = Clamp(bullish flag raw confidence) raised to the flag confidence exponent
Calculation: Bearish flag confidence = Clamp(bearish flag raw confidence) raised to the flag confidence exponent
Calculation: Demand zone confidence = Clamp(demand zone raw confidence) raised to the zone confidence exponent
Calculation: Supply zone confidence = Clamp(supply zone raw confidence) raised to the zone confidence exponent
Calculation: Per-timeframe winner = found demand zone, supply zone, bullish flag, or bearish flag with the highest confidence; ties prioritize demand zone, supply zone, bullish flag, then bearish flag; effective confidence equals confidence when active and confidence × invalidated confidence multiplier otherwise
Calculation: Selected setup = enabled T1 or T2 per-timeframe winner with the highest effective confidence; T1 wins ties
Calculation: Displayed recommendation = selected setup exists AND (an enabled T1 or T2 per-timeframe winner is active OR show invalidated plays is enabled)
Long: displayed recommendation AND selected setup is a demand zone or bullish flag
Short: displayed recommendation AND selected setup is a supply zone or bearish flag
Option: buy call, displayed recommendation AND (option mode is call OR option mode is automatic AND selected setup is a demand zone or bullish flag)
Option: buy put, displayed recommendation AND (option mode is put OR option mode is automatic AND selected setup is a supply zone or bearish flag)