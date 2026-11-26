# Fracture Threshold Strategy [JOAT]

- url: https://www.tradingview.com/script/NwMwuyA5-Fracture-Threshold-Strategy-JOAT/
- type: strategy
- pine_id: PUB;7daaa1ee8b8e4993b43d7053c6c087b1
- version: 1.0

## Description

[b]Fracture Threshold Strategy [JOAT][/b]

[b]Introduction[/b]

Fracture Threshold Strategy (FTS) is an open-source, automated Pine Script v6 trading strategy that combines three independent filters — a seven-condition MasterTrend EMA alignment score, a relative volume regime gate, and a session time restriction — into a single, unified entry system. Entry is triggered by an EMA 4/5 crossover when all three filters are simultaneously satisfied. Stop loss is placed at 1.5× ATR from entry. Take profit is set at a 3:1 reward-to-risk ratio by default. All orders are executed on bar close (process_orders_on_close=false), and signals are gated on barstate.isconfirmed to eliminate intrabar repainting.

FTS is designed to demonstrate how institutional-grade filtering layers can be combined into a programmatic strategy with realistic, auditable results. It is not a black box — every condition is visible in the dashboard and the source code is fully open. The strategy description explains the exact logic, the default backtesting parameters, and the limitations of any backtesting approach.

[image]https://www.tradingview.com/x/JBXANtqX/[/image]

[b]Core Concepts[/b]

[b]1. MasterTrend Seven-EMA Alignment Score[/b]

Seven trend conditions are evaluated on each bar. Each satisfied condition contributes one point to a bull or bear score (0–7):

[list]
[*]EMA 4 above/below EMA 5 — fast momentum direction
[*]RSI above/below 50 — momentum confirmation
[*]Price above/below EMA 21 — short-term trend
[*]EMA 21 above/below SMA 50 — medium-term structure
[*]SMA 50 above/below EMA 55 — medium-to-intermediate trend
[*]EMA 55 above/below EMA 89 — intermediate trend
[*]Price above/below EMA 750 — long-term macro trend
[/list]

Entry requires the bull or bear score to equal or exceed the configurable minimum (default: 5 out of 7). This prevents entries during low-conviction, mixed-alignment market conditions.

[b]2. Relative Volume Regime Gate[/b]

Volume regime is measured as the ratio of a short-term volume MA to a long-term volume MA, smoothed by an EMA:

[pine]
float volRatio = ta.ema(volShort / math.max(volLong, 1.0), i_volSmth)
bool  volOK    = volRatio >= i_volMin
[/pine]

The default minimum ratio is 0.90 — entries are blocked when recent volume is more than 10% below the long-term average. This prevents the strategy from entering trades during dead, low-participation conditions where institutional order flow is absent.

[b]3. Session Filter[/b]

Trading is restricted to the London session (08:00–17:00) and New York session (14:00–21:00) in the selected timezone, with both independently toggleable. Entries outside the active sessions are blocked. This keeps the strategy focused on the highest-liquidity periods of the trading day.

[b]4. EMA 4/5 Crossover Entry Trigger[/b]

The entry trigger is an EMA 4 crossover above EMA 5 (for longs) or crossunder (for shorts), evaluated on confirmed bar closes. The crossover is a fast momentum signal — it fires at the beginning of a new short-term directional move. Combined with the full filter stack, it identifies the specific bar where momentum begins aligning with the broader structural trend.

[b]5. ATR Stop Loss and 3:1 Take Profit[/b]

Stop loss is placed at 1.5× ATR from entry. Take profit is placed at 3× the stop distance (configurable). Both levels are computed at entry and fixed — they do not trail. The strategy uses Pine Script's strategy.exit() function with explicit stop and limit prices for clean, non-discretionary execution.

[b]Default Backtesting Properties[/b]

The strategy has been published with the following default Properties settings. These values are used in all performance metrics shown on the chart:

[list]
[*][b]Initial Capital:[/b] $10,000 (realistic for an individual trader)
[*][b]Position Size:[/b] 2% of equity per trade (risk-managed sizing)
[*][b]Commission:[/b] 0.05% per side (representative of standard exchange or broker fees)
[*][b]Slippage:[/b] 2 ticks
[*][b]Pyramiding:[/b] 0 (one trade open at a time)
[*][b]process_orders_on_close:[/b] false (orders execute on the next bar open, not at the signal bar close)
[/list]

