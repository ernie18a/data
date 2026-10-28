# Liquidity Void Mapper [forexobroker]

- url: https://www.tradingview.com/script/mLjuOHhC-Liquidity-Void-Mapper-forexobroker/
- type: indicator
- pine_id: PUB;12a07219498c4392ac31b37a3db63340
- version: 1.0

## Description

The Liquidity Void Mapper identifies price zones where historically little volume was transacted, creating "voids" in the volume distribution. These thin liquidity areas behave like air pockets -- price tends to move through them quickly. The indicator maps these voids as visual boxes and generates signals when price enters a void zone, anticipating rapid directional movement through the thin area.

🔶 CONCEPTS

Volume is not evenly distributed across price levels. Some levels attract heavy trading activity (high volume nodes) and act as support, resistance, or magnets. Other levels have very little historical volume, creating gaps in the volume profile that institutional traders call liquidity voids.

When price reaches a void, there are fewer resting limit orders to absorb momentum. This means price often accelerates through the void rather than consolidating within it. Understanding where these voids exist provides a structural edge in anticipating price behavior.

🔶 HOW IT WORKS

The indicator divides the recent price range into a configurable grid of price levels. For each bar in the lookback window, its volume is distributed proportionally across the grid levels that the bar's range covers.

After building the volume distribution, the average volume per grid level is calculated. Any grid level with volume significantly below the average (controlled by the void threshold) is marked as a liquidity void.

These void zones are drawn as semi-transparent boxes on the chart, colored based on their position relative to current price. The indicator then monitors whether price enters any active void zone and generates directional signals when combined with trend and volume filters.

🔶 HOW TO USE

Apply the indicator to your chart. Void zones appear as transparent boxes spanning historical price ranges. Cyan-tinted boxes are below current price, purple-tinted boxes are above, and gold-tinted boxes contain current price.

When price enters a void from below in a bullish trend, a buy signal fires -- anticipating that price will move quickly through the thin zone. When price enters a void from above in a bearish trend, a sell signal fires.

The info table shows the number of active voids, the analyzed range, grid resolution, trend direction, and current volume status.

Use the void threshold to control sensitivity. A lower threshold (0.15-0.20) only flags the most extreme voids. A higher threshold (0.40-0.50) captures more zones but includes less significant ones.

🔶 FEATURES

- Rolling volume distribution with configurable grid resolution
- Visual void zone boxes with position-based color coding
- Multi-confirmation buy and sell signals with 3-layer glow arrows
- EMA trend filter with glow effect
- Info table showing void count, range details, and volume status
- 15-bar signal cooldown to prevent overtrading
- Volume confirmation filter on all signals
- Configurable maximum void zones to keep the chart clean
- 9 configurable alert conditions with webhook JSON support
- Non-repainting signals using bar confirmation

🔶 SETTINGS GUIDE

Volume Profile Lookback (default 50): How many bars to analyze for volume distribution. Longer lookbacks capture more price history but may include outdated zones.

Price Grid Divisions (default 20): Number of price levels in the grid. More divisions provide finer resolution but increase computation. 15-25 is the recommended range.

Void Threshold (default 0.30): Volume fraction below which a zone qualifies as a void. Expressed as a ratio of the average grid volume. Lower values detect only severe voids.

Max Void Zones (default 5): Limits the number of boxes displayed to keep the chart readable.

EMA Length (default 50): Trend direction filter for signal confirmation.

🔶 ALERTS

Nine alert conditions are available:
- Buy Signal / Sell Signal / Any Signal: Core trading alerts
- Void Entry Below / Void Entry Above: Directional void entry detection
- Many Voids: Alerts when multiple voids are present (unusual market structure)
- Volume Confirm: Above-average volume alert
- Any Void Entry: Non-directional void entry detection
- Webhook JSON: Structured data for automated systems

All alerts are based on confirmed bar data.

🔶 LIMITATIONS AND DISCLAIMER

