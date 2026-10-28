# BB-RSI Overbought DCA - Short Strategy

- url: https://www.tradingview.com/script/PnnQc7fs-BB-RSI-Overbought-DCA-Short-Strategy/
- type: strategy
- pine_id: PUB;2d3e510ef9194c6a9e46ade8180bc676
- version: 1.0

## Description

BB-RSI Overbought DCA — Short Strategy

🔷 What it does:
This is a short-only DCA strategy that fades overbought thrusts confirmed by two independent volatility-and-momentum filters on a lower timeframe. A short entry opens only when Bollinger Bands %B crosses up the upper band AND RSI crosses up an overbought threshold at the same lower-timeframe close — the dual confirmation requires both volatility-expansion and momentum-overheat to align. Nine safety orders form a wide deviation ladder for adverse upward price action. Exit is a fixed percentage Take Profit below the running average entry. No trailing, no Stop Loss.
  - Single base order with up to nine safety orders, sized at a 1.03× progression for soft compounding.
  - Dual-filter entry: BB %B(20, 2.0) crossing up 1.00 AND RSI(7) crossing up 65, both on 30m.
  - Wide deviation ladder: 0.72% to first safety order, 1.55× step multiplier — last safety order at ~63% above base entry.
  - Take Profit: 2.11% below average entry. No trailing.
  - Every entry, safety order, and exit emits a webhook-ready JSON alert payload for direct DCA Bot consumption.

🔷 Who is it for:
  - Swing traders looking for high-win-rate short exposure on crypto perpetuals that frequently overshoot resistance.
  - Bot operators who want a mechanical fade engine with dual confirmation and bounded position size.
  - Risk-conscious operators — at default settings the maximum deployed capital is ~8.93% of equity, and the realized maximum drawdown over a 2.5-year sample stayed at 1.53%.
  - Traders building a low-correlation portfolio: a defensive short with very low DD and an exceptional profit factor pairs well with directional long strategies.

🔷 How does it work:
  Bollinger Bands %B Filter: A 30-minute Bollinger Bands(20, 2.0) is sampled via request.security and converted to %B = (close − lower) / (upper − lower). When %B crosses up the configured level (default 1.00 — price exiting the upper band), the BB gate is satisfied. The 30-minute timeframe is sampled with lookahead disabled to avoid repaint.
  RSI Filter: A 30-minute RSI(7) is sampled in parallel. When RSI crosses up the configured level (default 65 — entering overbought), the RSI gate is satisfied. Both gates must be satisfied at the same host-bar close to arm a base entry.
  Entry: When both filters cross up on the same host bar, a short position opens at the base order size. The base order is configurable as Market (default) or Limit at the bar's close.
  Safety Order Ladder: After the base fill, the strategy monitors price deviation upward against the position. The k-th safety order fires when close ≥ base entry × (1 + cumulative deviation), where cumulative deviation grows by the step multiplier (default 1.55). At default settings: 0.72%, 1.84%, 3.57%, 6.25%, 10.40%, 16.48%, 25.90%, 40.51%, 63.14%. Each safety order's size grows by the size multiplier (default 1.03) — soft compounding rather than aggressive martingale.
  Exit: A fixed Take Profit at 2.11% below the running average entry. The position closes the moment close ≤ TP target. No trailing, no Stop Loss.

🔷 Why it's unique:
  - Dual-Filter Confirmation: Two independent signals on the same lower timeframe must align. %B captures volatility expansion (price extension beyond statistical bounds); RSI captures momentum exhaustion. Together they filter out either-or noise that would trigger single-condition strategies.
  - Soft Compounding Ladder: The 1.03× size multiplier is much gentler than typical martingale (1.5–2.0×). It still scales position size with adverse drift but doesn't blow up capital deployment if all safety orders fill.
  - Bounded Position Cap: With 9 safety orders at 1.03× progression, the maximum deployed capital is exactly base + 80 × 10.159 = 893 USDT per trade ≈ 8.93% of default equity. Inside the conventional 5–10% per-trade band, no surprises.
  - DCA Bot Integration: Every event (base, AO 1–9, exit) emits a fully-formed JSON alert payload. Connect one alert to a DCA Bot's webhook URL and the strategy drives the bot end-to-end.

