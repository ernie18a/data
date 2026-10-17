# LTC RSI Oversold Doubling DCA - Long Strategy

- url: https://www.tradingview.com/script/Ab8n9Rx5-LTC-RSI-Oversold-Doubling-DCA-Long-Strategy/
- type: strategy
- pine_id: PUB;f6c5a331577547edb33e276f8abe82b8
- version: 1.0

## Description

LTC RSI Oversold Doubling DCA — Long Strategy

🔷 What it does:
This is a long-only DCA strategy with an extremely selective entry filter and an aggressive martingale safety-order ladder. A long entry opens only when the 4-hour RSI falls below 29 AND the close price is below a configurable ceiling ($61 by default). Four safety orders fire at fixed deviations from base entry (−2.5%, −5%, −10%, −20%) with sizes doubling on every rung ($2,000 → $4,000 → $8,000 → $16,000). Exit is a wide 35% Take Profit from average entry. No trailing, no Stop Loss.
  - Single base order with up to four safety orders on a non-uniform fixed-deviation ladder.
  - Aggressive size doubling: 1 / 2 / 4 / 8 / 16 unit progression.
  - Wide 35% Take Profit — the strategy is built around catching deep oversold reversals and holding for a meaningful recovery, not scalp profits.
  - Dual entry filter: deeply oversold RSI AND price below a configurable ceiling — extremely selective trigger.
  - Every entry, safety order, and exit emits a webhook-ready JSON alert payload for direct DCA Bot consumption.

🔷 Who is it for:
  - Patient swing traders looking for high-confidence long exposure on LTC when it prints deep oversold readings inside a defined price range.
  - DCA-style traders comfortable with rare entries (the strategy fires only a handful of times per year by design).
  - Bot operators who want to drive a DCA Bot via webhook with per-event JSON payloads tagged for each base / safety order / exit action.
  - Traders who can absorb a doubling martingale ladder up to 31% of equity deployed per trade in exchange for a wide 35% profit target.

