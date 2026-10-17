# FIL Grid Indicator [3Commas]

- url: https://www.tradingview.com/script/JwsU60EP-FIL-Grid-Indicator-3Commas/
- type: indicator
- pine_id: PUB;ef79dfa86f4e48c8a19cab834971c7dd
- version: 1.0

## Description

FIL Grid Indicator [3Commas]

🔷 What it does:
This is a signal-only indicator that mirrors a FIL / USDT price-grid workflow on a pre-defined ladder of levels between two fixed bounds. It tracks one virtual grid position at a time: when price crosses down through a level, the indicator opens one slot; when price subsequently crosses up through the level immediately above an owned slot, that slot is closed for a fixed round-trip profit. The grid is generated geometrically by default, so spacing adapts to the price scale. The indicator computes running average entry, deployed capital, open PnL, and lifetime realized PnL — all derived from honest fill-by-fill bookkeeping. Every fill and close emits a webhook-ready JSON alert payload tagged with the specific grid slot for direct DCA Bot consumption.
  - Up to 36 simultaneous virtual long slots at default settings, each sized as a fixed fraction of the configured Total Investment.
  - Geometric ladder with ~1.0% per step across the default 1.0151 / 0.7099 range (−30.07%).
  - No trailing exit, no stop loss — each slot's exit is the level immediately above its entry.
  - Per-slot reference exposure ~2.78% of equity at default settings.
  - Honest virtual bookkeeping: avg entry, deployed capital, Open PnL, and cumulative realized net profit displayed live on the chart.

🔷 Who is it for:
  - Swing traders harvesting volatility on FIL in range-bound regimes who want a chart-driven signal source.
  - Bot operators looking for per-slot webhook JSON ready to drive a DCA Bot configured for grid execution.
  - Range traders who prefer mechanical, level-based execution over discretionary entries.
  - Traders who want strategy-tester-equivalent insight (live realized/unrealized PnL) without running a backtest engine.

🔷 How does it work:
  Grid Construction: On script load, the indicator computes N price levels between the configured High and Low bounds. In Geometric mode (default), level k is at High × (Low/High)^(k/(N-1)), giving constant percent spacing — approximately 1.0% per step at default settings. In Arithmetic mode, levels are linearly spaced by absolute price.
  Per-Slot Logic: Each grid level is an independent slot tracked by a boolean ownership flag. When bar close moves price down through an empty slot's level, the indicator marks a virtual long opened at that level for one slot's worth of capital (Investment / N) and dispatches its buy webhook. When bar close moves price up through the level immediately above an owned slot, that slot is closed, the round-trip profit between the two adjacent levels is realized, and the close webhook fires.
  Honest Virtual Bookkeeping: Total cost and qty are updated incrementally on every event, so the avg entry, deployed capital, Open PnL, and realized net profit displayed in the status table reflect the actual broker-equivalent position state — no shortcut, no synthetic averaging.
  Lifetime Realized PnL: Each closed slot accumulates its round-trip profit into a persistent counter. The status table displays both Open PnL (current unrealized state) and cumulative realized net profit (how much the grid has actually earned, in USDT and % of starting capital), so live performance is visible directly on the chart.
  Capital Bounds: Total virtual deployed capital cannot exceed the configured Investment. When all 36 slots are filled, no new slots open until price rises and starts closing slots. This structural cap is the indicator's primary risk control.

🔷 Why it's unique:
  - Per-Level Webhook Ledger: Every fill and close emits a fully-formed JSON alert payload tagged with the specific grid slot ("Grid_BUY_L5" / "Grid_TP_L5"). One TradingView alert with "Any alert() function call" drives a DCA Bot configured for grid emulation end-to-end, with each level tracked independently downstream.
  - Pre-Allocated State: All up to 200 slot ledgers live in fixed-size arrays, so state lookups are constant-time and the chart can render every active slot with no performance overhead.
  - Live PnL Tracking: Open PnL and cumulative realized net profit are displayed live on the chart — the indicator gives strategy-tester-equivalent insight without running a backtest.
  - Calibrated for FIL 15m: Default bounds, level count, and step size are set against FIL's recent observed range. The 36-level geometric ladder gives roughly 1.0% per step — wide enough to clear taker fees on each round-trip, granular enough to keep catching 15m swings inside the range.

