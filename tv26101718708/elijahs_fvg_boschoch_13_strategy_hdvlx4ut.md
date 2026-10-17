# Elijah's FVG + BOS/CHoCH 1:3 Strategy

- url: https://www.tradingview.com/script/hDvlx4ut-Elijah-s-FVG-BOS-CHoCH-1-3-Strategy/
- type: strategy
- pine_id: PUB;1d3c1b3ada2e452dbd582b19e0b32e13
- version: 1.0

## Description

# FVG + BOS/CHoCH | Market Structure Trading Strategy

## Overview

This strategy combines **Fair Value Gaps (FVGs), Breaks of Structure (BOS), and Changes of Character (CHoCH)** to identify potential high-probability trading setups based on price action, market structure, and price imbalances.

Designed primarily for intraday trading on the **1-minute ES (E-mini S&P 500) and MES (Micro E-mini S&P 500) futures charts**, the strategy waits for a confirmed market structure break, the formation of a qualifying Fair Value Gap, a minimum retracement into the FVG, and a confirming candle close before generating a trade.

The strategy incorporates configurable entry filters, automated stop-loss and take-profit placement, adjustable risk-to-reward ratios, automatic breakeven management, trading session filters, real-time alerts, and a built-in performance dashboard.

**All major trading parameters are customizable directly through the strategy settings**, allowing traders to experiment with different FVG sizes, mitigation percentages, market structure sensitivities, risk-to-reward ratios, and breakeven triggers.

## How the Strategy Works

### 1. Market Structure Confirmation (BOS / CHoCH)

The strategy identifies confirmed swing highs and swing lows using a configurable pivot lookback.

- **Bullish BOS:** Price closes above a confirmed swing high while the market structure trend is bullish.
- **Bearish BOS:** Price closes below a confirmed swing low while the market structure trend is bearish.
- **Bullish CHoCH:** Price breaks above a confirmed swing high, indicating a potential bullish directional shift.
- **Bearish CHoCH:** Price breaks below a confirmed swing low, indicating a potential bearish directional shift.

By default, qualifying Fair Value Gaps must form after the most recent confirmed BOS or CHoCH and align with the direction of that structure event.

### 2. Fair Value Gap (FVG) Identification

The strategy identifies bullish and bearish three-candle Fair Value Gaps and filters them according to their size in ticks.

Default settings:
- Minimum FVG size: 5 ticks
- Maximum FVG size: 10 ticks
- Minimum FVG mitigation: 50%

The minimum and maximum FVG tick sizes are fully adjustable, allowing traders to filter smaller or larger imbalances depending on market conditions.

Each qualifying FVG is monitored until price retraces into the gap by the configured mitigation percentage.

### 3. Long (BUY) Entry Conditions

A bullish trade is considered when:

1. A bullish BOS or CHoCH has been confirmed.
2. A qualifying bullish FVG forms after the structure event.
3. Price retraces into the FVG by at least the configured mitigation percentage.
4. A candle closes above the upper boundary of the bullish FVG.
5. The confirming candle also closes above the active bullish structure level.
6. All enabled entry filters and trading session requirements are satisfied.

Once these conditions are met, the strategy generates a BUY signal with its corresponding entry, stop-loss, and take-profit levels.

### 4. Short (SELL) Entry Conditions

A bearish trade is considered when:

1. A bearish BOS or CHoCH has been confirmed.
2. A qualifying bearish FVG forms after the structure event.
3. Price retraces into the FVG by at least the configured mitigation percentage.
4. A candle closes below the lower boundary of the bearish FVG.
5. The confirming candle also closes below the active bearish structure level.
6. All enabled entry filters and trading session requirements are satisfied.

Once these conditions are met, the strategy generates a SELL signal with its corresponding entry, stop-loss, and take-profit levels.

## Risk Management

### 5. Stop Loss and Take Profit

The strategy automatically calculates stop-loss and take-profit levels for each trade.

**Stop-loss placement:**
- Long positions: Low of the middle candle forming the FVG.
- Short positions: High of the middle candle forming the FVG.

**Take-profit placement:**

The default risk-to-reward ratio is **1:3**, meaning the take-profit distance is three times the initial stop-loss distance.

The risk-to-reward ratio is fully adjustable through the strategy settings, allowing users to test alternatives such as 1:1, 1:1.5, 1:2, 1:3, or higher.

### 6. Automatic Stop Loss to Breakeven

The strategy includes an optional automatic breakeven feature designed to reduce risk after price moves favorably.

By default, when price reaches **50% of the distance from entry to take profit**, the stop loss automatically moves to the entry price.

For a 1:3 risk-to-reward trade, this occurs at approximately +1.5R.

Traders can customize:

- The percentage of the take-profit distance required to trigger breakeven.
- Whether a wick reaching the trigger is sufficient or a candle must close beyond it.
- The number of ticks beyond entry where the breakeven stop is placed.
- Whether automatic breakeven management is enabled or disabled.

Breakeven adjustments are evaluated at candle close, with the updated stop becoming active on the following bar.

## Customizable Strategy Settings

The strategy provides extensive customization through TradingView's built-in settings panel.

| Setting | Default | Customizable |
|---|---|---|
| Market structure swing length | 5 | Yes |
| Minimum FVG size | 5 ticks | Yes |
| Maximum FVG size | 10 ticks | Yes |
| Minimum FVG mitigation | 50% | Yes |
| Risk-to-reward ratio | 1:3 | Yes |
| Automatic breakeven | Enabled | Yes |
| Breakeven trigger | 50% toward TP | Yes |
| Breakeven offset | 0 ticks | Yes |
| Trading session | 8:45–10:45 AM Chicago time | Yes |
| One trade per FVG | Enabled | Yes |
| BOS/CHoCH alignment | Enabled | Yes |
| FVG close confirmation | Enabled | Yes |
| Structure close confirmation | Enabled | Yes |

These adjustable settings allow traders to backtest different configurations without modifying the underlying Pine Script code.

## Chart Features and Visualizations

The strategy includes several visual features to help traders understand market structure, entry conditions, and trade management.

- Bullish and bearish FVG boxes with customizable colors.
- FVG size displayed directly inside each gap in ticks.
- BOS and CHoCH labels at confirmed structure breaks.
- Active market structure levels.
- BUY and SELL labels displaying entry, stop-loss, take-profit, and risk-to-reward information.
- Shaded risk and reward zones.
- Automatic stop-loss-to-breakeven visualization.
- Optional breakeven trigger line.
- Customizable trading session shading.
- Historical trade drawings for visual backtesting.

## Alerts and Notifications

The strategy supports TradingView alerts for:

- Bullish and bearish BOS confirmations.
- Bullish and bearish CHoCH confirmations.
- Long and short trade executions.
- Stop-loss and take-profit order fills.
- Automatic breakeven adjustments.
- Optional FVG detection and invalidation notifications.

Alerts can be configured through TradingView and delivered to supported devices, including mobile phones.

## Performance Dashboard

A built-in performance dashboard displays key backtesting statistics directly on the chart.

Available metrics include:

