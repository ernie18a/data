# MA Cross Whipsaw Tax: What the Fake Crosses Cost

- url: https://www.tradingview.com/script/qDfurRAU-MA-Cross-Whipsaw-Tax-What-the-Fake-Crosses-Cost/
- type: indicator
- pine_id: PUB;8d133664354845a79d60b70d8a0142c3
- version: 1.0

## Description

WHAT IT DOES
A moving-average cross system pays for its signals in two places: the crosses that reverse a few bars later, and the costs of its fills. This indicator finds the crosses of a fast and a slow average (SMA or EMA of the close, 20 and 50 by default) and trades them in two shadow ledgers. By default each fill closes the open position, if any, and opens one on the signal's side; a long-only switch keeps only the long legs. Each closed trade is split by how long it was held: a trade held at most K bars (10 by default) is a whipsaw. The last-bar table puts both ledgers side by side.

WHAT IS ORIGINAL HERE
A total return hides where an MA cross loses. This script keeps three numbers apart: the whipsaw tax (the summed return of the trades that reversed within K bars); the summed return of the other trades; and the costs. It also runs a second ledger on the same bars, Confirmed, which trades a cross only after the fast average has stayed on the new side for M bars (3 by default). Waiting removes some whipsaws, but it also enters and exits the trends later. A third column shows Confirmed minus Raw on every measure row: the tax saved, the trend return given back, the fills saved, and the net of the three. The Difference row says whether the filter pays or costs on these bars. Unlike the author's Cost Ladder, which re-prices any signal at 0, 1 and 2x costs, this one splits MA-cross trades by holding time and compares a confirmation filter at one cost.

HOW IT IS MEASURED
- Side: +1 when the fast average closes above the slow one, -1 when below; equal values keep the previous side. A change of side is a cross; the first side after the warm-up is not one.
- Raw ledger: every cross is a signal. Confirmed ledger: a signal fires when the side has held for M consecutive confirmed bars, the cross bar included, and differs from the last side it fired on, or from the first side after the warm-up.
- Fills: at the open of the bar after the signal. Return = direction x (exit / entry - 1) in percent; bars held = exit bar - entry bar; a whipsaw when bars held <= K.
- Per ledger: trades, mean bars held, whipsaws and their share, whipsaw tax, other trades, gross = tax + other trades, costs = trades x 2 x cost per side (0.05% by default), net = gross minus costs. Returns are summed in percent, one unit per trade, not compounded.
- Counters move only on confirmed bars; a position still open on the last bar is not counted. No request.security call.

HOW TO USE IT
1. Keep the defaults first, then set the averages you trade. For the classic golden cross, use the 1D timeframe with fast 50 and slow 200; K then counts days.
2. Set the cost per side to your commission plus slippage.
3. Read the whipsaw tax next to the other trades. On a random walk the whipsaws lose too, because a quick reversal usually follows a move against the position, and the longer trades pay it back on average. A negative tax alone does not mean the market is choppy.
4. Read the third column and the Difference row: what M bars of confirmation saved and what it gave back.
5. Set M to 1: both ledgers match and the verdict reads "no difference on these bars", with "(under 30 trades)" when either ledger has fewer than 30 closed trades, and "no closed trade yet" when there is none.

HOW TO READ THE TABLE
Header: symbol, timeframe, averages, long/short or long only, confirmed bars counted; then the columns Raw, Confirmed and Confirmed - Raw.
Trades, mean bars held. Whipsaws (held <= K bars) and their share.
Whipsaw tax and Other trades: summed returns in percent.
Gross, Costs (negative), Net.
Difference: net difference, whipsaws removed, verdict.
Last cross: side, bar time in the chart symbol's exchange time, bars since.

LIMITATIONS
- Shadow ledgers, not a strategy: next-open fills, a flat cost per side, no stops, no sizing, no funding cost on shorts.
- K moves trades between the whipsaw and the other rows, and M changes the Confirmed ledger; the comparison holds for the settings chosen.
- The verdict is the sign of the net difference; on random walks it reads "pays" or "costs" by chance.
- Fills use the chart's open: use standard candles, not Heikin Ashi or Renko.
- With EMA the values depend on where the loaded history starts.
- Only loaded bars count, so history depth, symbol and timeframe change the result. Counts, not a trading rule. Not financial advice.

