# Painting the Tape Detector

- url: https://www.tradingview.com/script/K69BsuRb-Painting-the-Tape-Detector/
- type: indicator
- pine_id: PUB;609940fdf0f44044921d97ece96a4a5f
- version: 4.0

## Description

🎭 Painting the Tape Detector — "Fake Turnover"

Detects series of suspiciously similar consecutive bars — nearly identical close prices and volumes — which may indicate wash trading. A coordinated group trading with itself to create the illusion of liquidity.

On GPW, this pattern appears when a "spółdzielnia" (trading syndicate) generates fake activity to attract attention from screeners, create the impression of a liquid market, or build a false "trading history" before a larger move.

**HOW IT WORKS**
Each bar is compared to the previous bar across three dimensions:
📊 Close price similarity — within X% of each other (default 0.05%)
📏 High-Low range similarity — candles look copy-pasted (optional, default 0.10%)
📦 Volume similarity — within X% of each other (default 15%)

When all three match for N consecutive bars → streak detected.

**SEVERITY**
🟡 Mild (3+ bars) — unusual, worth watching
🟠 Strong (5+ bars) — rare on legitimate markets
🟣 Extreme (8+ bars) — practically impossible with genuine trading

**HTF AUTO MODE**
On 1min: full detail with columns and labels. On 5min/1h: automatically scans 1min and highlights bars with qualifying streaks. One indicator instance, adapts to whatever TF you're viewing.

**SESSION FILTER**
First and last N bars of each session are excluded — opening and closing naturally have unusual volume patterns.

**LIMITATIONS**
TradingView doesn't provide tick data, so this works on 1min bars as an approximation of true wash trading detection. False signals can occur on very illiquid stocks where price genuinely doesn't move. Use minimum volume filter to reduce noise.

**PRO TIP**
Most meaningful when combined with Fixing Volume Visualization — wash trading during the day + high fixing volume = someone is working the stock from multiple angles simultaneously.

Open source, Pine Script v6. Part of the Smart Money Hunter / GPW Anomaly Detection toolkit.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © fis_wse
//
// Painting the Tape Detector — "Pozorny obrót"
// Detects series of suspiciously similar transactions (identical or near-identical
// close prices and volumes) that may indicate wash trading — a coordinated group
// trading with itself to create the illusion of liquidity.
//
// Use on 1min or 5min charts.
// On GPW, this is a classic sign of a "spółdzielnia" creating fake activity.

//@version=6
indicator("Painting the Tape Detector", shorttitle="Tape Paint", overlay=false, precision=2, max_labels_count=500)

// ─────────────────────────────────────────
// 📋  MARKET PRESET
// ─────────────────────────────────────────

g_preset  = "📋 Market Preset"
presetStr = input.string("Mid Cap (mWIG40 / sWIG80)", "Market preset",
     options=["Large Cap (WIG20)", "Mid Cap (mWIG40 / sWIG80)", "Small Cap (NewConnect)", "— Custom —"],
     group=g_preset,
     tooltip="Auto-configures streak detection and min volume thresholds for the selected segment.\nPrice/volume similarity tolerances stay manual — they depend on absolute price level, not segment.")

_pL = presetStr == "Large Cap (WIG20)"
_pM = presetStr == "Mid Cap (mWIG40 / sWIG80)"
_pS = presetStr == "Small Cap (NewConnect)"
_pC = presetStr == "— Custom —"

// ─────────────────────────────────────────
// ⚙️  SETTINGS
// ─────────────────────────────────────────

// --- Price similarity ---
g_price = "Price Similarity"
priceTolPct  = input.float(0.05, "Max price deviation (%)",   minval=0.01, maxval=2.0, step=0.01, group=g_price,
     tooltip="Two bars have 'same price' if their closes differ by less than this %. 0.05 = within 0.05% = virtually identical.\nKept manual — depends on absolute price level (penny stocks vs blue chips).")
useHLcheck   = input.bool(true,  "Also check High-Low range similarity", group=g_price,
     tooltip="If ON, both close AND high-low range must be similar. Stronger filter — catches candles that look copy-pasted.")
hlTolPct     = input.float(0.10, "Max H-L range deviation (%)", minval=0.01, maxval=5.0, step=0.05, group=g_price,
     tooltip="Two bars have 'same range' if their high-low ranges differ by less than this %.")

