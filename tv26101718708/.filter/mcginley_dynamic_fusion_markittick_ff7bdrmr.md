# McGinley Dynamic Fusion [MarkitTick]

- url: https://www.tradingview.com/script/FF7bdrMr-McGinley-Dynamic-Fusion-MarkitTick/
- type: indicator
- pine_id: PUB;f6876a225d6a4647ae32a56140661a5d
- version: 1.0

## Description

💡 The McGinley Dynamic is a lesser-known adaptive moving average developed in the 1990s by market technician John R. McGinley, specifically engineered to solve a problem that plagues conventional moving averages: their tendency to lag badly during fast market moves while whipsawing excessively during slow, choppy conditions. Unlike a standard EMA or SMA, the McGinley Dynamic adjusts its own speed automatically based on the relationship between price and its prior value, effectively "hugging" price more tightly when the market accelerates and smoothing out more when it decelerates. This script builds a complete trading framework around a Fast/Slow McGinley Dynamic crossover, layering in higher-timeframe confirmation, signal cooldown filtering, ATR-adaptive trade levels, a live dashboard, and a manual signal-lock mechanism.

[b]✨ Originality and Utility[/b]
While McGinley Dynamic implementations exist on TradingView, this script does not simply plot the raw indicator. It combines four distinct engineering layers into a single decision framework:

[list]
[*]A recursively self-adjusting dual McGinley Dynamic engine (Fast and Slow) used as a crossover trigger rather than a static trend line.
[*]An optional higher-timeframe directional filter that requires the HTF trend to agree with the signal direction before a crossover is allowed to fire.
[*]A cooldown/gap filter measured in bars, which suppresses new signals for a configurable number of bars after the last one, reducing signal clustering during choppy crossover conditions.
[*]An ATR-based trade management layer that auto-plots Entry, Stop Loss, and three Take Profit levels the moment a signal fires, extended live on the chart with a color-coded risk/reward fill.
[/list]

The value to traders lies in how these layers interact: the McGinley crossover alone would generate frequent false signals in ranging markets, but the HTF filter and cooldown mechanism specifically target the crossover's greatest weakness (over-triggering during consolidation), while the ATR trade-level engine converts a raw directional signal into a fully defined, risk-quantified trade plan without any additional charting work from the user.

[b]🔬 Methodology and Concepts[/b]
[image]https://www.tradingview.com/x/s3Q9t64d/[/image]
[b]• The McGinley Dynamic Engine[/b]
The core building block is a recursive moving average that adjusts its step size relative to how far price has moved away from its previous value. Rather than applying a fixed weighting like an EMA, the McGinley Dynamic divides the price-to-prior-value distance by a dynamic denominator that grows sharply when price moves far from the average and shrinks when price sits close to it. This produces a curve that speeds up during trending, high-momentum moves and slows down during sideways congestion, giving it a self-correcting quality that fixed-period moving averages lack. The script instantiates two independent copies of this engine: a Fast McGinley Dynamic (default length 14) and a Slow McGinley Dynamic (default length 50), each with its own configurable "K Constant" that governs how aggressively the adaptive denominator reacts to price displacement.

[b]• Crossover Signal Logic[/b]
A long signal is generated when the Fast McGinley Dynamic closes above the Slow McGinley Dynamic after having been at or below it on the prior two bars — a confirmed upward crossover, not an intrabar or provisional one. A short signal mirrors this logic on the downside. This two-bar confirmation approach (checking both the [1] and [2] offsets) ensures the crossover has actually completed on a closed bar before a signal is registered, rather than reacting to a crossover that could still repaint on the current forming bar.

