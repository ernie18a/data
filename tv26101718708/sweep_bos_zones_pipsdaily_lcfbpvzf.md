# Sweep  BOS Zones pipsdaily

- url: https://www.tradingview.com/script/lCfBPVzF-Sweep-BOS-Zones-pipsdaily/
- type: indicator
- pine_id: PUB;9bf5c1052bfe4d96906f1ccf3fe2a910
- version: 1.0

## Description

SMC Suite [pips_daily] is an all-in-one Smart Money Concepts toolkit that maps market structure, liquidity and key zones automatically, then highlights high-quality setups where several SMC conditions line up at once. It works on any symbol and any timeframe, because every distance is measured with ATR rather than fixed pips.
WHAT IT DRAWS • Market structure: swing and internal Break of Structure (BOS) and Change of Character (CHoCH), with a small panel showing the current swing, internal and higher-timeframe trend. • Order blocks: swing and internal bullish and bearish order blocks. Mitigated blocks are greyed out or removed. • Fair value gaps: bullish and bearish imbalances with an automatic size threshold. Partly filled gaps shrink and fully filled gaps are removed. • Liquidity: equal highs and equal lows (ATR tolerance), liquidity sweep markers, and previous day and previous week highs and lows (non-repainting). • Premium and discount: zones built from the current swing range, with an equilibrium line.
ENTRY SIGNALS (A-GRADE SETUP) A LONG signal needs all of the following:
A sell-side liquidity sweep, where price trades below a recent internal swing low.
A bullish CHoCH or BOS within a set number of bars after the sweep.
A bullish order block or fair value gap from that move, sitting in the discount half of the range.
Price returning to that zone. Entry is at the zone edge, the stop goes beyond the sweep or zone plus a small ATR buffer, and the target is a fixed risk-to-reward (default 1:2, minimum 1:2) or the opposing liquidity. SHORT signals are the mirror image: a buy-side sweep, then a bearish CHoCH or BOS, then a bearish zone in premium. Each signal shows a LONG or SHORT label and a stop-loss and take-profit box.
NEWS FILTER Volatility around high-impact news often invalidates clean setups, so an optional filter blocks entries for a set window (default 150 minutes) after common release times: US 08:30 and 10:00 New York, FOMC 14:00 New York, UK 07:00 and BoE 12:00 London, and ECB 14:15 and 14:45 Frankfurt. Each time can be switched on or off, and you can type in exact release dates and times. Blocked windows are shaded on the chart.
OPTIONAL HIGHER-TIMEFRAME FILTER Only take signals in the direction of the higher-timeframe structure trend (default 4H, off by default).
STATS TABLE A table in the top-right corner scores every signal on the loaded chart history at 1:2 and 1:3, split into all, bullish and bearish trades. It shows the number of trades, wins, losses, win rate, net R and average R, plus how many entries the news filter skipped. Scoring is conservative: if the stop and target are both hit in the same candle, it counts as a loss.
ALERTS Bullish and bearish CHoCH, bullish and bearish BOS, sell-side and buy-side liquidity sweeps, approaching long and short zones, long and short entry signals, take-profit hit, and stop-loss hit. A single "any alert() function call" alert catches all events with full price details.
HOW TO USE IT Use the indicator to find and frame setups, not as an automatic buy and sell system. Check the stats table on your own symbol and timeframe before relying on any setting, and combine the signals with your own context, such as session, key levels and higher-timeframe bias.
NOTES AND LIMITATIONS • Swing points are confirmed a few bars after they form (pivot length), so structure appears with a small delay. Confirmed signals do not repaint. • The stats only use the chart history TradingView has loaded and candle open, high, low and close. They do not include spread, commission or slippage. • The news filter uses recurring release times because Pine Script cannot read the economic calendar. Add exact dates for more precision. • Past results do not guarantee future performance. This script is for educational purposes and is not financial advice.

## Source Code

````pine
//@version=6
// ============================================================================
//  Sweep -> BOS Zones  [pips_daily setup]
//  Liquidity sweep, break of structure, order-block zone, RR position box,
//  early-warning alerts and a win-rate table.
//
//  BULLISH: a confirmed swing low (liquidity) is taken by a lower low (sweep),
//           then price breaks above the structure high (BOS). The demand zone
//           runs from the sweep extreme up to the body high of the last bearish
//           candle at the sweep low. Entry = top of zone, SL = beyond the sweep
//           low (plus optional ATR buffer), TP = entry + RR x risk.
//  BEARISH: mirror image (sweep above a swing high, BOS below the structure low,
//           supply zone = last bullish candle at the sweep high).
//
//  Works on any timeframe and symbol: every distance is measured in ATR or in
//  zone height. Nothing is in fixed pips.
//
//  REPAINTING / LAG NOTES
//  * Swings are confirmed pivots (ta.pivothigh/pivotlow with left = right =
//    "Swing pivot length"). A pivot is only known "len" bars after it prints,
//    so a swing low that formed fewer than "len" bars ago is NOT yet treated
//    as liquidity. A very fast sweep of a brand-new low can be missed.
//  * Once a sweep, BOS, tap or result is recorded on a closed bar it never
//    changes. Close-based events (BOS in "Close" mode, close-based stop) are
//    only confirmed at bar close. Wick-based events (sweep, approach, tap,
//    TP/SL by wick) can fire intrabar on the live bar. Those wick events can't
//    be undone inside the bar because a high can only rise and a low can only fall.
//
//  STATS NOTES
//  * The win-rate table only covers the history loaded on the chart.
//  * It uses bar OHLC only, with no intrabar data. If SL and TP fall in the same
//    bar, the trade counts as a LOSS (conservative). A TP on the entry bar itself
//    is ignored because the order inside the bar is unknown, but an SL on the
//    entry bar counts as a loss.
//  * Zones that expire or are replaced before price enters them are not counted.
//    Trades that are still running are shown as "Open".
//  * Each triggered trade is tracked at TWO targets with the same entry and SL:
//    2R and 3R. They are scored separately, so the table compares win rates at each.
//    The position box and markers use the "Risk : Reward" input (default 1:2).
// ============================================================================
indicator("Sweep → BOS Zones [pips_daily]", shorttitle = "Sweep BOS Zones", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 500)

