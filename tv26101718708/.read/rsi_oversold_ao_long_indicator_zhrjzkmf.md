# RSI Oversold AO - Long Indicator

- url: https://www.tradingview.com/script/zhrJzKmF-RSI-Oversold-AO-Long-Indicator/
- type: indicator
- pine_id: PUB;762da0f3023c43f8ad34e0ecd15dd756
- version: 1.0

## Description

RSI Oversold AO DCA — Long Indicator

🔷 What it does:
This is a signal-only indicator that mirrors a dual-RSI-gated long DCA workflow. It tracks one virtual long position at a time, opened only on a lower-timeframe RSI cross-down into oversold, and averages the position with up to four safety orders on an aggressive 2× × 2× ladder — but each safety order requires the RSI to still be below 25 at the moment of fill. No falling-knife averaging into recovering momentum. Exit is a fixed Take Profit at 3% above average entry. Every event emits a webhook-ready JSON payload for a DCA Bot.
  - Dual RSI gating: cross-down 30 entry trigger AND static less-than-25 continuation filter on every safety order.
  - Aggressive 2× × 2× safety-order ladder: deviations 1.00%, 3.00%, 7.00%, 15.00%; sizes 60, 120, 240, 480 USDT.
  - Fixed Take Profit: 3% above running average entry, no trailing.
  - Honest virtual bookkeeping: total cost and qty updated incrementally on every fill — avg entry and open PnL displayed live.
  - Six discrete events per cycle (entry + 4 AO fills + TP), each with its own webhook payload.

🔷 Who is it for:
  - Swing traders running a DCA Bot on crypto pairs that frequently overshoot into oversold readings.
  - Bot operators who want a chart-driven signal source that emits per-event JSON ready for a DCA Bot.
  - Traders who want averaging gated by momentum continuation, not just price levels — the "no falling knives" guard prevents loading further when momentum has already reversed.
  - Traders who want to monitor an evolving DCA position — base entry, owned AO levels, deployed capital, open PnL, live RSI readings — directly on the chart without the strategy-tester overhead.

🔷 How does it work:
  Entry RSI Filter (Oversold Cross Down): A 15-minute RSI(7) is sampled via request.security with lookahead disabled. The entry gate fires when RSI crosses down through 30 — momentum has just entered oversold territory. At host-bar close, if the indicator is flat and the cross is fresh, the virtual long position opens.
  Safety Order Ladder (Dual Gate): After entry, the indicator monitors two conditions in parallel for each pending safety order: price deviation downward against the position AND a static RSI continuation filter. The k-th safety order fires only when close ≤ base entry × (1 − cumulative deviation) AND the 15-minute RSI(7) is still below 25. Cumulative deviation grows by the step multiplier (default 2×): 1.00%, 3.00%, 7.00%, 15.00%. Each safety order's virtual size grows by 2×: 60, 120, 240, 480 USDT.
  Why the AO Gate Matters: A pure price-ladder DCA blindly averages into any decline. The RSI < 25 gate stops the averaging if momentum has reversed back above 25 — the asset is no longer oversold by the indicator's definition, and adding to the position would mean buying a recovery, not a dip. This filter trades off some averaging frequency for materially higher average-entry quality.
  Honest Virtual Bookkeeping: Total cost and qty are updated incrementally on every fill, so the avg entry, deployed capital, and open PnL displayed in the status table reflect the actual broker-equivalent position state — no shortcut from base entry, no synthetic averaging.
  Exit: A fixed Take Profit at 3% above the running average entry. When close hits the TP target, the close webhook fires and the virtual position resets.

🔷 Why it's unique:
  - Dual RSI Gating: Most DCA indicators gate only the entry. This indicator gates both the entry (cross-down momentum trigger) and the continuation of averaging (static oversold filter on every safety order).
  - Aggressive 2× × 2× Ladder: Most published DCA tools use mild 1.05–1.25× compounding. This one doubles both the deviation step and the size each rung — the position scales fast if all safety orders fill, but only inside a confirmed oversold regime.
  - Fill-by-Fill Avg Entry: The orange avg-entry line is derived from running totals updated on every event — what you see is what the broker-equivalent position would actually have.
  - Per-Event Webhook Ledger: Six distinct events per cycle, each with its own JSON alert payload. The indicator drives a DCA Bot end-to-end through a single TradingView alert.

