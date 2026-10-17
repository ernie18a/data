# Stoch RSI Golden Cross | Astral Vision 

- url: https://www.tradingview.com/script/rAoKSDR5/
- type: indicator
- pine_id: PUB;edf92f4decc64628b4d1c9dd53608bb6
- version: 1.0

## Description

[b]Stoch RSI Golden Cross | Astral Vision 🌠💠[/b]

This indicator applies a Stochastic RSI computed on a fixed 5-day timeframe, using deliberately long lookback periods that filter out short-term noise and produce a slowly-turning oscillator oriented toward identifying major cycle inflection points rather than frequent trading signals. Crossovers between the K and D lines are only considered valid when they occur within the oversold or overbought zones, ensuring that signals correspond to genuine momentum reversals from extreme positioning rather than midrange noise crosses.

[b]Calculation ⚙️[/b]

The RSI is computed over 121 periods on the 5-day timeframe. The Stochastic of that RSI is then computed over 144 periods, measuring where the current RSI value sits within its highest-to-lowest range over the past 144 bars. This raw Stochastic is smoothed with a 33-period simple moving average to produce the K line. A second 25-period simple moving average is then applied to K to produce the D signal line.

The use of a 5-day timeframe with these long periods means each bar represents one trading week, and the full K lookback of 144 bars covers approximately 2.75 years of weekly data. This makes the oscillator insensitive to anything shorter than multi-month momentum shifts, functioning as a macro cycle tool rather than a swing trading indicator.

A bullish golden cross signal fires when K crosses above D while both lines are below the oversold threshold (default 10), meaning the crossover occurs from a position of statistically extreme pessimism. A bearish cross signal fires when K crosses below D while both lines are above the overbought threshold (default 80), meaning the crossover occurs from a position of statistically extreme optimism. Crosses that occur in the neutral zone between the two thresholds are ignored entirely.

Each valid signal draws a vertical line with a four-layer glow effect on the price chart, marking the exact bar at which the signal occurred and extending across the full chart height for maximum visibility.

[b]Plots 📊[/b]
[list]
[*]K line in the sub-panel
[*]D signal line in the sub-panel
[*]Oversold threshold line at 10
[*]Overbought threshold line at 80
[*]Glow vertical lines on the price chart at each valid bullish cross
[*]Glow vertical lines on the price chart at each valid bearish cross (toggleable)
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]Show Only Bullish Golden Cross: toggle to hide bearish cross signals and show only bullish ones
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Inferno.

[b]Purpose 🎯[/b]
A standard Stochastic RSI with default parameters (14/14/3/3) generates dozens of signals per year, most of which are noise on a macro timeframe. This implementation uses a 5-day bar combined with extended lookback periods to reduce the signal count to a handful per multi-year cycle, corresponding only to the deepest oversold recoveries and most extreme overbought reversals. The zone filter adds a second condition that eliminates all midrange crosses, further concentrating the signal set on statistically meaningful structural turning points. The result is an indicator designed to fire rarely and only at potentially significant macro inflection points rather than as a continuous trading signal generator.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("Stoch RSI Golden Cross | Astral Vision 🌠💠")

group4 = "Colors"

string theme      = input.string("Inferno", "Color Theme", ["Inferno", "Paradiso", "Futura", "Infinito", "Hermes"], group = group4)
bool   usecustom  = input.bool(false, "Use Custom Colors", group = group4)
color  custom_pos = input.color(color.rgb(255, 255, 255), "Custom Positive", group = group4)
color  custom_neg = input.color(color.rgb(100, 100, 100), "Custom Negative", group = group4)

bool show = input.bool(true, "Show Only Bullish Golden Cross")

color theme_pos = theme == "Paradiso" ? color.rgb(0, 210, 255) : theme == "Futura" ? color.rgb(0, 255, 180) : theme == "Infinito" ? color.rgb(180, 120, 255) : theme == "Hermes" ? color.rgb(255, 160, 0) : color.rgb(255, 0, 0)
color theme_neg = theme == "Paradiso" ? color.rgb(0, 80, 160) : theme == "Futura" ? color.rgb(180, 0, 255) : theme == "Infinito" ? color.rgb(255, 220, 80) : theme == "Hermes" ? color.rgb(0, 180, 120) : color.rgb(120, 0, 0)
color col_bull  = usecustom ? custom_pos : theme_pos
color col_bear  = usecustom ? custom_neg : theme_neg

stoch_rsi() =>
    rsi1 = ta.rsi(close, 121)
    k    = ta.sma(ta.stoch(rsi1, rsi1, rsi1, 144), 33)
    d    = ta.sma(k, 25)
    [k, d]

[k, d] = request.security(syminfo.tickerid, "5D", stoch_rsi())

plot(k, "K", color=col_bull)
plot(d, "D", color=col_bear)

plot(10, "Threshold Oversold",   col_bull)
plot(80, "Threshold Overbought", col_bear)



turned_bull = k > d and k[1] < d[1] and k < 10
turned_bear = k < d and k[1] > d[1] and k > 80

if turned_bull
    line.new(bar_index, high * 1.5, bar_index, low * 0.5, xloc=xloc.bar_index, extend=extend.both, color=color.new(col_bull, 0),  width=3,  force_overlay=true)
    line.new(bar_index, high * 1.5, bar_index, low * 0.5, xloc=xloc.bar_index, extend=extend.both, color=color.new(col_bull, 40), width=6,  force_overlay=true)
    line.new(bar_index, high * 1.5, bar_index, low * 0.5, xloc=xloc.bar_index, extend=extend.both, color=color.new(col_bull, 65), width=12, force_overlay=true)
    line.new(bar_index, high * 1.5, bar_index, low * 0.5, xloc=xloc.bar_index, extend=extend.both, color=color.new(col_bull, 82), width=20, force_overlay=true)

if turned_bear and not show
    line.new(bar_index, high * 1.5, bar_index, low * 0.5, xloc=xloc.bar_index, extend=extend.both, color=color.new(col_bear, 0),  width=3,  force_overlay=true)
    line.new(bar_index, high * 1.5, bar_index, low * 0.5, xloc=xloc.bar_index, extend=extend.both, color=color.new(col_bear, 40), width=6,  force_overlay=true)
    line.new(bar_index, high * 1.5, bar_index, low * 0.5, xloc=xloc.bar_index, extend=extend.both, color=color.new(col_bear, 65), width=12, force_overlay=true)
    line.new(bar_index, high * 1.5, bar_index, low * 0.5, xloc=xloc.bar_index, extend=extend.both, color=color.new(col_bear, 82), width=20, force_overlay=true)
````
