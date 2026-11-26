# Intrabar Ambiguity: Which Hit First, Stop or Target?

- url: https://www.tradingview.com/script/QXyp6oKQ-Intrabar-Ambiguity-Which-Hit-First-Stop-or-Target/
- type: indicator
- pine_id: PUB;a571ff04d8a749f2b2174512f9e54940
- version: 1.0

## Description

WHAT IT DOES
Intrabar Ambiguity counts the exit bars in which a stop and a target both sit inside one bar's range, so open, high, low and close cannot say which was hit first. It replays one hypothetical ATR-based trade at a time through a shadow ledger and settles each such bar twice: with a fixed rule on the bar's open, high and low, and with the lower-timeframe bars inside it. The table shows how often the two answers differ and how far the win rate moves.

WHAT IS ORIGINAL HERE
A bar records a range, not the order of the prices inside it. When a stop and a target both sit in that range, the order decides win or loss. This script isolates those bars and keeps two outcomes for the same trades, the rule's and the lower-timeframe data's, so the two win rates differ only by the order assumed inside ambiguous bars. Bars that cannot be settled are counted apart. It keeps its own ledger and does not use the Strategy Tester.

LEDGER RULES
- One trade at a time, long or short. Entry at a bar's close; the stop and the target are placed there, a chosen number of ATRs away.
- Exits are checked from the next bar on. A bar that opens beyond the stop or the target exits there. Gap exits are never ambiguous.
- Otherwise a bar touches the stop when its low (long) or high (short) reaches it, and the target likewise. Both touched makes the bar ambiguous.
- A trade that touches neither closes at the close of the Nth bar after entry: a win if that close is above the entry for a long, below it for a short.
- After an exit, the next trade opens at that bar's close, so its range is never reused.
- Only confirmed bars update the ledger. A trade still open on the last bar is not counted.

HOW AMBIGUITY IS RESOLVED
Rule. TradingView documents that on historical bars the strategy broker emulator does not know the intrabar path. It assumes that if the bar's high is closer to its open than the low is, price went open, high, low, close; otherwise open, low, high, close. The "Bar Magnifier" strategy setting uses lower-timeframe data instead. That documented assumption of the broker emulator is the rule here: high first means target first for a long and stop first for a short; low first is the reverse.
Lower timeframe. It walks the lower-timeframe bars inside the exit bar in time order. The first one that touches the stop or the target decides. If that one touches both, or none touches either, the bar is unresolved. If the lower timeframe is not below the chart timeframe, or TradingView returns no lower-timeframe bars, it is counted as "no lower-timeframe data".
Exit counts follow the rule. The LTF-corrected win rate uses the lower-timeframe outcome where there is one and the rule's otherwise.

HOW TO USE IT
1. Add it to a chart. Choose the direction, the ATR length, the stop and target distances in ATRs, and the time exit.
2. Choose a lower timeframe below the chart's, for example 5 on a 4 hour chart.
3. Read the table. Marks sit on ambiguous exit bars: red cross, the lower timeframe disagrees with the rule; gray circle, it agrees; orange square, unresolved or no data.

HOW TO READ THE TABLE
Trades closed; exits split into stop / target / time, ambiguous bars under the rule's answer.
Ambiguous exit bars: both levels touched, as a share of trades. Resolved with lower timeframe: those an intrabar decided.
Rule agreed / disagreed: among resolved bars, with the share that disagreed. Red when at least one did.
Unresolved in one intrabar: both levels inside one lower-timeframe bar, or no touch found. No lower-timeframe data: nothing to resolve the bar.
Win rate, rule and LTF-corrected: all closed trades, ambiguous bars settled by the rule or, where possible, the lower timeframe. Win rate, resolved bars: the same two over resolved bars only.

LIMITATIONS
- Lower-timeframe bars are not tick data: when both levels fall inside one, the order is unknown.
- TradingView limits intrabars by plan, so old bars can have none. The disagreement share covers only resolved bars.
- The ledger counts outcomes, not returns, with no commission, slippage or spread. A gap exit is counted at the level the bar opened beyond.
- The trades are hypothetical, not a signal.
- Only loaded bars count, so history depth, symbol and timeframe change every number.
- Not the Strategy Tester. Counts, not a trading rule. Not financial advice.

The chart shows BTCUSDT (Binance) on the 4 hour timeframe with the default settings. The table is in the bottom right.

