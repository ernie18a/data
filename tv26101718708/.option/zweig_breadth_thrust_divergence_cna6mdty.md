# Zweig Breadth Thrust + Divergence

- url: https://www.tradingview.com/script/Cna6mdtY-Zweig-Breadth-Thrust-Divergence/
- type: indicator
- pine_id: PUB;5978dee5dc94484b8d20b8b0f62a088d
- version: 1.0

## Description

█ [b]OVERVIEW[/b]

This indicator implements Martin Zweig's Breadth Thrust signal and adds a pivot-based breadth divergence detector. The thrust identifies rare, high-conviction moments when the market shifts explosively from oversold to overbought breadth within a compressed time window. The divergence layer provides ongoing analytical value between thrust events by flagging when price and breadth participation diverge at swing points.

The formula follows Greg Morris's documentation in [i]The Complete Guide to Market Breadth Indicators[/i] (2nd ed., 2015), Chapter 5. All parameters match Zweig's original specification and are configurable for experimentation.


═══════════════════════════════════════════════════════════════════


█ [b]ZWEIG BREADTH THRUST[/b]

[b]Formula[/b]

[pine]Breadth Ratio = Advances / (Advances + Declines)
Ratio EMA      = EMA(Breadth Ratio, 10)[/pine]

The indicator uses NYSE advancing and declining issues via [i]USI:ADV[/i] and [i]USI:DECL[/i].

[b]Signal logic[/b]

The thrust is a state machine with three phases:

 • [b]ARMED:[/b] The ratio EMA drops below 0.40, indicating deeply oversold breadth. The indicator begins counting bars.
 • [b]THRUST:[/b] If the ratio EMA then rises above 0.615 within 10 bars, the thrust signal fires. A green triangle marks the bar where the signal completes.
 • [b]FAILED:[/b] If 10 bars elapse without the ratio EMA reaching 0.615, the window expires and the indicator returns to idle. It must drop below 0.40 again to re-arm.

If the ratio EMA drops below 0.40 again while already armed, the bar counter resets. Per Morris: "Once it moves from below 0.4 to above it, the signal occurs when it then moves above 0.615. If it has not done that within 10 days it has to start over from below 0.4."

An orange background highlights bars where the indicator is in the armed state.

[b]Historical context[/b]

Thrust signals are rare. Morris documents 8 occurrences between 1965 and 2014: December 1971, October 1974, January 1975, August 1982, August 1984, March 2009, October 2011, and October 2013. Additional signals have fired since, including November 2023 and April 2025. Zweig's research found an average gain of 24.6% in the 11 months following a thrust, and most bull markets begin with one.


═══════════════════════════════════════════════════════════════════


█ [b]BREADTH DIVERGENCE[/b]

The divergence detector identifies when the reference index price and the breadth ratio EMA disagree at swing points:

 • [b]Bearish divergence:[/b] Price makes a higher swing high while the ratio EMA makes a lower swing high. Participation is narrowing even as price pushes to new highs.
 • [b]Bullish divergence:[/b] Price makes a lower swing low while the ratio EMA makes a higher swing low. Breadth is improving even as price deteriorates.

Swing highs and lows are identified using pivot detection with a configurable lookback (default: 5 bars left and right). Price and ratio pivots are tracked independently so they do not need to occur on the same bar. When a new ratio pivot is confirmed, it is compared against the two most recent price pivots (and vice versa) to identify the divergence pattern.

Divergences are drawn as dashed lines connecting the two ratio pivot points, with a label at the current pivot. Red dashed lines indicate bearish divergences; green dashed lines indicate bullish divergences.


═══════════════════════════════════════════════════════════════════


█ [b]INDEX OVERLAY[/b]

The Reference Index setting controls which price series is used for divergence detection:

 • [b]NYSE Composite[/b] (default): Uses [i]INDEX:NYA[/i]. The natural pairing since the breadth data is NYSE-sourced.
 • [b]S&P 500[/b]: Uses [i]SP:SPX[/i]. Useful for detecting divergences between NYSE breadth and S&P 500 price, which can reveal when the large-cap index is masking broader weakness.

