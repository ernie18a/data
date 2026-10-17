# GannEdge Pro - Cycle Intelligence (FREE)

- url: https://www.tradingview.com/script/X7CWrAwf-GannEdge-Pro-Cycle-Intelligence-FREE/
- type: indicator
- pine_id: PUB;976b2f03819f4819a5e940ac4b4f5a32
- version: 1.0

## Description

GannEdge Pro — Cycle Intelligence FREE

Identifies Gann cycle direction using highest high / lowest low anchoring.

🟢 GREEN background = Bullish cycle (from LOW)
🔴 RED background = Bearish cycle (from HIGH)
🟡 YELLOW bar = New cycle boundary — potential reversal zone

This is the FREE version. Upgrade to Basic or Pro for:
🔒 Phase labels (IMPULSE / CORRECTION / EXHAUSTION)
🔒 Signal labels (STRONG LONG / STRONG SHORT / CAUTION)
🔒 TP Levels on chart (TP1 / TP2 / TP3)
🔒 Next Milestone countdown with exact date & time
🔒 Multi-Timeframe Confluence panel
🔒 Trailing Stop Loss & Invalidation levels
🔒 12 alert types

DM @gannedge2009 on X to upgrade.

(c) GannEdgePro 2026 — All rights reserved.

## Source Code

````pine
//@version=5
// (c) GannEdgePro
// GannEdge Pro — Cycle Intelligence | FREE PUBLIC VERSION
// -------------------------------------------------------
// This is the FREE teaser version of GannEdge Pro.
// It shows Gann cycle direction background colour only.
//
// GREEN background  = Cycle from LOW  (bullish — momentum phase)
// RED background    = Cycle from HIGH (bearish — momentum phase)
// YELLOW bar        = NEW CYCLE boundary (potential reversal zone)
//
// -------------------------------------------------------
// Upgrade to BASIC or PRO for full Cycle Intelligence:
//   • Phase labels  (IMPULSE / CORRECTION / EXHAUSTION)
//   • Signal labels (STRONG LONG / STRONG SHORT / CAUTION)
//   • Milestone countdown (30 / 60 / 90 MARK with exact dates)
//   • Take Profit levels on chart (TP1 / TP2 / TP3)
//   • Auto Fibonacci levels and extensions
//   • Multi-Timeframe Confluence panel
//   • Trailing Stop Loss and Invalidation levels
//   • Gann Seasonal Date lines
//   • Full alert suite (12 alert types)
// -------------------------------------------------------
// (c) GannEdgePro 2026 — All rights reserved.
// Unauthorised reproduction or distribution is prohibited.
// -------------------------------------------------------

indicator("GannEdge Pro — Cycle Intelligence (FREE)", shorttitle="GannEdge Pro FREE", overlay=true, max_bars_back=5000)

// ===============================================================================
// INPUTS
// ===============================================================================

cycleLength     = input.int(90,   "Gann Cycle Length",       minval=45, maxval=360, step=45,  group="Cycle Settings")
extremeLookback = input.int(1000, "Extreme Lookback (bars)", minval=50, maxval=5000, step=50, group="Cycle Settings")
bgOpacity       = input.int(20,   "Background Opacity (0=solid, 100=invisible)", minval=0, maxval=99, group="Display")
showWatermark   = input.bool(true, "Show Watermark",   group="Display")
showPanel       = input.bool(true, "Show Info Panel",  group="Display")
panelPos        = input.string("Top Right", "Panel Position", options=["Top Left","Top Right","Bottom Left","Bottom Right"], group="Display")

// ===============================================================================
// FIND CYCLE START — most recent highest high or lowest low
// ===============================================================================

int safeLookback = math.min(extremeLookback, bar_index)

float hh      = high
int   hh_bars = 0
for i = 0 to safeLookback
    if high[i] > hh
        hh      := high[i]
        hh_bars := i

float ll      = low
int   ll_bars = 0
for i = 0 to safeLookback
    if low[i] < ll
        ll      := low[i]
        ll_bars := i

bool highIsMoreRecent = hh_bars < ll_bars
int  cycleStartBar    = highIsMoreRecent ? hh_bars : ll_bars

// Current bar position in cycle
int currentPos = cycleStartBar % cycleLength

// ===============================================================================
// BACKGROUND SHADING
// GREEN  = cycle from LOW  (bullish impulse)
// RED    = cycle from HIGH (bearish impulse)
// YELLOW = NEW CYCLE boundary bar
// ===============================================================================

var int cycleAnchorIdx = 0
if barstate.islast
    cycleAnchorIdx := bar_index - cycleStartBar

int barPos = (bar_index - cycleAnchorIdx) % cycleLength
if barPos < 0
    barPos := barPos + cycleLength

int  cyclesAhead   = math.floor((bar_index - cycleAnchorIdx) / cycleLength)
bool projectedHigh = (cyclesAhead % 2 == 0) ? highIsMoreRecent : not highIsMoreRecent

