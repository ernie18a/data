# RSI Oversold AO - Long Strategy

- url: https://www.tradingview.com/script/JtopWlYQ-RSI-Oversold-AO-Long-Strategy/
- type: strategy
- pine_id: PUB;e4d6f6d4f28b4ec7a2e5a4810970d60c
- version: 1.0

## Description

RSI Oversold AO — Long Strategy

🔷 What it does:
This is a long-only DCA strategy that buys oversold dips and continues averaging into them only while the asset stays in the oversold zone. A long entry opens on a lower-timeframe RSI crossing down through 30. Four safety orders then average the position on an aggressive 2× deviation × 2× size ladder — but each one fires only if the lower-timeframe RSI is still below 25 at that moment. No falling-knife averaging into recovering momentum. Exit is a fixed 3% Take Profit from average entry. No trailing, no Stop Loss.
  - Single base order with up to four safety orders on a 2× × 2× ladder.
  - Dual RSI gating: cross-down entry trigger AND static oversold continuation filter.
  - Aggressive size compounding: 60 / 120 / 240 / 480 USDT margins on the four safety orders.
  - Fixed Take Profit: 3% above average entry, no trailing.
  - Every entry, safety order, and exit emits a webhook-ready JSON alert payload for direct DCA Bot consumption.

🔷 Who is it for:
  - Swing traders looking for systematic long exposure on crypto pairs that frequently sweep liquidity into oversold readings.
  - DCA-style traders who want averaging gated by momentum continuation, not just price levels — the "no falling knives" guard prevents loading further when momentum has already reversed.
  - Bot operators who want to drive a DCA Bot via webhook with per-event JSON payloads tagged for each base / safety order / exit action.
  - Traders comfortable with deploying up to ~10% of equity per trade in exchange for a wider 3% profit target.

🔷 How does it work:
  Entry RSI Filter (Oversold Cross Down): A 15-minute RSI(7) is sampled via request.security with lookahead disabled. The entry gate fires when RSI crosses down through 30 — momentum has just entered oversold territory. At host-bar close, if no position is open and the cross is fresh, the strategy opens the base order.
  Base Order: Sized at 100 USDT default (1% of 10k capital). Configurable as Market (default) or Limit at the bar's close.
  Safety Order Ladder (Dual Gate): After the base fill, the strategy monitors two conditions in parallel for each pending safety order: price deviation downward against the position AND a static RSI continuation filter. The k-th safety order fires only when close ≤ base entry × (1 − cumulative deviation) AND the 15-minute RSI(7) is still below 25. Cumulative deviation grows by the step multiplier (default 2×): 1.00%, 3.00%, 7.00%, 15.00%. Each safety order's size grows by the size multiplier (default 2×): 60, 120, 240, 480 USDT.
  Why the AO Gate Matters: A pure price-ladder DCA blindly averages into any decline. The RSI < 25 gate stops the averaging if momentum has reversed back above 25 — the asset is no longer oversold by the strategy's definition, and adding to the position would mean buying a recovery, not a dip. This filter trades off some averaging frequency for materially higher average-entry quality.
  Exit: A fixed Take Profit at 3% above the running average entry. The strategy closes the moment close ≥ TP target. No trailing, no scaling out, no second-guessing.

🔷 Why it's unique:
  - Dual RSI Gating: Most DCA tools gate only the base entry. This strategy gates both the entry (cross-down momentum trigger) and the continuation of averaging (static oversold filter on each safety order).
  - Aggressive 2× × 2× Ladder: Most published DCAs use mild 1.05–1.25× compounding. This one doubles both the deviation step and the size each rung — the position gets large fast if all safety orders fill, but only inside a confirmed oversold regime.
  - Wide Take Profit (3%): Most scalp DCAs use tight 0.5–1.0% TPs. The 3% target lets the strategy ride the oversold reversal further before locking in, capturing more of the mean-reversion move.
  - DCA Bot Integration: Every event (base, AO 1–4, exit) emits a fully-formed JSON alert payload. Connect one alert to a DCA Bot's webhook URL and the strategy drives the bot end-to-end without any glue layer.

