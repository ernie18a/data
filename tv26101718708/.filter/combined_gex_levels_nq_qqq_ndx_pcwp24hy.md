# Combined GEX Levels (NQ / QQQ / NDX)

- url: https://www.tradingview.com/script/PCWP24hy-Combined-GEX-Levels-NQ-QQQ-NDX/
- type: indicator
- pine_id: PUB;ba2c56c507ec4163b7d7b318b5ce75a5
- version: 1.0

## Description

GEX Levels – NQ / QQQ / NDX
This indicator plots key Gamma Exposure (GEX) levels for the Nasdaq complex, helping traders visualize where options dealer positioning may influence price action on NQ futures, QQQ, and NDX.
What it shows:

Major positive and negative gamma levels (dealer long/short gamma zones)
Zero Gamma Flip level — the point where dealer hedging behavior tends to shift from stabilizing to amplifying price moves
Call and put wall levels — strikes with the largest open interest/gamma concentration, often acting as support/resistance
Highlights zones where volatility is likely to compress (positive gamma) vs. expand (negative gamma)

How to use it:
GEX levels are most useful as context for intraday support/resistance and volatility expectations, not standalon

## Source Code

````pine
//@version=6
indicator("Combined GEX Levels (NQ / QQQ / NDX)", overlay=true, max_lines_count=500, max_labels_count=500)

// =================================================================
//  Combine NQ + QQQ + NDX GEX paste-strings into ONE indicator.
//  - Lines colored BY LEVEL TYPE, spanning the full chart width.
//  - Labels are boxed, color-matched, and sit just to the RIGHT of
//    the last candle (in the empty space) so they never cover price.
//  Paste each provider string into its box below. The "$TICKER:"
//  prefix is stripped automatically; the source name comes from the
//  "Label prefix" field.
// =================================================================

// ----------------------------- NQ -----------------------------
grpNQ    = "NQ source"
nqEnable = input.bool(true,  "Enable NQ", group=grpNQ)
nqPrefix = input.string("NQ", "Label prefix", group=grpNQ)
nqMult   = input.float(1.0, "Price multiplier", group=grpNQ, tooltip="Leave at 1 if levels already match the chart price.")
nqRaw    = input.text_area("$NQ1!: Call Resistance, 31000, Put Support, 29000, HVL, 29710, 1D Min, 28856.11, 1D Max, 29880.39, Call Resistance 0DTE, 30000, Put Support 0DTE, 28750, HVL 0DTE, 29530, Gamma Wall 0DTE, 30000, GEX 1, 29500, GEX 2, 29700, GEX 3, 28900, GEX 4, 29200, GEX 5, 29100, GEX 6, 28500, GEX 7, 28600, GEX 8, 28800, GEX 9, 28700, GEX 10, 28400, BL 1, 29507.02, BL 2, 30126.68, BL 3, 30288.84, BL 4, 29755.57, BL 5, 28825.42, BL 6, 30166.96, BL 7, 28513.54, BL 8, 29366.33, BL 9, 28462.17, BL 10, 28553.71", "NQ data", group=grpNQ)

// ----------------------------- QQQ ----------------------------
grpQQQ    = "QQQ source"
qqqEnable = input.bool(true,   "Enable QQQ", group=grpQQQ)
qqqPrefix = input.string("QQQ", "Label prefix", group=grpQQQ)
qqqMult   = input.float(1.0, "Price multiplier", group=grpQQQ, tooltip="Leave at 1 if levels already match the chart price.")
qqqRaw    = input.text_area("$NQ1!: Call Resistance, 33253.98, Put Support, 29097.23, HVL, 30302.69, 1D Min, 28834.94, 1D Max, 29901.56, Call Resistance 0DTE, 30136.42, Put Support 0DTE, 29097.23, HVL 0DTE, 29970.15, Gamma Wall 0DTE, 30136.42, GEX 1, 29720.74, GEX 2, 29305.07, GEX 3, 28889.39, GEX 4, 29512.9, GEX 5, 29471.34, GEX 6, 28681.55, GEX 7, 29928.58, GEX 8, 28473.72, GEX 9, 30177.98, GEX 10, 30344.25, BL 1, 29507.08, BL 2, 30126.86, BL 3, 30288.97, BL 4, 29755.66, BL 5, 28825.38, BL 6, 30166.76, BL 7, 28513.62, BL 8, 29366.17, BL 9, 28462.08, BL 10, 28553.53", "QQQ data", group=grpQQQ)

