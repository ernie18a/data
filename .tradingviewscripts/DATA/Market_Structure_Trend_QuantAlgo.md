<!-- tradingview-pine-id: PUB;0aa44eee734141579f9018149d21bd32 -->
<!-- tradingviewscripts-format: 1 -->
# Market Structure Trend [QuantAlgo]

Source: https://www.tradingview.com/script/WuoIIKnH-Market-Structure-Trend-QuantAlgo/

## Description

🟢 Overview

The Market Structure Trend tracks the dominant directional bias of price by detecting confirmed swing highs and lows and maintaining an active structure level that only flips on a genuine break of that level. Rather than reacting to every minor high or low, it waits for a pivot to lock in after a defined number of bars on either side, then holds the resulting structure until price closes beyond it by an optional confirmation buffer. The result is a clean, non-repainting structure line that stays aligned with the prevailing market structure while filtering out stop hunts and marginal pokes through key levels. This makes the prevailing bias readable at a glance across any instrument or timeframe.
[image]https://www.tradingview.com/x/vNFZJ75R/[/image]
🟢 How It Works

The indicator begins by identifying pivot highs and pivot lows using the selected left and right structure bars. These pivots become the swing points that define market structure:
[pine]pivot_high = ta.pivothigh(high, left_bars, right_bars)
pivot_low  = ta.pivotlow(low, left_bars, right_bars)[/pine]
When a new pivot is confirmed, the corresponding swing high or swing low is updated. The active structure range is calculated as the absolute distance between the current swing high and swing low, and a confirmation buffer is derived as a percentage of that range:
[pine]structure_range = math.abs(swing_high - swing_low)
confirm_buffer  = structure_range * buffer_pct / 100.0[/pine]
Break levels are then offset by this buffer so that a downside break sits below the swing low and an upside break sits above the swing high. On every confirmed bar the script checks whether the chosen source (or the high or low when Break On Wick is enabled) has crossed the relevant break level. A successful cross reverses structure direction and reassigns the structure level to the opposite swing. If no break occurs, the structure level simply continues to track the swing consistent with the current direction.

Structure direction is seeded on the first ready bar by comparing price to the midpoint of the swing range, establishing an initial bias. From that point forward flips are gated strictly by confirmed breaks, so the state never repaints or changes mid-bar.

The structure level is drawn as a continuous line with a soft glow underneath. When radial layering is enabled, four concentric fills are drawn between the structure level and the bar midpoint, with transparency increasing outward. This produces a stepped radial field that visually maps distance from the active structure boundary rather than a single flat zone.
[image]https://www.tradingview.com/x/i5NFr0nX/[/image]
🟢 Signal Interpretation

▶ Bullish Structure (Structure Line at Swing Low with Bullish Color): When structure direction is bullish the line sits at the most recent confirmed swing low. Price is considered to remain in an uptrend structure as long as it stays above the buffered downside break level. The bullish state holds until a confirmed downside break occurs, at which point the line moves to the swing high and the color transitions.

▶ Bearish Structure (Structure Line at Swing High with Bearish Color): When structure direction is bearish the line sits at the most recent confirmed swing high. Price remains in a downtrend structure until a confirmed upside break flips the state. The bearish state persists through subsequent bars until an upside break is registered.
[image]https://www.tradingview.com/x/m5iw4rxA/[/image]
🟢 Features

▶ Preconfigured Presets: Three parameter sets cover a range of trading styles and timeframes. Default uses the manual Left Structure Bars, Right Structure Bars, and Confirmation Buffer values and is balanced for swing trading on 1-hour and daily charts. Fast Response shortens the structure legs for scalping and intraday use on 1-minute to 1-hour charts, registering minor swings so the structure trend flips earlier. Smooth Trend lengthens the legs for position trading on daily and weekly charts, tracking only major swings and holding through pullbacks with the confirmation buffer.
[image]https://www.tradingview.com/x/qaf92WF3/[/image]
▶ Built-in Alerts: Three alert conditions support automated monitoring of structure flips. Bullish Structure Shift fires on the first bar that structure direction changes from bearish to bullish. Bearish Structure Shift fires on the opposite transition. Any Structure Shift triggers on either flip for traders who prefer a single unified alert. All messages include the exchange, ticker, and timeframe for immediate context.
[image]https://www.tradingview.com/x/D3vqqYSR/[/image]
▶ Visual Customization: Six color presets (Classic, Aqua, Cosmic, Cyber, Neon, and Custom) supply coordinated bullish and bearish color pairings suited to different chart themes. Selecting Custom unlocks independent color pickers for full manual control. Optional bar coloring tints each candle with the active structure color at a configurable transparency, and optional background coloring extends the same tint across the full chart pane. Radial layering, structure shift markers, and the structure line itself all inherit the active color pair so the entire visual system remains consistent.
[image]https://www.tradingview.com/x/kbP8wOGX/[/image]

