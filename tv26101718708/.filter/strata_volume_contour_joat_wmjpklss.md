# Strata Volume Contour [JOAT]

- url: https://www.tradingview.com/script/WmJpKlSS-Strata-Volume-Contour-JOAT/
- type: indicator
- pine_id: PUB;67448784dfde4979ab8f64f48099e017
- version: 1.0

## Description

[b]Strata Volume Contour [JOAT][/b]

[b]Introduction[/b]

Strata Volume Contour (SVC) is an open-source dynamic volume profile engine that divides a configurable lookback window into 25 equidistant price bins and accumulates the total traded volume within each bin. The result is a real-time horizontal histogram drawn to the right of the current bar, showing exactly where the market has spent the most volume over the selected period. The Point of Control (POC) — the highest-volume bin — is highlighted as the dominant fair-value level. The Value Area — the range of bins containing 70% of total volume — is shaded to mark the institutional accumulation zone.

The problem SVC solves is the inability of time-based charts to show volume distribution across price levels. Standard volume bars show how much was traded each period, but not at which prices. Volume profile reveals the price levels that attracted the most participation — these are the levels where institutional orders were concentrated, making them the most meaningful support and resistance references available. SVC brings this institutional-grade analysis directly to the chart without requiring specialized volume profile software.

[image]https://www.tradingview.com/x/2DU93OZs/[/image]

[b]Core Concepts[/b]

[b]1. Price Range Binning[/b]

The indicator determines the highest high and lowest low across the full lookback window, then divides this range into 25 equal-width bins. Each bin represents a price zone:

[pine]
float rangeHi = ta.highest(high, math.min(bar_index + 1, lookback))
float rangeLo = ta.lowest( low,  math.min(bar_index + 1, lookback))
float binStep = (rangeHi - rangeLo) / BINS
[/pine]

A zero-range guard (binStep > 0) prevents division errors on flat or illiquid instruments. With 25 bins, the histogram provides enough granularity to identify structural features while remaining visually clean.

[b]2. Volume Accumulation (Performance-Gated)[/b]

Volume accumulation runs exclusively on the last bar of the chart (barstate.islast). This is a critical design decision: running the O(bins x lookback) double-loop on every bar within the lookback window would create an O(bars x bins x lookback) computational cost that exceeds TradingView's execution limits on longer charts. By gating to the last bar, the full recalculation costs O(bins x lookback) exactly once per chart update:

[pine]
if barstate.islast
    if binStep > 0.0
        for i = 0 to BINS - 1
            float binLevel = rangeLo + binStep * i
            float binVol   = 0.0
            for k = 0 to lookback - 1
                if math.abs(close[k] - binLevel) <= binStep
                    binVol += nz(volume[k], 0.0)
            array.set(volBins, i, binVol)
[/pine]

Each bar within the lookback is assigned to the nearest bin based on its closing price.

[b]3. Point of Control (POC)[/b]

The POC is the bin with the highest accumulated volume. It represents the price level where the most trading activity occurred over the lookback period. Markets tend to use the POC as a magnet — price is attracted to it during consolidation and uses it as a reference when transitioning between ranges. The POC is rendered with a distinct highlight color (default orange) to make it immediately identifiable.

[b]4. Value Area Calculation (70% Rule)[/b]

The Value Area is determined by a symmetric expansion algorithm. Starting from the POC, the algorithm expands outward one bin at a time, always adding the bin (above or below) that contributes the most volume, until the accumulated volume within the expanding range reaches 70% of total volume:

[pine]
while vaVol < vaTarget and (vaLow > 0 or vaHigh < BINS - 1)
    float addUp = vaHigh < BINS - 1 ? array.get(volBins, vaHigh + 1) : 0.0
    float addDn = vaLow  > 0        ? array.get(volBins, vaLow  - 1) : 0.0
    if addUp >= addDn and vaHigh < BINS - 1
        vaHigh += 1
        vaVol  += addUp
    else if vaLow > 0
        vaLow  -= 1
        vaVol  += addDn
[/pine]

The Value Area High (VAH) and Value Area Low (VAL) define the institutional accumulation zone. Price outside the value area represents a premium (above) or discount (below) relative to the lookback period's fair value.

