# Leverage Strategy Shell [by Oberlunar]

- url: https://www.tradingview.com/script/gUFrZvdW/
- type: strategy
- pine_id: PUB;f36d9595cd634a7786bc235ea2172eef
- version: 5.0

## Description

[b]Leverage Strategy Shell ★ by Oberlunar[/b]

A quantitative strategy shell that executes no logic of its own. It receives entry and exit signals from any external indicator through a standardised protocol, then sizes each position through a full risk engine, executes against TradingView's broker emulator, and produces a post-trade analytics suite that no native strategy tester can match. Think of it as a risk manager that sits between your signal generator and the market.

The core idea is the separation of concerns. Your indicator decides [i]when[/i] to trade. This shell decides [i]how much[/i] to trade, enforces margin constraints, tracks every position through intrabar LTF data, and decomposes your equity curve into R-multiple and time distributions so you can see exactly where your edge lives — and where it doesn't.


[b]Signal Protocol[/b]

The shell reads three values from your indicator via [pine]input.source()[/pine]. Your indicator must plot them with [pine]display=display.none[/pine] so they don't clutter the chart.

[pine]
// In your indicator:
signal = longCondition ? 1 : shortCondition ? -1 : exitLong ? 2 : exitShort ? -2 : 0
stopPx = longCondition ? yourStopPrice : shortCondition ? yourStopPrice : 0
tpPx   = longCondition ? yourTPPrice : shortCondition ? yourTPPrice : 0

plot(signal, "Signal", display=display.none)
plot(stopPx, "Stop",   display=display.none)
plot(tpPx,   "TP",     display=display.none)
[/pine]

[b]Signal[/b] is the only mandatory source. It accepts five discrete values: [b]+1[/b] opens a long, [b]-1[/b] opens a short, [b]+2[/b] closes an open long, [b]-2[/b] closes an open short, and [b]0[/b] means no action. The shell is edge-triggered — it fires only on the transition from one value to another, so holding +1 for multiple bars will not produce multiple entries.

[b]Stop[/b] is optional. When your indicator provides a stop price, the shell uses it for the exit order and for computing the risk distance that drives position sizing. When the source reads zero or equals the bar's close, the shell falls back to its internal stop model (ATR × multiplier or percentage). This means any indicator, from a simple moving-average crossover to a complex volatility regime detector, can plug in and immediately inherit disciplined risk management.

[b]TP[/b] is also optional. If provided, the shell places a limit exit at that price alongside the stop. If not, the position lives until a [b]+2[/b] or [b]-2[/b] signal closes it.

To connect: apply your signal indicator to the chart first, then apply the shell to the same chart. In the shell's settings, map each [pine]input.source()[/pine] to the corresponding plot from your indicator. That is the entire integration. No code changes to your indicator beyond adding the three plot lines above.


[b]Risk Engine[/b]

Position sizing is not a percentage of equity and not a fixed lot. It is derived from the actual risk per trade, defined as the monetary distance from entry to stop expressed in account currency.

The engine computes tick value as [pine]tickSize × pointValue[/pine], converts to account currency through [pine]request.currency_rate()[/pine], then calculates the cost of the stop being hit: [pine]stopTicks × tickValue × ccyRate[/pine]. To this it adds a friction estimate (spread + entry slippage + exit slippage, all in ticks) and the round-trip commission cost. The budget available for the trade is [pine]capital × riskPercent / 100[/pine]. Raw quantity is [pine]budget / totalCostPerUnit[/pine], floored to the instrument's minimum contract step and capped by the margin constraint [pine]capital / (notionalPerUnit × marginPercent)[/pine]. The final quantity is the smaller of the risk-sized and margin-capped values.

The commission model supports three modes. [b]Per Order[/b] subtracts a fixed dollar amount per order from the risk budget before dividing by the per-unit cost — this is the simplest to configure and is the default. [b]Per Contract[/b] scales linearly with quantity. [b]Percent[/b] scales with notional value. In all three cases, the engine accounts for the full round-trip cost before committing capital.

The strategy declaration at the top of the script uses compile-time constants for [pine]initial_capital[/pine], [pine]commission_type[/pine], [pine]commission_value[/pine], [pine]slippage[/pine], and [pine]margin_long/short[/pine]. These are the values TradingView's broker emulator actually uses during the backtest. The input panel exposes the same parameters for the dashboard and sizing engine. If the two diverge, a red [b]DECL MISMATCH[/b] warning appears at the bottom of the table — edit the constants in the source (marked with ✏️) to match your inputs.


[b]Trade Tracking[/b]

Once a position is filled, the shell begins monitoring it through lower-timeframe intrabar data via [pine]request.security_lower_tf()[/pine]. For each open trade it checks, bar by bar, whether the price path has reached -1R, +1R, +2R, +3R, or +5R from the entry, using the stop distance frozen at signal time as the unit of R. It records whether each level was touched and how many minutes it took to get there.

Trade close detection uses [pine]strategy.closedtrades[/pine] as an event counter, not [pine]strategy.position_size == 0[/pine]. This is critical for robustness: when the strategy reverses from long to short in a single bar, [pine]position_size[/pine] never passes through zero, but [pine]closedtrades[/pine] still increments. The entry price for R-multiple calculation comes from [pine]strategy.position_avg_price[/pine] — the real fill, not the close of the signal bar.

The stop distance follows a three-stage chain. At signal time, stop and distance are frozen into pending variables. At fill time, when the position actually exists, they transfer into active tracking variables. At trade close, when [pine]closedtrades[/pine] increments, the active stop distance is pushed into a closed-trade array that stays perfectly aligned with TradingView's internal trade index. This eliminates the fragile parallel-array problem that plagues most custom trade trackers.


[b]Analytics Dashboard[/b]

The dashboard is a single unified table rendered on the last bar. It has three main blocks.

[b]Left panel[/b] shows live strategy metrics computed from all closed trades: Profit Factor, Win Rate, Expectancy in account currency, average R-multiple at exit, average Win R and Loss R with trade counts, maximum drawdown, annualised Sortino ratio and Calmar ratio, and average trade duration. These are not approximations — they iterate over every [pine]strategy.closedtrades.profit(i)[/pine], [pine]entry_price(i)[/pine], [pine]exit_price(i)[/pine], and [pine]entry_time(i)/exit_time(i)[/pine] on the final bar.

[b]Right panel, upper block — R Distribution.[/b] Every closed trade is binned by its R-multiple at exit into eight buckets: below -1R, -1R to -0.5R, -0.5R to zero, zero to +0.5R, +0.5R to +1R, +1R to +2R, +2R to +3R, and above +3R. Each row shows the count of trades in that bin, the average P&L, the average duration, and the win percentage. The background colour shifts from red to green with the bin's average R. This is the distribution that tells you whether your strategy is a small-loss / big-win machine or something else entirely.

[b]Right panel, lower block — Time Distribution.[/b] The same closed trades are binned by duration into six buckets: under 6 hours, 6–24 hours, 1–3 days, 3–7 days, 1–4 weeks, and over 4 weeks. Each row shows count, average R, average P&L, and win rate. This reveals the time structure of your edge. A well-functioning trend-following signal will show negative average R in the short buckets (quick stops) and strongly positive R in the long buckets (runners). If the pattern is flat or inverted, the signal has no time edge.

