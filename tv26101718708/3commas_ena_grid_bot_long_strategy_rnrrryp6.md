# [3Commas] ENA Grid Bot - Long Strategy

- url: https://www.tradingview.com/script/RnrrRYP6-3Commas-ENA-Grid-Bot-Long-Strategy/
- type: strategy
- pine_id: PUB;6b4e5e13251f4e769dfbc2224a0dd8cd
- version: 1.0

## Description

[3Commas] ENA Grid Bot - Long Strategy

🔷 What it does:
This is a long-only price-grid strategy that harvests volatility on ENA / USDT through repeated round-trips on a pre-defined ladder of price levels between two fixed bounds. Each level is an independent slot: when price crosses down through a level, the strategy opens one slot; when price subsequently crosses up through the level immediately above, that slot is closed for a fixed round-trip profit. The grid is generated geometrically by default, so spacing adapts to the price scale.
  - Up to 65 simultaneous long slots at default settings, each sized as a fixed fraction of the configured Total Investment.
  - No trailing exit, no stop loss — each slot's exit is the level above its entry.
  - Per-slot exposure is approximately 1.54% of equity at default settings, comfortably inside the conventional 5–10% per-trade risk band.
  - Every fill and close emits a webhook-ready JSON alert payload tagged with the specific grid slot.

🔷 Who is it for:
  - Swing traders harvesting volatility on ENA in range-bound regimes.
  - Bot operators looking for a chart-driven signal source with per-slot webhook JSON ready to drive a DCA Bot configured for grid execution.
  - Traders running a portfolio of low-correlation strategies who want a high-trade-count contributor with bounded per-trade risk.
  - Range traders who prefer mechanical execution over discretionary entries.

🔷 How does it work:
  Grid Construction: On script load, the strategy computes N price levels between the configured High and Low bounds. In Geometric mode (default), level k is at High × (Low/High)^(k/(N-1)), giving constant percent spacing — approximately 1.0% per step at default settings. In Arithmetic mode, levels are linearly spaced by absolute price.
  Per-Slot Logic: Each grid level is an independent slot tracked by a boolean ownership flag. When bar close moves price down through an empty slot's level, a long is opened at that level for one slot's worth of capital (Investment / N). When bar close moves price up through the level immediately above an owned slot, that slot is closed, locking the round-trip profit between the two adjacent levels.
  No Trailing, No Stop Loss: By design, each slot has a fixed exit (the level above). The strategy never trails the exit and never stops a slot out for a loss — slots whose entry price is below current market simply wait until price comes back. This is the canonical grid-bot behavior.
  Capital Bounds: Total deployed capital cannot exceed the configured Investment. When all 65 slots are filled, no new orders are opened until price rises and starts closing slots. This structural cap is the strategy's primary risk control.

🔷 Why it's unique:
  - Per-Level Webhook Ledger: Every fill and close emits a fully-formed JSON alert payload tagged with the specific grid slot ("Grid_BUY_L5" / "Grid_TP_L5"). The strategy can drive a DCA Bot configured for grid emulation without any glue layer.
  - Pre-Allocated State: All up to 200 slot ledgers live in fixed-size arrays, so state lookups are constant-time and the chart can render every active slot with no performance overhead.
  - Honest Backtest Surface: The avg entry line plotted on the chart and the open PnL displayed in the status table both reflect the actual broker-equivalent position state — derived from fill-by-fill bookkeeping, not synthetic averaging. The status table also reports the cumulative realized net profit (how much the grid has actually earned, in USDT and % of starting capital), so live performance is visible directly on the chart.
  - Calibrated for ENA 15m: Default bounds, level count, and step size are set against ENA's recent observed range. The 65-level geometric ladder gives roughly 1.0% per step — wide enough to clear taker fees on each round-trip, granular enough to keep catching 15m swings inside a broad range.

