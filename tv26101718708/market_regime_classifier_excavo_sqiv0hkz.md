# Market Regime Classifier [EXCAVO]

- url: https://www.tradingview.com/script/sQIv0hKZ-Market-Regime-Classifier-EXCAVO/
- type: indicator
- pine_id: PUB;9d8b5337e564495bb3754cecf9b8612f
- version: 1.0

## Description

Four-State Probabilistic Regime Detection Using a Hidden Markov Model

The [i]Market Regime Classifier[/i] applies a four-state Hidden Markov Model (HMM)
to classify the current market environment as Bullish, Bearish, Volatile, or Sideways.
Rather than using fixed thresholds on ADX or moving average slopes, the model maintains
and continuously updates a probability distribution across all four states on every bar,
producing smooth, low-noise regime identification.

This is not a threshold-based classifier. State probabilities update through Bayesian
forward inference, so regime transitions emerge from the data rather than arbitrary
cutoff values.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ HOW TO USE[/b]

[b]Step 1[/b]  →  Add the indicator to a new pane. The confidence histogram
              appears immediately, colored by the current regime.
[b]Step 2[/b]  →  Read the regime from the histogram color and the dashboard
              panel. Blue = Bullish, Red = Bearish, Orange = Volatile,
              Gray = Sideways.
[b]Step 3[/b]  →  Monitor the confidence level. Above 80%, the model has high
              conviction. Below 60%, the market is transitioning and both
              adjacent states have similar probabilities.
[b]Step 4[/b]  →  Set up alerts for regime transitions. Each state change fires
              on a closed bar only, eliminating repainting.
[b]Step 5[/b]  →  Check the dashboard for individual state probabilities. When
              two states have close values, the market is ambiguous - this is
              visible in the dashboard before a formal regime change occurs.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ HOW IT CALCULATES[/b]

[b]◆  Data Conditioning[/b]
Each bar computes the log return: ln(close / close[1]). The mean and standard
deviation of log returns are calculated over the lookback period. Both are then
normalized: norm_ret = (log_ret - mean) / stdev, and norm_vol = stdev /
sma(stdev, lookback). This standardization makes the model asset-agnostic,
producing consistent behavior across equities, crypto, and forex without
requiring parameter adjustments per instrument.

[b]◆  Gaussian Emission Likelihoods[/b]
Each of the four states has a Gaussian emission function that evaluates how
well the current normalized volatility and return match that state's expected
profile. The emission formula is exp(-(x - center)^2 / width), where x is the
normalized observation, center is the expected value for that state, and width
controls the response range:
[list]
[*]Bullish: norm_vol = 1.1, norm_ret = +0.8 (moderate volatility, positive drift)
[*]Bearish: norm_vol = 1.1, norm_ret = -0.8 (moderate volatility, negative drift)
[*]Sideways: norm_vol = 0.7, norm_ret = 0.0 (low volatility, no directional bias)
[*]Volatile: norm_vol = 1.6 x sensitivity (elevated volatility, direction-agnostic)
[/list]
A state's emission is high when the current bar's profile closely matches its center
and decreases exponentially as the observation diverges.

[b]◆  Bayesian Forward Update[/b]
The model maintains four state probabilities (p_bull, p_bear, p_side, p_vola)
initialized at 0.25 each. On every bar, unnormalized posteriors are computed:
un_state = emission(state) x (p_state x 0.9 + sum_others x 0.033). The 0.9
self-transition coefficient gives the model inertia - it stays in the current
state unless emissions consistently support a different one. The 0.033
cross-transition coefficient (approximately (1 - 0.9) / 3) keeps all states
reachable. Posteriors are then normalized to sum to 1.0. The smoothing factor
controls how aggressively each bar's emission result shifts the running
probability, acting as an exponential moving average over the posterior series.

[b]◆  State Classification and Confidence[/b]
The active regime is the state with the highest posterior probability (argmax).
Confidence equals this maximum probability expressed as a percentage. A regime
change is detected when the dominant state changes on a confirmed (closed) bar,
which fires all alerts. The dashboard shows all four probabilities simultaneously,
making it possible to observe when the market is approaching a state boundary
before the formal regime label changes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ WHAT MAKES IT DIFFERENT[/b]

