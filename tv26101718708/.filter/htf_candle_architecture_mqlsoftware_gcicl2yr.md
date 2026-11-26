# HTF Candle Architecture [MQLSoftware]

- url: https://www.tradingview.com/script/GCIcl2yr-HTF-Candle-Architecture-MQLSoftware/
- type: indicator
- pine_id: PUB;881d0ef6805d4b37b1b80ae08a3f134f
- version: 1.0

## Description

HTF Candle Architecture overlays up to three higher-timeframe candles simultaneously on any chart, rendering each at full structural fidelity — body, wicks, and open mid-line — and extending the live candle in real time as bars print. A right-side panel shows the bias, range position, and cross-timeframe alignment for all active levels. Level-touch signals mark when price closes near a key HTF boundary.

This is a visual analytical tool intended for chart reading and structural context. It does not execute trades and does not provide financial advice.

[b]Key Features[/b]
[list]
[*]Three simultaneous HTF levels, auto-selected from the standard timeframe ladder above the chart, with an override for manual pinning
[*]Three display modes per level: Candles (body box + wicks), Bars (H-L spine with open/close ticks), and HL (high and low range lines only)
[*]Live candle extends in real time — the body, wicks, and projection lines follow price as the current HTF period develops
[*]OHLC Projection lines project the current HTF candle's High, Low, Open, and Close as dotted levels to the right, labeled with the timeframe and price
[*]Range Position gauge — a filled-block bar (`████░░░ 71%`) showing where price sits inside each HTF candle's range; extremes (above 80% or below 20%) highlight in amber
[*]Alignment row — cross-timeframe bias summary: ↑↑ ALIGNED when all enabled levels agree bullish, ↓↓ ALIGNED when all agree bearish, ⇅ MIXED when they conflict
[*]Level-touch signals — fires when price first closes within a configurable ATR threshold of a HTF High, Low, or Open; one signal per HTF candle, per level
[*]HTF Bias Background — subtle background tint matching the primary level's direction (blue for bull, red for bear)
[*]Four alert conditions, all confirmed-bar only
[/list]

[b]Core Concept[/b]
Most HTF candle overlay scripts show a single timeframe. The useful information in a multi-timeframe view is not just that a candle exists at a higher timeframe — it is the structural relationship between that candle and the current position of price, repeated across multiple timeframes at once.

This indicator builds that view directly. Three independent HTF levels render simultaneously with separate depth cues: the closest timeframe uses a lighter body and thinner border; deeper timeframes use heavier borders and darker fills, so the layered structure reads without confusion at a glance.

The range position gauge is the specific addition that single-timeframe tools miss. Whether price is at 91% or 47% of the current Weekly candle's range changes the structural read. The gauge answers that for all three active levels without requiring the user to manually measure.

The alignment row adds the cross-timeframe read in a single line. When all enabled timeframes agree on direction, a single colored label replaces the need to read each row and compare manually. When they conflict, ⇅ MIXED in amber flags it explicitly so a false conviction read is not made.

The level-touch signal system layers actionable entries on top of the structural view. It applies a zone-entry filter — the signal fires only when price moves into the zone on this bar, not while it is already inside — and a per-period gate that allows at most one signal per active HTF candle per level. Combined, these two filters remove the signal spam that plagues basic proximity alerts.

[b]Anatomy of the Display[/b]
[b]HTF candle bodies[/b] are box objects spanning the HTF period's bar range. The live body updates right-edge and color on every bar. Closed candles are committed once the HTF period ends and stay anchored.

[b]Wicks[/b] are line objects centered within the body's bar range, connecting the body edge to the High or Low. In Bars mode, the same lines form the H-L spine, open tick, and close tick of a standard bar representation.

[b]The open mid-line[/b] is a dashed horizontal line at the Open price inside the body, visible when the body height exceeds 5% of ATR14, so it is suppressed on doji-like candles where it would overlap the border.

[b]OHLC Projection lines[/b] are dotted horizontals extending from the HTF period start to `bar_index + N bars` (configurable). Each carries a tiny label on the right showing the timeframe abbreviation, level name, and price. They update every bar, so they track the live candle's developing values until the period closes.

[b]The panel[/b] occupies the top-right corner. Rows 1-3 show the active timeframe, its bias (↑ BULL / ↓ BEAR), and the range position gauge. Row 4 shows the alignment verdict with a colored background. Rows 5-6 show the last signal fired. The header row shows the ticker.

[b]Level-touch signal arrows[/b] appear below or above the bar that closes near a HTF level: ▲ for a Low touch (potential support), ▼ for a High touch (potential resistance). Signal size scales with HTF depth: L1 uses the smallest arrow, L3 the largest.

[b]Notes on Repainting[/b]
[list]
[*][b]HTF candle visual rendering[/b] uses `request.security` with `lookahead=barmerge.lookahead_on`. The live body and wicks update intrabar as the current HTF candle develops. This is display-only and is the standard practice for visualizing a forming HTF candle. The `lookahead_on` value is never used in any signal condition.
[*][b]All signals[/b] are gated by `barstate.isconfirmed` and fire only on closed bars, never intrabar.
[*][b]Zone-entry filter[/b]: a signal fires only if `math.abs(close - level) <= threshold` on this bar AND `math.abs(close[1] - level) > threshold` on the prior bar. Price must move into the zone on this bar; already being inside the zone does not retrigger.
[*][b]Per-period gate[/b]: a boolean flag resets at the start of each new HTF candle and is set on the first signal. At most one signal fires per HTF period per level.
[*][b]Alerts[/b] are gated by `barstate.isconfirmed` and fire once per confirmed bar.
[/list]

[b]Typical Analysis Workflow[/b]
A common analytical workflow may include:
[list=1]
[*]Checking the alignment row to establish a directional context — ↑↑ or ↓↓ ALIGNED suggests all active timeframes agree; ⇅ MIXED means caution
[*]Reading the range position gauge to see whether price is extended (above 80% or below 20% of the HTF range, highlighted in amber) or mid-range
[*]Watching the OHLC projection lines for the current session's active levels — these are the structurally meaningful prices for the live HTF candle
[*]Noting level-touch signals as markers where price has closed near a key HTF boundary; combine with other analysis to assess significance
[/list]

[b]Configuration[/b]
[b]Auto Timeframes[/b] — when enabled, selects the three most relevant standard TFs above the chart automatically. Disable to pin timeframes manually per level.
[b]Candles to Show[/b] — how many closed HTF candles to keep on chart per level. Older candles are removed as new ones close.
[b]Display Type[/b] — Candles, Bars, or HL. Applied to all levels simultaneously.
[b]Per level (HTF 1 / 2 / 3)[/b] — enable/disable, custom timeframe, body opacity (0=opaque to 95=near-transparent), and separate bull/bear color pickers.
[b]Visual group[/b] — show/hide wicks, mid-line, timeframe labels, live-candle highlight, bias background, anchor dots at period starts, and new-period shade.
[b]Projections[/b] — show/hide H, L, O, C levels independently; extend-right bars; price labels on/off.
[b]Panel[/b] — show/hide.
[b]Signals[/b] — show/hide; touch threshold as ATR multiplier (0.05–1.0); H/L and Open toggles per level independently.

[b]Markets and Timeframes[/b]
Works on any instrument and timeframe where at least one higher timeframe exists above the chart:
[list]
[*]Forex
[*]Stocks and Indices
[*]Commodities
[*]Cryptocurrencies
[/list]
Auto timeframe selection scales from 1m charts (1H / 4H / D auto) through Daily (W / M auto). At the top of the timeframe ladder, fewer than three higher timeframes exist and the unused levels can be disabled.

[b]Alerts[/b]
[list]
[*]HTF 1 H/L Touch — price closed near HTF 1 High or Low
[*]HTF 2 H/L Touch — price closed near HTF 2 High or Low
[*]HTF 3 H/L Touch — price closed near HTF 3 High or Low
[*]Any HTF H/L Touch — price closed near any active HTF High or Low
[/list]
All alerts fire on confirmed bars only.

## Source Code

````pine
//@version=6
// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/
// © MQLSoftware
//
// HTF Candle Architecture [MQLSoftware]
// Reconstructs up to 3 Higher Timeframe candles as overlays on the current chart.
// Display modes: Candles (box body + wicks), Bars (OHLC bar lines), HL (High/Low range).
// 3 simultaneous HTF levels — auto-selects the 3 most relevant TFs above chart timeframe.

