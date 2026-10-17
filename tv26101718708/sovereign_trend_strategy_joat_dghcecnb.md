# Sovereign Trend Strategy [JOAT]

- url: https://www.tradingview.com/script/DGHCEcnB-Sovereign-Trend-Strategy-JOAT/
- type: strategy
- pine_id: PUB;f03594b6e29f4727bebaaa91ca7ca704
- version: 1.0

## Description

Sovereign Trend Strategy [JOAT]

[b]Introduction[/b]

The Sovereign Trend Strategy is a systematic, rules-based trend-following strategy built on the SMEMA (SMA of EMA) crossover engine — a double-smoothed moving average system that removes the erratic noise of raw EMA crossovers while remaining faster to respond than pure SMA systems. It enters long and short trades on SMEMA fast/slow crossovers, applies four optional confirmation filters (ADX, RSI, volatility ratio, and baseline), and manages each trade through a full exit framework: stop loss, two take-profit levels with partial close at TP1, a dynamic trailing stop, a trend-reversal exit, and a maximum bars cap that forces turnover.

This is a strategy designed to trade [i]constantly[/i] — the default configuration is tuned for maximum trade frequency across all assets and timeframes, with all optional filters disabled so that every valid SMEMA crossover generates a signal. Traders seeking higher-quality entries can enable the ADX, RSI, baseline, or volatility filters individually to raise the bar.

[image]https://www.tradingview.com/x/L5xx7eEL/[/image]

[b]Core Concepts[/b]

[b]SMEMA — Double-Smoothed Moving Average Engine[/b]

The SMEMA construction applies a simple moving average on top of an exponential moving average, producing a line that is more responsive than a plain SMA but smoother than a raw EMA:

[pine]
smema(float src, int len) =>
    ta.sma(ta.ema(src, len), len)

float fast     = smema(close, smFast)
float slow     = smema(close, smSlow)
float baseline = smema(close, smBase)
[/pine]

Three SMEMA lines are computed: a fast line (default length 2), a slow line (default length 5), and a longer baseline (default length 15). Crossovers between fast and slow generate the entry signals. The baseline provides an optional directional filter when enabled.

[b]Entry Conditions[/b]

Long entries fire when the fast SMEMA crosses above the slow SMEMA with all active filters passing:

[pine]
bool xUp    = ta.crossover(fast, slow)
bool longOk = xUp and adxOk and rsiLongOk and volOk and baseOk
              and warmed and inDateRange and barstate.isconfirmed and doLong
[/pine]

Short entries mirror this on downward crossovers. Entries only fire when there are no open trades (pyramiding disabled), ensuring clean one-trade-at-a-time management.

[b]Trade Management Framework[/b]

Each trade uses ATR-based levels calculated at entry:

| Level | Default Multiplier | Purpose |
|-------|-------------------|---------|
| Stop Loss | 1.8× ATR | Full position stop |
| TP1 | 2.5× ATR | 50% partial close, breakeven stop move |
| TP2 | 4.5× ATR | Full position close |
| Trailing Stop | 1.5× ATR | Activated after TP1 hit |

After TP1 triggers, the stop-loss is moved to the entry price (breakeven). The trailing stop then follows price by 1.5× ATR, locking in profit while letting the remaining position run toward TP2. This staged approach captures quick-reaction profits at TP1 and rides momentum toward TP2.

[b]Six Exit Paths[/b]

[pine]
// Priority order for long exits:
// 1. Stop Loss   — low <= entrySL
// 2. TP1         — high >= entryTP1 (50% partial, breakeven stop set)
// 3. TP2         — high >= entryTP2 (full close after TP1 hit)
// 4. Trailing    — low <= trlStop (after TP1 hit)
// 5. Reversal    — fast SMEMA crosses below slow (xDn confirmed)
// 6. Max Bars    — barsInTrd >= maxBars
[/pine]

The max bars exit (default 10) is particularly important for trade frequency — it guarantees no position is held longer than 10 bars regardless of whether any other exit triggers, creating rapid capital recycling and enabling 100+ trade sample sizes even on daily timeframes.

