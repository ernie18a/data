<!-- tradingview-pine-id: PUB;76c3652422f44e81b661108d776773d3 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Inside Bar [scriptedge]

Source: https://www.tradingview.com/script/lkPzIYiY-Inside-Bar-scriptedge/

## Description

Overview
Inside Bar looks for a higher timeframe candle that trades entirely within the range of the one before it. Throughout this description the larger candle is called the mother candle, the contained one is the inside bar, and the one that follows is the trading candle.

The indicator is designed so that the whole setup can be visualised from the lower timeframe you intend to trade. The higher timeframe is read in the background and its structure is drawn onto your chart, so there is no need to switch timeframes to see where the range sits or how the trading candle is developing.

The tool draws structure and context. It does not generate buy or sell signals, and it does not manage entries, exits, stops, or position size. Those decisions are left to the trader.

The Higher Timeframe Pattern
An inside bar is a two candle pattern. The second candle's high is at or below the first candle's high, and its low is at or above the first candle's low — the whole candle sits within the range of the one before it. That is compression. Range has contracted, and unlike most patterns it carries no direction of its own. Both boundaries of the mother candle are live, and the market decides which one matters.
[image]https://www.tradingview.com/x/nV18jFtj/[/image]
What Gets Drawn
Once the inside bar closes, the mother candle's high and low are drawn as solid lines. These are the levels a break has to clear, and they are what almost every published treatment of this pattern uses for entries and stops.

A shaded box spans the compression itself: from the mother candle through every inside bar, ending where the trading candle opens. The box shows the coil, the lines carry the levels forward through the trading candle.

Two target lines are projected at one times the mother candle's range, one above the high and one below the low. This is the measured move, the conventional objective for a range break. They are drawn from the trading candle's open, since that is when a target first becomes relevant. Every line stops when price trades through it, or when the trading candle ends, whichever comes first.
[image]https://www.tradingview.com/x/5cTcpdb3/[/image]
Nested Inside Bars
Inside bars often arrive in runs. When the trading candle turns out to be another inside bar — still entirely within the mother's range — the coil has not resolved, so nothing is reset. The mother candle's levels stay exactly where they are, the box extends, and the next candle takes over as the trading candle. A label on the box counts the inside bars whenever there is more than one, so a deep coil is visible at a glance.
[image]https://www.tradingview.com/x/vEgstf3V/[/image]
Higher Timeframe Panel
The mother candle, every inside bar and the trading candle are redrawn to the right of the live chart, with the mother's levels marked across them. The trading candle updates live. On a long coil the mother candle is often well off the left of your screen. The panel is what lets you see the whole pattern without scrolling or switching timeframes.

Stats Dashboard
The table counts how past breaks on the selected higher timeframe resolved. A break is recorded the moment price trades outside the mother candle's range during the trading candle.

[*]Breakout — after breaking, price reached the target before reaching the opposite boundary.
[*]Failed breakout — after breaking, price reached the opposite boundary first.

Those two levels sit exactly one mother range either side of the break, so this is a symmetrical test rather than an arbitrary pairing.

A trading candle can break both boundaries, in which case both breaks are counted separately with their own outcomes. Breaks that have not yet resolved are excluded until they do, and setups still coiling are not counted at all, so the two percentages always sum to one hundred.

There is deliberately no win rate here. A failed breakout is a losing outcome to one trader and the entire premise to another, and it is not the indicator's place to decide which.

Please read this table for what it is. It is a count of what price did on the bars loaded in your chart. It is not a backtest and not a strategy report. No entry price, exit price, stop, commission, or slippage is assumed, because the indicator does not place trades. Past behaviour of a market does not indicate future behaviour.
[image]https://www.tradingview.com/x/IeKqL8uA/[/image]
Settings

[*]Chart Theme — light or dark colour palette.
[*]Stats Dashboard — show or hide the table.
[*]Higher Timeframe — 15m, 1h, 4h, D, W or M.
[*]HTF Candle Separators — vertical line at each higher timeframe open.
[*]Show Target Lines — the measured move projections.