Using 2% of equity per trade with a 1.5× ATR stop means the maximum percentage of equity at risk per trade scales with position size dynamically — at a 3:1 RR ratio, three losing trades in a row lose approximately 6% of equity, which is within the TradingView recommended range. A dataset that generates at least 100 trades is recommended for meaningful statistical evaluation. On lower timeframes (5m, 15m) on major equity indices or forex pairs with London and NY sessions active, the default settings typically produce sufficient trade counts.

[b]Features[/b]

[list]
[*][b]Three-Layer Entry Filter:[/b] MasterTrend score, volume regime, and session — all three must be satisfied simultaneously
[*][b]Configurable Minimum Score:[/b] Adjustable minimum MasterTrend alignment score threshold (1–7, default: 5)
[*][b]EMA 4/5 Crossover Trigger:[/b] Fast momentum crossover as entry signal within aligned conditions
[*][b]ATR Stop Loss:[/b] Dynamic stop placement based on current ATR — adapts to instrument volatility
[*][b]Fixed Ratio Take Profit:[/b] 3:1 default reward-to-risk — adjustable
[*][b]Session Restriction:[/b] London and New York sessions independently configurable with timezone setting
[*][b]Volume Regime Gate:[/b] Minimum volume ratio filter blocks entries during low-participation conditions
[*][b]TP/SL Visualization:[/b] Active trade TP and SL boxes drawn from entry and extended on each bar — color changes on outcome
[*][b]Entry Markers:[/b] Triangle plotshapes at long and short entry bars for clear chart identification
[*][b]EMA Reference Plots:[/b] EMA 4, EMA 5, EMA 21, and EMA 750 plotted as reference
[*][b]Non-Repainting:[/b] process_orders_on_close=false; all entry conditions gated on barstate.isconfirmed
[*][b]Dashboard (Top Right):[/b] Live MasterTrend state, volume regime, session, current position, net P&L, win rate, profit factor, max drawdown, average win/loss, and RR ratio
[*][b]Entry Context Labels:[/b] Each entry label now shows the MasterTrend score and volume regime tag at the moment of entry in the format "L 6/7 | V:HI" — full entry context visible on the chart without needing to consult the dashboard
[*][b]Position Candle Tint:[/b] Candles colored green while a long position is open, red while a short position is open — provides an immediate visual record of all trade durations across the full chart history
[*][b]Per-Session Performance Breakdown:[/b] London and New York win rates tracked and displayed separately in the dashboard — identifies which session produces the strongest historical edge for the current instrument and timeframe
[*][b]Expanded Dashboard (15 Rows):[/b] Dashboard expanded to 15 rows — now includes a full session performance section with London and NY win rates alongside the existing strategy performance metrics
[/list]

[b]Input Parameters[/b]

[b]MasterTrend EMA Stack:[/b]
[list]
[*]EMA 4, EMA 5, EMA 21, SMA 50, EMA 55, EMA 89, EMA 750: All periods individually configurable
[*]RSI Length: RSI period for momentum condition (default: 14)
[/list]

[b]Volume Regime Filter:[/b]
[list]
[*]Short Vol MA / Long Vol MA: Volume baseline calculation periods (default: 10, 40)
[*]Vol Smooth: EMA smoothing for ratio (default: 3)
[*]Min Vol Ratio: Minimum ratio threshold for entry permission (default: 0.90)
[/list]

[b]Session Filter:[/b]
[list]
[*]Timezone: Session evaluation timezone (default: America/New_York)
[*]Session Filter: Master toggle (default: enabled)
[*]Allow London / Allow NY: Independent session toggles (both default: enabled)
[/list]

[b]Entry Trigger:[/b]
[list]
[*]EMA4/5 Cross Entry: Use crossover as trigger (default: enabled)
[*]Min MasterTrend Score: Minimum score required for entry (default: 5)
[/list]

[b]Risk Management:[/b]
[list]
[*]ATR Length: ATR period (default: 14)
[*]ATR SL Multiplier: Stop distance as ATR multiple (default: 1.5)
[*]Reward:Risk Ratio: TP multiple (default: 3.0)
[/list]

