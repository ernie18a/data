# Options Flow Narrative [ZOM]

- url: https://www.tradingview.com/script/y94SICNe-Options-Flow-Narrative-ZOM/
- type: indicator
- pine_id: PUB;599231c090fc4002b6dc1a2983eb7884
- version: 1.0

## Description

[b]Options Flow Narrative[/b] is an educational framework designed to [b]approximate[/b] how dealers, hedging flows, volatility positioning, and sentiment alignment can influence price behavior.

[b]The script combines three concepts into one simplified narrative model:[/b]

- Delta sentiment proxy (buying vs selling pressure)
- Gamma-style support/resistance zones around VWAP
- VIX alignment for broader volatility confirmation

The goal is not to replicate institutional options data directly, because TradingView does not provide full real-time options chain exposure, dealer positioning, dark pool inventory, or true market-wide gamma calculations. Instead, this indicator uses price, volume, VWAP, volatility expansion, and VIX behavior to build a probabilistic narrative framework that traders can interpret visually.

[b]Bullish conditions occur when:[/b]

- buying pressure strengthens,
- volatility softens,
- and price reclaims projected support zones.

[b]Bearish conditions occur when:[/b]

- selling pressure strengthens,
- volatility expands,
- and price rejects projected resistance zones.

The shaded zones represent volatility-adjusted “[i]gamma wall[/i]” approximations around VWAP. These are not true institutional gamma levels and should not be interpreted as exact dealer positioning. They are modeled zones intended to help visualize potential reaction areas where liquidity, hedging behavior, or mean reversion may occur.

[b]Narrative labels appear only when multiple conditions align:[/b]

- Delta sentiment
- VIX momentum
- Price interaction with projected zones

[b]Narrative Ribbon (The "Bias"):[/b]

At the very bottom of your chart, there is now a continuous Bias Ribbon. This allows you to see the "Delta + Vanna" sentiment at a glance without cluttering your price action.
- Green: Full Bullish Alignment (Delta Bull + VIX Falling).
- Red: Full Bearish Alignment (Delta Bear + VIX Rising).
- Blue: Neutral/Divergent.

Because TradingView has limited access to real options flow, dealer inventory, and exchange-level positioning data, this script should be viewed as an approximation tool rather than a direct representation of institutional order flow.

[b]This indicator is best used alongside:[/b]

- market structure,
- higher timeframe context,
- liquidity analysis,
- VWAP,
- volume profile,
- or broader volatility studies.

No indicator can fully predict market direction, and all signals can fail during strong trend expansion, news events, or abnormal volatility conditions.

[b]Built primarily for educational and analytical purposes.[/b]
[b]Not financial advice.[/b]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Options Flow Narrative [ZOM]", shorttitle="Option Nar", overlay=true, max_labels_count=500, max_lines_count=500)

// --- Instructions & Methodology ---
// 1. Delta Sentiment: A Cumulative Volume Delta (CVD) proxy to find the 'Narrative Bias'.
// 2. Gamma Levels: Hedging 'Walls' calculated via Volatility-Adjusted Standard Deviations.
// 3. Vanna Alignment: Correlates the Narrative Bias with VIX momentum.
// 4. Trade Signals: Explicit entry/target markers when these three Greeks align at a level.

string GRP_DEX = "Delta Exposure (Sentiment Bias)"
string GRP_GEX = "Gamma Exposure (Hedging Levels)"
string GRP_VEX = "Vanna (VIX Confirmation)"

color BULL_COLOR = #089981
color BEAR_COLOR = #f23645
color NEUT_COLOR = #5b9cf6

