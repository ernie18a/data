Calculation: Safe ATR = max(ATR(ATR lookback) if available, otherwise true range, minimum tick size)
Calculation: ATR ratio = ATR(ATR lookback) / SMA(ATR(ATR lookback), ATR baseline lookback); use one if the baseline is unavailable or nonpositive
Calculation: Range high = highest(high, range lookback)
Calculation: Range low = lowest(low, range lookback)
Calculation: Range span = max(range high - range low, safe ATR)
Calculation: Range midpoint = the midpoint of range high and range low
Calculation: Latest pivot high = latest confirmed pivot high with left and right lengths equal to pivot length; use range high if unavailable
Calculation: Latest pivot low = latest confirmed pivot low with left and right lengths equal to pivot length; use range low if unavailable
Calculation: Planning side = forced long or short when selected by planning-side mode; otherwise long if EMA(close, fast EMA lookback) >= EMA(close, slow EMA lookback) and close >= EMA(close, slow EMA lookback), short if both comparisons are <=, and otherwise the previous planning side; initially use long if close >= range midpoint, short otherwise
Calculation: Decision reference = the closest-to-close of the planning-side pivot shelf, the planning-side range edge using the balance-edge fraction, and EMA(close, slow EMA lookback); ties favor the pivot shelf, then the range edge
Calculation: Decision distance in ATR = abs(close - decision reference) / safe ATR
Calculation: Zone touched = low <= decision reference + safe ATR * zone half-width in ATR and high >= decision reference - safe ATR * zone half-width in ATR
Calculation: Near decision = zone touched or decision distance in ATR <= decision reach in ATR
Calculation: Invalidation price = decision reference - safe ATR * (zone half-width in ATR + invalidation buffer in ATR) for long; decision reference + the same distance for short
Calculation: Invalidation breached = close < invalidation price for long or close > invalidation price for short
Calculation: Long reaction = planning side is long and zone touched and close > decision reference and close > open and abs(close - open) / max(high - low, minimum tick size) >= minimum body efficiency and max(min(open, close) - low, 0) / safe ATR >= zone half-width in ATR * reaction wick fraction
Calculation: Short reaction = planning side is short and zone touched and close < decision reference and close < open and abs(close - open) / max(high - low, minimum tick size) >= minimum body efficiency and max(high - max(open, close), 0) / safe ATR >= zone half-width in ATR * reaction wick fraction
Calculation: Accepted reaction = not invalidation breached and (long reaction or short reaction)
Calculation: Soft reaction = not invalidation breached and zone touched and ((planning side is long and close > decision reference) or (planning side is short and close < decision reference))
Calculation: Volume ratio = (volume if available, otherwise zero) / (SMA(volume, volume lookback) if available, otherwise volume if available, otherwise zero); use one if the denominator is nonpositive
Calculation: Volume supported = volume ratio >= minimum volume ratio
Calculation: Target room in ATR = max((max(range high, latest pivot high) - close) / safe ATR, 0) for long; max((close - min(range low, latest pivot low)) / safe ATR, 0) for short
Calculation: Room open = target room in ATR >= minimum target room in ATR
Calculation: Risk distance in ATR = max((close - invalidation price) / safe ATR, 0) for long; max((invalidation price - close) / safe ATR, 0) for short
Calculation: Normalize high(value, weak, strong) = zero if strong = weak; otherwise clamp((value - weak) / (strong - weak) * score scale, score minimum, score maximum)
Calculation: Normalize low(value, good, bad) = zero if bad = good; otherwise clamp((bad - value) / (bad - good) * score scale, score minimum, score maximum)
Calculation: Location score = score maximum if zone touched; otherwise Normalize low(decision distance in ATR, 0, decision reach in ATR * location reach multiplier)
Calculation: Reaction score = fully supported reaction score if accepted reaction and volume supported; otherwise unsupported reaction score if accepted reaction; otherwise soft reaction score if soft reaction; otherwise near-decision score if near decision; otherwise distant score
Calculation: Volume score = Normalize high(volume ratio, weak volume ratio, max(minimum volume ratio * volume ratio multiplier, volume ratio upper floor))
Calculation: Trend score = full trend score if the planning side's trend condition holds; otherwise medium trend score if close is on the planning side of EMA(close, slow EMA lookback); otherwise low trend score
Calculation: Room score = Normalize high(target room in ATR, minimum target room in ATR * room weak fraction, strong target room in ATR)
Calculation: Risk score = Normalize high(risk distance in ATR, minimum risk in ATR, ideal risk in ATR) when risk distance in ATR <= ideal risk in ATR; otherwise Normalize low(risk distance in ATR, ideal risk in ATR, maximum risk in ATR)
Calculation: Volatility score = high-volatility score if ATR ratio <= lower volatility boundary; otherwise normal-volatility score if ATR ratio <= middle volatility boundary; otherwise elevated-volatility score if ATR ratio <= upper volatility boundary; otherwise extreme-volatility score
Calculation: Decision score = round(clamp(location score * location weight + reaction score * reaction weight + volume score * volume weight + trend score * trend weight + room score * room weight + risk score * risk weight + volatility score * volatility weight, score minimum, score maximum)), capped at the no-near-decision cap when not near decision, the limited-room cap when room is not open, the tight-risk cap when risk distance is below minimum risk, the wide-risk cap when risk distance is above maximum risk, and the invalidation cap when invalidation is breached
Long: planning side is long AND decision score >= review threshold AND accepted reaction AND room open AND not invalidation breached
Short: planning side is short AND decision score >= review threshold AND accepted reaction AND room open AND not invalidation breached