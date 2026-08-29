<!-- tradingview-pine-id: PUB;b7a1864be3ba494fa5cef5dfaba07384 -->
<!-- tradingviewscripts-format: 1 -->
# PF - Momentum Map Lite v1.0.0

Source: https://www.tradingview.com/script/XXZiVA1Z-Momentum-Map-Lite-PrimeFold/

## Description

Four stochastic oscillators, read as one alignment score from 0/4 to 4/4. 

Free, no signals, no alerts.

Momentum Map Lite runs four stochastic oscillators at different lookbacks 
(fast, mid, slow, anchor) and plots their D-lines in one pane.)

You read one alignment score instead of watching all four:

- 4/4 BULL: all four turning up from oversold
- 4/4 BEAR: all four turning down from overbought
- Anything between: partial alignment, no full rotation

The background shades only at 4/4, and only on a closed bar, so it doesn't repaint. 

The dashboard shows the current rotation count plus the strongest and weakest of the four.

It doesn't generate alerts, give entry signals, or detect divergence. 

This is the alignment read. 
Check whether momentum agrees across the four before you act on any one of them.

---

## Source Code

````pine
//@version=6
// ============================================================
// PRIMEFOLD CONTINUITY REGISTRY
// Module: Momentum Map Lite — FREE TIER
// Version: v1.0.0
// Module Code: MM
// (c) 2026 PrimeFold Trading
// ============================================================
// Quad-stochastic rotation scanner. Visualises four stochastic
// D-lines and their alignment state in a single oscillator pane.
// Full rotation signals, alerts, and divergence detection are excluded from this free tier.
// ============================================================

indicator('PF - Momentum Map Lite v1.0.0', shorttitle = 'PF-MM-Lite', overlay = false, max_labels_count = 1, explicit_plot_zorder = true)

// ============================================================================
// PRIMEFOLD DESIGN SYSTEM v3.1 — IMMUTABLE CONSTANTS
// ============================================================================

var color BULLISH_GREEN = #10B981
var color BEARISH_RED = #EF4444
var color COGNITIVE_BLUE = #7AA2F7
var color NEUTRAL_AMBER = #F59E0B
var color TEXT_DIM = #999999
var color DIVIDER = #2A2A2A

// ============================================================================
// INPUTS — OSCILLATOR SETTINGS
// ============================================================================

k1 = input.int(9, title = '%K Length (Stoch 1 — Fast)', group = 'Oscillator Settings')
d1 = input.int(3, title = '%D Smoothing (Stoch 1)', group = 'Oscillator Settings')
k2 = input.int(14, title = '%K Length (Stoch 2 — Mid)', group = 'Oscillator Settings')
d2 = input.int(3, title = '%D Smoothing (Stoch 2)', group = 'Oscillator Settings')
k3 = input.int(40, title = '%K Length (Stoch 3 — Slow)', group = 'Oscillator Settings')
d3 = input.int(4, title = '%D Smoothing (Stoch 3)', group = 'Oscillator Settings')
k4 = input.int(60, title = '%K Length (Stoch 4 — Anchor)', group = 'Oscillator Settings')
d4 = input.int(10, title = '%D Smoothing (Stoch 4)', group = 'Oscillator Settings')
smoothK4 = input.int(1, title = 'Extra Smoothing (Stoch 4)', group = 'Oscillator Settings')

// ============================================================================
// INPUTS — DASHBOARD (Lite tier: Off / Simple only, per BUILDING_STANDARDS)
// ============================================================================

string GRP_DASH = 'Dashboard'
string dashboardMode = input.string('Simple', 'Dashboard Mode', options = ['Off', 'Simple'], group = GRP_DASH, tooltip = 'Off: no dashboard | Simple: full Lite breakdown (Rotation / Strongest / Weakest)')
string i_theme = input.string('Dark', 'Dashboard Theme', options = ['Dark', 'Light'], group = GRP_DASH)
string i_dash_size = input.string('Small', 'Dashboard Text Size', options = ['Tiny', 'Small', 'Normal', 'Large'], group = GRP_DASH)
string dashPos = input.string('Top Right', 'Dashboard Position', options = ['Top Right', 'Top Center', 'Top Left', 'Middle Right', 'Middle Center', 'Middle Left', 'Bottom Right', 'Bottom Center', 'Bottom Left'], group = GRP_DASH)

// ============================================================================
// CORE CALCULATIONS — QUAD STOCHASTICS (mirrors strategy v1.3.1)
// ============================================================================

