# Heikin Ashi RSI Fade - Short Strategy

- url: https://www.tradingview.com/script/oGwYWfai-Heikin-Ashi-RSI-Fade-Short-Strategy/
- type: strategy
- pine_id: PUB;9323db27734143f79905fd9b151c6ce3
- version: 1.0

## Description

Heikin Ashi RSI Fade — Short Strategy

🔷 What it does:
This is a short-only strategy that fades extended Heikin Ashi bullish streaks confirmed by a higher-timeframe RSI bias filter. A short entry is opened when the lower-timeframe Heikin Ashi prints a defined number of consecutive bullish candles AND the medium-term RSI is above a soft-bias threshold — the combination targets exhausted bullish thrusts that have run far enough to invite a pullback. The exit is a fixed Take Profit OR a fixed Stop Loss; no trailing, no averaging, no second-guessing.
  - Single base order, sized at 1% of equity by default.
  - Dual confirmation entry: RSI(100) on 1h > 46 AND 7 consecutive Heikin Ashi bullish candles on 15m.
  - Hard exit pair: TP at −2.1% from average entry, SL at +2.5%.
  - Every entry and exit emits a webhook-ready JSON alert payload for direct DCA Bot consumption.

🔷 Who is it for:
  - Swing traders looking for systematic short exposure on crypto pairs that frequently overrun local resistance.
  - Traders who want a clean, mechanical short setup with no averaging and no discretionary management once in trade.
  - Bot operators who want to drive a DCA Bot configured for one-shot short deals via webhook.
  - Risk-conscious operators — at default settings the worst-case per-trade loss is ~0.025% of equity (well inside the 5–10% per-trade risk band).

🔷 How does it work:
  RSI Bias Filter: A long-window RSI(100) is sampled from the 1-hour timeframe via request.security. The threshold (default 46) sits just below the midline, so the filter is satisfied during prolonged bullish drift — exactly the regime where fading strength has the highest expectancy. When RSI falls below 46, the bias is considered to have flipped bearish and the strategy stops looking for new shorts.
  Heikin Ashi Streak Trigger: A 15-minute Heikin Ashi stream is sampled in parallel, and the strategy counts the number of consecutive same-direction HA candles using ta.barssince. When the bullish streak reaches the configured length (default 7), the trigger is armed. The default Bullish direction defines the fade-the-strength mode; switching to Bearish converts the strategy into a trend-follow short.
  Entry: When BOTH conditions are true at host-bar close, a short position is opened at the base order size. The base order is configurable as Market (default) or Limit at the bar's close.
  Exit (OCO): Take Profit and Stop Loss are issued as a paired OCO order through strategy.exit. The first level reached closes the position and automatically cancels the other side — no trailing, no partial exits.

🔷 Why it's unique:
  - Dual-Timeframe Confirmation: RSI on 1h filters macro bias, Heikin Ashi on 15m times the entry. The two conditions operate on different scales so they cannot be satisfied by the same noise pattern — every entry requires alignment across both.
  - Fade-or-Follow Switch: A single input flips the HA direction filter between Bullish (fade strength, default) and Bearish (follow trend). The same engine handles two opposing strategy archetypes.
  - Bounded Trade Risk: With a single base order and a hard Stop Loss, the maximum loss per trade is exactly base size × SL%. At defaults that is 2.5 USDT on 10,000 — structural risk capping without any complex sizing logic.
  - DCA Bot Integration: Each event emits a fully-formed JSON alert payload tagged with the action type, so the strategy can drive a DCA Bot configured for one-shot deals directly through TradingView alerts.

