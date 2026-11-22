# US Yield Curve - 10Y-2Y & 10Y-3M

- url: https://www.tradingview.com/script/irBf5tYb-US-Yield-Curve-10Y-2Y-10Y-3M/
- type: indicator
- pine_id: PUB;a53d4debba644b79bacf2f8c3edd852b
- version: 1.0

## Description

[b]US Yield Curve — 10Y-2Y & 10Y-3M[/b]

Track the two most-watched US Treasury yield curve spreads in a single panel. The 10Y-2Y and 10Y-3M spreads are the gold standard for reading the bond market's view on growth, inflation, and Fed policy — and historically the most reliable leading indicators of US recessions.

[b]What it shows[/b]

Two spreads plotted in basis points:
[list]
[*][b]10Y - 2Y[/b] (blue) — the classic "belly to long end" spread, watched by every rates desk on the street
[*][b]10Y - 3M[/b] (orange) — the Fed's preferred recession indicator, used in the New York Fed's recession probability model
[/list]

Positive values mean a normal upward-sloping curve (long yields above short yields). Negative values mean an inverted curve — the market is pricing in slower growth and Fed easing ahead.

[b]Why it matters[/b]

The yield curve is one of the most studied signals in macroeconomics for a reason: [b]the 10Y-3M spread has inverted before every US recession since 1955[/b], typically 6 to 18 months in advance. The 10Y-2Y has a similar track record. Beyond recession signaling, the curve tells you:
[list]
[*]Whether the market expects the Fed to hike or cut
[*]How tight monetary policy is relative to long-term growth expectations
[*]When to position for risk-on (steepening) vs risk-off (flattening/inverting)
[*]Macro context for equities, FX, and credit positioning
[/list]

A classic pattern to watch: [b]bull steepening after a deep inversion[/b]. When a previously inverted curve rapidly re-steepens because short rates fall faster than long rates, the Fed is usually cutting into a slowdown — historically a moment of high market stress.

[b]Features[/b]

[list]
[*][b]Basis points display[/b] — the standard unit for rates analysis
[*][b]End-of-line labels[/b] with current spread values and automatic anti-overlap positioning
[*][b]Inversion zone highlighting[/b] — colored fill below zero makes inversion periods instantly visible
[*][b]Optional zero-cross markers[/b] — dots at each curve inversion/normalization for historical study
[*][b]Toggle each spread[/b] independently if you want to focus on just one
[*][b]Zero line[/b] reference for clarity
[/list]

[b]Settings[/b]

[list]
[*][b]Show 10Y - 2Y / 10Y - 3M[/b]: toggle each spread on/off
[*][b]Line thickness[/b]: 1 to 4
[*][b]Show end labels[/b]: display currency tags with live values at the right edge
[*][b]Highlight inversion zone[/b]: color fill below zero
[*][b]Show inversion markers[/b]: dots at zero crossings (recommended on daily/weekly charts)
[/list]

[b]Recommended setup[/b]

Best viewed on daily or weekly timeframes to see the full macro picture and historical inversions. Pairs well with equity indices (SPX, NDX) to study how stocks behave around curve inversions and steepenings. Also useful alongside DXY and gold to track the broader macro regime.

For intraday rates traders, works on shorter timeframes too — just expect the spread to move less since the curve doesn't whip around like FX or equities.

[b]Notes[/b]

Uses TVC symbols US10Y, US02Y, and US03MY. Data availability depends on your TradingView plan; if a yield doesn't render, your plan may not include that exchange. The 3-month bill is the Fed's chosen benchmark for the short end (rather than 1-month or fed funds) because it filters out the noise of operational liquidity flows.

Feedback and suggestions welcome.

## Source Code

````pine
//@version=6
indicator("US Yield Curve — 10Y-2Y & 10Y-3M", overlay=false, precision=1)

// === Inputs ===
show10Y2Y   = input.bool(true,  "Show 10Y - 2Y")
show10Y3M   = input.bool(true,  "Show 10Y - 3M")
lw          = input.int(2, "Line thickness", minval=1, maxval=4)
showLabels  = input.bool(true, "Show end labels")
showZero    = input.bool(true, "Show zero line")
fillRegime  = input.bool(true, "Highlight inversion zone")
showRecess  = input.bool(false, "Show inversion markers")

