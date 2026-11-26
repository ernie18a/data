# Impulse Origin [Smart Money]

- url: https://www.tradingview.com/script/4fZcUOKi-Impulse-Origin-Smart-Money/
- type: indicator
- pine_id: PUB;8ab540ec32d94cc993348ae48d8c1307
- version: 1.0

## Description

A strong move only tells you it mattered once it is over. Impulse Origin waits for that moment: a run that closes in one direction for a set number of bars without a single counter-close, ending on a bar whose volume has expanded against its own average. When that run is complete, the tool walks back and marks the candle it started from — and not just any opposing candle, but one whose liquidity was taken by the candle that came after it. The result is a zone at the origin of the move, which is then tracked: the first close through it flips its role between support and resistance, and the second close through it retires it.

[b]HOW IT WORKS[/b]

The idea behind it is that the beginning of a move is only interesting if the move turned out to be decisive, and you cannot know that while it is still running. So the measurement is deliberately backward-looking: the run is the gate, the origin is the output.

[list]
[*][b]The run[/b] — over the last N bars there must be no close against the direction at all. A single lower close breaks an up-run; a single higher close breaks a down-run. This is measured on closes, not on candle bodies, so the run describes where price actually settled bar after bar.
[*][b]The volume gate[/b] — the bar that completes the run must carry at least a chosen multiple of the average volume over its own baseline period. The baseline is independent of the run length, so a long run cannot inflate its own reference level.
[*][b]The origin[/b] — from that bar the tool searches backwards for the first candle that closed against its own open: a down candle for an up-run, an up candle for a down-run. This is the candle price left from.
[*][b]The sweep requirement[/b] — an opposing candle only qualifies as an origin if its liquidity was taken by the candle immediately after it. For a support origin, the next candle's low must trade below the origin low; for a resistance origin, the next candle's high must trade above the origin high. Search Back keeps walking further back until such a candle is found. First Only tests just the first opposing candle and draws nothing if it does not qualify. Off removes the requirement entirely and uses the opposing candle alone.
[*][b]The zone[/b] — with the sweep requirement active, the zone spans the combined range of the origin candle and the candle that swept it, so the swept level sits inside the zone rather than at its edge. The zone is anchored to the origin candle and extends forward from there.
[*][b]Role tracking[/b] — a zone holds a role until a bar closes beyond it. Wicks through it change nothing. On the first close beyond, the zone switches colour and swaps role: a support that is closed through becomes resistance, a resistance that is closed through becomes support. On the second close beyond, it is removed from the chart.
[/list]

An uninterrupted run of higher closes therefore produces a support zone below, at the candle the run started from — and a run of lower closes produces a resistance zone above, the same way.

[list=1]
[*]A run of N bars completes with no counter-close and with expanded volume on the final bar
[*]The tool searches backwards for the opposing candle that started it, keeping only one whose low or high was taken by the candle after it
[*]The zone is drawn from that candle, then tracked: first close through it flips the role, second close through it removes it
[/list]

Original zones and flipped zones are kept in separate pools with their own capacity, so a new signal never pushes out a zone that has already flipped. Because a long run can produce several trigger bars in a row that all resolve to the same origin candle, the tool remembers the origin it last used and will not redraw the same candle.

[b]HOW TO READ[/b]

[list]
[*]A zone marks where a decisive move began, with the stops below or above it already taken before it left. Price returning to that area is returning to the point it departed from.
[*]A grey zone is still in its original role. A blue zone has been closed through once and is now working the other way round — the level that was holding price up is now the level it is trading under, or the reverse.
[*]A blue zone is on its last life by design. The next close through it, now in its flipped role, removes it rather than leaving an old level on the chart forever.
[*]Only closes matter. A wick through a zone leaves it untouched, so a zone survives being tested and only changes when price actually settles on the other side.
[*]It fires rarely by design. A run with no counter-close at all, ending on expanded volume, is not a common event — on most charts you will see a handful of zones rather than a wall of them. Shorten the run length or lower the volume ratio for more, raise them for fewer and more selective ones.
[*]The shading carries no information: every zone is drawn at the same intensity, because the zone sits on the origin candle while the volume condition was measured on the bar that completed the run.
[/list]

[b]INPUTS[/b]

