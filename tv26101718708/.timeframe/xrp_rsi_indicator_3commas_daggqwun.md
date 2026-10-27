# XRP RSI Indicator [3Commas]

- url: https://www.tradingview.com/script/DAggqwUn-XRP-RSI-Indicator-3Commas/
- type: indicator
- pine_id: PUB;1b0dfb89f7c94f1e9a63eda29852185d
- version: 1.0

## Description

XRP RSI Indicator [3Commas]

🔷 What it does:
This is a signal-only indicator that mirrors a long-only DCA workflow on XRP / USDT. It tracks a single virtual position: a base entry opens when 4h RSI(14) drops below 28; if price keeps falling, five averaging orders add to the virtual position at fixed deviations from the base entry, each larger than the last; the position is then closed at a fixed take-profit above the blended average entry. The indicator computes running average entry, deployed capital, open PnL, and lifetime realized PnL from honest fill-by-fill bookkeeping, and emits a webhook-ready JSON alert payload on the base order, every safety order, and the close.
  - Single entry filter: 4h RSI(14) below 28 (deep oversold).
  - Five averaging orders at fixed deviations (−2%, −5%, −9.5%, −16%, −25%) with 1.8× size scaling per rung.
  - Fixed take-profit on the blended average entry; no trailing, no stop loss.
  - Honest virtual bookkeeping: avg entry, deployed capital, Open PnL, and cumulative realized PnL displayed live on the chart.

🔷 Who is it for:
  - Swing traders accumulating XRP on deep RSI flushes who want a chart-driven signal source.
  - Bot operators who want base / safety-order / close webhook JSON ready to drive a DCA Bot.
  - Traders comfortable with martingale-style averaging who size their capital to the worst-case ladder fill.
  - Traders who want strategy-tester-equivalent insight (live realized / unrealized PnL) without running a backtest engine.

🔷 How does it work:
  Base Entry: On each closed 4h bar the indicator reads RSI(14). When RSI falls below 28 and there is no open virtual position, it marks a virtual base order at the close price and dispatches the entry webhook.
  Averaging Orders: Once in a virtual position, the indicator watches price relative to the original base entry. The five safety orders are armed at fixed deviations from that base entry — not cumulatively — at −2%, −5%, −9.5%, −16%, and −25%. As each threshold is crossed on bar close, the corresponding safety order is recorded and its webhook fires. Order sizes scale 1.8× per rung ($900 → $1,620 → $2,916 → $5,249 → $9,448 from a $500 base), pulling the blended average entry down toward the latest fill.
  Honest Virtual Bookkeeping: Total cost and qty are updated incrementally on every event, so the avg entry, deployed capital, and Open PnL displayed in the status table reflect the actual broker-equivalent position state — no shortcut, no synthetic averaging.
  Take Profit & Lifetime PnL: When price closes at or above the take-profit level (a fixed percentage above the average entry), the virtual position is closed, its round-trip profit is added to a persistent realized-PnL counter, and the close webhook fires. The status table displays both Open PnL (current unrealized state) and cumulative realized PnL, so live performance is visible directly on the chart.
  Capital Bounds: Total virtual deployed capital cannot exceed the base order plus the five safety orders. Once all five are filled, no further adds occur — the position simply waits for the take-profit.

🔷 Why it's unique:
  - Deep-Oversold-Only Entries: A single, strict RSI(14) < 28 filter on 4h keeps the signal quiet in normal conditions and only fires after a meaningful flush.
  - Fixed-Deviation Martingale Ladder: Safety orders are placed at fixed percentages from the base entry with deliberate 1.8× size scaling — a transparent, fully-specified averaging schedule rather than an opaque adaptive grid.
  - Full Webhook Chain: Base order, each safety order, and the close all emit dedicated JSON payloads. One TradingView alert with "Any alert() function call" drives a 3Commas DCA Bot end-to-end.
  - Live PnL Tracking: Open PnL and cumulative realized PnL are displayed live on the chart — the indicator gives strategy-tester-equivalent insight without running a backtest.