## Source Code

````pine
//@version=6
indicator("Intrabar Ambiguity: Which Hit First, Stop or Target?", shorttitle = "INTRABAR-AMB", overlay = true, max_bars_back = 500)

// Intrabar Ambiguity
// 1) Replays one hypothetical trade at a time through a shadow ledger: entry at a close, a stop and a
//    target set in ATR units, and a time exit.
// 2) Finds the exit bars whose range touches both the stop and the target. A bar of open, high, low
//    and close cannot say which level came first.
// 3) Settles each of those bars twice: with the documented assumption of the broker emulator, and with
//    the lower-timeframe bars inside it. It counts how often the two answers differ.
// The result is a table of counts, not a trading rule.

// ───────────────────────── Inputs ─────────────────────────
direction = input.string("Long", "Direction", options = ["Long", "Short"], group = "Trade", tooltip = "Long: the stop is below the entry and the target above it. Short: the other way round.")
atrLen = input.int(14, "ATR length", minval = 1, group = "Trade", tooltip = "Length of the ATR that sizes the stop and the target. It is read at the close of the entry bar.")
stopAtr = input.float(0.5, "Stop distance (ATR)", minval = 0.1, step = 0.1, group = "Trade", tooltip = "Distance from the entry to the stop, in ATR units.")
targetAtr = input.float(0.5, "Target distance (ATR)", minval = 0.1, step = 0.1, group = "Trade", tooltip = "Distance from the entry to the target, in ATR units.")
maxBars = input.int(50, "Time exit (bars)", minval = 1, maxval = 500, group = "Trade", tooltip = "A trade that has touched neither level is closed at the close of the Nth bar after the entry bar.")

ltf = input.timeframe("5", "Lower timeframe", group = "Resolution", tooltip = "Must be below the chart timeframe. The number of intrabars TradingView returns is limited by your plan, so old bars may have no lower-timeframe data. Those bars are counted apart in the table.")

showMarks = input.bool(true, "Mark ambiguous exit bars", group = "Display", tooltip = "Red cross: the lower timeframe disagrees with the rule. Gray circle: it agrees. Orange square: not resolved, or no lower-timeframe data.")
tablePos = input.string("Bottom right", "Table position", options = ["Top right", "Bottom right", "Top left", "Bottom left"], group = "Display")

// ───────────────────────── Data ─────────────────────────
// Every ta.* and request.* call stays at global scope, so every bar evaluates it the same way.
float atr = ta.atr(atrLen)

// The intrabars of the current chart bar, oldest first. The arrays can be empty.
// ignore_invalid_timeframe = true: a lower timeframe that is not valid for this chart does not stop the script.
[ltfH, ltfL] = request.security_lower_tf(syminfo.tickerid, ltf, [high, low], ignore_invalid_timeframe = true)
bool ltfOk = timeframe.in_seconds(ltf) < timeframe.in_seconds(timeframe.period)

// 1 for a long, -1 for a short.
int d = direction == "Long" ? 1 : -1

// ───────────────────────── Shadow ledger state ─────────────────────────
var bool inTrade = false
var float entryPx = na
var float stopPx = na
var float targetPx = na
var int entryBar = na

// Counters. winsRule and winsLtf count over all closed trades.
// ambResolvedWins* count over the ambiguous bars the lower timeframe resolved.
var int trades = 0
var int exitsStop = 0
var int exitsTarget = 0
var int exitsTime = 0
var int ambiguous = 0
var int resolved = 0
var int agreed = 0
var int disagreed = 0
var int unresolved = 0
var int noLtf = 0
var int winsRule = 0
var int winsLtf = 0
var int ambResolvedWinsRule = 0
var int ambResolvedWinsLtf = 0

// ───────────────────────── Ledger update ─────────────────────────
// Only confirmed bars update the ledger, so a realtime bar never counts twice.
// A trade still open on the last bar is not counted.
bool markAgree = false
bool markDisagree = false
bool markUnres = false

