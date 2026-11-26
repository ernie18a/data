# CQ_(I)_Multi-Chart Widget Phases + Pivots + Fibonacci V2

- url: https://www.tradingview.com/script/cEjggYuW-CQ-I-Multi-Chart-Widget-Phases-Pivots-Fibonacci-V2/
- type: indicator
- pine_id: PUB;9e13aef4072a4074a06610a4d1ae87ff
- version: 4.0

## Description

================================================================================
 CQ_(I)_MULTI-CHART WIDGET PHASES + PIVOTS + FIBONACCI V2
 USER MANUAL
================================================================================

ATTRIBUTION
--------------------------------------------------------------------------------
This script reuses the public "Multi-Chart Widget" mini-chart rendering engine
originally published by LuxAlgo (symbol/timeframe fetching, mini candle/line/
area/volume-candle drawing, and panel layout). That portion is licensed under
Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
(CC BY-NC-SA 4.0): https://creativecommons.org/licenses/by-nc-sa/4.0/

The Zigzag / Fibonacci Retracement / Trend Pivots overlay, the arrowhead
markers, the average-leg statistics, and all related settings were added on
top of that base and are original to this script.

Because the underlying LuxAlgo code is CC BY-NC-SA 4.0, this script (and any
derivative of it) must remain non-commercial, must credit LuxAlgo, and must be
shared under the same license if redistributed.


--------------------------------------------------------------------------------
 1. WHAT THIS SCRIPT DOES
--------------------------------------------------------------------------------
This is an overlay indicator that draws up to THREE independent "mini charts"
floating to the right of the main chart, each one pulling its own symbol and
timeframe through request.security(). On top of each mini chart, the script
optionally overlays:

  - A Zigzag showing the last confirmed swing leg(s)
  - A Fibonacci retracement drawn from the most recent zigzag leg
  - Trend Pivot markers (Higher High / Lower High / Higher Low / Lower Low)
    with arrowheads and/or text labels
  - A compact info panel per mini chart (symbol, price, timeframe, RSI,
    Volatility, R-Squared)
  - Average bullish/bearish leg-size statistics

Each mini chart, and each overlay feature on it, is independently
configurable, and each mini chart can track a completely different
symbol/timeframe than the main chart and than the other two mini charts.


--------------------------------------------------------------------------------
 2. MINI CHART(S) GENERIC SETTINGS
--------------------------------------------------------------------------------
Mini Charts Separator
    Draws a vertical divider line (and horizontal dividers, when more than
    one mini chart is shown) separating the mini-chart area from the main
    chart and separating stacked mini charts from each other.

Number Of Bars
    How many bars each mini chart renders. Range 1-73 (TradingView line/box
    object limits cap how wide these can practically get). This is also the
    window used to decide which Trend Pivots are still "recent enough" to
    display (see section 6).

Horizontal Offset
    How far to the right of the current bar the mini charts begin. Range
    10-360. Increase this if the mini charts overlap your latest price
    action.


--------------------------------------------------------------------------------
 3. TOP / MIDDLE / BOTTOM MINI CHART SETTINGS
--------------------------------------------------------------------------------
Each of the three mini charts (Top, Middle, Bottom) has an identical set of
options:

Mini Chart Top/Middle/Bottom (on/off)
    Enables or disables that mini chart entirely.

Symbol
    The instrument to display. Leave blank to use the main chart's symbol.

Timeframe
    Chart, 5 Minutes, 15 Minutes, 1 Hour, 4 Hours, 1 Day, 1 Week, 1 Month.
    If you pick a timeframe lower than your chart's own timeframe, the
    script automatically falls back to the chart's timeframe (you cannot
    request a resolution finer than what your chart is currently on).

Chart Type
    Candles, Volume candles, Line, Area, Columns, High-low, Heikin Ashi.
    "Volume candles" scales candle body width by relative volume.

Chart Size
    A relative vertical size multiplier (1-5) used when stacking multiple
    mini charts in the available vertical space.

Technical Indicator
    Moving Average or None. When set to Moving Average, the moving average
    configured in section 4 is plotted on that specific mini chart.


--------------------------------------------------------------------------------
 4. MOVING AVERAGE SETTINGS
--------------------------------------------------------------------------------
Applies to any mini chart with its "Technical Indicator" set to Moving
Average.

Type      SMA, EMA, HMA, RMA, WMA, or VWMA
Source    Price source used for the calculation
Length    Lookback length
Color     Line color of the moving average overlay


--------------------------------------------------------------------------------
 5. MINI CHART(S) PANEL SETTINGS
--------------------------------------------------------------------------------
Mini Chart(s) Panel (on/off)
    Master switch for the small text panel drawn to the right of each mini
    chart (symbol, last price, timeframe, chart type).

Relative Strength Index (on/off), Source, Length
    Adds an RSI reading to the panel text, classified as Overbought /
    Bullish / Neutral / Bearish / Oversold.

Volatility (on/off), Length
    Adds a volatility reading to the panel text (ratio of the EMA of price
    change to the EMA of absolute price change).

R-Squared (on/off), Length
    Adds an R² reading (correlation strength between price and time) to the
    panel text.


--------------------------------------------------------------------------------
 6. ZIGZAG / FIBONACCI / TREND PIVOTS (PER MINI CHART, OWN TIMEFRAME)
--------------------------------------------------------------------------------
Everything in this group is calculated independently, per mini chart, using
that mini chart's own symbol and timeframe.

Enable Phases Overlay
    Master switch for the entire zigzag/Fibonacci/trend-pivot overlay. Turn
    this off to run the widget as a plain LuxAlgo-style mini-chart display
    with no extra markup.

--- Zigzag ---

Zigzag Last Leg (on/off)
    Detects swing highs/lows using a highest/lowest-bars pivot method and
    draws the last N confirmed legs as connecting lines. The most recent
    (still-forming) leg is drawn dashed and with a thicker line width; older
    legs are drawn as thin solid lines. Small circle markers cap the
    endpoints of the most recent leg.

Zigzag Period
    Lookback length used to detect swing highs and lows. Smaller = more
    sensitive/frequent swings; larger = fewer, larger swings.

Legs To Show
    How many of the most recent confirmed legs to draw (1-8).

Leg Line Width
    Line width of the most recent (dashed) leg.

Up / Down colors
    Color used for legs ending in a swing high vs. a swing low.

--- Fibonacci Retracement ---

Fibonacci Retracement (on/off)
    Draws a Fibonacci retracement grid anchored to the start and end price
    of the single most recent confirmed zigzag leg.

