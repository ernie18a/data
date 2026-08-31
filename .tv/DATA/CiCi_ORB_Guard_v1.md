<!-- tradingview-pine-id: PUB;a9cf7b0f52eb4a15a9b88e8e074b63a3 -->
<!-- tradingviewscripts-format: 1 -->
# CiCi ORB Guard v1

Source: https://www.tradingview.com/script/rPb19JCY-CiCi-ORB-Guard-v2/

## Description

# CiCi ORB Guard V2

CiCi ORB Guard V2 is a futures trading tool built around the **Opening Range Breakout (ORB)** strategy, with additional market-structure context designed to help traders identify confirmed breakouts, recognize potential false breakouts, and avoid entering directly into important levels.

Core Features

**📈 ORB Detection**

* Automatically identifies the Opening Range.
* Marks bullish and bearish breakouts.
* Tracks the breakout candle for confirmation.

**✅ Breakout Confirmation**

* Requires price to close beyond the breakout candle before confirming the setup.
* Helps reduce premature entries based on wicks or temporary price movement.
* Clearly identifies when a breakout fails.

**⚠️ False Breakout Detection**

* Highlights situations where price breaks the ORB but fails to continue.
* Displays a "FALSE BO — WAIT" warning when the breakout loses its level.
* Designed to encourage patience rather than chasing reversals.

**📊 Market Context**
The indicator automatically displays:

* Previous Day High (PDH)
* Previous Day Low (PDL)
* Overnight High
* Overnight Low
* Camarilla Pivot levels R1–R5 and S1–S5
* 4H 200 EMA for higher-timeframe trend context

**🟢 CLEAN vs 🟠 CAUTION Setups**

Confirmed breakouts are categorized based on surrounding market context:

**LONG — CLEAN**
A confirmed bullish breakout without the defined context conflicts.

**LONG — CAUTION**
A confirmed bullish breakout where price may be approaching an important level or is conflicting with the higher-timeframe trend.

The same logic is applied to short setups.

### Dashboard

The built-in dashboard provides a quick overview of:

* 4H trend
* Breakout status
* Previous-day levels
* Overnight levels
* Market context
* Current setup status

### Designed For

CiCi ORB Guard V2 was created primarily for **ES/MES futures traders**, but the concepts can be applied to other liquid markets and instruments.

The indicator is intended to be used as a **decision-support and market-context tool**, not as an automated trading system or a guarantee of profitable trades.

### Important

No indicator can predict market direction or eliminate false breakouts.

This tool does not replace proper risk management, position sizing, or a defined trading plan. Always test the indicator on historical data and in a simulated environment before using it with real capital.

Trade the setup. Respect the confirmation. Don't chase the candle.

---

## Source Code

````pine
//@version=6
indicator("CiCi ORB Guard v1", shorttitle="CiCi ORB Guard", overlay=true, max_labels_count=500)

// =====================================================
// SETTINGS
// =====================================================

string TZ = "America/Chicago"

string orbSession = input.session("0830-0845", "ORB Window")
string tradeSession = input.session("0845-1000", "Trading Window")

bool showSignals = input.bool(true, "Show Signals")
bool showWarnings = input.bool(true, "Show False Breakout Warnings")
bool showEMA = input.bool(true, "Show 20 EMA")
bool showDashboard = input.bool(true, "Show Dashboard")

// =====================================================
// SESSION DETECTION
// =====================================================

bool inORB = not na(time(timeframe.period, orbSession, TZ))
bool inTradeWindow = not na(time(timeframe.period, tradeSession, TZ))

bool newDay = ta.change(time("D", "0000-2359", TZ)) != 0

// =====================================================
// ORB CALCULATION
// =====================================================

var float orbHigh = na
var float orbLow = na

if newDay
    orbHigh := na
    orbLow := na

if inORB
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow := na(orbLow) ? low : math.min(orbLow, low)

// =====================================================
// ORB PLOTS
// =====================================================

plot(
     orbHigh,
     "ORB High",
     color=color.green,
     linewidth=2
)

plot(
     orbLow,
     "ORB Low",
     color=color.red,
     linewidth=2
)

// =====================================================
// 20 EMA
// =====================================================

ema20 = ta.ema(close, 20)

plot(
     showEMA ? ema20 : na,
     "20 EMA",
     color=color.orange,
     linewidth=1
)

// =====================================================
// 4H 200 EMA FOR DASHBOARD TREND
// =====================================================

