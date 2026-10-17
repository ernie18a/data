# ATOM RSI Strategy [3Commas]

- url: https://www.tradingview.com/script/lnBGmMLT-ATOM-RSI-Strategy-3Commas/
- type: strategy
- pine_id: PUB;5d3cba40fc5343c9bdaf200e6e12f4cc
- version: 1.0

## Description

ATOM RSI Long Strategy [3Commas]

🔷 What it does:
This is a long-only DCA (Dollar-Cost Averaging) strategy for ATOM / USDT that opens a position only in deep-oversold conditions and then averages down on a fixed safety-order ladder. A base order fires when 4h RSI(14) drops below 28; if price keeps falling, five averaging orders add to the position at fixed deviations from the base entry, each larger than the last. The full position is closed at a fixed take-profit above the blended average entry. There is no trailing exit and no stop loss — the position is structurally bounded by the five-order ladder.
  - Single entry filter: 4h RSI(14) below 28 (deep oversold).
  - Five averaging orders at fixed deviations (−2%, −5%, −9.5%, −16%, −25%) with 1.8× size scaling per rung.
  - Fixed take-profit on the blended average entry; no trailing, no stop loss.
  - Every fill and close emits a webhook-ready JSON alert payload for a DCA Bot.

🔷 Who is it for:
  - Swing traders accumulating ATOM on deep RSI flushes rather than chasing momentum.
  - Bot operators who want a chart-driven signal source with base / safety-order / close webhook JSON ready to drive a DCA Bot.
  - Traders comfortable with martingale-style averaging who size their capital to the worst-case ladder fill.
  - Range / mean-reversion traders who prefer mechanical oversold entries over discretionary timing.

🔷 How does it work:
  Entry (Base Order): On each closed 4h bar the strategy reads RSI(14). When RSI falls below 28 and there is no open position, it opens the base order at market (or limit, optionally) and dispatches the entry webhook.
  Averaging Orders: Once in a position, the strategy watches price relative to the original base entry. The five safety orders are armed at fixed deviations from that base entry — not cumulatively — at −2%, −5%, −9.5%, −16%, and −25%. As each threshold is crossed on bar close, the corresponding averaging order fires. Order sizes scale 1.8× per rung ($900 → $1,620 → $2,916 → $5,249 → $9,448 from a $500 base), pulling the blended average entry down toward the latest fill.
  Exit (Take Profit): While in a position, the strategy computes a take-profit price a fixed percentage above the current average entry. When price closes at or above that level, the entire position is closed at market and the close webhook fires. There is no trailing and no stop loss.
  Capital Bounds: Total deployed capital cannot exceed the base order plus the five safety orders. Once all five averaging orders are filled, no further adds occur — the position simply waits for the take-profit. This ladder cap is the strategy's primary risk control.

🔷 Why it's unique:
  - Deep-Oversold-Only Entries: A single, strict RSI(14) < 28 filter on 4h keeps the strategy out of the market in normal conditions and only commits capital after a meaningful flush.
  - Fixed-Deviation Martingale Ladder: Safety orders are placed at fixed percentages from the base entry with deliberate 1.8× size scaling, so each rung has progressively more influence on the average — a transparent, fully-specified averaging schedule rather than an opaque adaptive grid.
  - Full Webhook Chain: Base order, each safety order, and the close all emit dedicated JSON payloads. The strategy can drive a 3Commas DCA Bot end-to-end with no glue layer.
  - On-Chart Transparency: The AO ladder, average entry, and take-profit target are plotted live, and the status table reports RSI, AOs filled, base/average entry, TP target, and max deployable capital — so the position state is always visible.

🔷 Considerations Before Using the Strategy:
  Trade Volume — Below the Statistical Floor: The reference backtest produced 84 closed trades over ~30 months. This is below the ~100-trade threshold often used as a floor for statistical relevance, so treat the win rate and profit factor as indicative rather than conclusive. The strict RSI < 28 filter is what keeps the trade count low.
  Martingale Tail Risk: Order sizes scale 1.8× per rung, so the deepest fills are by far the largest. If ATOM trends hard below the −25% AO5 level without recovering to take-profit, the position sits fully loaded with no further adds and no stop — unrealized loss can grow until price reverts. The 1.8× scaling amplifies both the recovery speed and the downside.
  No Stop Loss Justification: There is no exit on adverse moves. Per-order risk is bounded by the fixed ladder allocation; aggregate exposure is capped at base + five AOs (≈ $20,633 on the default $100k account, ~20.6% of equity). Size the base/AO inputs down to match the worst-case exposure you are willing to hold.
  Capital Deployment & Drawdown: The reference backtest reached a 4.57% maximum equity drawdown at default sizing — but that depends on the configured ladder fitting within ATOM's observed swings. A deeper or more prolonged decline than the test sample would produce a larger drawdown.
  Fees: The default commission (0.06% per trade) should be matched to your exchange's actual taker fees. With a fixed 3% take-profit the per-trade edge is modest, so a fee mismatch matters.
  Demo Testing: Always demo-test before going live. Past results do not guarantee future performance, particularly for martingale-style averaging strategies whose risk profile is dominated by rare deep drawdowns.

