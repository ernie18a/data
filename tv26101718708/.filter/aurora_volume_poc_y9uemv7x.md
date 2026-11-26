# Aurora Volume POC

- url: https://www.tradingview.com/script/y9UeMV7X-Aurora-Volume-POC/
- type: indicator
- pine_id: PUB;c124448033f94904b2636150e79c948e
- version: 3.0

## Description

AURORA VOL POC

Overview

AURORA POC Wave brings together a period-based point of control (POC), volume concentration around that POC, relative-volume bubbles, reversal-pattern markers, and support and resistance zones. It is built for reading where volume has accumulated, whether current participation is unusual, and how price has reacted around a nearby POC.

Choose a profile period such as a day or week. The script builds a developing volume distribution for that period and draws the highest-volume price row as a POC zone. When the period ends, its POC can remain on the chart beside the developing one. The nearest visible POC can display a count of confirmed price rejections over a selected number of days. Each layer can be configured separately.

What you see on the chart

POC zone and heatmap. The center line marks the middle of the highest-volume price row; the edges mark that row's upper and lower prices. The neighboring heatmap rows show estimated volume intensity, with stronger fill indicating greater concentration. A second color channel shows estimated directional pressure from the direction of the contributing lower-timeframe candles. Pressure is an OHLCV-based estimate, not exchange-reported buy and sell volume.

Clean lines. Clean lines displays only the POC center and its row edges, without neighboring heatmap bands or fills. Show the developing POC, completed POCs, or both. You can adjust how many completed POCs remain visible, their placement and line length, and the center-line color and width.

Nearest POC bounce count. Only the nearest eligible visible POC displays the count. A possible bounce begins when price touches its row from outside. It counts when price closes back on the side it approached from within the allowed confirmation window. A cooldown prevents a sustained visit from registering repeatedly; an optional tick buffer requires a stronger rejection. The count uses a selectable number of calendar days. A developing POC may move before the profile closes, making its count provisional. The count describes past reactions, not the probability of another one.

Volume bubbles. Each chart candle's volume is compared with the average of a chosen number of previous completed candles. Bubbles sit inside price candles and grow through five size levels as relative volume increases. Up/down colors use the direction of available lower-timeframe candles, falling back to the chart candle when necessary. The minimum relative-volume setting filters ordinary bubbles. Bubble-only mode instead shows a bubble for every candle with volume once the comparison average is available, plus a close-price path. To remove native wicks and borders in Bubble-only mode, hide the chart symbol.

Volume-colored candles. Candle color and Both modes draw the original chart OHLC candles with the same volume-based color on each body, wick, and border. Stronger relative volume moves the color toward the configured up or down shade. Both also shows bubbles.

Reversal dots. A bullish candidate needs relatively high volume, a sufficiently small body, a dominant lower rejection wick, and estimated selling pressure. A bearish candidate uses an upper wick and estimated buying pressure. Within one or two subsequent candles, both price and the estimated volume direction must switch to confirm the pattern. Only then does a dot appear inside the original candle near its rejection wick. An optional larger bubble identifies the confirming candle. These marks are delayed OHLCV pattern estimates, not observations of real order-book absorption.

Support and resistance. Auto pivot mode tracks the latest confirmed pivot high and low on your chosen timeframe; an ATR fraction sets the width of their zones. Manual mode lets you enter separate support and resistance prices and set zone width in ticks. Choose Both, Nearest, Support, or Resistance; entering zero for a manual price hides that side. Automatic pivot zones appear after pivot confirmation and a completed source-timeframe bar.

How the profile works

The script requests lower-timeframe OHLCV samples when available. It allocates each sample's volume across the price rows crossed by that sample's high-to-low range, in proportion to how much of its range overlaps each row. If lower-timeframe samples are unavailable, it uses chart-candle OHLCV. The row with the greatest allocated volume becomes the POC. Adjacent real price rows form the compact heatmap around it.

Directional pressure comes from each sampled candle's close relative to its open. An up candle contributes positive estimated pressure, a down candle negative pressure, and a doji neutral pressure. The heatmap uses volume intensity for transparency and estimated pressure for color; they describe different properties. Neither is bid/ask delta or a footprint reading.

Each new profile period resets the distribution. The current POC can shift as new data arrives, while a completed period's POC keeps its last calculated position. The maximum-samples setting limits processing cost. Once reached, the script discards the oldest samples of the developing period, so a long or very active period may represent only its more recent portion.

How to use it

Set Profile period to the interval you want to follow and choose a Volume sampling timeframe lower than your chart timeframe for finer estimates.

Start with Heatmap to compare the POC with surrounding volume and pressure. Choose Clean lines when you want only the POC row.

Select Bubbles, Candle color, Both, Bubble-only, or Off under Show volume as. Adjust the average length and bubble threshold for your symbol's volume behavior.

Enable the nearest POC bounce count to see recorded rejections. Check the actual candle closes and the chosen day window before interpreting that count.

Add Auto pivot or Manual support and resistance. Choose Both to display both sides together.

Settings guide

Volume profile: profile period, sampling timeframe, price-row count, and sample limit.

POC zones and bounces: developing and completed POCs, historical count, line placement, bounce window, confirmation bars, cooldown, and optional developing-POC inclusion.

Appearance: Heatmap or Clean lines, separate POC and edge colors, pressure colors, heat transparency, label detail, and Custom/Light/Dark themes.

Volume display: display mode, bubble colors, previous-bar volume average, bubble threshold, size scaling, and transparency.

Reversal markers: relative-volume minimum, body and wick proportions, pressure-switch requirement, one- or two-bar confirmation, dot colors, and optional confirming-candle bubble.

Support and resistance: zone source, both sides or one side, pivot timeframe and confirmation, manual prices, zone width, length, fill, and colors.

Alerts: optional POC-row touch, qualifying high-volume bubble, and confirmed reversal-pattern conditions.

Interpretation and limitations

The POC is the highest-volume estimated price row in this script's sampled profile; it is not guaranteed to hold as support or resistance. Bubble size measures relative candle volume, not the size or count of individual trades. Up/down pressure and the reversal dots come from candle OHLCV; they cannot identify aggressors, resting orders, actual buying or selling volume, or order-book absorption. Symbols with tick volume produce results based on that feed's tick counts.

Bounce counts depend on loaded chart history, retained POC periods, and when each POC first existed. Automatic pivot zones require later confirmation. Reversal dots are intentionally plotted on an earlier wick after a later candle confirms them; a dot was not known in real time on the original wick candle. Use a standard OHLC chart for direct price interpretation. This indicator provides chart context, not trade entries or forecasts.

Credits and license: Original heatmap reference © LuxAlgo.  Source license: Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0).

## Source Code