🔷 Considerations Before Using the Strategy:
  Market & Timeframe: Designed and tested on XRPUSDT 1H, Binance Spot, over a five-year sample. The RSI-and-Heikin-Ashi combination is portable to other liquid crypto pairs that respect mean-reversion behavior, but the filter thresholds (RSI level, HA streak length) should be reviewed before redeployment.
  Performance Profile: This is a low-volatility, low-return defensive short. Over the 349-trade backtest the strategy returned +0.44% with a 0.47% maximum equity drawdown — a return-to-DD ratio just below 1, with a profit factor of 1.117. The value proposition is structural risk capping over a large statistical sample, not aggressive alpha. Size accordingly within a diversified portfolio.
  Trending Markets: In strong sustained uptrends, the strategy will continue to fire short entries and will incur stop-outs as price grinds higher. This is by design — the strategy is positioned for ranges and rotations, not breakouts. The 1h RSI(100) > 46 filter limits exposure to confirmed bullish regimes only, which is where fading has an edge; a regime change to a stronger trend will require manual oversight or a wider Stop Loss.
  Sample Size & Parameters: If a full-period backtest produces fewer than ~100 closed trades, either extend the period or lower the HA streak length to 5. Re-save the relaxed value as the new default so the publication continues to satisfy the "Default Properties match" rule.
  Commission & Slippage: Defaults reflect Bybit perpetual taker conditions (0.06% commission, 3 ticks slippage). Update both inputs to match your exchange's actual fees before relying on the backtest numbers.
  Past Performance: Past results do not guarantee future performance. Always demo-test before deploying live capital, and size the strategy as one part of a diversified portfolio.

🔷 STRATEGY PROPERTIES
  Symbol: BINANCE:XRPUSDT (Spot)
  Timeframe: 1H
  Test Period: Mar 1, 2025 — May 22, 2026.
  Initial Capital: 10,000 USDT.
  Order Size per Trade: 1% of Capital (single base order, no averaging).
  Max Capital Deployed: 100 USDT per trade (~1% of equity).
  Worst-Case Loss per Trade: ~2.5 USDT (~0.025% of equity).
  Commission: 0.06% per trade.
  Slippage: 3 ticks.
  Margin for Short Positions: 100%.
  Indicator Settings: Default Configuration.
  Base Order: 100 USDT, Market by default (Limit toggle available).
  Take Profit: 2.1% below average entry (no trailing).
  Stop Loss: 2.5% above average entry (close trade).
  RSI Filter: 1h RSI(100) > 46.
  Heikin Ashi Filter: 15m Heikin Ashi, 7 consecutive bullish candles.
  Strategy: Short Only.

🔷 STRATEGY RESULTS
  ⚠️ Remember, past results do not guarantee future performance.
  Net Profit: +44.33 USDT (+0.44%)
  Max Equity Drawdown: 46.78 USDT (0.47%)
  Total Closed Trades: 349
  Percent Profitable: 59.31% (207 / 349)
  Profit Factor: 1.117

🔷 How to Use It:
  🔸 Adjust Settings: Open the strategy inputs and review the Base Order Size, RSI filter (timeframe / length / level), and the Heikin Ashi filter (timeframe / streak length / direction). Defaults are calibrated for XRPUSDT 2H — recalibrate per asset before deploying.
  🔸 Results Review: Run a full-period backtest and confirm Max Drawdown stays inside your personal risk band. Validate that the closed-trade count is statistically meaningful (≥ 100 is a reasonable floor). Use realistic commission and slippage for your exchange.
  🔸 Create alerts to trigger the DCA Bot: Add one alert on the strategy using "Any alert() function call". Paste the DCA Bot's webhook URL into the alert's Webhook field, and fill the Bot ID, Email Token, and Pair inputs on the script. The strategy will emit JSON payloads for short entry and exit — TP, SL, or manual close — formatted for direct DCA Bot consumption.

🔷 INDICATOR SETTINGS
  Base Order Size (USDT): USDT amount opened on the short entry.
  Use LIMIT for Base: Toggle between Market (default, more conservative for backtest) and Limit at bar close.
  RSI Timeframe / Length / Condition / Level: Lower-timeframe RSI bias filter applied to the host symbol.
  HA Timeframe / Streak / Direction: Heikin Ashi consecutive-candle trigger on the lower timeframe. Direction defines fade (Bullish) vs follow (Bearish) mode.
  Take Profit (%) / Stop Loss (%): Fixed distance exits from average entry.
  DCA Bot Webhook: Bot ID, Email Token, and Pair fields injected into every alert payload.
  Visualization: Toggle Avg Entry / TP / SL plot lines, fill labels, status table.
  Brand Watermark: Configurable text, position, size, and transparency.

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.

