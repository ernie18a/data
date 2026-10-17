# [3Commas] Gold Vault Long - Indicator

- url: https://www.tradingview.com/script/CvDDW0ms-3Commas-Gold-Vault-Long-Indicator/
- type: indicator
- pine_id: PUB;2209fc4bbb47472385d9f1ef7b66daac
- version: 1.0

## Description

[3Commas] Gold Vault Long — Indicator

🔷 What it does:
This indicator visualizes a long-only Dollar-Cost-Averaging signal framework for tokenized gold, mirroring the Gold Vault Long strategy. It marks base order entries continuously, projects the full 3-level safety order ladder at constant 2% intervals, tracks a virtual deal lifecycle on the chart, and exposes webhook-ready alerts for automated execution through an external DCA Bot. No orders are placed by the indicator itself — it is a pure signal and visualization layer.
  - Base Order signal: opens immediately when no active deal exists (nonstop reload)
  - Safety Order ladder: 3 levels at constant 2% intervals (cumulative −2% / −4% / −6%)
  - Exit signal: pure 1.5% take-profit from average entry (no signal gates)
  - On-chart virtual P&L tracker: Net Profit, Max Drawdown, Trades, Win Rate, Profit Factor

🔷 Who is it for:
  Traders seeking visual exposure to tokenized gold DCA execution.
  Bot operators who automate execution through webhook integration with a DCA Bot.
  Free-tier TradingView users who want access to the same signal logic as the Strategy version without requiring backtest functionality.
  Long-term accumulators who prefer predictable, simple mechanics over complex signal stacks.

🔷 How does it work:
  Long Entry Signal: When no virtual deal is active, the indicator marks a Base Order fill on the next confirmed bar with a green "BO" triangle below the bar. The base price, total cost, and quantity are recorded for later P&L calculation.
  Short Entry: Not used — long-only signal framework by design.
  Exit Management: A take-profit signal fires when price reaches Average Entry × (1 + 1.5%). On exit, the indicator marks the bar with a cyan "TP" diamond, computes the realized P&L as (tpPrice − avgPrice) × totalQty, and resets the virtual deal state. There is no signal-based exit gate — the strategy is intentionally simple and predictable.

🔷 Why it's unique:
  Tokenized gold focus — most DCA indicators target crypto-native pairs. This one specifically calibrates for tokenized precious metals like XAUT with conservative 2% SO steps and a tight 1.5% take-profit, matching gold's lower-volatility profile versus crypto.
  Simplicity by design — no RSI, no trend filters, no signal stacks. Pure DCA mechanics that are easy to backtest, easy to explain, and easy to monitor. The indicator's behavior is fully deterministic given the price action.
  Bot Integration — entry and exit alerts ship with webhook-ready JSON payloads. Bot ID, Email Token, and pair label are exposed as inputs and automatically embedded into the alert message format.

🔷 What you'll see on the chart:
  Cyan line — Base Entry price (reference for the SO ladder)
  Yellow line — Average Entry price (recalculates as SOs fill)
  Lime line — Take Profit target (Average × 1.015)
  Red lines (3) — Full SO ladder projected from base at constant 2% intervals; fades to gray as each level fills
  Green "BO" triangle (below bar) — New virtual deal opened
  Red "SO" triangle (above bar) — Safety order filled at one of the ladder levels
  Cyan "TP" diamond (above bar) — Take-profit hit, deal closed
  Background tints — Green on BO bar, Red on SO bar, Cyan on TP bar
  Stats card (top-left, configurable) — Live virtual results: Net P&L, Max Drawdown, Total Trades, Win Rate, Profit Factor

