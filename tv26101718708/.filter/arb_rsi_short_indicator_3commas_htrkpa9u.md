# ARB RSI Short Indicator [3Commas]

- url: https://www.tradingview.com/script/hTRkPA9u-ARB-RSI-Short-Indicator-3Commas/
- type: indicator
- pine_id: PUB;f3c8c31a220441228aacad3ffa44bf35
- version: 1.0

## Description

ARB RSI Short Indicator [3Commas]

🔷 What it does:
This is the signal-only companion to the ARB RSI Short strategy — it fires alerts without running a backtest engine. It tracks one virtual short at a time, opened when the 4-hour RSI(14) crosses back DOWN through 74 (an overbought rollover). Two averaging orders stack ABOVE entry at +5% and +10% (sizes scaled 1.7×: 850, then 1,445). The deal closes on a fixed 6% Take Profit from the average. There is no Stop Loss — the position is bounded by the 2-rung ladder. Running average entry, deployed capital, open PnL, and lifetime realized PnL are kept from honest fill-by-fill bookkeeping, and every event emits a webhook-ready JSON payload for a DCA Bot.
  - Entry on the 4h RSI rollover: crossing DOWN through 74.
  - Two averaging orders above entry: +5% / +10%, sized 1.7× per rung.
  - Fixed 6% Take Profit from the running average. No trailing.
  - No Stop Loss — bounded by the 2-AO ladder.
  - Live Open PnL and lifetime Total PnL on the chart.

🔷 Who is it for:
  - Swing traders fading higher-timeframe overbought conditions on ARB.
  - DCA-style traders comfortable with rare, selective entries (a 4h RSI rollover fires only a few times per year).
  - Bot operators wiring TradingView alerts straight into a DCA Bot via per-event JSON.
  - Traders who accept a bounded ladder with no hard stop in exchange for a high deal-close rate.

🔷 How does it work:
  Entry Trigger: A 4-hour RSI(14) is pulled with request.security and lookahead disabled (no repaint). The short fires when that RSI was ≥ 74 on the prior 4h close and drops below it on the current close.
  Base Entry: On the trigger, the indicator marks a virtual short, records the entry, and seeds the cost-basis ledger with the base order size (default 500 USDT).
  Averaging Ladder: Two safety orders at fixed +5% / +10% above base, sized 850 then 1,445 (1.7× progression). Each fill updates the running cost-basis and dispatches its own webhook, raising the virtual average entry.
  Honest Bookkeeping: Cost and quantity update on every event, so the average entry, deployed capital, Open PnL, and Total PnL in the status table reflect the true broker-equivalent state.
  Exit: A fixed 6% Take Profit below the running average. When close reaches it, the close webhook fires, realized PnL accumulates, and the virtual position resets.
  No Stop Loss: There is no exit signal above the top rung. Risk is structurally capped on the bot side by the bounded position; if a hard stop is required, configure it on the bot.
  Lifetime Total PnL: Each closed cycle's realized PnL accumulates into a lifetime counter shown alongside the current-cycle Open PnL.

🔷 Why it's unique:
  - Higher-Timeframe Rollover: Firing on a 4h RSI cross-down through 74 is far more selective than an intraday trigger — it waits for a meaningful overbought turn.
  - Bounded Averaging, No Stop: A compact 2-rung 1.7× ladder caps the maximum position in advance, which is the structural risk control in place of a stop.
  - Fixed Recovery Target: The 6% Take Profit on the averaged-down entry releases the deal on a clean, defined bounce.
  - Lifetime PnL Tracking: Open and lifetime Total PnL on the chart give strategy-tester-equivalent insight without a backtest.
  - Plug-and-Play Webhooks: Base, each AO, and the exit each emit a complete JSON alert; one "Any alert() function call" alert drives a DCA Bot end-to-end.

