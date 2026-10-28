# SOL RSI DCA - Long Strategy

- url: https://www.tradingview.com/script/ADx8qrBK-SOL-RSI-DCA-Long-Strategy/
- type: strategy
- pine_id: PUB;08999818aee74c64980c609186cb8f58
- version: 1.0

## Description

SOL RSI DCA - Long Strategy

🔷 What it does:
This is a long-only DCA strategy that opens a base long while SOL's higher-timeframe momentum is depressed, then averages down on a geometric price-deviation ladder if the dip extends. A long entry arms whenever the 1-hour RSI(14) sits below a configurable level (default 44). Up to three averaging orders ladder the position deeper on widening deviation steps and growing order sizes. Exit is a fixed Take Profit from the running average entry. No trailing, no Stop Loss.
  - Single base order with up to three averaging orders on a geometric deviation × geometric size ladder.
  - HTF RSI entry gate: base order arms while 1h RSI(14) is below the threshold (Less Than condition).
  - Deviation ladder grows by a 1.3× step multiplier; order sizes grow by a 1.25× size multiplier.
  - Fixed Take Profit: 2.4% above average entry, no trailing.
  - Every entry, averaging order, and exit emits a webhook-ready JSON alert payload for direct DCA Bot consumption.

🔷 Who is it for:
  - Swing traders who want systematic long exposure on SOL when momentum is soft, scaling in if the dip deepens.
  - DCA-style traders who prefer a measured geometric ladder over an aggressive doubling schedule.
  - Bot operators who want to drive a DCA Bot via webhook with per-event JSON payloads tagged for each base / averaging order / exit action.
  - Range and mean-reversion traders comfortable with a moderate per-trade capital footprint (~5% of equity at default settings).

🔷 How does it work:
  Entry RSI Filter (HTF Oversold): A 1-hour RSI(14) is sampled via request.security with lookahead disabled (no repaint). The base order arms whenever this RSI is below the configured level (default 44). At host-bar close, if no position is open, the strategy opens the base order at market.
  Base Order: Sized at 200 USDT default (2% of 10k capital). Configurable as Market (default) or Limit at the bar's close.
  Averaging Order Ladder (Price-Driven): After the base fill, the strategy watches price deviation against the position. The k-th averaging order fires when close ≤ base entry × (1 − cumulative deviation). Cumulative deviation grows by the 1.3× step multiplier: 2.50%, 5.75%, 9.98%. Each averaging order's size grows by the 1.25× size multiplier: 87.5, 109.4, 136.7 USDT. Averaging is gated by price only — no extra RSI condition, matching the source bot configuration.
  Exit: A fixed Take Profit at 2.4% above the running average entry. The strategy closes the moment close ≥ TP target. No trailing, no scaling out.

🔷 Why it's unique:
  - HTF RSI Entry Gate: The base order keys off a 1-hour RSI(14) rather than the chart timeframe, so entries are anchored to the higher-timeframe momentum picture instead of intrabar noise.
  - Measured Geometric Ladder: A 1.3× deviation step paired with a 1.25× size step keeps the average entry compounding controlled — the position deepens gradually rather than ballooning, which keeps maximum deployment near 5% of equity.
  - Honest Position Bookkeeping: The avg-entry line, TP line, and status table all reflect the actual broker-equivalent position state derived from fill-by-fill order tracking — no synthetic averaging.
  - DCA Bot Integration: Every event (base, AO 1–3, exit) emits a fully-formed JSON alert payload. Connect one alert to a DCA Bot's webhook URL and the strategy drives the bot end-to-end without any glue layer.

🔷 Considerations Before Using the Strategy:
  Market & Timeframe: Defaults are calibrated for BINANCE:SOLUSDT spot, with the RSI filter on 1h. Run the strategy on a 1h chart (or lower for finer averaging-order fills). The logic is portable to other liquid pairs, but the RSI level and the deviation ladder should be reviewed before redeployment.
  Entry Is a Level, Not a Cross: The base order uses a Less Than condition (RSI < 44), matching the source bot. This means after a Take Profit, if RSI is still below 44 the strategy can immediately reopen a new deal. This produces more frequent re-entries than a cross-down trigger — intended behavior, but review it against your risk appetite.
  Capital Deployment: If all three averaging orders fill, the position scales from 200 USDT base to ~534 USDT total ≈ 5.3% of equity at default settings — comfortably inside TradingView's 5–10% per-trade band. Scale base + AO sizes down to dial position risk lower.
  No Stop Loss Justification: There is no exit on adverse moves beyond the 3-AO ladder. Per-trade risk is structurally capped by the bounded position-size ladder — at defaults that is ~534 USDT max deployed ≈ 5.3% of equity, well inside the conventional 5–10% per-trade band. If a hard exchange-side stop is required, layer it on the bot directly.
  Strong Downtrends: Like any dip-buying setup, this strategy is positioned for mean reversions, not waterfall declines. In a sustained downtrend the ladder fills out and the position holds underwater until price recovers to the 2.4% TP above average. The bounded ladder limits the size of that exposure, but underwater hold time can still extend.
  Commission Calibration: The default 0.1% commission matches Binance spot taker conditions. Update the commission input to match your fee tier for accurate forward expectations.
  Sample Size: The ~3.5-month backtest produced 29 closed trades — below the ≥100 floor typically used for statistical confidence. The 86.21% win rate and the very high 22.256 profit factor are encouraging but rest on a small sample and a high-win/low-frequency profile (a fixed 2.4% TP that is hit most of the time). Extend the test window to 12+ months and re-validate before drawing firm conclusions or deploying live.
  Demo Testing: Always demo-test before going live. Past results do not guarantee future performance.

