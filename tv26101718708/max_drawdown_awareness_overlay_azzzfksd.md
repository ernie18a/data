# Max Drawdown Awareness Overlay

- url: https://www.tradingview.com/script/azzzFKsd/
- type: indicator
- pine_id: PUB;c74bfa536372422abd789f520b97ae73
- version: 1.0

## Description

Tracks the running peak of price (or any source) over a configurable lookback and shows the current drawdown from that peak plus the running maximum drawdown observed across the window. The chart shades when drawdown crosses your warning and critical thresholds. It does NOT generate buy or sell signals.

What it shows
- Running peak over the lookback
- Current drawdown from peak, in percent
- Maximum drawdown observed, with warning/critical shading

Honest by design
- No buy/sell signals. It is a risk-awareness overlay.
- Non-repainting: every value is a function of confirmed bars.

Open-source and MIT licensed.

Disclaimer: impersonal educational and analytics tool. This is not investment advice, not a personalised recommendation, and carries no performance guarantee. Past results do not predict future results. You are solely responsible for your own trading decisions.

## Source Code

````pine
//@version=6
// Maximum Drawdown Awareness Overlay
// Track the running peak of price (or any provided source) over a
// configurable lookback and show the current drawdown from peak plus
// the running maximum drawdown observed across that window. Drawn as
// an overlay shading the drawdown depth. No signals, non-repainting.
indicator("Max Drawdown Awareness Overlay", overlay = true)
// Disclaimer: impersonal educational/analytics tool, not investment advice, no
// performance guarantees, no buy/sell signals, no auto-execution.

src    = input.source(close, "Source", group = "Inputs")
lookback = input.int(252, "Peak lookback (bars)", minval = 2,
     group = "Inputs")
warnDD = input.float(10.0, "Warning DD %", minval = 1.0, maxval = 50.0,
     step = 0.5, group = "Alerts")
critDD = input.float(20.0, "Critical DD %", minval = 5.0, maxval = 80.0,
     step = 0.5, group = "Alerts")

peak = ta.highest(src, lookback)
ddPct = peak > 0 ? (src - peak) / peak * 100.0 : na

var float maxDDObserved = 0.0
maxDDObserved := math.min(maxDDObserved, na(ddPct) ? 0.0 : ddPct)

ddCol = ddPct <= -critDD ? color.red : ddPct <= -warnDD ? color.orange :
     color.new(color.gray, 50)

plot(peak, title = "Running peak", color = color.new(color.aqua, 0))
bgcolor(ddPct <= -warnDD ? color.new(ddCol, 88) : na)

var table t = table.new(position.top_right, 2, 4, border_width = 1)
if barstate.islast
    table.cell(t, 0, 0, "Drawdown",
         text_color = color.white, bgcolor = color.new(color.black, 0))
    table.cell(t, 1, 0, "", bgcolor = color.new(color.black, 0))
    table.cell(t, 0, 1, "Peak (lookback)")
    table.cell(t, 1, 1, str.tostring(peak, format.mintick))
    table.cell(t, 0, 2, "Current DD")
    table.cell(t, 1, 2, na(ddPct) ? "na" : str.tostring(ddPct, "#.##") + "%",
         text_color = color.white, bgcolor = color.new(ddCol, 30))
    table.cell(t, 0, 3, "Max DD observed")
    table.cell(t, 1, 3, str.tostring(maxDDObserved, "#.##") + "%")
````
