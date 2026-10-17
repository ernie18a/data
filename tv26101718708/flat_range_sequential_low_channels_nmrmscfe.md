# Flat Range Sequential Low Channels

- url: https://www.tradingview.com/script/NMRmscfe/
- type: indicator
- pine_id: PUB;287ac313690b414385d2a1335327d271
- version: 1.0

## Description

In short:
This indicator finds areas where price is either flat/squeezed or moving in a steady trend, then draws a channel around that area. When price breaks out of the channel, it marks a BREAKOUT and can send an alert. If price goes back inside, it marks a RE-ENTRY. When the channel is no longer valid, the indicator closes it and starts searching for a new one.

Bottom line:
It finds where price is stuck or trending, draws a channel around it, tells you when price breaks out, tells you if it comes back in, and then automatically moves on to find the next opportunity.

What it actually does:

    Finds channels
    It scans recent price bars and tries to fit a channel around them.

        LOW mode: Looks for flat, sideways, low-volatility ranges.

        HIGH mode: Looks for strongly trending, sloped channels.

        BOTH: Runs both searches at the same time.

    Uses “R” to judge the channel
    R is a correlation value between price and time.

        Low |R| = price is flat / moving sideways.

        High |R| = price is trending in a consistent direction.
        You set the thresholds: how flat is “flat enough” for LOW, and how trendy is “trendy enough” for HIGH.

    Draws the channel
    Once a valid range is found, it draws:

        A base line (center)

        An upper border

        A lower border

        Optional fill, midline, and labels showing length and |R|.

    Detects breakouts
    If price closes outside the upper or lower border, it:

        Marks a BREAKOUT label on the chart.

        Optionally fires an alert (up or down, for LOW or HIGH channels).

        Starts a pending breakout state.

    Handles re-entries
    If price moves back inside the channel after a breakout, it:

        Marks a RE-ENTRY label.

        Optionally fires a re-entry alert.

        Cancels the pending breakout and continues the same channel.

    Ends and restarts
    If price stays outside the channel for a certain number of bars (Pending Break Bars), the channel is considered finished. The indicator then starts searching for a brand-new channel from that point.

    Summary label (optional)
    Shows how many confirmed channel segments have been found and which mode is active.

    Alerts
    You can enable alerts for:

        LOW breakout up/down

        HIGH breakout up/down

        Re-entry (LOW and HIGH)

## Source Code

````pine
//@version=6

indicator("Flat Range Sequential Low Channels",shorttitle = "FRF Sequential Channels", overlay=true, max_bars_back=5000, max_lines_count=500, max_labels_count=500)

// ============ INPUTS ============
int    totalLookback = input.int(1000, "Total Lookback (N bars)", minval=20, maxval=4500, group="Search",
     tooltip="Number of historical bars scanned from the current bar to look for flat ranges / channels.")
int    minLen        = input.int(10,  "Min Channel Length", minval=5, maxval=500, group="Search",
     tooltip="Minimum number of bars a candidate channel must contain.")
int    maxLen        = input.int(200, "Max Channel Length", minval=10, maxval=500, group="Search",
     tooltip="Maximum number of bars a candidate channel may contain.")
int    step          = input.int(2,   "Search Step", minval=1, group="Search",
     tooltip="Step size used when scanning candidate channel lengths. Smaller = more accurate but slower.")

string rSel          = input.string("Low", "R Selection Mode", options=["Low","High","Both"], group="Search",
     tooltip="Which channel type to detect:\n• Low: flat / low |R| channels\n• High: strongly trending / high |R| channels\n• Both: run both detectors simultaneously.")

float  lowRMax       = input.float(0.15, "Low Mode  → Max |R| (Low ≤ x)",   minval=0.0, maxval=1.0, step=0.005, group="Search",
     tooltip="Low Mode only. A candidate channel is accepted only if its absolute correlation |R| is less than or equal to this value. Lower = flatter channels.")
float  highRMin      = input.float(0.8999, "High Mode → Min |R| (High ≥ x)", minval=0.0, maxval=1.0, step=0.005, group="Search",
     tooltip="High Mode only. A candidate channel is accepted only if its absolute correlation |R| is greater than or equal to this value. Higher = more strongly trending channels.")

float  devMult       = input.float(2.0, "Deviation Multiplier", minval=0.5, step=0.5, group="Channel Style",
     tooltip="Multiplier applied to the standard deviation of the regression residuals to build the upper and lower channel borders.")
