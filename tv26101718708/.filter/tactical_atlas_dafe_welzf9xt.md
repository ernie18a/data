# Tactical Atlas [DAFE]

- url: https://www.tradingview.com/script/WElZf9XT-Tactical-Atlas-DAFE/
- type: indicator
- pine_id: PUB;fbfafa41f4c24a039d3f16a87178395d
- version: 1.0

## Description

[b]Tactical Atlas [DAFE]: A Multi-Dimensional Regime & Phase Space Visualizer[/b]

[b]This is not an indicator. This is a tactical map of the market's current state. It synthesizes multiple dimensions of data—trend, momentum, volatility, and stress—into a single, observable point in a four-quadrant phase space, providing an unparalleled, at-a-glance view of the market's true character.[/b]

[b]█ CHAPTER 1: THE PHILOSOPHY - FROM CLUTTER TO CLARITY[/b]
[b]The modern trader is drowning in data. We stack our charts with RSI, MACD, ADX, and Bollinger Bands, creating a cluttered screen of conflicting signals. We are then forced to perform a complex, subjective mental synthesis to answer the most fundamental question: "[b]What is the market actually doing right now?[/b]" Is it a healthy trend, an exhausted trend, a low-volatility compression, or a nascent recovery? Answering this requires juggling multiple concepts simultaneously.[/b]

[b]The [b]Tactical Atlas[/b] was engineered to solve this problem of information overload. It is a powerful data visualization engine built on a simple premise: a picture is worth a thousand indicators. It takes a suite of underlying metrics that quantify the market's key characteristics and maps them into a single, intuitive, two-dimensional "phase space." The position and trajectory of a single point within this space provides a complete, synthesized, and immediate understanding of the market's regime.[/b]

[b]This tool is not about adding another line to your chart; it's about replacing a dozen. It is a system for achieving profound contextual awareness, allowing you to see the market's state, its evolution over time, and its alignment across multiple timeframes, all within a single, elegant visual interface.[/b]

[b]█ CHAPTER 2: THE CORE INNOVATIONS - ORIGINALITY & USEFULNESS[/b]
[b]The Tactical Atlas is not a "mashup" of existing indicators. It is a novel framework for data synthesis and visualization, built upon a suite of proprietary and established analytical concepts.[/b]

[b]The Phase Space Architecture:[/b] This is the core innovation. Instead of displaying multiple oscillators in separate panes, the Atlas maps different dimensions of market data onto the X and Y axes of a scatter plot. The result is a single "point" whose coordinates (x, y) represent the synthesized state of the market. Its position and movement provide a rich, holistic view that is impossible to achieve with standard indicators.

[b]Three Distinct Analytical Modes:[/b] The Atlas is not one map, but three. You can instantly switch between different "lenses" to view the market's state from different perspectives, each answering a different critical question:
[b]Phase Space:[/b] Maps [b]Trend Strength[/b] (X-axis) vs. [b]Momentum[/b] (Y-axis). Answers: "Is this a strong trend with momentum, or is it an exhausted trend?"
Stress Orbit: Maps [b]Volatility Rank[/b] (X-axis) vs. [b]Market Stress[/b] (Y-axis). Answers: "Is this a calm, low-volatility environment, or a high-stress, fearful one?"
[b]Permission Field: [/b]Maps [b]Directional Bias[/b] (X-axis) vs. a proprietary [b]Permission Score[/b] (Y-axis). Answers: "Does the market have the underlying conditions (permission) to support a sustained directional move?"

[b]The Four Quadrant Regime Model:[/b] The phase space is divided into four distinct, named quadrants: [b]RECOVERY, EXPANSION, COMPRESSION,[/b] and [b]EXHAUSTION[/b]. The position of the point within these quadrants provides an immediate, human-readable classification of the market's character, allowing you to instantly align your strategy with the current environment.

[b]Multi-Timeframe "Ghost" Points:[/b] A revolutionary approach to multi-timeframe analysis. The Atlas calculates the state of the market on up to three higher timeframes and projects them as semi-transparent "ghost" points into the same phase space. This allows you to see, at a glance, if the current timeframe's regime is in alignment or conflict with the macro trend, without ever leaving your chart.

[b]The Velocity Vector:[/b] The system doesn't just show you where the market is in phase space; it shows you where it's going. A dynamic arrow is drawn from the current point, indicating the direction and magnitude of its recent travel through the space. A point moving rapidly from Compression towards Expansion is a powerful leading signal of an impending breakout.

[b]█ VISUALS - HOW TO READ THE ATLAS[/b]
[b]Every visual element is a data-rich component designed for rapid, intuitive interpretation.[/b]

[b]The Scatter Plot (The Map)[/b]
[b]The Quadrant Fields:[/b] The four colored quadrants that define the map. Each is labeled and has a distinct meaning. Your primary goal is to identify which quadrant the market currently occupies.
[b]The Gridlines:[/b] These faint lines mark the 25%, 50%, and 75% levels on both the X and Y axes, providing a clear visual reference for the strength of each component. The central intersection is the "neutral" point.
[b]The Trail:[/b] A multi-colored line that shows the historical path of the market's state over the last N bars. It allows you to see the journey the market took to arrive at its current position. A smooth, directional trail indicates a healthy, evolving regime. A tangled, chaotic trail indicates indecision.
[b]The Current Point (The Comet):[/b] This is you. It is the most important point on the map, representing the market's state on the most recent bar. It is rendered with a multi-layered, pulsating glow to make it the clear focal point. Its color is determined by the quadrant it is in.
[b]The Velocity Vector:[/b] An arrow drawn from the current point, indicating its recent direction of travel through the phase space. This is a critical leading indicator, showing you the "momentum of the regime."
[b]The MTF Ghost Points (◆):[/b] These are the semi-transparent, diamond-shaped markers. Each ghost represents the position of a higher timeframe (e.g., 1H, 4H, Daily) within the same coordinate space.
[b]Alignment:[/b]If the ghost points are clustered near the current point, it signals strong multi-timeframe confluence.
[b]Divergence:[/b] If the current point is in the "Expansion" quadrant but the Daily ghost point is deep in the "Exhaustion" quadrant, it's a powerful warning of a potential macro reversal.
[image]https://www.tradingview.com/x/f6nvB3M6/[/image]

[b]DASHBOARD (THE LEGEND)[/b]
[b]Current Quadrant:[/b] A clear, color-coded readout of the market's current regime.
[b]MTF Quadrants:[/b] Displays the regime classification for each of your selected higher timeframes, allowing for quick confirmation of alignment.
[b]Axis Info:[/b] Explicitly tells you what the X and Y axes currently represent based on your selected "Visualization Mode."
[b]Confluence & Stress:[/b] Provides the numerical score for MTF alignment and the calculated "Stress Score."
[b]Earnings Block:[/b] For equity traders, this section automatically pulls and displays the latest earnings data (Actual vs. Estimate) and the resulting surprise percentage.
[b]How To Read Guide:[/b] A built-in legend that provides a quick reference for interpreting the various visual elements.
[image]https://www.tradingview.com/x/2Kf168b6/[/image]

