<!-- tradingview-pine-id: PUB;301d6292a06244c6bd5b4b3ec7e4d611 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Dr.Oat SEPA Command Center V2

Source: https://www.tradingview.com/script/hRdXRir3/

## Description

# Dr.Oat SEPA Command Center V2

**Developed by Dr.Kor Endo**

Dr.Oat SEPA Command Center V2 is a technical analysis and stock-screening tool inspired by the principles of SEPA (Specific Entry Point Analysis), Stage 2 trend analysis, and volatility contraction concepts.

The indicator is designed to help traders identify stocks that are showing strong trend characteristics, constructive price contraction, proximity to a potential pivot, and breakout confirmation with volume expansion.

## Main Features

### 1. Stage 2 Trend Template

The script evaluates seven technical conditions using:

* SMA 50
* SMA 150
* SMA 200
* SMA 200 rising trend
* Distance above the 52-week low
* Proximity to the 52-week high
* Price position relative to SMA 50

A stock passing all seven conditions is considered to have passed the Stage 2 Trend Template.

### 2. Quantitative VCP Engine

The VCP Score is a quantitative proxy designed to identify characteristics associated with volatility contraction.

The score evaluates:

* Base depth
* Short-term range contraction
* Medium-term range contraction
* ATR contraction
* Volume dry-up
* Right-side price tightness

The VCP Score ranges from **0 to 100**.

Higher scores indicate a tighter and potentially more constructive setup.

### 3. Pivot Detection

The indicator automatically calculates an active pivot using the highest price of the previous configurable lookback period.

The current bar is excluded from the pivot calculation.

The dashboard also displays the percentage distance between the current price and the active pivot.

### 4. Setup Classification

The system classifies each stock into five possible states:

**BREAKOUT**
Trend Template passed, VCP conditions satisfied, price has moved above the pivot within the permitted breakout zone, and relative volume confirms the move.

**READY**
Trend Template passed, VCP conditions satisfied, and price is approaching the pivot from below.

**DEVELOPING**
The stock is in a valid Stage 2 trend, but the setup has not yet reached READY or BREAKOUT conditions.

**EXTENDED**
The stock has moved too far above the active pivot and may no longer offer an attractive entry point according to the configured maximum chase distance.

**SKIP**
The stock does not currently meet the required Stage 2 trend conditions.

Signal Codes:

* `0 = SKIP`
* `1 = DEVELOPING`
* `2 = READY`
* `3 = BREAKOUT`
* `4 = EXTENDED`

### 5. SEPA Score

The indicator calculates a composite **SEPA Score from 0–100** using:

* Trend Template — 30 points
* VCP characteristics — 30 points
* Volume characteristics — 15 points
* Pivot positioning — 15 points
* Breakout confirmation — 10 points

The score is intended as a ranking and screening tool rather than a standalone buy or sell signal.

### 6. Volume Analysis

The system evaluates both:

**Volume Dry-Up**

and

**Relative Volume (RVOL)**

Low relative volume during consolidation can help identify contraction, while expanding relative volume is used as confirmation during potential breakouts.

### 7. Daily RSI

Daily RSI is displayed for additional momentum context.

**Important:** RSI is informational only.

RSI is **not included in the Stage 2 Trend Template** and is **not included in the SEPA Score**.

### 8. Visual Dashboard

The on-chart dashboard provides a compact overview of:

* Current Status
* SEPA Score
* Trend Template Score
* VCP Score
* Daily RSI
* Active Pivot
* Distance to Pivot
* RVOL
* Base Depth
* Volume Dry-Up
* Range Contraction
* ATR Contraction
* Distance from 52-Week High
* Suggested Action

### 9. TradingView Pine Screener Support

The script exposes several numerical outputs that can be used as columns or filters within TradingView Pine Screener, including:

