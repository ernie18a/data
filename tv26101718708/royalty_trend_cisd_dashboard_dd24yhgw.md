# Royalty Trend + CISD Dashboard

- url: https://www.tradingview.com/script/dd24YhGW-Royalty-Trend-CISD-Dashboard/
- type: indicator
- pine_id: PUB;468ae274aaec4b338736399377ab1579
- version: 1.0

## Description

ROYALTY TREND + CISD DASHBOARD

A confluence indicator that combines an ATR-based trend engine with Change in State of Delivery (CISD) detection. A trade signal ("GO") prints only when both agree. Each signal is then graded for setup quality and trustworthiness, and an outcome log tests those signals forward on your chart's history so you can see which grades and exit styles actually performed.

The idea is simple: the trend flip is the TRIGGER, the CISD is the CONFIRMATION, and the verdict is the CONFLUENCE.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CREDITS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
This indicator is built on two open-source scripts. Full credit to their authors:

- "Trend Signals with TP & SL" by UAlgo
  Supplies the ATR trend engine, Buy/Sell signals, cloud, and the Entry/SL/TP framework. Originally Pine v5; migrated to v6 here.

- "CISD with Alerts" by neo|
  Supplies the CISD structure-tracking engine and level drawing.

Thank you to both authors for sharing their work with the community. Everything beyond those two cores was added in this script: the confirmation gate, confluence logic, Strength and Confidence scoring, signal filter, outcome log, model-compare table, repaint controls, consolidated alert, and dashboard themes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW IT WORKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1) TREND ENGINE (from UAlgo)
An ATR band (source hl2, Sensitivity x ATR) trails price. When the close crosses the opposite band, the trend flips and a Buy or Sell label prints. A cloud built from the EMA of highs and the EMA of lows sits behind price. The cloud is tinted aqua when the MACD line is above zero and red when it is below.

On a trend flip, the script projects an Entry, Stop, and TP1/TP2/TP3. You can choose between two modes:
- Percent: the stop sits at Stop Loss % from entry, and the TPs sit at 1R, 2R, and 3R. Setting the percent to 0 turns levels off.
- ATR: the stop and the TPs are fixed ATR multiples, captured at the entry bar.
The trend position closes when the stop or TP3 is hit. Levels are drawn from the last trend-flip entry.

2) CISD ENGINE (from neo|)
The script tracks the opening price of pullback candle sequences. When market structure breaks, it draws a CISD level at the origin of the move that caused the break. A CISD becomes CONFIRMED when price closes through that level in one of two ways:
- Strong close: a single candle closes beyond the level, in the strong part of its own range (default: the top or bottom 50%), or
- 2-bar: two consecutive closes beyond the level (optional).
The confirmation candle is labeled "50% close" or "2-bar" and its background is highlighted. CISD state is tri-state: Bullish, Bearish, or None.

3) CONFLUENCE / GO SIGNALS
- GO LONG prints when the trend is bullish AND the CISD is bullish.
- GO SHORT prints when the trend is bearish AND the CISD is bearish.
- Only the first bar of a new alignment prints a marker.
- If the two disagree, the dashboard verdict reads CONFLICT.

4) STRENGTH SCORE (0-100, graded A+ to F)
This measures setup quality on the chart timeframe. Points come from:
- Alignment: 40 points (12 if there is no CISD yet)
- CISD confirmation quality: 20 for a strong close, 12 for 2-bar
- MACD momentum direction and slope: 15
- Close position versus the cloud: 10
- R:R to TP1: 10
- Freshness of the CISD (bars since it formed): 5
Grades: A+ is 90 or more, A is 80+, B is 70+, C is 60+, D is 50+, and anything lower is F.

5) CONFIDENCE SCORE (0-100: High, Med, or Low)
This measures how much to trust the read. Points come from:
- Higher-timeframe trend agreement: 40 (the default HTF is 60m)
- Trend persistence (bars since the last flip, and number of flips in the last 20 bars): 25
- Volatility regime (ATR14 versus its 50-bar average; calm conditions score higher): 20
- Extension from the cloud midpoint, measured in ATR (stretched price scores lower): 15
Tiers: High is 75 or more, Med is 50+, and anything lower is Low.

6) SIGNAL FILTER
Filter modes: Off, Strength only, Confidence only, Both required, or Either. You set a minimum grade and a minimum confidence %. GO signals that fail the filter print a small gray "×" so you can still see what was blocked.

7) OUTCOME LOG (expectancy table)
Every raw GO signal is logged before the filter is applied. Each one is entered at the GO bar's close and simulated forward on confirmed bars only. You choose one of three exit models:
- Scale thirds: take 1/3 at TP1 and move the stop to breakeven, take 1/3 at TP2 and move the stop to TP1, take the final 1/3 at TP3.
- All out at TP1: a single 1R target.
- Runner to TP3: full size held to TP3 or the stop, with a fixed stop.
The table reports N, Expectancy (average R per trade), and Win%. Results are shown overall, by Strength grade, and by Confidence tier. This is how you find out whether A grades actually outperform C grades on your instrument.

8) MODEL-COMPARE TABLE
All three exit models are run in parallel on the same signals. For each model the table shows N, Expectancy, Net R, Max Drawdown (in R), and Profit Factor. The row for your currently selected model is marked.

9) REPAINT CONTROL
- "Confirm signals on bar close" (on by default): Buy/Sell, GO, blocked markers, and CISD confirmation marks only appear after the bar closes.
- "HTF confidence: use last closed HTF bar" (on by default): the HTF component won't wiggle intrabar, at the cost of up to one HTF bar of lag.
The outcome log and the compare table always use confirmed bars only.

10) DASHBOARD
The dashboard shows Trend, CISD, Confirm method, Verdict, Strength, Confidence, Filter status, Position, Entry, Stop, TPs, R:R, and % from entry. There are two themes: Classic, and Futuristic (HUD), which uses a monospace font, a neon palette, and segmented meters.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW TO USE IT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Set the HTF. Under Confidence, set the higher timeframe above your execution chart (for example, 60 on a 5m chart, or 240 on a 15m or 1H chart).

2. Choose your risk model. Use Percent for clean R-multiples. Use ATR if you want stops that adapt to volatility.

3. Read the log before filtering. With the filter Off, scroll through plenty of history and study the Outcome Log and the Compare table. Look for which grades and confidence tiers show positive expectancy, and which exit model gives the best balance of Net R and Max Drawdown.

4. Set the filter to match the data. For example, if C-grade signals are negative but B and above are positive, set the Min grade to B. Choose the exit model that fits both the numbers and how you actually manage trades.

5. Trade the GO, not just the flip.
   • Buy/Sell labels mean only that the trend has flipped.
   • GO means the trend and the CISD agree.
   • Prioritize GO signals that pass the filter and carry a High Confidence rating.

6. Set up alerts.
   • Recommended: create an alert on this indicator with the condition "Any alert() function call." You'll receive one message per filtered GO with symbol, timeframe, direction, grade and score, confidence, entry, stop, and TP1/TP2/TP3. It fires once per bar close.
   • Also available as separate conditions: GO LONG, GO SHORT, Trend Buy, Trend Sell, and optional CISD-formed alerts.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NOTES & LIMITATIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- The Entry/SL/TP lines and the dashboard levels follow the TREND position (from the last Buy/Sell flip). The Outcome Log and the GO alert use the GO bar's close as entry. These can differ, so use the alert or GO levels when trading GO signals.
- The outcome log is a forward simulation, not a broker-grade backtest. It includes no slippage, commissions, or partial fills. When the stop and a target are both touched on the same bar, it counts as a stop. Open trades are not counted. Results depend on how much history is loaded.
- CISD level lines extend and update live because structure is computed intrabar. The signal markers do not repaint while "confirm on close" is enabled.
- Scores are heuristics meant to rank setups, not probabilities.

For educational purposes only. Not financial advice.

## Source Code

````pine
//@version=6
// =============================================================================
//  Royalty Trend + CISD Dashboard
//  Merges: "Trend Signals with TP & SL [UAlgo]" (v5 -> migrated to v6)
//          "CISD with Alerts [neo|]"           (v6)
//  Trend band-flip = trigger | CISD state = confirmation | Verdict = confluence
//
//  v9  : tri-state CISD, symmetric confluence, clean Percent 0=off.
//  v10 : Strength row (0-100 -> A+..F).
//  v11 : Dashboard theme toggle (Classic / Futuristic HUD).
//  v12 : Confidence score + Signal Filter.
//  v13 : Outcome Log (TP1-vs-stop win-rate by grade/confidence).
//  v14 : Outcome Log -> EXPECTANCY. Reports average R captured per trade, per
//        bucket, under a selectable exit model:
//          - Scale thirds (BE->TP1 trail): 1/3 at TP1 (stop->BE), 1/3 at TP2
//            (stop->TP1), 1/3 at TP3.
//          - All out at TP1: single 1R target.
//          - Runner to TP3 (fixed stop): full size to TP3 or -1R.
//        Confirmed bars only, enter at GO close, stop-first on same-bar ties,
//        R multiples derived per trade from actual offsets (Percent & ATR modes).
//  v15 : Model-compare table. Every GO is simulated under ALL THREE exit models
//        in parallel; a compact table reports N, Exp (avg R), Net R, Max
//        Drawdown (R) and Profit Factor per model so all three exits can be
//        compared without toggling. Net R / Max DD / PF double as the equity
//        readout. Per-bucket table still follows the selected Exit model.
//  v16 : Repaint control. "Confirm signals on bar close" (default on) holds the
//        Buy/Sell, GO and blocked markers, the CISD-confirm candle mark and its
//        background until the bar actually closes, so on-chart signals stop
//        flickering on the live bar. "HTF confidence: last closed bar" locks the
//        Confidence HTF component to the last CLOSED htf bar (no live-htf wiggle,
//        at the cost of up to one htf bar of lag). Outcome-log / compare engines
//        were already confirmed-bar only and never repainted; unchanged.
//        NOTE: market-structure / CISD level LINES still track live (structure
//        is computed intrabar) - that's level-tracking, not signal repaint.
//  v17 : Consolidated GO alert. One alert() fires on a confirmed, filter-passed
//        GO with full context in the message - symbol, timeframe, direction,
//        Strength grade+score, Confidence tier+%, and entry/stop/TP1-3 computed
//        from the signal bar's close (matching the outcome-log entry model).
//        Always fires once-per-bar-close (no repaint) regardless of the display
//        confirm toggle. Gated by "Enable consolidated GO alert" (default on).
// =============================================================================
indicator("Royalty Trend + CISD Dashboard", "Royalty T+CISD", overlay = true, max_lines_count = 500, max_labels_count = 500)

