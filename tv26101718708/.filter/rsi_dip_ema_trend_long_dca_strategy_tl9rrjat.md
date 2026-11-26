# RSI Dip + EMA Trend Long DCA - Strategy

- url: https://www.tradingview.com/script/Tl9RRJAT-RSI-Dip-EMA-Trend-Long-DCA-Strategy/
- type: strategy
- pine_id: PUB;4e21c751a380404f806aa9d2628c4fc9
- version: 1.0

## Description

RSI Dip + EMA Trend Long DCA — Leveraged Strategy

🔷 What it does:
This is a long-only DCA strategy on leveraged crypto perpetuals that buys oversold dips inside confirmed uptrends. A long entry opens only when the lower-timeframe RSI crosses down into oversold territory AND a higher-timeframe EMA cross confirms the larger trend is up. Four safety orders form a pure-price deviation ladder. Exit is a tight Take Profit with trailing, OR a hard Stop Loss, OR a forced close after a maximum holding period.
  - Single base order with up to four safety orders, soft 1.05× size compounding.
  - Dual confirmation entry: RSI(12) crossing down 35 on 5m AND EMA(50) > EMA(100) on 15m.
  - Three exit paths: 1.0% Take Profit with 0.1% trailing, 9% hard Stop Loss, or forced market close after 3 days max hold.
  - Default leverage 25× — per-trade realized risk ~7.17% of equity (inside the 5–10% band).
  - Every entry, safety order, and exit emits a webhook-ready JSON alert payload for direct DCA Bot consumption.

🔷 Who is it for:
  - Active traders comfortable with leveraged crypto perpetuals who want a systematic dip-buying engine inside confirmed uptrends.
  - Bot operators who want a chart-driven signal source with per-event JSON ready for a DCA Bot configured for leveraged futures.
  - Traders looking to combine momentum exhaustion (RSI dip) with trend confirmation (EMA stack) for higher-confidence entries.
  - Portfolio operators who can absorb a 15–20% maximum drawdown in exchange for ~30% trailing returns over comparable periods.

🔷 How does it work:
  Entry RSI Filter (Oversold Dip): A 5-minute RSI(12) is sampled via request.security with lookahead disabled. The dip gate fires when RSI crosses down through 35 — momentum has rolled over into oversold, which on a confirmed uptrend often marks a tactical bounce point.
  EMA Trend Filter: A 15-minute EMA(50) and EMA(100) are sampled in parallel. The trend gate is satisfied only while Fast EMA > Slow EMA — the broader trend is up. When the EMA cross flips, the dip signal alone cannot open a trade.
  Entry: When both gates align at host-bar close, a long position opens. Base order is configurable as Market (default) or Limit. With default 25× leverage, base margin × leverage = notional position size.
  Safety Order Ladder: After base fill, the strategy monitors price deviation downward against the position. No additional gating — pure price ladder. The k-th safety order fires when close ≤ base entry × (1 − cumulative deviation), where cumulative deviation grows by the step multiplier (default 1.2): 1.00%, 2.20%, 3.64%, 5.37%. Each safety order's USDT margin grows by 1.05× — soft compounding.
  Exit Priority: Three exit paths evaluated in order on each bar: (1) Stop Loss at 9% below average entry, (2) Maximum Hold timeout at 3 days from base entry, (3) Take Profit at 1% above average entry with 0.1% trailing — once price reaches the TP target, the position closes only after a 0.1% retrace from the in-favor peak.

🔷 Why it's unique:
  - Two-Layer Confirmation: RSI(12) dip on 5m for entry timing, EMA(50/100) on 15m for trend bias. The two filters operate on different scales — momentum exhaustion alone cannot open a trade against a confirmed downtrend, and trend alignment alone cannot open a trade outside a tactical entry window.
  - Three-Exit Architecture: Hard Stop Loss for tail-risk protection, Maximum Hold timeout for stuck trades that don't reach either bound, and Take Profit with trailing for letting winners run. Most DCA strategies use one or two exits; this one explicitly handles all three failure modes.
  - Leverage-Aware Sizing: Base margin and leverage are independent inputs. Margin sets the per-trade capital commitment; leverage sets the notional exposure. Per-trade risk at SL = base + SO margins × SL% — bounded and predictable.
  - DCA Bot Integration: Every event (base, SO 1–4, TP/SL/MaxHold close) emits a fully-formed JSON alert payload. Connect one alert to a DCA Bot's webhook URL and the strategy drives the bot end-to-end.