- Total trades
- Winning trades
- Losing trades
- Win rate
- Profit factor
- Net profit
- Maximum drawdown
- Average winning trade
- Average losing trade
- Expectancy per trade
- Current market structure direction
- Breakeven adjustments and exits

These statistics are calculated using TradingView's Strategy Tester data.

## Recommended Usage

This strategy is primarily designed for traders who use market structure and Fair Value Gaps to identify intraday continuation and reversal opportunities.

It was developed with ES and MES futures in mind, particularly on the 1-minute timeframe, but its adjustable settings allow users to experiment with other instruments and timeframes.

The default parameters provide a starting configuration rather than a universally optimal setup. Traders are encouraged to backtest and optimize settings according to their preferred instruments, trading sessions, and risk tolerance.

## Disclaimer

This strategy is provided for educational, research, and backtesting purposes only. It does not guarantee profitable trades or future performance.

Futures trading involves substantial financial risk. Historical backtesting results may differ from live execution due to slippage, commissions, liquidity, and market conditions.

Users should independently evaluate the strategy and understand the risks before considering live trading.

## Credits and Attribution

This strategy combines market structure logic from Elijah's Structure BOS/CHoCH with modified Fair Value Gap logic derived from LuxAlgo.

The market structure component is identified as licensed under the Mozilla Public License 2.0 (MPL-2.0).

The LuxAlgo-derived Fair Value Gap component is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0).

Original attribution and applicable licensing terms must be retained when sharing or redistributing the combined script.

## Source Code

````pine
// ============================================================================
// LICENSE & ATTRIBUTION — READ BEFORE USING OR SHARING
// ----------------------------------------------------------------------------
// This strategy combines two works:
//
// (1) "Structure BOS / CHoCH" (Elijah's Structure)
//     This Pine Script® code is subject to the terms of the Mozilla Public
//     License 2.0 at https://mozilla.org/MPL/2.0/ MPL-2.0
//
// (2) "Elijah's FVG" — derived from LuxAlgo's Fair Value Gap indicator
//     This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0
//     International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
//     © LuxAlgo
//     Modified: added FVG size in ticks with customizable color
//     Modified (this version): converted Pine v5 -> v6, merged into a strategy,
//     added tick-size filter, % mitigation tracking, middle-candle storage,
//     dual candle-close entry confirmation and fixed-R exits.
//     Modified: dedicated BOS/CHoCH phone alerts (alert() calls).
//
// Because part (2) is CC BY-NC-SA 4.0, this combined script may not be used
// commercially, and any redistribution must credit LuxAlgo and carry the same
// license. The MPL-2.0 portions (structure logic) remain under MPL-2.0.
// ============================================================================

//@version=6
strategy("Elijah's FVG + BOS/CHoCH 1:3 Strategy", "Elijah FVG+Structure", overlay = true
  , pyramiding = 0
  , process_orders_on_close = true
  , calc_on_every_tick = false
  , initial_capital = 50000
  , default_qty_type = strategy.fixed
  , default_qty_value = 1
  , commission_type = strategy.commission.cash_per_contract
  , commission_value = 2.25
  , slippage = 1
  , margin_long = 10
  , margin_short = 10
  , max_lines_count = 500
  , max_labels_count = 500
  , max_boxes_count = 500)

//==============================================================================
// 1. STRATEGY RULE INPUTS (NEW)
//==============================================================================
GRP_RULES = "Strategy Rules"
minFvgTicks    = input.int(5,  "Minimum FVG size (ticks)", minval = 1, group = GRP_RULES)
maxFvgTicks    = input.int(10, "Maximum FVG size (ticks)", minval = 1, group = GRP_RULES)
minMitPct      = input.float(50.0, "Minimum mitigation %", minval = 0.0, maxval = 100.0, step = 5.0, group = GRP_RULES
  , tooltip = "How deep a later candle's wick must retrace into the FVG before an entry is allowed. 50 = the FVG midpoint.")
rrRatio        = input.float(3.0, "Risk-to-reward (TP = risk x this)", minval = 0.1, step = 0.25, group = GRP_RULES)
reqAlign       = input.bool(true, "Require BOS/CHoCH alignment", group = GRP_RULES)
reqFvgClose    = input.bool(true, "Require FVG close confirmation", group = GRP_RULES)
reqStrClose    = input.bool(true, "Require structure close confirmation", group = GRP_RULES)
reqAfter       = input.bool(true, "FVG must form after BOS/CHoCH", group = GRP_RULES)
oneTradePerFvg = input.bool(true, "One trade per FVG", group = GRP_RULES)
slipTicks      = input.int(1, "Slippage used for provisional TP (ticks)", minval = 0, group = GRP_RULES
  , tooltip = "Set this to the same value as Properties > Slippage. It lets the first TP order match the real fill. The TP is re-checked against the actual fill price on the next bar either way.")
showOutRange   = input.bool(false, "Show FVGs outside size range", group = GRP_RULES
  , tooltip = "Off (default): FVGs outside the min/max tick range are not drawn or tracked. On: they are drawn but can never trade.")
maxTracked     = input.int(200, "Max tracked FVGs", minval = 10, maxval = 1000, group = GRP_RULES
  , tooltip = "Oldest FVGs beyond this count are dropped (box deleted) to keep the script fast on long 1-minute histories.")

//==============================================================================
// 1b. TIME FILTER (NEW)
//==============================================================================
GRP_TIME = "Time Filter"
useTimeFilter = input.bool(true, "Only allow signals inside window", group = GRP_TIME)
sessWindow    = input.session("0845-1045", "Signal window", group = GRP_TIME
  , tooltip = "Entries are allowed only on bars that OPEN inside this window. On the 1-minute chart that means signal candles closing from 8:46 through 10:45. FVGs, structure and mitigation keep being tracked outside the window; open trades keep their SL/TP.")
sessTz        = input.string("America/Chicago", "Window time zone", group = GRP_TIME
  , tooltip = "IANA time zone name, e.g. America/Chicago or America/New_York.")
showSessBg    = input.bool(true, "Shade signal window", group = GRP_TIME)

//==============================================================================
// 1c. BREAKEVEN (NEW)
//==============================================================================
GRP_BE = "Breakeven"
useBreakeven  = input.bool(true, "Move stop to breakeven", group = GRP_BE)
beTriggerPct  = input.float(50.0, "Trigger (% of distance to TP)", minval = 1.0, maxval = 99.0, step = 5.0, group = GRP_BE
  , tooltip = "50 = halfway from entry to take profit (1.5R when RR is 3). Uses the actual fill price and final TP.")
beOnClose     = input.bool(false, "Require candle CLOSE beyond trigger", group = GRP_BE
  , tooltip = "Off: a wick reaching the trigger is enough. On: a candle must close at or beyond it.")
beOffsetTicks = input.int(0, "Breakeven offset (ticks)", minval = 0, group = GRP_BE
  , tooltip = "0 = stop exactly at the entry fill. Add ticks (e.g. 1) to cover commissions; the stop is placed that many ticks in profit.")