* SEPA Score
* Trend Template Score
* VCP Score
* Daily RSI
* Pivot Distance %
* RVOL
* Signal Code
* Base Depth %
* Volume10 / Volume50
* Trend Template PASS

For screening purposes, the **Daily timeframe (1D)** is recommended.

## Suggested Interpretation

Rather than treating the indicator as an automatic trading system, it can be used as a workflow:

**Market Universe → Stage 2 Trend → VCP → READY → BREAKOUT → Risk Management**

Stocks classified as READY may deserve closer monitoring around their pivot.

BREAKOUT indicates that the configured breakout and volume conditions have been satisfied.

EXTENDED is intended to warn against chasing a stock that has already moved significantly beyond its pivot.

## Important Notes

This indicator uses quantitative approximations of technical concepts such as VCP and SEPA.

Pattern recognition in financial markets is inherently subjective, and no numerical model can perfectly reproduce discretionary chart reading.

The tool should therefore be used as a **screening, ranking, and decision-support system**, not as a replacement for independent analysis.

Users are encouraged to evaluate:

* Overall market conditions
* Liquidity
* Fundamental quality
* Earnings growth
* Relative strength
* Risk/reward
* Position sizing
* Stop-loss strategy

before making any trading decision.

## Disclaimer

This script is provided for educational, research, and technical-analysis purposes only.

It does not constitute investment advice, financial advice, or a recommendation to buy or sell any security.

Past performance and historical technical patterns do not guarantee future results.

Users are solely responsible for their own trading and investment decisions.

---

**Developed by Dr.Kor Endo**

*Quantitative SEPA / Stage 2 / VCP Screening & Decision Support*

---

## Source Code

````pine
//@version=6
indicator(
     "Dr.Oat SEPA Command Center V2",
     shorttitle="OAT SEPA V2",
     overlay=true,
     max_labels_count=100,
     max_lines_count=100
)

// ============================================================================
// DR.OAT SEPA COMMAND CENTER V2
// ============================================================================
//
// Functions:
// 1. Stage 2 Trend Template Scanner
// 2. VCP Quantitative Proxy
// 3. Pivot / Breakout Detection
// 4. Volume Dry-Up / Expansion
// 5. Daily RSI Information
// 6. SEPA Score
// 7. Beautiful Chart Dashboard
// 8. Pine Screener Outputs
//
// Recommended Screener Timeframe = 1D
//
// RSI:
// - Display only
// - NOT used for Trend Template
// - NOT used for SEPA Score
//
// SIGNAL CODE:
// 0 = SKIP
// 1 = DEVELOPING
// 2 = READY
// 3 = BREAKOUT
// 4 = EXTENDED
//
// ============================================================================


// ============================================================================
// INPUT GROUP — TREND TEMPLATE
// ============================================================================

groupTrend = "① Stage 2 Trend Template"

sma50Len = input.int(
     50,
     "SMA 50",
     minval=1,
     group=groupTrend
)

sma150Len = input.int(
     150,
     "SMA 150",
     minval=1,
     group=groupTrend
)

sma200Len = input.int(
     200,
     "SMA 200",
     minval=1,
     group=groupTrend
)

sma200SlopeBars = input.int(
     22,
     "SMA200 Rising Lookback",
     minval=1,
     tooltip="22 trading days ≈ 1 month",
     group=groupTrend
)

low52Multiplier = input.float(
     1.25,
     "Minimum Multiple Above 52W Low",
     step=0.05,
     group=groupTrend
)

high52Multiplier = input.float(
     0.75,
     "Minimum Multiple of 52W High",
     step=0.05,
     group=groupTrend
)


// ============================================================================
// INPUT GROUP — RSI
// ============================================================================

groupRSI = "② Daily RSI"

rsiLength = input.int(
     14,
     "RSI Length",
     minval=2,
     group=groupRSI
)


// ============================================================================
// INPUT GROUP — VCP
// ============================================================================

groupVCP = "③ VCP Engine"

