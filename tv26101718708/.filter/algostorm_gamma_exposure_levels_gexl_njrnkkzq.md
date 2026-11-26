# AlgoStorm Gamma Exposure Levels (GEX-L)

- url: https://www.tradingview.com/script/njrnkKZq-AlgoStorm-Gamma-Exposure-Levels-GEX-L/
- type: indicator
- pine_id: PUB;69d5686c5f944e179a01fe212c577d62
- version: 6.0

## Description

[b]AlgoStorm Gamma Exposure Levels (GEX-L)[/b]

[i]A high-performance options market structure visualization tool designed to map total Gamma Exposure (GEX) profiles, Call Walls, Put Walls, and Gamma Flips directly onto your charts using custom-pasted external options chain inputs.[/i]

The AlgoStorm Gamma Exposure Levels (GEX-L) indicator is designed for active index and futures traders who track institutional options positioning to map structural support, resistance, and volatility inflection boundaries. It translates raw options chain metrics into actionable on-chart structural lines. By default, it supports mapping across SPX (cash index), ES/MES futures, and SPY ETF charts through localized scaling engines.

[quote][b]CRITICAL DATA INPUT REQUIREMENT — READ BEFORE LOADING[/b]
[b]This indicator DOES NOT come with an automatic or built-in options data feed.[/b] It operates as a blank visualization engine. To use it, you must copy a standardized 11-value comma-separated (CSV) data string from your external options data provider and paste it manually into the "GEX Data" field inside the indicator settings. The script parses this input to draw static levels for your trading session. It will remain empty until you provide data.[/quote]

[b]Technical Architecture: Anti-Overlap Stagger Pipeline[/b]
Traditional horizontal level indicators frequently suffer from visual clutter and illegible text labels when key options strikes or walls cluster tightly together. To bypass this platform constraint, this script utilizes an advanced multi-array sorting and layout engine:
[list]
[*] [b]True Price Isolation:[/b] Horizontal level lines are drawn strictly at their accurate options execution strikes, extending across your historical chart data.
[*] [b]Permutation Sorting Pass:[/b] The execution engine takes all active inputs and dynamically sorts them from lowest price to highest price on every new market tick.
[*] [b]Algorithmic Staggering Array:[/b] A secondary layout pass evaluates the vertical proximity of text tags in your chart margins. If adjacent tags fall below your user-defined point-separation threshold, the text labels are mathematically shifted away from each other along the Y-axis. This ensures that every price label remains completely readable without altering the true location of the price lines.
[/list]

[b]Features & Functionality[/b]
[list]
[*] [b]Multi-Tiered Level Layouts:[/b] Maps primary macro anchors (Primary Call Wall CW1, Primary Put Wall PW1, and Gamma Flip) using heavy line styling, alongside up to four distinct secondary levels (CW2–CW5 and PW2–PW5) for deeper context into out-of-the-money open interest.
[*] [b]Intelligent Symbol Scaling Engine:[/b] Built-in auto-scaling logic bridges index options structure with retail trading instruments. When toggled to SPY mode, the script automatically scales your pasted SPX options data by dividing values by 10 to perfectly align with your ETF chart grid.
[*] [b]Luminance-Sensing Contrast Badges:[/b] Features customizable label styles, including a modern solid badge layout. The script calculates the relative luminance of your chosen level colors to automatically determine whether to render black or white text on top of the background badge, preventing visual washout.
[*] [b]Opaque Visibility Overrides:[/b] Built with an explicit alpha channel stripping mechanism. Secondary levels can be configured with dimmed, low-opacity line styles to keep your main chart clean, while their text tags remain 100% opaque and sharp inside the margin.
[*] [b]Dynamic Trapped Zone Fills:[/b] Renders a background color cloud across the macro zone separating the primary Call Wall and Put Wall. The background dynamically transforms its color state depending on whether the current market price is safely insulated inside the wall boundaries or breaking out into high-volatility territory.
[/list]

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © AlgoStorm

