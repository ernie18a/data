# Liquidity Sweep Signals

- url: https://www.tradingview.com/script/loNFaWST-Liquidity-Sweep-Signals/
- type: indicator
- pine_id: PUB;79e953a2ef0e488d9baa809614615eb5
- version: 2.0

## Description

Detects liquidity sweeps and waits for a post-sweep Fair Value Gap retrace before marking an entry. No same-bar entries — the setup requires at least 2-3 candles to develop.

How it works — 3 steps:

Sweep — price wicks through a swing high (BSL) or swing low (SSL) and closes back inside. Liquidity taken.
Post-sweep FVG — waits for a Fair Value Gap to form in the impulse move that follows the sweep. Only FVGs created after the sweep bar are considered.
Retrace entry — when price pulls back into that FVG zone, the entry triggers at the midpoint. SL is placed below/above the sweep extreme. TP at 2:1 R:R.
What gets drawn:

Green box — TP zone (entry → target)
Red box — SL zone (entry → stop)
White dashed line — exact entry level
Boxes close automatically when TP, SL, or expiry is hit — no visual clutter
Setup markers (optional):

SSL▲ — bullish setup armed after sell-side sweep
BSL▼ — bearish setup armed after buy-side sweep
Inputs:

Swing Length — pivot detection sensitivity
SL ATR Buffer — extra room beyond the sweep extreme
R:R Ratio — default 2.0
Expire setup after N bars — cancels setup if no FVG retrace found in time
London / NY session filters
Stats table (top-right): live win rate, wins, losses, expired setups, open signals.

3 alerts included: Long, Short, Any signal.

Works on all FX pairs and timeframes. Designed for London and NY sessions.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © EVLabs
//@version=6
indicator("Liquidity Sweep Signals", shorttitle="LSS", overlay=true,
         max_labels_count=300, max_lines_count=300, max_boxes_count=300)

