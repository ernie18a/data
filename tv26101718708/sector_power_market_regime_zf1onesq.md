# Sector Power & Market Regime

- url: https://www.tradingview.com/script/ZF1Onesq-Sector-Power-Market-Regime/
- type: indicator
- pine_id: PUB;85ace5b0de874824955a7e4a14c4b04c
- version: 3.0

## Description

The Sector Power & Market Regime Indicator is a  multi-asset dashboard designed to quantify market dynamics through the lens of volatility-adjusted momentum. Unlike standard price-action indicators, this tool uses statistical normalization to compare the 11 major S&P 500 sectors, a benchmark (SPY), and custom equities on a leveled playing field.
1. The Rationale: Quantifying Market Behavior
The core philosophy of this indicator is that markets do not just move "up" or "down"—they move through different behavioral archetypes.
Statistical Normalization: By utilizing a Z-Score Window (defaulted to 252 days, or one trading year), the script calculates how an asset’s current performance deviates from its historical mean
. This allows a high-volatility sector like Technology (XLK) to be compared directly to a lower-volatility sector like Utilities (XLU)
.
Volatility Adjusted Momentum: By dividing price momentum (ROC) by the asset's current volatility (ATR), the script ensures that a high-volatility stock doesn't automatically look "stronger" than a stable one. It measures how much an asset is moving relative to its typical daily range.
Z-Scored X-Axis: This ROC/ATR value is then Z-scored over a 252-bar window (one trading year)
. This identifies how many standard deviations the current volatility-adjusted momentum is from its one-year mean.

Volatility Disorder (Z-Scored TR Dispersion):
The script evaluates the standard deviation of True Range relative to average True Range, then z-scores that value over the historical window. This quantifies how unusually dispersed or unstable volatility is versus the asset’s normal behavior, allowing the indicator to distinguish between smooth/trending price action and noisy/chaotic conditions.
. It essentially asks: Is this move backed by sustainable strength, or is it becoming dangerously erratic?
2. Understanding the Four Market States
The indicator categorizes every asset into one of four color-coded regimes
:
Efficient (Green): Characterized by strong, steady momentum with manageable volatility. This represents a healthy, sustainable trend where trend-following strategies typically thrive.
Explosive (Red): This state occurs during high-velocity breakouts or parabolic moves. While highly profitable, these are often "hot" zones that require active trade management.
Chaotic (Orange): Signals high volatility or trend exhaustion. Price action is often unpredictable here, suggesting a "hands-off" approach or a transition to a different regime.
Stable (Blue): Indicates consolidation or low-volatility environments. These are "quiet" periods where the asset is building energy for its next major move.
3. Key Metrics: Power & Age
Power (X-Value): This is the numerical strength of the asset
. A higher number indicates stronger relative momentum. Traders use this to rank sectors from strongest to weakest at a single glance.
Age (d): This tracks how many bars (days) the asset has remained in its current state
.
Fresh Trends: An asset in the Efficient state with an age of "2d" suggests a brand-new trend.
Overextended Trends: An asset in the Explosive state with an age of "20d" suggests the move may be nearing a climax.

--------------------------------------------------------------------------------
How to Use This in Your Trading Strategy
A. Alpha Generation (Relative Strength) Compare your Custom Stocks to the SPY benchmark
. If SPY is in a "Stable" (Blue) state but your stock is "Efficient" (Green) with higher "Power," your stock is showing significant relative strength and is a prime candidate for a long position.
B. Sector movement Tracking Monitor the 11 sectors to see where "Big Money" is moving
. If you see the "Defensive" sectors (XLU, XLP, XLV) moving into Efficient states while "Growth" sectors (XLK, XLY) move into Chaotic states, it is a strong signal of a defensive market shift.
C. Risk Management & Exit Timing The "Age" metric is your primary tool for timing exits
. If a sector you are holding moves from Efficient to Chaotic or stays in Explosive for an extended period, the "Age" will alert you that the trend is maturing, signaling it may be time to trail your stops tighter or harvest profits.
D. Customization Traders can input their own specific watchlist (e.g., MU, STX, BIIB) to see exactly how their personal portfolio is performing relative to the broader market sectors

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ 
//@version=6
indicator("Sector Power & Market Regime", overlay = false)

// --- Inputs ---
i01 = input.bool(true, "Communication Services (XLC)", group="Sectors")
i02 = input.bool(true, "Consumer Discretionary (XLY)", group="Sectors")
i03 = input.bool(true, "Consumer Staples (XLP)", group="Sectors")
i04 = input.bool(true, "Energy (XLE)", group="Sectors")
i05 = input.bool(true, "Financials (XLF)", group="Sectors")
i06 = input.bool(true, "Health Care (XLV)", group="Sectors")
i07 = input.bool(true, "Industrials (XLI)", group="Sectors")
i08 = input.bool(true, "Materials (XLB)", group="Sectors")
i09 = input.bool(true, "Real Estate (XLRE)", group="Sectors")
i10 = input.bool(true, "Technology (XLK)", group="Sectors")
i11 = input.bool(true, "Utilities (XLU)", group="Sectors")

