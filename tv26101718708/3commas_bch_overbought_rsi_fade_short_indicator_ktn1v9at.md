# [3Commas] BCH Overbought RSI Fade - Short Indicator

- url: https://www.tradingview.com/script/ktN1V9AT-3Commas-BCH-Overbought-RSI-Fade-Short-Indicator/
- type: indicator
- pine_id: PUB;48fa924f8dae48a4b8b45fb82a6c3aca
- version: 1.0

## Description

[3Commas] BCH Overbought RSI Fade - Short Indicator

🔷 What it does:
This is the signal-only companion to the BCH Overbought RSI Fade Short strategy — it fires alerts without running a backtest engine. It tracks one virtual short at a time, opened when the 5-minute RSI(9) crosses back DOWN through 80 (an overbought rollover). Up to three averaging orders stack at +1%, +2%, and +3% above entry (equal size). The deal closes on a 1.3% Take Profit from the average with a 0.3% trailing lock, or a hard 8% Stop Loss. Running average entry, deployed capital, open PnL, and lifetime realized PnL are all kept from honest fill-by-fill bookkeeping. Every event emits a webhook-ready JSON payload for a DCA Bot.
  - Entry on the RSI rollover: 5m RSI(9) crossing DOWN through 80.
  - Uniform averaging ladder above entry: +1% / +2% / +3%.
  - 1.3% Take Profit with a 0.3% trailing lock, plus a hard 8% Stop Loss.
  - Live Open PnL and lifetime Total PnL on the chart.

🔷 Who is it for:
  - Intraday traders fading blow-off spikes on BCH on lower timeframes.
  - Bot operators wiring TradingView alerts straight into a DCA Bot via per-event JSON.
  - Traders who want a defined-risk short signal — averaging with a stop, not a stopless martingale.
  - Operators who want to watch the virtual deal state (entry, fills, exit) directly on the chart.

🔷 How does it work:
  Entry Trigger: A 5-minute RSI(9) is pulled with request.security and lookahead disabled (no repaint). The short fires when that RSI was ≥ 80 on the prior 5m close and drops below it on the current close.
  Base Entry: On the trigger, the indicator marks a virtual short, records the entry, and seeds the cost-basis ledger with the base order size (default 500 USDT).
  Averaging Ladder (uniform): Three safety orders at fixed +1% / +2% / +3% above base, 250 USDT each. Each fill updates the running cost-basis and dispatches its own webhook, raising the virtual average entry.
  Honest Bookkeeping: Cost and quantity update on every event, so the average entry, deployed capital, Open PnL, and Total PnL in the status table reflect the true broker-equivalent state.
  Exit (TP + Trailing): At 1.3% below the running average, a trailing exit arms; the indicator tracks the in-favor low and signals a close on a 0.3% retrace off it.
  Stop Loss: A hard 8% stop above the average fires the close webhook, banks realized PnL, and resets the virtual position.
  Lifetime Total PnL: Each closed cycle's realized PnL accumulates into a lifetime counter shown alongside the current-cycle Open PnL.

🔷 Why it's unique:
  - Rollover, Not Just Overbought: Firing on the RSI cross-down through 80 skips trades that ignite while momentum is still rising — it waits for the turn.
  - Stop-Bounded Averaging: A compact 3-rung ladder plus an explicit 8% stop keeps the worst-case loss known up front.
  - Trailing Profit Lock: The 1.3% target arms a 0.3% trail, banking the snap-back while letting an extended drop run.
  - Lifetime PnL Tracking: Open and lifetime Total PnL on the chart give strategy-tester-equivalent insight without a backtest.
  - Plug-and-Play Webhooks: Base, each AO, and the exit each emit a complete JSON alert; one "Any alert() function call" alert drives a DCA Bot end-to-end.

