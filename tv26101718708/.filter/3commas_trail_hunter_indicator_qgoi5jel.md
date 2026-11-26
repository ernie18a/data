# [3Commas] Trail Hunter - Indicator

- url: https://www.tradingview.com/script/Qgoi5jEL-3Commas-Trail-Hunter-Indicator/
- type: indicator
- pine_id: PUB;fbac02bd739045e89cb75fa8735cea50
- version: 1.0

## Description

[3Commas] Trail Hunter - Indicator

🔷 What it does:
This indicator visualizes a long-only mean-reversion signal framework on liquid instruments. It marks dual-confluence entry signals (MA cross-under + CCI oversold), tracks a virtual deal lifecycle on the chart with trailing take-profit and hard stop loss management, and exposes webhook-ready alerts for automated execution through an external DCA Bot. No orders are placed by the indicator itself — it is a pure signal and visualization layer.

Base Order signal: SMA(24) crosses below SMA(31) on 1h (default) AND CCI(11) on 1h crosses below −80
Exit signal: trailing take-profit activated at +1.5% with 0.05% trailing deviation, or hard stop at −3.25%
Single entry per cycle — no averaging, no safety order ladder
On-chart virtual P&L tracker: Net Profit, Max Drawdown, Trades, Win Rate, Profit Factor

🔷 Who is it for:
Bot operators who need a visual confirmation layer for automated mean-reversion execution.
Discretionary traders who use dual-indicator confluence logic manually and want clear on-chart triggers.
Free-tier TradingView users who want access to the same signal logic as the Strategy version without requiring backtest functionality.
Cross-instrument testers who run the same signal framework across crypto perpetuals, spot pairs, and equity tickers.

🔷 How does it work:
Long Entry: A long signal fires when two conditions align within a configurable keep-alive window — SMA(24) crosses below SMA(31) on the signal timeframe AND CCI(11) drops below −80 on the same timeframe. The indicator marks the entry with a green "L" triangle below the bar and stores the entry price as the reference for the trailing exit.
Short Entry: Not used — long-only signal framework by design.
Exit Management: Two exit conditions are armed simultaneously after entry. The trailing exit activates when price reaches Entry × (1 + Take Profit %), then follows the highest price reached with the deviation gap; if price retraces by the deviation amount from peak, the indicator marks the exit with a cyan diamond. The hard stop closes the virtual deal if price drops to Entry × (1 − Stop Loss %). Whichever condition fires first wins. The virtual P&L tracker captures the realized return at the actual fill price (peak − deviation for trail; SL price for stop).

🔷 Why it's unique:
Dual-indicator confluence — neither signal acts alone. The MA cross-under confirms short-term momentum exhaustion against the medium-term trend, and the CCI extreme confirms statistical oversold conditions. Requiring both filters out single-indicator false positives common to either condition during sideways regimes. Configurable keep-alive window (default 3 bars) lets the two confirmations align without requiring exact same-bar synchronization.
Trailing-exit architecture with full peak-tracking — the indicator computes the running peak from entry and triggers exit only when price retraces by the configured deviation from that peak. This is a true trailing simulation, not a fixed take-profit shortcut, and produces stats that match the underlying Strategy version closely.
Bot Integration — entry and exit alerts ship with webhook-ready JSON payloads, enabling direct trigger of a connected DCA Bot. Bot ID, Email Token, and pair label are exposed as inputs and automatically embedded into the alert message format.

🔷 What you'll see on the chart:
Cyan line — Fast MA on the signal timeframe (default SMA 24)
Orange line — Slow MA on the signal timeframe (default SMA 31)
Orange triangle (above bar) — MA cross-under signal fired
Cyan triangle (below bar) — CCI cross-under −80 signal fired
Green "L" triangle (below bar) — Combined entry signal armed; virtual deal opens
Cyan diamond — Trailing TP, fixed TP, or hard SL triggered; virtual deal closes
Cyan line (when in deal) — Entry price reference
Lime line (when in deal) — Trailing TP activation level
Red line (when in deal) — Stop Loss level
Stats card (top-left, configurable) — Live virtual backtest results: Net Profit, Max Drawdown, Total Trades, Win Rate, Profit Factor