🔷 Considerations Before Using the Indicator:
  Market & Timeframe: Designed for liquid crypto pairs on 1h–2h ranges. Default thresholds are calibrated for DOGEUSDT 1h. Different pairs may need RSI threshold and deviation ladder tuning.
  Cross Detection Granularity: Entries and AO fills are evaluated on bar close. A bar that spikes through a level and returns within the same bar may be missed by design — this matches realistic polling behavior and avoids over-signaling on intra-bar wicks.
  Live vs Historical State: The virtual position state is rebuilt from chart history each time the indicator is recompiled. If the indicator is added mid-deployment or the live bot diverges from the signal stream (manual interventions, partial fills), the indicator state may not match the live bot. Toggle the indicator off and on to reset.
  Aggressive Compounding: The 2× × 2× ladder is more aggressive than typical published DCAs. If all four safety orders fill, the position scales from 100 USDT base to 1,000 USDT total. Match the indicator's per-slot allocation to your bot's grid configuration to keep the avg-entry display honest.
  No Stop Loss: There is no exit signal on adverse moves beyond the 4-AO ladder. Risk is structurally capped on the bot side by the bounded position-size ladder. If a hard exchange-side stop is required, configure it on the bot directly.
  RSI Oversold Continuation: The AO gate uses a static RSI < 25 check, not a cross. If RSI dips to 20 and stays there for multiple bars while price drops further, all four AOs can fill in succession. Conversely, a sharp RSI recovery above 25 freezes the ladder mid-position.
  Backtesting Note: This is an indicator, not a strategy. There is no built-in P&L tester. For performance metrics over a 4-month sample (~44 closed trades, 77.27% win rate, 0.96% max drawdown, profit factor 5.791, +1.26% net return), use the companion strategy version on identical parameters. The 44-trade sample is below the typical ≥100 floor for statistical confidence — re-run on a 12+ month window for a more robust validation.

🔷 How to Use It:
  🔸 Add the indicator to a 1h chart on the crypto pair you want to trade.
  🔸 Review the entry RSI filter (timeframe / length / level), the AO gate RSI filter, the 4-AO ladder parameters, and the Take Profit percentage. Defaults are calibrated for DOGEUSDT 1h — recalibrate per asset before deploying.
  🔸 Set Base Order Size and AO sizes to match your bot's grid configuration (the indicator's avg-entry display becomes meaningful when virtual sizing matches real sizing).
  🔸 In the DCA Bot Webhook group, paste the Bot ID, Email Token, and Pair (QUOTE_BASE format, e.g., USDT_DOGE).
  🔸 Create an alert on the indicator with "Any alert() function call". Paste the DCA Bot's webhook URL into the alert's Webhook field. The indicator will emit JSON payloads for entry, each safety order, and TP exit — formatted for direct DCA Bot consumption.

🔷 INDICATOR SETTINGS
  Base Order Size (USDT): Virtual order size for the avg-entry / open-PnL computation.
  Averaging Orders per Trade: Maximum number of safety orders per cycle (default 4).
  First AO Size (USDT): Virtual size of the first safety order; subsequent AOs scale by the Size Multiplier.
  Deviation to First AO (%): Distance from base entry at which AO1 becomes eligible.
  Deviation Step Multiplier: Ladder factor that widens each subsequent deviation step.
  Order Size Multiplier: Factor that grows each subsequent safety order's USDT size.
  Entry RSI Timeframe / Length / Level: Lower-timeframe RSI cross-down filter for the base entry.
  AO Trigger RSI Timeframe / Length / Less Than: Lower-timeframe RSI continuation filter for each safety order.
  Take Profit (%): Fixed distance above the running average entry where the virtual long closes.
  DCA Bot Webhook: Bot ID, Email Token, and Pair fields injected into every alert payload.
  Visualization: Toggle AO Ladder, Avg / TP plot lines, fill labels, signal triangles, status table.
  Brand Watermark: Configurable text, position, size, and transparency.

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.

__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=6
// =============================================================================
//  RSI Oversold AO DCA — Long Indicator
//  Signal-only companion to the RSI Oversold AO DCA Long strategy. Tracks a
//  virtual long position (base + up to 4 safety orders on a 2×× 2× ladder)
//  and fires webhook-ready alerts on every event:
//    • LONG entry — RSI crossing down 30 on 15m
//    • SO fill    — price reaches next deviation rung AND RSI still < 25
//    • TP close   — close hits avg × (1 + TP%)
//  No backtest engine — designed to drive a live DCA Bot via webhooks.
//  Calibrated defaults for BINANCE:DOGEUSDT on 1h timeframe.
// =============================================================================
indicator("RSI Oversold AO DCA — Long Indicator", shorttitle = "RSIAO-I", overlay = true, max_labels_count = 500, max_lines_count = 100)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS (mirror the strategy 1:1)
// ─────────────────────────────────────────────────────────────────────────────
grpBase = "Base Order (Virtual)"
baseOrderSize = input.float(100.0, "Base Order Size (USDT)", minval = 1, group = grpBase, tooltip = "Tracked virtually for avg-entry computation. Real sizing happens on the DCA Bot.")

