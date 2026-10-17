# Trend Momentum (Algionics) - Ribbon Pressure Field

- url: https://www.tradingview.com/script/gidoT7f9-Trend-Momentum-Algionics-Ribbon-Pressure-Field/
- type: indicator
- pine_id: PUB;091f0117449f4a76a3d0c70983a98527
- version: 1.0

## Description

Trend Momentum interprets a 28-line EMA ribbon field as a physical force landscape. It reads what directional pressure price is under, how strong that pressure is, and what the current market state is, all within a single framework.

The ribbon spans periods 20 to 236 in steps of 8. Each line is not a simple EMA. It passes through a multi-stage smoothing kernel:
[pine]f_rb(int len) =>
    float ama = (ta.ema(src, len) + ta.sma(src, len)) / 2
    int k = int(math.ceil(len * 0.08))
    float kl = ta.ema(ama, k)
    (kl + ta.sma(kl, k + 2)) / 2[/pine]
The average of EMA and SMA is computed first, then a secondary smoothing pass is applied using a kernel length equal to 8 percent of the original period. This dual-smoothing structure suppresses both the phase lag of a pure EMA and the ripple noise of a pure SMA simultaneously. Because the kernel ratio scales proportionally with the period, short lines and long lines maintain consistent smoothing characteristics across the entire ribbon.


[i][b]Force Boundary[/b][/i]
The histogram plots Bull Force above the zero line and Bear Force below it.
[pine]float bullForce = math.max(v001 - rb_min, 0.0)
float bearForce = math.min(v001 - rb_max, 0.0)[/pine]
Bull Force is the distance from price to the bottom edge of the field. Bear Force is the distance from price to the top edge. When price is inside the field, both are active. When price breaks above, Bear Force converges to zero. When price drops below, Bull Force converges to zero.

The space between them defines the force boundary. When the boundary widens, price is moving away from the field edges. When it narrows, price is returning toward the center.


[pine][b]Pressure Ratio[/b][/pine]
Where Force Boundary measures raw displacement between price and the field edges, Pressure Ratio measures the internal pressure distribution within the field.
float bp_a = math.max(v001-v020,0)+math.max(v001-v028,0)+math.max(v001-[pine]v036,0)+math.max(v001-v044,0)+...
float total_p = bull_pressure + bear_pressure
float bull_dom = total_p > 0 ? (bull_pressure / total_p) * 100.0 : 50.0[/pine]
For each of the 28 lines, the distance from price is measured individually. Lines below price contribute to bull pressure. Lines above contribute to bear pressure. Both sides are summed independently, then the ratio is computed.

This is not a simple count of how many lines are above or below. A line 10 points below price contributes 10 times more bull pressure than a line 1 point below. The ratio reflects both the number of lines favoring each side and how far they are from price.

At 100, every line sits below price. At 0, every line sits above. At 50, the total upward and downward distances are equal.


[pine][b]Bias Line[/b][/pine]
The Bias Line sits inside the force boundary. Its position is determined by the pressure ratio.
[pine]float biasLine = bearForce + (bullForce - bearForce) * (bull_dom / 100.0)[/pine]
It divides the space between Bull Force and Bear Force using the pressure ratio as a positioning weight. A 73 percent bull reading does not place the line at 73 percent of the field. It places the line at 73 percent of the distance between Bear Force and Bull Force at that moment.

The Bias Line responds to two independent inputs: how far the field edges are from price, and how the internal pressure is distributed. The separation between boundary logic and positioning logic is the structural core of this design.

The color follows a gradient based on its position within the force boundary.

[i][b]Ribbon Overlay[/b][/i]
The ribbon draws two boundary lines on the price chart. The upper line marks the highest value across the field. The lower line marks the lowest.

Each boundary changes color independently based on price crossovers. When price crosses above a boundary, it turns bull color. When price crosses below, it turns bear color. The moment both boundaries switch to the same color confirms that price has moved fully to one side of the field.

A gradient fill appears between price and the nearest boundary, fading as price moves away from the edge.


