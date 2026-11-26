# SuperTrend 3D [NeBlok]

- url: https://www.tradingview.com/script/fu7cwW8H-SuperTrend-3D-NeBlok/
- type: indicator
- pine_id: PUB;d0624d66dbcb4bc6932a5de47d12510a
- version: 1.0

## Description

SuperTrend 3D [NeBlok]

OVERVIEW
SuperTrend 3D is an original, from-scratch implementation of the classic ATR-based SuperTrend concept (originally developed by Olivier Seban). It keeps the simple, proven core — a volatility-based trailing line that flips between bullish and bearish — and adds signal grading, higher-timeframe confirmation, R-multiple target projection, a live dashboard, and a layered 3D-style visual design so trend state is readable at a glance.

The line itself behaves exactly like a standard SuperTrend. Everything added on top is designed to help you judge the QUALITY of each flip and manage the trade after it, not to replace the core logic.


HOW THE SUPERTREND WORKS
- Two bands are calculated around the source price (hl2 by default): one below price at Source − (Multiplier × ATR), one above at Source + (Multiplier × ATR).
- In an uptrend, only the lower band is shown and it can only move UP. In a downtrend, only the upper band is shown and it can only move DOWN. This ratchet effect is what makes it a trailing stop.
- When price crosses the active band, the trend flips and the opposite band takes over.


READING THE CHART
- Green line below price = bullish trend. Red line above price = bearish trend.
- The glowing line is the active trailing stop. The darker "extruded" edge behind it is purely visual depth; the bright line is the actual level.
- The gradient fill between the line and price shows the trend zone — strongest at the line, fading toward price.
- Dotted connectors and a small dot mark each flip, bridging the old band to the new one.
- BUY / SELL labels appear on flips, with a letter grade and stars (see Signal Grading below).
- Candle coloring (optional) follows the trend. In "Trend + Volume" mode, high-volume candles are solid and low-volume candles are faded, so you can see whether a move has participation behind it.


SIGNAL GRADING
Every flip is scored against up to four independent checks. Each check that passes earns one star:
1. ADX strength — ADX is at or above your threshold (default 20), meaning the market is actually trending rather than chopping.
2. Relative volume — volume on the flip bar is at or above your multiple of average volume (default 1.2x).
3. Flip conviction — price closed beyond the old band by at least a set fraction of ATR (default 0.25 ATR), filtering flips that barely poke through.
4. Higher-timeframe agreement — a SuperTrend on a higher timeframe (default 240) points the same direction.

Grades:
- A+ = every enabled check passed
- A = 75% or more passed
- B = 50% or more passed
- C = less than 50% passed

Important: the line ALWAYS flips according to standard SuperTrend rules. Grading does not change the line — it only tells you how much confirmation stands behind each flip. Use "Min points to show a signal" to hide lower-quality labels and alerts if you only want to see stronger setups.


RISK PROJECTION (R TARGETS)
On every flip, the script draws:
- An Entry line at the close of the flip bar.
- Target lines at 1R, 2R and 3R (adjustable), where 1R = the distance from entry to the SuperTrend line on the flip bar.
When price reaches a target, its line turns solid and a ✓ appears on the label. This gives you an immediate read on whether a trend is paying out relative to the risk the SuperTrend stop implied at entry.


DASHBOARD
- Trend — current direction.
- Bars in trend — how many bars since the last flip.
- Trailing stop — the current SuperTrend level.
- Distance — how far price is from the stop, in ATR and in percent. Large distances mean price is extended from its stop; small distances mean the stop is close.
- Open R since flip — current profit or loss measured in R from the last flip entry.
- Last signal — direction, grade, and stars of the most recent flip.
- HTF trend — direction of the higher-timeframe SuperTrend.
- Volatility — where current ATR ranks versus its recent history (Low / Normal / High), plus the multiplier currently in use.


HOW TO USE IT
Trend filter: Only take trades in the direction of the line. Many traders use SuperTrend purely as a bias filter for other entry methods.

Entries: Treat higher grades (A+ / A) as the flips worth acting on. C-grade flips often occur in chop and are more likely to reverse quickly.

Stops: The line is a volatility-based trailing stop. A common approach is to place or trail your stop at (or just beyond) the line and exit when it flips.

Targets: Use the R lines to plan partial exits, or to evaluate whether your setups typically reach 1R, 2R, or 3R before the trend flips.

