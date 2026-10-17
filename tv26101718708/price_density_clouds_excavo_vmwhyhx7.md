# Price Density Clouds [EXCAVO]

- url: https://www.tradingview.com/script/vMWHYHX7-Price-Density-Clouds-EXCAVO/
- type: indicator
- pine_id: PUB;702620b9f32848418a09a48b1fc3831f
- version: 1.0

## Description

Continuous Kernel-Density Map of Where Price Has Actually Traded

The [i]Price Density Clouds[/i] builds a smooth, continuous probability density of
price over a lookback window and paints it as gradient clouds directly behind
the candles. Dense, saturated clouds mark value zones - the equilibrium levels
where the market has spent the most time and where price tends to stall and
revert. Thin, transparent gaps mark inefficiency zones - levels price travels
through quickly. A dashed POC line marks the single highest-probability price,
and the Value Area High / Low bracket the core of the distribution.

This is not a bin-based volume profile. Instead of chopping price into discrete
buckets, KDE sums a smooth gaussian kernel around every price point, producing a
continuous density curve with no bin-edge artefacts. The bandwidth is set
automatically by Silverman's rule, so the smoothing adapts to the instrument's
own volatility.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ HOW TO USE[/b]

[b]Step 1[/b]  →  Add the indicator. Gradient clouds appear behind the candles
              over the lookback window, brightest at the highest-probability
              levels and fading out toward thin zones.
[b]Step 2[/b]  →  Read the clouds. Saturated bands = value / equilibrium where
              price tends to stall and mean-revert. Faint gaps = inefficiency
              where price moves fast - natural travel targets.
[b]Step 3[/b]  →  Use the POC. The dashed POC line is the single most-traded
              level - a robust magnet and support / resistance anchor. Price
              far from POC has a statistical pull back toward it.
[b]Step 4[/b]  →  Use the Value Area. The dotted Value Area High / Low bracket
              the core of the distribution (default 70%). Acceptance inside the
              area is balance; rejection outside it is imbalance worth trading.
[b]Step 5[/b]  →  Check the side profile. The gradient density profile on the
              right of the last bar is the same density rotated 90 degrees - a
              quick read of the full distribution shape at a glance.
[b]Step 6[/b]  →  Combine with structure. Clouds are context, not direction.
              They pair well with trend, sweep, and breakout tools - a breakout
              into a thin zone tends to run; a breakout into a dense zone tends
              to stall.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ HOW IT CALCULATES[/b]

[b]◆  Gaussian Kernel Density[/b]
Every close in the lookback window contributes a gaussian bell curve centred at
its own price. The curves are summed across the price range to produce a single
continuous density function: density(x) = sum over j of exp(-0.5 x ((x - price_j)
/ h)^2). Levels where many bars cluster get tall, overlapping kernels and a high
density; isolated levels get a low density.

[b]◆  Silverman Bandwidth[/b]
The kernel width h controls smoothness. It is set automatically by Silverman's
rule of thumb: h = 1.06 x sigma x n^(-1/5), where sigma is the stdev of the
lookback prices and n is the sample size. The Bandwidth Multiplier input scales
this for sharper or smoother clouds. Auto-bandwidth means the same settings
adapt across instruments and timeframes.

[b]◆  Normalisation and POC[/b]
The density is evaluated at Resolution levels between the lookback high and low,
then normalised so the peak equals 1.0. That peak level is the POC (Point of
Control) - the single highest-probability price. Cloud opacity and colour are
driven by each level's normalised density.

[b]◆  Value Area[/b]
Starting at the POC, the algorithm expands outward, each step absorbing the
denser of the two neighbouring levels, until the enclosed density reaches the
Value Area % of the total (default 70). The price extent reached becomes the
Value Area High and Low.