// ----------------------------- NDX ----------------------------
grpNDX    = "NDX source"
ndxEnable = input.bool(true,   "Enable NDX", group=grpNDX)
ndxPrefix = input.string("NDX", "Label prefix", group=grpNDX)
ndxMult   = input.float(1.0, "Price multiplier", group=grpNDX, tooltip="Leave at 1 if levels already match the chart price.")
ndxRaw    = input.text_area("$NQ1!: Call Resistance, 30585.37, Put Support, 28240.41, HVL, 29430.54, 1D Min, 28874.37, 1D Max, 29862.13, Call Resistance 0DTE, 29511.23, Put Support 0DTE, 28845.56, HVL 0DTE, 29682.69, Gamma Wall 0DTE, 29511.23, GEX 1, 29753.29, GEX 2, 29450.71, GEX 3, 29248.99, GEX 4, 29047.28, GEX 5, 29652.43, GEX 6, 28744.7, GEX 7, 30257.58, GEX 8, 30005.43, GEX 9, 30055.86, GEX 10, 28542.98, BL 1, 29507.02, BL 2, 30126.69, BL 3, 30288.85, BL 4, 29755.58, BL 5, 28825.42, BL 6, 30166.96, BL 7, 28513.54, BL 8, 29366.33, BL 9, 28462.17, BL 10, 28553.72", "NDX data", group=grpNDX)