Higher timeframe: Set the HTF timeframe ABOVE your chart timeframe (for example, 15m chart with 60 or 240 HTF). Trading flips that agree with the higher timeframe is one of the most effective ways to reduce whipsaws.


SETTINGS
Core SuperTrend
- ATR Length / ATR Multiplier — standard SuperTrend inputs. Higher multiplier = wider stop, fewer flips. Lower = tighter stop, more flips.
- Source — price used for the band center (hl2 default).
- ATR Smoothing — RMA (classic), SMA, EMA, or WMA.
- Flip Trigger — "Close" flips only on a closing cross (fewer false flips). "Wick" flips as soon as a wick crosses the band (faster, noisier, can trigger intrabar).

Adaptive Volatility (optional)
- When enabled, the multiplier is scaled by where current ATR ranks versus its own history over the lookback. Quiet markets get a tighter band; volatile markets get a wider one. Scale range is adjustable (default 0.8x to 1.3x).

Signal Quality Grading
- Toggle and tune each of the four checks, and set the minimum points required to display a signal.

Signals / 3D Visuals / Risk Projection / Dashboard
- Label sizes, colors, glow, extrusion depth, gradient fill, flip connectors, candle coloring, target multiples, and dashboard position and size. Every visual layer can be turned off.


ALERTS
- "ST3D Buy (raw flip)", "ST3D Sell (raw flip)", and "ST3D Any flip" fire on every flip.
- For graded alerts that respect your "Min points" filter, create an alert and choose "Any alert() function call." These messages include the ticker, timeframe, price, stop level, and grade.
- All alerts are set to fire once per bar close.


REPAINTING AND LIMITATIONS
- The higher-timeframe check uses the last CONFIRMED higher-timeframe bar, so it does not repaint. The tradeoff is that it can lag by up to one higher-timeframe bar.
- As with any SuperTrend, a flip on the current live bar is not final until that bar closes. Wait for bar close before acting on a signal.
- The relative volume check requires volume data. On symbols with no volume, that check will never pass.
- SuperTrend is a trend-following tool. It performs best in trending markets and will produce whipsaws in sideways, range-bound conditions. Grading and HTF agreement reduce this but do not eliminate it.
- If "Candle coloring" is on, it will override bar colors from other indicators.


DISCLAIMER
This script is provided for educational and informational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any security, futures contract, cryptocurrency, or other financial instrument.

Trading involves substantial risk of loss and is not suitable for every investor. You can lose more than your initial investment when trading leveraged products such as futures and options. Past performance, whether actual or indicated by historical signals, is not indicative of future results. No indicator can predict the market, and signals will produce losing trades.

All trading decisions are your own. Always do your own research, test any tool thoroughly on your own markets and timeframes, and consider consulting a licensed financial professional before making trading decisions. The author accepts no liability for any losses resulting from the use of this script.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NeBlok

// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NeBlok
//
// SuperTrend 3D [NeBlok]
// Original implementation of the classic ATR SuperTrend concept, rebuilt from scratch with:
//   • Selectable ATR smoothing, source, and close/wick flip trigger
//   • Optional volatility-adaptive multiplier (ATR percentile regime)
//   • Signal grading (ADX, relative volume, flip conviction, non-repainting HTF agreement)
//   • Faux-3D rendering: neon glow, extruded band, gradient trend fill, drop-shadow labels
//   • R-multiple target projection from each flip, with hit tracking
//   • Live dashboard and embedded alerts

//@version=6
indicator("SuperTrend 3D [NeBlok]", shorttitle = "ST3D [NeBlok]", overlay = true, max_labels_count = 500, max_lines_count = 500)

// ═══════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════
const string G_CORE  = "Core SuperTrend"
const string G_ADAPT = "Adaptive Volatility"
const string G_Q     = "Signal Quality Grading"
const string G_S     = "Signals"
const string G_V     = "3D Visuals"
const string G_R     = "Risk Projection"
const string G_D     = "Dashboard"

atrLen  = input.int(10, "ATR Length", minval = 1, group = G_CORE)
mult    = input.float(3.0, "ATR Multiplier", minval = 0.1, step = 0.1, group = G_CORE)
src     = input.source(hl2, "Source", group = G_CORE)
atrType = input.string("RMA", "ATR Smoothing", options = ["RMA", "SMA", "EMA", "WMA"], group = G_CORE)
flipOn  = input.string("Close", "Flip Trigger", options = ["Close", "Wick"], group = G_CORE,
     tooltip = "Close = trend flips only when price closes through the band (fewer whipsaws). Wick = flips as soon as a wick pierces the band (faster, noisier, fires intrabar).")

