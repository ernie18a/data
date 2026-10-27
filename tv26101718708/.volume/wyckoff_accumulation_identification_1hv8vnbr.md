# Wyckoff Accumulation Identification

- url: https://www.tradingview.com/script/1hV8VNBr-Wyckoff-Accumulation-Identification/
- type: indicator
- pine_id: PUB;009d844dcb80487a872d3d2a5bdc77b5
- version: 1.0

## Description

Wyckoff Accumulation Identification
- 1. wyckoffdistribution1.png` — Distribution Schematic #1 (with UTAD)
- 2. wyckoffdistribution2.png` — Distribution Schematic #2 (without UTAD)
- 3. wyckoffaccumulation1.png` — Accumulation Schematic #1 (with Spring)
- 4. wyckoffaccumulation2.png` — Accumulation Schematic #2 (without Spring)
### Event Mapping — Accumulation
| Event | Chart Signal | Volume |
|---|---|---|
| PS (Preliminary Support) | First volume spike in downtrend, price pauses temporarily | Spike |
| SC (Selling Climax) | Large red candle + long lower wick, lowest low | Extremely high |
| AR (Automatic Rally) | Sharp bounce from SC, defines top of TR | Moderate |
| ST (Secondary Test) | Retest SC zone, higher low than SC | Lower than SC |
| Spring | False break below SC then closes back inside TR | Low or high |
| Test of Spring | Retest Spring low, fails to break it | Very low |
| SOS (Sign of Strength) | Strong rally through top of TR | Surge |
| LPS (Last Point of Support) | Pullback to former TR top (now support) | Low |

### Event Mapping — Distribution
| Event | Chart Signal | Volume |
|---|---|---|
| PSY (Preliminary Supply) | Price slows, volume spike in uptrend | Spike |
| BC (Buying Climax) | Large green candle + long upper wick, highest high | Extremely high |
| AR (Automatic Reaction) | Sharp drop from BC, defines bottom of TR | Moderate |
| ST (Secondary Test) | Retest BC zone, lower high than BC | Lower than BC |
| UTAD (Upthrust After Distribution) | False break above BC then closes back inside TR | Low or high |
| LPSY (Last Point of Supply) | Weak rally fails to reach top of TR | Low |
| SOW (Sign of Weakness) | Break below bottom of TR, volume surges | Surge |

## Source Code

````pine
// @version=6
indicator("Wyckoff Accumulation Identification", overlay=true,
          max_labels_count=50, max_boxes_count=10, max_lines_count=10)

// Allow dynamic indexing up to 500 bars back
max_bars_back(high,   500)
max_bars_back(low,    500)
max_bars_back(close,  500)
max_bars_back(volume, 500)

// ═══════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════
i_lookback   = input.int(200,   "Lookback Window (bars)",   minval=50,  maxval=500,  group="Detection")
i_volLen     = input.int(20,    "Volume MA Length",          minval=5,   maxval=50,   group="Detection")
i_volMult    = input.float(1.5, "Volume Spike x MA",        minval=1.0, maxval=5.0,  step=0.1, group="Detection")
i_priorDTPct = input.float(10.0,"Prior Downtrend Min %",    minval=3.0, maxval=50.0, step=1.0, group="Detection")
i_phaseERst  = input.float(30.0,"Phase E Reset Drawdown %", minval=10.0, maxval=60.0, step=5.0, group="Detection")
i_arMinPct   = input.float(4.0, "AR Min Bounce % from SC",  minval=1.0, maxval=20.0, step=0.5, group="Detection")
i_stZonePct  = input.float(3.0, "ST Zone % above SC Low",   minval=0.5, maxval=10.0, step=0.5, group="Detection")

i_showTR     = input.bool(true, "Show TR Box",       group="Display")
i_showLines  = input.bool(true, "Show SC/AR Lines",  group="Display")
i_showLabels = input.bool(true, "Show Event Labels", group="Display")
i_showTable  = input.bool(true, "Show Info Table",   group="Display")

