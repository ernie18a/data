# VWAP Cross Flow Engine [AGPro Series]

- url: https://www.tradingview.com/script/446Fe3Nk-VWAP-Cross-Flow-Engine-AGPro-Series/
- type: indicator
- pine_id: PUB;a80f2680f91c47148a4e84739073a5f2
- version: 4.0

## Description

VWAP Cross Flow Engine [AGPro Series]

🔹 OVERVIEW

VWAP Cross Flow Engine is a precision scoring system for price-to-VWAP
crossovers. Instead of treating every VWAP cross as a binary signal,
this indicator measures the QUALITY of each crossover event in real
time using a weighted composite score derived from momentum, volume
expansion and optional sigma-band confluence. The engine is designed
for intraday scalpers and swing traders who rely on VWAP as a dynamic
equilibrium reference and need a structured way to separate high-
conviction continuation crosses from low-quality noise flips.

The script plots an anchored Volume-Weighted Average Price line with
optional volume-weighted standard-deviation bands, detects every
price/VWAP crossover event, scores each one on a 0–100 scale and
visualizes the result through compact X markers, directional bar
coloring, a retrospective quality dashboard and a dynamic bias zone
anchored on the strongest crosses.

[image]https://www.tradingview.com/x/XiPYBt5W/[/image]

🔸 UNIQUE EDGE

Most VWAP-based tools stop at plotting the line and marking raw
crossovers. VWAP Cross Flow Engine adds a multi-factor quality layer
on top of the crossover itself:

• Every cross receives a composite score, not a pass/fail flag
• Momentum sub-score derived from RSI distance from 50 at cross bar
• Volume sub-score derived from current volume vs SMA baseline
• Optional confluence bonus when cross occurs beyond 2-sigma envelope
• Retrospective follow-through measurement in ATR units
• Session-aware counters with automatic daily-vs-higher-timeframe
  label switching
• ATR-based cooldown filter that prevents label overlap on any
  timeframe, not just bar-count cooldowns that fail on daily charts

The combination of live scoring + retrospective success tracking in a
single panel is the core differentiator. It allows the trader to both
filter new crosses and study the historical reliability of VWAP cross
behavior on any symbol and timeframe.


🔷 METHODOLOGY

1. VWAP CALCULATION
   Volume-weighted average of HLC3 (configurable) anchored to the
   Session, Week or Month boundary. Cumulative price*volume and
   cumulative volume series are reset at every anchor change.

2. SIGMA BANDS (optional)
   Volume-weighted variance computed as E[X²] − E[X]² where X is the
   source price weighted by volume. Square root produces the true
   volume-weighted standard deviation. 1σ and 2σ envelopes are drawn
   around the VWAP line.

3. CROSS DETECTION
   Standard ta.crossover / ta.crossunder between close and VWAP.

4. QUALITY SCORING
   • Momentum sub-score: |RSI(14) − 50|, scaled to 0–40 range
   • Volume sub-score: volume / SMA(20), capped at 3x, scaled 0–30
   • Confluence bonus: +5 if prior bar touched the opposing 2σ band
   • Total live score (max 70 or 75) is rescaled to 0–100

5. COOLDOWN FILTER
   A new cross is only plotted if BOTH conditions are met:
   • At least N bars since the last plotted cross
   • At least K × ATR price distance from the last plotted cross

6. FOLLOW-THROUGH TRACKING
   Each cross is stored with its direction, price and ATR at the time
   of the event. After N bars, the displacement (in the cross
   direction) is measured. Success rate and average follow-through
   in ATR units are maintained inside a rolling lookback window.

7. QUALITY ZONE
   A rectangle zone (0.8 × ATR tall by default, 60 bars long) is
   drawn at every strong cross (score ≥ 70). The zone acts as a
   dynamic bias area anchored on high-conviction VWAP interactions.


🔶 SIGNALS & ALERTS

The indicator fires five distinct alert conditions:

