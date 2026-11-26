# Opening Range Breakout ORB - Signals, Targets & Alerts [LunqFX]

- url: https://www.tradingview.com/script/WRd9PpxL-Opening-Range-Breakout-ORB-Signals-Targets-Alerts-LunqFX/
- type: indicator
- pine_id: PUB;4a70422d8e6648dbb3fdc85cf96a2fe3
- version: 1.0

## Description

The Opening Range Breakout (ORB) is one of the most traded intraday strategies — but most ORB indicators only draw the opening range box and leave you guessing. This Opening Range Breakout indicator goes further: it marks the opening range, detects the first genuine breakout, filters fakeouts, projects measured-move targets, and — uniquely — builds a live breakout statistics engine from the last 100 trading days of the symbol on your chart.

[b]What makes this ORB indicator different[/b]

Instead of a static box, you get a data-driven read on how your market actually behaves after the opening range:

First-break direction split — how often the day breaks up vs down
Hold rate — how often the first breakout direction holds into the close
Fakeout rate — how often the first breakout fails back inside the range
Target hit rates — how often price reaches 1x and 2x the opening-range height
So before you take the trade you can see, for example, that on this symbol the upside breakout holds into the close 62% of the time and the 1R target is reached on 48% of breakout days.

[b]How the opening range breakout is calculated[/b]

Auto mode works on every market with zero setup. The opening range starts at each day's open of the symbol's own exchange — stocks at the 09:30 session open, crypto at the 00:00 UTC daily open, forex and futures at their session open — and lasts a chosen number of minutes (the classic 5-minute, 15-minute or 30-minute ORB). A Custom mode lets you define any session window, such as the London or New York open.
When the opening-range window closes, the range high and low are locked and projected forward as levels.
The first candle close beyond the range (or wick, if you prefer) is treated as the breakout. Targets are projected at 1x and 2x the range height in the breakout direction.
A close back inside the range before the first target is reached is flagged as a fakeout. A breakout that reaches 1R first and only then returns is counted as a valid breakout, not a fakeout.

At the end of each trading day the outcome is recorded — direction, hold, fakeout, targets — and the dashboard percentages are plain rolling hit rates. No repainting, no curve fitting.
How to use it

Breakout day trading: trade the first breakout with more context — use the hold rate to judge whether the break on your symbol is worth taking, and size your target from the 1R / 2R hit rates.

Fakeout fade: when a symbol shows a high fakeout rate, the failed breakout back inside the range is often the better setup; the fakeout is marked in real time.
Range-quality filter: the dashboard shows the opening range as a multiple of ATR, so you can skip abnormally small ranges that tend to break out randomly.
Works on any symbol and any intraday timeframe (1m–15m recommended): index futures and CFDs (NAS100, SPX500, US30, NQ, ES), stocks and ETFs (SPY, QQQ), gold (XAUUSD), Bitcoin and crypto, and forex majors.

[b]Dashboard[/b]
[image]https://www.tradingview.com/x/NMxe6hw5/[/image]


A clean on-chart panel shows today's live status (building range → inside range → breakout → target hit or fakeout), the opening-range high/low and its size in ATR, and the full statistics block with the sample size always visible.

[b]Settings[/b]

Auto anchor (any market, zero setup) or fully custom session window with timezone control — 5 / 15 / 30-minute ORB or any session open
Close-based or wick-based breakout logic
Adjustable target multiples, rolling statistics window, and visuals
Alerts for range locked, breakout up, breakout down, fakeout, target 1 and target 2
Optional gradient momentum candles that can be switched off
No repainting

The opening range is fixed the moment its window closes. Breakouts, fakeouts and targets are confirmed on closed bars only, and the statistics are built exclusively from completed trading days — never recalculated backwards.

This indicator is an educational market-analysis tool, not financial advice. Historical statistics describe past behavior and are not a guarantee of future results. Always confirm with your own analysis and manage your risk.

## Source Code

