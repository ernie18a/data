# Trendshot by MTM

- url: https://www.tradingview.com/script/lriO9V7X-Trendshot-by-MTM/
- type: indicator
- pine_id: PUB;be1c60d3c15249e4b609bb40a4412d1f
- version: 3.0

## Description

# Trendshot by MTM — Multi-Timeframe Trend & Trade Management

**Trade with context. Execute with discipline.**

Trendshot by MTM is a multi-functional technical analysis indicator designed to help traders identify market direction, analyse price structure and plan potential trade setups with greater clarity.

Combining trend-following tools, multi-timeframe analysis, volume-based price levels and automated risk/reward projections, Trendshot provides a structured view of the market directly on your TradingView chart.

### KEY FEATURES

**📈 1. EMA Trend System**
- Fast EMA (20), Slow EMA (50) and Long-Term EMA (238).
- Visual trend representation and crossover signals.
- Helps identify potential bullish and bearish momentum shifts.

**⏱️ 2. Multi-Timeframe Trend Dashboard**
- Monitor trend direction across up to six configurable timeframes.
- Default timeframes: M1, M5, M15, M30, H4 and Daily.
- Quickly assess whether different timeframes show bullish or bearish conditions.

**🎯 3. Volume Point of Control (POC)**
- Volume-based POC levels calculated for M15, M30 and H1.
- Optional horizontal POC line to identify an estimated high-volume price area.
- Dashboard showing whether the current price is above or below each POC.

**🧱 4. Dynamic Support & Resistance**
- Automatically identifies relevant swing highs and lows.
- Displays potential support and resistance levels and associated zones.
- Optional historical structure levels for additional market context.
- ATR-based filters help qualify price swings and zone sizes.

**⭐ 5. Market Swing Markers**
- Small, medium and large markers highlight potential swing highs and lows.
- Helps visualise market turning points and price structure.

**🛡️ 6. Entry, Stop Loss & Take Profit**
- Visualises the potential entry level following a confirmed EMA crossover.
- Configurable Stop Loss based on fixed distance or previous support/resistance structure.
- Displays up to four Take Profit levels.
- Colour-coded risk and reward zones for easier trade planning.

**🕒 7. Trade Session Filter**
- Default trading window: 08:00–21:00, based on the chart/exchange time.
- Option to display signals outside the configured trading window.

**🔔 8. TradingView Alerts**
- Configurable alerts for bullish and bearish crossover signals.
- Suitable for traders who want to monitor setups without watching every candle.

### DESIGNED FOR

Trendshot by MTM can support discretionary traders analysing Forex, Gold (XAUUSD), indices and cryptocurrencies, subject to the characteristics of the instrument, broker feed and chart timeframe.

Whether you are scalping, day trading or analysing broader market direction, the objective is to bring essential technical information together in one chart.

### IMPORTANT NOTES

Trendshot by MTM is an indicator for technical analysis and educational purposes. It does not guarantee profitable trades, predict market direction with certainty or execute orders automatically.

Signals are based on EMA crossovers and should be assessed alongside market structure, volatility, trading costs and an appropriate risk management plan. Support/resistance levels, POC calculations and historical swing markers are analytical estimates, not guarantees of future price behaviour.

The default Stop Loss and Take Profit settings are configurable and should be reviewed for each instrument and trading strategy.

Trading leveraged financial products involves substantial risk and may result in the loss of capital.

### INTELLECTUAL PROPERTY

© Ricardo Garcia | RicardoGarciaPT — MoreThanMoney

Trendshot by MTM is proprietary intellectual property. Copying, redistribution, resale or modification of the source code without prior written authorisation is prohibited.

**MoreThanMoney — More than money. A better way to understand the markets.**

## Source Code

````pine
// ════════════════════════════════════════════════════════════════════════════
// © Ricardo Garcia (RicardoGarciaPT) / MoreThanMoney. All rights reserved.
// This software and source code are the intellectual property of
// Ricardo Garcia (RicardoGarciaPT) and his company MoreThanMoney.
// Copying, redistribution, resale, modification or reuse of this code, in whole
// or in part, without the written authorization of the owner is prohibited.
// ════════════════════════════════════════════════════════════════════════════
//@version=6
indicator("Trendshot by MTM", shorttitle="Trendshot by MTM", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500, max_bars_back=500)