1. High-Quality VWAP Cross Up — bullish cross above the min quality
   threshold with cooldown satisfied.
2. High-Quality VWAP Cross Down — bearish cross above the min quality
   threshold with cooldown satisfied.
3. Strong VWAP Cross (≥70) — score 70 or higher; anchors a new
   quality zone.
4. Price Reached +2σ Band — price extended to the upper sigma band
   (optional, requires bands enabled).
5. Price Reached −2σ Band — price extended to the lower sigma band
   (optional, requires bands enabled).


🔹 KEY INPUTS

VWAP Reference
• Source — price series used for VWAP (default HLC3)
• Anchor Type — Session / Week / Month
• Show VWAP Line

Sigma Bands
• Show Sigma Bands (default OFF)
• Inner Band Multiplier (default 1.0)
• Outer Band Multiplier (default 2.0)

Quality Engine
• Momentum (RSI) Length
• Volume Average Length
• Follow-Through Bars
• ATR Length
• Min Quality To Plot (default 50)
• Use Sigma Confluence Bonus
• Cooldown — Minimum Bars (default 5)
• Cooldown — Minimum ATR Distance (default 0.5)

Visuals
• Show Cross X Labels
• Show Target Projection (default OFF)
• Show Quality Zone
• Quality Zone Height (ATR) / Length (Bars)
• Color Bars By Cross Strength
• Auto Label Size (upscale on 1D+)

Panel
• Show Dashboard Panel
• Panel Position (6 positions)
• Panel Theme (Dark / Light)
• Panel Font Size
• Success Rate Lookback Bars


🔸 HOW TO USE

• INTRADAY SCALPING — use Session anchor on 5m–1h charts. Focus on
  crosses scoring 70 or higher. The quality zone becomes a short-term
  bias area: price holding above a bull zone mid-line tends to favor
  continuation, breaks back through the mid-line tend to indicate
  weakening conviction.

• SWING BIAS — use Week or Month anchor on 4h and daily charts. Treat
  strong crosses as potential regime-shift events. Monitor the
  Success Rate metric to calibrate expectations for the current
  market and instrument.

• MEAN-REVERSION — enable sigma bands and confluence bonus. Crosses
  that form after a 2σ stretch tend to score higher and mark
  statistically meaningful reversal attempts.

• FILTER CALIBRATION — raise Min Quality To Plot to 60 or 70 for
  high-selectivity environments; lower to 40 for noisier instruments
  where you want earlier confirmation.

The dashboard gives at-a-glance context: how many crosses have fired
this session, how many were strong, what the historical win rate
looks like in the current lookback window, the average ATR-normalized
follow-through, and whether price is currently above or below VWAP.


🔷 LIMITATIONS & TRANSPARENCY

• This is NOT a strategy and does not generate buy/sell orders.
• Score is a quality filter, not a directional prediction. A high-
  score cross still carries market risk and can fail.
• Follow-through statistics depend on lookback window size and
  timeframe; adjust Success Rate Lookback to match your trading
  horizon.
• Sigma bands require a reliable volume feed. On low-liquidity
  instruments the bands may be noisy or meaningless.
• Anchored VWAP resets at each new anchor (Session / Week / Month);
  early-in-anchor values use fewer samples and are less stable.
• The indicator repaints only within the cross bar itself (like any
  crossover detector). Once a bar closes, the plotted cross and its
  score are fixed.


🔶 RISK DISCLOSURE

This script is a technical analysis tool intended for educational
and analytical purposes. It does not constitute financial advice,
investment advice or a recommendation to buy or sell any asset.
Trading financial markets involves substantial risk of loss. Past
performance of any indicator is not indicative of future results.
Users are fully responsible for their own trading decisions and
should combine this tool with independent analysis and proper risk
management.

## Source Code