grpAO = "Averaging Orders"
aoCount    = input.int(4, "Averaging Orders per Trade", minval = 0, maxval = 10, group = grpAO)
aoSize     = input.float(60.0, "First AO Size (USDT)", minval = 1, group = grpAO)
aoStep     = input.float(1.0, "Deviation to First AO (%)", minval = 0.1, step = 0.1, group = grpAO)
aoStepMult = input.float(2.0, "Deviation Step Multiplier", minval = 1.0, step = 0.1, group = grpAO)
aoSizeMult = input.float(2.0, "Order Size Multiplier", minval = 1.0, step = 0.1, group = grpAO)

grpEntry = "Entry RSI Filter"
entryTF       = input.timeframe("15", "RSI Timeframe", group = grpEntry)
entryRsiLen   = input.int(7, "RSI Length", minval = 2, group = grpEntry)
entryRsiLevel = input.float(30.0, "RSI Crossing Down Level", minval = 1, maxval = 100, group = grpEntry)

grpAORSI = "AO Trigger RSI Filter"
aoRsiTF    = input.timeframe("15", "RSI Timeframe", group = grpAORSI)
aoRsiLen   = input.int(7, "RSI Length", minval = 2, group = grpAORSI)
aoRsiLevel = input.float(25.0, "RSI Less Than", minval = 1, maxval = 100, group = grpAORSI, tooltip = "Safety order fires only when LTF RSI is below this level — no falling-knife averaging.")

grpExit = "Exit"
tpPct = input.float(3.0, "Take Profit (%)", minval = 0.1, step = 0.1, group = grpExit)

grpDate = "Active Window"
useDateFilter = input.bool(true, "Limit Active Period", group = grpDate, tooltip = "When ON, the indicator only fires signals between From and To dates. Before From: no events; after To: no new events.")
fromDate      = input.time(timestamp("01 Feb 2026 00:00 +0000"), "From", group = grpDate)
toDate        = input.time(timestamp("28 May 2026 23:59 +0000"), "To",   group = grpDate)

grpHook = "DCA Bot Webhook"
botId       = input.string("YOUR_BOT_ID",      "Bot ID",            group = grpHook)
emailToken  = input.string("YOUR_EMAIL_TOKEN", "Email Token",       group = grpHook)
pairWebhook = input.string("USDT_DOGE",        "Pair (QUOTE_BASE)", group = grpHook)

grpViz = "Visualization"
showLevels     = input.bool(true, "Show AO Ladder",         group = grpViz)
showLines      = input.bool(true, "Plot Avg / TP Lines",    group = grpViz)
showFillLabels = input.bool(true, "Show Fill Labels",       group = grpViz)
showShapes     = input.bool(true, "Show Signal Triangles",  group = grpViz)
showTable      = input.bool(true, "Show Status Table",      group = grpViz)

