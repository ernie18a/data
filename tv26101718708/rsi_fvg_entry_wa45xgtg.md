# RSI + FVG Entry

- url: https://www.tradingview.com/script/wa45XgtG-RSI-FVG-Entry/
- type: indicator
- pine_id: PUB;1e8f896215d14d5089641555a643d6a1
- version: 2.0

## Description

RSI + FVG Entry combines RSI extremes with Fair Value Gaps to identify precise, high-probability entry points during London and New York sessions. RSI overbought/oversold conditions set the bias — Fair Value Gaps provide the exact entry zone.

How it works

When RSI drops below the oversold level, the indicator arms a long setup and scans for a nearby bullish Fair Value Gap (a price imbalance left by a previous impulsive move). When price retraces into that gap, a long entry fires. The same logic applies in reverse for shorts when RSI is overbought.

If RSI divergence is also present at the setup — price making lower lows while RSI makes higher lows (or vice versa) — it is marked on the chart as additional confluence, though it is not required to trigger an entry.

What you see on the chart

FVG zone — the imbalance area used as entry trigger (teal = bullish, orange = bearish), only drawn when it fires
▲ / ▼ Entry signal — triangle below/above the entry bar
TP box — take profit zone based on configurable R:R ratio
SL box — stop loss beyond the FVG with ATR buffer
Entry line — dashed white line at entry price
Divergence lines — dotted lines connecting pivot highs/lows when RSI divergence is detected
Settings

RSI Overbought / Oversold thresholds
Min FVG Size (ATR) — filters out micro gaps
FVG Lookback — how far back to search for valid gaps
SL ATR Mult — stop distance
TP R:R — reward-to-risk ratio
Setup Expire Bars — auto-cancel unarmed setups
London / NY session filters
Recommended: 5m – 15m | EURUSD · GBPUSD · XAUUSD

For educational purposes only. Not financial advice. Always manage your risk.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © EVLabs
//@version=6
indicator("RSI + FVG Entry", overlay=true, max_boxes_count=300, max_lines_count=300, max_labels_count=300)

G_RSI  = "── RSI ──"
G_FVG  = "── Fair Value Gaps ──"
G_SIG  = "── Signals ──"
G_FILT = "── Filters ──"
G_VIS  = "── Display ──"

// ── RSI
rsiLen    = input.int(14,    "RSI Length",             group=G_RSI, minval=1)
rsiOB     = input.float(70,  "Overbought",             group=G_RSI, minval=55, maxval=90)
rsiOS     = input.float(30,  "Oversold",               group=G_RSI, minval=10, maxval=45)

// ── FVG
atrLen    = input.int(14,    "ATR Length",             group=G_FVG, minval=1)
minFvgAtr = input.float(0.2, "Min FVG Size (ATR)",     group=G_FVG, minval=0.05, step=0.05)
fvgMaxAge = input.int(30,    "FVG Max Age (Bars)",     group=G_FVG, minval=5)
minFvgAge = input.int(2,     "FVG Min Age (Bars)",     group=G_FVG, minval=0)
showFvg   = input.bool(true,  "Show Active FVGs",      group=G_FVG)

// ── Signals
atrMult   = input.float(0.5, "SL ATR Buffer",          group=G_SIG, minval=0.1, step=0.1)
rr1       = input.float(1.5, "TP1 R:R",                group=G_SIG, minval=0.5, step=0.5)
rr2       = input.float(3.0, "TP2 R:R",                group=G_SIG, minval=0.5, step=0.5)
setupExp  = input.int(40,    "Setup Expire (Bars)",    group=G_SIG, minval=5)
expBars   = input.int(50,    "Signal Expire (Bars)",   group=G_SIG, minval=10)
cooldown  = input.int(15,    "Cooldown (Bars)",        group=G_SIG, minval=1)

