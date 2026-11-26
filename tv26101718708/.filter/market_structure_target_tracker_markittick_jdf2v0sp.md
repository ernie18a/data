# Market Structure Target Tracker [MarkitTick]

- url: https://www.tradingview.com/script/jDf2v0SP-Market-Structure-Target-Tracker-MarkitTick/
- type: indicator
- pine_id: PUB;db4b2cb3ba5a44ee8a6cb12592ca1c89
- version: 1.0

## Description

💡 An advanced, multi-faceted analytical suite designed for traders who rely on price action and logical trend progressions. By systematically identifying structural pivots in the market, this tool automatically maps out Break of Structure (BOS) and Change of Character (CHoCH) events. Rather than simply plotting support and resistance, it integrates a sophisticated risk-management framework directly onto the chart, calculating dynamic Entry, Stop Loss (SL), and multiple Take Profit (TP) levels based on market volatility. 

Price action trading requires constant vigilance to identify local maxima and minima. This script relieves the trader of manual chart marking by perpetually analyzing rolling windows of price data. When an established swing high or low is breached, the indicator locks in the structural shift, evaluates higher timeframe momentum to filter out false breakouts, and establishes a forward-looking target zone.

[b]✨ Originality and Utility[/b]

Most market structure indicators limit their functionality to placing historical labels on the chart. The originality of this script lies in its forward-looking, state-aware tracking mechanism. It operates not just as an indicator, but as a simulated trade management dashboard. 

Once a structural break occurs, the indicator shifts into an active tracking state. It dynamically projects Entry and SL/TP bands anchored to the breakout, using Average True Range (ATR) to adapt to the asset's current volatility. Furthermore, it continuously evaluates the life-cycle of the structural break, monitoring price action to determine if the target is successfully hit or if the setup is invalidated by an opposing swing breach. This level of state persistence provides traders with an objective, real-time assessment of trade feasibility, risk-to-reward ratios, and trend duration.

[b]🔬 Methodology and Concepts[/b]

The script is built upon four foundational technical concepts, woven together into a unified logic sequence:

[b]• Pivot Detection[/b]
The core engine scans for Pivot Highs and Pivot Lows. A Pivot High is confirmed when a specific bar's high is strictly greater than the highs of a defined number of bars both preceding and following it. This creates a fractal representation of market turning points.

[b]• Break of Structure (BOS)[/b]
A bullish structure break occurs when the closing price of a confirmed bar exceeds the most recent Pivot High. Conversely, a bearish break occurs when the close drops below the most recent Pivot Low. The script categorizes the first break in a new direction as a CHoCH, and subsequent continuous breaks as BOS.

[b]• Higher Timeframe (HTF) Alignment[/b]
To prevent trading against the dominant macroeconomic trend, the script optionally queries the Relative Strength Index (RSI) from a higher timeframe. If this filter is engaged, bullish breakouts are ignored unless the HTF RSI indicates bullish momentum, adding a crucial layer of directional confirmation.

[b]• Volatility-Adjusted Target Mapping[/b]
Upon a valid breakout, the script captures the current ATR. It then maps out a predefined trade setup. The Entry is plotted slightly past the breakout line, the Stop Loss is placed at a multiple of the ATR away from the entry, and up to three Take Profit levels are projected using independent ATR multipliers.

[b]🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]

The indicator translates discretionary price action theory into a strict, rule-based algorithmic framework grounded in discrete mathematics and statistical dispersion.

[b]• Local Extrema in Discrete Time Series[/b]
The pivot detection relies on the mathematical definition of local extrema within a bounded domain. For a given time series of high prices $H_t$, a local maximum is identified at time $t$ if $H_t \ge H_{t \pm k}$ for a defined neighborhood $k$ (the Swing Length). By anchoring structural logic to these extrema, the script removes the subjectivity of trendline drawing, relying strictly on empirical data points that define the boundaries of recent market equilibrium.

[b]• Measurement of Dispersion via True Range[/b]
The risk management module utilizes the Average True Range. The True Range ([symbol="NYSE:TR"]NYSE:TR[/symbol]$) is defined as the greatest of the following: the current high minus the current low, the absolute value of the current high minus the previous close, or the absolute value of the current low minus the previous close. The ATR is a smoothed moving average of this [symbol="NYSE:TR"]NYSE:TR[/symbol]$. In academic finance, variance and standard deviation are common measures of risk; however, ATR is particularly robust for trading applications as it accounts for overnight gaps and limits, providing a highly adaptive measurement of kinetic market energy to appropriately size stop-loss thresholds.