🔷 Considerations Before Using the Indicator:
  Martingale Tail Risk: Order sizes scale 1.8× per rung, so the deepest fills are by far the largest. If XRP trends hard below the −25% AO5 level without recovering to take-profit, the virtual position sits fully loaded with no further adds and no stop — Open PnL can grow deeply negative until price reverts.
  No Stop Loss: There is no exit signal on adverse moves. Risk is bounded only by the fixed ladder allocation (base + five AOs ≈ $20,633 at default sizing). If a hard exchange-side stop is required, configure it on the bot directly.
  Match Sizing to Your Bot: The avg-entry and PnL display becomes meaningful only when the indicator's base/AO sizing matches your real DCA Bot configuration.
  Cross Detection Granularity: Base, safety-order, and take-profit events are evaluated on bar close. A bar that spikes through a level and returns within the same bar may be missed by design — this matches realistic polling behavior and avoids over-signaling on intra-bar wicks.
  Live vs Historical State: The virtual position is rebuilt from chart history each time the indicator is recompiled. If the indicator is added mid-deployment or the live bot diverges from the signal stream (manual interventions, partial fills), the indicator state may not match the live bot. Toggle the indicator off and on to reset.
  Backtesting Note: This is an indicator, not a strategy. There is no built-in P&L tester — but the live realized-PnL counter in the status table gives a running approximation. For full metrics over the reference ~30-month sample (75 closed trades, 76.00% win rate, 1.00% max drawdown, profit factor 13.058, +3.45% net return over January 1, 2024 – June 29, 2026), use the companion strategy version on identical parameters. Note the 75-trade sample is below the ~100-trade floor for statistical confidence — treat those metrics, including the high profit factor, as indicative.

🔷 How to Use It:
  🔸 Add the indicator to a 4h XRP / USDT chart.
  🔸 Confirm the RSI level (28), the five AO deviations and sizes, and the take-profit percentage match your bot's configuration. Match the base/AO sizing so the avg-entry and PnL display stays meaningful.
  🔸 In the DCA Bot Webhook group, paste the Bot ID, Email Token, and Pair (QUOTE_BASE format, e.g., USDT_XRP).
  🔸 Create an alert on the indicator with "Any alert() function call". Paste the DCA Bot's webhook URL into the alert's Webhook field. The base order, each safety order, and the close will each emit a dedicated JSON payload formatted for direct DCA Bot consumption.

🔷 INDICATOR SETTINGS
  Base Order Size: Virtual capital committed on the first (base) entry.
  AO Deviations: Fixed percentage distances from the base entry where each safety order fires.
  AO Sizes: Virtual capital per safety order (1.8× scaling by default).
  RSI Timeframe / Length / Level: Oversold filter for the base entry (default 4h, 14, below 28).
  Take Profit (%): Distance above average entry where the full position closes.
  DCA Bot Webhook: Bot ID, Email Token, and Pair fields injected into every alert payload.
  Visualization: Toggle the AO ladder, fill labels, avg/TP lines, and status table (shows status, AOs filled, base/avg entry, TP target, deployed capital, open PnL, RSI, and cumulative realized PnL).
  Brand Watermark: Configurable text, position, size, and transparency.

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.

__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
// =============================================================================
//  XRP RSI Long Indicator (signal-only companion)
//  Mirrors "XRP RSI Long Strategy" 1:1 as a virtual position state machine:
//    • Base entry when 4h RSI(14) < 28 (deep oversold)
//    • Five averaging orders at FIXED deviations from base entry
//      (−2%, −5%, −9.5%, −16%, −25%) with 1.8x size scaling
//      ($900 → $1,620 → $2,916 → $5,249 → $9,448 from a $500 base)
//    • Fixed Take Profit on blended avg entry, no trailing, no stop loss
//  No backtest engine — virtual bookkeeping (avg entry, deployed capital,
//  open PnL, lifetime realized PnL) + webhook JSON for a 3Commas DCA Bot.
//  Defaults calibrated for BYBIT:XRPUSDT.P on 4h.
// =============================================================================
//@version=6
indicator("XRP RSI Indicator [3Commas]", shorttitle = "XRP RSI-I [3Commas]", overlay = true, max_labels_count = 500, max_lines_count = 100)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grpBase = "Base Order"
baseOrderSize = input.float(500.0, "Base Order Size (USDT)", minval = 1, group = grpBase, tooltip = "Virtual base order. Total max position with all 5 AOs filled ≈ $20,633 (1.8x scaling martingale). Match to your DCA Bot config so the avg-entry and PnL display stay honest.")

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

grpHook = "DCA Bot Webhook"
botId       = input.string("YOUR_BOT_ID",      "Bot ID",            group = grpHook)
emailToken  = input.string("YOUR_EMAIL_TOKEN", "Email Token",       group = grpHook)
pairWebhook = input.string("USDT_XRP",         "Pair (QUOTE_BASE)", group = grpHook)

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

// AO arrays — fixed deviations and sizes
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
// VIRTUAL POSITION STATE
// ─────────────────────────────────────────────────────────────────────────────
var float baseEntry   = na      // base order price
var float totalCost   = 0.0     // sum of USDT deployed
var float totalQty    = 0.0     // sum of base units held
var int   aoFilled    = 0       // AOs filled so far
var float realizedPnl = 0.0     // lifetime realized profit (USDT)

