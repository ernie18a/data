# SOL RSI DCA - Long Indicator

- url: https://www.tradingview.com/script/g3fcGD6G-SOL-RSI-DCA-Long-Indicator/
- type: indicator
- pine_id: PUB;042d53753aec4dd0b23ee0c194d61672
- version: 1.0

## Description

SOL RSI DCA - Long Indicator

🔷 What it does:
This is a signal-only indicator that mirrors a long-only DCA workflow on SOL. It tracks one virtual long position at a time, opened while higher-timeframe momentum is depressed, then averages the position down on a measured geometric price-deviation ladder with up to three averaging orders. The base entry arms whenever the 1-hour RSI(14) sits below a configurable level (default 44). Averaging is price-driven only — no extra momentum gate — matching the source bot configuration. Exit is a fixed Take Profit at 2.4% above average entry. Every event emits a webhook-ready JSON payload for a DCA Bot.
  - HTF RSI entry gate: base order arms while 1h RSI(14) is below the threshold (Less Than condition).
  - Geometric averaging ladder: deviations −2.50%, −5.75%, −9.98%; sizes 87.5, 109.4, 136.7 USDT on a 1.3× deviation step × 1.25× size step.
  - Fixed Take Profit: 2.4% above running average entry, no trailing.
  - Honest virtual bookkeeping: total cost and qty updated incrementally on every fill — avg entry, deployed capital, open PnL, and cumulative realized PnL displayed live.
  - Five discrete events per cycle (entry + 3 AO fills + TP), each with its own webhook payload.

🔷 Who is it for:
  - Swing traders running a DCA Bot on SOL who want systematic long exposure when momentum is soft, scaling in if the dip deepens.
  - Bot operators who want a chart-driven signal source that emits per-event JSON ready for a DCA Bot.
  - DCA-style traders who prefer a measured geometric ladder over an aggressive doubling schedule.
  - Traders who want to monitor an evolving DCA position — base entry, owned AO levels, deployed capital, open PnL, realized PnL, live RSI reading — directly on the chart without the strategy-tester overhead.

🔷 How does it work:
  Entry RSI Filter (HTF Oversold): A 1-hour RSI(14) is sampled via request.security with lookahead disabled (no repaint). The base order arms whenever this RSI is below the configured level (default 44). At host-bar close, if the indicator is flat, the virtual long position opens.
  Averaging Order Ladder (Price-Driven): After the base fill, the indicator watches price deviation against the position. The k-th averaging order fires when close ≤ base entry × (1 − cumulative deviation). Cumulative deviation grows by the 1.3× step multiplier: 2.50%, 5.75%, 9.98%. Each averaging order's virtual size grows by the 1.25× size multiplier: 87.5, 109.4, 136.7 USDT. Averaging is gated by price only — no extra RSI condition, matching the source bot configuration.
  Honest Virtual Bookkeeping: Total cost and qty are updated incrementally on every fill, so the avg entry, deployed capital, open PnL, and cumulative realized PnL displayed in the status table reflect the actual broker-equivalent position state — no shortcut from base entry, no synthetic averaging.
  Exit: A fixed Take Profit at 2.4% above the running average entry. When close hits the TP target, the close webhook fires, the realized PnL accumulator banks the gain, and the virtual position resets.

🔷 Why it's unique:
  - HTF RSI Entry Gate: The base order keys off a 1-hour RSI(14) rather than the chart timeframe, so entries are anchored to the higher-timeframe momentum picture instead of intrabar noise.
  - Measured Geometric Ladder: A 1.3× deviation step paired with a 1.25× size step keeps the average entry compounding controlled — the position deepens gradually rather than ballooning, which keeps maximum deployment near 5% of equity.
  - Fill-by-Fill Avg Entry: The orange avg-entry line is derived from running totals updated on every event — what you see is what the broker-equivalent position would actually have.
  - Realized PnL Readout: The status table shows cumulative realized PnL banked across closed cycles, so the chart reflects how the workflow has performed over the visible history, not just the open position.
  - Per-Event Webhook Ledger: Five distinct events per cycle, each with its own JSON alert payload. The indicator drives a DCA Bot end-to-end through a single TradingView alert.

