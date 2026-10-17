# Trend Significance Signals [Jayadev Rana]

- url: https://www.tradingview.com/script/ybNvKgWR-Trend-Significance-Signals-Jayadev-Rana/
- type: indicator
- pine_id: PUB;9f7c8dfd4c984188a727ffa5262fe4b4
- version: 1.0

## Description

OVERVIEW

Trend Significance Signals is a trend-following overlay that prints alternating BUY and SELL signals from a statistical test instead of a price or moving-average cross. On every bar it asks one question: is the average return of the recent bars different enough from zero, relative to how much those returns vary, that it is unlikely to be noise? The answer is a t-statistic, and signals fire when it crosses a threshold.

HOW IT WORKS

1. The script takes the log return of each bar over the Sample Length.
2. It computes the mean of those returns and their standard deviation.
3. The t-statistic is the mean divided by its standard error (standard deviation divided by the square root of the sample size).

A large positive value means the recent returns were consistently positive relative to their own variability. A value near zero means that whatever net movement occurred is well within what random bar-to-bar variation would produce. Because the measure is a ratio, it is independent of price scale and of the instrument's volatility level.

The state is up when the t-statistic is at or above the Signal Threshold, down when it is at or below the negative threshold, and optionally returns to neutral when its absolute value falls under the Neutral Threshold. The gap between the two thresholds acts as hysteresis and prevents flicker.

SIGNALS

- BUY: the state turns up on a closed bar and the last signal was not a BUY.
- SELL: the state turns down on a closed bar and the last signal was not a SELL.

Signals strictly alternate. A pass through neutral does not repeat the previous signal. Signals are evaluated on closed bars and are not changed afterwards.

The baseline (an EMA with the same length as the sample) and the optional bar coloring show the current state. Neutral bars are drawn faded so that periods without statistical evidence of drift are easy to see.

DASHBOARD

State, the current t-statistic, and a plain-language reading of the evidence: Noise (below 1), Weak (1 to 2), Significant (2 to 3) or Strong (3 and above).

SETTINGS

Core: Sample Length, Signal Threshold (t), Neutral Threshold (t), Allow Neutral State, Color Bars by State.
Dashboard: visibility and position.
Style: colors.

DEFAULT SETTINGS

The default values were chosen with a parameter search on BTCUSDT on the 1-hour timeframe. The search treated the signals as a stop-and-reverse system with trading costs, split the history into an earlier and a later segment, and kept only settings that held up in both segments. Other symbols and timeframes will usually need different values; treat the defaults as a starting point and not as a recommendation.

ALERTS

Buy Signal, Sell Signal.

LIMITATIONS

- This is a trend-following tool. A drift has to exist for a while before it becomes statistically visible, so signals arrive after the move has started.
- Market returns are not independent and not normally distributed, so the t-statistic is used here as a ranking measure and not as a formal probability. A value of 2 does not mean a 95 percent chance that the trend continues.
- In sideways markets short bursts can cross the threshold in both directions and produce losing signals.
- A single very large bar inflates the standard deviation and can lower the t-statistic even though price moved strongly.
- Settings tuned on past data can stop working when market behavior changes.

This script is for analysis and education. It does not provide financial advice, and past behavior of any signal does not guarantee future results.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// (c) Jayadev Rana
//@version=6
indicator("Trend Significance Signals [Jayadev Rana]", shorttitle = "TSS", overlay = true)

//------------------------------------------------------------------------------
// Constants
//------------------------------------------------------------------------------
string GRP_CORE  = "Core"
string GRP_DASH  = "Dashboard"
string GRP_STYLE = "Style"

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
int   statLen    = input.int(30, "Sample Length", minval = 10, maxval = 500, group = GRP_CORE, tooltip = "Number of bar-to-bar log returns in the sample. The t-statistic asks whether their average is distinguishable from zero given how much they vary.")
float enterT     = input.float(2.0, "Signal Threshold (t)", minval = 0.5, maxval = 6.0, step = 0.1, group = GRP_CORE, tooltip = "A BUY needs the t-statistic at or above this value, a SELL at or below its negative. Around 2 is the conventional bar for a drift that is unlikely to be noise; higher values give fewer, later signals.")
float exitT      = input.float(0.5, "Neutral Threshold (t)", minval = 0.0, maxval = 3.0, step = 0.1, group = GRP_CORE, tooltip = "When the absolute t-statistic falls below this value the state returns to neutral. Keep it below the signal threshold.")
bool  useNeutral = input.bool(true, "Allow Neutral State", group = GRP_CORE, tooltip = "When off, the state holds its last direction until the opposite threshold is reached.")
bool  colorBars  = input.bool(true, "Color Bars by State", group = GRP_CORE)