🔷 Considerations Before Using the Indicator:
Market & Timeframe: Designed for 1-hour base charts on liquid instruments with frequent MA crossings — major crypto perpetuals (BTC, ETH, SOL), spot pairs on Coinbase and Bybit, and high-volume equities. The signal timeframe is independent of the chart timeframe — you can run on a 15m chart with 1h signals if you want fine-grained visualization with structural signal timing.
Limitations: The indicator does not place orders. It tracks a "virtual deal" state on the chart for visualization purposes only — actual execution must be performed through a connected bot or manually. This is a single-entry framework with no averaging, so a wrong entry caps at the −3.25% hard stop without recovery. The strategy carries no higher-timeframe regime filter, so it can signal long entries during sustained downtrends. For deployment in bearish regimes, consider gating the alerts manually with a higher-timeframe trend filter.

Virtual P&L Accuracy: The on-chart stats card uses a simplified internal accounting model — it does not factor exchange commission or slippage. The trailing exit simulation uses peak-tracking on the chart bar's high, which is an approximation of real intra-bar execution. Use the Strategy version for fee-adjusted backtest results.

Backtesting & Demo Testing: Always validate the signal framework on historical data before connecting to a live bot. The companion Strategy version of this script is available on the same profile for full backtest analysis with realistic commissions and slippage. Demo-trade for at least one month to observe behavior in conditions not represented in historical data. Past performance is not indicative of future results.
Parameter Adjustments: MA lengths, CCI threshold, signal timeframe, take-profit activation, trailing deviation, and stop loss should all be tuned per instrument volatility profile. Lower-volatility instruments work better with tighter MA pair, lower CCI threshold, and smaller trailing deviation. Higher-volatility instruments need wider parameters.

🔷 Backtest Validation:
This indicator shares identical signal logic with the Strategy version of the same framework, available on this profile for full historical performance review with realistic commission and slippage:
Strategy version: https://www.tradingview.com/script/d117dN6D-3Commas-Trail-Hunter-Reversal-Long/
Reference results from the Strategy version on COINBASE:BTCUSD, 1h chart, tested period May 12, 2025 — May 12, 2026:
Net Profit: +13.09 USD (+0.13%)   |   Max Drawdown: 7.91 USD (0.08%)   |   Total Trades: 66   |   Win Rate: 69.70% (46/66)   |   Profit Factor: 1.254
The strategy is positioned as a capital-preservation framework — extreme drawdown control (under 0.1% on the tested window) with positive expectancy. Refer to the Strategy publication for the complete equity curve, trade-by-trade breakdown, and Strategy Tester report.

🔷 How to Use It:
🔸 Adjust Settings: Configure the MA lengths, CCI threshold, signal timeframe, and exit parameters for the instrument you intend to trade. Defaults are calibrated for 1-hour BTC Spot on Coinbase. For lower-volatility instruments, tighten the MA pair and lower the trailing deviation; for higher-volatility instruments, do the opposite. The Initial Capital input (default 10,000) is used only for percentage calculations in the stats card — it does not affect signal logic.
🔸 Visual Confirmation: Use the on-chart projections (entry line, TP activation, SL level) to verify that the active virtual deal aligns with your bot's actual position. The indicator's virtual deal state is a 1-to-1 mirror of the Strategy version's signal logic, so any divergence between chart visuals and bot position is a flag for investigation. The MA and CCI signal triangles let you trace exactly when each condition fired in the entry stack.
🔸 Create alerts to trigger the DCA Bot: Two alert events are exposed by the indicator — "Deal Start" fires on each new combined entry signal, and "Deal Close" fires when any of the three exit conditions (trailing TP, fixed TP, or stop loss) triggers. Configure both alerts in TradingView with the webhook URL pointing to your DCA Bot's signal endpoint. The Bot ID, Email Token, and Pair label can be set in the script's inputs and are automatically embedded into the alert JSON payload.

