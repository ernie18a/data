# Fibo/FVG

- url: https://www.tradingview.com/script/058CAuCS-Fibo-FVG/
- type: indicator
- pine_id: PUB;7b2370992fb74d849a31e06cb030822a
- version: 2.0

## Description

What is the Optimal Trade Entry?

The Optimal Trade Entry (OTE) is a precision entry model based on Fibonacci retracement theory. After a significant swing high or swing low is formed, smart money rarely re-enters a move at the breakout point — instead, price is drawn back into a specific retracement window before continuing in the original direction. That window is the 61.8%–78.6% retracement of the prior swing, with the 70.5% level acting as the ideal midpoint entry.

This concept differs from a standard Fibonacci tool in a fundamental way: it is not used to draw levels and wait passively. It is a trigger-based framework — the setup only activates when price structure, session timing, and zone confluence align simultaneously. A retracement into this range during a low-liquidity period or outside a relevant session is ignored entirely.

Why this indicator is different

Most Fibonacci-based tools draw static levels and leave interpretation to the trader. This indicator automates the full OTE workflow:

Detects a confirmed swing structure (swing low followed by swing high for bullish, or swing high followed by swing low for bearish)
Validates the setup is occurring within London or New York session hours
Applies an optional minimum swing size filter to reject low-quality setups where the range is too small relative to current volatility (ATR)
Checks that price has actually retraced into the 61.8%–78.6% zone before triggering
Draws all relevant levels automatically and tracks the outcome in real time
Every signal is tracked from entry to resolution — either TP1 hit, stop hit, or expired — with the result displayed in the live setup table.

Limit Orders mode

Standard mode fires when price is already inside the OTE zone. This works for active traders watching the screen, but means you are reacting to price that has already moved.

With Use Limit Orders enabled, the alert fires the moment the swing structure is confirmed and session conditions are met — before price reaches the OTE zone. This gives you time to place a pending limit order at the 70.5% entry level and walk away. The setup table shows PENDING in orange until price reaches the entry level, at which point it switches to ACTIVE and the stop/target tracking begins. If price never reaches the entry level within the configured expiry window, the setup is discarded automatically.

Entry and risk levels

All levels are calculated from the confirmed swing range:

Level	Fibonacci	Role
0%	Swing extreme (origin)	Reference
61.8%	OTE zone top	Zone boundary
70.5%	OTE midpoint	Entry
78.6%	OTE zone bottom	Zone boundary
100%	Opposite swing extreme	Reference
-27.2%	Extension	TP1
-61.8%	Extension	TP2
Stop	Swing extreme ± ATR buffer	Dynamic SL
The stop loss is placed beyond the originating swing extreme with an ATR-based buffer, adapting to current market volatility rather than using a fixed pip distance.

Visual elements

Yellow box: OTE retracement zone (61.8%–78.6%), drawn from the swing origin to the trigger bar
Dashed white line: entry level at 70.5%, extends until the setup resolves
Green box: TP1 zone between entry and -27.2% extension
Red box: stop loss zone between entry and stop level
Dotted labeled lines: full Fibonacci map with text labels (0%, 61.8%, 70.5% Entry, 78.6%, 100%), extending to the right until the setup closes
Setup table

The top-right panel shows the live state of the most recent open setup:

EV OTE / Status: indicator name and current state (-- / PENDING / ACTIVE)
Dir: Long or Short
Entry: exact entry price at 70.5%
TP1: first target at -27.2% extension
TP2: second target at -61.8% extension
SL: stop loss level
R:R: reward-to-risk ratio based on TP1
Settings reference

Detection

Swing Length: number of bars used to confirm a pivot high or low. Higher values detect larger, more significant swings but add lag.
Risk

SL ATR Mult: multiplier applied to ATR for stop placement beyond the swing extreme. Controls the buffer size.
Cooldown Bars: minimum bars that must pass after a signal before a new one can trigger. Prevents clustering.
Expire After Bars: if a setup (or pending limit) has not resolved within this many bars, it is marked expired and cleared.
Use Limit Orders: changes trigger logic from zone-entry (reactive) to swing-confirmation (anticipatory). Recommended for traders who want to set and forget limit orders.
Filters