inPosition = totalQty > 0
avgEntry   = inPosition ? totalCost / totalQty : na
tpPrice    = inPosition ? avgEntry * (1.0 + tpPct / 100.0) : na
openPnl    = inPosition ? (close - avgEntry) * totalQty : 0.0

// ── 1. BASE ENTRY (RSI < 28 on 4h) ───────────────────────────────────────────
openBase = not inPosition and entrySignal
if openBase
    qty        = baseOrderSize / close
    totalCost := baseOrderSize
    totalQty  := qty
    baseEntry := close
    aoFilled  := 0
    alert(f_msgEntry(), alert.freq_once_per_bar_close)

// ── 2. AVERAGING ORDERS — fixed deviations from BASE entry ────────────────────
fillAO = false
if inPosition and aoFilled < aoCount and not na(baseEntry)
    nextIdx   = aoFilled + 1
    threshold = array.get(aoDevs, nextIdx - 1)
    triggerPx = baseEntry * (1.0 - threshold / 100.0)
    if close <= triggerPx
        aoUsdt     = array.get(aoSizes, nextIdx - 1)
        totalCost := totalCost + aoUsdt
        totalQty  := totalQty + aoUsdt / close
        aoFilled  := nextIdx
        fillAO    := true
        alert(f_msgAddAO(), alert.freq_once_per_bar_close)

// ── 3. EXIT — Fixed Take Profit (no trailing, no SL) ─────────────────────────
closeTP = false
if inPosition and close >= tpPrice
    realizedPnl := realizedPnl + (close - avgEntry) * totalQty
    totalCost   := 0.0
    totalQty    := 0.0
    baseEntry   := na
    aoFilled    := 0
    closeTP     := true
    alert(f_msgClose(), alert.freq_once_per_bar_close)

// ─────────────────────────────────────────────────────────────────────────────
// VISUALIZATION
// ─────────────────────────────────────────────────────────────────────────────
plot(showLines and inPosition ? avgEntry : na, title = "Avg Entry", color = color.new(color.orange, 0), linewidth = 2, style = plot.style_linebr)
plot(showLines and inPosition ? tpPrice : na, title = "TP", color = color.new(color.green, 0), linewidth = 1, style = plot.style_linebr)

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
if showLabels and fillAO
    label.new(bar_index, low, "AO" + str.tostring(aoFilled) + " ▲", style = label.style_label_up, color = color.new(color.teal, 20), textcolor = color.white, size = size.tiny)
if showLabels and closeTP
    label.new(bar_index, high, "TP ▼", style = label.style_label_down, color = color.new(color.green, 0), textcolor = color.white, size = size.tiny)

if showTable and barstate.islast
    var table tbl = table.new(position = position.top_right, columns = 2, rows = 9, border_width = 1)
    bg  = color.new(color.gray, 30)
    bgH = color.new(color.gray, 0)
    table.cell(tbl, 0, 0, "Status",         text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 1, 0, inPosition ? "In Long" : "Flat", text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 0, 1, "AOs Filled",     text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 1, str.tostring(aoFilled) + " / " + str.tostring(aoCount), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 2, "Base Entry",     text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 2, na(baseEntry) ? "—" : str.tostring(baseEntry, "#.####"), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 3, "Avg Entry",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 3, inPosition ? str.tostring(avgEntry, "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 4, "TP Target",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 4, inPosition ? str.tostring(tpPrice, "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 5, "Deployed",       text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 5, inPosition ? "$" + str.tostring(totalCost, "#") : "$0", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 6, "Open PnL",       text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 6, inPosition ? str.tostring(openPnl, "#.#") + " USDT" : "—", text_color = openPnl >= 0 ? color.green : color.red, bgcolor = bg)
    table.cell(tbl, 0, 7, rsiTF + " RSI(" + str.tostring(rsiLen) + ")", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 7, str.tostring(rsiVal, "#.#"), text_color = condRSI ? color.green : color.white, bgcolor = bg)
    table.cell(tbl, 0, 8, "Realized PnL",   text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 8, str.tostring(realizedPnl, "#.#") + " USDT", text_color = realizedPnl >= 0 ? color.green : color.red, bgcolor = bg)

// ─────────────────────────────────────────────────────────────────────────────
// BRAND WATERMARK
// ─────────────────────────────────────────────────────────────────────────────
var table wm = na
if showWM and barstate.islast
    if na(wm)
        wm := table.new(f_pos(wmPosStr), 1, 1, bgcolor = color.new(color.black, 100), border_width = 0)
    table.cell(wm, 0, 0, wmText, text_color = color.new(color.white, wmAlpha), text_size = f_size(wmSizeStr), bgcolor = color.new(color.black, 100))
````