// ═══════════════════════════════════════════════
// CORE INDICATORS
// ═══════════════════════════════════════════════
volMA        = ta.sma(volume, i_volLen)
max_bars_back(volMA, 500)
atr14        = ta.atr(14)
lowestInLB   = ta.lowest(low, i_lookback)   // extracted to top-level (Pine v6 scope rule)

// ═══════════════════════════════════════════════
// STATE MACHINE VARIABLES
// ═══════════════════════════════════════════════
var int   state      = 0  // 0=scan SC | 1=scan AR | 2=TR | 3=Phase C | 4=Phase D | 5=D+ | 6=E

var int   scIdx      = na
var float scLow      = na
var float scVol      = na

var int   psIdx      = na
var float psLow      = na

var int   arIdx      = na
var float arHigh     = na
var int   arCandIdx  = na
var float arCandHigh = na

var int   stIdx      = na
var float stLow      = na
var float stVol      = na

var int   sprIdx     = na
var float sprLow     = na

var int   sosIdx     = na
var float sosHigh    = na

var int   lpsIdx     = na
var float lpsLow     = na

var int   hlCount    = 0
var float lastTRLow  = na

var bool  needReset  = false
var float phaseEPeak = na

// ═══════════════════════════════════════════════
// STATE MACHINE
// ═══════════════════════════════════════════════
if barstate.isconfirmed
    if state == 0
        isNewLow  = low <= lowestInLB[1]
        volSpike  = volume >= volMA * i_volMult
        priorBars = math.min(bar_index, 30)
        hasDT     = priorBars >= 5 and close[priorBars] >= low * (1.0 + i_priorDTPct / 100.0)

        if isNewLow and volSpike and hasDT
            bestVol = 0.0
            scanTo  = math.min(50, bar_index - 1)
            for i = 5 to scanTo
                if low[i] > low * 1.005 and volume[i] > bestVol
                    bestVol := volume[i]
                    psIdx   := bar_index - i
                    psLow   := low[i]
            scIdx := bar_index
            scLow := low
            scVol := volume
            state := 1

    else if state == 1
        barsAfterSC = bar_index - scIdx

        if low < scLow * 0.995 and volume >= volMA * i_volMult * 0.75
            scIdx      := bar_index
            scLow      := low
            scVol      := volume
            arCandIdx  := na
            arCandHigh := na

        else if barsAfterSC >= 2
            if na(arCandHigh) or high > arCandHigh
                arCandHigh := high
                arCandIdx  := bar_index

            if not na(arCandHigh)
                bouncePct  = (arCandHigh - scLow) / scLow * 100.0
                retracePct = (arCandHigh - close)  / arCandHigh * 100.0
                if bouncePct >= i_arMinPct and retracePct >= 1.5 and barsAfterSC >= 5
                    arIdx  := arCandIdx
                    arHigh := arCandHigh
                    state  := 2

        if barsAfterSC > 60
            needReset := true

    else if state == 2
        barsInTR = bar_index - scIdx

        if barsInTR > i_lookback
            needReset := true
        else
            if low > scLow * 1.005 and low < arHigh * 0.995
                if na(lastTRLow)
                    lastTRLow := low
                else if low > lastTRLow * 1.005
                    hlCount   += 1
                    lastTRLow := low
                else if low < lastTRLow * 0.995
                    lastTRLow := low

            inSTZone   = low <= scLow * (1.0 + i_stZonePct / 100.0) and low > scLow * 0.98
            stVolOK    = volume < scVol * 0.75
            closeOK    = close >= scLow * 0.995
            stGap      = na(stIdx) or (bar_index - stIdx) >= 5

            if inSTZone and stVolOK and closeOK and stGap
                stIdx := bar_index
                stLow := low
                stVol := volume

            springCond = low < scLow and close >= scLow * 0.997 and close <= arHigh * 1.01 and (close - low) / math.max(high - low, 0.0001) > 0.45
            sosCond2   = close > arHigh and volume > volMA * i_volMult * 0.85 and close > open

            if springCond
                sprIdx := bar_index
                sprLow := low
                state  := 3
            else if sosCond2
                sosIdx  := bar_index
                sosHigh := high
                state   := 4
            else if close < scLow * 0.94
                needReset := true

    else if state == 3
        if (bar_index - scIdx) > i_lookback
            needReset := true
        else if close > arHigh and volume > volMA * i_volMult * 0.85 and close > open
            sosIdx  := bar_index
            sosHigh := high
            state   := 4

    else if state == 4
        barsAfterSOS = bar_index - sosIdx

        if barsAfterSOS >= 2 and not na(arHigh)
            nearAR  = low <= arHigh * 1.02 and low >= arHigh * 0.95
            lowVol  = volume < volMA
            aboveSC = low > scLow
            bullBar = close >= open
            if nearAR and lowVol and aboveSC and bullBar
                lpsIdx := bar_index
                lpsLow := low
                state  := 5

        if close > arHigh * 1.12
            state := 6

    else if state == 5
        if close > arHigh * 1.12
            state := 6

    else if state == 6
        if na(phaseEPeak) or high > phaseEPeak
            phaseEPeak := high
        if not na(phaseEPeak) and close < phaseEPeak * (1.0 - i_phaseERst / 100.0)
            needReset := true