````pine
// ─────────────────────────────────────────────────
// VWAP Cross Flow Engine [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.6
//
// Scores the ENERGY of every price-to-VWAP crossover from momentum, volume
// surge and optional sigma-band stretch, then frames it as a fade / reversion
// context tool. High-energy crosses that punch through VWAP often behave as
// exhaustion moves: in observed samples they tend to revert back toward VWAP
// rather than continue in the cross direction. The dashboard tracks the
// reversion rate and average reversion of HIGH-QUALITY crosses only, surfaces a
// clear next-action stance, a centered fade zone marks the setup, and a single
// ATR target projects back toward the mean. This is an analytical context
// layer, not a prediction or signal system.
// Keywords: vwap cross, vwap fade, vwap reversion, mean reversion, vwap
// scalping, momentum exhaustion, volume spike, session vwap, anchored vwap,
// vwap bands, sigma bands, confluence.
// ─────────────────────────────────────────────────

//@version=6
indicator("VWAP Cross Flow Engine [AGPro Series]",
     shorttitle = "AGP VWAPX",
     overlay    = true,
     max_labels_count = 500,
     max_boxes_count  = 500,
     max_lines_count  = 500)

// ═════════════════════════════════════════════════
// INPUTS — VWAP REFERENCE
// ═════════════════════════════════════════════════
grpVW = "VWAP Reference"
vwapSrc      = input.source(hlc3, "VWAP Source", group = grpVW,
     tooltip = "Price series used in the VWAP calculation. HLC3 is the standard institutional choice.")
anchorType   = input.string("Session", "Anchor Type",
     options = ["Session", "Week", "Month"], group = grpVW,
     tooltip = "Session = daily reset (intraday scalping). Week / Month = swing anchor.")
showVWAP     = input.bool(true, "Show VWAP Line", group = grpVW)

// ═════════════════════════════════════════════════
// INPUTS — SIGMA BANDS
// ═════════════════════════════════════════════════
grpSB = "Sigma Bands"
showBands    = input.bool(false, "Show Sigma Bands", group = grpSB,
     tooltip = "Optional volume-weighted standard-deviation (sigma) bands drawn around VWAP. The 1 SD and 2 SD envelopes help visualize mean-reversion zones.")
band1Mult    = input.float(1.0, "Inner Band Multiplier", minval = 0.5, maxval = 5.0, step = 0.1, group = grpSB)
band2Mult    = input.float(2.0, "Outer Band Multiplier", minval = 0.5, maxval = 5.0, step = 0.1, group = grpSB)

// ═════════════════════════════════════════════════
// INPUTS — QUALITY ENGINE
// ═════════════════════════════════════════════════
grpQ = "Quality Engine"
rsiLen       = input.int(14, "Momentum (RSI) Length", minval = 2, maxval = 50, group = grpQ,
     tooltip = "RSI distance from 50 at the cross bar drives the Momentum sub-score.")
volLen       = input.int(20, "Volume Average Length", minval = 5, maxval = 100, group = grpQ,
     tooltip = "Simple moving average of volume used as the baseline for the volume ratio.")
followBars   = input.int(5, "Follow-Through Bars", minval = 2, maxval = 30, group = grpQ,
     tooltip = "Number of bars after each cross used to measure follow-through distance.")
atrLen       = input.int(14, "ATR Length", minval = 2, maxval = 100, group = grpQ,
     tooltip = "ATR used for target projection and follow-through normalization.")
minQuality   = input.int(50, "Min Quality To Plot", minval = 0, maxval = 100, group = grpQ,
     tooltip = "Cross events scoring below this threshold are hidden. Lower = more signals, higher = stricter filter. The dashboard stats also reflect only crosses at or above this score.")
useConfluence = input.bool(true, "Use Sigma Confluence Bonus", group = grpQ,
     tooltip = "Adds up to +5 bonus points when a cross occurs beyond the 2 SD band (stretched reversal zone). Scoring only active when sigma bands are enabled.")
cooldownBars = input.int(5, "Cooldown - Minimum Bars", minval = 0, maxval = 50, group = grpQ,
     tooltip = "Minimum bars required between two consecutive plotted crosses.")