Volume distribution analysis has inherent limitations. The grid resolution creates discrete zones that may not perfectly represent continuous volume distribution. Volume data quality varies significantly between instruments -- forex spot volume, for example, represents only a fraction of total market activity. The lookback window determines which historical volume is considered, and zones may become invalid as market structure changes. Void zones should be used as one input among many, not as standalone signals. Always practice proper risk management. This is an educational and analytical tool.

🔶 RELEASE NOTES

v1.0 - Initial release with rolling volume distribution, void zone detection, visual box mapping, and multi-confirmation signal system.

## Source Code

````pine
// © forexobroker
//@version=6
indicator("Liquidity Void Mapper [forexobroker]", shorttitle="LVM [fob]", overlay=true, max_labels_count=500, max_boxes_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────────
string g_void   = "Void Detection"
string g_trend  = "Trend Filter"
string g_signal = "Signal Settings"
string g_visual = "Visual Settings"

int    i_lookback   = input.int(50, "Volume Profile Lookback", minval=20, maxval=200, group=g_void, tooltip="Number of bars to analyze for volume distribution")
int    i_gridRows   = input.int(20, "Price Grid Divisions", minval=10, maxval=50, group=g_void, tooltip="Number of price levels to divide the range into")
float  i_voidThresh = input.float(0.3, "Void Threshold", minval=0.05, maxval=0.8, step=0.05, group=g_void, tooltip="Volume fraction below which a zone is considered a void (relative to average)")
int    i_maxVoids   = input.int(5, "Max Void Zones Displayed", minval=1, maxval=15, group=g_void, tooltip="Maximum number of void boxes to show on chart")
int    i_emaLen     = input.int(50, "EMA Trend Length", minval=10, maxval=200, group=g_trend, tooltip="EMA length for trend direction filter")
int    i_cooldown   = input.int(15, "Signal Cooldown Bars", minval=5, maxval=50, group=g_signal, tooltip="Minimum bars between signals")
bool   i_showBoxes  = input.bool(true, "Show Void Boxes", group=g_visual, tooltip="Display liquidity void zones on chart")
bool   i_showTable  = input.bool(true, "Show Info Table", group=g_visual, tooltip="Display summary table")
bool   i_showGlow   = input.bool(true, "Show Glow Effects", group=g_visual, tooltip="Enable 3-layer glow on signals")

// ─── COLORS ────────────────────────────────────────────────────────────────────
color c_cyan    = #00d4ff
color c_pink    = #ff2d78
color c_green   = #39ff14
color c_purple  = #a855f7
color c_gold    = #ffaa00

// ─── CORE CALCULATIONS ────────────────────────────────────────────────────────
float ema50      = ta.ema(close, i_emaLen)
float volSma     = ta.sma(volume, 20)
float atrVal     = ta.atr(14)
bool  aboveEma   = close > ema50
bool  belowEma   = close < ema50

// ─── VOLUME PROFILE VOID DETECTION ─────────────────────────────────────────────
// Find highest high and lowest low over lookback
float rangeHigh = ta.highest(high, i_lookback)
float rangeLow  = ta.lowest(low, i_lookback)
float rangeSize = rangeHigh - rangeLow
float gridStep  = rangeSize / i_gridRows

// Volume distribution across grid levels
// We accumulate volume at each price level based on where each bar's body falls
type VoidZone
    float topPrice
    float botPrice
    float volRatio
    bool  isActive

var array<float> gridVol = array.new_float(i_gridRows, 0.0)

// Reset and recalculate volume grid periodically
if barstate.isconfirmed and bar_index % 5 == 0
    for idx = 0 to i_gridRows - 1
        array.set(gridVol, idx, 0.0)
    // Distribute current bar volume to appropriate grid levels
    for lookIdx = 0 to math.min(i_lookback - 1, bar_index)
        float barHi  = high[lookIdx]
        float barLo  = low[lookIdx]
        float barVol = volume[lookIdx]
        if rangeSize > 0 and barVol > 0
            int startGrid = math.max(0, math.floor((barLo - rangeLow) / gridStep))
            int endGrid   = math.min(i_gridRows - 1, math.floor((barHi - rangeLow) / gridStep))
            int gridSpan  = endGrid - startGrid + 1
            float volPerGrid = gridSpan > 0 ? barVol / gridSpan : 0.0
            for g = startGrid to endGrid
                if g >= 0 and g < i_gridRows
                    array.set(gridVol, g, array.get(gridVol, g) + volPerGrid)

// Find average grid volume and identify voids
float totalGridVol = 0.0
for idx = 0 to i_gridRows - 1
    totalGridVol += array.get(gridVol, idx)
float avgGridVol = totalGridVol / i_gridRows

// Detect void zones (low volume price levels)
var array<VoidZone> voids = array.new<VoidZone>()
var int voidCount = 0

if barstate.isconfirmed and bar_index % 5 == 0
    array.clear(voids)
    voidCount := 0
    for idx = 0 to i_gridRows - 1
        float gVol   = array.get(gridVol, idx)
        float ratio  = avgGridVol > 0 ? gVol / avgGridVol : 1.0
        if ratio < i_voidThresh and voidCount < i_maxVoids
            VoidZone vz = VoidZone.new()
            vz.topPrice := rangeLow + (idx + 1) * gridStep
            vz.botPrice := rangeLow + idx * gridStep
            vz.volRatio := ratio
            vz.isActive := close < vz.botPrice or close > vz.topPrice
            array.push(voids, vz)
            voidCount += 1

// ─── SIGNAL LOGIC ──────────────────────────────────────────────────────────────
var int lastSignalBar = 0
int barsSinceSignal   = bar_index - lastSignalBar
bool cooldownOk       = barsSinceSignal >= i_cooldown
bool volConfirm       = volume > volSma
bool confirmed        = barstate.isconfirmed

// Check if price is entering a void zone
bool enteringVoidFromBelow = false
bool enteringVoidFromAbove = false

if array.size(voids) > 0
    for idx = 0 to array.size(voids) - 1
        VoidZone vz = array.get(voids, idx)
        if close > vz.botPrice and close < vz.topPrice
            if close[1] <= vz.botPrice
                enteringVoidFromBelow := true
            if close[1] >= vz.topPrice
                enteringVoidFromAbove := true

// Buy: price enters void from below + bullish trend + volume
bool buySignal  = enteringVoidFromBelow and aboveEma and volConfirm and cooldownOk and confirmed
// Sell: price enters void from above + bearish trend + volume
bool sellSignal = enteringVoidFromAbove and belowEma and volConfirm and cooldownOk and confirmed

if buySignal or sellSignal
    lastSignalBar := bar_index

// ─── VISUAL: Void Zone Boxes ───────────────────────────────────────────────────
if i_showBoxes and barstate.isconfirmed and bar_index % 5 == 0
    // Clear old boxes by drawing new ones
    if array.size(voids) > 0
        for idx = 0 to array.size(voids) - 1
            VoidZone vz = array.get(voids, idx)
            color boxColor = close < vz.botPrice ? color.new(c_cyan, 85) : close > vz.topPrice ? color.new(c_purple, 85) : color.new(c_gold, 80)
            box.new(bar_index - i_lookback, vz.topPrice, bar_index + 10, vz.botPrice, border_color=color.new(c_cyan, 50), bgcolor=boxColor, border_width=1, border_style=line.style_dashed)

// ─── VISUAL: Signal Labels ─────────────────────────────────────────────────────
if buySignal
    label.new(bar_index, low - atrVal * 0.8, "BUY\nVOID", style=label.style_label_up, color=color.new(c_green, 10), textcolor=color.white, size=size.normal)
if sellSignal
    label.new(bar_index, high + atrVal * 0.8, "SELL\nVOID", style=label.style_label_down, color=color.new(c_pink, 10), textcolor=color.white, size=size.normal)

// ─── VISUAL: EMA Line (3-layer glow) ──────────────────────────────────────────
plot(ema50, "EMA Glow 1", color=color.new(c_purple, 70), linewidth=5)
plot(ema50, "EMA Glow 2", color=color.new(c_purple, 40), linewidth=3)
plot(ema50, "EMA Core",   color=color.new(c_purple, 0),  linewidth=1)

// ─── VISUAL: Glow Arrows ──────────────────────────────────────────────────────
plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(c_green, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(c_green, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",   shape.triangleup,   location.belowbar, color.new(c_green, 0),  size=size.normal, text="BUY", textcolor=color.white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1",  shape.triangledown, location.abovebar, color.new(c_pink, 70),  size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2",  shape.triangledown, location.abovebar, color.new(c_pink, 40),  size=size.large)
plotshape(sellSignal,                "Sell Signal",   shape.triangledown, location.abovebar, color.new(c_pink, 0),   size=size.normal, text="SELL", textcolor=color.white)

// ─── BAR & BG COLOR ────────────────────────────────────────────────────────────
barcolor(buySignal ? c_green : sellSignal ? c_pink : na)
bgcolor(buySignal ? color.new(c_green, 93) : sellSignal ? color.new(c_pink, 93) : na)

// ─── INFO TABLE ────────────────────────────────────────────────────────────────
if i_showTable and barstate.islast
    var table infoTable = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    table.cell(infoTable, 0, 0, "Liquidity Void Mapper", text_color=c_cyan, text_size=size.normal, text_halign=text.align_left)
    table.cell(infoTable, 1, 0, "", text_color=color.white, text_size=size.normal)
    table.cell(infoTable, 0, 1, "Active Voids", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(infoTable, 1, 1, str.tostring(voidCount), text_color=voidCount > 0 ? c_gold : color.gray, text_size=size.small)
    table.cell(infoTable, 0, 2, "Range", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(infoTable, 1, 2, str.tostring(math.round(rangeLow, 2)) + " - " + str.tostring(math.round(rangeHigh, 2)), text_color=color.white, text_size=size.small)
    table.cell(infoTable, 0, 3, "Grid Step", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(infoTable, 1, 3, str.tostring(math.round(gridStep, 4)), text_color=color.white, text_size=size.small)
    table.cell(infoTable, 0, 4, "Trend", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(infoTable, 1, 4, aboveEma ? "BULLISH" : "BEARISH", text_color=aboveEma ? c_green : c_pink, text_size=size.small)
    table.cell(infoTable, 0, 5, "Volume", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(infoTable, 1, 5, str.tostring(math.round(volume / volSma, 2)) + "x avg", text_color=volConfirm ? c_gold : color.gray, text_size=size.small)

// ─── ALERTS ────────────────────────────────────────────────────────────────────
if buySignal
    alert('{"action":"BUY","indicator":"LVM","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"voids":' + str.tostring(voidCount) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"LVM","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"voids":' + str.tostring(voidCount) + '}', alert.freq_once_per_bar_close)

// ─── ALERTCONDITIONS ───────────────────────────────────────────────────────────
alertcondition(buySignal,               "LVM Buy Signal",         "Liquidity Void BUY on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,              "LVM Sell Signal",        "Liquidity Void SELL on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal, "LVM Any Signal",         "Liquidity Void signal on {{ticker}} {{interval}} at {{close}}")
alertcondition(enteringVoidFromBelow,   "LVM Void Entry Below",   "Price entering void from below on {{ticker}} {{interval}} at {{close}}")
alertcondition(enteringVoidFromAbove,   "LVM Void Entry Above",   "Price entering void from above on {{ticker}} {{interval}} at {{close}}")
alertcondition(voidCount > 3,           "LVM Many Voids",         "Multiple liquidity voids detected on {{ticker}} {{interval}} at {{close}}")
alertcondition(volConfirm,              "LVM Volume Confirm",     "Above-average volume on {{ticker}} {{interval}} at {{close}}")
alertcondition(enteringVoidFromBelow or enteringVoidFromAbove, "LVM Any Void Entry", "Price entering any void on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal, "LVM Webhook JSON",       "{\"action\":\"signal\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