Below the distributions, a [b]Trade R-Level HIT%[/b] row shows what fraction of completed trades touched each R-level during their lifetime, with the average time to reach it. This is a different question from exit R: a trade can touch +3R intrabar and then close at +1.5R. The HIT% row captures the maximum favourable excursion in R-space, which is useful for evaluating whether wider take-profit targets are viable.

A [b]Multi-Risk Sizing[/b] table at the bottom shows what the position size, notional, margin, and risk dollar would be at seven different risk percentages from 0.25% to 10%, so you can instantly see the scaling profile of your current instrument without changing any input.



[b]Setup checklist[/b]

[list=1]
[*]Add three [pine]plot()[/pine] lines to your indicator (Signal, Stop (optional), TP(optional)) following the protocol above.
[*]Apply your indicator to the chart.
[*]Apply this strategy shell to the same chart.
[*]In the shell's settings, map the three [pine]input.source()[/pine] fields to the corresponding plots from your indicator.
[*]Set Account Capital, Leverage, Commission Type and Value to match your broker. Then edit the ✏️ constants at the top of the script to the same values — these are compile-time and cannot follow input changes.
[*]Verify no [b]DECL MISMATCH[/b] warning appears in the table.
[*]Run the backtest. Read the R and Time distributions. Decide whether your signal has edge.
[/list]

The strategy declaration uses [pine]process_orders_on_close=false[/pine] and [pine]use_bar_magnifier=true[/pine] by default. Orders fill on the next bar's open, which is realistic for market orders. Bar magnifier uses lower-timeframe data to improve fill simulation on higher timeframes. Both settings can be changed in the source if your workflow requires it.


The very simple tested strategy is the following:

[pine]
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Oberlunar ★
//@version=6
indicator("EMA Trend Signal ★ Oberlunar", overlay=true)

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
i_emaFast   = input.int(19,   "EMA Fast",        minval=2, group="EMA")
i_emaMid    = input.int(49,   "EMA Mid",         minval=2, group="EMA")
i_emaSlow   = input.int(154,  "EMA Slow",        minval=2, group="EMA")
i_slopeBars = input.int(5,    "Slope Lookback",   minval=1, maxval=50, group="EMA", tooltip="Bars to measure EMA slope.\nPositive = ema now > ema N bars ago.")
i_atrMult   = input.float(1.5,"Stop ATR Mult",    minval=0.1, step=0.1, group="Stop & TP")
i_rrRatio   = input.float(2.0,"R:R Ratio for TP", minval=0.5, step=0.5, group="Stop & TP", tooltip="0 = no TP, exit by signal only.")
i_showEMA   = input.bool(true,"Show EMAs",        group="Visual")

// ═══════════════════════════════════════════════════════════════════════════════
// EMAs + SLOPE
// ═══════════════════════════════════════════════════════════════════════════════
float ema21  = ta.ema(close, i_emaFast)
float ema50  = ta.ema(close, i_emaMid)
float ema200 = ta.ema(close, i_emaSlow)
float atr    = ta.atr(14)

// Slope: positive if EMA21 is rising over N bars
float slope21 = ema21 - ema21[i_slopeBars]
bool  slopeUp = slope21 > 0
bool  slopeDn = slope21 < 0

// ═══════════════════════════════════════════════════════════════════════════════
// ENTRY CONDITIONS
// ═══════════════════════════════════════════════════════════════════════════════

// ── LONG ─────────────────────────────────────────────────────────────────────
// Price crosses above EMA21
// EMA50 and EMA200 are BELOW (bullish alignment: 21 > 50 > 200 under price)
// Slope is positive
bool bullishAlignment = ema50 < ema21 and ema200 < ema50
bool priceCrossUp     = ta.crossover(close, ema21)
bool longEntry        = priceCrossUp and bullishAlignment and slopeUp

// ── SHORT ────────────────────────────────────────────────────────────────────
// EMA21 below EMA50 AND below EMA200 (bearish alignment)
// Slope is negative
// Trigger: price crosses below EMA21
bool bearishAlignment = ema21 < ema50 and ema21 < ema200
bool priceCrossDn     = ta.crossunder(close, ema21)
bool shortEntry       = priceCrossDn and bearishAlignment and slopeDn

// ── EXITS ────────────────────────────────────────────────────────────────────
// Long exit: bullish alignment breaks (EMA21 crosses below EMA50)
bool exitLong  = ta.crossunder(ema21, ema50)
// Short exit: bearish alignment breaks (EMA21 crosses above EMA50)
bool exitShort = ta.crossover(ema21, ema50)

// ═══════════════════════════════════════════════════════════════════════════════
// STOP & TP CALCULATION
// ═══════════════════════════════════════════════════════════════════════════════
float longStop  = longEntry  ? math.min(low, ema50) - atr * i_atrMult : 0.0
float shortStop = shortEntry ? math.max(high, ema50) + atr * i_atrMult : 0.0

float longRisk  = longEntry  ? close - longStop : 0.0
float shortRisk = shortEntry ? shortStop - close : 0.0

float longTP  = longEntry  and i_rrRatio > 0 ? close + longRisk * i_rrRatio  : 0.0
float shortTP = shortEntry and i_rrRatio > 0 ? close - shortRisk * i_rrRatio : 0.0

// ═══════════════════════════════════════════════════════════════════════════════
// SIGNAL PROTOCOL — Output for Leverage Strategy Shell
// ═══════════════════════════════════════════════════════════════════════════════
// +1 = Long entry    -1 = Short entry
// +2 = Close long    -2 = Close short
//  0 = No signal

float signal = longEntry ? 1 : shortEntry ? -1 : exitLong ? 2 : exitShort ? -2 : 0
float stopPx = longEntry ? longStop : shortEntry ? shortStop : 0
float tpPx   = longEntry ? longTP : shortEntry ? shortTP : 0

// Plots: connect these to Strategy Shell's input.source()
plot(signal, "Signal", color=color.new(color.yellow, 100), display=display.none)
plot(stopPx, "Stop",   color=color.new(color.red, 100),    display=display.none)
plot(tpPx,   "TP",     color=color.new(color.green, 100),  display=display.none)

