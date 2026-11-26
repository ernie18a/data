# [3Commas] DOT RSI Reversal DCA - Short Strategy

- url: https://www.tradingview.com/script/2SC4QXCp-3Commas-DOT-RSI-Reversal-DCA-Short-Strategy/
- type: strategy
- pine_id: PUB;5e7278cdb10b47c6a0d56fe54afeb44a
- version: 1.0

## Description

[3Commas] DOT RSI Reversal DCA - Short Strategy

🔷 What it does:
This is a short-only DCA strategy that fades overbought momentum on DOT / USDT. A short deal opens when the 3-minute RSI(9) crosses down through 80 — a momentum-exhaustion signal after a fast push higher. Up to three averaging orders then fill at fixed deviations ABOVE the base entry (+1%, +2%, +3%) with uniform sizing, pulling the average entry up if price keeps rising. Exit is a 1.3% Take Profit from the average entry with a 0.3% trailing retrace, and a hard 8% Stop Loss caps the downside.
  - Single base order plus up to three uniform averaging orders on a fixed +1% / +2% / +3% ladder.
  - Tight 1.3% Take Profit with a 0.3% trailing lock — captures the mean-reversion snap-back, then trails to squeeze a little extra.
  - Hard 8% Stop Loss closes the trade if the short keeps running against the position — a real, bounded per-trade risk.
  - Every entry, averaging order, and exit emits a webhook-ready JSON alert payload for direct DCA Bot consumption.

🔷 Who is it for:
  - Intraday traders fading overbought spikes on DOT on lower timeframes.
  - Bot operators who want to drive a DCA Bot short deal from TradingView alerts with per-event JSON payloads.
  - Traders who want a mechanical short with a defined stop, modest averaging, and a quick profit target rather than an open-ended hold.
  - Portfolio operators looking for a high-win-rate, short-side contributor with bounded risk.

🔷 How does it work:
  Entry Trigger: A 3-minute RSI(9) is sampled via request.security with lookahead disabled (no repaint). The base short opens when that RSI crosses DOWN through 80 — i.e., the prior 3m close was ≥ 80 and the current is below it, marking the moment overbought momentum rolls over.
  Base Order: Sized at 500 USDT default (5% of 10k capital), placed as a Limit order at the signal bar's close (Market toggle available).
  Averaging Orders (Uniform DCA Ladder): After the base fill, the strategy monitors price deviation above the base entry. Each averaging order has a fixed deviation — +1%, +2%, +3% — with uniform sizing (250 USDT each, half the base). If price rises against the short, each rung adds size and raises the average entry, so a smaller reversal is needed to reach Take Profit.
  Exit (TP + Trailing): A 1.3% Take Profit below the running average entry arms a trailing exit. Once price trades through the TP level, the strategy tracks the in-favor low and closes when price retraces 0.3% off that low — locking the move while letting it extend.
  Stop Loss: A hard 8% Stop Loss above the average entry. If price runs against the short past that level, the position closes at market. This is the strategy's defined, bounded per-trade risk.

🔷 Why it's unique:
  - Momentum-Exhaustion Trigger: Rather than shorting any overbought reading, the deal opens specifically on the RSI crossing DOWN through 80 — the rollover moment — which filters out trades that fire while momentum is still climbing.
  - Defined-Risk DCA: Most martingale DCA shorts run without a stop. This one keeps a modest 3-rung uniform ladder AND an 8% hard stop, so the worst-case loss per deal is bounded and known in advance.
  - Trailing Take Profit: The 1.3% target arms a 0.3% trailing exit rather than a fixed limit — capturing the reversion snap and then riding any follow-through.
  - DCA Bot Integration: Every event (base, AO 1–3, exit) emits a fully-formed JSON alert payload. Connect one alert to a DCA Bot's webhook URL and the strategy drives the bot end-to-end without any glue layer.

🔷 Considerations Before Using the Strategy:
  Sample Size: The backtest produced 131 closed trades — above the ~100-trade floor for statistical relevance, though still a relatively short window. The 88.55% win rate and 2.764 profit factor reflect favorable conditions over the test period; treat them as indicative rather than a forward-performance guarantee. Extend the window or run across multiple assets to build a larger sample.
  Lower-Timeframe Sensitivity: Tested on a 3-minute chart with a 3-minute RSI trigger. Lower timeframes generate more signals but are more sensitive to noise and fees. Confirm the trade frequency and fee drag fit your execution venue before deploying.
  Stop Loss Discipline: The 8% Stop Loss is the defining risk control. With the base plus three averaging orders, maximum deployed capital is ~1,250 USDT (12.5% of default equity); an 8% stop on that position bounds the worst-case loss to roughly 1% of equity. Keep the stop enabled — removing it converts this into an unbounded martingale short.
  Trend Risk: Fading overbought conditions works best in ranges and choppy regimes. In a strong, sustained uptrend the short can hit the 8% stop repeatedly. The RSI-crossing-down trigger reduces but does not eliminate this; pair with regime awareness.
  Commission Calibration: The default 0.06% commission is calibrated for Bybit perpetual taker conditions. Match it to your exchange's actual fees — on a high-frequency lower-timeframe strategy, fee mismatch materially shifts results.