[b]Important:[/b] The thrust calculation always uses NYSE breadth data regardless of the index selection. TradingView does not provide S&P 500-specific advance/decline feeds. The index toggle only affects which price series the divergence detector compares against the breadth ratio.


═══════════════════════════════════════════════════════════════════


█ [b]STATUS TABLE[/b]

A status table (position configurable) displays:

 • [b]Ratio EMA:[/b] Current value of the 10-period EMA of the breadth ratio. Color-coded green above the thrust threshold, red below the armed threshold, gray between.
 • [b]State:[/b] ARMED (orange) when the ratio EMA has dropped below 0.40 and the thrust window is open, or IDLE (gray) otherwise.
 • [b]Bars Left:[/b] Remaining bars in the thrust window before expiration.
 • [b]Last Thrust:[/b] How many bars ago the most recent thrust signal fired, or "None visible" if none has occurred in the loaded chart history.


═══════════════════════════════════════════════════════════════════


█ [b]ALERTS[/b]

Five alert conditions are available:

 • [i]Thrust Completed:[/i] The ratio EMA moved from below 0.40 to above 0.615 within the thrust window.
 • [i]Thrust Armed:[/i] The ratio EMA dropped below 0.40, opening the thrust window.
 • [i]Thrust Failed:[/i] The thrust window expired without the ratio EMA reaching 0.615.
 • [i]Bearish Divergence:[/i] Price made a higher high while the breadth ratio EMA made a lower high.
 • [i]Bullish Divergence:[/i] Price made a lower low while the breadth ratio EMA made a higher low.


═══════════════════════════════════════════════════════════════════


█ [b]SETTINGS[/b]

[b]Zweig Breadth Thrust[/b]
 • EMA Length: Period for the exponential moving average of the breadth ratio. Default: 10.
 • Low Threshold (Armed): The ratio EMA must drop below this level to arm the thrust. Default: 0.40.
 • High Threshold (Thrust): The ratio EMA must rise above this level to complete the thrust. Default: 0.615.
 • Thrust Window (bars): Maximum number of bars allowed between arming and thrust completion. Default: 10.

[b]Divergence Detection[/b]
 • Pivot Lookback: Number of bars to the left and right for pivot detection. Default: 5.
 • Show Divergences: Toggle divergence lines and labels on or off.

[b]Index Overlay[/b]
 • Reference Index: NYSE Composite or S&P 500. Controls which price series is used for divergence detection.

[b]Display[/b]
 • Show Status Table: Toggle the status table.
 • Show Armed Background: Toggle the orange background highlight during armed windows.
 • Table Position: Top-right, top-left, bottom-right, or bottom-left.


═══════════════════════════════════════════════════════════════════


█ [b]METHODOLOGY NOTES[/b]

Morris tested modifications to Zweig's original parameters, including substituting a simple moving average for the EMA and shortening the EMA period to 8. Neither improved results. The defaults in this indicator match the canonical formulation.

The divergence detector uses the breadth ratio EMA (not price) as the primary series for drawing lines. This keeps all visual elements in the indicator's own pane. The price comparison happens internally using pivots from the selected reference index.

This indicator is designed for daily charts. On intraday timeframes, the breadth data resolves to daily values via [i]request.security[/i], so the thrust logic will still operate on daily bars regardless of the chart timeframe.


═══════════════════════════════════════════════════════════════════


█ [b]PROVENANCE AND ATTRIBUTION[/b]

The Zweig Breadth Thrust is universally attributed to Martin Zweig (1942-2013), who published [i]The Zweig Forecast[/i] newsletter from 1971 to 1997 and wrote [i]Winning on Wall Street[/i] (Warner Books, 1986; revised edition 1994). The specific 0.40 / 0.615 / 10-day formulation does not appear in the 1986 first edition but is present in the 1994 revised edition (pp. 121-129). Whether the indicator was first published in the book or in the newsletter is unclear from available sources.

