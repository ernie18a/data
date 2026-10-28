# Impulse Structure Zones [JOAT]

- url: https://www.tradingview.com/script/OesGgbnY-Impulse-Structure-Zones-JOAT/
- type: indicator
- pine_id: PUB;3d3ef4af153445c8bfa77e370179b1da
- version: 1.0

## Description

[b]Impulse Structure Zones [JOAT][/b]

[b]Introduction[/b]

Impulse Structure Zones (ISZ) is an open-source, institutional-grade zone engine that detects statistically significant price impulses using a Z-Score methodology, identifies the origin candle of each impulse as an order block, and grades each zone using a multi-factor wick rejection scoring system. Bullish and bearish zones are tracked in parallel arrays with full lifecycle management — creation, extension, mitigation detection, and rejection confirmation — all rendered as clean, non-repainting boxes on the chart with a mid-line bisecting each zone.

The core problem ISZ solves is the manual process of locating high-probability order block zones on a chart. Institutional price delivery frequently originates from specific candles where large orders were placed — the last opposing candle before a strong directional move. ISZ automates the detection of those moves, marks the origin candles, and then monitors each zone to fire a graded rejection signal when price returns to test the level. Grades A, B, and C communicate signal quality based on wick dominance, proportional wick depth, volume confirmation, and candle size relative to ATR.

[image]https://www.tradingview.com/x/r0nGqCsz/[/image]

[b]Core Concepts[/b]

[b]1. Z-Score Impulse Detection[/b]

Price change is measured bar-by-bar as a percentage move and normalized into a Z-Score against a rolling mean and standard deviation window:

[pine]
float pxChg  = (close - close[1]) / close[1] * 100.0
float zscore = (pxChg - avgChg) / math.max(stdChg, 0.0001)
[/pine]

A bar qualifies as an impulse when the absolute Z-Score exceeds the user-defined threshold (default: 1.5). This isolates moves that are statistically unusual relative to recent activity — the same principle used in quantitative strategies to filter meaningful displacement from noise. All signals are gated on barstate.isconfirmed to prevent repainting.

[b]2. Order Block Identification[/b]

When a bullish impulse is confirmed, ISZ scans back through recent bars to locate the last bearish candle (close < open) before the move. That candle's high and low become the order block zone boundaries. For bearish impulses, the last bullish candle is used. This matches the ICT definition of an order block — the final imbalance candle before institutional displacement.

[b]3. Zone Lifecycle Management[/b]

Each zone is stored as a user-defined type (UDT) containing the box object, mid-line, price boundaries, birth bar, direction, mitigation flag, and rejection flag. Zones extend rightward on each bar until price closes beyond the zone (mitigation), at which point the box is frozen and marked as mitigated. A maximum zone count is enforced and oldest zones are trimmed to maintain chart performance.

[b]4. A/B/C Rejection Grading[/b]

When price returns to test a live zone and a rejection candle forms, ISZ grades the signal quality using four independent scoring factors:

[list]
[*][b]Wick dominance ratio:[/b] The rejection wick length divided by candle body size
[*][b]Proportional wick depth:[/b] The wick as a percentage of the total candle range
[*][b]Volume confirmation:[/b] Current bar volume compared to the 20-bar average
[*][b]Candle size vs ATR:[/b] Whether the rejection candle is of meaningful size relative to recent volatility
[/list]

A total score of 6+ = Grade A, 4-5 = Grade B, below 4 = Grade C. Grade is displayed as a label on the rejection bar.

[b]Features[/b]

[list]
[*][b]Z-Score Impulse Engine:[/b] Statistically filters price moves against a rolling mean/standard deviation window — configurable length and threshold
[*][b]Automatic Order Block Detection:[/b] Last opposing candle before each confirmed impulse identified and stored as a zone
[*][b]Bidirectional Zone Tracking:[/b] Bullish (demand) and bearish (supply) zones managed in separate arrays with independent colors
[*][b]A/B/C Rejection Grading:[/b] Four-factor scoring system labels each zone test with a quality grade
[*][b]Zone Mitigation Detection:[/b] Zones that are fully closed through are frozen and visually distinguished from active zones
[*][b]Mid-Line Reference:[/b] Each zone box includes a dashed mid-line at the 50% level — institutional equilibrium reference
[*][b]ATR Proximity Filter:[/b] Rejection signals only fire when price is within a configurable ATR multiple of the zone
[*][b]Volume Confirmation:[/b] Optional volume filter requires above-average volume at rejection for grading
[*][b]Non-Repainting:[/b] All signals gated on barstate.isconfirmed — no look-ahead bias
[*][b]Zone History Limit:[/b] Oldest zones automatically removed when the maximum count is reached to maintain performance
[*][b]Dashboard (Top Right):[/b] Active bull/bear zone counts, last signal grade, last impulse Z-Score, and ATR — updated on each bar
[*][b]Live Z-Score Candle Gradient Coloring:[/b] Impulse candles colored teal or rose based on Z-Score strength — immediately identifies statistically significant displacement bars on the chart
[*][b]ATR Band Plots Around EMA 750:[/b] Visual upper and lower extremity zones drawn as ATR-based bands around the 750-period EMA — communicates when price is at macro stretch relative to the long-term anchor
[*][b]RR Trade Boxes on Rejection Signals:[/b] Auto-generated SL/TP boxes on every rejection signal — 1.5× ATR stop loss with 3:1 reward-to-risk ratio, extending forward from the signal bar
[*][b]Session Win Rate Tracking:[/b] Asia, London, and NY win rates tracked independently for rejection trades — outcome recorded against each signal's ATR-based TP/SL levels
[*][b]Best Session Highlight:[/b] Dashboard automatically identifies and highlights the highest win-rate session across all three windows
[*][b]Expanded Dashboard (9 Rows):[/b] Dashboard expanded to 9 rows — now includes live Z-Score reading, total impulse count, and full session win rate breakdown alongside existing zone and signal data
[/list]

