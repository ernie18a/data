# Stock & Market Health Checklist

- url: https://www.tradingview.com/script/OTKIyaEq-Stock-Market-Health-Checklist/
- type: indicator
- pine_id: PUB;109979fdd5d7404b935fd0ecfc367a37
- version: 1.0

## Description

Market Health Checklist

A compact, fully-configurable dashboard that reads market and single-stock trend health at a glance. Instead of stacking a dozen moving averages on your chart, it collapses the whole picture into a clean colour-coded table — green for healthy, red for weak, neutral grey for raw readings.

It's built around two independent sections:

■ MARKET — calculated from a fixed Signal Ticker (default QQQ) regardless of what chart you're on. This is your top-down regime read: is the broad tape healthy right now?

■ STOCK — calculated from whatever symbol you're currently viewing. Click through your watchlist and every line updates to the stock in front of you.

What it tracks

MARKET section:

Up to 4 MA crossover signals (e.g. 5/10, 10/20) — green when fast > slow
Up to 4 MA slope signals — green when the MA is rising
Price vs MA checks
VIX vs threshold — green below (calm), red above (fear)
T2108 / breadth (default symbol MMFI) — red overbought, green washed-out
RSI with overbought/oversold colouring
STOCK section:

Price above 10/20/50/200 MA
Slope (up/down) of each of those MAs
RSI of the current stock
Current daily $ Volume, auto-formatted (e.g. $1.24B / $45.30M)
ATR in dollars (default 3× daily ATR) — handy for stop and target sizing
Customisation

Every moving-average row has its own EMA or SMA selector and its own length
Each signal can be toggled on or off independently
Pin VIX, T2108 and the STOCK stats to Daily values so they read identically on any chart and any timeframe (recommended)
Full appearance control: table position (9 anchors), text size, vertical or horizontal layout, section headers on/off, live values on/off, and individual colours for green / red / neutral / text / headers / border
Notes

For VIX, use TVC:VIX — it resolves real-time via request.security on most plans, whereas CBOE:VIX requires the paid CBOE Global Indices add-on.
Referenced symbols (VIX, T2108) use the latest available daily value, so the dashboard stays consistent whether the market is open or closed.
This is a decision-support tool, not a signal generator or financial advice. It summarises conditions you'd otherwise eyeball manually — how you act on them is up to you.

## Source Code

````pine
//@version=6
// =============================================================================
//  Market Health Checklist  —  colored table of regime signals
//  Two sections:
//    MARKET — computed from the Signal Ticker (default QQQ)
//    STOCK  — computed from the chart symbol you are currently viewing
//  Every moving-average signal has its own EMA / SMA selector.
// =============================================================================
indicator("Market Health Checklist", overlay = true)

// -----------------------------------------------------------------------------
//  GROUP 0 — Source
// -----------------------------------------------------------------------------
g_src   = "Source"
srcSym  = input.symbol("QQQ", "Signal Ticker (MARKET section)", group = g_src,
     tooltip = "MARKET-section MAs / RSI are calculated on THIS symbol, regardless of the chart you have open.")
vixSym  = input.symbol("TVC:VIX", "VIX Symbol", group = g_src,
     tooltip = "TVC:VIX is real-time on most plans via request.security. CBOE:VIX needs the paid CBOE Global Indices add-on.")
useChartTF = input.bool(true, "Use chart timeframe", group = g_src,
     tooltip = "On = MARKET signals follow the chart's timeframe. Off = lock to the timeframe below.")
lockTF  = input.timeframe("D", "Locked timeframe", group = g_src)
tf      = useChartTF ? timeframe.period : lockTF
extDaily = input.bool(true, "Pin VIX / T2108 to Daily", group = g_src,
     tooltip = "ON = VIX and T2108 always read their DAILY value, identical on every chart.")
extTF   = extDaily ? "D" : tf

MA_OPT = "EMA"  // default for every MA-type dropdown

