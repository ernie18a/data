# [3Commas] Dual RSI DCA INJ- Long Indicator

- url: https://www.tradingview.com/script/rUQrb7oI-3Commas-Dual-RSI-DCA-INJ-Long-Indicator/
- type: indicator
- pine_id: PUB;369a5fd8d974419b8ce3f016a6a2f4b7
- version: 1.0

## Description

[3Commas] Dual RSI DCA INJ - Long Indicator

🔷 What it does:
This is a signal-only indicator that mirrors a dollar-cost averaging long workflow with a dual RSI confirmation system. It identifies oversold reversal entries on the host chart using a lower-timeframe RSI cross-up, tracks a virtual position with up to five averaging fills on a deviation ladder, and fires the exit when the lower-timeframe RSI crosses down from overbought — but only after a minimum profit threshold from the running average entry has been reached.
  - Base entry signal arms on a lower-timeframe RSI(14) crossing up the oversold level (default 31 on 3m).
  - Up to five safety orders fire automatically as price ladders down, on a 1.3% step / 1.3 step multiplier / 1.25 size multiplier progression.
  - Take profit fires only when the lower-timeframe RSI crosses down the overbought level (default 69) AND minimum profit (default 2.4%) from average entry has been reached.
  - Every event emits a webhook-ready JSON alert payload formatted for direct DCA Bot consumption.

🔷 Who is it for:
  - Swing traders running a DCA Bot on crypto pairs that frequently mean-revert from local extremes.
  - Traders who want a clean oversold-to-overbought signal flow without the strategy-tester overhead.
  - Bot operators looking for a chart-driven signal source that ships webhook JSON natively, with no glue scripts required.
  - Anyone who wants to monitor a virtual DCA position with full transparency on average entry, fills, and deployed capital — directly on the chart.

🔷 How does it work:
  Lower-Timeframe RSI Cross-Up: The indicator polls a lower-timeframe RSI through request.security and checks for a cross above the oversold level at each host-bar close. When the cross fires AND the indicator is flat, the base-entry event triggers, the virtual position state is initialized, and the entry webhook payload is dispatched.
  Virtual Position Tracking: Once entered, the indicator captures the entry price, base USDT size, and seeds running totals of cost and asset units. Each subsequent safety order updates those totals so the average entry, total deployed capital, and profit zone are always derived from honest fill-by-fill bookkeeping.
  Safety Order Ladder: Five deviation thresholds are pre-computed from the base entry (1.30%, 2.99%, 5.18%, 8.04%, 11.75% at default settings). When the close price reaches the next threshold, the corresponding safety-order signal fires, the virtual position updates, and the AO webhook payload is emitted. No RSI gating on the ladder — it's pure price action.
  Take Profit Logic: Once price reaches the minimum-profit threshold above the running average entry, the exit becomes armed. The close signal then fires only when the lower-timeframe RSI crosses down from the overbought level — the indicator does not exit just because profit is reached, it waits for momentum confirmation.

🔷 Why it's unique:
  - Dual-RSI Architecture: Two independent lower-timeframe RSI cross conditions — one gates the entry, one gates the exit. Most DCA tools use a filter on only one end of the deal; this one filters both.
  - Profit-Armed Exit: The take profit does not fire on a static target. It waits for RSI to roll over from overbought, allowing winners to run while still requiring minimum profit before any close is considered.
  - Honest Virtual Tracking: Average entry, total cost, deployed capital, and minimum-profit target are all computed from the same fill-by-fill bookkeeping a real broker would do. No price-from-base shortcuts.
  - Webhook-First Design: Every event (base, each safety order, exit) emits a fully-formed JSON alert payload. Connect one alert to a DCA Bot's webhook URL and the indicator drives the bot end-to-end.

🔷 Considerations Before Using the Indicator:
  Market & Timeframe: Calibrated for INJUSDT perpetual on 3m with active mean-reversion behavior. Default RSI levels (31/69) are set for liquid volatility; thin or strongly trending pairs may need recalibration.
  Cross Detection Granularity: LTF RSI cross detection happens at host-bar close. A cross that completes and reverses inside a single host bar may be missed by design — this prevents over-signaling on intra-bar noise.
  No Stop Loss: There is no exit signal on adverse moves beyond the safety-order ladder. Risk is structurally capped by the bounded position-size sequence — at default settings, base + all five safety orders deploy roughly 9.93% of equity, keeping the trade within the conventional 5–10% risk band. If a hard stop is required, layer it on the bot side.
  Live vs Historical State: The virtual position state is rebuilt from the chart history each time the indicator is recompiled. If the indicator is added mid-trade or the live bot diverges from the signal stream (manual interventions, partial fills), the indicator state may not match the live bot. Toggle the indicator off and on to reset.
  Backtesting Note: This is an indicator, not a strategy. There is no built-in P&L tester. For performance metrics over a ~2.9-month sample (102 closed trades, 84.31% win rate, 1.98% max drawdown, profit factor 15.628, +2.23% net return), use the companion strategy version on identical parameters. The 102-trade sample is just above the ~100-trade floor for statistical relevance — treat the metrics as indicative.