useAdapt = input.bool(false, "Adaptive multiplier", group = G_ADAPT,
     tooltip = "Scales the multiplier by where current ATR ranks versus its own recent history. Quiet regime = tighter band, volatile regime = wider band.")
adaptLen = input.int(100, "Regime lookback", minval = 20, group = G_ADAPT)
adaptMin = input.float(0.8, "Scale at low volatility", minval = 0.1, step = 0.05, group = G_ADAPT)
adaptMax = input.float(1.3, "Scale at high volatility", minval = 0.1, step = 0.05, group = G_ADAPT)

useAdx  = input.bool(true, "ADX strength", inline = "adx", group = G_Q)
adxLen  = input.int(14, "", minval = 1, inline = "adx", group = G_Q)
adxThr  = input.float(20.0, "≥", minval = 0, inline = "adx", group = G_Q)
useVol  = input.bool(true, "Relative volume", inline = "vol", group = G_Q)
volLen  = input.int(20, "", minval = 1, inline = "vol", group = G_Q)
volThr  = input.float(1.2, "≥", minval = 0, step = 0.1, inline = "vol", group = G_Q)
useConv = input.bool(true, "Flip conviction (ATR)", inline = "conv", group = G_Q)
convThr = input.float(0.25, "≥", minval = 0, step = 0.05, inline = "conv", group = G_Q)
useHTF  = input.bool(true, "HTF SuperTrend agrees", inline = "htf", group = G_Q,
     tooltip = "Non-repainting: uses the last CONFIRMED higher-timeframe bar. Set the timeframe above your chart timeframe.")
htfTf   = input.timeframe("240", "", inline = "htf", group = G_Q)
minPts  = input.int(0, "Min points to show a signal", minval = 0, maxval = 4, group = G_Q,
     tooltip = "The line always flips. This only hides Buy/Sell labels and alerts that score below this many points.")

