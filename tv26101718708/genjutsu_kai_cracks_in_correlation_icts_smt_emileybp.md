# Genjutsu Kai - cracks in correlation (ICT's SMT)

- url: https://www.tradingview.com/script/EmileYBp-Genjutsu-Kai-cracks-in-correlation-ICT-s-SMT/
- type: indicator
- pine_id: PUB;3497692dd5394480bd322644ecb1d188
- version: 2.0

## Description

[image]https://www.tradingview.com/x/zRTSPBpi/[/image]
[b]Genjutsu Kai (幻術解 · "Genjutsu Release")[/b]
A run on one index can be an illusion: a high or low taken that its sister index refuses to confirm. Genjutsu Kai maps those cracks in correlation (ICT's SMT) between your chart and its sister market (NQ ↔ ES by default) during the regular session. It measures how far the trailing market, the "sick sister", is behind, and tracks whether each divergence holds or syncs.
[i]A confluence map, not a signal.[/i]

[b]What it draws[/b]
- Trendline from the reference high or low to the leader's new extreme
- Ghost: the sister's move, scaled by % onto your chart
- Lag bracket: the gap between them, in points and % ($ per contract in the tooltip)
- Tag: ▼/▲, the reference (30, 1H, OR) and its state: ● open · ◐ synced · ■ held
- Swing dots at both ends of the trendline; hover any mark for the full read
- Opening range lines (9:30–10:00 ET)
- Compact card: who leads since 9:30, each reference's high/low state, today's tally

[b]How it works[/b]
- References: 30-minute ranges, hourly ranges anchored to 9:30, and the opening range checked 10:00–16:00
- SMTs are only checked in RTH, 9:30–16:00 ET
- A divergence becomes an SMT once the sister has failed to confirm for longer than the grace period (default 2 min) and the lag reaches the minimum (default 0.02%)
- Each SMT then syncs (the sister takes its level: continuation on both) or holds (the divergence stands to the end of its window)
- Confirmed bars only, so nothing repaints
- Pairs itself on continuous (NQ1! ↔ ES1!) and single-contract (NQZ2026 ↔ ESZ2026) charts, and MNQ ↔ MES; any symbol can be set by hand

[b]HYDRA heads[/b] [i](NQ/ES 1-minute data: fit 2018–24, locked test 2025–26)[/i]
- Sync odds ↻: the chance the sister still takes its level before the window ends, from its distance, its volatility and the time left. Out of sample it separated syncs from holds with AUC 0.84 and read 25→21%, 45→40%, 65→67%, 93→93% (predicted→actual)
- Roll week flag: in the week before quarterly expiry week, fading an SMT won the 1σ race* 54% of the time in 2018–24 and 58% in 2025–26 (30 days), vs 49% in other weeks. It was the only one of 635 candidate features that survived the locked test. Treat it as a candidate

[b]What the testing says[/b]
- On its own an SMT was a coin flip: fading one won the 1σ race 49.5% (2018–24) and 49.9% (2025–26), close to fading an ordinary sweep or simply being long
- Whether an SMT held or synced said nothing about direction afterwards
- Sync odds forecast the sister's reach, not where price goes next
[i]*1σ race: did price move one 30-minute standard deviation in the fade direction before moving one against, by 16:14 ET[/i]

[b]Settings[/b]
- Each reference on/off with its own colours and width (default: 30-minute + opening range)
- Grace period, minimum lag, synced SMTs keep/fade/remove, days kept
- Ghost style, lag bracket, swing dot size, tag content, size and backing, lag units
- Card position, size and theme; sync odds in card/tooltip/tag; roll week flag
- Alerts: new SMT, sister syncs, SMT held

[b]Use[/b]
- Chart timeframes of 1–30 minutes that divide 30; 1-minute recommended (the odds were fitted on 1-minute data)
- NQ, ES, MNQ and MES pair automatically; set "Compare with" for anything else (e.g. RTY1!)

[b]Credits[/b]
- SMT, sick sister and opening range concepts as taught by ICT (Michael J. Huddleston)
- Trendline presentation inspired by "SMT Divergences" by LuxAlgo (CC BY-NC-SA 4.0); written from scratch, no LuxAlgo code used
- Not affiliated with or endorsed by either

[i]Open source under MPL 2.0. For education and research, not financial advice. Past results do not guarantee future results.[/i]

## Source Code

````pine
//@version=6
// This Source Code Form is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Unclehk2000
//
// Genjutsu Kai (幻術解 · "Genjutsu Release")
// Named for the technique that breaks an illusion. A run on one index can be an illusion: a high or low taken that the
// other index refuses to confirm. Genjutsu Kai compares your chart with its sister market (NQ ↔ ES by default) in the
// regular session and draws each crack in correlation (ICT's SMT) as a trendline from the reference high or low to the
// new extreme, with a ghost of the other market's move scaled onto your chart. The gap at the end is the lag: how far
// the trailing market (the sick sister) is behind, in points and %. Each SMT then either syncs (the sister takes its
// level too: the move continues on both) or holds to the end of its window (the divergence stood).
// References: 30-minute ranges, hourly ranges anchored to 9:30, and the opening range (9:30–10:00, checked to 16:00).
// SMTs are only checked in RTH, 9:30–16:00 ET. Pairs itself on continuous (NQ1! ↔ ES1!) and single-contract
// (NQZ2026 ↔ ESZ2026) charts. SMT, sick sister and opening range concepts are taught by ICT (Michael J. Huddleston).
// The trendline idea is inspired by "SMT Divergences" by LuxAlgo (CC BY-NC-SA 4.0); written from scratch, no LuxAlgo
// code is used. Not affiliated with or endorsed by either.
// HYDRA heads (fished on NQ/ES 1-minute 2018–24, locked test 2025–26): sync odds, the chance the sick sister still takes
// its level before the window ends, from its distance, its volatility and the time left; and a roll-week flag.

indicator("Genjutsu Kai", "Genjutsu Kai", overlay = true, max_labels_count = 500, max_lines_count = 500)

TZ = "America/New_York"

// ═══════════════════════════════════════════════════════════════ Inputs
gV = "View"
themeI  = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = gV, tooltip = "Auto follows the chart background.", display = display.none)
crdSzI  = input.string("Small", "Card text", options = ["Tiny", "Small", "Normal"], group = gV, display = display.none)