---

## Source Code

````pine
// This script is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © QuantAlgo

//@version=6
indicator('Market Structure Trend [QuantAlgo]', overlay = true)

//              ╔════════════════════════════════╗              //
//              ║      USER-DEFINED SETTINGS     ║              //
//              ╚════════════════════════════════╝              //

g_structure = '════════ Structure Settings ════════'
g_visual    = '════════ Visual Settings ════════'

tooltip_preset       = 'Select a predefined configuration that loads a complete set of market structure parameters optimized for different trading styles and timeframes. Choosing a preset overrides the manual Left Structure Bars, Right Structure Bars, and Confirmation Buffer values below. Select Default to use those manual inputs instead.'
tooltip_preset_det   = 'Default: Uses the manual Left Structure Bars, Right Structure Bars, and Confirmation Buffer inputs. With the factory values (5 / 5 / 0%), this is a balanced configuration for swing trading on 1H and daily charts. It reads moderate swing structure and flips the trend only on a clean break of the last confirmed swing level.\n\nFast Response (3 / 3 / 0%): Aggressive configuration for scalping and intraday use on 1 minute to 1H charts. Shorter structure legs register minor swings, so the market structure trend flips earlier on small breaks, at the cost of more frequent state changes in chop.\n\nSmooth Trend (12 / 12 / 10%): Conservative configuration for position trading on daily and weekly charts. Longer structure legs track only major swings and a 10% confirmation buffer holds the trend through pullbacks, delivering fewer but higher conviction structure shifts.'
tooltip_source       = 'Price series used to confirm a break of market structure. Close is the standard non-repainting choice because it reflects the settled bar. HL2 uses the bar midpoint to reduce close-to-close noise. HLC3 adds close weighting for a balanced estimate. OHLC4 averages all four prices. Open tracks the opening print only. When Break On Wick is enabled, high/low are used for break detection instead of this source.'
tooltip_left         = 'Number of bars to the left of a candidate swing high or swing low that must hold for that swing to qualify as market structure. Higher values register only major swings and keep the structure trend stable. Lower values register minor swings and increase activity. Used when Preset Configuration is Default; otherwise overridden by the selected preset.'
tooltip_right        = 'Number of bars to the right required to lock a swing as confirmed market structure. This is the confirmation lag of the structure engine. A swing is only accepted after this many bars have closed beyond it, so historical structure levels do not repaint once printed. Lower values confirm earlier. Higher values wait longer and reduce noise. Used when Preset Configuration is Default; otherwise overridden by the selected preset.'
tooltip_buffer       = 'Extra distance price must travel beyond a confirmed swing level before the market structure trend flips, expressed as a percentage of the active structure range (the gap between the last confirmed swing high and swing low). 0 flips on any break of the level. Higher values (5 to 20) ignore marginal pokes through structure and reduce whipsaw, at the cost of slightly later flips. Used when Preset Configuration is Default; otherwise overridden by the selected preset.'
tooltip_wick         = 'How a structure break is confirmed on a closed bar. Off requires the selected Source to close beyond the swing level, which filters wick stop hunts and keeps the structure trend clean. On allows a closed-bar high or low that pierces the level to count as a break. Both modes evaluate only on bar close so the trend state does not repaint or flip mid-bar.'
tooltip_radial       = 'When enabled, fills the zone between the active market structure level and mid-price using radial layering: four concentric fill bands whose density is strongest at the structure line and decays radially toward price. This maps distance from the structure level as a stepped radial field rather than a single flat fill.'
tooltip_radial_t     = 'Base transparency of the innermost radial layer (nearest the market structure line). Outer layers step progressively more transparent. 0 is fully opaque, 100 is fully transparent. Lower values (50 to 70) produce denser layering. Higher values (80 to 95) keep it subtle.'
tooltip_markers      = 'Show or hide markers that appear when the market structure trend flips direction. A marker plots on the structure line when a bullish or bearish structure shift is confirmed on bar close.'
tooltip_color_preset = 'Pre-configured bullish and bearish color schemes for different chart themes and visual preferences. Classic uses traditional green and red. Aqua uses blue and orange. Cosmic uses cyan and purple. Cyber uses cool cyan against warm orange. Neon uses high contrast yellow and magenta. Custom uses the Bullish Color and Bearish Color inputs below. The active pair colors the structure line, glow, radial layering, markers, optional bar coloring, and optional background coloring.'
tooltip_bullish      = 'Bullish color used when Color Preset is set to Custom, and whenever market structure is in an uptrend under a non Custom preset that resolves to this slot. Applied to the structure line, glow, radial layering, bullish shift markers, bar coloring, and background coloring.'
tooltip_bearish      = 'Bearish color used when Color Preset is set to Custom, and whenever market structure is in a downtrend under a non Custom preset that resolves to this slot. Applied to the structure line, glow, radial layering, bearish shift markers, bar coloring, and background coloring.'
tooltip_candles      = 'When enabled, each price bar is tinted with the current bullish or bearish color according to the confirmed market structure trend. Uptrend structure tints bars bullish. Downtrend structure tints bars bearish. This makes structure state readable directly from the candles without relying only on the structure line.'
tooltip_bar_trans    = 'Transparency of the bar coloring overlay from 0 to 100. Lower values produce more opaque, vivid bar colors that make direction obvious. Higher values produce a lighter tint that signals state without covering price action as heavily. Only applies when Enable Bar Coloring is turned on.'
tooltip_bgcolor      = 'When enabled, the chart background is tinted with the current bullish or bearish color according to the confirmed market structure trend. This reinforces structure state across the full pane and pairs well with radial layering disabled.'
tooltip_bg_trans     = 'Transparency of the background coloring overlay from 0 to 100. Lower values produce a stronger wash. Higher values produce a subtle tint that leaves candles and the structure line easier to read. Only applies when Enable Background Coloring is turned on.'

