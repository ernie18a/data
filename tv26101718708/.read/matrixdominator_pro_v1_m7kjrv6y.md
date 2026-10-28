# MatrixDominator Pro v1

- url: https://www.tradingview.com/script/m7kJrv6y-MatrixDominator-Pro-v1/
- type: indicator
- pine_id: PUB;edb061ff170144638d65988f9f9a7161
- version: 3.0

## Description

PriceIntent™MatrixDominator Pro — Smart Money Execution Engine
PriceIntent™MatrixDominator Pro is a professional-grade TradingView tool designed to identify high-probability trading opportunities with institutional precision. Built for serious traders, PI™MatrixDominator Pro automatically detects premium market zones and evaluates trade setups using a proprietary multi-factor confluence engine. The system filters market noise and highlights only the most promising opportunities, helping traders focus on high-quality entries. When conditions align, PI™MatrixDominator Pro generates clear BUY and SELL signals with predefined Entry, Stop Loss, and Take Profit targets, allowing for structured and disciplined trade execution. A built-in live dashboard keeps you informed in real time, displaying market bias, active trade conditions, and system status directly on the chart. Unlike traditional indicators that simply draw zones, PI™MatrixDominator Pro acts as a complete decision engine, analyzing the market and presenting traders with structured opportunities. Designed for traders who want clarity, structure, and precision — not just more indicators on their chart.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// © PriceIntent™ — All Rights Reserved
//@version=6
indicator("PriceIntent™MatrixDominator Pro", shorttitle="PI™MatrixDominator Pro", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500, explicit_plot_zorder=true)

// ╔══════════════════════════════════════════════════════════════╗
// ║              PriceIntent™MatrixDominator Pro                 ║
// ║              Smart Money Execution Engine v4.0               ║
// ╚══════════════════════════════════════════════════════════════╝

// ── BRAND PALETTE ──
color PI_GOLD     = #FFB300
color PI_BUY      = #00C853
color PI_SELL     = #D50000
color PI_TEAL     = #00897B
color PI_ORANGE   = #EF6C00
color PI_PURPLE   = #7B1FA2
color PI_BG_DARK  = #0D1117
color PI_TEXT     = #C9D1D9
color PI_TEXT_DIM = #6E7681
color PI_BORDER   = #30363D
color PI_FIB      = #0288D1
color PI_RLC      = #00B8D4

// ════════════════════════════════════════
// INPUTS
// ════════════════════════════════════════
string GRP_EXEC = "═══ EXECUTION ═══"
mode         = input.string("Intraday", "Execution Mode", options=["Scalp", "Intraday"], group=GRP_EXEC, tooltip="Scalp = tighter params. Intraday = higher confluence.")
minScoreIn   = input.int(5, "Minimum OB Score (0-10)", minval=1, maxval=10, group=GRP_EXEC)
signalExpiry = input.int(50, "Signal Expiry (bars)", minval=10, maxval=200, group=GRP_EXEC, tooltip="Signal panel shows EXPIRED after this many bars if TP/SL not hit.")

string GRP_RISK = "═══ RISK MANAGEMENT ═══"
atrLen       = input.int(14, "ATR Length", minval=1, group=GRP_RISK)
slBuffer     = input.float(0.3, "SL Buffer (ATR mult)", minval=0.05, maxval=2.0, step=0.05, group=GRP_RISK)
rrTarget1    = input.float(2.0, "TP1 Risk:Reward", minval=0.5, maxval=10.0, step=0.5, group=GRP_RISK)
rrTarget2    = input.float(4.0, "TP2 Risk:Reward", minval=1.0, maxval=20.0, step=0.5, group=GRP_RISK)
winTrackBars = input.int(80, "Win Track Lookback (bars)", minval=20, maxval=300, group=GRP_RISK)

string GRP_STRUCT = "═══ STRUCTURE ═══"
swingLen      = input.int(5, "Swing Detection Length", minval=1, maxval=20, group=GRP_STRUCT)
impulseLen    = input.int(3, "Impulse Lookback", minval=1, maxval=10, group=GRP_STRUCT)
obMaxAge      = input.int(150, "OB Max Age (bars)", minval=20, maxval=500, group=GRP_STRUCT)
obMaxCount    = input.int(20, "Max Active OBs", minval=5, maxval=50, group=GRP_STRUCT)
obMaxATR      = input.float(15.0, "OB Max Distance (ATR)", minval=2.0, maxval=50.0, group=GRP_STRUCT)
obMaxHeight   = input.float(1.8, "OB Max Height (ATR)", minval=0.5, maxval=10.0, step=0.5, group=GRP_STRUCT, tooltip="Caps OB box height to prevent oversized boxes on large candles.")
bosCooldown   = input.int(12, "Shift Cooldown (bars)", minval=1, maxval=50, group=GRP_STRUCT)
useReclaim    = input.bool(true, "Enable OB RLC", group=GRP_STRUCT, tooltip="Invalidated OBs that get RLC become active again with a score boost.")
reclaimWindow = input.int(15, "RLC Window (bars)", minval=3, maxval=50, group=GRP_STRUCT, tooltip="Max bars after invalidation for a reclaim to count.")
reclaimBoost  = input.int(2, "RLC Score Boost", minval=1, maxval=3, group=GRP_STRUCT)

string GRP_SESSION = "═══ SESSION FILTER ═══"
useSession    = input.bool(true, "Enable Session Filter", group=GRP_SESSION)
sessLondon    = input.bool(true, "London (02:00-10:00 EST)", group=GRP_SESSION)
sessNewYork   = input.bool(true, "New York (08:00-16:00 EST)", group=GRP_SESSION)
sessAsian     = input.bool(false, "Asian (19:00-02:00 EST)", group=GRP_SESSION)
sessHighlight = input.bool(false, "Highlight Sessions", group=GRP_SESSION)

string GRP_HTF = "═══ HTF BIAS ═══"
useHTF       = input.bool(true, "Enable HTF Bias Filter", group=GRP_HTF)
htfTF1       = input.timeframe("60", "HTF 1", group=GRP_HTF)
htfTF2       = input.timeframe("240", "HTF 2", group=GRP_HTF)
htfTF3       = input.timeframe("D", "HTF 3", group=GRP_HTF)
htfEmaFast   = input.int(9, "HTF EMA Fast", minval=1, group=GRP_HTF)
htfEmaSlow   = input.int(21, "HTF EMA Slow", minval=1, group=GRP_HTF)
useHTFCandle = input.bool(true, "HTF Candle Color Bonus (+1)", group=GRP_HTF, tooltip="Adds +1 to OB score when HTF1 candle color aligns with trade direction.")

string GRP_HTFOB = "═══ HTF ORDER BLOCKS ═══"
showHTFOB   = input.bool(true, "Show HTF OBs", group=GRP_HTFOB, tooltip="Draws higher timeframe Order Blocks as dashed zones. 15m OBs inside HTF OBs get +1 score boost.")
htfOBTF     = input.timeframe("240", "HTF OB Timeframe", group=GRP_HTFOB, tooltip="The higher timeframe to pull OBs from. Default 4H.")
htfOBMax    = input.int(4, "Max HTF OBs", minval=1, maxval=10, group=GRP_HTFOB)
htfOBMaxAge = input.int(100, "HTF OB Max Age (HTF bars)", minval=10, maxval=500, group=GRP_HTFOB)

string GRP_FIB = "═══ FIBONACCI / ZONES ═══"
showFibLevels = input.bool(true, "Show Fib Levels", group=GRP_FIB, tooltip="Draws 38.2%, 50%, 61.8% retracement lines on the 50-bar range.")
showOTE       = input.bool(true, "Show OTE Zone (62-79%)", group=GRP_FIB, tooltip="Highlights the Optimal Trade Entry zone used in ICT/SMC methodology.")

fibLookback   = input.int(50, "Fib Range Lookback", minval=20, maxval=200, group=GRP_FIB)

string GRP_FVG = "═══ FVG SETTINGS ═══"
fvgMode     = input.string("Normal", "FVG Filter", options=["Strict", "Normal", "All"], group=GRP_FVG, tooltip="Strict = requires displacement. Normal = any gap > min size. All = every gap.")
fvgMinATR   = input.float(0.25, "FVG Min Gap Size (ATR)", minval=0.0, maxval=2.0, step=0.05, group=GRP_FVG, tooltip="Minimum gap height in ATR units. Set 0 for no filter.")
fvgMaxAge   = input.int(100, "FVG Max Age (bars)", minval=10, maxval=500, group=GRP_FVG, tooltip="FVGs older than this get pruned.")
fvgMaxCount = input.int(8, "Max FVG Boxes", minval=3, maxval=50, group=GRP_FVG)

