# MVRV Z-Score Bands | Astral Vision 

- url: https://www.tradingview.com/script/GuocxHCz/
- type: indicator
- pine_id: PUB;d093cdbc6c514a1d928c21e89167bd29
- version: 1.0

## Description

[b]MVRV Z-Score Bands | Astral Vision 💠🌠[/b]

Market Value to Realized Value (MVRV) measures the ratio between Bitcoin's market capitalization and its Realized Capitalization, the aggregate value of all coins priced at their last on-chain movement. 
When market cap significantly exceeds realized cap, the network is collectively sitting on large unrealized profits, historically a condition associated with distribution tops. 
When the two converge or invert, the network is near or below its aggregate cost basis, the condition that has defined every major accumulation floor.

This indicator standardizes MVRV using the full historical standard deviation of market cap, producing a Z-Score that makes cycle extremes statistically comparable across all of Bitcoin's history. It then inverts the Z-Score thresholds back through the MVRV formula to project them as dynamic price levels directly onto the price chart, converting abstract statistical levels into concrete price bands that move in real time with Realized Cap.

[b]Calculation ⚙️[/b]

`MVRV Z-Score = (Market Cap − Realized Cap) / StdDev(Market Cap, all-time)`

The standard deviation is computed over the entire available history of market cap using a growing array, ensuring the normalization reflects the full distribution of Bitcoin's market structure at every point in time.

The price bands invert the Z-Score threshold back to price:

`Band Price = BTC Price × ((target_Z × StdDev + Realized Cap) / Market Cap)`

This back-projection means the overbought and oversold bands on the price chart represent exactly the price at which the MVRV Z-Score would equal the user-defined threshold given current on-chain conditions.

[b]Plots 📊[/b]
[list]
[*]MVRV Z-Score line in the indicator panel, colored by active regime
[*]Overbought threshold line (negative color) and oversold threshold line (positive color) in the panel
[*]Dynamic overbought price band projected on the price chart (negative color, linewidth 3)
[*]Dynamic oversold price band projected on the price chart (positive color, linewidth 3)
[*]Background highlight on the price chart when price breaches either band
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]`Oversold Value (Z-Score)`: lower threshold defining the accumulation extreme (default −0.2)
[*]`Overbought Value (Z-Score)`: upper threshold defining the distribution extreme (default 6.0)
[*]`Background Transparency`: opacity of the price chart background highlight when a band is breached (default 50)
[/list]

[b]Colors 🎨[/b]

5 Astral Vision presets + custom override. Default: Paradiso. Positive color applies at oversold extremes; negative color applies at overbought extremes.

[b]Purpose 🎯[/b]

Standard MVRV Z-Score implementations display only the oscillator panel, requiring the trader to mentally translate Z-Score levels back to price, a calculation that changes every day as Realized Cap evolves. Threshold lines in the panel are static and offer no direct price context.

This indicator closes that gap entirely. The Z-Score thresholds are continuously inverted to their equivalent price levels and projected as live bands on the chart, so the distance between current price and each extreme is always immediately readable without any mental conversion. As Realized Cap grows with each market cycle, the bands self-adjust upward, reflecting the structural elevation of Bitcoin's cost basis over time and keeping the signal relevant across every cycle without any manual recalibration.

[b]Disclaimer ⭕️[/b]

It is not financial advice, not an investment recommendation, and not affiliated with any financial institution, research firm, or organization of any kind. All content is provided for educational and informational purposes only. Always conduct your own research before making any financial decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Astral Vision 

//@version=6
indicator(title='MVRV Z-Score Bands | Astral Vision 💠🌠', precision=2, overlay=false)

inv_mvrv_to_price_zscore(float target_mvrv, float mc_realised, float stdev, float btc_close, float mc) =>
    target_mc = target_mvrv * stdev + mc_realised
    btc_close * (target_mc / mc)

group1 = "Z-Score Settings"
group2 = "Astral Colors"

float lval_z   = input.float(-0.2, "Oversold Value (Z-Score)",   step=0.01, group=group1)
float hval_z   = input.float(6.0,  "Overbought Value (Z-Score)", step=0.01, group=group1)
int   transp   = input.int(50,     "Background Transparency",     group=group1)

string theme     = input.string("Paradiso", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group2)
bool   usecustom  = input.bool(false, "Use Custom Colors", group=group2)
color  custom_pos = input.color(color.rgb(255,255,255), "Custom Positive", group=group2)
color  custom_neg = input.color(color.rgb(100,100,100), "Custom Negative", group=group2)

color raw_pos = theme == "Paradiso" ? color.rgb(0,210,255)  :
     theme == "Futura"   ? color.rgb(0,255,180)   :
     theme == "Infinito" ? color.rgb(180,120,255)  :
     theme == "Hermes"   ? color.rgb(255,160,0)    :
     color.rgb(255,0,0)
color raw_neg = theme == "Paradiso" ? color.rgb(0,80,160)   :
     theme == "Futura"   ? color.rgb(180,0,255)    :
     theme == "Infinito" ? color.rgb(255,220,80)   :
     theme == "Hermes"   ? color.rgb(0,180,120)    :
     color.rgb(120,0,0)

color col_pos = usecustom ? custom_pos : raw_pos
color col_neg = usecustom ? custom_neg : raw_neg
color midcolor = color.new(color.white, 60)

float MC          = request.security("GLASSNODE:BTC_MARKETCAP",      "D", close)
float MC_Realised = request.security("COINMETRICS:BTC_MARKETCAPREAL", "D", close)
float btc_close   = request.security("INDEX:BTCUSD",                  "D", close)

var MCap = array.new<float>()
array.push(MCap, MC)
float Stdev = array.stdev(MCap)

float MVRV  = (MC - MC_Realised) / Stdev
float mval  = (lval_z + hval_z) / 2

float price_ob  = inv_mvrv_to_price_zscore(hval_z, MC_Realised, Stdev, btc_close, MC)
float price_os  = inv_mvrv_to_price_zscore(lval_z, MC_Realised, Stdev, btc_close, MC)
float price_mid = inv_mvrv_to_price_zscore(mval,   MC_Realised, Stdev, btc_close, MC)

color col   = MVRV < lval_z ? col_pos : MVRV > hval_z ? col_neg : color.black
color bgcol = btc_close > price_ob ? col_neg : btc_close < price_os ? col_pos : na

plot(MVRV, "MVRV", color=col, linewidth=2)
hline(hval_z, "Overbought", color=color.new(col_neg, 0), linewidth=2, linestyle=hline.style_solid)
hline(lval_z, "Oversold",   color=color.new(col_pos, 0), linewidth=2, linestyle=hline.style_solid)

plot(price_ob,                  "Overbought Band", color=col_neg,  linewidth=3, force_overlay=true)
plot(price_os,                  "Oversold Band",   color=col_pos,  linewidth=3, force_overlay=true)

bgcolor(color.new(bgcol, transp), force_overlay=true)
````