// -----------------------------------------------------------------------------
//  GROUP 1 — MARKET: MA crossover signals (up to 4)
//  GREEN when Fast MA > Slow MA, RED when below. Each row: own EMA/SMA type.
// -----------------------------------------------------------------------------
g_x = "MARKET · MA Crossovers"
x1On  = input.bool(true,  "①", group = g_x, inline = "x1")
x1Fast= input.int(5,   "Fast", group = g_x, inline = "x1", minval = 1)
x1Slow= input.int(10,  "Slow", group = g_x, inline = "x1", minval = 1)
x1Ty  = input.string(MA_OPT, "", group = g_x, inline = "x1", options = ["EMA","SMA"])
x2On  = input.bool(true,  "②", group = g_x, inline = "x2")
x2Fast= input.int(10,  "Fast", group = g_x, inline = "x2", minval = 1)
x2Slow= input.int(20,  "Slow", group = g_x, inline = "x2", minval = 1)
x2Ty  = input.string(MA_OPT, "", group = g_x, inline = "x2", options = ["EMA","SMA"])
x3On  = input.bool(false, "③", group = g_x, inline = "x3")
x3Fast= input.int(20,  "Fast", group = g_x, inline = "x3", minval = 1)
x3Slow= input.int(50,  "Slow", group = g_x, inline = "x3", minval = 1)
x3Ty  = input.string(MA_OPT, "", group = g_x, inline = "x3", options = ["EMA","SMA"])
x4On  = input.bool(false, "④", group = g_x, inline = "x4")
x4Fast= input.int(50,  "Fast", group = g_x, inline = "x4", minval = 1)
x4Slow= input.int(200, "Slow", group = g_x, inline = "x4", minval = 1)
x4Ty  = input.string(MA_OPT, "", group = g_x, inline = "x4", options = ["EMA","SMA"])

// -----------------------------------------------------------------------------
//  GROUP 2 — MARKET: MA slope signals
//  GREEN when MA is higher than `slopeLB` bars ago (rising), RED when falling.
// -----------------------------------------------------------------------------
g_s = "MARKET · MA Slope"
s1On  = input.bool(true,  "Slope 1", group = g_s, inline = "s1")
s1Len = input.int(10,  "Len", group = g_s, inline = "s1", minval = 1)
s1Ty  = input.string(MA_OPT, "", group = g_s, inline = "s1", options = ["EMA","SMA"])
s2On  = input.bool(true,  "Slope 2", group = g_s, inline = "s2")
s2Len = input.int(20,  "Len", group = g_s, inline = "s2", minval = 1)
s2Ty  = input.string(MA_OPT, "", group = g_s, inline = "s2", options = ["EMA","SMA"])
s3On  = input.bool(false, "Slope 3", group = g_s, inline = "s3")
s3Len = input.int(50,  "Len", group = g_s, inline = "s3", minval = 1)
s3Ty  = input.string(MA_OPT, "", group = g_s, inline = "s3", options = ["EMA","SMA"])
s4On  = input.bool(false, "Slope 4", group = g_s, inline = "s4")
s4Len = input.int(200, "Len", group = g_s, inline = "s4", minval = 1)
s4Ty  = input.string(MA_OPT, "", group = g_s, inline = "s4", options = ["EMA","SMA"])
slopeLB = input.int(1, "Slope lookback (bars)", group = g_s, minval = 1,
     tooltip = "Compare the MA to its value this many bars ago.")

// -----------------------------------------------------------------------------
//  GROUP 2b — MARKET: Price vs MA
//  GREEN when price (close) is ABOVE the MA, RED when below.
// -----------------------------------------------------------------------------
g_p = "MARKET · Price vs MA"
p1On  = input.bool(true, "Price > MA 1", group = g_p, inline = "p1")
p1Len = input.int(10, "Len", group = g_p, inline = "p1", minval = 1)
p1Ty  = input.string(MA_OPT, "", group = g_p, inline = "p1", options = ["EMA","SMA"])
p2On  = input.bool(true, "Price > MA 2", group = g_p, inline = "p2")
p2Len = input.int(20, "Len", group = g_p, inline = "p2", minval = 1)
p2Ty  = input.string(MA_OPT, "", group = g_p, inline = "p2", options = ["EMA","SMA"])

// -----------------------------------------------------------------------------
//  GROUP 3 — MARKET: VIX  (GREEN below threshold = calm, RED above = fear)
// -----------------------------------------------------------------------------
g_v = "MARKET · VIX"
vixOn  = input.bool(true, "Enable VIX", group = g_v)
vixThr = input.float(20.0, "VIX threshold", group = g_v, step = 0.5,
     tooltip = "Below threshold = GREEN (calm), above = RED (fear).")

