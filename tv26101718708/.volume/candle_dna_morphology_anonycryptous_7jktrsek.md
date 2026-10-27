# Candle DNA Morphology | Anonycryptous

- url: https://www.tradingview.com/script/7JKtrsEk-Candle-DNA-Morphology-Anonycryptous/
- type: indicator
- pine_id: PUB;1c9bc591fec34fc2bd8dcaa5059790b7
- version: 1.0

## Description

Candle DNA Morphology | Anonycryptous
Description & user manual

Why is this indicator different:
Most candle analysis tools work with names. They look at a candle and call it an engulfing, a hammer, a doji, a shooting star. They compare shape against a fixed template and fire a signal when the match is close enough. The problem is that names are approximations. A hammer in a trending market is not the same as a hammer at a structural level with elevated volume. A name cannot capture that. A fixed template cannot either.

Candle DNA Morphology works differently.
It does not use names. It does not use templates. It compares the current candle to every historical candle within a configurable lookback window and finds the one that is mathematically closest — across up to eight normalized dimensions simultaneously. Body size, wick proportions, body position within the range, relative volume, candle size relative to recent volatility, trend alignment, and structural context. Then it tells you what happened after that historical candle, directly on the chart, with a single marker you can hover.
Other tools that use candle similarity show you statistics. Continuation rates. Reversal percentages. Tables to read and interpret. You still have to decide what the numbers mean and whether they matter right now.
Candle DNA Morphology does not show you statistics. It shows you a signal — the exact historical candle that matched, marked on the chart, with the date, the score, the direction, the R value, the percentage move, and the price move of what followed. No table to interpret. No calculation required. The information is in the hover.
The score tells you how close the match was. The tier tells you how rare it is. The color tells you the direction. Everything else is in the tooltip.

Important notice
Candle DNA Morphology generates signals based on historical pattern similarity and price behavior.
These signals are not financial advice.
They do not predict the future.
They do not guarantee profitability.
The outcome values shown — R, percentage, and price — are historical measurements from the matched candle in the past. They reflect what happened then, on that instrument, at that price level. The market may behave differently now. Similar candles can produce different results. These values are context, not certainty.
All trading decisions are made entirely by the user.
Always manage your own risk. Always apply your own judgment.

1. Overview
Candle DNA Morphology is a candle fingerprint matching indicator built around the mathematical similarity between the current candle and historical ones — and what those historical candles preceded.

What it includes:
- Up to 8-dimensional candle fingerprint matching using Euclidean distance
- Configurable lookback window from 50 to 1000 bars
- Three signal quality tiers: standard, elite, and ultra
- Hoverable triangle markers on signal bars with full match details in the tooltip
- Diamond marker and vertical line on the exact historical matched candle
- Configurable cooldown between signals to prevent clustering
- Signal mode selector: current bar, match bar, or both
- Dynamic score normalization — score stays 0-100 regardless of how many dimensions are active
- Vertical signal line and background glow on qualifying bars
- Live dashboard with score bar, tier, bias, match date, outcome in R / percentage / price, cooldown countdown, active dimensions, and ATR
- All times displayed in the timezone you select in the dashboard settings
- Four alerts: bull match, bear match, elite match (90+), ultra match (95+)

2. How the fingerprint works
Every candle is described by a set of normalized values between 0 and 1. These values capture the shape and context of the candle without using price or time units — which is what makes the engine self-calibrating across instruments and timeframes.
The five core dimensions are always active:
Body ratio. The size of the body relative to the total candle range. A full-body candle scores near 1. A doji scores near 0.
Upper wick. The upper wick as a proportion of the total range. A long upper wick scores high. A candle with no upper wick scores 0.
Lower wick. Same logic for the lower wick.
Body position. Where the body sits within the range — 0 is at the bottom, 1 is at the top. A bullish candle with a close near the high scores near 1. A bearish candle with a close near the low scores near 0.
Relative volume. Volume divided by the 20-bar average, capped at 3x and normalized. A spike at 2x average scores higher than a quiet bar at 0.8x.
Three optional dimensions can be enabled independently:
Atr percentile (dimension 6). How large the current candle is relative to recent volatility. Measures the candle range against the 14-bar ATR, normalized to a 0-2x cap. A large candle matches better with historically large candles.
Trend alignment (dimension 7). How far the close sits above or below EMA 21, normalized to the ATR. A bullish candle well above the EMA matches better with historical bullish candles that were also above the EMA.
Candle context (dimension 8). The relationship between the current candle and the previous one. Inside bars score 0. Outside bars score 1. Normal bars score 0.5. This dimension helps the engine recognize structural setups like inside bar breakouts.

3. Scoring and tiers
Similarity is measured using Euclidean distance — the straight-line distance between two candles in multi-dimensional space. The closer two candles are in this space, the more similar they are.
The maximum possible distance scales automatically with the number of active dimensions, so the score always ranges from 0 to 100 regardless of configuration. A score of 100 would mean a perfect match across all active dimensions. A score of 70 means a strong structural similarity. A score of 95 or above is exceptionally rare.
Three tiers determine how signals are displayed:
Standard (70-89). Green for bull, red for bear. The match is meaningful but not uncommon.
Elite (90-94). Gold marker with a star prefix ★. The match is close enough to be notable. These appear infrequently.
Ultra (95+). Cyan marker with a diamond prefix ◈. A near-identical historical candle was found. Very rare. When one fires, it is worth attention.

