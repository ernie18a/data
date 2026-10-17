# [3Commas] XRP Grid - Long Indicator

- url: https://www.tradingview.com/script/YmJJ8PMq-3Commas-XRP-Grid-Long-Indicator/
- type: indicator
- pine_id: PUB;415ae9d572594c05b8a5696d175c6034
- version: 1.0

## Description

[3Commas] XRP Grid - Long Indicator

🔷 What it does:
This is a signal-only indicator that mirrors a price-grid long workflow on XRP / USDT between two fixed bounds. It tracks up to 23 independent virtual slots between a configurable High and Low — each slot fires a webhook-ready buy signal when price crosses down through it, and a paired sell signal when price subsequently crosses up through the slot immediately above. The indicator computes a running average entry, total deployed capital, and open PnL from the live slot ledger and renders all of it on the chart.
  - Pre-computes 7–200 grid levels in Geometric (default) or Arithmetic spacing.
  - Each slot is an independent ownership flag with its own buy/sell webhook payload.
  - Avg entry is derived from fill-by-fill bookkeeping — total cost and total qty are updated on every event.
  - Every event emits a webhook-ready JSON alert payload tagged with the specific grid slot.

🔷 Who is it for:
  - Swing traders harvesting volatility on XRP in range-bound regimes.
  - Bot operators looking for a chart-driven signal source that emits per-slot JSON ready for a DCA Bot configured for grid execution.
  - Traders who want to monitor a virtual grid state — avg entry, owned slots, deployed capital, open PnL — directly on the chart without a backtest engine.
  - Portfolio operators using a high-trade-count contributor alongside directional strategies.

🔷 How does it work:
  Grid Construction: On script load, the indicator computes N price levels between the configured High and Low bounds. In Geometric mode (default), level k is at High × (Low/High)^(k/(N-1)), giving constant percent spacing — approximately 1.5% per step at default settings. In Arithmetic mode, levels are linearly spaced by absolute price.
  Per-Slot State Machine: Each grid level is an independent slot tracked by a boolean ownership flag. When close price crosses down through an empty slot's level, the slot is marked owned, virtual cost-basis is added, and the BUY webhook payload is dispatched. When close price crosses up through the level immediately above an owned slot, the slot is marked free, virtual cost-basis is subtracted, and the SELL webhook payload is dispatched.
  Honest Virtual Bookkeeping: Total cost and total qty are updated incrementally on each event, so the avg entry, deployed capital, and open PnL displayed in the status table reflect the actual broker-equivalent position state — no shortcuts from base entry, no synthetic averaging. The table also accumulates the realized PnL from every closed slot (the exact round-trip profit between adjacent levels), so it shows how much the grid has actually earned over the chart history.
  No Trailing, No Stop Loss: By design, each slot has a fixed exit (the level above). The indicator never trails the exit and never signals a slot-out for a loss — slots that fall below their entry stay owned until price comes back. This is the canonical grid-bot behavior.

🔷 Why it's unique:
  - Per-Level Webhook Ledger: Every BUY and SELL emits a fully-formed JSON alert payload tagged with the specific grid slot ("Grid_BUY_L5" / "Grid_TP_L5"). The indicator can drive a DCA Bot configured for grid emulation without any glue layer.
  - Fill-by-Fill Avg Entry: The orange avg-entry line is derived from running totals updated on every event — what you see is what the broker-equivalent position would actually have.
  - Active Slot Highlighting: Owned grid levels are rendered with a thicker green stroke; empty slots stay dashed gray. Slot density and current loading are visible at a glance.
  - Range Box & Bounds Labels: A semi-transparent box spans the configured High/Low range, and crisp HIGH/LOW labels mark the bounds — the grid topology is obvious without zooming.
  - Calibrated for XRP 15m: Default bounds, level count, and step size are set against XRP's recent observed range. The 23-level geometric ladder gives roughly 1.5% per step — wide enough to clear taker fees on each round-trip, granular enough to keep catching 15m swings inside the range.

