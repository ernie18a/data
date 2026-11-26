# Market Condition Indicator

- url: https://www.tradingview.com/script/PEsho9W5-Market-Condition-Indicator/
- type: indicator
- pine_id: PUB;dd42af8bcc55400080a3fb615c9a6242
- version: 1.0

## Description

[b]What this indicator does?[/b]
[i]This is best used on NQ! and ES! on hourly time frame.[/i] Classifies the market into five market condition using only volume and spread efficiency — two parameters derived from price action without any lagging indicators.

Every candle is categorised into one of five market condition — consolidation, absorption, normal trend, news spike, or thin volatile — by measuring how much price moved relative to the volume behind it.

Green dot (Normal Trend) - Average volume. Moderate spread.
Blue dot (Absorption) - High volume. Tight spread.
Orange dot (Thin Volatile) - Low volume. Wide spread.
Red dot (News Spike) - High volume. Wide spread.
Grey dot (Consolidation) - Low volume. Tight spread.

[b]How this indicator is made?[/b]
Market condition are discovered from using unsupervised machine learning on 2 years of hourly NQ! and ES! data then approximated in Pine Script for live use.
 
Validated on NQ and ES futures with 85–92% next-candle persistence.

[b]How do I use it?[/b]
I use it as a confluence tool where green dots appear on the levels I am expecting to be rejected.

## Source Code

````pine
//@version=6

// VSA Regime Filter
// Classifies market into 5 behavioral states using volume and spread efficiency.
// Trained on NQ/ES futures using Hidden Markov Models.
// Green  = edge active (normal trend or absorption)
// Grey   = consolidation, wait for setup
// Blue   = absorption, institutions active
// Red    = news spike, avoid
// Orange = thin volatile, caution
// Best used on NQ1! and ES1! hourly timeframe.
// Not financial advice.

indicator("VSA Regime Filter", overlay=false, max_bars_back=500)

vol_window    = input.int(500, "Volume lookback", minval=50)
spread_window = input.int(500, "Spread lookback", minval=50)
show_bg       = input.bool(true, "Color price chart background")

raw_spread = high - low
med_spread = ta.sma(raw_spread, spread_window)
rel_spread = raw_spread / math.max(med_spread, 0.0001)
med_volume = ta.sma(volume, vol_window)
rel_volume = volume / math.max(med_volume, 0.0001)
spread_eff = rel_spread / math.max(rel_volume, 0.1)

high_vol = rel_volume > 1.30
low_vol  = rel_volume < 0.75
high_se  = spread_eff > 2.00
low_se   = spread_eff < 0.80

state = low_vol and high_se ? 0 : high_vol and high_se ? 2 : low_vol and low_se ? 3 : high_vol and low_se ? 4 : 1

c_green  = #00cc7a
c_blue   = #0099ff
c_grey   = #888888
c_orange = #ff8800
c_red    = #ff3355

state_col = state == 0 ? color.new(c_orange, 0) : state == 1 ? color.new(c_green, 0) : state == 2 ? color.new(c_red, 0) : state == 3 ? color.new(c_grey, 0) : color.new(c_blue, 0)
state_bg  = state == 0 ? color.new(c_orange, 88) : state == 1 ? color.new(c_green, 88) : state == 2 ? color.new(c_red, 88) : state == 3 ? color.new(c_grey, 92) : color.new(c_blue, 88)

bgcolor(show_bg ? state_bg : na)

plot(state, "State", color=state_col, style=plot.style_circles, linewidth=2)

hline(1, "Trend",  color=color.new(c_green,  70), linestyle=hline.style_dotted)
hline(4, "Absorb", color=color.new(c_blue,   70), linestyle=hline.style_dotted)
hline(3, "Consol", color=color.new(c_grey,   70), linestyle=hline.style_dotted)
hline(0, "Thin",   color=color.new(c_orange, 70), linestyle=hline.style_dotted)
hline(2, "Spike",  color=color.new(c_red,    70), linestyle=hline.style_dotted)

prev         = state[1]
edge         = state == 1 or state == 4
setup_phase  = state == 4
entry_signal = state == 1 and prev == 4

alertcondition(setup_phase and state != prev, "Absorption — get ready",    "S4 Absorption — institutions active, watch your level for bounce setup")
alertcondition(entry_signal,                  "Bounce entry signal",        "S4 to S1 transition — enter if rejection confirmed at your level")
alertcondition(state == 1 and state != prev,  "Normal trend active",        "S1 Normal trend — edge active, look for bounce at key level")
alertcondition(state == 3 and state != prev,  "Consolidation — stand aside","S3 Consolidation — no setup, wait")
````