// =============================================================================
//                                 INPUTS
// =============================================================================
// --- Trend Signals (UAlgo) ---
grpT          = "Trend Signals (UAlgo)"
src           = input.source(hl2,        "Source",                          group = grpT)
Multiplier    = input.float(2.0,         "Sensitivity (0.5 - 5)", step = 0.1, minval = 0.5, maxval = 5, group = grpT)
atrPeriods    = input.int(10,            "ATR Length",                      group = grpT)
atrCalcMethod = input.string("Method 1", "ATR Calculation Method", options = ["Method 1", "Method 2"], group = grpT)
cloud_val     = input.int(10,            "Cloud Moving Average Length", minval = 5, maxval = 500, group = grpT)
stopLossVal   = input.float(2.0,         "Stop Loss Percent (0 = off)", minval = 0, group = grpT)
showBuySell   = input.bool(true,         "Show Buy/Sell Signals",           group = grpT)
showCloud     = input.bool(true,         "Show Cloud MA",                   group = grpT)
showTPSL      = input.bool(true,         "Show Entry / SL / TP lines",      group = grpT)

// --- CISD (neo) ---
grpC              = "CISD (neo)"
bullishBreakColor = input.color(color.teal, "Bull CISD", inline = "bup", group = grpC)
bullStr           = input.string("+CISD", " ",           inline = "bup", group = grpC)
bearishBreakColor = input.color(color.red,  "Bear CISD", inline = "bep", group = grpC)
bearStr           = input.string("-CISD", " ",           inline = "bep", group = grpC)
lineWidth         = input.int(1, "Line Width", minval = 1, maxval = 5,    group = grpC)
lookAheadBars     = input.int(5, "Line Lead Bars", minval = 0, maxval = 5, tooltip = "Small visual lead the active level keeps ahead of the current bar while it extends.", group = grpC)
styleOption       = input.string("Solid (─)", "Line Style", options = ["Solid (─)", "Dotted (┈)", "Dashed (╌)"], group = grpC)
keepLevels        = input.bool(false, "Keep old CISD levels", group = grpC)

// --- CISD confirmation gate (candle close) ---
grpF          = "CISD Confirmation (candle close)"
closePct      = input.float(0.5, "Strong-close fraction of range", step = 0.05, minval = 0.0, maxval = 1.0, tooltip = "A single break candle confirms the CISD if it closes beyond the level AND its close sits at least this far up (long) / down (short) its own range. 0.5 = closed in the strong half.", group = grpF)
useTwoClose   = input.bool(true, "Also confirm on 2 consecutive closes beyond level", group = grpF)
markConfirm   = input.bool(true, "Mark confirmation candle", group = grpF)
confBgHilite  = input.bool(true, "Highlight confirmation candle background", group = grpF)
confBullColor = input.color(color.teal, "Bull confirm color", inline = "cc", group = grpF)
confBearColor = input.color(color.red,  "Bear confirm color", inline = "cc", group = grpF)

// --- Take Profit / Stop basis ---
grpTP     = "Take Profit / Stop"
tpMode    = input.string("Percent", "TP / Stop Mode", options = ["Percent", "ATR"], tooltip = "Percent = R-multiples of the Stop Loss Percent (Trend group). ATR = fixed ATR multiples captured at the entry bar.", group = grpTP)
tpAtrLen  = input.int(14, "TP ATR Length", minval = 1, group = grpTP)
tpAtrStop = input.float(1.0, "Stop (x ATR)", step = 0.1, minval = 0.1, group = grpTP)
tpAtrM1   = input.float(1.0, "TP1 (x ATR)", step = 0.1, minval = 0.1, group = grpTP)
tpAtrM2   = input.float(2.0, "TP2 (x ATR)", step = 0.1, minval = 0.1, group = grpTP)
tpAtrM3   = input.float(3.0, "TP3 (x ATR)", step = 0.1, minval = 0.1, group = grpTP)

// --- Confluence Dashboard ---
grpD         = "Confluence Dashboard"
showDash     = input.bool(true,  "Show Dashboard",                    group = grpD)
dashTheme    = input.string("Classic", "Dashboard Theme", options = ["Classic", "Futuristic (HUD)"], tooltip = "Futuristic = monospace HUD, neon-on-dark palette, cyan frame, directional glyphs, and segmented meters.", group = grpD)
dashPosInp   = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = grpD)
dashSizeIn   = input.string("Normal", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpD)
showGoSig    = input.bool(true,  "Show GO LONG / GO SHORT markers",   group = grpD)
alertsOn     = input.bool(false, "Enable CISD-formed alerts",         group = grpD)
goAlertOn    = input.bool(true,  "Enable consolidated GO alert", tooltip = "Fires ONE alert() on a filter-passed GO, once per bar close (no repaint, regardless of the display confirm toggle). Message carries symbol, timeframe, direction, Strength grade+score, Confidence tier+%, and entry/stop/TP1-3 computed from the signal bar's close - the same entry model the outcome log uses. To receive it: Create Alert -> Condition = this indicator -> 'Any alert() function call'.", group = grpD)
showStrength = input.bool(true,  "Show Strength / Confidence row",    group = grpD)
strDetail    = input.string("Grade + Score", "Strength Display", options = ["Grade + Score", "Grade", "Score"], tooltip = "Confidence score (0-100) mapped to a grade: A+ >=90, A >=80, B >=70, C >=60, D >=50, else F.", group = grpD)

// --- Confidence + Signal Filter ---
grpCF          = "Confidence + Signal Filter"
confHTF        = input.timeframe("60", "Confidence: higher-timeframe bias", tooltip = "Timeframe whose trend must agree for full HTF-agreement credit. Set it above your execution chart. The live HTF bar can update until it closes; confirmed HTF bars are stable.", group = grpCF)
filterMode     = input.string("Off (display only)", "Signal filter", options = ["Off (display only)", "Strength only", "Confidence only", "Both required", "Either"], tooltip = "Gates the GO LONG / GO SHORT markers and alerts. Off = every aligned signal shows (current behavior). Suppressed signals draw a small gray x.", group = grpCF)
minGrade       = input.string("C", "Min Strength grade", options = ["A+", "A", "B", "C", "D", "F"], group = grpCF)
minConf        = input.int(60, "Min Confidence %", minval = 0, maxval = 100, group = grpCF)
showConfidence = input.bool(true, "Show Confidence row", group = grpCF)
showFilterRow  = input.bool(true, "Show Filter row",     group = grpCF)

// --- Outcome Log ---
grpOL       = "Outcome Log"
showStats   = input.bool(true, "Show outcome-log table", tooltip = "Logs every aligned GO (raw, pre-filter) at its close and simulates it forward under the chosen exit model on confirmed bars. Reports average R (expectancy) and win-rate bucketed by Strength grade and Confidence tier. Cumulative over loaded history; open trades aren't counted; same-bar ties count as stop; no slippage/costs.", group = grpOL)
exitModelIn = input.string("Scale thirds (BE→TP1 trail)", "Exit model", options = ["Scale thirds (BE→TP1 trail)", "All out at TP1", "Runner to TP3 (fixed stop)"], tooltip = "Scale thirds: 1/3 at TP1 (stop->breakeven), 1/3 at TP2 (stop->TP1), 1/3 at TP3. All out at TP1: single 1R target. Runner: full size to TP3 or -1R, stop never moves.", group = grpOL)
statsPos    = input.string("Bottom Left", "Table position", options = ["Bottom Left", "Bottom Right", "Top Left", "Top Right", "Middle Right"], group = grpOL)
showCompare = input.bool(true, "Show model-compare table", tooltip = "Simulates every logged GO under all three exit models at once and reports N, Exp (avg R), Net R, Max Drawdown (R) and Profit Factor per model. Equity stats are ordered by trade resolution; no slippage/costs; one symbol.", group = grpOL)
comparePos  = input.string("Top Left", "Compare table position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Middle Right"], group = grpOL)

// --- Repaint / Confirmation ---
grpR          = "Repaint / Confirmation"
confirmOnClose = input.bool(true, "Confirm signals on bar close (no live-bar repaint)", tooltip = "On: Buy/Sell, GO, blocked-x markers and the CISD-confirm candle mark only appear once the bar has CLOSED, so nothing flickers on the forming bar. Off: signals paint live and can appear/disappear until the bar closes. Trade-off: confirmed signals show one bar later - that's the honest timing, since the signal wasn't final until close.", group = grpR)
htfConfirmed   = input.bool(true, "HTF confidence: use last closed HTF bar", tooltip = "On: the Confidence HTF-agreement component reads the last CLOSED higher-timeframe bar, so it doesn't wiggle as the live HTF bar develops. Trade-off: up to one HTF bar of lag. Off: uses the live (updating) HTF bar.", group = grpR)

