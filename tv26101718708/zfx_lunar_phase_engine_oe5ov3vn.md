# Zfx Lunar Phase Engine

- url: https://www.tradingview.com/script/Oe5oV3vN-Zfx-Lunar-Phase-Engine/
- type: indicator
- pine_id: PUB;9256f6a2fac647ceb9c2b3b4089788f1
- version: 1.0

## Description

Zfx — Lunar Phase Engine

This indicator maps the synodic lunar cycle directly onto your price chart using precise astronomical timing. The lunar wave is calculated from a verified new moon epoch and plotted as a smooth sine oscillator on the left scale, allowing you to overlay the natural 29.5-day moon cycle against any market on any timeframe — without cluttering your price action.

What it does:
- Computes real-time lunar phase (0 = New Moon → 0.5 = Full Moon → 1 = back to New Moon) using the synodic month constant (2,551,442 seconds)
- Plots the wave on the left scale directly over price — candles remain fully readable
- Marks all four lunar phases with vertical lines and emoji anchors: 🌑 New Moon (cyan), 🌓 First Quarter, 🌕 Full Moon (gold), 🌗 Third Quarter
- Projects the next 3 upcoming phase events forward in time as dashed future lines
- Displays a live data table: current illumination % and days until the next New/Full Moon
- Optional waxing/waning background shading

Why it matters:
Lunar cycles have been studied in relation to market sentiment, liquidity windows, and turning points across commodities, indices, and crypto. This tool makes it effortless to visually correlate price behaviour with the moon's phase without any manual calculation.

Settings:
- Toggle quarter moon markers on/off
- Toggle background shading on/off
- Toggle the data table on/off
- All alert conditions included for all 4 phase transitions

Built for clean, uncluttered overlay use on any symbol and any timeframe.

---

That framing is distinct enough — it emphasises the astronomical calculation, the overlay approach, the left-scale design, and the forward projection, which differentiates it from generic lunar scripts.

## Source Code

````pine
// © Zfx1471
//@version=6
indicator("Zfx — Lunar Phase Engine", overlay=true, scale=scale.left, max_lines_count=500, max_labels_count=200)

grp_vis = "Visual Settings"
showQuarterMoons = input.bool(true,  "Show Quarter Moon Markers",     group=grp_vis)
showBgShading    = input.bool(false, "Show Waxing/Waning Background", group=grp_vis)
showTable        = input.bool(true,  "Show Lunar Data Table",         group=grp_vis)

float SYNODIC_MONTH  = 2551442841.6
float KNOWN_NEW_MOON = 1704974220000.0

float phase = ((time - KNOWN_NEW_MOON) % SYNODIC_MONTH) / SYNODIC_MONTH
phase := phase < 0 ? phase + 1 : phase

float lunarWave = math.sin((phase - 0.25) * 2 * math.pi)