[b]5. Horizontal Histogram Visualization[/b]

Each bin is drawn as a horizontal box extending rightward from the current bar. The box width is proportional to the bin's volume relative to the POC volume — the POC spans the maximum width (50 bars right), and all other bins scale proportionally. Volume amounts are labeled on each bar.

[b]Features[/b]

[list]
[*][b]25-Bin Volume Profile Histogram:[/b] Full horizontal volume distribution rendered to the right of price with proportional bar widths and volume labels
[*][b]Point of Control (POC):[/b] Highest-volume bin highlighted in a distinct color (default orange) with automatic detection each bar update
[*][b]Value Area (VAH / VAL):[/b] The 70%-volume range shaded in a distinct color, with Value Area High and Low explicitly tracked and displayed in the dashboard
[*][b]Gradient Bin Coloring:[/b] Each non-POC, non-VA bin is colored on a gradient from low volume (nearly transparent) to high volume (full opacity), creating a visual density map
[*][b]Static Level Plots:[/b] All 25 bin levels are plotted as horizontal lines over the lookback window, providing a persistent price level grid even without the boxes visible
[*][b]Price vs POC Context:[/b] The dashboard reports whether price is currently Above POC, Below POC, or At POC
[*][b]8-Row Dashboard (Top Right):[/b] POC price, VA High, VA Low, price vs POC relationship, total volume, lookback period, and version
[*][b]Watermark:[/b] JackOfAllTrades signature at chart center-bottom
[/list]

[b]Input Parameters[/b]

[b]Profile Settings:[/b]
[list]
[*]Lookback Period: Number of bars to include in the volume accumulation (default: 200, range: 50-500)
[/list]

[b]Visual Settings:[/b]
[list]
[*]Show Volume Bins: Toggle the horizontal histogram boxes
[*]Bin Color: Base color for the bin gradient (default: blue)
[*]Bin Width: Border width of histogram boxes (default: 1, range: 0-5)
[*]Highlight POC: Toggle POC highlighting
[*]POC Color: Color for the highest-volume bin (default: orange)
[*]Show Value Area: Toggle the 70%-volume range shading
[*]VA High Color: Color for the Value Area High reference
[*]VA Low Color: Color for the Value Area Low reference
[*]Theme: Auto, Dark, or Light
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Identify the Point of Control[/b]
The POC is the most important level on the profile. It is the price the market spent the most time trading at — the ultimate fair-value anchor. Price below the POC is at a discount; above is at a premium. Trading setups at the POC during retest often exhibit tight risk/reward.

[b]Step 2: Use Value Area Boundaries for Support and Resistance[/b]
The Value Area High and Low are the primary structural boundaries. Price often oscillates within the value area and struggles when attempting to leave it. A close outside the value area with high volume often signals the beginning of a new directional move.

[b]Step 3: Adjust Lookback to Your Trading Style[/b]
Shorter lookbacks (50-100 bars) produce a profile of recent price structure, relevant for intraday traders. Longer lookbacks (300-500 bars) produce a macro structural view, relevant for swing traders. The POC and value area boundaries shift as the lookback changes.

[b]Step 4: Watch Price Return to the POC[/b]
After price moves away from the POC, it frequently returns to it during low-volume periods. When price is far from the POC and trending, the POC can serve as a magnet target for reversion. When price is oscillating around the POC, it reflects a balanced, two-sided auction.

[image]https://www.tradingview.com/x/7A0oB908/[/image]

[b]Indicator Limitations[/b]

[list]
[*]The profile recalculates only on barstate.islast — it reflects the state at the last confirmed bar. During real-time market hours, the profile is not updating tick-by-tick; it updates each time a bar closes
[*]The volume accumulation assigns each bar to a bin based on closing price, not the intrabar high-low range. This is a simplification — a professional volume profile distributes volume across all prices touched during the bar. The close-based method is computationally feasible within Pine Script's constraints
[*]The 25-bin resolution is fixed. Very large price ranges (e.g., a lookback spanning a major crash) may produce bins too wide to be structurally meaningful. Users should adjust the lookback to keep the range within a reasonable structural period
[*]Instruments with no volume data (some indices, spot forex) will show all zero bins and the profile will not render meaningfully
[*]The histogram boxes are drawn to the right of the current bar. On instruments with extended right-side padding disabled, the boxes may be partially hidden off-chart
[/list]

