# [3Commas] TAO RSI Oversold Doubling DCA - Long Indicator

- url: https://www.tradingview.com/script/V0sXokA5-3Commas-TAO-RSI-Oversold-Doubling-DCA-Long-Indicator/
- type: indicator
- pine_id: PUB;bb46f0a7c8384d3980f33fdd43684767
- version: 1.0

## Description

[3Commas] TAO RSI Oversold Doubling DCA - Long Indicator

🔷 What it does:
This is a signal-only indicator that mirrors a TAO dip-buying workflow with an aggressive doubling-martingale safety ladder. It tracks one virtual long position at a time, opened only when TAO prints a deep oversold reading on 4-hour RSI. Five safety orders fire at fixed deviations from base entry (−2%, −5%, −9.5%, −16%, −25%) with sizes doubling on every rung. Exit is a fixed 3% Take Profit from average entry. The indicator computes running average entry, deployed capital, open PnL, and lifetime realized PnL — all derived from honest fill-by-fill bookkeeping. Every event emits a webhook-ready JSON alert payload for direct DCA Bot consumption.
  - Selective oversold entry: 4h RSI < 28.
  - Non-uniform fixed-deviation safety ladder: −2%, −5%, −9.5%, −16%, −25% from base entry.
  - Doubling safety-order sizes: 1k / 2k / 4k / 8k / 16k USDT from a $500 base.
  - Tight 3% Take Profit from the averaged-down entry — quick deal close once price stabilizes.
  - Honest virtual bookkeeping: Open PnL and lifetime Total PnL displayed live on the chart.

🔷 Who is it for:
  - Swing traders running a DCA Bot on TAO who want to buy deep oversold dips.
  - DCA-style traders who want a disciplined averaging ladder that only deepens on serious adverse moves.
  - Bot operators who want a chart-driven signal source that emits per-event JSON ready for a DCA Bot.
  - Traders comfortable with a doubling martingale ladder deploying up to ~31.5% of equity per trade in exchange for a high deal-close rate.

🔷 How does it work:
  Entry Filter: A 4-hour RSI(14) is sampled via request.security with lookahead disabled (no repaint). The entry gate fires when RSI is below 28 (deep oversold) at host-bar close, filtering out shallow dips.
  Base Entry: When the gate is satisfied, the indicator marks a virtual long entry, captures the base entry price, and seeds the cost-basis ledger with the configured base order size (default 500 USDT).
  Safety Order Ladder (Fixed Deviations, Doubling Sizes): After base fill, the indicator monitors price deviation against the base entry. Each safety order has its own fixed deviation from base — not a cumulative ladder. AO1 fills at close ≤ base × 0.98 (−2%); AO2 at −5%; AO3 at −9.5%; AO4 at −16%; AO5 at −25%. USDT sizes double from a 1,000 first AO: 1,000 / 2,000 / 4,000 / 8,000 / 16,000. Each fill updates the running cost-basis and dispatches its own webhook payload.
  Honest Virtual Bookkeeping: Total cost and qty are updated incrementally on every event, so the avg entry, deployed capital, Open PnL, and Total PnL displayed in the status table reflect the actual broker-equivalent position state — no shortcut from base entry, no synthetic averaging.
  Lifetime Total PnL: When the position closes for profit, the realized PnL from that cycle accumulates into a lifetime counter. The status table displays both Open PnL (current cycle, resets on exit) and Total PnL (lifetime, persists across the chart history) — giving traders a real-time read on cumulative performance without a backtest engine.
  Exit: A fixed 3% Take Profit above the running average entry. When close hits the TP target, the close webhook fires, realized PnL accumulates, and the virtual position resets.

🔷 Why it's unique:
  - Selective Oversold Entry: The deal opens only on a deep 4h RSI < 28 print, so capital is committed at genuinely stretched conditions rather than on every dip.
  - Non-Uniform Fixed-Deviation Ladder: Most published DCA tools use formula-based ladders (step × multiplier). This one exposes each AO deviation as a direct input, allowing an asymmetric ladder (2% / 5% / 9.5% / 16% / 25%) where deeper safety orders trigger only on serious adverse moves and the lowest rung sits a full 25% below base.
  - Doubling Martingale: 1 / 2 / 4 / 8 / 16 / 32 size progression scales position capital exponentially if the position runs adverse, but is hard-bounded by the 5-rung ladder.
  - Lifetime PnL Tracking: Open PnL and Total PnL are displayed live on the chart — Open resets per cycle, Total persists across the entire chart history. The indicator gives strategy-tester-equivalent insight without running a backtest.
  - Per-Event Webhook Ledger: Up to seven discrete events per cycle (entry + 5 AO fills + TP), each with its own JSON alert payload. One TradingView alert with "Any alert() function call" drives a DCA Bot end-to-end.