🔷 STRATEGY PROPERTIES
  Symbol: BYBIT:DOTUSDT.P (Perpetual) — portable to any DOT / USDT pair.
  Timeframe: 3M chart (3M RSI trigger).
  Test Period: March 23, 2026 — June 17, 2026 (~2.8 months).
  Initial Capital: 10,000 USDT.
  Order Size: 500 USDT base (5%) + 3 averaging orders of 250 USDT each (uniform).
  Max Capital Deployed: ~1,250 USDT per trade (~12.5% of equity).
  Commission: 0.06% per trade.
  Slippage: 3 ticks.
  Margin for Short Positions: 100% (1× leverage, Isolated in source config).
  Indicator Settings: Default Configuration.
  Base Order: 500 USDT, Limit by default (Market toggle available).
  Entry Trigger: 3m RSI(9) Crossing Down 80.
  Averaging Orders: 3 with fixed deviations +1% / +2% / +3% above base entry; uniform 250 USDT sizing.
  Take Profit: 1.3% below average entry, with 0.3% trailing.
  Stop Loss: 8% above average entry (hard close).
  Strategy: Short Only.

🔷 STRATEGY RESULTS
  ⚠️ Remember, past results do not guarantee future performance.
  Net Profit: +389.13 USDT (+3.89%)
  Max Equity Drawdown: 165.35 USDT (1.62%)
  Total Closed Trades: 131
  Percent Profitable: 88.55% (116 / 131)
  Profit Factor: 2.764

🔷 How to Use It:
  🔸 Adjust Settings: Open the strategy inputs and review the Base Order Size, the averaging-order count/deviation/size, the RSI trigger level, the Take Profit and Trailing percentages, and the Stop Loss. Defaults mirror the source DCA Bot configuration — recalibrate per asset and timeframe.
  🔸 Results Review: This configuration produced 131 closed trades over the test window — above the ~100-trade floor for statistical relevance. Confirm the win rate, drawdown, and trade frequency fit your risk tolerance before deploying capital.
  🔸 Create alerts to trigger the DCA Bot: Add one alert on the strategy using "Any alert() function call". Paste the DCA Bot's webhook URL into the alert's Webhook field, and fill the Bot ID, Email Token, and Pair inputs on the script. The strategy will emit JSON payloads for entry, each averaging order, and exit — formatted for direct DCA Bot consumption.

🔷 INDICATOR SETTINGS
  Base Order Size (USDT): USDT amount opened on the initial short.
  Use LIMIT for Base: Toggle between Limit (default) and Market entry.
  Averaging Orders per Trade: Number of safety orders (default 3).
  First AO Size (USDT): Size of each averaging order (uniform by default).
  Deviation to First AO (%) / Deviation Step Multiplier: Spacing of the AO ladder above base entry. Defaults to uniform +1% steps.
  Order Size Multiplier: Per-rung size scaling (1.0 = uniform).
  RSI Timeframe / Length / Crossing Down Level: The 3m RSI(9) crossing-down trigger for the base short.
  Take Profit (%) / Trailing (%): TP distance below average entry and the trailing retrace that closes the position.
  Stop Loss (%): Hard stop above average entry.
  DCA Bot Webhook: Bot ID, Email Token, and Pair fields injected into every alert payload.
  Visualization: Toggle DCA Ladder, Avg / TP / SL plot lines, fill labels, status table.
  Brand Watermark: Configurable text, position, size, and transparency.

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.