[b]◆  Probabilistic State Engine[/b]
Most regime classifiers use fixed thresholds: if ADX > 25 then trending, otherwise
ranging. This produces abrupt, oscillating switches at the boundary and gives no
information about conviction. The HMM produces a smooth probability distribution
across all four states simultaneously, with conviction visible at every bar as
an explicit confidence percentage.

[b]◆  Four-State Classification[/b]
Two-state models (trending vs. ranging) conflate Volatile markets with trending ones
and miss the distinction between low-activity consolidation and trend exhaustion.
Four states allow separate identification of sustained directional moves
(Bullish/Bearish), low-activity accumulation ranges (Sideways), and high-volatility
uncertainty (Volatile) - conditions that require different position sizing and
strategy selection.

[b]◆  Adaptive Volatility Threshold[/b]
The Volatile state's emission center scales with the Volatility Sensitivity input.
This makes the model configurable across asset classes: crypto spends more time at
elevated volatility levels and may benefit from a higher sensitivity value than
equities or forex.

[b]◆  Transition Memory (Inertia)[/b]
The self-transition coefficient (0.9) gives the model inertia - a single anomalous
bar cannot flip the regime. The classifier requires consistent evidence across
multiple bars to overcome the self-transition bias. This reduces false transitions
during brief volatility spikes or one-bar outliers.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ DASHBOARD[/b]

Real-time panel showing the current model state:
[list]
[*][b]Regime[/b] - active state (BULLISH / BEARISH / VOLATILE / SIDEWAYS), colored by type
[*][b]Confidence[/b] - highest state probability as a percentage; highlighted orange above 80%
[*][b]Bullish[/b] - current Bullish state probability
[*][b]Bearish[/b] - current Bearish state probability
[*][b]Volatile[/b] - current Volatile state probability
[*][b]Sideways[/b] - current Sideways state probability
[*][b]Norm Volatility[/b] - normalized volatility ratio; highlighted orange above 1.5 x sensitivity
[*][b]Smoothing[/b] - active smoothing factor (informational)
[/list]

Legend table (bottom left) explains histogram colors. Both panels toggle in Dashboard settings.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ SETTINGS[/b]

[b]HMM Engine[/b]
[list]
[*][b]Statistical Lookback[/b] - 50 bars (period for log-return mean and stdev; higher = more stable but slower to adapt)
[*][b]Decision Smoothing[/b] - 0.40 (exponential smoothing factor; lower = more stable, higher = more reactive)
[*][b]Volatility Sensitivity[/b] - 1.2 (scales the Volatile state emission center; increase for crypto, decrease for equities)
[/list]

[b]Visualization[/b]
[list]
[*][b]Bullish Color[/b] - default blue (histogram and ribbon color during Bullish regime)
[*][b]Bearish Color[/b] - default red (histogram and ribbon color during Bearish regime)
[*][b]Volatile Color[/b] - default orange (histogram and ribbon color during Volatile regime)
[*][b]Show Regime Ribbon[/b] - OFF (colored markers at pane bottom showing regime history)
[*][b]Background Highlight[/b] - ON (subtle tint matching the active regime)
[/list]

[b]Alerts[/b]
[list]
[*][b]JSON Alerts[/b] - OFF (enable for bot integration via 3Commas, Wunderbit, etc.)
[/list]

[b]Dashboard[/b]
[list]
[*][b]Dashboard Position[/b] - Top Right
[*][b]Show Dashboard[/b] - ON
[*][b]Show Legend[/b] - ON
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ ALERTS[/b]

[list]
[*][b]Bullish Regime[/b] - dominant state changed to Bullish on bar close
[*][b]Bearish Regime[/b] - dominant state changed to Bearish on bar close
[*][b]Volatile Regime[/b] - dominant state changed to Volatile on bar close
[*][b]Sideways Regime[/b] - dominant state changed to Sideways on bar close
[*][b]Regime Change[/b] - any state transition detected on bar close
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
// Market Regime Classifier [EXCAVO]
// -----------------------------------------------------------------------------
// Four-state Hidden Markov Model that classifies market conditions in real time.
//
//@version=6
indicator("Market Regime Classifier [EXCAVO]", "EXCAVO Market Regime Classifier",
     overlay       = false,
     max_bars_back = 500)