🔷 Considerations Before Using the Strategy:
  Market & Timeframe: Defaults are calibrated for BYBIT:XMRUSDT perpetual on 15m. The dip-buying-in-uptrend logic is portable to other liquid crypto perpetuals with clear directional regimes, but the EMA periods and RSI thresholds should be reviewed before redeployment.
  Leverage Warning: The default 25× leverage is aggressive. A 9% adverse price move at 25× leverage equals 225% of base margin — the Stop Loss closes the position at full margin loss before liquidation. The per-trade realized risk at SL is approximately 7.17% of equity at default base margin (60 USDT). Lower the leverage input or reduce base margin to dial down per-trade exposure.
  Drawdown Profile: The backtest produced a 18.01% maximum equity drawdown over a 14-month sample with 779 closed trades. This is above TradingView's typical 5–10% per-trade band — but the figure reflects portfolio-level accumulation of losing trades across an adverse period, not single-trade risk. Per-trade risk remains inside the 5–10% band; the portfolio-level DD reflects the leveraged compounding and should be sized accordingly within a diversified strategy mix.
  No SO Condition: Safety orders fire on pure price ladder with no momentum gate. This means averaging continues unconditionally as price drops, until either SL fires or the price reverses. The trade-off: higher average-entry quality if the dip continues, but greater unrealized loss exposure during sharp drops.
  Maximum Hold Period: The 3-day forced close exists to release capital from stuck trades that haven't reached TP or SL. On a 15m chart, this is approximately 288 bars. Adjust the timeout to match your strategy rotation cadence.
  Funding Rates (Perpetuals): Backtests do not account for perpetual funding rates. Sustained negative funding (shorts pay longs) improves live performance for this long strategy; sustained positive funding degrades it. Review the historical funding pattern before live deployment.
  Demo Testing: Always demo-test before going live. Past results do not guarantee future performance, especially on leveraged strategies where small parameter changes materially affect risk.

🔷 STRATEGY PROPERTIES
  Symbol: BYBIT:XMRUSDT.P (Perpetual)
  Timeframe: 15M
  Test Period: April 1, 2025 — May 26, 2026 (~14 months).
  Initial Capital: 10,000 USDT.
  Order Size per Trade: 60 USDT margin × 25× leverage = 1,500 USDT notional base + 4 safety orders at 1.05× progression.
  Max Capital Deployed (Margin): ~318.6 USDT per trade across base + 4 SOs.
  Max Realized Loss per Trade: ~717 USDT at full ladder + SL (~7.17% of equity).
  Commission: 0.05% per trade.
  Slippage: 3 ticks.
  Leverage: 25× (configurable).
  Margin for Long Positions: 100%.
  Indicator Settings: Default Configuration.
  Base Order: 60 USDT margin, Market by default (Limit toggle available).
  Take Profit: 1.0% above average entry with 0.1% trailing.
  Stop Loss: 9% below average entry (hard close).
  Max Hold: 3 days (259,200 seconds) — forced market close.
  Entry Filter: 5m RSI(12) Crossing Down 35 AND 15m EMA(50) > EMA(100).
  Safety Orders: 4, Deviation 1.0%, Deviation Step 1.2×, Size Multiplier 1.05×.
  Strategy: Long Only.

🔷 STRATEGY RESULTS
  ⚠️ Remember, past results do not guarantee future performance.
  Net Profit: +3,078.80 USDT (+30.79%)
  Max Equity Drawdown: 2,013.77 USDT (18.01%)
  Total Closed Trades: 779
  Percent Profitable: 74.07% (577 / 779)
  Profit Factor: 1.313

