# [3Commas] Triple-RSI DCA Long - Indicator

- url: https://www.tradingview.com/script/xJQIS5jz-3Commas-Triple-RSI-DCA-Long-Indicator/
- type: indicator
- pine_id: PUB;7da1b33c43374e84b16a4d855e5a8a2f
- version: 1.0

## Description

🔷 What it does:
This indicator visualizes a long-only Dollar-Cost-Averaging signal framework driven by three independent RSI conditions across two timeframes. It marks base order entries, projects the full safety order ladder, tracks a virtual deal lifecycle on the chart, and exposes webhook-ready alerts for automated execution through an external DCA Bot. No orders are placed by the indicator itself - it is a pure signal and visualization layer.

Base Order signal: RSI(14) on 5m crosses above 30 (oversold-exit confirmation)
Safety Order trigger: RSI(14) on 30m OR RSI(7) on 5m crosses above 30, coinciding with a structural deviation from base price
Visual ladder: 3 safety order levels projected as horizontal lines from base, with filled-state coloring
Take Profit: configurable percentage from average entry (default 1.3%), rendered as a target line

🔷 Who is it for:
Bot operators who need a visual confirmation layer for automated DCA execution.
Discretionary traders who use the structured averaging logic manually and want clear on-chart triggers.
Free-tier TradingView users who want access to the same signal logic as the Strategy version without requiring backtest functionality.
Cross-instrument testers who run the same signal framework across crypto, perpetuals, and tokenized equities.

🔷 How does it work:
Long Entry: A base order signal fires when RSI(14, 5m) crosses above 30. The indicator marks this with a green triangle below the bar and stores the base price as the reference for the safety order ladder.
Short Entry: Not used - long-only signal framework by design.
Exit Management: When price reaches Average Entry × (1 + Take Profit %), the indicator marks the bar with a cyan diamond, fires the TP alert, and resets the virtual deal state. No stop loss is implemented; invalidation is replaced by the depth of the safety order ladder, which absorbs a structural pullback of up to 5.37% from base.

🔷 Why it's unique:
Multi-timeframe RSI stack - three independent RSI conditions across 5m and 30m act as a regime filter, reducing false entries during trendless chop and isolating only confirmed oversold-exit conditions. Different lookback lengths (RSI(14) and RSI(7)) on the same 5m timeframe capture both medium-term and short-term momentum exhaustion, while the 30m RSI(14) provides higher-timeframe trend-context confirmation for safety orders.
Structural averaging architecture - safety orders trigger only at predefined cumulative deviations from base price (−1.00%, −2.65%, −5.37%), not at fixed time intervals. This aligns re-entries with structurally significant price levels rather than arbitrary clock-based steps. The full ladder is projected on chart from the moment of base entry, so traders see the entire risk envelope upfront.
Bot Integration - three alert events (Deal Entry, SO Triggered, Deal TP) expose webhook-ready JSON payloads, enabling automated execution through a connected DCA Bot. The indicator publishes the signal, the bot handles position management on the exchange autonomously across multiple pairs.

🔷 What you'll see on the chart:
Green triangle (below bar) - Base Order entry signal fired
Pink triangle (above bar) - Safety Order trigger signal fired
Cyan diamond - Take Profit target reached, virtual deal closed
Cyan line - Base Entry price (reference for the SO ladder)
Yellow line - Average Entry price (recalculates as SOs fill)
Green line - Take Profit target (Average × (1 + TP%))
Red bold line - Next pending Safety Order trigger price
Red thin lines - All 3 SO ladder levels projected from base
Gray fade - SO level once it has been filled (visual state tracking)
Background tints - Lime on Base Order bar, Cyan on Take Profit bar

🔷 Considerations Before Using the Indicator:
Market & Timeframe: Designed for a 3-minute base chart with the multi-RSI signal stack pulling from 5m and 30m. Best suited to liquid, volatile instruments with sufficient intraday range to populate all three RSI conditions - perpetual contracts, tokenized equities, and major altcoins. Not recommended for low-volatility, sideways-only assets where RSI rarely cycles through oversold zones.

