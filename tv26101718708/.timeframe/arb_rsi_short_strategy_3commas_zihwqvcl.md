# ARB RSI Short Strategy [3Commas]

- url: https://www.tradingview.com/script/ZiHWqvCl-ARB-RSI-Short-Strategy-3Commas/
- type: strategy
- pine_id: PUB;f745cb3c509545fe8b6eaaa123223f6c
- version: 1.0

## Description

ARB RSI Short Strategy [3Commas]

🔷 What it does:
A short-only, momentum-fade DCA system for Arbitrum on the 4-hour chart. The deal opens only when the 4h RSI(14) crosses back DOWN through 74 — a clean overbought rollover, which on a higher timeframe is a rare, selective event. Two averaging orders then stack ABOVE the base entry (+5% and +10% adverse) with sizes scaled 1.7× per rung, so a continued push higher improves the average. The position closes on a fixed 6% Take Profit from the average. There is no Stop Loss — risk is structurally capped by the bounded 2-rung ladder.
  - Single base short plus two averaging orders at +5% / +10% above entry.
  - Order sizes scaled 1.7×: base 500 → AO1 850 → AO2 1,445.
  - Fixed 6% Take Profit from the running average entry. No trailing.
  - No Stop Loss: maximum position is bounded by the 2-AO ladder (no adds beyond AO2).
  - Every base fill, averaging order, and exit emits a webhook-ready JSON payload for a DCA Bot.

🔷 Who is it for:
  - Swing traders who fade higher-timeframe overbought conditions on ARB.
  - DCA-style traders comfortable with rare, selective entries (a 4h RSI rollover fires only a handful of times per year).
  - Bot operators driving a DCA Bot from TradingView alerts with per-event JSON payloads.
  - Traders who accept a bounded martingale-style ladder in exchange for a high deal-close rate, with no hard stop.

🔷 How does it work:
  Entry Trigger: A 4-hour RSI(14) is sampled via request.security with lookahead disabled (no repaint). The short opens when that RSI was ≥ 74 on the prior 4h close and drops below it on the current close — the overbought-to-neutral rollover.
  Base Order: 500 USDT default (5% of 10k capital), placed Limit at the signal bar's close (a Market toggle is available).
  Averaging Ladder: Two safety orders sit at fixed +5% and +10% above the base. Sizes scale by 1.7× from an 850 USDT first AO (850, then 1,445). Each fill raises the average entry, shrinking the move-down needed to hit the target.
  Exit: A fixed 6% Take Profit below the running average entry. When close reaches it, the position closes at market. No trailing.
  No Stop Loss: There is no exit on adverse moves above the top of the ladder. Per-trade risk is structurally capped by the bounded position — base + 2 AOs = ~$2,795 max deployed (~27.95% of equity). If a hard exchange-side stop is required, layer it on the bot.

🔷 Why it's unique:
  - Higher-Timeframe Rollover: Firing on a 4h RSI cross-down through 74 is far more selective than an intraday trigger — it waits for a meaningful overbought turn, so capital is committed rarely and at stretched conditions.
  - Bounded Averaging, No Stop: A compact 2-rung 1.7× ladder caps the maximum position in advance, which is the structural risk control in place of a stop.
  - Fixed Recovery Target: The 6% Take Profit on the averaged-down entry releases the deal on a clean, defined bounce.
  - Plug-and-Play Webhooks: Base, each AO, and the exit each emit a complete JSON alert; one "Any alert() function call" alert drives a DCA Bot end-to-end.

🔷 Considerations Before Using the Strategy:
  Sample Size (Important): Over a ~3.25-year backtest the strategy produced only 10 closed trades — far below the ~100-trade floor for statistical relevance. The 80% win rate and the high profit factor are a direct consequence of this tiny, selective sample and must NOT be extrapolated as a forward edge. Treat the numbers as a demonstration of the entry's discipline only; validate across more assets and conditions before committing capital, and expect a very low trade frequency.
  No Stop Loss / Tail Risk: With no stop, a sustained rally above the +10% top rung leaves the full position open and unhedged until price reverts to the 6% target — the single largest risk here. The bounded ladder caps how much is deployed (~28% of equity), not how far price can run against the unhedged remainder.
  Market & Timeframe: Calibrated for ARBUSDT.P on 4h. RSI level (74), AO deviations, and sizing should be reviewed before redeploying on another asset.
  Capital Deployment: Maximum deployed is ~$2,795 (~27.95% of default 10k equity) — above the conventional 5–10% per-trade band. Scale the base/AO inputs down to dial exposure into a safer range.
  Commission Calibration: Default commission is 0.06% (Bybit perpetual taker). Match it to your venue's real fees.
  Demo Testing: Always demo-test before going live. Past results do not guarantee future performance, especially on a 10-trade sample.

