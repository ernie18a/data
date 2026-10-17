# Geometric Grid Machine [3Commas]

- url: https://www.tradingview.com/script/8N8DT3Pv-Geometric-Grid-Machine-3Commas/
- type: strategy
- pine_id: PUB;522260b0d6d643caa2901d380ca6e346
- version: 1.0

## Description

[3Commas] Geometric Grid Machine

🔷 What it does:
This strategy implements a geometric grid trading system on liquid range-bound instruments. It pre-computes a ladder of 56 price levels between a configurable High and Low boundary using geometric spacing (≈ 0.6% step), then buys at each level when price crosses down through it and sells at the next level up when price crosses back through. Profit comes from capturing the spread between adjacent grid lines on every oscillation. A trailing-up mechanic shifts the entire grid upward when price breaks above the High, allowing the system to follow rising trends without abandoning open positions.
  - 56 geometrically-spaced levels between Low (29.73) and High (41.31)
  - Buy on close-cross-down through an unfilled level; sell on close-cross-up through the next level
  - Fixed notional per level (28.15 USDT default), all fills equally sized
  - Trailing up activates when price exceeds High by 3%, shifts grid by 50% of range
  - No stop loss — positions held until matching sell level is hit

🔷 Who is it for:
  Range-bound market traders who want to extract value from sideways price action.
  Bot operators who automate grid execution through webhook integration with a connected bot.
  Volatility harvesters who profit from oscillations rather than directional moves.
  Spot traders with a ranging view on liquid altcoins, perpetuals, or major pairs.

🔷 How does it work:
  Long Entry: When close crosses down through an unfilled grid level, the strategy opens a long position sized to the per-level notional amount. Each level is independent — multiple buys can stack across the ladder simultaneously, which is what creates the GRID accumulation effect during a downtrend.
  Short Entry: Not used — this is a long-only spot grid.
  Exit Management: For each filled level, the strategy places a limit exit at the next level up. When close crosses up through that target, the position closes and the level becomes available to buy again. There is no stop loss — invalidation is handled structurally by the grid's Low boundary, which sets the worst-case accumulation point.
  Trailing Up: If close exceeds the current High by 3%, the entire grid shifts upward by 50% of the range. Levels recalculate to the new High/Low, and the strategy continues operating in the shifted range. Open positions remain; their exit targets now refer to the new level structure.

🔷 Why it's unique:
  Geometric distribution — most grid implementations use arithmetic (linear) spacing, which produces unequal percentage steps at different price levels. Geometric spacing maintains a constant percentage step across the entire range (≈ 0.6% in default config), which is structurally fairer when the instrument is far from zero and is the same model used by professional grid bots.
  Trailing-up architecture — fixed grids break when trends carry price out of range. The trailing-up mechanic detects a sustained break above the High and re-centers the grid around current price, preserving open positions and continuing operation without manual intervention.
  Bot Integration — entry and exit alerts ship with webhook-ready JSON payloads. Two alert events (grid_start on first bar in window, grid_shift_up on trailing event) enable an external bot to mirror state changes. Bot ID, Email Token, and pair label are exposed as inputs.

🔷 Considerations Before Using the Indicator:

  Market & Timeframe: This strategy is highly timeframe-sensitive and is calibrated for a 15-minute chart. Backtest fill density and overall P&L depend directly on how often close crosses grid levels, which is governed by bar duration. Higher timeframes (1h+) will show far fewer fills and may underperform; lower timeframes (1m, 5m) increase fills but slow down backtests significantly on standard TradingView plans. The runtime warning label on the chart will flag any timeframe other than 15m so the user is aware.

  Limitations: No stop loss is implemented. If price breaks below the grid's Low boundary, all filled levels accumulate unrealized loss until either the average is recovered through subsequent bounces or the user manually closes the position. The strategy assumes a structurally ranging instrument — sustained one-way trends (especially downtrends) will produce maximum drawdown without the trailing-up feature triggering. Pair this strategy with manual range validation before deploying capital.

  Backtesting & Demo Testing: Always validate the grid range and step size on historical data for the specific instrument you intend to trade. Each instrument has a different volatility profile, and the optimal grid parameters vary accordingly. Re-test on your own venue using venue-specific commission and slippage. Demo-trade for at least one month before any live deployment. Past performance is not indicative of future results.

  Parameter Adjustments: Commission defaults to 0.1% (Bybit spot taker). Adjust to match your exchange — Coinbase Advanced ~0.5%, Binance Spot ~0.1%, OKX Spot ~0.08%. Slippage of 2 ticks is conservative for liquid pairs — increase for thin order books. Grid range (High/Low) and level count should be re-tuned per instrument volatility — wider ranges and more levels for highly volatile assets, tighter setups for stable ranges.