[b]Originality Statement[/b]

SVC is original in its approach to making volume profile accessible within Pine Script's performance constraints. This indicator is published because:

[list]
[*]The barstate.islast performance gate is the key design innovation — it collapses what would otherwise be an O(bars x bins x lookback) computation into a single O(bins x lookback) pass, making a 25-bin volume profile with 500-bar lookback feasible within TradingView's execution limits
[*]The 70% Value Area algorithm uses a symmetric expansion approach (always adding the larger of the next bin up or down) that correctly implements the standard Volume Profile Value Area methodology
[*]The gradient bin coloring uses color.from_gradient() against the POC volume as the maximum reference, making the visual density map adaptive to the actual volume distribution rather than a fixed scale
[*]The Price vs POC contextual label in the dashboard provides an immediately actionable market context read without requiring the user to visually judge their position relative to the histogram
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss. Volume profile levels are based on historical volume distribution and represent areas of past interest, not guarantees of future price behavior. The Point of Control and Value Area boundaries can and do shift significantly as the lookback window evolves. Always use proper risk management. The author is not responsible for any trading losses resulting from the use of this indicator.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(
    title            = "Strata Volume Contour [JOAT]",
    shorttitle       = "SVC [JOAT]",
    overlay          = true,
    max_lines_count  = 500,
    max_labels_count = 500,
    max_boxes_count  = 500)

// ─── Groups ───────────────────────────────────────────────────────────────────
G_CORE  = "Profile Settings"
G_VIS   = "Visual Settings"
G_DASH  = "Dashboard"

INDICATOR_VERSION = "v1.0.0"

// ─── Inputs ───────────────────────────────────────────────────────────────────
lookback     = input.int(200,  "Lookback Period",      minval=50,  maxval=500,  group=G_CORE,
    tooltip="Number of bars to include in the volume profile calculation")