🔷 Considerations Before Using the Strategy:
  Wide Range & Drawdown (Important): The default range spans nearly 47% (0.132 down to 0.07). A grid this wide loads many slots as price falls toward the Low, which is exactly why the reference backtest shows a sizeable 23.52% maximum equity drawdown. Profit factor of 1.067 is only marginally above breakeven — this configuration grinds out volatility, it is not a high-edge setup. Size the Investment to a drawdown you can stomach, and treat the thin profit factor as a reason to demo-test thoroughly.
  Market Selection & Range Validity: Grid strategies are most profitable in range-bound, mean-reverting markets. On strong directional trends below the configured Low, slots keep loading and won't close until price reverses. The default High/Low (0.132 / 0.07) was set against ENA's recent observed range; update both whenever the regime changes.
  Capital Deployment: The default Investment of 10,000 USDT equals 100% of starting capital. Per-slot risk is low (~1.54% of equity), but with a wide range the aggregate unrealized loss can grow materially before price recovers — as the 23.52% drawdown shows. Scale the Investment input down to manage it.
  No Stop Loss Justification: There is no exit on adverse moves below the lowest grid level. Per-trade risk is structurally capped by the per-slot allocation (Investment / N) — at defaults ~154 USDT per slot, well inside the conventional 5–10% per-trade band. Aggregate exposure is controlled separately via the Investment input.
  Trade Volume & Fees: Grid bots on 15m generate a high number of round-trips — this configuration produced 1,875 closed trades. With a thin profit factor, fees are decisive: the default commission (0.06% per trade) must match your exchange's actual fees, or the edge can flip negative.
  Demo Testing: Always demo-test before going live. Past results do not guarantee future performance, especially on a wide-range, low-profit-factor configuration.

🔷 STRATEGY PROPERTIES
  Symbol: BYBIT:ENAUSDT.P (Perpetual) — strategy is portable to any ENA / USDT pair.
  Timeframe: 15M
  Test Period: January 31, 2026 — June 16, 2026 (~4.5 months).
  Initial Capital: 10,000 USDT.
  Total Investment: 10,000 USDT (100% of capital, high-conviction setting).
  Order Size per Slot: Investment / 65 ≈ 154 USDT (~1.54% of equity).
  Commission: 0.06% per trade.
  Slippage: 3 ticks.
  Margin for Long Positions: 100%.
  Indicator Settings: Default Configuration.
  Grid Bounds: High 0.132 / Low 0.07 (range −46.97%).
  Grid Levels: 65 (Geometric spacing, ~1.0% per step).
  Stop Loss: None — per-slot allocation is the structural risk cap.
  Trailing: None.
  Strategy: Long Only.

🔷 STRATEGY RESULTS
  ⚠️ Remember, past results do not guarantee future performance.
  Net Profit: +1,135.41 USDT (+11.21%)
  Max Equity Drawdown: 2,789.96 USDT (23.52%)
  Total Closed Trades: 1,875
  Percent Profitable: 49.55% (929 / 1,875)
  Profit Factor: 1.067

🔷 How to Use It:
  🔸 Adjust Settings: Open the strategy inputs and set the High and Low bounds to a range you expect ENA to respect. Pick Geometric for percent-spaced levels (default, recommended) or Arithmetic. Set Grid Levels (7–200) and Total Investment to match your risk profile — consider a narrower range to reduce the drawdown seen here.
  🔸 Results Review: Run a full-period backtest and confirm Max Drawdown stays within your personal risk band — note this configuration reached 23.52%. The 1,875 closed trades are well above the ~100-trade floor for statistical relevance, but the 1.067 profit factor leaves little margin once real fees are applied.
  🔸 Create alerts to trigger the DCA Bot: Add one alert on the strategy using "Any alert() function call". Paste your DCA Bot's webhook URL into the alert's Webhook field, and fill the Bot ID, Email Token, and Pair inputs on the script. Every grid-level buy and grid-level close will emit a dedicated JSON payload tagged with the slot index, so each level can be tracked independently downstream.

🔷 INDICATOR SETTINGS
  High Price: Top of the grid. The highest level a slot can be created from.
  Low Price: Bottom of the grid. The lowest level a slot can be created from.
  Grid Levels: Number of price levels between High and Low (default 65, range 7–200).
  Spacing Mode: Geometric (constant percent step) or Arithmetic (constant absolute step).
  Total Investment (USDT): Total capital allocated across all slots. Per-slot size = Investment / Grid Levels.
  Bot ID / Email Token / Pair: Webhook fields injected into every alert payload.
  Visualization: Toggle grid lines, range box, HIGH/LOW labels, avg entry plot, fill labels, status table (shows range, levels, owned slots, investment, per-slot size, open PnL, and cumulative realized net profit).
  Brand Watermark: Configurable text, position, size, and transparency.

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.