beLineCol     = input.color(color.gray, "Breakeven line", group = GRP_BE)
showBeTrigger = input.bool(true, "Show 50% trigger line", group = GRP_BE
  , tooltip = "Draws the halfway level between entry and TP for every trade, so you can see exactly where the stop moves to breakeven.")
beAlertOn     = input.bool(true, "Alert when stop moves to breakeven", group = GRP_BE
  , tooltip = "Sends an alert() message when the stop is moved. Moving a stop is not an order fill, so choose 'Order fills and alert() function calls' when creating the alert.")

//==============================================================================
// 2. TRADE VISUAL INPUTS (NEW)
//==============================================================================
GRP_VIS = "Trade Visuals"
showSignals  = input.bool(true, "Show BUY/SELL labels", group = GRP_VIS)
showLevels   = input.bool(true, "Show Entry/SL/TP", group = GRP_VIS)
showShade    = input.bool(true, "Show risk/reward shading", group = GRP_VIS)
showFvgBox   = input.bool(true, "Show FVG boxes", group = GRP_VIS)
showStructVis = input.bool(true, "Show BOS/CHoCH labels", group = GRP_VIS)
showStructLvl = input.bool(true, "Show active structure level", group = GRP_VIS
  , tooltip = "Plots the level of the most recent confirmed BOS/CHoCH that entries must close beyond.")