🔷 INDICATOR SETTINGS
MA Type — Moving average type for entry calculation (SMA or EMA).
Fast MA Length — Period of the fast moving average (default 24).
Slow MA Length — Period of the slow moving average (default 31).
MA Cross Timeframe — Timeframe on which the MA cross is computed.
Use MA Cross signal — Toggle the MA condition on or off in the entry stack.
CCI Length — Period for the CCI indicator (default 11).
CCI Oversold Threshold — Value below which CCI must cross to qualify as oversold (default −80).
CCI Timeframe — Timeframe on which the CCI cross is computed.
Use CCI signal — Toggle the CCI condition on or off.
Combine Signals — AND requires both conditions within the keep-alive window; OR fires on either alone.
Signal Keep-Alive (bars) — Number of bars within which both signals must align for AND mode (default 3).
Base Order Volume (USDT, ref) — Reference notional for virtual P&L calculation.
Take Profit % (activation) — Profit level at which the trailing exit arms.
Enable Trailing — Toggle trailing behavior on the take-profit exit.
Trailing Deviation % — Distance from the peak price at which the trailing exit fires.
Enable Stop Loss — Toggle the hard stop loss on or off.
Stop Loss % (from entry) — Maximum acceptable loss from entry price.
Initial Capital (ref for % calc) — Reference capital base for percentage metrics in the stats card.
Visual Layer toggles — Show/hide MA lines, entry line, TP/SL lines, signal triangles.
Stats card / Watermark — Display layer controls for on-chart virtual backtest summary and branding.

Webhook — Bot ID, Email Token, and Pair label for DCA Bot signal routing.

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.
__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=6
// =====================================================================
//  [3Commas] Trail Hunter — Reversal Long Indicator
//  Companion to the Strategy version with identical signal logic.
// ---------------------------------------------------------------------
//  Mirrors the Strategy version:
//    Entry       : SMA(24) cross-under SMA(31) on 1h (default) AND
//                  CCI(11) on 1h crosses below −80
//                  (Both within a configurable keep-alive window; AND/OR)
//    Exit        : Trailing TP — activation at +1.5%, deviation 0.05%
//    Stop loss   : −3.25% (hard SL from entry)
//    Order size  : 41.55858 USDT (reference for virtual AVG/PnL tracking)
//    Single entry per cycle — no DCA, no safety order ladder
//
//  Use cases:
//    - Visual signal confirmation for bot-driven execution
//    - Live overlay of the strategy logic on any chart
//    - Webhook source for automated DCA Bot integration
//
//  Visual layer:
//    - MA Fast/Slow lines on the entry timeframe
//    - Orange "MA" triangle on each MA cross-under (signal-TF detection)
//    - Cyan "CCI" triangle on each CCI cross-under −80
//    - Green "L" triangle when AND-combined entry signal fires
//    - Cyan TP-hit diamond on virtual exit
//    - Entry / Trailing TP / SL lines while virtual deal active
// =====================================================================

indicator(
     title              = "[3Commas] Trail Hunter — Indicator",
     shorttitle         = "Trail Hunter",
     overlay            = true,
     max_lines_count    = 100,
     max_labels_count   = 100,
     max_bars_back      = 500)

// =====================================================================
//                              INPUTS
// =====================================================================
maType     = input.string ("SMA", "MA Type", options = ["SMA","EMA"], group = "Entry — MA Cross")
maFastLen  = input.int    (24,   "Fast MA Length",            minval = 2, group = "Entry — MA Cross")
maSlowLen  = input.int    (31,   "Slow MA Length",            minval = 2, group = "Entry — MA Cross")
maTF       = input.timeframe("60", "MA Cross Timeframe",                  group = "Entry — MA Cross")
useMACross = input.bool   (true, "Use MA Cross signal",                   group = "Entry — MA Cross")