[b]Input Parameters[/b]

[b]Z-Score Settings:[/b]
[list]
[*]Z-Score Length: Rolling window for mean and standard deviation calculation (default: 20)
[*]Z-Score Threshold: Minimum absolute Z-Score required to qualify as an impulse (default: 1.5)
[/list]

[b]Zone Settings:[/b]
[list]
[*]Max Active Zones: Maximum number of zones tracked simultaneously per direction (default: 8)
[*]Bull Zone Color / Bear Zone Color: Independent colors per direction
[/list]

[b]Rejection Settings:[/b]
[list]
[*]ATR Proximity (multiplier): How close price must be to a zone to trigger rejection check (default: 0.5)
[*]ATR Length: Period for ATR calculation (default: 14)
[*]Require Volume Confirmation: Toggle — above-average volume required for Grade A
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Identify Active Zones[/b]
Active bullish zones (demand) appear below price in teal. Active bearish zones (supply) appear above price in rose. Mitigated zones are visually dimmed. Focus on zones that have not yet been tested — these are the most relevant levels for future price interaction.

[b]Step 2: Wait for Price to Return to the Zone[/b]
ISZ does not generate entry signals on impulse creation. It monitors active zones for return tests. When price pulls back into a zone, watch for the rejection grading label to appear.

[b]Step 3: Grade the Signal[/b]
An A-grade rejection at a fresh, unmitigated zone is the highest-quality setup. B-grade is acceptable with additional confluence. C-grade rejections at already-tested zones carry the least weight. Use the grade in combination with your own bias and higher-timeframe analysis.

[b]Step 4: Monitor the Dashboard[/b]
The dashboard shows active zone counts, last Z-Score, last grade, and ATR. A high Z-Score at impulse creation indicates an unusually strong move — those zones tend to attract more significant future tests.

[b]Indicator Limitations[/b]

[list]
[*]Z-Score impulse detection requires sufficient historical bars (at least 2× the Z-Score length) to produce accurate statistics — on very short chart histories the first few zones may form under unstable conditions
[*]Order block detection scans back a fixed number of bars (configurable). In fast-moving markets where multiple candles are the same color, the scan may place the zone further back than an analyst would manually
[*]Rejection grading uses volume data. On instruments with synthetic or unreliable volume (e.g., some CFDs, synthetic indices), the volume scoring component will not reflect true market activity
[*]Zones do not account for gap fills, overnight moves, or after-hours sessions — a zone that appears unmitigated on the chart may have been effectively traded through outside of regular hours depending on the instrument
[*]The A/B/C grading is a quantitative scoring system, not a certainty measure. Grade A signals do not guarantee price continuation in the expected direction
[/list]

[b]Originality Statement[/b]

ISZ combines Z-Score statistical impulse detection with origin-candle order block identification and a multi-factor rejection grading system in a single, self-contained indicator. This combination is original for the following reasons:

[list]
[*]The use of a Z-Score normalized against a rolling mean and standard deviation — rather than a fixed pip or percentage threshold — makes impulse detection adaptive to current market volatility. The same threshold parameter behaves consistently across instruments and timeframes without requiring manual recalibration
[*]The A/B/C grading system applies four independent quantitative factors (wick dominance, wick proportion, volume, candle size) simultaneously to classify signal quality at the point of zone interaction — rather than simply marking every return to a zone as equal
[*]Zone lifecycle management (create → extend → mitigate → reject → trim) is handled automatically through UDT arrays with in-place field mutation, eliminating the need for manual zone maintenance or re-drawing
[*]The combination of impulse detection, zone creation, and rejection grading in a single engine — with a unified dashboard — removes the need to layer multiple indicators to accomplish the same workflow
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss. Order block zones are historical reference levels and do not guarantee that price will react at those levels. A/B/C grades reflect quantitative scoring and do not predict future price movement. Always apply proper risk management. The author is not responsible for any trading losses resulting from the use of this indicator.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Impulse Structure Zones [JOAT]", shorttitle="ISZ [JOAT]",
     overlay=true, max_boxes_count=200, max_lines_count=200, max_labels_count=100)