The chart shows BINANCE:BTCUSDT on the 1 hour timeframe with the default settings. The table is in the bottom right.

## Source Code

````pine
//@version=6
indicator("MA Cross Whipsaw Tax: What the Fake Crosses Cost", shorttitle = "WHIPSAW-TAX", overlay = true, behind_chart = false)

// MA Cross Whipsaw Tax
// 1) A fast and a slow moving average of the close (SMA or EMA, 20 and 50 by default). On every confirmed bar
//    the side is +1 when the fast one is above the slow one and -1 when it is below; a bar where they are equal
//    keeps the previous side. A change of side is a cross. The first side after the warm-up is not one.
// 2) Two shadow ledgers trade the same bars. Raw: every cross is a signal. Confirmed: a signal fires only when
//    the side has held for M consecutive confirmed bars, the cross bar included (3 by default), so a cross that
//    flips back sooner is never traded; with M = 1 it is the Raw ledger. A signal on a confirmed bar fills at the
//    next bar's open. Stop and reverse by default: the fill closes the open position, if any, and opens one on the
//    signal's side. In long-only mode an up signal opens a long and a down signal only closes it.
// 3) A trade closes at the fill of the opposite signal: return = direction * (exit / entry - 1) in percent,
//    bars held = exit bar - entry bar. It is a whipsaw when it was held at most K bars (10 by default). Per
//    ledger: trades, whipsaws and their share, the whipsaw tax (the sum of the whipsaw trades' returns), the sum
//    of the other trades' returns, gross, costs = trades * 2 * cost per side, net, and mean bars held.
// 4) On the last bar the table shows both ledgers, their difference and a verdict: the filter pays or costs on
//    these bars. A position still open on the last bar is not counted.
// The result is a ledger of counts for this symbol on this chart, not a trading rule.

// ───────────────────────── Inputs ─────────────────────────
maType = input.string("SMA", "Average type", options = ["SMA", "EMA"], group = "Moving averages", tooltip = "ta.sma or ta.ema of the close, for both averages.")
fastLen = input.int(20, "Fast length", minval = 1, group = "Moving averages", tooltip = "Length of the fast average. For the golden cross on 1D, set 50 here and 200 for the slow one.")
slowLen = input.int(50, "Slow length", minval = 2, group = "Moving averages", tooltip = "Length of the slow average. The fast length should be the shorter one.")

longOnly = input.bool(false, "Long only", group = "Trades", tooltip = "Off: stop and reverse, a fill closes the open position, if any, and opens one on the signal's side. On: an up signal opens a long, a down signal only closes it.")
whipK = input.int(10, "Whipsaw window K (bars)", minval = 1, group = "Trades", tooltip = "A closed trade held at most this many bars, from its entry fill to its exit fill, is a whipsaw.")
confirmBars = input.int(3, "Confirmation M (bars)", minval = 1, maxval = 100, group = "Trades", tooltip = "The Confirmed ledger trades a cross only after the fast average has stayed on the new side for M consecutive confirmed bars, the cross bar included. M = 1 makes it the Raw ledger.")
costPct = input.float(0.05, "Cost per side (%)", minval = 0, maxval = 5, step = 0.01, group = "Trades", tooltip = "Commission plus slippage for one fill, in percent. A closed trade pays it twice, at entry and at exit.")

showMarks = input.bool(true, "Mark signals", group = "Display", tooltip = "Small triangles at the Raw crosses and small diamonds at the Confirmed signals, on the bar where each fires. The fill is at the next bar's open.")
tablePos = input.string("Bottom right", "Table position", options = ["Top right", "Bottom right", "Top left", "Bottom left"], group = "Display")
textSize = input.string("Small", "Table text size", options = ["Tiny", "Small", "Normal"], group = "Display")

// ───────────────────────── Averages ─────────────────────────
// Both types are computed on every bar, at global scope, and one is picked, so neither call runs conditionally.
float fastSma = ta.sma(close, fastLen)
float fastEma = ta.ema(close, fastLen)
float slowSma = ta.sma(close, slowLen)
float slowEma = ta.ema(close, slowLen)
float fastMa = maType == "EMA" ? fastEma : fastSma
float slowMa = maType == "EMA" ? slowEma : slowSma

plot(fastMa, "Fast average", color = color.new(color.orange, 0), linewidth = 1)
plot(slowMa, "Slow average", color = color.new(color.blue, 0), linewidth = 2)