🔷 Considerations Before Using the Indicator:

  Market & Timeframe: Designed for 2-hour chart on tokenized gold instruments (XAUT/USDT and similar precious metals tokens). The defaults align with the Strategy version's reference backtest. Lower timeframes increase trade frequency and commission drag; higher timeframes produce slower-cycling deals with longer holding periods.

  Limitations: The indicator does not place orders. It tracks a "virtual deal" state on chart for visualization purposes only — actual execution must be performed through a connected bot or manually. The signal framework carries no stop loss; in drawdowns extending beyond the deepest safety order (−6% from base), the virtual deal holds unrealized loss until either the average is recovered or the alert flow is manually overridden. Gold's historical drawdowns occasionally exceed 6% during macro stress events — combine this strategy with awareness of macro context.

  Virtual P&L Accuracy: The on-chart stats card uses a simplified internal accounting model — it does not factor exchange commission or slippage. Realized profit is computed as the raw (tpPrice − avgPrice) × qty at the moment of exit. Use the Strategy version for fee-adjusted backtest results.

  Backtesting & Demo Testing: Always validate the signal framework on historical data before connecting to a live bot. The companion Strategy version is available on the same profile for full backtest analysis with realistic commissions and slippage. Demo-trade for at least one month to observe behavior in conditions not represented in historical data. Past performance is not indicative of future results.

  Parameter Adjustments: The 2% SO step and 1.5% TP are tuned for gold's typical intraday range. For higher-volatility precious metals tokens, widen both proportionally. SO size and base order volume should be scaled to your account's risk tolerance — the default 12 / 9-USDT structure assumes a small test account.

🔷 Backtest Validation:

  This indicator shares identical signal logic with the Strategy version of the same framework, available on this profile for full historical performance review with realistic commission and slippage:

  Strategy version: https://www.tradingview.com/script/j36wYVnI-3Commas-Gold-Vault-Long/

  Reference 3Commas built-in backtest on XAUT/USDT (Bybit Spot, 2h chart), Mar 5 2025 — Mar 5 2026:
    PNL: +$19.66 (+29.21%) over 1 year

  Performance during different gold market regimes (bear markets, sustained sideways ranges, geopolitical stress periods) may differ significantly. The reference period covers a relatively bullish phase for tokenized gold. Refer to the Strategy publication for the complete Pine-simulated equity curve, trade-by-trade breakdown, and Strategy Tester report with venue-specific commission applied.

🔷 How to Use It:
  🔸 Adjust Settings: Configure Base Order and Safety Order volumes proportional to your account size. The default 12 / 9-USDT structure is calibrated for a 500-USDT test account with max position ≈ 40 USDT (8% capital deployment); scale linearly to your equity. The 2% SO step and 1.5% TP should be retuned proportionally if you switch from gold to higher-volatility precious metals tokens.

  🔸 Visual Confirmation: Use the on-chart projections (base entry, SO ladder, average entry, TP target) to verify that the active virtual deal aligns with your bot's actual position. The indicator's virtual deal state is a 1-to-1 mirror of the Strategy version's logic (minus commission), so any major divergence between chart visuals and bot position is a flag for investigation.

  🔸 Create alerts to trigger the DCA Bot: Two alert events are exposed by the indicator — "Deal Start" fires on each new base order signal, and "Deal Close" fires when the 1.5% take-profit target is hit. Configure both alerts in TradingView with the webhook URL pointing to your DCA Bot's signal endpoint. The Bot ID, Email Token, and Pair label can be set in the script's inputs and are automatically embedded into the alert JSON payload.

🔷 INDICATOR SETTINGS
  Base Order Volume (USDT, ref) — Reference notional for the initial entry; used for virtual P&L calculation.
  Safety Order Volume (USDT, ref) — Reference notional for the first averaging-down order.
  Max Safety Orders — Total number of averaging steps tracked in the virtual deal.
  Price Step % (1st SO from base) — Percentage deviation from base price for the first safety order.
  Deviation Step Multiplier — Multiplier applied to each successive deviation step (default 1.0 = constant step).
  Order Size Multiplier — Size multiplier applied to each successive safety order (default 1.05 = 5% per step).
  Take Profit % (from avg entry) — Profit target percentage measured from average entry price.
  Limit by Date Range — Constrain virtual backtest to a specific date window.
  Initial Capital (ref for % calc) — Reference capital base for percentage metrics in the stats card.
  Visual Layer toggles — Show/hide base line, average line, TP line, SO ladder, signal markers.
  Stats card / Watermark — Display layer controls for on-chart virtual backtest summary and branding.
  Webhook — Bot ID, Email Token, and Pair label for DCA Bot signal routing.

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.