[b]How to Use This Strategy[/b]

[b]Step 1: Verify the Filter Stack is Active[/b]
The dashboard shows MasterTrend state, volume regime, and current session at all times. Before a trade can occur, all three must be aligned — a bull score ≥ 5, volume ratio ≥ 0.90, and an active London or NY session window.

[b]Step 2: Observe the EMA 4/5 Crossover[/b]
The entry trigger is the EMA 4 crossing EMA 5. With all filters active, the next crossover in the trend direction will generate an entry. The entry is executed at the open of the following bar (process_orders_on_close=false), which is the realistic execution point.

[b]Step 3: Manage the Open Trade[/b]
The TP/SL boxes extend from the entry bar and update on each subsequent bar. The strategy's exit function manages the trade automatically — no manual management is required. The dashboard shows the current position state (LONG / SHORT / FLAT) at all times.

[b]Step 4: Evaluate Backtesting Results Critically[/b]
Past results do not predict future performance. Before drawing conclusions from any backtest, ensure the trade count is at least 100. A small sample (under 50 trades) produces unreliable win rate and profit factor estimates. Test across multiple instruments and timeframes — a strategy that performs well on one asset in one period may not generalize.

[b]Strategy Limitations[/b]

[list]
[*]The EMA 750 requires 750 bars of chart history. On timeframes or instruments with limited bar history, the 750-period EMA will be inaccurate for the first 750 bars — backtest results including those bars should be discounted
[*]Backtesting does not account for liquidity, market impact, or partial fills on real orders. The 2-tick slippage setting is an approximation — on illiquid instruments or during news events, actual slippage may be significantly higher
[*]The EMA 4/5 crossover is a fast signal. In choppy, sideways markets where EMAs cross frequently, the strategy may enter multiple trades quickly that all exit at stop loss before the filter stack re-assesses. The session and volume filters reduce but do not eliminate this behavior
[*]A fixed 3:1 RR ratio requires the market to travel 3× the initial risk without reversing. On short timeframes or on instruments with narrow average ranges relative to ATR, achieving the full TP target may be less frequent than on smoother-trending assets
[*]Commissions, taxes, and regulatory fees vary by broker, instrument, and jurisdiction. The 0.05% commission default is a general estimate — actual trading costs should be substituted with broker-specific values before drawing performance conclusions
[*]This strategy is one specific configuration of the underlying filter system. Adjusting the minimum MasterTrend score, volume threshold, session windows, or RR ratio will produce different results. Any configuration change constitutes a separate strategy with its own performance characteristics
[/list]

[b]Originality Statement[/b]

FTS implements a programmatic entry system by combining a seven-condition quantitative trend score, a relative volume regime gate, and a session time restriction into a unified, fully transparent open-source strategy. This is original for the following reasons:

[list]
[*]The MasterTrend alignment score functions as a structural quality gate — rather than entering on any EMA crossover, the strategy explicitly requires a minimum number of the seven structural conditions to be simultaneously satisfied, producing a much stricter entry criterion than a standard crossover system
[*]The volume regime gate uses a normalized ratio (not a raw volume level) to block entries during low-participation conditions — making the filter relevant across instruments and timeframes without requiring instrument-specific volume threshold calibration
[*]The combination of structural alignment (EMA stack), activity quality (volume regime), and time context (session filter) as three independent prerequisites creates a compounding selectivity effect — the strategy only enters the specific intersection of all three conditions, which is a smaller, higher-conviction subset than any single filter alone
[*]The live dashboard displaying all filter states, position context, and key performance metrics simultaneously provides full transparency into why any given bar does or does not produce a signal, making the strategy auditable in real time
[/list]

[b]Disclaimer[/b]

This strategy is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss. Backtesting results shown are based on historical data and do not guarantee or predict future performance. Past results are not indicative of future results. Commission and slippage values used in backtesting are estimates — actual trading costs will vary. The strategy does not account for all real-world execution factors. Always use proper risk management and consult a qualified financial professional before making trading decisions. The author is not responsible for any trading losses resulting from the use of this strategy.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
strategy("Fracture Threshold Strategy [JOAT]", shorttitle="FTS [JOAT]",
         overlay=true, pyramiding=0,
         default_qty_type=strategy.percent_of_equity, default_qty_value=2.0,
         commission_type=strategy.commission.percent, commission_value=0.05,
         slippage=2, process_orders_on_close=false,
         max_boxes_count=200, max_lines_count=300, max_labels_count=100)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────