baseLookback = input.int(
     65,
     "Base Lookback",
     minval=20,
     maxval=130,
     tooltip="65 bars ≈ 13 trading weeks",
     group=groupVCP
)

minBaseDepth = input.float(
     10.0,
     "Minimum Base Depth %",
     step=1,
     group=groupVCP
)

maxBaseDepth = input.float(
     35.0,
     "Maximum Base Depth %",
     step=1,
     group=groupVCP
)

vcpMinScore = input.float(
     70,
     "Minimum VCP Score",
     step=5,
     group=groupVCP
)

volumeDryThreshold = input.float(
     0.65,
     "Current RVOL Dry-Up Threshold",
     step=0.05,
     group=groupVCP
)

avgVolumeDryThreshold = input.float(
     0.80,
     "Volume10 / Volume50 Threshold",
     step=0.05,
     group=groupVCP
)


// ============================================================================
// INPUT GROUP — PIVOT
// ============================================================================

groupPivot = "④ Pivot / Breakout"

pivotLookback = input.int(
     20,
     "Pivot Lookback",
     minval=5,
     group=groupPivot
)

readyDistance = input.float(
     5.0,
     "READY if Within % Below Pivot",
     step=0.5,
     group=groupPivot
)

breakoutRVOL = input.float(
     1.50,
     "Minimum Breakout RVOL",
     step=0.1,
     group=groupPivot
)

maxChasePct = input.float(
     3.0,
     "Maximum % Above Pivot",
     step=0.5,
     group=groupPivot
)


// ============================================================================
// INPUT GROUP — VISUAL
// ============================================================================

groupVisual = "⑤ Chart & Dashboard"

showSMA = input.bool(
     true,
     "Show SMA 50 / 150 / 200",
     group=groupVisual
)

showPivot = input.bool(
     true,
     "Show Pivot",
     group=groupVisual
)

showSignals = input.bool(
     true,
     "Show READY / BREAKOUT Signals",
     group=groupVisual
)

showStageBackground = input.bool(
     true,
     "Highlight Stage 2 Background",
     group=groupVisual
)

showDashboard = input.bool(
     true,
     "Show Dashboard",
     group=groupVisual
)


// ============================================================================
// COLORS
// ============================================================================

colorGreen =
     color.rgb(38, 208, 124)

colorBrightGreen =
     color.rgb(70, 235, 145)

colorYellow =
     color.rgb(255, 193, 7)

colorOrange =
     color.rgb(255, 145, 0)

colorRed =
     color.rgb(255, 82, 82)

colorBlue =
     color.rgb(51, 153, 255)

colorPurple =
     color.rgb(170, 100, 255)

colorWhite =
     color.rgb(240, 242, 245)

colorGray =
     color.rgb(145, 150, 160)

colorDark =
     color.rgb(20, 22, 28)

colorDark2 =
     color.rgb(29, 32, 40)


// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

clamp(float value, float minimum, float maximum) =>
    math.max(
         minimum,
         math.min(maximum, value)
    )


scoreColor(float value) =>
    value >= 90
         ? colorBrightGreen
         : value >= 80
         ? colorGreen
         : value >= 70
         ? colorYellow
         : value >= 50
         ? colorOrange
         : colorRed


boolText(bool condition) =>
    condition ? "PASS" : "FAIL"


boolColor(bool condition) =>
    condition ? colorGreen : colorRed


// ============================================================================
// MOVING AVERAGES
// ============================================================================

sma50 =
     ta.sma(close, sma50Len)

sma150 =
     ta.sma(close, sma150Len)

sma200 =
     ta.sma(close, sma200Len)


// ============================================================================
// 52 WEEK RANGE
// ============================================================================

high52 =
     ta.highest(high, 252)

low52 =
     ta.lowest(low, 252)

distance52High =
     high52 > 0
     ? (close / high52 - 1) * 100
     : na