🔷 Considerations Before Using the Strategy:
  Market & Timeframe: Defaults are calibrated for BYBIT:ATOMUSDT perpetual on 30m. The dual-filter combination is portable to other liquid crypto perpetuals that mean-revert from overbought stretches, but filter thresholds (BB level, RSI level) should be reviewed before redeployment.
  Strong Uptrends: Like any fade-the-strength setup, this strategy is positioned for ranges and rotations, not breakouts. In sustained uptrends the strategy may fill the entire 9-AO ladder and hold the short while price grinds higher. The dual filter limits exposure to confirmed overbought conditions, which historically have higher mean-reversion expectancy, but a regime shift to a strong trend requires manual oversight.
  Performance Profile: This is a high-confidence, low-volatility, low-return defensive short. Over the 2.5-year backtest the strategy returned +3.95% with a 1.53% maximum drawdown — annualized return is modest, but the return-to-DD ratio of ~2.6 and profit factor of 6.23 reflect very tight risk control. Size accordingly: this is a portfolio contributor, not a standalone alpha source.
  Funding Rates (Perpetuals): Backtests do not account for perpetual funding rates. Sustained positive funding on ATOMUSDT.P (longs pay shorts) would improve live performance; sustained negative funding (shorts pay longs) would degrade it. Review the historical funding pattern before live deployment.
  Commission Calibration: The default commission (0.4%) is set high as a conservative assumption. The actual Bybit perpetual taker fee is approximately 0.06%, so live performance with realistic Bybit fees should be meaningfully better than the published numbers. Update the commission input to match your fee tier for accurate forward expectations.
  No Stop Loss Justification: There is no exit on adverse moves beyond the 9-AO ladder. Per-trade risk is structurally capped by the bounded position-size ladder — at defaults that is 893 USDT max deployed = 8.93% of equity, inside the conventional 5–10% per-trade band. If a hard stop is required at the exchange level, layer it on the bot side.

🔷 STRATEGY PROPERTIES
  Symbol: BYBIT:ATOMUSDT.P (Perpetual)
  Timeframe: 30M
  Test Period: Mar 1, 2025 — Apr 1, 2026 (~1.1 years).
  Initial Capital: 10,000 USDT.
  Order Size per Trade: 0.8% of Capital base + 9 safety orders at 1.03× progression.
  Max Capital Deployed: ~893 USDT per trade (~8.93% of equity).
  Commission: 0.4% per trade (conservative — Bybit perpetual taker is ~0.06%).
  Slippage: 3 ticks.
  Margin for Short Positions: 100%.
  Indicator Settings: Default Configuration.
  Base Order: 80 USDT, Market by default (Limit toggle available).
  Take Profit: 2.11% below average entry (no trailing).
  Stop Loss: None — bounded position size is the structural risk cap.
  BB %B Filter: 30m BB(20, 2.0), Crossing Up 1.00.
  RSI Filter: 30m RSI(7), Crossing Up 65.
  Averaging Orders: 9, Deviation 0.72%, Deviation Step 1.55×, Size Multiplier 1.03×.
  Strategy: Short Only.

🔷 STRATEGY RESULTS
  ⚠️ Remember, past results do not guarantee future performance.
  Net Profit: +395.18 USDT (+3.95%)
  Max Equity Drawdown: 154.46 USDT (1.53%)
  Total Closed Trades: 267
  Percent Profitable: 79.78% (213 / 267)
  Profit Factor: 6.23

🔷 How to Use It:
  🔸 Adjust Settings: Open the strategy inputs and review the Base Order Size, BB filter (period / deviation / level), RSI filter (length / level), the 9-AO ladder, and the Take Profit percentage. Defaults are calibrated for ATOMUSDT.P 30m — recalibrate per asset before deploying.
  🔸 Results Review: Run a full-period backtest and confirm Max Drawdown stays inside your personal risk band. Validate that the closed-trade count is statistically meaningful (≥ 100 is a reasonable floor). Update commission to match your exchange's actual fees.
  🔸 Create alerts to trigger the DCA Bot: Add one alert on the strategy using "Any alert() function call". Paste the DCA Bot's webhook URL into the alert's Webhook field, and fill the Bot ID, Email Token, and Pair inputs on the script. The strategy will emit JSON payloads for short entry, each safety order, and exit — formatted for direct DCA Bot consumption.

