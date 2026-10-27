# CandleSignalADXEMA

- url: https://www.tradingview.com/script/mREvvoZt/
- type: indicator
- pine_id: PUB;b3f5f2c5293c41f7a904926c6840ed35
- version: 1.0

## Description

CandleSignalADXEMA — Description, How to Use, and Financial Disclaimer

⚡ INITIAL NOTE ON OPTIMAL SETTINGS
"Optimal historical performance is achieved when scalping the 5-minute timeframe with a Risk/Reward (R:R) ratio of 1.5."

However, these settings are not universal and depend heavily on the asset, market session, and volatility conditions. Experimentation is strongly encouraged with:

Different timeframes (5m, 15m, 30m, 1H)

Different R:R ratios

Stricter ADX thresholds (20–25) to better filter false signals

Session windows adapted to the market being traded

Always perform a thorough backtest on your asset and timeframe before trading with real money.

📌 DESCRIPTION
CandleSignalADXEMA is an advanced indicator for TradingView (Pine Script v6) designed to identify 3-candle reversal/continuation patterns based on liquidity sweeps and reclaims, filtered by trend (EMA/SMA), trend strength (ADX), session time, and Order Blocks.

The indicator is built for intraday trading — with its best historical performance on the 5-minute timeframe — but it can also be used on higher or lower timeframes, provided you experiment and adapt the parameters.

It combines several professional methodologies into a single visual tool:

Smart Money Concepts (SMC) → liquidity sweeps, reclaims, Order Blocks

Trend Following → EMA 9 / SMA 20 filter

Trend Strength → ADX filter (avoids signals in sideways markets)

Risk Management → automatic SL/TP with configurable R:R ratio (optimal default 1.5)

Visual Backtesting → monthly statistics panel with weekly win rate

🎯 What it does in short
Identifies a reference candle (C1) and marks its high and low.

Waits for a sweep candle (C2) that breaks one extreme of C1 but closes back inside the range → absorption signal.

Waits for the confirmation breakout (C3) beyond C1 → generates a BUY or SELL signal.

Draws SL, TP, and entry lines with realistic intrabar management (no lookahead bias).

Checks whether the signal occurred near a fresh Order Block → high-probability "springboard".

Logs every trade in a monthly statistics panel with weekly win rate.

🛠️ HOW TO USE IT
1️⃣ Installing on TradingView
Open TradingView → chart of an asset (e.g., EURUSD, ES, NQ, BTCUSDT).

At the bottom, open Pine Editor.

Paste the indicator code.

Click "Add to chart".

The indicator will appear on the main pane with lines, boxes, labels, and info panels.

2️⃣ Recommended timeframes
Timeframe	Recommended use
1m	Aggressive scalping (more noise, more false signals)
5m	✅ Historically optimal — best balance between frequency and reliability
15m	Standard intraday
30m	Intraday with less noise
1H	Intraday swing
4H – Daily	Swing trading (filters more significant, fewer signals)
💡 The indicator automatically uses a lower timeframe (1m or 5m) to resolve the intrabar order of TP/SL hits.

3️⃣ Initial configuration (key parameters)
🔹 C1 Lines
Show C1 high/low lines: displays the reference lines.

Confirmed setups to keep: how many past setups to keep on the chart (default 50).

🔹 Pattern Signals
Show BUY / SELL signals: enables/disables the stars.

Breakout buffer beyond C1 (ATR): breakout tolerance. 0 = exact touch; 0.02 = small buffer to avoid false breakouts.

🔹 Session Time Filter
Enable session time filter: enable if you want to trade only within a time window.

Session start / end (HHMM): e.g., 930 and 1730 for the US stock session.

🔹 Moving Average Trend Filter
Enable MA trend filter: enables the directional filter.

Use EMA 9 (ON) or SMA 20 (OFF).

Dynamic color: the MA changes color based on price position.

🔹 ADX Trend Strength Filter
Enable ADX filter: blocks signals in weak trends.

ADX minimum value: threshold (default 14). Raise it to 20–25 for more selective signals (recommended during experimentation).

🔹 Order Block
Enable OB detection: detects Order Blocks.

Require displacement: requires an impulsive candle (> ATR × multiplier).

Mitigation on close: OB is invalidated on a close beyond the box.

🔹 Trade Levels (SL/TP)
Take Profit ratio (R:R): default 1.5 → TP = 1.5 × risk. (Historically optimal setting on the 5m TF)

Stop Loss distance (ATR): minimum SL distance beyond C1.

Box extension to the right: how far to extend the boxes to the right (in bars).

🔹 Panels
Last Trade Panel: shows Entry / SL / TP of the last signal.

Monthly Stats Panel: weekly statistics (Long, Short, TP, SL, WR%, blocked).

4️⃣ Reading the chart
Visual element	Meaning
🟦 Gray line	C1 waiting for C2
🟪 Fuchsia line	Valid C2 → waiting for C3 breakout
⭐ Yellow star below bar	BUY signal confirmed
⭐ Red star above bar	SELL signal confirmed
🟩 Green box	Take Profit
🟥 Red box	Stop Loss
⚪ Dashed white line	Entry
🔷 Teal box	Bullish Order Block
🔶 Orange box	Bearish Order Block
🏷️ "OB" label	Touch of an important Order Block
✔️ / ✘	Trade outcome (TP or SL)
5️⃣ Recommended operating procedure
Step 1 — Check the context

Verify price is above the EMA 9 (for BUY) or below (for SELL).

Verify ADX ≥ threshold (trend present).

Verify you are inside the configured session.

Step 2 — Wait for the pattern

C1 appears (gray lines).

C2 appears → lines turn fuchsia = setup pending.

Step 3 — Entry on C3

When the star appears, the signal is confirmed.

If the "OB" label also appears, the signal is an Order Block springboard (higher reliability).