🔷 Considerations Before Using the Indicator:
  Sample Size (Important): Over a ~3.25-year backtest the companion strategy produced only 10 closed trades — far below the ~100-trade floor for statistical relevance. The 80% win rate and high profit factor are a consequence of this tiny, selective sample and must NOT be extrapolated. Treat them as a demonstration of the entry's discipline; validate across more assets and conditions, and expect a very low signal frequency.
  No Stop Loss / Tail Risk: With no stop, a sustained rally above the +10% top rung leaves the full virtual position open until price reverts to the 6% target — the largest risk here. The bounded ladder caps deployment (~28% of reference equity), not how far price can run against the unhedged remainder.
  Short Execution Venue: This signals shorts. Live shorting of ARB requires a margin or perpetual venue — it cannot run on a spot account.
  Cross Detection Granularity: Entries, AO fills, and exit evaluate on bar close. A spike-and-revert within a single bar may be missed by design — matching realistic polling and avoiding intra-bar over-signaling.
  Live vs Historical State: The virtual state is rebuilt from chart history on each recompile. If added mid-deployment or if the live bot diverges (manual interventions, partial fills), states may differ. Toggle the indicator off and on to reset.
  Backtesting Note: This is an indicator, not a strategy. There is no built-in P&L tester — but the live Total PnL counter gives a running approximation. For full metrics over a ~3.25-year sample (10 closed trades, 80.00% win rate, 4.48% max drawdown, profit factor 16.189, +5.30% net return), use the companion strategy version on identical parameters — and read the Sample Size note above before relying on those figures.

🔷 How to Use It:
  🔸 Add the indicator to a 4h ARB / USDT chart.
  🔸 Review the RSI trigger level (74), the AO deviations/sizes, and the Take Profit. Defaults mirror the source strategy.
  🔸 Set Base Order Size and AO sizes to match your bot's configuration (the avg-entry display becomes meaningful when virtual sizing matches real sizing).
  🔸 In the DCA Bot Webhook group, paste the Bot ID, Email Token, and Pair (QUOTE_BASE format, e.g., USDT_ARB).
  🔸 Create an alert on the indicator with "Any alert() function call". Paste the DCA Bot's webhook URL into the alert's Webhook field. The indicator emits JSON for entry, each averaging order, and the TP exit.

🔷 INDICATOR SETTINGS
  Base Order Size (USDT): Virtual order size for the avg-entry / open-PnL computation.
  Averaging Orders per Trade: Number of safety orders (default 2).
  First AO Size (USDT): Virtual size of the first averaging order; subsequent AOs scale by the Order Size Multiplier.
  Deviation to First AO (%) / Deviation Step Multiplier: Spacing of the AO ladder above base entry. Defaults to +5% then +10%.
  Order Size Multiplier: Per-rung size scaling (default 1.7).
  RSI Timeframe / Length / Crossing Down Level: The 4h RSI(14) crossing-down trigger for the base short.
  Take Profit (%): Fixed distance below average entry where the virtual short closes.
  Active Window: Optional date filter — when ON, the indicator only fires signals between From and To dates.
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
//  ARB RSI Short Indicator
//  Signal-only companion to the ARB RSI Short strategy. Tracks a virtual short
//  position (base + up to 2 averaging orders at fixed +5% / +10% above entry,
//  sizes scaled 1.7x) and fires webhook-ready alerts on every event:
//    • SHORT entry — 4h RSI(14) crosses DOWN through 74
//    • AO fill     — price reaches next fixed deviation ABOVE base entry
//    • TP close    — close reaches avg × (1 − 6%)
//  NO STOP LOSS — bounded by the 2-AO ladder. No backtest engine; designed to
//  drive a live DCA Bot via webhooks. Calibrated for BYBIT:ARBUSDT.P on 4h.
// =============================================================================
indicator("ARB RSI Short Indicator [3Commas]", shorttitle = "ARB RSI-SI [3Commas]", overlay = true, max_labels_count = 500, max_lines_count = 100)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS (mirror the strategy 1:1)
// ─────────────────────────────────────────────────────────────────────────────
grpBase = "Base Order (Virtual)"
baseOrderSize = input.float(500.0, "Base Order Size (USDT)", minval = 1, group = grpBase, tooltip = "Tracked virtually for avg-entry computation. Real sizing happens on the DCA Bot.")

