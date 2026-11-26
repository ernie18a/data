# RSI Dip + EMA Trend Long DCA - Indicator

- url: https://www.tradingview.com/script/iE1pTnPv-RSI-Dip-EMA-Trend-Long-DCA-Indicator/
- type: indicator
- pine_id: PUB;d3376c40381a419ebae49bd03f8cb0e5
- version: 1.0

## Description

RSI Dip + EMA Trend Long DCA — Leveraged Indicator

🔷 What it does:
This is a signal-only indicator that mirrors a leveraged dip-buying DCA workflow on crypto perpetuals. It tracks one virtual long position at a time, opened only when an oversold dip and an uptrend confirmation align across two lower timeframes. The indicator manages up to four safety orders as price ladders lower, and exits via three independent paths: take profit with trailing, hard stop loss, or a forced close after a maximum holding period. Every event emits a webhook-ready JSON payload tailored for a DCA Bot configured for leveraged futures.
  - Dual confirmation entry: RSI(12) crossing down 35 on 5m AND EMA(50) > EMA(100) on 15m.
  - Soft-compounding safety ladder: 4 SOs at 1.05× margin progression, deviations 1.00%, 2.20%, 3.64%, 5.37%.
  - Three-exit architecture: 1.0% Take Profit with 0.1% trailing, 9% hard Stop Loss, 3-day Max Hold timeout.
  - Default leverage 25×, configurable from 1× upward.
  - Honest virtual bookkeeping: total notional and qty updated per fill, avg entry / open PnL displayed live.

🔷 Who is it for:
  - Active traders running a DCA Bot on leveraged crypto perpetuals who want a systematic dip-buying engine.
  - Bot operators who want a chart-driven signal source with per-event JSON ready for a DCA Bot.
  - Traders who want to monitor an evolving leveraged position — base entry, owned SO levels, deployed notional, open PnL, time-to-max-hold — directly on the chart.
  - Operators comfortable with portfolio-level drawdowns in the 15–20% range in exchange for accelerated returns.

🔷 How does it work:
  Entry RSI Filter (Oversold Dip): A 5-minute RSI(12) is sampled via request.security with lookahead disabled. The dip gate fires when RSI crosses down through 35 — momentum has rolled over into oversold.
  EMA Trend Filter: A 15-minute EMA(50) and EMA(100) are sampled in parallel. The trend gate is satisfied only while Fast EMA > Slow EMA — broader trend is up. When the EMA cross flips, the dip signal alone cannot open a virtual position.
  Entry: When both gates align at host-bar close, the indicator marks a virtual long entry, captures the base entry price, seeds the cost-basis ledger with base margin × leverage notional, and fires the entry webhook payload.
  Safety Order Ladder: After base fill, the indicator monitors close price downward against the position. When close reaches base entry × (1 − cumulative deviation), the k-th SO is marked filled, cost-basis is updated, and the SO webhook payload is fired. No additional gating on the SO ladder — pure price.
  Honest Virtual Bookkeeping: Total notional and qty are updated incrementally on every event, so the avg entry, deployed notional, and open PnL displayed in the status table reflect the actual broker-equivalent position state — no shortcut from base entry, no synthetic averaging.
  Exit Priority: Three exits evaluated in order on each bar: (1) Stop Loss at 9% below average entry, (2) Maximum Hold timeout from base entry, (3) Take Profit at 1.0% above average entry with 0.1% trailing — once price reaches the TP target, the position closes only after a 0.1% retrace from the in-favor peak.

🔷 Why it's unique:
  - Two-Layer Confirmation: RSI dip on 5m for timing, EMA stack on 15m for trend bias. The two filters operate on different scales — momentum exhaustion alone cannot fire a signal against a confirmed downtrend, and trend alignment alone cannot fire outside a tactical entry window.
  - Three-Exit Architecture: Most DCA tools use one or two exit conditions. This indicator handles all three failure modes explicitly — hard tail-risk stop, stuck-trade timeout release, and momentum-trailing winner exit.
  - Leverage-Aware Sizing: Margin and leverage are independent inputs. The virtual ledger tracks notional position, so the avg-entry line and open PnL reflect the leveraged broker state, not unleveraged cash-only math.
  - Per-Event Webhook Ledger: Up to seven distinct events per cycle (entry + 4 SO fills + close + max-hold/SL), each with its own JSON alert payload. The indicator drives a DCA Bot end-to-end through a single TradingView alert.