Min Swing Filter: when enabled, rejects any setup where the swing range is smaller than the minimum swing multiplier × ATR. Removes setups during low-volatility compression.
Min Swing (x ATR): the threshold multiplier for the above filter.
Display

Show Setup Table: toggles the live setup panel in the top-right corner.
Show Fib Levels: toggles the labeled Fibonacci dotted lines.
Sessions

London Session: default 08:00–17:00. Adjust to your broker's session times if needed.
NY Session: default 13:00–22:00.
All times are interpreted in America/New_York timezone.
Alerts

EV OTE — Long: fires when a bullish OTE setup is detected (or swing confirmed in Limit Orders mode)
EV OTE — Short: fires when a bearish OTE setup is detected (or swing confirmed in Limit Orders mode)
Use TradingView's alert system to receive notifications and set your limit orders before price reaches the zone.

Important notes

This indicator is a technical analysis tool designed to identify trade setups based on price structure and Fibonacci methodology. It does not guarantee any particular outcome. All signals should be used in conjunction with your own analysis, risk management rules, and trading plan. Past setup performance visible on historical bars is not indicative of future results.

## Source Code

````pine
//@version=6
indicator("EV OTE + FVG | ICT Fibonacci Entry", shorttitle="EV OTE+FVG", overlay=true,
          max_boxes_count=500, max_lines_count=350, max_labels_count=200)

// ─── Inputs ───────────────────────────────────────────────────────────────────
swingLen     = input.int(10,    "Swing Length",         minval=2,             group="Detection")
atrLen       = input.int(14,    "ATR Length",           minval=1,             group="Detection")
atrMult      = input.float(0.5, "SL ATR Mult",          minval=0.1, step=0.1, group="Risk")
cooldown     = input.int(20,    "Cooldown Bars",        minval=1,             group="Risk")
expireBars   = input.int(50,    "Expire After Bars",    minval=10,            group="Risk")
useLimits    = input.bool(false, "Use Limit Orders",                          group="Risk")
useMinSwing  = input.bool(true,  "Min Swing Filter",                          group="Filters")
minSwingMult = input.float(2.0,  "Min Swing (x ATR)",   minval=0.5, step=0.5, group="Filters")
showFVG      = input.bool(true,  "Show FVG Boxes",                            group="FVG")
requireFVG   = input.bool(false, "Require FVG Confluence",                    group="FVG")
fvgExpire    = input.int(50,    "FVG Expire (bars)",    minval=5, maxval=200, group="FVG")
showTable    = input.bool(true,  "Show Setup Table",                          group="Display")
showFibLvls  = input.bool(true,  "Show Fib Levels",                           group="Display")
sessionLon   = input.session("0800-1700", "London Session",                   group="Sessions")
sessionNY    = input.session("1300-2200", "NY Session",                       group="Sessions")
tz           = "America/New_York"

// ─── Base ─────────────────────────────────────────────────────────────────────
inSess = not na(time(timeframe.period, sessionLon, tz)) or not na(time(timeframe.period, sessionNY, tz))
atr    = ta.atr(atrLen)

// ─── Swings ───────────────────────────────────────────────────────────────────
swH = ta.pivothigh(high, swingLen, swingLen)
swL = ta.pivotlow(low,   swingLen, swingLen)

var float sHigh    = na
var int   sHighBar = na
var float sLow     = na
var int   sLowBar  = na

if not na(swH)
    sHigh    := swH
    sHighBar := bar_index - swingLen
if not na(swL)
    sLow    := swL
    sLowBar := bar_index - swingLen

f_bull(lo, hi, lvl) => hi - (hi - lo) * lvl
f_bear(hi, lo, lvl) => lo + (hi - lo) * lvl
prc(v, d)           => d != 0 ? str.tostring(v, "#.####") : "--"

// ─── FVG arrays ───────────────────────────────────────────────────────────────
var float[] fvgTop  = array.new_float()
var float[] fvgBot  = array.new_float()
var int[]   fvgDir  = array.new_int()
var int[]   fvgBar  = array.new_int()
var box[]   fvgBoxA = array.new_box()

