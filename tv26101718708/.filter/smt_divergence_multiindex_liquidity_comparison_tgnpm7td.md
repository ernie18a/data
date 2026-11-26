# SMT Divergence | Multi-Index Liquidity Comparison

- url: https://www.tradingview.com/script/TGNPm7td-SMT-Divergence-Multi-Index-Liquidity-Comparison/
- type: indicator
- pine_id: PUB;8c846a8bc7744dae8486d1503659c1ca
- version: 3.0

## Description

[b]SMT Divergence Map | Multi-Index Liquidity Comparison[/b]

[b]Description:[/b]
[i]Overview[/i]
This indicator tracks structural divergence between correlated index futures by comparing relative highs and lows across multiple markets. It is designed as a market-structure mapping tool, not as a standalone trade signal. The goal is to make intermarket disagreement visible so the user can judge whether one market is confirming or failing to confirm the movement of another.

[i]What the script plots[/i]
The script compares selected symbols such as NQ, ES, and YM and highlights divergence when one market takes a corresponding high or low while another does not. It can monitor multiple timeframes and can also project selected higher-timeframe reference levels onto the active chart so the user can evaluate divergence in context.

[i]How the logic works[/i]
The script reads highs and lows from 7 lookback bars of the selected symbols over the chosen comparison windows to the current market price. A bearish-style divergence is identified when one market trades above a prior reference high while another correlated market fails to do the same. A bullish-style divergence is identified when one market trades below a prior reference low while another correlated market fails to confirm that low. The script then plots the relevant divergence markers and optional reference lines on the chart.

[i]Inputs and customization[/i]
Users can choose which symbols to compare, which timeframes to evaluate, which divergence types to display, and whether to show supporting structures such as prior highs/lows, session references, daily references, or higher-timeframe range levels. Visual controls allow the user to adjust labels, line styles, colors, table size & transparency customization and display density.

[i]How to use it[/i]
This tool is best used as a structural context layer. It helps identify areas where correlated markets stop agreeing, which may matter near liquidity sweeps, session extremes, or higher-timeframe reference levels. The script does not place orders and does not guarantee reversal or continuation. It simply visualizes divergence so the trader can combine it with their own execution framework.

[i]Originality / why this script exists[/i]
This publication consolidates multiple SMT comparison functions into one configurable tool so users do not need several overlapping variants. The purpose is not to merge indicators for the sake of a mashup, but to provide one organized framework for viewing intermarket divergence, session references, and higher-timeframe structure in a single workflow.

[i]Limitations[/i]
Divergence is contextual and does not automatically imply a successful trade. Different data feeds, symbol mappings, session settings, and timeframes can change what is displayed. Users should verify the symbol configuration and session definitions before relying on the output.

[i]Note[/i]
This is a charting and analysis tool. It does not make performance claims, does not predict future results, and should be used as one component of a broader decision process.

## Source Code

````pine
//@version=6
indicator("SMT Divergence - Multi Timeframe Anchored", overlay=true, max_lines_count=500, max_labels_count=500)

//────────────────────────────────────────────────────
// Inputs
//────────────────────────────────────────────────────
groupSymbols = "Symbols"
nqSym = input.symbol("CME_MINI:NQ1!", "NQ Symbol", group=groupSymbols)
esSym = input.symbol("CME_MINI:ES1!", "ES Symbol", group=groupSymbols)
ymSym = input.symbol("CBOT_MINI:YM1!", "YM Symbol", group=groupSymbols)

groupTF = "Timeframes"
showTF1 = input.bool(true, "Show Timeframe 1", group=groupTF)
tf1Input = input.timeframe("", "Timeframe 1", group=groupTF)
lb1 = input.int(7, "Timeframe 1 Lookback", minval=1, maxval=7, group=groupTF)

showTF2 = input.bool(true, "Show Timeframe 2", group=groupTF)
tf2Input = input.timeframe("5", "Timeframe 2", group=groupTF)
lb2 = input.int(7, "Timeframe 2 Lookback", minval=1, maxval=7, group=groupTF)

showTF3 = input.bool(true, "Show Timeframe 3", group=groupTF)
tf3Input = input.timeframe("7", "Timeframe 3", group=groupTF)
lb3 = input.int(7, "Timeframe 3 Lookback", minval=1, maxval=7, group=groupTF)

showTF4 = input.bool(true, "Show Timeframe 4", group=groupTF)
tf4Input = input.timeframe("15", "Timeframe 4", group=groupTF)
lb4 = input.int(7, "Timeframe 4 Lookback", minval=1, maxval=7, group=groupTF)

showTF5 = input.bool(true, "Show Timeframe 5", group=groupTF)
tf5Input = input.timeframe("60", "Timeframe 5", group=groupTF)
lb5 = input.int(7, "Timeframe 5 Lookback", minval=1, maxval=7, group=groupTF)

