# [3Commas] XAUT RSI Reversal DCA - Short Indicator

- url: https://www.tradingview.com/script/QhOUuf4B-3Commas-XAUT-RSI-Reversal-DCA-Short-Indicator/
- type: indicator
- pine_id: PUB;896915571db34230a8cf8ba64a46b716
- version: 1.0

## Description

[3Commas] XAUT RSI Reversal DCA — Short Indicator

🔷 What it does:
This is a signal-only indicator that mirrors a short-side mean-reversion workflow on XAUT / USDT (Tether Gold). It tracks one virtual short position at a time, opened when the 3-minute RSI(9) crosses down through 80 (overbought momentum rollover). Up to three averaging orders fill at fixed deviations ABOVE base entry (+1%, +2%, +3%) with uniform sizing. Exit is a 1.3% Take Profit with a 0.3% trailing retrace, plus a hard 8% Stop Loss. The indicator computes running average entry, deployed capital, open PnL, and lifetime realized PnL — all from honest fill-by-fill bookkeeping. Every event emits a webhook-ready JSON alert payload for direct DCA Bot consumption.
  - Momentum-exhaustion trigger: 3m RSI(9) crossing DOWN through 80.
  - Uniform DCA ladder: +1% / +2% / +3% above base entry, equal sizing.
  - Tight 1.3% Take Profit with a 0.3% trailing lock, and a hard 8% Stop Loss.
  - Honest virtual bookkeeping: Open PnL and lifetime Total PnL displayed live on the chart.

🔷 Who is it for:
  - Intraday traders fading overbought spikes on gold-pegged XAUT on lower timeframes.
  - Bot operators who want a chart-driven signal source that emits per-event JSON ready for a DCA Bot.
  - Traders who want a defined-risk short signal — modest averaging plus a hard stop — rather than an open-ended martingale.
  - Operators tracking staged position management (entry, up to three averaging fills, single exit) directly on the chart without the strategy-tester overhead.

🔷 How does it work:
  Entry Trigger: A 3-minute RSI(9) is sampled via request.security with lookahead disabled (no repaint). The base short opens when that RSI crosses DOWN through 80 — the prior 3m close was ≥ 80 and the current is below it, marking the moment overbought momentum rolls over.
  Base Entry: When the trigger fires, the indicator marks a virtual short, captures the base entry price, and seeds the cost-basis ledger with the configured base order size (default 500 USDT).
  Averaging Orders (Uniform DCA Ladder): After base fill, the indicator monitors price deviation above the base entry. Each averaging order has a fixed deviation — +1%, +2%, +3% — with uniform sizing (250 USDT each). Each fill updates the running cost-basis and dispatches its own webhook payload, raising the virtual average entry.
  Honest Virtual Bookkeeping: Total cost and qty are updated incrementally on every event, so the avg entry, deployed capital, Open PnL, and Total PnL displayed in the status table reflect the actual broker-equivalent position state — no shortcut from base entry, no synthetic averaging.
  Exit (TP + Trailing): A 1.3% Take Profit below the running average entry arms a trailing exit. Once price trades through the TP level, the indicator tracks the in-favor low and signals a close when price retraces 0.3% off that low.
  Stop Loss: A hard 8% Stop Loss above the average entry. If price runs against the short past that level, the close webhook fires, realized PnL accumulates, and the virtual position resets.
  Lifetime Total PnL: When a cycle closes, its realized PnL accumulates into a lifetime counter. The status table displays both Open PnL (current cycle, resets on exit) and Total PnL (lifetime, persists across chart history).

🔷 Why it's unique:
  - Momentum-Exhaustion Trigger: Rather than signaling on any overbought reading, the short opens specifically on the RSI crossing DOWN through 80 — the rollover moment — filtering out signals that fire while momentum is still climbing.
  - Defined-Risk DCA: A modest 3-rung uniform ladder AND an 8% hard stop, so the worst-case loss per cycle is bounded and known in advance.
  - Trailing Take Profit: The 1.3% target arms a 0.3% trailing exit rather than a fixed limit — capturing the reversion snap and then riding any follow-through.
  - Lifetime PnL Tracking: Open PnL and Total PnL are displayed live on the chart — strategy-tester-equivalent insight without running a backtest.
  - Per-Event Webhook Ledger: Up to six discrete events per cycle (entry + 3 AO fills + TP or SL), each with its own JSON alert payload. One TradingView alert with "Any alert() function call" drives a DCA Bot end-to-end.

