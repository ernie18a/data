<!-- tradingview-pine-id: PUB;218b2019b41944cf9255da25dd83c5d5 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Elsea Heat Band & MAs

Source: https://www.tradingview.com/script/OMS37iDE-Elsea-Heat-Band-MAs/

## Description

Elsea Heat Band & MAs is a moving-average utility: it draws the medium-term band (also known as the Bull Market Support Band / Bear Market Resistance Band, credit: Benjamin Cowen) alongside a set of conventional daily and weekly moving averages, on a single overlay with independent toggles for each group.

There is nothing novel in the calculations here. Every line is a standard SMA or EMA at a conventional length, and the cross detection is the standard 50/200 golden and death cross. The script exists to put a specific combination on one chart with consistent colouring, per-group toggles and end-of-series labels, rather than to introduce a new method. It is open-source for that reason.

WHAT IT DRAWS

[*]Heat Band — a 140-day SMA and a 147-day EMA (roughly twenty and twenty-one weeks of trading days) with a shaded fill between them. Using both an SMA and an EMA at slightly offset lengths gives a band rather than a line, blending flat-window and recency weighting.
[*]Daily MAs — 50-day and 200-day SMAs, with star and skull markers where the 50 crosses the 200 in either direction.
[*]Weekly MAs — 50, 100, 200 and 300-week SMAs, computed as 350, 700, 1400 and 2100 daily bars, coloured on a single blue ramp so the ordering is readable at a glance.
[*]Labels — at the right edge of the series, each visible average is labelled with its length.

HOW TO USE IT
Each of the three groups toggles independently, so the script can serve as a Heat Band overlay alone, a conventional MA set alone, or all of it together.

The band is medium-term structure: price above it has been above its twenty-week baseline, price below it has not. The weekly averages are long-horizon reference levels, most useful on instruments with many years of history. The 50/200 cross is included because it is widely watched, not because it is predictive — it is a lagging construction by definition, and the markers are there to locate the event on the chart rather than to endorse it.

LIMITATIONS

[*]All averages are computed from daily closes regardless of chart timeframe, so they are stepped on intraday charts and update once per day.
[*]Weekly averages are approximated as multiples of seven daily bars, not calendar weeks. On instruments that do not trade seven days a week the effective calendar period is longer than the label suggests. This is intended for consistency with the daily series, but the labels are approximate.
[*]The longest average needs roughly 2100 daily bars before it produces a value. On instruments with less history it will not plot.
[*]Moving averages lag by construction, and the longer ones lag substantially. Nothing here identifies a turn as it happens.
[*]The 50/200 cross is a widely known lagging signal with no edge implied by its inclusion.
[*]This is an analysis tool. It does not predict direction and produces no buy or sell recommendations.

---

## Source Code

````pine
//@version=6
// Elsea Heat Band and Daily & Weekly MAs with Alerts


indicator('Elsea Heat Band & MAs', overlay=true)

// Inputs
showHeat     = input.bool(true, "Show Heat Band")
showDaily    = input.bool(true, "Show Daily MAs")
showWeekly   = input.bool(true, "Show Weekly MAs")
showMaLabels = input.bool(true, "Show MA Labels")

// MAs
sma20w  = request.security(syminfo.tickerid, "D", ta.sma(close, 20 * 7))
ema21w  = request.security(syminfo.tickerid, "D", ta.ema(close, 21 * 7))
sma50d  = request.security(syminfo.tickerid, "D", ta.sma(close, 50))
sma200d = request.security(syminfo.tickerid, "D", ta.sma(close, 200))
sma50w  = request.security(syminfo.tickerid, "D", ta.sma(close, 50 * 7))
sma100w = request.security(syminfo.tickerid, "D", ta.sma(close, 100 * 7))
sma200w = request.security(syminfo.tickerid, "D", ta.sma(close, 200 * 7))
sma300w = request.security(syminfo.tickerid, "D", ta.sma(close, 300 * 7))

// Golden/Death Cross Detection
goldenCross = ta.crossover(sma50d, sma200d)
deathCross  = ta.crossunder(sma50d, sma200d)

// Plots
sma20wPlot  = plot(showHeat   ? sma20w  : na, color=color.new(#00ff37, 50), title="20w SMA",  linewidth=1)
ema21wPlot  = plot(showHeat   ? ema21w  : na, color=color.new(#00ff37, 50), title="21w EMA",  linewidth=1)
fill(sma20wPlot, ema21wPlot, color=color.new(#00ff37, 85), fillgaps=true)
sma50dPlot  = plot(showDaily  ? sma50d  : na, color=color.new(#ffff00, 10), title="50d SMA",  linewidth=1)
sma200dPlot = plot(showDaily  ? sma200d : na, color=color.new(#ff9900, 10), title="200d SMA", linewidth=1)
sma50wPlot  = plot(showWeekly ? sma50w  : na, color=color.new(#c9daf8, 10), title="50w SMA",  linewidth=1)
sma100wPlot = plot(showWeekly ? sma100w : na, color=color.new(#a4c2f4, 10), title="100w SMA", linewidth=1)
sma200wPlot = plot(showWeekly ? sma200w : na, color=color.new(#6d9eeb, 10), title="200w SMA", linewidth=1)
sma300wPlot = plot(showWeekly ? sma300w : na, color=color.new(#3c78d8, 10), title="300w SMA", linewidth=1)

plotchar(showDaily and goldenCross, title="Golden Cross", location=location.belowbar,
     char="⭐", color=color.new(#00ff37, 0), size=size.tiny, display=display.all-display.status_line)
plotchar(showDaily and deathCross, title="Death Cross", location=location.abovebar,
     char="💀", color=color.new(#ff3b3b, 0), size=size.tiny, display=display.all-display.status_line)

var label lab20w  = na
var label lab21w  = na
var label lab50d  = na
var label lab200d = na
var label lab50w  = na
var label lab100w = na
var label lab200w = na
var label lab300w = na

mkLab(label lb, bool show, float y, string txt, color c) =>
    label r = lb
    if na(r)
        r := label.new(bar_index, y, "", style=label.style_label_left, color=color.new(color.black, 100), size=size.small)
    label.set_xy(r, bar_index + 3, y)
    label.set_text(r, show ? txt : "")
    label.set_textcolor(r, c)
    r

if barstate.islast and showMaLabels
    lab20w  := mkLab(lab20w,  showHeat,   sma20w,  "20w",  color.new(#00ff37, 30))
    lab21w  := mkLab(lab21w,  showHeat,   ema21w,  "21w",  color.new(#00ff37, 30))
    lab50d  := mkLab(lab50d,  showDaily,  sma50d,  "50d",  #ffff00)
    lab200d := mkLab(lab200d, showDaily,  sma200d, "200d", #ff9900)
    lab50w  := mkLab(lab50w,  showWeekly, sma50w,  "50w",  #c9daf8)
    lab100w := mkLab(lab100w, showWeekly, sma100w, "100w", #a4c2f4)
    lab200w := mkLab(lab200w, showWeekly, sma200w, "200w", #6d9eeb)
    lab300w := mkLab(lab300w, showWeekly, sma300w, "300w", #3c78d8)

// Alerts
alertcondition(goldenCross, title="Golden Cross", message="Golden Cross detected — 50d SMA crossed above 200d SMA")
alertcondition(deathCross, title="Death Cross", message="Death Cross detected — 50d SMA crossed below 200d SMA")
````