// ───────────────────────── State ─────────────────────────
// The side of the fast average (+1 above, -1 below, 0 before the first side), the confirmed bars it has held,
// and the last side the Confirmed ledger fired on.
var int maSide = 0
var int sideRun = 0
var int confSide = 0
var int nBars = 0

// The last Raw cross: its side, bar and bar time.
var int lastCrossDir = 0
var int lastCrossBar = int(na)
var int lastCrossTime = int(na)

// Ledgers: index 0 is Raw, 1 is Confirmed. Per ledger: the signal waiting for the next open (+1, -1 or 0), the
// open position (direction, entry price, entry bar), and the counters of the closed trades.
var array<int> pendSig = array.new<int>(2, 0)
var array<int> posDir = array.new<int>(2, 0)
var array<float> posEntry = array.new<float>(2, 0.0)
var array<int> posBar = array.new<int>(2, 0)
var array<int> nTrades = array.new<int>(2, 0)
var array<int> nWhip = array.new<int>(2, 0)
var array<int> sumBars = array.new<int>(2, 0)
var array<float> sumWhip = array.new<float>(2, 0.0)
var array<float> sumOther = array.new<float>(2, 0.0)

// The side of the Raw cross and of the Confirmed signal on this bar, 0 when there is none; the markers read them.
int rawHere = 0
int confHere = 0

// ───────────────────────── Ledger update ─────────────────────────
// Everything counts on confirmed bars only: on the realtime bar the averages still move with every tick. The
// order on a bar: first the fills, at this bar's open, of the signals from the previous confirmed bar; then the
// side at this close and the new signals, which wait for the next bar's open.
if barstate.isconfirmed
    nBars += 1
    for led = 0 to 1
        int sig = array.get(pendSig, led)
        if sig != 0
            // The fill, at this bar's open: closes the open position of the other side, if any, and books it; then
            // opens a position on the signal's side (in long-only mode, only an up signal opens). Written inline: as a
            // user-defined function called for its side effects, with its result unused, it did not run on TradingView.
            int pd = array.get(posDir, led)
            if pd != 0 and pd != sig
                float ret = pd * (open / array.get(posEntry, led) - 1) * 100
                int held = bar_index - array.get(posBar, led)
                array.set(nTrades, led, array.get(nTrades, led) + 1)
                array.set(sumBars, led, array.get(sumBars, led) + held)
                if held <= whipK
                    array.set(nWhip, led, array.get(nWhip, led) + 1)
                    array.set(sumWhip, led, array.get(sumWhip, led) + ret)
                else
                    array.set(sumOther, led, array.get(sumOther, led) + ret)
                array.set(posDir, led, 0)
            if array.get(posDir, led) == 0 and (sig == 1 or not longOnly)
                array.set(posDir, led, sig)
                array.set(posEntry, led, open)
                array.set(posBar, led, bar_index)
            array.set(pendSig, led, 0)
    int sideNow = na(fastMa) or na(slowMa) ? 0 : fastMa > slowMa ? 1 : fastMa < slowMa ? -1 : 0
    if sideNow != 0
        if maSide == 0
            // First side after the warm-up: not a cross, and the Confirmed ledger starts on it.
            maSide := sideNow
            sideRun := 1
            confSide := sideNow
        else if sideNow != maSide
            // A cross: a Raw signal.
            maSide := sideNow
            sideRun := 1
            array.set(pendSig, 0, sideNow)
            rawHere := sideNow
            lastCrossDir := sideNow
            lastCrossBar := bar_index
            lastCrossTime := time
        else
            sideRun += 1
    else if maSide != 0
        // Equal averages, or an na average after the first side, keep the previous side and extend the run.
        sideRun += 1
    // A Confirmed signal once the side has held for M bars and differs from the last side this ledger fired on.
    if maSide != 0 and sideRun >= confirmBars and maSide != confSide
        confSide := maSide
        array.set(pendSig, 1, maSide)
        confHere := maSide

