# Institutional Rolling VWAP

- url: https://www.tradingview.com/script/uCkqbW3U/
- type: indicator
- pine_id: PUB;4a3b28100baf4875985252a086f4b03c
- version: 1.0

## Description

Institutional Rolling VWAP (IRVWAP) combines a time-based Rolling VWAP with liquidity-adjusted volatility bands, ADV analysis, and relative volume metrics to estimate institutional fair value and identify accumulation, distribution, and price extremes.

Unlike a standard VWAP, which only tracks the volume-weighted average price over a rolling window, IRVWAP adapts its volatility bands using liquidity and volume participation metrics inspired by institutional trading behavior.

[b]Institutional Logic
[/b]
Research on market impact suggests that large orders are typically executed over multiple days or weeks rather than in a single session.

IRVWAP incorporates this idea by comparing recent trading activity against long-term average volume.​

[i]When market participation increases:[/i]
Bands contract;
Price deviations become more meaningful;

[i]When participation decreases:[/i]
Bands expand;
Noise is filtered more aggressively.

[i]Inputs[/i]
• Rolling VWAP time window;
• ADV length;
• Flow length;
• Adaptive band toggle;
• Standard deviation multipliers.

[i]Features:[/i]
• Rolling VWAP based on a time-based moving window;
• Volume-weighted standard deviation bands;
• Adaptive volatility bands based on Relative Volume (RVOL);
• Average Daily Volume (ADV) monitoring;
• Institutional Activity Score (Z-Score);
• Designed to identify potential accumulation and distribution zones.

[i]Suggested Uses[/i]
| Condition                        | Interpretation              |
| Above +2σ & RVOL > 1.3 | Bullish continuation        |
| Above +3σ & RVOL > 1.5 | Strong bullish continuation |
| Above +2σ & RVOL < 0.8 | Bearish mean reversion      |
| Below -2σ & RVOL > 1.3 | Bearish continuation        |
| Below -3σ & RVOL > 1.5 | Strong bearish continuation |
| Below -2σ & RVOL < 0.8 | Bullish mean reversion      |
| Between ±1σ            | Fair value zone             |


[b]Code is bugged, fix the scale: right click --> fix the axis[/b]

Based on the papers: 
[i]Slow decay of impact in equity markets - Brokmann et al. (2014)
VWAP Execution as an Optimal Strategy - Takashi Kato (2017)
Mean Variance Optimal: VWAP Trading - McCulloch & Kazakov (2012)[/i]

Ps: I built this code with zero coding knowledge using GPT. If I made mistakes or some things does not make sense please contact me.

## Source Code

````pine
//@version=6
indicator("Institutional Rolling VWAP", "IRVWAP", true)

import PineCoders/ConditionalAverages/2 as pc

//#region ———————————————————— Constants and inputs

// Time constants
int MS_IN_MIN  = 60 * 1000
int MS_IN_HOUR = MS_IN_MIN * 60
int MS_IN_DAY  = MS_IN_HOUR * 24

// Tooltips
string TT_SRC = (
    "The source series for which to calculate the RVWAP."
)

string TT_WIN = (
    "Use a fixed rolling window or automatically scale it based on chart timeframe."
)

string TT_MB = (
    "Minimum number of bars retained inside the rolling window."
)

string TT_STD = (
    "Standard deviation multipliers for the RVWAP bands."
)

//=========================
// Inputs
//=========================

float srcInput = input.source(hlc3, "Source")

//=========================
// Time period
//=========================

string GRP2 = "Time Period"

bool fixedTfInput =
     input.bool(false,
     "Use a fixed time period",
     group = GRP2,
     tooltip = TT_WIN)

int daysInput =
     input.int(1,
     "Days",
     group = GRP2,
     active = fixedTfInput,
     minval = 0) * MS_IN_DAY

int hoursInput =
     input.int(0,
     "Hours",
     group = GRP2,
     active = fixedTfInput,
     minval = 0,
     maxval = 23) * MS_IN_HOUR

int minsInput =
     input.int(0,
     "Minutes",
     group = GRP2,
     active = fixedTfInput,
     minval = 0,
     maxval = 59) * MS_IN_MIN

bool showInfoBoxInput =
     input.bool(true,
     "Show time period",
     group = GRP2)