🔷 Considerations Before Using the Indicator:
  Market & Timeframe: Designed for liquid crypto perpetuals on 15m. Default thresholds are calibrated for XMRUSDT.P 15m. Different pairs may need EMA period and RSI threshold tuning.
  Leverage Warning: The default 25× leverage is aggressive. The companion strategy's backtest at default settings produced 18.01% maximum drawdown — substantially above the 5–10% per-trade band, although that figure reflects portfolio-level accumulation across 779 trades, not single-trade risk. Lower the leverage input to dial down portfolio-level drawdown proportionally.
  Cross Detection Granularity: Entries and SO fills are evaluated on bar close. A bar that spikes through a level and returns within the same bar may be missed by design — this matches realistic polling behavior and avoids over-signaling on intra-bar wicks.
  Live vs Historical State: The virtual position state is rebuilt from chart history each time the indicator is recompiled. If the indicator is added mid-deployment or the live bot diverges from the signal stream (manual interventions, partial fills), the indicator state may not match the live bot. Toggle the indicator off and on to reset.
  No SO Condition: Safety orders fire on pure price ladder with no momentum gate — averaging continues unconditionally as price drops, until SL, MaxHold, or price reversal. Higher average-entry quality in shallow dips; greater unrealized exposure on sharp drops.
  Maximum Hold Timeout: The 3-day forced close exists to release capital from stuck trades. The indicator dispatches a close webhook the moment the timeout fires — verify the receiving DCA Bot accepts unconditional close commands.
  Funding Rates (Perpetuals): The indicator does not account for perpetual funding rates. Sustained negative funding improves live performance for this long strategy; sustained positive funding degrades it. Review the historical funding pattern before live deployment.
  Backtesting Note: This is an indicator, not a strategy. There is no built-in P&L tester. For performance metrics over a 14-month sample (~779 closed trades, 74.07% win rate, 18.01% max drawdown, profit factor 1.313, +30.79% net return), use the companion strategy version on identical parameters.

🔷 How to Use It:
  🔸 Add the indicator to a 15m chart on the leveraged perpetual pair you want to trade.
  🔸 Review the entry filters (RSI on 5m, EMA stack on 15m), the 4-SO ladder, and the three exit conditions. Defaults are calibrated for XMRUSDT.P 15m at 25× leverage — recalibrate per asset and per risk tolerance before deploying.
  🔸 Set leverage and base margin to match your exchange and account configuration. Lower leverage scales portfolio-level drawdown proportionally.
  🔸 In the DCA Bot Webhook group, paste the Bot ID, Email Token, and Pair (QUOTE_BASE format, e.g., USDT_XMR).
  🔸 Create an alert on the indicator with "Any alert() function call". Paste the DCA Bot's webhook URL into the alert's Webhook field. The indicator will emit JSON payloads for entry, each safety order, and all three close types — formatted for direct DCA Bot consumption.

🔷 INDICATOR SETTINGS
  Base Order Margin (USDT): Margin per base trade. Notional = Margin × Leverage. Used for the virtual avg-entry / open-PnL computation.
  Leverage (×): Exchange leverage. Default 25×.
  Max Safety Orders: Maximum number of safety orders per cycle (default 4).
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
  Visualization: Toggle SO Ladder, Avg / TP / SL plot lines, fill labels, signal triangles, status table.
  Brand Watermark: Configurable text, position, size, and transparency.

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.

__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=6
// =============================================================================
//  RSI Dip + EMA Trend Long DCA — Leveraged Indicator
//  Signal-only companion to the RSI Dip + EMA Trend Long DCA strategy. Tracks
//  one virtual long position at a time (base + up to 4 safety orders) and
//  fires webhook-ready alerts on every event:
//    • LONG entry  — RSI(12) crossing down 35 on 5m AND EMA(50) > EMA(100) on 15m
//    • SO fill     — price reaches the next deviation rung below base entry
//    • TP close    — close hits avg × (1 + TP%) and retraces by trailing dev
//    • SL close    — close drops to avg × (1 − SL%)
//    • MaxHold     — forced close after the configured holding period
//  No backtest engine — designed to drive a live DCA Bot via webhooks.
//  Calibrated defaults for BYBIT:XMRUSDT.P on 15m timeframe (25× leverage).
// =============================================================================
indicator("RSI Dip + EMA Trend Long DCA — Leveraged Indicator", shorttitle = "RSIEMA-I", overlay = true, max_labels_count = 500, max_lines_count = 100)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS (mirror the strategy 1:1)
// ─────────────────────────────────────────────────────────────────────────────
grpBase = "Base Order (Virtual)"
baseMargin = input.float(60.0, "Base Order Margin (USDT)", minval = 1, group = grpBase, tooltip = "Tracked virtually for avg-entry computation. Real sizing happens on the DCA Bot.")
leverage   = input.float(25.0, "Leverage (×)", minval = 1.0, maxval = 100.0, step = 1.0, group = grpBase)