// MasterTrend EMA Stack
i_e4         = input.int(4,   "EMA 4",        minval=1,  group="MasterTrend EMA Stack")
i_e5         = input.int(5,   "EMA 5",        minval=1,  group="MasterTrend EMA Stack")
i_e21        = input.int(21,  "EMA 21",       minval=5,  group="MasterTrend EMA Stack")
i_s50        = input.int(50,  "SMA 50",       minval=5,  group="MasterTrend EMA Stack")
i_e55        = input.int(55,  "EMA 55",       minval=5,  group="MasterTrend EMA Stack")
i_e89        = input.int(89,  "EMA 89",       minval=5,  group="MasterTrend EMA Stack")
i_e750       = input.int(750, "EMA 750",      minval=50, group="MasterTrend EMA Stack")
i_rsiLen     = input.int(14,  "RSI Length",   minval=2,  group="MasterTrend EMA Stack")

// Volume Regime Filter
i_shortVol   = input.int(10,  "Short Vol MA",   minval=2,  group="Volume Regime Filter")
i_longVol    = input.int(40,  "Long Vol MA",    minval=5,  group="Volume Regime Filter")
i_volSmth    = input.int(3,   "Vol Smooth",     minval=1,  group="Volume Regime Filter")
i_volMin     = input.float(0.90,"Min Vol Ratio", minval=0.1,step=0.05, group="Volume Regime Filter",
                tooltip="Minimum vol ratio to allow entry — filters out low-activity periods")

// Session Filter
i_tz         = input.string("America/New_York", "Timezone", group="Session Filter",
                 options=["America/New_York","America/Chicago","Europe/London","Asia/Tokyo","UTC"])
i_sessOn     = input.bool(true, "Session Filter",           group="Session Filter")
i_londonOn   = input.bool(true, "Allow London (08:00-17:00)",group="Session Filter")
i_nyOn       = input.bool(true, "Allow NY (14:00-21:00)",   group="Session Filter")

// Entry Trigger
i_emaCross   = input.bool(true, "EMA4/5 Cross Entry",       group="Entry Trigger")
i_minMTScore = input.int(5,     "Min MasterTrend Score",    minval=3, maxval=7, group="Entry Trigger")

// Risk / Reward
i_atrLen     = input.int(14,   "ATR Length",        minval=1,  group="Risk Management")
i_atrMult    = input.float(1.5,"ATR SL Multiplier", minval=0.5,step=0.1, group="Risk Management")
i_rrRatio    = input.float(3.0,"Reward:Risk Ratio", minval=1.0,step=0.5, group="Risk Management")

// Visual
i_showBoxes  = input.bool(true, "Show TP/SL Boxes", group="Visual")
i_dashOn     = input.bool(true, "Show Dashboard",   group="Visual")

// ─────────────────────────────────────────────────────────────────────────────
// INDICATORS
// ─────────────────────────────────────────────────────────────────────────────

float ema4   = ta.ema(close, i_e4)
float ema5   = ta.ema(close, i_e5)
float ema21  = ta.ema(close, i_e21)
float sma50  = ta.sma(close, i_s50)
float ema55  = ta.ema(close, i_e55)
float ema89  = ta.ema(close, i_e89)
float ema750 = ta.ema(close, i_e750)
float rsiVal = ta.rsi(close, i_rsiLen)
float atrVal = ta.atr(i_atrLen)

// Volume regime ratio
float volShort = ta.sma(volume, i_shortVol)
float volLong  = ta.sma(volume, i_longVol)
float volRatio = ta.ema(volShort / math.max(volLong, 1.0), i_volSmth)
bool  volOK    = volRatio >= i_volMin

// ─────────────────────────────────────────────────────────────────────────────
// MASTERTREND 7-EMA SCORE
// ─────────────────────────────────────────────────────────────────────────────

bool c1_bull = ema4  > ema5
bool c2_bull = rsiVal > 50.0
bool c3_bull = close > ema21
bool c4_bull = ema21 > sma50
bool c5_bull = sma50 > ema55
bool c6_bull = ema55 > ema89
bool c7_bull = close > ema750

