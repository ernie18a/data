# Smart Risk Manager

- url: https://www.tradingview.com/script/YLueVZjE-Smart-Risk-Manager/
- type: indicator
- pine_id: PUB;c55f0ec55b5d4bcab0e32e52d4812e2c
- version: 4.0

## Description

Smart Risk Manager is a visual risk-planning and position-sizing indicator designed to help traders build a structured trade plan directly on the chart.

The script calculates and displays:

* Account risk
* Risk amount
* Planned entry
* Stop level
* Stop distance
* Position size
* Position value
* Exposure percentage
* Risk:Reward
* Up to three target zones
* Target confluence sources
* Auto BOS setup status
* Manual trade plan status
* Entry / Stop / Target lines
* A customizable risk dashboard

This is an indicator, not a strategy. It does not place orders, does not execute trades, and does not produce TradingView Strategy Tester backtest results. The tool is intended for trade planning, educational risk management, and chart-based analysis only.

Important note

Smart Risk Manager does not guarantee profitable trades.

It does not predict future price movement.

It does not provide financial advice.

It does not replace a broker, a trading plan, or professional risk management.

All values are calculated from the user’s selected inputs and the chart’s price data. Users should always verify position size, tick value, contract multiplier, margin requirements, spread, commission, slippage, and broker-specific rules before using any calculated value in live trading.

Main purpose

The purpose of Smart Risk Manager is to help traders answer practical planning questions before entering a trade, such as:

* Where is the planned entry?
* Where is the stop?
* How much money is at risk?
* What position size matches the selected risk percentage?
* What is the approximate exposure?
* Where are possible targets?
* Which target levels have confluence?
* What is the approximate Risk:Reward profile?

The indicator is designed to make risk planning more visible and easier to review on the chart.

1. Account & Risk

The Account & Risk section allows the user to define the basic risk model.

Account Size

The user enters the total account size in the account currency.

Risk per Trade %

The user selects the maximum percentage of the account to risk if the stop level is reached.

For example, if Account Size is 10,000 and Risk per Trade is 1%, the planned risk amount is 100.

Instrument Type

The script includes instrument selection for:

* Stocks / Shares
* Forex / Units
* Crypto / Coins

This affects the display wording for the calculated position size.

Round size to whole units

When enabled, the calculated position size is rounded down to whole units. This is useful for stocks and shares.

When disabled, the script can display fractional sizing, which may be more suitable for crypto or some forex/CFD planning workflows.

Important limitation

The position-sizing calculation is generic. Some markets use contract multipliers, tick values, lot sizes, minimum order quantities, leverage, margin rules, spread costs, and currency conversions. Users must confirm the final order size with their broker or exchange.

2. Entry Logic Modes

The script includes two planning modes:

* Auto BOS
* Manual Plan

Auto BOS Mode

Auto BOS mode uses market structure to create a logical planning setup when price breaks a confirmed structure level.

The script detects confirmed pivot highs and pivot lows using the selected Structure Pivot Left and Structure Pivot Right settings.

A bullish Auto BOS setup can appear when price closes above the last confirmed structure high.

A bearish Auto BOS setup can appear when price closes below the last confirmed structure low.

The Auto BOS mode can be used to automatically create:

* Auto entry level
* Auto stop level
* Direction
* Setup reason
* Risk and target plan

Auto Direction

The user can choose:

Both
Allows both long and short Auto BOS planning setups.

Long Only
Allows only bullish Auto BOS planning setups.

Short Only
Allows only bearish Auto BOS planning setups.

Candle Confirmation

When enabled, the breakout candle must confirm direction:

* Long setup requires a bullish candle.
* Short setup requires a bearish candle.

Max Breakout Distance %

This filter helps avoid planning entries when price has already moved too far away from the broken structure level.

A value of 0 disables this filter.

Min Structure Range %

This filter helps avoid very small structures that may produce noisy or low-quality Auto BOS events.

Auto Stop Style

The script includes two Auto Stop styles:

Recent Pullback
Uses a recent pullback area for a closer stop.

Structure Swing
Uses the broader structure swing for a wider structural stop.

Auto Stop Buffer %

Adds a small buffer beyond the selected auto stop level.

Minimum R:R Filter

When enabled, Auto BOS setups appear only if the projected setup Risk:Reward is equal to or above the selected minimum value.

One active setup at a time

When enabled, the script prevents repeated same-direction Auto BOS setups until an opposite setup appears.

Show Auto BOS signals

This setting is OFF by default. When enabled, the script displays Auto Long BOS and Auto Short BOS markers on the chart.

Important note about Auto BOS

Auto BOS is a planning event based on confirmed structure. It is not an automatic buy or sell recommendation. It should be used as a planning reference and combined with the user’s own analysis.

3. Manual Plan Mode

Manual Plan mode allows the user to create a custom trade plan.

The user selects:

* Manual Direction
* Manual Entry Price
* Manual Stop Mode
* Target methods

Manual Direction

The user can choose:

Long
Creates a long-side plan.

Short
Creates a short-side plan.

Manual Entry Price

The user enters the planned entry price manually.

Manual Plan mode is useful when the trader already has a specific entry level and wants the script to calculate position size, risk, exposure, and target levels.

4. Stop Loss Methods

The script supports several stop calculation methods in Manual Plan mode.

Swing Structure

Uses the recent swing low for long plans or recent swing high for short plans.

ATR

Uses an ATR-based stop distance from the manual entry price.

For long plans, the stop is placed below entry.

For short plans, the stop is placed above entry.

Percent

Uses a percentage-based stop from the manual entry price.

Manual

Allows the user to enter a custom stop price.

Important stop placement rule

For a valid long plan, the stop must be below the entry.

For a valid short plan, the stop must be above the entry.

If the stop is placed incorrectly, the dashboard will show an invalid stop status.

5. Position Size Calculation

The script calculates position size from:

* Account Size
* Risk per Trade %
* Entry Price
* Stop Price
* Stop Distance

The general logic is:

Risk Amount = Account Size × Risk %

Position Size = Risk Amount ÷ Stop Distance

The script then displays:

* Risk Amount
* Stop Distance
* Position Size
* Position Value
* Exposure %

Risk Amount

The estimated amount that would be lost if the planned stop is reached, before considering real-world execution costs such as spread, slippage, commission, and broker rules.

Position Size

The calculated quantity based on the selected risk amount and stop distance.

Position Value

The approximate value of the planned position.

Exposure %

The position value compared with account size.

If exposure is above 100%, the dashboard highlights it as a potential leverage or overexposure condition.

6. Target Methods

The script can create target candidates from several sources.

The user can enable or disable each target method.

Available target methods:

* Swing Highs / Lows
* Fibonacci Extension
* Liquidity Equal Highs / Lows
* R-Multiple
* Manual prices

Swing Highs / Lows

For long plans, the script uses previous swing highs as potential target levels.

For short plans, it uses previous swing lows.

Fibonacci Extension

The script uses the selected swing lookback and Fibonacci extension levels to calculate possible target levels.

Default extension levels include:

* 127.2%
* 161.8%
* 261.8%

These levels can be changed in settings.

Liquidity Equal Highs / Lows

When enabled, the script looks for approximately equal highs or equal lows using the selected tolerance.

For long plans, equal highs can be used as possible upside liquidity targets.

For short plans, equal lows can be used as possible downside liquidity targets.

R-Multiple Targets

The script can calculate targets based on the risk distance.

Default R-Multiple targets include:

* 1R
* 2R
* 3R

Manual Targets

The user can enter up to three custom target prices manually.

7. Target Confluence

The script groups target candidates that are close to each other.

Confluence tolerance controls how close target levels must be to be grouped together.

If multiple target methods point to approximately the same area, the script marks the target as a confluence zone.

Examples of target confluence:

* Swing + Fibonacci
* R-Multiple + Fibonacci
* Liquidity + Swing
* Manual + R-Multiple

Targets with stronger confluence are visually highlighted differently from single-method targets.

Important note about targets

Targets are planning references only. They do not guarantee that price will reach them. They should be used as possible reference zones, not as guaranteed outcomes.

8. Dashboard

Smart Risk Manager includes a customizable dashboard.

The dashboard displays:

Account
The account size entered by the user.

Risk %
The selected percentage of account risk.

Risk Amount
The estimated risk amount based on position size and stop distance.

Entry
The planned entry price.

Stop
The planned stop price.

Stop Distance
The distance between entry and stop, displayed in price units and percentage.

Position Size
The calculated quantity for the selected risk.

Position Value
The approximate value of the planned position.

Exposure
The position value as a percentage of account size.

Risk : Reward
The approximate Risk:Reward to the furthest selected target.

Setup Logic
Shows whether the plan is based on Auto BOS or Manual Plan.

Reason
Shows the current reason or status of the setup.

Targets From
Shows which target methods are enabled.

T1 / T2 / T3
Shows up to three calculated target levels.

Status
Shows the current planning status, such as:

* Waiting for BOS setup
* Set manual entry price
* Invalid stop placement
* No targets - enable method
* Leverage > 100%
* High risk per trade
* OK to plan

9. Dashboard Themes

The script includes several dashboard themes:

* Luxury Dark
* Midnight Blue
* Graphite Gold
* Classic Dark

The user can also choose:

* Dashboard position
* Dashboard size
* Alternate row shading

10. Entry / Stop / Target Lines

When enabled, the script draws visual lines on the chart:

Entry Line

Shows the planned entry level.

Stop Line

Shows the planned stop level.

Target Lines

Shows up to three target levels.

Target labels can include:

* Target price
* R-Multiple
* Estimated potential gain
* Target source method
* Confluence marker when multiple methods align

Line Length

Controls how far the planning lines extend to the right.

11. Alerts

The script includes alert conditions for:

Auto Long BOS

Triggered when a bullish Auto BOS planning setup is detected.

Auto Short BOS

Triggered when a bearish Auto BOS planning setup is detected.

STOP hit

Triggered when price reaches the displayed stop level.

Target 1 reached

Triggered when price reaches Target 1.

Target 2 reached

Triggered when price reaches Target 2.

Target 3 reached

Triggered when price reaches Target 3.

Important alert note

Alerts are notifications only. They do not place orders and do not confirm broker execution.

12. How to use Smart Risk Manager

A practical workflow:

1. Enter your account size.
2. Select your risk per trade.
3. Choose the instrument type.
4. Choose Auto BOS or Manual Plan.
5. If using Manual Plan, enter the planned entry price.
6. Choose a stop method or enter a manual stop price.
7. Enable the target methods you want to use.
8. Review position size, risk amount, exposure, and Risk:Reward in the dashboard.
9. Review Entry / Stop / Target lines on the chart.
10. Confirm all values with your broker before placing any real trade.

Suggested use cases

Smart Risk Manager can be useful for:

* Position sizing
* Pre-trade planning
* Risk review
* Stop distance review
* Exposure control
* Target planning
* Risk:Reward comparison
* Auto BOS setup planning
* Manual trade planning
* Educational risk-management study

13. Important limitations

This script does not execute trades.

This script is not a trading strategy.

This script does not provide Strategy Tester results.

This script does not guarantee profitable outcomes.

This script does not account for all broker-specific rules.

The calculated position size is a generic estimate.

Forex, futures, CFDs, and leveraged products may require contract-size, tick-value, pip-value, margin, and currency conversion adjustments.

Commissions, spreads, slippage, taxes, borrow fees, funding costs, and order execution differences are not included in the generic calculation.

Auto BOS setups are structure-based planning events, not automatic trade recommendations.

Pivot-based structure requires confirmation bars, so structure levels are confirmed after the selected pivot settings.

Target levels are possible planning references, not guaranteed price destinations.

Stop and target alerts are chart-level events, not broker fills.

Users are responsible for verifying all calculations and managing their own risk.

14. Originality and purpose

Smart Risk Manager combines several trade-planning tools into one organized dashboard:

* Account risk calculation
* Position size calculation
* Auto BOS planning mode
* Manual trade planning mode
* Multiple stop methods
* Multiple target methods
* Target confluence grouping
* Exposure monitoring
* Visual Entry / Stop / Target lines
* Customizable dashboard themes
* Alert conditions for planning levels

The purpose of the script is to help traders build a clearer and more structured risk plan before making a trading decision.

Educational disclaimer

Smart Risk Manager is for educational and chart-analysis purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. Users should perform their own analysis and confirm all position-sizing and risk calculations with their broker or exchange before trading.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ADXAE

//@version=6
indicator("Smart Risk Manager", "Smart Risk Mgr", overlay = true, max_lines_count = 100, max_labels_count = 100)

// ===================== Inputs: Account & Risk =====================
grpAcc       = "Account & Risk"
accountSize  = input.float(10000.0, "Account Size", minval = 0.0, group = grpAcc, tooltip = "Total trading capital in your account currency.")
riskPct      = input.float(1.0, "Risk per Trade (%)", minval = 0.0, maxval = 100.0, step = 0.1, group = grpAcc, tooltip = "Max % of the account you are willing to lose if the stop is hit.")
instrument   = input.string("Stocks / Shares", "Instrument", options = ["Stocks / Shares", "Forex / Units", "Crypto / Coins"], group = grpAcc)
wholeUnits   = input.bool(true, "Round size to whole units", group = grpAcc, tooltip = "On for stocks. Off for fractional crypto / forex lots.")