🔷 Considerations Before Using the Indicator:
  Sample Size: The companion strategy's backtest produced 160 closed trades — above the ~100-trade floor commonly used for statistical relevance. Still a single test window, so treat the metrics as indicative.
  Short Execution Venue: This signals shorts. Live shorting of BCH requires a margin or perpetual venue — it cannot run on a spot account.
  Lower-Timeframe Sensitivity: The trigger runs on a 5-minute RSI. Fast timeframes mean more signals and more fee/slippage drag — confirm both fit your venue.
  Stop Loss Discipline: The 8% stop is the core risk control. Base plus three AOs deploy at most ~1,250 USDT (12.5% of the default reference equity); an 8% stop on that caps the worst case near ~1% of equity. Keep the stop on.
  Trend Risk: Fading strength suits ranges and choppy tape. In a relentless uptrend the short can be stopped out repeatedly; the rollover trigger reduces, but does not remove, that risk.
  Cross Detection Granularity: Entries, AO fills, and exits evaluate on bar close. A spike-and-revert within a single bar may be missed by design — matching realistic polling and avoiding intra-bar over-signaling.
  Live vs Historical State: The virtual state is rebuilt from chart history on each recompile. If added mid-deployment or if the live bot diverges (manual interventions, partial fills), states may differ. Toggle the indicator off and on to reset.
  Backtesting Note: This is an indicator, not a strategy. There is no built-in P&L tester — but the live Total PnL counter gives a running approximation. For full metrics over a ~4.8-month sample (160 closed trades, 84.38% win rate, 1.78% max drawdown, profit factor 2.207, +4.01% net return), use the companion strategy version on identical parameters.

🔷 How to Use It:
  🔸 Add the indicator to a 5m BCH / USDT chart.
  🔸 Review the RSI trigger level, the averaging-order count/deviation/size, the Take Profit, Trailing, and Stop Loss percentages. Defaults mirror the source DCA Bot configuration.
  🔸 Set Base Order Size and AO sizes to match your bot's configuration (the avg-entry display becomes meaningful when virtual sizing matches real sizing).
  🔸 In the DCA Bot Webhook group, paste the Bot ID, Email Token, and Pair (QUOTE_BASE format, e.g., USDT_BCH).
  🔸 Create an alert on the indicator with "Any alert() function call". Paste the DCA Bot's webhook URL into the alert's Webhook field. The indicator emits JSON for entry, each averaging order, and the TP/SL exit.

🔷 INDICATOR SETTINGS
  Base Order Size (USDT): Virtual order size for the avg-entry / open-PnL computation.
  Averaging Orders per Trade: Number of safety orders (default 3).
  First AO Size (USDT): Virtual size of each averaging order (uniform by default).
  Deviation to First AO (%) / Deviation Step Multiplier: Spacing of the AO ladder above base entry. Defaults to uniform +1% steps.
  Order Size Multiplier: Per-rung size scaling (1.0 = uniform).
  RSI Timeframe / Length / Crossing Down Level: The RSI(9) crossing-down trigger (default 5m).
  Take Profit (%) / Trailing (%): TP distance below average entry and the trailing retrace that closes the position.
  Stop Loss (%): Hard stop above average entry.
  Active Window: Optional date filter — when ON, the indicator only fires signals between From and To dates.
  DCA Bot Webhook: Bot ID, Email Token, and Pair fields injected into every alert payload.
  Visualization: Toggle DCA Ladder, Avg / TP / SL plot lines, fill labels, signal triangles, status table.
  Brand Watermark: Configurable text, position, size, and transparency.

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.

__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=6
// =============================================================================
//  BCH Overbought RSI Fade — Short Indicator
//  Signal-only companion to the BCH Overbought RSI Fade Short strategy.
//  Tracks a virtual short position (base + up to 3 uniform averaging orders on
//  a fixed +1% / +2% / +3% ladder) and fires webhook-ready alerts on every event:
//    • SHORT entry — 5m RSI(9) crosses DOWN through 80
//    • AO fill     — price reaches next fixed deviation ABOVE base entry
//    • TP close    — 1.3% target armed, closed on 0.3% trailing retrace
//    • SL close    — hard 8% stop above average entry
//  No backtest engine — designed to drive a live DCA Bot via webhooks.
//  Calibrated defaults for BYBIT:BCHUSDT.P.
// =============================================================================
indicator("[3Commas] BCH Overbought RSI Fade — Short Indicator", shorttitle = "[3Commas] BCH OB-Fade-SI", overlay = true, max_labels_count = 500, max_lines_count = 100)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS (mirror the strategy 1:1, RSI on 5m)
// ─────────────────────────────────────────────────────────────────────────────
grpBase = "Base Order (Virtual)"
baseOrderSize = input.float(500.0, "Base Order Size (USDT)", minval = 1, group = grpBase, tooltip = "Tracked virtually for avg-entry computation. Real sizing happens on the DCA Bot.")