Alerts
An alert fires the first time price trades outside the mother candle's range in each direction, with a message naming the timeframe and the side, for example 1h inside bar broken up. A trading candle that breaks both boundaries produces two alerts. To use them, create an alert on the indicator and choose Any alert() function call as the condition.

Repainting
Historical bars are never restated. Specifically:

[*]Higher timeframe candles are built by aggregating completed chart bars, so the pattern is only known once the inside bar has closed. request.security() with lookahead is not used anywhere in the script.
[*]Levels come from candles that have already closed. Nothing is drawn at a price that could still change.
[*]A break occurs once price trades through a level, which cannot be undone within a bar — once price has traded outside the range it has traded outside the range.
[*]The box and the lines extend to the right as the trading candle progresses. That is a drawing being lengthened, not a value being changed.

Limitations

[*]The mother candle defines the levels. Some traders use the inside bar's own high and low instead, for a tighter trigger and smaller risk. This tool does not draw those.
[*]A break is any trade outside the range, wick or close. A candle that pokes through and closes back inside counts as a break. If you think of a break as requiring a close, the counts here will run higher than you expect.
[*]On the higher timeframe itself, target lines, the inside bar count and the stats table are not shown. There the trading candle is a single bar, which cannot say whether a break or its outcome came first. The pattern, its levels and the box are still drawn.
[*]Above the higher timeframe, nothing is drawn. Select a chart timeframe lower than the higher timeframe setting.
[*]The panel is capped at twelve candles. A coil deeper than that still tracks correctly, but the panel shows the mother candle and the most recent inside bars rather than all of them.
[*]Drawing objects are capped by the platform. On very long histories the oldest drawings will drop off the chart.
[*]The stats table depends on how much history your plan loads, so the counts will differ between account types on the same instrument.
[*]This is an indicator, not a strategy. It offers no entries, exits, stop levels, position sizing, or risk management, and makes no claim about profitability.

Disclaimer
This script is for informational and educational purposes only. It is not financial advice and not a recommendation to buy or sell anything. Trading involves substantial risk of loss. Test any tool thoroughly and make your own decisions.

---

## Source Code