````pine
//@version=6
// ============================================================================
//  ORB Pro — Opening Range Breakout, Targets & Stats [LunqFX]
// ----------------------------------------------------------------------------
//  Every ORB indicator draws the box. This one tells you how YOUR symbol
//  actually behaves after it. It marks the opening range, detects the first
//  real breakout (close through the level), flags fakeouts, projects 1R / 2R
//  measured-move targets — and builds a statistics engine over the last N
//  trading days:
//
//      • FIRST BREAK direction split      (up % vs down %)
//      • HOLD RATE  — how often the first break direction survives to
//                     the end of the day
//      • FAKEOUT RATE — how often the first break closes back inside
//      • TARGET HIT RATES — how often price reaches 1x / 2x the range
//
//  So instead of "price broke the box", you get "NQ breaks up 57% of days,
//  the break holds into the close 62% of the time, and 1R is hit on 48%
//  of breakout days".
//
//  NON-REPAINTING: the opening range is fixed when its window closes;
//  breakouts, fakeouts and target hits are detected on closed bars only.
//  Statistics are built only from finished days.
// ============================================================================
indicator("Opening Range Breakout ORB - Signals, Targets & Alerts [LunqFX]",
     "ORB [LunqFX]",
     overlay = true, max_boxes_count = 60, max_lines_count = 400, max_labels_count = 300)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE  (LunqFX neon)
// ─────────────────────────────────────────────────────────────────────────
GOLD        = #FFB938
GOLD_HI     = #FFD983
NEON_VIOLET = #B026FF
VIO_MID     = #7A2BD6
VIO_HI      = #D070FF
NEON_TURQ   = #00E5D0
TUR_MID     = #12B8A6
TUR_HI      = #4DFCE6
INK         = #0B0E14
MUTE        = #8B93A3
TXT         = #E6EDF3

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gR      = "Opening Range"
orMode  = input.string("Auto (any market)", "Range anchor", options = ["Auto (any market)","Custom session"], group = gR, tooltip = "AUTO = the range starts at each day's open of THIS symbol's own exchange: stocks 09:30 ET, crypto 00:00 UTC, forex/futures their session open. Works on every pair and market out of the box. CUSTOM = define your own window below (e.g. London open for forex).")
orMin   = input.int(15, "Opening range minutes (Auto)", minval = 1, maxval = 240, group = gR, tooltip = "Classic ORB: 5, 15 or 30 minutes after the open.")
tz      = input.string("America/New_York", "Timezone (Custom)", options = ["America/New_York","UTC","Europe/London","Europe/Berlin","Asia/Tokyo","Asia/Singapore","Australia/Sydney","America/Chicago"], group = gR)
orSes   = input.session("0930-0945", "Opening range window (Custom)", group = gR, tooltip = "Classic ORB windows (New York time): 0930-0935 (5m), 0930-0945 (15m), 0930-1000 (30m).")
dayEnd  = input.session("0930-1600", "Trading day window (Custom)", group = gR, tooltip = "Levels, targets and statistics are tracked inside this window. Stats close out at its end.")

gB      = "Breakout logic"
useWick = input.bool(false, "Wick counts as breakout", group = gB, tooltip = "OFF (default) = a breakout needs a CLOSE beyond the range. ON = a wick through the level is enough. Close-based is cleaner and what the stats are built for.")
tgt1X   = input.float(1.0, "Target 1 (x range)", minval = 0.25, step = 0.25, group = gB)
tgt2X   = input.float(2.0, "Target 2 (x range)", minval = 0.5,  step = 0.25, group = gB)

gV      = "Visuals"
showBox = input.bool(true, "Opening range box",   group = gV)
boxTr   = input.int(86,    "Box fill transparency", minval = 50, maxval = 100, group = gV, tooltip = "The box extends across the whole trading day once the range is locked.")
glowOn  = input.bool(true, "Neon glow",           group = gV)
showTgt = input.bool(true, "Target lines",        group = gV)
showLbl = input.bool(true, "Event labels",        group = gV)
keepN   = input.int(6,     "Past days to keep on chart", minval = 1, maxval = 12, group = gV)

gC      = "Neon Candles"
neonOn  = input.bool(true, "Neon gradient candles", group = gC, tooltip = "Glowing candles: turquoise = bullish, violet = bearish, brightness scales with momentum. The signature LunqFX look.")
neonGlow= input.bool(true, "Glow halo",             group = gC)

gS      = "Statistics engine"
statN   = input.int(100, "Days in stats window", minval = 20, maxval = 500, group = gS, tooltip = "Rolling sample of finished trading days used for all percentages.")

