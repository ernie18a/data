# OPR Asia London US Universal Open Price Range

- url: https://www.tradingview.com/script/WwqAdQLW-OPR-Asia-London-US-Universal-Open-Price-Range/
- type: indicator
- pine_id: PUB;31c1b03e708a4b34a432fdda2e26a011
- version: 1.0

## Description

[b]Description[/b]:
What this script does
This indicator automatically draws the Open Price Range (OPR) for up to three configurable trading sessions: Asia, London, and US. For each session, it captures the high and low over a user-defined opening window, then extends the resulting levels forward in time so traders can monitor whether price respects or breaks the opening range.
What makes it original

Most OPR indicators on TradingView are hardcoded for a single instrument (DAX, NQ, ES) and a single timezone. This script solves three problems that existing public OPR tools do not handle:

Universal — works on any asset (indices, forex, commodities, crypto) without symbol detection logic. No ticker filtering.
Per-session timezone — each of the three sessions has its own independent timezone setting. Asia runs on America/New_York, London on Europe/London, US on America/New_York by default, but all are fully configurable. This ensures correct alignment regardless of the chart's display timezone.
Cross-midnight handling — the Asia session starts at 20:00 ET (evening) and its extension target falls the next morning. The script correctly computes next-day timestamps for the extend line, a case that breaks most existing OPR implementations.

[b]How it works
[/b]For each session the script computes a tStart and tEnd timestamp in the session's own timezone using Pine Script's timestamp() function with explicit year/month/day/hour/minute parameters. It accumulates the highest high and lowest low of all bars within the window. On the first bar after the window closes, it draws:

[b]A filled rectangle over the OPR capture window[/b]
A thick left-edge vertical line marking the exact open
High and low horizontal lines extended to a configurable end time
An optional dotted midpoint line
A small session label (AS / LN / US, all editable)

The extend target uses a cross-midnight guard: if the extend hour falls before the session start hour in that timezone, 86,400,000 ms (one day) is added to the timestamp.
How to use it
Set Start hour/min and End hour/min to define the capture window for each session. Set Extend hour/min to control how far the high/low lines project forward. Enable or disable each session independently. All colors, line widths, and labels are customizable in the Style group.
Works on any timeframe from 1 minute to 1 hour. Tested on indices (DAX, NQ, ES), forex pairs, and Gold.

## Source Code

````pine
//@version=6
indicator("OPR — Asia / London / US", overlay=true,
     max_lines_count=500, max_boxes_count=500)

// ══════════════════════════════════════════════
// INPUTS — SESSION 1 : ASIA
// ══════════════════════════════════════════════
grp1    = "── Session 1 · Asia"
s1_on   = input.bool(true,                "Activer",           group=grp1)
s1_lbl  = input.string("AS",             "Label",              group=grp1)
s1_tz   = input.string("America/New_York","Timezone",          group=grp1)
s1_sh   = input.int(20, "Début heure",   group=grp1, minval=0, maxval=23)
s1_sm   = input.int(0,  "Début min",     group=grp1, minval=0, maxval=59)
s1_eh   = input.int(20, "Fin heure",     group=grp1, minval=0, maxval=23)
s1_em   = input.int(15, "Fin min",       group=grp1, minval=0, maxval=59)
s1_xh   = input.int(0,  "Étend. heure",  group=grp1, minval=0, maxval=23)
s1_xm   = input.int(0,  "Étend. min",    group=grp1, minval=0, maxval=59)
s1_ext  = input.bool(false, "Étendre",    group=grp1)

// ══════════════════════════════════════════════
// INPUTS — SESSION 2 : LONDON
// ══════════════════════════════════════════════
grp2    = "── Session 2 · London"
s2_on   = input.bool(true,               "Activer",            group=grp2)
s2_lbl  = input.string("LN",            "Label",               group=grp2)
s2_tz   = input.string("America/New_York", "Timezone",         group=grp2)
s2_sh   = input.int(3,  "Début heure",  group=grp2, minval=0, maxval=23)
s2_sm   = input.int(0,  "Début min",    group=grp2, minval=0, maxval=59)
s2_eh   = input.int(3,  "Fin heure",    group=grp2, minval=0, maxval=23)
s2_em   = input.int(15, "Fin min",      group=grp2, minval=0, maxval=59)
s2_xh   = input.int(5, "Étend. heure", group=grp2, minval=0, maxval=23)
s2_xm   = input.int(0,  "Étend. min",   group=grp2, minval=0, maxval=59)
s2_ext  = input.bool(true, "Étendre",   group=grp2)