4. Understanding the signal
When a signal fires, two things appear on the chart depending on your signal mode setting.
A triangle on the current bar points in the direction the market moved after the historical match — up for a bullish outcome, down for a bearish one. Hovering the triangle with your cursor or S-Pen shows the full match details: the date and time of the historical candle, the score, the tier, the bias, the outcome in R, and the R value.
When a signal fires, two dotted lines and a vertical connector appear on the chart. The first dotted line runs horizontally from the signal bar close — this is the entry reference level, the price from which all R, percentage, and dollar measurements are calculated. The second dotted line shows the target level — where the market would reach if the historical outcome repeats. A vertical connector at the end of the forward window closes the structure. All three lines run exactly as many bars as your forward outcome setting.
The target level is calculated using the current ATR, not the historical ATR from the matched candle. This makes it relevant to the current market conditions. Hovering the target line shows both values — the target using the current ATR and the target using the historical ATR — so you can see how much volatility has changed between then and now. If the current ATR is significantly higher than the historical ATR, the target is further away than it was in the original setup. If it is lower, the target is closer.
A diamond and a vertical line on the historical matched candle shows you exactly which bar was used as the reference. The line runs through the full range of that candle so there is no ambiguity about which bar matched. The color follows the signal tier.
In addition to the dotted lines, the indicator can draw historical projection candles to the right of the signal bar. This feature is off by default and can be enabled in the visuals settings. When enabled, candles appear to the right of the signal bar showing the exact OHLC of the bars that followed the historical matched candle. Each candle has a body and centered wicks, drawn in the tier color of the signal. They scale correctly with chart zoom. A small label above the first candle reads "Historical projection" to make it immediately clear that these are historical bars, not predictions. The number of projection candles follows your forward outcome setting. Body transparency and wick transparency are independently configurable in settings.
The bias shown in the dashboard and the tooltip is the direction the market moved after the matched candle — not a prediction of what will happen now. It is historical context, not a guarantee.
All times shown in this indicator use the timezone you select in the dashboard settings. The default is UTC. Set it to your local timezone — for example UTC+2 for Amsterdam, UTC-4 for New York, UTC+9 for Tokyo — and all match times will display in your local time automatically.

5. Understanding the outcome values
The dashboard and tooltip show three outcome measurements for the historical matched candle. All three describe the same move — the price action in the bars following that historical candle — expressed in different units.
Outcome (R). How far price moved after the matched candle, expressed as a multiple of the ATR at that historical bar. This is the primary measurement. It is instrument-independent and works the same on BTC, SOL, MNQ, or any other asset. A value of +2.4R means price moved 2.4 times the ATR upward in the forward window.
Outcome (%). The same move expressed as a percentage of the close price at the matched candle. This gives a more intuitive sense of the magnitude for traders who think in percentage terms.
Outcome (price). The same move expressed in the currency of the instrument. This is the raw price distance the market covered — for example, $1,075 on Bitcoin or $0.87 on SOL. This value is calculated using the ATR and close price at the historical match bar, not at the current price.
The target line on the chart uses the current ATR rather than the historical ATR. This is intentional — the current ATR reflects how the market is moving right now, making the projected target more relevant to your actual trade. The historical ATR is still shown in the target line tooltip for reference, so you can see whether volatility has expanded or contracted since the original setup occurred. A large difference between the two ATR values means the market is in a different volatility regime than it was at the time of the match.
An important note on the price value: this reflects the historical move at the time and price of the matched candle. If Bitcoin was at 60,000 when the match occurred and is now at 78,000, the same R move produces a larger dollar value today than it did then. The price outcome is historical context — it shows what that candle type led to in dollar terms at that moment, not what the current setup will produce now.
This is not your personal risk-to-reward ratio. The R value gives you the historical move size. Your stop loss placement determines your actual R:R.

6. Bias and cooldown
The bias shown in the dashboard reflects the outcome direction of the current best match. It shows bull when the matched historical candle was followed by an upward move, and bear when it was followed by a downward move.
Bias changes when a new bar closes and the engine finds a different best match with a different historical outcome direction, or when the cooldown expires and a new signal fires pointing in a new direction.
During cooldown, the dashboard shows — wait. The last match date and all three outcome values remain visible. No new signal fires until the cooldown bar count has elapsed. The cooldown countdown shows how many bars remain before the next signal is allowed, or ready when it can fire freely.
Cooldown prevents signal clusters from forming on consecutive bars where the same setup repeats. On faster timeframes with many morphologically similar candles, a cooldown of 15 bars or more is strongly recommended.

7. Self-calibration
All fingerprint dimensions are normalized to values between 0 and 1. Volume is measured relative to its own 20-bar average. Candle size is measured relative to the ATR. Trend alignment is measured in ATR units. There are no fixed price thresholds anywhere in the engine.
This means the indicator adapts automatically to different instruments and timeframes. A BTC candle and an MNQ candle with the same proportional shape, same relative volume, and same relationship to their respective EMAs will produce the same fingerprint score — even though one trades at 78,000 and the other at 20,000.
When switching instruments, only the min match score typically needs a small adjustment. SOL and other volatile assets produce more morphological variation, so a slightly lower score threshold (75-80) often works better. More structured instruments like futures perform well at 85-90.

8. Settings guide
8.1 Match engine
Lookback window (bars). How many historical bars to scan for fingerprint matches. Range: 50-1000. Recommended: 500 on 1m-5m charts, 1000 on 15m and above. A larger window finds better matches but takes longer on lower timeframes.
Min match score (0-100). The minimum similarity score required to fire a signal. 70-79 is standard, 80-89 is strong, 90-94 is elite, 95+ is ultra. Start at 85 and adjust from there.
Cooldown between signals (bars). Minimum bars between signals. On a 5m chart, 15 bars equals 75 minutes. On a 1H chart, 15 bars equals 15 hours. Lower values produce more signals. Higher values enforce a minimum spacing between setups.
Dimension 6 — Atr percentile. Adds candle size context relative to recent volatility. Recommended: on.
Dimension 7 — Trend alignment. Adds EMA 21 directional context. Recommended: on.
Dimension 8 — Candle context. Adds inside/outside bar structural context. Recommended: on.

8.2 Outcome filter
Forward outcome (bars). How many bars after the historical match are used to measure the resulting move. Match this to your typical trade duration. On a 5m chart with 6 bars, the engine looks at 30 minutes of forward price action to determine the outcome direction and magnitude.
Min outcome move (ATR x). The historical match only qualifies if the resulting move exceeded this ATR multiple within the forward window. Filters out matches where the historical candle led to no meaningful move. Recommended: 1.0-2.0.

8.3 Visuals
Signal mode. Current bar only shows only the triangle. Match bar only shows only the diamond and vertical line on the historical candle. Both shows both simultaneously.
Show score on marker. When on, the triangle displays the score as text. When off, the triangle is clean. Hover always shows the full details regardless.
Signal bar background. Subtle glow on the signal bar in the tier color.
Vertical signal line. A faint vertical box through the signal bar. Useful for identifying signal bars when zoomed out.
Timezone. Select your local timezone from the dropdown. All match times in the dashboard and tooltips display in this timezone. Default is UTC. Amsterdam = UTC+2, London = UTC+1 (summer) or UTC, New York = UTC-4 (summer), Tokyo = UTC+9.