sym1 = input.symbol("MU",  "Stock 1", group="Custom")
sym2 = input.symbol("STX", "Stock 2", group="Custom")
sym3 = input.symbol("BIIB","Stock 3", group="Custom")

iSPX = input.bool(true, "SPY", group="Benchmark")

momLen = input.int(21, "Momentum / ATR Length", minval = 2, group="Lengths")
zL     = input.int(252, "Z-Score Window", minval = 20, group="Lengths")
eL     = input.int(5, "EMA Smoothing", minval = 1, group="Lengths")
tL     = input.int(10, "Trail Length", minval = 2, group="Lengths")

// --- Calculations ---
calc() =>
    tr = ta.tr(true)

    m1 = ta.roc(close, momLen) / ta.sma(tr, momLen)
    std1 = ta.stdev(m1, zL)
    x = ta.ema((m1 - ta.sma(m1, zL)) / (std1 != 0 ? std1 : 1), eL)

    m2 = ta.stdev(tr, momLen) / ta.sma(tr, momLen)
    std2 = ta.stdev(m2, zL)
    y = ta.ema((m2 - ta.sma(m2, zL)) / (std2 != 0 ? std2 : 1), eL)

    int st = x > 0 ? (y < 0 ? 1 : 2) : (y > 0 ? 3 : 4)
    int ag = nz(ta.barssince(ta.change(st) != 0), 0)

    [x, y, st, ag]

// --- Fetch Data ---
[x01, y01, s01, a01] = request.security("XLC", timeframe.period, calc())
[x02, y02, s02, a02] = request.security("XLY", timeframe.period, calc())
[x03, y03, s03, a03] = request.security("XLP", timeframe.period, calc())
[x04, y04, s04, a04] = request.security("XLE", timeframe.period, calc())
[x05, y05, s05, a05] = request.security("XLF", timeframe.period, calc())
[x06, y06, s06, a06] = request.security("XLV", timeframe.period, calc())
[x07, y07, s07, a07] = request.security("XLI", timeframe.period, calc())
[x08, y08, s08, a08] = request.security("XLB", timeframe.period, calc())
[x09, y09, s09, a09] = request.security("XLRE", timeframe.period, calc())
[x10, y10, s10, a10] = request.security("XLK", timeframe.period, calc())
[x11, y11, s11, a11] = request.security("XLU", timeframe.period, calc())

[x12, y12, s12, a12] = request.security(sym1, timeframe.period, calc())
[x13, y13, s13, a13] = request.security(sym2, timeframe.period, calc())
[x14, y14, s14, a14] = request.security(sym3, timeframe.period, calc())

[x15, y15, s15, a15] = request.security("SPY", timeframe.period, calc())

// --- Objects ---
var table mainT = table.new(position.top_right, 4, 16, border_width = 1, border_color = color.gray)
var polyline[] ps = array.new<polyline>()
var label[] ls = array.new<label>()
var line[] ax = array.new<line>()

var line hA = na
var line vA = na

// --- Helpers ---
f_stateName(s) =>
    s == 1 ? "Efficient" : s == 2 ? "Explosive" : s == 3 ? "Chaotic" : "Weak"

f_stateColor(s) =>
    s == 1 ? #089981 : s == 2 ? #f23645 : s == 3 ? #ff9800 : #5b9cf6

f_xpos(float pwr) =>
    bar_index - 40 + math.round(pwr * 13.3)

// --- Draw One Asset ---
drawOne(int r, string n, series float x, series float y, int st, int ag, color c, bool ok) =>
    if barstate.islast
        if ok
            table.cell(mainT, 0, r, n, bgcolor = color.new(color.gray, 80), text_color = color.white)
            table.cell(mainT, 1, r, f_stateName(st), bgcolor = f_stateColor(st), text_color = color.white)
            table.cell(mainT, 2, r, str.tostring(ag) + "d", bgcolor = color.new(color.gray, 80), text_color = color.white)
            table.cell(mainT, 3, r, str.tostring(x, "#.##"), bgcolor = color.new(color.gray, 80), text_color = color.white)

            if not na(x) and not na(y)
                array<chart.point> pts = array.new<chart.point>()

                for i = tL - 1 to 0
                    int px = f_xpos(nz(x[i]))
                    float py = nz(y[i])
                    array.push(pts, chart.point.from_index(px, py))

                array.push(ps, polyline.new(pts, false, false, xloc.bar_index, c, na, line.style_solid, 2))

                int lx = f_xpos(nz(x))
                float ly = nz(y)

                array.push(ls, label.new(
                     lx, ly, "●",
                     xloc = xloc.bar_index,
                     yloc = yloc.price,
                     style = label.style_none,
                     textcolor = color.white,
                     size = size.normal))

                array.push(ls, label.new(
                     lx + 1, ly, n,
                     xloc = xloc.bar_index,
                     yloc = yloc.price,
                     style = label.style_none,
                     textcolor = c,
                     size = size.small))
        else
            table.cell(mainT, 0, r, "")
            table.cell(mainT, 1, r, "")
            table.cell(mainT, 2, r, "")
            table.cell(mainT, 3, r, "")