// ════════════════════════════════════════════════════════════════
// INPUTS
// ════════════════════════════════════════════════════════════════
showSLTP = input.bool(true, "Show SL/TP on chart")

gEMA    = "EMA SETTINGS"
fastLen = input.int(20,  "Fast EMA", minval=1, group=gEMA)
slowLen = input.int(50,  "Slow EMA", minval=1, group=gEMA)
longLen = input.int(238, "Long EMA", minval=1, group=gEMA)

gTT    = "TREND TABLE SETTINGS"
showTT = input.bool(true, "Show Trend Table", group=gTT)
tfA = input.timeframe("1",   "TimeFrame - A", group=gTT, inline="a")
shA = input.bool(true, "Show", group=gTT, inline="a")
tfB = input.timeframe("5",   "TimeFrame - B", group=gTT, inline="b")
shB = input.bool(true, "Show", group=gTT, inline="b")
tfC = input.timeframe("15",  "TimeFrame - C", group=gTT, inline="c")
shC = input.bool(true, "Show", group=gTT, inline="c")
tfD = input.timeframe("30",  "TimeFrame - D", group=gTT, inline="d")
shD = input.bool(true, "Show", group=gTT, inline="d")
tfE = input.timeframe("240", "TimeFrame - E", group=gTT, inline="e")
shE = input.bool(true, "Show", group=gTT, inline="e")
tfF = input.timeframe("D",   "TimeFrame - F", group=gTT, inline="f")
shF = input.bool(true, "Show", group=gTT, inline="f")

