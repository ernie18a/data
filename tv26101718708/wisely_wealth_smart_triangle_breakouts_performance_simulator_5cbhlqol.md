# Wisely Wealth ; Smart Triangle Breakouts & Performance Simulator

- url: https://www.tradingview.com/script/5cBhlQOl-Wisely-Wealth-Smart-Triangle-Breakouts-Performance-Simulator/
- type: indicator
- pine_id: PUB;0e877330d50144a7ada57fd0e32b7ebe
- version: 1.0

## Description

**Introduction**
The **"Smart Triangle Breakouts & Performance Simulator"** script is an automated technical analysis tool designed to identify and visualize Triangle chart patterns on your TradingView charts. The primary purpose of this script is to detect three key variations of triangle patterns: Ascending, Descending, and Symmetrical. Beyond merely plotting these patterns, the script features a built-in trade simulator. This simulator allows traders to backtest breakout strategies associated with these patterns, providing valuable insights into potential performance before risking real capital.

**Working Mechanism**
The script operates by systematically analyzing historical price data to identify specific market structures that form triangle patterns:
* **Swing Point Detection:** The foundation of the script's logic relies on identifying significant peaks and valleys in price action, known as Swing Highs and Swing Lows. It utilizes the `ta.pivothigh()` and `ta.pivotlow()` functions to locate these points based on the parameters set in the 'Swing Left Bars' and 'Swing Right Bars' inputs. These parameters determine how many preceding and succeeding bars must have lower highs or higher lows to confirm a valid swing point.

* **Trendline Construction:** Once enough swing points are identified, the script attempts to fit trendlines connecting them. It doesn't just connect any two points; it requires a minimum number of touches (defined by 'Touches per Trendline') and allows for slight price deviations using an ATR-based tolerance ('ATR Tolerance Multiplier'). This ensures the trendlines are robust and reflect significant market boundaries, rather than just random price spikes.

* **Pattern Classification:** After establishing the upper and lower trendlines, the script analyzes their slopes and relationship to classify the resulting pattern:
* **Ascending Triangle:** Characterized by a relatively flat horizontal upper resistance line and a rising lower support line.

* **Descending Triangle:** Characterized by a falling upper resistance line and a relatively flat horizontal lower support line.

* **Symmetrical Triangle:** Characterized by converging upper falling and lower rising trendlines that have relatively balanced slopes.

* **Breakout Signal Generation:** The script continuously monitors the price action relative to the established trendlines of an active pattern. When the price decisively crosses a trendline boundary (a breakout or breakdown), it triggers a signal. The user can configure whether this trigger is based on the closing price ('Close') or intraday price extremes ('Wick').

**How to Use**
* **Configuration:** The 'Swing Left Bars' and 'Swing Right Bars' settings are crucial for determining the scale of the patterns detected. Higher values will filter out market noise and identify larger, higher-timeframe structures, while lower values will detect smaller, shorter-term patterns faster. Adjust these based on your trading style and time horizon.

* **Market Suitability:** This script can be applied to any market available on TradingView, including stocks, forex, crypto, and commodities. However, triangle patterns are generally more reliable in trending markets where there's a clear underlying bias.

* **Complementary Analysis:** It is important to note that the "Smart Triangle Breakouts & Performance Simulator" is designed to identify patterns, not provide standalone financial advice. It should be used in conjunction with other technical indicators (like RSI, MACD, or volume analysis) and fundamental analysis to confirm signals and improve overall trading decisions.

* **Utilizing the Trade Simulator:** The integrated simulator is a powerful feature for testing and optimizing your strategy. It allows you to simulate trades based on the detected breakouts, track performance metrics like win rate and profit factor, and experiment with different Take Profit (TP) and Stop Loss (SL) methods (such as fixed Risk:Reward ratios or ATR-based stops) directly on the chart. Use the simulator to refine your approach before deploying real funds.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradingView Expert Developer