The formula documented in this indicator follows Greg Morris, [i]The Complete Guide to Market Breadth Indicators[/i] (2nd ed., 2015), Chapter 5: Advance-Decline Ratio Indicators. Morris credits Zweig as the creator and provides the most rigorous published documentation of the methodology, including his own commentary on common misimplementations.

Additional references:
 • Arthur Hill, StockCharts.com commentary on the Zweig Breadth Thrust (2023)
 • Tom McClellan, McClellan Financial Publications

## Source Code

````pine
// Zweig Breadth Thrust + Breadth Divergence Detector
// ═══════════════════════════════════════════════════════════════
//
// Implements Martin Zweig's Breadth Thrust signal as documented by
// Greg Morris in "The Complete Guide to Market Breadth Indicators"
// (2nd ed., 2015), Chapter 5: Advance-Decline Ratio Indicators.
//
// Formula (Morris):
//   Breadth Ratio = Advances / (Advances + Declines)
//   Smoothed with a 10-bar EMA
//   Thrust signal: ratio moves from below 0.40 to above 0.615
//   within 10 trading days (bars on a daily chart)
//
// Morris clarifies: "Once it moves from below 0.4 to above it, the
// signal occurs when it then moves above 0.615. If it has not done
// that within 10 days it has to start over from below 0.4."
//
// The divergence layer detects when price makes a new swing high/low
// but the breadth ratio EMA fails to confirm, identifying potential
// exhaustion points.
//
// Data: NYSE breadth via USI:ADV and USI:DECL. TradingView does not
// provide S&P 500-specific advance/decline feeds, so the thrust
// calculation always uses NYSE data regardless of the index overlay
// selection. The index overlay setting controls which price series
// is used for divergence detection and the reference price plot.
//
// Attribution:
//   Creator: Martin Zweig
//   Formula reference: Greg Morris, "The Complete Guide to Market
//     Breadth Indicators" (2015), Chapter 5
//   Additional reference: Martin Zweig, "Winning on Wall Street"
//     (revised ed., 1994), pp. 121-129
//   The Zweig Forecast newsletter (1971-1997)
//
// NOTE ON PROVENANCE: The specific 0.40/0.615/10-day formulation is
// universally attributed to Zweig but does not appear in the 1986
// first edition of "Winning on Wall Street." It appears in the 1994
// revised edition and is formally documented by Morris. Whether the
// indicator originated in the book or in The Zweig Forecast newsletter
// is unclear from available sources.
//
// ═══════════════════════════════════════════════════════════════

//@version=6
indicator("Zweig Breadth Thrust + Divergence", shorttitle = "ZBT+Div", overlay = false, max_labels_count = 500)

// ─────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────

string  GRP_ZBT = "Zweig Breadth Thrust"
int     emaLen  = input.int(10,    title = "EMA Length",             group = GRP_ZBT, minval = 2)
float   loThr   = input.float(0.40,  title = "Low Threshold (Armed)", group = GRP_ZBT, minval = 0.0, maxval = 1.0, step = 0.01)
float   hiThr   = input.float(0.615, title = "High Threshold (Thrust)", group = GRP_ZBT, minval = 0.0, maxval = 1.0, step = 0.01)
int     window  = input.int(10,    title = "Thrust Window (bars)",   group = GRP_ZBT, minval = 1)

string  GRP_DIV = "Divergence Detection"
int     pivotLB = input.int(5,     title = "Pivot Lookback (bars L/R)", group = GRP_DIV, minval = 1, maxval = 20)
bool    showDiv = input.bool(true, title = "Show Divergences",          group = GRP_DIV)

string  GRP_OVL = "Index Overlay"
string  idxChoice = input.string("NYSE Composite", title = "Reference Index", group = GRP_OVL, options = ["NYSE Composite", "S&P 500"])