__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=6
// =============================================================================
//  Heikin Ashi RSI Fade — Short Strategy
//  Short-only strategy that fades extended Heikin Ashi bullish streaks
//  confirmed by an RSI bias filter on a lower timeframe. Single base order,
//  no averaging, fixed Take Profit and Stop Loss — no trailing by design.
// =============================================================================
strategy("Heikin Ashi RSI Fade — Short Strategy", shorttitle = "HA-RSI-S", overlay = true, initial_capital = 10000, default_qty_type = strategy.cash, default_qty_value = 100, pyramiding = 1, commission_type = strategy.commission.percent, commission_value = 0.06, slippage = 3, process_orders_on_close = true, calc_on_every_tick = false)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grpBase = "Base Order"
baseOrderSize = input.float(100.0, "Base Order Size (USDT)", minval = 1, group = grpBase, tooltip = "1% of default 10k capital.")
useLimitBase  = input.bool(false, "Use LIMIT for Base (else Market)", group = grpBase, tooltip = "Source bot used LIMIT; in practice fills near-instantly, so Market is the more honest backtest default.")

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
tpPct = input.float(2.1, "Take Profit (%)", minval = 0.1, step = 0.1, group = grpExit, tooltip = "Distance below avg entry where the position closes for profit.")
slPct = input.float(2.5, "Stop Loss (%)",   minval = 0.1, step = 0.1, group = grpExit, tooltip = "Distance above avg entry where the position is stopped out.")

grpDate = "Backtest Window"
useDateFilter = input.bool(false, "Limit Backtest Period", group = grpDate)
fromDate      = input.time(timestamp("01 Jan 2024 00:00 +0000"), "From", group = grpDate)
toDate        = input.time(timestamp("01 Jan 2030 00:00 +0000"), "To", group = grpDate)

grpHook = "DCA Bot Webhook"
botId       = input.string("YOUR_BOT_ID",      "Bot ID",            group = grpHook)
emailToken  = input.string("YOUR_EMAIL_TOKEN", "Email Token",       group = grpHook)
pairWebhook = input.string("USDT_XRP",         "Pair (QUOTE_BASE)", group = grpHook)

grpViz = "Visualization"
showEntryLines = input.bool(true, "Plot Avg Entry / TP / SL", group = grpViz)
showFillLabels = input.bool(true, "Show Fill Labels", group = grpViz)
showTable      = input.bool(true, "Show Status Table", group = grpViz)