indicator("HTF Candle Architecture [MQLSoftware]", shorttitle="MQLSoftware - HTF Candle Architecture", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ─── CONSTANTS ────────────────────────────────────────────────────────────────
color L1_BULL_DEF = #00C8FF  // 4H bull — electric cyan
color L1_BEAR_DEF = #FF2244  // 4H bear — vivid red
color L2_BULL_DEF = #A78BFA  // Daily bull — purple
color L2_BEAR_DEF = #C0392B  // Daily bear — deep crimson (NOT orange)
color L3_BULL_DEF = #00CCA3  // Weekly bull — teal
color L3_BEAR_DEF = #8B0000  // Weekly bear — dark red

// Neo Slate design tokens — MQLSoftware brand palette
color NS_BULL  = color.rgb(  0, 210, 255)
color NS_BEAR  = color.rgb(255,  70, 105)
color NS_AMBER = color.rgb(255, 175,  20)
color NS_WHITE = color.rgb(225, 230, 240)
color NS_LBL   = color.rgb(170, 178, 195)
color NS_SEC   = color.rgb( 90,  98, 115)
color NS_BG    = color.new(color.rgb(  8, 11, 18),  4)
color NS_ROW   = color.new(color.rgb( 16, 20, 30),  6)
color NS_SEP   = color.new(color.rgb( 30, 38, 56), 10)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
var string GRP_S   = "◆ Settings"
var string GRP_L1  = "HTF 1"
var string GRP_L2  = "HTF 2"
var string GRP_L3  = "HTF 3"
var string GRP_V   = "Visual"
var string GRP_P   = "◆ Projections"
var string GRP_SIG = "◆ Signals"
var string GRP_PNL = "◆ Panel"

bool autoTf        = input.bool(true, "Auto Timeframes", group = GRP_S,
     tooltip = "Auto-selects 3 standard TFs above your chart. Disable to pick manually.")
int  candlesToShow = input.int (20,   "Candles to Show", group = GRP_S, minval = 5, maxval = 100)
int  wickTransp    = input.int (50,   "Wick Transparency", group = GRP_S, minval = 0, maxval = 90)

bool   l1On      = input.bool     (true,        "Enable",           group = GRP_L1)
string l1TfMan   = input.timeframe("1D",         "Timeframe",        group = GRP_L1)
int    l1BodyTp  = input.int      (70,           "Body Opacity %",   group = GRP_L1,
     minval = 0, maxval = 95,
     tooltip = "0 = fully opaque, 95 = nearly invisible. Lower TF → lower value for more detail.")
color  l1Bull    = input.color    (L1_BULL_DEF,  "Bull",             group = GRP_L1, inline = "l1c")
color  l1Bear    = input.color    (L1_BEAR_DEF,  "Bear",             group = GRP_L1, inline = "l1c")

bool   l2On      = input.bool     (true,        "Enable",           group = GRP_L2)
string l2TfMan   = input.timeframe("1W",         "Timeframe",        group = GRP_L2)
int    l2BodyTp  = input.int      (83,           "Body Opacity %",   group = GRP_L2,
     minval = 0, maxval = 95)
color  l2Bull    = input.color    (L2_BULL_DEF,  "Bull",             group = GRP_L2, inline = "l2c")
color  l2Bear    = input.color    (L2_BEAR_DEF,  "Bear",             group = GRP_L2, inline = "l2c")

bool   l3On      = input.bool     (false,       "Enable",           group = GRP_L3)
string l3TfMan   = input.timeframe("1M",         "Timeframe",        group = GRP_L3)
int    l3BodyTp  = input.int      (91,           "Body Opacity %",   group = GRP_L3,
     minval = 0, maxval = 95)
color  l3Bull    = input.color    (L3_BULL_DEF,  "Bull",             group = GRP_L3, inline = "l3c")
color  l3Bear    = input.color    (L3_BEAR_DEF,  "Bear",             group = GRP_L3, inline = "l3c")

string dispType      = input.string("Candles", "Display Type",
     options = ["Candles", "Bars", "HL"], group = GRP_V,
     tooltip = "Candles: body box + wicks.  Bars: OHLC bar lines.  HL: High/Low range only.")
bool   showWicks     = input.bool(true,  "Show Wicks",            group = GRP_V)
bool   showMid       = input.bool(true,  "Show Mid-Line (Open)",  group = GRP_V)
bool   l1ShowLbl     = input.bool(false, "Labels: HTF 1",         group = GRP_V, inline = "lbl",
     tooltip = "Show timeframe label on each closed candle.")
bool   l2ShowLbl     = input.bool(false, "HTF 2",                 group = GRP_V, inline = "lbl")
bool   l3ShowLbl     = input.bool(true,  "HTF 3",                 group = GRP_V, inline = "lbl")
bool   highlightLive = input.bool(true,  "Highlight Live Candle", group = GRP_V)
bool   showBiasBg    = input.bool(true,  "HTF Bias Background",   group = GRP_V,
     tooltip = "Subtle background tint matching the primary HTF level bias (bull=blue, bear=red).")
bool   showAnchor    = input.bool(false, "Anchor Dots",           group = GRP_V,
     tooltip = "Dot marker at the start of each HTF candle.")
bool   showBgShade   = input.bool(false, "Shade New Period",      group = GRP_V,
     tooltip = "Subtle background flash when a new HTF candle begins.")

bool   showProj     = input.bool(true,  "Show OHLC Projections", group = GRP_P,
     tooltip = "Project current HTF candle's H/L/O/C as horizontal levels to the right.")
bool   showProjLbls = input.bool(true,  "Price Labels",          group = GRP_P)
int    projExtend   = input.int (30,    "Extend Right (bars)",   group = GRP_P, minval = 1, maxval = 500)
bool   showPH = input.bool(true, "H", group = GRP_P, inline = "proj_hl", tooltip = "Show High level")
bool   showPL = input.bool(true, "L", group = GRP_P, inline = "proj_hl", tooltip = "Show Low level")
bool   showPO = input.bool(true, "O", group = GRP_P, inline = "proj_oc", tooltip = "Show Open level")
bool   showPC = input.bool(true, "C", group = GRP_P, inline = "proj_oc", tooltip = "Show Close level (live)")

bool  showPanel   = input.bool(true,  "Show Panel",              group = GRP_PNL)
bool  showSig     = input.bool(true,  "Show Level Signals",      group = GRP_SIG,
     tooltip = "Arrow when price closes within Touch Threshold of an active HTF level.")
float touchThresh = input.float(0.25, "Touch Threshold (× ATR)", group = GRP_SIG,
     minval = 0.05, maxval = 1.0, step = 0.05,
     tooltip = "Close must be within N × ATR14 of the HTF level to fire a signal.")
bool sigL1HL = input.bool(true,  "L1 H/L", group = GRP_SIG, inline = "s1")
bool sigL1O  = input.bool(false, "L1 O",   group = GRP_SIG, inline = "s1")
bool sigL2HL = input.bool(true,  "L2 H/L", group = GRP_SIG, inline = "s2")
bool sigL2O  = input.bool(false, "L2 O",   group = GRP_SIG, inline = "s2")
bool sigL3HL = input.bool(true,  "L3 H/L", group = GRP_SIG, inline = "s3")
bool sigL3O  = input.bool(false, "L3 O",   group = GRP_SIG, inline = "s3")

// ─── AUTO-TF RESOLUTION ───────────────────────────────────────────────────────
int chartSecs = timeframe.in_seconds(timeframe.period)

string _l1Auto = chartSecs <= 300  ? "60"  :
                 chartSecs <= 1800 ? "240" :
                 chartSecs <= 7200 ? "1D"  : "1W"
string _l2Auto = chartSecs <= 300  ? "240" :
                 chartSecs <= 1800 ? "1D"  :
                 chartSecs <= 7200 ? "1W"  : "1M"
string _l3Auto = chartSecs <= 300  ? "1D"  :
                 chartSecs <= 1800 ? "1W"  :
                 chartSecs <= 7200 ? "1M"  : "3M"

string l1Tf = autoTf ? _l1Auto : l1TfMan
string l2Tf = autoTf ? _l2Auto : l2TfMan
string l3Tf = autoTf ? _l3Auto : l3TfMan

// ─── HTF DATA ─────────────────────────────────────────────────────────────────
// lookahead_on is used ONLY for visual rendering of the live HTF candle body/wicks.
// Signals fire on barstate.isconfirmed — no repainting occurs.
[l1LO, l1LH, l1LL, l1LC, l1Time] = request.security(syminfo.tickerid, l1Tf,
     [open, high, low, close, time], lookahead = barmerge.lookahead_on)
[l2LO, l2LH, l2LL, l2LC, l2Time] = request.security(syminfo.tickerid, l2Tf,
     [open, high, low, close, time], lookahead = barmerge.lookahead_on)
[l3LO, l3LH, l3LL, l3LC, l3Time] = request.security(syminfo.tickerid, l3Tf,
     [open, high, low, close, time], lookahead = barmerge.lookahead_on)

bool l1New = ta.change(l1Time) != 0
bool l2New = ta.change(l2Time) != 0
bool l3New = ta.change(l3Time) != 0

// ─── STATE — CANDLE HISTORY ───────────────────────────────────────────────────
// In Bars/HL modes l_LvBox is always na; l_LvLeft tracks live-candle existence.
// WicksU / WicksL / Mids are repurposed per mode:
//   Candles → upper wick / lower wick / open mid-line
//   Bars    → H-L spine  / open tick  / close tick
//   HL      → H level    / L level    / (unused, na)
var array<box>   l1Boxes  = array.new<box>()
var array<line>  l1WicksU = array.new<line>()
var array<line>  l1WicksL = array.new<line>()
var array<line>  l1Mids   = array.new<line>()
var array<label> l1Labels = array.new<label>()
var box          l1LvBox  = na
var line         l1LvWU   = na
var line         l1LvWL   = na
var line         l1LvMid  = na
var int          l1LvLeft = na

var array<box>   l2Boxes  = array.new<box>()
var array<line>  l2WicksU = array.new<line>()
var array<line>  l2WicksL = array.new<line>()
var array<line>  l2Mids   = array.new<line>()
var array<label> l2Labels = array.new<label>()
var box          l2LvBox  = na
var line         l2LvWU   = na
var line         l2LvWL   = na
var line         l2LvMid  = na
var int          l2LvLeft = na

var array<box>   l3Boxes  = array.new<box>()
var array<line>  l3WicksU = array.new<line>()
var array<line>  l3WicksL = array.new<line>()
var array<line>  l3Mids   = array.new<line>()
var array<label> l3Labels = array.new<label>()
var box          l3LvBox  = na
var line         l3LvWU   = na
var line         l3LvWL   = na
var line         l3LvMid  = na
var int          l3LvLeft = na

// ─── STATE — OHLC PROJECTION LINES ───────────────────────────────────────────
var line  l1PH    = na
var line  l1PL    = na
var line  l1PO    = na
var line  l1PC    = na
var label l1PHlbl = na
var label l1PLlbl = na
var label l1POlbl = na
var label l1PClbl = na
var line  l2PH    = na
var line  l2PL    = na
var line  l2PO    = na
var line  l2PC    = na
var label l2PHlbl = na
var label l2PLlbl = na
var label l2POlbl = na
var label l2PClbl = na
var line  l3PH    = na
var line  l3PL    = na
var line  l3PO    = na
var line  l3PC    = na
var label l3PHlbl = na
var label l3PLlbl = na
var label l3POlbl = na
var label l3PClbl = na

// ─── STATE — SIGNALS ─────────────────────────────────────────────────────────
var array<label> sigLbls    = array.new<label>()
var string       lastSigTxt = "—"
var color        lastSigCol = na
// One signal per HTF period — reset when a new HTF candle starts
var bool         l1SigUsed  = false
var bool         l2SigUsed  = false
var bool         l3SigUsed  = false

// ─── HELPERS ──────────────────────────────────────────────────────────────────
f_tfLbl(string tf) =>
    switch tf
        "1"   => "1m"
        "3"   => "3m"
        "5"   => "5m"
        "10"  => "10m"
        "15"  => "15m"
        "30"  => "30m"
        "45"  => "45m"
        "60"  => "1H"
        "120" => "2H"
        "180" => "3H"
        "240" => "4H"
        "1D"  => "D"
        "1W"  => "W"
        "1M"  => "M"
        "3M"  => "3M"
        "6M"  => "6M"
        "12M" => "12M"
        => tf

f_cleanup(array<box> bxs, array<line> wu, array<line> wl,
          array<line> mids, array<label> lbls, int cap) =>
    while array.size(bxs) > cap
        b = array.shift(bxs)
        if not na(b)
            box.delete(b)
        if array.size(wu) > 0
            lu = array.shift(wu)
            if not na(lu)
                line.delete(lu)
        if array.size(wl) > 0
            ll = array.shift(wl)
            if not na(ll)
                line.delete(ll)
        if array.size(mids) > 0
            lm = array.shift(mids)
            if not na(lm)
                line.delete(lm)
        if array.size(lbls) > 0
            lb = array.shift(lbls)
            if not na(lb)
                label.delete(lb)

f_updateProj(line projLine, label projLbl, bool show,
             int x1, int x2, float price,
             color lineCol, string lblText) =>
    line  newLine = projLine
    label newLbl  = projLbl
    if show and not na(price)
        if na(newLine)
            newLine := line.new(x1, price, x2, price,
                 color = lineCol, style = line.style_dotted, width = 1)
        else
            line.set_x1(newLine, x1), line.set_x2(newLine, x2)
            line.set_y1(newLine, price), line.set_y2(newLine, price)
            line.set_color(newLine, lineCol)
        if showProjLbls
            string ltext = lblText + "  " + str.tostring(price, format.mintick)
            if na(newLbl)
                newLbl := label.new(x2, price, ltext,
                     color     = color.new(lineCol, 75),
                     textcolor = lineCol,
                     style     = label.style_label_left,
                     size      = size.tiny)
            else
                label.set_x(newLbl, x2)
                label.set_y(newLbl, price)
                label.set_text(newLbl, ltext)
                label.set_textcolor(newLbl, lineCol)
    else
        if not na(newLine)
            line.delete(newLine)
            newLine := na
        if not na(newLbl)
            label.delete(newLbl)
            newLbl := na
    [newLine, newLbl]

// ─── MAIN ─────────────────────────────────────────────────────────────────────
float atr14     = ta.atr(14)
bool  isCandles = dispType == "Candles"
bool  isBars    = dispType == "Bars"

// ══ LEVEL 1 ══════════════════════════════════════════════════════════════════
if l1On
    // ── Finalize closed candle ───────────────────────────────────────────────
    if l1New and not na(l1LvLeft)
        float fO    = l1LO[1], fH = l1LH[1], fL = l1LL[1], fC = l1LC[1]
        bool  fBull = fC >= fO
        color fCol  = fBull ? l1Bull : l1Bear
        float fTop  = math.max(fO, fC)
        float fBot  = math.min(fO, fC)
        int   fRight = bar_index - 1
        int   fCx    = math.round((l1LvLeft + fRight) / 2)
        int   fTick  = math.max(1, math.round((fRight - l1LvLeft) / 6))

        if isCandles
            if not na(l1LvBox)
                box.set_top         (l1LvBox, fTop)
                box.set_bottom      (l1LvBox, fBot)
                box.set_bgcolor     (l1LvBox, color.new(fCol, l1BodyTp))
                box.set_border_color(l1LvBox, color.new(fCol, 30))
                box.set_border_width(l1LvBox, 1)
            if showWicks
                if not na(l1LvWU)
                    if fH > fTop
                        line.set_y1(l1LvWU, fTop), line.set_y2(l1LvWU, fH)
                    else
                        line.delete(l1LvWU), l1LvWU := na
                if not na(l1LvWL)
                    if fL < fBot
                        line.set_y1(l1LvWL, fL), line.set_y2(l1LvWL, fBot)
                    else
                        line.delete(l1LvWL), l1LvWL := na
            if showMid and not na(l1LvMid)
                if math.abs(fO - fC) < atr14 * 0.05
                    line.delete(l1LvMid), l1LvMid := na
                else
                    line.set_y1(l1LvMid, fO), line.set_y2(l1LvMid, fO)

        else if isBars
            if not na(l1LvWU)
                line.set_x1(l1LvWU, fCx),           line.set_x2(l1LvWU, fCx)
                line.set_y1(l1LvWU, fH),             line.set_y2(l1LvWU, fL)
                line.set_color(l1LvWU, color.new(fCol, wickTransp))
            if not na(l1LvWL)
                line.set_x1(l1LvWL, fCx - fTick),   line.set_x2(l1LvWL, fCx)
                line.set_y1(l1LvWL, fO),             line.set_y2(l1LvWL, fO)
                line.set_color(l1LvWL, color.new(fCol, wickTransp))
            if not na(l1LvMid)
                line.set_x1(l1LvMid, fCx),          line.set_x2(l1LvMid, fCx + fTick)
                line.set_y1(l1LvMid, fC),            line.set_y2(l1LvMid, fC)
                line.set_color(l1LvMid, color.new(fCol, wickTransp))

        else  // HL
            if not na(l1LvWU)
                line.set_x2(l1LvWU, fRight)
                line.set_y1(l1LvWU, fH), line.set_y2(l1LvWU, fH)
                line.set_color(l1LvWU, color.new(fCol, wickTransp))
            if not na(l1LvWL)
                line.set_x2(l1LvWL, fRight)
                line.set_y1(l1LvWL, fL), line.set_y2(l1LvWL, fL)
                line.set_color(l1LvWL, color.new(fCol, wickTransp))

        array.push(l1Boxes,  l1LvBox)
        array.push(l1WicksU, l1LvWU)
        array.push(l1WicksL, l1LvWL)
        array.push(l1Mids,   l1LvMid)
        label _lb1 = na
        if l1ShowLbl
            _lb1 := label.new(fCx, fH, f_tfLbl(l1Tf),
                 color     = color.new(fCol, 70),
                 textcolor = color.new(color.white, 10),
                 style     = label.style_label_down,
                 size      = size.small,
                 yloc      = yloc.price)
        array.push(l1Labels, _lb1)
        f_cleanup(l1Boxes, l1WicksU, l1WicksL, l1Mids, l1Labels, candlesToShow)
        l1LvBox := na, l1LvWU := na, l1LvWL := na, l1LvMid := na, l1LvLeft := na

    // ── Create new live candle ───────────────────────────────────────────────
    if l1New or na(l1LvLeft)
        float lO    = l1LO, lH = l1LH, lL = l1LL, lC = l1LC
        bool  lBull = lC >= lO
        color lCol  = lBull ? l1Bull : l1Bear
        float lTop  = math.max(lO, lC), lBot = math.min(lO, lC)
        l1LvLeft := bar_index
        l1LvBox  := na
        l1LvWU   := na
        l1LvWL   := na
        l1LvMid  := na

        if showAnchor
            label.new(bar_index, lH, "●",
                 color = color.new(lCol, 60), textcolor = color.new(lCol, 0),
                 style = label.style_none, size = size.tiny, yloc = yloc.price)

        if isCandles
            l1LvBox := box.new(bar_index, lTop, bar_index, lBot,
                 bgcolor      = color.new(lCol, l1BodyTp),
                 border_color = color.new(lCol, highlightLive ? 0 : 30),
                 border_width = highlightLive ? 2 : 1)
            if showWicks
                if lH > lTop
                    l1LvWU := line.new(bar_index, lTop, bar_index, lH,
                         color = color.new(lCol, wickTransp))
                if lL < lBot
                    l1LvWL := line.new(bar_index, lL, bar_index, lBot,
                         color = color.new(lCol, wickTransp))
            if showMid and not na(atr14) and math.abs(lO - lC) >= atr14 * 0.05
                l1LvMid := line.new(bar_index, lO, bar_index, lO,
                     color = color.new(lCol, math.max(l1BodyTp - 30, 0)),
                     style = line.style_dashed, width = 2)

        else if isBars
            l1LvWU  := line.new(bar_index, lH, bar_index, lL,
                 color = color.new(lCol, wickTransp))
            l1LvWL  := line.new(bar_index - 1, lO, bar_index, lO,
                 color = color.new(lCol, wickTransp))
            l1LvMid := line.new(bar_index, lC, bar_index + 1, lC,
                 color = color.new(lCol, wickTransp))

        else  // HL
            l1LvWU := line.new(bar_index, lH, bar_index, lH,
                 color = color.new(lCol, wickTransp))
            l1LvWL := line.new(bar_index, lL, bar_index, lL,
                 color = color.new(lCol, wickTransp))

    // ── Update live candle ───────────────────────────────────────────────────
    else if not na(l1LvLeft)
        float lO    = l1LO, lH = l1LH, lL = l1LL, lC = l1LC
        bool  lBull = lC >= lO
        color lCol  = lBull ? l1Bull : l1Bear
        float lTop  = math.max(lO, lC), lBot = math.min(lO, lC)
        int   cx    = math.round((l1LvLeft + bar_index) / 2)
        int   tk    = math.max(1, math.round((bar_index - l1LvLeft) / 6))

        if isCandles
            if not na(l1LvBox)
                box.set_right       (l1LvBox, bar_index)
                box.set_top         (l1LvBox, lTop)
                box.set_bottom      (l1LvBox, lBot)
                box.set_bgcolor     (l1LvBox, color.new(lCol, l1BodyTp))
                box.set_border_color(l1LvBox, color.new(lCol, highlightLive ? 0 : 30))
                box.set_border_width(l1LvBox, highlightLive ? 2 : 1)
            if showWicks
                if not na(l1LvWU)
                    line.set_x1(l1LvWU, cx), line.set_x2(l1LvWU, cx)
                    line.set_y1(l1LvWU, lTop), line.set_y2(l1LvWU, lH)
                else if lH > lTop
                    l1LvWU := line.new(cx, lTop, cx, lH, color = color.new(lCol, wickTransp))
                if not na(l1LvWL)
                    line.set_x1(l1LvWL, cx), line.set_x2(l1LvWL, cx)
                    line.set_y1(l1LvWL, lL), line.set_y2(l1LvWL, lBot)
                else if lL < lBot
                    l1LvWL := line.new(cx, lL, cx, lBot, color = color.new(lCol, wickTransp))
            if showMid and not na(l1LvMid)
                line.set_x2(l1LvMid, bar_index)

        else if isBars
            if not na(l1LvWU)
                line.set_x1(l1LvWU, cx),     line.set_x2(l1LvWU, cx)
                line.set_y1(l1LvWU, lH),      line.set_y2(l1LvWU, lL)
                line.set_color(l1LvWU, color.new(lCol, wickTransp))
            if not na(l1LvWL)
                line.set_x1(l1LvWL, cx - tk), line.set_x2(l1LvWL, cx)
                line.set_y1(l1LvWL, lO),       line.set_y2(l1LvWL, lO)
                line.set_color(l1LvWL, color.new(lCol, wickTransp))
            if not na(l1LvMid)
                line.set_x1(l1LvMid, cx),     line.set_x2(l1LvMid, cx + tk)
                line.set_y1(l1LvMid, lC),      line.set_y2(l1LvMid, lC)
                line.set_color(l1LvMid, color.new(lCol, wickTransp))

        else  // HL
            if not na(l1LvWU)
                line.set_x2(l1LvWU, bar_index)
                line.set_y1(l1LvWU, lH), line.set_y2(l1LvWU, lH)
                line.set_color(l1LvWU, color.new(lCol, wickTransp))
            if not na(l1LvWL)
                line.set_x2(l1LvWL, bar_index)
                line.set_y1(l1LvWL, lL), line.set_y2(l1LvWL, lL)
                line.set_color(l1LvWL, color.new(lCol, wickTransp))

    // ── OHLC projections ─────────────────────────────────────────────────────
    if showProj and not na(l1LvLeft)
        int    px1    = l1LvLeft
        int    px2    = bar_index + projExtend
        bool   lBull1 = l1LC >= l1LO
        color  bullC1 = color.new(l1Bull, 20)
        color  bearC1 = color.new(l1Bear, 20)
        color  openC1 = color.new(color.gray, 40)
        color  cls1   = color.new(lBull1 ? l1Bull : l1Bear, 10)
        string tf1    = f_tfLbl(l1Tf)
        [_ph, _phl] = f_updateProj(l1PH, l1PHlbl, showPH, px1, px2, l1LH, bullC1, tf1 + " H")
        l1PH := _ph, l1PHlbl := _phl
        [_pl, _pll] = f_updateProj(l1PL, l1PLlbl, showPL, px1, px2, l1LL, bearC1, tf1 + " L")
        l1PL := _pl, l1PLlbl := _pll
        [_po, _pol] = f_updateProj(l1PO, l1POlbl, showPO, px1, px2, l1LO, openC1, tf1 + " O")
        l1PO := _po, l1POlbl := _pol
        [_pc, _pcl] = f_updateProj(l1PC, l1PClbl, showPC, px1, px2, l1LC, cls1,   tf1 + " C")
        l1PC := _pc, l1PClbl := _pcl

// ══ LEVEL 2 ══════════════════════════════════════════════════════════════════
if l2On
    // ── Finalize closed candle ───────────────────────────────────────────────
    if l2New and not na(l2LvLeft)
        float fO    = l2LO[1], fH = l2LH[1], fL = l2LL[1], fC = l2LC[1]
        bool  fBull = fC >= fO
        color fCol  = fBull ? l2Bull : l2Bear
        float fTop  = math.max(fO, fC)
        float fBot  = math.min(fO, fC)
        int   fRight = bar_index - 1
        int   fCx    = math.round((l2LvLeft + fRight) / 2)
        int   fTick  = math.max(1, math.round((fRight - l2LvLeft) / 6))

        if isCandles
            if not na(l2LvBox)
                box.set_top         (l2LvBox, fTop)
                box.set_bottom      (l2LvBox, fBot)
                box.set_bgcolor     (l2LvBox, color.new(fCol, l2BodyTp))
                box.set_border_color(l2LvBox, color.new(fCol, 20))
                box.set_border_width(l2LvBox, 2)
            if showWicks
                if not na(l2LvWU)
                    if fH > fTop
                        line.set_y1(l2LvWU, fTop), line.set_y2(l2LvWU, fH)
                    else
                        line.delete(l2LvWU), l2LvWU := na
                if not na(l2LvWL)
                    if fL < fBot
                        line.set_y1(l2LvWL, fL), line.set_y2(l2LvWL, fBot)
                    else
                        line.delete(l2LvWL), l2LvWL := na
            if showMid and not na(l2LvMid)
                if math.abs(fO - fC) < atr14 * 0.05
                    line.delete(l2LvMid), l2LvMid := na
                else
                    line.set_y1(l2LvMid, fO), line.set_y2(l2LvMid, fO)

        else if isBars
            if not na(l2LvWU)
                line.set_x1(l2LvWU, fCx),           line.set_x2(l2LvWU, fCx)
                line.set_y1(l2LvWU, fH),             line.set_y2(l2LvWU, fL)
                line.set_color(l2LvWU, color.new(fCol, wickTransp))
            if not na(l2LvWL)
                line.set_x1(l2LvWL, fCx - fTick),   line.set_x2(l2LvWL, fCx)
                line.set_y1(l2LvWL, fO),             line.set_y2(l2LvWL, fO)
                line.set_color(l2LvWL, color.new(fCol, wickTransp))
            if not na(l2LvMid)
                line.set_x1(l2LvMid, fCx),          line.set_x2(l2LvMid, fCx + fTick)
                line.set_y1(l2LvMid, fC),            line.set_y2(l2LvMid, fC)
                line.set_color(l2LvMid, color.new(fCol, wickTransp))

        else  // HL
            if not na(l2LvWU)
                line.set_x2(l2LvWU, fRight)
                line.set_y1(l2LvWU, fH), line.set_y2(l2LvWU, fH)
                line.set_color(l2LvWU, color.new(fCol, wickTransp))
            if not na(l2LvWL)
                line.set_x2(l2LvWL, fRight)
                line.set_y1(l2LvWL, fL), line.set_y2(l2LvWL, fL)
                line.set_color(l2LvWL, color.new(fCol, wickTransp))

        array.push(l2Boxes,  l2LvBox)
        array.push(l2WicksU, l2LvWU)
        array.push(l2WicksL, l2LvWL)
        array.push(l2Mids,   l2LvMid)
        label _lb2 = na
        if l2ShowLbl
            _lb2 := label.new(fCx, fTop, f_tfLbl(l2Tf),
                 color     = color.new(fCol, 70),
                 textcolor = color.new(color.white, 10),
                 style     = label.style_label_down,
                 size      = size.small,
                 yloc      = yloc.price)
        array.push(l2Labels, _lb2)
        f_cleanup(l2Boxes, l2WicksU, l2WicksL, l2Mids, l2Labels, candlesToShow)
        l2LvBox := na, l2LvWU := na, l2LvWL := na, l2LvMid := na, l2LvLeft := na

    // ── Create new live candle ───────────────────────────────────────────────
    if l2New or na(l2LvLeft)
        float lO    = l2LO, lH = l2LH, lL = l2LL, lC = l2LC
        bool  lBull = lC >= lO
        color lCol  = lBull ? l2Bull : l2Bear
        float lTop  = math.max(lO, lC), lBot = math.min(lO, lC)
        l2LvLeft := bar_index
        l2LvBox  := na
        l2LvWU   := na
        l2LvWL   := na
        l2LvMid  := na

        if showAnchor
            label.new(bar_index, lH, "●",
                 color = color.new(lCol, 60), textcolor = color.new(lCol, 0),
                 style = label.style_none, size = size.tiny, yloc = yloc.price)

        if isCandles
            l2LvBox := box.new(bar_index, lTop, bar_index, lBot,
                 bgcolor      = color.new(lCol, l2BodyTp),
                 border_color = color.new(lCol, highlightLive ? 0 : 20),
                 border_width = highlightLive ? 3 : 2)
            if showWicks
                if lH > lTop
                    l2LvWU := line.new(bar_index, lTop, bar_index, lH,
                         color = color.new(lCol, wickTransp))
                if lL < lBot
                    l2LvWL := line.new(bar_index, lL, bar_index, lBot,
                         color = color.new(lCol, wickTransp))
            if showMid and not na(atr14) and math.abs(lO - lC) >= atr14 * 0.05
                l2LvMid := line.new(bar_index, lO, bar_index, lO,
                     color = color.new(lCol, math.max(l2BodyTp - 30, 0)),
                     style = line.style_dashed, width = 2)

        else if isBars
            l2LvWU  := line.new(bar_index, lH, bar_index, lL,
                 color = color.new(lCol, wickTransp))
            l2LvWL  := line.new(bar_index - 1, lO, bar_index, lO,
                 color = color.new(lCol, wickTransp))
            l2LvMid := line.new(bar_index, lC, bar_index + 1, lC,
                 color = color.new(lCol, wickTransp))

        else  // HL
            l2LvWU := line.new(bar_index, lH, bar_index, lH,
                 color = color.new(lCol, wickTransp))
            l2LvWL := line.new(bar_index, lL, bar_index, lL,
                 color = color.new(lCol, wickTransp))

    // ── Update live candle ───────────────────────────────────────────────────
    else if not na(l2LvLeft)
        float lO    = l2LO, lH = l2LH, lL = l2LL, lC = l2LC
        bool  lBull = lC >= lO
        color lCol  = lBull ? l2Bull : l2Bear
        float lTop  = math.max(lO, lC), lBot = math.min(lO, lC)
        int   cx    = math.round((l2LvLeft + bar_index) / 2)
        int   tk    = math.max(1, math.round((bar_index - l2LvLeft) / 6))

        if isCandles
            if not na(l2LvBox)
                box.set_right       (l2LvBox, bar_index)
                box.set_top         (l2LvBox, lTop)
                box.set_bottom      (l2LvBox, lBot)
                box.set_bgcolor     (l2LvBox, color.new(lCol, l2BodyTp))
                box.set_border_color(l2LvBox, color.new(lCol, highlightLive ? 0 : 20))
                box.set_border_width(l2LvBox, highlightLive ? 3 : 2)
            if showWicks
                if not na(l2LvWU)
                    line.set_x1(l2LvWU, cx), line.set_x2(l2LvWU, cx)
                    line.set_y1(l2LvWU, lTop), line.set_y2(l2LvWU, lH)
                else if lH > lTop
                    l2LvWU := line.new(cx, lTop, cx, lH, color = color.new(lCol, wickTransp))
                if not na(l2LvWL)
                    line.set_x1(l2LvWL, cx), line.set_x2(l2LvWL, cx)
                    line.set_y1(l2LvWL, lL), line.set_y2(l2LvWL, lBot)
                else if lL < lBot
                    l2LvWL := line.new(cx, lL, cx, lBot, color = color.new(lCol, wickTransp))
            if showMid and not na(l2LvMid)
                line.set_x2(l2LvMid, bar_index)

        else if isBars
            if not na(l2LvWU)
                line.set_x1(l2LvWU, cx),     line.set_x2(l2LvWU, cx)
                line.set_y1(l2LvWU, lH),      line.set_y2(l2LvWU, lL)
                line.set_color(l2LvWU, color.new(lCol, wickTransp))
            if not na(l2LvWL)
                line.set_x1(l2LvWL, cx - tk), line.set_x2(l2LvWL, cx)
                line.set_y1(l2LvWL, lO),       line.set_y2(l2LvWL, lO)
                line.set_color(l2LvWL, color.new(lCol, wickTransp))
            if not na(l2LvMid)
                line.set_x1(l2LvMid, cx),     line.set_x2(l2LvMid, cx + tk)
                line.set_y1(l2LvMid, lC),      line.set_y2(l2LvMid, lC)
                line.set_color(l2LvMid, color.new(lCol, wickTransp))

        else  // HL
            if not na(l2LvWU)
                line.set_x2(l2LvWU, bar_index)
                line.set_y1(l2LvWU, lH), line.set_y2(l2LvWU, lH)
                line.set_color(l2LvWU, color.new(lCol, wickTransp))
            if not na(l2LvWL)
                line.set_x2(l2LvWL, bar_index)
                line.set_y1(l2LvWL, lL), line.set_y2(l2LvWL, lL)
                line.set_color(l2LvWL, color.new(lCol, wickTransp))

    // ── OHLC projections ─────────────────────────────────────────────────────
    if showProj and not na(l2LvLeft)
        int    px1    = l2LvLeft
        int    px2    = bar_index + projExtend
        bool   lBull2 = l2LC >= l2LO
        color  bullC2 = color.new(l2Bull, 20)
        color  bearC2 = color.new(l2Bear, 20)
        color  openC2 = color.new(color.gray, 40)
        color  cls2   = color.new(lBull2 ? l2Bull : l2Bear, 10)
        string tf2    = f_tfLbl(l2Tf)
        [_ph, _phl] = f_updateProj(l2PH, l2PHlbl, showPH, px1, px2, l2LH, bullC2, tf2 + " H")
        l2PH := _ph, l2PHlbl := _phl
        [_pl, _pll] = f_updateProj(l2PL, l2PLlbl, showPL, px1, px2, l2LL, bearC2, tf2 + " L")
        l2PL := _pl, l2PLlbl := _pll
        [_po, _pol] = f_updateProj(l2PO, l2POlbl, showPO, px1, px2, l2LO, openC2, tf2 + " O")
        l2PO := _po, l2POlbl := _pol
        [_pc, _pcl] = f_updateProj(l2PC, l2PClbl, showPC, px1, px2, l2LC, cls2,   tf2 + " C")
        l2PC := _pc, l2PClbl := _pcl

// ══ LEVEL 3 ══════════════════════════════════════════════════════════════════
if l3On
    // ── Finalize closed candle ───────────────────────────────────────────────
    if l3New and not na(l3LvLeft)
        float fO    = l3LO[1], fH = l3LH[1], fL = l3LL[1], fC = l3LC[1]
        bool  fBull = fC >= fO
        color fCol  = fBull ? l3Bull : l3Bear
        float fTop  = math.max(fO, fC)
        float fBot  = math.min(fO, fC)
        int   fRight = bar_index - 1
        int   fCx    = math.round((l3LvLeft + fRight) / 2)
        int   fTick  = math.max(1, math.round((fRight - l3LvLeft) / 6))

        if isCandles
            if not na(l3LvBox)
                box.set_top         (l3LvBox, fTop)
                box.set_bottom      (l3LvBox, fBot)
                box.set_bgcolor     (l3LvBox, color.new(fCol, l3BodyTp))
                box.set_border_color(l3LvBox, color.new(fCol, 10))
                box.set_border_width(l3LvBox, 2)
            if showWicks
                if not na(l3LvWU)
                    if fH > fTop
                        line.set_y1(l3LvWU, fTop), line.set_y2(l3LvWU, fH)
                    else
                        line.delete(l3LvWU), l3LvWU := na
                if not na(l3LvWL)
                    if fL < fBot
                        line.set_y1(l3LvWL, fL), line.set_y2(l3LvWL, fBot)
                    else
                        line.delete(l3LvWL), l3LvWL := na
            if showMid and not na(l3LvMid)
                if math.abs(fO - fC) < atr14 * 0.05
                    line.delete(l3LvMid), l3LvMid := na
                else
                    line.set_y1(l3LvMid, fO), line.set_y2(l3LvMid, fO)

        else if isBars
            if not na(l3LvWU)
                line.set_x1(l3LvWU, fCx),           line.set_x2(l3LvWU, fCx)
                line.set_y1(l3LvWU, fH),             line.set_y2(l3LvWU, fL)
                line.set_color(l3LvWU, color.new(fCol, wickTransp))
            if not na(l3LvWL)
                line.set_x1(l3LvWL, fCx - fTick),   line.set_x2(l3LvWL, fCx)
                line.set_y1(l3LvWL, fO),             line.set_y2(l3LvWL, fO)
                line.set_color(l3LvWL, color.new(fCol, wickTransp))
            if not na(l3LvMid)
                line.set_x1(l3LvMid, fCx),          line.set_x2(l3LvMid, fCx + fTick)
                line.set_y1(l3LvMid, fC),            line.set_y2(l3LvMid, fC)
                line.set_color(l3LvMid, color.new(fCol, wickTransp))

        else  // HL
            if not na(l3LvWU)
                line.set_x2(l3LvWU, fRight)
                line.set_y1(l3LvWU, fH), line.set_y2(l3LvWU, fH)
                line.set_color(l3LvWU, color.new(fCol, wickTransp))
            if not na(l3LvWL)
                line.set_x2(l3LvWL, fRight)
                line.set_y1(l3LvWL, fL), line.set_y2(l3LvWL, fL)
                line.set_color(l3LvWL, color.new(fCol, wickTransp))

        array.push(l3Boxes,  l3LvBox)
        array.push(l3WicksU, l3LvWU)
        array.push(l3WicksL, l3LvWL)
        array.push(l3Mids,   l3LvMid)
        label _lb3 = na
        if l3ShowLbl
            _lb3 := label.new(fCx, math.avg(fTop, fBot), f_tfLbl(l3Tf),
                 color     = color.new(fCol, 70),
                 textcolor = color.new(color.white, 10),
                 style     = label.style_label_down,
                 size      = size.small,
                 yloc      = yloc.price)
        array.push(l3Labels, _lb3)
        f_cleanup(l3Boxes, l3WicksU, l3WicksL, l3Mids, l3Labels, candlesToShow)
        l3LvBox := na, l3LvWU := na, l3LvWL := na, l3LvMid := na, l3LvLeft := na

    // ── Create new live candle ───────────────────────────────────────────────
    if l3New or na(l3LvLeft)
        float lO    = l3LO, lH = l3LH, lL = l3LL, lC = l3LC
        bool  lBull = lC >= lO
        color lCol  = lBull ? l3Bull : l3Bear
        float lTop  = math.max(lO, lC), lBot = math.min(lO, lC)
        l3LvLeft := bar_index
        l3LvBox  := na
        l3LvWU   := na
        l3LvWL   := na
        l3LvMid  := na

        if showAnchor
            label.new(bar_index, lH, "●",
                 color = color.new(lCol, 60), textcolor = color.new(lCol, 0),
                 style = label.style_none, size = size.tiny, yloc = yloc.price)

        if isCandles
            l3LvBox := box.new(bar_index, lTop, bar_index, lBot,
                 bgcolor      = color.new(lCol, l3BodyTp),
                 border_color = color.new(lCol, highlightLive ? 0 : 10),
                 border_width = highlightLive ? 4 : 2)
            if showWicks
                if lH > lTop
                    l3LvWU := line.new(bar_index, lTop, bar_index, lH,
                         color = color.new(lCol, wickTransp))
                if lL < lBot
                    l3LvWL := line.new(bar_index, lL, bar_index, lBot,
                         color = color.new(lCol, wickTransp))
            if showMid and not na(atr14) and math.abs(lO - lC) >= atr14 * 0.05
                l3LvMid := line.new(bar_index, lO, bar_index, lO,
                     color = color.new(lCol, math.max(l3BodyTp - 30, 0)),
                     style = line.style_dashed, width = 2)

        else if isBars
            l3LvWU  := line.new(bar_index, lH, bar_index, lL,
                 color = color.new(lCol, wickTransp))
            l3LvWL  := line.new(bar_index - 1, lO, bar_index, lO,
                 color = color.new(lCol, wickTransp))
            l3LvMid := line.new(bar_index, lC, bar_index + 1, lC,
                 color = color.new(lCol, wickTransp))

        else  // HL
            l3LvWU := line.new(bar_index, lH, bar_index, lH,
                 color = color.new(lCol, wickTransp))
            l3LvWL := line.new(bar_index, lL, bar_index, lL,
                 color = color.new(lCol, wickTransp))

    // ── Update live candle ───────────────────────────────────────────────────
    else if not na(l3LvLeft)
        float lO    = l3LO, lH = l3LH, lL = l3LL, lC = l3LC
        bool  lBull = lC >= lO
        color lCol  = lBull ? l3Bull : l3Bear
        float lTop  = math.max(lO, lC), lBot = math.min(lO, lC)
        int   cx    = math.round((l3LvLeft + bar_index) / 2)
        int   tk    = math.max(1, math.round((bar_index - l3LvLeft) / 6))

        if isCandles
            if not na(l3LvBox)
                box.set_right       (l3LvBox, bar_index)
                box.set_top         (l3LvBox, lTop)
                box.set_bottom      (l3LvBox, lBot)
                box.set_bgcolor     (l3LvBox, color.new(lCol, l3BodyTp))
                box.set_border_color(l3LvBox, color.new(lCol, highlightLive ? 0 : 10))
                box.set_border_width(l3LvBox, highlightLive ? 4 : 2)
            if showWicks
                if not na(l3LvWU)
                    line.set_x1(l3LvWU, cx), line.set_x2(l3LvWU, cx)
                    line.set_y1(l3LvWU, lTop), line.set_y2(l3LvWU, lH)
                else if lH > lTop
                    l3LvWU := line.new(cx, lTop, cx, lH, color = color.new(lCol, wickTransp))
                if not na(l3LvWL)
                    line.set_x1(l3LvWL, cx), line.set_x2(l3LvWL, cx)
                    line.set_y1(l3LvWL, lL), line.set_y2(l3LvWL, lBot)
                else if lL < lBot
                    l3LvWL := line.new(cx, lL, cx, lBot, color = color.new(lCol, wickTransp))
            if showMid and not na(l3LvMid)
                line.set_x2(l3LvMid, bar_index)

        else if isBars
            if not na(l3LvWU)
                line.set_x1(l3LvWU, cx),     line.set_x2(l3LvWU, cx)
                line.set_y1(l3LvWU, lH),      line.set_y2(l3LvWU, lL)
                line.set_color(l3LvWU, color.new(lCol, wickTransp))
            if not na(l3LvWL)
                line.set_x1(l3LvWL, cx - tk), line.set_x2(l3LvWL, cx)
                line.set_y1(l3LvWL, lO),       line.set_y2(l3LvWL, lO)
                line.set_color(l3LvWL, color.new(lCol, wickTransp))
            if not na(l3LvMid)
                line.set_x1(l3LvMid, cx),     line.set_x2(l3LvMid, cx + tk)
                line.set_y1(l3LvMid, lC),      line.set_y2(l3LvMid, lC)
                line.set_color(l3LvMid, color.new(lCol, wickTransp))

        else  // HL
            if not na(l3LvWU)
                line.set_x2(l3LvWU, bar_index)
                line.set_y1(l3LvWU, lH), line.set_y2(l3LvWU, lH)
                line.set_color(l3LvWU, color.new(lCol, wickTransp))
            if not na(l3LvWL)
                line.set_x2(l3LvWL, bar_index)
                line.set_y1(l3LvWL, lL), line.set_y2(l3LvWL, lL)
                line.set_color(l3LvWL, color.new(lCol, wickTransp))

    // ── OHLC projections ─────────────────────────────────────────────────────
    if showProj and not na(l3LvLeft)
        int    px1    = l3LvLeft
        int    px2    = bar_index + projExtend
        bool   lBull3 = l3LC >= l3LO
        color  bullC3 = color.new(l3Bull, 20)
        color  bearC3 = color.new(l3Bear, 20)
        color  openC3 = color.new(color.gray, 40)
        color  cls3   = color.new(lBull3 ? l3Bull : l3Bear, 10)
        string tf3    = f_tfLbl(l3Tf)
        [_ph, _phl] = f_updateProj(l3PH, l3PHlbl, showPH, px1, px2, l3LH, bullC3, tf3 + " H")
        l3PH := _ph, l3PHlbl := _phl
        [_pl, _pll] = f_updateProj(l3PL, l3PLlbl, showPL, px1, px2, l3LL, bearC3, tf3 + " L")
        l3PL := _pl, l3PLlbl := _pll
        [_po, _pol] = f_updateProj(l3PO, l3POlbl, showPO, px1, px2, l3LO, openC3, tf3 + " O")
        l3PO := _po, l3POlbl := _pol
        [_pc, _pcl] = f_updateProj(l3PC, l3PClbl, showPC, px1, px2, l3LC, cls3,   tf3 + " C")
        l3PC := _pc, l3PClbl := _pcl

// ─── BACKGROUND ───────────────────────────────────────────────────────────────
bool _anyNew   = (l1On and l1New) or (l2On and l2New) or (l3On and l3New)
bool _htfBull  = l1On and l1LC >= l1LO
bool _htfBear  = l1On and l1LC < l1LO
bgcolor(showBiasBg and _htfBull ? color.new(NS_BULL, 96) : na, title = "HTF Bull Tint")
bgcolor(showBiasBg and _htfBear ? color.new(NS_BEAR, 96) : na, title = "HTF Bear Tint")
bgcolor(showBgShade and _anyNew ? color.new(color.silver, 92) : na, title = "New HTF Period")

// ─── SIGNALS — HTF LEVEL TOUCH ───────────────────────────────────────────────
// Fires on confirmed bar close only — no repaint.
// One signal per HTF candle period per level (first touch wins, resets on new candle).
if l1New
    l1SigUsed := false
if l2New
    l2SigUsed := false
if l3New
    l3SigUsed := false

if barstate.isconfirmed and showSig
    float thr = atr14 * touchThresh

    if l1On and not l1SigUsed
        string tfl1 = f_tfLbl(l1Tf)
        bool   l1HT = sigL1HL and not na(l1LH) and math.abs(close - l1LH) <= thr and math.abs(close[1] - l1LH) > thr
        bool   l1LT = sigL1HL and not na(l1LL) and math.abs(close - l1LL) <= thr and math.abs(close[1] - l1LL) > thr
        bool   l1OT = sigL1O  and not na(l1LO) and math.abs(close - l1LO) <= thr and math.abs(close[1] - l1LO) > thr
        string sTx1 = l1HT ? "▼ " + tfl1 + " H" : l1LT ? "▲ " + tfl1 + " L" : l1OT ? "◆ " + tfl1 + " O" : ""
        string sPn1 = l1HT ? "▼ " + tfl1 + " HIGH" : l1LT ? "▲ " + tfl1 + " LOW" : l1OT ? "◆ " + tfl1 + " OPEN" : ""
        color  sCl1 = l1HT ? NS_BEAR : l1LT ? NS_BULL : l1OT ? NS_AMBER : na
        bool   sBu1 = l1LT
        if str.length(sTx1) > 0
            label sl1 = label.new(bar_index,
                 sBu1 ? low - atr14 * 0.3 : high + atr14 * 0.3,
                 sTx1,
                 color     = color.new(sCl1, 5),
                 textcolor = NS_WHITE,
                 style     = sBu1 ? label.style_arrowup : label.style_arrowdown,
                 size      = size.small)
            array.push(sigLbls, sl1)
            lastSigTxt := sPn1
            lastSigCol := sCl1
            l1SigUsed  := true

    if l2On and not l2SigUsed
        string tfl2 = f_tfLbl(l2Tf)
        bool   l2HT = sigL2HL and not na(l2LH) and math.abs(close - l2LH) <= thr and math.abs(close[1] - l2LH) > thr
        bool   l2LT = sigL2HL and not na(l2LL) and math.abs(close - l2LL) <= thr and math.abs(close[1] - l2LL) > thr
        bool   l2OT = sigL2O  and not na(l2LO) and math.abs(close - l2LO) <= thr and math.abs(close[1] - l2LO) > thr
        string sTx2 = l2HT ? "▼ " + tfl2 + " H" : l2LT ? "▲ " + tfl2 + " L" : l2OT ? "◆ " + tfl2 + " O" : ""
        string sPn2 = l2HT ? "▼ " + tfl2 + " HIGH" : l2LT ? "▲ " + tfl2 + " LOW" : l2OT ? "◆ " + tfl2 + " OPEN" : ""
        color  sCl2 = l2HT ? NS_BEAR : l2LT ? NS_BULL : l2OT ? NS_AMBER : na
        bool   sBu2 = l2LT
        if str.length(sTx2) > 0
            label sl2 = label.new(bar_index,
                 sBu2 ? low - atr14 * 1.0 : high + atr14 * 1.0,
                 sTx2,
                 color     = color.new(sCl2, 5),
                 textcolor = NS_WHITE,
                 style     = sBu2 ? label.style_arrowup : label.style_arrowdown,
                 size      = size.normal)
            array.push(sigLbls, sl2)
            lastSigTxt := sPn2
            lastSigCol := sCl2
            l2SigUsed  := true

    if l3On and not l3SigUsed
        string tfl3 = f_tfLbl(l3Tf)
        bool   l3HT = sigL3HL and not na(l3LH) and math.abs(close - l3LH) <= thr and math.abs(close[1] - l3LH) > thr
        bool   l3LT = sigL3HL and not na(l3LL) and math.abs(close - l3LL) <= thr and math.abs(close[1] - l3LL) > thr
        bool   l3OT = sigL3O  and not na(l3LO) and math.abs(close - l3LO) <= thr and math.abs(close[1] - l3LO) > thr
        string sTx3 = l3HT ? "▼ " + tfl3 + " H" : l3LT ? "▲ " + tfl3 + " L" : l3OT ? "◆ " + tfl3 + " O" : ""
        string sPn3 = l3HT ? "▼ " + tfl3 + " HIGH" : l3LT ? "▲ " + tfl3 + " LOW" : l3OT ? "◆ " + tfl3 + " OPEN" : ""
        color  sCl3 = l3HT ? NS_BEAR : l3LT ? NS_BULL : l3OT ? NS_AMBER : na
        bool   sBu3 = l3LT
        if str.length(sTx3) > 0
            label sl3 = label.new(bar_index,
                 sBu3 ? low - atr14 * 1.7 : high + atr14 * 1.7,
                 sTx3,
                 color     = color.new(sCl3, 5),
                 textcolor = NS_WHITE,
                 style     = sBu3 ? label.style_arrowup : label.style_arrowdown,
                 size      = size.large)
            array.push(sigLbls, sl3)
            lastSigTxt := sPn3
            lastSigCol := sCl3
            l3SigUsed  := true

    while array.size(sigLbls) > 100
        label _old = array.shift(sigLbls)
        if not na(_old)
            label.delete(_old)

// ─── PANEL — NEO SLATE ────────────────────────────────────────────────────────
var table htfPanel = table.new(position.top_right, 3, 8,
     bgcolor = na, border_width = 0, frame_width = 0)

if showPanel and barstate.islast
    table.clear(htfPanel, 0, 0, 2, 7)

    // Header
    table.cell(htfPanel, 0, 0, "HTF ARCHITECTURE",
         text_color = NS_WHITE, bgcolor = color.new(NS_BULL, 25),
         text_size = size.small, text_halign = text.align_left)
    table.cell(htfPanel, 1, 0, "",
         bgcolor = color.new(NS_BULL, 25))
    table.cell(htfPanel, 2, 0, syminfo.ticker,
         text_color = NS_WHITE, bgcolor = color.new(NS_BULL, 25),
         text_size = size.small, text_halign = text.align_right)

    // Column labels
    table.cell(htfPanel, 0, 1, "FRAME",
         text_color = NS_LBL, bgcolor = NS_SEP,
         text_size = size.tiny, text_halign = text.align_left)
    table.cell(htfPanel, 1, 1, "BIAS",
         text_color = NS_LBL, bgcolor = NS_SEP,
         text_size = size.tiny, text_halign = text.align_center)
    table.cell(htfPanel, 2, 1, "RANGE POS",
         text_color = NS_LBL, bgcolor = NS_SEP,
         text_size = size.tiny, text_halign = text.align_right)

    // L1 row
    bool   _l1b  = l1LC >= l1LO
    float  _l1r  = l1LH - l1LL
    float  _l1p  = l1On and _l1r > 0 ? math.max(0.0, math.min(1.0, (close - l1LL) / _l1r)) : 0.5
    int    _l1f  = math.round(_l1p * 7)
    string _l1g  = l1On ? str.repeat("█", _l1f) + str.repeat("░", 7 - _l1f) + "  " + str.tostring(math.round(_l1p * 100)) + "%" : "—"
    table.cell(htfPanel, 0, 2, l1On ? f_tfLbl(l1Tf) : "—",
         text_color = l1On ? NS_LBL : NS_SEC, bgcolor = NS_ROW,
         text_size = size.small, text_halign = text.align_left)
    table.cell(htfPanel, 1, 2, l1On ? (_l1b ? "↑ BULL" : "↓ BEAR") : "—",
         text_color = l1On ? (_l1b ? NS_BULL : NS_BEAR) : NS_SEC, bgcolor = NS_ROW,
         text_size = size.small, text_halign = text.align_center)
    table.cell(htfPanel, 2, 2, _l1g,
         text_color = l1On ? (_l1p > 0.80 or _l1p < 0.20 ? NS_AMBER : NS_WHITE) : NS_SEC,
         bgcolor = NS_ROW, text_size = size.tiny, text_halign = text.align_right)

    // L2 row
    bool   _l2b  = l2LC >= l2LO
    float  _l2r  = l2LH - l2LL
    float  _l2p  = l2On and _l2r > 0 ? math.max(0.0, math.min(1.0, (close - l2LL) / _l2r)) : 0.5
    int    _l2f  = math.round(_l2p * 7)
    string _l2g  = l2On ? str.repeat("█", _l2f) + str.repeat("░", 7 - _l2f) + "  " + str.tostring(math.round(_l2p * 100)) + "%" : "—"
    table.cell(htfPanel, 0, 3, l2On ? f_tfLbl(l2Tf) : "—",
         text_color = l2On ? NS_LBL : NS_SEC, bgcolor = NS_BG,
         text_size = size.small, text_halign = text.align_left)
    table.cell(htfPanel, 1, 3, l2On ? (_l2b ? "↑ BULL" : "↓ BEAR") : "—",
         text_color = l2On ? (_l2b ? NS_BULL : NS_BEAR) : NS_SEC, bgcolor = NS_BG,
         text_size = size.small, text_halign = text.align_center)
    table.cell(htfPanel, 2, 3, _l2g,
         text_color = l2On ? (_l2p > 0.80 or _l2p < 0.20 ? NS_AMBER : NS_WHITE) : NS_SEC,
         bgcolor = NS_BG, text_size = size.tiny, text_halign = text.align_right)

    // L3 row
    bool   _l3b  = l3LC >= l3LO
    float  _l3r  = l3LH - l3LL
    float  _l3p  = l3On and _l3r > 0 ? math.max(0.0, math.min(1.0, (close - l3LL) / _l3r)) : 0.5
    int    _l3f  = math.round(_l3p * 7)
    string _l3g  = l3On ? str.repeat("█", _l3f) + str.repeat("░", 7 - _l3f) + "  " + str.tostring(math.round(_l3p * 100)) + "%" : "—"
    table.cell(htfPanel, 0, 4, l3On ? f_tfLbl(l3Tf) : "—",
         text_color = l3On ? NS_LBL : NS_SEC, bgcolor = NS_ROW,
         text_size = size.small, text_halign = text.align_left)
    table.cell(htfPanel, 1, 4, l3On ? (_l3b ? "↑ BULL" : "↓ BEAR") : "—",
         text_color = l3On ? (_l3b ? NS_BULL : NS_BEAR) : NS_SEC, bgcolor = NS_ROW,
         text_size = size.small, text_halign = text.align_center)
    table.cell(htfPanel, 2, 4, _l3g,
         text_color = l3On ? (_l3p > 0.80 or _l3p < 0.20 ? NS_AMBER : NS_WHITE) : NS_SEC,
         bgcolor = NS_ROW, text_size = size.tiny, text_halign = text.align_right)

    // Alignment row
    int    _aEn   = (l1On ? 1 : 0) + (l2On ? 1 : 0) + (l3On ? 1 : 0)
    int    _aBull = (l1On and l1LC >= l1LO ? 1 : 0) + (l2On and l2LC >= l2LO ? 1 : 0) + (l3On and l3LC >= l3LO ? 1 : 0)
    string _aStr  = _aEn == 0 ? "—" : _aBull == _aEn ? "↑↑ ALIGNED" : _aBull == 0 ? "↓↓ ALIGNED" : "⇅ MIXED"
    color  _aCol  = _aEn == 0 ? NS_SEC : _aBull == _aEn ? NS_BULL : _aBull == 0 ? NS_BEAR : NS_AMBER
    color  _aBg   = _aEn == 0 ? NS_BG  : _aBull == _aEn ? color.new(NS_BULL, 88) : _aBull == 0 ? color.new(NS_BEAR, 88) : color.new(NS_AMBER, 92)
    table.cell(htfPanel, 0, 5, "ALIGN",
         text_color = NS_LBL, bgcolor = _aBg,
         text_size = size.tiny, text_halign = text.align_left)
    table.cell(htfPanel, 1, 5, _aStr,
         text_color = _aCol, bgcolor = _aBg,
         text_size = size.small, text_halign = text.align_center)
    table.cell(htfPanel, 2, 5, "",
         bgcolor = _aBg)

    // Separator
    table.cell(htfPanel, 0, 6, "LAST SIGNAL",
         text_color = NS_LBL, bgcolor = NS_SEP,
         text_size = size.tiny, text_halign = text.align_left)
    table.cell(htfPanel, 1, 6, "",
         bgcolor = NS_SEP)
    table.cell(htfPanel, 2, 6, showSig ? "LIVE" : "OFF",
         text_color = showSig ? NS_BULL : NS_SEC, bgcolor = NS_SEP,
         text_size = size.tiny, text_halign = text.align_right)

    // Last signal
    color _lc = na(lastSigCol) ? NS_SEC : lastSigCol
    table.cell(htfPanel, 0, 7, lastSigTxt,
         text_color = _lc, bgcolor = NS_BG,
         text_size = size.small, text_halign = text.align_left)
    table.cell(htfPanel, 1, 7, "",
         bgcolor = NS_BG)
    table.cell(htfPanel, 2, 7, "",
         bgcolor = NS_BG)

// ─── ALERTS ──────────────────────────────────────────────────────────────────
float _aThr = atr14 * touchThresh
bool _a1H = l1On and barstate.isconfirmed and not na(l1LH) and math.abs(close - l1LH) <= _aThr
bool _a1L = l1On and barstate.isconfirmed and not na(l1LL) and math.abs(close - l1LL) <= _aThr
bool _a2H = l2On and barstate.isconfirmed and not na(l2LH) and math.abs(close - l2LH) <= _aThr
bool _a2L = l2On and barstate.isconfirmed and not na(l2LL) and math.abs(close - l2LL) <= _aThr
bool _a3H = l3On and barstate.isconfirmed and not na(l3LH) and math.abs(close - l3LH) <= _aThr
bool _a3L = l3On and barstate.isconfirmed and not na(l3LL) and math.abs(close - l3LL) <= _aThr

alertcondition(_a1H or _a1L, "HTF 1 H/L Touch",    "Price closed near HTF 1 High or Low")
alertcondition(_a2H or _a2L, "HTF 2 H/L Touch",    "Price closed near HTF 2 High or Low")
alertcondition(_a3H or _a3L, "HTF 3 H/L Touch",    "Price closed near HTF 3 High or Low")
alertcondition(_a1H or _a1L or _a2H or _a2L or _a3H or _a3L,
     "Any HTF H/L Touch", "Price closed near any active HTF High or Low")
````