//@version=6
indicator("Wisely Wealth ; Smart Triangle Breakouts & Performance Simulator", shorttitle = "Smart Triangle Sim", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// =============================================================================
// INPUTS & CONFIGURATION
// =============================================================================

// ── Detection Settings ──
grpDetect     = "Detection Settings"
pivLeft       = input.int(5, "Swing Left Bars", minval = 1, group = grpDetect, tooltip = "Number of preceding bars that must have lower highs or higher lows to establish a valid swing point. Higher values identify larger, higher-timeframe structures.")
pivRight      = input.int(5, "Swing Right Bars", minval = 1, group = grpDetect, tooltip = "Number of subsequent bars required to confirm a swing point. Lower values detect patterns faster, while higher values ensure stronger structural pivots with slight confirmation delay.")
touches       = input.int(2, "Touches per Trendline", minval = 2, maxval = 4, group = grpDetect, tooltip = "Minimum number of swing points each trendline must connect. Setting to 2 uses the two most recent pivots; higher values require intermediate pivots to align within ATR tolerance.")
fitTolATR     = input.float(0.5, "ATR Tolerance Multiplier", minval = 0.05, step = 0.05, group = grpDetect, tooltip = "Multiplied by ATR to set the tolerance boundary. Allows candles or intermediate swing points to poke slightly outside trendlines without invalidating the pattern.")
atrLength     = input.int(14, "ATR Length", minval = 1, group = grpDetect, tooltip = "Lookback period for the Average True Range (ATR) calculation, used for line fitting tolerances and volatility-based stop loss sizing.")
flatTolPct    = input.float(25.0, "Flat Slope Tolerance (% of Height)", minval = 5.0, maxval = 50.0, step = 5.0, group = grpDetect, tooltip = "Maximum allowed price variance across the pattern as a percentage of initial triangle height to classify a trendline as horizontal or flat.")
symRatioMax   = input.float(3.0, "Symmetry Max Slope Ratio", minval = 1.1, maxval = 10.0, step = 0.5, group = grpDetect, tooltip = "Maximum ratio between the steeper slope and gentler slope in Symmetrical triangles. Ensures both upper and lower trendlines converge at balanced angles.")
minPatternLen = input.int(12, "Min Pattern Length (Bars)", minval = 5, group = grpDetect, tooltip = "Minimum number of bars required between the earliest and most recent anchor pivots to prevent tiny or insignificant formations from triggering.")
maxPatternLen = input.int(200, "Max Pattern Length (Bars)", minval = 20, maxval = 500, group = grpDetect, tooltip = "Maximum bars permitted from the triangle's starting anchor to its projected apex. Patterns exceeding this duration without a breakout are marked expired.")

// ── Pattern Types Filter ──
grpTypes      = "Pattern Types Filter"
showAsc       = input.bool(true, "Show Ascending Triangles", group = grpTypes, tooltip = "Toggles detection of Ascending Triangles, characterized by a flat horizontal upper resistance line and a rising lower support line.")
showDesc      = input.bool(true, "Show Descending Triangles", group = grpTypes, tooltip = "Toggles detection of Descending Triangles, characterized by a falling upper resistance line and a flat horizontal lower support line.")
showSym       = input.bool(true, "Show Symmetrical Triangles", group = grpTypes, tooltip = "Toggles detection of Symmetrical Triangles, characterized by converging upper falling and lower rising trendlines with balanced slopes.")

// ── Breakout & Signal Settings ──
grpBreakout   = "Breakout & Signal Settings"
breakSource   = input.string("Close", "Breakout Trigger", options = ["Close", "Wick (High/Low)"], group = grpBreakout, tooltip = "Determines whether a breakout triggers when the bar Close crosses the trendline or immediately when the High/Low wick pierces the boundary.")
signalClose   = input.bool(true, "Signal Only on Bar Close (Anti-Repaint)", group = grpBreakout, tooltip = "When enabled, breakout signals only trigger after the candle has fully closed, completely eliminating intra-bar repainting.")
showSignals   = input.bool(true, "Plot Buy / Sell Signals", group = grpBreakout, tooltip = "Displays green Up Arrows below bullish breakout bars and red Down Arrows above bearish breakdown bars.")

// ── Trade Simulator Settings ──
grpSim        = "Trade Simulator Settings"
enableSim     = input.bool(true, "Enable Trade Simulator", group = grpSim, tooltip = "Activates the built-in paper trading engine to simulate trade execution, track win rate, profit factor, and net returns directly on the chart.")
tradeDir      = input.string("Both", "Allowed Directions", options = ["Both", "Long Only", "Short Only"], group = grpSim, tooltip = "Selects which trade directions the simulator executes: Both Long and Short, Long Only (bullish breakouts), or Short Only (bearish breakdowns).")
tpMethod      = input.string("Risk:Reward (R:R)", "Take Profit Method", options = ["Risk:Reward (R:R)", "Triangle Height", "ATR Multiple"], group = grpSim, tooltip = "Formula used to calculate Take Profit targets: a fixed Risk-to-Reward ratio, 100% projection of the triangle opening height, or an ATR multiple.")
rrRatio       = input.float(2.0, "Risk:Reward Ratio (R:R)", minval = 0.5, maxval = 10.0, step = 0.1, group = grpSim, tooltip = "The Risk:Reward ratio used to set Take Profit targets when Risk:Reward is selected. For example, 2.0 targets twice the risk distance.")
slMethod      = input.string("ATR Multiple", "Stop Loss Method", options = ["ATR Multiple", "Opposite Line / Apex", "Pattern Midpoint"], group = grpSim, tooltip = "Determines Stop Loss placement: based on an ATR multiple from entry, the triangle apex/opposite trendline, or the pattern midpoint.")
slAtrMult     = input.float(1.5, "SL ATR Multiplier", minval = 0.2, maxval = 10.0, step = 0.1, group = grpSim, tooltip = "Multiplier applied to the Average True Range (ATR) to define the Stop Loss distance from the entry price when using ATR-based stops.")
showTradeVisuals = input.bool(true, "Draw TP / SL Zones on Chart", group = grpSim, tooltip = "Draws green profit target boxes and red stop-loss risk zones on the chart for each simulated trade.")
maxVisTrades  = input.int(20, "Max Visual Trade Boxes", minval = 5, maxval = 100, group = grpSim, tooltip = "Maximum number of simulated trade TP/SL boxes retained on the chart. Older boxes are automatically deleted to maintain performance.")

// ── Dashboard Settings ──
grpDash       = "Dashboard Settings"
showDash      = input.bool(true, "Show Performance Dashboard", group = grpDash, tooltip = "Toggles the on-chart performance dashboard displaying win rate, total trades, profit factor, net R profit, and pattern breakdown.")
dashLoc       = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = grpDash, tooltip = "Specifies which corner of the chart the performance dashboard is anchored to.")
dashSize      = input.string("Small", "Dashboard Text Size", options = ["Tiny", "Small", "Normal"], group = grpDash, tooltip = "Sets the text and cell dimensions of the performance dashboard.")