25% / 40% / 50% / 60% / 75% / 90%
    Individually toggle which intermediate retracement levels are drawn.
    The 0% and 100% levels (the leg's own start/end prices) are always
    drawn and use a thicker line.

Fib Label Size
    Tiny, Small, or Normal text size for the level labels.

Fib Label Layout
    Two Lines (default) shows each label as "level%" stacked above "price".
    Single Line shows them side by side as "level% price" instead.

Bullish Read / Bearish Read colors
    These two colors are used for the Fibonacci grid, but note the color
    logic is intentionally inverted from the leg's own color: if the most
    recent leg itself is drawn in the "Up" color (a teal-style color by
    default), the Fibonacci grid is drawn in the Bullish Read color
    (an orange-style color by default), and vice versa. This is a deliberate
    contrast choice so the Fibonacci grid never visually blends into the
    zigzag leg it's measuring.

--- Trend Pivots (HH/LH/HL/LL) ---

Trend Pivots (on/off)
    Detects and labels the most recent Higher High (HH), Lower High (LH),
    Higher Low (HL), and Lower Low (LL) pivots using ta.pivothigh /
    ta.pivotlow.

Trend Pivot Period
    Lookback/lookahead length used for pivot confirmation. Note that a
    pivot only confirms this many bars after it actually occurred, so very
    recent pivots may not appear until enough bars have printed.

Show Arrowheads (on/off)
    Draws a small triangular arrowhead marker pinned exactly on each pivot's
    bar/price: a down-pointing arrowhead on highs (HH/LH) and an up-pointing
    arrowhead on lows (HL/LL). Independent of whether text labels are shown.

Label Content
    Controls what text (if any) is shown alongside the arrowhead at each
    pivot:
      Labels            -> "HH" / "LH" / "HL" / "LL" text
      Tendency Arrows    -> a single directional arrow (up-right for HH/HL,
                            down-right for LH/LL) used as a quick bullish/
                            bearish tendency cue
      Both               -> the text label and the tendency arrow together
      None               -> no text label at all (arrowheads only, if
                            enabled)

HH / LH / HL / LL colors
    Independent color for each of the four pivot types, applied to both the
    arrowhead and the text label for that pivot type.

Only the single most recent pivot of each type (HH, LH, HL, LL) is ever
shown, and only if it falls within the mini chart's own visible bar window
(see "Number Of Bars" in section 2) -- older pivots that have scrolled out
of that window are automatically hidden rather than pinned to the edge.

--- Averages ---

Show Avg Leg % in Panel (on/off)
    Adds a compact "Avg ▲: x.xx%  ▼: x.xx%" line above each mini chart's
    panel, showing the rolling average size (in percent) of recent bullish
    vs. bearish zigzag legs.

Averaging Length
    How many recent bullish legs / bearish legs (tracked separately) are
    averaged for the stat above.


--------------------------------------------------------------------------------
 7. HOW TO READ THE OVERLAY
--------------------------------------------------------------------------------
- The dashed, thicker zigzag line is always the CURRENT / most recent leg.
  Thin solid lines behind it are earlier, already-confirmed legs.
- The Fibonacci grid is always measured from that same most-recent leg only
  (0% = the leg's starting price, 100% = the leg's ending price).
- Trend Pivot arrowheads/labels mark swing extremes independently of the
  zigzag -- they use their own period setting and their own pivot-detection
  logic (ta.pivothigh/ta.pivotlow), so they will not always line up exactly
  with the zigzag's own swing points.
- All drawing only happens once per bar close, on the last confirmed bar
  (barstate.islast), to keep the script light -- nothing is redrawn
  intra-bar on every tick.


--------------------------------------------------------------------------------
 8. LIMITATIONS & TROUBLESHOOTING
--------------------------------------------------------------------------------
"There isn't enough data available" warning
    Appears when your chart doesn't yet have enough bars loaded to satisfy
    Number Of Bars plus the internal warm-up length needed for the Moving
    Average / Zigzag / Trend Pivot calculations. Scroll back to load more
    history, or reduce Number Of Bars.

Market status warning
    If the main chart's own symbol has an inactive/closed market and its
    exchange doesn't match all enabled mini-chart symbols, the widget shows
    an explanatory label instead of the mini charts. Use an active primary
    symbol, or make sure mini-chart symbols share its exchange and type.

Object limits
    The script is declared with max_lines_count = 500 and
    max_labels_count = 200. With all three mini charts enabled, a high
    Number Of Bars, multiple zigzag legs, all six Fibonacci sub-levels, and
    all four trend pivots with both arrowheads and text labels turned on,
    you are pushing close to those ceilings across three mini charts at
    once. If elements start disappearing unexpectedly, reduce Number Of
    Bars, Legs To Show, or disable some Fibonacci sub-levels.

Higher-timeframe context
    Each mini chart's zigzag/Fibonacci/trend-pivot calculations run on that
    mini chart's own timeframe via request.security(), not on the main
    chart's timeframe, so swing structure shown on the mini charts can look
    different from swing structure on your main chart even for the same
    symbol.

================================================================================

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo
//@version=6

indicator('CQ_(I)_Multi-Chart Widget Phases + Auto Fibonacci Retracement + Trend Pivots', overlay = true, max_lines_count = 500, max_labels_count = 500, scale = scale.none)

//---------------------------------------------------------------------------------------------------------------------
// Settings 
//---------------------------------------------------------------------------------------------------------------------{

disp = display.all - display.status_line

genericGR = 'Mini Chart(s) Generic Settings'
separator = input.bool(true, 'Mini Charts Separator', group = genericGR)
numberOfBars = input.int(80, '  Number Of Bars', minval = 20, maxval = 100, group = genericGR, display = disp, tooltip = 'A maximum of 73 bars can be configured for each mini chart.')
hOffset = input.int(80, '  Horizontal Offset', minval = 10, maxval = 360, group = genericGR, display = disp, tooltip = 'Option range 10-360')
panelHOffset = input.int(5, '  Panel Horizontal Offset', minval = 0, maxval = 100, group = genericGR, display = disp, tooltip = 'Horizontal distance (in bars) between the mini chart\'s right edge and its info panel / stats label.')

panleGR = 'Mini Chart(s) Panel Settings'
panelSH = input.bool(true, 'Mini Chart(s) Panel', group = panleGR)

tfTT = 'This option is utilized to calculate mini charts for higher timeframes. If a timeframe lower than the chart\'s timeframe is selected, calculations will be based on the chart\'s timeframe.'
htf1GR = 'Top Mini Chart Settings'
htf1SH = input.bool(true, 'Mini Chart Top', group = htf1GR)
htf1SY = input.symbol('', '  Symbol', group = htf1GR, display = disp)
htf1TF = input.string('Chart', '  Timeframe', options = ['Chart', '5 Minutes', '15 Minutes', '1 Hour', '4 Hours', '1 Day', '1 Week', '1 Month'], group = htf1GR, display = disp, tooltip = tfTT)
htf1SZ = input.int(1, '  Chart Size', minval = 1, maxval = 5, group = htf1GR, display = disp)
htf1TI = input.string('Moving Average', '  Technical Indicator', options = ['Moving Average', 'None'], group = htf1GR, display = disp)
htf1ZZLegs = input.int(4, '  Zigzag Legs To Show', minval = 3, maxval = 8, group = htf1GR, display = disp)

htf2GR = 'Middle Mini Chart Settings'
htf2SH = input.bool(true, 'Mini Chart Middle', group = htf2GR)
htf2SY = input.symbol('', '  Symbol', group = htf2GR, display = disp)
htf2TF = input.string('Chart', '  Timeframe', options = ['Chart', '5 Minutes', '15 Minutes', '1 Hour', '4 Hours', '1 Day', '1 Week', '1 Month'], group = htf2GR, display = disp, tooltip = tfTT)
htf2SZ = input.int(1, '  Chart Size', minval = 1, maxval = 5, group = htf2GR, display = disp)
htf2TI = input.string('Moving Average', '  Technical Indicator', options = ['Moving Average', 'None'], group = htf2GR, display = disp)
htf2ZZLegs = input.int(4, '  Zigzag Legs To Show', minval = 3, maxval = 8, group = htf2GR, display = disp)

htf3GR = 'Bottom Mini Chart Settings'
htf3SH = input.bool(true, 'Mini Chart Bottom', group = htf3GR)
htf3SY = input.symbol('', '  Symbol', group = htf3GR, display = disp)
htf3TF = input.string('Chart', '  Timeframe', options = ['Chart', '5 Minutes', '15 Minutes', '1 Hour', '4 Hours', '1 Day', '1 Week', '1 Month'], group = htf3GR, display = disp, tooltip = tfTT)
htf3SZ = input.int(1, '  Chart Size', minval = 1, maxval = 5, group = htf3GR, display = disp)
htf3TI = input.string('Moving Average', '  Technical Indicator', options = ['Moving Average', 'None'], group = htf3GR, display = disp)
htf3ZZLegs = input.int(4, '  Zigzag Legs To Show', minval = 3, maxval = 8, group = htf3GR, display = disp)

maGR = 'Moving Average Settings'
maTT = 'Display various moving averages for chart/high timeframe mini charts.'
maType = input.string('SMA', '  Type', options = ['SMA', 'EMA', 'HMA', 'RMA', 'WMA', 'VWMA'], group = maGR, display = disp)
maSource = input.source(close, '  Source', group = maGR, display = disp)
maLength = input.int(5, '  Length', minval = 1, group = maGR, display = disp)
maColor = input.color(color.orange, '  Color', group = maGR)

rsiSH = input.bool(true, 'Relative Strength Index', group = panleGR)
rsiSource = input.source(close, '  Source', group = panleGR, display = disp)
rsiLength = input.int(14, '  Length', minval = 1, group = panleGR, display = disp)

vixSH = input.bool(true, 'Volatility', group = panleGR)
vixLength = input.int(20, '  Length', minval = 1, group = panleGR, display = disp)

r2SH = input.bool(true, 'R-Squared', group = panleGR)
r2Length = input.int(20, '  Length', minval = 1, group = panleGR, display = disp)

zzGR = '🌀 Zigzag/Fibonacci/Trend Pivots (per Mini Chart)'
showOverlayFeatures = input.bool(true, 'Enable Phases Overlay', group = zzGR)

showZigzag  = input.bool(true, '  Zigzag Last Leg', group = zzGR)
zzPeriod    = input.int(8, '  Zigzag Period', minval = 2, group = zzGR, display = disp)
zzLineWidth = input.int(2, '  Leg Line Width', minval = 1, maxval = 4, group = zzGR, display = disp)
zzUpColor   = input.color(#6ba583, '  Up', inline = 'zzcol', group = zzGR)
zzDnColor   = input.color(#d75442, '  Down', inline = 'zzcol', group = zzGR)

showFib      = input.bool(true, '  Show Fibonacci Retracement', group = zzGR)
fib250       = input.bool(true, '  25%', inline = 'fiblvl1', group = zzGR)
fib400       = input.bool(true, '  40%', inline = 'fiblvl1', group = zzGR)
fib500       = input.bool(true, '  50%', inline = 'fiblvl1', group = zzGR)
fib600       = input.bool(true, '  60%', inline = 'fiblvl2', group = zzGR)
fib750       = input.bool(true, '  75%', inline = 'fiblvl2', group = zzGR)
fib900       = input.bool(true, '  90%', inline = 'fiblvl2', group = zzGR)
fibLabelSize = input.string('Tiny', '  Fib Label Size', options = ['Tiny', 'Small', 'Normal'], group = zzGR, display = disp)
fibLabelLayout = input.string('Two Lines', '  Fib Label Layout', options = ['Two Lines', 'Single Line'], group = zzGR, display = disp, tooltip = 'Two Lines shows "level%" and "price" stacked. Single Line shows them side by side as "level% price".')
fibBullColor = input.color(color.rgb(255, 138, 61), '  Bullish Read', inline = 'fibcol', group = zzGR)
fibBearColor = input.color(color.rgb(38, 166, 154), '  Bearish Read', inline = 'fibcol', group = zzGR)

showTrendPivots = input.bool(true, '  Trend Pivots (HH/LH/HL/LL)', group = zzGR)
tpPeriod        = input.int(5, '  Trend Pivot Period', minval = 1, group = zzGR, display = disp)
tpShowArrowheads = input.bool(true, '  Show Arrowheads', group = zzGR)
tpArrowDownColor = input.color(color.rgb(255, 0, 0), '  Arrow Down (HH/LH)', inline = 'tparrow', group = zzGR)
tpArrowUpColor   = input.color(color.rgb(0, 255, 8), '  Arrow Up (HL/LL)', inline = 'tparrow', group = zzGR)
tpLabelContent   = input.string('Labels', '  Label Content', options = ['Labels', 'Tendency Arrows', 'Both', 'None'], group = zzGR, display = disp, tooltip = 'Text shown next to each pivot arrowhead. "Labels" = HH/LH/HL/LL, "Tendency Arrows" = ↗/↘ direction cues, "Both" = combine the two, "None" = arrowheads only.')
tpCol_HH        = input.color(color.aqua, '  HH', inline = 'tpcol1', group = zzGR)
tpCol_LH        = input.color(color.rgb(150, 235, 235), '  LH', inline = 'tpcol1', group = zzGR)
tpCol_HL        = input.color(color.rgb(255, 150, 150), '  HL', inline = 'tpcol2', group = zzGR)
tpCol_LL        = input.color(color.red, '  LL', inline = 'tpcol2', group = zzGR)

showAvgStats = input.bool(true, '  Show Avg Leg % in Panel', group = zzGR)
avgLen       = input.int(10, '  Averaging Length', minval = 2, group = zzGR, display = disp)

fibLblSz = fibLabelSize == 'Tiny' ? size.tiny : fibLabelSize == 'Small' ? size.small : size.normal

//---------------------------------------------------------------------------------------------------------------------}
// User Defined Types
//---------------------------------------------------------------------------------------------------------------------{

type htfCharts
	array<line> bars
	array<chart.point> tiBasisPoints
	polyline tiBasisLine
	label panel

//---------------------------------------------------------------------------------------------------------------------}
// Variables
//---------------------------------------------------------------------------------------------------------------------{

//---------------------------------------------------------------------------------------------------------------------}
// Functions / Methods
//---------------------------------------------------------------------------------------------------------------------{

timeframe(userTimeframe) =>
    float chartTFinM = timeframe.in_seconds() / 60

    switch 
        userTimeframe == '5 Minutes' and chartTFinM <= 5 => '5'
        userTimeframe == '15 Minutes' and chartTFinM <= 15 => '15'
        userTimeframe == '1 Hour' and chartTFinM <= 60 => '60'
        userTimeframe == '4 Hours' and chartTFinM <= 240 => '240'
        userTimeframe == '1 Day' and timeframe.isintraday => 'D'
        userTimeframe == '1 Week' and (timeframe.isdaily or timeframe.isintraday) => 'W'
        userTimeframe == '1 Month' and (timeframe.isweekly or timeframe.isdaily or timeframe.isintraday) => 'M'
        => timeframe.period

timeframeText(userTimeframe) =>
    tf = timeframe(userTimeframe)

    if not str.contains(tf, 'D') and not str.contains(tf, 'W') and not str.contains(tf, 'M') and not str.contains(tf, 'S')
        numTF = str.tonumber(tf)
        if numTF < 60
            tf + 'm'
        else
            str.tostring(numTF / 60) + 'H'
    else
        tf

syminfo(symbol) =>
    symbol != '' ? str.substring(ticker.standard(symbol), str.pos(ticker.standard(symbol), ':') + 1) : syminfo.ticker

checkExchange(chartTickerid, htf1SH, htf1SY, htf2SH, htf2SY, htf3SH, htf3SY) =>
    exchange = str.substring(chartTickerid, 0, str.pos(chartTickerid, ':'))
    (htf1SH ? str.contains(htf1SY != '' ? htf1SY : syminfo.tickerid, exchange) : true) and (htf2SH ? str.contains(htf2SY != '' ? htf2SY : syminfo.tickerid, exchange) : true) and (htf3SH ? str.contains(htf3SY != '' ? htf3SY : syminfo.tickerid, exchange) : true)

movingAverage(source, length, maType) =>
    switch maType
        'SMA' => ta.sma(source, length)
        'EMA' => ta.ema(source, length)
        'HMA' => ta.hma(source, length)
        'RMA' => ta.rma(source, length)
        'WMA' => ta.wma(source, length)
        'VWMA' => ta.vwma(source, length)

rsi(source, length) =>
    rsi = ta.rsi(source, length)

    switch 
        rsi > 70 => '\nRelative Strength: ▲ Overbought'
        rsi > 60 => '\nRelative Strength: ▲ Bullish'
        rsi > 40 => '\nRelative Strength: Neutral'
        rsi > 30 => '\nRelative Strength: ▼ Bearish'
        => '\nRelative Strength: ▼ Oversold'

volatility(length) =>
    str.tostring(math.abs(ta.ema(close - close[1], length) / ta.ema(math.abs(close - close[1]), length)), '\nVolatility: %#.##')

r2(length) =>
    str.tostring(math.pow(ta.correlation(close, bar_index, length), 2), '\nR²: %#.##')

collectData(collect, technicalIndicator, tiMaxLength, zzLegsToShowLocal) =>

    var openArray = array.new_float()
    var highArray = array.new_float()
    var lowArray = array.new_float()
    var closeArray = array.new_float()

    var tiBasisArray = array.new_float()

    // Zigzag swing-point history (index 0 = newest/still-forming tip). Enough
    // entries are kept to reconstruct the last `zzLegsToShowLocal` legs.
    var string  zzType    = ""
    var float[] zzPriceArr = array.new_float()
    var int[]   zzBarArr   = array.new_int()
    var float[] bullPctArr = array.new_float()
    var float[] bearPctArr = array.new_float()

    // Trend Pivot state — ALL pivots are retained (not just the latest of
    // each type), newest first, so every HH/LH/HL/LL within the visible
    // window can be drawn, not only the most recent one of each kind.
    var string[] tpTypeArr  = array.new_string()
    var float[]  tpPriceArr = array.new_float()
    var int[]    tpBarArr   = array.new_int()
    var float tpPrevHighVal = na
    var float tpPrevLowVal  = na

    if collect
        openArray.unshift(open)
        highArray.unshift(high)
        lowArray.unshift(low)
        closeArray.unshift(close)

        tiSource = switch technicalIndicator
            'Moving Average' => movingAverage(maSource, maLength, maType)
            => close

        tiBasisArray.unshift(tiSource)

        rsiValue = rsi(rsiSource, rsiLength)
        vixValue = volatility(vixLength)
        r2Value = r2(r2Length)

        // --- Zigzag swing point tracking (keeps enough history for N legs) ---
        zzPH = 0 == ta.highestbars(high, zzPeriod) ? high : na
        zzPL = 0 == ta.lowestbars(low, zzPeriod) ? low : na

        var int zzDir = 0
        zzDir := (not na(zzPH) and na(zzPL)) ? 1 : (not na(zzPL) and na(zzPH)) ? -1 : zzDir

        zzCap = zzLegsToShowLocal * 2 + 4

        if zzDir == 1
            if zzType != "high"
                if zzType == "low" and zzPriceArr.size() > 0
                    prevLow = zzPriceArr.get(0)
                    bullPct = (zzPH - prevLow) / prevLow * 100
                    bullPctArr.unshift(bullPct)
                    if bullPctArr.size() > avgLen
                        bullPctArr.pop()
                zzPriceArr.unshift(zzPH)
                zzBarArr.unshift(bar_index)
                zzType := "high"
                if zzPriceArr.size() > zzCap
                    zzPriceArr.pop()
                    zzBarArr.pop()
            else
                if zzPH > zzPriceArr.get(0)
                    zzPriceArr.set(0, zzPH)
                    zzBarArr.set(0, bar_index)

        if zzDir == -1
            if zzType != "low"
                if zzType == "high" and zzPriceArr.size() > 0
                    prevHigh = zzPriceArr.get(0)
                    bearPct = math.abs((zzPL - prevHigh) / prevHigh * 100)
                    bearPctArr.unshift(bearPct)
                    if bearPctArr.size() > avgLen
                        bearPctArr.pop()
                zzPriceArr.unshift(zzPL)
                zzBarArr.unshift(bar_index)
                zzType := "low"
                if zzPriceArr.size() > zzCap
                    zzPriceArr.pop()
                    zzBarArr.pop()
            else
                if zzPL < zzPriceArr.get(0)
                    zzPriceArr.set(0, zzPL)
                    zzBarArr.set(0, bar_index)

        bullAvg = bullPctArr.size() > 0 ? array.avg(bullPctArr) : float(na)
        bearAvg = bearPctArr.size() > 0 ? array.avg(bearPctArr) : float(na)

        // --- Trend Pivots (HH/LH/HL/LL) — every confirmed pivot is kept ---
        tpPH = ta.pivothigh(tpPeriod, tpPeriod)
        tpPL = ta.pivotlow(tpPeriod, tpPeriod)

        // A generous cap: comfortably above the number of pivots that can
        // realistically occur within the mini chart's own bar window, so
        // pivots never get dropped before they scroll out of view, while
        // still bounding memory/object growth on very long histories.
        tpCap = numberOfBars + tiMaxLength + 10

        if not na(tpPH)
            _peakBarH = bar_index - tpPeriod
            _typeH = na(tpPrevHighVal) or tpPH > tpPrevHighVal ? "HH" : "LH"
            tpTypeArr.unshift(_typeH)
            tpPriceArr.unshift(tpPH)
            tpBarArr.unshift(_peakBarH)
            if tpTypeArr.size() > tpCap
                tpTypeArr.pop()
                tpPriceArr.pop()
                tpBarArr.pop()
            tpPrevHighVal := tpPH

        if not na(tpPL)
            _peakBarL = bar_index - tpPeriod
            _typeL = na(tpPrevLowVal) or tpPL < tpPrevLowVal ? "LL" : "HL"
            tpTypeArr.unshift(_typeL)
            tpPriceArr.unshift(tpPL)
            tpBarArr.unshift(_peakBarL)
            if tpTypeArr.size() > tpCap
                tpTypeArr.pop()
                tpPriceArr.pop()
                tpBarArr.pop()
            tpPrevLowVal := tpPL

        // Convert stored absolute bar indices to "bars ago" HERE, inside this
        // security context, where bar_index is meaningful — same reasoning
        // as the zigzag conversion below.
        tpN = tpTypeArr.size()
        tpBarsAgoArr = array.new_int(tpN)
        if tpN > 0
            for k = 0 to tpN - 1
                array.set(tpBarsAgoArr, k, bar_index - tpBarArr.get(k))

        // Convert stored absolute bar indices to "bars ago" HERE, inside this
        // security context, where bar_index is meaningful. renderOverlay runs
        // in the main chart's context, where bar_index means something else
        // entirely — passing raw zzBarArr out and subtracting there mixes two
        // incompatible bar-index scales and silently produces garbage offsets.
        zzN = zzPriceArr.size()
        zzBarsAgoArr = array.new_int(zzN)
        if zzN > 0
            for k = 0 to zzN - 1
                array.set(zzBarsAgoArr, k, bar_index - zzBarArr.get(k))

        if closeArray.size() > numberOfBars + tiMaxLength
            openArray.pop()
            highArray.pop()
            lowArray.pop()
            closeArray.pop()
            tiBasisArray.pop()

            [openArray, highArray, lowArray, closeArray, math.min(array.slice(lowArray, 0, numberOfBars + 1).min(), array.slice(tiBasisArray, 0, numberOfBars + 1).min()), math.max(array.slice(highArray, 0, numberOfBars + 1).max(), array.slice(tiBasisArray, 0, numberOfBars + 1).max()), tiBasisArray, rsiValue, vixValue, r2Value, zzType, zzPriceArr, zzBarsAgoArr, bullAvg, bearAvg, tpTypeArr, tpPriceArr, tpBarsAgoArr]
        else
            [openArray, highArray, lowArray, closeArray, math.min(array.slice(lowArray, 0, closeArray.size()).min(), array.slice(tiBasisArray, 0, closeArray.size()).min()), math.max(array.slice(highArray, 0, closeArray.size()).max(), array.slice(tiBasisArray, 0, closeArray.size()).max()), tiBasisArray, rsiValue, vixValue, r2Value, zzType, zzPriceArr, zzBarsAgoArr, bullAvg, bearAvg, tpTypeArr, tpPriceArr, tpBarsAgoArr]

processData(htfSH, htfTF, htfSY, tiMaxLength, openArray, highArray, lowArray, closeArray, htfLST, htfHST, tiBasisArray, technicalIndicator, rsiSH, rsiValue, vixSH, vixValue, r2SH, r2Value, offset, size) =>

    if htfSH
        var htfCharts htfChart = htfCharts.new(array.new<line>(na), array.new<chart.point>(na), polyline.new(na), label(na))

        if closeArray.size() > 0

            if htfChart.bars.size() > 0
                for i = 0 to htfChart.bars.size() - 1 by 1
                    line.delete(htfChart.bars.shift())

            if technicalIndicator != 'None'
                htfChart.tiBasisPoints.clear()
                htfChart.tiBasisLine.delete()

            for index = tiMaxLength to closeArray.size() - 1 by 1

                arrayIndex = closeArray.size() - index - 1
                barIndex = hOffset + bar_index + index - tiMaxLength
                barColor = openArray.get(arrayIndex) > closeArray.get(arrayIndex) ? color.orange : color.teal

                htfChart.bars.push(line.new(barIndex, size * (openArray.get(arrayIndex) - htfLST) / (htfHST - htfLST) + offset, barIndex, size * (closeArray.get(arrayIndex) - htfLST) / (htfHST - htfLST) + offset, xloc.bar_index, extend.none, barColor, line.style_solid, 3))
                htfChart.bars.push(line.new(barIndex, size * (highArray.get(arrayIndex) - htfLST) / (htfHST - htfLST) + offset, barIndex, size * (lowArray.get(arrayIndex) - htfLST) / (htfHST - htfLST) + offset, xloc.bar_index, extend.none, barColor, line.style_solid, 1))

                if technicalIndicator != 'None' and tiBasisArray.get(arrayIndex) > 0
                    htfChart.tiBasisPoints.push(chart.point.from_index(barIndex, size * (tiBasisArray.get(arrayIndex) - htfLST) / (htfHST - htfLST) + offset))

            if technicalIndicator != 'None'
                htfChart.tiBasisLine := polyline.new(htfChart.tiBasisPoints, false, false, xloc.bar_index, maColor, color(na), line.style_solid, 1)
                htfChart.tiBasisLine

            if panelSH
                panelText = syminfo(htfSY) + ' (' + str.tostring(closeArray.first()) + ') · ' + timeframeText(htfTF) + '\n' + (rsiSH ? rsiValue : '') + (vixSH ? vixValue : '') + (r2SH ? r2Value : '')
                htfChart.panel.delete()
                htfChart.panel := label.new(hOffset + bar_index + numberOfBars + panelHOffset, size * (math.avg(htfHST, htfLST) - htfLST) / (htfHST - htfLST) + offset, panelText, color = color(na), style = label.style_label_left, textcolor = chart.fg_color, textalign = text.align_left)
                htfChart.panel
        else
            panelText = syminfo(htfSY) + '\nThere isn\'t enough data available (' + r2Value + ' bars) for the selected timeframe ' + timeframeText(htfTF)
            htfChart.panel.delete()
            htfChart.panel := label.new(hOffset + bar_index + numberOfBars, offset + 0.5, panelText, color = color(na), style = label.style_label_down, textcolor = chart.fg_color, textalign = text.align_left)
            htfChart.panel

//---------------------------------------------------------------------------------------------------------------------}
// Overlay Functions — Zigzag Last Leg / Fibonacci / Trend Pivots (per Mini Chart)
//---------------------------------------------------------------------------------------------------------------------{

f_localBar(barsAgo, closeArraySize, tiMaxLength) =>
    hOffset + bar_index + (closeArraySize - 1 - barsAgo) - tiMaxLength

f_localBarClamped(barsAgo, closeArraySize, tiMaxLength) =>
    _b = math.min(barsAgo, closeArraySize - 1)
    hOffset + bar_index + (closeArraySize - 1 - _b) - tiMaxLength

f_localY(price, htfLST, htfHST, offset, size) =>
    size * (price - htfLST) / (htfHST - htfLST) + offset

f_inWindow(barsAgo, closeArraySize, tiMaxLength) =>
    not na(barsAgo) and barsAgo >= 0 and barsAgo <= closeArraySize - tiMaxLength - 1

f_tpText(baseTxt, tendArrow, mode) =>
    switch mode
        'Labels'           => baseTxt
        'Tendency Arrows'  => tendArrow
        'Both'             => baseTxt + ' ' + tendArrow
        => ''

f_drawFibLevel(lvl, base, rangeVal, x2, htfLST, htfHST, offset, size, fibCol, lblSz, layout) =>
    _price = base + rangeVal * lvl
    _y = f_localY(_price, htfLST, htfHST, offset, size)
    _ln = line.new(x2, _y, x2 + 4, _y, xloc.bar_index, extend.none, fibCol, line.style_solid, lvl == 0.0 or lvl == 1.0 ? 2 : 1)
    _sep = layout == 'Single Line' ? ' ' : '\n'
    _lb = label.new(x2 + 4, _y, str.tostring(lvl * 100, '##') + '%' + _sep + str.tostring(_price, format.mintick), xloc.bar_index, yloc.price, color(na), label.style_label_left, fibCol, lblSz, text.align_right)
    [_ln, _lb]

renderOverlay(htfSH, htfLST, htfHST, offset, size, closeArraySize, tiMaxLength, zzType, zzPriceArr, zzBarsAgoArr, bullAvg, bearAvg, tpTypeArr, tpPriceArr, tpBarsAgoArr, zzLegsToShowLocal) =>

    if htfSH and showOverlayFeatures and closeArraySize > 0

        var line[]  zzLegLines   = array.new_line()
        var label[] zzLegCircles = array.new_label()
        var line[]  fibLines     = array.new_line()
        var label[] fibLabels    = array.new_label()
        var label[] tpArrows     = array.new_label()
        var label[] tpLabels     = array.new_label()
        var label statsLbl = na

        nPoints    = zzPriceArr.size()
        nLegsAvail = math.max(0, math.min(zzLegsToShowLocal, nPoints - 1))

        // --- Zigzag: draw the last `zzLegsToShowLocal` confirmed legs ---
        if showZigzag and nLegsAvail >= 1

            for ln in zzLegLines
                line.delete(ln)
            for lb in zzLegCircles
                label.delete(lb)
            zzLegLines.clear()
            zzLegCircles.clear()

            for i = 0 to nLegsAvail - 1
                newBarsAgo = zzBarsAgoArr.get(i)
                newPrice   = zzPriceArr.get(i)
                newIsHigh  = zzType == "high" ? i % 2 == 0 : i % 2 == 1
                oldBarsAgo = zzBarsAgoArr.get(i + 1)
                oldPrice   = zzPriceArr.get(i + 1)

                _col = newIsHigh ? zzUpColor : zzDnColor
                x1 = f_localBarClamped(oldBarsAgo, closeArraySize, tiMaxLength)
                x2 = f_localBarClamped(newBarsAgo, closeArraySize, tiMaxLength)
                y1 = f_localY(oldPrice, htfLST, htfHST, offset, size)
                y2 = f_localY(newPrice, htfLST, htfHST, offset, size)

                _ln = line.new(x1, y1, x2, y2, xloc.bar_index, extend.none, _col, i == 0 ? line.style_dashed : line.style_solid, i == 0 ? zzLineWidth : 1)
                zzLegLines.push(_ln)

                if i == 0
                    _lb1 = label.new(x1, y1, '◯', xloc.bar_index, yloc.price, color(na), label.style_label_center, _col, size.tiny)
                    _lb2 = label.new(x2, y2, '◯', xloc.bar_index, yloc.price, color(na), label.style_label_center, _col, size.tiny)
                    zzLegCircles.push(_lb1)
                    zzLegCircles.push(_lb2)

            // Fibonacci retracement from only the most recent (i = 0) leg
            if showFib
                for ln in fibLines
                    line.delete(ln)
                for lb in fibLabels
                    label.delete(lb)
                fibLines.clear()
                fibLabels.clear()

                _fibCol = zzType == "high" ? fibBullColor : fibBearColor
                // Clamp the leg's two endpoints to this mini chart's own visible price
                // range (htfLST/htfHST) before computing 0%/100%. The zigzag pivot arrays
                // cap on PIVOT COUNT, not bars-in-view, so the last leg's pivot can be
                // older than the visible window and its raw price can sit outside
                // [htfLST, htfHST] — the exact range the mini chart's local Y-scale is
                // built from. Without clamping, that pushes the fib line/labels above or
                // below the mini chart's box instead of inside it.
                _legHi  = math.min(math.max(zzPriceArr.get(0), zzPriceArr.get(1)), htfHST)
                _legLo  = math.max(math.min(zzPriceArr.get(0), zzPriceArr.get(1)), htfLST)
                // Base/range are anchored from the NEWEST pivot (index 0) back toward
                // the older end of the leg, so 0% sits at the most recent extreme and
                // 100% sits at the leg's origin — the direction retracement levels are
                // conventionally measured from.
                _base   = zzType == "high" ? _legHi : _legLo
                _range  = zzType == "high" ? (_legLo - _legHi) : (_legHi - _legLo)
                x2      = f_localBarClamped(zzBarsAgoArr.get(0), closeArraySize, tiMaxLength)              

                [l0, b0] = f_drawFibLevel(0.0, _base, _range, x2, htfLST, htfHST, offset, size, _fibCol, fibLblSz, fibLabelLayout)
                fibLines.push(l0)
                fibLabels.push(b0)
                if fib250
                    [l1, b1] = f_drawFibLevel(0.25, _base, _range, x2, htfLST, htfHST, offset, size, _fibCol, fibLblSz, fibLabelLayout)
                    fibLines.push(l1)
                    fibLabels.push(b1)
                if fib400
                    [l2, b2] = f_drawFibLevel(0.40, _base, _range, x2, htfLST, htfHST, offset, size, _fibCol, fibLblSz, fibLabelLayout)
                    fibLines.push(l2)
                    fibLabels.push(b2)
                if fib500
                    [l3, b3] = f_drawFibLevel(0.50, _base, _range, x2, htfLST, htfHST, offset, size, _fibCol, fibLblSz, fibLabelLayout)
                    fibLines.push(l3)
                    fibLabels.push(b3)
                if fib600
                    [l4, b4] = f_drawFibLevel(0.60, _base, _range, x2, htfLST, htfHST, offset, size, _fibCol, fibLblSz, fibLabelLayout)
                    fibLines.push(l4)
                    fibLabels.push(b4)
                if fib750
                    [l5, b5] = f_drawFibLevel(0.75, _base, _range, x2, htfLST, htfHST, offset, size, _fibCol, fibLblSz, fibLabelLayout)
                    fibLines.push(l5)
                    fibLabels.push(b5)
                if fib900
                    [l6, b6] = f_drawFibLevel(0.90, _base, _range, x2, htfLST, htfHST, offset, size, _fibCol, fibLblSz, fibLabelLayout)
                    fibLines.push(l6)
                    fibLabels.push(b6)
                [l7, b7] = f_drawFibLevel(1.0, _base, _range, x2, htfLST, htfHST, offset, size, _fibCol, fibLblSz, fibLabelLayout)
                fibLines.push(l7)
                fibLabels.push(b7)

        // --- Trend Pivots: ALL HH / LH / HL / LL within the visible window ---
        // Each pivot gets an optional arrowhead marker pinned exactly on the
        // pivot point (label.style_arrowdown for highs, label.style_arrowup
        // for lows), plus an optional text label offset above/below it whose
        // content (HH/LH/HL/LL text, tendency arrow, or both) is chosen by
        // tpLabelContent. Every pivot the mini chart's own window still
        // contains is drawn — not just the single most recent one of each
        // type — so the full pivot history scrolls naturally as bars age out.
        if showTrendPivots
            for lb in tpArrows
                label.delete(lb)
            for lb in tpLabels
                label.delete(lb)
            tpArrows.clear()
            tpLabels.clear()

            _tpN = tpTypeArr.size()
            if _tpN > 0
                for i = 0 to _tpN - 1
                    _barsAgo = tpBarsAgoArr.get(i)
                    if f_inWindow(_barsAgo, closeArraySize, tiMaxLength)
                        _type  = tpTypeArr.get(i)
                        _price = tpPriceArr.get(i)
                        _bx = f_localBar(_barsAgo, closeArraySize, tiMaxLength)
                        _by = f_localY(_price, htfLST, htfHST, offset, size)
                        _isHigh = _type == "HH" or _type == "LH"
                        _col  = _type == "HH" ? tpCol_HH : _type == "LH" ? tpCol_LH : _type == "HL" ? tpCol_HL : tpCol_LL
                        _text = _type == "HH" ? f_tpText('ʜʜ', '↗', tpLabelContent) : _type == "LH" ? f_tpText('ʟʜ', '↘', tpLabelContent) : _type == "HL" ? f_tpText('ʜʟ', '↗', tpLabelContent) : f_tpText('ʟʟ', '↘', tpLabelContent)

                        if tpShowArrowheads
                            _arrowTxt = _isHigh ? '▼' : '▲'
                            _arrowCol = _isHigh ? tpArrowDownColor : tpArrowUpColor
                            tpArrows.push(label.new(_bx, _by, _arrowTxt, xloc.bar_index, yloc.price, color(na), label.style_label_center, _arrowCol, size.tiny, text.align_center)) 
                        if tpLabelContent != 'None'
                            tpLabels.push(label.new(_bx, _by, _text, xloc.bar_index, yloc.price, color(na), _isHigh ? label.style_label_down : label.style_label_up, _col, size.tiny, text.align_center))

        // --- Compact avg leg % stats, placed above the mini chart's panel ---
        if showAvgStats
            _statsTxt = 'Avg ▲:' + (na(bullAvg) ? '—' : str.tostring(bullAvg, '#.##') + '%') + '  ▼:' + (na(bearAvg) ? '—' : str.tostring(bearAvg, '#.##') + '%')
            statsLbl.delete()
            statsLbl := label.new(hOffset + bar_index + numberOfBars + panelHOffset, f_localY(htfHST, htfLST, htfHST, offset, size), _statsTxt, xloc.bar_index, yloc.price, color(na), label.style_label_left, chart.fg_color, size.tiny, text.align_left)

//---------------------------------------------------------------------------------------------------------------------}
// Calculations
//---------------------------------------------------------------------------------------------------------------------{

tiMaxLength = math.max(maLength, zzPeriod, tpPeriod * 2 + 2)

htf1SY := htf1SY != '' ? ticker.standard(htf1SY) : ticker.standard(syminfo.tickerid)
[openArray1, highArray1, lowArray1, closeArray1, htfLST1, htfHST1, tiBasisArray1, rsiValue1, vixValue1, r2Value1, zzType1, zzPriceArr1, zzBarsAgoArr1, bullAvg1, bearAvg1, tpTypeArr1, tpPriceArr1, tpBarsAgoArr1] = request.security(htf1SY, timeframe(htf1TF), collectData(htf1SH, htf1TI, tiMaxLength, htf1ZZLegs), calc_bars_count = numberOfBars + tiMaxLength + 1)

htf2SY := htf2SY != '' ? ticker.standard(htf2SY) : ticker.standard(syminfo.tickerid)
[openArray2, highArray2, lowArray2, closeArray2, htfLST2, htfHST2, tiBasisArray2, rsiValue2, vixValue2, r2Value2, zzType2, zzPriceArr2, zzBarsAgoArr2, bullAvg2, bearAvg2, tpTypeArr2, tpPriceArr2, tpBarsAgoArr2] = request.security(htf2SY, timeframe(htf2TF), collectData(htf2SH, htf2TI, tiMaxLength, htf2ZZLegs), calc_bars_count = numberOfBars + tiMaxLength + 1)

htf3SY := htf3SY != '' ? ticker.standard(htf3SY) : ticker.standard(syminfo.tickerid)
[openArray3, highArray3, lowArray3, closeArray3, htfLST3, htfHST3, tiBasisArray3, rsiValue3, vixValue3, r2Value3, zzType3, zzPriceArr3, zzBarsAgoArr3, bullAvg3, bearAvg3, tpTypeArr3, tpPriceArr3, tpBarsAgoArr3] = request.security(htf3SY, timeframe(htf3TF), collectData(htf3SH, htf3TI, tiMaxLength, htf3ZZLegs), calc_bars_count = numberOfBars + tiMaxLength + 1)

var label lbWarning = na

if barstate.islast and last_bar_index > numberOfBars + tiMaxLength - 1
    lbWarning.delete()

    if barstate.isrealtime or checkExchange(syminfo.tickerid, htf1SH, htf1SY, htf2SH, htf2SY, htf3SH, htf3SY)

        processData(htf1SH, htf1TF, htf1SY, tiMaxLength, openArray1, highArray1, lowArray1, closeArray1, htfLST1, htfHST1, tiBasisArray1, htf1TI, rsiSH, rsiValue1, vixSH, vixValue1, r2SH, r2Value1, 1.1 + (htf3SH ? 1.1 + htf3SZ - 1 : 1.1) + (htf2SH ? 1.1 + htf2SZ - 1 : 0), htf1SZ)
        processData(htf2SH, htf2TF, htf2SY, tiMaxLength, openArray2, highArray2, lowArray2, closeArray2, htfLST2, htfHST2, tiBasisArray2, htf2TI, rsiSH, rsiValue2, vixSH, vixValue2, r2SH, r2Value2, 1.1 + (htf3SH ? 1.1 + htf3SZ - 1 : 1.1), htf2SZ)
        processData(htf3SH, htf3TF, htf3SY, tiMaxLength, openArray3, highArray3, lowArray3, closeArray3, htfLST3, htfHST3, tiBasisArray3, htf3TI, rsiSH, rsiValue3, vixSH, vixValue3, r2SH, r2Value3, 1.1, htf3SZ)

        renderOverlay(htf1SH, htfLST1, htfHST1, 1.1 + (htf3SH ? 1.1 + htf3SZ - 1 : 1.1) + (htf2SH ? 1.1 + htf2SZ - 1 : 0), htf1SZ, closeArray1.size(), tiMaxLength, zzType1, zzPriceArr1, zzBarsAgoArr1, bullAvg1, bearAvg1, tpTypeArr1, tpPriceArr1, tpBarsAgoArr1, htf1ZZLegs)
        renderOverlay(htf2SH, htfLST2, htfHST2, 1.1 + (htf3SH ? 1.1 + htf3SZ - 1 : 1.1), htf2SZ, closeArray2.size(), tiMaxLength, zzType2, zzPriceArr2, zzBarsAgoArr2, bullAvg2, bearAvg2, tpTypeArr2, tpPriceArr2, tpBarsAgoArr2, htf2ZZLegs)
        renderOverlay(htf3SH, htfLST3, htfHST3, 1.1, htf3SZ, closeArray3.size(), tiMaxLength, zzType3, zzPriceArr3, zzBarsAgoArr3, bullAvg3, bearAvg3, tpTypeArr3, tpPriceArr3, tpBarsAgoArr3, htf3ZZLegs)

        var line lnVertical = na
        var line lnHorizontal1 = na
        var line lnHorizontal2 = na
        if separator and (htf1SH or htf2SH or htf3SH)
            lnVertical.delete()
            lnVertical := line.new(bar_index + hOffset - 5, 2.2, bar_index + hOffset - 5, 2.2, extend = extend.both, color = color.new(color.blue, 41), width = 3)

            spCount = (htf1SH ? 1 : 0) + (htf2SH ? 1 : 0) + (htf3SH ? 1 : 0)

            if spCount > 1
                yValue = 1.15 + (htf3SH ? htf3SZ : htf2SH ? htf2SZ + 1.1 : 1)
                lnHorizontal1.delete()
                lnHorizontal1 := line.new(bar_index + hOffset - 5, yValue, bar_index + hOffset, yValue, extend = extend.right, color = color.new(color.blue, 41), width = 3)
                lnHorizontal1
            if spCount > 2
                yValue = 2.25 + (htf3SH ? htf3SZ : 1) + (htf2SH ? htf2SZ - 1 : 0)
                lnHorizontal2.delete()
                lnHorizontal2 := line.new(bar_index + hOffset - 5, yValue, bar_index + hOffset, yValue, extend = extend.right, color = color.new(color.blue, 41), width = 3)
                lnHorizontal2
    else
        txt = 'The Multi-Chart Snapshot [LuxAlgo] tool supports the display of mini charts featuring various types of instruments alongside the primary chart instrument.\n' + 'However, this functionality is subject to a limitation: the selected primary chart instrument must have an ACTIVE market status.\n\n' + 'The market for the ' + syminfo.type + ' ' + syminfo.description + '(' + syminfo.ticker + ') on the ' + syminfo.prefix(syminfo.tickerid) + ' exchange is currently CLOSED or no new data available.\n\n' + 'Options:\n -Selecting an active primary chart instrument, or\n' + ' -Ensuring that the mini chart instruments belong to the same exchange and have the same type as the primary chart instrument (' + syminfo.ticker + ').\n\n' + 'If the above conditions are met, please wait a few seconds for the data to be loaded during the initial execution.'
        lbWarning.delete()
        lbWarning := label.new(bar_index + hOffset - 5, 1.1, txt, color = color(na), style = label.style_label_left, textcolor = chart.fg_color, textalign = text.align_left)
        lbWarning
else
    txt = 'There isn\'t enough data available;\nEnsure that the number of chart bars is at least more than ' + str.tostring(numberOfBars + tiMaxLength) + '\nReducing the number of bars set for the mini charts may help.'
    lbWarning.delete()
    lbWarning := label.new(bar_index + hOffset - 5, 1.1, txt, color = color(na), style = label.style_label_left, textcolor = chart.fg_color, textalign = text.align_left)
    lbWarning

//---------------------------------------------------------------------------------------------------------------------}
````