🔷 How to Use It:
  🔸 Adjust Settings: Open the strategy inputs and review the Base Margin, Leverage, entry filter (RSI level on 5m, EMA periods on 15m), the 4-SO ladder, and the three exit conditions. Defaults are calibrated for XMRUSDT.P 15m at 25× leverage — recalibrate per asset and per risk profile before deploying.
  🔸 Results Review: Run a full-period backtest and confirm Max Drawdown stays inside your personal risk band. The 18% DD at default settings reflects 25× leverage — lower the leverage input to scale risk down proportionally. Validate the closed-trade count (≥ 100 minimum is a comfortable statistical floor).
  🔸 Create alerts to trigger the DCA Bot: Add one alert on the strategy using "Any alert() function call". Paste the DCA Bot's webhook URL into the alert's Webhook field, and fill the Bot ID, Email Token, and Pair inputs on the script. The strategy will emit JSON payloads for entry, each safety order, and all three exit types — formatted for direct DCA Bot consumption.

🔷 INDICATOR SETTINGS
  Base Order Margin (USDT): Margin per base trade. Notional = Margin × Leverage.
  Leverage (×): Exchange leverage. Default 25× — adjust to match your account configuration.
  Use LIMIT for Base: Toggle between Market (default) and Limit at bar close.
  Max Safety Orders: Maximum number of safety orders per deal (default 4).
  First SO Margin (USDT): USDT margin of the first safety order; subsequent SOs scale by the Size Multiplier.
  Step to First SO (%): Distance from base entry at which SO1 becomes eligible.
  Step Multiplier: Ladder factor that widens each subsequent deviation step.
  Size Multiplier: Factor that grows each subsequent safety order's USDT margin.
  Entry RSI Timeframe / Length / Level: Lower-timeframe RSI oversold-dip filter.
  EMA Timeframe / Fast / Slow: Higher-timeframe trend confirmation filter.
  Take Profit (%) / Trailing Deviation (%): TP target above avg entry and trailing buffer.
  Stop Loss (%): Hard stop below avg entry.
  Force Close After Max Hold / Max Hold (seconds): Timeout for forced market close.
  DCA Bot Webhook: Bot ID, Email Token, and Pair fields injected into every alert payload.
  Visualization: Toggle SO Ladder, Avg / TP / SL plot lines, fill labels, status table.
  Brand Watermark: Configurable text, position, size, and transparency.

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.

__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=6
// =============================================================================
//  RSI Dip + EMA Trend Long DCA — Leveraged Strategy
//  Long-only DCA framework on leveraged perpetuals. Entry buys oversold dips
//  on a fast LTF (RSI crossing below 35) AND confirmed uptrend on a slower LTF
//  (EMA50 > EMA100). Four safety orders form a pure-price deviation ladder
//  with no additional gating. Exit is tight Take Profit with trailing, hard
//  Stop Loss, OR a forced close after a maximum holding period.
//  Calibrated defaults for BYBIT:XMRUSDT.P on 15m timeframe (25× leverage).
// =============================================================================
//  NOTE: 3Commas runtime features "Risk Reduction" (100%) and "Reinvesting"
//  (100%) are not directly modelled here. Pine compounds equity natively via
//  default_qty_type=strategy.cash, and position-size adjustments after losses
//  can be layered on by the user via leverage and base-margin inputs.
// =============================================================================
strategy("RSI Dip + EMA Trend Long DCA — Leveraged Strategy", shorttitle = "RSIEMA-L", overlay = true, initial_capital = 10000, default_qty_type = strategy.cash, default_qty_value = 1500, pyramiding = 5, commission_type = strategy.commission.percent, commission_value = 0.05, slippage = 3, process_orders_on_close = true, calc_on_every_tick = false, max_labels_count = 500, max_lines_count = 100)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grpBase = "Base Order (Margin × Leverage)"
baseMargin   = input.float(60.0, "Base Order Margin (USDT)", minval = 1, group = grpBase, tooltip = "Margin per base trade. With default 25× leverage, notional = 1,500 USDT per base (15% of equity notional).")
leverage     = input.float(25.0, "Leverage (×)", minval = 1.0, maxval = 100.0, step = 1.0, group = grpBase)
useLimitBase = input.bool(false, "Use LIMIT for Base (else Market)", group = grpBase, tooltip = "Source bot used LIMIT; Market is the more honest backtest default.")

