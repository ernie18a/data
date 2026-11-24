Calculation: Support level = the latest confirmed Pivot Low(low, pivot lookback, pivot lookback) whose pivot age is within the shelf-age limit.
Calculation: Resistance level = the latest confirmed Pivot High(high, pivot lookback, pivot lookback) whose pivot age is within the shelf-age limit.
Calculation: Chosen defense direction = the manually selected direction when manual selection is configured; in automatic mode choose bullish when only a support level exists; with both levels, let trend favor support when close >= EMA(close, slow lookback) OR EMA(close, fast lookback) >= EMA(close, slow lookback), where fast lookback is shorter than slow lookback; choose bullish when trend favors support and abs(close - support level) <= abs(close - resistance level) × the favorable-trend proximity factor, or when trend does not favor support and abs(close - support level) < abs(close - resistance level) × the other-trend proximity factor; otherwise choose bearish. With only a resistance level choose bearish.
Calculation: Chosen defense level = support level for bullish direction or resistance level for bearish direction; no active plan exists if the chosen level is unavailable.
Calculation: Safe ATR = max(ATR(ATR lookback), using True Range when ATR is unavailable, and minimum tick).
Calculation: Sensitivity scale = the scale selected by the sensitivity setting.
Calculation: Defense-zone half-width = safe ATR × defense-zone ATR parameter × sensitivity scale.
Calculation: Zone contact = high >= chosen defense level - defense-zone half-width AND low <= chosen defense level + defense-zone half-width.
Calculation: Near defense level = abs(close - chosen defense level) <= safe ATR × activation-distance ATR parameter × sensitivity scale.
Calculation: Risk edge = chosen defense level - safe ATR × risk-edge ATR parameter for bullish direction, or chosen defense level + safe ATR × risk-edge ATR parameter for bearish direction.
Calculation: Target guide = chosen defense level + abs(chosen defense level - risk edge) × target-R parameter for bullish direction, or chosen defense level - abs(chosen defense level - risk edge) × target-R parameter for bearish direction.
Calculation: Target room in ATR = (target guide - close) / safe ATR for bullish direction, or (close - target guide) / safe ATR for bearish direction.
Calculation: Invalidation = a close below the risk edge for bullish direction or above it for bearish direction; invalidation remains latched until the chosen level or direction changes.
Calculation: Recent touch = the number of chart bars since the first zone contact on the current chosen level and direction is within the response-window parameter; reset the touch age when the chosen level or direction changes, and record a touch only on an evaluation-ready bar.
Calculation: Evaluation-ready = the bar is closed unless live updating is configured.
Calculation: A zone-entry event occurs when there is zone contact and either the chosen level or direction has changed or the previous chart bar had no zone contact.
Calculation: Bar range = max(high - low, minimum tick).
Calculation: Normalized-high score(x, weak, strong) = 0 if strong = weak; otherwise min(max(100 × (x - weak) / (strong - weak), 0), 100).
Calculation: Normalized-low score(x, good, bad) = 0 if bad = good; otherwise min(max(100 × (bad - x) / (bad - good), 0), 100).
Calculation: Peak score(x, low, ideal, high) = normalized-high score(x, low, ideal) when x <= ideal, otherwise normalized-low score(x, ideal, high).
Calculation: Wick score = normalized-high score((min(open, close) - low) / bar range for bullish direction, or (high - max(open, close)) / bar range for bearish direction, using separate weak-wick and strong-wick parameters).
Calculation: Probe depth in ATR = max((chosen defense level - low) / safe ATR, 0) for bullish direction, or max((high - chosen defense level) / safe ATR, 0) for bearish direction.
Calculation: Retest-depth score for a recent touch = Peak score(probe depth in ATR, zero-probe parameter, ideal-probe ATR parameter, max(deep-probe ATR parameter, ideal-probe ATR parameter + probe-margin parameter)).
Calculation: Defended-side close distance in ATR = (close - chosen defense level) / safe ATR for bullish direction, or (chosen defense level - close) / safe ATR for bearish direction.
Calculation: Close-side score = normalized-high score(defended-side close distance in ATR, -defense-zone ATR parameter, close-response ATR parameter).
Calculation: Close-location score = normalized-high score((close - low) / bar range for bullish direction, or (high - close) / bar range for bearish direction, using separate weak-location and strong-location parameters).
Calculation: Close-response score = close-side weight × close-side score + close-location weight × close-location score.
Calculation: Time-at-level score = 0 without a recent touch; otherwise max(normalized-high score(touch age, zero-age parameter, ideal-hold-bars parameter) when touch age <= ideal-hold-bars parameter, or normalized-low score(touch age, ideal-hold-bars parameter, response-window parameter) otherwise, minimum-time-score parameter).
Calculation: Relative volume = volume / SMA(volume, volume-baseline lookback) when that average is positive, otherwise the neutral-relative-volume parameter.
Calculation: Volume score = normalized-high score(relative volume, weak-relative-volume parameter, strong-relative-volume parameter) when volume support is enabled; otherwise the neutral-volume-score parameter.
Calculation: Retest quality score, for a recent touch = depth weight × retest-depth score + wick weight × wick score + close-response weight × close-response score + time weight × time-at-level score + volume weight × volume score.
Calculation: Effective defended threshold = max(defended-score parameter, watch-score parameter + defended-threshold gap parameter).
Calculation: Reaction quality = reaction-wick weight × wick score + reaction-close weight × close-response score + reaction-volume weight × volume score.
Long: an active bullish plan AND evaluation-ready AND a zone-entry event.
Short: an active bearish plan AND evaluation-ready AND a zone-entry event.
Long: an active bullish plan AND evaluation-ready AND recent touch AND retest quality score >= effective defended threshold AND target room in ATR >= minimum-target-room parameter AND not invalidated AND retest quality score was below the defended threshold on the previous chart bar, or target room was below its minimum, or the plan was invalidated on that bar.
Short: an active bearish plan AND evaluation-ready AND recent touch AND retest quality score >= effective defended threshold AND target room in ATR >= minimum-target-room parameter AND not invalidated AND retest quality score was below the defended threshold on the previous chart bar, or target room was below its minimum, or the plan was invalidated on that bar.
Long: an active bullish plan AND evaluation-ready AND recent touch AND retest quality score >= watch-score parameter AND not defended AND not invalidated AND watch state was false on the previous chart bar.
Short: an active bearish plan AND evaluation-ready AND recent touch AND retest quality score >= watch-score parameter AND not defended AND not invalidated AND watch state was false on the previous chart bar.
Long: an active bullish plan AND evaluation-ready AND recent touch AND retest quality score < watch-score parameter AND not invalidated AND weak-retest state was false on the previous chart bar.
Short: an active bearish plan AND evaluation-ready AND recent touch AND retest quality score < watch-score parameter AND not invalidated AND weak-retest state was false on the previous chart bar.
Long: an active bullish plan AND (near the defense level OR recently touched) AND not invalidated AND evaluation-ready AND the context-mark interval has elapsed.
Short: an active bearish plan AND (near the defense level OR recently touched) AND not invalidated AND evaluation-ready AND the context-mark interval has elapsed.
Long: an active bullish plan AND reaction quality >= reaction-clean threshold.
Short: an active bearish plan AND reaction quality >= reaction-clean threshold.