// ─── FVG confluence helper ────────────────────────────────────────────────────
f_hasFVG(dir, zTop, zBot) =>
    found = false
    sz = array.size(fvgDir)
    if sz > 0
        for i = 0 to sz - 1
            if array.get(fvgDir, i) == dir
                fT = array.get(fvgTop, i)
                fL = array.get(fvgBot, i)
                if fT >= zBot and fL <= zTop
                    found := true
                    break
    found

// ─── Signal arrays ────────────────────────────────────────────────────────────
var int[]   sigDir    = array.new_int()
var float[] sigEntry  = array.new_float()
var float[] sigSL     = array.new_float()
var float[] sigTP1    = array.new_float()
var float[] sigTP2    = array.new_float()
var float[] sigOteTop = array.new_float()
var float[] sigOteBot = array.new_float()
var int[]   sigBar    = array.new_int()
var int[]   sigRes    = array.new_int()
var bool[]  sigFilled = array.new_bool()
var box[]   sigTpBox  = array.new_box()
var box[]   sigSlBox  = array.new_box()
var line[]  sigEntryL = array.new_line()

var int lastSigBar = -999

var line  fibL1  = na
var line  fibL2  = na
var line  fibL3  = na
var line  fibL4  = na
var line  fibL5  = na
var label fibLb1 = na
var label fibLb2 = na
var label fibLb3 = na
var label fibLb4 = na
var label fibLb5 = na

// ─── State ────────────────────────────────────────────────────────────────────
hasOpen = false
if array.size(sigRes) > 0
    for i = 0 to array.size(sigRes) - 1
        if array.get(sigRes, i) == 0
            hasOpen := true

inCooldown = (bar_index - lastSigBar) < cooldown
swingOk    = not (na(sHigh) or na(sLow)) and (not useMinSwing or math.abs(sHigh - sLow) >= atr * minSwingMult)

alertLong  = false
alertShort = false

// ─── FVG mitigation + extend ──────────────────────────────────────────────────
_fvgN = array.size(fvgDir)
if _fvgN > 0
    _ii = _fvgN - 1
    while _ii >= 0
        d   = array.get(fvgDir,  _ii)
        fT  = array.get(fvgTop,  _ii)
        fL  = array.get(fvgBot,  _ii)
        fb  = array.get(fvgBar,  _ii)
        fBx = array.get(fvgBoxA, _ii)
        gone = (d == 1 and low <= fL) or (d == -1 and high >= fT) or (bar_index - fb) > fvgExpire
        if gone
            if not na(fBx)
                box.delete(fBx)
            array.remove(fvgTop,  _ii)
            array.remove(fvgBot,  _ii)
            array.remove(fvgDir,  _ii)
            array.remove(fvgBar,  _ii)
            array.remove(fvgBoxA, _ii)
        else if not na(fBx)
            box.set_right(fBx, bar_index + 1)
        _ii -= 1

