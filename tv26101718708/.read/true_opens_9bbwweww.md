# True Opens 

- url: https://www.tradingview.com/script/9BBwwEWW-True-Opens/
- type: indicator
- pine_id: PUB;95c288a116404705b5d1c8b1849bbe1e
- version: 1.0

## Description

**True Opens** plots the full set of ICT-style anchored session opens — TMSO, AsiaTrueOpen, LDNTrueOpen, AMTrueOpen, PMTrueOpen, TDO, TWO, TMO, WkO — alongside 9 configurable fixed-time opens, with a live status dashboard showing whether price is above or below each level right now.

## What it does

In Inner Circle Trader methodology every session has a **true open** — the price at the second 90-minute quarter (Q2) of that session — which has historically acted as a magnet level for the rest of the day, week or month. The script computes them automatically:

- **TMSO** — Micro Q2 (every 22.5 min, micro-structure reference)
- **AsiaTrueOpen** — Asia session Q2 (19:30 ET)
- **LDNTrueOpen** — London session Q2 (01:30 ET)
- **AMTrueOpen** — NY AM Q2 (07:30 ET)
- **PMTrueOpen** — NY PM Q2 (13:30 ET)
- **TDO** — True Day Open (Day Q2 = London Open 00:00 ET)
- **TWO** — True Week Open (Week Q2 = Tuesday ICT day = Mon 18:00 ET)
- **TMO** — True Month Open (Month Q2 = 2nd Monday 00:00 ET)
- **WkO** — Sunday 18:00 ET futures weekly open

Plus 9 **fixed-time opens** (Asia Open, Asia Kill, LDN Kill, LDN Open, 07:00, 08:00, NY 08:30, 09:30 NYSE, LDN Cl. Kill) — each independently toggleable with a customizable time.

## Features

- **Live dashboard** showing every enabled level with current Above/Below status against close
- **Color-coded by tier** — macro levels (TMO, TWO, TDO) are most prominent; micro levels are subdued so they don't dominate the chart
- **Auto-hide on higher TFs** — TMSO hides above 15m, intraday TOs above 60m, TDO above 4H. TWO / TMO / WkO are always shown
- **Precise prices** — uses 1-minute `request.security` to capture the exact open at each ICT trigger time, even on higher chart timeframes. So a TDO on a 30m chart still shows the real 00:00 ET 1m open, not the 30m bar's open.
- **9 built-in alerts** — "Formed" alerts for each True Open type plus "Price crosses" alerts for TDO / TWO / TMO / WkO
- **Configurable line style, width, forward extension, and color** per level
- **Labels track each line's right tip** as the line extends forward each bar
- **Auto-clears at correct times** — each level expires at its proper "kill" time and redraws fresh on the next session/day/week/month

## How to use

**Reference levels for trade location**: TDO, TWO, TMO and WkO are macro magnets — price returning to them often signals a turn. AsiaTrueOpen / LDN / AM / PM TrueOpens act as intraday session pivots.

**Above-or-below bias**: glance the dashboard. If price is above TDO, TWO and TMO simultaneously you're in stacked-bullish posture. Mixed = no edge.

**Confluence**: zones where multiple True Opens cluster within a tight band are high-probability reaction levels. Watch where price returns to two or three of them at once.

## Settings

Grouped into **True Opens (Q2-based)**, **True Opens – Colors**, **Fixed-Time Opens**, **Fixed-Time Opens – Colors**, **Line Style**, **Dashboard**. Every input has a tooltip explaining the level it controls.

## Notes

- All session times are NY/ET — Pine handles DST automatically.
- TWO / TMO / WkO use lookahead-enabled 1m `request.security` for precise opens — these are reference levels (not signal triggers) so the lookahead is intentional and the captured prices don't repaint.
- Designed for intraday use (1m–4H). On daily+ charts the intraday TOs auto-hide; only TWO / TMO / WkO remain.
- Fixed-Time Opens run continuously from each open to the next day's same trigger — no mid-session freeze.

## License

Source code is released under the Mozilla Public License 2.0.

## Source Code

````pine
// This Pine Script™ source code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/

//@version=6
indicator("True Opens [v0.11]", "True Opens", true,
     max_lines_count  = 500,
     max_labels_count = 500)