grpSO = "Safety Orders"
soCount    = input.int(4, "Max Safety Orders", minval = 0, maxval = 10, group = grpSO)
soMargin   = input.float(60.0, "First SO Margin (USDT)", minval = 1, group = grpSO)
soStep     = input.float(1.0, "Step to First SO (%)", minval = 0.1, step = 0.1, group = grpSO)
soStepMult = input.float(1.2, "Step Multiplier", minval = 1.0, step = 0.05, group = grpSO)
soSizeMult = input.float(1.05, "Size Multiplier", minval = 1.0, step = 0.01, group = grpSO)

grpEntryRSI = "Entry RSI Filter (Oversold Dip)"
entryRsiTF    = input.timeframe("5", "RSI Timeframe", group = grpEntryRSI)
entryRsiLen   = input.int(12, "RSI Length", minval = 2, group = grpEntryRSI)
entryRsiLevel = input.float(35.0, "RSI Crossing Down Level", minval = 1, maxval = 100, group = grpEntryRSI, tooltip = "Entry arms when LTF RSI crosses down this level (oversold dip).")

grpEMA = "EMA Trend Filter"
emaTF     = input.timeframe("15", "EMA Timeframe", group = grpEMA)
emaFast   = input.int(50,  "Fast EMA Length",  minval = 2, group = grpEMA)
emaSlow   = input.int(100, "Slow EMA Length", minval = 2, group = grpEMA, tooltip = "Trend confirmation: only enter when Fast EMA > Slow EMA on the trend timeframe.")

grpExit = "Exit"
tpPct    = input.float(1.0, "Take Profit (%)", minval = 0.1, step = 0.1, group = grpExit)
trailDev = input.float(0.1, "Trailing Deviation (%)", minval = 0.05, step = 0.05, group = grpExit, tooltip = "Once TP target is reached, the position closes only after price retraces this far from the peak.")
slPct    = input.float(9.0, "Stop Loss (%)", minval = 0.1, step = 0.1, group = grpExit, tooltip = "Hard stop from average entry. With 25× leverage, a 9% adverse move ≈ 225% of margin (full liquidation).")

grpHold = "Max Hold Period"
useMaxHold     = input.bool(true, "Force Close After Max Hold", group = grpHold)
maxHoldSeconds = input.int(259200, "Max Hold (seconds)", minval = 60, group = grpHold, tooltip = "Default 259200 = 3 days. Position closes at market if not exited by TP or SL within this window.")

grpDate = "Backtest Window"
useDateFilter = input.bool(true, "Limit Backtest Period", group = grpDate)
fromDate      = input.time(timestamp("31 Jan 2024 00:00 +0000"), "From", group = grpDate)
toDate        = input.time(timestamp("06 Jan 2026 23:59 +0000"), "To",   group = grpDate)

grpHook = "DCA Bot Webhook"
botId       = input.string("YOUR_BOT_ID",      "Bot ID",            group = grpHook)
emailToken  = input.string("YOUR_EMAIL_TOKEN", "Email Token",       group = grpHook)
pairWebhook = input.string("USDT_XMR",         "Pair (QUOTE_BASE)", group = grpHook)

grpViz = "Visualization"
showLevels = input.bool(true, "Show SO Ladder",      group = grpViz)
showLabels = input.bool(true, "Show Fill Labels",    group = grpViz)
showLines  = input.bool(true, "Plot Avg / TP / SL",  group = grpViz)
showTable  = input.bool(true, "Show Status Table",   group = grpViz)

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
f_cumDev(int k) =>
    float dev  = 0.0
    float step = soStep
    for i = 1 to k
        if i == 1
            dev := step
        else
            step := step * soStepMult
            dev  := dev + step
    dev

f_soMargin(int k) =>
    soMargin * math.pow(soSizeMult, k - 1)

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
entryRsi      = request.security(syminfo.tickerid, entryRsiTF, ta.rsi(close, entryRsiLen), lookahead = barmerge.lookahead_off)
entryCrossDown = entryRsi[1] > entryRsiLevel and entryRsi <= entryRsiLevel