distance52Low =
     low52 > 0
     ? (close / low52 - 1) * 100
     : na


// ============================================================================
// STAGE 2 TREND TEMPLATE
// ============================================================================

// 1.
// Current price above SMA150 and SMA200.

t1 =
     close > sma150 and
     close > sma200


// 2.
// SMA150 above SMA200.

t2 =
     sma150 > sma200


// 3.
// SMA200 rising versus approximately one month ago.

t3 =
     sma200 > sma200[sma200SlopeBars]


// 4.
// SMA50 above SMA150 and SMA200.

t4 =
     sma50 > sma150 and
     sma50 > sma200


// 5.
// Price >= 25% above 52W low.

t5 =
     close >= low52 * low52Multiplier


// 6.
// Price within 25% of 52W high.

t6 =
     close >= high52 * high52Multiplier


// 7.
// Price above SMA50.

t7 =
     close > sma50


// ============================================================================
// TREND TEMPLATE COUNT
// ============================================================================

ttCount =
     (t1 ? 1 : 0) +
     (t2 ? 1 : 0) +
     (t3 ? 1 : 0) +
     (t4 ? 1 : 0) +
     (t5 ? 1 : 0) +
     (t6 ? 1 : 0) +
     (t7 ? 1 : 0)


trendTemplatePass =
     ttCount == 7


trendScore =
     ttCount / 7.0 * 100.0


// ============================================================================
// DAILY RSI
//
// INFORMATION ONLY
// ============================================================================

dailyRSI =
     request.security(
         syminfo.tickerid,
         "D",
         ta.rsi(close, rsiLength),
         barmerge.gaps_off,
         barmerge.lookahead_off
     )


// ============================================================================
// VOLUME
// ============================================================================

vol10 =
     ta.sma(volume, 10)

vol50 =
     ta.sma(volume, 50)


rvol =
     vol50 > 0
     ? volume / vol50
     : na


vol10Ratio =
     vol50 > 0
     ? vol10 / vol50
     : na


volumeDryUp =
     rvol < volumeDryThreshold and
     vol10Ratio < avgVolumeDryThreshold


// ============================================================================
// BASE STRUCTURE
// ============================================================================

baseHigh =
     ta.highest(high, baseLookback)

baseLow =
     ta.lowest(low, baseLookback)


baseDepth =
     baseHigh > 0
     ? (baseHigh - baseLow) / baseHigh * 100
     : na


baseDepthOK =
     baseDepth >= minBaseDepth and
     baseDepth <= maxBaseDepth


// ============================================================================
// RANGE CONTRACTION
// ============================================================================

high10 =
     ta.highest(high, 10)

low10 =
     ta.lowest(low, 10)

high20 =
     ta.highest(high, 20)

low20 =
     ta.lowest(low, 20)

high40 =
     ta.highest(high, 40)

low40 =
     ta.lowest(low, 40)


range10 =
     close > 0
     ? (high10 - low10) / close * 100
     : na


range20 =
     close > 0
     ? (high20 - low20) / close * 100
     : na


range40 =
     close > 0
     ? (high40 - low40) / close * 100
     : na


contraction1 =
     range10 < range20 * 0.75


contraction2 =
     range20 < range40 * 0.85


rangeContracting =
     contraction1 and contraction2


// ============================================================================
// ATR CONTRACTION
// ============================================================================

atr5 =
     ta.atr(5)

atr20 =
     ta.atr(20)

atr50 =
     ta.atr(50)


atrContract1 =
     atr5 < atr20 * 0.85


atrContract2 =
     atr20 < atr50


atrContracting =
     atrContract1 and atrContract2


// ============================================================================
// RIGHT-SIDE TIGHTNESS
// ============================================================================

rightSideTight =
     range10 < range20 * 0.75


