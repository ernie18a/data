# [3Commas] Pullback Sniper - Indicator

- url: https://www.tradingview.com/script/bQXt0dRL-3Commas-Pullback-Sniper-Indicator/
- type: indicator
- pine_id: PUB;39b355284ee742c2a725583185a3e465
- version: 1.0

## Description

🔷 What it does:
This indicator visualizes a long-only Dollar-Cost-Averaging signal framework driven by a classic RSI oversold-exit trigger on a 3-minute timeframe. It marks base order entries, projects the full safety order ladder, tracks a virtual deal lifecycle on the chart, and exposes webhook-ready alerts for automated execution through an external DCA Bot. No orders are placed by the indicator itself — it is a pure signal and visualization layer.

Base Order signal: RSI(14) crosses below 31 on 3m
Safety Order ladder: 5 levels projected as horizontal lines from base, with filled-state coloring (martingale ×1.30 deviation, ×1.25 volume)
Exit signal: RSI(14) crosses above 69 AND profit ≥ 2.4% from average entry (dual-gate)
On-chart virtual P&L tracker: Net Profit, Max Drawdown, Trades, Win Rate, Profit Factor

🔷 Who is it for:
Bot operators who need a visual confirmation layer for automated intraday DCA execution.
Discretionary traders who use structured averaging logic manually and want clear on-chart triggers.
Free-tier TradingView users who want access to the same signal logic as the Strategy version without requiring backtest functionality.
Cross-instrument testers who run the same signal framework across crypto, perpetuals, and tokenized equities.

🔷 How does it work:
Long Entry: A base order signal fires when RSI(14, 3m) crosses below 31. The indicator marks this with a green triangle below the bar and stores the base price as the reference for the safety order ladder.
Short Entry: Not used - long-only signal framework by design.
Exit Management: A take-profit signal fires when two conditions align simultaneously - RSI(14, 3m) crosses above 69 AND the unrealized profit from average entry reaches the minimum threshold (default 2.4%). This dual gate prevents premature exits during shallow rebounds and structural exits when profit has not yet recovered. The indicator marks the exit with a cyan diamond and resets the virtual deal state.

🔷 Why it's unique:
Dual-gate exit logic - closing requires both an RSI sell signal AND a minimum profit threshold from average entry. This combination filters out RSI-triggered exits that would close deep-averaged positions at a loss, ensuring every signaled close is structurally sound.
Cumulative martingale architecture - safety order trigger prices are computed from the base entry using a cumulative compounding deviation (each successive step multiplied by ×1.30), not by chaining from the previous SO. This produces a smoother, more controlled deepening of the ladder versus pure linear stepping. The full ladder is projected on chart from the moment of base entry, so traders see the entire risk envelope upfront.
Bot Integration - entry and exit alerts ship with webhook-ready JSON payloads, enabling direct trigger of a connected DCA Bot. Two alert conditions ("Deal Start" and "Deal Close") map cleanly to bot deal-start and close-deal endpoints, with Bot ID, Email Token, and pair label all configurable through inputs.

🔷 What you'll see on the chart:
Green triangle (below bar) - Base Order entry signal fired
Red triangle (above bar) - RSI sell signal fired
Cyan diamond - Dual-gate exit triggered, virtual deal closed
Cyan line - Base Entry price (reference for the SO ladder)
Yellow line - Average Entry price (recalculates as SOs fill)
Lime line - Take Profit target (Average × (1 + minProfit%))
Red lines (5) - Full SO ladder projected from base; fades as each level fills
Stats card (top-left, configurable) - Live virtual backtest results: Net Profit, Max Drawdown, Total Trades, Win Rate, Profit Factor

🔷 Considerations Before Using the Indicator:
Market & Timeframe: Designed for a 3-minute base chart on liquid, volatile instruments with active intraday RSI cycling - perpetual contracts, tokenized equities, and major altcoins. Performance degrades on low-volatility assets where RSI rarely reaches the oversold trigger.
Limitations: The indicator does not place orders. It tracks a "virtual deal" state on the chart for visualization purposes only — actual execution must be performed through a connected bot or manually. The signal framework carries no stop-loss component; in sustained downtrends extending beyond the deepest safety order, the virtual deal holds unrealized loss until either the average is recovered or the alert flow is manually overridden. The dual-gate exit can hold positions for extended periods if RSI never crosses above 69 while the profit threshold is unmet — pair this with a manual review cadence.
Virtual P&L Accuracy: The on-chart stats card uses a simplified internal accounting model - it does not factor exchange commission or slippage. Use the Strategy version for fee-adjusted backtest results.
Backtesting & Demo Testing: Always validate the signal framework on historical data before connecting to a live bot. The companion Strategy version of this script is available on the same profile for full backtest analysis with realistic commissions and slippage. Demo-trade for at least one month to observe behavior in conditions not represented in historical data. Past performance is not indicative of future results.
Parameter Adjustments: RSI thresholds (31 / 69) and the SO step (1.3%) should be tuned per instrument volatility profile. Tighter levels on lower-volatility assets, wider on more volatile pairs. The minimum profit threshold can be lowered to 1.5–2.0% for higher trade frequency or raised to 3.0–4.0% for fewer, larger captures.