🔷 Considerations Before Using the Indicator:
  Sample Size: The companion strategy's backtest produced 89 closed trades over a ~26-month window — just below the ≥100 floor typically used for statistical confidence. The high win rate and profit factor reflect favorable conditions and the averaging mechanic, not a deterministic edge. Treat them as indicative of how the ladder behaves, not a forward-performance guarantee.
  Aggressive Capital Deployment: If all five safety orders fill, total deployed capital reaches 31,500 USDT = ~31.5% of the default reference equity. The doubling martingale amplifies both upside on recovery and risk if the lower bound breaks. Match the indicator's per-AO allocation to your bot's configuration to keep the avg-entry display honest.
  No Stop Loss: There is no exit signal on adverse moves below AO5 (−25% from base). If price keeps falling, the virtual position holds unhedged until either price recovers to the 3% TP target or the user intervenes. Risk is structurally capped on the bot side by the bounded position ladder; if a hard exchange-side stop is required, configure it on the bot directly.
  Martingale Tail Risk: A doubling ladder that bottoms out at −25% is built for mean-reverting moves. TAO is a high-volatility asset; a sustained directional collapse below −25% leaves the full virtual position open with no further averaging available — the single largest risk in any martingale DCA. Choose regimes where deep-but-recoverable dips are the norm.
  Cross Detection Granularity: Entries and AO fills are evaluated on bar close. A bar that spikes through a level and returns within the same bar may be missed by design — this matches realistic polling behavior and avoids over-signaling on intra-bar wicks.
  Live vs Historical State: The virtual position state is rebuilt from chart history each time the indicator is recompiled. If the indicator is added mid-deployment or the live bot diverges from the signal stream (manual interventions, partial fills), the indicator state may not match the live bot. Toggle the indicator off and on to reset.
  Backtesting Note: This is an indicator, not a strategy. There is no built-in P&L tester — but the live Total PnL counter in the status table gives a running approximation. For full metrics over a ~26-month sample (89 closed trades, 77.53% win rate, 6.29% max drawdown, profit factor 7.259, +7.56% net return), use the companion strategy version on identical parameters.

🔷 How to Use It:
  🔸 Add the indicator to a 4h TAO / USDT chart.
  🔸 Review the RSI entry level, the five AO deviations and sizes, and the Take Profit percentage. Defaults are calibrated for TAO 4h — recalibrate when the asset's volatility regime shifts.
  🔸 Set Base Order Size and AO sizes to match your bot's configuration (the indicator's avg-entry display becomes meaningful when virtual sizing matches real sizing).
  🔸 In the DCA Bot Webhook group, paste the Bot ID, Email Token, and Pair (QUOTE_BASE format, e.g., USDT_TAO).
  🔸 Create an alert on the indicator with "Any alert() function call". Paste the DCA Bot's webhook URL into the alert's Webhook field. The indicator will emit JSON payloads for entry, each safety order, and TP exit — formatted for direct DCA Bot consumption.