````pine
// This work is licensed under Attribution-NonCommercial-ShareAlike 4.0 International.
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// Original heatmap reference © LuxAlgo; POC zone design
//@version=6
indicator("Aurora Volume POC", "Aurora VOL", overlay = true, behind_chart = false, explicit_plot_zorder = true, max_boxes_count = 500, max_lines_count = 100, max_labels_count = 50)
// ── Inputs ───────────────────────────────────────────────────────────────────
string GROUP_PROFILE = "1. Volume profile"
string anchorTimeframe = input.timeframe("D", "Profile period", group = GROUP_PROFILE, tooltip = "A new POC starts at each selected period.")
string intrabarTimeframe = input.timeframe("1", "Volume sampling timeframe", group = GROUP_PROFILE, tooltip = "Use a timeframe lower than your chart for more precise volume distribution.")
int profileRows = input.int(50, "Price rows", minval = 10, maxval = 100, group = GROUP_PROFILE)
int maxSamples = input.int(4000, "Maximum samples per period", minval = 500, maxval = 10000, step = 500, group = GROUP_PROFILE, tooltip = "Limits lower-timeframe history used in each profile to control processing time.")

string GROUP_ZONES = "2. POC zones and layout"
bool showDeveloping = input.bool(true, "Show current POC", group = GROUP_ZONES)
bool showPrior = input.bool(true, "Show completed POCs", group = GROUP_ZONES)
int priorCount = input.int(8, "Completed POCs to show", minval = 1, maxval = 20, group = GROUP_ZONES, active = showPrior)
bool extendPrior = input.bool(true, "Align completed POCs with latest bar", group = GROUP_ZONES, active = showPrior)
int boxWidth = input.int(9, "POC panel width (bars)", minval = 2, maxval = 300, group = GROUP_ZONES, tooltip = "Width of each POC heatmap panel or clean line.")
int panelOffset = input.int(5, "Right-side panel gap (bars)", minval = 0, maxval = 495, group = GROUP_ZONES, tooltip = "Empty bars between the anchor and each POC panel. The effective gap is capped to stay within TradingView's 500-bar future limit.")
int waveRows = input.int(11, "Heatmap rows around POC", minval = 3, maxval = 19, step = 2, group = GROUP_ZONES)

string GROUP_BOUNCES = "3. POC bounce counts"
bool showBounceCount = input.bool(true, "Show bounce count on nearest POC", group = GROUP_BOUNCES)
int bounceDays = input.int(5, "Count bounces over last (days)", minval = 1, maxval = 90, group = GROUP_BOUNCES, active = showBounceCount)
int bounceConfirmBars = input.int(2, "Bars allowed to confirm bounce", minval = 0, maxval = 10, group = GROUP_BOUNCES, active = showBounceCount)
int bounceCooldownBars = input.int(3, "Bars before another bounce can count", minval = 0, maxval = 100, group = GROUP_BOUNCES, active = showBounceCount)
int bounceBufferTicks = input.int(0, "Required close beyond POC (ticks)", minval = 0, maxval = 100, group = GROUP_BOUNCES, active = showBounceCount, tooltip = "Price must touch the row from outside and close back on the approach side. Add a buffer to require a stronger rejection.")
bool includeDevelopingBounce = input.bool(true, "Include current POC when finding nearest", group = GROUP_BOUNCES, active = showBounceCount, tooltip = "The current POC can move, so its count is provisional until the profile period closes.")