[b]• Relative Momentum Standardization[/b]
The Higher Timeframe filter utilizes the Relative Strength Index. The RSI standardizes the velocity of price movement onto a 0-100 scale by comparing the exponential moving average of recent gains to recent losses. By enforcing a rule where [symbol="NYSE:RSI"]NYSE:RSI[/symbol] > 50$ is required for bullish structural breaks, the algorithm mathematically demands that the higher-degree derivative of price (momentum) aligns with the lower-degree breakout, statistically reducing the probability of mean-reverting false breakouts.

[b]🎨 Visual Guide[/b]

The script provides a rich, non-intrusive visual overlay to keep the trader informed of all active states and historical context.

[b]• Structure Break Lines[/b]
[list]
[*] Dashed Green Lines: Indicate historical and active Bullish breakouts.
[*] Dashed Red Lines: Indicate historical and active Bearish breakouts.
[*] Trend Labels: Triangles and markers (▲ BOS / ▼ CHoCH) appear at the midpoint of the break line to clearly annotate the structural shift.
[/list]

[b]• Trade Projection Lines[/b]
When a break is active, a cluster of dashed lines projects to the right of the current price action:
[list]
[*] Blue Line (►): Proposed Entry level.
[*] Red Line (✕): Stop Loss level based on ATR.
[*] Green Lines (●, ★, ◆): Three tiered Take Profit targets based on escalating ATR multiples.
[/list]

[b]• The Heads-Up Dashboard[/b]
Located in the top right corner, this table is the operational nerve center. It displays:
[list]
[*] Asset Ticker and Current Trend status.
[*] HTF Direction and a visual block-bar representation of the HTF RSI.
[*] Active BOS Level and Target Status (⏳ Pending or ✓ Hit).
[*] Exact price coordinates for Entry, SL, and all TPs.
[*] The active Risk-to-Reward (R:R) ratio for the first target.
[*] Statistical tracking of Total BOS counts and the duration (in bars) of the active setup.
[/list]

[b]📖 How to Use[/b]

Traders can utilize this script as a complete ruleset for navigating trend continuations and reversals. 

When observing the chart, wait for the script to print a new BOS or CHoCH label. This signifies that a confirmed candle has closed beyond a significant structural pivot. If the HTF filter is enabled, this break already has the backing of higher timeframe momentum.

Once the break prints, look to the dashed projection lines and the dashboard. The dashboard will display exact coordinates for a theoretical trade setup. You can use the blue Entry line to plan limit orders or market execution upon pullbacks. Set your structural stop-loss according to the red SL line, and place limit orders to secure profits at the green TP lines. 

Monitor the Dashboard's "Tgt Status". If price action reverses heavily and crosses the opposing pivot point before reaching the target, the script will trigger its auto-invalidation sequence, clearing the active lines and returning to a neutral scanning state. This helps in dynamically cutting risk when a setup structurally fails.

[b]⚙️ Inputs and Settings[/b]

The indicator is highly customizable, allowing adaptation to any asset or timeframe.

[b]• BOS Group[/b]
[list]
[*] Swing Length: Determines the lookback and lookforward period for pivot detection. Lower values react faster but produce more noise; higher values identify major macro swings.
[/list]

[b]• Visibility Group[/b]
[list]
[*] Show BOS Line / Labels: Toggles the historical structural break drawings.
[*] Auto-Invalidate: When enabled, the script will cancel an active setup if the opposing structural extreme is breached.
[*] Color settings: Fully customize the hues for Bullish breaks, Bearish breaks, and Targets.
[/list]

[b]• SL/TP Group[/b]
[list]
[*] Show Entry/SL/TP: Toggles the projection lines on the chart.
[*] ATR Length: The lookback period for calculating market volatility.
[*] Multipliers: Adjust the SL ATR Multiplier and the individual TP1, TP2, and TP3 multipliers to define your specific risk-to-reward parameters.
[/list]

[b]• HTF Group[/b]
[list]
[*] HTF: Select the resolution for the higher timeframe filter (e.g., 240 for 4-hour, D for Daily).
[*] HTF Filter: Toggle the momentum alignment requirement on or off.
[*] HTF RSI Len: The period for the higher timeframe momentum oscillator.
[/list]

