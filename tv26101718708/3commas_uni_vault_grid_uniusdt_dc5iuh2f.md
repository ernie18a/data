# [3Commas] UNI Vault Grid - UNI/USDT

- url: https://www.tradingview.com/script/Dc5iUh2F-3Commas-UNI-Vault-Grid-UNI-USDT/
- type: strategy
- pine_id: PUB;333c3df4d9d84f8fb42d357672e8ee60
- version: 1.0

## Description

[3Commas] UNI Vault Grid — UNI/USDT

🔷 What it does:
This strategy implements a static geometric grid trading system for Uniswap (UNI), designed to capture range-bound oscillations between a configurable High and Low price boundary. It pre-computes 57 price levels using geometric spacing (≈ 0.61% step), buys at each level on close-cross-down, and sells at the next level up on close-cross-up. Unlike adaptive grid variants with trailing logic, this version stays locked to the original range — no auto-shift up. Profit comes from capturing the spread between adjacent grid lines on every oscillation; the structure is designed for periods where UNI consolidates within a defined band rather than trending strongly in one direction.
  - 57 geometrically-spaced levels between Low (2.979) and High (4.171)
  - Buy on close-cross-down through an unfilled level; sell on close-cross-up through the next level
  - Fixed notional per level (175.44 USDT default), all fills equally sized
  - No trailing up — grid stays locked to the configured range
  - No stop loss — positions held until matching sell level is hit

🔷 Who is it for:
  Swing traders who identify ranging conditions on UNI and want to monetize the oscillations.
  Bot operators who automate grid execution through webhook integration with a connected bot.
  Spot accumulators with a directional view that UNI will remain inside the configured boundaries during the deployment period.
  Risk-conscious participants who prefer predictable accumulation envelopes (capped at full-grid-filled at the Low boundary).

🔷 How does it work:
  Long Entry: When close crosses down through an unfilled grid level, the strategy opens a long position sized to the per-level notional amount (default 175.44 USDT). Each level operates independently — multiple buys can stack across the ladder simultaneously during a downward swing, creating a structured accumulation pattern.
  Short Entry: Not used — this is a long-only spot grid.
  Exit Management: For each filled level, the strategy places a limit exit at the next level up. When close crosses up through that target, the position closes and the level becomes available to buy again. No stop loss is used; the grid's Low boundary defines the structural worst-case accumulation point.
  Static range — the grid does NOT shift when price exits the boundary. If price breaks above High, the strategy stops opening new buys until price returns inside the band. If price breaks below Low, all 57 levels are filled and the position holds unrealized loss until either the average is recovered or the user manually closes.

🔷 Why it's unique:
  Pure static range design — most grid implementations include trailing-up logic that compromises the original risk envelope when price trends. This variant stays locked to the configured range, which gives a fully predictable worst-case scenario: maximum unrealized loss is bounded by (Current Price − Grid Low) × Total Position at Low. Traders know exactly what they are signing up for before deploying capital.
  Calibrated for UNI's DEX-token volatility — the 0.61% step and 57-level ladder are dense enough to capture UNI's higher-frequency intraday oscillations (typical of mid-cap altcoins with active DEX flow) while keeping the configured envelope tight. This contrasts with sparser grids used for majors like ETH/BTC where each step needs to be wider to match the larger absolute moves.
  Bot Integration — entry alerts ship with webhook-ready JSON payloads. The grid_start alert fires once on first activation. Bot ID, Email Token, and pair label are exposed as inputs.

🔷 Considerations Before Using the Indicator:

  Market & Timeframe: This strategy is calibrated for a 15-minute chart on UNI/USDT spot pairs with active intraday range. Fill density depends directly on how often close crosses grid levels. Higher timeframes (1h+) produce far fewer fills; lower timeframes (1m, 5m) generate more fills but slow backtests on TradingView's plan limits. The runtime warning label flags any TF other than 15m.

  Limitations: No stop loss and no trailing range adjustment. The strategy is structurally exposed to two failure modes:
  (1) Price breaks above High — strategy idles, no new fills until reversal back into range
  (2) Price breaks below Low — all 57 levels fill, unrealized loss accumulates until average is recovered or position is manually closed
  This is the trade-off of a pure static grid: predictable risk envelope, but no adaptive protection against trend breakouts. Pair this strategy with manual range validation and an exit plan before deploying capital.

  Backtesting & Demo Testing: Always validate the grid range and step size on historical data for the specific instrument. UNI's volatility profile shifts across DeFi cycles — what was a ranging instrument can become a strong-trend instrument and vice versa, especially around governance events, fee-switch proposals, or DEX-flow rotations. Re-test on your own venue using venue-specific commission and slippage. Demo-trade for at least one month before any live deployment. Past performance is not indicative of future results.

  Parameter Adjustments: Commission defaults to 0.10% (Bybit spot taker). Adjust for your venue — Binance Spot ~0.10%, Coinbase Advanced ~0.50%, OKX Spot ~0.08%. The grid range and level count should be re-evaluated for each new deployment period — UNI's "fair range" shifts over time, and a grid calibrated for one regime may not work for the next.