gP      = "Dashboard"
showHUD = input.bool(true, "Show dashboard", group = gP)
hudPos  = input.string("Top Right", "Position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gP)

// ─────────────────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────────────────
hudPosition(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.middle_right

progressBar(float pct) =>
    seg    = 12
    filled = math.round(nz(pct) / 100 * seg)
    out    = ""
    for i = 1 to seg
        out := out + (i <= filled ? "█" : "░")
    out

pctTrue(array<bool> a) =>
    n = array.size(a)
    if n == 0
        float(na)
    else
        c = 0
        for i = 0 to n - 1
            if array.get(a, i)
                c += 1
        100.0 * c / n

pushCap(array<bool> a, bool v, int cap) =>
    array.push(a, v)
    while array.size(a) > cap
        array.shift(a)

atr = ta.atr(14)

// ─────────────────────────────────────────────────────────────────────────
//  SESSION FLAGS
// ─────────────────────────────────────────────────────────────────────────
autoMode = orMode == "Auto (any market)"
dayStart = time("D")                    // this symbol's own trading-day open
inORauto = not na(dayStart) and (time - dayStart) < orMin * 60000
inORcust = not na(time(timeframe.period, orSes,  tz))
inDaycst = not na(time(timeframe.period, dayEnd, tz))

inOR  = autoMode ? inORauto : inORcust
inDay = autoMode ? true     : inDaycst

// ─────────────────────────────────────────────────────────────────────────
//  DAY STATE
// ─────────────────────────────────────────────────────────────────────────
var float orH      = na
var float orL      = na
var bool  orActive = false     // OR window running
var bool  orLocked = false     // OR finished, levels fixed for the day
var int   brkDir   = 0         // 0 = none, 1 = up, -1 = down
var bool  fakeOut  = false
var bool  t1Hit    = false
var bool  t2Hit    = false
var float t1Lvl    = na
var float t2Lvl    = na

// drawings of the current day
var box   orBx  = na
var line  hLn   = na
var line  hLnG  = na
var line  lLn   = na
var line  lLnG  = na
var line  t1Ln  = na
var line  t2Ln  = na

// archives
var array<box>   oldBoxes  = array.new<box>()
var array<line>  oldLines  = array.new<line>()
var array<label> oldLabels = array.new<label>()

// rolling stats (finished days only)
var array<bool> hadBreak = array.new<bool>()   // did the day break at all
var array<bool> brkUp    = array.new<bool>()   // first break was up   (breakout days only)
var array<bool> heldArr  = array.new<bool>()   // break direction held into day end
var array<bool> fakeArr  = array.new<bool>()   // first break failed back inside
var array<bool> t1Arr    = array.new<bool>()   // target 1 reached
var array<bool> t2Arr    = array.new<bool>()   // target 2 reached

// event flags for alerts (reset every bar)
evLock  = false
evUp    = false
evDown  = false
evFake  = false
evT1    = false
evT2    = false

archiveDay() =>
    array.push(oldBoxes, orBx)
    array.push(oldLines, hLn)
    array.push(oldLines, hLnG)
    array.push(oldLines, lLn)
    array.push(oldLines, lLnG)
    array.push(oldLines, t1Ln)
    array.push(oldLines, t2Ln)
    while array.size(oldBoxes) > keepN
        box.delete(array.shift(oldBoxes))
    while array.size(oldLines) > keepN * 6
        line.delete(array.shift(oldLines))
    while array.size(oldLabels) > keepN * 5
        label.delete(array.shift(oldLabels))

addLabel(float y, string txt, color c, bool below) =>
    if showLbl
        lb = label.new(bar_index, y, " " + txt + " ", style = below ? label.style_label_up : label.style_label_down, color = color.new(INK, 5), textcolor = c, size = size.normal)
        array.push(oldLabels, lb)

// ── new opening range starts: close out yesterday, reset today ──
if inOR and not inOR[1]
    if orLocked
        pushCap(hadBreak, brkDir != 0, statN)
        if brkDir != 0
            held = brkDir == 1 ? close[1] > orH : close[1] < orL
            pushCap(brkUp,   brkDir == 1, statN)
            pushCap(heldArr, held,        statN)
            pushCap(fakeArr, fakeOut,     statN)
            pushCap(t1Arr,   t1Hit,       statN)
            pushCap(t2Arr,   t2Hit,       statN)
    archiveDay()
    orH      := high
    orL      := low
    orActive := true
    orLocked := false
    brkDir   := 0
    fakeOut  := false
    t1Hit    := false
    t2Hit    := false
    t1Lvl    := na
    t2Lvl    := na
    t1Ln     := na
    t2Ln     := na
    orBx  := showBox ? box.new(bar_index, high, bar_index, low, border_color = color.new(GOLD, 25), bgcolor = color.new(GOLD, boxTr), border_width = 2) : na
    hLnG  := glowOn ? line.new(bar_index, high, bar_index + 1, high, color = color.new(NEON_TURQ, 88), width = 8) : na
    hLn   := line.new(bar_index, high, bar_index + 1, high, color = color.new(NEON_TURQ, 0), width = 2)
    lLnG  := glowOn ? line.new(bar_index, low, bar_index + 1, low, color = color.new(NEON_VIOLET, 88), width = 8) : na
    lLn   := line.new(bar_index, low, bar_index + 1, low, color = color.new(NEON_VIOLET, 0), width = 2)

// ── opening range building ──
if inOR and orActive
    orH := math.max(orH, high)
    orL := math.min(orL, low)
    if not na(orBx)
        box.set_top(orBx, orH)
        box.set_bottom(orBx, orL)
        box.set_right(orBx, bar_index)
    if not na(hLn)
        line.set_y1(hLn, orH)
        line.set_y2(hLn, orH)
    if not na(hLnG)
        line.set_y1(hLnG, orH)
        line.set_y2(hLnG, orH)
    if not na(lLn)
        line.set_y1(lLn, orL)
        line.set_y2(lLn, orL)
    if not na(lLnG)
        line.set_y1(lLnG, orL)
        line.set_y2(lLnG, orL)

// ── range locks ──
if not inOR and orActive
    orActive := false
    orLocked := true
    evLock   := true
    addLabel(orH, "OR " + str.tostring(orH - orL, format.mintick), GOLD_HI, false)

// ── after the lock: breakout / fakeout / targets (closed bars, inside day) ──
orSize = orH - orL
if orLocked and not orActive and inDay and barstate.isconfirmed
    // extend the range box across the trading day — the visual anchor
    if not na(orBx)
        box.set_right(orBx, bar_index)
    // extend live rays
    if not na(hLn)
        line.set_x2(hLn, bar_index + 1)
    if not na(hLnG)
        line.set_x2(hLnG, bar_index + 1)
    if not na(lLn)
        line.set_x2(lLn, bar_index + 1)
    if not na(lLnG)
        line.set_x2(lLnG, bar_index + 1)
    // first breakout
    if brkDir == 0
        upBrk = useWick ? high > orH : close > orH
        dnBrk = useWick ? low  < orL : close < orL
        if upBrk
            brkDir := 1
            evUp   := true
            t1Lvl  := orH + orSize * tgt1X
            t2Lvl  := orH + orSize * tgt2X
            addLabel(orH, "BREAK ▲", TUR_HI, true)
        else if dnBrk
            brkDir := -1
            evDown := true
            t1Lvl  := orL - orSize * tgt1X
            t2Lvl  := orL - orSize * tgt2X
            addLabel(orL, "BREAK ▼", VIO_HI, false)
        if brkDir != 0 and showTgt
            tc   = brkDir == 1 ? TUR_HI : VIO_HI
            t1Ln := line.new(bar_index, t1Lvl, bar_index + 1, t1Lvl, color = color.new(tc, 15), width = 2, style = line.style_dotted)
            t2Ln := line.new(bar_index, t2Lvl, bar_index + 1, t2Lvl, color = color.new(tc, 40), width = 2, style = line.style_dotted)
    else
        // fakeout: close back inside the range BEFORE the first target is
        // reached. A break that hits 1R and then returns is a win, not a fake.
        if not fakeOut and not t1Hit and (brkDir == 1 ? close < orH : close > orL)
            fakeOut := true
            evFake  := true
            addLabel(brkDir == 1 ? orH : orL, "FAKE ✕", GOLD_HI, brkDir != 1)
        // targets
        if not t1Hit and not na(t1Lvl) and (brkDir == 1 ? high >= t1Lvl : low <= t1Lvl)
            t1Hit := true
            evT1  := true
            addLabel(t1Lvl, "1R ✔", brkDir == 1 ? TUR_HI : VIO_HI, brkDir == -1)
        if not t2Hit and not na(t2Lvl) and (brkDir == 1 ? high >= t2Lvl : low <= t2Lvl)
            t2Hit := true
            evT2  := true
            addLabel(t2Lvl, "2R ✔", brkDir == 1 ? TUR_HI : VIO_HI, brkDir == -1)
        if not na(t1Ln)
            line.set_x2(t1Ln, bar_index + 1)
        if not na(t2Ln)
            line.set_x2(t2Ln, bar_index + 1)

// ─────────────────────────────────────────────────────────────────────────
//  DASHBOARD
// ─────────────────────────────────────────────────────────────────────────
todayStatus() =>
    orActive ? "● BUILDING RANGE" :
     not orLocked ? "WAITING FOR OPEN" :
     brkDir == 0 ? "INSIDE RANGE" :
     fakeOut ? (brkDir == 1 ? "FAKE ▲ ✕" : "FAKE ▼ ✕") :
     t2Hit ? (brkDir == 1 ? "BREAK ▲ · 2R ✔" : "BREAK ▼ · 2R ✔") :
     t1Hit ? (brkDir == 1 ? "BREAK ▲ · 1R ✔" : "BREAK ▼ · 1R ✔") :
     brkDir == 1 ? "BREAK ▲" : "BREAK ▼"

statTx(float p) =>
    na(p) ? "—" : str.tostring(math.round(p)) + "%"

// thin minimal bar: ▰▰▰▰▱▱▱▱
thinBar(float pct) =>
    seg = 10
    f   = math.round(nz(pct) / 100 * seg)
    out = ""
    for i = 1 to seg
        out := out + (i <= f ? "▰" : "▱")
    out

var table hud = na
if showHUD and barstate.islast
    if not na(hud)
        table.delete(hud)
    hud := table.new(hudPosition(hudPos), 3, 12, bgcolor = color.new(INK, 0), border_width = 0, frame_color = color.new(#1C2230, 0), frame_width = 1)

    head  = color.new(INK, 0)
    card  = color.new(INK, 0)
    band  = #10141D
    lblC  = color.new(TXT, 45)

    stCol = brkDir != 0 and fakeOut ? GOLD_HI : brkDir == 1 ? TUR_HI : brkDir == -1 ? VIO_HI : GOLD_HI

    // ── title ──
    table.cell(hud, 0, 0, "  ◈ ORB", text_color = TXT, text_size = size.large, text_halign = text.align_left, bgcolor = head)
    table.cell(hud, 1, 0, "", bgcolor = head)
    table.cell(hud, 2, 0, "LunqFX  ", text_color = NEON_TURQ, text_size = size.small, text_halign = text.align_right, bgcolor = head)

    // ── status: colored text on dark, like the chart ──
    table.cell(hud, 0, 1, "  TODAY", text_color = lblC, text_size = size.small, text_halign = text.align_left, bgcolor = card)
    table.cell(hud, 1, 1, todayStatus() + "  ", text_color = stCol, text_size = size.huge, text_halign = text.align_right, bgcolor = card)
    table.merge_cells(hud, 1, 1, 2, 1)

    // ── range readout ──
    orTx = orLocked or orActive ? str.tostring(orH, format.mintick) + " / " + str.tostring(orL, format.mintick) : "waiting for open"
    szTx = orLocked or orActive ? str.tostring(atr > 0 ? orSize / atr : na, "#.##") + "x ATR" : ""
    table.cell(hud, 0, 2, "  RANGE", text_color = lblC, text_size = size.small, text_halign = text.align_left, bgcolor = card)
    table.cell(hud, 1, 2, orTx, text_color = TXT, text_size = size.normal, text_halign = text.align_right, bgcolor = card)
    table.cell(hud, 2, 2, szTx + "  ", text_color = GOLD_HI, text_size = size.normal, text_halign = text.align_right, bgcolor = card)

    // ── edge section header ──
    table.cell(hud, 0, 3, "  EDGE · LAST " + str.tostring(array.size(hadBreak)) + " DAYS", text_color = NEON_TURQ, text_size = size.small, text_halign = text.align_left, bgcolor = band)
    table.merge_cells(hud, 0, 3, 2, 3)

    upP   = pctTrue(brkUp)
    holdP = pctTrue(heldArr)
    fakeP = pctTrue(fakeArr)
    t1P   = pctTrue(t1Arr)
    t2P   = pctTrue(t2Arr)
    upDom = nz(upP) >= 50

    table.cell(hud, 0, 4, "  First break", text_color = TXT, text_size = size.normal, text_halign = text.align_left, bgcolor = card)
    table.cell(hud, 1, 4, progressBar(upP), text_color = upDom ? NEON_TURQ : VIO_HI, text_size = size.normal, text_halign = text.align_right, bgcolor = card)
    table.cell(hud, 2, 4, (na(upP) ? "—" : "▲" + str.tostring(math.round(upP)) + " ▼" + str.tostring(100 - math.round(upP))) + "  ", text_color = upDom ? TUR_HI : VIO_HI, text_size = size.large, text_halign = text.align_right, bgcolor = card)

    table.cell(hud, 0, 5, "  Break holds", text_color = TXT, text_size = size.normal, text_halign = text.align_left, bgcolor = card)
    table.cell(hud, 1, 5, progressBar(holdP), text_color = NEON_TURQ, text_size = size.normal, text_halign = text.align_right, bgcolor = card)
    table.cell(hud, 2, 5, statTx(holdP) + "  ", text_color = TUR_HI, text_size = size.large, text_halign = text.align_right, bgcolor = card)

    table.cell(hud, 0, 6, "  Fakeout", text_color = TXT, text_size = size.normal, text_halign = text.align_left, bgcolor = card)
    table.cell(hud, 1, 6, progressBar(fakeP), text_color = GOLD, text_size = size.normal, text_halign = text.align_right, bgcolor = card)
    table.cell(hud, 2, 6, statTx(fakeP) + "  ", text_color = GOLD_HI, text_size = size.large, text_halign = text.align_right, bgcolor = card)

    table.cell(hud, 0, 7, "  1R target", text_color = TXT, text_size = size.normal, text_halign = text.align_left, bgcolor = card)
    table.cell(hud, 1, 7, progressBar(t1P), text_color = NEON_TURQ, text_size = size.normal, text_halign = text.align_right, bgcolor = card)
    table.cell(hud, 2, 7, statTx(t1P) + "  ", text_color = TUR_HI, text_size = size.large, text_halign = text.align_right, bgcolor = card)

    table.cell(hud, 0, 8, "  2R target", text_color = TXT, text_size = size.normal, text_halign = text.align_left, bgcolor = card)
    table.cell(hud, 1, 8, progressBar(t2P), text_color = NEON_TURQ, text_size = size.normal, text_halign = text.align_right, bgcolor = card)
    table.cell(hud, 2, 8, statTx(t2P) + "  ", text_color = TUR_HI, text_size = size.large, text_halign = text.align_right, bgcolor = card)

    // ── footer ──
    footTx = timeframe.isintraday ? "  closed bars · no repaint" : "  ⚠ use an intraday timeframe (1m–15m)"
    table.cell(hud, 0, 9, footTx, text_color = timeframe.isintraday ? color.new(MUTE, 40) : GOLD, text_size = size.small, text_halign = text.align_left, bgcolor = head)
    table.merge_cells(hud, 0, 9, 2, 9)

// ─────────────────────────────────────────────────────────────────────────
//  NEON GRADIENT CANDLES  (turquoise bullish / violet bearish)
// ─────────────────────────────────────────────────────────────────────────
isUp     = close >= open
strength = math.min(1.0, math.abs(close - open) / (atr * 0.45))
upCol    = color.from_gradient(strength, 0, 1, TUR_MID, TUR_HI)
dnCol    = color.from_gradient(strength, 0, 1, VIO_MID, VIO_HI)
bodyCol  = isUp ? upCol : dnCol
edgeCol  = isUp ? NEON_TURQ : NEON_VIOLET

// Halo layer — soft glow around each candle.
plotcandle(neonOn and neonGlow ? open : na, high, low, close, title = "Glow", color = color.new(edgeCol, 75), wickcolor = color.new(edgeCol, 55), bordercolor = color.new(edgeCol, 85), display = display.pane)
// Crisp neon body, fully opaque so it covers the native candles.
plotcandle(neonOn ? open : na, high, low, close, title = "Neon Candles", color = bodyCol, wickcolor = edgeCol, bordercolor = edgeCol, display = display.pane)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────
alertcondition(evLock, "Opening range locked", "LunqFX ORB: opening range is set")
alertcondition(evUp,   "Breakout UP",          "LunqFX ORB: breakout above the opening range")
alertcondition(evDown, "Breakout DOWN",        "LunqFX ORB: breakout below the opening range")
alertcondition(evFake, "Fakeout",              "LunqFX ORB: breakout failed back inside the range")
alertcondition(evT1,   "Target 1 hit",         "LunqFX ORB: target 1 reached")
alertcondition(evT2,   "Target 2 hit",         "LunqFX ORB: target 2 reached")
````