// ═══════════════════════════════════════════════
// APPLY DEFERRED RESET
// ═══════════════════════════════════════════════
if needReset
    state      := 0
    scIdx      := na
    scLow      := na
    scVol      := na
    psIdx      := na
    psLow      := na
    arIdx      := na
    arHigh     := na
    arCandIdx  := na
    arCandHigh := na
    stIdx      := na
    stLow      := na
    stVol      := na
    sprIdx     := na
    sprLow     := na
    sosIdx     := na
    sosHigh    := na
    lpsIdx     := na
    lpsLow     := na
    hlCount    := 0
    lastTRLow  := na
    phaseEPeak := na
    needReset  := false

// ═══════════════════════════════════════════════
// PHASE LABEL
// ═══════════════════════════════════════════════
f_phase() =>
    if na(scIdx)
        "?"
    else if state == 1
        "A"
    else if state == 2
        (bar_index - scIdx) < 20 ? "A" : "B"
    else if state == 3
        "C"
    else if state == 4 or state == 5
        "D"
    else if state == 6
        "E"
    else
        "?"

// ═══════════════════════════════════════════════
// VALIDATION SCORE  0-5
// ═══════════════════════════════════════════════
f_score() =>
    if na(scIdx)
        0
    else
        s = 0
        priorLen = math.min(bar_index - scIdx + 25, bar_index)
        if priorLen >= 5 and close[priorLen] >= scLow * (1.0 + i_priorDTPct / 100.0)
            s += 1
        if not na(scVol) and scVol >= volMA * i_volMult
            s += 1
        if not na(arIdx)
            s += 1
        if not na(stIdx) and not na(stVol) and stVol < scVol * 0.75
            s += 1
        if hlCount >= 2
            s += 1
        s

// ═══════════════════════════════════════════════
// DRAWING
// ═══════════════════════════════════════════════
var box   bx_tr  = na
var line  ln_sc  = na
var line  ln_ar  = na
var label lbl_ps = na
var label lbl_sc = na
var label lbl_ar = na
var label lbl_st = na
var label lbl_sp = na
var label lbl_ss = na
var label lbl_lp = na