// --- Cleanup & Static Drawing ---
if barstate.islast
    if array.size(ps) > 0
        for i = 0 to array.size(ps) - 1
            polyline.delete(array.get(ps, i))

    if array.size(ls) > 0
        for i = 0 to array.size(ls) - 1
            label.delete(array.get(ls, i))

    if array.size(ax) > 0
        for i = 0 to array.size(ax) - 1
            line.delete(array.get(ax, i))

    array.clear(ps)
    array.clear(ls)
    array.clear(ax)

    line.delete(hA)
    line.delete(vA)

    hA := line.new(bar_index - 80, 0, bar_index, 0, color = color.gray, style = line.style_dashed)
    vA := line.new(bar_index - 40, -3, bar_index - 40, 3, color = color.gray, style = line.style_dashed)

    // Numeric X-axis ticks for Power
    for xv = -3 to 3
        int xp = f_xpos(xv)
        array.push(ax, line.new(xp, -0.08, xp, 0.08, color = color.gray))
        array.push(ls, label.new(
             xp, -3.25, str.tostring(xv),
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_none,
             textcolor = color.gray,
             size = size.tiny))

    // Numeric Y-axis ticks for Volatility Disorder
    for yv = -3 to 3
        array.push(ax, line.new(bar_index - 42, yv, bar_index - 38, yv, color = color.gray))
        array.push(ls, label.new(
             bar_index - 44, yv, str.tostring(yv),
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_none,
             textcolor = color.gray,
             size = size.tiny))

    // Axis labels
    array.push(ls, label.new(
         bar_index - 40, -3.55, "Power / Momentum Z-Score",
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_none,
         textcolor = color.white,
         size = size.small))

    array.push(ls, label.new(
         bar_index - 79, 3.2, "Volatility Disorder Z-Score",
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_none,
         textcolor = color.white,
         size = size.small))

    // Quadrant Labels
    array.push(ls, label.new(
         bar_index - 20, 2.7, "Explosive\nPower + / Vol +",
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_none,
         textcolor = #f23645,
         size = size.small))

    array.push(ls, label.new(
         bar_index - 60, 2.7, "Chaotic\nPower - / Vol +",
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_none,
         textcolor = #ff9800,
         size = size.small))

    array.push(ls, label.new(
         bar_index - 20, -2.7, "Efficient\nPower + / Vol -",
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_none,
         textcolor = #089981,
         size = size.small))

    array.push(ls, label.new(
         bar_index - 60, -2.7, "Weak\nPower - / Vol -",
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_none,
         textcolor = #5b9cf6,
         size = size.small))

    // Table header
    table.cell(mainT, 0, 0, "Asset", bgcolor = color.gray, text_color = color.white)
    table.cell(mainT, 1, 0, "State", bgcolor = color.gray, text_color = color.white)
    table.cell(mainT, 2, 0, "Age",   bgcolor = color.gray, text_color = color.white)
    table.cell(mainT, 3, 0, "Power", bgcolor = color.gray, text_color = color.white)
// --- Execute ---
drawOne(1,  "XLC",  x01, y01, s01, a01, #1f77b4, i01)
drawOne(2,  "XLY",  x02, y02, s02, a02, #ff7f0e, i02)
drawOne(3,  "XLP",  x03, y03, s03, a03, #2ca02c, i03)
drawOne(4,  "XLE",  x04, y04, s04, a04, #d62728, i04)
drawOne(5,  "XLF",  x05, y05, s05, a05, #9467bd, i05)
drawOne(6,  "XLV",  x06, y06, s06, a06, #8c564b, i06)
drawOne(7,  "XLI",  x07, y07, s07, a07, #e377c2, i07)
drawOne(8,  "XLB",  x08, y08, s08, a08, #7f7f7f, i08)
drawOne(9,  "XLRE", x09, y09, s09, a09, #bcbd22, i09)
drawOne(10, "XLK",  x10, y10, s10, a10, #17becf, i10)
drawOne(11, "XLU",  x11, y11, s11, a11, #393b79, i11)

drawOne(12, sym1, x12, y12, s12, a12, color.white, true)
drawOne(13, sym2, x13, y13, s13, a13, color.white, true)
drawOne(14, sym3, x14, y14, s14, a14, color.white, true)

drawOne(15, "SPY", x15, y15, s15, a15, color.gray, iSPX)

plot(x15, display = display.none)
````