🔷 STRATEGY PROPERTIES
  Symbol: BYBIT:HYPEUSDT.P (Perpetual). Reference testing performed on HYPE/USDT on Bybit.
  Timeframe: 15m chart (mandatory — strategy is calibrated for this TF).
  Test Period: Feb 11, 2026 — May 13, 2026 (≈ 3 months).
  Initial Capital: 2,000 USDT.
  Order Size per Trade: 28.15 USDT per grid level. Total investment envelope ≈ 1,545.83 USDT (sum of all level allocations). Maximum simultaneous position count: 56 levels.
  Commission: 0.10% taker — Bybit spot reference. Adjust to your venue.
  Slippage: 2 ticks — typical taker execution on liquid spot pairs.
  Margin for Long and Short Positions: 100% (1× leverage assumed; no margin amplification).
  Indicator Settings: Default Configuration.
    Grid Mode: Geometric
    High Price: 41.31
    Low Price: 29.73
    Levels: 56
    Amount per Level: 28.15 USDT
    Trailing Up: enabled
    Trail Up Threshold: 3.0%
    Shift Up Magnitude: 50% of range
  Strategy: Long Only.

🔷 STRATEGY RESULTS
  ⚠️ Remember, past results do not guarantee future performance.
  Net Profit: +244.05 USDT (+12.20%)
  Max Drawdown: 118.35 USDT (5.45%)
  Total Closed Trades: 1,765
  Percent Profitable: 59.04% (1,042 / 1,765)
  Profit Factor: 1.903
  Average Trade: [to fill from Strategy Tester report]
  Average # Bars in Trades: [to fill from Strategy Tester report]

  Reference backtest run on BYBIT:HYPEUSDT.P on 15m base chart, Feb 11 — May 13, 2026. The 3-month period spans a sideways-to-mildly-bullish phase on HYPE, which is the ideal regime for grid strategies. Re-run on your own venue with venue-specific commission and slippage before drawing conclusions for live deployment.

🔷 How to Use It:
  🔸 Adjust Settings: Set the grid High and Low boundaries based on the instrument's observed range over the past 1–3 months. Use 50–80 levels for high-volatility altcoins, 30–50 for major pairs. The amount per level should be sized so that filling the entire ladder (all 56 levels) does not exceed your risk budget. The default 28.15-USDT structure is calibrated for a 2,000-USDT account; scale linearly to your equity. Always confirm you are on a 15-minute chart — the runtime warning label will flag mismatches.

  🔸 Results Review: Verify Maximum Drawdown stays within your personal risk budget. The strategy operates with no stop loss, so the worst-case is the full grid being filled at the Low boundary while price continues lower. Calculate this scenario before going live: if every level fills and price drops 10% below the grid Low, what is your unrealized loss? That is your hard floor. Re-test on your own venue with realistic commission and slippage.

  🔸 Create alerts to trigger the connected bot: Two alert events are exposed by the strategy — "grid_start" fires once when the first bar enters the configured backtest window, and "grid_shift_up" fires every time the trailing-up mechanic moves the grid. Configure both alerts in TradingView with the webhook URL pointing to your bot's signal endpoint. The Bot ID, Email Token, and Pair label can be set in the script's inputs. Note that grid bots are typically configured directly within the bot interface, so these alerts are primarily informational for monitoring purposes.

