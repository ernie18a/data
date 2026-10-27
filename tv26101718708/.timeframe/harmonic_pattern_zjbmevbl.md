# Harmonic Pattern

- url: https://www.tradingview.com/script/zjBMEVBl-Harmonic-Pattern/
- type: indicator
- pine_id: PUB;03f2f00d6b2547ebb4ee9c98072eb5fa
- version: 1.0

## Description

Institutional Harmonic

PRZ Lifecycle Scanner is a harmonic pattern and price structure indicator designed to identify confirmed pivot formations, Potential Reversal Zones, pattern lifecycle states, invalidation levels, and ATR-based risk projection areas.

The indicator is built for structured chart reading. It does not predict future price movement, does not execute trades, and does not guarantee results. Its purpose is to help traders study harmonic geometry, PRZ reactions, market structure, volatility context, and risk areas in a clear visual framework.

────────────────────────────
MAIN CONCEPT
────────────────────────────

Harmonic trading is based on the relationship between price legs. A valid pattern is not only a drawing on the chart. It requires measured ratios, a defined completion area, and a clear invalidation zone.

This indicator uses confirmed pivots to build X-A-B-C-D structures and other market patterns. When a valid structure is detected, the script calculates a Potential Reversal Zone using ratio confluence and then follows the pattern through different lifecycle states.

The main idea is simple:

1. Detect a confirmed structure.
2. Measure the ratios.
3. Build the PRZ.
4. Wait for price interaction with the PRZ.
5. Track reaction, invalidation, or target progression.

────────────────────────────
WHAT THE INDICATOR CAN DISPLAY
────────────────────────────

The script can display:

* Harmonic X-A-B-C-D structures
* Potential Reversal Zones
* Pattern labels
* Pattern score
* Bullish or bearish direction
* Entry reference
* Invalidation level
* Stop area
* TP1, TP2, and TP3 projection levels
* TP zones
* Pattern lifecycle status
* Dashboard information
* Higher timeframe bias
* Volatility context
* Alert events

────────────────────────────
PATTERN LIFECYCLE
────────────────────────────

Each pattern can move through several states:

DETECTED
A valid structure has been found and measured.

PRZ TOUCHED
Price has reached the Potential Reversal Zone.

REACTION
A rejection or reaction condition has appeared after price interacts with the PRZ.

TP1 HIT
The first projected target has been reached.

TP2 HIT
The second projected target has been reached.

TP3 HIT
The third projected target has been reached.

FAILED
Price has moved beyond the invalidation area.

EXPIRED
The pattern remained active for too many bars without developing.

This lifecycle approach is designed to separate raw pattern detection from cleaner trading context.

────────────────────────────
PATTERNS INCLUDED
────────────────────────────

The indicator can detect several harmonic and structural formations, depending on the active settings:

* Gartley
* Bat
* Alternate Bat
* Butterfly
* Crab
* Deep Crab
* Cypher
* 5-0
* AB=CD
* Three Drives
* Double Top
* Double Bottom
* Triple Top
* Triple Bottom
* Head and Shoulders
* Inverse Head and Shoulders
* Triangle
* Wedge

Each pattern type can be enabled or disabled from the settings.

────────────────────────────
INPUTS EXPLAINED
────────────────────────────

ENGINE SETTINGS

Pivot Depth
Controls how many bars are used to confirm a pivot high or pivot low. A lower value detects more structures but can create more noise. A higher value detects fewer structures but usually produces cleaner formations.

Ratio Tolerance
Defines how much deviation is allowed around the expected Fibonacci or structural ratio. Lower tolerance is stricter. Higher tolerance allows more patterns.

Minimum XA Size
Filters out very small patterns. This helps avoid structures that are too small compared to current volatility.

Minimum Score
Defines the minimum quality score required before a pattern can be displayed. A higher score means fewer but more selective patterns.

Pattern Expiration Bars
Defines how long an active pattern can remain valid before it is considered expired.

────────────────────────────
PATTERN SETTINGS

Enable Gartley
Turns Gartley pattern detection on or off.

Enable Bat
Turns Bat pattern detection on or off.

Enable Alternate Bat
Turns Alternate Bat pattern detection on or off.

Enable Butterfly
Turns Butterfly pattern detection on or off.

Enable Crab
Turns Crab pattern detection on or off.

Enable Deep Crab
Turns Deep Crab pattern detection on or off.

Enable Cypher
Turns Cypher pattern detection on or off.

Enable 5-0
Turns 5-0 pattern detection on or off.

Enable AB=CD
Turns AB=CD pattern detection on or off.

Enable Three Drives
Turns Three Drives detection on or off.

Enable Double Top / Bottom
Turns Double Top and Double Bottom detection on or off.

Enable Triple Top / Bottom
Turns Triple Top and Triple Bottom detection on or off.

Enable Head and Shoulders
Turns Head and Shoulders detection on or off.

Enable Inverse Head and Shoulders
Turns Inverse Head and Shoulders detection on or off.

Enable Triangle
Turns triangle structure detection on or off.

Enable Wedge
Turns wedge structure detection on or off.

────────────────────────────
PRZ SETTINGS

Show Institutional PRZ
Shows or hides the Potential Reversal Zone.

Auto-Extend PRZ Only
Extends active PRZ zones automatically as new bars appear.

Max Active PRZ Zones
Limits how many PRZ zones can stay visible on the chart.

PRZ Width / Confluence Sensitivity
Controls how tight or wide the PRZ can be around the calculated confluence area. A tighter setting is more selective. A wider setting is more visual and easier to see.

Show PRZ Labels
Shows or hides labels linked to the PRZ and pattern state.

────────────────────────────
RISK MODEL SETTINGS

Show Entry / SL / TP
Shows or hides the risk projection model.

Auto-Extend RM Lines / Labels
Extends Entry, SL, TP, and label positions automatically as new bars appear.

Show TP Zones
Shows or hides the colored target zones.

Auto-Extend TP Zones
Extends TP zone backgrounds automatically as new bars appear.

Max Active Risk Models
Limits the number of visible risk models.

Max Active TP Zone Sets
Limits the number of visible TP zone groups.

Level Projection Bars
Controls how far Entry, SL, TP, PRZ, and target zone objects are projected to the right side of the chart.

ATR Stop Multiplier
Controls the distance of the invalidation or stop reference using ATR.

TP1 Multiplier
Controls the first target projection.

TP2 Multiplier
Controls the second target projection.

TP3 Multiplier
Controls the third target projection.

Show TP3
Shows or hides the third target.

────────────────────────────
VISUAL SETTINGS

Show Connectors
Shows or hides the internal pattern connector lines.

Show Pattern Labels
Shows or hides the pattern name labels.

Show Ratio Labels
Shows or hides ratio information on the chart.

Neutral Color Theme
Uses a cleaner chart style with more neutral colors.

Bullish Color
Controls the color used for bullish structures.

Bearish Color
Controls the color used for bearish structures.

PRZ Color
Controls the color used for Potential Reversal Zones.

Risk Color
Controls the color used for invalidation or stop areas.

Target Color
Controls the color used for target zones.

────────────────────────────
DASHBOARD SETTINGS

Show Dashboard
Shows or hides the information panel.

Dashboard Position
Moves the panel to the selected chart corner.

Dashboard Detail Mode
Controls how much information appears inside the dashboard.

The dashboard can show:

* Last detected pattern
* Direction
* Score
* Status
* PRZ range
* Entry reference
* Invalidation level
* TP1, TP2, TP3
* Higher timeframe bias
* ATR regime
* Active PRZ count
* Active risk model count
* Extension status

────────────────────────────
CONTEXT SETTINGS

Use Higher Timeframe Bias
Adds a higher timeframe trend context to the dashboard or scoring logic.

Higher Timeframe
Selects the timeframe used for higher timeframe bias.

HTF EMA Fast
Defines the fast EMA used for higher timeframe trend reading.

HTF EMA Slow
Defines the slow EMA used for higher timeframe trend reading.

Use VWAP Context
Adds VWAP context when available on the chart.

Use ATR Regime
Adds volatility regime information based on ATR behavior.

────────────────────────────
ALERT SETTINGS

Alert New Pattern
Triggers an alert when a new valid pattern is detected. This is useful for scanning, but it should not be treated as a trade entry by itself.

Alert PRZ Touch
Triggers an alert when price reaches the PRZ.

Alert Confirmed Reaction
Triggers an alert when price reacts after interacting with the PRZ.

Alert High Score Only
Filters alerts so that only patterns above a selected score can trigger.

Alert Minimum Score
Sets the minimum score required for high-score alerts.

Alert TP Hits
Triggers alerts when TP1, TP2, or TP3 is reached.

Alert Failed Pattern
Triggers an alert when a pattern is invalidated.

Webhook Alert Mode
Allows dynamic alert messages to be used for automation workflows.

For cleaner alerts, it is generally better to focus on confirmed reaction alerts instead of raw new pattern alerts.

────────────────────────────
MINI TUTORIAL FOR BEGINNERS
────────────────────────────

1. Add the indicator to the chart.

2. Start with default settings.

3. Look for a clean pattern label and PRZ zone.

4. Do not treat a new pattern as an entry by itself. First, wait for price to reach or interact with the PRZ.

5. Check the pattern status:

* DETECTED means the structure exists.
* PRZ TOUCHED means price reached the reaction area.
* REACTION means the script detected a reaction condition.
* FAILED means the setup is invalidated.
* TP1, TP2, or TP3 means projected target areas were reached.

6. Check the dashboard:

* Pattern name
* Direction
* Score
* Status
* PRZ
* Invalidation
* Higher timeframe bias
* Volatility context

7. Compare the setup with your own chart reading:

* Is price near support or resistance?
* Is there liquidity nearby?
* Is the market trending or ranging?
* Is the pattern aligned with the higher timeframe?
* Is the invalidation distance acceptable?

8. Use alerts carefully. For cleaner signals, use confirmed reaction alerts rather than raw detection alerts.

────────────────────────────
EXAMPLE USE CASES
────────────────────────────

Example 1: Bullish harmonic reaction
A bullish harmonic pattern appears near a previous support area. Price enters the PRZ and prints a rejection reaction. The lifecycle status changes from DETECTED to PRZ TOUCHED, then to REACTION. The trader can use the PRZ, invalidation, and target levels as visual references for further analysis.

Example 2: Bearish pattern near resistance
A bearish pattern forms near a previous resistance area. Price reaches the PRZ and fails to continue upward. If a reaction is detected, the dashboard updates the status and shows the bearish context, invalidation level, and projected targets.

Example 3: Pattern invalidation
A pattern is detected, but price moves beyond the invalidation level. The script marks the pattern as FAILED. This helps separate invalidated setups from still-active ones.

Example 4: Scanning mode
A trader can enable alerts for new patterns to monitor multiple charts. In this mode, new pattern alerts are used only as early notifications. A second check is still needed before making any decision.

Example 5: Cleaner alert mode
A trader who wants fewer alerts can disable New Pattern and PRZ Touch alerts, then keep only Confirmed Reaction, TP Hits, and Failed Pattern alerts active.

────────────────────────────
BEST PRACTICES
────────────────────────────

Use lower tolerance for stricter pattern detection.

Use higher pivot depth to reduce noise.

Use the dashboard to confirm the pattern state before focusing on the setup.

Use confirmed reaction alerts for cleaner notifications.

Avoid using the indicator alone. Combine it with market structure, support and resistance, liquidity areas, session context, and personal risk management.

Test the indicator on different symbols and timeframes before relying on it for live decisions.

────────────────────────────
LIMITATIONS
────────────────────────────

This script is an indicator, not a strategy.

It does not place orders.

It does not provide financial advice.

It does not guarantee profitable results.

Patterns can fail.

Alerts depend on the user’s TradingView alert settings.

Pivot-based tools confirm structures after enough bars have passed, so they should be understood as confirmation tools, not instant prediction tools.