````pine
//@version=6
indicator("Inside Bar [scriptedge]", overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ─────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────
G_STYLE = "STYLE"
G_SETUP = "SETUP"

theme     = input.string("Light", "Chart Theme", options = ["Light", "Dark"], group = G_STYLE, display = display.none,
     tooltip = "Matches the colours to a light or dark chart background.")
showStats = input.bool(true, "Stats Dashboard", group = G_STYLE, display = display.none,
     tooltip = "Table of how past breakouts resolved.")

htfSel    = input.string("1h", "Higher Timeframe", options = ["15m", "1h", "4h", "D", "W", "M"],
     group = G_SETUP, display = display.none,
     tooltip = "The timeframe the inside bar is read from.")
showSep   = input.bool(true, "HTF Candle Separators", group = G_SETUP, display = display.none,
     tooltip = "Vertical line marking where each higher timeframe candle opens.")
showTgt   = input.bool(true, "Show Target Lines", group = G_SETUP, display = display.none,
     tooltip = "Projects the mother candle's range from each of its boundaries.")

htf = switch htfSel
    "15m" => "15"
    "1h"  => "60"
    "4h"  => "240"
    "D"   => "D"
    "W"   => "W"
    => "M"

CND_W     = 3
CND_GAP   = 0
PANEL_X   = 10
MAX_PANEL = 12

int  chartSec = timeframe.in_seconds()
int  htfSec   = timeframe.in_seconds(htf)
bool tfBelow  = chartSec < htfSec
bool tfEqual  = chartSec == htfSec
bool tfAbove  = chartSec > htfSec

bool light = theme == "Light"
bullCol  = #4caf50
bearCol  = light ? #2d2d2d : #b0bec5
edgeCol  = light ? #000000 : #b0bec5
bordCol  = light ? #000000 : color.new(#000000, 100)
lvlCol   = light ? color.new(#000000, 20) : color.new(#ffffff, 20)
boxCol   = light ? color.new(#787b86, 85) : color.new(#b2b5be, 88)
tgtCol   = light ? #1565c0 : #42a5f5
sepCol   = light ? color.new(#000000, 80) : color.new(#ffffff, 80)
tblBg    = light ? color.new(#ffffff, 20) : color.new(#000000, 20)
tblTx    = light ? #000000 : #ffffff

// ─────────────────────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────────────────────
type HtfCandle
    float o
    float h
    float l
    float c
    int   startBar

type Brk
    bool  isUp
    float top
    float bot
    float tgtUp
    float tgtDn

type Setup
    float top
    float bot
    float tgtUp
    float tgtDn
    int   leftBar
    label depthLb    = na
    box   rangeBox   = na
    line  topLn      = na
    line  botLn      = na
    line  tgtUpLn    = na
    line  tgtDnLn    = na
    bool  topBroken  = false
    bool  botBroken  = false
    bool  tgtUpHit   = false
    bool  tgtDnHit   = false

// ─────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────
var HtfCandle        cur   = na
var HtfCandle        prevC = na
var array<HtfCandle> done  = array.new<HtfCandle>()
var Setup            setup = na

var array<HtfCandle> nest = array.new<HtfCandle>()

var array<Brk> brks     = array.new<Brk>()
var int        cntBo    = 0
var int        cntFail  = 0
var table      statTbl  = na

var array<box>   panelBoxes  = array.new<box>()
var array<line>  panelLines  = array.new<line>()
var array<label> panelLabels = array.new<label>()

// ─────────────────────────────────────────────────────────────
// Utilities
// ─────────────────────────────────────────────────────────────
clearPanel() =>
    if array.size(panelBoxes) > 0
        for i = 0 to array.size(panelBoxes) - 1
            box.delete(array.get(panelBoxes, i))
        array.clear(panelBoxes)
    if array.size(panelLines) > 0
        for i = 0 to array.size(panelLines) - 1
            line.delete(array.get(panelLines, i))
        array.clear(panelLines)
    if array.size(panelLabels) > 0
        for i = 0 to array.size(panelLabels) - 1
            label.delete(array.get(panelLabels, i))
        array.clear(panelLabels)
    int(0)

drawPanelCandle(int slot, float o, float h, float l, float c) =>
    int xs  = bar_index + PANEL_X + slot * (CND_W + CND_GAP)
    int xe  = xs + CND_W - 1
    int xc  = xs + (CND_W - 1) / 2
    color body = c >= o ? bullCol : bearCol
    array.push(panelLines, line.new(xc, l, xc, h, color = edgeCol, width = 1))
    float bt = math.max(o, c)
    float bb = math.min(o, c)
    if bt == bb
        array.push(panelLines, line.new(xs, bt, xe, bt, color = edgeCol, width = 2))
    else
        array.push(panelBoxes, box.new(xs, bt, xe, bb,
             border_color = bordCol, border_width = 1, bgcolor = body))
    int(0)

extendLines(Setup s, int b) =>
    if not s.topBroken
        line.set_x2(s.topLn, b)
    if not s.botBroken
        line.set_x2(s.botLn, b)
    if not s.tgtUpHit and not na(s.tgtUpLn)
        line.set_x2(s.tgtUpLn, b)
    if not s.tgtDnHit and not na(s.tgtDnLn)
        line.set_x2(s.tgtDnLn, b)
    int(0)

// ─────────────────────────────────────────────────────────────
// Build HTF Candles
// ─────────────────────────────────────────────────────────────
htfFlip = not tfAbove and timeframe.change(htf)

int endBar = tfEqual ? bar_index - 1 : bar_index

if htfFlip
    if showSep and tfBelow
        line.new(time, close, time, close + syminfo.mintick, xloc = xloc.bar_time,
             extend = extend.both, color = sepCol, style = line.style_dotted, width = 1)
    prevC := cur
    if not na(cur)
        array.push(done, cur)
        if array.size(done) > 20
            array.shift(done)
    cur := HtfCandle.new(open, high, low, close, bar_index)
else if not na(cur)
    cur.h := math.max(cur.h, high)
    cur.l := math.min(cur.l, low)
    cur.c := close

// ─────────────────────────────────────────────────────────────
// Nest And Expiry
// ─────────────────────────────────────────────────────────────
if htfFlip and not na(setup) and not na(prevC)
    if prevC.h <= setup.top and prevC.l >= setup.bot
        array.push(nest, prevC)
        box.set_right(setup.rangeBox, bar_index)
        int depth = array.size(nest) - 1
        if depth >= 2 and tfBelow
            int cx = int(math.floor((setup.leftBar + bar_index) / 2.0))
            if na(setup.depthLb)
                setup.depthLb := label.new(cx, setup.top, str.tostring(depth) + " inside bars",
                     style     = label.style_label_down,
                     color     = color.new(color.black, 100),
                     textcolor = lvlCol,
                     size      = size.small)
            else
                label.set_x(setup.depthLb, cx)
                label.set_text(setup.depthLb, str.tostring(depth) + " inside bars")
        if not na(setup.tgtUpLn)
            line.set_x1(setup.tgtUpLn, bar_index)
        if not na(setup.tgtDnLn)
            line.set_x1(setup.tgtDnLn, bar_index)
    else
        extendLines(setup, endBar)
        setup := na
        array.clear(nest)

// ─────────────────────────────────────────────────────────────
// Inside Bar Pattern
// ─────────────────────────────────────────────────────────────
if htfFlip and na(setup) and array.size(done) >= 2
    int n = array.size(done)
    HtfCandle mother = array.get(done, n - 2)
    HtfCandle inside = array.get(done, n - 1)
    if inside.h <= mother.h and inside.l >= mother.l
        float rng = mother.h - mother.l
        float tu  = mother.h + rng
        float td  = mother.l - rng
        bx = box.new(mother.startBar, mother.h, bar_index, mother.l,
             border_color = color.new(color.gray, 100), bgcolor = boxCol)
        l1 = line.new(mother.startBar, mother.h, bar_index, mother.h,
             color = lvlCol, style = line.style_solid, width = 2)
        l2 = line.new(mother.startBar, mother.l, bar_index, mother.l,
             color = lvlCol, style = line.style_solid, width = 2)
        line t1 = na
        line t2 = na
        if showTgt and tfBelow
            t1 := line.new(bar_index, tu, bar_index, tu,
                 color = tgtCol, style = line.style_solid, width = 1)
            t2 := line.new(bar_index, td, bar_index, td,
                 color = tgtCol, style = line.style_solid, width = 1)
        setup := Setup.new(mother.h, mother.l, tu, td, mother.startBar, rangeBox = bx, topLn = l1, botLn = l2, tgtUpLn = t1, tgtDnLn = t2)
        array.clear(nest)
        array.push(nest, mother)
        array.push(nest, inside)

// ─────────────────────────────────────────────────────────────
// Live Setup
// ─────────────────────────────────────────────────────────────
if not na(setup)
    if not setup.topBroken
        line.set_x2(setup.topLn, bar_index)
        if high > setup.top
            setup.topBroken := true
            alert(htfSel + " inside bar broken up.", alert.freq_once_per_bar)
            array.push(brks, Brk.new(true, setup.top, setup.bot, setup.tgtUp, setup.tgtDn))
    if not setup.botBroken
        line.set_x2(setup.botLn, bar_index)
        if low < setup.bot
            setup.botBroken := true
            alert(htfSel + " inside bar broken down.", alert.freq_once_per_bar)
            array.push(brks, Brk.new(false, setup.top, setup.bot, setup.tgtUp, setup.tgtDn))
    if not setup.tgtUpHit
        if not na(setup.tgtUpLn)
            line.set_x2(setup.tgtUpLn, bar_index)
        if high >= setup.tgtUp
            setup.tgtUpHit := true
    if not setup.tgtDnHit
        if not na(setup.tgtDnLn)
            line.set_x2(setup.tgtDnLn, bar_index)
        if low <= setup.tgtDn
            setup.tgtDnHit := true

// ─────────────────────────────────────────────────────────────
// Outcomes
// ─────────────────────────────────────────────────────────────
if tfBelow and array.size(brks) > 0
    for i = array.size(brks) - 1 to 0
        Brk bk = array.get(brks, i)
        float tgt  = bk.isUp ? bk.tgtUp : bk.tgtDn
        float fail = bk.isUp ? bk.bot : bk.top
        bool hitTgt  = bk.isUp ? high >= tgt : low <= tgt
        bool hitFail = bk.isUp ? low <= fail : high >= fail
        if hitTgt
            cntBo += 1
            array.remove(brks, i)
        else if hitFail
            cntFail += 1
            array.remove(brks, i)

// ─────────────────────────────────────────────────────────────
// Draw HTF Candles
// ─────────────────────────────────────────────────────────────
if barstate.islast and tfBelow and not na(cur)
    clearPanel()

    array<HtfCandle> show = array.new<HtfCandle>()
    if not na(setup) and array.size(nest) > 0
        int keep = math.min(array.size(nest), MAX_PANEL - 1)
        for i = array.size(nest) - keep to array.size(nest) - 1
            array.push(show, array.get(nest, i))
    else if array.size(done) >= 2
        array.push(show, array.get(done, array.size(done) - 2))
        array.push(show, array.get(done, array.size(done) - 1))
    array.push(show, cur)

    int slots = array.size(show)
    float pTop = na
    for i = 0 to slots - 1
        HtfCandle hc = array.get(show, i)
        drawPanelCandle(i, hc.o, hc.h, hc.l, hc.c)
        pTop := na(pTop) ? hc.h : math.max(pTop, hc.h)

    if not na(setup)
        int mx  = bar_index + PANEL_X + (CND_W - 1) / 2
        int tx  = bar_index + PANEL_X + (slots - 1) * (CND_W + CND_GAP)
        int txc = tx + (CND_W - 1) / 2
        int txe = tx + CND_W - 1
        array.push(panelLines, line.new(mx, setup.top,
             setup.topBroken ? txc : txe, setup.top,
             color = lvlCol, style = line.style_solid, width = 2))
        array.push(panelLines, line.new(mx, setup.bot,
             setup.botBroken ? txc : txe, setup.bot,
             color = lvlCol, style = line.style_solid, width = 2))

    int pxc = bar_index + PANEL_X + int(math.floor((slots * (CND_W + CND_GAP) - CND_GAP - 1) / 2.0))
    array.push(panelLabels, label.new(pxc, pTop, htfSel + " timeframe",
         style     = label.style_label_down,
         color     = color.new(color.black, 100),
         textcolor = edgeCol,
         size      = size.normal))

// ─────────────────────────────────────────────────────────────
// Stats Dashboard
// ─────────────────────────────────────────────────────────────
statRow(int row, string lbl, string val, string pct) =>
    table.cell(statTbl, 0, row, lbl, text_size = size.small,
         text_color = tblTx, text_halign = text.align_left)
    table.cell(statTbl, 1, row, val, text_size = size.small,
         text_color = tblTx, text_halign = text.align_right)
    table.cell(statTbl, 2, row, pct, text_size = size.small,
         text_color = tblTx, text_halign = text.align_right)
    int(0)

if showStats and tfBelow and barstate.islast
    if na(statTbl)
        statTbl := table.new(position.top_right, 3, 3, bgcolor = tblBg,
             border_width = 3, border_color = color.new(color.gray, 100))
    int tot = cntBo + cntFail
    statRow(0, htfSel + " breaks", "", "")
    statRow(1, "Breakout", str.tostring(cntBo),
         tot > 0 ? str.tostring(math.round(100.0 * cntBo / tot)) + "%" : "-")
    statRow(2, "Failed breakout", str.tostring(cntFail),
         tot > 0 ? str.tostring(math.round(100.0 * cntFail / tot)) + "%" : "-")
````
