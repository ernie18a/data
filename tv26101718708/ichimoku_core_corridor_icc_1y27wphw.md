# Ichimoku Core Corridor (ICC)

- url: https://www.tradingview.com/script/1Y27WPHW/
- type: indicator
- pine_id: PUB;e3a8bb464929454fb5ddc22e7a63cf5b
- version: 1.0

## Description

🚀 Ichimoku Core Corridor (ICC)

The Ichimoku Core Corridor (ICC) is an institutional-grade, quantitative trend architecture designed to isolate market directionality and eliminate chart clutter. Conceptually built upon a radical optimization of Goichi Hosoda’s traditional Ichimoku Kumo logic and inspired by the technical implementations of Kıvanç Özbilgiç (@kivancozbilgic), this specific premium tool has been developed and engineered by @gunebak4n to isolate the true mathematical heart of the system: the interaction between Tenkansen (Short-Term Equilibrium) and Kijunsen (Medium-Term Trend Backbone).

Unlike standard Ichimoku setups that flood the screen with overwhelming lines, ICC transforms these core components into a dynamic, price-relative "Corridor / Plot". This gives professional traders immediate clarity on macro-regime shifts, compression zones, and institutional trend expansion.

💡 Key Features

🧠 Core Equilibrium Corridor: By treating the space between Tenkansen and Kijunsen as a unified geometric entity, ICC tracks real-time equilibrium. The corridor automatically dynamically adapts: turning Emerald Green during bullish expansion and Rose Red during bearish dominance.

🛡️ Noise-Reduction Engine: To protect traders from cognitive fatigue and high-frequency market noise, the raw Tenkansen and Kijunsen lines are mathematically mapped but completely hidden by default. Only the high-probability trend corridor remains visible, ensuring clean price-action analysis.

📊 Dual-Cloud Independent Control: ICC includes a fully integrated, modern implementation of the traditional Ichimoku Kumo Cloud. Both the custom Core Corridor (ICC) and the traditional cloud can be independently toggled, customized, and blended via the user dashboard to create a comprehensive multi-timeframe perspective—making it an absolute game-changer, hayatım.

⚡ Predictive Phase-Shift Signals: Armed with real-time momentum change detection, ICC plots discrete directional triangles at the exact bar where equilibrium flips. This prevents chasing late breakouts and locks entries into the birth of new micro-trends.

🔬 Mathematical Logic and Interaction

ICC acts as a dynamic spatial spread model. The indicator tracks the expansion and contraction of the two core lines, while simultaneously monitoring their physical intersection with the 26-period forward-shifted Senkou Span A and Senkou Span B boundaries.

Formulas: 
Tenkansen = (Highest High + Lowest Low) / 2 over a rolling 9-period lookback.
Kijunsen = (Highest High + Lowest Low) / 2 over a rolling 26-period lookback.

The indicator maps the maximum and minimum boundaries of both fields on the active bar. When the fast-moving Core Corridor physically intersects or penetrates the boundaries of the traditional Kumo cloud, it triggers a high-order structural crossover signal.

🛠️ How to Use

1. The Dynamic Corridor Ride: As long as price remains structured above the Emerald Green Corridor, the bullish macro-regime is completely intact. Avoid shorting or counter-trend scalping.
2. The Equilibrium Reversion (Chop): When price action gets trapped inside the Core Corridor, the market is in a temporary state of maximum balance (Accumulation/Distribution). Look for a breakout close outside the corridor boundaries.
3. Shape Momentum Triggers: Watch for the print of the Emerald Green Up-Triangle (Bullish Shift) or Rose Red Down-Triangle (Bearish Shift) to signal high-probability momentum entries.
4. Macro Cloud Intersection Backgrounds: When the entire Core Corridor physically crosses above the traditional cloud boundaries, a full background canvas flash is injected (Green for Bullish Cross, Red for Bearish Cross). This signals that short-term velocity has officially broken macro resistance.

🎛️ Settings

Tenkansen Period (9): Controls the short-term lookback filter for the fast equilibrium line. Optimize to 12 for highly volatile or fragmented liquidity pools.
Kijunsen Period (26): Controls the medium-term core trend filter. Acting as the ultimate trailing stop-loss anchor.

Show Visibility Toggles: Fully customizable checkboxes allowing you to isolate the ICC corridor, show/hide traditional clouds, or toggle momentum shapes and background intersection flashes.

📌 Credits and Origins