Limitations: The indicator does not place orders. It tracks a "virtual deal" state on the chart for visualization purposes only - actual execution must be performed through a connected bot or manually. The signal framework carries no stop-loss component; in sustained downtrends extending beyond the deepest safety order (−5.37% from base), the virtual deal holds unrealized loss until either the average is recovered or the alert flow is manually overridden. Consider adding a regime filter (e.g., long-term moving average) for deployment in non-trending or bearish markets.

Backtesting & Demo Testing: Always validate the signal framework on historical data before connecting to a live bot. The companion Strategy version of this script is available on the same profile for full backtest analysis, performance metrics, and equity curve review. Demo-trade for at least one month to observe behavior in conditions not represented in historical data. Past performance is not indicative of future results.
Parameter Adjustments: Take profit, safety order step, and volume scale parameters should be tuned per instrument volatility profile. Higher-volatility instruments benefit from wider SO step (1.3–1.5%) and elevated step scale (1.8–2.0). Lower-volatility instruments work better with tighter SO step (0.6–0.8%) and lower TP (0.8–1.2%). Trending regimes favor higher TP (2.0–3.0%) to capture larger structural moves; ranging regimes favor lower TP (0.8–1.2%) for higher trade frequency.

🔷 Backtest Validation:
This indicator shares identical signal logic with the Strategy version of the same framework, available on this profile for full historical performance review:
Strategy version: https://www.tradingview.com/script/u4g3IrXS-3Commas-Triple-RSI-DCA-Long-Risk-Adjusted-Averaging-Strategy/
Reference results from the Strategy version on COINUSDT.P (OKX Perpetual), tested period Feb 26 - May 8, 2026:
Net Profit: +13.76%   |   Max Drawdown: 5.45%   |   Total Trades: 102   |   Win Rate: 74.51%   |   Profit Factor: 4.381
Strategy benchmarked against Buy & Hold over the same period: strategy delivered higher current return than passive holding while drawing down a fraction of the underlying volatility.
Refer to the Strategy publication for the complete equity curve, trade-by-trade breakdown, and Strategy Tester report.

🔷 How to Use It:
🔸 Adjust Settings: Configure the Take Profit percentage and Safety Order step parameters for the instrument you intend to trade. Defaults are calibrated for COINUSDT.P perpetual; for other instruments, refer to the tuning notes above and re-validate on the Strategy version before deploying signals to a live bot.
🔸 Visual Confirmation: Use the on-chart projections (base entry, SO ladder, average entry, TP target) to verify that the active virtual deal aligns with your bot's actual position. The indicator's virtual deal state is a 1-to-1 mirror of the Strategy version's signal logic, so any divergence between chart visuals and bot position is a flag for investigation.
🔸 Create alerts to trigger the DCA Bot: Three alert conditions are exposed by the indicator - "Deal Entry" fires on each new base order signal, "SO Triggered" fires on each safety order signal, and "Deal TP" fires when the take profit target is hit. Configure all three alerts in TradingView with webhook URLs pointing to your DCA Bot's deal-start, safety-order-fill, and close-deal endpoints. Once configured, the indicator publishes the signal and the bot handles execution on the exchange autonomously.