🔷 STRATEGY PROPERTIES
  Symbol: BYBIT:ATOMUSDT.P (Perpetual) — strategy is portable to any ATOM / USDT pair.
  Timeframe: 4H (RSI sampled on 4h).
  Test Period: January 1, 2024 — June 24, 2026 (~30 months).
  Initial Capital: 100,000 USDT.
  Base Order Size: 500 USDT.
  Averaging Orders: 5, at −2% / −5% / −9.5% / −16% / −25% from base entry.
  AO Sizing: 1.8× per rung — 900 / 1,620 / 2,916 / 5,249 / 9,448 USDT.
  Max Deployed Capital: ≈ 20,633 USDT (~20.6% of equity, all AOs filled).
  Commission: 0.06% per trade.
  Slippage: 3 ticks.
  Entry Filter: 4h RSI(14) below 28.
  Take Profit: 3% above average entry.
  Stop Loss: None — ladder allocation is the structural risk cap.
  Trailing: None.
  Strategy: Long Only.

🔷 STRATEGY RESULTS
  ⚠️ Remember, past results do not guarantee future performance.
  Net Profit: +4,739.50 USDT (+4.74%)
  Max Equity Drawdown: 4,608.66 USDT (4.57%)
  Total Closed Trades: 84
  Percent Profitable: 70.24% (59 / 84)
  Profit Factor: 3.417

🔷 How to Use It:
  🔸 Adjust Settings: Open the strategy inputs and confirm the RSI level (28), the five AO deviations and sizes, and the take-profit percentage match your risk profile. Scale the base/AO sizes down for lower exposure.
  🔸 Results Review: Run a full-period backtest and confirm Max Drawdown stays within your personal risk band — note this configuration reached 4.57%. Keep in mind the 84-trade sample is below the ~100-trade floor for statistical confidence.
  🔸 Create alerts to trigger the DCA Bot: Add one alert on the strategy using "Any alert() function call". Paste your DCA Bot's webhook URL into the alert's Webhook field, and fill the Bot ID, Email Token, and Pair inputs on the script. The base order, each safety order, and the close will each emit a dedicated JSON payload.

🔷 INDICATOR SETTINGS
  Base Order Size: Capital committed on the first (base) entry.
  AO Deviations: Fixed percentage distances from the base entry where each safety order fires.
  AO Sizes: Capital per safety order (1.8× scaling by default).
  RSI Timeframe / Length / Level: Oversold filter for the base entry (default 4h, 14, below 28).
  Take Profit (%): Distance above average entry where the full position closes.
  Bot ID / Email Token / Pair: Webhook fields injected into every alert payload.
  Visualization: Toggle the AO ladder, fill labels, avg/TP lines, and status table.
  Brand Watermark: Configurable text, position, size, and transparency.

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.

__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
// =============================================================================
//  ATOM RSI Long Strategy
//  Long-only DCA framework on ATOMUSDT.P with a single entry filter:
//    • RSI(14) below 28 on 4h (deep oversold)
//  Five safety orders fire at FIXED deviations from base entry (−2%, −5%, −9.5%,
//  −16%, −25%) with size scaling 1.8x per rung ($900 → $1,620 → $2,916 →
//  $5,249 → $9,448 from a $500 base). Fixed Take Profit, no trailing, no Stop Loss.
//  Calibrated defaults for BYBIT:ATOMUSDT.P on 4h timeframe.
// =============================================================================
//  Max deployed capital with all 5 AOs filled ≈ $20,633 on a $100,000 account
//  (~20.6% of equity). The position is bounded by the 5-AO ladder (no adds below
//  AO5) and there is no Stop Loss. Size the base/AO inputs down for lower exposure.
// =============================================================================
//@version=6
strategy("ATOM RSI Strategy [3Commas]", shorttitle = "ATOM RSI-L [3Commas]", overlay = true, initial_capital = 100000, default_qty_type = strategy.cash, default_qty_value = 500, pyramiding = 6, commission_type = strategy.commission.percent, commission_value = 0.06, slippage = 3, process_orders_on_close = true, calc_on_every_tick = false, max_labels_count = 500, max_lines_count = 100)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grpBase = "Base Order"
baseOrderSize = input.float(500.0, "Base Order Size (USDT)", minval = 1, group = grpBase, tooltip = "0.5% of default 100k capital. Total max position with all 5 AOs filled ≈ $20,633 = 20.6% of equity (1.8x scaling martingale).")
useLimitBase  = input.bool(false, "Use LIMIT for Base (else Market)", group = grpBase)