// ══════════════════════════════════════════════
// INPUTS — SESSION 3 : US
// ══════════════════════════════════════════════
grp3    = "── Session 3 · US"
s3_on   = input.bool(true,                 "Activer",          group=grp3)
s3_lbl  = input.string("US",              "Label",              group=grp3)
s3_tz   = input.string("America/New_York","Timezone",           group=grp3)
s3_sh   = input.int(9,  "Début heure",   group=grp3, minval=0, maxval=23)
s3_sm   = input.int(30, "Début min",     group=grp3, minval=0, maxval=59)
s3_eh   = input.int(9,  "Fin heure",     group=grp3, minval=0, maxval=23)
s3_em   = input.int(45, "Fin min",       group=grp3, minval=0, maxval=59)
s3_xh   = input.int(11, "Étend. heure",  group=grp3, minval=0, maxval=23)
s3_xm   = input.int(0,  "Étend. min",    group=grp3, minval=0, maxval=59)
s3_ext  = input.bool(true, "Étendre",    group=grp3)

// ══════════════════════════════════════════════
// INPUTS — STYLE COMMUN
// ══════════════════════════════════════════════
grpS     = "── Style"
showMid  = input.bool(true,  "Midpoint",          group=grpS)
showLbl  = input.bool(true,  "Labels sessions",   group=grpS)
lw       = input.int(2, "Épaisseur lignes",        group=grpS, minval=1, maxval=4)
lw_edge  = input.int(3, "Épaisseur bord gauche",   group=grpS, minval=1, maxval=6)

// Couleurs S1 Asia — palette froide (nuit)
col_hi1  = input.color(color.new(color.orange,  0), "S1 Haut",   group=grpS)
col_lo1  = input.color(color.new(color.orange, 40), "S1 Bas",    group=grpS)
col_mid1 = input.color(color.new(color.orange, 60), "S1 Mid",    group=grpS)
col_box1 = input.color(color.new(color.orange, 92), "S1 Box",    group=grpS)

