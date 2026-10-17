# SPMA Supertrend | NAL

- url: https://www.tradingview.com/script/QPHhmXJm-SPMA-Supertrend-NAL/
- type: indicator
- pine_id: PUB;8459a600a03549ea9274f0da012b530f
- version: 1.0

## Description

SPMA Supertrend is a trend-following framework that replaces the conventional Supertrend center with a [b]Shock Percentile Moving Average (SPMA)[/b].

Unlike a traditional moving average that updates on every bar, SPMA only accepts a new baseline value when the current one-bar return ranks sufficiently high relative to its recent distribution. When that percentile condition is not met, the baseline remains unchanged.

The result is an [b]event-driven trend structure[/b] designed to respond selectively to meaningful upside price displacement rather than continuously following every movement in price.

[b]1. Shock Percentile Moving Average[/b]

The SPMA begins by calculating the current one-bar price change and ranking that observation against its recent history:

[pine]Ret = close - close[1]
Per = ta.percentrank(Ret, percentrank_lookback)
Gate = Per > percentile_gate[/pine]

The percentile gate determines whether the underlying EMA is permitted to update.

[pine]MA := na(MA[1]) ? emaValue : Gate ? emaValue : MA[1][/pine]

When the gate is satisfied, SPMA adopts the current EMA value. Otherwise, it preserves its previous level.

This creates a baseline whose evolution is determined by [b]relative return significance[/b] rather than the passage of time alone.

Higher percentile settings make the model increasingly selective, while lower settings allow the baseline to update more frequently.

[b]2. SPMA Supertrend[/b]

The SPMA is then used as the center of a conventional trailing-band Supertrend architecture.

[pine]UpperBand = SPMA + ATRFactor * ATR
LowerBand = SPMA - ATRFactor * ATR[/pine]

ATR defines the volatility distance around the event-driven baseline, while the trailing-band logic converts the structure into persistent bullish and bearish regimes.

[list=1]
[*][b]Bullish[/b] — price has cleared the upper trailing structure and the lower band becomes active.
[*][b]Bearish[/b] — price has cleared the lower trailing structure and the upper band becomes active.
[/list]

This produces a hybrid model combining [b]percentile-ranked price displacement, selective baseline updating, volatility normalization, and Supertrend state persistence[/b].

[b]Visuals & Interpretation[/b]

Only the active Supertrend boundary is displayed.

A gradient extends between the hidden SPMA baseline and the active Supertrend level, making the relationship between the event-driven baseline and current trend boundary visible without adding unnecessary chart clutter.

Candles are also colored according to the active regime.

Three visual presets are included:

[list=1]
[*]Standard
[*]Nordic
[*]Simple
[/list]

[b]Practical Application[/b]

SPMA Supertrend is designed for identifying directional market structure while reducing the influence of routine price movement on the underlying trend baseline.

The key distinction from a standard Supertrend is simple:

[i]The volatility bands still respond continuously, but the underlying baseline only evolves when price movement is sufficiently significant relative to its recent distribution.[/i]

Users can independently control the baseline horizon, percentile-ranking window, percentile gate, ATR horizon, and Supertrend volatility multiplier.

[b]Automated Alerts[/b]

Built-in alerts are included for both directional transitions:

[list=1]
[*][b]Bullish Flip[/b] — triggers when SPMA Supertrend changes from bearish to bullish.
[*][b]Bearish Flip[/b] — triggers when SPMA Supertrend changes from bullish to bearish.
[/list]

For closed-bar confirmation, configure TradingView alerts to trigger [b]Once Per Bar Close[/b].

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NordicAlphaLab

//@version=6
indicator("SPMA Supertrend | NAL", "SPMA Supertrend | NAL", overlay = true)

//                                     ███╗   ██╗ █████╗ ██╗
//                                     ████╗  ██║██╔══██╗██║
//                                     ██╔██╗ ██║███████║██║
//                                     ██║╚██╗██║██╔══██║██║
//                                     ██║ ╚████║██║  ██║███████╗
//                                     ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝

// ══════════════════════════════════════ ◈ Inputs ◈ ══════════════════════════════════════

string groupSPMA = "SPMA Settings"
string groupSupertrend = "Supertrend"
string groupVisuals = "Visuals"

int Length = input.int(5, "Baseline Length", minval = 1, group = groupSPMA)
int Lookback = input.int(30, "Percentrank Lookback", minval = 2, group = groupSPMA, tooltip = "Number of historical bars used to rank the current returns. Lower values react faster but produce a less stable rank. Higher values compare the current shock against a broader historical sample.")
int GateInp = input.int(50, "% Gate", minval = 0, maxval = 99, group = groupSPMA, tooltip = "Minimum percentile rank required for the SPMA to update. A value of 50 updates on above-median positive price shocks, while higher values restrict updates to increasingly unusual shocks. When the gate is not met, the SPMA holds its previous value.")

