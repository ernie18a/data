# SWING ATR Based V2 - Weekly + Daily

- url: https://www.tradingview.com/script/c4FT63qQ/
- type: indicator
- pine_id: PUB;e437e8f7450844c6ae78963552788ef4
- version: 1.0

## Description

What does this indicator do?

This is a dual-timeframe extension of the original SGE script. It runs the same structural logic on Weekly (macro filter) and Daily (tactical trigger) simultaneously, with a new Price Discovery detection layer.

1. It identifies Market Swings on two timeframes
The script monitors price action on both the Weekly and the Daily charts at the same time. Each timeframe has its own ATR-based volatility filter, its own range threshold (kRange), and its own confirmation logic requiring at least two significant candles to validate a directional change. The Weekly is fetched via request.security; the Daily runs natively on the chart's bars.

2. It plots Support and Resistance zones for each timeframe
Weekly levels: solid lines, brighter colors (green/red by default).
Daily levels: dashed lines, accent colors (blue/orange by default), tagged with ▲D / ▼D markers.
Auto-cleaning: once a level is broken by a close, the line turns gray and stops extending. Only unbroken levels remain active.

3. It calculates two SGE Scores with a new Price Discovery layer
Each timeframe has its own score (-2 / 0 / +2), with the same one-candle delay as before. The new logic:

Breaking a support/resistance with other levels still standing → score goes to ±2 directly, or to 0 if the previous score was the opposite extreme (smooth transition).
Breaking the last support or the last resistance → Price Discovery mode: the score jumps directly to ±2 regardless of previous state, signaling that the structure has run out of opposing levels.

4. It simplifies visual reading
Each timeframe shows only its N closest unbroken levels (configurable per TF).
The chart candles are colored by the Weekly score (Weekly is treated as the dominant macro filter). If Weekly is disabled, the candles stay neutral.

5. Dashboard (top-right)
A side-by-side panel showing both timeframes:

Current SGE Score (-2 / 0 / +2)
Price Discovery state (UP / DOWN / Non)
Number of active supports
Number of active resistances
Number of levels currently displayed

Summary: A dual-timeframe structural detector. Weekly defines the dominant context; Daily provides faster signals within that context. The Price Discovery flag highlights moments when the market has broken all opposing structure — typically the highest-conviction zones for trend continuation.
Recommended Settings:

kRange: 1.3 / 1.4 (both TFs)
ATR Mult: 0.3 to 0.5
Trade ideas: take Daily entries only when Weekly score agrees (or is in Price Discovery in the same direction).

Script created with Claude AI.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © maximesuty3

//@version=5
indicator("SGE COMBINED - Weekly + Daily", overlay=true, max_lines_count=500, max_labels_count=500)

// ==========================================
// 0. ACTIVATION DES TIMEFRAMES
// ==========================================
grp_enable    = "Activation Timeframes"
enableWeekly  = input.bool(true, "Activer Weekly", group=grp_enable)
enableDaily   = input.bool(true, "Activer Daily", group=grp_enable)

// ==========================================
// 1. PARAMÈTRES WEEKLY
// ==========================================
grp_struct_w  = "Structure Weekly"
atrLen_w      = input.int(14, "ATR Weekly Length", group=grp_struct_w)
kRange_w      = input.float(1.4, "Range Global ATR Mult Weekly", group=grp_struct_w)
kCandle_w     = input.float(0.0, "Min Candle Size ATR Mult Weekly", group=grp_struct_w)
initialScore_w = input.int(0, "Score Initial Weekly", options=[2, 0, -2], group=grp_struct_w)