if barstate.islast
    if not na(bx_tr)
        box.delete(bx_tr)
    if not na(ln_sc)
        line.delete(ln_sc)
    if not na(ln_ar)
        line.delete(ln_ar)
    if not na(lbl_ps)
        label.delete(lbl_ps)
    if not na(lbl_sc)
        label.delete(lbl_sc)
    if not na(lbl_ar)
        label.delete(lbl_ar)
    if not na(lbl_st)
        label.delete(lbl_st)
    if not na(lbl_sp)
        label.delete(lbl_sp)
    if not na(lbl_ss)
        label.delete(lbl_ss)
    if not na(lbl_lp)
        label.delete(lbl_lp)

    if i_showTR and not na(scIdx) and not na(arHigh)
        bx_tr := box.new(scIdx, arHigh, bar_index + 15, scLow,
                         bgcolor      = color.new(color.yellow, 88),
                         border_color = color.new(color.yellow, 40),
                         border_width = 1,
                         border_style = line.style_dashed)

    if i_showLines
        if not na(scLow)
            xSC   = not na(scIdx) ? scIdx : bar_index - 5
            ln_sc := line.new(xSC, scLow, bar_index + 20, scLow,
                              color=color.new(color.red, 30), width=1, style=line.style_dotted)
        if not na(arHigh)
            xAR   = not na(arIdx) ? arIdx : bar_index - 5
            ln_ar := line.new(xAR, arHigh, bar_index + 20, arHigh,
                              color=color.new(color.lime, 30), width=1, style=line.style_dotted)

    if i_showLabels
        if not na(psIdx)
            lbl_ps := label.new(psIdx, psLow * 0.985, "PS",
                                style=label.style_label_up, color=color.new(color.teal, 30),
                                textcolor=color.white, size=size.small)
        if not na(scIdx)
            lbl_sc := label.new(scIdx, scLow * 0.977, "SC",
                                style=label.style_label_up, color=color.new(color.red, 10),
                                textcolor=color.white, size=size.normal)
        if not na(arIdx)
            lbl_ar := label.new(arIdx, arHigh * 1.022, "AR",
                                style=label.style_label_down, color=color.new(color.green, 10),
                                textcolor=color.white, size=size.normal)
        if not na(stIdx)
            lbl_st := label.new(stIdx, stLow * 0.985, "ST",
                                style=label.style_label_up, color=color.new(color.orange, 20),
                                textcolor=color.white, size=size.small)
        if not na(sprIdx)
            lbl_sp := label.new(sprIdx, sprLow * 0.975, "SPRING",
                                style=label.style_label_up, color=color.new(color.lime, 0),
                                textcolor=color.black, size=size.normal)
        if not na(sosIdx)
            lbl_ss := label.new(sosIdx, sosHigh * 1.025, "SOS",
                                style=label.style_label_down, color=color.new(color.green, 0),
                                textcolor=color.white, size=size.large)
        if not na(lpsIdx)
            lbl_lp := label.new(lpsIdx, lpsLow * 0.985, "LPS",
                                style=label.style_label_up, color=color.new(color.aqua, 10),
                                textcolor=color.black, size=size.small)

// ═══════════════════════════════════════════════
// INFO TABLE
// ═══════════════════════════════════════════════
var table tbl = table.new(position.top_right, 2, 11,
                           bgcolor      = color.new(color.black, 15),
                           border_width = 1,
                           border_color = color.new(color.gray, 60))

