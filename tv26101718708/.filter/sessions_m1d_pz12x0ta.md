# Sessions+ (M1D)

- url: https://www.tradingview.com/script/Pz12X0Ta-Sessions-M1D/
- type: indicator
- pine_id: PUB;2a29d66eb19246908ec0819f91072c28
- version: 5.0

## Description

Sessions+ maps the ICT trading day as liquidity. It tracks the Asia, London and New York session highs and lows, frames the midnight (00:00) opening range, and reads your daily bias, premium/discount, resting liquidity and average range on one dashboard — everything you'd otherwise mark up by hand, kept current automatically.

Session levels (Asia / London / NY)
Each session's high and low are drawn from the exact candle that formed the extreme (not the session's start/end time) and projected forward as a liquidity level:

A session high is buy-side liquidity (resting stops above price). A session low is sell-side liquidity (resting stops below price).
A level stays live — bold colour, extending line — until price trades back through it. The moment that happens the level is "swept"/"mitigated": the line freezes in place and dims, so tapped liquidity fades into the background instead of cluttering the chart, but stays visible for context.
Every level carries a dated label (e.g. ASIA.H 06/07) so you always know which day a level belongs to, even several days back.
Session Days Back (0–5) — how many prior days of session levels stay on the chart in addition to today. 0 = today only (default); set to 2 to see the last 3 days of Asia/London/NY levels, each still fading correctly when tapped.
Core session windows plus optional carry windows (Asia carries to 02:00, London to 09:30, NY to 16:00) — the level keeps tracking new extremes through this follow-on period, not just the core window, since price often makes its real high/low after the "session" clock ends.
12am Opening Range
The first 30 minutes of the ICT trading day (00:00–00:30 NY) — the day's first pool of liquidity:

Boxes the 00:00–00:30 range and draws its high and low from the exact wick that made them (labelled 12am.H / 12am.L), plus a centred 12am tag on the box marking the open.
Each level holds until a candle body closes fully through it (not just a wick tap — a confirmed close), or until 05:00 NY (London Kill Zone close) if nothing has taken it by then. Either way, the level then freezes and dims like a session level.
Its own Trading Days Back (0–5), separate from the session setting above, so you can keep a different history depth for the 12am range vs. the sessions.
Dashboard — what every row means
The panel (top-right by default) is a live readout, refreshed every bar:

— BIAS —

Daily Dir: Bullish or Bearish — simply whether price is currently trading above or below today's 00:00 (midnight) open.
Bias: the actual trade bias, based on how far price sits into the prior dealing range (see Premium/Discount below) — not just which side of a line it's on:
Bullish — price is in discount (bought down into the lower half of the range) and below the midnight open — both signals agree.
Lean Bullish — price is in discount, but still trading above the midnight open (signals disagree, weaker read).
Bearish / Lean Bearish — the mirror image, price in premium.
Neutral — price is genuinely camped around the 50% equilibrium (inside the adjustable Bias Neutral Band %), i.e. no real edge either way. Bias never reports a vague "mixed" result — it always commits to a lean unless price is truly balanced.
— PREMIUM / DISCOUNT —

PDH / PWH / PMH and PDL / PWL / PML — the high and low of the dealing range you select in settings: Previous Day, Previous Week, or Previous Month. This is the range ICT traders use to judge premium vs. discount.
Each shows a ✓ (green) if that level is still open/unswept, or a ✗ (red) once price has traded through it this period.
EQ 50% — the exact midpoint of that dealing range (the equilibrium), plus a live read: premium (above EQ — expensive, favour selling), discount (below EQ — cheap, favour buying), or above PDH / below PDL if price has broken outside the range entirely.
— LIQUIDITY (today) —

Asia H / Asia L, London H / London L, NY H / NY L — today's session levels, each with the same ✓ open (green) / ✗ swept (red) marker as above, so you can tell at a glance which pools of liquidity are still resting and which have already been run.
— 12am OPENING RANGE —

12am Open — the exact 00:00 NY opening price, with its live distance from current price.
12am Rng — the size (in points) of the 00:00–00:30 opening range.
12am OR H / 12am OR L — the range's high/low, again with ✓/✗ sweep status.
— ADR (N-Day) — ("ADR" = Average Daily Range — the typical size, in points, of a full trading day over your chosen lookback)