// ── Filters
useEma    = input.bool(false, "EMA Bias Filter",       group=G_FILT, tooltip="Longs only above EMA, shorts only below")
emaLen    = input.int(200,   "EMA Length",             group=G_FILT, minval=10)
useSess   = input.bool(true,  "Session Filter",        group=G_FILT)
sessLon   = input.session("0800-1700", "London",       group=G_FILT)
sessNY    = input.session("1300-2200", "NY",           group=G_FILT)
TZ        = "America/New_York"

// ── Display
showPanel = input.bool(true, "Dashboard", group=G_VIS)

// ════════════════════════════════════════════════════════════════════════════════
// CORE
// ════════════════════════════════════════════════════════════════════════════════
atr    = ta.atr(atrLen)
rsi    = ta.rsi(close, rsiLen)
ema    = ta.ema(close, emaLen)
inSess = not useSess or not na(time(timeframe.period, sessLon, TZ)) or not na(time(timeframe.period, sessNY, TZ))

// ════════════════════════════════════════════════════════════════════════════════
// FAIR VALUE GAPS
// ════════════════════════════════════════════════════════════════════════════════
bullFvg = low > high[2] and (low - high[2]) >= atr * minFvgAtr
bearFvg = high < low[2] and (low[2] - high)  >= atr * minFvgAtr

var float[] bTop = array.new_float()
var float[] bBot = array.new_float()
var int[]   bBar = array.new_int()
var box[]   bBx  = array.new_box()
var bool[]  bMit = array.new_bool()

var float[] sTop = array.new_float()
var float[] sBot = array.new_float()
var int[]   sBar = array.new_int()
var box[]   sBx  = array.new_box()
var bool[]  sMit = array.new_bool()

MAX_FVG = 1