//@version=6
indicator(title = "AlgoStorm Gamma Exposure Levels (GEX-L)", shorttitle = "GEX-L • [AlgoStorm]", overlay = true, max_lines_count = 30, max_labels_count = 40, max_boxes_count = 10)

// The CW/PW background zone box starts 500 bars back, and drawings convert
// bar_index x-coordinates through the `time` series (Pine error RE10143), whose
// automatic buffer can be 400 bars. Size it for the zone.
max_bars_back(time, 500)

// ── GEX Data Input ────────────────────────────────────────────────────────────

const string GRP_DATA      = "GEX Data Setup"
const string GRP_DISPLAY   = "Display Toggles & Layout"
const string GRP_MODE      = "Symbol Scaling Mode"
const string GRP_STYLE_CW  = "Call Wall Styling"
const string GRP_STYLE_PW  = "Put Wall Styling"
const string GRP_STYLE_GF  = "Gamma Flip Styling"

var string TT_DATA = """Paste the CSV line from your chosen GEX data source.
                        Format: cw1-cw10,pw1-pw10,flip  (21 values total)
                        Example: 5600,5575,5550,5500,5480,5460,5440,5420,5400,5380,5300,5325,5350,5375,5250,5200,5150,5100,5050,5000,5475
                        All 21 values required. Use 0 for any level you want to hide.
                        Lines from the NQ dashboard end with a 22nd value, NDX: set Symbol Mode to NDX / NQ for them."""

var string TT_MODE = """SPX / ES: SPX strikes, shifted by the Futures Basis Adjustment below (zero on an SPX chart).
                        SPY: scales SPX levels to SPY by the measured SPY ÷ SPX ratio (about 0.0997) when the Futures Basis Adjustment is Auto, else divides by 10.
                        NDX / NQ: NDX strikes from the NQ dashboard, shifted by the NQ − NDX basis (zero on an NDX chart). The basis is measured against Basis Reference (NDX)."""

var string TT_BASIS = """ES and MES trade above the SPX index by the carry basis (tens of points, shrinking to zero at expiry), so SPX strikes plotted as-is sit too low on a futures chart.
                        Auto: measures chart close minus SPX close on the latest confirmed bar where both traded (cash session) and shifts every level by it. Zero on an SPX chart. Works on any timeframe of one minute or more: where chart bars do not open with SPX bars (1 hour, daily…), it pairs 15-minute (or 1-minute) bars inside each chart bar.
                        Manual: shifts by the points entered below. Off: plots the SPX strikes unchanged.
                        In SPY mode Auto measures the SPY ÷ SPX ratio instead (dividends and fees keep it a little under 0.1); Manual and Off divide by 10.
                        In NDX / NQ mode the same applies to NQ and MNQ against NDX: Auto measures chart close minus NDX close."""

string gexData    = input.string(defval = "", title = "GEX Data (Paste CSV)", tooltip = TT_DATA, group = GRP_DATA)
string symbolMode = input.string(defval = "SPX / ES", title = "Symbol Mode", options = ["SPX / ES", "SPY (auto ÷10)", "NDX / NQ"], group = GRP_MODE, tooltip = TT_MODE)

// ── Display Control Options (Upgraded with Custom Badge Modes) ────────────────

bool   showLabels = input.bool(defval = true, title = "Show Level Labels", group = GRP_DISPLAY)
string lblBgMode  = input.string(defval = "POI Tinted Style", title = "Label Background Mode", options = ["Solid Color Badge", "POI Tinted Style", "Fully Transparent"], group = GRP_DISPLAY, tooltip = "Choose between a modern solid badge look or your classic POI script tint.")
bool   showZone   = input.bool(defval = false, title = "Show CW/PW Background Zone", group = GRP_DISPLAY)
string lblSize    = input.string(defval = "small", title = "Label Font Size", options = ["tiny", "small", "normal"], group = GRP_DISPLAY)
int    lblOff     = input.int(defval = 8, title = "Label Offset (bars)", minval = 1, maxval = 50, group = GRP_DISPLAY, tooltip = "Shifts labels rightward into the chart margin.")
float  minSep     = input.float(defval = 3.0, title = "Min Label Separation (pts)", minval = 0.1, step = 0.5, group = GRP_DISPLAY, tooltip = "Minimum vertical price distance enforced between adjacent text labels.")

