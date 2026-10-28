# GCGrid  Psych Levels NomadaScalper

- url: https://www.tradingview.com/script/ZIQRZaiD-GCGrid-Psych-Levels-NomadaScalper/
- type: indicator
- pine_id: PUB;ae48269d4e7d44bc967c313223a7a488
- version: 4.0

## Description

# GCGrid, Psych Levels (NomadaScalper)

**Dual absolute grid of psychological levels for gold: every $100 and every $250, drawn as reaction zones instead of single lines.**

## What this is

Gold trades in the thousands, and round prices carry real weight up there. Whole hundreds like 4,100 or 4,300, and the bigger quarter thousand steps like 4,250 or 4,500, are the numbers people keep in their heads, park orders around and quote to each other. GCGrid draws that map for you and then stays out of the way.

Everything on the chart is absolute. A level is a multiple of 100 or a multiple of 250, and that is the whole definition. Nothing comes from a lookback window, a pivot search, a moving average or a fitted parameter. The consequence matters more than it sounds: the same levels appear on the 1 minute and on the daily, on any broker feed, on any date range, and they never shift after a candle closes.

I built this because I got tired of redrawing the same hundreds by hand every session, and because I wanted the two scales visible at once without the chart turning into a ladder of identical lines.

## How the grid is built

The script takes the current close and walks outward in both directions on each grid. You choose how many levels you want above and below price for each layer, up to four on each side, so the chart only ever shows the neighbourhood you are actually trading in.

Each level is drawn as a band rather than a line. You set the half width in points, so a half width of 5 on the $100 grid means 4,300 is shown as a zone from 4,295 to 4,305. Price rarely turns exactly on a round number, it turns near it, and a band says that honestly where a hairline pretends otherwise. If you still want the exact price marked, the centreline option puts a solid hairline at the level itself inside the band.

There is an opacity hierarchy so the chart reads at a glance. The nearest level on each side is drawn strongest and outer levels fade as they get further away. The $250 layer uses a wider, fainter body with a sharper edge, since a major level should announce itself by its boundary rather than by its mass, and it is painted underneath the $100 layer so the two never fight.

Every multiple of 500 belongs to both grids at the same time. By default those confluent levels are drawn once, as the wider $250 band, and flagged with a gold star chip so you can see instantly that two scales agree there. You can switch that off and have both bands drawn nested if you prefer to see the structure literally.

FastZone is the last piece of geometry: a dashed line at the 50 percent midpoint between consecutive $100 levels. It is purely a display layer and it never feeds anything else in the script. It exists because the halfway point of a hundred is where a lot of intraday rotation dies.

## The reaction markers

This is the part I spent the most time on, and the part where I wanted no ambiguity at all.

A marker is classified by the **direction of approach**, not by where the candle closes. If the previous bar closed above a zone and the current bar reaches down into it, that is marked as a Possible Support test. If the previous bar closed below a zone and the current bar reaches up into it, that is a Possible Resistance test. Falling into a level makes it support, rising into it makes it resistance. That is the whole rule, and there is nothing to tune inside it.

Three design choices keep it honest:

Markers are evaluated on confirmed bars only. Nothing appears and vanishes while a candle is still forming, and nothing repaints when you reload the chart.

The marker fires on arrival, on the first closed bar that reaches the zone from that side. One marker per level per episode, and that level only becomes eligible again once price moves more than half a grid step away from it.

The marker stays on the chart even if price later slices straight through. It flags that a test happened. It says nothing about whether the test held, and the script does not measure, store or imply any success rate anywhere.

Marker distance from the zone edge is scaled by ATR(14), so the labels sit off the candles whether you are on a 1 minute chart or a weekly one. You can show arrows, labels, both, or cap how many recent events stay visible.

## The dashboard

A compact panel that answers the questions you would otherwise squint at the chart for: which layers are active and how many levels each is showing, how many confluent levels are currently in view, the nearest level above and below the close with the signed distance in dollars to each, and the full span of what is currently drawn. Position and size are configurable, and it can be switched off entirely.

## How I use it

As context, not as a trigger. The grid tells me where the obvious prices are before the session starts, the bands tell me how much room a level realistically deserves, the star tells me which levels have two scales behind them, and the markers give me a clean record of which levels price has already come to test today and from which side. What I do with that information is a separate decision that this script does not make for me.