🔷 INDICATOR SETTINGS
  Base Order Size (USDT): Virtual order size for the avg-entry / open-PnL computation.
  AO1–AO5 Deviation (%): Fixed distance from base entry where each safety order becomes eligible. Non-uniform by design, reaching −25% at AO5.
  AO1–AO5 Size (USDT): Virtual USDT amount of each safety order. Doubles at each rung by default.
  RSI Timeframe / Length / Less Than: 4h RSI filter for the base entry.
  Take Profit (%): Fixed distance above the running average entry where the virtual long closes.
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
//  TAO RSI Oversold Doubling DCA — Long Indicator
//  Signal-only companion to the TAO Oversold Doubling DCA Long strategy.
//  Tracks a virtual long position (base + up to 5 safety orders on a
//  non-uniform fixed-deviation ladder with size doubling) and fires
//  webhook-ready alerts on every event:
//    • LONG entry — RSI(14) < 28 on 4h
//    • SO fill    — price reaches next fixed deviation from base entry
//    • TP close   — close hits avg × (1 + 3%)
//  No backtest engine — designed to drive a live DCA Bot via webhooks.
//  Calibrated defaults for BYBIT:TAOUSDT.P on 4h timeframe.
// =============================================================================
indicator("[3Commas] TAO RSI Oversold Doubling DCA — Long Indicator", shorttitle = "[3Commas] TAO-OS-I", overlay = true, max_labels_count = 500, max_lines_count = 100)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS (mirror the strategy 1:1)
// ─────────────────────────────────────────────────────────────────────────────
grpBase = "Base Order (Virtual)"
baseOrderSize = input.float(500.0, "Base Order Size (USDT)", minval = 1, group = grpBase, tooltip = "Tracked virtually for avg-entry computation. Real sizing happens on the DCA Bot.")

grpAO = "Averaging Orders (Fixed Deviations + Doubling)"
ao1Dev = input.float(2.0,  "AO1 Deviation from Base (%)", minval = 0.1, step = 0.1, group = grpAO)
ao2Dev = input.float(5.0,  "AO2 Deviation from Base (%)", minval = 0.1, step = 0.1, group = grpAO)
ao3Dev = input.float(9.5,  "AO3 Deviation from Base (%)", minval = 0.1, step = 0.1, group = grpAO)
ao4Dev = input.float(16.0, "AO4 Deviation from Base (%)", minval = 0.1, step = 0.1, group = grpAO)
ao5Dev = input.float(25.0, "AO5 Deviation from Base (%)", minval = 0.1, step = 0.1, group = grpAO)
ao1Size = input.float(1000.0,  "AO1 Size (USDT)", minval = 1, group = grpAO)
ao2Size = input.float(2000.0,  "AO2 Size (USDT)", minval = 1, group = grpAO)
ao3Size = input.float(4000.0,  "AO3 Size (USDT)", minval = 1, group = grpAO)
ao4Size = input.float(8000.0,  "AO4 Size (USDT)", minval = 1, group = grpAO)
ao5Size = input.float(16000.0, "AO5 Size (USDT)", minval = 1, group = grpAO)

grpEntry = "Entry Filters"
rsiTF     = input.timeframe("240", "RSI Timeframe", group = grpEntry, tooltip = "240 = 4 hours.")
rsiLen    = input.int(14, "RSI Length", minval = 2, group = grpEntry)
rsiLevel  = input.float(28.0, "RSI Less Than", minval = 1, maxval = 100, group = grpEntry, tooltip = "Entry arms when 4h RSI is below this level (deep oversold).")

grpExit = "Exit"
tpPct = input.float(3.0, "Take Profit (%)", minval = 0.1, step = 0.1, group = grpExit, tooltip = "Distance above avg entry where the long closes for profit. No trailing.")

grpDate = "Active Window"
useDateFilter = input.bool(false, "Limit Active Period", group = grpDate, tooltip = "When ON, the indicator only fires signals between From and To dates.")
fromDate      = input.time(timestamp("11 Apr 2024 00:00 +0000"), "From", group = grpDate)
toDate        = input.time(timestamp("15 Jun 2026 23:59 +0000"), "To",   group = grpDate)

grpHook = "DCA Bot Webhook"
botId       = input.string("YOUR_BOT_ID",      "Bot ID",            group = grpHook)
emailToken  = input.string("YOUR_EMAIL_TOKEN", "Email Token",       group = grpHook)
pairWebhook = input.string("USDT_TAO",         "Pair (QUOTE_BASE)", group = grpHook)

grpViz = "Visualization"
showLevels     = input.bool(true, "Show AO Ladder",        group = grpViz)
showLines      = input.bool(true, "Plot Avg / TP Lines",   group = grpViz)
showFillLabels = input.bool(true, "Show Fill Labels",      group = grpViz)
showShapes     = input.bool(true, "Show Signal Triangles", group = grpViz)
showTable      = input.bool(true, "Show Status Table",     group = grpViz)

