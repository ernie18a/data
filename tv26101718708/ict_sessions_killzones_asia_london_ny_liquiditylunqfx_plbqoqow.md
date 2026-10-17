# ICT Sessions & Killzones - Asia London NY + Liquidity[LunqFX]

- url: https://www.tradingview.com/script/plbqOqoW-ICT-Sessions-Killzones-Asia-London-NY-Liquidity-LunqFX/
- type: indicator
- pine_id: PUB;4a778454a82a46c8a46bd74c5b8db6e4
- version: 1.0

## Description

ICT Sessions & Killzones is a modern smart-money session indicator for TradingView that maps the three global trading sessions — Asia, London and New York — as clean, colour-coded ranges and, unlike most session tools, automatically detects liquidity sweeps: the exact moment price raids a previous session's high or low and rejects it. It turns the daily rhythm of the market — the ICT killzones, session opens, and the liquidity pools left behind — into a clear, actionable map. Works on forex, crypto, indices, futures and gold (XAUUSD), on any intraday timeframe. Built in Pine Script v6. Keywords: ICT, killzones, sessions, Asia session, London session, New York session, liquidity, liquidity sweep, stop hunt, smart money concepts, SMC, session high low, opening range, forex, crypto, day trading, scalping.

◆ WHY SESSIONS MATTER
Price does not move randomly — it moves in sessions. Asia sets the range, London expands it, New York reverses or continues it. The highs and lows each session leaves behind become liquidity pools — resting stop orders that smart money targets. Knowing where those levels are, which session is active, and when a level gets swept is the core of session-based and ICT trading. This tool puts all of that on your chart automatically.

◆ WHAT IT DRAWS
Session boxes — Asia (violet), London (teal) and New York (gold) ranges drawn automatically from each session's high and low, kept across history so you can study the pattern.
Previous-session liquidity levels — the last completed session's high and low extended forward as dashed lines. These are the magnets price hunts next.
Liquidity sweep markers — a compact, colour-coded arrow (▲/▼ with the session code A / L / NY) printed when price wicks beyond a prior session extreme and closes back inside — a real stop-raid / rejection. Hover any marker for the full detail.
Neon gradient candles — turquoise up / magenta down, intensity scaled by momentum.

◆ THE LIVE DASHBOARD
A clean, colour-railed panel that reads the sessions at a glance:

[image]https://www.tradingview.com/x/aoNiDIct/[/image]

Active session — which session is open right now (● marks any that are live; London and New York overlap in real hours, so both can be active).
Range per session — each session's high–low.
Range in pips — how far each session actually moved.
★ Widest range — the session that dominated the day (the "power session").
Timezone readout, fully themeable, adjustable text size.

◆ HOW IT WORKS
Every bar is assigned to a session from its own timestamp (no repainting from higher-timeframe data). The session's running high and low build the box in real time. When a new session opens, the previous session's extremes are locked in as liquidity levels. A liquidity sweep is flagged only when price trades beyond a prior session's high/low and then closes back inside it — a genuine rejection — so a clean break straight through does not trigger a false signal. This keeps the chart clean and every sweep meaningful.

◆ HOW TO USE IT
Trade the killzones. The London and New York opens produce the biggest, cleanest moves — focus your entries there.
Use prior session highs/lows as targets. Untapped levels act as magnets; price often runs them before reversing.
Fade or follow sweeps. When a sweep prints, the raid has taken liquidity — fade it back into range, or trade the reversal in the opposite direction.
Read the dashboard for context. Know which session is active and which had the widest range before you commit.
Set your times/timezone. Adjust each session's hours and the timezone in the settings to match your market and broker.
Combine with your own market structure, order blocks or bias for higher-probability confluence.
◆ SETTINGS
Session times & colours (Asia / London / New York), timezone, session boxes (soft fill or outline), previous-session levels with adjustable extension, liquidity sweep markers, neon candles, and a dashboard (show/hide, position, text size, background).

◆ ALERTS
Liquidity sweep — fires when any previous-session high or low is swept.

