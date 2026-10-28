# Lorentzian Dreamer Retrieval Architecture (DAFE)

- url: https://www.tradingview.com/script/LxaCl6Rp-Lorentzian-Dreamer-Retrieval-Architecture-DAFE/
- type: indicator
- pine_id: PUB;b3503d0c41414fd58fba167f7d03988b
- version: 1.0

## Description

[b]Lorentzian Dreamer Retrieval Architecture [DAFE][/b]
[b]A Unified Framework for Probabilistic Market Analysis, Integrating Memory Retrieval and Generative World Modeling[/b]

[b]█ CHAPTER 1: THE PHILOSOPHY - MEMORY REMEMBERS. DREAM IMAGINES.[/b]
Traditional technical analysis operates on a core assumption: that the future will resemble the past. It employs indicators to search for historical patterns, assuming that a pattern that resolved bullishly before will do so again. This is a one-dimensional view, often blind to the infinite nuance of context. What if the market is in a different volatility regime? What if the underlying order flow is different? What if the macro-structure has changed?

The Lorentzian Dreamer Retrieval Architecture (LDRA) was created to address this fundamental problem. It is not a predictive "signal" generator; it is a sophisticated, dual-core engine designed to model the market's probable future path by synergizing two powerful, opposing concepts:

[b]The Memory [/b](The Retrieval Engine): This is the system's "past." It is a powerful k-Nearest Neighbors (k-NN) engine that uses a Lorentzian distance kernel to search through hundreds of past market states. It finds the historical moments that are most geometrically similar to the current moment and retrieves what happened next. It asks: "[b]When the market looked and felt exactly like this before, what was the outcome?[/b]"

[b]The Dream[/b] (The Imagination Engine): This is the system's "future." It is a simplified "World Model," inspired by concepts from advanced computational theory. It has learned a mathematical representation of the market's "rules of motion." It takes the current market state as a seed and runs thousands of forward-looking simulations—"dreams"—to explore a vast tree of possible future trajectories. It asks: "[b]Given the current state and the learned rules of physics, what are the most probable future paths?[/b]"

The LDRA is the unification of these two forces. It is a system that grounds its imagination of the future in its memory of the past. The final output is not a simple buy or sell arrow, but a rich, multi-dimensional analysis of the market's state, its probable direction, and the system's confidence in its own analysis. It is a tool for thinking in probabilities, not certainties.

[b]█ THE LDRA CORE ARCHITECTURE - A DEEP DIVE INTO THE ENGINES[/b]
This is not a simple "mashup." It is a hierarchical, multi-stage processing pipeline where each component performs a specific, critical function.

[b]THE ENCODER[/b] - From Chaos to Coherence
The market is a sea of noisy data—RSI, MACD, Volume, Volatility, and dozens of other metrics. The first step is to transform this high-dimensional chaos into a low-dimensional, coherent representation. The LDRA does this with an "Encoder," a fixed neural network-style layer that takes in 13+ raw market features and compresses them into a 6-dimensional "latent vector." This vector is a unique mathematical fingerprint, a "state," that encapsulates the essential character of the current market condition. This is the language the rest of the system speaks.

[b]THE RETRIEVAL ENGINE[/b] - The Power of Lorentzian Memory
This is the system's memory bank. It stores hundreds of past latent vectors and their known outcomes. When a new state is encoded, this engine's job is to find the most similar memories.
[b]Why Lorentzian?: [/b]Standard k-NN uses Euclidean distance (a straight line), which is brittle. A single outlier feature can make two otherwise similar states appear distant. The Lorentzian Kernel (log(1 + d^2)) is a more robust distance metric used in advanced statistics. It is far less sensitive to outliers, allowing it to find more meaningful and robustly similar historical states. It is a superior memory retrieval mechanism.
[b]The Output:[/b] The engine retrieves the k (e.g., 8) most similar past states and performs a similarity-weighted aggregation of their outcomes. The result is the Lorentzian Prediction (lor_pred)—a powerful forecast based purely on historical precedent.

[b]THE IMAGINATION ENGINE[/b] - The "Dreamer" World Model
This is the forward-looking, generative component. It is a simplified World Model that has learned the "transition dynamics" of the market—how one latent state is likely to evolve into the next.
[b]How it "Dreams": [/b]It takes a seed state (either the current state or a retrieved memory state) and projects it one step into the future using its learned transition model. It then takes that future state and projects it again, and again, for a set "depth." This creates a single "dream"—a plausible future trajectory.
[b]The Rollouts:[/b] The engine doesn't just have one dream. It runs multiple "rollouts," each time injecting a tiny amount of structured noise to explore different branches of the probability tree. It then aggregates the outcomes of all these imagined futures.
[b]The Output: [/b]The result is the Dream Residual (WM_RESID)—the model's expectation of the future, generated from its internal understanding of market physics, completely independent of the historical retrieval. It also calculates its Uncertainty in this prediction.

[b]THE FUSION & GATING MECHANISM[/b]
This is where memory and imagination are unified. The system calculates a Trust Gate score. This score is high if the Memory and Dream engines agree, if the Dream engine is certain of its own prediction, and if the system's historical prediction error is low. This gate then determines how much of the "Dream" is blended with the "Memory."
[b]The Result: [/b]A Fused Score that is primarily driven by historical data (the Lorentzian prediction) but is intelligently nudged and refined by the forward-looking imagination of the Dreamer engine. The final Fused Confidence is a blend of the retrieval confidence, the imagination certainty, and the Trust Gate itself.

[b]█ THE LIBRARY ECOSYSTEM - A SYMPHONY OF CONFLUENCE[/b]
The LDRA is the central hub, but it is made exponentially more powerful by its seamless integration with other DAFE libraries.
[b]MarketStructureLib (MSL):[/b] This library provides the structural map of the battlefield. It performs a deep, quantitative analysis of market structure, identifying swing points, liquidity corridors, volume profiles, and "siege" levels under repeated attack. The LDRA ingests this data, using proximity to a significant structural level (like a siege resistance or a volume profile POC) as a powerful confluence factor. This grounds the LDRA's abstract analysis in the concrete reality of support and resistance.
[b]DafeRCMLib (RCM):[/b] This is the system's final conviction layer. The LDRA's final prediction, along with intelligence from the MSL and its own internal footprint delta, is injected as "External Evidence" into the RCM engine. The RCM's Integrity score—its confidence in the current market's "truthfulness"—is then used as a master filter and confidence booster for the LDRA's output. A high-confidence LDRA prediction during a low-integrity RCM state is a warning of a potential trap.
[b]DafeVisualsLib (Viz):[/b] This is the canvas upon which this complex data is painted. The LDRA leverages the VizLib's advanced rendering capabilities, including its theme engine and drawing helpers, to create the stunning and information-rich 3D manifold visualization. It is the engine that translates the abstract mathematics into an intuitive, perceptual experience.
[b]The Footprint Data Source:[/b] The indicator's "order flow" sense is powered by TradingView's request.footprint() data when available on the selected asset. This provides real, tick-level buy vs. sell volume data. In a demonstration of robustness, if native footprint data is not available, the system automatically and gracefully falls back to a sophisticated Synthetic Footprint Engine that estimates the delta from OHLCV data, ensuring universal functionality.

[b]█ THE VISUALIZATION ENGINE - THE 3D MANIFOLD[/b]
The LDRA's output is a high-information-density, three-dimensional, animated data visualization called the "Manifold." This is a rendering engine built using the DafeVisualsLib, designed to give you an intuitive, "at-a-glance" feel for the flow of market possibilities.
[b]The 3D Engine:[/b] The entire manifold is rendered in a simulated 3D space with a perspective camera. You can control the Camera Tilt Angle and Perspective Strength to change your viewpoint. An optional Auto-Rotate feature provides a cinematic view for presentations.
[b]The Wireframe Manifold Mesh:[/b] The core visual is a flowing, ribbon-like structure. This is the historical trajectory of the market's latent state, projected into 3D space.
[b]Longitudinal Curves:[/b] The main lines that flow from past to present, representing the path of the market's "fingerprint" through time.
[b]Latitudinal Curves:[/b] The cross-ribs that give the manifold its shape, colored by the market regime at that point in time (e.g., Green for Trend, Red for Mean-Reversion).
[b]The Memory Nebula:[/b] This is a 3D scatter plot of historical memory points that are relevant to the current state. They appear as glowing particles within the manifold, showing you the "constellation" of past events that are influencing the current prediction.
[b]The k-NN Constellation Lines:[/b] When the retrieval engine is active, faint, dotted lines are drawn from the current point on the manifold back to the specific memory points in the Nebula that it has identified as the "k-Nearest Neighbors." This gives you a direct, visual confirmation of which past events are informing the present analysis.
[b]The Dream Projection:[/b] From the very tip of the manifold (the current bar), the system projects several faint, glowing "ghost" trajectories into the future. These are the "dreams"—the possible future paths imagined by the World Model. Their convergence or divergence gives you an immediate sense of the model's certainty.
[b]The Iso-Reference Planes:[/b] To ground the 3D visualization, the engine draws a horizontal grid plane (the "floor") and a vertical "Scanner Slice"—a translucent plane that helps you perceive depth and position within the manifold.
[image]https://www.tradingview.com/x/xJiij0m7/[/image]

[b]█ THE COMPLETE USER MANUAL - INPUT CONFIGURATION[/b]
[b]Every parameter of the engine is exposed for professional-level fine-tuning. Understanding these controls is key to mastering the LDRA.[/b]
[b][u]LDRA Core Engine[/u][/b]
[b]Memory Lookback:[/b] The number of past bars the k-NN engine searches through. A larger value provides a richer memory bank but may increase script loading time.
[b]KNN Neighbors:[/b] The number (k) of most similar historical patterns to retrieve. A smaller k (3-5) makes the prediction sensitive to very specific matches. A larger k (10-15) creates a smoother, more generalized prediction.
[b]Outcome Horizon:[/b] The number of bars into the future the system looks at to determine the "outcome" of a past event. A shorter horizon trains the system for scalping; a longer horizon trains it for swing trading.
[b]Base Gamma:[/b] Controls the "width" of the Lorentzian distance kernel. A lower gamma makes the search highly sensitive to small differences. A higher gamma allows for more "fuzzy" matches, focusing on the overall geometric shape of the state.
[b]Latent Dim:[/b] The number of dimensions in the encoded state vector. Higher dimensions can capture more nuance but require more data to be effective. 6 is the recommended balance.
[b]WM Base LR:[/b] The base "Learning Rate" for the Dreamer (World Model). This controls how quickly the model updates its internal understanding of the market's transition dynamics.
[b]Imagination Depth & Paths:[/b] Depth is how many steps into the future each "dream" runs. Paths is the number of separate "dreams" (rollouts) it simulates on each bar.
[b]Discount:[/b] A factor that determines how much the Dreamer values immediate rewards versus distant ones in its simulations.
[b]Warmup Bars:[/b] The number of historical bars the system must process to build its initial memory bank before it begins making predictions.
[b]Min Similarity:[/b] The minimum similarity score required for a historical pattern to even be considered by the k-NN engine. Acts as a quality filter.
[b][u]Manifold Visualization[/u][/b]
[b]Theme:[/b] Select from a suite of professionally designed color palettes to customize the entire visual experience.
[b]Ribbon Span & Stride:[/b] Span controls the historical length of the manifold ribbon. Stride is a performance setting that controls how frequently the latitudinal ribs are drawn.
[b]Ribbon Height & Depth:[/b] These control the vertical and Z-axis scaling of the 3D manifold in the indicator pane.
[b]Camera Controls (Tilt, Auto-Rotate, Perspective):[/b] Direct control over the 3D camera, allowing you to change your viewpoint and add cinematic effects.
[b]Visual Toggles (Constellation, Nodes, Grid, Nebula, Isosurf):[/b] Enable or disable specific layers of the visualization to create a cleaner or more data-rich view.

[b][u]Dashboards & Other Libraries[/u][/b]
[b]The inputs for RCM, MSL, and the Dashboards are extensive.[/b] They allow you to fine-tune every aspect of the confluence libraries, from pivot lengths in the Market Structure Engine to the display size and position of the diagnostic panels. Please refer to the dedicated publications for those libraries for a full breakdown.