preset          = input.string('Default', 'Preset Configuration', options = ['Default', 'Fast Response', 'Smooth Trend'], group = g_structure, tooltip = tooltip_preset + '\n\n' + tooltip_preset_det)
src             = input.source(close, 'Source', group = g_structure, tooltip = tooltip_source)
left_input      = input.int(5, 'Left Structure Bars', minval = 1, maxval = 200, group = g_structure, tooltip = tooltip_left)
right_input     = input.int(5, 'Right Structure Bars', minval = 1, maxval = 200, group = g_structure, tooltip = tooltip_right)
buffer_input    = input.float(0.0, 'Confirmation Buffer %', minval = 0.0, maxval = 100.0, step = 0.5, group = g_structure, tooltip = tooltip_buffer)
break_on_wick   = input.bool(false, 'Break On Wick', group = g_structure, tooltip = tooltip_wick)

show_radial     = input.bool(true, 'Show Radial Layering', group = g_visual, tooltip = tooltip_radial)
radial_trans    = input.int(75, 'Radial Layer Transparency', minval = 0, maxval = 100, group = g_visual, tooltip = tooltip_radial_t)
show_markers    = input.bool(true, 'Show Structure Shift Markers', group = g_visual, tooltip = tooltip_markers)
color_preset    = input.string('Custom', 'Color Preset', options = ['Classic', 'Aqua', 'Cosmic', 'Cyber', 'Neon', 'Custom'], group = g_visual, tooltip = tooltip_color_preset)
bullish_input   = input.color(#00ffaa, 'Bullish Color', group = g_visual, tooltip = tooltip_bullish)
bearish_input   = input.color(#ff0000, 'Bearish Color', group = g_visual, tooltip = tooltip_bearish)
show_candles    = input.bool(false, 'Enable Bar Coloring', group = g_visual, tooltip = tooltip_candles)
bar_trans       = input.int(0, 'Bar Color Transparency', minval = 0, maxval = 100, group = g_visual, tooltip = tooltip_bar_trans)
show_bgcolor    = input.bool(false, 'Enable Background Coloring', group = g_visual, tooltip = tooltip_bgcolor)
bg_trans        = input.int(90, 'Background Color Transparency', minval = 0, maxval = 100, group = g_visual, tooltip = tooltip_bg_trans)

left_bars  = preset == 'Fast Response' ? 3  : preset == 'Smooth Trend' ? 12 : left_input
right_bars = preset == 'Fast Response' ? 3  : preset == 'Smooth Trend' ? 12 : right_input
buffer_pct = preset == 'Smooth Trend' ? 10.0 : preset == 'Fast Response' ? 0.0 : buffer_input

[bullish_color, bearish_color] = switch color_preset
    'Classic' => [#00ff00, #ff0000]
    'Aqua'    => [#00d4ff, #ff8c00]
    'Cosmic'  => [#49ffce, #9932cc]
    'Cyber'   => [#00cccc, #ff6600]
    'Neon'    => [#ffff00, #ff00ff]
    'Custom'  => [bullish_input, bearish_input]

//              ╔════════════════════════════════╗              //
//              ║        CORE CALCULATION        ║              //
//              ╚════════════════════════════════╝              //

pivot_high = ta.pivothigh(high, left_bars, right_bars)
pivot_low  = ta.pivotlow(low, left_bars, right_bars)

var float swing_high = na
var float swing_low  = na
var int   structure_dir = 0
var float structure_level = na

if not na(pivot_high)
    swing_high := pivot_high
if not na(pivot_low)
    swing_low := pivot_low

float structure_range = (not na(swing_high) and not na(swing_low)) ? math.abs(swing_high - swing_low) : na
float confirm_buffer  = nz(structure_range) * buffer_pct / 100.0

float break_down_level = swing_low  - confirm_buffer
float break_up_level   = swing_high + confirm_buffer

float break_down_src = break_on_wick ? low  : src
float break_up_src   = break_on_wick ? high : src

bool structure_ready = not na(swing_high) and not na(swing_low)

if barstate.isconfirmed and structure_ready
    if structure_dir == 0
        structure_dir := src >= (swing_high + swing_low) / 2.0 ? 1 : -1
        structure_level := structure_dir == 1 ? swing_low : swing_high
    else if structure_dir == 1
        if break_down_src < break_down_level
            structure_dir := -1
            structure_level := swing_high
        else
            structure_level := swing_low
    else if structure_dir == -1
        if break_up_src > break_up_level
            structure_dir := 1
            structure_level := swing_low
        else
            structure_level := swing_high

bool bullish_structure_shift = structure_dir == 1  and structure_dir[1] == -1 and barstate.isconfirmed
bool bearish_structure_shift = structure_dir == -1 and structure_dir[1] == 1  and barstate.isconfirmed
bool any_structure_shift     = bullish_structure_shift or bearish_structure_shift

color structure_color = structure_dir == 1 ? bullish_color : structure_dir == -1 ? bearish_color : bullish_color

//              ╔════════════════════════════════╗              //
//              ║         VISUALIZATION          ║              //
//              ╚════════════════════════════════╝              //

float structure_line = structure_dir == 0 ? na : structure_level
float structure_up   = structure_dir == 1  ? structure_line : na
float structure_dn   = structure_dir == -1 ? structure_line : na

plot(structure_up, 'Glow Up',   color = color.new(bullish_color, 70), linewidth = 6, style = plot.style_linebr)
plot(structure_dn, 'Glow Down', color = color.new(bearish_color, 70), linewidth = 6, style = plot.style_linebr)
plot(structure_up, 'Bullish Structure', color = bullish_color, linewidth = 2, style = plot.style_linebr)
plot(structure_dn, 'Bearish Structure', color = bearish_color, linewidth = 2, style = plot.style_linebr)

float radial_base = structure_line
float radial_edge = structure_dir == 0 ? na : hl2
float radial_1 = not na(radial_base) and not na(radial_edge) ? radial_base + (radial_edge - radial_base) * 0.25 : na
float radial_2 = not na(radial_base) and not na(radial_edge) ? radial_base + (radial_edge - radial_base) * 0.50 : na
float radial_3 = not na(radial_base) and not na(radial_edge) ? radial_base + (radial_edge - radial_base) * 0.75 : na

int radial_t0 = radial_trans
int radial_t1 = math.min(100, radial_trans + 12)
int radial_t2 = math.min(100, radial_trans + 24)
int radial_t3 = math.min(100, radial_trans + 32)

p_radial_0 = plot(show_radial ? radial_base : na, 'Radial Base', color = na, display = display.none, editable = false)
p_radial_1 = plot(show_radial ? radial_1    : na, 'Radial 1',    color = na, display = display.none, editable = false)
p_radial_2 = plot(show_radial ? radial_2    : na, 'Radial 2',    color = na, display = display.none, editable = false)
p_radial_3 = plot(show_radial ? radial_3    : na, 'Radial 3',    color = na, display = display.none, editable = false)
p_radial_4 = plot(show_radial ? radial_edge : na, 'Radial Edge', color = na, display = display.none, editable = false)

fill(p_radial_0, p_radial_1, color = show_radial and structure_dir != 0 ? color.new(structure_color, radial_t0) : na, title = 'Radial Layer 1')
fill(p_radial_1, p_radial_2, color = show_radial and structure_dir != 0 ? color.new(structure_color, radial_t1) : na, title = 'Radial Layer 2')
fill(p_radial_2, p_radial_3, color = show_radial and structure_dir != 0 ? color.new(structure_color, radial_t2) : na, title = 'Radial Layer 3')
fill(p_radial_3, p_radial_4, color = show_radial and structure_dir != 0 ? color.new(structure_color, radial_t3) : na, title = 'Radial Layer 4')

plotshape(show_markers and bullish_structure_shift ? structure_line : na, title = 'Bullish Structure Shift', style = shape.circle, location = location.absolute, color = bullish_color, size = size.tiny)
plotshape(show_markers and bearish_structure_shift ? structure_line : na, title = 'Bearish Structure Shift', style = shape.circle, location = location.absolute, color = bearish_color, size = size.tiny)

barcolor(show_candles and structure_dir != 0 ? color.new(structure_color, bar_trans) : na, title = 'Market Structure Bar Color')
bgcolor(show_bgcolor and structure_dir != 0 ? color.new(structure_color, bg_trans) : na, title = 'Market Structure Background Color')

//              ╔════════════════════════════════╗              //
//              ║             ALERTS             ║              //
//              ╚════════════════════════════════╝              //

alertcondition(bullish_structure_shift, title = 'Bullish Structure Shift', message = 'Market Structure Trend: BULLISH structure shift confirmed on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(bearish_structure_shift, title = 'Bearish Structure Shift', message = 'Market Structure Trend: BEARISH structure shift confirmed on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(any_structure_shift, title = 'Any Structure Shift', message = 'Market Structure Trend: Market structure trend flipped on {{exchange}}:{{ticker}} - {{interval}}')

//              ╔════════════════════════════════╗              //
//              ║           CREATED BY           ║              //
//              ╚════════════════════════════════╝              //

// ██████╗ ██╗   ██╗ █████╗ ███╗   ██╗████████╗     █████╗ ██╗      ██████╗  ██████╗
//██╔═══██╗██║   ██║██╔══██╗████╗  ██║╚══██╔══╝    ██╔══██╗██║     ██╔════╝ ██╔═══██╗
//██║   ██║██║   ██║███████║██╔██╗ ██║   ██║       ███████║██║     ██║  ███╗██║   ██║
//██║▄▄ ██║██║   ██║██╔══██║██║╚██╗██║   ██║       ██╔══██║██║     ██║   ██║██║   ██║
//╚██████╔╝╚██████╔╝██║  ██║██║ ╚████║   ██║       ██║  ██║███████╗╚██████╔╝╚██████╔╝
// ╚══▀▀═╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝       ╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝
````