grpAO = "Averaging Orders (Fixed Deviations)"
aoCount    = input.int(2, "Averaging Orders per Trade", minval = 0, maxval = 10, group = grpAO)
aoSize     = input.float(850.0, "First AO Size (USDT)", minval = 1, group = grpAO, tooltip = "First AO = base x1.7 = 850. Next AOs scale by the Order Size Multiplier.")
aoStep     = input.float(5.0, "Deviation to First AO (%)", minval = 0.1, step = 0.1, group = grpAO, tooltip = "AO1 fires when price rises 5% above base (-5% adverse for the short).")
aoStepMult = input.float(1.0, "Deviation Step Multiplier", minval = 1.0, step = 0.1, group = grpAO, tooltip = "1.0 = uniform 5% steps: +5%, +10% from base.")
aoSizeMult = input.float(1.7, "Order Size Multiplier", minval = 1.0, step = 0.1, group = grpAO, tooltip = "Each AO 1.7x the previous: 850 -> 1445.")

grpEntry = "Trade Start Condition (RSI Crossing Down)"
rsiTF    = input.timeframe("240", "RSI Timeframe", group = grpEntry, tooltip = "240 = 4 hours. Pine timeframe notation.")
rsiLen   = input.int(14, "RSI Length", minval = 2, group = grpEntry)
rsiLevel = input.float(74.0, "RSI Crossing Down Level", minval = 1, maxval = 100, group = grpEntry, tooltip = "Short arms when 4h RSI crosses DOWN through this level (overbought rollover).")

grpExit = "Exit"
tpPct = input.float(6.0, "Take Profit (%)", minval = 0.1, step = 0.1, group = grpExit, tooltip = "Distance below average entry where the short closes for profit. No trailing, no Stop Loss.")

grpDate = "Active Window"
useDateFilter = input.bool(false, "Limit Active Period", group = grpDate, tooltip = "When ON, the indicator only fires signals between From and To dates.")
fromDate      = input.time(timestamp("23 Mar 2023 00:00 +0000"), "From", group = grpDate)
toDate        = input.time(timestamp("21 Jun 2026 23:59 +0000"), "To", group = grpDate)

grpHook = "DCA Bot Webhook"
botId       = input.string("YOUR_BOT_ID", "Bot ID", group = grpHook)
emailToken  = input.string("YOUR_EMAIL_TOKEN", "Email Token", group = grpHook)
pairWebhook = input.string("USDT_ARB", "Pair (QUOTE_BASE)", group = grpHook)

grpViz = "Visualization"
showLevels     = input.bool(true, "Show AO Ladder", group = grpViz)
showLines      = input.bool(true, "Plot Avg / TP Lines", group = grpViz)
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
// 4h RSI crossing-down trigger (no repaint)
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

var bool entryEvent = false
var bool aoEvent    = false
var bool tpEvent    = false
entryEvent := false
aoEvent    := false
tpEvent    := false

// ENTRY — base order (RSI crosses down 74)
if inWindow and not inPosition and rsiCrossDn
    inPosition := true
    baseEntry  := close
    aoFilled   := 0
    totalCost  := baseOrderSize
    totalQty   := baseOrderSize / close
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

avgEntry = totalQty > 0 ? totalCost / totalQty : na
openPnl  = totalQty > 0 and not na(avgEntry) ? (avgEntry - close) * totalQty : 0.0

// EXIT — fixed TP (no SL)
if inWindow and inPosition and not na(avgEntry)
    tpPrice = avgEntry * (1.0 - tpPct / 100.0)
    if close <= tpPrice
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

