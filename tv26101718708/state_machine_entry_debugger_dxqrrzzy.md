# State Machine Entry Debugger

- url: https://www.tradingview.com/script/dXqRRzZy-State-Machine-Entry-Debugger/
- type: indicator
- pine_id: PUB;1e9dc8d17dbe49d8a8b392fe279c9ab9
- version: 1.0

## Description

[b]State Machine Entry Debugger - CoffeeKiller[/b]

State Machine Entry Debugger - CoffeeKiller is a development and diagnostic indicator designed to make a strategy's long-entry process visible on the chart.

Many strategies do not enter immediately when one condition becomes true. Instead, they move through a sequence of internal states. That sequence may include detecting a setup area, validating filters, waiting for confirmation, checking execution permission, and finally producing an entry signal.

These internal stages are normally invisible. A developer may see only the final strategy order and assume the entry was delayed without knowing which part of the logic caused the delay.

This indicator turns that hidden process into a visible chart timeline.

[b]Important[/b]

This is not a standalone trading system.

The included EMA, ATR, pullback, and breakout conditions are placeholders used only to demonstrate how the debugger operates. They are not intended as production trading signals.

The current example is designed for long-entry debugging only. It does not contain a separate short-side state machine.

[b]Entry Sequence[/b]

The debugger tracks the following sequence:

[quote]
Touch -> ARM -> Trigger -> Entry Signal -> Reset
[/quote]

[b]Touch[/b]

Price reaches or interacts with the defined setup area.

[b]ARM[/b]

The setup passes its required filters and becomes eligible to wait for a trigger.

[b]Trigger[/b]

The strategy's confirmation condition becomes true.

[b]Entry Signal[/b]

All setup, filter, trigger, and final permission requirements have passed.

[b]Reset[/b]

The example state machine returns to its idle state and waits for another setup.

[b]Why This Tool Exists[/b]

A strategy may appear to enter late for several different reasons:

[list]
[*]A setup filter remained false.
[*]The trigger occurred several bars after the initial touch.
[*]The setup expired before confirmation.
[*]Entry permission blocked execution.
[*]The state machine required each stage to begin on a separate bar.
[*]The strategy waited for the candle to close.
[*]The debugger and strategy used different realtime calculation behavior.
[*]The strategy created an order on one bar but filled it on the next.
[*]Reset or cancellation logic removed the setup.
[/list]

Without a debugger, these situations may all appear to be the same problem: a late entry.

This script separates those possibilities.

[b]Confirmed-Bar State Transitions[/b]

The state machine advances only when the candle is confirmed:

[pine]
barstate.isconfirmed
[/pine]

This means a state transition is committed only after the candle closes.

This behavior is intended to match strategies that evaluate their entry logic at bar close.

Without confirmed-bar gating, a condition may temporarily become true while the realtime candle is forming. Touch, ARM, Trigger, or Entry labels could then appear, disappear, or move before the candle closes.

That can make an indicator appear to react earlier than the strategy it is supposed to diagnose.

By waiting for candle confirmation, the debugger provides a more consistent comparison with bar-close strategy logic.

A strategy that intentionally calculates intrabar requires a debugger configured to reproduce its execution behavior.

Relevant strategy settings and behaviors may include:

[list]
[*]calc_on_every_tick
[*]calc_on_order_fills
[*]process_orders_on_close
[*]Wick-based versus close-based confirmation
[*]Higher-timeframe data behavior
[*]Session filters
[*]Time filters
[/list]

The debugger and the strategy must use equivalent assumptions before their results can be compared accurately.

[b]Entry Signal Versus Strategy Fill[/b]

The green Entry Signal marker identifies the bar where the state machine determines that all entry requirements have passed.

It does not necessarily represent the strategy broker emulator's actual fill bar or fill price.

Under the normal strategy execution model, an order created after a bar closes is generally filled at the next available tick. For a bar-close strategy, that commonly means the open of the next bar.

The chart may therefore show:

[quote]
Debugger Entry Signal on the current bar

Strategy fill on the next bar
[/quote]

That one-bar difference is not automatically a bug.

A strategy using the following setting may instead process an order at the close of the signal bar:

[pine]
process_orders_on_close=true
[/pine]

When comparing the debugger with a strategy, determine whether you are comparing:

[list]
[*]The signal bar
[*]The order-creation bar
[*]The broker-emulator fill bar
[*]The recorded fill price
[/list]

These events are related, but they are not always identical.

