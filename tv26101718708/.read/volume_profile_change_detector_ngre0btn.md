# Volume Profile Change Detector

- url: https://www.tradingview.com/script/ngRe0btN-Volume-Profile-Change-Detector/
- type: indicator
- pine_id: PUB;8c147c541e9049858ff54e569fa35310
- version: 6.0

## Description

📊 Volume Profile Change Detector — "New Cluster"

Detects sudden volume concentration at a specific price level — the footprint of a large player actively building a position. TradingView has Volume Profile built in, but no automatic alert when a new cluster emerges. This indicator fills that gap.

---
🧠 WHY IT WORKS
---

Institutional accumulation isn't random. A large player buying over several days will concentrate volume at specific price levels — either because that's their target entry zone, or because they're absorbing supply at a particular level. The short-term volume profile will look dramatically different from the longer-term baseline. That divergence is the signal.

---
📐 THE FORMULA
---

**Cluster Score = (5-day bin share) ÷ (20-day bin share)**

Score 1.0 = this level is proportional to history — nothing new.
Score 3.0 = 3× more concentrated than the 20-day baseline.
Score 5.0+ = institutional fingerprint. Someone decided this price level matters.

---
🚦 SIGNALS
---

📊 CLUSTER ↑ — new cluster while price is rising (accumulation into a move, or breakout building)
📊 CLUSTER ↓ — new cluster while price is falling (potential support being built, or distribution)

Two intensity levels: moderate and strong.

---
⚡ WHAT MAKES THIS UNIQUE
---

High volume ≠ high Cluster Score. A panic selloff can produce 10× normal daily volume and generate a Score of 2.3 — because panic is dispersed across many levels. Deliberate accumulation on a normal-volume day at one specific level can generate a Score of 8+. The indicator doesn't scream during panic. It whispers during accumulation.

---
⚙️ RECOMMENDED SETTINGS
---

WIG20 / large caps: short 5, long 20, bins 30, moderate 2.5, strong 5.0
mWIG40 / sWIG80 (default): short 5, long 20, bins 20, moderate 3.5, strong 7.0
Small caps / NewConnect: long 30, bins 15, moderate 5.0, strong 10.0

---
🎯 WHAT TO LOOK FOR
---

CLUSTER ↓ while price falls + low drift = someone buying from panicking sellers at one specific level. Classic institutional accumulation footprint.
Score > 7 (sWIG80) with 5d share > 30% = very high conviction, not noise.
No signal on panic volume = useful negative: selloff is disorganized retail, not institutional.
CLUSTER ↑ at breakout = institution adding into a move. Continuation signal.
Repeated cluster at the same price level across multiple weeks = strong support being built.

---
💡 PRO TIPS
---

Combine with VW Drift (Silent Accumulator) — a cluster + ACCUM signal means both the profile and the price behavior confirm accumulation. Strongest dual confirmation in the toolkit.
Use after a large-volume panic day to check if the selloff was organized or random — Score < 2 on a 10× volume day = retail panic, no institutional footprint.
Default thresholds are calibrated for sWIG80. Raise them for NewConnect (more noise) and lower them for WIG20 (institutional activity at lower relative concentration).

---