grpSO = "Safety Orders"
soCount    = input.int(4, "Max Safety Orders", minval = 0, maxval = 10, group = grpSO)
soMargin   = input.float(60.0, "First SO Margin (USDT)", minval = 1, group = grpSO)
soStep     = input.float(1.0, "Step to First SO (%)", minval = 0.1, step = 0.1, group = grpSO)
soStepMult = input.float(1.2, "Step Multiplier", minval = 1.0, step = 0.05, group = grpSO)
soSizeMult = input.float(1.05, "Size Multiplier", minval = 1.0, step = 0.01, group = grpSO)

grpEntryRSI = "Entry RSI Filter (Oversold Dip)"
entryRsiTF    = input.timeframe("5", "RSI Timeframe", group = grpEntryRSI)
entryRsiLen   = input.int(12, "RSI Length", minval = 2, group = grpEntryRSI)
entryRsiLevel = input.float(35.0, "RSI Crossing Down Level", minval = 1, maxval = 100, group = grpEntryRSI)

grpEMA = "EMA Trend Filter"
emaTF   = input.timeframe("15", "EMA Timeframe", group = grpEMA)
emaFast = input.int(50,  "Fast EMA Length",  minval = 2, group = grpEMA)
emaSlow = input.int(100, "Slow EMA Length",  minval = 2, group = grpEMA)

grpExit = "Exit"
tpPct    = input.float(1.0, "Take Profit (%)", minval = 0.1, step = 0.1, group = grpExit)
trailDev = input.float(0.1, "Trailing Deviation (%)", minval = 0.05, step = 0.05, group = grpExit)
slPct    = input.float(9.0, "Stop Loss (%)", minval = 0.1, step = 0.1, group = grpExit)

grpHold = "Max Hold Period"
useMaxHold     = input.bool(true, "Force Close After Max Hold", group = grpHold)
maxHoldSeconds = input.int(259200, "Max Hold (seconds)", minval = 60, group = grpHold, tooltip = "Default 259200 = 3 days.")

grpHook = "DCA Bot Webhook"
botId       = input.string("YOUR_BOT_ID",      "Bot ID",            group = grpHook)
emailToken  = input.string("YOUR_EMAIL_TOKEN", "Email Token",       group = grpHook)
pairWebhook = input.string("USDT_XMR",         "Pair (QUOTE_BASE)", group = grpHook)

grpViz = "Visualization"
showLevels     = input.bool(true, "Show SO Ladder",         group = grpViz)
showLines      = input.bool(true, "Plot Avg / TP / SL",     group = grpViz)
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
entryRsi       = request.security(syminfo.tickerid, entryRsiTF, ta.rsi(close, entryRsiLen), lookahead = barmerge.lookahead_off)
entryCrossDown = entryRsi[1] > entryRsiLevel and entryRsi <= entryRsiLevel

emaFastVal = request.security(syminfo.tickerid, emaTF, ta.ema(close, emaFast), lookahead = barmerge.lookahead_off)
emaSlowVal = request.security(syminfo.tickerid, emaTF, ta.ema(close, emaSlow), lookahead = barmerge.lookahead_off)
condTrend  = emaFastVal > emaSlowVal

entrySignal = entryCrossDown and condTrend

// ─────────────────────────────────────────────────────────────────────────────
// VIRTUAL POSITION STATE
// ─────────────────────────────────────────────────────────────────────────────
var bool  inPosition   = false
var float baseEntry    = na
var int   soFilled     = 0
var float totalCost    = 0.0  // USDT notional deployed (base + filled SOs)
var float totalQty     = 0.0  // asset units across all fills
var int   entryTime    = na
var float trailingPeak = na
var bool  inTPZone     = false