🔷 Backtest Validation:
This indicator shares identical signal logic with the Strategy version of the same framework, available on this profile for full historical performance review with realistic commission and slippage:
Strategy version: https://www.tradingview.com/script/XbtQXDMb-3Commas-Pullback-Sniper-Strategy/
Reference results from the Strategy version on BYBIT:ADAUSDT (Spot), 3m chart, tested period Feb 9 — May 11, 2026:
Net Profit: +95.00 USDT (+0.95%)   |   Max Drawdown: 67.16 USDT (0.67%)   |   Total Trades: 47   |   Win Rate: 72.34% (34/47)   |   Profit Factor: 7.377
Refer to the Strategy publication for the complete equity curve, trade-by-trade breakdown, and Strategy Tester report.

🔷 How to Use It:
🔸 Adjust Settings: Configure the RSI thresholds, SO step, and minimum profit parameters for the instrument you intend to trade. Defaults are calibrated for liquid altcoin spot pairs on a 3-minute chart. For lower-volatility instruments, tighten the SO step and lower the take-profit threshold; for higher-volatility instruments, do the opposite.
🔸 Visual Confirmation: Use the on-chart projections (base entry, SO ladder, average entry, TP target) to verify that the active virtual deal aligns with your bot's actual position. The indicator's virtual deal state is a 1-to-1 mirror of the Strategy version's signal logic, so any divergence between chart visuals and bot position is a flag for investigation.
🔸 Create alerts to trigger the DCA Bot: Two alert events are exposed by the indicator - "Deal Start" fires on each new base order signal, and "Deal Close" fires when the dual-gate exit triggers. Configure both alerts in TradingView with the webhook URL pointing to your DCA Bot's signal endpoint. The Bot ID, Email Token, and Pair label can be set in the script's inputs and are automatically embedded into the alert JSON payload. Once configured, the indicator publishes the signal and the bot handles execution on the exchange autonomously.

🔷 INDICATOR SETTINGS
RSI Length - Period for the RSI calculation (default 14).
RSI Buy Trigger (cross below) - Oversold threshold for the base order signal (default 31).
RSI Sell Trigger (cross above) - Overbought threshold for the exit signal (default 69).
Base Order Volume (USDT, ref) - Reference notional for the initial entry; used for Average Entry projection only.
Safety Order Volume (USDT, ref) - Reference notional for the first averaging-down order; subsequent SOs scale by Volume Coefficient.
Max Safety Orders - Total number of averaging steps tracked in the virtual deal.
Price Deviation % (SO step from base) - Percentage deviation for the first safety order; subsequent steps scale by Step Coefficient.
Martingale Volume Coefficient - Size multiplier applied to each successive safety order.
Martingale Step Coefficient - Multiplier applied to each successive deviation step.
Min Profit % (from avg entry) - Minimum unrealized profit threshold required for the exit gate.
Require RSI Sell Signal to Close - When enabled, both the RSI sell crossover AND the min profit threshold must align (dual-gate exit).
Initial Capital (ref for % calc) - Reference capital base for computing return and drawdown percentages in the stats card.
Visual Layer toggles - Show/hide base line, average line, TP line, full SO ladder, signal triangles.
Stats card / Watermark - Display layer controls for on-chart virtual backtest summary and branding.

Webhook - Bot ID, Email Token, and Pair label for DCA Bot signal routing.

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.
__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=6
// =====================================================================
//  [3Commas] Pullback Sniper — Signal Indicator
//  Companion to the Strategy version with identical signal logic.
// ---------------------------------------------------------------------
//  Mirrors the Strategy version:
//    Entry       : RSI(14) crossing below 31  on 3m  (default)
//    Exit        : RSI(14) crossing above 69  on 3m
//                  AND profit >= 2.4% from avg entry (dual-gate close)
//    Base order  : 45 USDT (reference for AVG projection)
//    Safety ord  : 55 USDT, max 5, step 1.3% from base (cumulative),
//                  martingale: vol x1.25, step x1.30
//    Stop loss   : disabled
//
//  Use cases:
//    - Visual signal confirmation for bot-driven execution
//    - Live overlay of the strategy logic on any chart
//    - Webhook source for automated DCA Bot integration
//
//  Visual layer:
//    - BO entry signal:  green triangle below bar
//    - Sell signal:      red triangle above bar
//    - Lines: Base Entry, Avg Entry, TP target, Next SO + full SO ladder
//    - Faded color when an SO level has already been filled
// =====================================================================