Signals may be less reliable during low liquidity, high spread, major news, or highly erratic market conditions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  ███╗   ███╗ █████╗ ████████╗██████╗ ██╗██╗  ██╗    ██████╗ ██████╗       ║
// ║  ████╗ ████║██╔══██╗╚══██╔══╝██╔══██╗██║╚██╗██╔╝    ██╔══██╗██╔══██╗      ║
// ║  ██╔████╔██║███████║   ██║   ██████╔╝██║ ╚███╔╝     ██████╔╝██████╔╝      ║
// ║  ██║╚██╔╝██║██╔══██║   ██║   ██╔══██╗██║ ██╔██╗     ██╔═══╝ ██╔══██╗      ║
// ║  ██║ ╚═╝ ██║██║  ██║   ██║   ██║  ██║██║██╔╝ ██╗    ██║     ██║  ██║      ║
// ║  ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝    ╚═╝     ╚═╝  ╚═╝      ║
// ╠══════════════════════════════════════════════════════════════════════════════╣
// ║             INSTITUTIONAL HARMONIC MATRIX // ULTIMATE ENGINE               ║
// ╠══════════════════════════════════════════════════════════════════════════════╣
// ║  [root@wizard-terminal ~]$ sudo ./scan_market --mode=institutional          ║
// ║  [0x01] Fibonacci Ratio Core ..................... ONLINE                  ║
// ║  [0x02] PRZ Confluence Matrix .................... ONLINE                  ║
// ║  [0x03] Pattern Lifecycle Engine ................. ONLINE                  ║
// ║  [0x04] Reversal Reaction Scanner ................ ONLINE                  ║
// ║  [0x05] Auto Invalidation Layer .................. ONLINE                  ║
// ║  [0x06] Risk / Reward Projection Grid ............ ONLINE                  ║
// ║  [0x07] HTF Bias Synchronizer .................... ONLINE                  ║
// ║  [0x08] Volatility Regime Filter ................. ONLINE                  ║
// ║  [0x09] Webhook Alert Matrix ..................... ARMED                   ║
// ╠══════════════════════════════════════════════════════════════════════════════╣
// ║  01001000 01000001 01010010 01001101 01001111 01001110 01001001 01000011   ║
// ║  ⣿⣿⣿⣷⣤⣀⡀   ░▒▓█ MATRIX FEED ACTIVE █▓▒░   ⢀⣀⣤⣾⣿⣿⣿ ║
// ║  ⠐⠒⠒⠒⠒⠂   X-A-B-C-D  ::  PRZ  ::  SCORE  ::  STATUS   ⠐⠒⠒⠂ ║
// ║  /dev/patterns mounted   |   /var/prz synced   |   /tmp/noise filtered     ║
// ╠══════════════════════════════════════════════════════════════════════════════╣
// ║  Built for structured harmonic pattern reading, PRZ validation,             ║
// ║  lifecycle tracking, institutional-style visual mapping, and disciplined    ║
// ║  risk projection. This tool is an analytical overlay, not financial advice. ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

//@version=6
indicator("Harmonic Pattern", shorttitle="HP", overlay=true, max_bars_back=5000, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

//──────────────────────────────────────────────────────────────────────────────
// INPUTS
//──────────────────────────────────────────────────────────────────────────────
grpEngine = "01. Institutional Engine"
int i_depth = input.int(5, "Confirmed Pivot Depth", minval=2, maxval=30, group=grpEngine)
string i_mode = input.string("Balanced", "Detection Mode", options=["Strict", "Balanced", "Research"], group=grpEngine)
float i_ratio_tol = input.float(0.055, "Core Ratio Tolerance", minval=0.015, maxval=0.150, step=0.005, group=grpEngine)
float i_min_xa_atr = input.float(0.75, "Min XA Size / ATR", minval=0.0, maxval=10.0, step=0.05, group=grpEngine)
float i_min_swing_atr = input.float(0.20, "Min Pivot Swing / ATR", minval=0.0, maxval=5.0, step=0.05, group=grpEngine)
float i_min_conf = input.float(72.0, "Min Institutional Score", minval=40.0, maxval=98.0, step=1.0, group=grpEngine)
int i_max_pivots = input.int(140, "Pivot Memory", minval=30, maxval=300, group=grpEngine)
int i_max_pattern_age = input.int(3500, "Max Pattern Age Bars", minval=100, maxval=9000, group=grpEngine)

float tol = i_mode == "Strict" ? i_ratio_tol * 0.75 : i_mode == "Research" ? i_ratio_tol * 1.25 : i_ratio_tol

//──────────────────────────────────────────────────────────────────────────────
grpPrz = "02. PRZ / Risk Model"
bool i_show_prz = input.bool(true, "Show Institutional PRZ", group=grpPrz)
bool i_require_prz = input.bool(true, "Require D Inside / Near PRZ", group=grpPrz)
float i_prz_pad_atr = input.float(0.08, "PRZ Padding / ATR", minval=0.0, maxval=1.0, step=0.01, group=grpPrz)
float i_d_prz_max_atr = input.float(0.45, "Max D Distance From PRZ / ATR", minval=0.0, maxval=3.0, step=0.05, group=grpPrz)
float i_min_prz_score = input.float(48.0, "Min PRZ Tightness Score", minval=0.0, maxval=100.0, step=1.0, group=grpPrz)
bool i_show_risk = input.bool(true, "Show Entry / SL / TP", group=grpPrz)
float i_stop_pad_atr = input.float(0.25, "Stop Padding / ATR", minval=0.0, maxval=3.0, step=0.05, group=grpPrz)
int i_level_right = input.int(18, "Level Projection Bars", minval=4, maxval=120, group=grpPrz)

//──────────────────────────────────────────────────────────────────────────────
grpContext = "03. Context Filters"
bool i_use_htf = input.bool(false, "Use Stable HTF Bias", group=grpContext)
string i_htf_tf = input.timeframe("240", "HTF Bias Timeframe", group=grpContext)
int i_htf_ema_len = input.int(100, "HTF EMA Length", minval=10, maxval=300, group=grpContext)
bool i_require_htf = input.bool(false, "Require HTF Alignment", group=grpContext)
bool i_use_rsi = input.bool(true, "Use RSI Turn In Score", group=grpContext)
int i_rsi_len = input.int(14, "RSI Length", minval=2, maxval=100, group=grpContext)
bool i_use_volume = input.bool(true, "Use Volume Expansion In Score", group=grpContext)
int i_vol_len = input.int(20, "Volume Average Length", minval=5, maxval=200, group=grpContext)
float i_vol_mult = input.float(1.15, "Volume Expansion x MA", minval=0.5, maxval=5.0, step=0.05, group=grpContext)
bool i_use_candle = input.bool(true, "Use Reversal Candle In Score", group=grpContext)

//──────────────────────────────────────────────────────────────────────────────
grpPatterns = "04. Legit Engines"
bool en_gartley = input.bool(true, "Gartley", group=grpPatterns)
bool en_bat = input.bool(true, "Bat", group=grpPatterns)
bool en_altbat = input.bool(true, "Alternate Bat", group=grpPatterns)
bool en_butterfly = input.bool(true, "Butterfly", group=grpPatterns)
bool en_crab = input.bool(true, "Crab", group=grpPatterns)
bool en_deepcrab = input.bool(true, "Deep Crab", group=grpPatterns)
bool en_cypher = input.bool(true, "Cypher", group=grpPatterns)
bool en_fiveo = input.bool(true, "5-0", group=grpPatterns)
bool en_abcd = input.bool(true, "AB=CD Family", group=grpPatterns)
bool en_three = input.bool(true, "Three Drives", group=grpPatterns)
bool en_double = input.bool(true, "Double Top / Bottom", group=grpPatterns)
bool en_triple = input.bool(true, "Triple Top / Bottom", group=grpPatterns)
bool en_hs = input.bool(true, "Head & Shoulders", group=grpPatterns)
bool en_triangle = input.bool(true, "Triangle / Wedge", group=grpPatterns)

//──────────────────────────────────────────────────────────────────────────────
grpVisual = "05. Institutional Visuals"
int i_max_patterns = input.int(28, "Max Pattern Groups", minval=1, maxval=45, group=grpVisual)
int i_max_per_pivot = input.int(2, "Max Patterns Per New Pivot", minval=1, maxval=5, group=grpVisual)
bool i_show_path = input.bool(true, "Show Pattern Legs", group=grpVisual)
bool i_show_connectors = input.bool(true, "Show Connectors", group=grpVisual)
bool i_show_ratios = input.bool(false, "Show Ratio Diagnostics", group=grpVisual)
bool i_show_dashboard = input.bool(true, "Show Dashboard", group=grpVisual)
string i_dash_pos = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpVisual)
color i_col_bull = input.color(color.rgb(83, 115, 107), "Bull Neutral Color", group=grpVisual)
color i_col_bear = input.color(color.rgb(132, 97, 97), "Bear Neutral Color", group=grpVisual)
color i_col_text = input.color(color.rgb(235, 238, 242), "Text Color", group=grpVisual)
color i_col_panel = input.color(color.rgb(18, 22, 28), "Panel Color", group=grpVisual)

//──────────────────────────────────────────────────────────────────────────────
grpLifecycle = "06. Pattern Lifecycle"
bool i_lifecycle = input.bool(true, "Track Pattern Lifecycle", group=grpLifecycle)
bool i_extend_live = input.bool(true, "Auto-Extend Active Objects", group=grpLifecycle)
int i_expire_bars = input.int(180, "Expire After Bars", minval=20, maxval=1500, group=grpLifecycle)
float i_fail_close_pad_atr = input.float(0.05, "Failure Close Padding / ATR", minval=0.0, maxval=1.5, step=0.01, group=grpLifecycle)
string i_stop_trigger = input.string("Wick", "Stop / Invalidation Trigger", options=["Wick", "Close"], group=grpLifecycle)
bool i_replay_from_d = input.bool(true, "Replay D→Detection Status", group=grpLifecycle)
string i_entry_model = input.string("Signal Close", "RM Entry Model", options=["Signal Close", "Pattern D"], group=grpLifecycle)
bool i_actionable_rm_only = input.bool(false, "Legacy: Hide RM If Setup Already Consumed", group=grpLifecycle)
float i_max_entry_dist_atr = input.float(0.45, "Legacy Max Current Distance From D Entry / ATR", minval=0.0, maxval=5.0, step=0.05, group=grpLifecycle)
string i_target_model = input.string("Structure CD", "RM Target Model", options=["Structure CD", "Risk Multiple"], group=grpLifecycle)
float i_tp1_cd = input.float(0.382, "Structure TP1 CD Retrace", minval=0.100, maxval=1.500, step=0.001, group=grpLifecycle)
float i_tp2_cd = input.float(0.618, "Structure TP2 CD Retrace", minval=0.100, maxval=2.000, step=0.001, group=grpLifecycle)
float i_tp3_cd = input.float(1.000, "Structure TP3 CD Retrace", minval=0.100, maxval=3.000, step=0.001, group=grpLifecycle)
float i_tp1_r = input.float(1.0, "Legacy TP1 Risk Multiple", minval=0.25, maxval=10.0, step=0.25, group=grpLifecycle)
float i_tp2_r = input.float(2.0, "Legacy TP2 Risk Multiple", minval=0.25, maxval=15.0, step=0.25, group=grpLifecycle)
float i_tp3_r = input.float(3.0, "Legacy TP3 Risk Multiple", minval=0.25, maxval=25.0, step=0.25, group=grpLifecycle)
bool i_need_rejection = input.bool(true, "Require Rejection For Reaction", group=grpLifecycle)
float i_reject_wick_ratio = input.float(0.38, "Min Rejection Wick Ratio", minval=0.10, maxval=0.90, step=0.01, group=grpLifecycle)
bool i_show_lifecycle_text = input.bool(true, "Show Lifecycle In Main Label", group=grpLifecycle)

vpGroup = "07. Volume / Regime Layer"
bool i_use_vwap = input.bool(false, "Use VWAP Context In Score", group=vpGroup)
bool i_use_atr_regime = input.bool(true, "Use ATR Regime In Score", group=vpGroup)
int i_atr_regime_len = input.int(50, "ATR Regime Average", minval=10, maxval=300, group=vpGroup)