🔷 INDICATOR SETTINGS
Base Order Volume (USD, ref) - Reference notional for the base entry; used for Average Entry projection only (no orders placed).
Safety Order Volume (1st, USD, ref) - Reference notional for the first averaging-down order; subsequent SOs scale by Volume Scale.
Max Safety Orders - Total number of averaging steps tracked in the virtual deal.
Volume Scale (martingale) - Size multiplier applied to each successive safety order in the average calculation.
Price Step % (1st SO) - Percentage deviation from base price that triggers the first safety order.
Step Scale (martingale) - Multiplier applied to each successive deviation step.
Take Profit % (from AVG) - Profit target percentage measured from average entry price.
Entry RSI Length / Threshold / Timeframe - Parameters for the base order RSI signal.
SO Sig 1 - RSI Length / Threshold / Timeframe - Parameters for the first safety order trigger.
SO Sig 2 - RSI Length / Threshold / Timeframe - Parameters for the second safety order trigger (OR-combined with the first).
Visual Layer Toggles - Show/hide individual chart elements: base line, average line, TP line, full SO ladder, next SO highlight, signal triangles.
Branding - Watermark text, position, size, transparency, and color (for chart screenshots and educational posts).

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.
__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=5
// =============================================================================
//  Triple-RSI DCA Long — Signal Indicator (Companion to the Strategy version)
//
//  Indicator-only port of the Triple-RSI DCA Long strategy. Identical signal
//  logic, no order placement — just visual signals, projected SO/TP levels,
//  and webhook-ready alerts for use with an external DCA Bot.
//
//  Use cases:
//    - Manual confirmation of bot entries on the chart
//    - Live signal visualization for discretionary DCA traders
//    - Webhook source for automated DCA Bot integration (alerts identical
//      to the strategy version)
//
//  Visual layer:
//    - BO entry signal:  green triangle below bar
//    - SO trigger signal: pink triangle above bar
//    - Base entry line, Avg entry line, TP target line, Next-SO line
//    - All 3 SO ladder levels projected as horizontal lines from base
//    - Faded color when an SO level has already been filled
// =============================================================================

indicator("Triple-RSI DCA Long — Signal Indicator",
     overlay            = true,
     max_lines_count    = 100,
     max_labels_count   = 100,
     max_bars_back      = 500)

// ============================ INPUTS =========================================
// — Sizing (used for Avg Entry projection only; no orders placed) —
boVol     = input.float(20.075, "Base Order Volume (USD, ref)",          minval = 0.001, step = 0.001, group = "Sizing (reference for AVG projection)")
soVol     = input.float(15.075, "Safety Order Volume (1st, USD, ref)",   minval = 0.001, step = 0.001, group = "Sizing (reference for AVG projection)")
maxSO     = input.int  (3,      "Max Safety Orders",                     minval = 0, maxval = 10,      group = "Sizing (reference for AVG projection)")
volScale  = input.float(1.9,    "Volume Scale (martingale)",             minval = 1.0, step = 0.01,    group = "Sizing (reference for AVG projection)")

stepPct   = input.float(1.0,    "Price Step % (1st SO)",   minval = 0.01, step = 0.05, group = "Price Deviation") / 100.0
stepScale = input.float(1.65,   "Step Scale (martingale)", minval = 1.0,  step = 0.01, group = "Price Deviation")

tpPct     = input.float(1.3,    "Take Profit % (from AVG)", minval = 0.01, step = 0.05, group = "Take Profit") / 100.0

// — Entry signal (BO) —
useEntryRsi = input.bool   (true,  "Require RSI cross-above for BO entry", group = "Entry Signal — Deal Start")
entryLen    = input.int    (14,    "Entry RSI Length",         minval = 2,  group = "Entry Signal — Deal Start")
entryThr    = input.float  (30,    "Entry RSI Threshold",                   group = "Entry Signal — Deal Start")
entryTF     = input.timeframe("5",  "Entry RSI Timeframe",                  group = "Entry Signal — Deal Start")

// — SO signals —
useSoSignal = input.bool   (true,  "Require RSI cross-above for SO entry (OR of two TFs)", group = "SO Signals")
so1Len      = input.int    (14,    "SO Sig 1 — RSI Length",   minval = 2,   group = "SO Signals")
so1Thr      = input.float  (30,    "SO Sig 1 — RSI Threshold",               group = "SO Signals")
so1TF       = input.timeframe("30", "SO Sig 1 — RSI Timeframe",              group = "SO Signals")
so2Len      = input.int    (7,     "SO Sig 2 — RSI Length",   minval = 2,   group = "SO Signals")
so2Thr      = input.float  (30,    "SO Sig 2 — RSI Threshold",               group = "SO Signals")
so2TF       = input.timeframe("5",  "SO Sig 2 — RSI Timeframe",              group = "SO Signals")