//-----------------------------------------------------------------------------}
// Inputs
//-----------------------------------------------------------------------------{
string GRP_HMM    = "HMM Engine"
string GRP_VIZ    = "Visualization"
string GRP_ALERTS = "Alerts"
string GRP_DASH   = "Dashboard"

int   i_lookback    = input.int  (50,  "Statistical Lookback",   minval = 10, maxval = 200, group = GRP_HMM,
     tooltip = "Bars used to calculate log-return mean and standard deviation. Higher values produce more stable but slower regime classification.")
float i_smooth      = input.float(0.4, "Decision Smoothing",     minval = 0.01, maxval = 1.0, step = 0.05, group = GRP_HMM,
     tooltip = "Exponential smoothing factor for state probability updates. Lower = more stable, higher = more reactive to recent data.")
float i_sensitivity = input.float(1.2, "Volatility Sensitivity", minval = 0.5, maxval = 3.0, step = 0.1, group = GRP_HMM,
     tooltip = "Adjusts the emission threshold for the Volatile state. Higher values require more extreme volatility to trigger the Volatile regime.")

color C_BULL        = input.color(color.rgb(0,   60,  180), "Bullish Color",        group = GRP_VIZ,
     tooltip = "Color for Bullish regime - histogram bars and regime ribbon.")
color C_BEAR        = input.color(color.rgb(200, 40,  40),  "Bearish Color",        group = GRP_VIZ,
     tooltip = "Color for Bearish regime - histogram bars and regime ribbon.")
color C_SIGNAL      = input.color(color.rgb(255, 140, 0),   "Volatile Color",       group = GRP_VIZ,
     tooltip = "Color for Volatile regime - histogram bars and regime ribbon.")
bool  i_show_ribbon = input.bool (false,                    "Show Regime Ribbon",   group = GRP_VIZ,
     tooltip = "Display a colored marker strip at the bottom of the pane showing regime history.")
bool  i_show_bg     = input.bool (true,                     "Background Highlight", group = GRP_VIZ,
     tooltip = "Subtle background tint matching the active regime state.")

bool  i_json        = input.bool (false, "JSON Alerts (for bots)", group = GRP_ALERTS,
     tooltip = "Enable JSON-formatted alerts for automated trading systems (3Commas, Wunderbit, etc.)")

string i_dash_pos   = input.string("Top Right", "Dashboard Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GRP_DASH,
     tooltip = "Position of the dashboard panel on the chart.")
bool   i_show_dash  = input.bool(true, "Show Dashboard", group = GRP_DASH)
bool   i_show_lgnd  = input.bool(true, "Show Legend",    group = GRP_DASH)

//-----------------------------------------------------------------------------}
// Constants
//-----------------------------------------------------------------------------{
color C_NEUTRAL     = color.rgb(80,  80,  100)
color C_DASH_BG     = color.rgb(50,  53,  60)
color C_DASH_BORDER = color.rgb(80,  85,  95)
color C_DASH_BULL   = color.rgb(80,  140, 255)
color C_DASH_BEAR   = color.rgb(240, 70,  70)
color C_DASH_SIGNAL = color.rgb(255, 170, 50)
color C_DASH_SIDE   = color.rgb(150, 155, 170)

//-----------------------------------------------------------------------------}
// Core — HMM Engine
//-----------------------------------------------------------------------------{
float log_ret  = math.log(close / nz(close[1], close))
float mean_ret = ta.sma(log_ret, i_lookback)
float vol_raw  = ta.stdev(log_ret, i_lookback)
float norm_ret = (log_ret - mean_ret) / (vol_raw + 0.000000001)
float norm_vol = vol_raw / (ta.sma(vol_raw, i_lookback) + 0.000000001)

