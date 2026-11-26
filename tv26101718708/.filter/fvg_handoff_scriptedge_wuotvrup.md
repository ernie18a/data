# FVG Handoff [scriptedge]

- url: https://www.tradingview.com/script/wUOtVrUP-FVG-Handoff-scriptedge/
- type: indicator
- pine_id: PUB;616416bbfe6445b69b566276f5b65f1e
- version: 1.0

## Description

[b]Overview[/b]
FVG Handoff looks for a fair value gap on a higher timeframe, then waits to see whether price returns to that gap on the very next higher timeframe candle. Throughout this description the three candles that form the gap are called the [b]context candles[/b], and the one after them is the [b]trading candle[/b].

The indicator is designed so that the whole setup can be visualised from the lower timeframe you intend to trade. The higher timeframe is read in the background and its structure is drawn onto your chart, so there is no need to switch timeframes to see where the gap sits or how the trading candle is developing. Any confirmation the indicator marks is one that occurred on your own chart timeframe, within the span of the trading candle.
[image]https://www.tradingview.com/x/XfbZbKIN/[/image]
The tool draws structure and context. It does not generate buy or sell signals, and it does not manage entries, exits, stops, or position size. Those decisions are left to the trader.

[b]The Higher Timeframe Pattern[/b]
A fair value gap is a three candle pattern where the first and third context candles do not overlap.
[list]
[*][b]Bullish:[/b] the low of the third context candle is above the high of the first, and the middle one closes up.
[*][b]Bearish:[/b] the high of the third context candle is below the low of the first, and the middle one closes down.
[/list]
The gap between the first and third context candles is the zone. It is drawn on your chart as a shaded box.
[image]https://www.tradingview.com/x/CidrGjVv/[/image]
The [b]target[/b] is the furthest extreme of the second and third context candles — the highest high on a bullish pattern, the lowest low on a bearish one. The second is the impulse candle and often overshoots the third, which is why both are considered rather than the third alone.
[image]https://www.tradingview.com/x/Nn7AmIR4/[/image]
[b]Why Only The Next Candle[/b]
Most fair value gap tools keep a gap on the chart indefinitely and mark it whenever price eventually returns, which can be days later. This indicator only considers the [b]immediately following higher timeframe candle[/b] — the trading candle.

Everything happens within it:
[list]
[*]If price never trades into the zone during the trading candle, the setup is discarded and its drawings are removed from the chart.
[*]If price reaches the target before it reaches the zone, the setup is discarded — there is nowhere left for it to go.
[image]https://www.tradingview.com/x/vLDACwZQ/[/image]
[*]If price trades into the zone during the trading candle, the setup becomes active and the zone is shaded more strongly.
[image]https://www.tradingview.com/x/I8rhfh2j/[/image]
[/list]
This is a deliberate narrowing, not an oversight. It selects for gaps that the market reacts to immediately rather than gaps that happen to be revisited much later.

[b]Lower Timeframe Confirmations[/b]
Once the zone has been tapped, the indicator looks for a confirmation on your chart timeframe, within the trading candle. Each type fires at most once per setup, and each can be turned on or off independently.