8.4 Dashboard
Score bar — visual meter 0-100 in tier color.
Tier — standard, ★ elite (90+), or ◈ ultra (95+).
Bias — ▲ bull or ▼ bear, or — wait during cooldown.
Match date — date and time of the historical matched candle in your selected timezone.
Outcome (R) — price move after the match in ATR multiples with forward bar count.
Outcome (%) — same move as a percentage of the historical close price.
Outcome (price) — same move in currency units at the historical price level.
Lookback — current lookback window setting.
Min score — current minimum score setting.
Cooldown — bars remaining until next signal, or ready.
Dimensions — how many dimensions are active and which ones (ATR, EMA, CTX).
ATR (14) — current ATR value.

9. Recommended starting settings
For 1m-5m scalping:
Lookback 500, min score 85, cooldown 15 bars, forward outcome 3 bars, min outcome move 1.0.
For 15m-1H:
Lookback 1000, min score 88, cooldown 8 bars, forward outcome 6 bars, min outcome move 1.5.
For 4H and above:
Lookback 1000, min score 90, cooldown 5 bars, forward outcome 4 bars, min outcome move 2.0.

10. How to use
Load the indicator and set signal mode to both. This gives you the triangle on the current signal bar and the diamond with border box on the historical matched candle simultaneously.
When a signal fires, hover the triangle with your cursor or S-Pen. Read the match date (UTC), score, bias, and outcome values. Then locate the diamond on the chart — the bordered box marks exactly which candle was matched. Look at what followed it on the chart. That is your reference.
The three outcome values give you the same historical move in three different units. Use whichever is most natural for how you think about size. The R value is instrument-independent. The percentage gives quick context. The price value shows the raw historical distance.
Watch the cooldown counter in the dashboard. When it shows ready, the next qualifying signal will fire without restriction. When it shows a bar count, the engine is waiting before it can fire again.
If you see too many signals, raise the min match score or increase the cooldown. If you see too few, lower the min outcome move or reduce the min score.
Candle DNA Morphology works best as a confluence tool. It tells you what the current candle morphology historically preceded. Your other indicators — levels, sessions, volume, trend — confirm whether the context justifies acting on it.

11. Disclaimer
This indicator is provided for educational and informational purposes only. Nothing in this document constitutes financial advice or any form of recommendation. Trading financial instruments involves substantial risk of loss. Past performance is not indicative of future results. You may lose all of your invested capital.
Anonycryptous accepts no responsibility or liability for any losses incurred as a result of using this indicator.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Anonycryptous

//@version=6
indicator("Candle DNA Morphology | Anonycryptous", shorttitle="CDM | Anonycryptous", overlay=true, max_labels_count=500, max_lines_count=500, max_bars_back=1100)

max_bars_back(high,   1100)
max_bars_back(low,    1100)
max_bars_back(close,  1100)
max_bars_back(open,   1100)
max_bars_back(volume, 1100)
max_bars_back(time,   1100)

// ═══════════════════════════════════════════════════════════════════
// GROUPS
// ═══════════════════════════════════════════════════════════════════

G_MATCH = "Match Engine"
G_OUT   = "Outcome Filter"
G_VIS   = "Visuals"
G_DASH  = "Dashboard"

// ═══════════════════════════════════════════════════════════════════
// INPUTS — MATCH ENGINE
// ═══════════════════════════════════════════════════════════════════

i_lookback   = input.int   (500,  "Lookback Window (bars)",      minval=50, maxval=1000, group=G_MATCH,
  tooltip="Number of historical bars to scan for candle fingerprint matches. Higher = more candidates but slower. Recommended: 500 on 1m-5m, 1000 on 15m+.")

i_minScore   = input.float (88.0, "Min Match Score (0-100)",     minval=10, maxval=99,   group=G_MATCH,
  tooltip="Minimum similarity score to trigger a signal.\n70-79 = Standard\n80-89 = Strong\n90-94 = Elite\n95+ = Ultra Elite\nHigher = fewer but higher quality signals.")

i_cooldown   = input.int   (15,   "Cooldown Between Signals (bars)", minval=1, maxval=100, group=G_MATCH,
  tooltip="Minimum number of bars between signals. Prevents signal clusters on consecutive bars. On 5m: 15 bars = 75 minutes. On 1H: 15 bars = 15 hours.")

// ── Extra fingerprint dimensions (toggleable) ─────────────────────

i_useAtrPct  = input.bool  (true, "Dimension 6 — ATR Percentile",  group=G_MATCH,
  tooltip="Adds candle size context to the fingerprint. Measures how large the current candle is relative to the last 20 bars using ATR percentile (0=smallest, 1=largest). A large candle matching a historically large candle scores higher than a small candle matching a large one. Recommended: ON.")

i_useTrend   = input.bool  (true, "Dimension 7 — Trend Alignment", group=G_MATCH,
  tooltip="Adds EMA trend direction to the fingerprint. Measures whether the candle closes above or below EMA 21, normalized to the ATR distance. A bullish candle above EMA 21 matches stronger with historical bullish candles that were also above EMA 21. Recommended: ON.")

i_useInside  = input.bool  (true, "Dimension 8 — Candle Context",  group=G_MATCH,
  tooltip="Adds the candle's relationship to the previous candle to the fingerprint. Detects inside bars (range within previous range), outside bars (range exceeds previous), and normal bars. Inside bars followed by breakouts are a well-known setup — this dimension captures that context. Recommended: ON.")

// ═══════════════════════════════════════════════════════════════════
// INPUTS — OUTCOME FILTER
// ═══════════════════════════════════════════════════════════════════

i_fwdBars    = input.int   (6,    "Forward Outcome (bars)",      minval=1, maxval=20,    group=G_OUT,
  tooltip="How many bars after the historical match are used to measure the resulting price move. Match to your trade duration. 5m chart: 6 bars = 30 min. 1H chart: 6 bars = 6 hours.")

i_minMove    = input.float (2.0,  "Min Outcome Move (ATR x)",   minval=0.0, maxval=5.0, group=G_OUT,
  tooltip="Historical match only qualifies if the price moved at least X ATR within the forward window. Filters weak setups. Recommended: 1.0-2.0 for meaningful signals.")

// ═══════════════════════════════════════════════════════════════════
// INPUTS — VISUALS
// ═══════════════════════════════════════════════════════════════════