Open source. Part of the Smart Money Hunter / GPW Anomaly Detection toolkit.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © fis_wse
//
// Volume Profile Change Detector — "Nowy klaster"
// Detects when volume is suddenly concentrating at a specific price level
// far more than the historical baseline — the fingerprint of a large player
// systematically building (or unwinding) a position at that level.
//
// Cluster Score = (5-day bin share) / (20-day bin share)
// Score 1.0 = proportional to history. Score 3.0 = 3x more concentrated. Score 5.0+ = institutional.
//
// Use on Daily or 1h charts. Designed for GPW (Warsaw Stock Exchange).
// Best combined with VW Drift and Fixing Volume indicators.
//
// v1.1 — dodano przełącznik "Only show STRONG signals":
//   Ukrywa cały tier MODERATE (labele + tło), zostawia tylko STRONG.
//   W HTF Summary Mode nadpisuje "Min severity to highlight" na STRONG.
//
// v1.2 — tło skaluje się siłą sygnału:
//   Zamiast stałej przezroczystości, im wyższy score, tym ciemniejsze tło
//   (gradient od progu Moderate do "Background darkness cap"). Czytelne
//   bez labelek, szczególnie na małym ekranie.
//
// v1.3 — mocniejszy kontrast tła:
//   Domyślna ciemność podniesiona (45→25 transparency), dodano "Background
//   contrast boost" — mnoży tempo dochodzenia do pełnej ciemności, żeby
//   różnica moderate/strong była widoczna na pierwszy rzut oka.
//
// v1.4 — poprawka defaultów różnicowania:
//   "Contrast boost" domyślnie 2.0 obcinał ratio zbyt wcześnie — wszystko
//   powyżej pewnego score wyglądało identycznie (max dark), zero różnicy
//   między score=7 a score=20. Nowe defaulty: cap 2.0→5.0 (max 10.0),
//   contrast 2.0→1.0 (czysty liniowy gradient, bez przedwczesnego obcinania).
//@version=6
indicator("Volume Profile Change Detector", shorttitle="VP Cluster", overlay=false, precision=2, max_labels_count=500)
// ─────────────────────────────────────────
// ⚙️  SETTINGS
// ─────────────────────────────────────────
// --- Market Preset ---
g_preset = "📋 Market Preset"
presetStr = input.string("Mid Cap (mWIG40 / sWIG80)", "Market preset",
     options=["Large Cap (WIG20)", "Mid Cap (mWIG40 / sWIG80)", "Small Cap (NewConnect)", "NASDAQ Large Cap", "— Custom —"],
     group=g_preset,
     tooltip="Auto-configures bins, cluster score thresholds and min share. Select '— Custom —' to set manually.")
// --- Core parameters ---
g_core = "Core Parameters"
shortLen    = input.int(5,  "Short lookback (bars)",  minval=2,  maxval=50,  group=g_core,
     tooltip="Recent window to compare against history. Default 5 = last 5 bars (5 days on daily chart, ~1 session on 1h).")
longLen     = input.int(20, "Long lookback (bars)",   minval=5,  maxval=200, group=g_core,
     tooltip="Historical baseline window. Default 20 = last 4 weeks on daily chart, ~2.5 sessions on 1h.")
nBins       = input.int(20, "Number of price bins (Custom only)",   minval=5,  maxval=50,  group=g_core,
     tooltip="How many equal-width price buckets to divide the range into. More bins = more precise but noisier. 15-30 is typical.")
// --- Thresholds ---
g_thresh = "Thresholds"
scoreMed     = input.float(3.5, "Cluster score — moderate signal (Custom only)", minval=1.0, maxval=20.0, step=0.5, group=g_thresh,
     tooltip="Score above this = moderate cluster. 3.5x more concentrated than 20-day baseline. WIG20: try 2.5 | mWIG40/sWIG80: 3.5 | NewConnect: 5.0")
scoreHigh    = input.float(7.0, "Cluster score — strong signal (Custom only)",   minval=1.5, maxval=50.0, step=0.5, group=g_thresh,
     tooltip="Score above this = strong cluster. WIG20: try 5.0 | mWIG40/sWIG80: 7.0 | NewConnect: 10.0")
minVolSharePct = input.float(5.0, "Min 5d vol share at level (%) (Custom only)", minval=0.5, maxval=30.0, step=0.5, group=g_thresh,
     tooltip="Signal fires only when the current price bin holds at least this % of recent 5-day volume. WIG20: 3% | mWIG40/sWIG80: 5% | NewConnect: 8%")
// --- Direction filter ---
g_dir = "Direction Filter"
showUp   = input.bool(true, "Show KLASTER ↑ (cluster while price rising)",  group=g_dir,
     tooltip="Cluster forming during a price upswing — may indicate accumulation in trend or distribution at top.")