if bullFvg
    bx = showFvg ? box.new(bar_index - 2, low, bar_index, high[2],
         border_color=color.new(#00c853, 50), bgcolor=color.new(#00c853, 85),
         extend=extend.right) : na
    array.push(bTop, low), array.push(bBot, high[2])
    array.push(bBar, bar_index), array.push(bBx, bx), array.push(bMit, false)
    if array.size(bTop) > MAX_FVG
        old = array.shift(bBx)
        if not na(old)
            box.delete(old)
        array.shift(bTop), array.shift(bBot), array.shift(bBar), array.shift(bMit)

if bearFvg
    bx = showFvg ? box.new(bar_index - 2, low[2], bar_index, high,
         border_color=color.new(#ff1744, 50), bgcolor=color.new(#ff1744, 85),
         extend=extend.right) : na
    array.push(sTop, low[2]), array.push(sBot, high)
    array.push(sBar, bar_index), array.push(sBx, bx), array.push(sMit, false)
    if array.size(sTop) > MAX_FVG
        old = array.shift(sBx)
        if not na(old)
            box.delete(old)
        array.shift(sTop), array.shift(sBot), array.shift(sBar), array.shift(sMit)

// Mitigation — delete box immediately
if array.size(bMit) > 0
    for i = array.size(bMit) - 1 to 0
        if not array.get(bMit, i) and close < array.get(bBot, i)
            array.set(bMit, i, true)
            bx = array.get(bBx, i)
            if not na(bx)
                box.delete(bx)
                array.set(bBx, i, na)

if array.size(sMit) > 0
    for i = array.size(sMit) - 1 to 0
        if not array.get(sMit, i) and close > array.get(sTop, i)
            array.set(sMit, i, true)
            bx = array.get(sBx, i)
            if not na(bx)
                box.delete(bx)
                array.set(sBx, i, na)

// ════════════════════════════════════════════════════════════════════════════════
// SETUP ARMING
// ════════════════════════════════════════════════════════════════════════════════
var bool armL = false, var int armLBar = -999
var bool armS = false, var int armSBar = -999

if rsi < rsiOS and inSess and not armL
    armL := true,  armLBar := bar_index
if rsi > rsiOB and inSess and not armS
    armS := true,  armSBar := bar_index
if armL and (bar_index - armLBar) > setupExp
    armL := false
if armS and (bar_index - armSBar) > setupExp
    armS := false

// ════════════════════════════════════════════════════════════════════════════════
// SIGNAL ARRAYS
// ════════════════════════════════════════════════════════════════════════════════
var int[]   sigDir  = array.new_int()
var float[] sigEnt  = array.new_float()
var float[] sigSL   = array.new_float()
var float[] sigTP1  = array.new_float()
var float[] sigTP2  = array.new_float()
var int[]   sigB    = array.new_int()
var int[]   sigRes  = array.new_int()   // 0=open  1=be-active  2=tp2  -1=sl  3=expired
var box[]   sigT1Bx = array.new_box()
var box[]   sigT2Bx = array.new_box()
var box[]   sigSLBx = array.new_box()
var line[]  sigEL   = array.new_line()
var bool[]  sigBE   = array.new_bool()
var int lastSig = -999

hasOpen = false
if array.size(sigRes) > 0
    for i = 0 to array.size(sigRes) - 1
        if array.get(sigRes, i) == 0 or array.get(sigRes, i) == 1
            hasOpen := true

notCool  = (bar_index - lastSig) >= cooldown
emaLong  = not useEma or close > ema
emaShort = not useEma or close < ema

// ════════════════════════════════════════════════════════════════════════════════
// LONG ENTRY
// ════════════════════════════════════════════════════════════════════════════════
longFired = false

if armL and inSess and notCool and not hasOpen and emaLong
    n = array.size(bBar)
    if n > 0
        for i = n - 1 to 0
            if longFired
                break
            if array.get(bMit, i)
                continue
            age = bar_index - array.get(bBar, i)
            if age >= minFvgAge and age <= fvgMaxAge
                fTop = array.get(bTop, i)
                fBot = array.get(bBot, i)
                if low <= fTop and close >= fBot
                    ep   = close
                    slP  = fBot - atr * atrMult
                    risk = ep - slP
                    t1   = ep + risk * rr1
                    t2   = ep + risk * rr2
                    x1   = bar_index
                    bx   = array.get(bBx, i)
                    if not na(bx)
                        box.delete(bx)
                        array.set(bBx, i, na)
                    t1Bx = box.new(x1, t1,  x1+1, ep,  bgcolor=color.new(color.green, 82), border_color=color.new(color.green, 30), text="TP1", text_color=color.white, text_size=size.tiny, extend=extend.right)
                    t2Bx = box.new(x1, t2,  x1+1, t1,  bgcolor=color.new(color.lime,  88), border_color=color.new(color.lime,  20), text="TP2", text_color=color.white, text_size=size.tiny, extend=extend.right)
                    slBx = box.new(x1, ep,  x1+1, slP, bgcolor=color.new(color.red,   82), border_color=color.new(color.red,   20), extend=extend.right)
                    eL   = line.new(x1, ep, x1+1, ep, color=color.new(color.white, 20), style=line.style_dashed, width=2, extend=extend.right)
                    label.new(x1, na, "▲", yloc=yloc.belowbar, color=color.new(color.teal, 10), textcolor=color.white, style=label.style_label_up, size=size.normal)
                    array.push(sigDir, 1),   array.push(sigEnt, ep),   array.push(sigSL, slP)
                    array.push(sigTP1, t1),  array.push(sigTP2, t2),   array.push(sigB, x1)
                    array.push(sigRes, 0),   array.push(sigT1Bx, t1Bx),array.push(sigT2Bx, t2Bx)
                    array.push(sigSLBx, slBx), array.push(sigEL, eL),  array.push(sigBE, false)
                    armL := false, lastSig := x1, longFired := true

// ════════════════════════════════════════════════════════════════════════════════
// SHORT ENTRY
// ════════════════════════════════════════════════════════════════════════════════
shortFired = false

if armS and inSess and notCool and not hasOpen and emaShort
    n = array.size(sBar)
    if n > 0
        for i = n - 1 to 0
            if shortFired
                break
            if array.get(sMit, i)
                continue
            age = bar_index - array.get(sBar, i)
            if age >= minFvgAge and age <= fvgMaxAge
                fTop = array.get(sTop, i)
                fBot = array.get(sBot, i)
                if high >= fBot and close <= fTop
                    ep   = close
                    slP  = fTop + atr * atrMult
                    risk = slP - ep
                    t1   = ep - risk * rr1
                    t2   = ep - risk * rr2
                    x1   = bar_index
                    bx   = array.get(sBx, i)
                    if not na(bx)
                        box.delete(bx)
                        array.set(sBx, i, na)
                    t1Bx = box.new(x1, ep,  x1+1, t1,  bgcolor=color.new(color.green, 82), border_color=color.new(color.green, 30), text="TP1", text_color=color.white, text_size=size.tiny, extend=extend.right)
                    t2Bx = box.new(x1, t1,  x1+1, t2,  bgcolor=color.new(color.lime,  88), border_color=color.new(color.lime,  20), text="TP2", text_color=color.white, text_size=size.tiny, extend=extend.right)
                    slBx = box.new(x1, slP, x1+1, ep,  bgcolor=color.new(color.red,   82), border_color=color.new(color.red,   20), extend=extend.right)
                    eL   = line.new(x1, ep, x1+1, ep, color=color.new(color.white, 20), style=line.style_dashed, width=2, extend=extend.right)
                    label.new(x1, na, "▼", yloc=yloc.abovebar, color=color.new(color.orange, 10), textcolor=color.white, style=label.style_label_down, size=size.normal)
                    array.push(sigDir, -1),  array.push(sigEnt, ep),   array.push(sigSL, slP)
                    array.push(sigTP1, t1),  array.push(sigTP2, t2),   array.push(sigB, x1)
                    array.push(sigRes, 0),   array.push(sigT1Bx, t1Bx),array.push(sigT2Bx, t2Bx)
                    array.push(sigSLBx, slBx), array.push(sigEL, eL),  array.push(sigBE, false)
                    armS := false, lastSig := x1, shortFired := true

// ════════════════════════════════════════════════════════════════════════════════
// RESOLUTION + BREAK-EVEN
// ════════════════════════════════════════════════════════════════════════════════
tp1Hit = false
tp2Hit = false
slHit  = false

if array.size(sigRes) > 0
    for i = 0 to array.size(sigRes) - 1
        res_i = array.get(sigRes, i)
        if res_i == 0 or res_i == 1
            d    = array.get(sigDir,  i)
            ep   = array.get(sigEnt,  i)
            t1   = array.get(sigTP1,  i)
            t2   = array.get(sigTP2,  i)
            sB   = array.get(sigB,    i)
            t1Bx = array.get(sigT1Bx, i)
            t2Bx = array.get(sigT2Bx, i)
            slBx = array.get(sigSLBx, i)
            eL   = array.get(sigEL,   i)
            beOn = array.get(sigBE,   i)

            // Break-even: TP1 touched → SL moves to entry, SL box turns amber
            if not beOn
                beTriggered = (d == 1 and high >= t1) or (d == -1 and low <= t1)
                if beTriggered
                    array.set(sigBE,  i, true)
                    array.set(sigSL,  i, ep)
                    array.set(sigRes, i, 1)
                    box.set_bgcolor(slBx, color.new(#f59e0b, 88))
                    box.set_border_color(slBx, color.new(#f59e0b, 30))
                    tp1Hit := true

            sl  = array.get(sigSL, i)
            hit = false
            res = array.get(sigRes, i)

            if d == 1
                if high >= t2
                    res := 2,  hit := true,  tp2Hit := true
                else if low <= sl
                    res := -1, hit := true,  slHit  := true
            else
                if low <= t2
                    res := 2,  hit := true,  tp2Hit := true
                else if high >= sl
                    res := -1, hit := true,  slHit  := true

            if not hit and (bar_index - sB) >= expBars
                res := 3,  hit := true

            if hit
                array.set(sigRes, i, res)
                box.set_extend(t1Bx, extend.none), box.set_right(t1Bx, bar_index)
                box.set_extend(t2Bx, extend.none), box.set_right(t2Bx, bar_index)
                box.set_extend(slBx, extend.none), box.set_right(slBx, bar_index)
                line.set_extend(eL, extend.none),  line.set_x2(eL, bar_index)
                if res == 2
                    box.set_bgcolor(t2Bx, color.new(color.lime, 60))
                if res == -1
                    box.set_bgcolor(slBx, color.new(color.red, 60))

// ════════════════════════════════════════════════════════════════════════════════
// EMA PLOT
// ════════════════════════════════════════════════════════════════════════════════
plot(useEma ? ema : na, "EMA", color=color.new(#f59e0b, 40), linewidth=1)

// ════════════════════════════════════════════════════════════════════════════════
// DASHBOARD
// ════════════════════════════════════════════════════════════════════════════════
var table dash = na
if showPanel and barstate.islast
    if not na(dash)
        table.delete(dash)
    dash := table.new(position.top_right, 2, 6,
        bgcolor=color.new(#1e222d, 5),
        border_width=1, border_color=color.new(#434651, 40),
        frame_width=1,  frame_color=color.new(#434651, 20))
    _c0 = color.new(#1e222d, 0)
    _ct = color.new(#787b86, 0)
    _cw = color.new(color.white, 0)
    rsiCol  = rsi >= rsiOB ? color.new(#ff1744, 0) : rsi <= rsiOS ? color.new(#00c853, 0) : _ct
    sessCol = inSess ? color.new(color.lime, 0) : _ct
    armLCol = armL ? color.new(color.teal,   0) : _ct
    armSCol = armS ? color.new(color.orange, 0) : _ct
    table.cell(dash, 0, 0, "RSI+FVG", bgcolor=_c0, text_color=_cw, text_size=size.small)
    table.cell(dash, 1, 0, "",        bgcolor=_c0, text_color=_ct, text_size=size.small)
    table.cell(dash, 0, 1, "RSI",     bgcolor=_c0, text_color=_ct, text_size=size.tiny)
    table.cell(dash, 1, 1, str.tostring(rsi, "#.0"), bgcolor=color.new(rsiCol, 85), text_color=_cw, text_size=size.small)
    table.cell(dash, 0, 2, "Session", bgcolor=_c0, text_color=_ct, text_size=size.tiny)
    table.cell(dash, 1, 2, inSess ? "Open" : "Closed", bgcolor=_c0, text_color=sessCol, text_size=size.small)
    table.cell(dash, 0, 3, "Arm L",   bgcolor=_c0, text_color=_ct, text_size=size.tiny)
    table.cell(dash, 1, 3, armL ? "Armed ▲" : "–", bgcolor=_c0, text_color=armLCol, text_size=size.small)
    table.cell(dash, 0, 4, "Arm S",   bgcolor=_c0, text_color=_ct, text_size=size.tiny)
    table.cell(dash, 1, 4, armS ? "Armed ▼" : "–", bgcolor=_c0, text_color=armSCol, text_size=size.small)
    emaStr = not useEma ? "Off" : close > ema ? "Above ▲" : "Below ▼"
    emaCol  = not useEma ? _ct : close > ema ? color.new(color.lime, 0) : color.new(color.red, 0)
    table.cell(dash, 0, 5, "EMA",     bgcolor=_c0, text_color=_ct, text_size=size.tiny)
    table.cell(dash, 1, 5, emaStr,    bgcolor=_c0, text_color=emaCol, text_size=size.small)

// ════════════════════════════════════════════════════════════════════════════════
// ALERTS
// ════════════════════════════════════════════════════════════════════════════════
alertcondition(longFired,  "RSI+FVG Long",    "RSI+FVG Entry — Long signal @ {{close}} on {{ticker}}")
alertcondition(shortFired, "RSI+FVG Short",   "RSI+FVG Entry — Short signal @ {{close}} on {{ticker}}")
alertcondition(tp1Hit,     "TP1 / Breakeven", "RSI+FVG Entry — TP1 hit, SL moved to breakeven")
alertcondition(tp2Hit,     "TP2 Hit",         "RSI+FVG Entry — TP2 hit, full target reached")
alertcondition(slHit,      "SL Hit",          "RSI+FVG Entry — Stop loss hit")
````