string GROUP_STYLE = "4. Appearance"
string displayMode = input.string("Heatmap", "POC display", options = ["Heatmap", "Clean lines"], group = GROUP_STYLE, tooltip = "Clean lines shows only dotted POC center lines. POC labels, bounce badges, row edges, and heatmap fills are hidden.")
string theme = input.string("Custom", "Theme", options = ["Custom", "Light", "Dark"], group = GROUP_STYLE)
color customEdge = input.color(#D0D0D0, "POC zone edges (Custom)", group = GROUP_STYLE, active = theme == "Custom")
color customPoc = input.color(#FFFFFF, "POC center line (Custom)", group = GROUP_STYLE, active = theme == "Custom")
color customBuy = input.color(#58B7E8, "Up-pressure heat (Custom)", group = GROUP_STYLE, active = theme == "Custom", tooltip = "Pressure uses lower-timeframe candle direction as an estimate, not trade-side volume.")
color customSell = input.color(#ED785B, "Down-pressure heat (Custom)", group = GROUP_STYLE, active = theme == "Custom")
color customText = input.color(#D0D0D0, "POC label text (Custom)", group = GROUP_STYLE, active = theme == "Custom")
color customSurface = input.color(#303943, "Quiet heatmap rows (Custom)", group = GROUP_STYLE, active = theme == "Custom", tooltip = "Neutral panel tone for low-pressure rows. Volume strength and directional pressure tint rows toward the up/down colors.")
color edgeInk = theme == "Light" ? #414A58 : theme == "Dark" ? #ADB6C7 : customEdge
color pocInk = theme == "Light" ? #174EA6 : theme == "Dark" ? #F7D46A : customPoc
color buyInk = theme == "Light" ? #087DB8 : theme == "Dark" ? #4CC7F5 : customBuy
color sellInk = theme == "Light" ? #B83D34 : theme == "Dark" ? #FF795F : customSell
color textInk = theme == "Light" ? #232A32 : theme == "Dark" ? #E7EDF5 : customText
color surfaceInk = theme == "Light" ? #E8EDF2 : theme == "Dark" ? #26313C : customSurface
int pocLineWidth = input.int(2, "POC line width", minval = 1, maxval = 4, group = GROUP_STYLE)
int quietHeat = input.int(96, "Low-volume heat transparency", minval = 80, maxval = 100, group = GROUP_STYLE, active = displayMode == "Heatmap", tooltip = "Quiet rows stay subtle so stronger activity stands out.")
int peakHeat = input.int(30, "High-volume heat transparency", minval = 0, maxval = 80, group = GROUP_STYLE, active = displayMode == "Heatmap", tooltip = "Lower values make the highest-volume rows more opaque.")
float directionalEmphasis = input.float(1.0, "Buy/sell color emphasis", minval = 0.0, maxval = 2.0, step = 0.1, group = GROUP_STYLE, active = displayMode == "Heatmap", tooltip = "Raises the saturation and visibility of rows with clearer up/down pressure.")
bool showLabels = input.bool(true, "Show POC labels", group = GROUP_STYLE)
string textSize = input.string("Tiny", "Label text size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = GROUP_STYLE, tooltip = "POC labels, bounce badges, and support/resistance captions.")
string labelSize = textSize == "Small" ? size.small : textSize == "Normal" ? size.normal : textSize == "Large" ? size.large : textSize == "Huge" ? size.huge : size.tiny
string labelDetail = input.string("Compact", "POC label detail", options = ["Compact", "Expanded"], group = GROUP_STYLE, active = showLabels, tooltip = "Expanded adds the POC price, distance from the current close, and estimated pressure.")

string GROUP_MARKERS = "5. Volume display"
string markerMode = input.string("Bubbles", "Show volume as", options = ["Bubbles", "Bubble-only", "Candle color", "Both", "Off"], group = GROUP_MARKERS, tooltip = "Candle color and Both draw opaque original-price candles with matching body, wick, and border colors. Bubble-only draws every volume bubble and a close-price path; hide the chart symbol to remove native wicks and borders.")
color customBubbleUp = input.color(#58B7E8, "Up bubbles (Custom)", group = GROUP_MARKERS, active = theme == "Custom")
color customBubbleDown = input.color(#ED785B, "Down bubbles (Custom)", group = GROUP_MARKERS, active = theme == "Custom")
color bubbleUpInk = theme == "Light" ? #1175B7 : theme == "Dark" ? #45B7E9 : customBubbleUp
color bubbleDownInk = theme == "Light" ? #BD4A37 : theme == "Dark" ? #FF876B : customBubbleDown
string volumeSource = input.string("XAUUSD tick volume", "Volume source", options = ["Chart volume", "XAUUSD tick volume"], group = GROUP_MARKERS, tooltip = "Uses the selected XAUUSD feed’s tick volume directly. Spot FX/CFD tick volume counts price updates or broker activity and is not centralized traded volume.")
string xauReference = input.symbol("OANDA:XAUUSD", "XAUUSD tick-volume feed", group = GROUP_MARKERS, active = volumeSource == "XAUUSD tick volume")
int volumeLength = input.int(30, "Average over previous bars", minval = 2, maxval = 500, group = GROUP_MARKERS, tooltip = "Each candle's volume is compared with the average of this many completed candles.")
float bubbleMinRatio = input.float(0.7, "Show bubble above average x", minval = 0.0, maxval = 10.0, step = 0.1, group = GROUP_MARKERS, tooltip = "For example, 0.7 means 70% of the previous average. Bubble-only shows all candles with volume.")
float bubbleMaxRatio = input.float(4.0, "Largest bubble at average x", minval = 1.0, maxval = 50.0, step = 0.1, group = GROUP_MARKERS, tooltip = "Bubble size grows automatically between the minimum and this value.")
int bubbleTransparency = input.int(20, "Bubble transparency", minval = 0, maxval = 90, group = GROUP_MARKERS)
bool confirmedMarkers = input.bool(true, "Show bubbles after candle closes", group = GROUP_MARKERS)

string GROUP_ABS = "6. Reversal markers"
bool showAbsorption = input.bool(true, "Show absorption proxy dots", group = GROUP_ABS, tooltip = "A high-volume rejection wick followed within 1-2 candles by opposite-direction volume and price confirmation. The dot is placed on the original wick after confirmation. This does not measure the order book.")
color customDotUp = input.color(#78D9A1, "Bullish dot (Custom)", group = GROUP_ABS, active = theme == "Custom" and showAbsorption)
color customDotDown = input.color(#F7B967, "Bearish dot (Custom)", group = GROUP_ABS, active = theme == "Custom" and showAbsorption)
color dotUpInk = theme == "Light" ? #168350 : theme == "Dark" ? #78D9A1 : customDotUp
color dotDownInk = theme == "Light" ? #A65A17 : theme == "Dark" ? #F7B967 : customDotDown
float absorptionVolume = input.float(1.2, "Minimum volume / average", minval = 0.5, maxval = 30.0, step = 0.1, group = GROUP_ABS, active = showAbsorption)
float maxBodyFraction = input.float(0.65, "Maximum body / candle range", minval = 0.01, maxval = 0.95, step = 0.05, group = GROUP_ABS, active = showAbsorption)
float minWickFraction = input.float(0.25, "Minimum rejection wick / range", minval = 0.05, maxval = 0.95, step = 0.05, group = GROUP_ABS, active = showAbsorption)
float wickDominance = input.float(1.2, "Wick vs opposite wick", minval = 1.0, maxval = 5.0, step = 0.1, group = GROUP_ABS, active = showAbsorption)
float switchRatio = input.float(1.1, "New pressure vs opposite pressure", minval = 1.0, maxval = 5.0, step = 0.1, group = GROUP_ABS, active = showAbsorption)
int confirmWithin = input.int(2, "Confirm within bars", minval = 1, maxval = 2, group = GROUP_ABS, active = showAbsorption)
bool showSwitchBubbles = input.bool(true, "Mark the confirming candle with a bubble", group = GROUP_ABS, active = showAbsorption)
int dotTransparency = input.int(5, "Dot transparency", minval = 0, maxval = 90, group = GROUP_ABS, active = showAbsorption)

string GROUP_SR = "7. Support and resistance"
string srMode = input.string("Auto pivot", "Zone source", options = ["Off", "Auto pivot", "Manual"], group = GROUP_SR)
string srSide = input.string("Both", "Zones to show", options = ["Both", "Nearest", "Support", "Resistance"], group = GROUP_SR, active = srMode != "Off")
string srTimeframe = input.timeframe("60", "Primary pivot timeframe", group = GROUP_SR, active = srMode == "Auto pivot", tooltip = "Select a timeframe equal to or higher than the chart timeframe.")
bool srChart = input.bool(false, "Add chart timeframe zones", group = GROUP_SR, active = srMode == "Auto pivot")
bool srExtra = input.bool(false, "Add selected timeframe zones", group = GROUP_SR, active = srMode == "Auto pivot")
string srExtraTimeframe = input.timeframe("D", "Additional timeframe", group = GROUP_SR, active = srMode == "Auto pivot" and srExtra)
int srPivotBars = input.int(3, "Bars to confirm a pivot", minval = 1, maxval = 20, group = GROUP_SR, active = srMode == "Auto pivot")
float srAtrWidth = input.float(0.25, "Zone half-height (ATR fraction)", minval = 0.01, maxval = 5.0, step = 0.05, group = GROUP_SR, active = srMode == "Auto pivot")
float srManualSupport = input.float(0.0, "Manual support price (0 = hide)", minval = 0.0, group = GROUP_SR, active = srMode == "Manual")
float srManualResistance = input.float(0.0, "Manual resistance price (0 = hide)", minval = 0.0, group = GROUP_SR, active = srMode == "Manual")
int srManualWidthTicks = input.int(20, "Manual zone half-height (ticks)", minval = 1, maxval = 10000, group = GROUP_SR, active = srMode == "Manual")
int srBackBars = input.int(120, "Zone length (bars)", minval = 2, maxval = 500, group = GROUP_SR, active = srMode != "Off")
int srTransparency = input.int(88, "Zone fill transparency", minval = 0, maxval = 100, group = GROUP_SR, active = srMode != "Off")
color customSupport = input.color(#38AB75, "Support zone (Custom)", group = GROUP_SR, active = srMode != "Off" and theme == "Custom")
color customResistance = input.color(#D65C60, "Resistance zone (Custom)", group = GROUP_SR, active = srMode != "Off" and theme == "Custom")
color supportInk = theme == "Light" ? #138452 : theme == "Dark" ? #5BD19A : customSupport
color resistanceInk = theme == "Light" ? #AF3E45 : theme == "Dark" ? #FA8290 : customResistance

string GROUP_ALERTS = "8. Alerts"
bool alertZoneTouch = input.bool(false, "Alert on POC touch", group = GROUP_ALERTS)
bool alertBubble = input.bool(false, "Alert on high-volume bubble", group = GROUP_ALERTS)
bool alertAbsorption = input.bool(false, "Alert on confirmed reversal marker", group = GROUP_ALERTS)

type PocZone
    int endBar
    int startTime
    float lowPrice
    float highPrice
    float centerPrice
    float pocVolume
    float pocPressure
    array<float> heat
    array<float> pressure
    array<box> bands
    box frame
    line midline
    label caption
    array<int> bounceTimes
    int pendingSide
    int pendingBar
    int lastBounceBar
    bool wasTouching
type SrVisual
    box area
    line center
f_clamp(float value, float lo, float hi) =>
    math.max(lo, math.min(hi, value))
f_volume(float value) =>
    value >= 1000000000 ? str.tostring(value / 1000000000, "#.##") + "B" : value >= 1000000 ? str.tostring(value / 1000000, "#.##") + "M" : value >= 1000 ? str.tostring(value / 1000, "#.##") + "K" : str.tostring(value, "#")
f_age(int stamp) =>
    int minutes = int(math.floor(math.max(0, time - stamp) / 60000.0))
    minutes >= 1440 ? str.tostring(int(math.floor(minutes / 1440.0))) + "d" : minutes >= 60 ? str.tostring(int(math.floor(minutes / 60.0))) + "h" : str.tostring(minutes) + "m"
f_panel(int anchor) =>
    int effectiveOffset = math.min(panelOffset, 498 - boxWidth)
    int firstSafeBar = math.max(0, bar_index - 9997)
    int left = math.max(firstSafeBar, anchor + effectiveOffset + 1)
    int right = left + boxWidth - 1
    [left, right]
f_update_bounces(PocZone zone) =>
    int cutoff = time - bounceDays * 86400000
    while array.size(zone.bounceTimes) > 0 and array.get(zone.bounceTimes, 0) < cutoff
        array.shift(zone.bounceTimes)
    if barstate.isconfirmed and not na(zone.centerPrice)
        bool touching = low <= zone.highPrice and high >= zone.lowPrice
        if zone.pendingSide == 0 and touching and not zone.wasTouching and bar_index - zone.lastBounceBar > bounceCooldownBars
            zone.pendingSide := close[1] > zone.highPrice ? 1 : close[1] < zone.lowPrice ? -1 : 0
            zone.pendingBar := bar_index
        if zone.pendingSide != 0
            float buffer = bounceBufferTicks * syminfo.mintick
            bool wrongSide = zone.pendingSide == 1 ? close < zone.lowPrice : close > zone.highPrice
            bool returned = zone.pendingSide == 1 ? close > zone.highPrice + buffer : close < zone.lowPrice - buffer
            if wrongSide or bar_index - zone.pendingBar > bounceConfirmBars
                zone.pendingSide := 0
            else if returned
                array.push(zone.bounceTimes, time)
                if array.size(zone.bounceTimes) > 500
                    array.shift(zone.bounceTimes)
                zone.lastBounceBar := bar_index
                zone.pendingSide := 0
        zone.wasTouching := touching
    array.size(zone.bounceTimes)
f_hide_sr(SrVisual visual) =>
    if not na(visual.area)
        box.delete(visual.area)
        visual.area := na
    if not na(visual.center)
        line.delete(visual.center)
        visual.center := na
    true
f_draw_sr(SrVisual visual, float price, float halfWidth, bool support, int left, int right, string sourceName) =>
    color zoneInk = support ? supportInk : resistanceInk
    if na(visual.area)
        visual.area := box.new(left, price + halfWidth, right, price - halfWidth, xloc = xloc.bar_index, border_color = zoneInk, bgcolor = color.new(zoneInk, srTransparency))
    box.set_lefttop(visual.area, left, price + halfWidth)
    box.set_rightbottom(visual.area, right, price - halfWidth)
    box.set_border_color(visual.area, zoneInk)
    box.set_bgcolor(visual.area, color.new(zoneInk, srTransparency))
    box.set_text(visual.area, (support ? "SUP " : "RES ") + str.tostring(price, format.mintick) + " · " + sourceName)
    box.set_text_color(visual.area, zoneInk)
    box.set_text_size(visual.area, labelSize)
    box.set_text_halign(visual.area, text.align_center)
    box.set_text_valign(visual.area, text.align_bottom)
    box.set_text_wrap(visual.area, text.wrap_auto)
    if na(visual.center)
        visual.center := line.new(left, price, right, price, xloc = xloc.bar_index, color = zoneInk, style = line.style_dashed)
    line.set_xy1(visual.center, left, price)
    line.set_xy2(visual.center, right, price)
    line.set_color(visual.center, zoneInk)
    true
f_delete(PocZone zone) =>
    for band in zone.bands
        box.delete(band)
    if not na(zone.frame)
        box.delete(zone.frame)
    if not na(zone.midline)
        line.delete(zone.midline)
    if not na(zone.caption)
        label.delete(zone.caption)
    true
f_profile(array<float> highs, array<float> lows, array<float> volumes, array<float> directions, int count, int bandCount) =>
    float pocLow = na
    float pocHigh = na
    float pocCenter = na
    float pocVolume = na
    float pocPressure = na
    array<float> heat = array.new_float(bandCount, 0.0)
    array<float> pressure = array.new_float(bandCount, 0.0)
    int samples = array.size(highs)
    if samples > 0
        float top = na
        float bottom = na
        for i = 0 to samples - 1
            float h = array.get(highs, i)
            float l = array.get(lows, i)
            float v = array.get(volumes, i)
            if not na(h) and not na(l) and not na(v) and v > 0
                top := na(top) ? h : math.max(top, h)
                bottom := na(bottom) ? l : math.min(bottom, l)
        if not na(top) and not na(bottom)
            top := top <= bottom ? bottom + syminfo.mintick * count : top
            float step = (top - bottom) / count
            array<float> rows = array.new_float(count, 0.0)
            array<float> signedRows = array.new_float(count, 0.0)
            for i = 0 to samples - 1
                float h = array.get(highs, i)
                float l = array.get(lows, i)
                float v = array.get(volumes, i)
                float direction = array.get(directions, i)
                if not na(h) and not na(l) and not na(v) and v > 0
                    int first = int(f_clamp(math.floor((l - bottom) / step), 0, count - 1))
                    int last = int(f_clamp(math.floor((h - bottom) / step), 0, count - 1))
                    for j = first to last
                        float rowLow = bottom + j * step
                        float overlap = math.max(0.0, math.min(h, rowLow + step) - math.max(l, rowLow))
                        float piece = h > l ? v * overlap / (h - l) : (j == first ? v : 0.0)
                        array.set(rows, j, array.get(rows, j) + piece)
                        array.set(signedRows, j, array.get(signedRows, j) + piece * direction)
            float maximum = 0.0
            int peak = 0
            for j = 0 to count - 1
                float candidate = array.get(rows, j)
                if candidate > maximum
                    maximum := candidate
                    peak := j
            if maximum > 0
                pocLow := bottom + peak * step
                pocHigh := pocLow + step
                pocCenter := math.avg(pocLow, pocHigh)
                pocVolume := maximum
                pocPressure := array.get(signedRows, peak) / maximum
                int half = int(math.floor(bandCount / 2.0))
                for k = 0 to bandCount - 1
                    int row = peak + k - half
                    float left = row > 0 and row - 1 < count ? array.get(rows, row - 1) : 0.0
                    float middle = row >= 0 and row < count ? array.get(rows, row) : 0.0
                    float right = row + 1 >= 0 and row + 1 < count ? array.get(rows, row + 1) : 0.0
                    array.set(heat, k, f_clamp((left + 2.0 * middle + right) / (4.0 * maximum), 0.0, 1.0))
                    float signed = row >= 0 and row < count ? array.get(signedRows, row) : 0.0
                    array.set(pressure, k, middle > 0 ? signed / middle : 0.0)
    [pocLow, pocHigh, pocCenter, pocVolume, pocPressure, heat, pressure]
f_draw(PocZone zone, int left, int right, bool developing, int age) =>
    int n = array.size(zone.heat)
    float step = zone.highPrice - zone.lowPrice
    int half = int(math.floor(n / 2.0))
    float bottom = zone.lowPrice - half * step
    float top = bottom + n * step
    int fade = developing ? 0 : math.min(26, (age - 1) * 4)
    color stroke = color.new(edgeInk, developing ? 14 : math.min(88, 44 + fade))
    color pocStroke = color.new(pocInk, developing ? 0 : math.min(80, 24 + fade))
    color words = color.new(textInk, developing ? 0 : math.min(85, 22 + fade))
    if displayMode == "Heatmap"
        if na(zone.frame)
            zone.frame := box.new(left, top, right, bottom, xloc = xloc.bar_index, border_color = stroke, border_width = 1, bgcolor = na)
        box.set_lefttop(zone.frame, left, top)
        box.set_rightbottom(zone.frame, right, bottom)
        box.set_border_color(zone.frame, stroke)
        for k = 0 to n - 1
            float bandLow = bottom + k * step
            float bandHigh = bandLow + step
            float strength = array.get(zone.heat, k)
            float signedPressure = array.get(zone.pressure, k)
            float pressureMagnitude = f_clamp(math.abs(signedPressure), 0.0, 1.0)
            float directionalMix = f_clamp((pressureMagnitude - 0.04) / 0.46, 0.0, 1.0)
            color directionInk = signedPressure >= 0 ? buyInk : sellInk
            color heatInk = color.from_gradient(directionalMix, 0.0, 1.0, surfaceInk, directionInk)
            float baseTransparency = quietHeat - strength * (quietHeat - peakHeat) + fade
            float visibilityBoost = strength * directionalMix * 14.0 * directionalEmphasis
            int opacity = int(f_clamp(baseTransparency - visibilityBoost, 0.0, 100.0))
            color fill = color.new(heatInk, opacity)
            if array.size(zone.bands) <= k
                array.push(zone.bands, box.new(left, bandHigh, right, bandLow, xloc = xloc.bar_index, border_color = na, bgcolor = fill))
            box band = array.get(zone.bands, k)
            box.set_lefttop(band, left, bandHigh)
            box.set_rightbottom(band, right, bandLow)
            box.set_bgcolor(band, fill)
    if na(zone.midline)
        zone.midline := line.new(left, zone.centerPrice, right, zone.centerPrice, xloc = xloc.bar_index, color = pocStroke, style = line.style_dotted, width = pocLineWidth)
    line.set_xy1(zone.midline, left, zone.centerPrice)
    line.set_xy2(zone.midline, right, zone.centerPrice)
    line.set_color(zone.midline, pocStroke)
    line.set_width(zone.midline, pocLineWidth)
    if showLabels and displayMode == "Heatmap"
        if na(zone.caption)
            zone.caption := label.new(right + 2, zone.centerPrice, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(color.black, 100), textcolor = words, size = labelSize, textalign = text.align_left, text_font_family = font.family_monospace)
        string status = developing ? "LIVE" : f_age(zone.startTime)
        string caption = "POC " + status + " · " + f_volume(zone.pocVolume)
        if labelDetail == "Expanded"
            float pct = zone.centerPrice != 0 ? (close / zone.centerPrice - 1.0) * 100.0 : na
            string distance = na(pct) ? "n/a" : (pct > 0 ? "+" : "") + str.tostring(pct, "#.##") + "%"
            string pressureText = (zone.pocPressure > 0 ? "+" : "") + str.tostring(zone.pocPressure * 100.0, "#.0") + "% pressure proxy"
            caption := "POC " + str.tostring(zone.centerPrice, format.mintick) + " · " + status + "\n" + distance + " close · " + f_volume(zone.pocVolume) + " vol · " + pressureText
        label.set_xy(zone.caption, right + 2, zone.centerPrice)
        label.set_size(zone.caption, labelSize)
        label.set_textcolor(zone.caption, words)
        label.set_text(zone.caption, caption)
    true
float xauTickVolume = request.security(xauReference, timeframe.period, volume, gaps = barmerge.gaps_off, ignore_invalid_symbol = true)
float effectiveVolume = volumeSource == "Chart volume" ? volume : xauTickVolume
plot(volumeSource == "Chart volume" ? na : effectiveVolume, title = "XAUUSD tick volume", display = display.data_window, precision = 2)
[ltfHighs, ltfLows, ltfVolumes, ltfOpens, ltfCloses] = request.security_lower_tf(syminfo.tickerid, intrabarTimeframe, [high, low, volume, open, close], ignore_invalid_timeframe = true)
var array<float> anchorHighs = array.new_float()
var array<float> anchorLows = array.new_float()
var array<float> anchorVolumes = array.new_float()
var array<float> anchorDirections = array.new_float()
var array<PocZone> history = array.new<PocZone>()
var PocZone active = na
if barstate.isfirst or timeframe.change(anchorTimeframe)
    if not na(active) and not na(active.centerPrice)
        active.endBar := bar_index - 1
        if showPrior
            array.push(history, active)
            while array.size(history) > priorCount
                f_delete(array.shift(history))
        else
            f_delete(active)
    else if not na(active)
        f_delete(active)
    array.clear(anchorHighs)
    array.clear(anchorLows)
    array.clear(anchorVolumes)
    array.clear(anchorDirections)
    active := PocZone.new(bar_index, time, na, na, na, na, na, array.new_float(), array.new_float(), array.new<box>(), na, na, na, array.new_int(), 0, na, -1000000, false)
int intrabars = array.size(ltfHighs)
float rawIntrabarTotal = 0.0
if intrabars > 0
    for i = 0 to intrabars - 1
        rawIntrabarTotal += nz(array.get(ltfVolumes, i))
float intrabarScale = volumeSource == "Chart volume" ? 1.0 : rawIntrabarTotal > 0 and not na(effectiveVolume) ? effectiveVolume / rawIntrabarTotal : na
float candleUpVolume = 0.0
float candleDownVolume = 0.0
if intrabars > 0
    for i = 0 to intrabars - 1
        float h = array.get(ltfHighs, i)
        float l = array.get(ltfLows, i)
        float rawV = array.get(ltfVolumes, i)
        float v = rawV * intrabarScale
        float o = array.get(ltfOpens, i)
        float c = array.get(ltfCloses, i)
        if not na(h) and not na(l) and not na(v) and not na(o) and not na(c) and v > 0
            array.push(anchorHighs, h)
            array.push(anchorLows, l)
            array.push(anchorVolumes, v)
            array.push(anchorDirections, c > o ? 1.0 : c < o ? -1.0 : 0.0)
            candleUpVolume += c > o ? v : c == o ? v * 0.5 : 0.0
            candleDownVolume += c < o ? v : c == o ? v * 0.5 : 0.0
else if not na(effectiveVolume) and effectiveVolume > 0
    array.push(anchorHighs, high)
    array.push(anchorLows, low)
    array.push(anchorVolumes, effectiveVolume)
    array.push(anchorDirections, close > open ? 1.0 : close < open ? -1.0 : 0.0)
    candleUpVolume := close > open ? effectiveVolume : close == open ? effectiveVolume * 0.5 : 0.0
    candleDownVolume := close < open ? effectiveVolume : close == open ? effectiveVolume * 0.5 : 0.0
while array.size(anchorHighs) > maxSamples
    array.shift(anchorHighs)
    array.shift(anchorLows)
    array.shift(anchorVolumes)
    array.shift(anchorDirections)
[pocLow, pocHigh, pocCenter, pocVolume, pocPressure, wave, pressureWave] = f_profile(anchorHighs, anchorLows, anchorVolumes, anchorDirections, profileRows, waveRows)
if not na(pocCenter)
    active.endBar := bar_index
    active.lowPrice := pocLow
    active.highPrice := pocHigh
    active.centerPrice := pocCenter
    active.pocVolume := pocVolume
    active.pocPressure := pocPressure
    active.heat := wave
    active.pressure := pressureWave
    if showDeveloping
        [panelLeft, panelRight] = f_panel(bar_index)
        f_draw(active, panelLeft, panelRight, true, 0)
if showBounceCount and not na(active) and not na(active.centerPrice)
    f_update_bounces(active)
if showBounceCount and showPrior and array.size(history) > 0
    for i = 0 to array.size(history) - 1
        f_update_bounces(array.get(history, i))
if barstate.islast and showPrior and array.size(history) > 0
    int total = array.size(history)
    for i = 0 to total - 1
        PocZone zone = array.get(history, i)
        [panelLeft, panelRight] = f_panel(extendPrior ? bar_index : zone.endBar)
        f_draw(zone, panelLeft, panelRight, false, total - i)
float averageVolume = ta.sma(effectiveVolume[1], volumeLength)
float volumeRatio = averageVolume > 0 ? effectiveVolume / averageVolume : na
plot(volumeRatio, title = "Selected volume / prior average", display = display.data_window, precision = 2)
bool markerReady = not confirmedMarkers or barstate.isconfirmed
bool bubbleOnly = markerMode == "Bubble-only"
bool bubblesEnabled = markerMode == "Bubbles" or markerMode == "Both" or bubbleOnly
bool colorsEnabled = markerMode == "Candle color" or markerMode == "Both"
float volumeSizeSpan = math.max(0.4, bubbleMaxRatio - bubbleMinRatio)
float smallCut = bubbleMinRatio + volumeSizeSpan * 0.15
float mediumCut = bubbleMinRatio + volumeSizeSpan * 0.35
float largeCut = bubbleMinRatio + volumeSizeSpan * 0.60
float hugeCut = bubbleMinRatio + volumeSizeSpan
bool bubbleSignal = bubblesEnabled and markerReady and not na(volumeRatio) and effectiveVolume > 0 and (bubbleOnly or volumeRatio >= bubbleMinRatio)
bool buyDominant = candleUpVolume > candleDownVolume
bool sellDominant = candleDownVolume > candleUpVolume
bool bubbleBuyer = buyDominant or not sellDominant and close >= open
float bubbleY = bubbleBuyer ? low + (high - low) * 0.15 : high - (high - low) * 0.15
color bubbleInk = color.new(bubbleBuyer ? bubbleUpInk : bubbleDownInk, bubbleTransparency)
color quietBubbleInk = color.new(bubbleBuyer ? bubbleUpInk : bubbleDownInk, math.min(90, bubbleTransparency + 40))
color candleInk = color.from_gradient(math.min(nz(volumeRatio), hugeCut), 0.0, hugeCut, edgeInk, bubbleBuyer ? bubbleUpInk : bubbleDownInk)
bool paintVolumeCandle = colorsEnabled and not na(volumeRatio)
barcolor(bubbleOnly ? color.new(color.white, 100) : paintVolumeCandle ? candleInk : na)
plotcandle(paintVolumeCandle ? open : na, paintVolumeCandle ? high : na, paintVolumeCandle ? low : na, paintVolumeCandle ? close : na, title = "Volume-colored original candles", color = candleInk, wickcolor = candleInk, bordercolor = candleInk)
plotshape(bubbleSignal and volumeRatio < smallCut ? bubbleY : na, title = "Volume bubble · very low", style = shape.circle, location = location.absolute, color = quietBubbleInk, size = size.tiny, force_overlay = true)
plotshape(bubbleSignal and volumeRatio >= smallCut and volumeRatio < mediumCut ? bubbleY : na, title = "Volume bubble · low", style = shape.circle, location = location.absolute, color = bubbleInk, size = size.small, force_overlay = true)
plotshape(bubbleSignal and volumeRatio >= mediumCut and volumeRatio < largeCut ? bubbleY : na, title = "Volume bubble · medium", style = shape.circle, location = location.absolute, color = bubbleInk, size = size.normal, force_overlay = true)
plotshape(bubbleSignal and volumeRatio >= largeCut and volumeRatio < hugeCut ? bubbleY : na, title = "Volume bubble · high", style = shape.circle, location = location.absolute, color = bubbleInk, size = size.large, force_overlay = true)
plotshape(bubbleSignal and volumeRatio >= hugeCut ? bubbleY : na, title = "Volume bubble · extreme", style = shape.circle, location = location.absolute, color = bubbleInk, size = size.huge, force_overlay = true)
plot(bubbleOnly ? close : na, title = "Bubble-only close-price path", color = color.new(pocInk, 25), linewidth = 2, style = plot.style_line, force_overlay = true)
float candleRange = high - low
float bodyFraction = candleRange > 0 ? math.abs(close - open) / candleRange : 1.0
float lowerWick = candleRange > 0 ? (math.min(open, close) - low) / candleRange : 0.0
float upperWick = candleRange > 0 ? (high - math.max(open, close)) / candleRange : 0.0
bool absorptionBase = not na(volumeRatio) and volumeRatio >= absorptionVolume and bodyFraction <= maxBodyFraction
bool bullCandidate = absorptionBase and sellDominant and lowerWick >= minWickFraction and lowerWick >= upperWick * wickDominance
bool bearCandidate = absorptionBase and buyDominant and upperWick >= minWickFraction and upperWick >= lowerWick * wickDominance
bool switchedBuy = markerReady and candleUpVolume >= candleDownVolume * switchRatio and candleUpVolume > 0 and close > open
bool switchedSell = markerReady and candleDownVolume >= candleUpVolume * switchRatio and candleDownVolume > 0 and close < open
bool bullConfirmed1 = bullCandidate[1] and switchedBuy and close >= math.avg(open[1], close[1])
bool bearConfirmed1 = bearCandidate[1] and switchedSell and close <= math.avg(open[1], close[1])
bool bullConfirmed2 = confirmWithin == 2 and bullCandidate[2] and not bullConfirmed1[1] and switchedBuy and close >= math.avg(open[2], close[2])
bool bearConfirmed2 = confirmWithin == 2 and bearCandidate[2] and not bearConfirmed1[1] and switchedSell and close <= math.avg(open[2], close[2])
bool bullSwitch = bullConfirmed1 or bullConfirmed2
bool bearSwitch = bearConfirmed1 or bearConfirmed2
plotshape(showAbsorption and bullConfirmed1 ? low[1] + (high[1] - low[1]) * 0.08 : na, title = "Bullish absorption · 1-bar confirmation", style = shape.circle, location = location.absolute, color = color.new(dotUpInk, dotTransparency), size = size.small, offset = -1, force_overlay = true)
plotshape(showAbsorption and bullConfirmed2 ? low[2] + (high[2] - low[2]) * 0.08 : na, title = "Bullish absorption · 2-bar confirmation", style = shape.circle, location = location.absolute, color = color.new(dotUpInk, dotTransparency), size = size.small, offset = -2, force_overlay = true)
plotshape(showAbsorption and bearConfirmed1 ? high[1] - (high[1] - low[1]) * 0.08 : na, title = "Bearish absorption · 1-bar confirmation", style = shape.circle, location = location.absolute, color = color.new(dotDownInk, dotTransparency), size = size.small, offset = -1, force_overlay = true)
plotshape(showAbsorption and bearConfirmed2 ? high[2] - (high[2] - low[2]) * 0.08 : na, title = "Bearish absorption · 2-bar confirmation", style = shape.circle, location = location.absolute, color = color.new(dotDownInk, dotTransparency), size = size.small, offset = -2, force_overlay = true)
plotshape(showAbsorption and showSwitchBubbles and bubblesEnabled and bullSwitch ? low + (high - low) * 0.15 : na, title = "Confirmed buy switch bubble", style = shape.circle, location = location.absolute, color = color.new(dotUpInk, bubbleTransparency), size = size.large, force_overlay = true)
plotshape(showAbsorption and showSwitchBubbles and bubblesEnabled and bearSwitch ? high - (high - low) * 0.15 : na, title = "Confirmed sell switch bubble", style = shape.circle, location = location.absolute, color = color.new(dotDownInk, bubbleTransparency), size = size.large, force_overlay = true)
f_sr_pivots() =>
    [ta.pivothigh(high, srPivotBars, srPivotBars)[1], ta.pivotlow(low, srPivotBars, srPivotBars)[1], ta.atr(14)[1], time[1]]
f_sr_store(array<float> prices, array<float> heights, array<int> stamps, array<bool> broken, float pivot, float atrValue, int stamp) =>
    if not na(pivot) and not na(atrValue) and not na(stamp) and (array.size(stamps) == 0 or array.get(stamps, array.size(stamps) - 1) != stamp)
        array.push(prices, pivot)
        array.push(heights, math.max(syminfo.mintick, atrValue * srAtrWidth))
        array.push(stamps, stamp)
        array.push(broken, false)
        if array.size(prices) > 80
            array.shift(prices)
            array.shift(heights)
            array.shift(stamps)
            array.shift(broken)
    true
f_sr_expire(array<float> prices, array<float> heights, array<bool> broken, bool support) =>
    if barstate.isconfirmed and array.size(prices) > 0
        for i = 0 to array.size(prices) - 1
            float level = array.get(prices, i)
            float half = array.get(heights, i)
            if support ? close < level - half : close > level + half
                array.set(broken, i, true)
    true
f_sr_pick(array<float> prices, array<float> heights, array<bool> broken, bool support, float priceNow, array<float> occupiedPrices, array<float> occupiedHeights) =>
    float best = na
    float height = na
    float gap = na
    if array.size(prices) > 0
        for i = 0 to array.size(prices) - 1
            float level = array.get(prices, i)
            float half = array.get(heights, i)
            bool valid = not array.get(broken, i) and (support ? level <= priceNow : level >= priceNow)
            if array.size(occupiedPrices) > 0
                for j = 0 to array.size(occupiedPrices) - 1
                    float used = array.get(occupiedPrices, j)
                    float usedHalf = array.get(occupiedHeights, j)
                    if level - half <= used + usedHalf and level + half >= used - usedHalf
                        valid := false
            float distance = math.abs(priceNow - level)
            if valid and (na(gap) or distance < gap)
                best := level
                height := half
                gap := distance
    [best, height]
[pH, pL, pA, pT] = request.security(syminfo.tickerid, srTimeframe, f_sr_pivots(), lookahead = barmerge.lookahead_on)
[cH, cL, cA, cT] = request.security(syminfo.tickerid, timeframe.period, f_sr_pivots(), lookahead = barmerge.lookahead_on)
[eH, eL, eA, eT] = request.security(syminfo.tickerid, srExtraTimeframe, f_sr_pivots(), lookahead = barmerge.lookahead_on)
var array<float> pRes = array.new_float()
var array<float> pSup = array.new_float()
var array<float> cRes = array.new_float()
var array<float> cSup = array.new_float()
var array<float> eRes = array.new_float()
var array<float> eSup = array.new_float()
var array<float> pResH = array.new_float()
var array<float> pSupH = array.new_float()
var array<float> cResH = array.new_float()
var array<float> cSupH = array.new_float()
var array<float> eResH = array.new_float()
var array<float> eSupH = array.new_float()
var array<int> pResT = array.new_int()
var array<int> pSupT = array.new_int()
var array<int> cResT = array.new_int()
var array<int> cSupT = array.new_int()
var array<int> eResT = array.new_int()
var array<int> eSupT = array.new_int()
var array<bool> pResBroken = array.new_bool()
var array<bool> pSupBroken = array.new_bool()
var array<bool> cResBroken = array.new_bool()
var array<bool> cSupBroken = array.new_bool()
var array<bool> eResBroken = array.new_bool()
var array<bool> eSupBroken = array.new_bool()
if srMode == "Auto pivot"
    f_sr_store(pRes, pResH, pResT, pResBroken, pH, pA, pT)
    f_sr_expire(pRes, pResH, pResBroken, false)
    f_sr_store(pSup, pSupH, pSupT, pSupBroken, pL, pA, pT)
    f_sr_expire(pSup, pSupH, pSupBroken, true)
    if srChart
        f_sr_store(cRes, cResH, cResT, cResBroken, cH, cA, cT)
        f_sr_expire(cRes, cResH, cResBroken, false)
        f_sr_store(cSup, cSupH, cSupT, cSupBroken, cL, cA, cT)
        f_sr_expire(cSup, cSupH, cSupBroken, true)
    if srExtra
        f_sr_store(eRes, eResH, eResT, eResBroken, eH, eA, eT)
        f_sr_expire(eRes, eResH, eResBroken, false)
        f_sr_store(eSup, eSupH, eSupT, eSupBroken, eL, eA, eT)
        f_sr_expire(eSup, eSupH, eSupBroken, true)
var array<SrVisual> srVisuals = array.from(SrVisual.new(na, na), SrVisual.new(na, na), SrVisual.new(na, na), SrVisual.new(na, na), SrVisual.new(na, na), SrVisual.new(na, na))
if barstate.islast
    float reference = barstate.isconfirmed ? close : close[1]
    bool manual = srMode == "Manual"
    array<float> occupiedPrices = array.new_float()
    array<float> occupiedHeights = array.new_float()
    array<float> chosenPrices = array.new_float()
    array<float> chosenHeights = array.new_float()
    array<bool> chosenSides = array.new_bool()
    array<string> chosenSources = array.new_string()
    array<int> chosenSourcesIndex = array.new_int()
    if manual
        float half = srManualWidthTicks * syminfo.mintick
        if srManualSupport > 0 and srManualSupport <= reference and srSide != "Resistance"
            array.push(chosenPrices, srManualSupport)
            array.push(chosenHeights, half)
            array.push(chosenSides, true)
            array.push(chosenSources, "manual")
        if srManualResistance > 0 and srManualResistance >= reference and srSide != "Support" and (array.size(chosenPrices) == 0 or srManualResistance - half > srManualSupport + half)
            array.push(chosenPrices, srManualResistance)
            array.push(chosenHeights, half)
            array.push(chosenSides, false)
            array.push(chosenSources, "manual")
        if srSide == "Nearest" and array.size(chosenPrices) == 2 and math.abs(reference - srManualResistance) < math.abs(reference - srManualSupport)
            array.remove(chosenPrices, 0)
            array.remove(chosenHeights, 0)
            array.remove(chosenSides, 0)
            array.remove(chosenSources, 0)
        else if srSide == "Nearest" and array.size(chosenPrices) == 2
            array.pop(chosenPrices)
            array.pop(chosenHeights)
            array.pop(chosenSides)
            array.pop(chosenSources)
    else if srMode == "Auto pivot"
        for slot = 0 to 5
            float bestPrice = na
            float bestHalf = na
            float bestDistance = na
            bool bestSupport = false
            string bestSource = ""
            int bestIndex = na
            for sourceIndex = 0 to 5
                bool support = sourceIndex % 2 == 0
                bool enabled = sourceIndex < 2 or sourceIndex < 4 and srChart or sourceIndex >= 4 and srExtra
                bool visibleSide = srSide == "Both" or srSide == "Nearest" or srSide == "Support" and support or srSide == "Resistance" and not support
                bool alreadyUsed = false
                if array.size(chosenSourcesIndex) > 0
                    for k = 0 to array.size(chosenSourcesIndex) - 1
                        if array.get(chosenSourcesIndex, k) == sourceIndex
                            alreadyUsed := true
                if enabled and visibleSide and not alreadyUsed
                    array<float> candidates = sourceIndex == 0 ? pSup : sourceIndex == 1 ? pRes : sourceIndex == 2 ? cSup : sourceIndex == 3 ? cRes : sourceIndex == 4 ? eSup : eRes
                    array<float> widths = sourceIndex == 0 ? pSupH : sourceIndex == 1 ? pResH : sourceIndex == 2 ? cSupH : sourceIndex == 3 ? cResH : sourceIndex == 4 ? eSupH : eResH
                    array<bool> expired = sourceIndex == 0 ? pSupBroken : sourceIndex == 1 ? pResBroken : sourceIndex == 2 ? cSupBroken : sourceIndex == 3 ? cResBroken : sourceIndex == 4 ? eSupBroken : eResBroken
                    [candidate, candidateHalf] = f_sr_pick(candidates, widths, expired, support, reference, occupiedPrices, occupiedHeights)
                    float distance = math.abs(reference - candidate)
                    if not na(candidate) and (na(bestDistance) or distance < bestDistance)
                        bestPrice := candidate
                        bestHalf := candidateHalf
                        bestDistance := distance
                        bestSupport := support
                        bestSource := sourceIndex < 2 ? srTimeframe : sourceIndex < 4 ? timeframe.period : srExtraTimeframe
                        bestIndex := sourceIndex
            if not na(bestPrice)
                array.push(chosenPrices, bestPrice)
                array.push(chosenHeights, bestHalf)
                array.push(chosenSides, bestSupport)
                array.push(chosenSources, bestSource)
                array.push(chosenSourcesIndex, bestIndex)
                array.push(occupiedPrices, bestPrice)
                array.push(occupiedHeights, bestHalf)
            if srSide == "Nearest"
                break
    for slot = 0 to 5
        SrVisual visual = array.get(srVisuals, slot)
        if slot < array.size(chosenPrices) and srMode != "Off"
            f_draw_sr(visual, array.get(chosenPrices, slot), array.get(chosenHeights, slot), array.get(chosenSides, slot), math.max(0, bar_index - srBackBars + 1), bar_index, array.get(chosenSources, slot))
        else
            f_hide_sr(visual)
var label nearestBounceBadge = na
if barstate.islast and showBounceCount and displayMode == "Heatmap"
    PocZone nearestZone = na
    float nearestDistance = na
    int nearestAnchor = na
    if showPrior and array.size(history) > 0
        for i = 0 to array.size(history) - 1
            PocZone zone = array.get(history, i)
            float distance = math.abs(close - zone.centerPrice)
            if not na(distance) and (na(nearestDistance) or distance <= nearestDistance)
                nearestZone := zone
                nearestDistance := distance
                nearestAnchor := extendPrior ? bar_index : zone.endBar
    if includeDevelopingBounce and showDeveloping and not na(active) and not na(active.centerPrice)
        float distance = math.abs(close - active.centerPrice)
        if na(nearestDistance) or distance <= nearestDistance
            nearestZone := active
            nearestDistance := distance
            nearestAnchor := bar_index
    if not na(nearestZone)
        string bounceText = "bounces " + str.tostring(array.size(nearestZone.bounceTimes)) + " / " + str.tostring(bounceDays) + "d"
        if showLabels and not na(nearestZone.caption)
            label.set_text(nearestZone.caption, label.get_text(nearestZone.caption) + " · " + bounceText)
        else
            [badgeLeft, badgeRight] = f_panel(nearestAnchor)
            int badgeX = badgeRight + 2
            if na(nearestBounceBadge)
                nearestBounceBadge := label.new(badgeX, nearestZone.centerPrice, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(color.black, 100), textcolor = pocInk, size = labelSize)
            label.set_xy(nearestBounceBadge, badgeX, nearestZone.centerPrice)
            label.set_size(nearestBounceBadge, labelSize)
            label.set_textcolor(nearestBounceBadge, pocInk)
            label.set_text(nearestBounceBadge, bounceText)
PocZone latest = array.size(history) > 0 ? array.get(history, array.size(history) - 1) : na
bool activeTouch = not na(active) and not na(active.lowPrice) and high >= active.lowPrice and low <= active.highPrice
bool priorTouch = not na(latest) and high >= latest.lowPrice and low <= latest.highPrice
alertcondition(alertZoneTouch and barstate.isconfirmed and (activeTouch or priorTouch), "AURORA POC touch", "Price touched an AURORA POC row on {{ticker}}")
alertcondition(alertBubble and bubbleSignal and volumeRatio >= smallCut, "AURORA high-volume bubble", "High relative selected volume on {{ticker}}")
alertcondition(alertAbsorption and showAbsorption and (bullSwitch or bearSwitch), "AURORA reversal proxy", "Confirmed wick rejection and opposite-direction volume switch on {{ticker}}; OHLCV volume proxy")
````