// === Colors ===
c10Y2Y = color.rgb(59,130,246)    // blue
c10Y3M = color.rgb(245,158,11)    // orange

// === Fetch yields ===
us10y = request.security("TVC:US10Y",  timeframe.period, close)
us02y = request.security("TVC:US02Y",  timeframe.period, close)
us03m = request.security("TVC:US03MY", timeframe.period, close)

// === Spreads in basis points ===
spread10Y2Y = (us10y - us02y) * 100
spread10Y3M = (us10y - us03m) * 100

// === Plots ===
p2Y = plot(show10Y2Y ? spread10Y2Y : na, "10Y - 2Y", color=c10Y2Y, linewidth=lw)
p3M = plot(show10Y3M ? spread10Y3M : na, "10Y - 3M", color=c10Y3M, linewidth=lw)
p0  = plot(showZero ? 0 : na, "Zero", color=color.new(color.gray, 50), linewidth=1)

// === Inversion zone fill (when spread is negative) ===
fill(p2Y, p0, (fillRegime and show10Y2Y and spread10Y2Y < 0) ? color.new(c10Y2Y, 85) : na)
fill(p3M, p0, (fillRegime and show10Y3M and spread10Y3M < 0) ? color.new(c10Y3M, 85) : na)

// === Inversion crossover markers (optional) ===
cross2Y = ta.cross(spread10Y2Y, 0)
cross3M = ta.cross(spread10Y3M, 0)
plotshape(showRecess and cross2Y, "2Y cross", style=shape.circle, location=location.absolute, color=c10Y2Y, size=size.tiny)
plotshape(showRecess and cross3M, "3M cross", style=shape.circle, location=location.absolute, color=c10Y3M, size=size.tiny)

// === End labels (non-overlapping) ===
var label lbl2Y = na
var label lbl3M = na
var line  ln2Y  = na
var line  ln3M  = na

if showLabels and barstate.islast
    label.delete(lbl2Y)
    label.delete(lbl3M)
    line.delete(ln2Y)
    line.delete(ln3M)

    v2Y = na(spread10Y2Y) ? 0.0 : spread10Y2Y
    v3M = na(spread10Y3M) ? 0.0 : spread10Y3M

    // Auto gap based on amplitude
    rng     = math.abs(v2Y - v3M)
    autoGap = math.max(3.0, rng * 0.15)

    // Anti-overlap positioning
    dispY2Y = v2Y
    dispY3M = v3M
    if math.abs(v2Y - v3M) < autoGap
        if v2Y >= v3M
            dispY2Y := (v2Y + v3M) / 2 + autoGap / 2
            dispY3M := (v2Y + v3M) / 2 - autoGap / 2
        else
            dispY2Y := (v2Y + v3M) / 2 - autoGap / 2
            dispY3M := (v2Y + v3M) / 2 + autoGap / 2

    xOff = 3

    if show10Y2Y
        txt2Y = "10Y-2Y  " + str.tostring(v2Y, "+#.#;-#.#") + " bps"
        ln2Y  := line.new(bar_index, v2Y, bar_index + xOff, dispY2Y, xloc=xloc.bar_index, color=color.new(c10Y2Y, 40), width=1)
        lbl2Y := label.new(bar_index + xOff, dispY2Y, txt2Y, xloc=xloc.bar_index, color=c10Y2Y, textcolor=color.white, style=label.style_label_left, size=size.small)

    if show10Y3M
        txt3M = "10Y-3M  " + str.tostring(v3M, "+#.#;-#.#") + " bps"
        ln3M  := line.new(bar_index, v3M, bar_index + xOff, dispY3M, xloc=xloc.bar_index, color=color.new(c10Y3M, 40), width=1)
        lbl3M := label.new(bar_index + xOff, dispY3M, txt3M, xloc=xloc.bar_index, color=c10Y3M, textcolor=color.white, style=label.style_label_left, size=size.small)
````
