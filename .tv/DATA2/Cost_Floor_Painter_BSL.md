<!-- tradingview-pine-id: PUB;08d3ac8e37874e16bd82d2b40a4687e4 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Cost Floor Painter [BSL]

Source: https://www.tradingview.com/script/BeKPSzwY-Cost-Floor-Painter-BSL/

## Description

Is this bar even big enough to pay for its own round trip?

Most people pick a timeframe before they ever ask that. Cost Floor Painter
[BSL] answers it for every bar on the chart, and then reports how often the
answer was yes.

HOW IT ANSWERS

You enter a round-trip cost once, in ticks: your spread plus your commission
plus whatever slippage you expect to pay. The script converts that to a price
distance using the instrument's own tick size, so the same setting keeps
working when you switch symbols.

Every closed bar is then measured against it. A bar that covered the cost is
painted solid. A bar that did not is painted in the SAME colour, faded. A
single-row panel reports how many of the last 50 closed bars cleared, with the
50 printed beside it.

The measurement is true range, not high minus low. If a session opened away
from the previous close, that jump is distance the instrument actually
travelled, and counting it is the honest reading. The panel names this on its
face, TRUE RANGE followed by your cost in ticks and in price, so you can see
which definition produced the number. Cost-to-Range Gauge [BSL] measures the
same predicate over a window and names it the same way, so two tools that
agree by construction can be seen to agree.

A bar whose range lands exactly on the cost counts as covered.

WHERE THE READING BITES

On daily bars almost everything clears, whatever cost you enter. A day of
EURUSD moves eighty pips and a round trip costs two; the comparison is not
close and the panel will read 100%. That is a true answer and a dull one. The
reading gets interesting on the timeframes where bar size and cost are the
same order of magnitude, which for most instruments means minutes rather than
days. Checked on 2026-09-04: at the default cost, BTCUSDT, AAPL and EURUSD all
read 100% on the daily.

WHY FAILING BARS ARE THE SAME COLOUR

A second colour would say: this is a different kind of bar. It is not. A bar
one tick short of the cost is not a different animal from one a tick over, and
colouring it separately would invent a boundary the market does not have.

Fading says: the same kind of thing, weaker. That is the true statement, and
it is the only claim the paint makes.

THE BAR STILL OPEN GETS NO VERDICT

The current bar is drawn as an outline. It is never painted, never counted and
never published, because its range can still change. Whatever it looks like
now, it has not finished being a bar.

THE COST IS YOURS AND THE SCRIPT CANNOT CHECK IT

Spread, commission and slippage are numbers you supply. No chart indicator can
read your broker's fee schedule, and this one does not pretend to. If your
figure is wrong, every reading here is wrong by the same amount, and that is
why the panel shows the conversion from ticks to price, so you can
sanity-check it against your own fills.

WHAT YOU CAN SET

- Round-trip cost: 4.0 ticks
- Coverage window: 50 closed bars
- Colour the bars: on
- Outline the forming bar: on
- Panel position: Bottom center

There are six positions to choose from and the panel starts at the bottom
center. That is the strip TradingView leaves empty. The chart legend and the
trading buttons live top left, the platform's own logo sits bottom left and
covers whatever starts there, and the price scale takes the right. Move it if it
covers something.

The two display switches change the picture and nothing else. Turn the paint
off and the counts, the share and the published value are identical.

Below 50 closed bars there is no share at all. The panel says how many bars it
has instead of dividing by a number it does not have.

WHERE IT REFUSES TO WORK

Heikin Ashi, Renko, Kagi, Point & Figure and Range charts build their bars
from the market rather than showing them. The range of a constructed bar is
not the distance a trade would have paid for, so measuring a cost against it
would produce a number that looks right and means nothing.

On those chart types the paint, the share and the published value stop, the
background carries a wash you cannot miss, and the panel collapses to one
frozen row naming the chart type.

WHAT OTHER SCRIPTS CAN READ

One value is published for other indicators to pick up in their Source
setting: whether the bar cleared the cost. It is 1 for a bar that covered it,
0 for a bar that did not, and no value at all before the script has an
opinion. That is not the same as a 0.

That value is a filter, not a signal. It describes bar size and carries no
direction. It says nothing about whether to be long or short, and connecting
it to a tool that expects entry events would produce entries nobody signalled:
the value sits at 1 for every large bar in a row, and a tool reading events
would treat each change from 0 to 1 as a fresh instruction.

The dropdown will show more than this one value. The outline drawn on the
forming bar is offered there too, along with the two alert conditions, and the
outline is switched off by a display box. Take the value named above.