ema200_4H = request.security(
     syminfo.tickerid,
     "240",
     ta.ema(close, 200),
     lookahead=barmerge.lookahead_off
)

bool bullish4H = close > ema200_4H
bool bearish4H = close < ema200_4H

// =====================================================
// BREAKOUT DETECTION
// =====================================================

bool orbReady =
     not inORB and
     not na(orbHigh) and
     not na(orbLow)

bool bullishBreakout =
     orbReady and
     inTradeWindow and
     close > orbHigh and
     close[1] <= orbHigh

bool bearishBreakout =
     orbReady and
     inTradeWindow and
     close < orbLow and
     close[1] >= orbLow

// =====================================================
// STORE BREAKOUT CANDLE
// =====================================================

var float breakoutHigh = na
var float breakoutLow = na
var int breakoutDirection = 0
var int breakoutBar = na
var bool waitingForConfirmation = false
var bool tradeConfirmed = false

if newDay
    breakoutHigh := na
    breakoutLow := na
    breakoutDirection := 0
    breakoutBar := na
    waitingForConfirmation := false
    tradeConfirmed := false

if bullishBreakout
    breakoutHigh := high
    breakoutLow := low
    breakoutDirection := 1
    breakoutBar := bar_index
    waitingForConfirmation := true
    tradeConfirmed := false

if bearishBreakout
    breakoutHigh := high
    breakoutLow := low
    breakoutDirection := -1
    breakoutBar := bar_index
    waitingForConfirmation := true
    tradeConfirmed := false

// =====================================================
// CONFIRMATION
// =====================================================

// Long confirmation:
// Confirmation candle must CLOSE above breakout candle high.

bool longConfirmation =
     waitingForConfirmation and
     breakoutDirection == 1 and
     bar_index > breakoutBar and
     close > breakoutHigh

// Short confirmation:
// Confirmation candle must CLOSE below breakout candle low.

bool shortConfirmation =
     waitingForConfirmation and
     breakoutDirection == -1 and
     bar_index > breakoutBar and
     close < breakoutLow

// =====================================================
// FAILED BREAKOUT
// =====================================================

// NEW LOGIC:
//
// Bullish breakout fails if price CLOSES
// BELOW the breakout candle's LOW.
//
// This means the breakout candle itself becomes
// the invalidation boundary.

bool failedBullishBreakout =
     waitingForConfirmation and
     breakoutDirection == 1 and
     bar_index > breakoutBar and
     close < breakoutLow

// Bearish breakout fails if price CLOSES
// ABOVE the breakout candle's HIGH.

bool failedBearishBreakout =
     waitingForConfirmation and
     breakoutDirection == -1 and
     bar_index > breakoutBar and
     close > breakoutHigh

// =====================================================
// CONFIRMED TRADE
// =====================================================

if longConfirmation
    tradeConfirmed := true
    waitingForConfirmation := false

if shortConfirmation
    tradeConfirmed := true
    waitingForConfirmation := false

// =====================================================
// CANCEL FAILED BREAKOUT
// =====================================================

if failedBullishBreakout
    waitingForConfirmation := false
    tradeConfirmed := false

if failedBearishBreakout
    waitingForConfirmation := false
    tradeConfirmed := false

// =====================================================
// VISUAL SIGNALS
// =====================================================

plotshape(
     showSignals and bullishBreakout,
     title="Bullish ORB Breakout",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.lime,
     size=size.small,
     text="BO"
)

plotshape(
     showSignals and bearishBreakout,
     title="Bearish ORB Breakout",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.small,
     text="BO"
)

plotshape(
     showSignals and longConfirmation,
     title="Long Confirmation",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="LONG\nCONFIRMED",
     textcolor=color.white
)

plotshape(
     showSignals and shortConfirmation,
     title="Short Confirmation",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SHORT\nCONFIRMED",
     textcolor=color.white
)

plotshape(
     showWarnings and failedBullishBreakout,
     title="Failed Bullish Breakout",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.orange,
     text="FALSE BO\nWAIT",
     textcolor=color.white
)

plotshape(
     showWarnings and failedBearishBreakout,
     title="Failed Bearish Breakout",
     style=shape.labelup,
     location=location.belowbar,
     color=color.orange,
     text="FALSE BO\nWAIT",
     textcolor=color.white
)

// =====================================================
// DASHBOARD
// =====================================================