// ===================== Inputs: Entry Logic =====================
grpEntry     = "Entry Logic"
entryLogic   = input.string("Auto BOS", "Entry Logic Mode", options = ["Auto BOS", "Manual Plan"], group = grpEntry, tooltip = "Auto BOS creates logical entries from market structure. Manual Plan lets you set your own entry.")
autoBias     = input.string("Both", "Auto Direction", options = ["Both", "Long Only", "Short Only"], group = grpEntry)
autoLeft     = input.int(5, "Structure Pivot Left", minval = 1, group = grpEntry)
autoRight    = input.int(5, "Structure Pivot Right", minval = 1, group = grpEntry)
requireCandleConfirm = input.bool(true, "Require candle confirmation", group = grpEntry, tooltip = "For long setups, the breakout candle should close bullish. For short setups, the breakout candle should close bearish.")
maxBreakoutPct = input.float(5.0, "Max breakout distance (%)", minval = 0.0, step = 0.1, group = grpEntry, tooltip = "Avoids entries that are too far from the broken structure level. Set 0 to disable.")
minStructureRangePct = input.float(0.15, "Min structure range (%)", minval = 0.0, step = 0.05, group = grpEntry, tooltip = "Filters out very small swing structures that usually create noisy signals.")
autoStopStyle = input.string("Recent Pullback", "Auto Stop Style", options = ["Recent Pullback", "Structure Swing"], group = grpEntry, tooltip = "Recent Pullback gives a closer stop. Structure Swing gives a wider structural stop.")
autoStopLookback = input.int(8, "Recent Pullback Lookback", minval = 2, group = grpEntry)
autoStopBufferPct = input.float(0.10, "Auto stop buffer (%)", minval = 0.0, step = 0.01, group = grpEntry)
useAutoRRFilter = input.bool(false, "Use minimum R:R filter", group = grpEntry, tooltip = "When enabled, Auto BOS signals appear only if the projected setup R:R is above the minimum value.")
minAutoRR = input.float(1.00, "Minimum Auto Setup R:R", minval = 0.1, step = 0.1, group = grpEntry)
oneSetupAtATime = input.bool(true, "One active setup at a time", group = grpEntry, tooltip = "When enabled, the first confirmed Auto BOS setup stays fixed until an opposite setup appears. This prevents AUTO ENTRY from being replaced by later same-direction signals.")
lockAutoOnClose = input.bool(true, "Lock Auto Entry on candle close", group = grpEntry, tooltip = "When enabled, Auto BOS entries are saved only after the breakout candle closes. This prevents AUTO ENTRY from moving up or down with the live candle before confirmation.")
showAutoSignals = input.bool(false, "Show Auto BOS signals", group = grpEntry, tooltip = "Turn this on only if you want to display BOS entry markers on the chart.")

// ===================== Inputs: Manual Plan =====================
grpManual    = "Manual Plan"
manualDir    = input.string("Long", "Manual Direction", options = ["Long", "Short"], group = grpManual)
manualEntry  = input.float(0.0, "Manual Entry Price", minval = 0.0, group = grpManual, tooltip = "Used only when Entry Logic Mode is Manual Plan.")

// ===================== Inputs: Manual Stop Loss =====================
grpStop      = "Manual Stop Loss"
stopMode     = input.string("Swing Structure", "Manual Stop Mode", options = ["Swing Structure", "ATR", "Percent", "Manual"], group = grpStop, tooltip = "Used only in Manual Plan mode. Auto BOS uses Auto Stop Style.")
atrLen       = input.int(14, "ATR Length", minval = 1, group = grpStop)
atrMult      = input.float(2.0, "ATR Multiple", minval = 0.1, step = 0.1, group = grpStop)
swingLenStop = input.int(20, "Swing Lookback (stop)", minval = 1, group = grpStop)
stopPct      = input.float(2.0, "Stop Percent (%)", minval = 0.1, step = 0.1, group = grpStop)
manualStop   = input.float(0.0, "Manual Stop Price", minval = 0.0, group = grpStop, tooltip = "Used only when Manual Stop Mode is Manual.")

// ===================== Inputs: Target Methods =====================
grpTgt       = "Targets (enable what you like)"
useSwing     = input.bool(true, "Swing Highs / Lows", group = grpTgt)
useFib       = input.bool(true, "Fibonacci Extension", group = grpTgt)
useLiq       = input.bool(false, "Liquidity (Equal H/L)", group = grpTgt)
useRMult     = input.bool(true, "R-Multiple", group = grpTgt)
useManual    = input.bool(false, "Manual prices", group = grpTgt)

// ===================== Swing Target Params =====================
grpSw        = "Targets: Swing"
pivLeft      = input.int(10, "Pivot Left bars", minval = 1, group = grpSw)
pivRight     = input.int(10, "Pivot Right bars", minval = 1, group = grpSw)

// ===================== Fibonacci Params =====================
grpFib       = "Targets: Fibonacci"
fibLook      = input.int(60, "Swing Lookback", minval = 5, group = grpFib)
fibM1        = input.float(1.272, "Ext level 1", step = 0.001, group = grpFib)
fibM2        = input.float(1.618, "Ext level 2", step = 0.001, group = grpFib)
fibM3        = input.float(2.618, "Ext level 3", step = 0.001, group = grpFib)

// ===================== Liquidity Params =====================
grpLiq       = "Targets: Liquidity"
liqTolPct    = input.float(0.15, "Equal level tolerance (%)", minval = 0.0, step = 0.01, group = grpLiq)

// ===================== R-Multiple Params =====================
grpR         = "Targets: R-Multiple"
rr1          = input.float(1.0, "Target 1 (R)", minval = 0.0, step = 0.5, group = grpR)
rr2          = input.float(2.0, "Target 2 (R)", minval = 0.0, step = 0.5, group = grpR)
rr3          = input.float(3.0, "Target 3 (R)", minval = 0.0, step = 0.5, group = grpR)

// ===================== Manual Target Params =====================
grpMan       = "Targets: Manual"
man1         = input.float(0.0, "Manual Target 1", minval = 0.0, group = grpMan)
man2         = input.float(0.0, "Manual Target 2", minval = 0.0, group = grpMan)
man3         = input.float(0.0, "Manual Target 3", minval = 0.0, group = grpMan)

// ===================== Confluence =====================
grpConf      = "Confluence"
confTolPct   = input.float(0.40, "Confluence tolerance (%)", minval = 0.01, step = 0.01, group = grpConf)