// — Visual layer toggles —
showBaseLine = input.bool(true, "Show Base Entry line",     group = "Visual Layer")
showAvgLine  = input.bool(true, "Show Avg Entry line",      group = "Visual Layer")
showTpLine   = input.bool(true, "Show TP Target line",      group = "Visual Layer")
showAllSO    = input.bool(true, "Show full SO ladder",      group = "Visual Layer")
showNextSO   = input.bool(true, "Highlight Next SO level",  group = "Visual Layer")
showShapes   = input.bool(true, "Show signal triangles",    group = "Visual Layer")

// ============================ SIGNALS ========================================
// Look-ahead-safe pattern: prior closed bar value (`[1]`) + lookahead_on
entryRsi    = request.security(syminfo.tickerid, entryTF, ta.rsi(close, entryLen)[1], lookahead = barmerge.lookahead_on)
entrySignal = useEntryRsi ? ta.crossover(entryRsi, entryThr) : false

so1Rsi  = request.security(syminfo.tickerid, so1TF, ta.rsi(close, so1Len)[1], lookahead = barmerge.lookahead_on)
so2Rsi  = request.security(syminfo.tickerid, so2TF, ta.rsi(close, so2Len)[1], lookahead = barmerge.lookahead_on)
soSig   = useSoSignal ? (ta.crossover(so1Rsi, so1Thr) or ta.crossover(so2Rsi, so2Thr)) : false

// ============================ STATE TRACKING (no orders) =====================
// Replicates the strategy's deal lifecycle for visualization purposes.
var float basePx    = na
var float avgPx     = na
var float costSum   = 0.0
var float qtySum    = 0.0
var int   soFilled  = 0
var bool  dealOpen  = false

// Cumulative deviation from base after k SOs
f_cumDev(k) =>
    s = 0.0
    if k > 0
        for i = 0 to k - 1
            s += math.pow(stepScale, i)
    s * stepPct

nextIdx  = soFilled + 1
nextDev  = nextIdx > 0 and nextIdx <= maxSO ? f_cumDev(nextIdx) : na
nextPx   = not na(basePx) and not na(nextDev) ? basePx * (1.0 - nextDev) : na
nextUsd  = soVol * math.pow(volScale, math.max(soFilled, 0))

// ============================ DEAL OPEN (BO) =================================
if entrySignal and not dealOpen
    basePx   := close
    avgPx    := close
    costSum  := boVol
    qtySum   := boVol / close
    soFilled := 0
    dealOpen := true

// ============================ SO TRIGGER =====================================
if dealOpen and soFilled < maxSO and not na(nextPx)
    if low <= nextPx and soSig
        execPx = math.min(open, nextPx)
        qty    = nextUsd / execPx
        costSum  := costSum + nextUsd
        qtySum   := qtySum  + qty
        avgPx    := costSum / qtySum
        soFilled := soFilled + 1

// ============================ DEAL CLOSE (TP) ================================
tpPx = not na(avgPx) ? avgPx * (1.0 + tpPct) : na
if dealOpen and not na(tpPx) and high >= tpPx
    dealOpen := false
    basePx   := na
    avgPx    := na
    costSum  := 0.0
    qtySum   := 0.0
    soFilled := 0

// ============================ VISUALIZATION ==================================
// Signal triangles
plotshape(showShapes and entrySignal and not dealOpen[1], title = "BO Signal", style = shape.triangleup,   location = location.belowbar, color = color.new(color.lime,    0), size = size.small, text = "BO",  textcolor = color.new(color.lime, 0))
plotshape(showShapes and soSig and dealOpen and soFilled != nz(soFilled[1]),       title = "SO Signal", style = shape.triangledown, location = location.abovebar, color = color.new(color.fuchsia, 0), size = size.tiny,  text = "SO",  textcolor = color.new(color.fuchsia, 0))
plotshape(showShapes and dealOpen[1] and not dealOpen,    title = "TP Hit",    style = shape.diamond,      location = location.abovebar, color = color.new(color.aqua,    0), size = size.small, text = "TP",  textcolor = color.new(color.aqua, 0))

