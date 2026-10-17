# edgeful - candle gaps

- url: https://www.tradingview.com/script/IQq2Sj88-edgeful-candle-gaps/
- type: indicator
- pine_id: PUB;2162bb1c9f8c4a7f872903127e4104f1
- version: 1.0

## Description

edgeful – candle gaps

Detects and visualizes price gaps between consecutive candles. A "candle gap" is the empty space between one candle's close and the next candle's open — a hidden imbalance that often acts as a magnet for future price action. This script finds those gaps automatically and tracks each one until it gets filled.
What counts as a gap?
The script flags a gap only when both candles are the same color and the next candle opens beyond the prior candle's close:

Bullish gap — two green candles in a row, where candle 2 opens above candle 1's close. Zone runs from the prior close up to the current open.
Bearish gap — two red candles in a row, where candle 2 opens below candle 1's close. Zone runs from the current open up to the prior close.

Requiring same-color candles filters out indecision-driven micro-gaps and isolates the directional, momentum-driven imbalances that tend to matter most.
What is "mitigation"?
A gap zone is mitigated (filled) when price comes back and fully consumes it:

Bullish gap → price drops through and below the bottom of the zone
Bearish gap → price rallies through and above the top of the zone

You choose the strictness:

Close mode (default) — the candle has to close through the far side of the zone
Wick mode — any wick touch through the far side counts

Features

Session filter: Daily (all bars), New York, London, or Asia — restrict gap detection to the window you care about
Min gap size filter (% of price) — ignore noise
Configurable look-back window (default 10 days) — old gaps auto-clear
Optional midpoint line at the 50% level of each zone (a common partial-fill target)
Optional toggle to keep mitigated gaps on the chart in a faded color, so you can see where prior fills happened
Four built-in alerts: bullish gap detected, bearish gap detected, bullish gap filled, bearish gap filled
Fully customizable colors and zone extension length

How traders use it

Magnets / targets — unfilled gaps frequently get revisited; use them as profit-taking levels
Support / resistance — the gap zone itself often reacts to price on the first retest
Trend bias — a chart full of unfilled bullish gaps below price suggests momentum is intact (and vice versa)
Mean-reversion entries — fade extended moves back toward the nearest unfilled gap
Session studies — combine with the session filter to study, for example, only gaps that form during the NY open

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © edgeful
// ============================================================================
// Name:        edgeful - candle gaps
// Author:      edgeful
// Version:     1.6
// Created:     2026-04-23
// Updated:     2026-04-27
// Description: Detects and visualizes price gaps between consecutive candles
//              with colored zone boxes, optional midpoint lines, and session
//              filtering.
// Type:        indicator
// Instrument:  Any
// Timeframe:   Any
// Session:     NY | London | Asia | Daily
// Tags:        gap, candle gap, imbalance, session, mitigation
//
// ============================================================================