WHAT IT WILL NOT TELL YOU

It never reports what happened after a bar cleared the cost. There is no
direction in it, no entry, no exit, no stop and no position size. It
recommends no timeframe, no instrument and no cost figure. No percentage
appears anywhere without the number it was divided by.

What a cost does to a sequence of trades is a different question, answered by
Execution-Aware Trend [BSL], where the same figure becomes an executed cost
with next-bar fills and a fixed in-sample / out-of-sample split.

This tool describes bar size against a cost you declare. It does not predict
price, guarantee performance or provide trading advice. Validate the behaviour
on your own symbols, timeframes and execution assumptions before making
decisions.

Open-source Pine Script® v6. Educational use only.

---

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// © BarState Labs
//@version=6
indicator("Cost Floor Painter [BSL]", shorttitle = "BSL Cost Floor", overlay = true, max_bars_back = 600)

// Cost Floor Painter answers one question: is this bar even big enough to pay
// for its own round trip? The cost is entered in ticks, converted to price with
// syminfo.mintick and compared against the bar's TRUE range. It makes no claim
// about direction, entry or outcome. What a cost does across a sequence of
// trades is BSL-003 Execution-Aware Trend, where the same assumption becomes an
// executed cost with next-bar fills and an out-of-sample split.
//
// The predicate is shared with B-vis3-02 Cost-to-Range Gauge, which aggregates
// the same test as a count of bars under cost. The two are defined to match:
// both use ta.tr(true), and both name the definition on their own panel, so a
// user who owns both can see that they agree rather than having to trust it.

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────
string GROUP_COST = "01 · Round-trip cost"
string GROUP_DISPLAY = "02 · Display"

float costTicks = input.float(4.0, "Round-trip cost, ticks", minval = 0.1, maxval = 10000.0, step = 0.1, group = GROUP_COST,
     tooltip = "Spread plus commission plus a slippage allowance, entered in ticks so the number survives a change of instrument. It is converted to price with syminfo.mintick and compared against each closed bar's true range, which counts an overnight gap as range the instrument actually travelled. B-vis3-02 Cost-to-Range Gauge counts the same test over a window and uses the same definition.")
int coverage = input.int(50, "Coverage window, closed bars", minval = 2, maxval = 5000, group = GROUP_COST,
     tooltip = "How many closed bars the cleared share is measured over. The panel always prints this count beside the share, so a share measured over 30 bars cannot pass for one measured over 3,000.")

bool showPaint = input.bool(true, "Colour the bars", group = GROUP_DISPLAY)
bool showForming = input.bool(true, "Outline the forming bar", group = GROUP_DISPLAY,
     tooltip = "The bar still forming is redrawn with its body at 90 percent transparency and its border and wick opaque. Pine has no hollow candle style, so the outline comes from body transparency against an opaque bordercolor, not from a style flag. That bar is never classified, counted or exported.")
string panelPositionInput = input.string("Bottom center", "Panel position", options = ["Auto", "Top right", "Bottom right", "Top left", "Bottom left", "Top center", "Bottom center"],
     group = GROUP_DISPLAY, tooltip = "Auto keeps the panel opposite the latest price within the visible chart range. Pick a corner by hand when another script already occupies this one.")

// ─────────────────────────────────────────────────────────────────────────────
// Palette
//
// One hue carries the verdict. Below cost is the same hue at raised
// transparency rather than a second colour, so it reads as LESS, not as OTHER.
// ─────────────────────────────────────────────────────────────────────────────
color COLOR_BG = color.rgb(11, 14, 13)
color COLOR_TEXT = color.rgb(242, 239, 232)
color COLOR_MUTED = color.rgb(156, 161, 154)
color COLOR_GREEN = color.rgb(82, 211, 151)
color COLOR_RED = color.rgb(239, 107, 107)
color COLOR_AMBER = color.rgb(235, 184, 87)
color COLOR_BLUE = color.rgb(104, 167, 255)
color COLOR_HUE = color.rgb(104, 167, 255)

int WASHED_TRANSPARENCY = 62
int FORMING_BODY_TRANSPARENCY = 90

f_chart_type() =>
    chart.is_heikinashi ? "HEIKIN ASHI" :
     chart.is_renko ? "RENKO" :
     chart.is_kagi ? "KAGI" :
     chart.is_pnf ? "POINT & FIGURE" :
     chart.is_range ? "RANGE" : "NON-STANDARD"

