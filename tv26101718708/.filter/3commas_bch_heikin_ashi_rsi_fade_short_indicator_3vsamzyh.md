# [3Commas] BCH Heikin Ashi RSI Fade - Short Indicator

- url: https://www.tradingview.com/script/3VSAMzYh-3Commas-BCH-Heikin-Ashi-RSI-Fade-Short-Indicator/
- type: indicator
- pine_id: PUB;d8127feb71a246b1919b3df14d680a08
- version: 1.0

## Description

[3Commas] BCH Heikin Ashi RSI Fade — Short Indicator

🔷 What it does:
This is the signal-only companion to the BCH Heikin Ashi RSI Fade Short strategy. It tracks a virtual short position and fires webhook-ready alerts on three events — entry, Take Profit, and Stop Loss — without running a backtest engine. A virtual short is opened when the 15-minute Heikin Ashi prints a defined number of consecutive bullish candles AND the long-window RSI is above a soft-bias threshold on the same timeframe. The trade is then closed on a fixed Take Profit OR a fixed Stop Loss; no trailing, no averaging, no discretionary management.
  - Tracks one virtual short at a time, sized at a configurable base order (default 280 USDT, used only for the on-chart PnL display).
  - Dual confirmation entry: RSI(100) on 15m > 46 AND 7 consecutive Heikin Ashi bullish candles on 15m.
  - Hard exit pair: TP at −2.1% from entry, SL at +2.5%.
  - Every entry and exit emits a webhook-ready JSON alert payload for direct DCA Bot consumption.

🔷 Who is it for:
  - Bot operators who want to drive a DCA Bot configured for one-shot short deals directly from TradingView alerts, without a strategy backtest object on the chart.
  - Traders who want a clean, mechanical short signal with no averaging and no discretionary management once in trade.
  - Swing traders looking for systematic short exposure on BCH when local upward thrusts overrun.
  - Operators who prefer a lightweight signal overlay with a live status table over a full strategy tester.

🔷 How does it work:
  RSI Bias Filter: A long-window RSI(100) is sampled from the 15-minute timeframe via request.security with lookahead disabled (no repaint). The threshold (default 46) sits just below the midline, so the filter is satisfied during prolonged bullish drift — exactly the regime where fading strength has the highest expectancy. When RSI falls below 46, the bias is considered to have flipped bearish and the indicator stops arming new shorts.
  Heikin Ashi Streak Trigger: A 15-minute Heikin Ashi stream is sampled in parallel, and the indicator counts the number of consecutive same-direction HA candles using ta.barssince. When the bullish streak reaches the configured length (default 7), the trigger is armed. The default Bullish direction defines the fade-the-strength mode; switching to Bearish converts the logic into a trend-follow short.
  Entry: When BOTH conditions are true at bar close and no virtual position is open, the indicator records the entry price, computes the TP and SL levels, fires the entry alert, and marks a SHORT label and triangle on the chart.
  Exit: On each bar close while in position, the indicator checks close against the TP and SL levels. The first level reached closes the virtual short, fires the close alert, marks a TP or SL label, and accumulates realized PnL. This close-based detection matches what a polling bot sees at bar close.

🔷 Why it's unique:
  - Dual-Signal Confirmation: A smoothed RSI(100) filters the regime bias while Heikin Ashi times the entry. RSI on a 100-bar window changes slowly and Heikin Ashi reacts to the immediate streak, so the two conditions cannot be satisfied by the same short-lived noise — every entry requires alignment of both.
  - Fade-or-Follow Switch: A single input flips the HA direction filter between Bullish (fade strength, default) and Bearish (follow trend). The same engine handles two opposing signal archetypes.
  - Live Status Table: An on-chart table shows position status, entry price, TP/SL levels, live RSI and HA streak values, and an entry-armed flag — so the current state of the virtual position is always visible at a glance.
  - DCA Bot Integration: Each event emits a fully-formed JSON alert payload tagged with the action type, so the indicator can drive a DCA Bot configured for one-shot deals directly through TradingView alerts.

