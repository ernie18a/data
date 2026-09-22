<!-- tradingview-pine-id: PUB;cc1dafc6100c4ed4950e4e0f14d3a2a4 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# DiNapoli Levels Confluence Targets [MarkitTick]

Source: https://www.tradingview.com/script/6JpJJe4C-DiNapoli-Levels-Confluence-Targets-MarkitTick/

## Description

💡 This script automates the complete DiNapoli-style Fibonacci workflow on any symbol and timeframe: it locates confirmed swing pivots, measures the resulting impulse leg, selects an appropriate Fibonacci retracement entry from that leg, projects a three-tier set of Fibonacci profit objectives from the pullback point, cross-checks a second independent swing for confluence, filters everything through a displaced-average trend context, and then tracks the resulting trade in real time through on-chart levels and a live dashboard.

Rather than requiring a trader to manually draw retracement and expansion tools on every fresh swing, cross-reference two different Fibonacci grids by eye, and mentally track a displaced moving average's bias, the script performs all of that detection, labeling, and state-tracking automatically, and exposes the resulting signals through webhook-ready alert payloads for automation.

✨ Originality and Utility

This is not a rehash of a single built-in Pine tool or a simple retracement drawing utility. It implements the full, interdependent DiNapoli Levels sequence as one coherent system, where each stage consumes the output of the previous one:

[*]Confirmed fractal pivot detection builds the swing skeleton the entire tool depends on.
[*]The most recent three-to-five pivots are used to define both a primary swing (for entries and objectives) and a secondary, older swing (used only for confluence cross-checking).
[*]Retracement depth of the pullback determines which of two Fibonacci entry levels is actually referenced, rather than relying on a single fixed ratio for every setup.
[*]Profit objectives are geometric extensions of the very same swing used to derive the entry, not independent, arbitrarily chosen levels.
[*]The displaced-average trend filter, ATR-based stop, and confluence check all read from the same pivot/swing state, so removing any one of them would break the internal logic rather than simply "simplify" the script.

Because the entry, stop, and all three objectives are all mathematically derived from the same confirmed swing, the tool gives traders a single, internally consistent read on a setup instead of several disconnected indicators layered on top of one another. The value is in the integration and automation of a documented, multi-step methodology, the live tracking of trade state once a signal fires, and the structured webhook output for downstream automation — not in inventing a new mathematical formula.

🔬 Methodology and Concepts

• Pivot and Swing Detection
Swing highs and lows are identified using a standard confirmed-fractal method: a candidate high (or low) is only accepted once it is verified to be the extreme point across a window of Pivot Left bars before it and Pivot Right bars after it. Confirmed pivots are stored in a rolling, alternating high/low sequence (capped at the eight most recent) that forms the script's live market-structure map.

• Swing Classification
The three most recent pivots are labeled, oldest to newest, A, B, and C. A bullish structure requires the sequence low → high → low (A low, B high, C low), representing an upward impulse leg from A to B followed by a pullback into C. A bearish structure is the mirror image. The distance from A to B defines the primary swing used for every subsequent calculation.

• Retracement Measurement
The pullback's depth is expressed as a percentage of the A–B swing: how far price has travelled back from B toward A by the time pivot C is confirmed. This retracement percentage drives both setup validity and entry-level selection.

• Fibonacci Retracement Entry Zone
Two retracement levels of the A–B swing are calculated, at 38.2% and 61.8%. If the confirmed pullback has already reached 61.8% or deeper, the script references the 61.8% level as the entry; otherwise it references the shallower 38.2% level. This dynamic selection reflects the idea that the appropriate entry reference depends on how deep the actual retracement has gone, rather than committing to one ratio for every swing.

• Fibonacci Objective Targets
Three profit objectives are projected from pivot C using the primary swing magnitude, following the classic three-tier DiNapoli objective-point structure:

[*]COP (Contracted Objective Point) — C plus 0.618 times the swing.
[*]OP (Objective Point) — C plus 1.000 times the swing.
[*]XOP (Expanded Objective Point) — C plus 1.618 times the swing.

These represent successively less conservative price projections derived from the same impulse leg used for the entry.

• Setup Validation
A setup is only considered valid when all of the following hold: the alternating high/low pattern is intact, the retracement sits between 38.2% and the user-defined Max Retrace ceiling (filters out pullbacks that have gone too deep to be a valid retracement), the swing's magnitude is at least the Min Swing × ATR threshold (filters out insignificant, noise-driven swings), the swing direction is consistent with the claimed bias, the trend filter (if enabled) agrees, and a confluence zone exists (if Confluence Required is enabled).

• Dual-Swing Confluence Detection
A second, independent swing is measured from an older pivot (A2) to B, and the same 38.2%/61.8% retracement math is applied to it. The script then compares all four combinations of the primary and secondary retracement levels and, if the two closest levels fall within Confluence Tolerance × ATR of each other, marks the midpoint between them as a confluence zone. This reflects agreement between two independently measured Fibonacci grids rather than a single grid taken in isolation, which is the basis of the confluence concept in DiNapoli's original methodology.

• Displaced Moving Average Trend Filter
A short simple moving average (DMA Length) is calculated, and the internal trend comparison uses that average's value from DMA Displace bars earlier, effectively lagging the filter by that many bars. The same average is plotted on the chart with a forward visual offset equal to the same displacement, so the line drawn on the chart lines up with the value actually being compared against price. When enabled, only setups where price sits on the correct side of this displaced average are accepted.

• Stop and Objective Placement Logic
The stop is placed a user-defined multiple of ATR beyond pivot C, giving the stop room proportional to the instrument's own recent volatility rather than a fixed distance. All targets are recalculated fresh each time a new, valid setup fires and remain fixed for the life of that trade.

• Signal Firing and State Tracking
A new signal fires only on a confirmed (closed) bar, and only once per underlying pivot, preventing duplicate or repeated firing on the same structure. Once fired, the script tracks live high/low crosses against the stop and each objective; a stop hit takes priority over a same-bar target hit, and each hit updates the relevant level's on-chart label and color permanently for that trade. The Lock Signal input can freeze the presently tracked setup on the real-time bar so that a fresh pivot does not override an open position mid-trade.

⏱️ Confirmation Lag Notice