[b]One Transition Per Bar[/b]

The example state machine intentionally allows only one transition per confirmed bar.

A completed sequence may therefore appear as:

[list=1]
[*]Bar 1: Touch
[*]Bar 2: ARM
[*]Bar 3: Trigger
[*]Bar 4: Entry Signal
[/list]

This occurs because the transition logic uses an if / else if structure.

Even when several conditions are already true, the state machine cannot move through multiple stages during the same bar. It must begin the bar in the required prior state before it can advance.

This behavior is useful for exposing structural delays.

For example, the market may satisfy the setup filters and breakout condition on the same candle, but the state machine may still require separate bars for Touch, ARM, Trigger, and Entry Signal.

In that situation, the apparent delay is caused by the state-machine architecture rather than by the market conditions.

This design is intentional for debugging purposes.

A strategy that permits multiple transitions on the same bar requires a different transition structure.

[b]What the Debugger Displays[/b]

The script can display event labels for:

[list]
[*]Touch
[*]ARM
[*]Trigger
[*]Entry Signal
[*]Touch expiration
[*]ARM expiration
[*]State reset
[/list]

It can also display blocked-condition labels for:

[list]
[*]Trend filter
[*]Quality filter
[*]Extension filter
[*]Trigger condition
[*]Entry permission
[/list]

A blocked label identifies the first condition preventing the current state from advancing on a confirmed bar.

A blocked condition does not automatically mean the strategy is malfunctioning.

For example, while an armed setup is waiting for confirmation, the trigger condition should normally remain false. A Waiting Trigger label may simply indicate that the state machine is operating as designed.

[b]Timeline Measurements[/b]

The debugger measures the number of confirmed bars between the major state transitions:

[list]
[*]Touch to ARM
[*]ARM to Trigger
[*]Trigger to Entry Signal
[*]Touch to Entry Signal
[/list]

These measurements help distinguish between:

[list]
[*]Filter delay
[*]Trigger delay
[*]Permission delay
[*]State-sequencing delay
[*]Timeout behavior
[/list]

The debugger also tracks:

[list]
[*]Bars since Touch
[*]Bars since ARM
[*]Bars since Trigger
[/list]

[b]State Background[/b]

Optional chart-background colors show the current internal state:

[list]
[*]Blue: Touched
[*]Orange: Armed
[*]Purple: Triggered
[*]Green: Entry Signal reached
[*]No background: Idle
[/list]

The green state represents the debugger's logical Entry Signal state. It should not automatically be interpreted as the strategy's broker-emulator fill.

[b]Debug Table[/b]

The on-chart table shows the latest state and condition information, including:

[list]
[*]Current state
[*]Last event
[*]Last blocking condition
[*]Touch condition
[*]Trend filter
[*]Quality filter
[*]Extension filter
[*]Trigger condition
[*]Entry permission
[*]Bars since Touch
[*]Bars since ARM
[*]Bars since Trigger
[*]ATR extension distance
[*]Confirmed-bar status
[*]Realtime-bar status
[*]Current bar index
[/list]

Conditions are displayed as PASS or FAIL.

A FAIL value means only that the condition is currently false. Whether that is expected depends on the current state.

The table displays condition values for the latest chart bar. On a forming realtime candle, those values may continue to change, but the state machine will not advance until the candle closes.

[b]Data Window Values[/b]

The indicator also sends its internal values to the TradingView Data Window.

This allows developers to inspect individual historical bars and compare the debugger with the original strategy.

Available values include:

[list]
[*]State number
[*]Touch condition
[*]Trend filter
[*]Quality filter
[*]Extension filter
[*]Trigger condition
[*]Entry permission
[*]ATR extension distance
[*]Bars since Touch
[*]Bars since ARM
[*]Bars since Trigger
[*]Same-bar transition checks
[*]Confirmed-bar status
[*]Realtime-bar status
[/list]

Boolean values appear as:

[quote]
1 = true

0 = false
[/quote]

[b]Placeholder Logic[/b]

The included conditions exist only so the indicator can compile and demonstrate its operation.

The main placeholder variables are:

[pine]
touchCondition
trendFilter
qualityFilter
extensionFilter
triggerCondition
entryPermission
[/pine]

Replace these variables with the exact conditions from the strategy being diagnosed.

For an accurate comparison, developers should also reproduce the strategy's:

[list]
[*]Price sources
[*]Wick or close confirmation rules
[*]Session restrictions
[*]Time restrictions
[*]Higher-timeframe requests
[*]Position-state restrictions
[*]Pyramiding behavior
[*]Cooldown rules
[*]Cancellation logic
[*]Rearm logic
[*]Order-processing settings
[/list]

[b]Suggested Implementation Process[/b]

Start with a duplicate of the strategy you want to diagnose.

Assign the condition that begins the setup to:

[pine]
touchCondition
[/pine]

Assign the setup-validation requirements to:

[pine]
trendFilter
qualityFilter
extensionFilter
[/pine]

Assign the actual confirmation event to:

[pine]
triggerCondition
[/pine]

Assign final execution restrictions to:

[pine]
entryPermission
[/pine]

Then compare the debugger's Touch, ARM, Trigger, and Entry Signal markers with the strategy's signal condition, order creation, order marker, and broker-emulator fill.

Do not assume that the debugger's Entry Signal and the strategy's fill marker should always appear on the same bar.

[b]Recommended Debugging Method[/b]

First reproduce the strategy's existing behavior exactly.

Do not begin by removing filters or forcing earlier entries.

Once the debugger and strategy agree, change one part of the logic at a time.

This helps determine whether an entry delay comes from:

[list]
[*]The market setup
[*]A filter
[*]The trigger
[*]Entry permission
[*]A timeout
[*]State sequencing
[*]Bar-close confirmation
[*]Intrabar calculation
[*]Order-fill timing
[*]Reset or cancellation behavior
[/list]

The goal is not simply to make the strategy enter earlier.

The goal is to understand why it entered when it did.

[b]Current Design Limitations[/b]

This version uses long-side placeholder logic.

It does not contain an independent short-side state machine.

Although the placeholder conditions can be replaced with bearish conditions, a complete two-direction debugger should normally use independent long and short state machines. This prevents one direction's setup from overwriting or blocking the other direction's state.

The example resets immediately after reaching the Entry Signal state.

A production strategy should replace that behavior with its actual:

[list]
[*]Position-entry handling
[*]Exit handling
[*]Setup cancellation
[*]Rearm rules
[*]Cooldown period
[*]Opposite-signal behavior
[/list]

The debugger intentionally permits only one transition per confirmed bar.

Because this script is an indicator rather than a strategy, it does not simulate:

[list]
[*]Strategy orders
[*]Position sizing
[*]Pyramiding
[*]Commissions
[*]Slippage
[*]Broker-emulator fills
[/list]

Labels may become crowded across long historical ranges. The recent-bars setting can be used to reduce chart clutter.

[b]Final Purpose[/b]

State Machine Entry Debugger converts an invisible decision process into a visible chart timeline.

Instead of seeing only the final strategy entry, developers can inspect:

[list]
[*]Where the setup began
[*]When it became armed
[*]Which condition delayed it
[*]When the trigger occurred
[*]When the logical entry signal became valid
[*]Whether the setup expired or reset
[*]Whether the apparent delay came from state logic or order-fill timing
[/list]

This makes complex state-machine behavior easier to test, explain, and improve.

[b]Disclaimer[/b]

This indicator is intended solely for educational, informational, diagnostic, and software-development purposes.

It is not a trading system and should not be interpreted as a recommendation to buy or sell any financial instrument.

The included conditions are placeholders and are not presented as a profitable or complete trading methodology.

Trading involves substantial risk of loss. Historical behavior, simulated performance, and strategy results do not guarantee future performance.

Always perform your own analysis, thoroughly test all strategy logic, account for realistic execution conditions, and consult a qualified financial professional when appropriate before risking real capital.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CoffeeKiller

//@version=6
indicator("State Machine Entry Debugger", overlay=true, max_labels_count=500)