// Gaussian emission likelihoods per state
float emit_bull = math.exp(-math.pow(norm_vol - 1.1, 2) / 0.6) * math.exp(-math.pow(norm_ret - 0.8, 2) / 1.5)
float emit_bear = math.exp(-math.pow(norm_vol - 1.1, 2) / 0.6) * math.exp(-math.pow(norm_ret + 0.8, 2) / 1.5)
float emit_side = math.exp(-math.pow(norm_vol - 0.7, 2) / 0.4) * math.exp(-math.pow(norm_ret,       2) / 0.4)
float emit_vola = math.exp(-math.pow(norm_vol - 1.6 * i_sensitivity, 2) / 0.8)

// Bayesian forward update
var float p_bull = 0.25
var float p_bear = 0.25
var float p_side = 0.25
var float p_vola = 0.25

if not na(norm_vol)
    float un_bull = emit_bull * (p_bull * 0.9 + (p_bear + p_side + p_vola) * 0.033)
    float un_bear = emit_bear * (p_bear * 0.9 + (p_bull + p_side + p_vola) * 0.033)
    float un_side = emit_side * (p_side * 0.9 + (p_bull + p_bear + p_vola) * 0.033)
    float un_vola = emit_vola * (p_vola * 0.9 + (p_bull + p_bear + p_side) * 0.033)
    float total   = un_bull + un_bear + un_side + un_vola
    if total > 0
        p_bull := p_bull + (un_bull / total - p_bull) * i_smooth
        p_bear := p_bear + (un_bear / total - p_bear) * i_smooth
        p_side := p_side + (un_side / total - p_side) * i_smooth
        p_vola := p_vola + (un_vola / total - p_vola) * i_smooth
    float t_sum = p_bull + p_bear + p_side + p_vola
    if t_sum > 0
        p_bull /= t_sum
        p_bear /= t_sum
        p_side /= t_sum
        p_vola /= t_sum

// Argmax state classification: 1=Bullish, 2=Bearish, 3=Volatile, 0=Sideways
float max_prob = math.max(p_bull, p_bear, p_side, p_vola)
int   state    = max_prob == p_bull ? 1 : max_prob == p_bear ? 2 : max_prob == p_vola ? 3 : 0

color reg_color = switch state
    1 => C_BULL
    2 => C_BEAR
    3 => C_SIGNAL
    => C_NEUTRAL

string reg_name = switch state
    1 => "BULLISH"
    2 => "BEARISH"
    3 => "VOLATILE"
    => "SIDEWAYS"

//-----------------------------------------------------------------------------}
// Detection — Regime Change
//-----------------------------------------------------------------------------{
var int prev_state  = na
bool regime_changed = not na(prev_state) and state != prev_state and barstate.isconfirmed
bool to_bull        = regime_changed and state == 1
bool to_bear        = regime_changed and state == 2
bool to_vola        = regime_changed and state == 3
bool to_side        = regime_changed and state == 0
prev_state         := state

//-----------------------------------------------------------------------------}
// Visuals
//-----------------------------------------------------------------------------{
plot(max_prob * 100, "Confidence", color = reg_color, style = plot.style_columns, histbase = 0)
hline(50, "Neutral",         color = color.new(color.gray, 50), linestyle = hline.style_dotted)
hline(80, "High Confidence", color = color.new(color.gray, 30), linestyle = hline.style_dashed)
plotshape(i_show_ribbon, "Ribbon", shape.square, location.bottom, color = color.new(reg_color, 40), size = size.small)
bgcolor(i_show_bg ? color.new(reg_color, 93) : na)

//-----------------------------------------------------------------------------}
// Dashboard
//-----------------------------------------------------------------------------{
color dash_state_col = switch state
    1 => C_DASH_BULL
    2 => C_DASH_BEAR
    3 => C_DASH_SIGNAL
    => C_DASH_SIDE

string dash_pos = switch i_dash_pos
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right