🔷 Considerations Before Using the Indicator:
  Sample Size (Important): The companion strategy's backtest produced only 25 closed trades with no losers — far below the ~100-trade floor for statistical relevance. A 100% win rate over so few trades is a consequence of a small, favorable window, NOT a deterministic edge, and must not be extrapolated. Validate over a much longer window and across multiple assets, and expect losing trades in any realistic sample.
  Short Execution Venue: This signals shorts. Live shorting of XAUT requires a margin or perpetual venue — it cannot run on a spot account.
  Lower-Timeframe Sensitivity: The trigger runs on a 3-minute RSI. Lower timeframes generate more signals but are more sensitive to noise and fees. Confirm trade frequency and fee drag fit your execution venue.
  Stop Loss Discipline: The 8% Stop Loss is the defining risk control. With base plus three averaging orders, maximum deployed capital is ~1,250 USDT (12.5% of the default reference equity); an 8% stop on that bounds the worst-case loss to roughly 1% of equity. Keep the stop enabled — removing it converts this into an unbounded martingale short.
  Trend Risk: Fading overbought conditions works best in ranges and choppy regimes. In a strong sustained uptrend the short can hit the 8% stop repeatedly. The RSI-crossing-down trigger reduces but does not eliminate this.
  Cross Detection Granularity: Entries, AO fills, and exits are evaluated on bar close. A bar that spikes through a level and returns within the same bar may be missed by design — this matches realistic polling behavior and avoids over-signaling on intra-bar wicks.
  Live vs Historical State: The virtual position state is rebuilt from chart history each time the indicator is recompiled. If added mid-deployment or if the live bot diverges (manual interventions, partial fills), the indicator state may not match the live bot. Toggle the indicator off and on to reset.
  Backtesting Note: This is an indicator, not a strategy. There is no built-in P&L tester — but the live Total PnL counter gives a running approximation. For full metrics over a ~2.9-month sample (25 closed trades, 100% win rate, 0.83% max drawdown, undefined profit factor, +1.25% net return), use the companion strategy version on identical parameters — and read the Sample Size note above before relying on those figures.

🔷 How to Use It:
  🔸 Add the indicator to a 3m XAUT / USDT chart.
  🔸 Review the RSI trigger level, the averaging-order count/deviation/size, the Take Profit, Trailing, and Stop Loss percentages. Defaults mirror the source DCA Bot configuration.
  🔸 Set Base Order Size and AO sizes to match your bot's configuration (the avg-entry display becomes meaningful when virtual sizing matches real sizing).
  🔸 In the DCA Bot Webhook group, paste the Bot ID, Email Token, and Pair (QUOTE_BASE format, e.g., USDT_XAUT).
  🔸 Create an alert on the indicator with "Any alert() function call". Paste the DCA Bot's webhook URL into the alert's Webhook field. The indicator will emit JSON payloads for entry, each averaging order, and the TP/SL exit — formatted for direct DCA Bot consumption.

🔷 INDICATOR SETTINGS
  Base Order Size (USDT): Virtual order size for the avg-entry / open-PnL computation.
  Averaging Orders per Trade: Number of safety orders (default 3).
  First AO Size (USDT): Virtual size of each averaging order (uniform by default).
  Deviation to First AO (%) / Deviation Step Multiplier: Spacing of the AO ladder above base entry. Defaults to uniform +1% steps.
  Order Size Multiplier: Per-rung size scaling (1.0 = uniform).
  RSI Timeframe / Length / Crossing Down Level: The RSI(9) crossing-down trigger (default 3m).
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
//  XAUT RSI Reversal DCA — Short Indicator
//  Signal-only companion to the XAUT RSI Reversal DCA Short strategy.
//  Tracks a virtual short position (base + up to 3 uniform averaging orders on
//  a fixed +1% / +2% / +3% ladder) and fires webhook-ready alerts on every event:
//    • SHORT entry — 3m RSI(9) crosses DOWN through 80
//    • AO fill     — price reaches next fixed deviation ABOVE base entry
//    • TP close    — 1.3% target armed, closed on 0.3% trailing retrace
//    • SL close    — hard 8% stop above average entry
//  No backtest engine — designed to drive a live DCA Bot via webhooks.
//  Calibrated defaults for BYBIT:XAUTUSDT.P.
// =============================================================================
indicator("XAUT RSI Reversal DCA — Short Indicator", shorttitle = "XAUT DCA-SI", overlay = true, max_labels_count = 500, max_lines_count = 100)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS (mirror the strategy 1:1, RSI on 3m)
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
rsiTF    = input.timeframe("3", "RSI Timeframe", group = grpEntry, tooltip = "3 = 3 minutes.")
rsiLen   = input.int(9, "RSI Length", minval = 2, group = grpEntry)
rsiLevel = input.float(80.0, "RSI Crossing Down Level", minval = 1, maxval = 100, group = grpEntry, tooltip = "Short arms when RSI crosses DOWN through this level.")

grpExit = "Exit"
tpPct    = input.float(1.3, "Take Profit (%)", minval = 0.1, step = 0.1, group = grpExit, tooltip = "Distance below average entry where the trailing exit arms.")
trailPct = input.float(0.3, "Trailing (%)", minval = 0.1, step = 0.1, group = grpExit, tooltip = "Retrace from the in-favor low that closes the position.")
slPct    = input.float(8.0, "Stop Loss (%)", minval = 0.1, step = 0.1, group = grpExit, tooltip = "Hard stop above average entry.")

grpDate = "Active Window"
useDateFilter = input.bool(false, "Limit Active Period", group = grpDate, tooltip = "When ON, the indicator only fires signals between From and To dates.")
fromDate      = input.time(timestamp("03 Mar 2026 00:00 +0000"), "From", group = grpDate)
toDate        = input.time(timestamp("12 Jun 2026 23:59 +0000"), "To", group = grpDate)

grpHook = "DCA Bot Webhook"
botId       = input.string("YOUR_BOT_ID", "Bot ID", group = grpHook)
emailToken  = input.string("YOUR_EMAIL_TOKEN", "Email Token", group = grpHook)
pairWebhook = input.string("USDT_XAUT", "Pair (QUOTE_BASE)", group = grpHook)

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
// 3m RSI crossing-down trigger (no repaint)
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