[b]Optional Confirmation Filters[/b]

All four filters are disabled by default and can be enabled individually:

[list]
[*] [b]ADX Filter[/b] — requires ADX above a minimum threshold before entry. Prevents entries in ranging, low-momentum markets.
[*] [b]RSI Filter[/b] — requires RSI above the bull minimum for longs (default 52) or below the bear maximum for shorts (default 48). Confirms momentum alignment with direction.
[*] [b]Volatility Ratio Filter[/b] — requires current ATR to be at least a configurable fraction of its own SMA. Filters out squeeze conditions where ATR is compressed.
[*] [b]Baseline Filter[/b] — requires close to be above the baseline SMEMA for longs and below for shorts. Adds a medium-term trend confirmation layer.
[/list]

[b]Strategy Parameters (Backtesting Standards)[/b]

[list]
[*] Initial capital: $10,000 (realistic for the average retail trader)
[*] Position size: 100% of equity (maximizes trade count visibility in backtest)
[*] Commission: 0.05% per side (appropriate for most spot and futures markets)
[*] Slippage: 2 ticks (conservative estimate for liquid instruments)
[*] Pyramiding: 0 (no compounding positions)
[/list]

[b]Features[/b]

[list]
[*] SMEMA fast/slow crossover entry engine with three configurable period lengths
[*] Full trade management: ATR-based SL, TP1 (50% partial), TP2 (full), trailing stop, reversal exit, max bars exit
[*] Breakeven stop migration to entry price after TP1 hit
[*] Four optional confirmation filters: ADX, RSI, volatility ratio, and SMEMA baseline
[*] Long-only, short-only, or both directions configurable
[*] Date range filter for restricted backtesting windows
[*] Live SL, TP1, and TP2 dashed lines drawn on the chart while a trade is open
[*] SMEMA ribbon fill between fast and slow lines, colored by crossover direction
[*] ▲ LONG / ▼ SHORT signal labels at every entry signal
[*] Dashboard: position, SMEMA cross direction, ADX, RSI, vol ratio, trade count, win rate, net P&L, bars in trade, settings summary
[*] Alerts for long entry and short entry signals
[*] Webhook JSON alert format
[*] Watermark
[/list]

[b]Input Parameters[/b]

[b]SMEMA Engine[/b]
[list]
[*] Fast SMEMA Length — period for the fast crossover line (default 2)
[*] Slow SMEMA Length — period for the slow crossover line (default 5)
[*] Baseline SMEMA — period for the optional trend baseline (default 15)
[/list]

[b]Trend Filter[/b]
[list]
[*] ADX Length — period for ADX / DMI calculation (default 14)
[*] Min ADX — minimum ADX value required before entry (default 18)
[*] Enable ADX Filter — master toggle (default off)
[/list]

[b]RSI Filter[/b]
[list]
[*] RSI Length — period for RSI calculation (default 14)
[*] RSI Bull Min — minimum RSI for long entries (default 52)
[*] RSI Bear Max — maximum RSI for short entries (default 48)
[*] Enable RSI Filter — master toggle (default off)
[/list]

[b]Volatility Filter[/b]
[list]
[*] ATR Length — lookback for ATR (default 14)
[*] ATR Smooth — lookback for the ATR average used in ratio (default 20)
[*] Min Vol Ratio — ATR/AvgATR minimum threshold (default 0.8)
[*] Enable Vol Ratio Filter — master toggle (default off)
[/list]

[b]Baseline Filter[/b]
[list]
[*] Enable Baseline Filter — when on, requires close above baseline for longs and below for shorts (default off)
[/list]

[b]Trade Management[/b]
[list]
[*] Stop-Loss ATR Mult — distance of initial stop from entry in ATR units (default 1.8)
[*] TP1 ATR Mult — distance of first take-profit from entry (default 2.5)
[*] TP2 ATR Mult — distance of second take-profit from entry (default 4.5)
[*] Use Trailing Stop — enables dynamic trailing after TP1 (default on)
[*] Trailing Stop ATR Mult — trail distance in ATR units (default 1.5)
[*] Max Bars in Trade — maximum bars before forced exit (default 10)
[/list]