// Position lines (only when deal active)
plot(showBaseLine and dealOpen ? basePx : na, "Base Entry",      color = color.new(color.aqua,   0), linewidth = 1, style = plot.style_linebr)
plot(showAvgLine  and dealOpen ? avgPx  : na, "Avg Entry",       color = color.new(color.yellow, 0), linewidth = 2, style = plot.style_linebr)
plot(showTpLine   and dealOpen ? tpPx   : na, "TP Target",       color = color.new(color.green,  0), linewidth = 1, style = plot.style_linebr)
plot(showNextSO   and dealOpen ? nextPx : na, "Next SO",         color = color.new(color.red,    0), linewidth = 2, style = plot.style_linebr)

// Full SO ladder (faded when filled, solid red when pending)
soDev1 = f_cumDev(1)
soDev2 = f_cumDev(2)
soDev3 = f_cumDev(3)
soL1   = not na(basePx) and maxSO >= 1 ? basePx * (1.0 - soDev1) : na
soL2   = not na(basePx) and maxSO >= 2 ? basePx * (1.0 - soDev2) : na
soL3   = not na(basePx) and maxSO >= 3 ? basePx * (1.0 - soDev3) : na

soL1Color = soFilled >= 1 ? color.new(color.gray, 60) : color.new(color.red, 50)
soL2Color = soFilled >= 2 ? color.new(color.gray, 60) : color.new(color.red, 50)
soL3Color = soFilled >= 3 ? color.new(color.gray, 60) : color.new(color.red, 50)

plot(showAllSO and dealOpen ? soL1 : na, "SO 1", color = soL1Color, linewidth = 1, style = plot.style_linebr)
plot(showAllSO and dealOpen ? soL2 : na, "SO 2", color = soL2Color, linewidth = 1, style = plot.style_linebr)
plot(showAllSO and dealOpen ? soL3 : na, "SO 3", color = soL3Color, linewidth = 1, style = plot.style_linebr)

// Background highlights for deal lifecycle
bgcolor(entrySignal and not dealOpen[1] ? color.new(color.lime,   92) : na, title = "BO bar")
bgcolor(dealOpen[1] and not dealOpen    ? color.new(color.aqua,   92) : na, title = "TP bar")

// ============================ BRAND WATERMARK ================================
showWM    = input.bool   (true,        "Show watermark",                     group = "Branding")
wmText    = input.string ("3Commas",   "Watermark text",                     group = "Branding")
wmPosStr  = input.string ("top_right", "Position", options = ["top_left","top_center","top_right","middle_left","middle_center","middle_right","bottom_left","bottom_center","bottom_right"], group = "Branding")
wmSizeStr = input.string ("huge",      "Size",     options = ["tiny","small","normal","large","huge"], group = "Branding")
wmAlpha   = input.int    (70,          "Transparency (0=solid, 100=invisible)", minval = 0, maxval = 100, group = "Branding")

f_wmPos(s) =>
    s == "top_left"      ? position.top_left      :
     s == "top_center"    ? position.top_center    :
     s == "top_right"     ? position.top_right     :
     s == "middle_left"   ? position.middle_left   :
     s == "middle_center" ? position.middle_center :
     s == "middle_right"  ? position.middle_right  :
     s == "bottom_left"   ? position.bottom_left   :
     s == "bottom_center" ? position.bottom_center :
     position.bottom_right

f_wmSize(s) =>
    s == "tiny"   ? size.tiny   :
     s == "small"  ? size.small  :
     s == "normal" ? size.normal :
     s == "large"  ? size.large  :
     size.huge

var table wm = table.new(f_wmPos(wmPosStr), 1, 1, bgcolor = color.new(color.black, 100), border_width = 0)
if showWM and barstate.islast
    table.cell(wm, 0, 0, wmText, text_color = color.new(color.white, wmAlpha), text_size = f_wmSize(wmSizeStr), bgcolor = color.new(color.black, 100))

// ============================ ALERTS / WEBHOOK (DCA Bot) =====================
alertcondition(entrySignal and not dealOpen[1],          title = "Deal Entry",         message = '{"action":"start_new_deal"}')
alertcondition(soSig and dealOpen and soFilled != nz(soFilled[1]), title = "SO Triggered", message = '{"action":"safety_order_filled"}')
alertcondition(dealOpen[1] and not dealOpen,             title = "Deal TP",            message = '{"action":"close_at_market_price"}')
````