// Emission gate: on history every bar is confirmed, so this only suppresses the
// live forming bar; historical signals are unchanged.
emit = confirmOnClose ? barstate.isconfirmed : true

// =============================================================================
//                           TREND ENGINE (UAlgo)
// =============================================================================
atr1 = ta.atr(atrPeriods)
atr2 = ta.sma(ta.tr, atrPeriods)
atr  = atrCalcMethod == "Method 1" ? atr1 : atr2

up  = src - (Multiplier * atr)
up1 = nz(up[1], up)
up := close[1] > up1 ? math.max(up, up1) : up

dn  = src + (Multiplier * atr)
dn1 = nz(dn[1], dn)
dn := close[1] < dn1 ? math.min(dn, dn1) : dn

var int trend = 1
trend := trend == -1 and close > dn1 ? 1 : trend == 1 and close < up1 ? -1 : trend

buySignal  = trend ==  1 and trend[1] == -1
sellSignal = trend == -1 and trend[1] ==  1

var float pos = 0.0
pos := buySignal ? 1.0 : sellSignal ? -1.0 : pos

longCond  = buySignal  and pos[1] !=  1
shortCond = sellSignal and pos[1] != -1

// Entry / stop / target levels ------------------------------------------------
entryOfLong  = ta.valuewhen(longCond,  close, 0)
entryOfShort = ta.valuewhen(shortCond, close, 0)
lindex       = ta.valuewhen(longCond,  bar_index, 0)
sindex       = ta.valuewhen(shortCond, bar_index, 0)

tpAtr      = ta.atr(tpAtrLen)
atrAtLong  = ta.valuewhen(longCond,  tpAtr, 0)
atrAtShort = ta.valuewhen(shortCond, tpAtr, 0)

// --- 0 = off handling -------------------------------------------------------
pctActive = stopLossVal > 0
hasLevels = tpMode == "ATR" or pctActive
slPctFrac = pctActive ? stopLossVal / 100 : na

riskLong  = tpMode == "ATR" ? tpAtrStop * atrAtLong  : entryOfLong  * slPctFrac
riskShort = tpMode == "ATR" ? tpAtrStop * atrAtShort : entryOfShort * slPctFrac

offLong1  = tpMode == "ATR" ? tpAtrM1 * atrAtLong  : entryOfLong  * slPctFrac
offLong2  = tpMode == "ATR" ? tpAtrM2 * atrAtLong  : entryOfLong  * slPctFrac * 2
offLong3  = tpMode == "ATR" ? tpAtrM3 * atrAtLong  : entryOfLong  * slPctFrac * 3
offShort1 = tpMode == "ATR" ? tpAtrM1 * atrAtShort : entryOfShort * slPctFrac
offShort2 = tpMode == "ATR" ? tpAtrM2 * atrAtShort : entryOfShort * slPctFrac * 2
offShort3 = tpMode == "ATR" ? tpAtrM3 * atrAtShort : entryOfShort * slPctFrac * 3

stopLossForLong  = entryOfLong  - riskLong
stopLossForShort = entryOfShort + riskShort
tpLong1  = entryOfLong  + offLong1
tpLong2  = entryOfLong  + offLong2
tpLong3  = entryOfLong  + offLong3
tpShort1 = entryOfShort - offShort1
tpShort2 = entryOfShort - offShort2
tpShort3 = entryOfShort - offShort3

rrLong1  = riskLong  != 0 ? offLong1  / riskLong  : na
rrLong2  = riskLong  != 0 ? offLong2  / riskLong  : na
rrLong3  = riskLong  != 0 ? offLong3  / riskLong  : na
rrShort1 = riskShort != 0 ? offShort1 / riskShort : na
rrShort2 = riskShort != 0 ? offShort2 / riskShort : na
rrShort3 = riskShort != 0 ? offShort3 / riskShort : na

pctLong1  = entryOfLong  != 0 ? offLong1  / entryOfLong  * 100 : na
pctLong2  = entryOfLong  != 0 ? offLong2  / entryOfLong  * 100 : na
pctLong3  = entryOfLong  != 0 ? offLong3  / entryOfLong  * 100 : na
pctShort1 = entryOfShort != 0 ? offShort1 / entryOfShort * 100 : na
pctShort2 = entryOfShort != 0 ? offShort2 / entryOfShort * 100 : na
pctShort3 = entryOfShort != 0 ? offShort3 / entryOfShort * 100 : na

long_sl      = hasLevels and low  < stopLossForLong  and pos[1] ==  1
short_sl     = hasLevels and high > stopLossForShort and pos[1] == -1
tpLongFinal  = hasLevels and high > tpLong3  and pos[1] ==  1
tpShortFinal = hasLevels and low  < tpShort3 and pos[1] == -1

if long_sl or short_sl or tpLongFinal or tpShortFinal
    pos := 0.0

// Cloud + signal shapes -------------------------------------------------------
smaSrcHigh = ta.ema(high, cloud_val)
smaSrcLow  = ta.ema(low,  cloud_val)
[macdLine, signalLine, histLine] = ta.macd(close, 12, 26, 9)

plotHigh = plot(showCloud ? smaSrcHigh : na, "Cloud High", color = na, editable = false)
plotLow  = plot(showCloud ? smaSrcLow  : na, "Cloud Low",  color = na, editable = false)

plotshape(longCond and emit ? up : na,                     title = "UpTrend Begins",   location = location.belowbar, style = shape.circle,  size = size.tiny, color = color.new(color.teal, 50))
plotshape(longCond and showBuySell and emit ? up : na,     title = "Buy",              location = location.belowbar, style = shape.labelup, size = size.tiny, color = color.new(color.teal, 50), text = "Buy",  textcolor = color.white)
plotshape(shortCond and emit ? dn : na,                    title = "DownTrend Begins", location = location.abovebar, style = shape.circle,  size = size.tiny, color = color.new(color.red, 50))
plotshape(shortCond and showBuySell and emit ? dn : na,    title = "Sell",             location = location.abovebar, style = shape.labeldown, size = size.tiny, color = color.new(color.red, 50), text = "Sell", textcolor = color.white)

fill(plotHigh, plotLow, color = macdLine > 0 ? color.new(color.aqua, 85) : macdLine < 0 ? color.new(color.red, 85) : na, title = "MACD Cloud")

// =============================================================================
//                             CISD ENGINE (neo)
// =============================================================================
lineStyle = styleOption == "Dotted (┈)" ? line.style_dotted : styleOption == "Dashed (╌)" ? line.style_dashed : line.style_solid

type MarketStructure
    float topPrice
    float bottomPrice
    bool  isBullish

type cisd
    line  level
    label txt
    bool  completed

var MarketStructure currentStructure = MarketStructure.new(0, 0, false)
var cisdLevelsBu = array.new<cisd>()
var cisdLevelsBe = array.new<cisd>()

var bool   isBullishPullback    = false
var bool   isBearishPullback    = false
var float  potentialTopPrice    = na
var float  potentialBottomPrice = na
var int    bullishBreakIndex    = na
var int    bearishBreakIndex    = na
var int    cisdState            = 0        // 0 = none, 1 = bull, -1 = bear
var string confMethod           = "none"

bearishPullbackDetected = close[1] > open[1]
bullishPullbackDetected = close[1] < open[1]

if bearishPullbackDetected and not isBearishPullback
    isBearishPullback := true
    potentialTopPrice := open[1]
    bullishBreakIndex := bar_index[1]

if bullishPullbackDetected and not isBullishPullback
    isBullishPullback := true
    potentialBottomPrice := open[1]
    bearishBreakIndex := bar_index[1]

if isBullishPullback
    if open < potentialBottomPrice
        potentialBottomPrice := open
        bearishBreakIndex := bar_index
    if (close < open) and (open > potentialBottomPrice)
        potentialBottomPrice := open
        bearishBreakIndex := bar_index

if isBearishPullback
    if open > potentialTopPrice
        potentialTopPrice := open
        bullishBreakIndex := bar_index
    if (close > open) and open < potentialTopPrice
        potentialTopPrice := open
        bullishBreakIndex := bar_index

// Structure break - bearish
if low < currentStructure.bottomPrice
    currentStructure.bottomPrice := low
    currentStructure.isBullish := false
    if isBearishPullback and (bar_index - bullishBreakIndex != 0)
        currentStructure.topPrice := math.max(high[bar_index - bullishBreakIndex], high[bar_index - bullishBreakIndex + 1])
        isBearishPullback := false
        bearishLine  = line.new(bullishBreakIndex, potentialTopPrice, bar_index + lookAheadBars, potentialTopPrice, color = bullishBreakColor, width = lineWidth, style = lineStyle)
        bearishLabel = label.new(bar_index + lookAheadBars, potentialTopPrice, bullStr, color = color.new(color.white, 100), textcolor = bullishBreakColor, style = label.style_label_left, size = size.small, text_formatting = text.format_italic)
        cisdLevelsBe.push(cisd.new(bearishLine, bearishLabel, false))
    else if close[1] > open[1] and close < open
        currentStructure.topPrice := high[1]
        isBearishPullback := false
        bearishLine  = line.new(bullishBreakIndex, potentialTopPrice, bar_index + lookAheadBars, potentialTopPrice, color = bullishBreakColor, width = lineWidth, style = lineStyle)
        bearishLabel = label.new(bar_index + lookAheadBars, potentialTopPrice, bullStr, color = color.new(color.white, 100), textcolor = bullishBreakColor, style = label.style_label_left, size = size.small, text_formatting = text.format_italic)
        cisdLevelsBe.push(cisd.new(bearishLine, bearishLabel, false))