//=============================================================================
// STATE MACHINE ENTRY DEBUGGER
//=============================================================================
//
// PURPOSE
//-----------------------------------------------------------------------------
// This indicator helps diagnose why a strategy appears to enter later than
// expected.
//
// It separates the entry process into four observable stages:
//
// 1. TOUCH
// 2. ARM
// 3. TRIGGER
// 4. ENTRY SIGNAL
//
// Each stage is intentionally limited to one transition per confirmed bar.
// This makes hidden state-machine delays easier to identify.
//
//-----------------------------------------------------------------------------
// IMPORTANT: CONFIRMED-BAR EXECUTION
//-----------------------------------------------------------------------------
// State transitions are gated by:
//
//     barstate.isconfirmed
//
// This means the debugger advances only when a candle closes.
//
// That behavior is appropriate when the strategy being diagnosed also makes
// decisions at bar close.
//
// Without this gate, conditions could become true temporarily while the live
// candle is forming. Labels, backgrounds, and state values could then appear,
// disappear, or move before the candle closes.
//
// If the strategy being diagnosed intentionally calculates intrabar, this
// debugger must be modified to reproduce that strategy's exact execution model.
//
//-----------------------------------------------------------------------------
// IMPORTANT: ENTRY SIGNAL IS NOT ALWAYS THE FILL
//-----------------------------------------------------------------------------
// The ENTRY SIGNAL marker identifies the bar where all entry requirements
// become valid.
//
// It does not necessarily represent the strategy broker emulator's fill price
// or fill bar.
//
// By default, a strategy.entry() order generated at bar close is normally
// filled at the next available tick, which is usually the next bar's open.
//
// If the strategy uses:
//
//     process_orders_on_close=true
//
// the order may instead be processed at the close of the signal bar.
//
// Therefore:
//
// ENTRY SIGNAL on this indicator
//     versus
// Strategy fill marker on the chart
//
// may show a normal one-bar difference.
//
// That offset is not necessarily a strategy bug.
//
//-----------------------------------------------------------------------------
// IMPORTANT: HISTORICAL VERSUS REALTIME RESULTS
//-----------------------------------------------------------------------------
// Historical candles are evaluated using their completed OHLC values.
//
// Realtime candles update while they are forming. Because transitions are
// confirmed-bar gated, the debugger waits until the realtime candle closes
// before committing a new state.
//
//-----------------------------------------------------------------------------
// IMPORTANT: PLACEHOLDER CONDITIONS
//-----------------------------------------------------------------------------
// Group B contains demonstration conditions only.
//
// Replace those conditions with the exact conditions used by the strategy.
//
// For accurate diagnosis, also match:
//
// • Signal source
// • Wick versus close confirmation
// • Session filters
// • Time filters
// • Higher-timeframe data
// • Entry permission rules
// • Position-state restrictions
// • Pyramiding rules
// • Strategy calculation settings
// • process_orders_on_close
// • calc_on_every_tick
// • calc_on_order_fills
//
//-----------------------------------------------------------------------------
// ONE TRANSITION PER BAR
//-----------------------------------------------------------------------------
// This debugger intentionally uses one state transition per confirmed bar.
//
// Example:
//
// Bar 1: TOUCH
// Bar 2: ARM
// Bar 3: TRIGGER
// Bar 4: ENTRY SIGNAL
//
// This exposes strategies where conditions are separated into sequential
// states and each state must already exist when the next bar begins.
//
// If the actual strategy permits multiple transitions on the same bar, this
// debugger must be adjusted to match that behavior.
//
//=============================================================================

//=============================================================================
// GROUP A — DEBUG SETTINGS
//=============================================================================

groupDebug = "A. Debug Settings"

showEventLabels = input.bool(true, "Show State Event Labels", group=groupDebug)
showBlockedLabels = input.bool(true, "Show Blocked-State Labels", group=groupDebug)
showStateBackground = input.bool(true, "Color Background by State", group=groupDebug)
showDebugTable = input.bool(true, "Show Debug Table", group=groupDebug)
showOnlyRecentBars = input.bool(true, "Limit Labels to Recent Bars", group=groupDebug)

recentBars = input.int(500, "Recent Bars to Debug", minval=50, maxval=5000, group=groupDebug)
maxBarsArmed = input.int(5, "Maximum Bars Allowed in ARM State", minval=1, group=groupDebug)
maxBarsTouched = input.int(5, "Maximum Bars Allowed After Touch", minval=1, group=groupDebug)

//=============================================================================
// GROUP B — PLACEHOLDER CONDITIONS
//=============================================================================
//
// Replace these conditions with the exact conditions from the strategy.
//
// These examples exist only so the debugger compiles and demonstrates its
// operation. They are not intended to be used as a trading system.
//
// The debugger will only be accurate when its conditions match the strategy's
// conditions and execution assumptions.
//=============================================================================

groupExample = "B. Placeholder Conditions"

fastLength = input.int(9, "Fast EMA", minval=1, group=groupExample)
slowLength = input.int(21, "Slow EMA", minval=1, group=groupExample)
breakoutLength = input.int(10, "Breakout Length", minval=1, group=groupExample)
extensionATR = input.float(1.5, "Maximum Extension ATR", minval=0.0, step=0.1, group=groupExample)

