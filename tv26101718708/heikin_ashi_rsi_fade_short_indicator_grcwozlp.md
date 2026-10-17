# Heikin Ashi RSI Fade - Short Indicator

- url: https://www.tradingview.com/script/GrCwoZlp-Heikin-Ashi-RSI-Fade-Short-Indicator/
- type: indicator
- pine_id: PUB;abb23cc012de4172bc65e9acdb4adc44
- version: 1.0

## Description

Heikin Ashi RSI Fade — Short Indicator

🔷 What it does:
This is a signal-only indicator that mirrors a fade-the-strength short workflow. It tracks one virtual short position at a time and fires webhook-ready alerts on three discrete events: a short entry confirmed by dual filters across two timeframes, a take-profit close when price drops a fixed percentage below entry, and a stop-loss close when price rises a fixed percentage above entry. No backtest engine — the indicator is built to drive a live DCA Bot directly through TradingView alerts.
  - Dual confirmation entry: RSI(100) on 1h above 46 AND a configurable number of consecutive bullish Heikin Ashi candles on 15m.
  - Fixed exits: TP at −2.1% from entry, SL at +2.5%. No trailing.
  - Every event emits a fully-formed JSON payload ready for direct DCA Bot consumption.
  - Status table tracks the live virtual state on every bar close.

🔷 Who is it for:
  - Swing traders running a DCA Bot on crypto pairs that frequently overrun local resistance.
  - Bot operators who want a chart-driven signal source that emits webhook JSON natively, with no glue scripts required.
  - Traders who want to monitor entry, TP, and SL conditions in real time on the chart without the strategy-tester overhead.
  - Risk-conscious operators looking for a clean fade engine with bounded per-trade exposure.

🔷 How does it work:
  RSI Bias Filter: A long-window RSI(100) is sampled from the 1-hour timeframe via request.security. The threshold (default 46) sits just below the midline, so the filter is satisfied during prolonged bullish drift — exactly the regime where fading strength has the highest expectancy. When RSI falls below 46, the bias is considered to have flipped bearish and the indicator stops looking for new short signals.
  Heikin Ashi Streak Trigger: A 15-minute Heikin Ashi stream is sampled in parallel, and the indicator counts consecutive same-direction HA candles using ta.barssince inside request.security. When the bullish streak reaches the configured length (default 7), the trigger is armed. A single input flips the HA direction between Bullish (fade strength, default) and Bearish (follow trend).
  Virtual Position Tracking: When both filters align at host-bar close, the indicator marks a virtual short entry, captures the entry price, and pre-computes the TP and SL levels from the configured percentages. The position state, target prices, and live RSI / HA filter readouts are surfaced in the status table on every bar.
  Close-Based Exit Detection: Exit signals are evaluated on bar close — when the close drops to the TP level, the TP event fires; when the close rises to the SL level, the SL event fires. This matches what a polling bot would see at each candle close and avoids over-signaling on intra-bar wicks.
  Webhook Dispatch: Every event (entry, TP, SL) emits a dedicated JSON payload through alert(). One TradingView alert configured for "Any alert() function call" drives a DCA Bot end-to-end through the indicator's lifetime.

🔷 Why it's unique:
  - Dual-Timeframe Confirmation: RSI on 1h filters macro bias, Heikin Ashi on 15m times the entry. The two conditions operate on different scales so they cannot be satisfied by the same noise pattern — every entry requires alignment across both.
  - Fade-or-Follow Switch: A single input flips the HA direction filter between Bullish (fade strength, default) and Bearish (follow trend). The same engine handles two opposing setup archetypes.
  - Honest Virtual State: Entry price, TP target, SL level, and live filter readouts are all surfaced on the chart in real time. No hidden math, no shortcut from a synthetic base — what you see is what the bot would see.
  - DCA Bot Integration: Webhook payloads are identical to the companion strategy version, so the same bot configuration drives both. Use the indicator for live signals and the strategy for backtest validation.