🔷 INDICATOR SETTINGS
  Base Order Size (USDT): USDT amount opened on the short entry.
  Use LIMIT for Base: Toggle between Market (default) and Limit at bar close.
  Averaging Orders per Trade: Maximum number of safety orders per deal (default 9).
  First AO Size (USDT): USDT size of the first safety order; subsequent AOs scale by the Size Multiplier.
  Deviation to First AO (%): Distance from base entry at which AO1 becomes eligible.
  Deviation Step Multiplier: Ladder factor that widens each subsequent deviation step.
  Order Size Multiplier: Factor that grows each subsequent safety order's USDT size.
  BB Timeframe / Period / Deviation / Level: 30-minute Bollinger Bands %B filter on the host symbol.
  RSI Timeframe / Length / Level: 30-minute RSI filter on the host symbol.
  Take Profit (%): Fixed distance from average entry where the short closes for profit.
  DCA Bot Webhook: Bot ID, Email Token, and Pair fields injected into every alert payload.
  Visualization: Toggle DCA Ladder, fill labels, status table.
  Brand Watermark: Configurable text, position, size, and transparency.

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.

__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=6
// =============================================================================
//  BB-RSI Overbought DCA — Short Strategy
//  Short-only DCA framework gated by TWO independent overbought conditions on
//  a lower timeframe: Bollinger Bands %B crossing up the upper band AND RSI
//  crossing up an overbought threshold. Nine safety orders form a deviation
//  ladder for adverse upward price action.
//  Calibrated defaults for COINBASE:ATOMUSDC on 2h timeframe.
// =============================================================================
//  NO STOP LOSS — risk is structurally capped by the bounded position-size
//  ladder. Max deployed capital across base + 9 safety orders ≈ 8.93% of
//  equity at default settings (within TradingView's 5–10% per-trade band).
// =============================================================================
strategy("BB-RSI Overbought DCA — Short Strategy", shorttitle = "BBRSI-S", overlay = true, initial_capital = 10000, default_qty_type = strategy.cash, default_qty_value = 80, pyramiding = 10, commission_type = strategy.commission.percent, commission_value = 0.4, slippage = 3, process_orders_on_close = true, calc_on_every_tick = false, max_labels_count = 500, max_lines_count = 100)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grpBase = "Base Order"
baseOrderSize = input.float(80.0, "Base Order Size (USDC)", minval = 1, group = grpBase, tooltip = "0.8% of default 10k capital. Sized so that base + all 9 AOs ≤ 8.93% of equity.")
useLimitBase  = input.bool(false, "Use LIMIT for Base (else Market)", group = grpBase, tooltip = "Source bot used LIMIT base; Market is the more honest backtest default.")

grpAO = "Averaging Orders"
aoCount    = input.int(9, "Averaging Orders per Trade", minval = 0, maxval = 15, group = grpAO)
aoSize     = input.float(80.0, "First AO Size (USDC)", minval = 1, group = grpAO)
aoStep     = input.float(0.72, "Deviation to First AO (%)", minval = 0.1, step = 0.01, group = grpAO)
aoStepMult = input.float(1.55, "Deviation Step Multiplier", minval = 1.0, step = 0.05, group = grpAO)
aoSizeMult = input.float(1.03, "Order Size Multiplier", minval = 1.0, step = 0.01, group = grpAO)

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
tpPct = input.float(2.11, "Take Profit (%)", minval = 0.1, step = 0.01, group = grpExit, tooltip = "Distance below avg entry where the short position closes for profit.")

grpDate = "Backtest Window"
useDateFilter = input.bool(true, "Limit Backtest Period", group = grpDate)
fromDate      = input.time(timestamp("10 Mar 2025 00:00 +0000"), "From", group = grpDate)
toDate        = input.time(timestamp("01 Apr 2026 23:59 +0000"), "To",   group = grpDate)

grpHook = "DCA Bot Webhook"
botId       = input.string("YOUR_BOT_ID",      "Bot ID",            group = grpHook)
emailToken  = input.string("YOUR_EMAIL_TOKEN", "Email Token",       group = grpHook)
pairWebhook = input.string("USDC_ATOM",        "Pair (QUOTE_BASE)", group = grpHook)

grpViz = "Visualization"
showLevels = input.bool(true, "Show DCA Ladder",   group = grpViz)
showLabels = input.bool(true, "Show Fill Labels",  group = grpViz)
showTable  = input.bool(true, "Show Status Table", group = grpViz)

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
bbB      = request.security(syminfo.tickerid, bbTF,  f_bbPercentB(bbPeriod, bbDev),  lookahead = barmerge.lookahead_off)
rsiVal   = request.security(syminfo.tickerid, rsiTF, ta.rsi(close, rsiLen),          lookahead = barmerge.lookahead_off)

bbCrossUp  = bbB[1]    < bbLevel  and bbB    >= bbLevel
rsiCrossUp = rsiVal[1] < rsiLevel and rsiVal >= rsiLevel

entrySignal = bbCrossUp and rsiCrossUp

// ─────────────────────────────────────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────────────────────────────────────
var float baseEntry = na
var int   aoFilled  = 0