fastEMA = ta.ema(close, fastLength)
slowEMA = ta.ema(close, slowLength)
atrValue = ta.atr(14)

priorHigh = ta.highest(high, breakoutLength)[1]
pullbackLevel = fastEMA

//-----------------------------------------------------------------------------
// REPLACE THESE PLACEHOLDER CONDITIONS
//-----------------------------------------------------------------------------

bool touchCondition = low <= pullbackLevel and high >= pullbackLevel
bool trendFilter = fastEMA > slowEMA
bool qualityFilter = atrValue > 0 and math.abs(fastEMA - slowEMA) / atrValue > 0.10

float extensionDistance = atrValue > 0 ? math.abs(close - fastEMA) / atrValue : 0.0

bool extensionFilter = extensionDistance <= extensionATR
bool triggerCondition = not na(priorHigh) and close > priorHigh
bool entryPermission = true

//=============================================================================
// GROUP C — HELPER FUNCTIONS
//=============================================================================

yesNo(bool condition) =>
    condition ? "PASS" : "FAIL"

formatInteger(int value) =>
    na(value) ? "NA" : str.tostring(value)

stateToText(int stateValue) =>
    switch stateValue
        0 => "IDLE"
        1 => "TOUCHED"
        2 => "ARMED"
        3 => "TRIGGERED"
        4 => "ENTRY SIGNAL"
        => "UNKNOWN"

//=============================================================================
// GROUP D — STATE CONSTANTS
//=============================================================================

const int STATE_IDLE = 0
const int STATE_TOUCHED = 1
const int STATE_ARMED = 2
const int STATE_TRIGGERED = 3
const int STATE_ENTERED = 4

var int tradeState = STATE_IDLE

//=============================================================================
// GROUP E — PERSISTENT TIMELINE VALUES
//=============================================================================
//
// These values record the confirmed bar where each state transition occurred.
//
// entryPrice records the close of the ENTRY SIGNAL bar. It is not necessarily
// the strategy's actual broker-emulator fill price.
//=============================================================================

var int touchBar = na
var int armBar = na
var int triggerBar = na
var int entryBar = na

var float touchPrice = na
var float armPrice = na
var float triggerPrice = na
var float entryPrice = na

var string lastBlockReason = "None"
var string lastEvent = "Waiting"

//=============================================================================
// GROUP F — PER-BAR EVENT FLAGS
//=============================================================================
//
// These flags reset to false on each script execution.
//
// Because the transition engine is confirmed-bar gated, event flags become true
// only when a transition is committed at the close of a candle.
//=============================================================================

bool newTouch = false
bool newArm = false
bool newTrigger = false
bool newEntry = false

bool resetEvent = false
bool touchExpired = false
bool armExpired = false

bool trendBlocked = false
bool qualityBlocked = false
bool extensionBlocked = false
bool triggerBlocked = false
bool permissionBlocked = false

//=============================================================================
// GROUP G — BAR AGE CALCULATIONS
//=============================================================================
//
// Bar age is measured using bar_index differences.
//
// A value of zero means the event occurred on the current confirmed bar.
//=============================================================================

int barsSinceTouch = not na(touchBar) ? bar_index - touchBar : na
int barsSinceArm = not na(armBar) ? bar_index - armBar : na
int barsSinceTrigger = not na(triggerBar) ? bar_index - triggerBar : na

bool touchStillValid = not na(barsSinceTouch) and barsSinceTouch <= maxBarsTouched
bool armStillValid = not na(barsSinceArm) and barsSinceArm <= maxBarsArmed

//=============================================================================
// GROUP H — CONFIRMED-BAR STATE TRANSITION LOGIC
//=============================================================================
//
// All state changes are gated by barstate.isconfirmed.
//
// This aligns the debugger with a strategy that evaluates its entry logic at
// candle close.
//
// Only one transition is permitted per confirmed bar because the state chain
// uses if / else if.
//
// This is intentional.
//
// If the real strategy allows TOUCH, ARM, TRIGGER, and ENTRY to occur on the
// same bar, this transition structure must be changed to match it.
//=============================================================================