🔷 How does it work:
  Entry Filter (Dual Gate): A 4-hour RSI(14) is sampled via request.security with lookahead disabled. The entry gate requires TWO conditions simultaneously at host-bar close: RSI must be below 29 (deep oversold) AND the close price must be below the configurable ceiling (default $61, set against LTC's historical accumulation zone). Both gates filter out shallow dips and price moves above the strategy's "value zone".
  Base Order: Sized at 1,000 USDT default (1% of 100k capital). Configurable as Market (default) or Limit at the bar's close.
  Safety Order Ladder (Fixed Deviations, Doubling Sizes): After the base fill, the strategy monitors price deviation against the position. Each safety order has its own fixed deviation from base entry — not a cumulative ladder. AO1 fires when close ≤ base × 0.975 (−2.5%); AO2 at −5%; AO3 at −10%; AO4 at −20%. Sizes double from a 2,000 USDT first AO: 2,000 / 4,000 / 8,000 / 16,000.
  Exit: A fixed 35% Take Profit above the running average entry. When close hits the TP target, the position closes at market. No trailing, no Stop Loss.
  Why the Wide TP: After a full ladder fill (price drops 20% from base), the average entry sits ~14.25% below base. A 35% TP from that average targets a recovery to ~16% above base — large but achievable on LTC over multi-month timeframes following deep oversold prints. The strategy explicitly trades trade frequency for a high-quality recovery target.

🔷 Why it's unique:
  - Extremely Selective Entry: Most DCA tools fire frequently. This one is gated by two independent filters (deep RSI oversold + price ceiling) that almost never align — backtest produced 11 closed trades across 4 years of LTC history.
  - Non-Uniform Fixed-Deviation Ladder: Most published DCAs use formula-based ladders (step × multiplier). This one exposes each AO deviation as a direct input, allowing asymmetric ladders like 2.5% / 5% / 10% / 20% — deeper safety orders trigger only on serious adverse moves.
  - Doubling Martingale: 1 / 2 / 4 / 8 / 16 size progression is more aggressive than typical 1.05–1.5× compounding. Capital deployed scales exponentially if the position runs adverse, but only inside the defined price ceiling.
  - Wide 35% Take Profit: Most DCAs target 1–3%. This one is built around recovery from deep oversold, not scalp profit.
  - DCA Bot Integration: Every event (base, AO 1–4, exit) emits a fully-formed JSON alert payload. Connect one alert to a DCA Bot's webhook URL and the strategy drives the bot end-to-end without any glue layer.

🔷 Considerations Before Using the Strategy:
  Sample Size: The 4-year backtest produced only 11 closed trades — far below the ≥100 floor typically used for statistical confidence. The 100% win rate and profit factor of 1,661 reflect the extreme selectivity of the entry filter (deep oversold + price below $61), not a deterministic edge. Treat these numbers as an indication of the entry filter's discipline, not as a forward-performance guarantee. The strategy assumes LTC continues to revert from oversold prints under $61 — if the asset enters a sustained regime above $61, the strategy will simply not fire.
  Aggressive Capital Deployment: If all four safety orders fill, total deployed capital reaches $31,000 = 31% of default 100k equity — above TradingView's typical 5–10% per-trade band. Size the base and AO inputs down to dial per-trade risk into a safer range. The doubling martingale amplifies both upside (when price recovers) and risk (if the lower bound breaks).
  No Stop Loss: There is no exit on adverse moves below the −20% AO4. If price keeps falling below the lowest safety order, the position holds unhedged until either price recovers to the 35% TP target or the user intervenes. The structural risk cap is the bounded position ladder; if a hard exchange-side stop is required, layer it on the bot directly.
  Price Ceiling Configuration: The default $61 ceiling was set against LTC's historical accumulation range. Update this input if LTC enters a new structural price regime — the strategy will not fire above the ceiling regardless of RSI readings.
  Wide Profit Target: The 35% Take Profit is large by DCA standards. Position holding times can stretch into months or longer as the strategy waits for the recovery. Consider whether the opportunity cost of locked capital fits your portfolio rotation cadence.
  Commission Calibration: The default 0.06% commission is calibrated for Bybit perpetual taker conditions. If running on a spot venue (Coinbase, Binance) the actual fee is 0.1–0.6% — update the commission input accordingly. Given the wide TP and low trade frequency, fee impact is modest.

🔷 STRATEGY PROPERTIES
  Symbol: COINBASE:LTCUSD (Spot) — portable to any LTC / USDT pair.
  Timeframe: 4H
  Test Period: May 1, 2022 — May 29, 2026 (~4 years, DEEP historical sample).
  Initial Capital: 100,000 USDT.
  Order Size per Trade: 1% of Capital base + 4 safety orders with size doubling.
  Max Capital Deployed: $31,000 per trade (~31% of equity).
  Commission: 0.06% per trade.
  Slippage: 3 ticks.
  Margin for Long Positions: 100%.
  Indicator Settings: Default Configuration.
  Base Order: 1,000 USDT, Market by default (Limit toggle available).
  Take Profit: 35.0% above average entry (no trailing).
  Stop Loss: None — bounded position size is the structural risk cap.
  Entry Filter: 4h RSI(14) Less Than 29 AND Close Below $61.
  Safety Orders: 4 with fixed deviations −2.5% / −5% / −10% / −20% from base entry; sizes 2k / 4k / 8k / 16k USDT.
  Strategy: Long Only.

🔷 STRATEGY RESULTS
  ⚠️ Remember, past results do not guarantee future performance.
  Net Profit: +13,907.58 USD (+13.91%)
  Max Equity Drawdown: 6,503.88 USD (6.50%)
  Total Closed Trades: 11
  Percent Profitable: 100.00% (11 / 11)
  Profit Factor: 1,661.503

🔷 How to Use It:
  🔸 Adjust Settings: Open the strategy inputs and review the Base Order Size, the four AO deviations and sizes, the entry filters (RSI level + price ceiling), and the Take Profit percentage. Defaults are calibrated for LTC 4h — recalibrate the price ceiling whenever LTC's structural range shifts.
  🔸 Results Review: The 4-year backtest produced 11 closed trades — a small sample size. Treat the metrics as indicative of the entry filter's discipline, not a forward-performance guarantee. Confirm that the trade frequency and the wide 35% Take Profit fit your portfolio rotation horizon before deploying capital.
  🔸 Create alerts to trigger the DCA Bot: Add one alert on the strategy using "Any alert() function call". Paste the DCA Bot's webhook URL into the alert's Webhook field, and fill the Bot ID, Email Token, and Pair inputs on the script. The strategy will emit JSON payloads for entry, each safety order, and exit — formatted for direct DCA Bot consumption.

🔷 INDICATOR SETTINGS
  Base Order Size (USDT): USDT amount opened on the long entry.
  Use LIMIT for Base: Toggle between Market (default) and Limit at bar close.
  AO1 / AO2 / AO3 / AO4 Deviation (%): Fixed distance from base entry where each safety order becomes eligible. Non-uniform by design.
  AO1 / AO2 / AO3 / AO4 Size (USDT): USDT amount of each safety order. Doubles at each rung by default.
  RSI Timeframe / Length / Less Than: Lower-timeframe RSI filter for the base entry.
  Price Below ($): Absolute price ceiling — entry only fires below this level.
  Take Profit (%): Fixed distance above average entry where the long closes for profit.
  DCA Bot Webhook: Bot ID, Email Token, and Pair fields injected into every alert payload.
  Visualization: Toggle AO Ladder, Price Ceiling line, Avg / TP plot lines, fill labels, status table.
  Brand Watermark: Configurable text, position, size, and transparency.

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.

__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=6
// =============================================================================
//  LTC RSI Oversold Doubling DCA — Long Strategy
//  Long-only DCA framework on LTCUSDT with TWO entry filters:
//    • RSI(14) below 29 on 4h (deep oversold)
//    • Close price below a configurable ceiling (default $61)
//  Four safety orders fire at FIXED deviations from base entry (−2.5%, −5%,
//  −10%, −20%) with size DOUBLING on every rung ($2k → $4k → $8k → $16k).
//  Fixed Take Profit, no trailing, no Stop Loss.
//  Calibrated defaults for BYBIT:LTCUSDT on 4h-RSI-driven timeframe.
// =============================================================================
//  AGGRESSIVE COMPOUNDING — max deployed capital with all AOs filled = $31,000
//  on a $100,000 initial capital ≈ 31% of equity per trade. This is above
//  TradingView's typical 5–10% per-trade band; the position is bounded by the
//  4-AO ladder and there is no Stop Loss. Size the base order down or reduce
//  AO sizes to dial per-trade exposure into a safer range.
// =============================================================================
strategy("LTC RSI Oversold Doubling DCA — Long Strategy", shorttitle = "LTC-OS-L", overlay = true, initial_capital = 100000, default_qty_type = strategy.cash, default_qty_value = 1000, pyramiding = 5, commission_type = strategy.commission.percent, commission_value = 0.06, slippage = 3, process_orders_on_close = true, calc_on_every_tick = false, max_labels_count = 500, max_lines_count = 100)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grpBase = "Base Order"
baseOrderSize = input.float(1000.0, "Base Order Size (USDT)", minval = 1, group = grpBase, tooltip = "1% of default 100k capital. Total max position with all 4 AOs filled ≈ $31,000 = 31% of equity (aggressive doubling martingale).")
useLimitBase  = input.bool(false, "Use LIMIT for Base (else Market)", group = grpBase)

grpAO = "Averaging Orders (Fixed Deviations + Doubling)"
ao1Dev = input.float(2.5,  "AO1 Deviation from Base (%)", minval = 0.1, step = 0.1, group = grpAO)
ao2Dev = input.float(5.0,  "AO2 Deviation from Base (%)", minval = 0.1, step = 0.1, group = grpAO)
ao3Dev = input.float(10.0, "AO3 Deviation from Base (%)", minval = 0.1, step = 0.1, group = grpAO)
ao4Dev = input.float(20.0, "AO4 Deviation from Base (%)", minval = 0.1, step = 0.1, group = grpAO)
ao1Size = input.float(2000.0,  "AO1 Size (USDT)", minval = 1, group = grpAO)
ao2Size = input.float(4000.0,  "AO2 Size (USDT)", minval = 1, group = grpAO)
ao3Size = input.float(8000.0,  "AO3 Size (USDT)", minval = 1, group = grpAO)
ao4Size = input.float(16000.0, "AO4 Size (USDT)", minval = 1, group = grpAO)

grpEntry = "Entry Filters"
rsiTF     = input.timeframe("240", "RSI Timeframe", group = grpEntry, tooltip = "240 = 4 hours. Pine timeframe notation.")
rsiLen    = input.int(14, "RSI Length", minval = 2, group = grpEntry)
rsiLevel  = input.float(29.0, "RSI Less Than", minval = 1, maxval = 100, group = grpEntry, tooltip = "Entry arms when LTF RSI is below this level (deep oversold).")
priceCeil = input.float(61.0, "Price Below ($)", minval = 0, step = 0.01, group = grpEntry, tooltip = "Entry only fires when close price is below this ceiling.")

grpExit = "Exit"
tpPct = input.float(35.0, "Take Profit (%)", minval = 0.1, step = 0.1, group = grpExit, tooltip = "Distance above avg entry where the long closes for profit. No trailing.")

grpDate = "Backtest Window"
useDateFilter = input.bool(true, "Limit Backtest Period", group = grpDate)
fromDate      = input.time(timestamp("01 May 2022 00:00 +0000"), "From", group = grpDate)
toDate        = input.time(timestamp("28 May 2026 23:59 +0000"), "To",   group = grpDate)

grpHook = "DCA Bot Webhook"
botId       = input.string("YOUR_BOT_ID",      "Bot ID",            group = grpHook)
emailToken  = input.string("YOUR_EMAIL_TOKEN", "Email Token",       group = grpHook)
pairWebhook = input.string("USDT_LTC",         "Pair (QUOTE_BASE)", group = grpHook)

grpViz = "Visualization"
showLevels    = input.bool(true, "Show AO Ladder",         group = grpViz)
showPriceCeil = input.bool(true, "Show Price Ceiling Line", group = grpViz)
showLabels    = input.bool(true, "Show Fill Labels",       group = grpViz)
showLines     = input.bool(true, "Plot Avg / TP Lines",    group = grpViz)
showTable     = input.bool(true, "Show Status Table",      group = grpViz)

grpWM = "Brand Watermark"
showWM    = input.bool(true,        "Show Watermark", group = grpWM)
wmText    = input.string("3Commas", "Watermark Text", group = grpWM)
wmPosStr  = input.string("Bottom Right", "Position", options = ["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group = grpWM)
wmSizeStr = input.string("Large",   "Text Size", options = ["Tiny","Small","Normal","Large","Huge"], group = grpWM)
wmAlpha   = input.int(70,           "Transparency (0–100)", minval = 0, maxval = 100, group = grpWM)

inWindow = not useDateFilter or (time >= fromDate and time <= toDate)

// AO arrays — fixed deviations and sizes (not formula-driven)
aoDevs  = array.from(ao1Dev,  ao2Dev,  ao3Dev,  ao4Dev)
aoSizes = array.from(ao1Size, ao2Size, ao3Size, ao4Size)
aoCount = 4

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────
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
// LTF RSI (no repaint)
// ─────────────────────────────────────────────────────────────────────────────
rsiVal    = request.security(syminfo.tickerid, rsiTF, ta.rsi(close, rsiLen), lookahead = barmerge.lookahead_off)
condRSI   = rsiVal < rsiLevel
condPrice = close < priceCeil
entrySignal = condRSI and condPrice

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
// 1. ENTRY — BASE ORDER (RSI < 29 on 4h AND close < $61)
// ─────────────────────────────────────────────────────────────────────────────
openBase = inWindow and not inPosition and strategy.opentrades == 0 and entrySignal
if openBase
    baseQty = baseOrderSize / close
    if useLimitBase
        strategy.entry("Long_Base", strategy.long, qty = baseQty, limit = close, comment = "Long_Base")
    else
        strategy.entry("Long_Base", strategy.long, qty = baseQty, comment = "Long_Base")
    alert(f_msgEntry(), alert.freq_once_per_bar_close)

// ─────────────────────────────────────────────────────────────────────────────
// 2. AVERAGING ORDERS — fixed deviations from BASE entry (not cumulative)
// ─────────────────────────────────────────────────────────────────────────────
if inPosition and inWindow and aoFilled < aoCount and not na(baseEntry)
    nextIdx   = aoFilled + 1
    threshold = array.get(aoDevs, nextIdx - 1)
    triggerPx = baseEntry * (1.0 - threshold / 100.0)
    if close <= triggerPx
        aoUsdt = array.get(aoSizes, nextIdx - 1)
        strategy.entry("Long_AO_" + str.tostring(nextIdx), strategy.long, qty = aoUsdt / close, comment = "Long_AO_" + str.tostring(nextIdx))
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
plot(showPriceCeil ? priceCeil : na, title = "Price Ceiling", color = color.new(color.purple, 30), linewidth = 1, style = plot.style_circles)

var aoLines = array.new<line>()

if barstate.islast and showLevels and not na(baseEntry)
    if array.size(aoLines) > 0
        for i = 0 to array.size(aoLines) - 1
            line.delete(array.get(aoLines, i))
        array.clear(aoLines)
    for k = 1 to aoCount
        dev = array.get(aoDevs, k - 1)
        px  = baseEntry * (1.0 - dev / 100.0)
        col = k <= aoFilled ? color.new(color.green, 10) : color.new(color.gray, 60)
        wid = k <= aoFilled ? 2 : 1
        ln  = line.new(x1 = bar_index - 100, x2 = bar_index + 8, y1 = px, y2 = px, color = col, style = line.style_dashed, width = wid)
        array.push(aoLines, ln)
        sz = array.get(aoSizes, k - 1)
        label.new(x = bar_index + 8, y = px, text = "AO" + str.tostring(k) + "  -" + str.tostring(dev, "#.#") + "%  $" + str.tostring(sz, "#"), style = label.style_label_left, color = color.new(color.gray, 70), textcolor = color.white, size = size.tiny)

if showLabels and openBase
    label.new(bar_index, low, "LONG ▲", style = label.style_label_up, color = color.new(color.green, 20), textcolor = color.white, size = size.tiny)

if showTable and barstate.islast
    var table tbl = table.new(position = position.top_right, columns = 2, rows = 9, border_width = 1)
    bg  = color.new(color.gray, 30)
    bgH = color.new(color.gray, 0)
    table.cell(tbl, 0, 0, "Status",         text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 1, 0, inPosition ? "In Long" : "Flat", text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 0, 1, "AOs Filled",     text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 1, str.tostring(aoFilled) + " / " + str.tostring(aoCount), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 2, "Base Entry",     text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 2, na(baseEntry) ? "—" : str.tostring(baseEntry, "#.##"), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 3, "Avg Entry",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 3, inPosition ? str.tostring(strategy.position_avg_price, "#.##") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 4, "TP Target",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 4, inPosition ? str.tostring(strategy.position_avg_price * (1.0 + tpPct / 100.0), "#.##") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 5, rsiTF + " RSI(" + str.tostring(rsiLen) + ")", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 5, str.tostring(rsiVal, "#.#"), text_color = condRSI ? color.green : color.white, bgcolor = bg)
    table.cell(tbl, 0, 6, "Price < $" + str.tostring(priceCeil, "#"), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 6, condPrice ? "YES" : "no", text_color = condPrice ? color.green : color.gray, bgcolor = bg)
    table.cell(tbl, 0, 7, "Entry Armed",    text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 7, entrySignal ? "YES" : "no", text_color = entrySignal ? color.green : color.gray, bgcolor = bg)
    table.cell(tbl, 0, 8, "Max Deployed",   text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 8, "$" + str.tostring(baseOrderSize + ao1Size + ao2Size + ao3Size + ao4Size, "#"), text_color = color.white, bgcolor = bg)

// ─────────────────────────────────────────────────────────────────────────────
// BRAND WATERMARK
// ─────────────────────────────────────────────────────────────────────────────
var table wm = na
if showWM and barstate.islast
    if na(wm)
        wm := table.new(f_pos(wmPosStr), 1, 1, bgcolor = color.new(color.black, 100), border_width = 0)
    table.cell(wm, 0, 0, wmText, text_color = color.new(color.white, wmAlpha), text_size = f_size(wmSizeStr), bgcolor = color.new(color.black, 100))
````