🔷 STRATEGY PROPERTIES
  Symbol: BYBIT:ARBUSDT.P (Perpetual) — portable to any ARB / USDT pair.
  Timeframe: 4H
  Test Period: March 23, 2023 — June 21, 2026 (~3.25 years).
  Initial Capital: 10,000 USDT.
  Order Size: 500 USDT base (5%) + 2 averaging orders (850, 1,445) scaled 1.7×.
  Max Capital Deployed: ~2,795 USDT per trade (~27.95% of equity).
  Commission: 0.06% per trade.
  Slippage: 3 ticks.
  Margin for Short Positions: 100%.
  Indicator Settings: Default Configuration.
  Base Order: 500 USDT, Limit by default (Market toggle available).
  Entry Trigger: 4h RSI(14) Crossing Down 74.
  Averaging Orders: 2 at fixed +5% / +10% above base entry; sizes 850 / 1,445 (1.7× progression).
  Take Profit: 6.0% below average entry (no trailing).
  Stop Loss: None — bounded position ladder is the structural risk cap.
  Strategy: Short Only.

🔷 STRATEGY RESULTS
  ⚠️ Remember, past results do not guarantee future performance. This is a very small (10-trade) sample — see the Sample Size note above.
  Net Profit: +530.08 USDT (+5.30%)
  Max Equity Drawdown: 448.19 USDT (4.48%)
  Total Closed Trades: 10
  Percent Profitable: 80.00% (8 / 10)
  Profit Factor: 16.189

🔷 How to Use It:
  🔸 Adjust Settings: Review the Base Order Size, the AO deviations/sizes, the RSI trigger level, and the Take Profit. Defaults are calibrated for ARB 4h — recalibrate per asset.
  🔸 Results Review: This configuration produced only 10 closed trades over ~3.25 years — far too few to be statistically meaningful. Treat the metrics as indicative of the entry's selectivity, not a forward guarantee; broaden testing across assets and consider whether the low trade frequency fits your goals before deploying.
  🔸 Create alerts to trigger the DCA Bot: Add one alert on the strategy using "Any alert() function call". Paste the DCA Bot's webhook URL into the alert's Webhook field, and fill the Bot ID, Email Token, and Pair inputs. The strategy emits JSON for entry, each averaging order, and exit.

🔷 INDICATOR SETTINGS
  Base Order Size (USDT): USDT amount opened on the initial short.
  Use LIMIT for Base: Toggle between Limit (default) and Market entry.
  Averaging Orders per Trade: Number of safety orders (default 2).
  First AO Size (USDT): Size of the first averaging order; subsequent AOs scale by the Order Size Multiplier.
  Deviation to First AO (%) / Deviation Step Multiplier: Spacing of the AO ladder above base entry. Defaults to +5% then +10%.
  Order Size Multiplier: Per-rung size scaling (default 1.7).
  RSI Timeframe / Length / Crossing Down Level: The 4h RSI(14) crossing-down trigger for the base short.
  Take Profit (%): Fixed distance below average entry where the short closes for profit.
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
//  ARB RSI Short Strategy
//  Short-only DCA strategy on ARBUSDT.P. A short opens when the 4h RSI(14)
//  crosses DOWN through 78 (overbought rollover). Two averaging orders fill at
//  fixed deviations ABOVE base entry (+5%, +10% adverse) with sizes scaled 1.7x
//  per rung (500 -> 850 -> 1445). Exit is a fixed 6% Take Profit from average
//  entry. NO STOP LOSS — risk is structurally capped by the bounded 2-AO ladder.
//  Calibrated defaults for BYBIT:ARBUSDT.P on 4h timeframe.
// =============================================================================
//  Max deployed capital with both AOs filled = $2,795 on a $10,000 account
//  (~27.95% of equity). There is no stop loss; the position is bounded by the
//  ladder (no adds beyond AO2). Size the base/AO inputs down for lower exposure.
// =============================================================================
strategy("ARB RSI Short Strategy [3Commas]", shorttitle = "ARB RSI-S [3Commas]", overlay = true, initial_capital = 10000, default_qty_type = strategy.cash, default_qty_value = 500, pyramiding = 3, commission_type = strategy.commission.percent, commission_value = 0.06, slippage = 3, process_orders_on_close = true, calc_on_every_tick = false, max_labels_count = 500, max_lines_count = 100)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grpBase = "Base Order"
baseOrderSize = input.float(500.0, "Base Order Size (USDT)", minval = 1, group = grpBase, tooltip = "USDT amount opened on the initial short. 5% of default 10k capital.")
useLimitBase  = input.bool(true, "Use LIMIT for Base (else Market)", group = grpBase)