longCol      = input.color(#2962ff, "BUY", inline = "tc", group = GRP_VIS)
shortCol     = input.color(#ff4fa3, "SELL", inline = "tc", group = GRP_VIS)
slLineCol    = input.color(#f23645, "Stop line", inline = "tc2", group = GRP_VIS)
riskShadeCol = input.color(color.new(color.gray, 80), "Risk shading", inline = "tc2", group = GRP_VIS)
tradeExtend  = input.int(1, "Bars to project ahead of price while open", minval = 1, maxval = 50, group = GRP_VIS
  , tooltip = "Risk/reward shading and trade lines grow with every bar while the trade is open and stop exactly on the bar where TP, SL or breakeven is hit. This only sets how far they reach past the current bar while the trade is still running.")

//==============================================================================
// 3. STRUCTURE INPUTS (ORIGINAL — Elijah's Structure)
//==============================================================================
swingLen = input.int(5, "Swing Length", minval = 2, maxval = 50, group = "Market Structure", tooltip = "Pivot lookback used to detect swing points. Higher values return larger, slower market structure.")
sBullCss = input.color(#089981, "Bullish", inline = "dir", group = "Market Structure")
sBearCss = input.color(#f23645, "Bearish", inline = "dir", group = "Market Structure")

//==============================================================================
// 4. FVG INPUTS (ORIGINAL — Elijah's FVG / LuxAlgo)
//==============================================================================
GRP_FVG = "FVG Detection"
thresholdPer = input.float(0, "Threshold %", minval = 0, maxval = 100, step = .1, inline = 'threshold', group = GRP_FVG)
auto = input(false, "Auto", inline = 'threshold', group = GRP_FVG)

showLast = input.int(0, 'Unmitigated Levels', minval = 0, group = GRP_FVG)
mitigationLevels = input.bool(false, 'Mitigation Levels', group = GRP_FVG)

tf = input.timeframe('', "Timeframe", group = GRP_FVG, tooltip = "Leave blank (chart timeframe) to trade. If a different timeframe is chosen, FVGs are still drawn but the strategy will not take trades.")

//Style
extendBars = input.int(20, 'Extend', minval = 0, inline = 'extend', group = 'Style')
dynamic = input(false, 'Dynamic', inline = 'extend', group = 'Style')

fvgBullCss = input.color(color.new(#089981, 70), "Bullish FVG", group = 'Style')
fvgBearCss = input.color(color.new(#f23645, 70), "Bearish FVG", group = 'Style')

//Tick Size
showTicks     = input.bool(true, 'Show Tick Size', group = 'Tick Size')
bullTickCss   = input.color(color.white, 'Bullish Text', inline = 'tickcss', group = 'Tick Size')
bearTickCss   = input.color(color.white, 'Bearish Text', inline = 'tickcss', group = 'Tick Size')
tickTextSize  = input.string('Small', 'Text Size', options = ['Tiny', 'Small', 'Normal', 'Large'], group = 'Tick Size')
tickHAlign    = input.string('Center', 'Horizontal Align', options = ['Left', 'Center', 'Right'], group = 'Tick Size')
tickSuffix    = input.bool(true, 'Append "ticks"', group = 'Tick Size')

//Dashboard (original FVG dashboard)
showDash  = input(false, 'Show Dashboard', group = 'FVG Dashboard')
dashLoc  = input.string('Top Right', 'Location', options = ['Top Right', 'Bottom Right', 'Bottom Left'], group = 'FVG Dashboard')
textSize = input.string('Small', 'Size'        , options = ['Tiny', 'Small', 'Normal']                 , group = 'FVG Dashboard')

//==============================================================================
// 5. PERFORMANCE DASHBOARD & ALERT INPUTS
//==============================================================================
showPerf = input.bool(true, "Show performance dashboard", group = "Performance Dashboard")
perfLoc  = input.string("Bottom Right", "Location", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group = "Performance Dashboard")

GRP_ALERT = "BOS / CHoCH Alerts"
structAlertsOn   = input.bool(true, "Send BOS/CHoCH alerts", group = GRP_ALERT
  , tooltip = "Fires an alert() message on the candle close that confirms a new BOS or CHoCH. Create the alert with 'alert() function calls only' to get these on your phone without trade fills.")
alertBullBosOn   = input.bool(true, "Bullish BOS", inline = "ab1", group = GRP_ALERT)
alertBearBosOn   = input.bool(true, "Bearish BOS", inline = "ab1", group = GRP_ALERT)
alertBullChochOn = input.bool(true, "Bullish CHoCH", inline = "ab2", group = GRP_ALERT)
alertBearChochOn = input.bool(true, "Bearish CHoCH", inline = "ab2", group = GRP_ALERT)
alertsOnly1m     = input.bool(false, "Only fire on the 1-minute chart", group = GRP_ALERT
  , tooltip = "On: structure alerts are sent only when the strategy runs on a 1-minute chart.")
alertsInWindow   = input.bool(false, "Only fire inside the signal window", group = GRP_ALERT
  , tooltip = "On: structure alerts are sent only during the Time Filter window (e.g. 08:45-10:45).")
legacyFvgAlerts  = input.bool(false, "Send FVG detected / invalidated alert() calls", group = GRP_ALERT)

//==============================================================================
// 6. TYPES
//==============================================================================
// Original FVG record from the LuxAlgo script, extended with the middle candle.
type fvg
    float max
    float min
    bool  isbull
    int   t
    float midHigh   // high of candle 2 (middle candle)
    float midLow    // low of candle 2 (middle candle)

// Per-FVG tracked setup state.
// state: -1 display only (never eligible)
//         0 formed / waiting for mitigation
//         1 mitigated >= min % / waiting for dual candle-close confirmation
//         2 entry triggered (used)
//         3 expired (newer structure event invalidated the setup)
// Removal from the array = invalidated by the original FVG rule (close through the gap).
type FvgSetup
    float top
    float bot
    bool  isBull
    int   t
    int   formBar
    float midHigh
    float midLow
    int   ticks
    bool  eligible
    bool  mitigated
    bool  traded
    int   state
    box   bx

var setups = array.new<FvgSetup>(0)
n = bar_index

//==============================================================================
// 7. MARKET STRUCTURE — ORIGINAL BOS / CHoCH LOGIC (Elijah's Structure)
//==============================================================================
var float lastHigh    = na
var int   lastHighBar = na
var bool  highTaken   = true
var float lastLow     = na
var int   lastLowBar  = na
var bool  lowTaken    = true
var int   trendDir    = 0

// --- Swing detection (pivots confirm swingLen bars after the swing — no lookahead) ---
float ph = ta.pivothigh(high, swingLen, swingLen)
float pl = ta.pivotlow(low, swingLen, swingLen)

if not na(ph)
    lastHigh    := ph
    lastHighBar := bar_index - swingLen
    highTaken   := false

if not na(pl)
    lastLow    := pl
    lastLowBar := bar_index - swingLen
    lowTaken   := false

// --- Event flags (reset every bar) ---
bool bullChochEvt = false
bool bearChochEvt = false
bool bullBosEvt   = false
bool bearBosEvt   = false
float bullBreakLevel = na
float bearBreakLevel = na

// --- Structure breaks (bar-close based) ---
bool bullBreak = not na(lastHigh) and not highTaken and close > lastHigh
bool bearBreak = not na(lastLow) and not lowTaken and close < lastLow

if bullBreak
    highTaken := true
    bool isBos = trendDir == 1
    bullBosEvt     := isBos
    bullChochEvt   := not isBos
    bullBreakLevel := lastHigh     // the actual broken swing-high level
    if showStructVis
        line.new(lastHighBar, lastHigh, bar_index, lastHigh, color = color.new(sBullCss, 40), style = line.style_dashed)
        label.new(int(math.avg(lastHighBar, bar_index)), lastHigh, isBos ? "BOS" : "CHoCH", style = label.style_label_down, color = #00000000, textcolor = sBullCss, size = size.tiny)
    if not isBos
        trendDir := 1

if bearBreak
    lowTaken := true
    bool isBos = trendDir == -1
    bearBosEvt     := isBos
    bearChochEvt   := not isBos
    bearBreakLevel := lastLow      // the actual broken swing-low level
    if showStructVis
        line.new(lastLowBar, lastLow, bar_index, lastLow, color = color.new(sBearCss, 40), style = line.style_dashed)
        label.new(int(math.avg(lastLowBar, bar_index)), lastLow, isBos ? "BOS" : "CHoCH", style = label.style_label_up, color = #00000000, textcolor = sBearCss, size = size.tiny)
    if not isBos
        trendDir := -1

//==============================================================================
// 8. LATEST CONFIRMED STRUCTURE EVENT (NEW)
//==============================================================================
var int   structDir     = 0     // 1 bullish, -1 bearish, 0 none / conflicting
var float structLevel   = na    // level of the most recent event
var int   structBar     = na    // bar of the most recent event
var float lastBullLevel = na
var float lastBearLevel = na

if bullBreak or bearBreak
    if bullBreak
        lastBullLevel := bullBreakLevel
    if bearBreak
        lastBearLevel := bearBreakLevel
    if bullBreak and bearBreak
        // Both directions broke on the same bar: ambiguous -> no permitted direction
        structDir   := 0
        structLevel := na
    else
        structDir   := bullBreak ? 1 : -1
        structLevel := bullBreak ? bullBreakLevel : bearBreakLevel
    structBar := bar_index

    // Expire pending setups that this newer event disqualifies
    if setups.size() > 0
        for s in setups
            if s.state == 0 or s.state == 1
                bool opposing = structDir == 0 or (s.isBull and structDir == -1) or (not s.isBull and structDir == 1)
                if reqAfter or (reqAlign and opposing)
                    s.state    := 3
                    s.eligible := false

//==============================================================================
// 9. FVG DETECTION — ORIGINAL LuxAlgo/Elijah LOGIC (v6)
//==============================================================================
method tosolid(color id)=> color.rgb(color.r(id),color.g(id),color.b(id))

tick_text_size = tickTextSize == 'Tiny' ? size.tiny
  : tickTextSize == 'Small' ? size.small
  : tickTextSize == 'Normal' ? size.normal
  : size.large

tick_halign = tickHAlign == 'Left' ? text.align_left
  : tickHAlign == 'Right' ? text.align_right
  : text.align_center

//Returns the FVG height expressed in ticks of the chart symbol
tickLabel(float top, float bottom)=>
    ticks = math.round((top - bottom) / syminfo.mintick)
    showTicks ? str.tostring(ticks) + (tickSuffix ? ' ticks' : '') : ''

detect()=>
    var new_fvg = fvg.new(na, na, false, na, na, na)
    cumRng = ta.cum((high - low) / low)
    threshold = auto ? cumRng / bar_index : thresholdPer / 100

    bull_fvg = low > high[2] and close[1] > high[2] and (low - high[2]) / high[2] > threshold
    bear_fvg = high < low[2] and close[1] < low[2] and (low[2] - high) / high > threshold

    if bull_fvg
        new_fvg := fvg.new(low, high[2], true, time, high[1], low[1])
    else if bear_fvg
        new_fvg := fvg.new(low[2], high, false, time, high[1], low[1])

    [bull_fvg, bear_fvg, new_fvg]

var float max_bull_fvg = na, var float min_bull_fvg = na, var bull_count = 0, var bull_mitigated = 0
var float max_bear_fvg = na, var float min_bear_fvg = na, var bear_count = 0, var bear_mitigated = 0
var t = 0

//Dynamic mode tick labels
var label bull_tick_lbl = na
var label bear_tick_lbl = na

[bull_fvg, bear_fvg, new_fvg] = request.security(syminfo.tickerid, tf, detect())

// Trading is only allowed when FVGs come from the chart timeframe
// (middle-candle stops and bar-by-bar mitigation need chart-timeframe candles).
bool tfTradeOk = tf == '' or tf == timeframe.period

//Bull FVG's
if bull_fvg and new_fvg.t != t
    int  fTicks  = math.round((new_fvg.max - new_fvg.min) / syminfo.mintick)
    bool inRange = fTicks >= minFvgTicks and fTicks <= maxFvgTicks
    if inRange or showOutRange
        if dynamic
            max_bull_fvg := new_fvg.max
            min_bull_fvg := new_fvg.min
        box bx = na
        if not dynamic and showFvgBox
            bx := box.new(n-2, new_fvg.max, n+extendBars, new_fvg.min, na, bgcolor = fvgBullCss
              , text = tickLabel(new_fvg.max, new_fvg.min)
              , text_color = bullTickCss
              , text_size = tick_text_size
              , text_halign = tick_halign
              , text_valign = text.align_center)
        bool elig = inRange and tfTradeOk
          and (not reqAlign or structDir == 1)
          and (not reqAfter or (not na(structBar) and n > structBar))
        setups.unshift(FvgSetup.new(new_fvg.max, new_fvg.min, true, new_fvg.t, n, new_fvg.midHigh, new_fvg.midLow, fTicks, elig, false, false, elig ? 0 : -1, bx))
        bull_count += 1
    t := new_fvg.t
else if dynamic
    max_bull_fvg := math.max(math.min(close, max_bull_fvg), min_bull_fvg)

//Bear FVG's
if bear_fvg and new_fvg.t != t
    int  fTicks  = math.round((new_fvg.max - new_fvg.min) / syminfo.mintick)
    bool inRange = fTicks >= minFvgTicks and fTicks <= maxFvgTicks
    if inRange or showOutRange
        if dynamic
            max_bear_fvg := new_fvg.max
            min_bear_fvg := new_fvg.min
        box bx = na
        if not dynamic and showFvgBox
            bx := box.new(n-2, new_fvg.max, n+extendBars, new_fvg.min, na, bgcolor = fvgBearCss
              , text = tickLabel(new_fvg.max, new_fvg.min)
              , text_color = bearTickCss
              , text_size = tick_text_size
              , text_halign = tick_halign
              , text_valign = text.align_center)
        bool elig = inRange and tfTradeOk
          and (not reqAlign or structDir == -1)
          and (not reqAfter or (not na(structBar) and n > structBar))
        setups.unshift(FvgSetup.new(new_fvg.max, new_fvg.min, false, new_fvg.t, n, new_fvg.midHigh, new_fvg.midLow, fTicks, elig, false, false, elig ? 0 : -1, bx))
        bear_count += 1
    t := new_fvg.t
else if dynamic
    min_bear_fvg := math.min(math.max(close, min_bear_fvg), max_bear_fvg)

// Cap tracked FVGs (oldest dropped)
while setups.size() > maxTracked
    FvgSetup old = setups.pop()
    box.delete(old.bx)

//Dynamic mode: show remaining gap size in ticks on the latest bar
if dynamic and showTicks and barstate.islast
    label.delete(bull_tick_lbl)
    label.delete(bear_tick_lbl)
    if not na(max_bull_fvg) and max_bull_fvg > min_bull_fvg
        bull_tick_lbl := label.new(n + 1, math.avg(max_bull_fvg, min_bull_fvg), tickLabel(max_bull_fvg, min_bull_fvg)
          , style = label.style_label_left, color = color.new(color.black, 100)
          , textcolor = bullTickCss, size = tick_text_size)
    if not na(max_bear_fvg) and max_bear_fvg > min_bear_fvg
        bear_tick_lbl := label.new(n + 1, math.avg(max_bear_fvg, min_bear_fvg), tickLabel(max_bear_fvg, min_bear_fvg)
          , style = label.style_label_left, color = color.new(color.black, 100)
          , textcolor = bearTickCss, size = tick_text_size)

//==============================================================================
// 10. MITIGATION TRACKING + DUAL CANDLE-CLOSE CANDIDATES (NEW)
//==============================================================================
FvgSetup longCand  = na
FvgSetup shortCand = na

int setupCount = setups.size()
if setupCount > 0
    // Descending loop: the last match assigned is the NEWEST qualifying FVG.
    for i = setupCount - 1 to 0
        FvgSetup s = setups.get(i)
        // The formation candle itself can never mitigate or confirm
        if s.eligible and (s.state == 0 or s.state == 1) and n > s.formBar
            float rng = s.top - s.bot
            if s.isBull
                float mitLvl = s.top - rng * minMitPct / 100.0
                if not s.mitigated and low <= mitLvl
                    s.mitigated := true
                    s.state     := 1
                if s.mitigated
                    float lvl     = reqAlign ? structLevel : lastBullLevel
                    bool  alignOk = not reqAlign or structDir == 1
                    bool  fvgOk   = not reqFvgClose or close > s.top
                    bool  strOk   = not reqStrClose or (not na(lvl) and close > lvl)
                    if alignOk and fvgOk and strOk
                        longCand := s
            else
                float mitLvl = s.bot + rng * minMitPct / 100.0
                if not s.mitigated and high >= mitLvl
                    s.mitigated := true
                    s.state     := 1
                if s.mitigated
                    float lvl     = reqAlign ? structLevel : lastBearLevel
                    bool  alignOk = not reqAlign or structDir == -1
                    bool  fvgOk   = not reqFvgClose or close < s.bot
                    bool  strOk   = not reqStrClose or (not na(lvl) and close < lvl)
                    if alignOk and fvgOk and strOk
                        shortCand := s

//==============================================================================
// 11. TRADE HELPERS
//==============================================================================
f_fmtPx(float v) => str.tostring(v, format.mintick)

f_rrText() => "1:" + str.tostring(rrRatio, "#.##")

// Breakeven trigger: beTriggerPct of the way from entry to TP (50 = halfway).
f_beTrigger(float e, float tp) => e + (tp - e) * beTriggerPct / 100.0

f_tradeText(bool isLong, float e, float sl, float tp) =>
    (isLong ? "BUY" : "SELL") + "\nEntry: " + f_fmtPx(e) + "\nSL: " + f_fmtPx(sl) + "\nTP: " + f_fmtPx(tp) + "\nRR " + f_rrText()

f_entryMsg(bool isLong, float e, float sl, float tp) =>
    syminfo.ticker + " " + (isLong ? "BUY" : "SELL") + " | Entry: " + f_fmtPx(e) + " | SL: " + f_fmtPx(sl) + " | TP: " + f_fmtPx(tp) + " | RR: " + f_rrText()

f_exitMsg(bool isLong, float sl, float tp) =>
    syminfo.ticker + " " + (isLong ? "LONG" : "SHORT") + " EXIT (SL or TP) | SL: " + f_fmtPx(sl) + " | TP: " + f_fmtPx(tp)

f_drawTrade(bool isLong, float e, float sl, float tp) =>
    color c  = isLong ? longCol : shortCol
    int   x2 = bar_index + tradeExtend
    line  le = na
    line  ls = na
    line  lt = na
    box   br = na
    box   bk = na
    label lb = na
    if showLevels
        le := line.new(bar_index, e,  x2, e,  color = c, width = 2)
        ls := line.new(bar_index, sl, x2, sl, color = slLineCol, width = 1, style = line.style_dashed)
        lt := line.new(bar_index, tp, x2, tp, color = c, width = 1, style = line.style_dashed)
    if showShade
        br := box.new(bar_index, math.max(e, tp), x2, math.min(e, tp), border_color = na, bgcolor = color.new(c, 85))
        bk := box.new(bar_index, math.max(e, sl), x2, math.min(e, sl), border_color = na, bgcolor = riskShadeCol)
    if showSignals
        if isLong
            lb := label.new(bar_index, low, f_tradeText(true, e, sl, tp), yloc = yloc.belowbar, style = label.style_label_up, color = c, textcolor = color.white, size = size.small)
        else
            lb := label.new(bar_index, high, f_tradeText(false, e, sl, tp), yloc = yloc.abovebar, style = label.style_label_down, color = c, textcolor = color.white, size = size.small)
    [le, ls, lt, br, bk, lb]

//==============================================================================
// 12. OPEN-TRADE MANAGEMENT (NEW)
//==============================================================================
var bool  needFinalize    = false
var int   trDir           = 0
var float trEntry         = na
var float trSL            = na
var float trTP            = na
var int   prevClosedCount = 0
var line  trEntryLn = na
var line  trSlLn    = na
var line  trTpLn    = na
var box   trRwdBx   = na
var box   trRiskBx  = na
var label trLbl     = na
var line  trBeLn    = na
var line  trBeTrigLn = na
var bool  beMoved   = false
var int   beMoveCount = 0   // trades whose stop was moved to breakeven
var int   beExitCount = 0   // trades that closed at the breakeven stop

// (a) First bar after entry: rebuild TP from the ACTUAL simulated fill price.
//     The initial stop stays at the middle candle; only the target is re-derived.
if needFinalize
    float fillPx = na
    if strategy.opentrades > 0
        fillPx := strategy.opentrades.entry_price(strategy.opentrades - 1)
    else if strategy.closedtrades > 0
        fillPx := strategy.closedtrades.entry_price(strategy.closedtrades - 1)
    if not na(fillPx)
        float riskPx = trDir == 1 ? fillPx - trSL : trSL - fillPx
        if riskPx > 0 and strategy.opentrades > 0
            float tpExact = math.round_to_mintick(trDir == 1 ? fillPx + rrRatio * riskPx : fillPx - rrRatio * riskPx)
            if tpExact != trTP
                trTP := tpExact
                if trDir == 1
                    strategy.exit("Long Exit", "Long", stop = trSL, limit = trTP, comment_loss = "SL", comment_profit = "TP", alert_message = f_exitMsg(true, trSL, trTP))
                else
                    strategy.exit("Short Exit", "Short", stop = trSL, limit = trTP, comment_loss = "SL", comment_profit = "TP", alert_message = f_exitMsg(false, trSL, trTP))
        trEntry := fillPx
        if not na(trEntryLn)
            trEntryLn.set_y1(trEntry)
            trEntryLn.set_y2(trEntry)
        if not na(trTpLn)
            trTpLn.set_y1(trTP)
            trTpLn.set_y2(trTP)
        if not na(trRwdBx)
            trRwdBx.set_top(math.max(trEntry, trTP))
            trRwdBx.set_bottom(math.min(trEntry, trTP))
        if not na(trRiskBx)
            trRiskBx.set_top(math.max(trEntry, trSL))
            trRiskBx.set_bottom(math.min(trEntry, trSL))
        if not na(trLbl)
            trLbl.set_text(f_tradeText(trDir == 1, trEntry, trSL, trTP))
        if not na(trBeTrigLn)
            float trg = f_beTrigger(trEntry, trTP)
            trBeTrigLn.set_y1(trg)
            trBeTrigLn.set_y2(trg)
    needFinalize := false

// (a2) Breakeven: as soon as price reaches 50% of the way from the ACTUAL entry
//      fill to the take profit, the stop is moved to the entry fill (+offset).
//      - Runs on every bar while a trade is open, starting the first bar after entry.
//      - Uses the finalized fill price and TP (finalize step above runs first).
//      - Fires once per trade; the stop never moves back.
//      - Checked at bar close, so the new stop is live from the NEXT bar.
bool beMovedThisBar = false
float beStopNow     = na
if useBreakeven and not beMoved and strategy.opentrades > 0 and not na(trEntry) and not na(trTP)
    float beTrigger = f_beTrigger(trEntry, trTP)
    bool  beHit = trDir == 1 ? (beOnClose ? close >= beTrigger : high >= beTrigger)
      : (beOnClose ? close <= beTrigger : low <= beTrigger)
    if beHit
        float beStop = math.round_to_mintick(trEntry + trDir * beOffsetTicks * syminfo.mintick)
        // Safety: never loosen the stop
        bool tighter = trDir == 1 ? beStop > trSL : beStop < trSL
        if tighter
            if trDir == 1
                strategy.exit("Long Exit", "Long", stop = beStop, limit = trTP, comment_loss = "BE", comment_profit = "TP", alert_message = f_exitMsg(true, beStop, trTP))
            else
                strategy.exit("Short Exit", "Short", stop = beStop, limit = trTP, comment_loss = "BE", comment_profit = "TP", alert_message = f_exitMsg(false, beStop, trTP))
            beMoved        := true
            beMovedThisBar := true
            beStopNow      := beStop
            beMoveCount    += 1
            if not na(trSlLn)
                trSlLn.set_x2(bar_index)
            if not na(trBeTrigLn)
                trBeTrigLn.set_x2(bar_index)
            if showLevels
                trBeLn := line.new(bar_index, beStop, bar_index + tradeExtend, beStop, color = beLineCol, width = 2, style = line.style_dotted)
            if not na(trLbl)
                trLbl.set_text(f_tradeText(trDir == 1, trEntry, trSL, trTP) + "\nSL → BE @ " + f_fmtPx(beStop))
            if beAlertOn
                alert(syminfo.ticker + " " + (trDir == 1 ? "LONG" : "SHORT") + " STOP MOVED TO BREAKEVEN | New SL: " + f_fmtPx(beStop) + " | TP: " + f_fmtPx(trTP), alert.freq_once_per_bar_close)

// (a3) Trade still open: keep the risk/reward shading and lines growing with price
//      until the TP, SL or breakeven stop is reached.
if strategy.opentrades > 0
    int xNow = bar_index + tradeExtend
    if not na(trEntryLn)
        trEntryLn.set_x2(xNow)
    if not na(trTpLn)
        trTpLn.set_x2(xNow)
    if not na(trRwdBx)
        trRwdBx.set_right(xNow)
    if not na(trRiskBx)
        trRiskBx.set_right(xNow)
    if not beMoved
        if not na(trSlLn)
            trSlLn.set_x2(xNow)
        if not na(trBeTrigLn)
            trBeTrigLn.set_x2(xNow)
    else if not na(trBeLn)
        trBeLn.set_x2(xNow)

// (b) Trade closed: trim its drawings to the exit bar (drawings are never deleted)
if strategy.closedtrades > prevClosedCount
    int xb = strategy.closedtrades.exit_bar_index(strategy.closedtrades - 1)
    if not na(trEntryLn)
        trEntryLn.set_x2(xb)
    if not na(trSlLn) and not beMoved
        trSlLn.set_x2(xb)
    if not na(trTpLn)
        trTpLn.set_x2(xb)
    if not na(trRwdBx)
        trRwdBx.set_right(xb)
    if not na(trRiskBx)
        trRiskBx.set_right(xb)
    if not na(trBeLn)
        trBeLn.set_x2(xb)
    if not na(trBeTrigLn) and not beMoved
        trBeTrigLn.set_x2(xb)
    if strategy.closedtrades.exit_comment(strategy.closedtrades - 1) == "BE"
        beExitCount += 1
    prevClosedCount := strategy.closedtrades

//==============================================================================
// 13. ENTRIES (NEW)
//==============================================================================
bool isFlat      = strategy.position_size == 0 and strategy.opentrades == 0
bool conflict    = not na(longCand) and not na(shortCand)   // only possible with alignment OFF
bool longSignal  = false
bool shortSignal = false

// Time filter: bar must open inside the window (evaluated in the chosen time zone)
bool inWindow    = not na(time(timeframe.period, sessWindow, sessTz))
bool timeOk      = not useTimeFilter or inWindow

if barstate.isconfirmed and isFlat and tfTradeOk and timeOk and not conflict
    if not na(longCand)
        float sl       = longCand.midLow
        float estEntry = close + slipTicks * syminfo.mintick
        float riskPx   = estEntry - sl
        if not na(sl) and close > sl and riskPx >= syminfo.mintick
            float tp = math.round_to_mintick(estEntry + rrRatio * riskPx)
            strategy.entry("Long", strategy.long, comment = "BUY", alert_message = f_entryMsg(true, estEntry, sl, tp))
            strategy.exit("Long Exit", "Long", stop = sl, limit = tp, comment_loss = "SL", comment_profit = "TP", alert_message = f_exitMsg(true, sl, tp))
            longCand.traded := true
            longCand.state  := oneTradePerFvg ? 2 : 1
            trDir   := 1
            trEntry := estEntry
            trSL    := sl
            trTP    := tp
            needFinalize := true
            longSignal   := true
            beMoved      := false
            trBeLn       := na
            [le, ls, lt, br, bk, lb] = f_drawTrade(true, estEntry, sl, tp)
            trEntryLn := le
            trSlLn    := ls
            trTpLn    := lt
            trRwdBx   := br
            trRiskBx  := bk
            trLbl     := lb
            trBeTrigLn := useBreakeven and showBeTrigger ? line.new(bar_index, f_beTrigger(estEntry, tp), bar_index + tradeExtend, f_beTrigger(estEntry, tp), color = color.new(beLineCol, 30), width = 1, style = line.style_dotted) : na
    else if not na(shortCand)
        float sl       = shortCand.midHigh
        float estEntry = close - slipTicks * syminfo.mintick
        float riskPx   = sl - estEntry
        if not na(sl) and close < sl and riskPx >= syminfo.mintick
            float tp = math.round_to_mintick(estEntry - rrRatio * riskPx)
            strategy.entry("Short", strategy.short, comment = "SELL", alert_message = f_entryMsg(false, estEntry, sl, tp))
            strategy.exit("Short Exit", "Short", stop = sl, limit = tp, comment_loss = "SL", comment_profit = "TP", alert_message = f_exitMsg(false, sl, tp))
            shortCand.traded := true
            shortCand.state  := oneTradePerFvg ? 2 : 1
            trDir   := -1
            trEntry := estEntry
            trSL    := sl
            trTP    := tp
            needFinalize := true
            shortSignal  := true
            beMoved      := false
            trBeLn       := na
            [le, ls, lt, br, bk, lb] = f_drawTrade(false, estEntry, sl, tp)
            trEntryLn := le
            trSlLn    := ls
            trTpLn    := lt
            trRwdBx   := br
            trRiskBx  := bk
            trLbl     := lb
            trBeTrigLn := useBreakeven and showBeTrigger ? line.new(bar_index, f_beTrigger(estEntry, tp), bar_index + tradeExtend, f_beTrigger(estEntry, tp), color = color.new(beLineCol, 30), width = 1, style = line.style_dotted) : na

//==============================================================================
// 14. FVG INVALIDATION — ORIGINAL "MITIGATION" RULE (close fully through gap)
//==============================================================================
if setups.size() > 0
    for i = setups.size() - 1 to 0
        FvgSetup get = setups.get(i)

        if get.isBull
            if close < get.bot
                //Display line if mitigated
                if mitigationLevels
                    line.new(get.t
                      , get.bot
                      , time
                      , get.bot
                      , xloc.bar_time
                      , color = fvgBullCss
                      , style = line.style_dashed)

                //Delete box
                if not dynamic
                    box.delete(get.bx)

                setups.remove(i)
                bull_mitigated += 1
        else if close > get.top
            //Display line if mitigated
            if mitigationLevels
                line.new(get.t
                  , get.top
                  , time
                  , get.top
                  , xloc.bar_time
                  , color = fvgBearCss
                  , style = line.style_dashed)

            //Delete box
            if not dynamic
                box.delete(get.bx)

            setups.remove(i)
            bear_mitigated += 1

//Unmitigated lines
var unmitigated = array.new<line>(0)

//Remove umitigated lines
if barstate.islast and showLast > 0 and setups.size() > 0
    if unmitigated.size() > 0
        for element in unmitigated
            element.delete()
        unmitigated.clear()

    for i = 0 to math.min(showLast-1, setups.size()-1)
        get = setups.get(i)

        unmitigated.push(line.new(get.t
          , get.isBull ? get.bot : get.top
          , time
          , get.isBull ? get.bot : get.top
          , xloc.bar_time
          , color = get.isBull ? fvgBullCss : fvgBearCss))

//==============================================================================
// 15. ORIGINAL FVG DASHBOARD
//==============================================================================
var table_position = dashLoc == 'Bottom Left' ? position.bottom_left
  : dashLoc == 'Top Right' ? position.top_right
  : position.bottom_right

var table_size = textSize == 'Tiny' ? size.tiny
  : textSize == 'Small' ? size.small
  : size.normal

var tb = table.new(table_position, 3, 3
  , bgcolor = #1e222d
  , border_color = #373a46
  , border_width = 1
  , frame_color = #373a46
  , frame_width = 1)

if showDash
    if barstate.isfirst
        tb.cell(1, 0, 'Bullish', text_color = fvgBullCss.tosolid(), text_size = table_size)
        tb.cell(2, 0, 'Bearish', text_color = fvgBearCss.tosolid(), text_size = table_size)

        tb.cell(0, 1, 'Count', text_size = table_size, text_color = color.white)
        tb.cell(0, 2, 'Mitigated', text_size = table_size, text_color = color.white)

    if barstate.islast
        tb.cell(1, 1, str.tostring(bull_count), text_color = fvgBullCss.tosolid(), text_size = table_size)
        tb.cell(2, 1, str.tostring(bear_count), text_color = fvgBearCss.tosolid(), text_size = table_size)

        tb.cell(1, 2, str.tostring(bull_count > 0 ? float(bull_mitigated) / bull_count * 100 : na, format.percent), text_color = fvgBullCss.tosolid(), text_size = table_size)
        tb.cell(2, 2, str.tostring(bear_count > 0 ? float(bear_mitigated) / bear_count * 100 : na, format.percent), text_color = fvgBearCss.tosolid(), text_size = table_size)

//==============================================================================
// 16. PERFORMANCE DASHBOARD (reads TradingView's own Strategy Tester values)
//==============================================================================
var perfPos = perfLoc == "Top Left" ? position.top_left
  : perfLoc == "Top Right" ? position.top_right
  : perfLoc == "Bottom Left" ? position.bottom_left
  : position.bottom_right

var perfTb = table.new(perfPos, 2, 14
  , bgcolor = #1e222d
  , border_color = #373a46
  , border_width = 1
  , frame_color = #373a46
  , frame_width = 1)

f_fmtNum(float v) => na(v) ? "—" : str.tostring(v, "#,##0.00")

f_row(table tbl, int r, string k, string v, color vc) =>
    tbl.cell(0, r, k, text_color = color.white, text_size = size.small, text_halign = text.align_left)
    tbl.cell(1, r, v, text_color = vc, text_size = size.small, text_halign = text.align_right)

if showPerf and barstate.islast
    int   tot    = strategy.closedtrades
    int   wins   = strategy.wintrades
    int   losses = strategy.losstrades
    float wr     = tot > 0 ? float(wins) / tot * 100.0 : na
    float pf     = strategy.grossloss > 0 ? strategy.grossprofit / strategy.grossloss : na
    float avgW   = wins > 0 ? strategy.grossprofit / wins : na
    float avgL   = losses > 0 ? -strategy.grossloss / losses : na
    float expct  = tot > 0 ? strategy.netprofit / tot : na
    string stTxt = structDir == 1 ? "Bullish @ " + f_fmtPx(structLevel)
      : structDir == -1 ? "Bearish @ " + f_fmtPx(structLevel)
      : "None / conflicting"
    color stCol  = structDir == 1 ? longCol : structDir == -1 ? shortCol : color.gray

    f_row(perfTb, 0,  "FVG + BOS/CHoCH " + f_rrText(), syminfo.ticker, color.white)
    f_row(perfTb, 1,  "Structure", stTxt, stCol)
    f_row(perfTb, 2,  "Total trades", str.tostring(tot), color.white)
    f_row(perfTb, 3,  "Winning trades", str.tostring(wins), longCol)
    f_row(perfTb, 4,  "Losing trades", str.tostring(losses), shortCol)
    f_row(perfTb, 5,  "Win rate %", f_fmtNum(wr), color.white)
    f_row(perfTb, 6,  "Profit factor", f_fmtNum(pf), color.white)
    f_row(perfTb, 7,  "Net profit", f_fmtNum(strategy.netprofit), strategy.netprofit >= 0 ? longCol : shortCol)
    f_row(perfTb, 8,  "Max drawdown", f_fmtNum(strategy.max_drawdown), shortCol)
    f_row(perfTb, 9,  "Avg win", f_fmtNum(avgW), longCol)
    f_row(perfTb, 10, "Avg loss", f_fmtNum(avgL), shortCol)
    f_row(perfTb, 11, "Expectancy / trade", f_fmtNum(expct), color.white)
    string statusTxt = not tfTradeOk ? "FVG TF != chart: trading OFF"
      : useTimeFilter ? "Window " + sessWindow + (inWindow ? " (open)" : " (closed)")
      : "Trading enabled"
    f_row(perfTb, 12, "Status", statusTxt, tfTradeOk ? color.white : color.orange)
    f_row(perfTb, 13, "Moved to BE / BE exits", useBreakeven ? str.tostring(beMoveCount) + " / " + str.tostring(beExitCount) : "Breakeven OFF", beLineCol)

//==============================================================================
// 17. PLOTS
//==============================================================================
//Dynamic Bull FVG
max_bull_plot = plot(max_bull_fvg, color = na)
min_bull_plot = plot(min_bull_fvg, color = na)
fill(max_bull_plot, min_bull_plot, color = fvgBullCss)

//Dynamic Bear FVG
max_bear_plot = plot(max_bear_fvg, color = na)
min_bear_plot = plot(min_bear_fvg, color = na)
fill(max_bear_plot, min_bear_plot, color = fvgBearCss)

//Signal window shading
bgcolor(useTimeFilter and showSessBg and inWindow ? color.new(longCol, 94) : na, title = "Signal window")

//Active structure level used for the structure-close condition
plot(showStructLvl ? structLevel : na, "Active structure level", color = structDir == 1 ? sBullCss : sBearCss, style = plot.style_linebr, linewidth = 1)

//==============================================================================
// 18. ALERTS
//==============================================================================
// TRADE ALERTS: create an alert with Condition = this strategy,
// "Order fills only", and Message = {{strategy.order.alert_message}}
// Entry fills send:  TICKER BUY/SELL | Entry | SL | TP | RR
// Exit fills send:   TICKER LONG/SHORT EXIT | SL | TP
//
// BOS / CHoCH PHONE ALERTS: create a SECOND alert on this strategy with
// "alert() function calls only". Every confirmed BOS/CHoCH sends one message,
// e.g.  "MNQ1! 1m BULLISH CHoCH | Broke 20150.25 | Close 20152.50 | 09:14 CT"
// (Breakeven messages also arrive on this alert if "Alert when stop moves to
// breakeven" is on.)

bool tfOk     = not alertsOnly1m or timeframe.period == "1"
bool winOk    = not alertsInWindow or inWindow
bool structGate = structAlertsOn and tfOk and winOk and barstate.isconfirmed

string tfTxt  = timeframe.isminutes ? timeframe.period + "m" : timeframe.period
string tStamp = str.format_time(time_close, "HH:mm", sessTz)

f_structMsg(string dir, string kind, float lvl) =>
    syminfo.ticker + " " + tfTxt + " " + dir + " " + kind + " | Broke " + f_fmtPx(lvl) + " | Close " + f_fmtPx(close) + " | " + tStamp

if structGate
    string msg = ""
    if bullBosEvt and alertBullBosOn
        msg := f_structMsg("BULLISH", "BOS", bullBreakLevel)
    if bullChochEvt and alertBullChochOn
        msg := f_structMsg("BULLISH", "CHoCH", bullBreakLevel)
    if bearBosEvt and alertBearBosOn
        msg := msg + (msg == "" ? "" : "\n") + f_structMsg("BEARISH", "BOS", bearBreakLevel)
    if bearChochEvt and alertBearChochOn
        msg := msg + (msg == "" ? "" : "\n") + f_structMsg("BEARISH", "CHoCH", bearBreakLevel)
    if msg != ""
        alert(msg, alert.freq_once_per_bar_close)

// Optional original FVG alerts (converted from alertcondition to alert())
bool bullFvgNew = bull_count > bull_count[1]
bool bearFvgNew = bear_count > bear_count[1]
bool bullFvgInv = bull_mitigated > bull_mitigated[1]
bool bearFvgInv = bear_mitigated > bear_mitigated[1]
if legacyFvgAlerts
    if bullFvgNew
        alert("Bullish FVG detected — " + syminfo.ticker, alert.freq_once_per_bar_close)
    if bearFvgNew
        alert("Bearish FVG detected — " + syminfo.ticker, alert.freq_once_per_bar_close)
    if bullFvgInv
        alert("Bullish FVG mitigated (closed through) — " + syminfo.ticker, alert.freq_once_per_bar_close)
    if bearFvgInv
        alert("Bearish FVG mitigated (closed through) — " + syminfo.ticker, alert.freq_once_per_bar_close)
````
