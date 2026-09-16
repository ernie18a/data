<!-- tradingview-pine-id: PUB;86e0c6d2c7ed45edbbcb32dd2c3ea7f8 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Trident Swing Projector [MarkitTick]

Source: https://www.tradingview.com/script/VwFBVQ65-Trident-Swing-Projector-MarkitTick/

## Description

💡 A structured swing-projection tool that automates Charles Lindsay's Trident quarter-swing method, turning a manual charting technique into a filtered, alert-ready framework for identifying retracement setups and projecting forward trade levels from a confirmed three-point swing structure.

✨ Originality and Utility

This script's value is not in reinventing pivot detection — left/right bar pivot confirmation is a known technique — but in the specific architecture built around it. The 25/50/75/100% level ladder projected from the retracement point follows the quarter-swing framework described by Charles Lindsay in his Trident work: a method of projecting Support/Resistance, Critical, and Equality points from a confirmed A-B-C swing. Everything surrounding that ladder — the pullback-depth gate, the dominant-trend filter, the ADX and higher-timeframe confluence layers, the configurable stop buffer, the armed-setup expiry, and the post-TP1 break-even handling — are MarkitTick design additions layered on top of Lindsay's original concept, not part of it.

The reason these pieces are combined rather than published separately is that a quarter-swing projection on its own is only as useful as the swing that produced it. A shallow, weak, or counter-trend retracement produces a projection ladder that is statistically less meaningful than one built from a decisive, trend-aligned impulse. The trend filter, pullback-depth window, ADX threshold, and HTF bias check all exist to answer one question before a projection is drawn: was this A-B leg significant enough to justify projecting from it? The trade-management layer (stop buffer, expiry, break-even) then exists to turn that projection into something that can be monitored and alerted on in real time, rather than only viewed as a static drawing. Each component is a gate or a consequence of the others; none of them functions as an independent indicator bolted on for its own sake.

The script is an indicator, not a strategy — it does not backtest or simulate equity. It identifies swing structures, projects levels from them, tracks whether those levels are subsequently reached, and reports all of this through a live dashboard and structured alert payloads.

🔬 Methodology and Concepts

● Confirmed Pivot Detection

Swing highs and lows are identified using a left/right bar-count pivot method: a candidate high or low is only confirmed once it has stood as the extreme point across both the bars to its left and the bars to its right, using the Pivot Left and Pivot Right settings. Because the check always references bars that have already closed, a pivot is never inferred from the currently forming bar — it is published exactly one bar after its right-side confirmation window completes. This is a deliberate implementation choice made to keep pivot detection non-repainting.

● The A-B-C Swing Structure

Once two consecutive confirmed pivots exist, the script watches for a third pivot that retraces into the prior leg:

[*]Point A — the origin pivot (a confirmed swing low ahead of a bullish setup, or swing high ahead of a bearish one).
[*]Point B — the impulse pivot that follows A, defining the A-B leg.
[*]Point C — a new, opposing pivot that pulls back into the A-B leg by a percentage between the Min Pullback % and Max Pullback % settings (23.6–78.6% by default). Pullbacks shallower or deeper than this window are rejected and no setup is formed.

If the Trend Filter is enabled, the A-B leg must also break the previous confirmed swing extreme in the same direction (B must exceed the prior swing high for a bullish setup, or undercut the prior swing low for a bearish one) before a retracement at C is allowed to qualify. This restricts setups to legs that are extending the dominant swing rather than forming inside a range.

● Leg Measurement and Smoothing

The A-B leg is measured either in raw price points or as a percentage move, depending on the Swing Unit setting. Before that leg size is used to derive projection levels, it can optionally be passed through one of five smoothing methods — SMA, RMA, WMA, HMA, or VWMA — set by Signal Smoothing and Smoothing Length. The smoothing is applied as a ratio between the smoothed and raw leg size and multiplied into the current leg, so that projection distances are influenced by the recent typical swing size on the instrument rather than reacting entirely to the size of a single leg. With Signal Smoothing set to None, the raw leg size is used unmodified.

● Quarter-Swing Level Projection

From point C, four levels are projected using fixed fractions of the A-B leg, applied in the direction of the new setup:

[*]25% of the leg → Entry level.
[*]50% of the leg → TP1, labeled as the Critical level in Lindsay's terminology.
[*]75% of the leg → TP2.
[*]100% of the leg → TP3, the Equality target — a projected swing from C equal in size to the original A-B leg.

The Stop is placed at point C itself, with an optional buffer applied beyond it — either a fixed number of ticks or a fraction of the current ATR (ATR Length setting) — configured through Stop Buffer, Buffer Ticks, and Buffer ATR Fraction.

● Confluence Filters

Two independent filters can each block a setup from arming even after a valid A-B-C structure is found:

[*]ADX Filter — requires the DMI-derived ADX value (ADX Length setting) to be at or above the ADX Threshold before a setup is allowed to arm, intended to avoid projecting swing levels during weak-trend, low directional-strength conditions.
[*]HTF Confirmation — requests a higher timeframe's close (HTF Timeframe setting) and compares it against the prior higher-timeframe close to derive a simple directional bias. A setup is only allowed to arm if this bias agrees with the setup's direction. The higher-timeframe read uses a confirmed prior-bar close with lookahead correctly paired to that offset, so this filter does not draw on unconfirmed higher-timeframe data.

● Trade Management and State

Once a setup arms, it steps through a defined state sequence: Armed, Active (entry triggered), TP1 hit, TP2 hit, TP3 hit, Stopped, or Cancelled. Entry triggers when a confirmed close crosses the Entry level; a setup is cancelled if its Armed Expiry Bars limit is reached before entry, or if price closes back through point C first. If Stop to Breakeven after TP1 is enabled, the internally tracked stop moves to the entry price once TP1 is hit — this managed stop is reported in the dashboard and in alert payloads, but the stop line and label drawn on the chart intentionally remain at the original level, so the chart never displays a level implying a fill that did not actually occur at that price.

● Confirmation Lag Notice