grpAO = "Averaging Orders (Fixed Deviations)"
aoCount    = input.int(2, "Averaging Orders per Trade", minval = 0, maxval = 10, group = grpAO)
aoSize     = input.float(850.0, "First AO Size (USDT)", minval = 1, group = grpAO, tooltip = "First AO = base x1.7 = 850. Next AOs scale by the Order Size Multiplier.")
aoStep     = input.float(5.0, "Deviation to First AO (%)", minval = 0.1, step = 0.1, group = grpAO, tooltip = "AO1 fires when price rises 5% above base (-5% adverse for the short).")
aoStepMult = input.float(1.0, "Deviation Step Multiplier", minval = 1.0, step = 0.1, group = grpAO, tooltip = "1.0 = uniform 5% steps: +5%, +10% from base.")
aoSizeMult = input.float(1.7, "Order Size Multiplier", minval = 1.0, step = 0.1, group = grpAO, tooltip = "Each AO 1.7x the previous: 850 -> 1445.")

grpEntry = "Trade Start Condition (RSI Crossing Down)"
rsiTF    = input.timeframe("240", "RSI Timeframe", group = grpEntry, tooltip = "240 = 4 hours. Pine timeframe notation.")
rsiLen   = input.int(14, "RSI Length", minval = 2, group = grpEntry)
rsiLevel = input.float(74.0, "RSI Crossing Down Level", minval = 1, maxval = 100, group = grpEntry, tooltip = "Short arms when 4h RSI crosses DOWN through this level (overbought rollover).")

grpExit = "Exit"
tpPct = input.float(6.0, "Take Profit (%)", minval = 0.1, step = 0.1, group = grpExit, tooltip = "Distance below average entry where the short closes for profit. No trailing, no Stop Loss.")

grpDate = "Backtest Window"
useDateFilter = input.bool(true, "Limit Backtest Period", group = grpDate)
fromDate      = input.time(timestamp("01 Aug 2025 00:00 +0000"), "From", group = grpDate)
toDate        = input.time(timestamp("20 Jun 2026 23:59 +0000"), "To", group = grpDate)

grpHook = "DCA Bot Webhook"
botId       = input.string("YOUR_BOT_ID", "Bot ID", group = grpHook)
emailToken  = input.string("YOUR_EMAIL_TOKEN", "Email Token", group = grpHook)
pairWebhook = input.string("USDT_ARB", "Pair (QUOTE_BASE)", group = grpHook)

grpViz = "Visualization"
showLevels = input.bool(true, "Show AO Ladder", group = grpViz)
showLines  = input.bool(true, "Plot Avg / TP Lines", group = grpViz)
showLabels = input.bool(true, "Show Fill Labels", group = grpViz)
showTable  = input.bool(true, "Show Status Table", group = grpViz)

