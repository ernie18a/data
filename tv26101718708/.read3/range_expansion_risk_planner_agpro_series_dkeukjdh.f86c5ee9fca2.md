Calculation: prior range high = Highest(high, source range lookback)[1]
Calculation: prior range low = Lowest(low, source range lookback)[1]
Calculation: prior range width = max(prior range high - prior range low, minimum price increment)
Calculation: prior range midpoint = (prior range high + prior range low) / two
Calculation: risk ATR = max(ATR(ATR length), when available, otherwise True Range, minimum price increment)
Calculation: bar range = max(high - low, minimum price increment)
Calculation: body share = abs(close - open) / bar range
Calculation: quiet bar = bar range / risk ATR <= quiet-bar ATR threshold AND body share <= quiet-bar body threshold
Calculation: prior quiet run length = previous quiet run length + one bar when the previous bar was quiet, otherwise zero
Calculation: required maturity bars = max(minimum maturity bars, round(source range lookback * maturity fraction * sensitivity-selected maturity multiplier))
Calculation: range-width baseline = SMA(prior range width, range-width baseline length)
Calculation: range-width ratio = prior range width / range-width baseline when the baseline is positive, otherwise the neutral ratio
Calculation: high-good score(x, weak, strong) = clamp((x - weak) / (strong - weak) * score scale, score floor, score ceiling), or score floor when strong equals weak
Calculation: low-good score(x, good, bad) = clamp((bad - x) / (bad - good) * score scale, score floor, score ceiling), or score floor when bad equals good
Calculation: peak score(x, weak, ideal, strong) = high-good score(x, weak, ideal) when x <= ideal, otherwise low-good score(x, ideal, strong)
Calculation: range maturity score = clamp(range-age score * range-age weight + range-width score * range-width weight + range-compression score * range-compression weight, score floor, score ceiling), where range-age score = high-good score(prior quiet run length, required maturity bars * weak-age fraction, required maturity bars * strong-age multiple), range-width score = peak score(prior range width / risk ATR, weak range-width ATR, ideal range-width ATR, strong range-width ATR), and range-compression score = low-good score(range-width ratio, good compression ratio, bad compression ratio)
Calculation: break threshold = minimum edge-close ATR * sensitivity-selected break multiplier
Calculation: upward break candidate = max(close - prior range high, zero) / risk ATR >= break threshold
Calculation: downward break candidate = max(prior range low - close, zero) / risk ATR >= break threshold
Calculation: automatic break side = long when only the upward break candidate is true, short when only the downward break candidate is true, otherwise long when close >= prior range midpoint and short otherwise
Calculation: selected break side = long when expansion-side setting permits long and the upward break candidate is true; short when it permits short and the downward break candidate is true; in automatic mode, the automatic break side only when exactly one break candidate is true; otherwise none
Calculation: confirmation eligible = confirmation setting is live updating OR the current chart bar is confirmed
Calculation: target edge = for an active long plan, the nearer of its measured target and the prior highest high over target-side obstacle lookback when that high is beyond the active edge by obstacle-clearance ATR; for an active short plan, the nearer of its measured target and the prior lowest low over target-side obstacle lookback when that low is beyond the active edge by obstacle-clearance ATR; otherwise the measured target; measured target = active edge + active side * active range width * target-range multiple
Calculation: failure rail = active edge - active side * risk ATR * failure-buffer ATR
Calculation: back inside range = active long plan AND close < active edge, OR active short plan AND close > active edge
Calculation: failure crossed = active long plan AND close < failure rail, OR active short plan AND close > failure rail
Calculation: target reached = active long plan AND high >= target edge, OR active short plan AND low <= target edge
Calculation: active-plan failure flag = reset on a new plan; otherwise remains true once failure crossed on a confirmation-eligible bar
Calculation: active-plan target flag = reset on a new plan; otherwise remains true once target reached on a confirmation-eligible bar
Calculation: new plan starts when confirmation eligible AND selected break side exists AND (no active plan OR selected break side differs from active side OR active-plan age > maximum active-plan bars OR active-plan failure flag OR active-plan target flag)
Calculation: active plan = the most recently started plan; on plan start, freeze selected side, prior range high, prior range low, prior range width, range maturity score, and expansion-candle score; retain it until another plan starts
Calculation: active edge = frozen prior range high for a long plan, frozen prior range low for a short plan
Calculation: active range width = max(frozen prior range width, minimum price increment)
Calculation: active-plan age = chart bars since the active plan started
Calculation: active close distance ATR = max(active side * (close - active edge), zero) / risk ATR
Calculation: edge touch = active-plan age > zero AND (active long plan AND low <= active edge + risk ATR * retest-band ATR OR active short plan AND high >= active edge - risk ATR * retest-band ATR)
Calculation: accepted retest = edge touch AND NOT back inside range AND NOT failure crossed
Calculation: recent accepted retest = bars since accepted retest <= retest lookback
Calculation: active close location = (close - low) / bar range for a long plan, (high - close) / bar range for a short plan
Calculation: close confirmation = active close distance ATR >= break threshold * close-confirmation multiplier AND active close location >= close-location threshold
Calculation: candidate close distance ATR = max(active side * (close - prior range edge), zero) / risk ATR, using prior range high for long and prior range low for short
Calculation: candidate close location = (close - low) / bar range for long, (high - close) / bar range for short
Calculation: volume score = missing-volume score when volume is unavailable; otherwise high-good score(volume / SMA(volume, volume-baseline length), weak volume ratio, strong volume ratio), using the neutral ratio when the baseline is unavailable or nonpositive
Calculation: candidate expansion-candle score = clamp(candidate close score * close-score weight + candidate close-location score * location-score weight + candidate body score * body-score weight + candidate range-power score * range-power weight + volume score * volume-score weight, score floor, score ceiling), where candidate close score = high-good score(candidate close distance ATR, break threshold * weak-close fraction, break threshold + strong-close extension), candidate close-location score = clamp(candidate close location * score scale, score floor, score ceiling), candidate body score = high-good score(body share, weak body share, strong body share), and candidate range-power score = peak score(bar range / risk ATR, weak range-power ATR, ideal range-power ATR, strong range-power ATR)
Calculation: current range maturity score = range maturity score using the current prior range
Calculation: active close score = high-good score(active close distance ATR, break threshold * current-close weak fraction, break threshold + current-close strong extension)
Calculation: retest quality score = failure score when the active-plan failure flag is true; otherwise accepted-retest score when accepted retest is true; otherwise recent-retest score when recent accepted retest is true; otherwise back-inside score when back inside range is true; otherwise early-retest score when active-plan age <= retest lookback; otherwise late-retest score
Calculation: target room ATR = max(active side * (target edge - close), zero) / risk ATR
Calculation: failure distance ATR = max(active side * (close - failure rail), zero) / risk ATR
Calculation: room-risk score = clamp(room-distance score * room-distance weight + failure-distance score * failure-distance weight, score floor, score ceiling), where room-distance score = high-good score(target room ATR, minimum target-room ATR * sensitivity-selected room multiplier, ideal target-room ATR * sensitivity-selected room multiplier) and failure-distance score = peak score(failure distance ATR, weak failure-distance ATR, ideal failure-distance ATR, maximum failure-distance ATR)
Calculation: raw planner score = frozen range maturity score * maturity weight + frozen expansion-candle score * expansion weight + active close score * close weight + retest quality score * retest weight + room-risk score * room-risk weight
Calculation: planner score = round(clamp(raw planner score, score floor, score ceiling)), first capping it at the failed-plan score cap when the active-plan failure flag is true, otherwise at the back-inside score cap when back inside range is true, otherwise at the target-reached score cap when the active-plan target flag is true, otherwise at the blocked-room score cap when room-risk score < blocked-room score threshold
Calculation: clean expansion state = active plan AND NOT active-plan failure flag AND NOT active-plan target flag AND NOT back inside range AND target room ATR >= minimum target-room ATR * sensitivity-selected room multiplier AND planner score >= clean-expansion score AND (accepted retest OR recent accepted retest OR close confirmation)
Calculation: display side = active plan side when a plan exists; otherwise selected break side when it exists; otherwise automatic break side
Long: confirmation eligible AND selected break side is long AND (no active plan OR active plan side is short OR active-plan age > maximum active-plan bars OR active-plan failure flag OR active-plan target flag)
Short: confirmation eligible AND selected break side is short AND (no active plan OR active plan side is long OR active-plan age > maximum active-plan bars OR active-plan failure flag OR active-plan target flag)
Long: active plan side is long AND clean expansion state
Short: active plan side is short AND clean expansion state
Long: display side is long
Short: display side is short