// ───────────────────────── Markers ─────────────────────────
plotshape(showMarks and rawHere == 1, "Raw cross up", style = shape.triangleup, location = location.belowbar, color = color.new(color.teal, 0), size = size.tiny, display = display.pane)
plotshape(showMarks and rawHere == -1, "Raw cross down", style = shape.triangledown, location = location.abovebar, color = color.new(color.red, 0), size = size.tiny, display = display.pane)
plotshape(showMarks and confHere == 1, "Confirmed signal up", style = shape.diamond, location = location.belowbar, color = color.new(color.teal, 0), size = size.tiny, display = display.pane)
plotshape(showMarks and confHere == -1, "Confirmed signal down", style = shape.diamond, location = location.abovebar, color = color.new(color.red, 0), size = size.tiny, display = display.pane)

// ───────────────────────── Table ─────────────────────────
tPos = switch tablePos
    "Top right" => position.top_right
    "Bottom right" => position.bottom_right
    "Top left" => position.top_left
    => position.bottom_left

tSize = switch textSize
    "Tiny" => size.tiny
    "Normal" => size.normal
    => size.small

// Four columns: the row names, Raw, Confirmed, and Confirmed minus Raw. Ten rows: header, seven measures, the
// difference and the last cross.
var table tbl = table.new(tPos, 4, 10, border_width = 1)

// Opaque cell colors blended from the chart background, so candles do not show through the table
// on a light or a dark theme.
cellBg = color.from_gradient(0.12, 0.0, 1.0, chart.bg_color, color.gray)
hdrBg = color.from_gradient(0.30, 0.0, 1.0, chart.bg_color, color.gray)
goodBg = color.from_gradient(0.40, 0.0, 1.0, chart.bg_color, color.green)

setCell(int col, int row, string txt, color bg = na, string align = text.align_center) =>
    table.cell(tbl, col, row, txt, text_color = chart.fg_color, text_size = tSize, text_halign = align, bgcolor = na(bg) ? cellBg : bg)

// "+1.23%" or "-1.23%" from a return in percent, "n/a" when there is none.
fmtPct(float v) =>
    na(v) ? "n/a" : (v > 0 ? "+" : "") + str.tostring(v, "0.00") + "%"

// "13.0%" from a share in [0, 1], "n/a" when there is none.
fmtShare(float r) =>
    na(r) ? "n/a" : str.tostring(r * 100, "0.0") + "%"

// "+14" or "-14" from a signed count.
fmtSigned(int d) =>
    (d > 0 ? "+" : "") + str.tostring(d)

// "+1.4" or "-1.4" from a signed number with one decimal, "n/a" when there is none.
fmtSigned1(float v) =>
    na(v) ? "n/a" : (v > 0 ? "+" : "") + str.tostring(v, "0.0")

// part / whole, na when whole is 0.
ratio(float part, int whole) =>
    whole > 0 ? part / whole : float(na)

// The bar's open time in the chart symbol's exchange time, "n/a" when there is none.
fmtTime(int t) =>
    na(t) ? "n/a" : str.format_time(t, "yyyy-MM-dd HH:mm", syminfo.timezone)

// Merged cells are merged once: merging a cell that is already merged raises an error.
var bool merged = false

