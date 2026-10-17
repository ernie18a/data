# Reyna_ Cosmic_ Timing

- url: https://www.tradingview.com/script/ln4Kudbt-Reyna-Cosmic-Timing/
- type: indicator
- pine_id: PUB;82ca67c2164f4d078298b9254a66adb8
- version: 1.0

## Description

🌙 COSMIC TIMING — MOON PHASES + TRADING SESSIONS

A minimalist overlay tool that weaves lunar rhythm with global 
trading session context. Built for traders who honor cycles as 
much as they honor charts.

═══════════════════════════════════════════════════════════

WHY THIS EXISTS

Markets are made by humans. Humans move in cycles. The lunar 
cycle — 29.53 days from New Moon to New Moon — is one of the 
oldest rhythms humans have tracked. Anecdotally and 
statistically, Full Moons often correlate with local market 
tops and reversals, while New Moons often correlate with 
accumulation windows and quiet ranges.

Whether you view this as astronomy, archetype, or emergent 
behavioral pattern, the correlation is real enough to be 
worth marking on a chart.

This tool does not claim to predict price. It marks the 
cosmic-temporal context that most traders overlook, giving 
you a timing lens alongside your existing technical setup.

═══════════════════════════════════════════════════════════

WHAT IT DRAWS

MOON PHASES (all four major)
🌑 New Moon      — silver dashed vertical line + optional 
                   silver background tint
🌓 First Quarter — purple dotted vertical line
🌕 Full Moon     — gold dashed vertical line + optional 
                   gold background tint
🌗 Last Quarter  — orange dotted vertical line

Each phase is auto-detected using astronomical calculation 
based on the synodic month (29.530588 days) anchored to a 
verified reference new moon on April 17, 2026 at 00:52 UTC. 
This gives accuracy within approximately one hour across 
multiple years in either direction.

Only the first bar of each phase transition is marked — 
not every bar within a phase window — keeping the chart 
clean and readable.

TRADING SESSIONS (background tints, UTC-based)
🟣 Asia   — 00:00–06:00 UTC (soft violet)
🟡 London — 07:00–10:00 UTC (soft gold)
🔵 NY     — 13:30–16:00 UTC (soft cyan)

These are the three highest-volume windows in the global 
trading day. Each has distinct volatility character — Asia 
tends toward range accumulation, London opens the first 
volatility wave, and NY overlap with London (13:30–16:00 
UTC) produces the highest-probability trend windows.

═══════════════════════════════════════════════════════════

HOW IT DIFFERS

Unlike most moon-phase indicators, this tool:

- Uses astronomical anchoring (verified NM reference point) 
  rather than simple modular arithmetic, giving multi-year 
  accuracy
- Detects only the FIRST bar of each phase transition, 
  preventing repeated markers within the same phase window
- Includes trading session context alongside moon phases — 
  most cosmic indicators show one or the other, this shows 
  both timing layers together
- Has toggleable background glow specifically for New Moon 
  and Full Moon bars, letting the two most impactful phases 
  breathe visually
- Ships with alert conditions on every phase transition — 
  no more manually checking the astronomical calendar

═══════════════════════════════════════════════════════════

HOW TO USE IT

This is a CONTEXT tool, not a signal tool. It works best when 
layered on top of your existing technical analysis (structure, 
liquidity, order blocks, momentum).

Suggested reading:
- At New Moon → watch for accumulation setups, potential 
  reversal bottoms
- At First Quarter → tension, breakout attempts, decisions
- At Full Moon → watch for exhaustion tops, potential 
  reversal peaks
- At Last Quarter → release, correction, integration phase

For session context:
- Asia session is often range-bound — accumulation setups
- London open often triggers the day's first liquidity hunt
- NY session drives the highest-conviction trend moves
- London + NY overlap (13:30–16:00 UTC) is the highest-
  volatility window

═══════════════════════════════════════════════════════════

ALERTS INCLUDED

🌑 New Moon transition
🌓 First Quarter transition
🌕 Full Moon transition
🌗 Last Quarter transition

Set these as "Once Per Bar Close" for confirmed timing.

═══════════════════════════════════════════════════════════

Pattern over proof. Simplicity over jargon. 
Empowerment over fear.

For educational purposes only. Not financial advice.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════
//   🌙 REYNA COSMIC TIMING
//   Moon Phases + Trading Sessions
//   
//   A minimalist tool weaving lunar rhythm with market timing.
//   The four major moon phases (New, First Quarter, Full, Last Quarter)
//   drawn as vertical lines through price action, alongside the three
//   major global trading sessions (Asia, London, New York).
//
//   No signals. No noise. Just the timing map.
//
//   Pattern over proof. Simplicity over jargon. 
//   Empowerment over fear. 🌙
// ═══════════════════════════════════════════════════════════════════

indicator("🌙 Reyna Cosmic Timing", 
     overlay = true, 
     max_labels_count = 200, 
     max_lines_count = 100)

// ═══════════════════════════════════════════════════════════════════
//                        🎛️ INPUTS
// ═══════════════════════════════════════════════════════════════════

grpMoon = "🌙 Moon Phases"
showMoon     = input.bool(true, "Show Moon Phase Lines & Labels", group = grpMoon)
showMoonGlow = input.bool(true, "Show NM/FM Background Glow",     group = grpMoon, tooltip = "Subtle silver/gold tint on New Moon and Full Moon bars")