🔷 STRATEGY PROPERTIES
  Symbol: BYBIT:UNIUSDT (Uniswap / Tether Spot). Strategy is generic — works on any spot pair with sufficient depth and structural range.
  Timeframe: 15m chart (mandatory — strategy is calibrated for this TF).
  Test Period: Jan 19, 2026 — May 19, 2026 (≈ 4 months / last 120 days).
  Initial Capital: 11,000 USDT (10,000 investment + 1,000 buffer for commission and grid fluctuations).
  Order Size per Trade: 175.44 USDT per grid level. Total investment envelope = 10,000 USDT (57 levels × 175.44). Maximum simultaneous position count: 57 levels.
  Commission: 0.10% taker — Bybit spot reference; adjust for your venue.
  Slippage: 2 ticks — typical taker execution on liquid UNI/USDT pairs.
  Margin for Long and Short Positions: 100% (1× leverage assumed; no margin amplification).
  Indicator Settings: Default Configuration.
    Grid Mode: Geometric
    High Price: 4.171
    Low Price: 2.979
    Levels: 57
    Amount per Level: 175.44 USDT
    Trailing Up: disabled
    Step (computed): ≈ 0.61%
  Strategy: Long Only.

🔷 STRATEGY RESULTS
  ⚠️ Remember, past results do not guarantee future performance.
  Net Profit: [to fill from Strategy Tester report]
  Max Drawdown: [to fill from Strategy Tester report]
  Total Closed Trades: [to fill from Strategy Tester report]
  Percent Profitable: [to fill from Strategy Tester report]
  Profit Factor: [to fill from Strategy Tester report]
  Average Trade: [to fill from Strategy Tester report]
  Average # Bars in Trades: [to fill from Strategy Tester report]

  Reference TradingView Pine backtest on BYBIT:UNIUSDT (15m chart), Jan 19 2026 — May 19 2026 (≈4 months / last 120 days at time of publication). The reference period captures UNI's choppy post-recovery phase, which is structurally favorable for static range grids — the strategy fills repeatedly as price oscillates through the band. Built-in GRID Bot backtest reference (last 120 days): +23.15% net profit / 1,290 trades. The Pine simulation differs slightly from the bot backtester due to fee structure, slippage model, and close-based level-crossing detection vs. exchange-side limit orders. Re-test on your own venue with venue-specific commission before live deployment.

🔷 How to Use It:
  🔸 Adjust Settings: Set the grid High and Low boundaries based on UNI's observed range over the past 1–3 months. The default 2.979 — 4.171 envelope reflects UNI's recent volatility band. Amount per level should be sized so that filling the entire ladder (all 57 levels = 10,000 USDT exposure) does not exceed your risk budget. Scale linearly to your equity. Always confirm you are on a 15-minute chart — the runtime warning label flags mismatches.

  🔸 Results Review: Verify Maximum Drawdown stays within your personal risk budget. The strategy operates with no stop loss, so the worst-case is the full grid being filled at the Low boundary while price continues lower. Calculate this scenario before going live: if every level fills and price drops 10% below the grid Low, what is your unrealized loss? That is your hard floor. Re-test on your own venue with realistic commission and slippage.

  🔸 Create alerts to trigger the connected bot: The strategy exposes a "grid_start" alert that fires once when the first bar enters the configured backtest window. Configure the alert in TradingView with the webhook URL pointing to your bot's signal endpoint. The Bot ID, Email Token, and Pair label can be set in the script's inputs. Note that grid bots are typically configured directly within the bot interface, so this alert is primarily informational for monitoring purposes.