riskGroup = "08. Premium Risk Zones"
bool i_show_rr = input.bool(true, "Show RR In Labels", group=riskGroup)
bool i_show_target_zones = input.bool(true, "Show TP Zones", group=riskGroup)
bool i_extend_prz = input.bool(false, "Auto-Extend PRZ Only", group=riskGroup)
bool i_extend_rm = input.bool(false, "Auto-Extend RM Lines / Labels", group=riskGroup)
bool i_extend_tp_zones = input.bool(false, "Auto-Extend TP Zones", group=riskGroup)
int i_max_active_prz = input.int(1, "Max Active PRZ Zones", minval=1, maxval=50, group=riskGroup)
int i_max_active_rm = input.int(1, "Max Active Risk Models", minval=1, maxval=30, group=riskGroup)
int i_max_active_tp_zones = input.int(1, "Max Active TP Zone Sets", minval=1, maxval=30, group=riskGroup)

grpAlerts = "09. Alerts"
bool i_alert_calls = input.bool(false, "Enable Dynamic alert() Calls", group=grpAlerts)

//──────────────────────────────────────────────────────────────────────────────
// TYPES
//──────────────────────────────────────────────────────────────────────────────
type Pivot
    int idx
    float price
    bool isHigh

type Match
    string name
    bool bull
    Pivot x
    Pivot a
    Pivot b
    Pivot c
    Pivot d
    float r1
    float r2
    float r3
    float r4
    float score
    float przLo
    float przHi
    float entry
    float stop
    float tp1
    float tp2
    float tp3

type DrawPack
    line l1
    line l2
    line l3
    line l4
    line l5
    line l6
    line l7
    line lEntry
    line lStop
    line lTp1
    line lTp2
    line lTp3
    label mainLbl
    label ratLbl1
    label ratLbl2
    label entryLbl
    label stopLbl
    label tp1Lbl
    label tp2Lbl
    label tp3Lbl
    box przBox
    box riskBox
    box tp1Box
    box tp2Box
    box tp3Box

//──────────────────────────────────────────────────────────────────────────────
// STATE
//──────────────────────────────────────────────────────────────────────────────
var array<Pivot> pivots = array.new<Pivot>()
var array<DrawPack> packs = array.new<DrawPack>()
var array<string> seenKeys = array.new<string>()
var int totalPatterns = 0
var string lastName = "None"
var string lastSide = "-"
var float lastScore = na
var float lastPrzLo = na
var float lastPrzHi = na
var int lastPatternBar = na
var string lastStatus = "-"
var float lastEntry = na
var float lastStop = na
var float lastTp1 = na
var float lastTp2 = na
var float lastTp3 = na
var float lastRR1 = na
var float lastRR2 = na
var float lastRR3 = na

var array<string> packNames = array.new<string>()
var array<bool> packBulls = array.new<bool>()
var array<float> packScores = array.new<float>()
var array<float> packPrzLos = array.new<float>()
var array<float> packPrzHis = array.new<float>()
var array<float> packEntries = array.new<float>()
var array<float> packStops = array.new<float>()
var array<float> packTp1s = array.new<float>()
var array<float> packTp2s = array.new<float>()
var array<float> packTp3s = array.new<float>()
var array<int> packBars = array.new<int>()
var array<int> packStatuses = array.new<int>()
var array<int> packTouchedBars = array.new<int>()
var array<bool> packPrzVisible = array.new<bool>()
var array<bool> packRmVisible = array.new<bool>()
var array<bool> packTpVisible = array.new<bool>()

//──────────────────────────────────────────────────────────────────────────────
// HELPERS
//──────────────────────────────────────────────────────────────────────────────
f_clamp(float v, float lo, float hi) => math.max(lo, math.min(hi, v))
f_abs(float v) => math.abs(v)
f_fmt(float v) => str.tostring(v, "#.###")
f_fmt_price(float v) => str.tostring(v, format.mintick)
f_ratio_line(string tag, float v) => na(v) ? "" : tag + " " + f_fmt(v)
f_join_lines(string a, string b) => a == "" ? b : b == "" ? a : a + "\n" + b
f_status_txt(int st) => st == -5 ? "TP2 STOPPED" : st == -4 ? "TP1 STOPPED" : st == -3 ? "STOPPED" : st == -2 ? "EXPIRED" : st == -1 ? "FAILED" : st == 0 ? "DETECTED" : st == 1 ? "PRZ TOUCHED" : st == 2 ? "REACTION" : st == 3 ? "TP1 HIT" : st == 4 ? "TP2 HIT" : st == 5 ? "TP3 HIT" : "ACTIVE"
f_status_col(int st, bool bull) => st <= -3 ? color.rgb(138, 112, 82) : st == -2 ? color.rgb(92, 96, 104) : st == -1 ? color.rgb(150, 82, 82) : st >= 3 ? color.rgb(86, 125, 98) : st == 2 ? (bull ? color.rgb(76, 120, 102) : color.rgb(135, 92, 92)) : st == 1 ? color.rgb(150, 130, 80) : color.rgb(90, 98, 110)
f_rr(float entry, float stop, float target) => math.abs(target - entry) / math.max(math.abs(entry - stop), syminfo.mintick)
f_price_in_zone(float lo, float hi) => high >= lo and low <= hi
f_stop_hit_live(bool bull, float stop) =>
    bool wickHit = bull ? low <= stop : high >= stop
    bool closeHit = bull ? close <= stop : close >= stop
    i_stop_trigger == "Close" ? closeHit : wickHit
f_stop_hit_hist(bool bull, float stop, int off) =>
    bool wickHit = bull ? low[off] <= stop : high[off] >= stop
    bool closeHit = bull ? close[off] <= stop : close[off] >= stop
    i_stop_trigger == "Close" ? closeHit : wickHit
f_target_hit_hist(bool bull, float target, int off) => bull ? high[off] >= target : low[off] <= target
f_replay_status_from_d(bool bull, float stop, float t1, float t2, float t3, int dIdx) =>
    int st = 0
    int barsBack = math.min(math.max(bar_index - dIdx, 0), 5000)
    if i_replay_from_d and barsBack > 0
        for k = 0 to barsBack - 1
            int off = barsBack - 1 - k
            if st >= 0 and st < 5
                bool stopHit = f_stop_hit_hist(bull, stop, off)
                bool h1 = f_target_hit_hist(bull, t1, off)
                bool h2 = f_target_hit_hist(bull, t2, off)
                bool h3 = f_target_hit_hist(bull, t3, off)
                if stopHit
                    st := st >= 4 ? -5 : st >= 3 ? -4 : -1
                else if h3
                    st := 5
                else if h2
                    st := math.max(st, 4)
                else if h1
                    st := math.max(st, 3)
    st
f_bull_rejection(float lo, float hi) =>
    float rng = math.max(high - low, syminfo.mintick)
    float lw = math.min(open, close) - low
    bool touched = f_price_in_zone(lo, hi)
    touched and close > open and close > (high + low) * 0.5 and (not i_need_rejection or lw / rng >= i_reject_wick_ratio)
f_bear_rejection(float lo, float hi) =>
    float rng = math.max(high - low, syminfo.mintick)
    float uw = high - math.max(open, close)
    bool touched = f_price_in_zone(lo, hi)
    touched and close < open and close < (high + low) * 0.5 and (not i_need_rejection or uw / rng >= i_reject_wick_ratio)
f_in_target(float actual, float target, float tolerance) => actual >= target * (1.0 - tolerance) and actual <= target * (1.0 + tolerance)
f_in_range(float actual, float lo, float hi) => actual >= lo and actual <= hi

f_target_score(float actual, float target, float tolerance) =>
    float denom = math.max(math.abs(target) * tolerance, 0.000001)
    float err = math.abs(actual - target) / denom
    f_clamp(100.0 - err * 100.0, 0.0, 100.0)

f_range_score(float actual, float lo, float hi) =>
    float mid = (lo + hi) * 0.5
    float half = math.max((hi - lo) * 0.5, 0.000001)
    actual < lo or actual > hi ? 0.0 : f_clamp(100.0 - math.abs(actual - mid) / half * 40.0, 0.0, 100.0)

f_sym_score(int idx1, int idx2, int idx3, int idx4) =>
    float t1 = math.max(math.abs(idx2 - idx1), 1)
    float t2 = math.max(math.abs(idx4 - idx3), 1)
    float mn = math.min(t1, t2)
    float mx = math.max(t1, t2)
    f_clamp(mn / mx * 100.0, 0.0, 100.0)

f_pos(string s) =>
    p = position.top_right
    if s == "Top Left"
        p := position.top_left
    else if s == "Bottom Right"
        p := position.bottom_right
    else if s == "Bottom Left"
        p := position.bottom_left
    p

f_add_pivot(array<Pivot> store, bool isHigh, float price, int idx, float minMove) =>
    bool changed = false
    int sz = array.size(store)
    if sz == 0
        array.push(store, Pivot.new(idx, price, isHigh))
        changed := true
    else
        Pivot last = array.get(store, sz - 1)
        if last.idx == idx and last.isHigh != isHigh
            changed := false
        else if last.isHigh == isHigh
            bool moreExtreme = isHigh ? price > last.price : price < last.price
            if moreExtreme
                array.set(store, sz - 1, Pivot.new(idx, price, isHigh))
                changed := true
        else
            if math.abs(price - last.price) >= minMove
                array.push(store, Pivot.new(idx, price, isHigh))
                changed := true
    while array.size(store) > i_max_pivots
        array.shift(store)
    changed

f_key_exists(array<string> keys, string key) =>
    bool found = false
    int sz = array.size(keys)
    if sz > 0
        for i = 0 to sz - 1
            if array.get(keys, i) == key
                found := true
    found

f_remember_key(array<string> keys, string key) =>
    array.push(keys, key)
    while array.size(keys) > 600
        array.shift(keys)
    true

f_xad_level(Pivot x, Pivot a, bool bull, float ratio, bool extension) =>
    float xa = math.abs(a.price - x.price)
    float level = na
    if extension
        level := bull ? x.price - xa * ratio : x.price + xa * ratio
    else
        level := bull ? x.price + xa * ratio : x.price - xa * ratio
    level

f_xc_retr_level(Pivot x, Pivot c, bool bull, float ratio) =>
    float xc = math.abs(c.price - x.price)
    bull ? c.price - xc * ratio : c.price + xc * ratio

f_bc_level(Pivot b, Pivot c, bool bull, float ratio) =>
    float bc = math.abs(c.price - b.price)
    bull ? c.price - bc * ratio : c.price + bc * ratio

f_abcd_level(Pivot a, Pivot b, Pivot c, bool bull, float ratio) =>
    float ab = math.abs(b.price - a.price)
    bull ? c.price - ab * ratio : c.price + ab * ratio

f_build_prz(float lv1, float lv2, float lv3, Pivot c, Pivot d, bool bull, float atrVal, float xa) =>
    float rawLo = math.min(lv1, math.min(lv2, lv3))
    float rawHi = math.max(lv1, math.max(lv2, lv3))
    float pad = math.max(atrVal * i_prz_pad_atr, syminfo.mintick * 2.0)
    float przLo = rawLo - pad
    float przHi = rawHi + pad
    float width = math.max(przHi - przLo, syminfo.mintick)
    float tightDenom = math.max(atrVal, xa * 0.025)
    float tightScore = f_clamp(100.0 - width / tightDenom * 45.0, 0.0, 100.0)
    float entry = i_entry_model == "Signal Close" ? close : d.price
    float dir = bull ? 1.0 : -1.0
    float rawStop = bull ? przLo - atrVal * i_stop_pad_atr : przHi + atrVal * i_stop_pad_atr
    float fallbackStopDist = math.max(atrVal * math.max(i_stop_pad_atr, 0.10), syminfo.mintick * 4.0)
    float stop = bull ? (rawStop < entry ? rawStop : entry - fallbackStopDist) : (rawStop > entry ? rawStop : entry + fallbackStopDist)
    float risk = math.max(math.abs(entry - stop), syminfo.mintick * 4.0)
    float cdLen = math.max(math.abs(c.price - d.price), syminfo.mintick * 4.0)
    float t1Cd = math.max(i_tp1_cd, 0.001)
    float t2Cd = math.max(i_tp2_cd, t1Cd + 0.001)
    float t3Cd = math.max(i_tp3_cd, t2Cd + 0.001)
    float tp1Struct = entry + dir * cdLen * t1Cd
    float tp2Struct = entry + dir * cdLen * t2Cd
    float tp3StructCandidate = c.price
    float tp3StructFallback = entry + dir * cdLen * t3Cd
    bool cIsValidTarget = bull ? tp3StructCandidate > tp2Struct : tp3StructCandidate < tp2Struct
    float tp3Struct = cIsValidTarget ? tp3StructCandidate : tp3StructFallback
    float r1 = math.max(i_tp1_r, 0.25)
    float r2 = math.max(i_tp2_r, r1 + 0.25)
    float r3 = math.max(i_tp3_r, r2 + 0.25)
    float tp1Risk = entry + dir * risk * r1
    float tp2Risk = entry + dir * risk * r2
    float tp3Risk = entry + dir * risk * r3
    float tp1 = i_target_model == "Risk Multiple" ? tp1Risk : tp1Struct
    float tp2 = i_target_model == "Risk Multiple" ? tp2Risk : tp2Struct
    float tp3 = i_target_model == "Risk Multiple" ? tp3Risk : tp3Struct
    float minStep = syminfo.mintick * 4.0
    tp1 := bull ? math.max(tp1, entry + minStep) : math.min(tp1, entry - minStep)
    tp2 := bull ? math.max(tp2, tp1 + minStep) : math.min(tp2, tp1 - minStep)
    tp3 := bull ? math.max(tp3, tp2 + minStep) : math.min(tp3, tp2 - minStep)
    [przLo, przHi, entry, stop, tp1, tp2, tp3, tightScore]