// ── GROUP LABELS ───────────────────────────────────────────────────────────────
var string GRP_IMP  = "Impulse Detection"
var string GRP_ZONE = "Zone Settings"
var string GRP_GRAD = "Rejection Grading"
var string GRP_FILT = "Filters"
var string GRP_SESS = "Sessions"
var string GRP_VIS  = "Visual"
var string GRP_DASH = "Dashboard"
var string GRP_ALT  = "Alerts"

// ── IMPULSE INPUTS ─────────────────────────────────────────────────────────────
i_zsLen     = input.int(20,    "Z-Score Period",       minval=5,              group=GRP_IMP,
     tooltip="Lookback length for the rolling mean and standard deviation of bar-to-bar price change.")
i_zsThresh  = input.float(1.5, "Z-Score Threshold",   minval=0.5,  step=0.1, group=GRP_IMP,
     tooltip="How many standard deviations a move must exceed to qualify as an impulse.")
i_impLB     = input.int(5,     "Origin Candle Scan",  minval=2,    maxval=10, group=GRP_IMP,
     tooltip="Candles to look back for the last opposing candle (impulse origin).")

// ── ZONE INPUTS ────────────────────────────────────────────────────────────────
i_maxZones  = input.int(20,    "Max Active Zones",    minval=5,    maxval=40,  group=GRP_ZONE)
i_maxAge    = input.int(150,   "Max Zone Age (bars)", minval=20,               group=GRP_ZONE)
i_showMit   = input.bool(true, "Show Mitigated Zones",                         group=GRP_ZONE)
i_mitType   = input.string("Close", "Mitigation Type", options=["Close","Wick"], group=GRP_ZONE)
i_fullCndl  = input.bool(false,"Zone: Include Wicks",                          group=GRP_ZONE,
     tooltip="When on, the zone box spans the full wick range. When off, body only.")

// ── REJECTION GRADING INPUTS ───────────────────────────────────────────────────
i_rejPct    = input.float(50.0,"Rejection Move %",    minval=5,    step=5,    group=GRP_GRAD,
     tooltip="The close must move at least this % of the zone height to count as a rejection.")
i_showGrade = input.bool(true, "Show Grade Labels",                            group=GRP_GRAD)
i_minWickR  = input.float(1.5, "Min Wick:Body Ratio", minval=1.0,  step=0.1,  group=GRP_GRAD)

// ── FILTER INPUTS ──────────────────────────────────────────────────────────────
i_useEMA    = input.bool(true, "EMA 750 Filter",                               group=GRP_FILT)
i_useVWAP   = input.bool(true, "VWAP Filter",                                  group=GRP_FILT)
i_useATR    = input.bool(false,"ATR Band Filter",                               group=GRP_FILT)
i_atrMult   = input.float(10.0,"ATR Band Multiplier", minval=1,    step=0.5,   group=GRP_FILT)

// ── SESSION INPUTS ─────────────────────────────────────────────────────────────
i_utcOff    = input.int(0,     "UTC Offset",          minval=-12,  maxval=14,  group=GRP_SESS)
i_useSess   = input.bool(true, "Enable Session Filter",                         group=GRP_SESS)
i_useAsia   = input.bool(true, "Asia",                                          group=GRP_SESS)
i_asiaRng   = input.session("0000-0800", "Asia Range",                          group=GRP_SESS)
i_useLon    = input.bool(true, "London",                                        group=GRP_SESS)
i_lonRng    = input.session("0700-1600", "London Range",                        group=GRP_SESS)
i_useNY     = input.bool(true, "New York",                                      group=GRP_SESS)
i_nyRng     = input.session("1300-2200", "New York Range",                      group=GRP_SESS)
i_useExcl   = input.bool(false,"Custom Exclusion",                              group=GRP_SESS)
i_exclRng   = input.session("2200-0700", "Exclusion Range",                     group=GRP_SESS)