cciLen   = input.int  (11,   "CCI Length",                    minval = 2, group = "Entry — CCI")
cciThr   = input.float(-80,  "CCI Oversold Threshold",                    group = "Entry — CCI")
cciTF    = input.timeframe("60", "CCI Timeframe",                          group = "Entry — CCI")
useCCI   = input.bool (true, "Use CCI signal",                            group = "Entry — CCI")

combineMode  = input.string("AND", "Combine Signals", options = ["AND","OR"], group = "Entry — Signal Combination")
keepAliveBars= input.int   (3,     "Signal Keep-Alive (bars)", minval = 1, maxval = 20, tooltip = "Bars within which both signals must align for AND mode", group = "Entry — Signal Combination")

boVol = input.float(41.55858, "Base Order Volume (USDT, ref)", minval = 0.01, step = 0.01, group = "Position Sizing")

tpPct        = input.float(1.5,  "Take Profit % (activation)", minval = 0.01, step = 0.05, group = "Take Profit / Trailing") / 100.0
trailEnabled = input.bool (true, "Enable Trailing",                                         group = "Take Profit / Trailing")
trailDevPct  = input.float(0.05, "Trailing Deviation %",       minval = 0.01, step = 0.01, group = "Take Profit / Trailing") / 100.0

useSL = input.bool (true, "Enable Stop Loss",                                     group = "Stop Loss")
slPct = input.float(3.25, "Stop Loss % (from entry)", minval = 0.01, step = 0.05, group = "Stop Loss") / 100.0

initCapital = input.float(10000, "Initial Capital (USDT, ref for % calc)", minval = 1, group = "Virtual Backtest")

botId      = input.string("12345678",         "Bot ID",                                      group = "Webhook (DCA Bot)")
emailToken = input.string("YOUR_EMAIL_TOKEN", "Email Token",                                 group = "Webhook (DCA Bot)")
pairLabel  = input.string("USDT_BTC",         "Pair (Bot format: QUOTE_BASE)",               group = "Webhook (DCA Bot)")

// — Visual layer toggles —
showMAs      = input.bool(true, "Show MA lines on chart",     group = "Visual Layer")
showEntryLn  = input.bool(true, "Show Entry line",            group = "Visual Layer")
showTpLn     = input.bool(true, "Show TP/Trail target",       group = "Visual Layer")
showSlLn     = input.bool(true, "Show SL line",               group = "Visual Layer")
showShapes   = input.bool(true, "Show signal triangles",      group = "Visual Layer")

// — Display layer (stats card + watermark) —
showStats   = input.bool   (true,        "Show stats card",                                  group = "Display")
statsPosStr = input.string ("top_left",  "Stats card position",
     options = ["top_left","top_center","top_right","middle_left","middle_right","bottom_left","bottom_center","bottom_right"], group = "Display")
showWM      = input.bool   (true,        "Show watermark",                                   group = "Display")
wmText      = input.string ("3Commas",   "Watermark text",                                   group = "Display")
wmPosStr    = input.string ("top_right", "Watermark position",
     options = ["top_left","top_center","top_right","middle_left","middle_center","middle_right","bottom_left","bottom_center","bottom_right"], group = "Display")
wmSizeStr   = input.string ("huge",      "Watermark size",
     options = ["tiny","small","normal","large","huge"], group = "Display")
wmAlpha     = input.int    (70,          "Watermark transparency (0=solid)", minval = 0, maxval = 100, group = "Display")

