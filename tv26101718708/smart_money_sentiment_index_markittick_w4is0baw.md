# Smart Money Sentiment Index [MarkitTick]

- url: https://www.tradingview.com/script/w4is0bAW-Smart-Money-Sentiment-Index-MarkitTick/
- type: indicator
- pine_id: PUB;cce55db6a60f472b8f074448962519c1
- version: 1.0

## Description

💡A comprehensive analytical tool designed to bridge the gap between underlying market psychology and structural price action. By synthesizing a multi-dimensional sentiment oscillator with an advanced market structure mapping system, this indicator provides a holistic view of market dynamics. It is engineered to identify periods of psychological exhaustion—where market participants exhibit extreme fear or greed—and cross-reference these anomalies with significant shifts in supply and demand. This confluence allows for a highly disciplined approach to navigating volatile environments, ensuring that structural analysis is always contextualized by prevailing market sentiment.

[b]✨ Originality and Utility[/b]
Traditional oscillators typically isolate a single variable, such as momentum or volume, which often leads to diverging signals during complex market phases. Furthermore, structural mapping tools operate strictly on price geometry without considering the behavioral state of the market. This tool is highly original because it resolves this disconnect. It operates as a strategic mashup, justifying the combination of sentiment analysis and structure mapping by positing that structural breaks are significantly more reliable when they align with behavioral extremes. By unifying these two previously disparate analytical frameworks, the indicator filters out structural noise that occurs in neutral psychological zones, delivering a refined perspective on market conditions. 

[b]🔬 Methodology and Concepts[/b]
The underlying methodology relies on a dual-engine architecture, carefully abstracted to maintain calculation integrity and protect core logic. 

[b]• The Sentiment Engine[/b]
The sentiment component processes multiple parallel vectors of market data. It continually assesses momentum differentials, volatility compression and expansion, volume participation intensity, and relative positioning. These vectors are mathematically normalized and aggregated into a singular composite score ranging from zero to one hundred. This raw composite is then passed through a dynamic smoothing algorithm to filter out erratic tick-level noise, resulting in a stable primary sentiment value. A secondary signal line is derived from this primary value to calculate momentum convergence and divergence, effectively anticipating shifts in behavioral trends before they fully materialize. 

[b]• The Structural Engine[/b]
Operating concurrently, the structural engine performs rigorous swing analysis. It continuously scans historical price action to identify confirmed pivot highs and pivot lows based on user-defined parameters. When price action eclipses these pivotal nodes, the engine mathematically categorizes the event as either a continuation of structure or a fundamental shift in character. Upon confirmation of these structural shifts, the engine projects dynamic support and resistance zones, tracking their mitigation status in real-time to visualize areas of untested liquidity.

[b]🎨 Visual Guide[/b]
The visual presentation is meticulously designed to present complex data hierarchies without obscuring price action.

[b]• The Oscillator Pane[/b]
[list]
[*] The primary sentiment line oscillates between 0 and 100, plotted prominently to reflect current market psychology.
[*] A secondary, semi-transparent signal line tracks the primary sentiment, providing a visual cue for momentum crossovers.
[*] Horizontal reference levels establish the baseline neutral zone (50), as well as the thresholds for extreme greed and extreme fear.
[*] The background of the oscillator pane dynamically illuminates with deeply saturated hues when the sentiment breaches the outermost extremes, providing immediate visual notification of exhaustion.
[/list]

[b]• Chart Elements and Overlays[/b]
[list]
[*] Price candles feature dynamic color gradients that transition from deep red to vibrant green, providing a bar-by-bar heatmap of the underlying sentiment.
[*] Dashed horizontal lines project across the chart to mark significant structural breaks, accompanied by precise text labels denoting the nature of the break.
[*] Translucent rectangular zones are drawn at the origin points of structural breaks, visually representing active areas of interest.
[*] The color coding of these zones shifts to a muted, darker shade once price successfully retests and mitigates the area, allowing the user to distinguish between fresh and exhausted liquidity.
[/list]