[b]Trade Direction[/b]
[list]
[*] Allow Long Trades — toggles long entry signals (default on)
[*] Allow Short Trades — toggles short entry signals (default on)
[/list]

[b]Date Range[/b]
[list]
[*] Enable Date Filter — restricts backtesting to a specific window
[*] From Date / To Date — start and end of the active period
[/list]

[b]Visuals[/b]
[list]
[*] Bull Color — cyan default for upside elements
[*] Bear Color — red default for downside elements
[*] Neutral Color — gray for baseline and neutral dashboard text
[*] Show Dashboard — live performance and settings panel
[*] Show Watermark
[*] Show Signal Labels — ▲ LONG / ▼ SHORT markers on entry bars
[*] Show SMEMA Bands — toggles the ribbon and three SMEMA line plots
[/list]

[b]How to Use[/b]

[list]
[*] Add the strategy to any chart. The default settings are tuned for high trade frequency — no filters enabled, fast periods of 2/5, max bars 10.
[*] Run the Strategy Tester to review backtest performance. Check that the trade count is above 100 on your chosen timeframe and symbol before drawing any performance conclusions.
[*] To increase signal quality at the cost of trade frequency, enable filters one at a time: start with the ADX filter to eliminate ranging entries, then add RSI if you want additional momentum confirmation.
[*] Use the SL/TP dashed lines drawn on-chart during live trades to monitor your risk levels visually in real time.
[*] Set the Long Entry and Short Entry alerts to receive notifications. Use Webhook JSON format to route signals to automation platforms.
[*] Adjust the ATR multipliers to fit the volatility profile of your market. Higher-volatility assets like altcoins benefit from wider stops (2.0–2.5×) and wider TP levels. Lower-volatility assets like indices may work better with tighter parameters.
[*] The Max Bars in Trade parameter is the most powerful lever for trade frequency. Reducing it to 5–7 generates very high trade counts. Increasing it to 20–40 gives trades more room to develop but reduces total trade count.
[/list]

[b]Indicator Limitations[/b]

[list]
[*] SMEMA crossovers are inherently lagging — by definition, the crossover confirms a direction change after it has already begun. In fast-moving markets this means entries will not be at the exact turning point.
[*] The default configuration (all filters off, max bars 10) optimizes for trade count and sample size rather than highest possible win rate. Enabling filters will reduce trade count but may improve per-trade quality — test thoroughly on your symbol and timeframe before live use.
[*] The 100% equity position sizing in the backtest is chosen to keep commission effects proportional and performance metrics visible at small capital sizes. This does not represent a recommendation to risk your entire account on any trade.
[*] Backtested results are not a guarantee of future performance. Past performance under any parameters does not imply future results.
[*] The strategy uses `calc_on_every_tick=false` — all orders execute at bar close, which is more realistic than tick-by-tick simulation but means intrabar SL/TP wicks may not be captured accurately in the backtest.
[/list]

[b]Originality Statement[/b]

The Sovereign Trend Strategy is an original Pine Script v6 strategy publication. The SMEMA (SMA of EMA) double-smoothing construction is an original baseline engineering choice that produces a distinct crossover behavior not replicated by standard EMA or SMA crossover systems. The six-path exit framework, the staged TP1/breakeven/trailing/TP2 management sequence, and the modular optional filter architecture are original design decisions. The strategy.position_size derivation of position state (avoiding the Pine Script v6 timing bug with strategy.opentrades and manual boolean flags) is an original technical solution developed for this publication.

[b]Disclaimer[/b]

This is a backtested strategy provided for educational purposes only. It does not constitute financial advice or a recommendation to trade any specific instrument. All trading involves risk of capital loss. Backtested performance does not guarantee future results. Commission, slippage, and real-world execution conditions will differ from backtest simulations. Always perform your own analysis and consult a licensed financial professional before trading with real capital.