f_d_near_prz(float dPrice, float lo, float hi, float atrVal) =>
    float dist = dPrice < lo ? lo - dPrice : dPrice > hi ? dPrice - hi : 0.0
    dist <= atrVal * i_d_prz_max_atr

f_add_match(array<Match> ms, string nm, bool bull, Pivot x, Pivot a, Pivot b, Pivot c, Pivot d, float r1, float r2, float r3, float r4, float score, float przLo, float przHi, float entry, float stop, float tp1, float tp2, float tp3) =>
    array.push(ms, Match.new(nm, bull, x, a, b, c, d, r1, r2, r3, r4, score, przLo, przHi, entry, stop, tp1, tp2, tp3))
    true

f_pick_top(array<Match> src, int want) =>
    array<Match> out = array.new<Match>()
    array<Match> tmp = array.new<Match>()
    int srcSz = array.size(src)
    if srcSz > 0
        for i = 0 to srcSz - 1
            array.push(tmp, array.get(src, i))
    int nWant = math.min(math.max(want, 0), array.size(tmp))
    if nWant > 0
        for n = 0 to nWant - 1
            int tsz = array.size(tmp)
            if tsz > 0
                int bestIdx = 0
                float bestScore = array.get(tmp, 0).score
                if tsz > 1
                    for j = 1 to tsz - 1
                        float sc = array.get(tmp, j).score
                        if sc > bestScore
                            bestScore := sc
                            bestIdx := j
                array.push(out, array.get(tmp, bestIdx))
                array.remove(tmp, bestIdx)
    out

f_line_delete(line id) =>
    if not na(id)
        line.delete(id)
    true

f_label_delete(label id) =>
    if not na(id)
        label.delete(id)
    true

f_box_delete(box id) =>
    if not na(id)
        box.delete(id)
    true

f_delete_pack(DrawPack p) =>
    f_line_delete(p.l1)
    f_line_delete(p.l2)
    f_line_delete(p.l3)
    f_line_delete(p.l4)
    f_line_delete(p.l5)
    f_line_delete(p.l6)
    f_line_delete(p.l7)
    f_line_delete(p.lEntry)
    f_line_delete(p.lStop)
    f_line_delete(p.lTp1)
    f_line_delete(p.lTp2)
    f_line_delete(p.lTp3)
    f_label_delete(p.mainLbl)
    f_label_delete(p.ratLbl1)
    f_label_delete(p.ratLbl2)
    f_label_delete(p.entryLbl)
    f_label_delete(p.stopLbl)
    f_label_delete(p.tp1Lbl)
    f_label_delete(p.tp2Lbl)
    f_label_delete(p.tp3Lbl)
    f_box_delete(p.przBox)
    f_box_delete(p.riskBox)
    f_box_delete(p.tp1Box)
    f_box_delete(p.tp2Box)
    f_box_delete(p.tp3Box)
    true

f_delete_prz_layer(DrawPack p) =>
    f_box_delete(p.przBox)
    true

f_delete_rm_layer(DrawPack p) =>
    f_line_delete(p.lEntry)
    f_line_delete(p.lStop)
    f_line_delete(p.lTp1)
    f_line_delete(p.lTp2)
    f_line_delete(p.lTp3)
    f_label_delete(p.entryLbl)
    f_label_delete(p.stopLbl)
    f_label_delete(p.tp1Lbl)
    f_label_delete(p.tp2Lbl)
    f_label_delete(p.tp3Lbl)
    f_box_delete(p.riskBox)
    true

f_delete_tp_zone_layer(DrawPack p) =>
    f_box_delete(p.tp1Box)
    f_box_delete(p.tp2Box)
    f_box_delete(p.tp3Box)
    true

f_apply_layer_limits() =>
    int sz = array.size(packs)
    int przCount = 0
    int rmCount = 0
    int tpCount = 0
    if sz > 0
        for k = 0 to sz - 1
            int idx = sz - 1 - k
            DrawPack dp = array.get(packs, idx)
            bool przVisible = array.get(packPrzVisible, idx)
            bool rmVisible = array.get(packRmVisible, idx)
            bool tpVisible = array.get(packTpVisible, idx)
            if przVisible
                if przCount < i_max_active_prz
                    przCount += 1
                else
                    f_delete_prz_layer(dp)
                    array.set(packPrzVisible, idx, false)
            if rmVisible
                if rmCount < i_max_active_rm
                    rmCount += 1
                else
                    f_delete_rm_layer(dp)
                    f_delete_tp_zone_layer(dp)
                    array.set(packRmVisible, idx, false)
                    array.set(packTpVisible, idx, false)
                    tpVisible := false
            if tpVisible
                if tpCount < i_max_active_tp_zones
                    tpCount += 1
                else
                    f_delete_tp_zone_layer(dp)
                    array.set(packTpVisible, idx, false)
    true

f_draw_match(Match m) =>
    color base = m.bull ? i_col_bull : i_col_bear
    color pathCol = color.new(base, 8)
    color connCol = color.new(base, 58)
    color przFill = color.new(base, 91)
    color przBorder = color.new(base, 38)
    color riskCol = color.new(color.rgb(120, 126, 134), 40)
    color stopCol = color.new(color.rgb(148, 105, 105), 10)
    color tpCol = color.new(color.rgb(96, 125, 116), 12)
    int rx = math.min(bar_index + i_level_right, bar_index + 500)
    int rmX1 = i_entry_model == "Signal Close" ? bar_index : m.d.idx
    line l1 = na
    line l2 = na
    line l3 = na
    line l4 = na
    line l5 = na
    line l6 = na
    line l7 = na
    line lEntry = na
    line lStop = na
    line lTp1 = na
    line lTp2 = na
    line lTp3 = na
    label mainLbl = na
    label ratLbl1 = na
    label ratLbl2 = na
    label entryLbl = na
    label stopLbl = na
    label tp1Lbl = na
    label tp2Lbl = na
    label tp3Lbl = na
    box przBox = na
    box riskBox = na
    box tp1Box = na
    box tp2Box = na
    box tp3Box = na
    if i_show_path
        l1 := line.new(m.x.idx, m.x.price, m.a.idx, m.a.price, xloc=xloc.bar_index, color=pathCol, width=1)
        l2 := line.new(m.a.idx, m.a.price, m.b.idx, m.b.price, xloc=xloc.bar_index, color=pathCol, width=1)
        l3 := line.new(m.b.idx, m.b.price, m.c.idx, m.c.price, xloc=xloc.bar_index, color=pathCol, width=1)
        l4 := line.new(m.c.idx, m.c.price, m.d.idx, m.d.price, xloc=xloc.bar_index, color=pathCol, width=2)
    if i_show_connectors
        l5 := line.new(m.x.idx, m.x.price, m.b.idx, m.b.price, xloc=xloc.bar_index, color=connCol, width=1, style=line.style_dotted)
        l6 := line.new(m.a.idx, m.a.price, m.c.idx, m.c.price, xloc=xloc.bar_index, color=connCol, width=1, style=line.style_dotted)
        l7 := line.new(m.b.idx, m.b.price, m.d.idx, m.d.price, xloc=xloc.bar_index, color=connCol, width=1, style=line.style_dotted)
    if i_show_prz
        przBox := box.new(m.d.idx, m.przHi, rx, m.przLo, xloc=xloc.bar_index, border_color=przBorder, bgcolor=przFill, border_style=line.style_dotted)
    string sideTxt = m.bull ? "BULL" : "BEAR"
    string mainTxt = m.name + "\n" + sideTxt + " | " + str.tostring(math.round(m.score)) + "/100"
    mainLbl := label.new(m.d.idx, m.bull ? m.przLo : m.przHi, mainTxt, xloc=xloc.bar_index, style=m.bull ? label.style_label_up : label.style_label_down, color=color.new(base, 8), textcolor=i_col_text, size=size.tiny)
    if i_show_ratios
        int mid1 = int(math.round((m.x.idx + m.b.idx) * 0.5))
        int mid2 = int(math.round((m.b.idx + m.d.idx) * 0.5))
        string ratioTxt1 = f_join_lines(f_ratio_line("XB", m.r1), f_ratio_line("BC", m.r2))
        string ratioTxt2 = f_join_lines(f_ratio_line("CD", m.r3), f_ratio_line("XD", m.r4))
        if ratioTxt1 != ""
            ratLbl1 := label.new(mid1, (m.x.price + m.b.price) * 0.5, ratioTxt1, xloc=xloc.bar_index, style=label.style_none, color=color.new(color.black, 100), textcolor=color.new(i_col_text, 15), size=size.tiny)
        if ratioTxt2 != ""
            ratLbl2 := label.new(mid2, (m.b.price + m.d.price) * 0.5, ratioTxt2, xloc=xloc.bar_index, style=label.style_none, color=color.new(color.black, 100), textcolor=color.new(i_col_text, 15), size=size.tiny)
    if i_show_risk
        lEntry := line.new(rmX1, m.entry, rx, m.entry, xloc=xloc.bar_index, color=riskCol, width=1)
        lStop := line.new(rmX1, m.stop, rx, m.stop, xloc=xloc.bar_index, color=stopCol, width=1, style=line.style_dashed)
        lTp1 := line.new(rmX1, m.tp1, rx, m.tp1, xloc=xloc.bar_index, color=tpCol, width=1)
        lTp2 := line.new(rmX1, m.tp2, rx, m.tp2, xloc=xloc.bar_index, color=tpCol, width=1)
        lTp3 := line.new(rmX1, m.tp3, rx, m.tp3, xloc=xloc.bar_index, color=tpCol, width=1, style=line.style_dotted)
        entryLbl := label.new(rx, m.entry, "ENTRY " + f_fmt_price(m.entry), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.rgb(80, 84, 92), 12), textcolor=i_col_text, size=size.tiny)
        stopLbl := label.new(rx, m.stop, "SL " + f_fmt_price(m.stop), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.rgb(120, 78, 78), 8), textcolor=i_col_text, size=size.tiny)
        tp1Lbl := label.new(rx, m.tp1, "TP1 " + f_fmt_price(m.tp1), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.rgb(67, 101, 91), 8), textcolor=i_col_text, size=size.tiny)
        tp2Lbl := label.new(rx, m.tp2, "TP2 " + f_fmt_price(m.tp2), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.rgb(67, 101, 91), 8), textcolor=i_col_text, size=size.tiny)
        tp3Lbl := label.new(rx, m.tp3, "TP3 " + f_fmt_price(m.tp3), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.rgb(67, 101, 91), 8), textcolor=i_col_text, size=size.tiny)
        if i_show_target_zones
            float slTop = m.bull ? m.entry : m.stop
            float slBot = m.bull ? m.stop : m.entry
            riskBox := box.new(rmX1, slTop, rx, slBot, xloc=xloc.bar_index, border_color=color.new(color.rgb(135, 92, 92), 78), bgcolor=color.new(color.rgb(135, 92, 92), 92))
            float t1Top = m.bull ? m.tp1 : m.entry
            float t1Bot = m.bull ? m.entry : m.tp1
            float t2Top = m.bull ? m.tp2 : m.tp1
            float t2Bot = m.bull ? m.tp1 : m.tp2
            float t3Top = m.bull ? m.tp3 : m.tp2
            float t3Bot = m.bull ? m.tp2 : m.tp3
            tp1Box := box.new(rmX1, t1Top, rx, t1Bot, xloc=xloc.bar_index, border_color=color.new(color.rgb(76, 120, 102), 82), bgcolor=color.new(color.rgb(76, 120, 102), 93))
            tp2Box := box.new(rmX1, t2Top, rx, t2Bot, xloc=xloc.bar_index, border_color=color.new(color.rgb(76, 120, 102), 86), bgcolor=color.new(color.rgb(76, 120, 102), 95))
            tp3Box := box.new(rmX1, t3Top, rx, t3Bot, xloc=xloc.bar_index, border_color=color.new(color.rgb(76, 120, 102), 88), bgcolor=color.new(color.rgb(76, 120, 102), 96))
    DrawPack.new(l1, l2, l3, l4, l5, l6, l7, lEntry, lStop, lTp1, lTp2, lTp3, mainLbl, ratLbl1, ratLbl2, entryLbl, stopLbl, tp1Lbl, tp2Lbl, tp3Lbl, przBox, riskBox, tp1Box, tp2Box, tp3Box)