// ---------------------------------------------------------------- Inputs ----
grpS = "Structure"
pivotLen     = input.int(5, "Swing pivot length (left = right bars)", minval = 1, maxval = 50, group = grpS, tooltip = "Bars on each side needed to confirm a swing. Higher = fewer, bigger swings, but more confirmation lag.")
bosSrc       = input.string("Close", "BOS confirmation", options = ["Close", "Wick"], group = grpS, tooltip = "Close: a candle must CLOSE beyond the structure level (confirmed at bar close). Wick: any trade beyond the level counts (earlier, but noisier).")
bosRef       = input.string("Structure swing", "BOS level", options = ["Structure swing", "Latest swing"], group = grpS, tooltip = "Structure swing: the extreme between the liquidity swing and the sweep (as in the reference charts). Latest swing: the most recent confirmed opposite pivot.")
maxSweepBars = input.int(50, "Max bars from sweep to BOS", minval = 1, maxval = 300, group = grpS, tooltip = "Drop the 'BOS watch' if structure doesn't break within this many bars.")
obLookback   = input.int(5, "Order-block lookback (bars before sweep extreme)", minval = 0, maxval = 20, group = grpS)
zoneEdge     = input.string("Body", "Zone proximal edge", options = ["Body", "Wick"], group = grpS, tooltip = "Body: zone runs from the sweep extreme to the order-block candle's body. Wick: to its high (bull) / low (bear).")

grpZ = "Zones & alerts"
apprMode     = input.string("ATR multiple", "Approach distance mode", options = ["ATR multiple", "% of zone height"], group = grpZ)
apprAtr      = input.float(0.5, "Approach distance (x ATR)", minval = 0, step = 0.1, group = grpZ)
apprPct      = input.float(50.0, "Approach distance (% of zone height)", minval = 0, step = 5, group = grpZ)
atrLen       = input.int(14, "ATR length", minval = 1, group = grpZ)
expiryBars   = input.int(100, "Expire untapped zone after N bars", minval = 1, maxval = 5000, group = grpZ)
maxActive    = input.int(5, "Max active zones", minval = 1, maxval = 50, group = grpZ)
maxHistory   = input.int(30, "Finished zones kept on chart", minval = 0, maxval = 100, group = grpZ)
intrabarAl   = input.bool(true, "Early (intrabar) alerts for sweep / approach / tap / TP / SL", group = grpZ, tooltip = "On: alert() fires the moment it happens on the live bar. Off: alert() waits for bar close.")

grpP = "Position (risk / reward)"
showPos      = input.bool(true, "Show position box", group = grpP)
rr           = input.float(2.0, "Risk : Reward (1 : x)", minval = 2.0, step = 0.5, group = grpP, tooltip = "Target used for the position box, TP alerts and W/L markers. Minimum 1:2. The stats table always shows 1:2 AND 1:3 side by side.")
slBufAtr     = input.float(0.1, "Stop buffer beyond sweep (x ATR)", minval = 0, step = 0.05, group = grpP)
slMode       = input.string("Wick", "Stop-loss hit on", options = ["Wick", "Close"], group = grpP, tooltip = "Wick: SL counts as hit when price trades through it. Close: only when a candle closes beyond it.")
posWidth     = input.int(20, "Position box width (bars)", minval = 1, maxval = 400, group = grpP)

grpT = "Win-rate table"
showStats    = input.bool(true, "Show stats table", group = grpT)
showMarks    = input.bool(true, "Show win / loss markers", group = grpT)
tblSize      = input.string("Small", "Table text size", options = ["Tiny", "Small", "Normal"], group = grpT)