// ------------------------- Level colors -----------------------
grpC       = "Level colors"
colCallRes = input.color(#ef5350, "Call Resistance (red)",     group=grpC)
colPutSup  = input.color(#26a69a, "Put Support (green)",       group=grpC)
colHVL     = input.color(#ffeb3b, "HVL / HVL 0DTE (yellow)",   group=grpC)
colGamma   = input.color(#ff9800, "Gamma Wall (orange)",       group=grpC)
colBL      = input.color(#ec407a, "Blind spots / BL (pink)",   group=grpC)
colGEX     = input.color(#ffffff, "GEX 1-10 (white)",          group=grpC)
colRange   = input.color(#4fc3f7, "1D Min / 1D Max (lt blue)", group=grpC)
colDefault = input.color(#9598a1, "Other (grey)",              group=grpC)

// ------------------------- Level filters ----------------------
grpF      = "Level filters"
showKey   = input.bool(true, "Key levels (Call Resistance / Put Support / HVL)", group=grpF)
show0DTE  = input.bool(true, "0DTE levels (incl. Gamma Wall)", group=grpF)
showGEX   = input.bool(true, "GEX 1-10", group=grpF)
showBL    = input.bool(true, "BL 1-10", group=grpF)
showRange = input.bool(true, "1D Min / 1D Max", group=grpF)

// ------------------------------ Style -------------------------
grpS        = "Style"
lineWidth   = input.int(1, "Line width", minval=1, maxval=4, group=grpS)
lineStyleI  = input.string("Solid", "Line style", options=["Solid","Dashed","Dotted"], group=grpS)
extendI     = input.string("Both", "Line extend", options=["Both","Right"], group=grpS)
lookback    = input.int(250, "Line start (bars back, Right mode only)", minval=0, group=grpS)
labelStyleI = input.string("Left pointer", "Label style", options=["Left pointer","Right pointer","None"], group=grpS, tooltip="Left pointer = tag sits to the right of its line, matching the S&P reference.")
labelOff    = input.int(3, "Label offset (bars right of last candle)", minval=0, group=grpS, tooltip="How far into the empty space to the right of price the tags sit. Increase to move them further right; lower if they get clipped at the edge.")
lblBg       = input.color(color.new(#1e222d, 20), "Label background", group=grpS)
showVal     = input.bool(true, "Show value in label", group=grpS)
labelSizeI  = input.string("Small", "Label size", options=["Tiny","Small","Normal","Large"], group=grpS)

// ------------------------------ Maps --------------------------
lnStyle  = lineStyleI == "Dashed" ? line.style_dashed : lineStyleI == "Dotted" ? line.style_dotted : line.style_solid
ext      = extendI == "Right" ? extend.right : extend.both
lblSize  = labelSizeI == "Tiny" ? size.tiny : labelSizeI == "Normal" ? size.normal : labelSizeI == "Large" ? size.large : size.small
lblStyle = labelStyleI == "Right pointer" ? label.style_label_right : labelStyleI == "None" ? label.style_none : label.style_label_left

// ---------------------------- Helpers -------------------------
// Strip leading / trailing spaces (Pine has no str.trim).
f_trim(string _s) =>
    string r = _s
    bool go = true
    while go and str.length(r) > 0
        if str.substring(r, 0, 1) == " "
            r := str.substring(r, 1, str.length(r))
        else
            go := false
    go := true
    while go and str.length(r) > 0
        int L = str.length(r)
        if str.substring(r, L - 1, L) == " "
            r := str.substring(r, 0, L - 1)
        else
            go := false
    r

// Visibility filter.
f_show(string _lbl) =>
    bool is0 = str.contains(_lbl, "0DTE")
    bool isG = str.contains(_lbl, "GEX")
    bool isB = str.startswith(_lbl, "BL")
    bool isR = str.contains(_lbl, "1D Min") or str.contains(_lbl, "1D Max")
    bool res = is0 ? show0DTE : isG ? showGEX : isB ? showBL : isR ? showRange : showKey
    res

// Color by level type.
f_color(string _lbl) =>
    color c = colDefault
    if str.contains(_lbl, "Call Resistance")
        c := colCallRes
    else if str.contains(_lbl, "Put Support")
        c := colPutSup
    else if str.contains(_lbl, "Gamma Wall")
        c := colGamma
    else if str.contains(_lbl, "HVL")
        c := colHVL
    else if str.contains(_lbl, "1D Min") or str.contains(_lbl, "1D Max")
        c := colRange
    else if str.contains(_lbl, "GEX")
        c := colGEX
    else if str.startswith(_lbl, "BL")
        c := colBL
    c

// Parse one provider string and draw its levels.
f_process(string _raw, string _prefix, float _mult, bool _on, line[] _lns, label[] _lbls) =>
    if _on and str.length(_raw) > 0
        string s = str.replace_all(_raw, "\n", "")
        if str.contains(s, ":")
            int cp = str.pos(s, ":")
            s := str.substring(s, cp + 1, str.length(s))
        array<string> parts = str.split(s, ",")
        int n = array.size(parts)
        for i = 0 to n - 1 by 2
            if i + 1 < n
                string lbl = f_trim(array.get(parts, i))
                float val = str.tonumber(f_trim(array.get(parts, i + 1)))
                if not na(val) and str.length(lbl) > 0 and f_show(lbl)
                    float y   = val * _mult
                    color col = f_color(lbl)
                    int   x1  = bar_index - lookback < 0 ? 0 : bar_index - lookback
                    line ln = line.new(x1, y, bar_index, y, xloc=xloc.bar_index, extend=ext, color=col, width=lineWidth, style=lnStyle)
                    array.push(_lns, ln)
                    string txt = _prefix + " " + lbl + (showVal ? "  " + str.tostring(val, "#.##") : "")
                    label lb = label.new(bar_index + labelOff, y, txt, xloc=xloc.bar_index, style=lblStyle, color=lblBg, textcolor=col, size=lblSize)
                    array.push(_lbls, lb)

// ----------------------------- Draw ---------------------------
var line[]  allLines  = array.new<line>()
var label[] allLabels = array.new<label>()

if barstate.islast
    if array.size(allLines) > 0
        for i = 0 to array.size(allLines) - 1
            line.delete(array.get(allLines, i))
        array.clear(allLines)
    if array.size(allLabels) > 0
        for j = 0 to array.size(allLabels) - 1
            label.delete(array.get(allLabels, j))
        array.clear(allLabels)
    f_process(nqRaw,  nqPrefix,  nqMult,  nqEnable,  allLines, allLabels)
    f_process(qqqRaw, qqqPrefix, qqqMult, qqqEnable, allLines, allLabels)
    f_process(ndxRaw, ndxPrefix, ndxMult, ndxEnable, allLines, allLabels)
````