// ═══════════════════════════════════════════════════════════════════════════════
// VISUAL — EMAs + Entry markers + Stop/TP levels
// ═══════════════════════════════════════════════════════════════════════════════
plot(i_showEMA ? ema21  : na, "EMA 21",  color=color.new(#FFD700, 0), linewidth=2)
plot(i_showEMA ? ema50  : na, "EMA 50",  color=color.new(#5b7dff, 0), linewidth=1)
plot(i_showEMA ? ema200 : na, "EMA 200", color=color.new(#c792ea, 0), linewidth=1)

// Entry arrows
plotshape(longEntry,  "Long",  shape.triangleup,   location.belowbar, color.new(#22d47a, 0), size=size.small)
plotshape(shortEntry, "Short", shape.triangledown,  location.abovebar, color.new(#f05050, 0), size=size.small)

// Exit crosses
plotshape(exitLong,  "Exit L", shape.xcross, location.abovebar, color.new(#22d47a, 60), size=size.tiny)
plotshape(exitShort, "Exit S", shape.xcross, location.belowbar, color.new(#f05050, 60), size=size.tiny)

// Stop & TP lines on signal bars
plot(longEntry ? longStop : na,   "L Stop", color=color.new(#f05050, 0), style=plot.style_circles, linewidth=3)
plot(longEntry ? longTP : na,     "L TP",   color=color.new(#22d47a, 0), style=plot.style_circles, linewidth=3)
plot(shortEntry ? shortStop : na, "S Stop", color=color.new(#f05050, 0), style=plot.style_circles, linewidth=3)
plot(shortEntry ? shortTP : na,   "S TP",   color=color.new(#22d47a, 0), style=plot.style_circles, linewidth=3)

// ═══════════════════════════════════════════════════════════════════════════════
// INFO LABEL — slope + alignment status
// ═══════════════════════════════════════════════════════════════════════════════
var label infoLbl = na
if barstate.islast
    string status = bullishAlignment ? "BULL ▲" : bearishAlignment ? "BEAR ▼" : "NEUTRAL —"
    string slopeTxt = "Slope 21: " + (slopeUp ? "+" : "") + str.tostring(slope21, "#.##")
    string txt = "EMA Signal ★\n" + status + "\n" + slopeTxt
    color  bg  = bullishAlignment ? color.new(#22d47a, 80) : bearishAlignment ? color.new(#f05050, 80) : color.new(#888888, 80)
    if not na(infoLbl)
        label.delete(infoLbl)
    infoLbl := label.new(bar_index, high, txt, style=label.style_label_down, color=bg, textcolor=color.white, size=size.small)


[/pine]



[b]Credits[/b]

Concept, architecture, and code: Oberlunar.
Built in Pine Script™ v6.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Oberlunar ★
//@version=6

// ═══════════════════════════════════════════════════════════════════════════════
// STRATEGY DECLARATION — ✏️ EDIT these const values to match your broker.
// ═══════════════════════════════════════════════════════════════════════════════
strategy("Leverage Strategy Shell ★ Oberlunar",
     overlay=true, initial_capital=10000, currency=currency.USD,
     commission_type=strategy.commission.cash_per_order, commission_value=5,
     slippage=2, margin_long=1, margin_short=1,
     default_qty_type=strategy.fixed, default_qty_value=1,
     calc_on_order_fills=false, process_orders_on_close=false,
     use_bar_magnifier=true, max_bars_back=5000)

DECL_CAP=10000, DECL_CV=5.0, DECL_SL=2, DECL_MG=1.0

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
i_signal   = input.source(close,"Signal Source",group="🔌 Signal",tooltip="+1=L -1=S +2=XL -2=XS 0=none")
i_extStop  = input.source(close,"Stop Source (0=internal)",group="🔌 Signal")
i_extTP    = input.source(close,"TP Source (0=none)",group="🔌 Signal")
i_cooldown = input.int(1,"Cooldown (bars)",minval=0,maxval=50,group="🔌 Signal")
i_capital  = input.float(10000.0,"Account Capital",minval=100,step=500,group="💰 Account")
i_riskPct  = input.float(1.0,"Risk % per Trade",minval=0.01,step=0.25,group="💰 Account")
i_acctCcy  = input.string("USD","Account Currency",options=["USD","EUR","GBP","JPY","CHF","AUD","CAD","NZD"],group="💱 Currency")
i_symCcy   = input.string("USD","Symbol P&L Currency",options=["USD","EUR","GBP","JPY","CHF","AUD","CAD","NZD"],group="💱 Currency")
i_commType = input.string("Per Order","Commission Type",options=["Per Contract","Per Order","Percent"],group="⚙️ Params")
i_commVal  = input.float(5.0,"Commission Value",minval=0,step=0.5,group="⚙️ Params")
i_slip     = input.int(2,"Slippage (ticks)",minval=0,group="⚙️ Params")
i_leverage = input.int(100,"Leverage 1:___",minval=1,maxval=2000,group="⚙️ Params")
i_stdLot   = input.float(0.0,"Std Lot Size (0=auto)",minval=0,group="⚙️ Params")
i_orderCnt = input.int(2,"Expected RT Orders",minval=2,maxval=20,group="⚙️ Params")
i_stopMode = input.string("ATR x","Internal Stop Model",options=["ATR x","% Stop"],group="🎯 Stop")
i_atrMult  = input.float(1.5,"ATR Mult",minval=0.1,step=0.1,group="🎯 Stop")
i_stopPct  = input.float(1.0,"% Stop",minval=0.01,step=0.25,group="🎯 Stop")
i_showMR   = input.bool(true,"Show Multi-Risk",group="📋 Display")
i_showPS   = input.bool(false,"Show Path Sampler (baseline)",group="📋 Display")
i_tblPos   = input.string("Bottom Left","Table Position",options=["Top Left","Top Right","Bottom Left","Bottom Right","Middle Left","Middle Right"],group="📋 Display")
i_txtSz    = input.string("small","Text Size",options=["tiny","small","normal"],group="📋 Display")
i_ltf      = input.string("5","Sampler LTF (min)",options=["1","5","15"],group="⏱️ Sampler")
i_simSp    = input.int(25,"Probe Spacing",minval=5,maxval=200,group="⏱️ Sampler")

bool wMismatch = i_capital!=DECL_CAP or i_commVal!=DECL_CV or i_slip!=DECL_SL or math.abs(100.0/i_leverage-DECL_MG)>0.001 or i_acctCcy!="USD" or i_commType!="Per Order"

// ═══════════════════════════════════════════════════════════════════════════════
// CONSTANTS + VAR DECLARATIONS — All here before any logic to prevent
// "Cannot call array methods when id of array is na" on bar 0.
// ═══════════════════════════════════════════════════════════════════════════════
int SR = 5
int SM = 4
int MP = 50
int NRB = 8
int NTB = 6

var float pendingStop = na
var float pendingSD = na
var float activeSD = na
var array<float> closedSDs = array.new_float(0)
var float[] sRT = array.from(-1.0, 1.0, 2.0, 3.0, 5.0)
var string[] sRL = array.from("-1R", "+1R", "+2R", "+3R", "+5R")
var bool stOpen = false
var float stEntry = na
var float stStop = na
var bool stLng = true
var int stTime = 0
var int stBar = 0
var array<bool> stRHit = array.new_bool(SR, false)
var array<float> stRTime = array.new_float(SR, na)
var array<int> stHitCnt = array.new_int(SR, 0)
var array<float> stTimSum = array.new_float(SR, 0.0)
var int stDone = 0
var int prevClosedCnt = 0
var float[] sMults = array.from(0.5, 1.0, 1.5, 2.5)
var string[] sMuLbl = array.from("0.5x", "1.0x", "1.5x", "2.5x")
var array<float> tSum = array.new_float(20, 0.0)
var array<int> tCnt = array.new_int(20, 0)
var array<int> tDone = array.new_int(SM, 0)
var array<int> tHit = array.new_int(20, 0)
var array<float> spE = array.new_float(MP, na)
var array<int> spT = array.new_int(MP, 0)
var array<int> spB = array.new_int(MP, 0)
var array<int> spM = array.new_int(MP, -1)
var array<float> spA = array.new_float(MP, na)
var array<bool> spL = array.new_bool(MP, true)
var array<bool> spAc = array.new_bool(MP, false)
var array<bool> spHF = array.new_bool(MP * SR, false)
var int spNx = 0
var int spTot = 0
var float aPF = na
var float aWR = na
var float aExp = na
var float aAvgR = na
var float aWinR = na
var float aLossR = na
var float aMaxDD = na
var float aSortino = na
var float aCalmar = na
var float aAvgMin = na
var int aTrades = 0
var int aWins = 0
var float[] rEdge = array.from(-999.0, -1.0, -0.5, 0.0, 0.5, 1.0, 2.0, 3.0, 999.0)
var string[] rLbl = array.from("<-1R", "-1R..-½", "-½R..0", "0..+½R", "+½R..+1R", "+1R..+2R", "+2R..+3R", ">+3R")
var array<int> rdN = array.new_int(NRB, 0)
var array<float> rdPnl = array.new_float(NRB, 0.0)
var array<float> rdDur = array.new_float(NRB, 0.0)
var array<float> rdR = array.new_float(NRB, 0.0)
var array<int> rdW = array.new_int(NRB, 0)
var float[] tEdge = array.from(0.0, 360.0, 1440.0, 4320.0, 10080.0, 40320.0, 999999.0)
var string[] tLbl = array.from("<6h", "6-24h", "1-3d", "3-7d", "1-4w", ">4w")
var array<int> tdN = array.new_int(NTB, 0)
var array<float> tdPnl = array.new_float(NTB, 0.0)
var array<float> tdR = array.new_float(NTB, 0.0)
var array<int> tdW = array.new_int(NTB, 0)

// ═══════════════════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════════════════
f_stdLotFB(string tk) =>
    string u = str.upper(tk)
    float l = 1.0
    if str.contains(u, "XAUUSD") or str.contains(u, "GOLD")
        l := 100.0
    else if str.contains(u, "XAGUSD")
        l := 5000.0
    else if str.contains(u, "OIL") or str.contains(u, "BRENT")
        l := 1000.0
    else
        bool fx = (str.contains(u, "USD") or str.contains(u, "EUR") or str.contains(u, "GBP") or str.contains(u, "JPY") or str.contains(u, "CHF")) and not str.contains(u, "BTC") and not str.contains(u, "ETH")
        if fx and str.length(u) <= 7
            l := 100000.0
    l

f_fs(float x, float s) => s > 0 ? math.floor(x / s) * s : x
f_f(float v) => math.abs(v) >= 1e6 ? str.tostring(v / 1e6, "#.##") + "M" : math.abs(v) >= 1e4 ? str.tostring(v / 1e3, "#.#") + "K" : math.abs(v) >= 1 ? str.tostring(v, "#.##") : math.abs(v) >= 0.001 ? str.tostring(v, "#.####") : str.tostring(v, "#.######")

// ═══════════════════════════════════════════════════════════════════════════════
// SYMBOL CONTEXT
// ═══════════════════════════════════════════════════════════════════════════════
float atrD = request.security(syminfo.tickerid, "D", ta.atr(14))
float atr = nz(atrD, close * 0.01)
float tickSz = syminfo.mintick
float qtyStp = syminfo.mincontract
float ptVal = syminfo.pointvalue
float stdLot = i_stdLot > 0 ? i_stdLot : f_stdLotFB(syminfo.ticker)
float ccyRate = i_acctCcy == i_symCcy ? 1.0 : request.currency_rate(i_symCcy, i_acctCcy, true)
float ccyR = nz(ccyRate, 1.0)
float marginPct = 100.0 / i_leverage
float tickVal = tickSz * ptVal

// ═══════════════════════════════════════════════════════════════════════════════
// SIGNAL PARSER
// ═══════════════════════════════════════════════════════════════════════════════
int sig = int(math.round(i_signal))
var int lastSigBar = -999999
bool cooled = bar_index - lastSigBar >= i_cooldown
bool goLong = sig == 1 and sig[1] != 1 and cooled and strategy.position_size <= 0
bool goShort = sig == -1 and sig[1] != -1 and cooled and strategy.position_size >= 0
bool exitL = sig == 2 and strategy.position_size > 0
bool exitS = sig == -2 and strategy.position_size < 0
if goLong or goShort
    lastSigBar := bar_index

// ═══════════════════════════════════════════════════════════════════════════════
// STOP & SIZING
// ═══════════════════════════════════════════════════════════════════════════════
bool isLong = goLong or (strategy.position_size > 0 and not goShort)
float dir = isLong ? -1.0 : 1.0
bool extStopOK = not na(i_extStop) and i_extStop != close and i_extStop > 0
float intStop = switch i_stopMode
    "ATR x" => close + dir * atr * i_atrMult
    "% Stop" => close * (1.0 + dir * i_stopPct / 100.0)
    => close + dir * atr * 1.5
float tradeStop = extStopOK ? i_extStop : intStop
float stopDist = math.abs(close - tradeStop)
float stopTk = tickSz > 0 ? stopDist / tickSz : 0.0
float moveCost = stopTk * tickVal * ccyR
float fricCost = (i_slip * 2) * tickVal * ccyR
bool isPerOrd = i_commType == "Per Order"
bool isPct = i_commType == "Percent"
float commPerQtyRT = isPct ? i_commVal / 100.0 * close * ptVal * ccyR * 2.0 : isPerOrd ? 0.0 : i_commVal * 2.0
float commPerOrd = isPerOrd ? i_commVal : 0.0
float orderMult = isPerOrd ? float(i_orderCnt) : 0.0
float commRT = commPerQtyRT
float budget = i_capital * i_riskPct / 100.0
float qtyRaw = 0.0
if isPerOrd
    float bn = budget - orderMult * commPerOrd
    float d = moveCost + fricCost
    qtyRaw := d > 0 and bn > 0 ? bn / d : 0.0
else
    float d = moveCost + fricCost + commPerQtyRT
    qtyRaw := d > 0 ? budget / d : 0.0
float qtyRisk = f_fs(qtyRaw, qtyStp)
float notPerQ = close * ptVal * ccyR
float qtyMarg = notPerQ > 0 and marginPct > 0 ? f_fs(i_capital / (notPerQ * marginPct / 100.0), qtyStp) : 0.0
float qtyFinal = math.max(0.0, math.min(qtyRisk, qtyMarg))
float lotEq = stdLot > 0 ? qtyFinal / stdLot : 0.0

// ═══════════════════════════════════════════════════════════════════════════════
// ORDER EXECUTOR — freeze stop at signal time
// ═══════════════════════════════════════════════════════════════════════════════
bool extTPOK = not na(i_extTP) and i_extTP != close and i_extTP > 0
float tradeTP = extTPOK ? i_extTP : na
if goLong and qtyFinal > 0
    pendingStop := tradeStop
    pendingSD := stopDist
    strategy.entry("L", strategy.long, qty = qtyFinal)
    strategy.exit("XL", "L", stop = tradeStop, limit = tradeTP)
if goShort and qtyFinal > 0
    pendingStop := tradeStop
    pendingSD := stopDist
    strategy.entry("S", strategy.short, qty = qtyFinal)
    strategy.exit("XS", "S", stop = tradeStop, limit = tradeTP)
if exitL
    strategy.close("L")
if exitS
    strategy.close("S")

// ═══════════════════════════════════════════════════════════════════════════════
// STRATEGY TRADE TRACKER
// ═══════════════════════════════════════════════════════════════════════════════
[ltfHi, ltfLo, ltfTm] = request.security_lower_tf(syminfo.tickerid, i_ltf, [high, low, time], ignore_invalid_timeframe = true)
int lSz = array.size(ltfHi)
bool wBadLTF = lSz == 0 and i_showPS

// Close detection via closedtrades count (robust to reversals)
bool newClosed = strategy.closedtrades > prevClosedCnt
if newClosed and stOpen
    stDone += 1
    if not na(activeSD)
        array.push(closedSDs, activeSD)
    for ri = 0 to SR - 1
        if array.get(stRHit, ri)
            array.set(stHitCnt, ri, array.get(stHitCnt, ri) + 1)
            float t = array.get(stRTime, ri)
            if not na(t)
                array.set(stTimSum, ri, array.get(stTimSum, ri) + t)
    stOpen := false
if newClosed
    prevClosedCnt := strategy.closedtrades

// Open detection via real fill — consume pending stop
bool justLong = strategy.position_size > 0 and strategy.position_size[1] <= 0
bool justShort = strategy.position_size < 0 and strategy.position_size[1] >= 0
if justLong or justShort
    stOpen := true
    stEntry := strategy.position_avg_price
    stStop := pendingStop
    activeSD := pendingSD
    stLng := justLong
    stTime := time
    stBar := bar_index
    for ri = 0 to SR - 1
        array.set(stRHit, ri, false)
        array.set(stRTime, ri, na)

// LTF monitoring
if stOpen and strategy.position_size != 0 and lSz > 0 and bar_index > stBar
    float sDist = math.abs(stEntry - stStop)
    if sDist > 0
        for li = 0 to lSz - 1
            float lH = array.get(ltfHi, li)
            float lL = array.get(ltfLo, li)
            int tm = array.get(ltfTm, li)
            float el = (tm - stTime) / 60000.0
            if el < 0
                continue
            for ri = 0 to SR - 1
                if array.get(stRHit, ri)
                    continue
                float rv = array.get(sRT, ri)
                bool hit = false
                if rv < 0
                    float tp = stLng ? stEntry - math.abs(rv) * sDist : stEntry + math.abs(rv) * sDist
                    hit := stLng ? lL <= tp : lH >= tp
                else
                    float tp = stLng ? stEntry + rv * sDist : stEntry - rv * sDist
                    hit := stLng ? lH >= tp : lL <= tp
                if hit
                    array.set(stRHit, ri, true)
                    array.set(stRTime, ri, math.max(0.0, el))

// ═══════════════════════════════════════════════════════════════════════════════
// PATH SAMPLER (optional baseline)
// ═══════════════════════════════════════════════════════════════════════════════
if bar_index > 50 and bar_index % i_simSp == 0 and i_showPS
    bool sLng = bar_index % (i_simSp * 2) < i_simSp
    for mi = 0 to SM - 1
        int ix = spNx % MP
        array.set(spE, ix, close)
        array.set(spT, ix, time_close)
        array.set(spB, ix, bar_index)
        array.set(spA, ix, atr)
        array.set(spM, ix, mi)
        array.set(spL, ix, sLng)
        array.set(spAc, ix, true)
        for ri = 0 to SR - 1
            array.set(spHF, ix * SR + ri, false)
        spNx += 1
        spTot += 1

if lSz > 0 and i_showPS
    for pi = 0 to MP - 1
        if not array.get(spAc, pi)
            continue
        if bar_index <= array.get(spB, pi)
            continue
        float eP = array.get(spE, pi)
        float eA = array.get(spA, pi)
        int mi = array.get(spM, pi)
        bool isL = array.get(spL, pi)
        float dist = eA * array.get(sMults, mi)
        bool dead = false
        for li = 0 to lSz - 1
            if dead
                break
            float lH = array.get(ltfHi, li)
            float lL = array.get(ltfLo, li)
            int tm = array.get(ltfTm, li)
            float el = (tm - array.get(spT, pi)) / 60000.0
            if el < 0
                continue
            for ri = 0 to SR - 1
                if array.get(spHF, pi * SR + ri)
                    continue
                float rv = array.get(sRT, ri)
                bool hit = false
                if rv < 0
                    float tp = isL ? eP - math.abs(rv) * dist : eP + math.abs(rv) * dist
                    hit := isL ? lL <= tp : lH >= tp
                    if hit
                        dead := true
                else
                    float tp = isL ? eP + rv * dist : eP - rv * dist
                    hit := isL ? lH >= tp : lL <= tp
                if hit
                    array.set(spHF, pi * SR + ri, true)
                    int ci = mi * SR + ri
                    array.set(tSum, ci, array.get(tSum, ci) + math.max(0.0, el))
                    array.set(tCnt, ci, array.get(tCnt, ci) + 1)
                if dead
                    break
        if dead
            array.set(spAc, pi, false)
            int dmi = array.get(spM, pi)
            array.set(tDone, dmi, array.get(tDone, dmi) + 1)
            for ri = 0 to SR - 1
                if array.get(spHF, pi * SR + ri)
                    int ci = dmi * SR + ri
                    array.set(tHit, ci, array.get(tHit, ci) + 1)
        if not dead and (time - array.get(spT, pi)) > 2592000000
            array.set(spAc, pi, false)
            int dmi = array.get(spM, pi)
            array.set(tDone, dmi, array.get(tDone, dmi) + 1)
            for ri = 0 to SR - 1
                if array.get(spHF, pi * SR + ri)
                    int ci = dmi * SR + ri
                    array.set(tHit, ci, array.get(tHit, ci) + 1)

// ═══════════════════════════════════════════════════════════════════════════════
// ANALYTICS + DISTRIBUTIONS
// ═══════════════════════════════════════════════════════════════════════════════
if barstate.islast
    int n = strategy.closedtrades
    aTrades := n
    for b = 0 to NRB - 1
        array.set(rdN, b, 0)
        array.set(rdPnl, b, 0.0)
        array.set(rdDur, b, 0.0)
        array.set(rdR, b, 0.0)
        array.set(rdW, b, 0)
    for b = 0 to NTB - 1
        array.set(tdN, b, 0)
        array.set(tdPnl, b, 0.0)
        array.set(tdR, b, 0.0)
        array.set(tdW, b, 0)
    if n > 0
        float sumW = 0.0
        float sumL = 0.0
        float sumPnl = 0.0
        float sumR = 0.0
        float sumWinR = 0.0
        float sumLossR = 0.0
        float sumMin = 0.0
        float sumRet = 0.0
        float sumRetSq = 0.0
        int wins = 0
        int rCnt = 0
        int winRCnt = 0
        int lossRCnt = 0
        int negCnt = 0
        int sdSz = array.size(closedSDs)
        for i = 0 to n - 1
            float net = strategy.closedtrades.profit(i)  // already net of commission
            sumPnl += net
            if net > 0
                sumW += net
                wins += 1
            else
                sumL += math.abs(net)
            int tE = strategy.closedtrades.entry_time(i)
            int tX = strategy.closedtrades.exit_time(i)
            float durMin = (tX - tE) / 60000.0
            sumMin += durMin
            float ret = net / i_capital
            sumRet += ret
            if ret < 0
                sumRetSq += ret * ret
                negCnt += 1
            float ep = strategy.closedtrades.entry_price(i)
            float xp = strategy.closedtrades.exit_price(i)
            bool wL = strategy.closedtrades.size(i) > 0
            float sd = i < sdSz ? array.get(closedSDs, i) : atr * i_atrMult
            float rMult = sd > 0 ? (wL ? (xp - ep) / sd : (ep - xp) / sd) : 0.0
            sumR += rMult
            rCnt += 1
            if rMult > 0
                sumWinR += rMult
                winRCnt += 1
            else
                sumLossR += rMult
                lossRCnt += 1
            // Bin by R
            int rb = NRB - 1
            for b = 0 to NRB - 2
                if rMult < array.get(rEdge, b + 1)
                    rb := b
                    break
            array.set(rdN, rb, array.get(rdN, rb) + 1)
            array.set(rdPnl, rb, array.get(rdPnl, rb) + net)
            array.set(rdDur, rb, array.get(rdDur, rb) + durMin)
            array.set(rdR, rb, array.get(rdR, rb) + rMult)
            if net > 0
                array.set(rdW, rb, array.get(rdW, rb) + 1)
            // Bin by time
            int tb = NTB - 1
            for b = 0 to NTB - 2
                if durMin < array.get(tEdge, b + 1)
                    tb := b
                    break
            array.set(tdN, tb, array.get(tdN, tb) + 1)
            array.set(tdPnl, tb, array.get(tdPnl, tb) + net)
            array.set(tdR, tb, array.get(tdR, tb) + rMult)
            if net > 0
                array.set(tdW, tb, array.get(tdW, tb) + 1)
        aWins := wins
        aPF := sumL > 0 ? sumW / sumL : sumW > 0 ? 999.0 : 0.0
        aWR := n > 0 ? wins * 100.0 / n : 0.0
        aExp := n > 0 ? sumPnl / n : 0.0
        aAvgR := rCnt > 0 ? sumR / rCnt : 0.0
        aWinR := winRCnt > 0 ? sumWinR / winRCnt : na
        aLossR := lossRCnt > 0 ? sumLossR / lossRCnt : na
        aAvgMin := n > 0 ? sumMin / n : 0.0
        aMaxDD := strategy.max_drawdown
        float meanRet = sumRet / n
        float ddDev = negCnt > 1 ? math.sqrt(sumRetSq / negCnt) : na
        aSortino := not na(ddDev) and ddDev > 0 ? (meanRet / ddDev) * math.sqrt(252) : na
        float totalRet = strategy.netprofit / i_capital
        float years = bar_index > 0 ? bar_index * timeframe.in_seconds() / (365.25 * 86400) : 1.0
        float cagr = years > 0 ? math.pow(1 + totalRet, 1 / years) - 1 : 0.0
        aCalmar := aMaxDD > 0 ? cagr / (aMaxDD / i_capital) : na

// ═══════════════════════════════════════════════════════════════════════════════
// PALETTE + HELPERS
// ═══════════════════════════════════════════════════════════════════════════════
f_c(float v) => i_acctCcy + " " + f_f(v)
f_dur(float m) => m >= 1440 ? str.tostring(m / 1440, "#.#") + "d" : m >= 60 ? str.tostring(m / 60, "#.#") + "h" : str.tostring(math.round(m)) + "m"

color cT = #FFD700
color cH = #888aaa
color cW = color.white
color cG = #22d47a
color cR = #f05050
color cO = #ff6d00
color cC = #19c8c8
color cP = #c792ea
color bgD = color.new(#08081a, 10)
color bgH = color.new(#10102a, 10)
color bgW = color.new(#2a1a10, 10)

f_kv(table t, int row, int col, string lbl, string val, color vc, string sz) =>
    table.cell(t, col, row, lbl, text_color = cH, text_size = sz, bgcolor = bgD, text_halign = text.align_left)
    table.cell(t, col + 1, row, val, text_color = vc, text_size = sz, bgcolor = bgD, text_halign = text.align_left)

f_hdr(table t, int row, int c0, int c1, string title, color c, string sz) =>
    table.cell(t, c0, row, title, text_color = c, text_size = sz, text_halign = text.align_left, bgcolor = bgH)
    if c1 > c0
        table.merge_cells(t, c0, row, c1, row)

// ═══════════════════════════════════════════════════════════════════════════════
// TABLE — 14 cols unified
// ═══════════════════════════════════════════════════════════════════════════════
tblPos = switch i_tblPos
    "Top Left" => position.top_left
    "Top Right" => position.top_right
    "Bottom Right" => position.bottom_right
    "Middle Left" => position.middle_left
    "Middle Right" => position.middle_right
    => position.bottom_left
txtSz = switch i_txtSz
    "tiny" => size.tiny
    "normal" => size.normal
    => size.small

var table tb = table.new(tblPos, 14, 55, bgcolor = color.new(#08081a, 5), border_width = 1, border_color = color.new(#2a2a55, 60), frame_width = 2, frame_color = color.new(#4444aa, 40))

if barstate.islast
    table.clear(tb, 0, 0, 13, 54)
    int r = 0
    table.cell(tb, 0, r, "Leverage Strategy Shell ★ Oberlunar", text_color = cT, text_size = size.normal, text_halign = text.align_left, bgcolor = bgH)
    table.merge_cells(tb, 0, r, 13, r)
    r += 1
    table.cell(tb, 0, r, syminfo.tickerid + " · " + i_acctCcy + " " + f_f(i_capital) + " · 1:" + str.tostring(i_leverage) + " · Risk " + str.tostring(i_riskPct, "#.##") + "% · Trades: " + str.tostring(aTrades), text_color = cH, text_size = txtSz, text_halign = text.align_left, bgcolor = bgH)
    table.merge_cells(tb, 0, r, 13, r)
    r += 1

    // BLOCK 1: METRICS | R DISTRIBUTION
    f_hdr(tb, r, 0, 3, "LIVE METRICS", cG, txtSz)
    f_hdr(tb, r, 4, 7, "SIZING NOW", cT, txtSz)
    table.cell(tb, 8, r, "R DISTRIBUTION (actual trades)", text_color = cT, text_size = txtSz, text_halign = text.align_left, bgcolor = bgH)
    table.merge_cells(tb, 8, r, 13, r)
    r += 1
    string[] rdHdr = array.from("R BIN", "#", "AVG P&L", "AVG DUR", "WIN%", "")
    for c = 0 to 5
        table.cell(tb, 8 + c, r, array.get(rdHdr, c), text_color = cH, text_size = txtSz, bgcolor = bgH)
    f_kv(tb, r, 0, "Profit F.", not na(aPF) ? str.tostring(aPF, "#.##") : "—", aPF > 1.5 ? cG : aPF > 1 ? cW : cR, txtSz)
    f_kv(tb, r, 4, "Qty", f_f(qtyFinal) + " (" + str.tostring(lotEq, "#.###") + "L)", qtyFinal > 0 ? cG : cR, txtSz)
    r += 1

    string wrS = not na(aWR) ? str.tostring(aWR, "#.#") + "%" : "—"
    string expS = not na(aExp) ? f_c(aExp) : "—"
    string arS = not na(aAvgR) ? str.tostring(aAvgR, "#.##") + "R" : "—"
    string wrRS = not na(aWinR) ? "+" + str.tostring(aWinR, "#.##") + "R (" + str.tostring(aWins) + ")" : "—"
    string lrRS = not na(aLossR) ? str.tostring(aLossR, "#.##") + "R (" + str.tostring(aTrades - aWins) + ")" : "—"
    string ddS = not na(aMaxDD) ? f_c(aMaxDD) : "—"
    string soS = not na(aSortino) ? str.tostring(aSortino, "#.##") + (not na(aCalmar) ? " Cal:" + str.tostring(aCalmar, "#.##") : "") : "—"
    string duS = not na(aAvgMin) ? f_dur(aAvgMin) : "—"
    string[] mL = array.from("Win Rate", "Expectancy", "Avg R exit", "Win R", "Loss R", "MaxDD", "Sortino", "Avg Dur")
    string[] mV = array.from(wrS, expS, arS, wrRS, lrRS, ddS, soS, duS)
    color[] mC = array.from(aWR > 50 ? cG : cR, aExp > 0 ? cG : cR, aAvgR > 0 ? cG : cR, cG, cR, cR, aSortino > 1 ? cG : cW, cW)
    string commDisp = isPerOrd ? f_c(commPerOrd) + "x" + str.tostring(i_orderCnt) + " /ord" : isPct ? str.tostring(i_commVal, "#.##") + "%" : f_c(commRT) + "/q"
    string[] sL = array.from("Stop", "Dist", "MoveCost", "Friction", "Comm " + i_commType, commDisp, "Budget", "MrgCap")
    string[] sV = array.from(i_stopMode, f_f(stopDist) + "(" + str.tostring(math.round(stopTk)) + "tk)", f_c(moveCost) + "/q", f_c(fricCost), "Margin%", str.tostring(marginPct, "#.##") + "%", f_c(budget), f_f(qtyMarg))

    for i = 0 to 7
        f_kv(tb, r, 0, array.get(mL, i), array.get(mV, i), array.get(mC, i), txtSz)
        f_kv(tb, r, 4, array.get(sL, i), array.get(sV, i), cW, txtSz)
        if i < NRB
            int cnt = array.get(rdN, i)
            float avgPnl = cnt > 0 ? array.get(rdPnl, i) / cnt : na
            float avgDur = cnt > 0 ? array.get(rdDur, i) / cnt : na
            float wp = cnt > 0 ? array.get(rdW, i) * 100.0 / cnt : na
            float avgR = cnt > 0 ? array.get(rdR, i) / cnt : na
            color bg = bgD
            if cnt > 0
                float cl = math.max(-3.0, math.min(3.0, nz(avgR, 0)))
                bg := cl < 0 ? color.from_gradient(cl, -3.0, 0.0, color.new(#aa1111, 0), color.new(#0e0e20, 0)) : color.from_gradient(cl, 0.0, 3.0, color.new(#0e0e20, 0), color.new(#11aa11, 0))
            table.cell(tb, 8, r, array.get(rLbl, i), text_color = i < 3 ? cR : cG, text_size = txtSz, bgcolor = bg)
            table.cell(tb, 9, r, str.tostring(cnt), text_color = cnt > 0 ? cW : cH, text_size = txtSz, bgcolor = bg)
            table.cell(tb, 10, r, cnt > 0 ? f_c(avgPnl) : "—", text_color = cnt > 0 ? (avgPnl > 0 ? cG : cR) : cH, text_size = txtSz, bgcolor = bg)
            table.cell(tb, 11, r, cnt > 0 ? f_dur(avgDur) : "—", text_color = cnt > 0 ? cW : cH, text_size = txtSz, bgcolor = bg)
            table.cell(tb, 12, r, cnt > 0 ? str.tostring(math.round(wp)) + "%" : "—", text_color = cnt > 0 ? (wp > 50 ? cG : cR) : cH, text_size = txtSz, bgcolor = bg)
            table.cell(tb, 13, r, "", bgcolor = bg)
        r += 1

    // BLOCK 2: CONFIG | TIME DISTRIBUTION
    f_hdr(tb, r, 0, 7, "STRATEGY() CONFIG", cT, txtSz)
    table.cell(tb, 8, r, "TIME DISTRIBUTION (actual trades)", text_color = cP, text_size = txtSz, text_halign = text.align_left, bgcolor = bgH)
    table.merge_cells(tb, 8, r, 13, r)
    r += 1
    string[] tdHdr = array.from("DURATION", "#", "AVG R", "AVG P&L", "WIN%", "")
    for c = 0 to 5
        table.cell(tb, 8 + c, r, array.get(tdHdr, c), text_color = cH, text_size = txtSz, bgcolor = bgH)
    string ctDisp = isPerOrd ? "cash_per_order" : isPct ? "percent" : "cash_per_contract"
    string[] cL1 = array.from("initial_capital", "commission_type", "slippage", "default_qty_type", "calc_on_order_fills", "")
    string[] cV1 = array.from(str.tostring(i_capital, "#"), ctDisp, str.tostring(i_slip) + " (proxy)", "strategy.fixed", "false ★", "")
    string[] cL2 = array.from("currency", "commission_value", "margin_long/short", "entry qty (explicit)", "use_bar_magnifier", "")
    string[] cV2 = array.from(i_acctCcy, f_f(i_commVal), str.tostring(marginPct, "#.####"), f_f(qtyFinal), "true ★", "")
    for i = 0 to 5
        f_kv(tb, r, 0, array.get(cL1, i), array.get(cV1, i), i < 5 ? cT : cH, txtSz)
        f_kv(tb, r, 4, array.get(cL2, i), array.get(cV2, i), i < 5 ? cT : cH, txtSz)
        if i < NTB
            int cnt = array.get(tdN, i)
            float avgPnl = cnt > 0 ? array.get(tdPnl, i) / cnt : na
            float avgR = cnt > 0 ? array.get(tdR, i) / cnt : na
            float wp = cnt > 0 ? array.get(tdW, i) * 100.0 / cnt : na
            color bg = bgD
            if cnt > 0
                float cl = math.max(-2.0, math.min(2.0, nz(avgR, 0)))
                bg := cl < 0 ? color.from_gradient(cl, -2.0, 0.0, color.new(#aa1111, 0), color.new(#0e0e20, 0)) : color.from_gradient(cl, 0.0, 2.0, color.new(#0e0e20, 0), color.new(#11aa11, 0))
            table.cell(tb, 8, r, array.get(tLbl, i), text_color = cW, text_size = txtSz, bgcolor = bg)
            table.cell(tb, 9, r, str.tostring(cnt), text_color = cnt > 0 ? cW : cH, text_size = txtSz, bgcolor = bg)
            table.cell(tb, 10, r, cnt > 0 ? str.tostring(avgR, "#.##") + "R" : "—", text_color = cnt > 0 ? (avgR > 0 ? cG : cR) : cH, text_size = txtSz, bgcolor = bg)
            table.cell(tb, 11, r, cnt > 0 ? f_c(avgPnl) : "—", text_color = cnt > 0 ? (avgPnl > 0 ? cG : cR) : cH, text_size = txtSz, bgcolor = bg)
            table.cell(tb, 12, r, cnt > 0 ? str.tostring(math.round(wp)) + "%" : "—", text_color = cnt > 0 ? (wp > 50 ? cG : cR) : cH, text_size = txtSz, bgcolor = bg)
            table.cell(tb, 13, r, "", bgcolor = bg)
        r += 1

    // TRADE R-LEVEL HIT%
    if stDone >= 1 and r < 45
        f_hdr(tb, r, 0, 7, "TRADE R-LEVEL HIT% (n=" + str.tostring(stDone) + ")", cC, txtSz)
        table.cell(tb, 8, r, "", text_color = cH, text_size = txtSz, bgcolor = bgH)
        for c = 0 to SR - 1
            table.cell(tb, 9 + c, r, array.get(sRL, c), text_color = array.get(sRT, c) < 0 ? cR : cG, text_size = txtSz, bgcolor = bgH)
        r += 1
        f_kv(tb, r, 0, "", "", cH, txtSz)
        f_kv(tb, r, 4, "", "", cH, txtSz)
        table.cell(tb, 8, r, "STRAT", text_color = cT, text_size = txtSz, bgcolor = color.new(#1a1a40, 0))
        for ri = 0 to SR - 1
            float hp = stDone > 0 ? array.get(stHitCnt, ri) * 100.0 / stDone : na
            float at = array.get(stHitCnt, ri) > 0 ? array.get(stTimSum, ri) / array.get(stHitCnt, ri) : na
            string tv = na(at) ? "" : f_dur(at)
            string tx = na(hp) ? "—" : str.tostring(math.round(hp)) + "%" + (tv != "" ? "\n" + tv : "")
            color tc = na(hp) ? cH : ri == 0 ? (hp > 50 ? cR : cG) : (hp > 40 ? cG : hp > 20 ? cW : color.new(cW, 40))
            table.cell(tb, 9 + ri, r, tx, text_color = tc, text_size = txtSz, bgcolor = color.new(#1a1a40, 0))
        r += 1

    // WARNINGS
    if wMismatch and r < 48
        table.cell(tb, 0, r, "⚠ DECL MISMATCH: inputs ≠ strategy() constants. Edit ✏️ lines.", text_color = cR, text_size = txtSz, text_halign = text.align_left, bgcolor = bgW)
        table.merge_cells(tb, 0, r, 13, r)
        r += 1

    // MULTI-RISK
    if i_showMR and r < 42
        f_hdr(tb, r, 0, 13, "═ MULTI-RISK SIZING ═", cO, txtSz)
        r += 1
        string[] mrH = array.from("RISK%", "BUDGET", "QTY", "LOTS", "RISK$", "NOTIONAL", "MARGIN", "OK")
        for c = 0 to 7
            table.cell(tb, c, r, array.get(mrH, c), text_color = cH, text_size = txtSz, bgcolor = bgH)
        table.cell(tb, 8, r, "", bgcolor = bgH)
        table.merge_cells(tb, 8, r, 13, r)
        r += 1
        float[] pcts = array.from(0.25, 0.5, 1.0, 2.0, 3.0, 5.0, 10.0)
        for p = 0 to 6
            if r < 53
                float pct = array.get(pcts, p)
                float bud = i_capital * pct / 100.0
                float qR = 0.0
                if isPerOrd
                    float bn = bud - orderMult * commPerOrd
                    float d = moveCost + fricCost
                    qR := d > 0 and bn > 0 ? bn / d : 0.0
                else
                    float d = moveCost + fricCost + commPerQtyRT
                    qR := d > 0 ? bud / d : 0.0
                float qRs = f_fs(qR, qtyStp)
                float qMs = notPerQ > 0 and marginPct > 0 ? f_fs(i_capital / (notPerQ * marginPct / 100.0), qtyStp) : 0.0
                float qF = math.max(0.0, math.min(qRs, qMs))
                float rk = qF * (moveCost + fricCost) + (isPerOrd ? orderMult * commPerOrd : qF * commPerQtyRT)
                float lt = stdLot > 0 ? qF / stdLot : 0.0
                float nt = qF * close * ptVal * ccyR
                float mg = nt * marginPct / 100.0
                bool ok = qF > 0 and mg <= i_capital
                bool ac = math.abs(pct - i_riskPct) < 0.001
                color bg = ac ? color.new(#1a1a40, 0) : bgD
                color rc = ac ? cT : ok ? cW : cR
                table.cell(tb, 0, r, str.tostring(pct, "#.##") + (ac ? " ★" : ""), text_color = ac ? cT : cO, text_size = txtSz, bgcolor = bg)
                table.cell(tb, 1, r, f_c(bud), text_color = rc, text_size = txtSz, bgcolor = bg)
                table.cell(tb, 2, r, f_f(qF), text_color = ok ? rc : cR, text_size = txtSz, bgcolor = bg)
                table.cell(tb, 3, r, str.tostring(lt, "#.####"), text_color = cC, text_size = txtSz, bgcolor = bg)
                table.cell(tb, 4, r, f_c(rk), text_color = ok ? cG : cR, text_size = txtSz, bgcolor = bg)
                table.cell(tb, 5, r, f_c(nt), text_color = rc, text_size = txtSz, bgcolor = bg)
                table.cell(tb, 6, r, f_c(mg), text_color = ok ? cG : cR, text_size = txtSz, bgcolor = bg)
                table.cell(tb, 7, r, ok ? "✓" : "✗", text_color = ok ? cG : cR, text_size = txtSz, bgcolor = bg)
                table.cell(tb, 8, r, "", bgcolor = bg)
                table.merge_cells(tb, 8, r, 13, r)
                r += 1

    // FOOTER
    if r < 55
        table.cell(tb, 0, r, "Signal:+1L -1S +2XL -2XS · R dist from closedtrades · Time dist from entry/exit · HIT%=R touched during trade · pv=" + f_f(ptVal) + " | Oberlunar ★", text_color = color.new(cW, 65), text_size = txtSz, text_halign = text.align_left, bgcolor = bgD)
        table.merge_cells(tb, 0, r, 13, r)

plot(sig != sig[1] ? i_signal : na, "Signal Echo", color = color.new(cT, 80), display = display.pane)
````