// ============================================================================
// VCP SCORE
//
// Base Depth                20
// Range Contraction         25
// ATR Contraction           20
// Volume Dry-Up             20
// Right-Side Tightness      15
//                           ---
//                           100
//
// ============================================================================

float vcpScore = 0.0


vcpScore +=
     baseDepthOK
     ? 20.0
     : 0.0


vcpScore +=
     contraction1
     ? 12.5
     : 0.0


vcpScore +=
     contraction2
     ? 12.5
     : 0.0


vcpScore +=
     atrContract1
     ? 10.0
     : 0.0


vcpScore +=
     atrContract2
     ? 10.0
     : 0.0


vcpScore +=
     volumeDryUp
     ? 20.0
     : 0.0


vcpScore +=
     rightSideTight
     ? 15.0
     : 0.0


// ============================================================================
// PIVOT
//
// Highest high of previous N bars.
// Current bar excluded.
// ============================================================================

pivot =
     ta.highest(
         high[1],
         pivotLookback
     )


pivotDistance =
     pivot > 0
     ? (close / pivot - 1) * 100
     : na


// ============================================================================
// SETUP CLASSIFICATION
// ============================================================================

nearPivot =
     pivotDistance <= 0 and
     pivotDistance >= -readyDistance


validBreakoutZone =
     pivotDistance > 0 and
     pivotDistance <= maxChasePct


breakoutVolume =
     rvol >= breakoutRVOL


breakout =
     trendTemplatePass and
     vcpScore >= vcpMinScore and
     validBreakoutZone and
     breakoutVolume


ready =
     trendTemplatePass and
     vcpScore >= vcpMinScore and
     nearPivot


extended =
     trendTemplatePass and
     pivotDistance > maxChasePct


developing =
     trendTemplatePass and
     not ready and
     not breakout and
     not extended


// ============================================================================
// SIGNAL CODE
// ============================================================================

signalCode =
     breakout
     ? 3
     : extended
     ? 4
     : ready
     ? 2
     : developing
     ? 1
     : 0


// ============================================================================
// SEPA SCORE
//
// RSI IS NOT INCLUDED.
//
// Trend Template        30
// VCP                   30
// Volume                15
// Pivot                 15
// Breakout              10
//                       ---
//                       100
//
// ============================================================================

trendComponent =
     trendScore / 100 * 30


vcpComponent =
     vcpScore / 100 * 30


volumeComponent =
     volumeDryUp
     ? 15
     : rvol < 1
     ? 7.5
     : 0


pivotComponent =
     nearPivot
     ? 15
     : validBreakoutZone
     ? 15
     : pivotDistance >= -10 and
       pivotDistance < -readyDistance
     ? 7.5
     : 0


breakoutComponent =
     breakout
     ? 10
     : validBreakoutZone and rvol >= 1.20
     ? 5
     : 0


sepaScore =
     trendComponent +
     vcpComponent +
     volumeComponent +
     pivotComponent +
     breakoutComponent


sepaScore :=
     clamp(
         sepaScore,
         0,
         100
     )


// ============================================================================
// SIGNAL TEXT
// ============================================================================

signalText =
     breakout
     ? "BREAKOUT"
     : ready
     ? "READY"
     : extended
     ? "EXTENDED"
     : developing
     ? "DEVELOPING"
     : "SKIP"


signalColor =
     breakout
     ? colorBrightGreen
     : ready
     ? colorYellow
     : extended
     ? colorOrange
     : developing
     ? colorBlue
     : colorRed


// ============================================================================
// ============================================================================
// PINE SCREENER OUTPUTS
//
// KEEP THESE FIRST.
// Pine Screener can use these as columns / filters.
// ============================================================================
// ============================================================================


// 1
plot(
     sepaScore,
     "SEPA Score",
     display=display.data_window
)


// 2
plot(
     ttCount,
     "Trend Template 0-7",
     display=display.data_window
)


// 3
plot(
     vcpScore,
     "VCP Score",
     display=display.data_window
)