var bool entryEvent = false
var bool soEvent    = false
var bool tpEvent    = false
var bool slEvent    = false
var bool mhEvent    = false
entryEvent := false
soEvent    := false
tpEvent    := false
slEvent    := false
mhEvent    := false

// ENTRY — base order
if not inPosition and entrySignal
    inPosition   := true
    baseEntry    := close
    soFilled     := 0
    notional     = baseMargin * leverage
    totalCost    := notional
    totalQty     := notional / close
    entryTime    := time
    trailingPeak := na
    inTPZone     := false
    entryEvent   := true
    alert(f_msgEntry(), alert.freq_once_per_bar_close)
    if showFillLabels
        label.new(bar_index, low, "LONG ▲", style = label.style_label_up, color = color.new(color.green, 20), textcolor = color.white, size = size.tiny)

// SO trigger — price ladders DOWN against the long
if inPosition and soFilled < soCount and not na(baseEntry)
    nextIdx   = soFilled + 1
    threshold = f_cumDev(nextIdx)
    triggerPx = baseEntry * (1.0 - threshold / 100.0)
    if close <= triggerPx
        soNotional = f_soMargin(nextIdx) * leverage
        totalCost  := totalCost + soNotional
        totalQty   := totalQty + soNotional / close
        soFilled   := nextIdx
        soEvent    := true
        alert(f_msgAddAO(), alert.freq_once_per_bar_close)
        if showFillLabels
            label.new(bar_index, low, "SO" + str.tostring(nextIdx) + " ▲", style = label.style_label_up, color = color.new(color.aqua, 20), textcolor = color.white, size = size.tiny)

avgEntry = totalQty > 0 ? totalCost / totalQty : na

// EXIT priority: SL → MaxHold → TP trailing
if inPosition and not na(avgEntry)
    tpPrice = avgEntry * (1.0 + tpPct / 100.0)
    slPrice = avgEntry * (1.0 - slPct / 100.0)

    closedNow = false

    // SL — hard stop
    if close <= slPrice
        slEvent   := true
        closedNow := true
        alert(f_msgClose(), alert.freq_once_per_bar_close)
        if showFillLabels
            label.new(bar_index, high, "SL ▼", style = label.style_label_down, color = color.new(color.red, 10), textcolor = color.white, size = size.tiny)

    // Max hold — force close
    if not closedNow and useMaxHold and not na(entryTime)
        holdMs = time - entryTime
        if holdMs >= maxHoldSeconds * 1000
            mhEvent   := true
            closedNow := true
            alert(f_msgClose(), alert.freq_once_per_bar_close)
            if showFillLabels
                label.new(bar_index, high, "MaxHold ▼", style = label.style_label_down, color = color.new(color.orange, 10), textcolor = color.white, size = size.tiny)

    // TP trailing
    if not closedNow
        if close >= tpPrice
            inTPZone     := true
            trailingPeak := na(trailingPeak) ? close : math.max(trailingPeak, close)
        if inTPZone and not na(trailingPeak)
            trailStop = trailingPeak * (1.0 - trailDev / 100.0)
            if close <= trailStop
                tpEvent   := true
                closedNow := true
                alert(f_msgClose(), alert.freq_once_per_bar_close)
                if showFillLabels
                    label.new(bar_index, high, "TP ▼", style = label.style_label_down, color = color.new(color.green, 10), textcolor = color.white, size = size.tiny)

    // Reset virtual state on any close
    if closedNow
        inPosition   := false
        baseEntry    := na
        soFilled     := 0
        totalCost    := 0.0
        totalQty     := 0.0
        entryTime    := na
        trailingPeak := na
        inTPZone     := false

openPnl = totalQty > 0 and not na(avgEntry) ? (close - avgEntry) * totalQty : 0.0

// ─────────────────────────────────────────────────────────────────────────────
// PLOTS & SIGNAL SHAPES
// ─────────────────────────────────────────────────────────────────────────────
plot(showLines and inPosition and not na(avgEntry) ? avgEntry : na, title = "Avg Entry", color = color.new(color.orange, 0), linewidth = 2, style = plot.style_linebr)
plot(showLines and inPosition and not na(avgEntry) ? avgEntry * (1.0 + tpPct / 100.0) : na, title = "TP", color = color.new(color.green, 0), linewidth = 1, style = plot.style_linebr)
plot(showLines and inPosition and not na(avgEntry) ? avgEntry * (1.0 - slPct / 100.0) : na, title = "SL", color = color.new(color.red, 0), linewidth = 1, style = plot.style_linebr)