gTD    = "TREND TABLE DISPLAY SETTINGS"
bgCol  = input.color(#363A45, "Background Color",  group=gTD)
upCol  = input.color(#2962FF, "Up Trend Color",    group=gTD)
dnCol  = input.color(#FF5252, "Down Trend Color",  group=gTD)
txtCol = input.color(#FFEB3B, "Text Color",        group=gTD)
ttPos  = input.string("Top Center", "Trend Table Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=gTD)
ttSize = input.string("Small", "Trend Table Size", options=["Tiny", "Small", "Normal", "Large"], group=gTD)

gPOC      = "VOLUME POINT OF CONTROL SETTINGS"
showPOCtb = input.bool(true, "Show POC in Table", group=gPOC, tooltip="Shows in the table whether price is Above or Below the Volume Point of Control of M15, M30 and H1.")
showPOCln = input.bool(true, "Show POC line", group=gPOC)
pocCol    = input.color(#FF9800, "POC Line Color", group=gPOC)

gSR      = "SUPPORT AND RESISTANCE SETTINGS"
showSR   = input.bool(true, "Display Support and Resistance", group=gSR)
atrMove  = input.float(1.0, "ATR Movement Required", minval=0.0, step=0.1, group=gSR, tooltip="Minimum swing (in ATR) between the pivot and the opposite extreme for a level to be valid.")
hlLook   = input.int(25, "High/Low Lookback", minval=3, group=gSR, tooltip="Number of bars used to validate highs and lows.")
maxZone  = input.float(2.5, "Max Zone Size (Compared to ATR)", minval=0.1, step=0.1, group=gSR, tooltip="Maximum zone size (pivot candle) compared to ATR. Larger zones are ignored.")
resetCnt = input.int(25, "Zone Update Count Before Reset", minval=1, group=gSR, tooltip="Number of bars without a new level before the current level is cleared.")
showPrev = input.bool(true, "Draw Previous Structure", group=gSR, tooltip="Also draws the previous levels (past structure).")

gStar     = "STAR COLOR SETTINGS"
showSmall = input.bool(true, "Show/Hide Small Stars",  group=gStar, inline="s1")
colSmall  = input.color(#FFEB3B, "", group=gStar, inline="s1")
showMed   = input.bool(true, "Show/Hide Medium Stars", group=gStar, inline="s2")
colMed    = input.color(#2962FF, "", group=gStar, inline="s2")
colLHigh  = input.color(#FF5252, "Large High Stars", group=gStar)
colLLow   = input.color(#00E676, "Large Low Stars",  group=gStar)

gClock      = "TRADE CLOCK"
showClock   = input.bool(true, "Show Trade Clock", group=gClock)
showOutside = input.bool(false, "Show signals outside of trade times", group=gClock)

gRisk    = "STOP LOSS / TAKE PROFIT SETTINGS"
slMode   = input.string("Fixed Points", "SL Mode", options=["Fixed Points", "Structure (Previous S/R)"], group=gRisk, tooltip="Fixed Points: SL at a fixed distance in points from the entry.\nStructure (Previous S/R): SL at the nearest previous support (long) or resistance (short). If none is available, it falls back to Fixed Points. TPs keep the same proportions relative to the SL.")
slPtsIn  = input.float(0.0, "SL Size (points, 0 = auto)", minval=0.0, step=100.0, group=gRisk, tooltip="Stop-loss distance in points. 1 point = 0.01 price units (indices, metals, crypto) or the minimum tick (forex).\n0 = auto: 100 pips on every symbol (US30 = 10000 points; forex = 1000 points on 5-digit pairs) and 200 pips (2000 points) on XAUUSD.")
tp1PtsIn = input.float(0.0, "TP1 Size (points, 0 = auto)", minval=0.0, step=100.0, group=gRisk, tooltip="0 = auto: 30% of the SL.")
tp2PtsIn = input.float(0.0, "TP2 Size (points, 0 = auto)", minval=0.0, step=100.0, group=gRisk, tooltip="0 = auto: 50% of the SL (60% on XAUUSD).")
tp3PtsIn = input.float(0.0, "TP3 Size (points, 0 = auto)", minval=0.0, step=100.0, group=gRisk, tooltip="0 = auto: 100% of the SL.")
showTP4  = input.bool(true, "Show TP4", group=gRisk, tooltip="Adds a fourth take-profit level above TP3. Untick it to show only TP1 to TP3.")
tp4PtsIn = input.float(0.0, "TP4 Size (points, 0 = auto)", minval=0.0, step=100.0, group=gRisk, tooltip="0 = auto: 150% of the SL (1.5 x TP3).")

// ════════════════════════════════════════════════════════════════
// INTERNAL PARAMETERS (editable here in the code)
// ════════════════════════════════════════════════════════════════
const int    POC_LEN       = 50          // bars used for the table POC
const int    POC_BINS      = 24          // price bins of the volume profile (table)
const int    POC_LINE_LEN  = 50        // bars of the volume profile used for the POC line
const int    POC_LINE_BINS = 100         // price bins of the POC line profile
const string POC_TF1       = "15"
const string POC_TF2       = "30"
const string POC_TF3       = "60"
const string TRADE_SESSION = "0800-2100" // Trade Clock session (chart / exchange time)
const int    SR_RIGHT      = 5           // confirmation bars of the S/R pivot
const float  LOWVOL_MULT   = 0.5         // Low Volume = volume < 0.5 x SMA(20)
const int    BOX_W         = 20          // width of the Entry/SL/TP box (bars)

const color  C_ENTRY = #8B5CF6
const color  C_TP    = #12B886
const color  C_SL    = #D6401F
const color  C_BRAND = #8B5CF6

// ════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ════════════════════════════════════════════════════════════════
f_pos(s) =>
    switch s
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_size(s) =>
    switch s
        "Tiny"  => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_tf(tf) =>
    sec = timeframe.in_seconds(tf)
    d = int(sec / 86400)
    sec < 3600 ? "M" + str.tostring(int(sec / 60)) : sec < 86400 ? "H" + str.tostring(int(sec / 3600)) : sec < 604800 ? "D" + (d == 1 ? "" : str.tostring(d)) : "W"

f_trend() =>
    ta.ema(close, fastLen) - ta.ema(close, slowLen)

f_poc(len, bins) =>
    hi = ta.highest(high, len)
    lo = ta.lowest(low, len)
    step = (hi - lo) / bins
    float res = na
    if step > 0 and bar_index >= len and not na(volume)
        vols = array.new_float(bins, 0.0)
        for i = 0 to len - 1
            idx = math.min(bins - 1, math.max(0, int(math.floor((hl2[i] - lo) / step))))
            array.set(vols, idx, array.get(vols, idx) + nz(volume[i]))
        mx = array.max(vols)
        if mx > 0
            res := lo + (array.indexof(vols, mx) + 0.5) * step
    res

f_fmt(v) => str.tostring(v, format.mintick)

// ════════════════════════════════════════════════════════════════
// EMAs, TREND AND HISTOGRAM (below the "water line")
// ════════════════════════════════════════════════════════════════
emaF = ta.ema(close, fastLen)
emaS = ta.ema(close, slowLen)
emaL = ta.ema(close, longLen)
atr  = ta.atr(14)
trendUp = emaF > emaS

plot(emaF, "Fast EMA", color=dnCol, linewidth=2)
plot(emaS, "Slow EMA", color=upCol, linewidth=2)
plot(emaL, "Long EMA", color=#FF9800, linewidth=3)

// Histogram: columns from the bottom of the chart up to the water line (top = higher of the two EMAs)
plot(math.max(emaF, emaS), "Histogram", style=plot.style_columns, color=trendUp ? color.new(upCol, 85) : color.new(dnCol, 85))

barcolor(trendUp ? upCol : na, title="Bars")

// ════════════════════════════════════════════════════════════════
// MULTI-TIMEFRAME TREND
// ════════════════════════════════════════════════════════════════
tA = request.security(syminfo.tickerid, tfA, f_trend()) > 0
tB = request.security(syminfo.tickerid, tfB, f_trend()) > 0
tC = request.security(syminfo.tickerid, tfC, f_trend()) > 0
tD = request.security(syminfo.tickerid, tfD, f_trend()) > 0
tE = request.security(syminfo.tickerid, tfE, f_trend()) > 0
tF = request.security(syminfo.tickerid, tfF, f_trend()) > 0

// ════════════════════════════════════════════════════════════════
// POC
// ════════════════════════════════════════════════════════════════
poc1 = request.security(syminfo.tickerid, POC_TF1, f_poc(POC_LEN, POC_BINS))
poc2 = request.security(syminfo.tickerid, POC_TF2, f_poc(POC_LEN, POC_BINS))
poc3 = request.security(syminfo.tickerid, POC_TF3, f_poc(POC_LEN, POC_BINS))

// POC line: orange horizontal ray at the highest-volume price of the last POC_LINE_LEN bars,
// starting at the beginning of that window and extending to the right
var line pocLn = na
if barstate.islast and showPOCln
    pn = math.min(POC_LINE_LEN, bar_index + 1)
    float pHi = high
    float pLo = low
    for i = 0 to pn - 1
        pHi := math.max(pHi, high[i])
        pLo := math.min(pLo, low[i])
    pStep = (pHi - pLo) / POC_LINE_BINS
    if pStep > 0
        pVols = array.new_float(POC_LINE_BINS, 0.0)
        for i = 0 to pn - 1
            b0 = math.min(POC_LINE_BINS - 1, math.max(0, int(math.floor((low[i] - pLo) / pStep))))
            b1 = math.min(POC_LINE_BINS - 1, math.max(0, int(math.floor((high[i] - pLo) / pStep))))
            share = nz(volume[i]) / (b1 - b0 + 1)
            for k = b0 to b1
                array.set(pVols, k, array.get(pVols, k) + share)
        pMax = array.max(pVols)
        if pMax > 0
            pocLvl = pLo + (array.indexof(pVols, pMax) + 0.5) * pStep
            line.delete(pocLn)
            pocLn := line.new(bar_index - (pn - 1), pocLvl, bar_index, pocLvl, color=pocCol, width=1, extend=extend.right)

// ════════════════════════════════════════════════════════════════
// SUPPORT / RESISTANCE: R1, R2, S1, S2, previous structure (PR1, PR2, PS1, PS2) and zones
// ════════════════════════════════════════════════════════════════
f_sr(lb, rb, mv, mz, rs, a) =>
    var float r   = na
    var float rh  = na
    var float p1  = na
    var float ph1 = na
    var float p2  = na
    var float ph2 = na
    var float s   = na
    var float sh  = na
    var float q1  = na
    var float qh1 = na
    var float q2  = na
    var float qh2 = na
    var int   ra  = 0
    var int   sa  = 0
    hiR = ta.highest(high, lb + rb + 1)
    loR = ta.lowest(low, lb + rb + 1)
    ph  = ta.pivothigh(high, lb, rb)
    pl  = ta.pivotlow(low, lb, rb)
    zH  = high[rb] - math.max(open[rb], close[rb])
    zL  = math.min(open[rb], close[rb]) - low[rb]
    if not na(ph) and ph - loR >= mv * a and zH <= mz * a
        if not na(r)
            p2  := p1
            ph2 := ph1
            p1  := r
            ph1 := rh
        r  := ph
        rh := zH
        ra := 0
    else
        ra += 1
    if ra > rs
        r  := na
        rh := na
    if not na(pl) and hiR - pl >= mv * a and zL <= mz * a
        if not na(s)
            q2  := q1
            qh2 := qh1
            q1  := s
            qh1 := sh
        s  := pl
        sh := zL
        sa := 0
    else
        sa += 1
    if sa > rs
        s  := na
        sh := na
    [r, rh, p1, ph1, p2, ph2, s, sh, q1, qh1, q2, qh2]

f_brk(x) => ta.change(x) != 0 ? na : x

[r1, r1h, pr1, pr1h, pr2, pr2h, s1, s1h, ps1, ps1h, ps2, ps2h] = f_sr(hlLook, SR_RIGHT, atrMove, maxZone, resetCnt, atr)
[r2, r2h, u1, u2, u3, u4, s2, s2h, u5, u6, u7, u8] = f_sr(hlLook * 2, SR_RIGHT, atrMove, maxZone, resetCnt, atr)

r1B  = f_brk(r1)
r2B  = f_brk(r2)
s1B  = f_brk(s1)
s2B  = f_brk(s2)
pr1B = f_brk(pr1)
pr2B = f_brk(pr2)
ps1B = f_brk(ps1)
ps2B = f_brk(ps2)

pvOn   = showSR and showPrev
cGreen = #4CAF50
cRed   = #FF5252

// Levels (R1/S1 visible; R2, S2 and previous structure unchecked by default)
plot(showSR ? r1B : na, "R1", color=close < nz(r1, close) ? cRed : cGreen, style=plot.style_linebr)
plot(showSR ? r2B : na, "R2", color=close < nz(r2, close) ? color.new(cRed, 50) : color.new(cGreen, 50), style=plot.style_linebr, display=display.none)
plot(showSR ? s1B : na, "S1", color=close > nz(s1, close) ? cGreen : cRed, style=plot.style_linebr)
plot(showSR ? s2B : na, "S2", color=close > nz(s2, close) ? color.new(cGreen, 50) : color.new(cRed, 50), style=plot.style_linebr, display=display.none)
plot(pvOn ? ps1B : na, "PS1", color=color.new(cGreen, 50), style=plot.style_linebr, display=display.none)
plot(pvOn ? ps2B : na, "PS2", color=color.new(cGreen, 50), style=plot.style_linebr, display=display.none)
plot(pvOn ? pr1B : na, "PR1", color=color.new(cRed, 50), style=plot.style_linebr, display=display.none)
plot(pvOn ? pr2B : na, "PR2", color=color.new(cRed, 50), style=plot.style_linebr, display=display.none)

// Zones (unchecked by default)
zRT = plot(showSR ? r1 : na, "Resistance Zone Top", color=na, editable=false, display=display.none)
zRB = plot(showSR ? r1 - r1h : na, "Resistance Zone Bottom", color=na, editable=false, display=display.none)
fill(zRT, zRB, color=close < nz(r1, close) ? color.new(cRed, 80) : color.new(cGreen, 80), title="Resistance Zone", display=display.none)

zSB = plot(showSR ? s1 : na, "Support Zone Bottom", color=na, editable=false, display=display.none)
zST = plot(showSR ? s1 + s1h : na, "Support Zone Top", color=na, editable=false, display=display.none)
fill(zST, zSB, color=close > nz(s1, close) ? color.new(cGreen, 80) : color.new(cRed, 80), title="Support Zone", display=display.none)

pSB = plot(pvOn ? ps1 : na, "Previous Support Zone Bottom", color=na, editable=false, display=display.none)
pST = plot(pvOn ? ps1 + ps1h : na, "Previous Support Zone Top", color=na, editable=false, display=display.none)
fill(pST, pSB, color=color.new(cGreen, 85), title="Previous Support Zone", display=display.none)

pRT = plot(pvOn ? pr1 : na, "Previous Resistance Zone Top", color=na, editable=false, display=display.none)
pRB = plot(pvOn ? pr1 - pr1h : na, "Previous Resistance Zone Bottom", color=na, editable=false, display=display.none)
fill(pRT, pRB, color=color.new(cRed, 85), title="Previous Resistance Zone", display=display.none)

// ════════════════════════════════════════════════════════════════
// STARS
// ════════════════════════════════════════════════════════════════
phS = ta.pivothigh(high, 3, 3)
plS = ta.pivotlow(low, 3, 3)
phM = ta.pivothigh(high, 10, 10)
plM = ta.pivotlow(low, 10, 10)
phL = ta.pivothigh(high, hlLook, hlLook)
plL = ta.pivotlow(low, hlLook, hlLook)
rngL = ta.highest(high, 2 * hlLook + 1) - ta.lowest(low, 2 * hlLook + 1)

bigH = not na(phL) and rngL >= atrMove * atr
bigL = not na(plL) and rngL >= atrMove * atr
medH = not na(phM) and not bigH
medL = not na(plM) and not bigL
smlH = not na(phS) and not bigH and not medH
smlL = not na(plS) and not bigL and not medL

plotshape(showSmall and smlH, "Small High", style=shape.circle, location=location.abovebar, color=colSmall, size=size.tiny, offset=-3)
plotshape(showSmall and smlL, "Small Low",  style=shape.circle, location=location.belowbar, color=colSmall, size=size.tiny, offset=-3)
plotchar(showMed and medH, "Medium High", char="✸", location=location.abovebar, color=colMed, size=size.tiny, offset=-10)
plotchar(showMed and medL, "Medium Low",  char="✸", location=location.belowbar, color=colMed, size=size.tiny, offset=-10)
plotchar(bigH, "Large High", char="✸", location=location.abovebar, color=colLHigh, size=size.tiny, offset=-hlLook)
plotchar(bigL, "Large Low",  char="✸", location=location.belowbar, color=colLLow,  size=size.tiny, offset=-hlLook)

// ════════════════════════════════════════════════════════════════
// SIGNALS + TRADE CLOCK
// ════════════════════════════════════════════════════════════════
crossUp = ta.crossover(emaF, emaS)
crossDn = ta.crossunder(emaF, emaS)
inTrade = not showClock or showOutside or not na(time(timeframe.period, TRADE_SESSION))
sigUp = crossUp and inTrade
sigDn = crossDn and inTrade

plotshape(sigUp, "Shapes", style=shape.triangleup,   location=location.abovebar, color=upCol, size=size.small)
plotshape(sigDn, "Shapes", style=shape.triangledown, location=location.abovebar, color=dnCol, size=size.small)

// Trade Session (unchecked by default): squares at the bottom of the chart during trading hours
plotshape(not na(time(timeframe.period, TRADE_SESSION)), "Trade Session", style=shape.square, location=location.bottom, color=cGreen, size=size.tiny, display=display.none)

alertcondition(sigUp, "Buy Signal",  "Trendshot: BUY signal")
alertcondition(sigDn, "Sell Signal", "Trendshot: SELL signal")

// ════════════════════════════════════════════════════════════════
// ENTRY / SL / TP (static at the zone of the latest signal)
// ════════════════════════════════════════════════════════════════
// Point size: 0.01 price units (indices, metals, crypto) or the minimum tick (forex)
isForex   = syminfo.type == "forex"
pointSize = isForex ? syminfo.mintick : 0.01
pipSize   = syminfo.mintick * 10          // forex pip (5-digit / 3-digit quotes)
tkr       = str.upper(syminfo.ticker)
isGold    = str.contains(tkr, "XAU") or str.contains(tkr, "GOLD")

// Auto SL: 100 pips (US30 = 10000 points, forex pairs = 100 pips), 200 pips (2000 points) on XAUUSD
autoSL = isGold ? 2000.0 : (isForex ? 100.0 * pipSize / pointSize : 10000.0)
slPts  = slPtsIn > 0 ? slPtsIn : autoSL
tp1Pts = tp1PtsIn > 0 ? tp1PtsIn : slPts * 0.3
tp2Pts = tp2PtsIn > 0 ? tp2PtsIn : slPts * (isGold ? 0.6 : 0.5)
tp3Pts = tp3PtsIn > 0 ? tp3PtsIn : slPts
tp4Pts = tp4PtsIn > 0 ? tp4PtsIn : slPts * 1.5

var array<line>  trLines  = array.new<line>()
var array<label> trLabels = array.new<label>()
var array<box>   trBoxes  = array.new<box>()

f_clear() =>
    while array.size(trLines) > 0
        line.delete(array.pop(trLines))
    while array.size(trLabels) > 0
        label.delete(array.pop(trLabels))
    while array.size(trBoxes) > 0
        box.delete(array.pop(trBoxes))

f_level(x1, x2, y, txt, col) =>
    array.push(trLines, line.new(x1, y, x2, y, color=col, width=1))
    array.push(trLabels, label.new(x2 + 1, y, txt, style=label.style_label_left, color=col, textcolor=color.white, size=size.small))

newTrade = showSLTP and (crossUp or crossDn) and barstate.isconfirmed
if newTrade
    f_clear()
    isLong = crossUp
    entry  = close
    dirn   = isLong ? 1.0 : -1.0

    // SL distance: fixed points, or nearest previous structure level (falls back to fixed points)
    fixedRisk = slPts * pointSize
    float structSL = na
    if slMode == "Structure (Previous S/R)"
        structSL := isLong ? (not na(s1) and s1 < entry ? s1 : not na(ps1) and ps1 < entry ? ps1 : not na(ps2) and ps2 < entry ? ps2 : na) : (not na(r1) and r1 > entry ? r1 : not na(pr1) and pr1 > entry ? pr1 : not na(pr2) and pr2 > entry ? pr2 : na)
    risk  = na(structSL) ? fixedRisk : math.abs(entry - structSL)
    scale = risk / fixedRisk

    slP = entry - dirn * risk
    tp1 = entry + dirn * tp1Pts * pointSize * scale
    tp2 = entry + dirn * tp2Pts * pointSize * scale
    tp3 = entry + dirn * tp3Pts * pointSize * scale
    tp4 = entry + dirn * tp4Pts * pointSize * scale
    tpLast = showTP4 ? tp4 : tp3
    x1 = bar_index
    x2 = bar_index + BOX_W

    // zones (green = target, red = risk)
    array.push(trBoxes, box.new(x1, math.max(entry, tpLast), x2, math.min(entry, tpLast), border_color=na, bgcolor=color.new(C_TP, 85)))
    array.push(trBoxes, box.new(x1, math.max(entry, slP),    x2, math.min(entry, slP),    border_color=na, bgcolor=color.new(C_SL, 85)))

    f_level(x1, x2, entry, "Entry: " + f_fmt(entry), C_ENTRY)
    f_level(x1, x2, tp1, "TP1: " + f_fmt(tp1), C_TP)
    f_level(x1, x2, tp2, "TP2: " + f_fmt(tp2), C_TP)
    f_level(x1, x2, tp3, "TP3: " + f_fmt(tp3), C_TP)
    if showTP4
        f_level(x1, x2, tp4, "TP4: " + f_fmt(tp4), C_TP)
    f_level(x1, x2, slP, "SL: " + f_fmt(slP), C_SL)

// ════════════════════════════════════════════════════════════════
// MULTI-TIMEFRAME TABLE
// ════════════════════════════════════════════════════════════════
tsz = f_size(ttSize)
var table tt = table.new(f_pos(ttPos), 7, 4, bgcolor=na, border_width=1, border_color=bgCol)

if showTT and barstate.islast
    labs = array.new_string()
    vals = array.new_bool()
    if shA
        array.push(labs, f_tf(tfA))
        array.push(vals, tA)
    if shB
        array.push(labs, f_tf(tfB))
        array.push(vals, tB)
    if shC
        array.push(labs, f_tf(tfC))
        array.push(vals, tC)
    if shD
        array.push(labs, f_tf(tfD))
        array.push(vals, tD)
    if shE
        array.push(labs, f_tf(tfE))
        array.push(vals, tE)
    if shF
        array.push(labs, f_tf(tfF))
        array.push(vals, tF)
    n = array.size(labs)

    // rows 0 and 1: Trend / Up-Down
    table.cell(tt, 0, 0, "Trend", text_color=txtCol, bgcolor=bgCol, text_size=tsz)
    table.cell(tt, 0, 1, syminfo.ticker, text_color=txtCol, bgcolor=bgCol, text_size=tsz)
    for i = 0 to 5
        c = i + 1
        if i < n
            up = array.get(vals, i)
            table.cell(tt, c, 0, array.get(labs, i), text_color=txtCol, bgcolor=bgCol, text_size=tsz)
            table.cell(tt, c, 1, up ? "Up" : "Down", text_color=color.white, bgcolor=up ? upCol : dnCol, text_size=tsz)
        else
            table.cell(tt, c, 0, "", bgcolor=na)
            table.cell(tt, c, 1, "", bgcolor=na)

    // rows 2 and 3: POC / Price (Above-Below)
    if showPOCtb
        table.cell(tt, 0, 2, "POC",   text_color=txtCol, bgcolor=bgCol, text_size=tsz)
        table.cell(tt, 0, 3, "Price", text_color=txtCol, bgcolor=bgCol, text_size=tsz)
        table.cell(tt, 1, 2, f_tf(POC_TF1), text_color=txtCol, bgcolor=bgCol, text_size=tsz)
        table.cell(tt, 2, 2, f_tf(POC_TF2), text_color=txtCol, bgcolor=bgCol, text_size=tsz)
        table.cell(tt, 3, 2, f_tf(POC_TF3), text_color=txtCol, bgcolor=bgCol, text_size=tsz)
        table.cell(tt, 1, 3, na(poc1) ? "n/a" : close >= poc1 ? "Above" : "Below", text_color=na(poc1) ? txtCol : color.white, bgcolor=na(poc1) ? bgCol : close >= poc1 ? upCol : dnCol, text_size=tsz)
        table.cell(tt, 2, 3, na(poc2) ? "n/a" : close >= poc2 ? "Above" : "Below", text_color=na(poc2) ? txtCol : color.white, bgcolor=na(poc2) ? bgCol : close >= poc2 ? upCol : dnCol, text_size=tsz)
        table.cell(tt, 3, 3, na(poc3) ? "n/a" : close >= poc3 ? "Above" : "Below", text_color=na(poc3) ? txtCol : color.white, bgcolor=na(poc3) ? bgCol : close >= poc3 ? upCol : dnCol, text_size=tsz)
        for c = 4 to 6
            table.cell(tt, c, 2, "", bgcolor=bgCol, text_size=tsz)
            table.cell(tt, c, 3, "", bgcolor=bgCol, text_size=tsz)
    else
        for r = 2 to 3
            for c = 0 to 6
                table.cell(tt, c, r, "", bgcolor=na)

// ════════════════════════════════════════════════════════════════
// LOW VOLUME + BRAND
// ════════════════════════════════════════════════════════════════
volAvg = ta.sma(volume, 20)
lowVol = not na(volume) and volume < volAvg * LOWVOL_MULT
var table lv    = table.new(position.top_right, 1, 1, bgcolor=na)
var table brand = table.new(position.bottom_right, 1, 1, bgcolor=na)
if barstate.islast
    if lowVol
        table.cell(lv, 0, 0, "Low Volume", text_color=color.white, bgcolor=color.new(#FF5252, 0), text_size=size.small)
    else
        table.cell(lv, 0, 0, "", bgcolor=na)
    table.cell(brand, 0, 0, "Trendshot by MTM", text_color=C_BRAND, bgcolor=na, text_size=size.normal)

// © Ricardo Garcia (RicardoGarciaPT) / MoreThanMoney. All rights reserved.
// This software and source code are the intellectual property of Ricardo Garcia and MoreThanMoney.
````