[b]█ THE THREE ATLASES - A DEEP DIVE INTO THE MODES[/b]
[b]MODE 1: PHASE SPACE (The Classic)[/b]
[b]X-Axis: Trend Strength.[/b] A composite score derived from ADX, price position relative to a long-term MA, and the alignment of multiple EMAs. It measures the existence and quality of a directional trend. A value of 100 is a powerful, unambiguous trend.
[b]Y-Axis: Momentum.[/b] A composite score derived from RSI, ROC, and Stochastic RSI. It measures the velocity and acceleration of price.
[b]This mode answers:[/b] Is this a strong trend backed by momentum (Expansion), or is the momentum dying while the trend is still high (Exhaustion)? Is momentum starting to build from a low-trend base (Recovery)?

[b]MODE 2: STRESS ORBIT (The Risk Gauge)[/b]
[b]X-Axis: Volatility Rank.[/b] Measures the current ATR relative to its historical range over a long lookback. A value of 100 means volatility is at a multi-month high.
[b]Y-Axis: Market Stress.[/b] A proprietary score that blends Volatility Rank with Bollinger Band Width and a penalty for a lack of trend strength. It quantifies "unproductive" or "fearful" volatility.
[b]This mode answers:[/b] Is this a low-volatility, calm environment (Compression), or a high-stress, dangerous one (Exhaustion)? Is volatility starting to expand in a productive way (Expansion)?

[b]MODE 3: PERMISSION FIELD (The Go/No-Go)[/b]
[b]X-Axis: Directional Bias.[/b] A composite score of momentum oscillators, all pointing in the same direction. It measures the short-term directional pressure.
[b]Y-Axis: Permission Score.[/b] A proprietary score that asks if the underlying market conditions have "permission" to trend. It rewards low volatility, rewards existing trend strength, and rewards momentum.
[b]This mode answers:[/b] We have a strong directional bias, but do we have the low-volatility, high-trend-strength "permission" needed for a successful breakout (Expansion)? Or is the directional bias occurring in a high-volatility, low-trend environment where it's likely to fail (Exhaustion)?

[b]█ DEVELOPMENT PHILOSOPHY[/b]
[b]The Tactical Atlas was born from a need to escape the "tyranny of the single indicator." It is a tool for systems thinking. It is built on the belief that a market's true character cannot be understood by looking at any single metric in isolation, but by observing the interplay and relationships between multiple dimensions of data. By transforming this complex, multi-dimensional state into a simple, intuitive visual, we empower traders to make faster, more accurate, and more contextually-aware decisions. This is not just data visualization; it is the visualization of understanding.[/b]

[b]█ DISCLAIMER AND BEST PRACTICES[/b]
[b]THIS IS A CONTEXTUAL TOOL, NOT A SIGNAL GENERATOR:[/b] The Tactical Atlas is designed to provide you with a deep understanding of the market regime. Use this understanding to select the appropriate strategy (e.g., trend-following in Expansion, mean-reversion in Compression).
[b]RISK MANAGEMENT IS PARAMOUNT:[/b] All trading involves substantial risk.
[b]CONFLUENCE IS KEY:[/b] The most powerful insights come from confluence. A move of the current point into the Expansion quadrant is a good sign. That same move, while the higher timeframe "ghost points" are also in or moving towards Expansion, is an A++ signal that a major, multi-timeframe move is underway.
[b]STUDY THE TRAJECTORY:[/b] Do not just look at where the point is. Look at the trail. Where did it come from? How fast is it moving? The history and velocity of the point are often more important than its current location.

