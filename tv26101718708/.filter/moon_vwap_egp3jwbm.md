# Moon VWAP

- url: https://www.tradingview.com/script/Egp3jwBM-Moon-VWAP/
- type: indicator
- pine_id: PUB;089988a1f986414f8145e34b46fc09c3
- version: 4.0

## Description

Moon VWAP (MAVWAP) overlays anchored VWAP (AVWAP) segments that reset on calendar-based anchors you choose—primarily every New Moon (and optionally Full Moon), plus optional anchors for Mercury retrograde start, Venus retrograde start, Total Lunar Eclipse (TLE), Total Solar Eclipse (TSE), and a regime-flip anchor derived from your scripted eclipse rules.

What you get

Lunar markers: New Moon and Full Moon events (UTC), with styling options including August New Moon emphasis and optional ±day background tint around New Moons.
Retrograde context: Mercury (and optional Venus) retrograde start/end markers, optional in-span shading, optional shadow shading, and optional “open at Rx start” reference.
Eclipse markers: Total (and optional partial) lunar/solar eclipse marks.
Optional regime backdrop: Background tinting for a lunar-cycle vs solar-cycle interpretation (user-configurable rules in the inputs).
AVWAP suite: Separate toggles/colors for VWAP segments anchored to the events above—useful for tracking how price behaves from each anchor forward.
How to use

Pick which anchors matter for your process (most users start with New Moon AVWAP).
Choose marker style (emoji-only vs vertical lines) for a cleaner chart.
If something looks off vs your reference almanac, confirm the underlying UTC tables against your preferred astronomical source—this tool is for visual context, not a guarantee of timing precision on every feed.
Disclaimer: For education and research only. Not financial advice. Past performance does not guarantee future results. Astronomical/astrological cycle overlays are discretionary; verify critical dates independently.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Moon / eclipse AVWAP + GPS 0.618–0.65 pockets (completed + forming/future).
// Forming pockets: live cycle high/low → golden pocket projected to the next
// known astro lock time. UTC event tables. Toggle zones in settings / Style.

//@version=6
indicator("Moon VWAP + GPS", shorttitle="MoonVWAP", overlay=true, max_labels_count=500, max_boxes_count=400, max_bars_back=5000)