🔷 How to Use It:
  🔸 Add the indicator to a 3m INJ / USDT chart.
  🔸 Configure the order sizing inputs to match the DCA Bot's settings (base order size, first AO size, multipliers).
  🔸 Set the entry RSI level (default 31) and exit RSI level (default 69) — these are the two RSI gates.
  🔸 Set the minimum profit threshold (default 2.4%) — exits will not fire below this.
  🔸 In the DCA Bot Webhook group, paste the Bot ID, Email Token, and Pair (QUOTE_BASE format, e.g., USDT_INJ).
  🔸 Create an alert on the indicator with "Any alert() function call". Paste the DCA Bot's webhook URL into the alert's Webhook field. The indicator will emit fully-formed JSON payloads for each event — no integration layer required.

🔷 INDICATOR SETTINGS
  Base Order Size (USDT): USDT size of the initial entry. Used for the virtual avg-entry computation.
  First AO Size (USDT): USDT size of the first safety order. Subsequent safety orders scale by the Size Multiplier.
  Order Size Multiplier: Factor that grows each subsequent safety order's USDT size (default 1.25).
  Averaging Orders per Trade: Maximum number of safety orders allowed per cycle (default 5).
  Deviation to First AO (%): Distance from base entry where the first safety order becomes eligible (default 1.3%).
  Deviation Step Multiplier: Ladder factor that widens each subsequent deviation step (default 1.3).
  Entry RSI Timeframe / Length / Level: Lower-timeframe RSI configuration for the oversold cross-up entry (default 3m / 14 / 31).
  Exit RSI Timeframe / Length / Level: Lower-timeframe RSI configuration for the overbought cross-down exit (default 3m / 14 / 69).
  Minimum Profit (%): Threshold above the running average entry that must be reached before the exit signal can fire (default 2.4%).
  DCA Bot Webhook: Bot ID, Email Token, and Pair fields injected into every alert payload.
  Visualization: Toggle the DCA Ladder, Signal Labels, Signal Triangles, Avg-Entry / Min-TP plots, and Status Table.
  Brand Watermark: Configurable text, position (9 options), size, and transparency.

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.

__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=6
// =============================================================================
//  Dual RSI DCA — Long Indicator
//  Signal-only companion to the Dual RSI DCA strategy. Tracks a virtual
//  position (base + up to 5 AOs) and fires webhook-ready alerts on:
//    • Base entry  — LTF RSI(14) crossing UP 31 on 3m
//    • Safety order — price reaches deviation ladder threshold
//    • Take profit — LTF RSI(14) crossing DOWN 69 + minimum profit ≥ 2.4%
//  No backtest engine — designed to drive a live DCA Bot via webhooks.
//  Calibrated defaults for BYBIT:INJUSDT.P on 3m timeframe.
// =============================================================================
indicator("Dual RSI DCA — Long Indicator", shorttitle = "DualRSI-I", overlay = true, max_lines_count = 100, max_labels_count = 500)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS (mirror the strategy 1:1)
// ─────────────────────────────────────────────────────────────────────────────
grpSize = "Order Sizing (Virtual)"
baseOrderSize = input.float(90.0,  "Base Order Size (USDT)", minval = 1, group = grpSize, tooltip = "Tracked virtually for avg-entry computation. Real sizing happens on the DCA Bot.")
aoSize        = input.float(110.0, "First AO Size (USDT)", minval = 1, group = grpSize)
aoSizeMult    = input.float(1.25,  "Order Size Multiplier", minval = 1.0, step = 0.05, group = grpSize)

grpAO = "Averaging Orders"
aoCount    = input.int(5,   "Averaging Orders per Trade", minval = 0, maxval = 10, group = grpAO)
aoStep     = input.float(1.3, "Deviation to First AO (%)", minval = 0.1, step = 0.1, group = grpAO)
aoStepMult = input.float(1.3, "Deviation Step Multiplier", minval = 1.0, step = 0.1, group = grpAO)