[i][b]Price Candles[/b][/i]
When enabled, candles on the main chart are colored based on where the Bias Line sits within the force boundary.
[pine]float sig_pos = tm_range > 0 ? ((biasLine - bearForce) / tm_range) * 2.0 - 1.0 : 0.0
color candle_col = color.from_gradient(sig_pos, -1.0, 1.0, C_BEAR, C_BULL)[/pine]
The Bias Line position is converted to a scale from minus 1 to plus 1, then mapped to a color gradient. Bear color at the bottom, bull color at the top.

This coloring reflects pressure balance, not price direction. A rising candle with bear coloring means price moved up but field pressure remains tilted to the downside. When candle color and price direction disagree, the field is telling a different story than the bar itself.


[i][b]Dashboard[/b][/i]

[b]BIAS[/b]
Displays bull and bear pressure percentages. Each value updates with a directional arrow indicating whether the percentage increased or decreased from the previous bar. A segment bar provides a visual representation of the pressure distribution.


[b]Flow[/b]
Tracks whether the dominant pressure is accelerating or decelerating. It compares the current pressure percentage against its own smoothed average.
[pine]float bias_smooth = ta.ema(bull_dom, GM_LEN)[/pine]
The smoothing length is derived as the geometric mean of the ribbon endpoints:
[pine]int GM_LEN = int(math.round(math.sqrt(float(START_P) * float(END_P))))[/pine]

No arbitrary period. A natural interaction scale derived from the ribbon structure.

When the percentage is above its average, the label reads Rising. When below, Falling. When pressure reaches full saturation, Maxed.


[b]Status[/b]
A four-state market condition classifier.

Trend activates when price moves outside the field entirely. Hold activates when the dominant side remains intact but price is inside the field. Weakening activates when the dominant side still leads but its pressure is declining. Reversal Warning activates when price crosses the center of mass to the opposing side.

The state engine uses two mechanisms. A trend latch and a condition matrix.
[pine]if bull_dom >= 100
    is_bull := true
if bull_dom <= 0
    is_bull := false[/pine]
The latch sets only when the pressure ratio touches either extreme. It does not reset at any intermediate value. It only changes at the next full saturation on the opposite side. 100 and 0 are mathematical boundaries. 50 is the equilibrium point where upward and downward pressure are equal. There is no arbitrary threshold in this system.

The natural state progression is Trend to Hold to Weakening to Reversal Warning. When states skip steps, for example jumping from Trend directly to Reversal Warning, it signals a sharp shift in pressure. The faster the sequence moves, the less time available to react.


[b]Trend[/b]
Confirms the established directional bias. It reads Bull when the last confirmed extreme was at full bullish saturation, and Bear when at full bearish saturation. The direction holds until the opposite extreme is reached.


[b]Note[/b]
A one-line contextual summary tied to the active status. Each of the four states has its own message describing the current condition and what to watch for.


[i][b]Technical Implementation[/b][/i]

[b]Ribbon Kernel Structure[/b]
Each ribbon line is not a simple EMA. The EMA-SMA average serves as a first-stage compromise between exponential responsiveness and rectangular stability. The secondary kernel, scaled to 8 percent of the input period, applies consistent proportional smoothing across the entire ribbon. Short-period lines receive short kernels. Long-period lines receive long kernels. The noise suppression ratio remains uniform regardless of where a line sits in the ribbon.


[b]Distance-Weighted Pressure Measurement[/b]
Conventional ribbon-based indicators measure strength as the count of lines above or below price divided by the total number of lines. This approach treats every line equally. A line barely below price and a line far below price contribute the same.

This engine converts the absolute distance to each line into pressure. A line 10 points below price contributes 10 times more bull pressure than a line 1 point below. Because this distance weighting is embedded in the ratio, the system reads the pressure gradient inside the field, which a simple count cannot capture.


[b]Dual Separation Architecture[/b]
Force Boundary and Pressure Ratio are computed independently. Force Boundary measures only the raw displacement between price and the field edges. Pressure Ratio measures only the distance-weighted sum across all 28 individual lines.