[list]
[*]Streak Length — how many consecutive bars must close in one direction with no counter-close.
[*]Volume Average Length — the baseline period the trigger bar's volume is measured against.
[*]Min Volume Ratio — how many times the average that volume must be. Higher gives fewer, more selective zones.
[*]Max Origin Lookback — how far back the search for the origin candle may run.
[*]Liquidity Sweep — Off, Search Back, or First Only, as described above.
[*]Original Support / Original Resistance — draw each side, with its own capacity for how many grey zones are kept.
[*]Flipped Support Max / Flipped Resistance Max — capacity for zones that have already flipped, held separately from the originals.
[*]ATR Length / Min Zone Height (%ATR) — if a zone is thinner than this share of ATR, it is expanded symmetrically around its midpoint. At 0 the zone keeps the exact range of the candles it came from.
[*]Colours / Transparency Offset — the original and flipped colours, and a single offset that shifts the tone of all zones together.
[/list]

[b]NOTES & LIMITS[/b]

A zone records where a decisive move began and whether that level has since been closed through. What you make of it at the next touch is yours, and that is exactly as it should be. The volume gate is part of the mechanism, so the tool needs a volume feed to produce anything at all — on a symbol that publishes no volume, no zones are drawn, and on forex and CFDs the volume is tick volume (the number of price updates, not contracts traded), which makes the gate read more loosely there. The zone is anchored to the origin candle in the past but is published on the close of the bar that completes the run, so on a chart you are scrolling back through, the zone was not on the screen for the bars between the two. Its price boundaries are set when it is created and never move afterwards: creation, the role flip and the removal all happen on closed bars, and the colour change is a change of state, not of level. The zone is as tall as the candles it came from — with the sweep requirement active that is the origin candle and the candle that swept it combined — so on volatile instruments it can be a wide band; Min Zone Height only ever expands a zone, never shrinks one. Breaks are judged on closes alone, so a wick beyond a zone leaves its role unchanged. No profit, win-rate, or guarantee claim. Open-source under CC BY-NC-SA 4.0 — non-commercial use, attribution to ElisTools required for reuse or derivatives. TradingView (Pine v6) only.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © ElisTools
// Impulse Origin [Smart Money] — Attribution required: credit "ElisTools" in any reuse or derivative.

//@version=6
indicator("Impulse Origin [Smart Money]", "Impulse Origin", overlay = true, max_boxes_count = 500, max_bars_back = 1000)


strkL = input.int   (7    , "Streak Length          ", group = "SETTINGS", minval = 2, maxval = 100, tooltip = "Number of consecutive closes in one direction required before a signal can form. No opposite close may occur within this window.")
volL  = input.int   (50   , "Volume Average Length  ", group = "SETTINGS", minval = 2, maxval = 500, tooltip = "Baseline period for the volume comparison. Independent of Streak Length, so the streak does not inflate its own reference level.")
minR  = input.float (1.5  , "Min Volume Ratio       ", group = "SETTINGS", minval = 0.1, maxval = 20.0, step = 0.1, tooltip = "The trigger bar's volume must be at least this multiple of the average. Higher values produce fewer, more selective signals.")
oLB   = input.int   (50   , "Max Origin Lookback    ", group = "SETTINGS", minval = 1, maxval = 500, tooltip = "Maximum number of bars to search backwards from the trigger bar when looking for the origin candle.")
swpM  = input.string("Search Back", "Liquidity Sweep", group = "SETTINGS", options = ["Off", "Search Back", "First Only"], tooltip = "The origin candle's liquidity must be taken by the candle immediately after it: for a support origin (down candle) the next candle's low must trade below the origin low; for a resistance origin (up candle) the next candle's high must trade above the origin high.\n\nOff — no sweep requirement; the zone is the origin candle only.\nSearch Back — keep walking back until a swept candle is found.\nFirst Only — test only the first opposite candle; draw nothing if it was not swept.\n\nIn both sweep modes the zone spans the COMBINED range of the origin candle and the candle that swept it.")

enSup = input.bool  (true , "Original Support       ", group = "ZONES   ", inline = "a", tooltip = "Draw support zones. These come from an up-run — an uninterrupted streak of higher closes — and are marked at the candle that launched it.")
shSup = input.int   (3    , "Max"                    , group = "ZONES   ", inline = "a", minval = 1, maxval = 50, tooltip = "How many original (grey) support zones are kept.")
enRes = input.bool  (true , "Original Resistance    ", group = "ZONES   ", inline = "b", tooltip = "Draw resistance zones. These come from a down-run — an uninterrupted streak of lower closes — and are marked at the candle that launched it.")
shRes = input.int   (3    , "Max"                    , group = "ZONES   ", inline = "b", minval = 1, maxval = 50, tooltip = "How many original (grey) resistance zones are kept.")