[b]• Alerts Group[/b]
[list]
[*] The script features built-in webhook-ready JSON alerts that can notify external services the moment a BOS occurs or a target is successfully hit.
[/list]

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. I expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick

//@version=6
indicator("Market Structure Target Tracker [MarkitTick]", overlay=true, max_lines_count=500, max_labels_count=500)
// ── Input Groups ──────────────────────────────────────────────────────────────
string GRP_BOS   = "BOS"
string GRP_HTF   = "HTF"
string GRP_VIS   = "Vis"
string GRP_TP    = "SL/TP"
string GRP_ALERT = "Alerts"
string GRP_DASH  = "Dash"
// ── User Inputs ───────────────────────────────────────────────────────────────
int    swingLen       = input.int(5,        "Swing Length",    minval=3,  maxval=50, group=GRP_BOS)
bool   showBosLine    = input.bool(true,      "Show BOS Line",               group=GRP_VIS)
bool   showLabel      = input.bool(true,      "Show Labels",                 group=GRP_VIS)
bool   invalidateMode = input.bool(true,      "Auto-Invalidate",             group=GRP_VIS)
color  colBullBos     = input.color(color.rgb(0,200,120,0),   "Bull BOS",   group=GRP_VIS)
color  colBearBos     = input.color(color.rgb(220,50,50,0),   "Bear BOS",   group=GRP_VIS)
color  colTarget      = input.color(color.rgb(255,200,0,0),   "Target",     group=GRP_VIS)
color  colHit         = input.color(color.rgb(180,100,255,0), "Target Hit", group=GRP_VIS)
bool   showTpSl       = input.bool(true,      "Show Entry/SL/TP",            group=GRP_TP)
float  slMulti        = input.float(1.0,      "SL ATR Multi",  minval=0.1, maxval=10.0, step=0.1, group=GRP_TP)
float  tp1Multi       = input.float(1.5,      "TP1 ATR Multi", minval=0.1, maxval=20.0, step=0.1, group=GRP_TP)
float  tp2Multi       = input.float(3.0,      "TP2 ATR Multi", minval=0.1, maxval=20.0, step=0.1, group=GRP_TP)
float  tp3Multi       = input.float(5.0,      "TP3 ATR Multi", minval=0.1, maxval=20.0, step=0.1, group=GRP_TP)
int    atrLen         = input.int(14,         "ATR Length",    minval=1,  maxval=50,   group=GRP_TP)
color  colEntry       = input.color(color.rgb(100,180,255,0), "Entry",    group=GRP_TP)
color  colSl          = input.color(color.rgb(255,60,60,0),   "SL",       group=GRP_TP)
color  colTp1         = input.color(color.rgb(0,220,130,0),   "TP1",      group=GRP_TP)
color  colTp2         = input.color(color.rgb(0,255,180,0),   "TP2",      group=GRP_TP)
color  colTp3         = input.color(color.rgb(0,255,255,0),   "TP3",      group=GRP_TP)
string htfRes         = input.timeframe("240", "HTF",         group=GRP_HTF)
bool   useHtfFilter   = input.bool(false,       "HTF Filter",  group=GRP_HTF)
int    htfRsiLen      = input.int(14,          "HTF RSI Len", group=GRP_HTF, minval=2)
bool   alertBos       = input.bool(true,       "BOS Alert",   group=GRP_ALERT)
bool   alertTarget    = input.bool(true,       "Target Alert",group=GRP_ALERT)
color  dash_bg_color  = input.color(color.rgb(10,10,18,5),    "BG",  group=GRP_DASH)
color  dash_txt_color = input.color(color.rgb(220,220,235,0), "Text",group=GRP_DASH)

// ── Dashboard Helper Functions ────────────────────────────────────────────────
f_blockBar(float rawVal, float domainMax) =>
    float  pct = math.min(math.max(rawVal / domainMax * 100.0, 0.0), 100.0)
    int    n   = math.round(pct / 10.0)
    string s   = ''
    for i = 1 to 10
        s += i <= n ? '█' : '░'
    s + ' ' + str.tostring(math.round(pct), '##0') + '%'

f_blockColor(float rawVal, float lo, float mid, float hi) =>
    rawVal >= hi  ? color.rgb(0, 255, 120) :
     rawVal >= mid ? color.rgb(80, 255, 0)  :
     rawVal >= lo  ? color.rgb(200, 200, 0) :
                     color.rgb(110, 110, 110)