// --- Volume similarity ---
g_vol = "Volume Similarity"
volTolPct    = input.float(15.0, "Max volume deviation (%)",  minval=1.0, maxval=100.0, step=1.0, group=g_vol,
     tooltip="Two bars have 'similar volume' if they differ by less than this %. 15 = within 15% of each other.")
minVol_      = input.int(100,    "Minimum volume per bar (Custom)", minval=0, maxval=100000, group=g_vol,
     tooltip="Ignore bars with volume below this. Filters pre-market noise and empty bars.\nPreset values — WIG20: 1000  mWIG40: 100  NewConnect: 50")

// --- Streak detection ---
g_streak = "Streak Detection"
minStreak_    = input.int(3, "Min consecutive similar bars (Custom)", minval=2, maxval=20, group=g_streak,
     tooltip="How many consecutive bars must be 'similar' to trigger a signal. 3 = triplet of copy-paste bars.\nPreset values — WIG20: 3  mWIG40: 3  NewConnect: 4")
strongStreak_ = input.int(5, "Strong signal streak (Custom)",         minval=3, maxval=30, group=g_streak,
     tooltip="Streak length that triggers strong signal (more suspicious).\nPreset values — WIG20: 5  mWIG40: 5  NewConnect: 7")
extremeStreak_= input.int(8, "Extreme signal streak (Custom)",        minval=4, maxval=50, group=g_streak,
     tooltip="Streak length that triggers extreme signal (very rare on legitimate markets).\nPreset values — WIG20: 8  mWIG40: 8  NewConnect: 12")

// ── Preset resolver ─────────────────────
// WIG20 = high liquidity, real trading varies → wash patterns rare, even short streaks notable
// mWIG40 = balanced default
// NewConnect = low liquidity, many naturally similar bars → require longer streaks + filter quiet bars
minVol        = _pC ? minVol_        : _pL ? 1000 : _pM ? 100 : _pS ? 50  : minVol_
minStreak     = _pC ? minStreak_     : _pL ? 3    : _pM ? 3   : _pS ? 4   : minStreak_
strongStreak  = _pC ? strongStreak_  : _pL ? 5    : _pM ? 5   : _pS ? 7   : strongStreak_
extremeStreak = _pC ? extremeStreak_ : _pL ? 8    : _pM ? 8   : _pS ? 12  : extremeStreak_

// --- Session filter ---
g_session = "Session Filter"
useSessionFilter = input.bool(true, "Filter out opening/closing auction bars", group=g_session,
     tooltip="Ignore first and last N bars of each session — these naturally have unusual volume patterns.")
auctionBars  = input.int(3, "Bars to ignore at open/close", minval=1, maxval=10, group=g_session,
     tooltip="Number of 1min bars to skip at session open and close.")

