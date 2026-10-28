# Graded FVG Indicator

- url: https://www.tradingview.com/script/2V1aGc75-Graded-FVG-Indicator/
- type: indicator
- pine_id: PUB;ceaf4d14255b40dc946e0d95511e7907
- version: 1.0

## Description

Graded FVG Indicator — FVG + IFVG Quality Grading by ApexFlow

━━━━━━━━━━━━━━━━━━━━ ✍️ ORIGINALITY ━━━━━━━━━━━━━━━━━━━━

Written from scratch. The only shared element is the standard, public 3-candle Fair Value Gap definition used across ICT / SMC trading. The 5-factor grading model, quality gates, close-based lifecycle engine, IFVG flip logic, fill shading and per-side zone caps are original. No code from other published scripts is reused.

━━━━━━━━━━━━━━━━━━━━ 📊 WHAT THIS INDICATOR DOES ━━━━━━━━━━━━━━━━━━━━

Most FVG indicators draw every gap they find, and most of those gaps are noise. This one adds three layers on top of standard detection:

[b]Grading:[/b] every FVG is scored 0–100 on five measurable factors and shown as a grade out of 10.
[b]Filtering:[/b] only gaps that clear the grade threshold and two quality gates are drawn. Everything else is discarded.
[b]Lifecycle:[/b] every drawn zone is tracked Fresh → Tested → Partial → Retired, and a zone that price closes through can flip into an Inversion FVG (IFVG).
A standard FVG indicator answers "where are the gaps?" This one also answers "which gaps are worth watching, and what has price done with them since?"

━━━━━━━━━━━━━━━━━━━━ 🔍 FVG DETECTION METHODOLOGY ━━━━━━━━━━━━━━━━━━━━

Candle 1 = bar[2], candle 2 (displacement) = bar[1], candle 3 = current bar. Evaluated on confirmed bars only.

[b]Bullish FVG:[/b] low > high[2] → Top = low (candle 3's low), Bottom = high[2] (candle 1's high)

[b]Bearish FVG:[/b] high < low[2] → Top = low[2] (candle 1's low), Bottom = high (candle 3's high)

Candle 2 creates the gap, but its own high and low are not part of the zone.

[b]ATR yardstick:[/b] every size is measured as a multiple of ATR(14), so grades mean the same thing on any symbol and timeframe. The script uses ATR[2], the value from before the displacement candle, so a huge candle 2 can't inflate the ATR and make itself look smaller.

[b]Ramp function:[/b] most factors convert a measurement to a 0–1 score with ramp(x, lo, hi) = clamp((x − lo) / (hi − lo), 0, 1) Below lo → 0, above hi → 1, linear in between.

━━━━━━━━━━━━━━━━━━━━ 🏅 GRADING SYSTEM (0–10) ━━━━━━━━━━━━━━━━━━━━

Each FVG is scored 0–100 at creation from five factors.

[b]⚡ Displacement (max 30 pts)[/b]: how forcefully price moved.

bodyATR = candle 2 body in the gap direction ÷ ATR[2] (zero if candle 2 closed against the gap)
bodyShare = body ÷ candle 2 range
closeLoc = where candle 2 closed within its range, measured toward the gap direction
legATR = (close − open[2]) in the gap direction ÷ ATR[2] disp = 0.40·ramp(bodyATR, 0.5, 2.0) + 0.25·ramp(bodyShare, 0.40, 0.85) + 0.15·ramp(closeLoc, 0.50, 0.90) + 0.20·ramp(legATR, 1.0, 3.0)
[b]🏗️ Structure (max 25 pts)[/b]: did the move break something that mattered?

Swings are tracked internally with pivots (3 bars each side). A swing stays "intact" until a candle closes beyond it. Nothing is drawn.
Swing break: candle 2 or 3 closed through the latest intact swing → +0.55
Range break: candle 3 closed beyond the highest high / lowest low of the 20 bars ending at candle 1 → +0.25
Squeeze bonus, only if a break happened: 0.20 × (1 − ramp(10-bar range ÷ ATR[2], 2.5, 6.0)). Breaking out of a tight base earns more.
No break, but the move agrees with the direction of the last swing break → 0.35 (continuation)
Otherwise → 0
[b]📈 Relative Volume (max 15 pts)[/b]: was there participation?

rvol = volume[1] ÷ SMA(volume, 20)[2]
vol = ramp(rvol, 0.8, 2.2). Capped, so a 10× spike counts no more than 2.2×.
[b]📐 Gap Size (max 15 pts)[/b]: is the gap meaningful?

gapATR = (top − bottom) ÷ ATR[2]
< 0.10 → 0 (noise) | 0.10–0.50 → ramps up to 1 | 0.50–1.50 → 1 | > 1.50 → declines to 0.4 at 3.0
Abnormally large gaps (news, thin liquidity) are scored down rather than rewarded.
[b]🗺️ Context (max 15 pts)[/b]: is it in a meaningful location?

traffic = share of the 50 bars before candle 1 whose high–low range overlaps the gap
fresh = 1 − ramp(traffic, 0.05, 0.40). Untouched territory scores high; congestion scores low.
pos = gap midpoint's position inside the 50-bar high–low range (0 = range low, 1 = range high)
edge = min(1, |pos − 0.5| × 2). The middle of the range scores 0; the edge or beyond scores 1.
ctx = 0.55·fresh + 0.45·edge
[b]Final score[/b] score = 30·disp + 25·struct + 15·volEff + 15·size + 15·ctx grade = floor(score) ÷ 10, so 69.9 displays as 6.9, never 7.0