// 4
plot(
     dailyRSI,
     "Daily RSI",
     display=display.data_window
)


// 5
plot(
     pivotDistance,
     "Pivot Distance %",
     display=display.data_window
)


// 6
plot(
     rvol,
     "RVOL",
     display=display.data_window
)


// 7
plot(
     signalCode,
     "Signal Code",
     display=display.data_window
)


// 8
plot(
     baseDepth,
     "Base Depth %",
     display=display.data_window
)


// 9
plot(
     vol10Ratio,
     "Vol10 / Vol50",
     display=display.data_window
)


// 10
plot(
     trendTemplatePass ? 1 : 0,
     "Trend Template PASS",
     display=display.data_window
)


// ============================================================================
// CHART — MOVING AVERAGES
// ============================================================================

plot(
     showSMA ? sma50 : na,
     "SMA 50",
     color=colorBlue,
     linewidth=2
)

plot(
     showSMA ? sma150 : na,
     "SMA 150",
     color=colorOrange,
     linewidth=2
)

plot(
     showSMA ? sma200 : na,
     "SMA 200",
     color=colorRed,
     linewidth=2
)


// ============================================================================
// CHART — PIVOT
// ============================================================================

plot(
     showPivot ? pivot : na,
     "Active Pivot",
     color=color.new(colorPurple, 10),
     linewidth=2,
     style=plot.style_stepline
)


// ============================================================================
// CHART — STAGE 2 BACKGROUND
// ============================================================================

bgcolor(
     showStageBackground and trendTemplatePass
     ? color.new(colorGreen, 94)
     : na,
     title="Stage 2 Background"
)


// ============================================================================
// READY SIGNAL
// ============================================================================

readyNew =
     ready and not ready[1]


plotshape(
     showSignals and readyNew,
     title="SEPA READY",
     location=location.belowbar,
     style=shape.labelup,
     text="READY",
     color=colorYellow,
     textcolor=color.black,
     size=size.tiny
)


// ============================================================================
// BREAKOUT SIGNAL
// ============================================================================

breakoutNew =
     breakout and not breakout[1]


plotshape(
     showSignals and breakoutNew,
     title="SEPA BREAKOUT",
     location=location.belowbar,
     style=shape.labelup,
     text="BUY",
     color=colorBrightGreen,
     textcolor=color.black,
     size=size.small
)


// ============================================================================
// EXTENDED SIGNAL
// ============================================================================

extendedNew =
     extended and not extended[1]


plotshape(
     showSignals and extendedNew,
     title="SEPA EXTENDED",
     location=location.abovebar,
     style=shape.labeldown,
     text="EXT",
     color=colorOrange,
     textcolor=color.black,
     size=size.tiny
)


// ============================================================================
// DASHBOARD
// ============================================================================

var table dash =
     table.new(
         position.top_right,
         2,
         15,
         bgcolor=color.new(colorDark, 5),
         frame_color=color.new(colorWhite, 75),
         frame_width=1,
         border_color=color.new(colorWhite, 90),
         border_width=1
     )


