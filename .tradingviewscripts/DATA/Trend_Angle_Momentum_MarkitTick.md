<!-- tradingview-pine-id: PUB;fc39c6b7dc95469dbb18967e47dcf1ea -->
<!-- tradingviewscripts-format: 1 -->
# Trend Angle Momentum [MarkitTick]

Source: https://www.tradingview.com/script/RB4p7wfL-Trend-Angle-Momentum-MarkitTick/

## Description

💡 This tool measures market structure not just as a sequence of highs and lows, but as a rate of directional change. It detects confirmed swing pivots and then calculates the geometric angle of the trendline connecting each pivot to the one before it, translating pure price action into a single, intuitive metric: degrees of trend steepness. Instead of asking traders to infer momentum from candle shape or oscillator divergence, it hands them a number — the actual angle of ascent or descent between structural turning points — along with an optional smoothed reading of how that angle is evolving over time.

✨ Originality and Utility

Most swing-detection tools stop at marking the high or low. This script goes a step further by quantifying the relationship between consecutive swings using trigonometry. Each swing-to-swing move is converted into a percentage price change, which is then run through an arctangent function to produce a true geometric angle in degrees, independent of the instrument's absolute price scale. A move on a $2 stock and a move on a $2,000 stock that share the same percentage steepness will report the same angle, making the readings comparable across symbols and timeframes in a way that raw price-based slope calculations cannot achieve.

The utility here is twofold. First, the angle itself acts as a quantified momentum proxy: a shallow angle after a strong prior swing signals decelerating momentum well before a lagging oscillator would confirm it, while a steepening angle on successive swings signals acceleration. Second, an optional Angle Momentum layer tracks a rolling average of the last several swing angles, smoothing out single-swing noise and revealing whether the broader structural rhythm of the market is strengthening or weakening. This combination — geometric normalization plus rolling angle smoothing — gives traders a structural momentum read that is not available from stock pivot tools or generic slope indicators alone.

🔬 Methodology and Concepts
[image]https://www.tradingview.com/x/KEiErZOY/[/image]
• Confirmed Pivot Detection
The script identifies swing highs and swing lows using a symmetric fractal method: a bar is only confirmed as a pivot high if it is higher than a defined number of bars to its left and right, and likewise for a pivot low. The "Left Bars" and "Right Bars" inputs control how many bars on each side must confirm the extreme. Because the right-side bars must fully close before a pivot can be validated, every pivot marked on the chart is confirmed historical structure, not a live, moving estimate — the marker is deliberately plotted with a backward offset equal to the right-bar count so that its horizontal position matches where the actual swing extreme occurred, not where it was confirmed.

• Percent-to-Angle Conversion
Once two consecutive confirmed pivots of the same type (high-to-high or low-to-low) are available, the script calculates the percentage price change between them. This percentage is then optionally normalized by the number of bars separating the two pivots (via the "Normalize Angle by Bars" input), which converts the reading from "how much did price move" into "how much did price move per bar," a more useful measure of steepness when swings vary widely in duration. The resulting rate is passed through an arctangent function and converted from radians to degrees, producing a bounded, intuitive angle: values approaching plus or minus ninety degrees represent extremely steep percentage moves, while values near zero represent flat, sideways structure.

• Angle Momentum (Optional Smoothing Layer)
When enabled, the script maintains a running array of the most recent swing angles (separately for highs and lows) and reports their simple average over a user-defined lookback length. This produces a second-order reading: rather than looking at a single swing's angle in isolation, it shows whether the sequence of recent swing angles is, on average, steep or shallow, positive or negative — a way of gauging whether structural momentum is building or fading across several swings rather than just the most recent one.

• Live Dashboard
A compact on-chart table continuously summarizes the last confirmed high pivot price, the last confirmed low pivot price, the most recent high-swing angle, the most recent low-swing angle, and whether Angle Momentum smoothing is currently active, giving traders a persistent numerical snapshot without needing to hover over chart objects.

🎨 Visual Guide
[image]https://www.tradingview.com/x/Wn4SMqXV/[/image]