Grade thresholds:

🟩 HIGH ≥ 7.0 | 🟨 MEDIUM ≥ 5.0 | ⬜ LOW < 5.0
Default display: HIGH only
Hover any zone's tag to see its full breakdown: every sub-score, the RVOL multiple, gap size in ATR, and which gate capped it, if any.

━━━━━━━━━━━━━━━━━━━━ 🛡️ QUALITY GATES (VOLUME CAN'T RESCUE A WEAK GAP) ━━━━━━━━━━━━━━━━━━━━

[b]Quality-scaled volume:[/b]

core = (30·disp + 25·struct + 15·size + 15·ctx) ÷ 85
volEff = vol × ramp(core, 0, 0.60) Volume only counts in full when the other four factors are already solid (core ≥ 0.60). At core 0.30 it counts half.
[b]Hard gates for HIGH:[/b]

Displacement sub-grade ≥ 4.5/10
gapATR ≥ 0.25 Fail one → capped at MEDIUM. Fail both → LOW, regardless of volume.
[b]No-volume symbols:[/b] when volume is missing (some indices, FX feeds), score = 100 × core. The other four factors fill the full scale. Volume = "Ignore" forces this mode.

[b]Example:[/b] candle 2 = 1.8 ATR closing near its high, breaks a swing high out of a 4-ATR base, 0.6 ATR gap in fresh territory, 1.8× RVOL → 27.2 + 22.9 + 10.7 + 15 + 15 = 90.8 → 9.0/10 HIGH. Weak candle 2 + 5× volume spike → core ≈ 0.28, volume counts less than half → ≈ 3/10 LOW.

━━━━━━━━━━━━━━━━━━━━ 🔄 ZONE LIFECYCLE ━━━━━━━━━━━━━━━━━━━━

Each zone stores two fill depths, updated on every confirmed bar:

wickDepth = how far a wick has reached into the zone (0–1 of its height)
closeDepth = how far a candle close has reached into the zone
States:

🆕 FRESH: untouched
👆 TESTED: wickDepth > 0. A deep wick that closes back out stays TESTED: it's a rejection, not a fill.
🌗 PARTIAL: closeDepth ≥ 0.5, a close past the 50% line (switchable to wick-based)
❌ Retired, per the Mitigation Rule: → Close Through (default): a close beyond the far edge → INVALIDATED → Full Wick Fill: wickDepth reaches 1 → MITIGATED → Close Beyond CE: a close past 50% → MITIGATED A close beyond the far edge always invalidates. Zones are never checked on their own creation bar.
━━━━━━━━━━━━━━━━━━━━ 🟣 INVERSION FVG (IFVG) ━━━━━━━━━━━━━━━━━━━━

When a zone is closed through, the same price range can flip role:

Broken bullish FVG → IFVG ▼ (resistance)
Broken bearish FVG → IFVG ▲ (support)
Break Requirement:

Displacement Gap (default): the breaking candle must itself be candle 3 of a new FVG in the opposite direction, i.e. a real displacement, not a drift
Strong Body: breaking body ≥ 1.0 × ATR
Any Close Through: every close-through flips
IFVG grade:

brkBody = breaking candle body in the break direction ÷ ATR
ifvgScore = score × (0.70 + 0.30·ramp(brkBody, 0.3, 1.5)) If the new grade falls below the display tier, the zone is retired instead.
After the flip, the zone is redrawn in purple from the breaking candle onward and restarts as FRESH. A zone flips only once; closing back through an IFVG retires it.

IFVG ≠ BPR: a Balanced Price Range is only the overlap of a bullish and a bearish FVG. An IFVG is the whole failed zone with its role reversed.

━━━━━━━━━━━━━━━━━━━━ 🔗 MERGING & ZONE LIMITS ━━━━━━━━━━━━━━━━━━━━

Merge: if overlap ÷ smaller zone height ≥ 50%, a new same-direction FVG merges into the existing zone (union of both ranges, better grade kept, reset to FRESH).
Per-side caps: support zones (bullish FVG, IFVG ▲) and resistance zones (bearish FVG, IFVG ▼) are capped separately, 4 each. The oldest zone on a side is removed first, so a strong trend never pushes the other side off the chart.
Only drawn zones are stored. Lower grades are discarded on the spot, which keeps the script well inside TradingView's drawing limits.
━━━━━━━━━━━━━━━━━━━━ 🎨 VISUALS ━━━━━━━━━━━━━━━━━━━━

Two layers per zone: a faint ghost box shows the full original zone, and a solid box shows only the unfilled remainder. The solid box shrinks as price fills the zone.
Opacity drops at each lifecycle step and with lower grades, so a FRESH 9/10 zone stands out most.
Tag at the right edge, e.g. "FVG 8.4/10 · FRESH" or "IFVG ▼ 7.6/10 · TESTED". Hover it for the breakdown.
🟢 Bullish | 🔴 Bearish | 🟣 IFVG. All colours are adjustable.
━━━━━━━━━━━━━━━━━━━━ 🔔 ALERTS ━━━━━━━━━━━━━━━━━━━━

New HIGH bullish FVG / new HIGH bearish FVG
First test of a bullish FVG / a bearish FVG
New IFVG / first test of an IFVG
One "Any alert() function call" alert whose message includes the grade and the zone's price levels All alerts fire once per bar close.
━━━━━━━━━━━━━━━━━━━━ 💡 WHAT IS ORIGINAL ━━━━━━━━━━━━━━━━━━━━

A 5-factor 0–100 FVG grade (displacement, structure, RVOL, size, context), shown out of 10
Quality-scaled volume plus hard gates, so volume can never promote a weak gap
Pre-displacement ATR, so a big candle can't distort its own measurement
A congestion measure that counts prior bars already traded inside the gap
Separate wick and close fill depths, so wick rejections aren't counted as fills
Graded IFVG flip with a selectable break requirement, drawn from the breaking candle onward
Two-layer fill shading, per-side zone caps, and a hover breakdown for every zone
━━━━━━━━━━━━━━━━━━━━ 🧭 HOW TO USE ━━━━━━━━━━━━━━━━━━━━

Focus on FRESH zones with high grades (8+/10).
Hover the tag to see why a zone scored well. Strong displacement + structure is the core.
Watch the first return: a wick rejection keeps a zone TESTED, while a close past 50% shows the imbalance being absorbed.
Treat purple IFVGs as flipped context: former support acting as resistance, or the reverse.
Combine with your own bias, session and risk rules. The grade ranks zones; it does not time entries.
━━━━━━━━━━━━━━━━━━━━ ⚙️ RECOMMENDED SETTINGS ━━━━━━━━━━━━━━━━━━━━

Stocks / Futures: defaults
Crypto / FX: HIGH Grade 7.5 (these markets print more strong gaps)
Indices / no-volume feeds: Volume = Ignore
Scalping (1–5m): Context Range 30, Max Zones per Side 3
Swing (4H–D): defaults
Cleaner chart: Labels = Off, Shade Filled Portion = On
More zones: Display = HIGH + MEDIUM
━━━━━━━━━━━━━━━━━━━━

No repainting. No lookahead. No request.security(). Zones are created, graded and updated only on barstate.isconfirmed, using the chart's own timeframe. The only thing that changes on the live bar is the boxes' right edge.

━━━━━━━━━━━━━━━━━━━━ 🧩 WHY THESE COMPONENTS WORK TOGETHER ━━━━━━━━━━━━━━━━━━━━

An FVG on its own only says price moved fast enough to leave a gap. Each factor checks a different question:

Displacement: was the move forceful?
Structure: did it break anything?
Volume: was there participation?
Size: is the gap meaningful?
Context: is it in fresh territory, at a relevant location?
No single factor separates a meaningful imbalance from a random gap; the combined grade does that ranking. The lifecycle and IFVG layers then show what price has done with the zone since. The result is fewer zones on the chart, each with a clear reason for being there.

━━━━━━━━━━━━━━━━━━━━ ⚠️ LIMITATIONS ━━━━━━━━━━━━━━━━━━━━

A grade measures how significant an imbalance was when it formed. It is not a probability that price will react, and not an entry signal.
Weights and thresholds are fixed heuristics. Tune the grade thresholds for your market.
Volume scoring is only as good as your data feed.
Educational purposes only. Not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ApexFlow_
// ═══════════════════════════════════════════════════════════════════════════
//   Graded FVG Indicator
//   Detects standard 3-candle Fair Value Gaps, grades every one of them /10
//   on displacement, structure, relative volume, gap size and context, and
//   draws only the imbalances that clear the quality gates. Each drawn zone
//   is tracked Fresh → Tested → Partial → Mitigated / Invalidated, and a
//   closed-through zone flips into a purple Inversion FVG (IFVG). No repaint.
//   Fewer FVGs. Better FVGs.
// ═══════════════════════════════════════════════════════════════════════════
//@version=6
indicator("Graded FVG Indicator", shorttitle="Graded FVG", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500, max_bars_back=300)

// ───────────  QUALITY ENGINE  ───────────
gQ = "Quality Engine"
showMode = input.string("HIGH only", "Display",                   options=["HIGH only", "HIGH + MEDIUM", "All"], group=gQ, tooltip="Which grades are drawn. Everything below is graded and discarded — never stored, never drawn.")
hiTh     = input.float(7.0,  "HIGH Grade (/10)",                  minval=0.1, maxval=10.0, step=0.1, group=gQ, tooltip="Minimum grade for HIGH. Raise it to see fewer, stronger zones (7.5 suits crypto / FX).")
medTh    = input.float(5.0,  "MEDIUM Grade (/10)",                minval=0.1, maxval=10.0, step=0.1, group=gQ, tooltip="Minimum grade for MEDIUM. Clamped to the HIGH grade if set above it.")
dispGate = input.float(4.5,  "Displacement Gate (/10)",           minval=0.0, maxval=10.0, step=0.5, group=gQ, tooltip="Displacement sub-grade an FVG must reach to be eligible for HIGH. Fail it and the zone is capped at MEDIUM; fail this and the size gate and it is LOW — no matter how big the volume is.")
sizeGate = input.float(0.25, "Gap Significance Gate (x ATR)",     minval=0.0, step=0.05, group=gQ, tooltip="Gap height, in ATRs, required for HIGH. Same capping logic as the displacement gate.")

// ───────────  INVERSION FVG  ───────────
gI = "Inversion FVG (IFVG)"
showIFVG = input.bool(true,     "Flip Closed-Through Zones into IFVGs", group=gI, tooltip="When price CLOSES through a displayed FVG, the zone flips polarity: a broken bullish FVG becomes resistance (IFVG ▼), a broken bearish FVG becomes support (IFVG ▲).\nIFVG grade = original grade × 70-100% depending on how hard the breaking candle closed through. IFVGs below the display grade are retired instead of drawn.")
brkMode  = input.string("Displacement Gap", "Break Requirement", options=["Displacement Gap", "Strong Body", "Any Close Through"], group=gI, tooltip="What the candle that closes through an FVG must show before the zone flips into an IFVG. If it doesn't qualify, the zone is simply retired.\nDisplacement Gap (ICT inversion): the breaking candle completes a gap in the opposite direction — it leaves its own FVG behind.\nStrong Body: the breaking candle's body is at least the ATR multiple below.\nAny Close Through: every close-through flips.")
brkMin   = input.float(1.0,     "Strong Body Min (x ATR)", minval=0.1, step=0.1, group=gI, tooltip="Only used by Break Requirement = Strong Body.")
ifvgCol  = input.color(#A35CFF, "IFVG Color", group=gI)

// ───────────  LOOKBACKS  ───────────
gL = "Lookbacks"
atrLen    = input.int(14,       "ATR Length",              minval=1,              group=gL)
volLen    = input.int(20,       "Volume Average Length",   minval=2,              group=gL, tooltip="RVOL = displacement-candle volume / SMA of the volume before it.")
volMode   = input.string("Auto", "Volume",                 options=["Auto", "Ignore"], group=gL, tooltip="Auto: uses RVOL whenever the bar reports volume, and re-weights the other four factors to 100 when it doesn't. Ignore: always re-weight — use on FX tick volume, indices, or any feed you don't trust.")
swingLen  = input.int(3,        "Swing Strength",          minval=1, maxval=20,   group=gL, tooltip="Bars on each side that define a swing high / low. The structure factor asks whether the displacement closed through the most recent intact swing.")
structLen = input.int(20,       "Structure Range Length",  minval=5, maxval=200,  group=gL, tooltip="Displacement that closes beyond this many bars' high/low counts as a range break. Half this length is used to measure pre-move compression.")
ctxLen    = input.int(50,       "Context Range Length",    minval=10, maxval=200, group=gL, tooltip="Window for the context factor: how much prior price traffic sits inside the gap, and where the gap sits in the recent range.")

// ───────────  LIFECYCLE  ───────────
gM = "Lifecycle"
fillBy   = input.string("Close", "Partial Fill Measured By", options=["Close", "Wick"], group=gM, tooltip="Close (default): a zone only turns PARTIAL when a candle CLOSES past its 50% line. A wick that stabs deep and closes back out is a rejection, so the zone stays TESTED.\nWick: any wick past 50% counts as a partial fill.")
mitRule  = input.string("Close Through", "Mitigation Rule",  options=["Close Through", "Full Wick Fill", "Close Beyond CE"], group=gM, tooltip="When a zone is retired.\nClose Through: only a candle CLOSE beyond the far edge (→ INVALIDATED, or IFVG).\nFull Wick Fill: any wick that reaches the far edge (→ MITIGATED).\nClose Beyond CE: a close past the 50% line (→ MITIGATED).\nA close beyond the far edge always invalidates.")
maxZones = input.int(4,      "Max Zones per Side",       minval=1, maxval=25,  group=gM, tooltip="Separate caps for support zones (bullish FVG, IFVG ▲) and resistance zones (bearish FVG, IFVG ▼), so a strong trend on one side can never push the other side off the chart. Oldest zone on the same side is dropped first.")
mergePct = input.int(50,     "Merge Overlap %",          minval=0, maxval=100, group=gM, tooltip="A new zone overlapping an active same-direction FVG by at least this % of the smaller one is merged into it (union of both, best grade kept, lifecycle reset). 0 = never merge.")
showHist = input.bool(false, "Keep Retired Zones",       group=gM, tooltip="Leave mitigated / invalidated zones on the chart, heavily faded and frozen at the bar they were retired.")
histMax  = input.int(4,      "Max Retired Zones",        minval=1, maxval=50,  group=gM)

// ───────────  VISUALS  ───────────
gV = "Visuals"
bullCol    = input.color(#089981, "Bullish",               group=gV)
bearCol    = input.color(#F23645, "Bearish",               group=gV)
lblStyle   = input.string("Pill", "Labels",                options=["Pill", "In-box", "Off"], group=gV, tooltip="Pill: compact tag at the zone's right edge — hover it for the full factor breakdown. In-box: text inside the zone. Off: zones only.")
showState  = input.bool(true,     "Show Lifecycle State",  group=gV)
showFill   = input.bool(true,     "Shade Filled Portion",  group=gV, tooltip="The solid part of a zone shrinks as price fills it; the part already traded through stays as a faint ghost, so you can see how much imbalance is left at a glance.")
showCE     = input.bool(false,    "Show CE (50%) Line",    group=gV)
extendBars = input.int(15,        "Extend Right (bars)",   minval=0, maxval=200, group=gV)
lblSizeIn  = input.string("Tiny", "Label Size",            options=["Tiny", "Small"], group=gV)

// ───────────  ALERTS  ───────────
gA = "Alerts (alert() function calls)"
alNew  = input.bool(true, "New HIGH FVG",          group=gA, tooltip="Alert conditions for every event are always available. These toggles control what the single 'Any alert() function call' alert sends.")
alTest = input.bool(true, "First Test of a Zone",  group=gA)
alIfvg = input.bool(true, "New IFVG",              group=gA)

// ───────────  CONSTANTS  ───────────
W_DISP = 30.0
W_STR  = 25.0
W_VOL  = 15.0
W_SIZE = 15.0
W_CTX  = 15.0

GAP_NOISE    = 0.10   // x ATR — below this a gap is noise and scores zero
GAP_IDEAL_LO = 0.50   // x ATR — full size credit from here…
GAP_IDEAL_HI = 1.50   // x ATR — …to here, then decays (news gaps / thin books)

// grades are shown /10, the engine runs on 0-100
hiScore     = hiTh * 10.0
medScore    = math.min(medTh, hiTh) * 10.0
minShowTier = showMode == "HIGH only" ? 3 : showMode == "HIGH + MEDIUM" ? 2 : 1
lblSize     = lblSizeIn == "Small" ? size.small : size.tiny
cmpLen      = math.max(5, int(structLen / 2))

// ───────────  TYPES  ───────────
type Zone
    box    bx       // unfilled remainder — the solid part
    box    gh       // full original zone — faint ghost behind it
    line   ce
    label  lb
    float  top
    float  bot
    bool   bull     // true = zone acts as support, false = resistance
    bool   inv      // true once flipped into an IFVG
    int    tier     // 3 HIGH · 2 MEDIUM · 1 LOW
    float  score    // 0-100, shown as /10
    int    state    // 0 FRESH · 1 TESTED · 2 PARTIAL · 3 MITIGATED · 4 INVALIDATED
    float  depth    // deepest WICK fill so far, 0..1 of zone height
    float  cdepth   // deepest CLOSE fill so far, 0..1 of zone height
    int    left
    string tip      // factor breakdown shown on hover

// ───────────  HELPERS  ───────────
f_ramp(float x, float lo, float hi) =>
    hi == lo ? (x >= hi ? 1.0 : 0.0) : math.max(0.0, math.min(1.0, (x - lo) / (hi - lo)))

f_tierName(int t) =>
    t == 3 ? "HIGH" : t == 2 ? "MEDIUM" : "LOW"

f_stateName(int s) =>
    s == 0 ? "FRESH" : s == 1 ? "TESTED" : s == 2 ? "PARTIAL" : s == 3 ? "MITIGATED" : "INVALIDATED"

// floor, not round, so a 69.9 never displays as a HIGH-looking 7.0
f_grade(float sc) =>
    str.tostring(math.floor(sc) / 10.0, "0.0")

// 0..1 sub-score → x.x /10
f_sub(float x) =>
    str.tostring(math.round(x * 100.0) / 10.0, "0.0")

f_kind(Zone z) =>
    (z.inv ? "IFVG " : "FVG ") + (z.bull ? "▲" : "▼")

f_label(Zone z) =>
    (z.inv ? "IFVG " + (z.bull ? "▲ " : "▼ ") : "FVG ") + f_grade(z.score) + "/10" + (showState ? " · " + f_stateName(z.state) : "")

f_levels(float bot, float top) =>
    str.tostring(bot, format.mintick) + "–" + str.tostring(top, format.mintick)

// geometry + prominence: fades with every lifecycle step and with lower grades
method restyle(Zone z) =>
    c    = z.inv ? ifvgCol : z.bull ? bullCol : bearCol
    s    = z.state
    h    = z.top - z.bot
    fd   = showFill ? math.min(1.0, math.max(0.0, fillBy == "Wick" ? z.depth : z.cdepth)) : 0.0
    rTop = z.bull ? z.top - fd * h : z.top
    rBot = z.bull ? z.bot : z.bot + fd * h
    gMod = math.min(8, math.max(0, int(math.round((100.0 - z.score) / 8.0))))
    bgT  = math.min(96, (s == 0 ? 78 : s == 1 ? 84 : s == 2 ? 88 : 94) + gMod)
    bdT  = math.min(95, (s == 0 ? 30 : s == 1 ? 50 : s == 2 ? 65 : 85) + gMod)
    pT   = s == 0 ? 10 : s == 1 ? 30 : s == 2 ? 50 : 75
    txt  = f_label(z)
    z.bx.set_top(rTop)
    z.bx.set_bottom(rBot)
    z.bx.set_bgcolor(color.new(c, bgT))
    z.bx.set_border_color(color.new(c, bdT))
    z.bx.set_border_style(s <= 1 ? line.style_solid : s == 2 ? line.style_dashed : line.style_dotted)
    z.gh.set_top(z.top)
    z.gh.set_bottom(z.bot)
    z.gh.set_bgcolor(color.new(c, math.min(97, bgT + 9)))
    z.gh.set_text(lblStyle == "In-box" ? txt : "")
    z.gh.set_text_color(color.new(c, pT))
    if not na(z.lb)
        z.lb.set_y((rTop + rBot) / 2)
        z.lb.set_text(txt)
        z.lb.set_color(color.new(c, pT))
        z.lb.set_textcolor(color.new(color.white, pT))
        z.lb.set_tooltip(z.tip)
    if not na(z.ce)
        mid = (z.top + z.bot) / 2
        z.ce.set_y1(mid)
        z.ce.set_y2(mid)
        z.ce.set_color(color.new(c, math.min(95, bdT + 10)))

method setRight(Zone z, int x) =>
    z.bx.set_right(x)
    z.gh.set_right(x)
    if not na(z.ce)
        z.ce.set_x2(x)
    if not na(z.lb)
        z.lb.set_x(x)

method kill(Zone z) =>
    z.bx.delete()
    z.gh.delete()
    if not na(z.ce)
        z.ce.delete()
    if not na(z.lb)
        z.lb.delete()

f_newZone(float top, float bot, bool bull, int tier, float score, int left, string tip) =>
    rx = bar_index + extendBars
    g  = box.new(left=left, top=top, right=rx, bottom=bot, border_color=color(na), border_width=1, xloc=xloc.bar_index, text_size=lblSize, text_halign=text.align_right, text_valign=text.align_center)
    b  = box.new(left=left, top=top, right=rx, bottom=bot, border_width=1, xloc=xloc.bar_index)
    line l = na
    if showCE
        l := line.new(left, (top + bot) / 2, rx, (top + bot) / 2, style=line.style_dotted, width=1)
    label lb = na
    if lblStyle == "Pill"
        lb := label.new(x=rx, y=(top + bot) / 2, text="", xloc=xloc.bar_index, style=label.style_label_left, size=lblSize)
    z = Zone.new(b, g, l, lb, top, bot, bull, false, tier, score, 0, 0.0, 0.0, left, tip)
    z.restyle()
    z

// drops the oldest zone on one side (support / resistance) once that side is over its cap
f_capSide(array<Zone> zs, bool side) =>
    cnt = 0
    for z in zs
        if z.bull == side
            cnt += 1
    if cnt > maxZones
        for i = 0 to zs.size() - 1
            if zs.get(i).bull == side
                zs.remove(i).kill()
                break

// ───────────  STATE  ───────────
var array<Zone> zones = array.new<Zone>()   // active FVGs + IFVGs, ordered oldest → newest
var array<Zone> hist  = array.new<Zone>()   // retired, only when Keep Retired Zones is on

// ───────────  SERIES — computed on every bar so history is always consistent  ───────────
atrV   = ta.atr(atrLen)
volAvg = ta.sma(volume, volLen)
ph     = ta.pivothigh(high, swingLen, swingLen)
pl     = ta.pivotlow(low, swingLen, swingLen)
strHi  = ta.highest(high, structLen)
strLo  = ta.lowest(low, structLen)
cmpHi  = ta.highest(high, cmpLen)
cmpLo  = ta.lowest(low, cmpLen)
ctxHi  = ta.highest(high, ctxLen)
ctxLo  = ta.lowest(low, ctxLen)

// ───────────  INTERNAL STRUCTURE — swing state, never drawn  ───────────
var float swHi       = na
var float swLo       = na
var bool  swHiIntact = false
var bool  swLoIntact = false
var int   hiBreakBar = -1
var int   loBreakBar = -1
var int   brkDir     = 0

if not na(ph)
    swHi       := ph
    swHiIntact := true
if not na(pl)
    swLo       := pl
    swLoIntact := true
if swHiIntact and close > swHi
    swHiIntact := false
    hiBreakBar := bar_index
    brkDir     := 1
if swLoIntact and close < swLo
    swLoIntact := false
    loBreakBar := bar_index
    brkDir     := -1

// ───────────  FVG DETECTION  ───────────
// candle 1 = [2] · candle 2 (displacement) = [1] · candle 3 = [0]
bullGap = low > high[2]
bearGap = high < low[2]
dir     = bullGap ? 1 : bearGap ? -1 : 0

// ATR as it stood before the displacement candle, so a violent candle can't inflate its own yardstick
atrRef = nz(atrV[2], atrV)
gTop   = dir == 1 ? low : low[2]
gBot   = dir == 1 ? high[2] : high
gapAtr = dir != 0 and atrRef > 0 ? (gTop - gBot) / atrRef : 0.0

// ───────────  FACTOR 1 · DISPLACEMENT (30)  ───────────
dRange    = high[1] - low[1]
dBody     = math.max((close[1] - open[1]) * dir, 0.0)   // counter-direction candle = zero body
dBodyAtr  = atrRef > 0 ? dBody / atrRef : 0.0
dRatio    = dRange > 0 ? dBody / dRange : 0.0
dCloseLoc = dRange > 0 ? (dir == 1 ? close[1] - low[1] : high[1] - close[1]) / dRange : 0.0
dLegAtr   = atrRef > 0 ? math.max((close - open[2]) * dir, 0.0) / atrRef : 0.0
scDisp    = 0.40 * f_ramp(dBodyAtr, 0.5, 2.0) + 0.25 * f_ramp(dRatio, 0.40, 0.85) + 0.15 * f_ramp(dCloseLoc, 0.50, 0.90) + 0.20 * f_ramp(dLegAtr, 1.0, 3.0)

// ───────────  FACTOR 2 · STRUCTURE (25)  ───────────
swingBrk = dir == 1 ? hiBreakBar >= bar_index - 1 : dir == -1 ? loBreakBar >= bar_index - 1 : false
rangeBrk = dir == 1 ? close > strHi[2] : dir == -1 ? close < strLo[2] : false
cmpWidth = atrRef > 0 ? (cmpHi[2] - cmpLo[2]) / atrRef : 99.0
cmpScore = 1.0 - f_ramp(cmpWidth, 2.5, 6.0)
aligned  = dir != 0 and brkDir[2] == dir
scStr    = swingBrk or rangeBrk ? math.min(1.0, (swingBrk ? 0.55 : 0.0) + (rangeBrk ? 0.25 : 0.0) + 0.20 * cmpScore) : aligned ? 0.35 : 0.0

// ───────────  FACTOR 3 · RELATIVE VOLUME (15)  ───────────
volBase = volAvg[2]
volOk   = volMode == "Auto" and volume[1] > 0 and volBase > 0
rvol    = volOk ? volume[1] / volBase : 0.0
scVol   = f_ramp(rvol, 0.8, 2.2)

// ───────────  FACTOR 4 · GAP SIZE (15)  ───────────
scSize = gapAtr < GAP_NOISE ? 0.0 : gapAtr < GAP_IDEAL_LO ? f_ramp(gapAtr, GAP_NOISE, GAP_IDEAL_LO) : gapAtr <= GAP_IDEAL_HI ? 1.0 : math.max(0.40, 1.0 - 0.60 * f_ramp(gapAtr, GAP_IDEAL_HI, GAP_IDEAL_HI * 2))

// ───────────  FACTOR 5 · CONTEXT (15)  ───────────
scCtx = 0.0
if dir != 0
    n            = math.min(ctxLen, bar_index - 3)
    float hits   = 0.0
    if n > 0
        for i = 3 to n + 2
            if high[i] >= gBot and low[i] <= gTop
                hits += 1.0
    traffic = n > 0 ? hits / n : 0.0
    fresh   = 1.0 - f_ramp(traffic, 0.05, 0.40)          // untraded territory vs congestion
    rHi     = ctxHi[2]
    rLo     = ctxLo[2]
    pos     = rHi > rLo ? ((gTop + gBot) / 2 - rLo) / (rHi - rLo) : 0.5
    edge    = math.min(1.0, math.abs(pos - 0.5) * 2)      // 0 = dead middle of the range, 1 = range edge or beyond
    scCtx  := 0.55 * fresh + 0.45 * edge

// ───────────  QUALITY ENGINE  ───────────
core     = (W_DISP * scDisp + W_STR * scStr + W_SIZE * scSize + W_CTX * scCtx) / (W_DISP + W_STR + W_SIZE + W_CTX)
volEff   = scVol * f_ramp(core, 0.0, 0.60)                // volume only pays out in full on an already-solid FVG
score    = volOk ? W_DISP * scDisp + W_STR * scStr + W_VOL * volEff + W_SIZE * scSize + W_CTX * scCtx : 100.0 * core
passDisp = scDisp * 10.0 >= dispGate
passSize = gapAtr >= sizeGate
rawTier  = score >= hiScore ? 3 : score >= medScore ? 2 : 1
tier     = not passDisp and not passSize ? 1 : not passDisp or not passSize ? math.min(rawTier, 2) : rawTier

// ───────────  LIFECYCLE + DRAWING — confirmed bars only  ───────────
aNewBull  = false
aNewBear  = false
aTestBull = false
aTestBear = false
aNewIfvg  = false
aTestIfvg = false
alertTxt  = ""

if barstate.isconfirmed
    // 1 · advance existing zones first, so a zone never "tests" on the bar that created it
    if zones.size() > 0
        for i = zones.size() - 1 to 0
            z    = zones.get(i)
            h    = z.top - z.bot
            oldF = fillBy == "Wick" ? z.depth : z.cdepth
            wPen = h > 0 ? (z.bull ? z.top - low : high - z.bot) / h : 0.0
            cPen = h > 0 ? (z.bull ? z.top - close : close - z.bot) / h : 0.0
            z.depth  := math.max(z.depth, math.min(wPen, 1.0))
            z.cdepth := math.max(z.cdepth, math.min(cPen, 1.0))
            fillD = fillBy == "Wick" ? z.depth : z.cdepth
            prev  = z.state
            ns    = prev
            if z.depth > 0 and ns == 0
                ns := 1
            if fillD >= 0.5 and ns < 2
                ns := 2
            ceLvl = (z.top + z.bot) / 2
            if z.bull ? close < z.bot : close > z.top
                ns := 4
            else if mitRule == "Full Wick Fill" and z.depth >= 1.0
                ns := 3
            else if mitRule == "Close Beyond CE" and (z.bull ? close < ceLvl : close > ceLvl)
                ns := 3
            if prev == 0 and ns >= 1
                if z.inv
                    aTestIfvg := true
                else if z.bull
                    aTestBull := true
                else
                    aTestBear := true
                if alTest
                    alertTxt += "ApexFlow • first test • " + f_kind(z) + " " + f_grade(z.score) + "/10 • " + f_levels(z.bot, z.top) + " → " + f_stateName(ns) + "\n"
            if ns != prev or fillD != oldF
                z.state := ns
                flipped = false
                // closed through an FVG → try to flip it into an IFVG
                if ns == 4 and showIFVG and not z.inv
                    brkBody = atrV > 0 ? math.max((close - open) * (z.bull ? -1 : 1), 0.0) / atrV : 0.0
                    brkOk   = brkMode == "Any Close Through" or (brkMode == "Strong Body" and brkBody >= brkMin) or (brkMode == "Displacement Gap" and dir == (z.bull ? -1 : 1))
                    nScore  = z.score * (0.70 + 0.30 * f_ramp(brkBody, 0.3, 1.5))
                    nTier   = math.min(z.tier, nScore >= hiScore ? 3 : nScore >= medScore ? 2 : 1)
                    if brkOk and nTier >= minShowTier
                        z.tip    := "IFVG " + f_grade(nScore) + "/10 — FVG " + f_grade(z.score) + " × break strength (" + str.tostring(brkBody, "0.0") + " ATR body)\n\n" + z.tip
                        z.inv    := true
                        z.bull   := not z.bull
                        z.score  := nScore
                        z.tier   := nTier
                        z.state  := 0
                        z.depth  := 0.0
                        z.cdepth := 0.0
                        // an IFVG only exists from the breaking candle onward
                        z.left   := bar_index
                        z.bx.set_left(bar_index)
                        z.gh.set_left(bar_index)
                        if not na(z.ce)
                            z.ce.set_x1(bar_index)
                        z.restyle()
                        zones.remove(i)
                        zones.push(z)                 // IFVG counts as the newest zone
                        flipped  := true
                        aNewIfvg := true
                        if alIfvg
                            alertTxt += "ApexFlow • new " + f_kind(z) + " • grade " + f_grade(nScore) + "/10 • " + f_levels(z.bot, z.top) + "\n"
                if not flipped
                    z.restyle()
                    if ns >= 3
                        zones.remove(i)
                        if showHist
                            z.setRight(bar_index)
                            hist.push(z)
                            if hist.size() > histMax
                                hist.shift().kill()
                        else
                            z.kill()

    // 2 · new FVG — only the grades that survive the filter are ever stored
    if dir != 0 and tier >= minShowTier
        isBull = dir == 1
        tipTxt = "FVG " + f_grade(score) + "/10  (" + f_tierName(tier) + ")\nDisplacement  " + f_sub(scDisp) + "\nStructure  " + f_sub(scStr) + "\nRVOL  " + (volOk ? f_sub(volEff) + "  (" + str.tostring(rvol, "0.0") + "x)" : "n/a — re-weighted") + "\nGap size  " + f_sub(scSize) + "  (" + str.tostring(gapAtr, "0.00") + " ATR)\nContext  " + f_sub(scCtx) + (passDisp and passSize ? "" : "\nCapped by " + (passDisp ? "size" : "displacement") + " gate")
        merged = false
        if mergePct > 0 and zones.size() > 0
            for i = zones.size() - 1 to 0
                z = zones.get(i)
                if z.bull == isBull and not z.inv
                    ov    = math.min(z.top, gTop) - math.max(z.bot, gBot)
                    small = math.min(z.top - z.bot, gTop - gBot)
                    if small > 0 and ov / small * 100.0 >= mergePct
                        if score > z.score
                            z.tip := tipTxt
                        z.top    := math.max(z.top, gTop)
                        z.bot    := math.min(z.bot, gBot)
                        z.tier   := math.max(z.tier, tier)
                        z.score  := math.max(z.score, score)
                        z.state  := 0
                        z.depth  := 0.0
                        z.cdepth := 0.0
                        z.restyle()
                        zones.remove(i)
                        zones.push(z)                 // merged zone becomes the newest
                        merged := true
                        break
        if not merged
            zones.push(f_newZone(gTop, gBot, isBull, tier, score, bar_index - 1, tipTxt))
        if tier == 3
            if isBull
                aNewBull := true
            else
                aNewBear := true
            if alNew
                alertTxt += "ApexFlow • new HIGH FVG " + (isBull ? "▲" : "▼") + " • grade " + f_grade(score) + "/10 • " + f_levels(gBot, gTop) + "\n"

    // 3 · enforce per-side caps after all inserts / flips (never mid-loop, so no index shifting)
    f_capSide(zones, true)
    f_capSide(zones, false)

// keep active zones pinned a few bars ahead of price — only needs doing on the live edge
if barstate.islast and zones.size() > 0
    for z in zones
        z.setRight(bar_index + extendBars)

// ───────────  ALERTS  ───────────
alertcondition(aNewBull,  "New HIGH Bullish FVG",   "ApexFlow: new HIGH-grade bullish FVG on {{ticker}} {{interval}}")
alertcondition(aNewBear,  "New HIGH Bearish FVG",   "ApexFlow: new HIGH-grade bearish FVG on {{ticker}} {{interval}}")
alertcondition(aTestBull, "First Test Bullish FVG", "ApexFlow: bullish FVG tested for the first time on {{ticker}} {{interval}}")
alertcondition(aTestBear, "First Test Bearish FVG", "ApexFlow: bearish FVG tested for the first time on {{ticker}} {{interval}}")
alertcondition(aNewIfvg,  "New IFVG",               "ApexFlow: FVG closed through and flipped into an IFVG on {{ticker}} {{interval}}")
alertcondition(aTestIfvg, "First Test IFVG",        "ApexFlow: IFVG tested for the first time on {{ticker}} {{interval}}")
if alertTxt != ""
    alert(syminfo.ticker + " " + timeframe.period + "\n" + alertTxt, alert.freq_once_per_bar_close)
````
