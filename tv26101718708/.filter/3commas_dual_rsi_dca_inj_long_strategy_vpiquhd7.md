# [3Commas] Dual RSI DCA INJ - Long Strategy

- url: https://www.tradingview.com/script/VPIQUHD7-3Commas-Dual-RSI-DCA-INJ-Long-Strategy/
- type: strategy
- pine_id: PUB;a75e6578690046bcb1c3a0f6fd8e55cf
- version: 1.0

## Description

Dual RSI DCA — Long Strategy

🔷 What it does:
This is a long-only DCA strategy that captures oversold-to-overbought rotations confirmed by two independent RSI conditions on a lower timeframe. A long entry opens only when the lower-timeframe RSI crosses up out of an oversold zone; the take profit fires only when the lower-timeframe RSI crosses down out of an overbought zone AND a minimum profit threshold from average entry has been reached. Five safety orders form a deviation ladder for adverse downward price action. No trailing, no Stop Loss.
  - Single base order with up to five safety orders, sized at a 1.25× progression for soft compounding.
  - Dual-RSI architecture: RSI(14) cross up 31 on 3m for entry, RSI(14) cross down 69 on 3m for exit.
  - Deviation ladder: 1.3% to first safety order, 1.3× step multiplier — five rungs from 1.30% to 11.75% below base entry.
  - Profit-armed exit: take profit fires only when minimum profit (default 2.4%) above average entry has been reached.
  - Every entry, safety order, and exit emits a webhook-ready JSON alert payload for direct DCA Bot consumption.

🔷 Who is it for:
  - Swing traders looking for systematic long exposure on crypto perpetuals that frequently sweep liquidity into local lows.
  - DCA-style traders who want both entry and exit signals gated by momentum confirmation, not just price levels.
  - Bot operators who want to drive a DCA Bot via webhook with per-event JSON payloads tagged for each base / safety order / exit action.
  - Risk-conscious operators — at default settings the maximum deployed capital is ~9.93% of equity per trade, comfortably inside the conventional 5–10% per-trade risk band.

🔷 How does it work:
  Entry RSI Filter: A 3-minute RSI(14) is sampled via request.security with lookahead disabled. The entry gate fires when RSI crosses up the oversold threshold (default 31). The cross is detected at host-bar close, comparing the current LTF RSI value to the previous host bar's reading.
  Entry: When the entry gate fires and no position is open, a long position opens at the base order size (default 90 USDT ≈ 0.9% of equity). The base order is configurable as Market (default) or Limit at the bar's close.
  Safety Order Ladder: After the base fill, the strategy monitors price deviation downward against the position. The k-th safety order fires when close ≤ base entry × (1 − cumulative deviation), where cumulative deviation grows by the step multiplier (default 1.3). At default settings the deviations are: 1.30%, 2.99%, 5.18%, 8.04%, 11.75%. Each safety order's size grows by the size multiplier (default 1.25) — soft compounding without aggressive martingale.
  Exit RSI Filter: A 3-minute RSI(14) is sampled in parallel. The exit gate is checked only when price has reached the minimum profit target (default 2.4% above average entry). When the exit gate fires (RSI crosses down 69), the position closes at market.
  Profit-Armed Exit: This is the key mechanic. The take profit does not fire on a static target — it waits for momentum confirmation. The strategy lets winners run when RSI keeps climbing, and only exits when RSI rolls over from overbought, locking in profit at a momentum peak rather than a fixed distance.

🔷 Why it's unique:
  - Dual-RSI Architecture: Two independent RSI cross conditions on the same lower timeframe — one for entry, one for exit. Most DCA tools gate only one end of the deal; this one filters both.
  - Profit-Armed Exit: The take profit waits for the lower-timeframe RSI to roll over from overbought. Winners run while momentum holds, then exit on the first sign of rotation — better expectancy than a fixed-target exit on trending moves.
  - Soft Compounding Ladder: The 1.25× size multiplier scales position size with adverse drift but doesn't blow up capital deployment. Five safety orders cap maximum exposure at ~9.93% of equity.
  - DCA Bot Integration: Every event (base, AO 1–5, exit) emits a fully-formed JSON alert payload. Connect one alert to a DCA Bot's webhook URL and the strategy drives the bot end-to-end without any glue layer.