inPosition       = strategy.position_size != 0
justEntered      = nz(strategy.position_size[1]) == 0 and inPosition
positionJustFlat = nz(strategy.position_size[1]) != 0 and not inPosition

if justEntered and na(baseEntry)
    baseEntry := strategy.position_avg_price
    aoFilled  := 0

if positionJustFlat or not inPosition
    baseEntry := na
    aoFilled  := 0

// ─────────────────────────────────────────────────────────────────────────────
// 1. ENTRY — BASE ORDER (SHORT, gated by BB %B AND RSI overbought)
// ─────────────────────────────────────────────────────────────────────────────
openBase = inWindow and not inPosition and strategy.opentrades == 0 and entrySignal
if openBase
    baseQty = baseOrderSize / close
    if useLimitBase
        strategy.entry("Short_Base", strategy.short, qty = baseQty, limit = close, comment = "Short_Base")
    else
        strategy.entry("Short_Base", strategy.short, qty = baseQty, comment = "Short_Base")
    alert(f_msgEntry(), alert.freq_once_per_bar_close)

// ─────────────────────────────────────────────────────────────────────────────
// 2. AVERAGING ORDERS (price ladder UP for short: AOs fill as price rises)
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
// 3. EXIT — Fixed TP (no trailing, no SL)
// ─────────────────────────────────────────────────────────────────────────────
if inPosition
    avgPx   = strategy.position_avg_price
    tpPrice = avgPx * (1.0 - tpPct / 100.0)
    if close <= tpPrice
        strategy.close_all(comment = "TP")
        alert(f_msgClose(), alert.freq_once_per_bar_close)

// ─────────────────────────────────────────────────────────────────────────────
// VISUALIZATION
// ─────────────────────────────────────────────────────────────────────────────
plot(inPosition ? strategy.position_avg_price : na, title = "Avg Entry", color = color.new(color.orange, 0), linewidth = 2, style = plot.style_linebr)
plot(inPosition ? strategy.position_avg_price * (1.0 - tpPct / 100.0) : na, title = "TP", color = color.new(color.green, 0), linewidth = 1, style = plot.style_linebr)

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
        ln  = line.new(x1 = bar_index - 80, x2 = bar_index + 8, y1 = px, y2 = px, color = col, style = line.style_dashed, width = 1)
        array.push(aoLines, ln)
        label.new(x = bar_index + 8, y = px, text = "AO" + str.tostring(k) + "  +" + str.tostring(dev, "#.##") + "%", style = label.style_label_left, color = color.new(color.gray, 70), textcolor = color.white, size = size.tiny)

if showLabels and openBase
    label.new(bar_index, low, "Base ▼", style = label.style_label_up, color = color.new(color.red, 20), textcolor = color.white, size = size.tiny)

if showTable and barstate.islast
    var table tbl = table.new(position = position.top_right, columns = 2, rows = 7, border_width = 1)
    bg  = color.new(color.gray, 30)
    bgH = color.new(color.gray, 0)
    table.cell(tbl, 0, 0, "Status",          text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 1, 0, inPosition ? "In Short" : "Flat", text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 0, 1, "AOs Filled",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 1, str.tostring(aoFilled) + " / " + str.tostring(aoCount), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 2, "Base Entry",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 2, na(baseEntry) ? "—" : str.tostring(baseEntry, "#.####"), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 3, "Avg Entry",       text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 3, inPosition ? str.tostring(strategy.position_avg_price, "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 4, "TP Target",       text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 4, inPosition ? str.tostring(strategy.position_avg_price * (1.0 - tpPct / 100.0), "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 5, bbTF + " BB %B",   text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 5, str.tostring(bbB, "#.###"), text_color = bbB > bbLevel ? color.red : color.white, bgcolor = bg)
    table.cell(tbl, 0, 6, rsiTF + " RSI(" + str.tostring(rsiLen) + ")", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 6, str.tostring(rsiVal, "#.#"), text_color = rsiVal > rsiLevel ? color.red : color.white, bgcolor = bg)

// ─────────────────────────────────────────────────────────────────────────────
// BRAND WATERMARK
// ─────────────────────────────────────────────────────────────────────────────
var table wm = na
if showWM and barstate.islast
    if na(wm)
        wm := table.new(f_pos(wmPosStr), 1, 1, bgcolor = color.new(color.black, 100), border_width = 0)
    table.cell(wm, 0, 0, wmText, text_color = color.new(color.white, wmAlpha), text_size = f_size(wmSizeStr), bgcolor = color.new(color.black, 100))
````
