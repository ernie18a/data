# Gap & Base Breakout Screener

- url: https://www.tradingview.com/script/2LQ0JaWB-Gap-Base-Breakout-Screener/
- type: indicator
- pine_id: PUB;9584aff9f3664f9a903a9033e9d81be2
- version: 1.0

## Description

Finds stocks that gap up, go quiet in a tight sideways base, then break out of the top of that base on a wide-range bar. Built for the Pine Screener, and it also draws the setup on your chart.

[b]How it works[/b]
[list=1]
[*][b]Gap:[/b] an open at least 4% above the prior close, on 1.5x the 50-day average volume.
[*][b]Base:[/b] the longest stretch of 5+ bars whose high-to-low range stays within your max width (default 10%). It must start within 10 bars of the gap and hold above the pre-gap close.
[*][b]Breakout:[/b] the high clears the base high, the bar closes in the top 30% of its range, the range is at least 1.5x the 20-day average, and volume is at least average.
[/list]
Why the high and not the close: on the chart, MSFT's Sep 25, 2026 bar cleared its 38-day base intraday (high 519.40 vs base high 517.77) but closed at 516.17, just inside. A close-only trigger misses day one of the move. The strong-close filter keeps wicky fakeouts out.

[b]How to use it (Pine Screener)[/b]
[list=1]
[*]Add the script to Favorites, open the Pine Screener and pick an index or watchlist.
[*]Add indicator, select this script and set the timeframe to 1D.
[*]Filter "1 Breakout" above 0.5 for today's breakouts, or "2 In Base" above 0.5 for stocks still basing.
[*]Click Scan. For In Base, sort "7 Dist To Base High pct" ascending: the names closest to the lid come first.
[/list]
[b]Settings:[/b] change the range width (for example 5% or 2%) with the gear icon. For tight widths, raise "Max bars from gap to base start" to about 40, because tight ranges usually form late in a longer consolidation.

[b]Columns:[/b] Breakout (1/0), In Base (1/0), Base Days, Base Width %, Bars Since Gap, Gap %, Distance to Base High %, Bar Range x Average, Relative Volume, 20-day Dollar Volume ($M).

[b]On the chart:[/b] the yellow box is the current base, labeled with its length and width. The green label marks the gap. The triangle marks the breakout bar. Two alerts: Gap Base Breakout and Gap Base Setup.

[b]What makes it different:[/b] instead of measuring a fixed lookback, it searches for the longest base that fits your width, ties that base to a specific gap-up, and requires the base to hold the gap. The result is post-gap consolidations, not random tight ranges.

[b]Limitations[/b]
[list]
[*]Cash buyouts gap up and then pin flat near the deal price, which looks like a base. A minimum 5-day average daily range (default 0.75%) removes most of them. Check the news on anything under about 3% wide.
[*]It cannot tell whether the gap came from a real earnings beat. Check the catalyst yourself.
[*]Pine Screener calculates on the last 500 bars. The base search looks back up to 120 bars by default.
[*]A setup is not a guarantee. Many bases fail or break down instead.
[/list]

## Source Code

````pine
//@version=6
// Gap & Base Breakout Screener - built for TradingView Pine Screener
// Setup: (1) a gap up, (2) a tight sideways base that lasts N+ bars and stays
// within X% high-to-low, (3) a wide-range breakout bar out of the top of the base.
// Reference case: MSFT - gap +12.1% Jul 30 2026, 38-day base Aug 3-Sep 24 (9.0% wide),
// Fri Sep 25 bar 2.2x avg range: high 519.40 cleared the base, close 516.17 did not.
// That is why the default trigger is the HIGH plus a strong close, not the close alone.
// Min ADR filter exists because of MKTX: +29.8% gap on the ICE $167 cash buyout (Jul 30 2026),
// then a 1.4%-wide 'base' that is really deal pinning, not accumulation. Same for PRTH
// and BWIN (Sep 2026). A 5-day window catches a fresh pin; a 20-day window did not.
// Pine Screener reads ONLY the first 10 plots + 2 alertconditions. Add one, delete one.
indicator("Gap & Base Breakout Screener", shorttitle = "Gap+Base", overlay = true, max_bars_back = 300, max_boxes_count = 10, max_labels_count = 10)
maxPct = input.float(10.0, "Max base width %", minval = 0.5, step = 0.5, group = "Base", display = display.none)
minDays = input.int(5, "Min base length (bars)", minval = 2, group = "Base", display = display.none)
maxDays = input.int(120, "Max base length searched (bars)", minval = 5, maxval = 200, group = "Base", display = display.none)
widthMode = input.string("High/Low", "Measure base width on", options = ["High/Low", "Closes"], group = "Base", display = display.none)
gapMin = input.float(4.0, "Min gap up %", minval = 0.0, step = 0.5, group = "Gap", display = display.none)
gapVolMult = input.float(1.5, "Gap day volume vs 50d avg", minval = 0.0, step = 0.1, group = "Gap", display = display.none)
maxRunBars = input.int(10, "Max bars from gap to base start", minval = 0, maxval = 60, group = "Gap", display = display.none)
reqHold = input.bool(true, "Base must hold above pre-gap close", group = "Gap", display = display.none)
boTrigger = input.string("High", "Breakout trigger (price that must clear base high)", options = ["High", "Close"], group = "Breakout", display = display.none)
boCloseLoc = input.float(70.0, "Breakout close in top % of bar (0 = off)", minval = 0.0, maxval = 100.0, step = 5.0, group = "Breakout", display = display.none)
bigBarMult = input.float(1.5, "Breakout bar range vs 20d avg range", minval = 0.0, step = 0.1, group = "Breakout", display = display.none)
boVolMult = input.float(1.0, "Breakout volume vs 50d avg", minval = 0.0, step = 0.1, group = "Breakout", display = display.none)
minPrice = input.float(5.0, "Min price", minval = 0.0, group = "Liquidity", display = display.none)
minDVolM = input.float(10.0, "Min 20d avg dollar volume ($M)", minval = 0.0, group = "Liquidity", display = display.none)
minADR = input.float(0.75, "Min 5-day avg daily range % (drops buyout-pinned stocks)", minval = 0.0, step = 0.25, group = "Liquidity", display = display.none)
useClose = widthMode == "Closes"
avgVol50 = ta.sma(volume, 50)
avgRange20 = ta.sma(high - low, 20)
dVolM = ta.sma(close * volume, 20) / 1000000
adrPct = 100 * (ta.sma(high / low, 5) - 1)
calcOK = last_bar_index - bar_index < 300
// Longest window ending at startOff whose high-to-low width stays within maxPct
f_base(int startOff, bool run) =>
    float hh = na
    float ll = na
    int n = 0
    if run
        for i = startOff to startOff + maxDays - 1
            float h = useClose ? close[i] : high[i]
            float l = useClose ? close[i] : low[i]
            if na(h) or na(l)
                break
            float nh = na(hh) ? h : math.max(hh, h)
            float nl = na(ll) ? l : math.min(ll, l)
            if (nh - nl) / nl * 100 > maxPct
                break
            hh := nh
            ll := nl
            n += 1
    [n, hh, ll]