grpV = "Visuals"
showLabels   = input.bool(true, "Show labels", group = grpV)
showLiq      = input.bool(true, "Show liquidity & BOS lines", group = grpV)
bullCol      = input.color(color.new(#F2A93B, 60), "Demand zone", group = grpV)
bearCol      = input.color(color.new(#F2A93B, 60), "Supply zone", group = grpV)
mitCol       = input.color(color.new(#2962FF, 75), "Tapped (mitigated) zone", group = grpV)
deadCol      = input.color(color.new(#9E9E9E, 85), "Invalid / expired zone", group = grpV)
slCol        = input.color(color.new(#F2A93B, 75), "Stop-loss box", group = grpV)
tpCol        = input.color(color.new(#9598A1, 75), "Take-profit box", group = grpV)
lineCol      = input.color(color.new(#787B86, 0), "Liquidity / BOS line", group = grpV)
watchCol     = input.color(color.new(#2962FF, 0), "BOS watch line", group = grpV)
bullLblCol   = input.color(color.new(#089981, 0), "Bullish sweep label", group = grpV)
bearLblCol   = input.color(color.new(#F23645, 0), "Bearish sweep label", group = grpV)
txtCol       = input.color(color.new(#787B86, 0), "Box text", group = grpV)
winCol       = input.color(color.new(#089981, 0), "Win marker", group = grpV)
lossCol      = input.color(color.new(#F23645, 0), "Loss marker", group = grpV)

// ----------------------------------------------------------------- Types ----
type Zone
    bool  isBull
    float top
    float bottom
    float entry
    float stop
    float tp
    int   bosBar
    int   tapBar
    int   state      = 0       // 0 = fresh, 1 = tapped (trade open), 2 = finished
    bool  approached = false
    box   zBox
    box   slBox
    box   tpBox

type Side
    bool  isBull
    float liqLvl                // resting liquidity (latest confirmed swing)
    int   liqBar
    float structLvl             // opposite extreme since that swing
    int   structBar
    bool  swept      = false
    int   sweepBar
    float sweptLvl
    int   sweptLiqBar
    float bosLvl
    int   bosRefBar
    float ext                   // sweep extreme (lowest low / highest high since sweep)
    int   extBar
    line  watchLine
    label watchLbl
    label sweepLbl

// One triggered trade, scored at 2R and 3R (same entry and SL)
type Trade
    bool  isBull
    float entry
    float stop
    int   tapBar
    int   res2 = 0              // 0 = open, 1 = win, -1 = loss
    int   res3 = 0

type Stats
    int bullW2 = 0
    int bullL2 = 0
    int bearW2 = 0
    int bearL2 = 0
    int bullW3 = 0
    int bullL3 = 0
    int bearW3 = 0
    int bearL3 = 0

type Events
    array<string> keys
    array<string> msgs
    array<bool>   early
    bool bullSweep    = false
    bool bearSweep    = false
    bool bullBos      = false
    bool bearBos      = false
    bool bullApproach = false
    bool bearApproach = false
    bool bullTap      = false
    bool bearTap      = false
    bool bullInvalid  = false
    bool bearInvalid  = false
    bool bullWin      = false
    bool bearWin      = false

// ------------------------------------------------------------ Series data ----
float atrV       = ta.atr(atrLen)
float ph         = ta.pivothigh(high, pivotLen, pivotLen)
float pl         = ta.pivotlow(low, pivotLen, pivotLen)
// extremes of the "right side" bars of a pivot that confirms on this bar
float hiRight    = ta.highest(high, pivotLen)
int   hiRightBar = bar_index + ta.highestbars(high, pivotLen)
float loRight    = ta.lowest(low, pivotLen)
int   loRightBar = bar_index + ta.lowestbars(low, pivotLen)

var float lastPH    = na
var int   lastPHBar = na
var float lastPL    = na
var int   lastPLBar = na
if not na(ph)
    lastPH    := ph
    lastPHBar := bar_index - pivotLen
if not na(pl)
    lastPL    := pl
    lastPLBar := bar_index - pivotLen

string pfx = syminfo.ticker + " " + timeframe.period + ": "

// ------------------------------------------------------------- Functions ----
fmt(float v) =>
    str.tostring(v, format.mintick)

queue(Events ev, string key, string msg, bool early) =>
    array.push(ev.keys, key)
    array.push(ev.msgs, msg)
    array.push(ev.early, early)
    true

setPos(Zone z, int l, int r) =>
    if not na(z.slBox)
        box.set_left(z.slBox, l)
        box.set_right(z.slBox, r)
    if not na(z.tpBox)
        box.set_left(z.tpBox, l)
        box.set_right(z.tpBox, r)
    true

deleteZone(Zone z) =>
    if not na(z.zBox)
        box.delete(z.zBox)
    if not na(z.slBox)
        box.delete(z.slBox)
    if not na(z.tpBox)
        box.delete(z.tpBox)
    true

// Finish a zone: stop extending it, recolour it and tidy the position boxes.
retireZone(Zone z, string why, color col, bool killPos) =>
    z.state := 2
    if not na(z.zBox)
        box.set_extend(z.zBox, extend.none)
        box.set_right(z.zBox, bar_index)
        box.set_bgcolor(z.zBox, col)
        box.set_border_color(z.zBox, col)
        if showLabels
            box.set_text(z.zBox, (z.isBull ? "Demand · " : "Supply · ") + why)
    if killPos
        if not na(z.slBox)
            box.delete(z.slBox)
        if not na(z.tpBox)
            box.delete(z.tpBox)
    else
        int r = math.max(bar_index, nz(z.tapBar, bar_index) + 1)
        if not na(z.slBox)
            box.set_right(z.slBox, r)
        if not na(z.tpBox)
            box.set_right(z.tpBox, r)
    true

countActive(array<Zone> zones) =>
    int c = 0
    int n = array.size(zones)
    if n > 0
        for i = 0 to n - 1
            Zone z = array.get(zones, i)
            if z.state < 2
                c += 1
    c

// Make room for a new zone: retire the oldest live zones above the cap.
// (Stats keep tracking an open trade even if its zone drawing is retired.)
enforceMax(array<Zone> zones) =>
    int excess = countActive(zones) - maxActive + 1
    int n = array.size(zones)
    if excess > 0 and n > 0
        for i = 0 to n - 1
            Zone z = array.get(zones, i)
            if excess > 0 and z.state < 2
                retireZone(z, "replaced", deadCol, true)
                excess -= 1
    excess

trimHistory(array<Zone> zones) =>
    while array.size(zones) > maxActive + maxHistory
        Zone old = array.shift(zones)
        deleteZone(old)
    true

// Run the sweep -> BOS state machine for one side (bull or bear).
// Bull: liquidity = swing lows, structure = highs. Bear: the mirror image.
processSide(Side s, array<Zone> zones, Events ev, float newPiv, float rightExt, int rightExtBar, float lastOpp, int lastOppBar) =>
    bool   b  = s.isBull
    string dn = b ? "Bullish" : "Bearish"

    // 1) SWEEP of resting liquidity (confirmed pivots only).
    //    While waiting for BOS, a sweep of a NEWER swing at or beyond the current
    //    extreme (trend continuation) re-arms the setup with the newer structure.
    if not na(s.liqLvl)
        bool took  = b ? low < s.liqLvl : high > s.liqLvl
        bool rearm = not s.swept or (b ? s.liqLvl <= s.ext : s.liqLvl >= s.ext)
        if took and rearm
            if s.swept
                if not na(s.watchLine)
                    line.delete(s.watchLine)
                if not na(s.watchLbl)
                    label.delete(s.watchLbl)
            bool useLatest = bosRef == "Latest swing" and not na(lastOpp) and (b ? lastOpp > s.liqLvl : lastOpp < s.liqLvl)
            s.swept       := true
            s.sweepBar    := bar_index
            s.sweptLvl    := s.liqLvl
            s.sweptLiqBar := s.liqBar
            s.bosLvl      := useLatest ? lastOpp : s.structLvl
            s.bosRefBar   := useLatest ? lastOppBar : s.structBar
            s.ext         := b ? low : high
            s.extBar      := bar_index
            s.liqLvl      := na
            s.watchLine   := na
            s.watchLbl    := na
            s.sweepLbl    := na
            if showLiq
                line.new(s.sweptLiqBar, s.sweptLvl, bar_index, s.sweptLvl, color = lineCol, width = 1)
                s.watchLine := line.new(s.bosRefBar, s.bosLvl, bar_index, s.bosLvl, color = watchCol, style = line.style_dashed, width = 1, extend = extend.right)
            if showLabels
                s.sweepLbl := label.new(bar_index, b ? low : high, "Liquidity sweep", color = b ? bullLblCol : bearLblCol, style = b ? label.style_label_up : label.style_label_down, textcolor = color.white, size = size.small)
                s.watchLbl := label.new(bar_index, s.bosLvl, "BOS watch", color = color.new(color.black, 100), style = b ? label.style_label_down : label.style_label_up, textcolor = watchCol, size = size.small)
            if b
                ev.bullSweep := true
            else
                ev.bearSweep := true
            queue(ev, b ? "SWB" : "SWS", pfx + dn + " liquidity sweep of " + fmt(s.sweptLvl) + ". Setup may be forming. BOS watch level: " + fmt(s.bosLvl), intrabarAl)

    // 2) Track the sweep extreme
    if s.swept and bar_index > s.sweepBar
        if b ? low < s.ext : high > s.ext
            s.ext    := b ? low : high
            s.extBar := bar_index

    // 3) BOS -> build the zone and the position box
    if s.swept
        bool brkW = b ? high > s.bosLvl : low < s.bosLvl
        bool brkC = b ? close > s.bosLvl : close < s.bosLvl
        bool brk  = bosSrc == "Wick" ? brkW : (brkC and barstate.isconfirmed)
        if brk
            // order block = last opposite-colour candle at/just before the sweep extreme
            int k     = bar_index - s.extBar
            int obOff = k
            for i = k to k + obLookback
                if b ? close[i] < open[i] : close[i] > open[i]
                    obOff := i
                    break
            float bodyEdge = b ? math.max(open[obOff], close[obOff]) : math.min(open[obOff], close[obOff])
            float wickEdge = b ? high[obOff] : low[obOff]
            float edge     = zoneEdge == "Body" ? bodyEdge : wickEdge
            if b ? edge <= s.ext : edge >= s.ext
                edge := wickEdge
            float zTop   = b ? edge : s.ext
            float zBot   = b ? s.ext : edge
            bool  okZone = zTop > zBot and (b ? zTop < s.bosLvl : zBot > s.bosLvl)
            float buf    = nz(atrV) * slBufAtr
            float entry  = b ? zTop : zBot
            float stop   = b ? zBot - buf : zTop + buf
            float risk   = math.abs(entry - stop)
            float tp     = b ? entry + rr * risk : entry - rr * risk
            int   left   = bar_index - obOff

            if not na(s.watchLine)
                line.set_x2(s.watchLine, bar_index)
                line.set_extend(s.watchLine, extend.none)
                line.set_style(s.watchLine, line.style_solid)
                line.set_color(s.watchLine, lineCol)
            if not na(s.watchLbl)
                label.set_text(s.watchLbl, "BOS")
                label.set_textcolor(s.watchLbl, lineCol)
                label.set_x(s.watchLbl, math.round((s.bosRefBar + bar_index) / 2))

            if okZone and risk > 0
                enforceMax(zones)
                color zc = b ? bullCol : bearCol
                box zb = box.new(left, zTop, bar_index, zBot, border_color = zc, border_width = 1, bgcolor = zc, extend = extend.right, text = showLabels ? (b ? "Demand" : "Supply") : "", text_color = txtCol, text_size = size.small, text_halign = text.align_left, text_valign = b ? text.align_bottom : text.align_top)
                box slb = na
                box tpb = na
                if showPos
                    slb := box.new(bar_index + 1, b ? entry : stop, bar_index + 1 + posWidth, b ? stop : entry, border_color = slCol, border_width = 1, bgcolor = slCol, text = showLabels ? "SL " + fmt(stop) : "", text_color = txtCol, text_size = size.small)
                    tpb := box.new(bar_index + 1, b ? tp : entry, bar_index + 1 + posWidth, b ? entry : tp, border_color = tpCol, border_width = 1, bgcolor = tpCol, text = showLabels ? "TP " + fmt(tp) + " (1:" + str.tostring(rr) + ")" : "", text_color = txtCol, text_size = size.small)
                Zone z = Zone.new(isBull = b, top = zTop, bottom = zBot, entry = entry, stop = stop, tp = tp, bosBar = bar_index, zBox = zb, slBox = slb, tpBox = tpb)
                array.push(zones, z)
                trimHistory(zones)
                if b
                    ev.bullBos := true
                else
                    ev.bearBos := true
                queue(ev, b ? "BOSB" : "BOSS", pfx + dn + " BOS through " + fmt(s.bosLvl) + ". " + (b ? "Demand" : "Supply") + " zone " + fmt(zBot) + " - " + fmt(zTop) + ". Entry " + fmt(entry) + ", SL " + fmt(stop) + ", TP " + fmt(tp) + " (1:" + str.tostring(rr) + ")", intrabarAl and bosSrc == "Wick")

            s.swept     := false
            s.watchLine := na
            s.watchLbl  := na
            s.sweepLbl  := na
        else if bar_index - s.sweepBar >= maxSweepBars
            // no BOS in time: drop the watch
            if not na(s.watchLine)
                line.delete(s.watchLine)
            if not na(s.watchLbl)
                label.delete(s.watchLbl)
            if not na(s.sweepLbl)
                label.set_text(s.sweepLbl, "Sweep (no BOS)")
                label.set_color(s.sweepLbl, color.new(#9E9E9E, 30))
            s.swept     := false
            s.watchLine := na
            s.watchLbl  := na
            s.sweepLbl  := na

    // 4) Pivot bookkeeping. This runs after the sweep check, and a bar can't
    //    sweep the pivot it confirms because the right-side bars never pass the pivot.
    if not na(newPiv)
        s.liqLvl    := newPiv
        s.liqBar    := bar_index - pivotLen
        s.structLvl := rightExt
        s.structBar := rightExtBar
    else if not na(s.structLvl)
        if b ? high > s.structLvl : low < s.structLvl
            s.structLvl := b ? high : low
            s.structBar := bar_index
    s.swept

// Manage live zones: approach -> tap (entry) -> TP / SL, expiry and stats.
manageZones(array<Zone> zones, array<Trade> trades, Events ev) =>
    int n = array.size(zones)
    if n > 0
        for i = 0 to n - 1
            Zone z = array.get(zones, i)
            if z.state < 2 and bar_index > z.bosBar
                bool   b    = z.isBull
                string nm   = b ? "Demand" : "Supply"
                float  dist = apprMode == "ATR multiple" ? nz(atrV) * apprAtr : (z.top - z.bottom) * apprPct / 100.0
                bool touched = b ? low <= z.top : high >= z.bottom
                bool near    = b ? low <= z.top + dist : high >= z.bottom - dist

                // A) early warning: price is close to the zone but hasn't touched it yet
                if z.state == 0 and not z.approached and near and not touched
                    z.approached := true
                    if b
                        ev.bullApproach := true
                    else
                        ev.bearApproach := true
                    queue(ev, "AP" + str.tostring(z.bosBar) + nm, pfx + "Price approaching " + nm + " zone " + fmt(z.bottom) + " - " + fmt(z.top) + " (entry " + fmt(z.entry) + ")", intrabarAl)

                // B) tap = entry triggered
                if z.state == 0 and touched
                    z.state  := 1
                    z.tapBar := bar_index
                    box.set_bgcolor(z.zBox, mitCol)
                    box.set_border_color(z.zBox, mitCol)
                    if showLabels
                        box.set_text(z.zBox, nm + " · tapped")
                    setPos(z, bar_index, bar_index + posWidth)
                    array.push(trades, Trade.new(isBull = b, entry = z.entry, stop = z.stop, tapBar = bar_index))
                    if b
                        ev.bullTap := true
                    else
                        ev.bearTap := true
                    queue(ev, "TAP" + str.tostring(z.bosBar) + nm, pfx + nm + " zone tapped. Entry " + fmt(z.entry) + ", SL " + fmt(z.stop) + ", TP " + fmt(z.tp), intrabarAl)
                else if z.state == 0
                    // keep the planned position box just ahead of price
                    setPos(z, bar_index + 1, bar_index + 1 + posWidth)

                // C) outcome
                bool slW    = b ? low <= z.stop : high >= z.stop
                bool slC    = (b ? close < z.stop : close > z.stop) and barstate.isconfirmed
                bool slHit  = z.state == 1 and (slMode == "Wick" ? slW : slC)
                bool tpHit  = z.state == 1 and bar_index > z.tapBar and (b ? high >= z.tp : low <= z.tp)
                bool expire = z.state == 0 and bar_index - z.bosBar >= expiryBars
                if slHit
                    // SL first, or SL and TP in the same bar: LOSS (conservative)
                    retireZone(z, "SL hit", deadCol, false)
                    if b
                        ev.bullInvalid := true
                    else
                        ev.bearInvalid := true
                    if showMarks
                        label.new(bar_index, z.stop, "L  -1R", color = lossCol, style = b ? label.style_label_up : label.style_label_down, textcolor = color.white, size = size.tiny)
                    queue(ev, "SL" + str.tostring(z.bosBar) + nm, pfx + nm + " trade stopped / zone invalidated at " + fmt(z.stop) + " (-1R)", intrabarAl and slMode == "Wick")
                else if tpHit
                    retireZone(z, "TP hit", mitCol, false)
                    if b
                        ev.bullWin := true
                    else
                        ev.bearWin := true
                    if showMarks
                        label.new(bar_index, z.tp, "W  +" + str.tostring(rr) + "R", color = winCol, style = b ? label.style_label_down : label.style_label_up, textcolor = color.white, size = size.tiny)
                    queue(ev, "TP" + str.tostring(z.bosBar) + nm, pfx + nm + " trade hit TP " + fmt(z.tp) + " (+" + str.tostring(rr) + "R)", intrabarAl)
                else if expire
                    retireZone(z, "expired", deadCol, true)
                    queue(ev, "EX" + str.tostring(z.bosBar) + nm, pfx + nm + " zone " + fmt(z.bottom) + " - " + fmt(z.top) + " expired untouched", false)
                else if z.state == 1 and not na(z.slBox)
                    // trade still running: stretch the position box with price
                    if bar_index > box.get_right(z.slBox)
                        setPos(z, z.tapBar, bar_index)
    n

// Score every triggered trade at 2R and 3R. Uses bar OHLC only. SL is checked
// first, so a bar that hits both SL and TP counts as a LOSS. A TP on the entry bar
// is ignored because the order inside the bar is unknown.
processTrades(array<Trade> trades, Stats st) =>
    int n = array.size(trades)
    if n > 0
        for i = n - 1 to 0
            Trade t = array.get(trades, i)
            bool  b    = t.isBull
            float risk = math.abs(t.entry - t.stop)
            float tp2  = b ? t.entry + 2.0 * risk : t.entry - 2.0 * risk
            float tp3  = b ? t.entry + 3.0 * risk : t.entry - 3.0 * risk
            bool  slW  = b ? low <= t.stop : high >= t.stop
            bool  slC  = (b ? close < t.stop : close > t.stop) and barstate.isconfirmed
            bool  sl   = slMode == "Wick" ? slW : slC
            bool  after = bar_index > t.tapBar
            if t.res2 == 0
                if sl
                    t.res2 := -1
                    if b
                        st.bullL2 := st.bullL2 + 1
                    else
                        st.bearL2 := st.bearL2 + 1
                else if after and (b ? high >= tp2 : low <= tp2)
                    t.res2 := 1
                    if b
                        st.bullW2 := st.bullW2 + 1
                    else
                        st.bearW2 := st.bearW2 + 1
            if t.res3 == 0
                if sl
                    t.res3 := -1
                    if b
                        st.bullL3 := st.bullL3 + 1
                    else
                        st.bearL3 := st.bearL3 + 1
                else if after and (b ? high >= tp3 : low <= tp3)
                    t.res3 := 1
                    if b
                        st.bullW3 := st.bullW3 + 1
                    else
                        st.bearW3 := st.bearW3 + 1
            if t.res2 != 0 and t.res3 != 0
                array.remove(trades, i)
    array.size(trades)

// ------------------------------------------------------------------ State ----
var array<Zone> zones = array.new<Zone>()
var Side  bullS = Side.new(isBull = true)
var Side  bearS = Side.new(isBull = false)
var array<Trade> trades = array.new<Trade>()
var Stats st    = Stats.new()
Events ev = Events.new(keys = array.new<string>(), msgs = array.new<string>(), early = array.new<bool>())

// Existing zones first, then new sweeps / BOS on this bar
manageZones(zones, trades, ev)
processTrades(trades, st)
processSide(bullS, zones, ev, pl, hiRight, hiRightBar, lastPH, lastPHBar)
processSide(bearS, zones, ev, ph, loRight, loRightBar, lastPL, lastPLBar)

// ----------------------------------------------------------------- Alerts ----
// alert() style: one "Any alert() function call" alert gets every event with
// full prices. Early events fire intrabar (deduplicated per bar with varip).
// Close-based events fire on the bar's last tick.
varip string sentKeys = ""
varip int    sentBar  = -1
if sentBar != bar_index
    sentKeys := ""
    sentBar  := bar_index
int nMsg = array.size(ev.msgs)
if nMsg > 0
    for i = 0 to nMsg - 1
        string key = "|" + array.get(ev.keys, i) + "|"
        if array.get(ev.early, i)
            if not str.contains(sentKeys, key)
                sentKeys := sentKeys + key
                alert(array.get(ev.msgs, i), alert.freq_all)
        else if barstate.isconfirmed
            alert(array.get(ev.msgs, i), alert.freq_all)

// alertcondition() style: pick these one by one in the Create Alert dialog.
bool aBullSweep    = ev.bullSweep
bool aBearSweep    = ev.bearSweep
bool aBullBos      = ev.bullBos
bool aBearBos      = ev.bearBos
bool aBullApproach = ev.bullApproach
bool aBearApproach = ev.bearApproach
bool aBullTap      = ev.bullTap
bool aBearTap      = ev.bearTap
bool aBullInvalid  = ev.bullInvalid
bool aBearInvalid  = ev.bearInvalid
bool aBullWin      = ev.bullWin
bool aBearWin      = ev.bearWin
alertcondition(aBullSweep,    "Bullish liquidity sweep",      "{{ticker}} {{interval}}: Bullish liquidity sweep. A setup may be forming. Watch the BOS level.")
alertcondition(aBearSweep,    "Bearish liquidity sweep",      "{{ticker}} {{interval}}: Bearish liquidity sweep. A setup may be forming. Watch the BOS level.")
alertcondition(aBullBos,      "Bullish BOS - demand zone",    "{{ticker}} {{interval}}: Bullish break of structure. New demand zone drawn.")
alertcondition(aBearBos,      "Bearish BOS - supply zone",    "{{ticker}} {{interval}}: Bearish break of structure. New supply zone drawn.")
alertcondition(aBullApproach, "Approaching demand zone",      "{{ticker}} {{interval}}: Price approaching the demand zone at {{close}}.")
alertcondition(aBearApproach, "Approaching supply zone",      "{{ticker}} {{interval}}: Price approaching the supply zone at {{close}}.")
alertcondition(aBullTap,      "Demand zone tapped",           "{{ticker}} {{interval}}: Demand zone tapped. Buy entry triggered.")
alertcondition(aBearTap,      "Supply zone tapped",           "{{ticker}} {{interval}}: Supply zone tapped. Sell entry triggered.")
alertcondition(aBullInvalid,  "Demand zone invalidated (SL)", "{{ticker}} {{interval}}: Demand zone invalidated. Stop-loss hit.")
alertcondition(aBearInvalid,  "Supply zone invalidated (SL)", "{{ticker}} {{interval}}: Supply zone invalidated. Stop-loss hit.")
alertcondition(aBullWin,      "Bullish trade hit TP",         "{{ticker}} {{interval}}: Bullish setup reached take-profit.")
alertcondition(aBearWin,      "Bearish trade hit TP",         "{{ticker}} {{interval}}: Bearish setup reached take-profit.")

// Hidden plot so the script always has a series output
plot(na, "hidden", display = display.none, editable = false)

// ------------------------------------------------------------ Stats table ----
// Columns: metric | 1:2 All | Bull | Bear | 1:3 All | Bull | Bear
fmtPct(int w, int t) =>
    t > 0 ? str.tostring(100.0 * w / t, "#.#") + "%" : "-"
fmtR(float r) =>
    (r > 0 ? "+" : "") + str.tostring(r, "#.##") + "R"
fmtAvg(float r, int t) =>
    t > 0 ? fmtR(r / t) : "-"

// Fill one column block (All / Bull / Bear) for one target
fillBlock(table tb, int col, int bW, int bL, int sW, int sL, float tgt, string sz, color tc) =>
    int   aW = bW + sW
    int   aL = bL + sL
    int   aT = aW + aL
    int   bT = bW + bL
    int   sT = sW + sL
    float aR = aW * tgt - aL
    float bR = bW * tgt - bL
    float sR = sW * tgt - sL
    array<int>   tr = array.from(aT, bT, sT)
    array<int>   ws = array.from(aW, bW, sW)
    array<int>   ls = array.from(aL, bL, sL)
    array<float> rs = array.from(aR, bR, sR)
    for j = 0 to 2
        int   c  = col + j
        float r  = array.get(rs, j)
        int   tt = array.get(tr, j)
        table.cell(tb, c, 2, str.tostring(tt), text_color = tc, text_size = sz)
        table.cell(tb, c, 3, str.tostring(array.get(ws, j)), text_color = winCol, text_size = sz)
        table.cell(tb, c, 4, str.tostring(array.get(ls, j)), text_color = lossCol, text_size = sz)
        table.cell(tb, c, 5, fmtPct(array.get(ws, j), tt), text_color = tc, text_size = sz)
        table.cell(tb, c, 6, fmtR(r), text_color = r >= 0 ? winCol : lossCol, text_size = sz)
        table.cell(tb, c, 7, fmtAvg(r, tt), text_color = tc, text_size = sz)
    true

var table tbl = table.new(position.top_right, 7, 9, bgcolor = color.new(#131722, 15), border_color = color.new(#787B86, 60), border_width = 1, frame_color = color.new(#787B86, 40), frame_width = 1)

if barstate.islast
    if showStats
        string sz = tblSize == "Tiny" ? size.tiny : tblSize == "Normal" ? size.normal : size.small
        color  hc = color.new(#F2A93B, 0)
        color  tc = color.white
        color  dc = color.new(color.white, 40)
        int open2 = 0
        int open3 = 0
        int nTr = array.size(trades)
        if nTr > 0
            for i = 0 to nTr - 1
                Trade t = array.get(trades, i)
                if t.res2 == 0
                    open2 += 1
                if t.res3 == 0
                    open3 += 1
        // header rows (no merged cells, so nothing breaks on realtime redraws)
        table.cell(tbl, 0, 0, "Sweep→BOS", text_color = hc, text_size = sz, text_halign = text.align_left)
        table.cell(tbl, 1, 0, "", text_size = sz)
        table.cell(tbl, 2, 0, "Target 1:2", text_color = hc, text_size = sz)
        table.cell(tbl, 3, 0, "", text_size = sz)
        table.cell(tbl, 4, 0, "", text_size = sz)
        table.cell(tbl, 5, 0, "Target 1:3", text_color = hc, text_size = sz)
        table.cell(tbl, 6, 0, "", text_size = sz)
        table.cell(tbl, 0, 1, "", text_size = sz)
        table.cell(tbl, 1, 1, "All",  text_color = hc, text_size = sz)
        table.cell(tbl, 2, 1, "Bull", text_color = hc, text_size = sz)
        table.cell(tbl, 3, 1, "Bear", text_color = hc, text_size = sz)
        table.cell(tbl, 4, 1, "All",  text_color = hc, text_size = sz)
        table.cell(tbl, 5, 1, "Bull", text_color = hc, text_size = sz)
        table.cell(tbl, 6, 1, "Bear", text_color = hc, text_size = sz)
        // row labels
        table.cell(tbl, 0, 2, "Trades",        text_color = tc, text_size = sz, text_halign = text.align_left)
        table.cell(tbl, 0, 3, "Wins",          text_color = tc, text_size = sz, text_halign = text.align_left)
        table.cell(tbl, 0, 4, "Losses",        text_color = tc, text_size = sz, text_halign = text.align_left)
        table.cell(tbl, 0, 5, "Win rate",      text_color = tc, text_size = sz, text_halign = text.align_left)
        table.cell(tbl, 0, 6, "Net R",         text_color = tc, text_size = sz, text_halign = text.align_left)
        table.cell(tbl, 0, 7, "Avg R / trade", text_color = tc, text_size = sz, text_halign = text.align_left)
        table.cell(tbl, 0, 8, "Open · B/E WR", text_color = dc, text_size = sz, text_halign = text.align_left)
        fillBlock(tbl, 1, st.bullW2, st.bullL2, st.bearW2, st.bearL2, 2.0, sz, tc)
        fillBlock(tbl, 4, st.bullW3, st.bullL3, st.bearW3, st.bearL3, 3.0, sz, tc)
        // footer: open trades and break-even win rate for each target
        table.cell(tbl, 1, 8, str.tostring(open2) + " open", text_color = dc, text_size = sz)
        table.cell(tbl, 2, 8, "B/E WR", text_color = dc, text_size = sz)
        table.cell(tbl, 3, 8, "33.3%", text_color = dc, text_size = sz)
        table.cell(tbl, 4, 8, str.tostring(open3) + " open", text_color = dc, text_size = sz)
        table.cell(tbl, 5, 8, "B/E WR", text_color = dc, text_size = sz)
        table.cell(tbl, 6, 8, "25.0%", text_color = dc, text_size = sz)
    else
        table.clear(tbl, 0, 0, 6, 8)
````