// -----------------------------------------------------------------------------
//  GROUP 3b — MARKET: T2108  (breadth, ticker MMFI by default)
// -----------------------------------------------------------------------------
g_t = "MARKET · T2108"
t2108On  = input.bool(true, "Enable T2108", group = g_t)
t2108Sym = input.symbol("MMFI", "T2108 Symbol", group = g_t)
t2108OB  = input.float(70, "Overbought (RED)",  group = g_t, step = 1)
t2108OS  = input.float(30, "Oversold (GREEN)",  group = g_t, step = 1)

// -----------------------------------------------------------------------------
//  GROUP 4 — MARKET: RSI
// -----------------------------------------------------------------------------
g_r = "MARKET · RSI"
rsiOn  = input.bool(true, "Enable RSI", group = g_r)
rsiLen = input.int(14, "RSI length",   group = g_r, minval = 1)
rsiOB  = input.float(70, "Overbought (RED)",  group = g_r, step = 1)
rsiOS  = input.float(30, "Oversold (GREEN)",  group = g_r, step = 1)

// -----------------------------------------------------------------------------
//  GROUP 5 — STOCK: the chart symbol you are currently viewing
//  Price vs MA, MA slope, RSI, $ Volume, ATR — all on syminfo.tickerid.
//  Each MA row has its own EMA/SMA type.
// -----------------------------------------------------------------------------
g_cs = "STOCK (current chart symbol)"
cs1On = input.bool(true, "MA 1", group = g_cs, inline = "m1")
cs1Len= input.int(10,  "Len", group = g_cs, inline = "m1", minval = 1)
cs1Ty = input.string(MA_OPT, "", group = g_cs, inline = "m1", options = ["EMA","SMA"])
cs2On = input.bool(true, "MA 2", group = g_cs, inline = "m2")
cs2Len= input.int(20,  "Len", group = g_cs, inline = "m2", minval = 1)
cs2Ty = input.string(MA_OPT, "", group = g_cs, inline = "m2", options = ["EMA","SMA"])
cs3On = input.bool(true, "MA 3", group = g_cs, inline = "m3")
cs3Len= input.int(50,  "Len", group = g_cs, inline = "m3", minval = 1)
cs3Ty = input.string(MA_OPT, "", group = g_cs, inline = "m3", options = ["EMA","SMA"])
cs4On = input.bool(true, "MA 4", group = g_cs, inline = "m4")
cs4Len= input.int(200, "Len", group = g_cs, inline = "m4", minval = 1)
cs4Ty = input.string(MA_OPT, "", group = g_cs, inline = "m4", options = ["EMA","SMA"])
csPriceVsMA = input.bool(true, "Show 'Price > MA' rows", group = g_cs)
csSlopeOn   = input.bool(true, "Show 'MA Slope' rows",   group = g_cs)
csSlopeLB   = input.int(3, "Slope lookback (bars)", group = g_cs, minval = 1)
csRsiOn  = input.bool(true, "Show RSI", group = g_cs, inline = "csr")
csRsiLen = input.int(14, "Len", group = g_cs, inline = "csr", minval = 1)
csDvOn   = input.bool(true, "Show $ Volume", group = g_cs)
atrOn    = input.bool(true, "Show ATR ($)", group = g_cs, inline = "atr")
atrLen   = input.int(14, "Len", group = g_cs, inline = "atr", minval = 1)
atrMult  = input.float(3.0, "×", group = g_cs, inline = "atr", step = 0.5,
     tooltip = "Row shows Multiplier × daily ATR of the chart symbol, in dollars.")
csPinDaily = input.bool(true, "Pin STOCK stats to Daily", group = g_cs,
     tooltip = "ON = MA / RSI / $Vol / ATR use DAILY values regardless of chart timeframe (best for swing reads).")
csTF = csPinDaily ? "D" : tf

// -----------------------------------------------------------------------------
//  GROUP 6 — Appearance
// -----------------------------------------------------------------------------
g_a = "Appearance"
posInput = input.string("Top Right", "Table position", group = g_a,
     options = ["Top Right","Top Left","Top Center","Middle Right","Middle Left","Middle Center","Bottom Right","Bottom Left","Bottom Center"])