// Structure break - bullish
if high > currentStructure.topPrice
    currentStructure.isBullish := true
    currentStructure.topPrice := high
    if isBullishPullback and (bar_index - bearishBreakIndex != 0)
        currentStructure.bottomPrice := math.min(low[bar_index - bearishBreakIndex], low[bar_index - bearishBreakIndex + 1])
        isBullishPullback := false
        bullishLine  = line.new(bearishBreakIndex, potentialBottomPrice, bar_index + lookAheadBars, potentialBottomPrice, color = bearishBreakColor, width = lineWidth, style = lineStyle)
        bullishLabel = label.new(bar_index + lookAheadBars, potentialBottomPrice, bearStr, color = color.new(color.white, 100), textcolor = bearishBreakColor, style = label.style_label_left, size = size.small, text_formatting = text.format_italic)
        cisdLevelsBu.push(cisd.new(bullishLine, bullishLabel, false))
    else if close[1] < open[1] and close > open
        currentStructure.bottomPrice := low[1]
        isBullishPullback := false
        bullishLine  = line.new(bearishBreakIndex, potentialBottomPrice, bar_index + lookAheadBars, potentialBottomPrice, color = bearishBreakColor, width = lineWidth, style = lineStyle)
        bullishLabel = label.new(bar_index + lookAheadBars, potentialBottomPrice, bearStr, color = color.new(color.white, 100), textcolor = bearishBreakColor, style = label.style_label_left, size = size.small, text_formatting = text.format_italic)
        cisdLevelsBu.push(cisd.new(bullishLine, bullishLabel, false))

if array.size(cisdLevelsBu) > 1 and not keepLevels
    old = array.shift(cisdLevelsBu)
    line.delete(old.level)
    label.delete(old.txt)

if array.size(cisdLevelsBe) > 1 and not keepLevels
    old = array.shift(cisdLevelsBe)
    line.delete(old.level)
    label.delete(old.txt)

bullCisdFormed = false
bearCisdFormed = false

// Bearish confirmation: price closes DOWN through a bullish-origin level.
if array.size(cisdLevelsBu) >= 1
    latest = array.get(cisdLevelsBu, 0)
    lvl    = line.get_y2(latest.level)
    if not latest.completed
        rngOk   = high > low
        strongS = close < lvl and rngOk and (high - close) / (high - low) >= closePct
        twoS    = useTwoClose and close < lvl and close[1] < lvl
        if strongS or twoS
            latest.completed := true
            line.set_x2(latest.level, bar_index)
            label.set_x(latest.txt, bar_index)
            bearCisdFormed := true
            confMethod := strongS ? "50% close" : "2-bar"
            bearishLine  = line.new(bullishBreakIndex, potentialTopPrice, bar_index + lookAheadBars, potentialTopPrice, color = bullishBreakColor, width = lineWidth, style = lineStyle)
            bearishLabel = label.new(bar_index + lookAheadBars, potentialTopPrice, bullStr, color = color.new(color.white, 100), textcolor = bullishBreakColor, style = label.style_label_left, size = size.small, text_formatting = text.format_italic)
            cisdLevelsBe.push(cisd.new(bearishLine, bearishLabel, false))
            cisdState := -1
        else
            line.set_x2(latest.level, bar_index + lookAheadBars)
            label.set_x(latest.txt, bar_index + lookAheadBars)

// Bullish confirmation: price closes UP through a bearish-origin level.
if array.size(cisdLevelsBe) >= 1
    latest = array.get(cisdLevelsBe, 0)
    lvl    = line.get_y2(latest.level)
    if not latest.completed
        rngOk   = high > low
        strongB = close > lvl and rngOk and (close - low) / (high - low) >= closePct
        twoB    = useTwoClose and close > lvl and close[1] > lvl
        if strongB or twoB
            latest.completed := true
            line.set_x2(latest.level, bar_index)
            label.set_x(latest.txt, bar_index)
            bullCisdFormed := true
            confMethod := strongB ? "50% close" : "2-bar"
            bullishLine  = line.new(bearishBreakIndex, potentialBottomPrice, bar_index + lookAheadBars, potentialBottomPrice, color = bearishBreakColor, width = lineWidth, style = lineStyle)
            bullishLabel = label.new(bar_index + lookAheadBars, potentialBottomPrice, bearStr, color = color.new(color.white, 100), textcolor = bearishBreakColor, style = label.style_label_left, size = size.small, text_formatting = text.format_italic)
            cisdLevelsBu.push(cisd.new(bullishLine, bullishLabel, false))
            cisdState := 1
        else
            line.set_x2(latest.level, bar_index + lookAheadBars)
            label.set_x(latest.txt, bar_index + lookAheadBars)

if bearCisdFormed and alertsOn
    alert("Bearish CISD Formed (" + confMethod + ")", alert.freq_once_per_bar_close)
if bullCisdFormed and alertsOn
    alert("Bullish CISD Formed (" + confMethod + ")", alert.freq_once_per_bar_close)

// =============================================================================
//                          CONFLUENCE + SIGNALS
// =============================================================================
trendBull    = trend == 1
cisdBull     = cisdState == 1
cisdBear     = cisdState == -1
alignedLong  = trendBull and cisdBull
alignedShort = (not trendBull) and cisdBear

goLong  = alignedLong  and not alignedLong[1]
goShort = alignedShort and not alignedShort[1]

if markConfirm and bullCisdFormed and emit
    label.new(bar_index, low,  confMethod, yloc = yloc.belowbar, style = label.style_label_up,   color = confBullColor, textcolor = color.white, size = size.small)
if markConfirm and bearCisdFormed and emit
    label.new(bar_index, high, confMethod, yloc = yloc.abovebar, style = label.style_label_down, color = confBearColor, textcolor = color.white, size = size.small)
bgcolor(confBgHilite and bullCisdFormed and emit ? color.new(confBullColor, 85) : confBgHilite and bearCisdFormed and emit ? color.new(confBearColor, 85) : na, title = "CISD confirmation candle")

// =============================================================================
//                        STRENGTH SCORE (single-timeframe setup quality)
// =============================================================================
var int lastCisdBar = na
if bullCisdFormed or bearCisdFormed
    lastCisdBar := bar_index

candidateDir = alignedLong ? 1 : alignedShort ? -1 : (trendBull ? 1 : -1)
isAligned    = alignedLong or alignedShort
cisdMatches  = (candidateDir == 1 and cisdBull) or (candidateDir == -1 and cisdBear)

scAlign = isAligned ? 40.0 : (cisdState == 0 ? 12.0 : 0.0)
scConf  = not cisdMatches ? 0.0 : confMethod == "50% close" ? 20.0 : confMethod == "2-bar" ? 12.0 : 0.0
histRising = histLine > histLine[1]
scMom = candidateDir == 1 ? ((histLine > 0 ? 10.0 : 0.0) + (histRising ? 5.0 : 0.0)) : ((histLine < 0 ? 10.0 : 0.0) + (not histRising ? 5.0 : 0.0))
aboveHi = close > smaSrcHigh
aboveLo = close > smaSrcLow
scCloud = candidateDir == 1 ? (aboveHi ? 10.0 : aboveLo ? 5.0 : 0.0) : (not aboveLo ? 10.0 : not aboveHi ? 5.0 : 0.0)
rrCand = candidateDir == 1 ? rrLong1 : rrShort1
scRR = na(rrCand) ? 0.0 : rrCand >= 2 ? 10.0 : rrCand >= 1 ? 6.0 : rrCand >= 0.5 ? 3.0 : 0.0
barsSince = na(lastCisdBar) ? na : bar_index - lastCisdBar
scFresh = na(barsSince) ? 0.0 : barsSince <= 3 ? 5.0 : barsSince <= 6 ? 3.0 : barsSince <= 10 ? 1.0 : 0.0

confScore = scAlign + scConf + scMom + scCloud + scRR + scFresh
confGrade = confScore >= 90 ? "A+" : confScore >= 80 ? "A" : confScore >= 70 ? "B" : confScore >= 60 ? "C" : confScore >= 50 ? "D" : "F"

// =============================================================================
//                        CONFIDENCE SCORE (trust in the read)
// =============================================================================
htfLiveRaw  = request.security(syminfo.tickerid, confHTF, trend,    lookahead = barmerge.lookahead_off)
htfPrevRaw  = request.security(syminfo.tickerid, confHTF, trend[1], lookahead = barmerge.lookahead_off)
htfTrendRaw = htfConfirmed ? htfPrevRaw : htfLiveRaw
htfKnown = not na(htfTrendRaw)
htfBull  = htfTrendRaw == 1
cfHtf = not htfKnown ? 20.0 : candidateDir == 1 ? (htfBull ? 40.0 : 0.0) : (not htfBull ? 40.0 : 0.0)

trendFlip = trend != trend[1]
var int lastFlipBar = na
if trendFlip
    lastFlipBar := bar_index
barsSinceFlip = na(lastFlipBar) ? bar_index : bar_index - lastFlipBar
flipCount = math.sum(trendFlip ? 1 : 0, 20)
cfPersist = (barsSinceFlip >= 10 ? 15.0 : barsSinceFlip >= 5 ? 9.0 : barsSinceFlip >= 2 ? 4.0 : 0.0) + (flipCount <= 1 ? 10.0 : flipCount <= 3 ? 5.0 : 0.0)

atrFast  = ta.atr(14)
atrSlow  = ta.sma(atrFast, 50)
atrRatio = atrSlow != 0 ? atrFast / atrSlow : na
cfVol = na(atrRatio) ? 10.0 : atrRatio <= 1.0 ? 20.0 : atrRatio <= 1.3 ? 14.0 : atrRatio <= 1.7 ? 8.0 : 0.0