// =====================================================================
//                              SIGNALS
// =====================================================================
// MA values on selected TF — for plotting only (look-ahead-safe [1] + lookahead_on)
maFastVal = request.security(syminfo.tickerid, maTF, (maType == "SMA" ? ta.sma(close, maFastLen) : ta.ema(close, maFastLen))[1], lookahead = barmerge.lookahead_on)
maSlowVal = request.security(syminfo.tickerid, maTF, (maType == "SMA" ? ta.sma(close, maSlowLen) : ta.ema(close, maSlowLen))[1], lookahead = barmerge.lookahead_on)

// Cross detection inside security context — captures every signal-TF crossing
maCrossSig = request.security(syminfo.tickerid, maTF,
     ta.crossunder(
         maType == "SMA" ? ta.sma(close, maFastLen) : ta.ema(close, maFastLen),
         maType == "SMA" ? ta.sma(close, maSlowLen) : ta.ema(close, maSlowLen)
     ),
     lookahead = barmerge.lookahead_off)

cciSig = request.security(syminfo.tickerid, cciTF,
     ta.crossunder(ta.cci(close, cciLen), cciThr),
     lookahead = barmerge.lookahead_off)

// Keep-alive tracker (sentinel -1 init for Pine v6 reliability)
var int maLastBar  = -1
var int cciLastBar = -1

if maCrossSig
    maLastBar := bar_index
if cciSig
    cciLastBar := bar_index

maAlive  = (not useMACross) or (maLastBar  >= 0 and (bar_index - maLastBar)  <= keepAliveBars)
cciAlive = (not useCCI)     or (cciLastBar >= 0 and (bar_index - cciLastBar) <= keepAliveBars)
freshlyFired = (useMACross and maCrossSig) or (useCCI and cciSig)
entrySignal  = combineMode == "AND" ? (maAlive and cciAlive and freshlyFired) : (maCrossSig or cciSig)

// =====================================================================
//                       VIRTUAL DEAL STATE
// =====================================================================
var bool  inDeal      = false
var float entryPx     = na
var float dealQty     = 0.0
var float peakSinceEntry = na

// =====================================================================
//                       VIRTUAL DEAL OPEN
// =====================================================================
if (not inDeal and entrySignal and barstate.isconfirmed)
    inDeal           := true
    entryPx          := close
    dealQty          := boVol / close
    peakSinceEntry   := close

// Track peak price while in deal (for trailing exit simulation)
if (inDeal and not na(entryPx))
    peakSinceEntry := math.max(peakSinceEntry, high)

// =====================================================================
//                       VIRTUAL EXIT (TP / Trail / SL)
// =====================================================================
tpActivPx = not na(entryPx) ? entryPx * (1.0 + tpPct)  : na
slPx      = not na(entryPx) ? entryPx * (1.0 - slPct)  : na

// Trailing TP fires when:
//   peak reached activation level AND price retraces by trail deviation from peak
trailHit = false
if inDeal and trailEnabled and not na(peakSinceEntry) and not na(tpActivPx) and peakSinceEntry >= tpActivPx
    trailExitPx = peakSinceEntry * (1.0 - trailDevPct)
    if low <= trailExitPx
        trailHit := true

// Fixed TP (if trailing off): fires when high >= activation level
fixedTpHit = inDeal and (not trailEnabled) and not na(tpActivPx) and high >= tpActivPx

// SL fires when low <= SL price
slHit = inDeal and useSL and not na(slPx) and low <= slPx

exitNow = inDeal and (trailHit or fixedTpHit or slHit) and barstate.isconfirmed

// =====================================================================
//                  VIRTUAL P&L / STATS TRACKER
// =====================================================================
var float vNetProfit   = 0.0
var float vGrossProfit = 0.0
var float vGrossLoss   = 0.0
var int   vTrades      = 0
var int   vWins        = 0
var float vPeakEquity  = 0.0
var float vMaxDD       = 0.0