emaFastVal = request.security(syminfo.tickerid, emaTF, ta.ema(close, emaFast), lookahead = barmerge.lookahead_off)
emaSlowVal = request.security(syminfo.tickerid, emaTF, ta.ema(close, emaSlow), lookahead = barmerge.lookahead_off)
condTrend  = emaFastVal > emaSlowVal

entrySignal = entryCrossDown and condTrend

// ─────────────────────────────────────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────────────────────────────────────
var float baseEntry    = na
var int   soFilled     = 0
var float trailingPeak = na
var bool  inTPZone     = false
var int   entryTime    = na

inPosition       = strategy.position_size != 0
justEntered      = nz(strategy.position_size[1]) == 0 and inPosition
positionJustFlat = nz(strategy.position_size[1]) != 0 and not inPosition

if justEntered and na(baseEntry)
    baseEntry    := strategy.position_avg_price
    soFilled     := 0
    trailingPeak := na
    inTPZone     := false
    entryTime    := time

if positionJustFlat or not inPosition
    baseEntry    := na
    soFilled     := 0
    trailingPeak := na
    inTPZone     := false
    entryTime    := na

// ─────────────────────────────────────────────────────────────────────────────
// 1. ENTRY — BASE ORDER (RSI cross down AND EMA trend confirmation)
// ─────────────────────────────────────────────────────────────────────────────
openBase = inWindow and not inPosition and strategy.opentrades == 0 and entrySignal
if openBase
    notional = baseMargin * leverage
    qty      = notional / close
    if useLimitBase
        strategy.entry("Long_Base", strategy.long, qty = qty, limit = close, comment = "Long_Base")
    else
        strategy.entry("Long_Base", strategy.long, qty = qty, comment = "Long_Base")
    alert(f_msgEntry(), alert.freq_once_per_bar_close)

// ─────────────────────────────────────────────────────────────────────────────
// 2. SAFETY ORDERS (pure deviation ladder, no condition gate)
// ─────────────────────────────────────────────────────────────────────────────
if inPosition and inWindow and soFilled < soCount and not na(baseEntry)
    nextIdx   = soFilled + 1
    threshold = f_cumDev(nextIdx)
    triggerPx = baseEntry * (1.0 - threshold / 100.0)
    if close <= triggerPx
        soNotional = f_soMargin(nextIdx) * leverage
        soQty      = soNotional / close
        strategy.entry("Long_SO_" + str.tostring(nextIdx), strategy.long, qty = soQty, comment = "Long_SO_" + str.tostring(nextIdx))
        soFilled := nextIdx
        alert(f_msgAddAO(), alert.freq_once_per_bar_close)

// ─────────────────────────────────────────────────────────────────────────────
// 3. EXIT — Hard SL → Max Hold → TP with trailing
// ─────────────────────────────────────────────────────────────────────────────
var bool closedThisBar = false
closedThisBar := false

if inPosition
    avgPx   = strategy.position_avg_price
    tpPrice = avgPx * (1.0 + tpPct / 100.0)
    slPrice = avgPx * (1.0 - slPct / 100.0)

    // SL — hard stop
    if close <= slPrice
        strategy.close_all(comment = "SL")
        alert(f_msgClose(), alert.freq_once_per_bar_close)
        closedThisBar := true

    // Max hold — force close after timeout
    if not closedThisBar and useMaxHold and not na(entryTime)
        holdMs = time - entryTime
        if holdMs >= maxHoldSeconds * 1000
            strategy.close_all(comment = "MaxHold")
            alert(f_msgClose(), alert.freq_once_per_bar_close)
            closedThisBar := true

    // TP with trailing — armed once price reaches TP zone
    if not closedThisBar
        if close >= tpPrice
            inTPZone     := true
            trailingPeak := na(trailingPeak) ? close : math.max(trailingPeak, close)
        if inTPZone and not na(trailingPeak)
            trailStop = trailingPeak * (1.0 - trailDev / 100.0)
            if close <= trailStop
                strategy.close_all(comment = "TP_Trail")
                alert(f_msgClose(), alert.freq_once_per_bar_close)
                closedThisBar := true