// ── Symbol & ATR Calculations ─────────────────────────────────────────────────
string clean_ticker = syminfo.prefix + ':' + syminfo.ticker
float atrVal    = ta.atr(atrLen)
float atrLocked = atrVal[1]

// ── HTF Bias Filter via RSI ───────────────────────────────────────────────────
float htfRsiRaw = request.security(syminfo.tickerid, htfRes, ta.rsi(close, htfRsiLen)[1], lookahead=barmerge.lookahead_off)
float htfRsi    = htfRsiRaw
bool  htfBull   = htfRsi > 50.0
bool  htfBear   = htfRsi < 50.0
bool  htfOkBull = not useHtfFilter or htfBull
bool  htfOkBear = not useHtfFilter or htfBear

// ── Pivot Detection ───────────────────────────────────────────────────────────
float ph = ta.pivothigh(high, swingLen, swingLen)
float pl = ta.pivotlow(low,  swingLen, swingLen)

// ── Persistent State Variables ────────────────────────────────────────────────
var float lastSwingHigh    = na
var float lastSwingLow     = na
var float prevSwingHigh    = na
var float prevSwingLow     = na
var int   lastSwingHighBar = na
var int   lastSwingLowBar  = na
var int   trend            = 0
var float bosLevel         = na
var float targetLevel      = na
var int   bosBar           = na
var int   bosBarTime       = na
var bool  bosIsBull        = false
var bool  targetHit        = false
var float entryPrice       = na
var float slPrice          = na
var float tp1Price         = na
var float tp2Price         = na
var float tp3Price         = na
var line  bosLine          = na
var line  entryLine        = na
var line  slLine           = na
var line  tp1Line          = na
var line  tp2Line          = na
var line  tp3Line          = na
var label bosLbl           = na
var label entryLbl         = na
var label slLbl            = na
var label tp1Lbl           = na
var label tp2Lbl           = na
var label tp3Lbl           = na
var int   bosBarsCount     = 0
var int   totalBos         = 0
var int   bullBosCount     = 0
var int   bearBosCount     = 0
var float invalidSwingRef  = na
var int   lastProcessedHighBar = na
var int   lastProcessedLowBar  = na

if not na(ph)
    prevSwingHigh    := lastSwingHigh
    lastSwingHigh    := ph
    lastSwingHighBar := bar_index - swingLen

if not na(pl)
    prevSwingLow    := lastSwingLow
    lastSwingLow    := pl
    lastSwingLowBar := bar_index - swingLen

bool bosBull = barstate.isconfirmed and not na(lastSwingHigh) and close > lastSwingHigh and htfOkBull and (na(lastProcessedHighBar) or lastSwingHighBar != lastProcessedHighBar)
bool bosBear = barstate.isconfirmed and not na(lastSwingLow)  and close < lastSwingLow  and htfOkBear and (na(lastProcessedLowBar)  or lastSwingLowBar  != lastProcessedLowBar)