var table dashboard = table.new(
     position.top_right,
     2,
     10,
     border_width=1
)

if barstate.islast and showDashboard

    // -------------------------
    // 4H TREND
    // -------------------------

    string trendText =
         bullish4H ? "BULLISH" :
         bearish4H ? "BEARISH" :
         "NEUTRAL"

    // -------------------------
    // ORB STATUS
    // -------------------------

    string orbText =
         inORB ? "FORMING" :
         orbReady ? "COMPLETE" :
         "WAITING"

    // -------------------------
    // BREAKOUT STATUS
    // -------------------------

    string breakoutText =
         breakoutDirection == 1 ? "BULLISH" :
         breakoutDirection == -1 ? "BEARISH" :
         "NONE"

    // -------------------------
    // CONFIRMATION STATUS
    // -------------------------

    string confirmationText =
         tradeConfirmed ? "CONFIRMED" :
         waitingForConfirmation ? "WAITING" :
         "NONE"

    // -------------------------
    // 20 EMA STATUS
    // -------------------------

    string emaText =
         close > ema20 ? "PRICE ABOVE" :
         close < ema20 ? "PRICE BELOW" :
         "AT EMA"

    // -------------------------
    // OVERALL STATUS
    // -------------------------

    string statusText =
         longConfirmation ? "LONG CONFIRMED" :
         shortConfirmation ? "SHORT CONFIRMED" :
         failedBullishBreakout ? "FALSE BO - WAIT" :
         failedBearishBreakout ? "FALSE BO - WAIT" :
         waitingForConfirmation ? "WAIT FOR CLOSE" :
         "NO SETUP"

    // -------------------------
    // GUIDE
    // -------------------------

    string guideText =
         longConfirmation ? "ENTER LONG" :
         shortConfirmation ? "ENTER SHORT" :
         waitingForConfirmation ? "WAIT FOR BREAK" :
         failedBullishBreakout ? "DO NOT SHORT" :
         failedBearishBreakout ? "DO NOT LONG" :
         "WAIT"

    // -------------------------
    // DASHBOARD
    // -------------------------

    table.cell(
         dashboard,
         0,
         0,
         "CiCi ORB GUARD",
         text_color=color.white
    )

    table.cell(
         dashboard,
         1,
         0,
         "V1",
         text_color=color.white
    )

    table.cell(
         dashboard,
         0,
         1,
         "4H Trend"
    )

    table.cell(
         dashboard,
         1,
         1,
         trendText
    )

    table.cell(
         dashboard,
         0,
         2,
         "ORB"
    )

    table.cell(
         dashboard,
         1,
         2,
         orbText
    )

    table.cell(
         dashboard,
         0,
         3,
         "Breakout"
    )

    table.cell(
         dashboard,
         1,
         3,
         breakoutText
    )

    table.cell(
         dashboard,
         0,
         4,
         "Confirmation"
    )

    table.cell(
         dashboard,
         1,
         4,
         confirmationText
    )

    table.cell(
         dashboard,
         0,
         5,
         "20 EMA"
    )

    table.cell(
         dashboard,
         1,
         5,
         emaText
    )

    table.cell(
         dashboard,
         0,
         6,
         "Status"
    )

    table.cell(
         dashboard,
         1,
         6,
         statusText
    )

    table.cell(
         dashboard,
         0,
         7,
         "Guide"
    )

    table.cell(
         dashboard,
         1,
         7,
         guideText
    )

    table.cell(
         dashboard,
         0,
         8,
         "Rule"
    )

    table.cell(
         dashboard,
         1,
         8,
         "CLOSE > BO CANDLE"
    )

    table.cell(
         dashboard,
         0,
         9,
         "Discipline"
    )

    table.cell(
         dashboard,
         1,
         9,
         "NO CHASE"
    )

// =====================================================
// ALERTS
// =====================================================

alertcondition(
     longConfirmation,
     title="CiCi Long Confirmation",
     message="CiCi ORB Guard: LONG confirmation on {{ticker}}"
)

alertcondition(
     shortConfirmation,
     title="CiCi Short Confirmation",
     message="CiCi ORB Guard: SHORT confirmation on {{ticker}}"
)

alertcondition(
     failedBullishBreakout or failedBearishBreakout,
     title="CiCi False Breakout",
     message="CiCi ORB Guard: FALSE BREAKOUT — WAIT on {{ticker}}"
)
````