Because pivot confirmation requires Pivot Right bars to elapse, and entry/cancellation logic checks a confirmed prior-bar close, every swing structure, entry trigger, and cancellation event appears with a built-in lag relative to the exact bar that produced it. This is a structural trade-off, not a defect: it is what keeps the A-B-C structure and its projected levels from repainting once drawn. Separately, TP1/TP2/TP3 target detection and the corresponding alerts monitor the current bar's high/low in real time rather than waiting for bar close, so a target can be marked and alerted as reached intrabar, before that bar has finished forming. This is standard behavior for real-time level-touch monitoring, but it means the exact moment a target fires can occur before the bar closes.

🎨 Visual Guide

[*]A · B · C labels — small grey markers placed at the three confirmed pivots that define the active setup, drawn once the pattern is confirmed (so they sit slightly in the past relative to the bar that produced them).
[*]Projected Leg — a dashed grey line running from point C forward to the TP3 price level, spanning a time distance matched to the original A-B leg's bar length. This shows the projection visually before price has necessarily reached it.
[*]Entry line and label — a dashed blue line at the 25% projection level, labeled with the exact price.
[*]Stop line and label — a solid line at point C (plus buffer, if configured), colored to match the Bearish color setting, labeled with the exact price. The label updates to show a hit confirmation and the resulting percentage move once the stop is reached, noting separately if the exit was a trend-failure stop or a break-even exit.
[*]TP1 / TP2 / TP3 lines and labels — dashed lines at the 50/75/100% levels, each labeled with price and the resulting reward-to-risk multiple. Each label updates to show a hit confirmation and percentage move once reached.
[*]BULL / BEAR entry marker — a small label placed at the bar where the Entry level is actually crossed, confirming the setup transitioned from Armed to Active.
[*]Dashboard table — a live panel (toggled and positioned via the Dashboard settings) showing direction, state, entry/stop/managed-stop/target prices, reward-to-risk bars for each target, pullback depth, A-B swing size, bars since entry, HTF bias, ADX condition, and active smoothing method.
[*]Non-standard chart warning — if the chart is displaying Heikin Ashi, Renko, Kagi, Point & Figure, Linebreak, or Range bars, a warning label appears directly on the chart, since projected price levels are not meaningful on synthetic bar types.

📖 How to Use

[*]Wait for a confirmed A-B-C structure to complete. The A and B markers appear once a swing has formed, and the C marker (with entry/stop/target lines) appears only once a pullback within the configured percentage window is confirmed.
[*]Treat the Entry line as the level the script is watching for a confirmed close through, not an instruction to enter immediately at C.
[*]Use the Stop line as the invalidation level for the setup — a confirmed close back through point C cancels an armed setup outright.
[*]Read TP1 (Critical), TP2, and TP3 (Equality) as sequential projection targets rather than a single expected outcome; the dashboard's reward-to-risk bars for each target update as price approaches or reaches them.
[*]Check the HTF Bias and ADX rows in the dashboard if those filters are enabled, to understand why a structurally valid A-B-C pattern may not have armed.
[*]Use the webhook alert payload's state and event fields to drive automation, rather than relying on price levels alone, since the payload also reports the managed (break-even) stop separately from the originally drawn stop.

⚙️ Inputs and Settings

● Core

[*]Pivot Left / Pivot Right — bar counts required on each side of a swing point before it is confirmed as a pivot. Larger values produce fewer, more significant, and later-confirmed pivots.
[*]Swing Unit — measures the A-B leg in raw price Points or as a Percent move, changing how leg size (and therefore all projected distances) is calculated.

● Filters

[*]Trend Filter — requires the A-B leg to break the prior confirmed swing extreme in the setup's direction.
[*]Min Pullback % / Max Pullback % — the acceptable retracement depth window for point C, as a percentage of the A-B leg.
[*]HTF Confirmation / HTF Timeframe — requires a higher-timeframe directional bias to agree with the setup direction before arming.
[*]ADX Filter / ADX Length / ADX Threshold — requires trend strength (via DMI/ADX) to clear a minimum threshold before arming.
[*]Signal Smoothing / Smoothing Length — applies SMA, RMA, WMA, HMA, or VWMA smoothing to the leg magnitude used for projections.

● Trade Tools

[*]Lock Signal — freezes the current signal and blocks any new setup from arming.
[*]Stop Buffer / Buffer Ticks / Buffer ATR Fraction / ATR Length — adds extra distance beyond point C when placing the stop, either as a fixed tick count or a fraction of ATR.
[*]Armed Expiry Bars — cancels an armed (not yet triggered) setup if the Entry level isn't closed through within this many bars.
[*]Stop to Breakeven after TP1 — moves the internally tracked (managed) stop to entry once TP1 is hit, reported in the dashboard and alerts without moving the drawn stop line.

● Visuals and Dashboard

[*]Trade Levels / A · B · C Markers / Projected Leg / Entry Markers — independent toggles for each chart element.
[*]Keep Last N Setups — limits how many historical setups' drawings remain on the chart, to stay within drawing object limits.
[*]Show Dashboard / Position — toggles and positions the live info panel.

● Alerts

[*]Long / Short / Close Long / Close Short / Info Action strings — customizable text values inserted into the "action" field of the JSON alert payload, for direct use in webhook automation.

● Colors

[*]Independent color controls for bullish/bearish/neutral tones, stop, entry, target, A·B·C markers, projected leg, label text, and dashboard header/body/text colors.

🔍 Deconstruction of the Underlying Scientific and Academic Framework

The projection ladder at the core of this script is drawn from the Trident method associated with Charles Lindsay, a framework built around measuring a swing's magnitude and projecting proportional fractions of it forward from a retracement point to derive Support/Resistance, Critical, and Equality levels. The underlying premise is that markets frequently move in self-similar proportional legs, so a retracement of a known size can be used to project plausible forward extension distances — the 50% "Critical" level and the 100% "Equality" level (a projected move matching the original leg) are the two most emphasized points in that framework, reflected here in TP1 and TP3 respectively.

The pullback-depth window applied to point C (23.6–78.6% by default) situates the acceptable retracement zone within a range commonly associated with Fibonacci retracement theory, without asserting that Fibonacci ratios themselves drive the projection math — the projection ladder here is a fixed 25/50/75/100% division of the leg, independent of the retracement percentage that qualified point C.