__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=6
// =============================================================================
//  ENA Grid Bot — Long Strategy
//  Long-only price-grid strategy operating between fixed high/low bounds with
//  geometric (default) or arithmetic level spacing. Buys on each downward grid
//  crossing, sells on each upward crossing to the level above.
//  NO TRAILING, NO STOP LOSS — by explicit design. Grid bounds and bounded
//  investment act as the structural risk caps.
//  Calibrated defaults for BYBIT:ENAUSDT.P on 15m timeframe.
// =============================================================================
strategy("[3Commas] ENA Grid Bot — Long Strategy", shorttitle = "[3Commas] ENA Grid", overlay = true, initial_capital = 10000, default_qty_type = strategy.cash, default_qty_value = 154, pyramiding = 200, commission_type = strategy.commission.percent, commission_value = 0.06, slippage = 3, process_orders_on_close = true, calc_on_every_tick = false, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 5)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grpBounds = "Grid Bounds"
highPrice = input.float(0.132, "High Price", minval = 0, step = 0.00001, group = grpBounds)
lowPrice  = input.float(0.07,  "Low Price",  minval = 0, step = 0.00001, group = grpBounds)

grpGrid = "Grid Configuration"
nLevels    = input.int(65, "Grid Levels", minval = 7, maxval = 200, group = grpGrid, tooltip = "Number of price levels between High and Low. 65 levels on the default 0.07–0.132 range gives ~1.0% step.")
gridMode   = input.string("Geometric", "Spacing Mode", options = ["Geometric", "Arithmetic"], group = grpGrid)
investment = input.float(10000.0, "Total Investment (USDT)", minval = 100, group = grpGrid, tooltip = "Total capital allocated across all grid slots. Per-slot size = Investment / Grid Levels. Default 10,000 = 100% of capital (high-conviction setting; scale down for lower risk).")

grpDate = "Backtest Window"
useDateFilter = input.bool(true, "Limit Backtest Period", group = grpDate)
fromDate      = input.time(timestamp("31 Jan 2026 00:00 +0000"), "From", group = grpDate)
toDate        = input.time(timestamp("15 Jun 2026 23:59 +0000"), "To",   group = grpDate)

grpHook = "DCA Bot Webhook"
botId       = input.string("YOUR_BOT_ID",      "Bot ID",            group = grpHook)
emailToken  = input.string("YOUR_EMAIL_TOKEN", "Email Token",       group = grpHook)
pairWebhook = input.string("USDT_ENA",         "Pair (QUOTE_BASE)", group = grpHook)

grpViz = "Visualization"
showGrid       = input.bool(true, "Show Grid Lines",      group = grpViz)
showRange      = input.bool(true, "Show Range Box",       group = grpViz)
showBounds     = input.bool(true, "Show HIGH/LOW Labels", group = grpViz)
showAvgEntry   = input.bool(true, "Plot Avg Entry Line",  group = grpViz)
showFillLabels = input.bool(true, "Show Fill Labels",     group = grpViz)
showTable      = input.bool(true, "Show Status Table",    group = grpViz)