//──────────────────────────────────────────────────────────────────────────────
// CONTEXT DATA
//──────────────────────────────────────────────────────────────────────────────
float atr = ta.atr(14)
float rsi = ta.rsi(close, i_rsi_len)
float volMa = ta.sma(volume, i_vol_len)
bool volExp = volume > volMa * i_vol_mult
bool candleBull = close > open and close > (high + low) * 0.5
bool candleBear = close < open and close < (high + low) * 0.5
bool rsiBull = rsi > rsi[1] and rsi > 38
bool rsiBear = rsi < rsi[1] and rsi < 62
float atrRegimeMa = ta.sma(atr, i_atr_regime_len)
bool atrRegimeOk = not i_use_atr_regime or atr >= atrRegimeMa * 0.85
float vwapVal = ta.vwap(hlc3)
bool vwapBull = close >= vwapVal
bool vwapBear = close <= vwapVal
float htfClose = request.security(syminfo.tickerid, i_htf_tf, close[1], lookahead=barmerge.lookahead_on)
float htfEma = request.security(syminfo.tickerid, i_htf_tf, ta.ema(close, i_htf_ema_len)[1], lookahead=barmerge.lookahead_on)
bool htfBull = htfClose > htfEma
bool htfBear = htfClose < htfEma

f_context_score(bool bull) =>
    float sc = 50.0
    if i_use_candle
        sc += bull ? (candleBull ? 14.0 : -6.0) : (candleBear ? 14.0 : -6.0)
    if i_use_rsi
        sc += bull ? (rsiBull ? 12.0 : -4.0) : (rsiBear ? 12.0 : -4.0)
    if i_use_volume
        sc += volExp ? 10.0 : -3.0
    if i_use_htf
        sc += bull ? (htfBull ? 10.0 : -8.0) : (htfBear ? 10.0 : -8.0)
    if i_use_vwap
        sc += bull ? (vwapBull ? 6.0 : -4.0) : (vwapBear ? 6.0 : -4.0)
    if i_use_atr_regime
        sc += atrRegimeOk ? 5.0 : -5.0
    f_clamp(sc, 0.0, 100.0)

f_htf_pass(bool bull) =>
    not i_require_htf or not i_use_htf or (bull ? htfBull : htfBear)

//──────────────────────────────────────────────────────────────────────────────
// PIVOT ENGINE
//──────────────────────────────────────────────────────────────────────────────
float ph = ta.pivothigh(high, i_depth, i_depth)
float pl = ta.pivotlow(low, i_depth, i_depth)
bool pivotChanged = false
if not na(ph)
    pivotChanged := f_add_pivot(pivots, true, ph, bar_index - i_depth, atr * i_min_swing_atr) or pivotChanged
if not na(pl)
    pivotChanged := f_add_pivot(pivots, false, pl, bar_index - i_depth, atr * i_min_swing_atr) or pivotChanged

//──────────────────────────────────────────────────────────────────────────────
// EVENT STATE
//──────────────────────────────────────────────────────────────────────────────
bool evNew = false
bool evBull = false
bool evBear = false
bool evHighScore = false
bool evTouched = false
bool evReaction = false
bool evFailed = false
bool evTP1 = false
bool evTP2 = false
bool evTP3 = false
string lastAlertStatus = ""

