<!-- tradingview-pine-id: PUB;007ed46ce8ad4748a499fa0362e3c32a -->
<!-- tradingviewscripts-format: 1 -->
# Previous Day Key Levels

Source: https://www.tradingview.com/script/U8ce7Cvm-Previous-Day-Key-Levels/

## Description

# Previous Day Key Levels

Previous Day Key Levels automatically plots the key reference points I use to frame each trading day:

* Previous RTH High and Low
* Asia High and Low
* London High and Low

The indicator is designed to work on an RTH chart while still calculating the Asia and London ranges from extended-hours data. Each level is drawn as a clean horizontal reference with a named label and a matching price marker on the right axis.

## How to use it

These levels help organize the market into clear areas of potential reaction, acceptance, rejection, breakout, or failed breakout.

Previous Day High and Low are especially useful as major reference points for the current RTH session. Price holding above or below them can support a directional thesis, while tests and rejections can highlight potential reversals or rotational conditions.

Asia and London Highs/Lows provide additional intraday structure before and during New York trading. They can act as liquidity targets, breakout points, or areas where an early New York move may stall, reverse, or accelerate.

The Asia range updates when the Asia session ends, and the London range updates when London ends. Previous Day High/Low refresh for the next RTH session.

## Pairing with Volume Profile

This indicator is intended as a supporting structure tool—not a standalone entry signal.

For a fuller market read, pair it with a Volume Profile indicator that provides:

* POC: the session’s highest-volume price area
* VAH: Value Area High
* VAL: Value Area Low

When a key session level overlaps with POC, VAH, or VAL, that confluence can make the area more meaningful. For example:

* A Previous Day High near VAH may act as a more significant resistance or breakout-acceptance area.
* A Previous Day Low near VAL may become a higher-quality support or breakdown-rejection zone.
* An Asia or London extreme aligning with POC can highlight a potential magnet, decision point, or support/resistance area.

Use the levels alongside price action, market context, and volume behavior. They are reference points—not guarantees—and are most useful for forming a structured trade idea and defining risk around meaningful market locations.

---

## Source Code

````pine
//@version=6
indicator("Previous Day Key Levels", shorttitle = "PD Levels", overlay = true, max_lines_count = 50, max_labels_count = 50)

string TZ = "America/New_York"
string GROUP_SESSIONS = "Sessions (New York time)"
string asiaSession = input.session("1800-0400", "Asia", group = GROUP_SESSIONS)
string londonSession = input.session("0400-0930", "London", group = GROUP_SESSIONS)
string rthSession = input.session("0930-1600", "RTH / Previous Day", group = GROUP_SESSIONS)

string GROUP_STYLE = "Style"
int pocRows = 100
int lineWidth = input.int(1, "Line width", minval = 1, maxval = 4, group = GROUP_STYLE)
bool showLabels = input.bool(true, "Show right-side labels", group = GROUP_STYLE)
color pdHighColor = input.color(color.rgb(245, 171, 29), "P. Day High", group = GROUP_STYLE)
color pdLowColor = input.color(color.rgb(255, 82, 93), "P. Day Low", group = GROUP_STYLE)
color asiaHighColor = input.color(color.rgb(255, 190, 38), "Asia High", group = GROUP_STYLE)
color asiaLowColor = input.color(color.rgb(255, 70, 91), "Asia Low", group = GROUP_STYLE)
color londonHighColor = input.color(color.rgb(142, 148, 160), "London High", group = GROUP_STYLE)
color londonLowColor = input.color(color.rgb(45, 81, 143), "London Low", group = GROUP_STYLE)

// This runs inside the extended-hours 30-second request. It therefore sees Asia
// and London even when the visible chart is set to Regular Trading Hours only.
f_extended_levels() =>
    bool inAsia = not na(time("30S", asiaSession, TZ))
    bool inLondon = not na(time("30S", londonSession, TZ))
    bool inRth = not na(time("30S", rthSession, TZ))
    bool asiaStart = inAsia and not inAsia[1]
    bool asiaEnd = not inAsia and inAsia[1]
    bool londonStart = inLondon and not inLondon[1]
    bool londonEnd = not inLondon and inLondon[1]
    bool rthStart = inRth and not inRth[1]
    bool rthEnd = not inRth and inRth[1]
    var float aHi = na
    var float aLo = na
    var float lHi = na
    var float lLo = na
    var float dHi = na
    var float dLo = na
    var float prevAHi = na
    var float prevALo = na
    var float prevLHi = na
    var float prevLLo = na
    var float prevDHi = na
    var float prevDLo = na
    var float prevPoc = na
    var array<float> prices = array.new_float()
    var array<float> lows = array.new_float()
    var array<float> highs = array.new_float()
    var array<float> vols = array.new_float()
    if asiaStart
        aHi := high
        aLo := low
    else if inAsia
        aHi := math.max(aHi, high)
        aLo := math.min(aLo, low)
    if asiaEnd
        prevAHi := aHi
        prevALo := aLo
    if londonStart
        lHi := high
        lLo := low
    else if inLondon
        lHi := math.max(lHi, high)
        lLo := math.min(lLo, low)
    if londonEnd
        prevLHi := lHi
        prevLLo := lLo
    if rthStart
        dHi := high
        dLo := low
        array.clear(prices)
        array.clear(lows)
        array.clear(highs)
        array.clear(vols)
    else if inRth
        dHi := math.max(dHi, high)
        dLo := math.min(dLo, low)
    if inRth
        array.push(prices, hlc3), array.push(lows, low), array.push(highs, high), array.push(vols, volume)
    if rthEnd
        prevDHi := dHi
        prevDLo := dLo
        float rng = dHi - dLo
        if rng == 0
            prevPoc := dHi
        else
            float rawStep = rng / pocRows
            float step = math.max(syminfo.mintick, math.ceil(rawStep / syminfo.mintick) * syminfo.mintick)
            float base = math.floor(dLo / syminfo.mintick) * syminfo.mintick
            int rows = int(math.ceil((dHi - base) / step))
            array<float> bins = array.new_float(rows, 0.0)
            for i = 0 to array.size(vols) - 1
                int first = math.max(0, int(math.floor((array.get(lows, i) - base) / step)))
                int last = math.min(rows - 1, int(math.floor((array.get(highs, i) - base) / step)))
                float allocated = array.get(vols, i) / (last - first + 1)
                for b = first to last
                    array.set(bins, b, array.get(bins, b) + allocated)
            int pocBin = 0
            for b = 1 to rows - 1
                if array.get(bins, b) > array.get(bins, pocBin)
                    pocBin := b
            prevPoc := base + (pocBin + 0.5) * step
    [prevAHi, prevALo, prevLHi, prevLLo, prevDHi, prevDLo, prevPoc]