Because a pivot cannot be confirmed until Pivot Right bars have elapsed past it, both the pivot itself and any signal built from it only become visible on the chart after that many bars have passed — the resulting lines and labels are drawn retroactively onto a swing that has already formed. This is a structural characteristic of any confirmed-pivot Fibonacci tool rather than a flaw, but it does mean a signal never appears exactly at the live turning point; it appears with a short, deliberate confirmation delay.

The script contains no request.security() calls and references no higher-timeframe or future data, so outside of this inherent pivot-confirmation delay there is no forward-looking bias in the setup logic. Entry signals fire only on confirmed, closed bars, and once a signal and its levels are drawn they do not later shift to a different bar or disappear — they are only replaced outright when a new, opposite setup fires.

The DMA line's forward visual offset is a display convention matching the traditional presentation of a displaced moving average: the values plotted are ordinary trailing averages, simply drawn shifted to the right so the line visually tracks price with the same lag the trend filter itself uses internally. It is not a projection or forecast of future price.

🎨 Visual Guide

• Trade Level Lines and Labels
When a setup fires, five horizontal lines and their accompanying labels extend from the signal bar: the Stop (solid, thicker line), Entry (dashed), and the COP, OP and XOP objectives (dashed, drawn in progressively fuller shades of the same bullish or bearish color to reflect their increasing distance). All five lines automatically extend to the current bar while the trade remains open, and extend up to the closing bar once the trade is stopped out or reaches XOP.

• Fibonacci Node Reference Line
A dotted line marks whichever of the two retracement levels (38.2% or 61.8%) was not selected as the entry, shown for reference so the alternate level remains visible alongside the chosen one.

• Confluence Line
When a confluence zone is detected and the Confluence Line option is enabled, a dashed line marks the midpoint between the two agreeing Fibonacci levels from the primary and secondary swing grids.

• Merged Labels
When two or more levels land at the same price, their labels are merged into a single combined label (separated by a middle dot) instead of stacking overlapping duplicate labels, keeping the chart readable.

• Signal Markers
A "BULL" or "BEAR" label is plotted at the low or high of the firing bar respectively, colored to match the configured bullish or bearish color.

• Displaced Moving Average Line
The DMA is plotted in its configured color, shifted forward on the chart by the DMA Displace setting, matching the internal trend-filter reference described above.

• Live Dashboard Table
An on-chart table (position configurable to any corner) shows, row by row: symbol and timeframe, Lock status, current bias, which Fibonacci node is active, retracement depth as a ten-block progress bar with percentage, whether confluence was present, the Entry/Stop/COP/OP/XOP price levels, risk-to-reward expressed as a block bar scaled to 5R, progress toward OP as a block bar, current trade status (open, or which level was hit), the swing size, the current ATR value, and the number of bars elapsed since the last signal.

📖 How to Use

[*]Wait for a "BULL" or "BEAR" marker and its accompanying level lines to appear; remember these will appear with the short pivot-confirmation delay described above rather than exactly at the swing extreme.
[*]On a bullish setup, price will already be sitting in the retracement zone of the prior up-leg; the Entry line marks the DiNapoli-selected reference level, the Stop sits an ATR-buffered distance beyond the swing low, and COP/OP/XOP are staged, increasingly distant profit levels. Bearish setups mirror this on the downside.
[*]Enable Confluence Required to restrict signals to setups where two independently measured Fibonacci grids agree — this produces fewer but more selectively filtered setups.
[*]Leave the DMA Filter enabled to only take setups aligned with the displaced-average trend context, or disable it to see every structurally valid swing regardless of that bias.
[*]Use Lock Signal on the real-time bar if you are already in a tracked trade and do not want a newly forming pivot to override the current levels mid-position.
[*]Watch the dashboard's Status row and block-bar visualizations for a fast read of retracement depth, risk-to-reward, and progress toward the OP objective without needing to read exact prices.
[*]Configure the Alerts group's action strings to match the JSON keys your webhook or automation platform expects, then use TradingView's "Any alert() function call" option to route long, short, close, objective-hit, and stop-hit events.
[*]Treat the Stop, COP, OP and XOP levels as a structured framework for planning risk and staged exits, not as a guarantee that price will reach any particular level — always size positions according to your own risk tolerance.

⚙️ Inputs and Settings

• Core

[*]Pivot Left / Pivot Right — number of bars required on each side of a candidate swing point before it is confirmed; larger values confirm more significant but slower-appearing swings.
[*]Min Swing × ATR — minimum size, in ATR multiples, an A–B swing must have to be considered valid, filtering out noise-sized structures.
[*]Max Retrace — the deepest retracement (as a fraction of the swing) still accepted as a valid pullback.
[*]ATR Len — lookback period for the Average True Range used throughout the stop, minimum-swing, and confluence-tolerance calculations.

• Filters

[*]DMA Filter — toggles the displaced-average trend requirement on entries.
[*]DMA Len / DMA Displace — period and forward displacement of the trend-filter average.
[*]Confluence Required — toggles whether a confluence zone is mandatory for a setup to fire.
[*]Confluence Tol × ATR — maximum distance, in ATR multiples, between two Fibonacci levels for them to be treated as confluent.

• Trade Tools

[*]Lock Signal — freezes the currently tracked setup on the real-time bar, blocking new signals from overriding it.
[*]Stop Buffer × ATR — distance, in ATR multiples, the stop is placed beyond pivot C.

• Visuals

[*]Fibnodes — shows or hides the unused Fibonacci reference node line.
[*]Confluence Line — shows or hides the confluence-zone line.
[*]Signal Markers — shows or hides the BULL/BEAR labels.
[*]DMA Line — shows or hides the displaced moving average plot.

• Dashboard

[*]Show Dashboard — toggles the on-chart table.
[*]Position — selects which chart corner hosts the dashboard.

• Alerts

[*]Long / Short Action, Close Long / Close Short Action — the "action" values sent in the JSON payload for entries and exits.
[*]COP / OP / XOP Action, Stop Action — the "action" values sent when each objective or the stop is hit.

• Colors
Individual color controls are provided for the bullish and bearish themes, stop, entry, each of the three objectives, both Fibonacci nodes, the confluence line, the DMA line, label text, the dashboard's three-tier progress-bar shading, and the dashboard's header, background, and text colors, allowing the full visual theme to be adapted to any chart background.