🔷 Considerations Before Using the Indicator:
  Signal-Only Design: This is an indicator, not a strategy. It does not place orders or run a backtest engine — it tracks a virtual position purely to time alerts and display state. The base order size input is virtual and feeds only the on-chart PnL display; real position sizing happens on the bot.
  Market & Timeframe: Calibrated for BCHUSDT on the 15-minute timeframe. The RSI-and-Heikin-Ashi combination is portable to other liquid crypto pairs that respect mean-reversion behavior, but the filter thresholds (RSI level, HA streak length) should be reviewed before redeployment. Live shorting requires a margin or perpetual venue.
  Reference Performance: Because behavior mirrors the companion strategy 1:1, the strategy's backtest is a useful reference. Over a 177-trade backtest on BCHUSDT 15m (November 19, 2025 — June 3, 2026), the matching strategy logic returned +0.88% with a 0.52% maximum equity drawdown, 61.02% of trades profitable (108 / 177), and a profit factor of 1.169. The 177-trade sample is above the ~100-trade floor for statistical relevance. The value proposition is structural risk capping over a meaningful sample, not aggressive alpha.
  Trending Markets: In strong sustained uptrends, the indicator will continue to arm short entries and will register stop-outs as price grinds higher. This is by design — the logic is positioned for ranges and rotations, not breakouts. The RSI(100) > 46 filter limits exposure to confirmed bullish regimes only, which is where fading has an edge; a regime change to a stronger trend will require manual oversight or a wider Stop Loss.
  Past Performance: Past results do not guarantee future performance. Always demo-test before deploying live capital, and size as one part of a diversified portfolio.

🔷 How to Use It:
  🔸 Adjust Settings: Open the indicator inputs and review the Base Order Size (virtual), the RSI filter (timeframe / length / condition / level), and the Heikin Ashi filter (timeframe / streak length / direction). Defaults are calibrated for BCHUSDT 15m — recalibrate per asset before deploying.
  🔸 Fill the Webhook Fields: Enter your DCA Bot's Bot ID, Email Token, and Pair (QUOTE_BASE) into the DCA Bot Webhook inputs. These values are injected into every alert payload.
  🔸 Create the alert: Add one alert on the indicator using "Any alert() function call". Paste the DCA Bot's webhook URL into the alert's Webhook field. The indicator will emit JSON payloads for short entry and close — formatted for direct DCA Bot consumption.

🔷 INDICATOR SETTINGS
  Base Order Size (USDT): Virtual size used only for the status-table / PnL display. Real sizing happens on the bot.
  RSI Timeframe / Length / Condition / Level: RSI bias filter applied to the host symbol.
  HA Timeframe / Streak / Direction: Heikin Ashi consecutive-candle trigger. Direction defines fade (Bullish) vs follow (Bearish) mode.
  Take Profit (%) / Stop Loss (%): Fixed distance exits from entry.
  DCA Bot Webhook: Bot ID, Email Token, and Pair fields injected into every alert payload.
  Visualization: Toggle Avg Entry / TP / SL plot lines, fill labels, signal triangles, and the status table (status, entry price, TP/SL levels, live RSI and HA streak, entry-armed flag).
  Brand Watermark: Configurable text, position, size, and transparency.

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.

__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=6
// =============================================================================
//  BCH Heikin Ashi RSI Fade — Short Indicator
//  Signal-only companion to the BCH HA RSI Fade Short strategy. Tracks a virtual
//  short position and fires webhook-ready alerts on three events:
//    • SHORT entry — RSI(100) > 46 on 15m AND 7+ consecutive bullish HA candles on 15m
//    • TP — close drops to entry × (1 − 2.1%)
//    • SL — close rises to entry × (1 + 2.5%)
//  No backtest engine — designed to drive a live DCA Bot via webhooks.
//  Calibrated defaults for BINANCE:BCHUSDT on 15m timeframe.
// =============================================================================
indicator("BCH Heikin Ashi RSI Fade — Short Indicator", shorttitle = "BCH-I", overlay = true, max_labels_count = 500)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS (mirror the strategy 1:1)
// ─────────────────────────────────────────────────────────────────────────────
grpSize = "Order Size (Virtual)"
baseOrderSize = input.float(280.0, "Base Order Size (USDT)", minval = 1, group = grpSize, tooltip = "Virtual — used only for the status-table / PnL display. Real sizing happens on the bot.")

grpRSI = "RSI Filter"
rsiTF        = input.timeframe("15", "RSI Timeframe", group = grpRSI)
rsiLen       = input.int(100, "RSI Length", minval = 2, group = grpRSI)
rsiCondition = input.string("Greater Than", "RSI Condition", options = ["Greater Than", "Less Than"], group = grpRSI)
rsiLevel     = input.float(46.0, "RSI Level", minval = 1, maxval = 100, group = grpRSI)