[*]Diagonal trend lines connecting consecutive swing highs (default red/green by angle sign) and consecutive swing lows are drawn directly between the two pivot points, visually representing the geometric slope being measured.
[*]A small numeric label at the midpoint of each swing line displays the calculated angle in degrees, colored green for a positive (upward) angle and red for a negative (downward) angle by default.
[*]When Angle Momentum is enabled, an additional label appears at the most recent pivot showing the smoothed "Mom" value in a distinct color (orange for highs, blue for lows by default), separated visually from the raw single-swing angle label.
[*]Cross-style markers plot at each confirmed pivot high and pivot low directly on price, offset backward to align with the actual bar where the extreme occurred.
[*]The dashboard table (position configurable) shows the symbol, timeframe, last high and low pivot prices, the latest angle readings for each, and the current on/off state of Angle Momentum.

📖 How to Use
[image]https://www.tradingview.com/x/RkhudBpp/[/image]

[*]Treat the angle label on each swing line as a normalized momentum reading for that specific leg of price action: steep angles indicate strong directional conviction, shallow angles indicate a weakening or consolidating move.
[*]Compare the angle of the most recent swing to the angle of the swing before it. A sequence of progressively shallower high-to-high angles during an uptrend can indicate fading bullish momentum even while price is still making new highs, a structural early warning that pure price action alone may not show.
[*]When Angle Momentum is enabled, use the smoothed "Mom" reading as a broader confirmation layer: a rising average angle across several swings supports the idea that momentum is genuinely building, rather than reacting to a single outlier swing.
[*]Divergences between price structure and angle behavior — for example, higher swing highs paired with a declining angle momentum reading — can be used as a discretionary caution signal ahead of a potential trend deceleration.
[*]The two alert conditions ("High Pivot Formed" and "Low Pivot Formed") can be used to build automated or semi-automated workflows that trigger only once a swing point is fully confirmed, rather than on every bar.

⚠️ Confirmation Lag Notice
All pivots and their associated angle calculations are confirmed structure. Because a pivot cannot be validated until the required number of bars on its right side have closed, every marker, line, and label is necessarily plotted a number of bars after the actual high or low occurred, equal to the "Right Bars" setting. The plotted markers are intentionally offset backward to align visually with the true location of the swing extreme — this does not mean the indicator is predicting or anticipating pivots in real time. Traders should treat swing confirmations as lagging structural events by design, not as leading signals.

⚙️ Inputs and Settings

[*]Left Bars / Right Bars: Define the symmetric lookback and lookahead window used to validate a swing high or low. Larger values filter out minor fluctuations and confirm only more significant structural turning points, at the cost of a longer confirmation delay. Smaller values confirm pivots faster but are more sensitive to short-term noise.
[*]Show High Swing Lines / Show Low Swing Lines: Independently toggle the diagonal trend lines connecting consecutive high or low pivots.
[*]Show Swing Point Dots: Toggles the cross markers plotted directly at each confirmed pivot price.
[*]Normalize Angle by Bars: When enabled, divides the percentage move between two pivots by the number of bars separating them before calculating the angle, producing a "steepness per bar" measure rather than a raw total-move angle. Useful for comparing swings of different durations on a more equal footing.
[*]Use Angle Momentum: Enables the rolling average smoothing layer over the last several swing angles, plotted as an additional label at each new pivot.
[*]Angle Momentum Length: Sets how many recent swing angles are averaged together for the smoothed momentum reading. Shorter lengths react faster to recent swings; longer lengths produce a smoother, slower-changing average.
[*]Dashboard Position / Show Dashboard: Controls visibility and screen placement of the summary table.
[*]High Pivot Action / Low Pivot Action: Custom text tags embedded into the JSON alert payload for each pivot type, useful for routing alerts to external automation systems that key off a specific action string.
[*]Color inputs: Independently control the color of swing lines, angle text, pivot cross markers, momentum labels, and dashboard theming to match personal charting preferences.

🔍 Deconstruction of the Underlying Scientific and Academic Framework

The core of this indicator rests on classical trigonometric slope analysis rather than any single named technical analysis school. Converting a price move into an angle is mathematically equivalent to computing the arctangent of a rate of change, the same operation used broadly in engineering and physics to express a gradient as an angular measure rather than a raw ratio. Expressing the swing-to-swing move as a percentage change before applying the arctangent function normalizes the calculation across instruments of different absolute price levels, addressing a well-known limitation of naive "price-per-bar" slope measures, which are not comparable between a low-priced and high-priced instrument, or between two different timeframes without adjustment. The optional bar-normalization step draws on the same logic used in rate-of-change and momentum oscillators broadly, where a raw price delta is scaled by the time or bar interval over which it occurred to produce a comparable velocity-style reading rather than a simple magnitude.