indicator(
     title              = "[3Commas] Pullback Sniper — Indicator",
     shorttitle         = "PB Sniper",
     overlay            = true,
     max_lines_count    = 100,
     max_labels_count   = 100,
     max_bars_back      = 500)

// =====================================================================
//                              INPUTS
// =====================================================================
rsiLen     = input.int  (14,   "RSI Length",                    minval = 2, group = "RSI Settings")
rsiBuyLvl  = input.float(31.0, "RSI Buy Trigger (cross below)",             group = "RSI Settings")
rsiSellLvl = input.float(69.0, "RSI Sell Trigger (cross above)",            group = "RSI Settings")

boVol    = input.float(45.0,  "Base Order Volume (USDT, ref)",       group = "DCA / Safety Orders")
soVol    = input.float(55.0,  "Safety Order Volume (USDT, ref)",     group = "DCA / Safety Orders")
maxSO    = input.int  (5,     "Max Safety Orders",  minval = 0, maxval = 15, group = "DCA / Safety Orders")
soStep   = input.float(1.3,   "Price Deviation % (SO step from base)", step = 0.1, group = "DCA / Safety Orders")
volCoef  = input.float(1.25,  "Martingale Volume Coefficient",       step = 0.05, group = "DCA / Safety Orders")
stepCoef = input.float(1.30,  "Martingale Step Coefficient",         step = 0.05, group = "DCA / Safety Orders")

minProfit   = input.float(2.4,  "Min Profit % (from avg entry)", step = 0.1, group = "Take Profit")
useCloseSig = input.bool (true, "Require RSI Sell Signal to Close (dual-gate)", group = "Take Profit")

initCapital = input.float(10000, "Initial Capital (USDT, ref for % calc)", minval = 1, group = "Virtual Backtest")

botId      = input.string("12345678",         "Bot ID",                                      group = "Webhook (DCA Bot)")
emailToken = input.string("YOUR_EMAIL_TOKEN", "Email Token",                                 group = "Webhook (DCA Bot)")
pairLabel  = input.string("USDT_ADA",         "Pair (Bot format: QUOTE_BASE)",               group = "Webhook (DCA Bot)")

// — Visual layer toggles —
showBaseLine = input.bool(true, "Show Base Entry line",     group = "Visual Layer")
showAvgLine  = input.bool(true, "Show Avg Entry line",      group = "Visual Layer")
showTpLine   = input.bool(true, "Show TP Target line",      group = "Visual Layer")
showAllSO    = input.bool(true, "Show full SO ladder",      group = "Visual Layer")
showShapes   = input.bool(true, "Show signal triangles",    group = "Visual Layer")

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
rsiVal  = ta.rsi(close, rsiLen)
buySig  = ta.crossunder(rsiVal, rsiBuyLvl)
sellSig = ta.crossover (rsiVal, rsiSellLvl)

// =====================================================================
//                          VIRTUAL DEAL STATE
// =====================================================================
var bool  inDeal      = false
var float basePrice   = na
var float totalVolume = 0.0
var float totalQty    = 0.0
var int   soCount     = 0

avgPrice = totalQty > 0 ? totalVolume / totalQty : na
tpPrice  = na(avgPrice) ? na : avgPrice * (1.0 + minProfit / 100.0)

// =====================================================================
//                              HELPERS
// =====================================================================
soTriggerPrice(int n) =>
    dev = 0.0
    s   = soStep
    for i = 1 to n
        dev := dev + s
        s   := s * stepCoef
    basePrice * (1.0 - dev / 100.0)

soVolume(int n) =>
    soVol * math.pow(volCoef, n - 1)

// =====================================================================
//                       VIRTUAL DEAL OPEN (BO)
// =====================================================================
if (not inDeal and buySig and barstate.isconfirmed)
    qty = boVol / close
    inDeal      := true
    basePrice   := close
    totalVolume := boVol
    totalQty    := qty
    soCount     := 0

// =====================================================================
//                       VIRTUAL SAFETY ORDERS
// =====================================================================
if (inDeal and barstate.isconfirmed)
    while soCount < maxSO
        nextSO = soCount + 1
        trig   = soTriggerPrice(nextSO)
        if low <= trig
            v = soVolume(nextSO)
            q = v / trig
            totalVolume := totalVolume + v
            totalQty    := totalQty + q
            soCount     := nextSO
        else
            break