A practical note on scope: the 100 and 250 steps are fixed constants, chosen for gold, where price sits in the four figure range. On instruments priced very differently those steps will not be meaningful, and they are deliberately not user editable because making them editable would turn a specific idea into a generic round number tool.

## Settings summary

**Grid $100:** levels above, levels below, band half width, level labels.

**Grid $250:** on or off, levels above, levels below, band half width, level labels, duplicate removal for confluent levels.

**Level styling:** centreline inside the bands.

**Reaction markers:** on or off, style (arrow plus label, label only, arrow only), how many recent events to keep, show the level price in the marker text, marker gap as a multiple of ATR, and whether the $250 layer is marked as well.

**FastZone:** show the 50 percent midpoints, show their labels.

**Colors:** resistance, support and FastZone tints, all tuned for a light chart background by default.

**UI:** dashboard on or off, panel position, panel size.

## Credits and disclaimer

Original work by NomadaScalper. This is the public evolution of my private Key100 and KeyPoint250 scripts, merged into a single dual grid engine with the approach based marker logic added. Written in Pine Script v6.

This indicator is a charting and context tool. It does not produce buy or sell signals, it does not claim or measure any win rate, and it is not financial advice. Anything you trade is your own decision and your own risk.

## Source Code

````pine
//@version=6
// © NomadaScalper · OHLClabs
// GCGrid v3.2.1 — CFD / futures psychological grids. No dashboard.
// Compact terminal redesign of the supplied v3.1.0. Grid logic preserved; no arrival markers.
// Cross-market levels use an additive spread, NOT an options/GEX calculation.
indicator("GCGrid · CFD & Futures — NomadaScalper", shorttitle = "GCGrid NomadaScalper", overlay = true,
     max_lines_count = 450, max_labels_count = 350, max_boxes_count = 200)

// 1. Palette and inputs. Product UI is English.
const color C_BG = #101924
const color C_PAPER = #EDF3FA
const color C_SHADOW = #05090F
const color C_FACE_CFD = #12242D
const color C_FACE_FUT = #26241F
const color C_MUTED = #99A1AE
const color C_GOLD = #D4AD64
const color C_CFD = #78BED0
const color C_RES = #CE6A62
const color C_SUP = #5DAE83
const color C_FZ = #738294
const float STEP_1 = 100.0
const float STEP_2 = 250.0
const float EPS = 0.000001

const string G_SRC = "01 · Markets"
i_markets = input.string("Both", "Levels to display", options = ["Both", "CFD only", "Futures only"], group = G_SRC,
     tooltip = "Works in both directions. CFD charts use their own native prices plus the selected futures source. GC/MGC charts use their own native prices plus the selected CFD source.")
i_futures = input.symbol("COMEX:GC1!", "Futures source · on CFD", group = G_SRC)
i_cfd = input.symbol("VANTAGE:XAUUSD", "CFD source · on futures", group = G_SRC)
i_mapping = input.string("Auto · confirmed spread", "Cross-market conversion", options = ["Auto · confirmed spread", "Manual spread"], group = G_SRC,
     tooltip = "Auto: chart close minus source close from the SAME completed bar. The last matched spread is held if a market pauses. Imported levels can move as the spread changes. Native levels remain fixed multiples.")
i_manual_basis = input.float(0.0, "Manual: futures minus CFD (pts)", step = 0.1, group = G_SRC,
     tooltip = "Used only in Manual spread mode. Example: GC 4401.2 minus XAU 4363.8 = +37.4. GC 4400 projects to XAU 4362.6; XAU 4300 projects to GC 4337.4. Supply a simultaneous, verified difference.")

// Fixed product preset: only Markets is user-editable.
// Grid defaults retained; visual geometry is a fixed product preset.
const int i_above_1 = 4
const int i_below_1 = 4
const float i_half_1 = 10.0
const bool i_lbl_1 = true
const bool i_show_2 = true
const int i_above_2 = 4
const int i_below_2 = 4
const float i_half_2 = 10.0
const bool i_lbl_2 = true
const bool i_dedupe = true
const bool i_centerln = true
const int i_label_offset = 18
const int i_history = 180
const bool i_separate = true
const color i_col_res = C_RES
const color i_col_sup = C_SUP
const color i_col_cfd = C_CFD
const color i_col_future = C_GOLD
const bool i_show_fz = true
const bool i_show_fz_lbl = true
const color i_col_fz = C_FZ