__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=6
// =====================================================================
//  [3Commas] Gold Vault Long — Indicator
//  Companion to the Strategy version with identical signal logic.
// ---------------------------------------------------------------------
//  Identical DCA mechanics to the Strategy version:
//    - Nonstop entry — opens base order when no active deal exists
//    - 3 safety orders with constant 2% step (cumulative −2% / −4% / −6%)
//    - Volume coef 1.05 → 9.00 / 9.45 / 9.92 USDT
//    - Pure %-TP: close when price ≥ avg × 1.015 (no signal gates)
//
//  Strategy reference (BYBIT:XAUTUSDT, 2h, Mar 5 2025 — Mar 5 2026):
//    3Commas built-in backtest PNL: +$19.66 (+29.21%) over 1 year
//
//  Use cases:
//    - Visual signal confirmation for bot-driven DCA on tokenized gold
//    - Live overlay of the strategy logic on any precious-metals token
//    - Webhook source for automated DCA Bot integration
//
//  Visual layer:
//    - Base, Avg, TP target, 3 SO ladder lines
//    - BO entry / SO fill / TP close markers with labels
//    - Stats card with virtual P&L, DD, Trades, Win Rate, PF
//    - Brand watermark
// =====================================================================

indicator(
     title              = "[3Commas] Gold Vault Long — Indicator",
     shorttitle         = "Gold Vault Ind",
     overlay            = true,
     max_lines_count    = 100,
     max_labels_count   = 300,
     max_bars_back      = 500)

// =====================================================================
//                              INPUTS
// =====================================================================
boVol    = input.float(12.0, "Base Order Volume (USDT, ref)",         group = "DCA / Safety Orders")
soVol    = input.float(9.0,  "Safety Order Volume (USDT, ref)",       group = "DCA / Safety Orders")
maxSO    = input.int  (3,    "Max Safety Orders",  minval = 0, maxval = 15, group = "DCA / Safety Orders")
soStep   = input.float(2.0,  "Price Step % (1st SO from base)",  step = 0.05, group = "DCA / Safety Orders")
stepCoef = input.float(1.0,  "Deviation Step Multiplier",       step = 0.01, group = "DCA / Safety Orders")
volCoef  = input.float(1.05, "Order Size Multiplier",            step = 0.01, group = "DCA / Safety Orders")

// — Take Profit —
tpPct = input.float(1.5, "Take Profit % (from avg entry)", minval = 0.01, step = 0.05, group = "Take Profit") / 100.0

useDates = input.bool(true, "Limit by Date Range",                                                  group = "Backtest Period")
startTs  = input.time(timestamp("2025-03-05 00:00 +0000"), "Start", group = "Backtest Period")
endTs    = input.time(timestamp("2026-03-05 23:59 +0000"), "End",   group = "Backtest Period")
inWindow = (not useDates) or (time >= startTs and time <= endTs)

initCapital = input.float(500, "Initial Capital (USDT, ref for % calc)", minval = 1, group = "Virtual Backtest")

botId      = input.string("12345678",         "Bot ID",                                      group = "Webhook (DCA Bot)")
emailToken = input.string("YOUR_EMAIL_TOKEN", "Email Token",                                 group = "Webhook (DCA Bot)")
pairLabel  = input.string("USDT_XAUT",        "Pair (Bot format: QUOTE_BASE)",               group = "Webhook (DCA Bot)")

// — Visual layer toggles —
showBaseLine = input.bool(true, "Show Base Entry line",     group = "Visual Layer")
showAvgLine  = input.bool(true, "Show Avg Entry line",      group = "Visual Layer")
showTpLine   = input.bool(true, "Show TP Target line",      group = "Visual Layer")
showSOLines  = input.bool(true, "Show SO ladder lines",     group = "Visual Layer")
showShapes   = input.bool(true, "Show entry/exit markers",  group = "Visual Layer")

// — Display layer (stats card + watermark) —
showStats   = input.bool   (true,        "Show stats card", group = "Display")
statsPosStr = input.string ("top_left",  "Stats card position",
     options = ["top_left","top_center","top_right","middle_left","middle_right","bottom_left","bottom_center","bottom_right"], group = "Display")
showWM      = input.bool   (true,        "Show watermark",   group = "Display")
wmText      = input.string ("3Commas",   "Watermark text",   group = "Display")
wmPosStr    = input.string ("top_right", "Watermark position",
     options = ["top_left","top_center","top_right","middle_left","middle_center","middle_right","bottom_left","bottom_center","bottom_right"], group = "Display")
wmSizeStr   = input.string ("huge",      "Watermark size",
     options = ["tiny","small","normal","large","huge"], group = "Display")