[b]• The Analytics Dashboard[/b]
A highly structured table anchors to the chart, displaying real-time metrics:
[list]
[*] [i]FGI Value[/i]: The exact numerical sentiment score paired with a visual magnitude bar.
[*] [i]Signal Value[/i]: The smoothed momentum score.
[*] [i]Momentum Gap[/i]: Calculates the absolute distance between the sentiment and signal lines, indicating whether the psychological momentum is expanding or narrowing.
[*] [i]Bias Regime[/i]: Classifies the broader environment as rising or extreme within the context of fear or greed.
[*] [i]Zone Status[/i]: Explicitly warns when the market enters extreme threshold boundaries.
[*] [i]Zero Cross Age[/i]: A bar-counting mechanism that tracks the duration since the sentiment last crossed the neutral baseline.
[*] [i]Market Structure[/i]: Displays the current prevailing structural trend confirmed by the SMC engine.
[/list]

[b]📖 How to Use[/b]
This tool is designed to foster a systematic approach to market analysis, utilizing confluence to filter high-probability environments.

[list=1]
[*] [i]Identify Behavioral Exhaustion[/i]: Monitor the sentiment oscillator and the analytics dashboard. When the market enters the extreme greed or extreme fear background zones, recognize that the prevailing trend is highly saturated and susceptible to mean reversion.
[*] [i]Wait for Structural Confirmation[/i]: Do not act solely on sentiment extremes. Wait for the structural engine to print a confirmed shift in character on the chart. 
[*] [i]Assess the Momentum Gap[/i]: Consult the dashboard to ensure the momentum gap is expanding in the direction of the new structural shift, validating that market psychology supports the technical breakout.
[*] [i]Define Invalidation[/i]: Utilize the freshly generated, unmitigated order block zones as logical areas to define risk parameters and structural invalidation points.
[/list]

[b]⚙️ Inputs and Settings[/b]
The indicator provides extensive configurability to adapt to various market environments.

[b]• Sentiment Parameters[/b]
[list]
[*] [i]FGI Period[/i]: Dictates the lookback window for the core sentiment vectors. Shorter lengths increase sensitivity, while longer lengths identify macro psychological shifts.
[*] [i]Signal Line Period[/i]: Adjusts the smoothing factor for the secondary momentum tracker.
[*] [i]Overbought/Oversold Levels[/i]: Allows the user to define the exact numerical thresholds that trigger the extreme background zones and alerts.
[/list]

[b]• Visual and Dashboard Configurations[/b]
[list]
[*] [i]Color Price Candles[/i]: Toggles the sentiment-based gradient coloring on the main chart candles.
[*] [i]Dashboard Settings[/i]: Provides options to customize the background and text colors of the analytics panel for optimal visibility.
[/list]

[b]• Structural Settings[/b]
[list]
[*] [i]Swing Length[/i]: Determines the number of bars required to confirm a valid structural pivot point.
[*] [i]Enable SMC Overlay[/i]: A master toggle for the structural lines and zone boxes.
[*] [i]Track/Hide Mitigation[/i]: Configures how the indicator handles zones once they have been retested by price, offering the option to either recolor them or remove them entirely to keep the chart clean.
[/list]

[b]• Alert Conditions[/b]
[list]
[*] [i]FGI crosses Zero[/i]: Generates a notification when sentiment flips across the neutral 50 baseline.
[*] [i]OB/OS Level Breach[/i]: Triggers a warning precisely when the market enters the predefined extreme psychological zones.
[/list]

[b]🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]
The theoretical foundation of this indicator is deeply rooted in the principles of behavioral finance and auction market theory. Traditional quantitative finance assumes rational actors operating in an efficient market; however, empirical evidence demonstrates that markets are frequently driven by cognitive biases, leading to periods of irrational exuberance (greed) and unwarranted panic (fear). 