// ── Style & Visuals ──
grpStyle      = "Style & Visuals"
colAsc        = input.color(color.rgb(0, 188, 212), "Ascending Color", group = grpStyle, tooltip = "Outline color and base tint for detected Ascending Triangle patterns.")
colDesc       = input.color(color.rgb(255, 82, 82), "Descending Color", group = grpStyle, tooltip = "Outline color and base tint for detected Descending Triangle patterns.")
colSym        = input.color(color.rgb(171, 71, 188), "Symmetrical Color", group = grpStyle, tooltip = "Outline color and base tint for detected Symmetrical Triangle patterns.")
colBuy        = input.color(color.rgb(0, 230, 118), "BUY Arrow Color", group = grpStyle, tooltip = "Color of the Up Arrow plot for bullish breakout buy signals.")
colSell       = input.color(color.rgb(255, 23, 68), "SELL Arrow Color", group = grpStyle, tooltip = "Color of the Down Arrow plot for bearish breakdown sell signals.")
lineWidth     = input.int(2, "Trendline Width", minval = 1, maxval = 4, group = grpStyle, tooltip = "Thickness of the triangle upper and lower trendlines in pixels.")
showFill      = input.bool(true, "Fill Triangle Background", group = grpStyle, tooltip = "Fills the background area between the upper and lower trendlines with the pattern's assigned color.")
fillTransp    = input.int(85, "Fill Transparency (%)", minval = 0, maxval = 100, group = grpStyle, tooltip = "Controls background fill transparency (0 = opaque, 100 = invisible).")
showLabels    = input.bool(true, "Show Pattern Labels", group = grpStyle, tooltip = "Displays pattern identification tags and lifecycle status badges at the start of each triangle.")
maxTriangles  = input.int(30, "Max Stored Historical Patterns", minval = 5, maxval = 100, group = grpStyle, tooltip = "Maximum number of historical triangle drawings preserved on the chart before oldest lines and labels are cleaned up.")

// =============================================================================
// CUSTOM TYPES
// =============================================================================

type Pivot
    int   x
    float y

type Triangle
    string   kind           // "Ascending", "Descending", "Symmetrical"
    int      startX         // Bar index where triangle begins (earliest anchor)
    float    startUpperY    // Upper line price at startX
    float    startLowerY    // Lower line price at startX
    int      anchorUpperX   // Reference pivot X for upper line
    float    anchorUpperY   // Reference pivot Y for upper line
    float    slopeUpper     // Upper line slope (price delta per bar)
    int      anchorLowerX   // Reference pivot X for lower line
    float    anchorLowerY   // Reference pivot Y for lower line
    float    slopeLower     // Lower line slope (price delta per bar)
    int      apexX          // Projected intersection bar index
    float    apexY          // Projected intersection price
    int      lastPivotX     // Most recent pivot bar index included in the triangle
    line     upperLine      // Upper boundary line object
    line     lowerLine      // Lower boundary line object
    linefill fillArea       // Shaded background area
    label    patternLabel   // Diagnostic/name label
    bool     isActive       // True while monitoring for breakouts, false when resolved/expired
    int      resolvedBar    // Bar index where breakout or expiration occurred
    string   status         // "Active", "Bull Breakout", "Bear Breakdown", "Expired"

// =============================================================================
// HELPER FUNCTIONS & MATH
// =============================================================================

// Linear extrapolation: y = y0 + slope * (x - x0)
lineAt(int x0, float y0, float slope, int x) =>
    y0 + slope * (x - x0)

// Helper to return color based on pattern type
getKindColor(string kind) =>
    kind == "Ascending" ? colAsc : kind == "Descending" ? colDesc : colSym

// Helper to return table size
getTableSize(string sz) =>
    switch sz
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        => size.small

// Helper to return table position
getTablePos(string loc) =>
    switch loc
        "Top Right"    => position.top_right
        "Bottom Right" => position.bottom_right
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        => position.top_right

// Fits a trendline across the last `n` pivots and verifies all intermediate points lie within `tol`
fitLine(array<Pivot> pts, int n, float tol) =>
    int  sz = pts.size()
    bool ok = sz >= n
    int  x1 = na
    float y1 = na
    float s  = na
    if ok
        Pivot a = pts.get(sz - n)
        Pivot b = pts.get(sz - 1)
        if b.x == a.x
            ok := false
        else
            x1 := a.x
            y1 := a.y
            s  := (b.y - a.y) / (b.x - a.x)
            if n > 2
                for i = sz - n + 1 to sz - 2
                    Pivot p = pts.get(i)
                    float expY = y1 + s * (p.x - x1)
                    if math.abs(p.y - expY) > tol
                        ok := false
                        break
    [ok, x1, y1, s]