gP = "Pair"
cmpIn = input.symbol("", "Compare with", group = gP, tooltip = "Leave blank to pair automatically: NQ ↔ ES and MNQ ↔ MES, keeping the chart's contract (NQ1! → ES1!, NQZ2026 → ESZ2026). Pick any symbol here to override (e.g. RTY1!).", display = display.none)

gR = "References · checked in RTH 9:30–16:00 ET"
use30 = input.bool(true, "30-minute   ", group = gR, inline = "r30", display = display.none)
c30H  = input.color(#f23645, "", group = gR, inline = "r30", display = display.none)
c30L  = input.color(#089981, "", group = gR, inline = "r30", display = display.none)
w30   = input.int(2, "", options = [1, 2, 3, 4], group = gR, inline = "r30", display = display.none)
use60 = input.bool(false, "Hourly        ", group = gR, inline = "r60", display = display.none)
c60H  = input.color(#ff7043, "", group = gR, inline = "r60", display = display.none)
c60L  = input.color(#26a69a, "", group = gR, inline = "r60", display = display.none)
w60   = input.int(1, "", options = [1, 2, 3, 4], group = gR, inline = "r60", display = display.none)
useOR = input.bool(true, "Opening range", group = gR, inline = "rOR", display = display.none)
cORH  = input.color(#ab47bc, "", group = gR, inline = "rOR", display = display.none)
cORL  = input.color(#42a5f5, "", group = gR, inline = "rOR", display = display.none)
wOR   = input.int(2, "", options = [1, 2, 3, 4], group = gR, inline = "rOR", tooltip = "Each row: on/off · colour for SMTs at highs (bearish) · colour for SMTs at lows (bullish) · line width.\n30-minute: each 30-minute range checked over the next 30 minutes (the first, 9:00–9:30, over 9:30–10:00).\nHourly: hourly ranges from 9:30 (the first, 8:30–9:30) checked over the next hour.\nOpening range: 9:30–10:00 checked 10:00–16:00.", display = display.none)

gS = "SMT rules"
graceM = input.int(2, "Divergence must hold for (minutes)", minval = 0, maxval = 30, group = gS, tooltip = "An SMT is drawn only once the sister has failed to confirm for longer than this. On NQ/ES 1-minute data 2023–26 about a quarter of 30m and hourly divergences were confirmed within 2 minutes: lag, not a crack.", display = display.none)
minLag = input.float(0.02, "Minimum lag (%)", minval = 0.0, maxval = 1.0, step = 0.01, group = gS, tooltip = "An SMT also needs the leader to be at least this far ahead of the sister, as a % of each market's own level (0.02% ≈ 4 NQ / 1.2 ES points). Cuts the hairline cracks that clutter the chart. 0 = off.\nOn NQ/ES 1-minute data 2018–24, 0.02% hid about 1 in 10 30m SMTs (6.8 → 6.2 a day) and left the held share unchanged (52% → 53%; 2025: 51% → 52%). It removes clutter; it is not an edge filter.", display = display.none)
syncI  = input.string("Fade", "Synced SMTs", options = ["Keep", "Fade", "Remove"], group = gS, display = display.none)
keepD  = input.int(5, "Keep the last (RTH days)", minval = 1, maxval = 30, group = gS, display = display.none)

gM = "Chart marks"
showTL  = input.bool(true, "Trendline: reference extreme → new extreme", group = gM, display = display.none)
showGh  = input.bool(true, "Ghost of the other market", group = gM, inline = "gh", tooltip = "The other market's move from its own reference, scaled by % onto your chart's price.", display = display.none)
ghStyI  = input.string("Dotted", "", options = ["Dotted", "Dashed", "Solid"], group = gM, inline = "gh", display = display.none)
showLag = input.bool(true, "Lag bracket", group = gM, inline = "lk", display = display.none)
showDot = input.bool(true, "Swing dots", group = gM, inline = "lk", display = display.none)
dotSzI  = input.string("Small", "", options = ["Tiny", "Small", "Medium", "Large"], group = gM, inline = "lk", tooltip = "Dots mark the reference extreme and the new extreme at the two ends of the trendline. Hover one for the full read.", display = display.none)
tagI    = input.string("Glyph + lag", "Tag", options = ["Glyph + lag", "Glyph only", "Off"], group = gM, inline = "tg", display = display.none)
tagSzI  = input.string("Tiny", "", options = ["Tiny", "Small", "Normal"], group = gM, inline = "tg", display = display.none)
tagBg   = input.bool(true, "Backing", group = gM, inline = "tg", tooltip = "Glyph: ▼ SMT at a high (bearish) · ▲ at a low (bullish), then the reference (30, 1H, OR) and its state: ● open · ◐ synced · ■ held.\nBacking puts a chart-coloured panel behind the tag so it reads cleanly over candles and lines.", display = display.none)
lagUnit = input.string("Points and %", "Lag as", options = ["Points and %", "Points", "%"], group = gM, inline = "lg", display = display.none)
lagIn   = input.string("Lagging market", "in", options = ["Lagging market", "Chart symbol"], group = gM, inline = "lg", tooltip = "Lag = how far the trailing market is behind the leader, relative to each one's own level. Points can be shown in the trailing market's own points or converted to your chart's points.", display = display.none)
showORl = input.bool(true, "Opening range lines", group = gM, inline = "or", display = display.none)
colORl  = input.color(color.new(#ffb300, 45), "", group = gM, inline = "or", display = display.none)

gH = "HYDRA heads"
oddsI   = input.string("Card + tooltip", "Sync odds", options = ["Card + tooltip", "Card + tooltip + tag", "Off"], group = gH, tooltip = "↻ = the chance the sister still takes its level before the window ends, updated every bar while the SMT is open. It is the random-walk hitting chance 2Φ(−distance ÷ (κ·σ·√minutes left)), recalibrated, with the sister's volatility from its last 60 bars.\nFit on NQ/ES 1-minute open SMTs 2018–24; on the locked 2025–26 test it ranked syncs vs holds with AUC 0.84 and read 3→3%, 25→21%, 45→40%, 65→67%, 84→89%, 93→93% (predicted→actual). It forecasts the sister's reach, not the direction after the window: held and synced SMTs were both coin flips afterwards.\nFitted on 1-minute bars; on higher timeframes it is an approximation.", display = display.none)
showRoll = input.bool(true, "Flag roll week", group = gH, tooltip = "Roll week = the week the quarterly contracts roll (Mon–Fri of the week before expiry week, March/June/Sept/Dec).\nOne head out of 635 fished survived the locked test: fading an SMT won the 1σ race 54% of the time in roll weeks 2018–24 (49% other weeks) and 58% in 2025–26 (30 days, so wide error bars). The weeks either side showed nothing. Both sides, 7 of 9 years. A candidate, not a rule: re-check it each quarter.", display = display.none)

gC = "Card"
showCrd = input.bool(true, "Card", group = gC, inline = "c1", display = display.none)
crdPos  = input.string("Top right", "", options = ["Top left", "Top center", "Top right", "Middle left", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = gC, inline = "c1", display = display.none)
crdLead = input.bool(true, "Leader since 9:30 row", group = gC, display = display.none)

gA = "Alerts (create one alert with 'Any alert() function call')"
alNew  = input.bool(true, "New SMT", group = gA, inline = "a1", display = display.none)
alSync = input.bool(true, "Sister syncs", group = gA, inline = "a1", display = display.none)
alHeld = input.bool(false, "SMT held", group = gA, inline = "a1", display = display.none)

// ═══════════════════════════════════════════════════════════════ Pair
pairRoot(string r) => r == "NQ" ? "ES" : r == "ES" ? "NQ" : r == "MNQ" ? "MES" : r == "MES" ? "MNQ" : ""
lastPart(string s) =>
    array<string> p = str.split(s, ":")
    p.size() > 0 ? p.get(p.size() - 1) : s
string autoRoot = pairRoot(syminfo.root)
string autoT    = syminfo.prefix + ":" + autoRoot + str.replace(syminfo.ticker, syminfo.root, "")
bool   havePair = cmpIn != "" or autoRoot != ""
string otherT   = cmpIn != "" ? cmpIn : autoRoot != "" ? autoT : syminfo.tickerid
string nmA      = syminfo.root
string nmB      = cmpIn != "" ? lastPart(cmpIn) : autoRoot

[bH, bL, bC, bO, bPv, bSd0] = request.security(otherT, timeframe.period, [high, low, close, open, syminfo.pointvalue, ta.stdev(math.log(close / close[1]), 60)], gaps = barmerge.gaps_on)
float bSd = fixnan(bSd0)
float bCf = fixnan(bC)
float aSd = ta.stdev(math.log(close / close[1]), 60)

// ═══════════════════════════════════════════════════════════════ Palette, helpers
float bgLum = 0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)
bool  dark  = themeI == "Dark" or (themeI == "Auto" and bgLum < 128)
color cBg   = dark ? #0e1117 : #ffffff
color cHd   = dark ? #171c28 : #eef1f6
color cBd   = dark ? #262c3a : #d5dae4
color cTx   = dark ? #e6e9ef : #131722
color cSub  = dark ? #9aa3b5 : #4a5163
color cMu   = dark ? #5d6476 : #9aa1b2
tagSz = tagSzI == "Tiny" ? size.tiny : tagSzI == "Small" ? size.small : size.normal
crdSz = crdSzI == "Tiny" ? size.tiny : crdSzI == "Small" ? size.small : size.normal
ghSty = ghStyI == "Dotted" ? line.style_dotted : ghStyI == "Dashed" ? line.style_dashed : line.style_solid
// dots are text glyphs on a bodiless label: label.style_circle pads itself to its text box and draws far too large
dotTx = dotSzI == "Tiny" ? "•" : "●"
dotSz = dotSzI == "Large" ? size.normal : dotSzI == "Medium" ? size.small : size.tiny
oddsOn  = oddsI != "Off"
oddsTag = oddsI == "Card + tooltip + tag"

// HYDRA sync odds. p = logistic(A + B·logit(2Φ(−gap / (κ·σ1·√left))) + kind term); gap = the sister's log distance to its level
// from its close, σ1 = its 1-minute σ (last 60 bars), left = minutes to the window end. Fit 2018–24, NQ/ES 1-minute.
SY_K30 = 1.080
SY_K60 = 1.115
SY_KOR = 1.155
SY_A   = -0.186
SY_B   = 0.769
SY_C60 = 0.033
SY_COR = 0.015
nCdf(float x) =>
    float z = math.abs(x)
    float t = 1.0 / (1.0 + 0.2316419 * z)
    float p = 1.0 - 0.3989422804 * math.exp(-0.5 * z * z) * t * (0.319381530 + t * (-0.356563782 + t * (1.781477937 + t * (-1.821255978 + t * 1.330274429))))
    x >= 0 ? p : 1.0 - p

solid(color c) =>
    color out = cBg
    if not na(color.r(c))
        float a = 1.0 - color.t(c) / 100.0
        out := color.rgb(color.r(c) * a + color.r(cBg) * (1.0 - a), color.g(c) * a + color.g(cBg) * (1.0 - a), color.b(c) * a + color.b(cBg) * (1.0 - a), 0)
    out
posOf(string s) =>
    switch s
        "Top left"      => position.top_left
        "Top center"    => position.top_center
        "Top right"     => position.top_right
        "Middle left"   => position.middle_left
        "Middle right"  => position.middle_right
        "Bottom left"   => position.bottom_left
        "Bottom center" => position.bottom_center
        => position.bottom_right
hm(int t) => str.format_time(t, "HH:mm", TZ)
stamp(int t) => str.format_time(t, "HH:mm MM/dd", TZ)
pts(float v) => str.tostring(v, "#,##0.00")
usd(float v) => "$" + str.tostring(v, "#,##0")
pct(float v) => str.tostring(v, "0.00") + "%"
sgnPct(float v) => (v >= 0 ? "+" : "") + str.tostring(v, "0.00") + "%"
pc0(float p) => str.tostring(p * 100.0, "0") + "%"
// roll week: Mon–Fri of the week before quarterly expiry week (third Friday of Mar/Jun/Sep/Dec)
rollWeek(int t) =>
    int y  = year(t, TZ)
    int mo = month(t, TZ)
    int dm = dayofmonth(t, TZ)
    int d1 = dayofweek(timestamp(TZ, y, mo, 1, 12, 0), TZ)
    int tF = 1 + (6 - d1 + 7) % 7 + 14
    mo % 3 == 0 and dm >= tF - 11 and dm <= tF - 7
bool rollWk = rollWeek(time)

// Blocks: 30m on the clock (:00/:30); 60m anchored to 9:30; OR: 0 = 9:30–10:00, 1 = 10:00–16:00.
blockOf(string k, int m) => k == "30m" ? int(math.floor(m / 30.0)) : k == "60m" ? int(math.floor((m - 30) / 60.0)) : m < 570 ? -1 : m < 600 ? 0 : m < 960 ? 1 : 2
blockStart(string k, int b) => k == "30m" ? b * 30 : k == "60m" ? b * 60 + 30 : b == 0 ? 570 : b == 1 ? 600 : 960
isWindow(string k, int b) => k == "OR" ? b == 1 : blockStart(k, b) >= 570 and blockStart(k, b) < 960
hhmm(int m) => str.tostring(int(m / 60), "00") + ":" + str.tostring(m % 60, "00")
winEnd(string k, int b) => k == "OR" ? 960 : math.min(960, blockStart(k, b) + (k == "30m" ? 30 : 60))
winText(string k, int b) =>
    int s = blockStart(k, b)
    int e = k == "OR" ? 960 : math.min(960, s + (k == "30m" ? 30 : 60))
    hhmm(s) + "–" + hhmm(e)

// ═══════════════════════════════════════════════════════════════ SMT engine
// One side (highs or lows) of one window. st: 0 nothing taken yet · 1 leader took, waiting out the grace period ·
// 2 SMT open · 3 sister synced · 4 SMT held to the end of the window · 5 both took (within the grace): no SMT ·
// 6 the window ended before the lag reached the minimum: no SMT.
type Side
    int   st    = 0
    int   lead  = 0
    int   tLead = na
    int   tSync = na
    float mA    = na
    int   tmA   = na
    float mB    = na
    int   tmB   = na
    float lagP  = na
    float lagMx = na
    int   tMx   = na
    float pSync = na
    float pSync0 = na
    bool  roll  = false
    float off   = 0.0
    line  lnA
    line  lnB
    line  lnK
    label lbl
    label d1
    label d2

type Track
    string kind
    string tag
    bool   on
    color  cH
    color  cL
    int    w
    int    blk   = -999
    int    day   = 0
    float  cHa   = na
    int    cHaT  = na
    float  cLa   = na
    int    cLaT  = na
    float  cHb   = na
    int    cHbT  = na
    float  cLb   = na
    int    cLbT  = na
    int    cN    = 0
    float  rHa   = na
    int    rHaT  = na
    float  rLa   = na
    int    rLaT  = na
    float  rHb   = na
    int    rHbT  = na
    float  rLb   = na
    int    rLbT  = na
    bool   live  = false
    int    wBlk  = na
    Side   hi
    Side   lo
    int    nSmt  = 0
    int    nSync = 0
    int    nHeld = 0

var array<Side>  hist    = array.new<Side>()
var array<int>   histD   = array.new<int>()
var array<line>  orLns   = array.new<line>()
var array<int>   orD     = array.new<int>()
var array<label> dayTags = array.new<label>()
var int          dayN    = 0
float sepY = 1.6 * ta.sma(high - low, 50)

method erase(Side s) =>
    line.delete(s.lnA)
    line.delete(s.lnB)
    line.delete(s.lnK)
    label.delete(s.lbl)
    label.delete(s.d1)
    label.delete(s.d2)
    s.lnA := na
    s.lnB := na
    s.lnK := na
    s.lbl := na
    s.d1  := na
    s.d2  := na
    s

// running extremes inside a window, with the time each was set
method ext(Side s, bool isHi) =>
    float vA = isHi ? high : low
    if not na(vA) and (na(s.mA) or (isHi ? vA > s.mA : vA < s.mA))
        s.mA  := vA
        s.tmA := time
    float vB = isHi ? bH : bL
    if not na(vB) and (na(s.mB) or (isHi ? vB > s.mB : vB < s.mB))
        s.mB  := vB
        s.tmB := time
    s

// a tag's vertical offset so it clears the tags already on today's chart
place(int x, float y, bool isHi) =>
    float off = 0.0
    int   win = 25 * timeframe.in_seconds() * 1000
    float sep = nz(sepY, 0.0)
    if sep > 0
        for k = 0 to 6
            bool hit = false
            for l in dayTags
                if math.abs(l.get_x() - x) < win and math.abs(l.get_y() - (y + off)) < sep
                    hit := true
                    break
            if not hit
                break
            off += isHi ? sep : -sep
    off

lagText(Track t, Side s, bool isHi) =>
    float refA  = isHi ? t.rHa : t.rLa
    float refB  = isHi ? t.rHb : t.rLb
    bool  sisA  = s.lead == 2
    string sisN = sisA ? nmA : nmB
    float  pL   = lagIn == "Chart symbol" ? s.lagP / 100.0 * refA : s.lagP / 100.0 * (sisA ? refA : refB)
    string pTx  = (lagIn == "Lagging market" ? sisN + " " : "") + "Δ" + pts(pL)
    na(s.lagP) ? "" : lagUnit == "Points" ? pTx : lagUnit == "%" ? sisN + " Δ" + pct(s.lagP) : pTx + " · " + pct(s.lagP)

glyph(Track t, Side s, bool isHi) => (isHi ? "▼" : "▲") + t.tag + " " + (s.st == 3 ? "◐" : s.st == 4 ? "■" : "●")

// HYDRA sync odds for an open SMT at this bar (m = minute of day of the bar open, ET)
syncP(Track t, Side s, bool isHi, int m) =>
    float p    = na
    bool  sisB = s.lead == 1
    float refS = sisB ? (isHi ? t.rHb : t.rLb) : (isHi ? t.rHa : t.rLa)
    float cS   = sisB ? bCf : close
    float tfM  = timeframe.in_seconds() / 60.0
    float sd   = (sisB ? bSd : aSd) / math.sqrt(tfM)
    float left = winEnd(t.kind, t.wBlk) - (m + tfM)
    if left > 0 and sd > 0 and not na(cS) and refS > 0
        float gap = math.max(0.0, (isHi ? 1.0 : -1.0) * math.log(refS / cS))
        float k   = t.kind == "30m" ? SY_K30 : t.kind == "60m" ? SY_K60 : SY_KOR
        float pr  = math.min(math.max(2.0 * nCdf(-gap / (sd * math.sqrt(left)) / k), 0.0001), 0.9999)
        float lg  = SY_A + SY_B * math.log(pr / (1.0 - pr)) + (t.kind == "60m" ? SY_C60 : t.kind == "OR" ? SY_COR : 0.0)
        p := 1.0 / (1.0 + math.exp(-lg))
    p

tipText(Track t, Side s, bool isHi) =>
    string nL   = s.lead == 1 ? nmA : nmB
    string nS   = s.lead == 1 ? nmB : nmA
    float  refA = isHi ? t.rHa : t.rLa
    float  refB = isHi ? t.rHb : t.rLb
    float  rL   = s.lead == 1 ? refA : refB
    float  rS   = s.lead == 1 ? refB : refA
    float  pvL  = s.lead == 1 ? syminfo.pointvalue : bPv
    float  pvS  = s.lead == 1 ? bPv : syminfo.pointvalue
    float  lagS = s.lagP / 100.0 * rS
    float  lagC = s.lagP / 100.0 * refA
    string lv   = isHi ? "high" : "low"
    string out  = (isHi ? "▼ Bearish" : "▲ Bullish") + " SMT · " + t.kind + " window " + winText(t.kind, t.wBlk) + " ET\n" + nL + " took its " + t.kind + " " + lv + " at " + stamp(s.tLead) + "; " + nS + ", the sick sister, failed to confirm."
    out += "\n" + (s.st == 3 ? "Lag at sync" : s.st == 4 ? "Lag at window end" : "Lag now") + ": " + nS + " is " + pct(s.lagP) + " behind = " + pts(lagS) + " " + nS + " pts" + (na(pvS) ? "" : " (" + usd(lagS * pvS) + " per contract)") + (s.lead == 1 ? " · " + pts(lagC) + " " + nmA + " pts on this chart" : "")
    out += not na(s.lagMx) and s.lagMx > s.lagP + 0.005 ? "\nPeak lag: " + pct(s.lagMx) + " at " + hm(s.tMx) + " ET" : ""
    if oddsOn and not na(s.pSync0)
        out += s.st == 2 and not na(s.pSync) ? "\nSync odds ↻ " + pc0(s.pSync) + " that " + nS + " takes its " + lv + " by " + hhmm(winEnd(t.kind, t.wBlk)) + " ET (" + pc0(s.pSync0) + " when drawn)" : "\nSync odds when drawn: " + pc0(s.pSync0)
    if showRoll and s.roll
        out += "\nRoll week: SMT fades won 54% of 1σ races in roll weeks 2018–24 and 58% in 2025–26, vs 49% in other weeks. A fished head that held out of sample; a candidate, not a rule."
    out + (s.st == 3 ? "\nSynced " + stamp(s.tSync) + " (+" + str.tostring((s.tSync - s.tLead) / 60000, "0") + "m): " + nS + " took its " + lv + " too. Continuation on both." : s.st == 4 ? "\nHeld: " + nS + " never took its " + lv + " in this window. The divergence stood." : "\nOpen: watching for " + nS + " to take its " + lv + ".")

// draw or refresh one SMT: trendline, ghost, lag bracket and tag
method paint(Track t, Side s, bool isHi) =>
    if s.st == 3 and syncI == "Remove"
        s.erase()
    else
        color  c0    = isHi ? t.cH : t.cL
        color  c     = s.st == 3 and syncI == "Fade" ? color.new(c0, 65) : c0
        float  refA  = isHi ? t.rHa : t.rLa
        float  refB  = isHi ? t.rHb : t.rLb
        int    tRefA = isHi ? t.rHaT : t.rLaT
        int    tRefB = isHi ? t.rHbT : t.rLbT
        float  gEnd  = na(s.mB) or na(refB) or refB == 0 ? na : refA * s.mB / refB
        int    xb    = na(s.tmB) ? s.tmA : math.max(s.tmA, s.tmB)
        if showTL
            if na(s.lnA)
                s.lnA := line.new(tRefA, refA, s.tmA, s.mA, xloc = xloc.bar_time, color = c, width = t.w)
            else
                s.lnA.set_xy2(s.tmA, s.mA)
                s.lnA.set_color(c)
        if showGh and not na(gEnd)
            if na(s.lnB)
                s.lnB := line.new(nz(tRefB, tRefA), refA, s.tmB, gEnd, xloc = xloc.bar_time, color = color.new(c, math.max(color.t(c), 25)), width = 1, style = ghSty)
            else
                s.lnB.set_xy2(s.tmB, gEnd)
                s.lnB.set_color(color.new(c, math.max(color.t(c), 25)))
        if showLag and not na(gEnd)
            if na(s.lnK)
                s.lnK := line.new(xb, s.mA, xb, gEnd, xloc = xloc.bar_time, color = c, width = 1, style = line.style_dotted)
            else
                s.lnK.set_xy1(xb, s.mA)
                s.lnK.set_xy2(xb, gEnd)
                s.lnK.set_color(c)
        string tp = tipText(t, s, isHi)
        if showDot
            if na(s.d1)
                s.d1 := label.new(tRefA, refA, dotTx, xloc = xloc.bar_time, color = #00000000, style = label.style_none, textcolor = c, size = dotSz, tooltip = tp)
                s.d2 := label.new(s.tmA, s.mA, dotTx, xloc = xloc.bar_time, color = #00000000, style = label.style_none, textcolor = c, size = dotSz, tooltip = tp)
            else
                s.d1.set_textcolor(c)
                s.d1.set_tooltip(tp)
                s.d2.set_xy(s.tmA, s.mA)
                s.d2.set_textcolor(c)
                s.d2.set_tooltip(tp)
        if tagI != "Off"
            float  ym = na(gEnd) ? s.mA : (s.mA + gEnd) / 2.0
            string tx = glyph(t, s, isHi) + (tagI == "Glyph + lag" ? "  " + lagText(t, s, isHi) : "") + (oddsTag and s.st == 2 and not na(s.pSync) ? "  ↻" + pc0(s.pSync) : "")
            color  bk = tagBg ? color.new(chart.bg_color, 12) : #00000000
            if na(s.lbl)
                s.off := place(xb, ym, isHi)
                s.lbl := label.new(xb, ym + s.off, tx, xloc = xloc.bar_time, color = bk, style = label.style_label_left, textcolor = c, size = tagSz, tooltip = tp)
                dayTags.push(s.lbl)
            else
                s.lbl.set_xy(xb, ym + s.off)
                s.lbl.set_text(tx)
                s.lbl.set_textcolor(c)
                s.lbl.set_tooltip(tp)
    t

method check(Track t, Side s, bool isHi, int m) =>
    float refA = isHi ? t.rHa : t.rLa
    float refB = isHi ? t.rHb : t.rLb
    if s.st <= 2
        s.ext(isHi)
    bool tA = not na(s.mA) and (isHi ? s.mA > refA : s.mA < refA)
    bool tB = not na(s.mB) and (isHi ? s.mB > refB : s.mB < refB)
    if s.st == 0
        if tA and tB
            s.st := 5
        else if tA or tB
            s.st    := 1
            s.lead  := tA ? 1 : 2
            s.tLead := time
    if (s.st == 1 or s.st == 2) and not na(s.mB) and refA > 0 and refB > 0
        s.lagP := 100.0 * math.abs(s.mB / refB - s.mA / refA)
        if na(s.lagMx) or s.lagP > s.lagMx
            s.lagMx := s.lagP
            s.tMx   := time
    bool   sisTook = s.lead == 1 ? tB : tA
    string nL = s.lead == 1 ? nmA : nmB
    string nS = s.lead == 1 ? nmB : nmA
    string lv = isHi ? "high" : "low"
    if s.st == 1
        if sisTook
            s.st := 5
        else if time_close - s.tLead > graceM * 60000 and nz(s.lagP) >= minLag
            s.st     := 2
            s.roll   := rollWk
            s.pSync  := syncP(t, s, isHi, m)
            s.pSync0 := s.pSync
            t.nSmt   += 1
            hist.push(s)
            histD.push(dayN)
            t.paint(s, isHi)
            if alNew
                alert("Genjutsu Kai · " + (isHi ? "▼ bearish" : "▲ bullish") + " " + t.kind + " SMT: " + nL + " took its " + lv + " at " + hm(s.tLead) + " ET, " + nS + " failed · " + nS + " " + pct(s.lagP) + " behind" + (oddsOn and not na(s.pSync) ? " · sync odds " + pc0(s.pSync) : "") + (showRoll and rollWk ? " · roll week" : ""), alert.freq_once_per_bar_close)
    else if s.st == 2
        if sisTook
            s.st    := 3
            s.tSync := time
            t.nSync += 1
            if alSync
                alert("Genjutsu Kai · " + t.kind + " SMT synced: " + nS + " took its " + lv + " at " + hm(time) + " ET, " + str.tostring((time - s.tLead) / 60000, "0") + "m after " + nL, alert.freq_once_per_bar_close)
        else
            s.pSync := syncP(t, s, isHi, m)
        t.paint(s, isHi)
    t

// end of the window: a divergence still standing is an SMT that held
method finish(Track t, Side s, bool isHi) =>
    if s.st == 1 and nz(s.lagP) < minLag
        s.st := 6
    else if s.st == 1 or s.st == 2
        if s.st == 1
            t.nSmt += 1
            hist.push(s)
            histD.push(dayN)
        s.st := 4
        t.nHeld += 1
        t.paint(s, isHi)
        if alHeld
            alert("Genjutsu Kai · " + t.kind + " SMT held: " + (s.lead == 1 ? nmB : nmA) + " never took its " + (isHi ? "high" : "low") + " in " + winText(t.kind, t.wBlk) + " ET", alert.freq_once_per_bar_close)
    t

method step(Track t, int m, int dk) =>
    if t.on
        int b = blockOf(t.kind, m)
        if b != t.blk or dk != t.day
            if t.live
                t.finish(t.hi, true)
                t.finish(t.lo, false)
                t.live := false
            bool contig = dk == t.day and b == t.blk + 1 and t.cN > 0 and not na(t.cHb) and not na(t.cLb)
            if isWindow(t.kind, b) and contig
                t.rHa  := t.cHa
                t.rHaT := t.cHaT
                t.rLa  := t.cLa
                t.rLaT := t.cLaT
                t.rHb  := t.cHb
                t.rHbT := t.cHbT
                t.rLb  := t.cLb
                t.rLbT := t.cLbT
                t.live := true
                t.wBlk := b
                t.hi   := Side.new()
                t.lo   := Side.new()
            if dk != t.day
                t.nSmt  := 0
                t.nSync := 0
                t.nHeld := 0
            t.blk  := b
            t.day  := dk
            t.cHa  := high
            t.cHaT := time
            t.cLa  := low
            t.cLaT := time
            t.cHb  := bH
            t.cHbT := time
            t.cLb  := bL
            t.cLbT := time
            t.cN   := 1
        else
            if high > t.cHa
                t.cHa  := high
                t.cHaT := time
            if low < t.cLa
                t.cLa  := low
                t.cLaT := time
            if not na(bH) and (na(t.cHb) or bH > t.cHb)
                t.cHb  := bH
                t.cHbT := time
            if not na(bL) and (na(t.cLb) or bL < t.cLb)
                t.cLb  := bL
                t.cLbT := time
            t.cN += 1
        if t.live and m < 960
            t.check(t.hi, true, m)
            t.check(t.lo, false, m)
    t

// ═══════════════════════════════════════════════════════════════ Run (confirmed bars only, so nothing repaints)
int  tfSec = timeframe.in_seconds()
bool tfOK  = timeframe.isintraday and tfSec >= 60 and 1800 % tfSec == 0
int  mod   = hour(time, TZ) * 60 + minute(time, TZ)
int  dKey  = year(time, TZ) * 10000 + month(time, TZ) * 100 + dayofmonth(time, TZ)

var Track tr30 = Track.new("30m", "30", use30, c30H, c30L, w30, hi = Side.new(), lo = Side.new())
var Track tr60 = Track.new("60m", "1H", use60, c60H, c60L, w60, hi = Side.new(), lo = Side.new())
var Track trOR = Track.new("OR", "OR", useOR, cORH, cORL, wOR, hi = Side.new(), lo = Side.new())

var float oA   = na
var float oB   = na
var int   oDay = 0
var float rA   = na
var float rB   = na

if barstate.isconfirmed and tfOK and havePair
    // a new RTH day: count it, prune old drawings, take the 9:30 opens
    if mod >= 570 and mod < 960 and dKey != oDay
        oA   := open
        oB   := bO
        oDay := dKey
        dayN += 1
        dayTags.clear()
        while hist.size() > 0 and histD.get(0) <= dayN - keepD
            Side old = hist.shift()
            histD.shift()
            old.erase()
        while orLns.size() > 0 and orD.get(0) <= dayN - keepD
            line.delete(orLns.shift())
            orD.shift()
    if dKey == oDay and mod >= 570 and mod < 960
        rA := oA > 0 ? 100.0 * (close - oA) / oA : na
        rB := oB > 0 and not na(bC) ? 100.0 * (bC - oB) / oB : rB
    tr30.step(mod, dKey)
    tr60.step(mod, dKey)
    trOR.step(mod, dKey)
    if showORl and useOR and trOR.live and mod == 600
        int t1 = trOR.blk == 1 ? time + 360 * 60000 : time
        orLns.push(line.new(time - 30 * 60000, trOR.rHa, t1, trOR.rHa, xloc = xloc.bar_time, color = colORl, width = 1, style = line.style_dotted))
        orLns.push(line.new(time - 30 * 60000, trOR.rLa, t1, trOR.rLa, xloc = xloc.bar_time, color = colORl, width = 1, style = line.style_dotted))
        orD.push(dayN)
        orD.push(dayN)

// ═══════════════════════════════════════════════════════════════ Compact card
int nRef  = (use30 ? 1 : 0) + (use60 ? 1 : 0) + (useOR ? 1 : 0)
int rLead = crdLead ? 1 : 0
int nRows = 3 + rLead + nRef
var table tC = na
if barstate.isfirst and showCrd
    tC := table.new(posOf(crdPos), 3, nRows, bgcolor = #00000000, frame_width = 0, border_color = cBd, border_width = 1, force_overlay = true)
    for r = 0 to nRows - 1
        for c = 0 to 2
            tC.cell(c, r, "", bgcolor = solid(cBg), text_size = crdSz)
    tC.merge_cells(0, 0, 2, 0)
    tC.merge_cells(1, nRows - 1, 2, nRows - 1)

tc(int c, int r, string s, color fg, color bg, string tip = "", string ha = text.align_left) =>
    tC.cell(c, r, s, text_color = fg, bgcolor = solid(bg), text_size = crdSz, text_halign = ha, tooltip = tip, text_font_family = font.family_monospace)

sideCell(Track t, Side s, bool isHi) =>
    string sis = s.lead == 1 ? nmB : nmA
    color  c   = isHi ? t.cH : t.cL
    string tx  = s.st == 0 or s.st == 1 or s.st == 6 ? (t.live ? "○" : "—") : s.st == 5 ? "= both" : s.st == 2 ? "● " + sis + " " + pct(s.lagP) + (oddsOn and not na(s.pSync) ? " ↻" + pc0(s.pSync) : "") : s.st == 3 ? "◐ " + hm(s.tSync) : "■ " + sis + " " + pct(s.lagP)
    color  fg  = s.st == 2 or s.st == 4 ? c : s.st == 3 ? color.new(c, 40) : cMu
    color  bg  = s.st == 2 ? color.new(c, 88) : cBg
    [tx, fg, bg]

refRow(int r, Track t, string name) =>
    tc(0, r, name, cSub, cBg, na(t.wBlk) ? "" : "window " + winText(t.kind, t.wBlk) + " ET")
    [t1, f1, b1] = sideCell(t, t.hi, true)
    [t2, f2, b2] = sideCell(t, t.lo, false)
    tc(1, r, t1, f1, b1, t.hi.st >= 2 and t.hi.st <= 4 ? tipText(t, t.hi, true) : "")
    tc(2, r, t2, f2, b2, t.lo.st >= 2 and t.lo.st <= 4 ? tipText(t, t.lo, false) : "")

if barstate.islast and showCrd and not na(tC)
    string live = barstate.isrealtime ? "● " : "◆ "
    tc(0, 0, live + "GENJUTSU KAI   " + nmA + " × " + nmB + "   " + stamp(time) + (showRoll and rollWk ? "   ROLL WK" : ""), cTx, cHd, "● open · ◐ synced · ■ held · ○ nothing yet · — window over · = both took (no SMT). The number is how far the sick sister is behind" + (oddsOn ? "; ↻ = sync odds, the chance it still takes its level before the window ends" : "") + "; hover a cell for the full read." + (showRoll and rollWk ? "\nROLL WK: the quarterly roll week. SMT fades won 54% of 1σ races in roll weeks 2018–24 and 58% in 2025–26 vs 49% in other weeks (fished head, held out of sample, small test)." : ""))
    int r = 1
    if crdLead
        if not tfOK
            tc(0, r, "chart", cSub, cBg)
            tc(1, r, "use 1–30 min", cTx, cBg)
            tc(2, r, "(divides 30)", cMu, cBg)
        else if not havePair
            tc(0, r, "pair", cSub, cBg)
            tc(1, r, "set Compare with", cTx, cBg)
            tc(2, r, "", cMu, cBg)
        else if oDay != dKey
            tc(0, r, "9:30→", cSub, cBg)
            tc(1, r, "waiting for 9:30", cMu, cBg)
            tc(2, r, "", cMu, cBg)
        else
            string ld = na(rA) or na(rB) ? "" : ((math.sign(rA + rB) >= 0 ? rA >= rB : rA <= rB) ? nmA : nmB) + " leads"
            tc(0, r, "9:30→", cSub, cBg, "Move since the 9:30 ET open. The leader has moved further in the direction both are going.")
            tc(1, r, nmA + " " + (na(rA) ? "—" : sgnPct(rA)) + "  " + nmB + " " + (na(rB) ? "—" : sgnPct(rB)), cTx, cBg)
            tc(2, r, ld, cTx, cHd, na(rA) or na(rB) ? "" : "by " + str.tostring(math.abs(rA - rB), "0.00") + " pp")
        r += 1
    tc(0, r, "", cMu, cHd)
    tc(1, r, "HIGH ▼", cSub, cHd)
    tc(2, r, "LOW ▲", cSub, cHd)
    r += 1
    if use30
        refRow(r, tr30, "30m")
        r += 1
    if use60
        refRow(r, tr60, "1H")
        r += 1
    if useOR
        refRow(r, trOR, "OR")
        r += 1
    int nS = tr30.nSmt + tr60.nSmt + trOR.nSmt
    int nY = tr30.nSync + tr60.nSync + trOR.nSync
    int nH = tr30.nHeld + tr60.nHeld + trOR.nHeld
    tc(0, r, "today", cSub, cBg)
    tc(1, r, str.tostring(nS) + " · " + str.tostring(nY) + " synced · " + str.tostring(nH) + " held", cTx, cBg)
````