string GRP_REGIME = "═══ MARKET REGIME ═══"
showRegime     = input.bool(true, "Show Market Regime", group=GRP_REGIME, tooltip="Detects Compression, Normal, or Expansion regimes using ATR ratio.")
regimeLookback = input.int(20, "Regime ATR Lookback", minval=5, maxval=100, group=GRP_REGIME, tooltip="Short ATR period for regime comparison.")
regimeLongLen  = input.int(100, "Regime Baseline Length", minval=20, maxval=300, group=GRP_REGIME, tooltip="Long ATR period used as the volatility baseline.")
compressionThr = input.float(0.7, "Compression Threshold", minval=0.3, maxval=0.95, step=0.05, group=GRP_REGIME, tooltip="ATR ratio below this = Compression (chop zone). Default 0.7.")
expansionThr   = input.float(1.4, "Expansion Threshold", minval=1.05, maxval=3.0, step=0.05, group=GRP_REGIME, tooltip="ATR ratio above this = Expansion (trending). Default 1.4.")
blockInChop    = input.bool(true, "Block Signals in Compression", group=GRP_REGIME, tooltip="Prevents OB signals from firing during compression/chop regimes.")
showChopBG     = input.bool(true, "Highlight Chop Zones", group=GRP_REGIME, tooltip="Tints chart background orange during compression regimes.")
showConfluence = input.bool(true, "Show Confluence Breakdown", group=GRP_REGIME, tooltip="Displays a breakdown panel showing which factors scored on the last signal.")

string GRP_VIS = "═══ DISPLAY ═══"
showOBBoxes     = input.bool(true, "Order Block Boxes", group=GRP_VIS)
showFVGBoxes    = input.bool(true, "FVG Boxes", group=GRP_VIS)
showSweepLabels = input.bool(true, "Liquidity Sweep Labels", group=GRP_VIS)
showEntryLabels = input.bool(true, "Entry Labels", group=GRP_VIS)
showTPSLLines   = input.bool(true, "TP/SL Lines", group=GRP_VIS)
showStructure   = input.bool(true, "Structure Breaks", group=GRP_VIS)
showDashboard   = input.bool(true, "Dashboard", group=GRP_VIS)

showBiasBG      = input.bool(false, "Bias Background", group=GRP_VIS)
showWatermark   = input.bool(true, "Watermark", group=GRP_VIS)
useLargeLabels  = input.bool(false, "Large Labels", group=GRP_VIS)

// ════════════════════════════════════════
// COMPUTED
// ════════════════════════════════════════
atr      = ta.atr(atrLen)
dispMult = mode == "Scalp" ? 1.0 : 1.5
minScore = mode == "Scalp" ? math.min(minScoreIn, 4) : minScoreIn
lblSize  = useLargeLabels ? size.large : size.normal

tfMins        = timeframe.in_seconds() / 60
isHTF         = tfMins >= 240
isDaily       = tfMins >= 1440
tfScale       = math.max(tfMins / 15.0, 1.0)
scaledExpiry  = math.max(math.round(signalExpiry / tfScale), 10)
scaledBOSCool = isDaily ? math.max(math.round(bosCooldown / tfScale), 2) : bosCooldown

isLightTheme = color.r(chart.bg_color) > 150 and color.g(chart.bg_color) > 150 and color.b(chart.bg_color) > 150
var table themeWarning = na
if isLightTheme and barstate.islast
    themeWarning := table.new(position.top_center, 1, 1, bgcolor=color.new(PI_SELL, 10), border_color=PI_SELL, border_width=2, frame_color=PI_SELL, frame_width=1)
    table.cell(themeWarning, 0, 0, "⚠ PI™MatrixDominator Pro is optimized for DARK theme  →  Settings → Appearance → Background → #131722", text_color=color.white, text_size=size.normal, bgcolor=color.new(PI_SELL, 10))

// ════════════════════════════════════════
// MARKET REGIME: COMPRESSION / NORMAL / EXPANSION
// Uses the ratio of a short ATR to a long baseline ATR.
// ratio < compressionThr  → COMPRESSION (chop, no-trade zone)
// ratio > expansionThr    → EXPANSION   (trending, best for signals)
// otherwise               → NORMAL
// ════════════════════════════════════════
atrShort      = ta.atr(regimeLookback)
atrLong       = ta.atr(regimeLongLen)
atrRatio      = atrLong > 0 ? atrShort / atrLong : 1.0
isCompression = atrRatio < compressionThr
isExpansion   = atrRatio > expansionThr
isNormal      = not isCompression and not isExpansion
noTrade       = isCompression and blockInChop
regimeStr     = isCompression ? "COMPRESSION" : isExpansion ? "EXPANSION" : "NORMAL"
regimeClr     = isCompression ? PI_ORANGE : isExpansion ? PI_BUY : PI_TEXT

bgcolor(showChopBG and isCompression ? color.new(PI_ORANGE, 96) : na, title="Chop Zone BG")

// ════════════════════════════════════════
// SESSIONS
// ════════════════════════════════════════
hourEST   = hour(time, "America/New_York")
inLondon  = hourEST >= 2 and hourEST < 10
inNY      = hourEST >= 8 and hourEST < 16
inAsian   = hourEST >= 19 or hourEST < 2
sessionOK = isDaily or not useSession or (sessLondon and inLondon) or (sessNewYork and inNY) or (sessAsian and inAsian)