🔍 Deconstruction of the Underlying Scientific and Academic Framework

The core methodology follows Joe DiNapoli's published approach from "Trading with DiNapoli Levels" (1998), which combines a displaced moving average for trend context with Fibonacci retracement levels for entry timing and a three-tier set of Fibonacci expansion objectives — the Contracted, standard, and Expanded Objective Points — for profit projection. The script's DMA filter and COP/OP/XOP target structure are direct implementations of that framework.

The use of Fibonacci ratios in price analysis traces back to the Fibonacci sequence itself (Leonardo of Pisa, 13th century) and its adoption into market analysis through Ralph Nelson Elliott's wave theory and W.D. Gann's work on proportional price relationships, later formalized by DiNapoli into a discrete, rules-based entry and objective framework.

Swing-point identification via a confirmed left/right bar window reflects the standard swing-high/swing-low definition used broadly across technical analysis, closely related to the fractal concept popularized by Bill Williams, and provides an objective, repeatable substitute for discretionary chart reading.

Average True Range, developed by J. Welles Wilder, supplies the volatility-normalized basis for the stop distance and minimum-swing filter, allowing the same input values to scale automatically across instruments and volatility regimes rather than relying on fixed point or pip distances.

The confluence-detection logic reflects the broader "cluster" or "confluence zone" concept found throughout Fibonacci-based technical analysis: treating agreement between two independently derived retracement grids as a stronger signal than either grid considered alone, a filtering approach explicitly discussed within DiNapoli's own writings on Fibonacci analysis.

⚠️ Disclaimer
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick

//@version=6
indicator(title = "DiNapoli Levels Confluence Targets [MarkitTick]", overlay = true, max_bars_back = 300, max_lines_count = 20, max_labels_count = 500)

// ── INPUTS ──────────────────────────────────────────────────
string GRP_CORE  = "⚙️ Core"
string GRP_FILT  = "🕯️ Filters"
string GRP_TRADE = "📐 Trade Tools"
string GRP_VIS   = "🎨 Visuals"
string GRP_DASH  = "📊 Dashboard"
string GRP_WH    = "🔔 Alerts"
string GRP_COL   = "🌈 Colors"

i_pvtLeft  = input.int(5, "Pivot Left", minval = 1, maxval = 50, group = GRP_CORE)
i_pvtRight = input.int(5, "Pivot Right", minval = 1, maxval = 50, group = GRP_CORE)
i_minSwing = input.float(1.0, "Min Swing × ATR", minval = 0.0, step = 0.1, group = GRP_CORE)
i_maxRetr  = input.float(0.90, "Max Retrace", minval = 0.40, maxval = 1.0, step = 0.01, group = GRP_CORE)
i_atrLen   = input.int(14, "ATR Len", minval = 1, group = GRP_CORE)

i_useDma  = input.bool(true, "DMA Filter", group = GRP_FILT)
i_dmaLen  = input.int(3, "DMA Len", minval = 1, maxval = 50, group = GRP_FILT)
i_dmaDisp = input.int(3, "DMA Displace", minval = 0, maxval = 50, group = GRP_FILT)
i_useConf = input.bool(false, "Confluence Required", group = GRP_FILT)
i_confTol = input.float(0.25, "Confluence Tol × ATR", minval = 0.01, step = 0.05, group = GRP_FILT)
i_useSmooth    = input.bool(false, "Adaptive Smoothing", group = GRP_FILT)
i_smoothMethod = input.string("EMA", "Smoothing Method", options = ["SMA", "EMA", "RMA", "WMA", "VWMA"], group = GRP_FILT)
i_smoothLen    = input.int(3, "Smoothing Len", minval = 1, maxval = 100, group = GRP_FILT)
i_useAdx  = input.bool(false, "ADX Filter", group = GRP_FILT)
i_adxLen  = input.int(14, "ADX DI Len", minval = 1, maxval = 100, group = GRP_FILT)
i_adxSmth = input.int(14, "ADX Smoothing", minval = 1, maxval = 100, group = GRP_FILT)
i_adxMin  = input.float(20.0, "ADX Min", minval = 0.0, maxval = 100.0, step = 1.0, group = GRP_FILT)
i_useHtf  = input.bool(false, "HTF Confirmation", group = GRP_FILT)
i_htfTf   = input.timeframe("240", "HTF Timeframe", group = GRP_FILT)

i_lockSignal = input.bool(false, "🔒 Lock Signal", tooltip = "Freeze current signal · block new ones", group = GRP_TRADE)
i_slAtr      = input.float(0.5, "Stop Buffer × ATR", minval = 0.0, step = 0.1, group = GRP_TRADE)

i_showNodes   = input.bool(true, "Fibnodes", group = GRP_VIS)
i_showConf    = input.bool(true, "Confluence Line", group = GRP_VIS)
i_showMarkers = input.bool(true, "Signal Markers", group = GRP_VIS)
i_showDma     = input.bool(true, "DMA Line", group = GRP_VIS)

i_showDash = input.bool(true, "Show Dashboard", group = GRP_DASH)
i_dashPos  = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GRP_DASH)

i_actionLong       = input.string("long", "↑ Long Action", group = GRP_WH)
i_actionShort      = input.string("short", "↓ Short Action", group = GRP_WH)
i_actionCloseLong  = input.string("closelong", "✕ Close Long Action", group = GRP_WH)
i_actionCloseShort = input.string("closeshort", "✕ Close Short Action", group = GRP_WH)
i_actionCop        = input.string("tp1", "◆ COP Action", group = GRP_WH)
i_actionOp         = input.string("tp2", "✦ OP Action", group = GRP_WH)
i_actionXop        = input.string("tp3", "◆ XOP Action", group = GRP_WH)
i_actionStop       = input.string("stop", "✕ Stop Action", group = GRP_WH)