// ─────────────────────────────────────────────────────────────────────────────
// The classification
//
// A closed bar's range is final the moment the bar closes, so the verdict sits
// on the bar that produced it with no delay and can never revise. The forming
// bar is deliberately excluded: its range is still growing, and a verdict that
// could be withdrawn is worse than no verdict at all.
//
// ta.tr(true) rather than high minus low. True range is gap-aware: a bar that
// gapped and then traded a narrow intrabar range carries a real move a holder
// captured, and high minus low would call that bar too small to trade when it
// was not. For a beginner tool a false "this bar is not worth it" costs the
// reader opportunity silently, which is the worse of the two errors. The `true`
// argument makes the first bar of the loaded history fall back to high minus
// low instead of returning na, so the series has no hole at its left end.
// ─────────────────────────────────────────────────────────────────────────────
bool configValid = costTicks > 0.0 and coverage >= 2 and coverage <= 5000
bool standardChart = chart.is_standard
bool drawable = configValid and standardChart

float costPrice = costTicks * syminfo.mintick
float barRange = ta.tr(true)
bool clearedRaw = barRange >= costPrice

bool resolved = drawable and barstate.isconfirmed
bool forming = drawable and not barstate.isconfirmed
bool cleared = resolved and clearedRaw

var int clearedCount = 0
var int observedBars = 0

if resolved
    observedBars += 1
    clearedCount += cleared ? 1 : 0

// The share is an average of the raw classification over the coverage window.
// ta.sma runs in global scope on every bar so it carries one history, and the
// published copy is refreshed only at a bar's close. That is what stops the
// right-hand number moving while the newest bar is still being built: because
// only the newest bar of a chart can be open, the window behind a published
// share contains closed bars only.
float clearedValue = clearedRaw ? 1.0 : 0.0
float rollingShare = ta.sma(clearedValue, coverage)
var float publishedShare = na
if resolved
    publishedShare := rollingShare

// ─────────────────────────────────────────────────────────────────────────────
// Paint
//
// barcolor carries the verdict on confirmed bars and is passed na on the bar
// still forming, which is then redrawn by plotcandle. barcolor and plotcandle
// have no hollow style, so the outline effect is body transparency against an
// opaque bordercolor and wickcolor, both of which are real plotcandle
// parameters. Nothing here is described as hollow, dashed or outlined by style.
// ─────────────────────────────────────────────────────────────────────────────
color paintHue = clearedRaw ? COLOR_HUE : color.new(COLOR_HUE, WASHED_TRANSPARENCY)
barcolor(showPaint and resolved ? paintHue : na, title = "Cost floor paint")

plotcandle(showForming and forming ? open : na, showForming and forming ? high : na,
     showForming and forming ? low : na, showForming and forming ? close : na,
     title = "Forming bar · not classified", color = color.new(COLOR_HUE, FORMING_BODY_TRANSPARENCY),
     bordercolor = COLOR_HUE, wickcolor = COLOR_HUE)

// The single background tint marks the bars this product has no opinion about:
// the open bar, and every bar of a chart or configuration it refuses. On a
// refused chart the wash covers the whole history, because a three-cell panel
// is easy to miss and a silent blank chart is not a refusal a reader can see.
bgcolor(not drawable ? color.new(COLOR_AMBER, 90) : forming ? color.new(COLOR_MUTED, 92) : na,
     title = "No opinion")

// ─────────────────────────────────────────────────────────────────────────────
// Exported stream
//
// BarState Labs producer stream contract 1.1.0, declared in
// docs/products/data-trust-painter-spec.md §5.1. Mask profile: 1 where the
// closed bar's TRUE range covered the declared round-trip cost, 0 where it did not,
// na where the product has no opinion — the open bar, an invalid configuration,
// a non-standard chart type. A consumer must not read na as 0 or carry it
// forward with nz(). The mask is an eligibility filter about bar size and says
// nothing about direction.
// ─────────────────────────────────────────────────────────────────────────────
plot(resolved ? (clearedRaw ? 1.0 : 0.0) : na, "Cost floor cleared", display = display.data_window)

alertcondition(cleared, "Bar cleared the round-trip cost",
     "Cost Floor Painter classified a closed bar's true range as large enough to cover the declared round-trip cost.")
alertcondition(resolved and not cleared, "Bar did not clear the round-trip cost",
     "Cost Floor Painter classified a closed bar's true range as too small to cover the declared round-trip cost.")