🔷 STRATEGY PROPERTIES
  Symbol: BINANCE:SOLUSDT (Spot)
  Timeframe: 1H (recommended; RSI filter sampled on 1h).
  Test Period: February 16, 2026 — June 1, 2026 (~3.5 months).
  Initial Capital: 10,000 USDT.
  Order Size per Trade: 2% of Capital base + 3 averaging orders on a 1.25× size ladder.
  Max Capital Deployed: ~534 USDT per trade (~5.3% of equity).
  Commission: 0.1% per trade.
  Slippage: 3 ticks.
  Margin for Long Positions: 100%.
  Indicator Settings: Default Configuration.
  Base Order: 200 USDT, Market by default (Limit toggle available).
  Take Profit: 2.4% above average entry (no trailing).
  Stop Loss: None — bounded position size is the structural risk cap.
  Entry Filter: 1h RSI(14) Less Than 44.
  Averaging Orders: 3, Deviation 2.5%, Deviation Step 1.3×, Size Multiplier 1.25× (cumulative −2.5% / −5.75% / −9.98%).
  Strategy: Long Only.

🔷 STRATEGY RESULTS
  ⚠️ Remember, past results do not guarantee future performance.
  Net Profit: +82.90 USDT (+0.83%)
  Max Equity Drawdown: 63.27 USDT (0.63%)
  Total Closed Trades: 29
  Percent Profitable: 86.21% (25 / 29)
  Profit Factor: 22.256

🔷 How to Use It:
  🔸 Adjust Settings: Open the strategy inputs and review the Base Order Size, the entry RSI filter (timeframe / length / level), the 3-AO ladder parameters, and the Take Profit percentage. Defaults are calibrated for SOLUSDT on 1h — recalibrate per asset before deploying.
  🔸 Results Review: Run a full-period backtest and confirm Max Drawdown stays inside your personal risk band. Validate that the closed-trade count is statistically meaningful (≥ 100 is a reasonable floor; extend the test window if needed). Update commission and slippage to match your exchange's actual conditions.
  🔸 Create alerts to trigger the DCA Bot: Add one alert on the strategy using "Any alert() function call". Paste the DCA Bot's webhook URL into the alert's Webhook field, and fill the Bot ID, Email Token, and Pair inputs on the script. The strategy will emit JSON payloads for entry, each averaging order, and exit — formatted for direct DCA Bot consumption.

🔷 INDICATOR SETTINGS
  Base Order Size (USDT): USDT amount opened on the long entry.
  Use LIMIT for Base: Toggle between Market (default) and Limit at bar close.
  Averaging Orders per Trade: Maximum number of averaging orders per deal (default 3).
  First AO Size (USDT): USDT size of the first averaging order; subsequent AOs scale by the Size Multiplier.
  Deviation to First AO (%): Distance from base entry at which AO1 becomes eligible.
  Deviation Step Multiplier: Ladder factor that widens each subsequent deviation step.
  Order Size Multiplier: Factor that grows each subsequent averaging order's USDT size.
  Entry RSI Timeframe / Length / Level: Higher-timeframe RSI filter that arms the base entry (Less Than condition).
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
//  SOL RSI DCA — Long Strategy
//  Long-only DCA framework. The base order arms whenever 1h RSI(14) is below a
//  configurable oversold level; up to 3 averaging orders then ladder down on a
//  geometric price-deviation schedule (deviation step multiplier) with a
//  geometric size schedule (order size multiplier). Fixed Take Profit from
//  average price. NO TRAILING, NO STOP LOSS — by explicit design.
//  Calibrated defaults for BINANCE:SOLUSDT.
// =============================================================================
//  NO STOP LOSS — risk is structurally capped by the bounded position-size
//  ladder. Max deployed capital across base + 3 AOs ≈ 534 USDT at default
//  settings ≈ 5.3% of equity (inside TradingView's 5–10% per-trade band).
// =============================================================================
strategy("SOL RSI DCA — Long Strategy", shorttitle = "SOL DCA-L", overlay = true, initial_capital = 10000, default_qty_type = strategy.cash, default_qty_value = 200, pyramiding = 5, commission_type = strategy.commission.percent, commission_value = 0.1, slippage = 3, process_orders_on_close = true, calc_on_every_tick = false, max_labels_count = 500, max_lines_count = 100)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grpBase = "Base Order"
baseOrderSize = input.float(200.0, "Base Order Size (USDT)", minval = 1, group = grpBase, tooltip = "2% of default 10k capital. Sized so base + all 3 AOs ≈ 5.3% of equity.")
useLimitBase  = input.bool(false, "Use LIMIT for Base (else Market)", group = grpBase, tooltip = "Source bot used Market base — the more honest backtest default.")