grpAO = "Averaging Orders (Dollar-Cost Averaging)"
aoCount    = input.int(3, "Averaging Orders per Trade", minval = 0, maxval = 10, group = grpAO)
aoSize     = input.float(250.0, "First AO Size (USDT)", minval = 1, group = grpAO, tooltip = "Half the base order, matching the source config ratio.")
aoStep     = input.float(1.0, "Deviation to First AO (%)", minval = 0.1, step = 0.1, group = grpAO)
aoStepMult = input.float(1.0, "Deviation Step Multiplier", minval = 1.0, step = 0.1, group = grpAO, tooltip = "1.0 = uniform spacing: +1%, +2%, +3% from base.")
aoSizeMult = input.float(1.0, "Order Size Multiplier", minval = 1.0, step = 0.1, group = grpAO, tooltip = "1.0 = all AOs same size.")

grpEntry = "Trade Start Condition (RSI Crossing Down)"
rsiTF    = input.timeframe("5", "RSI Timeframe", group = grpEntry, tooltip = "5 = 5 minutes.")
rsiLen   = input.int(9, "RSI Length", minval = 2, group = grpEntry)
rsiLevel = input.float(80.0, "RSI Crossing Down Level", minval = 1, maxval = 100, group = grpEntry, tooltip = "Short arms when RSI crosses DOWN through this level.")

grpExit = "Exit"
tpPct    = input.float(1.3, "Take Profit (%)", minval = 0.1, step = 0.1, group = grpExit, tooltip = "Distance below average entry where the trailing exit arms.")
trailPct = input.float(0.3, "Trailing (%)", minval = 0.1, step = 0.1, group = grpExit, tooltip = "Retrace from the in-favor low that closes the position.")
slPct    = input.float(8.0, "Stop Loss (%)", minval = 0.1, step = 0.1, group = grpExit, tooltip = "Hard stop above average entry.")

grpDate = "Active Window"
useDateFilter = input.bool(false, "Limit Active Period", group = grpDate, tooltip = "When ON, the indicator only fires signals between From and To dates.")
fromDate      = input.time(timestamp("26 Jan 2026 00:00 +0000"), "From", group = grpDate)
toDate        = input.time(timestamp("19 Jun 2026 23:59 +0000"), "To", group = grpDate)

grpHook = "DCA Bot Webhook"
botId       = input.string("YOUR_BOT_ID", "Bot ID", group = grpHook)
emailToken  = input.string("YOUR_EMAIL_TOKEN", "Email Token", group = grpHook)
pairWebhook = input.string("USDT_BCH", "Pair (QUOTE_BASE)", group = grpHook)

grpViz = "Visualization"
showLevels     = input.bool(true, "Show DCA Ladder", group = grpViz)
showLines      = input.bool(true, "Plot Avg / TP / SL Lines", group = grpViz)
showFillLabels = input.bool(true, "Show Fill Labels", group = grpViz)
showShapes     = input.bool(true, "Show Signal Triangles", group = grpViz)
showTable      = input.bool(true, "Show Status Table", group = grpViz)