This specific edition is engineered by @gunebak4n (dedicated to the true passion of trading, hayatım), bridging classical Japanese chartism founded by Goichi Hosoda, modern spatial geometry, and quantitative script standards previously highlighted by Kıvanç Özbilgiç (@kivancozbilgic). It is dedicated to professional algorithmic and discretionary traders who demand a mathematically sound, clutter-free view of trend validation and market structure mechanics.

Disclaimer: All financial indicators are purely probabilistic models. ICC is an advanced decision-support architecture and does not guarantee execution success or profits. Always utilize strict risk management protocols and predefined stop-losses.

## Source Code

````pine
//@version=6
// ==========================================
// 📜 INDICATOR INFO & LICENSING
// Developer: KıvanÇ @fr3762 & Goichi Hosoda
// Edition: gunebak4n
// ==========================================

indicator('Ichimoku Core Corridor', shorttitle = 'ICC', overlay = true, precision = 4)

// @description
// [EN] Premium Ichimoku tool with precise cloud-to-cloud intersection logic.
// Triggers background alerts exactly when the custom ICC corridor physically intersects,
// touches, or crosses into the traditional Kumo cloud boundaries.

// ==========================================
// 🛠️ USER INPUTS (SETTINGS)
// ==========================================
string G_CORE = 'Core Corridor Periods'
TKlength = input.int(9, 'Tenkansen Period', minval = 1, group = G_CORE, tooltip = 'Short-term equilibrium period.')
KJlength = input.int(26, 'Kijunsen Period', minval = 1, group = G_CORE, tooltip = 'Medium-term trend backbone period.')

string G_ICH = 'Traditional Ichimoku Settings'
CSHSlength = input.int(26, 'Chikou Span Shift', minval = 1, group = G_ICH, tooltip = 'The historical lagging span shift period.')
SAlength = input.int(26, 'Senkou Span A Period', minval = 1, group = G_ICH, tooltip = 'Lead 1 period used for the traditional cloud.')
SBlength = input.int(52, 'Senkou Span B Period', minval = 1, group = G_ICH, tooltip = 'Lead 2 period used for the traditional cloud.')

string G_TOGG = 'Visibility Toggles (On / Off)'
showICC = input.bool(true, 'Show ICC Corridor (TK-KJ Cloud)', group = G_TOGG, tooltip = 'Check to display our main custom Tenkansen & Kijunsen corridor.')
showTrad = input.bool(false, 'Show Traditional Ichimoku Cloud', group = G_TOGG, tooltip = 'Check to display the secondary traditional Kumo cloud.')
showSignals = input.bool(true, 'Show Momentum Signals (Shapes)', group = G_TOGG, tooltip = 'Show Buy/Sell triangles when ICC changes color.')
showBgAlerts = input.bool(true, 'Show Cloud Intersection Backgrounds', group = G_TOGG, tooltip = 'Highlight background exactly when the two clouds physically intersect.')

