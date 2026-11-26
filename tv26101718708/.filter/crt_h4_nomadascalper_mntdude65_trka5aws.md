# CRT H4 NomadaScalper [Mntdude65]

- url: https://www.tradingview.com/script/trKa5awS-CRT-H4-NomadaScalper-Mntdude65/
- type: indicator
- pine_id: PUB;6cbb7d00b18041d789a8df346577b281
- version: 1.0

## Description

This  is CRT EDGE · H4 · NomadaScalper [Mntdude65]
Candle Range Theory (CRT) — timed H4 candles, multi-timeframe Turtle Soup, and a self-scoring probability dashboard, built on John Tracy's Time-Based Trading Blueprint.
OVERVIEW
This indicator builds the three timed 4-hour candles the CRT model keys on, maps out the previous candle's high/low across five timeframes (Monthly, Weekly, Daily, H4, H1) with automatic Turtle Soup detection, and scores every setup against the chart's own history — so instead of eyeballing whether "CRT usually works," you get a running, self-updating win-rate for every slot, every session.
Everything is clock-aggregated from the chart's own bars (not repainted from a higher-timeframe security() call), so it stays exact on symbols like CME futures where the native exchange H4 bars don't open at 1/5/9 — the script detects the real native H4 phase and snaps the slots to it automatically.
WHAT IT DRAWS
Timed H4 Candles
— Three 4-hour clock-window candles per day (auto-aligns to 1AM/5AM/9AM on forex-style symbols, 2AM/6AM/10AM on CME futures — matches the real H4 candles Tracy reads, not just a fixed clock guess).
— Full anatomy: range box, body box (bullish/bearish), CRT-High / CRT-Low / 50% lines projected forward with price labels.
— Dashed while forming live, frozen solid at the close.
— Configurable projection window, history depth, and manual override hours if you don't want native alignment.
HTF CRT Levels + Turtle Soup (Tracy multi-timeframe bias)
— Draws the previous completed candle's high/low for Monthly, Weekly, Daily, H4, and H1, each in its own color.
— A Turtle Soup latches when a confirmed candle wicks beyond one of these levels and closes back inside — once per side, per period.
— Bias engine: 3 or more timeframes souped at the lows = BULLISH bias · 3+ at the highs = BEARISH bias · both = CONFLICT (Tracy's rule: stand aside).
— Faded gray "ts·" tags mark these sweeps on the chart, color-coded so you can tell direction at a glance without reading the text: faded red = a high was swept, faded green = a low was swept. Toggle on/off independently.
CRT Box Sweep (★TS)
— A second, distinct sweep detector focused specifically on the CRT box itself (the timed H4 candle's own range), not the HTF levels.
— Marks every candle — not just the first — that wicks beyond the box's high or low and closes back inside, live while the sweeping candle is still forming and finalized the moment it confirms.
— Bold gold "★TS" tag with a user-selectable color, separate toggle from the HTF Turtle Soup marks above.
Session Ranges (Tracy step 3)
— Asia range (8PM–12AM NY) and P12 range (6PM–6AM NY), boxed with the high/low projected forward — a secondary confirmation check against the CRT bias.
CRT EDGE DASHBOARD
A self-computing panel, split into two clearly labeled sections:
LIVE — what has actually happened, right now, on this chart:
— CRT BOX: has this slot's box been swept yet? ▼ red = the box HIGH was swept (bearish) · ▲ green = the box LOW was swept (bullish) · — = neither side yet.
— STATUS: this cycle's live state — forming… / armed · waiting purge / ↓ purged (bearish, high swept) / ↑ purged (bullish, low swept), plus whether price has reached the 50% and/or the full opposite extreme.
HISTORICAL ODDS (all-time %) — a running backtest, not a live target:
— ↑→50% / ↑→HIGH: of all the times this slot's low was purged FIRST (bullish), what % of the time did price also reach the 50% / fully deliver to the CRT-High before the projection window expired.
— ↓→50% / ↓→LOW: the mirror image for a high-purge-first (bearish) scenario.
— Heat-colored by win rate, with a low-sample warning (amber) under 8 occurrences.
Plus a top-line VERDICT row (Tracy's 3+/5 bias rule), an HTF SOUP row showing which of the five timeframes are currently souped, and a footer crediting the underlying concept.
ALERTS
— Standard alertcondition() entries for every candle close and every purge (high/low, per slot) — usable from the classic "Create Alert" dropdown.
— Additional dynamic alert() calls fire alongside them with the actual resolved slot time baked into the message (e.g. the real "2AM" on CME futures rather than a hardcoded "1AM") — select "Any alert() function call" in the Create Alert dialog to receive these.
SETTINGS
— Light/Dark theme (Obsidian & Gold on dark backgrounds).
— Native H4 auto-align on/off, manual slot hours, projection window length, history depth.
— Independent show/hide for every layer: body box, 50% line, labels, each HTF level, HTF Turtle Soup marks, CRT box ★TS marks (with color picker), Asia/P12 sessions, and the dashboard itself (position + size).
HOW TO READ IT
Check the VERDICT row for the multi-timeframe bias.
Watch the LIVE columns (CRT BOX + STATUS) for what's actually unfolding on the current slot.
Use the HISTORICAL ODDS columns as context, not a signal — they tell you how this slot has behaved historically, conditional on a purge already happening.
Cross-check against Asia/P12 session ranges for Tracy's step-3 confirmation.
Best used on chart timeframes of 1m–30m (works up to 4h); a warning label appears if the chart timeframe is too high for the timed candles to resolve.
CREDITS
Concept: John Tracy — Time-Based Trading Blueprint (Candle Range Theory), johntracy.me.
This implementation, the CRT box sweep detection, per-TF sweep coloring, and the probability dashboard: Mntdude65.
This script is provided for educational and informational purposes. It does not constitute financial advice. Past performance (including the historical odds shown on the dashboard) does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("CRT · H4 · NomadaScalper [Mntdude65]", shorttitle="CRT 4H  v.Mntdude65", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500)
// ═══════════════════════════════════════════════════════════════════════
// CRT EDGE — Phase 1: TIMED H4 CANDLES  ·  Midnight Quant Society
// Candle Range Theory groundwork: the three timed 4-hour candles the model
// keys on (opens at 01:00, 05:00 and 09:00 New York), drawn with their full
// anatomy on any intraday chart.
//
//   · CLOCK-AGGREGATED, not security("240"): on CME futures (NQ/ES) the
//     exchange H4 bars open 18/22/02/06/10/14 ET — a native "1am/5am/9am H4
//     candle" does NOT exist there. Each timed candle is built bar-by-bar
//     from the chart's own data over its 4-hour clock window (NY time,
//     DST-safe), so it is exact on any symbol and any chart TF <= 4h.
//   · Anatomy per candle: RANGE box (high-low, direction-tinted border),
//     BODY box (open-close, solid green/red = candle type), CRT-High /
//     CRT-Low lines and the 50% mid, projected N hours right with price
//     chips, and an ID chip "CRT 1AM ▲ 25.5p" with full OHLC in the tooltip.
//   · Live formation: dashed borders while the window runs, updated every
//     bar; frozen solid at the window close.
//   · History: keep the last N candles per slot (registries + cap).
//   · PHASE 3b — NATIVE H4 ALIGNMENT: the three slots now snap to the
//     symbol's REAL 4-hour candles (native H4 phase detected via security),
//     nearest 1/5/9 NY — forex keeps 1AM/5AM/9AM, CME futures become
//     2AM/6AM/10AM, matching Tracy's actual H4 reads. Manual clock hours
//     remain as an option. Slot names are dynamic everywhere.
//   · PHASE 3 — JOHN TRACY LAYER: multi-timeframe CRT levels
//     (previous M/W/D/H4/H1 candle H/L, Tracy color-coded: Monthly orange ·
//     Weekly purple · Daily black/white · 4H red · 1H blue), per-TF Turtle
//     Soup latching (wick beyond + confirmed close back inside, once per
//     side per period), the bias engine (3+ TFs souped at lows -> BULLISH ·
//     at highs -> BEARISH · both -> CONFLICT, no trade), Asia (20-00 NY) and
//     P12 (18-06 NY) session ranges, VERDICT + per-TF soup rows in the
//     dashboard, and bias-flip alerts. Concept credit: John Tracy,
//     "Time-Based Trading Blueprint (Candle Range Theory)" — johntracy.me.
//   · PHASE 2: per-slot stats engine. After each candle closes,
//     the FIRST purge of CRT-High/Low is detected inside the projection
//     window; conditional on the purge side, the engine counts delivery to
//     the 50% and to the OPPOSITE extreme before the window expires. Purge
//     markers on chart, 6 purge alerts, and a dashboard with one row per
//     hour: STATUS live + the four conditional probabilities with heat and
//     low-sample lamps. Close-back-inside validation comes in phase 3.
//   · PINE v6 PORT: directive bumped to v6. The engine was already v6-clean —
//     every boolean condition is guarded to resolve false (never na), so the
//     v6 short-circuit `and`/`or` and the bool-na->false rule change nothing;
//     request.security calls use simple/const args (dynamic-request default is
//     a no-op here). No logic was altered in the lift.
// ═══════════════════════════════════════════════════════════════════════

// ─── THEME + PALETTE (Light = white charts · Dark = Obsidian & Gold) ─────
theme = input.string("Light", "Chart theme", options=["Light", "Dark"], group="✦ Theme", tooltip="Light: dark text and darkened accents for WHITE chart backgrounds. Dark: the Obsidian & Gold set for BLACK backgrounds.")
bool TDK = theme == "Dark"
color C_BG    = TDK ? #05070C : #F4F6F9
color C_PANEL = TDK ? #0A0E17 : #E9EDF3
color C_RAISE = TDK ? #131A28 : #DCE2EB
color C_TXT   = TDK ? #F1F5F9 : #10151F
color C_MUTE  = TDK ? #64748B : #5A6472
color C_GOLD  = TDK ? #C9A85A : #9A7B32
color C_GREEN = TDK ? #5DAE83 : #2E7D55
color C_RED   = TDK ? #CE6A62 : #B04E48
color C_AMBER = TDK ? #E8A13D : #A8761C
color C_STEEL = TDK ? #9BA5B1 : #6B7684
color C_PURP  = TDK ? #B08CE0 : #6B4FA3   // Tracy: Weekly lines
color C_BLUE  = TDK ? #5B8DD9 : #2F5FA8   // Tracy: 1-Hour lines
color C_INK   = #05070C                   // fixed dark ink over solid accent chips

// ─── INPUTS ──────────────────────────────────────────────────────────────
g_c = "Timed H4 candles (New York time)"
show1 = input.bool(true, "Slot A (≈1AM)", group=g_c, inline="S")
show5 = input.bool(true, "B (≈5AM)", group=g_c, inline="S")
show9 = input.bool(true, "C (≈9AM)", group=g_c, inline="S", tooltip="The three timed 4-hour candles of the CRT model. With native-H4 auto-align ON they snap to the symbol's real H4 candles nearest 1/5/9 NY (forex: exactly 1AM/5AM/9AM · CME futures: 2AM/6AM/10AM). Built by clock aggregation from the chart's own bars — exact on futures too, where native exchange H4 bars do NOT open at these times. Use a chart timeframe of 4h or lower (1m-30m recommended).")
anchorH4 = input.bool(true, "Auto-align to the symbol's NATIVE H4 candles", group=g_c, tooltip="ON (default): the three slots snap to the symbol's REAL 4-hour candles nearest 1/5/9 NY, detected from the native H4 open phase. Forex (day starts 17:00 ET): native H4 opens 1/5/9/13/17/21 NY -> slots stay 1AM/5AM/9AM. CME index futures (day starts 18:00 ET): native opens 2/6/10/14/18/22 -> slots become 2AM/6AM/10AM — the actual H4 candles Tracy reads. OFF: the manual hours below are used as pure clock windows (community 1/5/9 convention).")
manH1 = input.int(1, "Manual slot hours (NY)", minval=0, maxval=23, group=g_c, inline="MH")
manH2 = input.int(5, "", minval=0, maxval=23, group=g_c, inline="MH")
manH3 = input.int(9, "", minval=0, maxval=23, group=g_c, inline="MH", tooltip="Used only when auto-align is OFF. Open hour (NY) of each 4h slot.")
projHours = input.float(8.0, "Project H/L/50% lines (hours)", minval=1.0, maxval=48.0, step=1.0, group=g_c, tooltip="How far past the candle close its CRT-High, CRT-Low and 50% lines extend. 8h (default) covers the next two H4 candles — where the purge and delivery of the model play out.")
keepN = input.int(5, "Keep last N candles per slot", minval=1, maxval=30, group=g_c, tooltip="History depth: how many past candles of EACH slot (1AM / 5AM / 9AM) stay drawn. Older ones are deleted automatically.")
g_v = "Visual"
showBody   = input.bool(true, "Body box (candle type)", group=g_v, tooltip="Solid open-close box inside the range: green = bullish H4 candle, red = bearish. This is the 'candle type' at a glance.")
show50     = input.bool(true, "50% mid line", group=g_v)
showLabels = input.bool(true, "Labels & price chips", group=g_v)
g_h = "HTF CRT levels · Turtle Soup bias (John Tracy)"
showM  = input.bool(true, "Monthly", group=g_h, inline="H1")
showW  = input.bool(true, "Weekly",  group=g_h, inline="H1")
showD  = input.bool(true, "Daily",   group=g_h, inline="H1")
showH4 = input.bool(true, "4H",      group=g_h, inline="H2")
showH1 = input.bool(true, "1H",      group=g_h, inline="H2", tooltip="Previous completed candle's CRT-High/Low per timeframe, color-coded Tracy-style (Monthly orange · Weekly purple · Daily black/white per theme · 4H red · 1H blue) so on a 1m-15m chart you instantly see WHICH timeframe is being souped. A Turtle Soup latches when a confirmed chart candle WICKS beyond a level and CLOSES back inside — once per side per period. Bias: 3+ timeframes souped at the LOWS -> bullish · at the HIGHS -> bearish · both -> conflict, no trade (Tracy's rule). Best on chart TFs of 1h or lower.")
showTsMk = input.bool(true, "ts marks on chart (faded gray, per-TF sweep)", group=g_h)
showBoxTS = input.bool(true, "★TS box-sweep labels (bold)", group=g_h, inline="BTS", tooltip="Marks EVERY candle that wicks beyond the CRT box on either side and CLOSES back inside — a Turtle Soup of the CRT box itself, distinct from the per-TF ts marks below. Live while the sweeping candle is still forming; each qualifying candle gets its own label.")
boxTSColor = input.color(#C9A85A, "", group=g_h, inline="BTS")
g_a = "Session ranges (Tracy step 3)"
showAsia = input.bool(true, "Asia range (20:00-00:00 NY)", group=g_a)
showP12  = input.bool(true, "P12 range (18:00-06:00 NY)",  group=g_a, tooltip="Tracy's two session confirmations: Asia = 8PM-12AM EST high/low · P12 = first 12 hours of the futures day (6PM-6AM EST). Boxes with the H/L projected forward — check whether they align with the CRT bias.")
g_p = "Dashboard"
showDash = input.bool(true, "Show probability dashboard", group=g_p)
dashPos  = input.string("top_right", "Position", options=["top_left","top_center","top_right","middle_left","middle_right","bottom_left","bottom_center","bottom_right"], group=g_p)
dashSize = input.string("Normal", "Size", options=["Small","Normal","Large"], group=g_p)
szHead = dashSize == "Small" ? size.small : dashSize == "Large" ? size.normal : size.small
szCell = dashSize == "Small" ? size.tiny  : dashSize == "Large" ? size.normal : size.small
szFoot = dashSize == "Small" ? size.tiny  : dashSize == "Large" ? size.small  : size.tiny

f_pos(simple string p) =>
    switch p
        "top_left"      => position.top_left
        "top_center"    => position.top_center
        "top_right"     => position.top_right
        "middle_left"   => position.middle_left
        "middle_right"  => position.middle_right
        "bottom_left"   => position.bottom_left
        "bottom_center" => position.bottom_center
        => position.top_right

string TZ = "America/New_York"
int curMin = hour(time, TZ) * 60 + minute(time, TZ)
int projBars = math.max(1, math.round(projHours * 3600.0 / timeframe.in_seconds(timeframe.period)))

// ─── NATIVE H4 PHASE — snap the slots to the symbol's real 4h candles ────
// The NY open-hour of the native H4 bar gives the phase (hour % 4). Each
// requested hour k (1/5/9) snaps to the nearest native open: forex phase 1 ->
// 1/5/9 unchanged · CME futures phase 2 -> 2/6/10 (the true H4 candles).
int h4hRaw = request.security(syminfo.tickerid, "240", hour(time, TZ), lookahead=barmerge.lookahead_off)
var int h4Phase = na
if na(h4Phase) and not na(h4hRaw)
    h4Phase := h4hRaw % 4
f_snap(simple int k) =>
    int r = na
    if not na(h4Phase)
        r := int((h4Phase + 4 * math.round((k - h4Phase) / 4.0) + 24) % 24)
    r
f_hName(int hh) =>
    na(hh) ? "…" : hh == 0 ? "12AM" : hh < 12 ? str.tostring(hh) + "AM" : hh == 12 ? "12PM" : str.tostring(hh - 12) + "PM"
int slotH1 = anchorH4 ? f_snap(1) : manH1
int slotH2 = anchorH4 ? f_snap(5) : manH2
int slotH3 = anchorH4 ? f_snap(9) : manH3
string slotN1 = f_hName(slotH1)
string slotN2 = f_hName(slotH2)
string slotN3 = f_hName(slotH3)

// ─── TIMED-CANDLE ENGINE (one instance per call site: 1AM / 5AM / 9AM) ───
// Builds the 4h clock window [stH:00, stH+4:00) NY, aggregates OHLC from the
// chart's bars, draws live (dashed) and freezes at the close (solid + grid).
f_crt(int stH, simple bool show, string tag) =>
    int stM = stH * 60
    bool inW = not na(stH) and curMin >= stM and curMin < stM + 240
    // per-instance state
    var float o = na
    var float h = na
    var float l = na
    var float c = na
    var int   x1 = na
    var int   xLast = na
    var box   rngBx = na
    var box   bodyBx = na
    var label tagLb = na
    // per-instance CRT stats engine (phase 2): monitoring + counters
    var bool  mon = false
    var int   monEnd = na
    var int   pDir = 0          // first purge: +1 broke CRT-High · -1 broke CRT-Low
    var bool  hitMid = false
    var bool  hitOpp = false
    var float mH = na
    var float mL = na
    var float mM = na
    var int dnTot = 0
    var int dnMid = 0
    var int dnFull = 0
    var int upTot = 0
    var int upMid = 0
    var int upFull = 0
    // per-instance history registries (frozen objects, capped by keepN)
    var array<box>   g_box = array.new<box>()
    var array<line>  g_lin = array.new<line>()
    var array<label> g_lab = array.new<label>()
    var array<label> g_mrk = array.new<label>()   // purge markers — own registry (count-safe)
    var label liveTsLb = na        // live/provisional ★TS label while the sweeping candle still forms
    var array<label> g_boxts = array.new<label>()  // confirmed ★TS box labels — own registry (count-safe)
    bool closedNow = false
    bool evDn = false
    bool evUp = false
    if show
        if inW and not inW[1]
            // enforce history cap BEFORE a new candle starts building
            // trim by ACTUAL per-candle object counts so "last N" stays literal
            // regardless of the showBody / show50 toggles
            int boxPerC = 1 + (showBody ? 1 : 0)          // rngBx (+ bodyBx)
            int linPerC = 2 + (show50 ? 1 : 0)            // H + L (+ 50%)
            int labPerC = 3 + (show50 ? 1 : 0)            // tag + H + L (+ 50%)
            while array.size(g_box) > keepN * boxPerC
                box.delete(array.shift(g_box))
            while array.size(g_lin) > keepN * linPerC
                line.delete(array.shift(g_lin))
            while array.size(g_lab) > keepN * labPerC
                label.delete(array.shift(g_lab))
            while array.size(g_mrk) > keepN
                label.delete(array.shift(g_mrk))
            o := open
            h := high
            l := low
            c := close
            x1 := bar_index
            xLast := bar_index
            // this box hasn't closed yet, so it cannot have been swept — clear the
            // PREVIOUS cycle's result now instead of leaving it stale through forming
            pDir := 0
            rngBx := box.new(x1, h, x1, l, border_color=color.new(close >= o ? C_GREEN : C_RED, 35), border_width=1, border_style=line.style_dashed, bgcolor=color.new(C_STEEL, 90))
            bodyBx := showBody ? box.new(x1, math.max(o, close), x1, math.min(o, close), border_color=na, bgcolor=color.new(close >= o ? C_GREEN : C_RED, 60)) : na
            if showLabels
                tagLb := label.new(x1, h, " CRT " + tag + " · forming ", style=label.style_label_down, color=color.new(C_RAISE, 0), textcolor=C_TXT, size=size.small, text_font_family=font.family_monospace)
        else if inW and not na(x1)
            h := math.max(h, high)
            l := math.min(l, low)
            c := close
            xLast := bar_index
            bool liveBull = c >= o
            box.set_top(rngBx, h)
            box.set_bottom(rngBx, l)
            box.set_right(rngBx, bar_index)
            box.set_border_color(rngBx, color.new(liveBull ? C_GREEN : C_RED, 35))
            if not na(bodyBx)
                box.set_lefttop(bodyBx, x1, math.max(o, c))
                box.set_rightbottom(bodyBx, bar_index, math.min(o, c))
                box.set_bgcolor(bodyBx, color.new(liveBull ? C_GREEN : C_RED, 60))
            if not na(tagLb)
                label.set_xy(tagLb, x1, h)
        if not inW and inW[1] and not na(x1) and not na(o)
            // WINDOW CLOSE — freeze anatomy, draw the projected CRT grid
            closedNow := true
            bool bull = c >= o
            color dirC = bull ? C_GREEN : C_RED
            int rpx = xLast + projBars
            box.set_border_style(rngBx, line.style_solid)
            box.set_right(rngBx, xLast)
            if not na(bodyBx)
                box.set_right(bodyBx, xLast)
            array.push(g_box, rngBx)
            if not na(bodyBx)
                array.push(g_box, bodyBx)
            array.push(g_lin, line.new(xLast, h, rpx, h, color=color.new(C_STEEL, 0), width=2, style=line.style_solid))
            array.push(g_lin, line.new(xLast, l, rpx, l, color=color.new(C_STEEL, 0), width=2, style=line.style_solid))
            if show50
                array.push(g_lin, line.new(xLast, (h + l) / 2, rpx, (h + l) / 2, color=color.new(C_GOLD, 0), width=1, style=line.style_dashed))
            if showLabels
                string ohlcTip = "CRT " + tag + " (H4 · New York clock window)\nO  " + str.tostring(o, format.mintick) + "\nH  " + str.tostring(h, format.mintick) + "\nL  " + str.tostring(l, format.mintick) + "\nC  " + str.tostring(c, format.mintick) + "\nRange  " + str.tostring(h - l, format.mintick) + "p · Body " + str.tostring(math.abs(c - o), format.mintick) + "p\nType  " + (bull ? "BULLISH ▲" : "BEARISH ▼") + (math.abs(c - o) < (h - l) * 0.3 ? " · small body (indecision)" : "")
                label.set_text(tagLb, " CRT " + tag + " " + (bull ? "▲" : "▼") + " " + str.tostring(h - l, format.mintick) + "p ")
                label.set_color(tagLb, color.new(dirC, 10))
                label.set_textcolor(tagLb, C_INK)
                label.set_tooltip(tagLb, ohlcTip)
                array.push(g_lab, tagLb)
                array.push(g_lab, label.new(rpx, h, " " + tag + "-H " + str.tostring(h, format.mintick) + " ", style=label.style_label_left, color=color.new(C_RAISE, 0), textcolor=C_TXT, size=size.small, text_font_family=font.family_monospace, tooltip="CRT-High of the " + tag + " candle — buy-side liquidity rests above this level."))
                array.push(g_lab, label.new(rpx, l, " " + tag + "-L " + str.tostring(l, format.mintick) + " ", style=label.style_label_left, color=color.new(C_RAISE, 0), textcolor=C_TXT, size=size.small, text_font_family=font.family_monospace, tooltip="CRT-Low of the " + tag + " candle — sell-side liquidity rests below this level."))
                if show50
                    array.push(g_lab, label.new(rpx, (h + l) / 2, " 50% " + str.tostring((h + l) / 2, format.mintick) + " ", style=label.style_label_left, color=color.new(C_RAISE, 0), textcolor=C_GOLD, size=size.small, text_font_family=font.family_monospace, tooltip="Midpoint of the " + tag + " candle — the model's first delivery target (TP1) after a purge."))
            rngBx := na
            bodyBx := na
            tagLb := na
            // arm the stats monitor over the same projected window as the grid
            mon := true
            monEnd := xLast + projBars
            pDir := 0
            hitMid := false
            hitOpp := false
            mH := h
            mL := l
            mM := (h + l) / 2
            if not na(liveTsLb)
                label.delete(liveTsLb)
                liveTsLb := na
        // ── MONITOR (phase 2): first purge + conditional delivery to 50% / opposite ──
        // Deadline = the drawn projection window. Same-bar high/low touch order is
        // unknown intrabar: purge side on a double-touch bar is taken from the
        // close vs the 50%; a purge bar can also score its targets on that same
        // bar (documented heuristic, rare on low TFs).
        // Confirmed bars only: the first-purge marker and its alert can no
        // longer repaint on an intrabar wick, and scoring never runs on the
        // purge bar itself (justPurged defers 50%/opposite to later bars).
        if mon and barstate.isconfirmed
            if bar_index > monEnd
                mon := false
            else
                bool justPurged = false
                if pDir == 0
                    bool bkUp = high >= mH
                    bool bkDn = low <= mL
                    if bkUp or bkDn
                        pDir := bkUp and bkDn ? (close >= mM ? 1 : -1) : bkUp ? 1 : -1
                        justPurged := true
                        if pDir == 1
                            upTot += 1
                            evUp := true
                        else
                            dnTot += 1
                            evDn := true
                        if showLabels
                            array.push(g_mrk, label.new(bar_index, pDir == 1 ? high : low, pDir == 1 ? "▼" : "▲", style=pDir == 1 ? label.style_label_down : label.style_label_up, color=color.new(pDir == 1 ? C_RED : C_GREEN, 10), textcolor=C_INK, size=size.small, text_font_family=font.family_monospace, tooltip="CRT " + tag + " · first purge of the " + (pDir == 1 ? "HIGH (bearish expectation: delivery toward the 50% and the CRT-Low)" : "LOW (bullish expectation: delivery toward the 50% and the CRT-High)") + "."))
                            while array.size(g_mrk) > keepN
                                label.delete(array.shift(g_mrk))
                if not justPurged
                    if pDir == -1
                        if not hitOpp and high >= mH
                            hitOpp := true
                            dnFull += 1
                            if not hitMid
                                hitMid := true
                                dnMid += 1
                            mon := false
                        else if not hitMid and high >= mM
                            hitMid := true
                            dnMid += 1
                    else if pDir == 1
                        if not hitOpp and low <= mL
                            hitOpp := true
                            upFull += 1
                            if not hitMid
                                hitMid := true
                                upMid += 1
                            mon := false
                        else if not hitMid and low <= mM
                            hitMid := true
                            upMid += 1
        // ── ★TS box sweep: wick beyond the box + close back inside ──────
        // Runs every tick (not just on confirmed bars) so a candle currently
        // trading back inside the box after sweeping it shows the label live;
        // EVERY qualifying candle gets its own permanent label once it confirms
        // (no once-per-box limit) — the live preview just tracks one bar at a time.
        if showBoxTS and mon and bar_index <= monEnd
            bool sweptHi = high > mH
            bool sweptLo = low < mL
            bool backIn  = close <= mH and close >= mL
            bool tsHit   = (sweptHi or sweptLo) and backIn
            if tsHit
                float ly = sweptHi ? high : low
                if na(liveTsLb)
                    liveTsLb := label.new(bar_index, ly, " ★TS ", style=sweptHi ? label.style_label_down : label.style_label_up, color=color.new(boxTSColor, 10), textcolor=C_INK, size=size.normal, text_font_family=font.family_monospace, tooltip="CRT " + tag + " box: price swept the " + (sweptHi ? "HIGH" : "LOW") + " and closed back inside the box — Turtle Soup of the CRT box.")
                else
                    label.set_xy(liveTsLb, bar_index, ly)
                    label.set_style(liveTsLb, sweptHi ? label.style_label_down : label.style_label_up)
                if barstate.isconfirmed
                    array.push(g_boxts, liveTsLb)
                    liveTsLb := na
                    while array.size(g_boxts) > keepN
                        label.delete(array.shift(g_boxts))
            else if not na(liveTsLb)
                label.delete(liveTsLb)
                liveTsLb := na
    int stCode = mon and pDir == -1 ? 3 : mon and pDir == 1 ? 4 : mon ? 2 : inW ? 1 : 0
    [closedNow, evDn, evUp, dnTot, dnMid, dnFull, upTot, upMid, upFull, stCode, hitMid, hitOpp, pDir]

// ─── RUN THE THREE SLOTS ─────────────────────────────────────────────────
[c1, e1d, e1u, d1t, d1m, d1f, u1t, u1m, u1f, st1, hm1, ho1, pd1] = f_crt(slotH1, show1, slotN1)
[c5, e5d, e5u, d5t, d5m, d5f, u5t, u5m, u5f, st5, hm5, ho5, pd5] = f_crt(slotH2, show5, slotN2)
[c9, e9d, e9u, d9t, d9m, d9f, u9t, u9m, u9f, st9, hm9, ho9, pd9] = f_crt(slotH3, show9, slotN3)

// ═══════════════════════════════════════════════════════════════════════
// HTF CRT LEVELS + PER-TF TURTLE SOUP (Tracy multi-timeframe bias routine)
// Previous completed candle's H/L per TF, drawn as right-extended lines in
// Tracy's per-TF colors. A Turtle Soup latches (once per side per period)
// when a CONFIRMED chart candle wicks beyond the level and closes back
// inside. Returns the two latches for the bias engine.
// ═══════════════════════════════════════════════════════════════════════
f_htf(simple string tf, simple bool showTf, simple string tag, color col) =>
    [ph, pl] = request.security(syminfo.tickerid, tf, [high[1], low[1]], lookahead=barmerge.lookahead_off)
    bool newP = timeframe.change(tf)
    var int  pStart = na
    var line lnH = na
    var line lnL = na
    var label lbH = na
    var label lbL = na
    var bool tsH = false
    var bool tsL = false
    var array<label> g_ts = array.new<label>()
    if newP
        pStart := bar_index
        tsH := false
        tsL := false
    if showTf and not na(ph) and not na(pl) and not na(pStart)
        if na(lnH)
            lnH := line.new(pStart, ph, pStart + 1, ph, color=col, width=2, extend=extend.right)
            lnL := line.new(pStart, pl, pStart + 1, pl, color=col, width=2, extend=extend.right)
        else
            line.set_xy1(lnH, pStart, ph)
            line.set_xy2(lnH, pStart + 1, ph)
            line.set_xy1(lnL, pStart, pl)
            line.set_xy2(lnL, pStart + 1, pl)
        if showLabels and barstate.islast
            if na(lbH)
                lbH := label.new(bar_index + 3, ph, "", style=label.style_label_left, color=color.new(C_RAISE, 0), textcolor=col, size=size.small, text_font_family=font.family_monospace)
                lbL := label.new(bar_index + 3, pl, "", style=label.style_label_left, color=color.new(C_RAISE, 0), textcolor=col, size=size.small, text_font_family=font.family_monospace)
            label.set_xy(lbH, bar_index + 3, ph)
            label.set_text(lbH, " " + tag + " CRT-H " + str.tostring(ph, format.mintick) + (tsH ? " · TS ✓" : "") + " ")
            label.set_tooltip(lbH, tag + " previous candle HIGH. Buy-side liquidity above; a wick beyond it that CLOSES back under = Turtle Soup at the highs (bearish evidence).")
            label.set_xy(lbL, bar_index + 3, pl)
            label.set_text(lbL, " " + tag + " CRT-L " + str.tostring(pl, format.mintick) + (tsL ? " · TS ✓" : "") + " ")
            label.set_tooltip(lbL, tag + " previous candle LOW. Sell-side liquidity below; a wick beyond it that CLOSES back above = Turtle Soup at the lows (bullish evidence).")
        // Turtle Soup latches — confirmed chart candles only, once per side per period
        if barstate.isconfirmed
            if not tsH and high > ph and close < ph
                tsH := true
                if showTsMk
                    array.push(g_ts, label.new(bar_index, high, " ts·" + tag + " ", style=label.style_label_down, color=color.new(C_RED, 75), textcolor=C_RED, size=size.small, text_font_family=font.family_monospace, tooltip="Turtle Soup of the " + tag + " CRT-High: wick beyond, close back inside. Bearish evidence in the multi-TF bias."))
                    while array.size(g_ts) > 20
                        label.delete(array.shift(g_ts))
            if not tsL and low < pl and close > pl
                tsL := true
                if showTsMk
                    array.push(g_ts, label.new(bar_index, low, " ts·" + tag + " ", style=label.style_label_up, color=color.new(C_GREEN, 75), textcolor=C_GREEN, size=size.small, text_font_family=font.family_monospace, tooltip="Turtle Soup of the " + tag + " CRT-Low: wick beyond, close back inside. Bullish evidence in the multi-TF bias."))
                    while array.size(g_ts) > 20
                        label.delete(array.shift(g_ts))
    [tsH, tsL]

[tsHm, tsLm]   = f_htf("M",   showM,  "M",  C_AMBER)
[tsHw, tsLw]   = f_htf("W",   showW,  "W",  C_PURP)
[tsHd, tsLd]   = f_htf("D",   showD,  "D",  C_TXT)
[tsH4, tsL4]   = f_htf("240", showH4, "H4", C_RED)
[tsH1, tsL1]   = f_htf("60",  showH1, "H1", C_BLUE)
int soupLo = (tsLm ? 1 : 0) + (tsLw ? 1 : 0) + (tsLd ? 1 : 0) + (tsL4 ? 1 : 0) + (tsL1 ? 1 : 0)
int soupHi = (tsHm ? 1 : 0) + (tsHw ? 1 : 0) + (tsHd ? 1 : 0) + (tsH4 ? 1 : 0) + (tsH1 ? 1 : 0)
bool biasBull = soupLo >= 3 and soupHi < 3
bool biasBear = soupHi >= 3 and soupLo < 3
alertcondition(biasBull and not biasBull[1], "CRT · Bias turned BULLISH", "CRT Edge: 3+ timeframes souped at the LOWS — bullish bias (Tracy rule).")
alertcondition(biasBear and not biasBear[1], "CRT · Bias turned BEARISH", "CRT Edge: 3+ timeframes souped at the HIGHS — bearish bias (Tracy rule).")

// ═══════════════════════════════════════════════════════════════════════
// SESSION RANGES (Tracy step 3): Asia 20:00-00:00 NY · P12 18:00-06:00 NY
// Clock-window boxes with the H/L projected forward.
// ═══════════════════════════════════════════════════════════════════════
f_sess(simple int stM, simple int enM, simple bool showS, simple string tag, color col) =>
    bool inS = stM <= enM ? (curMin >= stM and curMin < enM) : (curMin >= stM or curMin < enM)
    var float sh = na
    var float sl = na
    var int   sx = na
    var int   sLast = na
    var box   bx = na
    var label lb = na
    var array<box>   g_b = array.new<box>()
    var array<line>  g_l = array.new<line>()
    var array<label> g_lb2 = array.new<label>()
    if showS
        if inS and not inS[1]
            while array.size(g_b) > keepN
                box.delete(array.shift(g_b))
            while array.size(g_l) > keepN * 2
                line.delete(array.shift(g_l))
            while array.size(g_lb2) > keepN
                label.delete(array.shift(g_lb2))
            sh := high
            sl := low
            sx := bar_index
            sLast := bar_index
            bx := box.new(sx, sh, sx, sl, border_color=color.new(col, 40), border_width=1, border_style=line.style_dashed, bgcolor=color.new(col, 92))
            if showLabels
                lb := label.new(sx, sh, " " + tag + " ", style=label.style_label_down, color=color.new(col, 20), textcolor=C_INK, size=size.tiny, text_font_family=font.family_monospace)
        else if inS and not na(sx)
            sh := math.max(sh, high)
            sl := math.min(sl, low)
            sLast := bar_index
            box.set_top(bx, sh)
            box.set_bottom(bx, sl)
            box.set_right(bx, bar_index)
            if not na(lb)
                label.set_xy(lb, sx, sh)
        if not inS and inS[1] and not na(sx)
            box.set_border_style(bx, line.style_solid)
            box.set_right(bx, sLast)
            array.push(g_b, bx)
            int rpx2 = sLast + projBars
            array.push(g_l, line.new(sLast, sh, rpx2, sh, color=color.new(col, 30), width=1, style=line.style_dotted))
            array.push(g_l, line.new(sLast, sl, rpx2, sl, color=color.new(col, 30), width=1, style=line.style_dotted))
            if showLabels and not na(lb)
                label.set_text(lb, " " + tag + " " + str.tostring(sh - sl, format.mintick) + "p ")
                label.set_tooltip(lb, tag + " range\nH " + str.tostring(sh, format.mintick) + "\nL " + str.tostring(sl, format.mintick) + "\nDoes it align with the CRT bias? (Tracy step 3)")
                array.push(g_lb2, lb)
            bx := na
            lb := na
    true

f_sess(1200, 1440, showAsia, "ASIA", C_PURP)
f_sess(1080, 360,  showP12,  "P12",  C_STEEL)

// ─── TIMEFRAME GUARD ─────────────────────────────────────────────────────
var label tfWarn = na
if barstate.islast and timeframe.in_seconds(timeframe.period) > 14400
    if na(tfWarn)
        tfWarn := label.new(bar_index, high, " ⚠ CRT Edge needs a chart TF of 4h or lower ", style=label.style_label_down, color=color.new(C_AMBER, 0), textcolor=C_INK, size=size.normal, text_font_family=font.family_monospace, tooltip="The timed H4 candles are aggregated from the chart's own bars over 4-hour clock windows. On timeframes above 4h a window cannot be resolved. Switch to 1m-30m (recommended) or 1h-4h.")
    else
        label.set_xy(tfWarn, bar_index, high)
else if not na(tfWarn)
    label.delete(tfWarn)
    tfWarn := na

// ─── ALERTS (phase 1: candle closes — phase 2 adds purge/validation) ─────
alertcondition(c1, "CRT · 1AM candle closed", "CRT Edge: the 1AM H4 candle closed — CRT range set.")
alertcondition(c5, "CRT · 5AM candle closed", "CRT Edge: the 5AM H4 candle closed — CRT range set.")
alertcondition(c9, "CRT · 9AM candle closed", "CRT Edge: the 9AM H4 candle closed — CRT range set.")
alertcondition(e1d, "CRT · 1AM purge LOW",  "CRT Edge 1AM: CRT-Low purged — bullish delivery expected toward 50% / CRT-High.")
alertcondition(e1u, "CRT · 1AM purge HIGH", "CRT Edge 1AM: CRT-High purged — bearish delivery expected toward 50% / CRT-Low.")
alertcondition(e5d, "CRT · 5AM purge LOW",  "CRT Edge 5AM: CRT-Low purged — bullish delivery expected toward 50% / CRT-High.")
alertcondition(e5u, "CRT · 5AM purge HIGH", "CRT Edge 5AM: CRT-High purged — bearish delivery expected toward 50% / CRT-Low.")
alertcondition(e9d, "CRT · 9AM purge LOW",  "CRT Edge 9AM: CRT-Low purged — bullish delivery expected toward 50% / CRT-High.")
alertcondition(e9u, "CRT · 9AM purge HIGH", "CRT Edge 9AM: CRT-High purged — bearish delivery expected toward 50% / CRT-Low.")

// ─── DYNAMIC ALERTS — normalized to the actual resolved slot time ────────
// alertcondition() text above must be a compile-time constant, so it can't
// reflect the REAL resolved hour (1AM vs 2AM, 5AM vs 6AM, 9AM vs 10AM — see
// NATIVE H4 PHASE above). These alert() calls fire the same events with the
// live slot name baked in. In the Create Alert dialog, choose "Any alert()
// function call" on this indicator to receive the actual-time-accurate text.
if c1
    alert("CRT Edge: the " + slotN1 + " H4 candle closed — CRT range set.", alert.freq_once_per_bar)
if c5
    alert("CRT Edge: the " + slotN2 + " H4 candle closed — CRT range set.", alert.freq_once_per_bar)
if c9
    alert("CRT Edge: the " + slotN3 + " H4 candle closed — CRT range set.", alert.freq_once_per_bar)
if e1d
    alert("CRT Edge " + slotN1 + ": CRT-Low purged — bullish delivery expected toward 50% / CRT-High.", alert.freq_once_per_bar)
if e1u
    alert("CRT Edge " + slotN1 + ": CRT-High purged — bearish delivery expected toward 50% / CRT-Low.", alert.freq_once_per_bar)
if e5d
    alert("CRT Edge " + slotN2 + ": CRT-Low purged — bullish delivery expected toward 50% / CRT-High.", alert.freq_once_per_bar)
if e5u
    alert("CRT Edge " + slotN2 + ": CRT-High purged — bearish delivery expected toward 50% / CRT-Low.", alert.freq_once_per_bar)
if e9d
    alert("CRT Edge " + slotN3 + ": CRT-Low purged — bullish delivery expected toward 50% / CRT-High.", alert.freq_once_per_bar)
if e9u
    alert("CRT Edge " + slotN3 + ": CRT-High purged — bearish delivery expected toward 50% / CRT-Low.", alert.freq_once_per_bar)

// ═══════════════════════════════════════════════════════════════════════
// DASHBOARD — per-slot conditional probabilities (self-computed, full chart
// history): given the FIRST purge side, how often price delivered to the 50%
// and to the OPPOSITE extreme before the projection window expired.
// ═══════════════════════════════════════════════════════════════════════
f_pct(int hh, int tt) => tt > 0 ? hh * 100.0 / tt : na
f_cell(int hh, int tt) =>
    float p = f_pct(hh, tt)
    na(p) ? "—" : str.tostring(p, "0") + "%  " + str.tostring(hh) + "/" + str.tostring(tt)
f_heat(int hh, int tt) =>
    float p = f_pct(hh, tt)
    na(p) ? color.new(C_PANEL, 0) : tt < 8 ? color.new(C_AMBER, 55) : color.new(p >= 50 ? C_GREEN : C_RED, p >= 70 or p < 30 ? 45 : 65)
f_tsCell(bool th, bool tl) => th and tl ? "▲▼" : tl ? "▲" : th ? "▼" : "—"
f_tsCol(bool th, bool tl) => th and tl ? C_AMBER : tl ? C_GREEN : th ? C_RED : C_MUTE
f_boxCell(int pd) => pd == 1 ? "▼ SWEPT" : pd == -1 ? "▲ SWEPT" : "—"
f_boxCol(int pd)  => pd == 1 ? C_RED : pd == -1 ? C_GREEN : C_MUTE
f_status(int sc, bool hm, bool ho) =>
    sc == 1 ? "forming…" : sc == 2 ? "armed · waiting purge" : sc == 3 ? "↑ purged" + (ho ? " · FULL ✓" : hm ? " · 50% ✓" : " → 50%?") : sc == 4 ? "↓ purged" + (ho ? " · FULL ✓" : hm ? " · 50% ✓" : " → 50%?") : "—"
f_statusCol(int sc) => sc == 3 ? C_GREEN : sc == 4 ? C_RED : C_MUTE
string statTip = "Self-computed over this chart's full history. Conditional on the FIRST purge side after the candle closed:\n↑→50% / ↑→HIGH: CRT-Low purged first (bullish) -> price tagged the 50% / the CRT-High before the projection window (" + str.tostring(projHours, "0.#") + "h) expired.\n↓→50% / ↓→LOW: mirror for a CRT-High purge (bearish).\nAmber = low sample (n<8). Changing the projection hours or a slot toggle recalculates the history.\nHeuristics: on a double-touch bar the purge side comes from the close vs the 50%; a purge bar may score its targets on that same bar (intrabar order unknown)."
var table dash = table.new(f_pos(dashPos), 7, 10, bgcolor=C_BG, frame_color=C_GOLD, frame_width=2, border_color=color.new(C_MUTE, 70), border_width=1)
if showDash and barstate.islast
    // ── R0 · brand ──
    table.cell(dash, 0, 0, "◆ CRT EDGE · NomadaScalper", bgcolor=C_GOLD, text_color=C_INK, text_size=szHead, text_halign=text.align_left, text_font_family=font.family_monospace, tooltip=statTip)
    table.cell(dash, 1, 0, "", bgcolor=C_GOLD)
    table.cell(dash, 2, 0, "", bgcolor=C_GOLD)
    table.cell(dash, 3, 0, "", bgcolor=C_GOLD)
    table.cell(dash, 4, 0, "", bgcolor=C_GOLD)
    table.cell(dash, 5, 0, "", bgcolor=C_GOLD)
    table.cell(dash, 6, 0, "", bgcolor=C_GOLD)
    // ── R1 · VERDICT (Tracy bias: 3+ soups on one side) ──
    string vTxt = biasBull ? "▲ BULLISH BIAS · TS at lows " + str.tostring(soupLo) + "/5" : biasBear ? "▼ BEARISH BIAS · TS at highs " + str.tostring(soupHi) + "/5" : (soupLo >= 3 and soupHi >= 3) ? "⛔ CONFLICT · no trade (lows " + str.tostring(soupLo) + " · highs " + str.tostring(soupHi) + ")" : "◆ WAIT · lows " + str.tostring(soupLo) + " · highs " + str.tostring(soupHi)
    color vBg = biasBull ? color.new(C_GREEN, 60) : biasBear ? color.new(C_RED, 60) : (soupLo >= 3 and soupHi >= 3) ? color.new(C_AMBER, 55) : C_RAISE
    color vFg = biasBull ? C_GREEN : biasBear ? C_RED : (soupLo >= 3 and soupHi >= 3) ? C_AMBER : C_MUTE
    table.cell(dash, 0, 1, vTxt, bgcolor=vBg, text_color=vFg, text_size=szHead, text_halign=text.align_left, text_font_family=font.family_monospace, tooltip="Tracy multi-TF bias: Turtle Soups latched this period per timeframe. 3-5 TFs souped at the LOWS -> bullish · at the HIGHS -> bearish · both sides 3+ -> conflict, stand aside. Latches reset when each timeframe's candle rolls.")
    table.cell(dash, 1, 1, "", bgcolor=vBg)
    table.cell(dash, 2, 1, "", bgcolor=vBg)
    table.cell(dash, 3, 1, "", bgcolor=vBg)
    table.cell(dash, 4, 1, "", bgcolor=vBg)
    table.cell(dash, 5, 1, "", bgcolor=vBg)
    table.cell(dash, 6, 1, "", bgcolor=vBg)
    // ── R2/R3 · per-TF Turtle Soup status ──
    table.cell(dash, 0, 2, "HTF SOUP", bgcolor=C_RAISE, text_color=C_MUTE, text_size=szCell, text_halign=text.align_left, text_font_family=font.family_monospace, tooltip="▲ = Turtle Soup at that timeframe's LOW (bullish evidence) · ▼ = at its HIGH (bearish) · ▲▼ = both sides souped this period · — = none yet.")
    table.cell(dash, 1, 2, "M",  bgcolor=C_RAISE, text_color=C_AMBER, text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace)
    table.cell(dash, 2, 2, "W",  bgcolor=C_RAISE, text_color=C_PURP,  text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace)
    table.cell(dash, 3, 2, "D",  bgcolor=C_RAISE, text_color=C_TXT,   text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace)
    table.cell(dash, 4, 2, "H4", bgcolor=C_RAISE, text_color=C_RED,   text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace)
    table.cell(dash, 5, 2, "H1", bgcolor=C_RAISE, text_color=C_BLUE,  text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace)
    table.cell(dash, 6, 2, "", bgcolor=C_RAISE)
    table.cell(dash, 0, 3, "", bgcolor=C_PANEL)
    table.cell(dash, 1, 3, f_tsCell(tsHm, tsLm), bgcolor=C_PANEL, text_color=f_tsCol(tsHm, tsLm), text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace)
    table.cell(dash, 2, 3, f_tsCell(tsHw, tsLw), bgcolor=C_PANEL, text_color=f_tsCol(tsHw, tsLw), text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace)
    table.cell(dash, 3, 3, f_tsCell(tsHd, tsLd), bgcolor=C_PANEL, text_color=f_tsCol(tsHd, tsLd), text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace)
    table.cell(dash, 4, 3, f_tsCell(tsH4, tsL4), bgcolor=C_PANEL, text_color=f_tsCol(tsH4, tsL4), text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace)
    table.cell(dash, 5, 3, f_tsCell(tsH1, tsL1), bgcolor=C_PANEL, text_color=f_tsCol(tsH1, tsL1), text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace)
    table.cell(dash, 6, 3, "", bgcolor=C_PANEL)
    // ── R4 · column groups (live vs. historical) ──
    table.cell(dash, 0, 4, "", bgcolor=C_RAISE)
    table.cell(dash, 1, 4, "LIVE", bgcolor=C_RAISE, text_color=C_GOLD, text_size=szFoot, text_halign=text.align_left, text_font_family=font.family_monospace, tooltip="This box's actual, real-time state on this chart — not a stat.")
    table.cell(dash, 2, 4, "", bgcolor=C_RAISE)
    table.cell(dash, 3, 4, "HISTORICAL ODDS (all-time %)", bgcolor=C_RAISE, text_color=C_MUTE, text_size=szFoot, text_halign=text.align_left, text_font_family=font.family_monospace, tooltip=statTip)
    table.cell(dash, 4, 4, "", bgcolor=C_RAISE)
    table.cell(dash, 5, 4, "", bgcolor=C_RAISE)
    table.cell(dash, 6, 4, "", bgcolor=C_RAISE)
    // ── R5 · slot header ──
    table.cell(dash, 0, 5, "SLOT",   bgcolor=C_RAISE, text_color=C_MUTE, text_size=szCell, text_halign=text.align_left, text_font_family=font.family_monospace)
    table.cell(dash, 1, 5, "CRT BOX", bgcolor=C_RAISE, text_color=C_MUTE, text_size=szCell, text_halign=text.align_left, text_font_family=font.family_monospace, tooltip="Has this slot's CRT box been swept yet (first purge since the box closed)? ▼ red = the BOX HIGH was swept (bearish) · ▲ green = the BOX LOW was swept (bullish) · — = neither side swept yet.")
    table.cell(dash, 2, 5, "STATUS", bgcolor=C_RAISE, text_color=C_MUTE, text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace)
    table.cell(dash, 3, 5, "↑→50%",  bgcolor=C_RAISE, text_color=C_GREEN, text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace, tooltip=statTip)
    table.cell(dash, 4, 5, "↑→HIGH", bgcolor=C_RAISE, text_color=C_GREEN, text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace, tooltip=statTip)
    table.cell(dash, 5, 5, "↓→50%",  bgcolor=C_RAISE, text_color=C_RED, text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace, tooltip=statTip)
    table.cell(dash, 6, 5, "↓→LOW",  bgcolor=C_RAISE, text_color=C_RED, text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace, tooltip=statTip)
    // ── R6-R8 · slots ──
    table.cell(dash, 0, 6, slotN1, bgcolor=C_PANEL, text_color=C_TXT, text_size=szCell, text_halign=text.align_left, text_font_family=font.family_monospace)
    table.cell(dash, 1, 6, f_boxCell(pd1), bgcolor=C_PANEL, text_color=f_boxCol(pd1), text_size=szCell, text_halign=text.align_left, text_font_family=font.family_monospace)
    table.cell(dash, 2, 6, f_status(st1, hm1, ho1), bgcolor=C_PANEL, text_color=f_statusCol(st1), text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace)
    table.cell(dash, 3, 6, f_cell(d1m, d1t), bgcolor=f_heat(d1m, d1t), text_color=C_TXT, text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace, tooltip=statTip)
    table.cell(dash, 4, 6, f_cell(d1f, d1t), bgcolor=f_heat(d1f, d1t), text_color=C_TXT, text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace, tooltip=statTip)
    table.cell(dash, 5, 6, f_cell(u1m, u1t), bgcolor=f_heat(u1m, u1t), text_color=C_TXT, text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace, tooltip=statTip)
    table.cell(dash, 6, 6, f_cell(u1f, u1t), bgcolor=f_heat(u1f, u1t), text_color=C_TXT, text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace, tooltip=statTip)
    table.cell(dash, 0, 7, slotN2, bgcolor=C_PANEL, text_color=C_TXT, text_size=szCell, text_halign=text.align_left, text_font_family=font.family_monospace)
    table.cell(dash, 1, 7, f_boxCell(pd5), bgcolor=C_PANEL, text_color=f_boxCol(pd5), text_size=szCell, text_halign=text.align_left, text_font_family=font.family_monospace)
    table.cell(dash, 2, 7, f_status(st5, hm5, ho5), bgcolor=C_PANEL, text_color=f_statusCol(st5), text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace)
    table.cell(dash, 3, 7, f_cell(d5m, d5t), bgcolor=f_heat(d5m, d5t), text_color=C_TXT, text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace, tooltip=statTip)
    table.cell(dash, 4, 7, f_cell(d5f, d5t), bgcolor=f_heat(d5f, d5t), text_color=C_TXT, text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace, tooltip=statTip)
    table.cell(dash, 5, 7, f_cell(u5m, u5t), bgcolor=f_heat(u5m, u5t), text_color=C_TXT, text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace, tooltip=statTip)
    table.cell(dash, 6, 7, f_cell(u5f, u5t), bgcolor=f_heat(u5f, u5t), text_color=C_TXT, text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace, tooltip=statTip)
    table.cell(dash, 0, 8, slotN3, bgcolor=C_PANEL, text_color=C_TXT, text_size=szCell, text_halign=text.align_left, text_font_family=font.family_monospace)
    table.cell(dash, 1, 8, f_boxCell(pd9), bgcolor=C_PANEL, text_color=f_boxCol(pd9), text_size=szCell, text_halign=text.align_left, text_font_family=font.family_monospace)
    table.cell(dash, 2, 8, f_status(st9, hm9, ho9), bgcolor=C_PANEL, text_color=f_statusCol(st9), text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace)
    table.cell(dash, 3, 8, f_cell(d9m, d9t), bgcolor=f_heat(d9m, d9t), text_color=C_TXT, text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace, tooltip=statTip)
    table.cell(dash, 4, 8, f_cell(d9f, d9t), bgcolor=f_heat(d9f, d9t), text_color=C_TXT, text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace, tooltip=statTip)
    table.cell(dash, 5, 8, f_cell(u9m, u9t), bgcolor=f_heat(u9m, u9t), text_color=C_TXT, text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace, tooltip=statTip)
    table.cell(dash, 6, 8, f_cell(u9f, u9t), bgcolor=f_heat(u9f, u9t), text_color=C_TXT, text_size=szCell, text_halign=text.align_center, text_font_family=font.family_monospace, tooltip=statTip)
    // ── R9 · footer ──
    table.cell(dash, 0, 9, "◆ Magic Hour · concepts: John Tracy [TS enhanced by Mntdude65]", bgcolor=C_BG, text_color=C_MUTE, text_size=szFoot, text_halign=text.align_left, text_font_family=font.family_monospace)
    table.cell(dash, 1, 9, "", bgcolor=C_BG)
    table.cell(dash, 2, 9, "", bgcolor=C_BG)
    table.cell(dash, 3, 9, "", bgcolor=C_BG)
    table.cell(dash, 4, 9, "", bgcolor=C_BG)
    table.cell(dash, 5, 9, "", bgcolor=C_BG)
    table.cell(dash, 6, 9, "", bgcolor=C_BG)
````