i_sigMode    = input.string("Both", "Signal Mode",               group=G_VIS,
  options=["Current bar only", "Match bar only", "Both"],
  tooltip="Current bar only = triangle on the signal bar only.\nMatch bar only = diamond on the historical matched candle only.\nBoth = triangle on current bar + diamond on matched historical bar.")

i_showLabel  = input.bool  (true,  "Show Score on Marker",        group=G_VIS,
  tooltip="When ON, the triangle shows the score as text (e.g. 91.2). When OFF, the triangle is clean with no text. Hover always shows full match details regardless of this setting.")

i_showBg     = input.bool  (true,  "Signal Bar Background",      group=G_VIS,
  tooltip="Subtle background glow on the signal bar. Color follows signal quality tier.")

i_showLine   = input.bool  (true,  "Vertical Signal Line",       group=G_VIS,
  tooltip="Vertical line through signal bar. Color follows signal quality tier. Helps isolate signal bars visually.")

i_showGhost  = input.bool  (false, "Historical Projection Candles", group=G_VIS,
  tooltip="Draw ghost candles to the right of the signal bar showing the exact bars that followed the historical matched candle. Outline boxes with subtle glow — historical reference only, not a prediction. Number of candles follows the Forward Outcome setting. Default: off.")

i_ghostBody  = input.int   (60,   "Ghost Body Transparency",   minval=0, maxval=100, group=G_VIS,
  tooltip="Transparency of the ghost candle bodies. 0 = fully opaque, 100 = invisible. Default: 60.")

i_ghostWick  = input.int   (20,   "Ghost Wick Transparency",   minval=0, maxval=100, group=G_VIS,
  tooltip="Transparency of the ghost candle wicks and borders. 0 = fully opaque, 100 = invisible. Default: 20.")

i_bullCol    = input.color (color.rgb(0, 230, 0),    "Bull Color",       group=G_VIS,
  tooltip="Color for standard bullish signals (score below 90).")

i_bearCol    = input.color (color.rgb(230, 0, 0),    "Bear Color",       group=G_VIS,
  tooltip="Color for standard bearish signals (score below 90).")

i_eliteCol   = input.color (color.rgb(255, 214, 0),  "Elite Color (90-94)", group=G_VIS,
  tooltip="Color for elite signals — score 90 to 94. Rare and high quality.")

i_ultraCol   = input.color (color.rgb(21, 244, 238), "Ultra Color (95+)",   group=G_VIS,
  tooltip="Color for ultra elite signals — score 95 and above. Exceptional match quality. Very rare.")

// ═══════════════════════════════════════════════════════════════════
// INPUTS — DASHBOARD
// ═══════════════════════════════════════════════════════════════════

i_showDash   = input.bool  (true,  "Show Dashboard",             group=G_DASH,
  tooltip="Toggle the information panel on or off.")

i_dashPos    = input.string("Bottom Right", "Position",          group=G_DASH,
  options=["Top Left","Top Right","Bottom Left","Bottom Right"],
  tooltip="Corner position of the dashboard.")

i_dashSize   = input.string("Tiny", "Size",                      group=G_DASH,
  options=["Tiny","Small","Normal"],
  tooltip="Text size of the dashboard. Tiny recommended for clean charts.")

i_timezone   = input.string("UTC",  "Timezone",                  group=G_DASH,
  options=["UTC-12","UTC-11","UTC-10","UTC-9","UTC-8","UTC-7","UTC-6","UTC-5",
           "UTC-4","UTC-3","UTC-2","UTC-1","UTC","UTC+1","UTC+2","UTC+3",
           "UTC+4","UTC+5","UTC+6","UTC+7","UTC+8","UTC+9","UTC+10","UTC+11","UTC+12"],
  tooltip="Select your local timezone so match times display in your local time. Default is UTC.\nExamples: Amsterdam/Paris = UTC+2, London = UTC+1 (summer) or UTC, New York = UTC-4 (summer), Tokyo = UTC+9, Sydney = UTC+10.")

// ═══════════════════════════════════════════════════════════════════
// COLORS
// ═══════════════════════════════════════════════════════════════════

BULL_COLOR  = i_bullCol
BEAR_COLOR  = i_bearCol
ELITE_COLOR = i_eliteCol
ULTRA_COLOR = i_ultraCol
CYAN_COLOR  = color.rgb(21, 244, 238)
GOLD_COLOR  = color.rgb(255, 214, 0)
MUTED       = color.rgb(139, 148, 158)

// ═══════════════════════════════════════════════════════════════════
// FINGERPRINT FUNCTION
// Core 5 dimensions (always active), normalized 0.0 - 1.0:
//   [0] body_ratio    body size / total range
//   [1] upper_wick    upper wick / total range
//   [2] lower_wick    lower wick / total range
//   [3] body_position where body sits in range (0=bottom 1=top)
//   [4] rel_volume    volume / 20-bar average capped at 3x
// Optional dimensions (toggleable):
//   [5] atr_pct       candle size percentile vs last 20 bars
//   [6] trend_align   distance above/below EMA21 normalized to ATR
//   [7] candle_ctx    inside bar / outside bar / normal context
// ═══════════════════════════════════════════════════════════════════

f_fingerprint(_o, _h, _l, _c, _vol, _avgVol, _atr, _ema21, _prevH, _prevL) =>
    _range     = _h - _l
    _body      = math.abs(_c - _o)
    _safe      = _range < syminfo.mintick ? syminfo.mintick : _range
    _atrSafe   = _atr > 0 ? _atr : syminfo.mintick

    // Core 5 dimensions
    _bodyRatio = _body / _safe
    _upperWick = (_h - math.max(_o, _c)) / _safe
    _lowerWick = (math.min(_o, _c) - _l) / _safe
    _bodyPos   = (math.min(_o, _c) - _l) / _safe
    _relVol    = _avgVol > 0 ? math.min(_vol / _avgVol, 3.0) / 3.0 : 0.5

    // Dim 6 — ATR percentile: candle range vs ATR, normalized 0-1, capped at 2x ATR
    _atrPct    = math.min(_range / _atrSafe, 2.0) / 2.0

    // Dim 7 — Trend alignment: close vs EMA21 distance normalized to ATR, capped -1 to 1, then 0-1
    _trendRaw  = (_c - _ema21) / _atrSafe
    _trendAlign= (math.max(math.min(_trendRaw, 2.0), -2.0) + 2.0) / 4.0

    // Dim 8 — Candle context vs previous candle
    // Inside bar = 0.0, Normal = 0.5, Outside bar = 1.0
    _isInside  = _h <= _prevH and _l >= _prevL
    _isOutside = _h > _prevH and _l < _prevL
    _candleCtx = _isInside ? 0.0 : _isOutside ? 1.0 : 0.5

    [_bodyRatio, _upperWick, _lowerWick, _bodyPos, _relVol, _atrPct, _trendAlign, _candleCtx]