//──────────────────────────────────────────────────────────────────────────────
// DETECTION
//──────────────────────────────────────────────────────────────────────────────
if pivotChanged and array.size(pivots) >= 5 and barstate.isconfirmed
    int sz = array.size(pivots)
    Pivot d = array.get(pivots, sz - 1)
    Pivot c = array.get(pivots, sz - 2)
    Pivot b = array.get(pivots, sz - 3)
    Pivot a = array.get(pivots, sz - 4)
    Pivot x = array.get(pivots, sz - 5)
    bool ageOk = bar_index - x.idx <= i_max_pattern_age and bar_index - x.idx <= 9000
    bool harmBull = not x.isHigh and a.isHigh and not b.isHigh and c.isHigh and not d.isHigh
    bool harmBear = x.isHigh and not a.isHigh and b.isHigh and not c.isHigh and d.isHigh
    bool harmOk = ageOk and (harmBull or harmBear)
    bool bull = harmBull
    float xa = math.abs(a.price - x.price)
    float ab = math.abs(b.price - a.price)
    float bc = math.abs(c.price - b.price)
    float cd = math.abs(d.price - c.price)
    float xc = math.abs(c.price - x.price)
    float rXB = ab / math.max(xa, syminfo.mintick)
    float rBC = bc / math.max(ab, syminfo.mintick)
    float rCD = cd / math.max(bc, syminfo.mintick)
    float rXD = math.abs(d.price - x.price) / math.max(xa, syminfo.mintick)
    float rXC = xc / math.max(xa, syminfo.mintick)
    float rDxc = math.abs(c.price - d.price) / math.max(xc, syminfo.mintick)
    float rABCD = cd / math.max(ab, syminfo.mintick)
    bool sizeOk = xa >= atr * i_min_xa_atr
    bool retDir = bull ? d.price > x.price and d.price < a.price : d.price < x.price and d.price > a.price
    bool extDir = bull ? d.price < x.price : d.price > x.price
    array<Match> matches = array.new<Match>()
    if harmOk and sizeOk
        float contextBullBear = f_context_score(bull)
        float symScore = f_sym_score(a.idx, b.idx, c.idx, d.idx)
        if en_gartley and retDir and f_in_target(rXB, 0.618, tol) and f_in_range(rBC, 0.382, 0.886) and f_in_range(rCD, 1.13, 1.618) and f_in_target(rXD, 0.786, tol) and f_htf_pass(bull)
            float lv1 = f_xad_level(x, a, bull, 0.786, false)
            float lv2 = f_bc_level(b, c, bull, 1.272)
            float lv3 = f_abcd_level(a, b, c, bull, 1.0)
            [przLo, przHi, entry, stop, tp1, tp2, tp3, tightScore] = f_build_prz(lv1, lv2, lv3, c, d, bull, atr, xa)
            bool przOk = (not i_require_prz or f_d_near_prz(d.price, przLo, przHi, atr)) and tightScore >= i_min_prz_score
            float ratioScore = (f_target_score(rXB, 0.618, tol) + f_range_score(rBC, 0.382, 0.886) + f_range_score(rCD, 1.13, 1.618) + f_target_score(rXD, 0.786, tol)) * 0.25
            float score = ratioScore * 0.62 + tightScore * 0.22 + symScore * 0.08 + contextBullBear * 0.08
            if przOk and score >= i_min_conf
                f_add_match(matches, "Gartley", bull, x, a, b, c, d, rXB, rBC, rCD, rXD, score, przLo, przHi, entry, stop, tp1, tp2, tp3)
        if en_bat and retDir and f_in_range(rXB, 0.382, 0.500) and f_in_range(rBC, 0.382, 0.886) and f_in_range(rCD, 1.618, 2.618) and f_in_target(rXD, 0.886, tol) and f_htf_pass(bull)
            float lv1 = f_xad_level(x, a, bull, 0.886, false)
            float lv2 = f_bc_level(b, c, bull, 2.000)
            float lv3 = f_abcd_level(a, b, c, bull, 1.272)
            [przLo, przHi, entry, stop, tp1, tp2, tp3, tightScore] = f_build_prz(lv1, lv2, lv3, c, d, bull, atr, xa)
            bool przOk = (not i_require_prz or f_d_near_prz(d.price, przLo, przHi, atr)) and tightScore >= i_min_prz_score
            float ratioScore = (f_range_score(rXB, 0.382, 0.500) + f_range_score(rBC, 0.382, 0.886) + f_range_score(rCD, 1.618, 2.618) + f_target_score(rXD, 0.886, tol)) * 0.25
            float score = ratioScore * 0.62 + tightScore * 0.22 + symScore * 0.08 + contextBullBear * 0.08
            if przOk and score >= i_min_conf
                f_add_match(matches, "Bat", bull, x, a, b, c, d, rXB, rBC, rCD, rXD, score, przLo, przHi, entry, stop, tp1, tp2, tp3)
        if en_altbat and extDir and f_in_range(rXB, 0.382, 0.500) and f_in_range(rBC, 0.382, 0.886) and f_in_range(rCD, 2.000, 3.618) and f_in_target(rXD, 1.130, tol) and f_htf_pass(bull)
            float lv1 = f_xad_level(x, a, bull, 1.130, true)
            float lv2 = f_bc_level(b, c, bull, 2.618)
            float lv3 = f_abcd_level(a, b, c, bull, 1.618)
            [przLo, przHi, entry, stop, tp1, tp2, tp3, tightScore] = f_build_prz(lv1, lv2, lv3, c, d, bull, atr, xa)
            bool przOk = (not i_require_prz or f_d_near_prz(d.price, przLo, przHi, atr)) and tightScore >= i_min_prz_score
            float ratioScore = (f_range_score(rXB, 0.382, 0.500) + f_range_score(rBC, 0.382, 0.886) + f_range_score(rCD, 2.000, 3.618) + f_target_score(rXD, 1.130, tol)) * 0.25
            float score = ratioScore * 0.62 + tightScore * 0.22 + symScore * 0.08 + contextBullBear * 0.08
            if przOk and score >= i_min_conf
                f_add_match(matches, "Alternate Bat", bull, x, a, b, c, d, rXB, rBC, rCD, rXD, score, przLo, przHi, entry, stop, tp1, tp2, tp3)
        if en_butterfly and extDir and f_in_target(rXB, 0.786, tol) and f_in_range(rBC, 0.382, 0.886) and f_in_range(rCD, 1.618, 2.240) and f_in_range(rXD, 1.270, 1.618) and f_htf_pass(bull)
            float lv1 = f_xad_level(x, a, bull, 1.272, true)
            float lv2 = f_bc_level(b, c, bull, 1.618)
            float lv3 = f_abcd_level(a, b, c, bull, 1.272)
            [przLo, przHi, entry, stop, tp1, tp2, tp3, tightScore] = f_build_prz(lv1, lv2, lv3, c, d, bull, atr, xa)
            bool przOk = (not i_require_prz or f_d_near_prz(d.price, przLo, przHi, atr)) and tightScore >= i_min_prz_score
            float ratioScore = (f_target_score(rXB, 0.786, tol) + f_range_score(rBC, 0.382, 0.886) + f_range_score(rCD, 1.618, 2.240) + f_range_score(rXD, 1.270, 1.618)) * 0.25
            float score = ratioScore * 0.62 + tightScore * 0.22 + symScore * 0.08 + contextBullBear * 0.08
            if przOk and score >= i_min_conf
                f_add_match(matches, "Butterfly", bull, x, a, b, c, d, rXB, rBC, rCD, rXD, score, przLo, przHi, entry, stop, tp1, tp2, tp3)
        if en_crab and extDir and f_in_range(rXB, 0.382, 0.618) and f_in_range(rBC, 0.382, 0.886) and f_in_range(rCD, 2.240, 3.618) and f_in_target(rXD, 1.618, tol) and f_htf_pass(bull)
            float lv1 = f_xad_level(x, a, bull, 1.618, true)
            float lv2 = f_bc_level(b, c, bull, 3.140)
            float lv3 = f_abcd_level(a, b, c, bull, 1.618)
            [przLo, przHi, entry, stop, tp1, tp2, tp3, tightScore] = f_build_prz(lv1, lv2, lv3, c, d, bull, atr, xa)
            bool przOk = (not i_require_prz or f_d_near_prz(d.price, przLo, przHi, atr)) and tightScore >= i_min_prz_score
            float ratioScore = (f_range_score(rXB, 0.382, 0.618) + f_range_score(rBC, 0.382, 0.886) + f_range_score(rCD, 2.240, 3.618) + f_target_score(rXD, 1.618, tol)) * 0.25
            float score = ratioScore * 0.62 + tightScore * 0.22 + symScore * 0.08 + contextBullBear * 0.08
            if przOk and score >= i_min_conf
                f_add_match(matches, "Crab", bull, x, a, b, c, d, rXB, rBC, rCD, rXD, score, przLo, przHi, entry, stop, tp1, tp2, tp3)
        if en_deepcrab and extDir and f_in_target(rXB, 0.886, tol) and f_in_range(rBC, 0.382, 0.886) and f_in_range(rCD, 2.240, 3.618) and f_in_target(rXD, 1.618, tol) and f_htf_pass(bull)
            float lv1 = f_xad_level(x, a, bull, 1.618, true)
            float lv2 = f_bc_level(b, c, bull, 2.618)
            float lv3 = f_abcd_level(a, b, c, bull, 1.618)
            [przLo, przHi, entry, stop, tp1, tp2, tp3, tightScore] = f_build_prz(lv1, lv2, lv3, c, d, bull, atr, xa)
            bool przOk = (not i_require_prz or f_d_near_prz(d.price, przLo, przHi, atr)) and tightScore >= i_min_prz_score
            float ratioScore = (f_target_score(rXB, 0.886, tol) + f_range_score(rBC, 0.382, 0.886) + f_range_score(rCD, 2.240, 3.618) + f_target_score(rXD, 1.618, tol)) * 0.25
            float score = ratioScore * 0.62 + tightScore * 0.22 + symScore * 0.08 + contextBullBear * 0.08
            if przOk and score >= i_min_conf
                f_add_match(matches, "Deep Crab", bull, x, a, b, c, d, rXB, rBC, rCD, rXD, score, przLo, przHi, entry, stop, tp1, tp2, tp3)
        bool cypherDir = bull ? d.price > x.price and d.price < c.price : d.price < x.price and d.price > c.price
        if en_cypher and cypherDir and f_in_range(rXB, 0.382, 0.618) and f_in_range(rXC, 1.272, 1.414) and f_in_target(rDxc, 0.786, tol) and f_htf_pass(bull)
            float lv1 = f_xc_retr_level(x, c, bull, 0.786)
            float lv2 = f_abcd_level(a, b, c, bull, 1.272)
            float lv3 = f_bc_level(b, c, bull, 1.272)
            [przLo, przHi, entry, stop, tp1, tp2, tp3, tightScore] = f_build_prz(lv1, lv2, lv3, c, d, bull, atr, xa)
            bool przOk = (not i_require_prz or f_d_near_prz(d.price, przLo, przHi, atr)) and tightScore >= i_min_prz_score
            float ratioScore = (f_range_score(rXB, 0.382, 0.618) + f_range_score(rXC, 1.272, 1.414) + f_target_score(rDxc, 0.786, tol) + f_range_score(rBC, 0.382, 0.886)) * 0.25
            float score = ratioScore * 0.62 + tightScore * 0.22 + symScore * 0.08 + contextBullBear * 0.08
            if przOk and score >= i_min_conf
                f_add_match(matches, "Cypher", bull, x, a, b, c, d, rXB, rXC, rDxc, rXD, score, przLo, przHi, entry, stop, tp1, tp2, tp3)
        if en_fiveo and f_in_range(rXB, 1.130, 1.618) and f_in_range(rBC, 1.618, 2.240) and f_in_target(rCD, 0.500, tol) and f_htf_pass(bull)
            float lv1 = f_bc_level(b, c, bull, 0.500)
            float lv2 = f_abcd_level(a, b, c, bull, 0.618)
            float lv3 = f_abcd_level(a, b, c, bull, 0.500)
            [przLo, przHi, entry, stop, tp1, tp2, tp3, tightScore] = f_build_prz(lv1, lv2, lv3, c, d, bull, atr, xa)
            bool przOk = (not i_require_prz or f_d_near_prz(d.price, przLo, przHi, atr)) and tightScore >= i_min_prz_score
            float ratioScore = (f_range_score(rXB, 1.130, 1.618) + f_range_score(rBC, 1.618, 2.240) + f_target_score(rCD, 0.500, tol) + symScore) * 0.25
            float score = ratioScore * 0.62 + tightScore * 0.22 + symScore * 0.08 + contextBullBear * 0.08
            if przOk and score >= i_min_conf
                f_add_match(matches, "5-0", bull, x, a, b, c, d, rXB, rBC, rCD, rXD, score, przLo, przHi, entry, stop, tp1, tp2, tp3)
        if en_abcd and f_in_range(rBC, 0.382, 0.886) and f_htf_pass(bull)
            float abcdTol = f_clamp(tol * 0.75, 0.02, 0.10)
            if f_in_target(rABCD, 1.000, abcdTol)
                float lv1 = f_abcd_level(a, b, c, bull, 1.000)
                float lv2 = f_bc_level(b, c, bull, 1.272)
                float lv3 = f_bc_level(b, c, bull, 1.618)
                [przLo, przHi, entry, stop, tp1, tp2, tp3, tightScore] = f_build_prz(lv1, lv2, lv3, c, d, bull, atr, xa)
                bool przOk = not i_require_prz or f_d_near_prz(d.price, przLo, przHi, atr)
                float ratioScore = (f_target_score(rABCD, 1.000, abcdTol) + f_range_score(rBC, 0.382, 0.886) + symScore) / 3.0
                float score = ratioScore * 0.66 + tightScore * 0.18 + symScore * 0.08 + contextBullBear * 0.08
                if przOk and score >= i_min_conf
                    f_add_match(matches, "AB=CD 1.0", bull, x, a, b, c, d, rABCD, rBC, rCD, rXD, score, przLo, przHi, entry, stop, tp1, tp2, tp3)
            if f_in_target(rABCD, 1.272, abcdTol)
                float lv1 = f_abcd_level(a, b, c, bull, 1.272)
                float lv2 = f_bc_level(b, c, bull, 1.618)
                float lv3 = f_xad_level(x, a, bull, rXD, retDir ? false : true)
                [przLo, przHi, entry, stop, tp1, tp2, tp3, tightScore] = f_build_prz(lv1, lv2, lv3, c, d, bull, atr, xa)
                bool przOk = not i_require_prz or f_d_near_prz(d.price, przLo, przHi, atr)
                float ratioScore = (f_target_score(rABCD, 1.272, abcdTol) + f_range_score(rBC, 0.382, 0.886) + symScore) / 3.0
                float score = ratioScore * 0.66 + tightScore * 0.18 + symScore * 0.08 + contextBullBear * 0.08
                if przOk and score >= i_min_conf
                    f_add_match(matches, "AB=CD 1.272", bull, x, a, b, c, d, rABCD, rBC, rCD, rXD, score, przLo, przHi, entry, stop, tp1, tp2, tp3)
            if f_in_target(rABCD, 1.618, abcdTol)
                float lv1 = f_abcd_level(a, b, c, bull, 1.618)
                float lv2 = f_bc_level(b, c, bull, 2.000)
                float lv3 = f_xad_level(x, a, bull, rXD, retDir ? false : true)
                [przLo, przHi, entry, stop, tp1, tp2, tp3, tightScore] = f_build_prz(lv1, lv2, lv3, c, d, bull, atr, xa)
                bool przOk = not i_require_prz or f_d_near_prz(d.price, przLo, przHi, atr)
                float ratioScore = (f_target_score(rABCD, 1.618, abcdTol) + f_range_score(rBC, 0.382, 0.886) + symScore) / 3.0
                float score = ratioScore * 0.66 + tightScore * 0.18 + symScore * 0.08 + contextBullBear * 0.08
                if przOk and score >= i_min_conf
                    f_add_match(matches, "AB=CD 1.618", bull, x, a, b, c, d, rABCD, rBC, rCD, rXD, score, przLo, przHi, entry, stop, tp1, tp2, tp3)
    if en_three and ageOk and array.size(pivots) >= 6
        Pivot p0 = array.get(pivots, sz - 6)
        bool tdBull = not p0.isHigh and a.isHigh and not b.isHigh and c.isHigh and not d.isHigh
        bool tdBear = p0.isHigh and not a.isHigh and b.isHigh and not c.isHigh and d.isHigh
        bool tdOk = tdBull or tdBear
        if tdOk
            bool tdBullSide = tdBull
            float d1 = math.abs(a.price - p0.price)
            float d2 = math.abs(c.price - b.price)
            float d3 = math.abs(d.price - c.price)
            float rr12 = d2 / math.max(d1, syminfo.mintick)
            float rr23 = d3 / math.max(d2, syminfo.mintick)
            float retr1 = math.abs(b.price - a.price) / math.max(d1, syminfo.mintick)
            float retr2 = math.abs(d.price - c.price) / math.max(d2, syminfo.mintick)
            bool tdPass = f_in_target(rr12, 1.000, 0.25) and f_in_target(rr23, 1.000, 0.25) and f_in_range(retr1, 0.500, 0.886) and f_in_range(retr2, 0.500, 0.886) and d1 >= atr * i_min_xa_atr and f_htf_pass(tdBullSide)
            if tdPass
                float lv1 = d.price
                float lv2 = tdBullSide ? d.price - atr * 0.10 : d.price + atr * 0.10
                float lv3 = tdBullSide ? d.price + atr * 0.10 : d.price - atr * 0.10
                [przLo, przHi, entry, stop, tp1, tp2, tp3, tightScore] = f_build_prz(lv1, lv2, lv3, c, d, tdBullSide, atr, math.max(d1, syminfo.mintick))
                float ratioScore = (f_target_score(rr12, 1.000, 0.25) + f_target_score(rr23, 1.000, 0.25) + f_range_score(retr1, 0.500, 0.886) + f_range_score(retr2, 0.500, 0.886)) * 0.25
                float score = ratioScore * 0.68 + tightScore * 0.12 + f_context_score(tdBullSide) * 0.12 + f_sym_score(p0.idx, a.idx, b.idx, c.idx) * 0.08
                if score >= i_min_conf
                    f_add_match(matches, "Three Drives", tdBullSide, x, a, b, c, d, rr12, rr23, retr1, retr2, score, przLo, przHi, entry, stop, tp1, tp2, tp3)
    if ageOk and array.size(matches) < i_max_per_pivot + 6
        float topTol = f_clamp(tol * 1.35, 0.025, 0.140)
        if en_double and sz >= 3
            Pivot p2 = array.get(pivots, sz - 3)
            Pivot p1 = array.get(pivots, sz - 2)
            Pivot p00 = array.get(pivots, sz - 1)
            bool dt = p2.isHigh and not p1.isHigh and p00.isHigh
            bool db = not p2.isHigh and p1.isHigh and not p00.isHigh
            if dt or db
                bool sideBull = db
                float basePrice = math.max(math.abs(p2.price), syminfo.mintick)
                float rel = math.abs(p2.price - p00.price) / basePrice
                float depthMove = math.abs(p2.price - p1.price)
                if rel <= topTol and depthMove >= atr * 0.50 and f_htf_pass(sideBull)
                    float lv1 = p00.price
                    float lv2 = p00.price + atr * 0.12
                    float lv3 = p00.price - atr * 0.12
                    [przLo, przHi, entry, stop, tp1, tp2, tp3, tightScore] = f_build_prz(lv1, lv2, lv3, c, d, sideBull, atr, depthMove)
                    float score = f_clamp(92.0 - rel / topTol * 32.0 + f_context_score(sideBull) * 0.08, 0.0, 100.0)
                    if score >= i_min_conf
                        f_add_match(matches, sideBull ? "Double Bottom" : "Double Top", sideBull, x, a, b, c, d, rel, depthMove / atr, na, na, score, przLo, przHi, entry, stop, tp1, tp2, tp3)
        if en_triple and sz >= 5
            Pivot q4 = array.get(pivots, sz - 5)
            Pivot q3 = array.get(pivots, sz - 4)
            Pivot q2 = array.get(pivots, sz - 3)
            Pivot q1 = array.get(pivots, sz - 2)
            Pivot q0 = array.get(pivots, sz - 1)
            bool tt = q4.isHigh and not q3.isHigh and q2.isHigh and not q1.isHigh and q0.isHigh
            bool tb = not q4.isHigh and q3.isHigh and not q2.isHigh and q1.isHigh and not q0.isHigh
            if tt or tb
                bool sideBull = tb
                float hMax = math.max(q4.price, math.max(q2.price, q0.price))
                float hMin = math.min(q4.price, math.min(q2.price, q0.price))
                float rel = (hMax - hMin) / math.max(math.abs(hMax), syminfo.mintick)
                float depthMove = math.abs(q4.price - q3.price)
                if rel <= topTol and depthMove >= atr * 0.50 and f_htf_pass(sideBull)
                    float lv1 = q0.price
                    float lv2 = q0.price + atr * 0.14
                    float lv3 = q0.price - atr * 0.14
                    [przLo, przHi, entry, stop, tp1, tp2, tp3, tightScore] = f_build_prz(lv1, lv2, lv3, c, d, sideBull, atr, depthMove)
                    float score = f_clamp(94.0 - rel / topTol * 35.0 + f_context_score(sideBull) * 0.08, 0.0, 100.0)
                    if score >= i_min_conf
                        f_add_match(matches, sideBull ? "Triple Bottom" : "Triple Top", sideBull, x, a, b, c, d, rel, depthMove / atr, na, na, score, przLo, przHi, entry, stop, tp1, tp2, tp3)
        if en_hs and sz >= 7
            Pivot s6 = array.get(pivots, sz - 7)
            Pivot s5 = array.get(pivots, sz - 6)
            Pivot s4 = array.get(pivots, sz - 5)
            Pivot s3 = array.get(pivots, sz - 4)
            Pivot s2 = array.get(pivots, sz - 3)
            Pivot s1 = array.get(pivots, sz - 2)
            Pivot s0 = array.get(pivots, sz - 1)
            bool hsShape = s6.isHigh and not s5.isHigh and s4.isHigh and not s3.isHigh and s2.isHigh and not s1.isHigh
            bool ihsShape = not s6.isHigh and s5.isHigh and not s4.isHigh and s3.isHigh and not s2.isHigh and s1.isHigh
            if hsShape or ihsShape
                bool sideBull = ihsShape
                bool headOk = sideBull ? s4.price < s6.price and s4.price < s2.price : s4.price > s6.price and s4.price > s2.price
                float shoulderRel = math.abs(s6.price - s2.price) / math.max(math.abs(s6.price), syminfo.mintick)
                float neckRel = math.abs(s5.price - s3.price) / math.max(atr, syminfo.mintick)
                if headOk and shoulderRel <= topTol and neckRel <= 0.75 and f_htf_pass(sideBull)
                    float lv1 = s0.price
                    float lv2 = s0.price + atr * 0.18
                    float lv3 = s0.price - atr * 0.18
                    [przLo, przHi, entry, stop, tp1, tp2, tp3, tightScore] = f_build_prz(lv1, lv2, lv3, c, d, sideBull, atr, math.abs(s4.price - s3.price))
                    float score = f_clamp(90.0 - shoulderRel / topTol * 28.0 - neckRel * 5.0 + f_context_score(sideBull) * 0.08, 0.0, 100.0)
                    if score >= i_min_conf
                        f_add_match(matches, sideBull ? "Inverse H&S" : "Head & Shoulders", sideBull, x, a, b, c, d, shoulderRel, neckRel, na, na, score, przLo, przHi, entry, stop, tp1, tp2, tp3)
        if en_triangle and sz >= 6
            Pivot t5 = array.get(pivots, sz - 6)
            Pivot t4 = array.get(pivots, sz - 5)
            Pivot t3 = array.get(pivots, sz - 4)
            Pivot t2 = array.get(pivots, sz - 3)
            Pivot t1 = array.get(pivots, sz - 2)
            Pivot t0 = array.get(pivots, sz - 1)
            bool alt = t5.isHigh != t4.isHigh and t4.isHigh != t3.isHigh and t3.isHigh != t2.isHigh and t2.isHigh != t1.isHigh and t1.isHigh != t0.isHigh
            if alt
                float h1 = na
                float h2 = na
                float h3 = na
                float l1 = na
                float l2 = na
                float l3 = na
                if t5.isHigh
                    h1 := t5.price
                    l1 := t4.price
                    h2 := t3.price
                    l2 := t2.price
                    h3 := t1.price
                    l3 := t0.price
                else
                    l1 := t5.price
                    h1 := t4.price
                    l2 := t3.price
                    h2 := t2.price
                    l3 := t1.price
                    h3 := t0.price
                float range1 = h1 - l1
                float range3 = h3 - l3
                bool converging = range1 > 0 and range3 > 0 and range3 < range1 * 0.85
                bool lowerHighs = h3 < h2 and h2 < h1
                bool higherLows = l3 > l2 and l2 > l1
                bool fallingWedge = lowerHighs and l3 < l2 and l2 < l1 and converging
                bool risingWedge = h3 > h2 and h2 > h1 and higherLows and converging
                bool triangle = lowerHighs and higherLows and converging
                if triangle or fallingWedge or risingWedge
                    bool sideBull = triangle ? close > (h3 + l3) * 0.5 : fallingWedge
                    string nm = triangle ? "Triangle" : fallingWedge ? "Falling Wedge" : "Rising Wedge"
                    float lv1 = d.price
                    float lv2 = d.price + atr * 0.16
                    float lv3 = d.price - atr * 0.16
                    [przLo, przHi, entry, stop, tp1, tp2, tp3, tightScore] = f_build_prz(lv1, lv2, lv3, c, d, sideBull, atr, range1)
                    float compact = range3 / math.max(range1, syminfo.mintick)
                    float score = f_clamp(88.0 - compact * 25.0 + f_context_score(sideBull) * 0.08, 0.0, 100.0)
                    if score >= i_min_conf and f_htf_pass(sideBull)
                        f_add_match(matches, nm, sideBull, x, a, b, c, d, compact, range1 / atr, range3 / atr, na, score, przLo, przHi, entry, stop, tp1, tp2, tp3)
    if array.size(matches) > 0
        array<Match> picked = f_pick_top(matches, i_max_per_pivot)
        int pSz = array.size(picked)
        if pSz > 0
            for i = 0 to pSz - 1
                Match m = array.get(picked, i)
                string key = syminfo.tickerid + "|" + timeframe.period + "|" + str.tostring(m.d.idx) + "|" + m.name + "|" + (m.bull ? "B" : "S")
                bool already = f_key_exists(seenKeys, key)
                if not already
                    f_remember_key(seenKeys, key)
                    int initStatus = i_entry_model == "Pattern D" ? f_replay_status_from_d(m.bull, m.stop, m.tp1, m.tp2, m.tp3, m.d.idx) : 0
                    bool initTradable = initStatus >= 0 and initStatus < 3
                    bool priceNearEntry = i_max_entry_dist_atr <= 0.0 ? true : (math.abs(close - m.entry) <= atr * i_max_entry_dist_atr or f_price_in_zone(m.przLo, m.przHi))
                    bool rmActionable = i_entry_model == "Signal Close" ? true : ((not i_actionable_rm_only) or (initTradable and priceNearEntry))
                    DrawPack dp = f_draw_match(m)
                    if i_actionable_rm_only and not rmActionable
                        f_delete_rm_layer(dp)
                        f_delete_tp_zone_layer(dp)
                        dp.lEntry := na
                        dp.lStop := na
                        dp.lTp1 := na
                        dp.lTp2 := na
                        dp.lTp3 := na
                        dp.entryLbl := na
                        dp.stopLbl := na
                        dp.tp1Lbl := na
                        dp.tp2Lbl := na
                        dp.tp3Lbl := na
                        dp.riskBox := na
                        dp.tp1Box := na
                        dp.tp2Box := na
                        dp.tp3Box := na
                    array.push(packs, dp)
                    array.push(packNames, m.name)
                    array.push(packBulls, m.bull)
                    array.push(packScores, m.score)
                    array.push(packPrzLos, m.przLo)
                    array.push(packPrzHis, m.przHi)
                    array.push(packEntries, m.entry)
                    array.push(packStops, m.stop)
                    array.push(packTp1s, m.tp1)
                    array.push(packTp2s, m.tp2)
                    array.push(packTp3s, m.tp3)
                    array.push(packBars, bar_index)
                    array.push(packStatuses, initStatus)
                    array.push(packTouchedBars, int(na))
                    array.push(packPrzVisible, i_show_prz)
                    array.push(packRmVisible, i_show_risk and rmActionable)
                    array.push(packTpVisible, i_show_risk and i_show_target_zones and rmActionable)
                    f_apply_layer_limits()
                    while array.size(packs) > i_max_patterns
                        DrawPack old = array.shift(packs)
                        f_delete_pack(old)
                        array.shift(packNames)
                        array.shift(packBulls)
                        array.shift(packScores)
                        array.shift(packPrzLos)
                        array.shift(packPrzHis)
                        array.shift(packEntries)
                        array.shift(packStops)
                        array.shift(packTp1s)
                        array.shift(packTp2s)
                        array.shift(packTp3s)
                        array.shift(packBars)
                        array.shift(packStatuses)
                        array.shift(packTouchedBars)
                        array.shift(packPrzVisible)
                        array.shift(packRmVisible)
                        array.shift(packTpVisible)
                    f_apply_layer_limits()
                    totalPatterns += 1
                    lastName := m.name
                    lastSide := m.bull ? "Bull" : "Bear"
                    lastScore := m.score
                    lastPrzLo := m.przLo
                    lastPrzHi := m.przHi
                    lastEntry := m.entry
                    lastStop := m.stop
                    lastTp1 := m.tp1
                    lastTp2 := m.tp2
                    lastTp3 := m.tp3
                    lastRR1 := f_rr(m.entry, m.stop, m.tp1)
                    lastRR2 := f_rr(m.entry, m.stop, m.tp2)
                    lastRR3 := f_rr(m.entry, m.stop, m.tp3)
                    lastStatus := f_status_txt(initStatus)
                    lastPatternBar := bar_index
                    evNew := evNew or initTradable
                    lastAlertStatus := f_status_txt(initStatus)
                    evBull := evBull or (initTradable and m.bull)
                    evBear := evBear or (initTradable and not m.bull)
                    evHighScore := evHighScore or (initTradable and m.score >= 86.0)