//@version=6
indicator("edgeful - candle gaps", overlay=true,
  max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// ─── UDT ────────────────────────────────────────────────────────────────────
type candle_gap
    float top
    float bot
    bool  isbull
    int   bar_time
    bool  mitigated

// ─── INPUTS ─────────────────────────────────────────────────────────────────

// --- Session Settings ---
grpSession    = "Session Settings"
i_tz          = input.string("America/New_York", "Timezone", group=grpSession,
  tooltip="Timezone for session filter. Use IANA format (e.g. 'America/New_York').")
i_sessionType = input.string("Daily", "Session Filter",
  options=["Daily", "New York", "London", "Asia"], group=grpSession,
  tooltip="Daily = all bars (no filter). Named sessions restrict gap detection to that window. On daily+ charts, named sessions have no effect -- use Daily.")
i_nyTime      = input.session("0930-1600", "New York Session", group=grpSession)
i_londonTime  = input.session("0300-1100", "London Session", group=grpSession)
i_asiaTime    = input.session("1900-0400", "Asia Session", group=grpSession)

// --- Core Settings ---
grpCore       = "Core Settings"
i_mitType     = input.string("Close", "Mitigation By",
  options=["Close", "Wick"], group=grpCore,
  tooltip="Close: candle close must fill through zone. Wick: any wick touch counts.")
i_minGapPct   = input.float(0.0, "Min Gap Size %", minval=0.0, maxval=20.0, step=0.01,
  group=grpCore,
  tooltip="Minimum gap size as % of price. 0 = detect all gaps.")
i_maxDaysBack = input.int(10, "Maximum Days Back", minval=1, maxval=90, group=grpCore,
  tooltip="Remove gap zones older than this many days.")
i_extendBars  = input.int(20, "Extend Boxes (bars)", minval=1, maxval=500, group=grpCore,
  tooltip="How many bars to extend gap zone boxes to the right from the gap bar.")
i_showMid     = input.bool(true, "Show Midpoint Line", group=grpCore,
  tooltip="Draw a dashed line at the 50% level of each gap zone.")
i_showMitigated = input.bool(false, "Show Mitigated Gaps", group=grpCore,
  tooltip="Keep filled gaps on the chart with a faded color instead of removing them. Mitigated gaps freeze at the bar where they were filled.")

// --- Visual Settings ---
grpVisual     = "Visual Settings"
i_bullColor   = input.color(color.new(#089981, 70), "Bullish Gap", group=grpVisual, inline="colors")
i_bearColor   = input.color(color.new(#F23645, 70), "Bearish Gap", group=grpVisual, inline="colors")
i_bullMitColor = input.color(color.new(#2962FF, 70), "Bullish Mitigated", group=grpVisual, inline="mit")
i_bearMitColor = input.color(color.new(#FFEB3B, 70), "Bearish Mitigated", group=grpVisual, inline="mit")
i_midColor    = input.color(color.new(#878b94, 50), "Midpoint Line", group=grpVisual)
i_showBorder  = input.bool(false, "Show Box Border", group=grpVisual,
  tooltip="Draw a visible border around gap zone boxes.")

// ─── SESSION FILTER ─────────────────────────────────────────────────────────
InSession(string sessionStr, string tz) =>
    not na(time(timeframe.period, sessionStr, tz))

selectedSession = switch i_sessionType
    "New York" => i_nyTime
    "London"   => i_londonTime
    "Asia"     => i_asiaTime
    => "0000-0000"

inSession = (i_sessionType == "Daily" ?
  true :
  InSession(selectedSession, i_tz) and timeframe.isintraday)

// ─── ARRAYS ─────────────────────────────────────────────────────────────────
var gap_records = array.new<candle_gap>(0)
var gap_boxes   = array.new<box>(0)
var gap_lines   = array.new<line>(0)

// ─── TIME CALCULATIONS ──────────────────────────────────────────────────────
int tfMs       = math.round(timeframe.in_seconds() * 1000)
int extendMs   = i_extendBars * tfMs
int msPerDay   = 24 * 60 * 60 * 1000
int cutoffTime = time - i_maxDaysBack * msPerDay

// ─── GAP DETECTION ──────────────────────────────────────────────────────────
bool prevGreen = close[1] > open[1]
bool currGreen = close > open
bool prevRed   = close[1] < open[1]
bool currRed   = close < open

bool isBullGap = open > close[1] and prevGreen and currGreen
bool isBearGap = open < close[1] and prevRed and currRed

float gapSize = math.abs(open - close[1])
float gapPct  = close[1] != 0 ? gapSize / close[1] * 100 : 0.0
bool  sizeOK  = i_minGapPct == 0.0 or gapPct >= i_minGapPct

color borderBull = i_showBorder ? i_bullColor : na
color borderBear = i_showBorder ? i_bearColor : na

if isBullGap and sizeOK and inSession and barstate.isconfirmed
    float gTop = open
    float gBot = close[1]
    gap_records.unshift(candle_gap.new(gTop, gBot, true, time, false))
    gap_boxes.unshift(box.new(time, gTop, time + tfMs, gBot, xloc=xloc.bar_time, border_color=borderBull, bgcolor=i_bullColor))
    if i_showMid
        gap_lines.unshift(line.new(time, (gTop + gBot) / 2, time + tfMs, (gTop + gBot) / 2, xloc=xloc.bar_time, color=i_midColor, style=line.style_dashed, width=1))
    else
        gap_lines.unshift(na)

if isBearGap and sizeOK and inSession and barstate.isconfirmed
    float gTop = close[1]
    float gBot = open
    gap_records.unshift(candle_gap.new(gTop, gBot, false, time, false))
    gap_boxes.unshift(box.new(time, gTop, time + tfMs, gBot, xloc=xloc.bar_time, border_color=borderBear, bgcolor=i_bearColor))
    if i_showMid
        gap_lines.unshift(line.new(time, (gTop + gBot) / 2, time + tfMs, (gTop + gBot) / 2, xloc=xloc.bar_time, color=i_midColor, style=line.style_dashed, width=1))
    else
        gap_lines.unshift(na)

// ─── MITIGATION & CLEANUP LOOP ─────────────────────────────────────────────
var bool bullFilled = false
var bool bearFilled = false
bullFilled := false
bearFilled := false

if gap_records.size() > 0
    for i = gap_records.size() - 1 to 0
        candle_gap g = gap_records.get(i)
        bool mitigated = false

        if not g.mitigated
            if g.isbull
                float mitSrc = i_mitType == "Close" ? close : low
                mitigated := mitSrc < g.bot
            else
                float mitSrc = i_mitType == "Close" ? close : high
                mitigated := mitSrc > g.top

        bool tooOld = g.bar_time < cutoffTime

        if tooOld
            box b = gap_boxes.get(i)
            if not na(b)
                b.delete()
            gap_boxes.remove(i)

            line l = gap_lines.get(i)
            if not na(l)
                l.delete()
            gap_lines.remove(i)

            gap_records.remove(i)

        else if mitigated
            if g.isbull
                bullFilled := true
            else
                bearFilled := true

            if i_showMitigated
                // Freeze at mitigation bar, swap to mitigated color, drop midline
                g.mitigated := true
                gap_records.set(i, g)

                box b = gap_boxes.get(i)
                if not na(b)
                    b.set_right(time + tfMs)
                    b.set_bgcolor(g.isbull ? i_bullMitColor : i_bearMitColor)
                    if i_showBorder
                        b.set_border_color(g.isbull ? i_bullMitColor : i_bearMitColor)

                line l = gap_lines.get(i)
                if not na(l)
                    l.delete()
                    gap_lines.set(i, na)
            else
                box b = gap_boxes.get(i)
                if not na(b)
                    b.delete()
                gap_boxes.remove(i)

                line l = gap_lines.get(i)
                if not na(l)
                    l.delete()
                gap_lines.remove(i)

                gap_records.remove(i)

        else if not g.mitigated
            if inSession
                int maxRight = g.bar_time + extendMs
                int newRight = math.min(time + tfMs, maxRight)
                box b = gap_boxes.get(i)
                if not na(b)
                    b.set_right(newRight)
                line l = gap_lines.get(i)
                if not na(l)
                    l.set_x2(newRight)

// ─── ALERTS ─────────────────────────────────────────────────────────────────
alertcondition(isBullGap and sizeOK and inSession and barstate.isconfirmed, "Bullish Candle Gap",
  "Bullish candle gap detected on {{ticker}} {{interval}}")
alertcondition(isBearGap and sizeOK and inSession and barstate.isconfirmed, "Bearish Candle Gap",
  "Bearish candle gap detected on {{ticker}} {{interval}}")
alertcondition(bullFilled, "Bullish Gap Filled",
  "Bullish candle gap filled on {{ticker}} {{interval}}")
alertcondition(bearFilled, "Bearish Gap Filled",
  "Bearish candle gap filled on {{ticker}} {{interval}}")

// [EXTENSION] Add gap zone labels showing price range
// [EXTENSION] Add dashboard table showing gap statistics
// [EXTENSION] Add HTF gap detection via request.security()
````