string infoBoxSizeInput =
     input.string("small",
     "Size",
     group = GRP2,
     options = ["tiny","small","normal","large","huge","auto"])

string infoBoxYPosInput =
     input.string("bottom",
     "Vertical Position",
     group = GRP2,
     options = ["top","middle","bottom"])

string infoBoxXPosInput =
     input.string("right",
     "Horizontal Position",
     group = GRP2,
     options = ["left","center","right"])

color infoBoxColorInput =
     input.color(#787b86,
     "Box Color",
     group = GRP2)

color infoBoxTxtColorInput =
     input.color(#ffffff,
     "Text Color",
     group = GRP2)

//=========================
// Standard Deviation Bands
//=========================

string GRP3 = "Deviation Bands"

float stdevMult1 =
     input.float(1.0,
     "Band 1",
     group = GRP3,
     minval = 0)

float stdevMult2 =
     input.float(2.0,
     "Band 2",
     group = GRP3,
     minval = 0)

float stdevMult3 =
     input.float(3.0,
     "Band 3",
     group = GRP3,
     minval = 0)

color stdevColor1 =
     input.color(color.green,
     "Band 1 Color",
     group = GRP3)

color stdevColor2 =
     input.color(color.yellow,
     "Band 2 Color",
     group = GRP3)

color stdevColor3 =
     input.color(color.red,
     "Band 3 Color",
     group = GRP3)

//=========================
// Minimum Window Size
//=========================

string GRP4 = "Minimum Window"

int minBarsInput =
     input.int(10,
     "Bars",
     group = GRP4,
     tooltip = TT_MB)

//=========================
// Institutional Settings
//=========================

string GRP5 = "Institutional"

int advLength =
     input.int(50,
     "ADV Length",
     group = GRP5,
     minval = 5)

int flowLength =
     input.int(20,
     "Flow Length",
     group = GRP5,
     minval = 5)

bool institutionalBands =
     input.bool(true,
     "Liquidity Adjusted Bands",
     group = GRP5)

bool showInstData =
     input.bool(true,
     "Show Institutional Data",
     group = GRP5)

//#endregion

//#region ———————————————————— Functions

timeStep() =>
    int tfInMs = timeframe.in_seconds() * 1000

    float step = switch
        tfInMs <= MS_IN_MIN       => MS_IN_HOUR
        tfInMs <= MS_IN_MIN * 5   => MS_IN_HOUR * 4
        tfInMs <= MS_IN_HOUR      => MS_IN_DAY
        tfInMs <= MS_IN_HOUR * 4  => MS_IN_DAY * 3
        tfInMs <= MS_IN_HOUR * 12 => MS_IN_DAY * 7
        tfInMs <= MS_IN_DAY       => MS_IN_DAY * 30.4375
        tfInMs <= MS_IN_DAY * 7   => MS_IN_DAY * 90
        =>                           MS_IN_DAY * 365

    int(step)

tfString(series int timeInMs) =>
    int s  = timeInMs / 1000
    int m  = s / 60
    int h  = m / 60

    int tm = math.floor(m % 60)
    int th = math.floor(h % 24)
    int d  = math.floor(h / 24)

    if d == 30 and th == 10 and tm == 30
        "1M"
    else if d == 7 and th == 0 and tm == 0
        "1W"
    else
        string dStr = d > 0 ? str.tostring(d) + "D" : ""
        string hStr = th > 0 ? str.tostring(th) + "H" : ""
        string mStr = tm > 0 ? str.tostring(tm) + "min" : ""

        dStr + (hStr != "" ? " " + hStr : "") + (mStr != "" ? " " + mStr : "")
//#endregion
//#region ———————————————————— Calculations and display

// Stop if no volume exists.
if ta.cum(nz(volume)) == 0 and barstate.islast
    runtime.error("No volume is provided by the data vendor.")

//====================================================
// Rolling window length
//====================================================

int timeInMs =
     fixedTfInput
     ? minsInput + hoursInput + daysInput
     : timeStep()

//====================================================
// Rolling VWAP
//====================================================

float sumSrcVol =
     pc.totalForTimeWhen(
     srcInput * volume,
     timeInMs,
     true,
     minBarsInput)

