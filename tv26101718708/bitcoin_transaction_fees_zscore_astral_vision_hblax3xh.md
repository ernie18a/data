# Bitcoin Transaction Fees Z-Score | Astral Vision 

- url: https://www.tradingview.com/script/hBlaX3XH/
- type: indicator
- pine_id: PUB;d39833f09dd7445e8c424968957cb7c4
- version: 1.0

## Description

[b]Bitcoin Transaction Fees Z-Score | Astral Vision 🌠💠[/b]

Transaction fees are one of the most direct expressions of genuine on-chain demand pressure. When users compete to get transactions confirmed, fees spike and historically those spikes have aligned tightly with late-stage cycle euphoria. Conversely, fee compression marks periods of network inactivity that have repeatedly preceded major accumulation opportunities.

This indicator standardizes total Bitcoin transaction fees (USD) in log space over a configurable lookback window, producing a Z-Score that exposes statistically extreme deviations from the long-term fee baseline, both to the upside and the downside.

[b]Calculation ⚙️[/b]

`Z = (log(SMA(Total Fees USD, smooth)) − SMA(log_fees, length)) / StdDev(log_fees, length)`

Total on-chain fees in USD are first smoothed by a short SMA to reduce daily noise, then transformed into log space before standardization. The Z-Score measures how many standard deviations the current fee level sits above or below its long-term mean, compressing Bitcoin's exponential fee growth into a cycle-comparable signal.

[b]Plots 📊[/b]
[list]
[*]Z-Score line, colored by active regime (positive, negative, or neutral)
[*]Extreme High threshold line (default 2.5)
[*]Low threshold line (default −1.35)
[*]Fill between Z-Score and Extreme High threshold when breached (distribution zone)
[*]Fill between Z-Score and Low threshold when breached (accumulation zone)
[*]Candle coloring on the price chart by active regime
[*]Background highlight on the price chart when either threshold is active
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]`Z-Score Length (days)`: lookback window for mean and standard deviation calculation (default 730)
[*]`Smooth Input (days)` : SMA applied to raw fee data before log transformation (default 7)
[*]`Extreme High Threshold` : Z-Score level marking fee-driven distribution zones (default 2.5)
[*]`Low Threshold` : Z-Score level marking fee-driven accumulation zones (default −1.35)
[/list]

[b]Colors 🎨[/b]

5 Astral Vision presets + custom override. Default: Futura. Positive color activates below the Low threshold; negative color activates above the Extreme High threshold; neutral applies between thresholds.

[b]Purpose 🎯[/b]

Raw fee charts are dominated by Bitcoin's exponential price growth, making cycle-to-cycle comparison visually meaningless. Standard fee indicators plot absolute values with no statistical context, offering no signal on whether current fees are elevated or compressed relative to historical norms.

This indicator solves both problems: log transformation removes the exponential trend, and Z-Score standardization makes every cycle directly comparable regardless of Bitcoin's price magnitude. The result is a clean, threshold-driven signal that identifies when fee demand has reached statistically extreme levels, either as a distribution warning or an accumulation opportunity, directly overlaid on the price chart through candle and background coloring.

[b]Disclaimer ⭕️[/b]

It is not financial advice, not an investment recommendation, and not affiliated with any financial institution, research firm, or organization of any kind. All content is provided for educational and informational purposes only. Always conduct your own research before making any financial decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("Bitcoin Transaction Fees Z-Score | Astral Vision 🌠💠")

group1 = "Settings"
group2 = "Astral Colors"

int   length     = input.int(730, "Z-Score Length (days)", minval=30, group=group1)
int   src_length = input.int(7,   "Smooth Input (days)",   minval=1,  group=group1)
float thresh_hi2 = input.float(2.5,  "Extreme High Threshold", step=0.05, group=group1)
float thresh_lo1 = input.float(-1.35,"Low Threshold",          step=0.05, group=group1)

string theme      = input.string("Futura", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group2)
bool   usecustom  = input.bool(false, "Custom Colors", group=group2)
color  custom_pos = input.color(color.rgb(255,0,0),  "Custom Positive", group=group2)
color  custom_neg = input.color(color.rgb(120,0,0),  "Custom Negative", group=group2)

color pos_col = usecustom ? custom_pos :
     theme == "Inferno"  ? color.rgb(255,0,0)    :
     theme == "Paradiso" ? color.rgb(0,210,255)  :
     theme == "Futura"   ? color.rgb(0,255,180)  :
     theme == "Infinito" ? color.rgb(180,120,255) :
     color.rgb(255,160,0)

color neg_col = usecustom ? custom_neg :
     theme == "Inferno"  ? color.rgb(120,0,0)    :
     theme == "Paradiso" ? color.rgb(0,80,160)   :
     theme == "Futura"   ? color.rgb(180,0,255)  :
     theme == "Infinito" ? color.rgb(255,220,80)  :
     color.rgb(0,180,120)

color neu_col = color.rgb(120,120,120)

float fees        = request.security("GLASSNODE:BTC_TOTALTXFEESUSD", "D", close)
float fees_smooth = ta.sma(fees, src_length)

float log_fees = math.log(fees_smooth)
float mean     = ta.sma(log_fees, length)
float std      = ta.stdev(log_fees, length)
float z        = (log_fees - mean) / std

color z_col = z > thresh_hi2 ? neg_col :
              z < thresh_lo1 ? pos_col :
              color.black

color bgcol = z > thresh_hi2 ? color.new(neg_col, 50) :
              z < thresh_lo1  ? color.new(pos_col, 50) : na

p1 = plot(thresh_hi2, "Extreme High", color=neg_col,                   linewidth=1)
p2 = plot(thresh_lo1, "Low",          color=pos_col,                   linewidth=1)

zplot = plot(z, "Z-Score", color=z_col, linewidth=2)

bgcolor(bgcol, force_overlay=true)

fill(zplot, p1 , z > thresh_hi2 ? color.new(neg_col, 40) : na)
fill(zplot, p2 , z < thresh_lo1 ? color.new(pos_col, 40) : na)
plotcandle(open,high,low,close, "Plotc", z_col, z_col, bordercolor = z_col, force_overlay = true)
````
