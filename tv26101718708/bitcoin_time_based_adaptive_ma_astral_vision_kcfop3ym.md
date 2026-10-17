# Bitcoin Time Based Adaptive MA | Astral Vision 

- url: https://www.tradingview.com/script/KCfop3Ym/
- type: indicator
- pine_id: PUB;334da85b1d854ea2bc79bac7537e53d5
- version: 1.0

## Description

[b]Bitcoin Time Based Adaptive MA | Astral Vision 🌠💠[/b]

Work inspired by @moneyordebt.

This indicator computes a weighted moving average on Bitcoin's low price in log space, using a lookback period that automatically expands as Bitcoin matures over time. The core principle is that Bitcoin's market cycles lengthen with each passing halving epoch: the relevant trend window for a 2-year-old asset is structurally shorter than the appropriate window for a 10-year-old asset with deep institutional participation. A fixed MA length either overreacts to noise in early history or becomes too slow in recent years.

[b]Calculation ⚙️[/b]

The first step is computing how many years have elapsed since July 1, 2010, the reference origin of Bitcoin's tradeable price history. This elapsed time drives a piecewise linear schedule that determines the appropriate lookback in weeks:

From 0 to 2 years elapsed: the lookback is fixed at 25 weeks. From 2 to 4 years: it scales linearly from 25 to 50 weeks. From 4 to 8 years: it scales linearly from 50 to 100 weeks. From 8 to 16 years: it scales linearly from 100 to 200 weeks. Beyond 16 years: the lookback is capped at 200 weeks.

This schedule approximates Bitcoin's empirically observed cycle elongation across halving epochs without requiring any manual input. The resulting week count is then converted into bars by dividing by the number of seconds per bar and multiplying by the number of seconds per week, making the indicator fully timeframe-agnostic: it produces the correct lookback on daily, weekly, or any other chart resolution automatically.

The MA itself is computed as a weighted moving average (WMA, which weights recent bars more heavily than older ones) applied to the natural logarithm of the low price rather than to raw price. Working in log space is critical for an asset like Bitcoin that has moved across six orders of magnitude: in log space, a move from $100 to $200 and a move from $30,000 to $60,000 are treated as equivalent proportional moves, which is the correct treatment for long-term structural analysis. Once the WMA is computed in log space, the result is exponentiated back to price scale using the natural exponential function.

A scaling factor of 0.65 is then applied to the exponentiated result, positioning the base line near the historical cycle lows of each major Bitcoin correction. A second line is derived by multiplying the base line by 7.5, which approximates the historically observed ratio between Bitcoin's macro support level and its cycle top extremes.

[b]Plots 📊[/b]
[list]
[*]Base adaptive MA: log-space WMA of lows scaled to historical cycle low support, with layered glow effect
[*]Top reference line: base MA multiplied by 7.5, approximating historical cycle top territory, with glow effect
[*]Background color when price closes below the base MA: potential macro support zone
[*]Background color when price closes above the top reference line: potential macro distribution zone
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]No length or period inputs: the adaptive schedule is fully automatic and time-driven
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Futura.

[b]Purpose 🎯[/b]
Standard moving averages use a fixed length that the user must manually adjust as market conditions evolve. This indicator automates that adaptation based on a time schedule calibrated to Bitcoin's historical cycle structure, removing parameter tuning entirely.  The dual-line structure with a support base and a top reference provides a complete macro range framework within a single indicator, functional across Bitcoin's entire available price history from 2010 to present.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("Bitcoin Time Based Adaptive MA | Astral Vision 🌠💠", overlay=true)

string group1 = "Astral Colors"

string theme      = input.string("Futura", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group1)
bool   usecustom  = input.bool(false, "Use Custom Colors", group=group1)
color  custom_pos = input.color(color.white, "Custom Positive", group=group1)
color  custom_neg = input.color(color.gray,  "Custom Negative", group=group1)

color pos_col = usecustom ? custom_pos :
     theme == "Inferno"  ? color.rgb(255,0,0)    :
     theme == "Paradiso" ? color.rgb(0,210,255)   :
     theme == "Futura"   ? color.rgb(0,255,180)   :
     theme == "Infinito" ? color.rgb(180,120,255) :
     color.rgb(255,160,0)

color neg_col = usecustom ? custom_neg :
     theme == "Inferno"  ? color.rgb(120,0,0)   :
     theme == "Paradiso" ? color.rgb(0,80,160)   :
     theme == "Futura"   ? color.rgb(180,0,255)  :
     theme == "Infinito" ? color.rgb(255,220,80) :
     color.rgb(0,180,120)

int startTime = timestamp("2010-07-01")
float yearsElapsed = (time - startTime) / (365.25 * 24.0 * 3600.0 * 1000.0)

float adaptiveWeeks = 0.0
if yearsElapsed <= 2
    adaptiveWeeks := 25.0
else if yearsElapsed <= 4
    adaptiveWeeks := 25.0 + (yearsElapsed - 2.0) / 2.0 * 25.0
else if yearsElapsed <= 8
    adaptiveWeeks := 50.0 + (yearsElapsed - 4.0) / 4.0 * 50.0
else if yearsElapsed <= 16
    adaptiveWeeks := 100.0 + (yearsElapsed - 8.0) / 8.0 * 100.0
else
    adaptiveWeeks := 200.0

float secsPerBar  = timeframe.in_seconds()
float secsPerWeek = 7.0 * 24.0 * 3600.0
int   adaptiveLen = math.max(2, math.min(math.round(adaptiveWeeks * secsPerWeek / secsPerBar), 5000))

float logMA      = bar_index >= adaptiveLen ? ta.wma(math.log(low), adaptiveLen) : na
float adaptiveMA = math.exp(logMA) * 0.65
float topMA      = adaptiveMA * 7.5

plot(topMA,      color=color.new(neg_col, 70), linewidth=5)
plot(topMA,      color=color.new(neg_col,  0), linewidth=2)
plot(adaptiveMA, color=color.new(pos_col, 85), linewidth=8)
plot(adaptiveMA, color=color.new(pos_col, 60), linewidth=5)
plot(adaptiveMA, color=color.new(pos_col,  0), linewidth=2)

bgcolor(close < adaptiveMA ? color.new(pos_col, 50) : na)
bgcolor(close > topMA      ? color.new(neg_col, 50) : na)
````