— Dskyz, Trade with insight. Trade with anticipation. (Don't follow the trend, be the trend)

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © DskyzInvestments — DAFE Trading Systems
// @version=6
indicator('Tactical Atlas [DAFE]', '⟡ TA', overlay = true, max_lines_count = 500, max_labels_count = 500, max_bars_back = 500, max_boxes_count = 500)
// ============================================================================
// ⟡ TACTICAL ATLAS [DAFE] — Phase Space Regime Visualizer
// ============================================================================
// Three visualization modes mapping regime state into 2D scatter space:
//   Phase Space:      X = Trend Strength,   Y = Momentum
//   Stress Orbit:     X = Volatility Rank,  Y = Market Stress
//   Permission Field: X = Directional Bias, Y = Permission Score
//
// Quadrants:  RECOVERY | EXPANSION | COMPRESSION | EXHAUSTION
// MTF:        Current (bright) · Weekly (mid) · Monthly (faint)
// Dashboard:  Regime context + native earnings + manual news/analyst
// ============================================================================
// INPUTS
// ============================================================================
// ── Scatter Engine ──
string i_viewMode    = input.string('Phase Space', 'Visualization Mode', options = ['Phase Space', 'Stress Orbit', 'Permission Field'], group = 'Scatter Engine')
int    i_tailBars    = input.int(30, 'Trail Length', minval = 4, maxval = 80, step = 1, group = 'Scatter Engine')
int    i_calcLen     = input.int(20, 'Calculation Window', minval = 5, maxval = 100, step = 1, group = 'Scatter Engine')
float  i_resolution  = input.float(80.0, 'Scatter Resolution', minval = 10.0, maxval = 300.0, step = 10.0, tooltip = 'Controls horizontal spread of scatter points. Higher = wider scatter.', group = 'Scatter Engine')
string i_chartSize   = input.string('medium', 'Chart Size', options = ['small', 'medium', 'large'], tooltip = 'Scales scatter width AND height (price band). Small = compact, Large = expansive.', group = 'Scatter Engine')
// ── Multi-Timeframe ──
string i_tf1         = input.timeframe('60',  'MTF 1 (Short)',  group = 'Multi-Timeframe', tooltip = 'Short-term context')
string i_tf2         = input.timeframe('240', 'MTF 2 (Medium)', group = 'Multi-Timeframe', tooltip = 'Medium-term context')
bool   i_useTF3      = input.bool(true, 'Enable MTF 3', group = 'Multi-Timeframe', tooltip = 'Turn off for 2-TF mode')
string i_tf3         = input.timeframe('D',   'MTF 3 (Long)',   group = 'Multi-Timeframe', tooltip = 'Long-term context (only used if enabled)')
// ── Regime ──
int    i_atrLen      = input.int(14, 'ATR Length', minval = 5, maxval = 50, group = 'Regime Detection')
int    i_rsiLen      = input.int(14, 'RSI Length', minval = 5, maxval = 50, group = 'Regime Detection')
int    i_maLen       = input.int(50, 'Trend MA Length', minval = 10, maxval = 200, group = 'Regime Detection')
int    i_volRankLen  = input.int(60, 'Volatility Rank Lookback', minval = 20, maxval = 200, group = 'Regime Detection')
// ── Display ──
string i_theme       = input.string('DAFE Signature', 'Theme', options = ['DAFE Signature', 'Neon', 'Cyber', 'Holographic', 'Ice', 'Blood'], group = 'Display')
string i_dashPos     = input.string('Bottom Left', 'Dashboard Position', options = ['Top Left', 'Top Center', 'Top Right', 'Middle Left', 'Middle Center', 'Middle Right', 'Bottom Left', 'Bottom Center', 'Bottom Right'], group = 'Display')
bool   i_showTrails  = input.bool(true, 'Show Trails', group = 'Display')
bool   i_showQuads   = input.bool(true, 'Show Quadrants', group = 'Display')
bool   i_showDash    = input.bool(true, 'Show Dashboard', group = 'Display')
bool   i_showEarn    = input.bool(true, 'Show Earnings Block', group = 'Display')
bool   i_showMTFGhost = input.bool(true, 'Show MTF Ghost Points on Scatter', group = 'Display')
bool   i_showHowTo   = input.bool(true, 'Show How-To Legend', group = 'Display')
// ============================================================================
// THEME ENGINE
// ============================================================================
type ThemeColors
    color bull
    color bear
    color neu
    color prim
    color sec
    color accent
    color ghost
    color bg
    color txt
    color field
    color tf1Color
    color tf2Color
    color tf3Color
    color recovery
    color expansion
    color compression
    color exhaustion
var ThemeColors TH = ThemeColors.new()
if barstate.isfirst
    switch i_theme
        'DAFE Signature' =>
            TH.bull := #00FF88, TH.bear := #FF0055, TH.neu := #9D00FF
            TH.prim := #BD00FF, TH.sec := #00FFAA, TH.accent := #C0C0FF
            TH.ghost := #9966FF, TH.bg := #0A0A14, TH.txt := #E0E0FF
            TH.field := #00CFFF
            TH.tf1Color := #FF00AA, TH.tf2Color := #FFCC00, TH.tf3Color := #00E5FF
            TH.recovery := #2962FF, TH.expansion := #00FF88
            TH.compression := #FF9800, TH.exhaustion := #FF0055
        'Neon' =>
            TH.bull := #39FF14, TH.bear := #FF3131, TH.neu := #FF00FF
            TH.prim := #FFFF00, TH.sec := #00FFFF, TH.accent := #FFFFFF
            TH.ghost := #FF00FF, TH.bg := #0A0A14, TH.txt := #E0E0FF
            TH.field := #00E5FF
            TH.tf1Color := #FF00FF, TH.tf2Color := #FFFF00, TH.tf3Color := #00FFFF
            TH.recovery := #00E5FF, TH.expansion := #39FF14
            TH.compression := #FFFF00, TH.exhaustion := #FF3131
        'Cyber' =>
            TH.bull := #00F0FF, TH.bear := #FF2A6D, TH.neu := #05D9E8
            TH.prim := #D1F7FF, TH.sec := #01242E, TH.accent := #005678
            TH.ghost := #FF2A6D, TH.bg := #0A0A14, TH.txt := #E0E0FF
            TH.field := #00C2FF
            TH.tf1Color := #FF2A6D, TH.tf2Color := #00F0FF, TH.tf3Color := #D1F7FF
            TH.recovery := #05D9E8, TH.expansion := #00F0FF
            TH.compression := #D1F7FF, TH.exhaustion := #FF2A6D
        'Holographic' =>
            TH.bull := #00F0FF, TH.bear := #FF0055, TH.neu := #C0C0FF
            TH.prim := #BD00FF, TH.sec := #00FFAA, TH.accent := #E0E0FF
            TH.ghost := #CC88FF, TH.bg := #0A0A14, TH.txt := #E0E0FF
            TH.field := #00F0FF
            TH.tf1Color := #FF00CC, TH.tf2Color := #00FFAA, TH.tf3Color := #00F0FF
            TH.recovery := #00F0FF, TH.expansion := #00FFAA
            TH.compression := #BD00FF, TH.exhaustion := #FF0055
        'Ice' =>
            TH.bull := #A5F2F3, TH.bear := #FF6B6B, TH.neu := #4ECDC4
            TH.prim := #45B7D1, TH.sec := #96CEB4, TH.accent := #D4E6F1
            TH.ghost := #A5F2F3, TH.bg := #0A0A14, TH.txt := #D4E6F1
            TH.field := #8BE9FD
            TH.tf1Color := #FF6B6B, TH.tf2Color := #96CEB4, TH.tf3Color := #8BE9FD
            TH.recovery := #8BE9FD, TH.expansion := #A5F2F3
            TH.compression := #45B7D1, TH.exhaustion := #FF6B6B
        'Blood' =>
            TH.bull := #FF4444, TH.bear := #8B0000, TH.neu := #FF0000
            TH.prim := #DC143C, TH.sec := #B22222, TH.accent := #FFD700
            TH.ghost := #FF6347, TH.bg := #0A0A14, TH.txt := #FFE6E6
            TH.field := #FF9800
            TH.tf1Color := #FFD700, TH.tf2Color := #FF6347, TH.tf3Color := #FF4444
            TH.recovery := #FF9800, TH.expansion := #FF4444
            TH.compression := #FFD700, TH.exhaustion := #8B0000
// ============================================================================
// GLOBALS
// ============================================================================
int sCut = bar_index > 0 ? 1 : 0
float g_close     = nz(close[sCut])
float g_high      = nz(high[sCut])
float g_low       = nz(low[sCut])
float g_open      = nz(open[sCut])
float g_atr       = ta.atr(i_atrLen)
float g_rsi       = ta.rsi(close, i_rsiLen)
float g_sma       = ta.sma(close, i_maLen)
float g_ema_fast  = ta.ema(close, 9)
float g_ema_slow  = ta.ema(close, 21)
float g_wma       = ta.wma(close, i_calcLen)
float g_stdev     = ta.stdev(close, i_calcLen)
float g_highest_c = ta.highest(close, i_volRankLen)
float g_lowest_c  = ta.lowest(close, i_volRankLen)
float g_highest_atr = ta.highest(g_atr, i_volRankLen)
float g_lowest_atr  = ta.lowest(g_atr, i_volRankLen)
float g_roc       = ta.roc(close, i_calcLen)
float g_stochRsi_k = ta.sma(ta.stoch(g_rsi, g_rsi, g_rsi, i_rsiLen), 3)
float g_chg_high    = ta.change(high)
float g_chg_low     = ta.change(low)
float g_neg_chg_low = -g_chg_low
float g_plus_di      = g_chg_high > g_neg_chg_low and g_chg_high > 0 ? g_chg_high : 0.0
float g_minus_di     = g_neg_chg_low > g_chg_high and g_neg_chg_low > 0 ? g_neg_chg_low : 0.0
float g_plus_smooth  = ta.ema(g_plus_di, i_atrLen)
float g_minus_smooth = ta.ema(g_minus_di, i_atrLen)
float g_di_sum       = g_plus_smooth + g_minus_smooth
float g_dx           = g_di_sum > 0 ? math.abs(g_plus_smooth - g_minus_smooth) / g_di_sum * 100.0 : 0.0
float g_adx          = ta.ema(g_dx, i_atrLen)
float g_bb_upper     = g_sma + 2.0 * g_stdev
float g_bb_lower     = g_sma - 2.0 * g_stdev
float g_bb_width     = g_sma > 0 ? (g_bb_upper - g_bb_lower) / g_sma * 100.0 : 0.0
float g_bb_width_sma = ta.sma(g_bb_width, i_volRankLen)
float g_wma_ratio_raw = g_wma > 0 ? close / g_wma : 1.0
float g_wma_ratio     = ta.wma(g_wma_ratio_raw, i_calcLen) * 100.0
float g_wma_ratio_wma = ta.wma(g_wma_ratio, i_calcLen)
float g_wma_ratio_mom = g_wma_ratio_wma > 0 ? g_wma_ratio / g_wma_ratio_wma * 100.0 : 100.0
// ============================================================================
// REGIME COMPUTATION ENGINE
// ============================================================================
float _volRange = g_highest_atr - g_lowest_atr
float volRank   = _volRange > 0 ? (g_atr - g_lowest_atr) / _volRange * 100.0 : 50.0
float _pricePos = g_highest_c - g_lowest_c > 0 ? (close - g_lowest_c) / (g_highest_c - g_lowest_c) * 100.0 : 50.0
float _maAlign  = g_ema_fast > g_ema_slow ? math.min((g_ema_fast - g_ema_slow) / g_atr * 25.0, 50.0) : -math.min((g_ema_slow - g_ema_fast) / g_atr * 25.0, 50.0)
float trendStr  = math.max(0.0, math.min(100.0, g_adx * 0.4 + _pricePos * 0.35 + (_maAlign + 50.0) * 0.25))
float _rocNorm  = 50.0 + math.max(-50.0, math.min(50.0, g_roc * 5.0))
float momScore  = math.max(0.0, math.min(100.0, g_rsi * 0.35 + _rocNorm * 0.35 + g_stochRsi_k * 0.30))
float _bbStress   = g_bb_width_sma > 0 ? math.min(g_bb_width / g_bb_width_sma * 50.0, 100.0) : 50.0
float stressScore = math.max(0.0, math.min(100.0, volRank * 0.40 + _bbStress * 0.35 + (100.0 - trendStr) * 0.25))
float _dirRaw     = (g_rsi - 50.0) * 0.30 + (g_ema_fast > g_ema_slow ? 15.0 : -15.0) + math.max(-20.0, math.min(20.0, g_roc * 2.0))
float dirBias     = math.max(0.0, math.min(100.0, _dirRaw + 50.0))
float _volPerm    = volRank < 70.0 ? (70.0 - volRank) / 70.0 * 40.0 : -((volRank - 70.0) / 30.0 * 20.0)
float _trendPerm  = trendStr > 40.0 ? (trendStr - 40.0) / 60.0 * 35.0 : -(40.0 - trendStr) / 40.0 * 15.0
float _momPerm    = math.abs(momScore - 50.0) / 50.0 * 25.0
float permScore   = math.max(0.0, math.min(100.0, 50.0 + _volPerm + _trendPerm + _momPerm))
// ============================================================================
// QUADRANT CLASSIFICATION
// ============================================================================
_getXY() =>
    float xVal = 50.0
    float yVal = 50.0
    switch i_viewMode
        'Phase Space' =>
            xVal := trendStr
            yVal := momScore
        'Stress Orbit' =>
            xVal := volRank
            yVal := stressScore
        'Permission Field' =>
            xVal := dirBias
            yVal := permScore
    [xVal, yVal]
[scatterX, scatterY] = _getXY()
_classifyQuadrant(float x, float y) =>
    string q = ''
    if x < 50.0 and y >= 50.0
        q := 'RECOVERY'
    else if x >= 50.0 and y >= 50.0
        q := 'EXPANSION'
    else if x < 50.0 and y < 50.0
        q := 'COMPRESSION'
    else
        q := 'EXHAUSTION'
    q
string currentQuad = _classifyQuadrant(scatterX, scatterY)
// ============================================================================
// MTF
// ============================================================================
float g_tf1_rsi  = request.security(syminfo.tickerid, i_tf1, ta.rsi(close, i_rsiLen), lookahead = barmerge.lookahead_on)
float g_tf1_adx  = request.security(syminfo.tickerid, i_tf1, g_adx, lookahead = barmerge.lookahead_on)
float g_tf1_roc  = request.security(syminfo.tickerid, i_tf1, ta.roc(close, i_calcLen), lookahead = barmerge.lookahead_on)
float g_tf2_rsi  = request.security(syminfo.tickerid, i_tf2, ta.rsi(close, i_rsiLen), lookahead = barmerge.lookahead_on)
float g_tf2_adx  = request.security(syminfo.tickerid, i_tf2, g_adx, lookahead = barmerge.lookahead_on)
float g_tf2_roc  = request.security(syminfo.tickerid, i_tf2, ta.roc(close, i_calcLen), lookahead = barmerge.lookahead_on)
float g_tf3_rsi  = request.security(syminfo.tickerid, i_tf3, ta.rsi(close, i_rsiLen), lookahead = barmerge.lookahead_on)
float g_tf3_adx  = request.security(syminfo.tickerid, i_tf3, g_adx, lookahead = barmerge.lookahead_on)
float g_tf3_roc  = request.security(syminfo.tickerid, i_tf3, ta.roc(close, i_calcLen), lookahead = barmerge.lookahead_on)
_classifyMTF(float mtfRsi, float mtfAdx, float mtfRoc) =>
    float ts = math.max(0.0, math.min(100.0, nz(mtfAdx) * 0.5 + 25.0))
    float ms = math.max(0.0, math.min(100.0, nz(mtfRsi) * 0.5 + (50.0 + math.max(-50.0, math.min(50.0, nz(mtfRoc) * 5.0))) * 0.5))
    _classifyQuadrant(ts, ms)
string tf1Quad = _classifyMTF(g_tf1_rsi, g_tf1_adx, g_tf1_roc)
string tf2Quad = _classifyMTF(g_tf2_rsi, g_tf2_adx, g_tf2_roc)
string tf3Quad = _classifyMTF(g_tf3_rsi, g_tf3_adx, g_tf3_roc)
// ============================================================================
// CONFLUENCE & ALIGNMENT
// ============================================================================
int _tfCount     = i_useTF3 ? 3 : 2
int _matchCount  = (currentQuad == tf1Quad ? 1 : 0) + (currentQuad == tf2Quad ? 1 : 0) + (i_useTF3 and currentQuad == tf3Quad ? 1 : 0)
float _confluencePct = _matchCount / float(_tfCount) * 100.0
string _alignment    = _matchCount == _tfCount ? 'FULL' : _matchCount == _tfCount - 1 ? 'STRONG' : _matchCount >= 1 ? 'PARTIAL' : 'DIVERGED'
string _confLabel    = str.tostring(math.round(_confluencePct)) + '%'
// ============================================================================
// SCATTER PLOT ENGINE
// ============================================================================
type ScatterPoint
    float xMetric
    float yMetric
var array<ScatterPoint> g_trail = array.new<ScatterPoint>(0)
if scatterX != scatterX[1] or scatterY != scatterY[1] or barstate.islast
    g_trail.unshift(ScatterPoint.new(scatterX, scatterY))
    if g_trail.size() > i_tailBars
        g_trail.pop()
_quadColor(string q) =>
    color c = na
    switch q
        'RECOVERY'    => c := TH.recovery
        'EXPANSION'   => c := TH.expansion
        'COMPRESSION' => c := TH.compression
        'EXHAUSTION'  => c := TH.exhaustion
    c
_fmtTF(string tf) =>
    string r = tf
    int m = int(nz(str.tonumber(tf)))
    if m > 0
        if m < 60
            r := str.tostring(m) + 'm'
        else if m == 60
            r := '1H'
        else if m < 1440 and m % 60 == 0
            r := str.tostring(m / 60) + 'H'
        else if m == 1440
            r := '1D'
        else
            r := str.tostring(m) + 'm'
    r
// ============================================================================
// MTF SCATTER POINTS
// ============================================================================
_mtfXY(float mtfRsi, float mtfAdx, float mtfRoc) =>
    float _ts = math.max(0.0, math.min(100.0, nz(mtfAdx) * 0.5 + 25.0))
    float _ms = math.max(0.0, math.min(100.0, nz(mtfRsi) * 0.5 + (50.0 + math.max(-50.0, math.min(50.0, nz(mtfRoc) * 5.0))) * 0.5))
    [_ts, _ms]
[tf1X, tf1Y] = _mtfXY(g_tf1_rsi, g_tf1_adx, g_tf1_roc)
[tf2X, tf2Y] = _mtfXY(g_tf2_rsi, g_tf2_adx, g_tf2_roc)
[tf3X, tf3Y] = _mtfXY(g_tf3_rsi, g_tf3_adx, g_tf3_roc)

// ============================================================================
// SCATTER CHART
// ============================================================================
if barstate.islast and g_trail.size() > 0
    float _sizeMult = i_chartSize == 'small' ? 0.6 : i_chartSize == 'large' ? 1.6 : 1.0
    int   _w_bars  = int(i_resolution * _sizeMult)  
    int   _gap     = 5                         
    int   _left    = bar_index + _gap
    int   _right   = _left + _w_bars
    int   _cx      = _left + _w_bars / 2
    float _band    = g_atr * 14.0 * _sizeMult
    float _yTop    = close + _band / 2.0
    float _yBot    = close - _band / 2.0
    float _yMid    = close
    float _q1  = _yBot + 0.25 * _band
    float _q3  = _yBot + 0.75 * _band
    int   _qx1 = _left + _w_bars / 4
    int   _qx3 = _left + (_w_bars * 3) / 4
    color _curC = _quadColor(currentQuad)
    // ─── QUADRANT FIELDS ───
    if i_showQuads
        box.delete(box.new(_left, _yTop, _cx, _yMid, border_color = color.new(TH.recovery, 100),    bgcolor = color.new(TH.recovery, 94))[1])
        box.delete(box.new(_cx, _yTop, _right, _yMid, border_color = color.new(TH.expansion, 100),  bgcolor = color.new(TH.expansion, 92))[1])
        box.delete(box.new(_left, _yMid, _cx, _yBot, border_color = color.new(TH.compression, 100), bgcolor = color.new(TH.compression, 94))[1])
        box.delete(box.new(_cx, _yMid, _right, _yBot, border_color = color.new(TH.exhaustion, 100), bgcolor = color.new(TH.exhaustion, 92))[1])
        box.delete(box.new(_left, _yTop, _qx1, _q3, border_color = color.new(TH.recovery, 100),     bgcolor = color.new(TH.recovery, 86))[1])
        box.delete(box.new(_qx3, _yTop, _right, _q3, border_color = color.new(TH.expansion, 100),   bgcolor = color.new(TH.expansion, 80))[1])
        box.delete(box.new(_left, _q1, _qx1, _yBot, border_color = color.new(TH.compression, 100),  bgcolor = color.new(TH.compression, 86))[1])
        box.delete(box.new(_qx3, _q1, _right, _yBot, border_color = color.new(TH.exhaustion, 100),  bgcolor = color.new(TH.exhaustion, 80))[1])
        box.delete(box.new(_left, _yTop, _right, _yBot, border_color = color.new(TH.prim, 50), border_width = 1, bgcolor = color(na))[1])
        label.delete(label.new(_left,  _yTop, ' RECOVERY ',    style = label.style_label_lower_right, color = color.new(TH.recovery, 70),    textcolor = TH.recovery,    size = size.small, text_font_family = font.family_monospace)[1])
        label.delete(label.new(_right, _yTop, ' EXPANSION ',   style = label.style_label_lower_left,  color = color.new(TH.expansion, 70),   textcolor = TH.expansion,   size = size.small, text_font_family = font.family_monospace)[1])
        label.delete(label.new(_left,  _yBot, ' COMPRESSION ', style = label.style_label_upper_right, color = color.new(TH.compression, 70), textcolor = TH.compression, size = size.small, text_font_family = font.family_monospace)[1])
        label.delete(label.new(_right, _yBot, ' EXHAUSTION ',  style = label.style_label_upper_left,  color = color.new(TH.exhaustion, 70),  textcolor = TH.exhaustion,  size = size.small, text_font_family = font.family_monospace)[1])
    // ─── GRIDLINES ───
    line.delete(line.new(_left, _q3, _right, _q3, color = color.new(TH.txt, 88), style = line.style_dotted, width = 1)[1])
    line.delete(line.new(_left, _yMid, _right, _yMid, color = color.new(TH.field, 60), style = line.style_dashed, width = 1)[1])
    line.delete(line.new(_left, _q1, _right, _q1, color = color.new(TH.txt, 88), style = line.style_dotted, width = 1)[1])
    line.delete(line.new(_qx1, _yBot, _qx1, _yTop, color = color.new(TH.txt, 88), style = line.style_dotted, width = 1)[1])
    line.delete(line.new(_cx, _yBot, _cx, _yTop, color = color.new(TH.field, 60), style = line.style_dashed, width = 1)[1])
    line.delete(line.new(_qx3, _yBot, _qx3, _yTop, color = color.new(TH.txt, 88), style = line.style_dotted, width = 1)[1])
    string _xLabel = i_viewMode == 'Phase Space' ? 'TREND →' : i_viewMode == 'Stress Orbit' ? 'VOL RANK →' : 'BIAS →'
    string _yLabel = i_viewMode == 'Phase Space' ? 'MOMENTUM ↑' : i_viewMode == 'Stress Orbit' ? 'STRESS ↑' : 'PERMISSION ↑'
    label.delete(label.new(_left, _yMid, ' ' + _xLabel, style = label.style_label_left, color = color(na), textcolor = TH.field, size = size.small, text_font_family = font.family_monospace)[1])
    label.delete(label.new(_cx, _yBot, _yLabel + ' ', style = label.style_label_down, color = color(na), textcolor = TH.field, size = size.small, text_font_family = font.family_monospace)[1])
    // ─── VELOCITY-AWARE TRAIL POLYLINE ───
    if i_showTrails and g_trail.size() > 1
        array<chart.point> pts = array.new<chart.point>(0)
        for i = 0 to g_trail.size() - 1
            ScatterPoint sp = g_trail.get(g_trail.size() - 1 - i) 
            pts.push(chart.point.from_index((_left + int((sp.xMetric) * 0.01 * _w_bars)), (_yBot + (sp.yMetric) * 0.01 * _band)))
        polyline.delete(polyline.new(pts, line_color = color.new(_curC, 80), line_width = 4)[1])
        polyline.delete(polyline.new(pts, line_color = color.new(_curC, 40), line_width = 2)[1])
    // ─── TRAIL DOTS ───
    int _tSize = g_trail.size()
    for i = 0 to _tSize - 1
        ScatterPoint sp = g_trail.get(i)
        int   _px = (_left + int((sp.xMetric) * 0.01 * _w_bars))
        float _py = (_yBot + (sp.yMetric) * 0.01 * _band)
        if i > 0  
            int _alpha = math.min(92, int(40 + i * 60 / math.max(_tSize, 1)))
            label.delete(label.new(_px, _py, '•', style = label.style_label_center, color = color(na), textcolor = color.new(TH.ghost, _alpha), size = size.tiny)[1])
    // ─── VELOCITY VECTOR ───
    if g_trail.size() >= 3
        ScatterPoint sp0 = g_trail.get(0)
        ScatterPoint sp2 = g_trail.get(2)
        float _dx = sp0.xMetric - sp2.xMetric
        float _dy = sp0.yMetric - sp2.yMetric
        float _mag = math.sqrt(_dx * _dx + _dy * _dy)
        if _mag > 1.0
            float _ext = math.min(_mag * 2.5, 20.0)
            float _projX = math.max(0.0, math.min(100.0, sp0.xMetric + _dx / _mag * _ext))
            float _projY = math.max(0.0, math.min(100.0, sp0.yMetric + _dy / _mag * _ext))
            int   _cpx = (_left + int((sp0.xMetric) * 0.01 * _w_bars))
            float _cpy = (_yBot + (sp0.yMetric) * 0.01 * _band)
            int   _ppx = (_left + int((_projX) * 0.01 * _w_bars))
            float _ppy = (_yBot + (_projY) * 0.01 * _band)
            line.delete(line.new(_cpx, _cpy, _ppx, _ppy, color = color.new(TH.accent, 30), style = line.style_arrow_right, width = 2)[1])
    // ─── COMPUTE CURRENT POINT POSITION ───
    ScatterPoint _cur = g_trail.get(0)
    int   _curPX = (_left + int((_cur.xMetric) * 0.01 * _w_bars))
    float _curPY = (_yBot + (_cur.yMetric) * 0.01 * _band)
    // ─── MTF GHOST POINTS ───
    if i_showMTFGhost
        int   _t1PX = (_left + int((tf1X) * 0.01 * _w_bars))
        float _t1PY = (_yBot + (tf1Y) * 0.01 * _band)
        int   _t2PX = (_left + int((tf2X) * 0.01 * _w_bars))
        float _t2PY = (_yBot + (tf2Y) * 0.01 * _band)
        label.delete(label.new(_t1PX, _t1PY, '●', style = label.style_label_center, color = color(na), textcolor = color.new(TH.tf1Color, 75), size = size.large)[1])
        label.delete(label.new(_t1PX, _t1PY, '●', style = label.style_label_center, color = color(na), textcolor = color.new(TH.tf1Color, 50), size = size.normal)[1])
        label.delete(label.new(_t1PX, _t1PY, '◆', style = label.style_label_center, color = color(na), textcolor = TH.tf1Color, size = size.small)[1])
        label.delete(label.new(_t1PX, _t1PY, _fmtTF(i_tf1), style = label.style_label_down, color = color.new(TH.tf1Color, 70), textcolor = color.new(#FFFFFF, 0), size = size.tiny, text_font_family = font.family_monospace)[1])
        label.delete(label.new(_t2PX, _t2PY, '●', style = label.style_label_center, color = color(na), textcolor = color.new(TH.tf2Color, 75), size = size.large)[1])
        label.delete(label.new(_t2PX, _t2PY, '●', style = label.style_label_center, color = color(na), textcolor = color.new(TH.tf2Color, 50), size = size.normal)[1])
        label.delete(label.new(_t2PX, _t2PY, '◆', style = label.style_label_center, color = color(na), textcolor = TH.tf2Color, size = size.small)[1])
        label.delete(label.new(_t2PX, _t2PY, _fmtTF(i_tf2), style = label.style_label_down, color = color.new(TH.tf2Color, 70), textcolor = color.new(#FFFFFF, 0), size = size.tiny, text_font_family = font.family_monospace)[1])
        if i_useTF3
            int   _t3PX = (_left + int((tf3X) * 0.01 * _w_bars))
            float _t3PY = (_yBot + (tf3Y) * 0.01 * _band)
            label.delete(label.new(_t3PX, _t3PY, '●', style = label.style_label_center, color = color(na), textcolor = color.new(TH.tf3Color, 75), size = size.large)[1])
            label.delete(label.new(_t3PX, _t3PY, '●', style = label.style_label_center, color = color(na), textcolor = color.new(TH.tf3Color, 50), size = size.normal)[1])
            label.delete(label.new(_t3PX, _t3PY, '◆', style = label.style_label_center, color = color(na), textcolor = TH.tf3Color, size = size.small)[1])
            label.delete(label.new(_t3PX, _t3PY, _fmtTF(i_tf3), style = label.style_label_down, color = color.new(TH.tf3Color, 70), textcolor = color.new(#FFFFFF, 0), size = size.tiny, text_font_family = font.family_monospace)[1])
    // ─── CURRENT POINT ───
    label.delete(label.new(_curPX, _curPY, '●', style = label.style_label_center, color = color(na), textcolor = color.new(_curC, 70), size = size.huge)[1])
    label.delete(label.new(_curPX, _curPY, '●', style = label.style_label_center, color = color(na), textcolor = color.new(_curC, 40), size = size.large)[1])
    label.delete(label.new(_curPX, _curPY, '●', style = label.style_label_center, color = color(na), textcolor = color.new(_curC, 10), size = size.normal)[1])
    label.delete(label.new(_curPX, _curPY, '◆', style = label.style_label_center, color = color(na), textcolor = TH.prim, size = size.small)[1])
    // ─── CONFLUENCE RING ───
    if _confluencePct >= 99.0
        array<chart.point> ringPts = array.new<chart.point>(0)
        float _ringR_x = _w_bars / 14.0
        float _ringR_y = _band / 14.0
        for k = 0 to 24
            float _theta = k * 2.0 * 3.14159 / 24.0
            int   _rx = _curPX + int(math.cos(_theta) * _ringR_x)
            float _ry = _curPY + math.sin(_theta) * _ringR_y
            ringPts.push(chart.point.from_index(_rx, _ry))
        polyline.delete(polyline.new(ringPts, line_color = color.new(TH.bull, 30), line_width = 2, closed = true)[1])
        array<chart.point> ringPts2 = array.new<chart.point>(0)
        for k = 0 to 24
            float _theta = k * 2.0 * 3.14159 / 24.0
            int   _rx = _curPX + int(math.cos(_theta) * _ringR_x * 1.4)
            float _ry = _curPY + math.sin(_theta) * _ringR_y * 1.4
            ringPts2.push(chart.point.from_index(_rx, _ry))
        polyline.delete(polyline.new(ringPts2, line_color = color.new(TH.bull, 70), line_width = 1, closed = true)[1])
    // ─── TITLE BAR WITH LIVE COORDINATES ───
    string _titleTxt = '◆ TACTICAL ATLAS ◆'
    label.delete(label.new(_cx, _yTop + g_atr * 2.0, _titleTxt, style = label.style_label_down, color = color.new(TH.prim, 70), textcolor = TH.prim, size = size.normal, text_font_family = font.family_monospace)[1])
    string _coordTxt = _xLabel + ' ' + str.tostring(scatterX, '#.0') + '  │  ' + _yLabel + ' ' + str.tostring(scatterY, '#.0') + '  │  ' + currentQuad
    label.delete(label.new(_cx, _yBot - g_atr * 1.0, _coordTxt, style = label.style_label_up, color = color.new(TH.bg, 30), textcolor = _curC, size = size.small, text_font_family = font.family_monospace)[1])
// ============================================================================
// EARNINGS DATA
// ============================================================================
float earnEPS = request.earnings(syminfo.tickerid, earnings.actual, barmerge.gaps_on, lookahead = barmerge.lookahead_on)
float earnEST = request.earnings(syminfo.tickerid, earnings.estimate, barmerge.gaps_on, lookahead = barmerge.lookahead_on)
var float lastEPS    = na
var float lastEPSest = na
if not na(earnEPS)
    lastEPS := earnEPS
if not na(earnEST)
    lastEPSest := earnEST
float epsSurprise = not na(lastEPS) and not na(lastEPSest) and lastEPSest != 0 ? (lastEPS - lastEPSest) / math.abs(lastEPSest) * 100.0 : na
// ============================================================================
// DASHBOARD
// ============================================================================
if barstate.islast and i_showDash
    int cols = 4
    string _dashPos = i_dashPos == 'Top Left'      ? position.top_left :
                     i_dashPos == 'Top Center'    ? position.top_center :
                     i_dashPos == 'Top Right'     ? position.top_right :
                     i_dashPos == 'Middle Left'   ? position.middle_left :
                     i_dashPos == 'Middle Center' ? position.middle_center :
                     i_dashPos == 'Middle Right'  ? position.middle_right :
                     i_dashPos == 'Bottom Center' ? position.bottom_center :
                     i_dashPos == 'Bottom Right'  ? position.bottom_right :
                     position.bottom_left
    var table dash = table.new(_dashPos, cols, 30, bgcolor = TH.bg, border_color = color.new(TH.prim, 80), border_width = 1, frame_color = color.new(TH.prim, 60), frame_width = 2)
    int r = 0
    table.cell(dash, 0, r, '◆ TACTICAL ATLAS ◆', text_color = TH.prim, text_size = size.normal, bgcolor = color.new(TH.prim, 88), text_halign = text.align_center)
    table.merge_cells(dash, 0, r, cols - 1, r)
    r += 1
    table.cell(dash, 0, r, 'Sym: ' + syminfo.ticker, text_color = TH.txt, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, r, 'Mode: ' + i_viewMode, text_color = TH.field, text_size = size.small, text_halign = text.align_center)
    table.merge_cells(dash, 1, r, 2, r)
    table.cell(dash, 3, r, 'Align: ' + _alignment, text_color = _matchCount == 3 ? TH.bull : _matchCount == 2 ? TH.accent : _matchCount == 1 ? TH.field : TH.bear, text_size = size.small, text_halign = text.align_right)
    r += 1
    color _curQC = _quadColor(currentQuad)
    table.cell(dash, 0, r, 'CURRENT: ' + currentQuad, text_color = _curQC, text_size = size.small, text_halign = text.align_center, bgcolor = color.new(_curQC, 80))
    table.merge_cells(dash, 0, r, cols - 1, r)
    r += 1
    if i_useTF3
        table.cell(dash, 0, r, _fmtTF(i_tf1) + ': ' + tf1Quad, text_color = _quadColor(tf1Quad), text_size = size.tiny, text_halign = text.align_center, bgcolor = color.new(_quadColor(tf1Quad), 88))
        table.cell(dash, 1, r, _fmtTF(i_tf2) + ': ' + tf2Quad, text_color = _quadColor(tf2Quad), text_size = size.tiny, text_halign = text.align_center, bgcolor = color.new(_quadColor(tf2Quad), 88))
        table.merge_cells(dash, 1, r, 2, r)
        table.cell(dash, 3, r, _fmtTF(i_tf3) + ': ' + tf3Quad, text_color = _quadColor(tf3Quad), text_size = size.tiny, text_halign = text.align_center, bgcolor = color.new(_quadColor(tf3Quad), 88))
    else
        table.cell(dash, 0, r, _fmtTF(i_tf1) + ': ' + tf1Quad, text_color = _quadColor(tf1Quad), text_size = size.tiny, text_halign = text.align_center, bgcolor = color.new(_quadColor(tf1Quad), 88))
        table.merge_cells(dash, 0, r, 1, r)
        table.cell(dash, 2, r, _fmtTF(i_tf2) + ': ' + tf2Quad, text_color = _quadColor(tf2Quad), text_size = size.tiny, text_halign = text.align_center, bgcolor = color.new(_quadColor(tf2Quad), 88))
        table.merge_cells(dash, 2, r, 3, r)
    r += 1
    string _xLbl = i_viewMode == 'Phase Space' ? 'Trend Strength' : i_viewMode == 'Stress Orbit' ? 'Volatility Rank' : 'Directional Bias'
    string _yLbl = i_viewMode == 'Phase Space' ? 'Momentum' : i_viewMode == 'Stress Orbit' ? 'Market Stress' : 'Permission'
    table.cell(dash, 0, r, 'X: ' + _xLbl, text_color = TH.field, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, r, 'Y: ' + _yLbl, text_color = TH.field, text_size = size.tiny, text_halign = text.align_center)
    table.cell(dash, 2, r, 'Conf: ' + _confLabel, text_color = TH.accent, text_size = size.tiny, text_halign = text.align_center)
    table.cell(dash, 3, r, 'Stress: ' + str.tostring(math.round(stressScore, 1)), text_color = stressScore > 70 ? TH.bear : stressScore > 40 ? TH.accent : TH.bull, text_size = size.tiny, text_halign = text.align_right)
    r += 1
    table.cell(dash, 0, r, 'RECOVERY', text_color = TH.recovery, text_size = size.tiny, text_halign = text.align_center, bgcolor = color.new(TH.recovery, 88))
    table.cell(dash, 1, r, 'EXPANSION', text_color = TH.expansion, text_size = size.tiny, text_halign = text.align_center, bgcolor = color.new(TH.expansion, 88))
    table.cell(dash, 2, r, 'COMPRESSION', text_color = TH.compression, text_size = size.tiny, text_halign = text.align_center, bgcolor = color.new(TH.compression, 88))
    table.cell(dash, 3, r, 'EXHAUSTION', text_color = TH.exhaustion, text_size = size.tiny, text_halign = text.align_center, bgcolor = color.new(TH.exhaustion, 88))
    r += 1
    if i_showHowTo
        table.cell(dash, 0, r, 'HOW TO READ THIS', text_color = TH.prim, text_size = size.tiny, bgcolor = color.new(TH.prim, 88), text_halign = text.align_center)
        table.merge_cells(dash, 0, r, cols - 1, r)
        r += 1
        table.cell(dash, 0, r, 'X = regime strength / directional pressure', text_color = color.new(TH.txt, 30), text_size = size.tiny, text_halign = text.align_center)
        table.merge_cells(dash, 0, r, cols - 1, r)
        r += 1
        table.cell(dash, 0, r, 'Y = momentum / stress / permission by mode', text_color = color.new(TH.txt, 30), text_size = size.tiny, text_halign = text.align_center)
        table.merge_cells(dash, 0, r, cols - 1, r)
        r += 1
        table.cell(dash, 0, r, '◇ Ghost points = MTF positions in same coord space', text_color = color.new(TH.txt, 30), text_size = size.tiny, text_halign = text.align_center)
        table.merge_cells(dash, 0, r, cols - 1, r)
        r += 1
        table.cell(dash, 0, r, '↗ Velocity arrow = direction of regime travel', text_color = color.new(TH.txt, 30), text_size = size.tiny, text_halign = text.align_center)
        table.merge_cells(dash, 0, r, cols - 1, r)
        r += 1
    if i_showEarn
        table.cell(dash, 0, r, 'EARNINGS', text_color = TH.prim, text_size = size.tiny, bgcolor = color.new(TH.prim, 88), text_halign = text.align_center)
        table.merge_cells(dash, 0, r, cols - 1, r)
        r += 1
        string _epsActStr = not na(lastEPS) ? 'EPS: $' + str.tostring(lastEPS, '#.##') : 'EPS: —'
        string _epsEstStr = not na(lastEPSest) ? 'Est: $' + str.tostring(lastEPSest, '#.##') : 'Est: —'
        string _surpStr   = not na(epsSurprise) ? (epsSurprise >= 0 ? '+' : '') + str.tostring(math.round(epsSurprise, 1)) + '%' : '—'
        color  _surpClr   = not na(epsSurprise) ? (epsSurprise >= 0 ? TH.bull : TH.bear) : TH.txt
        table.cell(dash, 0, r, _epsActStr, text_color = TH.bull, text_size = size.tiny, text_halign = text.align_left)
        table.cell(dash, 1, r, _epsEstStr, text_color = TH.txt, text_size = size.tiny, text_halign = text.align_center)
        table.merge_cells(dash, 1, r, 2, r)
        table.cell(dash, 3, r, _surpStr, text_color = _surpClr, text_size = size.tiny, text_halign = text.align_right)
        r += 1
    table.cell(dash, 0, r, 'DskyzInvestments — DAFE Trading Systems ◆', text_color = color.new(TH.prim, 50), text_size = size.tiny, text_halign = text.align_center)
    table.merge_cells(dash, 0, r, cols - 1, r)
// ============================================================================
// PLOT
// ============================================================================
color barClr = _quadColor(currentQuad)
barcolor(color.new(barClr, 40))
bgcolor(color.new(barClr, 95))
// ============================================================================
// ALERTS
// ============================================================================
alertcondition(currentQuad != currentQuad[1], 'Regime Change', 'Tactical Atlas: Regime changed')
alertcondition(currentQuad == 'EXPANSION' and currentQuad[1] != 'EXPANSION', 'Enter Expansion', 'Tactical Atlas: Entered EXPANSION quadrant')
alertcondition(currentQuad == 'COMPRESSION' and currentQuad[1] != 'COMPRESSION', 'Enter Compression', 'Tactical Atlas: Entered COMPRESSION quadrant')
alertcondition(_confluencePct >= 99.0 and _confluencePct[1] < 99.0, 'Full Alignment', 'Tactical Atlas: Full MTF alignment achieved')
````