The ADX/DMI filter is grounded in Welles Wilder's directional movement framework, which measures trend strength by comparing the smoothed magnitude of directional price movement to overall volatility; applying a minimum threshold is a common approach to excluding range-bound conditions from directional setups, though ADX is a lagging, smoothed measure and does not itself predict continuation.

The higher-timeframe bias filter reflects multi-timeframe confluence theory: the idea that a directional bias visible on a longer aggregation of price is a useful, if imperfect, filter for shorter-timeframe setups, since it reduces (but does not eliminate) the chance of trading against the prevailing higher-timeframe trend.

The leg-smoothing step applies standard moving-average theory (simple, exponential-family, weighted, Hull, and volume-weighted variants) not to price directly, but to the derived leg-size series, an approach intended to make projected distances reflect a instrument's typical recent swing amplitude rather than the idiosyncrasies of a single leg.

⚠️ Disclaimer
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick

//@version=6
indicator(title = "Trident Swing Projector [MarkitTick]", overlay = true, max_bars_back = 500, max_lines_count = 500, max_labels_count = 500)

// ── INPUTS ──────────────────────────────────────────────────
var string GRP_CORE  = "⚙️ Core"
var string GRP_FILT  = "🕯️ Filters"
var string GRP_TRADE = "📐 Trade Tools"
var string GRP_VIS   = "🎨 Visuals"
var string GRP_DASH  = "📊 Dashboard"
var string GRP_WH    = "🔔 Alerts"
var string GRP_COL   = "🌈 Colors"

i_pivotLeft    = input.int(5, "Pivot Left", minval = 1, maxval = 50, group = GRP_CORE, tooltip = "Bars required to the left of a swing point before it is treated as a confirmed pivot.\n\nMETHOD NOTE — Level ladder: the 25/50/75/100% projection follows Charles Lindsay's Trident quarter-swing concept. The pullback window, trend filter, stop buffer, entry expiry and break-even option are MarkitTick design choices, not part of Lindsay's original method. This tool projects levels only and makes no claim about profitability.")
i_pivotRight   = input.int(5, "Pivot Right", minval = 1, maxval = 50, group = GRP_CORE, tooltip = "Bars required to the right of a swing point before it is confirmed. The pivot is published one bar after this window completes, so the currently forming bar is never read. Higher values give fewer, later pivots.")
i_swingUnit    = input.string("Points", "Swing Unit", options = ["Points", "Percent"], group = GRP_CORE, tooltip = "Points: the projected leg equals the A-B leg measured in price units.\nPercent: the projected leg equals the A-B leg percentage move, applied from point C.")

i_useTrend     = input.bool(true, "Trend Filter", group = GRP_FILT, tooltip = "Require the A-B impulse to break the previous confirmed swing high (bullish) or swing low (bearish), so setups only follow the dominant swing direction. MarkitTick design choice, not part of Lindsay's original method.")
i_minPullback  = input.float(23.6, "Min Pullback %", minval = 0.0, maxval = 100.0, step = 0.1, group = GRP_FILT, tooltip = "Minimum depth of the B-C pullback as a percentage of the A-B leg. Shallower pullbacks are rejected. MarkitTick design choice.")
i_maxPullback  = input.float(78.6, "Max Pullback %", minval = 0.0, maxval = 100.0, step = 0.1, group = GRP_FILT, tooltip = "Maximum depth of the B-C pullback as a percentage of the A-B leg. Deeper pullbacks are rejected. MarkitTick design choice.")
i_useHtf       = input.bool(false, "HTF Confirmation", group = GRP_FILT, tooltip = "Require the higher-timeframe swing bias to agree with the pattern direction before a setup can arm. MarkitTick design choice.")
i_htfTf        = input.timeframe("240", "HTF Timeframe", group = GRP_FILT, tooltip = "Higher timeframe read for the confirmation bias.")
i_useAdx       = input.bool(false, "ADX Filter", group = GRP_FILT, tooltip = "Block setups when trend strength is below the ADX threshold. MarkitTick design choice.")
i_adxLen       = input.int(14, "ADX Length", minval = 1, maxval = 100, group = GRP_FILT, tooltip = "DI/ADX smoothing period.")
i_adxThresh    = input.float(20.0, "ADX Threshold", minval = 0.0, maxval = 100.0, step = 0.5, group = GRP_FILT, tooltip = "Minimum ADX value required to allow a setup to arm.")
i_smoothMethod = input.string("None", "Signal Smoothing", options = ["None", "SMA", "RMA", "WMA", "HMA", "VWMA"], group = GRP_FILT, tooltip = "Smoothing method applied to the A-B leg magnitude before it is used to derive entry and target levels. MarkitTick design choice.")
i_smoothLen    = input.int(5, "Smoothing Length", minval = 1, maxval = 100, group = GRP_FILT, tooltip = "Length used by the selected smoothing method.")

i_lockSignal   = input.bool(false, "🔒 Lock Signal", group = GRP_TRADE, tooltip = "Freeze current signal · block new ones")
i_stopBufMode  = input.string("None", "Stop Buffer", options = ["None", "Ticks", "ATR Fraction"], group = GRP_TRADE, tooltip = "Extra distance placed beyond point C when setting the stop. MarkitTick design choice.")
i_stopBufTicks = input.int(0, "Buffer Ticks", minval = 0, maxval = 10000, group = GRP_TRADE, tooltip = "Applied when Stop Buffer is set to Ticks.")
i_stopBufAtr   = input.float(0.0, "Buffer ATR Fraction", minval = 0.0, maxval = 10.0, step = 0.05, group = GRP_TRADE, tooltip = "Applied when Stop Buffer is set to ATR Fraction.")
i_atrLen       = input.int(14, "ATR Length", minval = 1, maxval = 500, group = GRP_TRADE, tooltip = "Length of the ATR used by the ATR Fraction stop buffer.")
i_expiryBars   = input.int(20, "Armed Expiry Bars", minval = 1, maxval = 500, group = GRP_TRADE, tooltip = "Cancel an armed setup if the entry level is not closed through within this many bars. MarkitTick design choice.")
i_useBreakeven = input.bool(false, "Stop to Breakeven after TP1", group = GRP_TRADE, tooltip = "After TP1 is reached, manage the stop at the entry price. The managed stop is reported in the dashboard and in alert payloads only; the drawn stop line and its label stay at the original level, so no level label claims a hit the market did not trade. MarkitTick design choice, not part of Lindsay's original method.")