if exitNow
    // Approximate fill price: SL fills at slPx, trail fills at peak * (1 - trailDev), fixed TP at tpActivPx
    fillPx = slHit ? slPx :
             trailHit ? peakSinceEntry * (1.0 - trailDevPct) :
             fixedTpHit ? tpActivPx :
             close
    realizedPnl = (fillPx - entryPx) * dealQty

    vNetProfit := vNetProfit + realizedPnl
    vTrades    := vTrades + 1
    if realizedPnl >= 0
        vWins        := vWins + 1
        vGrossProfit := vGrossProfit + realizedPnl
    else
        vGrossLoss   := vGrossLoss + math.abs(realizedPnl)

    // Reset deal state
    inDeal         := false
    entryPx        := na
    dealQty        := 0.0
    peakSinceEntry := na

// Drawdown via peak-equity tracking
vPeakEquity := math.max(vPeakEquity, vNetProfit)
currentDD   = vPeakEquity - vNetProfit
vMaxDD      := math.max(vMaxDD, currentDD)

// =====================================================================
//                             VISUALS
// =====================================================================
// MA debug lines
plot(showMAs ? maFastVal : na, "Fast MA", color = color.new(#00BCD4, 0), linewidth = 1)
plot(showMAs ? maSlowVal : na, "Slow MA", color = color.new(#FF9800, 0), linewidth = 1)

// Position-related lines (only when virtual deal is active)
plot(showEntryLn and inDeal ? entryPx                : na, "Entry",    color = color.aqua,  style = plot.style_linebr, linewidth = 2)
plot(showTpLn    and inDeal ? entryPx * (1.0 + tpPct) : na, "TP/Trail", color = color.lime,  style = plot.style_linebr, linewidth = 1)
plot(showSlLn    and inDeal and useSL ? entryPx * (1.0 - slPct) : na, "SL", color = color.red, style = plot.style_linebr, linewidth = 1)

// Signal markers
plotshape(showShapes and useMACross and maCrossSig, "MA Cross",     shape.triangledown, location.abovebar, color = color.new(#FF9800, 30), size = size.tiny, text = "MA",  textcolor = color.new(#FF9800, 0))
plotshape(showShapes and useCCI and cciSig,         "CCI Oversold", shape.triangleup,   location.belowbar, color = color.new(#00BCD4, 30), size = size.tiny, text = "CCI", textcolor = color.new(#00BCD4, 0))
plotshape(showShapes and entrySignal and not inDeal[1], "Long Entry", shape.triangleup, location.belowbar, color = color.green, size = size.small, text = "L", textcolor = color.green)
plotshape(showShapes and exitNow,                       "Exit",       shape.diamond,    location.abovebar, color = color.aqua,  size = size.small)

// =====================================================================
//                          STATS CARD
// =====================================================================
f_pos(s) =>
    s == "top_left"      ? position.top_left      :
     s == "top_center"    ? position.top_center    :
     s == "top_right"     ? position.top_right     :
     s == "middle_left"   ? position.middle_left   :
     s == "middle_center" ? position.middle_center :
     s == "middle_right"  ? position.middle_right  :
     s == "bottom_left"   ? position.bottom_left   :
     s == "bottom_center" ? position.bottom_center :
     position.bottom_right

f_size(s) =>
    s == "tiny"   ? size.tiny   :
     s == "small"  ? size.small  :
     s == "normal" ? size.normal :
     s == "large"  ? size.large  :
     size.huge

np      = vNetProfit
npPct   = initCapital > 0 ? np / initCapital * 100 : 0.0
dd      = vMaxDD
ddPct   = initCapital > 0 ? dd / initCapital * 100 : 0.0
nTrades = vTrades
wins    = vWins
wrPct   = nTrades > 0 ? wins / nTrades * 100 : 0.0
pf      = vGrossLoss > 0 ? vGrossProfit / vGrossLoss : 0.0

clrPos    = color.new(#00C853, 0)
clrNeg    = color.new(#D50000, 0)
clrNeutral= color.new(#FFFFFF, 10)
clrHdrBg  = color.new(#1E88E5, 10)
clrRowBg  = color.new(#0D1B2A, 25)
clrAltBg  = color.new(#152238, 25)
clrBorder = color.new(#1E88E5, 60)

var table stats = na

if showStats and barstate.islast
    if na(stats)
        stats := table.new(f_pos(statsPosStr), 2, 6, bgcolor = clrRowBg, border_width = 1, border_color = clrBorder, frame_color = clrBorder, frame_width = 1)

    table.cell(stats, 0, 0, "BACKTEST RESULTS", text_color = color.white, text_size = size.normal, bgcolor = clrHdrBg, text_halign = text.align_center)
    table.cell(stats, 1, 0, "—",                text_color = clrHdrBg,   text_size = size.normal, bgcolor = clrHdrBg, text_halign = text.align_center)

    table.cell(stats, 0, 1, "Net P&L",  text_color = clrNeutral, text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_left)
    table.cell(stats, 1, 1, (np >= 0 ? "+" : "") + str.tostring(np, "0.00") + "  (" + (npPct >= 0 ? "+" : "") + str.tostring(npPct, "0.00") + "%)",
         text_color = np >= 0 ? clrPos : clrNeg, text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_right)

    table.cell(stats, 0, 2, "Max Drawdown", text_color = clrNeutral, text_size = size.normal, bgcolor = clrAltBg, text_halign = text.align_left)
    table.cell(stats, 1, 2, str.tostring(dd, "0.00") + "  (" + str.tostring(ddPct, "0.00") + "%)",
         text_color = clrNeg, text_size = size.normal, bgcolor = clrAltBg, text_halign = text.align_right)

    table.cell(stats, 0, 3, "Total Trades", text_color = clrNeutral, text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_left)
    table.cell(stats, 1, 3, str.tostring(nTrades), text_color = clrNeutral, text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_right)

    table.cell(stats, 0, 4, "Win Rate", text_color = clrNeutral, text_size = size.normal, bgcolor = clrAltBg, text_halign = text.align_left)
    table.cell(stats, 1, 4, str.tostring(wrPct, "0.00") + "%  (" + str.tostring(wins) + "/" + str.tostring(nTrades) + ")",
         text_color = wrPct >= 50 ? clrPos : clrNeg, text_size = size.normal, bgcolor = clrAltBg, text_halign = text.align_right)

    table.cell(stats, 0, 5, "Profit Factor", text_color = clrNeutral, text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_left)
    table.cell(stats, 1, 5, str.tostring(pf, "0.000"), text_color = pf >= 1.5 ? clrPos : (pf >= 1.0 ? clrNeutral : clrNeg), text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_right)

// =====================================================================
//                          BRAND WATERMARK
// =====================================================================
var table wm = na
if showWM and barstate.islast
    if na(wm)
        wm := table.new(f_pos(wmPosStr), 1, 1, bgcolor = color.new(color.black, 100), border_width = 0)
    table.cell(wm, 0, 0, wmText, text_color = color.new(color.white, wmAlpha), text_size = f_size(wmSizeStr), bgcolor = color.new(color.black, 100))

// =====================================================================
//                          WEBHOOK ALERTS
// =====================================================================
dealStartMsg = '{"message_type":"bot","bot_id":' + botId +
     ',"email_token":"' + emailToken + '","delay_seconds":0,"pair":"' + pairLabel + '"}'
dealCloseMsg = '{"action":"close_at_market_price","message_type":"bot","bot_id":' + botId +
     ',"email_token":"' + emailToken + '","delay_seconds":0,"pair":"' + pairLabel + '"}'

// Deal Start
if (entrySignal and not inDeal[1] and barstate.isconfirmed)
    alert(dealStartMsg, alert.freq_once_per_bar_close)

// Deal Close (trailing TP / fixed TP / SL)
if (exitNow)
    alert(dealCloseMsg, alert.freq_once_per_bar_close)
````