[b]◆  Gradient Rendering[/b]
Each density band of the cloud is drawn as a horizontal box tinted by a
two-colour gradient: the Low Density Color at thin levels through to the High
Density Color at the POC, with opacity ramping in parallel. Adjacent bands tile
continuously, so the cloud reads as a smooth heat-map rather than discrete
blocks. The same gradient drives the right-side density profile, whose width
per level scales with density - at the default resolution the edge reads as a
near-smooth wave while keeping the per-level gradient colour.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ WHAT MAKES IT DIFFERENT[/b]

[b]◆  Continuous Density, Not Bins[/b]
Standard volume / price profiles split price into discrete bins, so the result
depends heavily on bin size and shows hard edges. KDE produces a smooth
continuous curve - no bin-edge artefacts, no arbitrary bucket count, just the
true shape of where price has traded.

[b]◆  Auto-Adaptive Bandwidth[/b]
Silverman's rule sizes the smoothing from the instrument's own volatility and
sample size. The clouds stay meaningful on BTC, EURUSD, gold or an index with
the same default settings.

[b]◆  Value Structure In One View[/b]
POC, Value Area High / Low and the full density shape are all on the chart at
once, with a matching side profile - the complete market-profile read without a
separate pane or a session reset.

[b]◆  Premium Gradient Visual[/b]
A smooth two-colour density gradient behind the candles with parallel opacity
ramp, a clean dashed POC, dotted value-area lines, and a right-side profile
histogram. The clouds sit behind price as context and never clutter the read.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ DASHBOARD[/b]

Real-time panel (top right) with the current value read:
[list]
[*][b]POC[/b] - price of the highest-density level
[*][b]Value Area High[/b] - upper bound of the value area
[*][b]Value Area Low[/b] - lower bound of the value area
[*][b]Price Zone[/b] - whether price is Above Value, In Value, or Below Value
[*][b]Lookback[/b] - bars used to build the distribution
[/list]

Legend table (bottom left) explains every colour. Both panels toggle in the
Dashboard settings.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ SETTINGS[/b]

[b]Engine[/b]
[list]
[*][b]Lookback Period[/b] - 200 (bars used to build the price distribution)
[*][b]Resolution[/b] - 120 (number of horizontal density bands; higher = smoother gradient and profile edge, up to 200)
[*][b]Bandwidth Multiplier[/b] - 1.0 (smoothness; 1.0 = Silverman auto, higher = broader clouds)
[*][b]Value Area %[/b] - 70 (percentage of total density that defines the value area)
[/list]

[b]Visualization[/b]
[list]
[*][b]Low Density Color[/b] - blue (thin / inefficiency end of the gradient)
[*][b]High Density Color[/b] - orange (dense / value end of the gradient)
[*][b]POC Line Color[/b] - near-white (high contrast against the dense orange cloud the POC sits in)
[*][b]Min Cloud Opacity[/b] - 8 (opacity of the lowest-density band; keeps empty zones faint)
[*][b]Max Cloud Opacity[/b] - 65 (opacity of the POC band)
[*][b]Show POC Line[/b] - ON
[*][b]Show Value Area[/b] - ON (dotted Value Area High / Low lines)
[*][b]Value Area Highlight[/b] - ON (boosts band opacity inside the value area so the 70% core pops)
[*][b]Show Side Profile[/b] - ON
[*][b]Profile Outline[/b] - ON (thin bright line tracing the right edge of the profile for a crisp silhouette)
[*][b]Cloud Forward Extend[/b] - 10 (bars the clouds extend right of the last bar)
[/list]

[b]Dashboard[/b]
[list]
[*][b]Show Dashboard[/b] - ON
[*][b]Dashboard Position[/b] - Top Right
[*][b]Show Legend[/b] - ON
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Best regards,
EXCAVO

[quote]
[b]Disclaimer[/b]
Trading involves significant risk. This indicator is a technical analysis tool
and does not constitute financial advice, investment recommendations, or a
guarantee of future results. Past indicator behavior does not guarantee future
performance. Always use proper risk management and your own judgment.
[/quote]

## Source Code