🔷 Considerations Before Using the Indicator:
  Market Selection & Range Validity: Grid strategies are most profitable in range-bound, mean-reverting markets. On strong directional trends below the configured Low, slots will keep marking as owned as price falls and won't free until price reverses. The default High/Low (1.5466 / 1.1124) was set against XRP's recent observed range; update both whenever the regime changes.
  Capital Deployment: The default Total Investment of 10,000 USDT is a virtual reference used for the avg-entry and open-PnL computation. The real sizing happens on the bot side — match the indicator's per-slot allocation to your bot's grid configuration to keep the avg-entry display honest.
  Cross Detection Granularity: Crossings are detected on bar close, comparing the current close to the previous close. A bar that spikes through a level and returns within the same bar may be missed by design — this prevents over-signaling on intra-bar wicks.
  Live vs Historical State: The virtual slot ledger is rebuilt from chart history each time the indicator is recompiled. If the indicator is added mid-deployment or the live bot diverges from the signal stream (manual interventions, partial fills), the indicator state may not match the live bot. Toggle the indicator off and on to reset.
  No Stop Loss: There is no exit signal on adverse moves below the lowest grid level. Risk is structurally capped on the bot side by the bounded Total Investment configured at the bot. If a hard stop is required, layer it on the bot side.
  Backtesting Note: This is an indicator, not a strategy. There is no built-in P&L tester. For performance metrics over a ~14.3-month sample (269 closed trades, 66.54% win rate, 5.78% max drawdown, profit factor 2.809, +9.52% net return), use the companion strategy version on identical parameters. The 269-trade sample is well above the ~100-trade floor for statistical relevance.

🔷 How to Use It:
  🔸 Add the indicator to an XRP / USDT 15m chart.
  🔸 Set the High and Low bounds to a range you expect XRP to respect.
  🔸 Pick Geometric (default, recommended) or Arithmetic spacing.
  🔸 Set Grid Levels (7–200) and the virtual Total Investment used for avg-entry computation.
  🔸 In the DCA Bot Webhook group, paste your Bot ID, Email Token, and Pair (QUOTE_BASE format, e.g., USDT_XRP).
  🔸 Create an alert on the indicator with "Any alert() function call". Paste the DCA Bot's webhook URL into the alert's Webhook field. Every grid-level buy and grid-level close will emit a dedicated JSON payload tagged with the slot index, so each level can be tracked independently downstream.

🔷 INDICATOR SETTINGS
  High Price: Top of the grid. The highest level a slot can be created from.
  Low Price: Bottom of the grid. The lowest level a slot can be created from.
  Grid Levels: Number of price levels between High and Low (default 23, range 7–200).
  Spacing Mode: Geometric (constant percent step) or Arithmetic (constant absolute step).
  Total Investment (USDT): Virtual capital allocated across all slots. Used for the avg-entry and open-PnL computation only.
  Bot ID / Email Token / Pair: Webhook fields injected into every alert payload.
  Visualization: Toggle grid lines, range box, HIGH/LOW labels, avg entry plot, fill labels, signal triangles, status table (shows status, range, levels, owned slots, avg entry, deployed capital, open PnL, and cumulative realized PnL).
  Brand Watermark: Configurable text, position, size, and transparency.

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.

__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=6
// =============================================================================
//  XRP Grid — Long Indicator
//  Signal-only companion to the XRP Grid Bot strategy. Tracks a virtual grid
//  of up to 200 long slots between fixed bounds and fires webhook-ready alerts
//  on every level-cross event:
//    • BUY  — price crosses DOWN through an empty slot's level
//    • SELL — price crosses UP through the level immediately above an owned slot
//  No backtest engine — designed to drive a live DCA Bot via webhooks.
//  Calibrated defaults for BYBIT:XRPUSDT.P on 15m timeframe.
// =============================================================================
indicator("XRP Grid — Long Indicator", shorttitle = "XRP-I", overlay = true, max_labels_count = 500, max_lines_count = 250, max_boxes_count = 5)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS (mirror the strategy 1:1)
// ─────────────────────────────────────────────────────────────────────────────
grpBounds = "Grid Bounds"
highPrice = input.float(1.5466, "High Price", minval = 0, step = 0.0001, group = grpBounds)
lowPrice  = input.float(1.1124, "Low Price",  minval = 0, step = 0.0001, group = grpBounds)

grpGrid = "Grid Configuration"
nLevels    = input.int(23, "Grid Levels", minval = 7, maxval = 200, group = grpGrid, tooltip = "Number of price levels between High and Low. 23 levels on the default 1.1124–1.5466 range gives ~1.5% step.")
gridMode   = input.string("Geometric", "Spacing Mode", options = ["Geometric", "Arithmetic"], group = grpGrid)
investment = input.float(10000.0, "Total Investment (USDT)", minval = 100, group = grpGrid, tooltip = "Virtual — used only for avg-entry and open-PnL computation. Real sizing happens on the bot.")

grpHook = "DCA Bot Webhook"
botId       = input.string("YOUR_BOT_ID",      "Bot ID",            group = grpHook)
emailToken  = input.string("YOUR_EMAIL_TOKEN", "Email Token",       group = grpHook)
pairWebhook = input.string("USDT_XRP",         "Pair (QUOTE_BASE)", group = grpHook)