color  chColorLow    = input.color(color.rgb(200, 78, 34), "Low Channel Color",  group="Channel Style",
     tooltip="Border and fill color used for LOW mode channels.")
color  chColorHigh   = input.color(color.rgb(33, 150, 243), "High Channel Color", group="Channel Style",
     tooltip="Border and fill color used for HIGH mode channels.")
int    chTransp      = input.int(40, "Border Transparency", minval=0, maxval=100, group="Channel Style",
     tooltip="Transparency (0 = solid, 100 = invisible) of the channel border lines.")
int    fillTransp    = input.int(93, "Fill Transparency", minval=0, maxval=100, group="Channel Style",
     tooltip="Transparency of the shaded area between the channel borders.")
string lineStyleIn   = input.string("Solid", "Line Style", options=["Solid","Dotted","Dashed"], group="Channel Style",
     tooltip="Line style used for the channel border lines.")
bool   showMidline   = input.bool(true, "Show Midline", group="Channel Style",
     tooltip="Draw a dashed midline through the center of the channel.")
bool   showLabel     = input.bool(false,  "Show Length/R Labels", group="Channel Style",
     tooltip="Show a small label above each channel displaying its length and |R| value.")
bool   showSummary   = input.bool(false,  "Show Summary Label", group="Channel Style",
     tooltip="Show a summary label at the last bar with the total number of confirmed segments and the active mode.")

int    pendingBars   = input.int(5, "Pending Break Bars", minval=1, maxval=50, group="Extend & Restart",
     tooltip="Number of bars a breakout must persist before the channel is treated as ended and a new search starts. Fewer bars = faster restart.")

// ---- BREAKOUT / RE-ENTRY LABEL INPUTS ----
bool   showBreakoutLbl = input.bool(true,  "Show 'BREAKOUT' Label",  group="Breakout Labels",
     tooltip="Show a BREAKOUT label when price closes outside the channel border.")
bool   showReentryLbl  = input.bool(false,  "Show 'RE-ENTRY' Label",  group="Breakout Labels",
     tooltip="Show a RE-ENTRY label when price returns inside the channel after a breakout.")

// ---- ALERT INPUTS ----
bool alertLowUpIn     = input.bool(true,  "Alert: LOW Breakout ▲",   group="Alerts",
     tooltip="Fire an alert when price breaks above the upper border of a LOW channel.")
bool alertLowDnIn     = input.bool(true,  "Alert: LOW Breakout ▼",   group="Alerts",
     tooltip="Fire an alert when price breaks below the lower border of a LOW channel.")
bool alertHighUpIn    = input.bool(true,  "Alert: HIGH Breakout ▲",  group="Alerts",
     tooltip="Fire an alert when price breaks above the upper border of a HIGH channel.")
bool alertHighDnIn    = input.bool(true,  "Alert: HIGH Breakout ▼",  group="Alerts",
     tooltip="Fire an alert when price breaks below the lower border of a HIGH channel.")
bool alertReentryIn   = input.bool(false, "Alert: Re-Entry (LOW & HIGH)", group="Alerts",
     tooltip="Fire an alert when price re-enters a channel after a breakout (both LOW and HIGH modes).")

// ============ MOD SEÇİMİ ============
bool useLow  = rSel == "Low"  or rSel == "Both"
bool useHigh = rSel == "High" or rSel == "Both"

// ============ ALERT SİNYAL FLAG'LERİ (her bar başında sıfırlanır) ============
bool sigLowUp    = false
bool sigLowDn    = false
bool sigHighUp   = false
bool sigHighDn   = false
bool sigReentry  = false

// ============ STATE (Aktif LOW Kanal) ============
var int    L_actStartBar = na
var int    L_actEndBar   = na
var float  L_actSlope    = na
var float  L_actInt      = na
var float  L_actStd      = na
var int    L_actLen      = na
var float  L_actAbsR     = na
var float  L_actFlatBase = na
var line     L_actBase   = na
var line     L_actUpper  = na
var line     L_actLower  = na
var linefill L_actUpFill = na
var linefill L_actDnFill = na
var line     L_actMid    = na
var label    L_actLabel  = na

var line L_extUpper = na
var line L_extLower = na

var int L_pendingSide = 0
var int L_pendingBar  = na

var label L_breakLabel = na