grpWM = "Brand Watermark"
showWM    = input.bool(true,        "Show Watermark", group = grpWM)
wmText    = input.string("3Commas", "Watermark Text", group = grpWM)
wmPosStr  = input.string("Bottom Right", "Position", options = ["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group = grpWM)
wmSizeStr = input.string("Large",   "Text Size", options = ["Tiny","Small","Normal","Large","Huge"], group = grpWM)
wmAlpha   = input.int(70,           "Transparency (0–100)", minval = 0, maxval = 100, group = grpWM)

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

inWindow = not useDateFilter or (time >= fromDate and time <= toDate)

// ─────────────────────────────────────────────────────────────────────────────
// VIRTUAL POSITION STATE
// ─────────────────────────────────────────────────────────────────────────────
var bool  inPosition = false
var float baseEntry  = na
var int   aoFilled   = 0
var float totalCost  = 0.0   // USDT deployed across base + filled AOs
var float totalQty   = 0.0   // asset units across all fills

var bool entryEvent = false
var bool aoEvent    = false
var bool tpEvent    = false
entryEvent := false
aoEvent    := false
tpEvent    := false

// ENTRY — base order
if inWindow and not inPosition and entryCrossDown
    inPosition := true
    baseEntry  := close
    aoFilled   := 0
    totalCost  := baseOrderSize
    totalQty   := baseOrderSize / close
    entryEvent := true
    alert(f_msgEntry(), alert.freq_once_per_bar_close)
    if showFillLabels
        label.new(bar_index, low, "LONG ▲", style = label.style_label_up, color = color.new(color.green, 20), textcolor = color.white, size = size.tiny)

// AO trigger — price ladders DOWN against the long AND RSI still oversold
if inWindow and inPosition and aoFilled < aoCount and not na(baseEntry) and condAOG
    nextIdx   = aoFilled + 1
    threshold = f_cumDev(nextIdx)
    triggerPx = baseEntry * (1.0 - threshold / 100.0)
    if close <= triggerPx
        usdt = f_aoSize(nextIdx)
        totalCost := totalCost + usdt
        totalQty  := totalQty + usdt / close
        aoFilled  := nextIdx
        aoEvent   := true
        alert(f_msgAddAO(), alert.freq_once_per_bar_close)
        if showFillLabels
            label.new(bar_index, low, "AO" + str.tostring(nextIdx) + " ▲", style = label.style_label_up, color = color.new(color.aqua, 20), textcolor = color.white, size = size.tiny)

avgEntry = totalQty > 0 ? totalCost / totalQty : na
openPnl  = totalQty > 0 and not na(avgEntry) ? (close - avgEntry) * totalQty : 0.0

// EXIT — fixed TP
if inWindow and inPosition and not na(avgEntry)
    tpPrice = avgEntry * (1.0 + tpPct / 100.0)
    if close >= tpPrice
        tpEvent := true
        alert(f_msgClose(), alert.freq_once_per_bar_close)
        if showFillLabels
            label.new(bar_index, high, "TP ▼", style = label.style_label_down, color = color.new(color.green, 10), textcolor = color.white, size = size.tiny)
        // reset virtual position
        inPosition := false
        baseEntry  := na
        aoFilled   := 0
        totalCost  := 0.0
        totalQty   := 0.0

// ─────────────────────────────────────────────────────────────────────────────
// PLOTS & SIGNAL SHAPES
// ─────────────────────────────────────────────────────────────────────────────
plot(showLines and inPosition and not na(avgEntry) ? avgEntry : na, title = "Avg Entry", color = color.new(color.orange, 0), linewidth = 2, style = plot.style_linebr)
plot(showLines and inPosition and not na(avgEntry) ? avgEntry * (1.0 + tpPct / 100.0) : na, title = "TP", color = color.new(color.green, 0), linewidth = 1, style = plot.style_linebr)

plotshape(showShapes and entryEvent, title = "Long Entry", location = location.belowbar, style = shape.triangleup,   color = color.new(color.green, 0), size = size.small)
plotshape(showShapes and aoEvent,    title = "AO Fill",    location = location.belowbar, style = shape.triangleup,   color = color.new(color.aqua,  0), size = size.tiny)
plotshape(showShapes and tpEvent,    title = "TP Hit",     location = location.abovebar, style = shape.triangledown, color = color.new(color.green, 0), size = size.small)

// AO ladder lines (below baseEntry for long)
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

// Status table
if showTable and barstate.islast
    var table tbl = table.new(position = position.top_right, columns = 2, rows = 9, border_width = 1)
    bg  = color.new(color.gray, 30)
    bgH = color.new(color.gray, 0)
    table.cell(tbl, 0, 0, "Status",          text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 1, 0, inPosition ? "In Long (virtual)" : "Flat", text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 0, 1, "AOs Filled",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 1, str.tostring(aoFilled) + " / " + str.tostring(aoCount), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 2, "Base Entry",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 2, na(baseEntry) ? "—" : str.tostring(baseEntry, "#.#####"), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 3, "Avg Entry",       text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 3, inPosition and not na(avgEntry) ? str.tostring(avgEntry, "#.#####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 4, "TP Target",       text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 4, inPosition and not na(avgEntry) ? str.tostring(avgEntry * (1.0 + tpPct / 100.0), "#.#####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 5, "Deployed (USDT)", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 5, str.tostring(totalCost, "#.##"), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 6, entryTF + " RSI Entry", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 6, str.tostring(entryRsi, "#.#"), text_color = entryRsi <= entryRsiLevel ? color.green : color.white, bgcolor = bg)
    table.cell(tbl, 0, 7, aoRsiTF + " RSI AO Gate", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 7, str.tostring(aoRsi, "#.#"), text_color = condAOG ? color.green : color.white, bgcolor = bg)
    table.cell(tbl, 0, 8, "Open PnL",        text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 8, inPosition ? str.tostring(openPnl, "#.##") + " USDT" : "—", text_color = openPnl >= 0 ? color.green : color.red, bgcolor = bg)

// ─────────────────────────────────────────────────────────────────────────────
// BRAND WATERMARK
// ─────────────────────────────────────────────────────────────────────────────
var table wm = na
if showWM and barstate.islast
    if na(wm)
        wm := table.new(f_pos(wmPosStr), 1, 1, bgcolor = color.new(color.black, 100), border_width = 0)
    table.cell(wm, 0, 0, wmText, text_color = color.new(color.white, wmAlpha), text_size = f_size(wmSizeStr), bgcolor = color.new(color.black, 100))
````