// ── Bullish BOS/CHoCH Handler ─────────────────────────────────────────────────
if bosBull
    lastProcessedHighBar := lastSwingHighBar  
    string _lbl    = trend == 1 ? "BOS" : "CHoCH"
    trend         := 1
    bosLevel      := lastSwingHigh
    targetLevel   := prevSwingHigh
    bosBar        := bar_index
    bosBarTime    := time
    bosIsBull     := true
    targetHit     := false
    bosBarsCount  := 0
    totalBos      += 1
    bullBosCount  += 1
    entryPrice    := bosLevel + atrLocked * 0.1
    slPrice       := bosLevel - atrLocked * slMulti
    tp1Price      := entryPrice + atrLocked * tp1Multi
    tp2Price      := entryPrice + atrLocked * tp2Multi
    tp3Price      := entryPrice + atrLocked * tp3Multi
    invalidSwingRef := lastSwingLow
    if showBosLine and not na(bosLevel)
        line.delete(bosLine)
        int _x1 = na(lastSwingHighBar) ? bar_index : math.max(lastSwingHighBar, bar_index - 499)
        bosLine := line.new(_x1, bosLevel, bar_index, bosLevel, color=colBullBos, width=2, style=line.style_dashed)
    if showLabel
        label.delete(bosLbl)
        int _x1  = na(lastSwingHighBar) ? bar_index : math.max(lastSwingHighBar, bar_index - 499)
        int _mid = math.min(math.round((_x1 + bar_index) / 2), bar_index)
        bosLbl  := label.new(_mid, bosLevel, "▲ " + _lbl, color=color.new(color.white, 100), textcolor=colBullBos, style=label.style_label_down, size=size.small)
    if showTpSl
        line.delete(entryLine)
        line.delete(slLine)
        line.delete(tp1Line)
        line.delete(tp2Line)
        line.delete(tp3Line)
        label.delete(entryLbl)
        label.delete(slLbl)
        label.delete(tp1Lbl)
        label.delete(tp2Lbl)
        label.delete(tp3Lbl)
        entryLine := line.new(bosBar, entryPrice, bar_index + 30, entryPrice, color=colEntry, width=1, style=line.style_dashed)
        slLine    := line.new(bosBar, slPrice,    bar_index + 30, slPrice,    color=colSl,    width=1, style=line.style_dashed)
        tp1Line   := line.new(bosBar, tp1Price,   bar_index + 30, tp1Price,   color=colTp1,   width=1, style=line.style_dashed)
        tp2Line   := line.new(bosBar, tp2Price,   bar_index + 30, tp2Price,   color=colTp2,   width=1, style=line.style_dashed)
        tp3Line   := line.new(bosBar, tp3Price,   bar_index + 30, tp3Price,   color=colTp3,   width=1, style=line.style_dashed)
        entryLbl  := label.new(bar_index + 30, entryPrice, "► Entry  " + str.tostring(entryPrice, format.mintick), color=color.new(colEntry,70), textcolor=colEntry, style=label.style_label_left, size=size.small)
        slLbl     := label.new(bar_index + 30, slPrice,    "✕ SL  "    + str.tostring(slPrice,    format.mintick), color=color.new(colSl,   70), textcolor=colSl,    style=label.style_label_left, size=size.small)
        tp1Lbl    := label.new(bar_index + 30, tp1Price,   "● TP1  "   + str.tostring(tp1Price,   format.mintick), color=color.new(colTp1,  70), textcolor=colTp1,   style=label.style_label_left, size=size.small)
        tp2Lbl    := label.new(bar_index + 30, tp2Price,   "★ TP2  "   + str.tostring(tp2Price,   format.mintick), color=color.new(colTp2,  70), textcolor=colTp2,   style=label.style_label_left, size=size.small)
        tp3Lbl    := label.new(bar_index + 30, tp3Price,   "◆ TP3  "   + str.tostring(tp3Price,   format.mintick), color=color.new(colTp3,  70), textcolor=colTp3,   style=label.style_label_left, size=size.small)