string  GRP_VIS = "Display"
bool    showTable   = input.bool(true,  title = "Show Status Table",    group = GRP_VIS)
bool    showBG      = input.bool(true,  title = "Show Armed Background", group = GRP_VIS)
string  tblPos      = input.string("top_right", title = "Table Position", group = GRP_VIS, options = ["top_right", "top_left", "bottom_right", "bottom_left"])

// ─────────────────────────────────────────────────────────────
// DATA
// ─────────────────────────────────────────────────────────────

float advances = request.security("USI:ADV",  "D", close)
float declines = request.security("USI:DECL", "D", close)

// Reference index for divergence detection
string idxSym = idxChoice == "S&P 500" ? "SP:SPX" : "INDEX:NYA"
float  idxClose = request.security(idxSym, "D", close)

// ─────────────────────────────────────────────────────────────
// BREADTH RATIO + EMA
// ─────────────────────────────────────────────────────────────

float totalIssues = advances + declines
float rawRatio    = totalIssues > 0 ? advances / totalIssues : na
float ratioEMA    = ta.ema(rawRatio, emaLen)

// ─────────────────────────────────────────────────────────────
// ZWEIG BREADTH THRUST STATE MACHINE
// ─────────────────────────────────────────────────────────────
// States:
//   IDLE   - waiting for ratio EMA to drop below loThr
//   ARMED  - ratio EMA dropped below loThr; counting bars
//   THRUST - signal fired (ratio EMA crossed above hiThr within window)
//   FAILED - window expired without thrust

var bool  isArmed        = false
var int   armedBar       = 0
var int   barsSinceArmed = 0
var bool  thrustSignal   = false
var bool  thrustFailed   = false
var bool  thrustArmed    = false
var int   lastThrustBar  = 0

thrustSignal := false  // reset each bar; only true on the thrust bar
thrustFailed := false
thrustArmed  := false

if not na(ratioEMA)
    if not isArmed
        // Check for arming: EMA drops below low threshold
        if ratioEMA < loThr
            isArmed        := true
            armedBar       := bar_index
            barsSinceArmed := 0
            thrustArmed    := true
    else
        barsSinceArmed := bar_index - armedBar
        if ratioEMA > hiThr
            // Thrust fires
            thrustSignal := true
            lastThrustBar := bar_index
            isArmed      := false
        else if barsSinceArmed > window
            // Window expired, disarm
            thrustFailed := true
            isArmed      := false
        // If EMA drops below loThr again while armed, reset the counter
        // (per Morris: "it has to start over from below 0.4")
        if ratioEMA < loThr and barsSinceArmed > 0
            armedBar       := bar_index
            barsSinceArmed := 0

// Bars remaining in window (for status table)
int barsRemaining = isArmed ? math.max(0, window - barsSinceArmed) : 0

// ─────────────────────────────────────────────────────────────
// DIVERGENCE DETECTION
// ─────────────────────────────────────────────────────────────
// Pivot-based swing detection on both price and breadth ratio EMA.
// Price and ratio pivots are tracked independently. When a new
// ratio pivot is confirmed, it is compared against the most recent
// price pivot (and vice versa) to identify divergences.
//
// Bearish divergence: price higher high + ratio lower high
// Bullish divergence: price lower low  + ratio higher low

float pricePivotHigh = ta.pivothigh(idxClose, pivotLB, pivotLB)
float pricePivotLow  = ta.pivotlow(idxClose, pivotLB, pivotLB)
float ratioPivotHigh = ta.pivothigh(ratioEMA, pivotLB, pivotLB)
float ratioPivotLow  = ta.pivotlow(ratioEMA, pivotLB, pivotLB)

int pivotOffset = pivotLB  // pivots are confirmed pivotLB bars ago

// Track the two most recent price pivots
var float currPriceHigh  = na
var int   currPriceHBar  = na
var float prevPriceHigh  = na
var int   prevPriceHBar  = na