float sumVol =
     pc.totalForTimeWhen(
     volume,
     timeInMs,
     true,
     minBarsInput)

float sumSrcSrcVol =
     pc.totalForTimeWhen(
     volume * math.pow(srcInput, 2),
     timeInMs,
     true,
     minBarsInput)

float rollingVWAP = sumSrcVol / sumVol

//====================================================
// Variance & Standard Deviation
//====================================================

float variance =
     math.max(
     sumSrcSrcVol / sumVol -
     math.pow(rollingVWAP, 2),
     0.0)

float stDev = ta.stdev(close, 20)

//====================================================
// Institutional Flow Model
//====================================================

// ADV (50-day by default)
float adv =
     ta.sma(volume, advLength)

// Recent institutional flow
float flowVol =
     ta.sma(volume, flowLength)

// Relative flow
float instRVOL =
     adv > 0
     ? flowVol / adv
     : 1.0

// Liquidity-adjusted volatility
float adjStDev =
     institutionalBands
     ? stDev / math.sqrt(math.max(instRVOL, 0.25))
     : stDev

//====================================================
// Institutional Score
//====================================================

float instScore =
     adjStDev > 0
     ? (close - rollingVWAP) / adjStDev
     : na

//====================================================
// Bands
//====================================================

float upperBand1 =
     rollingVWAP + adjStDev * stdevMult1

float lowerBand1 =
     rollingVWAP - adjStDev * stdevMult1

float upperBand2 =
     rollingVWAP + adjStDev * stdevMult2

float lowerBand2 =
     rollingVWAP - adjStDev * stdevMult2

float upperBand3 =
     rollingVWAP + adjStDev * stdevMult3

float lowerBand3 =
     rollingVWAP - adjStDev * stdevMult3

//====================================================
// Plots
//====================================================

plot(
     rollingVWAP,
     "Institutional RVWAP",
     color.orange,
     linewidth = 2)

p1 = plot(
     stdevMult1 != 0 ? upperBand1 : na,
     "Upper Band 1",
     stdevColor1)

p2 = plot(
     stdevMult1 != 0 ? lowerBand1 : na,
     "Lower Band 1",
     stdevColor1)

p3 = plot(
     stdevMult2 != 0 ? upperBand2 : na,
     "Upper Band 2",
     stdevColor2)

p4 = plot(
     stdevMult2 != 0 ? lowerBand2 : na,
     "Lower Band 2",
     stdevColor2)

p5 = plot(
     stdevMult3 != 0 ? upperBand3 : na,
     "Upper Band 3",
     stdevColor3)

p6 = plot(
     stdevMult3 != 0 ? lowerBand3 : na,
     "Lower Band 3",
     stdevColor3)

//====================================================
// Fills
//====================================================

fill(
     p1,
     p2,
     color.new(stdevColor1, 92))

fill(
     p3,
     p4,
     color.new(stdevColor2, 92))

fill(
     p5,
     p6,
     color.new(stdevColor3, 92))

//====================================================
// Information Table
//====================================================

if barstate.islastconfirmedhistory

    table info =
         table.new(
         infoBoxYPosInput + "_" + infoBoxXPosInput,
         1,
         showInstData ? 4 : 1)

    table.cell(
    info,
    0,
    0,
    str.tostring(timeInMs),
    bgcolor = infoBoxColorInput,
    text_color = infoBoxTxtColorInput,
    text_size = infoBoxSizeInput)

    if showInstData

        table.cell(
             info,
             0,
             1,
             "ADV: " + str.tostring(math.round(adv)),
             bgcolor = infoBoxColorInput,
             text_color = infoBoxTxtColorInput,
             text_size = infoBoxSizeInput)

        table.cell(
             info,
             0,
             2,
             "RVOL: " + str.tostring(instRVOL, "#.##"),
             bgcolor = infoBoxColorInput,
             text_color = infoBoxTxtColorInput,
             text_size = infoBoxSizeInput)

        table.cell(
             info,
             0,
             3,
             "Z: " + str.tostring(instScore, "#.##"),
             bgcolor = infoBoxColorInput,
             text_color = infoBoxTxtColorInput,
             text_size = infoBoxSizeInput)

//#endregion
````