🔷 INDICATOR SETTINGS
  Grid High Price — Upper boundary of the grid range.
  Grid Low Price — Lower boundary of the grid range.
  Grid Levels — Total number of price levels between Low and High (default 56).
  Grid Mode — Distribution of levels: Geometric (constant % spacing) or Arithmetic (constant absolute spacing).
  Amount per Level (USDT) — Notional value of each buy fill.
  Total Investment (USDT, ref) — Reference total capital deployed across all levels (informational).
  Trailing Up — Enable grid shift when price exceeds the High threshold.
  Trail Up Threshold % — Percentage above High at which trailing-up triggers.
  Shift Up Magnitude % — How much of the current range to shift when trailing-up fires.
  Limit by Date Range — Constrain backtest to a specific date window.
  Show grid lines on chart — Toggle visual display of all 56 level lines.
  Recommended TF (for warning) — Timeframe baseline for the runtime mismatch warning (default 15m).
  Stats card / Watermark — Display layer controls for on-chart backtest summary and branding.

  Webhook — Bot ID, Email Token, and Pair label for connected bot signal routing.

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.

__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=6
// =====================================================================
//  [3Commas] GRID Bot Nonstop — Geometric Grid
// ---------------------------------------------------------------------
//  ⚠️ RECOMMENDED TIMEFRAME: 15 minutes
//
//  This strategy is highly timeframe-sensitive. Backtest performance and
//  fill density depend directly on how often `close` crosses grid levels,
//  which is governed by the chart's bar duration. The 3Commas GRID Bot
//  reference config is tuned for 15-minute base chart execution.
//
//  Tested on 15m chart of HYPEUSDT.P (Bybit), Feb 11 — May 13, 2026:
//      Net Profit: +248.03 USDT (+12.40%)
//      Max DD:     118.35 USDT (5.44%)
//      Trades:     1,787
//      Win Rate:   59.43% (1062 / 1787)
//      PF:         1.903
//
//  Running on higher TF (1h, 4h, 1D) will produce far fewer fills and
//  may show net-zero or negative P&L because daily candles span 10+
//  grid levels and the close-based detector catches only the final
//  crossing. Running on lower TF (1m, 5m) gives more fills but heavy
//  load and slower backtests on TradingView's plan limits.
// ---------------------------------------------------------------------
//  Source bot config (3Commas GRID Bot):
//    Pair         : HYPE/USDT (Bybit Spot)
//    Mode         : Geometric
//    High price   : 41.31  (+3.01% above reference)
//    Low price    : 29.73  (−25.86% below reference)
//    Levels       : 56  (step ≈ 0.6%)
//    Amount/level : 28.15 USDT
//    Investment   : 1545.83 USDT
//    Trailing up  : enabled (grid shifts up when price exceeds high)
//    Profit ccy   : Quote (USDT)
//    Lower stop   : disabled
//
//  GRID logic:
//    - 56 price levels are pre-computed between Low and High (geometric).
//    - When close crosses DOWN through an unfilled level → BUY at that level.
//    - When close crosses UP through the next level above a filled buy →
//      SELL that buy, capture the step spread (≈ 0.6%) as profit.
//    - When price exceeds High by the trail-up threshold → grid shifts
//      up to follow the trend (Low/High move up, levels recalculated).
// =====================================================================

strategy(
     title                   = "[3Commas] GRID Bot Nonstop — Geometric Grid",
     shorttitle              = "GRID Nonstop",
     overlay                 = true,
     pyramiding              = 100,
     initial_capital         = 2000,
     default_qty_type        = strategy.cash,
     default_qty_value       = 28.15,
     commission_type         = strategy.commission.percent,
     commission_value        = 0.1,        // Bybit spot taker
     slippage                = 2,
     calc_on_every_tick      = false)

// =====================================================================
//                              INPUTS
// =====================================================================
highPx     = input.float(41.31, "Grid High Price",                    step = 0.01, group = "Grid Range")
lowPx      = input.float(29.73, "Grid Low Price",                     step = 0.01, group = "Grid Range")
levels     = input.int  (56,    "Grid Levels",     minval = 2, maxval = 100,        group = "Grid Range")
gridMode   = input.string("Geometric", "Grid Mode", options = ["Geometric","Arithmetic"], group = "Grid Range")