stoch1K = ta.sma(ta.stoch(close, high, low, k1), 1)
stoch1D = ta.sma(stoch1K, d1)
stoch2K = ta.sma(ta.stoch(close, high, low, k2), 1)
stoch2D = ta.sma(stoch2K, d2)
stoch3K = ta.sma(ta.stoch(close, high, low, k3), 1)
stoch3D = ta.sma(stoch3K, d3)
stoch4K = ta.sma(ta.stoch(close, high, low, k4), smoothK4)
stoch4D = ta.sma(stoch4K, d4)

// ============================================================================
// ROTATION LOGIC (confirmed-bar gated, non-repaint)
// ============================================================================

bool confirmed = barstate.isconfirmed

// Bullish: D-line rising while below 20
bool s1Up = ta.change(stoch1D) > 0 and stoch1D < 20
bool s2Up = ta.change(stoch2D) > 0 and stoch2D < 20
bool s3Up = ta.change(stoch3D) > 0 and stoch3D < 20
bool s4Up = ta.change(stoch4D) > 0 and stoch4D < 20

// Bearish: D-line falling while above 80
bool s1Dn = ta.change(stoch1D) < 0 and stoch1D > 80
bool s2Dn = ta.change(stoch2D) < 0 and stoch2D > 80
bool s3Dn = ta.change(stoch3D) < 0 and stoch3D > 80
bool s4Dn = ta.change(stoch4D) < 0 and stoch4D > 80

int bullCount = (s1Up ? 1 : 0) + (s2Up ? 1 : 0) + (s3Up ? 1 : 0) + (s4Up ? 1 : 0)
int bearCount = (s1Dn ? 1 : 0) + (s2Dn ? 1 : 0) + (s3Dn ? 1 : 0) + (s4Dn ? 1 : 0)

bool isBull = bullCount >= 4
bool isBear = bearCount >= 4

// ============================================================================
// PLOTS — FOUR D-LINES
// ============================================================================

// Line weight climbs with lookback: thin = fast, thick = slow/anchor
plot(stoch1D, 'Stoch 1 D (K=9 — Fast)', color = COGNITIVE_BLUE, linewidth = 1)
plot(stoch2D, 'Stoch 2 D (K=14 — Mid)', color = NEUTRAL_AMBER, linewidth = 2)
plot(stoch3D, 'Stoch 3 D (K=40 — Slow)', color = BULLISH_GREEN, linewidth = 3)
plot(stoch4D, 'Stoch 4 D (K=60 — Anchor)', color = BEARISH_RED, linewidth = 4)

// Reference levels
h80 = hline(80, 'Overbought', color = color.new(TEXT_DIM, 60), linestyle = hline.style_dotted)
h20 = hline(20, 'Oversold', color = color.new(TEXT_DIM, 60), linestyle = hline.style_dotted)
hline(50, 'Midline', color = color.new(DIVIDER, 70), linestyle = hline.style_dotted)
fill(h80, h20, color = color.new(DIVIDER, 92), title = 'Channel Fill')

// ============================================================================
// BACKGROUND — ROTATION ALIGNMENT
// ============================================================================

bgcolor(isBull and confirmed ? color.new(BULLISH_GREEN, 82) : na, title = 'Bullish Rotation BG')
bgcolor(isBear and confirmed ? color.new(BEARISH_RED, 82) : na, title = 'Bearish Rotation BG')

// ============================================================================
// HELPERS — STRONGEST / WEAKEST
// ============================================================================

float strongest = math.max(stoch1D, math.max(stoch2D, math.max(stoch3D, stoch4D)))
float weakest = math.min(stoch1D, math.min(stoch2D, math.min(stoch3D, stoch4D)))

string rotLabel = bullCount > bearCount ? str.tostring(bullCount) + '/4 BULL' : bearCount > bullCount ? str.tostring(bearCount) + '/4 BEAR' : 'NEUTRAL'
color rotColor = bullCount > bearCount ? BULLISH_GREEN : bearCount > bullCount ? BEARISH_RED : NEUTRAL_AMBER

// ============================================================================
// DASHBOARD — theme / size / position resolved from inputs (Lite: Off / Simple)
// ============================================================================