showSig   = input.bool(true, "Show Buy / Sell labels", group = G_S)
showGrade = input.bool(true, "Show grade on labels", group = G_S)
sigSize   = input.string("Large", "Label size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_S)

bullCol   = input.color(#00E5A0, "Bull", inline = "col", group = G_V)
bearCol   = input.color(#FF3D71, "Bear", inline = "col", group = G_V)
showGlow  = input.bool(true, "Neon glow", group = G_V)
show3D    = input.bool(true, "3D extrusion", group = G_V)
depthAtr  = input.float(0.35, "Extrusion depth (ATR)", minval = 0.05, step = 0.05, group = G_V)
showFill  = input.bool(true, "Gradient trend fill", group = G_V)
showLinks = input.bool(true, "Flip connectors", group = G_V)
barMode   = input.string("Trend + Volume", "Candle coloring", options = ["Off", "Trend", "Trend + Volume"], group = G_V,
     tooltip = "Trend + Volume fades low-volume candles and makes high-volume candles solid.")

showRisk = input.bool(true, "Project R targets from last flip", group = G_R,
     tooltip = "Entry = close of the flip bar. 1R = distance from entry to the SuperTrend line on that bar.")
r1 = input.float(1.0, "Target 1 (R)", minval = 0, step = 0.5, group = G_R)
r2 = input.float(2.0, "Target 2 (R)", minval = 0, step = 0.5, group = G_R)
r3 = input.float(3.0, "Target 3 (R)", minval = 0, step = 0.5, group = G_R)
riskSize = input.string("Normal", "Entry / target label size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_R)

showDash = input.bool(true, "Show dashboard", group = G_D)
dashPos  = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Middle Right", "Bottom Right", "Bottom Left"], group = G_D)
dashSize = input.string("Large", "Text size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_D)

// ═══════════════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════════════
f_shade(color c, float k) =>
    color.rgb(color.r(c) * k, color.g(c) * k, color.b(c) * k)

f_grade(int pts, int maxP) =>
    string g = ""
    if maxP > 0
        float q = float(pts) / maxP
        g := q >= 1.0 ? "A+" : q >= 0.75 ? "A" : q >= 0.5 ? "B" : "C"
    g

f_stars(int pts, int maxP) =>
    string s = ""
    if maxP > 0
        for i = 1 to maxP
            s += i <= pts ? "★" : "☆"
    s

f_size(string s) =>
    s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : s == "Large" ? size.large : s == "Huge" ? size.huge : size.small

// Standalone SuperTrend direction for the higher-timeframe request
f_stTrend(float s, float m, int len) =>
    float a  = ta.atr(len)
    float u  = s - m * a
    float d  = s + m * a
    var float uT = na
    var float dT = na
    var int   t  = 1
    float pu = nz(uT, u)
    float pd = nz(dT, d)
    uT := close[1] > pu ? math.max(u, pu) : u
    dT := close[1] < pd ? math.min(d, pd) : d
    t  := t == -1 and close > pd ? 1 : t == 1 and close < pu ? -1 : t
    t

// ═══════════════════════════════════════════════════════════════════════════
// VOLATILITY
// ═══════════════════════════════════════════════════════════════════════════
float trueRange = ta.tr(true)
float atrRma = ta.rma(trueRange, atrLen)
float atrSma = ta.sma(trueRange, atrLen)
float atrEma = ta.ema(trueRange, atrLen)
float atrWma = ta.wma(trueRange, atrLen)
float atrVal = atrType == "SMA" ? atrSma : atrType == "EMA" ? atrEma : atrType == "WMA" ? atrWma : atrRma

float volRank = nz(ta.percentrank(atrVal, adaptLen), 50)
float scale   = useAdapt ? adaptMin + (adaptMax - adaptMin) * volRank / 100 : 1.0
float m       = mult * scale

// ═══════════════════════════════════════════════════════════════════════════
// CORE SUPERTREND
// ═══════════════════════════════════════════════════════════════════════════
float basicUp = src - m * atrVal
float basicDn = src + m * atrVal

var float upT   = na
var float dnT   = na
var int   trend = 1

float prevUp = nz(upT, basicUp)
float prevDn = nz(dnT, basicDn)

upT := close[1] > prevUp ? math.max(basicUp, prevUp) : basicUp
dnT := close[1] < prevDn ? math.min(basicDn, prevDn) : basicDn

float hiTrig = flipOn == "Wick" ? high : close
float loTrig = flipOn == "Wick" ? low  : close

int prevTrend = trend
trend := prevTrend == -1 and hiTrig > prevDn ? 1 : prevTrend == 1 and loTrig < prevUp ? -1 : prevTrend

bool  buySig  = trend == 1  and prevTrend == -1
bool  sellSig = trend == -1 and prevTrend == 1
float stLine  = trend == 1 ? upT : dnT

// ═══════════════════════════════════════════════════════════════════════════
// SIGNAL GRADING
// ═══════════════════════════════════════════════════════════════════════════
[diPlus, diMinus, adxVal] = ta.dmi(adxLen, adxLen)

float avgVol = ta.sma(nz(volume), volLen)
float relVol = avgVol > 0 ? nz(volume) / avgVol : 1.0

// [1] + lookahead_on = last confirmed HTF bar, no repainting
int htfRaw   = request.security(syminfo.tickerid, htfTf, f_stTrend(src, mult, atrLen)[1], lookahead = barmerge.lookahead_on)
int htfTrend = useHTF ? htfRaw : 0

float convBuy  = atrVal > 0 ? (close - prevDn) / atrVal : 0.0
float convSell = atrVal > 0 ? (prevUp - close) / atrVal : 0.0

int maxPts  = (useAdx ? 1 : 0) + (useVol ? 1 : 0) + (useConv ? 1 : 0) + (useHTF ? 1 : 0)
int buyPts  = (useAdx and adxVal >= adxThr ? 1 : 0) + (useVol and relVol >= volThr ? 1 : 0) + (useConv and convBuy  >= convThr ? 1 : 0) + (useHTF and htfTrend == 1  ? 1 : 0)
int sellPts = (useAdx and adxVal >= adxThr ? 1 : 0) + (useVol and relVol >= volThr ? 1 : 0) + (useConv and convSell >= convThr ? 1 : 0) + (useHTF and htfTrend == -1 ? 1 : 0)

int  showThresh = math.min(minPts, maxPts)
bool showBuy    = buySig  and buyPts  >= showThresh
bool showSell   = sellSig and sellPts >= showThresh

// ═══════════════════════════════════════════════════════════════════════════
// STATE TRACKING
// ═══════════════════════════════════════════════════════════════════════════
var int    barsIn     = 0
var float  entryPx    = na
var float  entryStop  = na
var string lastSigTxt = "—"
var color  lastSigCol = color.gray

barsIn := buySig or sellSig ? 0 : barsIn + 1

if buySig or sellSig
    entryPx   := close
    entryStop := stLine

if buySig
    lastSigTxt := "BUY " + f_grade(buyPts, maxPts) + " " + f_stars(buyPts, maxPts)
    lastSigCol := bullCol
if sellSig
    lastSigTxt := "SELL " + f_grade(sellPts, maxPts) + " " + f_stars(sellPts, maxPts)
    lastSigCol := bearCol

// ═══════════════════════════════════════════════════════════════════════════
// 3D RENDERING
// ═══════════════════════════════════════════════════════════════════════════
color bullDark = f_shade(bullCol, 0.35)
color bearDark = f_shade(bearCol, 0.35)

float upLine  = trend == 1  ? upT : na
float dnLine  = trend == -1 ? dnT : na
float depth   = depthAtr * nz(atrVal)
float upShad  = show3D and trend == 1  ? upT - depth : na
float dnShad  = show3D and trend == -1 ? dnT + depth : na
float bodyMid = (open + close) / 2

// Invisible anchors for fills
pMid = plot(bodyMid, "Body mid anchor", display = display.none, editable = false)
pUpA = plot(upLine,  "Up anchor",       display = display.none, editable = false, style = plot.style_linebr)
pDnA = plot(dnLine,  "Down anchor",     display = display.none, editable = false, style = plot.style_linebr)

// Extrusion back edges (the "depth" side of the ribbon)
pUpS = plot(upShad, "Up extrusion edge",   color.new(bullDark, 30), 1, plot.style_linebr)
pDnS = plot(dnShad, "Down extrusion edge", color.new(bearDark, 30), 1, plot.style_linebr)

// Gradient trend fill: strong at the line, fading toward price
fill(pMid, pUpA, bodyMid, upLine, showFill ? color.new(bullCol, 97) : na, showFill ? color.new(bullCol, 80) : na, title = "Bull trend fill")
fill(pDnA, pMid, dnLine, bodyMid, showFill ? color.new(bearCol, 80) : na, showFill ? color.new(bearCol, 97) : na, title = "Bear trend fill")

// Extrusion face: bright at the line, dark at the back edge
fill(pUpA, pUpS, upLine, upShad, color.new(bullCol, 50), color.new(bullDark, 85), title = "Bull extrusion")
fill(pDnS, pDnA, dnShad, dnLine, color.new(bearDark, 85), color.new(bearCol, 50), title = "Bear extrusion")

// Neon glow layers → main line → specular highlight
plot(showGlow ? upLine : na, "Up glow outer",   color.new(bullCol, 88), 9, plot.style_linebr)
plot(showGlow ? upLine : na, "Up glow inner",   color.new(bullCol, 68), 5, plot.style_linebr)
plot(upLine,                 "SuperTrend Up",   bullCol,                2, plot.style_linebr)
plot(showGlow ? upLine : na, "Up highlight",    color.new(color.white, 65), 1, plot.style_linebr)

plot(showGlow ? dnLine : na, "Down glow outer", color.new(bearCol, 88), 9, plot.style_linebr)
plot(showGlow ? dnLine : na, "Down glow inner", color.new(bearCol, 68), 5, plot.style_linebr)
plot(dnLine,                 "SuperTrend Down", bearCol,                2, plot.style_linebr)
plot(showGlow ? dnLine : na, "Down highlight",  color.new(color.white, 65), 1, plot.style_linebr)

plotshape(buySig  ? upT : na, "Flip dot up",   shape.circle, location.absolute, bullCol, size = size.tiny)
plotshape(sellSig ? dnT : na, "Flip dot down", shape.circle, location.absolute, bearCol, size = size.tiny)

plot(stLine, "Trailing Stop", color.gray, display = display.data_window)

// Flip connectors: bridge the old band to the new one
if showLinks and buySig
    line.new(bar_index - 1, prevDn, bar_index, upT, color = color.new(bullCol, 30), width = 2, style = line.style_dotted)
if showLinks and sellSig
    line.new(bar_index - 1, prevUp, bar_index, dnT, color = color.new(bearCol, 30), width = 2, style = line.style_dotted)

// Drop-shadow signal labels
string lblSize = f_size(sigSize)
float  shadOff = 0.12 * nz(atrVal)

if showSig and showBuy
    string txt = "BUY" + (showGrade and maxPts > 0 ? "\n" + f_grade(buyPts, maxPts) + " " + f_stars(buyPts, maxPts) : "")
    float  y   = upT - 0.1 * nz(atrVal)
    label.new(bar_index, y - shadOff, txt, color = color.new(#000000, 35), textcolor = color.new(#000000, 100), style = label.style_label_up, size = lblSize)
    label.new(bar_index, y, txt, color = bullCol, textcolor = #0B0E14, style = label.style_label_up, size = lblSize)

if showSig and showSell
    string txt = "SELL" + (showGrade and maxPts > 0 ? "\n" + f_grade(sellPts, maxPts) + " " + f_stars(sellPts, maxPts) : "")
    float  y   = dnT + 0.1 * nz(atrVal)
    label.new(bar_index, y - shadOff, txt, color = color.new(#000000, 35), textcolor = color.new(#000000, 100), style = label.style_label_down, size = lblSize)
    label.new(bar_index, y, txt, color = bearCol, textcolor = color.white, style = label.style_label_down, size = lblSize)

// Candle coloring
color trendCol  = trend == 1 ? bullCol : bearCol
int   volTransp = relVol >= 2.0 ? 0 : relVol >= 1.3 ? 20 : relVol >= 0.8 ? 45 : 65
color candleCol = barMode == "Off" ? na : barMode == "Trend" ? trendCol : color.new(trendCol, volTransp)
barcolor(candleCol)

// ═══════════════════════════════════════════════════════════════════════════
// RISK PROJECTION (R targets from the last flip)
// ═══════════════════════════════════════════════════════════════════════════
var array<line>  rLn  = array.new<line>()
var array<label> rLb  = array.new<label>()
var array<float> rLv  = array.new<float>()
var array<bool>  rHit = array.new<bool>()
var line  eLn = na
var label eLb = na

if showRisk and (buySig or sellSig)
    for l in rLn
        line.delete(l)
    for lb in rLb
        label.delete(lb)
    rLn.clear()
    rLb.clear()
    rLv.clear()
    rHit.clear()
    line.delete(eLn)
    label.delete(eLb)

    float risk = math.abs(entryPx - entryStop)
    color c    = trend == 1 ? bullCol : bearCol

    eLn := line.new(bar_index, entryPx, bar_index, entryPx, color = color.new(color.gray, 20), style = line.style_dashed)
    eLb := label.new(bar_index + 2, entryPx, "Entry " + str.tostring(entryPx, format.mintick), style = label.style_label_left,
         color = color.new(#000000, 100), textcolor = color.gray, size = f_size(riskSize))

    for r in array.from(r1, r2, r3)
        if r > 0 and risk > 0
            float tp = entryPx + trend * r * risk
            rLn.push(line.new(bar_index, tp, bar_index, tp, color = color.new(c, 35), style = line.style_dotted))
            rLb.push(label.new(bar_index + 2, tp, str.tostring(r, "#.##") + "R  " + str.tostring(tp, format.mintick),
                 style = label.style_label_left, color = color.new(#000000, 100), textcolor = color.new(c, 10), size = f_size(riskSize)))
            rLv.push(tp)
            rHit.push(false)

if showRisk and not na(eLn)
    eLn.set_x2(bar_index)
    eLb.set_x(bar_index + 2)
    int n = rLn.size()
    if n > 0
        for i = 0 to n - 1
            line  ln = rLn.get(i)
            label lb = rLb.get(i)
            float tp = rLv.get(i)
            ln.set_x2(bar_index)
            lb.set_x(bar_index + 2)
            if not rHit.get(i) and not (buySig or sellSig)
                bool hit = trend == 1 ? high >= tp : low <= tp
                if hit
                    rHit.set(i, true)
                    ln.set_style(line.style_solid)
                    lb.set_text(lb.get_text() + "  ✓")

// ═══════════════════════════════════════════════════════════════════════════
// DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════
string dashPosition = dashPos == "Top Left" ? position.top_left : dashPos == "Middle Right" ? position.middle_right :
     dashPos == "Bottom Right" ? position.bottom_right : dashPos == "Bottom Left" ? position.bottom_left : position.top_right
string dashTxt = f_size(dashSize)

var table dash = showDash ? table.new(dashPosition, 2, 9, bgcolor = color.new(#0B0E14, 8), frame_color = color.new(#2A2E39, 0),
     frame_width = 2, border_color = color.new(#1E222D, 0), border_width = 1) : na

f_row(table t, int r, string k, string v, color vc) =>
    table.cell(t, 0, r, k, text_color = color.new(#9AA3B2, 0), text_size = dashTxt, text_halign = text.align_left)
    table.cell(t, 1, r, v, text_color = vc, text_size = dashTxt, text_halign = text.align_right)

if showDash and barstate.islast
    color tc     = trend == 1 ? bullCol : bearCol
    float dist   = atrVal > 0 ? (close - stLine) * trend / atrVal : na
    float pct    = close != 0 ? math.abs(close - stLine) / close * 100 : na
    float risk   = math.abs(entryPx - entryStop)
    float rNow   = risk > 0 ? (close - entryPx) * trend / risk : na
    string rTxt  = na(rNow) ? "—" : (rNow >= 0 ? "+" : "") + str.tostring(rNow, "#.##") + "R"
    string htfTx = not useHTF ? "Off" : (htfTrend == 1 ? "▲ BULL" : htfTrend == -1 ? "▼ BEAR" : "—") + " (" + htfTf + ")"
    color htfCol = not useHTF ? color.gray : htfTrend == 1 ? bullCol : htfTrend == -1 ? bearCol : color.gray
    string regime = volRank < 33 ? "Low" : volRank < 67 ? "Normal" : "High"

    dash.set_frame_color(color.new(tc, 20))
    table.cell(dash, 0, 0, "SuperTrend 3D", text_color = color.white, bgcolor = color.new(tc, 55), text_size = dashTxt, text_halign = text.align_left)
    table.cell(dash, 1, 0, "[NeBlok]", text_color = color.white, bgcolor = color.new(tc, 55), text_size = dashTxt, text_halign = text.align_right)
    f_row(dash, 1, "Trend", trend == 1 ? "▲ BULL" : "▼ BEAR", tc)
    f_row(dash, 2, "Bars in trend", str.tostring(barsIn), color.white)
    f_row(dash, 3, "Trailing stop", str.tostring(stLine, format.mintick), tc)
    f_row(dash, 4, "Distance", str.tostring(dist, "#.##") + " ATR · " + str.tostring(pct, "#.##") + "%", color.white)
    f_row(dash, 5, "Open R since flip", rTxt, na(rNow) ? color.gray : rNow >= 0 ? bullCol : bearCol)
    f_row(dash, 6, "Last signal", lastSigTxt, lastSigCol)
    f_row(dash, 7, "HTF trend", htfTx, htfCol)
    f_row(dash, 8, "Volatility", regime + " (" + str.tostring(volRank, "#") + "%) · x" + str.tostring(m, "#.##"), color.white)

// ═══════════════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════════════
alertcondition(buySig,            "ST3D Buy (raw flip)",  "SuperTrend 3D [NeBlok]: BUY {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(sellSig,           "ST3D Sell (raw flip)", "SuperTrend 3D [NeBlok]: SELL {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(buySig or sellSig, "ST3D Any flip",        "SuperTrend 3D [NeBlok]: trend flip on {{ticker}} ({{interval}}) @ {{close}}")

if showBuy
    alert("ST3D [NeBlok] BUY " + syminfo.ticker + " " + timeframe.period + " @ " + str.tostring(close, format.mintick) +
         " | Stop " + str.tostring(upT, format.mintick) + " | Grade " + f_grade(buyPts, maxPts) + " (" + str.tostring(buyPts) + "/" + str.tostring(maxPts) + ")",
         alert.freq_once_per_bar_close)
if showSell
    alert("ST3D [NeBlok] SELL " + syminfo.ticker + " " + timeframe.period + " @ " + str.tostring(close, format.mintick) +
         " | Stop " + str.tostring(dnT, format.mintick) + " | Grade " + f_grade(sellPts, maxPts) + " (" + str.tostring(sellPts) + "/" + str.tostring(maxPts) + ")",
         alert.freq_once_per_bar_close)
````