szInput  = input.string("Normal", "Text size", group = g_a,
     options = ["Tiny","Small","Normal","Large","Huge","Auto"])
layout   = input.string("Vertical", "Table layout", group = g_a,
     options = ["Vertical","Horizontal"],
     tooltip = "Vertical = one row per signal. Horizontal = one column per signal.")
showLabels  = input.bool(true, "Show signal labels", group = g_a)
showHeaders = input.bool(true, "Show section headers", group = g_a,
     tooltip = "Adds MARKET / STOCK divider rows with the symbol name.")
showVals    = input.bool(true, "Show live values in labels", group = g_a,
     tooltip = "Append the live number (RSI 48.3, VIX 21.5, etc.). Off = name only.")

colGreen  = input.color(color.new(color.green, 0), "GREEN color", group = g_a)
colRed    = input.color(color.new(color.red,   0), "RED color",   group = g_a)
colNeut   = input.color(color.new(color.gray,  0), "Neutral color", group = g_a)
colText   = input.color(color.white, "Text color", group = g_a)
colHdrBg  = input.color(color.new(color.blue, 35), "Header background", group = g_a)
colHdrTxt = input.color(color.white, "Header text", group = g_a)
frameCol  = input.color(color.new(color.gray, 40), "Frame/border color", group = g_a)

posVal = switch posInput
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right"  => position.bottom_right
    => position.top_right

szVal = switch szInput
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge
    "Auto"   => size.auto
    => size.normal

// -----------------------------------------------------------------------------
//  HELPERS
// -----------------------------------------------------------------------------
// Moving average of a given type ("EMA"/"SMA")
f_ma(string ty, float src, int len) => ty == "SMA" ? ta.sma(src, len) : ta.ema(src, len)

// STOCK: MA value + its value csSlopeLB bars ago, as a tuple (one security call)
maPair(string ty, int len) =>
    float m = f_ma(ty, close, len)
    [m, m[csSlopeLB]]

// Format a dollar figure with K / M / B suffix
f_money(float v) =>
    float a = math.abs(v)
    a >= 1e9 ? str.format("${0,number,0.00}B", v / 1e9) : a >= 1e6 ? str.format("${0,number,0.00}M", v / 1e6) : a >= 1e3 ? str.format("${0,number,0.00}K", v / 1e3) : str.format("${0,number,0.00}", v)

// Append a value to a label only when showVals is on
lbl(string name, string valStr) => showVals ? name + "  " + valStr : name

// -----------------------------------------------------------------------------
//  CALCULATIONS — MARKET (Signal Ticker)
// -----------------------------------------------------------------------------
emaX1f = request.security(srcSym, tf, f_ma(x1Ty, close, x1Fast))
emaX1s = request.security(srcSym, tf, f_ma(x1Ty, close, x1Slow))
emaX2f = request.security(srcSym, tf, f_ma(x2Ty, close, x2Fast))
emaX2s = request.security(srcSym, tf, f_ma(x2Ty, close, x2Slow))
emaX3f = request.security(srcSym, tf, f_ma(x3Ty, close, x3Fast))
emaX3s = request.security(srcSym, tf, f_ma(x3Ty, close, x3Slow))
emaX4f = request.security(srcSym, tf, f_ma(x4Ty, close, x4Fast))
emaX4s = request.security(srcSym, tf, f_ma(x4Ty, close, x4Slow))

emaS1  = request.security(srcSym, tf, f_ma(s1Ty, close, s1Len))
emaS1p = request.security(srcSym, tf, f_ma(s1Ty, close, s1Len)[slopeLB])
emaS2  = request.security(srcSym, tf, f_ma(s2Ty, close, s2Len))
emaS2p = request.security(srcSym, tf, f_ma(s2Ty, close, s2Len)[slopeLB])
emaS3  = request.security(srcSym, tf, f_ma(s3Ty, close, s3Len))
emaS3p = request.security(srcSym, tf, f_ma(s3Ty, close, s3Len)[slopeLB])
emaS4  = request.security(srcSym, tf, f_ma(s4Ty, close, s4Len))
emaS4p = request.security(srcSym, tf, f_ma(s4Ty, close, s4Len)[slopeLB])