````pine
// (c) EXCAVO
// This work is licensed under Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
//
// Price Density Clouds [EXCAVO]
// -----------------------------------------------------------------------------
// Continuous Kernel Density Estimation of price over a lookback window. Builds
// a smooth probability density of where price has traded (gaussian kernels,
// Silverman bandwidth) and paints it as gradient clouds behind the candles -
// dense clouds are value / equilibrium zones, transparent gaps are
// inefficiency zones price tends to travel through quickly. POC, Value Area
// High / Low and a right-side density profile complete the read.
//
//@version=6
indicator("Price Density Clouds [EXCAVO]", "EXCAVO Price Density Clouds",
     overlay              = true,
     max_boxes_count      = 500,
     max_lines_count      = 500,
     max_labels_count     = 500,
     max_polylines_count  = 10,
     max_bars_back        = 5000)

//-----------------------------------------------------------------------------}
// Inputs
//-----------------------------------------------------------------------------{
string GRP_ENG  = "Engine"
string GRP_VIZ  = "Visualization"
string GRP_DASH = "Dashboard"

int   i_lookback = input.int  (200, "Lookback Period",     minval = 30, maxval = 1000, group = GRP_ENG,
     tooltip = "Number of bars used to build the price distribution. Larger = broader, slower-moving value structure.")
int   i_prec     = input.int  (120, "Resolution",          minval = 20, maxval = 200,  group = GRP_ENG,
     tooltip = "Vertical resolution - how many horizontal density bands the cloud and side profile are split into. Higher = smoother gradient and a near-perfectly smooth profile edge. Each level draws 2 boxes (cloud + profile) so the practical ceiling is ~240 within the 500-box budget. Default 120 is smooth; raise toward 200 for maximum smoothness.")
float i_bw_mult  = input.float(1.0, "Bandwidth Multiplier", minval = 0.2, maxval = 3.0, step = 0.1, group = GRP_ENG,
     tooltip = "Smoothness of the density. 1.0 = Silverman's auto bandwidth. Higher = smoother / broader clouds, lower = sharper / more detailed peaks.")
float i_va_pct   = input.float(70,  "Value Area %",        minval = 50, maxval = 90,   step = 5, group = GRP_ENG,
     tooltip = "Percentage of total density that defines the Value Area. 70 is the classic market-profile value-area width.")

color C_LOW      = input.color(color.rgb(0,   60,  180), "Low Density Color",  group = GRP_VIZ,
     tooltip = "Color at the thin / low-probability end of the gradient (inefficiency zones).")
color C_HIGH     = input.color(color.rgb(255, 140, 0),   "High Density Color", group = GRP_VIZ,
     tooltip = "Color at the dense / high-probability end of the gradient (value zones).")
color C_POC      = input.color(color.rgb(245, 245, 250), "POC Line Color",     group = GRP_VIZ,
     tooltip = "Color of the POC line. Defaults to near-white for high contrast against the dense (orange) cloud where the POC always sits.")
int   i_op_min   = input.int  (8,   "Min Cloud Opacity",   minval = 0,  maxval = 40, group = GRP_VIZ,
     tooltip = "Opacity of the lowest-density band. Lower = more transparent so empty zones stay faint.")
int   i_op_max   = input.int  (65,  "Max Cloud Opacity",   minval = 30, maxval = 90, group = GRP_VIZ,
     tooltip = "Opacity of the highest-density band (POC). Higher = more saturated value zone.")
bool  i_show_poc = input.bool (true,  "Show POC Line",      group = GRP_VIZ,
     tooltip = "Dashed line at the Point of Control - the single highest-density price level.")
bool  i_show_va  = input.bool (true,  "Show Value Area",    group = GRP_VIZ,
     tooltip = "Dotted lines at the Value Area High and Low.")
bool  i_va_emph  = input.bool (true,  "Value Area Highlight", group = GRP_VIZ,
     tooltip = "Boost the opacity of cloud and profile bands inside the Value Area so the 70% core pops out of the rest of the distribution.")
bool  i_show_prof= input.bool (true,  "Show Side Profile",  group = GRP_VIZ,
     tooltip = "Density profile drawn just to the right of the last bar.")