🔷 Considerations Before Using the Strategy:
  Market & Timeframe: Defaults are calibrated for INJUSDT perpetual on 3m. The dual-RSI mechanic is portable to other liquid crypto perpetuals that mean-revert from oversold conditions, but RSI thresholds and the deviation ladder should be reviewed before redeployment.
  Sample Size: The backtest produced 102 closed trades — just above the ~100-trade floor for statistical relevance, not far above it. The high win rate and profit factor reflect favorable conditions over the test window and the profit-armed exit mechanic; treat them as indicative rather than a forward-performance guarantee. Extend the window or test across multiple assets to build a larger sample.
  Strong Downtrends: Like any oversold-reversal setup, the strategy is positioned for ranges and rotations, not waterfall declines. In sustained downtrends the strategy may fill the entire 5-AO ladder and hold the position while price grinds lower. The dual RSI filter limits exposure to confirmed oversold conditions, but a regime shift to a strong downtrend requires manual oversight.
  Cross Detection Granularity: LTF RSI cross detection happens at host-bar close. A cross that completes and reverses inside a single host bar may be missed by design — this prevents over-signaling on intra-bar noise.
  Funding Rates (Perpetuals): Backtests do not account for perpetual funding rates. Sustained negative funding (shorts pay longs) improves live performance for this long strategy; sustained positive funding degrades it. Review the historical funding pattern before live deployment.
  No Stop Loss Justification: There is no exit on adverse moves beyond the 5-AO ladder. Per-trade risk is structurally capped by the bounded position-size ladder — at defaults that is base 90 + AO sum ~903 = 993 USDT max deployed ≈ 9.93% of equity, inside the conventional 5–10% per-trade band. If a hard stop is required at the exchange level, layer it on the bot side.

🔷 STRATEGY PROPERTIES
  Symbol: BYBIT:INJUSDT.P (Perpetual) — portable to any INJ / USDT pair.
  Timeframe: 3M
  Test Period: March 16, 2026 — June 11, 2026 (~2.9 months).
  Initial Capital: 10,000 USDT.
  Order Size per Trade: 0.9% of Capital base + 5 safety orders at 1.25× progression.
  Max Capital Deployed: ~993 USDT per trade (~9.93% of equity).
  Commission: 0.08% per trade.
  Slippage: 3 ticks.
  Margin for Long Positions: 100%.
  Indicator Settings: Default Configuration.
  Base Order: 90 USDT, Market by default (Limit toggle available).
  Take Profit: 2.4% minimum profit, armed by 3m RSI crossing down 69.
  Stop Loss: None — bounded position size is the structural risk cap.
  Entry Filter: 3m RSI(14) Crossing Up 31.
  Exit Filter: 3m RSI(14) Crossing Down 69 + minimum profit 2.4%.
  Averaging Orders: 5, Deviation 1.3%, Deviation Step 1.3×, Size Multiplier 1.25×.
  Strategy: Long Only.

🔷 STRATEGY RESULTS
  ⚠️ Remember, past results do not guarantee future performance.
  Net Profit: +223.16 USDT (+2.23%)
  Max Equity Drawdown: 204.77 USDT (1.98%)
  Total Closed Trades: 102
  Percent Profitable: 84.31% (86 / 102)
  Profit Factor: 15.628

🔷 How to Use It:
  🔸 Adjust Settings: Open the strategy inputs and review the Base Order Size, the entry RSI filter (timeframe / length / level), the exit RSI filter, the 5-AO ladder, and the Minimum Profit threshold. Defaults are calibrated for INJUSDT.P 3m — recalibrate per asset before deploying.
  🔸 Results Review: Run a full-period backtest and confirm Max Drawdown stays inside your personal risk band. This configuration produced 102 closed trades — just above the ~100-trade floor for statistical relevance; a larger sample increases confidence. Update commission and slippage to match your exchange's actual conditions.
  🔸 Create alerts to trigger the DCA Bot: Add one alert on the strategy using "Any alert() function call". Paste the DCA Bot's webhook URL into the alert's Webhook field, and fill the Bot ID, Email Token, and Pair inputs on the script. The strategy will emit JSON payloads for entry, each safety order, and exit — formatted for direct DCA Bot consumption.

