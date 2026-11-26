# Pre-Fixing Volume Spike

- url: https://www.tradingview.com/script/nBs3Mdno-Pre-Fixing-Volume-Spike/
- type: indicator
- pine_id: PUB;b4575b123d5e4a888e11b25b9afaef8a
- version: 4.0

## Description

📊 Pre-Fixing Volume Spike — Detect Fixing Paint Attempts

Interesting things happen in the last few minutes before the fixing (closing auction). Large players often position themselves in the final 5-20 minutes of continuous trading to influence the fixing price — buying aggressively to paint it higher, or dumping to drag it lower. This indicator watches exactly that window and flags unusual volume activity.

On GPW, fixing is at 17:00. The window from 16:40-17:00 is where the real action happens — not inside the auction itself, but in the positioning right before.

─────────────────────────────────────────
🔍 WHAT IT DETECTS
─────────────────────────────────────────

The indicator watches one simple thing: how much volume is happening RIGHT NOW compared to what's normal for THIS EXACT MINUTE on other trading days.

📊 Volume at time-of-day — A bar at 16:42 is compared to historical bars at 16:42, not to a flat daily average. This is what makes the signal meaningful — a "normal" 16:42 is very different from a "normal" 10:30.

⚡ Spike ratio — Current volume ÷ historical average for this minute. 2x = mild, 3.5x = strong, 6x = extreme.

⬆⬇ Direction bias — Is the pre-fixing volume pushing price UP or DOWN? Aggressive buying before fixing = someone wants the close higher. Aggressive selling = someone wants it lower.

─────────────────────────────────────────
🧠 WHY IT WORKS
─────────────────────────────────────────

The fixing price on GPW matters for multiple reasons:
 • It's the reference price for options and structured products
 • It's what many institutional mandates use for NAV calculation
 • It's the price that ends up in financial reports

This creates incentive for large players to nudge the fixing in their preferred direction. They can't do it inside the auction (too transparent), so they position themselves in the final minutes of continuous trading — buying aggressively to set a higher last traded price before the auction opens, or unloading to set a lower one.

A sudden 3-6x volume spike at 16:45 on a stock that normally trades quietly at that hour is a footprint. And if the spike is directional — all buying, or all selling — the intent is clear.

─────────────────────────────────────────
📐 HOW IT WORKS
─────────────────────────────────────────

The indicator runs on 1min or 5min charts and shows:

 🟡 Yellow columns — mild spike (2-3.5x normal)
 🟠 Orange columns — strong spike (3.5-6x normal)
 🟣 Purple columns — extreme spike (6x+)
 🟢 Green/🔴 Red histogram — direction bias (buying/selling pressure during the spike)
 🟡 Yellow shaded background — the pre-fixing window itself

Threshold lines:
 ⚪ 1.0 baseline (normal volume for this time-of-day)
 🟡 Mild threshold (dotted)
 🟠 Strong threshold (dashed)
 🟣 Extreme threshold (solid)

When a spike is detected, an alert label shows:
 ⚠️ Severity (MILD / STRONG / EXTREME)
 📊 Exact ratio, current volume, expected volume
 ⏱️ Minutes remaining until fixing

─────────────────────────────────────────
🕐 HTF SUMMARY MODE (with Auto)
─────────────────────────────────────────

This is where it gets powerful for scanning. Add the indicator once to your chart, leave HTF mode on "Auto", and it will adapt to whatever timeframe you're viewing:

 • On 5min (or lower) — full detail: columns, labels, direction bias, window shading
 • On 1h (or higher) — scans the 5min timeframe in the background and highlights any HTF bar that contained a pre-fixing spike. Just the highlight, nothing else — clean scan view.

Switch your chart from 5min to 1h and the indicator automatically swaps modes. No settings to touch, no duplicate indicator instances needed.

If you want to override the auto-detection, set HTF mode to "Always ON" or "Always OFF".