[b]FVG[/b] — a fair value gap in the same direction as the setup forming on the chart timeframe, in other words price leaving the higher timeframe zone with a gap of its own. Drawn as a box over the three candles that formed it.
[image]https://www.tradingview.com/x/X4KyNuMn/[/image]
[b]IFVG[/b] — a gap in the [i]opposite[/i] direction that price then closes back through, inverting it. A bullish setup looks for a bearish gap that price closes above; a bearish setup looks for a bullish gap that price closes below. The gap being inverted may have formed before the trading candle opened, so long as it is no older than the extreme that started the retracement. Drawn at its own original location, which can sit well to the left.
[image]https://www.tradingview.com/x/9A0ZDC76/[/image]
[b]MSS[/b] — a market structure shift. The indicator tracks swing highs and lows on the chart timeframe. When the last three swings form a high, low, high sequence and price then closes below that low, a line is drawn from the broken swing to the candle that closed through it. On a bullish setup the mirror applies. If the third swing also exceeded the first, taking out its level beforehand, a second line marks that swept level. An MSS is only marked if the level being broken is still short of the target, and only once per setup.
[image]https://www.tradingview.com/x/iXjkXjHP/[/image]
[b]What Is Drawn[/b]
[list]
[*][b]Zone[/b] — a grey box spanning the HTF FVG. Lightly shaded while untouched, more strongly shaded once price has traded into it.
[*][b]Target line[/b] — a dashed line from the bar that made the extreme, ending at the candle that reaches the target or at the end of the trading candle, whichever comes first.
[*][b]Confirmation boxes[/b] — FVG in blue, IFVG in cyan, each labelled and extended until candles clear them.
[*][b]MSS lines[/b] — a solid line for the broken swing and a dotted line for the swept level.
[*][b]Higher timeframe panel[/b] — the three context candles and the trading candle redrawn to the right of the live chart, with the gap marked across them and the target line running through. The trading candle updates live. This lets you see the higher timeframe structure without switching timeframes.
[*][b]Separators[/b] — a vertical line at the open of each higher timeframe candle.
[*][b]EMA[/b] — drawn only across the span of a setup rather than continuously.
[/list]
[b]Stats Dashboard[/b]
The table counts how past setups on the selected higher timeframe resolved:
[list]
[*][b]Tap to target[/b] — price traded into the zone during the trading candle, and later reached the target without a higher timeframe candle first closing through the far side of the gap.
[*][b]Tap to fail[/b] — price traded into the zone during the trading candle, but a higher timeframe candle closed through the far side of the gap before the target was reached.
[*][b]No setup[/b] — the zone was never tapped during the trading candle, or the target was taken before price returned.
[*][b]Hit rate[/b] — the first figure as a percentage of the first two.
[/list]
Please read this table for what it is. It is a count of what price did on the bars loaded in your chart. It is [b]not[/b] a backtest and [b]not[/b] a strategy report. No entry price, exit price, stop, commission, or slippage is assumed, because the indicator does not place trades. Outcomes still open — neither target reached nor gap invalidated — are excluded from all counts, so the figures move as those resolve. Past behaviour of a market does not indicate future behaviour.

[b]Settings[/b]
[list]
[*][b]Chart Theme[/b] — light or dark colour palette.
[*][b]Stats Dashboard[/b] — show or hide the table.
[*][b]Higher Timeframe[/b] — 15m, 1h, 4h, D, W or M.
[*][b]HTF Candle Separators[/b] — vertical line at each higher timeframe open.
[*][b]Show FVG / Show IFVG / Show MSS[/b] — confirmation types, independently toggled.
[*][b]Show EMA / EMA Length[/b] — optional EMA across the setup.
[/list]
[b]Alerts[/b]
One alert fires when a zone is first tapped during the trading candle, with a message naming the timeframe and direction, for example [i]1h bullish FVG tapped.[/i] It fires at most once per setup. To use it, create an alert on the indicator and choose [b]Any alert() function call[/b] as the condition.

[b]Repainting[/b]
Historical bars are never restated. Specifically:
[list]
[*]Higher timeframe candles are built by aggregating completed chart bars, so a pattern is only known once its third candle has closed. [i]request.security()[/i] with lookahead is not used anywhere in the script.
[*]All detection runs on confirmed bars. A condition that appears mid-bar and is gone by the close never registers.
[*]Drawings are placed on the bar where the event actually occurred, even when the event only becomes knowable a bar or two later. Detection timing affects when a drawing appears, never where.
[/list]
There is one deliberate removal, and it is worth stating plainly: [b]a zone that price never trades into during the trading candle is deleted when that candle closes.[/b] This keeps the chart to setups that actually became live, but it does mean you will not see discarded gaps when scrolling back. The stats table counts them under "No setup".

The zone box, the target line and confirmation boxes extend to the right as the trading candle progresses. That is a drawing being lengthened, not a value being changed.