[b]█ INTERPRETING THE DASHBOARDS[/b]
[b]State Dashboard:[/b] This is your high-level summary.
Confluence: The primary output. It shows the Score (the strength of agreement between all engines) and the Components (how many engines are in agreement).
Lor / Flow / RCM / Structure: A breakdown of the individual signals from the Lorentzian engine, the Footprint/Delta engine, the RCM, and the MSL.
Regime: The current market personality (e.g., Trend, MeanRev).
[b]Diagnostics Dashboard:[/b] A look under the hood for the advanced analyst.
Lor Pred & Assurance: The raw prediction from the memory retrieval and its statistical confidence.
Dream Resid & Unc: The raw prediction from the imagination engine and its uncertainty.
WM Accuracy & Pred Err: A real-time measure of how well the Dreamer engine is predicting the market's next move.
Trust Gate: The final score that determines how much the system trusts its own imagination vs. its memory.
[image]https://www.tradingview.com/x/Ve6m6OTF/[/image]

[b]█ DEVELOPMENT PHILOSOPHY[/b]
[b]The Lorentzian Dreamer Retrieval Architecture is a culmination of years of research into the intersection of physics, computer science, and financial markets. It was born from the belief that the future of technical analysis is not about finding a better lagging indicator, but about building better models of the market itself. This tool is a step in that direction. It is for the serious trader, the quantitative analyst, and the systems thinker who is not just looking for signals, but for a deeper, more profound understanding of the probabilistic nature of the market.[/b]

[b]█ DISCLAIMER AND BEST PRACTICES[/b]
[b]THIS IS AN ADVANCED ANALYTICAL TOOL:[/b] This indicator provides a sophisticated probabilistic analysis, not direct financial advice. It is a decision-support tool designed to be the centerpiece of a comprehensive trading framework.
[b]RISK MANAGEMENT IS PARAMOUNT:[/b] All trading involves substantial risk. The probabilities and scores are based on historical data and statistical models, not guarantees of future outcomes.
[b]USE THE FULL CONTEXT:[/b] Do not trade based on a single number. The highest-quality insights come from confluence across all engines. A high "Confluence Score" on the main dashboard is the most robust output. Check the RCM "Integrity" and the "Market State" before acting.
[b]GIVE IT TIME TO BUILD MEMORY:[/b] The indicator requires a "Warmup" period to build its initial memory bank. Its analysis will become progressively more robust as it processes more data.

**This script is heavy. 

[b]"The art of prophecy is very difficult, especially with respect to the future."[/b]
[b]— Mark Twain[/b]