This lets you scan a whole month on 1h in seconds and immediately spot which days had aggressive fixing manipulation — then zoom into 5min for details.

🔧 HTF summary mode → Auto (recommended)
🔧 Lower timeframe to scan → 5
🔧 Minimum severity → Extreme (or Strong if you want more hits)

─────────────────────────────────────────
⚙️ SETTINGS
─────────────────────────────────────────

Pre-fixing window:
 • Fixing hour (exchange time) — default 17 for GPW
 • Pre-fixing window (minutes) — how far back from fixing to analyze. Default 20 (16:40-17:00).

Baseline calculation:
 • Lookback (days) — how many days to average for the time-of-day baseline. Default 20.

Thresholds:
 • Mild spike multiplier — default 2.0
 • Strong spike multiplier — default 3.5
 • Extreme spike multiplier — default 6.0

Direction analysis:
 • Track pre-fixing direction bias — show buying vs selling pressure during spikes

HTF summary mode:
 • HTF summary mode — Auto (default, recommended) / Always ON / Always OFF
 • Lower TF to scan — default 5 (5min)
 • Minimum severity to highlight — Mild, Strong, or Extreme
 • Separate color controls for HTF highlights

Visual:
 • Full color customization for all severities
 • Toggle labels, background shading independently
 • Adjustable transparency

Date range:
 • Optional date filter for specific period analysis

─────────────────────────────────────────
✅ RECOMMENDED SETTINGS
─────────────────────────────────────────

For 5min chart (detail view):
 Window: 20 min
 Lookback: 20 days
 Mild: 2.0, Strong: 3.5, Extreme: 6.0
 Track direction: ON

For 1min chart (precise entry timing):
 Window: 15 min
 Lookback: 20 days
 Mild: 2.5, Strong: 5.0, Extreme: 10.0
 (Tighter thresholds — 1min data is noisier)

For 1h chart (scanning mode):
 HTF mode: Auto (auto-activates on 1h)
 Lower TF: 5
 Minimum severity: Extreme (for cleanest signals)
 OR: Strong (to catch more events)

For illiquid stocks (sWIG80, NewConnect):
 Raise all thresholds by ~50% (Mild 3.0, Strong 5.0, Extreme 10.0)
 — single orders routinely create 5x spikes on low-float stocks

─────────────────────────────────────────
💡 PRO TIPS
─────────────────────────────────────────

 • Direction matters more than magnitude. A 3x spike of pure buying is more meaningful than a 6x spike of mixed activity. Watch the histogram color.

 • The strongest paint signal: extreme spike + directional + very close to fixing (0-5 min to fix). This is someone making a final push to set the closing price.

 • If you see a pattern of daily pre-fixing spikes in the SAME direction over several days, combine this with the FO Gap indicator. Consistent pre-fixing buying + consistent OPEN > FIX bias = the same player is working the stock from both ends.

 • On days with major news or ex-dividend, expect false signals. The time-of-day baseline adapts over 20 days, but a single extreme event will show up as a spike even if it's not manipulation.

 • HTF mode is best for backtesting — scan a year of 1h data to find the days with suspicious pre-fixing activity, then investigate those days in detail on 5min.

─────────────────────────────────────────
⚠️ DISCLAIMER
─────────────────────────────────────────

This indicator is a pattern detection tool, not a trading signal. Pre-fixing volume spikes can happen for legitimate reasons — index rebalancing, large institutional orders, news reactions. Always combine with your own analysis.

─────────────────────────────────────────
🛠️ BUILT WITH PINE SCRIPT v6
─────────────────────────────────────────

Open source. Part of the GPW Anomaly Detection toolkit alongside:
 • AutomatOff (ATR + Volume Collapse + Still Price)
 • Fixing Volume Visualization
 • Volume-Weighted Price Drift
 • Fixing-Open Gap Asymmetry