cooldownATR  = input.float(0.5, "Cooldown - Minimum ATR Distance", minval = 0.0, maxval = 5.0, step = 0.1, group = grpQ,
     tooltip = "Minimum price distance (in ATRs) from the last plotted cross. Prevents label overlap on higher timeframes independent of bar count.")

// ═════════════════════════════════════════════════
// INPUTS — VISUALS
// ═════════════════════════════════════════════════
grpV = "Visuals"
showX        = input.bool(true, "Show Cross Labels", group = grpV)
showTarget   = input.bool(true, "Show Reversion Target", group = grpV,
     tooltip = "Dotted line + end marker projected one ATR back toward VWAP from the most recent high-quality cross (the reversion target). Only the latest projection is shown to keep the chart clean.")
targetBars   = input.int(25, "Target Projection Bars", minval = 10, maxval = 100, group = grpV)
showZone     = input.bool(true, "Show Fade Zone", group = grpV,
     tooltip = "Extended rectangle zone drawn from the last strong cross, marking the fade / reversion bias area. A centered badge shows its anchoring score.")
zoneATR      = input.float(0.8, "Fade Zone Height (ATR)", minval = 0.1, maxval = 3.0, step = 0.1, group = grpV)
zoneBars     = input.int(60, "Fade Zone Length (Bars)", minval = 10, maxval = 200, group = grpV)
colorBars    = input.bool(true, "Color Bars By Cross Strength", group = grpV)
autoLblSize  = input.bool(false, "Auto Label Size (upscale on 1D+)", group = grpV,
     tooltip = "When enabled, label font automatically upsizes on daily or higher timeframes for better readability.")
lblSizeStr   = input.string("Normal", "Manual Label Font Size",
     options = ["Tiny", "Small", "Normal", "Large"], group = grpV,
     tooltip = "Ignored when Auto Label Size is ON for 1D+ timeframes.")

// ═════════════════════════════════════════════════
// INPUTS — PANEL
// ═════════════════════════════════════════════════
grpP = "Panel"
showPanel     = input.bool(true, "Show Dashboard Panel", group = grpP)
panelPos      = input.string("Top Right", "Panel Position",
     options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = grpP)
panelTheme    = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = grpP)
panelFont     = input.string("Normal", "Panel Font Size",
     options = ["Tiny", "Small", "Normal", "Large"], group = grpP)

// ═════════════════════════════════════════════════
// COLOR PALETTE — AGPro Standard
// ═════════════════════════════════════════════════
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBg       = panelTheme == "Dark" ? color.rgb(15, 23, 42)    : color.rgb(245, 247, 250)
panelBorder   = panelTheme == "Dark" ? color.rgb(51, 65, 85)    : color.rgb(203, 213, 225)
panelLabelCol = panelTheme == "Dark" ? color.rgb(148, 163, 184) : color.rgb(71, 85, 105)
panelValueCol = panelTheme == "Dark" ? color.rgb(226, 232, 240) : color.rgb(15, 23, 42)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)
darkText      = color.rgb(17, 24, 39)

// ═════════════════════════════════════════════════
// HELPERS
// ═════════════════════════════════════════════════
f_size(s) =>
    s == "Tiny"   ? size.tiny   :
     s == "Small"  ? size.small  :
     s == "Large"  ? size.large  : size.normal

f_panelPos(p) =>
    p == "Top Right"     ? position.top_right    :
     p == "Top Left"      ? position.top_left     :
     p == "Middle Right"  ? position.middle_right :
     p == "Middle Left"   ? position.middle_left  :
     p == "Bottom Right"  ? position.bottom_right : position.bottom_left

f_text_on(color bg) =>
    bright = (color.r(bg) * 299 + color.g(bg) * 587 + color.b(bg) * 114) / 1000
    bright >= 145 ? darkText : headerText