🔷 INDICATOR SETTINGS
  Base Order Size (USDT): USDT amount opened on the long entry.
  Use LIMIT for Base: Toggle between Market (default) and Limit at bar close.
  Averaging Orders per Trade: Maximum number of safety orders per deal (default 5).
  First AO Size (USDT): USDT size of the first safety order; subsequent AOs scale by the Size Multiplier.
  Deviation to First AO (%): Distance from base entry at which AO1 becomes eligible.
  Deviation Step Multiplier: Ladder factor that widens each subsequent deviation step.
  Order Size Multiplier: Factor that grows each subsequent safety order's USDT size.
  Entry RSI Timeframe / Length / Level: Lower-timeframe RSI filter that gates the base entry.
  Exit RSI Timeframe / Length / Level: Lower-timeframe RSI filter that arms the take profit.
  Minimum Profit (%): Threshold above the running average entry that must be reached before the exit signal can fire.
  DCA Bot Webhook: Bot ID, Email Token, and Pair fields injected into every alert payload.
  Visualization: Toggle DCA Ladder, fill labels, status table.
  Brand Watermark: Configurable text, position, size, and transparency.

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.

__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=6
// =============================================================================
//  Dual RSI DCA — Long Strategy
//  Long-only DCA framework with TWO independent RSI conditions on a lower
//  timeframe: one gates the base entry (oversold reversal), one arms the
//  take-profit (overbought rotation). Five safety orders form a deviation
//  ladder for adverse price action.
//  Calibrated defaults for BYBIT:INJUSDT.P on 3m timeframe.
// =============================================================================
//  NO STOP LOSS — risk is structurally capped by the bounded position-size
//  ladder. Max deployed capital across base + 5 safety orders ≈ 9.93% of
//  equity at default settings (within TradingView's 5–10% per-trade band).
// =============================================================================
strategy("Dual RSI DCA — Long Strategy", shorttitle = "DualRSI-L", overlay = true, initial_capital = 10000, default_qty_type = strategy.cash, default_qty_value = 90, pyramiding = 6, commission_type = strategy.commission.percent, commission_value = 0.08, slippage = 3, process_orders_on_close = true, calc_on_every_tick = false)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grpBase = "Base Order"
baseOrderSize = input.float(90.0, "Base Order Size (USDT)", minval = 1, group = grpBase, tooltip = "0.9% of default 10k capital. Sized so that base + all 5 AOs ≤ 9.93% of equity.")
useLimitBase  = input.bool(false, "Use LIMIT for Base (else Market)", group = grpBase)

grpAO = "Averaging Orders"
aoCount    = input.int(5, "Averaging Orders per Trade", minval = 0, maxval = 10, group = grpAO)
aoSize     = input.float(110.0, "First AO Size (USDT)", minval = 1, group = grpAO)
aoStep     = input.float(1.3, "Deviation to First AO (%)", minval = 0.1, step = 0.1, group = grpAO)
aoStepMult = input.float(1.3, "Deviation Step Multiplier", minval = 1.0, step = 0.1, group = grpAO)
aoSizeMult = input.float(1.25, "Order Size Multiplier", minval = 1.0, step = 0.05, group = grpAO)

grpEntry = "Entry RSI Filter"
entryTF       = input.timeframe("3", "RSI Timeframe", group = grpEntry)
entryRsiLen   = input.int(14, "RSI Length", minval = 2, group = grpEntry)
entryRsiLevel = input.float(31.0, "RSI Crossing Up Level", minval = 1, maxval = 100, group = grpEntry, tooltip = "Base order arms when LTF RSI crosses up this level (oversold reversal).")

grpExit = "Exit RSI Filter"
exitTF        = input.timeframe("3", "RSI Timeframe", group = grpExit)
exitRsiLen    = input.int(14, "RSI Length", minval = 2, group = grpExit)
exitRsiLevel  = input.float(69.0, "RSI Crossing Down Level", minval = 1, maxval = 100, group = grpExit, tooltip = "Take profit fires when LTF RSI crosses down this level AND minimum profit is reached.")
minProfitPct  = input.float(2.4, "Minimum Profit (%)", minval = 0.1, step = 0.1, group = grpExit, tooltip = "Gate on the exit signal — profit from average entry must be at least this to close.")