if barstate.islast and i_show_dash
    var table dash = table.new(dash_pos, 2, 9,
         C_DASH_BG, C_DASH_BORDER, 2, C_DASH_BORDER, 2)

    table.cell(dash, 0, 0, "EXCAVO",
         text_color = C_DASH_BULL, text_size = size.normal, text_halign = text.align_left)
    table.cell(dash, 1, 0, "Regime Classifier",
         text_color = color.white, text_size = size.normal, text_halign = text.align_right)

    table.cell(dash, 0, 1, "Regime",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 1, reg_name,
         text_color = dash_state_col, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 2, "Confidence",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 2, str.tostring(max_prob * 100, "0.0") + "%",
         text_color = max_prob >= 0.8 ? C_DASH_SIGNAL : color.white, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 3, "Bullish",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 3, str.tostring(p_bull * 100, "0.0") + "%",
         text_color = state == 1 ? C_DASH_BULL : color.white, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 4, "Bearish",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 4, str.tostring(p_bear * 100, "0.0") + "%",
         text_color = state == 2 ? C_DASH_BEAR : color.white, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 5, "Volatile",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 5, str.tostring(p_vola * 100, "0.0") + "%",
         text_color = state == 3 ? C_DASH_SIGNAL : color.white, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 6, "Sideways",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 6, str.tostring(p_side * 100, "0.0") + "%",
         text_color = state == 0 ? C_DASH_SIDE : color.white, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 7, "Norm Volatility",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 7, str.tostring(nz(norm_vol, 0.0), "0.00"),
         text_color = norm_vol > 1.5 * i_sensitivity ? C_DASH_SIGNAL : color.white, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 8, "Smoothing",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 8, str.tostring(i_smooth, "0.00"),
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

    table.cell(leg, 0, 1, "▮", text_color = C_DASH_BULL,   text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 1, "Bullish regime",        text_color = color.white, text_size = size.small, bgcolor = C_DASH_BG)

    table.cell(leg, 0, 2, "▮", text_color = C_DASH_BEAR,   text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 2, "Bearish regime",        text_color = color.white, text_size = size.small, bgcolor = C_DASH_BG)

    table.cell(leg, 0, 3, "▮", text_color = C_DASH_SIGNAL, text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 3, "Volatile regime",       text_color = color.white, text_size = size.small, bgcolor = C_DASH_BG)

    table.cell(leg, 0, 4, "▮", text_color = C_DASH_SIDE,   text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 4, "Sideways regime",       text_color = color.white, text_size = size.small, bgcolor = C_DASH_BG)

    table.cell(leg, 0, 5, "━", text_color = color.new(color.gray, 30), text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 5, "High confidence (80%)", text_color = color.white, text_size = size.small, bgcolor = C_DASH_BG)

    table.cell(leg, 0, 6, "", text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 6, "", text_size = size.small, bgcolor = C_DASH_BG)

//-----------------------------------------------------------------------------}
// Alerts
//-----------------------------------------------------------------------------{
alertcondition(to_bull, title = "Bullish Regime",
     message = "EXCAVO Market Regime Classifier: BULLISH regime on {{ticker}} ({{interval}})")
alertcondition(to_bear, title = "Bearish Regime",
     message = "EXCAVO Market Regime Classifier: BEARISH regime on {{ticker}} ({{interval}})")
alertcondition(to_vola, title = "Volatile Regime",
     message = "EXCAVO Market Regime Classifier: VOLATILE regime on {{ticker}} ({{interval}})")
alertcondition(to_side, title = "Sideways Regime",
     message = "EXCAVO Market Regime Classifier: SIDEWAYS regime on {{ticker}} ({{interval}})")
alertcondition(regime_changed, title = "Regime Change",
     message = "EXCAVO Market Regime Classifier: Regime changed to {{plot(\"Confidence\")}} on {{ticker}} ({{interval}})")

if i_json and regime_changed
    alert('{"ticker":"' + syminfo.ticker + '","regime":"' + reg_name + '",' +
          '"confidence":' + str.tostring(max_prob * 100, "0.0") + ',' +
          '"price":' + str.tostring(close, format.mintick) + ',' +
          '"indicator":"EXCAVO_Market_Regime_Classifier","timeframe":"' + timeframe.period + '"}',
          alert.freq_once_per_bar)
````