grpEntry = "Entry RSI Filter"
entryTF       = input.timeframe("3", "RSI Timeframe", group = grpEntry)
entryRsiLen   = input.int(14, "RSI Length", minval = 2, group = grpEntry)
entryRsiLevel = input.float(31.0, "RSI Crossing Up Level", minval = 1, maxval = 100, group = grpEntry, tooltip = "Base order arms when LTF RSI crosses up this level (oversold reversal).")

grpExit = "Exit RSI Filter"
exitTF        = input.timeframe("3", "RSI Timeframe", group = grpExit)
exitRsiLen    = input.int(14, "RSI Length", minval = 2, group = grpExit)
exitRsiLevel  = input.float(69.0, "RSI Crossing Down Level", minval = 1, maxval = 100, group = grpExit, tooltip = "Take profit fires when LTF RSI crosses down this level AND minimum profit is reached.")
minProfitPct  = input.float(2.4, "Minimum Profit (%)", minval = 0.1, step = 0.1, group = grpExit)

grpHook = "DCA Bot Webhook"
botId       = input.string("YOUR_BOT_ID",      "Bot ID",            group = grpHook)
emailToken  = input.string("YOUR_EMAIL_TOKEN", "Email Token",       group = grpHook)
pairWebhook = input.string("USDT_INJ",         "Pair (QUOTE_BASE)", group = grpHook)

grpViz = "Visualization"
showLadder = input.bool(true, "Show DCA Ladder",       group = grpViz)
showLabels = input.bool(true, "Show Signal Labels",    group = grpViz)
showShapes = input.bool(true, "Show Signal Triangles", group = grpViz)
showAvg    = input.bool(true, "Plot Avg Entry / Min TP", group = grpViz)
showTable  = input.bool(true, "Show Status Table",     group = grpViz)