//──────────────────────────────────────────────────────────────────────────────
// LIVE LIFECYCLE ENGINE
//──────────────────────────────────────────────────────────────────────────────
if i_lifecycle and array.size(packs) > 0 and barstate.isconfirmed
    int liveCount = array.size(packs)
    for i = 0 to liveCount - 1
        DrawPack dp = array.get(packs, i)
        string nm = array.get(packNames, i)
        bool bull = array.get(packBulls, i)
        float sc = array.get(packScores, i)
        float lo = array.get(packPrzLos, i)
        float hi = array.get(packPrzHis, i)
        float entry = array.get(packEntries, i)
        float stop = array.get(packStops, i)
        float t1 = array.get(packTp1s, i)
        float t2 = array.get(packTp2s, i)
        float t3 = array.get(packTp3s, i)
        int startBar = array.get(packBars, i)
        int st = array.get(packStatuses, i)
        int touchBar = array.get(packTouchedBars, i)
        bool terminal = st < 0 or st >= 5
        bool touched = f_price_in_zone(lo, hi)
        bool expired = bar_index - startBar > i_expire_bars and st < 2
        bool reaction = bull ? f_bull_rejection(lo, hi) or (not na(touchBar) and close > entry and close > high[1]) : f_bear_rejection(lo, hi) or (not na(touchBar) and close < entry and close < low[1])
        bool stopHit = f_stop_hit_live(bull, stop)
        bool hit1 = bull ? high >= t1 : low <= t1
        bool hit2 = bull ? high >= t2 : low <= t2
        bool hit3 = bull ? high >= t3 : low <= t3
        int newSt = st
        bool canEvaluateTrade = i_entry_model == "Pattern D" or bar_index > startBar
        if not terminal
            if not canEvaluateTrade
                newSt := math.max(newSt, touched ? 1 : 0)
            else if stopHit
                newSt := st >= 4 ? -5 : st >= 3 ? -4 : -1
            else if expired
                newSt := -2
            else if hit3
                newSt := 5
            else if hit2
                newSt := math.max(newSt, 4)
            else if hit1
                newSt := math.max(newSt, 3)
            else if reaction
                newSt := math.max(newSt, 2)
            else if touched
                newSt := math.max(newSt, 1)
        if touched and na(touchBar)
            touchBar := bar_index
            array.set(packTouchedBars, i, touchBar)
        if newSt != st
            array.set(packStatuses, i, newSt)
            lastName := nm
            lastSide := bull ? "Bull" : "Bear"
            lastScore := sc
            lastPrzLo := lo
            lastPrzHi := hi
            lastEntry := entry
            lastStop := stop
            lastTp1 := t1
            lastTp2 := t2
            lastTp3 := t3
            lastRR1 := f_rr(entry, stop, t1)
            lastRR2 := f_rr(entry, stop, t2)
            lastRR3 := f_rr(entry, stop, t3)
            lastStatus := f_status_txt(newSt)
            lastAlertStatus := lastStatus
            evTouched := evTouched or newSt == 1
            evReaction := evReaction or newSt == 2
            evTP1 := evTP1 or newSt == 3
            evTP2 := evTP2 or newSt == 4
            evTP3 := evTP3 or newSt == 5
            evFailed := evFailed or newSt < 0
        int rx = math.min(bar_index + i_level_right, bar_index + 500)
        bool przVisibleLive = array.get(packPrzVisible, i)
        bool rmVisibleLive = array.get(packRmVisible, i)
        bool tpVisibleLive = array.get(packTpVisible, i)
        if i_extend_live and i_extend_prz and przVisibleLive
            if not na(dp.przBox)
                box.set_right(dp.przBox, rx)
        if i_extend_live and i_extend_rm and rmVisibleLive
            if not na(dp.riskBox)
                box.set_right(dp.riskBox, rx)
            if not na(dp.lEntry)
                line.set_x2(dp.lEntry, rx)
            if not na(dp.lStop)
                line.set_x2(dp.lStop, rx)
            if not na(dp.lTp1)
                line.set_x2(dp.lTp1, rx)
            if not na(dp.lTp2)
                line.set_x2(dp.lTp2, rx)
            if not na(dp.lTp3)
                line.set_x2(dp.lTp3, rx)
            if not na(dp.entryLbl)
                label.set_x(dp.entryLbl, rx)
            if not na(dp.stopLbl)
                label.set_x(dp.stopLbl, rx)
            if not na(dp.tp1Lbl)
                label.set_x(dp.tp1Lbl, rx)
            if not na(dp.tp2Lbl)
                label.set_x(dp.tp2Lbl, rx)
            if not na(dp.tp3Lbl)
                label.set_x(dp.tp3Lbl, rx)
        if i_extend_live and i_extend_tp_zones and tpVisibleLive
            if not na(dp.tp1Box)
                box.set_right(dp.tp1Box, rx)
            if not na(dp.tp2Box)
                box.set_right(dp.tp2Box, rx)
            if not na(dp.tp3Box)
                box.set_right(dp.tp3Box, rx)
        color statusColor = f_status_col(array.get(packStatuses, i), bull)
        if not na(dp.mainLbl) and i_show_lifecycle_text
            string sideTxt = bull ? "BULL" : "BEAR"
            string txt = nm + "\n" + sideTxt + " | " + str.tostring(math.round(sc)) + "/100\n" + f_status_txt(array.get(packStatuses, i))
            label.set_text(dp.mainLbl, txt)
            label.set_color(dp.mainLbl, color.new(statusColor, 8))

