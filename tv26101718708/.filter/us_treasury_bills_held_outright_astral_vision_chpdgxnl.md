# U.S. Treasury Bills Held Outright | Astral Vision 

- url: https://www.tradingview.com/script/ChpDGXnl/
- type: indicator
- pine_id: PUB;71f1ca167bc246d5bf5a9e1bb6b0fa1e
- version: 1.0

## Description

[b]U.S. Treasury Bills Held Outright | Astral Vision 🌠💠[/b]

Treasury Bills Held Outright represents the stock of short-term US government securities held directly on the Federal Reserve's balance sheet. 
Expansions of this holding reflect active Fed intervention in the short-term debt market, injecting liquidity into the financial system. Contractions signal withdrawal. Because T-Bills are the shortest-duration instrument the Fed holds, changes in this series respond faster than broader balance sheet metrics and can serve as an early read on the direction of monetary conditions.

This indicator plots the weekly WSHOBL series from FRED and colors it by whether its 10-bar rate of change is above a configurable growth threshold, distinguishing active expansion phases from stagnation or contraction. The same regime is projected onto the price chart as a background highlight.

[b]Calculation ⚙️[/b]

`ROC = (val − val[10]) / |val[10]|`

The signal colors positive when ROC exceeds the configured threshold, indicating active T-Bill accumulation by the Fed. Below the threshold the signal turns negative. Data is pulled weekly from FRED on confirmed closed bars.

[b]Plots 📊[/b]
[list]
[*]Weekly WSHOBL line in the indicator panel, colored by ROC regime
[*]Background highlight on the price chart during active expansion phases (toggleable transparency)
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]`Overlay BG Transparency`: opacity of the price chart background highlight during expansion
[/list]

[b]Colors 🎨[/b]

5 Astral Vision presets + custom override. Default: Paradiso. Positive color activates when the rate of change exceeds the growth threshold; negative color applies otherwise.

[b]Purpose 🎯[/b]

Most Fed balance sheet indicators track total assets or reserves, series that move slowly and are dominated by longer-duration holdings like MBS and Treasuries. 
T-Bills Held Outright is a narrower and more reactive slice of the balance sheet that captures short-term liquidity operations directly. 
When the Fed is actively accumulating T-Bills, it is injecting short-duration liquidity into the system, a condition that has historically been favorable for risk assets including Bitcoin. 
This indicator makes that dynamic visible on any chart without requiring manual cross-referencing of FRED data.

[b]Disclaimer ⭕️[/b]

It is not financial advice, not an investment recommendation, and not affiliated with any financial institution, research firm, or organization of any kind. All content is provided for educational and informational purposes only. Always conduct your own research before making any financial decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision 

//@version=6
indicator("U.S. Treasury Bills Held Outright | Astral Vision 🌠💠", overlay=false, max_bars_back=500)

group1 = "Settings"
group2 = "Visualization"
group3 = "Astral Colors"

string theme      = input.string("Paradiso", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group3)
bool   usecustom  = input.bool(false, "Use Custom Colors", group=group3)
color  custom_pos = input.color(color.green, "Custom Positive", group=group3)
color  custom_neg  = input.color(color.red,   "Custom Negative", group=group3)

int   bg_transp   = input.int(60, "Overlay BG Transparency", minval=0, maxval=100, group=group2)

color pos_col = usecustom ? custom_pos : theme == "Inferno" ? color.rgb(255,0,0) : theme == "Paradiso" ? color.rgb(0,210,255) : theme == "Futura" ? color.rgb(0,255,180) : theme == "Infinito" ? color.rgb(180,120,255) : color.rgb(255,160,0)
color neg_col = usecustom ? custom_neg : theme == "Inferno" ? color.rgb(120,0,0) : theme == "Paradiso" ? color.rgb(0,80,160) : theme == "Futura" ? color.rgb(180,0,255) : theme == "Infinito" ? color.rgb(255,220,80) : color.rgb(0,180,120)
float val = request.security("FRED:WSHOBL", "1W", close[1], lookahead=barmerge.lookahead_on)

float roc = (val - val[10]) / math.abs(val[10])

color zone_col = roc > 0.005 ? pos_col : neg_col

plot(val, "WSHOBL", color=zone_col, linewidth=2, style=plot.style_line)

bgcolor(roc > 0.005 ? color.new(pos_col, bg_transp) : na, force_overlay=true)
````