bgcolor(sessHighlight and inLondon ? color.new(#1565C0, 94) : na, title="London BG")
bgcolor(sessHighlight and inNY ? color.new(#2E7D32, 94) : na, title="New York BG")
bgcolor(sessHighlight and inAsian ? color.new(#6A1B9A, 94) : na, title="Asian BG")

// ════════════════════════════════════════
// HTF BIAS
// ════════════════════════════════════════
f_htfBias(simple string tf) =>
    emaF = request.security(syminfo.tickerid, tf, ta.ema(close, htfEmaFast))
    emaS = request.security(syminfo.tickerid, tf, ta.ema(close, htfEmaSlow))
    emaF > emaS ? 1 : emaF < emaS ? -1 : 0

htfB1std   = f_htfBias(htfTF1)
htfB2std   = f_htfBias(htfTF2)
htfB3std   = f_htfBias(htfTF3)
htfB1daily = f_htfBias("W")
htfB2daily = f_htfBias("M")
htfB3daily = f_htfBias("3M")

htfBias1   = isDaily ? htfB1daily : htfB1std
htfBias2   = isDaily ? htfB2daily : htfB2std
htfBias3   = isDaily ? htfB3daily : htfB3std
htfSum     = htfBias1 + htfBias2 + htfBias3
htfBullish = htfSum >= 2
htfBearish = htfSum <= -2
htfNeutral = not htfBullish and not htfBearish

htfAligned(int dir) =>
    not useHTF or (dir == 1 and htfBullish) or (dir == -1 and htfBearish) or htfNeutral

htfClose1     = request.security(syminfo.tickerid, isDaily ? "W" : htfTF1, close)
htfOpen1      = request.security(syminfo.tickerid, isDaily ? "W" : htfTF1, open)
htfCandleBull = htfClose1 > htfOpen1
htfCandleBear = htfClose1 < htfOpen1

// ════════════════════════════════════════
// HTF ORDER BLOCKS
// ════════════════════════════════════════
f_htfOBData() =>
    htfAtr  = ta.atr(14)
    htfBody = math.abs(close - open)
    htfDisp = htfBody > htfAtr * 0.8
    bullOB  = htfDisp and close > open and close[1] < open[1]
    bullTop = bullOB ? high[1] : na
    bullBot = bullOB ? low[1] : na
    bearOB  = htfDisp and close < open and close[1] > open[1]
    bearTop = bearOB ? high[1] : na
    bearBot = bearOB ? low[1] : na
    [bullOB, bullTop, bullBot, bearOB, bearTop, bearBot, time]

htfOBTFMins = timeframe.in_seconds(htfOBTF) / 60
needsScale  = tfMins >= htfOBTFMins

[htfBullOBstd, htfBullTopStd, htfBullBotStd, htfBearOBstd, htfBearTopStd, htfBearBotStd, htfTimeStd] = request.security(syminfo.tickerid, htfOBTF, f_htfOBData())
[htfBullOBd, htfBullTopD, htfBullBotD, htfBearOBd, htfBearTopD, htfBearBotD, htfTimeD]               = request.security(syminfo.tickerid, "D", f_htfOBData())
[htfBullOBw, htfBullTopW, htfBullBotW, htfBearOBw, htfBearTopW, htfBearBotW, htfTimeW]               = request.security(syminfo.tickerid, "W", f_htfOBData())

string htfOBActualTF = htfOBTF
bool   htfBullOB  = htfBullOBstd
float  htfBullTop = htfBullTopStd
float  htfBullBot = htfBullBotStd
bool   htfBearOB  = htfBearOBstd
float  htfBearTop = htfBearTopStd
float  htfBearBot = htfBearBotStd

if isDaily
    htfBullOB  := htfBullOBw
    htfBullTop := htfBullTopW
    htfBullBot := htfBullBotW
    htfBearOB  := htfBearOBw
    htfBearTop := htfBearTopW
    htfBearBot := htfBearBotW
    htfOBActualTF := "W"
else if needsScale
    htfBullOB  := htfBullOBd
    htfBullTop := htfBullTopD
    htfBullBot := htfBullBotD
    htfBearOB  := htfBearOBd
    htfBearTop := htfBearTopD
    htfBearBot := htfBearBotD
    htfOBActualTF := "D"

type HTFOB
    box   bx
    float top
    float bot
    int   dir
    int   barBorn
    bool  active

var array<HTFOB> htfOBs = array.new<HTFOB>()
var float prevHTFBullTop = na
var float prevHTFBearTop = na

if showHTFOB
    if htfBullOB and not na(htfBullTop) and htfBullTop != prevHTFBullTop
        rawH   = htfBullTop - htfBullBot
        capH   = nz(atr) * 5.0
        adjTop = rawH > capH and capH > 0 ? htfBullBot + capH : htfBullTop
        if htfOBs.size() < htfOBMax * 2
            bx = box.new(bar_index, adjTop, bar_index + 50, htfBullBot, bgcolor=color.new(PI_BUY, 90), border_color=color.new(PI_BUY, 40), border_width=2, border_style=line.style_dashed, text="HTF " + htfOBActualTF, text_color=color.new(PI_BUY, 40), text_size=size.small, text_halign=text.align_left, text_valign=text.align_top)
            htfOBs.push(HTFOB.new(bx, adjTop, htfBullBot, 1, bar_index, true))
        prevHTFBullTop := htfBullTop
    if htfBearOB and not na(htfBearTop) and htfBearTop != prevHTFBearTop
        rawH   = htfBearTop - htfBearBot
        capH   = nz(atr) * 5.0
        adjBot = rawH > capH and capH > 0 ? htfBearTop - capH : htfBearBot
        if htfOBs.size() < htfOBMax * 2
            bx = box.new(bar_index, htfBearTop, bar_index + 50, adjBot, bgcolor=color.new(PI_SELL, 90), border_color=color.new(PI_SELL, 40), border_width=2, border_style=line.style_dashed, text="HTF " + htfOBActualTF, text_color=color.new(PI_SELL, 40), text_size=size.small, text_halign=text.align_left, text_valign=text.align_top)
            htfOBs.push(HTFOB.new(bx, htfBearTop, adjBot, -1, bar_index, true))
        prevHTFBearTop := htfBearTop

if showHTFOB and htfOBs.size() > 0
    for i = htfOBs.size() - 1 to 0
        h   = htfOBs.get(i)
        if not h.active
            continue
        age = bar_index - h.barBorn
        box.set_right(h.bx, bar_index + 50)
        if h.dir == 1 and close < h.bot
            h.active := false
            box.set_bgcolor(h.bx, color.new(PI_TEXT_DIM, 95))
            box.set_border_color(h.bx, color.new(PI_TEXT_DIM, 85))
            box.set_text_color(h.bx, color.new(PI_TEXT_DIM, 80))
        if h.dir == -1 and close > h.top
            h.active := false
            box.set_bgcolor(h.bx, color.new(PI_TEXT_DIM, 95))
            box.set_border_color(h.bx, color.new(PI_TEXT_DIM, 85))
            box.set_text_color(h.bx, color.new(PI_TEXT_DIM, 80))
        if age > htfOBMaxAge * 16
            h.active := false
            box.delete(h.bx)
            htfOBs.remove(i)
            continue
    if htfOBs.size() > htfOBMax * 4
        for i = 0 to math.min(htfOBs.size() - 1, 3)
            if htfOBs.size() > 0
                old = htfOBs.get(0)
                if not old.active
                    box.delete(old.bx)
                    htfOBs.remove(0)

f_inHTFOB(int dir) =>
    bool result = false
    if showHTFOB and htfOBs.size() > 0
        for i = 0 to htfOBs.size() - 1
            h = htfOBs.get(i)
            if h.active and h.dir == dir and close >= h.bot and close <= h.top
                result := true
                break
    result

htfOBBullConf = f_inHTFOB(1)
htfOBBearConf = f_inHTFOB(-1)

// ════════════════════════════════════════
// SWING STRUCTURE
// ════════════════════════════════════════
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

var float lastHH = na
var float lastLL = na
var int   trend  = 0

if not na(ph)
    lastHH := ph
if not na(pl)
    lastLL := pl

bullBreak = not na(lastHH) and close > lastHH and close[1] <= lastHH
bearBreak = not na(lastLL) and close < lastLL and close[1] >= lastLL

if bullBreak
    trend := 1
if bearBreak
    trend := -1

var int lastBullBOS = 0
var int lastBearBOS = 0

if showStructure and bullBreak and bar_index - lastBullBOS > scaledBOSCool
    label.new(bar_index, low, "SHIFT ▲", style=label.style_label_up, textcolor=PI_BUY, color=color.new(PI_BUY, 65), size=size.tiny)
    lastBullBOS := bar_index
    alert("PI BULL SHIFT ▲ | " + syminfo.ticker + " " + timeframe.period + " | Price: " + str.tostring(close, format.mintick) + " | Broke above: " + str.tostring(lastHH, format.mintick), alert.freq_once_per_bar)

if showStructure and bearBreak and bar_index - lastBearBOS > scaledBOSCool
    label.new(bar_index, high, "SHIFT ▼", style=label.style_label_down, textcolor=PI_SELL, color=color.new(PI_SELL, 65), size=size.tiny)
    lastBearBOS := bar_index
    alert("PI BEAR SHIFT ▼ | " + syminfo.ticker + " " + timeframe.period + " | Price: " + str.tostring(close, format.mintick) + " | Broke below: " + str.tostring(lastLL, format.mintick), alert.freq_once_per_bar)

bgcolor(showBiasBG and trend == 1 ? color.new(PI_BUY, 96) : na, title="Bull Bias BG")
bgcolor(showBiasBG and trend == -1 ? color.new(PI_SELL, 96) : na, title="Bear Bias BG")

// ════════════════════════════════════════
// DISPLACEMENT & VOLUME
// ════════════════════════════════════════
body               = math.abs(close - open)
displacement       = body > atr * dispMult
volSMA             = ta.sma(volume, 20)
volSpike           = volume > volSMA * 1.5
candleRange        = high - low
deltaRaw           = candleRange > 0 ? ((close - low) - (high - close)) / candleRange : 0.0
deltaSMA           = ta.sma(deltaRaw, 5)
deltaBull          = deltaSMA > 0.15
deltaBear          = deltaSMA < -0.15
deltaStrong        = math.abs(deltaSMA) > 0.3
strongDisplacement = body > atr * dispMult * 1.5

// ════════════════════════════════════════
// LIQUIDITY SWEEPS
// ════════════════════════════════════════
bullSweep      = not na(lastHH) and high > lastHH and close < lastHH
bearSweep      = not na(lastLL) and low < lastLL and close > lastLL
validBullSweep = bullSweep and displacement
validBearSweep = bearSweep and displacement

if showSweepLabels and validBullSweep
    label.new(bar_index, high, "SWEEP ▼", style=label.style_label_down, textcolor=PI_SELL, color=color.new(PI_SELL, 65), size=size.tiny, tooltip="Liquidity swept above highs — bearish signal")

if showSweepLabels and validBearSweep
    label.new(bar_index, low, "SWEEP ▲", style=label.style_label_up, textcolor=PI_BUY, color=color.new(PI_BUY, 65), size=size.tiny, tooltip="Liquidity swept below lows — bullish signal")

// ════════════════════════════════════════
// FVG ENGINE
// ════════════════════════════════════════
bullFVG     = low > high[2]
bearFVG     = high < low[2]
bullGapSize = bullFVG ? low - high[2] : 0.0
bearGapSize = bearFVG ? low[2] - high : 0.0
fvgMinSize  = nz(atr) * fvgMinATR
fvgBullOK   = bullFVG and bullGapSize >= fvgMinSize
fvgBearOK   = bearFVG and bearGapSize >= fvgMinSize

if fvgMode == "Strict"
    fvgBullOK := fvgBullOK and displacement
    fvgBearOK := fvgBearOK and displacement
else if fvgMode == "All"
    fvgBullOK := bullFVG
    fvgBearOK := bearFVG

type FVG
    box   bx
    float top
    float bot
    int   dir
    bool  active
    int   barBorn

var array<FVG> fvgs = array.new<FVG>()

if showFVGBoxes and fvgBullOK and fvgs.size() < fvgMaxCount
    fvgBx = box.new(bar_index - 1, low, bar_index + 20, high[2], bgcolor=color.new(PI_TEAL, 88), border_color=color.new(PI_TEAL, 60), border_width=1, text="FVG", text_color=color.new(PI_TEAL, 45), text_size=size.tiny)
    fvgs.push(FVG.new(fvgBx, low, high[2], 1, true, bar_index))

if showFVGBoxes and fvgBearOK and fvgs.size() < fvgMaxCount
    fvgBx = box.new(bar_index - 1, low[2], bar_index + 20, high, bgcolor=color.new(PI_PURPLE, 88), border_color=color.new(PI_PURPLE, 60), border_width=1, text="FVG", text_color=color.new(PI_PURPLE, 45), text_size=size.tiny)
    fvgs.push(FVG.new(fvgBx, low[2], high, -1, true, bar_index))

if fvgs.size() > 0
    for i = fvgs.size() - 1 to 0
        if i >= fvgs.size()
            continue
        f = fvgs.get(i)
        if f.active
            filled = (f.dir == 1 and close < f.bot) or (f.dir == -1 and close > f.top)
            if filled
                f.active := false
                box.set_bgcolor(f.bx, color.new(PI_TEXT_DIM, 95))
                box.set_border_color(f.bx, color.new(PI_TEXT_DIM, 90))
                fvgs.set(i, f)
            else
                box.set_right(f.bx, bar_index + 3)
        fvgMid = (f.top + f.bot) / 2
        tooFar = nz(atr) > 0 ? math.abs(close - fvgMid) > atr * obMaxATR : false
        tooOld = bar_index - f.barBorn > fvgMaxAge
        if (not f.active and tooOld) or tooFar
            box.delete(f.bx)
            fvgs.remove(i)

// ════════════════════════════════════════
// FIBONACCI / PREMIUM-DISCOUNT / OTE
// ════════════════════════════════════════
hhVal      = ta.highest(high, fibLookback)
llVal      = ta.lowest(low, fibLookback)
rng50      = hhVal - llVal
eqZone     = rng50 > 0 ? (close - llVal) / rng50 : 0.5
inDiscount = eqZone < 0.382
inPremium  = eqZone > 0.618

fib382 = llVal + rng50 * 0.382
fib500 = llVal + rng50 * 0.5
fib618 = llVal + rng50 * 0.618
fib705 = llVal + rng50 * 0.705
fib790 = llVal + rng50 * 0.79

var line fibLine382 = na
var line fibLine500 = na
var line fibLine618 = na
var label fibLbl382 = na
var label fibLbl500 = na
var label fibLbl618 = na

if showFibLevels and rng50 > 0
    if not na(fibLine382)
        line.delete(fibLine382)
        line.delete(fibLine500)
        line.delete(fibLine618)
        label.delete(fibLbl382)
        label.delete(fibLbl500)
        label.delete(fibLbl618)
    startBar   = bar_index - fibLookback
    fibLine382 := line.new(startBar, fib382, bar_index + 5, fib382, color=color.new(PI_FIB, 40), style=line.style_dotted, width=2)
    fibLine500 := line.new(startBar, fib500, bar_index + 5, fib500, color=color.new(PI_ORANGE, 30), style=line.style_dashed, width=2)
    fibLine618 := line.new(startBar, fib618, bar_index + 5, fib618, color=color.new(PI_FIB, 40), style=line.style_dotted, width=2)
    fibLbl382  := label.new(bar_index + 6, fib382, "S1",  style=label.style_label_left, textcolor=PI_FIB,    color=color.new(PI_FIB, 75),    size=size.tiny)
    fibLbl500  := label.new(bar_index + 6, fib500, "MID", style=label.style_label_left, textcolor=PI_ORANGE, color=color.new(PI_ORANGE, 75), size=size.tiny)
    fibLbl618  := label.new(bar_index + 6, fib618, "R1",  style=label.style_label_left, textcolor=PI_FIB,    color=color.new(PI_FIB, 75),    size=size.tiny)

var box oteBox = na
if showOTE and rng50 > 0
    if not na(oteBox)
        box.delete(oteBox)
    startBar = bar_index - fibLookback
    oteBox  := box.new(startBar, fib790, bar_index + 5, fib618, bgcolor=color.new(PI_GOLD, 93), border_color=color.new(PI_GOLD, 70), border_width=1, text="KEY", text_color=color.new(PI_GOLD, 50), text_size=size.tiny, text_halign=text.align_left, text_valign=text.align_top)

// ════════════════════════════════════════
// ORDER BLOCK UDT
// ════════════════════════════════════════
type OB
    box   bx
    float top
    float bot
    int   dir
    int   score
    bool  active
    int   barBorn
    bool  triggered
    float entryPrice
    float slPrice
    float tp1Price
    float tp2Price
    int   triggerBar
    int   result
    bool  reclaimed
    int   invalidBar

var array<OB> obs = array.new<OB>()

// ════════════════════════════════════════
// OB SCORING (0-10)
// ════════════════════════════════════════
f_scoreOB(int dir, bool hasSweep, bool hasFVG, bool hasVol, bool strongDisp, bool htfCandleOK, bool inHTFOBZone, bool deltaOK) =>
    int s = 2
    s += hasSweep    ? 2 : 0
    s += hasFVG      ? 1 : 0
    s += (dir == 1 and trend == 1) or (dir == -1 and trend == -1) ? 1 : 0
    s += htfAligned(dir) and useHTF ? 1 : 0
    s += hasVol      ? 1 : 0
    s += (dir == 1 and inDiscount) or (dir == -1 and inPremium) ? 1 : 0
    s += strongDisp  ? 1 : 0
    s += htfCandleOK ? 1 : 0
    s += inHTFOBZone ? 1 : 0
    s += deltaOK     ? 1 : 0
    math.min(s, 10)

f_obBg(int score, int dir) =>
    score >= 8 ? color.new(PI_GOLD, 55) : score >= 5 ? (dir == 1 ? color.new(PI_BUY, 68) : color.new(PI_SELL, 68)) : color.new(PI_TEXT_DIM, 85)

f_obBorder(int score, int dir) =>
    score >= 8 ? color.new(PI_GOLD, 20) : score >= 5 ? (dir == 1 ? color.new(PI_BUY, 35) : color.new(PI_SELL, 35)) : color.new(PI_TEXT_DIM, 60)

f_tooltip(string dir, int score, float entry, float sl, float tp1, float tp2, float risk) =>
    string htfL  = htfBullish ? "BULL" : htfBearish ? "BEAR" : "NEUT"
    string sessL = inLondon ? "London" : inNY ? "NY" : inAsian ? "Asian" : "Off"
    "PI " + dir + " | " + str.tostring(score) + "/10 | E:" + str.tostring(entry, format.mintick) + " SL:" + str.tostring(sl, format.mintick) + " TP1:" + str.tostring(tp1, format.mintick) + " TP2:" + str.tostring(tp2, format.mintick) + " | HTF:" + htfL + " | " + sessL

// ════════════════════════════════════════
// CONFLUENCE BREAKDOWN STATE
// Persists the factors from the most recent signal for the breakdown panel
// ════════════════════════════════════════
var bool   cfSweep      = false
var bool   cfFVG        = false
var bool   cfTrend      = false
var bool   cfHTF        = false
var bool   cfVol        = false
var bool   cfZone       = false
var bool   cfStrongDisp = false
var bool   cfHTFCandle  = false
var bool   cfHTFOBZone  = false
var bool   cfDelta      = false
var int    cfScore      = 0
var string cfDir        = "NONE"
var bool   cfRLC        = false
var string cfRegime     = "NORMAL"

// ════════════════════════════════════════
// OB CREATION
// ════════════════════════════════════════
maxBoxH = nz(atr) * obMaxHeight

if bar_index > impulseLen + 5
    if displacement and close > open and close[impulseLen + 1] < open[impulseLen + 1]
        rawTop = high[impulseLen + 1]
        rawBot = low[impulseLen + 1]
        rawH   = rawTop - rawBot
        obBot  = rawBot
        obTop  = rawH > maxBoxH and maxBoxH > 0 ? rawBot + maxBoxH : rawTop
        score  = f_scoreOB(1, validBearSweep, fvgBullOK, volSpike, strongDisplacement, useHTFCandle and htfCandleBull, htfOBBullConf, deltaBull)
        if showOBBoxes and obs.size() < obMaxCount
            obBar = bar_index - (impulseLen + 1)
            bx    = box.new(obBar, obTop, bar_index + 20, obBot, bgcolor=f_obBg(score, 1), border_color=f_obBorder(score, 1), border_width=score >= 8 ? 2 : 1, text=str.tostring(score) + "10", text_color=score >= 8 ? PI_GOLD : PI_TEXT_DIM, text_size=size.tiny, text_halign=text.align_right, text_valign=text.align_top)
            obs.push(OB.new(bx, obTop, obBot, 1, score, true, bar_index, false, na, na, na, na, na, 0, false, na))

    if displacement and close < open and close[impulseLen + 1] > open[impulseLen + 1]
        rawTop = high[impulseLen + 1]
        rawBot = low[impulseLen + 1]
        rawH   = rawTop - rawBot
        obTop  = rawTop
        obBot  = rawH > maxBoxH and maxBoxH > 0 ? rawTop - maxBoxH : rawBot
        score  = f_scoreOB(-1, validBullSweep, fvgBearOK, volSpike, strongDisplacement, useHTFCandle and htfCandleBear, htfOBBearConf, deltaBear)
        if showOBBoxes and obs.size() < obMaxCount
            obBar = bar_index - (impulseLen + 1)
            bx    = box.new(obBar, obTop, bar_index + 20, obBot, bgcolor=f_obBg(score, -1), border_color=f_obBorder(score, -1), border_width=score >= 8 ? 2 : 1, text=str.tostring(score) + "10", text_color=score >= 8 ? PI_GOLD : PI_TEXT_DIM, text_size=size.tiny, text_halign=text.align_right, text_valign=text.align_top)
            obs.push(OB.new(bx, obTop, obBot, -1, score, true, bar_index, false, na, na, na, na, na, 0, false, na))

// ════════════════════════════════════════
// EXECUTION & WIN/LOSS
// ════════════════════════════════════════
var int    totalBuySignals  = 0
var int    totalSellSignals = 0
var int    totalWins        = 0
var int    totalLosses      = 0
var float  lastBuyEntry     = na
var float  lastSellEntry    = na
var float  lastBuySL        = na
var float  lastSellSL       = na
var float  lastBuyTP1       = na
var float  lastSellTP1      = na
var float  lastBuyTP2       = na
var float  lastSellTP2      = na
var string lastSignalDir    = "NONE"
var int    lastSignalBar    = 0
var int    lastSignalResult = 0

var bool triggerBuyAlert     = false
var bool triggerSellAlert    = false
var bool triggerGoldAlert    = false
var bool triggerReclaimAlert = false
var bool triggerReclaimBuy   = false
var bool triggerReclaimSell  = false

triggerBuyAlert     := false
triggerSellAlert    := false
triggerGoldAlert    := false
triggerReclaimAlert := false
triggerReclaimBuy   := false
triggerReclaimSell  := false

signalAge    = bar_index - lastSignalBar
signalActive = lastSignalDir != "NONE" and lastSignalBar > 0 and signalAge <= scaledExpiry and lastSignalResult == 0

if lastSignalResult == 0 and lastSignalBar > 0
    if lastSignalDir == "BUY" and not na(lastBuyTP1) and not na(lastBuySL)
        if high >= lastBuyTP1
            lastSignalResult := 1
        else if low <= lastBuySL
            lastSignalResult := -1
    if lastSignalDir == "SELL" and not na(lastSellTP1) and not na(lastSellSL)
        if low <= lastSellTP1
            lastSignalResult := 1
        else if high >= lastSellSL
            lastSignalResult := -1
    if signalAge > scaledExpiry and lastSignalResult == 0
        lastSignalResult := -2

if obs.size() > 0
    for i = obs.size() - 1 to 0
        if i >= obs.size()
            continue
        o     = obs.get(i)
        obMid = (o.top + o.bot) / 2

        tooFar = nz(atr) > 0 and math.abs(close - obMid) > atr * obMaxATR
        tooOld = bar_index - o.barBorn > obMaxAge
        if tooFar or (tooOld and not o.active and o.result != 0)
            box.delete(o.bx)
            obs.remove(i)
            continue
        if tooOld and o.active
            o.active := false
            box.set_bgcolor(o.bx, color.new(PI_TEXT_DIM, 95))
            box.set_border_style(o.bx, line.style_dotted)
            box.set_text(o.bx, "EXPIRED")
            box.set_text_color(o.bx, color.new(PI_TEXT_DIM, 70))
            obs.set(i, o)

        if o.triggered and o.result == 0 and not na(o.triggerBar)
            if bar_index - o.triggerBar <= winTrackBars
                if o.dir == 1 and high >= o.tp1Price
                    o.result    := 1
                    totalWins   += 1
                    obs.set(i, o)
                else if o.dir == 1 and low <= o.slPrice
                    o.result    := -1
                    totalLosses += 1
                    obs.set(i, o)
                if o.dir == -1 and low <= o.tp1Price
                    o.result    := 1
                    totalWins   += 1
                    obs.set(i, o)
                else if o.dir == -1 and high >= o.slPrice
                    o.result    := -1
                    totalLosses += 1
                    obs.set(i, o)
            else if bar_index - o.triggerBar > winTrackBars and o.result == 0
                o.result := -2
                obs.set(i, o)

        if o.active and o.dir == 1 and close < o.bot
            o.active     := false
            o.invalidBar := bar_index
            box.set_bgcolor(o.bx, color.new(PI_TEXT_DIM, 95))
            box.set_border_style(o.bx, line.style_dotted)
            box.set_text(o.bx, "")
            obs.set(i, o)
        if o.active and o.dir == -1 and close > o.top
            o.active     := false
            o.invalidBar := bar_index
            box.set_bgcolor(o.bx, color.new(PI_TEXT_DIM, 95))
            box.set_border_style(o.bx, line.style_dotted)
            box.set_text(o.bx, "")
            obs.set(i, o)

        if useReclaim and not o.active and not o.triggered and not o.reclaimed and not na(o.invalidBar)
            withinWindow = bar_index - o.invalidBar <= reclaimWindow
            if withinWindow
                reclaimedBull = o.dir == 1 and close > o.top
                reclaimedBear = o.dir == -1 and close < o.bot
                if reclaimedBull or reclaimedBear
                    o.active    := true
                    o.reclaimed := true
                    o.score     := math.min(o.score + reclaimBoost, 10)
                    box.set_bgcolor(o.bx, color.new(PI_RLC, 65))
                    box.set_border_color(o.bx, color.new(PI_RLC, 40))
                    box.set_border_style(o.bx, line.style_solid)
                    box.set_border_width(o.bx, 2)
                    box.set_text(o.bx, "RLC " + str.tostring(o.score) + "10")
                    box.set_text_color(o.bx, PI_RLC)
                    obs.set(i, o)
                    triggerReclaimAlert := true
                    if o.dir == 1
                        triggerReclaimBuy := true
                    else
                        triggerReclaimSell := true
                    label.new(bar_index, o.dir == 1 ? low : high, "⚡ RLC", style=o.dir == 1 ? label.style_label_up : label.style_label_down, textcolor=PI_RLC, color=color.new(PI_RLC, 60), size=size.tiny, tooltip="OB RLC — trapped liquidity detected. Score boosted to " + str.tostring(o.score) + "10")

        if o.active
            box.set_right(o.bx, bar_index + 3)

        // Entry trigger — blocked during compression when blockInChop is ON
        if o.active and not o.triggered and o.score >= minScore and sessionOK and htfAligned(o.dir) and not noTrade
            mid = (o.top + o.bot) / 2

            if o.dir == 1 and low <= mid and close > o.bot and trend == 1
                entry   = mid
                sl      = o.bot - atr * slBuffer
                risk    = math.abs(entry - sl)
                tp1     = entry + risk * rrTarget1
                tp2     = entry + risk * rrTarget2
                tierTxt = o.score >= 8 ? " GOLD" : o.score >= 5 ? " A+" : ""
                lblTxt  = "▲ BUY" + tierTxt + "\n" + str.tostring(o.score) + "10"
                ttip    = f_tooltip("BUY", o.score, entry, sl, tp1, tp2, risk)
                if showEntryLabels
                    lblBg = o.score >= 8 ? color.new(PI_GOLD, 5) : color.new(PI_BG_DARK, 5)
                    label.new(bar_index, low, lblTxt, style=label.style_label_up, textcolor=PI_BUY, color=lblBg, size=lblSize, tooltip=ttip)
                if showTPSLLines
                    line.new(bar_index, tp1,   bar_index + 30, tp1,   color=PI_BUY,  style=line.style_dashed,  width=2)
                    line.new(bar_index, tp2,   bar_index + 30, tp2,   color=PI_TEAL, style=line.style_dashed,  width=2)
                    line.new(bar_index, sl,    bar_index + 30, sl,    color=PI_SELL, style=line.style_dotted,  width=2)
                    line.new(bar_index, entry, bar_index + 30, entry, color=PI_GOLD, style=line.style_solid,   width=2)
                    label.new(bar_index + 31, tp1,   "TP1 "   + str.tostring(tp1,   format.mintick), style=label.style_label_left, textcolor=color.white, color=color.new(PI_BUY,  30), size=size.small)
                    label.new(bar_index + 31, tp2,   "TP2 "   + str.tostring(tp2,   format.mintick), style=label.style_label_left, textcolor=color.white, color=color.new(PI_TEAL, 30), size=size.small)
                    label.new(bar_index + 31, sl,    "SL "    + str.tostring(sl,    format.mintick), style=label.style_label_left, textcolor=color.white, color=color.new(PI_SELL, 30), size=size.small)
                    label.new(bar_index + 31, entry, "ENTRY " + str.tostring(entry, format.mintick), style=label.style_label_left, textcolor=PI_BG_DARK,  color=color.new(PI_GOLD, 10), size=size.small)
                box.set_right(o.bx, bar_index)
                box.set_bgcolor(o.bx, color.new(PI_BUY, 80))
                box.set_border_style(o.bx, line.style_dashed)
                box.set_text(o.bx, "FILLED")
                box.set_text_color(o.bx, color.new(PI_BUY, 40))
                o.triggered   := true
                o.active      := false
                o.entryPrice  := entry
                o.slPrice     := sl
                o.tp1Price    := tp1
                o.tp2Price    := tp2
                o.triggerBar  := bar_index
                obs.set(i, o)
                totalBuySignals  += 1
                lastBuyEntry     := entry
                lastBuySL        := sl
                lastBuyTP1       := tp1
                lastBuyTP2       := tp2
                lastSignalDir    := "BUY"
                lastSignalBar    := bar_index
                lastSignalResult := 0
                triggerBuyAlert  := true
                if o.score >= 8
                    triggerGoldAlert := true

                // Store confluence factors
                cfSweep      := validBearSweep
                cfFVG        := fvgBullOK
                cfTrend      := trend == 1
                cfHTF        := htfAligned(1) and useHTF
                cfVol        := volSpike
                cfZone       := inDiscount
                cfStrongDisp := strongDisplacement
                cfHTFCandle  := useHTFCandle and htfCandleBull
                cfHTFOBZone  := htfOBBullConf
                cfDelta      := deltaBull
                cfScore      := o.score
                cfDir        := "BUY"
                cfRLC        := o.reclaimed
                cfRegime     := regimeStr

                // Dynamic alert with full trade details
                string htfA  = htfBullish ? "BULL" : htfBearish ? "BEAR" : "NEUT"
                string sesA  = inLondon ? "London" : inNY ? "NY" : inAsian ? "Asian" : "Off"
                string rlcA  = o.reclaimed ? " [RLC]" : ""
                string tierA = o.score >= 8 ? "GOLD" : "A+"
                alert("PI BUY" + rlcA + " | " + syminfo.ticker + " " + timeframe.period + " | Score:" + str.tostring(o.score) + "/10 " + tierA + " | Entry:" + str.tostring(entry, format.mintick) + " SL:" + str.tostring(sl, format.mintick) + " TP1:" + str.tostring(tp1, format.mintick) + " TP2:" + str.tostring(tp2, format.mintick) + " | HTF:" + htfA + " Sess:" + sesA + " Regime:" + regimeStr, alert.freq_once_per_bar)

            if o.dir == -1 and high >= mid and close < o.top and trend == -1
                entry   = mid
                sl      = o.top + atr * slBuffer
                risk    = math.abs(sl - entry)
                tp1     = entry - risk * rrTarget1
                tp2     = entry - risk * rrTarget2
                tierTxt = o.score >= 8 ? " GOLD" : o.score >= 5 ? " A+" : ""
                lblTxt  = "▼ SELL" + tierTxt + "\n" + str.tostring(o.score) + "10"
                ttip    = f_tooltip("SELL", o.score, entry, sl, tp1, tp2, risk)
                if showEntryLabels
                    lblBg = o.score >= 8 ? color.new(PI_GOLD, 5) : color.new(PI_BG_DARK, 5)
                    label.new(bar_index, high, lblTxt, style=label.style_label_down, textcolor=PI_SELL, color=lblBg, size=lblSize, tooltip=ttip)
                if showTPSLLines
                    line.new(bar_index, tp1,   bar_index + 30, tp1,   color=PI_SELL,       style=line.style_dashed,  width=2)
                    line.new(bar_index, tp2,   bar_index + 30, tp2,   color=color.maroon,  style=line.style_dashed,  width=2)
                    line.new(bar_index, sl,    bar_index + 30, sl,    color=PI_BUY,        style=line.style_dotted,  width=2)
                    line.new(bar_index, entry, bar_index + 30, entry, color=PI_GOLD,       style=line.style_solid,   width=2)
                    label.new(bar_index + 31, tp1,   "TP1 "   + str.tostring(tp1,   format.mintick), style=label.style_label_left, textcolor=color.white, color=color.new(PI_SELL,       30), size=size.small)
                    label.new(bar_index + 31, tp2,   "TP2 "   + str.tostring(tp2,   format.mintick), style=label.style_label_left, textcolor=color.white, color=color.new(color.maroon, 30), size=size.small)
                    label.new(bar_index + 31, sl,    "SL "    + str.tostring(sl,    format.mintick), style=label.style_label_left, textcolor=color.white, color=color.new(PI_BUY,        30), size=size.small)
                    label.new(bar_index + 31, entry, "ENTRY " + str.tostring(entry, format.mintick), style=label.style_label_left, textcolor=PI_BG_DARK,  color=color.new(PI_GOLD,       10), size=size.small)
                box.set_right(o.bx, bar_index)
                box.set_bgcolor(o.bx, color.new(PI_SELL, 80))
                box.set_border_style(o.bx, line.style_dashed)
                box.set_text(o.bx, "FILLED")
                box.set_text_color(o.bx, color.new(PI_SELL, 40))
                o.triggered   := true
                o.active      := false
                o.entryPrice  := entry
                o.slPrice     := sl
                o.tp1Price    := tp1
                o.tp2Price    := tp2
                o.triggerBar  := bar_index
                obs.set(i, o)
                totalSellSignals += 1
                lastSellEntry    := entry
                lastSellSL       := sl
                lastSellTP1      := tp1
                lastSellTP2      := tp2
                lastSignalDir    := "SELL"
                lastSignalBar    := bar_index
                lastSignalResult := 0
                triggerSellAlert := true
                if o.score >= 8
                    triggerGoldAlert := true

                // Store confluence factors
                cfSweep      := validBullSweep
                cfFVG        := fvgBearOK
                cfTrend      := trend == -1
                cfHTF        := htfAligned(-1) and useHTF
                cfVol        := volSpike
                cfZone       := inPremium
                cfStrongDisp := strongDisplacement
                cfHTFCandle  := useHTFCandle and htfCandleBear
                cfHTFOBZone  := htfOBBearConf
                cfDelta      := deltaBear
                cfScore      := o.score
                cfDir        := "SELL"
                cfRLC        := o.reclaimed
                cfRegime     := regimeStr

                // Dynamic alert with full trade details
                string htfB  = htfBullish ? "BULL" : htfBearish ? "BEAR" : "NEUT"
                string sesB  = inLondon ? "London" : inNY ? "NY" : inAsian ? "Asian" : "Off"
                string rlcB  = o.reclaimed ? " [RLC]" : ""
                string tierB = o.score >= 8 ? "GOLD" : "A+"
                alert("PI SELL" + rlcB + " | " + syminfo.ticker + " " + timeframe.period + " | Score:" + str.tostring(o.score) + "/10 " + tierB + " | Entry:" + str.tostring(entry, format.mintick) + " SL:" + str.tostring(sl, format.mintick) + " TP1:" + str.tostring(tp1, format.mintick) + " TP2:" + str.tostring(tp2, format.mintick) + " | HTF:" + htfB + " Sess:" + sesB + " Regime:" + regimeStr, alert.freq_once_per_bar)

bgcolor(triggerGoldAlert ? color.new(PI_GOLD, 85) : na, title="Gold Flash")

// ════════════════════════════════════════
// ALERTCONDITIONS
// ════════════════════════════════════════
alertcondition(triggerBuyAlert,                    title="PI BUY",            message="PriceIntent BUY on {{ticker}} {{interval}}")
alertcondition(triggerSellAlert,                   title="PI SELL",           message="PriceIntent SELL on {{ticker}} {{interval}}")
alertcondition(triggerGoldAlert,                   title="PI GOLD",           message="GOLD Signal on {{ticker}} {{interval}}")
alertcondition(validBullSweep,                     title="PI Bear Sweep",     message="Bear Sweep on {{ticker}} {{interval}}")
alertcondition(validBearSweep,                     title="PI Bull Sweep",     message="Bull Sweep on {{ticker}} {{interval}}")
alertcondition(validBullSweep or validBearSweep,   title="PI Any Sweep",      message="Liquidity Sweep on {{ticker}} {{interval}}")
alertcondition(bullBreak,                          title="PI Bull Shift",     message="Bullish Shift on {{ticker}} {{interval}}")
alertcondition(bearBreak,                          title="PI Bear Shift",     message="Bearish Shift on {{ticker}} {{interval}}")
alertcondition(bullBreak or bearBreak,             title="PI Any Shift",      message="Shift on {{ticker}} {{interval}}")
alertcondition(triggerBuyAlert or triggerSellAlert,title="PI Any",            message="PriceIntent Signal on {{ticker}} {{interval}}")
alertcondition(triggerReclaimBuy,                  title="PI RLC BUY",        message="Bullish OB RLC on {{ticker}} {{interval}} — Trapped liquidity!")
alertcondition(triggerReclaimSell,                 title="PI RLC SELL",       message="Bearish OB RLC on {{ticker}} {{interval}} — Trapped liquidity!")
alertcondition(triggerReclaimAlert,                title="PI Any RLC",        message="OB RLC on {{ticker}} {{interval}} — Trapped liquidity!")
alertcondition(htfOBBullConf or htfOBBearConf,    title="PI HTF OB Zone",    message="Price in HTF OB zone on {{ticker}} {{interval}}")
alertcondition(isCompression,                      title="PI Chop/Compression",message="Market entering Compression (no-trade zone) on {{ticker}} {{interval}}")
alertcondition(isExpansion,                        title="PI Expansion",      message="Market entering Expansion (trending regime) on {{ticker}} {{interval}}")

// ════════════════════════════════════════
// WATERMARK
// ════════════════════════════════════════
var table wm = table.new(position.middle_center, 1, 1, bgcolor=color.new(color.white, 100))
if showWatermark and barstate.islast
    table.cell(wm, 0, 0, "PriceIntent™MatrixDominator Pro", text_color=color.new(PI_GOLD, 85), text_size=size.huge)



// ════════════════════════════════════════
// DASHBOARD (bottom-right) — 16 rows
// ════════════════════════════════════════
var table tb = table.new(position.bottom_right, 3, 16, bgcolor=color.new(PI_BG_DARK, 0), border_color=PI_BORDER, border_width=1, frame_color=PI_GOLD, frame_width=2)

if showDashboard and barstate.islast
    table.cell(tb, 0, 0, "  PriceIntent™  ",    bgcolor=PI_GOLD, text_color=PI_BG_DARK, text_size=size.normal)
    table.cell(tb, 1, 0, "  MatrixDominator  ", bgcolor=PI_GOLD, text_color=PI_BG_DARK, text_size=size.normal)
    table.cell(tb, 2, 0, "  Pro  ",             bgcolor=PI_GOLD, text_color=PI_BG_DARK, text_size=size.normal)

    table.cell(tb, 0, 1, "  Mode  ", text_color=PI_TEXT_DIM, text_size=size.small)
    table.cell(tb, 1, 1, mode,       text_color=PI_ORANGE,   text_size=size.small)
    table.cell(tb, 2, 1, "Min:" + str.tostring(minScore), text_color=PI_TEXT_DIM, text_size=size.small)

    biasT = trend == 1 ? "BULLISH" : trend == -1 ? "BEARISH" : "NEUTRAL"
    biasC = trend == 1 ? PI_BUY   : trend == -1 ? PI_SELL   : PI_TEXT_DIM
    table.cell(tb, 0, 2, "  Bias  ", text_color=PI_TEXT_DIM, text_size=size.small)
    table.cell(tb, 1, 2, biasT,      text_color=biasC,       text_size=size.small)
    table.cell(tb, 2, 2, "",          text_size=size.small)

    htfT  = htfBullish ? "BULLISH" : htfBearish ? "BEARISH" : "NEUTRAL"
    htfC  = htfBullish ? PI_BUY   : htfBearish ? PI_SELL   : PI_TEXT_DIM
    string a1 = htfBias1 == 1 ? "▲" : htfBias1 == -1 ? "▼" : "-"
    string a2 = htfBias2 == 1 ? "▲" : htfBias2 == -1 ? "▼" : "-"
    string a3 = htfBias3 == 1 ? "▲" : htfBias3 == -1 ? "▼" : "-"
    table.cell(tb, 0, 3, "  HTF  ", text_color=PI_TEXT_DIM, text_size=size.small)
    table.cell(tb, 1, 3, htfT,       text_color=htfC,        text_size=size.small)
    table.cell(tb, 2, 3, a1 + "  " + a2 + "  " + a3, text_color=PI_TEXT_DIM, text_size=size.small)

    dT = displacement ? "ACTIVE" : "-"
    dC = displacement ? PI_BUY : PI_TEXT_DIM
    table.cell(tb, 0, 4, "  Displace  ", text_color=PI_TEXT_DIM, text_size=size.small)
    table.cell(tb, 1, 4, dT,             text_color=dC,           text_size=size.small)
    table.cell(tb, 2, 4, str.tostring(atr, format.mintick), text_color=PI_TEXT_DIM, text_size=size.small)

    zT = inDiscount ? "DISCOUNT" : inPremium ? "PREMIUM" : "EQUILIBRIUM"
    zC = inDiscount ? PI_BUY   : inPremium ? PI_SELL   : PI_ORANGE
    table.cell(tb, 0, 5, "  Zone  ", text_color=PI_TEXT_DIM, text_size=size.small)
    table.cell(tb, 1, 5, zT,          text_color=zC,           text_size=size.small)
    table.cell(tb, 2, 5, str.tostring(eqZone * 100, "#") + "%", text_color=PI_TEXT_DIM, text_size=size.small)

    fibPos = rng50 > 0 ? str.tostring(fib500, format.mintick) : "-"
    table.cell(tb, 0, 6, "  EQ  ",  text_color=PI_TEXT_DIM, text_size=size.small)
    table.cell(tb, 1, 6, fibPos,     text_color=PI_ORANGE,   text_size=size.small)
    oteT = showOTE ? "KEY ON" : "KEY OFF"
    oteC = showOTE ? PI_GOLD : PI_TEXT_DIM
    table.cell(tb, 2, 6, oteT, text_color=oteC, text_size=size.small)

    sT  = isDaily ? "AUTO" : inLondon and inNY ? "LDN+NY" : inLondon ? "LONDON" : inNY ? "NEW YORK" : inAsian ? "ASIAN" : "CLOSED"
    sC  = isDaily ? PI_BUY : inLondon or inNY ? PI_BUY : inAsian ? PI_PURPLE : PI_TEXT_DIM
    sOk = isDaily ? "ALL" : sessionOK ? "OK" : "X"
    table.cell(tb, 0, 7, "  Session  ", text_color=PI_TEXT_DIM, text_size=size.small)
    table.cell(tb, 1, 7, sT,             text_color=sC,           text_size=size.small)
    table.cell(tb, 2, 7, sOk, text_color=sessionOK ? PI_BUY : PI_SELL, text_size=size.small)

    int aC = 0
    int gC = 0
    int rC = 0
    if obs.size() > 0
        for j = 0 to obs.size() - 1
            if obs.get(j).active
                aC += 1
                if obs.get(j).score >= 8
                    gC += 1
                if obs.get(j).reclaimed
                    rC += 1
    obStat = str.tostring(aC) + " active"
    if rC > 0
        obStat := obStat + " (" + str.tostring(rC) + " RLC)"
    table.cell(tb, 0, 8, "  OBs  ", text_color=PI_TEXT_DIM, text_size=size.small)
    table.cell(tb, 1, 8, obStat,     text_color=aC > 0 ? PI_ORANGE : PI_TEXT_DIM, text_size=size.small)
    gTxt = gC > 0 ? str.tostring(gC) + " GOLD" : ""
    table.cell(tb, 2, 8, gTxt, text_color=PI_GOLD, text_size=size.small)

    int htfOBAct = 0
    if showHTFOB and htfOBs.size() > 0
        for i = 0 to htfOBs.size() - 1
            if htfOBs.get(i).active
                htfOBAct += 1
    string htfOBTxt  = showHTFOB ? str.tostring(htfOBAct) + " active" : "OFF"
    color  htfOBClr  = showHTFOB and htfOBAct > 0 ? PI_TEAL : PI_TEXT_DIM
    table.cell(tb, 0, 9, "  HTF OB  ", text_color=PI_TEXT_DIM, text_size=size.small)
    table.cell(tb, 1, 9, htfOBTxt,     text_color=htfOBClr,    text_size=size.small)
    string htfOBConf  = htfOBBullConf ? "BULL" : htfOBBearConf ? "BEAR" : htfOBActualTF
    color  htfOBConfC = htfOBBullConf ? PI_BUY : htfOBBearConf ? PI_SELL : PI_TEXT_DIM
    table.cell(tb, 2, 9, htfOBConf, text_color=htfOBConfC, text_size=size.small)

    vR = volSMA > 0 ? volume / volSMA : 0.0
    string deltaT = deltaBull ? "BUY" : deltaBear ? "SELL" : "FLAT"
    color  deltaC = deltaBull ? PI_BUY : deltaBear ? PI_SELL : PI_TEXT_DIM
    table.cell(tb, 0, 10, "  Volume  ", text_color=PI_TEXT_DIM, text_size=size.small)
    table.cell(tb, 1, 10, volSpike ? "SPIKE" : "NORMAL", text_color=volSpike ? PI_ORANGE : PI_TEXT_DIM, text_size=size.small)
    table.cell(tb, 2, 10, deltaT + " " + str.tostring(vR, "#.0") + "x", text_color=deltaC, text_size=size.small)

    // Regime row
    string regimeBadge  = noTrade ? regimeStr + " ✕" : regimeStr
    color  regimeBadgeC = noTrade ? PI_ORANGE : regimeClr
    table.cell(tb, 0, 11, "  Regime  ",  text_color=PI_TEXT_DIM,   text_size=size.small)
    table.cell(tb, 1, 11, regimeBadge,   text_color=regimeBadgeC,  text_size=size.small)
    table.cell(tb, 2, 11, str.tostring(atrRatio, "#.##") + "x", text_color=PI_TEXT_DIM, text_size=size.small)

    table.cell(tb, 0, 12, "  Signals  ", text_color=PI_TEXT_DIM, text_size=size.small)
    table.cell(tb, 1, 12, str.tostring(totalBuySignals) + "B / " + str.tostring(totalSellSignals) + "S", text_color=PI_TEXT, text_size=size.small)
    table.cell(tb, 2, 12, "total", text_color=PI_TEXT_DIM, text_size=size.small)

    tT2    = totalWins + totalLosses
    wP2raw = tT2 > 0 ? totalWins * 100.0 / tT2 : 0.0
    wP2    = math.round(wP2raw, 1)
    wTx2   = tT2 > 0 ? str.tostring(wP2, "#.#") + "%" : "-"
    wC2    = wP2 >= 55 ? PI_BUY : wP2 > 0 ? PI_SELL : PI_TEXT_DIM
    table.cell(tb, 0, 13, "  WinRate  ", text_color=PI_TEXT_DIM, text_size=size.small)
    table.cell(tb, 1, 13, wTx2,           text_color=wC2,          text_size=size.small)
    table.cell(tb, 2, 13, str.tostring(totalWins) + "W/" + str.tostring(totalLosses) + "L", text_color=PI_TEXT_DIM, text_size=size.small)

    string lT = "-"
    color  lC = PI_TEXT_DIM
    if lastSignalDir == "BUY" and not na(lastBuyEntry)
        lT := "BUY " + str.tostring(lastBuyEntry, format.mintick)
        lC := PI_BUY
    else if lastSignalDir == "SELL" and not na(lastSellEntry)
        lT := "SELL " + str.tostring(lastSellEntry, format.mintick)
        lC := PI_SELL
    table.cell(tb, 0, 14, "  Last  ", text_color=PI_TEXT_DIM, text_size=size.small)
    table.cell(tb, 1, 14, lT,          text_color=lC,           text_size=size.small)
    bAgo = bar_index - lastSignalBar
    agoT = lastSignalBar > 0 ? str.tostring(bAgo) + " bars" : ""
    table.cell(tb, 2, 14, agoT, text_color=PI_TEXT_DIM, text_size=size.small)

    // No-trade warning row
    ntTxt = noTrade ? "NO-TRADE  CHOP" : "TRADE OK"
    ntClr = noTrade ? PI_ORANGE : PI_BUY
    ntBg  = noTrade ? color.new(PI_ORANGE, 75) : color.new(PI_BG_DARK, 0)
    table.cell(tb, 0, 15, "  Filter  ", text_color=PI_TEXT_DIM, text_size=size.small)
    table.cell(tb, 1, 15, ntTxt,         text_color=ntClr, bgcolor=ntBg, text_size=size.small)
    table.cell(tb, 2, 15, "",             text_size=size.small)

// ════════════════════════════════════════
// CONFLUENCE BREAKDOWN PANEL (bottom-left)
// Shows which of the 11 factors scored on the most recent signal
// ════════════════════════════════════════

// Helper function must be defined at global scope (not inside an if block)
f_cfRow(tbl, row, lbl, fired) =>
    string tick = fired ? "✓" : "✗"
    color  tc   = fired ? PI_BUY : PI_TEXT_DIM
    color  lc   = fired ? PI_TEXT : PI_TEXT_DIM
    table.cell(tbl, 0, row, "  " + lbl + "  ", text_color=lc, text_size=size.small)
    table.cell(tbl, 1, row, "  " + tick + "  ", text_color=tc, text_size=size.small)

var table cp = table.new(position.bottom_left, 2, 14, bgcolor=color.new(PI_BG_DARK, 0), border_color=PI_BORDER, border_width=1, frame_color=PI_GOLD, frame_width=2)

if showConfluence and barstate.islast and cfDir != "NONE"
    cfHdrClr  = cfDir == "BUY" ? color.new(PI_BUY, 50) : color.new(PI_SELL, 50)
    cfTierTxt = cfScore >= 8 ? "GOLD " + str.tostring(cfScore) + "/10" : "A+  " + str.tostring(cfScore) + "/10"
    cfRLCtxt  = cfRLC ? "  ⚡RLC" : ""

    table.cell(cp, 0, 0, "  CONFLUENCE  ", bgcolor=cfHdrClr, text_color=color.white, text_size=size.normal)
    table.cell(cp, 1, 0, "  " + cfDir + " " + cfTierTxt + cfRLCtxt + "  ", bgcolor=cfHdrClr, text_color=color.white, text_size=size.normal)

    f_cfRow(cp, 1,  "Base (+2)",          true)
    f_cfRow(cp, 2,  "Sweep (+2)",         cfSweep)
    f_cfRow(cp, 3,  "FVG (+1)",           cfFVG)
    f_cfRow(cp, 4,  "Structure (+1)",     cfTrend)
    f_cfRow(cp, 5,  "HTF Bias (+1)",      cfHTF)
    f_cfRow(cp, 6,  "Vol Spike (+1)",     cfVol)
    f_cfRow(cp, 7,  "P/D Zone (+1)",      cfZone)
    f_cfRow(cp, 8,  "Strong Disp (+1)",   cfStrongDisp)
    f_cfRow(cp, 9,  "HTF Candle (+1)",    cfHTFCandle)
    f_cfRow(cp, 10, "HTF OB Zone (+1)",   cfHTFOBZone)
    f_cfRow(cp, 11, "Vol Delta (+1)",     cfDelta)

    table.cell(cp, 0, 12, "  Regime  ", text_color=PI_TEXT_DIM, text_size=size.small)
    table.cell(cp, 1, 12, "  " + cfRegime + "  ", text_color=regimeClr, text_size=size.small)

    // Score progress bar (filled blocks out of 10)
    string scoreBar = ""
    for k = 1 to 10
        scoreBar := scoreBar + (k <= cfScore ? "█" : "░")
    table.cell(cp, 0, 13, "  Score  ", text_color=PI_TEXT_DIM, text_size=size.small)
    table.cell(cp, 1, 13, "  " + scoreBar + "  ", text_color=cfScore >= 8 ? PI_GOLD : cfScore >= 5 ? PI_BUY : PI_TEXT_DIM, text_size=size.small)

// ════════════════════════════════════════
// FIB SIGNAL PANEL (bottom-left)
// ════════════════════════════════════════
fib236       = llVal + rng50 * 0.236
fib786       = llVal + rng50 * 0.786
inGoldenZone = eqZone >= 0.618 and eqZone <= 0.786

fibBuySignal  = inDiscount and trend == 1 and rng50 > 0
fibSellSignal = inPremium and trend == -1 and rng50 > 0
goldenBuy     = inGoldenZone and trend == 1 and close < close[1] and rng50 > 0
goldenSell    = inGoldenZone and trend == -1 and close > close[1] and rng50 > 0

alertcondition(fibBuySignal,                title="PI Key BUY",      message="Key Zone BUY on {{ticker}} {{interval}}")
alertcondition(fibSellSignal,               title="PI Key SELL",     message="Key Zone SELL on {{ticker}} {{interval}}")
alertcondition(fibBuySignal or fibSellSignal, title="PI Any Key Zone", message="Key Zone Signal on {{ticker}} {{interval}}")
alertcondition(goldenBuy,                   title="PI Golden BUY",   message="Golden Zone BUY on {{ticker}} {{interval}}")
alertcondition(goldenSell,                  title="PI Golden SELL",  message="Golden Zone SELL on {{ticker}} {{interval}}")
alertcondition(goldenBuy or goldenSell,     title="PI Any Golden",   message="Golden Zone Signal on {{ticker}} {{interval}}")

fibBuyEntry   = fibBuySignal  ? close : na
fibBuySL      = fibBuySignal  ? llVal - nz(atr) * 0.3 : na
fibBuyTP      = fibBuySignal  ? fib500 : na
fibBuyTP2     = fibBuySignal  ? fib618 : na
fibSellEntry  = fibSellSignal ? close : na
fibSellSL     = fibSellSignal ? hhVal + nz(atr) * 0.3 : na
fibSellTP     = fibSellSignal ? fib500 : na
fibSellTP2    = fibSellSignal ? fib382 : na
goldBuyEntry  = goldenBuy  ? close : na
goldBuySL     = goldenBuy  ? fib618 - nz(atr) * 0.5 : na
goldBuyTP     = goldenBuy  ? hhVal : na
goldSellEntry = goldenSell ? close : na
goldSellSL    = goldenSell ? fib786 + nz(atr) * 0.5 : na
goldSellTP    = goldenSell ? llVal : na

// ── END ──
````