// Auto label size on 1D+ timeframes
isHighTF = timeframe.in_seconds(timeframe.period) >= 86400
lblSize  = autoLblSize and isHighTF ? size.large : f_size(lblSizeStr)
pnlSize  = f_size(panelFont)

// Dynamic panel labels depending on timeframe
todayLabelTxt  = isHighTF ? "Crosses This Bar" : "Crosses Today"
strongLabelTxt = isHighTF ? "Strong This Bar (>=70)" : "Strong Today (>=70)"

// ═════════════════════════════════════════════════
// VWAP CALCULATION
// ═════════════════════════════════════════════════
anchorCond = anchorType == "Session" ? timeframe.change("D") :
             anchorType == "Week"    ? timeframe.change("W") : timeframe.change("M")

var float cumPV   = na
var float cumVol  = na
var float cumPV2  = na
if anchorCond or na(cumPV)
    cumPV  := vwapSrc * volume
    cumVol := volume
    cumPV2 := vwapSrc * vwapSrc * volume
else
    cumPV  += vwapSrc * volume
    cumVol += volume
    cumPV2 += vwapSrc * vwapSrc * volume

vwapLine = cumVol > 0 ? cumPV / cumVol : close
variance = cumVol > 0 ? (cumPV2 / cumVol) - (vwapLine * vwapLine) : 0.0
vwapStd  = variance > 0 ? math.sqrt(variance) : 0.0

upper1 = vwapLine + vwapStd * band1Mult
lower1 = vwapLine - vwapStd * band1Mult
upper2 = vwapLine + vwapStd * band2Mult
lower2 = vwapLine - vwapStd * band2Mult

plot(showVWAP  ? vwapLine : na, "VWAP",    accentColor, 2)
plot(showBands ? upper1   : na, "+1 SD",   color.new(accentColor, 50), 1, plot.style_linebr)
plot(showBands ? lower1   : na, "-1 SD",   color.new(accentColor, 50), 1, plot.style_linebr)
plot(showBands ? upper2   : na, "+2 SD",   color.new(accentColor, 70), 1, plot.style_linebr)
plot(showBands ? lower2   : na, "-2 SD",   color.new(accentColor, 70), 1, plot.style_linebr)

// ═════════════════════════════════════════════════
// CROSS DETECTION
// ═════════════════════════════════════════════════
crossUp   = ta.crossover(close, vwapLine)
crossDown = ta.crossunder(close, vwapLine)
crossEvt  = crossUp or crossDown

// ═════════════════════════════════════════════════
// QUALITY SCORING (0–100) + CONFLUENCE BONUS
//   Momentum   : 0–40  (RSI distance from 50)
//   Volume     : 0–30  (volume / avgVol ratio, capped)
//   Confluence : 0–5   (beyond-2-SD reversal bonus, optional)
//   Total live : 0–75  -> rescaled to 0–100
// ═════════════════════════════════════════════════
rsiVal  = ta.rsi(close, rsiLen)
avgVol  = ta.sma(volume, volLen)
atr     = math.max(nz(ta.atr(atrLen), ta.tr(true)), syminfo.mintick)

f_momScore(dir) =>
    rawDist = dir > 0 ? rsiVal - 50 : 50 - rsiVal
    d = math.max(rawDist, 0)
    math.min(d / 25.0 * 40.0, 40.0)

f_volScore() =>
    r = avgVol > 0 ? volume / avgVol : 1.0
    math.min(r / 3.0 * 30.0, 30.0)

// Confluence bonus — active only when bands are shown AND confluence is enabled
f_confScore(dir) =>
    if not (useConfluence and showBands)
        0.0
    else
        // Bull cross from below the lower 2 SD = stretched reversal
        // Bear cross from above the upper 2 SD = stretched reversal
        stretched = dir > 0 ? (low[1] <= lower2[1]) : (high[1] >= upper2[1])
        stretched ? 5.0 : 0.0