Step 4 — Trade management

Entry: break of C1 high (BUY) or C1 low (SELL).

SL: beyond the opposite extreme of C1 + ATR buffer.

TP: calculated on the configured R:R (default 1.5).

The trade remains locked until TP or SL.

Step 5 — Monitoring statistics

The bottom-left panel shows weekly win rate.

Useful to evaluate the real performance of the strategy on your asset/timeframe.

6️⃣ Recommended alerts
You can configure TradingView alerts on:

✅ Buy Confirmed → notification when the pattern is complete

✅ Sell Confirmed

✅ Buy + Order Block → high-probability signal

✅ Sell + Order Block

✅ Buy Setup Pending → early warning (C2 formed)

✅ Sell Setup Pending

⚠️ OB Touch alerts in the current version trigger on every bar: consider not using them or fixing the code.

7️⃣ Best practices
Start from the 5m TF with R:R 1.5 as the historically strongest baseline configuration.

Experiment: change timeframe, R:R, ADX threshold, and session until you find the best setup for your asset.

Do not trade against the trend: respect the MA filter.

Avoid sideways markets: raise the ADX threshold to 20–25.

Avoid high-impact news: disable the session filter only in controlled cases.

Backtest first: use TradingView's Bar Replay to validate the logic on your market.

Respect the R:R: do not manually modify SL/TP during the trade.

Combine with market analysis: the indicator is a tool, not a crystal ball.

⚠️ FINANCIAL DISCLAIMER
IMPORTANT NOTICE — READ CAREFULLY

This indicator (CandleSignalADXEMA) is provided for informational and educational purposes only. It does not constitute in any way:

Financial advice

Investment advice

Personalized trading recommendation

Solicitation to invest

Guaranteed trading signal

🚨 Trading risks
Trading financial instruments (forex, stocks, futures, cryptocurrencies, CFDs, options) involves high risk of capital loss, including the possibility of losing your entire invested capital and, with leveraged instruments, even more than your deposited capital.

Past performance is not indicative of future results.

No strategy, indicator, or system guarantees profits.

Most retail traders lose money.

📊 Indicator limitations
Generated signals are the result of algorithmic calculations based on historical prices and may not reflect real market conditions (slippage, spread, liquidity, commissions).

The statistics panel is an approximate visual backtest and does not account for transaction costs, spread, slippage, or broker execution differences.

Exchange sessions and time zones can affect results on different assets.

The indicator may repaint in real time on a forming bar if obRealtimeDraw is enabled.

Results optimized on one asset/timeframe do not automatically transfer to others. The "optimal" settings (5m TF, R:R 1.5) are indicative and do not guarantee similar performance under different market conditions.

🧠 User responsibility
The user is solely responsible for:

Any trading decision made using this indicator.

Fully understanding the logic of the C1-C2-C3 pattern and its filters.

Performing an adequate backtest and demo testing before trading with real money.

Evaluating their own risk tolerance and financial situation.

Consulting a licensed financial advisor before investing.

📜 No warranty
The author/provider of the indicator:

Provides no warranty, express or implied, regarding accuracy, reliability, completeness, or fitness for a specific purpose.

Is not liable for any direct, indirect, incidental, or consequential losses arising from the use of the indicator.

Does not provide personalized advice nor manage third-party capital.

🌍 Regulations
The use of this tool may be subject to local regulations. It is the user's responsibility to verify compliance with the laws of their country.

By using this indicator you declare that you have read, understood, and fully accepted this disclaimer and that you assume all risks arising from trading in financial markets.

## Source Code