// ═══════════════════════════════════════════════════════════════
//  §1  INPUTS
// ═══════════════════════════════════════════════════════════════

string G_TO = "True Opens (Q2-based)"
bool i_toTmso = input.bool(true, "TMSO – Micro Q2",                    group = G_TO)
bool i_toAso  = input.bool(true, "AsiaTrueOpen – Asia Q2",             group = G_TO)
bool i_toLdo  = input.bool(true, "LDNTrueOpen – London Q2",            group = G_TO)
bool i_toAmo  = input.bool(true, "AMTrueOpen – NY AM Q2",              group = G_TO)
bool i_toPmo  = input.bool(true, "PMTrueOpen – NY PM Q2",              group = G_TO)
bool i_toTdo  = input.bool(true, "TDO – Day Q2",                       group = G_TO)
bool i_toTwo  = input.bool(true, "TWO – Week Q2",                      group = G_TO)
bool i_toTmo  = input.bool(true, "TMO – Month Q2",                     group = G_TO)
bool i_toWkO  = input.bool(true, "WkO – Sun 18:00 Open",               group = G_TO)
bool i_autoHide = input.bool(true, "Auto-hide intraday TOs on higher TFs", group = G_TO,
     tooltip = "Hides TMSO above 15m, AsiaTrueOpen/LDNTrueOpen/AMTrueOpen/PMTrueOpen above 60m, TDO above 240m. TWO/TMO/WkO always shown.")