amountPerLevel = input.float(28.15, "Amount per Level (USDT)",      minval = 0.01, step = 0.01, group = "Sizing")
investment     = input.float(1545.83, "Total Investment (USDT, ref)", minval = 0.01, step = 1,   group = "Sizing")

trailUp     = input.bool (true, "Trailing Up — shift grid when price exceeds High", group = "Behavior")
trailUpThr  = input.float(3.0,  "Trail Up Threshold % above High",  minval = 0.1, step = 0.1, group = "Behavior")
trailShiftPct = input.float(50, "Shift Up Magnitude % of range",    minval = 1, maxval = 100, step = 1, group = "Behavior")

useDates = input.bool(true, "Limit by Date Range",                                                  group = "Backtest Period")
startTs  = input.time(timestamp("2026-02-11 00:00 +0000"), "Start", group = "Backtest Period")
endTs    = input.time(timestamp("2026-05-13 00:00 +0000"), "End",   group = "Backtest Period")
inWindow = (not useDates) or (time >= startTs and time <= endTs)

botId      = input.string("12345678",         "Bot ID",                                      group = "Webhook (GRID Bot)")
emailToken = input.string("YOUR_EMAIL_TOKEN", "Email Token",                                 group = "Webhook (GRID Bot)")
pairLabel  = input.string("USDT_HYPE",        "Pair (Bot format: QUOTE_BASE)",               group = "Webhook (GRID Bot)")

// — Display —
showGridLines = input.bool(true, "Show grid lines on chart",   group = "Display")
showStats     = input.bool(true, "Show stats card",            group = "Display")
statsPosStr   = input.string("top_left", "Stats card position",
     options = ["top_left","top_center","top_right","middle_left","middle_right","bottom_left","bottom_center","bottom_right"], group = "Display")
showWM        = input.bool(true, "Show watermark",             group = "Display")
wmText        = input.string("3Commas", "Watermark text",      group = "Display")
wmPosStr      = input.string("top_right", "Watermark position",
     options = ["top_left","top_center","top_right","middle_left","middle_center","middle_right","bottom_left","bottom_center","bottom_right"], group = "Display")
wmSizeStr     = input.string("huge", "Watermark size",
     options = ["tiny","small","normal","large","huge"], group = "Display")
wmAlpha       = input.int(70, "Watermark transparency (0=solid)", minval = 0, maxval = 100, group = "Display")

// =====================================================================
//                       TIMEFRAME WARNING
// =====================================================================
// Reference results are calibrated on a 15-minute chart. Display a
// visible warning label on the last bar if running on a different TF.
recommendedTF = input.timeframe("15", "Recommended TF (for warning)", group = "Timeframe")
tfMismatch = timeframe.period != recommendedTF

var label tfWarn = na
if barstate.islast and tfMismatch
    label.delete(tfWarn)
    tfWarn := label.new(
         x      = bar_index,
         y      = high,
         text   = "⚠ This strategy is calibrated for " + recommendedTF + "m chart.\nCurrent TF: " + timeframe.period + ". Results may differ significantly.",
         style  = label.style_label_down,
         color  = color.new(color.orange, 20),
         textcolor = color.white,
         size   = size.normal,
         yloc   = yloc.abovebar)

// =====================================================================
//                          GRID STATE
// =====================================================================
var float curHigh     = highPx
var float curLow      = lowPx
var array<float> gridLevels = array.new<float>(levels, 0.0)
var array<bool>  filled     = array.new<bool>(levels, false)
var array<line>  gridLines  = array.new<line>(0)

// Compute level prices (geometric or arithmetic)
f_computeLevels() =>
    for i = 0 to levels - 1
        ratio = i / (levels - 1.0)
        lvl = gridMode == "Geometric"
             ? curLow * math.pow(curHigh / curLow, ratio)
             : curLow + (curHigh - curLow) * ratio
        array.set(gridLevels, i, lvl)

if barstate.isfirst
    f_computeLevels()