// ═══════════════════════════════════════════════════════════════════
// EUCLIDEAN DISTANCE — dynamic dimensions
// Only active dimensions contribute to the distance.
// Max distance scales with sqrt(active dims) so score stays 0-100.
// ═══════════════════════════════════════════════════════════════════

f_distance(_a0, _a1, _a2, _a3, _a4, _a5, _a6, _a7,
           _b0, _b1, _b2, _b3, _b4, _b5, _b6, _b7,
           _useAtr, _useTrend, _useInside) =>
    d0  = _a0 - _b0
    d1  = _a1 - _b1
    d2  = _a2 - _b2
    d3  = _a3 - _b3
    d4  = _a4 - _b4
    d5  = _useAtr    ? _a5 - _b5 : 0.0
    d6  = _useTrend  ? _a6 - _b6 : 0.0
    d7  = _useInside ? _a7 - _b7 : 0.0
    math.sqrt(d0*d0 + d1*d1 + d2*d2 + d3*d3 + d4*d4 + d5*d5 + d6*d6 + d7*d7)

f_score(_dist, _useAtr, _useTrend, _useInside) =>
    _dims = 5 + (_useAtr ? 1 : 0) + (_useTrend ? 1 : 0) + (_useInside ? 1 : 0)
    _maxDist = math.sqrt(_dims)
    (1.0 - math.min(_dist, _maxDist) / _maxDist) * 100.0

// ═══════════════════════════════════════════════════════════════════
// SIGNAL QUALITY TIER — based on score
// Standard  : 70-89  bull/bear color
// Elite     : 90-94  gold
// Ultra     : 95+    cyan
// ═══════════════════════════════════════════════════════════════════

f_tierColor(_score, _isBull) =>
    _score >= 95.0 ? ULTRA_COLOR :
      _score >= 90.0 ? ELITE_COLOR :
      _isBull ? BULL_COLOR : BEAR_COLOR

// ═══════════════════════════════════════════════════════════════════
// BASE CALCULATIONS
// ═══════════════════════════════════════════════════════════════════

atrVal = ta.atr(14)
ema21  = ta.ema(close, 21)
avgVol = ta.sma(volume, 20)

[fp0, fp1, fp2, fp3, fp4, fp5, fp6, fp7] = f_fingerprint(
  open, high, low, close, volume, avgVol, atrVal, ema21, high[1], low[1])

// ═══════════════════════════════════════════════════════════════════
// MATCHING LOOP
// Scans the lookback window bar by bar.
// For each historical bar:
//   1. Compute 5-8 dim fingerprint (based on active toggles)
//   2. Calculate Euclidean similarity score (normalized to active dims)
//   3. Measure forward price move (fwdBars after the historical bar)
//   4. Keep the highest-scoring qualifying match
// ═══════════════════════════════════════════════════════════════════

var float bestScore      = 0.0
var int   bestBar        = 0
var int   bestTime       = 0
var float bestOutcome    = 0.0
var int   bestOutBars    = 0
var bool  bestIsBull     = false
var float bestMatchClose = 0.0
var float bestMatchAtr   = 0.0

bestScore      := 0.0
bestBar        := 0
bestTime       := 0
bestOutcome    := 0.0
bestOutBars    := 0
bestIsBull     := false
bestMatchClose := 0.0
bestMatchAtr   := 0.0

// Ensure the loop never references bars that don't exist yet
// and always has room for the forward window
_maxLook = math.min(i_lookback, bar_index - i_fwdBars - 2)

if _maxLook >= i_fwdBars + 2
    for i = i_fwdBars + 2 to _maxLook
        [h0, h1, h2, h3, h4, h5, h6, h7] = f_fingerprint(
          open[i], high[i], low[i], close[i], volume[i], avgVol[i],
          atrVal[i], ema21[i], high[i + 1], low[i + 1])

        dist  = f_distance(
          fp0, fp1, fp2, fp3, fp4, fp5, fp6, fp7,
          h0,  h1,  h2,  h3,  h4,  h5,  h6,  h7,
          i_useAtrPct, i_useTrend, i_useInside)

        score = f_score(dist, i_useAtrPct, i_useTrend, i_useInside)

        // Forward window: measure from bar[i] looking i_fwdBars bars forward
        // i_fwdBars bars after bar[i] = bar[i - i_fwdBars] in series offset
        _fwdIdx     = i - i_fwdBars
        _entryClose = close[i]
        _fwdHigh    = high[_fwdIdx]
        _fwdLow     = low[_fwdIdx]
        _atrAtBar   = math.max(atrVal[i], syminfo.mintick)
        _moveUp     = (_fwdHigh - _entryClose) / _atrAtBar
        _moveDn     = (_entryClose - _fwdLow)  / _atrAtBar
        _outcome    = _moveUp > _moveDn ? _moveUp : -_moveDn

        if score > bestScore and math.abs(_outcome) >= i_minMove
            bestScore      := score
            bestBar        := i
            bestTime       := time[i]
            bestOutcome    := _outcome
            bestOutBars    := i_fwdBars
            bestIsBull     := _outcome > 0
            bestMatchClose := close[i]
            bestMatchAtr   := atrVal[i]

// ═══════════════════════════════════════════════════════════════════
// COOLDOWN + SIGNALS
// ═══════════════════════════════════════════════════════════════════

var int lastSignalBar = 0

cooldownOk  = (bar_index - lastSignalBar) >= i_cooldown
rawSignal   = bestScore >= i_minScore
signal      = rawSignal and cooldownOk
bullSignal  = signal and bestIsBull
bearSignal  = signal and not bestIsBull
eliteSignal = signal and bestScore >= 90.0
ultraSignal = signal and bestScore >= 95.0

if signal
    lastSignalBar := bar_index

sigColor = f_tierColor(bestScore, bestIsBull)

// ═══════════════════════════════════════════════════════════════════
// BACKGROUND — subtle glow on signal bar
// ═══════════════════════════════════════════════════════════════════