var float currPriceLow   = na
var int   currPriceLBar  = na
var float prevPriceLow   = na
var int   prevPriceLBar  = na

// Track the two most recent ratio pivots
var float currRatioHigh  = na
var int   currRatioHBar  = na
var float prevRatioHigh  = na
var int   prevRatioHBar  = na

var float currRatioLow   = na
var int   currRatioLBar  = na
var float prevRatioLow   = na
var int   prevRatioLBar  = na

var bool bearDiv = false
var bool bullDiv = false
bearDiv := false
bullDiv := false

if showDiv
    // Update price pivot tracking
    if not na(pricePivotHigh)
        prevPriceHigh := currPriceHigh
        prevPriceHBar := currPriceHBar
        currPriceHigh := pricePivotHigh
        currPriceHBar := bar_index - pivotOffset

    if not na(pricePivotLow)
        prevPriceLow  := currPriceLow
        prevPriceLBar := currPriceLBar
        currPriceLow  := pricePivotLow
        currPriceLBar := bar_index - pivotOffset

    // Update ratio pivot tracking and check for divergences
    if not na(ratioPivotHigh)
        prevRatioHigh := currRatioHigh
        prevRatioHBar := currRatioHBar
        currRatioHigh := ratioPivotHigh
        currRatioHBar := bar_index - pivotOffset

        // Check bearish divergence: compare current vs previous ratio highs,
        // and the price highs nearest to each ratio high
        if not na(prevRatioHigh) and not na(currPriceHigh) and not na(prevPriceHigh)
            if currPriceHigh > prevPriceHigh and currRatioHigh < prevRatioHigh
                bearDiv := true
                line.new(prevRatioHBar, prevRatioHigh, currRatioHBar, currRatioHigh, color = color.red, width = 2, style = line.style_dashed)
                label.new(currRatioHBar, currRatioHigh, "Bear\nDiv", color = color.new(color.red, 80), textcolor = color.red, style = label.style_label_down, size = size.small)

    if not na(ratioPivotLow)
        prevRatioLow  := currRatioLow
        prevRatioLBar := currRatioLBar
        currRatioLow  := ratioPivotLow
        currRatioLBar := bar_index - pivotOffset

        // Check bullish divergence: compare current vs previous ratio lows,
        // and the price lows nearest to each ratio low
        if not na(prevRatioLow) and not na(currPriceLow) and not na(prevPriceLow)
            if currPriceLow < prevPriceLow and currRatioLow > prevRatioLow
                bullDiv := true
                line.new(prevRatioLBar, prevRatioLow, currRatioLBar, currRatioLow, color = color.green, width = 2, style = line.style_dashed)
                label.new(currRatioLBar, currRatioLow, "Bull\nDiv", color = color.new(color.green, 80), textcolor = color.green, style = label.style_label_up, size = size.small)

// ─────────────────────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────────────────────

// Ratio EMA
color ratioColor = ratioEMA >= hiThr ? color.green : ratioEMA <= loThr ? color.red : color.new(color.gray, 20)
plot(ratioEMA, title = "Breadth Ratio EMA", color = ratioColor, linewidth = 2)

// Threshold lines
hline(hiThr, title = "Thrust Threshold (0.615)", color = color.new(color.green, 60), linestyle = hline.style_dashed)
hline(loThr, title = "Armed Threshold (0.40)",   color = color.new(color.red, 60),   linestyle = hline.style_dashed)
hline(0.50,  title = "Midline",                  color = color.new(color.gray, 80),  linestyle = hline.style_dotted)

// Fill between thresholds
fill_hi = plot(hiThr, display = display.none)
fill_lo = plot(loThr, display = display.none)
fill(fill_hi, fill_lo, color = color.new(color.yellow, 92), title = "Thrust Zone")

// Armed background
bgcolor(showBG and isArmed ? color.new(color.orange, 90) : na, title = "Armed Window")