grpAO = "Averaging Orders"
aoCount    = input.int(3, "Averaging Orders per Trade", minval = 0, maxval = 10, group = grpAO)
aoSize     = input.float(87.5, "First AO Size (USDT)", minval = 1, group = grpAO, tooltip = "Preserves source bot ratio AO1/Base = 0.4375.")
aoStep     = input.float(2.5, "Deviation to First AO (%)", minval = 0.1, step = 0.1, group = grpAO)
aoStepMult = input.float(1.3, "Deviation Step Multiplier", minval = 1.0, step = 0.1, group = grpAO)
aoSizeMult = input.float(1.25, "Order Size Multiplier", minval = 1.0, step = 0.05, group = grpAO)

grpEntry = "Entry RSI Filter"
entryTF       = input.timeframe("60", "RSI Timeframe", group = grpEntry)
entryRsiLen   = input.int(14, "RSI Length", minval = 2, group = grpEntry)
entryRsiLevel = input.float(44.0, "RSI Less Than Level", minval = 1, maxval = 100, group = grpEntry, tooltip = "Base order arms while HTF RSI is below this level (Less Than condition, matching the source bot).")

grpExit = "Exit"
tpPct = input.float(2.4, "Take Profit (%)", minval = 0.1, step = 0.1, group = grpExit, tooltip = "Distance above avg entry where the position closes for profit. No trailing.")

grpDate = "Backtest Window"
useDateFilter = input.bool(true, "Limit Backtest Period", group = grpDate)
fromDate      = input.time(timestamp("16 Feb 2026 00:00 +0000"), "From", group = grpDate)
toDate        = input.time(timestamp("01 Jun 2026 23:59 +0000"), "To",   group = grpDate)

grpHook = "DCA Bot Webhook"
botId       = input.string("YOUR_BOT_ID",      "Bot ID",            group = grpHook)
emailToken  = input.string("YOUR_EMAIL_TOKEN", "Email Token",       group = grpHook)
pairWebhook = input.string("USDT_SOL",         "Pair (QUOTE_BASE)", group = grpHook)

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
// HTF RSI FILTER (no repaint)
// ─────────────────────────────────────────────────────────────────────────────
entryRsi  = request.security(syminfo.tickerid, entryTF, ta.rsi(close, entryRsiLen), lookahead = barmerge.lookahead_off)
entryCond = entryRsi < entryRsiLevel

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
// 1. ENTRY — BASE ORDER (1h RSI < level)
// ─────────────────────────────────────────────────────────────────────────────
openBase = inWindow and not inPosition and strategy.opentrades == 0 and entryCond
if openBase
    baseQty = baseOrderSize / close
    if useLimitBase
        strategy.entry("Long_Base", strategy.long, qty = baseQty, limit = close, comment = "Long_Base")
    else
        strategy.entry("Long_Base", strategy.long, qty = baseQty, comment = "Long_Base")
    alert(f_msgEntry(), alert.freq_once_per_bar_close)

// ─────────────────────────────────────────────────────────────────────────────
// 2. AVERAGING ORDERS (price-deviation ladder, no extra condition)
// ─────────────────────────────────────────────────────────────────────────────
if inPosition and inWindow and aoFilled < aoCount and not na(baseEntry)
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
    table.cell(tbl, 0, 0, "Strategy",       text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 1, 0, "SOL RSI DCA Long", text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 0, 1, "Status",         text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 1, inPosition ? "In Long" : "Flat", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 2, "AOs Filled",     text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 2, str.tostring(aoFilled) + " / " + str.tostring(aoCount), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 3, "Avg Entry",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 3, inPosition ? str.tostring(strategy.position_avg_price, "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 4, "TP Target",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 4, inPosition ? str.tostring(strategy.position_avg_price * (1.0 + tpPct / 100.0), "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 5, entryTF + " RSI",       text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 5, str.tostring(entryRsi, "#.#"), text_color = entryCond ? color.green : color.white, bgcolor = bg)
    table.cell(tbl, 0, 6, "Entry Armed",    text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 6, entryCond ? "YES" : "no", text_color = entryCond ? color.green : color.gray, bgcolor = bg)
    table.cell(tbl, 0, 7, "Open PnL",       text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 7, str.tostring(strategy.openprofit, "#.##") + " USDT", text_color = strategy.openprofit >= 0 ? color.green : color.red, bgcolor = bg)

// ─────────────────────────────────────────────────────────────────────────────
// BRAND WATERMARK
// ─────────────────────────────────────────────────────────────────────────────
var table wm = na
if showWM and barstate.islast
    if na(wm)
        wm := table.new(f_pos(wmPosStr), 1, 1, bgcolor = color.new(color.black, 100), border_width = 0)
    table.cell(wm, 0, 0, wmText, text_color = color.new(color.white, wmAlpha), text_size = f_size(wmSizeStr), bgcolor = color.new(color.black, 100))
````