[b]Limitations[/b]
[list]
[*][b]Only the next candle is considered.[/b] A gap that price returns to two or more candles later is ignored by design. If you want every gap tracked indefinitely, this is not the tool for that.
[*][b]On the higher timeframe itself,[/b] the trading candle is a single bar. Its open, high, low and close cannot say whether price tapped the zone before or after it reached the target. Lower timeframe confirmations, the target line and the stats table are therefore not shown when your chart timeframe equals the selected higher timeframe. Only the gap is drawn there.
[*][b]Above the higher timeframe,[/b] nothing is drawn. Select a chart timeframe lower than the higher timeframe setting.
[*][b]Swing detection for MSS uses a fixed strength of one bar[/b] either side. This is intentional, because the structure being measured sits inside a single higher timeframe candle, but it is sensitive and will pick up minor swings.
[*][b]A pivot needs one bar to confirm,[/b] so an MSS occurring on the last bar of the trading candle is detected a bar late. The line is still drawn at the correct candle.
[*][b]Drawing objects are capped by the platform.[/b] On very long histories the oldest drawings will drop off the chart.
[*][b]The stats table depends on how much history your plan loads,[/b] so the counts will differ between account types on the same instrument.
[*][b]This is an indicator, not a strategy.[/b] It offers no entries, exits, stop levels, position sizing, or risk management, and makes no claim about profitability.
[/list]
[b]Disclaimer[/b]
This script is for informational and educational purposes only. It is not financial advice and not a recommendation to buy or sell anything. Trading involves substantial risk of loss. Test any tool thoroughly and make your own decisions.

## Source Code

````pine
//@version=6

indicator("FVG Handoff [scriptedge]", overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500,
     max_polylines_count = 100, max_bars_back = 500)

// ─────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────
G_STYLE = "STYLE"
G_SETUP = "SETUP"
G_CONF  = "CONFIRMATIONS"
G_EMA   = "EMA"

theme     = input.string("Light", "Chart Theme", options = ["Light", "Dark"], group = G_STYLE, display = display.none,
     tooltip = "Matches the colours to a light or dark chart background.")
showStats = input.bool(true, "Stats Dashboard", group = G_STYLE, display = display.none,
     tooltip = "Table of how past setups resolved.")

htfSel    = input.string("1h", "Higher Timeframe", options = ["15m", "1h", "4h", "D", "W", "M"],
     group = G_SETUP, display = display.none,
     tooltip = "The timeframe the fair value gap is read from.")
showSep   = input.bool(true, "HTF Candle Separators", group = G_SETUP, display = display.none,
     tooltip = "Vertical line marking where each higher timeframe candle opens.")

showFvg   = input.bool(true, "Show FVG", group = G_CONF, display = display.none,
     tooltip = "Marks a fair value gap forming on the chart timeframe.")
showIfvg  = input.bool(false, "Show IFVG", group = G_CONF, display = display.none,
     tooltip = "Marks a fair value gap that price has closed back through.")
showMss   = input.bool(false, "Show MSS", group = G_CONF, display = display.none,
     tooltip = "Marks a swing level broken by a close, and the level swept beforehand.")

showEma   = input.bool(false, "Show EMA", group = G_EMA, display = display.none,
     tooltip = "Plots an EMA across the setup.")
emaLen    = input.int(9, "EMA Length", minval = 1, maxval = 500, group = G_EMA, display = display.none,
     tooltip = "Number of bars used in the EMA.")

htf = switch htfSel
    "15m" => "15"
    "1h"  => "60"
    "4h"  => "240"
    "D"   => "D"
    "W"   => "W"
    => "M"

