# Erhirhi BB% Indicator

- url: https://www.tradingview.com/script/bSQsbjwH-Erhirhi-BB-Indicator/
- type: indicator
- pine_id: PUB;9351d581a03a411a8922d3b773c4ce2c
- version: 2.0

## Description

[image]https://www.tradingview.com/x/l55T2m1H/[/image]Erhirhi BB% Indicator

Overview

Erhirhi BB% Indicator is a multi-factor momentum, volatility, and participation oscillator designed to identify statistically stretched market conditions, trend maturity, accumulation/distribution behavior, and momentum exhaustion.

The indicator combines: Bollinger Band %B, percentile ranking, KDJ momentum structure,
normalized volume participation, and adaptive volatility filtering into a single regime-based analytical framework.

Rather than functioning as a traditional overbought/oversold oscillator, the script attempts to measure: trend quality, participation strength, volatility expansion, and reversal probability across multiple market conditions.

The foundation of the script is Bollinger Band Percent (%B), which measures the position of price relative to its Bollinger Band structure.

Values:
below 0 indicate price trading outside the lower band,
above 1 indicate price trading outside the upper band.

This allows the indicator to evaluate:

volatility expansion,
compression,
momentum acceleration,
and statistically stretched movement.

Unlike traditional oscillators, BB %B adapts dynamically to volatility conditions.

Standard Deviation Zones: The script visualizes multiple statistical expansion regions:

1 Standard Deviation Zone - Represents relatively balanced market behavior and normal volatility participation. This is where 68.2 of normal trading occurs

2 Standard Deviation Zone - Represents stronger directional movement and increasing trend conviction. This is where the normal expansion zones are located.

3 Standard Deviation Zone - Represents statistically stretched conditions where continuation quality may begin deteriorating. Price structure in these zone represent a high likelihood of trend exhaustion.

These zones help identify: trend acceleration, instability, exhaustion, and potential transition phases. Extended occupation of upper zones may indicate euphoric expansion or distribution, while persistent lower-zone behavior may indicate panic, compression, or accumulation.

KDJ Momentum Engine: The script incorporates a smoothed KDJ momentum structure to evaluate: directional pressure, momentum persistence, and reversal probability. KDJ behavior is blended with BB %B and percentile calculations to produce adaptive momentum filtering rather than isolated oscillator signals. This allows the indicator to better distinguish:

genuine expansion, weak continuation, and unstable trend behavior.

Percentile Rank Analysis: The indicator uses Percent Rank and Percentile Nearest Rank calculations to contextualize current market behavior relative to historical conditions.

This helps identify: momentum extremes, volatility compression, and statistically unusual participation. Percentile behavior is particularly useful during: trend maturity, exhaustion phases, and reversal development.

FG Score (BB%-KDJ Normalised Score): The FG Score is the primary composite momentum model within the script. It combines:

BB %B positioning, KDJ momentum, percentile range behavior, and normalized volatility relationships into a single adaptive score intended to measure: trend pressure, participation quality, and market stability. The FG Score acts as the core regime filter throughout the indicator. FG Score Below -0.60 represents deeply compressed or statistically washed-out market conditions. These readings often occur during: panic selling, liquidation behavior,
emotional downside acceleration, or exhaustion-driven volatility expansion and frequently reflects elevated reversal probability, instability, and high emotional participation. When combined with improving momentum structure, recovering percentile behavior, or constructive volume participation, these regions may become high-quality accumulation or recovery environments.
FG Score Above 1.24 represents statistically overheated momentum conditions. These readings typically occur during aggressive bullish expansion, euphoric continuation, volatility acceleration or crowded directional participation. While strong momentum may still persist, conditions above 1.24 often signal increasing fragility, weakening continuation quality,
distribution behavior or elevated exhaustion risk. 

These regions should not automatically be interpreted as reversal signals, but rather as high risk areas where trend sustainability may begin deteriorating.

Volume Normalization: The volume engine is one of the most important confirmation layers in the script. Instead of displaying raw exchange volume, the indicator normalizes volume relative to recent participation and weights it using candle body strength versus total range. This creates a contextual measure of participation quality rather than simple activity. The objective is to distinguish between:

constructive participation, passive continuation, aggressive expansion, weakening momentum,
and exhaustion-driven movement. The histogram colors reflect the relationship between:
momentum structure, percentile positioning, BB %B expansion, and participation quality.

White bar = excessively high volume input

Green Bars = constructive bullish participation. Bulls are stronger than bears. These typically appear when momentum strengthens, KDJ structure improves, and percentile rank confirms bullish continuation. This behavior often signals trend acceptance, accumulation, or healthy directional continuation.

Red bars indicate deteriorating momentum structure or increasing bearish participation. Clusters of red bars may signal distribution, weakening continuation, or growing downside pressure.

Pure red bars represent aggressive bearish participation and downside volatility expansion.
These conditions frequently occur during liquidation phases, strong directional breakdowns,
or emotionally driven selling.

Black/red bars highlight elevated selling pressure during statistically stretched bullish conditions. These bars often appear near upper expansion zones, during weakening continuation, or before larger reversal structures develop. This behavior may reflect 
institutional distribution, profit-taking, or deteriorating trend quality.

Black/yellow bars represent unstable participation conditions. These typically occur when 
momentum diverges from price, continuation quality weakens, or volatility expands without strong directional confirmation. These conditions frequently precede exhaustion, failed continuation, or momentum instability. These are the typical areas to buy when the yellow bars disappear and green bars begin to appear above red; indicating that the bulls are beginning to take charge of the trend.

The script visually highlights several market states:

Red Background Zones = Potential distribution, overextension, trend exhaustion, or unstable bullish continuation.

Blue Background Zones = Momentum transition and directional uncertainty.

Green Background Zones = Potential accumulation, recovery structure, and volatility compression.

These zones are intended to provide market context rather than standalone trade signals.

Intended Usage

This indicator is designed as a market structure framework, volatility regime filter, momentum exhaustion detector, and participation quality model.

It works best when combined with price structure, higher timeframe analysis, and disciplined risk management. The script is not intended to predict exact tops or bottoms, but rather to identify: statistically stretched conditions, trend maturity, volatility instability, and changing participation behavior.

Notes
Best suited for trending or volatility-driven markets.
Higher timeframes generally produce cleaner structure.
No indicator should be used in isolation.
Feedback and improvements are always welcome.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © capableDealer16380

//@version=6
indicator(title="Erhirhi BB% Indicator", shorttitle="Erhirhi BB%", overlay=false)

// Input parameters
percentRankPeriod = input.int(100, title="Percent Rank Period", minval=1)
percentNearRankPeriod = input.int(14, title="Percent Nearest Rank Period", minval=1)

// Calculate Bollinger Bands
basis = ta.sma(close, 127)
dev = 2 * ta.stdev(close, 127)
upper = basis + dev
lower = basis - dev

// Calculate %B
bb_percent = (close - lower) / (upper - lower)
bbpcsma = ta.sma(bb_percent,8)*-1

// Determine which zone the oscillator is in
zone1 = bb_percent >= 0.25 and bb_percent <= 0.75  // 1 Standard Deviation Zone
zone2 = bb_percent >= 0 and bb_percent <= 1        // 2 Standard Deviation Zone
zone3 = bb_percent >= -0.25 and bb_percent <= 1.25 // 3 Standard Deviation Zone