momSc = crossUp ? f_momScore(1) : crossDown ? f_momScore(-1) : 0.0
volSc = crossEvt ? f_volScore() : 0.0
conSc = crossUp ? f_confScore(1) : crossDown ? f_confScore(-1) : 0.0

// Max possible live score: 40 + 30 + (5 if confluence active) = 75 or 70
maxLive      = 40.0 + 30.0 + (useConfluence and showBands ? 5.0 : 0.0)
liveScore    = crossEvt ? momSc + volSc + conSc : 0.0
liveScore100 = maxLive > 0 ? liveScore / maxLive * 100.0 : 0.0

// ═════════════════════════════════════════════════
// COOLDOWN FILTER (bars + ATR distance)
// ═════════════════════════════════════════════════
var int   lastPlottedBar   = -10000
var float lastPlottedPrice = na
barGapOk = (bar_index - lastPlottedBar) >= cooldownBars
atrGapOk = na(lastPlottedPrice) or atr <= 0 or math.abs(close - lastPlottedPrice) >= (atr * cooldownATR)
cooldownOk = barGapOk and atrGapOk
passFilter = crossEvt and liveScore100 >= minQuality and cooldownOk

if passFilter
    lastPlottedBar   := bar_index
    lastPlottedPrice := close

strongCross = passFilter and liveScore100 >= 70

// ═════════════════════════════════════════════════
// REVERSION TRACKING (retrospective, HIGH-QUALITY crosses only)
//   Measures how far price reverts BACK toward VWAP after a high-quality
//   cross (the opposite of continuation). A win = price faded back from the
//   cross point within the follow-through window. Stats reflect only crosses
//   that passed the quality filter, so the dashboard matches what the engine
//   actually flags as fade setups.
// ═════════════════════════════════════════════════
var array<int>   crossBars = array.new_int(0)
var array<int>   crossDirs = array.new_int(0)
var array<float> crossPrc  = array.new_float(0)
var array<float> crossAtr  = array.new_float(0)

if passFilter
    array.push(crossBars, bar_index)
    array.push(crossDirs, crossUp ? 1 : -1)
    array.push(crossPrc,  close)
    array.push(crossAtr,  atr)

var int   totalCrosses = 0
var int   revSuccess   = 0
var float sumRevAtr    = 0.0
var int   todayCount   = 0
var int   strongToday  = 0

isSessionStart = timeframe.change("D")
if isSessionStart
    todayCount  := 0
    strongToday := 0
if crossEvt
    todayCount += 1
if strongCross
    strongToday += 1

if array.size(crossBars) > 0
    i = 0
    while i < array.size(crossBars)
        b = array.get(crossBars, i)
        if bar_index - b >= followBars
            d  = array.get(crossDirs, i)
            p0 = array.get(crossPrc,  i)
            a0 = array.get(crossAtr,  i)
            // reversion = move OPPOSITE to the cross direction (back toward VWAP)
            revDisp = (p0 - close) * d
            totalCrosses += 1
            if revDisp > 0
                revSuccess += 1
            sumRevAtr += (a0 > 0 ? revDisp / a0 : 0)
            array.remove(crossBars, i)
            array.remove(crossDirs, i)
            array.remove(crossPrc,  i)
            array.remove(crossAtr,  i)
        else
            i += 1

// ═════════════════════════════════════════════════
// ACTION STANCE — fade context from distance to VWAP
// ═════════════════════════════════════════════════
vwapDistAtr = math.abs(close - vwapLine) / atr
aboveVwap   = close > vwapLine
string actionTxt = strongCross ? "Review fade setup" : vwapDistAtr >= 2.0 ? "Fade toward VWAP" : vwapDistAtr >= 1.0 ? "Watch for reversion" : "Wait for cross"
color actionCol = strongCross ? (crossUp ? bearColor : bullColor) : vwapDistAtr >= 2.0 ? (aboveVwap ? bearColor : bullColor) : vwapDistAtr >= 1.0 ? neutralColor : panelLabelCol