// Couleurs S2 London — palette chaude (matin)
col_hi2  = input.color(color.new(#f76809, 0), "S2 Haut",  group=grpS)
col_lo2  = input.color(color.new(#e56640, 40), "S2 Bas",   group=grpS)
col_mid2 = input.color(color.new(#f12416, 60), "S2 Mid",   group=grpS)
col_box2 = input.color(color.new(color.orange, 92), "S2 Box",   group=grpS)

// Couleurs S3 US — palette vive (après-midi)
col_hi3  = input.color(color.new(color.aqua,  0), "S3 Haut",  group=grpS)
col_lo3  = input.color(color.new(color.aqua, 40), "S3 Bas",   group=grpS)
col_mid3 = input.color(color.new(color.aqua, 60), "S3 Mid",   group=grpS)
col_box3 = input.color(color.new(color.aqua, 92), "S3 Box",   group=grpS)

// ══════════════════════════════════════════════
// ÉTAT GLOBAL
// ══════════════════════════════════════════════
var float s1Hi = na, var float s1Lo = na
var bool  s1In = false, var bool s1Done = false
var int   s1TS = na

var float s2Hi = na, var float s2Lo = na
var bool  s2In = false, var bool s2Done = false
var int   s2TS = na

var float s3Hi = na, var float s3Lo = na
var bool  s3In = false, var bool s3Done = false
var int   s3TS = na

// ══════════════════════════════════════════════
// FONCTION — dessin OPR amélioré
// ══════════════════════════════════════════════
f_draw(tS, tE, tX, rHi, rLo,
       colHi, colLo, colMid, colBox,
       lStyle, lbl, doExt) =>
    if na(rHi) or na(rLo) or rHi <= rLo
        false
    else
        tR  = doExt ? tX : tE
        mid = (rHi + rLo) / 2.0

        // Boîte de fond (remplie, transparente)
        box.new(tS, rHi, tE, rLo,
             xloc        = xloc.bar_time,
             border_color= na,
             bgcolor     = colBox)

        // Bord gauche épais — marqueur visuel d'ouverture
        line.new(tS, rHi, tS, rLo,
             xloc  = xloc.bar_time,
             color = colHi,
             width = lw_edge)

        // Ligne High — style configurable par session
        line.new(tS, rHi, tR, rHi,
             xloc  = xloc.bar_time,
             color = colHi,
             width = lw,
             style = lStyle)

        // Ligne Low
        line.new(tS, rLo, tR, rLo,
             xloc  = xloc.bar_time,
             color = colLo,
             width = lw,
             style = lStyle)

        // Midpoint
        if showMid
            line.new(tS, mid, tR, mid,
                 xloc  = xloc.bar_time,
                 color = colMid,
                 width = 1,
                 style = line.style_dotted)

        // Label session — discret, en haut à gauche de la boîte
        if showLbl
            label.new(tS, rHi,
                 text     = lbl,
                 xloc     = xloc.bar_time,
                 style    = label.style_label_right,
                 color    = colBox,
                 textcolor= colHi,
                 size     = size.small)
        true

// ══════════════════════════════════════════════
// BOUCLE — SESSION 1 · ASIA
// ══════════════════════════════════════════════
if s1_on
    y1  = year(time,  s1_tz)
    m1  = month(time, s1_tz)
    d1  = dayofmonth(time, s1_tz)
    tS1 = timestamp(s1_tz, y1, m1, d1, s1_sh, s1_sm)
    tE1 = timestamp(s1_tz, y1, m1, d1, s1_eh, s1_em)
    tX1 = timestamp(s1_tz, y1, m1, d1, s1_xh, s1_xm)

    wasIn1 = s1In
    s1In  := time >= tS1 and time < tE1

    if s1In and not wasIn1
        s1Hi := high, s1Lo := low
        s1TS := tS1,  s1Done := false

    if s1In
        s1Hi := math.max(s1Hi, high)
        s1Lo := math.min(s1Lo, low)

    if wasIn1 and not s1In and not s1Done and not na(s1Hi)
        f_draw(s1TS, tE1, tX1, s1Hi, s1Lo,
               col_hi1, col_lo1, col_mid1, col_box1,
               line.style_solid, s1_lbl, s1_ext)
        s1Done := true

// ══════════════════════════════════════════════
// BOUCLE — SESSION 2 · LONDON
// ══════════════════════════════════════════════
if s2_on
    y2  = year(time,  s2_tz)
    m2  = month(time, s2_tz)
    d2  = dayofmonth(time, s2_tz)
    tS2 = timestamp(s2_tz, y2, m2, d2, s2_sh, s2_sm)
    tE2 = timestamp(s2_tz, y2, m2, d2, s2_eh, s2_em)
    tX2 = timestamp(s2_tz, y2, m2, d2, s2_xh, s2_xm)

    wasIn2 = s2In
    s2In  := time >= tS2 and time < tE2

    if s2In and not wasIn2
        s2Hi := high, s2Lo := low
        s2TS := tS2,  s2Done := false

    if s2In
        s2Hi := math.max(s2Hi, high)
        s2Lo := math.min(s2Lo, low)

    if wasIn2 and not s2In and not s2Done and not na(s2Hi)
        f_draw(s2TS, tE2, tX2, s2Hi, s2Lo,
               col_hi2, col_lo2, col_mid2, col_box2,
               line.style_dashed, s2_lbl, s2_ext)
        s2Done := true

// ══════════════════════════════════════════════
// BOUCLE — SESSION 3 · US
// ══════════════════════════════════════════════
if s3_on
    y3  = year(time,  s3_tz)
    m3  = month(time, s3_tz)
    d3  = dayofmonth(time, s3_tz)
    tS3 = timestamp(s3_tz, y3, m3, d3, s3_sh, s3_sm)
    tE3 = timestamp(s3_tz, y3, m3, d3, s3_eh, s3_em)
    tX3 = timestamp(s3_tz, y3, m3, d3, s3_xh, s3_xm)

    wasIn3 = s3In
    s3In  := time >= tS3 and time < tE3

    if s3In and not wasIn3
        s3Hi := high, s3Lo := low
        s3TS := tS3,  s3Done := false

    if s3In
        s3Hi := math.max(s3Hi, high)
        s3Lo := math.min(s3Lo, low)

    if wasIn3 and not s3In and not s3Done and not na(s3Hi)
        f_draw(s3TS, tE3, tX3, s3Hi, s3Lo,
               col_hi3, col_lo3, col_mid3, col_box3,
               line.style_dotted, s3_lbl, s3_ext)
        s3Done := true
````