grpWM = "Brand Watermark"
showWM    = input.bool(true,        "Show Watermark", group = grpWM)
wmText    = input.string("3Commas", "Watermark Text", group = grpWM)
wmPosStr  = input.string("Bottom Right", "Position", options = ["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group = grpWM)
wmSizeStr = input.string("Large",   "Text Size", options = ["Tiny","Small","Normal","Large","Huge"], group = grpWM)
wmAlpha   = input.int(70,           "Transparency (0–100)", minval = 0, maxval = 100, group = grpWM)

inWindow = not useDateFilter or (time >= fromDate and time <= toDate)

// ─────────────────────────────────────────────────────────────────────────────
// 5m RSI crossing-down trigger (no repaint)
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
// VIRTUAL POSITION STATE
// ─────────────────────────────────────────────────────────────────────────────
var bool  inPosition  = false
var float baseEntry   = na
var int   aoFilled    = 0
var float totalCost   = 0.0   // USDT deployed across base + filled AOs
var float totalQty    = 0.0   // asset units across all fills
var float realizedPnl = 0.0   // cumulative realized PnL from closed virtual cycles
var float minSinceTP  = na
var bool  inTPZone    = false

var bool entryEvent = false
var bool aoEvent    = false
var bool tpEvent    = false
var bool slEvent    = false
entryEvent := false
aoEvent    := false
tpEvent    := false
slEvent    := false

avgEntry = totalQty > 0 ? totalCost / totalQty : na

// ENTRY — base order (RSI crosses down 80)
if inWindow and not inPosition and rsiCrossDn
    inPosition := true
    baseEntry  := close
    aoFilled   := 0
    totalCost  := baseOrderSize
    totalQty   := baseOrderSize / close
    minSinceTP := na
    inTPZone   := false
    entryEvent := true
    alert(f_msgEntry(), alert.freq_once_per_bar_close)
    if showFillLabels
        label.new(bar_index, high, "SHORT ▼", style = label.style_label_down, color = color.new(color.red, 20), textcolor = color.white, size = size.tiny)

// AO trigger — fixed deviation ABOVE base entry
if inWindow and inPosition and aoFilled < aoCount and not na(baseEntry)
    nextIdx   = aoFilled + 1
    threshold = f_cumDev(nextIdx)
    triggerPx = baseEntry * (1.0 + threshold / 100.0)
    if close >= triggerPx
        usdt = f_aoSize(nextIdx)
        totalCost := totalCost + usdt
        totalQty  := totalQty + usdt / close
        aoFilled  := nextIdx
        aoEvent   := true
        alert(f_msgAddAO(), alert.freq_once_per_bar_close)
        if showFillLabels
            label.new(bar_index, high, "AO" + str.tostring(nextIdx) + " ▼", style = label.style_label_down, color = color.new(color.orange, 20), textcolor = color.white, size = size.tiny)

avgEntry := totalQty > 0 ? totalCost / totalQty : na
openPnl  = totalQty > 0 and not na(avgEntry) ? (avgEntry - close) * totalQty : 0.0

// EXIT — hard Stop Loss, then TP + trailing
if inWindow and inPosition and not na(avgEntry)
    slPrice = avgEntry * (1.0 + slPct / 100.0)
    tpPrice = avgEntry * (1.0 - tpPct / 100.0)
    if close >= slPrice
        realizedPnl := realizedPnl + (avgEntry - close) * totalQty
        slEvent := true
        alert(f_msgClose(), alert.freq_once_per_bar_close)
        if showFillLabels
            label.new(bar_index, high, "SL ▲", style = label.style_label_up, color = color.new(color.red, 10), textcolor = color.white, size = size.tiny)
        inPosition := false
        baseEntry  := na
        aoFilled   := 0
        totalCost  := 0.0
        totalQty   := 0.0
        minSinceTP := na
        inTPZone   := false
    else
        if close <= tpPrice
            inTPZone   := true
            minSinceTP := na(minSinceTP) ? close : math.min(minSinceTP, close)
        if inTPZone and not na(minSinceTP)
            trailStop = minSinceTP * (1.0 + trailPct / 100.0)
            if close >= trailStop
                realizedPnl := realizedPnl + (avgEntry - close) * totalQty
                tpEvent := true
                alert(f_msgClose(), alert.freq_once_per_bar_close)
                if showFillLabels
                    label.new(bar_index, low, "TP ▲", style = label.style_label_up, color = color.new(color.green, 10), textcolor = color.white, size = size.tiny)
                inPosition := false
                baseEntry  := na
                aoFilled   := 0
                totalCost  := 0.0
                totalQty   := 0.0
                minSinceTP := na
                inTPZone   := false

// ─────────────────────────────────────────────────────────────────────────────
// PLOTS & SIGNAL SHAPES
// ─────────────────────────────────────────────────────────────────────────────
plot(showLines and inPosition and not na(avgEntry) ? avgEntry : na, title = "Avg Entry", color = color.new(color.orange, 0), linewidth = 2, style = plot.style_linebr)
plot(showLines and inPosition and not na(avgEntry) ? avgEntry * (1.0 - tpPct / 100.0) : na, title = "TP Target", color = color.new(color.green, 0), linewidth = 1, style = plot.style_linebr)
plot(showLines and inPosition and not na(avgEntry) ? avgEntry * (1.0 + slPct / 100.0) : na, title = "Stop Loss", color = color.new(color.red, 0), linewidth = 1, style = plot.style_linebr)

plotshape(showShapes and entryEvent, title = "Short Entry", location = location.abovebar, style = shape.triangledown, color = color.new(color.red,    0), size = size.small)
plotshape(showShapes and aoEvent,    title = "AO Fill",     location = location.abovebar, style = shape.triangledown, color = color.new(color.orange, 0), size = size.tiny)
plotshape(showShapes and tpEvent,    title = "TP Hit",      location = location.belowbar, style = shape.triangleup,   color = color.new(color.green,  0), size = size.small)
plotshape(showShapes and slEvent,    title = "SL Hit",      location = location.abovebar, style = shape.xcross,       color = color.new(color.red,    0), size = size.small)

// DCA ladder lines (above baseEntry for short)
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
        ln  = line.new(x1 = bar_index - 80, x2 = bar_index + 8, y1 = px, y2 = px, color = col, style = line.style_dashed, width = wid)
        array.push(aoLines, ln)
        sz = f_aoSize(k)
        label.new(x = bar_index + 8, y = px, text = "AO" + str.tostring(k) + "  +" + str.tostring(dev, "#.#") + "%  $" + str.tostring(sz, "#"), style = label.style_label_left, color = color.new(color.gray, 70), textcolor = color.white, size = size.tiny)

// Status table
if showTable and barstate.islast
    var table tbl = table.new(position = position.top_right, columns = 2, rows = 10, border_width = 1)
    bg  = color.new(color.gray, 30)
    bgH = color.new(color.gray, 0)
    table.cell(tbl, 0, 0, "Status", text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 1, 0, inPosition ? "In Short (virtual)" : "Flat", text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 0, 1, "AOs Filled", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 1, str.tostring(aoFilled) + " / " + str.tostring(aoCount), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 2, "Base Entry", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 2, na(baseEntry) ? "—" : str.tostring(baseEntry, "#.##"), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 3, "Avg Entry", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 3, inPosition and not na(avgEntry) ? str.tostring(avgEntry, "#.##") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 4, "TP Target", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 4, inPosition and not na(avgEntry) ? str.tostring(avgEntry * (1.0 - tpPct / 100.0), "#.##") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 5, "Stop Loss", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 5, inPosition and not na(avgEntry) ? str.tostring(avgEntry * (1.0 + slPct / 100.0), "#.##") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 6, rsiTF + "m RSI(" + str.tostring(rsiLen) + ")", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 6, str.tostring(rsiVal, "#.#"), text_color = rsiVal > rsiLevel ? color.red : color.white, bgcolor = bg)
    table.cell(tbl, 0, 7, "Deployed (USDT)", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 7, str.tostring(totalCost, "#"), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 8, "Open PnL", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 8, inPosition ? "$" + str.tostring(openPnl, "#.##") : "—", text_color = openPnl >= 0 ? color.green : color.red, bgcolor = bg)
    totalPnl = realizedPnl + (inPosition ? openPnl : 0.0)
    table.cell(tbl, 0, 9, "Total PnL", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 9, "$" + str.tostring(totalPnl, "#.##"), text_color = totalPnl >= 0 ? color.green : color.red, bgcolor = bg)

// ─────────────────────────────────────────────────────────────────────────────
// BRAND WATERMARK
// ─────────────────────────────────────────────────────────────────────────────
var table wm = na
if showWM and barstate.islast
    if na(wm)
        wm := table.new(f_pos(wmPosStr), 1, 1, bgcolor = color.new(color.black, 100), border_width = 0)
    table.cell(wm, 0, 0, wmText, text_color = color.new(color.white, wmAlpha), text_size = f_size(wmSizeStr), bgcolor = color.new(color.black, 100))
````
