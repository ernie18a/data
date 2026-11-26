# BB-RSI - Short Indicator

- url: https://www.tradingview.com/script/3mWvFV6y-BB-RSI-Short-Indicator/
- type: indicator
- pine_id: PUB;d61557d127964ae19fe5f96bfbdd0bfd
- version: 1.0

## Description

BB-RSI — Short Indicator

🔷 What it does:
This is a signal-only indicator that mirrors a fade-the-strength short DCA workflow. It tracks one virtual short position at a time, opened only when TWO independent overbought conditions align on a lower timeframe, then scales the position with up to nine safety orders as price ladders higher against entry. The indicator computes a running average entry, total deployed capital, and open PnL from the live fill ledger and renders all of it on the chart. Every event emits a webhook-ready JSON payload tailored for a DCA Bot.
  - Dual confirmation entry: Bollinger Bands %B(20, 2.0) crossing up 1.00 AND RSI(7) crossing up 65, both on 30m.
  - Wide deviation ladder: 0.72% to first safety order, 1.55× step multiplier — last AO at ~63% above base entry.
  - Soft compounding: each safety order is sized 1.03× the previous one.
  - Fixed exit: TP at 2.11% below the running average entry. No trailing, no Stop Loss.
  - Eleven discrete events per cycle (entry + 9 AO fills + TP) — each one fires its own webhook payload.

🔷 Who is it for:
  - Swing traders running a DCA Bot on crypto perpetuals that frequently overshoot resistance.
  - Bot operators who want a chart-driven signal source that emits per-event JSON ready for a DCA Bot.
  - Traders who want to monitor an evolving short position — base entry, owned AO levels, deployed capital, open PnL — directly on the chart without the strategy-tester overhead.
  - Risk-conscious operators building a high-confidence, low-drawdown defensive short into a diversified portfolio.

🔷 How does it work:
  Bollinger Bands %B Filter: A 30-minute Bollinger Bands(20, 2.0) is sampled via request.security and converted to %B = (close − lower) / (upper − lower). The BB gate fires when %B crosses up the configured level (default 1.00 — price exiting the upper band) at host-bar close.
  RSI Filter: A 30-minute RSI(7) is sampled in parallel. The RSI gate fires when RSI crosses up the configured level (default 65 — entering overbought) at host-bar close.
  Entry: When both gates align at the same host-bar close, the indicator marks a virtual short entry, captures the base entry price, seeds the cost-basis ledger, and fires the entry webhook payload.
  Safety Order Ladder: After base entry, the indicator monitors close price upward against the position. When close reaches base entry × (1 + cumulative deviation), the k-th safety order is marked filled, cost-basis is updated, and the AO webhook payload is fired. Cumulative deviation grows by the step multiplier (default 1.55): 0.72%, 1.84%, 3.57%, 6.25%, 10.40%, 16.48%, 25.90%, 40.51%, 63.14%. AO USDT size grows by 1.03× per fill — soft compounding rather than aggressive martingale.
  Honest Virtual Bookkeeping: Total cost and total qty are updated incrementally on every event, so the avg entry, deployed capital, and open PnL displayed in the status table reflect the actual broker-equivalent position state — no shortcut from base entry, no synthetic averaging.
  Exit: A fixed Take Profit at 2.11% below the running average entry. When close reaches the TP target, the close webhook payload fires and the virtual position resets.

🔷 Why it's unique:
  - Dual-Filter Confirmation: Two independent signals on the same lower timeframe must align. %B captures volatility expansion beyond statistical bounds; RSI captures momentum overheating. Together they filter out the either-or noise that triggers single-condition strategies.
  - Soft Compounding Ladder: The 1.03× size multiplier is much gentler than typical martingale (1.5–2.0×). It scales position size with adverse drift but doesn't blow up capital deployment if all safety orders fill.
  - Fill-by-Fill Avg Entry: The orange avg-entry line is derived from running totals updated on every event — what you see is what the broker-equivalent position would actually have.
  - Per-Event Webhook Ledger: Eleven distinct events per cycle, each with its own JSON alert payload. The indicator drives a DCA Bot end-to-end through a single TradingView alert.