bgcolor(i_showBg and signal ? color.new(sigColor, 88) : na, title="Signal Background")

// ═══════════════════════════════════════════════════════════════════
// VERTICAL LINE — narrow box spanning high to low of signal bar
// ═══════════════════════════════════════════════════════════════════

var box sigLine = na

if i_showLine and signal
    if not na(sigLine)
        box.delete(sigLine)
    sigLine := box.new(
      bar_index, high + atrVal * 1,
      bar_index, low  - atrVal * 1,
      border_color = color.new(sigColor, 50),
      border_width = 1,
      bgcolor      = color.new(sigColor, 90))

// ═══════════════════════════════════════════════════════════════════
// SIGNAL MARKERS — hoverable label triangles
// Hover any triangle or diamond for full match info
// Current bar  = triangle pointing in expected direction
// Match bar    = diamond on the exact historical matched candle
// Color = tier: Standard / Elite (90+) / Ultra (95+)
// ═══════════════════════════════════════════════════════════════════

bullAnchor = low  - atrVal * 1.5
bearAnchor = high + atrVal * 1.5

showCurrent = i_sigMode == "Current bar only" or i_sigMode == "Both"
showMatch   = i_sigMode == "Match bar only"   or i_sigMode == "Both"

var label sigTriangle    = na
var label histLabel      = na
var label projLabel      = na
var line  histLine       = na
var line  entryLine      = na
var line  targetLine     = na
var line  connectorLine  = na
var int   lastMatchTime  = 0
var float lastScore      = 0.0
var float lastOutcome    = 0.0
var bool  lastOutBull    = false
var int   lastOutBars    = 0
var float lastMatchClose = 0.0
var float lastMatchAtr   = 0.0

// Ghost candle storage — filled at signal time
var float[] gO    = array.new_float(20, na)
var float[] gH    = array.new_float(20, na)
var float[] gL    = array.new_float(20, na)
var float[] gC    = array.new_float(20, na)
var int     gBar          = 0
var color   gCol          = na
var int     ghostSigBarTime = 0

// Ghost candle drawing objects — pre-created on first bar
var box[]  gBoxes = array.new_box()
var line[] gLines = array.new_line()

if barstate.isfirst
    for _ = 0 to 19
        array.push(gBoxes, box.new(na, na, na, na, border_color=na, bgcolor=na, xloc=xloc.bar_time))

if signal
    _dateStr    = str.format_time(bestTime, "dd MMM HH:mm", i_timezone) + " " + i_timezone
    _scoreStr   = str.tostring(math.round(bestScore, 1))
    _outcomeStr = bestOutcome > 0
      ? "+" + str.tostring(math.round(bestOutcome, 2)) + "R in " + str.tostring(bestOutBars) + " bars"
      : str.tostring(math.round(bestOutcome, 2)) + "R in " + str.tostring(bestOutBars) + " bars"
    _tierStr    = ultraSignal ? "ULTRA (95+)" : eliteSignal ? "ELITE (90-94)" : "STANDARD"
    _dirStr     = bestIsBull ? "BULL" : "BEAR"
    _rrStr      = str.tostring(math.round(math.abs(bestOutcome), 2)) + "R"

    _tip = "Candle Morphology Engine" +
      "\n──────────────────────" +
      "\nMatch date: " + _dateStr +
      "\nScore:      " + _scoreStr + " / 100" +
      "\nTier:       " + _tierStr +
      "\nBias:       " + _dirStr +
      "\nOutcome:    " + _outcomeStr +
      "\nR value:    " + _rrStr

    // Triangle on current bar — label style, tiny, fully hoverable
    if showCurrent
        if not na(sigTriangle)
            label.delete(sigTriangle)
        if not na(entryLine)
            line.delete(entryLine)
        _anchor    = bullSignal ? bullAnchor : bearAnchor
        _style     = bullSignal ? label.style_triangleup : label.style_triangledown
        _scoreText = i_showLabel ? str.tostring(math.round(bestScore, 1)) : ""
        sigTriangle := label.new(
          bar_index, _anchor,
          _scoreText,
          color     = color.new(sigColor, 0),
          textcolor = color.white,
          style     = _style,
          size      = size.tiny,
          tooltip   = _tip)

        // Horizontal dotted entry line at signal bar close
        entryLine := line.new(
          bar_index,             close,
          bar_index + i_fwdBars, close,
          xloc  = xloc.bar_index,
          color = color.new(sigColor, 30),
          width = 1,
          style = line.style_dotted)

        // Target level — current ATR used for relevance to current market
        _moveSize    = math.abs(bestOutcome) * atrVal
        _targetPrice = bullSignal ? close + _moveSize : close - _moveSize

        // Historical target for tooltip reference
        _moveSizeHist    = math.abs(bestOutcome) * bestMatchAtr
        _targetPriceHist = bullSignal ? close + _moveSizeHist : close - _moveSizeHist
        _targetTip = "Target level (current ATR)" +
          "\n──────────────────────" +
          "\nEntry:           " + str.tostring(close, format.mintick) +
          "\nTarget:          " + str.tostring(_targetPrice, format.mintick) +
          "\nMove (current):  " + str.tostring(math.round(_moveSize, 2)) + " " + syminfo.currency +
          "\nMove (historic): " + str.tostring(math.round(_moveSizeHist, 2)) + " " + syminfo.currency +
          "\n──────────────────────" +
          "\nCurrent ATR:     " + str.tostring(atrVal, format.mintick) +
          "\nHistoric ATR:    " + str.tostring(bestMatchAtr, format.mintick) +
          "\nNote: target uses current ATR. Historic ATR shows what actually moved then."

        // Horizontal dotted target line
        if not na(targetLine)
            line.delete(targetLine)
        targetLine := line.new(
          bar_index,             _targetPrice,
          bar_index + i_fwdBars, _targetPrice,
          xloc  = xloc.bar_index,
          color = color.new(sigColor, 30),
          width = 1,
          style = line.style_dotted)

        // Vertical connector at end of forward window
        if not na(connectorLine)
            line.delete(connectorLine)
        connectorLine := line.new(
          bar_index + i_fwdBars, close,
          bar_index + i_fwdBars, _targetPrice,
          xloc  = xloc.bar_index,
          color = color.new(sigColor, 30),
          width = 1,
          style = line.style_dotted)

    // Diamond on historical match candle — hoverable with same info
    if showMatch
        if not na(histLabel)
            label.delete(histLabel)
        if not na(histLine)
            line.delete(histLine)

        _matchIdx = bar_index - bestBar

        // Clean vertical line on exact matched candle — properly managed with var
        histLine := line.new(
          _matchIdx, high[bestBar] + atrVal * 1,
          _matchIdx, low[bestBar]  - atrVal * 1,
          xloc  = xloc.bar_index,
          color = color.new(sigColor, 0),
          width = 1,
          style = line.style_solid)

        histLabel := label.new(
          _matchIdx,
          high[bestBar] + atrVal * 1.2,
          "◆",
          color     = color.new(color.black, 100),
          textcolor = sigColor,
          style     = label.style_none,
          size      = size.huge,
          tooltip   = "Matched Candle — " + _dateStr +
            "\n──────────────────────" +
            "\nScore:    " + _scoreStr + " / 100" +
            "\nTier:     " + _tierStr +
            "\nBias:     " + _dirStr +
            "\nOutcome:  " + _outcomeStr +
            "\nR value:  " + _rrStr)

    lastMatchTime  := bestTime
    lastOutcome    := bestOutcome
    lastOutBull    := bestIsBull
    lastOutBars    := bestOutBars
    lastMatchClose := bestMatchClose
    lastMatchAtr   := bestMatchAtr
    lastScore      := bestScore

    // Store ghost candle OHLC at signal time — bar indices correct here
    gBar            := bar_index
    gCol            := sigColor
    ghostSigBarTime := time
    _off  = close - open[bestBar - 1]
    for k = 1 to math.min(i_fwdBars, 20)
        _idx = bestBar - k
        if _idx >= 0
            array.set(gO, k - 1, open[_idx]  + _off)
            array.set(gH, k - 1, high[_idx]  + _off)
            array.set(gL, k - 1, low[_idx]   + _off)
            array.set(gC, k - 1, close[_idx] + _off)
        else
            array.set(gO, k - 1, na)
            array.set(gH, k - 1, na)
            array.set(gL, k - 1, na)
            array.set(gC, k - 1, na)