bool c1_bear = ema4  < ema5
bool c2_bear = rsiVal < 50.0
bool c3_bear = close < ema21
bool c4_bear = ema21 < sma50
bool c5_bear = sma50 < ema55
bool c6_bear = ema55 < ema89
bool c7_bear = close < ema750

int bullScore = (c1_bull ? 1 : 0) + (c2_bull ? 1 : 0) + (c3_bull ? 1 : 0) + (c4_bull ? 1 : 0) + (c5_bull ? 1 : 0) + (c6_bull ? 1 : 0) + (c7_bull ? 1 : 0)
int bearScore = (c1_bear ? 1 : 0) + (c2_bear ? 1 : 0) + (c3_bear ? 1 : 0) + (c4_bear ? 1 : 0) + (c5_bear ? 1 : 0) + (c6_bear ? 1 : 0) + (c7_bear ? 1 : 0)

// ─────────────────────────────────────────────────────────────────────────────
// SESSION FILTER
// ─────────────────────────────────────────────────────────────────────────────

int   barTotalMin = hour(time, i_tz) * 60 + minute(time, i_tz)
bool  inLondon    = barTotalMin >= 480  and barTotalMin < 1020
bool  inNY        = barTotalMin >= 840  and barTotalMin < 1260
bool  sessOK      = not i_sessOn or (i_londonOn and inLondon) or (i_nyOn and inNY)

// ─────────────────────────────────────────────────────────────────────────────
// EMA CROSS TRIGGER
// ─────────────────────────────────────────────────────────────────────────────

bool ema4CrossUp   = ta.crossover( ema4, ema5)
bool ema4CrossDown = ta.crossunder(ema4, ema5)

// Entry trigger: EMA cross (confirmed on close) OR first bar of sufficient score
bool bullTrigger = i_emaCross ? ema4CrossUp   : (c1_bull and not c1_bull[1])
bool bearTrigger = i_emaCross ? ema4CrossDown : (c1_bear and not c1_bear[1])

// ─────────────────────────────────────────────────────────────────────────────
// COMPOSITE ENTRY CONDITIONS
// ─────────────────────────────────────────────────────────────────────────────

bool longEntry  = barstate.isconfirmed and
                  bullTrigger and
                  bullScore >= i_minMTScore and
                  volOK and sessOK and
                  strategy.position_size == 0

bool shortEntry = barstate.isconfirmed and
                  bearTrigger and
                  bearScore >= i_minMTScore and
                  volOK and sessOK and
                  strategy.position_size == 0

// ─────────────────────────────────────────────────────────────────────────────
// PERSISTENT TRADE STATE — TP/SL boxes
// ─────────────────────────────────────────────────────────────────────────────

var box   slBox    = na
var box   tpBox    = na
var label slLbl    = na
var label tpLbl    = na
var float slLvl    = na
var float tpLvl    = na
var float entryPx  = na
var bool  inLong   = false
var bool  inShort  = false
var int   lonTrd   = 0
var int   lonWin   = 0
var int   nyTrd    = 0
var int   nyWin    = 0
var bool  sessTrkd = false
var string entSess = ""

// ─────────────────────────────────────────────────────────────────────────────
// EXECUTE ENTRIES
// ─────────────────────────────────────────────────────────────────────────────