// Color conditions for oscillator
brightGreen = bb_percent < 0
brightRed = bb_percent > 1
oscColor = brightGreen ? color.new(#00FF00, 0) : brightRed ? color.yellow : color.new(#2196F3, 0)

// Replot with dynamic colors
plot(bb_percent, title="BB %B", color=oscColor, linewidth=2)
plot(bb_percent-1, title="BB %B Adjusted", color=oscColor, linewidth=2)
plot(bbpcsma, title="BB %B Adjusted SMA", color=bbpcsma<-1?#FF0000:color.yellow, linewidth=2)

// Percent Rank Calculation
// Calculate the rank of current value within the specified period
percentRankT = ta.percentrank(bb_percent, percentRankPeriod)/100
percentRankB = -percentRankT

// Zone lines
// 1 Standard Deviation Zone (0.25 - 0.75)
line_1sd_lower = hline(0.25, title="1SD Lower", color=color.new(#808080, 70), linestyle=hline.style_dotted)
line_1sd_upper = hline(0.75, title="1SD Upper", color=color.new(#808080, 70), linestyle=hline.style_dotted)
fill(line_1sd_lower, line_1sd_upper, title="1SD Zone Fill", color=color.new(#FFEB3B, 45))

// 2 Standard Deviation Zone (0 - 1)
line_2sd_lower = hline(0, title="2SD Lower", color=color.new(#000000, 0), linestyle=hline.style_solid)
line_2sd_upper = hline(1, title="2SD Upper", color=color.new(#000000, 0), linestyle=hline.style_solid)
fill(line_2sd_lower, line_2sd_upper, title="2SD Zone Fill", color=color.new(#808080, 80))

// 3 Standard Deviation Zone (-0.25 - 1.25)
line_3sd_lower = hline(-0.25, title="3SD Lower", color=color.new(#808080, 50), linestyle=hline.style_dotted)
line_3sd_upper = hline(1.25, title="3SD Upper", color=color.new(#808080, 50), linestyle=hline.style_dotted)
fill(line_3sd_lower, line_3sd_upper, title="3SD Zone Fill", color=color.new(#808080, 70))

// Add horizontal lines at key levels
hline(0, title="Zero Line", color=color.new(#000000, 0), linestyle=hline.style_solid)
hline(1, title="One Line", color=color.new(#000000, 0), linestyle=hline.style_solid)

// KDJ CORE
low_n1  = ta.lowest(low, 127)
high_n1 = ta.highest(high, 127)
rsv = (close - low_n1) / (high_n1 - low_n1)
k = ta.rma(rsv, 3)
d = ta.rma(k,   3)
j = 3 * k - 2 * d
plotcandle(k, d, k, d, color = k>d?color.green:color.red, title = "KDJ Oscillator")

// Calculate percentile_nearest_rank
pnr = bb_percent+bbpcsma
dZoneAbove = ta.percentile_nearest_rank(pnr, percentNearRankPeriod, 10)
dZoneBelow = -dZoneAbove
//
max = ta.highest(127)
min = ta.lowest(127)
percentR = (close - max) / (max - min)
plot(percentR, title="%Range", color=percentR<-0.8?#f70d20:color.blue)
pctNRankplot = plot(dZoneAbove, title = "Percentile Nearest Rank", 
      color = color.fuchsia, style=plot.style_line, linewidth = 2)
pctNRankplot2 = plot(dZoneBelow, title = "Percentile Nearest Rank Inverted", 
      color = color.orange, style=plot.style_line, linewidth = 2)

// Plot Percent Rank
ppocol = bbpcsma>k?#f70d20:color.new(color.white,80)
pctRankTplot = plot(percentRankT, title = "Percentile Rank Top", 
      color = ppocol, style=plot.style_area)
pctRankBplot = plot(percentRankB, title = "Percentile Rank Bottom", 
      color = ppocol, style=plot.style_area)

// Volume Bars - Scaled to fit between 0 and 1
// Calculate normalized volume (0 to 1 range)
float highestVol = ta.highest(volume, 100) // Lookback period for volume normalization
normalizedVolume = volume / highestVol
body = math.abs(close - open)
vol_range = high - low
strength = vol_range > 0 ? body / vol_range : 0
buyVol  = close > open ? normalizedVolume * strength : normalizedVolume * (1 - strength)
sellVol = close < open ? normalizedVolume * strength : normalizedVolume * (1 - strength)

// Ensure volume stays within 0-1 range
normalizedVolume := math.min(normalizedVolume, 1)
norm_len = percentRankPeriod/3
rsi_score = math.min(math.max(k,0),percentRankPeriod) * norm_len                             // k is 0-100
bb_score  = math.min(math.max(bb_percent,0),percentRankPeriod) * norm_len                     // Bollinger %b is 0-100
pp_score = math.min(math.max(percentR,0),percentRankPeriod) * norm_len
fg_score = (math.avg(rsi_score,bb_score,pp_score)-8)/10
//Normalization Filter
volumeSMA = ta.sma(normalizedVolume, 20)
fg_bear = bb_percent-1>dZoneBelow or bb_percent-1>dZoneAbove
fg_bull = fg_score<=0.05 and bb_percent<fg_score and k<volumeSMA and k<d and dZoneAbove<bbpcsma and k<dZoneBelow or
      bb_percent<bbpcsma and fg_score<0.02 and dZoneAbove<bbpcsma and k<dZoneBelow or 
      bbpcsma>fg_score and dZoneAbove<bbpcsma and k<dZoneBelow or 
      fg_score<=0.02 and dZoneAbove<bbpcsma and k<dZoneBelow or 
      bb_percent<dZoneBelow and k<dZoneBelow
filt_vol = fg_score<volumeSMA and percentRankB>-0.25 and 
      percentRankT<fg_score and bb_percent<volumeSMA and 
      dZoneBelow>bb_percent
//
plotchar(percentR>-0.05 or bb_percent-1>fg_score, title ='Bullish Exhaustion', char='🐻️', 
      location=location.top, size=size.tiny)
plotchar(bbpcsma>bb_percent and fg_score<-0.6 or 
      k<dZoneBelow and fg_score<-0.6 or
      fg_score<-0.6, title ='Bearish Exhaustion', char='🔥', 
      location=location.bottom, size=size.tiny)
plot(volumeSMA, title="Volume SMA", color=color.new(#FFA500, 0), linewidth=1, display=display.pane)
FG_PLOT = plot(fg_score, title="BB%-KDJ Normalised Score", color=color.new(color.white, 0), linewidth=1)
// Determine volume bar color based on close vs open
volumeColor = normalizedVolume>=1?color.white:bbpcsma>k and bb_percent<percentRankB and close<open or
      bbpcsma>percentRankT or bbpcsma>fg_score and close<open or
      bb_percent<-0.25 ?color.yellow:
      close >= open and percentRankT>fg_score or k>d and k<bbpcsma and percentRankT>fg_score or
      k>d and percentRankT>k and percentRankT>fg_score?color.new(#00FF00, 30):color.new(#FF0000, 30)
      
// Plot volume bars as columns
plot(normalizedVolume, title="Volume", style=plot.style_columns, 
     color=volumeColor, linewidth=1, editable=true, display=display.pane)
plot(sellVol, title ="Sell Volume", color= bb_percent-1>dZoneAbove?na:
      sellVol>0.75 and bb_percent-1>dZoneAbove or 
      bb_percent<0 or
      bb_percent-1>fg_score or
      bb_percent>1 and percentRankT>k and volumeSMA<0.5 and bb_percent-1>dZoneAbove or
      bb_percent<dZoneBelow or 
      bb_percent>1 and ta.falling(volumeSMA,1) and bb_percent-1>dZoneAbove?#000000:
      na,
      style=plot.style_columns)
//
bgcolor(fg_bear?color.new(#FF0000, 50):fg_bull?color.new(color.blue,50):filt_vol?color.new(#00FF00, 80):na, title = "Peak Reversal Zone - High")
// Add Percent Rank tooltip
if barstate.islast and ta.crossover(bb_percent,bbpcsma)
    label.new(x=bar_index, y=0.05, text="BB% =" + str.tostring(bb_percent) + " and is a good time to buy", 
              color=color.new(#FFFFFF, 80), textcolor=color.black, size=size.small, style=label.style_label_lower_right)
              // Fill between zones for visual reference
fill(line_3sd_lower, line_2sd_lower, title="Below 2SD Fill", color=color.new(#00FF00, 70))
fill(line_2sd_upper, line_3sd_upper, title="Above 2SD Fill", 
      color= percentRankB>percentRankT and k<dZoneBelow?color.blue:
      percentRankB>0?color.rgb(227,292,3,0):
      color.new(#FF0000, 70))
fill(line_3sd_lower, line_3sd_upper, title="Accumulation", color=fg_score<=0.05 and k<volumeSMA and dZoneAbove<bbpcsma?color.new(#00FF00, 30):na)
fill(line_3sd_lower, line_3sd_upper, title="Distribution", color=fg_score>=0.2 and bb_percent-1>fg_score and dZoneAbove>0?color.new(#FF0000, 50):na)
// Alert conditions
bbpc_buy_zone = bb_percent<percentRankB and bbpcsma>fg_score
alertcondition(fg_score>=1.24, title="Sell Alert", message="BB %B is in the key Sell zone")
alertcondition(fg_score<=-0.6, title="BB% Buy Zone", message="BB %B is in the key buy zone")
````