grpWM = "Brand Watermark"
showWM    = input.bool(true,        "Show Watermark", group = grpWM)
wmText    = input.string("3Commas", "Watermark Text", group = grpWM)
wmPosStr  = input.string("Bottom Right", "Position", options = ["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group = grpWM)
wmSizeStr = input.string("Large",   "Text Size", options = ["Tiny","Small","Normal","Large","Huge"], group = grpWM)
wmAlpha   = input.int(70,           "Transparency (0–100)", minval = 0, maxval = 100, group = grpWM)

inWindow     = not useDateFilter or (time >= fromDate and time <= toDate)
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

if barstate.isfirst
    for i = 0 to nLevels - 1
        array.set(gridLevels, i, f_levelPx(i))

// ─────────────────────────────────────────────────────────────────────────────
// MAIN LOGIC — close-to-close crossing detection
// Each level is a slot: cross DOWN through it = BUY one unit; cross UP through
// the level immediately above = SELL the unit bought at this slot.
// ─────────────────────────────────────────────────────────────────────────────
prevClose = nz(close[1], close)

if inWindow
    for i = 1 to nLevels - 1
        levelPx = array.get(gridLevels, i)
        upperPx = array.get(gridLevels, i - 1)
        owned   = array.get(gridOwned, i)

        // BUY: not yet owned, price just crossed down through this level
        if not owned and prevClose > levelPx and close <= levelPx
            qty = usdtPerLevel / levelPx
            strategy.entry("L" + str.tostring(i), strategy.long, qty = qty, comment = "Grid_BUY_L" + str.tostring(i))
            array.set(gridOwned, i, true)
            alert(f_msgEntry(), alert.freq_once_per_bar_close)
            if showFillLabels
                label.new(bar_index, low, "BUY L" + str.tostring(i), style = label.style_label_up, color = color.new(color.green, 20), textcolor = color.white, size = size.tiny)

        // SELL: owned, price just crossed up through the level above
        if owned and prevClose < upperPx and close >= upperPx
            strategy.close("L" + str.tostring(i), comment = "Grid_TP_L" + str.tostring(i))
            array.set(gridOwned, i, false)
            alert(f_msgClose(), alert.freq_once_per_bar_close)
            if showFillLabels
                label.new(bar_index, high, "TP L" + str.tostring(i), style = label.style_label_down, color = color.new(color.red, 20), textcolor = color.white, size = size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
// VISUALIZATION
// ─────────────────────────────────────────────────────────────────────────────
plot(showAvgEntry and strategy.position_size > 0 ? strategy.position_avg_price : na, title = "Avg Entry", color = color.new(color.orange, 0), linewidth = 2, style = plot.style_linebr)

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
        if i == 0 or i == nLevels - 1 or i % 5 == 0
            lbl = label.new(x = bar_index + 8, y = px, text = "L" + str.tostring(i) + "  " + str.tostring(px, "#.#####"), style = label.style_label_left, color = color.new(color.gray, 80), textcolor = color.white, size = size.tiny)
            array.push(gridLabelRefs, lbl)

if barstate.islast and showBounds
    if not na(hiLabel)
        label.delete(hiLabel)
    if not na(loLabel)
        label.delete(loLabel)
    hiLabel := label.new(x = bar_index + 8, y = highPrice, text = "HIGH  " + str.tostring(highPrice, "#.#####"), style = label.style_label_left, color = color.new(color.red, 10),   textcolor = color.white, size = size.small)
    loLabel := label.new(x = bar_index + 8, y = lowPrice,  text = "LOW   " + str.tostring(lowPrice,  "#.#####"), style = label.style_label_left, color = color.new(color.green, 10), textcolor = color.white, size = size.small)

// Status table
if showTable and barstate.islast
    var table tbl = table.new(position = position.top_right, columns = 2, rows = 8, border_width = 1)
    bg  = color.new(color.gray, 30)
    bgH = color.new(color.gray, 0)

    ownedCount = 0
    for i = 0 to nLevels - 1
        if array.get(gridOwned, i)
            ownedCount += 1

    table.cell(tbl, 0, 0, "Strategy",      text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 1, 0, "ENA Grid Long", text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 0, 1, "Range",         text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 1, str.tostring(highPrice, "#.#####") + " ↔ " + str.tostring(lowPrice, "#.#####"), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 2, "Levels",        text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 2, str.tostring(nLevels) + " (" + gridMode + ")", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 3, "Owned / Total", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 3, str.tostring(ownedCount) + " / " + str.tostring(nLevels), text_color = ownedCount > 0 ? color.green : color.white, bgcolor = bg)
    table.cell(tbl, 0, 4, "Investment",    text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 4, str.tostring(investment, "#.##") + " USDT", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 5, "Per Slot",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 5, str.tostring(usdtPerLevel, "#.##") + " USDT", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 6, "Open PnL",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 6, str.tostring(strategy.openprofit, "#.##") + " USDT", text_color = strategy.openprofit >= 0 ? color.green : color.red, bgcolor = bg)
    table.cell(tbl, 0, 7, "Realized PnL",  text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 7, str.tostring(strategy.netprofit, "#.##") + " USDT (" + str.tostring(strategy.netprofit / strategy.initial_capital * 100, "#.##") + "%)", text_color = strategy.netprofit >= 0 ? color.green : color.red, bgcolor = bg)

// ─────────────────────────────────────────────────────────────────────────────
// BRAND WATERMARK
// ─────────────────────────────────────────────────────────────────────────────
var table wm = na
if showWM and barstate.islast
    if na(wm)
        wm := table.new(f_pos(wmPosStr), 1, 1, bgcolor = color.new(color.black, 100), border_width = 0)
    table.cell(wm, 0, 0, wmText, text_color = color.new(color.white, wmAlpha), text_size = f_size(wmSizeStr), bgcolor = color.new(color.black, 100))
````