//──────────────────────────────────────────────────────────────────────────────
// DASHBOARD
//──────────────────────────────────────────────────────────────────────────────
var table dash = na
if i_show_dashboard and na(dash)
    dash := table.new(f_pos(i_dash_pos), 2, 16, bgcolor=color.new(i_col_panel, 4), frame_color=color.new(color.rgb(105, 112, 122), 35), frame_width=1, border_width=1, border_color=color.new(color.rgb(105, 112, 122), 65))

if i_show_dashboard and barstate.islast
    color rowBg = color.new(i_col_panel, 0)
    color hdrBg = color.new(color.rgb(30, 35, 42), 0)
    color muted = color.new(color.rgb(176, 184, 194), 0)
    table.cell(dash, 0, 0, "IHM ULTIMATE", text_color=i_col_text, text_size=size.tiny, bgcolor=hdrBg)
    table.cell(dash, 1, 0, syminfo.ticker + " " + timeframe.period, text_color=i_col_text, text_size=size.tiny, bgcolor=hdrBg)
    table.cell(dash, 0, 1, "Mode", text_color=muted, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dash, 1, 1, i_mode + " | tol " + f_fmt(tol), text_color=i_col_text, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dash, 0, 2, "Pivots", text_color=muted, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dash, 1, 2, str.tostring(array.size(pivots)) + " / " + str.tostring(i_max_pivots), text_color=i_col_text, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dash, 0, 3, "Last Pattern", text_color=muted, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dash, 1, 3, lastName, text_color=i_col_text, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dash, 0, 4, "Side / Score", text_color=muted, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dash, 1, 4, lastSide + " | " + (na(lastScore) ? "-" : str.tostring(math.round(lastScore)) + "/100"), text_color=lastSide == "Bull" ? color.new(i_col_bull, 0) : lastSide == "Bear" ? color.new(i_col_bear, 0) : i_col_text, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dash, 0, 5, "PRZ", text_color=muted, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dash, 1, 5, na(lastPrzLo) ? "-" : f_fmt_price(lastPrzLo) + " / " + f_fmt_price(lastPrzHi), text_color=i_col_text, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dash, 0, 6, "HTF Bias", text_color=muted, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dash, 1, 6, i_use_htf ? (htfBull ? "Bull" : htfBear ? "Bear" : "Flat") : "Off", text_color=i_use_htf ? (htfBull ? color.new(i_col_bull, 0) : htfBear ? color.new(i_col_bear, 0) : i_col_text) : muted, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dash, 0, 7, "Context", text_color=muted, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dash, 1, 7, "RSI " + str.tostring(math.round(rsi)) + " | Vol " + (volExp ? "EXP" : "Norm"), text_color=i_col_text, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dash, 0, 8, "Detected", text_color=muted, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dash, 1, 8, str.tostring(totalPatterns), text_color=i_col_text, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dash, 0, 9, "Lifecycle", text_color=muted, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dash, 1, 9, lastStatus, text_color=lastStatus == "FAILED" ? color.new(color.rgb(150,82,82), 0) : lastStatus == "EXPIRED" ? muted : color.new(color.rgb(104,132,116), 0), text_size=size.tiny, bgcolor=rowBg)
    table.cell(dash, 0, 10, "Entry / SL", text_color=muted, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dash, 1, 10, na(lastEntry) ? "-" : f_fmt_price(lastEntry) + " / " + f_fmt_price(lastStop), text_color=i_col_text, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dash, 0, 11, "TP1 / TP2 / TP3", text_color=muted, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dash, 1, 11, na(lastTp1) ? "-" : f_fmt_price(lastTp1) + " / " + f_fmt_price(lastTp2) + " / " + f_fmt_price(lastTp3), text_color=i_col_text, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dash, 0, 12, "RR", text_color=muted, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dash, 1, 12, na(lastRR1) ? "-" : str.tostring(lastRR1, "#.##") + " / " + str.tostring(lastRR2, "#.##") + " / " + str.tostring(lastRR3, "#.##"), text_color=i_col_text, text_size=size.tiny, bgcolor=rowBg)
    int dashPrzCount = 0
    int dashRmCount = 0
    int dashTpCount = 0
    if array.size(packs) > 0
        for di = 0 to array.size(packs) - 1
            dashPrzCount += array.get(packPrzVisible, di) ? 1 : 0
            dashRmCount += array.get(packRmVisible, di) ? 1 : 0
            dashTpCount += array.get(packTpVisible, di) ? 1 : 0
    table.cell(dash, 0, 13, "Active Groups", text_color=muted, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dash, 1, 13, str.tostring(array.size(packs)) + " / " + str.tostring(i_max_patterns), text_color=i_col_text, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dash, 0, 14, "Layer Limits", text_color=muted, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dash, 1, 14, "PRZ " + str.tostring(dashPrzCount) + "/" + str.tostring(i_max_active_prz) + " | RM " + str.tostring(dashRmCount) + "/" + str.tostring(i_max_active_rm), text_color=i_col_text, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dash, 0, 15, "Extensions", text_color=muted, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dash, 1, 15, "PRZ " + (i_extend_prz ? "ON" : "OFF") + " | RM " + (i_extend_rm ? "ON" : "OFF") + " | TPZ " + (i_extend_tp_zones ? "ON" : "OFF"), text_color=i_col_text, text_size=size.tiny, bgcolor=rowBg)

//──────────────────────────────────────────────────────────────────────────────
// ALERTS
//──────────────────────────────────────────────────────────────────────────────
if i_alert_calls and (evNew or evTouched or evReaction or evFailed or evTP1 or evTP2 or evTP3) and barstate.isconfirmed
    string jStatus = lastAlertStatus == "" ? (evNew ? "DETECTED" : lastStatus) : lastAlertStatus
    string j = "{\"ticker\":\"" + syminfo.ticker + "\",\"timeframe\":\"" + timeframe.period + "\",\"pattern\":\"" + lastName + "\",\"side\":\"" + lastSide + "\",\"status\":\"" + jStatus + "\",\"score\":" + str.tostring(math.round(lastScore)) + ",\"entry\":\"" + f_fmt_price(lastEntry) + "\",\"stop\":\"" + f_fmt_price(lastStop) + "\",\"tp1\":\"" + f_fmt_price(lastTp1) + "\"}"
    alert(j, alert.freq_once_per_bar_close)

alertcondition(evNew, "IHM ULTIMATE - New Pattern", "New institutional pattern detected")
alertcondition(evBull, "IHM ULTIMATE - Bullish Pattern", "New bullish institutional pattern detected")
alertcondition(evBear, "IHM ULTIMATE - Bearish Pattern", "New bearish institutional pattern detected")
alertcondition(evHighScore, "IHM ULTIMATE - High Score Pattern", "New high-score institutional pattern detected")
alertcondition(evTouched, "IHM ULTIMATE - PRZ Touched", "Active pattern PRZ touched")
alertcondition(evReaction, "IHM ULTIMATE - Reaction Confirmed", "Active pattern produced a PRZ reaction")
alertcondition(evFailed, "IHM ULTIMATE - Failed / Stopped", "Active pattern invalidated or stopped before next target")
alertcondition(evTP1, "IHM ULTIMATE - TP1 Hit", "Active pattern reached TP1")
alertcondition(evTP2, "IHM ULTIMATE - TP2 Hit", "Active pattern reached TP2")
alertcondition(evTP3, "IHM ULTIMATE - TP3 Hit", "Active pattern reached TP3")
````
