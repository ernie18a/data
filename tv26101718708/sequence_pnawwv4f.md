# Sequence+

- url: https://www.tradingview.com/script/pnawWV4F-Sequence/
- type: indicator
- pine_id: PUB;b6dca402794a411d9d2021491e95a59e
- version: 6.0

## Description

A Classic-style market-timing / trend-exhaustion model.

Price flip -> Setup (1-9) -> Count phase (1-13) -> structural validation.
- Perfected arrow at the TRUE extreme bar (prints later if bar 8/9 has not yet exceeded bars 6-7).
- Deferred 13: the 2-bars-earlier rule and the bar-8 close rule must align on the same bar. Optional aggressive 8-vs-5 deferral.
- Optional structural-validation levels plus a post-13 risk line / 12-bar reversal window.
- Optional LOCATION confluence: recomputes prior-period D/W/M High/Low/EQ and HTF 2-bar-reversal levels in-script and flags a 9/13 printing AT a level with a diamond + alerts.

Gives timing, not signals - pair it with location and a confirmation price flip. Not financial advice.

## Source Code

````pine
//@version=6
indicator("Sequence+", overlay=true, max_lines_count=500, max_labels_count=500)

// =================================================================================
// Sequence+ — clean count engine (mirrors "Sequence (by Igor)")
//   Setup (1-9, strict TD, never pauses) + Countdown (1-13, can pause -> dot).
//   Both counts shown simultaneously, same signal side, offset apart.
//   Perfected arrows, deferred +/X, recycle R/S, structure & risk levels, 12-bar window.
//   No PP/HTF/VP confluence engine (removed). Pure close-vs-close[4]. Timing tool.
// =================================================================================

// ---------- General ----------
string i_txtSize  = input.string("Tiny", "Text size", options=["Tiny","Small","Normal","Large","Huge"], group="General")
float  i_offUnit  = input.float(0.25, "Offset step (ATR mult per unit)", minval=0.0, step=0.01, group="General")