grpWM = "Brand Watermark"
showWM    = input.bool(true,        "Show Watermark", group = grpWM)
wmText    = input.string("3Commas", "Watermark Text", group = grpWM)
wmPosStr  = input.string("Bottom Right", "Position", options = ["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group = grpWM)
wmSizeStr = input.string("Large",   "Text Size", options = ["Tiny","Small","Normal","Large","Huge"], group = grpWM)
wmAlpha   = input.int(70,           "Transparency (0–100)", minval = 0, maxval = 100, group = grpWM)

inWindow = not useDateFilter or (time >= fromDate and time <= toDate)

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

// ENTRY — base order
if inWindow and not inPosition and entrySignal
    inPosition := true
    baseEntry  := close
    aoFilled   := 0
    totalCost  := baseOrderSize
    totalQty   := baseOrderSize / close
    entryEvent := true
    alert(f_msgEntry(), alert.freq_once_per_bar_close)
    if showFillLabels
        label.new(bar_index, low, "LONG ▲", style = label.style_label_up, color = color.new(color.green, 20), textcolor = color.white, size = size.tiny)

// AO trigger — fixed deviation from base entry
if inWindow and inPosition and aoFilled < aoCount and not na(baseEntry)
    nextIdx   = aoFilled + 1
    threshold = array.get(aoDevs, nextIdx - 1)
    triggerPx = baseEntry * (1.0 - threshold / 100.0)
    if close <= triggerPx
        usdt = array.get(aoSizes, nextIdx - 1)
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
        // capture realized PnL before resetting the virtual position
        realizedPnl := realizedPnl + (close - avgEntry) * totalQty
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
        dev = array.get(aoDevs, k - 1)
        px  = baseEntry * (1.0 - dev / 100.0)
        col = k <= aoFilled ? color.new(color.green, 10) : color.new(color.gray, 60)
        wid = k <= aoFilled ? 2 : 1
        ln  = line.new(x1 = bar_index - 100, x2 = bar_index + 8, y1 = px, y2 = px, color = col, style = line.style_dashed, width = wid)
        array.push(aoLines, ln)
        sz = array.get(aoSizes, k - 1)
        label.new(x = bar_index + 8, y = px, text = "AO" + str.tostring(k) + "  -" + str.tostring(dev, "#.#") + "%  $" + str.tostring(sz, "#"), style = label.style_label_left, color = color.new(color.gray, 70), textcolor = color.white, size = size.tiny)

// Status table
if showTable and barstate.islast
    var table tbl = table.new(position = position.top_right, columns = 2, rows = 10, border_width = 1)
    bg  = color.new(color.gray, 30)
    bgH = color.new(color.gray, 0)
    table.cell(tbl, 0, 0, "Status",          text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 1, 0, inPosition ? "In Long (virtual)" : "Flat", text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 0, 1, "AOs Filled",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 1, str.tostring(aoFilled) + " / " + str.tostring(aoCount), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 2, "Base Entry",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 2, na(baseEntry) ? "—" : str.tostring(baseEntry, "#.##"), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 3, "Avg Entry",       text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 3, inPosition and not na(avgEntry) ? str.tostring(avgEntry, "#.##") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 4, "TP Target",       text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 4, inPosition and not na(avgEntry) ? str.tostring(avgEntry * (1.0 + tpPct / 100.0), "#.##") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 5, "Deployed (USDT)", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 5, str.tostring(totalCost, "#"), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 6, rsiTF + " RSI(" + str.tostring(rsiLen) + ")", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 6, str.tostring(rsiVal, "#.#"), text_color = condRSI ? color.green : color.white, bgcolor = bg)
    table.cell(tbl, 0, 7, "Entry Armed",     text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 7, entrySignal ? "YES" : "no", text_color = entrySignal ? color.green : color.gray, bgcolor = bg)
    table.cell(tbl, 0, 8, "Open PnL",        text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 8, inPosition ? "$" + str.tostring(openPnl, "#.##") : "—", text_color = openPnl >= 0 ? color.green : color.red, bgcolor = bg)
    totalPnl = realizedPnl + (inPosition ? openPnl : 0.0)
    table.cell(tbl, 0, 9, "Total PnL",       text_color = color.white, bgcolor = bg)
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