i_showLevels   = input.bool(true, "Trade Levels", group = GRP_VIS)
i_showABC      = input.bool(true, "A · B · C Markers", group = GRP_VIS, tooltip = "Mark the three pattern points at their own pivot bars. A marker is drawn only once the pattern is confirmed, which is Pivot Right + 1 bars after the pivot itself, so it appears in the past relative to the bar that created it.")
i_showProj     = input.bool(true, "Projected Leg", group = GRP_VIS)
i_showMarker   = input.bool(true, "Entry Markers", group = GRP_VIS)
i_histCount    = input.int(1, "Keep Last N Setups", minval = 1, maxval = 20, group = GRP_VIS, tooltip = "Older drawing sets are removed to stay inside TradingView drawing object limits.")

i_showDash     = input.bool(true, "Show Dashboard", group = GRP_DASH)
i_dashPos      = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GRP_DASH)

i_actionLong       = input.string("long",       "↑ Long Action",        group = GRP_WH)
i_actionShort      = input.string("short",      "↓ Short Action",       group = GRP_WH)
i_actionCloseLong  = input.string("closelong",  "✕ Close Long Action",  group = GRP_WH)
i_actionCloseShort = input.string("closeshort", "✕ Close Short Action", group = GRP_WH)
i_actionInfo       = input.string("info",       "• Info Action",        group = GRP_WH)