The pivot detection mechanism itself is a fractal/symmetric extremum test, a widely used method in swing-structure analysis (related in spirit to Bill Williams' fractal indicator and to classical Dow Theory's emphasis on confirmed swing highs and lows as the building blocks of trend structure) that requires a candidate bar to dominate a defined number of bars on both sides before being accepted as a genuine local extremum. This symmetric confirmation requirement is a standard technique for filtering transient noise out of swing-point identification, at the deliberate cost of confirmation lag, a well-documented trade-off in any lookback-based extremum detection method. The Angle Momentum layer applies a simple moving average — one of the most foundational smoothing techniques in time-series analysis — to the sequence of discrete angle readings themselves rather than to price, effectively treating "swing angle" as its own derived data series and smoothing it the same way a moving average would smooth a price or oscillator series, in order to separate signal (the underlying trend in momentum) from noise (single-swing outliers).

⚠️ Disclaimer
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

---

## Source Code

````pine
//@version=6
// © MarkitTick
// https://creativecommons.org/licenses/by-nc-sa/4.0/
indicator("Trend Angle Momentum [MarkitTick]", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ── INPUTS ──────────────────────────────────────────────────────
var string G_CORE = "⚙️ Core"
var string G_COL  = "🌈 Colors"
i_leftBars    = input.int(5, "Left Bars", minval = 1, group = G_CORE)
i_rightBars   = input.int(5, "Right Bars", minval = 1, group = G_CORE)
i_showHigh    = input.bool(true, "Show High Swing Lines", group = G_CORE)
i_showLow     = input.bool(true, "Show Low Swing Lines", group = G_CORE)
i_showCross   = input.bool(true, "Show Swing Point Dots", group = G_CORE)
i_normByTime  = input.bool(false, "Normalize Angle by Bars", group = G_CORE)
i_useAngMom   = input.bool(false, "Use Angle Momentum", group = G_CORE)
i_angMomLen   = input.int(5, "Angle Momentum Length", minval = 2, group = G_CORE)
var string _mt741a = "📊 Dashboard"
i_dashPos = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = _mt741a)
i_showDash = input.bool(true, "Show Dashboard", group = _mt741a)
var string G_WH = "🔔 Alerts"
i_actionHighPivot = input.string("highpivot", "High Pivot Action", group = G_WH)
i_actionLowPivot  = input.string("lowpivot", "Low Pivot Action", group = G_WH)
i_colHighLine = input.color(color.new(#ff0014, 0), "High Swing Line", group = G_COL)
i_colLowLine  = input.color(color.new(#00ff0a, 0), "Low Swing Line", group = G_COL)
i_colHighTxt  = input.color(color.new(#ff0014, 0), "High Angle Text", group = G_COL)
i_colLowTxt   = input.color(color.new(#00ff0a, 0), "Low Angle Text", group = G_COL)
i_colStepHigh = input.color(color.new(#ff0014, 0), "Pivot High Cross", group = G_COL)
i_colStepLow  = input.color(color.new(#00ff0a, 0), "Pivot Low Cross", group = G_COL)
i_colAngPos   = input.color(color.new(#00ff0a, 0), "Positive Angle Color", group = G_COL)
i_colAngNeg   = input.color(color.new(#ff0014, 0), "Negative Angle Color", group = G_COL)
i_colMomHigh  = input.color(color.new(#ffaa00, 0), "High Angle Momentum Text", group = G_COL)
i_colMomLow   = input.color(color.new(#00aaff, 0), "Low Angle Momentum Text", group = G_COL)
i_colDashHdr  = input.color(color.new(#3a2a6d, 55), "Dash Header", group = G_COL)
i_colDashBg   = input.color(color.new(#0a0f1a, 10), "Dash BG", group = G_COL)
i_colDashTxt  = input.color(color.new(#ffffff, 0), "Dash Text", group = G_COL)

// ── CORE LOGIC ──────────────────────────────────────────────────
f_pivotHigh(int left, int right) =>
    float pivotVal = na
    if bar_index >= left + right
        float candidate = high[right]
        bool isPivot = true
        for i = 1 to left
            if high[right + i] >= candidate
                isPivot := false
        for i = 1 to right
            if high[right - i] >= candidate
                isPivot := false
        if isPivot
            pivotVal := candidate
    pivotVal

f_pivotLow(int left, int right) =>
    float pivotVal = na
    if bar_index >= left + right
        float candidate = low[right]
        bool isPivot = true
        for i = 1 to left
            if low[right + i] <= candidate
                isPivot := false
        for i = 1 to right
            if low[right - i] <= candidate
                isPivot := false
        if isPivot
            pivotVal := candidate
    pivotVal

calculate_p2p_angle(p1, p2, bars, normByTime) =>
    pct_change = p1 != 0 ? (p2 - p1) / p1 * 100 : 0.0
    rate = normByTime and bars > 0 ? pct_change / bars : pct_change
    angle_rad = math.atan(rate)
    angle_rad * (180 / math.pi)

f_angleMomentum(array<float> arr, float ang, int len) =>
    array.push(arr, ang)
    if array.size(arr) > len
        array.shift(arr)
    array.avg(arr)

var array<float> highAngles = array.new_float(0)
var array<float> lowAngles  = array.new_float(0)

float labelOffset = ta.atr(14) * 0.5

float ph_val = f_pivotHigh(i_leftBars, i_rightBars)
float pl_val = f_pivotLow(i_leftBars, i_rightBars)

var int   prevHighBar = na
var float prevHighPrc = na
var int   prevLowBar  = na
var float prevLowPrc  = na
var bool  highPivotSignal = false
var bool  lowPivotSignal  = false

highPivotSignal := false
lowPivotSignal  := false

if not na(ph_val) and barstate.isconfirmed
    int   thisHighBar = bar_index - i_rightBars
    float thisHighPrc = ph_val
    if not na(prevHighBar)
        highPivotSignal := true
        int   barsBetween = thisHighBar - prevHighBar
        float ang = calculate_p2p_angle(prevHighPrc, thisHighPrc, barsBetween, i_normByTime)
        color angCol = ang >= 0 ? i_colAngPos : i_colAngNeg
        float angMomHigh = i_useAngMom ? f_angleMomentum(highAngles, ang, i_angMomLen) : na
        if i_showHigh
            line.new(prevHighBar, prevHighPrc, thisHighBar, thisHighPrc, color = angCol, style = line.style_solid, width = 2)
            int   midBar = math.round((prevHighBar + thisHighBar) / 2)
            float midPrc = math.max(prevHighPrc, thisHighPrc)
            label.new(midBar, midPrc, text = str.tostring(ang, "#.##") + "°", style = label.style_label_up, color = color.new(color.black, 100), textcolor = angCol, size = size.small)
            if i_useAngMom and not na(angMomHigh)
                label.new(thisHighBar, thisHighPrc + labelOffset, text = "Mom " + str.tostring(angMomHigh, "#.##") + "°", style = label.style_label_down, color = color.new(color.black, 100), textcolor = i_colMomHigh, size = size.small)
    prevHighBar := thisHighBar
    prevHighPrc := thisHighPrc

if not na(pl_val) and barstate.isconfirmed
    int   thisLowBar = bar_index - i_rightBars
    float thisLowPrc = pl_val
    if not na(prevLowBar)
        lowPivotSignal := true
        int   barsBetween = thisLowBar - prevLowBar
        float ang = calculate_p2p_angle(prevLowPrc, thisLowPrc, barsBetween, i_normByTime)
        color angCol = ang >= 0 ? i_colAngPos : i_colAngNeg
        float angMomLow = i_useAngMom ? f_angleMomentum(lowAngles, ang, i_angMomLen) : na
        if i_showLow
            line.new(prevLowBar, prevLowPrc, thisLowBar, thisLowPrc, color = angCol, style = line.style_solid, width = 2)
            int   midBar = math.round((prevLowBar + thisLowBar) / 2)
            float midPrc = math.min(prevLowPrc, thisLowPrc)
            label.new(midBar, midPrc, text = str.tostring(ang, "#.##") + "°", style = label.style_label_down, color = color.new(color.black, 100), textcolor = angCol, size = size.small)
            if i_useAngMom and not na(angMomLow)
                label.new(thisLowBar, thisLowPrc - labelOffset, text = "Mom " + str.tostring(angMomLow, "#.##") + "°", style = label.style_label_up, color = color.new(color.black, 100), textcolor = i_colMomLow, size = size.small)
    prevLowBar := thisLowBar
    prevLowPrc := thisLowPrc

// ── ALERTS ───────────────────────────────────────────
string _highInner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}","price":"{3}"',
 i_actionHighPivot, syminfo.tickerid, timeframe.period,
 str.tostring(ph_val, format.mintick))
string highPivotPayload = "{" + _highInner + "}"
string _lowInner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}","price":"{3}"',
 i_actionLowPivot, syminfo.tickerid, timeframe.period,
 str.tostring(pl_val, format.mintick))
string lowPivotPayload = "{" + _lowInner + "}"
if highPivotSignal
    alert(highPivotPayload, alert.freq_once_per_bar_close)
if lowPivotSignal
    alert(lowPivotPayload, alert.freq_once_per_bar_close)
alertcondition(highPivotSignal, "High Pivot", "MarkitTick — High Pivot Formed")
alertcondition(lowPivotSignal, "Low Pivot", "MarkitTick — Low Pivot Formed")

float ph_filled = fixnan(ph_val)
float pl_filled = fixnan(pl_val)

var float phs = 0.0
var float pls = 0.0

if barstate.isconfirmed
    phs := ph_filled
    pls := pl_filled

// ── VISUALS ───────────────────────────────────────────
plot(i_showCross ? phs : na, "Pivot High", style = plot.style_cross, color = i_colStepHigh, linewidth = 1, offset = -i_rightBars, display = display.all - display.price_scale - display.status_line)
plot(i_showCross ? pls : na, "Pivot Low", style = plot.style_cross, color = i_colStepLow, linewidth = 1, offset = -i_rightBars, display = display.all - display.price_scale - display.status_line)

// ── DASHBOARD ─────────────────────────────────────
f_dashPos(string p) =>
    p == "Top Left" ? position.top_left : p == "Bottom Right" ? position.bottom_right : p == "Bottom Left" ? position.bottom_left : position.top_right
var table dash = table.new(f_dashPos(i_dashPos), 2, 6, border_width = 1, border_color = color.new(#2a3040, 40), frame_width = 1, frame_color = color.new(#3a2a6d, 40))
lastAngHigh = array.size(highAngles) > 0 ? array.get(highAngles, array.size(highAngles) - 1) : na
lastAngLow  = array.size(lowAngles) > 0 ? array.get(lowAngles, array.size(lowAngles) - 1) : na
if i_showDash
    table.cell(dash, 0, 0, "Trend Angle Momentum", text_color = i_colDashTxt, bgcolor = i_colDashHdr, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 0, syminfo.ticker + "  ·  " + timeframe.period, text_color = i_colDashTxt, bgcolor = i_colDashHdr, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 1, "  Last High Pivot", text_color = color.new(i_colDashTxt, 25), bgcolor = i_colDashBg, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 1, (na(phs) ? "—" : str.tostring(phs, format.mintick)) + "  ", text_color = i_colDashTxt, bgcolor = i_colDashBg, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 2, "  Last Low Pivot", text_color = color.new(i_colDashTxt, 25), bgcolor = color.new(i_colDashBg, 40), text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 2, (na(pls) ? "—" : str.tostring(pls, format.mintick)) + "  ", text_color = i_colDashTxt, bgcolor = color.new(i_colDashBg, 40), text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 3, "  High Angle", text_color = color.new(i_colDashTxt, 25), bgcolor = i_colDashBg, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 3, (na(lastAngHigh) ? "—" : str.tostring(lastAngHigh, "#.##") + "°") + "  ", text_color = na(lastAngHigh) ? i_colDashTxt : (lastAngHigh >= 0 ? i_colAngPos : i_colAngNeg), bgcolor = i_colDashBg, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 4, "  Low Angle", text_color = color.new(i_colDashTxt, 25), bgcolor = color.new(i_colDashBg, 40), text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 4, (na(lastAngLow) ? "—" : str.tostring(lastAngLow, "#.##") + "°") + "  ", text_color = na(lastAngLow) ? i_colDashTxt : (lastAngLow >= 0 ? i_colAngPos : i_colAngNeg), bgcolor = color.new(i_colDashBg, 40), text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 5, "  Ang Momentum", text_color = color.new(i_colDashTxt, 25), bgcolor = i_colDashBg, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 5, (i_useAngMom ? "ON  " : "OFF  "), text_color = i_useAngMom ? i_colAngPos : i_colDashTxt, bgcolor = i_colDashBg, text_size = size.small, text_halign = text.align_right)
````