// Calculates apex (intersection point) of upper and lower trendlines
calcApex(int xu, float yu, float su, int xl, float yl, float sl) =>
    if su == sl
        [na, na]
    else
        float apexX = (yl - sl * xl - yu + su * xu) / (su - sl)
        float apexY = yu + su * (apexX - xu)
        [apexX, apexY]

// =============================================================================
// SWING DETECTION & STORAGE
// =============================================================================

var array<Pivot> highs = array.new<Pivot>()
var array<Pivot> lows  = array.new<Pivot>()

atr = ta.atr(atrLength)
ph  = ta.pivothigh(high, pivLeft, pivRight)
pl  = ta.pivotlow(low, pivLeft, pivRight)

if not na(ph)
    highs.push(Pivot.new(bar_index - pivRight, ph))
    if highs.size() > 20
        highs.shift()

if not na(pl)
    lows.push(Pivot.new(bar_index - pivRight, pl))
    if lows.size() > 20
        lows.shift()

// =============================================================================
// PATTERN DETECTION & TRACKING STATE
// =============================================================================

var Triangle tri = na
var array<Triangle> historyTriangles = array.new<Triangle>()

bool newTriangleDetected = false
bool buySignal           = false
bool sellSignal          = false
string signalPatternType = ""
float  signalTriHeight   = na
float  signalApexPrice   = na

// Run detection only when a new swing point is confirmed
if (not na(ph) or not na(pl)) and highs.size() >= touches and lows.size() >= touches and not na(atr)
    float tol = fitTolATR * atr
    [okU, xu, yu, su] = fitLine(highs, touches, tol)
    [okL, xl, yl, sl] = fitLine(lows, touches, tol)

    if okU and okL
        int   startX = math.min(xu, xl)
        int   lastX  = math.max(highs.last().x, lows.last().x)
        int   span   = lastX - startX

        float uStart = lineAt(xu, yu, su, startX)
        float lStart = lineAt(xl, yl, sl, startX)
        float uNow   = lineAt(xu, yu, su, bar_index)
        float lNow   = lineAt(xl, yl, sl, bar_index)

        // Geometric height at start
        float height = uStart - lStart

        // Flatness check: slope variation across pattern span relative to initial height
        bool upFlat = height > 0 and math.abs(su * span) <= (flatTolPct / 100.0) * height
        bool loFlat = height > 0 and math.abs(sl * span) <= (flatTolPct / 100.0) * height
        bool upFall = su < 0 and not upFlat
        bool loRise = sl > 0 and not loFlat

        // Symmetrical: both falling/rising towards each other with balanced slope ratio
        float minSlopeAbs = math.max(math.min(-su, sl), 0.000001)
        float slopeRatio  = math.max(-su, sl) / minSlopeAbs
        bool  balanced    = upFall and loRise and slopeRatio <= symRatioMax

        // Pattern Classification
        string kind = upFlat and loRise ? "Ascending" : upFall and loFlat ? "Descending" : balanced ? "Symmetrical" : na
        bool enabled = (kind == "Ascending" and showAsc) or (kind == "Descending" and showDesc) or (kind == "Symmetrical" and showSym)

        // Intersection (Apex) calculations
        [apexF, apexYF] = calcApex(xu, yu, su, xl, yl, sl)

        // Overlap: both lines must span overlapping time periods
        bool overlap = xu < lows.last().x and xl < highs.last().x

        // Valid convergence criteria
        bool valid = enabled and overlap and span >= minPatternLen and not na(apexF) and apexF > bar_index and (apexF - startX) <= maxPatternLen and uStart > lStart and uNow > lNow

        // Price containment check with ATR tolerance
        if valid
            for k = 0 to bar_index - startX
                int   x = bar_index - k
                float u = lineAt(xu, yu, su, x)
                float l = lineAt(xl, yl, sl, x)
                if high[k] > u + tol or low[k] < l - tol
                    valid := false
                    break

        // Prevent overwriting an already resolved triangle if overlapping
        if valid and not na(tri) and not tri.isActive and startX < tri.resolvedBar
            valid := false

        if valid
            color c = getKindColor(kind)
            int apexBar = int(math.round(apexF))

            // Check if this is an existing active pattern receiving another touch
            if not na(tri) and tri.isActive and startX <= tri.lastPivotX
                tri.kind         := kind
                tri.startX       := startX
                tri.startUpperY  := uStart
                tri.startLowerY  := lStart
                tri.anchorUpperX := xu
                tri.anchorUpperY := yu
                tri.slopeUpper   := su
                tri.anchorLowerX := xl
                tri.anchorLowerY := yl
                tri.slopeLower   := sl
                tri.apexX        := apexBar
                tri.apexY        := apexYF
                tri.lastPivotX   := lastX

                tri.upperLine.set_xy1(startX, uStart)
                tri.upperLine.set_xy2(bar_index, uNow)
                tri.upperLine.set_color(c)
                tri.lowerLine.set_xy1(startX, lStart)
                tri.lowerLine.set_xy2(bar_index, lNow)
                tri.lowerLine.set_color(c)
                tri.fillArea.set_color(showFill ? color.new(c, fillTransp) : color.new(color.white, 100))
                if not na(tri.patternLabel)
                    tri.patternLabel.set_xy(startX, uStart)
                    tri.patternLabel.set_text(kind + " Triangle")
                    tri.patternLabel.set_color(c)
            else
                // A new pattern replaces any previous unresolved pattern
                if not na(tri) and tri.isActive
                    tri.isActive := false
                    tri.resolvedBar := bar_index
                    tri.status := "Expired"
                    tri.upperLine.set_style(line.style_dashed)
                    tri.lowerLine.set_style(line.style_dashed)
                    if not na(tri.patternLabel)
                        color oldC = getKindColor(tri.kind)
                        tri.patternLabel.set_color(color.new(oldC, 60))
                        tri.patternLabel.set_text(tri.kind + " Triangle (Replaced)")

                // Instantiate new triangle drawings
                line upLine = line.new(startX, uStart, bar_index, uNow, xloc = xloc.bar_index, color = c, width = lineWidth, style = line.style_solid)
                line loLine = line.new(startX, lStart, bar_index, lNow, xloc = xloc.bar_index, color = c, width = lineWidth, style = line.style_solid)
                linefill fillObj = linefill.new(upLine, loLine, color = showFill ? color.new(c, fillTransp) : color.new(color.white, 100))
                label tagLabel = na
                if showLabels
                    tagLabel := label.new(startX, uStart, kind + " Triangle", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = c, textcolor = color.white, size = size.small)

                tri := Triangle.new(kind, startX, uStart, lStart, xu, yu, su, xl, yl, sl, apexBar, apexYF, lastX, upLine, loLine, fillObj, tagLabel, true, na, "Active")
                historyTriangles.push(tri)
                newTriangleDetected := true

                // Memory cleanup: maintain max history limit
                if historyTriangles.size() > maxTriangles
                    Triangle oldest = historyTriangles.shift()
                    line.delete(oldest.upperLine)
                    line.delete(oldest.lowerLine)
                    if not na(oldest.patternLabel)
                        label.delete(oldest.patternLabel)