🔷 Considerations Before Using the Indicator:
  Market & Timeframe: Designed for liquid crypto pairs. Default thresholds are calibrated for BINANCE:SOLUSDT spot, with the RSI filter on 1h. Run on a 1h chart (or lower for finer averaging-order fills). Different pairs may need RSI level and deviation ladder tuning.
  Entry Is a Level, Not a Cross: The base order uses a Less Than condition (RSI < 44), matching the source bot. After a Take Profit, if RSI is still below 44 the indicator can immediately reopen a new virtual deal. This produces more frequent re-entries than a cross-down trigger — intended behavior, but review it against your risk appetite.
  Cross Detection Granularity: Entries and AO fills are evaluated on bar close. A bar that spikes through a level and returns within the same bar may be missed by design — this matches realistic polling behavior and avoids over-signaling on intra-bar wicks.
  Live vs Historical State: The virtual position state is rebuilt from chart history each time the indicator is recompiled. If the indicator is added mid-deployment or the live bot diverges from the signal stream (manual interventions, partial fills), the indicator state may not match the live bot. Toggle the indicator off and on to reset.
  Capital Deployment: If all three averaging orders fill, the virtual position scales from 200 USDT base to ~534 USDT total. Match the indicator's per-order allocation to your bot's configuration to keep the avg-entry display honest.
  No Stop Loss: There is no exit signal on adverse moves beyond the 3-AO ladder. Risk is structurally capped on the bot side by the bounded position-size ladder. If a hard exchange-side stop is required, configure it on the bot directly.
  Strong Downtrends: Like any dip-buying setup, this is positioned for mean reversions, not waterfall declines. In a sustained downtrend the ladder fills out and the position holds underwater until price recovers to the 2.4% TP above average. The bounded ladder limits the size of that exposure, but underwater hold time can still extend.
  Backtesting Note: This is an indicator, not a strategy. There is no built-in P&L tester. For performance metrics over a ~3.5-month sample (29 closed trades, 86.21% win rate, 0.63% max drawdown, profit factor 22.256, +0.83% net return), use the companion strategy version on identical parameters. The 29-trade sample is well below the typical ≥100 floor for statistical confidence, and the high-win/low-frequency profile rests on a fixed 2.4% TP being hit most of the time — re-run on a 12+ month window for a more robust validation before drawing firm conclusions.

🔷 How to Use It:
  🔸 Add the indicator to a 1h chart on the crypto pair you want to trade.
  🔸 Review the entry RSI filter (timeframe / length / level), the 3-AO ladder parameters, and the Take Profit percentage. Defaults are calibrated for SOLUSDT 1h — recalibrate per asset before deploying.
  🔸 Set Base Order Size and AO sizes to match your bot's configuration (the indicator's avg-entry display becomes meaningful when virtual sizing matches real sizing).
  🔸 In the DCA Bot Webhook group, paste the Bot ID, Email Token, and Pair (QUOTE_BASE format, e.g., USDT_SOL).
  🔸 Create an alert on the indicator with "Any alert() function call". Paste the DCA Bot's webhook URL into the alert's Webhook field. The indicator will emit JSON payloads for entry, each averaging order, and TP exit — formatted for direct DCA Bot consumption.

🔷 INDICATOR SETTINGS
  Base Order Size (USDT): Virtual order size for the avg-entry / open-PnL computation.
  Averaging Orders per Trade: Maximum number of averaging orders per cycle (default 3).
  First AO Size (USDT): Virtual size of the first averaging order; subsequent AOs scale by the Size Multiplier.
  Deviation to First AO (%): Distance from base entry at which AO1 becomes eligible.
  Deviation Step Multiplier: Ladder factor that widens each subsequent deviation step.
  Order Size Multiplier: Factor that grows each subsequent averaging order's USDT size.
  Entry RSI Timeframe / Length / Level: Higher-timeframe RSI filter that arms the base entry (Less Than condition).
  Take Profit (%): Fixed distance above the running average entry where the virtual long closes.
  DCA Bot Webhook: Bot ID, Email Token, and Pair fields injected into every alert payload.
  Visualization: Toggle AO Ladder, Avg / TP plot lines, fill labels, signal triangles, status table (including cumulative realized PnL).
  Brand Watermark: Configurable text, position, size, and transparency.

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.

__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=6
// =============================================================================
//  SOL RSI DCA — Long Indicator
//  Signal-only companion to the SOL RSI DCA Long strategy. Tracks a virtual
//  long position (base + up to 3 averaging orders on a 1.3× deviation × 1.25×
//  size ladder) and fires webhook-ready alerts on every event:
//    • LONG entry — 1h RSI(14) below the configured level
//    • AO fill    — price reaches the next deviation rung
//    • TP close   — close hits avg × (1 + TP%)
//  No backtest engine — designed to drive a live DCA Bot via webhooks.
//  Calibrated defaults for BINANCE:SOLUSDT (run on 1h timeframe).
// =============================================================================
indicator("SOL RSI DCA — Long Indicator", shorttitle = "SOL-I", overlay = true, max_labels_count = 500, max_lines_count = 100)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS (mirror the strategy 1:1)
// ─────────────────────────────────────────────────────────────────────────────
grpBase = "Base Order (Virtual)"
baseOrderSize = input.float(200.0, "Base Order Size (USDT)", minval = 1, group = grpBase, tooltip = "Tracked virtually for avg-entry computation. Real sizing happens on the DCA Bot.")

grpAO = "Averaging Orders"
aoCount    = input.int(3, "Averaging Orders per Trade", minval = 0, maxval = 10, group = grpAO)
aoSize     = input.float(87.5, "First AO Size (USDT)", minval = 1, group = grpAO, tooltip = "Preserves source bot ratio AO1/Base = 0.4375.")
aoStep     = input.float(2.5, "Deviation to First AO (%)", minval = 0.1, step = 0.1, group = grpAO)
aoStepMult = input.float(1.3, "Deviation Step Multiplier", minval = 1.0, step = 0.1, group = grpAO)
aoSizeMult = input.float(1.25, "Order Size Multiplier", minval = 1.0, step = 0.05, group = grpAO)