The Bias Line is the sole point where these two independent inputs converge. The boundary defines the range of possible positions. The pressure ratio determines the position within that range. A change in one does not affect the calculation of the other.


[b]Latch-Based State Engine[/b]
State transitions are driven by mathematical extremes, not arbitrary thresholds. The latch sets only at 100 (all lines below price) or 0 (all lines above price). These are physical limits of the distribution, not chosen values.

50 is the point where the sum of upward distances exactly equals the sum of downward distances. The condition matrix uses only these three structural boundaries: 0, 50, and 100.


[b]Interlocking Constant Architecture[/b]
Every parameter in this system branches from a single root:
[pine]int START_P = 20
int END_P   = 236[/pine]
From these two constants the 28-line ribbon is defined, and from that ribbon: Force Boundary, Pressure Ratio, Bias Line, Flow smoothing length, and every boundary in the state engine are all derived. The smoothing length used for Flow is the geometric mean of the two endpoints. The state classification boundaries of 0, 50, and 100 derive directly from the mathematical limits of the pressure distribution.

Change one constant and the ribbon structure shifts, the field boundaries move, the pressure distribution recalculates, and every downstream output cascades accordingly.


[b]Settings[/b]
[b]Ribbon Overlay:[/b] 
displays the upper and lower field boundaries on the price chart with color-coded crossover states.

[b]Price Candles:[/b]
colors candles on the main chart based on the Bias Line position within the force boundary.

[b]Dashboard:[/b] 
shows the status panel with BIAS percentages, segment bar, Flow, Status classification, Trend direction, and Note.

[b]Force Boundary:[/b]
plots the Bull Force and Bear Force histogram in the indicator pane.

[b]Bias Line:[/b]
plots the pressure-weighted position line inside the force boundary.

[b]Position Point: [/b]
marks the current Bias position on the last bar.

## Source Code

````pine
//@version=6
indicator("Trend Momentum (Algionics)", format=format.price, precision=2, overlay=false)

// ------------------------------------------------------------------------------------------------
// [Block 0] Constants & Settings
// ------------------------------------------------------------------------------------------------
bool show_ribbon    = input.bool(true, "Ribbon Overlay",   tooltip="Displays the ribbon envelope on the price chart.", group="Display")
bool show_candles   = input.bool(true, "Price Candles",    tooltip="Colors price candles based on the bias position within the force boundary.", group="Display")
bool show_dash      = input.bool(true, "Dashboard",        tooltip="Shows the status dashboard with bias reading, trend direction, and market state.", group="Display")
bool show_histogram = input.bool(true, "Force Boundary",   tooltip="Plots the bull and bear force boundaries derived from price distance to the ribbon edges.", group="Display")
bool show_bias      = input.bool(true, "Bias Line",        tooltip="Plots the bias line within the force boundary. Position is determined by the 28-line pressure ratio.", group="Display")
bool show_dot       = input.bool(true, "Position Point",   tooltip="Marks the current bias position on the last bar.", group="Display")