// Nearest qualifying gap-up bar at or before the oldest bar of the base
f_gap(int startOff, int baseLen, bool run) =>
    int found = -1
    float gp = na
    if run and baseLen >= 1
        int first = startOff + baseLen - 1
        for i = first to first + maxRunBars
            float prevC = close[i + 1]
            if not na(prevC) and open[i] >= prevC * (1 + gapMin / 100) and volume[i] >= gapVolMult * avgVol50[i + 1]
                found := i
                gp := (open[i] / prevC - 1) * 100
                break
    [found, gp]
[len0, hi0, lo0] = f_base(0, calcOK)
[len1, hi1, lo1] = f_base(1, calcOK)
[gOff0, gPct0] = f_gap(0, len0, calcOK)
[gOff1, gPct1] = f_gap(1, len1, calcOK)
preGap0 = gOff0 >= 0 ? close[math.max(gOff0 + 1, 0)] : na
preGap1 = gOff1 >= 0 ? close[math.max(gOff1 + 1, 0)] : na
hold0 = gOff0 >= 0 and (not reqHold or lo0 >= preGap0)
hold1 = gOff1 >= 0 and (not reqHold or lo1 >= preGap1)
liquid = close >= minPrice and dVolM >= minDVolM and adrPct >= minADR
trigPx = boTrigger == "Close" ? close : high
barX = (high - low) / avgRange20[1]
rvol = volume / avgVol50[1]
clr = high > low ? (close - low) / (high - low) * 100 : 50.0
breakout = liquid and len1 >= minDays and hold1 and trigPx > hi1 and close > open and clr >= boCloseLoc and barX >= bigBarMult and rvol >= boVolMult
inBase = liquid and not breakout and len0 >= minDays and hold0
// Report the base ending today if still inside it, otherwise the base ending yesterday
showPrior = breakout or len0 < minDays
baseDays = showPrior ? len1 : len0
baseHi = showPrior ? hi1 : hi0
baseLo = showPrior ? lo1 : lo0
baseW = (baseHi - baseLo) / baseLo * 100
gOff = showPrior ? gOff1 : gOff0
gPct = showPrior ? gPct1 : gPct0
distHi = (baseHi - close) / close * 100
dispSet = display.data_window + display.pine_screener
plot(breakout ? 1 : 0, "1 Breakout", color = color.lime, display = dispSet)
plot(inBase ? 1 : 0, "2 In Base", color = color.yellow, display = dispSet)
plot(baseDays, "3 Base Days", color = color.orange, display = dispSet)
plot(baseW, "4 Base Width pct", color = color.aqua, display = dispSet)
plot(gOff >= 0 ? gOff : na, "5 Bars Since Gap", color = color.teal, display = dispSet)
plot(gPct, "6 Gap pct", color = color.green, display = dispSet)
plot(distHi, "7 Dist To Base High pct", color = color.white, display = dispSet)
plot(barX, "8 Bar Range x Avg", color = color.purple, display = dispSet)
plot(rvol, "9 RVol 50d", color = color.fuchsia, display = dispSet)
plot(dVolM, "10 Dollar Vol M", color = color.gray, display = dispSet)
alertcondition(breakout, "Gap Base Breakout", "Breakout from a post-gap base")
alertcondition(inBase, "Gap Base Setup", "Stock is basing after a gap up")
plotshape(breakout, "Breakout marker", shape.triangleup, location.belowbar, color.lime, text = "Breakout", textcolor = color.lime, size = size.small)
// On the chart: box around the current base, label on the gap bar
var box bx = na
var label lb = na
if barstate.islast and baseDays >= minDays and gOff >= 0
    box.delete(bx)
    label.delete(lb)
    int st = showPrior ? 1 : 0
    bx := box.new(bar_index - (st + baseDays - 1), baseHi, bar_index - st, baseLo, border_color = color.new(color.yellow, 30), bgcolor = color.new(color.yellow, 90), text = str.tostring(baseDays) + "-day base  |  " + str.tostring(baseW, "#.0") + "% range", text_color = color.new(color.yellow, 10), text_size = size.small, text_halign = text.align_center, text_valign = text.align_top)
    lb := label.new(bar_index - gOff, low[gOff], "GAP +" + str.tostring(gPct, "#.0") + "%", style = label.style_label_up, color = color.new(color.lime, 20), textcolor = color.black, size = size.small)
````