grpHA = "Heikin Ashi Filter"
haTF        = input.timeframe("15", "HA Timeframe", group = grpHA)
haStreak    = input.int(7, "Consecutive Candles", minval = 2, maxval = 30, group = grpHA, tooltip = "Number of consecutive same-direction HA candles required to confirm entry.")
haDirection = input.string("Bullish", "HA Streak Direction", options = ["Bullish", "Bearish"], group = grpHA, tooltip = "For fade-the-strength Short: Bullish (default). For trend-follow Short: Bearish.")

grpExit = "Exit"
tpPct = input.float(2.1, "Take Profit (%)", minval = 0.1, step = 0.1, group = grpExit)
slPct = input.float(2.5, "Stop Loss (%)",   minval = 0.1, step = 0.1, group = grpExit)

grpHook = "DCA Bot Webhook"
botId       = input.string("YOUR_BOT_ID",      "Bot ID",            group = grpHook)
emailToken  = input.string("YOUR_EMAIL_TOKEN", "Email Token",       group = grpHook)
pairWebhook = input.string("USDT_BCH",         "Pair (QUOTE_BASE)", group = grpHook)

grpViz = "Visualization"
showEntryLines = input.bool(true, "Plot Avg Entry / TP / SL", group = grpViz)
showFillLabels = input.bool(true, "Show Fill Labels",         group = grpViz)
showShapes     = input.bool(true, "Show Signal Triangles",    group = grpViz)
showTable      = input.bool(true, "Show Status Table",        group = grpViz)

