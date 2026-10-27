# Bitcoin Power Law Corridor | Astral Vision 

- url: https://www.tradingview.com/script/HZW2XiYJ/
- type: indicator
- pine_id: PUB;b75cbf2f1a544a30887288ab9ac669d0
- version: 1.0

## Description

[b]Bitcoin Power Law Corridor | Astral Vision 🌠💠[/b]

This indicator plots a mathematically derived price corridor based on the power law relationship between Bitcoin's price and the number of days since its genesis. The power law is a well-documented empirical observation in Bitcoin's price history: when both price and time are plotted on logarithmic scales, the relationship between the two approximates a straight line, meaning price grows as a power function of time rather than linearly or exponentially. This produces a structural corridor that expands over time at a decelerating rate, capturing Bitcoin's long-term appreciation while reflecting its diminishing growth rate across cycles.

[b]Calculation ⚙️[/b]

The foundation of the model is the number of days elapsed since July 19, 2010, Bitcoin's reference origin for this model, with a fixed offset of 564 days added to calibrate the day count to the genesis block. Call this value D.

The general form of each line in the corridor is a power law equation expressed in log-log space: the base-10 logarithm of price equals a constant term A plus a slope coefficient B multiplied by the base-10 logarithm of D. In standard notation: log10(price) = A + B × log10(D), which is equivalent to price = 10^(A + B × log10(D)).

The four lines use the following coefficients, each fitted independently to different aspects of Bitcoin's historical price distribution:

Centre line: A = -16.982, B = 5.834. This is the central regression fit through the full price history, representing the median fair value implied by the power law.

Resistance line: A = -13.366, B = 5.029. Fitted to the historical cycle top regions, this line represents the upper boundary of the corridor where Bitcoin has historically found significant selling pressure.

Robust Fit line: A = -17.155, B = 5.799. An alternative regression fit using a method more resistant to outliers, providing a reference closer to the lower half of the price distribution.

Support line: A = -17.432, B = 5.834. Fitted to the historical cycle bottom regions, using the same slope as the centre line but a lower intercept, representing the floor of the corridor where Bitcoin has historically found strong buying interest.

The fill between the Robust Fit and Support lines visually marks the lower corridor zone that has historically corresponded to macro accumulation opportunities.

Because the model is built on day count rather than bar count, the indicator fetches the daily bar index from the reference date using a separate security call, making it produce consistent output regardless of which chart timeframe is active.

[b]Plots 📊[/b]
[list]
[*]Centre line: central power law regression through full price history
[*]Resistance line: upper corridor boundary fitted to historical cycle tops
[*]Robust Fit line: alternative lower regression using outlier-resistant fitting
[*]Support line: lower corridor boundary fitted to historical cycle bottoms
[*]Fill between Robust Fit and Support: lower accumulation zone (toggleable)
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]Plot Line Fill: toggle the fill between Robust Fit and Support lines
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Infinito.

[b]Purpose 🎯[/b]
Standard moving averages and trend channels are anchored to recent price action and reset with each new cycle. The power law corridor is anchored to time itself, meaning its positioning is determined entirely by how old Bitcoin is rather than by recent price behavior. This makes it one of the few tools capable of placing any price level in the context of Bitcoin's full historical trajectory: a price that appears high relative to recent months may still be near the bottom of the long-term corridor, or vice versa. The four-line structure further provides distinct reference levels for fair value, upper resistance, and lower support within a single unified framework.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
//@version=6
indicator("Bitcoin Power Law Corridor | Astral Vision 🌠💠", overlay=true)

group1 = "Settings"
group2 = "Astral Colors"

bool showFill = input.bool(true, "Plot Line Fill?", group=group1)

string theme      = input.string("Infinito", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group2)
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

start  = time == timestamp(2010, 7, 19, 0, 0)
days   = request.security("INDEX:BTCUSD", "D", ta.barssince(start))
offset = 564
d      = days + offset

a  = -16.98212206
b  =   5.83430649
y  = math.pow(10, a + b * math.log10(d))

a2 = -13.36632341
b2 =   5.02927337
y2 = math.pow(10, a2 + b2 * math.log10(d))

a3 = -17.15502654
b3 =   5.79855145
y3 = math.pow(10, a3 + b3 * math.log10(d))

a4 = -17.43212206
b4 =   5.83430649
y4 = math.pow(10, a4 + b4 * math.log10(d))

p1 = plot(y,  "Centre",     color=color.white, linewidth=2, force_overlay=true)
p2 = plot(y2, "Resistance", color=pos_col,                linewidth=3, force_overlay=true)
p3 = plot(y3, "Robust Fit", color=neg_col, linewidth=3, force_overlay=true)
p4 = plot(y4, "Support",    color=neg_col,                linewidth=3, force_overlay=true)

fill(p3, p4, color=showFill ? color.new(neg_col, 50) : na)
````