grpDate = "Backtest Window"
useDateFilter = input.bool(false, "Limit Backtest Period", group = grpDate)
fromDate      = input.time(timestamp("16 Nov 2025 00:00 +0000"), "From", group = grpDate)
toDate        = input.time(timestamp("01 Jan 2030 00:00 +0000"), "To", group = grpDate)

grpHook = "DCA Bot Webhook"
botId       = input.string("YOUR_BOT_ID", "Bot ID", group = grpHook)
emailToken  = input.string("YOUR_EMAIL_TOKEN", "Email Token", group = grpHook)
pairWebhook = input.string("USDT_INJ", "Pair (QUOTE_BASE)", group = grpHook)

grpViz = "Visualization"
showLevels = input.bool(true, "Show DCA Ladder", group = grpViz)
showLabels = input.bool(true, "Show Fill Labels", group = grpViz)
showTable  = input.bool(true, "Show Status Table", group = grpViz)

inWindow = not useDateFilter or (time >= fromDate and time <= toDate)

// ─────────────────────────────────────────────────────────────────────────────
// LOWER-TIMEFRAME RSI VALUES (no repaint)
// Detection of cross is done at host-bar granularity: a cross is counted
// when LTF RSI moves from one side of the threshold to the other between
// successive HTF bar closes.
// ─────────────────────────────────────────────────────────────────────────────
entryRsi = request.security(syminfo.tickerid, entryTF, ta.rsi(close, entryRsiLen), lookahead = barmerge.lookahead_off)
exitRsi  = request.security(syminfo.tickerid, exitTF,  ta.rsi(close, exitRsiLen),  lookahead = barmerge.lookahead_off)

entryCrossUp   = entryRsi[1] < entryRsiLevel and entryRsi >= entryRsiLevel
exitCrossDown  = exitRsi[1]  > exitRsiLevel  and exitRsi  <= exitRsiLevel

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────
f_cumDev(int k) =>
    float dev  = 0.0
    float step = aoStep
    for i = 1 to k
        if i == 1
            dev := step
        else
            step := step * aoStepMult
            dev  := dev + step
    dev

f_aoSize(int k) =>
    aoSize * math.pow(aoSizeMult, k - 1)

f_msgEntry() => '{"message_type":"bot","bot_id":' + botId + ',"email_token":"' + emailToken + '","delay_seconds":0,"pair":"' + pairWebhook + '"}'
f_msgAddAO() => '{"action":"add_funds_in_quote","message_type":"bot","bot_id":' + botId + ',"email_token":"' + emailToken + '","delay_seconds":0,"pair":"' + pairWebhook + '"}'
f_msgClose() => '{"action":"close_at_market_price","message_type":"bot","bot_id":' + botId + ',"email_token":"' + emailToken + '","delay_seconds":0,"pair":"' + pairWebhook + '"}'

// ─────────────────────────────────────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────────────────────────────────────
var float baseEntry = na
var int   aoFilled  = 0

inPosition       = strategy.position_size != 0
justEntered      = nz(strategy.position_size[1]) == 0 and inPosition
positionJustFlat = nz(strategy.position_size[1]) != 0 and not inPosition

if justEntered and na(baseEntry)
    baseEntry := strategy.position_avg_price
    aoFilled  := 0

if positionJustFlat or not inPosition
    baseEntry := na
    aoFilled  := 0

// ─────────────────────────────────────────────────────────────────────────────
// 1. ENTRY — BASE ORDER (gated by RSI cross up 31 on 3m)
// ─────────────────────────────────────────────────────────────────────────────
openBase = inWindow and not inPosition and strategy.opentrades == 0 and entryCrossUp
if openBase
    baseQty = baseOrderSize / close
    if useLimitBase
        strategy.entry("Long_Base", strategy.long, qty = baseQty, limit = close)
    else
        strategy.entry("Long_Base", strategy.long, qty = baseQty)
    alert(f_msgEntry(), alert.freq_once_per_bar_close)