grp_vis_w     = "Visuel Weekly"
maxLevelsShow_w = input.int(3, "Niveaux Weekly à afficher", minval=1, maxval=10, group=grp_vis_w)
colorUp_w     = input.color(#00ff00, "Couleur Bull Weekly", group=grp_vis_w)
colorDown_w   = input.color(#ff0000, "Couleur Bear Weekly", group=grp_vis_w)
colorNeutral_w = input.color(#808080, "Couleur Neutre Weekly", group=grp_vis_w)
lineWidth_w   = input.int(2, "Épaisseur Lignes Weekly", group=grp_vis_w)

// ==========================================
// 2. PARAMÈTRES DAILY
// ==========================================
grp_struct_d  = "Structure Daily"
atrLen_d      = input.int(14, "ATR Daily Length", group=grp_struct_d)
kRange_d      = input.float(1.4, "Range Global ATR Mult Daily", group=grp_struct_d)
kCandle_d     = input.float(0.0, "Min Candle Size ATR Mult Daily", group=grp_struct_d)
initialScore_d = input.int(0, "Score Initial Daily", options=[2, 0, -2], group=grp_struct_d)

grp_vis_d     = "Visuel Daily"
maxLevelsShow_d = input.int(3, "Niveaux Daily à afficher", minval=1, maxval=10, group=grp_vis_d)
colorUp_d     = input.color(#00bfff, "Couleur Bull Daily", group=grp_vis_d)  // Bleu clair
colorDown_d   = input.color(#ff8c00, "Couleur Bear Daily", group=grp_vis_d)  // Orange
colorNeutral_d = input.color(#696969, "Couleur Neutre Daily", group=grp_vis_d)
lineWidth_d   = input.int(1, "Épaisseur Lignes Daily", group=grp_vis_d)
showSymbols_d = input.bool(true, "Afficher symboles Daily", group=grp_vis_d)

// ==========================================
// PARTIE WEEKLY - MTF
// ==========================================
timeframe_weekly = "1W"

// Récupération des données TOUJOURS (même si désactivé)
[wO, wH, wL, wC] = request.security(syminfo.tickerid, timeframe_weekly, [open, high, low, close], lookahead=barmerge.lookahead_off)
wAtr = request.security(syminfo.tickerid, timeframe_weekly, ta.atr(atrLen_w), lookahead=barmerge.lookahead_off)

var float lastWeeklyClose = na
bool newWeeklyBar = na(lastWeeklyClose) or wC != lastWeeklyClose
lastWeeklyClose := wC

w_O = wO, w_H = wH, w_L = wL, w_C = wC
w_Atr = wAtr
w_isBigCandle = math.abs(w_C - w_O) >= (w_Atr * kCandle_w)

// Variables d'état Weekly
var int   w_swingDir = 1
var float w_currentExtremum = na
var int   w_candidateCount = 0
var float w_candidateHigh = na
var float w_candidateLow = na
var float w_currentSwingHighClose = na
var float w_currentSwingLowClose = na

var int     w_scoreSGE = initialScore_w
var int     w_pendingScore = na
var line[]  w_bullLines = array.new<line>(0)
var line[]  w_bearLines = array.new<line>(0)
var float[] w_bullLevels = array.new<float>(0)
var float[] w_bearLevels = array.new<float>(0)

if na(w_currentExtremum)
    w_currentExtremum := w_swingDir == 1 ? w_H : w_L

if newWeeklyBar
    w_currentSwingHighClose := na(w_currentSwingHighClose) ? w_C : math.max(w_currentSwingHighClose, w_C)
    w_currentSwingLowClose  := na(w_currentSwingLowClose)  ? w_C : math.min(w_currentSwingLowClose, w_C)

// Détection swing Weekly (seulement si activé)
bool w_confirmedBull = false
bool w_confirmedBear = false
float w_newLevel = na

if enableWeekly and newWeeklyBar
    if w_swingDir == 1
        if w_H > w_currentExtremum
            w_currentExtremum := w_H
            w_candidateCount := 0
        if w_C < w_O and w_isBigCandle
            w_candidateCount += 1
        if w_candidateCount > 0
            w_candidateHigh := na(w_candidateHigh) ? w_H : math.max(w_candidateHigh, w_H)
            w_candidateLow  := na(w_candidateLow)  ? w_L : math.min(w_candidateLow, w_L)
            if w_candidateCount >= 2 and (w_candidateHigh - w_candidateLow) >= (w_Atr * kRange_w)
                w_swingDir := -1
                w_confirmedBear := true
                w_newLevel := w_currentSwingHighClose
                w_currentExtremum := w_L
                w_candidateCount := 0
                w_currentSwingHighClose := w_C
                w_currentSwingLowClose := w_C
                w_candidateHigh := na
                w_candidateLow := na
    else
        if w_L < w_currentExtremum
            w_currentExtremum := w_L
            w_candidateCount := 0
        if w_C > w_O and w_isBigCandle
            w_candidateCount += 1
        if w_candidateCount > 0
            w_candidateHigh := na(w_candidateHigh) ? w_H : math.max(w_candidateHigh, w_H)
            w_candidateLow  := na(w_candidateLow)  ? w_L : math.min(w_candidateLow, w_L)
            if w_candidateCount >= 2 and (w_candidateHigh - w_candidateLow) >= (w_Atr * kRange_w)
                w_swingDir := 1
                w_confirmedBull := true
                w_newLevel := w_currentSwingLowClose
                w_currentExtremum := w_H
                w_candidateCount := 0
                w_currentSwingHighClose := w_C
                w_currentSwingLowClose := w_C
                w_candidateHigh := na
                w_candidateLow := na

if enableWeekly
    if w_confirmedBull
        array.unshift(w_bullLines, line.new(bar_index, w_newLevel, bar_index + 1, w_newLevel, color=colorUp_w, width=lineWidth_w))
        array.unshift(w_bullLevels, w_newLevel)
    if w_confirmedBear
        array.unshift(w_bearLines, line.new(bar_index, w_newLevel, bar_index + 1, w_newLevel, color=colorDown_w, width=lineWidth_w))
        array.unshift(w_bearLevels, w_newLevel)

// Cassures Weekly
int w_brokenBull = 0, w_brokenBear = 0

if enableWeekly
    if array.size(w_bullLevels) > 0
        for i = array.size(w_bullLevels) - 1 to 0
            if w_C < array.get(w_bullLevels, i)
                w_brokenBull += 1
                ln = array.get(w_bullLines, i)
                line.set_x2(ln, bar_index)
                line.set_color(ln, color.new(colorNeutral_w, 60))
                array.remove(w_bullLines, i)
                array.remove(w_bullLevels, i)
            else
                line.set_x2(array.get(w_bullLines, i), bar_index + 1)

    if array.size(w_bearLevels) > 0
        for i = array.size(w_bearLevels) - 1 to 0
            if w_C > array.get(w_bearLevels, i)
                w_brokenBear += 1
                ln = array.get(w_bearLines, i)
                line.set_x2(ln, bar_index)
                line.set_color(ln, color.new(colorNeutral_w, 60))
                array.remove(w_bearLines, i)
                array.remove(w_bearLevels, i)
            else
                line.set_x2(array.get(w_bearLines, i), bar_index + 1)

    // Mise à jour Score SGE Weekly - AVEC PRICE DISCOVERY
    if not na(w_pendingScore)
        w_scoreSGE := w_pendingScore
        w_pendingScore := na

    // LOGIQUE PRICE DISCOVERY WEEKLY
    if w_brokenBull > 0
        // Cassure de support(s)
        if array.size(w_bullLevels) == 0
            // Plus aucun support → Price Discovery baissier
            w_pendingScore := -2
        else
            // Il reste des supports
            w_pendingScore := w_brokenBull >= 2 ? -2 : (w_scoreSGE == 2 ? 0 : -2)

    if w_brokenBear > 0
        // Cassure de résistance(s)
        if array.size(w_bearLevels) == 0
            // Plus aucune résistance → Price Discovery haussier
            w_pendingScore := 2
        else
            // Il reste des résistances
            w_pendingScore := w_brokenBear >= 2 ? 2 : (w_scoreSGE == -2 ? 0 : 2)

// ==========================================
// PARTIE DAILY - NATIVE
// ==========================================
var int d_scoreSGE = initialScore_d
var int d_pendingScore = na
var line[] d_bullLines = array.new<line>(0)
var line[] d_bearLines = array.new<line>(0)
var float[] d_bullLevels = array.new<float>(0)
var float[] d_bearLevels = array.new<float>(0)

if enableDaily
    d_O = open, d_H = high, d_L = low, d_C = close
    d_Atr = ta.atr(atrLen_d)
    d_isBigCandle = math.abs(d_C - d_O) >= (d_Atr * kCandle_d)

    // Variables d'état Daily
    var int   d_swingDir = 1
    var float d_currentExtremum = high
    var int   d_candidateCount = 0
    var float d_candidateHigh = na
    var float d_candidateLow = na
    var float d_currentSwingHighClose = na
    var float d_currentSwingLowClose = na

    d_currentSwingHighClose := na(d_currentSwingHighClose) ? d_C : math.max(d_currentSwingHighClose, d_C)
    d_currentSwingLowClose  := na(d_currentSwingLowClose)  ? d_C : math.min(d_currentSwingLowClose, d_C)

    // Détection swing Daily
    bool d_confirmedBull = false
    bool d_confirmedBear = false
    float d_newLevel = na

    if d_swingDir == 1
        if d_H > d_currentExtremum
            d_currentExtremum := d_H
            d_candidateCount := 0
        if d_C < d_O and d_isBigCandle
            d_candidateCount += 1
        if d_candidateCount > 0
            d_candidateHigh := na(d_candidateHigh) ? d_H : math.max(d_candidateHigh, d_H)
            d_candidateLow  := na(d_candidateLow)  ? d_L : math.min(d_candidateLow, d_L)
            if d_candidateCount >= 2 and (d_candidateHigh - d_candidateLow) >= (d_Atr * kRange_d)
                d_swingDir := -1
                d_confirmedBear := true
                d_newLevel := d_currentSwingHighClose
                d_currentExtremum := d_L
                d_candidateCount := 0
                d_currentSwingHighClose := d_C
                d_currentSwingLowClose := d_C
    else
        if d_L < d_currentExtremum
            d_currentExtremum := d_L
            d_candidateCount := 0
        if d_C > d_O and d_isBigCandle
            d_candidateCount += 1
        if d_candidateCount > 0
            d_candidateHigh := na(d_candidateHigh) ? d_H : math.max(d_candidateHigh, d_H)
            d_candidateLow  := na(d_candidateLow)  ? d_L : math.min(d_candidateLow, d_L)
            if d_candidateCount >= 2 and (d_candidateHigh - d_candidateLow) >= (d_Atr * kRange_d)
                d_swingDir := 1
                d_confirmedBull := true
                d_newLevel := d_currentSwingLowClose
                d_currentExtremum := d_H
                d_candidateCount := 0
                d_currentSwingHighClose := d_C
                d_currentSwingLowClose := d_C

    if d_confirmedBull
        array.unshift(d_bullLines, line.new(bar_index, d_newLevel, bar_index + 1, d_newLevel, color=colorUp_d, width=lineWidth_d, style=line.style_dashed))
        array.unshift(d_bullLevels, d_newLevel)
        if showSymbols_d
            label.new(bar_index, d_newLevel, "▲D", color=color.new(colorUp_d, 0), textcolor=color.white, style=label.style_label_up, size=size.tiny)
    if d_confirmedBear
        array.unshift(d_bearLines, line.new(bar_index, d_newLevel, bar_index + 1, d_newLevel, color=colorDown_d, width=lineWidth_d, style=line.style_dashed))
        array.unshift(d_bearLevels, d_newLevel)
        if showSymbols_d
            label.new(bar_index, d_newLevel, "▼D", color=color.new(colorDown_d, 0), textcolor=color.white, style=label.style_label_down, size=size.tiny)

    // Cassures Daily
    int d_brokenBull = 0, d_brokenBear = 0

    if array.size(d_bullLevels) > 0
        for i = array.size(d_bullLevels) - 1 to 0
            if d_C < array.get(d_bullLevels, i)
                d_brokenBull += 1
                ln = array.get(d_bullLines, i)
                line.set_x2(ln, bar_index)
                line.set_color(ln, color.new(colorNeutral_d, 60))
                array.remove(d_bullLines, i)
                array.remove(d_bullLevels, i)
            else
                line.set_x2(array.get(d_bullLines, i), bar_index + 1)

    if array.size(d_bearLevels) > 0
        for i = array.size(d_bearLevels) - 1 to 0
            if d_C > array.get(d_bearLevels, i)
                d_brokenBear += 1
                ln = array.get(d_bearLines, i)
                line.set_x2(ln, bar_index)
                line.set_color(ln, color.new(colorNeutral_d, 60))
                array.remove(d_bearLines, i)
                array.remove(d_bearLevels, i)
            else
                line.set_x2(array.get(d_bearLines, i), bar_index + 1)

    // Mise à jour Score SGE Daily - AVEC PRICE DISCOVERY
    if not na(d_pendingScore)
        d_scoreSGE := d_pendingScore
        d_pendingScore := na

    // LOGIQUE PRICE DISCOVERY DAILY
    if d_brokenBull > 0
        // Cassure de support(s)
        if array.size(d_bullLevels) == 0
            // Plus aucun support → Price Discovery baissier
            d_pendingScore := -2
        else
            // Il reste des supports
            d_pendingScore := d_brokenBull >= 2 ? -2 : (d_scoreSGE == 2 ? 0 : -2)

    if d_brokenBear > 0
        // Cassure de résistance(s)
        if array.size(d_bearLevels) == 0
            // Plus aucune résistance → Price Discovery haussier
            d_pendingScore := 2
        else
            // Il reste des résistances
            d_pendingScore := d_brokenBear >= 2 ? 2 : (d_scoreSGE == -2 ? 0 : 2)

// ==========================================
// FILTRAGE VISUEL
// ==========================================
if barstate.islast
    // Weekly
    if enableWeekly
        int[] w_bullIdx = array.new_int(0)
        int[] w_bearIdx = array.new_int(0)
        
        if array.size(w_bullLines) > 0
            for i = 0 to array.size(w_bullLines) - 1
                line.set_color(array.get(w_bullLines, i), color.new(colorUp_w, 100))
                array.push(w_bullIdx, i)
        if array.size(w_bearLines) > 0
            for i = 0 to array.size(w_bearLines) - 1
                line.set_color(array.get(w_bearLines, i), color.new(colorDown_w, 100))
                array.push(w_bearIdx, i)

        if array.size(w_bullLevels) > 0
            for k = 1 to math.min(maxLevelsShow_w, array.size(w_bullLevels))
                float maxVal = -1.0
                int bestI = -1
                for i = 0 to array.size(w_bullIdx) - 1
                    int actualIdx = array.get(w_bullIdx, i)
                    float val = array.get(w_bullLevels, actualIdx)
                    if val > maxVal
                        maxVal := val
                        bestI := i
                if bestI != -1
                    line.set_color(array.get(w_bullLines, array.get(w_bullIdx, bestI)), colorUp_w)
                    array.remove(w_bullIdx, bestI)

        if array.size(w_bearLevels) > 0
            for k = 1 to math.min(maxLevelsShow_w, array.size(w_bearLevels))
                float minVal = 1000000000.0
                int bestI = -1
                for i = 0 to array.size(w_bearIdx) - 1
                    int actualIdx = array.get(w_bearIdx, i)
                    float val = array.get(w_bearLevels, actualIdx)
                    if val < minVal
                        minVal := val
                        bestI := i
                if bestI != -1
                    line.set_color(array.get(w_bearLines, array.get(w_bearIdx, bestI)), colorDown_w)
                    array.remove(w_bearIdx, bestI)

    // Daily
    if enableDaily
        int[] d_bullIdx = array.new_int(0)
        int[] d_bearIdx = array.new_int(0)
        
        if array.size(d_bullLines) > 0
            for i = 0 to array.size(d_bullLines) - 1
                line.set_color(array.get(d_bullLines, i), color.new(colorUp_d, 100))
                array.push(d_bullIdx, i)
        if array.size(d_bearLines) > 0
            for i = 0 to array.size(d_bearLines) - 1
                line.set_color(array.get(d_bearLines, i), color.new(colorDown_d, 100))
                array.push(d_bearIdx, i)

        if array.size(d_bullLevels) > 0
            for k = 1 to math.min(maxLevelsShow_d, array.size(d_bullLevels))
                float maxVal = -1.0
                int bestI = -1
                for i = 0 to array.size(d_bullIdx) - 1
                    int actualIdx = array.get(d_bullIdx, i)
                    float val = array.get(d_bullLevels, actualIdx)
                    if val > maxVal
                        maxVal := val
                        bestI := i
                if bestI != -1
                    line.set_color(array.get(d_bullLines, array.get(d_bullIdx, bestI)), colorUp_d)
                    array.remove(d_bullIdx, bestI)

        if array.size(d_bearLevels) > 0
            for k = 1 to math.min(maxLevelsShow_d, array.size(d_bearLevels))
                float minVal = 1000000000.0
                int bestI = -1
                for i = 0 to array.size(d_bearIdx) - 1
                    int actualIdx = array.get(d_bearIdx, i)
                    float val = array.get(d_bearLevels, actualIdx)
                    if val < minVal
                        minVal := val
                        bestI := i
                if bestI != -1
                    line.set_color(array.get(d_bearLines, array.get(d_bearIdx, bestI)), colorDown_d)
                    array.remove(d_bearIdx, bestI)

// ==========================================
// DASHBOARD & BARCOLOR
// ==========================================
// Détection Price Discovery
bool w_priceDiscoveryUp = enableWeekly and array.size(w_bearLevels) == 0 and w_scoreSGE == 2
bool w_priceDiscoveryDown = enableWeekly and array.size(w_bullLevels) == 0 and w_scoreSGE == -2
bool d_priceDiscoveryUp = enableDaily and array.size(d_bearLevels) == 0 and d_scoreSGE == 2
bool d_priceDiscoveryDown = enableDaily and array.size(d_bullLevels) == 0 and d_scoreSGE == -2

// Barcolor suit le Weekly si activé, sinon neutre
barcolor(enableWeekly ? (w_scoreSGE == 2 ? colorUp_w : w_scoreSGE == -2 ? colorDown_w : colorNeutral_w) : color.new(color.gray, 80))

// Dashboard adaptatif selon les timeframes activés
int tableRows = 0
if enableWeekly
    tableRows += 1
if enableDaily
    tableRows += 1

var table info = table.new(position.top_right, enableWeekly and enableDaily ? 3 : 2, 7, bgcolor=color.new(color.black, 70), border_width=1)
if barstate.islast
    int row = 0
    
    // Ligne de titre
    table.cell(info, 0, row, "Timeframe", text_color=color.white, text_size=size.small)
    if enableWeekly
        table.cell(info, 1, row, "Weekly", text_color=color.aqua, text_size=size.small)
    if enableDaily
        table.cell(info, enableWeekly ? 2 : 1, row, "Daily", text_color=color.yellow, text_size=size.small)
    row += 1
    
    // Score SGE
    table.cell(info, 0, row, "Score SGE:", text_color=color.white, text_size=size.normal)
    if enableWeekly
        table.cell(info, 1, row, str.tostring(w_scoreSGE), text_color=w_scoreSGE == 2 ? colorUp_w : w_scoreSGE == -2 ? colorDown_w : colorNeutral_w, text_size=size.normal)
    if enableDaily
        table.cell(info, enableWeekly ? 2 : 1, row, str.tostring(d_scoreSGE), text_color=d_scoreSGE == 2 ? colorUp_d : d_scoreSGE == -2 ? colorDown_d : colorNeutral_d, text_size=size.normal)
    row += 1
    
    // Price Discovery
    table.cell(info, 0, row, "Price Discovery:", text_color=color.white, text_size=size.small)
    if enableWeekly
        string w_pd_text = w_priceDiscoveryUp ? "UP" : w_priceDiscoveryDown ? "DOWN" : "Non"
        color w_pd_color = w_priceDiscoveryUp ? color.lime : w_priceDiscoveryDown ? color.red : color.gray
        table.cell(info, 1, row, w_pd_text, text_color=w_pd_color, text_size=size.small)
    if enableDaily
        string d_pd_text = d_priceDiscoveryUp ? "UP" : d_priceDiscoveryDown ? "DOWN" : "Non"
        color d_pd_color = d_priceDiscoveryUp ? color.lime : d_priceDiscoveryDown ? color.red : color.gray
        table.cell(info, enableWeekly ? 2 : 1, row, d_pd_text, text_color=d_pd_color, text_size=size.small)
    row += 1
    
    // Supports
    table.cell(info, 0, row, "Supports:", text_color=color.white, text_size=size.small)
    if enableWeekly
        table.cell(info, 1, row, str.tostring(array.size(w_bullLevels)), text_color=colorUp_w, text_size=size.small)
    if enableDaily
        table.cell(info, enableWeekly ? 2 : 1, row, str.tostring(array.size(d_bullLevels)), text_color=colorUp_d, text_size=size.small)
    row += 1
    
    // Résistances
    table.cell(info, 0, row, "Résistances:", text_color=color.white, text_size=size.small)
    if enableWeekly
        table.cell(info, 1, row, str.tostring(array.size(w_bearLevels)), text_color=colorDown_w, text_size=size.small)
    if enableDaily
        table.cell(info, enableWeekly ? 2 : 1, row, str.tostring(array.size(d_bearLevels)), text_color=colorDown_d, text_size=size.small)
    row += 1
    
    // Affichés
    table.cell(info, 0, row, "Affichés:", text_color=color.white, text_size=size.small)
    if enableWeekly
        table.cell(info, 1, row, str.tostring(maxLevelsShow_w), text_color=color.aqua, text_size=size.small)
    if enableDaily
        table.cell(info, enableWeekly ? 2 : 1, row, str.tostring(maxLevelsShow_d), text_color=color.yellow, text_size=size.small)
````