// ── Bearish BOS/CHoCH Handler ─────────────────────────────────────────────────
if bosBear
    lastProcessedLowBar := lastSwingLowBar   
    string _lbl    = trend == -1 ? "BOS" : "CHoCH"
    trend         := -1
    bosLevel      := lastSwingLow
    targetLevel   := prevSwingLow
    bosBar        := bar_index
    bosBarTime    := time
    bosIsBull     := false
    targetHit     := false
    bosBarsCount  := 0
    totalBos      += 1
    bearBosCount  += 1
    entryPrice    := bosLevel - atrLocked * 0.1
    slPrice       := bosLevel + atrLocked * slMulti
    tp1Price      := entryPrice - atrLocked * tp1Multi
    tp2Price      := entryPrice - atrLocked * tp2Multi
    tp3Price      := entryPrice - atrLocked * tp3Multi
    invalidSwingRef := lastSwingHigh
    if showBosLine and not na(bosLevel)
        line.delete(bosLine)
        int _x1 = na(lastSwingLowBar) ? bar_index : math.max(lastSwingLowBar, bar_index - 499)
        bosLine := line.new(_x1, bosLevel, bar_index, bosLevel, color=colBearBos, width=2, style=line.style_dashed)
    if showLabel
        label.delete(bosLbl)
        int _x1  = na(lastSwingLowBar) ? bar_index : math.max(lastSwingLowBar, bar_index - 499)
        int _mid = math.min(math.round((_x1 + bar_index) / 2), bar_index)
        bosLbl  := label.new(_mid, bosLevel, "▼ " + _lbl, color=color.new(color.white, 100), textcolor=colBearBos, style=label.style_label_up, size=size.small)
    if showTpSl
        line.delete(entryLine)
        line.delete(slLine)
        line.delete(tp1Line)
        line.delete(tp2Line)
        line.delete(tp3Line)
        label.delete(entryLbl)
        label.delete(slLbl)
        label.delete(tp1Lbl)
        label.delete(tp2Lbl)
        label.delete(tp3Lbl)
        entryLine := line.new(bosBar, entryPrice, bar_index + 30, entryPrice, color=colEntry, width=1, style=line.style_dashed)
        slLine    := line.new(bosBar, slPrice,    bar_index + 30, slPrice,    color=colSl,    width=1, style=line.style_dashed)
        tp1Line   := line.new(bosBar, tp1Price,   bar_index + 30, tp1Price,   color=colTp1,   width=1, style=line.style_dashed)
        tp2Line   := line.new(bosBar, tp2Price,   bar_index + 30, tp2Price,   color=colTp2,   width=1, style=line.style_dashed)
        tp3Line   := line.new(bosBar, tp3Price,   bar_index + 30, tp3Price,   color=colTp3,   width=1, style=line.style_dashed)
        entryLbl  := label.new(bar_index + 30, entryPrice, "► Entry  " + str.tostring(entryPrice, format.mintick), color=color.new(colEntry,70), textcolor=colEntry, style=label.style_label_left, size=size.small)
        slLbl     := label.new(bar_index + 30, slPrice,    "✕ SL  "    + str.tostring(slPrice,    format.mintick), color=color.new(colSl,   70), textcolor=colSl,    style=label.style_label_left, size=size.small)
        tp1Lbl    := label.new(bar_index + 30, tp1Price,   "● TP1  "   + str.tostring(tp1Price,   format.mintick), color=color.new(colTp1,  70), textcolor=colTp1,   style=label.style_label_left, size=size.small)
        tp2Lbl    := label.new(bar_index + 30, tp2Price,   "★ TP2  "   + str.tostring(tp2Price,   format.mintick), color=color.new(colTp2,  70), textcolor=colTp2,   style=label.style_label_left, size=size.small)
        tp3Lbl    := label.new(bar_index + 30, tp3Price,   "◆ TP3  "   + str.tostring(tp3Price,   format.mintick), color=color.new(colTp3,  70), textcolor=colTp3,   style=label.style_label_left, size=size.small)

var linefill slFill   = na
var linefill tp1Fill  = na
var linefill tp2Fill  = na
var linefill tp3Fill  = na

if bosBull or bosBear
    linefill.delete(slFill)
    linefill.delete(tp1Fill)
    linefill.delete(tp2Fill)
    slFill  := linefill.new(entryLine, slLine,  color.new(colSl,  70))
    tp1Fill := linefill.new(entryLine, tp1Line, color.new(colTp1, 70))
    tp2Fill := linefill.new(tp1Line,   tp2Line, color.new(colTp2, 85))
    tp3Fill := linefill.new(tp2Line,   tp3Line, color.new(colTp2, 95))

// ── Active BOS Line Extension ─────────────────────────────────────────────────
bool bosActive = not na(bosLevel) and not na(bosBar)
if bosActive and not bosBull and not bosBear
    bosBarsCount += 1
    if showTpSl
        if not na(entryLine)
            line.set_x2(entryLine, bar_index + 30)
        if not na(slLine)
            line.set_x2(slLine, bar_index + 30)
        if not na(tp1Line)
            line.set_x2(tp1Line, bar_index + 30)
        if not na(tp2Line)
            line.set_x2(tp2Line, bar_index + 30)
        if not na(tp3Line)
            line.set_x2(tp3Line, bar_index + 30)
        if not na(entryLbl)
            label.set_x(entryLbl, bar_index + 30)
        if not na(slLbl)
            label.set_x(slLbl, bar_index + 30)
        if not na(tp1Lbl)
            label.set_x(tp1Lbl, bar_index + 30)
        if not na(tp2Lbl)
            label.set_x(tp2Lbl, bar_index + 30)
        if not na(tp3Lbl)
            label.set_x(tp3Lbl, bar_index + 30)

// ── Target Hit Detection ──────────────────────────────────────────────────────
bool targetReached = bosActive and not targetHit and not na(targetLevel) and (bosIsBull ? high >= targetLevel : low <= targetLevel)
if targetReached
    targetHit := true