◆ LIMITATIONS
Sessions are an intraday concept — use a 1m to 4h timeframe. On daily or higher the panel shows a reminder and no sessions are drawn.
Default session times are in GMT; set the timezone and hours to match your instrument and broker feed, as session boundaries vary by symbol.
A liquidity sweep shows that a level was raided and rejected — it is context and confluence, not a standalone buy/sell signal.
Session ranges reflect the data of your chart's feed; different brokers can differ slightly.
◆ ORIGINALITY & NON-REPAINTING
Original work — the session engine, the rejection-based liquidity-sweep detection, the previous-session liquidity levels and the dashboard are all my own implementation; no third-party code is used. Sessions and levels are built from each bar's own timestamp with no higher-timeframe lookahead, so a sweep printed on a closed bar stays.

Educational analysis tool, not financial advice. Trading involves risk. Always do your own research and manage risk. © LunqFX.

## Source Code

````pine
//@version=6
// ============================================================================
//  Sessions & Killzones - Asia London New York + Liquidity Sweeps [LunqFX]
// ----------------------------------------------------------------------------
//  The market moves in sessions. Where Asia, London and New York open and close
//  - and the highs/lows they leave behind - are the liquidity pools price hunts
//  next. This tool maps the three global sessions as clean neon ranges and then
//  does what most session tools don't: it flags LIQUIDITY SWEEPS - the moment
//  price runs the previous session's high or low (a classic smart-money stop
//  raid) so you can fade the grab or trade the reversal.
//
//  • Auto session ranges (Asia / London / New York) as glowing boxes with H/L.
//  • Previous-session high & low drawn as live liquidity levels.
//  • SWEEP markers when price takes a prior session extreme.
//  • Live dashboard: active session, each session's range, and the last sweep.
//
//  Works on forex, crypto, indices and futures, on any intraday timeframe.
//
//  NON-REPAINTING: sessions come from the bar's own timestamp and levels are
//  confirmed on closed sessions; a printed sweep on a closed bar stays.
// ============================================================================
indicator("ICT Sessions & Killzones - Asia London New York + Liquidity Sweeps", "ICT Sessions & Killzones [LunqFX]", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE
// ─────────────────────────────────────────────────────────────────────────
TEAL_MID = #12B8A6
TEAL_HI  = #4DFCE6
PINK_MID = #FF2E63
PINK_HI  = #FF6FA3
VIOLET   = #A855F7
GOLD     = #FFB938
AMBER    = #FF9F45
MUTE     = #5C6675
INKHI    = #EAEEF6
CARDBG   = #0A0D14

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
tz       = input.string("GMT", "Session timezone", options = ["GMT","GMT-5","GMT-4","GMT+1","GMT+2","GMT+3","GMT+8","GMT+9"], group = "General")
showBox  = input.bool(true, "Session boxes", group = "General")
boxStyle = input.string("Soft fill", "Box style", options = ["Soft fill","Outline"], group = "General")
showLvl  = input.bool(true, "Previous session H/L levels", group = "General")
showSwp  = input.bool(true, "Liquidity sweep markers", group = "General")
ext      = input.int(30, "Level extend (bars)", minval = 0, maxval = 200, group = "General")

gA = "Asia"
enA = input.bool(true, "Show Asia", inline = "a", group = gA)
seA = input.session("0000-0800", "", inline = "a", group = gA)
coA = input.color(VIOLET, "", inline = "a", group = gA)

gL = "London"
enL = input.bool(true, "Show London", inline = "l", group = gL)
seL = input.session("0700-1600", "", inline = "l", group = gL)
coL = input.color(TEAL_MID, "", inline = "l", group = gL)

gN = "New York"
enN = input.bool(true, "Show New York", inline = "n", group = gN)
seN = input.session("1200-2100", "", inline = "n", group = gN)
coN = input.color(GOLD, "", inline = "n", group = gN)

gC = "Candles"
neonOn = input.bool(true, "Neon gradient candles", group = gC)

gP = "Panel"
showHUD = input.bool(true, "Show dashboard", group = gP)
txtSize = input.string("Large","Text size", options = ["Normal","Large","Huge"], group = gP)
hudPos  = input.string("Top Right","Position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gP)
hudBg   = input.color(#0C0F16, "Background", group = gP)

// ─────────────────────────────────────────────────────────────────────────
//  HELPERS + SESSION TYPE
// ─────────────────────────────────────────────────────────────────────────
hudPosition(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.middle_right

f_px(float v) => str.tostring(v, format.mintick)

f_sz(string s) => s == "Huge" ? size.huge : s == "Normal" ? size.normal : size.large

type Sess
    string name
    string sess
    color  col
    bool   en
    float  hi     = na
    float  lo     = na
    int    startB = na
    box    cur    = na
    float  pHi    = na
    float  pLo    = na
    line   pHiLn  = na
    line   pLoLn  = na
    bool   inS    = false
    bool   armHi  = false
    bool   armLo  = false
    bool   swHi   = false
    bool   swLo   = false
    bool   fired  = false

var array<Sess> sess = array.new<Sess>()
if barstate.isfirst
    array.push(sess, Sess.new("Asia",     seA, coA, enA))
    array.push(sess, Sess.new("London",   seL, coL, enL))
    array.push(sess, Sess.new("New York", seN, coN, enN))

// per-session engine (mutates the session object)
f_run(Sess s) =>
    s.fired := false
    inNow = not na(time(timeframe.period, s.sess, tz))
    if s.en
        if inNow and not s.inS
            // new session starts -> finalize previous, arm sweeps, open a box
            s.pHi := s.hi
            s.pLo := s.lo
            s.armHi := not na(s.pHi)
            s.armLo := not na(s.pLo)
            s.swHi := false
            s.swLo := false
            s.hi := high
            s.lo := low
            s.startB := bar_index
            if showBox
                s.cur := box.new(bar_index, high, bar_index, low, border_color = color.new(s.col, 20), border_width = 1, bgcolor = boxStyle == "Outline" ? color.new(s.col, 100) : color.new(s.col, 82))
        else if inNow
            s.hi := math.max(s.hi, high)
            s.lo := math.min(s.lo, low)
            if showBox and not na(s.cur)
                box.set_right(s.cur, bar_index)
                box.set_top(s.cur, s.hi)
                box.set_bottom(s.cur, s.lo)
        s.inS := inNow

        // previous-session liquidity levels
        if showLvl and not na(s.pHi)
            if na(s.pHiLn)
                s.pHiLn := line.new(bar_index, s.pHi, bar_index, s.pHi, color = s.col, width = 1, style = line.style_dashed)
                s.pLoLn := line.new(bar_index, s.pLo, bar_index, s.pLo, color = s.col, width = 1, style = line.style_dashed)
            line.set_xy1(s.pHiLn, s.startB, s.pHi)
            line.set_xy2(s.pHiLn, bar_index + ext, s.pHi)
            line.set_xy1(s.pLoLn, s.startB, s.pLo)
            line.set_xy2(s.pLoLn, bar_index + ext, s.pLo)

        // liquidity sweep = wick BEYOND the prior extreme, then CLOSE back inside
        // (a real stop-raid / rejection). A clean break the other way just disarms.
        // Compact label: session code + arrow, small; hover for full detail.
        // sweeps are locked in only on a CLOSED bar so a marker never repaints
        code = s.name == "New York" ? "NY" : str.substring(s.name, 0, 1)
        if showSwp and not na(s.pHi) and barstate.isconfirmed
            if s.armHi and high > s.pHi
                if close < s.pHi
                    label.new(bar_index, high, "▼ " + code, style = label.style_label_down, color = color.new(s.col, 0), textcolor = #0B0E14, size = size.normal, tooltip = s.name + " sweep — prior high " + f_px(s.pHi) + " raided then rejected")
                    s.swHi := true
                    s.fired := true
                s.armHi := false
            if s.armLo and low < s.pLo
                if close > s.pLo
                    label.new(bar_index, low, "▲ " + code, style = label.style_label_up, color = color.new(s.col, 0), textcolor = #0B0E14, size = size.normal, tooltip = s.name + " sweep — prior low " + f_px(s.pLo) + " raided then rejected")
                    s.swLo := true
                    s.fired := true
                s.armLo := false

isIntraday = timeframe.isintraday
if (barstate.isconfirmed or barstate.islast) and isIntraday
    for i = 0 to array.size(sess) - 1
        f_run(array.get(sess, i))

// ─────────────────────────────────────────────────────────────────────────
//  NEON GRADIENT CANDLES
// ─────────────────────────────────────────────────────────────────────────
mom   = math.abs(close - open)
atr14 = ta.atr(14)
strn  = atr14 > 0 ? math.min(1.0, mom / atr14) : 0.0
upC   = color.from_gradient(strn, 0, 1, TEAL_MID, TEAL_HI)
dnC   = color.from_gradient(strn, 0, 1, PINK_MID, PINK_HI)
bull  = close >= open
plotcandle(neonOn ? open : na, high, low, close, "Neon", color = bull ? upC : dnC, wickcolor = bull ? TEAL_HI : PINK_HI, bordercolor = bull ? TEAL_HI : PINK_HI)

// ─────────────────────────────────────────────────────────────────────────
//  DASHBOARD
// ─────────────────────────────────────────────────────────────────────────
var table hud = na
if showHUD and barstate.islast
    if not na(hud)
        table.delete(hud)

    SURF  = color.new(hudBg, 0)
    HEADR = color.new(color.from_gradient(0.5, 0, 1, hudBg, #161C28), 0)
    bsz   = f_sz(txtSize)

    if not isIntraday
        // clear notice on daily+ (sessions are an intraday concept)
        hud := table.new(hudPosition(hudPos), 2, 1, bgcolor = color.new(hudBg, 0), border_width = 0, frame_color = color.new(GOLD, 40), frame_width = 1)
        table.cell(hud, 0, 0, "  ", bgcolor = GOLD)
        table.cell(hud, 1, 0, "  SESSIONS & KILLZONES — switch to an intraday timeframe (1m–4h)  ", text_color = GOLD, text_size = bsz, text_halign = text.align_left, bgcolor = HEADR)
    else
        // active session + widest-range ("power") session
        activeName = "—"
        activeCol = MUTE
        wIdx = -1
        wRange = 0.0
        for i = 0 to array.size(sess) - 1
            s = array.get(sess, i)
            if s.en and s.inS
                activeName := s.name
                activeCol := s.col
            if s.en and not na(s.hi) and not na(s.lo) and (s.hi - s.lo) > wRange
                wRange := s.hi - s.lo
                wIdx := i

        pipMult = syminfo.mintick * 10
        cardBg  = color.new(CARDBG, 0)
        headBg  = color.new(color.from_gradient(0.5, 0, 1, CARDBG, #1A2234), 0)

        hud := table.new(hudPosition(hudPos), 4, 5, bgcolor = cardBg, border_width = 0, frame_color = color.new(#242C3C, 0), frame_width = 1)

        table.cell(hud, 0, 0, "  ", bgcolor = activeCol)
        table.cell(hud, 1, 0, "  SESSIONS  &  KILLZONES", text_color = INKHI, text_size = bsz, text_halign = text.align_left, bgcolor = headBg)
        table.cell(hud, 2, 0, "", bgcolor = headBg)
        table.cell(hud, 3, 0, activeName + "  ", text_color = activeCol, text_size = bsz, text_halign = text.align_right, bgcolor = headBg)

        r = 1
        for i = 0 to array.size(sess) - 1
            s = array.get(sess, i)
            if s.en
                hasR   = not na(s.hi) and not na(s.lo)
                rngTxt = hasR ? f_px(s.lo) + " – " + f_px(s.hi) : "—"
                pipTxt = hasR ? str.tostring(math.round((s.hi - s.lo) / pipMult)) + "p" : "—"
                swTxt  = s.swHi and s.swLo ? " ⇅" : s.swHi ? " ▲" : s.swLo ? " ▼" : ""
                star   = i == wIdx ? "  ★" : ""
                table.cell(hud, 0, r, "  ", bgcolor = s.col)
                table.cell(hud, 1, r, "  " + s.name + (s.inS ? "  ●" : "") + star, text_color = s.inS ? INKHI : MUTE, text_size = bsz, text_halign = text.align_left, bgcolor = cardBg)
                table.cell(hud, 2, r, rngTxt, text_color = INKHI, text_size = bsz, text_halign = text.align_right, bgcolor = cardBg)
                table.cell(hud, 3, r, pipTxt + swTxt + "  ", text_color = s.swHi or s.swLo ? PINK_HI : s.col, text_size = bsz, text_halign = text.align_right, bgcolor = cardBg)
                r += 1

        table.cell(hud, 0, 4, "  ", bgcolor = MUTE)
        table.cell(hud, 1, 4, "  ★ widest range", text_color = MUTE, text_size = bsz, text_halign = text.align_left, bgcolor = headBg)
        table.cell(hud, 2, 4, "", bgcolor = headBg)
        table.cell(hud, 3, 4, tz + "  ", text_color = MUTE, text_size = bsz, text_halign = text.align_right, bgcolor = headBg)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────
swpAny = false
for i = 0 to array.size(sess) - 1
    if array.get(sess, i).fired
        swpAny := true
alertcondition(swpAny, "Liquidity sweep", "A previous-session high or low was swept")
````