[b]• Higher-Timeframe Directional Filter[/b]
When enabled, the script pulls the source price and Fast McGinley Dynamic value from a user-selected higher timeframe (default 4-hour) and requires that the HTF price sit on the correct side of the HTF Fast McGinley Dynamic before allowing a same-direction signal on the working timeframe. This acts as a macro-trend veto: a bullish crossover on the chart timeframe will be ignored if the higher-timeframe trend context is bearish, and vice versa. The higher-timeframe request is built using a confirmed, prior-bar value combined with TradingView's lookahead-on merge policy — the standard non-repainting pattern for pulling higher-timeframe data — so the filter reacts only to fully closed higher-timeframe bars.

[b]• Cooldown / Signal Spacing Filter[/b]
To prevent rapid-fire signals during periods where the Fast and Slow McGinley Dynamic lines oscillate around each other, the script tracks the bar index of the last long and last short signal separately. A new signal in the same direction is only permitted once a user-defined minimum number of bars ("Cooldown Bars") has elapsed since the prior one, reducing signal noise without altering the underlying crossover logic itself.

[b]• ATR-Based Trade Level Construction[/b]
The moment a qualifying signal fires, the script calculates an Average True Range value over a configurable lookback and uses it to derive five reference prices: an entry (the prior bar's close), a stop loss, and three take-profit targets. Each level is expressed as an ATR multiple away from entry, with independently configurable multipliers for the stop and each take-profit tier. This means the distance between entry and each level automatically expands or contracts with recent volatility rather than using a fixed point or percentage distance, keeping the risk/reward structure proportionate to current market conditions.

[b]• Signal Lock[/b]
The optional Lock Signal feature freezes the currently displayed trade levels once toggled on, preventing them from being overwritten by a subsequent crossover. This is useful for traders who want to manually track a single active setup on the chart without the lines and labels shifting each time a new signal condition is technically met.

[b]🎨 Visual Guide[/b]
[image]https://www.tradingview.com/x/pgJCCs7b/[/image]
[list]
[*]Fast MD line (default blue) — the fast-length McGinley Dynamic.
[*]Slow MD line (default orange) — the slow-length McGinley Dynamic.
[*]Heatmap Candles — when enabled, candle bodies and wicks are recolored based on trend bias: teal/green when the Fast MD sits above the Slow MD (bullish bias), red when below (bearish bias), independent of the raw candle color.
[*]Entry line (dashed, blue by default) — plotted at the close of the bar prior to signal confirmation, marking the reference entry price.
[*]Stop Loss line (solid, red by default) — the ATR-derived stop level, labeled with an "✕ SL" tag showing the exact price.
[*]Take Profit lines (dashed, teal by default, three tiers with increasing opacity) — TP1, TP2, and TP3, each labeled with its price.
[*]Risk fill — a shaded region between the entry line and stop-loss line, tinted in the stop-loss color, visually representing the risk portion of the trade.
[*]Reward fill — a shaded region between the entry line and the TP3 line, tinted in the take-profit color, visually representing the potential reward span.
[*]All trade-level lines and labels extend live to the right edge of the chart until superseded by a new signal or, if Signal Lock is active, held in place.
[*]📌 Note : the best way to resolve visual overlap is to navigate to the Object Tree and drag the indicator above the main chart layer, or simply hide the native candles in your chart settings.
[/list]

[b]📖 How to Use[/b]
[image]https://www.tradingview.com/x/6vSmvyf0/[/image]
[list]
[*]A bullish signal occurs when the Fast MD confirms a crossover above the Slow MD, subject to the HTF filter and cooldown filter both being satisfied. The dashboard's Bias row will read "▲ Bull".
[*]A bearish signal occurs on the mirrored downward crossover, with the Bias row reading "▼ Bear".
[*]When a signal fires, use the auto-plotted Entry, SL, and TP1/TP2/TP3 lines as a starting framework for trade structure — the R:R progress bar on the dashboard shows the reward-to-risk ratio for TP1 relative to the stop distance.
[*]The MD Gap row on the dashboard visualizes, as a percentage bar, how far apart the Fast and Slow MD lines currently are, which can help gauge trend strength or an approaching crossover.
[*]Enabling the HTF Filter is recommended for traders who want signals to align with a broader trend context rather than trading every local crossover.
[*]Enabling Signal Lock freezes the current trade plan on screen, useful when manually managing an active position and wanting to prevent the levels from updating on the next crossover.
[/list]

[b]⚙️ Inputs and Settings[/b]
[list]
[*]Src / Fast N / Slow N — source price and the lookback lengths for the Fast and Slow McGinley Dynamic calculations. Shorter lengths react faster but generate more signals; longer lengths are smoother but slower to confirm.
[*]K Const — governs how aggressively the McGinley Dynamic's adaptive denominator responds to price displacement from the prior value. Higher values slow the line's responsiveness.
[*]HTF Filter / HTF TF — enables the higher-timeframe directional veto and sets which higher timeframe is used for that check.
[*]Cooldown Bars — minimum number of bars required between two signals of the same direction.
[*]Lock Signal — freezes the current trade levels in place, blocking updates from subsequent signals.
[*]ATR Len — lookback length for the Average True Range used to size the SL and TP levels.
[*]SL Mult / TP1 Mult / TP2 Mult / TP3 Mult — ATR multipliers that set the distance of the stop loss and each take-profit tier from the entry price.
[*]Heatmap Candles / Trade Levels — visual toggles for the bias-colored candles and the auto-plotted trade-level lines/labels/fills.
[*]Show Dash / Dash Pos — toggles the on-chart dashboard and sets its screen position.
[*]Alert action fields (Long/Short/Close Long/Close Short) — customizable string values embedded into the script's JSON alert payloads, allowing the fired alerts to be mapped to specific automation or webhook actions.
[/list]

[b]🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]
The McGinley Dynamic belongs to a broader family of adaptive-smoothing techniques in technical analysis that attempt to address a structural weakness of fixed-weight moving averages: a constant smoothing factor cannot simultaneously be fast enough to track trending markets and slow enough to filter noise in ranging markets. McGinley's original design achieves adaptivity by making the effective smoothing constant a function of the ratio between current price and the prior average value raised to the fourth power — a formulation that causes the adjustment factor to grow disproportionately large when price diverges sharply from the average, automatically accelerating the line's response, and to shrink toward a baseline when price and average are close, automatically slowing the response. This self-referential feedback mechanism places the McGinley Dynamic conceptually closer to adaptive filters used in signal processing (where a filter's gain is modulated by the magnitude of recent error) than to the fixed-coefficient exponential smoothing used in a standard EMA.

The dual-length crossover structure applied here draws on the well-established moving-average-crossover framework from technical trend-following literature, where the relationship between a fast and slow-adaptive series is used as a proxy for shifting momentum regimes, conceptually related to dual-moving-average systems and change-point detection approaches that flag a regime shift once a fast-reacting series diverges from a slow-reacting baseline. The higher-timeframe confirmation layer reflects the top-down, multi-timeframe analysis principle common in technical trading methodology, where signals on a lower timeframe are treated as more reliable when they align with the prevailing direction on a higher timeframe, reducing the frequency of signals that run counter to the dominant trend. Finally, the ATR-scaled trade-level construction is grounded in volatility-normalized position and risk sizing, a standard practice in quantitative trade management where stop and target distances are expressed as a multiple of recent realized volatility (via Average True Range) rather than fixed price or percentage distances, ensuring risk parameters adapt to the current volatility regime rather than remaining static across changing market conditions.

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick
//@version=6
indicator("McGinley Dynamic Fusion [MarkitTick]", overlay=true, max_lines_count=500, max_labels_count=500)
// ── INPUTS ──────────────────────────────────────────────────────
var string GRP_CORE = "⚙️ Core"
i_src        = input.source(close, "Src", group=GRP_CORE)
i_lenFast    = input.int(14, "Fast N", minval=1, group=GRP_CORE)
i_lenSlow    = input.int(50, "Slow N", minval=1, group=GRP_CORE)
i_constant   = input.float(4.0, "K Const", minval=0.1, step=0.1, group=GRP_CORE, tooltip="")
var string GRP_FILT = "🕯️ Filters"
i_useHtf     = input.bool(false, "HTF Filter", group=GRP_FILT)
i_htf        = input.timeframe("240", "HTF TF", group=GRP_FILT)
i_minGap     = input.int(3, "Cooldown Bars", minval=0, group=GRP_FILT)
var string GRP_TRADE = "📐 Trade Tools"
i_lockSignal = input.bool(false, "🔒 Lock Signal", group=GRP_TRADE, tooltip="Freeze current signal · block new ones")
i_atrLen     = input.int(14, "ATR Len", minval=1, group=GRP_TRADE)
i_slMult     = input.float(1.5, "SL Mult", minval=0.1, step=0.1, group=GRP_TRADE)
i_tp1Mult    = input.float(1.0, "TP1 Mult", minval=0.1, step=0.1, group=GRP_TRADE)
i_tp2Mult    = input.float(2.0, "TP2 Mult", minval=0.1, step=0.1, group=GRP_TRADE)
i_tp3Mult    = input.float(3.0, "TP3 Mult", minval=0.1, step=0.1, group=GRP_TRADE)
var string GRP_VIS = "🎨 Visuals"
i_showCandles = input.bool(true, "Heatmap Candles", group=GRP_VIS)
i_showLevels  = input.bool(true, "Trade Levels", group=GRP_VIS)
var string _mt741a = "📊 Dashboard"
i_showDash   = input.bool(true, "Show Dash", group=_mt741a)
i_dashPos    = input.string("Top Right", "Dash Pos", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=_mt741a)
var string GRP_WH = "🔔 Alerts"
i_actionLong       = input.string("long",      "↑ Long Action",       group=GRP_WH)
i_actionShort      = input.string("short",     "↓ Short Action",      group=GRP_WH)
i_actionCloseLong  = input.string("closelong", "✕ Close Long Action", group=GRP_WH)
i_actionCloseShort = input.string("closeshort","✕ Close Short Action",group=GRP_WH)
var string GRP_COL = "🌈 Colors"
c_mdFast     = input.color(#2196f3, "Fast MD", group=GRP_COL)
c_mdSlow     = input.color(#f9a825, "Slow MD", group=GRP_COL)
c_bullBody   = input.color(#26a69a, "Bull Body", group=GRP_COL)
c_bearBody   = input.color(#ef5350, "Bear Body", group=GRP_COL)
c_bullBorder = input.color(#26a69a, "Bull Border", group=GRP_COL)
c_bearBorder = input.color(#ef5350, "Bear Border", group=GRP_COL)
c_slCol      = input.color(#ef5350, "SL Col", group=GRP_COL)
c_entryCol   = input.color(#2196f3, "Entry Col", group=GRP_COL)
c_tpCol      = input.color(#26a69a, "TP Col", group=GRP_COL)
C_DASH_HDR   = input.color(color.new(#3a2a6d, 55), "Dash Hdr", group=GRP_COL)
C_DASH_BG    = input.color(color.new(#0a0f1a, 10), "Dash BG", group=GRP_COL)
C_DASH_TXT   = input.color(#ffffff, "Dash Txt", group=GRP_COL)
C_SUP        = input.color(#26a69a, "Bull Val", group=GRP_COL)
C_RES        = input.color(#ef5350, "Bear Val", group=GRP_COL)
// ── CORE LOGIC ──────────────────────────────────────────────────
f_mcginley(float src, simple int len, float k) =>
    var float md = na
    smaVal = ta.sma(src, len)
    float denom = na(md[1]) or md[1] == 0 ? na : k * len * math.pow(src / md[1], 4)
    md := na(md[1]) ? smaVal : (na(denom) or denom == 0 ? md[1] : md[1] + (src - md[1]) / denom)
    md
mdFast = f_mcginley(i_src, i_lenFast, i_constant)
mdSlow = f_mcginley(i_src, i_lenSlow, i_constant)
htfSrcRaw = request.security(syminfo.tickerid, i_htf, i_src[1], lookahead=barmerge.lookahead_on)
htfMdRaw  = request.security(syminfo.tickerid, i_htf, mdFast[1], lookahead=barmerge.lookahead_on)
bool htfOkLong  = not i_useHtf or htfSrcRaw > htfMdRaw
bool htfOkShort = not i_useHtf or htfSrcRaw < htfMdRaw
bool crossUp   = mdFast[1] > mdSlow[1] and mdFast[2] <= mdSlow[2]
bool crossDown = mdFast[1] < mdSlow[1] and mdFast[2] >= mdSlow[2]
var int lastLongBarIdx  = na
var int lastShortBarIdx = na
bool gapOkLong  = na(lastLongBarIdx)  or (bar_index - lastLongBarIdx)  >= i_minGap
bool gapOkShort = na(lastShortBarIdx) or (bar_index - lastShortBarIdx) >= i_minGap
bool _rawLongSignal  = crossUp   and htfOkLong  and gapOkLong
bool _rawShortSignal = crossDown and htfOkShort and gapOkShort
bool longSignal  = _rawLongSignal
bool shortSignal = _rawShortSignal
if longSignal
    lastLongBarIdx := bar_index
if shortSignal
    lastShortBarIdx := bar_index
bool bullBias = mdFast > mdSlow
atrVal = ta.atr(i_atrLen)
var float entryPrice = na
var float slPrice    = na
var float tp1Price   = na
var float tp2Price   = na
var float tp3Price   = na
var int   lastSignalBar = na
var string lastDir = na
bool _mt741b = i_lockSignal and barstate.islast
if (longSignal or shortSignal) and not _mt741b
    entryPrice := close[1]
    if longSignal
        slPrice  := entryPrice - atrVal * i_slMult
        tp1Price := entryPrice + atrVal * i_tp1Mult
        tp2Price := entryPrice + atrVal * i_tp2Mult
        tp3Price := entryPrice + atrVal * i_tp3Mult
        lastDir  := "long"
    else
        slPrice  := entryPrice + atrVal * i_slMult
        tp1Price := entryPrice - atrVal * i_tp1Mult
        tp2Price := entryPrice - atrVal * i_tp2Mult
        tp3Price := entryPrice - atrVal * i_tp3Mult
        lastDir  := "short"
    lastSignalBar := bar_index
bool tp1Hit = lastDir == "long" ? high >= tp1Price : lastDir == "short" ? low <= tp1Price : false
bool tp2Hit = lastDir == "long" ? high >= tp2Price : lastDir == "short" ? low <= tp2Price : false
bool tp3Hit = lastDir == "long" ? high >= tp3Price : lastDir == "short" ? low <= tp3Price : false
// ── VISUALS ─────────────────────────────────────────────────────
plot(mdFast, "Fast MD", color=c_mdFast, linewidth=2)
plot(mdSlow, "Slow MD", color=c_mdSlow, linewidth=2)
bodyColor   = bullBias ? c_bullBody   : c_bearBody
borderColor = bullBias ? c_bullBorder : c_bearBorder
plotcandle(i_showCandles ? open : na, high, low, close,
 title       = "Heatmap Candles",
 color       = bodyColor,
 wickcolor   = borderColor,
 bordercolor = borderColor)
var line slLine = na
var line entryLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na
var label slLbl = na
var label entryLbl = na
var label tp1Lbl = na
var label tp2Lbl = na
var label tp3Lbl = na
var linefill riskFill = na
var linefill rewardFill = na
f_deleteLevels() =>
    line.delete(slLine)
    line.delete(entryLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)
    label.delete(slLbl)
    label.delete(entryLbl)
    label.delete(tp1Lbl)
    label.delete(tp2Lbl)
    label.delete(tp3Lbl)
    linefill.delete(riskFill)
    linefill.delete(rewardFill)
if i_showLevels and (longSignal or shortSignal) and not _mt741b
    f_deleteLevels()
    slLine    := line.new(bar_index, slPrice,    bar_index, slPrice,    color=c_slCol,  style=line.style_solid,  width=2)
    entryLine := line.new(bar_index, entryPrice, bar_index, entryPrice, color=c_entryCol, style=line.style_dashed, width=1)
    tp1Line   := line.new(bar_index, tp1Price,   bar_index, tp1Price,   color=color.new(c_tpCol, 40), style=line.style_dashed, width=1)
    tp2Line   := line.new(bar_index, tp2Price,   bar_index, tp2Price,   color=color.new(c_tpCol, 20), style=line.style_dashed, width=1)
    tp3Line   := line.new(bar_index, tp3Price,   bar_index, tp3Price,   color=color.new(c_tpCol, 0),  style=line.style_dashed, width=1)
    slLbl     := label.new(bar_index, slPrice,    "✕ SL "    + str.tostring(slPrice,    format.mintick), style=label.style_label_left, color=c_slCol,    textcolor=#ffffff, size=size.small)
    entryLbl  := label.new(bar_index, entryPrice, "▶ Entry " + str.tostring(entryPrice, format.mintick), style=label.style_label_left, color=c_entryCol, textcolor=#ffffff, size=size.small)
    tp1Lbl    := label.new(bar_index, tp1Price,   "◆ TP1 "   + str.tostring(tp1Price,   format.mintick), style=label.style_label_left, color=c_tpCol,    textcolor=#ffffff, size=size.small)
    tp2Lbl    := label.new(bar_index, tp2Price,   "✦ TP2 "   + str.tostring(tp2Price,   format.mintick), style=label.style_label_left, color=c_tpCol,    textcolor=#ffffff, size=size.small)
    tp3Lbl    := label.new(bar_index, tp3Price,   "◆ TP3 "   + str.tostring(tp3Price,   format.mintick), style=label.style_label_left, color=c_tpCol,    textcolor=#ffffff, size=size.small)
    riskFill   := linefill.new(slLine, entryLine, color.new(c_slCol, 80))
    rewardFill := linefill.new(entryLine, tp3Line, color.new(c_tpCol, 85))
if not na(slLine) and barstate.islast
    int _extX = i_lockSignal ? bar_index + 10 : last_bar_index + 10
    line.set_x2(slLine, _extX)
    line.set_x2(entryLine, _extX)
    line.set_x2(tp1Line, _extX)
    line.set_x2(tp2Line, _extX)
    line.set_x2(tp3Line, _extX)
    label.set_x(slLbl, _extX)
    label.set_x(entryLbl, _extX)
    label.set_x(tp1Lbl, _extX)
    label.set_x(tp2Lbl, _extX)
    label.set_x(tp3Lbl, _extX)
// ── ALERTS ──────────────────────────────────────────────────────
string _longInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long","entry":"{3}","sl":"{4}","tp":"{5}"',
     i_actionLong, syminfo.tickerid, timeframe.period,
     str.tostring(close[1], format.mintick),
     str.tostring(slPrice,  format.mintick),
     str.tostring(tp1Price, format.mintick))
string longPayload = "{" + _longInner + "}"
string _shortInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short","entry":"{3}","sl":"{4}","tp":"{5}"',
     i_actionShort, syminfo.tickerid, timeframe.period,
     str.tostring(close[1], format.mintick),
     str.tostring(slPrice,  format.mintick),
     str.tostring(tp1Price, format.mintick))
string shortPayload = "{" + _shortInner + "}"
string _closeLongInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"closelong"',
     i_actionCloseLong, syminfo.tickerid, timeframe.period)
string closeLongPayload = "{" + _closeLongInner + "}"
string _closeShortInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"closeshort"',
     i_actionCloseShort, syminfo.tickerid, timeframe.period)
string closeShortPayload = "{" + _closeShortInner + "}"
string _tp1Inner = str.format('"action":"tp1","ticker":"{0}","tf":"{1}","price":"{2}"', syminfo.tickerid, timeframe.period, str.tostring(tp1Price, format.mintick))
string tp1Payload = "{" + _tp1Inner + "}"
string _tp2Inner = str.format('"action":"tp2","ticker":"{0}","tf":"{1}","price":"{2}"', syminfo.tickerid, timeframe.period, str.tostring(tp2Price, format.mintick))
string tp2Payload = "{" + _tp2Inner + "}"
string _tp3Inner = str.format('"action":"tp3","ticker":"{0}","tf":"{1}","price":"{2}"', syminfo.tickerid, timeframe.period, str.tostring(tp3Price, format.mintick))
string tp3Payload = "{" + _tp3Inner + "}"
if longSignal and barstate.isconfirmed
    alert(longPayload, alert.freq_once_per_bar_close)
if shortSignal and barstate.isconfirmed
    alert(shortPayload, alert.freq_once_per_bar_close)
if shortSignal and barstate.isconfirmed
    alert(closeLongPayload, alert.freq_once_per_bar_close)
if longSignal and barstate.isconfirmed
    alert(closeShortPayload, alert.freq_once_per_bar_close)
if tp1Hit
    alert(tp1Payload, alert.freq_once_per_bar)
if tp2Hit
    alert(tp2Payload, alert.freq_once_per_bar)
if tp3Hit
    alert(tp3Payload, alert.freq_once_per_bar)
alertcondition(longSignal  and barstate.isconfirmed, "BUY Signal",         "MarkitTick — BUY Signal Fired")
alertcondition(shortSignal and barstate.isconfirmed, "SELL Signal",        "MarkitTick — SELL Signal Fired")
alertcondition(shortSignal and barstate.isconfirmed, "Close Long Signal",  "MarkitTick — Close Long")
alertcondition(longSignal  and barstate.isconfirmed, "Close Short Signal", "MarkitTick — Close Short")
// ── DASHBOARD ───────────────────────────────────────────────────
f_bar(float val, float maxVal, color clr) =>
    int filled = math.round(math.min(val / maxVal, 1.0) * 10)
    string bar = ""
    for i = 1 to 10
        bar += i <= filled ? "█" : "░"
    bar + "  " + str.tostring(math.round(val / maxVal * 100)) + "%"
f_barColor(float pct) =>
    pct >= 0.66 ? color.new(#26a69a, 0) : pct >= 0.33 ? color.new(#f9a825, 0) : color.new(#ef5350, 0)
_mt741c = i_dashPos == "Top Right" ? position.top_right : i_dashPos == "Top Left" ? position.top_left : i_dashPos == "Bottom Right" ? position.bottom_right : position.bottom_left
var table dash = table.new(_mt741c, 2, 9, border_width=1, border_color=color.new(#2a3040, 40), frame_width=1, frame_color=color.new(#3a2a6d, 40))
mdGapPct = mdSlow != 0 ? math.abs(mdFast - mdSlow) / mdSlow : 0.0
mdGapBarPct = math.min(mdGapPct * 100 / 2.0, 1.0)
rrVal = (not na(slPrice) and not na(entryPrice) and slPrice != entryPrice) ? math.abs(tp1Price - entryPrice) / math.abs(entryPrice - slPrice) : 0.0
row_a = C_DASH_BG
row_b = color.new(C_DASH_BG, 40)
if i_showDash
    table.cell(dash, 0, 0, "MD [MarkitTick]", text_color=C_DASH_TXT, text_halign=text.align_left, text_size=size.small, bgcolor=C_DASH_HDR)
    table.cell(dash, 1, 0, syminfo.ticker + "  ·  " + timeframe.period, text_color=C_DASH_TXT, text_halign=text.align_right, text_size=size.small, bgcolor=C_DASH_HDR)
    table.cell(dash, 0, 1, "  Lock", text_color=color.new(C_DASH_TXT, 25), text_halign=text.align_left, text_size=size.small, bgcolor=row_a)
    table.cell(dash, 1, 1, (i_lockSignal ? "ACTIVE" : "OFF") + "  ", text_color=i_lockSignal ? C_RES : C_DASH_TXT, text_halign=text.align_right, text_size=size.small, bgcolor=row_a)
    table.cell(dash, 0, 2, "  Bias", text_color=color.new(C_DASH_TXT, 25), text_halign=text.align_left, text_size=size.small, bgcolor=row_b)
    table.cell(dash, 1, 2, (bullBias ? "▲ Bull" : "▼ Bear") + "  ", text_color=bullBias ? C_SUP : C_RES, text_halign=text.align_right, text_size=size.small, bgcolor=row_b)
    table.cell(dash, 0, 3, "  Fast MD", text_color=color.new(C_DASH_TXT, 25), text_halign=text.align_left, text_size=size.small, bgcolor=row_a)
    table.cell(dash, 1, 3, str.tostring(mdFast, format.mintick) + "  ", text_color=C_DASH_TXT, text_halign=text.align_right, text_size=size.small, bgcolor=row_a)
    table.cell(dash, 0, 4, "  Slow MD", text_color=color.new(C_DASH_TXT, 25), text_halign=text.align_left, text_size=size.small, bgcolor=row_b)
    table.cell(dash, 1, 4, str.tostring(mdSlow, format.mintick) + "  ", text_color=C_DASH_TXT, text_halign=text.align_right, text_size=size.small, bgcolor=row_b)
    table.cell(dash, 0, 5, "  MD Gap", text_color=color.new(C_DASH_TXT, 25), text_halign=text.align_left, text_size=size.small, bgcolor=row_a)
    table.cell(dash, 1, 5, f_bar(mdGapBarPct, 1.0, f_barColor(mdGapBarPct)) + "  ", text_color=f_barColor(mdGapBarPct), text_halign=text.align_right, text_size=size.small, bgcolor=row_a)
    table.cell(dash, 0, 6, "  R:R (TP1)", text_color=color.new(C_DASH_TXT, 25), text_halign=text.align_left, text_size=size.small, bgcolor=row_b)
    table.cell(dash, 1, 6, f_bar(math.min(rrVal, 5.0), 5.0, f_barColor(math.min(rrVal, 5.0) / 5.0)) + "  ", text_color=f_barColor(math.min(rrVal, 5.0) / 5.0), text_halign=text.align_right, text_size=size.small, bgcolor=row_b)
    table.cell(dash, 0, 7, "  ATR", text_color=color.new(C_DASH_TXT, 25), text_halign=text.align_left, text_size=size.small, bgcolor=row_a)
    table.cell(dash, 1, 7, str.tostring(atrVal, format.mintick) + "  ", text_color=C_DASH_TXT, text_halign=text.align_right, text_size=size.small, bgcolor=row_a)
    table.cell(dash, 0, 8, "  Last Signal", text_color=color.new(C_DASH_TXT, 25), text_halign=text.align_left, text_size=size.small, bgcolor=row_b)
    table.cell(dash, 1, 8, (na(lastDir) ? "—" : lastDir == "long" ? "▲ Long" : "▼ Short") + "  ", text_color=na(lastDir) ? C_DASH_TXT : lastDir == "long" ? C_SUP : C_RES, text_halign=text.align_right, text_size=size.small, bgcolor=row_b)
````