cloudMid = (smaSrcHigh + smaSrcLow) / 2
extAtr = atrFast != 0 ? math.abs(close - cloudMid) / atrFast : na
cfLoc = na(extAtr) ? 7.0 : extAtr <= 1.5 ? 15.0 : extAtr <= 3.0 ? 9.0 : extAtr <= 5.0 ? 4.0 : 0.0

confidence = cfHtf + cfPersist + cfVol + cfLoc
confLabel  = confidence >= 75 ? "High" : confidence >= 50 ? "Med" : "Low"

// =============================================================================
//                              SIGNAL FILTER
// =============================================================================
gradeFloor     = minGrade == "A+" ? 90 : minGrade == "A" ? 80 : minGrade == "B" ? 70 : minGrade == "C" ? 60 : minGrade == "D" ? 50 : 0
strengthPass   = confScore  >= gradeFloor
confidencePass = confidence >= minConf
passFilter = filterMode == "Off (display only)" ? true : filterMode == "Strength only" ? strengthPass : filterMode == "Confidence only" ? confidencePass : filterMode == "Both required" ? (strengthPass and confidencePass) : (strengthPass or confidencePass)

goLongF  = goLong  and passFilter
goShortF = goShort and passFilter

plotchar(showGoSig and goLongF  and emit ? low  : na, title = "GO LONG",  char = "▲", location = location.belowbar, color = color.green, size = size.small, text = "GO LONG",  textcolor = color.green)
plotchar(showGoSig and goShortF and emit ? high : na, title = "GO SHORT", char = "▼", location = location.abovebar, color = color.red,   size = size.small, text = "GO SHORT", textcolor = color.red)
plotchar(showGoSig and goLong  and not passFilter and emit ? low  : na, title = "GO LONG blocked",  char = "×", location = location.belowbar, color = color.new(color.gray, 30), size = size.tiny)
plotchar(showGoSig and goShort and not passFilter and emit ? high : na, title = "GO SHORT blocked", char = "×", location = location.abovebar, color = color.new(color.gray, 30), size = size.tiny)

alertcondition(goLongF,    "GO LONG (aligned)",  "Trend + CISD aligned BULLISH (passed filter)")
alertcondition(goShortF,   "GO SHORT (aligned)", "Trend + CISD aligned BEARISH (passed filter)")
alertcondition(buySignal,  "Trend Buy",          "Trend flipped bullish")
alertcondition(sellSignal, "Trend Sell",         "Trend flipped bearish")

// Consolidated GO alert: one alert() with full trade context. Levels are
// computed from the signal bar's close, matching the outcome-log entry model.
// Fires once per bar close, so it never fires on a live-bar signal that later
// vanishes - independent of the display confirm toggle.
f_px(x) => str.tostring(math.round(x * 100) / 100)
if goAlertOn and hasLevels and (goLongF or goShortF)
    dA   = goLongF ? 1 : -1
    eA   = close
    rkA  = tpMode == "ATR" ? tpAtrStop * tpAtr : eA * slPctFrac
    if not na(rkA) and rkA > 0
        oA1  = tpMode == "ATR" ? tpAtrM1 * tpAtr : eA * slPctFrac * 1
        oA2  = tpMode == "ATR" ? tpAtrM2 * tpAtr : eA * slPctFrac * 2
        oA3  = tpMode == "ATR" ? tpAtrM3 * tpAtr : eA * slPctFrac * 3
        stA  = dA == 1 ? eA - rkA : eA + rkA
        aA1  = dA == 1 ? eA + oA1 : eA - oA1
        aA2  = dA == 1 ? eA + oA2 : eA - oA2
        aA3  = dA == 1 ? eA + oA3 : eA - oA3
        msg  = "Royalty GO " + (dA == 1 ? "LONG" : "SHORT") + " - " + syminfo.ticker + " " + timeframe.period + "\n" + "Grade " + confGrade + " (" + str.tostring(int(math.round(confScore))) + ")  Conf " + confLabel + " (" + str.tostring(int(math.round(confidence))) + "%)\n" + "Entry " + f_px(eA) + "  Stop " + f_px(stA) + "\n" + "TP " + f_px(aA1) + " / " + f_px(aA2) + " / " + f_px(aA3)
        alert(msg, alert.freq_once_per_bar_close)

// =============================================================================
//                          OUTCOME LOG ENGINE (expectancy)
// =============================================================================
// Logs every raw aligned GO (pre-filter) at its close with Strength grade and
// Confidence tier, then simulates it forward under the chosen exit model on
// confirmed bars. R multiples are derived per trade from actual offsets, so the
// math is correct in both Percent and ATR modes. Stop-first on same-bar ties.
exitModel = exitModelIn == "All out at TP1" ? 1 : exitModelIn == "Runner to TP3 (fixed stop)" ? 2 : 0

type Trade
    int   dir
    float entry
    float risk
    float stop
    float tp1
    float tp2
    float tp3
    float r1
    float r2
    float r3
    int   stage      // 0 open, 1 past TP1, 2 past TP2, 3 done
    float banked
    int   gradeIdx
    int   confTier
    int   model      // 0 scale-thirds, 1 all-out-TP1, 2 runner-TP3

// Simulate one bar for a trade under its own exit model. Mutates
// stop/stage/banked (reference). Returns [finalized, totalR].
procTrade(Trade t) =>
    fin = false
    tR  = 0.0
    stopR   = t.dir == 1 ? (t.stop - t.entry) / t.risk : (t.entry - t.stop) / t.risk
    remFrac = t.model != 0 ? 1.0 : (t.stage == 0 ? 1.0 : t.stage == 1 ? 2.0 / 3.0 : 1.0 / 3.0)
    stopHit = t.dir == 1 ? low <= t.stop : high >= t.stop
    if stopHit
        tR  := t.banked + remFrac * stopR
        fin := true
    else if t.model == 1
        if (t.dir == 1 ? high >= t.tp1 : low <= t.tp1)
            tR  := t.r1
            fin := true
    else if t.model == 2
        if (t.dir == 1 ? high >= t.tp3 : low <= t.tp3)
            tR  := t.r3
            fin := true
    else
        if t.stage == 0 and (t.dir == 1 ? high >= t.tp1 : low <= t.tp1)
            t.banked := t.banked + (1.0 / 3.0) * t.r1
            t.stop   := t.entry
            t.stage  := 1
        if t.stage == 1 and (t.dir == 1 ? high >= t.tp2 : low <= t.tp2)
            t.banked := t.banked + (1.0 / 3.0) * t.r2
            t.stop   := t.tp1
            t.stage  := 2
        if t.stage == 2 and (t.dir == 1 ? high >= t.tp3 : low <= t.tp3)
            t.banked := t.banked + (1.0 / 3.0) * t.r3
            t.stage  := 3
            tR  := t.banked
            fin := true
    [fin, tR]

var array<Trade> trades = array.new<Trade>()
var array<int>   gN     = array.new_int(6, 0)     // A+ A B C D F
var array<float> gSum   = array.new_float(6, 0.0)
var array<int>   gWin   = array.new_int(6, 0)
var array<int>   cN     = array.new_int(3, 0)     // High Med Low
var array<float> cSum   = array.new_float(3, 0.0)
var array<int>   cWin   = array.new_int(3, 0)

// per-model equity accumulators (index 0 scale-thirds, 1 TP1, 2 runner)
var array<int>   mN     = array.new_int(3, 0)
var array<float> mSum   = array.new_float(3, 0.0)   // Net R (== sum of R); Exp = mSum/mN
var array<int>   mWin   = array.new_int(3, 0)
var array<float> mCum   = array.new_float(3, 0.0)   // running equity in R
var array<float> mPeak  = array.new_float(3, 0.0)   // running peak equity
var array<float> mMaxDD = array.new_float(3, 0.0)   // max drawdown magnitude (R)
var array<float> mGW    = array.new_float(3, 0.0)   // gross win R
var array<float> mGL    = array.new_float(3, 0.0)   // gross loss R (abs)

if barstate.isconfirmed
    // 1) simulate pending trades on this bar
    if array.size(trades) > 0
        for i = array.size(trades) - 1 to 0
            t = array.get(trades, i)
            [fin, tr] = procTrade(t)
            if fin
                w  = tr > 0 ? 1 : 0
                mi = t.model
                // per-model equity accumulators
                array.set(mN,   mi, array.get(mN,   mi) + 1)
                array.set(mSum, mi, array.get(mSum, mi) + tr)
                array.set(mWin, mi, array.get(mWin, mi) + w)
                newCum = array.get(mCum, mi) + tr
                array.set(mCum, mi, newCum)
                if newCum > array.get(mPeak, mi)
                    array.set(mPeak, mi, newCum)
                dd = array.get(mPeak, mi) - newCum
                if dd > array.get(mMaxDD, mi)
                    array.set(mMaxDD, mi, dd)
                if tr > 0
                    array.set(mGW, mi, array.get(mGW, mi) + tr)
                else
                    array.set(mGL, mi, array.get(mGL, mi) - tr)
                // per-bucket table follows the selected exit model only
                if mi == exitModel
                    array.set(gN,   t.gradeIdx, array.get(gN,   t.gradeIdx) + 1)
                    array.set(gSum, t.gradeIdx, array.get(gSum, t.gradeIdx) + tr)
                    array.set(gWin, t.gradeIdx, array.get(gWin, t.gradeIdx) + w)
                    array.set(cN,   t.confTier, array.get(cN,   t.confTier) + 1)
                    array.set(cSum, t.confTier, array.get(cSum, t.confTier) + tr)
                    array.set(cWin, t.confTier, array.get(cWin, t.confTier) + w)
                array.remove(trades, i)
    // 2) log a fresh aligned GO (raw, pre-filter). Enter at close.
    if hasLevels and (goLong or goShort)
        dirG   = goLong ? 1 : -1
        entryG = close
        riskG  = tpMode == "ATR" ? tpAtrStop * tpAtr : entryG * slPctFrac
        if not na(riskG) and riskG > 0
            off1  = tpMode == "ATR" ? tpAtrM1 * tpAtr : entryG * slPctFrac * 1
            off2  = tpMode == "ATR" ? tpAtrM2 * tpAtr : entryG * slPctFrac * 2
            off3  = tpMode == "ATR" ? tpAtrM3 * tpAtr : entryG * slPctFrac * 3
            stopG = dirG == 1 ? entryG - riskG : entryG + riskG
            t1G   = dirG == 1 ? entryG + off1 : entryG - off1
            t2G   = dirG == 1 ? entryG + off2 : entryG - off2
            t3G   = dirG == 1 ? entryG + off3 : entryG - off3
            gIdx  = confGrade == "A+" ? 0 : confGrade == "A" ? 1 : confGrade == "B" ? 2 : confGrade == "C" ? 3 : confGrade == "D" ? 4 : 5
            cTier = confidence >= 75 ? 0 : confidence >= 50 ? 1 : 2
            for m = 0 to 2
                array.push(trades, Trade.new(dirG, entryG, riskG, stopG, t1G, t2G, t3G, off1 / riskG, off2 / riskG, off3 / riskG, 0, 0.0, gIdx, cTier, m))