Suggestions and bug reports welcome in the comments.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © fis_wse
//
// Pre-Fixing Volume Spike — "Malowanie fixingu"
// Detects unusual volume activity in the final minutes before the closing auction (fixing).
// Large players often position themselves in the last 5-10 minutes before fixing (17:00 on GPW)
// to influence the closing auction price. This indicator compares current volume in the
// pre-fixing window to the historical average for the SAME time-of-day.
//
// Use on 1min or 5min charts.
//@version=6
indicator("Pre-Fixing Volume Spike", shorttitle="PreFix Spike", overlay=false, precision=2, max_labels_count=500)
// ─────────────────────────────────────────
// ⚙️  SETTINGS
// ─────────────────────────────────────────
// --- Market Preset ---
g_preset = "📋 Market Preset"
presetStr = input.string("Mid Cap (mWIG40 / sWIG80)", "Market preset",
     options=["Large Cap (WIG20)", "Mid Cap (mWIG40 / sWIG80)", "Small Cap (NewConnect)", "NASDAQ Large Cap", "— Custom —"],
     group=g_preset,
     tooltip="Auto-configures fixing hour and spike thresholds. Select '— Custom —' to set values manually.")
// --- Window ---
g_window = "Pre-Fixing Window"
fixingHour    = input.int(17,    "Fixing hour (exchange time) (Custom only)", minval=0, maxval=23, group=g_window,
     tooltip="Hour of the closing auction. GPW = 17.")
windowMinutes = input.int(20,    "Pre-fixing window (minutes)", minval=5, maxval=60, group=g_window,
     tooltip="How many minutes BEFORE fixing to analyze. 20 = watch from 16:40 to 17:00.")
// --- Baseline ---
g_base = "Baseline Calculation"
lookbackDays  = input.int(20,    "Lookback (days)",             minval=5, maxval=100, group=g_base,
     tooltip="How many trading days to use for the 'normal' volume baseline for each minute.")
// --- Thresholds ---
g_thresh = "Thresholds"
spikeMild     = input.float(2.0, "Mild spike multiplier (Custom only)",       minval=1.2, maxval=20.0, step=0.1, group=g_thresh,
     tooltip="Multiplier of average volume to trigger mild spike. 2.0 = volume is 2x average for this minute.")
spikeStrong   = input.float(3.5, "Strong spike multiplier (Custom only)",     minval=1.5, maxval=50.0, step=0.1, group=g_thresh,
     tooltip="Multiplier for strong spike signal.")
spikeExtreme  = input.float(6.0, "Extreme spike multiplier (Custom only)",    minval=2.0, maxval=100.0, step=0.5, group=g_thresh,
     tooltip="Multiplier for extreme spike — likely aggressive positioning before fixing.")
// --- Direction analysis ---
g_dir = "Direction Analysis"
trackDirection = input.bool(true, "Track pre-fixing direction bias", group=g_dir,
     tooltip="Show whether pre-fixing volume is buying (price up) or selling (price down). Paint attempts often have directional bias.")
// --- HTF Summary Mode ---
g_htf = "HTF Summary Mode"
htfModeStr     = input.string("Auto", "HTF summary mode", options=["Auto", "Always ON", "Always OFF"], group=g_htf,
     tooltip="Auto (recommended): on chart TF equal or smaller than 'Lower TF to scan' = show full detail. On higher TF = scan lower TF and highlight bars with spikes. You can keep this one indicator instance and it adapts to whatever chart TF you're viewing.")
htfScanTF      = input.timeframe("5", "Lower TF to scan",           group=g_htf,
     tooltip="Which timeframe to scan for spikes when on higher TF. 5 = 5min.")
htfMinSeverity = input.string("Extreme", "Minimum severity to highlight", options=["Mild", "Strong", "Extreme"], group=g_htf,
     tooltip="Only highlight HTF bars that contained a spike of at least this severity on the lower TF.")