// ─────────────────────────────────────────────────────────────────────────────
// PLOTS & SIGNAL SHAPES
// ─────────────────────────────────────────────────────────────────────────────
plot(showLines and inPosition and not na(avgEntry) ? avgEntry : na, title = "Avg Entry", color = color.new(color.orange, 0), linewidth = 2, style = plot.style_linebr)
plot(showLines and inPosition and not na(avgEntry) ? avgEntry * (1.0 - tpPct / 100.0) : na, title = "TP Target", color = color.new(color.green, 0), linewidth = 1, style = plot.style_linebr)

plotshape(showShapes and entryEvent, title = "Short Entry", location = location.abovebar, style = shape.triangledown, color = color.new(color.red,    0), size = size.small)
plotshape(showShapes and aoEvent,    title = "AO Fill",     location = location.abovebar, style = shape.triangledown, color = color.new(color.orange, 0), size = size.tiny)
plotshape(showShapes and tpEvent,    title = "TP Hit",      location = location.belowbar, style = shape.triangleup,   color = color.new(color.green,  0), size = size.small)

// AO ladder lines (above baseEntry for short)
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
        ln  = line.new(x1 = bar_index - 100, x2 = bar_index + 8, y1 = px, y2 = px, color = col, style = line.style_dashed, width = wid)
        array.push(aoLines, ln)
        sz = f_aoSize(k)
        label.new(x = bar_index + 8, y = px, text = "AO" + str.tostring(k) + "  +" + str.tostring(dev, "#.#") + "%  $" + str.tostring(sz, "#"), style = label.style_label_left, color = color.new(color.gray, 70), textcolor = color.white, size = size.tiny)

// Status table
if showTable and barstate.islast
    var table tbl = table.new(position = position.top_right, columns = 2, rows = 9, border_width = 1)
    bg  = color.new(color.gray, 30)
    bgH = color.new(color.gray, 0)
    table.cell(tbl, 0, 0, "Status", text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 1, 0, inPosition ? "In Short (virtual)" : "Flat", text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 0, 1, "AOs Filled", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 1, str.tostring(aoFilled) + " / " + str.tostring(aoCount), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 2, "Base Entry", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 2, na(baseEntry) ? "—" : str.tostring(baseEntry, "#.####"), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 3, "Avg Entry", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 3, inPosition and not na(avgEntry) ? str.tostring(avgEntry, "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 4, "TP Target", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 4, inPosition and not na(avgEntry) ? str.tostring(avgEntry * (1.0 - tpPct / 100.0), "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 5, rsiTF + " RSI(" + str.tostring(rsiLen) + ")", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 5, str.tostring(rsiVal, "#.#"), text_color = rsiVal > rsiLevel ? color.red : color.white, bgcolor = bg)
    table.cell(tbl, 0, 6, "Deployed (USDT)", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 6, str.tostring(totalCost, "#"), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 7, "Open PnL", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 7, inPosition ? "$" + str.tostring(openPnl, "#.##") : "—", text_color = openPnl >= 0 ? color.green : color.red, bgcolor = bg)
    totalPnl = realizedPnl + (inPosition ? openPnl : 0.0)
    table.cell(tbl, 0, 8, "Total PnL", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 8, "$" + str.tostring(totalPnl, "#.##"), text_color = totalPnl >= 0 ? color.green : color.red, bgcolor = bg)

// ─────────────────────────────────────────────────────────────────────────────
// BRAND WATERMARK
// ─────────────────────────────────────────────────────────────────────────────
var table wm = na
if showWM and barstate.islast
    if na(wm)
        wm := table.new(f_pos(wmPosStr), 1, 1, bgcolor = color.new(color.black, 100), border_width = 0)
    table.cell(wm, 0, 0, wmText, text_color = color.new(color.white, wmAlpha), text_size = f_size(wmSizeStr), bgcolor = color.new(color.black, 100))
````
