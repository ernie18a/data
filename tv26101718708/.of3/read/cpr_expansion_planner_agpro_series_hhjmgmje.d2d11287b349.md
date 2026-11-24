Calculation: CPR band = CPR(previous completed T1 high, low, and close), read on chart bars; expose its top, bottom, midpoint, and width
Calculation: ATR = ATR(chart bars, ATR lookback)
Calculation: Safe ATR = max(ATR, or True Range if ATR is unavailable, minimum price increment)
Calculation: Current T1 open and range = open and cumulative high minus low of the still-forming T1 bar, read on chart bars
Calculation: Prior T1 range = high minus low of the last completed T1 bar, read on chart bars
Calculation: Average T1 range = SMA(high minus low, T1 range lookback, calculated on T1 bars and using the last completed T1 bar); use prior T1 range if unavailable
Calculation: Active side = fixed side when the side-mode parameter fixes one; otherwise long if close > CPR top, short if close < CPR bottom, otherwise long if current T1 open > CPR midpoint, short if current T1 open < CPR midpoint, otherwise long if close >= CPR midpoint and short if close < CPR midpoint
Calculation: Range expansion ratio = current T1 range / max(prior T1 range, Safe ATR)
Calculation: Accepted-close count = consecutive chart bars closing beyond the active CPR edge while active side is unchanged; reset to zero when not beyond, start at one when beyond after a reset or side change, otherwise increment the prior count
Calculation: Required accepted closes = base accepted-close parameter adjusted by a sensitivity-selected adjustment, with a sensitivity-selected minimum
Calculation: Relative volume = volume / SMA(volume, volume lookback, chart bars); use a separate fallback parameter when the SMA is not positive
Calculation: CPR width score = normLow(CPR width / Safe ATR, sensitivity-selected width strong threshold, sensitivity-selected width weak threshold)
Calculation: Anchor-open score = score upper bound when current T1 open is within the CPR band; otherwise normLow(distance from the nearest CPR edge / Safe ATR, zero, sensitivity-selected open-distance threshold)
Calculation: Acceptance score = zero unless close is beyond the active CPR edge; otherwise accepted-count score * accepted-count weight + beyond-edge distance score * distance weight, where accepted-count score = normHigh(accepted-close count, zero, required accepted closes) and beyond-edge distance score = normHigh(distance of close beyond the active CPR edge / Safe ATR, zero, sensitivity-selected distance threshold)
Calculation: Range score = normHigh(range expansion ratio, sensitivity-selected weak threshold, sensitivity-selected strong threshold) * range-ratio weight + normHigh(current T1 range, average T1 range * context weak multiplier, average T1 range * context strong multiplier) * range-context weight
Calculation: Target rail = active CPR edge projected in the active-side direction by max(clean-target-room ATR parameter * Safe ATR, prior T1 range * target-range multiplier, CPR width * CPR-width multiplier)
Calculation: Target room ATR = distance from close to target rail in the active-side direction / Safe ATR
Calculation: Target-room score = normHigh(target room ATR, target-score weak threshold, clean-target-room ATR parameter)
Calculation: Expansion score = round(clamp(CPR width score * width weight + anchor-open score * open weight + acceptance score * acceptance weight + range score * range weight + target-room score * target weight, score lower bound, score upper bound)); each score weight is a separate parameter
Calculation: Invalidation rail = CPR bottom minus Safe ATR * invalidation-buffer parameter for a long active side; CPR top plus Safe ATR * invalidation-buffer parameter for a short active side
Calculation: Invalidation risk = close < invalidation rail for a long active side, or close > invalidation rail for a short active side
Calculation: Accepted confirmation = close beyond the active CPR edge AND accepted-close count >= required accepted closes AND the selected confirmation-mode gates pass; the close gate passes always in realtime-allowed mode and otherwise only on a confirmed chart bar; the volume gate requires relative volume >= the sensitivity-selected threshold in volume or strict mode and otherwise passes; the strict gate requires range expansion ratio, target room ATR, and CPR width score to meet their separate strict-mode thresholds and otherwise passes
Calculation: Target blocked = target room ATR < target-blocked threshold; target extended = target room ATR <= target-extension threshold
Calculation: Ready state = valid CPR AND accepted confirmation AND expansion score >= READY threshold AND NOT invalidation risk AND NOT target blocked
Calculation: Watch state = valid CPR AND NOT ready state AND NOT invalidation risk AND close beyond the active CPR edge AND expansion score >= WATCH threshold
Calculation: Major follow-through event = confirmed chart bar AND accepted confirmation AND range expansion ratio >= follow-through threshold AND expansion score >= alert-score threshold AND the same follow-through condition was false on the prior chart bar
Long: active side is long AND (ready state OR watch state OR major follow-through event)
Short: active side is short AND (ready state OR watch state OR major follow-through event)
Exit: long, active side is long AND invalidation risk
Exit: short, active side is short AND invalidation risk