__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=6
// =============================================================================
//  DOT RSI Reversal DCA — Short Strategy
//  Short-only DCA framework on DOTUSDT.P. A short deal opens when 3m RSI(9)
//  crosses DOWN through 80 (overbought momentum exhaustion). Up to 3 averaging
//  orders fill at fixed deviations ABOVE base entry (+1%, +2%, +3%) with uniform
//  sizing. Exit is a 1.3% Take Profit from average entry with a 0.3% trailing
//  retrace; a hard 8% Stop Loss caps the downside.
//  Calibrated defaults for BYBIT:DOTUSDT.P.
// =============================================================================
strategy("[3Commas] DOT RSI Reversal DCA — Short Strategy", shorttitle = "[3Commas] DOT DCA-S", overlay = true, initial_capital = 10000, default_qty_type = strategy.cash, default_qty_value = 500, pyramiding = 4, commission_type = strategy.commission.percent, commission_value = 0.06, slippage = 3, process_orders_on_close = true, calc_on_every_tick = false, max_labels_count = 500, max_lines_count = 100)
// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grpBase = "Base Order"
baseOrderSize = input.float(500.0, "Base Order Size (USDT)", minval = 1, group = grpBase, tooltip = "USDT amount opened on the initial short. 5% of default 10k capital.")
useLimitBase  = input.bool(true, "Use LIMIT for Base (else Market)", group = grpBase, tooltip = "3Commas config uses a Limit start order.")
grpAO = "Averaging Orders (Dollar-Cost Averaging)"
aoCount    = input.int(3, "Averaging Orders per Trade", minval = 0, maxval = 10, group = grpAO)
aoSize     = input.float(250.0, "First AO Size (USDT)", minval = 1, group = grpAO, tooltip = "Half the base order, matching the source config ratio.")
aoStep     = input.float(1.0, "Deviation to First AO (%)", minval = 0.1, step = 0.1, group = grpAO)
aoStepMult = input.float(1.0, "Deviation Step Multiplier", minval = 1.0, step = 0.1, group = grpAO, tooltip = "1.0 = uniform spacing: +1%, +2%, +3% from base.")
aoSizeMult = input.float(1.0, "Order Size Multiplier", minval = 1.0, step = 0.1, group = grpAO, tooltip = "1.0 = all AOs same size.")
grpEntry = "Trade Start Condition (RSI Crossing Down)"
rsiTF    = input.timeframe("3", "RSI Timeframe", group = grpEntry, tooltip = "3 = 3 minutes.")
rsiLen   = input.int(9, "RSI Length", minval = 2, group = grpEntry)
rsiLevel = input.float(80.0, "RSI Crossing Down Level", minval = 1, maxval = 100, group = grpEntry, tooltip = "Short arms when 3m RSI crosses DOWN through this level.")
grpExit = "Exit"
tpPct    = input.float(1.3, "Take Profit (%)", minval = 0.1, step = 0.1, group = grpExit, tooltip = "Distance below average entry where the trailing exit arms.")
trailPct = input.float(0.3, "Trailing (%)", minval = 0.1, step = 0.1, group = grpExit, tooltip = "Retrace from the in-favor low that closes the position.")
slPct    = input.float(8.0, "Stop Loss (%)", minval = 0.1, step = 0.1, group = grpExit, tooltip = "Hard stop above average entry. Closes the trade.")
grpDate = "Backtest Window"
useDateFilter = input.bool(true, "Limit Backtest Period", group = grpDate)
fromDate      = input.time(timestamp("23 Mar 2026 00:00 +0000"), "From", group = grpDate)
toDate        = input.time(timestamp("17 Jun 2026 23:59 +0000"), "To", group = grpDate)
grpHook = "DCA Bot Webhook"
botId       = input.string("YOUR_BOT_ID", "Bot ID", group = grpHook)
emailToken  = input.string("YOUR_EMAIL_TOKEN", "Email Token", group = grpHook)
pairWebhook = input.string("USDT_DOT", "Pair (QUOTE_BASE)", group = grpHook)
grpViz = "Visualization"
showLevels = input.bool(true, "Show DCA Ladder", group = grpViz)
showLines  = input.bool(true, "Plot Avg / TP / SL Lines", group = grpViz)
showLabels = input.bool(true, "Show Fill Labels", group = grpViz)
showTable  = input.bool(true, "Show Status Table", group = grpViz)
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
rsiVal    = request.security(syminfo.tickerid, rsiTF, ta.rsi(close, rsiLen), lookahead = barmerge.lookahead_off)
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
// STATE
// ─────────────────────────────────────────────────────────────────────────────
var float baseEntry  = na
var int   aoFilled   = 0
var float minSinceTP = na
var bool  inTPZone   = false
inPosition       = strategy.position_size != 0
justEntered      = nz(strategy.position_size[1]) == 0 and inPosition
positionJustFlat = nz(strategy.position_size[1]) != 0 and not inPosition
if justEntered and na(baseEntry)
    baseEntry := strategy.position_avg_price
    aoFilled  := 0
if positionJustFlat or not inPosition
    baseEntry  := na
    aoFilled   := 0
    minSinceTP := na
    inTPZone   := false
// ─────────────────────────────────────────────────────────────────────────────
// 1. ENTRY — BASE ORDER (3m RSI crosses down 80)
// ─────────────────────────────────────────────────────────────────────────────
openBase = inWindow and not inPosition and strategy.opentrades == 0 and rsiCrossDn
if openBase
    baseQty = baseOrderSize / close
    if useLimitBase
        strategy.entry("Short_Base", strategy.short, qty = baseQty, limit = close, comment = "Short_Base")
    else
        strategy.entry("Short_Base", strategy.short, qty = baseQty, comment = "Short_Base")
    alert(f_msgEntry(), alert.freq_once_per_bar_close)