🔷 INDICATOR SETTINGS
  Grid High Price — Upper boundary of the grid range.
  Grid Low Price — Lower boundary of the grid range.
  Grid Levels — Total number of price levels between Low and High (default 57).
  Grid Mode — Distribution of levels: Geometric (constant % spacing) or Arithmetic (constant absolute spacing).
  Amount per Level (USDT) — Notional value of each buy fill.
  Total Investment (USDT, ref) — Reference total capital deployed across all levels (informational).
  Trailing Up — Disabled by default; enable to make grid shift up on breakout (turns this into adaptive grid behavior).
  Trail Up Threshold % — Percentage above High at which trailing-up triggers (only used if Trailing Up enabled).
  Shift Up Magnitude % — How much of the current range to shift when trailing-up fires (only used if Trailing Up enabled).
  Limit by Date Range — Constrain backtest to a specific date window.
  Show grid lines on chart — Toggle visual display of all level lines.
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
//  [3Commas] UNI Vault Grid — UNI/USDT Static Geometric Grid
// ---------------------------------------------------------------------
//  ⚠️ RECOMMENDED TIMEFRAME: 15 minutes
//
//  Source bot config (3Commas GRID Bot):
//    Pair         : UNI/USDT (Bybit Spot)
//    Mode         : Geometric
//    High price   : 4.171   (+19.34% above reference)
//    Low price    : 2.979   (−14.76% below reference)
//    Levels       : 57  (step ≈ 0.61%)
//    Amount/level : 175.44 USDT  (investment 10000 / 57 levels)
//    Investment   : 10000 USDT
//    Trailing up  : DISABLED — pure static range grid
//    Expansion dn : DISABLED
//    Profit ccy   : Quote (USDT)
//
//  3Commas built-in backtest (Last 120 days, UNI/USDT):
//    Profit: +23.15%   |   Trades: 1290
//
//  Static range grid for Uniswap — focuses on capturing the DEX-token
//  oscillations within a structurally defined band. No trailing follow,
//  no expansion down — the grid stays locked.
// =====================================================================

strategy(
     title                   = "[3Commas] UNI Vault Grid — UNI",
     shorttitle              = "UNI Vault Grid",
     overlay                 = true,
     pyramiding              = 100,
     initial_capital         = 11000,
     default_qty_type        = strategy.cash,
     default_qty_value       = 175.44,
     commission_type         = strategy.commission.percent,
     commission_value        = 0.1,        // Bybit spot taker
     slippage                = 2,
     calc_on_every_tick      = false)

// =====================================================================
//                              INPUTS
// =====================================================================
highPx     = input.float(4.171, "Grid High Price",                    step = 0.001, group = "Grid Range")
lowPx      = input.float(2.979, "Grid Low Price",                     step = 0.001, group = "Grid Range")
levels     = input.int  (57,    "Grid Levels",     minval = 2, maxval = 100,        group = "Grid Range")
gridMode   = input.string("Geometric", "Grid Mode", options = ["Geometric","Arithmetic"], group = "Grid Range")

amountPerLevel = input.float(175.44,   "Amount per Level (USDT)",      minval = 0.01, step = 0.01, group = "Sizing")
investment     = input.float(10000.0,  "Total Investment (USDT, ref)", minval = 0.01, step = 1,   group = "Sizing")

trailUp     = input.bool (false, "Trailing Up — shift grid when price exceeds High", group = "Behavior")
trailUpThr  = input.float(3.0,   "Trail Up Threshold % above High",  minval = 0.1, step = 0.1, group = "Behavior")
trailShiftPct = input.float(50,  "Shift Up Magnitude % of range",    minval = 1, maxval = 100, step = 1, group = "Behavior")

useDates = input.bool(true, "Limit by Date Range",                                                  group = "Backtest Period")
startTs  = input.time(timestamp("2026-01-19 00:00 +0000"), "Start", group = "Backtest Period")
endTs    = input.time(timestamp("2026-05-19 23:59 +0000"), "End",   group = "Backtest Period")
inWindow = (not useDates) or (time >= startTs and time <= endTs)

botId      = input.string("12345678",         "Bot ID",                                      group = "Webhook (GRID Bot)")
emailToken = input.string("YOUR_EMAIL_TOKEN", "Email Token",                                 group = "Webhook (GRID Bot)")
pairLabel  = input.string("USDT_UNI",         "Pair (Bot format: QUOTE_BASE)",               group = "Webhook (GRID Bot)")

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
//                       TRAILING UP — shift grid (off by default)
// =====================================================================
if trailUp and inWindow and close > curHigh * (1.0 + trailUpThr / 100.0)
    rng = curHigh - curLow
    shift = rng * trailShiftPct / 100.0
    curHigh := curHigh + shift
    curLow  := curLow  + shift
    f_computeLevels()

// =====================================================================
//                       GRID TRADING LOGIC
// =====================================================================
if inWindow and barstate.isconfirmed and bar_index > 0
    // SELL pass
    for i = 0 to levels - 2
        if array.get(filled, i)
            sellLvl = array.get(gridLevels, i + 1)
            if close >= sellLvl and close[1] < sellLvl
                strategy.close("B" + str.tostring(i), comment = "Grid Sell L" + str.tostring(i))
                array.set(filled, i, false)

    // BUY pass
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
    while array.size(gridLines) > 0
        line.delete(array.pop(gridLines))
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
gridStartMsg = '{"message_type":"bot","bot_id":' + botId + ',"email_token":"' + emailToken + '","action":"grid_start","pair":"' + pairLabel + '"}'

var bool startedNotified = false
if (not startedNotified) and inWindow and barstate.isconfirmed
    alert(gridStartMsg, alert.freq_once_per_bar_close)
    startedNotified := true
````