// =============================================================================
//                       ENTRY / SL / TP VISUALIZATION
// =============================================================================
var line  lnEntry = na
var line  lnStop  = na
var line  lnTp1   = na
var line  lnTp2   = na
var line  lnTp3   = na
var label lbEntry = na
var label lbStop  = na
var label lbTp1   = na
var label lbTp2   = na
var label lbTp3   = na

if showTPSL and barstate.islast and pos != 0 and hasLevels
    entryColor = pos == 1 ? color.blue : color.purple
    ePx  = pos == 1 ? entryOfLong     : entryOfShort
    sPx  = pos == 1 ? stopLossForLong : stopLossForShort
    t1   = pos == 1 ? tpLong1 : tpShort1
    t2   = pos == 1 ? tpLong2 : tpShort2
    t3   = pos == 1 ? tpLong3 : tpShort3
    r1   = pos == 1 ? rrLong1 : rrShort1
    r2   = pos == 1 ? rrLong2 : rrShort2
    r3   = pos == 1 ? rrLong3 : rrShort3
    p1   = pos == 1 ? pctLong1 : pctShort1
    p2   = pos == 1 ? pctLong2 : pctShort2
    p3   = pos == 1 ? pctLong3 : pctShort3
    d1   = pos == 1 ? offLong1 : offShort1
    d2   = pos == 1 ? offLong2 : offShort2
    d3   = pos == 1 ? offLong3 : offShort3
    sDist = pos == 1 ? riskLong : riskShort
    sPctV = pos == 1 ? riskLong / entryOfLong * 100 : riskShort / entryOfShort * 100
    xIdx = int(pos == 1 ? lindex : sindex)

    line.delete(lnEntry)
    line.delete(lnStop)
    line.delete(lnTp1)
    line.delete(lnTp2)
    line.delete(lnTp3)
    label.delete(lbEntry)
    label.delete(lbStop)
    label.delete(lbTp1)
    label.delete(lbTp2)
    label.delete(lbTp3)

    lnEntry := line.new(bar_index, ePx, xIdx, ePx, color = entryColor)
    lnStop  := line.new(bar_index, sPx, xIdx, sPx, color = color.red)
    lnTp1   := line.new(bar_index, t1,  xIdx, t1,  color = color.green)
    lnTp2   := line.new(bar_index, t2,  xIdx, t2,  color = color.green)
    lnTp3   := line.new(bar_index, t3,  xIdx, t3,  color = color.green)

    lbEntry := label.new(bar_index, ePx, "Entry Price: " + str.tostring(math.round(ePx * 100) / 100), color = entryColor, textcolor = color.white, style = label.style_label_left)
    lbStop  := label.new(bar_index, sPx, "🛑 Stop Loss Price: " + str.tostring(math.round(sPx * 100) / 100) + "  (-" + str.tostring(math.round(sPctV * 100) / 100) + "%  -$" + str.tostring(math.round(sDist * 100) / 100) + ")", color = color.red, textcolor = color.white, style = label.style_label_left)
    lbTp1   := label.new(bar_index, t1, "🎯 TP1 Take Profit: " + str.tostring(math.round(t1 * 100) / 100) + "  (+" + str.tostring(math.round(p1 * 100) / 100) + "%  +$" + str.tostring(math.round(d1 * 100) / 100) + "  " + str.tostring(math.round(r1 * 10) / 10) + "R)", color = color.green, textcolor = color.white, style = label.style_label_left)
    lbTp2   := label.new(bar_index, t2, "🎯 TP2 Take Profit: " + str.tostring(math.round(t2 * 100) / 100) + "  (+" + str.tostring(math.round(p2 * 100) / 100) + "%  +$" + str.tostring(math.round(d2 * 100) / 100) + "  " + str.tostring(math.round(r2 * 10) / 10) + "R)", color = color.green, textcolor = color.white, style = label.style_label_left)
    lbTp3   := label.new(bar_index, t3, "🎯 TP3 Take Profit: " + str.tostring(math.round(t3 * 100) / 100) + "  (+" + str.tostring(math.round(p3 * 100) / 100) + "%  +$" + str.tostring(math.round(d3 * 100) / 100) + "  " + str.tostring(math.round(r3 * 10) / 10) + "R)", color = color.green, textcolor = color.white, style = label.style_label_left)

// =============================================================================
//                              THEME PALETTE (shared by both tables)
// =============================================================================
dashPos = dashPosInp == "Top Left" ? position.top_left : dashPosInp == "Bottom Right" ? position.bottom_right : dashPosInp == "Bottom Left" ? position.bottom_left : dashPosInp == "Middle Right" ? position.middle_right : position.top_right
dashSize = dashSizeIn == "Tiny" ? size.tiny : dashSizeIn == "Small" ? size.small : dashSizeIn == "Large" ? size.large : size.normal