// ── BOS Invalidation Logic ────────────────────────────────────────────────────
bool invalidated = bosActive and not targetHit and barstate.isconfirmed and not na(invalidSwingRef) and (bosIsBull ? close < invalidSwingRef : close > invalidSwingRef) and invalidateMode
if invalidated
    bosLevel    := na
    bosBar      := na
    bosBarTime  := na
    targetLevel := na
    entryPrice := na
    slPrice    := na
    tp1Price   := na
    tp2Price   := na
    tp3Price   := na
    invalidSwingRef := na
    trend := 0
    lastProcessedHighBar := na
    lastProcessedLowBar  := na
    if not na(bosLine)
        line.delete(bosLine)
    if not na(entryLine)
        line.delete(entryLine)
    if not na(slLine)
        line.delete(slLine)
    if not na(tp1Line)
        line.delete(tp1Line)
    if not na(tp2Line)
        line.delete(tp2Line)
    if not na(tp3Line)
        line.delete(tp3Line)
    label.delete(entryLbl)
    label.delete(slLbl)
    label.delete(tp1Lbl)
    label.delete(tp2Lbl)
    label.delete(tp3Lbl)

// ── Dashboard String & Color Pre-computation ──────────────────────────────────
string trendStr    = trend == 1 ? '▲ Bull' : trend == -1 ? '▼ Bear' : '● Neutral'
color  trendCol    = trend == 1 ? color.rgb(0,200,120) : trend == -1 ? color.rgb(220,50,50) : color.rgb(140,140,140)
float  htfBarVal   = htfRsi
string htfBarStr   = f_blockBar(htfBarVal, 100.0)
color  htfBarCol   = f_blockColor(htfBarVal, 30.0, 50.0, 70.0)
string bosLvlStr   = bosActive and not na(bosLevel)    ? str.tostring(bosLevel,    format.mintick) : '—'
string tgtLvlStr   = bosActive and not na(targetLevel) ? str.tostring(targetLevel, format.mintick) : '—'
string entryStr    = bosActive and not na(entryPrice)  ? str.tostring(entryPrice,  format.mintick) : '—'
string slStr       = bosActive and not na(slPrice)     ? str.tostring(slPrice,     format.mintick) : '—'
string tp1Str      = bosActive and not na(tp1Price)    ? str.tostring(tp1Price,    format.mintick) : '—'
string tp2Str      = bosActive and not na(tp2Price)    ? str.tostring(tp2Price,    format.mintick) : '—'
string tp3Str      = bosActive and not na(tp3Price)    ? str.tostring(tp3Price,    format.mintick) : '—'
string tgtHitStr   = targetHit ? '✓ Hit' : bosActive ? '⏳ Pending' : '—'
color  tgtHitCol   = targetHit ? colHit : bosActive ? color.rgb(255,200,0) : color.rgb(110,110,110)
string durationStr = bosActive ? '⏳ ' + str.tostring(bosBarsCount) + ' Bars' : '—'
string totalStr    = str.tostring(totalBos) + ' (' + str.tostring(bullBosCount) + '▲ / ' + str.tostring(bearBosCount) + '▼)'
string htfStr      = htfBull ? '▲ Bull HTF' : '▼ Bear HTF'
color  htfDirCol   = htfBull ? color.rgb(0,200,120) : color.rgb(220,50,50)
float  _slDiff     = math.abs(entryPrice - slPrice)
float  rrVal       = bosActive and not na(tp1Price) and not na(entryPrice) and not na(slPrice) and _slDiff > 0.0 ? math.abs(tp1Price - entryPrice) / _slDiff : 0.0
string rrStr       = bosActive ? str.tostring(rrVal, '#.##') + ' R' : '—'
color  rrCol       = rrVal >= 2.0 ? color.rgb(0,255,120) : rrVal >= 1.5 ? color.rgb(80,255,0) : rrVal >= 1.0 ? color.rgb(200,200,0) : color.rgb(110,110,110)

// ── Dashboard Table ───────────────────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 15,
     border_width=1, border_color=color.rgb(50,50,70,20),
     frame_width=1,  frame_color=color.rgb(60,60,90,10))