if i_showTable and barstate.islast
    ph  = f_phase()
    sc  = f_score()

    phClr = switch ph
        "A" => color.orange
        "B" => color.yellow
        "C" => color.lime
        "D" => color.green
        "E" => color.teal
        =>     color.gray

    stStr = sc >= 5 ? "Confirmed" : sc >= 3 ? "Possible" : sc >= 1 ? "Weak" : "None"
    stClr = sc >= 5 ? color.green : sc >= 3 ? color.yellow : color.red

    trRng = not na(scLow) and not na(arHigh) ? str.tostring(math.round((arHigh - scLow) / scLow * 100.0, 1)) + "%" : "-"
    brStr = not na(scIdx)  ? str.tostring(bar_index - scIdx)     : "-"
    scStr = not na(scLow)  ? str.tostring(math.round(scLow,  4)) : "-"
    arStr = not na(arHigh) ? str.tostring(math.round(arHigh, 4)) : "-"
    spStr = not na(sprIdx) ? "Yes" : "No"
    ssStr = not na(sosIdx) ? "Yes" : "No"
    spClr = not na(sprIdx) ? color.lime  : color.gray
    ssClr = not na(sosIdx) ? color.green : color.gray

    phDs = switch ph
        "A" => "Stopping downtrend"
        "B" => "Building cause in TR"
        "C" => "Spring / Phase C test"
        "D" => "Markup beginning"
        "E" => "Uptrend active"
        =>     "Scanning..."

    hBg = color.new(#1a237e, 20)
    rBg = color.new(color.black, 30)

    table.cell(tbl, 0, 0,  "WYCKOFF",              text_color=color.white, text_size=size.small,  bgcolor=hBg)
    table.cell(tbl, 1, 0,  "ACCUMULATION",          text_color=color.white, text_size=size.small,  bgcolor=hBg)
    table.cell(tbl, 0, 1,  "Phase",                 text_color=color.gray,  text_size=size.small,  bgcolor=rBg)
    table.cell(tbl, 1, 1,  "Phase " + ph,           text_color=phClr,       text_size=size.normal, bgcolor=rBg)
    table.cell(tbl, 0, 2,  "Status",                text_color=color.gray,  text_size=size.small,  bgcolor=rBg)
    table.cell(tbl, 1, 2,  stStr,                   text_color=stClr,       text_size=size.small,  bgcolor=rBg)
    table.cell(tbl, 0, 3,  "Score",                 text_color=color.gray,  text_size=size.small,  bgcolor=rBg)
    table.cell(tbl, 1, 3,  str.tostring(sc) + "/5", text_color=color.white, text_size=size.small,  bgcolor=rBg)
    table.cell(tbl, 0, 4,  "TR Range",              text_color=color.gray,  text_size=size.small,  bgcolor=rBg)
    table.cell(tbl, 1, 4,  trRng,                   text_color=color.white, text_size=size.small,  bgcolor=rBg)
    table.cell(tbl, 0, 5,  "Bars in TR",            text_color=color.gray,  text_size=size.small,  bgcolor=rBg)
    table.cell(tbl, 1, 5,  brStr,                   text_color=color.white, text_size=size.small,  bgcolor=rBg)
    table.cell(tbl, 0, 6,  "SC Support",            text_color=color.gray,  text_size=size.small,  bgcolor=rBg)
    table.cell(tbl, 1, 6,  scStr,                   text_color=color.red,   text_size=size.small,  bgcolor=rBg)
    table.cell(tbl, 0, 7,  "AR Resistance",         text_color=color.gray,  text_size=size.small,  bgcolor=rBg)
    table.cell(tbl, 1, 7,  arStr,                   text_color=color.lime,  text_size=size.small,  bgcolor=rBg)
    table.cell(tbl, 0, 8,  "Spring",                text_color=color.gray,  text_size=size.small,  bgcolor=rBg)
    table.cell(tbl, 1, 8,  spStr,                   text_color=spClr,       text_size=size.small,  bgcolor=rBg)
    table.cell(tbl, 0, 9,  "SOS",                   text_color=color.gray,  text_size=size.small,  bgcolor=rBg)
    table.cell(tbl, 1, 9,  ssStr,                   text_color=ssClr,       text_size=size.small,  bgcolor=rBg)
    table.cell(tbl, 0, 10, "Desc",                  text_color=color.gray,  text_size=size.tiny,   bgcolor=rBg)
    table.cell(tbl, 1, 10, phDs,                    text_color=phClr,       text_size=size.tiny,   bgcolor=rBg)

// ═══════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════
alertcondition(not na(sprIdx) and sprIdx == bar_index,
               title="Wyckoff Spring",
               message="SPRING detected - Phase C. Watch for SOS breakout above AR.")

alertcondition(not na(sosIdx) and sosIdx == bar_index,
               title="Wyckoff SOS (Sign of Strength)",
               message="SOS detected - Phase D beginning. Look for LPS entry.")

alertcondition(not na(lpsIdx) and lpsIdx == bar_index,
               title="Wyckoff LPS - Entry Zone",
               message="LPS detected - Phase D confirmed. Prime entry zone above AR.")
````