// ═══════════════════════════════════════════════════════════════════
// HISTORICAL PROJECTION CANDLES — update on barstate.islast
// Uses pre-created objects updated via set_ functions
// Fully bar_index based — scales correctly with chart zoom
// ═══════════════════════════════════════════════════════════════════

if barstate.islast and i_showGhost and gBar > 0
    if not na(projLabel)
        label.delete(projLabel)

    // Delete old wick lines and recreate with bar_time for centered wicks
    for _ln in gLines
        line.delete(_ln)
    array.clear(gLines)

    _barMs = time - time[1]  // bar duration in milliseconds

    for m = 0 to 19
        _bx = array.get(gBoxes, m)

        if m < i_fwdBars and not na(array.get(gO, m))
            _tLeft  = ghostSigBarTime + _barMs * (m + 1)
            _tRight = _tLeft + _barMs
            _tMid   = _tLeft + _barMs / 2
            _top    = math.max(array.get(gO, m), array.get(gC, m))
            _bot    = math.min(array.get(gO, m), array.get(gC, m))

            // Body via bar_time
            box.set_left(_bx,   _tLeft)
            box.set_right(_bx,  _tRight)
            box.set_top(_bx,    _top)
            box.set_bottom(_bx, _bot)
            box.set_bgcolor(_bx,      color.new(gCol, i_ghostBody))
            box.set_border_color(_bx, color.new(gCol, i_ghostWick))

            // Wick centered via bar_time midpoint
            _wk = line.new(
              _tMid, array.get(gH, m),
              _tMid, array.get(gL, m),
              xloc  = xloc.bar_time,
              color = color.new(gCol, i_ghostWick),
              width = 1)
            array.push(gLines, _wk)
        else
            box.set_bgcolor(_bx,      na)
            box.set_border_color(_bx, na)

    // Projection label
    projLabel := label.new(
      ghostSigBarTime + _barMs,
      array.get(gO, 0) + atrVal * 1.5,
      "Historical projection",
      xloc      = xloc.bar_time,
      color     = color.new(gCol, 85),
      textcolor = color.new(gCol, 0),
      style     = label.style_label_down,
      size      = size.tiny)


// ═══════════════════════════════════════════════════════════════════
// DASHBOARD
// ═══════════════════════════════════════════════════════════════════