🔷 Considerations Before Using the Indicator:
  Market Selection: Designed for liquid crypto pairs that respect mean-reversion behavior on 1h–2h ranges. Strongly trending markets will repeatedly stop the indicator out; the 1h RSI(100) > 46 filter limits exposure to confirmed bullish drift, but a regime shift to a stronger trend requires manual oversight.
  Cross-Detection Granularity: The indicator evaluates entries and exits on bar close. A bar that spikes through a TP or SL level intra-bar and returns within the same bar will not fire the event by design — this matches realistic polling behavior and avoids over-signaling on wicks.
  Live vs Historical State: The virtual position state is rebuilt from chart history each time the indicator is recompiled or reloaded. If the indicator is added mid-deployment or the live bot diverges from the signal stream (manual interventions, partial fills), the indicator state may not match the live bot. Toggle the indicator off and on to reset.
  No Stop Loss on the Bot Side: The indicator fires a close webhook when its virtual SL level is reached, but the underlying bot still relies on the indicator being live and the webhook being delivered. If hard exchange-side risk protection is required, configure a parallel SL on the exchange directly.
  Backtesting Note: This is an indicator, not a strategy. There is no built-in P&L tester. For performance metrics over a five-year sample (~349 closed trades, 0.47% max drawdown, profit factor 1.117), use the companion strategy version on identical parameters.

🔷 How to Use It:
  🔸 Add the indicator to a 1H or 2H crypto chart on the pair you want to trade.
  🔸 Review the RSI filter (timeframe / length / condition / level) and the Heikin Ashi filter (timeframe / streak / direction). Defaults are calibrated for XRPUSDT — recalibrate per asset before deploying.
  🔸 Set the Take Profit and Stop Loss percentages to match the volatility profile of your asset.
  🔸 In the DCA Bot Webhook group, paste the Bot ID, Email Token, and Pair (QUOTE_BASE format, e.g., USDT_XRP).
  🔸 Create an alert on the indicator with "Any alert() function call". Paste the DCA Bot's webhook URL into the alert's Webhook field. The indicator will emit JSON payloads for short entry, TP close, and SL close — formatted for direct DCA Bot consumption.

🔷 INDICATOR SETTINGS
  Base Order Size (USDT): Virtual order size, used only for the status-table display.
  RSI Timeframe / Length / Condition / Level: Lower-timeframe RSI bias filter on the host symbol.
  HA Timeframe / Streak / Direction: Heikin Ashi consecutive-candle trigger on the lower timeframe. Direction defines fade (Bullish) vs follow (Bearish) mode.
  Take Profit (%) / Stop Loss (%): Fixed distance exits from the entry price.
  DCA Bot Webhook: Bot ID, Email Token, and Pair fields injected into every alert payload.
  Visualization: Toggle Avg Entry / TP / SL plot lines, fill labels, signal triangles, status table.
  Brand Watermark: Configurable text, position, size, and transparency.

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.

__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=6
// =============================================================================
//  Heikin Ashi RSI Fade — Short Indicator
//  Signal-only companion to the HA RSI Fade Short strategy. Tracks a virtual
//  short position and fires webhook-ready alerts on three events:
//    • SHORT entry — RSI > 46 on 1h AND 7+ consecutive bullish HA candles on 15m
//    • TP — close drops to entry × (1 − 2.1%)
//    • SL — close rises to entry × (1 + 2.5%)
//  No backtest engine — designed to drive a live DCA Bot via webhooks.
// =============================================================================
indicator("Heikin Ashi RSI Fade — Short Indicator", shorttitle = "HA-RSI-I", overlay = true, max_labels_count = 500)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS (mirror the strategy 1:1)
// ─────────────────────────────────────────────────────────────────────────────
grpSize = "Order Size (Virtual)"
baseOrderSize = input.float(100.0, "Base Order Size (USDT)", minval = 1, group = grpSize, tooltip = "Virtual — used only for the status-table display. Real sizing happens on the bot.")

grpRSI = "RSI Filter"
rsiTF        = input.timeframe("60", "RSI Timeframe", group = grpRSI)
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
pairWebhook = input.string("USDT_XRP",         "Pair (QUOTE_BASE)", group = grpHook)

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
var bool  inPosition = false
var float entryPrice = na
var float tpPx       = na
var float slPx       = na

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
        tpEvent    := true
        inPosition := false
        entryPrice := na
        tpPx       := na
        slPx       := na
        alert(f_msgClose(), alert.freq_once_per_bar_close)
        if showFillLabels
            label.new(bar_index, low, "TP ▲", style = label.style_label_up, color = color.new(color.green, 20), textcolor = color.white, size = size.tiny)
    else if close >= slPx
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
    table.cell(tbl, 1, 1, inPosition ? str.tostring(entryPrice, "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 2, "TP Target",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 2, inPosition ? str.tostring(tpPx, "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 3, "SL Level",       text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 3, inPosition ? str.tostring(slPx, "#.####") : "—", text_color = color.white, bgcolor = bg)
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