if barstate.islast
    int tR = array.get(nTrades, 0)
    int tC = array.get(nTrades, 1)
    int wR = array.get(nWhip, 0)
    int wC = array.get(nWhip, 1)
    float taxR = array.get(sumWhip, 0)
    float taxC = array.get(sumWhip, 1)
    float othR = array.get(sumOther, 0)
    float othC = array.get(sumOther, 1)
    float grossR = taxR + othR
    float grossC = taxC + othC
    // Costs are shown as a negative contribution, so net = gross + costs.
    float costR = 0.0 - tR * 2 * costPct
    float costC = 0.0 - tC * 2 * costPct
    float netR = grossR + costR
    float netC = grossC + costC
    float heldR = ratio(array.get(sumBars, 0), tR)
    float heldC = ratio(array.get(sumBars, 1), tC)
    float shareR = ratio(wR, tR)
    float shareC = ratio(wC, tC)
    float netDiff = netC - netR
    // Verdict on the net difference; under 30 trades in either ledger it says so.
    string verdict = tR == 0 ? "no closed trade yet" : netDiff > 0 ? "the filter pays on these bars" : netDiff < 0 ? "the filter costs on these bars" : "no difference on these bars"
    if tR > 0 and math.min(tR, tC) < 30
        verdict += " (under 30 trades)"
    string diffText = tR == 0 ? verdict : "net " + fmtPct(netDiff) + ", " + str.tostring(wR - wC) + " whipsaws removed, " + verdict
    string lastSide = lastCrossDir == 0 ? "n/a" : lastCrossDir == 1 ? "up" : "down"
    string sinceText = na(lastCrossBar) ? "n/a" : str.tostring(bar_index - lastCrossBar, "#,##0") + " bars ago"
    // ticker.standard gives the plain "prefix:ticker" form; syminfo.tickerid can carry the session, adjustment
    // and currency modifiers in an encoded form.
    string hdr = ticker.standard(syminfo.tickerid) + " · " + timeframe.period + " · " + maType + " " + str.tostring(fastLen) + "/" + str.tostring(slowLen) + " · " + (longOnly ? "long only" : "long/short") + " · " + str.tostring(nBars, "#,##0") + " confirmed bars"
    table.cell(tbl, 0, 0, hdr, text_color = chart.fg_color, text_size = tSize, text_halign = text.align_left, bgcolor = hdrBg, tooltip = "Counts on confirmed bars. A position still open on the last bar is not counted. Not advice.")
    setCell(1, 0, "Raw: every cross", hdrBg)
    setCell(2, 0, "Confirmed: " + str.tostring(confirmBars) + (confirmBars == 1 ? " bar" : " bars"), hdrBg)
    setCell(3, 0, "Confirmed - Raw", hdrBg)
    setCell(0, 1, "Trades, mean bars held", na, text.align_left)
    setCell(1, 1, str.tostring(tR, "#,##0") + ", " + (na(heldR) ? "n/a" : str.tostring(heldR, "0.0")))
    setCell(2, 1, str.tostring(tC, "#,##0") + ", " + (na(heldC) ? "n/a" : str.tostring(heldC, "0.0")))
    setCell(3, 1, fmtSigned(tC - tR) + ", " + (na(heldC - heldR) ? "n/a" : fmtSigned1(heldC - heldR) + " bars"))
    setCell(0, 2, "Whipsaws (held <= " + str.tostring(whipK) + " bars), share", na, text.align_left)
    setCell(1, 2, str.tostring(wR, "#,##0") + ", " + fmtShare(shareR))
    setCell(2, 2, str.tostring(wC, "#,##0") + ", " + fmtShare(shareC))
    setCell(3, 2, fmtSigned(wC - wR) + ", " + (na(shareC - shareR) ? "n/a" : fmtSigned1((shareC - shareR) * 100) + " pts"))
    setCell(0, 3, "Whipsaw tax (their returns)", na, text.align_left)
    setCell(1, 3, fmtPct(taxR))
    setCell(2, 3, fmtPct(taxC))
    setCell(3, 3, fmtPct(taxC - taxR))
    setCell(0, 4, "Other trades (their returns)", na, text.align_left)
    setCell(1, 4, fmtPct(othR))
    setCell(2, 4, fmtPct(othC))
    setCell(3, 4, fmtPct(othC - othR))
    setCell(0, 5, "Gross", na, text.align_left)
    setCell(1, 5, fmtPct(grossR))
    setCell(2, 5, fmtPct(grossC))
    setCell(3, 5, fmtPct(grossC - grossR))
    setCell(0, 6, "Costs (" + str.tostring(costPct, "0.0##") + "% per side)", na, text.align_left)
    setCell(1, 6, fmtPct(costR))
    setCell(2, 6, fmtPct(costC))
    setCell(3, 6, fmtPct(costC - costR))
    setCell(0, 7, "Net", na, text.align_left)
    setCell(1, 7, fmtPct(netR))
    setCell(2, 7, fmtPct(netC))
    setCell(3, 7, fmtPct(netDiff))
    // Green only when the filter pays; the other readings are plain.
    setCell(0, 8, "Difference", na, text.align_left)
    setCell(1, 8, diffText, tR > 0 and netDiff > 0 ? goodBg : na, text.align_left)
    setCell(2, 8, "")
    setCell(3, 8, "")
    setCell(0, 9, "Last cross", na, text.align_left)
    setCell(1, 9, lastSide)
    setCell(2, 9, "bar " + fmtTime(lastCrossTime) + " (" + syminfo.timezone + ")")
    setCell(3, 9, sinceText)
    if not merged
        table.merge_cells(tbl, 1, 8, 3, 8)
        merged := true
````