var table dash = table.new(position.bottom_right, 2, 14,
  bgcolor      = color.new(#0d1117, 10),
  border_color = color.new(#30363d, 20), border_width = 1,
  frame_color  = color.new(#30363d, 40), frame_width  = 1)

if i_showDash and barstate.islast
    dSize      = i_dashSize == "Tiny" ? size.tiny : i_dashSize == "Small" ? size.small : size.normal
    colorMuted = color.new(#8b949e, 0)
    colorWhite = color.new(#ffffff, 0)
    colorPanel = color.new(#161b22, 0)
    colorHead  = color.new(sigColor, 40)

    _dashPos = switch i_dashPos
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        =>               position.bottom_right
    table.set_position(dash, _dashPos)

    // Row 0 — Header
    table.cell(dash, 0, 0, "DNA Morphology", text_color=colorWhite, bgcolor=colorHead, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 0, timeframe.period + "m", text_color=colorMuted, bgcolor=colorHead, text_size=dSize, text_halign=text.align_right)

    // Row 1 — Score bar + tier color
    _scorePct    = signal ? math.round(bestScore) : 0
    _filled      = math.floor(_scorePct / 10)
    _empty       = 10 - _filled
    _bar         = ""
    _fi          = 0
    while _fi < _filled
        _bar := _bar + "█"
        _fi  := _fi + 1
    _ei = 0
    while _ei < _empty
        _bar := _bar + "░"
        _ei  := _ei + 1
    _scoreNumStr = signal ? str.tostring(math.round(bestScore, 1)) : "—"
    _barAlpha    = signal ? 0 : 60
    table.cell(dash, 0, 1, _bar,         text_color=color.new(sigColor, _barAlpha), bgcolor=colorPanel, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 1, _scoreNumStr, text_color=color.new(sigColor, _barAlpha), bgcolor=colorPanel, text_size=dSize, text_halign=text.align_right)

    // Row 2 — Tier
    _tierDisp  = ultraSignal ? "◈ ULTRA 95+" : eliteSignal ? "★ ELITE 90+" : signal ? "STANDARD" : "—"
    _tierColor = ultraSignal ? ULTRA_COLOR : eliteSignal ? ELITE_COLOR : signal ? colorWhite : colorMuted
    table.cell(dash, 0, 2, "Tier",     text_color=colorMuted, bgcolor=colorPanel, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 2, _tierDisp,  text_color=_tierColor, bgcolor=colorPanel, text_size=dSize, text_halign=text.align_right)

    // Row 3 — Bias
    _dirDisp  = signal ? (bestIsBull ? "▲ BULL" : "▼ BEAR") : "— WAIT"
    _dirColor = signal ? (bestIsBull ? BULL_COLOR : BEAR_COLOR) : colorMuted
    table.cell(dash, 0, 3, "Bias",    text_color=colorMuted, bgcolor=colorPanel, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 3, _dirDisp,  text_color=_dirColor,  bgcolor=colorPanel, text_size=dSize, text_halign=text.align_right)

    // Row 4 — Match date (UTC)
    _dateDisp = lastMatchTime > 0 ? str.format_time(lastMatchTime, "dd MMM HH:mm", i_timezone) + " " + i_timezone : "—"
    table.cell(dash, 0, 4, "Match Date", text_color=colorMuted, bgcolor=colorPanel, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 4, _dateDisp,    text_color=colorWhite, bgcolor=colorPanel, text_size=dSize, text_halign=text.align_right)

    // Row 5 — Outcome R
    _outDisp  = lastMatchTime > 0
      ? (lastOutcome > 0 ? "+" : "") + str.tostring(math.round(lastOutcome, 2)) + "R  " + str.tostring(lastOutBars) + " bars"
      : "—"
    _outColor = lastOutcome > 0 ? BULL_COLOR : lastOutcome < 0 ? BEAR_COLOR : colorMuted
    table.cell(dash, 0, 5, "Outcome (R)", text_color=colorMuted, bgcolor=colorPanel, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 5, _outDisp,      text_color=_outColor,  bgcolor=colorPanel, text_size=dSize, text_halign=text.align_right)

    // Row 6 — Outcome %
    _pctMove  = lastMatchClose > 0 and lastMatchAtr > 0
      ? math.abs(lastOutcome) * lastMatchAtr / lastMatchClose * 100
      : 0.0
    _pctDisp  = lastMatchTime > 0
      ? (lastOutcome > 0 ? "+" : "-") + str.tostring(math.round(_pctMove, 2)) + "%"
      : "—"
    table.cell(dash, 0, 6, "Outcome (%)", text_color=colorMuted, bgcolor=colorPanel, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 6, _pctDisp,      text_color=_outColor,  bgcolor=colorPanel, text_size=dSize, text_halign=text.align_right)

    // Row 7 — Outcome price move (historical value)
    _priceMove = lastMatchClose > 0 and lastMatchAtr > 0
      ? math.abs(lastOutcome) * lastMatchAtr
      : 0.0
    _priceDisp = lastMatchTime > 0
      ? (lastOutcome > 0 ? "+" : "-") + str.tostring(math.round(_priceMove, 2)) + " " + syminfo.currency
      : "—"
    table.cell(dash, 0, 7, "Outcome (price)", text_color=colorMuted, bgcolor=colorPanel, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 7, _priceDisp,        text_color=_outColor,  bgcolor=colorPanel, text_size=dSize, text_halign=text.align_right)

    // Row 8 — Lookback
    table.cell(dash, 0, 8, "Lookback", text_color=colorMuted, bgcolor=colorPanel, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(i_lookback) + " bars", text_color=colorWhite, bgcolor=colorPanel, text_size=dSize, text_halign=text.align_right)

    // Row 9 — Min Score
    table.cell(dash, 0, 9, "Min Score", text_color=colorMuted, bgcolor=colorPanel, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 9, str.tostring(i_minScore, "#.#"), text_color=colorWhite, bgcolor=colorPanel, text_size=dSize, text_halign=text.align_right)

    // Row 10 — Cooldown
    _cdRemain = math.max(0, i_cooldown - (bar_index - lastSignalBar))
    _cdDisp   = _cdRemain > 0 ? str.tostring(_cdRemain) + " bars" : "Ready"
    _cdColor  = _cdRemain > 0 ? colorMuted : color.new(BULL_COLOR, 0)
    table.cell(dash, 0, 10, "Cooldown", text_color=colorMuted, bgcolor=colorPanel, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 10, _cdDisp,    text_color=_cdColor,   bgcolor=colorPanel, text_size=dSize, text_halign=text.align_right)

    // Row 11 — Active dimensions
    _dimCount = 5 + (i_useAtrPct ? 1 : 0) + (i_useTrend ? 1 : 0) + (i_useInside ? 1 : 0)
    _dimStr   = str.tostring(_dimCount) + "/8 dims  " +
      (i_useAtrPct ? "ATR " : "") +
      (i_useTrend  ? "EMA " : "") +
      (i_useInside ? "CTX"  : "")
    table.cell(dash, 0, 11, "Dimensions", text_color=colorMuted, bgcolor=colorPanel, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 11, _dimStr,      text_color=CYAN_COLOR,  bgcolor=colorPanel, text_size=dSize, text_halign=text.align_right)

    // Row 12 — ATR
    table.cell(dash, 0, 12, "ATR (14)", text_color=colorMuted, bgcolor=colorPanel, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 12, str.tostring(atrVal, format.mintick), text_color=colorWhite, bgcolor=colorPanel, text_size=dSize, text_halign=text.align_right)

    // Row 13 — Brand
    table.cell(dash, 0, 13, "Anonycryptous", text_color=color.new(#15f4ee, 0), bgcolor=colorPanel, text_size=dSize, text_halign=text.align_left)
    table.cell(dash, 1, 13, "v1.3",          text_color=colorMuted,            bgcolor=colorPanel, text_size=dSize, text_halign=text.align_right)

// ═══════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════

alertcondition(bullSignal,  "CME Bull Match",  "Candle Morphology Engine - Bull match detected")
alertcondition(bearSignal,  "CME Bear Match",  "Candle Morphology Engine - Bear match detected")
alertcondition(eliteSignal, "CME Elite Match", "Candle Morphology Engine - Elite match 90+ detected")
alertcondition(ultraSignal, "CME Ultra Match", "Candle Morphology Engine - Ultra match 95+ detected")
````