grpWM = "Brand Watermark"
showWM    = input.bool(true,        "Show Watermark", group = grpWM)
wmText    = input.string("3Commas", "Watermark Text", group = grpWM)
wmPosStr  = input.string("Bottom Right", "Position", options = ["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group = grpWM)
wmSizeStr = input.string("Large",   "Text Size", options = ["Tiny","Small","Normal","Large","Huge"], group = grpWM)
wmAlpha   = input.int(70,           "Transparency (0–100)", minval = 0, maxval = 100, group = grpWM)

inWindow = not useDateFilter or (time >= fromDate and time <= toDate)

// ─────────────────────────────────────────────────────────────────────────────
// 4h RSI crossing-down trigger (no repaint)
// ─────────────────────────────────────────────────────────────────────────────
rsiVal     = request.security(syminfo.tickerid, rsiTF, ta.rsi(close, rsiLen), lookahead = barmerge.lookahead_off)
rsiCrossDn = request.security(syminfo.tickerid, rsiTF, ta.crossunder(ta.rsi(close, rsiLen), rsiLevel), lookahead = barmerge.lookahead_off)

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
// 1. ENTRY — BASE ORDER (4h RSI crosses down 78)
// ─────────────────────────────────────────────────────────────────────────────
openBase = inWindow and not inPosition and strategy.opentrades == 0 and rsiCrossDn
if openBase
    baseQty = baseOrderSize / close
    if useLimitBase
        strategy.entry("Short_Base", strategy.short, qty = baseQty, limit = close, comment = "Short_Base")
    else
        strategy.entry("Short_Base", strategy.short, qty = baseQty, comment = "Short_Base")
    alert(f_msgEntry(), alert.freq_once_per_bar_close)

// ─────────────────────────────────────────────────────────────────────────────
// 2. AVERAGING ORDERS — fixed deviations ABOVE base entry (no extra condition)
// ─────────────────────────────────────────────────────────────────────────────
if inPosition and inWindow and aoFilled < aoCount and not na(baseEntry)
    nextIdx   = aoFilled + 1
    threshold = f_cumDev(nextIdx)
    triggerPx = baseEntry * (1.0 + threshold / 100.0)
    if close >= triggerPx
        aoQtyUsdt = f_aoSize(nextIdx)
        strategy.entry("Short_AO_" + str.tostring(nextIdx), strategy.short, qty = aoQtyUsdt / close, comment = "Short_AO_" + str.tostring(nextIdx))
        aoFilled := nextIdx
        alert(f_msgAddAO(), alert.freq_once_per_bar_close)

// ─────────────────────────────────────────────────────────────────────────────
// 3. EXIT — Fixed Take Profit (6%), no trailing, no Stop Loss
// ─────────────────────────────────────────────────────────────────────────────
if inPosition
    avgPx   = strategy.position_avg_price
    tpPrice = avgPx * (1.0 - tpPct / 100.0)
    if close <= tpPrice
        strategy.close_all(comment = "TP")
        alert(f_msgClose(), alert.freq_once_per_bar_close)

// ─────────────────────────────────────────────────────────────────────────────
// VISUALIZATION
// ─────────────────────────────────────────────────────────────────────────────
plot(showLines and inPosition ? strategy.position_avg_price : na, title = "Avg Entry", color = color.new(color.orange, 0), linewidth = 2, style = plot.style_linebr)
plot(showLines and inPosition ? strategy.position_avg_price * (1.0 - tpPct / 100.0) : na, title = "TP Target", color = color.new(color.green, 0), linewidth = 1, style = plot.style_linebr)

var aoLines = array.new<line>()

if barstate.islast and showLevels and not na(baseEntry)
    if array.size(aoLines) > 0
        for i = 0 to array.size(aoLines) - 1
            line.delete(array.get(aoLines, i))
        array.clear(aoLines)
    for k = 1 to aoCount
        dev = f_cumDev(k)
        px  = baseEntry * (1.0 + dev / 100.0)
        col = k <= aoFilled ? color.new(color.red, 20) : color.new(color.gray, 50)
        wid = k <= aoFilled ? 2 : 1
        ln  = line.new(x1 = bar_index - 100, x2 = bar_index + 8, y1 = px, y2 = px, color = col, style = line.style_dashed, width = wid)
        array.push(aoLines, ln)
        sz = f_aoSize(k)
        label.new(x = bar_index + 8, y = px, text = "AO" + str.tostring(k) + "  +" + str.tostring(dev, "#.#") + "%  $" + str.tostring(sz, "#"), style = label.style_label_left, color = color.new(color.gray, 70), textcolor = color.white, size = size.tiny)

if showLabels and openBase
    label.new(bar_index, high, "SHORT ▼", style = label.style_label_down, color = color.new(color.red, 20), textcolor = color.white, size = size.tiny)

if showTable and barstate.islast
    var table tbl = table.new(position = position.top_right, columns = 2, rows = 7, border_width = 1)
    bg  = color.new(color.gray, 30)
    bgH = color.new(color.gray, 0)
    table.cell(tbl, 0, 0, "Status", text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 1, 0, inPosition ? "In Short" : "Flat", text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 0, 1, "AOs Filled", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 1, str.tostring(aoFilled) + " / " + str.tostring(aoCount), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 2, "Base Entry", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 2, na(baseEntry) ? "—" : str.tostring(baseEntry, "#.####"), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 3, "Avg Entry", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 3, inPosition ? str.tostring(strategy.position_avg_price, "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 4, "TP Target", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 4, inPosition ? str.tostring(strategy.position_avg_price * (1.0 - tpPct / 100.0), "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 5, rsiTF + " RSI(" + str.tostring(rsiLen) + ")", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 5, str.tostring(rsiVal, "#.#"), text_color = rsiVal > rsiLevel ? color.red : color.white, bgcolor = bg)
    table.cell(tbl, 0, 6, "Realized PnL", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 6, str.tostring(strategy.netprofit, "#.##") + " USDT (" + str.tostring(strategy.netprofit / strategy.initial_capital * 100, "#.##") + "%)", text_color = strategy.netprofit >= 0 ? color.green : color.red, bgcolor = bg)

// ─────────────────────────────────────────────────────────────────────────────
// BRAND WATERMARK
// ─────────────────────────────────────────────────────────────────────────────
var table wm = na
if showWM and barstate.islast
    if na(wm)
        wm := table.new(f_pos(wmPosStr), 1, 1, bgcolor = color.new(color.black, 100), border_width = 0)
    table.cell(wm, 0, 0, wmText, text_color = color.new(color.white, wmAlpha), text_size = f_size(wmSizeStr), bgcolor = color.new(color.black, 100))
````