color hdrBg = color.rgb(30,30,45,10)
color altBg = color.rgb(20,20,25,10)
color oddBg = dash_bg_color
table.cell(dash, 0, 0,  clean_ticker, text_color=dash_txt_color,         bgcolor=hdrBg, text_halign=text.align_left,  text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 0,  'BOS [MT]',   text_color=color.rgb(180,180,220), bgcolor=hdrBg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 0, 1,  'Trend',      text_color=dash_txt_color,         bgcolor=oddBg, text_halign=text.align_left,  text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 1,  trendStr,     text_color=trendCol,               bgcolor=oddBg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 0, 2,  'HTF Dir',    text_color=dash_txt_color,         bgcolor=altBg, text_halign=text.align_left,  text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 2,  htfStr,       text_color=htfDirCol,              bgcolor=altBg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 0, 3,  'HTF RSI',    text_color=dash_txt_color,         bgcolor=oddBg, text_halign=text.align_left,  text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 3,  htfBarStr,    text_color=htfBarCol,              bgcolor=oddBg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 0, 4,  'BOS Lvl',    text_color=dash_txt_color,         bgcolor=altBg, text_halign=text.align_left,  text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 4,  bosLvlStr,    text_color=color.rgb(200,200,60),  bgcolor=altBg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 0, 5,  'Target',     text_color=dash_txt_color,         bgcolor=oddBg, text_halign=text.align_left,  text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 5,  tgtLvlStr,    text_color=color.rgb(200,200,60),  bgcolor=oddBg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 0, 6,  'Tgt Status', text_color=dash_txt_color,         bgcolor=altBg, text_halign=text.align_left,  text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 6,  tgtHitStr,    text_color=tgtHitCol,              bgcolor=altBg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 0, 7,  '► Entry',    text_color=dash_txt_color,         bgcolor=oddBg, text_halign=text.align_left,  text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 7,  entryStr,     text_color=colEntry,               bgcolor=oddBg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 0, 8,  '✕ SL',       text_color=dash_txt_color,         bgcolor=altBg, text_halign=text.align_left,  text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 8,  slStr,        text_color=colSl,                  bgcolor=altBg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 0, 9,  '● TP1',      text_color=dash_txt_color,         bgcolor=oddBg, text_halign=text.align_left,  text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 9,  tp1Str,       text_color=colTp1,                 bgcolor=oddBg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 0, 10, '★ TP2',      text_color=dash_txt_color,         bgcolor=altBg, text_halign=text.align_left,  text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 10, tp2Str,       text_color=colTp2,                 bgcolor=altBg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 0, 11, '◆ TP3',      text_color=dash_txt_color,         bgcolor=oddBg, text_halign=text.align_left,  text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 11, tp3Str,       text_color=colTp3,                 bgcolor=oddBg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 0, 12, 'R:R',        text_color=dash_txt_color,         bgcolor=altBg, text_halign=text.align_left,  text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 12, rrStr,        text_color=rrCol,                  bgcolor=altBg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 0, 13, 'Duration',   text_color=dash_txt_color,         bgcolor=oddBg, text_halign=text.align_left,  text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 13, durationStr,  text_color=color.rgb(140,180,255), bgcolor=oddBg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 0, 14, 'Total BOS',  text_color=dash_txt_color,         bgcolor=hdrBg, text_halign=text.align_left,  text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 14, totalStr,     text_color=color.rgb(180,180,220), bgcolor=hdrBg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)

// ── Webhook Alert Message Construction ───────────────────────────────────────
string bosAlertMsg = "{" + str.format('"t":"{0}","tf":"{1}","type":"BOS","dir":"{2}","lvl":{3},"entry":{4},"sl":{5},"tp1":{6},"tp2":{7},"tp3":{8}',
     syminfo.tickerid, timeframe.period,
     bosIsBull ? "bull" : "bear",
     str.tostring(bosLevel,   format.mintick),
     str.tostring(entryPrice, format.mintick),
     str.tostring(slPrice,    format.mintick),
     str.tostring(tp1Price,   format.mintick),
     str.tostring(tp2Price,   format.mintick),
     str.tostring(tp3Price,   format.mintick)) + "}"
string tgtAlertMsg = "{" + str.format('"t":"{0}","tf":"{1}","type":"TGT","dir":"{2}","tgt":{3}',
     syminfo.tickerid, timeframe.period,
     bosIsBull ? "bull" : "bear",
     str.tostring(targetLevel, format.mintick)) + "}"

// ── Alert Dispatch ────────────────────────────────────────────────────────────
if alertBos and (bosBull or bosBear) and barstate.isconfirmed
    alert(bosAlertMsg, alert.freq_once_per_bar_close)
if alertTarget and targetReached and barstate.isconfirmed
    alert(tgtAlertMsg, alert.freq_once_per_bar_close)
````
