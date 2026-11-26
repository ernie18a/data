# Pump-and-Dump / Volatility Spike Flag

- url: https://www.tradingview.com/script/ZEuYW0qC-Pump-and-Dump-Volatility-Spike-Flag/
- type: indicator
- pine_id: PUB;94271f5310aa48b58103a3295d164d98
- version: 1.0

## Description

Pump-and-Dump / Volatility Spike Flag flags abnormal single-candle volatility — not the manipulation scheme, but the classic sharp-spike-then-reverse price shape that shows up around news events (frequently seen on MCX crude oil and silver).

HOW IT WORKS
A candle is flagged only when two conditions occur together: its true range (which includes gap-opens) expands well beyond its rolling ATR, AND its volume expands well beyond its rolling average. Flagged spikes are tracked for a short window afterward — if price closes back through that candle's open before the window expires, it is separately flagged as a "Fade," indicating the initial move has started reversing.

HOW TO USE
Use the Spike flag as an early heads-up that a candle is statistically abnormal for current conditions. Use the Fade flag as the more actionable signal — it confirms the spike has already started giving back its move. This is an informational/analytical tool, not a buy or sell signal, and should be combined with your own risk management and market context.

LIMITATIONS
ATR and volume averages are backward-looking, so the first spike after a long quiet period needs a relatively larger move to trigger. This is a single-candle geometry and volume-shape detector — it cannot identify why a move happened (news, order-flow, or otherwise), and it does not predict direction after the fade.

DISCLAIMER
For educational/informational purposes only. Not financial advice. Past performance does not guarantee future results. Trade at your own risk and always use proper risk management.

## Source Code

````pine
// @darshakssc — Radhe Radhe 🙏
// Pump-and-Dump / Volatility Spike Flag
// Author: Darshak Adhyaru (@darshakssc)
// License: Mozilla Public License 2.0 — https://mozilla.org/MPL/2.0/
//
// ============================================================================
// DISCLAIMER: For educational/informational purposes only. Not financial
// advice. Past performance does not guarantee future results. Trade at your
// own risk and always use proper risk management.
// ============================================================================
//
// WHAT THIS DOES
// Flags a single candle as an abnormal volatility spike when its true range
// (which includes gap-opens, common on MCX crude/silver news moves) expands
// well beyond ATR AND its volume expands well beyond its rolling average, at
// the same time. Each flagged spike is also tracked for a short window
// afterward — if price closes back through the spike bar's open, that's
// flagged separately as a "fade," the classic pump-and-dump give-back.
//
// HOW TO USE
// A Pump/Dump flag alone just means "abnormal single-candle expansion" — it
// says nothing about direction persistence. The Fade flag is the more
// actionable one: it means the initial spike has already started giving
// back its move within the tracked window.
//
// LIMITATIONS
// ATR- and volume-based thresholds mean the very first spike after a long
// quiet period needs a slightly larger move to trigger (ATR hasn't caught up
// yet), while spikes during an already-volatile stretch need a relatively
// bigger push to register as "abnormal." This is a single-candle geometry
// flag, not a news or fundamental filter — it cannot tell you why a spike
// happened.
//
//@version=6
indicator(title = "Pump-and-Dump / Volatility Spike Flag [@darshakssc]", shorttitle = "PumpDump", overlay = true)

// ---------------------------------------------------------------------------
// INPUTS
// ---------------------------------------------------------------------------
atrLen           = input.int(14, "ATR Length", minval = 5, group = "Spike Detection")
spikeAtrMult     = input.float(2.5, "Min Range Expansion (x ATR)", minval = 1.0, step = 0.1, group = "Spike Detection")
volLen            = input.int(20, "Volume Avg Length", minval = 5, group = "Spike Detection")
spikeVolMult      = input.float(2.0, "Min Volume Spike (x Avg)", minval = 1.0, step = 0.1, group = "Spike Detection")
useTrueRange      = input.bool(true, "Use True Range (include gaps)", group = "Spike Detection", tooltip = "True Range accounts for gap-opens, common on MCX crude/silver news moves. Turn off to use simple high-low range only.")
cooldownBars      = input.int(3, "Cooldown Between Spike Flags (bars)", minval = 1, group = "Spike Detection")

fadeWithinBars    = input.int(5, "Check for Fade Within (bars)", minval = 1, maxval = 30, group = "Fade Detection")
maxTrackedSpikes = input.int(5, "Max Tracked Spikes", minval = 1, maxval = 15, group = "Fade Detection")