// ─────────────────────────────────────────────────────────────────────────────
// 2. AVERAGING ORDERS (pure deviation ladder, no AO condition)
// ─────────────────────────────────────────────────────────────────────────────
if inPosition and inWindow and aoFilled < aoCount and not na(baseEntry)
    nextIdx   = aoFilled + 1
    threshold = f_cumDev(nextIdx)
    triggerPx = baseEntry * (1.0 - threshold / 100.0)
    if close <= triggerPx
        aoQtyUsdt = f_aoSize(nextIdx)
        strategy.entry("Long_AO_" + str.tostring(nextIdx), strategy.long, qty = aoQtyUsdt / close)
        aoFilled := nextIdx
        alert(f_msgAddAO(), alert.freq_once_per_bar_close)

// ─────────────────────────────────────────────────────────────────────────────
// 3. EXIT — RSI cross down 69 AND minimum profit ≥ 2.4%
// ─────────────────────────────────────────────────────────────────────────────
if inPosition
    avgPx       = strategy.position_avg_price
    minTpPrice  = avgPx * (1.0 + minProfitPct / 100.0)
    profitArmed = close >= minTpPrice
    if profitArmed and exitCrossDown
        strategy.close_all(comment = "RSI_TP")
        alert(f_msgClose(), alert.freq_once_per_bar_close)

// ─────────────────────────────────────────────────────────────────────────────
// VISUALIZATION
// ─────────────────────────────────────────────────────────────────────────────
plot(inPosition ? strategy.position_avg_price : na, title = "Avg Entry", color = color.new(color.orange, 0), linewidth = 2, style = plot.style_linebr)
plot(inPosition ? strategy.position_avg_price * (1.0 + minProfitPct / 100.0) : na, title = "Min Profit", color = color.new(color.green, 0), linewidth = 1, style = plot.style_linebr)

var aoLines = array.new<line>()

if barstate.islast and showLevels and not na(baseEntry)
    if array.size(aoLines) > 0
        for i = 0 to array.size(aoLines) - 1
            line.delete(array.get(aoLines, i))
        array.clear(aoLines)
    for k = 1 to aoCount
        dev = f_cumDev(k)
        px  = baseEntry * (1.0 - dev / 100.0)
        col = k <= aoFilled ? color.new(color.green, 20) : color.new(color.gray, 50)
        ln  = line.new(x1 = bar_index - 80, x2 = bar_index + 8, y1 = px, y2 = px, color = col, style = line.style_dashed, width = 1)
        array.push(aoLines, ln)
        label.new(x = bar_index + 8, y = px, text = "AO" + str.tostring(k) + "  -" + str.tostring(dev, "#.##") + "%", style = label.style_label_left, color = color.new(color.gray, 70), textcolor = color.white, size = size.tiny)

if showLabels and openBase
    label.new(bar_index, high, "Base ▲", style = label.style_label_down, color = color.new(color.green, 20), textcolor = color.white, size = size.tiny)

if showTable and barstate.islast
    var table tbl = table.new(position = position.top_right, columns = 2, rows = 7, border_width = 1)
    bg  = color.new(color.gray, 30)
    bgH = color.new(color.gray, 0)
    table.cell(tbl, 0, 0, "Status", text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 1, 0, inPosition ? "In Long" : "Flat", text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 0, 1, "AOs Filled", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 1, str.tostring(aoFilled) + " / " + str.tostring(aoCount), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 2, "Base Entry", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 2, na(baseEntry) ? "—" : str.tostring(baseEntry, "#.####"), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 3, "Avg Entry", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 3, inPosition ? str.tostring(strategy.position_avg_price, "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 4, "Min TP", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 4, inPosition ? str.tostring(strategy.position_avg_price * (1.0 + minProfitPct / 100.0), "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 5, entryTF + " RSI (Entry)", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 5, str.tostring(entryRsi, "#.#"), text_color = entryRsi < entryRsiLevel ? color.red : color.white, bgcolor = bg)
    table.cell(tbl, 0, 6, exitTF + " RSI (Exit)", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 6, str.tostring(exitRsi, "#.#"), text_color = exitRsi > exitRsiLevel ? color.green : color.white, bgcolor = bg)
````