groupDisplay = "Display"
showHighSMT = input.bool(true, "Show High SMT", group=groupDisplay)
showLowSMT = input.bool(true, "Show Low SMT", group=groupDisplay)
showLabels = input.bool(true, "Show Labels", group=groupDisplay)
showHistorical = input.bool(false, "Show Historical Lines", group=groupDisplay)
lineWidth = input.int(2, "Line Width", minval=1, maxval=5, group=groupDisplay)
lineStyleInput = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=groupDisplay)
labelSizeInput = input.string("Tiny", "Tag Size", options=["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], group=groupDisplay)

groupPlacement = "Tag Placement"
placeTF1 = input.string("Right", "Timeframe 1 Tag Placement", options=["Left", "Middle", "Right"], group=groupPlacement)
placeTF2 = input.string("Right", "Timeframe 2 Tag Placement", options=["Left", "Middle", "Right"], group=groupPlacement)
placeTF3 = input.string("Right", "Timeframe 3 Tag Placement", options=["Left", "Middle", "Right"], group=groupPlacement)
placeTF4 = input.string("Right", "Timeframe 4 Tag Placement", options=["Left", "Middle", "Right"], group=groupPlacement)
placeTF5 = input.string("Right", "Timeframe 5 Tag Placement", options=["Left", "Middle", "Right"], group=groupPlacement)

groupIPDA = "IPDA / 369"
useIPDAStyle = input.bool(true, "Dash + Recolor When Anchor Time Is IPDA / 369", group=groupIPDA)
ipdaTimeZone = input.string("America/New_York", "IPDA / 369 Time Zone", group=groupIPDA)
ipdaBearColor = input.color(color.rgb(236, 72, 153), "IPDA High SMT Color", group=groupIPDA)
ipdaBullColor = input.color(color.rgb(34, 197, 94), "IPDA Low SMT Color", group=groupIPDA)

groupColors1 = "Timeframe 1 Colors"
colTF1Bear = input.color(color.rgb(244, 114, 182), "TF1 High SMT", group=groupColors1)
colTF1Bull = input.color(color.rgb(56, 189, 248), "TF1 Low SMT", group=groupColors1)

groupColors2 = "Timeframe 2 Colors"
colTF2Bear = input.color(color.rgb(192, 132, 252), "TF2 High SMT", group=groupColors2)
colTF2Bull = input.color(color.rgb(96, 165, 250), "TF2 Low SMT", group=groupColors2)

groupColors3 = "Timeframe 3 Colors"
colTF3Bear = input.color(color.rgb(168, 85, 247), "TF3 High SMT", group=groupColors3)
colTF3Bull = input.color(color.rgb(59, 130, 246), "TF3 Low SMT", group=groupColors3)

groupColors4 = "Timeframe 4 Colors"
colTF4Bear = input.color(color.rgb(111, 66, 193), "TF4 High SMT", group=groupColors4)
colTF4Bull = input.color(color.rgb(14, 165, 233), "TF4 Low SMT", group=groupColors4)

groupColors5 = "Timeframe 5 Colors"
colTF5Bear = input.color(color.rgb(181, 146, 59), "TF5 High SMT", group=groupColors5)
colTF5Bull = input.color(color.rgb(245, 158, 11), "TF5 Low SMT", group=groupColors5)

groupTable = "Table Settings"
showTable = input.bool(true, "Show Summary Table", group=groupTable)
tableMode = input.string("Full", "Table Mode", options=["Full", "Minimal"], group=groupTable)
tablePositionInput = input.string("Bottom Center", "Table Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=groupTable)
tableTextSizeInput = input.string("Small", "Table Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=groupTable)
tableBgTransparency = input.int(15, "Table Transparency", minval=0, maxval=100, group=groupTable)
tableBorderWidth = input.int(2, "Table Border Width", minval=0, maxval=5, group=groupTable)
tableCol0Width = input.int(7, "Column 1 Width", minval=4, maxval=40, group=groupTable)
tableCol1Width = input.int(7, "Column 2 Width", minval=4, maxval=60, group=groupTable)
tableCol2Width = input.int(7, "Column 3 Width", minval=4, maxval=60, group=groupTable)

//────────────────────────────────────────────────────
// Helpers
// State encoding:
// 0 = reference not swept
// 1 = reference swept by current open candle
// 2 = invalid because an intermediate candle already swept it
//────────────────────────────────────────────────────
f_name(code) =>
    string s = "—"
    if code == 1
        s := "NQ"
    else if code == 2
        s := "ES"
    else if code == 3
        s := "YM"
    s

f_tf_eff(tf) =>
    tf == "" ? timeframe.period : tf

f_tf_label(tf) =>
    t = f_tf_eff(tf)
    string s = t
    if t == "1"
        s := "1M"
    else if t == "2"
        s := "2M"
    else if t == "3"
        s := "3M"
    else if t == "4"
        s := "4M"
    else if t == "5"
        s := "5M"
    else if t == "7"
        s := "7M"
    else if t == "10"
        s := "10M"
    else if t == "12"
        s := "12M"
    else if t == "15"
        s := "15M"
    else if t == "30"
        s := "30M"
    else if t == "60"
        s := "1H"
    else if t == "90"
        s := "90M"
    else if t == "240"
        s := "4H"
    else if t == "D" or t == "1D"
        s := "D"
    else if t == "W" or t == "1W"
        s := "W"
    else if t == "M" or t == "1M"
        s := "M"
    s

f_label_size() =>
    labelSizeInput == "Auto" ? size.auto :
     labelSizeInput == "Tiny" ? size.tiny :
     labelSizeInput == "Small" ? size.small :
     labelSizeInput == "Normal" ? size.normal :
     labelSizeInput == "Large" ? size.large : size.huge

f_table_text_size() =>
    tableTextSizeInput == "Tiny" ? size.tiny :
     tableTextSizeInput == "Small" ? size.small :
     tableTextSizeInput == "Normal" ? size.normal :
     tableTextSizeInput == "Large" ? size.large : size.huge

f_table_position() =>
    tablePositionInput == "Top Left" ? position.top_left :
     tablePositionInput == "Top Center" ? position.top_center :
     tablePositionInput == "Top Right" ? position.top_right :
     tablePositionInput == "Middle Left" ? position.middle_left :
     tablePositionInput == "Middle Center" ? position.middle_center :
     tablePositionInput == "Middle Right" ? position.middle_right :
     tablePositionInput == "Bottom Left" ? position.bottom_left :
     tablePositionInput == "Bottom Center" ? position.bottom_center : position.bottom_right

f_line_style() =>
    lineStyleInput == "Dashed" ? line.style_dashed :
     lineStyleInput == "Dotted" ? line.style_dotted : line.style_solid

f_label_x(t1, t2, placement) =>
    placement == "Left" ? t1 : placement == "Middle" ? int(math.round((t1 + t2) / 2.0)) : t2

f_label_y(y1, y2, placement) =>
    placement == "Left" ? y1 : placement == "Middle" ? (y1 + y2) / 2.0 : y2

f_is_ipda_ts(ts) =>
    int h = hour(ts, ipdaTimeZone)
    int m = minute(ts, ipdaTimeZone)
    bool mod0 = math.floor(math.abs(m % 3)) == 0
    bool mod1 = math.floor(math.abs(m % 3)) == 1
    bool mod2 = math.floor(math.abs(m % 3)) == 2
    bool hourSet0 = h == 9 or h == 12 or h == 15 or h == 21
    bool hourSet1 = h == 11 or h == 14 or h == 20 or h == 23
    bool hourSet2 = h == 10 or h == 13 or h == 16 or h == 19 or h == 22
    (hourSet0 and mod0) or (hourSet1 and mod1) or (hourSet2 and mod2)

f_pow3(idx) =>
    idx == 0 ? 1 :
     idx == 1 ? 3 :
     idx == 2 ? 9 :
     idx == 3 ? 27 :
     idx == 4 ? 81 :
     idx == 5 ? 243 : 729

f_state_digit(mask, idx) =>
    int v = int(math.floor(mask / f_pow3(idx)))
    v % 3

f_outlier_state(a, b, c) =>
    int result = 0
    if a != 2 and b != 2 and c != 2
        if a == b and b != c
            result := 3
        else if a == c and c != b
            result := 2
        else if b == c and c != a
            result := 1
    result

f_out_for_idx(nqMask, esMask, ymMask, idx) =>
    f_outlier_state(f_state_digit(nqMask, idx), f_state_digit(esMask, idx), f_state_digit(ymMask, idx))

f_add_unique_symbol(base, code) =>
    sym = f_name(code)
    code == 0 ? base : str.contains(base, sym) ? base : base == "—" ? sym : base + "|" + sym

f_state_mask_7() =>
    int h1 = high > high[1] ? 1 : 0

    bool h2Clean = high[1] <= high[2]
    int h2 = h2Clean ? (high > high[2] ? 1 : 0) : 2

    bool h3Clean = math.max(high[1], high[2]) <= high[3]
    int h3 = h3Clean ? (high > high[3] ? 1 : 0) : 2

    bool h4Clean = math.max(math.max(high[1], high[2]), high[3]) <= high[4]
    int h4 = h4Clean ? (high > high[4] ? 1 : 0) : 2

    bool h5Clean = math.max(math.max(math.max(high[1], high[2]), high[3]), high[4]) <= high[5]
    int h5 = h5Clean ? (high > high[5] ? 1 : 0) : 2

    bool h6Clean = math.max(math.max(math.max(math.max(high[1], high[2]), high[3]), high[4]), high[5]) <= high[6]
    int h6 = h6Clean ? (high > high[6] ? 1 : 0) : 2

    bool h7Clean = math.max(math.max(math.max(math.max(math.max(high[1], high[2]), high[3]), high[4]), high[5]), high[6]) <= high[7]
    int h7 = h7Clean ? (high > high[7] ? 1 : 0) : 2

    int l1 = low < low[1] ? 1 : 0

    bool l2Clean = low[1] >= low[2]
    int l2 = l2Clean ? (low < low[2] ? 1 : 0) : 2

    bool l3Clean = math.min(low[1], low[2]) >= low[3]
    int l3 = l3Clean ? (low < low[3] ? 1 : 0) : 2

    bool l4Clean = math.min(math.min(low[1], low[2]), low[3]) >= low[4]
    int l4 = l4Clean ? (low < low[4] ? 1 : 0) : 2

    bool l5Clean = math.min(math.min(math.min(low[1], low[2]), low[3]), low[4]) >= low[5]
    int l5 = l5Clean ? (low < low[5] ? 1 : 0) : 2

    bool l6Clean = math.min(math.min(math.min(math.min(low[1], low[2]), low[3]), low[4]), low[5]) >= low[6]
    int l6 = l6Clean ? (low < low[6] ? 1 : 0) : 2

    bool l7Clean = math.min(math.min(math.min(math.min(math.min(low[1], low[2]), low[3]), low[4]), low[5]), low[6]) >= low[7]
    int l7 = l7Clean ? (low < low[7] ? 1 : 0) : 2

    int highMask = h1 + h2 * 3 + h3 * 9 + h4 * 27 + h5 * 81 + h6 * 243 + h7 * 729
    int lowMask = l1 + l2 * 3 + l3 * 9 + l4 * 27 + l5 * 81 + l6 * 243 + l7 * 729

    [highMask, lowMask]

f_shift7_float(arr) =>
    array.set(arr, 6, array.get(arr, 5))
    array.set(arr, 5, array.get(arr, 4))
    array.set(arr, 4, array.get(arr, 3))
    array.set(arr, 3, array.get(arr, 2))
    array.set(arr, 2, array.get(arr, 1))
    array.set(arr, 1, array.get(arr, 0))

f_shift7_int(arr) =>
    array.set(arr, 6, array.get(arr, 5))
    array.set(arr, 5, array.get(arr, 4))
    array.set(arr, 4, array.get(arr, 3))
    array.set(arr, 3, array.get(arr, 2))
    array.set(arr, 2, array.get(arr, 1))
    array.set(arr, 1, array.get(arr, 0))

f_update_tracker(newTF, barIsIPDA, currHigh, currLow, currHighTime, currLowTime, currHighIPDA, currLowIPDA, arrHigh, arrLow, arrHighTime, arrLowTime) =>
    float outHigh = currHigh
    float outLow = currLow
    int outHighTime = currHighTime
    int outLowTime = currLowTime
    bool outHighIPDA = currHighIPDA
    bool outLowIPDA = currLowIPDA

    if newTF
        f_shift7_float(arrHigh)
        f_shift7_float(arrLow)
        f_shift7_int(arrHighTime)
        f_shift7_int(arrLowTime)

        array.set(arrHigh, 0, outHigh)
        array.set(arrLow, 0, outLow)
        array.set(arrHighTime, 0, outHighTime)
        array.set(arrLowTime, 0, outLowTime)

        outHigh := high
        outLow := low
        outHighTime := time
        outLowTime := time
        outHighIPDA := barIsIPDA
        outLowIPDA := barIsIPDA
    else
        if na(outHigh)
            outHigh := high
            outLow := low
            outHighTime := time
            outLowTime := time
            outHighIPDA := barIsIPDA
            outLowIPDA := barIsIPDA
        else
            if high >= outHigh
                outHigh := high
                outHighTime := time
                outHighIPDA := barIsIPDA
            if low <= outLow
                outLow := low
                outLowTime := time
                outLowIPDA := barIsIPDA

    [outHigh, outLow, outHighTime, outLowTime, outHighIPDA, outLowIPDA]

f_select_high(lbCount, nqMask, esMask, ymMask, arrHigh, arrHighTime) =>
    bool found = false
    float bestPrice = na
    int bestTime = na
    int bestOut = 0

    for i = 0 to 6
        if i < lbCount
            out = f_out_for_idx(nqMask, esMask, ymMask, i)
            refPrice = array.get(arrHigh, i)
            refTime = array.get(arrHighTime, i)

            if out != 0 and not na(refPrice) and not na(refTime)
                if not found
                    found := true
                    bestPrice := refPrice
                    bestTime := refTime
                    bestOut := out
                else if refPrice > bestPrice
                    bestPrice := refPrice
                    bestTime := refTime
                    bestOut := out

    [found, bestPrice, bestTime, bestOut]

f_select_low(lbCount, nqMask, esMask, ymMask, arrLow, arrLowTime) =>
    bool found = false
    float bestPrice = na
    int bestTime = na
    int bestOut = 0

    for i = 0 to 6
        if i < lbCount
            out = f_out_for_idx(nqMask, esMask, ymMask, i)
            refPrice = array.get(arrLow, i)
            refTime = array.get(arrLowTime, i)

            if out != 0 and not na(refPrice) and not na(refTime)
                if not found
                    found := true
                    bestPrice := refPrice
                    bestTime := refTime
                    bestOut := out
                else if refPrice < bestPrice
                    bestPrice := refPrice
                    bestTime := refTime
                    bestOut := out

    [found, bestPrice, bestTime, bestOut]

f_manage_line_label(ln, lb, active, t1, y1, t2, y2, txt, col, isHigh, dashed, placement) =>
    line outLine = ln
    label outLabel = lb

    if active
        usedStyle = dashed ? line.style_dashed : f_line_style()

        if na(outLine)
            outLine := line.new(x1=t1, y1=y1, x2=t2, y2=y2, xloc=xloc.bar_time, extend=extend.none, color=col, style=usedStyle, width=lineWidth)
        else
            line.set_xy1(outLine, t1, y1)
            line.set_xy2(outLine, t2, y2)
            line.set_color(outLine, col)
            line.set_style(outLine, usedStyle)
            line.set_width(outLine, lineWidth)

        if showLabels
            lx = f_label_x(t1, t2, placement)
            ly = f_label_y(y1, y2, placement)

            if na(outLabel)
                outLabel := label.new(x=lx, y=ly, xloc=xloc.bar_time, text=txt, style=isHigh ? label.style_label_down : label.style_label_up, color=col, textcolor=color.white, size=f_label_size())
            else
                label.set_xy(outLabel, lx, ly)
                label.set_text(outLabel, txt)
                label.set_color(outLabel, col)
                label.set_textcolor(outLabel, color.white)
                label.set_style(outLabel, isHigh ? label.style_label_down : label.style_label_up)
                label.set_size(outLabel, f_label_size())
        else
            if not na(outLabel)
                label.delete(outLabel)
                outLabel := na
    else
        if not na(outLine)
            line.delete(outLine)
            outLine := na
        if not na(outLabel)
            label.delete(outLabel)
            outLabel := na

    [outLine, outLabel]

f_make_hist_label(t1, y1, t2, y2, txt, col, isHigh, placement) =>
    label.new(x=f_label_x(t1, t2, placement), y=f_label_y(y1, y2, placement), xloc=xloc.bar_time, text=txt, style=isHigh ? label.style_label_down : label.style_label_up, color=col, textcolor=color.white, size=f_label_size())

f_process_slot(enabled, lbCount, tfText, placement, colBear, colBull, currHigh, currLow, currHighTime, currLowTime, currHighIPDA, currLowIPDA, arrHigh, arrLow, arrHighTime, arrLowTime, hiLine, hiLabel, loLine, loLabel, nqHighMask, esHighMask, ymHighMask, nqLowMask, esLowMask, ymLowMask) =>
    [highFound, highRef, highRefTime, highOut] = f_select_high(lbCount, nqHighMask, esHighMask, ymHighMask, arrHigh, arrHighTime)
    [lowFound, lowRef, lowRefTime, lowOut] = f_select_low(lbCount, nqLowMask, esLowMask, ymLowMask, arrLow, arrLowTime)

    highActive = enabled and showHighSMT and highFound and not na(currHighTime) and not na(currHigh)
    lowActive = enabled and showLowSMT and lowFound and not na(currLowTime) and not na(currLow)

    highColor = useIPDAStyle and currHighIPDA ? ipdaBearColor : colBear
    lowColor = useIPDAStyle and currLowIPDA ? ipdaBullColor : colBull

    highDashed = useIPDAStyle and currHighIPDA
    lowDashed = useIPDAStyle and currLowIPDA

    highText = highActive ? tfText + " " + f_name(highOut) : "—"
    lowText = lowActive ? tfText + " " + f_name(lowOut) : "—"

    if showHistorical and highActive[1] and not highActive
        line.new(x1=highRefTime[1], y1=highRef[1], x2=currHighTime[1], y2=currHigh[1], xloc=xloc.bar_time, extend=extend.none, color=highColor[1], style=highDashed[1] ? line.style_dashed : f_line_style(), width=lineWidth)
        if showLabels
            f_make_hist_label(highRefTime[1], highRef[1], currHighTime[1], currHigh[1], highText[1], highColor[1], true, placement)

    if showHistorical and lowActive[1] and not lowActive
        line.new(x1=lowRefTime[1], y1=lowRef[1], x2=currLowTime[1], y2=currLow[1], xloc=xloc.bar_time, extend=extend.none, color=lowColor[1], style=lowDashed[1] ? line.style_dashed : f_line_style(), width=lineWidth)
        if showLabels
            f_make_hist_label(lowRefTime[1], lowRef[1], currLowTime[1], currLow[1], lowText[1], lowColor[1], false, placement)

    [newHiLine, newHiLabel] = f_manage_line_label(hiLine, hiLabel, highActive, highRefTime, highRef, currHighTime, currHigh, highText, highColor, true, highDashed, placement)
    [newLoLine, newLoLabel] = f_manage_line_label(loLine, loLabel, lowActive, lowRefTime, lowRef, currLowTime, currLow, lowText, lowColor, false, lowDashed, placement)

    [newHiLine, newHiLabel, newLoLine, newLoLabel, highText, lowText]

//────────────────────────────────────────────────────
// Core state
//────────────────────────────────────────────────────
tf1 = f_tf_eff(tf1Input)
tf2 = f_tf_eff(tf2Input)
tf3 = f_tf_eff(tf3Input)
tf4 = f_tf_eff(tf4Input)
tf5 = f_tf_eff(tf5Input)

tf1Text = f_tf_label(tf1Input)
tf2Text = f_tf_label(tf2Input)
tf3Text = f_tf_label(tf3Input)
tf4Text = f_tf_label(tf4Input)
tf5Text = f_tf_label(tf5Input)

newTF1 = ta.change(time(tf1)) != 0
newTF2 = ta.change(time(tf2)) != 0
newTF3 = ta.change(time(tf3)) != 0
newTF4 = ta.change(time(tf4)) != 0
newTF5 = ta.change(time(tf5)) != 0

currBarIsIPDA = f_is_ipda_ts(time)

//────────────────────────────────────────────────────
// Security calls for SMT state
//────────────────────────────────────────────────────
[nqHMask1, nqLMask1] = request.security(nqSym, tf1, f_state_mask_7(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
[esHMask1, esLMask1] = request.security(esSym, tf1, f_state_mask_7(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
[ymHMask1, ymLMask1] = request.security(ymSym, tf1, f_state_mask_7(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

[nqHMask2, nqLMask2] = request.security(nqSym, tf2, f_state_mask_7(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
[esHMask2, esLMask2] = request.security(esSym, tf2, f_state_mask_7(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
[ymHMask2, ymLMask2] = request.security(ymSym, tf2, f_state_mask_7(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

[nqHMask3, nqLMask3] = request.security(nqSym, tf3, f_state_mask_7(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
[esHMask3, esLMask3] = request.security(esSym, tf3, f_state_mask_7(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
[ymHMask3, ymLMask3] = request.security(ymSym, tf3, f_state_mask_7(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

[nqHMask4, nqLMask4] = request.security(nqSym, tf4, f_state_mask_7(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
[esHMask4, esLMask4] = request.security(esSym, tf4, f_state_mask_7(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
[ymHMask4, ymLMask4] = request.security(ymSym, tf4, f_state_mask_7(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

[nqHMask5, nqLMask5] = request.security(nqSym, tf5, f_state_mask_7(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
[esHMask5, esLMask5] = request.security(esSym, tf5, f_state_mask_7(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
[ymHMask5, ymLMask5] = request.security(ymSym, tf5, f_state_mask_7(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

//────────────────────────────────────────────────────
// Local chart-anchor trackers
//────────────────────────────────────────────────────
var float currHigh1 = na
var float currLow1 = na
var int currHighTime1 = na
var int currLowTime1 = na
var bool currHighIPDA1 = false
var bool currLowIPDA1 = false
var float[] arrHigh1 = array.new_float(7, na)
var float[] arrLow1 = array.new_float(7, na)
var int[] arrHighTime1 = array.new_int(7, na)
var int[] arrLowTime1 = array.new_int(7, na)
var line hiLine1 = na
var line loLine1 = na
var label hiLabel1 = na
var label loLabel1 = na

var float currHigh2 = na
var float currLow2 = na
var int currHighTime2 = na
var int currLowTime2 = na
var bool currHighIPDA2 = false
var bool currLowIPDA2 = false
var float[] arrHigh2 = array.new_float(7, na)
var float[] arrLow2 = array.new_float(7, na)
var int[] arrHighTime2 = array.new_int(7, na)
var int[] arrLowTime2 = array.new_int(7, na)
var line hiLine2 = na
var line loLine2 = na
var label hiLabel2 = na
var label loLabel2 = na

var float currHigh3 = na
var float currLow3 = na
var int currHighTime3 = na
var int currLowTime3 = na
var bool currHighIPDA3 = false
var bool currLowIPDA3 = false
var float[] arrHigh3 = array.new_float(7, na)
var float[] arrLow3 = array.new_float(7, na)
var int[] arrHighTime3 = array.new_int(7, na)
var int[] arrLowTime3 = array.new_int(7, na)
var line hiLine3 = na
var line loLine3 = na
var label hiLabel3 = na
var label loLabel3 = na

var float currHigh4 = na
var float currLow4 = na
var int currHighTime4 = na
var int currLowTime4 = na
var bool currHighIPDA4 = false
var bool currLowIPDA4 = false
var float[] arrHigh4 = array.new_float(7, na)
var float[] arrLow4 = array.new_float(7, na)
var int[] arrHighTime4 = array.new_int(7, na)
var int[] arrLowTime4 = array.new_int(7, na)
var line hiLine4 = na
var line loLine4 = na
var label hiLabel4 = na
var label loLabel4 = na

var float currHigh5 = na
var float currLow5 = na
var int currHighTime5 = na
var int currLowTime5 = na
var bool currHighIPDA5 = false
var bool currLowIPDA5 = false
var float[] arrHigh5 = array.new_float(7, na)
var float[] arrLow5 = array.new_float(7, na)
var int[] arrHighTime5 = array.new_int(7, na)
var int[] arrLowTime5 = array.new_int(7, na)
var line hiLine5 = na
var line loLine5 = na
var label hiLabel5 = na
var label loLabel5 = na

//────────────────────────────────────────────────────
// Update exact current-candle high/low anchors
//────────────────────────────────────────────────────
[tmpHigh1, tmpLow1, tmpHighTime1, tmpLowTime1, tmpHighIPDA1, tmpLowIPDA1] = f_update_tracker(newTF1, currBarIsIPDA, currHigh1, currLow1, currHighTime1, currLowTime1, currHighIPDA1, currLowIPDA1, arrHigh1, arrLow1, arrHighTime1, arrLowTime1)
currHigh1 := tmpHigh1
currLow1 := tmpLow1
currHighTime1 := tmpHighTime1
currLowTime1 := tmpLowTime1
currHighIPDA1 := tmpHighIPDA1
currLowIPDA1 := tmpLowIPDA1

[tmpHigh2, tmpLow2, tmpHighTime2, tmpLowTime2, tmpHighIPDA2, tmpLowIPDA2] = f_update_tracker(newTF2, currBarIsIPDA, currHigh2, currLow2, currHighTime2, currLowTime2, currHighIPDA2, currLowIPDA2, arrHigh2, arrLow2, arrHighTime2, arrLowTime2)
currHigh2 := tmpHigh2
currLow2 := tmpLow2
currHighTime2 := tmpHighTime2
currLowTime2 := tmpLowTime2
currHighIPDA2 := tmpHighIPDA2
currLowIPDA2 := tmpLowIPDA2

[tmpHigh3, tmpLow3, tmpHighTime3, tmpLowTime3, tmpHighIPDA3, tmpLowIPDA3] = f_update_tracker(newTF3, currBarIsIPDA, currHigh3, currLow3, currHighTime3, currLowTime3, currHighIPDA3, currLowIPDA3, arrHigh3, arrLow3, arrHighTime3, arrLowTime3)
currHigh3 := tmpHigh3
currLow3 := tmpLow3
currHighTime3 := tmpHighTime3
currLowTime3 := tmpLowTime3
currHighIPDA3 := tmpHighIPDA3
currLowIPDA3 := tmpLowIPDA3

[tmpHigh4, tmpLow4, tmpHighTime4, tmpLowTime4, tmpHighIPDA4, tmpLowIPDA4] = f_update_tracker(newTF4, currBarIsIPDA, currHigh4, currLow4, currHighTime4, currLowTime4, currHighIPDA4, currLowIPDA4, arrHigh4, arrLow4, arrHighTime4, arrLowTime4)
currHigh4 := tmpHigh4
currLow4 := tmpLow4
currHighTime4 := tmpHighTime4
currLowTime4 := tmpLowTime4
currHighIPDA4 := tmpHighIPDA4
currLowIPDA4 := tmpLowIPDA4

[tmpHigh5, tmpLow5, tmpHighTime5, tmpLowTime5, tmpHighIPDA5, tmpLowIPDA5] = f_update_tracker(newTF5, currBarIsIPDA, currHigh5, currLow5, currHighTime5, currLowTime5, currHighIPDA5, currLowIPDA5, arrHigh5, arrLow5, arrHighTime5, arrLowTime5)
currHigh5 := tmpHigh5
currLow5 := tmpLow5
currHighTime5 := tmpHighTime5
currLowTime5 := tmpLowTime5
currHighIPDA5 := tmpHighIPDA5
currLowIPDA5 := tmpLowIPDA5

//────────────────────────────────────────────────────
// Process and draw SMT
//────────────────────────────────────────────────────
[newHiLine1, newHiLabel1, newLoLine1, newLoLabel1, txtHigh1, txtLow1] = f_process_slot(showTF1, lb1, tf1Text, placeTF1, colTF1Bear, colTF1Bull, currHigh1, currLow1, currHighTime1, currLowTime1, currHighIPDA1, currLowIPDA1, arrHigh1, arrLow1, arrHighTime1, arrLowTime1, hiLine1, hiLabel1, loLine1, loLabel1, nqHMask1, esHMask1, ymHMask1, nqLMask1, esLMask1, ymLMask1)
hiLine1 := newHiLine1
hiLabel1 := newHiLabel1
loLine1 := newLoLine1
loLabel1 := newLoLabel1

[newHiLine2, newHiLabel2, newLoLine2, newLoLabel2, txtHigh2, txtLow2] = f_process_slot(showTF2, lb2, tf2Text, placeTF2, colTF2Bear, colTF2Bull, currHigh2, currLow2, currHighTime2, currLowTime2, currHighIPDA2, currLowIPDA2, arrHigh2, arrLow2, arrHighTime2, arrLowTime2, hiLine2, hiLabel2, loLine2, loLabel2, nqHMask2, esHMask2, ymHMask2, nqLMask2, esLMask2, ymLMask2)
hiLine2 := newHiLine2
hiLabel2 := newHiLabel2
loLine2 := newLoLine2
loLabel2 := newLoLabel2

[newHiLine3, newHiLabel3, newLoLine3, newLoLabel3, txtHigh3, txtLow3] = f_process_slot(showTF3, lb3, tf3Text, placeTF3, colTF3Bear, colTF3Bull, currHigh3, currLow3, currHighTime3, currLowTime3, currHighIPDA3, currLowIPDA3, arrHigh3, arrLow3, arrHighTime3, arrLowTime3, hiLine3, hiLabel3, loLine3, loLabel3, nqHMask3, esHMask3, ymHMask3, nqLMask3, esLMask3, ymLMask3)
hiLine3 := newHiLine3
hiLabel3 := newHiLabel3
loLine3 := newLoLine3
loLabel3 := newLoLabel3

[newHiLine4, newHiLabel4, newLoLine4, newLoLabel4, txtHigh4, txtLow4] = f_process_slot(showTF4, lb4, tf4Text, placeTF4, colTF4Bear, colTF4Bull, currHigh4, currLow4, currHighTime4, currLowTime4, currHighIPDA4, currLowIPDA4, arrHigh4, arrLow4, arrHighTime4, arrLowTime4, hiLine4, hiLabel4, loLine4, loLabel4, nqHMask4, esHMask4, ymHMask4, nqLMask4, esLMask4, ymLMask4)
hiLine4 := newHiLine4
hiLabel4 := newHiLabel4
loLine4 := newLoLine4
loLabel4 := newLoLabel4

[newHiLine5, newHiLabel5, newLoLine5, newLoLabel5, txtHigh5, txtLow5] = f_process_slot(showTF5, lb5, tf5Text, placeTF5, colTF5Bear, colTF5Bull, currHigh5, currLow5, currHighTime5, currLowTime5, currHighIPDA5, currLowIPDA5, arrHigh5, arrLow5, arrHighTime5, arrLowTime5, hiLine5, hiLabel5, loLine5, loLabel5, nqHMask5, esHMask5, ymHMask5, nqLMask5, esLMask5, ymLMask5)
hiLine5 := newHiLine5
hiLabel5 := newHiLabel5
loLine5 := newLoLine5
loLabel5 := newLoLabel5

//────────────────────────────────────────────────────
// Table
//────────────────────────────────────────────────────
bgHeader = color.new(color.black, tableBgTransparency)
bgRow = color.new(color.black, math.min(tableBgTransparency + 20, 100))
bgEmpty = color.new(color.gray, 80)
txtSize = f_table_text_size()

var table smtTable = table.new(f_table_position(), 3, 6, border_width=tableBorderWidth)

f_table_cell(col, row, txt, txtCol, bgCol, widthPct) =>
    table.cell(smtTable, col, row, txt, text_color=txtCol, bgcolor=bgCol, text_size=txtSize, width=widthPct)

f_draw_table_row(row, labelTxt, highTxt, lowTxt, highBg, lowBg) =>
    f_table_cell(0, row, labelTxt, color.white, bgRow, tableCol0Width)
    f_table_cell(1, row, highTxt, color.white, highTxt == "—" ? bgEmpty : highBg, tableCol1Width)
    f_table_cell(2, row, lowTxt, color.white, lowTxt == "—" ? bgEmpty : lowBg, tableCol2Width)

if barstate.islast
    if showTable
        table.clear(smtTable, 0, 0, 2, 5)

        f_table_cell(0, 0, "TF", color.white, bgHeader, tableCol0Width)
        f_table_cell(1, 0, "High", color.white, bgHeader, tableCol1Width)
        f_table_cell(2, 0, "Low", color.white, bgHeader, tableCol2Width)

        int rowPtr = 1

        if showTF1 and (tableMode == "Full" or txtHigh1 != "—" or txtLow1 != "—")
            f_draw_table_row(rowPtr, tf1Text, txtHigh1, txtLow1, colTF1Bear, colTF1Bull)
            rowPtr += 1

        if showTF2 and (tableMode == "Full" or txtHigh2 != "—" or txtLow2 != "—")
            f_draw_table_row(rowPtr, tf2Text, txtHigh2, txtLow2, colTF2Bear, colTF2Bull)
            rowPtr += 1

        if showTF3 and (tableMode == "Full" or txtHigh3 != "—" or txtLow3 != "—")
            f_draw_table_row(rowPtr, tf3Text, txtHigh3, txtLow3, colTF3Bear, colTF3Bull)
            rowPtr += 1

        if showTF4 and (tableMode == "Full" or txtHigh4 != "—" or txtLow4 != "—")
            f_draw_table_row(rowPtr, tf4Text, txtHigh4, txtLow4, colTF4Bear, colTF4Bull)
            rowPtr += 1

        if showTF5 and (tableMode == "Full" or txtHigh5 != "—" or txtLow5 != "—")
            f_draw_table_row(rowPtr, tf5Text, txtHigh5, txtLow5, colTF5Bear, colTF5Bull)
            rowPtr += 1
    else
        table.clear(smtTable, 0, 0, 2, 5)
````