grpEntry = "Entry RSI Filter"
entryTF       = input.timeframe("60", "RSI Timeframe", group = grpEntry)
entryRsiLen   = input.int(14, "RSI Length", minval = 2, group = grpEntry)
entryRsiLevel = input.float(44.0, "RSI Less Than Level", minval = 1, maxval = 100, group = grpEntry, tooltip = "Base order arms while HTF RSI is below this level (Less Than condition, matching the source bot).")

grpExit = "Exit"
tpPct = input.float(2.4, "Take Profit (%)", minval = 0.1, step = 0.1, group = grpExit)

grpDate = "Active Window"
useDateFilter = input.bool(true, "Limit Active Period", group = grpDate, tooltip = "When ON, the indicator only fires signals between From and To dates. Before From: no events; after To: no new events.")
fromDate      = input.time(timestamp("16 Feb 2026 00:00 +0000"), "From", group = grpDate)
toDate        = input.time(timestamp("01 Jun 2026 23:59 +0000"), "To",   group = grpDate)

grpHook = "DCA Bot Webhook"
botId       = input.string("YOUR_BOT_ID",      "Bot ID",            group = grpHook)
emailToken  = input.string("YOUR_EMAIL_TOKEN", "Email Token",       group = grpHook)
pairWebhook = input.string("USDT_SOL",         "Pair (QUOTE_BASE)", group = grpHook)

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
// HTF RSI FILTER (no repaint)
// ─────────────────────────────────────────────────────────────────────────────
entryRsi  = request.security(syminfo.tickerid, entryTF, ta.rsi(close, entryRsiLen), lookahead = barmerge.lookahead_off)
entryCond = entryRsi < entryRsiLevel

inWindow = not useDateFilter or (time >= fromDate and time <= toDate)

// ─────────────────────────────────────────────────────────────────────────────
// VIRTUAL POSITION STATE
// ─────────────────────────────────────────────────────────────────────────────
var bool  inPosition  = false
var float baseEntry   = na
var int   aoFilled    = 0
var float totalCost   = 0.0   // USDT deployed across base + filled AOs
var float totalQty    = 0.0   // asset units across all fills
var float realizedPnl = 0.0   // cumulative realized profit from closed deals (USDT)

var bool entryEvent = false
var bool aoEvent    = false
var bool tpEvent    = false
entryEvent := false
aoEvent    := false
tpEvent    := false

// ENTRY — base order (1h RSI below level)
if inWindow and not inPosition and entryCond
    inPosition := true
    baseEntry  := close
    aoFilled   := 0
    totalCost  := baseOrderSize
    totalQty   := baseOrderSize / close
    entryEvent := true
    alert(f_msgEntry(), alert.freq_once_per_bar_close)
    if showFillLabels
        label.new(bar_index, low, "LONG ▲", style = label.style_label_up, color = color.new(color.green, 20), textcolor = color.white, size = size.tiny)

// AO trigger — price ladders DOWN against the long (price-only, no extra gate)
if inWindow and inPosition and aoFilled < aoCount and not na(baseEntry)
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
        realizedPnl := realizedPnl + (close - avgEntry) * totalQty
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
    table.cell(tbl, 1, 2, na(baseEntry) ? "—" : str.tostring(baseEntry, "#.####"), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 3, "Avg Entry",       text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 3, inPosition and not na(avgEntry) ? str.tostring(avgEntry, "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 4, "TP Target",       text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 4, inPosition and not na(avgEntry) ? str.tostring(avgEntry * (1.0 + tpPct / 100.0), "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 5, "Deployed (USDT)", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 5, str.tostring(totalCost, "#.##"), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 6, entryTF + " RSI",  text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 6, str.tostring(entryRsi, "#.#"), text_color = entryCond ? color.green : color.white, bgcolor = bg)
    table.cell(tbl, 0, 7, "Open PnL",        text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 7, inPosition ? str.tostring(openPnl, "#.##") + " USDT" : "—", text_color = openPnl >= 0 ? color.green : color.red, bgcolor = bg)
    table.cell(tbl, 0, 8, "Realized PnL",    text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 8, str.tostring(realizedPnl, "#.##") + " USDT", text_color = realizedPnl >= 0 ? color.green : color.red, bgcolor = bg)

// ─────────────────────────────────────────────────────────────────────────────
// BRAND WATERMARK
// ─────────────────────────────────────────────────────────────────────────────
var table wm = na
if showWM and barstate.islast
    if na(wm)
        wm := table.new(f_pos(wmPosStr), 1, 1, bgcolor = color.new(color.black, 100), border_width = 0)
    table.cell(wm, 0, 0, wmText, text_color = color.new(color.white, wmAlpha), text_size = f_size(wmSizeStr), bgcolor = color.new(color.black, 100))
````