// ============ STATE (Aktif HIGH Kanal) ============
var int    H_actStartBar = na
var int    H_actEndBar   = na
var float  H_actSlope    = na
var float  H_actInt      = na
var float  H_actStd      = na
var int    H_actLen      = na
var float  H_actAbsR     = na
var line     H_actBase   = na
var line     H_actUpper  = na
var line     H_actLower  = na
var linefill H_actUpFill = na
var linefill H_actDnFill = na
var line     H_actMid    = na
var label    H_actLabel  = na

var line H_extUpper = na
var line H_extLower = na

var int H_pendingSide = 0
var int H_pendingBar  = na

var label H_breakLabel = na

// ============ STATE (Sıralı Arama) ============
var int L_nextSearchBar = na
var int H_nextSearchBar = na
var int totalSegCount   = 0

var label sumLabel = na

styleLine = lineStyleIn == "Dotted" ? line.style_dotted : lineStyleIn == "Dashed" ? line.style_dashed : line.style_solid

// ============ ANA MOTOR ============
if barstate.isconfirmed
    if na(L_nextSearchBar)
        L_nextSearchBar := math.max(0, bar_index - totalLookback)
    if na(H_nextSearchBar)
        H_nextSearchBar := math.max(0, bar_index - totalLookback)

    int L_candStart = na
    int L_candEnd   = na
    int H_candStart = na
    int H_candEnd   = na

    // =========================================================
    // LOW FAZ 1
    // =========================================================
    if useLow and not na(L_actStartBar)
        float L_upFlat  = L_actFlatBase + devMult * L_actStd
        float L_loFlat  = L_actFlatBase - devMult * L_actStd

        if L_pendingSide == 0
            line.set_xy2(L_actBase,  bar_index, L_actFlatBase)
            line.set_xy2(L_actUpper, bar_index, L_upFlat)
            line.set_xy2(L_actLower, bar_index, L_loFlat)
            if not na(L_actMid)
                line.set_xy2(L_actMid, bar_index, L_actFlatBase)

            if not na(L_actLabel)
                int totalBars = bar_index - L_actStartBar + 1
                label.set_text(L_actLabel, "L " + str.tostring(L_actLen) + "/" + str.tostring(totalBars) + "  |R|=" + str.tostring(L_actAbsR, "#.####"))

            float bodyHi = math.max(open, close)
            float bodyLo = math.min(open, close)
            bool hitUp = (bodyLo > L_upFlat) and (low > L_upFlat)
            bool hitDn = (bodyHi < L_loFlat) and (high < L_loFlat)

            if hitUp or hitDn
                L_pendingSide := hitUp ? 1 : -1
                L_pendingBar  := bar_index
                L_extUpper := line.new(bar_index, L_upFlat, bar_index, L_upFlat, color=color.new(chColorLow, chTransp), width=2, style=line.style_dashed)
                L_extLower := line.new(bar_index, L_loFlat, bar_index, L_loFlat, color=color.new(chColorLow, chTransp), width=2, style=line.style_dashed)

                if showBreakoutLbl
                    if not na(L_breakLabel)
                        label.delete(L_breakLabel)
                    string brkTxt = hitUp ? "▲ BREAKOUT" : "▼ BREAKOUT"
                    color  brkCol = hitUp ? color.new(color.green, 15) : color.new(color.red, 15)
                    L_breakLabel := label.new(bar_index, hitUp ? high : low, brkTxt,
                         style     = hitUp ? label.style_label_down : label.style_label_up,
                         yloc      = hitUp ? yloc.abovebar : yloc.belowbar,
                         color     = brkCol,
                         textcolor = color.white,
                         size      = size.small)

                // ---- ALARM: LOW BREAKOUT ----
                if hitUp and alertLowUpIn
                    sigLowUp := true
                    alert("LOW Breakout ▲\nKanal üst çizgisi kırıldı\nFiyat: " + str.tostring(close, format.mintick) + "\nSeviye: " + str.tostring(L_upFlat, format.mintick) + "\nLen: " + str.tostring(L_actLen) + " | |R|=" + str.tostring(L_actAbsR, "#.####"), alert.freq_once_per_bar_close)
                if hitDn and alertLowDnIn
                    sigLowDn := true
                    alert("LOW Breakout ▼\nKanal alt çizgisi kırıldı\nFiyat: " + str.tostring(close, format.mintick) + "\nSeviye: " + str.tostring(L_loFlat, format.mintick) + "\nLen: " + str.tostring(L_actLen) + " | |R|=" + str.tostring(L_actAbsR, "#.####"), alert.freq_once_per_bar_close)

            L_candStart := L_actStartBar
            L_candEnd   := bar_index
        else
            if not na(L_extUpper)
                line.set_xy2(L_extUpper, bar_index, L_upFlat)
            if not na(L_extLower)
                line.set_xy2(L_extLower, bar_index, L_loFlat)

            bool revived = false
            if L_pendingSide == 1
                if low <= L_upFlat
                    revived := true
            else
                if high >= L_loFlat
                    revived := true

            if revived
                if not na(L_extUpper)
                    line.delete(L_extUpper)
                    L_extUpper := na
                if not na(L_extLower)
                    line.delete(L_extLower)
                    L_extLower := na
                line.set_xy2(L_actBase,  bar_index, L_actFlatBase)
                line.set_xy2(L_actUpper, bar_index, L_upFlat)
                line.set_xy2(L_actLower, bar_index, L_loFlat)
                if not na(L_actMid)
                    line.set_xy2(L_actMid, bar_index, L_actFlatBase)

                if not na(L_breakLabel)
                    label.delete(L_breakLabel)
                    L_breakLabel := na
                if showReentryLbl
                    bool  wasUpBreakL = L_pendingSide == 1
                    float reY         = wasUpBreakL ? L_upFlat : L_loFlat
                    label.new(bar_index, reY, "◆ RE-ENTRY",
                         style     = wasUpBreakL ? label.style_label_down : label.style_label_up,
                         yloc      = yloc.price,
                         color     = color.new(color.orange, 15),
                         textcolor = color.white,
                         size      = size.small)

                // ---- ALARM: LOW RE-ENTRY ----
                if alertReentryIn
                    sigReentry := true
                    alert("LOW RE-ENTRY (kanala geri dönüş)\nFiyat: " + str.tostring(close, format.mintick) + "\nKanal: " + (L_pendingSide == 1 ? "üst" : "alt") + " çizgiden", alert.freq_once_per_bar_close)

                L_pendingSide := 0
                L_pendingBar  := na
                L_candStart := L_actStartBar
                L_candEnd   := bar_index
            else
                if not na(L_pendingBar) and (bar_index - L_pendingBar) >= pendingBars
                    int solidEndBar = L_pendingBar + 1
                    line.set_xy2(L_actBase,  solidEndBar, L_actFlatBase)
                    line.set_xy2(L_actUpper, solidEndBar, L_actFlatBase + devMult * L_actStd)
                    line.set_xy2(L_actLower, solidEndBar, L_actFlatBase - devMult * L_actStd)
                    if not na(L_actMid)
                        line.set_xy2(L_actMid, solidEndBar, L_actFlatBase)

                    if not na(L_extUpper)
                        line.delete(L_extUpper)
                        L_extUpper := na
                    if not na(L_extLower)
                        line.delete(L_extLower)
                        L_extLower := na

                    L_breakLabel := na

                    totalSegCount += 1
                    L_nextSearchBar := bar_index + 1
                    L_candStart := L_actStartBar
                    L_candEnd   := bar_index
                    L_actStartBar := na
                    L_actEndBar   := na
                    L_actSlope    := na
                    L_actInt      := na
                    L_actStd      := na
                    L_actLen      := na
                    L_actAbsR     := na
                    L_actFlatBase := na
                    L_actBase     := na
                    L_actUpper    := na
                    L_actLower    := na
                    L_actUpFill   := na
                    L_actDnFill   := na
                    L_actMid      := na
                    L_actLabel    := na
                    L_pendingSide := 0
                    L_pendingBar  := na
                else
                    L_candStart := L_actStartBar
                    L_candEnd   := bar_index

    // =========================================================
    // HIGH FAZ 1
    // =========================================================
    if useHigh and not na(H_actStartBar)
        int   k        = bar_index - H_actEndBar
        float extBase  = H_actInt - H_actSlope * k
        float extUpper = extBase + devMult * H_actStd
        float extLower = extBase - devMult * H_actStd

        if H_pendingSide == 0
            line.set_xy2(H_actBase,  bar_index, extBase)
            line.set_xy2(H_actUpper, bar_index, extUpper)
            line.set_xy2(H_actLower, bar_index, extLower)
            if not na(H_actMid)
                line.set_xy2(H_actMid, bar_index, extBase)

            if not na(H_actLabel)
                int totalBars = bar_index - H_actStartBar + 1
                label.set_text(H_actLabel, "H " + str.tostring(H_actLen) + "/" + str.tostring(totalBars) + "  |R|=" + str.tostring(H_actAbsR, "#.####"))

            float bodyHi = math.max(open, close)
            float bodyLo = math.min(open, close)
            bool hitUp = (bodyLo > extUpper) and (low > extUpper)
            bool hitDn = (bodyHi < extLower) and (high < extLower)

            if hitUp or hitDn
                H_pendingSide := hitUp ? 1 : -1
                H_pendingBar  := bar_index
                H_extUpper := line.new(bar_index, extUpper, bar_index, extUpper, color=color.new(chColorHigh, chTransp), width=2, style=line.style_dashed)
                H_extLower := line.new(bar_index, extLower, bar_index, extLower, color=color.new(chColorHigh, chTransp), width=2, style=line.style_dashed)

                if showBreakoutLbl
                    if not na(H_breakLabel)
                        label.delete(H_breakLabel)
                    string brkTxt = hitUp ? "▲ BREAKOUT" : "▼ BREAKOUT"
                    color  brkCol = hitUp ? color.new(color.green, 15) : color.new(color.red, 15)
                    H_breakLabel := label.new(bar_index, hitUp ? high : low, brkTxt,
                         style     = hitUp ? label.style_label_down : label.style_label_up,
                         yloc      = hitUp ? yloc.abovebar : yloc.belowbar,
                         color     = brkCol,
                         textcolor = color.white,
                         size      = size.small)

                // ---- ALARM: HIGH BREAKOUT ----
                if hitUp and alertHighUpIn
                    sigHighUp := true
                    alert("HIGH Breakout ▲\nKanal üst (eğimli) çizgisi kırıldı\nFiyat: " + str.tostring(close, format.mintick) + "\nSeviye: " + str.tostring(extUpper, format.mintick) + "\nLen: " + str.tostring(H_actLen) + " | |R|=" + str.tostring(H_actAbsR, "#.####"), alert.freq_once_per_bar_close)
                if hitDn and alertHighDnIn
                    sigHighDn := true
                    alert("HIGH Breakout ▼\nKanal alt (eğimli) çizgisi kırıldı\nFiyat: " + str.tostring(close, format.mintick) + "\nSeviye: " + str.tostring(extLower, format.mintick) + "\nLen: " + str.tostring(H_actLen) + " | |R|=" + str.tostring(H_actAbsR, "#.####"), alert.freq_once_per_bar_close)

            H_candStart := H_actStartBar
            H_candEnd   := bar_index
        else
            if not na(H_extUpper)
                line.set_xy2(H_extUpper, bar_index, extUpper)
            if not na(H_extLower)
                line.set_xy2(H_extLower, bar_index, extLower)

            bool revived = false
            if H_pendingSide == 1
                if low <= extUpper
                    revived := true
            else
                if high >= extLower
                    revived := true

            if revived
                if not na(H_extUpper)
                    line.delete(H_extUpper)
                    H_extUpper := na
                if not na(H_extLower)
                    line.delete(H_extLower)
                    H_extLower := na
                line.set_xy2(H_actBase,  bar_index, extBase)
                line.set_xy2(H_actUpper, bar_index, extUpper)
                line.set_xy2(H_actLower, bar_index, extLower)
                if not na(H_actMid)
                    line.set_xy2(H_actMid, bar_index, extBase)

                if not na(H_breakLabel)
                    label.delete(H_breakLabel)
                    H_breakLabel := na
                if showReentryLbl
                    bool  wasUpBreakH = H_pendingSide == 1
                    float reY         = wasUpBreakH ? extUpper : extLower
                    label.new(bar_index, reY, "◆ RE-ENTRY",
                         style     = wasUpBreakH ? label.style_label_down : label.style_label_up,
                         yloc      = yloc.price,
                         color     = color.new(color.orange, 15),
                         textcolor = color.white,
                         size      = size.small)

                // ---- ALARM: HIGH RE-ENTRY ----
                if alertReentryIn
                    sigReentry := true
                    alert("HIGH RE-ENTRY (kanala geri dönüş)\nFiyat: " + str.tostring(close, format.mintick) + "\nKanal: " + (H_pendingSide == 1 ? "üst" : "alt") + " (eğimli) çizgiden", alert.freq_once_per_bar_close)

                H_pendingSide := 0
                H_pendingBar  := na
                H_candStart := H_actStartBar
                H_candEnd   := bar_index
            else
                if not na(H_pendingBar) and (bar_index - H_pendingBar) >= pendingBars
                    int solidEndBar = H_pendingBar + 1
                    float eBase = H_actInt - H_actSlope * (solidEndBar - H_actEndBar)
                    float eUp   = eBase + devMult * H_actStd
                    float eLo   = eBase - devMult * H_actStd
                    line.set_xy2(H_actBase,  solidEndBar, eBase)
                    line.set_xy2(H_actUpper, solidEndBar, eUp)
                    line.set_xy2(H_actLower, solidEndBar, eLo)
                    if not na(H_actMid)
                        line.set_xy2(H_actMid, solidEndBar, eBase)

                    if not na(H_extUpper)
                        line.delete(H_extUpper)
                        H_extUpper := na
                    if not na(H_extLower)
                        line.delete(H_extLower)
                        H_extLower := na

                    H_breakLabel := na

                    totalSegCount += 1
                    H_nextSearchBar := bar_index + 1
                    H_candStart := H_actStartBar
                    H_candEnd   := bar_index
                    H_actStartBar := na
                    H_actEndBar   := na
                    H_actSlope    := na
                    H_actInt      := na
                    H_actStd      := na
                    H_actLen      := na
                    H_actAbsR     := na
                    H_actBase     := na
                    H_actUpper    := na
                    H_actLower    := na
                    H_actUpFill   := na
                    H_actDnFill   := na
                    H_actMid      := na
                    H_actLabel    := na
                    H_pendingSide := 0
                    H_pendingBar  := na
                else
                    H_candStart := H_actStartBar
                    H_candEnd   := bar_index

    // =========================================================
    // LOW FAZ 2 — Yeni kanal ara
    // =========================================================
    if useLow and na(L_actStartBar)
        int cursor    = L_nextSearchBar
        int available = bar_index - cursor + 1

        if available >= minLen
            int searchMax = math.min(maxLen, available)

            float bestAbsR   = na
            float bestScore  = na
            int   bestL      = na
            float bestStd    = na
            float bestSlope  = na
            float bestInt    = na

            for L = minLen to searchMax by step
                int n1L = L - 1
                int segEndOffset = bar_index - (cursor + L - 1)

                float sumX  = 0.0
                float sumXX = 0.0
                float sumYX = 0.0
                float sumY  = 0.0
                for i = 1 to L
                    float val = close[segEndOffset + i - 1]
                    sumX  += i
                    sumXX += i * i
                    sumYX += i * val
                    sumY  += val

                float denom = L * sumXX - sumX * sumX
                if denom == 0
                    continue

                float slopeL     = nz((L * sumYX - sumX * sumY) / denom)
                float avgL       = sumY / L
                float interceptL = avgL - slopeL * sumX / L + slopeL

                float sumDev = 0.0
                float sumDxx = 0.0
                float sumDyy = 0.0
                float sumDyx = 0.0
                float regL   = interceptL + slopeL * n1L * 0.5
                float lineV  = interceptL
                for i = 0 to n1L
                    float v   = close[segEndOffset + i]
                    float dxt = v - avgL
                    float dyt = lineV - regL
                    v := v - lineV
                    lineV += slopeL
                    sumDxx += dxt * dxt
                    sumDyy += dyt * dyt
                    sumDyx += dxt * dyt
                    sumDev += v * v

                int   dfL       = math.max(1, L - 2)
                float unStdDevL = math.sqrt(sumDev / dfL)
                float divisorL  = sumDxx * sumDyy
                float rL        = divisorL > 0 ? (sumDyx / math.sqrt(divisorL)) : na

                if not na(rL)
                    float absR = math.abs(rL)
                    if absR <= lowRMax
                        if na(bestScore) or absR < bestScore
                            bestScore := absR
                            bestAbsR  := absR
                            bestL     := L
                            bestStd   := unStdDevL
                            bestSlope := slopeL
                            bestInt   := interceptL

            if not na(bestL)
                int sBar = cursor
                int eBar = cursor + bestL - 1

                float startPrice = bestInt + bestSlope * (bestL - 1)
                float endPrice   = bestInt
                float flatBase   = (startPrice + endPrice) / 2.0
                float upperFlat  = flatBase + devMult * bestStd
                float lowerFlat  = flatBase - devMult * bestStd

                line baseL  = line.new(sBar, flatBase,  eBar, flatBase,  color=color.new(chColorLow, 100), width=1)
                line upperL = line.new(sBar, upperFlat, eBar, upperFlat, color=color.new(chColorLow, chTransp), width=2, style=styleLine)
                line lowerL = line.new(sBar, lowerFlat, eBar, lowerFlat, color=color.new(chColorLow, chTransp), width=2, style=styleLine)

                linefill upF = linefill.new(upperL, baseL, color.new(chColorLow, fillTransp))
                linefill dnF = linefill.new(baseL, lowerL, color.new(chColorLow, fillTransp))

                line mL = na
                if showMidline
                    mL := line.new(sBar, flatBase, eBar, flatBase, color=color.new(color.gray, 50), width=1, style=line.style_dashed)

                label actLbl = na
                if showLabel
                    int   midBar   = math.round((sBar + eBar) / 2)
                    float midPrice = upperFlat + (devMult * bestStd) * 0.2
                    string txt = "L " + str.tostring(bestL) + "  |R|=" + str.tostring(bestAbsR, "#.####")
                    actLbl := label.new(midBar, midPrice, txt, style=label.style_label_down, yloc=yloc.price, color=color.new(chColorLow, 20), textcolor=color.white, size=size.small)

                L_actStartBar := sBar
                L_actEndBar   := eBar
                L_actSlope    := bestSlope
                L_actInt      := bestInt
                L_actStd      := bestStd
                L_actLen      := bestL
                L_actAbsR     := bestAbsR
                L_actFlatBase := flatBase
                L_actBase     := baseL
                L_actUpper    := upperL
                L_actLower    := lowerL
                L_actUpFill   := upF
                L_actDnFill   := dnF
                L_actMid      := mL
                L_actLabel    := actLbl
                L_pendingSide := 0
                L_pendingBar  := na
                L_extUpper    := na
                L_extLower    := na
                L_breakLabel  := na

                L_nextSearchBar := eBar + 1
                L_candStart := sBar
                L_candEnd   := bar_index
            else
                L_nextSearchBar := cursor + step

    // =========================================================
    // HIGH FAZ 2 — Yeni kanal ara
    // =========================================================
    if useHigh and na(H_actStartBar)
        int cursor    = H_nextSearchBar
        int available = bar_index - cursor + 1

        if available >= minLen
            int searchMax = math.min(maxLen, available)

            float bestAbsR   = na
            float bestScore  = na
            int   bestL      = na
            float bestStd    = na
            float bestSlope  = na
            float bestInt    = na

            for L = minLen to searchMax by step
                int n1L = L - 1
                int segEndOffset = bar_index - (cursor + L - 1)

                float sumX  = 0.0
                float sumXX = 0.0
                float sumYX = 0.0
                float sumY  = 0.0
                for i = 1 to L
                    float val = close[segEndOffset + i - 1]
                    sumX  += i
                    sumXX += i * i
                    sumYX += i * val
                    sumY  += val

                float denom = L * sumXX - sumX * sumX
                if denom == 0
                    continue

                float slopeL     = nz((L * sumYX - sumX * sumY) / denom)
                float avgL       = sumY / L
                float interceptL = avgL - slopeL * sumX / L + slopeL

                float sumDev = 0.0
                float sumDxx = 0.0
                float sumDyy = 0.0
                float sumDyx = 0.0
                float regL   = interceptL + slopeL * n1L * 0.5
                float lineV  = interceptL
                for i = 0 to n1L
                    float v   = close[segEndOffset + i]
                    float dxt = v - avgL
                    float dyt = lineV - regL
                    v := v - lineV
                    lineV += slopeL
                    sumDxx += dxt * dxt
                    sumDyy += dyt * dyt
                    sumDyx += dxt * dyt
                    sumDev += v * v

                int   dfL       = math.max(1, L - 2)
                float unStdDevL = math.sqrt(sumDev / dfL)
                float divisorL  = sumDxx * sumDyy
                float rL        = divisorL > 0 ? (sumDyx / math.sqrt(divisorL)) : na

                if not na(rL)
                    float absR = math.abs(rL)
                    if absR >= highRMin
                        float score = absR * math.sqrt(L)
                        if na(bestScore) or score > bestScore
                            bestScore := score
                            bestAbsR  := absR
                            bestL     := L
                            bestStd   := unStdDevL
                            bestSlope := slopeL
                            bestInt   := interceptL

            if not na(bestL)
                int sBar = cursor
                int eBar = cursor + bestL - 1

                float startPrice = bestInt + bestSlope * (bestL - 1)
                float endPrice   = bestInt
                float upperStart = startPrice + devMult * bestStd
                float upperEnd   = endPrice   + devMult * bestStd
                float lowerStart = startPrice - devMult * bestStd
                float lowerEnd   = endPrice   - devMult * bestStd

                line baseL  = line.new(sBar, startPrice, eBar, endPrice, color=color.new(chColorHigh, 100), width=1)
                line upperL = line.new(sBar, upperStart, eBar, upperEnd, color=color.new(chColorHigh, chTransp), width=2, style=styleLine)
                line lowerL = line.new(sBar, lowerStart, eBar, lowerEnd, color=color.new(chColorHigh, chTransp), width=2, style=styleLine)

                linefill upF = linefill.new(upperL, baseL, color.new(chColorHigh, fillTransp))
                linefill dnF = linefill.new(baseL, lowerL, color.new(chColorHigh, fillTransp))

                line mL = na
                if showMidline
                    mL := line.new(sBar, startPrice, eBar, endPrice, color=color.new(color.gray, 50), width=1, style=line.style_dashed)

                label actLbl = na
                if showLabel
                    int   midBar   = math.round((sBar + eBar) / 2)
                    float midPrice = math.max(upperStart, upperEnd) + (devMult * bestStd) * 0.2
                    string txt = "H " + str.tostring(bestL) + "  |R|=" + str.tostring(bestAbsR, "#.####")
                    actLbl := label.new(midBar, midPrice, txt, style=label.style_label_down, yloc=yloc.price, color=color.new(chColorHigh, 20), textcolor=color.white, size=size.small)

                H_actStartBar := sBar
                H_actEndBar   := eBar
                H_actSlope    := bestSlope
                H_actInt      := bestInt
                H_actStd      := bestStd
                H_actLen      := bestL
                H_actAbsR     := bestAbsR
                H_actBase     := baseL
                H_actUpper    := upperL
                H_actLower    := lowerL
                H_actUpFill   := upF
                H_actDnFill   := dnF
                H_actMid      := mL
                H_actLabel    := actLbl
                H_pendingSide := 0
                H_pendingBar  := na
                H_extUpper    := na
                H_extLower    := na
                H_breakLabel  := na

                H_nextSearchBar := eBar + 1
                H_candStart := sBar
                H_candEnd   := bar_index
            else
                H_nextSearchBar := cursor + step