showProfile  = input.bool(true,  "Show Volume Bins",    group=G_VIS)
binClr       = input.color(#0288D1, "Bin Color",        inline="bin", group=G_VIS)
binWidth     = input.int(1,        "",    minval=0, maxval=5, inline="bin", group=G_VIS)
showPoc      = input.bool(true,  "Highlight POC",       group=G_VIS,
    tooltip="Point of Control — the price bin with the highest volume")
pocClr       = input.color(#FF6F00, "POC Color",        group=G_VIS)
showVa       = input.bool(true,  "Show Value Area",     group=G_VIS,
    tooltip="Value Area = bins containing 70% of total volume (institutional range)")
vaHiClr      = input.color(#26A69A, "VA High",          inline="va", group=G_VIS)
vaLoClr      = input.color(#EF5350, "VA Low",           inline="va", group=G_VIS)
showDash     = input.bool(true,  "Show Dashboard",      group=G_DASH)
dashPosStr   = input.string("Top Right","Position",
    options=["Top Left","Top Right","Bottom Left","Bottom Right"], group=G_DASH)
showWM       = input.bool(true,  "Show Watermark",      group=G_VIS)
themeStr     = input.string("Auto","Theme",options=["Auto","Dark","Light"], group=G_VIS)

// ─── Theme ────────────────────────────────────────────────────────────────────
isDark  = switch themeStr
    "Dark"  => true
    "Light" => false
    =>         color.r(chart.bg_color) < 128

TXT     = isDark ? #E0E0E0 : #1A1A1A
TXT_M   = isDark ? color.new(#9E9E9E, 0) : color.new(#757575, 0)
TBL_BG  = isDark ? color.new(#0D1117, 5) : color.new(#FFFFFF, 5)
TBL_BD  = isDark ? color.new(#21262D, 0) : color.new(#D0D0D0, 0)
TBL_ALT = isDark ? color.new(#161B22, 0) : color.new(#F6F8FA, 0)
HDR_BG  = color.new(#1565C0, 0)
WM_C    = isDark ? color.new(#FFFFFF, 85) : color.new(#000000, 85)

getDashPos(string s) =>
    switch s
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        =>               position.top_right

// ─── Utility ──────────────────────────────────────────────────────────────────
safeDiv(float n, float d, float fb = 0.0) =>
    d != 0.0 and not na(n) and not na(d) ? n / d : fb

// ─── Profile Constants ────────────────────────────────────────────────────────
int BINS = 25

// ─── Profile State Arrays ─────────────────────────────────────────────────────
var array<float> levels  = array.new<float>(BINS, na)
var array<float> volBins = array.new<float>(BINS, 0.0)
var array<color> colors  = array.new<color>(BINS, color.new(color.white, 100))
var array<box>   profile = array.new<box>()

// ─── Range for current lookback window ────────────────────────────────────────
float rangeHi = ta.highest(high, math.min(bar_index + 1, lookback))
float rangeLo = ta.lowest( low,  math.min(bar_index + 1, lookback))
float binStep = (rangeHi - rangeLo) / BINS

// ─── Volume Accumulation — runs ONLY on barstate.islast for performance ────────
// FIX: Previously ran on every bar within lookback window → O(bars × BINS × lookback)
// which caused TradingView "execution timeout" on assets with many bars.
// Now runs once per confirmed last-bar update: O(BINS × lookback) total.
if barstate.islast

    // Clear previous profile boxes
    for b in profile
        box.delete(b)
    array.clear(profile)

    // FIX: Guard against zero-range (flat price, no data) to avoid div/0 downstream
    if binStep > 0.0

        // Accumulate volume into bins
        for i = 0 to BINS - 1
            float binLevel = rangeLo + binStep * i
            float binVol   = 0.0
            for k = 0 to lookback - 1
                if math.abs(close[k] - binLevel) <= binStep
                    binVol += nz(volume[k], 0.0)
            array.set(levels,  i, binLevel)
            array.set(volBins, i, binVol)

        float maxVol = array.max(volBins)
        float totVol = array.sum(volBins)

        // Color each bin by its volume relative to maximum
        for i = 0 to BINS - 1
            float v = array.get(volBins, i)
            array.set(colors, i, color.from_gradient(v, 0.0, maxVol, color.new(binClr, 95), color.new(binClr, 20)))

        // ─── Value Area Calculation (70% of total volume) ────────────────────
        int   pocIdx = 0
        float pocVol = 0.0
        for i = 0 to BINS - 1
            if array.get(volBins, i) > pocVol
                pocVol := array.get(volBins, i)
                pocIdx := i

        float vaVol    = pocVol
        float vaTarget = totVol * 0.70
        int   vaLow    = pocIdx
        int   vaHigh   = pocIdx

        while vaVol < vaTarget and (vaLow > 0 or vaHigh < BINS - 1)
            float addUp = vaHigh < BINS - 1 ? array.get(volBins, vaHigh + 1) : 0.0
            float addDn = vaLow  > 0        ? array.get(volBins, vaLow  - 1) : 0.0
            if addUp >= addDn and vaHigh < BINS - 1
                vaHigh += 1
                vaVol  += addUp
            else if vaLow > 0
                vaLow  -= 1
                vaVol  += addDn
            else
                vaHigh += 1
                vaVol  += addUp

        // ─── Draw Profile Boxes ───────────────────────────────────────────────
        if showProfile
            for i = 0 to BINS - 1
                float level  = array.get(levels, i)
                float volVal = array.get(volBins, i)
                int   barW   = int(safeDiv(volVal, maxVol, 0.0) * 50)
                bool  isPoc  = i == pocIdx
                bool  inVa   = i >= vaLow and i <= vaHigh

                color boxClr = isPoc and showPoc ? pocClr :
                               inVa  and showVa  ? color.new(binClr, 60) :
                                                   array.get(colors, i)

                box b = box.new(bar_index + 3, level + binStep * 0.48,
                                bar_index + 3 + barW, level - binStep * 0.48,
                                chart.bg_color, 1, bgcolor=boxClr,
                                text=str.tostring(volVal, format.volume),
                                text_halign=text.align_left,
                                text_size=size.tiny)
                array.push(profile, b)

// ─── Static Level Plots ───────────────────────────────────────────────────────
// Plot each bin level as a horizontal line (show_last limits to lookback window)
display_ = showProfile ? display.all : display.none

plot(array.get(levels, 0 ), color=array.get(colors, 0 ), show_last=lookback, editable=false, display=display_, linewidth=binWidth)
plot(array.get(levels, 1 ), color=array.get(colors, 1 ), show_last=lookback, editable=false, display=display_, linewidth=binWidth)
plot(array.get(levels, 2 ), color=array.get(colors, 2 ), show_last=lookback, editable=false, display=display_, linewidth=binWidth)
plot(array.get(levels, 3 ), color=array.get(colors, 3 ), show_last=lookback, editable=false, display=display_, linewidth=binWidth)
plot(array.get(levels, 4 ), color=array.get(colors, 4 ), show_last=lookback, editable=false, display=display_, linewidth=binWidth)
plot(array.get(levels, 5 ), color=array.get(colors, 5 ), show_last=lookback, editable=false, display=display_, linewidth=binWidth)
plot(array.get(levels, 6 ), color=array.get(colors, 6 ), show_last=lookback, editable=false, display=display_, linewidth=binWidth)
plot(array.get(levels, 7 ), color=array.get(colors, 7 ), show_last=lookback, editable=false, display=display_, linewidth=binWidth)
plot(array.get(levels, 8 ), color=array.get(colors, 8 ), show_last=lookback, editable=false, display=display_, linewidth=binWidth)
plot(array.get(levels, 9 ), color=array.get(colors, 9 ), show_last=lookback, editable=false, display=display_, linewidth=binWidth)
plot(array.get(levels, 10), color=array.get(colors, 10), show_last=lookback, editable=false, display=display_, linewidth=binWidth)
plot(array.get(levels, 11), color=array.get(colors, 11), show_last=lookback, editable=false, display=display_, linewidth=binWidth)
plot(array.get(levels, 12), color=array.get(colors, 12), show_last=lookback, editable=false, display=display_, linewidth=binWidth)
plot(array.get(levels, 13), color=array.get(colors, 13), show_last=lookback, editable=false, display=display_, linewidth=binWidth)
plot(array.get(levels, 14), color=array.get(colors, 14), show_last=lookback, editable=false, display=display_, linewidth=binWidth)
plot(array.get(levels, 15), color=array.get(colors, 15), show_last=lookback, editable=false, display=display_, linewidth=binWidth)
plot(array.get(levels, 16), color=array.get(colors, 16), show_last=lookback, editable=false, display=display_, linewidth=binWidth)
plot(array.get(levels, 17), color=array.get(colors, 17), show_last=lookback, editable=false, display=display_, linewidth=binWidth)
plot(array.get(levels, 18), color=array.get(colors, 18), show_last=lookback, editable=false, display=display_, linewidth=binWidth)
plot(array.get(levels, 19), color=array.get(colors, 19), show_last=lookback, editable=false, display=display_, linewidth=binWidth)
plot(array.get(levels, 20), color=array.get(colors, 20), show_last=lookback, editable=false, display=display_, linewidth=binWidth)
plot(array.get(levels, 21), color=array.get(colors, 21), show_last=lookback, editable=false, display=display_, linewidth=binWidth)
plot(array.get(levels, 22), color=array.get(colors, 22), show_last=lookback, editable=false, display=display_, linewidth=binWidth)
plot(array.get(levels, 23), color=array.get(colors, 23), show_last=lookback, editable=false, display=display_, linewidth=binWidth)
plot(array.get(levels, 24), color=array.get(colors, 24), show_last=lookback, editable=false, display=display_, linewidth=binWidth)

// ─── Range Reference Plots ────────────────────────────────────────────────────
plot(rangeHi, "Range High", color=color.new(chart.fg_color, 80), show_last=lookback, display=display.none)
plot(rangeLo, "Range Low",  color=color.new(chart.fg_color, 80), show_last=lookback, display=display.none)

// ─── Dashboard ────────────────────────────────────────────────────────────────
// Read POC and VA from the most-recently-computed profile
float dashPoc   = na
float dashVaHi  = na
float dashVaLo  = na
float dashTotVol = 0.0

if array.size(volBins) > 0
    float mxV = array.max(volBins)
    float ttV = array.sum(volBins)
    dashTotVol := ttV
    int pIdx = 0
    for i = 0 to BINS - 1
        if array.get(volBins, i) >= mxV
            pIdx := i
    dashPoc := array.get(levels, pIdx)

    int vaL = pIdx
    int vaH = pIdx
    float vaA = array.get(volBins, pIdx)
    float vaTgt = ttV * 0.70
    while vaA < vaTgt and (vaL > 0 or vaH < BINS - 1)
        float u = vaH < BINS - 1 ? array.get(volBins, vaH + 1) : 0.0
        float d = vaL > 0        ? array.get(volBins, vaL - 1) : 0.0
        if u >= d and vaH < BINS - 1
            vaH += 1
            vaA += u
        else if vaL > 0
            vaL -= 1
            vaA += d
        else
            vaH += 1
            vaA += u
    dashVaHi := array.get(levels, vaH) + binStep
    dashVaLo := array.get(levels, vaL)

if showDash and barstate.islast
    var tbl = table.new(getDashPos(dashPosStr), 2, 8, TBL_BG, TBL_BD, 1, TBL_BD, 1)

    table.cell(tbl, 0, 0, "JOAT  |  Strata Volume",
        text_color=#FFFFFF, bgcolor=HDR_BG, text_size=size.small, text_halign=text.align_center)
    table.merge_cells(tbl, 0, 0, 1, 0)

    table.cell(tbl, 0, 1, "POC",        text_color=TXT_M, text_size=size.small, bgcolor=TBL_BG)
    table.cell(tbl, 1, 1, not na(dashPoc) ? str.tostring(dashPoc, format.mintick) : "—",
        text_color=pocClr, text_size=size.small, bgcolor=TBL_BG)

    table.cell(tbl, 0, 2, "VA High",    text_color=TXT_M, text_size=size.small, bgcolor=TBL_ALT)
    table.cell(tbl, 1, 2, not na(dashVaHi) ? str.tostring(dashVaHi, format.mintick) : "—",
        text_color=vaHiClr, text_size=size.small, bgcolor=TBL_ALT)

    table.cell(tbl, 0, 3, "VA Low",     text_color=TXT_M, text_size=size.small, bgcolor=TBL_BG)
    table.cell(tbl, 1, 3, not na(dashVaLo) ? str.tostring(dashVaLo, format.mintick) : "—",
        text_color=vaLoClr, text_size=size.small, bgcolor=TBL_BG)

    table.cell(tbl, 0, 4, "Price vs POC", text_color=TXT_M, text_size=size.small, bgcolor=TBL_ALT)
    string pocRel = not na(dashPoc) ? (close > dashPoc ? "Above POC" : close < dashPoc ? "Below POC" : "At POC") : "—"
    color  pocRelC = not na(dashPoc) ? (close > dashPoc ? #00C853 : #D50000) : TXT_M
    table.cell(tbl, 1, 4, pocRel, text_color=pocRelC, text_size=size.small, bgcolor=TBL_ALT)

    table.cell(tbl, 0, 5, "Total Vol",  text_color=TXT_M, text_size=size.small, bgcolor=TBL_BG)
    table.cell(tbl, 1, 5, str.tostring(dashTotVol, format.volume),
        text_color=TXT, text_size=size.small, bgcolor=TBL_BG)

    table.cell(tbl, 0, 6, "Lookback",   text_color=TXT_M, text_size=size.small, bgcolor=TBL_ALT)
    table.cell(tbl, 1, 6, str.tostring(lookback) + " bars",
        text_color=TXT, text_size=size.small, bgcolor=TBL_ALT)

    table.cell(tbl, 0, 7, "Version",    text_color=TXT_M, text_size=size.tiny,  bgcolor=TBL_BG)
    table.cell(tbl, 1, 7, INDICATOR_VERSION, text_color=TXT_M, text_size=size.tiny, bgcolor=TBL_BG)

// ─── Watermark ────────────────────────────────────────────────────────────────
if showWM and barstate.islast
    var wmT = table.new(position.bottom_center, 1, 1,
        bgcolor=color.new(color.black, 100), border_color=color.new(color.black, 100), border_width=0)
    table.cell(wmT, 0, 0, "JackOfAllTrades",
        text_color=WM_C, text_size=size.normal, text_halign=text.align_center,
        bgcolor=color.new(color.black, 100))
````