grpWM = "Brand Watermark"
showWM    = input.bool(true,        "Show Watermark", group = grpWM)
wmText    = input.string("3Commas", "Watermark Text", group = grpWM)
wmPosStr  = input.string("Bottom Right", "Position", options = ["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group = grpWM)
wmSizeStr = input.string("Large",   "Text Size", options = ["Tiny","Small","Normal","Large","Huge"], group = grpWM)
wmAlpha   = input.int(70,           "Transparency (0–100)", minval = 0, maxval = 100, group = grpWM)

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
f_msgClose() => '{"action":"close_at_market_price","message_type":"bot","bot_id":' + botId + ',"email_token":"' + emailToken + '","delay_seconds":0,"pair":"' + pairWebhook + '"}'

// ─────────────────────────────────────────────────────────────────────────────
// LOWER-TIMEFRAME DATA (no repaint)
// ─────────────────────────────────────────────────────────────────────────────
haTicker = ticker.heikinashi(syminfo.tickerid)

rsiLTF      = request.security(syminfo.tickerid, rsiTF, ta.rsi(close, rsiLen),    lookahead = barmerge.lookahead_off)
haBullCount = request.security(haTicker,         haTF,  ta.barssince(close <= open), lookahead = barmerge.lookahead_off)
haBearCount = request.security(haTicker,         haTF,  ta.barssince(close >= open), lookahead = barmerge.lookahead_off)

// ─────────────────────────────────────────────────────────────────────────────
// CONDITIONS
// ─────────────────────────────────────────────────────────────────────────────
condRSI = rsiCondition == "Greater Than" ? rsiLTF > rsiLevel : rsiLTF < rsiLevel
haCount = haDirection == "Bullish" ? haBullCount : haBearCount
condHA  = haCount >= haStreak

entrySignal = condRSI and condHA

// ─────────────────────────────────────────────────────────────────────────────
// VIRTUAL POSITION STATE
// ─────────────────────────────────────────────────────────────────────────────
var bool  inPosition  = false
var float entryPrice  = na
var float tpPx        = na
var float slPx        = na
var float realizedPnl = 0.0   // cumulative realized profit from closed virtual shorts (USDT)

var bool entryEvent = false
var bool tpEvent    = false
var bool slEvent    = false
entryEvent := false
tpEvent    := false
slEvent    := false

// ENTRY
if not inPosition and entrySignal
    inPosition := true
    entryPrice := close
    tpPx       := close * (1.0 - tpPct / 100.0)
    slPx       := close * (1.0 + slPct / 100.0)
    entryEvent := true
    alert(f_msgEntry(), alert.freq_once_per_bar_close)
    if showFillLabels
        label.new(bar_index, high, "SHORT ▼", style = label.style_label_down, color = color.new(color.red, 20), textcolor = color.white, size = size.tiny)

// EXIT — close-based detection (matches what a polling bot sees at bar close)
if inPosition
    if close <= tpPx
        qty = baseOrderSize / entryPrice
        realizedPnl := realizedPnl + (entryPrice - close) * qty   // short: profit when price falls
        tpEvent    := true
        inPosition := false
        entryPrice := na
        tpPx       := na
        slPx       := na
        alert(f_msgClose(), alert.freq_once_per_bar_close)
        if showFillLabels
            label.new(bar_index, low, "TP ▲", style = label.style_label_up, color = color.new(color.green, 20), textcolor = color.white, size = size.tiny)
    else if close >= slPx
        qty = baseOrderSize / entryPrice
        realizedPnl := realizedPnl + (entryPrice - close) * qty   // short: loss when price rises
        slEvent    := true
        inPosition := false
        entryPrice := na
        tpPx       := na
        slPx       := na
        alert(f_msgClose(), alert.freq_once_per_bar_close)
        if showFillLabels
            label.new(bar_index, low, "SL ▲", style = label.style_label_up, color = color.new(color.orange, 20), textcolor = color.white, size = size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
// PLOTS & SIGNAL SHAPES
// ─────────────────────────────────────────────────────────────────────────────
plot(showEntryLines and inPosition ? entryPrice : na, title = "Avg Entry", color = color.new(color.orange, 0), linewidth = 2, style = plot.style_linebr)
plot(showEntryLines and inPosition ? tpPx       : na, title = "TP",        color = color.new(color.green, 0),  linewidth = 1, style = plot.style_linebr)
plot(showEntryLines and inPosition ? slPx       : na, title = "SL",        color = color.new(color.red, 0),    linewidth = 1, style = plot.style_linebr)

plotshape(showShapes and entryEvent, title = "Short Entry", location = location.abovebar, style = shape.triangledown, color = color.new(color.red, 0),    size = size.tiny)
plotshape(showShapes and tpEvent,    title = "TP Hit",      location = location.belowbar, style = shape.triangleup,   color = color.new(color.green, 0),  size = size.tiny)
plotshape(showShapes and slEvent,    title = "SL Hit",      location = location.belowbar, style = shape.triangleup,   color = color.new(color.orange, 0), size = size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
// STATUS TABLE
// ─────────────────────────────────────────────────────────────────────────────
if showTable and barstate.islast
    var table tbl = table.new(position = position.top_right, columns = 2, rows = 7, border_width = 1)
    bg  = color.new(color.gray, 30)
    bgH = color.new(color.gray, 0)
    table.cell(tbl, 0, 0, "Status",         text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 1, 0, inPosition ? "In Short (virtual)" : "Flat", text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 0, 1, "Entry Price",    text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 1, inPosition ? str.tostring(entryPrice, "#.##") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 2, "TP Target",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 2, inPosition ? str.tostring(tpPx, "#.##") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 3, "SL Level",       text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 3, inPosition ? str.tostring(slPx, "#.##") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 4, rsiTF + " RSI(" + str.tostring(rsiLen) + ")", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 4, str.tostring(rsiLTF, "#.#"), text_color = condRSI ? color.green : color.white, bgcolor = bg)
    table.cell(tbl, 0, 5, haTF + " HA Streak (" + haDirection + ")", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 5, str.tostring(haCount), text_color = condHA ? color.green : color.white, bgcolor = bg)
    table.cell(tbl, 0, 6, "Entry Armed",    text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 6, entrySignal ? "YES" : "no", text_color = entrySignal ? color.green : color.gray, bgcolor = bg)

// ─────────────────────────────────────────────────────────────────────────────
// BRAND WATERMARK
// ─────────────────────────────────────────────────────────────────────────────
var table wm = na
if showWM and barstate.islast
    if na(wm)
        wm := table.new(f_pos(wmPosStr), 1, 1, bgcolor = color.new(color.black, 100), border_width = 0)
    table.cell(wm, 0, 0, wmText, text_color = color.new(color.white, wmAlpha), text_size = f_size(wmSizeStr), bgcolor = color.new(color.black, 100))
````