// "Delta" Inputs
int deltaLookback = input.int(50, "Bias Lookback", minval=1, group=GRP_DEX, tooltip="Lookback for the Cumulative Volume Sentiment.")
// "Gamma" Inputs
float gammaMult = input.float(2.0, "Gamma Wall Width (StdDev)", minval=0.5, step=0.1, group=GRP_GEX)
int gammaLookback = input.int(20, "Gamma Lookback", minval=5, group=GRP_GEX)
// "Vanna" Inputs
string vixTicker = input.symbol("CBOE:VIX", "VIX Symbol", group=GRP_VEX)
bool showSignals = input.bool(true, "Show Narrative Signals", group=GRP_VEX)

float buyVol = volume * (close > open ? 1 : 0.5)
float sellVol = volume * (close < open ? 1 : 0.5)
float deltaRatio = ta.ema(buyVol, deltaLookback) / ta.ema(sellVol, deltaLookback)

bool isBullishBias = deltaRatio > 1.0
bool isBearishBias = deltaRatio < 1.0

float vwapValue = ta.vwap
float stdev = ta.stdev(close, gammaLookback)

float callWallHigh = vwapValue + (stdev * gammaMult * 1.5)
float callWallLow  = vwapValue + (stdev * gammaMult)
float putWallHigh  = vwapValue - (stdev * gammaMult)
float putWallLow   = vwapValue - (stdev * gammaMult * 1.5)

float vix = request.security(vixTicker, timeframe.period, close)
bool vixFalling = vix < ta.ema(vix, 10)
bool vixRising  = vix > ta.ema(vix, 10)

bool narrativeBull = isBullishBias and vixFalling
bool narrativeBear = isBearishBias and vixRising

p_call_top = plot(callWallHigh, "Call Wall High", color.new(BULL_COLOR, 100))
p_call_bot = plot(callWallLow, "Call Wall Low", color.new(BULL_COLOR, 100))
fill(p_call_top, p_call_bot, color.new(BULL_COLOR, 80), "Call Wall Zone")

p_put_top = plot(putWallHigh, "Put Wall High", color.new(BEAR_COLOR, 100))
p_put_bot = plot(putWallLow, "Put Wall Low", color.new(BEAR_COLOR, 100))
fill(p_put_top, p_put_bot, color.new(BEAR_COLOR, 80), "Put Wall Zone")

plot(vwapValue, "Neutral Level (VWAP)", color.new(NEUT_COLOR, 50), 1, plot.style_linebr)

plotshape(true, "Bias Ribbon", shape.square, location.bottom, narrativeBull ? BULL_COLOR : (narrativeBear ? BEAR_COLOR : NEUT_COLOR), size=size.tiny)

bool bullEntry = narrativeBull and ta.crossover(close, putWallHigh) 
bool bearEntry = narrativeBear and ta.crossunder(close, callWallLow) 

if bullEntry and showSignals
    label.new(bar_index, low, "BULLISH NARRATIVE\nEntry: Gamma Support", color=BULL_COLOR, textcolor=color.white, style=label.style_label_up, size=size.small)

if bearEntry and showSignals
    label.new(bar_index, high, "BEARISH NARRATIVE\nEntry: Gamma Resistance", color=BEAR_COLOR, textcolor=color.white, style=label.style_label_down, size=size.small)

bool hitCallWall = ta.crossover(close, callWallLow) and narrativeBull
bool hitPutWall  = ta.crossunder(close, putWallHigh) and narrativeBear

if hitCallWall and not bullEntry and showSignals
    label.new(bar_index, high, "TARGET REACHED\nCall Wall Wall", color=NEUT_COLOR, textcolor=color.white, style=label.style_label_down, size=size.tiny)

if hitPutWall and not bearEntry and showSignals
    label.new(bar_index, low, "TARGET REACHED\nPut Wall Wall", color=NEUT_COLOR, textcolor=color.white, style=label.style_label_up, size=size.tiny)

alertcondition(bullEntry, "Bullish Options Flow Entry", "Delta and Vanna aligned at Gamma Support")
alertcondition(bearEntry, "Bearish Options Flow Entry", "Delta and Vanna aligned at Gamma Resistance")
````