// ─────────────────────────────────────────────────────────────────────────────
// Evidence panel
//
// Three cells in one row, which is the declared budget. Every disclosure the
// product owes a reader fits inside them: the cost assumption with its price
// conversion, the share with its own denominator, and the status with the
// standing reminder that this is a statement about bar size and not a trade.
// ─────────────────────────────────────────────────────────────────────────────
bool inVisibleWindow = time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time
var float visibleWindowHigh = na
var float visibleWindowLow = na
var float visibleWindowRightClose = na
if inVisibleWindow
    visibleWindowHigh := na(visibleWindowHigh) ? high : math.max(visibleWindowHigh, high)
    visibleWindowLow := na(visibleWindowLow) ? low : math.min(visibleWindowLow, low)
    visibleWindowRightClose := close

float visibleWindowMid = not na(visibleWindowHigh) and not na(visibleWindowLow) ?
     (visibleWindowHigh + visibleWindowLow) / 2.0 : na
string automaticPanelPosition = not na(visibleWindowMid) and visibleWindowRightClose > visibleWindowMid ?
     position.bottom_right : position.top_right
string resolvedPanelPosition = panelPositionInput == "Top right" ? position.top_right :
     panelPositionInput == "Bottom right" ? position.bottom_right :
     panelPositionInput == "Top left" ? position.top_left :
     panelPositionInput == "Bottom left" ? position.bottom_left :
     panelPositionInput == "Top center" ? position.top_center :
     panelPositionInput == "Bottom center" ? position.bottom_center : automaticPanelPosition

var table panel = table.new(position.top_right, 3, 1, bgcolor = color.new(COLOR_BG, 3),
     border_color = color.new(COLOR_MUTED, 65), border_width = 1)

if barstate.islast
    table.set_position(panel, resolvedPanelPosition)
    if not standardChart
        // A range measured on a synthetic bar is not the range a trade would
        // have paid for, so the product refuses rather than paints.
        table.cell(panel, 0, 0, "BSL / COST FLOOR · FROZEN", text_color = COLOR_AMBER,
             bgcolor = color.new(COLOR_AMBER, 78), text_size = size.small, text_halign = text.align_left)
        table.cell(panel, 1, 0, f_chart_type() + " BARS ARE SYNTHETIC", text_color = COLOR_TEXT,
             bgcolor = color.new(COLOR_AMBER, 78), text_size = size.small, text_halign = text.align_left)
        table.cell(panel, 2, 0, "NO PAINT, NO SHARE, NO MASK", text_color = COLOR_TEXT,
             bgcolor = color.new(COLOR_AMBER, 78), text_size = size.small, text_halign = text.align_left)
    else
        string status = not configValid ? "CONFIG ERROR" :
             observedBars == 0 ? "WARM-UP · NO CLOSED BARS" :
             barstate.isconfirmed ? "CONFIRMED" : "OPEN BAR · HELD"
        color statusColor = not configValid ? COLOR_RED :
             observedBars == 0 ? COLOR_AMBER :
             barstate.isconfirmed ? COLOR_GREEN : COLOR_AMBER
        string shareText = not configValid ? "NO SHARE" :
             na(publishedShare) ? "FEWER THAN " + str.tostring(coverage) + " CLOSED BARS · NO SHARE" :
             str.tostring(int(math.round(publishedShare * 100.0))) + "% OF " + str.tostring(coverage) +
             " CLOSED BARS CLEARED"
        // The share is printed in one neutral colour whatever its value. A
        // green-above / red-below split would need a threshold nobody declared,
        // and would read as a verdict on a number that is only a description of
        // bar size.
        color shareColor = na(publishedShare) ? COLOR_AMBER : COLOR_TEXT

        // The range definition is named on the panel, not only in the
        // description. B-vis3-02 Cost-to-Range Gauge counts the same predicate
        // over a window, and two products that agree by construction should be
        // visibly seen to agree rather than taken on trust.
        table.cell(panel, 0, 0, "BSL / COST FLOOR · TRUE RANGE ≥ " + str.tostring(costTicks, "#.##") +
             " TICKS = " + str.tostring(costPrice, format.mintick), text_color = COLOR_TEXT,
             bgcolor = color.new(COLOR_BLUE, 70), text_size = size.small, text_halign = text.align_left)
        table.cell(panel, 1, 0, shareText, text_color = shareColor, text_size = size.small,
             text_halign = text.align_left)
        table.cell(panel, 2, 0, status + " · BAR SIZE ONLY · NOT A TRADE SIGNAL", text_color = statusColor,
             text_size = size.small, text_halign = text.align_left)
````
