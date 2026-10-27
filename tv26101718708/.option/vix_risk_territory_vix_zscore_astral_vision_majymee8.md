# VIX Risk Territory + VIX Z-Score | Astral Vision 

- url: https://www.tradingview.com/script/MaJymEe8/
- type: indicator
- pine_id: PUB;e9b95ef6720e4e469e12da8ca7058be1
- version: 1.0

## Description

[b]VIX Risk Territory + VIX Z-Score | Astral Vision 🌠💠[/b]

This indicator plots the CBOE Volatility Index on any chart with two analytical modes: a raw VIX view that highlights when the index is in historically elevated territory, and a Z-Score normalized view that measures how statistically extreme the current VIX reading is relative to its own rolling history. The VIX measures the implied volatility of S&P 500 options over the next 30 days and is widely used as a proxy for market fear and risk appetite across all asset classes including Bitcoin, which historically peaks in volatility during the same macro stress events that drive the VIX higher.

[b]Calculation ⚙️[/b]

The VIX is fetched from FRED on a daily timeframe. In Raw VIX mode, the index is plotted directly against a configurable overbought threshold, with a fill highlight when the VIX is above that level. The threshold default of 30 corresponds to the widely referenced boundary between normal market volatility and elevated fear regimes: VIX readings above 30 have historically coincided with financial stress events, equity drawdowns, and Bitcoin corrections.

In Z-Score mode, the VIX is normalized as: Z = (VIX - SMA(VIX, N)) / StDev(VIX, N), where N is a configurable rolling lookback window. This transforms the raw VIX level into a dimensionless measure of how far the current reading sits above or below its own historical mean in units of standard deviations. The Z-Score is more analytically useful than the raw level in two respects. First, the VIX has a secular baseline that shifts over time: a reading of 20 meant different things in 2007 versus 2017 versus 2022. The Z-Score adjusts for this drift by always measuring relative to the recent rolling distribution. Second, the Z-Score allows direct comparison of VIX extremes across different regimes: a +2σ reading is always a statistically rare event regardless of the absolute VIX level at the time.

Configurable overbought and oversold thresholds on the Z-Score identify statistically extreme fear and complacency readings. Elevated positive Z-Scores (VIX spiking far above its recent norm) have historically corresponded to capitulation events and macro bottoms. Negative Z-Scores (VIX compressed far below its norm) have historically corresponded to complacency phases that precede corrections.

[b]Plots 📊[/b]
[list]
[*]Raw VIX line with overbought threshold and fill when above threshold (Raw VIX mode)
[*]Z-Score oscillator with overbought and oversold threshold lines and fill above the upper threshold (Z-Score mode)
[*]Candle coloring or background color on the price chart reflecting current VIX regime, switchable between the two display styles
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]Mode: Raw VIX or Z-Score
[*]OB Threshold (Candle): raw VIX level above which fear territory is signaled
[*]OB Threshold (Z-Score): upper Z-Score extreme level
[*]OS Threshold (Z-Score): lower Z-Score extreme level
[*]Z-Score Length: rolling window for mean and standard deviation normalization
[*]Chart Visualization: switch between candle coloring and background color on the price chart
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override plus a configurable neutral color. Default: Infinito.

[b]Purpose 🎯[/b]
Most crypto-native indicators track on-chain or market structure data without any reference to the macro fear environment. The VIX provides a cross-asset context layer: Bitcoin's largest drawdowns have almost all occurred during periods of elevated macro fear that were visible in the VIX before or during the move. Adding VIX regime context to any Bitcoin chart allows traders to distinguish between Bitcoin-specific corrections and systemic risk-off events, which typically require different responses. The Z-Score mode further improves on the standard practice of using fixed VIX thresholds by adapting the extreme zone definition to the current volatility regime of the VIX itself.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("VIX Risk Territory + VIX Z-Score | Astral Vision 🌠💠", overlay=false, format=format.price)

group1 = "Settings"
group2 = "Astral Colors"

mode     = input.string("Z-Score", "Mode", options=["Raw VIX","Z-Score"], group=group1)
ob_level = input.float(30.0, "OB Threshold (Candle)", group=group1)
zob      = input.float(2.0,  "OB Threshold (Z-Score)", group=group1)
zos      = input.float(-2.0, "OS Threshold (Z-Score)", group=group1)
zlength  = input.int(365,    "Z-Score Length", group=group1)

theme      = input.string("Infinito", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group2)
usecustom  = input.bool(false, "Use Custom Colors", group=group2)
custom_pos = input.color(color.rgb(255,255,255), "Custom Positive", group=group2)
custom_neg = input.color(color.rgb(100,100,100), "Custom Negative", group=group2)
neutral    = input.color(color.black, "Neutral Color", group=group2)

raw_pos = theme == "Inferno" ? color.rgb(255,0,0) : theme == "Paradiso" ? color.rgb(0,210,255) : theme == "Futura" ? color.rgb(0,255,180) : theme == "Infinito" ? color.rgb(180,120,255) : color.rgb(255,160,0)
raw_neg = theme == "Inferno" ? color.rgb(120,0,0) : theme == "Paradiso" ? color.rgb(0,80,160)  : theme == "Futura" ? color.rgb(180,0,255)  : theme == "Infinito" ? color.rgb(255,220,80)  : color.rgb(0,180,120)

col_pos = usecustom ? custom_pos : raw_pos
col_neg = usecustom ? custom_neg : raw_neg

vixC = request.security("FRED:VIXCLS", "1D", close)

zscore = (vixC - ta.sma(vixC, zlength)) / ta.stdev(vixC, zlength)

col     = vixC > ob_level ? col_pos : neutral
zColor  = zscore > zob ? col_pos : zscore < zos ? col_neg : neutral

plot1 = plot(mode == "Raw VIX"  ? vixC   : na, "VIX",       col)
plot2 = plot(mode == "Raw VIX"  ? ob_level : na, "OB",      raw_neg)
fill(plot1, plot2, vixC >= ob_level ? raw_pos : na)

zplot   = plot(mode == "Z-Score" ? zscore : na, "VIX Z-Score", zColor, linewidth=2)
zobLine = plot(mode == "Z-Score" ? zob    : na, "OB",   color=color.new(col_pos, 50), linewidth=1)
zosLine = plot(mode == "Z-Score" ? zos    : na, "OS",   color=color.new(col_neg, 50), linewidth=1)
fill(zplot, zobLine, zscore > zob ? col_pos : na)

viz = input.string("Candle", "Chart Visualization", options=["Candle","Background"], group=group1)

bgCol  = mode == "Raw VIX"  ? (vixC > ob_level ? col_pos : na) : na
bgZCol = mode == "Z-Score"  ? (zscore > zob ? col_pos : zscore < zos ? col_neg : na) : na

bgcolor(viz == "Background" ? nz(bgCol, bgZCol) : na, force_overlay=true)

plotcandle(open, high, low, close, title="Price",   color=col,    wickcolor=col,    bordercolor=col,    force_overlay=true, display=mode == "Raw VIX"  and viz == "Candle" ? display.all : display.none)
plotcandle(open, high, low, close, title="Price Z", color=zColor, wickcolor=zColor, bordercolor=zColor, force_overlay=true, display=mode == "Z-Score"  and viz == "Candle" ? display.all : display.none)
````