grpAO = "Averaging Orders (Fixed Deviations + 1.8x Scaling)"
ao1Dev = input.float(2.0,  "AO1 Deviation from Base (%)", minval = 0.1, step = 0.1, group = grpAO)
ao2Dev = input.float(5.0,  "AO2 Deviation from Base (%)", minval = 0.1, step = 0.1, group = grpAO)
ao3Dev = input.float(9.5,  "AO3 Deviation from Base (%)", minval = 0.1, step = 0.1, group = grpAO)
ao4Dev = input.float(16.0, "AO4 Deviation from Base (%)", minval = 0.1, step = 0.1, group = grpAO)
ao5Dev = input.float(25.0, "AO5 Deviation from Base (%)", minval = 0.1, step = 0.1, group = grpAO)
ao1Size = input.float(900.0,  "AO1 Size (USDT)", minval = 1, group = grpAO)
ao2Size = input.float(1620.0, "AO2 Size (USDT)", minval = 1, group = grpAO)
ao3Size = input.float(2916.0, "AO3 Size (USDT)", minval = 1, group = grpAO)
ao4Size = input.float(5249.0, "AO4 Size (USDT)", minval = 1, group = grpAO)
ao5Size = input.float(9448.0, "AO5 Size (USDT)", minval = 1, group = grpAO)

grpEntry = "Entry Filters"
rsiTF     = input.timeframe("240", "RSI Timeframe", group = grpEntry, tooltip = "240 = 4 hours. Pine timeframe notation.")
rsiLen    = input.int(14, "RSI Length", minval = 2, group = grpEntry)
rsiLevel  = input.float(28.0, "RSI Less Than", minval = 1, maxval = 100, group = grpEntry, tooltip = "Entry arms when 4h RSI is below this level (deep oversold).")

grpExit = "Exit"
tpPct = input.float(3.0, "Take Profit (%)", minval = 0.1, step = 0.1, group = grpExit, tooltip = "Distance above avg entry where the long closes for profit. No trailing.")

grpDate = "Backtest Window"
useDateFilter = input.bool(true, "Limit Backtest Period", group = grpDate)
fromDate      = input.time(timestamp("01 Jan 2024 00:00 +0000"), "From", group = grpDate)
toDate        = input.time(timestamp("23 Jun 2026 23:59 +0000"), "To",   group = grpDate)

grpHook = "DCA Bot Webhook"
botId       = input.string("YOUR_BOT_ID",      "Bot ID",            group = grpHook)
emailToken  = input.string("YOUR_EMAIL_TOKEN", "Email Token",       group = grpHook)
pairWebhook = input.string("USDT_ATOM",        "Pair (QUOTE_BASE)", group = grpHook)

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

// AO arrays — fixed deviations and sizes (not formula-driven)
aoDevs  = array.from(ao1Dev,  ao2Dev,  ao3Dev,  ao4Dev,  ao5Dev)
aoSizes = array.from(ao1Size, ao2Size, ao3Size, ao4Size, ao5Size)
aoCount = 5

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
// 4h RSI (no repaint)
// ─────────────────────────────────────────────────────────────────────────────
rsiVal      = request.security(syminfo.tickerid, rsiTF, ta.rsi(close, rsiLen), lookahead = barmerge.lookahead_off)
condRSI     = rsiVal < rsiLevel
entrySignal = condRSI

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
// 1. ENTRY — BASE ORDER (RSI < 28 on 4h)
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
    var table tbl = table.new(position = position.top_right, columns = 2, rows = 8, border_width = 1)
    bg  = color.new(color.gray, 30)
    bgH = color.new(color.gray, 0)
    table.cell(tbl, 0, 0, "Status",         text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 1, 0, inPosition ? "In Long" : "Flat", text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 0, 1, "AOs Filled",     text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 1, str.tostring(aoFilled) + " / " + str.tostring(aoCount), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 2, "Base Entry",     text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 2, na(baseEntry) ? "—" : str.tostring(baseEntry, "#.####"), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 3, "Avg Entry",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 3, inPosition ? str.tostring(strategy.position_avg_price, "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 4, "TP Target",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 4, inPosition ? str.tostring(strategy.position_avg_price * (1.0 + tpPct / 100.0), "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 5, rsiTF + " RSI(" + str.tostring(rsiLen) + ")", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 5, str.tostring(rsiVal, "#.#"), text_color = condRSI ? color.green : color.white, bgcolor = bg)
    table.cell(tbl, 0, 6, "Entry Armed",    text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 6, entrySignal ? "YES" : "no", text_color = entrySignal ? color.green : color.gray, bgcolor = bg)
    table.cell(tbl, 0, 7, "Max Deployed",   text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 7, "$" + str.tostring(baseOrderSize + ao1Size + ao2Size + ao3Size + ao4Size + ao5Size, "#"), text_color = color.white, bgcolor = bg)

// ─────────────────────────────────────────────────────────────────────────────
// BRAND WATERMARK
// ─────────────────────────────────────────────────────────────────────────────
var table wm = na
if showWM and barstate.islast
    if na(wm)
        wm := table.new(f_pos(wmPosStr), 1, 1, bgcolor = color.new(color.black, 100), border_width = 0)
    table.cell(wm, 0, 0, wmText, text_color = color.new(color.white, wmAlpha), text_size = f_size(wmSizeStr), bgcolor = color.new(color.black, 100))
````