// ─────────────────────────────────────────────────────────────────────────────
// 2. AVERAGING ORDERS — fixed deviations ABOVE base entry (no extra condition)
// ─────────────────────────────────────────────────────────────────────────────
if inPosition and inWindow and aoFilled < aoCount and not na(baseEntry)
    nextIdx   = aoFilled + 1
    threshold = f_cumDev(nextIdx)
    triggerPx = baseEntry * (1.0 + threshold / 100.0)
    if close >= triggerPx
        aoQtyUsdt = f_aoSize(nextIdx)
        strategy.entry("Short_AO_" + str.tostring(nextIdx), strategy.short, qty = aoQtyUsdt / close, comment = "Short_AO_" + str.tostring(nextIdx))
        aoFilled := nextIdx
        alert(f_msgAddAO(), alert.freq_once_per_bar_close)
// ─────────────────────────────────────────────────────────────────────────────
// 3. EXIT — Stop Loss (hard) + Take Profit with Trailing
// ─────────────────────────────────────────────────────────────────────────────
if inPosition
    avgPx   = strategy.position_avg_price
    slPrice = avgPx * (1.0 + slPct / 100.0)
    tpPrice = avgPx * (1.0 - tpPct / 100.0)
    // Hard Stop Loss first (price moved against the short)
    if close >= slPrice
        strategy.close_all(comment = "SL")
        alert(f_msgClose(), alert.freq_once_per_bar_close)
    else
        if close <= tpPrice
            inTPZone   := true
            minSinceTP := na(minSinceTP) ? close : math.min(minSinceTP, close)
        if inTPZone
            trailStop = minSinceTP * (1.0 + trailPct / 100.0)
            if close >= trailStop
                strategy.close_all(comment = "TP_Trail")
                alert(f_msgClose(), alert.freq_once_per_bar_close)
// ─────────────────────────────────────────────────────────────────────────────
// VISUALIZATION
// ─────────────────────────────────────────────────────────────────────────────
plot(showLines and inPosition ? strategy.position_avg_price : na, title = "Avg Entry", color = color.new(color.orange, 0), linewidth = 2, style = plot.style_linebr)
plot(showLines and inPosition ? strategy.position_avg_price * (1.0 - tpPct / 100.0) : na, title = "TP Target", color = color.new(color.green, 0), linewidth = 1, style = plot.style_linebr)
plot(showLines and inPosition ? strategy.position_avg_price * (1.0 + slPct / 100.0) : na, title = "Stop Loss", color = color.new(color.red, 0), linewidth = 1, style = plot.style_linebr)
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
if showLabels and openBase
    label.new(bar_index, high, "SHORT ▼", style = label.style_label_down, color = color.new(color.red, 20), textcolor = color.white, size = size.tiny)
if showTable and barstate.islast
    var table tbl = table.new(position = position.top_right, columns = 2, rows = 8, border_width = 1)
    bg  = color.new(color.gray, 30)
    bgH = color.new(color.gray, 0)
    table.cell(tbl, 0, 0, "Status", text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 1, 0, inPosition ? "In Short" : "Flat", text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 0, 1, "AOs Filled", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 1, str.tostring(aoFilled) + " / " + str.tostring(aoCount), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 2, "Base Entry", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 2, na(baseEntry) ? "—" : str.tostring(baseEntry, "#.####"), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 3, "Avg Entry", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 3, inPosition ? str.tostring(strategy.position_avg_price, "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 4, "TP Target", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 4, inPosition ? str.tostring(strategy.position_avg_price * (1.0 - tpPct / 100.0), "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 5, "Stop Loss", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 5, inPosition ? str.tostring(strategy.position_avg_price * (1.0 + slPct / 100.0), "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 6, rsiTF + "m RSI(" + str.tostring(rsiLen) + ")", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 6, str.tostring(rsiVal, "#.#"), text_color = rsiVal > rsiLevel ? color.red : color.white, bgcolor = bg)
    table.cell(tbl, 0, 7, "Realized PnL", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 7, str.tostring(strategy.netprofit, "#.##") + " USDT (" + str.tostring(strategy.netprofit / strategy.initial_capital * 100, "#.##") + "%)", text_color = strategy.netprofit >= 0 ? color.green : color.red, bgcolor = bg)
// ─────────────────────────────────────────────────────────────────────────────
// BRAND WATERMARK
// ─────────────────────────────────────────────────────────────────────────────
var table wm = na
if showWM and barstate.islast
    if na(wm)
        wm := table.new(f_pos(wmPosStr), 1, 1, bgcolor = color.new(color.black, 100), border_width = 0)
    table.cell(wm, 0, 0, wmText, text_color = color.new(color.white, wmAlpha), text_size = f_size(wmSizeStr), bgcolor = color.new(color.black, 100))
````