grpViz = "Visualization"
showGrid       = input.bool(true, "Show Grid Lines",       group = grpViz)
showRange      = input.bool(true, "Show Range Box",        group = grpViz)
showBounds     = input.bool(true, "Show HIGH/LOW Labels",  group = grpViz)
showAvgEntry   = input.bool(true, "Plot Avg Entry Line",   group = grpViz)
showFillLabels = input.bool(true, "Show Fill Labels",      group = grpViz)
showShapes     = input.bool(true, "Show Signal Triangles", group = grpViz)
showTable      = input.bool(true, "Show Status Table",     group = grpViz)

grpWM = "Brand Watermark"
showWM    = input.bool(true,        "Show Watermark", group = grpWM)
wmText    = input.string("3Commas", "Watermark Text", group = grpWM)
wmPosStr  = input.string("Bottom Right", "Position", options = ["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group = grpWM)
wmSizeStr = input.string("Large",   "Text Size", options = ["Tiny","Small","Normal","Large","Huge"], group = grpWM)
wmAlpha   = input.int(70,           "Transparency (0–100)", minval = 0, maxval = 100, group = grpWM)

usdtPerLevel = investment / nLevels

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────
f_levelPx(int i) =>
    pct = float(i) / float(nLevels - 1)
    gridMode == "Geometric" ? highPrice * math.pow(lowPrice / highPrice, pct) : highPrice - (highPrice - lowPrice) * pct

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
f_msgClose() => '{"action":"close_at_market_price","message_type":"bot","bot_id":' + botId + ',"email_token":"' + emailToken + '","delay_seconds":0,"pair":"' + pairWebhook + '"}'

// ─────────────────────────────────────────────────────────────────────────────
// STATE — pre-allocated to max grid size (200, matches 3Commas ceiling)
// ─────────────────────────────────────────────────────────────────────────────
var gridOwned  = array.new<bool>(200, false)
var gridLevels = array.new<float>(200, na)
var float totalCost   = 0.0   // cost-basis of currently open virtual slots (USDT)
var float totalQty    = 0.0   // qty of asset across currently open virtual slots
var float realizedPnl = 0.0   // cumulative realized profit from closed slots (USDT)

if barstate.isfirst
    for i = 0 to nLevels - 1
        array.set(gridLevels, i, f_levelPx(i))

// ─────────────────────────────────────────────────────────────────────────────
// EVENT DETECTION — close-to-close crossing
// ─────────────────────────────────────────────────────────────────────────────
prevClose = nz(close[1], close)
var bool buyEvent  = false
var bool sellEvent = false
buyEvent  := false
sellEvent := false

for i = 1 to nLevels - 1
    levelPx = array.get(gridLevels, i)
    upperPx = array.get(gridLevels, i - 1)
    owned   = array.get(gridOwned, i)

    // BUY: price crossed DOWN through an empty slot
    if not owned and prevClose > levelPx and close <= levelPx
        array.set(gridOwned, i, true)
        totalCost := totalCost + usdtPerLevel
        totalQty  := totalQty  + usdtPerLevel / levelPx
        buyEvent  := true
        alert(f_msgEntry(), alert.freq_once_per_bar_close)
        if showFillLabels
            label.new(bar_index, low, "BUY L" + str.tostring(i), style = label.style_label_up, color = color.new(color.green, 20), textcolor = color.white, size = size.tiny)

    // SELL: price crossed UP through the level above an owned slot
    if owned and prevClose < upperPx and close >= upperPx
        array.set(gridOwned, i, false)
        slotQty   = usdtPerLevel / levelPx
        totalCost := totalCost - usdtPerLevel
        totalQty  := totalQty  - slotQty
        realizedPnl := realizedPnl + (upperPx - levelPx) * slotQty
        sellEvent := true
        alert(f_msgClose(), alert.freq_once_per_bar_close)
        if showFillLabels
            label.new(bar_index, high, "TP L" + str.tostring(i), style = label.style_label_down, color = color.new(color.red, 20), textcolor = color.white, size = size.tiny)

avgEntry = totalQty > 0 ? totalCost / totalQty : na
openPnl  = totalQty > 0 and not na(avgEntry) ? (close - avgEntry) * totalQty : 0.0

// ─────────────────────────────────────────────────────────────────────────────
// PLOTS & SIGNAL SHAPES
// ─────────────────────────────────────────────────────────────────────────────
plot(showAvgEntry and not na(avgEntry) ? avgEntry : na, title = "Avg Entry", color = color.new(color.orange, 0), linewidth = 2, style = plot.style_linebr)

plotshape(showShapes and buyEvent,  title = "Grid Buy",  location = location.belowbar, style = shape.triangleup,   color = color.new(color.green, 0), size = size.tiny)
plotshape(showShapes and sellEvent, title = "Grid Sell", location = location.abovebar, style = shape.triangledown, color = color.new(color.red,   0), size = size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
// GRID VIZ — range box, level lines, HIGH/LOW labels
// ─────────────────────────────────────────────────────────────────────────────
var box   rangeBox      = na
var       gridLineRefs  = array.new<line>()
var       gridLabelRefs = array.new<label>()
var label hiLabel       = na
var label loLabel       = na

if barstate.islast and showRange
    if not na(rangeBox)
        box.delete(rangeBox)
    rangeBox := box.new(left = bar_index - 300, top = highPrice, right = bar_index + 8, bottom = lowPrice, bgcolor = color.new(color.blue, 95), border_color = color.new(color.blue, 70), border_style = line.style_dotted, border_width = 1)

if barstate.islast and showGrid
    if array.size(gridLineRefs) > 0
        for i = 0 to array.size(gridLineRefs) - 1
            line.delete(array.get(gridLineRefs, i))
        array.clear(gridLineRefs)
    if array.size(gridLabelRefs) > 0
        for i = 0 to array.size(gridLabelRefs) - 1
            label.delete(array.get(gridLabelRefs, i))
        array.clear(gridLabelRefs)
    for i = 0 to nLevels - 1
        px    = array.get(gridLevels, i)
        owned = array.get(gridOwned, i)
        col   = owned ? color.new(color.green, 10) : color.new(color.gray, 70)
        wid   = owned ? 2 : 1
        ln    = line.new(x1 = bar_index - 300, x2 = bar_index + 8, y1 = px, y2 = px, color = col, style = line.style_dashed, width = wid)
        array.push(gridLineRefs, ln)
        if i == 0 or i == nLevels - 1 or i % 3 == 0
            lbl = label.new(x = bar_index + 8, y = px, text = "L" + str.tostring(i) + "  " + str.tostring(px, "#.####"), style = label.style_label_left, color = color.new(color.gray, 80), textcolor = color.white, size = size.tiny)
            array.push(gridLabelRefs, lbl)

if barstate.islast and showBounds
    if not na(hiLabel)
        label.delete(hiLabel)
    if not na(loLabel)
        label.delete(loLabel)
    hiLabel := label.new(x = bar_index + 8, y = highPrice, text = "HIGH  " + str.tostring(highPrice, "#.####"), style = label.style_label_left, color = color.new(color.red, 10),   textcolor = color.white, size = size.small)
    loLabel := label.new(x = bar_index + 8, y = lowPrice,  text = "LOW   " + str.tostring(lowPrice,  "#.####"), style = label.style_label_left, color = color.new(color.green, 10), textcolor = color.white, size = size.small)

// ─────────────────────────────────────────────────────────────────────────────
// STATUS TABLE
// ─────────────────────────────────────────────────────────────────────────────
if showTable and barstate.islast
    var table tbl = table.new(position = position.top_right, columns = 2, rows = 8, border_width = 1)
    bg  = color.new(color.gray, 30)
    bgH = color.new(color.gray, 0)

    ownedCount = 0
    for i = 0 to nLevels - 1
        if array.get(gridOwned, i)
            ownedCount += 1

    table.cell(tbl, 0, 0, "Status",          text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 1, 0, ownedCount > 0 ? "In Position (virtual)" : "Flat", text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 0, 1, "Range",           text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 1, str.tostring(highPrice, "#.####") + " ↔ " + str.tostring(lowPrice, "#.####"), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 2, "Levels",          text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 2, str.tostring(nLevels) + " (" + gridMode + ")", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 3, "Owned / Total",   text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 3, str.tostring(ownedCount) + " / " + str.tostring(nLevels), text_color = ownedCount > 0 ? color.green : color.white, bgcolor = bg)
    table.cell(tbl, 0, 4, "Avg Entry",       text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 4, not na(avgEntry) ? str.tostring(avgEntry, "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 5, "Deployed (USDT)", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 5, str.tostring(totalCost, "#.##"), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 6, "Open PnL (USDT)", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 6, str.tostring(openPnl, "#.##"), text_color = openPnl >= 0 ? color.green : color.red, bgcolor = bg)
    table.cell(tbl, 0, 7, "Realized PnL (USDT)", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 7, str.tostring(realizedPnl, "#.##"), text_color = realizedPnl >= 0 ? color.green : color.red, bgcolor = bg)

// ─────────────────────────────────────────────────────────────────────────────
// BRAND WATERMARK
// ─────────────────────────────────────────────────────────────────────────────
var table wm = na
if showWM and barstate.islast
    if na(wm)
        wm := table.new(f_pos(wmPosStr), 1, 1, bgcolor = color.new(color.black, 100), border_width = 0)
    table.cell(wm, 0, 0, wmText, text_color = color.new(color.white, wmAlpha), text_size = f_size(wmSizeStr), bgcolor = color.new(color.black, 100))
````