CND_W    = 3
CND_GAP  = 0
PANEL_X  = 10

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
zoneFill = light ? color.new(#787b86, 88) : color.new(#b2b5be, 90)
zoneFillOn = light ? color.new(#787b86, 70) : color.new(#b2b5be, 78)
fvgCol   = light ? #1565c0 : #42a5f5
ifvgCol  = light ? #00acc1 : #4dd0e1
tgtCol   = light ? color.new(#000000, 20) : color.new(#ffffff, 20)
sepCol   = light ? color.new(#000000, 80) : color.new(#ffffff, 80)
emaCol   = light ? color.new(#000000, 45) : color.new(#ffffff, 45)
mssCol   = light ? color.new(#000000, 10) : color.new(#ffffff, 10)
tblBg    = light ? color.new(#ffffff, 20) : color.new(#000000, 20)
tblTx    = light ? #000000 : #ffffff
tblDim   = light ? color.new(#000000, 45) : color.new(#ffffff, 45)

// ─────────────────────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────────────────────
type HtfCandle
    float o
    float h
    float l
    float c
    int   startBar
    int   highBar
    int   lowBar

type Setup
    bool  isBull
    float zNear
    float zFar
    float target
    int   targetBar
    bool  armed     = false
    bool  voided    = false
    bool  fvgDone   = false
    bool  ifvgDone  = false
    bool  tgtHit    = false
    int   armedBar  = na
    bool  mssDone   = false
    box   zoneBox   = na
    line  tgtLine   = na

type Pending
    bool  isBull
    float farEdge
    float target

type ConfDraw
    box   bx      = na
    label lb      = na
    float top     = na
    float bot     = na
    bool  growing = false
    int   clear   = 0

type Swing
    float price
    int   bar
    bool  isHigh

// ─────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────
var HtfCandle        cur   = na
var HtfCandle        prevC = na
var array<HtfCandle> done  = array.new<HtfCandle>()
var Setup            setup = na

var array<Pending> pend = array.new<Pending>()
var int cntWin  = 0
var int cntFail = 0
var int cntNone = 0
var table statTbl = na

var ConfDraw fvgDraw  = ConfDraw.new()
var ConfDraw ifvgDraw = ConfDraw.new()

var float bullGapTop = na
var float bullGapBot = na
var int   bullGapBar = na
var float bearGapTop = na
var float bearGapBot = na
var int   bearGapBar = na

var array<Swing> swings = array.new<Swing>()

var array<box>   panelBoxes  = array.new<box>()
var array<line>  panelLines  = array.new<line>()
var array<label> panelLabels = array.new<label>()

emaVal = ta.ema(close, emaLen)
var array<chart.point> emaPts = array.new<chart.point>()
var polyline           emaPl  = na

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

addSwing(float px, int b, bool isHigh) =>
    int n = array.size(swings)
    if n == 0
        array.push(swings, Swing.new(px, b, isHigh))
    else
        Swing last = array.get(swings, n - 1)
        if last.isHigh == isHigh
            if (isHigh and px > last.price) or (not isHigh and px < last.price)
                last.price := px
                last.bar   := b
        else
            array.push(swings, Swing.new(px, b, isHigh))
            if array.size(swings) > 20
                array.shift(swings)
    array.size(swings)

firstCloseBeyond(int fromBar, int toBar, float level, bool above) =>
    int found  = na
    int startB = math.max(fromBar, bar_index - 500)
    if startB <= toBar
        for b = startB to toBar
            int off = bar_index - b
            if off >= 0
                if above ? close[off] > level : close[off] < level
                    found := b
                    break
    found

firstTradeBeyond(int fromBar, int toBar, float level, bool above) =>
    int found  = na
    int startB = math.max(fromBar, bar_index - 500)
    if startB <= toBar
        for b = startB to toBar
            int off = bar_index - b
            if off >= 0
                if above ? high[off] > level : low[off] < level
                    found := b
                    break
    found

float sPh = ta.pivothigh(1, 1)
float sPl = ta.pivotlow(1, 1)

if barstate.isconfirmed and tfBelow
    int sBar = bar_index - 1
    if not na(sPh) and not na(sPl)
        int nSw = array.size(swings)
        bool lastHi = nSw > 0 ? array.get(swings, nSw - 1).isHigh : true
        if lastHi
            addSwing(sPl, sBar, false)
            addSwing(sPh, sBar, true)
        else
            addSwing(sPh, sBar, true)
            addSwing(sPl, sBar, false)
    else
        if not na(sPh)
            addSwing(sPh, sBar, true)
        if not na(sPl)
            addSwing(sPl, sBar, false)

growConf(ConfDraw d) =>
    if d.growing
        box.set_right(d.bx, bar_index)
        label.set_x(d.lb, bar_index)
        if low > d.top or high < d.bot
            d.clear += 1
            if d.clear >= 2
                d.growing := false
        else
            d.clear := 0
    int(0)

tryMss(Setup s, int toBar) =>
    if showMss and tfBelow and not na(s) and s.armed and not s.mssDone and array.size(swings) >= 3
        int   ns = array.size(swings)
        Swing s3 = array.get(swings, ns - 1)
        Swing s2 = array.get(swings, ns - 2)
        Swing s1 = array.get(swings, ns - 3)
        bool shape = s3.isHigh != s.isBull and s2.isHigh == s.isBull and s1.isHigh != s.isBull
        bool roomLeft = s.isBull ? s2.price < s.target : s2.price > s.target
        if shape and roomLeft
            int from = math.max(s3.bar, s.armedBar)
            int brk  = firstCloseBeyond(from, toBar, s2.price, s.isBull)
            if not na(brk)
                s.mssDone := true
                line.new(s2.bar, s2.price, brk, s2.price,
                     color = mssCol, style = line.style_solid, width = 1)
                bool swept = s.isBull ? s3.price < s1.price : s3.price > s1.price
                if swept
                    int swBrk = firstTradeBeyond(s1.bar + 1, s3.bar, s1.price, not s.isBull)
                    if not na(swBrk)
                        line.new(s1.bar, s1.price, swBrk, s1.price,
                             color = mssCol, style = line.style_dotted, width = 1)
    int(0)

// ─────────────────────────────────────────────────────────────
// Build HTF Candles
// ─────────────────────────────────────────────────────────────
htfFlip = not tfAbove and timeframe.change(htf)

if htfFlip
    if showSep and tfBelow
        line.new(time, close, time, close + syminfo.mintick, xloc = xloc.bar_time,
             extend = extend.both, color = sepCol, style = line.style_dotted, width = 1)
    prevC := cur
    if not na(cur)
        array.push(done, cur)
        if array.size(done) > 8
            array.shift(done)
    cur := HtfCandle.new(open, high, low, close, bar_index, bar_index, bar_index)
else if not na(cur)
    if high > cur.h
        cur.h       := high
        cur.highBar := bar_index
    if low < cur.l
        cur.l      := low
        cur.lowBar := bar_index
    cur.c := close

// ─────────────────────────────────────────────────────────────
// Setup Expiry
// ─────────────────────────────────────────────────────────────
if htfFlip
    if tfBelow and not na(prevC) and array.size(pend) > 0
        for pi = array.size(pend) - 1 to 0
            Pending pp = array.get(pend, pi)
            if pp.isBull ? prevC.c < pp.farEdge : prevC.c > pp.farEdge
                cntFail += 1
                array.remove(pend, pi)

    if not na(setup) and not setup.armed
        box.delete(setup.zoneBox)
        if not na(setup.tgtLine)
            line.delete(setup.tgtLine)
    if not na(setup) and setup.armed
        box.set_right(setup.zoneBox, bar_index)
        if not na(setup.tgtLine) and not setup.tgtHit
            line.set_x2(setup.tgtLine, bar_index)
    tryMss(setup, bar_index - 1)
    growConf(fvgDraw)
    growConf(ifvgDraw)
    if showEma and tfBelow and not na(setup)
        if not setup.armed
            if not na(emaPl)
                polyline.delete(emaPl)
        else if not na(emaVal)
            array.push(emaPts, chart.point.from_index(bar_index, emaVal))
            if not na(emaPl)
                polyline.delete(emaPl)
            emaPl := polyline.new(emaPts, curved = false, line_color = emaCol, line_width = 2)
    if tfBelow and not na(setup)
        if not setup.armed
            cntNone += 1
        else if setup.tgtHit
            cntWin += 1
        else if not na(prevC) and (setup.isBull ? prevC.c < setup.zFar : prevC.c > setup.zFar)
            cntFail += 1
        else
            array.push(pend, Pending.new(setup.isBull, setup.zFar, setup.target))
    emaPl     := na
    setup     := na
    fvgDraw.growing  := false
    ifvgDraw.growing := false

// ─────────────────────────────────────────────────────────────
// HTF Pattern
// ─────────────────────────────────────────────────────────────
if htfFlip and array.size(done) >= 3
    n  = array.size(done)
    c1 = array.get(done, n - 3)
    c2 = array.get(done, n - 2)
    c3 = array.get(done, n - 1)

    bool isBull = c3.l > c1.h and c2.c > c2.o
    bool isBear = c3.h < c1.l and c2.c < c2.o

    if isBull or isBear
        float zNear = isBull ? c3.l : c3.h
        float zFar  = isBull ? c1.h : c1.l
        float tgt   = isBull ? math.max(c2.h, c3.h) : math.min(c2.l, c3.l)
        int   tgtB  = na
        if isBull
            tgtB := c2.h > c3.h ? c2.highBar : c3.highBar
        else
            tgtB := c2.l < c3.l ? c2.lowBar : c3.lowBar

        int zLeft = tfEqual ? c1.startBar : bar_index
        b = box.new(zLeft, math.max(zNear, zFar), bar_index, math.min(zNear, zFar),
             border_color = color.new(color.gray, 100), bgcolor = zoneFill)
        line l = na
        if tfBelow
            l := line.new(tgtB, tgt, bar_index, tgt, color = tgtCol, style = line.style_dashed)

        setup := Setup.new(isBull, zNear, zFar, tgt, tgtB, zoneBox = b, tgtLine = l)

        if showEma and tfBelow
            array.clear(emaPts)
            emaPl := na
            for eb = tgtB to bar_index - 1
                int eoff = bar_index - eb
                if eoff >= 0 and eoff <= bar_index
                    float ev = emaVal[eoff]
                    if not na(ev)
                        array.push(emaPts, chart.point.from_index(eb, ev))

// ─────────────────────────────────────────────────────────────
// Confirmation
// ─────────────────────────────────────────────────────────────
if barstate.isconfirmed and tfBelow
    if low > high[2] and close[1] > open[1]
        bullGapTop := low
        bullGapBot := high[2]
        bullGapBar := bar_index
    if high < low[2] and close[1] < open[1]
        bearGapTop := low[2]
        bearGapBot := high
        bearGapBar := bar_index

growConf(fvgDraw)
growConf(ifvgDraw)

if not na(setup)
    box.set_right(setup.zoneBox, bar_index)
    if not setup.tgtHit
        if not na(setup.tgtLine)
            line.set_x2(setup.tgtLine, bar_index)
        bool hit = setup.isBull ? high >= setup.target : low <= setup.target
        if hit
            setup.tgtHit := true

if not na(setup) and barstate.isconfirmed
    if not setup.voided
        bool hitTarget = setup.isBull ? high >= setup.target : low <= setup.target
        bool touchZone = setup.isBull ? low <= setup.zNear   : high >= setup.zNear

        if not setup.armed
            if hitTarget and tfBelow
                setup.voided := true
            else if touchZone
                setup.armed := true
                setup.armedBar := bar_index
                box.set_bgcolor(setup.zoneBox, zoneFillOn)
                if tfBelow
                    alert(htfSel + " " + (setup.isBull ? "bullish" : "bearish") + " FVG tapped.",
                         alert.freq_once_per_bar_close)

        if setup.armed and not setup.voided and tfBelow
            if showFvg and not setup.fvgDone
                bool fvgBull = setup.isBull and low > high[2] and close[1] > open[1]
                bool fvgBear = not setup.isBull and high < low[2] and close[1] < open[1]
                if fvgBull or fvgBear
                    setup.fvgDone := true
                    fvgDraw.top := fvgBull ? low : low[2]
                    fvgDraw.bot := fvgBull ? high[2] : high
                    fvgDraw.bx  := box.new(bar_index - 2, fvgDraw.top, bar_index, fvgDraw.bot,
                         border_color = color.new(color.gray, 100),
                         bgcolor      = color.new(fvgCol, 78))
                    fvgDraw.lb  := label.new(bar_index, fvgDraw.top, "FVG",
                         style     = label.style_none,
                         textcolor = fvgCol,
                         size      = size.small)
                    fvgDraw.growing := true
                    fvgDraw.clear   := 0

            if showIfvg and not setup.ifvgDone
                float lvl = na
                int   gBar = na
                float gTop = na
                float gBot = na
                if setup.isBull
                    if not na(bearGapBar) and bearGapBar >= setup.targetBar
                        lvl := bearGapTop
                        gBar := bearGapBar
                        gTop := bearGapTop
                        gBot := bearGapBot
                else
                    if not na(bullGapBar) and bullGapBar >= setup.targetBar
                        lvl := bullGapBot
                        gBar := bullGapBar
                        gTop := bullGapTop
                        gBot := bullGapBot
                if not na(lvl)
                    bool inv = setup.isBull ? close > lvl : close < lvl
                    if inv
                        setup.ifvgDone := true
                        ifvgDraw.top := gTop
                        ifvgDraw.bot := gBot
                        ifvgDraw.bx  := box.new(gBar - 2, ifvgDraw.top, bar_index, ifvgDraw.bot,
                             border_color = color.new(color.gray, 100),
                             bgcolor      = color.new(ifvgCol, 78))
                        ifvgDraw.lb  := label.new(bar_index, ifvgDraw.top, "IFVG",
                             style     = label.style_none,
                             textcolor = ifvgCol,
                             size      = size.small)
                        ifvgDraw.growing := true
                        ifvgDraw.clear   := 0

if barstate.isconfirmed and not na(setup)
    tryMss(setup, bar_index)

if tfBelow and array.size(pend) > 0
    for pi = array.size(pend) - 1 to 0
        Pending pp = array.get(pend, pi)
        if pp.isBull ? high >= pp.target : low <= pp.target
            cntWin += 1
            array.remove(pend, pi)

if barstate.isconfirmed and tfBelow
    if not na(bullGapBar) and close < bullGapBot
        bullGapBar := na
    if not na(bearGapBar) and close > bearGapTop
        bearGapBar := na

if showEma and tfBelow and not na(setup) and not na(emaVal)
    array.push(emaPts, chart.point.from_index(bar_index, emaVal))
    if array.size(emaPts) > 1
        if not na(emaPl)
            polyline.delete(emaPl)
        emaPl := polyline.new(emaPts, curved = false, line_color = emaCol, line_width = 2)

// ─────────────────────────────────────────────────────────────
// Draw HTF Candles
// ─────────────────────────────────────────────────────────────
if barstate.islast and tfBelow
    clearPanel()
    if array.size(done) >= 3
        n  = array.size(done)
        c1 = array.get(done, n - 3)
        c2 = array.get(done, n - 2)
        c3 = array.get(done, n - 1)
        if not na(setup)
            int px1 = bar_index + PANEL_X
            int px2 = bar_index + PANEL_X + 4 * (CND_W + CND_GAP) - CND_GAP - 1
            array.push(panelBoxes, box.new(px1, math.max(setup.zNear, setup.zFar),
                 px2, math.min(setup.zNear, setup.zFar),
                 border_color = color.new(color.gray, 100),
                 bgcolor      = setup.armed ? zoneFillOn : zoneFill))
        drawPanelCandle(0, c1.o, c1.h, c1.l, c1.c)
        drawPanelCandle(1, c2.o, c2.h, c2.l, c2.c)
        drawPanelCandle(2, c3.o, c3.h, c3.l, c3.c)
        if not na(cur)
            drawPanelCandle(3, cur.o, cur.h, cur.l, cur.c)
        float pTop = math.max(math.max(c1.h, c2.h), c3.h)
        if not na(cur)
            pTop := math.max(pTop, cur.h)
        int pxc = bar_index + PANEL_X + int(math.floor((4 * (CND_W + CND_GAP) - CND_GAP - 1) / 2.0))
        array.push(panelLabels, label.new(pxc, pTop, htfSel + " timeframe",
             style     = label.style_label_down,
             color     = color.new(color.black, 100),
             textcolor = edgeCol,
             size      = size.normal))
        if not na(setup)
            int tSlot = setup.isBull ? (c2.h > c3.h ? 1 : 2) : (c2.l < c3.l ? 1 : 2)
            int txs   = bar_index + PANEL_X + tSlot * (CND_W + CND_GAP) + (CND_W - 1) / 2
            int c4x   = bar_index + PANEL_X + 3 * (CND_W + CND_GAP)
            int txe   = setup.tgtHit ? c4x + (CND_W - 1) / 2 : c4x + CND_W - 1
            array.push(panelLines, line.new(txs, setup.target, txe, setup.target,
                 color = tgtCol, style = line.style_dashed, width = 1))

// ─────────────────────────────────────────────────────────────
// Stats Dashboard
// ─────────────────────────────────────────────────────────────
statRow(int row, string lbl, string val, bool dim) =>
    table.cell(statTbl, 0, row, lbl, text_size = size.small,
         text_color = dim ? tblDim : tblTx, text_halign = text.align_left)
    table.cell(statTbl, 1, row, val, text_size = size.small,
         text_color = dim ? tblDim : tblTx, text_halign = text.align_right)
    int(0)

if showStats and tfBelow and barstate.islast
    if na(statTbl)
        statTbl := table.new(position.top_right, 2, 5, bgcolor = tblBg,
             border_width = 3, border_color = color.new(color.gray, 100))
    int decided = cntWin + cntFail
    statRow(0, htfSel + " setups", "", false)
    statRow(1, "Tap → target", str.tostring(cntWin), false)
    statRow(2, "Tap → fail",   str.tostring(cntFail), false)
    statRow(3, "No setup",     str.tostring(cntNone), true)
    statRow(4, "Hit rate",
         decided > 0 ? str.tostring(math.round(100.0 * cntWin / decided)) + "%" : "—", false)
````