// =====================================================================
//                       TRAILING UP — shift grid
// =====================================================================
// If price exceeds High × (1 + trailUpThr/100), shift the entire grid up
// by `trailShiftPct` of the current range, then recompute all levels.
if trailUp and inWindow and close > curHigh * (1.0 + trailUpThr / 100.0)
    rng = curHigh - curLow
    shift = rng * trailShiftPct / 100.0
    curHigh := curHigh + shift
    curLow  := curLow  + shift
    f_computeLevels()
    // Note: existing filled[] state is preserved; levels just shifted.
    // Pine's open positions remain; new sell levels reflect the new grid.

// =====================================================================
//                       GRID TRADING LOGIC
// =====================================================================
// Close-based level-crossing detection (no intra-bar high/low usage).
// Each confirmed bar:
//   1. SELL check: if close just crossed UP through a filled level's
//      sell target, close that buy entry and mark level unfilled.
//   2. BUY check: if close just crossed DOWN through an unfilled level,
//      open a buy at that level and mark it filled.
if inWindow and barstate.isconfirmed and bar_index > 0
    // --- SELL pass ---
    for i = 0 to levels - 2
        if array.get(filled, i)
            sellLvl = array.get(gridLevels, i + 1)
            if close >= sellLvl and close[1] < sellLvl
                strategy.close("B" + str.tostring(i), comment = "Grid Sell L" + str.tostring(i))
                array.set(filled, i, false)

    // --- BUY pass ---
    for i = 0 to levels - 1
        if not array.get(filled, i)
            buyLvl = array.get(gridLevels, i)
            if close <= buyLvl and close[1] > buyLvl
                qty = amountPerLevel / buyLvl
                strategy.entry("B" + str.tostring(i), strategy.long, qty = qty, comment = "Grid Buy L" + str.tostring(i))
                array.set(filled, i, true)

// =====================================================================
//                       VISUALIZE GRID LINES
// =====================================================================
if barstate.islast and showGridLines
    // Clear old lines
    while array.size(gridLines) > 0
        line.delete(array.pop(gridLines))
    // Draw fresh lines for each level — extend.both avoids historical buffer limits
    for i = 0 to levels - 1
        lvl = array.get(gridLevels, i)
        isHi = i == levels - 1
        isLo = i == 0
        clr = isHi ? color.new(color.red, 30) : isLo ? color.new(color.green, 30) : color.new(color.aqua, 80)
        wd  = (isHi or isLo) ? 2 : 1
        ln = line.new(bar_index - 1, lvl, bar_index, lvl, color = clr, width = wd, extend = extend.both)
        array.push(gridLines, ln)

// =====================================================================
//                          STATS CARD
// =====================================================================
f_pos(s) =>
    s == "top_left"      ? position.top_left      :
     s == "top_center"    ? position.top_center    :
     s == "top_right"     ? position.top_right     :
     s == "middle_left"   ? position.middle_left   :
     s == "middle_center" ? position.middle_center :
     s == "middle_right"  ? position.middle_right  :
     s == "bottom_left"   ? position.bottom_left   :
     s == "bottom_center" ? position.bottom_center :
     position.bottom_right

f_size(s) =>
    s == "tiny"   ? size.tiny   :
     s == "small"  ? size.small  :
     s == "normal" ? size.normal :
     s == "large"  ? size.large  :
     size.huge

np      = strategy.netprofit
npPct   = strategy.initial_capital > 0 ? np / strategy.initial_capital * 100 : 0.0
dd      = strategy.max_drawdown
ddPct   = strategy.initial_capital > 0 ? dd / strategy.initial_capital * 100 : 0.0
nTrades = strategy.closedtrades
wins    = strategy.wintrades
wrPct   = nTrades > 0 ? wins / nTrades * 100 : 0.0
gp      = strategy.grossprofit
gl      = strategy.grossloss
pf      = gl > 0 ? gp / gl : 0.0