if barstate.isconfirmed
    // 1) Exits are checked from the bar after the entry bar.
    if inTrade and bar_index > entryBar
        bool exited = false
        bool rWin = false
        bool lWin = false

        // Gap rule first: a bar that opens beyond a level exits at that level, and is not ambiguous.
        bool gapStop = d == 1 ? open <= stopPx : open >= stopPx
        bool gapTarget = d == 1 ? open >= targetPx : open <= targetPx

        if gapStop
            exitsStop += 1
            exited := true
        else if gapTarget
            exitsTarget += 1
            rWin := true
            lWin := true
            exited := true
        else
            bool hitStop = d == 1 ? low <= stopPx : high >= stopPx
            bool hitTarget = d == 1 ? high >= targetPx : low <= targetPx

            if hitStop and hitTarget
                // Both levels are inside this bar: the bar alone cannot say which came first.
                ambiguous += 1

                // Rule: if the high is closer to the open than the low is, the path goes to the high first.
                // For a long, high first means target first (a win). For a short, it means stop first (a loss).
                bool highFirst = (high - open) <= (open - low)
                rWin := d == 1 ? highFirst : not highFirst
                lWin := rWin

                // Lower timeframe: the first intrabar that touches a level decides.
                int nIn = 0
                if ltfOk
                    nIn := math.min(array.size(ltfH), array.size(ltfL))

                if nIn > 0
                    bool settled = false
                    bool lStop = false
                    bool lTarget = false
                    for k = 0 to nIn - 1
                        float kHigh = array.get(ltfH, k)
                        float kLow = array.get(ltfL, k)
                        bool kStop = d == 1 ? kLow <= stopPx : kHigh >= stopPx
                        bool kTarget = d == 1 ? kHigh >= targetPx : kLow <= targetPx
                        if kStop or kTarget
                            settled := true
                            lStop := kStop
                            lTarget := kTarget
                            break

                    // Both levels inside the same intrabar, or no touch at all: no lower-timeframe outcome.
                    if settled and not (lStop and lTarget)
                        resolved += 1
                        lWin := lTarget
                        ambResolvedWinsRule += rWin ? 1 : 0
                        ambResolvedWinsLtf += lWin ? 1 : 0
                        if lWin == rWin
                            agreed += 1
                            markAgree := true
                        else
                            disagreed += 1
                            markDisagree := true
                    else
                        unresolved += 1
                        markUnres := true
                else
                    noLtf += 1
                    markUnres := true

                // The exit tallies follow the rule outcome.
                if rWin
                    exitsTarget += 1
                else
                    exitsStop += 1
                exited := true
            else if hitStop
                exitsStop += 1
                exited := true
            else if hitTarget
                exitsTarget += 1
                rWin := true
                lWin := true
                exited := true

        // Time exit at this bar's close: a win if it is on the right side of the entry.
        if not exited and bar_index - entryBar >= maxBars
            exitsTime += 1
            bool tWin = d * (close - entryPx) > 0
            rWin := tWin
            lWin := tWin
            exited := true

        if exited
            trades += 1
            winsRule += rWin ? 1 : 0
            winsLtf += lWin ? 1 : 0
            inTrade := false

    // 2) If flat, including right after an exit on this bar, open the next trade at this bar's close.
    //    The exit bar's own range is never reused by the new trade.
    if not inTrade and not na(atr) and atr > 0
        entryPx := close
        stopPx := close - d * stopAtr * atr
        targetPx := close + d * targetAtr * atr
        entryBar := bar_index
        inTrade := true

// ───────────────────────── Plots ─────────────────────────
// The flags are set only inside the confirmed-bar block, so a mark never disappears later.
plotshape(showMarks and markDisagree, "Lower timeframe disagrees", shape.xcross, location.abovebar, color.red, size = size.tiny, display = display.pane)
plotshape(showMarks and markAgree, "Lower timeframe agrees", shape.circle, location.abovebar, color.gray, size = size.tiny, display = display.pane)
plotshape(showMarks and markUnres, "Not resolved", shape.square, location.abovebar, color.orange, size = size.tiny, display = display.pane)

// ───────────────────────── Table ─────────────────────────
tPos = switch tablePos
    "Top right" => position.top_right
    "Bottom right" => position.bottom_right
    "Top left" => position.top_left
    => position.bottom_left

var table tbl = table.new(tPos, 3, 13, border_width = 1)

cellBg = color.new(color.gray, 85)
hdrBg = color.new(color.gray, 65)
badBg = color.new(color.red, 65)

setCell(int col, int row, string txt, color bg = na, string align = text.align_center) =>
    table.cell(tbl, col, row, txt, text_color = chart.fg_color, text_size = size.small, text_halign = align, bgcolor = na(bg) ? cellBg : bg)