// ===================== Display =====================
grpDisp      = "Display"
showDashboard = input.bool(false, "Show Dashboard", group = grpDisp, tooltip = "OFF by default to keep the chart clean. Turn ON to display account risk, position size, stop, targets, and status table.")
tblPos       = input.string("Top Right", "Table Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = grpDisp, active = showDashboard)
tblSize      = input.string("Normal", "Table Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpDisp, active = showDashboard)
dashTheme    = input.string("Luxury Dark", "Dashboard Theme", options = ["Luxury Dark", "Midnight Blue", "Graphite Gold", "Classic Dark"], group = grpDisp, active = showDashboard)
zebraRows    = input.bool(true, "Alternate row shading", group = grpDisp, active = showDashboard)
showEntryStopLines = input.bool(true, "Draw Entry / Stop lines", group = grpDisp)
showTargetLines    = input.bool(true, "Draw Target lines", group = grpDisp, tooltip = "Targets will be drawn only when this option is enabled AND at least one target method is enabled.")
lineLen      = input.int(30, "Line length (bars)", minval = 5, group = grpDisp)

// ===================== Labels =====================
grpLbl       = "Labels"
labelSizeOpt = input.string("Small", "Entry / Stop / Target Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpLbl, tooltip = "Controls the size of all price-plan labels drawn on the chart.")
labelBgTransp = input.int(84, "Label Background Transparency", minval = 0, maxval = 100, group = grpLbl, tooltip = "0 = solid background. 100 = fully transparent.")
entryLabelBg = input.color(color.rgb(64, 196, 255), "Entry Label Background", group = grpLbl)
entryLabelTextColor = input.color(color.rgb(64, 196, 255), "Entry Label Text", group = grpLbl)
stopLabelBg = input.color(color.rgb(255, 95, 109), "Stop Label Background", group = grpLbl)
stopLabelTextColor = input.color(color.rgb(255, 95, 109), "Stop Label Text", group = grpLbl)
targetLabelBg = input.color(color.rgb(54, 215, 183), "Target Label Background", group = grpLbl)
targetLabelTextColor = input.color(color.rgb(54, 215, 183), "Target Label Text", group = grpLbl)
confLabelBg = input.color(color.rgb(255, 184, 77), "Confluence Target Label Background", group = grpLbl)
confLabelTextColor = input.color(color.rgb(255, 184, 77), "Confluence Target Label Text", group = grpLbl)

// ===================== Helpers =====================
f_money(x) =>
    na(x) ? "-" : str.tostring(x, "#,###.##")

f_price(x) =>
    na(x) ? "-" : str.tostring(x, format.mintick)

f_row_bg(_row, _bg1, _bg2, _zebra) =>
    _zebra ? (_row % 2 == 0 ? _bg1 : _bg2) : _bg1

f_fib_label(_level) =>
    "Fib " + str.tostring(_level * 100.0, "#.#") + "%"

f_join_tag(_txt, _tag) =>
    _txt == "" ? _tag : str.contains(_txt, _tag) ? _txt : _txt + " + " + _tag

f_label_size(_sizeOpt) =>
    switch _sizeOpt
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Large"  => size.large
        "Huge"   => size.huge
        => size.normal

f_add(array<float> prices, array<string> tags, float v, string tag, bool lng, float ref) =>
    if not na(v) and not na(ref)
        if (lng and v > ref) or (not lng and v < ref)
            array.push(prices, v)
            array.push(tags, tag)

f_sort_pairs(array<float> prices, array<string> tags, bool asc) =>
    sz = array.size(prices)
    if sz > 1
        for i = 0 to sz - 2
            for j = i + 1 to sz - 1
                pi = array.get(prices, i)
                pj = array.get(prices, j)
                shouldSwap = asc ? pj < pi : pj > pi
                if shouldSwap
                    ti = array.get(tags, i)
                    tj = array.get(tags, j)
                    array.set(prices, i, pj)
                    array.set(prices, j, pi)
                    array.set(tags, i, tj)
                    array.set(tags, j, ti)

f_clusters(array<float> prices, array<string> tags, bool asc, float tol) =>
    f_sort_pairs(prices, tags, asc)
    cP = array.new_float()
    cN = array.new_int()
    cT = array.new_string()
    sz = array.size(prices)
    if sz > 0
        anchor = array.get(prices, 0)
        sum    = anchor
        cnt    = 1
        tagTxt = array.get(tags, 0)
        if sz > 1
            for i = 1 to sz - 1
                v = array.get(prices, i)
                t = array.get(tags, i)
                if math.abs(v - anchor) <= tol
                    sum += v
                    cnt += 1
                    tagTxt := f_join_tag(tagTxt, t)
                else
                    array.push(cP, sum / cnt)
                    array.push(cN, cnt)
                    array.push(cT, tagTxt)
                    anchor := v
                    sum    := v
                    cnt    := 1
                    tagTxt := t
        array.push(cP, sum / cnt)
        array.push(cN, cnt)
        array.push(cT, tagTxt)
    [cP, cN, cT]

// ===================== Auto BOS Engine =====================
autoPh = ta.pivothigh(autoLeft, autoRight)
autoPl = ta.pivotlow(autoLeft, autoRight)

var float lastStructHigh = na
var float lastStructLow  = na

if not na(autoPh)
    lastStructHigh := autoPh

if not na(autoPl)
    lastStructLow := autoPl

canAutoLong  = autoBias == "Both" or autoBias == "Long Only"
canAutoShort = autoBias == "Both" or autoBias == "Short Only"

structureRange = not na(lastStructHigh) and not na(lastStructLow) ? math.abs(lastStructHigh - lastStructLow) : na
structureRangePct = not na(structureRange) and close > 0 ? structureRange / close * 100.0 : na
structureRangeOk = not na(structureRangePct) and structureRangePct >= minStructureRangePct

longBreakDistOk  = not na(lastStructHigh) and (maxBreakoutPct == 0.0 or ((close - lastStructHigh) / lastStructHigh * 100.0) <= maxBreakoutPct)
shortBreakDistOk = not na(lastStructLow) and (maxBreakoutPct == 0.0 or ((lastStructLow - close) / lastStructLow * 100.0) <= maxBreakoutPct)

longCandleOk  = not requireCandleConfirm or close > open
shortCandleOk = not requireCandleConfirm or close < open

recentLongStopBase = ta.lowest(low, autoStopLookback)
recentShortStopBase = ta.highest(high, autoStopLookback)

longStopBase = autoStopStyle == "Recent Pullback" ? recentLongStopBase : lastStructLow
shortStopBase = autoStopStyle == "Recent Pullback" ? recentShortStopBase : lastStructHigh

longSetupStop = not na(longStopBase) ? longStopBase * (1.0 - autoStopBufferPct / 100.0) : na
shortSetupStop = not na(shortStopBase) ? shortStopBase * (1.0 + autoStopBufferPct / 100.0) : na

longProjectedTarget = not na(lastStructHigh) and not na(lastStructLow) ? lastStructLow + structureRange * fibM2 : na
shortProjectedTarget = not na(lastStructHigh) and not na(lastStructLow) ? lastStructHigh - structureRange * fibM2 : na

longSetupRisk = not na(longSetupStop) ? close - longSetupStop : na
shortSetupRisk = not na(shortSetupStop) ? shortSetupStop - close : na

longSetupReward = not na(longProjectedTarget) ? longProjectedTarget - close : na
shortSetupReward = not na(shortProjectedTarget) ? close - shortProjectedTarget : na

longSetupRR = not na(longSetupRisk) and longSetupRisk > 0 and not na(longSetupReward) and longSetupReward > 0 ? longSetupReward / longSetupRisk : na
shortSetupRR = not na(shortSetupRisk) and shortSetupRisk > 0 and not na(shortSetupReward) and shortSetupReward > 0 ? shortSetupReward / shortSetupRisk : na

longRROk = not useAutoRRFilter or (not na(longSetupRR) and longSetupRR >= minAutoRR)
shortRROk = not useAutoRRFilter or (not na(shortSetupRR) and shortSetupRR >= minAutoRR)

rawLongSignal = entryLogic == "Auto BOS" and canAutoLong and structureRangeOk and longRROk and not na(lastStructHigh) and not na(lastStructLow) and close > lastStructHigh and close[1] <= lastStructHigh and longBreakDistOk and longCandleOk
rawShortSignal = entryLogic == "Auto BOS" and canAutoShort and structureRangeOk and shortRROk and not na(lastStructHigh) and not na(lastStructLow) and close < lastStructLow and close[1] >= lastStructLow and shortBreakDistOk and shortCandleOk

var float autoEntry = na
var float autoStop  = na
var int   autoDir   = 0
var int   autoEntryBar = na
var string autoReason = "Waiting for BOS setup"

canReplaceLong = not oneSetupAtATime or autoDir == 0 or autoDir == -1
canReplaceShort = not oneSetupAtATime or autoDir == 0 or autoDir == 1

autoConfirmOk = not lockAutoOnClose or barstate.isconfirmed

longSignal = rawLongSignal and canReplaceLong and autoConfirmOk
shortSignal = rawShortSignal and canReplaceShort and autoConfirmOk

if longSignal
    autoEntry    := close
    autoStop     := longSetupStop
    autoDir      := 1
    autoEntryBar := bar_index
    autoReason   := "Bullish BOS" + (not na(longSetupRR) ? " | RR " + str.tostring(longSetupRR, "#.##") : "")

if shortSignal
    autoEntry    := close
    autoStop     := shortSetupStop
    autoDir      := -1
    autoEntryBar := bar_index
    autoReason   := "Bearish BOS" + (not na(shortSetupRR) ? " | RR " + str.tostring(shortSetupRR, "#.##") : "")

plotshape(showAutoSignals and longSignal, title = "Auto Long BOS", style = shape.triangleup, location = location.belowbar, color = color.rgb(46, 204, 113), text = "BOS\nLONG", textcolor = color.white, size = size.small)
plotshape(showAutoSignals and shortSignal, title = "Auto Short BOS", style = shape.triangledown, location = location.abovebar, color = color.rgb(231, 76, 60), text = "BOS\nSHORT", textcolor = color.white, size = size.small)

// ===================== Manual Stop Calculations =====================
manualIsLong  = manualDir == "Long"
manualEntryOk = manualEntry > 0
manualEntryVal = manualEntryOk ? manualEntry : na

atr      = ta.atr(atrLen)
swLowStp = ta.lowest(low, swingLenStop)
swHiStp  = ta.highest(high, swingLenStop)

manualStopCalc = switch stopMode
    "Swing Structure" => manualIsLong ? swLowStp : swHiStp
    "ATR"             => manualEntryOk ? (manualIsLong ? manualEntryVal - atrMult * atr : manualEntryVal + atrMult * atr) : na
    "Percent"         => manualEntryOk ? (manualIsLong ? manualEntryVal * (1.0 - stopPct / 100.0) : manualEntryVal * (1.0 + stopPct / 100.0)) : na
    => manualStop > 0 ? manualStop : na

// ===================== Active Trade Plan =====================
isAutoMode = entryLogic == "Auto BOS"

activeDir = isAutoMode ? autoDir : (manualIsLong ? 1 : -1)
isLong    = activeDir == 1

entry = isAutoMode ? autoEntry : manualEntryVal
stop  = isAutoMode ? autoStop : manualStopCalc

hasEntry = not na(entry) and activeDir != 0

validSetup  = hasEntry and not na(stop) and (isLong ? stop < entry : stop > entry)
stopDist    = validSetup ? math.abs(entry - stop) : na
stopPctReal = validSetup and entry != 0 ? stopDist / entry * 100.0 : na

riskAmount  = accountSize * riskPct / 100.0
posRaw      = validSetup and stopDist > 0 ? riskAmount / stopDist : na
posSize     = validSetup ? (wholeUnits ? math.floor(posRaw) : posRaw) : na
riskReal    = validSetup ? posSize * stopDist : na
posValue    = validSetup ? posSize * entry : na
exposurePct = validSetup and accountSize > 0 ? posValue / accountSize * 100.0 : na

unitName = switch instrument
    "Stocks / Shares" => "shares"
    "Forex / Units"   => "units"
    => "coins"

// ===================== Target Source Data =====================
ph = ta.pivothigh(pivLeft, pivRight)
pl = ta.pivotlow(pivLeft, pivRight)

var array<float> phArr = array.new_float()
var array<float> plArr = array.new_float()
var array<float> liqHi = array.new_float()
var array<float> liqLo = array.new_float()

liqTol = math.max(close * liqTolPct / 100.0, syminfo.mintick)

if not na(ph)
    if array.size(phArr) > 0
        prevPh = array.get(phArr, array.size(phArr) - 1)
        if math.abs(ph - prevPh) <= liqTol
            array.push(liqHi, (ph + prevPh) / 2.0)
            if array.size(liqHi) > 60
                array.shift(liqHi)
    array.push(phArr, ph)
    if array.size(phArr) > 150
        array.shift(phArr)

if not na(pl)
    if array.size(plArr) > 0
        prevPl = array.get(plArr, array.size(plArr) - 1)
        if math.abs(pl - prevPl) <= liqTol
            array.push(liqLo, (pl + prevPl) / 2.0)
            if array.size(liqLo) > 60
                array.shift(liqLo)
    array.push(plArr, pl)
    if array.size(plArr) > 150
        array.shift(plArr)

fibHi  = ta.highest(high, fibLook)
fibLo  = ta.lowest(low, fibLook)
fibRng = fibHi - fibLo

// ===================== Drawing Containers =====================
var line  lnEntry = na
var line  lnStop  = na
var label lbEntry = na
var label lbStop  = na
var array<line>  tLines = array.new_line()
var array<label> tLabs  = array.new_label()

var float lvlStop = na
var float lvlT1   = na
var float lvlT2   = na
var float lvlT3   = na
var float maxR    = na

var table dash = table.new(position.top_right, 2, 18)

// ===================== Last Bar Logic =====================
if barstate.islast
    cands = array.new_float()
    cTags = array.new_string()

    if validSetup
        if useRMult
            if rr1 > 0
                f_add(cands, cTags, isLong ? entry + rr1 * stopDist : entry - rr1 * stopDist, "R " + str.tostring(rr1, "#.##") + "R", isLong, entry)
            if rr2 > 0
                f_add(cands, cTags, isLong ? entry + rr2 * stopDist : entry - rr2 * stopDist, "R " + str.tostring(rr2, "#.##") + "R", isLong, entry)
            if rr3 > 0
                f_add(cands, cTags, isLong ? entry + rr3 * stopDist : entry - rr3 * stopDist, "R " + str.tostring(rr3, "#.##") + "R", isLong, entry)

        if useManual
            f_add(cands, cTags, man1, "Manual", isLong, entry)
            f_add(cands, cTags, man2, "Manual", isLong, entry)
            f_add(cands, cTags, man3, "Manual", isLong, entry)

        if useFib and fibRng > 0
            fibT1 = isLong ? fibLo + fibRng * fibM1 : fibHi - fibRng * fibM1
            fibT2 = isLong ? fibLo + fibRng * fibM2 : fibHi - fibRng * fibM2
            fibT3 = isLong ? fibLo + fibRng * fibM3 : fibHi - fibRng * fibM3

            f_add(cands, cTags, fibT1, f_fib_label(fibM1), isLong, entry)
            f_add(cands, cTags, fibT2, f_fib_label(fibM2), isLong, entry)
            f_add(cands, cTags, fibT3, f_fib_label(fibM3), isLong, entry)

        if useSwing
            srcSwing = isLong ? phArr : plArr
            if array.size(srcSwing) > 0
                for i = 0 to array.size(srcSwing) - 1
                    f_add(cands, cTags, array.get(srcSwing, i), "Swing", isLong, entry)

        if useLiq
            srcLiq = isLong ? liqHi : liqLo
            if array.size(srcLiq) > 0
                for i = 0 to array.size(srcLiq) - 1
                    f_add(cands, cTags, array.get(srcLiq, i), "Liquidity", isLong, entry)

    tolP = validSetup ? math.max(entry * confTolPct / 100.0, syminfo.mintick) : syminfo.mintick
    [cP, cN, cMethod] = f_clusters(cands, cTags, isLong, tolP)
    targetsEnabled = useSwing or useFib or useLiq or useRMult or useManual
    nTgt = targetsEnabled ? math.min(3, array.size(cP)) : 0

    lvlStop := validSetup ? stop : na
    lvlT1   := nTgt > 0 ? array.get(cP, 0) : na
    lvlT2   := nTgt > 1 ? array.get(cP, 1) : na
    lvlT3   := nTgt > 2 ? array.get(cP, 2) : na
    maxR    := nTgt > 0 and validSetup and stopDist > 0 ? math.abs(array.get(cP, nTgt - 1) - entry) / stopDist : na

    if not na(lnEntry)
        line.delete(lnEntry)
        lnEntry := na

    if not na(lnStop)
        line.delete(lnStop)
        lnStop := na

    if not na(lbEntry)
        label.delete(lbEntry)
        lbEntry := na

    if not na(lbStop)
        label.delete(lbStop)
        lbStop := na

    while array.size(tLines) > 0
        oldLine = array.pop(tLines)
        if not na(oldLine)
            line.delete(oldLine)

    while array.size(tLabs) > 0
        oldLabel = array.pop(tLabs)
        if not na(oldLabel)
            label.delete(oldLabel)

    x1 = isAutoMode and not na(autoEntryBar) ? autoEntryBar : bar_index
    x2 = bar_index + lineLen

    entryCol      = color.rgb(64, 196, 255)
    stopCol       = color.rgb(255, 95, 109)
    targetCol     = color.rgb(54, 215, 183)
    confTargetCol = color.rgb(255, 184, 77)
    chartLabelSize = f_label_size(labelSizeOpt)

    if showEntryStopLines and validSetup
        lnEntry := line.new(x1, entry, x2, entry, color = entryCol, width = 2)
        lnStop  := line.new(x1, stop, x2, stop, color = stopCol, width = 2, style = line.style_dashed)

        entryLabelText = isAutoMode ? "AUTO ENTRY " : "PLANNED ENTRY "
        lbEntry := label.new(x2, entry, entryLabelText + f_price(entry), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(entryLabelBg, labelBgTransp), textcolor = entryLabelTextColor, size = chartLabelSize)
        lbStop  := label.new(x2, stop, "STOP " + f_price(stop) + "  (-" + str.tostring(stopPctReal, "#.##") + "%)", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(stopLabelBg, labelBgTransp), textcolor = stopLabelTextColor, size = chartLabelSize)

    if showTargetLines and validSetup and targetsEnabled and nTgt > 0
        for i = 0 to nTgt - 1
            tp        = array.get(cP, i)
            cnt       = array.get(cN, i)
            methodTxt = array.get(cMethod, i)
            rMul      = stopDist > 0 ? math.abs(tp - entry) / stopDist : 0.0
            conf      = cnt >= 2
            col       = conf ? confTargetCol : targetCol

            txt = "T" + str.tostring(i + 1) + " " + f_price(tp) + "  (" + str.tostring(rMul, "#.##") + "R, +" + f_money(posSize * math.abs(tp - entry)) + ")  " + methodTxt + (conf ? "  [CONF x" + str.tostring(cnt) + "]" : "")

            ln = line.new(x1, tp, x2, tp, color = col, width = conf ? 2 : 1, style = line.style_dotted)
            lbBg = conf ? confLabelBg : targetLabelBg
            lbTextCol = conf ? confLabelTextColor : targetLabelTextColor
            lb = label.new(x2, tp, txt, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(lbBg, labelBgTransp), textcolor = lbTextCol, size = chartLabelSize)

            array.push(tLines, ln)
            array.push(tLabs, lb)

    if showDashboard
        // ===================== Dashboard Theme =====================
        color panelBgA   = na
        color panelBgB   = na
        color labelCol   = na
        color valueCol   = na
        color headerLeft = na
        color longBg     = na
        color shortBg    = na
        color accentCol  = na

        if dashTheme == "Luxury Dark"
            panelBgA   := color.rgb(20, 24, 31)
            panelBgB   := color.rgb(27, 32, 41)
            labelCol   := color.rgb(182, 189, 202)
            valueCol   := color.rgb(245, 247, 250)
            headerLeft := color.rgb(102, 126, 234)
            longBg     := color.rgb(46, 168, 106)
            shortBg    := color.rgb(202, 76, 92)
            accentCol  := color.rgb(242, 189, 77)
        else if dashTheme == "Midnight Blue"
            panelBgA   := color.rgb(13, 23, 38)
            panelBgB   := color.rgb(18, 31, 50)
            labelCol   := color.rgb(177, 194, 214)
            valueCol   := color.rgb(240, 245, 252)
            headerLeft := color.rgb(56, 102, 189)
            longBg     := color.rgb(24, 153, 125)
            shortBg    := color.rgb(204, 70, 90)
            accentCol  := color.rgb(255, 194, 87)
        else if dashTheme == "Graphite Gold"
            panelBgA   := color.rgb(24, 24, 24)
            panelBgB   := color.rgb(32, 32, 32)
            labelCol   := color.rgb(198, 192, 176)
            valueCol   := color.rgb(247, 244, 236)
            headerLeft := color.rgb(111, 86, 56)
            longBg     := color.rgb(52, 140, 94)
            shortBg    := color.rgb(171, 74, 74)
            accentCol  := color.rgb(215, 175, 96)
        else
            panelBgA   := color.rgb(28, 30, 35)
            panelBgB   := color.rgb(36, 39, 45)
            labelCol   := color.rgb(185, 190, 198)
            valueCol   := color.rgb(238, 240, 243)
            headerLeft := color.rgb(79, 102, 165)
            longBg     := color.rgb(42, 155, 88)
            shortBg    := color.rgb(194, 74, 74)
            accentCol  := color.rgb(235, 181, 72)

        tPos = switch tblPos
            "Top Right"    => position.top_right
            "Top Left"     => position.top_left
            "Bottom Right" => position.bottom_right
            "Bottom Left"  => position.bottom_left
            => position.middle_right

        tSize = switch tblSize
            "Tiny"  => size.tiny
            "Small" => size.small
            "Large" => size.large
            => size.normal

        table.set_position(dash, tPos)

        dirTitle = isAutoMode and autoDir == 0 ? "WAIT" : isLong ? "LONG" : "SHORT"
        dirColor = isAutoMode and autoDir == 0 ? accentCol : isLong ? longBg : shortBg

        riskCol        = riskPct > 3 ? color.rgb(255, 183, 77) : valueCol
        riskAmtCol     = color.rgb(255, 176, 64)
        entryValCol    = entryCol
        stopValCol     = stopCol
        posSizeCol     = color.rgb(90, 227, 134)
        posValueCol    = not na(posValue) and posValue > accountSize ? color.rgb(255, 150, 150) : valueCol
        exposureCol    = not na(exposurePct) and exposurePct > 100 ? color.rgb(255, 110, 110) : not na(exposurePct) and exposurePct > 50 ? color.rgb(255, 196, 87) : valueCol
        rrCol          = not na(maxR) and maxR >= 2 ? color.rgb(111, 245, 111) : not na(maxR) and maxR >= 1 ? color.rgb(255, 214, 102) : color.rgb(165, 170, 180)
        targetsFromCol = accentCol

        enabledStr = (useSwing ? "SW " : "") + (useFib ? "FIB " : "") + (useLiq ? "LIQ " : "") + (useRMult ? "R " : "") + (useManual ? "MAN " : "")
        if enabledStr == ""
            enabledStr := "NONE"

        setupText  = isAutoMode ? "Auto BOS" : "Manual Plan"
        reasonText = isAutoMode ? autoReason : "User-defined plan"

        status = isAutoMode and not hasEntry ? "Waiting for BOS setup" : not hasEntry ? "Set manual entry price" : not validSetup ? "Invalid stop placement" : nTgt == 0 ? "No targets - enable method" : exposurePct > 100 ? "Leverage > 100%" : riskPct > 3 ? "High risk per trade" : "OK to plan"

        statusCol = isAutoMode and not hasEntry ? color.rgb(255, 214, 102) : not hasEntry ? color.rgb(255, 214, 102) : not validSetup ? color.rgb(255, 110, 110) : exposurePct > 100 ? color.rgb(255, 110, 110) : riskPct > 3 ? color.rgb(255, 196, 87) : nTgt == 0 ? color.rgb(255, 214, 102) : color.rgb(112, 230, 161)
        statusBg  = color.new(statusCol, 82)

        table.cell(dash, 0, 0, "SMART RISK MANAGER", text_color = color.white, bgcolor = headerLeft, text_size = tSize, text_halign = text.align_center)
        table.cell(dash, 1, 0, dirTitle, text_color = color.white, bgcolor = dirColor, text_size = tSize, text_halign = text.align_center)

        table.cell(dash, 0, 1, "Account", text_color = labelCol, bgcolor = f_row_bg(1, panelBgA, panelBgB, zebraRows), text_size = tSize, text_halign = text.align_left)
        table.cell(dash, 1, 1, f_money(accountSize), text_color = valueCol, bgcolor = f_row_bg(1, panelBgA, panelBgB, zebraRows), text_size = tSize)

        table.cell(dash, 0, 2, "Risk %", text_color = labelCol, bgcolor = f_row_bg(2, panelBgA, panelBgB, zebraRows), text_size = tSize, text_halign = text.align_left)
        table.cell(dash, 1, 2, str.tostring(riskPct, "#.##") + " %", text_color = riskCol, bgcolor = f_row_bg(2, panelBgA, panelBgB, zebraRows), text_size = tSize)

        table.cell(dash, 0, 3, "Risk Amount", text_color = labelCol, bgcolor = f_row_bg(3, panelBgA, panelBgB, zebraRows), text_size = tSize, text_halign = text.align_left)
        table.cell(dash, 1, 3, f_money(riskReal), text_color = riskAmtCol, bgcolor = f_row_bg(3, panelBgA, panelBgB, zebraRows), text_size = tSize)

        table.cell(dash, 0, 4, "Entry", text_color = labelCol, bgcolor = f_row_bg(4, panelBgA, panelBgB, zebraRows), text_size = tSize, text_halign = text.align_left)
        table.cell(dash, 1, 4, f_price(entry), text_color = entryValCol, bgcolor = f_row_bg(4, panelBgA, panelBgB, zebraRows), text_size = tSize)

        table.cell(dash, 0, 5, "Stop", text_color = labelCol, bgcolor = f_row_bg(5, panelBgA, panelBgB, zebraRows), text_size = tSize, text_halign = text.align_left)
        table.cell(dash, 1, 5, validSetup ? f_price(stop) : "-", text_color = validSetup ? stopValCol : color.rgb(255, 214, 102), bgcolor = f_row_bg(5, panelBgA, panelBgB, zebraRows), text_size = tSize)

        table.cell(dash, 0, 6, "Stop Distance", text_color = labelCol, bgcolor = f_row_bg(6, panelBgA, panelBgB, zebraRows), text_size = tSize, text_halign = text.align_left)
        table.cell(dash, 1, 6, validSetup ? f_price(stopDist) + "  (" + str.tostring(stopPctReal, "#.##") + "%)" : "-", text_color = valueCol, bgcolor = f_row_bg(6, panelBgA, panelBgB, zebraRows), text_size = tSize)

        table.cell(dash, 0, 7, "Position Size", text_color = labelCol, bgcolor = f_row_bg(7, panelBgA, panelBgB, zebraRows), text_size = tSize, text_halign = text.align_left)
        table.cell(dash, 1, 7, validSetup ? f_money(posSize) + " " + unitName : "-", text_color = posSizeCol, bgcolor = f_row_bg(7, panelBgA, panelBgB, zebraRows), text_size = tSize)

        table.cell(dash, 0, 8, "Position Value", text_color = labelCol, bgcolor = f_row_bg(8, panelBgA, panelBgB, zebraRows), text_size = tSize, text_halign = text.align_left)
        table.cell(dash, 1, 8, f_money(posValue), text_color = posValueCol, bgcolor = f_row_bg(8, panelBgA, panelBgB, zebraRows), text_size = tSize)

        table.cell(dash, 0, 9, "Exposure", text_color = labelCol, bgcolor = f_row_bg(9, panelBgA, panelBgB, zebraRows), text_size = tSize, text_halign = text.align_left)
        table.cell(dash, 1, 9, validSetup ? str.tostring(exposurePct, "#.##") + " %" : "-", text_color = exposureCol, bgcolor = f_row_bg(9, panelBgA, panelBgB, zebraRows), text_size = tSize)

        table.cell(dash, 0, 10, "Risk : Reward", text_color = labelCol, bgcolor = f_row_bg(10, panelBgA, panelBgB, zebraRows), text_size = tSize, text_halign = text.align_left)
        rrTxt = nTgt > 0 and not na(maxR) ? "1 : " + str.tostring(maxR, "#.##") : "-"
        table.cell(dash, 1, 10, rrTxt, text_color = rrCol, bgcolor = f_row_bg(10, panelBgA, panelBgB, zebraRows), text_size = tSize)

        table.cell(dash, 0, 11, "Setup Logic", text_color = labelCol, bgcolor = f_row_bg(11, panelBgA, panelBgB, zebraRows), text_size = tSize, text_halign = text.align_left)
        table.cell(dash, 1, 11, setupText, text_color = targetsFromCol, bgcolor = f_row_bg(11, panelBgA, panelBgB, zebraRows), text_size = tSize)

        table.cell(dash, 0, 12, "Reason", text_color = labelCol, bgcolor = f_row_bg(12, panelBgA, panelBgB, zebraRows), text_size = tSize, text_halign = text.align_left)
        table.cell(dash, 1, 12, reasonText, text_color = valueCol, bgcolor = f_row_bg(12, panelBgA, panelBgB, zebraRows), text_size = tSize)

        table.cell(dash, 0, 13, "Targets From", text_color = labelCol, bgcolor = f_row_bg(13, panelBgA, panelBgB, zebraRows), text_size = tSize, text_halign = text.align_left)
        table.cell(dash, 1, 13, enabledStr, text_color = targetsFromCol, bgcolor = f_row_bg(13, panelBgA, panelBgB, zebraRows), text_size = tSize)

        for r = 0 to 2
            rowTxt = "-"
            rowCol = color.rgb(145, 152, 165)
            rowIndex = 14 + r
            rowBg = f_row_bg(rowIndex, panelBgA, panelBgB, zebraRows)

            if r < nTgt
                tp        = array.get(cP, r)
                cnt       = array.get(cN, r)
                methodTxt = array.get(cMethod, r)
                rMul      = stopDist > 0 ? math.abs(tp - entry) / stopDist : 0.0
                conf      = cnt >= 2

                rowTxt := f_price(tp) + "  " + str.tostring(rMul, "#.##") + "R  " + methodTxt + (conf ? "  *x" + str.tostring(cnt) : "")
                rowCol := conf ? confTargetCol : targetCol

            table.cell(dash, 0, rowIndex, "T" + str.tostring(r + 1), text_color = labelCol, bgcolor = rowBg, text_size = tSize, text_halign = text.align_left)
            table.cell(dash, 1, rowIndex, rowTxt, text_color = rowCol, bgcolor = rowBg, text_size = tSize)

        table.cell(dash, 0, 17, "Status", text_color = labelCol, bgcolor = f_row_bg(17, panelBgA, panelBgB, zebraRows), text_size = tSize, text_halign = text.align_left)
        table.cell(dash, 1, 17, status, text_color = statusCol, bgcolor = statusBg, text_size = tSize)

// ===================== Alerts =====================
stopHit = not na(lvlStop) and (isLong ? low <= lvlStop : high >= lvlStop)
t1Hit   = not na(lvlT1) and (isLong ? high >= lvlT1 : low <= lvlT1)
t2Hit   = not na(lvlT2) and (isLong ? high >= lvlT2 : low <= lvlT2)
t3Hit   = not na(lvlT3) and (isLong ? high >= lvlT3 : low <= lvlT3)

alertcondition(longSignal, title = "Auto Long BOS", message = "Smart Risk Mgr: Bullish BOS auto setup detected")
alertcondition(shortSignal, title = "Auto Short BOS", message = "Smart Risk Mgr: Bearish BOS auto setup detected")
alertcondition(stopHit, title = "STOP hit", message = "Smart Risk Mgr: price reached the STOP level")
alertcondition(t1Hit, title = "Target 1 reached", message = "Smart Risk Mgr: price reached Target 1")
alertcondition(t2Hit, title = "Target 2 reached", message = "Smart Risk Mgr: price reached Target 2")
alertcondition(t3Hit, title = "Target 3 reached", message = "Smart Risk Mgr: price reached Target 3")
````