````pine
//@version=6
indicator("CandleSignalADXEMA", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ============================================================
// INPUTS
// ============================================================
grpLines          = "C1 Lines"
showLines         = input.bool(true, "Show C1 high/low lines", group=grpLines)
maxHistory        = input.int(50, "Confirmed setups (successful C1-C2-C3) to keep on chart", minval=5, maxval=200, group=grpLines)
lineColor         = input.color(color.new(color.gray, 60), "Line color (C1, waiting for C2)", group=grpLines)
setupColor        = input.color(color.new(color.fuchsia, 0), "Line color (valid C2, waiting for C3)", group=grpLines)

grpSig            = "Pattern Signals"
showBuy           = input.bool(true,  "Show BUY signals", group=grpSig)
showSell          = input.bool(true,  "Show SELL signals (mirrored)", group=grpSig)
buyColor          = input.color(color.yellow, "Buy star color", group=grpSig)
sellColor         = input.color(color.red,    "Sell star color", group=grpSig)
closeToleranceATR = input.float(0.02, "Breakout buffer beyond C1 (in ATR, 0 = triggers at exact touch)", minval=0, step=0.01, group=grpSig)

grpSess           = "Session Time Filter"
useSession        = input.bool(true, "Enable session time filter", group=grpSess)
sessionStart      = input.int(930,  "Session start (HHMM, exchange time)", minval=0, maxval=2359, group=grpSess)
sessionEnd        = input.int(1730, "Session end   (HHMM, exchange time)", minval=0, maxval=2359, group=grpSess)

grpMA             = "Moving Average Trend Filter"
useMaFilter       = input.bool(true, "Enable MA trend filter (no signals against the chosen MA)", group=grpMA)
useEmaAsFilter    = input.bool(true, "Use EMA 9 as trend filter (if OFF, SMA 20 is used)", group=grpMA)

maLen             = input.int(20, "SMA period", minval=1, group=grpMA)
maSrc             = input.source(close, "SMA source", group=grpMA)
showMaPlot        = input.bool(true, "Show SMA on chart", group=grpMA)
maWidth           = input.int(2, "SMA line thickness", minval=1, maxval=10, group=grpMA)
maDynamicColor    = input.bool(true, "Dynamic SMA color based on trend", group=grpMA)
maColorUp         = input.color(color.lime, "SMA color (price above)", group=grpMA)
maColorDown       = input.color(color.red,  "SMA color (price below)", group=grpMA)
maColorFlat       = input.color(color.aqua, "SMA color (fixed, if dynamic is disabled)", group=grpMA)

grpEMA            = "EMA 9"
showEma           = input.bool(true, "Show EMA 9 on chart", group=grpEMA)
emaLen            = input.int(9, "EMA period", minval=1, group=grpEMA)
emaSrc            = input.source(close, "EMA source", group=grpEMA)
emaWidth          = input.int(2, "EMA line thickness", minval=1, maxval=10, group=grpEMA)
emaDynamicColor   = input.bool(true, "Dynamic EMA color based on trend", group=grpEMA)
emaColorUp        = input.color(color.lime, "EMA color (price above)", group=grpEMA)
emaColorDown      = input.color(color.red,  "EMA color (price below)", group=grpEMA)
emaColorFlat      = input.color(color.orange, "EMA color (fixed, if dynamic is disabled)", group=grpEMA)

grpADX            = "ADX Trend Strength Filter"
useAdxFilter      = input.bool(true, "Enable ADX filter (no signals when trend is weak)", group=grpADX)
adxLen            = input.int(14, "ADX period", minval=1, group=grpADX)
adxSmoothing      = input.int(14, "ADX smoothing", minval=1, group=grpADX)
adxThreshold      = input.float(14.0, "ADX minimum value to allow signals (higher = fewer signals)", minval=0, step=1, group=grpADX)

grpOB             = "Order Block (springboard)"
obEnable          = input.bool(true, "Enable Order Block detection", group=grpOB)
showObBoxes       = input.bool(true, "Show Order Block boxes on chart", group=grpOB)
obRealtimeDraw    = input.bool(true, "Draw OB also on forming candle (repainting)", group=grpOB)
useDisplacement   = input.bool(true, "Require displacement (strong breakout)", group=grpOB)
atrLen            = input.int(23, "ATR period", minval=1, group=grpOB)
dispMult          = input.float(0.9, "ATR multiplier for displacement", minval=0.1, step=0.1, group=grpOB)
obBoxCount        = input.int(5, "Max OB per side on chart", minval=1, maxval=20, group=grpOB)
obMitigateOnClose = input.bool(true, "Mitigation on close (otherwise on wick)", group=grpOB)
obProximityATR    = input.float(1.0, "'Near' margin (in ATR)", minval=0, step=0.1, group=grpOB)
obBorderTransp    = input.int(70, "OB border transparency (0 = solid, 100 = invisible)", minval=0, maxval=100, group=grpOB)
bullObColor       = input.color(color.new(color.teal, 80), "Bullish OB box color", group=grpOB)
bearObColor       = input.color(color.new(color.orange, 80), "Bearish OB box color", group=grpOB)

grpTouch          = "OB Touch Label"
showOBTouchLabel  = input.bool(true, "Show 'OB' label on first touch of an important Order Block", group=grpTouch)
obTouchMinSizeATR = input.float(1.0, "Minimum OB size to be 'important' (in ATR)", minval=0, step=0.1, group=grpTouch)
obTouchMaxLabels  = input.int(20, "Max OB Touch labels on chart", minval=5, maxval=500, group=grpTouch)

grpTrade          = "Trade Levels (SL/TP)"
showTradeBox      = input.bool(true, "Draw SL/TP box on confirmed signal", group=grpTrade)
rrRatio           = input.float(1.5, "Take Profit ratio (R:R)", minval=0.5, step=0.5, group=grpTrade)
minAtrStopMult    = input.float(0.8, "Stop Loss distance beyond C1 (in ATR)", minval=0, step=0.1, group=grpTrade)
tradeBoxBars      = input.int(30, "Box extension to the right (bars)", minval=1, group=grpTrade)
maxTradeBoxes     = input.int(10, "Max trade boxes on chart", minval=1, maxval=50, group=grpTrade)
tpBoxColor        = input.color(color.new(color.green, 85), "Take Profit box color", group=grpTrade)
slBoxColor        = input.color(color.new(color.red, 85), "Stop Loss box color", group=grpTrade)
tradeBorderTransp = input.int(40, "SL/TP box border transparency (0 = solid, 100 = invisible)", minval=0, maxval=100, group=grpTrade)
entryLineColor    = input.color(color.new(color.white, 20), "Entry line color", group=grpTrade)
ltfMode           = input.string("Auto", "Lower timeframe used to find which of TP/SL is hit first (min 1m)", options=["Auto", "1", "3", "5", "15", "30", "60"], group=grpTrade)

grpPanel          = "Last Trade Panel"
showInfoTable     = input.bool(true, "Show last trade Entry/SL/TP panel", group=grpPanel)
infoTablePos      = input.string("Top Right", "Panel position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpPanel)

grpStats          = "Monthly Stats Panel"
showMonthlyStats  = input.bool(true, "Show monthly weekly trade stats panel (bottom left)", group=grpStats)

// ============================================================
// SESSION TIME FILTER
// ============================================================
f_inSession() =>
    if not useSession
        true
    else
        t = hour(time) * 100 + minute(time)
        if sessionStart > sessionEnd
            t >= sessionStart or t <= sessionEnd   // overnight session
        else
            t >= sessionStart and t <= sessionEnd  // daytime session

inSession = f_inSession()

// ============================================================
// STATE & TRADE TRACKING
// ============================================================
var int   state              = 0
var float c1High             = na
var float c1Low              = na
var line  c1HiLine           = na
var line  c1LoLine           = na
var bool  isBuySetup         = false
var bool  isSellSetup        = false

var bool c1c2TouchedBullOB   = false
var bool c1c2TouchedBearOB   = false

var bool buyTradeDrawn       = false
var bool sellTradeDrawn      = false

var int lastBullOBBar        = -1
var int lastBearOBBar        = -1

var line[] histHi            = array.new_line()
var line[] histLo            = array.new_line()

var box[]   tpBoxes          = array.new_box()
var box[]   slBoxes          = array.new_box()
var line[]  entryLines       = array.new_line()

var label[] obTouchLabels    = array.new_label()
var label[] alertLabels      = array.new_label()
var label[] resultLabels     = array.new_label()

// --- ACTIVE TRADE (locked until TP or SL is hit) ---
var bool  inTrade            = false
var bool  activeIsLong       = false
var float activeSL           = na
var float activeTP           = na
var float activeEntry        = na
var box   activeTpBox        = na
var box   activeSlBox        = na
var line  activeEntryLine    = na

// --- ACTIVE TRADE WEEK/MONTH MEMORY ---
var int   activeWeek         = 0
var int   activeMonth        = na

// --- MONTHLY STATS ARRAYS (6 weeks max) ---
var int[] wkLong     = array.new_int(6, 0)
var int[] wkShort    = array.new_int(6, 0)
var int[] wkTP       = array.new_int(6, 0)
var int[] wkSL       = array.new_int(6, 0)
var int[] wkBlocked  = array.new_int(6, 0)

var int   currentMonth = na
var int   currentWeek  = 0

// --- LAST TRADE INFO PANEL ---
infoPos = infoTablePos == "Top Right" ? position.top_right : infoTablePos == "Top Left" ? position.top_left : infoTablePos == "Bottom Right" ? position.bottom_right : position.bottom_left
var table infoTable = table.new(infoPos, 2, 5, bgcolor=color.new(color.black, 15), border_width=1, border_color=color.gray)

// --- MONTHLY STATS TABLE ---
var table statsTable = table.new(position.bottom_left, 7, 7, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray)

f_updateInfoTable(isLong, entryPx, slPx, tpPx, status) =>
    if showInfoTable
        table.cell(infoTable, 0, 0, "Last Signal", text_color=color.white, bgcolor=color.new(color.gray, 20), text_size=size.normal)
        table.cell(infoTable, 1, 0, isLong ? "BUY" : "SELL", text_color=color.white, bgcolor=isLong ? color.new(color.green, 30) : color.new(color.red, 30), text_size=size.normal)
        table.cell(infoTable, 0, 1, "Entry", text_color=color.white, text_size=size.normal)
        table.cell(infoTable, 1, 1, str.tostring(entryPx, "#.#####"), text_color=color.white, text_size=size.normal)
        table.cell(infoTable, 0, 2, "SL", text_color=color.white, text_size=size.normal)
        table.cell(infoTable, 1, 2, str.tostring(slPx, "#.#####"), text_color=color.red, text_size=size.normal)
        table.cell(infoTable, 0, 3, "TP", text_color=color.white, text_size=size.normal)
        table.cell(infoTable, 1, 3, str.tostring(tpPx, "#.#####"), text_color=color.green, text_size=size.normal)
        table.cell(infoTable, 0, 4, "Status", text_color=color.white, text_size=size.normal)
        table.cell(infoTable, 1, 4, status, text_color=color.white, bgcolor=status == "IN TRADE" ? color.new(color.blue, 30) : color.new(color.gray, 30), text_size=size.normal)

// ============================================================
// MONTHLY RESET + WEEK OF MONTH
// ============================================================
curMonth = month(time)
if na(currentMonth) or curMonth != currentMonth
    currentMonth := curMonth
    for i = 0 to 5
        array.set(wkLong,    i, 0)
        array.set(wkShort,   i, 0)
        array.set(wkTP,      i, 0)
        array.set(wkSL,      i, 0)
        array.set(wkBlocked, i, 0)

dayOfMonth  = dayofmonth(time)
currentWeek := math.min(int((dayOfMonth - 1) / 7), 5)

// Snapshot at bar start
bool wasInTrade     = inTrade
bool openedThisBar  = false
bool blockedThisBar = false

// Per-bar signal flags
buySignal   = false
sellSignal  = false
buyOB       = false
sellOB      = false

// ============================================================
// MOVING AVERAGES (SMA + EMA 9, with dynamic colors)
// ============================================================
maValue  = ta.sma(maSrc, maLen)
emaValue = ta.ema(emaSrc, emaLen)

// Dynamic color for SMA
maPlotColor = maDynamicColor ? (close > maValue ? maColorUp : close < maValue ? maColorDown : maColorFlat) : maColorFlat
plot(showMaPlot ? maValue : na, title="SMA", color=maPlotColor, linewidth=maWidth)

// Dynamic color for EMA 9
emaPlotColor = emaDynamicColor ? (close > emaValue ? emaColorUp : close < emaValue ? emaColorDown : emaColorFlat) : emaColorFlat
plot(showEma ? emaValue : na, title="EMA 9", color=emaPlotColor, linewidth=emaWidth)

// Filter selection: if useEmaAsFilter = true -> use EMA 9, else use SMA
filterMA = useEmaAsFilter ? emaValue : maValue

aboveMa = not useMaFilter or close > filterMA
belowMa = not useMaFilter or close < filterMA

// ============================================================
// ADX TREND STRENGTH FILTER (no separate pane plot)
// ============================================================
[diPlus, diMinus, adxValue] = ta.dmi(adxLen, adxSmoothing)

adxOK = not useAdxFilter or (not na(adxValue) and adxValue >= adxThreshold)

// ============================================================
// INTRABAR DATA
// ============================================================
chartSec = timeframe.in_seconds()
ltfAuto  = chartSec >= 3600 ? "5" : "1"
ltfTF    = ltfMode == "Auto" ? ltfAuto : ltfMode

ltfHigh = request.security_lower_tf(syminfo.tickerid, ltfTF, high)
ltfLow  = request.security_lower_tf(syminfo.tickerid, ltfTF, low)

// ============================================================
// ORDER BLOCK: data structures
// ============================================================
var box[]   bullBoxes   = array.new_box()
var float[] bullTop     = array.new_float()
var float[] bullBottom  = array.new_float()
var bool[]  bullTouched = array.new_bool()

var box[]   bearBoxes   = array.new_box()
var float[] bearTop     = array.new_float()
var float[] bearBottom  = array.new_float()
var bool[]  bearTouched = array.new_bool()

atrVal = ta.atr(atrLen)

// ============================================================
// ORDER BLOCK: mitigation (confirmed bars only)
// ============================================================
if barstate.isconfirmed and obEnable
    if array.size(bullBoxes) > 0
        for i = array.size(bullBoxes) - 1 to 0
            bx  = array.get(bullBoxes, i)
            bot = array.get(bullBottom, i)
            box.set_right(bx, bar_index)
            mitigated = obMitigateOnClose ? close < bot : low < bot
            if mitigated
                box.delete(bx)
                array.remove(bullBoxes, i)
                array.remove(bullTop, i)
                array.remove(bullBottom, i)
                array.remove(bullTouched, i)

    if array.size(bearBoxes) > 0
        for i = array.size(bearBoxes) - 1 to 0
            bx  = array.get(bearBoxes, i)
            top = array.get(bearTop, i)
            box.set_right(bx, bar_index)
            mitigated = obMitigateOnClose ? close > top : high > top
            if mitigated
                box.delete(bx)
                array.remove(bearBoxes, i)
                array.remove(bearTop, i)
                array.remove(bearBottom, i)
                array.remove(bearTouched, i)

// ============================================================
// ORDER BLOCK: creation
// ============================================================
if obEnable and (obRealtimeDraw or barstate.isconfirmed)
    bullishOB = close[1] < open[1] and close > high[1] and (not useDisplacement or (close - open) > atrVal * dispMult)
    if bullishOB and bar_index != lastBullOBBar
        obTop = high[1]
        obBot = low[1]
        newBoxBull = box.new(left=bar_index[1], top=obTop, right=bar_index, bottom=obBot, border_color=color.new(bullObColor, obBorderTransp), bgcolor=showObBoxes ? bullObColor : na)
        array.push(bullBoxes, newBoxBull)
        array.push(bullTop, obTop)
        array.push(bullBottom, obBot)
        array.push(bullTouched, false)
        lastBullOBBar := bar_index
        if array.size(bullBoxes) > obBoxCount
            box.delete(array.shift(bullBoxes))
            array.shift(bullTop)
            array.shift(bullBottom)
            array.shift(bullTouched)

    bearishOB = close[1] > open[1] and close < low[1] and (not useDisplacement or (open - close) > atrVal * dispMult)
    if bearishOB and bar_index != lastBearOBBar
        obTop = high[1]
        obBot = low[1]
        newBoxBear = box.new(left=bar_index[1], top=obTop, right=bar_index, bottom=obBot, border_color=color.new(bearObColor, obBorderTransp), bgcolor=showObBoxes ? bearObColor : na)
        array.push(bearBoxes, newBoxBear)
        array.push(bearTop, obTop)
        array.push(bearBottom, obBot)
        array.push(bearTouched, false)
        lastBearOBBar := bar_index
        if array.size(bearBoxes) > obBoxCount
            box.delete(array.shift(bearBoxes))
            array.shift(bearTop)
            array.shift(bearBottom)
            array.shift(bearTouched)

// ============================================================
// OB CHECK FUNCTIONS
// ============================================================
f_overlapsAnyBox(tops, bottoms, lo, hi, margin) =>
    bool found = false
    int sz = array.size(tops)
    if sz > 0
        for i = 0 to sz - 1
            t = array.get(tops, i)
            b = array.get(bottoms, i)
            if hi >= b - margin and lo <= t + margin
                found := true
                break
    found

f_checkImportantTouch(tops, bottoms, touched, lo, hi, minSizeATR, atrV) =>
    bool anyNewTouch = false
    int sz = array.size(tops)
    if sz > 0
        for i = 0 to sz - 1
            already = array.get(touched, i)
            if not already
                t = array.get(tops, i)
                b = array.get(bottoms, i)
                sizeOK  = (t - b) >= atrV * minSizeATR
                overlap = hi >= b and lo <= t
                if sizeOK and overlap
                    array.set(touched, i, true)
                    anyNewTouch := true
    anyNewTouch

// ============================================================
// OB TOUCH LABELS
// ============================================================
if showOBTouchLabel and obEnable and showObBoxes
    newBullTouch = f_checkImportantTouch(bullTop, bullBottom, bullTouched, low, high, obTouchMinSizeATR, atrVal)
    newBearTouch = f_checkImportantTouch(bearTop, bearBottom, bearTouched, low, high, obTouchMinSizeATR, atrVal)
    if newBullTouch or newBearTouch
        obTouchLbl = label.new(bar_index, high, text="OB", style=label.style_label_down,
                             color=color.new(color.white, 100), textcolor=color.white, size=size.tiny)
        array.push(obTouchLabels, obTouchLbl)
        if array.size(obTouchLabels) > obTouchMaxLabels
            label.delete(array.shift(obTouchLabels))

// ============================================================
// TRADE DRAW FUNCTION
// ============================================================
f_drawTrade(isLong, entryPx, slPx) =>
    riskDist  = math.abs(entryPx - slPx)
    tpPx      = isLong ? entryPx + riskDist * rrRatio : entryPx - riskDist * rrRatio
    boxRight  = bar_index + tradeBoxBars

    if showTradeBox
        tBox = box.new(left=bar_index, top=isLong ? tpPx : entryPx, right=boxRight,
             bottom=isLong ? entryPx : tpPx, border_color=color.new(color.green, tradeBorderTransp), bgcolor=tpBoxColor)
        sBox = box.new(left=bar_index, top=isLong ? entryPx : slPx, right=boxRight,
             bottom=isLong ? slPx : entryPx, border_color=color.new(color.red, tradeBorderTransp), bgcolor=slBoxColor)
        eLine = line.new(bar_index, entryPx, boxRight, entryPx, color=entryLineColor, width=1, style=line.style_dashed)

        array.push(tpBoxes, tBox)
        array.push(slBoxes, sBox)
        array.push(entryLines, eLine)

        if array.size(tpBoxes) > maxTradeBoxes
            box.delete(array.shift(tpBoxes))
            box.delete(array.shift(slBoxes))
            line.delete(array.shift(entryLines))

    tpPx

// ============================================================
// REAL-TIME SIGNAL CHECK (MA filter + ADX + session applied)
// ============================================================
if state == 2 and not wasInTrade
    tolBrk = atrVal * closeToleranceATR

    buyPattern  = isBuySetup  and high >= c1High + tolBrk and aboveMa and adxOK
    sellPattern = isSellSetup and low  <= c1Low  - tolBrk and belowMa and adxOK

    if (buyPattern or sellPattern) and not inSession
        blockedThisBar := true
        array.set(wkBlocked, currentWeek, array.get(wkBlocked, currentWeek) + 1)

    buyConfirm  = buyPattern  and inSession
    sellConfirm = sellPattern and inSession

    if buyConfirm and showBuy
        buySignal := true
        buyOB     := obEnable and c1c2TouchedBullOB
        if not buyTradeDrawn
            slPx = c1Low - atrVal * minAtrStopMult
            tpPx = f_drawTrade(true, c1High, slPx)
            buyTradeDrawn := true

            inTrade      := true
            activeIsLong := true
            activeSL     := slPx
            activeTP     := tpPx
            activeEntry  := c1High
            activeWeek   := currentWeek
            activeMonth  := currentMonth
            f_updateInfoTable(true, c1High, slPx, tpPx, "IN TRADE")
            openedThisBar := true
            array.set(wkLong, currentWeek, array.get(wkLong, currentWeek) + 1)

            if showTradeBox and array.size(tpBoxes) > 0
                lastIdx = array.size(tpBoxes) - 1
                activeTpBox     := array.get(tpBoxes, lastIdx)
                activeSlBox     := array.get(slBoxes, lastIdx)
                activeEntryLine := array.get(entryLines, lastIdx)

    if sellConfirm and showSell
        sellSignal := true
        sellOB     := obEnable and c1c2TouchedBearOB
        if not sellTradeDrawn
            slPx = c1High + atrVal * minAtrStopMult
            tpPx = f_drawTrade(false, c1Low, slPx)
            sellTradeDrawn := true

            inTrade      := true
            activeIsLong := false
            activeSL     := slPx
            activeTP     := tpPx
            activeEntry  := c1Low
            activeWeek   := currentWeek
            activeMonth  := currentMonth
            f_updateInfoTable(false, c1Low, slPx, tpPx, "IN TRADE")
            openedThisBar := true
            array.set(wkShort, currentWeek, array.get(wkShort, currentWeek) + 1)

            if showTradeBox and array.size(tpBoxes) > 0
                lastIdx = array.size(tpBoxes) - 1
                activeTpBox     := array.get(tpBoxes, lastIdx)
                activeSlBox     := array.get(slBoxes, lastIdx)
                activeEntryLine := array.get(entryLines, lastIdx)

// ============================================================
// TRADE EXIT: first level hit wins (intrabar order)
// ============================================================
f_firstHit(isLong, tpPx, slPx, entryPx, fromEntry) =>
    int res = 0
    int n = array.size(ltfHigh)
    if n > 0
        bool active = not fromEntry
        for i = 0 to n - 1
            h = array.get(ltfHigh, i)
            l = array.get(ltfLow, i)
            if not active
                active := isLong ? h >= entryPx : l <= entryPx
            if active
                tpHit = isLong ? h >= tpPx : l <= tpPx
                slHit = isLong ? l <= slPx : h >= slPx
                if slHit
                    res := 2
                    break
                else if tpHit
                    res := 1
                    break
    else if not fromEntry
        tpHitB = isLong ? high >= tpPx : low <= tpPx
        slHitB = isLong ? low <= slPx : high >= slPx
        if slHitB
            res := 2
        else if tpHitB
            res := 1
    res

if inTrade
    hit = f_firstHit(activeIsLong, activeTP, activeSL, activeEntry, openedThisBar)
    if hit != 0
        isTP   = hit == 1
        exitPx = isTP ? activeTP : activeSL
        f_updateInfoTable(activeIsLong, activeEntry, activeSL, activeTP, isTP ? "TP HIT" : "SL HIT")

        resLbl = label.new(bar_index, exitPx, text=isTP ? "TP ✔" : "SL ✘",
             style=(activeIsLong == isTP) ? label.style_label_down : label.style_label_up,
             color=color.new(isTP ? color.green : color.red, 30), textcolor=color.white, size=size.small)
        array.push(resultLabels, resLbl)
        if array.size(resultLabels) > 100
            label.delete(array.shift(resultLabels))

        if not na(activeTpBox)
            box.set_right(activeTpBox, bar_index)
            box.set_right(activeSlBox, bar_index)
            line.set_x2(activeEntryLine, bar_index)
            activeTpBox     := na
            activeSlBox     := na
            activeEntryLine := na

        if not na(activeMonth)
            if isTP
                array.set(wkTP, activeWeek, array.get(wkTP, activeWeek) + 1)
            else
                array.set(wkSL, activeWeek, array.get(wkSL, activeWeek) + 1)

        inTrade  := false
        activeSL := na
        activeTP := na

// ============================================================
// STATEFUL LOGIC (confirmed bars only)
// ============================================================
if barstate.isconfirmed
    if state == 0
        c1High   := high
        c1Low    := low
        c1c2TouchedBullOB := false
        c1c2TouchedBearOB := false
        buyTradeDrawn  := false
        sellTradeDrawn := false
        if obEnable
            marginC1 = atrVal * obProximityATR
            if f_overlapsAnyBox(bullTop, bullBottom, low, high, marginC1)
                c1c2TouchedBullOB := true
            if f_overlapsAnyBox(bearTop, bearBottom, low, high, marginC1)
                c1c2TouchedBearOB := true
        if showLines
            c1HiLine := line.new(bar_index, high, bar_index + 2, high, xloc=xloc.bar_index, color=lineColor, width=1)
            c1LoLine := line.new(bar_index, low,  bar_index + 2, low,  xloc=xloc.bar_index, color=lineColor, width=1)
        state := 1

    else if state == 1
        brokeDown = low  < c1Low
        brokeUp   = high > c1High
        reclaimed = close >= c1Low and close <= c1High
        buySetup  = brokeDown and not brokeUp and reclaimed
        sellSetup = brokeUp and not brokeDown and reclaimed

        if obEnable and (buySetup or sellSetup)
            marginC2 = atrVal * obProximityATR
            if f_overlapsAnyBox(bullTop, bullBottom, low, high, marginC2)
                c1c2TouchedBullOB := true
            if f_overlapsAnyBox(bearTop, bearBottom, low, high, marginC2)
                c1c2TouchedBearOB := true

        if buySetup or sellSetup
            isBuySetup  := buySetup
            isSellSetup := sellSetup
            if showLines and not na(c1HiLine)
                line.set_color(c1HiLine, setupColor)
                line.set_color(c1LoLine, setupColor)
            state := 2
        else
            if not na(c1HiLine)
                line.delete(c1HiLine)
                line.delete(c1LoLine)
            c1High := high
            c1Low  := low
            c1c2TouchedBullOB := false
            c1c2TouchedBearOB := false
            buyTradeDrawn  := false
            sellTradeDrawn := false
            if obEnable
                marginC1 = atrVal * obProximityATR
                if f_overlapsAnyBox(bullTop, bullBottom, low, high, marginC1)
                    c1c2TouchedBullOB := true
                if f_overlapsAnyBox(bearTop, bearBottom, low, high, marginC1)
                    c1c2TouchedBearOB := true
            if showLines
                c1HiLine := line.new(x1=bar_index, y1=high, x2=bar_index + 2, y2=high, xloc=xloc.bar_index, color=lineColor, width=1)
                c1LoLine := line.new(x1=bar_index, y1=low,  x2=bar_index + 2, y2=low,  xloc=xloc.bar_index, color=lineColor, width=1)
            else
                c1HiLine := na
                c1LoLine := na
            state := 1

    else if state == 2
        tolBrkF = atrVal * closeToleranceATR

        buyPatternF  = isBuySetup  and high >= c1High + tolBrkF and aboveMa and adxOK
        sellPatternF = isSellSetup and low  <= c1Low  - tolBrkF and belowMa and adxOK

        if (buyPatternF or sellPatternF) and not inSession and not openedThisBar
            if not blockedThisBar
                blockedThisBar := true
                array.set(wkBlocked, currentWeek, array.get(wkBlocked, currentWeek) + 1)

        buyConfirmFinal  = not wasInTrade and buyPatternF  and inSession
        sellConfirmFinal = not wasInTrade and sellPatternF and inSession

        if buyConfirmFinal or sellConfirmFinal or openedThisBar
            if not na(c1HiLine)
                array.push(histHi, c1HiLine)
                array.push(histLo, c1LoLine)
                while array.size(histHi) > maxHistory
                    line.delete(array.shift(histHi))
                    line.delete(array.shift(histLo))
            isBuySetup  := false
            isSellSetup := false
            c1c2TouchedBullOB := false
            c1c2TouchedBearOB := false
            buyTradeDrawn  := false
            sellTradeDrawn := false
            state       := 0
        else
            if not na(c1HiLine)
                line.delete(c1HiLine)
                line.delete(c1LoLine)
            isBuySetup  := false
            isSellSetup := false
            c1High := high
            c1Low  := low
            c1c2TouchedBullOB := false
            c1c2TouchedBearOB := false
            buyTradeDrawn  := false
            sellTradeDrawn := false
            if obEnable
                marginC1 = atrVal * obProximityATR
                if f_overlapsAnyBox(bullTop, bullBottom, low, high, marginC1)
                    c1c2TouchedBullOB := true
                if f_overlapsAnyBox(bearTop, bearBottom, low, high, marginC1)
                    c1c2TouchedBearOB := true
            if showLines
                c1HiLine := line.new(x1=bar_index, y1=high, x2=bar_index + 2, y2=high, xloc=xloc.bar_index, color=lineColor, width=1)
                c1LoLine := line.new(x1=bar_index, y1=low,  x2=bar_index + 2, y2=low,  xloc=xloc.bar_index, color=lineColor, width=1)
            else
                c1HiLine := na
                c1LoLine := na
            state := 1

// ============================================================
// SIGNAL PLOTS
// ============================================================
plotchar(buySignal,  title="Buy Star",  char="★", location=location.belowbar, color=buyColor,  size=size.small)
plotchar(sellSignal, title="Sell Star", char="★", location=location.abovebar, color=sellColor, size=size.small)

if buySignal and buyOB
    lbl = label.new(bar_index, low, text="OB", style=label.style_label_up, color=color.new(bullObColor, 90), textcolor=color.white, size=size.tiny)
    array.push(alertLabels, lbl)
    if array.size(alertLabels) > 200
        label.delete(array.shift(alertLabels))

if sellSignal and sellOB
    lbl = label.new(bar_index, high, text="OB", style=label.style_label_down, color=color.new(bearObColor, 90), textcolor=color.white, size=size.tiny)
    array.push(alertLabels, lbl)
    if array.size(alertLabels) > 200
        label.delete(array.shift(alertLabels))

// ============================================================
// MONTHLY STATS TABLE
// ============================================================
if showMonthlyStats and barstate.islast
    table.cell(statsTable, 0, 0, "Wk",    text_color=color.white, bgcolor=color.new(color.gray, 30),  text_size=size.small)
    table.cell(statsTable, 1, 0, "Long",  text_color=color.white, bgcolor=color.new(color.green, 40), text_size=size.small)
    table.cell(statsTable, 2, 0, "Short", text_color=color.white, bgcolor=color.new(color.red, 40),   text_size=size.small)
    table.cell(statsTable, 3, 0, "TP",    text_color=color.white, bgcolor=color.new(color.green, 40), text_size=size.small)
    table.cell(statsTable, 4, 0, "SL",    text_color=color.white, bgcolor=color.new(color.red, 40),   text_size=size.small)
    table.cell(statsTable, 5, 0, "WR%",   text_color=color.white, bgcolor=color.new(color.blue, 40),  text_size=size.small)
    table.cell(statsTable, 6, 0, "Blk",   text_color=color.white, bgcolor=color.new(color.orange, 40), text_size=size.small)

    int totL   = 0
    int totS   = 0
    int totTP  = 0
    int totSL  = 0
    int totBlk = 0

    for i = 0 to 5
        l   = array.get(wkLong,    i)
        s   = array.get(wkShort,   i)
        tp  = array.get(wkTP,      i)
        sl  = array.get(wkSL,      i)
        blk = array.get(wkBlocked, i)
        totL   += l
        totS   += s
        totTP  += tp
        totSL  += sl
        totBlk += blk

        trades = tp + sl
        wr     = trades > 0 ? (tp * 100.0 / trades) : 0.0
        wrTxt  = trades > 0 ? str.tostring(wr, "#.#") + "%" : "-"

        table.cell(statsTable, 0, i + 1, "W" + str.tostring(i + 1), text_color=color.white, text_size=size.small)
        table.cell(statsTable, 1, i + 1, str.tostring(l),   text_color=color.white, text_size=size.small)
        table.cell(statsTable, 2, i + 1, str.tostring(s),   text_color=color.white, text_size=size.small)
        table.cell(statsTable, 3, i + 1, str.tostring(tp),  text_color=color.lime,  text_size=size.small)
        table.cell(statsTable, 4, i + 1, str.tostring(sl),  text_color=color.red,   text_size=size.small)
        table.cell(statsTable, 5, i + 1, wrTxt,             text_color=wr >= 50 ? color.lime : color.orange, text_size=size.small)
        table.cell(statsTable, 6, i + 1, str.tostring(blk), text_color=color.orange, text_size=size.small)

    totTrades = totTP + totSL
    totWR     = totTrades > 0 ? (totTP * 100.0 / totTrades) : 0.0
    totWRTxt  = totTrades > 0 ? str.tostring(totWR, "#.#") + "%" : "-"

    table.cell(statsTable, 0, 6, "Tot", text_color=color.white, bgcolor=color.new(color.blue, 30), text_size=size.small)
    table.cell(statsTable, 1, 6, str.tostring(totL),   text_color=color.white, bgcolor=color.new(color.blue, 30), text_size=size.small)
    table.cell(statsTable, 2, 6, str.tostring(totS),   text_color=color.white, bgcolor=color.new(color.blue, 30), text_size=size.small)
    table.cell(statsTable, 3, 6, str.tostring(totTP),  text_color=color.lime,  bgcolor=color.new(color.blue, 30), text_size=size.small)
    table.cell(statsTable, 4, 6, str.tostring(totSL),  text_color=color.red,   bgcolor=color.new(color.blue, 30), text_size=size.small)
    table.cell(statsTable, 5, 6, totWRTxt,             text_color=totWR >= 50 ? color.lime : color.orange, bgcolor=color.new(color.blue, 30), text_size=size.small)
    table.cell(statsTable, 6, 6, str.tostring(totBlk), text_color=color.orange, bgcolor=color.new(color.blue, 30), text_size=size.small)

// ============================================================
// ALERTS
// ============================================================
if buySignal
    alert("BUY confirmed on " + syminfo.ticker, alert.freq_once_per_bar)
if sellSignal
    alert("SELL confirmed on " + syminfo.ticker, alert.freq_once_per_bar)
if buySignal and buyOB
    alert("BUY confirmed + Order Block springboard on " + syminfo.ticker, alert.freq_once_per_bar)
if sellSignal and sellOB
    alert("SELL confirmed + Order Block springboard on " + syminfo.ticker, alert.freq_once_per_bar)

alertcondition(isBuySetup  and state == 2, title="Buy Setup Pending",  message="Low sweep + reclaim: waiting for C1 breakout on C3")
alertcondition(isSellSetup and state == 2, title="Sell Setup Pending", message="High sweep + reclaim: waiting for C1 breakout on C3")
alertcondition(buySignal,  title="Buy Confirmed",  message="C3 breaks C1 high: BUY pattern completed")
alertcondition(sellSignal, title="Sell Confirmed", message="C3 breaks C1 low: SELL pattern completed")
alertcondition(buySignal  and buyOB,  title="Buy + Order Block",  message="BUY confirmed with Order Block springboard")
alertcondition(sellSignal and sellOB, title="Sell + Order Block", message="SELL confirmed with Order Block springboard")
alertcondition(showOBTouchLabel, title="Important OB Touch", message="First candle touching an important Order Block")
````