// =============================================================================
// ACTIVE PATTERN TRACKING, BREAKOUT DETECTION & EXPIRY
// =============================================================================

if not na(tri) and tri.isActive
    float uNow = lineAt(tri.anchorUpperX, tri.anchorUpperY, tri.slopeUpper, bar_index)
    float lNow = lineAt(tri.anchorLowerX, tri.anchorLowerY, tri.slopeLower, bar_index)

    // Dynamically extend trendlines up to current bar
    tri.upperLine.set_xy2(bar_index, uNow)
    tri.lowerLine.set_xy2(bar_index, lNow)

    // Evaluate breakout prices based on user input
    float upSource = breakSource == "Close" ? close : high
    float dnSource = breakSource == "Close" ? close : low

    bool isBullBreak = upSource > uNow
    bool isBearBreak = dnSource < lNow

    // Handle high volatility bar piercing both boundaries
    if isBullBreak and isBearBreak
        isBullBreak := close > uNow
        isBearBreak := close < lNow
        if isBullBreak and isBearBreak
            isBullBreak := close >= open
            isBearBreak := close < open

    // Confirmation gate: prevents intra-bar repainting if selected
    bool canTrigger = not signalClose or barstate.isconfirmed

    if isBullBreak and canTrigger
        // BUY SIGNAL (Bullish Breakout)
        buySignal         := true
        signalPatternType := tri.kind
        signalTriHeight   := tri.startUpperY - tri.startLowerY
        signalApexPrice   := tri.apexY
        tri.isActive      := false
        tri.resolvedBar   := bar_index
        tri.status        := "Bull Breakout"
        tri.upperLine.set_xy2(bar_index, uNow)
        tri.lowerLine.set_xy2(bar_index, lNow)
        if not na(tri.patternLabel)
            tri.patternLabel.set_text(tri.kind + " Triangle (BUY Breakout)")
        alert(tri.kind + " Triangle: Bullish Breakout on " + syminfo.ticker + " at " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

    else if isBearBreak and canTrigger
        // SELL SIGNAL (Bearish Breakdown)
        sellSignal        := true
        signalPatternType := tri.kind
        signalTriHeight   := tri.startUpperY - tri.startLowerY
        signalApexPrice   := tri.apexY
        tri.isActive      := false
        tri.resolvedBar   := bar_index
        tri.status        := "Bear Breakdown"
        tri.upperLine.set_xy2(bar_index, uNow)
        tri.lowerLine.set_xy2(bar_index, lNow)
        if not na(tri.patternLabel)
            tri.patternLabel.set_text(tri.kind + " Triangle (SELL Breakdown)")
        alert(tri.kind + " Triangle: Bearish Breakdown on " + syminfo.ticker + " at " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

    else if bar_index >= tri.apexX or (bar_index - tri.startX) > maxPatternLen
        // PATTERN EXPIRATION
        tri.isActive    := false
        tri.resolvedBar := bar_index
        tri.status      := "Expired"
        tri.upperLine.set_xy2(tri.apexX, tri.apexY)
        tri.lowerLine.set_xy2(tri.apexX, tri.apexY)
        tri.upperLine.set_style(line.style_dashed)
        tri.lowerLine.set_style(line.style_dashed)
        color c = getKindColor(tri.kind)
        tri.fillArea.set_color(showFill ? color.new(c, 95) : color.new(color.white, 100))
        if not na(tri.patternLabel)
            tri.patternLabel.set_color(color.new(c, 60))
            tri.patternLabel.set_text(tri.kind + " Triangle (Expired)")

if newTriangleDetected
    alert(tri.kind + " Triangle detected on " + syminfo.ticker, alert.freq_once_per_bar_close)

// =============================================================================
// TRADE SIMULATOR ENGINE
// =============================================================================

// Simulator state variables
var int   simPosition   = 0     // 1: Long, -1: Short, 0: Flat
var float simEntryPrice = na
var float simSL         = na
var float simTP         = na
var int   simEntryBar   = na
var string simTradeType = ""    // "Ascending", "Descending", "Symmetrical"
var box   simActiveBoxTP = na
var box   simActiveBoxSL = na
var array<box> simBoxHistory = array.new<box>()

// Performance tracking metrics
var int   simTotalTrades  = 0
var int   simWins         = 0
var int   simLosses       = 0
var float simGrossProfitR = 0.0
var float simGrossLossR   = 0.0
var float simNetProfitR   = 0.0
var float simPeakProfitR  = 0.0
var float simMaxDrawdownR = 0.0
var int   simConsecWins   = 0
var int   simConsecLosses = 0
var int   simMaxConsecWins= 0
var int   simMaxConsecLoss= 0

// Pattern specific win rate tracking
var int simAscTrades = 0, var int simAscWins = 0
var int simDescTrades = 0, var int simDescWins = 0
var int simSymTrades = 0, var int simSymWins = 0

// Check active trade exits (evaluated on every bar)
if enableSim and simPosition != 0
    bool hitTP = false
    bool hitSL = false

    if simPosition == 1 // LONG
        if high >= simTP
            hitTP := true
        else if low <= simSL
            hitSL := true
    else if simPosition == -1 // SHORT
        if low <= simTP
            hitTP := true
        else if high >= simSL
            hitSL := true

    if hitTP
        simTotalTrades   += 1
        simWins          += 1
        simConsecWins    += 1
        simConsecLosses  := 0
        if simConsecWins > simMaxConsecWins
            simMaxConsecWins := simConsecWins
        
        float rewardR = rrRatio
        simGrossProfitR += rewardR
        simNetProfitR   += rewardR
        if simNetProfitR > simPeakProfitR
            simPeakProfitR := simNetProfitR

        // Breakdown by pattern
        if simTradeType == "Ascending"
            simAscTrades += 1
            simAscWins   += 1
        else if simTradeType == "Descending"
            simDescTrades += 1
            simDescWins   += 1
        else if simTradeType == "Symmetrical"
            simSymTrades += 1
            simSymWins   += 1

        if not na(simActiveBoxTP)
            simActiveBoxTP.set_right(bar_index)
        if not na(simActiveBoxSL)
            simActiveBoxSL.set_right(bar_index)

        simPosition := 0

    else if hitSL
        simTotalTrades   += 1
        simLosses        += 1
        simConsecLosses  += 1
        simConsecWins    := 0
        if simConsecLosses > simMaxConsecLoss
            simMaxConsecLoss := simConsecLosses

        float riskR = 1.0
        simGrossLossR += riskR
        simNetProfitR -= riskR
        float currentDD = simPeakProfitR - simNetProfitR
        if currentDD > simMaxDrawdownR
            simMaxDrawdownR := currentDD

        // Breakdown by pattern
        if simTradeType == "Ascending"
            simAscTrades += 1
        else if simTradeType == "Descending"
            simDescTrades += 1
        else if simTradeType == "Symmetrical"
            simSymTrades += 1

        if not na(simActiveBoxTP)
            simActiveBoxTP.set_right(bar_index)
        if not na(simActiveBoxSL)
            simActiveBoxSL.set_right(bar_index)

        simPosition := 0
    else
        // Keep active boxes extending to current bar
        if not na(simActiveBoxTP)
            simActiveBoxTP.set_right(bar_index)
        if not na(simActiveBoxSL)
            simActiveBoxSL.set_right(bar_index)

// Check new simulated entries when flat
if enableSim and simPosition == 0
    if buySignal and (tradeDir == "Both" or tradeDir == "Long Only")
        simPosition   := 1
        simEntryPrice := close
        simEntryBar   := bar_index
        simTradeType  := signalPatternType

        // Calculate Stop Loss
        float slDist = 0.0
        if slMethod == "ATR Multiple"
            slDist := slAtrMult * atr
        else if slMethod == "Opposite Line / Apex"
            slDist := math.max(close - signalApexPrice, atr * 0.5)
        else // Pattern Midpoint
            slDist := math.max(signalTriHeight * 0.5, atr * 0.5)
        simSL := close - slDist

        // Calculate Take Profit
        if tpMethod == "Risk:Reward (R:R)"
            simTP := close + slDist * rrRatio
        else if tpMethod == "Triangle Height"
            simTP := close + signalTriHeight
        else // ATR Multiple
            simTP := close + atr * rrRatio * slAtrMult

        // Draw visual TP/SL boxes
        if showTradeVisuals
            simActiveBoxTP := box.new(left = bar_index, top = simTP, right = bar_index + 1, bottom = close, border_color = color.green, bgcolor = color.new(color.green, 85))
            simActiveBoxSL := box.new(left = bar_index, top = close, right = bar_index + 1, bottom = simSL, border_color = color.red, bgcolor = color.new(color.red, 85))
            simBoxHistory.push(simActiveBoxTP)
            simBoxHistory.push(simActiveBoxSL)

            if simBoxHistory.size() > (maxVisTrades * 2)
                box bOld1 = simBoxHistory.shift()
                box bOld2 = simBoxHistory.shift()
                box.delete(bOld1)
                box.delete(bOld2)

    else if sellSignal and (tradeDir == "Both" or tradeDir == "Short Only")
        simPosition   := -1
        simEntryPrice := close
        simEntryBar   := bar_index
        simTradeType  := signalPatternType

        // Calculate Stop Loss
        float slDist = 0.0
        if slMethod == "ATR Multiple"
            slDist := slAtrMult * atr
        else if slMethod == "Opposite Line / Apex"
            slDist := math.max(signalApexPrice - close, atr * 0.5)
        else // Pattern Midpoint
            slDist := math.max(signalTriHeight * 0.5, atr * 0.5)
        simSL := close + slDist

        // Calculate Take Profit
        if tpMethod == "Risk:Reward (R:R)"
            simTP := close - slDist * rrRatio
        else if tpMethod == "Triangle Height"
            simTP := close - signalTriHeight
        else // ATR Multiple
            simTP := close - atr * rrRatio * slAtrMult

        // Draw visual TP/SL boxes
        if showTradeVisuals
            simActiveBoxTP := box.new(left = bar_index, top = close, right = bar_index + 1, bottom = simTP, border_color = color.green, bgcolor = color.new(color.green, 85))
            simActiveBoxSL := box.new(left = bar_index, top = simSL, right = bar_index + 1, bottom = close, border_color = color.red, bgcolor = color.new(color.red, 85))
            simBoxHistory.push(simActiveBoxTP)
            simBoxHistory.push(simActiveBoxSL)

            if simBoxHistory.size() > (maxVisTrades * 2)
                box bOld1 = simBoxHistory.shift()
                box bOld2 = simBoxHistory.shift()
                box.delete(bOld1)
                box.delete(bOld2)

// =============================================================================
// PERFORMANCE DASHBOARD
// =============================================================================

var table perfTable = table.new(position = getTablePos(dashLoc), columns = 2, rows = 10, bgcolor = color.rgb(18, 24, 38, 20), border_color = color.rgb(55, 65, 81), border_width = 1)

if showDash and barstate.islast
    string tSize = dashSize
    color headBg = color.rgb(30, 41, 59)
    color cellBg = color.rgb(15, 23, 42, 30)

    // Title Row
    table.cell(perfTable, 0, 0, "📐 Smart Triangles", bgcolor = headBg, text_color = color.white, text_size = getTableSize(tSize), text_font_family = font.family_monospace)
    table.cell(perfTable, 1, 0, "Simulator", bgcolor = headBg, text_color = color.rgb(148, 163, 184), text_size = getTableSize(tSize), text_font_family = font.family_monospace)

    // Win Rate
    float wr = simTotalTrades > 0 ? (simWins / float(simTotalTrades)) * 100.0 : 0.0
    color wrCol = wr >= 50.0 ? color.rgb(74, 222, 128) : color.rgb(248, 113, 113)
    table.cell(perfTable, 0, 1, "Win Rate", bgcolor = cellBg, text_color = color.rgb(203, 213, 225), text_size = getTableSize(tSize))
    table.cell(perfTable, 1, 1, str.tostring(wr, "#.#") + "% (" + str.tostring(simWins) + "W/" + str.tostring(simLosses) + "L)", bgcolor = cellBg, text_color = wrCol, text_size = getTableSize(tSize))

    // Total Trades
    table.cell(perfTable, 0, 2, "Total Trades", bgcolor = cellBg, text_color = color.rgb(203, 213, 225), text_size = getTableSize(tSize))
    table.cell(perfTable, 1, 2, str.tostring(simTotalTrades), bgcolor = cellBg, text_color = color.white, text_size = getTableSize(tSize))

    // Profit Factor
    float pf = simGrossLossR > 0 ? simGrossProfitR / simGrossLossR : (simGrossProfitR > 0 ? 99.9 : 0.0)
    color pfCol = pf >= 1.5 ? color.rgb(74, 222, 128) : (pf >= 1.0 ? color.white : color.rgb(248, 113, 113))
    table.cell(perfTable, 0, 3, "Profit Factor", bgcolor = cellBg, text_color = color.rgb(203, 213, 225), text_size = getTableSize(tSize))
    table.cell(perfTable, 1, 3, str.tostring(pf, "#.##"), bgcolor = cellBg, text_color = pfCol, text_size = getTableSize(tSize))

    // Net Profit (R Multiple)
    color pnlCol = simNetProfitR >= 0 ? color.rgb(74, 222, 128) : color.rgb(248, 113, 113)
    string pnlSign = simNetProfitR > 0 ? "+" : ""
    table.cell(perfTable, 0, 4, "Net Profit (R)", bgcolor = cellBg, text_color = color.rgb(203, 213, 225), text_size = getTableSize(tSize))
    table.cell(perfTable, 1, 4, pnlSign + str.tostring(simNetProfitR, "#.##") + " R", bgcolor = cellBg, text_color = pnlCol, text_size = getTableSize(tSize))

    // Max Drawdown (R)
    table.cell(perfTable, 0, 5, "Max Drawdown", bgcolor = cellBg, text_color = color.rgb(203, 213, 225), text_size = getTableSize(tSize))
    table.cell(perfTable, 1, 5, "-" + str.tostring(simMaxDrawdownR, "#.##") + " R", bgcolor = cellBg, text_color = color.rgb(248, 113, 113), text_size = getTableSize(tSize))

    // Ascending Triangle Stats
    float ascWR = simAscTrades > 0 ? (simAscWins / float(simAscTrades)) * 100.0 : 0.0
    table.cell(perfTable, 0, 6, "Ascending Tri", bgcolor = cellBg, text_color = colAsc, text_size = getTableSize(tSize))
    table.cell(perfTable, 1, 6, str.tostring(ascWR, "#.#") + "% (" + str.tostring(simAscWins) + "/" + str.tostring(simAscTrades) + ")", bgcolor = cellBg, text_color = color.white, text_size = getTableSize(tSize))

    // Descending Triangle Stats
    float descWR = simDescTrades > 0 ? (simDescWins / float(simDescTrades)) * 100.0 : 0.0
    table.cell(perfTable, 0, 7, "Descending Tri", bgcolor = cellBg, text_color = colDesc, text_size = getTableSize(tSize))
    table.cell(perfTable, 1, 7, str.tostring(descWR, "#.#") + "% (" + str.tostring(simDescWins) + "/" + str.tostring(simDescTrades) + ")", bgcolor = cellBg, text_color = color.white, text_size = getTableSize(tSize))

    // Symmetrical Triangle Stats
    float symWR = simSymTrades > 0 ? (simSymWins / float(simSymTrades)) * 100.0 : 0.0
    table.cell(perfTable, 0, 8, "Symmetrical Tri", bgcolor = cellBg, text_color = colSym, text_size = getTableSize(tSize))
    table.cell(perfTable, 1, 8, str.tostring(symWR, "#.#") + "% (" + str.tostring(simSymWins) + "/" + str.tostring(simSymTrades) + ")", bgcolor = cellBg, text_color = color.white, text_size = getTableSize(tSize))

    // Active Position Status
    string statusText = "FLAT"
    color statusColor = color.rgb(148, 163, 184)
    if simPosition == 1
        statusText  := "LONG (" + str.tostring(simEntryPrice, format.mintick) + ")"
        statusColor := color.rgb(74, 222, 128)
    else if simPosition == -1
        statusText  := "SHORT (" + str.tostring(simEntryPrice, format.mintick) + ")"
        statusColor := color.rgb(248, 113, 113)

    table.cell(perfTable, 0, 9, "Active Status", bgcolor = cellBg, text_color = color.rgb(203, 213, 225), text_size = getTableSize(tSize))
    table.cell(perfTable, 1, 9, statusText, bgcolor = cellBg, text_color = statusColor, text_size = getTableSize(tSize))

// =============================================================================
// VISUAL SIGNALS & PLOTS
// =============================================================================

// Visual Green Up Arrow on Bullish Breakout
plotshape(showSignals and buySignal, title = "BUY Signal (Up Arrow)", style = shape.arrowup, location = location.belowbar, color = colBuy, size = size.normal, text = "BUY", textcolor = colBuy)

// Visual Red Down Arrow on Bearish Breakdown
plotshape(showSignals and sellSignal, title = "SELL Signal (Down Arrow)", style = shape.arrowdown, location = location.abovebar, color = colSell, size = size.normal, text = "SELL", textcolor = colSell)

// =============================================================================
// ALERT CONDITIONS
// =============================================================================

alertcondition(newTriangleDetected, title = "New Triangle Detected", message = "New Triangle Pattern Detected on {{ticker}}")
alertcondition(buySignal, title = "BUY Signal", message = "Triangle Bullish Breakout BUY Signal on {{ticker}} at {{close}}")
alertcondition(sellSignal, title = "SELL Signal", message = "Triangle Bearish Breakdown SELL Signal on {{ticker}} at {{close}}")
````