// =====================================================================
//                  VIRTUAL EXIT (TP via dual gate)
// =====================================================================
canCloseBySignal = (not useCloseSig) or sellSig
priceOK          = not na(tpPrice) and close >= tpPrice
exitNow          = inDeal and canCloseBySignal and priceOK and barstate.isconfirmed

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
    // Capture P&L BEFORE resetting deal state
    realizedPnl = (close - avgPrice) * totalQty
    vNetProfit  := vNetProfit + realizedPnl
    vTrades     := vTrades + 1
    if realizedPnl >= 0
        vWins         := vWins + 1
        vGrossProfit  := vGrossProfit + realizedPnl
    else
        vGrossLoss    := vGrossLoss + math.abs(realizedPnl)

    // Reset deal state
    inDeal      := false
    basePrice   := na
    totalVolume := 0.0
    totalQty    := 0.0
    soCount     := 0

// Drawdown via peak-equity tracking
vPeakEquity := math.max(vPeakEquity, vNetProfit)
currentDD   = vPeakEquity - vNetProfit
vMaxDD      := math.max(vMaxDD, currentDD)

// =====================================================================
//                             VISUALS
// =====================================================================
plot(inDeal and showAvgLine  ? avgPrice  : na, "Avg Entry",  color = color.yellow, style = plot.style_linebr, linewidth = 2)
plot(inDeal and showTpLine   ? tpPrice   : na, "TP Target",  color = color.lime,   style = plot.style_linebr, linewidth = 2)
plot(inDeal and showBaseLine ? basePrice : na, "Base Price", color = color.aqua,   style = plot.style_linebr)

plot(inDeal and showAllSO and soCount < 1 ? soTriggerPrice(1) : na, "SO1", color = color.new(color.red, 40), style = plot.style_linebr)
plot(inDeal and showAllSO and soCount < 2 ? soTriggerPrice(2) : na, "SO2", color = color.new(color.red, 50), style = plot.style_linebr)
plot(inDeal and showAllSO and soCount < 3 ? soTriggerPrice(3) : na, "SO3", color = color.new(color.red, 60), style = plot.style_linebr)
plot(inDeal and showAllSO and soCount < 4 ? soTriggerPrice(4) : na, "SO4", color = color.new(color.red, 70), style = plot.style_linebr)
plot(inDeal and showAllSO and soCount < 5 ? soTriggerPrice(5) : na, "SO5", color = color.new(color.red, 80), style = plot.style_linebr)

plotshape(showShapes and buySig  and not inDeal[1], "Buy Sig",  shape.triangleup,   location.belowbar, color = color.green, size = size.tiny)
plotshape(showShapes and sellSig and inDeal,        "Sell Sig", shape.triangledown, location.abovebar, color = color.red,   size = size.tiny)
plotshape(showShapes and exitNow,                   "TP Hit",   shape.diamond,      location.abovebar, color = color.aqua,  size = size.small)

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

// Aggregated metrics from virtual tracker
np      = vNetProfit
npPct   = initCapital > 0 ? np / initCapital * 100 : 0.0
dd      = vMaxDD
ddPct   = initCapital > 0 ? dd / initCapital * 100 : 0.0
nTrades = vTrades
wins    = vWins
wrPct   = nTrades > 0 ? wins / nTrades * 100 : 0.0
pf      = vGrossLoss > 0 ? vGrossProfit / vGrossLoss : 0.0

// Colors (same scheme as Strategy version)
clrPos    = color.new(#00C853, 0)
clrNeg    = color.new(#D50000, 0)
clrNeutral= color.new(#FFFFFF, 10)
clrHdrBg  = color.new(#1E88E5, 10)
clrRowBg  = color.new(#0D1B2A, 25)
clrAltBg  = color.new(#152238, 25)
clrBorder = color.new(#1E88E5, 60)

var table stats = table.new(f_pos(statsPosStr), 2, 6, bgcolor = clrRowBg, border_width = 1, border_color = clrBorder, frame_color = clrBorder, frame_width = 1)

if showStats and barstate.islast
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
var table wm = table.new(f_pos(wmPosStr), 1, 1, bgcolor = color.new(color.black, 100), border_width = 0)
if showWM and barstate.islast
    table.cell(wm, 0, 0, wmText, text_color = color.new(color.white, wmAlpha), text_size = f_size(wmSizeStr), bgcolor = color.new(color.black, 100))

// =====================================================================
//                          WEBHOOK ALERTS
// =====================================================================
dealStartMsg = '{"message_type":"bot","bot_id":' + botId +
     ',"email_token":"' + emailToken + '","delay_seconds":0,"pair":"' + pairLabel + '"}'
dealCloseMsg = '{"action":"close_at_market_price","message_type":"bot","bot_id":' + botId +
     ',"email_token":"' + emailToken + '","delay_seconds":0,"pair":"' + pairLabel + '"}'

// Deal Start (BO entry)
if (buySig and not inDeal[1] and barstate.isconfirmed)
    alert(dealStartMsg, alert.freq_once_per_bar_close)

// Deal Close (dual-gate exit)
if (exitNow)
    alert(dealCloseMsg, alert.freq_once_per_bar_close)
````