grpSession = "🌍 Trading Sessions (UTC)"
showAsia    = input.bool(true, "Asia (00:00-06:00)",     group = grpSession)
showLondon  = input.bool(true, "London (07:00-10:00)",   group = grpSession)
showNY      = input.bool(true, "New York (13:30-16:00)", group = grpSession)

// ═══════════════════════════════════════════════════════════════════
//                        🎨 COLORS
// ═══════════════════════════════════════════════════════════════════

colAsia   = color.new(#9D4EDD, 94)   // Violet
colLondon = color.new(#FFD700, 94)   // Gold
colNY     = color.new(#00B4D8, 94)   // Cyan

// ═══════════════════════════════════════════════════════════════════
//                    🌙 MOON PHASES (anchored 2026-04-17 NM)
// ═══════════════════════════════════════════════════════════════════

moonPhase() =>
    refTime         = timestamp("2026-04-17 00:52:00")
    secondsSinceRef = (time - refTime) / 1000
    daysSinceRef    = secondsSinceRef / 86400.0
    synodic         = 29.530588
    rawPhase        = daysSinceRef / synodic
    phase           = rawPhase - math.floor(rawPhase)
    phase

phaseNow  = moonPhase()
phasePrev = moonPhase()[1]

isNewMoon  = false
isFirstQtr = false
isFullMoon = false
isLastQtr  = false

if not na(phasePrev)
    if phasePrev > 0.95 and phaseNow < 0.05
        isNewMoon := true
    if phasePrev < 0.25 and phaseNow >= 0.25
        isFirstQtr := true
    if phasePrev < 0.50 and phaseNow >= 0.50
        isFullMoon := true
    if phasePrev < 0.75 and phaseNow >= 0.75
        isLastQtr := true

// ═══════════════════════════════════════════════════════════════════
//                    🌍 SESSION BACKGROUNDS
// ═══════════════════════════════════════════════════════════════════

inAsia   = not na(time(timeframe.period, "0000-0600", "UTC"))
inLondon = not na(time(timeframe.period, "0700-1000", "UTC"))
inNY     = not na(time(timeframe.period, "1330-1600", "UTC"))

color asiaBg   = na
color londonBg = na
color nyBg     = na

if showAsia and inAsia
    asiaBg := colAsia
if showLondon and inLondon
    londonBg := colLondon
if showNY and inNY
    nyBg := colNY

bgcolor(asiaBg,   title = "Asia Session")
bgcolor(londonBg, title = "London Session")
bgcolor(nyBg,     title = "NY Session")

// ═══════════════════════════════════════════════════════════════════
//                    🌑🌓🌕🌗 MOON LINES & LABELS
// ═══════════════════════════════════════════════════════════════════

if showMoon and isNewMoon and not isNewMoon[1]
    line.new(bar_index, high * 1.02, bar_index, low * 0.98,
         color = color.new(color.silver, 0), width = 2, style = line.style_dashed)
    label.new(bar_index, high * 1.03,
         text = "🌑 NM", color = color.new(color.black, 100),
         textcolor = color.silver, style = label.style_label_down, size = size.small)

if showMoon and isFullMoon and not isFullMoon[1]
    line.new(bar_index, high * 1.02, bar_index, low * 0.98,
         color = color.new(color.yellow, 0), width = 2, style = line.style_dashed)
    label.new(bar_index, high * 1.03,
         text = "🌕 FM", color = color.new(color.black, 100),
         textcolor = color.yellow, style = label.style_label_down, size = size.small)

if showMoon and isFirstQtr and not isFirstQtr[1]
    line.new(bar_index, high * 1.02, bar_index, low * 0.98,
         color = color.new(color.purple, 40), width = 1, style = line.style_dotted)
    label.new(bar_index, high * 1.03,
         text = "🌓 1Q", color = color.new(color.black, 100),
         textcolor = color.purple, style = label.style_label_down, size = size.tiny)

if showMoon and isLastQtr and not isLastQtr[1]
    line.new(bar_index, high * 1.02, bar_index, low * 0.98,
         color = color.new(color.orange, 40), width = 1, style = line.style_dotted)
    label.new(bar_index, high * 1.03,
         text = "🌗 LQ", color = color.new(color.black, 100),
         textcolor = color.orange, style = label.style_label_down, size = size.tiny)

// Moon glow
color nmGlow = na
color fmGlow = na
if showMoonGlow and isNewMoon
    nmGlow := color.new(color.silver, 94)
if showMoonGlow and isFullMoon
    fmGlow := color.new(color.yellow, 94)
bgcolor(nmGlow, title = "New Moon Glow")
bgcolor(fmGlow, title = "Full Moon Glow")

// ═══════════════════════════════════════════════════════════════════
//                    🔔 ALERTS
// ═══════════════════════════════════════════════════════════════════

alertcondition(isNewMoon,   title = "🌑 New Moon",     message = "🌑 New Moon transition — cosmic seeds planted")
alertcondition(isFullMoon,  title = "🌕 Full Moon",    message = "🌕 Full Moon transition — peak lunar energy")
alertcondition(isFirstQtr,  title = "🌓 First Quarter", message = "🌓 First Quarter transition — tension building")
alertcondition(isLastQtr,   title = "🌗 Last Quarter",  message = "🌗 Last Quarter transition — release phase")
````