clrPos    = color.new(#00C853, 0)
clrNeg    = color.new(#D50000, 0)
clrNeutral= color.new(#FFFFFF, 10)
clrHdrBg  = color.new(#1E88E5, 10)
clrRowBg  = color.new(#0D1B2A, 25)
clrAltBg  = color.new(#152238, 25)
clrBorder = color.new(#1E88E5, 60)

var table stats = na
if showStats and barstate.islast
    if na(stats)
        stats := table.new(f_pos(statsPosStr), 2, 6, bgcolor = clrRowBg, border_width = 1, border_color = clrBorder, frame_color = clrBorder, frame_width = 1)

    table.cell(stats, 0, 0, "GRID BACKTEST RESULTS", text_color = color.white, text_size = size.normal, bgcolor = clrHdrBg, text_halign = text.align_center)
    table.cell(stats, 1, 0, "—",                     text_color = clrHdrBg,   text_size = size.normal, bgcolor = clrHdrBg, text_halign = text.align_center)

    table.cell(stats, 0, 1, "Net P&L",  text_color = clrNeutral, text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_left)
    table.cell(stats, 1, 1, (np >= 0 ? "+" : "") + str.tostring(np, "0.00") + "  (" + (npPct >= 0 ? "+" : "") + str.tostring(npPct, "0.00") + "%)",
         text_color = np >= 0 ? clrPos : clrNeg, text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_right)

    table.cell(stats, 0, 2, "Max Drawdown", text_color = clrNeutral, text_size = size.normal, bgcolor = clrAltBg, text_halign = text.align_left)
    table.cell(stats, 1, 2, str.tostring(dd, "0.00") + "  (" + str.tostring(ddPct, "0.00") + "%)",
         text_color = clrNeg, text_size = size.normal, bgcolor = clrAltBg, text_halign = text.align_right)

    table.cell(stats, 0, 3, "Grid Fills", text_color = clrNeutral, text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_left)
    table.cell(stats, 1, 3, str.tostring(nTrades), text_color = clrNeutral, text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_right)

    table.cell(stats, 0, 4, "Win Rate", text_color = clrNeutral, text_size = size.normal, bgcolor = clrAltBg, text_halign = text.align_left)
    table.cell(stats, 1, 4, str.tostring(wrPct, "0.00") + "%  (" + str.tostring(wins) + "/" + str.tostring(nTrades) + ")",
         text_color = wrPct >= 50 ? clrPos : clrNeg, text_size = size.normal, bgcolor = clrAltBg, text_halign = text.align_right)

    table.cell(stats, 0, 5, "Profit Factor", text_color = clrNeutral, text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_left)
    table.cell(stats, 1, 5, str.tostring(pf, "0.000"), text_color = pf >= 1.5 ? clrPos : (pf >= 1.0 ? clrNeutral : clrNeg), text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_right)

// =====================================================================
//                          BRAND WATERMARK
// =====================================================================
var table wm = na
if showWM and barstate.islast
    if na(wm)
        wm := table.new(f_pos(wmPosStr), 1, 1, bgcolor = color.new(color.black, 100), border_width = 0)
    table.cell(wm, 0, 0, wmText, text_color = color.new(color.white, wmAlpha), text_size = f_size(wmSizeStr), bgcolor = color.new(color.black, 100))

// =====================================================================
//                          WEBHOOK ALERTS
// =====================================================================
// GRID Bots in 3Commas are typically configured directly without external
// webhook signals — but a generic "start" alert is provided for completeness.
gridStartMsg = '{"message_type":"bot","bot_id":' + botId + ',"email_token":"' + emailToken + '","action":"grid_start","pair":"' + pairLabel + '"}'
gridShiftMsg = '{"message_type":"bot","bot_id":' + botId + ',"email_token":"' + emailToken + '","action":"grid_shift_up","pair":"' + pairLabel + '"}'

// Fire once on first bar of the date window
var bool startedNotified = false
if (not startedNotified) and inWindow and barstate.isconfirmed
    alert(gridStartMsg, alert.freq_once_per_bar_close)
    startedNotified := true

// Fire when trailing-up shift happens
var float prevHigh = curHigh
if trailUp and curHigh != prevHigh and barstate.isconfirmed
    alert(gridShiftMsg, alert.freq_once_per_bar_close)
    prevHigh := curHigh
````