— Dskyz, Trade with insight. Trade with anticipation. (Don't follow the trend, be the trend)

## Source Code

````pine
//@version=6
indicator("Lorentzian Dreamer Retrieval Architecture (DAFE)", "⟡ LDRA", overlay=false, max_bars_back=500, max_labels_count=500, max_lines_count=500, max_polylines_count=100, max_boxes_count=500)
// ═══════════════════════════════════════════════════════════════════════════════
//
//                    ██╗     ██████╗ ██████╗  █████╗     
//                    ██║     ██╔══██╗██╔══██╗██╔══██╗   
//                    ██║     ██║  ██║██████╔╝███████║   
//                    ██║     ██║  ██║██╔══██╗██╔══██║   
//                    ███████╗██████╔╝██║  ██║██║  ██║   
//                    ╚══════╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝    
//
//                  LORENTZIAN DREAMER RETRIEVAL ARCHITECTURE
//    ─────────────────────────────────────────────────────────────────
//              Memory remembers. Dream imagines. We only observe.
//    ─────────────────────────────────────────────────────────────────
//
//    NOTES:
//    · 3D Engine — perspective camera with auto-rotation
//    · Wireframe Manifold Mesh (longitudinal + latitudinal curves)
//    · Memory Nebula — 3D scatter of latent memory points
//    · Iso-Reference Planes (horizontal grid + vertical scanner slice)
//    · Holographic stream theme + depth fog
//    · All existing logic (k-NN, Dreamer, RCM, MSL, Footprint) 
//
// ═══════════════════════════════════════════════════════════════════════════════
import DskyzInvestments/MarketStructureLib/1 as msl
import DskyzInvestments/DafeRCMLib/1     as rcm
import DskyzInvestments/DafeVisLib/1 as viz
// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
string G_CORE = "⟡ LDRA Core Engine"
int    i_lookback   = input.int(150,   "Memory Lookback",     minval=50,  maxval=500, group=G_CORE, tooltip="How many past bars the KNN engine searches. Larger = richer memory but slower load.")
int    i_neighbors  = input.int(8,     "KNN Neighbors",       minval=3,   maxval=20,  group=G_CORE)
int    i_pivot      = input.int(4,     "Outcome Horizon",     minval=1,   maxval=20,  group=G_CORE)
float  i_gamma      = input.float(1.5, "Base Gamma",          minval=0.1, maxval=5.0, group=G_CORE)
int    i_latent     = input.int(6,     "Latent Dim",          minval=3,   maxval=8,   group=G_CORE)
float  i_wm_lr      = input.float(0.04,"WM Base LR",          minval=0.001, maxval=0.2, group=G_CORE)
int    i_depth      = input.int(3,     "Imagination Depth",   minval=2,   maxval=10,  group=G_CORE)
int    i_paths      = input.int(4,     "Imagination Paths",   minval=2,   maxval=16,  group=G_CORE)
float  i_discount   = input.float(0.92,"Discount",            minval=0.7, maxval=0.99,group=G_CORE)
int    i_warm       = input.int(50,    "Warmup Bars",         minval=20,  maxval=150, group=G_CORE)
float  i_min_sim    = input.float(0.20,"Min Similarity",      minval=0.05,maxval=0.8, group=G_CORE)
string G_CONF = "✦ Confluence Dots"
float  i_conf_threshold = input.float(0.50, "Confluence Activation Threshold", minval=0.1, maxval=0.9, step=0.05, group=G_CONF, tooltip="Minimum blended confluence score to plot a dot. Higher = fewer, more selective dots.")
bool   i_dot_stack  = input.bool(true, "Stack Dots by Strength", group=G_CONF, tooltip="When multiple confluences hit simultaneously, stack multiple dots for visual density.")
int    i_dot_size   = input.int(2, "Dot Size (1=tiny, 2=small, 3=normal)", minval=1, maxval=3, group=G_CONF)
string G_FP = "📊 Footprint Order Flow"
bool   i_use_fp     = input.bool(true, "Enable Footprint (graceful fallback)", group=G_FP)
int    i_fp_ticks   = input.int(100, "Ticks per Footprint Row", minval=1, group=G_FP)
int    i_fp_va      = input.int(70, "Value Area %", minval=1, maxval=99, group=G_FP)
string G_MSL = "🏗 Market Structure"
bool   i_use_msl    = input.bool(true, "Enable MSL Structural Context", group=G_MSL)
int    i_pivot_len  = input.int(5, "Pivot Length", minval=2, maxval=15, group=G_MSL)
int    i_vp_len     = input.int(60, "Volume Profile Lookback", minval=20, maxval=200, group=G_MSL)
float  i_prox_atr   = input.float(0.5, "Structural Proximity (ATR)", minval=0.1, maxval=2.0, group=G_MSL)
string G_RCM = "🛡 RCM Conviction"
bool   i_use_rcm    = input.bool(true, "Enable RCM Conviction Layer", group=G_RCM)
string i_rcm_preset = input.string("Auto", "RCM Preset", options=["Auto","Default","Scalp","Swing"], group=G_RCM)
float  i_inj_lor    = input.float(1.2, "Lorentzian → Impulse Weight", minval=0.0, maxval=3.0, group=G_RCM)
float  i_inj_delta  = input.float(1.0, "Footprint Delta → Structure Weight", minval=0.0, maxval=3.0, group=G_RCM)
float  i_inj_siege  = input.float(0.8, "MSL Siege → Compression Weight", minval=0.0, maxval=3.0, group=G_RCM)
string G_VIZ = "🎨 Manifold Visualization"
string i_theme      = input.string("DAFE Signature", "Theme", options=["DAFE Signature","Neon","Cyber","Matrix","Gold","Ice","Blood","Clean","Holographic"], group=G_VIZ)
int    i_ribbon_span = input.int(200, "Ribbon Span (bars)", minval=50, maxval=300, group=G_VIZ, tooltip="How many bars of history the manifold ribbon spans.")
int    i_ribbon_stride = input.int(3, "Ribbon Stride (perf)", minval=1, maxval=8, group=G_VIZ, tooltip="Draw ribbon ribbing every N bars. Lower = denser, more linefills used.")
float  i_ribbon_height = input.float(60.0, "Ribbon Vertical Extent", minval=20.0, maxval=150.0, group=G_VIZ, tooltip="Height of the ribbon in chart units (lower panel).")
float  i_ribbon_depth  = input.float(20.0, "3D Depth Parallax", minval=5.0, maxval=60.0, group=G_VIZ, tooltip="Parallax offset magnitude creating the 3D illusion.")
float  i_cam_tilt      = input.float(25.0, "Camera Tilt Angle (deg)", minval=0.0, maxval=60.0, group=G_VIZ)
bool   i_show_constellation = input.bool(true, "Show k-NN Constellation Lines", group=G_VIZ)
bool   i_show_nodes    = input.bool(true, "Show Retrieval Event Nodes", group=G_VIZ)
bool   i_show_grid     = input.bool(true, "Show Manifold Grid", group=G_VIZ)
bool   i_auto_rotate = input.bool(false, "🎥 Auto-Rotate Camera (Stream FX)", group=G_VIZ)
float  i_rot_speed   = input.float(12.0, "Rotation Period (sec)", minval=4.0, maxval=60.0, group=G_VIZ)
float  i_perspective = input.float(900.0, "Perspective Strength", minval=300.0, maxval=3000.0, group=G_VIZ)
bool   i_show_nebula = input.bool(true, "Show Memory Nebula (3D Scatter)", group=G_VIZ)
bool   i_show_isosurf= input.bool(true, "Show Scanner Slice (Vertical Plane)", group=G_VIZ)
string G_DASH = "📋 Dashboard"
bool   i_show_dash1  = input.bool(true,  "Show State Dashboard",        group=G_DASH)
bool   i_show_dash2  = input.bool(true,  "Show Diagnostics Dashboard",  group=G_DASH)
string i_dash1_size  = input.string("Full",         "State Dashboard Size",        options=["Full","Compact","Mini"], group=G_DASH)
string i_dash2_size  = input.string("Full",         "Diagnostics Dashboard Size",  options=["Full","Compact","Mini"], group=G_DASH)
string i_dash1_pos   = input.string("Bottom Right",    "State Dashboard Position",    options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=G_DASH)
string i_dash2_pos   = input.string("Bottom Left",  "Diagnostics Dashboard Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=G_DASH)
string i_dash1_mode  = input.string("Main Chart Overlay", "State Dashboard Location",       options=["Main Chart Overlay","Indicator Panel"], group=G_DASH)
string i_dash2_mode  = input.string("Main Chart Overlay", "Diagnostics Dashboard Location",  options=["Main Chart Overlay","Indicator Panel"], group=G_DASH)
// ═══════════════════════════════════════════════════════════════════════════════
// THEME & CONSTANTS
// ═══════════════════════════════════════════════════════════════════════════════
viz.Theme THM = viz.get_theme(i_theme)
float EPS  = 1e-8
int   LDIM = i_latent
int   NFEAT = 13
// ═══════════════════════════════════════════════════════════════════════════════
// PURE HELPERS
// ═══════════════════════════════════════════════════════════════════════════════
clamp(float v, float lo, float hi) =>
    math.max(lo, math.min(hi, v))
sigmoid(float x) =>
    1.0 / (1.0 + math.exp(-clamp(x, -8.0, 8.0)))
tanh_f(float x) =>
    float e = math.exp(-2.0 * clamp(x, -8.0, 8.0))
    (1.0 - e) / (1.0 + e)
det_rand(int seed) =>
    float x = math.sin(float(seed) * 127.1 + 311.7) * 43758.5453
    x - math.floor(x)
f_dashPos(string p) =>
    switch p
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        => position.bottom_left
// ═══════════════════════════════════════════════════════════════════════════════
// BASE FEATURES
// ═══════════════════════════════════════════════════════════════════════════════
float atr14   = nz(ta.atr(14), 0.0)
float atr_sma = nz(ta.sma(atr14, 20), 0.0)
float vol_sma = nz(ta.sma(nz(volume, 0.0), 20), 0.0)
[macd_line, macd_sig, macd_hist] = ta.macd(close, 12, 26, 9)
float rsi14   = nz(ta.rsi(close, 14), 50.0)
float stoch14 = nz(ta.stoch(close, high, low, 14), 50.0)
float cci20   = nz(ta.cci(close, 20), 0.0)
float mom10   = nz(ta.mom(close, 10), 0.0)
float roc10   = nz(ta.roc(close, 10), 0.0)
float macd_l  = nz(macd_line, 0.0)
float v       = nz(volume, 0.0)
float v_ratio = vol_sma > 0 ? math.log(v / vol_sma + 1.0) : 0.0
float hi14    = nz(ta.highest(high, 14), high)
float lo14    = nz(ta.lowest(low, 14), low)
float rng14   = math.max(hi14 - lo14, EPS)
float pu_raw = 0.0
float pd_raw = 0.0
for i = 0 to 13
    float c0 = nz(close[i], close)
    float c1 = nz(close[i + 1], close)
    if c0 > c1
        pu_raw += (c0 - c1) / rng14
    else
        pd_raw += (c1 - c0) / rng14
float pu_n  = clamp(pu_raw / 14.0, EPS, 1.0 - EPS)
float pd_n  = clamp(pd_raw / 14.0, EPS, 1.0 - EPS)
float ent_n = clamp(-(pu_n * math.log(pu_n) + pd_n * math.log(pd_n)) / math.log(2.0), 0.0, 1.0)
float F0 = (rsi14 - 50.0) / 50.0
float F1 = (stoch14 - 50.0) / 50.0
float F2 = clamp(cci20 / 200.0, -1.0, 1.0)
float F3 = clamp(v_ratio / 2.0, -1.0, 1.0)
float F4 = ent_n
float F5 = atr14 > 0 ? clamp(mom10 / (atr14 * 5.0), -1.0, 1.0) : 0.0
float F6 = clamp(roc10 / 10.0, -1.0, 1.0)
float F7 = atr14 > 0 ? clamp(macd_l / atr14 / 2.0, -1.0, 1.0) : 0.0
var array<float> F_NOW = array.new_float(NFEAT, 0.0)
// ═══════════════════════════════════════════════════════════════════════════════
// FOOTPRINT — SYNTHETIC FALLBACK
// ═══════════════════════════════════════════════════════════════════════════════
footprint fp       = i_use_fp ? request.footprint(i_fp_ticks, i_fp_va) : na
bool      fp_active = not na(fp)
float fp_buy   = fp_active ? fp.buy_volume()  : 0.0
float fp_sell  = fp_active ? fp.sell_volume() : 0.0
float fp_delta = fp_active ? fp.delta()       : 0.0
float fp_total = fp_active ? (fp_buy + fp_sell) : 0.0
float fp_poc_mid = na
float fp_vah_up  = na
float fp_val_dn  = na
if fp_active
    volume_row poc_row = fp.poc()
    volume_row vah_row = fp.vah()
    volume_row val_row = fp.val()
    fp_poc_mid := (poc_row.up_price() + poc_row.down_price()) / 2.0
    fp_vah_up  := vah_row.up_price()
    fp_val_dn  := val_row.down_price()
// ── Synthetic footprint engine ──
float _bar_range    = high - low
float _body         = math.abs(close - open)
float _upper_wick   = high - math.max(open, close)
float _lower_wick   = math.min(open, close) - low
float _bar_loc      = _bar_range > 0 ? (close - low) / _bar_range : 0.5
float _loc_bias     = (_bar_loc - 0.5) * 2.0
float _wick_pressure = 0.0
if _upper_wick > _lower_wick * 2.2 and _upper_wick > _body * 0.35
    _wick_pressure := -0.45
else if _lower_wick > _upper_wick * 2.2 and _lower_wick > _body * 0.35
    _wick_pressure := 0.45
float _trend_dir = close > open ? 1.0 : close < open ? -1.0 : 0.0
var float _prev_delta_store = 0.0
float _momentum    = clamp(_prev_delta_store * 0.30, -0.25, 0.25)
float _vol_stdev   = ta.stdev(v, 20)
float _vol_z       = vol_sma > 0 ? (v - vol_sma) / (_vol_stdev + EPS) : 0.0
float _vol_boost   = 1.0 + clamp(_vol_z * 0.18, -0.25, 0.50)
float _range_z     = atr14 > 0 ? _bar_range / atr14 : 1.0
float _range_factor = _range_z > 1.6 ? 1.25 : _range_z < 0.4 ? 0.55 : 1.0
float est_delta    = fp_active ? fp_delta : v * clamp((_loc_bias * 0.50 + _trend_dir * 0.22 + _wick_pressure + _momentum) * _vol_boost * _range_factor, -0.95, 0.95)
float delta_ratio_raw = fp_active and fp_total > 0 ? fp_delta / fp_total : (vol_sma > 0 ? est_delta / vol_sma : 0.0)
float delta_ratio  = clamp(delta_ratio_raw, -1.0, 1.0)
float abs_range_ratio = atr14 > 0 ? (high - low) / atr14 : 1.0
float abs_vol_ratio   = vol_sma > 0 ? v / vol_sma : 1.0
float absorption   = abs_vol_ratio > 1.25 and abs_range_ratio < 0.60 ? clamp(abs_vol_ratio * (1.0 - abs_range_ratio) * 1.8, 0.0, 2.0) / 2.0 : 0.0
float abs_signed   = close > open ? absorption : -absorption
_prev_delta_store  := delta_ratio
// ═══════════════════════════════════════════════════════════════════════════════
// MSL
// ═══════════════════════════════════════════════════════════════════════════════
var float prev_poc_mid = na
msl.MarketContext mctx = msl.get_market_context(open, high, low, close, v, fp_active ? fp : na, vol_sma, prev_poc_mid, atr14)
[shP, shB] = msl.detect_swing_high(i_pivot_len)
[slP, slB] = msl.detect_swing_low(i_pivot_len)
var array<float> shPrices = array.new_float()
var array<int>   shBars   = array.new_int()
var array<float> slPrices = array.new_float()
var array<int>   slBars   = array.new_int()
if not na(shP)
    array.unshift(shPrices, shP)
    array.unshift(shBars,   shB)
    if array.size(shPrices) > 10
        array.pop(shPrices)
        array.pop(shBars)
if not na(slP)
    array.unshift(slPrices, slP)
    array.unshift(slBars,   slB)
    if array.size(slPrices) > 10
        array.pop(slPrices)
        array.pop(slBars)
var array<float> lbH = array.new_float()
var array<float> lbL = array.new_float()
var array<float> lbC = array.new_float()
var array<float> lbV = array.new_float()
array.unshift(lbH, high)
array.unshift(lbL, low)
array.unshift(lbC, close)
array.unshift(lbV, v)
if array.size(lbH) > i_vp_len
    array.pop(lbH)
    array.pop(lbL)
    array.pop(lbC)
    array.pop(lbV)
[poc_val, vah_val, val_val] = msl.calc_unified_poc_va(lbH, lbL, lbC, lbV, 24, fp_active ? fp : na)
var msl.MultiTFStructure structure = msl.create_structure()
structure.tf1 := msl.update_structure(structure.tf1, poc_val, vah_val, val_val, shPrices, shBars, slPrices, slBars, timeframe.period, atr14, mctx)
bool at_siege_res = i_use_msl and msl.check_siege_proximity(close, structure.tf1.res_corridor, atr14)
bool at_siege_sup = i_use_msl and msl.check_siege_proximity(close, structure.tf1.sup_corridor, atr14)
bool at_poc       = i_use_msl and not na(poc_val) and math.abs(close - poc_val) <= atr14 * i_prox_atr
bool at_vah       = i_use_msl and not na(vah_val) and math.abs(close - vah_val) <= atr14 * i_prox_atr * 0.7
bool at_val       = i_use_msl and not na(val_val) and math.abs(close - val_val) <= atr14 * i_prox_atr * 0.7
bool at_struct    = at_siege_res or at_siege_sup or at_poc or at_vah or at_val
prev_poc_mid := not na(fp_poc_mid) ? fp_poc_mid : poc_val
float ms_net_bias = 0.0
bool  ms_inside_va = false
if i_use_msl and structure.tf1.is_valid
    ms_net_bias  := structure.tf1.bias
    ms_inside_va := not na(vah_val) and not na(val_val) and close <= vah_val and close >= val_val
// ═══════════════════════════════════════════════════════════════════════════════
// EXTENDED FEATURES  
// ═══════════════════════════════════════════════════════════════════════════════
float F8  = delta_ratio
float F9  = not na(poc_val) and atr14 > 0 ? clamp((close - poc_val) / (atr14 * 2.0), -1.0, 1.0) : 0.0
float F10 = ms_inside_va ? 1.0 : (not na(vah_val) and not na(val_val) ? (close > vah_val ? 0.5 : close < val_val ? -0.5 : 0.0) : 0.0)
float F11 = abs_signed
var float F12_ref = 0.0
array.set(F_NOW, 0,  F0)
array.set(F_NOW, 1,  F1)
array.set(F_NOW, 2,  F2)
array.set(F_NOW, 3,  F3)
array.set(F_NOW, 4,  F4)
array.set(F_NOW, 5,  F5)
array.set(F_NOW, 6,  F6)
array.set(F_NOW, 7,  F7)
array.set(F_NOW, 8,  F8)
array.set(F_NOW, 9,  F9)
array.set(F_NOW, 10, F10)
array.set(F_NOW, 11, F11)
array.set(F_NOW, 12, F12_ref)   
get_f(int k) => array.get(F_NOW, k)
// ═══════════════════════════════════════════════════════════════════════════════
// ENCODER
// ═══════════════════════════════════════════════════════════════════════════════
var matrix<float> ENC_W = matrix.new<float>(LDIM, NFEAT, 0.0)
var array<float>  ENC_B = array.new_float(LDIM, 0.0)
var bool enc_init = false
if not enc_init and bar_index == 0
    matrix.set(ENC_W, 0, 0,  0.35)
    matrix.set(ENC_W, 0, 5,  0.30)
    matrix.set(ENC_W, 0, 6,  0.20)
    matrix.set(ENC_W, 0, 8,  0.15)
    matrix.set(ENC_W, 1, 0, -0.25)
    matrix.set(ENC_W, 1, 2,  0.40)
    matrix.set(ENC_W, 1, 1,  0.15)
    matrix.set(ENC_W, 1, 10,-0.20)
    matrix.set(ENC_W, 2, 3,  0.40)
    matrix.set(ENC_W, 2, 7,  0.20)
    matrix.set(ENC_W, 2, 8,  0.30)
    matrix.set(ENC_W, 2, 11, 0.10)
    matrix.set(ENC_W, 3, 4,  0.60)
    matrix.set(ENC_W, 3, 3, -0.15)
    matrix.set(ENC_W, 3, 9,  0.25)
    matrix.set(ENC_W, 4, 5,  0.25)
    matrix.set(ENC_W, 4, 7,  0.25)
    matrix.set(ENC_W, 4, 6,  0.20)
    matrix.set(ENC_W, 4, 12, 0.30)
    matrix.set(ENC_W, 5, 0,  0.25)
    matrix.set(ENC_W, 5, 1,  0.25)
    matrix.set(ENC_W, 5, 2,  0.25)
    matrix.set(ENC_W, 5, 9,  0.25)
    enc_init := true
encode_current() =>
    array<float> s = array.new_float(LDIM, 0.0)
    for d = 0 to LDIM - 1
        float z = array.get(ENC_B, d)
        for k = 0 to NFEAT - 1
            z += matrix.get(ENC_W, d, k) * array.get(F_NOW, k)
        array.set(s, d, tanh_f(z))
    s
array<float> S_NOW = encode_current()
// ═══════════════════════════════════════════════════════════════════════════════
// MEMORY BANK 
// ═══════════════════════════════════════════════════════════════════════════════
var array<float> MEM_F  = array.new_float(0)   
var array<float> MLAT   = array.new_float(0)   
var array<float> MOUT   = array.new_float(0)
var array<float> MRES   = array.new_float(0)
var array<float> MLOR   = array.new_float(0)
var array<float> MEP    = array.new_float(0)
var array<int>   MBAR   = array.new_int(0)
var int MEM_N = 0
mem_size() => MEM_N
mem_f(int slot, int k) => array.get(MEM_F, slot * NFEAT + k)
mem_lat(int slot, int d) =>
    int idx = slot * LDIM + d
    idx < array.size(MLAT) ? array.get(MLAT, idx) : 0.0
mem_ok() =>
    MEM_N >= 0 and array.size(MLAT) == MEM_N * LDIM and array.size(MOUT) == MEM_N and array.size(MRES) == MEM_N
// ═══════════════════════════════════════════════════════════════════════════════
// REGIME & GAMMA
// ═══════════════════════════════════════════════════════════════════════════════
float hurst_r1 = nz(ta.stdev(close, 8),  0.0)
float hurst_r2 = nz(ta.stdev(close, 32), 0.0)
float hurst    = hurst_r2 > 0 ? clamp(0.5 + (hurst_r1 / hurst_r2 - 0.5) * 0.8, 0.1, 0.9) : 0.5
string regime      = hurst > 0.60 ? "Trend" : hurst < 0.40 ? "MeanRev" : "Ranging"
int    regime_code = regime == "Trend" ? 1 : regime == "MeanRev" ? -1 : 0
float volty       = atr_sma > 0 ? atr14 / atr_sma : 1.0
float gamma_ent   = F4 > 0.7 ? 1.4 : F4 < 0.3 ? 0.7 : 1.0
float gamma_reg   = regime == "Trend" ? 1.5 : regime == "MeanRev" ? 0.6 : 1.0
float gamma_vol   = 1.0 + (volty - 1.0) * 0.5
var float gamma_rcm_mod = 1.0
float gamma_now   = i_gamma * gamma_ent * gamma_reg * gamma_vol * gamma_rcm_mod
float inv_g2      = 1.0 / math.max(gamma_now * gamma_now, EPS)
// ═══════════════════════════════════════════════════════════════════════════════
// LORENTZIAN KERNEL
// ═══════════════════════════════════════════════════════════════════════════════
var array<float> FW = array.from(1.00, 0.80, 0.90, 1.10, 1.20, 1.00, 0.85, 0.95, 1.15, 1.05, 0.95, 1.10, 0.85)
float FW_SUM = 12.90
kernel_sim(int slot, float inv_g2_local) =>
    float logd   = 0.0
    int   base   = slot * NFEAT
    for k = 0 to NFEAT - 1
        float dx = array.get(F_NOW, k) - array.get(MEM_F, base + k)
        logd += array.get(FW, k) * math.log(1.0 + dx * dx * inv_g2_local)
    math.exp(-logd / FW_SUM)
// ═══════════════════════════════════════════════════════════════════════════════
// WORLD MODEL
// ═══════════════════════════════════════════════════════════════════════════════
var matrix<float> TM = matrix.new<float>(LDIM, LDIM, 0.0)
var array<float>  TB = array.new_float(LDIM, 0.0)
var array<float>  WR = array.new_float(LDIM, 0.0)
var float BR       = 0.0
var float PRED_ERR = 0.10
var float WM_ACC   = 0.50
var bool  wm_init  = false
if not wm_init and bar_index == 0
    for d = 0 to LDIM - 1
        matrix.set(TM, d, d, 0.90)
    wm_init := true
imagine_from(array<float> seed_in) =>
    array<float> st = array.copy(seed_in)
    float tot  = 0.0
    float disc = 1.0
    for step = 0 to i_depth - 1
        array<float> ns = array.new_float(LDIM, 0.0)
        for d = 0 to LDIM - 1
            float vv = array.get(TB, d)
            for dd = 0 to LDIM - 1
                vv += matrix.get(TM, d, dd) * array.get(st, dd)
            array.set(ns, d, tanh_f(vv))
        float r = BR
        for d = 0 to LDIM - 1
            r += array.get(WR, d) * array.get(ns, d)
        tot  += disc * r
        disc *= i_discount
        st   := ns
    tanh_f(tot * 5.0)
// ═══════════════════════════════════════════════════════════════════════════════
// RCM (GLOBAL SCOPE)
// ═══════════════════════════════════════════════════════════════════════════════
f_rcm_auto_config() =>
    rcm.RCMConfig result = rcm.default_config()
    if i_rcm_preset == "Scalp"
        result := rcm.scalp_config()
    else if i_rcm_preset == "Swing"
        result := rcm.swing_config()
    else if i_rcm_preset == "Auto"
        int tfMins = timeframe.in_seconds() / 60
        if tfMins <= 5
            result := rcm.scalp_config()
        else if tfMins >= 240
            result := rcm.swing_config()
        else
            result := rcm.default_config()
    result
var rcm.RCMState  rcm_st  = rcm.RCMState.new()
var rcm.RCMConfig rcm_cfg = f_rcm_auto_config()
var float RCM_BULL_EV   = 0.0
var float RCM_BEAR_EV   = 0.0
var float RCM_INTEG_MOD = 0.0
rcm.ExternalEvidence _rcm_ev = rcm.ExternalEvidence.new(RCM_BULL_EV, RCM_BEAR_EV, RCM_INTEG_MOD, "LDRA")
rcm_st := i_use_rcm ? rcm.inject(rcm_st, _rcm_ev) : rcm_st
rcm_st := i_use_rcm ? rcm.update(rcm_st, rcm_cfg) : rcm_st
// ═══════════════════════════════════════════════════════════════════════════════
// RUNTIME STATE
// ═══════════════════════════════════════════════════════════════════════════════
var float lor_pred   = 0.0
var float lor_conf   = 0.0
var float lor_assur  = 0.0
var float mem_bias   = 0.0
var bool  seed_valid = false
var array<float> SEED_L = array.new_float(LDIM, 0.0)
var array<float> KNN_S  = array.new_float(0)
var array<int>   KNN_I  = array.new_int(0)
var float WM_RESID  = 0.0
var float WM_UNC    = 0.5
var float WM_SKEW   = 0.0
var float IMAG_CONF = 0.0
var float GATE      = 0.5
var float FUSED_SCORE = 0.0
var float FUSED_CONF  = 0.0
var float LOR_PREV    = 0.0
var array<float> S_PREV = array.new_float(LDIM, 0.0)
// ═══════════════════════════════════════════════════════════════════════════════
// MANIFOLD TRAJECTORY STORAGE
// ═══════════════════════════════════════════════════════════════════════════════
var array<float> TRAJ_Y      = array.new_float()
var array<float> TRAJ_Z      = array.new_float()
var array<float> TRAJ_CONF   = array.new_float()
var array<float> TRAJ_SCORE  = array.new_float()
var array<int>   TRAJ_REGIME = array.new_int()
var array<int>   TRAJ_BAR    = array.new_int()
var array<bool>  TRAJ_EVENT  = array.new_bool()
var float CONFLUENCE_SCORE  = 0.0
var int   CONFLUENCE_COUNT  = 0
var float LOR_CONFLUENCE    = 0.0
var float STRUCT_CONFLUENCE = 0.0
var float FLOW_CONFLUENCE   = 0.0
var float RCM_CONFLUENCE    = 0.0
// ═══════════════════════════════════════════════════════════════════════════════
// MAIN LOOP
// ═══════════════════════════════════════════════════════════════════════════════
if barstate.isconfirmed and bar_index > i_warm
    if mem_ok()
        // KNN retrieval
        array.clear(KNN_S)
        array.clear(KNN_I)
        seed_valid := false
        for d = 0 to LDIM - 1
            array.set(SEED_L, d, 0.0)
        int memN = MEM_N
        if memN > i_pivot + 2
            int s0 = math.max(0, memN - i_lookback)
            int s1 = math.max(0, memN - i_pivot - 1)
            if s1 >= s0
                float knn_min = -1.0
                float cf4  = array.get(F_NOW, 4)
                float cf8  = array.get(F_NOW, 8)
                float cf3  = array.get(F_NOW, 3)
                float cf11 = array.get(F_NOW, 11)
                for slot = s0 to s1
                    float oc = array.get(MOUT, slot)
                    float rs = array.get(MRES, slot)
                    if not na(oc) and not na(rs)
                        int knn_n = array.size(KNN_S)
                        if knn_n >= i_neighbors
                            int base = slot * NFEAT
                            float cheap_d = math.abs(cf4  - array.get(MEM_F, base + 4))
                                          + math.abs(cf8  - array.get(MEM_F, base + 8))
                                          + math.abs(cf3  - array.get(MEM_F, base + 3))
                                          + math.abs(cf11 - array.get(MEM_F, base + 11))
                            if cheap_d > 3.5
                                continue
                        float sim = kernel_sim(slot, inv_g2)
                        if sim > i_min_sim and sim > EPS and (knn_n < i_neighbors or sim > knn_min)
                            int n   = knn_n
                            int pos = n
                            if n > 0
                                for p = 0 to n - 1
                                    if sim > array.get(KNN_S, p)
                                        pos := p
                                        break
                            array.insert(KNN_S, pos, sim)
                            array.insert(KNN_I, pos, slot)
                            if array.size(KNN_S) > i_neighbors
                                array.pop(KNN_S)
                                array.pop(KNN_I)
                            if array.size(KNN_S) > 0
                                knn_min := array.get(KNN_S, array.size(KNN_S) - 1)
        // Weighted aggregation 
        int   nn   = array.size(KNN_S)
        float wsum = 0.0
        float pred = 0.0
        float bias = 0.0
        float bull = 0.0
        float bear = 0.0
        float f4_w = F4    
        if nn > 0
            for j = 0 to nn - 1
                float w  = array.get(KNN_S, j)
                int   sl = array.get(KNN_I, j)
                float oc = array.get(MOUT, sl)
                float rs = array.get(MRES, sl)
                float mass = w * (1.0 - f4_w * 0.3)
                pred += oc * mass
                bias += rs * mass
                wsum += mass
                if oc > 0.0
                    bull += mass
                else if oc < 0.0
                    bear += mass
                int lat_base = sl * LDIM
                for d = 0 to LDIM - 1
                    array.set(SEED_L, d, array.get(SEED_L, d) + w * array.get(MLAT, lat_base + d))
        if wsum > EPS
            lor_pred  := pred / wsum
            lor_assur := math.abs(bull - bear) / wsum
            lor_conf  := clamp(float(nn) / float(i_neighbors), 0.0, 1.0)
            mem_bias  := clamp(bias / wsum, -1.0, 1.0)
            float inv_wsum = 1.0 / wsum
            for d = 0 to LDIM - 1
                array.set(SEED_L, d, array.get(SEED_L, d) * inv_wsum)
            seed_valid := true
        else
            lor_pred  := 0.0
            lor_conf  := 0.0
            lor_assur := 0.0
            mem_bias  := 0.0
            seed_valid := false
        // World-model update 
        float lr_wm  = i_wm_lr * math.max(0.15, 1.0 - WM_ACC)
        float t_err2 = 0.0
        for d = 0 to LDIM - 1
            float p = array.get(TB, d)
            for dd = 0 to LDIM - 1
                p += matrix.get(TM, d, dd) * array.get(S_PREV, dd)
            float s_hat = tanh_f(p)
            float err   = array.get(S_NOW, d) - s_hat
            t_err2 += err * err
            for dd = 0 to LDIM - 1
                float upd = matrix.get(TM, d, dd) + lr_wm * err * array.get(S_PREV, dd)
                matrix.set(TM, d, dd, clamp(upd * 0.99995, -2.0, 2.0))
            array.set(TB, d, clamp(array.get(TB, d) + lr_wm * err * 0.1, -1.0, 1.0))
        PRED_ERR := PRED_ERR * 0.95 + math.sqrt(t_err2 / LDIM) * 0.05
        float prev_close    = nz(close[1], close)
        float bar_ret_raw   = prev_close > 0 ? (close - prev_close) / prev_close : 0.0
        float bar_ret_norm  = atr14 > 0 and close > 0 ? clamp(bar_ret_raw / (atr14 / close), -2.0, 2.0) / 2.0 : 0.0
        float resid_target  = bar_ret_norm - LOR_PREV
        float resid_pred_wm = BR
        for d = 0 to LDIM - 1
            resid_pred_wm += array.get(WR, d) * array.get(S_PREV, d)
        float r_err = resid_target - resid_pred_wm
        float lr_half = lr_wm * 0.5
        for d = 0 to LDIM - 1
            array.set(WR, d, clamp(array.get(WR, d) + lr_half * r_err * array.get(S_PREV, d), -2.0, 2.0))
        BR := clamp(BR + lr_wm * 0.1 * r_err, -1.0, 1.0)
        WM_ACC := WM_ACC * 0.99 + (1.0 / (1.0 + PRED_ERR * 2.0)) * 0.01
        // Imagination rollouts
        bool  wm_ready = WM_ACC >= 0.3
        float base_val = wm_ready ? imagine_from(S_NOW) : 0.0
        if not seed_valid or nn == 0 or not wm_ready
            WM_RESID  := base_val
            WM_UNC    := 0.5
            WM_SKEW   := 0.0
            IMAG_CONF := WM_ACC * 0.5
        else
            float w_total = 0.0
            float r_total = 0.0
            float v_total = 0.0
            float max_r   = -9999.0
            float min_r   =  9999.0
            float inv_pmax = 1.0 / float(i_paths)
            for j = 0 to nn - 1
                float sim = array.get(KNN_S, j)
                int   sl  = array.get(KNN_I, j)
                array<float> blended = array.new_float(LDIM, 0.0)
                int lat_base = sl * LDIM
                for d = 0 to LDIM - 1
                    float n_lat = array.get(MLAT, lat_base + d)
                    float c_lat = array.get(S_NOW, d)
                    array.set(blended, d, sim * n_lat + (1.0 - sim) * c_lat)
                float p_sum  = 0.0
                float p_sum2 = 0.0
                for p = 0 to i_paths - 1
                    array<float> ns = array.copy(blended)
                    for d = 0 to LDIM - 1
                        float noise = (det_rand(bar_index * 541 + j * 199 + p * 29 + d) - 0.5) * 0.12 * PRED_ERR
                        array.set(ns, d, array.get(ns, d) + noise)
                    float pv = imagine_from(ns)
                    p_sum  += pv
                    p_sum2 += pv * pv
                float mean_r = p_sum * inv_pmax
                float var_r  = math.max(p_sum2 * inv_pmax - mean_r * mean_r, 0.0)
                float prec   = 1.0 / (var_r + EPS)
                float w      = sim * prec / (prec + 1.0)
                r_total += mean_r * w
                v_total += var_r  * w
                w_total += w
                max_r   := math.max(max_r, mean_r)
                min_r   := math.min(min_r, mean_r)
            if w_total > EPS
                float fr     = r_total / w_total
                float unc    = math.sqrt(v_total / w_total)
                float spread = math.max(max_r - min_r, EPS)
                float sk     = (fr - (max_r + min_r) * 0.5) / (spread * 0.5)
                WM_RESID  := fr
                WM_UNC    := clamp(unc, 0.0, 1.0)
                WM_SKEW   := clamp(sk, -1.0, 1.0)
                IMAG_CONF := WM_ACC * (1.0 - WM_UNC)
            else
                WM_RESID  := base_val
                WM_UNC    := 0.5
                WM_SKEW   := 0.0
                IMAG_CONF := WM_ACC * 0.5
        // RCM evidence injection
        RCM_BULL_EV   := 0.0
        RCM_BEAR_EV   := 0.0
        RCM_INTEG_MOD := 0.0
        if i_use_rcm
            if seed_valid and math.abs(lor_pred) > 0.1
                float lor_mag = math.abs(lor_pred) * lor_assur * i_inj_lor
                if lor_pred > 0
                    RCM_BULL_EV += lor_mag
                else
                    RCM_BEAR_EV += lor_mag
            if math.abs(delta_ratio) > 0.3 and (fp_active or vol_sma > 0)
                float d_mag = math.abs(delta_ratio) * i_inj_delta
                if delta_ratio > 0
                    RCM_BULL_EV += d_mag
                else
                    RCM_BEAR_EV += d_mag
            if i_use_msl and (at_siege_res or at_siege_sup)
                float s_mag = 0.5 * i_inj_siege
                RCM_BULL_EV   += s_mag * 0.5
                RCM_BEAR_EV   += s_mag * 0.5
                RCM_INTEG_MOD -= 0.1
            if i_use_msl and structure.active_count >= 2 and math.abs(ms_net_bias) > 0.4
                RCM_INTEG_MOD += 0.15
        float rcm_integrity       = i_use_rcm ? rcm_st.integrity : 1.0
        int   rcm_state_code_local = i_use_rcm ? rcm_st.state    : 0
        F12_ref := rcm_integrity * 2.0 - 1.0
        array.set(F_NOW, 12, F12_ref)
        gamma_rcm_mod := i_use_rcm ? clamp(0.7 + rcm_integrity * 0.6, 0.7, 1.3) : 1.0
        // Fused score & gate
        float agree_gate = math.sign(lor_pred) == math.sign(WM_RESID) ? 1.0 : 0.0
        float gate_raw   = 0.55 * lor_conf + 0.45 * (1.0 - WM_UNC) + 0.25 * agree_gate - 0.20 * PRED_ERR
        GATE := sigmoid(gate_raw)
        FUSED_SCORE := lor_pred + GATE * WM_RESID + 0.10 * mem_bias
        if i_use_msl and math.abs(ms_net_bias) > 0.3
            FUSED_SCORE += ms_net_bias * 0.15
        if math.abs(delta_ratio) > 0.4
            FUSED_SCORE += delta_ratio * 0.10
        FUSED_SCORE := clamp(FUSED_SCORE, -1.5, 1.5)
        FUSED_CONF  := clamp(lor_assur * 0.30 + agree_gate * 0.30 + IMAG_CONF * 0.15 + GATE * 0.10 + rcm_integrity * 0.15, 0.0, 1.0)
        // Confluence scoring
        LOR_CONFLUENCE    := math.abs(lor_pred) * lor_assur
        STRUCT_CONFLUENCE := at_struct ? (ms_inside_va ? 0.7 : 1.0) : 0.0
        FLOW_CONFLUENCE   := math.abs(delta_ratio)
        RCM_CONFLUENCE    := rcm_integrity
        float bull_conf = 0.0
        float bear_conf = 0.0
        if lor_pred > 0.1
            bull_conf += LOR_CONFLUENCE
        else if lor_pred < -0.1
            bear_conf += LOR_CONFLUENCE
        if delta_ratio > 0.2
            bull_conf += FLOW_CONFLUENCE * 0.8
        else if delta_ratio < -0.2
            bear_conf += FLOW_CONFLUENCE * 0.8
        if WM_RESID > 0.1
            bull_conf += math.abs(WM_RESID) * IMAG_CONF * 0.6
        else if WM_RESID < -0.1
            bear_conf += math.abs(WM_RESID) * IMAG_CONF * 0.6
        if i_use_rcm and rcm_state_code_local == 1
            bull_conf += RCM_CONFLUENCE * 0.5
        else if i_use_rcm and rcm_state_code_local == -1
            bear_conf += RCM_CONFLUENCE * 0.5
        if at_struct
            bull_conf *= 1.3
            bear_conf *= 1.3
        CONFLUENCE_SCORE := math.max(bull_conf, bear_conf)
        int ccount = 0
        if LOR_CONFLUENCE > 0.2
            ccount += 1
        if FLOW_CONFLUENCE > 0.2
            ccount += 1
        if at_struct
            ccount += 1
        if i_use_rcm and math.abs(rcm_state_code_local) == 1
            ccount += 1
        if IMAG_CONF > 0.3 and math.abs(WM_RESID) > 0.15
            ccount += 1
        CONFLUENCE_COUNT := ccount
        for k = 0 to NFEAT - 1
            array.push(MEM_F, array.get(F_NOW, k))
        for d = 0 to LDIM - 1
            array.push(MLAT, array.get(S_NOW, d))
        array.push(MOUT, na)
        array.push(MRES, na)
        array.push(MLOR, lor_pred)
        array.push(MEP,  close)
        array.push(MBAR, bar_index)
        MEM_N += 1
        int cap_soft = i_lookback
        int cap_hard = i_lookback + math.max(30, i_lookback / 5)
        if MEM_N > cap_hard
            int excess = MEM_N - cap_soft
            for _b = 0 to excess - 1
                for _k = 0 to NFEAT - 1
                    array.shift(MEM_F)
                for _d = 0 to LDIM - 1
                    array.shift(MLAT)
                array.shift(MOUT)
                array.shift(MRES)
                array.shift(MLOR)
                array.shift(MEP)
                array.shift(MBAR)
            MEM_N -= excess
        for i = 0 to MEM_N - 1
            int age = bar_index - array.get(MBAR, i)
            if age < i_pivot
                break
            if na(array.get(MOUT, i))
                float ep      = array.get(MEP, i)
                float lpr     = array.get(MLOR, i)
                float fr      = ep > 0 ? (close - ep) / ep : 0.0
                float fr_atr  = atr14 > 0 and close > 0 ? fr / (atr14 / close) : 0.0
                float lbl     = fr_atr > 0.35 ? 1.0 : fr_atr < -0.35 ? -1.0 : 0.0
                array.set(MOUT, i, lbl)
                array.set(MRES, i, fr_atr - lpr)
        for d = 0 to LDIM - 1
            array.set(S_PREV, d, array.get(S_NOW, d))
        LOR_PREV := lor_pred
        bool is_event = CONFLUENCE_SCORE >= i_conf_threshold and CONFLUENCE_COUNT >= 3
        array.push(TRAJ_Y,      array.get(S_NOW, 0))
        array.push(TRAJ_Z,      LDIM >= 2 ? array.get(S_NOW, 1) : 0.0)
        array.push(TRAJ_CONF,   FUSED_CONF)
        array.push(TRAJ_SCORE,  FUSED_SCORE)
        array.push(TRAJ_REGIME, regime_code)
        array.push(TRAJ_BAR,    bar_index)
        array.push(TRAJ_EVENT,  is_event)
        while array.size(TRAJ_Y) > i_ribbon_span
            array.shift(TRAJ_Y)
            array.shift(TRAJ_Z)
            array.shift(TRAJ_CONF)
            array.shift(TRAJ_SCORE)
            array.shift(TRAJ_REGIME)
            array.shift(TRAJ_BAR)
            array.shift(TRAJ_EVENT)
    else
        lor_pred         := 0.0
        lor_conf         := 0.0
        lor_assur        := 0.0
        mem_bias         := 0.0
        WM_RESID         := 0.0
        WM_UNC           := 0.5
        WM_SKEW          := 0.0
        IMAG_CONF        := 0.0
        GATE             := 0.0
        FUSED_SCORE      := 0.0
        FUSED_CONF       := 0.0
        seed_valid       := false
        CONFLUENCE_SCORE := 0.0
        CONFLUENCE_COUNT := 0
// ═══════════════════════════════════════════════════════════════════════════════
// MANIFOLD VISUALIZATION
// ═══════════════════════════════════════════════════════════════════════════════
color LOC_BULL   = THM.bull
color LOC_BEAR   = THM.bear
color LOC_ACCENT = THM.a
color LOC_PRIM   = THM.p
color LOC_SEC    = THM.s
color LOC_GHOST  = #9966FF
if i_theme == "Holographic"
    LOC_BULL   := #00F0FF
    LOC_BEAR   := #FF0055
    LOC_ACCENT := #C0C0FF
    LOC_PRIM   := #BD00FF
    LOC_SEC    := #00FFAA
    LOC_GHOST  := #CC88FF
var array<polyline> MESH_PL  = array.new<polyline>()
var array<line>     FX_LINES = array.new<line>()
var array<label>    FX_LBL   = array.new<label>()
project_3d_v2(float wx, float wy, float wz) =>
    float cx    = float(bar_index) - i_ribbon_span * 0.5
    float cy    = i_ribbon_height * 0.5
    float orbit = i_auto_rotate ? (float(timenow) / math.max(i_rot_speed * 1000.0, 1.0)) % 1.0 * 2.0 * math.pi : 0.0
    float elev  = math.toradians(i_cam_tilt)
    float cam_r = i_ribbon_span * 0.8
    float cam_x = cx + math.sin(orbit) * cam_r
    float cam_z = -math.cos(orbit) * cam_r * 1.6
    float cam_y = cy + i_ribbon_height * 1.3
    float yaw_c   = math.cos(orbit)
    float yaw_s   = math.sin(orbit)
    float pitch_c = math.cos(elev)
    float pitch_s = math.sin(elev)
    float dx = wx - cam_x
    float dy = wy - cam_y
    float dz = wz - cam_z
    float rx  = dx * yaw_c + dz * yaw_s
    float rz  = -dx * yaw_s + dz * yaw_c
    float ry  = dy
    float ry2 = ry * pitch_c - rz * pitch_s
    float rz2 = ry * pitch_s + rz * pitch_c
    float near   = 15.0
    float proj_z = rz2 + i_perspective
    bool  visible = proj_z > near
    float scale   = i_perspective / math.max(proj_z, near)
    float sx    = cx + rx * scale
    float sy    = cy + ry2 * scale * 0.82
    float depth = clamp(1.0 - (proj_z / (i_perspective * 3.5)), 0.0, 1.0)
    [sx, sy, depth, visible]
depth_alpha(int base_a, float d) =>
    int(math.max(0, math.min(100, base_a + int((1.0 - d * d) * 55))))
regime_color(int reg, float conf, float d) =>
    color base = reg == 1 ? LOC_BULL : reg == -1 ? LOC_BEAR : LOC_ACCENT
    int a = math.max(0, math.min(95, 28 + int((1.0 - conf) * 28) - int((1.0 - d) * 22)))
    color.new(base, a)
// ═══════════════════════════════════════════════════════════════════════════════
// RENDER
// ═══════════════════════════════════════════════════════════════════════════════
if barstate.islast
    for pl in MESH_PL
        polyline.delete(pl)
    array.clear(MESH_PL)
    for ln in FX_LINES
        line.delete(ln)
    array.clear(FX_LINES)
    for lb in FX_LBL
        label.delete(lb)
    array.clear(FX_LBL)
    int n_traj = array.size(TRAJ_Y)
    if n_traj > 3
        float cx = float(bar_index) - i_ribbon_span * 0.5
        float cy = i_ribbon_height * 0.5
        float x0 = float(bar_index) - i_ribbon_span
        float x1 = float(bar_index)
        if i_show_grid
            int   g_res  = 5
            float zr     = i_ribbon_depth * 2.5
            color grid_c = color.new(LOC_PRIM, 94)
            for gi = 0 to g_res
                float gz = -zr + float(gi) / g_res * zr * 2.0
                array<chart.point> gpts = array.new<chart.point>()
                for gj = 0 to g_res
                    float gx = x0 + float(gj) / g_res * (x1 - x0)
                    [gsx, gsy, gdep, gvis] = project_3d_v2(gx, cy * 0.06, gz)
                    if gvis
                        gpts.push(chart.point.from_index(int(math.round(gsx)), gsy))
                if gpts.size() >= 2
                    array.push(MESH_PL, polyline.new(gpts, curved=false, closed=false, line_color=grid_c, line_width=1, xloc=xloc.bar_index))
            for gj = 0 to g_res
                float gx = x0 + float(gj) / g_res * (x1 - x0)
                array<chart.point> gpts = array.new<chart.point>()
                for gi = 0 to g_res
                    float gz = -zr + float(gi) / g_res * zr * 2.0
                    [gsx, gsy, gdep, gvis] = project_3d_v2(gx, cy * 0.06, gz)
                    if gvis
                        gpts.push(chart.point.from_index(int(math.round(gsx)), gsy))
                if gpts.size() >= 2
                    array.push(MESH_PL, polyline.new(gpts, curved=false, closed=false, line_color=grid_c, line_width=1, xloc=xloc.bar_index))
            [lx,  ly,  ld,  lv]  = project_3d_v2(x1 + i_ribbon_span * 0.08, cy * 0.06, 0.0)
            if lv
                array.push(FX_LBL, label.new(int(math.round(lx)), ly, text="◀ TIME", textcolor=color.new(LOC_ACCENT, depth_alpha(10, ld)), style=label.style_none, size=size.small, xloc=xloc.bar_index))
            [lyx, lyy, lyd, lyv] = project_3d_v2(x0 - i_ribbon_span * 0.05, i_ribbon_height * 0.92, 0.0)
            if lyv
                array.push(FX_LBL, label.new(int(math.round(lyx)), lyy, text="MEMORY ▲", textcolor=color.new(LOC_ACCENT, depth_alpha(10, lyd)), style=label.style_none, size=size.small, xloc=xloc.bar_index))
            [lzx, lzy, lzd, lzv] = project_3d_v2(x0, cy * 0.06, -zr * 1.15)
            if lzv
                array.push(FX_LBL, label.new(int(math.round(lzx)), lzy, text="DEPTH ◆", textcolor=color.new(LOC_PRIM, depth_alpha(15, lzd)), style=label.style_none, size=size.tiny, xloc=xloc.bar_index))
        if i_show_isosurf
            for si = 0 to 1
                int slice_bar = bar_index - int(float(i_ribbon_span) * float(si + 1) / 3.0)
                for vj = 0 to 1
                    float vz = -i_ribbon_depth + float(vj) * i_ribbon_depth * 2.0
                    array<chart.point> s_pts = array.new<chart.point>()
                    for vi = 0 to 4
                        float vy = cy * 0.06 + float(vi) / 4.0 * i_ribbon_height * 0.94
                        [vsx, vsy, vdep, vvis] = project_3d_v2(float(slice_bar), vy, vz)
                        if vvis
                            s_pts.push(chart.point.from_index(int(math.round(vsx)), vsy))
                    if s_pts.size() >= 2
                        color sc = si == 0 ? color.new(LOC_BULL, 85) : color.new(LOC_PRIM, 88)
                        array.push(MESH_PL, polyline.new(s_pts, curved=false, closed=false, line_color=sc, line_width=1, xloc=xloc.bar_index))
                for vi = 0 to 4
                    float vy = cy * 0.06 + float(vi) / 4.0 * i_ribbon_height * 0.94
                    array<chart.point> s_pts = array.new<chart.point>()
                    for vj = 0 to 1
                        float vz = -i_ribbon_depth + float(vj) * i_ribbon_depth * 2.0
                        [vsx, vsy, vdep, vvis] = project_3d_v2(float(slice_bar), vy, vz)
                        if vvis
                            s_pts.push(chart.point.from_index(int(math.round(vsx)), vsy))
                    if s_pts.size() >= 2
                        color sc = si == 0 ? color.new(LOC_BULL, 85) : color.new(LOC_PRIM, 88)
                        array.push(MESH_PL, polyline.new(s_pts, curved=false, closed=false, line_color=sc, line_width=1, xloc=xloc.bar_index))
        int   W      = 9
        float w_half = 4.0
        float w_step = i_ribbon_depth * 2.8 / w_half
        for w = 0 to W - 1
            float z_off = (float(w) - w_half) * w_step
            array<chart.point> lng_pts = array.new<chart.point>()
            for i = 0 to n_traj - 1
                int   tb  = array.get(TRAJ_BAR,   i)
                float ty  = array.get(TRAJ_Y,     i)
                float tz  = array.get(TRAJ_Z,     i)
                float tsc = array.get(TRAJ_SCORE, i)
                float wave = math.sin(float(i) * 0.12 + float(w) * 0.35) * 0.14 * (1.0 + math.abs(tsc))
                float wz   = tz * i_ribbon_depth + z_off
                float wy   = cy + ty * (i_ribbon_height * 0.44) + z_off * tsc * 0.18 + wave * i_ribbon_height
                [sx, sy, dep, vis] = project_3d_v2(float(tb), wy, wz)
                if vis
                    lng_pts.push(chart.point.from_index(int(math.round(sx)), sy))
            if lng_pts.size() >= 2
                bool is_center = w == 4
                int  alpha     = is_center ? 12 : int(clamp(25.0 + (1.0 - math.abs(float(w) - w_half) / w_half) * 35.0, 18.0, 58.0))
                color lng_col  = is_center ? color.new(LOC_PRIM, alpha) : color.new(LOC_SEC, alpha + 8)
                array.push(MESH_PL, polyline.new(lng_pts, curved=true, closed=false, line_color=lng_col, line_width=is_center ? 3 : 1, xloc=xloc.bar_index))
        int lat_stride = math.max(1, int(math.ceil(float(n_traj) / 24.0)))
        int li = 0
        while li < n_traj
            int   tb    = array.get(TRAJ_BAR,    li)
            float ty    = array.get(TRAJ_Y,      li)
            float tz    = array.get(TRAJ_Z,      li)
            float tsc   = array.get(TRAJ_SCORE,  li)
            int   reg   = array.get(TRAJ_REGIME, li)
            float tconf = array.get(TRAJ_CONF,   li)
            array<chart.point> lat_pts = array.new<chart.point>()
            for w = 0 to W - 1
                float z_off = (float(w) - w_half) * w_step
                float wave  = math.sin(float(li) * 0.12 + float(w) * 0.35) * 0.14 * (1.0 + math.abs(tsc))
                float wz    = tz * i_ribbon_depth + z_off
                float wy    = cy + ty * (i_ribbon_height * 0.44) + z_off * tsc * 0.18 + wave * i_ribbon_height
                [sx, sy, dep, vis] = project_3d_v2(float(tb), wy, wz)
                if vis
                    lat_pts.push(chart.point.from_index(int(math.round(sx)), sy))
            if lat_pts.size() >= 2
                array.push(MESH_PL, polyline.new(lat_pts, curved=false, closed=false, line_color=regime_color(reg, tconf, 1.0), line_width=1, xloc=xloc.bar_index))
            li += lat_stride
        if i_show_nebula and MEM_N > 0
            int neb_start = math.max(0, MEM_N - 35)
            for mi = neb_start to MEM_N - 1
                int mb = array.get(MBAR, mi)
                if mb >= bar_index - i_ribbon_span and mb <= bar_index
                    int   lat_base = mi * LDIM
                    float ml0 = array.get(MLAT, lat_base)
                    float ml1 = LDIM >= 2 ? array.get(MLAT, lat_base + 1) : 0.0
                    float ml2 = LDIM >= 3 ? array.get(MLAT, lat_base + 2) : 0.0
                    float wz  = ml1 * i_ribbon_depth * 0.8 + ml2 * i_ribbon_depth * 0.3
                    float wy  = cy + ml0 * (i_ribbon_height * 0.44)
                    [sx, sy, dep, vis] = project_3d_v2(float(mb), wy, wz)
                    if vis and dep > 0.05
                        float psz   = i_ribbon_height * 0.018 * dep
                        int   ix    = int(math.round(sx))
                        color pt_col = ml0 > 0.2 ? color.new(LOC_BULL, depth_alpha(8, dep)) : ml0 < -0.2 ? color.new(LOC_BEAR, depth_alpha(8, dep)) : color.new(LOC_ACCENT, depth_alpha(12, dep))
                        array.push(FX_LINES, line.new(ix - 1, sy - psz, ix + 1, sy + psz, color=pt_col, width=2))
                        array.push(FX_LINES, line.new(ix - 1, sy + psz, ix + 1, sy - psz, color=pt_col, width=2))
                        if dep > 0.35
                            [fx, fy, fdep, fvis] = project_3d_v2(float(mb), cy * 0.06, wz)
                            if fvis
                                array.push(FX_LINES, line.new(ix, sy, int(math.round(fx)), fy, color=color.new(pt_col, 90), width=1, style=line.style_dotted))
        if seed_valid and WM_ACC >= 0.25 and n_traj > 5
            float cur_y = array.get(TRAJ_Y,   n_traj - 1)
            float cur_z = array.get(TRAJ_Z,   n_traj - 1)
            int   cur_b = array.get(TRAJ_BAR, n_traj - 1)
            [c_sx, c_sy, c_dep, c_vis] = project_3d_v2(float(cur_b), cy + cur_y * (i_ribbon_height * 0.44), cur_z * i_ribbon_depth)
            if c_vis
                for g = 0 to 2
                    array<chart.point> ghost_pts = array.new<chart.point>()
                    ghost_pts.push(chart.point.from_index(int(math.round(c_sx)), c_sy))
                    float g_seed   = det_rand(bar_index * 31 + g * 257)
                    float g_spread = (g_seed - 0.5) * 2.0
                    float g_dir    = WM_RESID + g_spread * WM_UNC * 1.8
                    float g_curve  = g_spread * 0.25
                    for f = 1 to 8
                        float fx  = float(cur_b + f * 3)
                        float fy  = cur_y + g_dir * f * 0.08 + g_curve * math.sin(float(f) * 0.5) * 0.18
                        float fz  = cur_z + g_spread * f * 0.04
                        float fwy = cy + fy * (i_ribbon_height * 0.44)
                        [fsx, fsy, fdep, fvis] = project_3d_v2(fx, fwy, fz * i_ribbon_depth)
                        if fvis
                            ghost_pts.push(chart.point.from_index(int(math.round(fsx)), fsy))
                    if ghost_pts.size() >= 2
                        color g_col = WM_RESID > 0.15 ? color.new(LOC_BULL, 45 + g * 12) : WM_RESID < -0.15 ? color.new(LOC_BEAR, 45 + g * 12) : color.new(LOC_GHOST, 45 + g * 12)
                        array.push(MESH_PL, polyline.new(ghost_pts, curved=true, closed=false, line_color=g_col, line_width=g == 1 ? 2 : 1, xloc=xloc.bar_index))
                float halo_r = i_ribbon_height * 0.04 * (1.0 - WM_UNC * 0.7)
                array<chart.point> halo_pts = array.new<chart.point>()
                for a = 0 to 16
                    float ang = float(a) / 16.0 * 2.0 * math.pi
                    halo_pts.push(chart.point.from_index(int(math.round(c_sx + math.cos(ang) * 3.0)), c_sy + math.sin(ang) * halo_r))
                if halo_pts.size() >= 2
                    array.push(MESH_PL, polyline.new(halo_pts, curved=true, closed=true, line_color=GATE > 0.6 ? color.new(LOC_BULL, 40) : color.new(LOC_PRIM, 50), line_width=2, xloc=xloc.bar_index))
                string arrow_txt = WM_RESID > 0.2 ? "▲" : WM_RESID < -0.2 ? "▼" : "◆"
                color  arrow_col = WM_RESID > 0.2 ? color.new(LOC_BULL, 0) : WM_RESID < -0.2 ? color.new(LOC_BEAR, 0) : color.new(LOC_ACCENT, 0)
                array.push(FX_LBL, label.new(int(math.round(c_sx)), c_sy, text=arrow_txt, textcolor=arrow_col, style=label.style_none, size=size.normal, xloc=xloc.bar_index))
        if i_show_constellation and array.size(KNN_S) > 0 and seed_valid
            int   nn_c  = array.size(KNN_S)
            float cur_y = array.get(TRAJ_Y,   n_traj - 1)
            float cur_z = array.get(TRAJ_Z,   n_traj - 1)
            int   cur_b = array.get(TRAJ_BAR, n_traj - 1)
            [cur_sx_f, cur_sy_f, cur_dep, cur_vis] = project_3d_v2(float(cur_b), cy + cur_y * (i_ribbon_height * 0.44), cur_z * i_ribbon_depth)
            if cur_vis
                int cur_sx = int(math.round(cur_sx_f))
                for kj = 0 to nn_c - 1
                    int mem_slot = array.get(KNN_I, kj)
                    int nb       = MEM_N > mem_slot ? array.get(MBAR, mem_slot) : na
                    if not na(nb)
                        int traj_slot = -1
                        for ts = 0 to n_traj - 1
                            if array.get(TRAJ_BAR, ts) == nb
                                traj_slot := ts
                                break
                        if traj_slot >= 0
                            float nly = array.get(TRAJ_Y, traj_slot)
                            float nlz = array.get(TRAJ_Z, traj_slot)
                            [n_sx_f, n_sy_f, n_dep, n_vis] = project_3d_v2(float(nb), cy + nly * (i_ribbon_height * 0.44), nlz * i_ribbon_depth)
                            if n_vis
                                float sim  = array.get(KNN_S, kj)
                                int   n_sx = int(math.round(n_sx_f))
                                int   alpha = int(clamp((1.0 - sim) * 55 + 15, 15, 70))
                                float psize = i_ribbon_height * 0.012
                                array.push(FX_LINES, line.new(cur_sx, cur_sy_f, n_sx, n_sy_f, color=color.new(LOC_PRIM, alpha), width=1, style=line.style_dashed))
                                array.push(FX_LINES, line.new(n_sx - 1, n_sy_f, n_sx + 1, n_sy_f, color=color.new(LOC_PRIM, 35), width=1))
                                array.push(FX_LINES, line.new(n_sx, n_sy_f - psize, n_sx, n_sy_f + psize, color=color.new(LOC_PRIM, 35), width=1))
        if i_show_nodes
            int nodes_drawn = 0
            for ti2 = n_traj - 1 to 0
                if nodes_drawn >= 14
                    break
                if array.get(TRAJ_EVENT, ti2)
                    float ey   = array.get(TRAJ_Y,      ti2)
                    float ez   = array.get(TRAJ_Z,      ti2)
                    int   eb   = array.get(TRAJ_BAR,    ti2)
                    float esc  = array.get(TRAJ_SCORE,  ti2)
                    int   ereg = array.get(TRAJ_REGIME, ti2)
                    [sx_f, sy_f, dep, vis] = project_3d_v2(float(eb), cy + ey * (i_ribbon_height * 0.44), ez * i_ribbon_depth)
                    if vis and dep > 0.12
                        color  node_col = esc > 0.3 ? LOC_BULL : esc < -0.3 ? LOC_BEAR : LOC_ACCENT
                        string sym      = ereg == 1 ? "▲" : ereg == -1 ? "▼" : "◆"
                        array.push(FX_LBL, label.new(int(math.round(sx_f)), sy_f, text=sym, textcolor=color.new(node_col, depth_alpha(5, dep)), style=label.style_none, size=size.small, xloc=xloc.bar_index))
                        nodes_drawn += 1
// ═══════════════════════════════════════════════════════════════════════════════
// CONFLUENCE DOTS
// ═══════════════════════════════════════════════════════════════════════════════
bool has_bull_conf = lor_pred > 0.1 or delta_ratio > 0.2 or (i_use_rcm and rcm_st.state == 1)
bool has_bear_conf = lor_pred < -0.1 or delta_ratio < -0.2 or (i_use_rcm and rcm_st.state == -1)
bool conf_bull  = CONFLUENCE_SCORE >= i_conf_threshold and CONFLUENCE_COUNT >= 2 and has_bull_conf and not has_bear_conf
bool conf_bear  = CONFLUENCE_SCORE >= i_conf_threshold and CONFLUENCE_COUNT >= 2 and has_bear_conf and not has_bull_conf
bool conf_tier2 = CONFLUENCE_SCORE >= i_conf_threshold * 1.4 and CONFLUENCE_COUNT >= 3
bool conf_tier3 = CONFLUENCE_SCORE >= i_conf_threshold * 1.8 and CONFLUENCE_COUNT >= 4
color dot_bull_col = color.new(THM.bull, 20)
color dot_bear_col = color.new(THM.bear, 20)
bool dot_sz1 = i_dot_size == 1
bool dot_sz2 = i_dot_size == 2
bool dot_sz3 = i_dot_size == 3
plotshape(conf_bull and dot_sz1, title="Conf Bull (tiny)",   style=shape.circle, location=location.belowbar, color=dot_bull_col, size=size.tiny, force_overlay=true)
plotshape(conf_bull and dot_sz2, title="Conf Bull (small)",  style=shape.circle, location=location.belowbar, color=dot_bull_col, size=size.tiny, force_overlay=true)
plotshape(conf_bull and dot_sz3, title="Conf Bull (normal)", style=shape.circle, location=location.belowbar, color=dot_bull_col, size=size.tiny, force_overlay=true)
plotshape(conf_bear and dot_sz1, title="Conf Bear (tiny)",   style=shape.circle, location=location.abovebar, color=dot_bear_col, size=size.tiny, force_overlay=true)
plotshape(conf_bear and dot_sz2, title="Conf Bear (small)",  style=shape.circle, location=location.abovebar, color=dot_bear_col, size=size.tiny, force_overlay=true)
plotshape(conf_bear and dot_sz3, title="Conf Bear (normal)", style=shape.circle, location=location.abovebar, color=dot_bear_col, size=size.tiny, force_overlay=true)
plotshape(i_dot_stack and conf_bull and conf_tier2 and dot_sz1, title="Conf Bull T2 (tiny)",   style=shape.circle, location=location.belowbar, color=color.new(THM.bull, 10), size=size.tiny, force_overlay=true)
plotshape(i_dot_stack and conf_bull and conf_tier2 and dot_sz2, title="Conf Bull T2 (small)",  style=shape.circle, location=location.belowbar, color=color.new(THM.bull, 10), size=size.tiny, force_overlay=true)
plotshape(i_dot_stack and conf_bull and conf_tier2 and dot_sz3, title="Conf Bull T2 (normal)", style=shape.circle, location=location.belowbar, color=color.new(THM.bull, 10), size=size.tiny, force_overlay=true)
plotshape(i_dot_stack and conf_bear and conf_tier2 and dot_sz1, title="Conf Bear T2 (tiny)",   style=shape.circle, location=location.abovebar, color=color.new(THM.bear, 10), size=size.tiny, force_overlay=true)
plotshape(i_dot_stack and conf_bear and conf_tier2 and dot_sz2, title="Conf Bear T2 (small)",  style=shape.circle, location=location.abovebar, color=color.new(THM.bear, 10), size=size.tiny, force_overlay=true)
plotshape(i_dot_stack and conf_bear and conf_tier2 and dot_sz3, title="Conf Bear T2 (normal)", style=shape.circle, location=location.abovebar, color=color.new(THM.bear, 10), size=size.tiny, force_overlay=true)
plotshape(i_dot_stack and conf_bull and conf_tier3 and dot_sz1, title="Conf Bull T3 (tiny)",   style=shape.diamond, location=location.belowbar, color=color.new(THM.p, 0), size=size.tiny, force_overlay=true)
plotshape(i_dot_stack and conf_bull and conf_tier3 and dot_sz2, title="Conf Bull T3 (small)",  style=shape.diamond, location=location.belowbar, color=color.new(THM.p, 0), size=size.tiny, force_overlay=true)
plotshape(i_dot_stack and conf_bull and conf_tier3 and dot_sz3, title="Conf Bull T3 (normal)", style=shape.diamond, location=location.belowbar, color=color.new(THM.p, 0), size=size.tiny, force_overlay=true)
plotshape(i_dot_stack and conf_bear and conf_tier3 and dot_sz1, title="Conf Bear T3 (tiny)",   style=shape.diamond, location=location.abovebar, color=color.new(THM.p, 0), size=size.tiny, force_overlay=true)
plotshape(i_dot_stack and conf_bear and conf_tier3 and dot_sz2, title="Conf Bear T3 (small)",  style=shape.diamond, location=location.abovebar, color=color.new(THM.p, 0), size=size.tiny, force_overlay=true)
plotshape(i_dot_stack and conf_bear and conf_tier3 and dot_sz3, title="Conf Bear T3 (normal)", style=shape.diamond, location=location.abovebar, color=color.new(THM.p, 0), size=size.tiny, force_overlay=true)
alertcondition(conf_bull, title="LDRA Bull Confluence", message="LDRA: Bullish confluence detected")
alertcondition(conf_bear, title="LDRA Bear Confluence", message="LDRA: Bearish confluence detected")
plot(CONFLUENCE_SCORE, title="LDRA Confluence",   display=display.data_window, color=color.white)
plot(CONFLUENCE_COUNT, title="LDRA Components",   display=display.data_window, color=color.white)
plot(FUSED_SCORE,      title="LDRA Fused Score",  display=display.data_window, color=color.white)
plot(FUSED_CONF,       title="LDRA Fused Conf",   display=display.data_window, color=color.white)
// ═══════════════════════════════════════════════════════════════════════════════
// DASHBOARD 1 — STATE
// ═══════════════════════════════════════════════════════════════════════════════
f_dash_bar(float val, float maxVal, int len) =>
    float pct    = math.max(0.0, math.min(1.0, val / math.max(maxVal, EPS)))
    int   filled = math.round(pct * len)
    str.repeat("█", filled) + str.repeat("░", len - filled)
bool d1_overlay = i_dash1_mode == "Main Chart Overlay"
var table D1_OVR = table.new(f_dashPos(i_dash1_pos), 2, 13, bgcolor=color.new(#0A0A14, 10), border_color=color.new(THM.a, 40), border_width=1, frame_color=color.new(THM.a, 30), frame_width=1, force_overlay=true)
var table D1_PNL = table.new(f_dashPos(i_dash1_pos), 2, 13, bgcolor=color.new(#0A0A14, 10), border_color=color.new(THM.a, 40), border_width=1, frame_color=color.new(THM.a, 30), frame_width=1, force_overlay=false)
if barstate.islast and i_show_dash1
    if d1_overlay
        table.clear(D1_PNL, 0, 0, 1, 12)
    else
        table.clear(D1_OVR, 0, 0, 1, 12)
    table dash1    = d1_overlay ? D1_OVR : D1_PNL
    color c_text   = color.new(#E0E0F0, 0)
    color c_up     = color.new(THM.bull, 0)
    color c_dn     = color.new(THM.bear, 0)
    color c_mid    = color.new(THM.a, 0)
    color c_hdr    = color.new(THM.p, 0)
    string conf_text = conf_bull ? "▲ BULL CONF" : conf_bear ? "▼ BEAR CONF" : "—"
    color  conf_col  = conf_bull ? c_up : conf_bear ? c_dn : color.new(color.gray, 0)
    string rcm_text  = i_use_rcm ? (rcm_st.state == 1 ? "▲ BULL" : rcm_st.state == -1 ? "▼ BEAR" : "◆ TRANS") : "—"
    color  rcm_col   = i_use_rcm ? (rcm_st.state == 1 ? c_up : rcm_st.state == -1 ? c_dn : c_mid) : color.new(color.gray, 0)
    float  integ     = i_use_rcm ? rcm_st.integrity : 1.0
    color  integ_col = integ > 0.7 ? c_up : integ > 0.4 ? c_mid : c_dn
    color  reg_col   = regime == "Trend" ? c_up : regime == "MeanRev" ? c_dn : color.new(color.yellow, 0)
    string struct_txt = at_siege_res ? "Siege R" : at_siege_sup ? "Siege S" : at_poc ? "At POC" : at_vah ? "At VAH" : at_val ? "At VAL" : ms_inside_va ? "In VA" : "Free"
    string fp_state   = fp_active ? "LIVE" : "EST"
    color  hdr_bg     = color.new(THM.p, 85)
    if i_dash1_size == "Full"
        table.cell(dash1, 0, 0, "⟡  Lorentzian Dreamer  ⟡", text_color=c_hdr, text_size=size.normal, text_font_family=font.family_monospace, bgcolor=hdr_bg, text_halign=text.align_center)
        table.cell(dash1, 1, 0, "", bgcolor=hdr_bg)
        table.merge_cells(dash1, 0, 0, 1, 0)
        table.cell(dash1, 0, 1, "CONFLUENCE",  text_color=c_text, text_size=size.small, text_font_family=font.family_monospace)
        table.cell(dash1, 1, 1, conf_text,     text_color=conf_col, text_size=size.normal, text_font_family=font.family_monospace)
        table.cell(dash1, 0, 2, "Score",       text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 1, 2, str.tostring(CONFLUENCE_SCORE, "#.##") + " " + f_dash_bar(CONFLUENCE_SCORE, 2.0, 8), text_color=CONFLUENCE_SCORE > i_conf_threshold ? c_up : c_mid, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 0, 3, "Components",  text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 1, 3, str.tostring(CONFLUENCE_COUNT) + "/5", text_color=CONFLUENCE_COUNT >= 3 ? c_up : c_mid, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 0, 4, "Lor",         text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 1, 4, f_dash_bar(LOR_CONFLUENCE, 1.0, 8) + "  " + str.tostring(lor_pred, "#.##"), text_color=lor_pred > 0 ? c_up : c_dn, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 0, 5, "Flow",        text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 1, 5, f_dash_bar(FLOW_CONFLUENCE, 1.0, 8) + "  " + str.tostring(delta_ratio, "#.##"), text_color=delta_ratio > 0 ? c_up : c_dn, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 0, 6, "RCM",         text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 1, 6, rcm_text,      text_color=rcm_col, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 0, 7, "Integrity",   text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 1, 7, str.tostring(integ * 100, "#") + "% " + f_dash_bar(integ, 1.0, 8), text_color=integ_col, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 0, 8, "Regime",      text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 1, 8, regime,        text_color=reg_col, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 0, 9, "Structure",   text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 1, 9, struct_txt,    text_color=at_struct ? c_mid : color.new(color.gray, 0), text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 0, 10, "Δ Ratio",   text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 1, 10, str.tostring(delta_ratio, "#.##") + " (" + fp_state + ")", text_color=delta_ratio > 0 ? c_up : c_dn, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 0, 11, "Mem / KNN", text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 1, 11, str.tostring(MEM_N) + " / " + str.tostring(array.size(KNN_S)), text_color=color.new(color.gray, 0), text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 0, 12, "Manifold",  text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 1, 12, str.tostring(array.size(TRAJ_Y)) + " bars", text_color=color.new(color.gray, 0), text_size=size.tiny, text_font_family=font.family_monospace)
    else if i_dash1_size == "Compact"
        table.cell(dash1, 0, 0, "⟡ LDRA", text_color=c_hdr, bgcolor=hdr_bg, text_size=size.small, text_font_family=font.family_monospace)
        table.cell(dash1, 1, 0, "", bgcolor=hdr_bg)
        table.merge_cells(dash1, 0, 0, 1, 0)
        table.cell(dash1, 0, 1, "Confluence", text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 1, 1, conf_text,    text_color=conf_col, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 0, 2, "Score",      text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 1, 2, str.tostring(CONFLUENCE_SCORE, "#.##") + " [" + str.tostring(CONFLUENCE_COUNT) + "/5]", text_color=CONFLUENCE_SCORE > i_conf_threshold ? c_up : c_mid, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 0, 3, "Regime",     text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 1, 3, regime,       text_color=reg_col, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 0, 4, "Structure",  text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 1, 4, struct_txt,   text_color=at_struct ? c_mid : color.new(color.gray, 0), text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 0, 5, "RCM",        text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 1, 5, rcm_text,     text_color=rcm_col, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 0, 6, "Δ Ratio",    text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 1, 6, str.tostring(delta_ratio, "#.##") + " (" + fp_state + ")", text_color=delta_ratio > 0 ? c_up : c_dn, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 0, 7, "⟡ DAFE ⟡", text_color=color.new(THM.p, 40), bgcolor=color.new(#0A0A14, 0), text_size=size.tiny, text_font_family=font.family_monospace, text_halign=text.align_center)
        table.merge_cells(dash1, 0, 7, 1, 7)
    else
        color gcol_mini = conf_bull ? c_up : conf_bear ? c_dn : color.new(color.gray, 0)
        table.cell(dash1, 0, 0, "⟡ LDRA", text_color=c_hdr, bgcolor=hdr_bg, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash1, 1, 0, "", bgcolor=hdr_bg)
        table.merge_cells(dash1, 0, 0, 1, 0)
        table.cell(dash1, 0, 1, conf_text, text_color=gcol_mini, bgcolor=color.new(#0A0A14, 30), text_size=size.normal, text_font_family=font.family_monospace)
        table.merge_cells(dash1, 0, 1, 1, 1)
        table.cell(dash1, 0, 2, "Score: " + str.tostring(CONFLUENCE_SCORE, "#.##") + "  Mem: " + str.tostring(MEM_N), text_color=c_mid, bgcolor=color.new(#0A0A14, 30), text_size=size.tiny, text_font_family=font.family_monospace)
        table.merge_cells(dash1, 0, 2, 1, 2)
// ═══════════════════════════════════════════════════════════════════════════════
// DASHBOARD 2 — DIAGNOSTICS
// ═══════════════════════════════════════════════════════════════════════════════
bool d2_overlay = i_dash2_mode == "Main Chart Overlay"
var table D2_OVR = table.new(f_dashPos(i_dash2_pos), 2, 11, bgcolor=color.new(#0A0A14, 10), border_color=color.new(THM.a, 40), border_width=1, frame_color=color.new(THM.a, 30), frame_width=1, force_overlay=true)
var table D2_PNL = table.new(f_dashPos(i_dash2_pos), 2, 11, bgcolor=color.new(#0A0A14, 10), border_color=color.new(THM.a, 40), border_width=1, frame_color=color.new(THM.a, 30), frame_width=1, force_overlay=false)
if barstate.islast and i_show_dash2
    if d2_overlay
        table.clear(D2_PNL, 0, 0, 1, 10)
    else
        table.clear(D2_OVR, 0, 0, 1, 10)
    table dash2   = d2_overlay ? D2_OVR : D2_PNL
    color c_text  = color.new(#E0E0F0, 0)
    color c_up    = color.new(THM.bull, 0)
    color c_dn    = color.new(THM.bear, 0)
    color c_mid   = color.new(THM.a, 0)
    color pe_col  = PRED_ERR < 0.2 ? c_up : PRED_ERR < 0.5 ? c_mid : c_dn
    color unc_col = WM_UNC  < 0.3 ? c_up : WM_UNC  < 0.6 ? c_mid : c_dn
    color hdr_bg  = color.new(THM.p, 85)
    if i_dash2_size == "Full"
        table.cell(dash2, 0, 0, "⚙  DIAGNOSTICS  ⚙", text_color=color.new(THM.p, 0), text_size=size.normal, text_font_family=font.family_monospace, bgcolor=hdr_bg, text_halign=text.align_center)
        table.cell(dash2, 1, 0, "", bgcolor=hdr_bg)
        table.merge_cells(dash2, 0, 0, 1, 0)
        table.cell(dash2, 0, 1, "Lor Pred",      text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 1, 1, str.tostring(lor_pred, "#.###") + " " + f_dash_bar(math.abs(lor_pred), 1.0, 8), text_color=lor_pred > 0 ? c_up : c_dn, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 0, 2, "Lor Assurance", text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 1, 2, str.tostring(lor_assur * 100, "#") + "% " + f_dash_bar(lor_assur, 1.0, 8), text_color=c_mid, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 0, 3, "Dream Resid",   text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 1, 3, str.tostring(WM_RESID, "#.###") + " " + f_dash_bar(math.abs(WM_RESID), 1.0, 8), text_color=WM_RESID > 0 ? c_up : c_dn, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 0, 4, "Dream Unc",     text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 1, 4, str.tostring(WM_UNC * 100, "#") + "% " + f_dash_bar(1.0 - WM_UNC, 1.0, 8), text_color=unc_col, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 0, 5, "WM Accuracy",   text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 1, 5, str.tostring(WM_ACC * 100, "#") + "% " + f_dash_bar(WM_ACC, 1.0, 8), text_color=WM_ACC > 0.6 ? c_up : c_mid, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 0, 6, "Trust Gate",    text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 1, 6, str.tostring(GATE * 100, "#") + "% " + f_dash_bar(GATE, 1.0, 8), text_color=GATE > 0.5 ? c_up : c_mid, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 0, 7, "Pred Err",      text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 1, 7, str.tostring(PRED_ERR, "#.###"), text_color=pe_col, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 0, 8, "Absorption",    text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 1, 8, str.tostring(absorption * 100, "#") + "% " + f_dash_bar(absorption, 1.0, 8), text_color=absorption > 0.3 ? c_mid : color.new(color.gray, 0), text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 0, 9, "Dream Skew",    text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 1, 9, str.tostring(WM_SKEW, "#.##"), text_color=WM_SKEW > 0 ? c_up : c_dn, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 0, 10, "Gamma",        text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 1, 10, str.tostring(gamma_now, "#.##"), text_color=c_mid, text_size=size.tiny, text_font_family=font.family_monospace)
    else if i_dash2_size == "Compact"
        table.cell(dash2, 0, 0, "⚙ DIAG", text_color=color.new(THM.p, 0), bgcolor=hdr_bg, text_size=size.small, text_font_family=font.family_monospace)
        table.cell(dash2, 1, 0, "", bgcolor=hdr_bg)
        table.merge_cells(dash2, 0, 0, 1, 0)
        table.cell(dash2, 0, 1, "Lor Pred",    text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 1, 1, str.tostring(lor_pred, "#.###"), text_color=lor_pred > 0 ? c_up : c_dn, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 0, 2, "Dream Resid", text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 1, 2, str.tostring(WM_RESID, "#.###"), text_color=WM_RESID > 0 ? c_up : c_dn, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 0, 3, "WM Acc",      text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 1, 3, str.tostring(WM_ACC * 100, "#") + "%", text_color=WM_ACC > 0.6 ? c_up : c_mid, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 0, 4, "Trust Gate",  text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 1, 4, str.tostring(GATE * 100, "#") + "%", text_color=GATE > 0.5 ? c_up : c_mid, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 0, 5, "Pred Err",    text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 1, 5, str.tostring(PRED_ERR, "#.###"), text_color=pe_col, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 0, 6, "Gamma",       text_color=c_text, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 1, 6, str.tostring(gamma_now, "#.##"), text_color=c_mid, text_size=size.tiny, text_font_family=font.family_monospace)
    else
        table.cell(dash2, 0, 0, "⚙ DIAG", text_color=color.new(THM.p, 0), bgcolor=hdr_bg, text_size=size.tiny, text_font_family=font.family_monospace)
        table.cell(dash2, 1, 0, "", bgcolor=hdr_bg)
        table.merge_cells(dash2, 0, 0, 1, 0)
        table.cell(dash2, 0, 1, "Lor " + str.tostring(lor_pred, "#.##") + "  Gate " + str.tostring(GATE * 100, "#") + "%", text_color=lor_pred > 0 ? c_up : c_dn, bgcolor=color.new(#0A0A14, 30), text_size=size.normal, text_font_family=font.family_monospace)
        table.merge_cells(dash2, 0, 1, 1, 1)
        table.cell(dash2, 0, 2, "WM " + str.tostring(WM_ACC * 100, "#") + "%  Err " + str.tostring(PRED_ERR, "#.###"), text_color=c_mid, bgcolor=color.new(#0A0A14, 30), text_size=size.tiny, text_font_family=font.family_monospace)
        table.merge_cells(dash2, 0, 2, 1, 2)
// ═══════════════════════════════════════════════════════════════════════════════
// WATERMARK
// ═══════════════════════════════════════════════════════════════════════════════
var table wm = table.new(position.bottom_right, 1, 1, bgcolor=color.new(#0A0A14, 99), border_color=color.new(THM.a, 50), border_width=1)
if barstate.islast
    table.cell(wm, 0, 0, "⟡ Dskyz (DAFE) Trading Systems ⟡", text_color=color.new(THM.a, 40), text_size=size.normal)
````