wmAlpha     = input.int    (70,          "Watermark transparency (0=solid)", minval = 0, maxval = 100, group = "Display")

// =====================================================================
//                       VIRTUAL DEAL STATE
// =====================================================================
var bool  inDeal      = false
var float basePrice   = na
var float totalVolume = 0.0
var float totalQty    = 0.0
var int   soCount     = 0

avgPrice = totalQty > 0 ? totalVolume / totalQty : na
tpPrice  = na(avgPrice) ? na : avgPrice * (1.0 + tpPct)

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
//                       VIRTUAL DEAL OPEN (BO — nonstop)
// =====================================================================
if (not inDeal and inWindow and barstate.isconfirmed)
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
//                       VIRTUAL EXIT — pure %-TP
// =====================================================================
priceOK = not na(tpPrice) and high >= tpPrice
exitNow = inDeal and priceOK and barstate.isconfirmed

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
    realizedPnl = (tpPrice - avgPrice) * totalQty
    vNetProfit  := vNetProfit + realizedPnl
    vTrades     := vTrades + 1
    if realizedPnl >= 0
        vWins         := vWins + 1
        vGrossProfit  := vGrossProfit + realizedPnl
    else
        vGrossLoss    := vGrossLoss + math.abs(realizedPnl)

    inDeal      := false
    basePrice   := na
    totalVolume := 0.0
    totalQty    := 0.0
    soCount     := 0

vPeakEquity := math.max(vPeakEquity, vNetProfit)
currentDD   = vPeakEquity - vNetProfit
vMaxDD      := math.max(vMaxDD, currentDD)

// =====================================================================
//                             VISUALS
// =====================================================================
plot(showBaseLine and inDeal ? basePrice : na, "Base Price", color = color.new(color.aqua,   0), style = plot.style_linebr, linewidth = 2)
plot(showAvgLine  and inDeal ? avgPrice  : na, "Avg Entry",  color = color.new(color.yellow, 0), style = plot.style_linebr, linewidth = 3)
plot(showTpLine   and inDeal ? tpPrice   : na, "TP Target",  color = color.new(color.lime,   0), style = plot.style_linebr, linewidth = 2)

plot(showSOLines and inDeal and maxSO >= 1 ? soTriggerPrice(1) : na, "SO1", color = soCount >= 1 ? color.new(color.gray, 70) : color.new(color.red, 20), style = plot.style_linebr, linewidth = 1)
plot(showSOLines and inDeal and maxSO >= 2 ? soTriggerPrice(2) : na, "SO2", color = soCount >= 2 ? color.new(color.gray, 70) : color.new(color.red, 35), style = plot.style_linebr, linewidth = 1)
plot(showSOLines and inDeal and maxSO >= 3 ? soTriggerPrice(3) : na, "SO3", color = soCount >= 3 ? color.new(color.gray, 70) : color.new(color.red, 50), style = plot.style_linebr, linewidth = 1)

boJustOpened = not inDeal[1] and inDeal
soJustAdded  = inDeal and soCount != nz(soCount[1]) and soCount > 0

plotshape(showShapes and boJustOpened, "BO Entry",  shape.triangleup,   location.belowbar, color = color.new(color.green,    0), size = size.normal, text = "BO",  textcolor = color.new(color.lime,    0))
plotshape(showShapes and soJustAdded,  "SO Fill",   shape.triangledown, location.abovebar, color = color.new(color.red,      0), size = size.small,  text = "SO",  textcolor = color.new(color.red,     0))
plotshape(showShapes and exitNow,      "TP Close",  shape.diamond,      location.abovebar, color = color.new(color.aqua,     0), size = size.normal, text = "TP",  textcolor = color.new(color.aqua,    0))

bgcolor(boJustOpened ? color.new(color.green, 90) : na, title = "BO bar")
bgcolor(exitNow      ? color.new(color.aqua,  90) : na, title = "TP bar")
bgcolor(soJustAdded  ? color.new(color.red,   92) : na, title = "SO bar")

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

if (not inDeal[1] and inDeal and barstate.isconfirmed)
    alert(dealStartMsg, alert.freq_once_per_bar_close)

if (exitNow)
    alert(dealCloseMsg, alert.freq_once_per_bar_close)
````