// Share as a plain percentage with one decimal.
fmtPct(float v) =>
    na(v) ? "n/a" : str.tostring(v * 100.0, "0.0") + "%"

// Share of a base, written with the base: "12.3% of ambiguous".
fmtShare(float v, string base) =>
    na(v) ? "n/a" : fmtPct(v) + " of " + base

// Merged rows are merged once: merging cells that are already merged on every realtime tick is avoided.
var bool merged = false

if barstate.islast
    float fTrades = float(trades)
    float fAmb = float(ambiguous)
    float fRes = float(resolved)

    float shAmb = trades > 0 ? fAmb / fTrades : na
    float shRes = ambiguous > 0 ? fRes / fAmb : na
    float shDis = resolved > 0 ? float(disagreed) / fRes : na
    float shUnr = ambiguous > 0 ? float(unresolved) / fAmb : na
    float shNo = ambiguous > 0 ? float(noLtf) / fAmb : na
    float wrRule = trades > 0 ? float(winsRule) / fTrades : na
    float wrLtf = trades > 0 ? float(winsLtf) / fTrades : na
    float wrResRule = resolved > 0 ? float(ambResolvedWinsRule) / fRes : na
    float wrResLtf = resolved > 0 ? float(ambResolvedWinsLtf) / fRes : na

    setCell(0, 0, "Measure", hdrBg, text.align_left)
    setCell(1, 0, "Value", hdrBg)
    setCell(2, 0, "Share", hdrBg)

    setCell(0, 1, "Trades closed", na, text.align_left)
    setCell(1, 1, str.tostring(trades))
    setCell(2, 1, "")

    setCell(0, 2, "Exits: stop / target / time", na, text.align_left)
    setCell(1, 2, str.tostring(exitsStop) + " / " + str.tostring(exitsTarget) + " / " + str.tostring(exitsTime))
    setCell(2, 2, "")

    setCell(0, 3, "Ambiguous exit bars", na, text.align_left)
    setCell(1, 3, str.tostring(ambiguous))
    setCell(2, 3, fmtShare(shAmb, "trades"))

    setCell(0, 4, "Resolved with lower timeframe", na, text.align_left)
    setCell(1, 4, str.tostring(resolved))
    setCell(2, 4, fmtShare(shRes, "ambiguous"))

    color disBg = disagreed > 0 ? badBg : na
    setCell(0, 5, "Rule agreed / disagreed", na, text.align_left)
    setCell(1, 5, str.tostring(agreed) + " / " + str.tostring(disagreed), disBg)
    setCell(2, 5, na(shDis) ? "n/a" : fmtPct(shDis) + " disagreed", disBg)

    setCell(0, 6, "Unresolved in one intrabar", na, text.align_left)
    setCell(1, 6, str.tostring(unresolved))
    setCell(2, 6, fmtShare(shUnr, "ambiguous"))

    setCell(0, 7, "No lower-timeframe data", na, text.align_left)
    setCell(1, 7, str.tostring(noLtf))
    setCell(2, 7, fmtShare(shNo, "ambiguous"))

    setCell(0, 8, "Win rate, rule (all trades)", na, text.align_left)
    setCell(1, 8, fmtPct(wrRule))
    setCell(2, 8, "")

    setCell(0, 9, "Win rate, LTF-corrected (all trades)", na, text.align_left)
    setCell(1, 9, fmtPct(wrLtf))
    setCell(2, 9, "")

    setCell(0, 10, "Win rate, resolved bars: rule vs LTF", na, text.align_left)
    setCell(1, 10, fmtPct(wrResRule) + " vs " + fmtPct(wrResLtf))
    setCell(2, 10, "n = " + str.tostring(resolved))

    string ltfTxt = ltfOk ? "LTF " + ltf : "LTF " + ltf + " (not below chart)"
    setCell(0, 11, direction + " · stop " + str.tostring(stopAtr) + " ATR · target " + str.tostring(targetAtr) + " ATR · " + ltfTxt, hdrBg, text.align_left)
    setCell(0, 12, "Hypothetical trades, one at a time. Counts, not advice.", hdrBg, text.align_left)
    for c = 1 to 2
        setCell(c, 11, "", hdrBg)
        setCell(c, 12, "", hdrBg)
    if not merged
        table.merge_cells(tbl, 0, 11, 2, 11)
        table.merge_cells(tbl, 0, 12, 2, 12)
        merged := true
````