// ── User-Adjustable Styling Engine ────────────────────────────────────────────

// Call Wall Adjustments
color  c_call       = input.color(defval = #c7e36c, title = "Primary Call Wall (CW1)", group = GRP_STYLE_CW)
color  c_call_dim   = input.color(defval = color.new(#c7e36c, 20), title = "Secondary Call Walls (CW2-10)", group = GRP_STYLE_CW)
int    w_call1      = input.int(defval = 2, title = "CW1 Line Thickness", minval = 1, maxval = 5, group = GRP_STYLE_CW)
int    w_call_dim   = input.int(defval = 1, title = "CW2-10 Line Thickness", minval = 1, maxval = 5, group = GRP_STYLE_CW)
string s_call1      = input.string(defval = "Solid", title = "CW1 Line Pattern", options = ["Solid", "Dashed", "Dotted"], group = GRP_STYLE_CW)
string s_call_dim   = input.string(defval = "Dashed", title = "CW2-10 Line Pattern", options = ["Solid", "Dashed", "Dotted"], group = GRP_STYLE_CW)

// Put Wall Adjustments
color  c_put        = input.color(defval = #ff8068, title = "Primary Put Wall (PW1)", group = GRP_STYLE_PW)
color  c_put_dim    = input.color(defval = color.new(#ff8068, 20), title = "Secondary Put Walls (PW2-10)", group = GRP_STYLE_PW)
int    w_put1       = input.int(defval = 2, title = "PW1 Line Thickness", minval = 1, maxval = 5, group = GRP_STYLE_PW)
int    w_put_dim    = input.int(defval = 1, title = "PW2-10 Line Thickness", minval = 1, maxval = 5, group = GRP_STYLE_PW)
string s_put1       = input.string(defval = "Solid", title = "PW1 Line Pattern", options = ["Solid", "Dashed", "Dotted"], group = GRP_STYLE_PW)
string s_put_dim    = input.string(defval = "Dashed", title = "PW2-10 Line Pattern", options = ["Solid", "Dashed", "Dotted"], group = GRP_STYLE_PW)

// Gamma Flip Adjustments
color  c_flip       = input.color(defval = color.new(#f3f5f0, 0), title = "Gamma Flip Level Color", group = GRP_STYLE_GF)
int    w_flip       = input.int(defval = 1, title = "Gamma Flip Line Thickness", minval = 1, maxval = 5, group = GRP_STYLE_GF)
string s_flip       = input.string(defval = "Dashed", title = "Gamma Flip Line Pattern", options = ["Solid", "Dashed", "Dotted"], group = GRP_STYLE_GF)

// Zone Dynamic Background Adjustments
color  c_zone_in    = input.color(defval = color.new(color.green, 95), title = "Inside Zone BG Fill", group = GRP_DISPLAY)
color  c_zone_out   = input.color(defval = color.new(color.red, 95), title = "Outside Zone BG Fill", group = GRP_DISPLAY)

// Futures basis. Declared last on purpose: TradingView keys saved inputs by
// position, so new inputs are appended after every existing one.
string basisMode    = input.string(defval = "Auto (chart − SPX)", title = "Futures Basis Adjustment", options = ["Auto (chart − SPX)", "Manual", "Off"], group = GRP_MODE, tooltip = TT_BASIS)
string basisRef     = input.symbol(defval = "SP:SPX", title = "Basis Reference (SPX)", group = GRP_MODE)
float  basisManual  = input.float(defval = 0.0, title = "Manual Basis (pts)", step = 0.25, group = GRP_MODE)
string basisRefNDX  = input.symbol(defval = "NASDAQ:NDX", title = "Basis Reference (NDX)", group = GRP_MODE)

// NDX / NQ mode reads NDX strikes and measures the basis against NDX instead of SPX.
bool   isNDX   = symbolMode == "NDX / NQ"
string refSym  = isNDX ? basisRefNDX : basisRef
string idxName = isNDX ? "NDX" : "SPX"

// ── Futures Basis ─────────────────────────────────────────────────────────────

// SPX bars exist only in the cash session; gaps_on returns na elsewhere, so the
// basis is measured on bars where both instruments traded, never against a
// stale SPX close overnight. Confirmed bars only: a delayed SPX feed has no
// matching bar yet on the realtime one.
// SPX bars start at 09:30 ET. Only minute charts whose length divides 30
// (1, 2, 3, 5, 6, 10, 15, 30) open SPX and futures bars at the same times;
// on any other a close-to-close difference would mix two moments.
bool basisTF = timeframe.isminutes and timeframe.multiplier <= 30 and 30 % timeframe.multiplier == 0
float refClose = request.security(refSym, timeframe.period, close, gaps = barmerge.gaps_on)
var float autoBasis = na
var float autoRatio = na
if basisTF and barstate.isconfirmed and not na(refClose) and refClose > 0
    autoBasis := close - refClose
    autoRatio := close / refClose

// On every other timeframe above one minute, pair SPX and chart closes from the
// same lower-timeframe bars inside each chart bar, matched on bar time.
bool   pairTF  = not basisTF and timeframe.in_seconds() > 60
string pairRes = timeframe.in_seconds() >= 900 ? "15" : "1"
if pairTF and barstate.isconfirmed
    [refT, refC] = request.security_lower_tf(refSym, pairRes, [time, close])
    [chT, chC]   = request.security_lower_tf(syminfo.tickerid, pairRes, [time, close])
    int nRef = array.size(refT)
    if nRef > 0 and array.size(chT) > 0
        for i = nRef - 1 to 0
            int   j  = array.indexof(chT, array.get(refT, i))
            float rc = array.get(refC, i)
            if j >= 0 and rc > 0
                float cc = array.get(chC, j)
                autoBasis := cc - rc
                autoRatio := cc / rc
                break

// Outside these bounds it is the wrong chart for the mode (SPY or NQ in SPX / ES
// mode, ES in SPY mode, ES in NDX / NQ mode), not carry or fees.
bool basisSane = not na(autoBasis) and math.abs(autoBasis) < close * 0.05
bool ratioSane = not na(autoRatio) and autoRatio > 0.09 and autoRatio < 0.11
bool isSPY     = symbolMode == "SPY (auto ÷10)"
float levelShift = isSPY ? 0.0 : basisMode == "Manual" ? basisManual : basisMode == "Off" ? 0.0 : basisSane ? autoBasis : 0.0
float spyFactor  = basisMode == "Auto (chart − SPX)" and ratioSane ? autoRatio : 0.1

// ── Persistent Drawing Containers ─────────────────────────────────────────────

var line[]  gexLines  = array.new_line()
var label[] gexLabels = array.new_label()
var box[]   gexBoxes  = array.new_box()

// ── Helper Conversions ────────────────────────────────────────────────────────

scale(v) =>
    isSPY and v > 100 ? v * spyFactor : v > 0 ? v + levelShift : v

lblSz = lblSize == "tiny" ? size.tiny : lblSize == "normal" ? size.normal : size.small

getStyle(styleStr) =>
    switch styleStr
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

// ── Level Collection Helper Function ──────────────────────────────────────────

f_collect(array<float> ps, array<string> ts, array<color> cs, array<int> ws, array<string> ss, float price, string txt, color clr, int wid, string sty) =>
    if price > 0
        array.push(ps, price)
        array.push(ts, txt)
        array.push(cs, clr)
        array.push(ws, wid)
        array.push(ss, sty)

// ── Clear Canvas on New Ticks ─────────────────────────────────────────────────

if barstate.islast
    for ln in gexLines
        line.delete(ln)
    for lb in gexLabels
        label.delete(lb)
    for bx in gexBoxes
        box.delete(bx)
    array.clear(gexLines)
    array.clear(gexLabels)
    array.clear(gexBoxes)

// ── Parse CSV (Execution Optimized for Last Bar Only) ─────────────────────────

var float callWall1  = 0.0, var float callWall2  = 0.0, var float callWall3  = 0.0
var float callWall4  = 0.0, var float callWall5  = 0.0, var float callWall6  = 0.0
var float callWall7  = 0.0, var float callWall8  = 0.0, var float callWall9  = 0.0
var float callWall10 = 0.0
var float putWall1   = 0.0, var float putWall2   = 0.0, var float putWall3   = 0.0
var float putWall4   = 0.0, var float putWall5   = 0.0, var float putWall6   = 0.0
var float putWall7   = 0.0, var float putWall8   = 0.0, var float putWall9   = 0.0
var float putWall10  = 0.0
var float gammaFlip  = 0.0
// Index named by an optional 22nd value; lines without one are SPX.
var string dataTag   = "SPX"

_level(parts, idx) =>
    n = array.size(parts)
    raw = idx < n ? str.tonumber(array.get(parts, idx)) : 0.0
    na(raw) ? 0.0 : raw

if barstate.islast and gexData != ""
    string[] parts = str.split(gexData, ",")
    callWall1  := _level(parts,  0)
    callWall2  := _level(parts,  1)
    callWall3  := _level(parts,  2)
    callWall4  := _level(parts,  3)
    callWall5  := _level(parts,  4)
    callWall6  := _level(parts,  5)
    callWall7  := _level(parts,  6)
    callWall8  := _level(parts,  7)
    callWall9  := _level(parts,  8)
    callWall10 := _level(parts,  9)
    putWall1   := _level(parts, 10)
    putWall2   := _level(parts, 11)
    putWall3   := _level(parts, 12)
    putWall4   := _level(parts, 13)
    putWall5   := _level(parts, 14)
    putWall6   := _level(parts, 15)
    putWall7   := _level(parts, 16)
    putWall8   := _level(parts, 17)
    putWall9   := _level(parts, 18)
    putWall10  := _level(parts, 19)
    gammaFlip  := _level(parts, 20)
    dataTag    := array.size(parts) > 21 ? str.upper(str.trim(array.get(parts, 21))) : "SPX"

// ── Processing & Render Engine Pipeline ───────────────────────────────────────

// NDX levels in an SPX mode, or SPX levels in NDX / NQ mode, would plot thousands
// of points from price: warn and draw nothing.
bool tagMismatch = gexData != "" and (isNDX ? dataTag != "NDX" : dataTag == "NDX")

if barstate.islast and tagMismatch
    string mmTxt = "⚠ Pasted levels are " + dataTag + " but Symbol Mode is " + symbolMode + ". Switch to " + (dataTag == "NDX" ? "NDX / NQ" : "SPX / ES or SPY") + "; levels hidden"
    label mmLbl = label.new(bar_index, high, text = mmTxt, color = color.new(color.yellow, 75), textcolor = color.yellow, style = label.style_label_down, size = size.tiny)
    array.push(gexLabels, mmLbl)

if barstate.islast and not tagMismatch
    if symbolMode == "SPY (auto ÷10)"
        string spyTxt = spyFactor != 0.1 ? "SPY mode: SPX levels × " + str.tostring(spyFactor, "0.00000") + " (measured SPY ÷ SPX)" : "⚠ SPY mode: SPX levels ÷10 (ratio not measured)"
        label spyWarn = label.new(bar_index, high, text = spyTxt, color = color.new(color.yellow, 75), textcolor = color.yellow, style = label.style_label_down, size = size.tiny)
        array.push(gexLabels, spyWarn)
    else if gexData != "" and basisMode != "Off"
        string shiftTxt = (levelShift >= 0 ? "+" : "") + str.tostring(levelShift, "#.##")
        string basisTxt = ""
        if basisMode == "Manual"
            basisTxt := levelShift != 0 ? "Levels shifted " + shiftTxt + " pts (manual basis)" : ""
        else if not (basisTF or pairTF)
            basisTxt := "⚠ Auto basis needs a chart of one minute or more; use Manual here. Levels unshifted"
        else if not basisSane
            basisTxt := isNDX ? "⚠ Basis not measured: no matching NDX bar, or chart is not NDX/NQ. Levels unshifted" : "⚠ Basis not measured: no matching SPX bar, or chart is not SPX/ES. Levels unshifted"
        else if math.abs(levelShift) >= 0.01
            basisTxt := "Levels shifted " + shiftTxt + " pts (chart − " + idxName + " basis)"
        if basisTxt != ""
            label basisLbl = label.new(bar_index, high, text = basisTxt, color = color.new(color.gray, 80), textcolor = color.gray, style = label.style_label_down, size = size.tiny)
            array.push(gexLabels, basisLbl)

    array<float>  lvlP = array.new<float>()
    array<string> lvlT = array.new<string>()
    array<color>  lvlC = array.new<color>()
    array<int>    lvlW = array.new<int>()
    array<string> lvlS = array.new<string>()

    f_collect(lvlP, lvlT, lvlC, lvlW, lvlS, scale(callWall1),  "CW1",    c_call,     w_call1,    s_call1)
    f_collect(lvlP, lvlT, lvlC, lvlW, lvlS, scale(callWall2),  "CW2",    c_call_dim, w_call_dim, s_call_dim)
    f_collect(lvlP, lvlT, lvlC, lvlW, lvlS, scale(callWall3),  "CW3",    c_call_dim, w_call_dim, s_call_dim)
    f_collect(lvlP, lvlT, lvlC, lvlW, lvlS, scale(callWall4),  "CW4",    c_call_dim, w_call_dim, s_call_dim)
    f_collect(lvlP, lvlT, lvlC, lvlW, lvlS, scale(callWall5),  "CW5",    c_call_dim, w_call_dim, s_call_dim)
    f_collect(lvlP, lvlT, lvlC, lvlW, lvlS, scale(callWall6),  "CW6",    c_call_dim, w_call_dim, s_call_dim)
    f_collect(lvlP, lvlT, lvlC, lvlW, lvlS, scale(callWall7),  "CW7",    c_call_dim, w_call_dim, s_call_dim)
    f_collect(lvlP, lvlT, lvlC, lvlW, lvlS, scale(callWall8),  "CW8",    c_call_dim, w_call_dim, s_call_dim)
    f_collect(lvlP, lvlT, lvlC, lvlW, lvlS, scale(callWall9),  "CW9",    c_call_dim, w_call_dim, s_call_dim)
    f_collect(lvlP, lvlT, lvlC, lvlW, lvlS, scale(callWall10), "CW10",   c_call_dim, w_call_dim, s_call_dim)

    f_collect(lvlP, lvlT, lvlC, lvlW, lvlS, scale(putWall1),   "PW1",    c_put,     w_put1,    s_put1)
    f_collect(lvlP, lvlT, lvlC, lvlW, lvlS, scale(putWall2),   "PW2",    c_put_dim, w_put_dim, s_put_dim)
    f_collect(lvlP, lvlT, lvlC, lvlW, lvlS, scale(putWall3),   "PW3",    c_put_dim, w_put_dim, s_put_dim)
    f_collect(lvlP, lvlT, lvlC, lvlW, lvlS, scale(putWall4),   "PW4",    c_put_dim, w_put_dim, s_put_dim)
    f_collect(lvlP, lvlT, lvlC, lvlW, lvlS, scale(putWall5),   "PW5",    c_put_dim, w_put_dim, s_put_dim)
    f_collect(lvlP, lvlT, lvlC, lvlW, lvlS, scale(putWall6),   "PW6",    c_put_dim, w_put_dim, s_put_dim)
    f_collect(lvlP, lvlT, lvlC, lvlW, lvlS, scale(putWall7),   "PW7",    c_put_dim, w_put_dim, s_put_dim)
    f_collect(lvlP, lvlT, lvlC, lvlW, lvlS, scale(putWall8),   "PW8",    c_put_dim, w_put_dim, s_put_dim)
    f_collect(lvlP, lvlT, lvlC, lvlW, lvlS, scale(putWall9),   "PW9",    c_put_dim, w_put_dim, s_put_dim)
    f_collect(lvlP, lvlT, lvlC, lvlW, lvlS, scale(putWall10),  "PW10",   c_put_dim, w_put_dim, s_put_dim)

    f_collect(lvlP, lvlT, lvlC, lvlW, lvlS, scale(gammaFlip),  "γ FLIP", c_flip,    w_flip,    s_flip)

    int nLvl = array.size(lvlP)

    if nLvl > 0
        // Apply Sort Ascending Permutation Matrix
        array<int>    idx    = array.sort_indices(lvlP, order.ascending)
        array<float>  sPrice = array.new<float>()
        array<string> sTxt   = array.new<string>()
        array<color>  sClr   = array.new<color>()
        array<int>    sWid   = array.new<int>()
        array<string> sSty   = array.new<string>()

        for i = 0 to nLvl - 1
            int si = array.get(idx, i)
            array.push(sPrice, array.get(lvlP, si))
            array.push(sTxt,   array.get(lvlT, si))
            array.push(sClr,   array.get(lvlC, si))
            array.push(sWid,   array.get(lvlW, si))
            array.push(sSty,   array.get(lvlS, si))

        // Label Stagger Matrix Calculations
        array<float> lblY = array.copy(sPrice)
        if nLvl > 1
            for i = 1 to nLvl - 1
                float prevY = array.get(lblY, i - 1)
                float curY  = array.get(lblY, i)
                if curY - prevY < minSep
                    array.set(lblY, i, prevY + minSep)

        // Unified Drawing Execution Pass
        for i = 0 to nLvl - 1
            float  p = array.get(sPrice, i)
            float  y = array.get(lblY,   i)
            string t = array.get(sTxt,   i)
            color  c = array.get(sClr,   i)
            int    w = array.get(sWid,   i)
            string s = array.get(sSty,   i)

            // Strip incoming alpha transparencies out completely for raw label color structures
            color c_solid = color.rgb(color.r(c), color.g(c), color.b(c))

            // Initialize structural container values
            color finalBgColor  = na
            color finalTxtColor = c_solid

            // Process dynamic user presentation modes
            if lblBgMode == "Solid Color Badge"
                finalBgColor  := c_solid
                // Mathematically calculate luminance to auto-contrast text against bright or dim background colors
                float luminance = (color.r(c_solid) * 0.299 + color.g(c_solid) * 0.587 + color.b(c_solid) * 0.114) / 255.0
                finalTxtColor := luminance > 0.6 ? color.black : color.white
            else if lblBgMode == "POI Tinted Style"
                finalBgColor  := color.new(c_solid, 85)
                finalTxtColor := c_solid
            else // Fully Transparent Option
                finalBgColor  := color.new(color.white, 100)
                finalTxtColor := c_solid

            // True Price Line
            line ln = line.new(
              x1     = bar_index,
              y1     = p,
              x2     = bar_index + lblOff,
              y2     = p,
              color  = c,
              width  = w,
              style  = getStyle(s),
              extend = extend.left
              )
            array.push(gexLines, ln)

            // Clear Staggered Y Label Badge Container
            if showLabels
                label lb = label.new(
                  x         = bar_index + lblOff,
                  y         = y,
                  text      = t + "  " + str.tostring(p, "#.##"),
                  color     = finalBgColor,
                  textcolor = finalTxtColor,
                  style     = label.style_label_left,
                  size      = lblSz
                  )
                array.push(gexLabels, lb)

    // Background Dynamic Fill Zone
    float scaledCW1 = scale(callWall1)
    float scaledPW1 = scale(putWall1)
    if (showZone and (scaledCW1 > 0) and (scaledPW1 > 0))
        bool insideZone = (close >= scaledPW1) and (close <= scaledCW1)
        zoneColor = insideZone ? c_zone_in : c_zone_out
        int startBar = math.max(0, bar_index - 500)
        box b = box.new(startBar, scaledCW1, bar_index + lblOff, scaledPW1, bgcolor = zoneColor, border_color = color.new(color.white, 100))
        array.push(gexBoxes, b)
````