// ═════════════════════════════════════════════════
// CROSS LABELS
// ═════════════════════════════════════════════════
if showX and passFilter
    col      = crossUp ? bullColor : bearColor
    crossTxt = crossUp ? "UP CROSS" : "DOWN CROSS"
    scoreTxt = crossTxt + "\nFADE Q" + str.tostring(math.round(liveScore100))
    yPos     = crossUp ? low - atr * 0.55 : high + atr * 0.55
    sty      = crossUp ? label.style_label_up : label.style_label_down
    label.new(bar_index, yPos, scoreTxt,
         style     = sty,
         color     = col,
         textcolor = f_text_on(col),
         size      = lblSize)

barcolor(colorBars and passFilter and crossUp   ? bullColor :
         colorBars and passFilter and crossDown ? bearColor : na)

// ═════════════════════════════════════════════════
// REVERSION TARGET (single active — latest high-quality cross only)
//   Projects one ATR back toward VWAP, in the opposite direction of the cross.
// ═════════════════════════════════════════════════
var line  tgtLine = na
var label tgtLbl  = na

if showTarget and passFilter
    if not na(tgtLine)
        line.delete(tgtLine)
        label.delete(tgtLbl)
    dir = crossUp ? 1 : -1
    tgt = close - atr * dir
    tgtLine := line.new(bar_index, close, bar_index + targetBars, tgt,
         color = color.new(accentColor, 40),
         style = line.style_dotted,
         width = 1)
    tgtLbl := label.new(bar_index + targetBars, tgt, "VWAP TARGET  " + str.tostring(tgt, format.mintick),
         style     = label.style_label_left,
         color     = color.new(accentColor, 20),
         textcolor = f_text_on(accentColor),
         size      = lblSize)

// ═════════════════════════════════════════════════
// FADE ZONE (single active + centered badge)
// ═════════════════════════════════════════════════
var box   qZone    = na
var line  qZoneMid = na
var label qZoneLbl = na

if showZone and strongCross
    if not na(qZone)
        box.delete(qZone)
        line.delete(qZoneMid)
        label.delete(qZoneLbl)
    half = atr * zoneATR * 0.5
    zTop = close + half
    zBot = close - half
    zCol = crossUp ? bullColor : bearColor
    qZone := box.new(bar_index, zTop, bar_index + zoneBars, zBot,
         border_color = color.new(zCol, 10),
         border_width = 1,
         bgcolor      = color.new(zCol, 92))
    qZoneMid := line.new(bar_index, close, bar_index + zoneBars, close,
         color = color.new(zCol, 40),
         style = line.style_dashed,
         width = 2)
    zoneSideTxt = crossUp ? "UP-CROSS FADE" : "DOWN-CROSS FADE"
    qZoneLbl := label.new(bar_index + int(zoneBars / 2), close,
         zoneSideTxt + "\nZONE Q" + str.tostring(math.round(liveScore100)),
         style     = label.style_label_center,
         color     = color.new(zCol, 30),
         textcolor = f_text_on(zCol),
         size      = lblSize)

// ═════════════════════════════════════════════════
// PANEL / DASHBOARD
// ═════════════════════════════════════════════════
var table pnl = na