bool dashIsDark = i_theme == 'Dark'
color DASH_BG = dashIsDark ? #121212 : #F5F5F5
color DASH_TEXT = dashIsDark ? #FFFFFF : #1A1A1A
color DASH_DIM = dashIsDark ? #999999 : #666666
color DASH_FRAME = dashIsDark ? #FFFFFF : #4A4A4A
color DASH_HDR = dashIsDark ? COGNITIVE_BLUE : #4A7AE0

dashPos_resolved = dashPos == 'Top Right' ? position.top_right : dashPos == 'Top Center' ? position.top_center : dashPos == 'Top Left' ? position.top_left : dashPos == 'Middle Right' ? position.middle_right : dashPos == 'Middle Center' ? position.middle_center : dashPos == 'Middle Left' ? position.middle_left : dashPos == 'Bottom Right' ? position.bottom_right : dashPos == 'Bottom Center' ? position.bottom_center : position.bottom_left

size_hdr = i_dash_size == 'Large' ? size.large : i_dash_size == 'Normal' ? size.normal : i_dash_size == 'Small' ? size.normal : size.small
size_val = i_dash_size == 'Large' ? size.large : i_dash_size == 'Normal' ? size.normal : i_dash_size == 'Small' ? size.small : size.tiny
size_lbl = i_dash_size == 'Large' ? size.normal : i_dash_size == 'Normal' ? size.small : i_dash_size == 'Small' ? size.small : size.tiny

var table dash = na
if barstate.islast and dashboardMode != 'Off'
    if na(dash)
        dash := table.new(dashPos_resolved, 2, 5, bgcolor = DASH_BG, frame_color = DASH_FRAME, frame_width = 2, border_width = 1, border_color = DIVIDER)
        dash
    table.cell(dash, 0, 0, 'MOMENTUM MAP LITE', bgcolor = DASH_HDR, text_color = DASH_TEXT, text_size = size_hdr)
    table.cell(dash, 1, 0, 'v1.0.0', bgcolor = DASH_HDR, text_color = DASH_TEXT, text_size = size_val)
    table.cell(dash, 0, 1, 'Rotation', text_color = DASH_DIM, text_size = size_lbl, bgcolor = DASH_BG)
    table.cell(dash, 1, 1, rotLabel, text_color = rotColor, text_size = size_val, bgcolor = DASH_BG)
    table.cell(dash, 0, 2, 'Strongest', text_color = DASH_DIM, text_size = size_lbl, bgcolor = DASH_BG)
    table.cell(dash, 1, 2, str.tostring(math.round(strongest, 1)), text_color = BULLISH_GREEN, text_size = size_val, bgcolor = DASH_BG)
    table.cell(dash, 0, 3, 'Weakest', text_color = DASH_DIM, text_size = size_lbl, bgcolor = DASH_BG)
    table.cell(dash, 1, 3, str.tostring(math.round(weakest, 1)), text_color = BEARISH_RED, text_size = size_val, bgcolor = DASH_BG)
    table.cell(dash, 0, 4, '🔓 Lite · PrimeFold', text_color = DASH_DIM, text_size = size.tiny, bgcolor = DASH_BG)
    table.cell(dash, 1, 4, '', text_color = DASH_DIM, text_size = size.tiny, bgcolor = DASH_BG)

// ============================================================================
// CHANGELOG
// ============================================================================
//
// v1.0.0 (2026-03-21) — INITIAL FREE-TIER RELEASE
//   - Quad stochastics: K=9/14/40/60 with D-line smoothing (core from v1.3.1).
//   - Rotation count: bullish/bearish alignment tally (X/4).
//   - Four D-line oscillator plots in separate pane.
//   - Background shading: green (4/4 bull), red (4/4 bear).
//   - Dashboard: header, rotation, strongest, weakest, footer.
//   - Non-repaint: barstate.isconfirmed gates on bgcolor.
//   - EXCLUDED: alerts, entry/exit signals, divergence, bridge schema, strategy.
//
// v1.0.1 (2026-04-02) — ALIGNMENT FIX
//   - Signal threshold changed from >= 3 to >= 4 (all 4 stochastics must agree).
//   - Matches Python backtest engine and v3 validated data.
//
// Full rotation signals, alerts, and divergence detection are excluded from this free tier.
// ============================================================================

//               /\        N
//              /  \       |
//         /\  /    \  W --+-- E
//        /  \/      \     |
//       /____________\    S
//        TOOLS THAT THINK.
//     SYSTEMS THAT SCALE.
//  DECISIONS THAT COMPOUND.
//  -------------------------------------------
````