// Thrust signal marker
plotshape(thrustSignal, title = "Thrust Signal", style = shape.triangleup, location = location.bottom, color = color.green, size = size.small, text = "THRUST")

// ─────────────────────────────────────────────────────────────
// STATUS TABLE
// ─────────────────────────────────────────────────────────────

// Table position mapping
string tblPosVal = switch tblPos
    "top_right"    => position.top_right
    "top_left"     => position.top_left
    "bottom_right" => position.bottom_right
    "bottom_left"  => position.bottom_left
    => position.top_right

var table tbl = table.new(tblPosVal, 2, 6, bgcolor = color.new(color.black, 20), border_width = 1, border_color = color.new(color.gray, 60), frame_width = 1, frame_color = color.new(color.gray, 40))

if showTable and barstate.islast

    // Header
    table.cell(tbl, 0, 0, "Zweig Breadth Thrust",  text_color = color.white, text_size = size.small, bgcolor = color.new(color.blue, 40), text_halign = text.align_left)
    table.cell(tbl, 1, 0, idxChoice,                text_color = color.white, text_size = size.small, bgcolor = color.new(color.blue, 40), text_halign = text.align_right)

    // Current ratio
    table.cell(tbl, 0, 1, "Ratio EMA",   text_color = color.white, text_size = size.tiny, text_halign = text.align_left)
    table.cell(tbl, 1, 1, str.tostring(ratioEMA, "#.###"), text_color = ratioColor, text_size = size.tiny, text_halign = text.align_right)

    // State
    string stateStr = isArmed ? "ARMED" : "IDLE"
    color  stateClr = isArmed ? color.orange : color.gray
    table.cell(tbl, 0, 2, "State",   text_color = color.white, text_size = size.tiny, text_halign = text.align_left)
    table.cell(tbl, 1, 2, stateStr,  text_color = stateClr,    text_size = size.tiny, text_halign = text.align_right)

    // Bars remaining
    table.cell(tbl, 0, 3, "Bars Left",  text_color = color.white, text_size = size.tiny, text_halign = text.align_left)
    table.cell(tbl, 1, 3, isArmed ? str.tostring(barsRemaining) : "n/a", text_color = isArmed ? color.orange : color.gray, text_size = size.tiny, text_halign = text.align_right)

    // Last thrust
    int thrustAge = lastThrustBar > 0 ? bar_index - lastThrustBar : -1
    string thrustStr = thrustAge >= 0 ? str.tostring(thrustAge) + " bars ago" : "None visible"
    table.cell(tbl, 0, 4, "Last Thrust", text_color = color.white, text_size = size.tiny, text_halign = text.align_left)
    table.cell(tbl, 1, 4, thrustStr,     text_color = thrustAge >= 0 ? color.green : color.gray, text_size = size.tiny, text_halign = text.align_right)

    // Data source note
    table.cell(tbl, 0, 5, "Data: NYSE breadth (USI:ADV/DECL)", text_color = color.new(color.gray, 40), text_size = size.tiny, text_halign = text.align_left)
    table.cell(tbl, 1, 5, "", text_size = size.tiny)

// ─────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────

alertcondition(thrustSignal,  title = "Thrust Completed",  message = "Zweig Breadth Thrust signal fired! Ratio EMA moved from below 0.40 to above 0.615 within the thrust window.")
alertcondition(thrustArmed,   title = "Thrust Armed",      message = "Zweig Breadth Thrust armed: ratio EMA dropped below 0.40. Watching for thrust.")
alertcondition(thrustFailed,  title = "Thrust Failed",     message = "Zweig Breadth Thrust window expired without firing.")
alertcondition(bearDiv,       title = "Bearish Divergence", message = "Bearish breadth divergence: price made higher high but breadth ratio EMA made lower high.")
alertcondition(bullDiv,       title = "Bullish Divergence", message = "Bullish breadth divergence: price made lower low but breadth ratio EMA made higher low.")
````