if barstate.isconfirmed
    if tradeState == STATE_IDLE
        if touchCondition
            tradeState := STATE_TOUCHED
            touchBar := bar_index
            touchPrice := close
            armBar := na
            triggerBar := na
            entryBar := na
            armPrice := na
            triggerPrice := na
            entryPrice := na
            newTouch := true
            lastEvent := "Touch"
            lastBlockReason := "None"

    else if tradeState == STATE_TOUCHED
        if not touchStillValid
            tradeState := STATE_IDLE
            touchExpired := true
            resetEvent := true
            lastEvent := "Touch Expired"
            lastBlockReason := "Touch expired before ARM"
        else if not trendFilter
            trendBlocked := true
            lastBlockReason := "Trend filter"
        else if not qualityFilter
            qualityBlocked := true
            lastBlockReason := "Quality filter"
        else if not extensionFilter
            extensionBlocked := true
            lastBlockReason := "Extension filter"
        else
            tradeState := STATE_ARMED
            armBar := bar_index
            armPrice := close
            newArm := true
            lastEvent := "ARM"
            lastBlockReason := "None"

    else if tradeState == STATE_ARMED
        if not armStillValid
            tradeState := STATE_IDLE
            armExpired := true
            resetEvent := true
            lastEvent := "ARM Expired"
            lastBlockReason := "ARM expired before Trigger"
        else if not triggerCondition
            triggerBlocked := true
            lastBlockReason := "Trigger condition"
        else
            tradeState := STATE_TRIGGERED
            triggerBar := bar_index
            triggerPrice := close
            newTrigger := true
            lastEvent := "Trigger"
            lastBlockReason := "None"

    else if tradeState == STATE_TRIGGERED
        if not entryPermission
            permissionBlocked := true
            lastBlockReason := "Entry permission"
        else
            tradeState := STATE_ENTERED
            entryBar := bar_index
            entryPrice := close
            newEntry := true
            lastEvent := "Entry Signal"
            lastBlockReason := "None"

    else if tradeState == STATE_ENTERED
        tradeState := STATE_IDLE
        resetEvent := true
        lastEvent := "Reset"

//=============================================================================
// GROUP I — TIMELINE MEASUREMENTS
//=============================================================================
//
// These values reveal how many confirmed bars elapsed between state changes.
//
// Because only one transition is permitted per bar, each completed transition
// will normally have a minimum delay of one bar from the prior transition.
//=============================================================================

int touchToArmBars = not na(touchBar) and not na(armBar) ? armBar - touchBar : na
int armToTriggerBars = not na(armBar) and not na(triggerBar) ? triggerBar - armBar : na
int triggerToEntryBars = not na(triggerBar) and not na(entryBar) ? entryBar - triggerBar : na
int touchToEntryBars = not na(touchBar) and not na(entryBar) ? entryBar - touchBar : na

//=============================================================================
// GROUP J — SAME-BAR TRANSITION CHECKS
//=============================================================================
//
// With the current one-transition-per-bar structure, these should remain false.
//
// They are retained as diagnostic checks in case the state-transition structure
// is later modified.
//=============================================================================

bool touchAndArmSameBar = newArm and not na(touchBar) and bar_index == touchBar
bool armAndTriggerSameBar = newTrigger and not na(armBar) and bar_index == armBar
bool triggerAndEntrySameBar = newEntry and not na(triggerBar) and bar_index == triggerBar

//=============================================================================
// GROUP K — LABEL WINDOW
//=============================================================================
//
// Limiting labels does not change the state machine.
//
// It only reduces historical chart clutter and label usage.
//=============================================================================

bool insideDebugWindow = not showOnlyRecentBars or bar_index >= last_bar_index - recentBars

//=============================================================================
// GROUP L — EVENT LABELS
//=============================================================================
//
// ENTRY SIGNAL marks the logical signal bar.
//
// It should not automatically be interpreted as the strategy's fill bar.
//=============================================================================

if showEventLabels and insideDebugWindow
    if newTouch
        label.new(bar_index, low, "TOUCH\nBar: " + str.tostring(bar_index), style=label.style_label_up, textcolor=color.white, color=color.new(color.blue, 0), size=size.tiny)
    if newArm
        label.new(bar_index, low, "ARM\nTouch delay: " + formatInteger(touchToArmBars) + " bars", style=label.style_label_up, textcolor=color.white, color=color.new(color.orange, 0), size=size.tiny)
    if newTrigger
        label.new(bar_index, high, "TRIGGER\nARM delay: " + formatInteger(armToTriggerBars) + " bars", style=label.style_label_down, textcolor=color.white, color=color.new(color.purple, 0), size=size.tiny)
    if newEntry
        label.new(bar_index, high, "ENTRY SIGNAL\nTouch → Signal: " + formatInteger(touchToEntryBars) + " bars", style=label.style_label_down, textcolor=color.white, color=color.new(color.green, 0), size=size.small)