🔷 Considerations Before Using the Strategy:
  Market & Timeframe: Defaults are calibrated for BINANCE:DOGEUSDT spot on 1h. The dual-RSI logic is portable to other liquid crypto pairs that frequently overshoot oversold, but RSI thresholds and the deviation ladder should be reviewed before redeployment.
  Sample Size: The 4-month backtest produced 44 closed trades — below the ≥100 floor typically used for statistical confidence. The strategy generates roughly 11 closed trades per month at default settings, so extending the test window to 12+ months would yield ~130 trades and a more robust sample. The 77.27% win rate and 5.791 profit factor are encouraging but should be re-validated on a longer test period before live deployment.
  Commission Calibration: The default 0.18% commission was set conservatively above Binance spot taker rates (~0.1%). Live performance with realistic Binance fees should be modestly better than the published numbers. Update the commission input to match your fee tier for accurate forward expectations.
  Strong Downtrends: Like any oversold-buying setup, this strategy is positioned for mean reversions, not waterfall declines. In sustained downtrends the strategy will keep filling the ladder while RSI < 25, then hold the position once RSI recovers. The dual RSI filter limits exposure compared to pure price-ladder DCAs, but a regime shift to sustained selling still produces extended underwater hold time.
  Aggressive Compounding: The 2× × 2× ladder is more aggressive than typical published DCAs. If all four safety orders fill, the position scales from 100 USDT base to 1,000 USDT total = 10% of equity at default settings. This is right at the upper edge of TradingView's typical 5–10% per-trade band — comfortable, but no further headroom. Scale base + AO sizes down to dial position risk lower.
  No Stop Loss Justification: There is no exit on adverse moves beyond the 4-AO ladder. Per-trade risk is structurally capped by the bounded position-size ladder — at defaults that is 1,000 USDT max deployed = 10% of equity, at the upper edge of the conventional 5–10% per-trade band. If a hard exchange-side stop is required, layer it on the bot directly.
  RSI Oversold Continuation: The AO gate uses a static RSI < 25 check, not a cross. This means averaging continues as long as RSI stays below 25 — if RSI dips to 20 and stays there for multiple bars while price drops further, all four AOs can fill in succession. Conversely, a sharp RSI recovery above 25 freezes the ladder mid-position. Test the strategy's behavior on your target asset before live deployment.
  Demo Testing: Always demo-test before going live. Past results do not guarantee future performance, especially on a strategy whose profitability hinges on the asset reaching the 3% TP target while still recovering from an oversold print.

🔷 STRATEGY PROPERTIES
  Symbol: BINANCE:DOGEUSDT (Spot)
  Timeframe: 1H
  Test Period: February 1, 2026 — May 28, 2026 (~4 months).
  Initial Capital: 10,000 USDT.
  Order Size per Trade: 1% of Capital base + 4 safety orders at 2× progression.
  Max Capital Deployed: 1,000 USDT per trade (~10% of equity, upper edge of 5–10% band).
  Commission: 0.18% per trade.
  Slippage: 3 ticks.
  Margin for Long Positions: 100%.
  Indicator Settings: Default Configuration.
  Base Order: 100 USDT, Market by default (Limit toggle available).
  Take Profit: 3.0% above average entry (no trailing).
  Stop Loss: None — bounded position size is the structural risk cap.
  Entry Filter: 15m RSI(7) Crossing Down 30.
  AO Gate: 15m RSI(7) Less Than 25 (static continuation filter).
  Safety Orders: 4, Deviation 1.0%, Deviation Step 2.0×, Size Multiplier 2.0×.
  Strategy: Long Only.

🔷 STRATEGY RESULTS
  ⚠️ Remember, past results do not guarantee future performance.
  Net Profit: +126.22 USDT (+1.26%)
  Max Equity Drawdown: 96.05 USDT (0.96%)
  Total Closed Trades: 44
  Percent Profitable: 77.27% (34 / 44)
  Profit Factor: 5.791

🔷 How to Use It:
  🔸 Adjust Settings: Open the strategy inputs and review the Base Order Size, the entry RSI filter (timeframe / length / level), the AO gate RSI filter, the 4-AO ladder parameters, and the Take Profit percentage. Defaults are calibrated for DOGEUSDT 2h — recalibrate per asset before deploying.
  🔸 Results Review: Run a full-period backtest and confirm Max Drawdown stays inside your personal risk band. Validate that the closed-trade count is statistically meaningful (≥ 100 is a reasonable floor). Update commission and slippage to match your exchange's actual conditions.
  🔸 Create alerts to trigger the DCA Bot: Add one alert on the strategy using "Any alert() function call". Paste the DCA Bot's webhook URL into the alert's Webhook field, and fill the Bot ID, Email Token, and Pair inputs on the script. The strategy will emit JSON payloads for entry, each safety order, and exit — formatted for direct DCA Bot consumption.