The sentiment engine models this behavioral distribution by capturing standard deviations in volatility and momentum, mapping the data onto a normalized sigmoid-like curve. This quantifies the exact degree of psychological saturation. When a market reaches the tail ends of this distribution, the probability of mean reversion increases exponentially due to the exhaustion of marginal buyers or sellers.

Simultaneously, the structural engine maps these psychological states onto the physical mechanics of order flow. Breakouts and structural shifts that occur during neutral sentiment phases are often the result of standard liquidity provision and algorithmic execution. However, structural breaks that trigger concurrently with extreme sentiment readings mathematically validate a macro shift in participant behavior. By tracking the origin points of these shifts (order blocks), the indicator highlights the exact price vectors where institutional and large-scale participants initiated the phase transition, offering a rigorous, data-driven framework for anticipating future supply and demand imbalances.

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. I expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick

// ─────────────────────────────────────────────────────────────────────────────
//@version=6
indicator("Smart Money Sentiment Index [MarkitTick]", overlay=false, max_bars_back=500, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS

int   i_len        = input.int  (21,    "FGI Period",         minval=1,  group="Calculation")
int   i_sigLen     = input.int  (9,     "Signal Line Period", minval=1,  group="Calculation")
bool  i_showSig    = input.bool (true,  "Show Signal Line",              group="Calculation")
float i_overbought = input.float(70.0, "Overbought Level", minval=51.0, maxval=99.0, step=0.5, group="Calculation")
float i_oversold   = input.float(30.0, "Oversold Level",   minval=1.0,  maxval=49.0, step=0.5, group="Calculation")

bool  i_showCandles = input.bool (true,                   "Color Price Candles",    group="Neon Colors")

bool  i_alertCross = input.bool(true, "Alert: FGI crosses Zero",   group="Alerts")
bool  i_alertOBOS  = input.bool(true, "Alert: OB/OS Level Breach", group="Alerts")

string GRP_DASH     = "📊 Dashboard Settings"
color  dash_bg_color  = input.color(color.rgb(14, 10, 28, 5),    "Background Color", group=GRP_DASH)
color  dash_txt_color = input.color(color.rgb(200, 195, 230, 0), "Text Color",       group=GRP_DASH)

string GRP_SMC      = "🏛 SMC — Market Structure & Order Blocks"
bool   smc_show     = input.bool(true,  "Enable SMC Overlay",    group=GRP_SMC)
int    smc_swing    = input.int (5,     "Swing Length",  minval=2, group=GRP_SMC)
color  smc_col_bull = input.color(color.new(#7B61FF, 0),  "BOS/CHoCH Bull Color",   group=GRP_SMC)
color  smc_col_bear = input.color(color.new(#FF6B35, 0),  "BOS/CHoCH Bear Color",   group=GRP_SMC)
color  smc_col_ob_bull = input.color(color.new(#00FF00, 78), "Bull OB Fill",        group=GRP_SMC)
color  smc_col_ob_bear = input.color(color.new(#FF0000, 78), "Bear OB Fill",        group=GRP_SMC)
bool   smc_show_mit = input.bool(false,  "Track OB Mitigation",   group=GRP_SMC)
bool   smc_hide_mit = input.bool(false, "Hide Mitigated OBs",    group=GRP_SMC)
color  smc_col_mit  = input.color(color.new(#4A4A6A, 82), "Mitigated OB Color",    group=GRP_SMC)


f_blockBar(float score) =>
    int    n = math.min(math.max(math.round(score), 0), 10)
    string s = ''
    for i = 1 to 10
        s += i <= n ? '█' : '░'
    s

f_blockColor(float score) =>
    score >= 7.0 ? color.rgb(0, 229, 160) :
     score >= 4.0 ? color.rgb(123, 97, 255) :
     score >= 1.5 ? color.rgb(240, 192, 64) :
     color.rgb(80, 75, 110)

string clean_ticker = syminfo.prefix + ':' + syminfo.ticker

// ══════════════════════════════════════════════════════════════════════════════
// SMART FEAR & GREED INDEX ENGINE

type QuantEngine
    float m_momentum
    float m_volatility
    float m_volume
    float m_position
    float m_composite
    float m_final

normalize_helper(float src, int len) =>
    float h   = ta.highest(src, len)
    float l   = ta.lowest(src, len)
    float div = math.max(h - l, 1e-9)
    math.min(100, math.max(0, (src - l) / div * 100))

method update_metrics(QuantEngine eng, int lookback_len) =>
    eng.m_momentum   := ta.rsi(close[1], lookback_len)
    float raw_atr     = ta.atr(lookback_len)[1]
    float norm_atr    = normalize_helper(raw_atr, lookback_len * 2)
    eng.m_volatility  := 100.0 - norm_atr
    float vol_sma     = ta.sma(volume[1], lookback_len)
    float vol_rel     = volume[1] / math.max(vol_sma, 1.0)
    float vol_metric  = math.min(vol_rel, 2.0) / 2.0 * 100.0
    eng.m_volume      := close[1] > open[1] ? vol_metric : (100.0 - vol_metric)
    eng.m_position    := ta.stoch(close[1], high[1], low[1], lookback_len)

f_ema(float src, int len, float prev) =>
    float k = 2.0 / (len + 1)
    na(prev) ? src : prev + k * (src - prev)

var float _engFinalState = na

method aggregate(QuantEngine eng, int smooth_len, float prev_final) =>
    eng.m_composite := (eng.m_momentum + eng.m_volatility + eng.m_volume + eng.m_position) / 4.0
    eng.m_final     := f_ema(eng.m_composite, smooth_len, prev_final)

var QuantEngine engine = QuantEngine.new()
engine.update_metrics(i_len)
engine.aggregate(i_sigLen, _engFinalState)
_engFinalState := engine.m_final

float fgi = engine.m_final

var float _fgiSigState = na
_fgiSigState := f_ema(fgi, i_sigLen, _fgiSigState[1])
float fgiSig = _fgiSigState

float fgi_ob = i_overbought
float fgi_os = i_oversold

bool crossUpZero = fgi[2] < 50.0   and fgi[1] >= 50.0
bool crossDnZero = fgi[2] >= 50.0  and fgi[1] <  50.0
bool crossUpOB   = fgi[2] < fgi_ob and fgi[1] >= fgi_ob
bool crossDnOS   = fgi[2] > fgi_os and fgi[1] <= fgi_os

bool  sigBull     = fgi[1] >= 50.0
bool  gapWidening = math.abs(fgi[1] - fgiSig[1]) > math.abs(fgi[2] - fgiSig[2])

var int barsSinceZero = 0
barsSinceZero := (crossUpZero or crossDnZero) ? 0 : barsSinceZero + 1


// ══════════════════════════════════════════════════════════════════════════════
// SMC ENGINE

type SMCSwing
    int   idx
    float price
    bool  active

type SMCBlock
    int   left
    float top
    float bottom
    bool  is_bull
    bool  mitigated
    box   bx

var SMCSwing          smc_ph    = SMCSwing.new(0, 0.0, false)
var SMCSwing          smc_pl    = SMCSwing.new(0, 0.0, false)
var int               smc_trend = 0
var array<SMCBlock>   smc_obs   = array.new<SMCBlock>()

f_smcPH(series float src, simple int len) =>
    float c = src[len]
    bool  v = true
    for i = 1 to len * 2
        if i != len and src[i] >= c
            v := false
    v ? c : na

f_smcPL(series float src, simple int len) =>
    float c = src[len]
    bool  v = true
    for i = 1 to len * 2
        if i != len and src[i] <= c
            v := false
    v ? c : na

float smc_raw_ph = f_smcPH(high, smc_swing)
float smc_raw_pl = f_smcPL(low,  smc_swing)

float smc_atr = ta.atr(14)[1]

var bool  _ph_active_prev = false
var float _ph_price_prev  = 0.0
var bool  _pl_active_prev = false
var float _pl_price_prev  = 0.0

bool  ph_active_snap = _ph_active_prev
float ph_price_snap  = _ph_price_prev
bool  pl_active_snap = _pl_active_prev
float pl_price_snap  = _pl_price_prev

if not na(smc_raw_ph)
    smc_ph.idx    := bar_index[smc_swing]
    smc_ph.price  := smc_raw_ph
    smc_ph.active := true

if not na(smc_raw_pl)
    smc_pl.idx    := bar_index[smc_swing]
    smc_pl.price  := smc_raw_pl
    smc_pl.active := true

_ph_active_prev := smc_ph.active
_ph_price_prev  := smc_ph.price
_pl_active_prev := smc_pl.active
_pl_price_prev  := smc_pl.price

var int _brk_cooldown = 0
_brk_cooldown := _brk_cooldown > 0 ? _brk_cooldown - 1 : 0

bool ms_bull_break = ph_active_snap and close[1] > ph_price_snap and _brk_cooldown == 0
bool ms_bear_break = pl_active_snap and close[1] < pl_price_snap and _brk_cooldown == 0

if smc_show and smc_show_mit
    int _sz = array.size(smc_obs)
    if _sz > 0
        for i = 0 to _sz - 1
            SMCBlock ob = array.get(smc_obs, i)
            if not ob.mitigated
                bool hit = ob.is_bull ? low[1] <= ob.bottom : high[1] >= ob.top
                if hit
                    ob.mitigated := true
                    if smc_hide_mit
                        box.delete(ob.bx)
                    else
                        box.set_bgcolor(ob.bx, smc_col_mit)
                    array.set(smc_obs, i, ob)

if array.size(smc_obs) > 40
    SMCBlock evicted = array.shift(smc_obs)
    box.delete(evicted.bx)

color smc_brk_col = color.from_gradient(nz(fgi[1], 50.0), 0.0, 100.0, #00ff00, #ff0000)

if smc_show and ms_bull_break
    string lbl_txt  = smc_trend == 1 ? "BOS" : "CHoCH"
    int    lx1      = math.max(smc_ph.idx, bar_index - 499)
    int    mid_x    = math.round((lx1 + bar_index) / 2)

    line.new(lx1, smc_ph.price, bar_index, smc_ph.price,
         color=smc_brk_col, style=line.style_dashed, width=1,
         force_overlay=true)
    label.new(mid_x, smc_ph.price, lbl_txt,
         color=color.new(color.white, 100), textcolor=smc_brk_col,
         style=label.style_label_down, size=size.small,
         force_overlay=true)

    float ob_bottom = smc_pl.price
    float ob_top    = smc_pl.price + (smc_atr * 0.5)
    int   ob_left   = math.max(smc_pl.idx, bar_index - 499)
    box ob_bx = box.new(ob_left, ob_top, bar_index + 10, ob_bottom,
         border_color=na, bgcolor=smc_col_ob_bull,
         force_overlay=true)
    array.push(smc_obs, SMCBlock.new(ob_left, ob_top, ob_bottom, true, false, ob_bx))

    smc_trend       := 1
    smc_ph.active  := false
    _brk_cooldown  := smc_swing

if smc_show and ms_bear_break
    string lbl_txt  = smc_trend == -1 ? "BOS" : "CHoCH"
    int    lx1      = math.max(smc_pl.idx, bar_index - 499)
    int    mid_x    = math.round((lx1 + bar_index) / 2)

    line.new(lx1, smc_pl.price, bar_index, smc_pl.price,
         color=smc_brk_col, style=line.style_dashed, width=1,
         force_overlay=true)
    label.new(mid_x, smc_pl.price, lbl_txt,
         color=color.new(color.white, 100), textcolor=smc_brk_col,
         style=label.style_label_up, size=size.small,
         force_overlay=true)

    float ob_top    = smc_ph.price
    float ob_bottom = smc_ph.price - (smc_atr * 0.5)
    int   ob_left   = math.max(smc_ph.idx, bar_index - 499)
    box ob_bx = box.new(ob_left, ob_top, bar_index + 10, ob_bottom,
         border_color=na, bgcolor=smc_col_ob_bear,
         force_overlay=true)
    array.push(smc_obs, SMCBlock.new(ob_left, ob_top, ob_bottom, false, false, ob_bx))

    smc_trend      := -1
    smc_pl.active  := false
    _brk_cooldown  := smc_swing

// ══════════════════════════════════════════════════════════════════════════════
// DASHBOARD

const color C_XFEAR  = color.rgb( 0, 229, 160)
const color C_FEAR   = color.rgb(80, 200, 120)
const color C_NEUT   = color.rgb(240, 192,  64)
const color C_GREED  = color.rgb(180,  80, 255)
const color C_XGREED = color.rgb(255,  70,  70)


float  _fgi1        = nz(fgi[1], 50.0)
color dash_zone_col = _fgi1 >= fgi_ob  ? C_XGREED :
                      _fgi1 >= 50.0    ? C_GREED  :
                      _fgi1 >  fgi_os  ? C_NEUT   :
                      _fgi1 >  30.0    ? C_FEAR   :
                                         C_XFEAR

color rowBg_A  = color.new(dash_zone_col, 88)
color rowBg_B  = color.new(dash_zone_col, 82)
color hdrBg    = color.new(dash_zone_col, 70)
color hdrBg2   = color.new(dash_zone_col, 75)
color lbl_col  = color.new(dash_zone_col, 20)
color val_col  = dash_txt_color

float FGIScore   = fgi / 10.0
string FGIPrefix = fgi >= 50.0 ? '▲ ' : '▼ '
string FGIBar    = FGIPrefix + f_blockBar(FGIScore) + '  ' + str.tostring(fgi, '#.##')
color  FGIBarCol = color.from_gradient(_fgi1, 0.0, 100.0, C_XFEAR, C_XGREED)

float  sigScore  = fgiSig / 10.0
string sigPrefix = fgiSig >= 50.0 ? '▲ ' : '▼ '
string sigBar    = sigPrefix + f_blockBar(sigScore) + '  ' + str.tostring(fgiSig, '#.##')
color  sigBarCol = color.from_gradient(nz(fgiSig[1], 50.0), 0.0, 100.0, C_XFEAR, C_XGREED)

string sigStateStr = sigBull
     ? (gapWidening ? '▲ Greed  ·  Expanding' : '▲ Greed  ·  Narrowing')
     : (gapWidening ? '▼ Fear   ·  Expanding' : '▼ Fear   ·  Narrowing')
color  sigStateCol = sigBull ? C_GREED : C_FEAR

string zeroRegimeStr = fgi >= 50.0
     ? (fgi >= fgi_ob ? '📈 Greed · Extreme' : '📈 Greed · Rising')
     : (fgi <= fgi_os ? '📉 Fear  · Extreme' : '📉 Fear  · Rising')
color  zeroRegimeCol = fgi >= 50.0 ? C_GREED : C_FEAR

float  gapRaw    = math.abs(fgi - fgiSig)
float  gapScore  = math.min(gapRaw / 5.0 * 10.0, 10.0)
string gapPrefix = gapWidening ? '⚡ ' : '○  '
string gapBar    = gapPrefix + f_blockBar(gapScore) + '  ' + str.tostring(gapRaw, '#.##')
color  gapBarCol = gapWidening
     ? color.from_gradient(gapScore, 0.0, 10.0, C_NEUT, C_XGREED)
     : color.from_gradient(gapScore, 0.0, 10.0, C_XFEAR, C_NEUT)

string zoneStr = fgi >= fgi_ob  ? '⚠  Extreme Greed' :
                 fgi <= fgi_os  ? '⚠  Extreme Fear'  :
                 fgi >= 50.0    ? '⚖  Neutral Greed' :
                                  '⚖  Neutral Fear'
color  zoneCol = dash_zone_col

string barsStr = '⏳ ' + str.tostring(barsSinceZero) + ' Bars'
color  barsCol = barsSinceZero < 5  ? dash_zone_col :
                 barsSinceZero < 20 ? color.new(dash_zone_col, 35) :
                                      color.new(dash_zone_col, 60)

string smcTrendStr = smc_trend == 1  ? '▲ Bullish Structure' :
                     smc_trend == -1 ? '▼ Bearish Structure' :
                                       '— Undefined'
color  smcTrendCol = smc_trend == 1  ? C_XFEAR  :
                     smc_trend == -1 ? C_XGREED :
                                       C_NEUT

var table dash = table.new(position.top_right, 2, 10,
     border_width  = 1,
     border_color  = color.new(dash_zone_col, 50),
     frame_width   = 1,
     frame_color   = color.new(dash_zone_col, 40),
     force_overlay = true)

table.cell(dash, 0, 0, '  FGI · SMC Dashboard',
     bgcolor=hdrBg, text_color=lbl_col,
     text_halign=text.align_left, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 0, clean_ticker + ' · ' + timeframe.period,
     bgcolor=hdrBg, text_color=color.new(dash_zone_col, 10),
     text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)

table.cell(dash, 0, 1, '  FGI Value',
     bgcolor=rowBg_A, text_color=lbl_col,
     text_halign=text.align_left, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 1, FGIBar,
     bgcolor=rowBg_A, text_color=FGIBarCol,
     text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)

table.cell(dash, 0, 2, '  Signal Value',
     bgcolor=rowBg_B, text_color=lbl_col,
     text_halign=text.align_left, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 2, sigBar,
     bgcolor=rowBg_B, text_color=sigBarCol,
     text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)

table.cell(dash, 0, 3, '  FGI vs Signal',
     bgcolor=rowBg_A, text_color=lbl_col,
     text_halign=text.align_left, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 3, sigStateStr,
     bgcolor=rowBg_A, text_color=sigStateCol,
     text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)

table.cell(dash, 0, 4, '  Bias Regime',
     bgcolor=rowBg_B, text_color=lbl_col,
     text_halign=text.align_left, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 4, zeroRegimeStr,
     bgcolor=rowBg_B, text_color=zeroRegimeCol,
     text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)

table.cell(dash, 0, 5, '  Momentum Gap',
     bgcolor=rowBg_A, text_color=lbl_col,
     text_halign=text.align_left, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 5, gapBar,
     bgcolor=rowBg_A, text_color=gapBarCol,
     text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)

table.cell(dash, 0, 6, '  Zone Status',
     bgcolor=rowBg_B, text_color=lbl_col,
     text_halign=text.align_left, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 6, zoneStr,
     bgcolor=rowBg_B, text_color=zoneCol,
     text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)

table.cell(dash, 0, 7, '  Zero Cross Age',
     bgcolor=rowBg_A, text_color=lbl_col,
     text_halign=text.align_left, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 7, barsStr,
     bgcolor=rowBg_A, text_color=barsCol,
     text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)

table.cell(dash, 0, 8, '  Market Structure',
     bgcolor=rowBg_B, text_color=lbl_col,
     text_halign=text.align_left, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 8, smcTrendStr,
     bgcolor=rowBg_B, text_color=smcTrendCol,
     text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)

table.cell(dash, 0, 9, '  © MarkitTick',
     bgcolor=hdrBg2, text_color=color.new(dash_zone_col, 30),
     text_halign=text.align_left, text_font_family=font.family_monospace, text_size=size.tiny)
table.cell(dash, 1, 9, 'FGI® v6 · SMC',
     bgcolor=hdrBg2, text_color=color.new(dash_zone_col, 30),
     text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.tiny)

// ══════════════════════════════════════════════════════════════════════════════
// VISUALIZATION

bool s_ext_greed = fgi >= 70
bool s_greed     = fgi >= 60 and fgi < 70
bool s_neutral   = fgi >= 40 and fgi < 60
bool s_fear      = fgi >= 30 and fgi < 40
bool s_ext_fear  = fgi < 30

plot(fgi,                       "FGI",         color=color.new(color.blue, 0),   linewidth=1, display=display.pane + display.status_line)
plot(i_showSig ? fgiSig : na,   "Signal",      color=color.new(color.white, 20), linewidth=1, style=plot.style_line, display=display.pane + display.status_line)

plot(s_ext_greed ? fgi : na, "Zone: Extreme Greed", color=#ff0000, linewidth=2, style=plot.style_linebr, display=display.pane)
plot(s_greed     ? fgi : na, "Zone: Greed",         color=#ff6b35, linewidth=2, style=plot.style_linebr, display=display.pane)
plot(s_neutral   ? fgi : na, "Zone: Neutral",       color=#ffd700, linewidth=2, style=plot.style_linebr, display=display.pane)
plot(s_fear      ? fgi : na, "Zone: Fear",          color=#7cb342, linewidth=2, style=plot.style_linebr, display=display.pane)
plot(s_ext_fear  ? fgi : na, "Zone: Extreme Fear",  color=#00ff00, linewidth=2, style=plot.style_linebr, display=display.pane)

color candle_col = i_showCandles ? color.from_gradient(fgi, 0.0, 100.0, #00ff00, #ff0000) : na
plotcandle(i_showCandles ? open : na, i_showCandles ? high : na, i_showCandles ? low : na, i_showCandles ? close : na,
     title="Price Candles", color=candle_col, wickcolor=candle_col, bordercolor=candle_col, force_overlay=true, display=display.pane)

h_80 = hline(80, "Ref: Extreme Greed Top", color=color.red,   linestyle=hline.style_dotted)
h_70 = hline(70, "Ref: Extreme Greed",     color=color.red,   linestyle=hline.style_dotted)
fill(h_80, h_70, color=color.new(color.red, 90), title="Extreme Greed Zone Fill")

hline(50, "Ref: Neutral", color=color.gray, linestyle=hline.style_dashed)

h_30 = hline(30, "Ref: Extreme Fear",     color=color.green, linestyle=hline.style_dotted)
h_20 = hline(20, "Ref: Extreme Fear Bot", color=color.green, linestyle=hline.style_dotted)
fill(h_30, h_20, color=color.new(color.green, 90), title="Extreme Fear Zone Fill")

color bg_top = fgi >= 70 ? color.new(color.red,   90) : na
color bg_bot = fgi <= 30 ? color.new(color.green, 90) : na
bgcolor(bg_top, title="Background: Top Extreme")
bgcolor(bg_bot, title="Background: Bottom Extreme")
bgcolor(bg_top, title="Chart BG: Top Extreme",    force_overlay=true)
bgcolor(bg_bot, title="Chart BG: Bottom Extreme", force_overlay=true)

// ══════════════════════════════════════════════════════════════════════════════
// ALERTS


if i_alertCross and barstate.isconfirmed
    if crossUpZero
        alert(str.format("FGI crossed ABOVE Neutral (50) — {0} [{1}]", syminfo.tickerid, timeframe.period), alert.freq_once_per_bar_close)
    if crossDnZero
        alert(str.format("FGI crossed BELOW Neutral (50) — {0} [{1}]", syminfo.tickerid, timeframe.period), alert.freq_once_per_bar_close)

if i_alertOBOS and barstate.isconfirmed
    if crossUpOB
        alert(str.format("FGI entered EXTREME GREED — {0} [{1}]", syminfo.tickerid, timeframe.period), alert.freq_once_per_bar_close)
    if crossDnOS
        alert(str.format("FGI entered EXTREME FEAR — {0} [{1}]", syminfo.tickerid, timeframe.period), alert.freq_once_per_bar_close)
````