grpWM = "Brand Watermark"
showWM    = input.bool(true,         "Show Watermark", group = grpWM)
wmText    = input.string("3Commas",  "Watermark Text", group = grpWM)
wmPosStr  = input.string("Bottom Right", "Position", options = ["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group = grpWM)
wmSizeStr = input.string("Large",    "Text Size", options = ["Tiny","Small","Normal","Large","Huge"], group = grpWM)
wmAlpha   = input.int(70,            "Transparency (0–100)", minval = 0, maxval = 100, group = grpWM, tooltip = "0 = fully opaque, 100 = invisible. Default 70 = subtle.")

// ─────────────────────────────────────────────────────────────────────────────
// LOWER-TIMEFRAME RSI
// ─────────────────────────────────────────────────────────────────────────────
entryRsi = request.security(syminfo.tickerid, entryTF, ta.rsi(close, entryRsiLen), lookahead = barmerge.lookahead_off)
exitRsi  = request.security(syminfo.tickerid, exitTF,  ta.rsi(close, exitRsiLen),  lookahead = barmerge.lookahead_off)

entryCrossUp  = entryRsi[1] < entryRsiLevel and entryRsi >= entryRsiLevel
exitCrossDown = exitRsi[1]  > exitRsiLevel  and exitRsi  <= exitRsiLevel

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
// VIRTUAL POSITION STATE
// ─────────────────────────────────────────────────────────────────────────────
var bool  inPosition = false
var float baseEntry  = na
var int   aoFilled   = 0
var float totalCost  = 0.0  // sum of USDT deployed across all fills
var float totalQty   = 0.0  // sum of asset units across all fills

// ─────────────────────────────────────────────────────────────────────────────
// EVENT 1 — BASE ENTRY (RSI cross up)
// ─────────────────────────────────────────────────────────────────────────────
baseFire = not inPosition and entryCrossUp
if baseFire
    inPosition := true
    baseEntry  := close
    aoFilled   := 0
    totalCost  := baseOrderSize
    totalQty   := baseOrderSize / close
    alert(f_msgEntry(), alert.freq_once_per_bar_close)

// ─────────────────────────────────────────────────────────────────────────────
// EVENT 2 — AVERAGING ORDER TRIGGER (price ladder)
// ─────────────────────────────────────────────────────────────────────────────
aoFire = false
if inPosition and aoFilled < aoCount and not na(baseEntry)
    nextIdx   = aoFilled + 1
    threshold = f_cumDev(nextIdx)
    triggerPx = baseEntry * (1.0 - threshold / 100.0)
    if close <= triggerPx
        aoFire    := true
        usdt      = f_aoSize(nextIdx)
        totalCost := totalCost + usdt
        totalQty  := totalQty + usdt / close
        aoFilled  := nextIdx
        alert(f_msgAddAO(), alert.freq_once_per_bar_close)

avgEntry = totalQty > 0 ? totalCost / totalQty : na

// ─────────────────────────────────────────────────────────────────────────────
// EVENT 3 — EXIT (RSI cross down + min profit armed)
// ─────────────────────────────────────────────────────────────────────────────
exitFire = false
if inPosition and not na(avgEntry)
    minTpPx     = avgEntry * (1.0 + minProfitPct / 100.0)
    profitArmed = close >= minTpPx
    if profitArmed and exitCrossDown
        exitFire   := true
        alert(f_msgClose(), alert.freq_once_per_bar_close)
        // reset virtual position
        inPosition := false
        baseEntry  := na
        aoFilled   := 0
        totalCost  := 0.0
        totalQty   := 0.0

// ─────────────────────────────────────────────────────────────────────────────
// VISUALIZATION
// ─────────────────────────────────────────────────────────────────────────────
plot(showAvg and inPosition and not na(avgEntry) ? avgEntry : na, title = "Avg Entry", color = color.new(color.orange, 0), linewidth = 2, style = plot.style_linebr)
plot(showAvg and inPosition and not na(avgEntry) ? avgEntry * (1.0 + minProfitPct / 100.0) : na, title = "Min TP", color = color.new(color.green, 0), linewidth = 1, style = plot.style_linebr)

// triangles (subtle, always-on signals)
plotshape(showShapes and baseFire, title = "Base Entry", location = location.belowbar, style = shape.triangleup,   color = color.new(color.green, 0), size = size.small)
plotshape(showShapes and aoFire,   title = "AO Fill",    location = location.belowbar, style = shape.triangleup,   color = color.new(color.aqua,  20), size = size.tiny)
plotshape(showShapes and exitFire, title = "TP Exit",    location = location.abovebar, style = shape.triangledown, color = color.new(color.red,   0), size = size.small)

// detailed labels (off by default)
if showLabels and baseFire
    label.new(bar_index, low, "BASE ▲", style = label.style_label_up, color = color.new(color.green, 10), textcolor = color.white, size = size.small)
if showLabels and aoFire
    label.new(bar_index, low, "AO" + str.tostring(aoFilled), style = label.style_label_up, color = color.new(color.aqua, 20), textcolor = color.white, size = size.tiny)
if showLabels and exitFire
    label.new(bar_index, high, "TP ▼", style = label.style_label_down, color = color.new(color.red, 10), textcolor = color.white, size = size.small)

// AO ladder
var aoLines = array.new<line>()
if barstate.islast and showLadder and not na(baseEntry)
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

// status table
if showTable and barstate.islast
    var table tbl = table.new(position = position.top_right, columns = 2, rows = 8, border_width = 1)
    bg  = color.new(color.gray, 30)
    bgH = color.new(color.gray, 0)
    table.cell(tbl, 0, 0, "Status",          text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 1, 0, inPosition ? "In Long (virtual)" : "Flat", text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 0, 1, "AOs Filled",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 1, str.tostring(aoFilled) + " / " + str.tostring(aoCount), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 2, "Base Entry",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 2, na(baseEntry) ? "—" : str.tostring(baseEntry, "#.####"), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 3, "Avg Entry",       text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 3, inPosition and not na(avgEntry) ? str.tostring(avgEntry, "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 4, "Min TP",          text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 4, inPosition and not na(avgEntry) ? str.tostring(avgEntry * (1.0 + minProfitPct / 100.0), "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 5, "Deployed (USDT)", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 5, str.tostring(totalCost, "#.##"), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 6, entryTF + " RSI (Entry)", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 6, str.tostring(entryRsi, "#.#"), text_color = entryRsi < entryRsiLevel ? color.red : color.white, bgcolor = bg)
    table.cell(tbl, 0, 7, exitTF + " RSI (Exit)", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 7, str.tostring(exitRsi, "#.#"), text_color = exitRsi > exitRsiLevel ? color.green : color.white, bgcolor = bg)

// ─────────────────────────────────────────────────────────────────────────────
// BRAND WATERMARK
// ─────────────────────────────────────────────────────────────────────────────
var table wm = na
if showWM and barstate.islast
    if na(wm)
        wm := table.new(f_pos(wmPosStr), 1, 1, bgcolor = color.new(color.black, 100), border_width = 0)
    table.cell(wm, 0, 0, wmText, text_color = color.new(color.white, wmAlpha), text_size = f_size(wmSizeStr), bgcolor = color.new(color.black, 100))
````