C_SUP      = input.color(#26a69a, "Bullish", group = GRP_COL)
C_RES      = input.color(#ef5350, "Bearish", group = GRP_COL)
C_MID      = input.color(#f9a825, "Neutral", group = GRP_COL)
C_SL       = input.color(#ef5350, "Stop", group = GRP_COL)
C_ENTRY    = input.color(#2196f3, "Entry", group = GRP_COL)
C_TP       = input.color(#26a69a, "Targets", group = GRP_COL)
C_ABC      = input.color(#787b86, "A · B · C", group = GRP_COL)
C_PROJ     = input.color(#787b86, "Projected Leg", group = GRP_COL)
C_TXT      = input.color(#ffffff, "Label Text", group = GRP_COL)
C_DASH_HDR = input.color(color.new(#3a2a6d, 55), "Dash Header", group = GRP_COL)
C_DASH_BG  = input.color(color.new(#0a0f1a, 10), "Dash Body", group = GRP_COL)
C_DASH_TXT = input.color(#ffffff, "Dash Text", group = GRP_COL)

// ── UDTs ────────────────────────────────────────────────────
type TradeArt
    line  slLine
    line  entryLine
    line  tp1Line
    line  tp2Line
    line  tp3Line
    line  projLine
    label slLbl
    label entryLbl
    label tp1Lbl
    label tp2Lbl
    label tp3Lbl
    label aLbl
    label bLbl
    label cLbl
    label markLbl

// ── CORE LOGIC ──────────────────────────────────────────────
f_tfTxt() =>
    string _r = timeframe.period
    if timeframe.isseconds
        _r := str.tostring(timeframe.multiplier, "#") + "s"
    else if timeframe.isminutes
        _r := timeframe.multiplier % 60 == 0 ? str.tostring(timeframe.multiplier / 60, "#") + "H" : str.tostring(timeframe.multiplier, "#") + "m"
    else if timeframe.isdaily
        _r := str.tostring(timeframe.multiplier, "#") + "D"
    else if timeframe.isweekly
        _r := str.tostring(timeframe.multiplier, "#") + "W"
    else if timeframe.ismonthly
        _r := str.tostring(timeframe.multiplier, "#") + "M"
    _r

f_num(float v) =>
    float _a = math.abs(v)
    _a >= 1e9 ? str.tostring(v / 1e9, "#.#") + "B" : _a >= 1e6 ? str.tostring(v / 1e6, "#.#") + "M" : _a >= 1e3 ? str.tostring(v / 1e3, "#.#") + "K" : str.tostring(v, "#.##")

f_pctTxt(float lvl, float entry, bool isLong) =>
    float _p = na(entry) or entry == 0 ? na : (isLong ? lvl - entry : entry - lvl) / entry * 100
    na(_p) ? "—" : (_p >= 0 ? "+" : "") + str.tostring(_p, "#.00") + "%"

f_rr(float lvl, float entry, float risk) =>
    na(lvl) or na(entry) or na(risk) or risk <= 0 ? 0.0 : math.abs(lvl - entry) / risk

f_bar(float val, float maxVal) =>
    float _r = math.min(math.max(nz(val) / maxVal, 0.0), 1.0)
    int _filled = math.round(_r * 10)
    string _b = ""
    for i = 1 to 10
        _b += i <= _filled ? "█" : "░"
    _b + "  " + str.tostring(math.round(_r * 100), "#") + "%"

f_barColor(float pct) =>
    pct >= 0.66 ? C_SUP : pct >= 0.33 ? C_MID : C_RES

f_stateTxt(int s) =>
    s == 1 ? "Armed" : s == 2 ? "Active" : s == 3 ? "TP1 hit" : s == 4 ? "TP2 hit" : s == 5 ? "TP3 hit" : s == 6 ? "Stopped" : s == 7 ? "Cancelled" : "—"

f_dashPos(string p) =>
    p == "Top Left" ? position.top_left : p == "Bottom Right" ? position.bottom_right : p == "Bottom Left" ? position.bottom_left : position.top_right

f_smoothPick(string method, float vSma, float vRma, float vWma, float vHma, float vVwma, float vNone) =>
    method == "SMA" ? vSma : method == "RMA" ? vRma : method == "WMA" ? vWma : method == "HMA" ? vHma : method == "VWMA" ? vVwma : vNone

f_pivotHigh(int lLen, int rLen) =>
    float _cand  = high[rLen + 1]
    float _newer = ta.highest(high[1], rLen)
    float _older = ta.highest(high[rLen + 2], lLen)
    bool  _ok    = bar_index >= lLen + rLen + 1 and _cand > _newer and _cand > _older
    _ok ? _cand : na

f_pivotLow(int lLen, int rLen) =>
    float _cand  = low[rLen + 1]
    float _newer = ta.lowest(low[1], rLen)
    float _older = ta.lowest(low[rLen + 2], lLen)
    bool  _ok    = bar_index >= lLen + rLen + 1 and _cand < _newer and _cand < _older
    _ok ? _cand : na

float _ph     = f_pivotHigh(i_pivotLeft, i_pivotRight)
float _pl     = f_pivotLow(i_pivotLeft, i_pivotRight)
int   _pivBar = bar_index - i_pivotRight - 1
float _atr    = ta.atr(i_atrLen)
float _buf    = i_stopBufMode == "Ticks" ? i_stopBufTicks * syminfo.mintick : i_stopBufMode == "ATR Fraction" ? nz(_atr) * i_stopBufAtr : 0.0

float _htfClose  = request.security(syminfo.tickerid, i_htfTf, close[1], lookahead = barmerge.lookahead_on)
float _htfClose1 = request.security(syminfo.tickerid, i_htfTf, close[2], lookahead = barmerge.lookahead_on)
int   _htfBias   = not na(_htfClose) and not na(_htfClose1) ? (_htfClose > _htfClose1 ? 1 : _htfClose < _htfClose1 ? -1 : 0) : 0

[_diP, _diM, _adx] = ta.dmi(i_adxLen, i_adxLen)
bool _adxOk = not i_useAdx or _adx >= i_adxThresh

var float lastPH    = na
var int   lastPHBar = na
var float prevPH    = na
var float lastPL    = na
var int   lastPLBar = na
var float prevPL    = na

var float _legSrc = na
if not na(lastPH) and not na(lastPL)
    _legSrc := math.abs(lastPH - lastPL)
float _legForSmooth = nz(_legSrc)
float _legSma  = ta.sma(_legForSmooth, i_smoothLen)
float _legRma  = ta.rma(_legForSmooth, i_smoothLen)
float _legWma  = ta.wma(_legForSmooth, i_smoothLen)
float _legHma  = ta.hma(_legForSmooth, i_smoothLen)
float _legVwma = ta.vwma(_legForSmooth, i_smoothLen)
float _legSmoothed = f_smoothPick(i_smoothMethod, _legSma, _legRma, _legWma, _legHma, _legVwma, _legForSmooth)
float _smoothRatio = _legForSmooth != 0 ? _legSmoothed / _legForSmooth : 1.0

var int    st          = 0
var int    stDir       = 0
var float  stA         = na
var int    stABar      = na
var float  stB         = na
var int    stBBar      = na
var float  stC         = na
var int    stCBar      = na
var float  stLeg       = na
var float  stPb        = na
var float  stEntry     = na
var float  stStop      = na
var float  stMgStop    = na
var float  stTp1       = na
var float  stTp2       = na
var float  stTp3       = na
var float  stRisk      = na
var int    stArmBar    = na
var int    stEntryBar  = na
var string stReason    = ""
var bool   stTrendFail = false
var int    _closeBar   = na

int   _cDir  = 0
float _cA    = na
int   _cABar = na
float _cB    = na
int   _cBBar = na
float _cC    = na
int   _cCBar = na
float _cLeg  = na
float _cPb   = na

if not na(_pl) and not na(lastPL) and not na(lastPH) and lastPLBar < lastPHBar and lastPHBar < _pivBar and _pl > lastPL
    float _ab = lastPH - lastPL
    if _ab > 0
        float _pb = (lastPH - _pl) / _ab * 100
        bool _trendOk = not i_useTrend or (not na(prevPH) and lastPH > prevPH)
        if _pb >= i_minPullback and _pb <= i_maxPullback and _trendOk
            _cDir  := 1
            _cA    := lastPL
            _cABar := lastPLBar
            _cB    := lastPH
            _cBBar := lastPHBar
            _cC    := _pl
            _cCBar := _pivBar
            _cLeg  := (i_swingUnit == "Percent" and lastPL != 0 ? _pl * (_ab / lastPL) : _ab) * _smoothRatio
            _cPb   := _pb

if _cDir == 0 and not na(_ph) and not na(lastPH) and not na(lastPL) and lastPHBar < lastPLBar and lastPLBar < _pivBar and _ph < lastPH
    float _ab = lastPH - lastPL
    if _ab > 0
        float _pb = (_ph - lastPL) / _ab * 100
        bool _trendOk = not i_useTrend or (not na(prevPL) and lastPL < prevPL)
        if _pb >= i_minPullback and _pb <= i_maxPullback and _trendOk
            _cDir  := -1
            _cA    := lastPH
            _cABar := lastPHBar
            _cB    := lastPL
            _cBBar := lastPLBar
            _cC    := _ph
            _cCBar := _pivBar
            _cLeg  := (i_swingUnit == "Percent" and lastPH != 0 ? _ph * (_ab / lastPH) : _ab) * _smoothRatio
            _cPb   := _pb

if not na(_ph)
    prevPH    := lastPH
    lastPH    := _ph
    lastPHBar := _pivBar
if not na(_pl)
    prevPL    := lastPL
    lastPL    := _pl
    lastPLBar := _pivBar

int  _st0     = st
bool _isL     = stDir == 1
bool _open    = _st0 >= 2 and _st0 <= 4
bool _wasBusy = _st0 == 1 or _open

bool _cancelBreak = _st0 == 1 and (_isL ? low[1] < stC : high[1] > stC)
bool _cancelExp   = _st0 == 1 and bar_index - stArmBar >= i_expiryBars
bool _cancelled   = _cancelBreak or _cancelExp
bool _entryTrig   = _st0 == 1 and not _cancelled and (_isL ? close[1] >= stEntry : close[1] <= stEntry)

bool _slCross = (_open or _entryTrig) and (_isL ? low <= stMgStop : high >= stMgStop)
bool _c1      = (_open or _entryTrig) and (_isL ? high >= stTp1 : low <= stTp1)
bool _c2      = (_open or _entryTrig) and (_isL ? high >= stTp2 : low <= stTp2)
bool _c3      = (_open or _entryTrig) and (_isL ? high >= stTp3 : low <= stTp3)

bool _hitSL = _slCross
bool _hitT1 = not _slCross and _c1 and (_st0 == 2 or _entryTrig)
bool _hitT2 = not _slCross and _c2 and (_st0 <= 3 or _entryTrig)
bool _hitT3 = not _slCross and _c3 and (_st0 <= 4 or _entryTrig)

bool _beExit     = _hitSL and stMgStop != stStop
bool _drawnSlHit = _hitSL and stMgStop == stStop

if _cancelled
    st       := 7
    stReason := _cancelBreak ? "C broken" : "Expired"
else if _entryTrig
    st         := 2
    stEntryBar := bar_index
    stReason   := ""

if _hitSL
    stTrendFail := _st0 == 2
    stReason    := _st0 == 2 ? "Trend failure" : _beExit ? "Breakeven" : "Stopped"
    st          := 6
else if _hitT3
    st       := 5
    stReason := "TP3 target"
else if _hitT2
    st := 4
else if _hitT1
    st := 3

if i_useBreakeven and _hitT1 and st >= 3 and st <= 4
    stMgStop := stEntry

bool _setClosed = st >= 5
if _setClosed and na(_closeBar)
    _closeBar := bar_index

bool _frozen = i_lockSignal and barstate.islast

bool _busy    = st == 1 or (st >= 2 and st <= 4)
bool _htfOk   = not i_useHtf or _htfBias == _cDir
bool newArmed = _cDir != 0 and _cLeg > 0 and not _busy and not _wasBusy and not _frozen and _htfOk and _adxOk

if newArmed
    stDir       := _cDir
    stA         := _cA
    stABar      := _cABar
    stB         := _cB
    stBBar      := _cBBar
    stC         := _cC
    stCBar      := _cCBar
    stLeg       := _cLeg
    stPb        := _cPb
    stEntry     := _cDir == 1 ? _cC + 0.25 * _cLeg : _cC - 0.25 * _cLeg
    stTp1       := _cDir == 1 ? _cC + 0.50 * _cLeg : _cC - 0.50 * _cLeg
    stTp2       := _cDir == 1 ? _cC + 0.75 * _cLeg : _cC - 0.75 * _cLeg
    stTp3       := _cDir == 1 ? _cC + 1.00 * _cLeg : _cC - 1.00 * _cLeg
    stStop      := _cDir == 1 ? _cC - _buf : _cC + _buf
    stMgStop    := stStop
    stRisk      := math.abs(stEntry - stStop)
    stArmBar    := bar_index
    stEntryBar  := na
    stReason    := ""
    stTrendFail := false
    _closeBar   := na
    st          := 1

// ── ALERTS ──────────────────────────────────────────────────
string _dirTxt   = stDir == 1 ? "long" : "short"
string _actEntry = stDir == 1 ? i_actionLong : i_actionShort
string _actClose = stDir == 1 ? i_actionCloseLong : i_actionCloseShort

f_payload(string act, string ev) =>
    string _inner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","event":"{4}","state":"{5}","entry":"{6}","sl":"{7}","sl_managed":"{8}","tp1":"{9}","tp2":"{10}","tp3":"{11}","ab_size":"{12}","rr_tp3":"{13}"', act, syminfo.tickerid, timeframe.period, _dirTxt, ev, f_stateTxt(st), str.tostring(stEntry, format.mintick), str.tostring(stStop, format.mintick), str.tostring(stMgStop, format.mintick), str.tostring(stTp1, format.mintick), str.tostring(stTp2, format.mintick), str.tostring(stTp3, format.mintick), str.tostring(stLeg, format.mintick), str.tostring(f_rr(stTp3, stEntry, stRisk), "#.00"))
    "{" + _inner + "}"

if newArmed and barstate.isconfirmed
    alert(f_payload(i_actionInfo, "armed"), alert.freq_once_per_bar_close)
if _entryTrig and barstate.isconfirmed
    alert(f_payload(_actEntry, "entry"), alert.freq_once_per_bar_close)
if _cancelled and barstate.isconfirmed
    alert(f_payload(i_actionInfo, "cancelled"), alert.freq_once_per_bar_close)
if _hitSL and barstate.isconfirmed
    alert(f_payload(_actClose, stTrendFail ? "trend_failure" : _beExit ? "breakeven" : "stop"), alert.freq_once_per_bar_close)
if _hitT3
    alert(f_payload(_actClose, "tp3"), alert.freq_once_per_bar)
else if _hitT2
    alert(f_payload(_actClose, "tp2"), alert.freq_once_per_bar)
else if _hitT1
    alert(f_payload(_actClose, "tp1"), alert.freq_once_per_bar)

alertcondition(newArmed and barstate.isconfirmed, "Trident Setup Armed", "MarkitTick Trident — setup armed on {{ticker}} {{interval}}")
alertcondition(_entryTrig and barstate.isconfirmed, "Trident Entry Triggered", "MarkitTick Trident — entry triggered on {{ticker}} {{interval}} at {{close}}")
alertcondition(_hitT1, "Trident TP1 Hit", "MarkitTick Trident — TP1 Critical Price reached on {{ticker}} {{interval}}")
alertcondition(_hitT2, "Trident TP2 Hit", "MarkitTick Trident — TP2 reached on {{ticker}} {{interval}}")
alertcondition(_hitT3, "Trident TP3 Hit", "MarkitTick Trident — TP3 swing-equality target reached on {{ticker}} {{interval}}")
alertcondition(_hitSL and barstate.isconfirmed, "Trident Stop Hit", "MarkitTick Trident — stop reached on {{ticker}} {{interval}}")
alertcondition(_cancelled and barstate.isconfirmed, "Trident Setup Cancelled", "MarkitTick Trident — setup cancelled on {{ticker}} {{interval}}")

// ── VISUALS ─────────────────────────────────────────────────
var array<TradeArt> arts = array.new<TradeArt>()
var TradeArt cur = na

var label _chartWarnLbl = na
bool _nonStdChart = chart.is_heikinashi or chart.is_renko or chart.is_kagi or chart.is_pnf or chart.is_linebreak or chart.is_range
if barstate.islast
    if _nonStdChart
        if na(_chartWarnLbl)
            _chartWarnLbl := label.new(bar_index, high, "⚠ Non-standard chart type — price levels may not reflect real price", yloc = yloc.abovebar, style = label.style_label_down, color = C_RES, textcolor = C_TXT, size = size.small)
        else
            label.set_xy(_chartWarnLbl, bar_index, high)
    else if not na(_chartWarnLbl)
        label.delete(_chartWarnLbl)
        _chartWarnLbl := na

f_killArt(TradeArt a) =>
    if not na(a)
        line.delete(a.slLine)
        line.delete(a.entryLine)
        line.delete(a.tp1Line)
        line.delete(a.tp2Line)
        line.delete(a.tp3Line)
        line.delete(a.projLine)
        label.delete(a.slLbl)
        label.delete(a.entryLbl)
        label.delete(a.tp1Lbl)
        label.delete(a.tp2Lbl)
        label.delete(a.tp3Lbl)
        label.delete(a.aLbl)
        label.delete(a.bLbl)
        label.delete(a.cLbl)
        label.delete(a.markLbl)

f_killLevels(TradeArt a) =>
    if not na(a)
        line.delete(a.slLine)
        line.delete(a.entryLine)
        line.delete(a.tp1Line)
        line.delete(a.tp2Line)
        line.delete(a.tp3Line)
        label.delete(a.slLbl)
        label.delete(a.entryLbl)
        label.delete(a.tp1Lbl)
        label.delete(a.tp2Lbl)
        label.delete(a.tp3Lbl)
        a.slLine    := na
        a.entryLine := na
        a.tp1Line   := na
        a.tp2Line   := na
        a.tp3Line   := na
        a.slLbl     := na
        a.entryLbl  := na
        a.tp1Lbl    := na
        a.tp2Lbl    := na
        a.tp3Lbl    := na

if newArmed
    TradeArt _a = TradeArt.new()
    bool _bull  = stDir == 1
    int  _x2    = bar_index + 10
    if i_showABC
        _a.aLbl := label.new(stABar, stA, "A", yloc = _bull ? yloc.belowbar : yloc.abovebar, style = _bull ? label.style_label_up : label.style_label_down, color = C_ABC, textcolor = C_TXT, size = size.small)
        _a.bLbl := label.new(stBBar, stB, "B", yloc = _bull ? yloc.abovebar : yloc.belowbar, style = _bull ? label.style_label_down : label.style_label_up, color = C_ABC, textcolor = C_TXT, size = size.small)
        _a.cLbl := label.new(stCBar, stC, "C", yloc = _bull ? yloc.belowbar : yloc.abovebar, style = _bull ? label.style_label_up : label.style_label_down, color = C_ABC, textcolor = C_TXT, size = size.small)
    if i_showProj
        _a.projLine := line.new(stCBar, stC, stCBar + math.max(stBBar - stABar, 1), stTp3, color = C_PROJ, style = line.style_dashed, width = 1)
    if i_showLevels
        _a.slLine    := line.new(stCBar, stStop,  _x2, stStop,  color = C_SL, style = line.style_solid, width = 2)
        _a.entryLine := line.new(stCBar, stEntry, _x2, stEntry, color = C_ENTRY, style = line.style_dashed, width = 1)
        _a.tp1Line   := line.new(stCBar, stTp1,   _x2, stTp1,   color = color.new(C_TP, 40), style = line.style_dashed, width = 1)
        _a.tp2Line   := line.new(stCBar, stTp2,   _x2, stTp2,   color = color.new(C_TP, 20), style = line.style_dashed, width = 1)
        _a.tp3Line   := line.new(stCBar, stTp3,   _x2, stTp3,   color = C_TP, style = line.style_dashed, width = 1)
        _a.slLbl     := label.new(_x2, stStop, "✕ SL " + str.tostring(stStop, format.mintick), style = label.style_label_left, color = C_SL, textcolor = C_TXT, size = size.small)
        _a.entryLbl  := label.new(_x2, stEntry, "▶ Entry " + str.tostring(stEntry, format.mintick), style = label.style_label_left, color = C_ENTRY, textcolor = C_TXT, size = size.small)
        _a.tp1Lbl    := label.new(_x2, stTp1, "◆ TP1 " + str.tostring(stTp1, format.mintick) + " · " + str.tostring(f_rr(stTp1, stEntry, stRisk), "#.00") + "R", style = label.style_label_left, color = C_TP, textcolor = C_TXT, size = size.small)
        _a.tp2Lbl    := label.new(_x2, stTp2, "✦ TP2 " + str.tostring(stTp2, format.mintick) + " · " + str.tostring(f_rr(stTp2, stEntry, stRisk), "#.00") + "R", style = label.style_label_left, color = C_TP, textcolor = C_TXT, size = size.small)
        _a.tp3Lbl    := label.new(_x2, stTp3, "◆ TP3 " + str.tostring(stTp3, format.mintick) + " · " + str.tostring(f_rr(stTp3, stEntry, stRisk), "#.00") + "R", style = label.style_label_left, color = C_TP, textcolor = C_TXT, size = size.small)
    array.push(arts, _a)
    cur := _a
    if array.size(arts) > i_histCount
        f_killArt(array.shift(arts))

if _entryTrig and i_showMarker and not na(cur)
    cur.markLbl := label.new(bar_index, _isL ? low : high, _isL ? "BULL" : "BEAR", yloc = _isL ? yloc.belowbar : yloc.abovebar, style = _isL ? label.style_label_up : label.style_label_down, color = _isL ? C_SUP : C_RES, textcolor = C_TXT, size = size.small)

if _cancelled and not na(cur)
    f_killLevels(cur)

if not na(cur)
    if _drawnSlHit and not na(cur.slLbl)
        label.set_text(cur.slLbl, (stTrendFail ? "SL ✓ TREND FAILURE " : "SL ✓ HIT ") + f_pctTxt(stStop, stEntry, _isL))
        label.set_color(cur.slLbl, C_SL)
    if _hitT1 and not na(cur.tp1Lbl)
        label.set_text(cur.tp1Lbl, "TP1 ✓ HIT " + f_pctTxt(stTp1, stEntry, _isL))
        label.set_color(cur.tp1Lbl, C_TP)
    if _hitT2 and not na(cur.tp2Lbl)
        label.set_text(cur.tp2Lbl, "TP2 ✓ HIT " + f_pctTxt(stTp2, stEntry, _isL))
        label.set_color(cur.tp2Lbl, C_TP)
    if _hitT3 and not na(cur.tp3Lbl)
        label.set_text(cur.tp3Lbl, "TP3 ✓ HIT " + f_pctTxt(stTp3, stEntry, _isL))
        label.set_color(cur.tp3Lbl, C_TP)

bool _extUpdate = _setClosed ? _closeBar == bar_index : barstate.islast
if not na(cur) and not na(cur.slLine) and _extUpdate
    int _extX = _setClosed ? _closeBar + 10 : last_bar_index + 10
    line.set_x2(cur.slLine, _extX)
    line.set_x2(cur.entryLine, _extX)
    line.set_x2(cur.tp1Line, _extX)
    line.set_x2(cur.tp2Line, _extX)
    line.set_x2(cur.tp3Line, _extX)
    label.set_x(cur.slLbl, _extX)
    label.set_x(cur.entryLbl, _extX)
    label.set_x(cur.tp1Lbl, _extX)
    label.set_x(cur.tp2Lbl, _extX)
    label.set_x(cur.tp3Lbl, _extX)

// ── DASHBOARD ───────────────────────────────────────────────
var table dash = table.new(f_dashPos(i_dashPos), 2, 19, border_width = 1, border_color = color.new(#2a3040, 40), frame_width = 1, frame_color = color.new(#3a2a6d, 40))

f_row(int r, string lbl, string val, color vcol) =>
    color _bg = r % 2 == 0 ? C_DASH_BG : color.new(C_DASH_BG, 40)
    table.cell(dash, 0, r, "  " + lbl, text_color = color.new(C_DASH_TXT, 25), text_halign = text.align_left, text_size = size.small, bgcolor = _bg)
    table.cell(dash, 1, r, val + "  ", text_color = vcol, text_halign = text.align_right, text_size = size.small, bgcolor = _bg)

float  _rr1    = f_rr(stTp1, stEntry, stRisk)
float  _rr2    = f_rr(stTp2, stEntry, stRisk)
float  _rr3    = f_rr(stTp3, stEntry, stRisk)
color  _dirCol = stDir == 1 ? C_SUP : stDir == -1 ? C_RES : C_DASH_TXT
color  _stCol  = st == 6 ? C_RES : st >= 3 and st <= 5 ? C_SUP : C_DASH_TXT
string _dirRow = st == 0 ? "—" : stDir == 1 ? "Long" : "Short"
string _stRow  = f_stateTxt(st) + (st >= 5 and stReason != "" ? " · " + stReason : "")
string _entRow = na(stEntry) ? "—" : str.tostring(stEntry, format.mintick)
string _slRow  = na(stStop) ? "—" : str.tostring(stStop, format.mintick)
string _mgRow  = na(stMgStop) ? "—" : str.tostring(stMgStop, format.mintick) + (stMgStop != stStop ? " · BE" : "")
string _t1Row  = na(stTp1) ? "—" : str.tostring(stTp1, format.mintick)
string _t2Row  = na(stTp2) ? "—" : str.tostring(stTp2, format.mintick)
string _t3Row  = na(stTp3) ? "—" : str.tostring(stTp3, format.mintick)
string _abRow  = na(stLeg) ? "—" : i_swingUnit == "Percent" ? (na(stC) or stC == 0 ? "—" : str.tostring(stLeg / stC * 100, "#.00") + "%") : f_num(stLeg)
string _bsRow  = na(stEntryBar) ? "—" : f_num(bar_index - stEntryBar)
string _htfRow = not i_useHtf ? "OFF" : _htfBias == 1 ? "Bull" : _htfBias == -1 ? "Bear" : "Flat"
color  _htfCol = not i_useHtf ? C_DASH_TXT : _htfBias == 1 ? C_SUP : _htfBias == -1 ? C_RES : C_MID
color  _adxCol = not i_useAdx ? C_DASH_TXT : _adxOk ? C_SUP : C_RES
string _smRow  = i_smoothMethod == "None" ? "OFF" : i_smoothMethod

if i_showDash and barstate.islast
    table.cell(dash, 0, 0, "Trident Swing Projector", text_color = C_DASH_TXT, text_halign = text.align_left, text_size = size.small, bgcolor = C_DASH_HDR)
    table.cell(dash, 1, 0, syminfo.ticker + "  ·  " + f_tfTxt(), text_color = C_DASH_TXT, text_halign = text.align_right, text_size = size.small, bgcolor = C_DASH_HDR)
    f_row(1, "Lock", i_lockSignal ? "ACTIVE" : "OFF", i_lockSignal ? C_RES : C_DASH_TXT)
    f_row(2, "Direction", _dirRow, _dirCol)
    f_row(3, "State", _stRow, _stCol)
    f_row(4, "Entry", _entRow, C_ENTRY)
    f_row(5, "Stop", _slRow, C_SL)
    f_row(6, "Managed Stop", _mgRow, C_SL)
    f_row(7, "TP1 · Critical", _t1Row, C_TP)
    f_row(8, "TP2", _t2Row, C_TP)
    f_row(9, "TP3 · Equality", _t3Row, C_TP)
    f_row(10, "R:R TP1", f_bar(_rr1, 5.0), f_barColor(math.min(_rr1 / 5.0, 1.0)))
    f_row(11, "R:R TP2", f_bar(_rr2, 5.0), f_barColor(math.min(_rr2 / 5.0, 1.0)))
    f_row(12, "R:R TP3", f_bar(_rr3, 5.0), f_barColor(math.min(_rr3 / 5.0, 1.0)))
    f_row(13, "Pullback", f_bar(stPb, 100.0), f_barColor(math.min(nz(stPb) / 100.0, 1.0)))
    f_row(14, "AB Swing", _abRow, C_DASH_TXT)
    f_row(15, "Bars Since Entry", _bsRow, C_DASH_TXT)
    f_row(16, "HTF Bias", _htfRow, _htfCol)
    f_row(17, "ADX", i_useAdx ? f_bar(_adx, 100.0) : "OFF", _adxCol)
    f_row(18, "Smoothing", _smRow, C_DASH_TXT)
````