if longEntry
    entryPx  := close
    entSess  := inLondon ? "London" : inNY ? "NY" : "Off"
    sessTrkd := false
    float slDist = atrVal * i_atrMult
    slLvl   := entryPx - slDist
    tpLvl   := entryPx + slDist * i_rrRatio
    inLong  := true
    inShort := false

    strategy.entry("Long", strategy.long)
    strategy.exit("Long Exit", "Long", stop=slLvl, limit=tpLvl)

    if i_showBoxes
        box.delete(slBox)
        box.delete(tpBox)
        label.delete(slLbl)
        label.delete(tpLbl)
        slBox := box.new(bar_index, entryPx, bar_index + 40, slLvl,
                         border_color=color.new(#ef4444, 50), bgcolor=color.new(#ef4444, 88),
                         border_width=1)
        tpBox := box.new(bar_index, tpLvl, bar_index + 40, entryPx,
                         border_color=color.new(#22c55e, 50), bgcolor=color.new(#22c55e, 88),
                         border_width=1)
        slLbl := label.new(bar_index + 40, slLvl, "SL " + str.format("{0,number,#.##}", slLvl),
                           color=color.new(#ef4444, 60), textcolor=color.white,
                           style=label.style_label_left, size=size.tiny)
        tpLbl := label.new(bar_index + 40, tpLvl, "TP " + str.format("{0,number,#.##}", tpLvl),
                           color=color.new(#22c55e, 60), textcolor=color.white,
                           style=label.style_label_left, size=size.tiny)

if shortEntry
    entryPx  := close
    entSess  := inLondon ? "London" : inNY ? "NY" : "Off"
    sessTrkd := false
    float slDist = atrVal * i_atrMult
    slLvl   := entryPx + slDist
    tpLvl   := entryPx - slDist * i_rrRatio
    inLong  := false
    inShort := true

    strategy.entry("Short", strategy.short)
    strategy.exit("Short Exit", "Short", stop=slLvl, limit=tpLvl)

    if i_showBoxes
        box.delete(slBox)
        box.delete(tpBox)
        label.delete(slLbl)
        label.delete(tpLbl)
        slBox := box.new(bar_index, slLvl, bar_index + 40, entryPx,
                         border_color=color.new(#ef4444, 50), bgcolor=color.new(#ef4444, 88),
                         border_width=1)
        tpBox := box.new(bar_index, entryPx, bar_index + 40, tpLvl,
                         border_color=color.new(#22c55e, 50), bgcolor=color.new(#22c55e, 88),
                         border_width=1)
        slLbl := label.new(bar_index + 40, slLvl, "SL " + str.format("{0,number,#.##}", slLvl),
                           color=color.new(#ef4444, 60), textcolor=color.white,
                           style=label.style_label_left, size=size.tiny)
        tpLbl := label.new(bar_index + 40, tpLvl, "TP " + str.format("{0,number,#.##}", tpLvl),
                           color=color.new(#22c55e, 60), textcolor=color.white,
                           style=label.style_label_left, size=size.tiny)

// Extend active boxes
if (inLong or inShort) and i_showBoxes and strategy.position_size != 0
    if not na(slBox)
        box.set_right(slBox, bar_index)
        box.set_right(tpBox, bar_index)
        label.set_x(slLbl, bar_index)
        label.set_x(tpLbl, bar_index)

// Track session outcome when trade just closed
bool justClosed = (inLong or inShort) and strategy.position_size == 0 and not sessTrkd
if justClosed
    sessTrkd := true
    bool wasWin = strategy.wintrades > 0 and strategy.closedtrades > 0
    if entSess == "London"
        lonTrd += 1
        if wasWin
            lonWin += 1
    else if entSess == "NY"
        nyTrd += 1
        if wasWin
            nyWin += 1

// Reset flags when flat
if strategy.position_size == 0
    inLong  := false
    inShort := false

// ─────────────────────────────────────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────────────────────────────────────

plot(ema750, "EMA 750", color=color.new(#6366f1, 40), linewidth=2)
plot(ema21,  "EMA 21",  color=color.new(#3b82f6, 60), linewidth=1)
plot(ema4,   "EMA 4",   color=color.new(#f59e0b, 65), linewidth=1)
plot(ema5,   "EMA 5",   color=color.new(#ef4444, 65), linewidth=1)

// Entry markers
plotshape(longEntry,  "Long Entry",  shape.triangleup,   location.belowbar,
          color=color.new(#10b981, 10), size=size.small)
plotshape(shortEntry, "Short Entry", shape.triangledown, location.abovebar,
          color=color.new(#f43f5e, 10), size=size.small)

// Entry context labels
if longEntry
    string volTag = volRatio >= 1.80 ? "EXT" : volRatio >= 1.20 ? "HI" : "OK"
    label.new(bar_index, low - atrVal * 0.8, "L " + str.tostring(bullScore) + "/7 | V:" + volTag,
         style=label.style_label_up,
         color=color.new(#10b981, 50),
         textcolor=color.white,
         size=size.tiny)

if shortEntry
    string volTag2 = volRatio >= 1.80 ? "EXT" : volRatio >= 1.20 ? "HI" : "OK"
    label.new(bar_index, high + atrVal * 0.8, "S " + str.tostring(bearScore) + "/7 | V:" + volTag2,
         style=label.style_label_down,
         color=color.new(#f43f5e, 50),
         textcolor=color.white,
         size=size.tiny)

// ── POSITION CANDLE TINT ─────────────────────────────────────────────────────
barcolor(strategy.position_size > 0 ? color.new(#10b981, 80) : strategy.position_size < 0 ? color.new(#f43f5e, 80) : na, title="Position Tint")

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────

if i_dashOn and barstate.islast
    float netPnl   = strategy.netprofit
    int   totTrd   = strategy.closedtrades
    float winRate  = totTrd > 0 ? float(strategy.wintrades) / float(totTrd) * 100.0 : 0.0
    float pf       = strategy.grossloss != 0.0 ? math.abs(strategy.grossprofit / strategy.grossloss) : 0.0
    float maxDD    = strategy.max_drawdown
    float avgWin   = strategy.wintrades   > 0 ? strategy.grossprofit  / float(strategy.wintrades)   : 0.0
    float avgLoss  = strategy.losstrades  > 0 ? strategy.grossloss    / float(strategy.losstrades)  : 0.0

    // Current regime status
    string volStr  = volRatio >= 1.80 ? "EXTREME" : volRatio >= 1.20 ? "HIGH" : volRatio >= 0.70 ? "NORMAL" : "LOW"
    string mtStr   = bullScore >= i_minMTScore ? "BULL " + str.tostring(bullScore) + "/7" :
                     bearScore >= i_minMTScore ? "BEAR " + str.tostring(bearScore) + "/7" :
                     "NEUTRAL"
    string sessStr = inLondon ? "London" : inNY ? "New York" : "Off"

    table dash = table.new(position.top_right, 2, 15,
                           bgcolor=color.new(#0f172a, 10),
                           border_color=color.new(#334155, 80),
                           border_width=1, frame_color=color.new(#334155, 60),
                           frame_width=1)

    // Header
    table.cell(dash, 0, 0, "Fracture Threshold Strategy [JOAT]",
               text_color=color.new(#f8fafc, 0), text_size=size.small,
               bgcolor=color.new(#1e293b, 10), text_halign=text.align_center)
    table.cell(dash, 1, 0, "", text_size=size.normal, bgcolor=color.new(#1e293b, 10))

    // Live state section
    color mtTxtCol = bullScore >= i_minMTScore ? color.new(#14b8a6, 0) : bearScore >= i_minMTScore ? color.new(#f43f5e, 0) : color.new(#64748b, 0)
    table.cell(dash, 0, 1, "MasterTrend", text_color=color.new(#94a3b8, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 25))
    table.cell(dash, 1, 1, mtStr, text_color=mtTxtCol, text_size=size.normal, bgcolor=color.new(#1e293b, 25))

    color volCol = volRatio >= 1.80 ? color.new(#ef4444, 0) : volRatio >= 1.20 ? color.new(#f59e0b, 0) : volRatio >= 0.70 ? color.new(#3b82f6, 0) : color.new(#475569, 0)
    table.cell(dash, 0, 2, "Vol Regime", text_color=color.new(#94a3b8, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 30))
    table.cell(dash, 1, 2, volStr + " (" + str.format("{0,number,#.##}", volRatio) + ")", text_color=volCol, text_size=size.normal, bgcolor=color.new(#1e293b, 30))

    color sessTxtCol = sessStr == "Off" ? color.new(#475569, 0) : color.new(#22c55e, 0)
    table.cell(dash, 0, 3, "Session", text_color=color.new(#94a3b8, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 30))
    table.cell(dash, 1, 3, sessStr, text_color=sessTxtCol, text_size=size.normal, bgcolor=color.new(#1e293b, 30))

    string posStr = strategy.position_size > 0 ? "LONG" : strategy.position_size < 0 ? "SHORT" : "FLAT"
    color  posCol = strategy.position_size > 0 ? color.new(#14b8a6, 0) : strategy.position_size < 0 ? color.new(#f43f5e, 0) : color.new(#64748b, 0)
    table.cell(dash, 0, 4, "Position", text_color=color.new(#94a3b8, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 30))
    table.cell(dash, 1, 4, posStr, text_color=posCol, text_size=size.normal, bgcolor=color.new(#1e293b, 30))

    // Divider
    table.cell(dash, 0, 5, "", bgcolor=color.new(#334155, 60))
    table.cell(dash, 1, 5, "", bgcolor=color.new(#334155, 60))

    // Performance section
    color netCol = netPnl >= 0 ? color.new(#22c55e, 0) : color.new(#ef4444, 0)
    table.cell(dash, 0, 6, "Net P&L", text_color=color.new(#94a3b8, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 25))
    table.cell(dash, 1, 6, str.format("{0,number,#.##}", netPnl), text_color=netCol, text_size=size.normal, bgcolor=color.new(#1e293b, 25))

    color wrCol = winRate >= 55.0 ? color.new(#22c55e, 20) : winRate >= 45.0 ? color.new(#f59e0b, 20) : color.new(#ef4444, 20)
    table.cell(dash, 0, 7, "Win Rate", text_color=color.new(#94a3b8, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 30))
    table.cell(dash, 1, 7, str.format("{0,number,#.#}%", winRate) + " (" + str.tostring(totTrd) + ")", text_color=color.new(#f8fafc, 0), text_size=size.normal, bgcolor=wrCol)

    color pfCol = pf >= 1.5 ? color.new(#22c55e, 0) : pf >= 1.0 ? color.new(#f59e0b, 0) : color.new(#ef4444, 0)
    table.cell(dash, 0, 8, "Profit Factor", text_color=color.new(#94a3b8, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 30))
    table.cell(dash, 1, 8, str.format("{0,number,#.##}", pf), text_color=pfCol, text_size=size.normal, bgcolor=color.new(#1e293b, 30))

    table.cell(dash, 0, 9, "Max DD", text_color=color.new(#94a3b8, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 30))
    table.cell(dash, 1, 9, str.format("{0,number,#.##}", maxDD), text_color=color.new(#ef4444, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 30))

    table.cell(dash, 0, 10, "Avg Win", text_color=color.new(#94a3b8, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 30))
    table.cell(dash, 1, 10, str.format("{0,number,#.##}", avgWin), text_color=color.new(#22c55e, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 30))

    table.cell(dash, 0, 11, "Avg Loss", text_color=color.new(#94a3b8, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 30))
    table.cell(dash, 1, 11, str.format("{0,number,#.##}", avgLoss), text_color=color.new(#ef4444, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 30))

    // RR display
    table.cell(dash, 0, 12, "RR Ratio", text_color=color.new(#94a3b8, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 10))
    table.cell(dash, 1, 12, "1:" + str.format("{0,number,#.#}", i_rrRatio), text_color=color.new(#a78bfa, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 10))

    // Session performance rows
    float lonWR2 = lonTrd > 0 ? lonWin * 100.0 / lonTrd : 0.0
    float nyWR2  = nyTrd  > 0 ? nyWin  * 100.0 / nyTrd  : 0.0
    color lonWRcol = lonWR2 >= 55.0 ? color.new(#22c55e, 0) : lonWR2 >= 45.0 ? color.new(#f59e0b, 0) : color.new(#ef4444, 0)
    color nyWRcol  = nyWR2  >= 55.0 ? color.new(#22c55e, 0) : nyWR2  >= 45.0 ? color.new(#f59e0b, 0) : color.new(#ef4444, 0)
    table.cell(dash, 0, 13, "London WR", text_color=color.new(#3b82f6, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 25))
    table.cell(dash, 1, 13, str.tostring(lonWin) + "/" + str.tostring(lonTrd) + " (" + str.format("{0,number,#.#}%", lonWR2) + ")", text_color=lonWRcol, text_size=size.normal, bgcolor=color.new(#1e293b, 25))

    table.cell(dash, 0, 14, "NY WR", text_color=color.new(#10b981, 0), text_size=size.normal, bgcolor=color.new(#1e293b, 25))
    table.cell(dash, 1, 14, str.tostring(nyWin) + "/" + str.tostring(nyTrd) + " (" + str.format("{0,number,#.#}%", nyWR2) + ")", text_color=nyWRcol, text_size=size.normal, bgcolor=color.new(#1e293b, 25))
````