bool   showDash = input.bool(true, "Show Dashboard", group = GRP_DASH)
string dashPos  = input.string("Top Right", "Position", options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = GRP_DASH)

color upCol   = input.color(#26a69a, "Up", group = GRP_STYLE)
color dnCol   = input.color(#ef5350, "Down", group = GRP_STYLE)
color neutCol = input.color(#787b86, "Neutral", group = GRP_STYLE)

//------------------------------------------------------------------------------
// Core calculations: t-statistic of the mean log return
//------------------------------------------------------------------------------
float ret   = math.log(close / close[1])
float mu    = ta.sma(ret, statLen)
float sd    = ta.stdev(ret, statLen)
float tStat = sd > 0 ? nz(mu / (sd / math.sqrt(statLen))) : 0.0
float base  = ta.ema(close, statLen)

var int state = 0
if tStat >= enterT
    state := 1
else if tStat <= -enterT
    state := -1
else if useNeutral and math.abs(tStat) < exitT
    state := 0

// BUY and SELL strictly alternate: a pass through neutral does not repeat the last signal.
bool warm = bar_index > statLen * 2
var int lastSig = 0
bool buySig  = warm and barstate.isconfirmed and state == 1 and lastSig != 1
bool sellSig = warm and barstate.isconfirmed and state == -1 and lastSig != -1
if buySig
    lastSig := 1
if sellSig
    lastSig := -1

//------------------------------------------------------------------------------
// Visuals
//------------------------------------------------------------------------------
color stCol = state == 1 ? upCol : state == -1 ? dnCol : neutCol
plot(base, "Baseline", color = stCol, linewidth = 2)
plotshape(buySig, "Buy", shape.labelup, location.belowbar, color = upCol, text = "BUY", textcolor = color.white, size = size.small)
plotshape(sellSig, "Sell", shape.labeldown, location.abovebar, color = dnCol, text = "SELL", textcolor = color.white, size = size.small)
barcolor(colorBars ? color.new(stCol, state == 0 ? 60 : 15) : na, title = "State Bar Color")

plot(tStat, "Trend t-Statistic", display = display.data_window)
plot(state, "State", display = display.data_window)

//------------------------------------------------------------------------------
// Dashboard
//------------------------------------------------------------------------------
f_pos(string p) =>
    switch p
        "Top Right"    => position.top_right
        "Bottom Right" => position.bottom_right
        "Top Left"     => position.top_left
        => position.bottom_left

var table dash = table.new(f_pos(dashPos), 2, 3, bgcolor = color.new(#131722, 15), border_color = color.new(neutCol, 70), border_width = 1)

f_row(int r, string k, string v, color c) =>
    table.cell(dash, 0, r, k, text_color = color.new(color.white, 30), text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, r, v, text_color = c, text_size = size.small, text_halign = text.align_right)

if showDash and barstate.islast
    float aT = math.abs(tStat)
    string strength = aT >= 3 ? "Strong" : aT >= 2 ? "Significant" : aT >= 1 ? "Weak" : "Noise"
    f_row(0, "State", state == 1 ? "Up" : state == -1 ? "Down" : "Neutral", stCol)
    f_row(1, "t-statistic", str.tostring(tStat, "#.00"), tStat >= 0 ? upCol : dnCol)
    f_row(2, "Drift evidence", strength, color.white)

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
alertcondition(buySig, "Buy Signal", "Trend Significance: BUY signal on {{ticker}} ({{interval}})")
alertcondition(sellSig, "Sell Signal", "Trend Significance: SELL signal on {{ticker}} ({{interval}})")
````