// ─── FVG detection ────────────────────────────────────────────────────────────
if inSess
    if high[2] < low[0]
        fH  = low[0]
        fL  = high[2]
        fBx = showFVG ? box.new(bar_index - 2, fH, bar_index + 1, fL,
                                border_color=color.new(#26a69a, 60),
                                bgcolor=color.new(#26a69a, 90)) : na
        array.push(fvgTop,  fH)
        array.push(fvgBot,  fL)
        array.push(fvgDir,  1)
        array.push(fvgBar,  bar_index)
        array.push(fvgBoxA, fBx)

    if low[2] > high[0]
        fH  = low[2]
        fL  = high[0]
        fBx = showFVG ? box.new(bar_index - 2, fH, bar_index + 1, fL,
                                border_color=color.new(#ef5350, 60),
                                bgcolor=color.new(#ef5350, 90)) : na
        array.push(fvgTop,  fH)
        array.push(fvgBot,  fL)
        array.push(fvgDir,  -1)
        array.push(fvgBar,  bar_index)
        array.push(fvgBoxA, fBx)

// ─── Setup detection ─────────────────────────────────────────────────────────
if inSess and swingOk and not inCooldown and not hasOpen

    if sLowBar < sHighBar
        oteTop  = f_bull(sLow, sHigh, 0.618)
        oteBot  = f_bull(sLow, sHigh, 0.786)
        entryP  = f_bull(sLow, sHigh, 0.705)
        slP     = sLow - atr * atrMult
        tp1P    = f_bull(sLow, sHigh, -0.272)
        tp2P    = f_bull(sLow, sHigh, -0.618)
        fvgConf = not requireFVG or f_hasFVG(1, oteTop, oteBot)
        trigger = (useLimits or (low <= oteTop and close >= oteBot)) and fvgConf
        if trigger
            x1    = bar_index
            box.new(sHighBar, oteTop, x1, oteBot, border_color=color.new(color.yellow, 40), bgcolor=color.new(color.yellow, 85))
            tpBox = box.new(x1, tp1P,   x1 + 1, entryP, border_color=color.new(color.green, 20), bgcolor=color.new(color.green, 80))
            slBox = box.new(x1, entryP, x1 + 1, slP,    border_color=color.new(color.red,   20), bgcolor=color.new(color.red,   80))
            eL    = line.new(x1, entryP, x1 + 1, entryP, color=color.white, style=line.style_dashed, width=2)
            line.new(sHighBar, tp2P, x1, tp2P, color=color.new(color.green, 50), style=line.style_dotted)
            if showFibLvls
                if not na(fibL1)
                    line.delete(fibL1)
                if not na(fibL2)
                    line.delete(fibL2)
                if not na(fibL3)
                    line.delete(fibL3)
                if not na(fibL4)
                    line.delete(fibL4)
                if not na(fibL5)
                    line.delete(fibL5)
                if not na(fibLb1)
                    label.delete(fibLb1)
                if not na(fibLb2)
                    label.delete(fibLb2)
                if not na(fibLb3)
                    label.delete(fibLb3)
                if not na(fibLb4)
                    label.delete(fibLb4)
                if not na(fibLb5)
                    label.delete(fibLb5)
                fibL1  := line.new(sHighBar, sHigh,  x1, sHigh,  color=color.new(color.gray,   50), style=line.style_dotted, extend=extend.right)
                fibL2  := line.new(sHighBar, oteTop, x1, oteTop, color=color.new(color.yellow,  40), style=line.style_dotted, extend=extend.right)
                fibL3  := line.new(sHighBar, entryP, x1, entryP, color=color.new(color.white,   40), style=line.style_dotted, extend=extend.right)
                fibL4  := line.new(sHighBar, oteBot, x1, oteBot, color=color.new(color.yellow,  40), style=line.style_dotted, extend=extend.right)
                fibL5  := line.new(sHighBar, sLow,   x1, sLow,   color=color.new(color.gray,    50), style=line.style_dotted, extend=extend.right)
                fibLb1 := label.new(x1 + 2, sHigh,  "0%",          style=label.style_none, color=color.new(color.black, 100), textcolor=color.new(color.gray,   20), size=size.tiny)
                fibLb2 := label.new(x1 + 2, oteTop, "61.8%",       style=label.style_none, color=color.new(color.black, 100), textcolor=color.new(color.yellow, 20), size=size.tiny)
                fibLb3 := label.new(x1 + 2, entryP, "70.5% Entry", style=label.style_none, color=color.new(color.black, 100), textcolor=color.new(color.white,  20), size=size.tiny)
                fibLb4 := label.new(x1 + 2, oteBot, "78.6%",       style=label.style_none, color=color.new(color.black, 100), textcolor=color.new(color.yellow, 20), size=size.tiny)
                fibLb5 := label.new(x1 + 2, sLow,   "100%",        style=label.style_none, color=color.new(color.black, 100), textcolor=color.new(color.gray,   20), size=size.tiny)
            array.push(sigDir,    1)
            array.push(sigEntry,  entryP)
            array.push(sigSL,     slP)
            array.push(sigTP1,    tp1P)
            array.push(sigTP2,    tp2P)
            array.push(sigOteTop, oteTop)
            array.push(sigOteBot, oteBot)
            array.push(sigBar,    x1)
            array.push(sigRes,    0)
            array.push(sigFilled, not useLimits)
            array.push(sigTpBox,  tpBox)
            array.push(sigSlBox,  slBox)
            array.push(sigEntryL, eL)
            lastSigBar := x1
            alertLong  := true

    else if sHighBar < sLowBar
        oteBot  = f_bear(sHigh, sLow, 0.618)
        oteTop  = f_bear(sHigh, sLow, 0.786)
        entryP  = f_bear(sHigh, sLow, 0.705)
        slP     = sHigh + atr * atrMult
        tp1P    = f_bear(sHigh, sLow, -0.272)
        tp2P    = f_bear(sHigh, sLow, -0.618)
        fvgConf = not requireFVG or f_hasFVG(-1, oteTop, oteBot)
        trigger = (useLimits or (high >= oteBot and close <= oteTop)) and fvgConf
        if trigger
            x1    = bar_index
            box.new(sLowBar, oteTop, x1, oteBot, border_color=color.new(color.yellow, 40), bgcolor=color.new(color.yellow, 85))
            tpBox = box.new(x1, entryP, x1 + 1, tp1P,   border_color=color.new(color.green, 20), bgcolor=color.new(color.green, 80))
            slBox = box.new(x1, slP,    x1 + 1, entryP, border_color=color.new(color.red,   20), bgcolor=color.new(color.red,   80))
            eL    = line.new(x1, entryP, x1 + 1, entryP, color=color.white, style=line.style_dashed, width=2)
            line.new(sLowBar, tp2P, x1, tp2P, color=color.new(color.green, 50), style=line.style_dotted)
            if showFibLvls
                if not na(fibL1)
                    line.delete(fibL1)
                if not na(fibL2)
                    line.delete(fibL2)
                if not na(fibL3)
                    line.delete(fibL3)
                if not na(fibL4)
                    line.delete(fibL4)
                if not na(fibL5)
                    line.delete(fibL5)
                if not na(fibLb1)
                    label.delete(fibLb1)
                if not na(fibLb2)
                    label.delete(fibLb2)
                if not na(fibLb3)
                    label.delete(fibLb3)
                if not na(fibLb4)
                    label.delete(fibLb4)
                if not na(fibLb5)
                    label.delete(fibLb5)
                fibL1  := line.new(sLowBar, sLow,   x1, sLow,   color=color.new(color.gray,   50), style=line.style_dotted, extend=extend.right)
                fibL2  := line.new(sLowBar, oteBot, x1, oteBot, color=color.new(color.yellow,  40), style=line.style_dotted, extend=extend.right)
                fibL3  := line.new(sLowBar, entryP, x1, entryP, color=color.new(color.white,   40), style=line.style_dotted, extend=extend.right)
                fibL4  := line.new(sLowBar, oteTop, x1, oteTop, color=color.new(color.yellow,  40), style=line.style_dotted, extend=extend.right)
                fibL5  := line.new(sLowBar, sHigh,  x1, sHigh,  color=color.new(color.gray,    50), style=line.style_dotted, extend=extend.right)
                fibLb1 := label.new(x1 + 2, sLow,   "0%",          style=label.style_none, color=color.new(color.black, 100), textcolor=color.new(color.gray,   20), size=size.tiny)
                fibLb2 := label.new(x1 + 2, oteBot, "61.8%",       style=label.style_none, color=color.new(color.black, 100), textcolor=color.new(color.yellow, 20), size=size.tiny)
                fibLb3 := label.new(x1 + 2, entryP, "70.5% Entry", style=label.style_none, color=color.new(color.black, 100), textcolor=color.new(color.white,  20), size=size.tiny)
                fibLb4 := label.new(x1 + 2, oteTop, "78.6%",       style=label.style_none, color=color.new(color.black, 100), textcolor=color.new(color.yellow, 20), size=size.tiny)
                fibLb5 := label.new(x1 + 2, sHigh,  "100%",        style=label.style_none, color=color.new(color.black, 100), textcolor=color.new(color.gray,   20), size=size.tiny)
            array.push(sigDir,    -1)
            array.push(sigEntry,  entryP)
            array.push(sigSL,     slP)
            array.push(sigTP1,    tp1P)
            array.push(sigTP2,    tp2P)
            array.push(sigOteTop, oteTop)
            array.push(sigOteBot, oteBot)
            array.push(sigBar,    x1)
            array.push(sigRes,    0)
            array.push(sigFilled, not useLimits)
            array.push(sigTpBox,  tpBox)
            array.push(sigSlBox,  slBox)
            array.push(sigEntryL, eL)
            lastSigBar := x1
            alertShort := true

// ─── Fill tracking + Resolution ───────────────────────────────────────────────
if array.size(sigRes) > 0
    for i = 0 to array.size(sigRes) - 1
        if array.get(sigRes, i) == 0
            d      = array.get(sigDir,    i)
            entry  = array.get(sigEntry,  i)
            sl     = array.get(sigSL,     i)
            tp1    = array.get(sigTP1,    i)
            sBar   = array.get(sigBar,    i)
            tpB    = array.get(sigTpBox,  i)
            slB    = array.get(sigSlBox,  i)
            eL     = array.get(sigEntryL, i)
            filled = array.get(sigFilled, i)

            if not filled
                if d == 1 and low <= entry
                    array.set(sigFilled, i, true)
                    filled := true
                else if d == -1 and high >= entry
                    array.set(sigFilled, i, true)
                    filled := true
                if not filled and (bar_index - sBar) >= expireBars
                    array.set(sigRes, i, 2)
                    box.set_right(tpB, bar_index)
                    box.set_right(slB, bar_index)
                    line.set_x2(eL, bar_index)
                    if showFibLvls
                        if not na(fibL1)
                            line.delete(fibL1)
                            fibL1 := na
                        if not na(fibL2)
                            line.delete(fibL2)
                            fibL2 := na
                        if not na(fibL3)
                            line.delete(fibL3)
                            fibL3 := na
                        if not na(fibL4)
                            line.delete(fibL4)
                            fibL4 := na
                        if not na(fibL5)
                            line.delete(fibL5)
                            fibL5 := na
                        if not na(fibLb1)
                            label.delete(fibLb1)
                            fibLb1 := na
                        if not na(fibLb2)
                            label.delete(fibLb2)
                            fibLb2 := na
                        if not na(fibLb3)
                            label.delete(fibLb3)
                            fibLb3 := na
                        if not na(fibLb4)
                            label.delete(fibLb4)
                            fibLb4 := na
                        if not na(fibLb5)
                            label.delete(fibLb5)
                            fibLb5 := na

            if filled and array.get(sigRes, i) == 0
                hit = false
                res = 0
                if d == 1
                    if high >= tp1
                        res := 1
                        hit := true
                    else if low <= sl
                        res := -1
                        hit := true
                else
                    if low <= tp1
                        res := 1
                        hit := true
                    else if high >= sl
                        res := -1
                        hit := true
                if not hit and (bar_index - sBar) >= expireBars
                    res := 2
                    hit := true
                if hit
                    array.set(sigRes, i, res)
                    box.set_right(tpB, bar_index)
                    box.set_right(slB, bar_index)
                    line.set_x2(eL, bar_index)
                    if showFibLvls
                        if not na(fibL1)
                            line.delete(fibL1)
                            fibL1 := na
                        if not na(fibL2)
                            line.delete(fibL2)
                            fibL2 := na
                        if not na(fibL3)
                            line.delete(fibL3)
                            fibL3 := na
                        if not na(fibL4)
                            line.delete(fibL4)
                            fibL4 := na
                        if not na(fibL5)
                            line.delete(fibL5)
                            fibL5 := na
                        if not na(fibLb1)
                            label.delete(fibLb1)
                            fibLb1 := na
                        if not na(fibLb2)
                            label.delete(fibLb2)
                            fibLb2 := na
                        if not na(fibLb3)
                            label.delete(fibLb3)
                            fibLb3 := na
                        if not na(fibLb4)
                            label.delete(fibLb4)
                            fibLb4 := na
                        if not na(fibLb5)
                            label.delete(fibLb5)
                            fibLb5 := na

// ─── Setup table ─────────────────────────────────────────────────────────────
var table setupT = table.new(position.top_right, 2, 8,
                              bgcolor=color.new(color.black, 70), border_color=color.gray,
                              border_width=1, frame_color=color.gray, frame_width=1)

if barstate.islast and showTable
    curDir    = 0
    curEntry  = 0.0
    curTP1    = 0.0
    curTP2    = 0.0
    curSL     = 0.0
    curOteTop = 0.0
    curOteBot = 0.0
    curFilled = false
    lastOpen  = -1
    if array.size(sigRes) > 0
        for i = 0 to array.size(sigRes) - 1
            if array.get(sigRes, i) == 0
                lastOpen := i
    if lastOpen >= 0
        curDir    := array.get(sigDir,    lastOpen)
        curEntry  := array.get(sigEntry,  lastOpen)
        curTP1    := array.get(sigTP1,    lastOpen)
        curTP2    := array.get(sigTP2,    lastOpen)
        curSL     := array.get(sigSL,     lastOpen)
        curOteTop := array.get(sigOteTop, lastOpen)
        curOteBot := array.get(sigOteBot, lastOpen)
        curFilled := array.get(sigFilled, lastOpen)

    hasSignal   = lastOpen >= 0
    d           = hasSignal ? 1 : 0
    dirStr      = curDir == 1 ? "Long  " : curDir == -1 ? "Short" : "--"
    dirCol      = curDir == 1 ? color.new(#26a69a, 0) : curDir == -1 ? color.new(#ef5350, 0) : color.gray
    statStr     = not hasSignal ? "--" : useLimits and not curFilled ? "PENDING" : "ACTIVE"
    statCol     = not hasSignal ? color.gray : useLimits and not curFilled ? color.orange : color.white
    tpDist      = hasSignal ? math.abs(curTP1 - curEntry) : 0.0
    slDist      = hasSignal ? math.abs(curEntry - curSL)  : 0.0
    rrVal       = slDist > 0 ? tpDist / slDist : 0.0
    hasFvgConfl = hasSignal and f_hasFVG(curDir, curOteTop, curOteBot)
    fvgStr      = not hasSignal ? "--" : hasFvgConfl ? "yes" : "no"
    fvgCol      = not hasSignal ? color.gray : hasFvgConfl ? color.new(#26a69a, 0) : color.new(color.gray, 20)

    table.cell(setupT, 0, 0, "EV OTE", text_color=color.white, bgcolor=color.new(color.blue, 50))
    table.cell(setupT, 1, 0, statStr,  text_color=statCol,     bgcolor=color.new(color.blue, 50))
    table.cell(setupT, 0, 1, "Dir",    text_color=color.white)
    table.cell(setupT, 1, 1, dirStr,   text_color=dirCol)
    table.cell(setupT, 0, 2, "Entry",  text_color=color.white)
    table.cell(setupT, 1, 2, prc(curEntry, d), text_color=color.white)
    table.cell(setupT, 0, 3, "TP1",   text_color=color.white)
    table.cell(setupT, 1, 3, prc(curTP1, d),   text_color=color.new(#26a69a, 0))
    table.cell(setupT, 0, 4, "TP2",   text_color=color.white)
    table.cell(setupT, 1, 4, prc(curTP2, d),   text_color=color.new(#26a69a, 0))
    table.cell(setupT, 0, 5, "SL",    text_color=color.white)
    table.cell(setupT, 1, 5, prc(curSL, d),    text_color=color.new(#ef5350, 0))
    table.cell(setupT, 0, 6, "R:R",   text_color=color.white)
    table.cell(setupT, 1, 6, d != 0 ? str.tostring(math.round(rrVal, 2)) : "--", text_color=color.white)
    table.cell(setupT, 0, 7, "FVG",   text_color=color.white)
    table.cell(setupT, 1, 7, fvgStr,  text_color=fvgCol)

alertcondition(alertLong,  "EV OTE+FVG - Long",  "OTE + FVG Bullish confluence detected.")
alertcondition(alertShort, "EV OTE+FVG - Short", "OTE + FVG Bearish confluence detected.")
````