🔷 INDICATOR SETTINGS
  Base Order Size (USDT): USDT amount opened on the long entry.
  Use LIMIT for Base: Toggle between Market (default) and Limit at bar close.
  Averaging Orders per Trade: Maximum number of safety orders per deal (default 4).
  First AO Size (USDT): USDT size of the first safety order; subsequent AOs scale by the Size Multiplier.
  Deviation to First AO (%): Distance from base entry at which AO1 becomes eligible.
  Deviation Step Multiplier: Ladder factor that widens each subsequent deviation step.
  Order Size Multiplier: Factor that grows each subsequent safety order's USDT size.
  Entry RSI Timeframe / Length / Level: Lower-timeframe RSI filter that gates the base entry on cross down.
  AO Trigger RSI Timeframe / Length / Less Than: Lower-timeframe RSI continuation filter that gates each safety order.
  Take Profit (%): Fixed distance above average entry where the long closes for profit.
  DCA Bot Webhook: Bot ID, Email Token, and Pair fields injected into every alert payload.
  Visualization: Toggle AO Ladder, Avg / TP plot lines, fill labels, status table.
  Brand Watermark: Configurable text, position, size, and transparency.

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.

__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=6
// =============================================================================
//  RSI Oversold AO DCA — Long Strategy
//  Long-only DCA framework gated by an RSI oversold filter on both ends:
//  the base entry fires on RSI cross down 30, and each safety order requires
//  RSI < 25 on the same lower timeframe ("no falling knives" — only average
//  in when the asset is genuinely oversold). Four safety orders form an
//  aggressive 2× × 2× ladder. Fixed Take Profit, no trailing, no Stop Loss.
//  Calibrated defaults for BYBIT:DOGEUSDT on 2h timeframe.
// =============================================================================
//  NO STOP LOSS — risk is structurally capped by the bounded position-size
//  ladder. Max deployed capital across base + 4 safety orders = 1,000 USDT
//  at default settings ≈ 10% of equity (upper edge of TradingView's 5–10%
//  per-trade band).
// =============================================================================
strategy("RSI Oversold AO DCA — Long Strategy", shorttitle = "RSIAO-L", overlay = true, initial_capital = 10000, default_qty_type = strategy.cash, default_qty_value = 100, pyramiding = 5, commission_type = strategy.commission.percent, commission_value = 0.18, slippage = 3, process_orders_on_close = true, calc_on_every_tick = false, max_labels_count = 500, max_lines_count = 100)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grpBase = "Base Order"
baseOrderSize = input.float(100.0, "Base Order Size (USDT)", minval = 1, group = grpBase, tooltip = "1% of default 10k capital. Sized so that base + all 4 AOs ≤ 10% of equity.")
useLimitBase  = input.bool(false, "Use LIMIT for Base (else Market)", group = grpBase, tooltip = "Source bot used LIMIT base; Market is the more honest backtest default.")

grpAO = "Averaging Orders"
aoCount    = input.int(4, "Averaging Orders per Trade", minval = 0, maxval = 10, group = grpAO)
aoSize     = input.float(60.0, "First AO Size (USDT)", minval = 1, group = grpAO)
aoStep     = input.float(1.0, "Deviation to First AO (%)", minval = 0.1, step = 0.1, group = grpAO)
aoStepMult = input.float(2.0, "Deviation Step Multiplier", minval = 1.0, step = 0.1, group = grpAO)
aoSizeMult = input.float(2.0, "Order Size Multiplier", minval = 1.0, step = 0.1, group = grpAO)

grpEntry = "Entry RSI Filter"
entryTF       = input.timeframe("15", "RSI Timeframe", group = grpEntry)
entryRsiLen   = input.int(7, "RSI Length", minval = 2, group = grpEntry)
entryRsiLevel = input.float(30.0, "RSI Crossing Down Level", minval = 1, maxval = 100, group = grpEntry, tooltip = "Base order arms when LTF RSI crosses down this level (oversold dip entry).")

grpAORSI = "AO Trigger RSI Filter"
aoRsiTF    = input.timeframe("15", "RSI Timeframe", group = grpAORSI)
aoRsiLen   = input.int(7, "RSI Length", minval = 2, group = grpAORSI)
aoRsiLevel = input.float(25.0, "RSI Less Than", minval = 1, maxval = 100, group = grpAORSI, tooltip = "Safety order fires only when LTF RSI is below this level — no falling-knife averaging.")