-Made with passion by jackofalltrades

## Source Code

````pine
//@version=6
strategy("Sovereign Trend Strategy [JOAT]", shorttitle="STS [JOAT]", overlay=true,
     initial_capital=10000, default_qty_type=strategy.percent_of_equity,
     default_qty_value=100, commission_type=strategy.commission.percent,
     commission_value=0.05, slippage=2, calc_on_every_tick=false,
     pyramiding=0, close_entries_rule="ANY", max_labels_count=200,
     max_lines_count=200)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 1 — INPUTS
// ═══════════════════════════════════════════════════════════════════════════════

// SMEMA Settings
sGrp         = "SMEMA Engine"
int  smFast  = input.int(2,  "Fast SMEMA Length",  minval=2, maxval=30,  group=sGrp,
    tooltip="Default 2 — ultra-short period generates maximum crossover frequency on all timeframes")
int  smSlow  = input.int(5,  "Slow SMEMA Length",  minval=3, maxval=60,  group=sGrp)
int  smBase  = input.int(15, "Baseline SMEMA",     minval=5, maxval=100, group=sGrp)

// Trend Filter
tGrp         = "Trend Filter"
int  adxLen  = input.int(14, "ADX Length",         minval=5,  maxval=30, group=tGrp)
float adxMin = input.float(18.0, "Min ADX (trend threshold)", minval=5.0, maxval=50.0, step=1.0, group=tGrp)
bool useAdx  = input.bool(false, "Enable ADX Filter", group=tGrp,
    tooltip="Disabled by default to maximize trade count across all timeframes")

// RSI Filter
rGrp         = "RSI Filter"
int  rsiLen  = input.int(14, "RSI Length",         minval=5,  maxval=30, group=rGrp)
float rsiBull= input.float(52.0, "RSI Bull Min",   minval=40.0, maxval=70.0, step=1.0, group=rGrp)
float rsiBear= input.float(48.0, "RSI Bear Max",   minval=30.0, maxval=60.0, step=1.0, group=rGrp)
bool useRsi  = input.bool(false, "Enable RSI Filter", group=rGrp,
    tooltip="Disabled by default to maximize trade count across all timeframes")

// Volatility Filter
vGrp         = "Volatility Filter"
int  atrLen  = input.int(14, "ATR Length",         minval=5,  maxval=30, group=vGrp)
int  atrSmth = input.int(20, "ATR Smooth (squeeze filter)", minval=5, maxval=50, group=vGrp)
float minVolR= input.float(0.8, "Min Vol Ratio (ATR/AvgATR)", minval=0.3, maxval=2.0, step=0.05, group=vGrp)
bool useVol  = input.bool(false, "Enable Vol Ratio Filter", group=vGrp)

// Baseline Filter
bGrp         = "Baseline Filter"
bool useBase = input.bool(false, "Enable Baseline Filter (close vs SMEMA baseline)", group=bGrp,
    tooltip="When enabled: longs require close > baseline SMEMA, shorts require close < baseline. Disable for maximum trade count.")

// Trade Management
tmGrp        = "Trade Management"
float slMult = input.float(1.8, "Stop-Loss ATR Mult",    minval=0.5, maxval=5.0, step=0.1, group=tmGrp)
float tp1M   = input.float(2.5, "TP1 ATR Mult",          minval=1.0, maxval=8.0, step=0.1, group=tmGrp)
float tp2M   = input.float(4.5, "TP2 ATR Mult",          minval=2.0, maxval=12.0, step=0.1, group=tmGrp)
bool useTrl  = input.bool(true, "Use Trailing Stop",      group=tmGrp)
float trlM   = input.float(1.5, "Trailing Stop ATR Mult", minval=0.5, maxval=4.0, step=0.1, group=tmGrp)
int   maxBars= input.int(10,   "Max Bars in Trade",       minval=2,  maxval=200, group=tmGrp,
    tooltip="Default 10 — tight cap on trade duration forces rapid turnover and maximizes trade count")