//=============================================================================
// GROUP M — BLOCKED-CONDITION LABELS
//=============================================================================
//
// Blocked labels identify the first condition preventing the current state from
// advancing on a confirmed bar.
//
// A blocked condition does not necessarily mean the strategy is incorrect.
// It means the exact requirement was false when that candle closed.
//=============================================================================

if showBlockedLabels and insideDebugWindow
    if trendBlocked
        label.new(bar_index, high, "BLOCKED\nTrend", style=label.style_label_down, textcolor=color.white, color=color.new(color.red, 25), size=size.tiny)

    if qualityBlocked
        label.new(bar_index, high, "BLOCKED\nQuality", style=label.style_label_down, textcolor=color.white, color=color.new(color.red, 25), size=size.tiny)

    if extensionBlocked
        label.new(bar_index, high, "BLOCKED\nExtension\n" + str.tostring(extensionDistance, "#.##") + " ATR", style=label.style_label_down, textcolor=color.white, color=color.new(color.red, 25), size=size.tiny)

    if triggerBlocked
        label.new(bar_index, high, "WAITING\nTrigger", style=label.style_label_down, textcolor=color.white, color=color.new(color.gray, 35), size=size.tiny)

    if permissionBlocked
        label.new(bar_index, high, "BLOCKED\nEntry Permission", style=label.style_label_down, textcolor=color.white, color=color.new(color.red, 25), size=size.tiny)

    if touchExpired
        label.new(bar_index, high, "RESET\nTouch Expired", style=label.style_label_down, textcolor=color.white, color=color.new(color.black, 0), size=size.tiny)

    if armExpired
        label.new(bar_index, high, "RESET\nARM Expired", style=label.style_label_down, textcolor=color.white, color=color.new(color.black, 0), size=size.tiny)

//=============================================================================
// GROUP N — STATE BACKGROUND
//=============================================================================

color stateBackground =
     tradeState == STATE_IDLE ? na :
     tradeState == STATE_TOUCHED ? color.new(color.blue, 90) :
     tradeState == STATE_ARMED ? color.new(color.orange, 88) :
     tradeState == STATE_TRIGGERED ? color.new(color.purple, 88) :
     tradeState == STATE_ENTERED ? color.new(color.green, 85) :
     na

bgcolor(showStateBackground ? stateBackground : na)

//=============================================================================
// GROUP O — VISUAL PLOTS
//=============================================================================
//
// These plots are visual references only.
//
// Confirm that the plotted references exactly match the values used by the
// strategy being diagnosed.
//=============================================================================

plot(fastEMA, "Fast EMA", color=color.orange)
plot(slowEMA, "Slow EMA", color=color.blue)
plot(priorHigh, "Trigger Reference", color=color.new(color.purple, 25), style=plot.style_linebr)

plotshape(newTouch, "Touch Event", shape.circle, location.belowbar, color=color.blue, size=size.tiny, text="T", textcolor=color.white)
plotshape(newArm, "ARM Event", shape.square, location.belowbar, color=color.orange, size=size.tiny, text="A", textcolor=color.white)
plotshape(newTrigger, "Trigger Event", shape.diamond, location.abovebar, color=color.purple, size=size.tiny, text="TR", textcolor=color.white)
plotshape(newEntry, "Entry Signal Event", shape.triangleup, location.belowbar, color=color.green, size=size.small, text="ES", textcolor=color.white)

//=============================================================================
// GROUP P — DATA WINDOW VALUES
//=============================================================================
//
// These values can be inspected one historical bar at a time through the
// TradingView Data Window.
//
// A value of:
//
// 1 = true
// 0 = false
//
// The Bar Confirmed field helps verify that state events only occur on closed
// candles.
//=============================================================================

plot(tradeState, "Debug State Number", display=display.data_window)

plot(touchCondition ? 1 : 0, "Touch Condition", display=display.data_window)
plot(trendFilter ? 1 : 0, "Trend Filter", display=display.data_window)
plot(qualityFilter ? 1 : 0, "Quality Filter", display=display.data_window)
plot(extensionFilter ? 1 : 0, "Extension Filter", display=display.data_window)
plot(triggerCondition ? 1 : 0, "Trigger Condition", display=display.data_window)
plot(entryPermission ? 1 : 0, "Entry Permission", display=display.data_window)

plot(extensionDistance, "Extension Distance ATR", display=display.data_window)