string G_TOC = "True Opens – Colors"
color i_clrTmso = input.color(color.new(#888888, 60), "TMSO",          group = G_TOC, tooltip = "Micro Q2 — fires every 22.5 min, lots of redraws. Subdued default.")
color i_clrAso  = input.color(color.new(#FB8C00, 50), "AsiaTrueOpen",  group = G_TOC, tooltip = "Asia session Q2 (19:30 ET).")
color i_clrLdo  = input.color(color.new(#1976D2, 45), "LDNTrueOpen",   group = G_TOC, tooltip = "London session Q2 (01:30 ET).")
color i_clrAmo  = input.color(color.new(#388E3C, 40), "AMTrueOpen",    group = G_TOC, tooltip = "NY AM session Q2 (07:30 ET).")
color i_clrPmo  = input.color(color.new(#7B1FA2, 40), "PMTrueOpen",    group = G_TOC, tooltip = "NY PM session Q2 (13:30 ET).")
color i_clrTdo  = input.color(color.new(#E65100, 20), "TDO",           group = G_TOC, tooltip = "True Day Open (Day Q2 = London Open at 00:00 ET).")
color i_clrTwo  = input.color(color.new(#0D47A1, 10), "TWO",           group = G_TOC, tooltip = "True Week Open (Week Q2 = Tuesday's ICT day = Mon 18:00 ET).")
color i_clrTmo  = input.color(color.new(#B71C1C, 0),  "TMO",           group = G_TOC, tooltip = "True Month Open (Month Q2 = 2nd Monday 00:00 ET). Highest-tier reference.")
color i_clrWkO  = input.color(color.new(#212121, 15), "WkO",           group = G_TOC, tooltip = "Sunday 18:00 ET — futures weekly open.")

string G_FT = "Fixed-Time Opens (NY/ET, HH:MM)"
bool   i_ftAsiaO_en = input.bool(true,    "Asia Open",    inline = "asiao", group = G_FT)
string i_ftAsiaO_t  = input.string("18:00", "",           inline = "asiao", group = G_FT)
bool   i_ftAsiaK_en = input.bool(true,    "Asia Kill",    inline = "asiak", group = G_FT)
string i_ftAsiaK_t  = input.string("20:00", "",           inline = "asiak", group = G_FT)
bool   i_ftLdnK_en  = input.bool(true,    "LDN Kill",     inline = "ldnk",  group = G_FT)
string i_ftLdnK_t   = input.string("02:00", "",           inline = "ldnk",  group = G_FT)
bool   i_ftLdnO_en  = input.bool(true,    "LDN Open",     inline = "ldno",  group = G_FT)
string i_ftLdnO_t   = input.string("03:00", "",           inline = "ldno",  group = G_FT)
bool   i_ft0700_en  = input.bool(true,    "07:00",        inline = "o0700", group = G_FT)
string i_ft0700_t   = input.string("07:00", "",           inline = "o0700", group = G_FT)
bool   i_ft0800_en  = input.bool(true,    "08:00",        inline = "o0800", group = G_FT)
string i_ft0800_t   = input.string("08:00", "",           inline = "o0800", group = G_FT)
bool   i_ft0830_en  = input.bool(true,    "NY 08:30",     inline = "o0830", group = G_FT)
string i_ft0830_t   = input.string("08:30", "",           inline = "o0830", group = G_FT)
bool   i_ft0930_en  = input.bool(true,    "09:30 NYSE",   inline = "o0930", group = G_FT)
string i_ft0930_t   = input.string("09:30", "",           inline = "o0930", group = G_FT)
bool   i_ftLdnCK_en = input.bool(true,    "LDN Cl. Kill", inline = "ldnck", group = G_FT)
string i_ftLdnCK_t  = input.string("10:00", "",           inline = "ldnck", group = G_FT)

string G_FTC = "Fixed-Time Opens – Colors"
color i_clrFtAsiaO = input.color(color.new(#FB8C00, 45), "Asia Open",     group = G_FTC)
color i_clrFtAsiaK = input.color(color.new(#FFB300, 42), "Asia Kill",     group = G_FTC)
color i_clrFtLdnK  = input.color(color.new(#1976D2, 40), "LDN Kill",      group = G_FTC)
color i_clrFtLdnO  = input.color(color.new(#0D47A1, 38), "LDN Open",      group = G_FTC)
color i_clrFt0700  = input.color(color.new(#616161, 35), "07:00",         group = G_FTC)
color i_clrFt0800  = input.color(color.new(#757575, 32), "08:00",         group = G_FTC)
color i_clrFt0830  = input.color(color.new(#E65100, 30), "NY 08:30",      group = G_FTC, tooltip = "Common news release time — make distinct.")
color i_clrFt0930  = input.color(color.new(#C62828, 28), "09:30 NYSE",    group = G_FTC, tooltip = "NYSE cash open — high importance.")
color i_clrFtLdnCK = input.color(color.new(#5D4037, 26), "LDN Cl. Kill",  group = G_FTC)

string G_STY = "Line Style"
string i_sty = input.string("Dotted", "Line Style", options = ["Solid", "Dashed", "Dotted"], group = G_STY)
int    i_wid = input.int(1, "Line Width", minval = 1, maxval = 4, group = G_STY)
int    i_off = input.int(10, "Line Forward Extension (bars)", minval = 1, maxval = 100, group = G_STY)
bool   i_showLabels = input.bool(true, "Show line labels on chart", group = G_STY, tooltip = "ON (default): each label sits at the right tip of its line and tracks the tip as the line extends. OFF: clean chart, no labels — identify lines via the dashboard.")

string G_DASH = "Dashboard"
bool   i_showTbl = input.bool(true, "Show Dashboard", group = G_DASH)
string i_tblPos  = input.string("Top Right", "Position",
     options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group = G_DASH)


// ═══════════════════════════════════════════════════════════════
//  §2  HELPERS
// ═══════════════════════════════════════════════════════════════

var string TZ = "America/New_York"

f_parseHM(string s) =>
    array<string> _p = str.split(s, ":")
    int _h = math.round(nz(str.tonumber(array.get(_p, 0)), 0))
    int _m = array.size(_p) > 1 ? math.round(nz(str.tonumber(array.get(_p, 1)), 0)) : 0
    _h * 60 + _m

f_lineStyle() =>
    switch i_sty
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        => line.style_dotted

f_pos() =>
    switch i_tblPos
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        => position.bottom_right

int bm_now  = hour(time, TZ) * 60 + minute(time, TZ)
int bm_prev = nz(hour(time[1], TZ) * 60 + minute(time[1], TZ), bm_now)

// v0.11: clean ascending cross. v0.10 had `or bm_prev >= 1080` in the
// target<1080 branch, which fired on every session-0 bar (18:00-23:59 ET)
// for any target already crossed earlier that day. On a 30m chart that
// re-drew FT opens 11x per evening (last redraw landed at 23:30 — the
// "23:59" stacked-label cluster) and clobbered LDN/AM/PM/TWO/WkO clears.
f_cross(int target) =>
    bm_now >= target and bm_prev < target

f_draw(line oldLn, label oldLb, string txt, color c, float px) =>
    if not na(oldLn)
        oldLn.delete()
    if not na(oldLb)
        oldLb.delete()
    line  ln  = line.new(bar_index, px, bar_index + i_off, px,
         color = c, style = f_lineStyle(), width = i_wid)
    label lb  = na
    if i_showLabels
        lb := label.new(bar_index + i_off, px, txt,
             xloc = xloc.bar_index,
             style = label.style_none, textcolor = c, size = size.tiny)
    [ln, lb]

f_clear(line oldLn, label oldLb) =>
    if not na(oldLn)
        oldLn.delete()
    if not na(oldLb)
        oldLb.delete()
    [line(na), label(na)]

// v0.11: label.x tracks line.x2 each bar so the text sits at the line's
// CURRENT right tip — not at a fixed historical x. Older versions anchored
// labels at draw-time + i_off bars; once the line extended past that point
// the label was stranded inside the line. Multiple labels with similar
// prices may visually overlap at the right edge — that's the tradeoff.
f_extend(line ln, label lb) =>
    if not na(ln)
        ln.set_x2(bar_index + i_off)
    if not na(lb)
        lb.set_x(bar_index + i_off)

f_firstMonDom(int y, int m) =>
    int _ts  = timestamp(TZ, y, m, 1, 0, 0)
    int _d   = dayofweek(_ts, TZ)
    int _add = _d == dayofweek.monday ? 0 :
               _d == dayofweek.sunday ? 1 :
               9 - _d
    1 + _add

f_capTDO() =>
    var float _val = na
    if hour(time, TZ) == 0 and minute(time, TZ) == 0
        _val := open
    _val

f_capTWO() =>
    var float _val = na
    if hour(time, TZ) == 18 and minute(time, TZ) == 0 and dayofweek(time, TZ) == dayofweek.monday
        _val := open
    _val

f_capTMO() =>
    var float _val = na
    if hour(time, TZ) == 0 and minute(time, TZ) == 0 and dayofweek(time, TZ) == dayofweek.monday
        int _dom = dayofmonth(time, TZ)
        if _dom >= 8 and _dom <= 14
            _val := open
    _val

f_capWkO() =>
    var float _val = na
    if hour(time, TZ) == 18 and minute(time, TZ) == 0 and dayofweek(time, TZ) == dayofweek.sunday
        _val := open
    _val


// ═══════════════════════════════════════════════════════════════
//  §3  SESSION + QUARTER CLASSIFICATION
// ═══════════════════════════════════════════════════════════════

f_sess(int bm) =>
    int _s = 3
    if bm >= 1080
        _s := 0
    else if bm < 360
        _s := 1
    else if bm < 720
        _s := 2
    _s

f_sessStart(int s) =>
    s == 0 ? 1080 : s == 1 ? 0 : s == 2 ? 360 : 720

int sess     = f_sess(bm_now)
int sessSt   = f_sessStart(sess)
int minsInS  = bm_now - sessSt
if minsInS < 0
    minsInS += 1440

int q90 = int(math.min(math.floor(minsInS / 90), 3)) + 1
float _m90 = minsInS % 90
int q22 = int(math.min(math.floor(_m90 / 22.5), 3)) + 1

int dow = dayofweek(time, TZ)
int dom = dayofmonth(time, TZ)
int curY = year(time, TZ)
int curM = month(time, TZ)

int firstMonDom = f_firstMonDom(curY, curM)
int weekOfMonth = dom < firstMonDom ? 0 : int(math.floor((dom - firstMonDom) / 7.0)) + 1

f_wkQ(int d, int s) =>
    int _e = d
    if s == 0
        _e := d == dayofweek.sunday    ? dayofweek.monday    :
              d == dayofweek.monday    ? dayofweek.tuesday   :
              d == dayofweek.tuesday   ? dayofweek.wednesday :
                                         dayofweek.thursday
    _e == dayofweek.monday    ? 1 :
     _e == dayofweek.tuesday  ? 2 :
     _e == dayofweek.wednesday ? 3 : 4

int weekQ = f_wkQ(dow, sess)

bool newQ22  = q22         != nz(q22[1])
bool newQ90  = q90         != nz(q90[1])
bool newSess = sess        != nz(sess[1], sess)
bool newWkQ  = weekQ       != nz(weekQ[1])
bool newMoQ  = weekOfMonth != nz(weekOfMonth[1])

int  chartSec   = timeframe.in_seconds()
bool showTmso   = i_toTmso and (not i_autoHide or chartSec <= 900)
bool showSess   = (not i_autoHide or chartSec <= 3600)
bool showTdo    = i_toTdo  and (not i_autoHide or chartSec <= 14400)

float _capTDO = request.security(syminfo.tickerid, "1", f_capTDO(), lookahead = barmerge.lookahead_on)
float _capTWO = request.security(syminfo.tickerid, "1", f_capTWO(), lookahead = barmerge.lookahead_on)
float _capTMO = request.security(syminfo.tickerid, "1", f_capTMO(), lookahead = barmerge.lookahead_on)
float _capWkO = request.security(syminfo.tickerid, "1", f_capWkO(), lookahead = barmerge.lookahead_on)


// ═══════════════════════════════════════════════════════════════
//  §4  TRUE OPENS
// ═══════════════════════════════════════════════════════════════

var line  lnTmso = na
var label lbTmso = na
var float pxTmso = na
var line  lnAso  = na
var label lbAso  = na
var float pxAso  = na
var line  lnLdo  = na
var label lbLdo  = na
var float pxLdo  = na
var line  lnAmo  = na
var label lbAmo  = na
var float pxAmo  = na
var line  lnPmo  = na
var label lbPmo  = na
var float pxPmo  = na
var line  lnTdo  = na
var label lbTdo  = na
var float pxTdo  = na
var line  lnTwo  = na
var label lbTwo  = na
var float pxTwo  = na
var line  lnTmo  = na
var label lbTmo  = na
var float pxTmo  = na
var line  lnWkO  = na
var label lbWkO  = na
var float pxWkO  = na

if f_cross(1169)
    if not na(lnAso)
        lnAso.delete()
        lnAso := na
    if not na(lbAso)
        lbAso.delete()
        lbAso := na
    pxAso := na

if f_cross(89)
    if not na(lnLdo)
        lnLdo.delete()
        lnLdo := na
    if not na(lbLdo)
        lbLdo.delete()
        lbLdo := na
    pxLdo := na

if f_cross(449)
    if not na(lnAmo)
        lnAmo.delete()
        lnAmo := na
    if not na(lbAmo)
        lbAmo.delete()
        lbAmo := na
    pxAmo := na

if f_cross(809)
    if not na(lnPmo)
        lnPmo.delete()
        lnPmo := na
    if not na(lbPmo)
        lbPmo.delete()
        lbPmo := na
    pxPmo := na

if f_cross(1439)
    if not na(lnTdo)
        lnTdo.delete()
        lnTdo := na
    if not na(lbTdo)
        lbTdo.delete()
        lbTdo := na
    pxTdo := na

if f_cross(1079) and dow == dayofweek.monday
    if not na(lnTwo)
        lnTwo.delete()
        lnTwo := na
    if not na(lbTwo)
        lbTwo.delete()
        lbTwo := na
    pxTwo := na

if f_cross(1079) and dow == dayofweek.sunday
    if not na(lnWkO)
        lnWkO.delete()
        lnWkO := na
    if not na(lbWkO)
        lbWkO.delete()
        lbWkO := na
    pxWkO := na

if f_cross(1439) and dow == dayofweek.sunday
    int _tomDom = dayofmonth(time + 86400000, TZ)
    int _tomDow = dayofweek(time + 86400000, TZ)
    if _tomDow == dayofweek.monday and _tomDom >= 8 and _tomDom <= 14
        if not na(lnTmo)
            lnTmo.delete()
            lnTmo := na
        if not na(lbTmo)
            lbTmo.delete()
            lbTmo := na
        pxTmo := na

if showTmso and newQ22 and q22 == 2
    [a, b] = f_draw(lnTmso, lbTmso, "TMSO", i_clrTmso, open)
    lnTmso := a
    lbTmso := b
    pxTmso := open

if i_toAso and showSess and sess == 0 and newQ90 and q90 == 2
    [a, b] = f_draw(lnAso, lbAso, "AsiaTrueOpen", i_clrAso, open)
    lnAso := a
    lbAso := b
    pxAso := open

if i_toLdo and showSess and sess == 1 and newQ90 and q90 == 2
    [a, b] = f_draw(lnLdo, lbLdo, "LDNTrueOpen", i_clrLdo, open)
    lnLdo := a
    lbLdo := b
    pxLdo := open

if i_toAmo and showSess and sess == 2 and newQ90 and q90 == 2
    [a, b] = f_draw(lnAmo, lbAmo, "AMTrueOpen", i_clrAmo, open)
    lnAmo := a
    lbAmo := b
    pxAmo := open

if i_toPmo and showSess and sess == 3 and newQ90 and q90 == 2
    [a, b] = f_draw(lnPmo, lbPmo, "PMTrueOpen", i_clrPmo, open)
    lnPmo := a
    lbPmo := b
    pxPmo := open

if showTdo and newSess and sess == 1
    float _px = not na(_capTDO) ? _capTDO : open
    [a, b] = f_draw(lnTdo, lbTdo, "TDO", i_clrTdo, _px)
    lnTdo := a
    lbTdo := b
    pxTdo := _px

if i_toTwo and newWkQ and weekQ == 2
    float _px = not na(_capTWO) ? _capTWO : open
    [a, b] = f_draw(lnTwo, lbTwo, "TWO", i_clrTwo, _px)
    lnTwo := a
    lbTwo := b
    pxTwo := _px

if i_toTmo and newMoQ and weekOfMonth == 2
    float _px = not na(_capTMO) ? _capTMO : open
    [a, b] = f_draw(lnTmo, lbTmo, "TMO", i_clrTmo, _px)
    lnTmo := a
    lbTmo := b
    pxTmo := _px

bool isWkOpen = dow == dayofweek.sunday and f_cross(1080)
if i_toWkO and isWkOpen
    float _px = not na(_capWkO) ? _capWkO : open
    [a, b] = f_draw(lnWkO, lbWkO, "WkO", i_clrWkO, _px)
    lnWkO := a
    lbWkO := b
    pxWkO := _px

f_extend(lnTmso, lbTmso)
f_extend(lnAso,  lbAso)
f_extend(lnLdo,  lbLdo)
f_extend(lnAmo,  lbAmo)
f_extend(lnPmo,  lbPmo)
f_extend(lnTdo,  lbTdo)
f_extend(lnTwo,  lbTwo)
f_extend(lnTmo,  lbTmo)
f_extend(lnWkO,  lbWkO)


// ═══════════════════════════════════════════════════════════════
//  §4b  ALERTS
// ═══════════════════════════════════════════════════════════════

alertcondition(showTmso and newQ22 and q22 == 2,                              title = "TMSO Formed",          message = "TMSO formed (micro Q2)")
alertcondition(i_toAso and showSess and sess == 0 and newQ90 and q90 == 2,    title = "AsiaTrueOpen Formed",  message = "AsiaTrueOpen formed (Asia Q2)")
alertcondition(i_toLdo and showSess and sess == 1 and newQ90 and q90 == 2,    title = "LDNTrueOpen Formed",   message = "LDNTrueOpen formed (London Q2)")
alertcondition(i_toAmo and showSess and sess == 2 and newQ90 and q90 == 2,    title = "AMTrueOpen Formed",    message = "AMTrueOpen formed (AM Q2)")
alertcondition(i_toPmo and showSess and sess == 3 and newQ90 and q90 == 2,    title = "PMTrueOpen Formed",    message = "PMTrueOpen formed (PM Q2)")
alertcondition(showTdo and newSess and sess == 1,                             title = "TDO Formed",           message = "TDO formed (Day Q2 / London open)")
alertcondition(i_toTwo and newWkQ and weekQ == 2,                             title = "TWO Formed",           message = "TWO formed (Week Q2 / Tuesday)")
alertcondition(i_toTmo and newMoQ and weekOfMonth == 2,                       title = "TMO Formed",           message = "TMO formed (Month Q2 / 2nd Monday)")
alertcondition(i_toWkO and isWkOpen,                                          title = "WkO Formed",           message = "Weekly Open (Sun 18:00 ET)")

bool _cTdo = ta.cross(close, pxTdo)
bool _cTwo = ta.cross(close, pxTwo)
bool _cTmo = ta.cross(close, pxTmo)
bool _cWkO = ta.cross(close, pxWkO)
bool xTdo  = not na(pxTdo) and _cTdo
bool xTwo  = not na(pxTwo) and _cTwo
bool xTmo  = not na(pxTmo) and _cTmo
bool xWkO  = not na(pxWkO) and _cWkO
alertcondition(xTdo, title = "Price crosses TDO", message = "Price crossed TDO")
alertcondition(xTwo, title = "Price crosses TWO", message = "Price crossed TWO")
alertcondition(xTmo, title = "Price crosses TMO", message = "Price crossed TMO")
alertcondition(xWkO, title = "Price crosses WkO", message = "Price crossed Weekly Open")


// ═══════════════════════════════════════════════════════════════
//  §5  FIXED-TIME OPENS
// ═══════════════════════════════════════════════════════════════
// v0.11: removed the 16:00-17:59 ET freeze. With f_cross fixed each FT
// line now runs cleanly from its open to the next day's same trigger.

const int FT_N = 9

array<bool>   ft_en  = array.from(i_ftAsiaO_en, i_ftAsiaK_en, i_ftLdnK_en, i_ftLdnO_en, i_ft0700_en, i_ft0800_en, i_ft0830_en, i_ft0930_en, i_ftLdnCK_en)
array<string> ft_tx  = array.from("Asia Open", "Asia Kill", "LDN Kill", "LDN Open", "07:00", "08:00", "NY 08:30", "09:30 NYSE", "LDN Cl. Kill")
array<int>    ft_tgt = array.from(f_parseHM(i_ftAsiaO_t), f_parseHM(i_ftAsiaK_t), f_parseHM(i_ftLdnK_t), f_parseHM(i_ftLdnO_t), f_parseHM(i_ft0700_t), f_parseHM(i_ft0800_t), f_parseHM(i_ft0830_t), f_parseHM(i_ft0930_t), f_parseHM(i_ftLdnCK_t))
array<color>  ft_clr = array.from(i_clrFtAsiaO, i_clrFtAsiaK, i_clrFtLdnK, i_clrFtLdnO, i_clrFt0700, i_clrFt0800, i_clrFt0830, i_clrFt0930, i_clrFtLdnCK)

var array<line>  ft_ln = array.new<line>(FT_N, na)
var array<label> ft_lb = array.new<label>(FT_N, na)
var array<float> ft_px = array.new<float>(FT_N, na)

for i = 0 to FT_N - 1
    bool en  = array.get(ft_en, i)
    int  tgt = array.get(ft_tgt, i)

    if not en and not na(array.get(ft_ln, i))
        [cl_l, cl_b] = f_clear(array.get(ft_ln, i), array.get(ft_lb, i))
        array.set(ft_ln, i, cl_l)
        array.set(ft_lb, i, cl_b)
        array.set(ft_px, i, na)

    if en and f_cross(tgt)
        [dr_l, dr_b] = f_draw(array.get(ft_ln, i), array.get(ft_lb, i),
             array.get(ft_tx, i), array.get(ft_clr, i), open)
        array.set(ft_ln, i, dr_l)
        array.set(ft_lb, i, dr_b)
        array.set(ft_px, i, open)

    if en
        f_extend(array.get(ft_ln, i), array.get(ft_lb, i))


// ═══════════════════════════════════════════════════════════════
//  §6  DASHBOARD
// ═══════════════════════════════════════════════════════════════

f_status(float px) =>
    string s = na(px) ? "-" : (close >= px ? "Above" : "Below")
    color  c = na(px) ? #999999 : (close >= px ? #1565C0 : #C62828)
    [s, c]

int rowsCnt = 2
if i_toTmso
    rowsCnt += 1
if i_toAso or i_toLdo or i_toAmo or i_toPmo
    rowsCnt += 1
if i_toTdo
    rowsCnt += 1
if i_toTwo
    rowsCnt += 1
if i_toTmo
    rowsCnt += 1
if i_toWkO
    rowsCnt += 1
for i = 0 to FT_N - 1
    if array.get(ft_en, i)
        rowsCnt += 1

var table tbl = na

if i_showTbl and barstate.islast
    if not na(tbl)
        tbl.delete()
    tbl := table.new(f_pos(), 2, rowsCnt,
         border_color = color.new(#e0e0e0, 0), border_width = 1,
         frame_color  = color.new(#bdbdbd, 0), frame_width  = 1)

    tbl.cell(0, 0, "True Open", text_color = #ffffff, bgcolor = #424242, text_size = size.small)
    tbl.cell(1, 0, "Status",    text_color = #ffffff, bgcolor = #424242, text_size = size.small)

    string nowEt = str.format("{0,number,00}:{1,number,00}", hour(timenow, TZ), minute(timenow, TZ))
    tbl.cell(0, 1, "Now (ET)", text_color = #333333, bgcolor = #fff8dc, text_size = size.small)
    tbl.cell(1, 1, nowEt,      text_color = #333333, bgcolor = #fff8dc, text_size = size.small)

    int r = 2

    if i_toTmso
        [s, c] = f_status(pxTmso)
        tbl.cell(0, r, "TMSO", text_color = #333333, bgcolor = #fafafa, text_size = size.small)
        tbl.cell(1, r, s, text_color = c, bgcolor = #fafafa, text_size = size.small)
        r += 1

    if i_toAso or i_toLdo or i_toAmo or i_toPmo
        string slbl = "PMTrueOpen"
        float  spx  = pxPmo
        if sess == 0
            slbl := "AsiaTrueOpen"
            spx  := pxAso
        else if sess == 1
            slbl := "LDNTrueOpen"
            spx  := pxLdo
        else if sess == 2
            slbl := "AMTrueOpen"
            spx  := pxAmo
        [s, c] = f_status(spx)
        tbl.cell(0, r, slbl, text_color = #333333, bgcolor = #fafafa, text_size = size.small)
        tbl.cell(1, r, s, text_color = c, bgcolor = #fafafa, text_size = size.small)
        r += 1

    if i_toTdo
        [s, c] = f_status(pxTdo)
        tbl.cell(0, r, "TDO", text_color = #333333, bgcolor = #fafafa, text_size = size.small)
        tbl.cell(1, r, s, text_color = c, bgcolor = #fafafa, text_size = size.small)
        r += 1

    if i_toTwo
        [s, c] = f_status(pxTwo)
        tbl.cell(0, r, "TWO", text_color = #333333, bgcolor = #fafafa, text_size = size.small)
        tbl.cell(1, r, s, text_color = c, bgcolor = #fafafa, text_size = size.small)
        r += 1

    if i_toTmo
        [s, c] = f_status(pxTmo)
        tbl.cell(0, r, "TMO", text_color = #333333, bgcolor = #fafafa, text_size = size.small)
        tbl.cell(1, r, s, text_color = c, bgcolor = #fafafa, text_size = size.small)
        r += 1

    if i_toWkO
        [s, c] = f_status(pxWkO)
        tbl.cell(0, r, "WkO", text_color = #333333, bgcolor = #fafafa, text_size = size.small)
        tbl.cell(1, r, s, text_color = c, bgcolor = #fafafa, text_size = size.small)
        r += 1

    for i = 0 to FT_N - 1
        if array.get(ft_en, i)
            [s, c] = f_status(array.get(ft_px, i))
            tbl.cell(0, r, array.get(ft_tx, i), text_color = #333333, bgcolor = #fafafa, text_size = size.small)
            tbl.cell(1, r, s, text_color = c, bgcolor = #fafafa, text_size = size.small)
            r += 1


// ═══════════════════════════════════════════════════════════════
//  END
// ═══════════════════════════════════════════════════════════════
````