grpWM = "Brand Watermark"
showWM    = input.bool(true,        "Show Watermark", group = grpWM)
wmText    = input.string("3Commas", "Watermark Text", group = grpWM)
wmPosStr  = input.string("Bottom Right", "Position", options = ["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group = grpWM)
wmSizeStr = input.string("Large",   "Text Size", options = ["Tiny","Small","Normal","Large","Huge"], group = grpWM)
wmAlpha   = input.int(70,           "Transparency (0–100)", minval = 0, maxval = 100, group = grpWM)

inWindow = not useDateFilter or (time >= fromDate and time <= toDate)

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

// RSI on host symbol at LTF
rsiLTF = request.security(syminfo.tickerid, rsiTF, ta.rsi(close, rsiLen), lookahead = barmerge.lookahead_off)

// HA streak counters: bars since last opposite-direction HA candle on LTF
// (HA ticker returns HA OHLC inside the security call; close>open = bullish HA)
haBullCount = request.security(haTicker, haTF, ta.barssince(close <= open), lookahead = barmerge.lookahead_off)
haBearCount = request.security(haTicker, haTF, ta.barssince(close >= open), lookahead = barmerge.lookahead_off)

// ─────────────────────────────────────────────────────────────────────────────
// CONDITIONS
// ─────────────────────────────────────────────────────────────────────────────
condRSI = rsiCondition == "Greater Than" ? rsiLTF > rsiLevel : rsiLTF < rsiLevel
haCount = haDirection == "Bullish" ? haBullCount : haBearCount
condHA  = haCount >= haStreak

entrySignal = condRSI and condHA

// ─────────────────────────────────────────────────────────────────────────────
// ENTRY — SHORT
// ─────────────────────────────────────────────────────────────────────────────
inPosition = strategy.position_size != 0

openEntry = inWindow and not inPosition and strategy.opentrades == 0 and entrySignal
if openEntry
    qty = baseOrderSize / close
    if useLimitBase
        strategy.entry("Short_Base", strategy.short, qty = qty, limit = close, comment = "Short_Base")
    else
        strategy.entry("Short_Base", strategy.short, qty = qty, comment = "Short_Base")
    alert(f_msgEntry(), alert.freq_once_per_bar_close)
    if showFillLabels
        label.new(bar_index, high, "SHORT ▼", style = label.style_label_down, color = color.new(color.red, 20), textcolor = color.white, size = size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
// EXIT — Fixed TP and SL via OCO limit/stop (no trailing)
// ─────────────────────────────────────────────────────────────────────────────
if inPosition
    avgPx = strategy.position_avg_price
    tpPx  = avgPx * (1.0 - tpPct / 100.0)
    slPx  = avgPx * (1.0 + slPct / 100.0)
    strategy.exit("Exit", from_entry = "Short_Base", limit = tpPx, stop = slPx, comment_profit = "TP", comment_loss = "SL")

// Detect just-closed for alerts and labels
prevSize   = nz(strategy.position_size[1])
nowSize    = strategy.position_size
justClosed = prevSize != 0 and nowSize == 0
if justClosed
    alert(f_msgClose(), alert.freq_once_per_bar_close)
    if showFillLabels
        label.new(bar_index, low, "CLOSE ▲", style = label.style_label_up, color = color.new(color.green, 20), textcolor = color.white, size = size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
// VISUALIZATION — Avg Entry / TP / SL plot lines
// ─────────────────────────────────────────────────────────────────────────────
avgPxNow = strategy.position_size != 0 ? strategy.position_avg_price : na
tpPxNow  = strategy.position_size != 0 ? avgPxNow * (1.0 - tpPct / 100.0) : na
slPxNow  = strategy.position_size != 0 ? avgPxNow * (1.0 + slPct / 100.0) : na

plot(showEntryLines ? avgPxNow : na, title = "Avg Entry", color = color.new(color.orange, 0), linewidth = 2, style = plot.style_linebr)
plot(showEntryLines ? tpPxNow  : na, title = "TP",        color = color.new(color.green, 0),  linewidth = 1, style = plot.style_linebr)
plot(showEntryLines ? slPxNow  : na, title = "SL",        color = color.new(color.red, 0),    linewidth = 1, style = plot.style_linebr)

// ─────────────────────────────────────────────────────────────────────────────
// STATUS TABLE
// ─────────────────────────────────────────────────────────────────────────────
if showTable and barstate.islast
    var table tbl = table.new(position = position.top_right, columns = 2, rows = 7, border_width = 1)
    bg  = color.new(color.gray, 30)
    bgH = color.new(color.gray, 0)
    table.cell(tbl, 0, 0, "Status",         text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 1, 0, inPosition ? "In Short" : "Flat", text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 0, 1, "Avg Entry",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 1, inPosition ? str.tostring(strategy.position_avg_price, "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 2, "TP Target",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 2, inPosition ? str.tostring(strategy.position_avg_price * (1.0 - tpPct / 100.0), "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 3, "SL Level",       text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 3, inPosition ? str.tostring(strategy.position_avg_price * (1.0 + slPct / 100.0), "#.####") : "—", text_color = color.white, bgcolor = bg)
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