if barstate.islast and showDashboard

    // ------------------------------------------------------------------------
    // HEADER
    // ------------------------------------------------------------------------

    table.cell(
         dash,
         0,
         0,
         "DR.OAT SEPA",
         text_color=colorWhite,
         bgcolor=color.rgb(42, 46, 58),
         text_size=size.normal,
         text_halign=text.align_left
    )

    table.cell(
         dash,
         1,
         0,
         syminfo.ticker,
         text_color=colorBrightGreen,
         bgcolor=color.rgb(42, 46, 58),
         text_size=size.normal,
         text_halign=text.align_right
    )


    // ------------------------------------------------------------------------
    // STATUS
    // ------------------------------------------------------------------------

    table.cell(
         dash,
         0,
         1,
         "STATUS",
         text_color=colorGray,
         bgcolor=colorDark2,
         text_halign=text.align_left
    )

    table.cell(
         dash,
         1,
         1,
         signalText,
         text_color=signalColor,
         bgcolor=colorDark2,
         text_halign=text.align_right
    )


    // ------------------------------------------------------------------------
    // SEPA SCORE
    // ------------------------------------------------------------------------

    table.cell(
         dash,
         0,
         2,
         "SEPA SCORE",
         text_color=colorWhite,
         text_halign=text.align_left
    )

    table.cell(
         dash,
         1,
         2,
         str.tostring(sepaScore, "#.0") + " / 100",
         text_color=scoreColor(sepaScore),
         text_halign=text.align_right
    )


    // ------------------------------------------------------------------------
    // TREND TEMPLATE
    // ------------------------------------------------------------------------

    table.cell(
         dash,
         0,
         3,
         "TREND TEMPLATE",
         text_color=colorWhite,
         text_halign=text.align_left
    )

    table.cell(
         dash,
         1,
         3,
         str.tostring(ttCount) + " / 7",
         text_color=
             trendTemplatePass
             ? colorGreen
             : colorOrange,
         text_halign=text.align_right
    )


    // ------------------------------------------------------------------------
    // VCP
    // ------------------------------------------------------------------------

    table.cell(
         dash,
         0,
         4,
         "VCP SCORE",
         text_color=colorWhite,
         text_halign=text.align_left
    )

    table.cell(
         dash,
         1,
         4,
         str.tostring(vcpScore, "#.0"),
         text_color=scoreColor(vcpScore),
         text_halign=text.align_right
    )


    // ------------------------------------------------------------------------
    // DAILY RSI
    // ------------------------------------------------------------------------

    rsiDisplayColor =
         dailyRSI >= 80
         ? colorOrange
         : dailyRSI >= 60
         ? colorGreen
         : dailyRSI >= 50
         ? colorYellow
         : colorGray


    table.cell(
         dash,
         0,
         5,
         "RSI (DAY)",
         text_color=colorWhite,
         text_halign=text.align_left
    )

    table.cell(
         dash,
         1,
         5,
         str.tostring(dailyRSI, "#.0"),
         text_color=rsiDisplayColor,
         text_halign=text.align_right
    )


    // ------------------------------------------------------------------------
    // PIVOT
    // ------------------------------------------------------------------------

    table.cell(
         dash,
         0,
         6,
         "PIVOT",
         text_color=colorWhite,
         bgcolor=colorDark2,
         text_halign=text.align_left
    )

    table.cell(
         dash,
         1,
         6,
         str.tostring(pivot, format.mintick),
         text_color=colorPurple,
         bgcolor=colorDark2,
         text_halign=text.align_right
    )


    // ------------------------------------------------------------------------
    // PIVOT DISTANCE
    // ------------------------------------------------------------------------

    pivotDistanceColor =
         pivotDistance >= 0 and
         pivotDistance <= maxChasePct
         ? colorGreen
         : pivotDistance < 0 and
           pivotDistance >= -readyDistance
         ? colorYellow
         : pivotDistance > maxChasePct
         ? colorOrange
         : colorGray


    table.cell(
         dash,
         0,
         7,
         "DIST TO PIVOT",
         text_color=colorWhite,
         text_halign=text.align_left
    )

    table.cell(
         dash,
         1,
         7,
         str.tostring(pivotDistance, "#.00") + "%",
         text_color=pivotDistanceColor,
         text_halign=text.align_right
    )


    // ------------------------------------------------------------------------
    // RVOL
    // ------------------------------------------------------------------------

    rvolColor =
         rvol >= breakoutRVOL
         ? colorBrightGreen
         : rvol < volumeDryThreshold
         ? colorBlue
         : colorWhite


    table.cell(
         dash,
         0,
         8,
         "RVOL",
         text_color=colorWhite,
         text_halign=text.align_left
    )

    table.cell(
         dash,
         1,
         8,
         str.tostring(rvol, "#.00") + "x",
         text_color=rvolColor,
         text_halign=text.align_right
    )


    // ------------------------------------------------------------------------
    // BASE DEPTH
    // ------------------------------------------------------------------------

    table.cell(
         dash,
         0,
         9,
         "BASE DEPTH",
         text_color=colorWhite,
         text_halign=text.align_left
    )

    table.cell(
         dash,
         1,
         9,
         str.tostring(baseDepth, "#.0") + "%",
         text_color=
             baseDepthOK
             ? colorGreen
             : colorOrange,
         text_halign=text.align_right
    )


    // ------------------------------------------------------------------------
    // VOLUME DRY-UP
    // ------------------------------------------------------------------------

    table.cell(
         dash,
         0,
         10,
         "VOLUME DRY-UP",
         text_color=colorWhite,
         text_halign=text.align_left
    )

    table.cell(
         dash,
         1,
         10,
         volumeDryUp ? "YES" : "NO",
         text_color=boolColor(volumeDryUp),
         text_halign=text.align_right
    )


    // ------------------------------------------------------------------------
    // RANGE CONTRACT
    // ------------------------------------------------------------------------

    table.cell(
         dash,
         0,
         11,
         "RANGE CONTRACT",
         text_color=colorWhite,
         text_halign=text.align_left
    )

    table.cell(
         dash,
         1,
         11,
         boolText(rangeContracting),
         text_color=boolColor(rangeContracting),
         text_halign=text.align_right
    )


    // ------------------------------------------------------------------------
    // ATR CONTRACT
    // ------------------------------------------------------------------------

    table.cell(
         dash,
         0,
         12,
         "ATR CONTRACT",
         text_color=colorWhite,
         text_halign=text.align_left
    )

    table.cell(
         dash,
         1,
         12,
         boolText(atrContracting),
         text_color=boolColor(atrContracting),
         text_halign=text.align_right
    )


    // ------------------------------------------------------------------------
    // 52 WEEK HIGH DISTANCE
    // ------------------------------------------------------------------------

    table.cell(
         dash,
         0,
         13,
         "52W HIGH DIST",
         text_color=colorWhite,
         bgcolor=colorDark2,
         text_halign=text.align_left
    )

    table.cell(
         dash,
         1,
         13,
         str.tostring(distance52High, "#.0") + "%",
         text_color=
             t6
             ? colorGreen
             : colorOrange,
         bgcolor=colorDark2,
         text_halign=text.align_right
    )


    // ------------------------------------------------------------------------
    // FOOTER / ACTION
    // ------------------------------------------------------------------------

    actionText =
         breakout
         ? "BREAKOUT CONFIRMED"
         : ready
         ? "WATCH PIVOT CLOSELY"
         : extended
         ? "DO NOT CHASE"
         : developing
         ? "SETUP DEVELOPING"
         : "WAIT / SKIP"


    table.cell(
         dash,
         0,
         14,
         "ACTION",
         text_color=colorWhite,
         bgcolor=color.rgb(42, 46, 58),
         text_halign=text.align_left
    )

    table.cell(
         dash,
         1,
         14,
         actionText,
         text_color=signalColor,
         bgcolor=color.rgb(42, 46, 58),
         text_halign=text.align_right
    )


// ============================================================================
// ALERTS
// ============================================================================

alertcondition(
     readyNew,
     title="Dr.Oat SEPA READY",
     message="{{ticker}} is SEPA READY and near Pivot."
)


alertcondition(
     breakoutNew,
     title="Dr.Oat SEPA BREAKOUT",
     message="{{ticker}} SEPA BREAKOUT detected with volume expansion."
)


alertcondition(
     extendedNew,
     title="Dr.Oat SEPA EXTENDED",
     message="{{ticker}} is extended more than allowed distance above Pivot."
)
````
