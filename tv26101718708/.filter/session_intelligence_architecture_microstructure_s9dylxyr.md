# Session Intelligence Architecture [Microstructure]

- url: https://www.tradingview.com/script/s9DyLXYR/
- type: indicator
- pine_id: PUB;420ec5a251a349f1863c6ab8935bcf92
- version: 8.0

## Description

[b]SESSION INTELLIGENCE ARCHITECTURE [Microstructure][/b]
An institutional-grade session & market-structure overlay for crypto.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]WHAT IT DOES[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Crypto trades 24/7, but it "breathes" in three waves — Asia, Europe and the US.
Each session has its own character. This indicator marks those sessions directly on
your chart and translates institutional metrics into clear, jargon-free signals.

It answers three questions at a glance:
• Who is in control right now — buyers or sellers?
• Is a move real, or just a liquidity trap?
• Which session is actually driving the market today?

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]ON-CHART VISUALS[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• Session Boxes — a live, growing rectangle clamped to each session's high & low
  (yellow = Asia, blue = Europe, red = US). The active box border turns SOLID & thicker
  when a strong, volume-backed move is underway, and DASHED when the market is quiet.
• Session VWAP — an anchored fair-value line per session that fades out after close.
• Open / Equilibrium Line — a dotted line at each session's opening price.
• Sweep & Breakout Markers — ✕ for liquidity sweeps (stop hunts), ▲/▼ triangles for
  genuine structural breakouts of the Asia range.
• Focus Mode — gently dims the gaps between sessions so the active session pops.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]THE ENGINE (why it's different)[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• ATR-NORMALIZED, not static %. A move is only flagged as a "Significant Expansion"
  when |Close − Open| exceeds a multiple of the current ATR(14). This adapts to
  volatility instead of using a fixed, one-size-fits-all percentage.
• SESSION-SPECIFIC RVOL. Each session's cumulative volume is compared against the
  average of the last 10 SAME-type sessions (Asia vs Asia, US vs US). Above the
  threshold = institutional drive; below = suspect.
• LIQUIDITY SWEEP vs. BREAKOUT. A wick beyond the Asia high/low that closes back
  inside is tagged as a trap. A close outside with an expansion body (≥60% of range)
  is tagged as a real breakout.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]THE DASHBOARD (bottom-center)[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
One row per session, read left to right:
• SESSION — name + status (🟢 Active / ⚪ Inactive)
• MARKET STATE — plain language, color-coded:
    🚀 Buyer Dominance (Strong)   — expansion up + valid volume
    🩸 Seller Dominance (Strong)  — expansion down + valid volume
    ⚠️ Weak Trend (Trap)          — expansion without volume (fake-move protection)
    💤 Market Asleep / Accumulation — price still inside the ATR threshold
• PRICE & MOVE — session range + net % change
• RVOL — a 5-block progress bar (████░) with the raw ratio, e.g. (1.45x)
• ORDERFLOW — Bullish ▲ / Bearish ▼ based on price vs. session VWAP
Plus a merged bottom row: today's dominant session by combined volume & expansion.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]ALERTS[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• "Breakout detected" — fires once per bar close (confirmed, no repaint).
• "Liquidity Sweep detected" — fires once per bar (sweeps often form intrabar).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]SETTINGS OVERVIEW[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
① Sessions — timezone + the three session windows + historical lookback (days)
② Engine — ATR length & multiplier, RVOL lookback & threshold
③ Market Structure — breakout body ratio, toggle sweeps/breakouts
④ Visualization — colors, line widths, box fill color & saturation,
   VWAP fade-out, Focus Mode + dim color, and on/off toggles for every element

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]HOW TO USE[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Best on intraday timeframes (5m–1h), where sessions are most meaningful. Watch the
dashboard for the current regime, use the Asia range + sweep/breakout markers for
structure, and the VWAP/orderflow bias to gauge who has the upper hand.


This script is an analysis tool, not financial advice. Always do your own research
and manage risk. Past behavior does not guarantee future results.

## Source Code

````pine
//@version=6
// ╔══════════════════════════════════════════════════════════════════════════════════════╗
// ║  MARKET MICROSTRUCTURE & SESSION INTELLIGENCE ARCHITECTURE  (Crypto / UTC)             ║
// ║  Pine Script v6 · UDT-based · ATR-normalized · Session-RVOL · Liquidity Engine         ║
// ║  Author: Quant Engineering Desk · Overlay indicator · Non-Repainting                   ║
// ╚══════════════════════════════════════════════════════════════════════════════════════╝
//
// DESIGN PHILOSOPHY:
//  - A single UDT (SessionData) encapsulates the full state of a session (OHLCV, ATR, VWAP, RVOL).
//  - Methods (method ...) mutate the objects by reference -> no duplicated code per session.
//  - Graphical objects (boxes/lines) are managed in arrays and "garbage collected" outside the lookback.
//  - All classifications are ATR-normalized (volatility-adaptive) instead of static % thresholds.

indicator("Session Intelligence Architecture [Microstructure]", shorttitle="SESSION-INTEL", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// ══════════════════════════════════════════════════════════════════════════════════════════
//  I. USER INPUTS
// ══════════════════════════════════════════════════════════════════════════════════════════
string GRP_SES  = "① Sessions (Timezone: UTC)"
string GRP_ENG  = "② Volatility & Volume Engine"
string GRP_STR  = "③ Market Structure (Sweeps / Breakouts)"
string GRP_VIS  = "④ Session Boxes & Colors"
string GRP_LINE = "⑤ Lines · VWAP · Focus Mode"

// --- Session time windows (default UTC) ---
string i_tz        = input.string("UTC", "Timezone", group=GRP_SES, tooltip="All sessions are calculated in this timezone.")
bool   i_enAsia    = input.bool(true, "", inline="SA", group=GRP_SES, tooltip="Enable / disable the Asia session entirely (boxes, VWAP, dashboard).")
string i_asiaSes   = input.session("0000-0800", "Asia Session",   inline="SA", group=GRP_SES)
bool   i_enEuro    = input.bool(true, "", inline="SE", group=GRP_SES, tooltip="Enable / disable the Europe session entirely.")
string i_euroSes   = input.session("0700-1530", "Europe Session", inline="SE", group=GRP_SES)
bool   i_enUS      = input.bool(true, "", inline="SU", group=GRP_SES, tooltip="Enable / disable the US session entirely.")
string i_usSes     = input.session("1330-2100", "US Session",     inline="SU", group=GRP_SES)
int    i_lookback  = input.int(5, "Historical Lookback (Days)", minval=1, maxval=60, group=GRP_SES, tooltip="Limits the number of rendered boxes/lines per session to protect the object limit.")

// --- ATR / RVOL Engine ---
int    i_atrLen    = input.int(14, "ATR Length", minval=1, group=GRP_ENG)
float  i_atrMult   = input.float(1.5, "ATR Multiplier (Expansion)", minval=0.1, step=0.1, group=GRP_ENG, tooltip="A move counts as a 'Significant Expansion' only if |Close-Open| > ATR * Multiplier.")
int    i_rvolLen   = input.int(10, "RVOL Lookback (Sessions)", minval=2, maxval=60, group=GRP_ENG, tooltip="Number of past same-type sessions used for the volume average.")
float  i_rvolValid = input.float(1.2, "RVOL Threshold 'Institutional'", minval=1.0, step=0.05, group=GRP_ENG, tooltip="Current volume must be > Factor * historical average.")

// --- Market structure ---
float  i_bodyRatio = input.float(0.6, "Min. Body Ratio for Breakout", minval=0.1, maxval=1.0, step=0.05, group=GRP_STR, tooltip="Candle body must be at least X% of the total range (displacement filter).")
bool   i_showSweep = input.bool(true, "Show Liquidity Sweeps", group=GRP_STR)
bool   i_showBreak = input.bool(true, "Show Structural Breakouts", group=GRP_STR)
bool   i_showChoch = input.bool(true, "Show Change of Character (CHoCH)", group=GRP_STR)
int    i_chochLen  = input.int(5, "CHoCH Pivot Length", minval=2, maxval=50, group=GRP_STR, tooltip="Swing-pivot strength used to detect the market-structure shift (CHoCH).")

// --- Visualization ---
color  i_colAsia   = input.color(color.new(#f1c40f, 0), "Asia",   inline="C", group=GRP_VIS)
color  i_colEuro   = input.color(color.new(#3498db, 0), "Europe", inline="C", group=GRP_VIS)
color  i_colUS     = input.color(color.new(#e74c3c, 0), "US",     inline="C", group=GRP_VIS)
bool   i_showBox   = input.bool(true, "Session Boxes", inline="V", group=GRP_VIS)
bool   i_showVwap  = input.bool(true, "Session VWAP",  inline="V", group=GRP_VIS)
bool   i_showTable = input.bool(true, "Dashboard",     inline="V", group=GRP_VIS)
// --- Box fill (background color + saturation) ---
bool   i_boxCustomFill = input.bool(false, "Custom Box Fill Color", inline="BF", group=GRP_VIS, tooltip="On: fixed fill color for all boxes. Off: each box uses its session color.")
color  i_boxFillCol    = input.color(color.new(#888888, 0), "", inline="BF", group=GRP_VIS)
int    i_boxFillTransp = input.int(88, "Box Fill Saturation (Transparency)", minval=0, maxval=100, group=GRP_VIS, tooltip="0 = full saturation (opaque), 100 = invisible. Controls the transparency of the box background color.")
int    i_boxBordTransp = input.int(45, "Box Border Transparency", minval=0, maxval=100, group=GRP_VIS)
int    i_boxBordWidth  = input.int(2, "Box Border Width", minval=1, maxval=5, inline="BL", group=GRP_VIS)
string i_boxBordStyle  = input.string("Solid", "Box Border Style", options=["Solid", "Dashed", "Dotted"], inline="BL", group=GRP_VIS)
bool   i_boxAccent      = input.bool(true, "Session Name Above Box", inline="AC", group=GRP_VIS, tooltip="Shows the session name (ASIA / EU / USA) as coloured text floating ABOVE the box, with no background fill so it never covers the candles. Brightens on strong, volume-backed moves.")
float  i_boxAccentThick = input.float(0.35, "Name Offset Above Box (ATR)", minval=0.05, maxval=2.0, step=0.05, inline="AC", group=GRP_VIS)
bool   i_boxAccentLabel = input.bool(true, "Show Session Name in Accent Bar (ASIA / EU / USA)", group=GRP_VIS)
// --- Line widths ---
int    i_vwapWidth     = input.int(2, "Session VWAP Line Width",        minval=1, maxval=5, group=GRP_LINE)
int    i_asiaLineWidth = input.int(1, "Asia Liquidity Lines Width",     minval=1, maxval=5, group=GRP_LINE)
int    i_openLineWidth = input.int(1, "Open/Equilibrium Line Width",    minval=1, maxval=5, group=GRP_LINE)
int    i_fadeBars  = input.int(60, "VWAP Fade-Out (Bars)", minval=5, group=GRP_LINE, tooltip="Number of bars over which the VWAP fades out after the session ends.")
bool   i_showVwapLabel = input.bool(true, "Show 'Ses.Vwap' Tag (right end of VWAP)", group=GRP_LINE, tooltip="Floating label at the right end of the active session's VWAP, coloured like that session.")
bool   i_showDailyOpen = input.bool(true, "Daily Open Line + Label", inline="DO", group=GRP_LINE, tooltip="Horizontal line at the current day's opening price, with a 'Daily Open' tag at the right end.")
color  i_dOpenCol      = input.color(color.new(#ffa000, 0), "", inline="DO", group=GRP_LINE)
// --- Focus Mode: dim the background when no session is active ---
bool   i_useFocusMode = input.bool(true, "Focus Mode (Dim Background)", group=GRP_LINE, tooltip="Dims the 'empty' zones between sessions so active session boxes pop out visually.")
color  i_dimColor     = input.color(color.new(#0d1117, 40), "Dim Color (Focus Mode)", group=GRP_LINE)

// ══════════════════════════════════════════════════════════════════════════════════════════
//  II. USER-DEFINED TYPE (UDT)  -- central data object of a session
// ══════════════════════════════════════════════════════════════════════════════════════════
type SessionData
    // --- Required fields per specification ---
    float open_price      = na      // session opening price
    float high_price      = na      // session high (vertical clamping of the box)
    float low_price       = na      // session low
    float close_price     = na      // last price inside the session
    float volume          = 0.0     // CUMULATIVE session volume
    float volume_sma      = na      // reference volume SMA (context)
    float atr_value       = na      // current ATR value (volatility normalization)
    bool  is_active       = false   // is the session currently active?
    float session_range   = 0.0     // high_price - low_price (range in quote currency)
    // --- Extended engine fields ---
    float pv_sum          = 0.0     // Σ(hlc3 * volume) for VWAP
    float vol_sum         = 0.0     // Σ(volume) for VWAP (== volume, kept separate for clarity)
    float vwap            = na      // anchored session VWAP
    int   start_time      = na      // bar time of the session start (box anchor)
    float hist_avg_vol    = na      // historical volume average of same-type sessions
    float rvol_ratio      = na      // current_vol / hist_avg_vol
    int   bars_since_active = 100000 // bars since last activity (VWAP fade-out)
    box   live_box        = na      // reference to the currently growing box
    box   accent_box      = na      // reference to the top accent bar
    line  open_line       = na      // reference to the open/equilibrium line

// ══════════════════════════════════════════════════════════════════════════════════════════
//  III. PERSISTENT STATE  (var -> survives the bar change)
// ══════════════════════════════════════════════════════════════════════════════════════════
var SessionData asia   = SessionData.new()
var SessionData europe = SessionData.new()
var SessionData us     = SessionData.new()

// Box storage per session (for garbage collection)
var array<box> asiaBoxes = array.new<box>()
var array<box> euroBoxes = array.new<box>()
var array<box> usBoxes   = array.new<box>()

// Top accent bars per session (for garbage collection)
var array<box> asiaAccents = array.new<box>()
var array<box> euroAccents = array.new<box>()
var array<box> usAccents   = array.new<box>()

// Line storage per session (open lines, for garbage collection)
var array<line> asiaLines = array.new<line>()
var array<line> euroLines = array.new<line>()
var array<line> usLines   = array.new<line>()

// Historical session volume (ring buffer of the last N sessions)
var array<float> asiaVolHist = array.new<float>()
var array<float> euroVolHist = array.new<float>()
var array<float> usVolHist   = array.new<float>()

// Asia liquidity pools (for sweep/breakout logic in EU/US). Frozen after the Asia session ends.
var float asiaHighLevel = na
var float asiaLowLevel  = na

// ══════════════════════════════════════════════════════════════════════════════════════════
//  IV. GLOBAL SERIES  (must be evaluated every bar -> never in a local scope!)
// ══════════════════════════════════════════════════════════════════════════════════════════
float atrVal   = ta.atr(i_atrLen)          // ATR 14 as a continuous series (state consistency)
float volSma20 = ta.sma(volume, 20)        // reference volume SMA

// Uniform, very transparent "glass" background for ALL dashboard cells (chart stays visible;
// the colour meaning lives in the text, not the fill).
color BG_GLASS = color.new(#131722, 88)

// Session membership of the current bar (na -> not in session)
bool in_asia = i_enAsia and not na(time(timeframe.period, i_asiaSes, i_tz))
bool in_euro = i_enEuro and not na(time(timeframe.period, i_euroSes, i_tz))
bool in_us   = i_enUS   and not na(time(timeframe.period, i_usSes,   i_tz))

// ══════════════════════════════════════════════════════════════════════════════════════════
//  V. METHODS & FUNCTIONS  -- core session-tracking logic
// ══════════════════════════════════════════════════════════════════════════════════════════

// step(): updates a SessionData object for the current bar.
// Returns: [justStarted, justEnded] -> triggers box creation resp. RVOL archiving.
method step(SessionData s, bool inSess, float atrInput, float volSmaInput) =>
    bool justStarted = inSess and not s.is_active        // edge: session begins NOW
    bool justEnded   = (not inSess) and s.is_active      // edge: session ends NOW

    if justStarted
        // --- Reset / initialization at the session open ---
        s.open_price  := open
        s.high_price  := high
        s.low_price   := low
        s.close_price := close
        s.volume      := volume
        s.pv_sum      := hlc3 * volume
        s.vol_sum     := volume
        s.start_time  := time
    else if inSess
        // --- Running aggregation within the session ---
        s.high_price  := math.max(s.high_price, high)    // vertical clamp to the session high
        s.low_price   := math.min(s.low_price, low)      // vertical clamp to the session low
        s.close_price := close
        s.volume      += volume                          // cumulative session volume
        s.pv_sum      += hlc3 * volume                   // VWAP numerator
        s.vol_sum     += volume                          // VWAP denominator

    if inSess
        // Derived metrics recalculated only while the session is active (efficiency)
        s.vwap          := s.vol_sum > 0 ? s.pv_sum / s.vol_sum : na
        s.session_range := s.high_price - s.low_price
        s.atr_value     := atrInput
        s.volume_sma    := volSmaInput
        s.bars_since_active := 0
    else
        s.bars_since_active += 1                         // counter for VWAP fade-out

    s.is_active := inSess
    [justStarted, justEnded]

// classifyState(): ATR-normalized market state (no trading jargon).
// Returns: [plain-text state, color, isStrong].
//  - Expansion  : |Close-Open| > ATR * Multiplier
//  - RVOL valid : ratio > threshold (institutional drive)
//  - isStrong   : true only for the dominance states (Buyer/Seller) -> drives dynamic box border
classifyState(SessionData s) =>
    string state = "—"
    color  col   = color.new(color.gray, 30)
    bool   strong = false
    if not na(s.open_price) and not na(s.atr_value)
        float move      = s.close_price - s.open_price
        bool  up        = move > 0
        bool  expansion = math.abs(move) > s.atr_value * i_atrMult
        float ratio     = s.rvol_ratio
        bool  rvolValid = not na(ratio) and ratio > i_rvolValid
        if expansion and up and rvolValid
            state := "Buyer Dominance (Strong) 🚀"
            col   := color.new(#00b894, 0)
            strong := true
        else if expansion and (not up) and rvolValid
            state := "Seller Dominance (Strong) 🩸"
            col   := color.new(#d63031, 0)
            strong := true
        else if expansion and (na(ratio) or ratio < 1.0)
            // Expansion achieved but volume is missing -> fake move / bull or bear trap
            state := "Weak Trend (Trap) ⚠️"
            col   := color.new(#fdcb6e, 0)
        else
            // Price within the ATR threshold -> no significant expansion
            state := "Market Asleep / Accumulation 💤"
            col   := color.new(#636e72, 0)
    [state, col, strong]

// manageBox(): creates/updates the growing session box (horizontal expansion + vertical clamp)
// as well as the open/equilibrium line. Both are bounded via garbage collection.
method manageBox(SessionData s, bool justStarted, color col, string sesName, array<box> store, array<line> lineStore, array<box> accentStore, int maxKeep) =>
    if justStarted
        // --- Session body box (soft fill; near-borderless when the accent bar is on) ---
        if i_showBox
            color fillCol = color.new(i_boxCustomFill ? i_boxFillCol : col, i_boxFillTransp)
            // Body border: user-defined transparency (default 45%), width & line style
            color  bordCol   = color.new(col, i_boxBordTransp)
            string bordStyle = i_boxBordStyle == "Dotted" ? line.style_dotted : i_boxBordStyle == "Dashed" ? line.style_dashed : line.style_solid
            box b = box.new(s.start_time, s.high_price, time, s.low_price, xloc=xloc.bar_time, border_color=bordCol, border_width=i_boxBordWidth, border_style=bordStyle, bgcolor=fillCol)
            array.push(store, b)
            s.live_box := b
            // Garbage collection: delete the oldest boxes beyond the lookback
            while array.size(store) > maxKeep
                box.delete(array.shift(store))
            // --- Crisp top accent bar (session color, full strength) ---
            if i_boxAccent
                float thick = (not na(s.atr_value) and s.atr_value > 0) ? s.atr_value * i_boxAccentThick : s.high_price * 0.0005
                // Header bar ABOVE the box top (clear space above the high): dark tab + session-coloured border + full-white name
                box acc = box.new(s.start_time, s.high_price + thick, time, s.high_price, xloc=xloc.bar_time, border_color=color.new(col, 0), border_width=1, bgcolor=color.new(#0b0e14, 20), text=i_boxAccentLabel ? sesName : "", text_color=color.white, text_size=size.small, text_halign=text.align_center, text_valign=text.align_center)
                array.push(accentStore, acc)
                s.accent_box := acc
                while array.size(accentStore) > maxKeep
                    box.delete(array.shift(accentStore))
        // --- Open/equilibrium line at the session open ---
        line ol = line.new(s.start_time, s.open_price, time, s.open_price, xloc=xloc.bar_time, color=col, style=line.style_dotted, width=i_openLineWidth)
        s.open_line := ol
        array.push(lineStore, ol)
        while array.size(lineStore) > maxKeep
            line.delete(array.shift(lineStore))
    else if s.is_active
        // Pull the body box to the right + clamp vertically to high/low
        if not na(s.live_box) and i_showBox
            box.set_right(s.live_box, time)
            box.set_top(s.live_box, s.high_price)
            box.set_bottom(s.live_box, s.low_price)
        // The accent bar tracks the top edge with a constant ATR-based thickness
        if not na(s.accent_box) and i_showBox and i_boxAccent
            float thick = (not na(s.atr_value) and s.atr_value > 0) ? s.atr_value * i_boxAccentThick : s.high_price * 0.0005
            box.set_right(s.accent_box, time)
            box.set_top(s.accent_box, s.high_price + thick)
            box.set_bottom(s.accent_box, s.high_price)
        // Carry the open line to the right (held horizontally at open_price)
        if not na(s.open_line)
            line.set_x2(s.open_line, time)
            line.set_y1(s.open_line, s.open_price)
            line.set_y2(s.open_line, s.open_price)

// styleBox(): dynamically adapts the border width & style of the ACTIVE box to the market state.
//  - Dominance states (strong) -> width 2, solid (line.style_solid)
//  - otherwise                  -> width 1, dashed (line.style_dashed)
method styleBox(SessionData s, bool strong, color col) =>
    if s.is_active and i_showBox
        if i_boxAccent and not na(s.accent_box)
            // Header background: dark by default, lights up in the session colour on strong moves (text stays full white)
            box.set_bgcolor(s.accent_box, strong ? color.new(col, 20) : color.new(#0b0e14, 20))
        else if not na(s.live_box)
            // Classic mode (accent off): user width/style as baseline, emphasized on strong moves
            string baseStyle = i_boxBordStyle == "Dotted" ? line.style_dotted : i_boxBordStyle == "Dashed" ? line.style_dashed : line.style_solid
            box.set_border_width(s.live_box, strong ? i_boxBordWidth + 1 : i_boxBordWidth)
            box.set_border_style(s.live_box, strong ? line.style_solid : baseStyle)

// archiveVolume(): pushes the completed session volume into the ring buffer (max N) and
// recomputes the new historical average for the RVOL matrix.
method archiveVolume(SessionData s, array<float> hist, int keep) =>
    array.push(hist, s.volume)
    while array.size(hist) > keep
        array.shift(hist)
    s.hist_avg_vol := array.avg(hist)

// refreshRvol(): updates the RVOL ratio (current session volume vs. historical average).
method refreshRvol(SessionData s) =>
    s.rvol_ratio := (not na(s.hist_avg_vol) and s.hist_avg_vol > 0) ? s.volume / s.hist_avg_vol : na

// f_getRvolBar(): converts the RVOL ratio into a scannable 5-block progress bar.
f_getRvolBar(float ratio) =>
    string bar = "░░░░░"
    if na(ratio)
        bar := "░░░░░"
    else if ratio < 0.5
        bar := "░░░░░"
    else if ratio < 0.8
        bar := "█░░░░"
    else if ratio < 1.0
        bar := "██░░░"
    else if ratio < i_rvolValid
        bar := "███░░"
    else if ratio < 1.5
        bar := "████░"
    else
        bar := "█████"
    bar

// ══════════════════════════════════════════════════════════════════════════════════════════
//  VI. PROCESSING  -- run the methods per session
// ══════════════════════════════════════════════════════════════════════════════════════════
[startedAsia, endedAsia] = asia.step(in_asia, atrVal, volSma20)
[startedEuro, endedEuro] = europe.step(in_euro, atrVal, volSma20)
[startedUS,   endedUS]   = us.step(in_us, atrVal, volSma20)

// Manage boxes + open lines (maxKeep = lookback days + 1 buffer, since ~1 object per session per day)
int maxKeep = i_lookback + 1
asia.manageBox(startedAsia, i_colAsia, "ASIA", asiaBoxes, asiaLines, asiaAccents, maxKeep)
europe.manageBox(startedEuro, i_colEuro, "EU",   euroBoxes, euroLines, euroAccents, maxKeep)
us.manageBox(startedUS, i_colUS, "USA",  usBoxes, usLines, usAccents, maxKeep)

// Determine the market state per session (every bar -> for dynamic box borders)
[asiaState, asiaCol, asiaStrong] = classifyState(asia)
[euroState, euroCol, euroStrong] = classifyState(europe)
[usState,   usCol,   usStrong]   = classifyState(us)

// Apply dynamic box borders (expansion = solid/2, otherwise dashed/1)
asia.styleBox(asiaStrong, i_colAsia)
europe.styleBox(euroStrong, i_colEuro)
us.styleBox(usStrong, i_colUS)

// Archive RVOL history only at session END (once per session)
if endedAsia
    asia.archiveVolume(asiaVolHist, i_rvolLen)
if endedEuro
    europe.archiveVolume(euroVolHist, i_rvolLen)
if endedUS
    us.archiveVolume(usVolHist, i_rvolLen)

// Refresh the RVOL ratio every bar (for the live dashboard)
asia.refreshRvol()
europe.refreshRvol()
us.refreshRvol()

// Maintain the Asia liquidity pools: track live while Asia is active; stay frozen afterwards.
if in_asia
    asiaHighLevel := asia.high_price
    asiaLowLevel  := asia.low_price

// ══════════════════════════════════════════════════════════════════════════════════════════
//  VII. FOCUS MODE  -- dim the background when no session is active
// ══════════════════════════════════════════════════════════════════════════════════════════
bool noSession = not in_asia and not in_euro and not in_us
bgcolor(i_useFocusMode and noSession ? i_dimColor : na, title="Focus Mode Dimmer")

// ══════════════════════════════════════════════════════════════════════════════════════════
//  VIII. MARKET STRUCTURE  -- Liquidity Sweeps vs. Structural Breakouts (EU/US vs. Asia only)
// ══════════════════════════════════════════════════════════════════════════════════════════
bool euOrUs = (in_euro or in_us) and not in_asia          // active EU/US session outside of Asia
float body  = math.abs(close - open)                       // candle body
float rng   = high - low                                   // total range of the candle
bool  bigBody = rng > 0 and (body / rng) >= i_bodyRatio    // displacement filter (expansion body)

// --- Liquidity Sweep (stop hunt): wick above/below the Asia level, but the body closes INSIDE ---
bool sweepHigh = euOrUs and not na(asiaHighLevel) and high > asiaHighLevel and close < asiaHighLevel
bool sweepLow  = euOrUs and not na(asiaLowLevel)  and low  < asiaLowLevel  and close > asiaLowLevel

// --- Structural Breakout (displacement): close OUTSIDE the Asia level + expansion body ---
bool breakUp   = euOrUs and not na(asiaHighLevel) and close > asiaHighLevel and bigBody
bool breakDown = euOrUs and not na(asiaLowLevel)  and close < asiaLowLevel  and bigBody

// Visualization of the structure events
plotshape(i_showSweep and sweepHigh, title="Sweep High", style=shape.xcross, location=location.abovebar, color=color.new(#e17055, 0), size=size.tiny, text="Sweep")
plotshape(i_showSweep and sweepLow,  title="Sweep Low",  style=shape.xcross, location=location.belowbar, color=color.new(#e17055, 0), size=size.tiny, text="Sweep")
plotshape(i_showBreak and breakUp,   title="Breakout Up",   style=shape.triangleup,   location=location.belowbar, color=color.new(#00b894, 0), size=size.small, text="BO")
plotshape(i_showBreak and breakDown, title="Breakout Down", style=shape.triangledown, location=location.abovebar, color=color.new(#d63031, 0), size=size.small, text="BO")

// Asia liquidity lines for orientation (current day only) -- line width adjustable
plot(not na(asiaHighLevel) and not in_asia ? asiaHighLevel : na, "Asia High", color=color.new(i_colAsia, 40), style=plot.style_linebr, linewidth=i_asiaLineWidth)
plot(not na(asiaLowLevel)  and not in_asia ? asiaLowLevel  : na, "Asia Low",  color=color.new(i_colAsia, 40), style=plot.style_linebr, linewidth=i_asiaLineWidth)

// Right-end tags for the (permanently shown) Asia liquidity levels.
var label asiaHiLbl = na
var label asiaLoLbl = na
if barstate.islast
    if not na(asiaHighLevel) and not in_asia
        if na(asiaHiLbl)
            asiaHiLbl := label.new(bar_index, asiaHighLevel, "ASIA High", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(i_colAsia, 100), textcolor=i_colAsia, size=size.small)
        label.set_xy(asiaHiLbl, bar_index, asiaHighLevel)
        label.set_textcolor(asiaHiLbl, i_colAsia)
        if na(asiaLoLbl)
            asiaLoLbl := label.new(bar_index, asiaLowLevel, "ASIA Low", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(i_colAsia, 100), textcolor=i_colAsia, size=size.small)
        label.set_xy(asiaLoLbl, bar_index, asiaLowLevel)
        label.set_textcolor(asiaLoLbl, i_colAsia)
    else
        if not na(asiaHiLbl)
            label.delete(asiaHiLbl)
            asiaHiLbl := na
        if not na(asiaLoLbl)
            label.delete(asiaLoLbl)
            asiaLoLbl := na

// ══════════════════════════════════════════════════════════════════════════════════════════
//  VIII-b. CHANGE OF CHARACTER (CHoCH)  -- market-structure shift via swing pivots
// ══════════════════════════════════════════════════════════════════════════════════════════
// A CHoCH prints when price closes beyond the most recent OPPOSITE swing, i.e. the trend's
// character flips: a break above the last swing high while bearish -> bullish CHoCH; a break
// below the last swing low while bullish -> bearish CHoCH. Pivots are confirmed (length bars
// back), so the signal does not repaint once the breaking bar has closed.
float chPH = ta.pivothigh(i_chochLen, i_chochLen)
float chPL = ta.pivotlow(i_chochLen, i_chochLen)
var float lastSwingHigh = na
var float lastSwingLow  = na
if not na(chPH)
    lastSwingHigh := chPH
if not na(chPL)
    lastSwingLow := chPL
var int msBias = 0                       // current structure bias: 1 bullish, -1 bearish
bool chochUp   = false
bool chochDown = false
if not na(lastSwingHigh) and ta.crossover(close, lastSwingHigh)
    chochUp := msBias == -1              // flip bearish -> bullish = CHoCH
    msBias  := 1
if not na(lastSwingLow) and ta.crossunder(close, lastSwingLow)
    chochDown := msBias == 1             // flip bullish -> bearish = CHoCH
    msBias    := -1

plotshape(i_showChoch and chochUp,   title="CHoCH Up",   style=shape.labelup,   location=location.belowbar, color=color.new(#00b894, 0), text="CHoCH", textcolor=color.white, size=size.tiny)
plotshape(i_showChoch and chochDown, title="CHoCH Down", style=shape.labeldown, location=location.abovebar, color=color.new(#d63031, 0), text="CHoCH", textcolor=color.white, size=size.tiny)

if i_showChoch and (chochUp or chochDown)
    alert("Change of Character (CHoCH) " + (chochUp ? "Bullish" : "Bearish") + " on " + syminfo.ticker, alert.freq_once_per_bar_close)

// ══════════════════════════════════════════════════════════════════════════════════════════
//  IX. SESSION VWAP  -- anchored, visible while active, fading out afterwards
// ══════════════════════════════════════════════════════════════════════════════════════════
// Helper: returns [plot value, transparency] for the fade-out effect.
vwapPlot(SessionData s, bool fade) =>
    // fade = false -> the VWAP ends exactly at session close (no fade-out trailing into the gap)
    bool show = i_showVwap and not na(s.vwap) and (s.is_active or (fade and s.bars_since_active < i_fadeBars))
    float val = show ? s.vwap : na
    // Transparency rises linearly after the session ends -> smooth fade-out
    int transp = s.is_active ? 0 : int(math.min(90.0, s.bars_since_active * (90.0 / i_fadeBars)))
    [val, transp]

[asiaVwapVal, asiaVwapT] = vwapPlot(asia, true)
[euroVwapVal, euroVwapT] = vwapPlot(europe, true)
[usVwapVal,   usVwapT]   = vwapPlot(us, false)   // US VWAP stops exactly at the US session end

plot(asiaVwapVal, "Asia VWAP",   color=color.new(i_colAsia, asiaVwapT), linewidth=i_vwapWidth, style=plot.style_linebr)
plot(euroVwapVal, "Europe VWAP", color=color.new(i_colEuro, euroVwapT), linewidth=i_vwapWidth, style=plot.style_linebr)
plot(usVwapVal,   "US VWAP",     color=color.new(i_colUS,   usVwapT),   linewidth=i_vwapWidth, style=plot.style_linebr)

// --- Current session's VWAP (priority US > Europe > Asia) for the tag + the cross alert ---
float curVwap    = na
color curVwapCol = na
if in_us and not na(us.vwap)
    curVwap    := us.vwap
    curVwapCol := i_colUS
else if in_euro and not na(europe.vwap)
    curVwap    := europe.vwap
    curVwapCol := i_colEuro
else if in_asia and not na(asia.vwap)
    curVwap    := asia.vwap
    curVwapCol := i_colAsia

// "Ses.Vwap" tag, pinned to the right end of the active VWAP and coloured like the session.
var label vwapLbl = na
if barstate.islast
    if i_showVwap and i_showVwapLabel and not na(curVwap)
        if na(vwapLbl)
            vwapLbl := label.new(bar_index, curVwap, "Ses.Vwap", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(curVwapCol, 100), textcolor=curVwapCol, size=size.small)
        label.set_xy(vwapLbl, bar_index, curVwap)
        label.set_textcolor(vwapLbl, curVwapCol)
        label.set_color(vwapLbl, color.new(curVwapCol, 100))
    else if not na(vwapLbl)
        label.delete(vwapLbl)
        vwapLbl := na

// --- Daily Open: horizontal line at the current day's opening price + right-end tag ---
float dOpen = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_on)
plot(i_showDailyOpen and not na(dOpen) ? dOpen : na, "Daily Open", color=color.new(i_dOpenCol, 0), linewidth=1, style=plot.style_linebr)
var label dOpenLbl = na
if barstate.islast
    if i_showDailyOpen and not na(dOpen)
        if na(dOpenLbl)
            dOpenLbl := label.new(bar_index, dOpen, "Daily Open", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(i_dOpenCol, 100), textcolor=i_dOpenCol, size=size.small)
        label.set_xy(dOpenLbl, bar_index, dOpen)
    else if not na(dOpenLbl)
        label.delete(dOpenLbl)
        dOpenLbl := na

// ══════════════════════════════════════════════════════════════════════════════════════════
//  X. ALERT INFRASTRUCTURE  -- structured events
// ══════════════════════════════════════════════════════════════════════════════════════════
if breakUp or breakDown
    alert("Breakout detected on " + syminfo.ticker, alert.freq_once_per_bar_close)
if sweepHigh or sweepLow
    alert("Liquidity Sweep detected on " + syminfo.ticker, alert.freq_once_per_bar)

// Selectable alert: price crossing the CURRENT session's VWAP (pick it in the alert dialog).
bool vwapCross = not na(curVwap) and (ta.crossover(close, curVwap) or ta.crossunder(close, curVwap))
alertcondition(vwapCross, title="Price ⨯ Session VWAP", message="Price crossed the Session VWAP on {{ticker}}")

// ══════════════════════════════════════════════════════════════════════════════════════════
//  XI. INSTITUTIONAL DASHBOARD  (KPI-card layout, 5 columns, @ position.bottom_center)
// ══════════════════════════════════════════════════════════════════════════════════════════
var table dash = table.new(position.bottom_center, 5, 5, border_width=1, border_color=color.new(color.gray, 70), frame_width=1, frame_color=color.new(color.gray, 50))

// Helper: fills a complete session row (5 columns / KPI card).
fillRow(table t, int row, string sesName, color sesCol, SessionData s) =>
    [state, stateCol, strong] = classifyState(s)
    string status   = s.is_active ? "🟢 Active" : "⚪ Inactive"
    bool   hasData  = not na(s.open_price)
    // Metrics
    float  netPct   = hasData and s.open_price != 0 ? (s.close_price - s.open_price) / s.open_price * 100.0 : na
    string rangeStr = hasData ? str.tostring(s.session_range, format.mintick) : "—"
    string pctStr   = na(netPct) ? "—" : (netPct >= 0 ? "+" : "") + str.tostring(netPct, "0.00") + "%"
    // Combined column "Price & Move": range + Δ% on a single line (compact, no extra row height)
    string priceMoveStr = rangeStr + "  " + pctStr
    color  priceMoveCol = na(netPct) ? color.new(color.gray, 0) : (netPct >= 0 ? color.new(#55efc4, 0) : color.new(#ff7675, 0))
    // RVOL: progress bar on top, raw value below
    string rvolStr  = na(s.rvol_ratio) ? "—" : f_getRvolBar(s.rvol_ratio) + "  (" + str.tostring(s.rvol_ratio, "0.00") + "x)"
    // Orderflow bias: VWAP below price -> bullish, VWAP above price -> bearish
    string biasStr  = "—"
    color  biasCol  = color.new(color.gray, 30)
    if hasData and not na(s.vwap)
        bool bullBias = s.close_price > s.vwap
        biasStr := bullBias ? "Bullish ▲" : "Bearish ▼"
        biasCol := bullBias ? color.new(#00b894, 0) : color.new(#d63031, 0)
    // RVOL color gradient (background)
    color rvolCol = na(s.rvol_ratio) ? color.new(color.gray, 30) : (s.rvol_ratio >= i_rvolValid ? color.new(#00b894, 0) : (s.rvol_ratio < 1.0 ? color.new(#d63031, 0) : color.new(#fdcb6e, 0)))
    // Write cells (columns: 0=Session 1=State 2=Price&Move 3=RVOL 4=Orderflow)
    table.cell(t, 0, row, sesName + "  " + status, text_color=sesCol, bgcolor=BG_GLASS, text_size=size.normal, text_halign=text.align_left)
    table.cell(t, 1, row, state, text_color=stateCol, bgcolor=BG_GLASS, text_size=size.normal)
    table.cell(t, 2, row, priceMoveStr, text_color=priceMoveCol, bgcolor=BG_GLASS, text_size=size.normal)
    table.cell(t, 3, row, rvolStr, text_color=rvolCol, bgcolor=BG_GLASS, text_size=size.normal)
    table.cell(t, 4, row, biasStr, text_color=biasCol, bgcolor=BG_GLASS, text_size=size.normal)

// Score for macro dominance: combines RVOL and ATR-normalized expansion.
domScore(SessionData s) =>
    float r = na(s.rvol_ratio) ? 0.0 : s.rvol_ratio
    float e = (not na(s.atr_value) and s.atr_value > 0 and not na(s.open_price)) ? math.abs(s.close_price - s.open_price) / s.atr_value : 0.0
    r + e

// Render the dashboard only on the last bar (performance + no table repainting).
if barstate.islast and i_showTable
    // --- Header row ---
    table.cell(dash, 0, 0, "SESSION",     text_color=color.white, bgcolor=BG_GLASS, text_size=size.normal)
    table.cell(dash, 1, 0, "MARKET STATE", text_color=color.white, bgcolor=BG_GLASS, text_size=size.normal)
    table.cell(dash, 2, 0, "PRICE & MOVE", text_color=color.white, bgcolor=BG_GLASS, text_size=size.normal)
    table.cell(dash, 3, 0, "RVOL",        text_color=color.white, bgcolor=BG_GLASS, text_size=size.normal)
    table.cell(dash, 4, 0, "ORDERFLOW",   text_color=color.white, bgcolor=BG_GLASS, text_size=size.normal)

    // --- Session rows ---
    fillRow(dash, 1, "ASIA",   i_colAsia, asia)
    fillRow(dash, 2, "EUROPE", i_colEuro, europe)
    fillRow(dash, 3, "US",     i_colUS,   us)

    // --- Macro dominance: session with the highest combined score (RVOL + ATR expansion) ---
    float sA = domScore(asia)
    float sE = domScore(europe)
    float sU = domScore(us)
    string domName = "—"
    color  domCol  = color.new(color.gray, 0)
    if sA >= sE and sA >= sU and sA > 0
        domName := "ASIA"
        domCol  := i_colAsia
    else if sE >= sA and sE >= sU and sE > 0
        domName := "EUROPE"
        domCol  := i_colEuro
    else if sU > 0
        domName := "US"
        domCol  := i_colUS

    // Merge the macro row across all 5 columns (true cell merging)
    table.cell(dash, 0, 4, "🏛  Institutional Capital Flow Today (Dominance):  " + domName, text_color=domCol, bgcolor=BG_GLASS, text_size=size.large)
    table.merge_cells(dash, 0, 4, 4, 4)

// ══════════════════════════════════════════════════════════════════════════════════════════
//  XII. PARTICIPANT INTELLIGENCE  -- "Who's trading the market right now?" (right-side box)
// ══════════════════════════════════════════════════════════════════════════════════════════
//  IMPORTANT — HONEST DATA DISCLOSURE:
//  TradingView exposes NO participant-tagged data. We cannot KNOW who trades; we INFER the
//  dominant trading BEHAVIOUR from measurable footprints. The model is a normalized
//  volume×displacement matrix, augmented by volume-delta one-sidedness, liquidity sweeps,
//  delta divergence (absorption), VWAP-pin and volatility compression:
//
//                 │ High displacement (big move) │ Low displacement (small move)
//    High volume  │   Institutional (conviction) │   Smart Money (absorption)
//    Low  volume  │   Retail (chasing thin flow)  │   Market Maker (balance / VWAP pin)
//
//  All inputs are ATR-/average-normalized (symbol- & timeframe-agnostic) and read from
//  settled values -> the historical read does not repaint.

string GRP_FLOW = "⑥ Order-Flow / Participants (estimated)"
bool   i_showFlow          = input.bool(true, "Show 'Who's Trading' Box", group=GRP_FLOW)
string i_flowPos           = input.string("Bottom Right", "Box Position", options=["Top Right", "Middle Right", "Bottom Right"], group=GRP_FLOW)
bool   i_flowShowBreakdown = input.bool(true, "Show 4-Participant Breakdown", group=GRP_FLOW)
int    i_flowWin           = input.int(20, "Live Regime Window (Bars)", minval=5, maxval=200, group=GRP_FLOW, tooltip="Rolling lookback that defines the current 'who is trading now' regime.")
string i_flowLTF           = input.string("", "Volume-Delta Lower TF (blank = auto)", group=GRP_FLOW, tooltip="Lower timeframe used to estimate buy/sell volume delta. Leave blank to auto-pick from the chart timeframe. Falls back to candle-sign delta if intrabar data is unavailable.")
float  i_flowDivBoost      = input.float(0.4, "Smart-Money Sweep/Divergence Weight", minval=0.0, maxval=0.9, step=0.05, group=GRP_FLOW, tooltip="How strongly liquidity sweeps & delta divergence count toward the Smart Money score.")
color  i_colInst           = input.color(color.new(#3498db, 0), "Institutional", inline="P1", group=GRP_FLOW)
color  i_colSmart          = input.color(color.new(#9b59b6, 0), "Smart Money",   inline="P1", group=GRP_FLOW)
color  i_colRetail         = input.color(color.new(#e67e22, 0), "Retail",        inline="P2", group=GRP_FLOW)
color  i_colMM             = input.color(color.new(#95a5a6, 0), "Market Maker",  inline="P2", group=GRP_FLOW)

// --- Small helpers ---
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))

// Auto lower-TF selector: always strictly LOWER than the chart timeframe (else request returns empty).
f_autoLTF() =>
    int s = timeframe.in_seconds()
    string r = s >= 86400 ? "60" : s >= 14400 ? "30" : s >= 3600 ? "5" : s >= 300 ? "1" : "1S"
    r

// 5-block intensity bar for a 0..100 percentage.
f_getPctBar(float p) =>
    string b = "░░░░░"
    if na(p)
        b := "░░░░░"
    else if p < 20
        b := "█░░░░"
    else if p < 40
        b := "██░░░"
    else if p < 60
        b := "███░░"
    else if p < 80
        b := "████░"
    else
        b := "█████"
    b

// --- Volume Delta engine (global scope; request.* must not live inside a function/condition) ---
string flowLTF = i_flowLTF == "" ? f_autoLTF() : i_flowLTF
array<float> upArr = request.security_lower_tf(syminfo.tickerid, flowLTF, close >= open ? volume : 0.0)
array<float> dnArr = request.security_lower_tf(syminfo.tickerid, flowLTF, close <  open ? volume : 0.0)
// Guard: request.security_lower_tf returns `na` (not an empty array) on the first bars -> never
// call array.size/sum on an na array. Control-flow `if` (not a ternary) makes this safe.
float vdRaw = na
if not na(upArr) and not na(dnArr)
    if array.size(upArr) > 0
        vdRaw := array.sum(upArr) - array.sum(dnArr)
// Graceful fallback: if intrabar data is unavailable, sign the bar's volume by its candle direction.
float vd = na(vdRaw) ? (close >= open ? volume : -volume) : vdRaw

// --- Normalized per-bar features (all guarded -> never NA-propagate into the scores) ---
bool   flowReady = not na(atrVal) and atrVal > 0
float  volBase   = ta.sma(volume, i_flowWin)
float  rvolNow   = not na(volBase) and volBase > 0 ? volume / volBase : 1.0
float  vwapVal   = ta.vwap(hlc3)
float  atrSma    = ta.sma(atrVal, i_flowWin * 3)

float nVol  = f_clamp((rvolNow - 0.6) / (1.6 - 0.6), 0, 1)                                   // volume axis
float nDisp = flowReady ? f_clamp((math.abs(close - open) / atrVal) / 1.5, 0, 1) : 0.0       // displacement axis
float nImb  = f_clamp(math.abs(vd) / math.max(volume, 1e-9), 0, 1)                           // delta one-sidedness
float divergence = math.sign(vd) != math.sign(close - open) ? 1.0 : 0.0                       // absorption signal
float nPin  = flowReady and not na(vwapVal) ? f_clamp(1 - math.abs(close - vwapVal) / atrVal, 0, 1) : 0.0  // VWAP magnet
float nCompr = not na(atrSma) and atrSma > 0 ? f_clamp(1 - atrVal / atrSma, 0, 1) : 0.0       // volatility compression

float sumDir = math.sum(close - open, i_flowWin)
float sumAbs = math.sum(math.abs(close - open), i_flowWin)
float chop  = sumAbs > 0 ? f_clamp(1 - math.abs(sumDir) / sumAbs, 0, 1) : 0.0                 // directionless = retail noise

// Reuse the structural sweep detection from section VIII.
float nSweep = (sweepHigh or sweepLow) ? 1.0 : 0.0

// --- Four raw participant scores (per bar) ---
float instRaw   = nVol * nDisp * (0.5 + 0.5 * nImb)
float smartRaw  = nVol * (1 - nDisp) * (1 - i_flowDivBoost) + (divergence * 0.5 + nSweep * 0.5) * i_flowDivBoost
float retailRaw = (1 - nVol) * nDisp * (0.6 + 0.4 * chop)
float mmRaw     = (1 - nVol) * (1 - nDisp) * (0.5 + 0.25 * nPin + 0.25 * nCompr)

// --- Smooth over the regime window for a stable "live" read ---
float instS   = ta.sma(instRaw,   i_flowWin)
float smartS  = ta.sma(smartRaw,  i_flowWin)
float retailS = ta.sma(retailRaw, i_flowWin)
float mmS     = ta.sma(mmRaw,     i_flowWin)

// --- Normalize to shares that sum to 100 ---
float flowTotal = instS + smartS + retailS + mmS
float instP   = flowTotal > 0 ? instS   / flowTotal * 100 : 25.0
float smartP  = flowTotal > 0 ? smartS  / flowTotal * 100 : 25.0
float retailP = flowTotal > 0 ? retailS / flowTotal * 100 : 25.0
float mmP     = flowTotal > 0 ? mmS     / flowTotal * 100 : 25.0

// --- Verdict: dominant participant + confidence ---
float  maxP     = math.max(math.max(instP, smartP), math.max(retailP, mmP))
string winName  = maxP == instP ? "🏛 INSTITUTIONAL" : maxP == smartP ? "🧠 SMART MONEY" : maxP == retailP ? "🐟 RETAIL" : "⚖️ MARKET MAKER"
color  winCol   = maxP == instP ? i_colInst : maxP == smartP ? i_colSmart : maxP == retailP ? i_colRetail : i_colMM

// --- Right-side box (table; not counted against box/line/label limits) ---
var table flowBox = table.new(i_flowPos == "Top Right" ? position.top_right : i_flowPos == "Bottom Right" ? position.bottom_right : position.middle_right, 3, 6, border_width=1, border_color=color.new(color.gray, 70), frame_width=1, frame_color=color.new(color.gray, 50))

// Helper: one breakdown row (name | bar | pct).
f_flowRow(table t, int row, string label, color c, float pct) =>
    table.cell(t, 0, row, label, text_color=color.new(c, 0), bgcolor=BG_GLASS, text_size=size.normal, text_halign=text.align_left)
    table.cell(t, 1, row, f_getPctBar(pct), text_color=color.new(c, 0), bgcolor=BG_GLASS, text_size=size.normal)
    table.cell(t, 2, row, str.tostring(pct, "0") + "%", text_color=color.new(c, 0), bgcolor=BG_GLASS, text_size=size.normal)

if barstate.islast and i_showFlow
    // Title
    table.cell(flowBox, 0, 0, "WHO'S TRADING NOW", text_color=color.white, bgcolor=BG_GLASS, text_size=size.normal)
    table.merge_cells(flowBox, 0, 0, 2, 0)
    // Verdict
    table.cell(flowBox, 0, 1, "▶ " + winName + "   " + str.tostring(maxP, "0") + "%", text_color=winCol, bgcolor=BG_GLASS, text_size=size.large)
    table.merge_cells(flowBox, 0, 1, 2, 1)
    // Breakdown
    if i_flowShowBreakdown
        f_flowRow(flowBox, 2, "🏛 Institutional", i_colInst,   instP)
        f_flowRow(flowBox, 3, "🧠 Smart Money",   i_colSmart,  smartP)
        f_flowRow(flowBox, 4, "🐟 Retail",        i_colRetail, retailP)
        f_flowRow(flowBox, 5, "⚖️ Market Maker",  i_colMM,     mmP)

// Alert when the dominant participant changes (confirmed bars only -> no repaint).
if barstate.isconfirmed and i_showFlow and winName != winName[1]
    alert("Dominant flow shifted to " + winName + " on " + syminfo.ticker, alert.freq_once_per_bar_close)

// ══════════════════════════════════════════════════════════════════════════════════════════
//  XIII. SPOT vs FUTURES FLOW  -- real cross-market read (bottom-left box)
// ══════════════════════════════════════════════════════════════════════════════════════════
//  Unlike Section XII (single-symbol inference), this compares the SPOT and the FUTURES (perp)
//  market DIRECTLY by pulling a second symbol with request.security:
//   - Basis / premium  : perp price vs spot price  -> leveraged (futures) buy demand
//   - Taker-delta diff  : net taker buy volume on perp vs spot -> who lifts the book harder
//   - Volume share      : which market simply trades more
//  ignore_invalid_symbol=true -> a wrong/auto-mismatched symbol yields na instead of erroring.
//  Reuses f_clamp / f_autoLTF / f_getPctBar from Section XII.

string GRP_SF = "⑦ Spot vs Futures Flow (real cross-market)"
bool   i_showSF        = input.bool(true, "Show Spot-vs-Futures Box", group=GRP_SF)
string i_sfSpotSym     = input.string("", "Spot Symbol (blank = auto)",    group=GRP_SF, tooltip="Blank = auto-derive from the chart (strip .P). Override for non-Binance naming, e.g. BYBIT:BTCUSDT.")
string i_sfPerpSym     = input.string("", "Futures Symbol (blank = auto)", group=GRP_SF, tooltip="Blank = auto-derive from the chart (append .P). Override for non-Binance naming, e.g. BYBIT:BTCUSDT.P.")
int    i_sfWin         = input.int(20, "Smoothing Window (Bars)", minval=5, maxval=200, group=GRP_SF)
string i_sfLTF         = input.string("", "Volume-Delta Lower TF (blank = auto)", group=GRP_SF, tooltip="Lower timeframe for the taker buy/sell delta on each market. Blank = auto from chart timeframe.")
float  i_sfBasisWeight = input.float(0.5, "Basis vs. Taker-Delta Weight", minval=0.0, maxval=1.0, step=0.05, group=GRP_SF, tooltip="1.0 = pure basis/premium, 0.0 = pure taker-delta differential.")
color  i_colSpot       = input.color(color.new(#2ecc71, 0), "Spot",    inline="SF", group=GRP_SF)
color  i_colFut        = input.color(color.new(#e84393, 0), "Futures", inline="SF", group=GRP_SF)

// --- Symbol auto-derivation (simple strings -> valid for request.* symbol arg) ---
bool   isPerpChart = str.contains(syminfo.tickerid, ".P")
string autoSpot = isPerpChart ? str.replace_all(syminfo.tickerid, ".P", "") : syminfo.tickerid
string autoPerp = isPerpChart ? syminfo.tickerid : syminfo.tickerid + ".P"
string spotSym  = i_sfSpotSym == "" ? autoSpot : i_sfSpotSym
string perpSym  = i_sfPerpSym == "" ? autoPerp : i_sfPerpSym
string sfLTF    = i_sfLTF == "" ? f_autoLTF() : i_sfLTF

// --- Real data fetch (global scope; ignore_invalid_symbol -> na instead of runtime error) ---
[spotO, spotC, spotV] = request.security(spotSym, timeframe.period, [open, close, volume], ignore_invalid_symbol=true)
[perpO, perpC, perpV] = request.security(perpSym, timeframe.period, [open, close, volume], ignore_invalid_symbol=true)
array<float> spotUp = request.security_lower_tf(spotSym, sfLTF, close >= open ? volume : 0.0, ignore_invalid_symbol=true)
array<float> spotDn = request.security_lower_tf(spotSym, sfLTF, close <  open ? volume : 0.0, ignore_invalid_symbol=true)
array<float> perpUp = request.security_lower_tf(perpSym, sfLTF, close >= open ? volume : 0.0, ignore_invalid_symbol=true)
array<float> perpDn = request.security_lower_tf(perpSym, sfLTF, close <  open ? volume : 0.0, ignore_invalid_symbol=true)

// --- Net taker deltas with graceful candle-sign fallback when intrabar data is missing ---
// Guard against na arrays (request.security_lower_tf returns na on the first bars).
float spotDeltaRaw = na
if not na(spotUp) and not na(spotDn)
    if array.size(spotUp) > 0
        spotDeltaRaw := array.sum(spotUp) - array.sum(spotDn)
float spotDelta = na(spotDeltaRaw) ? (spotC >= spotO ? nz(spotV) : -nz(spotV)) : spotDeltaRaw
float perpDeltaRaw = na
if not na(perpUp) and not na(perpDn)
    if array.size(perpUp) > 0
        perpDeltaRaw := array.sum(perpUp) - array.sum(perpDn)
float perpDelta = na(perpDeltaRaw) ? (perpC >= perpO ? nz(perpV) : -nz(perpV)) : perpDeltaRaw

// --- Metrics ---
float basisPct     = not na(spotC) and spotC > 0 and not na(perpC) ? (perpC - spotC) / spotC * 100 : na   // perp premium/discount
float spotDeltaPct = not na(spotV) and spotV > 0 ? spotDelta / spotV : 0.0                                 // -1..1 net buy aggression
float perpDeltaPct = not na(perpV) and perpV > 0 ? perpDelta / perpV : 0.0
float volShareFut  = (nz(spotV) + nz(perpV)) > 0 ? nz(perpV) / (nz(spotV) + nz(perpV)) : 0.5               // 0..1 futures volume dominance

float basisSig = na(basisPct) ? 0.0 : f_clamp(basisPct / 0.1, -1, 1)        // ~0.1% premium = full futures signal
float deltaSig = f_clamp(perpDeltaPct - spotDeltaPct, -1, 1)                 // who lifts harder
float biasRaw  = i_sfBasisWeight * basisSig + (1 - i_sfBasisWeight) * deltaSig   // -1..1 (+ = futures-led)
float biasS    = ta.sma(biasRaw, i_sfWin)
float futShare = f_clamp((biasS + 1) / 2 * 100, 0, 100)
float spotShare = 100 - futShare

string sfVerdict = futShare >= 58 ? "▶ FUTURES-LED" : futShare <= 42 ? "▶ SPOT-LED" : "▶ BALANCED"
color  sfCol     = futShare >= 58 ? i_colFut : futShare <= 42 ? i_colSpot : color.new(color.gray, 0)
bool   sfValid   = not na(spotC) and not na(perpC)   // both symbols resolved?

// --- Bottom-left box (table; not counted against box/line/label limits) ---
var table sfBox = table.new(position.bottom_left, 3, 4, border_width=1, border_color=color.new(color.gray, 70), frame_width=1, frame_color=color.new(color.gray, 50))

if barstate.islast and i_showSF
    table.cell(sfBox, 0, 0, "SPOT vs FUTURES", text_color=color.white, bgcolor=BG_GLASS, text_size=size.normal)
    table.merge_cells(sfBox, 0, 0, 2, 0)
    if not sfValid
        table.cell(sfBox, 0, 1, "n/a — set Spot/Futures symbols in settings", text_color=color.white, bgcolor=BG_GLASS, text_size=size.normal)
        table.merge_cells(sfBox, 0, 1, 2, 1)
        table.cell(sfBox, 0, 2, "🟢 Spot",    text_color=i_colSpot, bgcolor=BG_GLASS, text_size=size.normal, text_halign=text.align_left)
        table.cell(sfBox, 1, 2, "░░░░░",      text_color=color.new(i_colSpot, 40), bgcolor=BG_GLASS, text_size=size.normal)
        table.cell(sfBox, 2, 2, "—",          text_color=i_colSpot, bgcolor=BG_GLASS, text_size=size.normal)
        table.cell(sfBox, 0, 3, "🟣 Futures", text_color=i_colFut, bgcolor=BG_GLASS, text_size=size.normal, text_halign=text.align_left)
        table.cell(sfBox, 1, 3, "░░░░░",      text_color=color.new(i_colFut, 40), bgcolor=BG_GLASS, text_size=size.normal)
        table.cell(sfBox, 2, 3, "—",          text_color=i_colFut, bgcolor=BG_GLASS, text_size=size.normal)
    else
        // Verdict + dominant share %
        table.cell(sfBox, 0, 1, sfVerdict + "   " + str.tostring(math.max(spotShare, futShare), "0") + "%", text_color=sfCol, bgcolor=BG_GLASS, text_size=size.large)
        table.merge_cells(sfBox, 0, 1, 2, 1)
        // Spot row
        table.cell(sfBox, 0, 2, "🟢 Spot", text_color=i_colSpot, bgcolor=BG_GLASS, text_size=size.normal, text_halign=text.align_left)
        table.cell(sfBox, 1, 2, f_getPctBar(spotShare), text_color=color.new(i_colSpot, 0), bgcolor=BG_GLASS, text_size=size.normal)
        table.cell(sfBox, 2, 2, str.tostring(spotShare, "0") + "%", text_color=i_colSpot, bgcolor=BG_GLASS, text_size=size.normal)
        // Futures row
        table.cell(sfBox, 0, 3, "🟣 Futures", text_color=i_colFut, bgcolor=BG_GLASS, text_size=size.normal, text_halign=text.align_left)
        table.cell(sfBox, 1, 3, f_getPctBar(futShare), text_color=color.new(i_colFut, 0), bgcolor=BG_GLASS, text_size=size.normal)
        table.cell(sfBox, 2, 3, str.tostring(futShare, "0") + "%", text_color=i_colFut, bgcolor=BG_GLASS, text_size=size.normal)

// Alert when the spot/futures regime flips (confirmed bars only -> no repaint).
if barstate.isconfirmed and i_showSF and sfValid and sfVerdict != sfVerdict[1]
    alert("Spot/Futures flow: " + sfVerdict + " on " + syminfo.ticker, alert.freq_once_per_bar_close)
````
