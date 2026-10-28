# CVDD Bands | Astral Vision 

- url: https://www.tradingview.com/script/eSbmhWNW/
- type: indicator
- pine_id: PUB;61099716188243d380aaaa0c405a1fd4
- version: 1.0

## Description

[b]CVDD Bands | Astral Vision 🌠💠
[/b]
Coin Value Days Destroyed (CVDD) measures the aggregate economic weight of Bitcoin supply movements by combining the Realized Capitalization (the sum of all coins valued at their last on-chain movement price) with the cumulative destruction of coin-days through spending activity, smoothed over a 500-bar window and normalized against the fixed 21M supply ceiling. The result is a per-coin floor valuation that reflects how much long-term economic conviction the network has collectively expressed.

This indicator builds a three-band structure anchored to that baseline:
[list]
[*]The mid band plots CVDD itself, historically coinciding with the deepest capitulation floors across every major Bitcoin cycle. 
[*]The bottom band shifts CVDD downward by a configurable factor, defining a sub-floor extreme that has marked generational buying opportunities. 
[*]The top band scales CVDD upward via a time-decaying power-law extension that compresses as Bitcoin matures, tracing the upper boundary of speculative excess against the network's fundamental valuation anchor.
[/list]

[b]Calculation ⚙️
[/b]
`CVDD = (Realized Cap − 500-bar SMA of Total Transfer Volume) / 21,000,000`

The Realized Cap prices each coin at its last on-chain move; the smoothed transfer volume captures the cumulative economic weight of coin-day destruction. Dividing by the supply ceiling converts the result into a per-coin floor valuation.

`CVDD Bottom = CVDD × shift_factor`: a simple downward scalar applied to CVDD, defining the sub-floor capitulation extreme.

`CVDD Top = CVDD × 10^(a × time + b)`: a time-decaying power-law multiplier applied to CVDD. The exponent shrinks as Unix time increases, causing the top band to compress relative to CVDD as Bitcoin matures. Both the slope and intercept of the exponent are user-adjustable.


[b]Plots 📊
[/b]- CVDD Mid band on the price chart with triple-layer glow (widths 8/4/2, transparency 60/30/0)
- CVDD Bottom band on the price chart with triple-layer glow
- CVDD Top band on the price chart with triple-layer glow in negative color
- Fill between Mid and Bottom bands
- Background highlight when price closes above the Top band (distribution warning)
- Background highlight when price closes below the Mid band (capitulation zone)

[b]Inputs 🎛️
[/b]
- `Top Extension Slope Factor (%)` scales the time-decay rate of the power-law top extension (default 100)
- `Top Extension Intercept Factor (%)` scales the vertical offset of the power-law top extension (default 100)
- `Bottom Shift (%)` scales CVDD downward to define the sub-floor extreme (default 120, interpreted as ×1.2 inversion)

[b]Colors 🎨
[/b]
5 Astral Vision presets + custom override. Default: Inferno. Positive color applies to Mid and Bottom bands; negative color applies to the Top band.

[b]Purpose 🎯
[/b]
Standard CVDD implementations plot a single line with no envelope, leaving traders without context for how far price is from both the accumulation floor and the distribution ceiling within the same framework. 
This indicator converts CVDD into a full valuation band system: the bottom anchors the deepest possible accumulation zones, the mid marks the historical cycle floor, and the top provides a time-aware, power-law-adjusted resistance ceiling that self-compresses as Bitcoin's market matures. 
The three-band structure lets you read where price sits within the full cycle valuation range at a glance, without any external oscillator.

[b]Disclaimer ⭕️
[/b]
It is not financial advice, not an investment recommendation, and not affiliated with any financial institution, research firm, or organization of any kind. All content is provided for educational and informational purposes only. Always conduct your own research before making any financial decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision 

//@version=6
indicator("CVDD Bands | Astral Vision 🌠💠", overlay = true)

GRP_CVDD = "CVDD Settings"
GRP_STY  = "Style"

slope_factor     = input.int(100, "Top Extension Slope Factor (%)",     group=GRP_CVDD)
intercept_factor = input.int(100, "Top Extension Intercept Factor (%)", group=GRP_CVDD)
shift            = input.int(120, "Bottom Shift (%)",                   group=GRP_CVDD)

theme      = input.string("Inferno", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=GRP_STY)
usecustom  = input.bool(false, "Custom Colors", group=GRP_STY)
custom_pos = input.color(color.rgb(255,0,0),   "Positive", inline="col", group=GRP_STY)
custom_neg = input.color(color.rgb(120,0,0),   "Negative", inline="col", group=GRP_STY)

color pos_col = usecustom ? custom_pos :
     theme == "Inferno"  ? color.rgb(255,0,0) :
     theme == "Paradiso" ? color.rgb(0,210,255) :
     theme == "Futura"   ? color.rgb(0,255,180) :
     theme == "Infinito" ? color.rgb(180,120,255) :
     color.rgb(255,160,0)

color neg_col = usecustom ? custom_neg :
     theme == "Inferno"  ? color.rgb(120,0,0) :
     theme == "Paradiso" ? color.rgb(0,80,160) :
     theme == "Futura"   ? color.rgb(180,0,255) :
     theme == "Infinito" ? color.rgb(255,220,80) :
     color.rgb(0,180,120)

start = timestamp(2011, 08, 06)

MCR      = request.security("COINMETRICS:BTC_MARKETCAPREAL", "D", close)
TV_expr  = ta.sma(close, 500)
TV       = request.security("GLASSNODE:BTC_TOTALVOLUME", "D", TV_expr)
btc_high = request.security("INDEX:BTCUSD", "D", high)
btc_low  = request.security("INDEX:BTCUSD", "D", low)

CVDD        = (MCR - TV) / 22000000
CVDD_bottom = CVDD * shift / 100

top_factor  = math.pow(10, -8.1775e-13 * slope_factor / 100 * time + 1.965805965 * intercept_factor / 100)
CVDD_top    = CVDD * top_factor

valid = not na(CVDD) and time > start

plot(valid ? CVDD_bottom : na, "CVDD Bottom Glow 1", color.new(pos_col, 60), 8)
plot(valid ? CVDD_bottom : na, "CVDD Bottom Glow 2", color.new(pos_col, 30), 4)
plot2 = plot(valid ? CVDD_bottom : na, "CVDD Bottom",        pos_col, 2)

plot(valid ? CVDD : na, "CVDD Mid Glow 1", color.new(pos_col, 60), 8)
plot(valid ? CVDD : na, "CVDD Mid Glow 2", color.new(pos_col, 30), 4)
plot1 = plot(valid ? CVDD : na, "CVDD Mid",        pos_col, 2)

plot(valid ? CVDD_top : na, "CVDD Top Glow 1", color.new(neg_col, 60), 8)
plot(valid ? CVDD_top : na, "CVDD Top Glow 2", color.new(neg_col, 30), 4)
plot(valid ? CVDD_top : na, "CVDD Top",        neg_col, 2)

bgcolor(valid and btc_high >= CVDD_top    ? color.new(neg_col, 50) : na, title="Above Top")
bgcolor(valid and btc_low  <= CVDD ? color.new(pos_col, 50) : na, title="Below Bottom")

fill(plot1,plot2, color.new(pos_col, 50))
````