ADR — the average range figure itself, plus % used — how much of that typical daily move has already printed today (e.g. "112% used" means today has already moved further than an average day, which flags a potentially exhausted/extended move).
Proj Hi / Proj Lo — simple range projections: today's low + ADR (a possible high target), and today's high − ADR (a possible low target) — a rough gauge of how much room is statistically "left" in the day.
Day Rng — today's actual realised range so far, for comparison against the ADR figure.
Settings
Sessions — timezone, core + carry windows per session, Session Days Back, line width, mitigated-dim %, session label size.
12am Opening Range — show/hide, range window, Trading Days Back, active window (the 05:00 cutoff), box fill and level line colours/width, label colour.
Dashboard — show/hide, screen position, text size, which Dealing Range to use for premium/discount (Day/Week/Month), ADR lookback length, Bias Neutral Band %, and the bullish/bearish/neutral/open/swept colours.
ICT logic in one line
London and New York run the liquidity that Asia and the prior period left resting; the midnight open is the true day open and the pivot for premium/discount; the 12am range is the very first pool the new day creates. This tool keeps all four of those — sessions, midnight range, dealing-range bias, and average range — in front of you at once.

Notes
Best on intraday timeframes (30 minutes or lower recommended for the 12am Opening Range; the session levels work across any intraday timeframe).
Session-based (not a fixed UTC offset), so everything tracks correctly through daylight-saving changes.
A level's date stamps when it opened, not the trading day it belongs to — e.g. Asia opens at 6pm NY, so its label shows the prior calendar date, which is when that range actually printed.
Daily/weekly/monthly and ADR data are pulled anti-repaint (confirmed prior-period values only); every swept/taken state is confirmed on candle close, never mid-bar.

Built by M1D. For education and the study of price delivery — not financial advice.
(New and improved version of the previous "Sessions Highs And Lows Unmitigated" script.)

## Source Code