showDown = input.bool(true, "Show KLASTER ↓ (cluster while price falling)", group=g_dir,
     tooltip="Cluster forming during a price downswing — may indicate support being built or a falling knife being caught.")
// --- Signal strength filter ---
g_strength = "Signal Strength Filter"
onlyStrongSignals = input.bool(false, "Only show STRONG signals", group=g_strength,
     tooltip="Hides the MODERATE tier entirely — labels and background shading only render for STRONG clusters (score ≥ 'Strong' threshold). In HTF Summary Mode this also forces the highlight to STRONG only, overriding 'Min severity to highlight' in the HTF group below. Use this to cut chart noise down to the clusters that actually matter.")
// --- Visual settings ---
g_vis = "Visual Settings"
colStrongUp   = input.color(color.new(#00C853, 0),   "Strong cluster ↑",   group=g_vis)
colMedUp      = input.color(color.new(#69F0AE, 0),   "Moderate cluster ↑", group=g_vis)
colStrongDown = input.color(color.new(#FF1744, 0),   "Strong cluster ↓",   group=g_vis)
colMedDown    = input.color(color.new(#FF8A80, 0),   "Moderate cluster ↓", group=g_vis)
colNeutral    = input.color(color.new(#9E9E9E, 60),  "Neutral / no signal", group=g_vis)
colShare      = input.color(color.new(#42A5F5, 40),  "5d vol share line",   group=g_vis)
showLabels    = input.bool(true,  "Show alert labels",       group=g_vis)
showBg        = input.bool(true,  "Show background shading", group=g_vis)
bgTransp      = input.int(85,     "Background transparency — at Moderate threshold (lightest)", minval=50, maxval=98, group=g_vis,
     tooltip="Transparency used right when a signal first crosses the Moderate threshold. Higher = more transparent/lighter. Also the fixed transparency used for all signals when 'Scale background darkness with score' below is off.")
bgDarkScale   = input.bool(true,  "Scale background darkness with score", group=g_vis,
     tooltip="On: background darkens smoothly as the score rises (see the two settings below). Off: background uses a single fixed transparency (the setting above) for every signal, like before v1.2.")
bgTranspDark  = input.int(25,     "Background transparency — at darkness cap (darkest)", minval=5, maxval=90, group=g_vis,
     tooltip="Transparency used once the score reaches the darkness cap below. Lower = more opaque/darker. Must be less than the value above for the fade-to-dark gradient to work. Ignored when 'Scale background darkness with score' is off.")
bgDarkCapMult = input.float(5.0,  "Background darkness cap (x Strong threshold)", minval=1.0, maxval=10.0, step=0.25, group=g_vis,
     tooltip="Score value, expressed as a multiple of the Strong threshold, at which the background reaches maximum darkness. E.g. 5.0 with Strong=7.0 → score 35.0+ renders fully dark, and scores in between fan out into visibly different shades instead of clustering at max. This is the main knob for differentiation — if signals still look too similar, raise this further before touching the contrast boost below. Ignored when 'Scale background darkness with score' is off.")
bgContrast    = input.float(1.0,  "Background contrast boost", minval=1.0, maxval=5.0, step=0.25, group=g_vis,
     tooltip="1.0 = plain linear gradient across the full range — recommended, gives the most distinguishable shades. Raising this makes the background hit max darkness at a LOWER score, which creates a sharper two-tone look but means more signals collapse into the same 'fully dark' shade, losing fine differentiation. Use this only if you want a stark on/off cue rather than a graduated one; otherwise widen 'Background darkness cap' above instead. Ignored when 'Scale background darkness with score' is off.")
// --- HTF Summary Mode ---
g_htf = "HTF Summary Mode"
htfModeStr  = input.string("Auto", "HTF summary mode", options=["Auto", "Always ON", "Always OFF"], group=g_htf,
     tooltip="Auto: on chart TF ≤ scan TF = full detail mode. On higher TF = summary highlight per bar. Switch charts — it adapts automatically.")
htfScanTF   = input.timeframe("D", "Lower TF to scan", group=g_htf,
     tooltip="Timeframe to scan for clusters when viewing a higher TF. 'D' = scan daily bars when viewing weekly.")
htfMinSev   = input.string("Strong", "Min severity to highlight", options=["Moderate", "Strong"], group=g_htf)
colHtfMod   = input.color(color.new(#69F0AE, 70), "HTF — Moderate", group=g_htf)
colHtfStr   = input.color(color.new(#00C853, 55), "HTF — Strong",   group=g_htf)
// --- Date range ---
g_date = "Date Range Filter"
useDateRange = input.bool(false,                     "Enable date range", group=g_date)
dateFrom     = input.time(timestamp("2025-01-01"),   "From",              group=g_date)
dateTo       = input.time(timestamp("2026-12-31"),   "To",                group=g_date)
// 🎛️  PRESET RESOLVED VALUES
// ─────────────────────────────────────────

_pL = presetStr == "Large Cap (WIG20)"
_pM = presetStr == "Mid Cap (mWIG40 / sWIG80)"
_pS = presetStr == "Small Cap (NewConnect)"
_pN = presetStr == "NASDAQ Large Cap"
_pC = presetStr == "— Custom —"
_nBins = _pC ? nBins : _pL ? 30 : _pM ? 20 : _pS ? 15 : _pN ? 40 : nBins
_scoreMed = _pC ? scoreMed : _pL ? 2.5 : _pM ? 3.5 : _pS ? 5.0 : _pN ? 4.0 : scoreMed
_scoreHigh = _pC ? scoreHigh : _pL ? 5.0 : _pM ? 7.0 : _pS ? 10.0 : _pN ? 8.0 : scoreHigh
_minVolSharePct = _pC ? minVolSharePct : _pL ? 3.0 : _pM ? 5.0 : _pS ? 8.0 : _pN ? 2.0 : minVolSharePct
// ─────────────────────────────────────────
// 📐  HTF AUTO DETECTION
// ─────────────────────────────────────────
chartTFsec = timeframe.in_seconds()
scanTFsec  = timeframe.in_seconds(htfScanTF)
htfMode    = htfModeStr == "Always ON"  ? true  :
             htfModeStr == "Always OFF" ? false :
             chartTFsec > scanTFsec
// ─────────────────────────────────────────
// 📐  CALCULATIONS
// ─────────────────────────────────────────
inDateRange = useDateRange ? (time >= dateFrom and time <= dateTo) : true
// ── Price range for binning (based on long lookback) ──
float priceMin   = ta.lowest(low,   longLen)
float priceMax   = ta.highest(high, longLen)
float priceRange = priceMax - priceMin
bool  validRange = priceRange > 0.0
float binSize    = validRange ? priceRange / _nBins : 1.0
// ── Current price bin ──
int currentBin = validRange ?
     math.min(math.max(int(math.floor((close - priceMin) / binSize)), 0), _nBins - 1) : 0
// ── Build volume profiles ──
// For each bar in longLen, assign volume to the bin matching its close.
// Track total volume and volume at currentBin for both windows.
float shortBinVol   = 0.0
float longBinVol    = 0.0
float totalShortVol = 0.0
float totalLongVol  = 0.0
for i = 0 to longLen - 1
    float c   = nz(close[i])
    float v   = nz(volume[i])
    int   bin = validRange ?
         math.min(math.max(int(math.floor((c - priceMin) / binSize)), 0), _nBins - 1) : 0
    // Long window — all bars
    totalLongVol += v
    if bin == currentBin
        longBinVol += v
    // Short window — first shortLen bars only
    if i < shortLen
        totalShortVol += v
        if bin == currentBin
            shortBinVol += v
// ── Shares (fraction of total window volume at current bin) ──
float epsilon    = 0.001
float shortShare = totalShortVol > 0.0 ? shortBinVol / totalShortVol : 0.0
float longShare  = totalLongVol  > 0.0 ? longBinVol  / totalLongVol  : 0.0
// ── Cluster Score ──
// How much more concentrated is the recent period vs the historical baseline?
float clusterScore = shortShare / (longShare + epsilon)
// ── Short-term price direction ──
float shortDrift = shortLen > 0 and close[shortLen] != 0 ?
     ((close - close[shortLen]) / close[shortLen]) * 100 : 0.0
bool priceUp   = shortDrift > 0
bool priceDown = shortDrift < 0
// ─────────────────────────────────────────
// 🚦  SIGNAL CONDITIONS
// ─────────────────────────────────────────
float shortSharePct = shortShare * 100.0
bool passBase    = validRange and inDateRange and shortSharePct >= _minVolSharePct
bool isModerate  = passBase and clusterScore >= _scoreMed
bool isStrong    = passBase and clusterScore >= _scoreHigh
bool sigUp       = isModerate and priceUp   and showUp
bool sigDown     = isModerate and priceDown and showDown
bool anySignal   = sigUp or sigDown
// ─────────────────────────────────────────
// 🎨  PLOTTING
// ─────────────────────────────────────────
var color scoreColor = colNeutral
if sigUp and isStrong
    scoreColor := colStrongUp
else if sigUp
    scoreColor := colMedUp
else if sigDown and isStrong
    scoreColor := colStrongDown
else if sigDown
    scoreColor := colMedDown
else
    scoreColor := colNeutral
// Cluster score line
plot(not htfMode ? clusterScore : na,    "Cluster Score",         color=scoreColor, linewidth=2)
// 5-day volume share at current level (secondary reference)
plot(not htfMode ? shortSharePct : na,   "5d share % at level",   color=colShare,   linewidth=1, style=plot.style_stepline)
// Threshold lines
plot(_scoreHigh, "Strong threshold",    color=color.new(#FF5252, 55), linewidth=1, style=plot.style_line)
plot(_scoreMed,  "Moderate threshold",  color=color.new(#FFB74D, 55), linewidth=1, style=plot.style_line)
hline(1.0,       "Baseline (1.0)",      color=color.new(#FFFFFF, 70), linestyle=hline.style_solid)
// ── Background shading — darkness scales with score (higher score = darker/more opaque) ──
f_bgTransp(float score) =>
    int result = bgTransp
    if bgDarkScale
        float lo      = _scoreMed
        float hi      = _scoreHigh * bgDarkCapMult
        float ratio   = hi > lo ? math.min(math.max((score - lo) / (hi - lo), 0.0), 1.0) : 0.0
        float ratioBst = math.min(ratio * bgContrast, 1.0)
        result := int(bgTransp - ratioBst * (bgTransp - bgTranspDark))
    result

var color bgCol = na
if showBg and not htfMode
    if sigUp and isStrong
        bgCol := color.new(colStrongUp,   f_bgTransp(clusterScore))
    else if sigUp and not onlyStrongSignals
        bgCol := color.new(colMedUp,      f_bgTransp(clusterScore))
    else if sigDown and isStrong
        bgCol := color.new(colStrongDown, f_bgTransp(clusterScore))
    else if sigDown and not onlyStrongSignals
        bgCol := color.new(colMedDown,    f_bgTransp(clusterScore))
    else
        bgCol := na
else
    bgCol := na
bgcolor(bgCol)
// ─────────────────────────────────────────
// 🔭  HTF SCAN
// ─────────────────────────────────────────
// Encode severity as int for lower-TF scanning
int severityCode = isStrong ? 2 : isModerate ? 1 : 0
bool _htfValid  = timeframe.in_seconds(htfScanTF) < timeframe.in_seconds()
string _safeTF  = _htfValid ? htfScanTF : "1"
int[] htfSevArr = request.security_lower_tf(syminfo.tickerid, _safeTF, severityCode)
var int htfSev = 0
htfSev := 0
if htfMode and _htfValid and array.size(htfSevArr) > 0
    for i = 0 to array.size(htfSevArr) - 1
        v = array.get(htfSevArr, i)
        if v > htfSev
            htfSev := v
int  minHtfSev = onlyStrongSignals ? 2 : (htfMinSev == "Strong" ? 2 : 1)
bool htfHit    = htfMode and htfSev >= minHtfSev
var color htfBgCol = na
if htfMode and htfHit
    htfBgCol := htfSev >= 2 ? colHtfStr : colHtfMod
else
    htfBgCol := na
bgcolor(htfMode ? htfBgCol : na)
// ─────────────────────────────────────────
// 🏷️  LABELS
// ─────────────────────────────────────────
if not htfMode and showLabels
    bool wasSignal       = anySignal[1]
    bool isNewSignal     = anySignal and not wasSignal
    bool upgradedStrong  = anySignal and isStrong and not isStrong[1]
    bool passStrength    = not onlyStrongSignals or isStrong
    if (isNewSignal or upgradedStrong) and passStrength
        string dir      = priceUp ? "↑" : "↓"
        string strength = isStrong ? "🔴" : "🟡"
        string txt = strength + " KLASTER " + dir +
             "\nScore: "    + str.tostring(clusterScore,  "#.##") +
             "\n5d share: " + str.tostring(shortSharePct, "#.##") + "%" +
             "\n20d share: " + str.tostring(longShare * 100, "#.##") + "%" +
             "\nDrift: "    + str.tostring(shortDrift,    "#.##") + "%"
        color lblCol = priceUp ?
             (isStrong ? colStrongUp   : colMedUp) :
             (isStrong ? colStrongDown : colMedDown)
        label.new(bar_index, clusterScore, txt,
             style     = priceUp ? label.style_label_up : label.style_label_down,
             color     = lblCol,
             textcolor = color.white,
             size      = size.small)
// HTF label
if htfMode and showLabels and htfHit
    string htfSevTxt = htfSev >= 2 ? "🔴 STRONG" : "🟡 MOD"
    color  htfLblCol = htfSev >= 2 ? colHtfStr : colHtfMod
    label.new(bar_index, 1.0, htfSevTxt + "\ncluster",
         style     = label.style_label_up,
         color     = htfLblCol,
         textcolor = color.white,
         size      = size.tiny)
// ─────────────────────────────────────────
// 🔔  ALERTS
// ─────────────────────────────────────────
alertcondition(sigUp and isStrong,
     title   = "Strong Cluster ↑",
     message = "🔴 STRONG KLASTER ↑ — Score: {{clusterScore}}, 5d share: {{shortSharePct}}%, drift: {{shortDrift}}%")
alertcondition(sigUp and isModerate and not isStrong,
     title   = "Moderate Cluster ↑",
     message = "🟡 MODERATE KLASTER ↑ — Score: {{clusterScore}}, 5d share: {{shortSharePct}}%")
alertcondition(sigDown and isStrong,
     title   = "Strong Cluster ↓",
     message = "🔴 STRONG KLASTER ↓ — Score: {{clusterScore}}, 5d share: {{shortSharePct}}%, drift: {{shortDrift}}%")
alertcondition(sigDown and isModerate and not isStrong,
     title   = "Moderate Cluster ↓",
     message = "🟡 MODERATE KLASTER ↓ — Score: {{clusterScore}}, 5d share: {{shortSharePct}}%")
alertcondition(anySignal,
     title   = "Any Cluster Signal",
     message = "⚠️ VP CLUSTER detected — check chart")

alertcondition(htfHit,
     title   = "VP Cluster — HTF Signal Detected",
     message = "📊 VP Cluster HTF: new cluster on lower TF — {{ticker}} @ {{close}}")
````