string G_COL_ICC = 'ICC Corridor Colors (Primary)'
iccBullColor = input.color(#10b981, 'ICC Bullish (Up) Color', group = G_COL_ICC, tooltip = 'Color used for positive ICC corridor.')
iccBearColor = input.color(#f43f5e, 'ICC Bearish (Down) Color', group = G_COL_ICC, tooltip = 'Color used for negative ICC corridor.')

string G_COL_TRAD = 'Traditional Cloud Colors (Secondary)'
tradBullColor = input.color(#06b6d4, 'Trad Bullish (Up) Color', group = G_COL_TRAD, tooltip = 'Color used for positive traditional cloud.')
tradBearColor = input.color(#a855f7, 'Trad Bearish (Down) Color', group = G_COL_TRAD, tooltip = 'Color used for negative traditional cloud.')

string G_COL_LINES = 'Line Colors (If Made Visible)'
tkLineColor = input.color(#1e90ff, 'Tenkansen Line Color', group = G_COL_LINES, tooltip = 'Color for Tenkansen if you choose to make it visible.')
kjLineColor = input.color(#ffa500, 'Kijunsen Line Color', group = G_COL_LINES, tooltip = 'Color for Kijunsen if you choose to make it visible.')
csLineColor = input.color(#ff00ff, 'Chikou Span Color', group = G_COL_LINES, tooltip = 'Color for Chikou Span if you choose to make it visible.')

string G_VIS = 'Transparency & Thickness Settings'
transparency = input.int(82, 'ICC Corridor Opacity (%)', minval = 0, maxval = 100, group = G_VIS, tooltip = 'Transparency of the main TK-KJ corridor.')
tradCloudTrans = input.int(92, 'Traditional Cloud Opacity (%)', minval = 0, maxval = 100, group = G_VIS, tooltip = 'Transparency of the secondary traditional cloud.')
lineWidth = input.int(2, 'Line Thickness', minval = 1, maxval = 5, group = G_VIS, tooltip = 'Thickness for all lines when toggled visible.')

// ==========================================
// 🧮 MATHEMATICAL CALCULATIONS
// ==========================================
// Core Components (ICC boundaries)
TK = math.avg(ta.lowest(TKlength), ta.highest(TKlength))
KJ = math.avg(ta.lowest(KJlength), ta.highest(KJlength))

// Secondary Components (Traditional cloud boundaries with offset)
CS = close
SA = math.avg(TK, KJ)
SB = math.avg(ta.lowest(SBlength), ta.highest(SBlength))

// We track the shifted boundaries to detect the exact layout on the current bar
SA_shifted = SA[CSHSlength]
SB_shifted = SB[CSHSlength]

// ==========================================
// 🎨 GRAPHICS & PLOTS
// ==========================================

// 1. Core Corridor Plots
plotTK = plot(TK, linewidth = math.max(1, lineWidth), color = tkLineColor, title = 'TenkanSen (Core)', display = display.none)
plotKJ = plot(KJ, linewidth = math.max(1, lineWidth), color = kjLineColor, title = 'KijunSen (Core)', display = display.none)

corridorColor = showICC ? TK > KJ ? color.new(iccBullColor, transparency) : color.new(iccBearColor, transparency) : color.new(color.white, 100)
fill(plotTK, plotKJ, color = corridorColor, title = 'ICC Core Corridor Fill')

// 2. Traditional Ichimoku Components
plotCS = plot(CS, offset = -CSHSlength, linewidth = math.max(1, lineWidth), color = csLineColor, title = 'Chikou Span (Lagging)', display = display.none)
plotSA = plot(SA, offset = CSHSlength, linewidth = 1, color = color.new(tradBullColor, 30), title = 'Senkou Span A (Lead 1)', display = display.none)
plotSB = plot(SB, offset = CSHSlength, linewidth = 1, color = color.new(tradBearColor, 30), title = 'Senkou Span B (Lead 2)', display = display.none)

tradCloudColor = showTrad ? SA > SB ? color.new(tradBullColor, tradCloudTrans) : color.new(tradBearColor, tradCloudTrans) : color.new(color.white, 100)
fill(plotSA, plotSB, color = tradCloudColor, title = 'Traditional Kumo Cloud Fill')

// ==========================================
// 🚨 REAL INTERSECTION SIGNAL LOGIC
// ==========================================
// A. ICC Color Change Signals (Triangles)
iccBullish = TK > KJ
iccCrossUp = ta.rising(TK, 1) and iccBullish and not iccBullish[1]
iccCrossDown = ta.falling(TK, 1) and not iccBullish and iccBullish[1]

plotshape(showSignals and iccCrossUp ? math.min(TK, KJ) : na, title = 'ICC Bullish Cross', style = shape.triangleup, location = location.belowbar, color = iccBullColor, size = size.small)
plotshape(showSignals and iccCrossDown ? math.max(TK, KJ) : na, title = 'ICC Bearish Cross', style = shape.triangledown, location = location.abovebar, color = iccBearColor, size = size.small)

// B. Physical Cloud-to-Cloud Intersection Logic
// Detects if any line of the ICC crosses any line of the Traditional Cloud on the active bar
iccMax = math.max(TK, KJ)
iccMin = math.min(TK, KJ)
tradMax = math.max(SA_shifted, SB_shifted)
tradMin = math.min(SA_shifted, SB_shifted)

// Pure physical intersection crossings
crossUp1 = ta.crossover(iccMax, tradMin) or ta.crossover(iccMin, tradMin)
crossUp2 = ta.crossover(iccMax, tradMax) or ta.crossover(iccMin, tradMax)
crossBullIntersection = crossUp1 or crossUp2

crossDown1 = ta.crossunder(iccMin, tradMax) or ta.crossunder(iccMax, tradMax)
crossDown2 = ta.crossunder(iccMin, tradMin) or ta.crossunder(iccMax, tradMin)
crossBearIntersection = crossDown1 or crossDown2

// Trigger background flash on the exact crossing bar
bgcolor(showBgAlerts and crossBullIntersection ? color.new(iccBullColor, 85) : na, title = 'Clouds Intersect Up Background Alert')
bgcolor(showBgAlerts and crossBearIntersection ? color.new(iccBearColor, 85) : na, title = 'Clouds Intersect Down Background Alert')
````