// ---------- Counts ----------
bool  i_buySetup  = input.bool(true,  "Buy Setup",        group="Counts")
bool  i_sellSetup = input.bool(true,  "Sell Setup",       group="Counts")
bool  i_buyCd     = input.bool(true,  "Buy Countdown",    group="Counts")
bool  i_sellCd    = input.bool(true,  "Sell Countdown",   group="Counts")
bool  i_onlyComp  = input.bool(false, "Show Only Completions", group="Counts")
color i_buyCol    = input.color(#EF5350, "Buy color (down-move)",      group="Counts")
color i_sellCol   = input.color(#26A69A, "Sell color (up-move)",       group="Counts")
color i_buyCdCol  = input.color(#FF9800, "Buy Countdown color",        group="Counts")
color i_sellCdCol = input.color(#26A69A, "Sell Countdown color",       group="Counts")

// ---------- Setup behaviour ----------
bool  i_tieCont   = input.bool(false, "Continuous count — number every candle (off = strict TD flips)", group="Setup")
bool  i_sessReset = input.bool(false, "Reset count across session gaps (off = gap-agnostic TD)",        group="Setup")

// ---------- Perfected ----------
bool   i_showPerf = input.bool(true,  "Show Perfection Arrows", group="Perfected")
string i_perfSize = input.string("Tiny", "Arrow size", options=["Tiny","Small","Normal","Large","Huge"], group="Perfected")
int    i_perfWatch = input.int(20, "Perfected watch window (bars)", minval=1, maxval=100, group="Perfected")
int    i_offPerf  = input.int(6, "Perfected Arrows Offset", minval=0, group="Perfected")

// ---------- Countdown ----------
bool i_use8v5       = input.bool(true,  "Use Optional 8 vs 5 Countdown Deferral", group="Countdown")
bool i_showCd8      = input.bool(true,  "Show Countdown 8 Marker",  group="Countdown")
bool i_showDeferred = input.bool(true,  "Mark deferred bars (+)",   group="Countdown")
bool i_showPauseDot = input.bool(true,  "Mark paused countdown bars (dot)", group="Countdown")
int  i_offCd        = input.int(3, "Countdown digit offset",       minval=0, group="Countdown")
int  i_offCd8       = input.int(4, "Countdown 8 Marker Offset",    minval=0, group="Countdown")
int  i_offCd8X      = input.int(3, "Countdown 8 Reject X Offset",  minval=0, group="Countdown")
int  i_offDeferred  = input.int(3, "Deferred (+) Offset",          minval=0, group="Countdown")
int  i_offCd13      = input.int(3, "Countdown 13 Offset",          minval=0, group="Countdown")

// ---------- Recycling ----------
bool i_recycle = input.bool(true, "Enable Recycling (R/S)",              group="Recycling")
bool i_showR   = input.bool(true, "Show Recycle Marker (R) [22-rule]",   group="Recycling")
bool i_showS   = input.bool(true, "Show Recycle Marker (S) [size-rule]", group="Recycling")
int  i_offR    = input.int(6, "Recycle Marker R Offset", minval=0, group="Recycling")
int  i_offS    = input.int(6, "Recycle Marker S Offset", minval=0, group="Recycling")

// ---------- Structure ----------
bool  i_structSupport = input.bool(false, "Structure Support",    group="Structure")
bool  i_structResist  = input.bool(false, "Structure Resistance", group="Structure")
int   i_structWidth   = input.int(1, "Structure Line Width", minval=1, maxval=5, group="Structure")
int   i_maxStruct     = input.int(20, "Max structural lines",  minval=1, maxval=100, group="Structure")

// ---------- Risk ----------
bool  i_buyRisk      = input.bool(true,  "Buy Risk Level",  group="Risk")
bool  i_sellRisk     = input.bool(true,  "Sell Risk Level", group="Risk")
int   i_riskWidth    = input.int(1,  "Risk Level Line Width", minval=1, maxval=5, group="Risk")
int   i_riskMaxBars  = input.int(22, "Risk Level Max Bars",   minval=1, maxval=200, group="Risk")
color i_buyRiskCol   = input.color(#EF5350, "Buy risk color",  group="Risk")
color i_sellRiskCol  = input.color(#26A69A, "Sell risk color", group="Risk")
bool  i_show12Metric = input.bool(true,  "Show 12-Bar Metric",          group="Risk")
bool  i_show12Counter= input.bool(false, "Show 12-Bar Running Counter", group="Risk")
bool  i_expire13     = input.bool(false, "Expire 13 Signal After 12 Bars", group="Risk")
int   i_off12Metric  = input.int(2, "12-Bar Metric Label Offset", minval=0, group="Risk")
int   i_off12Counter = input.int(4, "12-Bar Counter Offset",      minval=0, group="Risk")

// ---------- Tuning (added last to keep input IDs stable) ----------
int   i_rCount       = input.int(18, "Recycle R: setup extends to N bars", minval=10, maxval=40, group="Recycling")
int   i_dotMinCd     = input.int(8,  "Pause dot: only from countdown bar N (higher = fewer dots)", minval=1, maxval=13, group="Countdown")
// Setup-row offset: keep STRICTLY BELOW the countdown offset (i_offCd) so the two rows
// share one ATR coordinate system and can never swap/overlap on zoom (was yloc.belowbar = fixed pixels).
int   i_offSetup     = input.int(1,  "Setup digit offset (keep < Countdown offset)", minval=0, group="General")
// Back-to-back setup recycle: after a printed 9, re-arm the setup at 1 so the primary
// count keeps printing 1..9 through an extended trend (mirrors Igor's last-leg behaviour).
// Countdown is left running untouched (see the doSeed guard in the 9-completion blocks).
bool  i_setupRecycle = input.bool(false, "Recycle setup after 9 (continuous primary count)", group="Setup")

// ---------- State ----------
var int   setupDir   = 0
var int   setupCount = 0          // raw count — may exceed 9 (for the R / 22 rule); only 1-9 print
var float curMinLow  = na
var float curMaxHigh = na
var int   setupStartTime = na
var float b6l = na, var float b7l = na, var float b8l = na, var float b9l = na
var float b6h = na, var float b7h = na, var float b8h = na, var float b9h = na

var bool  watchBuyPerf  = false
var bool  watchSellPerf = false
var float perfBuyTrig   = na
var float perfSellTrig  = na
var int   perfBuyBars   = 0
var int   perfSellBars  = 0

var int   cdDir   = 0
var int   cdCount = 0
var float cd5c    = na
var float cd8c    = na
var float cdMinLow  = na
var float cdMaxHigh = na
var float cdRiskBuy  = na          // DeMark risk level = true extreme -/+ that bar's true range
var float cdRiskSell = na
var float cdStruct  = na

var bool  armedBuy  = false
var bool  armedSell = false

var int   cdDoneDir = 0            // 12-bar window after a completed 13
var int   cdDoneBar = na

var array<label> allLabels  = array.new_label()
var array<line>  structLines = array.new_line()
var array<line>  riskLines   = array.new_line()

float atr14 = ta.atr(14)
float trueHi  = math.max(high, close[1])
float trueLo  = math.min(low,  close[1])
float trueRng = trueHi - trueLo

// ---------- Helpers ----------
f_txtSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.small

f_pushLabel(label lb) =>
    array.push(allLabels, lb)
    if array.size(allLabels) > 480
        label.delete(array.shift(allLabels))

f_off(int mult) =>
    mult * i_offUnit * atr14

// setup digit at a small ATR offset on the signal side (SAME coordinate system as countdown,
// just inner) so setup/countdown rows scale together and never swap or overlap on zoom.
f_setup(int n, bool isBuy) =>
    float y = isBuy ? low - f_off(i_offSetup) : high + f_off(i_offSetup)
    label lb = label.new(bar_index, y, str.tostring(n), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=(isBuy ? i_buyCol : i_sellCol), size=f_txtSize(i_txtSize))
    f_pushLabel(lb)

// countdown / marker text at an outward ATR offset on the signal side
f_offText(string txt, bool isBuy, int off, color col) =>
    float y = isBuy ? low - f_off(off) : high + f_off(off)
    label lb = label.new(bar_index, y, txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=col, size=f_txtSize(i_txtSize))
    f_pushLabel(lb)

// perfected arrow at a (possibly past) bar, offset beyond its extreme
f_perfArrow(int xidx, float px, bool isBuy) =>
    float y = isBuy ? px - f_off(i_offPerf) : px + f_off(i_offPerf)
    label lb = label.new(xidx, y, "", xloc=xloc.bar_index, yloc=yloc.price, style=(isBuy ? label.style_triangleup : label.style_triangledown), color=(isBuy ? i_buyCol : i_sellCol), size=f_txtSize(i_perfSize))
    f_pushLabel(lb)

f_structLine(int t, float px, bool isBuy) =>
    int  span = timeframe.in_seconds() * 1000 * 2
    line ln = line.new(t, px, t + span, px, xloc=xloc.bar_time, extend=extend.right, color=(isBuy ? i_buyCol : i_sellCol), width=i_structWidth, style=line.style_solid)
    array.push(structLines, ln)
    if array.size(structLines) > i_maxStruct
        line.delete(array.shift(structLines))

f_riskLine(float px, bool isBuy) =>
    line ln = line.new(bar_index, px, bar_index + i_riskMaxBars, px, xloc=xloc.bar_index, extend=extend.none, color=(isBuy ? i_buyRiskCol : i_sellRiskCol), width=i_riskWidth, style=line.style_solid)
    array.push(riskLines, ln)
    if array.size(riskLines) > 50
        line.delete(array.shift(riskLines))

// ---------- Per-bar evaluation ----------
bool dn = close < close[4]
bool up = close > close[4]
bool bearFlip = up[1] and dn
bool bullFlip = dn[1] and up

bool buyDone  = false
bool sellDone = false
bool sigPerf9  = false
bool sigPerf13 = false
bool sigConfirm = false

// pause-dot positions (rendered via plotchar = unlimited history, zero label budget)
float buyDotY  = na
float sellDotY = na

// Session-gap guard (default off — classic TD is gap-agnostic)
if i_sessReset
    bool gapBar = na(time[1]) or (time - time[1]) > timeframe.in_seconds() * 1000 * 3 / 2
    if gapBar
        setupDir := 0
        setupCount := 0
        cdDir := 0
        cdCount := 0
        watchBuyPerf := false
        watchSellPerf := false
        armedBuy := false
        armedSell := false

// ----- Setup advance -----
if setupDir == 1
    if (i_tieCont ? not up : dn)
        setupCount += 1
        if setupCount == 6
            b6l := low
        if setupCount == 7
            b7l := low
        if setupCount == 8
            b8l := low
        if setupCount == 9
            b9l := low
            buyDone := true
        curMinLow := na(curMinLow) ? low : math.min(curMinLow, low)
        curMaxHigh := na(curMaxHigh) ? high : math.max(curMaxHigh, high)
        if i_buySetup and setupCount <= 9 and (not i_onlyComp or setupCount == 9)
            f_setup(setupCount, true)
        if setupCount == i_rCount and i_recycle and i_showR
            f_offText("R", true, i_offR, i_buyCol)
    else
        setupDir := 0
        setupCount := 0
else if setupDir == -1
    if (i_tieCont ? not dn : up)
        setupCount += 1
        if setupCount == 6
            b6h := high
        if setupCount == 7
            b7h := high
        if setupCount == 8
            b8h := high
        if setupCount == 9
            b9h := high
            sellDone := true
        curMaxHigh := na(curMaxHigh) ? high : math.max(curMaxHigh, high)
        curMinLow := na(curMinLow) ? low : math.min(curMinLow, low)
        if i_sellSetup and setupCount <= 9 and (not i_onlyComp or setupCount == 9)
            f_setup(setupCount, false)
        if setupCount == i_rCount and i_recycle and i_showR
            f_offText("R", false, i_offR, i_sellCol)
    else
        setupDir := 0
        setupCount := 0

// ----- Buy setup completed (9) -----
if buyDone
    perfBuyTrig := math.min(b6l, b7l)
    bool perfNow = (b8l <= perfBuyTrig) or (b9l <= perfBuyTrig)
    if perfNow
        if i_showPerf
            int back = b8l <= b9l ? 1 : 0
            f_perfArrow(bar_index - back, back == 0 ? low : low[1], true)
        watchBuyPerf := false
        sigPerf9 := true
        armedBuy := true
    else
        watchBuyPerf := true
        perfBuyBars := 0
    watchSellPerf := false
    armedSell := false
    if i_structResist
        f_structLine(setupStartTime, curMaxHigh, true)
    if cdDir == -1
        cdDir := 0
        cdCount := 0
    bool doSeed = true
    if cdDir == 1
        if i_setupRecycle
            doSeed := false                     // recycled setup-9: leave the running countdown alone
        else if i_recycle
            if i_showS
                f_offText("S", true, i_offS, i_buyCdCol)
        else
            doSeed := false
    if doSeed
        cdDir := 1
        cdCount := 0
        cd5c := na
        cd8c := na
        cdMinLow := na
        cdRiskBuy := na
        cdStruct := curMaxHigh

// ----- Sell setup completed (9) -----
if sellDone
    perfSellTrig := math.max(b6h, b7h)
    bool perfNowS = (b8h >= perfSellTrig) or (b9h >= perfSellTrig)
    if perfNowS
        if i_showPerf
            int backs = b8h >= b9h ? 1 : 0
            f_perfArrow(bar_index - backs, backs == 0 ? high : high[1], false)
        watchSellPerf := false
        sigPerf9 := true
        armedSell := true
    else
        watchSellPerf := true
        perfSellBars := 0
    watchBuyPerf := false
    armedBuy := false
    if i_structSupport
        f_structLine(setupStartTime, curMinLow, false)
    if cdDir == 1
        cdDir := 0
        cdCount := 0
    bool doSeedS = true
    if cdDir == -1
        if i_setupRecycle
            doSeedS := false                    // recycled setup-9: leave the running countdown alone
        else if i_recycle
            if i_showS
                f_offText("S", false, i_offS, i_sellCdCol)
        else
            doSeedS := false
    if doSeedS
        cdDir := -1
        cdCount := 0
        cd5c := na
        cd8c := na
        cdMaxHigh := na
        cdRiskSell := na
        cdStruct := curMinLow

// ----- Back-to-back setup recycle (optional) -----
// After a printed 9, re-arm the count (keep direction) so the next trend bar prints a fresh 1.
// Countdown keeps running (guarded above); an opposite price-move still ends the run normally.
if i_setupRecycle and setupDir != 0 and setupCount == 9
    setupCount := 0

// ----- Setup start (idle) -----
if setupDir == 0
    if (i_tieCont ? dn : bearFlip)
        setupDir := 1
        setupCount := 1
        curMinLow := low
        curMaxHigh := high
        setupStartTime := time
        b6l := na
        b7l := na
        b8l := na
        b9l := na
        if i_buySetup and not i_onlyComp
            f_setup(1, true)
    else if (i_tieCont ? up : bullFlip)
        setupDir := -1
        setupCount := 1
        curMaxHigh := high
        curMinLow := low
        setupStartTime := time
        b6h := na
        b7h := na
        b8h := na
        b9h := na
        if i_sellSetup and not i_onlyComp
            f_setup(1, false)

// ----- Buy countdown -----
if cdDir == 1
    bool qual = close <= low[2]
    if cdCount < 13 and qual
        int nextC = cdCount + 1
        bool defer8  = (nextC == 8)  and i_use8v5 and not (low <= cd5c)
        bool defer13 = (nextC == 13) and not (low <= cd8c)
        if defer8
            if i_buyCd and not i_onlyComp
                f_offText("X", true, i_offCd8X, i_buyCdCol)
        else if defer13
            if i_buyCd and i_showDeferred and not i_onlyComp
                f_offText("+", true, i_offDeferred, i_buyCdCol)
        else
            cdCount := nextC
            if na(cdMinLow) or trueLo < cdMinLow
                cdMinLow := trueLo
                cdRiskBuy := trueLo - trueRng
            if cdCount == 5
                cd5c := close
            if cdCount == 8
                cd8c := close
            if cdCount == 13
                if i_buyCd
                    f_offText("13", true, i_offCd13, i_buyCdCol)
                if i_buyRisk
                    f_riskLine(cdRiskBuy, true)
                sigPerf13 := true
                armedBuy := true
                cdDoneDir := 1
                cdDoneBar := bar_index
                cdDir := 0
            else
                if i_buyCd and not i_onlyComp
                    int off = (cdCount == 8 and i_showCd8) ? i_offCd8 : i_offCd
                    f_offText(str.tostring(cdCount), true, off, i_buyCdCol)
    else if cdCount >= i_dotMinCd and cdCount < 13 and not qual
        if i_buyCd and i_showPauseDot and not i_onlyComp
            buyDotY := low - f_off(i_offCd)
    if cdDir == 1 and not na(cdStruct) and close > cdStruct
        cdDir := 0
        cdCount := 0
// ----- Sell countdown -----
else if cdDir == -1
    bool qualS = close >= high[2]
    if cdCount < 13 and qualS
        int nextCs = cdCount + 1
        bool defer8s  = (nextCs == 8)  and i_use8v5 and not (high >= cd5c)
        bool defer13s = (nextCs == 13) and not (high >= cd8c)
        if defer8s
            if i_sellCd and not i_onlyComp
                f_offText("X", false, i_offCd8X, i_sellCdCol)
        else if defer13s
            if i_sellCd and i_showDeferred and not i_onlyComp
                f_offText("+", false, i_offDeferred, i_sellCdCol)
        else
            cdCount := nextCs
            if na(cdMaxHigh) or trueHi > cdMaxHigh
                cdMaxHigh := trueHi
                cdRiskSell := trueHi + trueRng
            if cdCount == 5
                cd5c := close
            if cdCount == 8
                cd8c := close
            if cdCount == 13
                if i_sellCd
                    f_offText("13", false, i_offCd13, i_sellCdCol)
                if i_sellRisk
                    f_riskLine(cdRiskSell, false)
                sigPerf13 := true
                armedSell := true
                cdDoneDir := -1
                cdDoneBar := bar_index
                cdDir := 0
            else
                if i_sellCd and not i_onlyComp
                    int offs = (cdCount == 8 and i_showCd8) ? i_offCd8 : i_offCd
                    f_offText(str.tostring(cdCount), false, offs, i_sellCdCol)
    else if cdCount >= i_dotMinCd and cdCount < 13 and not qualS
        if i_sellCd and i_showPauseDot and not i_onlyComp
            sellDotY := high + f_off(i_offCd)
    if cdDir == -1 and not na(cdStruct) and close < cdStruct
        cdDir := 0
        cdCount := 0

// ----- Perfection watch (arrow may print bars after the 9) -----
if watchBuyPerf
    perfBuyBars += 1
    if low <= perfBuyTrig
        if i_showPerf
            f_perfArrow(bar_index, low, true)
        watchBuyPerf := false
        sigPerf9 := true
        armedBuy := true
    else if perfBuyBars >= i_perfWatch
        watchBuyPerf := false
if watchSellPerf
    perfSellBars += 1
    if high >= perfSellTrig
        if i_showPerf
            f_perfArrow(bar_index, high, false)
        watchSellPerf := false
        sigPerf9 := true
        armedSell := true
    else if perfSellBars >= i_perfWatch
        watchSellPerf := false

// ----- 12-bar window after a completed 13 -----
if not na(cdDoneBar) and i_show12Counter and bar_index > cdDoneBar and bar_index <= cdDoneBar + 12
    int k = bar_index - cdDoneBar
    f_offText(str.tostring(k), cdDoneDir == 1, i_off12Counter, color.new(color.gray, 0))
if not na(cdDoneBar) and i_show12Metric and bar_index == cdDoneBar + 12
    f_offText("12", cdDoneDir == 1, i_off12Metric, color.new(color.gray, 0))

// ----- Opposing-flip confirmation -----
if armedBuy and bullFlip
    sigConfirm := true
    armedBuy := false
if armedSell and bearFlip
    sigConfirm := true
    armedSell := false

// ---------- Pause dots (plotchar = minute, unlimited history, zero label budget) ----------
plotchar(buyDotY,  title="Buy pause dot",  char="•", location=location.absolute, color=i_buyCdCol,  size=size.tiny)
plotchar(sellDotY, title="Sell pause dot", char="•", location=location.absolute, color=i_sellCdCol, size=size.tiny)

// ---------- Alerts ----------
alertcondition(sigPerf9,   title="Perfected 9",           message="Sequence+: perfected 9 printed")
alertcondition(sigPerf13,  title="Countdown 13",          message="Sequence+: countdown 13 completed")
alertcondition(sigConfirm, title="Opposing flip confirm", message="Sequence+: opposing price-flip confirmation")
````
