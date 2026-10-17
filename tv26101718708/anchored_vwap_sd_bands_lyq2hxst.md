# Anchored VWAP +/- SD Bands 

- url: https://www.tradingview.com/script/lYQ2HxST-Anchored-VWAP-SD-Bands/
- type: indicator
- pine_id: PUB;a2873b731d8549f5b37232ca8ee79e25
- version: 1.0

## Description

**Anchored VWAP +/− SD Bands** plots the volume-weighted average price from a chosen anchor with ±1, ±2 and ±3 standard-deviation bands, plus a live Z-score readout so you can see *exactly* how stretched price is from session fair value.

## What it does

VWAP is the price every dollar of volume has paid since the anchor — the "fair value" reference for the session. The SD bands wrap that line in statistical confidence intervals: ~68% of bars stay within ±1σ, ~95% within ±2σ, >99% within ±3σ. Touching the bands means price is over-extended relative to where volume agrees the asset should trade.

## Features

**Three anchor modes**
- **Futures (18:00 ET)** — resets daily at the futures session open
- **Daily (00:00 ET)** — resets at midnight ET (use for crypto / 24h symbols)
- **Custom Date/Time** — resets ONCE at any timestamp you pick. Anchor from FOMC, earnings, contract roll, a swing high or low, the post-news candle — anything that matters to your context.

**Z-score panel** — live numeric readout of current σ distance from VWAP, color-coded:
- green inside ±1σ (normal)
- orange ±1σ to ±2σ (stretched)
- red beyond ±2σ (extreme)

Switchable to any of the 4 chart corners.

**±1, ±2, ±3 SD bands** — full statistical range visible at a glance, with the ±2σ channel filled blue.

**Smart warmup** — bands stay hidden for the first N bars after each anchor reset so they don't snap onto VWAP at the open.

**Configurable source** — defaults to `hlc3` (conventional VWAP input), switch to close, ohlc4, etc.

**Optional slope coloring** — color VWAP green when rising, red when falling for at-a-glance trend bias. Off by default (yellow line).

**VWAP value tag** — small label at the right tip of the line showing the current VWAP price.

**5 built-in alerts** — band tags (upper/lower), VWAP reclaim, VWAP lost, anchor reset. All carry the `{{ticker}}` placeholder.

**Works on every timeframe** — uses minute-of-day crossing detection instead of bar-start equality, so the anchor fires correctly on 1m, 4H, 8H, daily — anywhere.

## How to use

**Mean reversion**: fade ±2σ / ±3σ tags back toward VWAP. The Z-score going red flags the setup before you read the chart.

**Trend**: VWAP acts as session support/resistance. The "VWAP reclaim" and "VWAP lost" alerts mark regime shifts intraday.

**Context**: a symbol pinned to +1σ all session is trending strong; one oscillating around 0σ is balanced; one tagging both ±2σ in the same session is volatile or news-driven.

## Settings

All inputs grouped: **Anchor**, **Math**, **Display**. Panel position is swappable between all 4 corners. Every input has a tooltip.

## Notes

- The "Custom Date/Time" anchor only resets once. Use it for event-anchored trades (post-FOMC, swing high, breakout candle).
- On volume-less instruments (some indexes), the indicator falls back to a time-weighted mean so the line still renders.
- Load enough chart history to include your anchor point or the indicator will accumulate from chart-start instead.

## License

Source code is released under the Mozilla Public License 2.0. Fork freely.

## Source Code

````pine
// This Pine Script™ source code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/

//@version=6
// =============================================================================
//  Anchored VWAP +/- SD Bands  -  v0.2
//  Indicator only (no orders)
// =============================================================================
indicator(title      = "Anchored VWAP +/- SD Bands [v0.2]",
          shorttitle = "AVWAP SD",
          overlay    = true,
          max_labels_count = 50)


// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════

string G_ANC = "Anchor"
mode         = input.string("Futures (18:00 ET)", "Anchor Mode",
                  options = ["Futures (18:00 ET)", "Daily (00:00 ET)", "Custom Date/Time"],
                  group   = G_ANC,
                  tooltip = "Futures: resets daily at 18:00 ET. Daily: resets daily at 00:00 ET. Custom: resets ONCE at the date/time below.")