colHtfMild     = input.color(color.new(#FFD600, 70), "HTF highlight — Mild",    group=g_htf)
colHtfStrong   = input.color(color.new(#FF6D00, 60), "HTF highlight — Strong",  group=g_htf)
colHtfExtreme  = input.color(color.new(#D500F9, 50), "HTF highlight — Extreme", group=g_htf)
// Auto-detect: HTF mode should activate when chart TF > scan TF
chartTFsec = timeframe.in_seconds()
scanTFsec  = timeframe.in_seconds(htfScanTF)
htfMode    = htfModeStr == "Always ON" ? true : htfModeStr == "Always OFF" ? false : chartTFsec > scanTFsec
// --- Visual ---
g_vis = "Visual Settings"
colMild       = input.color(color.new(#FFD600, 0),  "Mild spike",    group=g_vis)
colStrong     = input.color(color.new(#FF6D00, 0),  "Strong spike",  group=g_vis)
colExtreme    = input.color(color.new(#D500F9, 0),  "Extreme spike", group=g_vis)
colNormal     = input.color(color.new(#9E9E9E, 60), "Normal volume", group=g_vis)
colBuy        = input.color(color.new(#00C853, 0),  "Pre-fix buying", group=g_vis)
colSell       = input.color(color.new(#FF1744, 0),  "Pre-fix selling", group=g_vis)
showLabels    = input.bool(true,  "Show alert labels",            group=g_vis)
showBg        = input.bool(true,  "Shade pre-fixing window",      group=g_vis)
bgTransp      = input.int(92,     "Window background transparency", minval=70, maxval=98, group=g_vis)
// --- Date range ---
g_date = "Date Range Filter"
useDateRange  = input.bool(false,       "Enable date range", group=g_date)
dateFrom      = input.time(timestamp("2025-01-01"), "From",  group=g_date)
dateTo        = input.time(timestamp("2026-12-31"), "To",    group=g_date)
// 🎛️  PRESET RESOLVED VALUES
// ─────────────────────────────────────────

_pL = presetStr == "Large Cap (WIG20)"
_pM = presetStr == "Mid Cap (mWIG40 / sWIG80)"
_pS = presetStr == "Small Cap (NewConnect)"
_pN = presetStr == "NASDAQ Large Cap"
_pC = presetStr == "— Custom —"
_fixingHour = _pC ? fixingHour : _pL ? 17 : _pM ? 17 : _pS ? 17 : _pN ? 16 : fixingHour
_spikeMild = _pC ? spikeMild : _pL ? 2.0 : _pM ? 2.0 : _pS ? 3.0 : _pN ? 2.5 : spikeMild
_spikeStrong = _pC ? spikeStrong : _pL ? 3.5 : _pM ? 3.5 : _pS ? 5.0 : _pN ? 4.0 : spikeStrong
_spikeExtreme = _pC ? spikeExtreme : _pL ? 6.0 : _pM ? 6.0 : _pS ? 10.0 : _pN ? 8.0 : spikeExtreme
// ─────────────────────────────────────────
// 📐  CALCULATIONS
// ─────────────────────────────────────────
inDateRange = useDateRange ? (time >= dateFrom and time <= dateTo) : true
// Check if current bar is inside pre-fixing window
curHour   = hour(time)
curMinute = minute(time)
curTotalMin = curHour * 60 + curMinute
fixingTotalMin = _fixingHour * 60
windowStart = fixingTotalMin - windowMinutes
inWindow = curTotalMin >= windowStart and curTotalMin < fixingTotalMin
// ─────────────────────────────────────────
// 📊  TIME-OF-DAY BASELINE
// ─────────────────────────────────────────
// We want the average volume for THIS SPECIFIC MINUTE over the last N days.
// Since Pine Script bars are sequential, we approximate by using a rolling average
// of volume at the same time-of-day.
//
// Trick: count how many bars per day on this timeframe, then multiply by lookbackDays.
// Detect new day
isNewDay = ta.change(dayofmonth) != 0
// Count bars per day (rolling) by counting bars since last new day
var int barsToday = 0
if isNewDay
    barsToday := 1
else
    barsToday += 1
// Estimate bars per day using SMA of (barsToday on last bar of each day)
// Simpler approach: use fixed timeframe calculation
tfMinutes = timeframe.in_seconds() / 60
barsPerDay = tfMinutes > 0 ? math.round(510 / tfMinutes) : 78  // GPW session ~8.5h = 510min
// Rolling average of volume at SAME time-of-day
// By sampling volume[barsPerDay], volume[barsPerDay*2], ... we get same-time-of-day history
sumTodVol = 0.0
countTod  = 0
for i = 1 to lookbackDays
    idx = i * barsPerDay
    v = nz(volume[idx], 0)
    if v > 0
        sumTodVol += v
        countTod  += 1
avgTodVol = countTod > 0 ? sumTodVol / countTod : 0.0
// Spike ratio (only meaningful in the pre-fixing window)
spikeRatio = (inWindow and avgTodVol > 0) ? volume / avgTodVol : 0.0
// ─────────────────────────────────────────
// 🎯  SIGNAL LOGIC
// ─────────────────────────────────────────
isMild    = inDateRange and inWindow and spikeRatio >= _spikeMild    and spikeRatio < _spikeStrong
isStrong  = inDateRange and inWindow and spikeRatio >= _spikeStrong  and spikeRatio < _spikeExtreme
isExtreme = inDateRange and inWindow and spikeRatio >= _spikeExtreme
anySpike  = isMild or isStrong or isExtreme
// Direction: is this bar going up or down?
barDir = close > open ? 1 : close < open ? -1 : 0
// ─────────────────────────────────────────
// 🔭  HTF SCAN (query lower TF for max severity inside current HTF bar)
// ─────────────────────────────────────────
// Build a numeric severity code: 0 = none, 1 = mild, 2 = strong, 3 = extreme.
severityCode = isExtreme ? 3 : isStrong ? 2 : isMild ? 1 : 0
// When on HTF chart, ask lower TF for the MAX severity within this HTF bar.
bool _htfValid = timeframe.in_seconds(htfScanTF) < timeframe.in_seconds()
string _safeTF = _htfValid ? htfScanTF : "1"
htfMaxSeverity = request.security_lower_tf(syminfo.tickerid, _safeTF, severityCode)
// Reduce the array to a single max value for this HTF bar
var int htfSev = 0
htfSev := 0
if htfMode and _htfValid and array.size(htfMaxSeverity) > 0
    for i = 0 to array.size(htfMaxSeverity) - 1
        v = array.get(htfMaxSeverity, i)
        if v > htfSev
            htfSev := v
// Translate severity threshold selection
minSev = htfMinSeverity == "Extreme" ? 3 : htfMinSeverity == "Strong" ? 2 : 1
htfHit = htfMode and htfSev >= minSev
// ─────────────────────────────────────────
// 🎨  PLOTTING
// ─────────────────────────────────────────
// Color spike ratio bars by severity (only when NOT in HTF mode)
var color spikeColor = colNormal
if isExtreme
    spikeColor := colExtreme
else if isStrong
    spikeColor := colStrong
else if isMild
    spikeColor := colMild
else
    spikeColor := colNormal
plot((not htfMode and inWindow) ? spikeRatio : na, "Spike Ratio", color=spikeColor, linewidth=2, style=plot.style_columns)
// Reference lines
plot(_spikeMild,    "Mild threshold",    color=color.new(colMild,    50), linewidth=1, style=plot.style_line)
plot(_spikeStrong,  "Strong threshold",  color=color.new(colStrong,  50), linewidth=1, style=plot.style_line)
plot(_spikeExtreme, "Extreme threshold", color=color.new(colExtreme, 40), linewidth=1, style=plot.style_line)
hline(1.0,          "Baseline (1x)",     color=color.new(#FFFFFF,    70))
// Direction bar (if tracking, only in normal mode)
dirBarVal = (not htfMode and trackDirection and inWindow and anySpike) ? (barDir * spikeRatio * 0.3) : na
plot(dirBarVal, "Direction bias", color=barDir == 1 ? colBuy : colSell, linewidth=1, style=plot.style_histogram)
// Shade the pre-fixing window (only in normal mode)
var color bgCol = na
if not htfMode and showBg and inWindow
    bgCol := color.new(#FFC107, bgTransp)
else if htfMode and htfHit
    bgCol := htfSev == 3 ? colHtfExtreme : htfSev == 2 ? colHtfStrong : colHtfMild
else
    bgCol := na
bgcolor(bgCol)
// ─────────────────────────────────────────
// 🏷️  LABELS
// ─────────────────────────────────────────
// Format volume as 1.2M / 52K / 341
formatVol(float val) =>
    string result = ""
    if val >= 1000000
        result := str.tostring(math.round(val / 1000000.0, 2)) + "M"
    else if val >= 1000
        result := str.tostring(math.round(val / 1000.0, 1)) + "K"
    else
        result := str.tostring(math.round(val))
    result
if not htfMode and showLabels and anySpike
    severity = isExtreme ? "🟣 EXTREME" : isStrong ? "🟠 STRONG" : "🟡 MILD"
    dirTxt   = trackDirection ? (barDir == 1 ? " ⬆" : barDir == -1 ? " ⬇" : "") : ""
    minToFix = fixingTotalMin - curTotalMin
    txt = severity + " SPIKE" + dirTxt +
          "\nRatio: "   + str.tostring(spikeRatio, "#.##") + "x" +
          "\nVol: "     + formatVol(volume) +
          "\nAvg: "     + formatVol(avgTodVol) +
          "\nTo fix: "  + str.tostring(minToFix) + "min"
    lblCol = isExtreme ? colExtreme : isStrong ? colStrong : colMild
    label.new(bar_index, spikeRatio, txt,
         style     = label.style_label_down,
         color     = lblCol,
         textcolor = color.white,
         size      = size.small)
// HTF hit marker (one small label per HTF bar that contained a qualifying spike)
if htfMode and showLabels and htfHit
    htfSevTxt = htfSev == 3 ? "🟣 EXTREME" : htfSev == 2 ? "🟠 STRONG" : "🟡 MILD"
    htfLblCol = htfSev == 3 ? colExtreme : htfSev == 2 ? colStrong : colMild
    label.new(bar_index, 0, htfSevTxt + "\npre-fix",
         style     = label.style_label_up,
         color     = htfLblCol,
         textcolor = color.white,
         size      = size.tiny)
// ─────────────────────────────────────────
// 🔔  ALERTS
// ─────────────────────────────────────────
alertcondition(isMild,
     title   = "Mild Pre-Fixing Spike",
     message = "🟡 Pre-fixing volume spike: {{spikeRatio}}x normal")
alertcondition(isStrong,
     title   = "Strong Pre-Fixing Spike",
     message = "🟠 STRONG pre-fixing volume: {{spikeRatio}}x normal — possible fixing paint attempt")
alertcondition(isExtreme,
     title   = "Extreme Pre-Fixing Spike",
     message = "🟣 EXTREME pre-fixing volume: {{spikeRatio}}x normal — aggressive positioning before fixing")
alertcondition(anySpike,
     title   = "Any Pre-Fixing Spike",
     message = "⚠️ Pre-fixing volume spike detected")

alertcondition(htfHit,
     title   = "PreFix — HTF Spike Detected",
     message = "🖌️ PreFix HTF: pre-fixing spike on lower TF — {{ticker}} @ {{close}}")
````