// ─── Inputs ───────────────────────────────────────────────────────────────────
swingLen   = input.int(10,    "Swing Length",              minval=3,  maxval=50,  group="Detection")
maxLevels  = input.int(5,     "Max Liq Levels",            minval=1,  maxval=10,  group="Detection")
atrMult    = input.float(0.5, "SL ATR Buffer",             minval=0.1, step=0.1,  group="Risk")
rrRatio    = input.float(2.0, "R:R Ratio",                 minval=0.5, step=0.1,  group="Risk")
expireBars = input.int(30,    "Expire setup after N bars", minval=3,  maxval=200, group="Risk")
statsLen   = input.int(20,    "Stats: Last N Signals",     minval=5,  maxval=100, group="Stats")
showDebug  = input.bool(true, "Show setup markers",        group="Stats")
sessionLon = input.session("0700-1200", "London Session",  group="Sessions")
sessionNY  = input.session("1330-2000", "NY Session",      group="Sessions")
longCol    = input.color(color.new(#26a69a, 0), "Long Color",  group="Visuals")
shortCol   = input.color(color.new(#ef5350, 0), "Short Color", group="Visuals")
boxWidth   = input.int(30, "Box Width after entry (bars)", minval=5, maxval=100, group="Visuals")

// ─── Session ──────────────────────────────────────────────────────────────────
inLondon  = not na(time(timeframe.period, sessionLon, "Europe/Berlin"))
inNY      = not na(time(timeframe.period, sessionNY,  "America/New_York"))
inSession = inLondon or inNY

atr = ta.atr(14)

// ─── Pivots → Liquidity ───────────────────────────────────────────────────────
swingH = ta.pivothigh(high, swingLen, swingLen)
swingL = ta.pivotlow(low,  swingLen, swingLen)

var float[] bslLvls  = array.new_float()
var bool[]  bslSwept = array.new_bool()
var float[] sslLvls  = array.new_float()
var bool[]  sslSwept = array.new_bool()

f_trimLiq(float[] lvls, bool[] sw, int maxN) =>
    while array.size(lvls) > maxN
        array.shift(lvls)
        array.shift(sw)

if not na(swingH)
    array.push(bslLvls, swingH)
    array.push(bslSwept, false)
    f_trimLiq(bslLvls, bslSwept, maxLevels)

if not na(swingL)
    array.push(sslLvls, swingL)
    array.push(sslSwept, false)
    f_trimLiq(sslLvls, sslSwept, maxLevels)

// ─── FVG ──────────────────────────────────────────────────────────────────────
bullFVG = low > high[2]
bearFVG = high < low[2]

var float[] bFvgTop = array.new_float()
var float[] bFvgBot = array.new_float()
var int[]   bFvgBar = array.new_int()
var float[] sFvgTop = array.new_float()
var float[] sFvgBot = array.new_float()
var int[]   sFvgBar = array.new_int()

if bullFVG
    array.push(bFvgTop, low)
    array.push(bFvgBot, high[2])
    array.push(bFvgBar, bar_index)
if bearFVG
    array.push(sFvgTop, low[2])
    array.push(sFvgBot, high)
    array.push(sFvgBar, bar_index)

maxFvg = 20
while array.size(bFvgTop) > maxFvg
    array.shift(bFvgTop)
    array.shift(bFvgBot)
    array.shift(bFvgBar)
while array.size(sFvgTop) > maxFvg
    array.shift(sFvgTop)
    array.shift(sFvgBot)
    array.shift(sFvgBar)

// ─── Sweeps ───────────────────────────────────────────────────────────────────
sslSweep  = false
bslSweep  = false
sweepLow  = 0.0
sweepHigh = 0.0

nb = array.size(sslLvls)
if nb > 0
    for i = 0 to nb - 1
        if not array.get(sslSwept, i)
            lvl = array.get(sslLvls, i)
            if low < lvl and close > lvl
                array.set(sslSwept, i, true)
                sslSweep := true
                sweepLow := low

nc = array.size(bslLvls)
if nc > 0
    for i = 0 to nc - 1
        if not array.get(bslSwept, i)
            lvl = array.get(bslLvls, i)
            if high > lvl and close < lvl
                array.set(bslSwept, i, true)
                bslSweep := true
                sweepHigh := high

// ─── Signal tracking ──────────────────────────────────────────────────────────
var int[]   sigDir    = array.new_int()
var float[] sigEntry  = array.new_float()
var float[] sigSL     = array.new_float()
var float[] sigTP     = array.new_float()
var int[]   sigResult = array.new_int()
var int[]   sigBar    = array.new_int()
var box[]   sigTpBox  = array.new_box()
var box[]   sigSlBox  = array.new_box()
var line[]  sigEntryL = array.new_line()

nSig = array.size(sigDir)
if nSig > 0
    for i = 0 to nSig - 1
        if array.get(sigResult, i) == 0
            d        = array.get(sigDir, i)
            tp       = array.get(sigTP,  i)
            sl       = array.get(sigSL,  i)
            age      = bar_index - array.get(sigBar, i)
            resolved = false
            if age >= expireBars * 3
                array.set(sigResult, i, 2)
                resolved := true
            else if d == 1
                if high >= tp
                    array.set(sigResult, i, 1)
                    resolved := true
                else if low <= sl
                    array.set(sigResult, i, -1)
                    resolved := true
            else
                if low <= tp
                    array.set(sigResult, i, 1)
                    resolved := true
                else if high >= sl
                    array.set(sigResult, i, -1)
                    resolved := true
            if resolved
                box.set_right(array.get(sigTpBox,  i), bar_index)
                box.set_right(array.get(sigSlBox,  i), bar_index)
                line.set_x2(array.get(sigEntryL,   i), bar_index)

hasOpen = false
nSig2 = array.size(sigResult)
if nSig2 > 0
    for i = 0 to nSig2 - 1
        if array.get(sigResult, i) == 0
            hasOpen := true

while array.size(sigDir) > statsLen
    array.shift(sigDir)
    array.shift(sigEntry)
    array.shift(sigSL)
    array.shift(sigTP)
    array.shift(sigResult)
    array.shift(sigBar)
    array.shift(sigTpBox)
    array.shift(sigSlBox)
    array.shift(sigEntryL)

// ─── Setup state ─────────────────────────────────────────────────────────────
var bool  lookLong  = false
var bool  lookShort = false
var int   setupBarL = 0
var int   setupBarS = 0
var float setupSLL  = 0.0
var float setupSLS  = 0.0
var int   lastBias  = 0

if sslSweep and inSession and not hasOpen
    lookLong  := true
    lookShort := false
    setupBarL := bar_index
    setupSLL  := sweepLow - atr * atrMult
    lastBias  := 1
    if showDebug
        label.new(bar_index, low, "SSL▲", style=label.style_label_up,
                  color=color.new(longCol, 50), textcolor=color.white, size=size.tiny)

if bslSweep and inSession and not hasOpen
    lookShort := true
    lookLong  := false
    setupBarS := bar_index
    setupSLS  := sweepHigh + atr * atrMult
    lastBias  := -1
    if showDebug
        label.new(bar_index, high, "BSL▼", style=label.style_label_down,
                  color=color.new(shortCol, 50), textcolor=color.white, size=size.tiny)

if not inSession
    lookLong  := false
    lookShort := false

if lookLong  and (bar_index - setupBarL) > expireBars
    lookLong  := false
if lookShort and (bar_index - setupBarS) > expireBars
    lookShort := false

// ─── Entry ────────────────────────────────────────────────────────────────────
newLong  = false
newShort = false

if lookLong and not hasOpen
    nf = array.size(bFvgBar)
    if nf > 0
        for i = nf - 1 to 0
            if array.get(bFvgBar, i) > setupBarL
                fTop = array.get(bFvgTop, i)
                fBot = array.get(bFvgBot, i)
                mid  = (fTop + fBot) / 2
                if low <= fTop and close > fBot
                    entryP = mid
                    slP    = setupSLL
                    slDist = entryP - slP
                    if slDist > 0
                        tpP = entryP + slDist * rrRatio
                        x1  = bar_index
                        x2  = bar_index + boxWidth
                        bTP = box.new(x1, tpP, x2, entryP,
                                      border_color=color.new(#26a69a, 30), bgcolor=color.new(#26a69a, 75),
                                      text="TP " + str.tostring(tpP, "#.#####"),
                                      text_color=color.new(color.white, 20),
                                      text_size=size.small, text_halign=text.align_right, text_valign=text.align_top)
                        bSL = box.new(x1, entryP, x2, slP,
                                      border_color=color.new(#ef5350, 30), bgcolor=color.new(#ef5350, 75),
                                      text="SL " + str.tostring(slP, "#.#####"),
                                      text_color=color.new(color.white, 20),
                                      text_size=size.small, text_halign=text.align_right, text_valign=text.align_bottom)
                        ln = line.new(x1, entryP, x2, entryP, color=color.white, width=2, style=line.style_dashed)
                        label.new(x1, entryP, "▶ LONG  " + str.tostring(entryP, "#.#####"),
                                  style=label.style_label_right, color=color.white, textcolor=color.black, size=size.small)
                        array.push(sigDir, 1)
                        array.push(sigEntry, entryP)
                        array.push(sigSL, slP)
                        array.push(sigTP, tpP)
                        array.push(sigResult, 0)
                        array.push(sigBar, bar_index)
                        array.push(sigTpBox, bTP)
                        array.push(sigSlBox, bSL)
                        array.push(sigEntryL, ln)
                        lookLong := false
                        newLong  := true
                        break

if lookShort and not hasOpen
    nf = array.size(sFvgBar)
    if nf > 0
        for i = nf - 1 to 0
            if array.get(sFvgBar, i) > setupBarS
                fTop = array.get(sFvgTop, i)
                fBot = array.get(sFvgBot, i)
                mid  = (fTop + fBot) / 2
                if high >= fBot and close < fTop
                    entryP = mid
                    slP    = setupSLS
                    slDist = slP - entryP
                    if slDist > 0
                        tpP = entryP - slDist * rrRatio
                        x1  = bar_index
                        x2  = bar_index + boxWidth
                        bTP = box.new(x1, entryP, x2, tpP,
                                      border_color=color.new(#26a69a, 30), bgcolor=color.new(#26a69a, 75),
                                      text="TP " + str.tostring(tpP, "#.#####"),
                                      text_color=color.new(color.white, 20),
                                      text_size=size.small, text_halign=text.align_right, text_valign=text.align_bottom)
                        bSL = box.new(x1, slP, x2, entryP,
                                      border_color=color.new(#ef5350, 30), bgcolor=color.new(#ef5350, 75),
                                      text="SL " + str.tostring(slP, "#.#####"),
                                      text_color=color.new(color.white, 20),
                                      text_size=size.small, text_halign=text.align_right, text_valign=text.align_bottom)
                        ln = line.new(x1, entryP, x2, entryP, color=color.white, width=2, style=line.style_dashed)
                        label.new(x1, entryP, "▶ SHORT  " + str.tostring(entryP, "#.#####"),
                                  style=label.style_label_right, color=color.white, textcolor=color.black, size=size.small)
                        array.push(sigDir, -1)
                        array.push(sigEntry, entryP)
                        array.push(sigSL, slP)
                        array.push(sigTP, tpP)
                        array.push(sigResult, 0)
                        array.push(sigBar, bar_index)
                        array.push(sigTpBox, bTP)
                        array.push(sigSlBox, bSL)
                        array.push(sigEntryL, ln)
                        lookShort := false
                        newShort  := true
                        break

// ─── Stats table ─────────────────────────────────────────────────────────────
var table tbl = table.new(position.top_right, 2, 8,
                           bgcolor=color.new(color.black, 75), border_width=1,
                           border_color=color.new(color.gray, 60))

if barstate.islast
    wins   = 0
    losses = 0
    openS  = 0
    exp    = 0
    n = array.size(sigResult)
    if n > 0
        for i = 0 to n - 1
            r = array.get(sigResult, i)
            if r == 1
                wins += 1
            else if r == -1
                losses += 1
            else if r == 2
                exp += 1
            else
                openS += 1
    total = wins + losses
    wr    = total > 0 ? wins / total * 100 : 0.0
    wrCol = wr >= 50 ? color.new(#26a69a, 0) : color.new(#ef5350, 0)

    biasStr = lastBias == 1 ? "Bullish ▲" : lastBias == -1 ? "Bearish ▼" : "–"
    biasCol = lastBias == 1 ? color.new(#26a69a, 0) : lastBias == -1 ? color.new(#ef5350, 0) : color.new(color.gray, 0)

    table.cell(tbl, 0, 0, "EV LSS",   text_color=color.gray, text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(tbl, 1, 0, "Signals",  text_color=color.gray, text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(tbl, 0, 1, "Bias",     text_color=color.gray, text_size=size.small)
    table.cell(tbl, 1, 1, biasStr,    text_color=biasCol,    text_size=size.normal)
    table.cell(tbl, 0, 2, "Win Rate", text_color=color.gray, text_size=size.small)
    table.cell(tbl, 1, 2, str.tostring(wr, "#.0") + "%", text_color=wrCol, text_size=size.normal)
    table.cell(tbl, 0, 3, "Wins",     text_color=color.gray, text_size=size.small)
    table.cell(tbl, 1, 3, str.tostring(wins),   text_color=color.new(#26a69a, 0), text_size=size.small)
    table.cell(tbl, 0, 4, "Losses",   text_color=color.gray, text_size=size.small)
    table.cell(tbl, 1, 4, str.tostring(losses), text_color=color.new(#ef5350, 0), text_size=size.small)
    table.cell(tbl, 0, 5, "Expired",  text_color=color.gray, text_size=size.small)
    table.cell(tbl, 1, 5, str.tostring(exp),    text_color=color.gray,            text_size=size.small)
    table.cell(tbl, 0, 6, "Open",     text_color=color.gray, text_size=size.small)
    table.cell(tbl, 1, 6, str.tostring(openS),  text_color=color.white,           text_size=size.small)
    table.cell(tbl, 0, 7, "Sample",   text_color=color.gray, text_size=size.small)
    table.cell(tbl, 1, 7, str.tostring(total) + "/" + str.tostring(statsLen), text_color=color.gray, text_size=size.small)

// ─── Alerts ───────────────────────────────────────────────────────────────────
alertcondition(newLong,             "LSS Long",  "EV LSS — LONG {{ticker}} {{interval}}")
alertcondition(newShort,            "LSS Short", "EV LSS — SHORT {{ticker}} {{interval}}")
alertcondition(newLong or newShort, "LSS Any",   "EV LSS — Signal {{ticker}} {{interval}}")
````