customAnchor = input.time(1735689600000, "Custom Anchor (used when mode = Custom Date/Time)", group = G_ANC, confirm = false)

string G_MATH = "Math"
src        = input.source(hlc3, "Source", group = G_MATH,
                tooltip = "Default hlc3 is the conventional VWAP input. Use close or ohlc4 if you prefer.")
sdMult     = input.float(2.0, "Band Width (SD Multiplier)",
                minval = 0.5, step = 0.1, group = G_MATH)
warmupBars = input.int(5, "Warm-up Bars (hide bands until N samples)",
                minval = 1, maxval = 100, group = G_MATH,
                tooltip = "Bands stay hidden for the first N bars after each anchor reset so they don't snap onto VWAP at the open.")

string G_DSP = "Display"
showPanel  = input.bool(true,  "Show Z-score panel", group = G_DSP,
                tooltip = "Top-corner table with current σ distance from VWAP.")
panelPos   = input.string("Top Right", "Panel Position",
                options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = G_DSP)
showTag    = input.bool(true,  "Show VWAP value tag",  group = G_DSP,
                tooltip = "Small label at the right tip of VWAP showing its current price.")
slopeColor = input.bool(false, "Color VWAP by slope",  group = G_DSP,
                tooltip = "Green when rising, red when falling. Default OFF (yellow).")
showSesBg  = input.bool(true,  "Highlight anchor bar", group = G_DSP)


// ═══════════════════════════════════════════════════════════════
//  ANCHOR LOGIC
//  v0.2 fix: detect minute-of-day CROSSINGS instead of bar-start
//  equality. Works on every TF, not just ones where a bar happens
//  to start at the anchor hour.
// ═══════════════════════════════════════════════════════════════

var string TZ = "America/New_York"

int  bm_now    = hour(time, TZ) * 60 + minute(time, TZ)
int  bm_prev   = nz(hour(time[1], TZ) * 60 + minute(time[1], TZ), bm_now)
bool isCustom  = mode == "Custom Date/Time"
int  anchorMin = mode == "Futures (18:00 ET)" ? 1080 : 0

bool crossRecur = (bm_prev < anchorMin and bm_now >= anchorMin) or
                  (bm_prev >  bm_now    and (anchorMin > bm_prev or anchorMin <= bm_now))
bool crossCustom = not na(time[1]) and time[1] < customAnchor and time >= customAnchor

bool newSess = isCustom ? crossCustom : crossRecur


// ═══════════════════════════════════════════════════════════════
//  ACCUMULATORS
// ═══════════════════════════════════════════════════════════════

var float sumPV  = 0.0
var float sumV   = 0.0
var float sumP2V = 0.0
var int   nBars  = 0

float v = nz(volume, 1)

if newSess or barstate.isfirst
    sumPV  := 0.0
    sumV   := 0.0
    sumP2V := 0.0
    nBars  := 0

bool accumulate = not isCustom or time >= customAnchor

if accumulate
    sumPV  += src * v
    sumV   += v
    sumP2V += src * src * v
    nBars  += 1


// ═══════════════════════════════════════════════════════════════
//  VWAP, SD, Z-SCORE
// ═══════════════════════════════════════════════════════════════

float vwap   = sumV > 0 ? sumPV / sumV : na
float varc   = sumV > 0 ? math.max(sumP2V / sumV - vwap * vwap, 0.0) : 0.0
float sd     = math.sqrt(varc)
float zScore = not na(vwap) and sd > 0 ? (close - vwap) / sd : na

bool ready = nBars >= warmupBars

float up1 = ready ? vwap + sd          : na
float dn1 = ready ? vwap - sd          : na
float up2 = ready ? vwap + sdMult * sd : na
float dn2 = ready ? vwap - sdMult * sd : na
float up3 = ready ? vwap + 3.0    * sd : na
float dn3 = ready ? vwap - 3.0    * sd : na


// ═══════════════════════════════════════════════════════════════
//  PLOTS
// ═══════════════════════════════════════════════════════════════

color vwapColor = (slopeColor and not na(vwap) and not na(vwap[1])) ? (vwap > vwap[1] ? color.new(color.lime, 0) : color.new(color.red, 0)) : color.new(color.yellow, 0)