plotshape(showShapes and entryEvent, title = "Long Entry", location = location.belowbar, style = shape.triangleup,   color = color.new(color.green,  0), size = size.small)
plotshape(showShapes and soEvent,    title = "SO Fill",    location = location.belowbar, style = shape.triangleup,   color = color.new(color.aqua,   0), size = size.tiny)
plotshape(showShapes and tpEvent,    title = "TP Hit",     location = location.abovebar, style = shape.triangledown, color = color.new(color.green,  0), size = size.small)
plotshape(showShapes and slEvent,    title = "SL Hit",     location = location.abovebar, style = shape.triangledown, color = color.new(color.red,    0), size = size.small)
plotshape(showShapes and mhEvent,    title = "MaxHold",    location = location.abovebar, style = shape.triangledown, color = color.new(color.orange, 0), size = size.small)

// SO ladder lines (below baseEntry for long)
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
        ln  = line.new(x1 = bar_index - 100, x2 = bar_index + 8, y1 = px, y2 = px, color = col, style = line.style_dashed, width = wid)
        array.push(soLines, ln)
        label.new(x = bar_index + 8, y = px, text = "SO" + str.tostring(k) + "  -" + str.tostring(dev, "#.##") + "%", style = label.style_label_left, color = color.new(color.gray, 70), textcolor = color.white, size = size.tiny)

// Status table
if showTable and barstate.islast
    var table tbl = table.new(position = position.top_right, columns = 2, rows = 10, border_width = 1)
    bg  = color.new(color.gray, 30)
    bgH = color.new(color.gray, 0)
    table.cell(tbl, 0, 0, "Status",          text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 1, 0, inPosition ? "In Long (virtual)" : "Flat", text_color = color.white, bgcolor = bgH)
    table.cell(tbl, 0, 1, "SOs Filled",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 1, str.tostring(soFilled) + " / " + str.tostring(soCount), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 2, "Base Entry",      text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 2, na(baseEntry) ? "—" : str.tostring(baseEntry, "#.####"), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 3, "Avg Entry",       text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 3, inPosition and not na(avgEntry) ? str.tostring(avgEntry, "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 4, "TP Target",       text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 4, inPosition and not na(avgEntry) ? str.tostring(avgEntry * (1.0 + tpPct / 100.0), "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 5, "SL Level",        text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 5, inPosition and not na(avgEntry) ? str.tostring(avgEntry * (1.0 - slPct / 100.0), "#.####") : "—", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 6, "Deployed Notional", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 6, str.tostring(totalCost, "#.##"), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 0, 7, entryRsiTF + " RSI(" + str.tostring(entryRsiLen) + ")", text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 7, str.tostring(entryRsi, "#.#"), text_color = entryRsi <= entryRsiLevel ? color.green : color.white, bgcolor = bg)
    table.cell(tbl, 0, 8, emaTF + " EMA " + str.tostring(emaFast) + "/" + str.tostring(emaSlow), text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 8, condTrend ? "Up ▲" : "Down ▼", text_color = condTrend ? color.green : color.red, bgcolor = bg)
    holdLeftSec = inPosition and not na(entryTime) ? math.max(0, maxHoldSeconds - int((time - entryTime) / 1000)) : 0
    table.cell(tbl, 0, 9, "Hold Left (s)",   text_color = color.white, bgcolor = bg)
    table.cell(tbl, 1, 9, inPosition and useMaxHold ? str.tostring(holdLeftSec) : "—", text_color = color.white, bgcolor = bg)

// ─────────────────────────────────────────────────────────────────────────────
// BRAND WATERMARK
// ─────────────────────────────────────────────────────────────────────────────
var table wm = na
if showWM and barstate.islast
    if na(wm)
        wm := table.new(f_pos(wmPosStr), 1, 1, bgcolor = color.new(color.black, 100), border_width = 0)
    table.cell(wm, 0, 0, wmText, text_color = color.new(color.white, wmAlpha), text_size = f_size(wmSizeStr), bgcolor = color.new(color.black, 100))
````