bool  i_prof_line= input.bool (true,  "Profile Outline",    group = GRP_VIZ,
     tooltip = "Thin bright line tracing the right edge of the side profile for a crisp, designed silhouette over the gradient fill.")
int   i_ext      = input.int  (10,  "Cloud Forward Extend", minval = 0, maxval = 100, group = GRP_VIZ,
     tooltip = "How many bars to the right the clouds extend past the last bar.")

bool   i_show_dash = input.bool  (true, "Show Dashboard",   group = GRP_DASH)
string i_dash_pos  = input.string("Top Right", "Dashboard Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GRP_DASH)
bool   i_show_lgnd = input.bool  (true, "Show Legend",      group = GRP_DASH)

//-----------------------------------------------------------------------------}
// Constants
//-----------------------------------------------------------------------------{
color C_NEUTRAL     = color.rgb(80,  80,  100)
color C_DASH_BG     = color.rgb(50,  53,  60)
color C_DASH_BORDER = color.rgb(80,  85,  95)
color C_DASH_BULL   = color.rgb(80,  140, 255)
color C_DASH_ACCENT = color.rgb(255, 170, 50)
color C_DASH_SIDE   = color.rgb(150, 155, 170)

//-----------------------------------------------------------------------------}
// Persistent drawing pools
//-----------------------------------------------------------------------------{
var array<box>  cloud_boxes = array.new<box>()
var array<box>  prof_boxes  = array.new<box>()
var polyline    prof_poly   = na
var line  poc_line  = na
var line  vah_line  = na
var line  val_line  = na
var label poc_lbl   = na

// Values surfaced to the dashboard (var so they persist between the heavy
// recompute on barstate.islast and other bars).
var float poc_price = na
var float vah_price = na
var float val_price = na

//-----------------------------------------------------------------------------}
// KDE compute + draw - runs on the last bar only (profile-style heavy calc)
//-----------------------------------------------------------------------------{
if barstate.islast
    // Clean previous drawings.
    for b in cloud_boxes
        box.delete(b)
    cloud_boxes.clear()
    for b in prof_boxes
        box.delete(b)
    prof_boxes.clear()
    polyline.delete(prof_poly)
    line.delete(poc_line)
    line.delete(vah_line)
    line.delete(val_line)
    label.delete(poc_lbl)

    int n = math.min(i_lookback, bar_index + 1)
    if n >= 10
        // Collect lookback closes.
        array<float> prices = array.new<float>()
        for i = 0 to n - 1
            prices.push(close[i])

        float sigma = prices.stdev()
        float hi    = prices.max()
        float lo    = prices.min()
        float rng   = hi - lo

        if rng > 0 and sigma > 0
            // Silverman bandwidth: h = 1.06 * sigma * n^(-1/5), scaled by user.
            float h = i_bw_mult * 1.06 * sigma * math.pow(n, -0.2)
            h := math.max(h, syminfo.mintick)

            float step = rng / i_prec

            // Evaluate density at each level. Store raw densities + max (POC).
            array<float> dens   = array.new<float>()
            array<float> levels = array.new<float>()
            float max_d   = 0.0
            float poc_lvl = lo
            float total_d = 0.0
            for k = 0 to i_prec
                float x = lo + step * k
                float d = 0.0
                for j = 0 to n - 1
                    float u = (x - prices.get(j)) / h
                    d += math.exp(-0.5 * u * u)
                dens.push(d)
                levels.push(x)
                total_d += d
                if d > max_d
                    max_d   := d
                    poc_lvl := x

            poc_price := poc_lvl

            // Value Area: walk outward from POC by density until i_va_pct of
            // total density is enclosed. Track the price extent reached.
            int   poc_i   = dens.indexof(max_d)
            float acc     = max_d
            int   lo_i    = poc_i
            int   hi_i    = poc_i
            float target  = total_d * i_va_pct / 100.0
            while acc < target and (lo_i > 0 or hi_i < dens.size() - 1)
                float below = lo_i > 0 ? dens.get(lo_i - 1) : -1.0
                float above = hi_i < dens.size() - 1 ? dens.get(hi_i + 1) : -1.0
                if above >= below
                    hi_i := hi_i + 1
                    acc  += above
                else
                    lo_i := lo_i - 1
                    acc  += below
            val_price := levels.get(lo_i)
            vah_price := levels.get(hi_i)

            int left_bar  = bar_index - (n - 1)
            int right_bar = bar_index + i_ext

            // Draw cloud bands with a density-driven gradient. Bands inside the
            // Value Area get an opacity boost so the 70% core stands out.
            for k = 0 to dens.size() - 1
                float norm = max_d > 0 ? dens.get(k) / max_d : 0.0
                float lvl  = levels.get(k)
                bool  in_va = i_va_emph and lvl >= val_price and lvl <= vah_price
                // Interpolate opacity between Min and Max, then flip to Pine
                // transparency (inverted).
                float op_user = i_op_min + (i_op_max - i_op_min) * norm
                if in_va
                    op_user := math.min(95.0, op_user + 12.0)
                int   transp  = int(math.round(100.0 - op_user))
                color band_c  = color.from_gradient(norm, 0.0, 1.0, color.new(C_LOW, transp), color.new(C_HIGH, transp))
                cloud_boxes.push(box.new(
                     left   = left_bar,
                     top    = lvl + step / 2,
                     right  = right_bar,
                     bottom = lvl - step / 2,
                     bgcolor = band_c,
                     border_color = na))

            // Side profile - density histogram to the right, same blue->orange
            // gradient as the cloud. Width per band scales with density. At the
            // default resolution (120 bands) the right edge reads as a near-
            // smooth wave while keeping the per-level gradient. Boxes never
            // overshoot the lookback price range.
            if i_show_prof
                int prof_left  = bar_index + i_ext + 2
                int prof_width = math.max(5, int(n * 0.18))
                array<chart.point> outline = array.new<chart.point>()
                for k = 0 to dens.size() - 1
                    float norm = max_d > 0 ? dens.get(k) / max_d : 0.0
                    int   bar_len = int(math.round(norm * prof_width))
                    float lvl = levels.get(k)
                    bool  in_va = i_va_emph and lvl >= val_price and lvl <= vah_price
                    if bar_len > 0
                        float op_user = i_op_min + (i_op_max - i_op_min) * norm
                        if in_va
                            op_user := math.min(95.0, op_user + 12.0)
                        int   transp  = int(math.round(100.0 - op_user))
                        color pc = color.from_gradient(norm, 0.0, 1.0, color.new(C_LOW, transp), color.new(C_HIGH, transp))
                        prof_boxes.push(box.new(
                             left   = prof_left,
                             top    = lvl + step / 2,
                             right  = prof_left + bar_len,
                             bottom = lvl - step / 2,
                             bgcolor = pc,
                             border_color = na))
                    if i_prof_line
                        outline.push(chart.point.from_index(prof_left + bar_len, lvl))
                // Crisp silhouette outline tracing the right edge of the profile.
                if i_prof_line and outline.size() > 1
                    prof_poly := polyline.new(outline,
                         curved     = false,
                         closed     = false,
                         line_color = color.new(C_HIGH, 0),
                         line_width = 1)

            // POC line + label. POC sits in the densest (most orange) band, so
            // the line uses a high-contrast colour (default near-white) and the
            // label a dark background so it reads on top of the cloud.
            if i_show_poc
                poc_line := line.new(left_bar, poc_lvl, right_bar, poc_lvl,
                     color = color.new(C_POC, 0), width = 2, style = line.style_dashed)
                poc_lbl := label.new(right_bar, poc_lvl, "POC " + str.tostring(poc_lvl, format.mintick),
                     style = label.style_label_left, color = color.new(color.rgb(30, 34, 45), 0),
                     textcolor = color.white, size = size.small)

            // Value Area High / Low lines.
            if i_show_va
                vah_line := line.new(left_bar, vah_price, right_bar, vah_price,
                     color = color.new(C_NEUTRAL, 20), width = 1, style = line.style_dotted)
                val_line := line.new(left_bar, val_price, right_bar, val_price,
                     color = color.new(C_NEUTRAL, 20), width = 1, style = line.style_dotted)

//-----------------------------------------------------------------------------}
// Dashboard
//-----------------------------------------------------------------------------{
string dash_pos = switch i_dash_pos
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right

// Price position relative to value structure.
string price_zone = na(poc_price) ? "---" :
     close > vah_price ? "Above Value" :
     close < val_price ? "Below Value" : "In Value"
color zone_clr = price_zone == "Above Value" ? C_DASH_BULL : price_zone == "Below Value" ? C_DASH_ACCENT : C_DASH_SIDE

if barstate.islast and i_show_dash
    var table dash = table.new(dash_pos, 2, 6,
         C_DASH_BG, C_DASH_BORDER, 2, C_DASH_BORDER, 2)

    table.cell(dash, 0, 0, "EXCAVO",
         text_color = C_DASH_BULL, text_size = size.normal, text_halign = text.align_left)
    table.cell(dash, 1, 0, "Density Clouds",
         text_color = color.white, text_size = size.normal, text_halign = text.align_right)

    table.cell(dash, 0, 1, "POC",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 1, na(poc_price) ? "---" : str.tostring(poc_price, format.mintick),
         text_color = C_DASH_ACCENT, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 2, "Value Area High",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 2, na(vah_price) ? "---" : str.tostring(vah_price, format.mintick),
         text_color = color.white, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 3, "Value Area Low",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 3, na(val_price) ? "---" : str.tostring(val_price, format.mintick),
         text_color = color.white, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 4, "Price Zone",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 4, price_zone,
         text_color = zone_clr, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 5, "Lookback",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 5, str.tostring(i_lookback),
         text_color = color.white, text_size = size.small, text_halign = text.align_right)

//-----------------------------------------------------------------------------}
// Legend
//-----------------------------------------------------------------------------{
if barstate.islast and i_show_lgnd
    var table leg = table.new(position.bottom_left, 2, 7,
         C_DASH_BG, C_DASH_BORDER, 1, C_DASH_BORDER, 1)

    table.cell(leg, 0, 0, "LEGEND",
         text_color = C_DASH_BULL, text_size = size.normal, text_halign = text.align_center, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 0, "", text_size = size.small, bgcolor = C_DASH_BG)
    table.merge_cells(leg, 0, 0, 1, 0)

    // One-line plain description of what the indicator shows.
    table.cell(leg, 0, 1, "Where price has traded most",
         text_color = C_DASH_SIDE, text_size = size.small, text_halign = text.align_center, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 1, "", text_size = size.small, bgcolor = C_DASH_BG)
    table.merge_cells(leg, 0, 1, 1, 1)

    table.cell(leg, 0, 2, "▮", text_color = C_HIGH,     text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 2, "Value - traded most",     text_color = color.white, text_size = size.small, text_halign = text.align_left, bgcolor = C_DASH_BG)

    table.cell(leg, 0, 3, "▮", text_color = C_LOW,      text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 3, "Thin - price moves fast",  text_color = color.white, text_size = size.small, text_halign = text.align_left, bgcolor = C_DASH_BG)

    table.cell(leg, 0, 4, "━", text_color = C_POC,      text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 4, "POC - most-traded price",  text_color = color.white, text_size = size.small, text_halign = text.align_left, bgcolor = C_DASH_BG)

    table.cell(leg, 0, 5, "┈", text_color = C_NEUTRAL,  text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 5, "Value Area (70% core)",    text_color = color.white, text_size = size.small, text_halign = text.align_left, bgcolor = C_DASH_BG)

    table.cell(leg, 0, 6, " ", text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 6, " ", text_size = size.small, bgcolor = C_DASH_BG)
````