plot(vwap, "VWAP", color = vwapColor, linewidth = 2)

plot(up1, "+1 SD", color = color.new(color.aqua, 60))
plot(dn1, "-1 SD", color = color.new(color.aqua, 60))

p2u = plot(up2, "+2 SD", color = color.new(color.red,  20), linewidth = 2)
p2l = plot(dn2, "-2 SD", color = color.new(color.lime, 20), linewidth = 2)

plot(up3, "+3 SD", color = color.new(color.gray, 50))
plot(dn3, "-3 SD", color = color.new(color.gray, 50))

fill(p2u, p2l, color = color.new(color.blue, 93), title = "Band Channel")

bgcolor(showSesBg and newSess ? color.new(color.yellow, 88) : na, title = "Anchor Reset")


// ═══════════════════════════════════════════════════════════════
//  VWAP VALUE TAG
// ═══════════════════════════════════════════════════════════════

var label vwapTag = na
if barstate.islast
    if not na(vwapTag)
        vwapTag.delete()
        vwapTag := na
    if showTag and not na(vwap)
        vwapTag := label.new(bar_index + 3, vwap,
             str.tostring(vwap, format.mintick),
             xloc      = xloc.bar_index,
             style     = label.style_none,
             textcolor = vwapColor,
             size      = size.small)


// ═══════════════════════════════════════════════════════════════
//  Z-SCORE PANEL
// ═══════════════════════════════════════════════════════════════

f_pos() =>
    switch panelPos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        => position.bottom_left

f_zColor(float z) =>
    float az = math.abs(z)
    az < 1.0 ? color.new(color.green, 0) : (az < 2.0 ? color.new(color.orange, 0) : color.new(color.red, 0))

var table tbl = na
if showPanel and barstate.islast
    if not na(tbl)
        tbl.delete()
    tbl := table.new(f_pos(), 2, 4,
         border_color = color.new(#e0e0e0, 0), border_width = 1,
         frame_color  = color.new(#bdbdbd, 0), frame_width  = 1)

    string vText = na(vwap) ? "—" : str.tostring(vwap, format.mintick)
    string zText = na(zScore) ? "—" : (zScore >= 0 ? "+" : "") + str.tostring(zScore, "0.00") + "σ"
    color  zCol  = na(zScore) ? #999999 : f_zColor(zScore)
    string sText = sd > 0 ? str.tostring(sd, format.mintick) : "—"

    tbl.cell(0, 0, "AVWAP",   text_color = #ffffff, bgcolor = #424242, text_size = size.small)
    tbl.cell(1, 0, vText,     text_color = #ffffff, bgcolor = #424242, text_size = size.small)
    tbl.cell(0, 1, "Z-score", text_color = #333333, bgcolor = #fafafa, text_size = size.small)
    tbl.cell(1, 1, zText,     text_color = zCol,    bgcolor = #fafafa, text_size = size.small)
    tbl.cell(0, 2, "± 1 SD",  text_color = #333333, bgcolor = #fafafa, text_size = size.small)
    tbl.cell(1, 2, sText,     text_color = #333333, bgcolor = #fafafa, text_size = size.small)
    tbl.cell(0, 3, "Bars",    text_color = #333333, bgcolor = #fafafa, text_size = size.small)
    tbl.cell(1, 3, str.tostring(nBars), text_color = #333333, bgcolor = #fafafa, text_size = size.small)


// ═══════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════

bool xVwapUp   = ta.crossover(close, vwap)
bool xVwapDown = ta.crossunder(close, vwap)

alertcondition(ready and low  <= dn2,    "Price tagged lower band", "{{ticker}} tagged lower band")
alertcondition(ready and high >= up2,    "Price tagged upper band", "{{ticker}} tagged upper band")
alertcondition(ready and xVwapUp,        "VWAP reclaim (up)",       "{{ticker}} reclaimed VWAP")
alertcondition(ready and xVwapDown,      "VWAP lost (down)",        "{{ticker}} lost VWAP")
alertcondition(newSess,                  "Anchor reset",            "{{ticker}} anchored VWAP reset")
````