grpExit = "Exit"
tpPct = input.float(3.0, "Take Profit (%)", minval = 0.1, step = 0.1, group = grpExit, tooltip = "Distance above avg entry where the position closes for profit. No trailing.")

grpDate = "Backtest Window"
useDateFilter = input.bool(true, "Limit Backtest Period", group = grpDate)
fromDate      = input.time(timestamp("01 Feb 2026 00:00 +0000"), "From", group = grpDate)
toDate        = input.time(timestamp("28 May 2026 23:59 +0000"), "To",   group = grpDate)

grpHook = "DCA Bot Webhook"
botId       = input.string("YOUR_BOT_ID",      "Bot ID",            group = grpHook)
emailToken  = input.string("YOUR_EMAIL_TOKEN", "Email Token",       group = grpHook)
pairWebhook = input.string("USDT_DOGE",        "Pair (QUOTE_BASE)", group = grpHook)

grpViz = "Visualization"
showLevels = input.bool(true, "Show AO Ladder",      group = grpViz)
showLabels = input.bool(true, "Show Fill Labels",    group = grpViz)
showLines  = input.bool(true, "Plot Avg / TP Lines", group = grpViz)
showTable  = input.bool(true, "Show Status Table",   group = grpViz)

grpWM = "Brand Watermark"
showWM    = input.bool(true,        "Show Watermark", group = grpWM)
wmText    = input.string("3Commas", "Watermark Text", group = grpWM)
wmPosStr  = input.string("Bottom Right", "Position", options = ["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group = grpWM)
wmSizeStr = input.string("Large",   "Text Size", options = ["Tiny","Small","Normal","Large","Huge"], group = grpWM)
wmAlpha   = input.int(70,           "Transparency (0–100)", minval = 0, maxval = 100, group = grpWM)

inWindow = not useDateFilter or (time >= fromDate and time <= toDate)

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

f_pos(string s) =>
    switch s
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        => position.bottom_right

f_size(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.normal

f_msgEntry() => '{"message_type":"bot","bot_id":' + botId + ',"email_token":"' + emailToken + '","delay_seconds":0,"pair":"' + pairWebhook + '"}'
f_msgAddAO() => '{"action":"add_funds_in_quote","message_type":"bot","bot_id":' + botId + ',"email_token":"' + emailToken + '","delay_seconds":0,"pair":"' + pairWebhook + '"}'
f_msgClose() => '{"action":"close_at_market_price","message_type":"bot","bot_id":' + botId + ',"email_token":"' + emailToken + '","delay_seconds":0,"pair":"' + pairWebhook + '"}'

// ─────────────────────────────────────────────────────────────────────────────
// LOWER-TIMEFRAME FILTERS (no repaint)
// ─────────────────────────────────────────────────────────────────────────────
entryRsi       = request.security(syminfo.tickerid, entryTF, ta.rsi(close, entryRsiLen), lookahead = barmerge.lookahead_off)
entryCrossDown = entryRsi[1] > entryRsiLevel and entryRsi <= entryRsiLevel

aoRsi    = request.security(syminfo.tickerid, aoRsiTF, ta.rsi(close, aoRsiLen), lookahead = barmerge.lookahead_off)
condAOG  = aoRsi < aoRsiLevel

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
// 1. ENTRY — BASE ORDER (RSI cross down 30 on 15m)
// ─────────────────────────────────────────────────────────────────────────────
openBase = inWindow and not inPosition and strategy.opentrades == 0 and entryCrossDown
if openBase
    baseQty = baseOrderSize / close
    if useLimitBase
        strategy.entry("Long_Base", strategy.long, qty = baseQty, limit = close, comment = "Long_Base")
    else
        strategy.entry("Long_Base", strategy.long, qty = baseQty, comment = "Long_Base")
    alert(f_msgEntry(), alert.freq_once_per_bar_close)

// ─────────────────────────────────────────────────────────────────────────────
// 2. AVERAGING ORDERS (price ladder AND RSI < 25 oversold gate)
// ─────────────────────────────────────────────────────────────────────────────
if inPosition and inWindow and aoFilled < aoCount and not na(baseEntry) and condAOG
    nextIdx   = aoFilled + 1
    threshold = f_cumDev(nextIdx)
    triggerPx = baseEntry * (1.0 - threshold / 100.0)
    if close <= triggerPx
        aoQtyUsdt = f_aoSize(nextIdx)
        strategy.entry("Long_AO_" + str.tostring(nextIdx), strategy.long, qty = aoQtyUsdt / close, comment = "Long_AO_" + str.tostring(nextIdx))
        aoFilled := nextIdx
        alert(f_msgAddAO(), alert.freq_once_per_bar_close)

// ─────────────────────────────────────────────────────────────────────────────
// 3. EXIT — Fixed Take Profit (no trailing, no SL)
// ─────────────────────────────────────────────────────────────────────────────
if inPosition
    avgPx   = strategy.position_avg_price
    tpPrice = avgPx * (1.0 + tpPct / 100.0)
    if close >= tpPrice
        strategy.close_all(comment = "TP")
        alert(f_msgClose(), alert.freq_once_per_bar_close)

// ─────────────────────────────────────────────────────────────────────────────
// VISUALIZATION
// ─────────────────────────────────────────────────────────────────────────────
plot(showLines and inPosition ? strategy.position_avg_price : na, title = "Avg Entry", color = color.new(color.orange, 0), linewidth = 2, style = plot.style_linebr)
plot(showLines and inPosition ? strategy.position_avg_price * (1.0 + tpPct / 100.0) : na, title = "TP", color = color.new(color.green, 0), linewidth = 1, style = plot.style_linebr)

var aoLines = array.new<line>()

if barstate.islast and showLevels and not na(baseEntry)
    if array.size(aoLines) > 0
        for i = 0 to array.size(aoLines) - 1
            line.delete(array.get(aoLines, i))
        array.clear(aoLines)
    for k = 1 to aoCount
        dev = f_cumDev(k)
        px  = baseEntry * (1.0 - dev / 100.0)
        col = k <= aoFilled ? color.new(color.green, 10) : color.new(color.gray, 60)
        wid = k <= aoFilled ? 2 : 1
        ln  = line.new(x1 = bar_index - 100, x2 = bar_index + 8, y1 = px, y2 = px, color = col, style = line.style_dashed, width = wid)
        array.push(aoLines, ln)
        label.new(x = bar_index + 8, y = px, text = "AO" + str.tostring(k) + "  -" + str.tostring(dev, "#.##") + "%", style = label.style_label_left, color = color.new(color.gray, 70), textcolor = color.white, size = size.tiny)

if showLabels and openBase
    label.new(bar_index, low, "LONG ▲", style = label.style_label_up, color = color.new(color.green, 20), textcolor = color.white, size = size.tiny)

if showTable and barstate.islast
    var table tbl = table.new(position = position.top_right, columns = 2, rows = 8, border_width = 1)
    bg  = color.new(color.gray, 30)
    bgH = color.new(color.gray, 0)
    table.cell(tbl, 0, 0, "Status",         text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 1, 0, inPosition ? "In Long" : "Flat", text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 0, 1, "AOs Filled",     text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 1, str.tostring(aoFilled) + " / " + str.tostring(aoCount), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 2, "Base Entry",     text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 2, na(baseEntry) ? "—" : str.tostring(baseEntry, "#.#####"), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 3, "Avg Entry",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 3, inPosition ? str.tostring(strategy.position_avg_price, "#.#####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 4, "TP Target",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 4, inPosition ? str.tostring(strategy.position_avg_price * (1.0 + tpPct / 100.0), "#.#####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 5, entryTF + " RSI Entry", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 5, str.tostring(entryRsi, "#.#"), text_color = entryRsi <= entryRsiLevel ? color.green : color.white, bgcolor = bg)
    table.cell(tbl, 0, 6, aoRsiTF + " RSI AO Gate", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 6, str.tostring(aoRsi, "#.#"), text_color = condAOG ? color.green : color.white, bgcolor = bg)
    table.cell(tbl, 0, 7, "Entry Armed",    text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 7, entryCrossDown ? "YES" : "no", text_color = entryCrossDown ? color.green : color.gray, bgcolor = bg)

// ─────────────────────────────────────────────────────────────────────────────
// BRAND WATERMARK
// ─────────────────────────────────────────────────────────────────────────────
var table wm = na
if showWM and barstate.islast
    if na(wm)
        wm := table.new(f_pos(wmPosStr), 1, 1, bgcolor = color.new(color.black, 100), border_width = 0)
    table.cell(wm, 0, 0, wmText, text_color = color.new(color.white, wmAlpha), text_size = f_size(wmSizeStr), bgcolor = color.new(color.black, 100))
````