🔷 Considerations Before Using the Indicator:
  Market & Timeframe: Designed for liquid crypto perpetuals on 30m–1h ranges. Default thresholds are calibrated for ATOMUSDT.P 30m. Strongly trending markets will fill the entire 9-AO ladder and hold the short while price grinds higher — the dual filter limits exposure to confirmed overbought conditions, but a regime shift to a strong trend requires manual oversight.
  Cross Detection Granularity: Entries and AO fills are evaluated on bar close. A bar that spikes through a level and returns within the same bar may be missed by design — this matches realistic polling behavior and avoids over-signaling on intra-bar wicks.
  Live vs Historical State: The virtual position state is rebuilt from chart history each time the indicator is recompiled. If the indicator is added mid-deployment or the live bot diverges from the signal stream (manual interventions, partial fills), the indicator state may not match the live bot. Toggle the indicator off and on to reset.
  Funding Rates (Perpetuals): The indicator does not account for perpetual funding rates. Sustained positive funding (longs pay shorts) improves live performance; sustained negative funding degrades it. Review the historical funding pattern before live deployment.
  No Stop Loss: There is no exit signal on adverse moves beyond the 9-AO ladder. Risk is structurally capped on the bot side by the bounded position-size ladder. If a hard exchange-side stop is required, configure it on the bot directly.
  Backtesting Note: This is an indicator, not a strategy. There is no built-in P&L tester. For performance metrics over a 2.5-year sample (~267 closed trades, 79.78% win rate, 1.53% max drawdown, profit factor 6.23), use the companion strategy version on identical parameters.

🔷 How to Use It:
  🔸 Add the indicator to a 30m chart on the perpetual pair you want to trade.
  🔸 Review the BB filter (timeframe / period / deviation / level) and the RSI filter (timeframe / length / level). Defaults are calibrated for ATOMUSDT.P 30m — recalibrate per asset before deploying.
  🔸 Set the AO ladder parameters (count, first AO size, step, multipliers) and the Take Profit percentage to match your bot's configuration.
  🔸 In the DCA Bot Webhook group, paste the Bot ID, Email Token, and Pair (QUOTE_BASE format, e.g., USDT_ATOM).
  🔸 Create an alert on the indicator with "Any alert() function call". Paste the DCA Bot's webhook URL into the alert's Webhook field. The indicator will emit JSON payloads for short entry, each safety order, and TP exit — formatted for direct DCA Bot consumption.

🔷 INDICATOR SETTINGS
  Base Order Size (USDT): Virtual order size for the avg-entry computation. Real sizing happens on the bot.
  First AO Size (USDT): Virtual size of the first safety order; subsequent AOs scale by the Size Multiplier.
  Order Size Multiplier: Factor that grows each subsequent safety order's USDT size.
  Averaging Orders per Trade: Maximum number of safety orders per deal (default 9).
  Deviation to First AO (%): Distance from base entry at which AO1 becomes eligible.
  Deviation Step Multiplier: Ladder factor that widens each subsequent deviation step.
  BB Timeframe / Period / Deviation / Level: Lower-timeframe Bollinger Bands %B filter on the host symbol.
  RSI Timeframe / Length / Level: Lower-timeframe RSI filter on the host symbol.
  Take Profit (%): Fixed distance below the running average entry where the virtual short closes.
  DCA Bot Webhook: Bot ID, Email Token, and Pair fields injected into every alert payload.
  Visualization: Toggle DCA Ladder, Avg Entry / TP plot lines, fill labels, signal triangles, status table.
  Brand Watermark: Configurable text, position, size, and transparency.

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.

__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=6
// =============================================================================
//  BB-RSI Overbought DCA — Short Indicator
//  Signal-only companion to the BB-RSI Overbought Short strategy. Tracks a
//  virtual short position (base + up to 9 safety orders) and fires webhook-
//  ready alerts on every event:
//    • SHORT entry — BB %B cross up upper band AND RSI cross up overbought
//    • AO fill — price reaches the next deviation rung above base entry
//    • TP close — close drops to avg entry × (1 − TP%)
//  No backtest engine — designed to drive a live DCA Bot via webhooks.
//  Calibrated defaults for BYBIT:ATOMUSDT.P on 30m timeframe.
// =============================================================================
indicator("BB-RSI Overbought DCA — Short Indicator", shorttitle = "BBRSI-I", overlay = true, max_labels_count = 500, max_lines_count = 100)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS (mirror the strategy 1:1)
// ─────────────────────────────────────────────────────────────────────────────
grpSize = "Order Sizing (Virtual)"
baseOrderSize = input.float(80.0,  "Base Order Size (USDT)", minval = 1, group = grpSize, tooltip = "Tracked virtually for avg-entry computation. Real sizing happens on the DCA Bot.")
aoSize        = input.float(80.0,  "First AO Size (USDT)", minval = 1, group = grpSize)
aoSizeMult    = input.float(1.03,  "Order Size Multiplier", minval = 1.0, step = 0.01, group = grpSize)