shFS  = input.int   (3    , "Flipped Support    Max ", group = "ZONES   ", minval = 1, maxval = 50, tooltip = "Capacity for zones that broke and now act as SUPPORT. This pool is independent of the original zone capacity, so a new signal never displaces a zone that has already flipped.")
shFR  = input.int   (3    , "Flipped Resistance Max ", group = "ZONES   ", minval = 1, maxval = 50, tooltip = "Capacity for zones that broke and now act as RESISTANCE. This pool is independent of the original zone capacity, so a new signal never displaces a zone that has already flipped.")

origC = input.color (color.gray, "Original             ", group = "ZONES   ", inline = "c")
flipC = input.color (#2962FF   , "Flipped              ", group = "ZONES   ", inline = "c")

atrL  = input.int   (14   , "ATR Length             ", group = "ZONES   ", minval = 1, maxval = 500, tooltip = "Period of the ATR used by Min Zone Height.")
mnPc  = input.float (0.0  , "Min Zone Height (%ATR) ", group = "ZONES   ", minval = 0.0, maxval = 300.0, step = 5.0, tooltip = "If a zone is thinner than this percentage of ATR, it is expanded symmetrically around its midpoint. Set to 0 to disable.")

zTr   = input.int   (0    , "Transparency Offset    ", group = "DISPLAY ", minval = -40, maxval = 40, tooltip = "Negative = more prominent, positive = fainter. All zones share a single tone; this setting shifts them together.")


type zone
    box   bx
    float top
    float bot
    bool  isSup      // current role: true = support, false = resistance

var array<zone> supZ  = array.new<zone>()    // original (grey), acting as support
var array<zone> resZ  = array.new<zone>()    // original (grey), acting as resistance
var array<zone> fSupZ = array.new<zone>()    // flipped (blue), acting as SUPPORT
var array<zone> fResZ = array.new<zone>()    // flipped (blue), acting as RESISTANCE

// Absolute bar index of the origin candle used most recently.
// Inside a long uninterrupted streak, consecutive bars resolve to the same
// origin; this guard stops the same candle from producing repeated zones.
var int lastSupOrig = -1
var int lastResOrig = -1

float sma = ta.sma(volume, volL)
float atr = ta.atr(atrL)
float mnH = atr * mnPc / 100.0

float vRat  = sma > 0 ? volume / sma : 0.0
bool  volOK = vRat >= minR

// One tone for every zone. Shading carries no information: the box sits on the
// origin candle while the volume condition is measured on the trigger bar.
int brdTr = math.max(0, math.min(100, 40 + zTr))
int bgTr  = math.max(0, math.min(100, 85 + zTr))


// ---------- 1) BLUE POOLS: second break -> DELETE ----------
// Runs first, so a zone that flips on this bar is not re-tested on the same bar.
killFlipped(array<zone> arr) =>
    bool k = false
    if barstate.isconfirmed and arr.size() > 0
        for i = arr.size() - 1 to 0
            zone z = arr.get(i)
            if z.isSup ? close < z.bot : close > z.top
                box.delete(z.bx)
                arr.remove(i)
                k := true
    k

bool fSupKill = killFlipped(fSupZ)
bool fResKill = killFlipped(fResZ)


// ---------- 2) GREY POOLS: first break -> FLIP ROLE and MOVE TO THE BLUE POOL ----------
// Wicks do not count: only closes are compared.
// Grey SUPPORT broken downwards  -> becomes RESISTANCE -> fResZ
// Grey RESISTANCE broken upwards -> becomes SUPPORT    -> fSupZ
processGray(array<zone> arr) =>
    bool fl = false
    if barstate.isconfirmed and arr.size() > 0
        for i = arr.size() - 1 to 0
            zone z = arr.get(i)
            if z.isSup ? close < z.bot : close > z.top
                z.isSup := not z.isSup
                box.set_border_color(z.bx, color.new(flipC, brdTr))
                box.set_bgcolor    (z.bx, color.new(flipC, bgTr))
                arr.remove(i)                          // leave the grey pool
                if z.isSup
                    fSupZ.unshift(z)
                else
                    fResZ.unshift(z)
                fl := true
    fl

bool supFlip = processGray(supZ)
bool resFlip = processGray(resZ)

while fSupZ.size() > shFS
    box.delete(fSupZ.pop().bx)

while fResZ.size() > shFR
    box.delete(fResZ.pop().bx)


// ---------- 3) STREAK DETECTION ----------
int upBrk = 0
int dnBrk = 0

for i = 0 to strkL - 1
    upBrk += close[i] < close[i + 1] ? 1 : 0
    dnBrk += close[i] > close[i + 1] ? 1 : 0

bool upExh = barstate.isconfirmed and enSup and upBrk == 0 and volOK
bool dnExh = barstate.isconfirmed and enRes and dnBrk == 0 and volOK


// ---------- 4) ORIGIN SEARCH + LIQUIDITY SWEEP ----------
// isUp = true  -> up move,   origin is a DOWN candle, liquidity sits at its LOW
// isUp = false -> down move, origin is an UP candle,  liquidity sits at its HIGH
findOrigin(simple bool isUp, simple int maxLB, simple string mode) =>
    int idx = -1
    for i = 1 to maxLB
        bool isOpp = isUp ? close[i] < open[i] : close[i] > open[i]
        if isOpp
            bool swept = mode == "Off" or (isUp ? low[i - 1] < low[i] : high[i - 1] > high[i])
            if swept
                idx := i
                break
            if mode == "First Only"
                break
    idx

int supIdx = upExh ? findOrigin(true , oLB, swpM) : -1
int resIdx = dnExh ? findOrigin(false, oLB, swpM) : -1

// Absolute bar index of the origin -- used by the repeat guard
int supOrig = supIdx >= 0 ? bar_index - supIdx : -1
int resOrig = resIdx >= 0 ? bar_index - resIdx : -1

bool supNew = supIdx >= 0 and supOrig != lastSupOrig
bool resNew = resIdx >= 0 and resOrig != lastResOrig


// ---------- 5) ZONE CONSTRUCTION ----------
// merge = true -> the zone spans the combined range of the origin and the candle that swept it
makeZone(int idx, bool isSup, bool merge) =>
    float hi  = merge ? math.max(high[idx], high[idx - 1]) : high[idx]
    float lo  = merge ? math.min(low [idx], low [idx - 1]) : low [idx]
    float mid = (hi + lo) / 2.0
    float top = math.max(hi, mid + mnH / 2.0)
    float bot = math.min(lo, mid - mnH / 2.0)

    box bx = box.new(
           left         = time[idx]
         , right        = time[idx] + 1
         , top          = top
         , bottom       = bot
         , xloc         = xloc.bar_time
         , extend       = extend.right
         , border_color = color.new(origC, brdTr)
         , border_width = 1
         , bgcolor      = color.new(origC, bgTr)
         )

    zone.new(bx, top, bot, isSup)


bool mrg = swpM != "Off"

if supNew
    lastSupOrig := supOrig
    supZ.unshift(makeZone(supIdx, true, mrg))
    while supZ.size() > shSup
        box.delete(supZ.pop().bx)

if resNew
    lastResOrig := resOrig
    resZ.unshift(makeZone(resIdx, false, mrg))
    while resZ.size() > shRes
        box.delete(resZ.pop().bx)


// ---------- ALERTS ----------
alertcondition(supNew, "Support Zone"   , "Impulse Origin: Support zone marked on bar close")
alertcondition(resNew, "Resistance Zone", "Impulse Origin: Resistance zone marked on bar close")
alertcondition(supNew or resNew, "Any Zone", "Impulse Origin: Zone marked on bar close")

alertcondition(supFlip, "Support Flipped to Resistance", "Impulse Origin: Support broken by close -- now resistance")
alertcondition(resFlip, "Resistance Flipped to Support", "Impulse Origin: Resistance broken by close -- now support")
alertcondition(supFlip or resFlip, "Any Zone Flipped", "Impulse Origin: Zone broken by close -- role flipped")

alertcondition(fSupKill, "Flipped Support Removed"   , "Impulse Origin: Flipped support broken again -- removed")
alertcondition(fResKill, "Flipped Resistance Removed", "Impulse Origin: Flipped resistance broken again -- removed")
alertcondition(fSupKill or fResKill, "Any Zone Removed", "Impulse Origin: Flipped zone broken again -- removed")
````