// ─────────────────────────────────────────────────────────────────────────────
// VISUALIZATION
// ─────────────────────────────────────────────────────────────────────────────
plot(showLines and inPosition ? strategy.position_avg_price : na, title = "Avg Entry", color = color.new(color.orange, 0), linewidth = 2, style = plot.style_linebr)
plot(showLines and inPosition ? strategy.position_avg_price * (1.0 + tpPct / 100.0) : na, title = "TP", color = color.new(color.green, 0), linewidth = 1, style = plot.style_linebr)
plot(showLines and inPosition ? strategy.position_avg_price * (1.0 - slPct / 100.0) : na, title = "SL", color = color.new(color.red, 0),   linewidth = 1, style = plot.style_linebr)

var soLines = array.new<line>()

if barstate.islast and showLevels and not na(baseEntry)
    if array.size(soLines) > 0
        for i = 0 to array.size(soLines) - 1
            line.delete(array.get(soLines, i))
        array.clear(soLines)
    for k = 1 to soCount
        dev = f_cumDev(k)
        px  = baseEntry * (1.0 - dev / 100.0)
        col = k <= soFilled ? color.new(color.green, 10) : color.new(color.gray, 60)
        wid = k <= soFilled ? 2 : 1
        ln  = line.new(x1 = bar_index - 80, x2 = bar_index + 8, y1 = px, y2 = px, color = col, style = line.style_dashed, width = wid)
        array.push(soLines, ln)
        label.new(x = bar_index + 8, y = px, text = "SO" + str.tostring(k) + "  -" + str.tostring(dev, "#.##") + "%", style = label.style_label_left, color = color.new(color.gray, 70), textcolor = color.white, size = size.tiny)

if showLabels and openBase
    label.new(bar_index, low, "LONG ▲", style = label.style_label_up, color = color.new(color.green, 20), textcolor = color.white, size = size.tiny)

if showTable and barstate.islast
    var table tbl = table.new(position = position.top_right, columns = 2, rows = 9, border_width = 1)
    bg  = color.new(color.gray, 30)
    bgH = color.new(color.gray, 0)
    table.cell(tbl, 0, 0, "Status",         text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 1, 0, inPosition ? "In Long" : "Flat", text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 0, 1, "SOs Filled",     text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 1, str.tostring(soFilled) + " / " + str.tostring(soCount), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 2, "Base Entry",     text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 2, na(baseEntry) ? "—" : str.tostring(baseEntry, "#.####"), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 3, "Avg Entry",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 3, inPosition ? str.tostring(strategy.position_avg_price, "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 4, "TP Target",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 4, inPosition ? str.tostring(strategy.position_avg_price * (1.0 + tpPct / 100.0), "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 5, "SL Level",       text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 5, inPosition ? str.tostring(strategy.position_avg_price * (1.0 - slPct / 100.0), "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 6, entryRsiTF + " RSI(" + str.tostring(entryRsiLen) + ")", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 6, str.tostring(entryRsi, "#.#"), text_color = entryRsi <= entryRsiLevel ? color.green : color.white, bgcolor = bg)
    table.cell(tbl, 0, 7, emaTF + " EMA " + str.tostring(emaFast) + "/" + str.tostring(emaSlow), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 7, condTrend ? "Up ▲" : "Down ▼", text_color = condTrend ? color.green : color.red, bgcolor = bg)
    holdLeftSec = inPosition and not na(entryTime) ? math.max(0, maxHoldSeconds - int((time - entryTime) / 1000)) : 0
    table.cell(tbl, 0, 8, "Hold Left (s)",  text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 8, inPosition and useMaxHold ? str.tostring(holdLeftSec) : "—", text_color = color.white, bgcolor = bg)

// ─────────────────────────────────────────────────────────────────────────────
// BRAND WATERMARK
// ─────────────────────────────────────────────────────────────────────────────
var table wm = na
if showWM and barstate.islast
    if na(wm)
        wm := table.new(f_pos(wmPosStr), 1, 1, bgcolor = color.new(color.black, 100), border_width = 0)
    table.cell(wm, 0, 0, wmText, text_color = color.new(color.white, wmAlpha), text_size = f_size(wmSizeStr), bgcolor = color.new(color.black, 100))
````