grpVW = "AVWAP (click Style legend to hide a line)"
showVwNew   = input.bool(true, "New Moon AVWAP", group=grpVW)
showVwFull  = input.bool(true, "Full Moon AVWAP", group=grpVW)
showVwTLE   = input.bool(true, "Total Lunar eclipse AVWAP", group=grpVW)
showVwTSE   = input.bool(true, "Total Solar eclipse AVWAP", group=grpVW)
vwNewColor  = input.color(color.new(color.teal, 0), "New Moon AVWAP color", group=grpVW)
vwFullColor = input.color(color.new(color.blue, 0), "Full Moon AVWAP color", group=grpVW)
vwTleColor  = input.color(color.new(#64B5F6, 0), "TLE AVWAP color", group=grpVW)
vwTseColor  = input.color(color.new(#E57373, 0), "TSE AVWAP color", group=grpVW)

grpGP = "GPS zones — each is its own toggle"
showGpNew   = input.bool(true, "GPS New Moon (prior New→New range)", group=grpGP)
showGpFull  = input.bool(true, "GPS Full Moon (prior Full→Full range)", group=grpGP)
showGpTLE   = input.bool(true, "GPS Total Lunar (prior TLE→TLE range)", group=grpGP)
showGpTSE   = input.bool(true, "GPS Total Solar (prior TSE→TSE range)", group=grpGP)
showGpPLE   = input.bool(true, "GPS Partial Lunar (prior PLE→PLE range)", group=grpGP)
showGpPSE   = input.bool(true, "GPS Partial Solar (prior PSE→PSE range)", group=grpGP)
gpHiFib     = input.float(0.618, "GP high fib (61.8%)", minval=0.50, maxval=0.70, step=0.001, group=grpGP)
gpLoFib     = input.float(0.65, "GP low fib (65%)", minval=0.50, maxval=0.80, step=0.001, group=grpGP)
gpNewFill   = input.color(color.new(color.teal, 88), "New Moon GPS fill", group=grpGP)
gpFullFill  = input.color(color.new(color.blue, 88), "Full Moon GPS fill", group=grpGP)
gpTleFill   = input.color(color.new(#64B5F6, 88), "TLE GPS fill", group=grpGP)
gpTseFill   = input.color(color.new(#E57373, 88), "TSE GPS fill", group=grpGP)
gpPleFill   = input.color(color.new(#90CAF9, 88), "PLE GPS fill", group=grpGP)
gpPseFill   = input.color(color.new(#EF9A9A, 88), "PSE GPS fill", group=grpGP)

grpPh = "LTF GPS — moon-phase legs (~7.4d)"
showGpN2Q   = input.bool(true, "GPS New → First Quarter", group=grpPh)
showGpQ2F   = input.bool(true, "GPS First Quarter → Full", group=grpPh)
showGpF2L   = input.bool(true, "GPS Full → Last Quarter", group=grpPh)
showGpL2N   = input.bool(true, "GPS Last Quarter → New", group=grpPh)
gpN2QFill   = input.color(color.new(#FFD54F, 88), "New→FQ fill", group=grpPh)
gpQ2FFill   = input.color(color.new(#FFB74D, 88), "FQ→Full fill", group=grpPh)
gpF2LFill   = input.color(color.new(#CE93D8, 88), "Full→LQ fill", group=grpPh)
gpL2NFill   = input.color(color.new(#80CBC4, 88), "LQ→New fill", group=grpPh)

grpNum = "Numerology — strongest tags only"
showAngleNum  = input.bool(true, "Tiny N / Q / F / L calendar chips (not signals)", group=grpNum)
showNineTicks = input.bool(false, "Mark lunation days 9 / 18 / 27 (calendar only)", group=grpNum)
showNumConf   = input.bool(true, "B / S — one tag per moon event, HTF GPS + number + tape", group=grpNum)
winExtraBars  = input.int(3, "Bars after event to hunt the candle (then lock)", minval=0, maxval=12, group=grpNum)
kissPct       = input.float(0.35, "AVWAP kiss % (tooltip only)", minval=0.05, maxval=2.0, step=0.05, group=grpNum)

grpFut = "Forming GPS — future pocket (locks at next astro time)"
showForming     = input.bool(true, "Show forming New/Full GPS (live cycle → next event)", group=grpFut, tooltip="The cycle running NOW has a known end. Its 0.618–0.65 pocket is drawn forward to that lock time and updates as the live high/low extends. Firm when ≥90% of the cycle is built.")
showFormingLegs = input.bool(false, "Also show forming phase-leg pockets", group=grpFut)
formMinProg     = input.float(0.25, "Hide forming until cycle progress ≥", minval=0.0, maxval=0.9, step=0.05, group=grpFut, tooltip="Skips early sketches. 0.25 ≈ 25% through; desk grades: sketch/rough/likely/firm.")
formFillNew     = input.color(color.new(color.teal, 92), "Forming New fill", group=grpFut)
formFillFull    = input.color(color.new(color.blue, 92), "Forming Full fill", group=grpFut)
formFillLeg     = input.color(color.new(#FFD54F, 93), "Forming leg fill", group=grpFut)

grpPct = "% away labels (last bar)"
showVwapPct = input.bool(true, "Show % away on AVWAPs", group=grpPct)
showGpPct   = input.bool(true, "Show % away on GPS zones", group=grpPct)
pctSizeOpt  = input.string("Small", "Label size", options=["Tiny", "Small", "Normal"], group=grpPct)

f_ts(_y, _m, _d, _h, _min) =>
    timestamp("UTC", _y, _m, _d, _h, _min)

barDurMs() =>
    timeframe.in_seconds(timeframe.period) * 1000

f_lblSz() =>
    pctSizeOpt == "Tiny" ? size.tiny : pctSizeOpt == "Normal" ? size.normal : size.small

var allNewMs = array.from(
     f_ts(2022, 1, 2, 18, 33), f_ts(2022, 2, 1, 5, 46), f_ts(2022, 3, 2, 17, 34),
     f_ts(2022, 4, 1, 6, 24), f_ts(2022, 4, 30, 20, 28), f_ts(2022, 5, 30, 11, 30),
     f_ts(2022, 6, 28, 2, 52), f_ts(2022, 7, 28, 17, 55), f_ts(2022, 8, 27, 8, 17),
     f_ts(2022, 9, 25, 19, 54), f_ts(2022, 10, 25, 10, 49), f_ts(2022, 11, 23, 22, 57),
     f_ts(2022, 12, 23, 10, 17),
     f_ts(2023, 1, 21, 20, 53), f_ts(2023, 2, 20, 7, 6), f_ts(2023, 3, 21, 17, 23),
     f_ts(2023, 4, 20, 4, 12), f_ts(2023, 5, 19, 15, 53), f_ts(2023, 6, 18, 4, 37),
     f_ts(2023, 7, 17, 18, 32), f_ts(2023, 8, 16, 9, 38), f_ts(2023, 9, 15, 1, 40),
     f_ts(2023, 10, 14, 17, 55), f_ts(2023, 11, 13, 9, 27), f_ts(2023, 12, 12, 23, 32),
     f_ts(2024, 1, 11, 11, 57), f_ts(2024, 2, 9, 22, 59), f_ts(2024, 3, 10, 9, 0),
     f_ts(2024, 4, 8, 18, 21), f_ts(2024, 5, 8, 3, 22), f_ts(2024, 6, 6, 12, 38),
     f_ts(2024, 7, 5, 22, 59), f_ts(2024, 8, 4, 11, 13), f_ts(2024, 9, 3, 1, 56),
     f_ts(2024, 10, 2, 18, 49), f_ts(2024, 11, 1, 12, 47), f_ts(2024, 12, 1, 6, 21),
     f_ts(2024, 12, 30, 22, 27),
     f_ts(2025, 1, 29, 12, 36), f_ts(2025, 2, 28, 0, 45), f_ts(2025, 3, 29, 10, 58),
     f_ts(2025, 4, 27, 19, 32), f_ts(2025, 5, 27, 3, 3), f_ts(2025, 6, 25, 10, 33),
     f_ts(2025, 7, 24, 18, 12), f_ts(2025, 8, 23, 6, 6), f_ts(2025, 9, 21, 19, 54),
     f_ts(2025, 10, 21, 12, 39), f_ts(2025, 11, 20, 6, 47), f_ts(2025, 12, 20, 1, 43),
     f_ts(2026, 1, 18, 19, 52), f_ts(2026, 2, 17, 12, 1), f_ts(2026, 3, 19, 1, 23),
     f_ts(2026, 4, 17, 11, 52), f_ts(2026, 5, 16, 20, 1), f_ts(2026, 6, 15, 2, 54),
     f_ts(2026, 7, 14, 9, 43), f_ts(2026, 8, 12, 2, 37), f_ts(2026, 9, 10, 9, 26),
     f_ts(2026, 10, 9, 15, 47), f_ts(2026, 11, 8, 0, 2), f_ts(2026, 12, 7, 16, 8),
     f_ts(2027, 1, 6, 10, 23), f_ts(2027, 2, 5, 4, 55), f_ts(2027, 3, 6, 23, 29),
     f_ts(2027, 4, 5, 16, 51), f_ts(2027, 5, 5, 8, 58), f_ts(2027, 6, 4, 0, 39),
     f_ts(2027, 7, 3, 16, 2), f_ts(2027, 8, 2, 6, 5), f_ts(2027, 8, 31, 17, 40),
     f_ts(2027, 9, 30, 2, 36), f_ts(2027, 10, 29, 9, 36), f_ts(2027, 11, 27, 16, 23),
     f_ts(2027, 12, 27, 1, 12),
     f_ts(2028, 1, 26, 15, 12), f_ts(2028, 2, 25, 10, 37), f_ts(2028, 3, 26, 4, 31),
     f_ts(2028, 4, 24, 19, 46), f_ts(2028, 5, 24, 8, 16), f_ts(2028, 6, 22, 18, 27),
     f_ts(2028, 7, 22, 3, 2), f_ts(2028, 8, 20, 10, 43), f_ts(2028, 9, 18, 18, 23),
     f_ts(2028, 10, 18, 2, 56), f_ts(2028, 11, 16, 13, 17), f_ts(2028, 12, 16, 2, 6)
 )

var allFullMs = array.from(
     f_ts(2022, 1, 17, 23, 48), f_ts(2022, 2, 16, 16, 56), f_ts(2022, 3, 18, 7, 17),
     f_ts(2022, 4, 16, 18, 55), f_ts(2022, 5, 16, 4, 14), f_ts(2022, 6, 14, 11, 52),
     f_ts(2022, 7, 13, 18, 38), f_ts(2022, 8, 12, 1, 36), f_ts(2022, 9, 10, 9, 59),
     f_ts(2022, 10, 9, 20, 55), f_ts(2022, 11, 8, 11, 2), f_ts(2022, 12, 8, 4, 8),
     f_ts(2023, 1, 6, 23, 8), f_ts(2023, 2, 5, 18, 29), f_ts(2023, 3, 7, 12, 40),
     f_ts(2023, 4, 6, 4, 35), f_ts(2023, 5, 5, 17, 34), f_ts(2023, 6, 4, 3, 42),
     f_ts(2023, 7, 3, 11, 39), f_ts(2023, 8, 1, 18, 32), f_ts(2023, 8, 31, 1, 36),
     f_ts(2023, 9, 29, 9, 58), f_ts(2023, 10, 28, 20, 24), f_ts(2023, 11, 27, 9, 16),
     f_ts(2023, 12, 27, 0, 33),
     f_ts(2024, 1, 25, 17, 54), f_ts(2024, 2, 24, 12, 30), f_ts(2024, 3, 25, 7, 0),
     f_ts(2024, 4, 23, 23, 49), f_ts(2024, 5, 23, 13, 53), f_ts(2024, 6, 22, 1, 8),
     f_ts(2024, 7, 21, 10, 17), f_ts(2024, 8, 19, 18, 26), f_ts(2024, 9, 18, 2, 34),
     f_ts(2024, 10, 17, 11, 26), f_ts(2024, 11, 15, 21, 28), f_ts(2024, 12, 15, 9, 1),
     f_ts(2025, 1, 13, 22, 27), f_ts(2025, 2, 12, 13, 53), f_ts(2025, 3, 14, 6, 55),
     f_ts(2025, 4, 13, 0, 22), f_ts(2025, 5, 12, 16, 56), f_ts(2025, 6, 11, 7, 44),
     f_ts(2025, 7, 10, 20, 37), f_ts(2025, 8, 9, 7, 55), f_ts(2025, 9, 7, 18, 9),
     f_ts(2025, 10, 7, 3, 48), f_ts(2025, 11, 5, 13, 19), f_ts(2025, 12, 5, 0, 14),
     f_ts(2026, 1, 3, 10, 16), f_ts(2026, 2, 1, 22, 9), f_ts(2026, 3, 3, 11, 38),
     f_ts(2026, 4, 2, 2, 12), f_ts(2026, 5, 1, 17, 23), f_ts(2026, 5, 31, 8, 45),
     f_ts(2026, 6, 29, 23, 57), f_ts(2026, 7, 29, 14, 36), f_ts(2026, 8, 28, 4, 18),
     f_ts(2026, 9, 26, 16, 49), f_ts(2026, 10, 26, 4, 12), f_ts(2026, 11, 24, 14, 53),
     f_ts(2026, 12, 24, 1, 28),
     f_ts(2027, 1, 22, 12, 17), f_ts(2027, 2, 20, 23, 23), f_ts(2027, 3, 22, 10, 43),
     f_ts(2027, 4, 20, 22, 26), f_ts(2027, 5, 20, 10, 59), f_ts(2027, 6, 19, 0, 43),
     f_ts(2027, 7, 18, 15, 44), f_ts(2027, 8, 17, 7, 28), f_ts(2027, 9, 15, 23, 3),
     f_ts(2027, 10, 15, 13, 47), f_ts(2027, 11, 14, 3, 25), f_ts(2027, 12, 13, 16, 8),
     f_ts(2028, 1, 12, 4, 3), f_ts(2028, 2, 10, 15, 3), f_ts(2028, 3, 11, 1, 6),
     f_ts(2028, 4, 9, 10, 26), f_ts(2028, 5, 8, 19, 49), f_ts(2028, 6, 7, 6, 8),
     f_ts(2028, 7, 6, 18, 11), f_ts(2028, 8, 5, 8, 9), f_ts(2028, 9, 3, 23, 47),
     f_ts(2028, 10, 3, 16, 25), f_ts(2028, 11, 2, 9, 17), f_ts(2028, 12, 2, 1, 41),
     f_ts(2028, 12, 31, 16, 49)
 )

var tleMs = array.from(
     f_ts(2022, 11,  8, 10, 59),
     f_ts(2025,  3, 14,  6, 59),
     f_ts(2025,  9,  7, 18, 11),
     f_ts(2026,  3,  3, 11, 33),
     f_ts(2028, 12, 31, 16, 52),
     f_ts(2029,  6, 26,  3, 22),
     f_ts(2029, 12, 20, 22, 13)
 )

var tseMs = array.from(
     f_ts(2020, 12, 14, 16, 13),
     f_ts(2021, 12,  4,  7, 33),
     f_ts(2023,  4, 20,  4, 17),
     f_ts(2024,  4,  8, 18, 17),
     f_ts(2026,  8, 12, 17, 47),
     f_ts(2027,  8,  2, 10, 4)
 )

var pleMs = array.from(
     f_ts(2021, 11, 19,  9,  3),
     f_ts(2023, 10, 28, 20, 14),
     f_ts(2024,  9, 18,  2, 44),
     f_ts(2026,  8, 28,  4, 13),
     f_ts(2028,  1, 12,  4,  3),
     f_ts(2028,  7,  6, 18, 20)
 )

var pseMs = array.from(
     f_ts(2022,  4, 30, 20, 41),
     f_ts(2022, 10, 25, 11,  0),
     f_ts(2025,  3, 29, 10, 47),
     f_ts(2025,  9, 21, 19, 41),
     f_ts(2026,  2, 17, 12, 12),
     f_ts(2027,  2,  6, 16,  0),
     f_ts(2029,  1, 14, 17, 13),
     f_ts(2029,  6, 12,  3, 53),
     f_ts(2029,  7, 11, 15, 37),
     f_ts(2029, 12,  5, 15, 3)
 )

var array<int> fqMs = array.new_int(0)
var array<int> lqMs = array.new_int(0)
if barstate.isfirst
    array.clear(fqMs)
    array.clear(lqMs)
    if array.size(allNewMs) > 0 and array.size(allFullMs) > 0
        for qi = 0 to array.size(allNewMs) - 1
            int qn = array.get(allNewMs, qi)
            int nxtF = na
            for qj = 0 to array.size(allFullMs) - 1
                int qf = array.get(allFullMs, qj)
                if qf > qn
                    nxtF := qf
                    break
            if not na(nxtF)
                array.push(fqMs, qn + int((nxtF - qn) / 2))
        for qi = 0 to array.size(allFullMs) - 1
            int qf = array.get(allFullMs, qi)
            int nxtN = na
            for qj = 0 to array.size(allNewMs) - 1
                int qn = array.get(allNewMs, qj)
                if qn > qf
                    nxtN := qn
                    break
            if not na(nxtN)
                array.push(lqMs, qf + int((nxtN - qf) / 2))

f_latest(array<int> src) =>
    int best = na
    if array.size(src) > 0
        for u = 0 to array.size(src) - 1
            c = array.get(src, u)
            if c <= time
                best := c
    best

f_next(array<int> src) =>
    // First event AFTER now — the lock time for a forming GPS pocket.
    int best = na
    if array.size(src) > 0
        for u = 0 to array.size(src) - 1
            c = array.get(src, u)
            if c > time
                best := c
                break
    best

int axNew  = f_latest(allNewMs)
int axFull = f_latest(allFullMs)
int axTle  = f_latest(tleMs)
int axTse  = f_latest(tseMs)
int axPle  = f_latest(pleMs)
int axPse  = f_latest(pseMs)
int axFq   = f_latest(fqMs)
int axLq   = f_latest(lqMs)
int nxNew  = f_next(allNewMs)
int nxFull = f_next(allFullMs)
int nxFq   = f_next(fqMs)
int nxLq   = f_next(lqMs)

tp  = hlc3 * nz(volume, 0)
vp  = nz(volume, 0)
cPV = ta.cum(tp)
cV  = ta.cum(vp)
max_bars_back(cPV, 5000)
max_bars_back(cV, 5000)

f_segVwap(bool on, int anchor, int ssIn) =>
    int pineMaxBk = 5000
    int ss = ssIn
    float out = na
    if on and not na(anchor)
        if na(anchor[1]) or anchor != anchor[1]
            ss := bar_index
        float prePV = 0.0
        float preV = 0.0
        bool segTooLong = false
        if not na(ss) and ss > 0
            bk = bar_index - ss + 1
            if bk > pineMaxBk
                segTooLong := true
            else if bk >= 0 and bk <= bar_index
                prePV := nz(cPV[bk], 0)
                preV := nz(cV[bk], 0)
        dv = cV - preV
        out := segTooLong ? na : (dv > 0 ? (cPV - prePV) / dv : na)
    [ss, out]

var int ssNew = na
var int ssFull = na
var int ssTle = na
var int ssTse = na
[ssNewN, avNew]   = f_segVwap(showVwNew,  axNew,  ssNew[1])
[ssFullN, avFull] = f_segVwap(showVwFull, axFull, ssFull[1])
[ssTleN, avTle]   = f_segVwap(showVwTLE,  axTle,  ssTle[1])
[ssTseN, avTse]   = f_segVwap(showVwTSE,  axTse,  ssTse[1])
ssNew  := ssNewN
ssFull := ssFullN
ssTle  := ssTleN
ssTse  := ssTseN

plot(showVwNew  ? avNew  : na, "AVWAP New Moon",          color=vwNewColor,  linewidth=1, style=plot.style_cross)
plot(showVwFull ? avFull : na, "AVWAP Full Moon",         color=vwFullColor, linewidth=1, style=plot.style_cross)
plot(showVwTLE  ? avTle  : na, "AVWAP Total Lunar (TLE)", color=vwTleColor,  linewidth=1, style=plot.style_cross)
plot(showVwTSE  ? avTse  : na, "AVWAP Total Solar (TSE)", color=vwTseColor,  linewidth=1, style=plot.style_cross)

f_gpBand(float h, float l) =>
    float span = h - l
    float gph = na
    float gpl = na
    if not na(h) and not na(l) and span > 0.0
        gph := h - span * gpHiFib
        gpl := h - span * gpLoFib
    [gph, gpl]

f_legStep(bool on, int startAx, int endAx, float runHIn, float runLIn, float prevHIn, float prevLIn) =>
    float runH = runHIn
    float runL = runLIn
    float prevH = prevHIn
    float prevL = prevLIn
    bool startFlip = on and not na(startAx) and (na(startAx[1]) or startAx != startAx[1])
    bool endFlip = on and not na(endAx) and (na(endAx[1]) or endAx != endAx[1])
    if on
        if endFlip and not na(runH)
            prevH := runH
            prevL := runL
            runH := na
            runL := na
        if startFlip
            runH := high
            runL := low
        else if not na(runH)
            runH := math.max(runH, high)
            runL := math.min(runL, low)
    [runH, runL, prevH, prevL, endFlip]

f_cycleStep(bool on, int anchor, float runHIn, float runLIn, float prevHIn, float prevLIn) =>
    float runH = runHIn
    float runL = runLIn
    float prevH = prevHIn
    float prevL = prevLIn
    bool flip = on and not na(anchor) and (na(anchor[1]) or anchor != anchor[1])
    if on
        if flip
            prevH := runH
            prevL := runL
            runH := high
            runL := low
        else if not na(runH)
            runH := math.max(runH, high)
            runL := math.min(runL, low)
    [runH, runL, prevH, prevL, flip]

f_gpBox(box bx, bool on, bool flip, float prevH, float prevL, color fillC, color borderC, string tag) =>
    box out = bx
    if not on
        if not na(out)
            box.delete(out)
            out := na
    else
        if flip and not na(prevH) and not na(prevL) and prevH > prevL
            if not na(out)
                box.set_right(out, time)
            [gph, gpl] = f_gpBand(prevH, prevL)
            out := box.new(time, gph, time + barDurMs(), gpl, xloc=xloc.bar_time, border_color=borderC, border_width=1, bgcolor=fillC, text=tag, text_size=size.tiny, text_color=borderC)
        else if not na(out)
            box.set_right(out, time + barDurMs())
    out

// Forming pocket: GPS of the LIVE cycle high/low, projected to the next
// known astro lock. Moves only if price extends the range before lockMs.
f_formingGrade(float progress) =>
    progress >= 0.90 ? "firm" : progress >= 0.75 ? "likely" : progress >= 0.50 ? "rough" : "sketch"

f_formingBox(box bx, bool on, float runH, float runL, int startMs, int lockMs, color fillC, color borderC, string tag) =>
    box out = bx
    float prog = na(startMs) or na(lockMs) or lockMs <= startMs ? 0.0 : math.max(0.0, math.min(1.0, (time - startMs) / (lockMs - startMs)))
    bool show = on and not na(runH) and not na(runL) and runH > runL and not na(lockMs) and lockMs > time and prog >= formMinProg
    if not show
        if not na(out)
            box.delete(out)
            out := na
    else
        [gph, gpl] = f_gpBand(runH, runL)
        string txt = tag + " · " + f_formingGrade(prog)
        if na(out)
            out := box.new(time, gph, lockMs, gpl, xloc=xloc.bar_time, border_color=borderC, border_width=1, border_style=line.style_dashed, bgcolor=fillC, text=txt, text_size=size.tiny, text_color=borderC)
        else
            box.set_lefttop(out, time, gph)
            box.set_rightbottom(out, lockMs, gpl)
            box.set_bgcolor(out, fillC)
            box.set_text(out, txt)
    out

var float nH = na
var float nL = na
var float nPH = na
var float nPL = na
var float fH = na
var float fL = na
var float fPH = na
var float fPL = na
var float tlH = na
var float tlL = na
var float tlPH = na
var float tlPL = na
var float tsH = na
var float tsL = na
var float tsPH = na
var float tsPL = na
var float plH = na
var float plL = na
var float plPH = na
var float plPL = na
var float psH = na
var float psL = na
var float psPH = na
var float psPL = na

[nH1, nL1, nPH1, nPL1, nFlip]     = f_cycleStep(showGpNew,  axNew,  nH[1],  nL[1],  nPH[1],  nPL[1])
[fH1, fL1, fPH1, fPL1, fFlip]     = f_cycleStep(showGpFull, axFull, fH[1],  fL[1],  fPH[1],  fPL[1])
[tlH1, tlL1, tlPH1, tlPL1, tlFlip] = f_cycleStep(showGpTLE,  axTle,  tlH[1], tlL[1], tlPH[1], tlPL[1])
[tsH1, tsL1, tsPH1, tsPL1, tsFlip] = f_cycleStep(showGpTSE,  axTse,  tsH[1], tsL[1], tsPH[1], tsPL[1])
[plH1, plL1, plPH1, plPL1, plFlip] = f_cycleStep(showGpPLE,  axPle,  plH[1], plL[1], plPH[1], plPL[1])
[psH1, psL1, psPH1, psPL1, psFlip] = f_cycleStep(showGpPSE,  axPse,  psH[1], psL[1], psPH[1], psPL[1])
nH := nH1
nL := nL1
nPH := nPH1
nPL := nPL1
fH := fH1
fL := fL1
fPH := fPH1
fPL := fPL1
tlH := tlH1
tlL := tlL1
tlPH := tlPH1
tlPL := tlPL1
tsH := tsH1
tsL := tsL1
tsPH := tsPH1
tsPL := tsPL1
plH := plH1
plL := plL1
plPH := plPH1
plPL := plPL1
psH := psH1
psL := psL1
psPH := psPH1
psPL := psPL1

[nmHi, nmLo]   = f_gpBand(nPH, nPL)
[fmHi, fmLo]   = f_gpBand(fPH, fPL)
[tleHi, tleLo] = f_gpBand(tlPH, tlPL)
[tseHi, tseLo] = f_gpBand(tsPH, tsPL)
[pleHi, pleLo] = f_gpBand(plPH, plPL)
[pseHi, pseLo] = f_gpBand(psPH, psPL)
nmMid  = showGpNew  and not na(nmHi)  ? (nmHi + nmLo) / 2.0 : na
fmMid  = showGpFull and not na(fmHi)  ? (fmHi + fmLo) / 2.0 : na
tleMid = showGpTLE  and not na(tleHi) ? (tleHi + tleLo) / 2.0 : na
tseMid = showGpTSE  and not na(tseHi) ? (tseHi + tseLo) / 2.0 : na
pleMid = showGpPLE  and not na(pleHi) ? (pleHi + pleLo) / 2.0 : na
pseMid = showGpPSE  and not na(pseHi) ? (pseHi + pseLo) / 2.0 : na

var box bxNm = na
var box bxFm = na
var box bxTl = na
var box bxTs = na
var box bxPl = na
var box bxPs = na
bxNm := f_gpBox(bxNm, showGpNew,  nFlip,  nPH,  nPL,  gpNewFill,  color.new(color.teal, 25), "NM")
bxFm := f_gpBox(bxFm, showGpFull, fFlip,  fPH,  fPL,  gpFullFill, color.new(color.blue, 25), "FM")
bxTl := f_gpBox(bxTl, showGpTLE,  tlFlip, tlPH, tlPL, gpTleFill,  color.new(#64B5F6, 25), "TLE")
bxTs := f_gpBox(bxTs, showGpTSE,  tsFlip, tsPH, tsPL, gpTseFill,  color.new(#E57373, 25), "TSE")
bxPl := f_gpBox(bxPl, showGpPLE,  plFlip, plPH, plPL, gpPleFill,  color.new(#90CAF9, 30), "PLE")
bxPs := f_gpBox(bxPs, showGpPSE,  psFlip, psPH, psPL, gpPseFill,  color.new(#EF9A9A, 30), "PSE")

// Forming (future) GPS — live New/Full cycle range → pocket locks at next event.
var box bxFormNm = na
var box bxFormFm = na
bxFormNm := f_formingBox(bxFormNm, showForming, nH, nL, axNew, nxNew, formFillNew, color.new(color.teal, 40), "NM forming")
bxFormFm := f_formingBox(bxFormFm, showForming, fH, fL, axFull, nxFull, formFillFull, color.new(color.blue, 40), "FM forming")

pNmHi  = plot(showGpNew  ? nmHi  : na, "GPS New Moon 61.8",  color=color.new(color.teal, 15), linewidth=1, style=plot.style_cross)
pNmLo  = plot(showGpNew  ? nmLo  : na, "GPS New Moon 65",    color=color.new(color.teal, 40), linewidth=1, style=plot.style_cross)
pFmHi  = plot(showGpFull ? fmHi  : na, "GPS Full Moon 61.8", color=color.new(color.blue, 15), linewidth=1, style=plot.style_cross)
pFmLo  = plot(showGpFull ? fmLo  : na, "GPS Full Moon 65",   color=color.new(color.blue, 40), linewidth=1, style=plot.style_cross)
pTlHi  = plot(showGpTLE  ? tleHi : na, "GPS TLE 61.8",       color=color.new(#64B5F6, 15), linewidth=1, style=plot.style_cross)
pTlLo  = plot(showGpTLE  ? tleLo : na, "GPS TLE 65",         color=color.new(#64B5F6, 40), linewidth=1, style=plot.style_cross)
pTsHi  = plot(showGpTSE  ? tseHi : na, "GPS TSE 61.8",       color=color.new(#E57373, 15), linewidth=1, style=plot.style_cross)
pTsLo  = plot(showGpTSE  ? tseLo : na, "GPS TSE 65",         color=color.new(#E57373, 40), linewidth=1, style=plot.style_cross)
pPlHi  = plot(showGpPLE  ? pleHi : na, "GPS PLE 61.8",       color=color.new(#90CAF9, 20), linewidth=1, style=plot.style_cross)
pPlLo  = plot(showGpPLE  ? pleLo : na, "GPS PLE 65",         color=color.new(#90CAF9, 45), linewidth=1, style=plot.style_cross)
pPsHi  = plot(showGpPSE  ? pseHi : na, "GPS PSE 61.8",       color=color.new(#EF9A9A, 20), linewidth=1, style=plot.style_cross)
pPsLo  = plot(showGpPSE  ? pseLo : na, "GPS PSE 65",         color=color.new(#EF9A9A, 45), linewidth=1, style=plot.style_cross)
fill(pNmHi, pNmLo, color=showGpNew  ? gpNewFill  : na, title="GPS New Moon fill")
fill(pFmHi, pFmLo, color=showGpFull ? gpFullFill : na, title="GPS Full Moon fill")
fill(pTlHi, pTlLo, color=showGpTLE  ? gpTleFill  : na, title="GPS TLE fill")
fill(pTsHi, pTsLo, color=showGpTSE  ? gpTseFill  : na, title="GPS TSE fill")
fill(pPlHi, pPlLo, color=showGpPLE  ? gpPleFill  : na, title="GPS PLE fill")
fill(pPsHi, pPsLo, color=showGpPSE  ? gpPseFill  : na, title="GPS PSE fill")

var float nqH = na
var float nqL = na
var float nqPH = na
var float nqPL = na
var float qfH = na
var float qfL = na
var float qfPH = na
var float qfPL = na
var float flH = na
var float flL = na
var float flPH = na
var float flPL = na
var float lnH = na
var float lnL = na
var float lnPH = na
var float lnPL = na
[nqH1, nqL1, nqPH1, nqPL1, nqFlip] = f_legStep(showGpN2Q, axNew, axFq,   nqH[1], nqL[1], nqPH[1], nqPL[1])
[qfH1, qfL1, qfPH1, qfPL1, qfFlip] = f_legStep(showGpQ2F, axFq,  axFull, qfH[1], qfL[1], qfPH[1], qfPL[1])
[flH1, flL1, flPH1, flPL1, flFlip] = f_legStep(showGpF2L, axFull, axLq,  flH[1], flL[1], flPH[1], flPL[1])
[lnH1, lnL1, lnPH1, lnPL1, lnFlip] = f_legStep(showGpL2N, axLq,  axNew,  lnH[1], lnL[1], lnPH[1], lnPL[1])
nqH := nqH1
nqL := nqL1
nqPH := nqPH1
nqPL := nqPL1
qfH := qfH1
qfL := qfL1
qfPH := qfPH1
qfPL := qfPL1
flH := flH1
flL := flL1
flPH := flPH1
flPL := flPL1
lnH := lnH1
lnL := lnL1
lnPH := lnPH1
lnPL := lnPL1

[n2qHi, n2qLo] = f_gpBand(nqPH, nqPL)
[q2fHi, q2fLo] = f_gpBand(qfPH, qfPL)
[f2lHi, f2lLo] = f_gpBand(flPH, flPL)
[l2nHi, l2nLo] = f_gpBand(lnPH, lnPL)
n2qMid = showGpN2Q and not na(n2qHi) ? (n2qHi + n2qLo) / 2.0 : na
q2fMid = showGpQ2F and not na(q2fHi) ? (q2fHi + q2fLo) / 2.0 : na
f2lMid = showGpF2L and not na(f2lHi) ? (f2lHi + f2lLo) / 2.0 : na
l2nMid = showGpL2N and not na(l2nHi) ? (l2nHi + l2nLo) / 2.0 : na

var box bxN2Q = na
var box bxQ2F = na
var box bxF2L = na
var box bxL2N = na
bxN2Q := f_gpBox(bxN2Q, showGpN2Q, nqFlip, nqPH, nqPL, gpN2QFill, color.new(#FFD54F, 20), "N→Q")
bxQ2F := f_gpBox(bxQ2F, showGpQ2F, qfFlip, qfPH, qfPL, gpQ2FFill, color.new(#FFB74D, 20), "Q→F")
bxF2L := f_gpBox(bxF2L, showGpF2L, flFlip, flPH, flPL, gpF2LFill, color.new(#CE93D8, 20), "F→L")
bxL2N := f_gpBox(bxL2N, showGpL2N, lnFlip, lnPH, lnPL, gpL2NFill, color.new(#80CBC4, 20), "L→N")

// Forming phase-leg pockets (optional) — live leg range locks at the next quarter/syzygy.
var box bxFormN2Q = na
var box bxFormQ2F = na
var box bxFormF2L = na
var box bxFormL2N = na
bool formLegs = showForming and showFormingLegs
bxFormN2Q := f_formingBox(bxFormN2Q, formLegs, nqH, nqL, axNew,  nxFq,   formFillLeg, color.new(#FFD54F, 35), "N→Q forming")
bxFormQ2F := f_formingBox(bxFormQ2F, formLegs, qfH, qfL, axFq,   nxFull, formFillLeg, color.new(#FFB74D, 35), "Q→F forming")
bxFormF2L := f_formingBox(bxFormF2L, formLegs, flH, flL, axFull, nxLq,   formFillLeg, color.new(#CE93D8, 35), "F→L forming")
bxFormL2N := f_formingBox(bxFormL2N, formLegs, lnH, lnL, axLq,   nxNew,  formFillLeg, color.new(#80CBC4, 35), "L→N forming")

pN2QHi = plot(showGpN2Q ? n2qHi : na, "GPS New→FQ 61.8",  color=color.new(#FFD54F, 10), linewidth=1, style=plot.style_cross)
pN2QLo = plot(showGpN2Q ? n2qLo : na, "GPS New→FQ 65",    color=color.new(#FFD54F, 40), linewidth=1, style=plot.style_cross)
pQ2FHi = plot(showGpQ2F ? q2fHi : na, "GPS FQ→Full 61.8", color=color.new(#FFB74D, 10), linewidth=1, style=plot.style_cross)
pQ2FLo = plot(showGpQ2F ? q2fLo : na, "GPS FQ→Full 65",   color=color.new(#FFB74D, 40), linewidth=1, style=plot.style_cross)
pF2LHi = plot(showGpF2L ? f2lHi : na, "GPS Full→LQ 61.8", color=color.new(#CE93D8, 10), linewidth=1, style=plot.style_cross)
pF2LLo = plot(showGpF2L ? f2lLo : na, "GPS Full→LQ 65",   color=color.new(#CE93D8, 40), linewidth=1, style=plot.style_cross)
pL2NHi = plot(showGpL2N ? l2nHi : na, "GPS LQ→New 61.8",  color=color.new(#80CBC4, 10), linewidth=1, style=plot.style_cross)
pL2NLo = plot(showGpL2N ? l2nLo : na, "GPS LQ→New 65",    color=color.new(#80CBC4, 40), linewidth=1, style=plot.style_cross)
fill(pN2QHi, pN2QLo, color=showGpN2Q ? gpN2QFill : na, title="GPS New→FQ fill")
fill(pQ2FHi, pQ2FLo, color=showGpQ2F ? gpQ2FFill : na, title="GPS FQ→Full fill")
fill(pF2LHi, pF2LLo, color=showGpF2L ? gpF2LFill : na, title="GPS Full→LQ fill")
fill(pL2NHi, pL2NLo, color=showGpL2N ? gpL2NFill : na, title="GPS LQ→New fill")

f_pctFrom(float lvl) =>
    na(lvl) or lvl == 0.0 ? na : (close - lvl) / lvl * 100.0

f_gpAway(float gph, float gpl) =>
    string s = "—"
    if not na(gph) and not na(gpl)
        float lo = math.min(gph, gpl)
        float hi = math.max(gph, gpl)
        if close >= lo and close <= hi
            s := "IN"
        else if close > hi
            s := "+" + str.tostring((close - hi) / hi * 100.0, "#.##") + "%"
        else
            s := str.tostring((close - lo) / lo * 100.0, "#.##") + "%"
    s

f_fmtVwap(float av) =>
    float p = f_pctFrom(av)
    na(p) ? "—" : (p >= 0 ? "+" : "") + str.tostring(p, "#.##") + "%"

f_updLbl(label lb, bool on, float y, string txt, color tc) =>
    label out = lb
    if not na(out)
        label.delete(out)
        out := na
    if on and not na(y) and barstate.islast
        out := label.new(bar_index, y, txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=#1A1A1A, textcolor=tc, size=f_lblSz())
    out

var label lbVn = na
var label lbVf = na
var label lbVl = na
var label lbVs = na
var label lbGn = na
var label lbGf = na
var label lbGl = na
var label lbGs = na
var label lbGp = na
var label lbGq = na
lbVn := f_updLbl(lbVn, showVwapPct and showVwNew,  avNew,  f_fmtVwap(avNew), vwNewColor)
lbVf := f_updLbl(lbVf, showVwapPct and showVwFull, avFull, f_fmtVwap(avFull), vwFullColor)
lbVl := f_updLbl(lbVl, showVwapPct and showVwTLE,  avTle,  f_fmtVwap(avTle), vwTleColor)
lbVs := f_updLbl(lbVs, showVwapPct and showVwTSE,  avTse,  f_fmtVwap(avTse), vwTseColor)
lbGn := f_updLbl(lbGn, showGpPct and showGpNew,  nmMid,  f_gpAway(nmHi, nmLo), color.teal)
lbGf := f_updLbl(lbGf, showGpPct and showGpFull, fmMid,  f_gpAway(fmHi, fmLo), color.blue)
lbGl := f_updLbl(lbGl, showGpPct and showGpTLE,  tleMid, f_gpAway(tleHi, tleLo), #64B5F6)
lbGs := f_updLbl(lbGs, showGpPct and showGpTSE,  tseMid, f_gpAway(tseHi, tseLo), #E57373)
lbGp := f_updLbl(lbGp, showGpPct and showGpPLE,  pleMid, f_gpAway(pleHi, pleLo), #90CAF9)
lbGq := f_updLbl(lbGq, showGpPct and showGpPSE,  pseMid, f_gpAway(pseHi, pseLo), #EF9A9A)
var label lbN2Q = na
var label lbQ2F = na
var label lbF2L = na
var label lbL2N = na
lbN2Q := f_updLbl(lbN2Q, showGpPct and showGpN2Q, n2qMid, f_gpAway(n2qHi, n2qLo), #FFD54F)
lbQ2F := f_updLbl(lbQ2F, showGpPct and showGpQ2F, q2fMid, f_gpAway(q2fHi, q2fLo), #FFB74D)
lbF2L := f_updLbl(lbF2L, showGpPct and showGpF2L, f2lMid, f_gpAway(f2lHi, f2lLo), #CE93D8)
lbL2N := f_updLbl(lbL2N, showGpPct and showGpL2N, l2nMid, f_gpAway(l2nHi, l2nLo), #80CBC4)

// — Numerology: calendar is a WINDOW. Side comes from tape vs AVWAP/GPS + candle digits. —
f_digitRoot(int raw) =>
    int x = math.abs(raw)
    int guard = 0
    if x == 0
        x := 0
    else
        while x > 9 and guard < 16
            if x == 11 or x == 22 or x == 33
                break
            int s = 0
            int t = x
            int g2 = 0
            while t > 0 and g2 < 16
                s += t % 10
                t := int(t / 10)
                g2 += 1
            x := s
            guard += 1
    x

f_sumYmd(int y, int m, int d) =>
    int(m / 10) + (m % 10) + int(d / 10) + (d % 10) + (y % 10) + (int(y / 10) % 10) + (int(y / 100) % 10) + int(y / 1000)

f_dateRoot(int ms) =>
    na(ms) ? 0 : f_digitRoot(f_sumYmd(year(ms), month(ms), dayofmonth(ms)))

f_rootMeaning(int r) =>
    switch r
        1 => "begin"
        2 => "pair"
        3 => "voice"
        4 => "build"
        5 => "change"
        6 => "heal"
        7 => "study"
        8 => "cycle"
        9 => "close"
        11 => "master-11"
        22 => "master-22"
        33 => "master-33"
        => "—"

f_reduce9(int r) =>
    r == 11 ? 2 : r == 22 ? 4 : r == 33 ? 6 : r

f_priceInt(float p) =>
    float a = math.abs(p)
    float x = a
    int e = 0
    while x < 1000.0 and e < 6
        x *= 10.0
        e += 1
    int(math.round(x))

f_isRepeating(int n) =>
    int last = n % 10
    int c = 0
    int t = math.abs(n)
    int g = 0
    while t > 0 and g < 12
        if t % 10 != last
            break
        c += 1
        t := int(t / 10)
        g += 1
    c >= 3 and last != 0

f_inBand(float hi, float lo) =>
    not na(hi) and not na(lo) and close >= math.min(hi, lo) and close <= math.max(hi, lo)

f_kissLvl(float lvl) =>
    not na(lvl) and lvl != 0.0 and math.abs(close - lvl) / lvl * 100.0 <= kissPct

float synodic = 29.5305882
int refFullMs = f_ts(2000, 1, 21, 4, 40)
int lunationN = int(math.floor((time - refFullMs) / (synodic * 86400000.0))) + 1
int lunaRoot = f_digitRoot(lunationN)
float ageDays = na(axNew) ? na : (time - axNew) / 86400000.0
int lunaDay = na(ageDays) ? na : int(math.floor(ageDays)) + 1
int dateRootNow = f_dateRoot(time)
int lunaDay1 = lunaDay[1]
int pxInt = f_priceInt(close)
int pxRoot = f_digitRoot(pxInt)
bool pxRep = f_isRepeating(pxInt)
bool pxMaster = pxRoot == 11 or pxRoot == 22 or pxRoot == 33
bool numMatch = pxRoot == dateRootNow or pxRoot == lunaRoot or pxMaster or pxRep
bool numConflict = f_reduce9(pxRoot) + f_reduce9(dateRootNow) == 10 and not pxMaster and not pxRep

bool hitNewA  = not na(axNew)  and (na(axNew[1])  or axNew  != axNew[1])
bool hitFqA   = not na(axFq)   and (na(axFq[1])   or axFq   != axFq[1])
bool hitFullA = not na(axFull) and (na(axFull[1]) or axFull != axFull[1])
bool hitLqA   = not na(axLq)   and (na(axLq[1])   or axLq   != axLq[1])
bool d9First  = not na(lunaDay) and lunaDay == 9  and (na(lunaDay1) or lunaDay1 != 9)
bool d18First = not na(lunaDay) and lunaDay == 18 and (na(lunaDay1) or lunaDay1 != 18)
bool d27First = not na(lunaDay) and lunaDay == 27 and (na(lunaDay1) or lunaDay1 != 27)
bool moonEvent = hitNewA or hitFqA or hitFullA or hitLqA or d9First or d18First or d27First

var int winStart = na
var int winUntil = na
var int lastFire = na
if moonEvent
    winStart := bar_index
    winUntil := bar_index + winExtraBars
bool inWin = not na(winUntil) and bar_index >= winStart and bar_index <= winUntil
bool slotOpen = inWin and (na(lastFire) or lastFire < winStart)

bool inHtfGps = f_inBand(nmHi, nmLo) or f_inBand(fmHi, fmLo) or f_inBand(tleHi, tleLo) or f_inBand(tseHi, tseLo) or f_inBand(pleHi, pleLo) or f_inBand(pseHi, pseLo)
bool atVwap = f_kissLvl(avNew) or f_kissLvl(avFull) or f_kissLvl(avTle) or f_kissLvl(avTse)

float atrN = ta.atr(14)
bool bodyOk = not na(atrN) and math.abs(close - open) >= atrN * 0.25
bool tapeBull = bodyOk and close > open and close > close[1] and (na(avNew) or close > avNew)
bool tapeBear = bodyOk and close < open and close < close[1] and (na(avNew) or close < avNew)

bool allThree = inHtfGps and numMatch and not numConflict
bool bullConf = showNumConf and slotOpen and allThree and tapeBull
bool bearConf = showNumConf and slotOpen and allThree and tapeBear and not bullConf
if bullConf or bearConf
    lastFire := bar_index

f_angleTip(string ang, int evtMs) =>
    int dr = f_dateRoot(evtMs)
    int ld = na(axNew) ? na : int(math.floor((evtMs - axNew) / 86400000.0)) + 1
    ang + " · d" + (na(ld) ? "—" : str.tostring(ld)) + " · date R" + str.tostring(dr) + " " + f_rootMeaning(dr) + " · luna #" + str.tostring(lunationN) + " R" + str.tostring(lunaRoot)

f_confTip() =>
    (bullConf ? "BULL" : "BEAR") + " · HTF GPS · px R" + str.tostring(pxRoot) + (pxRep ? " repeat" : "") + " · date R" + str.tostring(dateRootNow) + " · luna R" + str.tostring(lunaRoot) + (atVwap ? " · AVWAP kiss" : "")

f_sideLbl(string txt, color bg, color fg, string tip, bool isBull, bool isBear) =>
    bool goBot = isBull
    label.new(bar_index, goBot ? low : high, txt, xloc=xloc.bar_index, yloc=goBot ? yloc.belowbar : yloc.abovebar, style=goBot ? label.style_label_up : label.style_label_down, color=bg, textcolor=fg, size=size.tiny, tooltip=tip)

f_dot(int evtMs, string shortTxt, color bg, color fg, string ang) =>
    label.new(bar_index, high, shortTxt, xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=bg, textcolor=fg, size=size.tiny, tooltip=f_angleTip(ang, evtMs))

if showAngleNum
    if hitNewA
        f_dot(axNew, "N", #004D40, #E0F2F1, "New 0°")
    if hitFqA
        f_dot(axFq, "Q", #F9A825, #111111, "FQ 90°")
    if hitFullA
        f_dot(axFull, "F", #0D47A1, #E3F2FD, "Full 180°")
    if hitLqA
        f_dot(axLq, "L", #6A1B9A, #F3E5F5, "LQ 270°")

bool hitD9  = showNineTicks and d9First
bool hitD18 = showNineTicks and d18First
bool hitD27 = showNineTicks and d27First
plotshape(hitD9,  title="Lunation day 9",  style=shape.circle, location=location.belowbar, color=#F9A825, size=size.tiny)
plotshape(hitD18, title="Lunation day 18", style=shape.circle, location=location.belowbar, color=#EF6C00, size=size.tiny)
plotshape(hitD27, title="Lunation day 27", style=shape.circle, location=location.belowbar, color=#8E24AA, size=size.tiny)

plotshape(bullConf, title="Numerology BULL", style=shape.triangleup, location=location.belowbar, color=#00E676, size=size.tiny)
plotshape(bearConf, title="Numerology BEAR", style=shape.triangledown, location=location.abovebar, color=#FF5252, size=size.tiny)

if bullConf
    f_sideLbl("B" + str.tostring(pxRoot), #1B5E20, #E8F5E9, f_confTip(), true, false)
if bearConf
    f_sideLbl("S" + str.tostring(pxRoot), #B71C1C, #FFEBEE, f_confTip(), false, true)
````