plot(barsSinceTouch, "Bars Since Touch", display=display.data_window)
plot(barsSinceArm, "Bars Since ARM", display=display.data_window)
plot(barsSinceTrigger, "Bars Since Trigger", display=display.data_window)

plot(touchAndArmSameBar ? 1 : 0, "Touch and ARM Same Bar", display=display.data_window)
plot(armAndTriggerSameBar ? 1 : 0, "ARM and Trigger Same Bar", display=display.data_window)
plot(triggerAndEntrySameBar ? 1 : 0, "Trigger and Entry Same Bar", display=display.data_window)

plot(barstate.isconfirmed ? 1 : 0, "Bar Confirmed", display=display.data_window)
plot(barstate.isrealtime ? 1 : 0, "Realtime Bar", display=display.data_window)

//=============================================================================
// GROUP Q — DEBUG TABLE
//=============================================================================
//
// The table displays current conditions on the chart's latest bar.
//
// On a forming realtime candle, condition values may still change before close.
// The state itself will not advance until the candle is confirmed.
//=============================================================================

var table debugTable = table.new(position.bottom_left, 2, 17, border_width=1)

string stateText = stateToText(tradeState)

if barstate.islast
    if showDebugTable
        table.cell(debugTable, 0, 0, "Debug Item", text_color=color.white, bgcolor=color.new(color.gray, 20))
        table.cell(debugTable, 1, 0, "Current Value", text_color=color.white, bgcolor=color.new(color.gray, 20))

        table.cell(debugTable, 0, 1, "State")
        table.cell(debugTable, 1, 1, stateText)

        table.cell(debugTable, 0, 2, "Last Event")
        table.cell(debugTable, 1, 2, lastEvent)

        table.cell(debugTable, 0, 3, "Last Block")
        table.cell(debugTable, 1, 3, lastBlockReason)

        table.cell(debugTable, 0, 4, "Touch")
        table.cell(debugTable, 1, 4, yesNo(touchCondition))

        table.cell(debugTable, 0, 5, "Trend")
        table.cell(debugTable, 1, 5, yesNo(trendFilter))

        table.cell(debugTable, 0, 6, "Quality")
        table.cell(debugTable, 1, 6, yesNo(qualityFilter))

        table.cell(debugTable, 0, 7, "Extension")
        table.cell(debugTable, 1, 7, yesNo(extensionFilter))

        table.cell(debugTable, 0, 8, "Trigger")
        table.cell(debugTable, 1, 8, yesNo(triggerCondition))

        table.cell(debugTable, 0, 9, "Entry Permission")
        table.cell(debugTable, 1, 9, yesNo(entryPermission))

        table.cell(debugTable, 0, 10, "Bars Since Touch")
        table.cell(debugTable, 1, 10, formatInteger(barsSinceTouch))

        table.cell(debugTable, 0, 11, "Bars Since ARM")
        table.cell(debugTable, 1, 11, formatInteger(barsSinceArm))

        table.cell(debugTable, 0, 12, "Bars Since Trigger")
        table.cell(debugTable, 1, 12, formatInteger(barsSinceTrigger))

        table.cell(debugTable, 0, 13, "Extension ATR")
        table.cell(debugTable, 1, 13, str.tostring(extensionDistance, "#.###"))

        table.cell(debugTable, 0, 14, "Confirmed Bar")
        table.cell(debugTable, 1, 14, barstate.isconfirmed ? "YES" : "NO")

        table.cell(debugTable, 0, 15, "Realtime")
        table.cell(debugTable, 1, 15, barstate.isrealtime ? "YES" : "NO")

        table.cell(debugTable, 0, 16, "Bar Index")
        table.cell(debugTable, 1, 16, str.tostring(bar_index))

    else
        table.clear(debugTable, 0, 0, 1, 16)

//=============================================================================
// GROUP R — ALERT DEBUGGING
//=============================================================================
//
// Alerts fire from confirmed state-transition events.
//
// When creating TradingView alerts, using Once Per Bar Close provides the
// closest match to this debugger's confirmed-bar transition model.
//=============================================================================

alertcondition(newTouch, "Debug Touch", "State-machine debug event: Touch")
alertcondition(newArm, "Debug ARM", "State-machine debug event: ARM")
alertcondition(newTrigger, "Debug Trigger", "State-machine debug event: Trigger")
alertcondition(newEntry, "Debug Entry Signal", "State-machine debug event: Entry Signal")
````