priceVal = request.security(srcSym, tf, close)
emaP1    = request.security(srcSym, tf, f_ma(p1Ty, close, p1Len))
emaP2    = request.security(srcSym, tf, f_ma(p2Ty, close, p2Len))

t2108Val = request.security(t2108Sym, extTF, close, gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
vixVal   = request.security(vixSym, extTF, close, gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
rsiVal   = request.security(srcSym, tf, ta.rsi(close, rsiLen))

// -----------------------------------------------------------------------------
//  CALCULATIONS — STOCK (chart symbol = syminfo.tickerid)
// -----------------------------------------------------------------------------
[csMa1, csMa1p] = request.security(syminfo.tickerid, csTF, maPair(cs1Ty, cs1Len), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[csMa2, csMa2p] = request.security(syminfo.tickerid, csTF, maPair(cs2Ty, cs2Len), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[csMa3, csMa3p] = request.security(syminfo.tickerid, csTF, maPair(cs3Ty, cs3Len), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[csMa4, csMa4p] = request.security(syminfo.tickerid, csTF, maPair(cs4Ty, cs4Len), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

[csPrice, csRsi, csDvol] = request.security(syminfo.tickerid, csTF, [close, ta.rsi(close, csRsiLen), close * volume], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

atrDollar = request.security(syminfo.tickerid, "D", ta.atr(atrLen) * atrMult, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

// -----------------------------------------------------------------------------
//  ROW DEFINITIONS  → label + state (1 green, -1 red, 0 neutral) + header flag
// -----------------------------------------------------------------------------
type Row
    string lbl
    int    st
    bool   hdr

var rows = array.new<Row>()
addRow(bool enabled, string label, int state) =>
    if enabled
        array.push(rows, Row.new(label, state, false))
addHdr(string label) =>
    array.push(rows, Row.new(label, 0, true))
stColor(int st) => st == 1 ? colGreen : st == -1 ? colRed : colNeut

marketAny = x1On or x2On or x3On or x4On or s1On or s2On or s3On or s4On or p1On or p2On or vixOn or t2108On or rsiOn
stockAny  = (csPriceVsMA and (cs1On or cs2On or cs3On or cs4On)) or (csSlopeOn and (cs1On or cs2On or cs3On or cs4On)) or csRsiOn or csDvOn or atrOn

array.clear(rows)

// ---------------- MARKET ----------------
if showHeaders and marketAny
    addHdr(str.format("■ MARKET  {0}", srcSym))

addRow(x1On, str.format("{0}/{1} {2} Cross", x1Fast, x1Slow, x1Ty), emaX1f > emaX1s ? 1 : -1)
addRow(x2On, str.format("{0}/{1} {2} Cross", x2Fast, x2Slow, x2Ty), emaX2f > emaX2s ? 1 : -1)
addRow(x3On, str.format("{0}/{1} {2} Cross", x3Fast, x3Slow, x3Ty), emaX3f > emaX3s ? 1 : -1)
addRow(x4On, str.format("{0}/{1} {2} Cross", x4Fast, x4Slow, x4Ty), emaX4f > emaX4s ? 1 : -1)

addRow(s1On, str.format("{0} {1} Slope", s1Len, s1Ty), emaS1 > emaS1p ? 1 : -1)
addRow(s2On, str.format("{0} {1} Slope", s2Len, s2Ty), emaS2 > emaS2p ? 1 : -1)
addRow(s3On, str.format("{0} {1} Slope", s3Len, s3Ty), emaS3 > emaS3p ? 1 : -1)
addRow(s4On, str.format("{0} {1} Slope", s4Len, s4Ty), emaS4 > emaS4p ? 1 : -1)

addRow(p1On, str.format("Price > {0} {1}", p1Len, p1Ty), priceVal > emaP1 ? 1 : -1)
addRow(p2On, str.format("Price > {0} {1}", p2Len, p2Ty), priceVal > emaP2 ? 1 : -1)

addRow(vixOn, lbl("VIX", str.format("{0,number,#.##}", vixVal)), vixVal < vixThr ? 1 : -1)

t2108State = t2108Val >= t2108OB ? -1 : t2108Val <= t2108OS ? 1 : 0
addRow(t2108On, lbl("T2108", str.format("{0,number,#.#}", t2108Val)), t2108State)

rsiState = rsiVal >= rsiOB ? -1 : rsiVal <= rsiOS ? 1 : 0
addRow(rsiOn, lbl("RSI", str.format("{0,number,#.#}", rsiVal)), rsiState)

// ---------------- STOCK ----------------
if showHeaders and stockAny
    addHdr(str.format("■ STOCK  {0}", syminfo.ticker))

if csPriceVsMA
    addRow(cs1On, str.format("Px > {0} {1}", cs1Len, cs1Ty), csPrice > csMa1 ? 1 : -1)
    addRow(cs2On, str.format("Px > {0} {1}", cs2Len, cs2Ty), csPrice > csMa2 ? 1 : -1)
    addRow(cs3On, str.format("Px > {0} {1}", cs3Len, cs3Ty), csPrice > csMa3 ? 1 : -1)
    addRow(cs4On, str.format("Px > {0} {1}", cs4Len, cs4Ty), csPrice > csMa4 ? 1 : -1)

if csSlopeOn
    addRow(cs1On, str.format("{0} {1} Slope", cs1Len, cs1Ty), csMa1 > csMa1p ? 1 : -1)
    addRow(cs2On, str.format("{0} {1} Slope", cs2Len, cs2Ty), csMa2 > csMa2p ? 1 : -1)
    addRow(cs3On, str.format("{0} {1} Slope", cs3Len, cs3Ty), csMa3 > csMa3p ? 1 : -1)
    addRow(cs4On, str.format("{0} {1} Slope", cs4Len, cs4Ty), csMa4 > csMa4p ? 1 : -1)

csRsiState = csRsi >= rsiOB ? -1 : csRsi <= rsiOS ? 1 : 0
addRow(csRsiOn, lbl("RSI", str.format("{0,number,#.#}", csRsi)), csRsiState)

addRow(csDvOn, lbl("$ Vol", f_money(csDvol)), 0)

addRow(atrOn, lbl(str.format("{0,number,#.#}x ATR", atrMult), f_money(atrDollar)), 0)

// -----------------------------------------------------------------------------
//  RENDER  (only on the last bar)
// -----------------------------------------------------------------------------
var table t = na

if barstate.islast
    n = array.size(rows)
    bool horiz = layout == "Horizontal"
    int cols = horiz ? n : (showLabels ? 2 : 1)
    int trows = horiz ? (showLabels ? 2 : 1) : n

    t := table.new(posVal, math.max(cols, 1), math.max(trows, 1), border_width = 1, border_color = frameCol, frame_color = frameCol, frame_width = 1)
    table.clear(t, 0, 0, math.max(cols, 1) - 1, math.max(trows, 1) - 1)

    for i = 0 to n - 1
        Row r = array.get(rows, i)
        if horiz
            if r.hdr
                table.cell(t, i, 0, r.lbl, text_color = colHdrTxt, text_size = szVal, bgcolor = colHdrBg)
                if showLabels
                    table.cell(t, i, 1, "", bgcolor = colHdrBg, text_size = szVal)
            else
                cellCol = stColor(r.st)
                if showLabels
                    table.cell(t, i, 0, r.lbl, text_color = colText, text_size = szVal, bgcolor = na)
                    table.cell(t, i, 1, "", bgcolor = cellCol, text_size = szVal)
                else
                    table.cell(t, i, 0, r.lbl, text_color = colText, text_size = szVal, bgcolor = cellCol)
        else
            if r.hdr
                table.cell(t, 0, i, r.lbl, text_color = colHdrTxt, text_size = szVal, bgcolor = colHdrBg, text_halign = text.align_left)
                if showLabels
                    table.cell(t, 1, i, "", bgcolor = colHdrBg, text_size = szVal)
            else
                cellCol = stColor(r.st)
                if showLabels
                    table.cell(t, 0, i, r.lbl, text_color = colText, text_size = szVal, bgcolor = na, text_halign = text.align_left)
                    table.cell(t, 1, i, "", bgcolor = cellCol, text_size = szVal)
                else
                    table.cell(t, 0, i, r.lbl, text_color = colText, text_size = szVal, bgcolor = cellCol)
````