flashBackground   = input.bool(true, "Flash Background on Spike Bar", group = "Visuals")
showTable          = input.bool(true, "Show Dashboard Table", group = "Visuals")
dashPosInput       = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"], group = "Visuals")

// ---------------------------------------------------------------------------
// COLORS (dark theme, high contrast)
// ---------------------------------------------------------------------------
colPump    = #76ff03
colDump    = #ff1744
colFade    = #ffab00
colNeutral = #9aa4b2
colGold    = #ffd54f
colBg      = color.new(#151a2e, 0)
colBgAlt   = color.new(#1c2238, 0)
colHeader  = color.new(#2b2d42, 0)

dashPos = switch dashPosInput
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    "Middle Right" => position.middle_right
    "Middle Left"  => position.middle_left
    => position.top_right

// ---------------------------------------------------------------------------
// GLOBAL-SCOPE INDICATORS
// ---------------------------------------------------------------------------
atrVal        = ta.atr(atrLen)
trueRangeVal = ta.tr(true)
plainRange    = high - low
rangeUsed     = useTrueRange ? trueRangeVal : plainRange
volAvg        = ta.sma(volume, volLen)

rangeMult = atrVal != 0.0 ? rangeUsed / atrVal : 0.0
volMult    = volAvg != 0.0 ? volume / volAvg : 0.0

// ---------------------------------------------------------------------------
// SPIKE DETECTION (confirmed bars only — non-repainting, cooldown gated)
// ---------------------------------------------------------------------------
var int lastSpikeBar = na
cooldownOK = na(lastSpikeBar) or (bar_index - lastSpikeBar) >= cooldownBars

isSpikeRaw = barstate.isconfirmed and rangeMult >= spikeAtrMult and volMult >= spikeVolMult
isSpike     = isSpikeRaw and cooldownOK

if isSpike
    lastSpikeBar := bar_index

pumpSpike = isSpike and close > open
dumpSpike = isSpike and close < open

// ---------------------------------------------------------------------------
// SESSION SPIKE COUNT (resets each session)
// ---------------------------------------------------------------------------
var int spikesToday = 0
if timeframe.change("D")
    spikesToday := 0
if isSpike
    spikesToday := spikesToday + 1

// ---------------------------------------------------------------------------
// FADE TRACKING (FIFO, capped at `maxTrackedSpikes`)
// ---------------------------------------------------------------------------
var array<int>   spikeBarArr    = array.new<int>()
var array<float> spikeOpenArr   = array.new<float>()
var array<bool>  spikeIsPumpArr = array.new<bool>()

if isSpike
    array.push(spikeBarArr, bar_index)
    array.push(spikeOpenArr, open)
    array.push(spikeIsPumpArr, close > open)
    if array.size(spikeBarArr) > maxTrackedSpikes
        array.shift(spikeBarArr)
        array.shift(spikeOpenArr)
        array.shift(spikeIsPumpArr)

bool pumpFaded = false
bool dumpFaded = false

if barstate.isconfirmed and array.size(spikeBarArr) > 0
    for i = array.size(spikeBarArr) - 1 to 0
        sBar  = array.get(spikeBarArr, i)
        sOpen = array.get(spikeOpenArr, i)
        sPump = array.get(spikeIsPumpArr, i)
        barsElapsed = bar_index - sBar
        if barsElapsed >= 1
            fadedNow = sPump ? close < sOpen : close > sOpen
            if fadedNow
                if sPump
                    pumpFaded := true
                else
                    dumpFaded := true
                array.remove(spikeBarArr, i)
                array.remove(spikeOpenArr, i)
                array.remove(spikeIsPumpArr, i)
            else if barsElapsed >= fadeWithinBars
                array.remove(spikeBarArr, i)
                array.remove(spikeOpenArr, i)
                array.remove(spikeIsPumpArr, i)

var string lastEventText = "None"
if pumpSpike
    lastEventText := "Pump Spike"
if dumpSpike
    lastEventText := "Dump Spike"
if pumpFaded
    lastEventText := "Pump Faded"
if dumpFaded
    lastEventText := "Dump Faded"

// ---------------------------------------------------------------------------
// PLOTS
// ---------------------------------------------------------------------------
plotshape(pumpSpike, title = "Pump Spike", style = shape.labelup,   location = location.belowbar, color = colPump, size = size.tiny, text = "PUMP", textcolor = color.black)
plotshape(dumpSpike, title = "Dump Spike", style = shape.labeldown, location = location.abovebar, color = colDump, size = size.tiny, text = "DUMP", textcolor = color.white)
plotshape(pumpFaded, title = "Pump Faded", style = shape.xcross, location = location.abovebar, color = colFade, size = size.tiny, text = "fade", textcolor = colFade)
plotshape(dumpFaded, title = "Dump Faded", style = shape.xcross, location = location.belowbar, color = colFade, size = size.tiny, text = "fade", textcolor = colFade)

bgcolor(flashBackground and pumpSpike ? color.new(colPump, 88) : na, title = "Pump Spike Flash")
bgcolor(flashBackground and dumpSpike ? color.new(colDump, 88) : na, title = "Dump Spike Flash")

// ---------------------------------------------------------------------------
// DASHBOARD (movable via input, updates only on latest bar)
// ---------------------------------------------------------------------------
var table dash = table.new(dashPos, 2, 6, border_width = 1, border_color = color.new(colGold, 70), frame_color = colGold, frame_width = 2)

if showTable and barstate.islast
    rangeColor = rangeMult >= spikeAtrMult ? colGold : colNeutral
    volColor    = volMult >= spikeVolMult ? colGold : colNeutral
    eventColor  = lastEventText == "Pump Spike" ? colPump : lastEventText == "Dump Spike" ? colDump : (lastEventText == "Pump Faded" or lastEventText == "Dump Faded") ? colFade : colNeutral

    table.cell(dash, 0, 0, "⚡ Pump/Dump Spike Flag", text_color = colGold, bgcolor = colHeader, text_size = size.normal)
    table.cell(dash, 1, 0, "", bgcolor = colHeader)

    table.cell(dash, 0, 1, "Range vs ATR", text_color = colNeutral, bgcolor = colBg, text_size = size.small)
    table.cell(dash, 1, 1, str.tostring(rangeMult, "#.##") + "x  (need " + str.tostring(spikeAtrMult, "#.#") + "x)", text_color = rangeColor, bgcolor = colBg, text_size = size.small)

    table.cell(dash, 0, 2, "Volume vs Avg", text_color = colNeutral, bgcolor = colBgAlt, text_size = size.small)
    table.cell(dash, 1, 2, str.tostring(volMult, "#.##") + "x  (need " + str.tostring(spikeVolMult, "#.#") + "x)", text_color = volColor, bgcolor = colBgAlt, text_size = size.small)

    table.cell(dash, 0, 3, "Spikes Today", text_color = colNeutral, bgcolor = colBg, text_size = size.small)
    table.cell(dash, 1, 3, str.tostring(spikesToday), text_color = color.white, bgcolor = colBg, text_size = size.small)

    table.cell(dash, 0, 4, "Pending Fades", text_color = colNeutral, bgcolor = colBgAlt, text_size = size.small)
    table.cell(dash, 1, 4, str.tostring(array.size(spikeBarArr)) + " / " + str.tostring(maxTrackedSpikes), text_color = color.white, bgcolor = colBgAlt, text_size = size.small)

    table.cell(dash, 0, 5, "Last Event", text_color = colNeutral, bgcolor = colBg, text_size = size.small)
    table.cell(dash, 1, 5, lastEventText, text_color = eventColor, bgcolor = colBg, text_size = size.small)

// ---------------------------------------------------------------------------
// ALERTS (const string messages only — required for v6 alertcondition)
// ---------------------------------------------------------------------------
alertcondition(pumpSpike, title = "Pump Spike Detected", message = "Pump-and-Dump / Volatility Spike Flag: abnormal up-candle range expansion with volume spike detected.")
alertcondition(dumpSpike, title = "Dump Spike Detected", message = "Pump-and-Dump / Volatility Spike Flag: abnormal down-candle range expansion with volume spike detected.")
alertcondition(pumpFaded, title = "Pump Spike Faded",     message = "Pump-and-Dump / Volatility Spike Flag: a prior pump spike has faded — price closed back through the spike bar's open.")
alertcondition(dumpFaded, title = "Dump Spike Faded",     message = "Pump-and-Dump / Volatility Spike Flag: a prior dump spike has faded — price closed back through the spike bar's open.")
````