// ============ ALERTCONDITION'LAR (TV dropdown menüsünde görünür) ============
alertcondition(sigLowUp,   title="LOW Breakout ▲",   message="LOW kanal üst çizgisi yukarı kırıldı")
alertcondition(sigLowDn,   title="LOW Breakout ▼",   message="LOW kanal alt çizgisi aşağı kırıldı")
alertcondition(sigHighUp,  title="HIGH Breakout ▲",  message="HIGH kanal üst (eğimli) çizgisi yukarı kırıldı")
alertcondition(sigHighDn,  title="HIGH Breakout ▼",  message="HIGH kanal alt (eğimli) çizgisi aşağı kırıldı")
alertcondition(sigReentry, title="Re-Entry",         message="Fiyat kanala geri döndü (RE-ENTRY)")

// ============ ÖZET ETİKETİ ============
if barstate.islast
    if showSummary and totalSegCount > 0
        string summaryTxt = "Confirmed Segments: " + str.tostring(totalSegCount) + "  |  Mode: " + rSel
        if na(sumLabel)
            sumLabel := label.new(bar_index, high, summaryTxt, style=label.style_label_down, yloc=yloc.abovebar, color=color.new(color.blue, 20), textcolor=color.white, size=size.small)
        else
            label.set_xy(sumLabel, bar_index, high)
            label.set_text(sumLabel, summaryTxt)
    else
        if not na(sumLabel)
            label.delete(sumLabel)
            sumLabel := na
````
