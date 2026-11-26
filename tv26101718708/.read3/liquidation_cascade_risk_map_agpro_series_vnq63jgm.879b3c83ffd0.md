Calculation: selected participation series = selected open-interest close series when available; otherwise volume when volume-only mode is selected or volume fallback is enabled; otherwise unavailable
Calculation: valid participation = selected participation series is available and greater than zero
Calculation: safe ATR = maximum of ATR(ATR lookback) when available or true range otherwise, and minimum price increment
Calculation: participation change = (selected participation series − its value fast EMA lookback bars ago) / that earlier value × percentage scale, when valid participation and the earlier value is available and nonzero; otherwise unavailable
Calculation: participation velocity = EMA(participation change − nz(participation change[1]), velocity smoothing lookback) when participation is valid
Calculation: normalized volatility = (safe ATR / close × percentage scale) / SMA(safe ATR / close × percentage scale, context lookback), or neutral ratio when the average is unavailable or nonpositive
Calculation: normalized range = ((high − low) / close × percentage scale) / SMA((high − low) / close × percentage scale, context lookback), or neutral ratio when the average is unavailable or nonpositive
Calculation: normalized body = (abs(close − open) / close × percentage scale) / SMA(abs(close − open) / close × percentage scale, context lookback), or neutral ratio when the average is unavailable or nonpositive
Calculation: volatility component = clamp((normalized volatility − volatility offset) / volatility scale × score maximum, score minimum, score maximum)
Calculation: range component = clamp((normalized range − range offset) / range scale × score maximum, score minimum, score maximum)
Calculation: body component = clamp((normalized body − body offset) / body scale × score maximum, score minimum, score maximum)
Calculation: participation component = clamp(abs(participation change) / participation scale × score maximum, score minimum, score maximum)
Calculation: velocity component = clamp(abs(participation velocity) / velocity scale × score maximum, score minimum, score maximum)
Calculation: price displacement = (close − EMA(close, longer slow EMA lookback)) / max(safe ATR, minimum price increment)
Calculation: distance component = clamp(abs(price displacement) / distance scale × score maximum, score minimum, score maximum)
Calculation: cascade-risk score = clamp(volatility component × volatility weight + range component × range weight + body component × body weight + participation component × participation weight + velocity component × velocity weight + distance component × distance weight, score minimum, score maximum)
Calculation: upper-wick percentage = (high − max(open, close)) / max(high − low, minimum price increment) × percentage scale
Calculation: lower-wick percentage = (min(open, close) − low) / max(high − low, minimum price increment) × percentage scale
Calculation: downside cascade-risk flag = valid participation AND cascade-risk score >= cascade threshold AND ((close < open AND close < EMA(close, shorter fast EMA lookback) AND close < EMA(close, longer slow EMA lookback)) OR (upper-wick percentage > wick threshold AND close < EMA(close, shorter fast EMA lookback))) AND price displacement < −distance threshold
Calculation: upside cascade-risk flag = valid participation AND cascade-risk score >= cascade threshold AND ((close > open AND close > EMA(close, shorter fast EMA lookback) AND close > EMA(close, longer slow EMA lookback)) OR (lower-wick percentage > wick threshold AND close > EMA(close, shorter fast EMA lookback))) AND price displacement > distance threshold
Calculation: downside persistence = count of true downside cascade-risk flags over persistence lookback / persistence lookback × percentage scale
Calculation: upside persistence = count of true upside cascade-risk flags over persistence lookback / persistence lookback × percentage scale
Long: upside cascade-risk flag AND upside persistence >= persistence threshold
Short: downside cascade-risk flag AND downside persistence >= persistence threshold