// 2. Source identity and synchronized, completed-bar conversion.
bool chartCFD = syminfo.ticker == "XAUUSD" and syminfo.type != "futures"
bool chartFuture = syminfo.type == "futures" and (syminfo.root == "GC" or syminfo.root == "MGC")
bool chartOK = chart.is_standard and syminfo.currency == "USD" and (chartCFD or chartFuture)
bool autoTimeOK = timeframe.isintraday and timeframe.in_seconds() >= 60
bool showCFD = i_markets != "Futures only"
bool showFuture = i_markets != "CFD only"
bool showNative = chartCFD ? showCFD : chartFuture and showFuture
bool showForeign = chartCFD ? showFuture : chartFuture and showCFD
bool manual = i_mapping == "Manual spread"
string otherSymbol = chartCFD ? i_futures : i_cfd

// [1] makes every requested price a completed bar. Never use an unshifted close
// with lookahead_on. Gaps are filled only for transport; equality of bar-close
// timestamps below rejects asynchronous combinations and session gaps.
[otherClose, otherStamp, otherTicker, otherRoot, otherType, otherCurrency] = request.security(otherSymbol, timeframe.period,
     [close[1], time_close[1], syminfo.ticker, syminfo.root, syminfo.type, syminfo.currency],
     gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
bool otherIdentityOK = otherCurrency == "USD" and (chartCFD ? otherType == "futures" and (otherRoot == "GC" or otherRoot == "MGC") : otherTicker == "XAUUSD" and otherType != "futures")
bool pairOK = chartOK and autoTimeOK and otherIdentityOK and not na(otherClose) and otherClose > 0 and not na(close[1]) and close[1] > 0 and not na(otherStamp) and otherStamp == time_close[1] and otherStamp <= time
var float lastSpread = na
var int lastPairStamp = na
if pairOK
    lastSpread := close[1] - otherClose
    lastPairStamp := otherStamp

// Offset is always TARGET minus SOURCE. Same-dollar-unit additive basis.
float crossOffset = manual ? (chartCFD ? -i_manual_basis : i_manual_basis) : lastSpread
bool crossReady = chartOK and (manual or (otherIdentityOK and autoTimeOK and not na(lastSpread)))
bool held = not manual and crossReady and (na(time_close[1]) or lastPairStamp != time_close[1])
float atrValue = ta.atr(14)

// 3. Grid engine. Every level retains SOURCE price and TARGET price separately.
type GridLevel
    float origin
    float mapped
    float half
    bool futures
    bool foreign
    string source
    int tier
    int rank
    bool confluent
    bool labelOn

f_above(float px, float stepSize, int k) =>
    math.floor(px / stepSize) * stepSize + k * stepSize

f_below(float px, float stepSize, int k) =>
    math.ceil(px / stepSize) * stepSize - k * stepSize

f_nearest(float px, float stepSize) =>
    math.round(px / stepSize) * stepSize

f_same(float first, float second) =>
    math.abs(first - second) < EPS

f_price(float value) =>
    str.tostring(math.round_to_mintick(value), format.mintick)

f_origin(float value) =>
    str.tostring(value, "#,###")

f_ladder(float refPrice, float stepSize, int belowCount, int aboveCount) =>
    array<float> result = array.new_float()
    float central = f_nearest(refPrice, stepSize)
    bool exactCenter = f_same(refPrice, central)
    float ladderReference = exactCenter ? central : refPrice
    for k = belowCount to 1
        array.push(result, f_below(ladderReference, stepSize, k))
    // Do not lose the central grid level when price is exactly on a multiple.
    if exactCenter
        array.push(result, central)
    for k = 1 to aboveCount
        array.push(result, f_above(ladderReference, stepSize, k))
    result

f_contains(array<float> values, float value) =>
    bool found = false
    for element in values
        if f_same(element, value)
            found := true
    found

f_source_levels(array<GridLevel> output, bool isFuture, bool isForeign, string symbolName, float offset) =>
    float refPrice = close - offset
    array<float> primary = f_ladder(refPrice, STEP_1, i_below_1, i_above_1)
    array<float> major = i_show_2 ? f_ladder(refPrice, STEP_2, i_below_2, i_above_2) : array.new_float()
    for level in major
        bool overlap = f_contains(primary, level)
        float halfWidth = overlap and i_dedupe ? math.max(i_half_1, i_half_2) : i_half_2
        int rank = int(math.max(0, math.ceil(math.abs(level - refPrice) / STEP_2) - 1))
        bool labelOn = i_lbl_2 or (overlap and i_dedupe and i_lbl_1)
        array.push(output, GridLevel.new(level, math.round_to_mintick(level + offset), halfWidth, isFuture, isForeign, symbolName, 2, rank, overlap, labelOn))
    for level in primary
        if not (i_dedupe and f_contains(major, level))
            int rank = int(math.max(0, math.ceil(math.abs(level - refPrice) / STEP_1) - 1))
            array.push(output, GridLevel.new(level, math.round_to_mintick(level + offset), i_half_1, isFuture, isForeign, symbolName, 1, rank, false, i_lbl_1))
    if i_show_fz
        // Absolute x50 midpoints, including at exact x00 prices. Suppress FZ
        // when an already drawn $250 major has the same center (e.g. 4250).
        float firstMid = array.first(primary) + STEP_1 / 2.0
        float lastLevel = array.last(primary)
        int midCount = int(math.floor((lastLevel - firstMid) / STEP_1))
        if midCount >= 0
            for j = 0 to midCount
                float mid = firstMid + j * STEP_1
                if not f_contains(major, mid)
                    array.push(output, GridLevel.new(mid, math.round_to_mintick(mid + offset), 0.0, isFuture, isForeign, symbolName, 0, 0, false, i_show_fz_lbl))

// 4. Compact terminal presentation. Original semantic/source colors retained.
// Pools update existing IDs and remove surplus objects when the source count changes.
// Layer order is stable: shadow, rim, opaque face; only the face contains visible ink.
var array<box> qBoxes = array.new<box>()
var array<line> qLines = array.new<line>()
var array<label> qLabels = array.new<label>()
var array<int> qUsed = array.new_int(3, 0)

f_begin_grid() =>
    array.fill(qUsed, 0)

f_finish_grid() =>
    while array.size(qBoxes) > array.get(qUsed, 0)
        box.delete(array.pop(qBoxes))
    while array.size(qLines) > array.get(qUsed, 1)
        line.delete(array.pop(qLines))
    while array.size(qLabels) > array.get(qUsed, 2)
        label.delete(array.pop(qLabels))

f_box(int leftBar, float topPrice, int rightBar, float bottomPrice, color fill, color edge, string stroke) =>
    int slot = array.get(qUsed, 0)
    box drawing = na
    if slot < array.size(qBoxes)
        drawing := array.get(qBoxes, slot)
    else
        drawing := box.new(leftBar, topPrice, rightBar, bottomPrice)
        array.push(qBoxes, drawing)
    box.set_lefttop(drawing, leftBar, topPrice)
    box.set_rightbottom(drawing, rightBar, bottomPrice)
    box.set_bgcolor(drawing, fill)
    box.set_border_color(drawing, edge)
    box.set_border_width(drawing, 1)
    box.set_border_style(drawing, stroke)
    array.set(qUsed, 0, slot + 1)

f_line(int firstBar, float firstPrice, int lastBar, float lastPrice, color ink, int weight, string stroke) =>
    int slot = array.get(qUsed, 1)
    line drawing = na
    if slot < array.size(qLines)
        drawing := array.get(qLines, slot)
    else
        drawing := line.new(firstBar, firstPrice, lastBar, lastPrice)
        array.push(qLines, drawing)
    line.set_xy1(drawing, firstBar, firstPrice)
    line.set_xy2(drawing, lastBar, lastPrice)
    line.set_color(drawing, ink)
    line.set_width(drawing, weight)
    line.set_style(drawing, stroke)
    array.set(qUsed, 1, slot + 1)

f_label_layer(int atBar, float atPrice, string content, color surface, color ink, int pointSize, string tip, bool strong = false) =>
    int slot = array.get(qUsed, 2)
    label drawing = na
    if slot < array.size(qLabels)
        drawing := array.get(qLabels, slot)
    else
        drawing := label.new(atBar, atPrice, content, style = label.style_label_left,
             text_font_family = font.family_monospace, textalign = text.align_left)
        array.push(qLabels, drawing)
    label.set_xy(drawing, atBar, atPrice)
    label.set_text(drawing, content)
    label.set_color(drawing, surface)
    label.set_textcolor(drawing, ink)
    label.set_size(drawing, pointSize)
    label.set_text_formatting(drawing, strong ? text.format_bold : text.format_none)
    label.set_tooltip(drawing, tip)
    array.set(qUsed, 2, slot + 1)

f_grid_tag(GridLevel item) =>
    item.tier == 0 ? "FZ 50%" : item.confluent ? "100 + 250" : item.tier == 2 ? "250" : "100"

f_source_tag(GridLevel item) =>
    item.futures ? "FUT " + item.source : "CFD"

f_tooltip(GridLevel item) =>
    string sourceId = item.foreign ? otherSymbol : syminfo.tickerid
    string result = "OHLClabs · NomadaScalper / GCGrid 3.2.1\n" + f_source_tag(item) + " · " + sourceId + "\n"
    result += "Source level: " + f_origin(item.origin) + " · Grid " + f_grid_tag(item) + "\n"
    result += "Chart level: " + f_price(item.mapped)
    if item.tier != 0
        result += "\nBand: " + f_price(item.mapped - item.half) + " — " + f_price(item.mapped + item.half)
    if item.foreign
        result += "\nConversion: source level + target/source spread."
        result += "\nSpread: " + (crossOffset >= 0 ? "+" : "-") + str.tostring(math.abs(crossOffset), "0.00") + " pts"
        result += manual ? " · MANUAL" : "\nMatched bar: " + str.format_time(lastPairStamp, "yyyy-MM-dd HH:mm", "America/New_York") + " NY"
        result += held ? "\nHELD: using the last matched pair; no newer aligned pair is available." : ""
        result += "\nCurrent projection across the displayed window, not historical basis."
    else
        result += "\nNative chart price. No conversion."
    result += "\nPsychological grid, not measured order-book liquidity."
    float distance = item.mapped - close
    result += "\nDistance to center: " + (distance > 0 ? "+" : "") + str.tostring(distance, "0.00") + " pts"
    result += "\nLabel shows the chart-equivalent price. Follow its connector to the exact level."
    result += item.confluent ? "\nDiamond: shared $100/$250 grid level." : ""
    result

// One line at every zoom/source count; metadata remains in the tooltip.
f_featured(GridLevel item) =>
    item.tier != 0 and math.abs(item.mapped - close) <= STEP_2 + i_half_1

f_display_price(float value) =>
    str.tostring(value, "#,##0.00")

f_columns(string firstText, string secondText, int width) =>
    firstText + str.repeat(" ", math.max(2, width - str.length(firstText) - str.length(secondText))) + secondText

f_card_height(GridLevel item, float rowUnit) =>
    rowUnit * (item.tier == 0 ? 1.45 : f_featured(item) ? 1.65 : 1.50)

// Isotonic packing moves presentation coordinates only. Source levels and band
// boundaries never move. Pixel-perfect packing at every zoom is not available in Pine.
f_pack_labels(array<float> prices, array<float> heights, float gutter) =>
    array<float> offsets = array.new_float()
    array<float> means = array.new_float()
    array<int> counts = array.new_int()
    array<float> result = array.new_float()
    float cumulative = 0.0
    for [idx, price] in prices
        if idx > 0
            cumulative += (array.get(heights, idx - 1) + array.get(heights, idx)) / 2.0 + gutter
        array.push(offsets, cumulative)
        array.push(means, price - cumulative)
        array.push(counts, 1)
        bool merging = array.size(means) >= 2
        while merging
            int n = array.size(means)
            if n >= 2 and array.get(means, n - 2) > array.get(means, n - 1)
                float rightMean = array.pop(means)
                int rightCount = array.pop(counts)
                float leftMean = array.pop(means)
                int leftCount = array.pop(counts)
                array.push(means, (leftMean * leftCount + rightMean * rightCount) / (leftCount + rightCount))
                array.push(counts, leftCount + rightCount)
            else
                merging := false
    for [idx, meanValue] in means
        int count = array.get(counts, idx)
        for j = 1 to count
            array.push(result, meanValue + array.get(offsets, array.size(result)))
    result

f_draw_band(GridLevel item, int startBar, int endBar) =>
    color semantic = item.mapped > close ? i_col_res : i_col_sup
    color sourceAccent = item.futures ? i_col_future : i_col_cfd
    bool nearLevel = math.abs(item.mapped - close) <= STEP_1 + item.half
    bool inBand = item.tier != 0 and math.abs(item.mapped - close) <= item.half
    int capBar = math.max(startBar, endBar - 2)
    int glintBar = math.max(startBar, endBar - 6)
    string stroke = item.foreign ? line.style_dashed : line.style_solid
    if item.tier == 0
        f_line(startBar, item.mapped, endBar, item.mapped, color.new(i_col_fz, 70), 1, line.style_dotted)
        f_line(glintBar, item.mapped, endBar, item.mapped, color.new(sourceAccent, 44), 1, line.style_dotted)
    else
        float bandTop = item.mapped + item.half
        float bandBottom = item.mapped - item.half
        // Five restrained facets, all contained inside the ORIGINAL +/-10 pt band.
        // Opacity indicates proximity only, never volume, strength or probability.
        f_box(startBar, bandTop, endBar, bandBottom,
             color.new(semantic, inBand ? 90 : nearLevel ? 94 : 97),
             color.new(semantic, nearLevel ? 67 : 86), stroke)
        f_box(startBar, bandTop, endBar, item.mapped,
             color.new(C_PAPER, nearLevel ? 94 : 98), na, line.style_solid)
        f_box(startBar, bandBottom + item.half * 0.14, endBar, bandBottom,
             color.new(C_SHADOW, nearLevel ? 94 : 98), na, line.style_solid)
        f_box(startBar, item.mapped + item.half * 0.10, endBar, item.mapped - item.half * 0.10,
             color.new(semantic, inBand ? 89 : nearLevel ? 93 : 97), na, line.style_solid)
        f_box(capBar, bandTop, endBar, bandBottom,
             color.new(sourceAccent, inBand ? 76 : nearLevel ? 86 : 94), na, line.style_solid)
        f_line(startBar, bandTop, endBar, bandTop, color.new(semantic, nearLevel ? 47 : 78), 1, stroke)
        f_line(endBar, bandTop, endBar, bandBottom, color.new(sourceAccent, nearLevel ? 23 : 62), 1, line.style_solid)
        if i_centerln
            f_line(startBar, item.mapped, endBar, item.mapped,
                 color.new(semantic, nearLevel ? 17 : 60), item.confluent and nearLevel ? 2 : 1, stroke)
            f_line(glintBar, item.mapped, endBar, item.mapped,
                 color.new(sourceAccent, nearLevel ? 17 : 53), 1, stroke)

f_draw_card(GridLevel item, int endBar, int labelBar, float textPrice, float rowUnit) =>
    color sourceAccent = item.futures ? i_col_future : i_col_cfd
    bool featured = f_featured(item)
    bool inBand = item.tier != 0 and math.abs(item.mapped - close) <= item.half
    bool fast = item.tier == 0
    string tip = f_tooltip(item)
    int elbowBar = labelBar - (item.foreign ? 3 : 5)
    color route = color.new(sourceAccent, fast ? 74 : featured ? 45 : 68)
    f_line(endBar, item.mapped, elbowBar, item.mapped, route, 1, line.style_solid)
    if math.abs(textPrice - item.mapped) > syminfo.mintick / 2
        f_line(elbowBar, item.mapped, elbowBar, textPrice, route, 1, line.style_solid)
    f_line(elbowBar, textPrice, labelBar, textPrice, route, 1, line.style_solid)
    string title = (item.confluent ? "◆ " : "") + f_source_tag(item) + (fast ? " FZ" : "")
    title += item.foreign and held ? " H" : ""
    // No visible origin/delta/extra metadata row. Long symbols grow naturally.
    string content = " " + f_columns(title, f_display_price(item.mapped), 26) + " "
    int pointSize = fast or not featured ? 9 : 10
    float relief = math.max(syminfo.mintick * 0.5, rowUnit * 0.035)
    float shadowDepth = math.max(syminfo.mintick, rowUnit * 0.10)
    color face = inBand ? (item.futures ? C_FACE_FUT : C_FACE_CFD) : C_BG
    // Same X, font, content and formatting across every layer. No doubled text.
    f_label_layer(labelBar, textPrice - shadowDepth, content, color.new(C_SHADOW, fast ? 87 : 81),
         color.new(sourceAccent, 100), pointSize, tip, not fast)
    if not fast
        f_label_layer(labelBar, textPrice + relief, content, color.new(sourceAccent, featured ? 30 : 51),
             color.new(sourceAccent, 100), pointSize, tip, true)
    f_label_layer(labelBar, textPrice, content, face,
         fast ? color.new(sourceAccent, 18) : sourceAccent, pointSize, tip, not fast)

// 5. Last-bar rendering. All levels remain present; only label Y is packed.
// No table/dashboard. Five original Markets inputs, same defaults and options.
if barstate.islast
    f_begin_grid()
    array<GridLevel> levels = array.new<GridLevel>()
    if chartOK
        if showNative
            f_source_levels(levels, chartFuture, false, syminfo.ticker, 0.0)
        if showForeign and crossReady
            string sourceName = chartCFD ? (manual ? array.last(str.split(i_futures, ":")) : otherTicker) : "XAUUSD"
            f_source_levels(levels, chartCFD, true, sourceName, crossOffset)
    int labelBar = bar_index + i_label_offset
    int endBar = labelBar - 10
    int startBar = math.max(0, bar_index - i_history)
    array<float> labelPrices = array.new_float()
    array<int> labelItems = array.new_int()
    for [idx, item] in levels
        f_draw_band(item, startBar, endBar)
        if item.labelOn
            array.push(labelPrices, item.mapped)
            array.push(labelItems, idx)
    array<int> sorted = array.sort_indices(labelPrices, order.ascending)
    array<float> orderedPrices = array.new_float()
    array<float> cardHeights = array.new_float()
    // Bounded price-unit estimate, not pixel geometry. No viewport input enters
    // the grid, the synchronized spread, the arrival engine or historical events.
    float rowUnit = math.max(syminfo.mintick * 4, math.min(9.0, math.max(6.0, nz(atrValue, 5.0) * 0.7)))
    for idx in sorted
        GridLevel item = array.get(levels, array.get(labelItems, idx))
        array.push(orderedPrices, array.get(labelPrices, idx))
        array.push(cardHeights, f_card_height(item, rowUnit))
    float noticeAnchor = close
    if array.size(orderedPrices) > 0
        array<float> packed = i_separate ? f_pack_labels(orderedPrices, cardHeights, rowUnit * 0.20) : array.copy(orderedPrices)
        noticeAnchor := math.max(array.last(orderedPrices), array.last(packed))
        for [positionIndex, labelIndex] in sorted
            GridLevel item = array.get(levels, array.get(labelItems, labelIndex))
            f_draw_card(item, endBar, labelBar, array.get(packed, positionIndex), rowUnit)
    string notice = not chartOK ? "GCGrid · Use standard XAUUSD or GC/MGC candles in USD" : ""
    if chartOK and showForeign and not crossReady
        notice := not autoTimeOK and not manual ? "Cross levels: use an intraday chart (1m+) or Manual spread" : not otherIdentityOK ? "Cross source unavailable · check symbol / data access" : "Cross levels · waiting for matching closed bars"
    if str.length(notice) > 0
        float noticePrice = array.size(orderedPrices) > 0 ? noticeAnchor + math.max(nz(atrValue, 10.0) * 3, 30.0) : close
        f_label_layer(labelBar, noticePrice, notice, C_BG, C_GOLD, 9,
             "Native levels remain available. Auto conversion never substitutes missing data with a zero spread. Select the source symbols in Markets, or supply a verified manual spread.")
    f_finish_grid()
````