color bgCol = barPos == 0
     ? color.new(#FFFF00, bgOpacity)
     : projectedHigh
         ? color.new(#FF0000, bgOpacity)
         : color.new(#00FF00, bgOpacity)

bgcolor(bgCol)

// ===============================================================================
// INFO PANEL — Teaser box (locked fields with upgrade prompts)
// ===============================================================================

string panelPosition = panelPos == "Top Left"    ? position.top_left    :
                       panelPos == "Top Right"   ? position.top_right   :
                       panelPos == "Bottom Left" ? position.bottom_left :
                       position.bottom_right

var table panel = table.new(
     position     = panelPosition,
     columns      = 2,
     rows         = 10,
     bgcolor      = color.new(#0a0a0a, 10),
     border_color = color.new(#444444, 0),
     border_width = 1,
     frame_color  = color.new(#FFD700, 0),
     frame_width  = 2)

if barstate.islast and showPanel

    // ── Header ──────────────────────────────────────────────────────────────
    table.cell(panel, 0, 0, "  GannEdge Pro  |  FREE VERSION  ", 
         text_color=color.new(#FFD700, 0), text_size=size.large, 
         bgcolor=color.new(#0a0a0a, 0), text_halign=text.align_center)
    table.cell(panel, 1, 0, "", bgcolor=color.new(#0a0a0a, 0))
    table.merge_cells(panel, 0, 0, 1, 0)

    // ── Divider label ───────────────────────────────────────────────────────
    table.cell(panel, 0, 1, "FEATURE", 
         text_color=color.new(#888888, 0), text_size=size.normal, 
         bgcolor=color.new(#111111, 0), text_halign=text.align_center)
    table.cell(panel, 1, 1, "STATUS", 
         text_color=color.new(#888888, 0), text_size=size.normal, 
         bgcolor=color.new(#111111, 0), text_halign=text.align_center)

    // ── Bar count — shown ───────────────────────────────────────────────────
    int barsInCycle = currentPos == 0 ? cycleLength : currentPos
    table.cell(panel, 0, 2, "Bar in Cycle", 
         text_color=color.white, text_size=size.normal, bgcolor=color.new(#1a1a1a, 0))
    table.cell(panel, 1, 2, str.tostring(barsInCycle) + " / " + str.tostring(cycleLength), 
         text_color=color.new(#00BFFF, 0), text_size=size.normal, bgcolor=color.new(#1a1a1a, 0))

    // ── Phase — locked ──────────────────────────────────────────────────────
    table.cell(panel, 0, 3, "Phase", 
         text_color=color.white, text_size=size.normal, bgcolor=color.new(#111111, 0))
    table.cell(panel, 1, 3, "🔒  Upgrade to Basic", 
         text_color=color.new(#FF8C00, 0), text_size=size.normal, bgcolor=color.new(#111111, 0))

    // ── Signal — locked ─────────────────────────────────────────────────────
    table.cell(panel, 0, 4, "Signal", 
         text_color=color.white, text_size=size.normal, bgcolor=color.new(#1a1a1a, 0))
    table.cell(panel, 1, 4, "🔒  Upgrade to Basic", 
         text_color=color.new(#FF8C00, 0), text_size=size.normal, bgcolor=color.new(#1a1a1a, 0))

    // ── TP Levels — locked ──────────────────────────────────────────────────
    table.cell(panel, 0, 5, "TP Levels", 
         text_color=color.white, text_size=size.normal, bgcolor=color.new(#111111, 0))
    table.cell(panel, 1, 5, "🔒  Upgrade to Basic", 
         text_color=color.new(#FF8C00, 0), text_size=size.normal, bgcolor=color.new(#111111, 0))

    // ── Next Milestone — locked ─────────────────────────────────────────────
    table.cell(panel, 0, 6, "Next Milestone", 
         text_color=color.white, text_size=size.normal, bgcolor=color.new(#1a1a1a, 0))
    table.cell(panel, 1, 6, "🔒  Upgrade to Pro", 
         text_color=color.new(#FF4444, 0), text_size=size.normal, bgcolor=color.new(#1a1a1a, 0))

    // ── MTF Confluence — locked ─────────────────────────────────────────────
    table.cell(panel, 0, 7, "MTF Confluence", 
         text_color=color.white, text_size=size.normal, bgcolor=color.new(#111111, 0))
    table.cell(panel, 1, 7, "🔒  Upgrade to Pro", 
         text_color=color.new(#FF4444, 0), text_size=size.normal, bgcolor=color.new(#111111, 0))

    // ── Alerts — locked ─────────────────────────────────────────────────────
    table.cell(panel, 0, 8, "Alerts (12 types)", 
         text_color=color.white, text_size=size.normal, bgcolor=color.new(#1a1a1a, 0))
    table.cell(panel, 1, 8, "🔒  Upgrade to Pro", 
         text_color=color.new(#FF4444, 0), text_size=size.normal, bgcolor=color.new(#1a1a1a, 0))

    // ── CTA footer ──────────────────────────────────────────────────────────
    table.cell(panel, 0, 9, "DM @gannedge2009 on X to upgrade", 
         text_color=color.new(#FFD700, 0), text_size=size.normal, 
         bgcolor=color.new(#0a0a0a, 0), text_halign=text.align_center)
    table.cell(panel, 1, 9, "", bgcolor=color.new(#0a0a0a, 0))
    table.merge_cells(panel, 0, 9, 1, 9)

// ===============================================================================
// WATERMARK LABEL — persistent bottom of chart
// ===============================================================================

var label wmLbl = na
if barstate.islast and showWatermark
    label.delete(wmLbl)
    wmLbl := label.new(
         x         = bar_index,
         y         = low * 0.985,
         text      = "GannEdge Pro  |  @gannedge2009  |  Upgrade for Full Cycle Intelligence  |  GREEN = Bullish  |  RED = Bearish  |  YELLOW = Reversal",
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         color     = color.new(#000000, 20),
         textcolor = color.new(#FFFFFF, 5),
         size      = size.normal,
         style     = label.style_label_left)
````