string extTicker = ticker.new(syminfo.prefix, syminfo.ticker, session.extended)
[asiaHi, asiaLo, londonHi, londonLo, dayHi, dayLo, dayPoc] = request.security(extTicker, "30S", f_extended_levels(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)


bool chartRthStart = not na(time(timeframe.period, rthSession, TZ)) and na(time(timeframe.period, rthSession, TZ)[1])
bool chartAsiaEnded = na(time(timeframe.period, asiaSession, TZ)) and not na(time(timeframe.period, asiaSession, TZ)[1])
bool chartLondonEnded = na(time(timeframe.period, londonSession, TZ)) and not na(time(timeframe.period, londonSession, TZ)[1])
var float shownAsiaHi = na
var float shownAsiaLo = na
var float shownLondonHi = na
var float shownLondonLo = na
var float shownDayHi = na
var float shownDayLo = na
var float shownDayPoc = na
var array<line> lines = array.new_line()
var array<label> labels = array.new_label()
f_clear() =>
    if array.size(lines) > 0
        for i = 0 to array.size(lines) - 1
            line.delete(array.get(lines, i))
    if array.size(labels) > 0
        for i = 0 to array.size(labels) - 1
            label.delete(array.get(labels, i))
    array.clear(lines)
    array.clear(labels)
f_add(float price, string name, color c) =>
    if not na(price)
        line ln = line.new(bar_index, price, bar_index + 1, price, xloc = xloc.bar_index, extend = extend.right, color = c, width = lineWidth, force_overlay = true)
        array.push(lines, ln)
        if showLabels
            label lb = label.new(bar_index + 1, price, name, xloc = xloc.bar_index, style = label.style_label_up, color = color.new(c, 100), textcolor = c, size = size.small, force_overlay = true)
            array.push(labels, lb)
f_build() =>
    f_add(shownAsiaHi, "Asia High", asiaHighColor)
    f_add(shownDayHi, "P. Day High", pdHighColor)
    f_add(shownLondonHi, "London High", londonHighColor)
    f_add(shownLondonLo, "London Low", londonLowColor)
    f_add(shownDayLo, "P. Day Low", pdLowColor)
    f_add(shownAsiaLo, "Asia Low", asiaLowColor)
if chartRthStart
    shownAsiaHi := asiaHi
    shownAsiaLo := asiaLo
    shownLondonHi := londonHi
    shownLondonLo := londonLo
    shownDayHi := dayHi
    shownDayLo := dayLo
    shownDayPoc := dayPoc
    f_clear()
    f_build()
else if chartAsiaEnded
    shownAsiaHi := asiaHi
    shownAsiaLo := asiaLo
    f_clear()
    f_build()
else if chartLondonEnded
    shownLondonHi := londonHi
    shownLondonLo := londonLo
    f_clear()
    f_build()
if barstate.islast and array.size(lines) == 0
    shownAsiaHi := asiaHi
    shownAsiaLo := asiaLo
    shownLondonHi := londonHi
    shownLondonLo := londonLo
    shownDayHi := dayHi
    shownDayLo := dayLo
    shownDayPoc := dayPoc
    f_build()
if array.size(labels) > 0
    for i = 0 to array.size(labels) - 1
        label.set_x(array.get(labels, i), bar_index + 1)

// Price-scale markers: values live on the axis; text labels above carry only names.
plot(shownAsiaHi, "Asia High", color = asiaHighColor, trackprice = true, show_last = 1, display = display.price_scale)
plot(shownDayHi, "P. Day High", color = pdHighColor, trackprice = true, show_last = 1, display = display.price_scale)
plot(shownLondonHi, "London High", color = londonHighColor, trackprice = true, show_last = 1, display = display.price_scale)
plot(shownLondonLo, "London Low", color = londonLowColor, trackprice = true, show_last = 1, display = display.price_scale)
plot(shownDayLo, "P. Day Low", color = pdLowColor, trackprice = true, show_last = 1, display = display.price_scale)
plot(shownAsiaLo, "Asia Low", color = asiaLowColor, trackprice = true, show_last = 1, display = display.price_scale)
````