grpAO = "Averaging Orders"
aoCount    = input.int(9, "Averaging Orders per Trade", minval = 0, maxval = 15, group = grpAO)
aoStep     = input.float(0.72, "Deviation to First AO (%)", minval = 0.1, step = 0.01, group = grpAO)
aoStepMult = input.float(1.55, "Deviation Step Multiplier", minval = 1.0, step = 0.05, group = grpAO)

grpBB = "Bollinger Bands %B Filter"
bbTF     = input.timeframe("30", "BB Timeframe", group = grpBB)
bbPeriod = input.int(20, "BB Period", minval = 2, group = grpBB)
bbDev    = input.float(2.0, "BB Deviation", minval = 0.1, step = 0.1, group = grpBB)
bbLevel  = input.float(1.0, "BB %B Crossing Up Level", step = 0.01, group = grpBB, tooltip = "Entry arms when %B crosses up this level. 1.0 = price exiting upper Bollinger band.")

grpRSI = "RSI Filter"
rsiTF    = input.timeframe("30", "RSI Timeframe", group = grpRSI)
rsiLen   = input.int(7, "RSI Length", minval = 2, group = grpRSI)
rsiLevel = input.float(65.0, "RSI Crossing Up Level", minval = 1, maxval = 100, group = grpRSI, tooltip = "Entry arms when RSI crosses up this level (entering overbought).")

grpExit = "Exit"
tpPct = input.float(2.11, "Take Profit (%)", minval = 0.1, step = 0.01, group = grpExit, tooltip = "Distance below avg entry where the short closes for profit.")

grpHook = "DCA Bot Webhook"
botId       = input.string("YOUR_BOT_ID",      "Bot ID",            group = grpHook)
emailToken  = input.string("YOUR_EMAIL_TOKEN", "Email Token",       group = grpHook)
pairWebhook = input.string("USDT_ATOM",        "Pair (QUOTE_BASE)", group = grpHook)

grpViz = "Visualization"
showLevels     = input.bool(true, "Show DCA Ladder",        group = grpViz)
showEntryLines = input.bool(true, "Plot Avg Entry / TP",    group = grpViz)
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
f_bbPercentB(int len, float mult) =>
    basis = ta.sma(close, len)
    dev   = mult * ta.stdev(close, len)
    upper = basis + dev
    lower = basis - dev
    (close - lower) / (upper - lower)

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
bbB    = request.security(syminfo.tickerid, bbTF,  f_bbPercentB(bbPeriod, bbDev), lookahead = barmerge.lookahead_off)
rsiVal = request.security(syminfo.tickerid, rsiTF, ta.rsi(close, rsiLen),         lookahead = barmerge.lookahead_off)

bbCrossUp   = bbB[1]    < bbLevel  and bbB    >= bbLevel
rsiCrossUp  = rsiVal[1] < rsiLevel and rsiVal >= rsiLevel
entrySignal = bbCrossUp and rsiCrossUp

// ─────────────────────────────────────────────────────────────────────────────
// VIRTUAL POSITION STATE
// ─────────────────────────────────────────────────────────────────────────────
var bool  inPosition = false
var float baseEntry  = na
var int   aoFilled   = 0
var float totalCost  = 0.0   // USDT deployed across base + filled AOs
var float totalQty   = 0.0   // asset units across base + filled AOs

var bool entryEvent = false
var bool aoEvent    = false
var bool exitEvent  = false
entryEvent := false
aoEvent    := false
exitEvent  := false

// ENTRY — base order
if not inPosition and entrySignal
    inPosition := true
    baseEntry  := close
    aoFilled   := 0
    totalCost  := baseOrderSize
    totalQty   := baseOrderSize / close
    entryEvent := true
    alert(f_msgEntry(), alert.freq_once_per_bar_close)
    if showFillLabels
        label.new(bar_index, high, "SHORT ▼", style = label.style_label_down, color = color.new(color.red, 20), textcolor = color.white, size = size.tiny)

// AO trigger — price ladders UP against the short
if inPosition and aoFilled < aoCount and not na(baseEntry)
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