🔷 Considerations Before Using the Indicator:
  Market Selection & Range Validity: Grid tools are most profitable in range-bound, mean-reverting markets. On strong directional trends below the configured Low, slots will keep loading as price falls and won't close until price reverses. The default High/Low (1.0151 / 0.7099) was set against FIL's recent observed range; update both whenever the regime changes.
  Aggregate Drawdown: Per-slot reference risk is moderate (~2.78% of equity), but if price collapses below the Low bound, aggregate unrealized loss can grow further — the companion strategy's backtest reached a 15.13% maximum equity drawdown. Match the indicator's per-slot allocation and Investment to your bot's configuration to keep the avg-entry and PnL display honest.
  No Stop Loss: There is no exit signal on adverse moves below the lowest grid level. Slots whose entry sits above current market simply wait until price comes back. Risk is structurally capped by the bounded per-slot allocation; if a hard exchange-side stop is required, configure it on the bot directly.
  Cross Detection Granularity: Slot fills and closes are evaluated on bar close. A bar that spikes through a level and returns within the same bar may be missed by design — this matches realistic polling behavior and avoids over-signaling on intra-bar wicks.
  Live vs Historical State: The virtual grid state is rebuilt from chart history each time the indicator is recompiled. If the indicator is added mid-deployment or the live bot diverges from the signal stream (manual interventions, partial fills), the indicator state may not match the live bot. Toggle the indicator off and on to reset.
  Backtesting Note: This is an indicator, not a strategy. There is no built-in P&L tester — but the live realized-profit counter in the status table gives a running approximation. For full metrics over the reference ~13.8-month sample (1,294 closed trades, 57.96% win rate, 15.13% max drawdown, profit factor 1.434, +16.24% net return over May 1, 2025 – June 26, 2026), use the companion strategy version on identical parameters.

🔷 How to Use It:
  🔸 Add the indicator to a 15m FIL / USDT chart.
  🔸 Set the High and Low bounds to a range you expect FIL to respect, pick Geometric (default, recommended) or Arithmetic spacing, and set Grid Levels (7–200) and Total Investment to match your bot's configuration (the indicator's avg-entry and PnL display becomes meaningful when virtual sizing matches real sizing).
  🔸 In the DCA Bot Webhook group, paste the Bot ID, Email Token, and Pair (QUOTE_BASE format, e.g., USDT_FIL).
  🔸 Create an alert on the indicator with "Any alert() function call". Paste the DCA Bot's webhook URL into the alert's Webhook field. The indicator will emit a dedicated JSON payload for every grid-level buy and grid-level close, tagged with the slot index — formatted for direct DCA Bot consumption.

🔷 INDICATOR SETTINGS
  High Price: Top of the grid. The highest level a slot can be created from.
  Low Price: Bottom of the grid. The lowest level a slot can be created from.
  Grid Levels: Number of price levels between High and Low (default 36, range 7–200).
  Spacing Mode: Geometric (constant percent step) or Arithmetic (constant absolute step).
  Total Investment (USDT): Total virtual capital allocated across all slots. Per-slot size = Investment / Grid Levels.
  DCA Bot Webhook: Bot ID, Email Token, and Pair fields injected into every alert payload.
  Visualization: Toggle grid lines, range box, HIGH/LOW labels, avg entry plot, fill labels, signal triangles, status table (shows range, levels, owned slots, investment, per-slot size, open PnL, and cumulative realized net profit).
  Brand Watermark: Configurable text, position, size, and transparency.

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.

__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=6
// =============================================================================
//  FIL Grid Long Indicator
//  Signal-only companion to the FIL Grid Long strategy. Tracks a virtual grid
//  of up to 200 long slots between fixed bounds and fires webhook-ready alerts
//  on every level-cross event:
//    • BUY  — price crosses DOWN through an empty slot's level
//    • SELL — price crosses UP through the level immediately above an owned slot
//  No backtest engine — designed to drive a live DCA Bot via webhooks.
//  Calibrated defaults for BYBIT:FILUSDT.P on 15m timeframe.
// =============================================================================
indicator("FIL Grid Indicator [3Commas]", shorttitle = "FIL-I [3Commas]", overlay = true, max_labels_count = 500, max_lines_count = 250, max_boxes_count = 5)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS (mirror the strategy 1:1)
// ─────────────────────────────────────────────────────────────────────────────
grpBounds = "Grid Bounds"
highPrice = input.float(1.0151, "High Price", minval = 0, step = 0.0001, group = grpBounds)
lowPrice  = input.float(0.7099, "Low Price",  minval = 0, step = 0.0001, group = grpBounds)

grpGrid = "Grid Configuration"
nLevels    = input.int(36, "Grid Levels", minval = 7, maxval = 200, group = grpGrid, tooltip = "Number of price levels between High and Low. 36 levels on the default 0.7099–1.0151 range gives ~1.0% step.")
gridMode   = input.string("Geometric", "Spacing Mode", options = ["Geometric", "Arithmetic"], group = grpGrid)
investment = input.float(10000.0, "Total Investment (USDT)", minval = 100, group = grpGrid, tooltip = "Virtual — used only for avg-entry and open-PnL computation. Real sizing happens on the bot.")

grpHook = "DCA Bot Webhook"
botId       = input.string("YOUR_BOT_ID",      "Bot ID",            group = grpHook)
emailToken  = input.string("YOUR_EMAIL_TOKEN", "Email Token",       group = grpHook)
pairWebhook = input.string("USDT_FIL",         "Pair (QUOTE_BASE)", group = grpHook)

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