// Direction
dGrp         = "Trade Direction"
bool doLong  = input.bool(true,  "Allow Long Trades",  group=dGrp)
bool doShort = input.bool(true,  "Allow Short Trades", group=dGrp)

// Date filter
dtGrp        = "Date Range"
bool useDt   = input.bool(false, "Enable Date Filter", group=dtGrp)
int  dtFrom  = input.time(timestamp("2020-01-01"), "From Date", group=dtGrp, confirm=false)
int  dtTo    = input.time(timestamp("2030-12-31"), "To  Date",  group=dtGrp, confirm=false)

// Visual
visGrp       = "Visuals"
color cUp    = input.color(#00E5FF, "Bull Color",    group=visGrp)
color cDn    = input.color(#FF4B4B, "Bear Color",    group=visGrp)
color cNeutral= input.color(#B0BEC5, "Neutral Color", group=visGrp)
bool showDash= input.bool(true, "Show Dashboard",    group=visGrp)
bool showWm  = input.bool(true, "Show Watermark",    group=visGrp)
bool showSig = input.bool(true, "Show Signal Labels", group=visGrp)
bool showBand= input.bool(true, "Show SMEMA Bands",  group=visGrp)

// Alerts
alrtGrp      = "Alerts"
bool useJson = input.bool(false, "Webhook JSON Format", group=alrtGrp)
string ticker= syminfo.ticker

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 2 — CORE FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════

safeDiv(float a, float b, float fallback=0.0) =>
    not na(b) and b != 0.0 ? a / b : fallback

// SMEMA: double-smoothed adaptive baseline
smema(float src, int len) =>
    ta.sma(ta.ema(src, len), len)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 3 — CORE CALCULATIONS
// ═══════════════════════════════════════════════════════════════════════════════

int  WARMUP     = math.max(smSlow * 2, adxLen * 2, rsiLen + 5, 60)
bool warmed     = bar_index >= WARMUP
bool inDateRange= not useDt or (time >= dtFrom and time <= dtTo)

// SMEMA lines
float fast      = smema(close, smFast)
float slow      = smema(close, smSlow)
float baseline  = smema(close, smBase)

// ATR
float atrVal    = ta.atr(atrLen)
float avgAtr    = ta.sma(atrVal, atrSmth)
float volRatio  = safeDiv(atrVal, avgAtr, 1.0)

// ADX / DMI
[diPlus, diMinus, adxVal] = ta.dmi(adxLen, adxLen)

// RSI
float rsiVal    = ta.rsi(close, rsiLen)

// Crossover signals (confirmed only)
bool xUp        = ta.crossover(fast, slow)
bool xDn        = ta.crossunder(fast, slow)

// Filters
bool adxOk      = not useAdx  or adxVal >= adxMin
bool rsiLongOk  = not useRsi  or rsiVal >= rsiBull
bool rsiShortOk = not useRsi  or rsiVal <= rsiBear
bool volOk      = not useVol  or volRatio >= minVolR
bool baseOk     = not useBase or close > baseline
bool baseShortOk= not useBase or close <= baseline

// Composite entry conditions
bool longOk     = xUp and adxOk and rsiLongOk  and volOk and baseOk       and warmed and inDateRange and barstate.isconfirmed and doLong
bool shortOk    = xDn and adxOk and rsiShortOk and volOk and baseShortOk  and warmed and inDateRange and barstate.isconfirmed and doShort

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 4 — TRADE MANAGEMENT STATE
// ═══════════════════════════════════════════════════════════════════════════════

var float entryPrice = na
var float entrySL    = na
var float entryTP1   = na
var float entryTP2   = na
var float trlStop    = na
var int   barsInTrd  = 0
var bool  tp1Hit     = false

// Derive position state from strategy.position_size — avoids timing bug where
// manual bool flags get reset by the opentrades==0 check on the same entry bar.
bool inLong  = strategy.position_size > 0
bool inShort = strategy.position_size < 0

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 5 — STRATEGY ENTRIES & EXITS
// ═══════════════════════════════════════════════════════════════════════════════

// ── LONG ENTRY ──────────────────────────────────────────────────────────────
// FIX: `not strategy.opentrades` is a type error (int → bool). Use == 0 comparison.
if longOk and strategy.opentrades == 0
    strategy.entry("Long", strategy.long, comment="L")
    entryPrice := close
    entrySL    := close - slMult  * atrVal
    entryTP1   := close + tp1M    * atrVal
    entryTP2   := close + tp2M    * atrVal
    trlStop    := close - trlM    * atrVal
    tp1Hit     := false
    barsInTrd  := 0

// ── SHORT ENTRY ─────────────────────────────────────────────────────────────
if shortOk and strategy.opentrades == 0
    strategy.entry("Short", strategy.short, comment="S")
    entryPrice := close
    entrySL    := close + slMult  * atrVal
    entryTP1   := close - tp1M    * atrVal
    entryTP2   := close - tp2M    * atrVal
    trlStop    := close + trlM    * atrVal
    tp1Hit     := false
    barsInTrd  := 0

// ── BAR COUNTER ─────────────────────────────────────────────────────────────
if strategy.opentrades > 0
    barsInTrd += 1

// ── TRAILING STOP UPDATE ────────────────────────────────────────────────────
if useTrl and inLong and strategy.opentrades > 0
    float newTrl = close - trlM * atrVal
    if newTrl > trlStop
        trlStop := newTrl

if useTrl and inShort and strategy.opentrades > 0
    float newTrl = close + trlM * atrVal
    if newTrl < trlStop
        trlStop := newTrl

// ── LONG EXITS ──────────────────────────────────────────────────────────────
if inLong and strategy.opentrades > 0
    // Stop Loss
    if low <= entrySL
        strategy.close("Long", comment="SL", immediately=false)

    // TP1: partial (50%)
    else if not tp1Hit and high >= entryTP1
        strategy.close("Long", qty_percent=50.0, comment="TP1", immediately=false)
        tp1Hit  := true
        trlStop := entryPrice  // Move stop to breakeven after TP1

    // TP2: full
    else if tp1Hit and high >= entryTP2
        strategy.close("Long", comment="TP2", immediately=false)

    // Trailing Stop
    else if useTrl and tp1Hit and low <= trlStop
        strategy.close("Long", comment="TRL", immediately=false)

    // Trend reversal exit (fast crosses below slow)
    else if xDn and barstate.isconfirmed
        strategy.close("Long", comment="REV", immediately=false)

    // Max bars exit
    else if barsInTrd >= maxBars
        strategy.close("Long", comment="MAX", immediately=false)

// ── SHORT EXITS ─────────────────────────────────────────────────────────────
if inShort and strategy.opentrades > 0
    // Stop Loss
    if high >= entrySL
        strategy.close("Short", comment="SL", immediately=false)

    // TP1: partial (50%)
    else if not tp1Hit and low <= entryTP1
        strategy.close("Short", qty_percent=50.0, comment="TP1", immediately=false)
        tp1Hit  := true
        trlStop := entryPrice  // Move stop to breakeven after TP1

    // TP2: full
    else if tp1Hit and low <= entryTP2
        strategy.close("Short", comment="TP2", immediately=false)

    // Trailing Stop
    else if useTrl and tp1Hit and high >= trlStop
        strategy.close("Short", comment="TRL", immediately=false)

    // Trend reversal exit (fast crosses above slow)
    else if xUp and barstate.isconfirmed
        strategy.close("Short", comment="REV", immediately=false)

    // Max bars exit
    else if barsInTrd >= maxBars
        strategy.close("Short", comment="MAX", immediately=false)

// ── RESET tp1Hit ON NEW TRADE ─────────────────────────────────────────────
// tp1Hit is reset inside the entry blocks; ensure it clears when flat
if strategy.opentrades == 0
    tp1Hit := false

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 6 — SMEMA RIBBON PLOTS
// ═══════════════════════════════════════════════════════════════════════════════

color ribbonCol = fast > slow ? color.new(cUp, 70) : color.new(cDn, 70)

pFast    = plot(showBand ? fast     : na, "Fast SMEMA",     color=color.new(cUp, 30), linewidth=2)
pSlow    = plot(showBand ? slow     : na, "Slow SMEMA",     color=color.new(cDn, 30), linewidth=2)
pBase    = plot(showBand ? baseline : na, "Baseline SMEMA", color=color.new(cNeutral, 50), linewidth=1, style=plot.style_circles)

fill(pFast, pSlow, fast, slow,
     top_color    = color.new(cUp, 80),
     bottom_color = color.new(cDn, 80),
     title="SMEMA Ribbon")

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 7 — SIGNAL LABELS
// ═══════════════════════════════════════════════════════════════════════════════

if showSig and longOk
    label.new(bar_index, low - atrVal * 0.6,
         "▲ LONG", color=color.new(cUp, 5), textcolor=color.white,
         style=label.style_label_up, size=size.small, xloc=xloc.bar_index)

if showSig and shortOk
    label.new(bar_index, high + atrVal * 0.6,
         "▼ SHORT", color=color.new(cDn, 5), textcolor=color.white,
         style=label.style_label_down, size=size.small, xloc=xloc.bar_index)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 8 — SL/TP LINES
// ═══════════════════════════════════════════════════════════════════════════════

var line slLine  = na
var line tp1Line = na
var line tp2Line = na

if strategy.opentrades > 0 and (inLong or inShort)
    if na(slLine)
        slLine  := line.new(bar_index, entrySL,  bar_index + 1, entrySL,  color=color.new(cDn, 20),       width=1, style=line.style_dashed, extend=extend.right)
        tp1Line := line.new(bar_index, entryTP1, bar_index + 1, entryTP1, color=color.new(cUp, 40),       width=1, style=line.style_dashed, extend=extend.right)
        tp2Line := line.new(bar_index, entryTP2, bar_index + 1, entryTP2, color=color.new(cUp, 10),       width=1, style=line.style_dashed, extend=extend.right)
    else
        line.set_y1(slLine,  entrySL)
        line.set_y2(slLine,  entrySL)
        line.set_y1(tp1Line, entryTP1)
        line.set_y2(tp1Line, entryTP1)
        line.set_y1(tp2Line, entryTP2)
        line.set_y2(tp2Line, entryTP2)
else
    line.delete(slLine)
    slLine  := na
    line.delete(tp1Line)
    tp1Line := na
    line.delete(tp2Line)
    tp2Line := na

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 9 — DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════

var table dash = table.new(position.top_right, 2, 13,
     bgcolor=color.new(#0D1117, 10), border_color=color.new(#30363D, 80), border_width=1,
     frame_color=color.new(#58A6FF, 60), frame_width=1)

dashCell(int row, string lbl, string val, color vc) =>
    table.cell(dash, 0, row, lbl, text_color=color.new(#8B949E, 0), text_size=size.small, bgcolor=color.new(#0D1117, 10))
    table.cell(dash, 1, row, val, text_color=vc,                     text_size=size.small, bgcolor=color.new(#161B22, 10))

if showDash and barstate.islast
    table.cell(dash, 0, 0, "STS [JOAT]", text_color=color.new(#58A6FF, 0),
         text_size=size.normal, bgcolor=color.new(#0D1117, 5))
    table.cell(dash, 1, 0, ticker,        text_color=color.new(#E6EDF3, 0),
         text_size=size.normal, bgcolor=color.new(#0D1117, 5))

    string posStr  = strategy.opentrades > 0 ? (inLong ? "▲ LONG" : "▼ SHORT") : "— Flat"
    color  posCol  = inLong ? cUp : inShort ? cDn : cNeutral
    string fastDir = fast > slow ? "▲ Bull" : "▼ Bear"
    color  fdCol   = fast > slow ? cUp : cDn
    string adxStr  = str.tostring(math.round(adxVal * 10.0) / 10.0) + (adxOk ? " ✓" : " ✗")
    color  adxCol  = adxOk ? cUp : cNeutral
    string rsiStr  = str.tostring(math.round(rsiVal * 10.0) / 10.0) + (rsiVal > 50.0 ? " Bull" : " Bear")
    color  rsiCol  = rsiVal > rsiBull ? cUp : rsiVal < rsiBear ? cDn : cNeutral
    string volStr  = str.tostring(math.round(volRatio * 100.0) / 100.0) + (volOk ? " ✓" : " ✗")
    color  volCol  = volOk ? cUp : cNeutral
    int    trd     = strategy.closedtrades
    // FIX: strategy.wintrades and trd are both int — integer division gives wrong result.
    // Cast to float before dividing to get the correct win-rate percentage.
    float  winR    = trd > 0 ? float(strategy.wintrades) / float(trd) * 100.0 : 0.0
    string winStr  = str.tostring(math.round(winR * 10.0) / 10.0) + "%"
    color  winCol  = winR >= 50.0 ? cUp : cDn
    float  netPL   = strategy.netprofit
    color  plCol   = netPL >= 0.0 ? cUp : cDn
    string plStr   = (netPL >= 0.0 ? "+" : "") + str.tostring(math.round(netPL * 100.0) / 100.0)
    string barsStr = strategy.opentrades > 0 ? str.tostring(barsInTrd) + "/" + str.tostring(maxBars) : "—"

    dashCell(1,  "Position",    posStr,  posCol)
    dashCell(2,  "SMEMA Cross", fastDir, fdCol)
    dashCell(3,  "ADX",         adxStr,  adxCol)
    dashCell(4,  "RSI",         rsiStr,  rsiCol)
    dashCell(5,  "Vol Ratio",   volStr,  volCol)
    dashCell(6,  "Trades",      str.tostring(trd),  trd >= 100 ? cUp : cNeutral)
    dashCell(7,  "Win Rate",    winStr,  winCol)
    dashCell(8,  "Net P&L",     plStr,   plCol)
    dashCell(9,  "Bars in Trd", barsStr, cNeutral)
    dashCell(10, "Fast/Slow",   str.tostring(smFast) + "/" + str.tostring(smSlow), cNeutral)
    dashCell(11, "SL Mult",     str.tostring(slMult), cNeutral)
    dashCell(12, "ATR",         str.tostring(math.round(atrVal * 10000.0) / 10000.0), cNeutral)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 10 — WATERMARK
// ═══════════════════════════════════════════════════════════════════════════════

var label wmLbl = na
if showWm and barstate.islast
    label.delete(wmLbl)
    wmLbl := label.new(bar_index - 5, ta.highest(high, 50),
         "JackOfAllTrades", color=color.new(#FFFFFF, 100),
         textcolor=color.new(#FFFFFF, 82), style=label.style_none,
         size=size.large, xloc=xloc.bar_index)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 11 — ALERTS
// ═══════════════════════════════════════════════════════════════════════════════

alertMsg(string sig, string dir) =>
    useJson ?
     '{"source":"STS_JOAT","ticker":"' + ticker + '","signal":"' + sig + '","direction":"' + dir + '","price":"' + str.tostring(close) + '"}' :
     "STS [JOAT] — " + sig + " | " + dir + " | " + ticker + " @ " + str.tostring(close)

if longOk
    alert(alertMsg("ENTRY", "LONG"),  alert.freq_once_per_bar_close)
if shortOk
    alert(alertMsg("ENTRY", "SHORT"), alert.freq_once_per_bar_close)

alertcondition(longOk,  "Long Entry Signal",  "STS [JOAT] — Long Entry")
alertcondition(shortOk, "Short Entry Signal", "STS [JOAT] — Short Entry")
````