// --- Visual ---
g_vis = "Visual Settings"
colMild      = input.color(color.new(#FFD600, 0),  "Mild streak",    group=g_vis)
colStrong    = input.color(color.new(#FF6D00, 0),  "Strong streak",  group=g_vis)
colExtreme   = input.color(color.new(#D500F9, 0),  "Extreme streak", group=g_vis)
colSimilar   = input.color(color.new(#42A5F5, 40), "Similar bars (sub-threshold)", group=g_vis)
colNormal    = input.color(color.new(#9E9E9E, 70), "Normal bars",    group=g_vis)
showLabels   = input.bool(true,  "Show alert labels",   group=g_vis)
showBg       = input.bool(true,  "Show background shading", group=g_vis)
bgTransp     = input.int(88,     "Background transparency", minval=60, maxval=98, group=g_vis)

// --- HTF Summary Mode ---
g_htf = "HTF Summary Mode"
htfModeStr   = input.string("Auto", "HTF summary mode", options=["Auto", "Always ON", "Always OFF"], group=g_htf,
     tooltip="Auto: on chart TF ≤ scan TF = full detail. On higher TF = highlight bars with streaks. Adapts automatically when you switch timeframes.")
htfScanTF    = input.timeframe("1", "Lower TF to scan", group=g_htf,
     tooltip="Which timeframe to scan for streaks when on higher TF. 1 = 1min.")
htfMinSev    = input.string("Strong", "Min severity to highlight", options=["Mild", "Strong", "Extreme"], group=g_htf)
colHtfMild   = input.color(color.new(#FFD600, 70), "HTF — Mild",    group=g_htf)
colHtfStrong = input.color(color.new(#FF6D00, 60), "HTF — Strong",  group=g_htf)
colHtfExt    = input.color(color.new(#D500F9, 50), "HTF — Extreme", group=g_htf)

// --- Date range ---
g_date = "Date Range Filter"
useDateRange = input.bool(false,       "Enable date range", group=g_date)
dateFrom     = input.time(timestamp("2025-01-01"), "From",  group=g_date)
dateTo       = input.time(timestamp("2026-12-31"), "To",    group=g_date)

// ─────────────────────────────────────────
// 📐  HTF AUTO DETECTION
// ─────────────────────────────────────────

chartTFsec = timeframe.in_seconds()
scanTFsec  = timeframe.in_seconds(htfScanTF)
htfMode    = htfModeStr == "Always ON" ? true : htfModeStr == "Always OFF" ? false : chartTFsec > scanTFsec

// ─────────────────────────────────────────
// 📐  CALCULATIONS
// ─────────────────────────────────────────

inDateRange = useDateRange ? (time >= dateFrom and time <= dateTo) : true

// Session filter: ignore first/last N bars
var int barsIntoSession = 0
isNewDay2 = ta.change(dayofmonth) != 0
if isNewDay2
    barsIntoSession := 1
else
    barsIntoSession += 1

// Rough end-of-session detection: count bars since session start
// On 1min: GPW session ≈ 510 bars (8:30-17:00 + fixing)
// We flag last N bars too — simple: if next bar is new day, this is near end
barsFromEnd = 0  // can't perfectly detect from current bar, use time approach
nearOpen  = barsIntoSession <= auctionBars
nearClose = (hour == 16 and minute >= (60 - auctionBars)) or hour == 17
inAuction = useSessionFilter and (nearOpen or nearClose)

// Skip bars with too low volume or in auction period
validBar = volume >= minVol and not inAuction and inDateRange

// ─────────────────────────────────────────
// 🔍  SIMILARITY CHECKS
// ─────────────────────────────────────────

// Price similarity: are two closes within priceTolPct of each other?
priceClose1 = close[1]
priceSimilar = priceClose1 != 0 ? math.abs(close - priceClose1) / priceClose1 * 100 <= priceTolPct : false

// High-Low range similarity
range0 = high - low
range1 = high[1] - low[1]
rangeSimilar = range1 != 0 ? math.abs(range0 - range1) / range1 * 100 <= hlTolPct : (range0 == 0 and range1 == 0)

// Volume similarity: are two volumes within volTolPct of each other?
vol1 = volume[1]
volSimilar = vol1 != 0 ? math.abs(volume - vol1) / vol1 * 100 <= volTolPct : false

// Combined similarity
pricePart  = priceSimilar
rangePart  = not useHLcheck or rangeSimilar
volPart    = volSimilar

isSimilar  = validBar and pricePart and rangePart and volPart

// ─────────────────────────────────────────
// 📈  STREAK COUNTER
// ─────────────────────────────────────────

var int streak = 0
if isSimilar
    streak += 1
else
    streak := 0

// Similarity score: normalize streak to 0-10 scale for plotting
streakPlot = streak

// Severity
isMild    = streak >= minStreak    and streak < strongStreak
isStrong  = streak >= strongStreak and streak < extremeStreak
isExtreme = streak >= extremeStreak
anySignal = streak >= minStreak

// ─────────────────────────────────────────
// 🔭  HTF SCAN
// ─────────────────────────────────────────

severityCode = isExtreme ? 3 : isStrong ? 2 : isMild ? 1 : 0
bool _htfValid = timeframe.in_seconds(htfScanTF) < timeframe.in_seconds()
string _safeTF = _htfValid ? htfScanTF : "1"
htfMaxArr      = request.security_lower_tf(syminfo.tickerid, _safeTF, severityCode)

var int htfSev = 0
htfSev := 0
if htfMode and _htfValid and array.size(htfMaxArr) > 0
    for i = 0 to array.size(htfMaxArr) - 1
        v = array.get(htfMaxArr, i)
        if v > htfSev
            htfSev := v

minHtfSev = htfMinSev == "Extreme" ? 3 : htfMinSev == "Strong" ? 2 : 1
htfHit    = htfMode and htfSev >= minHtfSev

// ─────────────────────────────────────────
// 🎨  PLOTTING
// ─────────────────────────────────────────

// Bar colors by streak severity
var color barCol = colNormal
if not htfMode
    if isExtreme
        barCol := colExtreme
    else if isStrong
        barCol := colStrong
    else if isMild
        barCol := colMild
    else if isSimilar
        barCol := colSimilar
    else
        barCol := colNormal

plot(not htfMode ? streakPlot : na, "Streak Length", color=barCol, linewidth=2, style=plot.style_columns)

// Threshold reference lines
hline(minStreak,    "Mild threshold",    color=color.new(colMild,    50), linestyle=hline.style_dotted)
hline(strongStreak, "Strong threshold",  color=color.new(colStrong,  50), linestyle=hline.style_dashed)
hline(extremeStreak,"Extreme threshold", color=color.new(colExtreme, 40), linestyle=hline.style_solid)
hline(0, "Zero", color=color.new(#FFFFFF, 80))

// Background
var color bgCol = na
if not htfMode and showBg
    if isExtreme
        bgCol := color.new(colExtreme, bgTransp)
    else if isStrong
        bgCol := color.new(colStrong, bgTransp)
    else if isMild
        bgCol := color.new(colMild, bgTransp)
    else
        bgCol := na
else if htfMode and htfHit
    bgCol := htfSev == 3 ? colHtfExt : htfSev == 2 ? colHtfStrong : colHtfMild
else
    bgCol := na
bgcolor(bgCol)

// ─────────────────────────────────────────
// 🏷️  LABELS
// ─────────────────────────────────────────

if not htfMode and showLabels

    // Main streak label — fires when streak just reaches threshold, then again at each severity upgrade
    if (streak == minStreak) or (streak == strongStreak) or (streak == extremeStreak)
        sev  = isExtreme ? "🟣 EXTREME" : isStrong ? "🟠 STRONG" : "🟡 MILD"
        txt  = sev + " TAPE PAINT" +
               "\nStreak: " + str.tostring(streak) + " bars" +
               "\nClose: "  + str.tostring(close, "#.####") +
               "\nVol: "    + str.tostring(volume, "#") +
               "\nΔPrice: " + str.tostring(math.abs(close - close[1]) / close[1] * 100, "#.###") + "%" +
               "\nΔVol: "   + str.tostring(math.abs(volume - volume[1]) / volume[1] * 100, "#.#") + "%"

        lblCol = isExtreme ? colExtreme : isStrong ? colStrong : colMild

        label.new(bar_index, streak, txt,
             style     = label.style_label_down,
             color     = lblCol,
             textcolor = color.white,
             size      = size.small)

// HTF label
if htfMode and showLabels and htfHit
    htfSevTxt = htfSev == 3 ? "🟣 EXTREME" : htfSev == 2 ? "🟠 STRONG" : "🟡 MILD"
    htfLblCol = htfSev == 3 ? colExtreme : htfSev == 2 ? colStrong : colMild

    label.new(bar_index, 0, htfSevTxt + "\ntape",
         style     = label.style_label_up,
         color     = htfLblCol,
         textcolor = color.white,
         size      = size.tiny)

// ─────────────────────────────────────────
// 🔔  ALERTS
// ─────────────────────────────────────────

alertcondition(streak == minStreak,
     title   = "Mild Tape Painting",
     message = "🟡 MILD tape painting: {{streak}} consecutive similar bars. Close {{close}}, Vol {{volume}}")

alertcondition(streak == strongStreak,
     title   = "Strong Tape Painting",
     message = "🟠 STRONG tape painting: {{streak}} consecutive similar bars — possible wash trade")

alertcondition(streak == extremeStreak,
     title   = "Extreme Tape Painting",
     message = "🟣 EXTREME tape painting: {{streak}} consecutive similar bars — high probability wash trading")

alertcondition(anySignal,
     title   = "Any Tape Painting",
     message = "⚠️ Tape painting detected: {{streak}} similar consecutive bars")

alertcondition(htfHit,
     title   = "Tape Paint — HTF Signal Detected",
     message = "🎭 Tape Paint HTF: tape painting detected on lower TF — {{ticker}} @ {{close}}")
````