// EXIT — fixed TP
if inPosition and not na(avgEntry)
    tpPrice = avgEntry * (1.0 - tpPct / 100.0)
    if close <= tpPrice
        exitEvent  := true
        alert(f_msgClose(), alert.freq_once_per_bar_close)
        if showFillLabels
            label.new(bar_index, low, "TP ▲", style = label.style_label_up, color = color.new(color.green, 20), textcolor = color.white, size = size.tiny)
        // reset virtual position
        inPosition := false
        baseEntry  := na
        aoFilled   := 0
        totalCost  := 0.0
        totalQty   := 0.0

openPnl = totalQty > 0 and not na(avgEntry) ? (avgEntry - close) * totalQty : 0.0

// ─────────────────────────────────────────────────────────────────────────────
// PLOTS & SIGNAL SHAPES
// ─────────────────────────────────────────────────────────────────────────────
plot(showEntryLines and inPosition and not na(avgEntry) ? avgEntry : na, title = "Avg Entry", color = color.new(color.orange, 0), linewidth = 2, style = plot.style_linebr)
plot(showEntryLines and inPosition and not na(avgEntry) ? avgEntry * (1.0 - tpPct / 100.0) : na, title = "TP Target", color = color.new(color.green, 0), linewidth = 1, style = plot.style_linebr)

plotshape(showShapes and entryEvent, title = "Short Entry", location = location.abovebar, style = shape.triangledown, color = color.new(color.red,    0), size = size.small)
plotshape(showShapes and aoEvent,    title = "AO Fill",     location = location.abovebar, style = shape.triangledown, color = color.new(color.orange, 0), size = size.tiny)
plotshape(showShapes and exitEvent,  title = "TP Hit",      location = location.belowbar, style = shape.triangleup,   color = color.new(color.green,  0), size = size.small)

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
        col = k <= aoFilled ? color.new(color.red, 10) : color.new(color.gray, 60)
        wid = k <= aoFilled ? 2 : 1
        ln  = line.new(x1 = bar_index - 100, x2 = bar_index + 8, y1 = px, y2 = px, color = col, style = line.style_dashed, width = wid)
        array.push(aoLines, ln)
        label.new(x = bar_index + 8, y = px, text = "AO" + str.tostring(k) + "  +" + str.tostring(dev, "#.##") + "%", style = label.style_label_left, color = color.new(color.gray, 70), textcolor = color.white, size = size.tiny)

// Status table
if showTable and barstate.islast
    var table tbl = table.new(position = position.top_right, columns = 2, rows = 8, border_width = 1)
    bg  = color.new(color.gray, 30)
    bgH = color.new(color.gray, 0)
    table.cell(tbl, 0, 0, "Status",          text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 1, 0, inPosition ? "In Short (virtual)" : "Flat", text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 0, 1, "AOs Filled",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 1, str.tostring(aoFilled) + " / " + str.tostring(aoCount), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 2, "Base Entry",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 2, na(baseEntry) ? "—" : str.tostring(baseEntry, "#.####"), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 3, "Avg Entry",       text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 3, inPosition and not na(avgEntry) ? str.tostring(avgEntry, "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 4, "TP Target",       text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 4, inPosition and not na(avgEntry) ? str.tostring(avgEntry * (1.0 - tpPct / 100.0), "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 5, "Deployed (USDT)", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 5, str.tostring(totalCost, "#.##"), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 6, bbTF + " BB %B",   text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 6, str.tostring(bbB, "#.###"), text_color = bbB > bbLevel ? color.red : color.white, bgcolor = bg)
    table.cell(tbl, 0, 7, rsiTF + " RSI(" + str.tostring(rsiLen) + ")", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 7, str.tostring(rsiVal, "#.#"), text_color = rsiVal > rsiLevel ? color.red : color.white, bgcolor = bg)

// ─────────────────────────────────────────────────────────────────────────────
// BRAND WATERMARK
// ─────────────────────────────────────────────────────────────────────────────
var table wm = na
if showWM and barstate.islast
    if na(wm)
        wm := table.new(f_pos(wmPosStr), 1, 1, bgcolor = color.new(color.black, 100), border_width = 0)
    table.cell(wm, 0, 0, wmText, text_color = color.new(color.white, wmAlpha), text_size = f_size(wmSizeStr), bgcolor = color.new(color.black, 100))
````