int ATRLength = input.int(10, "ATR Length", minval = 1, group = groupSupertrend)
float ATRFactor = input.float(2.0, "ATR Factor", minval = 0.1, step = 0.1, group = groupSupertrend, tooltip = "ATR multiplier used to position the Supertrend bands around the SPMA.")

string col_mode = input.string("Standard", "Color Mode", options = ["Standard", "Nordic", "Simple"], group = groupVisuals)

[col_up, col_dn, col_nu] = switch col_mode
    "Standard" => [color.rgb(0, 255, 200), color.rgb(32, 94, 144), color.gray]
    "Nordic"   => [color.rgb(0, 96, 175), color.rgb(150, 154, 169), color.gray]
    "Simple"   => [color.lime, color.red, color.gray]

// ══════════════════════════════════════ ◈ SPMA ◈ ══════════════════════════════════════

f_SPMA(simple int percentrank_lookback, simple int ma_length, simple int percentile_gate) =>
    float Ret = close - close[1]
    float Per = ta.percentrank(Ret, percentrank_lookback)
    bool Gate = Per > percentile_gate
    float emaValue = ta.ema(close, ma_length)

    var float MA = na
    MA := na(MA[1]) ? emaValue : Gate ? emaValue : MA[1]
    MA

float SPMA = f_SPMA(Lookback, Length, GateInp)

// ══════════════════════════════════════ ◈ SPMA Supertrend ◈ ══════════════════════════════════════

// Standard Supertrend trailing-band architecture,
// except SPMA replaces the conventional hl2 center.

float ATR = ta.atr(ATRLength)

float UpperBand = SPMA + ATRFactor * ATR
float LowerBand = SPMA - ATRFactor * ATR

float PreviousUpperBand = nz(UpperBand[1], UpperBand)
float PreviousLowerBand = nz(LowerBand[1], LowerBand)

UpperBand := UpperBand < PreviousUpperBand or close[1] > PreviousUpperBand ? UpperBand : PreviousUpperBand
LowerBand := LowerBand > PreviousLowerBand or close[1] < PreviousLowerBand ? LowerBand : PreviousLowerBand

int Direction = na
float Supertrend = na
float PreviousSupertrend = Supertrend[1]

if na(ATR[1])
    Direction := 1
else if PreviousSupertrend == PreviousUpperBand
    Direction := close > UpperBand ? -1 : 1
else
    Direction := close < LowerBand ? 1 : -1

Supertrend := Direction == -1 ? LowerBand : UpperBand

bool Bullish = Direction == -1
bool Bearish = Direction == 1

bool BullishFlip = Bullish and not Bullish[1]
bool BearishFlip = Bearish and not Bearish[1]

color TrendColor = Bullish ? col_up : Bearish ? col_dn : col_nu

// ══════════════════════════════════════ ◈ Plots ◈ ══════════════════════════════════════

SPMAPlot = plot(SPMA, "Shock Percentile Moving Average", color = color.new(TrendColor, 45), linewidth = 1, display = display.none)

BullishPlot = plot(Bullish ? Supertrend : na, "Bullish SPMA Supertrend", color = col_up, linewidth = 2, style = plot.style_linebr)
BearishPlot = plot(Bearish ? Supertrend : na, "Bearish SPMA Supertrend", color = col_dn, linewidth = 2, style = plot.style_linebr)

// ══════════════════════════════════════ ◈ Gradient Fill ◈ ══════════════════════════════════════


fill(SPMAPlot, BullishPlot, Bullish ? SPMA : na, Bullish ? Supertrend : na, color.new(col_up, 100), color.new(col_up, 68))
fill(SPMAPlot, BearishPlot, Bearish ? Supertrend : na, Bearish ? SPMA : na, color.new(col_dn, 68), color.new(col_dn, 100))

barcolor(TrendColor)

plotcandle(open, high, low, close, "Candles", color = TrendColor, wickcolor = TrendColor, bordercolor = TrendColor, display = display.pane, force_overlay = true)

// ══════════════════════════════════════ ◈ Alerts ◈ ══════════════════════════════════════

alertcondition(BullishFlip, "SPMA Supertrend Bullish", "SPMA Supertrend changed to bullish on {{ticker}}.")
alertcondition(BearishFlip, "SPMA Supertrend Bearish", "SPMA Supertrend changed to bearish on {{ticker}}.")
````