// ── VISUAL INPUTS ──────────────────────────────────────────────────────────────
i_bullZone  = input.color(color.new(#00bcd4, 88), "Bullish Zone",               group=GRP_VIS)
i_bearZone  = input.color(color.new(#dd326b, 88), "Bearish Zone",               group=GRP_VIS)
i_bullBord  = input.color(color.new(#00bcd4, 50), "Bullish Border",             group=GRP_VIS)
i_bearBord  = input.color(color.new(#dd326b, 50), "Bearish Border",             group=GRP_VIS)
i_showEMAl  = input.bool(true, "Show EMA 750",                                  group=GRP_VIS)
i_showVWAPl = input.bool(true, "Show VWAP",                                     group=GRP_VIS)
i_ema750Col = input.color(color.new(#f8f8f8, 50), "EMA 750 Color",              group=GRP_VIS)
i_vwapCol   = input.color(color.new(#c2185c, 35), "VWAP Color",                 group=GRP_VIS)

// ── DASHBOARD INPUT ────────────────────────────────────────────────────────────
i_showDash  = input.bool(true, "Show Dashboard", group=GRP_DASH)

// ── ALERT INPUTS ───────────────────────────────────────────────────────────────
i_bullAlt   = input.bool(true, "Bullish Rejection Alert", group=GRP_ALT)
i_bearAlt   = input.bool(true, "Bearish Rejection Alert", group=GRP_ALT)

// ── CORE CALCULATIONS ──────────────────────────────────────────────────────────
float ema750    = ta.ema(close, 750)
float vwapVal   = ta.vwap(hl2)
float atrVal    = ta.atr(14)
float smoothATR = ta.ema(ta.tr, 750)
float upperBand = ema750 + i_atrMult * smoothATR
float lowerBand = ema750 - i_atrMult * smoothATR
float vol20     = ta.sma(volume, 20)

// Z-Score impulse engine
float pxChg  = close - close[1]
float avgChg = ta.sma(pxChg, i_zsLen)
float stdChg = ta.stdev(pxChg, i_zsLen)
float zscore = stdChg > 0.0 ? (pxChg - avgChg) / stdChg : 0.0

// ── PLOTS ──────────────────────────────────────────────────────────────────────
plot(i_showEMAl  ? ema750   : na, "EMA 750", color=i_ema750Col, linewidth=1)
plot(i_showVWAPl ? vwapVal  : na, "VWAP",   color=i_vwapCol,   linewidth=1)
plot(i_useATR and i_showEMAl ? upperBand : na, "ATR Upper Band", color=color.new(#00bcd4, 70), linewidth=1, style=plot.style_linebr)
plot(i_useATR and i_showEMAl ? lowerBand : na, "ATR Lower Band", color=color.new(#dd326b, 70), linewidth=1, style=plot.style_linebr)

// ── DYNAMIC CANDLE COLORING ─────────────────────────────────────────────────
float zAbs   = math.abs(zscore)
float zMax   = ta.highest(zAbs, 50)
float zStr   = zMax > 0 ? math.min(zAbs / zMax, 1.0) : 0.0
color zBull  = color.from_gradient(zStr, 0, 1, color.new(#00bcd4, 60), color.new(#00bcd4, 0))
color zBear  = color.from_gradient(zStr, 0, 1, color.new(#dd326b, 60), color.new(#dd326b, 0))
barcolor(zscore > i_zsThresh ? zBull : zscore < -i_zsThresh ? zBear : na, title="Z-Score Impulse")

// ── TIMEZONE / SESSION ─────────────────────────────────────────────────────────
f_tz() =>
    "UTC" + (i_utcOff >= 0 ? "+" + str.tostring(i_utcOff) : str.tostring(i_utcOff))

bool inAsia   = i_useAsia and not na(time(timeframe.period, i_asiaRng, f_tz()))
bool inLondon = i_useLon  and not na(time(timeframe.period, i_lonRng,  f_tz()))
bool inNY     = i_useNY   and not na(time(timeframe.period, i_nyRng,   f_tz()))
bool inExcl   = i_useExcl and not na(time(timeframe.period, i_exclRng, f_tz()))
bool sessOK   = not inExcl and (not i_useSess or (inAsia or inLondon or inNY))

f_sessTag() =>
    inNY and inLondon ? "LN+NY" : inLondon ? "London" : inNY ? "NY" : inAsia ? "Asia" : "Off"
string curSess = f_sessTag()

// ── DIRECTIONAL FILTERS ────────────────────────────────────────────────────────
bool fBull = (not i_useEMA  or close > ema750)    and
             (not i_useVWAP or close > vwapVal)   and
             (not i_useATR  or close <= upperBand)

bool fBear = (not i_useEMA  or close < ema750)    and
             (not i_useVWAP or close < vwapVal)   and
             (not i_useATR  or close >= lowerBand)

// ── IMPULSE CONDITIONS — only fire on confirmed (closed) bars ──────────────────
bool bullImp = barstate.isconfirmed and
               zscore > i_zsThresh  and close > open  and fBull and sessOK and
               close > ta.highest(close, i_impLB)[1]

bool bearImp = barstate.isconfirmed and
               zscore < -i_zsThresh and close < open  and fBear and sessOK and
               close < ta.lowest(close, i_impLB)[1]

// ── UDT: IMPULSE ZONE ─────────────────────────────────────────────────────────
type ImpulseZone
    box    zBox
    line   midLine
    float  zTop
    float  zBot
    int    birthBar
    bool   isBull
    bool   mitigated
    bool   rejFired

var array<ImpulseZone> zones = array.new<ImpulseZone>()

// ── REJECTION GRADING FUNCTION ────────────────────────────────────────────────
// Scores the quality of a rejection candle on four criteria.
// Returns "A" (score ≥ 6), "B" (score ≥ 4), or "C" (below 4).
f_grade(float wick, float body, float rng, float vol, float avgVol, float atr) =>
    int sc = 0
    // Criterion 1: wick-to-body dominance
    float wRat = wick / math.max(body, rng * 0.001)
    sc += wRat >= 4.0 ? 3 : wRat >= 3.0 ? 2 : 1
    // Criterion 2: wick as proportion of total range
    float wPct = wick / math.max(rng, atr * 0.01)
    sc += wPct >= 0.75 ? 2 : wPct >= 0.65 ? 1 : 0
    // Criterion 3: volume vs 20-bar average
    sc += vol >= avgVol * 2.0 ? 2 : vol >= avgVol * 1.5 ? 1 : 0
    // Criterion 4: candle size vs ATR
    sc += rng >= atr ? 1 : 0
    sc >= 6 ? "A" : sc >= 4 ? "B" : "C"

// ── STAT COUNTERS ──────────────────────────────────────────────────────────────
var int cntBull   = 0
var int cntBear   = 0
var int cntMit    = 0
var int cntA      = 0
var int cntB      = 0
var int cntC      = 0
var int cntRej    = 0

// ── RR TRADE VISUALIZATION ────────────────────────────────────────────────────
type ISZTrade
    box    slBox
    box    tpBox
    float  slLvl
    float  tpLvl
    float  entry
    bool   isBull
    int    entBar

var array<ISZTrade> iszTrades = array.new<ISZTrade>()

// ── SESSION WIN TRACKING ──────────────────────────────────────────────────────
var int iszTotT  = 0
var int iszTotW  = 0
var int iszAsiaT = 0
var int iszAsiaW = 0
var int iszLonT  = 0
var int iszLonW  = 0
var int iszNYT   = 0
var int iszNYW   = 0

// ── RR INPUTS (add at top of inputs if needed — use defaults here) ────────────
float iszRR     = 3.0
float iszSLMult = 1.5

// ── CREATE ZONE ON BULLISH IMPULSE ────────────────────────────────────────────
if bullImp
    // Find the last bearish candle in the lookback — that is the origin
    int obBar = 1
    for k = 1 to i_impLB
        if close[k] < open[k]
            obBar := k
            break
    float obH = i_fullCndl ? high[obBar]  : math.max(open[obBar], close[obBar])
    float obL = i_fullCndl ? low[obBar]   : math.min(open[obBar], close[obBar])
    float mid = (obH + obL) * 0.5
    int   bL  = bar_index - obBar
    box bx = box.new(bL, obH, bar_index + 1, obL,
         border_color=i_bullBord, bgcolor=i_bullZone, border_width=1)
    line ml = line.new(bL, mid, bar_index + 1, mid,
         color=color.new(#00bcd4, 50), style=line.style_dashed, width=1)
    // Zone label inside the box
    label.new(bL + 1, mid, "BULL OB",
         style=label.style_label_right,
         color=color.new(#00bcd4, 85),
         textcolor=color.new(#00bcd4, 0),
         size=size.small)
    array.push(zones, ImpulseZone.new(bx, ml, obH, obL, bar_index, true, false, false))
    cntBull += 1

// ── CREATE ZONE ON BEARISH IMPULSE ────────────────────────────────────────────
if bearImp
    // Find the last bullish candle in the lookback — that is the origin
    int obBar = 1
    for k = 1 to i_impLB
        if close[k] > open[k]
            obBar := k
            break
    float obH = i_fullCndl ? high[obBar]  : math.max(open[obBar], close[obBar])
    float obL = i_fullCndl ? low[obBar]   : math.min(open[obBar], close[obBar])
    float mid = (obH + obL) * 0.5
    int   bL  = bar_index - obBar
    box bx = box.new(bL, obH, bar_index + 1, obL,
         border_color=i_bearBord, bgcolor=i_bearZone, border_width=1)
    line ml = line.new(bL, mid, bar_index + 1, mid,
         color=color.new(#dd326b, 50), style=line.style_dashed, width=1)
    // Zone label inside the box
    label.new(bL + 1, mid, "BEAR OB",
         style=label.style_label_right,
         color=color.new(#dd326b, 85),
         textcolor=color.new(#dd326b, 0),
         size=size.small)
    array.push(zones, ImpulseZone.new(bx, ml, obH, obL, bar_index, false, false, false))
    cntBear += 1

// ── UPDATE ZONES: EXTEND / MITIGATE / GRADE REJECTIONS ────────────────────────
bool bullRej = false
bool bearRej = false
var string lastGrade = "C"

if array.size(zones) > 0
    for i = array.size(zones) - 1 to 0
        ImpulseZone z = array.get(zones, i)

        if not z.mitigated
            // Extend zone right edge every bar
            box.set_right(z.zBox, bar_index + 1)
            line.set_x2(z.midLine, bar_index + 1)

            // ── Mitigation check ──────────────────────────────────────────────
            bool isMit = false
            if i_mitType == "Close"
                isMit := z.isBull ? close < z.zBot : close > z.zTop
            else
                isMit := z.isBull ? low < z.zBot : high > z.zTop
            bool expired = (bar_index - z.birthBar) > i_maxAge

            if isMit or expired
                z.mitigated := true
                cntMit += 1
                color fc = z.isBull ? i_bullZone : i_bearZone
                box.set_bgcolor(z.zBox, color.new(fc, 96))
                box.set_border_color(z.zBox, color.new(fc, 85))
                box.set_border_style(z.zBox, line.style_dotted)
                if not i_showMit
                    box.delete(z.zBox)
                    line.delete(z.midLine)

            // ── Rejection detection — confirmed bars, unfired zones only ──────
            if not z.mitigated and not z.rejFired and barstate.isconfirmed
                float zH   = z.zTop - z.zBot
                float rDst = zH * (i_rejPct * 0.01)
                float bdy  = math.abs(close - open)
                float rng  = high - low

                if z.isBull
                    float loWick = math.min(open, close) - low
                    bool  touch  = low <= z.zTop and low >= z.zBot
                    bool  move   = close > open and (close - low) > rDst
                    bool  wkOK   = loWick / math.max(bdy, rng * 0.001) >= i_minWickR
                    if touch and move and wkOK and fBull and sessOK
                        string grd = f_grade(loWick, bdy, rng, volume, vol20, atrVal)
                        z.rejFired := true
                        bullRej    := true
                        lastGrade  := grd
                        cntRej     += 1
                        cntA += grd == "A" ? 1 : 0
                        cntB += grd == "B" ? 1 : 0
                        cntC += grd == "C" ? 1 : 0
                        if i_showGrade
                            label.new(bar_index, z.zBot, grd,
                                 style=label.style_label_up,
                                 color=color.new(#00bcd4, 55),
                                 textcolor=color.new(#00bcd4, 0),
                                 size=size.small)
                else
                    float hiWick = high - math.max(open, close)
                    bool  touch  = high >= z.zBot and high <= z.zTop
                    bool  move   = close < open and (high - close) > rDst
                    bool  wkOK   = hiWick / math.max(bdy, rng * 0.001) >= i_minWickR
                    if touch and move and wkOK and fBear and sessOK
                        string grd = f_grade(hiWick, bdy, rng, volume, vol20, atrVal)
                        z.rejFired := true
                        bearRej    := true
                        lastGrade  := grd
                        cntRej     += 1
                        cntA += grd == "A" ? 1 : 0
                        cntB += grd == "B" ? 1 : 0
                        cntC += grd == "C" ? 1 : 0
                        if i_showGrade
                            label.new(bar_index, z.zTop, grd,
                                 style=label.style_label_down,
                                 color=color.new(#dd326b, 55),
                                 textcolor=color.new(#dd326b, 0),
                                 size=size.small)

// ── TRIM OLDEST ZONES BEYOND CAP ──────────────────────────────────────────────
while array.size(zones) > i_maxZones
    ImpulseZone z0 = array.shift(zones)
    box.delete(z0.zBox)
    line.delete(z0.midLine)

// ── ACTIVE ZONE COUNT ─────────────────────────────────────────────────────────
int activeZones = 0
if array.size(zones) > 0
    for j = 0 to array.size(zones) - 1
        ImpulseZone zj = array.get(zones, j)
        if not zj.mitigated
            activeZones += 1

// ── DASHBOARD ─────────────────────────────────────────────────────────────────
var table dash = table.new(position.top_right, 4, 9,
     bgcolor=color.new(#0d0d14, 80), border_width=0, frame_width=0)

if barstate.islast and i_showDash
    color cHead = color.new(#00bcd4, 0)
    color cBear = color.new(#dd326b, 0)
    color cBody = color.new(#d0d0d0, 0)
    color cDim  = color.new(#707070, 0)
    color cBgH  = color.new(#0d0d14, 72)
    color cBgR  = color.new(#111118, 60)

    int   totZ   = cntBull + cntBear
    float mitPct = totZ > 0 ? cntMit * 100.0 / totZ : 0.0
    float aPct   = cntRej > 0 ? cntA   * 100.0 / cntRej : 0.0

    // ── Row 0 — Header ────────────────────────────────────────────────────────
    table.cell(dash, 0, 0, "Impulse Structure Zones [JOAT]",
         text_color=cHead, text_size=size.normal, text_halign=text.align_left, bgcolor=cBgH)
    table.cell(dash, 1, 0, "",
         text_size=size.normal, bgcolor=cBgH)
    table.cell(dash, 2, 0, str.tostring(activeZones) + " active",
         text_color=activeZones > 0 ? cHead : cDim,
         text_size=size.normal, text_halign=text.align_center, bgcolor=cBgH)
    table.cell(dash, 3, 0, curSess,
         text_color=cDim, text_size=size.normal, text_halign=text.align_right, bgcolor=cBgH)

    // ── Row 1 — Zone counts ───────────────────────────────────────────────────
    table.cell(dash, 0, 1, "Bull Zones", text_color=cHead, text_size=size.normal, text_halign=text.align_left, bgcolor=cBgR)
    table.cell(dash, 1, 1, str.tostring(cntBull), text_color=cBody, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgR)
    table.cell(dash, 2, 1, "Bear Zones", text_color=cBear, text_size=size.normal, text_halign=text.align_left, bgcolor=cBgR)
    table.cell(dash, 3, 1, str.tostring(cntBear), text_color=cBody, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgR)

    // ── Row 2 — Rejections / Mitigation ──────────────────────────────────────
    table.cell(dash, 0, 2, "Rejections", text_color=cDim, text_size=size.normal, text_halign=text.align_left, bgcolor=cBgH)
    table.cell(dash, 1, 2, str.tostring(cntRej), text_color=cBody, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgH)
    table.cell(dash, 2, 2, "Mitigated",  text_color=cDim, text_size=size.normal, text_halign=text.align_left, bgcolor=cBgH)
    table.cell(dash, 3, 2, str.tostring(mitPct, "#.0") + "%",
         text_color=mitPct > 60.0 ? cBear : cHead,
         text_size=size.normal, text_halign=text.align_center, bgcolor=cBgH)

    // ── Row 3 — Grades ────────────────────────────────────────────────────────
    table.cell(dash, 0, 3, "Grade  A", text_color=cHead, text_size=size.normal, text_halign=text.align_left, bgcolor=cBgR)
    table.cell(dash, 1, 3, str.tostring(cntA), text_color=cBody, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgR)
    table.cell(dash, 2, 3, "Grade  B", text_color=cDim, text_size=size.normal, text_halign=text.align_left, bgcolor=cBgR)
    table.cell(dash, 3, 3, str.tostring(cntB), text_color=cBody, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgR)

    // ── Row 4 — Grade C + A-grade % ──────────────────────────────────────────
    table.cell(dash, 0, 4, "Grade  C", text_color=cDim, text_size=size.normal, text_halign=text.align_left, bgcolor=cBgH)
    table.cell(dash, 1, 4, str.tostring(cntC), text_color=cBody, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgH)
    table.cell(dash, 2, 4, "A-Grade %", text_color=cDim, text_size=size.normal, text_halign=text.align_left, bgcolor=cBgH)
    table.cell(dash, 3, 4, str.tostring(aPct, "#.0") + "%",
         text_color=aPct > 30.0 ? cHead : cDim,
         text_size=size.normal, text_halign=text.align_center, bgcolor=cBgH)

    // ── Row 5 — Live Z-Score ──────────────────────────────────────────────────
    float curZ = math.round(zscore * 100.0) / 100.0
    color zCol = zscore > i_zsThresh ? cHead : zscore < -i_zsThresh ? cBear : cDim
    table.cell(dash, 0, 5, "Z-Score",  text_color=cDim,  text_size=size.normal, text_halign=text.align_left,   bgcolor=cBgR)
    table.cell(dash, 1, 5, str.tostring(curZ, "#.00"), text_color=zCol, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgR)
    table.cell(dash, 2, 5, "Impulses", text_color=cDim,  text_size=size.normal, text_halign=text.align_left,   bgcolor=cBgR)
    table.cell(dash, 3, 5, str.tostring(cntBull + cntBear), text_color=cHead, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgR)

    // ── Row 6 — Settings summary ──────────────────────────────────────────────
    table.cell(dash, 0, 6, "ZS " + str.tostring(i_zsThresh, "#.0"),
         text_color=cDim, text_size=size.normal, text_halign=text.align_left, bgcolor=cBgH)
    table.cell(dash, 1, 6, i_useEMA  ? "EMA ON"  : "EMA OFF",
         text_color=i_useEMA  ? cHead : cDim, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgH)
    table.cell(dash, 2, 6, i_useVWAP ? "VWAP ON" : "VWAP OFF",
         text_color=i_useVWAP ? cHead : cDim, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgH)
    table.cell(dash, 3, 6, i_useSess ? "SESS ON" : "SESS OFF",
         text_color=i_useSess ? cHead : cDim, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgH)

    // ── Row 7 — RR trade win rate ─────────────────────────────────────────────
    float iszWR = iszTotT > 0 ? iszTotW * 100.0 / iszTotT : 0.0
    table.cell(dash, 0, 7, "RR Trades", text_color=cDim,  text_size=size.normal, text_halign=text.align_left,   bgcolor=cBgR)
    table.cell(dash, 1, 7, str.tostring(iszTotT),         text_color=cBody, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgR)
    table.cell(dash, 2, 7, "Win Rate",  text_color=cDim,  text_size=size.normal, text_halign=text.align_left,   bgcolor=cBgR)
    table.cell(dash, 3, 7, str.tostring(iszWR, "#.0") + "%", text_color=iszWR >= 50 ? cHead : cBear, text_size=size.normal, text_halign=text.align_center, bgcolor=cBgR)

    // ── Row 8 — Session breakdown ─────────────────────────────────────────────
    float asWR2 = iszAsiaT > 0 ? iszAsiaW * 100.0 / iszAsiaT : 0.0
    float lnWR2 = iszLonT  > 0 ? iszLonW  * 100.0 / iszLonT  : 0.0
    float nyWR2 = iszNYT   > 0 ? iszNYW   * 100.0 / iszNYT   : 0.0
    string bestSess = iszAsiaT == 0 and iszLonT == 0 and iszNYT == 0 ? "---" : asWR2 >= lnWR2 and asWR2 >= nyWR2 ? "Asia " + str.tostring(asWR2,"#.0") + "%" : lnWR2 >= nyWR2 ? "Lon " + str.tostring(lnWR2,"#.0") + "%" : "NY " + str.tostring(nyWR2,"#.0") + "%"
    table.cell(dash, 0, 8, "Best Sess", text_color=cDim,  text_size=size.normal, text_halign=text.align_left,   bgcolor=cBgH)
    table.cell(dash, 1, 8, bestSess,    text_color=color.new(#f59e0b, 0), text_size=size.normal, text_halign=text.align_left, bgcolor=cBgH)
    table.cell(dash, 2, 8, "",          text_size=size.normal, bgcolor=cBgH)
    table.cell(dash, 3, 8, "",          text_size=size.normal, bgcolor=cBgH)

// ── OPEN RR TRADE ON REJECTION ────────────────────────────────────────────────
if bullRej or bearRej
    bool   newBull  = bullRej
    float  entPx    = close
    float  slDist   = atrVal * iszSLMult
    float  slLvl2   = newBull ? entPx - slDist : entPx + slDist
    float  tpLvl2   = newBull ? entPx + slDist * iszRR : entPx - slDist * iszRR
    color  slFill   = color.new(#dd326b, 85)
    color  tpFill   = color.new(#00bcd4, 85)
    box    slBx     = box.new(bar_index, entPx, bar_index + 1, slLvl2,
         bgcolor=slFill, border_color=color.new(#dd326b, 50), border_width=1)
    box    tpBx     = box.new(bar_index, entPx, bar_index + 1, tpLvl2,
         bgcolor=tpFill, border_color=color.new(#00bcd4, 50), border_width=1)
    array.push(iszTrades, ISZTrade.new(slBx, tpBx, slLvl2, tpLvl2, entPx, newBull, bar_index))
    iszTotT += 1
    if curSess == "Asia"
        iszAsiaT += 1
    else if curSess == "London"
        iszLonT += 1
    else if curSess == "NY"
        iszNYT += 1
    if array.size(iszTrades) > 50
        ISZTrade old = array.shift(iszTrades)
        box.delete(old.slBox)
        box.delete(old.tpBox)

// ── UPDATE RR TRADES ──────────────────────────────────────────────────────────
if array.size(iszTrades) > 0
    for ti = array.size(iszTrades) - 1 to 0
        ISZTrade tr = array.get(iszTrades, ti)
        if bar_index > tr.entBar
            box.set_right(tr.slBox, bar_index + 1)
            box.set_right(tr.tpBox, bar_index + 1)
            bool slHit2 = tr.isBull ? low  <= tr.slLvl : high >= tr.slLvl
            bool tpHit2 = tr.isBull ? high >= tr.tpLvl : low  <= tr.tpLvl
            if slHit2 or tpHit2
                bool won2 = tpHit2
                if won2
                    iszTotW += 1
                    if curSess == "Asia"
                        iszAsiaW += 1
                    else if curSess == "London"
                        iszLonW += 1
                    else if curSess == "NY"
                        iszNYW += 1
                box.set_right(tr.slBox, bar_index)
                box.set_right(tr.tpBox, bar_index)
                color doneCol = won2 ? color.new(#00bcd4, 88) : color.new(#dd326b, 88)
                box.set_bgcolor(tr.slBox, doneCol)
                box.set_bgcolor(tr.tpBox, doneCol)
                array.remove(iszTrades, ti)

// ── ALERTS ─────────────────────────────────────────────────────────────────────
alertcondition(i_bullAlt and bullRej,
     "ISZ Bull Rejection", "Impulse Structure Zones [JOAT]: Bullish rejection at zone")
alertcondition(i_bearAlt and bearRej,
     "ISZ Bear Rejection", "Impulse Structure Zones [JOAT]: Bearish rejection at zone")
````