bool isWaxing = phase < 0.5
bgcolor(showBgShading ? (isWaxing ? color.new(color.aqua, 95) : color.new(#0a192f, 90)) : na, title="Phase Background")

plot(lunarWave, color=color.new(color.gray, 80),   linewidth=4, title="Glow Outer")
plot(lunarWave, color=color.new(color.silver, 60), linewidth=2, title="Glow Inner")
plot(lunarWave, color=color.new(color.white, 0),   linewidth=1, title="Lunar Wave Core")
plot(0.0,       color=color.new(color.gray, 60),   linewidth=1, title="Zero Line")

bool fullMoonTrigger     = phase >= 0.5  and phase[1] < 0.5
bool newMoonTrigger      = phase < 0.1   and phase[1] > 0.9
bool firstQuarterTrigger = phase >= 0.25 and phase[1] < 0.25
bool thirdQuarterTrigger = phase >= 0.75 and phase[1] < 0.75

if fullMoonTrigger
    line.new(time, -1.2, time, 1.2, xloc=xloc.bar_time, color=color.new(#FFD700, 20), width=2)
    label.new(time, 1.2, "🌕", xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=color.new(#FFD700, 0), style=label.style_label_down, size=size.small)

if newMoonTrigger
    line.new(time, -1.2, time, 1.2, xloc=xloc.bar_time, color=color.new(color.aqua, 20), width=2)
    label.new(time, -1.2, "🌑", xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=color.aqua, style=label.style_label_up, size=size.small)

if firstQuarterTrigger and showQuarterMoons
    line.new(time, -1.2, time, 1.2, xloc=xloc.bar_time, color=color.new(color.gray, 40), width=1, style=line.style_dashed)
    label.new(time, 1.2, "🌓", xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=color.gray, style=label.style_label_down, size=size.small)

if thirdQuarterTrigger and showQuarterMoons
    line.new(time, -1.2, time, 1.2, xloc=xloc.bar_time, color=color.new(color.gray, 40), width=1, style=line.style_dashed)
    label.new(time, -1.2, "🌗", xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=color.gray, style=label.style_label_up, size=size.small)

if barstate.islast
    for i = 0 to 2
        float  target_fraction = (math.floor(phase * 4) + 1 + i) / 4
        int    target_time     = int(time + (target_fraction - phase) * SYNODIC_MONTH)
        int    phase_idx       = int(math.floor(phase * 4) + 1 + i) % 4
        bool   drawFuture      = true
        if (phase_idx == 1 or phase_idx == 3) and not showQuarterMoons
            drawFuture := false
        if drawFuture
            color  lineColor = (phase_idx == 0 ? color.new(color.aqua, 70) :
                                phase_idx == 2 ? color.new(#FFD700, 70) :
                                                 color.new(color.gray, 70))
            string labelStr  = phase_idx == 0 ? "🌑" : phase_idx == 1 ? "🌓" : phase_idx == 2 ? "🌕" : "🌗"
            int    lineWidth = (phase_idx == 0 or phase_idx == 2) ? 2 : 1
            float  yPos      = (phase_idx == 0 or phase_idx == 3) ? -1.2 : 1.2
            line.new(target_time, -1.2, target_time, 1.2, xloc=xloc.bar_time,
                     color=lineColor, width=lineWidth,
                     style=(phase_idx == 0 or phase_idx == 2) ? line.style_solid : line.style_dashed)
            label.new(target_time, yPos, labelStr, xloc=xloc.bar_time,
                      color=color.new(color.black, 100), textcolor=lineColor, size=size.small,
                      style=(phase_idx == 0 or phase_idx == 3) ? label.style_label_up : label.style_label_down)

var table moonTable = table.new(position.bottom_right, 2, 2,
     bgcolor=color.new(#0a192f, 80), frame_color=color.gray, frame_width=1,
     border_color=color.gray, border_width=1)

if barstate.islast and showTable
    float  illumPct   = phase <= 0.5 ? phase * 200 : (1.0 - phase) * 200
    string nextName   = phase < 0.5 ? "Full Moon" : "New Moon"
    float  daysToNext = (phase < 0.5 ? (0.5 - phase) * SYNODIC_MONTH / 86400000.0 :
                                       (1.0 - phase) * SYNODIC_MONTH / 86400000.0)
    table.cell(moonTable, 0, 0, "Illumination:",          text_color=color.gray,  text_size=size.small)
    table.cell(moonTable, 1, 0, str.tostring(illumPct, "#.##") + "%", text_color=color.white, text_size=size.small)
    table.cell(moonTable, 0, 1, "Next " + nextName + ":", text_color=color.gray,  text_size=size.small)
    table.cell(moonTable, 1, 1, str.tostring(daysToNext, "#.##") + " Days",
               text_color=phase < 0.5 ? color.new(#FFD700, 0) : color.aqua, text_size=size.small)

alertcondition(newMoonTrigger,      "New Moon Alert",      "New Moon Phase Reached!")
alertcondition(fullMoonTrigger,     "Full Moon Alert",     "Full Moon Phase Reached!")
alertcondition(firstQuarterTrigger, "First Quarter Alert", "First Quarter (Waxing) Reached!")
alertcondition(thirdQuarterTrigger, "Third Quarter Alert", "Third Quarter (Waning) Reached!")
````