C_SUP      = input.color(#26a69a, "Bull", group = GRP_COL)
C_RES      = input.color(#ef5350, "Bear", group = GRP_COL)
C_SL       = input.color(#ef5350, "SL", group = GRP_COL)
C_ENTRY    = input.color(#2196f3, "Entry", group = GRP_COL)
C_TP1      = input.color(color.new(#26a69a, 40), "COP", group = GRP_COL)
C_TP2      = input.color(color.new(#26a69a, 20), "OP", group = GRP_COL)
C_TP3      = input.color(color.new(#26a69a, 0), "XOP", group = GRP_COL)
C_N382     = input.color(#f9a825, "Node 38.2", group = GRP_COL)
C_N618     = input.color(#fb8c00, "Node 61.8", group = GRP_COL)
C_CONF     = input.color(#ab47bc, "Confluence", group = GRP_COL)
C_DMA      = input.color(#7e57c2, "DMA", group = GRP_COL)
C_LBLTXT   = input.color(#ffffff, "Label Text", group = GRP_COL)
C_BAR_HI   = input.color(#26a69a, "Bar High", group = GRP_COL)
C_BAR_MID  = input.color(#f9a825, "Bar Mid", group = GRP_COL)
C_BAR_LO   = input.color(#ef5350, "Bar Low", group = GRP_COL)
C_DASH_HDR = input.color(color.new(#3a2a6d, 55), "Dash Header", group = GRP_COL)
C_DASH_BG  = input.color(color.new(#0a0f1a, 10), "Dash BG", group = GRP_COL)
C_DASH_TXT = input.color(#ffffff, "Dash Text", group = GRP_COL)

// ── CORE LOGIC ──────────────────────────────────────────────
f_pivotHigh(int lb, int rb) =>
    float _res = float(na)
    if bar_index >= lb + rb
        float _p = high[rb]
        bool _ok = true
        for i = 1 to lb
            if high[rb + i] >= _p
                _ok := false
                break
        if _ok
            for i = 1 to rb
                if high[rb - i] > _p
                    _ok := false
                    break
        if _ok
            _res := _p
    _res

f_pivotLow(int lb, int rb) =>
    float _res = float(na)
    if bar_index >= lb + rb
        float _p = low[rb]
        bool _ok = true
        for i = 1 to lb
            if low[rb + i] <= _p
                _ok := false
                break
        if _ok
            for i = 1 to rb
                if low[rb - i] < _p
                    _ok := false
                    break
        if _ok
            _res := _p
    _res

f_pctTxt(float lvl, float ent, bool dirLong) =>
    float _p = (dirLong ? lvl - ent : ent - lvl) / ent * 100
    (_p >= 0 ? "+" : "") + str.tostring(_p, "#.00") + "%"

f_smooth(string method, float src, int len) =>
    float _sma  = ta.sma(src, len)
    float _ema  = ta.ema(src, len)
    float _rma  = ta.rma(src, len)
    float _wma  = ta.wma(src, len)
    float _vwma = ta.vwma(src, len)
    float _res = switch method
        "SMA"  => _sma
        "EMA"  => _ema
        "RMA"  => _rma
        "WMA"  => _wma
        "VWMA" => _vwma
        => _ema
    _res

float _atr      = ta.atr(i_atrLen)
float _dma      = ta.sma(close, i_dmaLen)
float _dmaRef   = _dma[i_dmaDisp]
float _smoothed = f_smooth(i_smoothMethod, close, i_smoothLen)

[_diPlus, _diMinus, _adx] = ta.dmi(i_adxLen, i_adxSmth)

bool _adxOk = not i_useAdx or _adx >= i_adxMin

float _htfClose = request.security(syminfo.tickerid, i_htfTf, close[1], lookahead = barmerge.lookahead_on)

var array<float> _pvPrice = array.new_float(0)
var array<int>   _pvBar   = array.new_int(0)
var array<bool>  _pvHigh  = array.new_bool(0)

float _ph = f_pivotHigh(i_pvtLeft, i_pvtRight)
float _pl = f_pivotLow(i_pvtLeft, i_pvtRight)

if not na(_ph)
    bool _sameSide = false
    if array.size(_pvHigh) > 0
        _sameSide := array.get(_pvHigh, 0)
    if _sameSide
        if _ph > array.get(_pvPrice, 0)
            array.set(_pvPrice, 0, _ph)
            array.set(_pvBar, 0, bar_index - i_pvtRight)
    else
        array.unshift(_pvPrice, _ph)
        array.unshift(_pvBar, bar_index - i_pvtRight)
        array.unshift(_pvHigh, true)

if not na(_pl)
    bool _sameSideLow = false
    if array.size(_pvHigh) > 0
        _sameSideLow := not array.get(_pvHigh, 0)
    if _sameSideLow
        if _pl < array.get(_pvPrice, 0)
            array.set(_pvPrice, 0, _pl)
            array.set(_pvBar, 0, bar_index - i_pvtRight)
    else
        array.unshift(_pvPrice, _pl)
        array.unshift(_pvBar, bar_index - i_pvtRight)
        array.unshift(_pvHigh, false)

if array.size(_pvPrice) > 8
    array.pop(_pvPrice)
    array.pop(_pvBar)
    array.pop(_pvHigh)

int   _pvN  = array.size(_pvPrice)
float _pxC  = float(na)
float _pxB  = float(na)
float _pxA  = float(na)
float _pxA2 = float(na)
int   _barC = int(na)
bool  _hiC  = false
bool  _hiB  = false
bool  _hiA  = false

if _pvN >= 3
    _pxC  := array.get(_pvPrice, 0)
    _pxB  := array.get(_pvPrice, 1)
    _pxA  := array.get(_pvPrice, 2)
    _barC := array.get(_pvBar, 0)
    _hiC  := array.get(_pvHigh, 0)
    _hiB  := array.get(_pvHigh, 1)
    _hiA  := array.get(_pvHigh, 2)

if _pvN >= 5
    _pxA2 := array.get(_pvPrice, 4)

bool  _isBull = not na(_pxC) and not _hiC and _hiB and not _hiA
bool  _isBear = not na(_pxC) and _hiC and not _hiB and _hiA
float _swing  = _pxB - _pxA
float _retr   = float(na)

if (_isBull or _isBear) and _swing != 0
    _retr := (_pxB - _pxC) / _swing

float _n382  = _pxB - 0.382 * _swing
float _n618  = _pxB - 0.618 * _swing
float _entry = float(na)

if not na(_retr)
    _entry := _retr >= 0.618 ? _n618 : _n382

float _stop = _isBull ? _pxC - _atr * i_slAtr : _pxC + _atr * i_slAtr
float _cop  = _pxC + 0.618 * _swing
float _op   = _pxC + _swing
float _xop  = _pxC + 1.618 * _swing

float _swing2 = _pxB - _pxA2
float _m382   = _pxB - 0.382 * _swing2
float _m618   = _pxB - 0.618 * _swing2
float _confPx = float(na)
bool  _confIs618 = false

if not na(_pxA2) and not na(_n382) and not na(_atr) and (_isBull ? _swing2 > 0 : _swing2 < 0)
    float _d1   = math.abs(_n382 - _m382)
    float _d2   = math.abs(_n382 - _m618)
    float _d3   = math.abs(_n618 - _m382)
    float _d4   = math.abs(_n618 - _m618)
    float _best = math.min(_d1, _d2, _d3, _d4)
    if _best <= _atr * i_confTol
        if _best == _d1
            _confPx := (_n382 + _m382) / 2
        else if _best == _d2
            _confPx := (_n382 + _m618) / 2
        else if _best == _d3
            _confPx := (_n618 + _m382) / 2
            _confIs618 := true
        else
            _confPx := (_n618 + _m618) / 2
            _confIs618 := true

bool _smoothOk = not i_useSmooth or (_isBull ? close > _smoothed : close < _smoothed)
bool _htfOk    = not i_useHtf or na(_htfClose) or (_isBull ? close > _htfClose : close < _htfClose)
bool _trendOk  = (not i_useDma or (_isBull ? close > _dmaRef : close < _dmaRef)) and _smoothOk and _adxOk and _htfOk
bool _setupValid = (_isBull or _isBear) and not na(_retr) and not na(_barC) and _retr >= 0.382 and _retr <= i_maxRetr and math.abs(_swing) >= _atr * i_minSwing and (_isBull ? _swing > 0 : _swing < 0) and _trendOk and (not i_useConf or not na(_confPx))

var line  slLine    = na
var line  entryLine = na
var line  tp1Line   = na
var line  tp2Line   = na
var line  tp3Line   = na
var line  n382Line  = na
var line  n618Line  = na
var line  confLine  = na
var label slLbl     = na
var label entryLbl  = na
var label tp1Lbl    = na
var label tp2Lbl    = na
var label tp3Lbl    = na
var label n382Lbl   = na
var label n618Lbl   = na
var label confLbl   = na

var bool  isLong        = false
var float entryPrice    = float(na)
var float slPrice       = float(na)
var float tp1Price      = float(na)
var float tp2Price      = float(na)
var float tp3Price      = float(na)
var float node382       = float(na)
var float node618       = float(na)
var float confPrice     = float(na)
var bool  confIs618     = false
var float swingSize     = float(na)
var float nodeRetr      = float(na)
var bool  nodeIs618     = false
var int   signalBar     = int(na)
var bool  tp1Hit        = false
var bool  tp2Hit        = false
var bool  tp3Hit        = false
var bool  slHit         = false
var int   _closeBar     = int(na)
var int   _lastSetupBar = int(na)
var array<float>  lvPx   = array.new<float>(7, na)
var array<string> lvName = array.new<string>(7, "")
var array<string> lvHit  = array.new<string>(7, "")
var array<int>    lvHost = array.new<int>(7, -1)

f_hostOf(int _i) =>
    int _h = _i
    if _i > 0
        for j = 0 to _i - 1
            if array.get(lvHost, j) == j and array.get(lvPx, j) == array.get(lvPx, _i)
                _h := j
                break
    _h

f_lvText(int _host) =>
    float _hPx  = array.get(lvPx, _host)
    int   _last = -1
    for i = 0 to 6
        if array.get(lvHost, i) == _host and array.get(lvHit, i) == "" and array.get(lvPx, i) == _hPx
            _last := i
    string _out = ""
    for i = 0 to 6
        if array.get(lvHost, i) == _host
            float  _px    = array.get(lvPx, i)
            string _hit   = array.get(lvHit, i)
            bool   _atHst = _px == _hPx
            string _piece = _hit != "" ? _hit : not _atHst ? array.get(lvName, i) + " " + str.tostring(_px, format.mintick) : i == _last ? array.get(lvName, i) + " " + str.tostring(_hPx, format.mintick) : array.get(lvName, i)
            _out := _out == "" ? _piece : _out + " · " + _piece
    _out

bool _tp1Cross = isLong ? high >= tp1Price : low <= tp1Price
bool _tp2Cross = isLong ? high >= tp2Price : low <= tp2Price
bool _tp3Cross = isLong ? high >= tp3Price : low <= tp3Price
bool _slCross  = isLong ? low <= slPrice : high >= slPrice
bool _slFire   = _slCross and not slHit and not tp3Hit
bool _tp1Fire  = _tp1Cross and not tp1Hit and not slHit and not _slFire
bool _tp2Fire  = _tp2Cross and not tp2Hit and not slHit and not _slFire
bool _tp3Fire  = _tp3Cross and not tp3Hit and not slHit and not _slFire

if not na(slLbl) and not slHit and not tp3Hit and _slCross
    slHit := true
    array.set(lvHit, 0, "SL ✓ HIT " + f_pctTxt(slPrice, entryPrice, isLong))
    label.set_text(slLbl, f_lvText(array.get(lvHost, 0)))
    label.set_color(slLbl, color.new(C_SL, 0))

if not na(tp1Lbl) and not tp1Hit and not slHit and _tp1Cross
    tp1Hit := true
    array.set(lvHit, 2, "COP ✓ HIT " + f_pctTxt(tp1Price, entryPrice, isLong))
    label.set_text(tp1Lbl, f_lvText(array.get(lvHost, 2)))
    if array.get(lvHost, 2) == 2
        label.set_color(tp1Lbl, color.new(C_TP1, 0))

if not na(tp2Lbl) and not tp2Hit and not slHit and _tp2Cross
    tp2Hit := true
    array.set(lvHit, 3, "OP ✓ HIT " + f_pctTxt(tp2Price, entryPrice, isLong))
    label.set_text(tp2Lbl, f_lvText(array.get(lvHost, 3)))
    if array.get(lvHost, 3) == 3
        label.set_color(tp2Lbl, color.new(C_TP2, 0))

if not na(tp3Lbl) and not tp3Hit and not slHit and _tp3Cross
    tp3Hit := true
    array.set(lvHit, 4, "XOP ✓ HIT " + f_pctTxt(tp3Price, entryPrice, isLong))
    label.set_text(tp3Lbl, f_lvText(array.get(lvHost, 4)))
    if array.get(lvHost, 4) == 4
        label.set_color(tp3Lbl, color.new(C_TP3, 0))

bool _tradeClosed = slHit or tp3Hit

if not na(slLine) and _tradeClosed and na(_closeBar)
    _closeBar := bar_index

bool  _preOpen = not na(slLine) and not _tradeClosed
bool  _preLong = isLong
float _preSl   = slPrice
float _preTp1  = tp1Price
float _preTp2  = tp2Price
float _preTp3  = tp3Price

bool _locked    = i_lockSignal and barstate.islast
bool _newSignal = _setupValid and barstate.isconfirmed and (na(_lastSetupBar) or _barC != _lastSetupBar)
bool _fire      = _newSignal and not _locked

if _fire
    tp1Hit        := false
    tp2Hit        := false
    tp3Hit        := false
    slHit         := false
    _closeBar     := int(na)
    isLong        := _isBull
    entryPrice    := _entry
    slPrice       := _stop
    tp1Price      := _cop
    tp2Price      := _op
    tp3Price      := _xop
    node382       := _n382
    node618       := _n618
    confPrice     := _confPx
    confIs618     := _confIs618
    swingSize     := _swing
    nodeRetr      := _retr
    nodeIs618     := _retr >= 0.618
    signalBar     := bar_index
    _lastSetupBar := _barC

bool longSignal  = _fire and _isBull
bool shortSignal = _fire and _isBear

// ── ALERTS ──────────────────────────────────────────────────
if longSignal and barstate.isconfirmed
    string _nodeTxt = nodeIs618 ? "61.8" : "38.2"
    string _confTxt = na(confPrice) ? "no" : "yes"
    string _retrTxt = str.tostring(nodeRetr * 100, "#.0")
    string _tp3Txt  = str.tostring(tp3Price, format.mintick)
    string _longInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long","entry":"{3}","sl":"{4}","tp":"{5}","cop":"{6}","op":"{7}","xop":"{8}","node":"{9}","retrace":"{10}","confluence":"{11}"', i_actionLong, syminfo.tickerid, timeframe.period, str.tostring(entryPrice, format.mintick), str.tostring(slPrice, format.mintick), _tp3Txt, str.tostring(tp1Price, format.mintick), str.tostring(tp2Price, format.mintick), _tp3Txt, _nodeTxt, _retrTxt, _confTxt)
    string longPayload = "{" + _longInner + "}"
    alert(longPayload, alert.freq_once_per_bar_close)
    if _preOpen and not _preLong
        string _closeShortInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short"', i_actionCloseShort, syminfo.tickerid, timeframe.period)
        string closeShortPayload = "{" + _closeShortInner + "}"
        alert(closeShortPayload, alert.freq_once_per_bar_close)

if shortSignal and barstate.isconfirmed
    string _nodeTxt = nodeIs618 ? "61.8" : "38.2"
    string _confTxt = na(confPrice) ? "no" : "yes"
    string _retrTxt = str.tostring(nodeRetr * 100, "#.0")
    string _tp3Txt  = str.tostring(tp3Price, format.mintick)
    string _shortInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short","entry":"{3}","sl":"{4}","tp":"{5}","cop":"{6}","op":"{7}","xop":"{8}","node":"{9}","retrace":"{10}","confluence":"{11}"', i_actionShort, syminfo.tickerid, timeframe.period, str.tostring(entryPrice, format.mintick), str.tostring(slPrice, format.mintick), _tp3Txt, str.tostring(tp1Price, format.mintick), str.tostring(tp2Price, format.mintick), _tp3Txt, _nodeTxt, _retrTxt, _confTxt)
    string shortPayload = "{" + _shortInner + "}"
    alert(shortPayload, alert.freq_once_per_bar_close)
    if _preOpen and _preLong
        string _closeLongInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long"', i_actionCloseLong, syminfo.tickerid, timeframe.period)
        string closeLongPayload = "{" + _closeLongInner + "}"
        alert(closeLongPayload, alert.freq_once_per_bar_close)

if _tp1Fire
    string _copInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","level":"COP","price":"{4}"', i_actionCop, syminfo.tickerid, timeframe.period, _preLong ? "long" : "short", str.tostring(_preTp1, format.mintick))
    string copPayload = "{" + _copInner + "}"
    alert(copPayload, alert.freq_once_per_bar)

if _tp2Fire
    string _opInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","level":"OP","price":"{4}"', i_actionOp, syminfo.tickerid, timeframe.period, _preLong ? "long" : "short", str.tostring(_preTp2, format.mintick))
    string opPayload = "{" + _opInner + "}"
    alert(opPayload, alert.freq_once_per_bar)

if _tp3Fire
    string _xopInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","level":"XOP","price":"{4}"', i_actionXop, syminfo.tickerid, timeframe.period, _preLong ? "long" : "short", str.tostring(_preTp3, format.mintick))
    string xopPayload = "{" + _xopInner + "}"
    alert(xopPayload, alert.freq_once_per_bar)

if _slFire
    string _stopInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","level":"SL","price":"{4}"', i_actionStop, syminfo.tickerid, timeframe.period, _preLong ? "long" : "short", str.tostring(_preSl, format.mintick))
    string stopPayload = "{" + _stopInner + "}"
    alert(stopPayload, alert.freq_once_per_bar)

alertcondition(longSignal and barstate.isconfirmed, "BUY Signal", "MarkitTick — DiNapoli BUY Signal Fired")
alertcondition(shortSignal and barstate.isconfirmed, "SELL Signal", "MarkitTick — DiNapoli SELL Signal Fired")
alertcondition(shortSignal and barstate.isconfirmed and _preOpen and _preLong, "Close Long Signal", "MarkitTick — Close Long")
alertcondition(longSignal and barstate.isconfirmed and _preOpen and not _preLong, "Close Short Signal", "MarkitTick — Close Short")
alertcondition(_tp1Fire, "COP Reached", "MarkitTick — COP Objective Reached")
alertcondition(_tp2Fire, "OP Reached", "MarkitTick — OP Objective Reached")
alertcondition(_tp3Fire, "XOP Reached", "MarkitTick — XOP Objective Reached")
alertcondition(_slFire, "Stop Hit", "MarkitTick — Stop Hit")

// ── VISUALS ─────────────────────────────────────────────────
f_deleteLevels() =>
    line.delete(slLine)
    line.delete(entryLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)
    line.delete(n382Line)
    line.delete(n618Line)
    line.delete(confLine)
    label.delete(slLbl)
    label.delete(entryLbl)
    label.delete(tp1Lbl)
    label.delete(tp2Lbl)
    label.delete(tp3Lbl)
    label.delete(n382Lbl)
    label.delete(n618Lbl)
    label.delete(confLbl)

if _fire
    f_deleteLevels()
    n382Line := na
    n618Line := na
    confLine := na
    n382Lbl  := na
    n618Lbl  := na
    confLbl  := na
    int _x1 = bar_index
    int _x2 = bar_index + 10
    slLine    := line.new(_x1, slPrice, _x2, slPrice, color = C_SL, style = line.style_solid, width = 2)
    entryLine := line.new(_x1, entryPrice, _x2, entryPrice, color = C_ENTRY, style = line.style_dashed, width = 1)
    tp1Line   := line.new(_x1, tp1Price, _x2, tp1Price, color = C_TP1, style = line.style_dashed, width = 1)
    tp2Line   := line.new(_x1, tp2Price, _x2, tp2Price, color = C_TP2, style = line.style_dashed, width = 1)
    tp3Line   := line.new(_x1, tp3Price, _x2, tp3Price, color = C_TP3, style = line.style_dashed, width = 1)
    if i_showNodes
        if nodeIs618
            n382Line := line.new(_x1, node382, _x2, node382, color = C_N382, style = line.style_dotted, width = 1)
        else
            n618Line := line.new(_x1, node618, _x2, node618, color = C_N618, style = line.style_dotted, width = 1)
    if i_showConf and not na(confPrice)
        confLine := line.new(_x1, confPrice, _x2, confPrice, color = C_CONF, style = line.style_dashed, width = 2)
    array.fill(lvHost, -1)
    array.fill(lvHit, "")
    array.set(lvPx, 0, slPrice)
    array.set(lvPx, 1, entryPrice)
    array.set(lvPx, 2, tp1Price)
    array.set(lvPx, 3, tp2Price)
    array.set(lvPx, 4, tp3Price)
    array.set(lvPx, 5, i_showNodes ? (nodeIs618 ? node382 : node618) : float(na))
    array.set(lvPx, 6, i_showConf ? confPrice : float(na))
    array.set(lvName, 0, "✕ SL")
    array.set(lvName, 1, "▶ Entry " + (nodeIs618 ? "F 61.8" : "F 38.2"))
    array.set(lvName, 2, "◆ COP")
    array.set(lvName, 3, "✦ OP")
    array.set(lvName, 4, "◆ XOP")
    array.set(lvName, 5, nodeIs618 ? "F 38.2" : "F 61.8")
    array.set(lvName, 6, "◈ Conf")
    for i = 0 to 5
        if not na(array.get(lvPx, i))
            array.set(lvHost, i, f_hostOf(i))
    if not na(array.get(lvPx, 6))
        int _src = confIs618 == nodeIs618 ? 1 : 5
        array.set(lvHost, 6, not na(array.get(lvPx, _src)) ? array.get(lvHost, _src) : f_hostOf(6))
    array<color> _lvCol = array.from(C_SL, C_ENTRY, C_TP1, C_TP2, C_TP3, nodeIs618 ? C_N382 : C_N618, C_CONF)
    array<label> _lvLbl = array.new<label>(7, na)
    for i = 0 to 6
        if array.get(lvHost, i) == i
            array.set(_lvLbl, i, label.new(_x2, array.get(lvPx, i), f_lvText(i), style = label.style_label_left, color = array.get(_lvCol, i), textcolor = C_LBLTXT, size = size.small))
    for i = 0 to 6
        int _h = array.get(lvHost, i)
        if _h >= 0 and _h != i
            array.set(_lvLbl, i, array.get(_lvLbl, _h))
    slLbl    := array.get(_lvLbl, 0)
    entryLbl := array.get(_lvLbl, 1)
    tp1Lbl   := array.get(_lvLbl, 2)
    tp2Lbl   := array.get(_lvLbl, 3)
    tp3Lbl   := array.get(_lvLbl, 4)
    if nodeIs618
        n382Lbl := array.get(_lvLbl, 5)
    else
        n618Lbl := array.get(_lvLbl, 5)
    confLbl  := array.get(_lvLbl, 6)
    if i_showMarkers
        label.new(bar_index, isLong ? low : high, isLong ? "BULL" : "BEAR", yloc = isLong ? yloc.belowbar : yloc.abovebar, style = isLong ? label.style_label_up : label.style_label_down, color = isLong ? C_SUP : C_RES, textcolor = C_LBLTXT, size = size.small)

bool _extUpdate = _tradeClosed ? (not na(_closeBar) and _closeBar == bar_index) : barstate.islast

if not na(slLine) and _extUpdate
    int _extX = _tradeClosed ? _closeBar + 10 : last_bar_index + 10
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
    if not na(n382Line)
        line.set_x2(n382Line, _extX)
        label.set_x(n382Lbl, _extX)
    if not na(n618Line)
        line.set_x2(n618Line, _extX)
        label.set_x(n618Lbl, _extX)
    if not na(confLine)
        line.set_x2(confLine, _extX)
        label.set_x(confLbl, _extX)

plot(_dma, "DMA", color = i_showDma ? C_DMA : na, offset = i_dmaDisp)

// ── DASHBOARD ───────────────────────────────────────────────
f_tf() =>
    string _r = timeframe.period
    if timeframe.isseconds
        _r := str.tostring(timeframe.multiplier) + "s"
    else if timeframe.isminutes
        _r := timeframe.multiplier % 60 == 0 ? str.tostring(math.round(timeframe.multiplier / 60)) + "H" : str.tostring(timeframe.multiplier) + "m"
    else if timeframe.isdaily
        _r := str.tostring(timeframe.multiplier) + "D"
    else if timeframe.isweekly
        _r := str.tostring(timeframe.multiplier) + "W"
    else if timeframe.ismonthly
        _r := str.tostring(timeframe.multiplier) + "M"
    else if timeframe.isticks
        _r := str.tostring(timeframe.multiplier) + "T"
    _r

f_num(float v) =>
    float _a = math.abs(v)
    string _s = str.tostring(v, "#")
    if _a >= 1000000000
        _s := str.tostring(v / 1000000000, "#.#") + "B"
    else if _a >= 1000000
        _s := str.tostring(v / 1000000, "#.#") + "M"
    else if _a >= 1000
        _s := str.tostring(v / 1000, "#.#") + "K"
    _s

f_barColor(float pct) =>
    pct >= 0.66 ? color.new(C_BAR_HI, 0) : pct >= 0.33 ? color.new(C_BAR_MID, 0) : color.new(C_BAR_LO, 0)

f_bar(float val, float maxVal) =>
    float _ratio = val / maxVal
    int filled = math.round(math.min(_ratio, 1.0) * 10)
    string bar = ""
    for i = 1 to 10
        bar += i <= filled ? "█" : "░"
    bar + "  " + str.tostring(math.round(_ratio * 100)) + "%"

f_px(float v) =>
    na(v) ? "—" : str.tostring(v, format.mintick)

var table _dash = table.new(i_dashPos == "Top Left" ? position.top_left : i_dashPos == "Bottom Right" ? position.bottom_right : i_dashPos == "Bottom Left" ? position.bottom_left : position.top_right, 2, 20, border_width = 1, border_color = color.new(#2a3040, 40), frame_width = 1, frame_color = color.new(#3a2a6d, 40))
color _rowA   = C_DASH_BG
var color _rowB   = color.new(C_DASH_BG, 40)
var color _lblCol = color.new(C_DASH_TXT, 25)

f_row(int r, string lbl, string val, color vcol) =>
    color _bg = r % 2 == 1 ? _rowA : _rowB
    table.cell(_dash, 0, r, "  " + lbl, text_halign = text.align_left, text_color = _lblCol, text_size = size.small, bgcolor = _bg, text_font_family = font.family_monospace)
    table.cell(_dash, 1, r, val + "  ", text_halign = text.align_right, text_color = vcol, text_size = size.small, bgcolor = _bg, text_font_family = font.family_monospace)

if barstate.islast and i_showDash
    bool   _hasSet  = not na(entryPrice)
    string _biasTxt = _hasSet ? (isLong ? "BULL" : "BEAR") : "—"
    color  _biasCol = _hasSet ? (isLong ? C_SUP : C_RES) : C_DASH_TXT
    string _status  = na(slLine) ? "—" : slHit ? "SL HIT" : tp3Hit ? "XOP HIT" : tp2Hit ? "OP HIT" : tp1Hit ? "COP HIT" : "OPEN"
    float  _risk    = math.abs(entryPrice - slPrice)
    float  _rr      = _risk > 0 ? math.abs(tp2Price - entryPrice) / _risk : 0.0
    float  _rrPct   = math.min(_rr / 5.0, 1.0)
    float  _prog    = 0.0
    if _hasSet and tp2Price != entryPrice
        _prog := math.min(math.max((close - entryPrice) / (tp2Price - entryPrice), 0.0), 1.0)
    table.cell(_dash, 0, 0, "DiNapoli Levels", text_halign = text.align_left, text_color = C_DASH_TXT, text_size = size.small, bgcolor = C_DASH_HDR, text_font_family = font.family_monospace)
    table.cell(_dash, 1, 0, syminfo.prefix + ":" + syminfo.ticker + "  ·  " + f_tf(), text_halign = text.align_right, text_color = C_DASH_TXT, text_size = size.small, bgcolor = C_DASH_HDR, text_font_family = font.family_monospace)
    f_row(1, "Lock", i_lockSignal ? "ACTIVE" : "OFF", i_lockSignal ? C_RES : C_DASH_TXT)
    f_row(2, "Bias", _biasTxt, _biasCol)
    f_row(3, "Node", _hasSet ? (nodeIs618 ? "F 61.8" : "F 38.2") : "—", C_DASH_TXT)
    f_row(4, "Retrace", na(nodeRetr) ? "—" : f_bar(nodeRetr, 1.0), na(nodeRetr) ? C_DASH_TXT : f_barColor(nodeRetr))
    f_row(5, "Confluence", na(confPrice) ? "NO" : "YES", na(confPrice) ? C_DASH_TXT : C_SUP)
    f_row(6, "Entry", f_px(entryPrice), C_ENTRY)
    f_row(7, "Stop", f_px(slPrice), C_RES)
    f_row(8, "COP", f_px(tp1Price), C_SUP)
    f_row(9, "OP", f_px(tp2Price), C_SUP)
    f_row(10, "XOP", f_px(tp3Price), C_SUP)
    f_row(11, "R:R", _risk > 0 ? f_bar(_rr, 5.0) : "—", _risk > 0 ? f_barColor(_rrPct) : C_DASH_TXT)
    f_row(12, "To OP", _hasSet ? f_bar(_prog, 1.0) : "—", _hasSet ? f_barColor(_prog) : C_DASH_TXT)
    f_row(13, "Status", _status, slHit ? C_RES : tp1Hit ? C_SUP : C_DASH_TXT)
    f_row(14, "Swing", f_px(math.abs(swingSize)), C_DASH_TXT)
    f_row(15, "ATR", f_px(_atr), C_DASH_TXT)
    f_row(16, "Bars Since", na(signalBar) ? "—" : f_num(bar_index - signalBar), C_DASH_TXT)
    f_row(17, "ADX", i_useAdx ? f_bar(math.min(_adx, 100.0), 100.0) : "OFF", i_useAdx ? f_barColor(math.min(_adx, 100.0) / 100.0) : C_DASH_TXT)
    f_row(18, "HTF Bias", not i_useHtf ? "OFF" : na(_htfClose) ? "—" : close > _htfClose ? "BULL" : "BEAR", not i_useHtf or na(_htfClose) ? C_DASH_TXT : close > _htfClose ? C_SUP : C_RES)
    f_row(19, "Smoothing", i_useSmooth ? i_smoothMethod : "OFF", C_DASH_TXT)
````