isFut     = dashTheme == "Futuristic (HUD)"
dashFont  = isFut ? font.family_monospace : font.family_default
panelBg   = isFut ? color.new(#0A0E1A, 0)  : chart.bg_color
frameCol  = isFut ? color.new(#00E5FF, 30) : color.gray
borderCol = isFut ? color.new(#12324A, 20) : color.gray
txtMain   = isFut ? #C7D6F0 : color.white
labTxt    = isFut ? #7E93B8 : color.white
labBg     = isFut ? color.new(#0F1D33, 0)  : na
hdrBg     = isFut ? color.new(#0E1B2E, 0)  : color.new(color.blue, 30)
hdrTxt    = isFut ? #00E5FF : color.white
valHal    = isFut ? text.align_right : text.align_center
labHal    = isFut ? text.align_left  : text.align_center

bullC = isFut ? #00FFA3 : color.new(color.teal, 0)
bearC = isFut ? #FF3B6B : color.new(color.red,  0)
noneC = isFut ? #4A5B7A : color.new(color.gray, 0)
grnC  = isFut ? #00FFA3 : color.new(color.green, 0)
ambC  = isFut ? #FFC048 : color.new(color.orange, 20)

// =============================================================================
//                              OUTCOME-LOG TABLE (expectancy)
// =============================================================================
f_num(n)        => str.tostring(n)
f_avg(sm, n)    => n > 0 ? sm / n : na
f_expTxt(a)     => na(a) ? "–" : (a >= 0 ? "+" : "") + str.tostring(math.round(a * 100) / 100) + "R"
f_wrTxt(w, n)   => n > 0 ? str.tostring(math.round(w / n * 100)) + "%" : "–"
f_r1Txt(x)      => (x >= 0 ? "+" : "") + str.tostring(math.round(x * 10) / 10) + "R"
f_ddTxt(x, n)   => n > 0 ? "-" + str.tostring(math.round(x * 10) / 10) + "R" : "–"
f_pfTxt(gw, gl) => gl > 0 ? str.tostring(math.round(gw / gl * 100) / 100) : (gw > 0 ? "∞" : "–")

statsPosR = statsPos == "Bottom Right" ? position.bottom_right : statsPos == "Top Left" ? position.top_left : statsPos == "Top Right" ? position.top_right : statsPos == "Middle Right" ? position.middle_right : position.bottom_left

var table stats = na
if showStats and barstate.islast
    if na(stats)
        stats := table.new(statsPosR, 4, 11, bgcolor = panelBg, border_color = borderCol, border_width = 1, frame_color = frameCol, frame_width = isFut ? 2 : 1)

    gradeNames = array.from("A+", "A", "B", "C", "D", "F")
    confNames  = array.from("High", "Med", "Low")
    modeTag    = exitModel == 1 ? "TP1" : exitModel == 2 ? "Run" : "1/3s"
    oN   = array.sum(gN)
    oSum = array.sum(gSum)
    oWin = array.sum(gWin)

    rr = 0
    table.cell(stats, 0, rr, (isFut ? "◢ OUTCOME · " : "Outcome · ") + modeTag, text_color = hdrTxt, text_size = dashSize, bgcolor = hdrBg, text_font_family = dashFont, text_halign = labHal)
    table.cell(stats, 1, rr, "N",    text_color = hdrTxt, text_size = dashSize, bgcolor = hdrBg, text_font_family = dashFont, text_halign = valHal)
    table.cell(stats, 2, rr, "Exp",  text_color = hdrTxt, text_size = dashSize, bgcolor = hdrBg, text_font_family = dashFont, text_halign = valHal)
    table.cell(stats, 3, rr, "Win%", text_color = hdrTxt, text_size = dashSize, bgcolor = hdrBg, text_font_family = dashFont, text_halign = valHal)
    rr := rr + 1

    oAvg = f_avg(oSum, oN)
    oCol = na(oAvg) ? noneC : oAvg >= 0.1 ? grnC : oAvg <= -0.1 ? bearC : ambC
    table.cell(stats, 0, rr, isFut ? "ALL" : "Overall", text_color = txtMain, text_size = dashSize, bgcolor = labBg, text_font_family = dashFont, text_halign = labHal)
    table.cell(stats, 1, rr, f_num(oN), text_color = txtMain, text_size = dashSize, bgcolor = na, text_font_family = dashFont, text_halign = valHal)
    table.cell(stats, 2, rr, f_expTxt(oAvg), text_color = isFut ? oCol : txtMain, text_size = dashSize, bgcolor = isFut ? na : oCol, text_font_family = dashFont, text_halign = valHal)
    table.cell(stats, 3, rr, f_wrTxt(oWin, oN), text_color = txtMain, text_size = dashSize, bgcolor = na, text_font_family = dashFont, text_halign = valHal)
    rr := rr + 1

    for gi = 0 to 5
        n   = array.get(gN, gi)
        sm  = array.get(gSum, gi)
        w   = array.get(gWin, gi)
        a   = f_avg(sm, n)
        col = na(a) ? noneC : a >= 0.1 ? grnC : a <= -0.1 ? bearC : ambC
        table.cell(stats, 0, rr, array.get(gradeNames, gi), text_color = txtMain, text_size = dashSize, bgcolor = labBg, text_font_family = dashFont, text_halign = labHal)
        table.cell(stats, 1, rr, f_num(n), text_color = txtMain, text_size = dashSize, bgcolor = na, text_font_family = dashFont, text_halign = valHal)
        table.cell(stats, 2, rr, f_expTxt(a), text_color = isFut ? col : txtMain, text_size = dashSize, bgcolor = isFut ? na : col, text_font_family = dashFont, text_halign = valHal)
        table.cell(stats, 3, rr, f_wrTxt(w, n), text_color = txtMain, text_size = dashSize, bgcolor = na, text_font_family = dashFont, text_halign = valHal)
        rr := rr + 1

    for ci = 0 to 2
        n   = array.get(cN, ci)
        sm  = array.get(cSum, ci)
        w   = array.get(cWin, ci)
        a   = f_avg(sm, n)
        col = na(a) ? noneC : a >= 0.1 ? grnC : a <= -0.1 ? bearC : ambC
        table.cell(stats, 0, rr, array.get(confNames, ci), text_color = txtMain, text_size = dashSize, bgcolor = labBg, text_font_family = dashFont, text_halign = labHal)
        table.cell(stats, 1, rr, f_num(n), text_color = txtMain, text_size = dashSize, bgcolor = na, text_font_family = dashFont, text_halign = valHal)
        table.cell(stats, 2, rr, f_expTxt(a), text_color = isFut ? col : txtMain, text_size = dashSize, bgcolor = isFut ? na : col, text_font_family = dashFont, text_halign = valHal)
        table.cell(stats, 3, rr, f_wrTxt(w, n), text_color = txtMain, text_size = dashSize, bgcolor = na, text_font_family = dashFont, text_halign = valHal)
        rr := rr + 1

// =============================================================================
//                      MODEL-COMPARE TABLE (all three exits)
// =============================================================================
comparePosR = comparePos == "Top Right" ? position.top_right : comparePos == "Bottom Left" ? position.bottom_left : comparePos == "Bottom Right" ? position.bottom_right : comparePos == "Middle Right" ? position.middle_right : position.top_left

var table cmp = na
if showCompare and barstate.islast
    if na(cmp)
        cmp := table.new(comparePosR, 6, 4, bgcolor = panelBg, border_color = borderCol, border_width = 1, frame_color = frameCol, frame_width = isFut ? 2 : 1)

    mNames = array.from(isFut ? "1/3s" : "Scale⅓", "TP1", isFut ? "Run" : "Runner")

    table.cell(cmp, 0, 0, isFut ? "◢ MODEL" : "Model", text_color = hdrTxt, text_size = dashSize, bgcolor = hdrBg, text_font_family = dashFont, text_halign = labHal)
    table.cell(cmp, 1, 0, "N",     text_color = hdrTxt, text_size = dashSize, bgcolor = hdrBg, text_font_family = dashFont, text_halign = valHal)
    table.cell(cmp, 2, 0, "Exp",   text_color = hdrTxt, text_size = dashSize, bgcolor = hdrBg, text_font_family = dashFont, text_halign = valHal)
    table.cell(cmp, 3, 0, "NetR",  text_color = hdrTxt, text_size = dashSize, bgcolor = hdrBg, text_font_family = dashFont, text_halign = valHal)
    table.cell(cmp, 4, 0, "MaxDD", text_color = hdrTxt, text_size = dashSize, bgcolor = hdrBg, text_font_family = dashFont, text_halign = valHal)
    table.cell(cmp, 5, 0, "PF",    text_color = hdrTxt, text_size = dashSize, bgcolor = hdrBg, text_font_family = dashFont, text_halign = valHal)

    for mm = 0 to 2
        n   = array.get(mN, mm)
        net = array.get(mSum, mm)
        dd  = array.get(mMaxDD, mm)
        gw  = array.get(mGW, mm)
        gl  = array.get(mGL, mm)
        a   = f_avg(net, n)
        pf  = gl > 0 ? gw / gl : na
        expC = na(a) ? noneC : a >= 0.1 ? grnC : a <= -0.1 ? bearC : ambC
        netC = n <= 0 ? noneC : net > 0.1 ? grnC : net < -0.1 ? bearC : ambC
        ddC  = n > 0 ? bearC : noneC
        pfC  = n <= 0 ? noneC : na(pf) ? grnC : pf >= 1.1 ? grnC : pf <= 0.9 ? bearC : ambC
        sel   = mm == exitModel
        rowBg = sel ? (isFut ? color.new(#12324A, 20) : color.new(color.blue, 75)) : labBg
        lblTxt = (sel ? "▸ " : "") + array.get(mNames, mm)

        table.cell(cmp, 0, mm + 1, lblTxt, text_color = txtMain, text_size = dashSize, bgcolor = rowBg, text_font_family = dashFont, text_halign = labHal)
        table.cell(cmp, 1, mm + 1, f_num(n), text_color = txtMain, text_size = dashSize, bgcolor = na, text_font_family = dashFont, text_halign = valHal)
        table.cell(cmp, 2, mm + 1, f_expTxt(a), text_color = isFut ? expC : txtMain, text_size = dashSize, bgcolor = isFut ? na : expC, text_font_family = dashFont, text_halign = valHal)
        table.cell(cmp, 3, mm + 1, n > 0 ? f_r1Txt(net) : "–", text_color = isFut ? netC : txtMain, text_size = dashSize, bgcolor = isFut ? na : (n > 0 ? netC : na), text_font_family = dashFont, text_halign = valHal)
        table.cell(cmp, 4, mm + 1, f_ddTxt(dd, n), text_color = isFut ? ddC : txtMain, text_size = dashSize, bgcolor = isFut ? na : (n > 0 ? ddC : na), text_font_family = dashFont, text_halign = valHal)
        table.cell(cmp, 5, mm + 1, n > 0 ? f_pfTxt(gw, gl) : "–", text_color = isFut ? pfC : txtMain, text_size = dashSize, bgcolor = isFut ? na : (n > 0 ? pfC : na), text_font_family = dashFont, text_halign = valHal)

// =============================================================================
//                              DASHBOARD TABLE
// =============================================================================
var table dash = na
if showDash and barstate.islast
    nRows = 11 + (showStrength ? 1 : 0) + (showConfidence ? 1 : 0) + (showFilterRow ? 1 : 0)
    if na(dash)
        dash := table.new(dashPos, 2, nRows, bgcolor = panelBg, border_color = borderCol, border_width = 1, frame_color = frameCol, frame_width = isFut ? 2 : 1)

    showLv   = pos != 0 and hasLevels
    verdictC = alignedLong ? bullC : alignedShort ? bearC : noneC
    ePx      = pos == 1 ? entryOfLong     : pos == -1 ? entryOfShort     : na
    sPx      = pos == 1 ? stopLossForLong : pos == -1 ? stopLossForShort : na
    tp1      = pos == 1 ? tpLong1 : pos == -1 ? tpShort1 : na
    tp2      = pos == 1 ? tpLong2 : pos == -1 ? tpShort2 : na
    tp3      = pos == 1 ? tpLong3 : pos == -1 ? tpShort3 : na
    tpTxt    = showLv ? str.tostring(math.round(tp1 * 100) / 100) + " / " + str.tostring(math.round(tp2 * 100) / 100) + " / " + str.tostring(math.round(tp3 * 100) / 100) : "–"
    rr1      = pos == 1 ? rrLong1 : pos == -1 ? rrShort1 : na
    rr2      = pos == 1 ? rrLong2 : pos == -1 ? rrShort2 : na
    rr3      = pos == 1 ? rrLong3 : pos == -1 ? rrShort3 : na
    rrTxt    = showLv ? str.tostring(math.round(rr1 * 10) / 10) + "R / " + str.tostring(math.round(rr2 * 10) / 10) + "R / " + str.tostring(math.round(rr3 * 10) / 10) + "R" : "–"
    pc1      = pos == 1 ? pctLong1 : pos == -1 ? pctShort1 : na
    pc2      = pos == 1 ? pctLong2 : pos == -1 ? pctShort2 : na
    pc3      = pos == 1 ? pctLong3 : pos == -1 ? pctShort3 : na
    pctTxt   = showLv ? "+" + str.tostring(math.round(pc1 * 10) / 10) + "% / +" + str.tostring(math.round(pc2 * 10) / 10) + "% / +" + str.tostring(math.round(pc3 * 10) / 10) + "%" : "–"

    cisdCol  = cisdState == 1 ? bullC : cisdState == -1 ? bearC : noneC
    confirmC = confMethod == "none" ? noneC : (cisdState == 1 ? grnC : bearC)

    scoreStr = str.tostring(int(math.round(confScore)))
    fillN    = math.max(0, math.min(10, int(math.round(confScore / 10))))
    meter    = (fillN > 0 ? str.repeat("█", fillN) : "") + (10 - fillN > 0 ? str.repeat("░", 10 - fillN) : "")
    strengthC = confScore >= 80 ? grnC : confScore >= 70 ? (isFut ? #00E5FF : color.new(color.green, 40)) : confScore >= 60 ? ambC : confScore >= 50 ? (isFut ? #FF8A00 : color.new(color.orange, 0)) : bearC

    confPctStr = str.tostring(int(math.round(confidence)))
    fillC      = math.max(0, math.min(10, int(math.round(confidence / 10))))
    meterC     = (fillC > 0 ? str.repeat("▮", fillC) : "") + (10 - fillC > 0 ? str.repeat("▯", 10 - fillC) : "")
    confTierC  = confidence >= 75 ? grnC : confidence >= 50 ? ambC : bearC

    modeShort    = filterMode == "Off (display only)" ? "Off" : filterMode == "Strength only" ? "Strength" : filterMode == "Confidence only" ? "Confidence" : filterMode == "Both required" ? "Both" : "Either"
    filterActive = filterMode != "Off (display only)"
    filterBase   = not filterActive ? modeShort : modeShort + " · " + (passFilter ? "PASS" : "BLOCK")
    filterC      = not filterActive ? noneC : (passFilter ? grnC : bearC)

    trendTxt    = isFut ? (trendBull ? "▲ BULLISH" : "▼ BEARISH") : (trendBull ? "Bullish" : "Bearish")
    trendCol    = trendBull ? bullC : bearC
    cisdTxt     = isFut ? (cisdState == 1 ? "▲ BULL" : cisdState == -1 ? "▼ BEAR" : "◆ NONE") : (cisdState == 1 ? "Bullish" : cisdState == -1 ? "Bearish" : "none")
    confirmTxt  = isFut ? str.upper(confMethod) : confMethod
    verdictTxt  = isFut ? (alignedLong ? "▲ LONG" : alignedShort ? "▼ SHORT" : "✕ CONFLICT") : (alignedLong ? "LONG ✓" : alignedShort ? "SHORT ✓" : "CONFLICT ✗")
    posTxt      = isFut ? (pos == 1 ? "▲ LONG" : pos == -1 ? "▼ SHORT" : "— FLAT") : (pos == 1 ? "LONG" : pos == -1 ? "SHORT" : "FLAT")
    posCol      = pos == 1 ? bullC : pos == -1 ? bearC : noneC
    strengthTxt = isFut ? (strDetail == "Grade" ? confGrade + " " + meter : strDetail == "Score" ? meter + " " + scoreStr : confGrade + " " + meter + " " + scoreStr) : (strDetail == "Grade" ? confGrade : strDetail == "Score" ? scoreStr : confGrade + "  (" + scoreStr + ")")
    confRowTxt  = isFut ? (confPctStr + "% " + meterC) : (confLabel + " (" + confPctStr + "%)")
    filterTxt   = isFut ? (str.upper(filterBase) + (filterActive ? (passFilter ? " ✓" : " ✗") : "")) : filterBase

    titleTxt = isFut ? "◢ ROYALTY T+CISD" : "Royalty T+CISD"
    symTxt   = isFut ? str.upper(syminfo.ticker) + " · " + timeframe.period : syminfo.ticker + " " + timeframe.period

    r = 0
    table.cell(dash, 0, r, titleTxt, text_color = hdrTxt, text_size = dashSize, bgcolor = hdrBg, text_font_family = dashFont, text_halign = labHal)
    table.cell(dash, 1, r, symTxt,   text_color = hdrTxt, text_size = dashSize, bgcolor = hdrBg, text_font_family = dashFont, text_halign = valHal)
    r := r + 1

    table.cell(dash, 0, r, "Trend", text_color = labTxt, text_size = dashSize, bgcolor = labBg, text_font_family = dashFont, text_halign = labHal)
    table.cell(dash, 1, r, trendTxt, text_color = isFut ? trendCol : txtMain, text_size = dashSize, bgcolor = isFut ? na : trendCol, text_font_family = dashFont, text_halign = valHal)
    r := r + 1

    table.cell(dash, 0, r, "CISD", text_color = labTxt, text_size = dashSize, bgcolor = labBg, text_font_family = dashFont, text_halign = labHal)
    table.cell(dash, 1, r, cisdTxt, text_color = isFut ? cisdCol : txtMain, text_size = dashSize, bgcolor = isFut ? na : cisdCol, text_font_family = dashFont, text_halign = valHal)
    r := r + 1

    table.cell(dash, 0, r, "Confirm", text_color = labTxt, text_size = dashSize, bgcolor = labBg, text_font_family = dashFont, text_halign = labHal)
    table.cell(dash, 1, r, confirmTxt, text_color = isFut ? confirmC : txtMain, text_size = dashSize, bgcolor = isFut ? na : confirmC, text_font_family = dashFont, text_halign = valHal)
    r := r + 1

    table.cell(dash, 0, r, "Verdict", text_color = labTxt, text_size = dashSize, bgcolor = labBg, text_font_family = dashFont, text_halign = labHal)
    table.cell(dash, 1, r, verdictTxt, text_color = isFut ? verdictC : txtMain, text_size = dashSize, bgcolor = isFut ? na : verdictC, text_font_family = dashFont, text_halign = valHal)
    r := r + 1

    if showStrength
        table.cell(dash, 0, r, "Strength", text_color = labTxt, text_size = dashSize, bgcolor = labBg, text_font_family = dashFont, text_halign = labHal)
        table.cell(dash, 1, r, strengthTxt, text_color = isFut ? strengthC : txtMain, text_size = dashSize, bgcolor = isFut ? na : strengthC, text_font_family = dashFont, text_halign = valHal)
        r := r + 1

    if showConfidence
        table.cell(dash, 0, r, "Confidence", text_color = labTxt, text_size = dashSize, bgcolor = labBg, text_font_family = dashFont, text_halign = labHal)
        table.cell(dash, 1, r, confRowTxt, text_color = isFut ? confTierC : txtMain, text_size = dashSize, bgcolor = isFut ? na : confTierC, text_font_family = dashFont, text_halign = valHal)
        r := r + 1

    if showFilterRow
        table.cell(dash, 0, r, "Filter", text_color = labTxt, text_size = dashSize, bgcolor = labBg, text_font_family = dashFont, text_halign = labHal)
        table.cell(dash, 1, r, filterTxt, text_color = isFut ? filterC : txtMain, text_size = dashSize, bgcolor = isFut ? na : filterC, text_font_family = dashFont, text_halign = valHal)
        r := r + 1

    table.cell(dash, 0, r, "Position", text_color = labTxt, text_size = dashSize, bgcolor = labBg, text_font_family = dashFont, text_halign = labHal)
    table.cell(dash, 1, r, posTxt, text_color = isFut ? posCol : txtMain, text_size = dashSize, bgcolor = na, text_font_family = dashFont, text_halign = valHal)
    r := r + 1

    table.cell(dash, 0, r, "Entry", text_color = labTxt, text_size = dashSize, bgcolor = labBg, text_font_family = dashFont, text_halign = labHal)
    table.cell(dash, 1, r, pos != 0 ? str.tostring(math.round(ePx * 100) / 100) : "–", text_color = txtMain, text_size = dashSize, bgcolor = na, text_font_family = dashFont, text_halign = valHal)
    r := r + 1

    table.cell(dash, 0, r, "Stop", text_color = labTxt, text_size = dashSize, bgcolor = labBg, text_font_family = dashFont, text_halign = labHal)
    table.cell(dash, 1, r, showLv ? str.tostring(math.round(sPx * 100) / 100) : "–", text_color = txtMain, text_size = dashSize, bgcolor = na, text_font_family = dashFont, text_halign = valHal)
    r := r + 1

    table.cell(dash, 0, r, "TP " + tpMode, text_color = labTxt, text_size = dashSize, bgcolor = labBg, text_font_family = dashFont, text_halign = labHal)
    table.cell(dash, 1, r, tpTxt, text_color = txtMain, text_size = dashSize, bgcolor = na, text_font_family = dashFont, text_halign = valHal)
    r := r + 1

    table.cell(dash, 0, r, "R:R", text_color = labTxt, text_size = dashSize, bgcolor = labBg, text_font_family = dashFont, text_halign = labHal)
    table.cell(dash, 1, r, rrTxt, text_color = txtMain, text_size = dashSize, bgcolor = na, text_font_family = dashFont, text_halign = valHal)
    r := r + 1

    table.cell(dash, 0, r, "% from Entry", text_color = labTxt, text_size = dashSize, bgcolor = labBg, text_font_family = dashFont, text_halign = labHal)
    table.cell(dash, 1, r, pctTxt, text_color = txtMain, text_size = dashSize, bgcolor = na, text_font_family = dashFont, text_halign = valHal)
````