if barstate.islast and showPanel
    if not na(pnl)
        table.delete(pnl)
    pnl := table.new(f_panelPos(panelPos), 2, 8,
         bgcolor      = panelBg,
         border_color = panelBorder,
         border_width = 1,
         frame_color  = panelBorder,
         frame_width  = 1)

    table.merge_cells(pnl, 0, 0, 1, 0)
    table.cell(pnl, 0, 0, "AG Pro VWAP Cross Flow Engine",
         text_color = headerText,
         bgcolor    = headerBg,
         text_size  = pnlSize)

    revRate = totalCrosses > 0 ? revSuccess / totalCrosses * 100.0 : 0.0
    avgRev  = totalCrosses > 0 ? sumRevAtr / totalCrosses          : 0.0
    rateCol = revRate >= 60 ? bullColor : revRate >= 40 ? neutralColor : bearColor

    table.cell(pnl, 0, 1, todayLabelTxt, text_color = panelLabelCol, text_size = pnlSize, bgcolor = panelBg, text_halign = text.align_center)
    table.cell(pnl, 1, 1, str.tostring(todayCount), text_color = panelValueCol, text_size = pnlSize, bgcolor = panelBg, text_halign = text.align_right)

    table.cell(pnl, 0, 2, strongLabelTxt, text_color = panelLabelCol, text_size = pnlSize, bgcolor = panelBg, text_halign = text.align_center)
    table.cell(pnl, 1, 2, str.tostring(strongToday), text_color = accentColor, text_size = pnlSize, bgcolor = panelBg, text_halign = text.align_right)

    table.cell(pnl, 0, 3, "Fade Win Rate", text_color = panelLabelCol, text_size = pnlSize, bgcolor = panelBg, text_halign = text.align_center)
    table.cell(pnl, 1, 3, str.tostring(revRate, "#.0") + "%", text_color = rateCol, text_size = pnlSize, bgcolor = panelBg, text_halign = text.align_right)

    table.cell(pnl, 0, 4, "Avg Reversion", text_color = panelLabelCol, text_size = pnlSize, bgcolor = panelBg, text_halign = text.align_center)
    table.cell(pnl, 1, 4, str.tostring(avgRev, "#.00") + " ATR", text_color = accentColor, text_size = pnlSize, bgcolor = panelBg, text_halign = text.align_right)

    table.cell(pnl, 0, 5, "Fade Sample", text_color = panelLabelCol, text_size = pnlSize, bgcolor = panelBg, text_halign = text.align_center)
    table.cell(pnl, 1, 5, str.tostring(totalCrosses), text_color = panelValueCol, text_size = pnlSize, bgcolor = panelBg, text_halign = text.align_right)

    biasTxt = close > vwapLine ? "ABOVE VWAP" : "BELOW VWAP"
    biasCol = close > vwapLine ? bullColor    : bearColor
    table.cell(pnl, 0, 6, "Current Bias", text_color = panelLabelCol, text_size = pnlSize, bgcolor = panelBg, text_halign = text.align_center)
    table.cell(pnl, 1, 6, biasTxt, text_color = biasCol, text_size = pnlSize, bgcolor = panelBg, text_halign = text.align_right)

    table.cell(pnl, 0, 7, "Action", text_color = panelLabelCol, text_size = pnlSize, bgcolor = panelBg, text_halign = text.align_center)
    table.cell(pnl, 1, 7, actionTxt, text_color = actionCol, text_size = pnlSize, bgcolor = panelBg, text_halign = text.align_right)

// ═════════════════════════════════════════════════
// ALERTS
// ═════════════════════════════════════════════════
// Sigma-band reach: price extends to a 2 SD band
reachedUpperBand = showBands and close >= upper2 and close[1] < upper2[1]
reachedLowerBand = showBands and close <= lower2 and close[1] > lower2[1]

alertcondition(passFilter and crossUp,
     "VWAP Fade Setup (Up-Cross)",
     "VWAP Cross Flow Engine: High-energy bullish cross - potential fade back toward VWAP.")
alertcondition(passFilter and crossDown,
     "VWAP Fade Setup (Down-Cross)",
     "VWAP Cross Flow Engine: High-energy bearish cross - potential fade back toward VWAP.")
alertcondition(strongCross,
     "Strong VWAP Fade Setup (>=70)",
     "VWAP Cross Flow Engine: Strong high-energy cross - fade zone anchored.")
alertcondition(reachedUpperBand,
     "Price Reached +2 SD Band",
     "VWAP Cross Flow Engine: Price extended to the upper 2 SD band.")
alertcondition(reachedLowerBand,
     "Price Reached -2 SD Band",
     "VWAP Cross Flow Engine: Price extended to the lower 2 SD band.")
````