color C_BULL    = input.color(#0b7788, "Bull", group="Color Settings", inline="main")
color C_BEAR    = input.color(#9f0808, "Bear", group="Color Settings", inline="main")
color C_BIAS_HI = input.color(#00E5FF, "Bias", group="Color Settings", inline="bias")
color C_BIAS_LO = input.color(#FF1744, "",     group="Color Settings", inline="bias")

int START_P = 20
int END_P   = 236
int GM_LEN  = int(math.round(math.sqrt(float(START_P) * float(END_P))))

series float src = close

f_is_light() =>
    color c = chart.bg_color
    (0.2126 * color.r(c) / 255.0 + 0.7152 * color.g(c) / 255.0 + 0.0722 * color.b(c) / 255.0) > 0.5

bool is_light = f_is_light()

color C_ZERO    = is_light ? color.new(color.black, 50) : color.new(color.gray, 50)
color C_DASH_BG  = is_light ? color.new(color.white, 100) : color.new(color.black, 100)
color C_DASH_TXT = is_light ? color.black : color.white
color C_DASH_HDR = is_light ? color.rgb(80, 80, 80) : color.gray
color C_INACTIVE = is_light ? color.new(color.gray, 70) : color.new(color.gray, 70)
color C_ACTIVE_BG = is_light ? color.new(color.gray, 80) : color.new(color.white, 85)

int SEG_ALPHA_VIVID = 50
int SEG_ALPHA_FADED = 75
int SEG_ALPHA_OFF   = 98

f_seg_bull_alpha(int i, int bullSegs) =>
    int distFromCenter = 9 - i
    float t = float(distFromCenter) / float(math.max(bullSegs - 1, 1))
    float ease = math.cos(t * math.pi * 0.5)
    int alpha = SEG_ALPHA_VIVID + int(ease * (SEG_ALPHA_FADED - SEG_ALPHA_VIVID))
    alpha

f_seg_bear_alpha(int i, int bearSegs) =>
    float t = float(i) / float(math.max(bearSegs - 1, 1))
    float ease = math.cos(t * math.pi * 0.5)
    int alpha = SEG_ALPHA_VIVID + int(ease * (SEG_ALPHA_FADED - SEG_ALPHA_VIVID))
    alpha

// ------------------------------------------------------------------------------------------------
// [Block 1] Ribbon
// ------------------------------------------------------------------------------------------------
f_rb(int len) =>
    float ama = (ta.ema(src, len) + ta.sma(src, len)) / 2
    int k = int(math.ceil(len * 0.08))
    float kl = ta.ema(ama, k)
    (kl + ta.sma(kl, k + 2)) / 2

float v001 = f_rb(1)
float v020 = f_rb(20),  float v028 = f_rb(28),  float v036 = f_rb(36),  float v044 = f_rb(44)
float v052 = f_rb(52),  float v060 = f_rb(60),  float v068 = f_rb(68),  float v076 = f_rb(76)
float v084 = f_rb(84),  float v092 = f_rb(92),  float v100 = f_rb(100), float v108 = f_rb(108)
float v116 = f_rb(116), float v124 = f_rb(124), float v132 = f_rb(132), float v140 = f_rb(140)
float v148 = f_rb(148), float v156 = f_rb(156), float v164 = f_rb(164), float v172 = f_rb(172)
float v180 = f_rb(180), float v188 = f_rb(188), float v196 = f_rb(196), float v204 = f_rb(204)
float v212 = f_rb(212), float v220 = f_rb(220), float v228 = f_rb(228), float v236 = f_rb(236)

// ------------------------------------------------------------------------------------------------
// [Block 2] Boundaries
// ------------------------------------------------------------------------------------------------
float rb_max = math.max(math.max(math.max(v020,v028,v036,v044,v052,v060), math.max(v068,v076,v084,v092,v100,v108)), math.max(math.max(v116,v124,v132,v140,v148,v156), math.max(math.max(v164,v172,v180,v188,v196,v204), math.max(v212,v220,v228,v236))))
float rb_min = math.min(math.min(math.min(v020,v028,v036,v044,v052,v060), math.min(v068,v076,v084,v092,v100,v108)), math.min(math.min(v116,v124,v132,v140,v148,v156), math.min(math.min(v164,v172,v180,v188,v196,v204), math.min(v212,v220,v228,v236))))

// ------------------------------------------------------------------------------------------------
// [Block 3] Pressure + BIAS
// ------------------------------------------------------------------------------------------------
float bp_a = math.max(v001-v020,0)+math.max(v001-v028,0)+math.max(v001-v036,0)+math.max(v001-v044,0)+math.max(v001-v052,0)+math.max(v001-v060,0)+math.max(v001-v068,0)
float bp_b = math.max(v001-v076,0)+math.max(v001-v084,0)+math.max(v001-v092,0)+math.max(v001-v100,0)+math.max(v001-v108,0)+math.max(v001-v116,0)+math.max(v001-v124,0)
float bp_c = math.max(v001-v132,0)+math.max(v001-v140,0)+math.max(v001-v148,0)+math.max(v001-v156,0)+math.max(v001-v164,0)+math.max(v001-v172,0)+math.max(v001-v180,0)
float bp_d = math.max(v001-v188,0)+math.max(v001-v196,0)+math.max(v001-v204,0)+math.max(v001-v212,0)+math.max(v001-v220,0)+math.max(v001-v228,0)+math.max(v001-v236,0)
float bull_pressure = bp_a + bp_b + bp_c + bp_d

float sp_a = math.max(v020-v001,0)+math.max(v028-v001,0)+math.max(v036-v001,0)+math.max(v044-v001,0)+math.max(v052-v001,0)+math.max(v060-v001,0)+math.max(v068-v001,0)
float sp_b = math.max(v076-v001,0)+math.max(v084-v001,0)+math.max(v092-v001,0)+math.max(v100-v001,0)+math.max(v108-v001,0)+math.max(v116-v001,0)+math.max(v124-v001,0)
float sp_c = math.max(v132-v001,0)+math.max(v140-v001,0)+math.max(v148-v001,0)+math.max(v156-v001,0)+math.max(v164-v001,0)+math.max(v172-v001,0)+math.max(v180-v001,0)
float sp_d = math.max(v188-v001,0)+math.max(v196-v001,0)+math.max(v204-v001,0)+math.max(v212-v001,0)+math.max(v220-v001,0)+math.max(v228-v001,0)+math.max(v236-v001,0)
float bear_pressure = sp_a + sp_b + sp_c + sp_d

float total_p = bull_pressure + bear_pressure
float bull_dom = total_p > 0 ? (bull_pressure / total_p) * 100.0 : 50.0

float bullForce = math.max(v001 - rb_min, 0.0)
float bearForce = math.min(v001 - rb_max, 0.0)
float biasLine  = bearForce + (bullForce - bearForce) * (bull_dom / 100.0)

// ------------------------------------------------------------------------------------------------
// [Block 4] Smooth + Status + Flow
// ------------------------------------------------------------------------------------------------
float bias_smooth = ta.ema(bull_dom, GM_LEN)

var bool is_bull   = true
var bool trend_set = false

if bull_dom >= 100
    is_bull   := true
    trend_set := true
if bull_dom <= 0
    is_bull   := false
    trend_set := true

bool outside = bull_dom >= 100 or bull_dom <= 0
bool falling = bull_dom < nz(bull_dom[1])
bool rising  = bull_dom > nz(bull_dom[1])

int g_status = 2
bool g_is_bull = is_bull

if outside
    g_status := 1
else if is_bull
    if bull_dom > 50 and falling
        g_status := 3
    else if bull_dom > 50
        g_status := 2
    else
        g_status := 4
else
    if bull_dom < 50 and rising
        g_status := 3
    else if bull_dom < 50
        g_status := 2
    else
        g_status := 4

string flow_label = bias_smooth >= 50 ? (bull_dom >= 100 ? "Bull Maxed" : bull_dom > bias_smooth ? "Bull Rising ▲" : "Bull Falling ▼") : (bull_dom <= 0 ? "Bear Maxed" : bull_dom < bias_smooth ? "Bear Rising ▲" : "Bear Falling ▼")
color flow_c = bull_dom >= 50 ? C_BULL : C_BEAR

// ------------------------------------------------------------------------------------------------
// [Block 5] Histogram + Bias + Candles
// ------------------------------------------------------------------------------------------------
color bias_col = show_bias ? color.from_gradient(biasLine, bearForce, bullForce, C_BIAS_LO, C_BIAS_HI) : na

pBull = plot(show_histogram ? bullForce : na, "Bull Force", color=color.new(C_BULL, 0), linewidth=1)
pBear = plot(show_histogram ? bearForce : na, "Bear Force", color=color.new(C_BEAR, 0), linewidth=1)
pBias = plot(show_bias ? biasLine : na, "Bias", color=bias_col, linewidth=2)
pZero = plot(0.0, display=display.none, editable=false)

fill(pBull, pZero, bullForce, 0.0, color.new(C_BULL, 80), color.new(C_BULL, 100))
fill(pZero, pBear, 0.0, bearForce, color.new(C_BEAR, 100), color.new(C_BEAR, 80))
hline(0, "Zero", color=C_ZERO, linestyle=hline.style_dotted)

var label bias_dot = na
if barstate.islast and show_dot
    label.delete(bias_dot)
    bias_dot := label.new(bar_index, biasLine, "●", color=color.new(color.white, 100), textcolor=bias_col, style=label.style_label_center, size=size.large)

float tm_range = bullForce - bearForce
float sig_pos  = tm_range > 0 ? ((biasLine - bearForce) / tm_range) * 2.0 - 1.0 : 0.0
color candle_col = show_candles ? color.from_gradient(sig_pos, -1.0, 1.0, C_BEAR, C_BULL) : na

plotcandle(show_candles ? open : na, show_candles ? high : na, show_candles ? low : na, show_candles ? close : na, title="Price Candles", color=candle_col, wickcolor=candle_col, bordercolor=candle_col, force_overlay=true)

// ------------------------------------------------------------------------------------------------
// [Block 6] Ribbon Overlay
// ------------------------------------------------------------------------------------------------
var bool ub = true
var bool lb = true
if ta.crossover(v001, rb_max)
    ub := true
if ta.crossunder(v001, rb_max)
    ub := false
if ta.crossover(v001, rb_min)
    lb := true
if ta.crossunder(v001, rb_min)
    lb := false

color uc = ub ? C_BULL : C_BEAR
color lc = lb ? C_BULL : C_BEAR
float v001c = math.max(math.min(v001, rb_max), rb_min)
float rng   = rb_max - rb_min

p_up = plot(show_ribbon ? rb_max : na, "Ribbon Upper Boundary", color=uc, force_overlay=true)
p_cl = plot(show_ribbon ? v001c : na,  "Ref",   display=display.none, editable=false, force_overlay=true)
p_lo = plot(show_ribbon ? rb_min : na, "Ribbon Lower Boundary", color=lc, force_overlay=true)

fill(p_cl, p_lo, rb_min + rng * 0.35, rb_min, color.new(lc, 100), color.new(lc, 80))
fill(p_up, p_cl, rb_max, rb_max - rng * 0.35, color.new(uc, 80), color.new(uc, 100))

// ------------------------------------------------------------------------------------------------
// [Block 7] Dashboard
// ------------------------------------------------------------------------------------------------
var table dash = table.new(position.bottom_right, 24, 6, bgcolor=C_DASH_BG, border_width=0)

if show_dash
    string side_txt = g_is_bull ? "Bull" : "Bear"
    float bias_bear_raw = 100.0 - bull_dom

    string bias_bull_arrow = bull_dom > nz(bull_dom[1]) ? " ▲" : bull_dom < nz(bull_dom[1]) ? " ▼" : ""
    string bias_bear_arrow = bias_bear_raw > nz(bias_bear_raw[1]) ? " ▲" : bias_bear_raw < nz(bias_bear_raw[1]) ? " ▼" : ""

    int b_seg = int(math.round(bull_dom / 10.0))
    int s_seg = int(math.round(bias_bear_raw / 10.0))

    table.cell(dash, 0, 0, "", text_size=size.small)
    table.cell(dash, 1, 0, "Bullish", text_color=C_BULL, text_size=size.small, text_halign=text.align_center)
    table.merge_cells(dash, 1, 0, 11, 0)
    table.cell(dash, 12, 0, "Bearish", text_color=C_BEAR, text_size=size.small, text_halign=text.align_center)
    table.merge_cells(dash, 12, 0, 22, 0)
    table.cell(dash, 23, 0, "Flow", text_color=C_DASH_HDR, text_size=size.small)

    table.cell(dash, 0, 1, "BIAS", text_color=C_DASH_HDR, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(bull_dom, "0.0") + "%" + bias_bull_arrow, text_color=C_BULL, text_size=size.small, text_halign=text.align_left)
    for i = 0 to 9
        bool active = (9 - i) < b_seg
        int alpha = active ? f_seg_bull_alpha(i, b_seg) : SEG_ALPHA_OFF
        table.cell(dash, 2 + i, 1, " ", text_size=size.small, bgcolor=color.new(C_BULL, alpha))
    for i = 0 to 9
        bool active = i < s_seg
        int alpha = active ? f_seg_bear_alpha(i, s_seg) : SEG_ALPHA_OFF
        table.cell(dash, 12 + i, 1, " ", text_size=size.small, bgcolor=color.new(C_BEAR, alpha))
    table.cell(dash, 22, 1, str.tostring(bias_bear_raw, "0.0") + "%" + bias_bear_arrow, text_color=C_BEAR, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 23, 1, flow_label, text_color=flow_c, text_size=size.small, text_halign=text.align_center)

    table.cell(dash, 0, 2, "", text_size=size.tiny)
    table.cell(dash, 1, 2, "", text_size=size.tiny)
    table.merge_cells(dash, 1, 2, 23, 2)

    table.cell(dash, 0, 3, "STATUS", text_color=C_DASH_HDR, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 0, 4, "", text_size=size.small)

    bool a1 = g_status == 1
    table.cell(dash, 1, 3, a1 ? side_txt + " Trend" : "Trend", text_color=a1 ? C_DASH_TXT : C_INACTIVE, text_size=size.small, bgcolor=a1 ? C_ACTIVE_BG : C_DASH_BG, text_halign=text.align_center)
    table.merge_cells(dash, 1, 3, 11, 3)

    bool a2 = g_status == 2
    table.cell(dash, 12, 3, a2 ? side_txt + " Hold" : "Hold", text_color=a2 ? C_DASH_TXT : C_INACTIVE, text_size=size.small, bgcolor=a2 ? C_ACTIVE_BG : C_DASH_BG, text_halign=text.align_center)
    table.merge_cells(dash, 12, 3, 22, 3)
    bool a3 = g_status == 3
    table.cell(dash, 1, 4, a3 ? side_txt + " Weakening" : "Weakening", text_color=a3 ? C_DASH_TXT : C_INACTIVE, text_size=size.small, bgcolor=a3 ? C_ACTIVE_BG : C_DASH_BG, text_halign=text.align_center)
    table.merge_cells(dash, 1, 4, 11, 4)

    string rev_side = g_is_bull ? "Bear" : "Bull"
    bool a4 = g_status == 4
    table.cell(dash, 12, 4, a4 ? rev_side + " Reversal Warning" : "Reversal Warning", text_color=a4 ? C_DASH_TXT : C_INACTIVE, text_size=size.small, bgcolor=a4 ? C_ACTIVE_BG : C_DASH_BG, text_halign=text.align_center)
    table.merge_cells(dash, 12, 4, 22, 4)

    table.cell(dash, 23, 3, "Trend", text_color=C_DASH_HDR, text_size=size.small, text_halign=text.align_center)
    string trend_dir = g_is_bull ? "Bull ▲" : "Bear ▼"
    color trend_dir_c = g_is_bull ? C_BULL : C_BEAR
    table.cell(dash, 23, 4, trend_dir, text_color=trend_dir_c, text_size=size.small, text_halign=text.align_center)

    string note = switch g_status
        1 => side_txt + " in full control. Price outside ribbon — trend confirmed."
        2 => side_txt + " trend intact. Inside ribbon, holding position."
        3 => side_txt + " momentum fading. Pullback deepening — stay alert."
        => "Price crossed center of mass. Potential trend shift — manage risk."

    color note_c = C_DASH_TXT

    table.cell(dash, 0, 5, "NOTE", text_color=C_DASH_HDR, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, note, text_color=note_c, text_size=size.small, text_halign=text.align_left)
    table.merge_cells(dash, 1, 5, 23, 5)
````