````pine
//@version=6
// ============================================================================
//  Sessions + (M1D)
//  Asia / London / NY session highs & lows with carry windows, a 12am opening
//  range, and an ICT dashboard (bias, premium/discount, liquidity, ADR).
// ============================================================================
indicator('Sessions + (M1D)', overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// == ORIGIN GUARD ==
// A drawing anchored on a stored origin can sit thousands of chart bars back. Placing that x walks the
// `time` series to it, and Pine auto-sizes that buffer from what history happened to need, so a live bar
// that needs one more kills the whole script ("requested historical offset is beyond the historical
// buffer's limit"). Function form buffers `time` alone; anything older than ORIGIN_MAX clamps to the
// buffer's edge and draws short from the left instead of crashing.
const int ORIGIN_MAX = 4900
max_bars_back(time, 5000)
//@function Clamps a bar-time anchor to the oldest bar the drawing engine can still place.
//@param t (int) The stored origin time.
//@returns (int) t, or the time of the oldest reachable bar when t is older than that.
f_xClamp(int t) =>
    math.max(t, time[math.min(bar_index, ORIGIN_MAX)])


// Real black, NOT Pine's built-in black constant — that one is #363A45, a dark slate
// grey out of TradingView's own UI chrome, so on a white chart every line and every
// label that used it rendered grey. Where black is the requirement it is written as
// the hex. A grep proving this file is CONSISTENT is not a check that it is BLACK;
// only the hex value is.
const color C_INK = #000000

//========================
// Inputs
//========================
tz = input.string('America/New_York', 'Session Timezone')

asiaCore = input.session('1800-0000', 'Asia CORE (NY)')
lonCore = input.session('0200-0500', 'London CORE (NY)')
nyCore = input.session('0930-1100', 'New York AM (NY)')

useAsiaCarry = input.bool(true, 'Asia Carry 00:00–02:00')
asiaCarrySess = input.session('0000-0200', 'Asia Carry Window')

useLonCarry = input.bool(true, 'London Carry 05:00–09:30')
lonCarrySess = input.session('0500-0930', 'London Carry Window')

useNYCarry = input.bool(true, 'NY Carry 11:00–16:00')
nyCarrySess = input.session('1100-1600', 'NY Carry Window')

gSess = 'Show Sessions'
showAsia = input.bool(true, 'Asia', group = gSess)
showLon = input.bool(true, 'London', group = gSess)
showNy = input.bool(true, 'NY AM', group = gSess)
showNyLunch = input.bool(false, 'NY Lunch', group = gSess, inline = 'nyl')
nyLunchCore = input.session('1200-1300', '', group = gSess, inline = 'nyl')
showNyPm = input.bool(false, 'NY PM', group = gSess, inline = 'nyp')
nyPmCore = input.session('1330-1600', '', group = gSess, inline = 'nyp')
showSessLabels = input.bool(true, 'Session Labels', group = gSess)

lineW = input.int(2, 'Line Width', minval = 1, maxval = 5)
dimTransp = input.int(50, 'Mitigated Level Dim %', minval = 0, maxval = 100)
lblSizeIn = input.string('Small', 'Session Label Size', options = ['Tiny', 'Small', 'Normal', 'Large'])
sessDaysBack = input.int(0, 'Session Days Back', minval = 0, maxval = 15, tooltip = 'Prior days of Asia/London/NY levels kept on the chart, in addition to today (0–15). Older levels dim once mitigated.')

//========================
// 12am Opening Range (00:00–00:30 NY)
//========================
gMOR = '12am Opening Range'
useMOR = input.bool(true, 'Show 12am OR', group = gMOR)
morSess = input.session('0000-0030', '12am Range Window (NY)', group = gMOR)
morDaysBack = input.int(1, 'Trading Days Back', minval = 0, maxval = 5, tooltip = 'How many prior days of midnight ranges to keep on the chart, in addition to the current day (0–5).', group = gMOR)
morActiveSess = input.session('0000-0500', 'Levels Active Window (NY)', tooltip = 'Range levels project from the wick extreme until a candle body closes through them, or until this window ends — London Kill Zone close (05:00 NY).', group = gMOR)
morBoxCol = input.color(color.new(color.gray, 70), 'Box Fill', group = gMOR)
morLineCol = input.color(C_INK, 'Level Lines', group = gMOR)
morLineW = input.int(1, 'Level Line Width', minval = 1, maxval = 5, group = gMOR)
morTxtCol = input.color(color.white, '12am Label', group = gMOR)

//========================
// Midnight Open (00:00 NY true day open)
//========================
gMO = 'Midnight Open'
useMO = input.bool(true, 'Show Midnight Open Line', group = gMO, tooltip = 'The 00:00 New York open, drawn from its own candle. Today\'s line is dotted and runs with price. When the next midnight opens, the prior line stops there and takes its date.')
moDaysBack = input.int(1, 'Days Back', minval = 0, maxval = 5, tooltip = 'Prior midnight opens kept on the chart, in addition to today (0–5).', group = gMO)
moCol = input.color(C_INK, 'Line', group = gMO, inline = 'mo')
moW = input.int(1, 'Width', minval = 1, maxval = 5, group = gMO, inline = 'mo')

//========================
// Dashboard
//========================
gDash = 'Dashboard'
showDash = input.bool(true, 'Show Dashboard', group = gDash)
dashPosIn = input.string('Top Right', 'Position', options = ['Top Right', 'Top Left', 'Bottom Right', 'Bottom Left', 'Middle Right'], group = gDash)
dashSizeIn = input.string('Normal', 'Text Size', options = ['Tiny', 'Small', 'Normal'], group = gDash)
adrDaysIn = input.int(5, 'ADR Days', minval = 1, maxval = 20, tooltip = 'Lookback for the Average Daily Range and its projections.', group = gDash)
pdRangeIn = input.string('Previous Day', 'PD Dealing Range', options = ['Previous Day', 'Previous Week', 'Previous Month'], tooltip = 'Which prior period defines the premium/discount dealing range and its 50% equilibrium.', group = gDash)
dashColour = input.bool(false, 'Colour the Verdicts', tooltip = 'Off: every cell is black ink. On: bias and open/swept values take the colours below.', group = gDash)
bullCol = input.color(#1B7F4B, 'Bullish', group = gDash)
bearCol = input.color(#C0392B, 'Bearish', group = gDash)
neutCol = input.color(color.gray, 'Neutral', group = gDash)
openCol = input.color(#1B7F4B, 'Level Open', group = gDash)
sweptCol = input.color(#C0392B, 'Level Swept', group = gDash)
biasBandIn = input.float(5, 'Bias Neutral Band %', minval = 0, maxval = 50, tooltip = 'Price within this % of the dealing range around equilibrium reads as neutral; beyond it leans bullish/bearish.', group = gDash)

//========================
// Colors — all black
//========================
asiaCol = C_INK
lonCol = C_INK
nyCol = C_INK

//========================
// Helpers
//========================
//@function True when the current bar falls inside the given session window.
//@param _sess (string) Session specification (e.g. '0930-1100').
//@returns (bool) Whether the bar is in session.
in_session(_sess) =>
    not na(time(timeframe.period, _sess, tz))

//@function Price formatted to the symbol's tick size, or an em dash when na.
//@param _p (float) Price.
//@returns (string) Formatted price.
f_px(float _p) =>
    na(_p) ? '—' : str.tostring(_p, format.mintick)

//@function Signed distance from current price to a level, with an explicit plus sign.
//@param _lvl (float) Target level.
//@param _px (float) Current price.
//@returns (string) "+12.25" / "-8.50".
f_dist(float _lvl, float _px) =>
    float d = _lvl - _px
    (d > 0 ? '+' : '') + str.tostring(d, format.mintick)

//@function Liquidity value: the level price, then whether it is still open or already swept.
//@param _lvl (float) Level price.
//@param _mit (bool) Whether the level is swept / mitigated.
//@param _word (string) Word used for a taken level.
//@returns (string) "29,497.00  open" / "29,497.00  swept".
f_lvl(float _lvl, bool _mit, string _word) =>
    str.tostring(_lvl, format.mintick) + '  ' + (_mit ? _word : 'open')

//@function Value colour for an open/swept level — ink unless verdict colouring is on.
//@param _swept (bool) Whether the level has been swept / mitigated.
//@returns (color) Value colour.
f_lc(bool _swept) =>
    not dashColour ? C_INK : _swept ? sweptCol : openCol

//@function Resolves the dashboard position input to a table position.
//@param _p (string) Position label.
//@returns (string) Table position constant.
f_pos(string _p) =>
    switch _p
        'Top Left'     => position.top_left
        'Bottom Right' => position.bottom_right
        'Bottom Left'  => position.bottom_left
        'Middle Right' => position.middle_right
        =>                position.top_right

//@function Resolves the dashboard size input to a text size.
//@param _s (string) Size label.
//@returns (string) Text size constant.
f_size(string _s) =>
    switch _s
        'Tiny'   => size.tiny
        'Normal' => size.normal
        'Large'  => size.large
        =>         size.small

//@function Writes a section heading row — bold ink name, empty value cell. No merge, so rows can shift.
//@param _t (table) Target table.
//@param _r (int) Row index.
//@param _txt (string) Heading text.
//@param _sz (string) Text size.
//@returns (int) The next free row.
f_head(table _t, int _r, string _txt, string _sz) =>
    table.cell(_t, 0, _r, _txt, text_color = C_INK, bgcolor = color.white, text_size = _sz, text_halign = text.align_left, text_font_family = font.family_monospace, text_formatting = text.format_bold)
    table.cell(_t, 1, _r, '', text_color = C_INK, bgcolor = color.white, text_size = _sz)
    _r + 1

//@function Writes one dashboard row — italic name on the left, bold value on the right.
//@param _t (table) Target table.
//@param _r (int) Row index.
//@param _name (string) Row name.
//@param _val (string) Row value.
//@param _col (color) Value colour.
//@param _sz (string) Text size.
//@returns (int) The next free row.
f_row(table _t, int _r, string _name, string _val, color _col, string _sz) =>
    table.cell(_t, 0, _r, _name, text_color = C_INK, bgcolor = color.white, text_size = _sz, text_halign = text.align_left, text_font_family = font.family_monospace, text_formatting = text.format_italic)
    table.cell(_t, 1, _r, _val, text_color = _col, bgcolor = color.white, text_size = _sz, text_halign = text.align_right, text_font_family = font.family_monospace, text_formatting = text.format_bold)
    _r + 1

//@variable Resolved session-label size, driven by the Session Label Size input.
lblSize = f_size(lblSizeIn)

//@function Zero-padded DD/MM date stamp (e.g. "06/07") for a bar time, in the session timezone.
//@param _t (int) Bar time.
//@returns (string) Day/month string.
f_datestamp(int _t) =>
    int d = dayofmonth(_t, tz)
    int m = month(_t, tz)
    (d < 10 ? '0' : '') + str.tostring(d) + '/' + (m < 10 ? '0' : '') + str.tostring(m)

//==================================================
// Session engine — keeps the last N days of each session's high/low,
// each extending from its origin until mitigated, then dimmed.
//==================================================
//@type A stored session level (high or low) with its drawing objects and mitigation state.
type SLvl
    float price
    int   originT
    bool  isHigh
    bool  mit
    int   freezeT
    line  ln
    label lb

//@type A session's reported high/low and their mitigation state (dashboard read).
type SessOut
    float hi
    float lo
    bool  hiMit
    bool  loMit

//@function Draws and maintains a session's high/low levels across the configured days back.
//@param _show (bool) Whether this session is drawn and reported.
//@param _core (string) Core session window.
//@param _carry (string) Carry-over window tracked after the core session.
//@param _useCarry (bool) Whether to include the carry window.
//@param _col (color) Line and label colour.
//@param _nameH (string) High label text.
//@param _nameL (string) Low label text.
//@returns (SessOut) Current-day high, low, and their mitigation state.
f_session(bool _show, string _core, string _carry, bool _useCarry, color _col, string _nameH, string _nameL) =>
    coreIn = in_session(_core)
    coreStart = coreIn and not coreIn[1]
    carryIn = in_session(_carry)
    trackIn = coreIn or _useCarry and carryIn

    var array<SLvl> store = array.new<SLvl>()
    var SLvl curH = na
    var SLvl curL = na

    // New session — retire the prior labels, open two fresh levels, prune to the days-back window
    if coreStart
        string ds = f_datestamp(time)
        line hLn = _show ? line.new(time, high, time, high, xloc = xloc.bar_time, color = _col, width = lineW) : na
        label hLb = _show and showSessLabels ? label.new(time, high, _nameH + '  ' + ds, xloc = xloc.bar_time, style = label.style_label_down, color = color.new(color.white, 100), textcolor = _col, size = lblSize) : na
        line lLn = _show ? line.new(time, low, time, low, xloc = xloc.bar_time, color = _col, width = lineW) : na
        label lLb = _show and showSessLabels ? label.new(time, low, _nameL + '  ' + ds, xloc = xloc.bar_time, style = label.style_label_up, color = color.new(color.white, 100), textcolor = _col, size = lblSize) : na
        curH := SLvl.new(high, time, true, false, na, hLn, hLb)
        curL := SLvl.new(low, time, false, false, na, lLn, lLb)
        array.push(store, curH)
        array.push(store, curL)

        while array.size(store) > (sessDaysBack + 1) * 2
            SLvl retired = array.shift(store)
            if not na(retired.ln)
                line.delete(retired.ln)
            if not na(retired.lb)
                label.delete(retired.lb)

    // Track the current session's extremes and the candles that formed them
    if trackIn and not na(curH)
        if high > curH.price
            curH.price := high
            curH.originT := time
        if low < curL.price
            curL.price := low
            curL.originT := time

    // Mitigation + right-edge extension for every stored level
    if array.size(store) > 0
        for i = 0 to array.size(store) - 1
            SLvl lv = array.get(store, i)
            bool isCur = i >= array.size(store) - 2
            if not lv.mit and not (trackIn and isCur)
                if lv.isHigh and high >= lv.price
                    lv.mit := true
                    lv.freezeT := time
                else if not lv.isHigh and low <= lv.price
                    lv.mit := true
                    lv.freezeT := time
            int x2 = lv.mit ? lv.freezeT : time
            if not na(lv.ln)
                line.set_xy1(lv.ln, f_xClamp(lv.originT), lv.price)
                line.set_xy2(lv.ln, x2, lv.price)
                line.set_color(lv.ln, lv.mit ? color.new(_col, dimTransp) : _col)
            if not na(lv.lb)
                label.set_xy(lv.lb, lv.originT, lv.price)
                label.set_textcolor(lv.lb, lv.mit ? color.new(_col, dimTransp) : _col)

    SessOut.new(_show and not na(curH) ? curH.price : na, _show and not na(curL) ? curL.price : na, _show and not na(curH) ? curH.mit : false, _show and not na(curL) ? curL.mit : false)

//==================================================
// Apply sessions
//==================================================
asia = f_session(showAsia, asiaCore, asiaCarrySess, useAsiaCarry, asiaCol, 'ASIA.H', 'ASIA.L')
lon = f_session(showLon, lonCore, lonCarrySess, useLonCarry, lonCol, 'LON.H', 'LON.L')
ny = f_session(showNy, nyCore, nyCarrySess, useNYCarry, nyCol, 'NY.H', 'NY.L')
f_session(showNyLunch, nyLunchCore, nyLunchCore, false, nyCol, 'NYL.H', 'NYL.L')
f_session(showNyPm, nyPmCore, nyPmCore, false, nyCol, 'NYP.H', 'NYP.L')

//==================================================
// 12am Opening Range engine
//   • Boxes the 00:00–00:30 NY candle range
//   • Projects the range high/low from their wick extreme
//   • Levels hold until a body closes through them or London KZ closes (05:00)
//   • Keeps the current day + up to 5 prior days
//==================================================
morIn = not na(time(timeframe.period, morSess, tz))
morStart = morIn and not morIn[1]
morEnd = not morIn and morIn[1]
morActive = not na(time(timeframe.period, morActiveSess, tz))

var float morHigh = na
var float morLow = na
var int morHighT = na
var int morLowT = na
var int morLeftT = na
var bool morHiTaken = false
var bool morLoTaken = false

var array<box> morBoxes = array.new<box>()
var array<line> morHighLns = array.new<line>()
var array<line> morLowLns = array.new<line>()
var array<label> morLabels = array.new<label>()
var array<label> morHiLbls = array.new<label>()
var array<label> morLoLbls = array.new<label>()

// Open a fresh range at 00:00
if useMOR and morStart
    morHigh := high
    morLow := low
    morHighT := time
    morLowT := time
    morLeftT := time
    morHiTaken := false
    morLoTaken := false

// Track the extremes and the candles that formed them
if useMOR and morIn
    if na(morHigh) or high > morHigh
        morHigh := high
        morHighT := time
        morHighT
    if na(morLow) or low < morLow
        morLow := low
        morLowT := time
        morLowT

// Finalise the range at 00:30 — draw box, wick-anchored levels and centred label
if useMOR and morEnd and not na(morHigh) and not na(morLow) and not na(morLeftT)
    morRightT = time
    centerX = int(math.avg(morLeftT, morRightT))
    centerY = math.avg(morHigh, morLow)

    newBox = box.new(morLeftT, morHigh, morRightT, morLow, xloc = xloc.bar_time, border_color = morBoxCol, border_width = 1, border_style = line.style_solid, bgcolor = morBoxCol)
    newHi = line.new(morHighT, morHigh, morRightT, morHigh, xloc = xloc.bar_time, color = morLineCol, width = morLineW, style = line.style_solid)
    newLo = line.new(morLowT, morLow, morRightT, morLow, xloc = xloc.bar_time, color = morLineCol, width = morLineW, style = line.style_solid)
    newLbl = label.new(centerX, centerY, '12am', xloc = xloc.bar_time, style = label.style_none, textcolor = morTxtCol, size = size.small, textalign = text.align_center)
    label.set_text_font_family(newLbl, font.family_monospace)

    newHiLbl = label.new(morHighT, morHigh, '12am.H', xloc = xloc.bar_time, style = label.style_label_down, color = color.new(color.white, 100), textcolor = morLineCol, size = lblSize)
    label.set_text_font_family(newHiLbl, font.family_monospace)
    newLoLbl = label.new(morLowT, morLow, '12am.L', xloc = xloc.bar_time, style = label.style_label_up, color = color.new(color.white, 100), textcolor = morLineCol, size = lblSize)
    label.set_text_font_family(newLoLbl, font.family_monospace)

    array.push(morBoxes, newBox)
    array.push(morHighLns, newHi)
    array.push(morLowLns, newLo)
    array.push(morLabels, newLbl)
    array.push(morHiLbls, newHiLbl)
    array.push(morLoLbls, newLoLbl)

    // Keep only the current day + morDaysBack prior days
    while array.size(morBoxes) > morDaysBack + 1
        box.delete(array.shift(morBoxes))
        line.delete(array.shift(morHighLns))
        line.delete(array.shift(morLowLns))
        label.delete(array.shift(morLabels))
        label.delete(array.shift(morHiLbls))
        label.delete(array.shift(morLoLbls))

// Extend each level from its wick extreme until a body closes through it, or until 05:00 (London KZ close)
if useMOR and morActive and not morIn and array.size(morHighLns) > 0
    if not morHiTaken
        line.set_x2(array.last(morHighLns), time)
        if barstate.isconfirmed and close > morHigh
            morHiTaken := true
            line.set_color(array.last(morHighLns), color.new(morLineCol, dimTransp))
            label.set_textcolor(array.last(morHiLbls), color.new(morLineCol, dimTransp))
    if not morLoTaken
        line.set_x2(array.last(morLowLns), time)
        if barstate.isconfirmed and close < morLow
            morLoTaken := true
            line.set_color(array.last(morLowLns), color.new(morLineCol, dimTransp))
            label.set_textcolor(array.last(morLoLbls), color.new(morLineCol, dimTransp))

//==================================================
// Dashboard — daily direction, PD array bias, session liquidity, ADR
//==================================================
[dHigh, dLow] = request.security(syminfo.tickerid, 'D', [high, low])
pdTf = pdRangeIn == 'Previous Week' ? 'W' : pdRangeIn == 'Previous Month' ? 'M' : 'D'
[pdHigh, pdLow] = request.security(syminfo.tickerid, pdTf, [high[1], low[1]], lookahead = barmerge.lookahead_on)
adrN = request.security(syminfo.tickerid, 'D', ta.sma(high - low, adrDaysIn)[1], lookahead = barmerge.lookahead_on)

// Midnight open (00:00 true day open) and prior-range sweep state — reset each NY day.
// The Sunday 18:00 reopen also changes the calendar date; it is a session open, not a
// midnight, so the midnight open only takes a bar that opens before 18:00.
bool newDay = dayofmonth(time, tz) != dayofmonth(time[1], tz)
bool isMidnight = newDay and hour(time, tz) < 18
var float midOpen = na
var bool pdhSwept = false
var bool pdlSwept = false
if newDay
    pdhSwept := false
    pdlSwept := false

var array<line> moLines = array.new<line>()
var array<label> moLabels = array.new<label>()
var array<int> moDays = array.new<int>()

if isMidnight
    midOpen := open
    if useMO
        // Retire the prior line where the new day begins: stop it, dot it, date it
        if array.size(moLines) > 0
            line prevLn = array.last(moLines)
            label prevLb = array.last(moLabels)
            line.set_x2(prevLn, time)
            line.set_style(prevLn, line.style_dotted)
            label.set_x(prevLb, time)
            label.set_text(prevLb, 'Midnight Open  ' + f_datestamp(array.last(moDays)))
        line moLn = line.new(time, open, time, open, xloc = xloc.bar_time, color = moCol, width = moW, style = line.style_dotted)
        label moLb = label.new(time, open, 'Midnight Open', xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.white, 100), textcolor = moCol, size = lblSize, textalign = text.align_left)
        label.set_text_font_family(moLb, font.family_monospace)
        array.push(moLines, moLn)
        array.push(moLabels, moLb)
        array.push(moDays, time)
        while array.size(moLines) > moDaysBack + 1
            line.delete(array.shift(moLines))
            label.delete(array.shift(moLabels))
            array.shift(moDays)

// Today's line runs with price; its name rides at the right end
if useMO and not isMidnight and array.size(moLines) > 0
    line.set_x2(array.last(moLines), time)
    label.set_x(array.last(moLabels), time)
if not na(pdHigh) and high >= pdHigh
    pdhSwept := true
if not na(pdLow) and low <= pdLow
    pdlSwept := true

const int DASH_ROWS = 24
var table dash = na

if barstate.islast and showDash
    string dashSize = f_size(dashSizeIn)

    // Premium/discount — equilibrium is 50% of the prior period's dealing range (day/week/month)
    float dayEQ = na(pdHigh) or na(pdLow) ? na : math.avg(pdHigh, pdLow)
    string hiLbl = pdRangeIn == 'Previous Week' ? 'PWH' : pdRangeIn == 'Previous Month' ? 'PMH' : 'PDH'
    string loLbl = pdRangeIn == 'Previous Week' ? 'PWL' : pdRangeIn == 'Previous Month' ? 'PML' : 'PDL'

    // Daily direction reads against the midnight open; premium/discount against the dealing range
    string dirTxt = na(midOpen) ? '—' : close > midOpen ? 'bullish' : close < midOpen ? 'bearish' : 'neutral'
    color dirCol = not dashColour or na(midOpen) ? C_INK : close > midOpen ? bullCol : close < midOpen ? bearCol : neutCol
    string eqTxt = na(dayEQ) ? '—' : close > pdHigh ? 'above ' + hiLbl : close < pdLow ? 'below ' + loLbl : close >= dayEQ ? 'premium' : 'discount'

    // Bias — depth into the dealing range sets the lean; the midnight open confirms strength.
    // Neutral only when price sits inside the equilibrium band (balanced); otherwise it always leans.
    bool belowMid = not na(midOpen) and close < midOpen
    bool aboveMid = not na(midOpen) and close > midOpen
    float rangeH = na(pdHigh) or na(pdLow) ? na : pdHigh - pdLow
    float depth = na(dayEQ) or na(rangeH) or rangeH == 0 ? na : (close - dayEQ) / rangeH
    float tol = biasBandIn / 100.0

    string biasTxt = 'neutral'
    color biasCol = neutCol
    if not na(depth) and depth <= -tol
        biasTxt := belowMid ? 'bullish' : 'lean bullish'
        biasCol := bullCol
    else if not na(depth) and depth >= tol
        biasTxt := aboveMid ? 'bearish' : 'lean bearish'
        biasCol := bearCol

    // ADR and its projection off today's extremes
    float projHigh = na(adrN) or na(dLow) ? na : dLow + adrN
    float projLow = na(adrN) or na(dHigh) ? na : dHigh - adrN
    string adrUsed = na(adrN) or adrN == 0 or na(dHigh) or na(dLow) ? '—' : str.tostring(math.round((dHigh - dLow) / adrN * 100)) + '% used'
    float morRng = na(morHigh) or na(morLow) ? na : morHigh - morLow
    color biasInk = dashColour ? biasCol : C_INK

    if na(dash)
        dash := table.new(f_pos(dashPosIn), 2, DASH_ROWS, bgcolor = color.white, frame_width = 1, frame_color = C_INK, border_width = 1, border_color = C_INK)

    // Rows with nothing to report are dropped, so the row count moves — wipe before writing
    table.clear(dash, 0, 0, 1, DASH_ROWS - 1)
    int r = 0

    r := f_head(dash, r, 'Sessions+', dashSize)
    r := f_row(dash, r, 'Bias', biasTxt, biasInk, dashSize)
    if not na(midOpen)
        r := f_row(dash, r, 'Daily direction', dirTxt, dirCol, dashSize)

    if not na(dayEQ)
        r := f_head(dash, r, 'PREMIUM / DISCOUNT', dashSize)
        r := f_row(dash, r, 'EQ 50%', f_px(dayEQ) + '  ' + eqTxt, C_INK, dashSize)
        r := f_row(dash, r, hiLbl, f_lvl(pdHigh, pdhSwept, 'swept'), f_lc(pdhSwept), dashSize)
        r := f_row(dash, r, loLbl, f_lvl(pdLow, pdlSwept, 'swept'), f_lc(pdlSwept), dashSize)

    if not (na(asia.hi) and na(lon.hi) and na(ny.hi))
        r := f_head(dash, r, 'LIQUIDITY TODAY', dashSize)
        if not na(asia.hi)
            r := f_row(dash, r, 'Asia high', f_lvl(asia.hi, asia.hiMit, 'swept'), f_lc(asia.hiMit), dashSize)
            r := f_row(dash, r, 'Asia low', f_lvl(asia.lo, asia.loMit, 'swept'), f_lc(asia.loMit), dashSize)
        if not na(lon.hi)
            r := f_row(dash, r, 'London high', f_lvl(lon.hi, lon.hiMit, 'swept'), f_lc(lon.hiMit), dashSize)
            r := f_row(dash, r, 'London low', f_lvl(lon.lo, lon.loMit, 'swept'), f_lc(lon.loMit), dashSize)
        if not na(ny.hi)
            r := f_row(dash, r, 'NY high', f_lvl(ny.hi, ny.hiMit, 'swept'), f_lc(ny.hiMit), dashSize)
            r := f_row(dash, r, 'NY low', f_lvl(ny.lo, ny.loMit, 'swept'), f_lc(ny.loMit), dashSize)

    if not na(adrN)
        r := f_head(dash, r, 'ADR ' + str.tostring(adrDaysIn) + 'D', dashSize)
        r := f_row(dash, r, 'ADR', f_px(adrN) + '  ' + adrUsed, C_INK, dashSize)
        if not (na(dHigh) or na(dLow))
            r := f_row(dash, r, 'Day range', f_px(dHigh - dLow), C_INK, dashSize)
            r := f_row(dash, r, 'Projected high', f_px(projHigh) + '  ' + f_dist(projHigh, close), C_INK, dashSize)
            r := f_row(dash, r, 'Projected low', f_px(projLow) + '  ' + f_dist(projLow, close), C_INK, dashSize)

if barstate.islast and not showDash and not na(dash)
    table.delete(dash)
    dash := na
````
