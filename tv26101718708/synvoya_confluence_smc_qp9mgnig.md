# Synvoya Confluence (SMC)

- url: https://www.tradingview.com/script/QP9mGNIG-Synvoya-Confluence-SMC/
- type: indicator
- pine_id: PUB;69e0febfe43e414ba789d0697b898f3f
- version: 5.0

## Description

Synvoya Confluence (SMC) is a free, all-in-one Smart Money Concepts indicator for ICT/SMC traders. It combines 15 modules into a single overlay with a multi-timeframe bias dashboard — no paywall, no feature gating.

█ MODULES

1. Market Structure — Fractal swing detection with BOS (Break of Structure) and CHoCH (Change of Character) labels. Configurable pivot lookback and MTF structure analysis.

2. Order Blocks + Breaker Blocks — Automatic detection of bullish/bearish OBs with volume data overlay. Breaker block identification when OBs fail and flip. Configurable max active zones and mitigation tracking.

3. Fair Value Gaps (FVG) + Inversion FVG + Consequent Encroachment — Standard FVG detection with automatic IFVG flip tracking. CE (50%) midline plotted. Quality filtering from aggressive to very defensive.

4. Liquidity Levels + Inducement (IDM) — Equal highs/lows detection for buy-side and sell-side liquidity pools. IDM marking for the most recent pullback extreme before structure breaks.

5. Premium / Discount Zones — Automatic equilibrium (50%) calculation on the current dealing range. Visual shading for premium (above EQ) and discount (below EQ) zones.

6. Sessions + Killzones + Silver Bullet + ICT Macros — Full session visualization: Asian, London, New York. ICT Killzones (London 02:00–05:00, NY 07:00–10:00 ET). Silver Bullet windows (03:00–04:00, 10:00–11:00, 14:00–15:00 ET). All 8 ICT Macro time windows. All times use America/New_York timezone with automatic DST handling.

7. Key Levels — Previous Day/Week/Month/Quarter highs and lows. Monday range. Asian range high/low extension lines. NY Midnight Open.

8. Candle Range Theory (CRT) — Multi-timeframe CRT analysis. Turtle Body Soup (TBS) and Turtle Wick Soup (TWS) detection. Gated to 15min+ timeframes for signal quality.

9. ADR + Judas Levels — Average Daily Range calculation with configurable period. Judas swing reference levels for session bias.

10. SMT Divergence — Smart Money Technique divergence detection across correlated/inversely correlated pairs. Configurable pair and triad symbols. Supports indices, forex, and metals.

11. Multi-Timeframe Bias Dashboard — Dual-column bias system: Structure column (pivot BOS/CHoCH detection) + EMA column (close vs EMA9 & EMA21). Bullish = above both EMAs, Bearish = below both, Neutral = between. Timeframes: Weekly, Daily, 4H, 1H, 15m, 5m, 1m.

12. Candle Coloring — Optional directional candle coloring based on bias state.

13. Alerts — Configurable alerts for BOS, CHoCH, OB mitigation, FVG creation, liquidity sweeps, session opens, and more.

14. EMA Trend Lines — EMA 9 and EMA 21 with visual crossover detection.

15. Fractal Markers — Swing high/low fractal markers with configurable sensitivity.

█ HOW TO USE

- Apply to any timeframe. Use 1H/4H/Daily for bias, 1m/5m/15m for entries.
- Best suited for Forex (EURUSD, GBPUSD), Gold (XAUUSD), and NAS100.
- All modules are independently toggleable — enable only what fits your trading model.
- The dashboard provides at-a-glance multi-timeframe confluence without switching charts.

█ METHODOLOGY

Built on ICT (Inner Circle Trader) and Smart Money Concepts methodology. Designed for traders who use institutional order flow analysis, liquidity-based entries, and time-based setups (Killzones, Silver Bullet, Macros).

█ TECHNICAL NOTES

- Non-repainting — all structure detection and alert logic fires on confirmed bar close.
- Timezone-independent — all session logic uses America/New_York (ET) regardless of broker or chart timezone.
- Open source — full Pine Script v6 source code available for review and learning.
- 2500+ lines of Pine Script v6 with optimized performance for real-time charts.
- All dashboard, legend, and visual elements are independently toggleable.

## Source Code

````pine
//@version=6
// ============================================================
// Synvoya Confluence (SMC)
// ============================================================


//=============================================================================
// SECTION 0 — INDICATOR DECLARATION
//=============================================================================
indicator("Synvoya Confluence (SMC)", shorttitle="Synvoya Confluence (SMC)", overlay=true,
         max_lines_count=500, max_boxes_count=500, max_labels_count=500,
         max_bars_back=5000)


//=============================================================================
// SECTION 1 — INPUT GROUPS & SETTINGS
//=============================================================================
// Group constants act as section dividers in the indicator settings panel.
G_STRUCT   = "═══ Market Structure ═══"
G_OB       = "═══ Order Blocks ═══"
G_FVG      = "═══ Fair Value Gaps ═══"
G_LIQ      = "═══ Liquidity ═══"
G_PD       = "═══ Premium / Discount ═══"
G_SESSIONS  = "═══ Sessions ═══"
G_KILLZONES = "═══ ICT Killzones ═══"
G_LEVELS   = "═══ Key Levels ═══"
G_CRT      = "═══ CRT (Candle Range Theory) ═══"
G_ADR      = "═══ ADR Monitor ═══"
G_SMT      = "═══ SMT Divergence ═══"
G_DASH     = "═══ Dashboard ═══"
G_LEGEND   = "═══ Legend ═══"
G_VISUAL   = "═══ Visual Settings ═══"


smcWorkflowMode = input.string("Clean", "SMC Workflow Mode",
     options=["Clean", "Learning", "Full"], group=G_VISUAL, display=display.none,
     tooltip="Clean keeps the chart focused. Learning adds the legend and checklist. Full respects every detailed module toggle.")


// ---- 1.0 Global visual rules ----
// htfOnly: HIGH-NOISE structure items (HH/HL/LH/LL labels, fractal
// connector lines, CRT) only render on 15m+. On 1m/5m these overlap into
// an unreadable mess.
//
// Items NOT gated by this toggle (always render on all TFs):
// - Fractal markers ▽△ (controlled separately by Show Fractal Markers)
// - BOS, CHoCH labels
// - EQH, EQL, OBs, FVGs, sweeps
// All discrete events that stay readable on 1m.
htfOnly        = input.bool(true,  "Show HH/HL & CRT on 15m+ only", group=G_STRUCT, display=display.none,
     tooltip="When ON, HH/HL/LH/LL classification labels, fractal connector lines, and CRT only render on 15m+. Fractal markers ▽△, BOS, CHoCH, EQH, EQL, FVGs, and OBs always render on every timeframe.")
rightExtBars   = input.int(5, "Line Right Extension (bars)",
     minval=0, maxval=50, group=G_VISUAL, display=display.none,
     tooltip="How many bars past the last candle horizontal levels (key levels, EQH/EQL, IDM, EQ, ADR, Judas, CRT) extend to. 0 = stop exactly at the last bar.")


// ---- 1.1 Market Structure ----
showStructure   = input.bool(true,  "Show Market Structure",     group=G_STRUCT, display=display.none)
showInternal    = input.bool(true,  "Show Internal Structure",   group=G_STRUCT, display=display.none)
showSwing       = input.bool(true,  "Show Swing Structure",      group=G_STRUCT, display=display.none)
showBOS         = input.bool(true,  "Show BOS Labels",           group=G_STRUCT, display=display.none)
showCHoCH       = input.bool(true,  "Show CHoCH Labels",         group=G_STRUCT, display=display.none)
showSwingPoints = input.bool(true,  "Show Swing Points (Fractal Markers ▲▼)", group=G_STRUCT, display=display.none,
     tooltip="Williams-Fractal-style triangle markers at every swing pivot. ▲ above highs (points up), ▼ below lows (points down). Always rendered on all timeframes (independent of the 15m+ HTF gate). Default ON.")
fractalBullColor = input.color(#26A69A, "Fractal Bull Color (▼)", group=G_STRUCT, display=display.none,
     tooltip="Color of the ▼ markers below swing lows. Defaults to teal — distinct from BOS/CHoCH bull color so fractals stand out as a separate visual layer.")
fractalBearColor = input.color(#EF5350, "Fractal Bear Color (▲)", group=G_STRUCT, display=display.none,
     tooltip="Color of the ▲ markers above swing highs. Defaults to coral — distinct from BOS/CHoCH bear color so fractals stand out as a separate visual layer.")
// HH/HL/LH/LL classification text — separate from the triangle markers and
// default OFF so the chart looks like the standard Williams Fractals indicator
// (clean red ▽ above highs, green △ below lows). Turn ON when you want the
// structural classification text alongside the markers.
showHHHL        = input.bool(false, "Show HH/HL/LH/LL Labels",   group=G_STRUCT, display=display.none)
showSwingLines  = input.bool(true,  "Show Swing Lines (fractal connectors)", group=G_STRUCT, display=display.none)
intLeftBars     = input.int(5,  "Internal Lookback Left",  minval=1, maxval=20, group=G_STRUCT, display=display.none)
intRightBars    = input.int(5,  "Internal Lookback Right", minval=1, maxval=20, group=G_STRUCT, display=display.none)
swgLeftBars     = input.int(10, "External Lookback Left",  minval=5, maxval=30, group=G_STRUCT, display=display.none,
     tooltip="External/swing pivots for BOS and CHoCH. Internal pivots use the smaller lookback and print iBOS/iCHoCH.")
swgRightBars    = input.int(10, "External Lookback Right", minval=5, maxval=30, group=G_STRUCT, display=display.none)
confirmMode     = input.string("Close", "Confirmation", options=["Close", "Wick"], group=G_STRUCT, display=display.none)
structureValidation = input.string("Strict SMC", "Structure Validation",
     options=["Strict SMC", "Classic Pivot"], group=G_STRUCT, display=display.none,
     tooltip="Strict SMC filters BOS/CHoCH through protected highs/lows, inducement/pullback, ATR buffer, and mother-candle range logic. Classic Pivot keeps the older raw pivot-break behavior.")
smcRequireInducement = input.bool(true, "Require Pullback / Inducement Before BOS", group=G_STRUCT, display=display.none,
     tooltip="When ON, a bullish BOS needs a confirmed pivot low after the high being broken, and a bearish BOS needs a confirmed pivot high after the low being broken.")
smcMotherFilter = input.bool(true, "Ignore Structure Inside Mother Candle", group=G_STRUCT, display=display.none,
     tooltip="Blocks BOS/CHoCH while the break is still inside the containing candle range. This prevents internal range noise from printing structure.")
smcMinLegATR = input.float(0.25, "Min Structure Leg (ATR)", minval=0.0, maxval=2.0, step=0.05, group=G_STRUCT, display=display.none,
     tooltip="Minimum distance between the active high/low pivots before Strict SMC accepts a structure break. Internal structure uses half this value.")
smcBreakBufferATR = input.float(0.03, "Break Buffer (ATR)", minval=0.0, maxval=0.5, step=0.01, group=G_STRUCT, display=display.none,
     tooltip="Extra distance beyond the protected level required for Strict SMC. Helps prevent tiny tick breaks from printing BOS/CHoCH.")
bullColor       = input.color(#4CAF50, "Bullish Color", group=G_STRUCT, display=display.none)
bearColor       = input.color(#F44336, "Bearish Color", group=G_STRUCT, display=display.none)
chochColor      = input.color(#FF9800, "CHoCH Color",   group=G_STRUCT, display=display.none)


// ---- 1.2 Order Blocks ----
showOBs         = input.bool(true,  "Show Order Blocks",   group=G_OB, display=display.none)
showBullOB      = input.bool(true,  "Show Bullish OBs",    group=G_OB, display=display.none)
showBearOB      = input.bool(true,  "Show Bearish OBs",    group=G_OB, display=display.none)
showBreakers    = input.bool(true,  "Show Breaker Blocks", group=G_OB, display=display.none)
maxOBs          = input.int(5, "Max OBs per Side", minval=1, maxval=10, group=G_OB, display=display.none)
showMitigatedOB = input.bool(false, "Show Mitigated OBs", group=G_OB, display=display.none)
showOBLabels    = input.bool(true,  "Show OB Labels",     group=G_OB, display=display.none)
bullOBColor     = input.color(#4CAF50, "Bullish OB Color", group=G_OB, display=display.none)
bearOBColor     = input.color(#F44336, "Bearish OB Color", group=G_OB, display=display.none)
obTransp        = input.int(85, "OB Transparency", minval=0, maxval=100, group=G_OB, display=display.none)


// ---- 1.3 Fair Value Gaps ----
showFVGs         = input.bool(true,  "Show FVGs",            group=G_FVG, display=display.none)
showBullFVG      = input.bool(true,  "Show Bullish FVGs",    group=G_FVG, display=display.none)
showBearFVG      = input.bool(true,  "Show Bearish FVGs",    group=G_FVG, display=display.none)
showCE           = input.bool(true,  "Show CE Line",         group=G_FVG, display=display.none)
showIFVG         = input.bool(true,  "Show iFVGs",           group=G_FVG, display=display.none)
showMitigatedFVG = input.bool(false, "Show Mitigated FVGs",  group=G_FVG, display=display.none)
maxFVGs          = input.int(5, "Max Visible FVGs", minval=1, maxval=20, group=G_FVG, display=display.none)
minFVGSize       = input.float(0.1, "Min FVG Size (ATR mult)", minval=0.0, maxval=1.0, step=0.05, group=G_FVG, display=display.none)
// FVG palette — single color per state so the chart reads at a glance:
//   active FVG (bull or bear) = BLUE  (#2196F3) — easy to see against dark bg
//   inverted FVG (iFVG)       = ORANGE (#FF9800) — clearly different from active
// Cream/gold defaults were tried earlier and proved too pale to spot against
// other overlays. Users who want bull-green / bear-red can switch the inputs.
bullFVGColor     = input.color(#2196F3, "Bullish FVG Color",  group=G_FVG, display=display.none)
bearFVGColor     = input.color(#2196F3, "Bearish FVG Color",  group=G_FVG, display=display.none)
iFVGBullColor    = input.color(#FF9800, "iFVG Bullish Color", group=G_FVG, display=display.none)
iFVGBearColor    = input.color(#FF9800, "iFVG Bearish Color", group=G_FVG, display=display.none)
fvgTransp        = input.int(65, "FVG Transparency", minval=0, maxval=100, group=G_FVG, display=display.none)


// ---- 1.4 Liquidity ----
showLiq         = input.bool(true,  "Show Liquidity Levels", group=G_LIQ, display=display.none)
showEQH         = input.bool(true,  "Show EQH",              group=G_LIQ, display=display.none)
showEQL         = input.bool(true,  "Show EQL",              group=G_LIQ, display=display.none)
showSweeps      = input.bool(true,  "Show Sweep Labels",     group=G_LIQ, display=display.none)
showIDM         = input.bool(true,  "Show Inducements",      group=G_LIQ, display=display.none)
// EQ tolerance — distance two swing points must be within to count as "equal".
//   "Auto (ATR)" : tolerance = ATR(14) × eqToleranceATR. Adapts to instrument
//                  volatility — 0.10 means 10% of ATR. Works on forex AND
//                  indices (where 10 "pips" = 2.5 NAS100 points is too tight
//                  for any swings to ever pair).
//   "Pips"       : tolerance = pip-aware mintick × eqTolerance (legacy mode).
eqToleranceMode = input.string("Auto (ATR)", "EQ Tolerance Mode",
     options=["Auto (ATR)", "Pips"], group=G_LIQ, display=display.none)
eqToleranceATR  = input.float(0.10, "EQ Tolerance (ATR multiplier, when Auto)",
     minval=0.01, maxval=1.0, step=0.05, group=G_LIQ, display=display.none)
eqTolerance     = input.float(10.0, "EQ Tolerance (pips, when Mode=Pips)",
     minval=0.0, step=1.0, group=G_LIQ, display=display.none)
eqhColor        = input.color(#F44336, "EQH Color",   group=G_LIQ, display=display.none)
eqlColor        = input.color(#4CAF50, "EQL Color",   group=G_LIQ, display=display.none)
sweptColor      = input.color(#9E9E9E, "Swept Color", group=G_LIQ, display=display.none)


// ---- 1.5 Premium / Discount ----
showPD          = input.bool(true,  "Show P/D Zones",        group=G_PD, display=display.none)
showEQ          = input.bool(true,  "Show Equilibrium Line", group=G_PD, display=display.none)
showZoneShading = input.bool(true,  "Show Zone Shading",     group=G_PD, display=display.none)
// "% Prem"/"% Disc" floating label — default OFF. The zone shading already
// communicates premium-vs-discount; the percentage adds clutter near price.
showPctReadout  = input.bool(false, "Show % Readout",        group=G_PD, display=display.none)
premColor       = input.color(#F44336, "Premium Color",  group=G_PD, display=display.none)
discColor       = input.color(#4CAF50, "Discount Color", group=G_PD, display=display.none)
eqColor         = input.color(#9E9E9E, "EQ Color",       group=G_PD, display=display.none)
zoneTransp      = input.int(95, "Zone Transparency", minval=0, maxval=100, group=G_PD, display=display.none)


// ---- 1.6 Sessions & Killzones ----
showSessions      = input.bool(true,  "Show Sessions",              group=G_SESSIONS, display=display.none)
showAsia          = input.bool(true,  "Show Asia",                  group=G_SESSIONS, display=display.none)
showPreLondon     = input.bool(true,  "Show Pre-London",            group=G_SESSIONS, display=display.none)
showLondon        = input.bool(true,  "Show London",                group=G_SESSIONS, display=display.none)
showPreNY         = input.bool(true,  "Show Pre-NY",                group=G_SESSIONS, display=display.none)
// Single combined "NY" block — 07:00-16:00 EST, covers extended hours +
// cash session as one box. Default ON. The granular sub-sessions below
// (NY Open / NY AM Cash / NY Lunch / NY PM) overlap with this block and
// are off by default to avoid visual stacking. Turn them on if you want
// killzone-level detail.
showNY            = input.bool(true,  "Show NY (full)",             group=G_SESSIONS, display=display.none)
showNYOpen        = input.bool(false, "Show NY Open (sub)",         group=G_SESSIONS, display=display.none)
showNYAM          = input.bool(false, "Show NY AM Cash (sub)",      group=G_SESSIONS, display=display.none)
showNYLunch       = input.bool(false, "Show NY Lunch (sub)",        group=G_SESSIONS, display=display.none)
showNYPM          = input.bool(false, "Show NY PM (sub)",           group=G_SESSIONS, display=display.none)
// Session H/L lines used to extend right indefinitely and clutter the chart
// with horizontal session-extreme rays. Default OFF — the session box already
// shows the high and low; traders who specifically want the rays can re-enable.
showSessionHL     = input.bool(false, "Show Session H/L Lines",     group=G_SESSIONS, display=display.none)
showAsiaHL        = input.bool(false, "Show Asia H/L Extension (past session end)", group=G_SESSIONS, display=display.none,
     tooltip="Plots Asia session High and Low as dashed lines that extend into London and NY sessions. Useful as a reference for stop hunts and liquidity draws.")
showSessionLabels = input.bool(true,  "Show Session Labels",        group=G_SESSIONS, display=display.none)
showSilverBullet  = input.bool(false, "Show Silver Bullet Windows", group=G_SESSIONS, display=display.none)
showICTMacros     = input.bool(false, "Show ICT Macros",            group=G_SESSIONS, display=display.none)
// Every session gets its own color input — previously Pre-London, Pre-NY,
// NY AM, NY Lunch, NY PM were hardcoded and uncustomizable.
asiaColor         = input.color(#9C27B0, "Asia Color",       group=G_SESSIONS, display=display.none)
preLondonColor    = input.color(#FF9800, "Pre-London Color", group=G_SESSIONS, display=display.none)
londonColor       = input.color(#2196F3, "London Color",     group=G_SESSIONS, display=display.none)
preNYColor        = input.color(#FF9800, "Pre-NY Color",     group=G_SESSIONS, display=display.none)
nyColor           = input.color(#4CAF50, "NY Open Color",    group=G_SESSIONS, display=display.none)
nyAMColor         = input.color(#00BCD4, "NY AM Color",      group=G_SESSIONS, display=display.none)
nyLunchColor      = input.color(#F44336, "NY Lunch Color",   group=G_SESSIONS, display=display.none)
nyPMColor         = input.color(#8BC34A, "NY PM Color",      group=G_SESSIONS, display=display.none)
sessionTransp     = input.int(90, "Session Transparency", minval=0, maxval=100, group=G_SESSIONS, display=display.none)


// ---- 1.6b ICT Killzones ----
// Optional ICT-specific killzone windows. Default OFF — session boxes use
// market hours by default; killzones are an opt-in for ICT traders who
// want the classic 02-05 London / 07-10 NY / 13:30-16 NY PM / 20-00 Asia
// liquidity windows highlighted on the chart.
showKillzones = input.bool(false, "Show ICT Killzones",                 group=G_KILLZONES, display=display.none,
     tooltip="Overlay ICT-style killzone boxes (Asia/London Open/NY AM/NY PM). Independent of the Sessions feature — sessions show market hours, killzones show liquidity windows.")
showAsiaKZ    = input.bool(true,  "Asia Killzone (20:00-00:00 NY)",     group=G_KILLZONES, display=display.none)
showLondonKZ  = input.bool(true,  "London Open Killzone (02:00-05:00 NY)", group=G_KILLZONES, display=display.none)
showNYAMKZ    = input.bool(true,  "NY AM Killzone (07:00-10:00 NY)",    group=G_KILLZONES, display=display.none)
showNYPMKZ    = input.bool(true,  "NY PM Killzone (13:30-16:00 NY)",    group=G_KILLZONES, display=display.none)
killzoneColor = input.color(#E91E63, "Killzone Color",                  group=G_KILLZONES, display=display.none)


// ---- 1.7 Key Levels ----
showLevels      = input.bool(true,  "Show Key Levels",       group=G_LEVELS, display=display.none)
showPDH_PDL     = input.bool(true,  "Show PDH/PDL",          group=G_LEVELS, display=display.none)
showPWH_PWL     = input.bool(true,  "Show PWH/PWL",          group=G_LEVELS, display=display.none)
showPMH_PML     = input.bool(false, "Show PMH/PML",          group=G_LEVELS, display=display.none)
showMonday      = input.bool(false, "Show Monday H/L",       group=G_LEVELS, display=display.none)
showNYMidnight  = input.bool(true,  "Show NY Midnight Open", group=G_LEVELS, display=display.none)
showLevelLabels = input.bool(true,  "Show Level Labels",     group=G_LEVELS, display=display.none)
dailyColor      = input.color(#FF9800, "Daily Color",   group=G_LEVELS, display=display.none)
weeklyColor     = input.color(#2196F3, "Weekly Color",  group=G_LEVELS, display=display.none)
monthlyColor    = input.color(#9C27B0, "Monthly Color", group=G_LEVELS, display=display.none)


// ---- 1.8 CRT (Candle Range Theory) ----
showCRT       = input.bool(true, "Show CRT",        group=G_CRT, display=display.none)
showCRTLabels = input.bool(true, "Show CRT Labels", group=G_CRT, display=display.none)
bullCRTColor  = input.color(#4CAF50, "Bullish CRT Color", group=G_CRT, display=display.none)
bearCRTColor  = input.color(#F44336, "Bearish CRT Color", group=G_CRT, display=display.none)
crtLineStyle  = input.string("Dashed", "CRT Line Style", options=["Solid", "Dashed", "Dotted"], group=G_CRT, display=display.none)


// ---- 1.9 ADR Monitor ----
// Default OFF — ADR % consumption is information-dense but adds chart clutter
// for traders who don't actively use range targets. Enable when you do.
showADR      = input.bool(false, "Show ADR",                  group=G_ADR, display=display.none)
adrPeriod    = input.int(14, "ADR Period", minval=5, maxval=30, group=G_ADR, display=display.none)
showADRProj  = input.bool(false, "Show ADR Projection Lines", group=G_ADR, display=display.none)
showJudas    = input.bool(false, "Show Judas Levels",         group=G_ADR, display=display.none)
adrColor     = input.color(#FF9800, "ADR Color", group=G_ADR, display=display.none)
adrThreshold = input.int(80, "ADR Exhaustion Threshold %", minval=50, maxval=95, group=G_ADR, display=display.none)


// ---- 1.10 SMT Divergence ----
showSMT         = input.bool(true, "Show SMT", group=G_SMT, display=display.none)
smtPairOverride = input.string("", "Correlated Pair Override", group=G_SMT, display=display.none,
     tooltip="Leave blank for auto-detection. Format: EXCHANGE:SYMBOL e.g. FX:GBPUSD")
showSMTLabels   = input.bool(true, "Show SMT Labels", group=G_SMT, display=display.none)
bullSMTColor    = input.color(#4CAF50, "Bullish SMT Color", group=G_SMT, display=display.none)
bearSMTColor    = input.color(#F44336, "Bearish SMT Color", group=G_SMT, display=display.none)


// ---- 1.11 Dashboard ----
showDash      = input.bool(true, "Show Dashboard", group=G_DASH, display=display.none)
dashPosition  = input.string("Top Right", "Table Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=G_DASH, display=display.none)
dashSize      = input.string("Small", "Table Size",
     options=["Tiny", "Small", "Normal"], group=G_DASH, display=display.none)
// EMA periods for the EMA-cross bias column. 9/21 is the SMC intraday
// convention — adjust if you prefer 10/20, 5/13, 8/21, etc.
dashEmaFast   = input.int(9,  "EMA Fast (Bias)", minval=2, maxval=50,  group=G_DASH, display=display.none,
     tooltip="Fast EMA period for the dashboard's EMA bias column. Default 9 (SMC convention). EMA9 above EMA21 = bullish, below = bearish.")
dashEmaSlow   = input.int(21, "EMA Slow (Bias)", minval=3, maxval=200, group=G_DASH, display=display.none,
     tooltip="Slow EMA period for the dashboard's EMA bias column. Default 21. Pair with the Fast input — common alternates: 10/20, 5/13, 8/21.")
// EMA-on-chart plotting — render the same EMAs used for the bias column
// as lines on the chart. Off by default. When ON, traders see exactly
// what the bias dashboard is computing.
showEMALines  = input.bool(false, "Show EMA Lines on Chart", group=G_DASH, display=display.none,
     tooltip="Plots the same fast/slow EMAs used for the dashboard EMA bias column directly on the chart. Useful for traders who want to see the EMA cross visually rather than just the bias arrow.")
emaFastColor  = input.color(#00BCD4, "EMA Fast Line Color", group=G_DASH, display=display.none)
emaSlowColor  = input.color(#FF9800, "EMA Slow Line Color", group=G_DASH, display=display.none)
dashBgColor   = input.color(#1E1E1E, "Table BG Color",   group=G_DASH, display=display.none)
dashTextColor = input.color(#FFFFFF, "Table Text Color", group=G_DASH, display=display.none)


// ---- 1.12 Legend ----
// Toggleable abbreviation-key table — explains OB, BB, FVG, iFVG, CE, EQH/EQL,
// IDM, PDH/PDL/PWH/PWL/PMH/PML, NY Mid, ADR, SMT, CRT, BOS, CHoCH, HH/HL/LH/LL.
// Default ON — the indicator throws a lot of acronyms on the chart and new
// users shouldn't have to guess what they mean. Power users turn it off.
showLegend     = input.bool(true,  "Show Legend",       group=G_LEGEND, display=display.none)
legendPosition = input.string("Bottom Right", "Legend Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"],
     group=G_LEGEND, display=display.none)
legendSize     = input.string("Tiny", "Legend Size",
     options=["Tiny", "Small", "Normal"], group=G_LEGEND, display=display.none)


// ---- 1.13 Visual Settings ----
enableCandleColor = input.bool(false, "Enable Candle Coloring", group=G_VISUAL, display=display.none)
// Candle Color Mode:
//   "Direction" — color by candle's own close vs open (what users expect when
//                 they hear "candle coloring"). Bullish bars green, bearish red.
//   "Structure" — color by swing-level structural bias (the original PRD intent;
//                 useful for "trend at-a-glance" but counter-intuitive because
//                 every candle in a bullish trend tints green even when bearish).
candleColorMode   = input.string("Direction", "Candle Color Mode",
     options=["Direction", "Structure"], group=G_VISUAL, display=display.none)
bullCandleColor   = input.color(#4CAF50, "Bullish Candle Color", group=G_VISUAL, display=display.none)
bearCandleColor   = input.color(#F44336, "Bearish Candle Color", group=G_VISUAL, display=display.none)

workflowClean    = smcWorkflowMode == "Clean"
workflowLearning = smcWorkflowMode == "Learning"
workflowFull     = smcWorkflowMode == "Full"
showHHHL_eff        = workflowFull ? showHHHL : workflowLearning
showSwingLines_eff  = workflowFull ? showSwingLines : false
showPctReadout_eff  = workflowFull ? showPctReadout : false
showSilverBullet_eff = workflowFull ? showSilverBullet : false
showICTMacros_eff    = workflowFull ? showICTMacros : false
showKillzones_eff    = workflowFull ? showKillzones : false
showADR_eff          = workflowFull ? showADR : false
showJudas_eff        = workflowFull ? showJudas : false
showLegend_eff       = workflowLearning ? true : workflowFull ? showLegend : false
showChecklist_eff    = showDash and not workflowFull


//=============================================================================
// SECTION 2 — UTILITY FUNCTIONS & CONSTANTS
//=============================================================================

// ---- NY-localized time getters ----
// Every session/macro check in this indicator uses America/New_York time
// so broker timezone differences and DST transitions are auto-handled.
// Never read raw hour(time) / minute(time) anywhere else in the file.
//
// Bar-time variants (use `time` = bar's open timestamp). Drive session-box
// rendering — each bar gets its session via its own open time.
f_ny_hour()   => hour(time, "America/New_York")
f_ny_minute() => minute(time, "America/New_York")

// Wall-clock variants (use `timenow` = live real-world time). Drive the
// dashboard's "Session" label and NY-clock row. On HTF charts (4H, D),
// the live wall-clock can be hours into a bar that opened in a different
// session — without these, the dashboard would show the bar-open session
// instead of what's actually happening right now.
f_ny_hour_now()   => hour(timenow, "America/New_York")
f_ny_minute_now() => minute(timenow, "America/New_York")


// ---- Session window check ----
// Returns true when the current bar falls within [startH:startM, endH:endM)
// in NY time. Handles sessions that cross midnight (e.g. Asia 19:00 → 00:00)
// by switching to OR semantics when start > end.
f_is_in_session(startH, startM, endH, endM) =>
    cur = f_ny_hour() * 60 + f_ny_minute()
    s   = startH * 60 + startM
    e   = endH   * 60 + endM
    s > e ? (cur >= s or cur < e) : (cur >= s and cur < e)

// Wall-clock version — same logic but evaluated against live time.
f_is_in_session_now(startH, startM, endH, endM) =>
    cur = f_ny_hour_now() * 60 + f_ny_minute_now()
    s   = startH * 60 + startM
    e   = endH   * 60 + endM
    s > e ? (cur >= s or cur < e) : (cur >= s and cur < e)


// ---- Color helpers ----
// Apply transparency (0 = solid, 100 = fully transparent). Single named
// wrapper around color.new keeps visual settings consistent and lets us
// swap implementations later without touching every call site.
f_alpha(c, transp) => color.new(c, transp)


// Pick the right color for a structural-bias state.
// bias: 1 = bullish, -1 = bearish, 0 = neutral.
f_bias_color(bias, bull_c, bear_c, neutral_c) =>
    bias == 1 ? bull_c : bias == -1 ? bear_c : neutral_c


// ---- HTF gate ----
// True when the chart's timeframe is 15m or higher. Used to suppress
// market-structure labels and CRT on 1m/5m where they're too noisy.
// 900 sec = 15 min. timeframe.in_seconds() returns the chart TF in seconds.
f_is_htf() => timeframe.in_seconds(timeframe.period) >= 900

// Resolved per-bar — most call sites are gated by `htfOnly` AND this check.
// Using `not htfOnly or f_is_htf()` makes the labels show on all TFs when
// the user disables htfOnly, and on 15m+ when enabled.
htfPass = not htfOnly or f_is_htf()


// ---- Right-edge anchor for extending lines ----
// Replaces `extend = extend.right`. The line stops `rightExtBars` past the
// last bar so labels can sit on the right edge without spilling off-screen.
f_right_anchor() => bar_index + rightExtBars

// ---- Drawing-object recycling helpers ----
// Pine keeps historical drawings alive unless we explicitly delete them. These
// helpers keep uncapped visual layers under TradingView's 500-object limits.
f_track_box(array<box> arr, box bx, int cap) =>
    array.push(arr, bx)
    while array.size(arr) > cap
        old = array.shift(arr)
        if not na(old)
            box.delete(old)

f_track_line(array<line> arr, line ln, int cap) =>
    array.push(arr, ln)
    while array.size(arr) > cap
        old = array.shift(arr)
        if not na(old)
            line.delete(old)

f_track_label(array<label> arr, label lbl, int cap) =>
    array.push(arr, lbl)
    while array.size(arr) > cap
        old = array.shift(arr)
        if not na(old)
            label.delete(old)


//=============================================================================
// SECTION 3 — TIMEZONE & SESSION ENGINE
//=============================================================================
// Renders Asia, Pre-London, London, Pre-NY, NY Open, NY AM Cash, NY Lunch,
// NY PM session boxes; tracks session H/L lines + name labels; renders Silver
// Bullet windows and ICT Macros. All time logic flows through f_is_in_session
// (Section 2), which is NY-localized.

// ---- 3.1 Static window colors (Silver Bullet + ICT macros) ----
// Every session now has a user-facing input.color in Section 1.6. Only
// the Silver Bullet windows and ICT macros stay hardcoded here.
SB_COLOR    = #FFEB3B   // Silver Bullet — yellow
MACRO_COLOR = #B0BEC5   // ICT Macro — muted blue-gray

// ---- 3.2 Per-session state types ----
type SessionState
    bool  active = false
    box   bx        = na
    line  hiLine    = na
    line  loLine    = na
    label nameLabel = na
    float hi        = na
    float lo        = na

type WindowState
    bool active = false
    box  bx     = na

SESSION_BOX_CAP = 80
WINDOW_BOX_CAP  = 80
var array<box> sessionBoxes = array.new<box>()
var array<box> windowBoxes  = array.new<box>()

// ---- 3.3 Updaters ----
// f_update_session: full session with box, H/L lines, and name label.
// State machine on inSess vs state.active:
//   off -> on  : delete prior H/L + label, create new box / lines / label
//   on  -> on  : extend high/low, push box right, slide label up to current high
//   on  -> off : freeze (do nothing — box and H/L lines persist as historical reference)
//   show=false : tear everything down
f_update_session(SessionState state, bool show, int startH, int startM,
                 int endH, int endM, color sessC, string name) =>
    inSess = f_is_in_session(startH, startM, endH, endM)
    // Pine v6 CE10235: shared int sentinel aligns return types of every
    // branch in the chained if/elif/elif (bool / void / bool would error).
    _step = 0

    if not show
        if not na(state.bx)
            box.delete(state.bx)
            state.bx := na
        if not na(state.hiLine)
            line.delete(state.hiLine)
            state.hiLine := na
        if not na(state.loLine)
            line.delete(state.loLine)
            state.loLine := na
        if not na(state.nameLabel)
            label.delete(state.nameLabel)
            state.nameLabel := na
        state.active := false
        _step := 1
    else
        if inSess and not state.active
            // Session start — replace prior H/L + label with fresh ones.
            // The previous session's box is left in place as historical context.
            if not na(state.hiLine)
                line.delete(state.hiLine)
            if not na(state.loLine)
                line.delete(state.loLine)
            if not na(state.nameLabel)
                label.delete(state.nameLabel)

            state.hi := high
            state.lo := low
            state.bx := box.new(time, high, time, low,
                 bgcolor     = f_alpha(sessC, sessionTransp),
                 border_color= f_alpha(sessC, math.max(sessionTransp - 30, 0)),
                 xloc        = xloc.bar_time)
            f_track_box(sessionBoxes, state.bx, SESSION_BOX_CAP)

            if showSessionHL
                // Session H/L lines now stop at the live edge — no extend.right.
                // Old behavior turned every session into a horizontal ray that
                // bled across the chart for hours after the session ended.
                state.hiLine := line.new(time, high, time, high,
                     color  = sessC,
                     style  = line.style_solid,
                     xloc   = xloc.bar_time)
                state.loLine := line.new(time, low, time, low,
                     color  = sessC,
                     style  = line.style_solid,
                     xloc   = xloc.bar_time)

            if showSessionLabels
                state.nameLabel := label.new(time, high, name,
                     style    = label.style_label_down,
                     color    = sessC,
                     textcolor= color.white,
                     xloc     = xloc.bar_time,
                     size     = size.small)

            state.active := true
            _step := 2

        else if inSess
            // Session ongoing — extend high/low and push the box right.
            state.hi := math.max(state.hi, high)
            state.lo := math.min(state.lo, low)
            box.set_top(state.bx, state.hi)
            box.set_bottom(state.bx, state.lo)
            box.set_right(state.bx, time)

            if showSessionHL and not na(state.hiLine)
                // Update y AND x2 every bar so the line stays horizontal and
                // its right edge tracks the live bar. No extend.right anymore —
                // the line is bounded to the session itself.
                line.set_y1(state.hiLine, state.hi)
                line.set_y2(state.hiLine, state.hi)
                line.set_x2(state.hiLine, time)
                line.set_y1(state.loLine, state.lo)
                line.set_y2(state.loLine, state.lo)
                line.set_x2(state.loLine, time)

            if showSessionLabels and not na(state.nameLabel)
                label.set_y(state.nameLabel, state.hi)
            _step := 3

        else if not inSess and state.active
            // Session just ended — freeze. Box and (optional) H/L lines stay
            // at their last extent. They get torn down on the next instance of
            // this session, not on session-end.
            state.active := false
            _step := 4


// f_update_window: lightweight session-like box with no H/L lines, no label.
// Used for Silver Bullet windows and ICT macros.
f_update_window(WindowState state, bool show, int startH, int startM,
                int endH, int endM, color winC, int transp) =>
    inWin = f_is_in_session(startH, startM, endH, endM)
    // Pine v6 CE10235 prevention: shared int sentinel across all branches.
    _step = 0

    if not show
        if not na(state.bx)
            box.delete(state.bx)
            state.bx := na
        state.active := false
        _step := 1
    else
        if inWin and not state.active
            state.bx := box.new(time, high, time, low,
                 bgcolor     = f_alpha(winC, transp),
                 border_color= f_alpha(winC, math.max(transp - 20, 0)),
                 xloc        = xloc.bar_time)
            f_track_box(windowBoxes, state.bx, WINDOW_BOX_CAP)
            state.active := true
            _step := 2
        else if inWin and not na(state.bx)
            box.set_top(state.bx, math.max(box.get_top(state.bx), high))
            box.set_bottom(state.bx, math.min(box.get_bottom(state.bx), low))
            box.set_right(state.bx, time)
            _step := 3
        else if not inWin and state.active
            state.active := false
            _step := 4

// ---- 3.4 Session and window state instances ----
var SessionState asiaState      = SessionState.new()
var SessionState preLondonState = SessionState.new()
var SessionState londonState    = SessionState.new()
var SessionState preNYState     = SessionState.new()
var SessionState nyState        = SessionState.new()  // NY full block 09:30-16:00
var SessionState nyOpenState    = SessionState.new()
var SessionState nyAMState      = SessionState.new()
var SessionState nyLunchState   = SessionState.new()
var SessionState nyPMState      = SessionState.new()

// Asia range H/L extension state — lines persist past session end into London/NY
var line  asiaHiExt  = na
var line  asiaLoExt  = na
var label asiaHiLbl  = na
var label asiaLoLbl  = na
var bool  asiaWasAct = false

var WindowState londonSBState = WindowState.new()
var WindowState nyAMSBState   = WindowState.new()
var WindowState nyPMSBState   = WindowState.new()

// ICT Killzone window states — ICT-defined liquidity windows. Independent of
// the Sessions feature; rendered as separately-colored boxes when enabled.
var WindowState asiaKZState   = WindowState.new()
var WindowState londonKZState = WindowState.new()
var WindowState nyAMKZState   = WindowState.new()
var WindowState nyPMKZState   = WindowState.new()

var WindowState lonMacro1State     = WindowState.new()
var WindowState lonMacro2State     = WindowState.new()
var WindowState nyMacro1State      = WindowState.new()
var WindowState nyMacro2State      = WindowState.new()
var WindowState nyMacro3State      = WindowState.new()
var WindowState nyLunchMacroState  = WindowState.new()
var WindowState nyPMMacroState     = WindowState.new()
var WindowState lastHourMacroState = WindowState.new()

// ---- 3.5 Per-bar session updates ----
sessionsOn = showSessions

// Sessions use actual MARKET HOURS (NY local time, DST-aware via America/New_York).
// London = 03:00 NY = 08:00 BST/GMT (London cash open). NY = 09:30 NY (NYSE open).
// For ICT killzone windows (02-05 London, 07-10 NY etc.), use the ICT Killzones
// feature group below — those are separately toggleable.
f_update_session(asiaState,      sessionsOn and showAsia,      19,  0,  2,  0, asiaColor,      "Asia")
f_update_session(preLondonState, sessionsOn and showPreLondon,  2,  0,  3,  0, preLondonColor, "Pre-London")
f_update_session(londonState,    sessionsOn and showLondon,     3,  0,  9, 30, londonColor,    "London")
f_update_session(preNYState,     sessionsOn and showPreNY,      8,  0,  9, 30, preNYColor,     "Pre-NY")
// Combined NY block (default ON) — NYSE cash session 09:30-16:00 NY.
f_update_session(nyState,        sessionsOn and showNY,         9, 30, 16,  0, nyColor,        "NY")
// Granular NY sub-sessions (all default OFF) — opt-in killzone-level detail.
f_update_session(nyOpenState,    sessionsOn and showNYOpen,     9, 30, 11,  0, nyColor,        "NY Open")
f_update_session(nyAMState,      sessionsOn and showNYAM,       9, 30, 12,  0, nyAMColor,      "NY AM")
f_update_session(nyLunchState,   sessionsOn and showNYLunch,   12,  0, 13, 30, nyLunchColor,   "Lunch")
f_update_session(nyPMState,      sessionsOn and showNYPM,      13, 30, 16,  0, nyPMColor,      "NY PM")

// ---- 3.5b Asia H/L extension lines ----
// Dashed AsiaH / AsiaL lines that appear after Asia closes and extend into
// London + NY sessions as reference levels for stop hunts and liquidity draws.
// Lines are deleted when the next Asia session starts (stale level gone).
if not (sessionsOn and showAsiaHL)
    if not na(asiaHiExt)
        line.delete(asiaHiExt)
        asiaHiExt := na
    if not na(asiaLoExt)
        line.delete(asiaLoExt)
        asiaLoExt := na
    if not na(asiaHiLbl)
        label.delete(asiaHiLbl)
        asiaHiLbl := na
    if not na(asiaLoLbl)
        label.delete(asiaLoLbl)
        asiaLoLbl := na
else
    if asiaState.active and not asiaWasAct
        // New Asia session started — clear yesterday's extension lines
        if not na(asiaHiExt)
            line.delete(asiaHiExt)
            asiaHiExt := na
        if not na(asiaLoExt)
            line.delete(asiaLoExt)
            asiaLoExt := na
        if not na(asiaHiLbl)
            label.delete(asiaHiLbl)
            asiaHiLbl := na
        if not na(asiaLoLbl)
            label.delete(asiaLoLbl)
            asiaLoLbl := na
    if not asiaState.active and asiaWasAct and not na(asiaState.hi)
        // Session just ended — spawn extension lines from the close bar
        asiaHiExt := line.new(bar_index, asiaState.hi, bar_index + rightExtBars, asiaState.hi,
             color = asiaColor, style = line.style_dashed, width = 1)
        asiaLoExt := line.new(bar_index, asiaState.lo, bar_index + rightExtBars, asiaState.lo,
             color = asiaColor, style = line.style_dashed, width = 1)
        asiaHiLbl := label.new(bar_index + rightExtBars, asiaState.hi, "AsiaH",
             style = label.style_label_left, color = color.new(asiaColor, 80),
             textcolor = asiaColor, size = size.tiny)
        asiaLoLbl := label.new(bar_index + rightExtBars, asiaState.lo, "AsiaL",
             style = label.style_label_left, color = color.new(asiaColor, 80),
             textcolor = asiaColor, size = size.tiny)
    if not na(asiaHiExt)
        // Every bar — push right edge forward
        line.set_x2(asiaHiExt, bar_index + rightExtBars)
        line.set_x2(asiaLoExt, bar_index + rightExtBars)
        label.set_x(asiaHiLbl, bar_index + rightExtBars)
        label.set_x(asiaLoLbl, bar_index + rightExtBars)
asiaWasAct := asiaState.active

sbTransp    = math.max(math.min(sessionTransp -  5, 100), 0)   // [0,100], slightly more visible than sessions
macroTransp = math.max(math.min(sessionTransp + 5, 100), 0)    // [0,100], slightly more transparent
kzTransp    = math.max(math.min(sessionTransp - 10, 100), 0)   // [0,100], more visible — killzones are the focus when enabled

// ICT Killzone windows — toggled via showKillzones master + per-window flags.
// Asia 20-00 NY uses (20,0,0,0) which f_is_in_session handles via OR semantics.
f_update_window(asiaKZState,   showKillzones_eff and showAsiaKZ,   20,  0,  0,  0, killzoneColor, kzTransp)
f_update_window(londonKZState, showKillzones_eff and showLondonKZ,  2,  0,  5,  0, killzoneColor, kzTransp)
f_update_window(nyAMKZState,   showKillzones_eff and showNYAMKZ,    7,  0, 10,  0, killzoneColor, kzTransp)
f_update_window(nyPMKZState,   showKillzones_eff and showNYPMKZ,   13, 30, 16,  0, killzoneColor, kzTransp)

f_update_window(londonSBState, showSilverBullet_eff,  3,  0,  4,  0, SB_COLOR, sbTransp)
f_update_window(nyAMSBState,   showSilverBullet_eff, 10,  0, 11,  0, SB_COLOR, sbTransp)
f_update_window(nyPMSBState,   showSilverBullet_eff, 14,  0, 15,  0, SB_COLOR, sbTransp)

f_update_window(lonMacro1State,     showICTMacros_eff,  2, 33,  3,  0, MACRO_COLOR, macroTransp)
f_update_window(lonMacro2State,     showICTMacros_eff,  4,  3,  4, 30, MACRO_COLOR, macroTransp)
f_update_window(nyMacro1State,      showICTMacros_eff,  8, 50,  9, 10, MACRO_COLOR, macroTransp)
f_update_window(nyMacro2State,      showICTMacros_eff,  9, 50, 10, 10, MACRO_COLOR, macroTransp)
f_update_window(nyMacro3State,      showICTMacros_eff, 10, 50, 11, 10, MACRO_COLOR, macroTransp)
f_update_window(nyLunchMacroState,  showICTMacros_eff, 11, 50, 12, 10, MACRO_COLOR, macroTransp)
f_update_window(nyPMMacroState,     showICTMacros_eff, 13, 10, 13, 40, MACRO_COLOR, macroTransp)
f_update_window(lastHourMacroState, showICTMacros_eff, 15, 15, 15, 45, MACRO_COLOR, macroTransp)


//=============================================================================
// SECTION 4 — MARKET STRUCTURE ENGINE (BOS / CHoCH / SWINGS)
//=============================================================================
// Two independent layers — Internal (short-term) and Swing (longer-term).
// Each runs its own pivot detection (ta.pivothigh / ta.pivotlow) and its
// own bias state machine.
//
// Bias rules:
//   bias = 0  : no break has happened yet
//   bias = 1  : last break was upward
//   bias = -1 : last break was downward
//
// On upward break of stored pivot high:
//   bias was -1 → CHoCH (bullish)
//   bias was  0 → BOS  (establishing bullish bias)
//   bias was  1 → BOS  (continuation)
// Mirror for downward break of stored pivot low.
//
// confirmMode = "Close" : break needs close beyond level
// confirmMode = "Wick"  : any wick penetration counts

// 4.1 Pivots — two real SMC tiers:
// Internal pivots print iBOS/iCHoCH; external pivots print BOS/CHoCH.
intPivotH = ta.pivothigh(intLeftBars, intRightBars)
intPivotL = ta.pivotlow(intLeftBars,  intRightBars)
swgPivotH = ta.pivothigh(swgLeftBars, swgRightBars)
swgPivotL = ta.pivotlow(swgLeftBars,  swgRightBars)

// 4.2 Per-layer state
type StructState
    int   bias    = 0
    float ph      = na
    float pl      = na
    int   phBar   = na
    int   plBar   = na
    float prevPH  = na
    float prevPL  = na
    int   prevPHBar = na
    int   prevPLBar = na
    float protH  = na
    float protL  = na
    int   protHBar = na
    int   protLBar = na
    float extH   = na
    float extL   = na
    int   extHBar = na
    int   extLBar = na
    bool  bullBreakNow = false
    bool  bearBreakNow = false
    int   bullBreakLevelBar = na
    int   bearBreakLevelBar = na
    float bullBreakLevel = na
    float bearBreakLevel = na

var StructState intStruct = StructState.new()
var StructState swgStruct = StructState.new()
var bool intBullCounterSinceSwg = false
var bool intBearCounterSinceSwg = false
var float lastSwgBullBosLevel = na
var float lastSwgBearBosLevel = na
var int   lastSwgBullBosBar = na
var int   lastSwgBearBosBar = na

STRUCT_LINE_CAP  = 160
STRUCT_LABEL_CAP = 160
var array<line>  structLines  = array.new<line>()
var array<label> structLabels = array.new<label>()

// 4.3 Break thresholds
breakUpVal   = confirmMode == "Close" ? close : high
breakDownVal = confirmMode == "Close" ? close : low
strictStructure = structureValidation == "Strict SMC"
smcStructATR = ta.atr(14)

// Strict SMC mother-candle filter: while price remains inside a containing
// candle, minor range breaks are liquidity noise rather than BOS/CHoCH.
var float motherHigh = na
var float motherLow  = na
var int   motherBar  = na
insidePrevCandle = high <= high[1] and low >= low[1]
newMotherRange = na(motherHigh) ? true : (high[1] > motherHigh or low[1] < motherLow)
if smcMotherFilter and insidePrevCandle and newMotherRange
    motherHigh := high[1]
    motherLow  := low[1]
    motherBar  := bar_index - 1

f_smc_break_ok(StructState state, int dir, float target, int targetBar, bool isInternal) =>
    if not strictStructure
        true
    else
        targetOk = not na(target) and not na(targetBar)
        if not targetOk
            false
        else
            legMin = smcStructATR * (isInternal ? smcMinLegATR * 0.5 : smcMinLegATR)
            oppLow = not na(state.pl) ? state.pl : (not isInternal ? intStruct.pl : na)
            oppLowBar = not na(state.plBar) ? state.plBar : (not isInternal ? intStruct.plBar : na)
            oppHigh = not na(state.ph) ? state.ph : (not isInternal ? intStruct.ph : na)
            oppHighBar = not na(state.phBar) ? state.phBar : (not isInternal ? intStruct.phBar : na)
            legSpan = dir == 1 and not na(oppLow) ? math.abs(target - oppLow) : dir == -1 and not na(oppHigh) ? math.abs(oppHigh - target) : na
            legOk = not na(legSpan) and legSpan >= legMin
            pullbackOk = smcRequireInducement ? (dir == 1 ? (not na(oppLowBar) and oppLowBar > targetBar) : (not na(oppHighBar) and oppHighBar > targetBar)) : true
            bufferOk = dir == 1 ? breakUpVal > target + smcStructATR * smcBreakBufferATR : breakDownVal < target - smcStructATR * smcBreakBufferATR
            motherOk = smcMotherFilter and not na(motherHigh) ? (dir == 1 ? breakUpVal > motherHigh : breakDownVal < motherLow) : true
            legOk and pullbackOk and bufferOk and motherOk

// 4.4 Render HH/HL/LH/LL classification text at a pivot bar.
// Triangle fractal markers are drawn via plotshape in section 4.8 — using
// plotshape produces proper solid filled triangles (Williams Fractal style)
// rather than the filled label containers that label.style_triangledown yields.
f_render_pivot(int barX, float price, bool isHigh, bool isHigherThanPrev, bool isInternal, bool shouldDraw) =>
    markerSize = isInternal ? size.tiny : size.small
    classColor  = isHigherThanPrev ? bullColor : bearColor

    // HH/HL/LH/LL text — ATR-offset above/below the pivot so it doesn't
    // sit on top of the plotshape fractal marker.
    if shouldDraw and showHHHL_eff and not na(barX) and not na(price)
        cls    = isHigh ? (isHigherThanPrev ? "HH" : "LH") : (isHigherThanPrev ? "HL" : "LL")
        atrOff = smcStructATR * 0.5
        textY  = isHigh ? price + atrOff : price - atrOff
        lbl = label.new(barX, textY, cls,
             style     = label.style_none,
             textcolor = classColor,
             size      = markerSize)
        f_track_label(structLabels, lbl, STRUCT_LABEL_CAP)

// Draw a fractal connector — a dotted line between the previous pivot and the
// new pivot of the same direction. Color reflects the structural movement
// (higher = bullColor, lower = bearColor). Width thicker for swing layer.
f_draw_swing_connector(int prevBar, float prevPrice, int curBar, float curPrice,
                        bool isHigherThanPrev, bool isInternal) =>
    if showSwingLines_eff and not na(prevBar) and not na(prevPrice)
        ln = line.new(prevBar, prevPrice, curBar, curPrice,
             color = isHigherThanPrev ? bullColor : bearColor,
             style = line.style_dotted,
             width = isInternal ? 1 : 2)
        f_track_line(structLines, ln, STRUCT_LINE_CAP)

// 4.5 Render a structure-break event (BOS or CHoCH)
//   typ:        "BOS" or "CHoCH"
//   dir:        1 (bullish break) or -1 (bearish break)
//   isInternal: dashed line, "i"-prefixed label, smaller text
//   fromBar:    bar of the broken pivot
//   toBar:      current bar (where the break is confirmed)
//   breakPrice: pivot price that was broken
//
// Swing-layer labels render at size.normal with a tinted background so they
// stand out above HH/HL fractal text. Internal-layer keeps size.tiny so it
// stays visually subordinate to the swing layer.
f_draw_break(string typ, int dir, bool isInternal, int fromBar, int toBar, float breakPrice) =>
    txt       = isInternal ? "i" + typ : typ
    isCHoCH   = typ == "CHoCH"
    lblColor  = isCHoCH ? chochColor : (dir == 1 ? bullColor : bearColor)
    lineStyle = isInternal ? line.style_dashed : line.style_solid
    lblSize   = isInternal ? size.tiny : size.normal
    lblBg     = isInternal ? color.new(color.white, 100) : color.new(lblColor, 70)

    ln = line.new(fromBar, breakPrice, toBar, breakPrice,
         color = lblColor,
         style = lineStyle,
         width = isInternal ? 1 : 2)
    f_track_line(structLines, ln, STRUCT_LINE_CAP)

    // Label sits at the MIDPOINT of the break line, centered between the
    // broken pivot and the break candle. Reads as a caption on the line
    // rather than a marker stuck at one end.
    midBar = math.round(0.5 * (fromBar + toBar))
    lbl = label.new(midBar, breakPrice, txt,
         style     = dir == 1 ? label.style_label_down : label.style_label_up,
         color     = lblBg,
         textcolor = lblColor,
         size      = lblSize)
    f_track_label(structLabels, lbl, STRUCT_LABEL_CAP)

// 4.6 Run one tier's state machine.
f_update_structure(StructState state, float pivotH, float pivotL, int rightBars, bool isInternal,
                   bool suppressBullLabel, bool suppressBearLabel) =>
    state.bullBreakNow := false
    state.bearBreakNow := false
    state.bullBreakLevel := na
    state.bearBreakLevel := na

    layerShow         = showStructure and (isInternal ? showInternal : showSwing)
    layerShowDetailed = layerShow and htfPass

    preBias = state.bias
    prePH = state.ph
    prePL = state.pl
    prePHBar = state.phBar
    prePLBar = state.plBar
    preProtH = state.protH
    preProtL = state.protL
    preProtHBar = state.protHBar
    preProtLBar = state.protLBar
    preExtH = state.extH
    preExtL = state.extL
    preExtHBar = state.extHBar
    preExtLBar = state.extLBar
    usingProtectedBullTarget = strictStructure and preBias == -1 and not na(preProtH)
    usingProtectedBearTarget = strictStructure and preBias ==  1 and not na(preProtL)
    usingLockedBullTarget = strictStructure and not isInternal and preBias ==  1 and not usingProtectedBullTarget
    usingLockedBearTarget = strictStructure and not isInternal and preBias == -1 and not usingProtectedBearTarget
    preBullTarget = usingProtectedBullTarget ? preProtH : usingLockedBullTarget ? (not na(preExtH) ? preExtH : prePH) : prePH
    preBullTargetBar = usingProtectedBullTarget ? preProtHBar : usingLockedBullTarget ? (not na(preExtHBar) ? preExtHBar : prePHBar) : prePHBar
    preBearTarget = usingProtectedBearTarget ? preProtL : usingLockedBearTarget ? (not na(preExtL) ? preExtL : prePL) : prePL
    preBearTargetBar = usingProtectedBearTarget ? preProtLBar : usingLockedBearTarget ? (not na(preExtLBar) ? preExtLBar : prePLBar) : prePLBar

    int   renderHighBar    = na
    float renderHighPrice  = na
    bool  renderHighHigher = false
    bool  renderHighNow    = false
    int   renderLowBar     = na
    float renderLowPrice   = na
    bool  renderLowHigher  = false
    bool  renderLowNow     = false

    if not na(pivotH)
        state.prevPH    := state.ph
        state.prevPHBar := state.phBar
        state.ph        := pivotH
        state.phBar     := bar_index - rightBars
        renderHighBar    := state.phBar
        renderHighPrice  := pivotH
        renderHighHigher := na(state.prevPH) ? true : pivotH > state.prevPH
        renderHighNow    := layerShowDetailed
        if layerShowDetailed
            f_draw_swing_connector(state.prevPHBar, state.prevPH, state.phBar, pivotH, renderHighHigher, isInternal)
    f_render_pivot(renderHighBar, renderHighPrice, true, renderHighHigher, isInternal, renderHighNow)

    if not na(pivotL)
        state.prevPL    := state.pl
        state.prevPLBar := state.plBar
        state.pl        := pivotL
        state.plBar     := bar_index - rightBars
        renderLowBar    := state.plBar
        renderLowPrice  := pivotL
        renderLowHigher := na(state.prevPL) ? true : pivotL > state.prevPL
        renderLowNow    := layerShowDetailed
        if layerShowDetailed
            f_draw_swing_connector(state.prevPLBar, state.prevPL, state.plBar, pivotL, renderLowHigher, isInternal)
    f_render_pivot(renderLowBar, renderLowPrice, false, renderLowHigher, isInternal, renderLowNow)

    bullTarget    = preBullTarget
    bullTargetBar = preBullTargetBar
    bearTarget    = preBearTarget
    bearTargetBar = preBearTargetBar
    bullRawBreak  = na(bullTarget) ? false : breakUpVal > bullTarget
    bearRawBreak  = na(bearTarget) ? false : breakDownVal < bearTarget
    dualSideBreak = strictStructure and bullRawBreak and bearRawBreak
    contextBias   = isInternal and strictStructure and swgStruct.bias != 0 ? swgStruct.bias : preBias
    sameLevelTol = math.max(smcStructATR * smcBreakBufferATR, syminfo.mintick * 2)
    sameBarBullSwingLevel = isInternal and suppressBullLabel
    sameBarBearSwingLevel = isInternal and suppressBearLabel

    if bullRawBreak and not dualSideBreak and barstate.isconfirmed and f_smc_break_ok(state, 1, bullTarget, bullTargetBar, isInternal)
        isCHoCH = strictStructure ? (isInternal and swgStruct.bias != 0 ? (contextBias == -1 and not intBullCounterSinceSwg) : usingProtectedBullTarget) : contextBias == -1
        if layerShow and not sameBarBullSwingLevel and barstate.isconfirmed
            typ = isCHoCH ? "CHoCH" : "BOS"
            showThisBreak = isCHoCH ? showCHoCH : showBOS
            if showThisBreak
                f_draw_break(typ, 1, isInternal, bullTargetBar, bar_index, bullTarget)
        state.bullBreakNow      := true
        state.bullBreakLevelBar := bullTargetBar
        state.bullBreakLevel    := bullTarget
        protLow = not na(state.pl) ? state.pl : (not isInternal ? intStruct.pl : na)
        protLowBar = not na(state.plBar) ? state.plBar : (not isInternal ? intStruct.plBar : na)
        if not na(protLow)
            state.protL := protLow
            state.protLBar := protLowBar
        state.protH := na
        state.protHBar := na
        if not isInternal
            state.extH := na
            state.extHBar := na
        state.bias := 1
        state.ph   := na

    if bearRawBreak and not dualSideBreak and barstate.isconfirmed and f_smc_break_ok(state, -1, bearTarget, bearTargetBar, isInternal)
        isCHoCH = strictStructure ? (isInternal and swgStruct.bias != 0 ? (contextBias == 1 and not intBearCounterSinceSwg) : usingProtectedBearTarget) : contextBias == 1
        if layerShow and not sameBarBearSwingLevel and barstate.isconfirmed
            typ = isCHoCH ? "CHoCH" : "BOS"
            showThisBreak = isCHoCH ? showCHoCH : showBOS
            if showThisBreak
                f_draw_break(typ, -1, isInternal, bearTargetBar, bar_index, bearTarget)
        state.bearBreakNow      := true
        state.bearBreakLevelBar := bearTargetBar
        state.bearBreakLevel    := bearTarget
        protHigh = not na(state.ph) ? state.ph : (not isInternal ? intStruct.ph : na)
        protHighBar = not na(state.phBar) ? state.phBar : (not isInternal ? intStruct.phBar : na)
        if not na(protHigh)
            state.protH := protHigh
            state.protHBar := protHighBar
        state.protL := na
        state.protLBar := na
        if not isInternal
            state.extL := na
            state.extLBar := na
        state.bias := -1
        state.pl   := na

// 4.7 Per-bar updates — external runs first; internal can dedupe same-level breaks.
preSwgBiasForBreak = swgStruct.bias
f_update_structure(swgStruct, swgPivotH, swgPivotL, swgRightBars, false, false, false)

if swgStruct.bullBreakNow and preSwgBiasForBreak != -1
    lastSwgBullBosLevel := swgStruct.bullBreakLevel
    lastSwgBullBosBar := bar_index
if swgStruct.bearBreakNow and preSwgBiasForBreak != 1
    lastSwgBearBosLevel := swgStruct.bearBreakLevel
    lastSwgBearBosBar := bar_index

promoteBuffer = smcStructATR * math.max(smcBreakBufferATR, 0.05)
promoteBullToExternal = strictStructure and not swgStruct.bullBreakNow and swgStruct.bias == 1 and not na(lastSwgBullBosLevel) and not na(intStruct.ph) and breakUpVal > intStruct.ph and intStruct.ph > lastSwgBullBosLevel + promoteBuffer
promoteBearToExternal = strictStructure and not swgStruct.bearBreakNow and swgStruct.bias == -1 and not na(lastSwgBearBosLevel) and not na(intStruct.pl) and breakDownVal < intStruct.pl and intStruct.pl < lastSwgBearBosLevel - promoteBuffer

f_update_structure(intStruct, intPivotH, intPivotL, intRightBars, true,
                   swgStruct.bullBreakNow or promoteBullToExternal,
                   swgStruct.bearBreakNow or promoteBearToExternal)

if promoteBullToExternal and intStruct.bullBreakNow and not na(intStruct.bullBreakLevel)
    if showStructure and showSwing and showBOS
        f_draw_break("BOS", 1, false, intStruct.bullBreakLevelBar, bar_index, intStruct.bullBreakLevel)
    swgStruct.bullBreakNow := true
    swgStruct.bullBreakLevelBar := intStruct.bullBreakLevelBar
    swgStruct.bullBreakLevel := intStruct.bullBreakLevel
    swgStruct.bias := 1
    swgStruct.ph := na
    if not na(intStruct.protL)
        swgStruct.protL := intStruct.protL
        swgStruct.protLBar := intStruct.protLBar
    swgStruct.protH := na
    swgStruct.protHBar := na
    lastSwgBullBosLevel := intStruct.bullBreakLevel
    lastSwgBullBosBar := bar_index

if promoteBearToExternal and intStruct.bearBreakNow and not na(intStruct.bearBreakLevel)
    if showStructure and showSwing and showBOS
        f_draw_break("BOS", -1, false, intStruct.bearBreakLevelBar, bar_index, intStruct.bearBreakLevel)
    swgStruct.bearBreakNow := true
    swgStruct.bearBreakLevelBar := intStruct.bearBreakLevelBar
    swgStruct.bearBreakLevel := intStruct.bearBreakLevel
    swgStruct.bias := -1
    swgStruct.pl := na
    if not na(intStruct.protH)
        swgStruct.protH := intStruct.protH
        swgStruct.protHBar := intStruct.protHBar
    swgStruct.protL := na
    swgStruct.protLBar := na
    lastSwgBearBosLevel := intStruct.bearBreakLevel
    lastSwgBearBosBar := bar_index

if swgStruct.bullBreakNow
    intBearCounterSinceSwg := false
if swgStruct.bearBreakNow
    intBullCounterSinceSwg := false
if intStruct.bullBreakNow and swgStruct.bias == -1 and not swgStruct.bearBreakNow
    intBullCounterSinceSwg := true
if intStruct.bearBreakNow and swgStruct.bias == 1 and not swgStruct.bullBreakNow
    intBearCounterSinceSwg := true
if intBullCounterSinceSwg and swgStruct.bias == -1 and not na(swgStruct.pl)
    if na(swgStruct.extL) or swgStruct.pl < swgStruct.extL
        swgStruct.extL := swgStruct.pl
        swgStruct.extLBar := swgStruct.plBar
if intBearCounterSinceSwg and swgStruct.bias == 1 and not na(swgStruct.ph)
    if na(swgStruct.extH) or swgStruct.ph > swgStruct.extH
        swgStruct.extH := swgStruct.ph
        swgStruct.extHBar := swgStruct.phBar

if not na(motherHigh) and (close > motherHigh or close < motherLow)
    motherHigh := na
    motherLow  := na
    motherBar  := na

// 4.8 Fractal markers — Unicode triangle characters via plotchar.
// All four render on every TF (NO htfPass gate). plotchar at size.tiny
// gives a marker noticeably smaller than plotshape size.tiny but still
// readable on 1m / 5m. ▲ / ▼ are the larger Unicode triangles (vs ▴/▾
// which are the "small triangle" variants — those rendered too tiny).
//
// Direction convention (user-requested 2026-04-28):
//   ▲ above swing high — points UP toward the high
//   ▼ below swing low  — points DOWN toward the low
// Reads naturally: "the marker points to the extreme it sits next to."
//
// Colors are dedicated inputs (fractalBullColor / fractalBearColor) so
// fractals stay visually distinct from BOS/CHoCH structure colors.
plotchar(showStructure and showSwing    and showSwingPoints and not na(swgPivotH),
         char="▲", location=location.abovebar,
         offset=-swgRightBars, color=fractalBearColor, size=size.tiny,
         title="Swing High Fractal",    display=display.pane)
plotchar(showStructure and showSwing    and showSwingPoints and not na(swgPivotL),
         char="▼", location=location.belowbar,
         offset=-swgRightBars, color=fractalBullColor, size=size.tiny,
         title="Swing Low Fractal",     display=display.pane)
plotchar(showStructure and showInternal and showSwingPoints and not na(intPivotH),
         char="▲", location=location.abovebar,
         offset=-intRightBars, color=fractalBearColor, size=size.tiny,
         title="Internal High Fractal", display=display.pane)
plotchar(showStructure and showInternal and showSwingPoints and not na(intPivotL),
         char="▼", location=location.belowbar,
         offset=-intRightBars, color=fractalBullColor, size=size.tiny,
         title="Internal Low Fractal",  display=display.pane)


//=============================================================================
// SECTION 5 — ORDER BLOCK ENGINE (OBs + BREAKER BLOCKS)
//=============================================================================
// OBs are spawned from swing-level structure breaks (swgStruct.bullBreakNow /
// bearBreakNow). For a bullish break, the OB is the last bearish candle
// preceding the break; the zone runs from that candle's open (top) down to
// its low (bottom). Mirror for bearish.
//
// Lifecycle:
//   active OB  →  mitigated (close past 50% midline) → breaker (role flips, dashed border)
//   breaker    →  invalidated (close past zone's far extreme) → deleted
//
// Cap: maxOBs active OBs per side. Oldest active is array.shift'd off when
// a new OB pushes us over.

// 5.1 OB / breaker zone state
type OBZone
    box   bx
    label lbl
    float top
    float bottom
    int   originBar      // bar_index of the OB candle
    bool  origBull       // original direction (true = was bullish OB)
    bool  mitigated = false

var array<OBZone> activeBullOBs = array.new<OBZone>()
var array<OBZone> activeBearOBs = array.new<OBZone>()
var array<OBZone> bullBreakers  = array.new<OBZone>()  // from mitigated bearish OBs
var array<OBZone> bearBreakers  = array.new<OBZone>()  // from mitigated bullish OBs

OB_SCAN_LOOKBACK = 50  // how far back to scan for the OB candle

// 5.2 Find the OB candle's offset from the current bar
//   isBullishOB = true  → look for last bearish candle (close < open)
//   isBullishOB = false → look for last bullish candle (close > open)
// Returns offset in bars (1..OB_SCAN_LOOKBACK) or 0 if none found.
f_find_ob_offset(bool isBullishOB) =>
    int found = 0
    for i = 1 to OB_SCAN_LOOKBACK
        candleBearish = close[i] < open[i]
        match = isBullishOB ? candleBearish : not candleBearish
        if match and found == 0
            found := i
    found

// 5.3 Render a zone (active OB or breaker)
//   role = 0: active bullish OB (green, solid border, "OB")
//   role = 1: active bearish OB (red,   solid border, "OB")
//   role = 2: bullish breaker  (green, dashed border, "BB")  — from mitigated bear OB
//   role = 3: bearish breaker  (red,   dashed border, "BB")  — from mitigated bull OB
f_render_zone_visuals(OBZone z, int role) =>
    isBullRole = role == 0 or role == 2
    isBreaker  = role == 2 or role == 3
    fillColor  = isBullRole ? bullOBColor : bearOBColor
    bord       = isBreaker  ? line.style_dashed : line.style_solid
    txt        = isBreaker  ? "BB" : "OB"

    if not na(z.bx)
        box.set_bgcolor(z.bx,      f_alpha(fillColor, obTransp))
        box.set_border_color(z.bx, f_alpha(fillColor, math.max(obTransp - 30, 0)))
        box.set_border_style(z.bx, bord)

    if not na(z.lbl)
        if showOBLabels
            label.set_text(z.lbl, txt)
            label.set_textcolor(z.lbl, fillColor)
            label.set_color(z.lbl, color.new(color.white, 100))
        else
            label.set_text(z.lbl, "")

// 5.4 Create a new OB from a swing break event
f_create_ob(bool isBullish) =>
    int obOffset = f_find_ob_offset(isBullish)
    if obOffset > 0
        obBar = bar_index - obOffset
        topPx    = isBullish ? open[obOffset]  : high[obOffset]
        bottomPx = isBullish ? low[obOffset]   : open[obOffset]

        z = OBZone.new(na, na, topPx, bottomPx, obBar, isBullish, false)
        tmpBox = box.new(obBar, topPx, bar_index, bottomPx,
             bgcolor      = f_alpha(isBullish ? bullOBColor : bearOBColor, obTransp),
             border_color = f_alpha(isBullish ? bullOBColor : bearOBColor, math.max(obTransp - 30, 0)),
             border_style = line.style_solid,
             xloc         = xloc.bar_index)
        z.bx := tmpBox
        tmpLbl = label.new(bar_index, isBullish ? topPx : bottomPx,
             showOBLabels ? "OB" : "",
             style     = isBullish ? label.style_label_left : label.style_label_left,
             color     = color.new(color.white, 100),
             textcolor = isBullish ? bullOBColor : bearOBColor,
             size      = size.tiny,
             xloc      = xloc.bar_index,
             tooltip   = "Order Block — institutional supply/demand zone. Becomes a Breaker Block when mitigated.")
        z.lbl := tmpLbl

        targetArr = isBullish ? activeBullOBs : activeBearOBs
        array.push(targetArr, z)

        // Cap to maxOBs — drop oldest active on this side
        while array.size(targetArr) > maxOBs
            old = array.shift(targetArr)
            if not na(old.bx)
                box.delete(old.bx)
            if not na(old.lbl)
                label.delete(old.lbl)

// 5.5 Tear down a zone's draws and return whether to keep referencing it
f_delete_zone(OBZone z) =>
    if not na(z.bx)
        box.delete(z.bx)
    if not na(z.lbl)
        label.delete(z.lbl)

// 5.6 Iterate active OBs of one direction → check for mitigation, convert to breaker
f_check_active_obs(array<OBZone> activeArr, array<OBZone> breakerArr, bool isBullish) =>
    int i = 0
    _step = 0
    while i < array.size(activeArr)
        z = array.get(activeArr, i)
        midline = (z.top + z.bottom) / 2
        // Bullish OB mitigated when close < midline
        // Bearish OB mitigated when close > midline
        mitigatedNow = not z.mitigated and (isBullish ? (close < midline) : (close > midline))

        // Pine v6 CE10235: every branch of this if/else (and its inner if/else)
        // must return the same type. The shared `_step` sentinel makes the
        // construct evaluate to int consistently.
        if z.mitigated and not showMitigatedOB
            f_delete_zone(z)
            array.remove(activeArr, i)
            _step := 1
        else if mitigatedNow
            if showBreakers and showOBs
                array.remove(activeArr, i)
                // Convert: bullish OB → bearish breaker (role 3); bearish OB → bullish breaker (role 2)
                breakerRole = isBullish ? 3 : 2
                f_render_zone_visuals(z, breakerRole)
                array.push(breakerArr, z)
                _step := 2
            else if showMitigatedOB
                z.mitigated := true
                mitigatedColor = color.gray
                if not na(z.bx)
                    box.set_bgcolor(z.bx, f_alpha(isBullish ? bullOBColor : bearOBColor, 95))
                    box.set_border_color(z.bx, mitigatedColor)
                    box.set_border_style(z.bx, line.style_dashed)
                if not na(z.lbl)
                    label.set_text(z.lbl, showOBLabels ? "M-OB" : "")
                    label.set_textcolor(z.lbl, mitigatedColor)
                i += 1
                _step := 3
            else
                array.remove(activeArr, i)
                f_delete_zone(z)
                _step := 4
        else
            // Extend right edge and refresh label text so the showOBLabels toggle is live.
            if not na(z.bx)
                box.set_right(z.bx, bar_index)
            if not na(z.lbl)
                label.set_x(z.lbl, bar_index)
                label.set_text(z.lbl, showOBLabels ? (z.mitigated ? "M-OB" : "OB") : "")
            i += 1
            _step := 5

// 5.7 Iterate breakers of one role → check for invalidation, delete if so
//   isBullishBreaker = true  → invalidated when close < zone bottom
//   isBullishBreaker = false → invalidated when close > zone top
f_check_breakers(array<OBZone> breakerArr, bool isBullishBreaker) =>
    int i = 0
    _step = 0
    while i < array.size(breakerArr)
        z = array.get(breakerArr, i)
        invalid = isBullishBreaker ? (close < z.bottom) : (close > z.top)
        // Pine v6 CE10235: align both if/else branches' return types via sentinel.
        if invalid
            f_delete_zone(z)
            array.remove(breakerArr, i)
            _step := 1
        else
            if not na(z.bx)
                box.set_right(z.bx, bar_index)
            if not na(z.lbl)
                label.set_x(z.lbl, bar_index)
                label.set_text(z.lbl, showOBLabels ? "BB" : "")
            i += 1
            _step := 2

// 5.8 Master cleanup when showOBs is false
f_clear_zones(array<OBZone> arr) =>
    while array.size(arr) > 0
        z = array.shift(arr)
        f_delete_zone(z)

// 5.9 Per-bar dispatch
if not showOBs
    f_clear_zones(activeBullOBs)
    f_clear_zones(activeBearOBs)
    f_clear_zones(bullBreakers)
    f_clear_zones(bearBreakers)
else
    // 1) Spawn new OBs from swing breaks (only if direction is enabled)
    if swgStruct.bullBreakNow and showBullOB
        f_create_ob(true)
    if swgStruct.bearBreakNow and showBearOB
        f_create_ob(false)

    // 2) Update active OBs — check mitigation, extend boxes
    f_check_active_obs(activeBullOBs, bearBreakers, true)
    f_check_active_obs(activeBearOBs, bullBreakers, false)

    // 3) Update breakers — check invalidation, extend boxes
    if showBreakers
        f_check_breakers(bullBreakers, true)
        f_check_breakers(bearBreakers, false)
    else
        f_clear_zones(bullBreakers)
        f_clear_zones(bearBreakers)


//=============================================================================
// SECTION 6 — FVG ENGINE (FVG + iFVG + CE)
//=============================================================================
// 3-candle imbalance detection on every confirmed bar:
//   bullish: low > high[2]   → zone [high[2], low]
//   bearish: high < low[2]   → zone [high, low[2]]
// Auto-threshold filter: zone size must be ≥ ta.atr(14) * minFVGSize.
//
// Lifecycle:
//   phase 0 (active)     → unmitigated, original color
//   phase 1 (partial)    → price entered zone but hasn't crossed CE
//   phase 2 (mitigated)  → close past CE midline
//   phase 3 (inverted)   → close past far extreme → flips role to iFVG
//
// CE line is dotted, drawn at the 50% midline.

// 6.1 FVG state
type FVG
    box   bx
    line  ceLine
    label lbl
    float top
    float bottom
    int   originBar
    int   phase = 0      // 0 active, 1 partial, 2 mitigated, 3 inverted (iFVG)
    bool  origBull = true

var array<FVG> fvgs = array.new<FVG>()

// 6.2 Detection inputs (recomputed every bar)
fvgATR        = ta.atr(14)
isBullFVG     = low > high[2]
isBearFVG     = high < low[2]
bullFVGSize   = low - high[2]
bearFVGSize   = low[2] - high
minFVGSizePx  = fvgATR * minFVGSize

// 6.3 Create a new FVG and push it into the array (oldest auto-evicted by cap)
f_create_fvg(bool isBullish, float topPx, float bottomPx) =>
    fillColor = isBullish ? bullFVGColor : bearFVGColor
    midPx     = (topPx + bottomPx) / 2

    bx = box.new(bar_index - 2, topPx, bar_index, bottomPx,
         bgcolor      = f_alpha(fillColor, fvgTransp),
         border_color = f_alpha(fillColor, math.max(fvgTransp - 30, 0)),
         xloc         = xloc.bar_index)

    ceLine = line.new(bar_index - 2, midPx, bar_index, midPx,
         color = fillColor,
         style = line.style_dotted,
         xloc  = xloc.bar_index)

    lbl = label.new(bar_index, midPx, "",
         style     = label.style_label_right,
         color     = color.new(color.white, 100),
         textcolor = fillColor,
         size      = size.tiny,
         xloc      = xloc.bar_index)

    f = FVG.new(bx, ceLine, lbl, topPx, bottomPx, bar_index - 2, 0, isBullish)
    array.push(fvgs, f)

    // Cap visible FVGs — drop oldest off the front
    while array.size(fvgs) > maxFVGs
        old = array.shift(fvgs)
        if not na(old.bx)
            box.delete(old.bx)
        if not na(old.ceLine)
            line.delete(old.ceLine)
        if not na(old.lbl)
            label.delete(old.lbl)

// 6.4 Phase-machine for one FVG. Phases are monotonic (only forward).
//   0 active → 1 partial (entered zone) → 2 mitigated (CE crossed)
//   → 3 inverted (full break, now iFVG) → 4 iFVG invalidated (price reclaimed zone)
f_update_fvg(FVG f) =>
    midline = (f.top + f.bottom) / 2

    // Skip the creation bar. A new FVG necessarily contains that same candle's
    // high/low, so updating immediately would mark it "touched" on birth.
    if bar_index > f.originBar + 2
        if f.origBull
            // Bullish FVG: zone is below current price after formation, acts as support.
            if f.phase == 0 and low <= f.top
                f.phase := 1
            if f.phase == 1 and close < midline
                f.phase := 2
            if f.phase == 2 and close < f.bottom
                f.phase := 3
            // bearish iFVG (was bullish FVG) — invalidated when price closes back above the zone
            if f.phase == 3 and close > f.top
                f.phase := 4
        else
            // Bearish FVG: zone above current price, acts as resistance.
            if f.phase == 0 and high >= f.bottom
                f.phase := 1
            if f.phase == 1 and close > midline
                f.phase := 2
            if f.phase == 2 and close > f.top
                f.phase := 3
            // bullish iFVG (was bearish FVG) — invalidated when price closes back below the zone
            if f.phase == 3 and close < f.bottom
                f.phase := 4

// 6.5 Render an FVG given its current phase + visibility toggles
f_render_fvg(FVG f) =>
    isInverted  = f.phase == 3
    isMitigated = f.phase == 2

    fillColor = isInverted ? (f.origBull ? iFVGBearColor : iFVGBullColor) : (f.origBull ? bullFVGColor : bearFVGColor)

    showThisFvg = if isInverted
        showIFVG
    else if isMitigated
        showMitigatedFVG
    else
        f.origBull ? showBullFVG : showBearFVG

    fillTransp   = showThisFvg ? fvgTransp : 100
    borderTransp = showThisFvg ? math.max(fvgTransp - 30, 0) : 100

    if not na(f.bx)
        box.set_bgcolor(f.bx,      f_alpha(fillColor, fillTransp))
        box.set_border_color(f.bx, f_alpha(fillColor, borderTransp))
        box.set_right(f.bx, bar_index)

    if not na(f.ceLine)
        ceVisible = showCE and showThisFvg and not isInverted
        line.set_color(f.ceLine, ceVisible ? fillColor : f_alpha(fillColor, 100))
        line.set_x2(f.ceLine, bar_index)

    if not na(f.lbl)
        // Label shows "FVG" for active/partial/mitigated and "iFVG" once the
        // zone has flipped. Previous behavior left active-phase FVGs label-less,
        // which made the cream zones nearly invisible against the chart.
        lblText = if not showThisFvg
            ""
        else
            isInverted ? "iFVG" : "FVG"
        label.set_x(f.lbl, bar_index)
        label.set_text(f.lbl, lblText)
        label.set_textcolor(f.lbl, fillColor)

// 6.6 Per-bar dispatch (and event tracking for Phase 13 alerts)
fvgTouchEvent = false   // declared at top-level so Phase 13 can read it

if not showFVGs
    while array.size(fvgs) > 0
        old = array.shift(fvgs)
        if not na(old.bx)
            box.delete(old.bx)
        if not na(old.ceLine)
            line.delete(old.ceLine)
        if not na(old.lbl)
            label.delete(old.lbl)
else
    if isBullFVG and showBullFVG and bullFVGSize >= minFVGSizePx
        f_create_fvg(true, low, high[2])
    if isBearFVG and showBearFVG and bearFVGSize >= minFVGSizePx
        f_create_fvg(false, low[2], high)

    int i = 0
    while i < array.size(fvgs)
        f = array.get(fvgs, i)
        prevPhase = f.phase
        f_update_fvg(f)
        if prevPhase == 0 and f.phase == 1
            fvgTouchEvent := true
        // Delete FVGs that should no longer be on the chart:
        //   phase 2 (mitigated) when user has Show Mitigated FVGs off
        //   phase 4 (iFVG invalidated) — always
        deleteFvg = (f.phase == 2 and not showMitigatedFVG) or f.phase == 4
        if deleteFvg
            if not na(f.bx)
                box.delete(f.bx)
            if not na(f.ceLine)
                line.delete(f.ceLine)
            if not na(f.lbl)
                label.delete(f.lbl)
            array.remove(fvgs, i)
        else
            f_render_fvg(f)
            i += 1


//=============================================================================
// SECTION 7 — LIQUIDITY ENGINE (EQH/EQL + SWEEPS + IDM)
//=============================================================================
// EQH/EQL: two+ swing highs (or lows) within tolerance form a horizontal
// liquidity line. New same-direction swings within tolerance EXTEND an
// existing line rather than creating a duplicate.
//
// Sweep: wick passes through the level but the bar closes back on the
// origin side → "SWEEP" label, line recolors to swept gray.
//
// IDM (Inducements): the current unbroken INTERNAL pivot high/low (from
// Phase 3's intStruct) drawn as a dotted line. Cleared when the pivot is
// consumed by a break.

// 7.1 Tolerance — ATR-based by default so EQH/EQL pair on every instrument
// (including indices, where the legacy 10-pip default = 2.5 NAS100 points
// was so tight nothing ever paired). User can opt back into pips via the
// eqToleranceMode input.
liqAtr         = ta.atr(14)
liqPipSize     = syminfo.mintick * (syminfo.mintick <= 0.001 ? 10 : 1)
liqTolerancePx = eqToleranceMode == "Auto (ATR)" ? liqAtr * eqToleranceATR : liqPipSize * eqTolerance

// 7.2 Recent swing history (used to find matching pivots)
type SwingHist
    float price = na
    int   bar   = na
    bool  isHigh = true

var array<SwingHist> swingHistory = array.new<SwingHist>()
LIQ_HISTORY_SIZE = 30

// 7.3 EQ level state
type EQLevel
    line  ln
    label lbl
    float price
    int   bar1
    int   bar2
    bool  isHigh
    bool  swept

var array<EQLevel> eqLevels = array.new<EQLevel>()
LIQ_MAX_LEVELS = 10
LIQ_LABEL_CAP = 80
var array<label> liqLabels = array.new<label>()

// 7.4 Push a new swing onto history, drop oldest if over capacity
f_add_swing(float swPrice, int swBar, bool isHigh) =>
    array.push(swingHistory, SwingHist.new(swPrice, swBar, isHigh))
    while array.size(swingHistory) > LIQ_HISTORY_SIZE
        SwingHist _dropped = array.shift(swingHistory)

// 7.5 New swing → either extend an existing EQ line or create a new one
f_check_eq_match(float newPrice, int newBar, bool isHigh) =>
    if showLiq and (isHigh ? showEQH : showEQL)
        // Try to extend an existing live EQ level first
        bool extended = false
        int j = 0
        while j < array.size(eqLevels) and not extended
            eq = array.get(eqLevels, j)
            sameDir   = eq.isHigh == isHigh
            withinTol = math.abs(eq.price - newPrice) <= liqTolerancePx
            if sameDir and not eq.swept and withinTol
                if not na(eq.ln)
                    line.set_x2(eq.ln, newBar)
                eq.bar2 := newBar
                extended := true
            j += 1

        // Otherwise scan the last ~10 swings of history for a new pair
        if not extended
            int n = array.size(swingHistory) - 1
            int i = n - 1
            int lowerBound = math.max(0, n - 10)
            bool found = false
            while i >= lowerBound and not found
                sh = array.get(swingHistory, i)
                if sh.isHigh == isHigh and math.abs(sh.price - newPrice) <= liqTolerancePx
                    levelPrice = (sh.price + newPrice) / 2
                    levelColor = isHigh ? eqhColor : eqlColor
                    ln = line.new(sh.bar, levelPrice, f_right_anchor(), levelPrice,
                         color = levelColor,
                         style = line.style_solid,
                         width = 1,
                         xloc  = xloc.bar_index)
                    // Label sits at the right anchor (a few bars past the last
                    // candle) and uses label.style_label_left so the box sits
                    // to the left of its anchor, hugging the line's right end.
                    lbl = label.new(f_right_anchor(), levelPrice, isHigh ? "EQH" : "EQL",
                         style     = label.style_label_left,
                         color     = color.new(color.white, 100),
                         textcolor = levelColor,
                         size      = size.tiny,
                         xloc      = xloc.bar_index)
                    eq = EQLevel.new(ln, lbl, levelPrice, sh.bar, newBar, isHigh, false)
                    array.push(eqLevels, eq)

                    while array.size(eqLevels) > LIQ_MAX_LEVELS
                        EQLevel old = array.shift(eqLevels)
                        if not na(old.ln)
                            line.delete(old.ln)
                        if not na(old.lbl)
                            label.delete(old.lbl)

                    found := true
                i -= 1

// 7.6 Sweep detection + label-position upkeep for live EQ levels.
// Returns true if any new sweep happened on this bar (consumed by Phase 13).
f_update_eq_levels() =>
    int i = 0
    bool anySwept = false
    while i < array.size(eqLevels)
        eq = array.get(eqLevels, i)

        if not eq.swept
            sweptNow = eq.isHigh ? (high > eq.price and close < eq.price) : (low < eq.price and close > eq.price)
            if sweptNow
                eq.swept := true
                anySwept := true
                if showSweeps and barstate.isconfirmed
                    lbl = label.new(bar_index, eq.price, "SWEEP",
                         style     = eq.isHigh ? label.style_label_down : label.style_label_up,
                         color     = color.new(color.white, 100),
                         textcolor = sweptColor,
                         size      = size.small,
                         xloc      = xloc.bar_index)
                    f_track_label(liqLabels, lbl, LIQ_LABEL_CAP)
                if not na(eq.ln)
                    line.set_color(eq.ln, sweptColor)
                if not na(eq.lbl)
                    label.set_textcolor(eq.lbl, sweptColor)

        if not na(eq.ln)
            // Keep the live edge tracking the right anchor every bar so the
            // line grows with the chart instead of stalling at its origin bar.
            line.set_x2(eq.ln, f_right_anchor())
        if not na(eq.lbl)
            label.set_x(eq.lbl, f_right_anchor())

        i += 1
    anySwept

// 7.7 IDM lines that mirror the current unbroken internal pivots.
// Pine v6 forbids functions from modifying global vars, so all updates
// are inlined in the dispatch below.
var line  idmHighLine = na
var line  idmLowLine  = na
var label idmHighLbl  = na
var label idmLowLbl   = na

// 7.8 Per-bar dispatch (and event tracking for Phase 13 alerts)
liqSweepEvent = false

if not showLiq
    while array.size(eqLevels) > 0
        EQLevel old = array.shift(eqLevels)
        if not na(old.ln)
            line.delete(old.ln)
        if not na(old.lbl)
            label.delete(old.lbl)
else
    if not na(swgPivotH)
        f_add_swing(swgPivotH, bar_index - swgRightBars, true)
        f_check_eq_match(swgPivotH, bar_index - swgRightBars, true)
    if not na(swgPivotL)
        f_add_swing(swgPivotL, bar_index - swgRightBars, false)
        f_check_eq_match(swgPivotL, bar_index - swgRightBars, false)
    liqSweepEvent := f_update_eq_levels()

// 7.9 IDM update — fully inlined (touches global var lines/labels).
// Each branch ends with `int _step := N` so the if/else has consistent return
// type and Pine doesn't trip CE10235 on the label-vs-void mismatch.
idmEnabled = showLiq and showIDM

// High-side IDM
_idmHighStep = 0
if idmEnabled and not na(intStruct.ph)
    if na(idmHighLine)
        idmHighLine := line.new(intStruct.phBar, intStruct.ph, f_right_anchor(), intStruct.ph,
             color = eqhColor,
             style = line.style_dotted,
             xloc  = xloc.bar_index)
        idmHighLbl := label.new(f_right_anchor(), intStruct.ph, "IDM",
             style     = label.style_label_left,
             color     = color.new(color.white, 100),
             textcolor = eqhColor,
             size      = size.tiny,
             xloc      = xloc.bar_index,
             tooltip   = "Inducement — minor swing point used as a liquidity trap before a larger move.")
        _idmHighStep := 1
    else
        line.set_x1(idmHighLine, intStruct.phBar)
        line.set_y1(idmHighLine, intStruct.ph)
        line.set_y2(idmHighLine, intStruct.ph)
        line.set_x2(idmHighLine, f_right_anchor())
        if not na(idmHighLbl)
            label.set_xy(idmHighLbl, f_right_anchor(), intStruct.ph)
        _idmHighStep := 2
else
    if not na(idmHighLine)
        line.delete(idmHighLine)
        idmHighLine := na
    if not na(idmHighLbl)
        label.delete(idmHighLbl)
        idmHighLbl := na
    _idmHighStep := 3

// Low-side IDM (mirror)
_idmLowStep = 0
if idmEnabled and not na(intStruct.pl)
    if na(idmLowLine)
        idmLowLine := line.new(intStruct.plBar, intStruct.pl, f_right_anchor(), intStruct.pl,
             color = eqlColor,
             style = line.style_dotted,
             xloc  = xloc.bar_index)
        idmLowLbl := label.new(f_right_anchor(), intStruct.pl, "IDM",
             style     = label.style_label_left,
             color     = color.new(color.white, 100),
             textcolor = eqlColor,
             size      = size.tiny,
             xloc      = xloc.bar_index,
             tooltip   = "Inducement — minor swing point used as a liquidity trap before a larger move.")
        _idmLowStep := 1
    else
        line.set_x1(idmLowLine, intStruct.plBar)
        line.set_y1(idmLowLine, intStruct.pl)
        line.set_y2(idmLowLine, intStruct.pl)
        line.set_x2(idmLowLine, f_right_anchor())
        if not na(idmLowLbl)
            label.set_xy(idmLowLbl, f_right_anchor(), intStruct.pl)
        _idmLowStep := 2
else
    if not na(idmLowLine)
        line.delete(idmLowLine)
        idmLowLine := na
    if not na(idmLowLbl)
        label.delete(idmLowLbl)
        idmLowLbl := na
    _idmLowStep := 3


//=============================================================================
// SECTION 8 — PREMIUM / DISCOUNT ENGINE
//=============================================================================
// Range = current swing high to current swing low. EQ at the midpoint.
// Premium = upper half (light red); Discount = lower half (light green).
// % readout label shows position 0-100% of the range.

// 8.1 Track most recent swing pivots (regardless of break status — we need
// both endpoints of the range, even if one has been broken).
var float pdSwgH    = na
var float pdSwgL    = na
var int   pdSwgHBar = na
var int   pdSwgLBar = na

if not na(swgPivotH)
    pdSwgH    := swgPivotH
    pdSwgHBar := bar_index - swgRightBars
if not na(swgPivotL)
    pdSwgL    := swgPivotL
    pdSwgLBar := bar_index - swgRightBars

// 8.2 Single-instance drawing objects (repositioned, not recreated, each bar)
var box   pdPremiumBox  = na
var box   pdDiscountBox = na
var line  pdEqLine      = na
var label pdEqLabel     = na
var label pdPctLabel    = na

// 8.3 Per-bar update — clear logic inlined (Pine v6 forbids global mutation in functions)
if not showPD or na(pdSwgH) or na(pdSwgL) or pdSwgH <= pdSwgL
    if not na(pdPremiumBox)
        box.delete(pdPremiumBox)
        pdPremiumBox := na
    if not na(pdDiscountBox)
        box.delete(pdDiscountBox)
        pdDiscountBox := na
    if not na(pdEqLine)
        line.delete(pdEqLine)
        pdEqLine := na
    if not na(pdEqLabel)
        label.delete(pdEqLabel)
        pdEqLabel := na
    if not na(pdPctLabel)
        label.delete(pdPctLabel)
        pdPctLabel := na
else
    eqPx        = (pdSwgH + pdSwgL) / 2
    rangeSize   = pdSwgH - pdSwgL
    pricePosPct = (close - pdSwgL) / rangeSize * 100
    rangeLeft   = math.min(pdSwgHBar, pdSwgLBar)

    // Premium / Discount shading — int sentinel aligns branch return types
    if showZoneShading
        _pdShadeStep = 0
        if na(pdPremiumBox)
            pdPremiumBox := box.new(rangeLeft, pdSwgH, bar_index, eqPx,
                 bgcolor      = f_alpha(premColor, zoneTransp),
                 border_color = color.new(color.white, 100),
                 xloc         = xloc.bar_index)
            _pdShadeStep := 1
        else
            box.set_left(pdPremiumBox,   rangeLeft)
            box.set_top(pdPremiumBox,    pdSwgH)
            box.set_bottom(pdPremiumBox, eqPx)
            box.set_right(pdPremiumBox,  bar_index)
            box.set_bgcolor(pdPremiumBox, f_alpha(premColor, zoneTransp))
            _pdShadeStep := 2

        if na(pdDiscountBox)
            pdDiscountBox := box.new(rangeLeft, eqPx, bar_index, pdSwgL,
                 bgcolor      = f_alpha(discColor, zoneTransp),
                 border_color = color.new(color.white, 100),
                 xloc         = xloc.bar_index)
            _pdShadeStep := 3
        else
            box.set_left(pdDiscountBox,   rangeLeft)
            box.set_top(pdDiscountBox,    eqPx)
            box.set_bottom(pdDiscountBox, pdSwgL)
            box.set_right(pdDiscountBox,  bar_index)
            box.set_bgcolor(pdDiscountBox, f_alpha(discColor, zoneTransp))
            _pdShadeStep := 4
    else
        if not na(pdPremiumBox)
            box.delete(pdPremiumBox)
            pdPremiumBox := na
        if not na(pdDiscountBox)
            box.delete(pdDiscountBox)
            pdDiscountBox := na

    // EQ line — int sentinel makes both branches return int (CE10235 alignment)
    if showEQ
        _pdEqStep = 0
        if na(pdEqLine)
            pdEqLine := line.new(rangeLeft, eqPx, f_right_anchor(), eqPx,
                 color = eqColor,
                 style = line.style_solid,
                 width = 1,
                 xloc  = xloc.bar_index)
            pdEqLabel := label.new(f_right_anchor(), eqPx, "EQ",
                 style     = label.style_label_left,
                 color     = color.new(color.white, 100),
                 textcolor = eqColor,
                 size      = size.tiny,
                 xloc      = xloc.bar_index,
                 tooltip   = "Equilibrium — 50% of the current swing range. Premium above, discount below.")
            _pdEqStep := 1
        else
            line.set_x1(pdEqLine, rangeLeft)
            line.set_y1(pdEqLine, eqPx)
            line.set_y2(pdEqLine, eqPx)
            line.set_x2(pdEqLine, f_right_anchor())
            line.set_color(pdEqLine, eqColor)
            if not na(pdEqLabel)
                label.set_xy(pdEqLabel, f_right_anchor(), eqPx)
                label.set_textcolor(pdEqLabel, eqColor)
            _pdEqStep := 2
    else
        if not na(pdEqLine)
            line.delete(pdEqLine)
            pdEqLine := na
        if not na(pdEqLabel)
            label.delete(pdEqLabel)
            pdEqLabel := na

    // % readout — anchored to whichever extreme price is closer to
    if showPctReadout_eff
        inPremium    = pricePosPct >= 50
        zoneText     = str.tostring(pricePosPct, "0.0") + (inPremium ? "% Prem" : "% Disc")
        zoneTxtColor = inPremium ? premColor : discColor
        labelY       = inPremium ? pdSwgH : pdSwgL
        labelStyle   = inPremium ? label.style_label_down : label.style_label_up

        _pdPctStep = 0
        if na(pdPctLabel)
            pdPctLabel := label.new(bar_index, labelY, zoneText,
                 style     = labelStyle,
                 color     = color.new(color.white, 100),
                 textcolor = zoneTxtColor,
                 size      = size.small,
                 xloc      = xloc.bar_index)
            _pdPctStep := 1
        else
            label.set_xy(pdPctLabel, bar_index, labelY)
            label.set_text(pdPctLabel, zoneText)
            label.set_textcolor(pdPctLabel, zoneTxtColor)
            label.set_style(pdPctLabel, labelStyle)
            _pdPctStep := 2
    else
        if not na(pdPctLabel)
            label.delete(pdPctLabel)
            pdPctLabel := na


//=============================================================================
// SECTION 9 — KEY LEVELS ENGINE
//=============================================================================
// Plots PDH/PDL, PWH/PWL, PMH/PML, Monday H/L, and NY-Midnight-Open as
// horizontal reference lines that stop at f_right_anchor() — a few bars past
// the live edge — with a label hugging the right end. No extend.right.
//
// Three security calls (D / W / M) — within the 8-call budget for the Free
// version. Monday H/L and NY Midnight Open are tracked locally from the
// chart's bars (no extra security call).

// 9.1 HTF prior-period highs/lows via tuple security calls
[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]],
     lookahead = barmerge.lookahead_off)
[pwh, pwl] = request.security(syminfo.tickerid, "W", [high[1], low[1]],
     lookahead = barmerge.lookahead_off)
[pmh, pml] = request.security(syminfo.tickerid, "M", [high[1], low[1]],
     lookahead = barmerge.lookahead_off)

// 9.2 Monday H/L tracked locally
var float curMonH  = na
var float curMonL  = na
var float lastMonH = na
var float lastMonL = na

isMon = dayofweek(time, "America/New_York") == dayofweek.monday

if isMon
    if na(curMonH)
        curMonH := high
        curMonL := low
    else
        curMonH := math.max(curMonH, high)
        curMonL := math.min(curMonL, low)
else
    if not na(curMonH)
        lastMonH := curMonH
        lastMonL := curMonL
        curMonH  := na
        curMonL  := na

mondayH = isMon ? curMonH : lastMonH
mondayL = isMon ? curMonL : lastMonL

// 9.3 NY Midnight Open — captured on the first bar of 00:00 EST
var float nyMidOpen = na
nyHr  = f_ny_hour()
nyMn  = f_ny_minute()
prevH = nz(nyHr[1], -1)
prevM = nz(nyMn[1], -1)
if nyHr == 0 and nyMn == 0 and (prevH != 0 or prevM != 0)
    nyMidOpen := open

// 9.4 KeyLevel pair (line + label) and a single render helper
type KeyLevel
    line  ln  = na
    label lbl = na

f_draw_level(KeyLevel kl, bool show, float price, color c, int wid, string sty, string txt) =>
    // Pine v6 CE10235: every branch must return the same type. Each branch
    // ends with `_step := N` so the if/else chain evaluates to int.
    _step = 0
    if not show or na(price)
        if not na(kl.ln)
            line.delete(kl.ln)
            kl.ln := na
        if not na(kl.lbl)
            label.delete(kl.lbl)
            kl.lbl := na
        _step := 1
    else
        if na(kl.ln)
            kl.ln := line.new(bar_index - 1, price, f_right_anchor(), price,
                 color = c,
                 width = wid,
                 style = sty,
                 xloc  = xloc.bar_index)
            kl.lbl := label.new(f_right_anchor(), price, showLevelLabels ? txt : "",
                 style     = label.style_label_left,
                 color     = color.new(color.white, 100),
                 textcolor = c,
                 size      = size.tiny,
                 xloc      = xloc.bar_index)
            _step := 2
        else
            line.set_y1(kl.ln, price)
            line.set_y2(kl.ln, price)
            line.set_x2(kl.ln, f_right_anchor())
            line.set_color(kl.ln, c)
            line.set_style(kl.ln, sty)
            line.set_width(kl.ln, wid)
            if not na(kl.lbl)
                label.set_xy(kl.lbl, f_right_anchor(), price)
                label.set_text(kl.lbl, showLevelLabels ? txt : "")
                label.set_textcolor(kl.lbl, c)
            _step := 3

// 9.5 KeyLevel instances
var KeyLevel klPDH   = KeyLevel.new()
var KeyLevel klPDL   = KeyLevel.new()
var KeyLevel klPWH   = KeyLevel.new()
var KeyLevel klPWL   = KeyLevel.new()
var KeyLevel klPMH   = KeyLevel.new()
var KeyLevel klPML   = KeyLevel.new()
var KeyLevel klMonH  = KeyLevel.new()
var KeyLevel klMonL  = KeyLevel.new()
var KeyLevel klNYMid = KeyLevel.new()

// 9.6 Per-bar dispatch
levelsOn = showLevels

f_draw_level(klPDH,   levelsOn and showPDH_PDL,    pdh,       dailyColor,   1, line.style_solid,  "PDH")
f_draw_level(klPDL,   levelsOn and showPDH_PDL,    pdl,       dailyColor,   1, line.style_solid,  "PDL")
f_draw_level(klPWH,   levelsOn and showPWH_PWL,    pwh,       weeklyColor,  2, line.style_solid,  "PWH")
f_draw_level(klPWL,   levelsOn and showPWH_PWL,    pwl,       weeklyColor,  2, line.style_solid,  "PWL")
f_draw_level(klPMH,   levelsOn and showPMH_PML,    pmh,       monthlyColor, 2, line.style_dashed, "PMH")
f_draw_level(klPML,   levelsOn and showPMH_PML,    pml,       monthlyColor, 2, line.style_dashed, "PML")
f_draw_level(klMonH,  levelsOn and showMonday,     mondayH,   dailyColor,   1, line.style_dotted, "MonH")
f_draw_level(klMonL,  levelsOn and showMonday,     mondayL,   dailyColor,   1, line.style_dotted, "MonL")
f_draw_level(klNYMid, levelsOn and showNYMidnight, nyMidOpen, dailyColor,   1, line.style_solid,  "NY Mid")


//=============================================================================
// SECTION 10 — CRT ENGINE (CANDLE RANGE THEORY)
//=============================================================================
// CRT candle = a candle that sweeps both the prior candle's high AND low.
// Direction = sign of the candle body (close > open is bullish, close <
// open is bearish).
//
// On detection, draw horizontal lines at the CRT candle's high and low
// extending right. When price touches a line, that side stops extending
// (line.set_extend(extend.none)) and the label freezes at the touch bar.

// 10.1 CRT state
type CRT
    line  hiLine
    line  loLine
    label hiLbl
    label loLbl
    float hi
    float lo
    int   originBar
    bool  isBullish
    bool  hiTouched = false
    bool  loTouched = false

var array<CRT> crts = array.new<CRT>()
CRT_MAX = 5

// 10.2 Resolve user's line-style string to the Pine constant
crtStyleConst = crtLineStyle == "Solid" ? line.style_solid : crtLineStyle == "Dotted" ? line.style_dotted : line.style_dashed

// 10.3 Friendly TF tag for label text
f_format_tf() =>
    p = timeframe.period
    p == "D" ? "D" : p == "W" ? "W" : p == "M" ? "M" : p == "1" ? "1m" : p == "5" ? "5m" : p == "15" ? "15m" : p == "30" ? "30m" : p == "60" ? "1H" : p == "240" ? "4H" : p

// 10.4 Detection
isBullishCRT = high > high[1] and low < low[1] and close > open
isBearishCRT = high > high[1] and low < low[1] and close < open
isCRT        = isBullishCRT or isBearishCRT

// 10.5 Spawn a new CRT
f_create_crt(bool isBullish) =>
    crtColor = isBullish ? bullCRTColor : bearCRTColor
    tfTag    = f_format_tf()
    txt      = "CRT " + tfTag

    hiLine = line.new(bar_index, high, f_right_anchor(), high,
         color = crtColor,
         style = crtStyleConst,
         width = 1,
         xloc  = xloc.bar_index)
    loLine = line.new(bar_index, low, f_right_anchor(), low,
         color = crtColor,
         style = crtStyleConst,
         width = 1,
         xloc  = xloc.bar_index)
    // Labels live at the right anchor (a few bars past the last candle) so
    // they hug the right end of the line instead of getting buried in the
    // CRT candle body. style_label_left sets the box on the left of its anchor.
    hiLbl = label.new(f_right_anchor(), high, showCRTLabels ? txt : "",
         style     = label.style_label_left,
         color     = color.new(color.white, 100),
         textcolor = crtColor,
         size      = size.tiny,
         xloc      = xloc.bar_index)
    loLbl = label.new(f_right_anchor(), low, showCRTLabels ? txt : "",
         style     = label.style_label_left,
         color     = color.new(color.white, 100),
         textcolor = crtColor,
         size      = size.tiny,
         xloc      = xloc.bar_index)

    c = CRT.new(hiLine, loLine, hiLbl, loLbl, high, low, bar_index, isBullish, false, false)
    array.push(crts, c)

    while array.size(crts) > CRT_MAX
        CRT old = array.shift(crts)
        if not na(old.hiLine)
            line.delete(old.hiLine)
        if not na(old.loLine)
            line.delete(old.loLine)
        if not na(old.hiLbl)
            label.delete(old.hiLbl)
        if not na(old.loLbl)
            label.delete(old.loLbl)

// 10.6 Update one CRT — touch detection + live label/style refresh
// Lines now stop at f_right_anchor() (no extend.right). Untouched sides have
// their right edge pushed forward each bar; touched sides freeze at the touch.
f_update_crt(CRT c) =>
    if bar_index > c.originBar
        // High side touch — freeze the right edge at the touch bar
        if not c.hiTouched and high >= c.hi
            c.hiTouched := true
            if not na(c.hiLine)
                line.set_x2(c.hiLine, bar_index)
            if not na(c.hiLbl)
                label.set_x(c.hiLbl, bar_index)

        // Low side touch — mirror
        if not c.loTouched and low <= c.lo
            c.loTouched := true
            if not na(c.loLine)
                line.set_x2(c.loLine, bar_index)
            if not na(c.loLbl)
                label.set_x(c.loLbl, bar_index)

    // Live updates for non-touched sides — push right edge forward and refresh
    txt = "CRT " + f_format_tf()

    if not na(c.hiLine)
        line.set_style(c.hiLine, crtStyleConst)
    if not na(c.loLine)
        line.set_style(c.loLine, crtStyleConst)

    if not c.hiTouched
        if not na(c.hiLine)
            line.set_x2(c.hiLine, f_right_anchor())
        if not na(c.hiLbl)
            label.set_x(c.hiLbl, f_right_anchor())
            label.set_text(c.hiLbl, showCRTLabels ? txt : "")
    if not c.loTouched
        if not na(c.loLine)
            line.set_x2(c.loLine, f_right_anchor())
        if not na(c.loLbl)
            label.set_x(c.loLbl, f_right_anchor())
            label.set_text(c.loLbl, showCRTLabels ? txt : "")

// 10.7 Per-bar dispatch
// CRT is gated by both the showCRT toggle and the htfPass rule (15m+ when
// htfOnly is on). When gated off, we tear down all live CRT draws so the
// chart doesn't keep stale boxes.
crtActive = showCRT and htfPass

if not crtActive
    while array.size(crts) > 0
        CRT old = array.shift(crts)
        if not na(old.hiLine)
            line.delete(old.hiLine)
        if not na(old.loLine)
            line.delete(old.loLine)
        if not na(old.hiLbl)
            label.delete(old.hiLbl)
        if not na(old.loLbl)
            label.delete(old.loLbl)
else
    if isCRT and barstate.isconfirmed
        f_create_crt(isBullishCRT)

    int i = 0
    while i < array.size(crts)
        c = array.get(crts, i)
        f_update_crt(c)
        i += 1


//=============================================================================
// SECTION 11 — ADR ENGINE (AVERAGE DAILY RANGE + JUDAS)
//=============================================================================
// One security call returns daily H/L/O plus the ADR (SMA of prior
// adrPeriod daily ranges). Today's consumption = (dH - dL) / ADR × 100.
//
// Visuals:
//   ADR projection (optional): dOpen ± ADR/2, solid
//   Judas levels: nyMidOpen ± ADR/3, dotted
//   Consumption % label: green <60%·threshold, yellow <threshold, red ≥threshold

// 11.1 Daily data + ADR (single security call returning 4 values)
[dHigh, dLow, dOpen, adrVal] = request.security(syminfo.tickerid, "D",
     [high, low, open, ta.sma(high[1] - low[1], adrPeriod)],
     lookahead = barmerge.lookahead_off)

// 11.2 Consumption % and status color
adrConsumption = na(adrVal) or adrVal == 0 ? 0.0 : (dHigh - dLow) / adrVal * 100
adrLowerBound  = adrThreshold * 0.75
adrConsumColor = adrConsumption >= adrThreshold ? color.red : adrConsumption >= adrLowerBound ? color.yellow : color.green

// 11.3 Single-instance drawing objects
var line  lnADRUp     = na
var line  lnADRDown   = na
var line  lnJudasUp   = na
var line  lnJudasDown = na
var label lblADRUp     = na
var label lblADRDown   = na
var label lblJudasUp   = na
var label lblJudasDown = na
var label lblConsum   = na

// 11.4 Per-bar update — clear logic inlined (Pine v6 forbids global mutation in functions)
if not showADR_eff or na(adrVal)
    if not na(lnADRUp)
        line.delete(lnADRUp)
        lnADRUp := na
    if not na(lnADRDown)
        line.delete(lnADRDown)
        lnADRDown := na
    if not na(lnJudasUp)
        line.delete(lnJudasUp)
        lnJudasUp := na
    if not na(lnJudasDown)
        line.delete(lnJudasDown)
        lnJudasDown := na
    if not na(lblADRUp)
        label.delete(lblADRUp)
        lblADRUp := na
    if not na(lblADRDown)
        label.delete(lblADRDown)
        lblADRDown := na
    if not na(lblJudasUp)
        label.delete(lblJudasUp)
        lblJudasUp := na
    if not na(lblJudasDown)
        label.delete(lblJudasDown)
        lblJudasDown := na
    if not na(lblConsum)
        label.delete(lblConsum)
        lblConsum := na
else
    // --- ADR Projection lines (optional) ---
    adrHalf  = adrVal / 2
    projUp   = dOpen + adrHalf
    projDown = dOpen - adrHalf

    if showADRProj
        _adrProjStep = 0
        if na(lnADRUp)
            lnADRUp := line.new(bar_index - 1, projUp, f_right_anchor(), projUp,
                 color = adrColor, width = 1, style = line.style_solid, xloc = xloc.bar_index)
            lnADRDown := line.new(bar_index - 1, projDown, f_right_anchor(), projDown,
                 color = adrColor, width = 1, style = line.style_solid, xloc = xloc.bar_index)
            lblADRUp := label.new(f_right_anchor(), projUp, "ADR+",
                 style = label.style_label_left, color = color.new(color.white, 100),
                 textcolor = adrColor, size = size.tiny, xloc = xloc.bar_index)
            lblADRDown := label.new(f_right_anchor(), projDown, "ADR-",
                 style = label.style_label_left, color = color.new(color.white, 100),
                 textcolor = adrColor, size = size.tiny, xloc = xloc.bar_index)
            _adrProjStep := 1
        else
            line.set_y1(lnADRUp, projUp)
            line.set_y2(lnADRUp, projUp)
            line.set_x2(lnADRUp, f_right_anchor())
            line.set_color(lnADRUp, adrColor)
            line.set_y1(lnADRDown, projDown)
            line.set_y2(lnADRDown, projDown)
            line.set_x2(lnADRDown, f_right_anchor())
            line.set_color(lnADRDown, adrColor)
            if not na(lblADRUp)
                label.set_xy(lblADRUp, f_right_anchor(), projUp)
            if not na(lblADRDown)
                label.set_xy(lblADRDown, f_right_anchor(), projDown)
            _adrProjStep := 2
    else
        if not na(lnADRUp)
            line.delete(lnADRUp)
            lnADRUp := na
        if not na(lnADRDown)
            line.delete(lnADRDown)
            lnADRDown := na
        if not na(lblADRUp)
            label.delete(lblADRUp)
            lblADRUp := na
        if not na(lblADRDown)
            label.delete(lblADRDown)
            lblADRDown := na

    // --- Judas levels ---
    judasOk = showJudas_eff and not na(nyMidOpen)
    if judasOk
        judasUp   = nyMidOpen + adrVal / 3
        judasDown = nyMidOpen - adrVal / 3
        _adrJudasStep = 0
        if na(lnJudasUp)
            lnJudasUp := line.new(bar_index - 1, judasUp, f_right_anchor(), judasUp,
                 color = adrColor, width = 1, style = line.style_dotted, xloc = xloc.bar_index)
            lnJudasDown := line.new(bar_index - 1, judasDown, f_right_anchor(), judasDown,
                 color = adrColor, width = 1, style = line.style_dotted, xloc = xloc.bar_index)
            lblJudasUp := label.new(f_right_anchor(), judasUp, "Judas+",
                 style = label.style_label_left, color = color.new(color.white, 100),
                 textcolor = adrColor, size = size.tiny, xloc = xloc.bar_index)
            lblJudasDown := label.new(f_right_anchor(), judasDown, "Judas-",
                 style = label.style_label_left, color = color.new(color.white, 100),
                 textcolor = adrColor, size = size.tiny, xloc = xloc.bar_index)
            _adrJudasStep := 1
        else
            line.set_y1(lnJudasUp, judasUp)
            line.set_y2(lnJudasUp, judasUp)
            line.set_x2(lnJudasUp, f_right_anchor())
            line.set_color(lnJudasUp, adrColor)
            line.set_y1(lnJudasDown, judasDown)
            line.set_y2(lnJudasDown, judasDown)
            line.set_x2(lnJudasDown, f_right_anchor())
            line.set_color(lnJudasDown, adrColor)
            if not na(lblJudasUp)
                label.set_xy(lblJudasUp, f_right_anchor(), judasUp)
            if not na(lblJudasDown)
                label.set_xy(lblJudasDown, f_right_anchor(), judasDown)
            _adrJudasStep := 2
    else
        if not na(lnJudasUp)
            line.delete(lnJudasUp)
            lnJudasUp := na
        if not na(lnJudasDown)
            line.delete(lnJudasDown)
            lnJudasDown := na
        if not na(lblJudasUp)
            label.delete(lblJudasUp)
            lblJudasUp := na
        if not na(lblJudasDown)
            label.delete(lblJudasDown)
            lblJudasDown := na

    // --- Consumption % label ---
    consumText = "ADR " + str.tostring(adrConsumption, "0") + "%"
    _adrConsumStep = 0
    if na(lblConsum)
        lblConsum := label.new(bar_index, dHigh, consumText,
             style     = label.style_label_left,
             color     = color.new(color.white, 100),
             textcolor = adrConsumColor,
             size      = size.small,
             xloc      = xloc.bar_index)
        _adrConsumStep := 1
    else
        label.set_xy(lblConsum, bar_index, dHigh)
        label.set_text(lblConsum, consumText)
        label.set_textcolor(lblConsum, adrConsumColor)
        _adrConsumStep := 2


//=============================================================================
// SECTION 12 — SMT DIVERGENCE ENGINE
//=============================================================================
// SMT (Smart Money Technique) divergence: when the chart's symbol prints a
// new swing high/low and a correlated pair fails to confirm, that's a
// divergence — institutional players moving one but not the other.
//
// Default pair mapping:
//   EUR* → FX:GBPUSD
//   GBP* → FX:EURUSD
//   XAU/GOLD → TVC:SILVER
//   NAS/US100 → SP:SPX
//   else → user override (smtPairOverride input)

// 12.1 Resolve correlated pair
smtPair = smtPairOverride != "" ? smtPairOverride : str.contains(syminfo.ticker, "EUR") ? "FX:GBPUSD" : str.contains(syminfo.ticker, "GBP") ? "FX:EURUSD" : (str.contains(syminfo.ticker, "XAU") or str.contains(syminfo.ticker, "GOLD")) ? "TVC:SILVER" : (str.contains(syminfo.ticker, "NAS") or str.contains(syminfo.ticker, "US100")) ? "SP:SPX" : ""

smtEnabled = showSMT and smtPair != ""

// 12.2 Fetch correlated pair (1 security call — total budget now 6/8)
// We must call request.security unconditionally at script scope. Falling
// back to chart's own ticker when no pair is determined keeps the call
// valid; we just don't act on the data.
effectivePair = smtPair != "" ? smtPair : syminfo.tickerid
[smtHigh, smtLow] = request.security(effectivePair, timeframe.period, [high, low],
     lookahead = barmerge.lookahead_off)

// 12.3 Persist correlated pair's value at chart's previous swing pivot
var float lastSmtHighAtSwg = na
var float lastSmtLowAtSwg  = na
SMT_LABEL_CAP = 60
var array<label> smtLabels = array.new<label>()

// 12.4 Per-bar detection (and event flag for Phase 13 alerts)
smtDivEvent = false

if smtEnabled
    // ▼ bearish: chart prints HH, correlated does not
    if not na(swgPivotH)
        chartHH        = not na(swgStruct.prevPH) and swgPivotH > swgStruct.prevPH
        smtHighAtPivot = smtHigh[intRightBars]

        bearishSmt = chartHH and not na(lastSmtHighAtSwg) and not na(smtHighAtPivot) and smtHighAtPivot < lastSmtHighAtSwg
        if bearishSmt
            smtDivEvent := true
            if showSMTLabels and barstate.isconfirmed
                lbl = label.new(bar_index - swgRightBars, swgPivotH, "SMT ▼",
                     style     = label.style_label_down,
                     color     = color.new(color.white, 100),
                     textcolor = bearSMTColor,
                     size      = size.small,
                     xloc      = xloc.bar_index)
                f_track_label(smtLabels, lbl, SMT_LABEL_CAP)

        lastSmtHighAtSwg := smtHighAtPivot

    // ▲ bullish: chart prints LL, correlated does not
    if not na(swgPivotL)
        chartLL       = not na(swgStruct.prevPL) and swgPivotL < swgStruct.prevPL
        smtLowAtPivot = smtLow[intRightBars]

        bullishSmt = chartLL and not na(lastSmtLowAtSwg) and not na(smtLowAtPivot) and smtLowAtPivot > lastSmtLowAtSwg
        if bullishSmt
            smtDivEvent := true
            if showSMTLabels and barstate.isconfirmed
                lbl = label.new(bar_index - swgRightBars, swgPivotL, "SMT ▲",
                     style     = label.style_label_up,
                     color     = color.new(color.white, 100),
                     textcolor = bullSMTColor,
                     size      = size.small,
                     xloc      = xloc.bar_index)
                f_track_label(smtLabels, lbl, SMT_LABEL_CAP)

        lastSmtLowAtSwg := smtLowAtPivot


//=============================================================================
// SECTION 13 — DASHBOARD TABLE
//=============================================================================
// 4 rows of HTF bias (W / D / 4H / 1H) + active session name + NY clock.
// Bias is computed inline inside request.security via f_dash_bias() —
// EMA20 vs EMA50 crossover, runs cleanly in a security call.
// 4 security calls here → total budget 10/40 hard limit.

// 13.1 Bias functions — TWO metrics shown side-by-side for confluence.
// Both agree = high-confidence directional signal; divergence = transition.
//
// f_dash_bias_struct — STRUCTURE (5/5 pivot BOS detection)
//   Sticky — flips only on real structural breaks. SMC-pure.
//   Same logic as the chart's market structure module.
//
// f_dash_bias_ema — PRICE vs EMAs (default 9/21, user-configurable)
//   Bullish when close is above BOTH EMAs (price + faster trend agreeing).
//   Bearish when close is below BOTH EMAs.
//   Neutral (—) when price is sandwiched between EMAs — honest signal of
//   "no clear bias", instead of reporting stale cross direction during
//   transitions. Periods configurable via "EMA Fast (Bias)" / "EMA Slow
//   (Bias)" inputs in the Dashboard group. Common alternates: 10/20
//   (classic), 5/13 (Fibonacci), 8/21 (Elder).
//
// Earlier iteration used pure EMA9/21 cross — that lagged real reversals
// because the cross only flips after price has been below the fast EMA
// for many bars. Switched to "price vs both EMAs" so the bias matches
// what traders see when price clearly breaks the trend lines.
//
// When Struct says ▲ but EMA says ▼, that's "pullback within bullish
// structure" — useful confluence read, NOT a contradiction. Two
// metrics measuring different things give complementary info.
//
// Both run in target-TF context via a single tuple request.security per
// TF (one call returns [struct, ema]). Security budget stays at 4.
f_dash_bias_struct() =>
    var float dashLastPH = na
    var float dashLastPL = na
    var int   dashLastPHBar = na
    var int   dashLastPLBar = na
    var float protH = na
    var float protL = na
    var int   protHBar = na
    var int   protLBar = na
    var float dashMotherH = na
    var float dashMotherL = na
    var int   b      = 0
    ph = ta.pivothigh(5, 5)
    pl = ta.pivotlow(5, 5)
    if not na(ph)
        dashLastPH := ph
        dashLastPHBar := bar_index - 5
    if not na(pl)
        dashLastPL := pl
        dashLastPLBar := bar_index - 5

    dashInsidePrev = high <= high[1] and low >= low[1]
    dashNewMother = na(dashMotherH) ? true : (high[1] > dashMotherH or low[1] < dashMotherL)
    if strictStructure and smcMotherFilter and dashInsidePrev and dashNewMother
        dashMotherH := high[1]
        dashMotherL := low[1]

    dashAtr = ta.atr(14)
    dashBullTarget = strictStructure and b == -1 and not na(protH) ? protH : dashLastPH
    dashBullBar = strictStructure and b == -1 and not na(protHBar) ? protHBar : dashLastPHBar
    dashBearTarget = strictStructure and b == 1 and not na(protL) ? protL : dashLastPL
    dashBearBar = strictStructure and b == 1 and not na(protLBar) ? protLBar : dashLastPLBar
    dashBullRaw = na(dashBullTarget) ? false : close > dashBullTarget
    dashBearRaw = na(dashBearTarget) ? false : close < dashBearTarget
    dashDual = strictStructure and dashBullRaw and dashBearRaw
    dashLegMin = dashAtr * smcMinLegATR
    dashLegOk = strictStructure ? (not na(dashLastPH) and not na(dashLastPL) and math.abs(dashLastPH - dashLastPL) >= dashLegMin) : true
    dashBullPullbackOk = strictStructure and smcRequireInducement ? (not na(dashLastPLBar) and not na(dashBullBar) and dashLastPLBar > dashBullBar) : true
    dashBearPullbackOk = strictStructure and smcRequireInducement ? (not na(dashLastPHBar) and not na(dashBearBar) and dashLastPHBar > dashBearBar) : true
    dashBullBufferOk = strictStructure ? (not na(dashBullTarget) and close > dashBullTarget + dashAtr * smcBreakBufferATR) : true
    dashBearBufferOk = strictStructure ? (not na(dashBearTarget) and close < dashBearTarget - dashAtr * smcBreakBufferATR) : true
    dashBullMotherOk = strictStructure and smcMotherFilter and not na(dashMotherH) ? close > dashMotherH : true
    dashBearMotherOk = strictStructure and smcMotherFilter and not na(dashMotherL) ? close < dashMotherL : true

    if dashBullRaw and not dashDual and dashLegOk and dashBullPullbackOk and dashBullBufferOk and dashBullMotherOk
        b := 1
        if not na(dashLastPL)
            protL := dashLastPL
            protLBar := dashLastPLBar
        protH := na
        protHBar := na
        dashLastPH := na
    if dashBearRaw and not dashDual and dashLegOk and dashBearPullbackOk and dashBearBufferOk and dashBearMotherOk
        b := -1
        if not na(dashLastPH)
            protH := dashLastPH
            protHBar := dashLastPHBar
        protL := na
        protLBar := na
        dashLastPL := na
    if not na(dashMotherH) and (close > dashMotherH or close < dashMotherL)
        dashMotherH := na
        dashMotherL := na
    b

f_dash_bias_ema() =>
    emaFast = ta.ema(close, dashEmaFast)
    emaSlow = ta.ema(close, dashEmaSlow)
    // Bullish: close above BOTH EMAs (strong trend up — price + cross both confirming)
    // Bearish: close below BOTH EMAs (strong trend down — price + cross both confirming)
    // Mixed:   close sandwiched between EMAs — neutral (—). Honest signal of
    //          "no clear bias right now" rather than reporting stale cross direction.
    bullish = close > emaFast and close > emaSlow
    bearish = close < emaFast and close < emaSlow
    bullish ? 1 : bearish ? -1 : 0

// 13.2 HTF bias via security — tuple returns BOTH metrics per call.
[biasW_s,  biasW_e]  = request.security(syminfo.tickerid, "W",   [f_dash_bias_struct(), f_dash_bias_ema()], lookahead = barmerge.lookahead_off)
[biasD_s,  biasD_e]  = request.security(syminfo.tickerid, "D",   [f_dash_bias_struct(), f_dash_bias_ema()], lookahead = barmerge.lookahead_off)
[bias4H_s, bias4H_e] = request.security(syminfo.tickerid, "240", [f_dash_bias_struct(), f_dash_bias_ema()], lookahead = barmerge.lookahead_off)
[bias1H_s, bias1H_e] = request.security(syminfo.tickerid, "60",  [f_dash_bias_struct(), f_dash_bias_ema()], lookahead = barmerge.lookahead_off)

// 13.3 Currently active session name — uses LIVE wall-clock NY time
// (timenow), not the bar's open time. Times match the market-hours
// session windows defined in Section 3.5. Asia covers 19:00→02:00
// (extended past midnight to remove the gap before Pre-London).
// Pre-NY (08:00-09:30) is checked BEFORE London (03:00-09:30) so it
// shows during the London-NY transition pre-market window.
f_active_session_name() =>
    f_is_in_session_now(19, 0, 2, 0) ? "Asia" : f_is_in_session_now(8, 0, 9, 30) ? "Pre-NY" : f_is_in_session_now(2, 0, 3, 0) ? "Pre-LDN" : f_is_in_session_now(3, 0, 9, 30) ? "London" : f_is_in_session_now(9, 30, 11, 0) ? "NY Open" : f_is_in_session_now(11, 0, 12, 0) ? "NY AM" : f_is_in_session_now(12, 0, 13, 30) ? "Lunch" : f_is_in_session_now(13, 30, 16, 0) ? "NY PM" : "—"

// 13.4 Resolve position + size strings to constants
f_dash_pos() =>
    dashPosition == "Top Left" ? position.top_left : dashPosition == "Bottom Right" ? position.bottom_right : dashPosition == "Bottom Left" ? position.bottom_left : position.top_right

f_dash_size() =>
    dashSize == "Tiny" ? size.tiny : dashSize == "Normal" ? size.normal : size.small

// 13.5 Bias rendering
f_bias_arrow(int b) =>
    b == 1 ? "▲" : b == -1 ? "▼" : "—"

f_bias_arrow_color(int b) =>
    b == 1 ? bullColor : b == -1 ? bearColor : color.gray

f_free_ob_touch(array<OBZone> arr) =>
    inside = false
    if array.size(arr) > 0
        for k = 0 to array.size(arr) - 1
            z = array.get(arr, k)
            if close <= z.top and close >= z.bottom
                inside := true
    inside

f_free_fvg_touch() =>
    inside = false
    if array.size(fvgs) > 0
        for k = 0 to array.size(fvgs) - 1
            f = array.get(fvgs, k)
            if f.phase < 2 and close <= f.top and close >= f.bottom
                inside := true
    inside

// 13.6 Table state
var table  dashTable      = na
var string lastDashPosStr = na
var int    lastDashRows   = 0

// 13.7 Per-bar dispatch — table itself only updates on the last bar
if not showDash
    if not na(dashTable)
        table.delete(dashTable)
        dashTable := na
    lastDashPosStr := na
    lastDashRows   := 0
else
    dashRows = showChecklist_eff ? 8 : 7
    if na(dashTable) or dashPosition != lastDashPosStr or dashRows != lastDashRows
        if not na(dashTable)
            table.delete(dashTable)
        dashTable := table.new(f_dash_pos(), columns = 3, rows = dashRows,
             bgcolor      = f_alpha(dashBgColor, 10),
             border_width = 1,
             border_color = color.new(#333333, 0))
        lastDashPosStr := dashPosition
        lastDashRows   := dashRows

    if barstate.islast
        sz       = f_dash_size()
        cellBg   = f_alpha(dashBgColor, 0)
        textCol  = dashTextColor

        // Header — 3 columns: TF | Str (5/5 pivot BOS) | EMA (user-configurable cross)
        table.cell(dashTable, 0, 0, "TF",  text_color = textCol, text_size = sz, bgcolor = cellBg)
        table.cell(dashTable, 1, 0, "Str", text_color = textCol, text_size = sz, bgcolor = cellBg)
        table.cell(dashTable, 2, 0, "EMA", text_color = textCol, text_size = sz, bgcolor = cellBg)

        // 4 HTF bias rows — both metrics per row for confluence
        table.cell(dashTable, 0, 1, "W", text_color = textCol, text_size = sz)
        table.cell(dashTable, 1, 1, f_bias_arrow(biasW_s),  text_color = f_bias_arrow_color(biasW_s),  text_size = sz)
        table.cell(dashTable, 2, 1, f_bias_arrow(biasW_e),  text_color = f_bias_arrow_color(biasW_e),  text_size = sz)

        table.cell(dashTable, 0, 2, "D", text_color = textCol, text_size = sz)
        table.cell(dashTable, 1, 2, f_bias_arrow(biasD_s),  text_color = f_bias_arrow_color(biasD_s),  text_size = sz)
        table.cell(dashTable, 2, 2, f_bias_arrow(biasD_e),  text_color = f_bias_arrow_color(biasD_e),  text_size = sz)

        table.cell(dashTable, 0, 3, "4H", text_color = textCol, text_size = sz)
        table.cell(dashTable, 1, 3, f_bias_arrow(bias4H_s), text_color = f_bias_arrow_color(bias4H_s), text_size = sz)
        table.cell(dashTable, 2, 3, f_bias_arrow(bias4H_e), text_color = f_bias_arrow_color(bias4H_e), text_size = sz)

        table.cell(dashTable, 0, 4, "1H", text_color = textCol, text_size = sz)
        table.cell(dashTable, 1, 4, f_bias_arrow(bias1H_s), text_color = f_bias_arrow_color(bias1H_s), text_size = sz)
        table.cell(dashTable, 2, 4, f_bias_arrow(bias1H_e), text_color = f_bias_arrow_color(bias1H_e), text_size = sz)

        // Session + NY clock — pad col 2 blank
        table.cell(dashTable, 0, 5, "Session", text_color = textCol, text_size = sz)
        table.cell(dashTable, 1, 5, f_active_session_name(), text_color = textCol, text_size = sz)
        table.cell(dashTable, 2, 5, "", text_size = sz)

        // NY clock — uses timenow (live wall-clock) so on HTF charts it
        // shows the actual current NY time, not the bar's open time.
        nyH = f_ny_hour_now()
        nyM = f_ny_minute_now()
        nyTimeStr = (nyH < 10 ? "0" : "") + str.tostring(nyH) + ":" + (nyM < 10 ? "0" : "") + str.tostring(nyM)
        table.cell(dashTable, 0, 6, "NY Time", text_color = textCol, text_size = sz)
        table.cell(dashTable, 1, 6, nyTimeStr,  text_color = textCol, text_size = sz)
        table.cell(dashTable, 2, 6, "", text_size = sz)
        if showChecklist_eff
            biasTxt = swgStruct.bias == 1 ? "Bull" : swgStruct.bias == -1 ? "Bear" : "—"
            liqTxt = liqSweepEvent ? "Sweep" : array.size(eqLevels) > 0 ? "Pool" : "—"
            poiActive = f_free_ob_touch(activeBullOBs) or f_free_ob_touch(activeBearOBs) or f_free_ob_touch(bullBreakers) or f_free_ob_touch(bearBreakers) or f_free_fvg_touch()
            poiTxt = poiActive ? "POI" : "—"
            alertNow = barstate.isconfirmed and (swgStruct.bullBreakNow or swgStruct.bearBreakNow or fvgTouchEvent or liqSweepEvent or (isCRT and crtActive) or smtDivEvent)
            table.cell(dashTable, 0, 7, "Checklist", text_color = textCol, text_size = sz)
            table.cell(dashTable, 1, 7, biasTxt + " · " + liqTxt, text_color = swgStruct.bias == 1 ? bullColor : swgStruct.bias == -1 ? bearColor : color.gray, text_size = sz)
            table.cell(dashTable, 2, 7, poiTxt + (alertNow ? " · Alert" : ""), text_color = poiActive ? chochColor : color.gray, text_size = sz)


//=============================================================================
// SECTION 13B — LEGEND TABLE
//=============================================================================
// Toggleable abbreviation key. Off by default so it doesn't crowd the chart;
// users flip it on when they're learning the terminology and turn it off
// once they've internalized the abbreviations. Reuses the dashboard's color
// inputs (dashBgColor / dashTextColor) so the two tables visually match.

// Single-line chained ternary — Pine v6 errors on multi-line chained ternaries
// at top-level (CE10156). Same shape as f_dash_pos in Section 13.4.
f_legend_pos() =>
    legendPosition == "Top Right" ? position.top_right : legendPosition == "Top Left" ? position.top_left : legendPosition == "Middle Right" ? position.middle_right : legendPosition == "Middle Left" ? position.middle_left : legendPosition == "Bottom Left" ? position.bottom_left : position.bottom_right

f_legend_size() =>
    legendSize == "Small" ? size.small : legendSize == "Normal" ? size.normal : size.tiny

var table  legendTable      = na
var string lastLegendPosStr = na

LEGEND_ROWS = 26  // header + 25 abbreviation rows

if not showLegend_eff
    if not na(legendTable)
        table.delete(legendTable)
        legendTable := na
    lastLegendPosStr := na
else
    if na(legendTable) or legendPosition != lastLegendPosStr
        if not na(legendTable)
            table.delete(legendTable)
        legendTable := table.new(f_legend_pos(), columns = 2, rows = LEGEND_ROWS,
             bgcolor      = f_alpha(dashBgColor, 10),
             border_width = 1,
             border_color = color.new(#333333, 0))
        lastLegendPosStr := legendPosition

    if barstate.islast
        sz      = f_legend_size()
        cellBg  = f_alpha(dashBgColor, 0)
        textCol = dashTextColor

        table.cell(legendTable, 0, 0, "Abbr",    text_color = textCol, text_size = sz, bgcolor = f_alpha(dashBgColor, 0))
        table.cell(legendTable, 1, 0, "Meaning", text_color = textCol, text_size = sz, bgcolor = f_alpha(dashBgColor, 0))

        // Each row: short label (left) + plain-English expansion (right).
        // Order roughly groups by module: structure, OBs, FVGs, liquidity,
        // P/D, key levels, ADR, SMT, CRT, sessions.
        table.cell(legendTable, 0,  1, "BOS",     text_color = textCol, text_size = sz)
        table.cell(legendTable, 1,  1, "Break of Structure",              text_color = textCol, text_size = sz)
        table.cell(legendTable, 0,  2, "CHoCH",   text_color = textCol, text_size = sz)
        table.cell(legendTable, 1,  2, "Change of Character",             text_color = textCol, text_size = sz)
        table.cell(legendTable, 0,  3, "iBOS",    text_color = textCol, text_size = sz)
        table.cell(legendTable, 1,  3, "Internal Break of Structure",     text_color = textCol, text_size = sz)
        table.cell(legendTable, 0,  4, "iCHoCH",  text_color = textCol, text_size = sz)
        table.cell(legendTable, 1,  4, "Internal Change of Character",    text_color = textCol, text_size = sz)
        table.cell(legendTable, 0,  5, "HH/HL",   text_color = textCol, text_size = sz)
        table.cell(legendTable, 1,  5, "Higher High / Higher Low",        text_color = textCol, text_size = sz)
        table.cell(legendTable, 0,  6, "LH/LL",   text_color = textCol, text_size = sz)
        table.cell(legendTable, 1,  6, "Lower High / Lower Low",          text_color = textCol, text_size = sz)
        table.cell(legendTable, 0,  7, "OB",      text_color = textCol, text_size = sz)
        table.cell(legendTable, 1,  7, "Order Block",                     text_color = textCol, text_size = sz)
        table.cell(legendTable, 0,  8, "BB",      text_color = textCol, text_size = sz)
        table.cell(legendTable, 1,  8, "Breaker Block",                   text_color = textCol, text_size = sz)
        table.cell(legendTable, 0,  9, "FVG",     text_color = textCol, text_size = sz)
        table.cell(legendTable, 1,  9, "Fair Value Gap",                  text_color = textCol, text_size = sz)
        table.cell(legendTable, 0, 10, "iFVG",    text_color = textCol, text_size = sz)
        table.cell(legendTable, 1, 10, "Inverse Fair Value Gap",          text_color = textCol, text_size = sz)
        table.cell(legendTable, 0, 11, "CE",      text_color = textCol, text_size = sz)
        table.cell(legendTable, 1, 11, "Consequent Encroachment",         text_color = textCol, text_size = sz)
        table.cell(legendTable, 0, 12, "EQH",     text_color = textCol, text_size = sz)
        table.cell(legendTable, 1, 12, "Equal Highs (liquidity)",         text_color = textCol, text_size = sz)
        table.cell(legendTable, 0, 13, "EQL",     text_color = textCol, text_size = sz)
        table.cell(legendTable, 1, 13, "Equal Lows (liquidity)",          text_color = textCol, text_size = sz)
        table.cell(legendTable, 0, 14, "IDM",     text_color = textCol, text_size = sz)
        table.cell(legendTable, 1, 14, "Inducement",                      text_color = textCol, text_size = sz)
        table.cell(legendTable, 0, 15, "EQ",      text_color = textCol, text_size = sz)
        table.cell(legendTable, 1, 15, "Equilibrium (range 50%)",         text_color = textCol, text_size = sz)
        table.cell(legendTable, 0, 16, "Prem",    text_color = textCol, text_size = sz)
        table.cell(legendTable, 1, 16, "Premium zone (above range midpoint)", text_color = textCol, text_size = sz)
        table.cell(legendTable, 0, 17, "Disc",    text_color = textCol, text_size = sz)
        table.cell(legendTable, 1, 17, "Discount zone (below range midpoint)", text_color = textCol, text_size = sz)
        table.cell(legendTable, 0, 18, "PDH/PDL", text_color = textCol, text_size = sz)
        table.cell(legendTable, 1, 18, "Prior Day High / Low",            text_color = textCol, text_size = sz)
        table.cell(legendTable, 0, 19, "PWH/PWL", text_color = textCol, text_size = sz)
        table.cell(legendTable, 1, 19, "Prior Week High / Low",           text_color = textCol, text_size = sz)
        table.cell(legendTable, 0, 20, "PMH/PML", text_color = textCol, text_size = sz)
        table.cell(legendTable, 1, 20, "Prior Month High / Low",          text_color = textCol, text_size = sz)
        table.cell(legendTable, 0, 21, "NY Mid",  text_color = textCol, text_size = sz)
        table.cell(legendTable, 1, 21, "NY Midnight Open (00:00 EST)",    text_color = textCol, text_size = sz)
        table.cell(legendTable, 0, 22, "ADR",     text_color = textCol, text_size = sz)
        table.cell(legendTable, 1, 22, "Average Daily Range",             text_color = textCol, text_size = sz)
        table.cell(legendTable, 0, 23, "Judas",   text_color = textCol, text_size = sz)
        table.cell(legendTable, 1, 23, "NY-Mid ± ADR/3 trap level",      text_color = textCol, text_size = sz)
        table.cell(legendTable, 0, 24, "SMT",     text_color = textCol, text_size = sz)
        table.cell(legendTable, 1, 24, "Smart Money Technique (divergence)", text_color = textCol, text_size = sz)
        table.cell(legendTable, 0, 25, "CRT",     text_color = textCol, text_size = sz)
        table.cell(legendTable, 1, 25, "Candle Range Theory",             text_color = textCol, text_size = sz)


//=============================================================================
// SECTION 14 — CANDLE COLORING
//=============================================================================
// Two modes (see G_VISUAL inputs):
//   "Direction" : color by the candle's own close vs open. This is the default —
//                 it matches what most traders mean by "candle coloring": green
//                 bullish bars, red bearish bars.
//   "Structure" : color by the swing-bias state. Every candle in a bullish-bias
//                 trend tints green; every candle in a bearish-bias trend tints
//                 red. Useful for trend-at-a-glance, but counter-intuitive
//                 because individual bearish candles still get the bullish tint.
candleColorByDir    = close > open ? bullCandleColor : close < open ? bearCandleColor : na
candleColorByStruct = swgStruct.bias == 1 ? bullCandleColor : swgStruct.bias == -1 ? bearCandleColor : na
candleColor         = enableCandleColor ? (candleColorMode == "Structure" ? candleColorByStruct : candleColorByDir) : na
barcolor(candleColor)


//=============================================================================
// SECTION 14B — EMA LINES ON CHART (optional)
//=============================================================================
// Plots the same fast/slow EMAs used by the dashboard EMA bias column.
// Off by default — opt-in for traders who want to see the cross visually.
// Periods come from dashEmaFast / dashEmaSlow (Dashboard input group), so
// changing those inputs updates both the bias column AND the plotted lines.
emaFastChart = ta.ema(close, dashEmaFast)
emaSlowChart = ta.ema(close, dashEmaSlow)
plot(showEMALines ? emaFastChart : na, color = emaFastColor, linewidth = 2, title = "EMA Fast (Bias)", display = display.pane)
plot(showEMALines ? emaSlowChart : na, color = emaSlowColor, linewidth = 2, title = "EMA Slow (Bias)", display = display.pane)


//=============================================================================
// SECTION 15 — ALERT CONDITIONS
//=============================================================================
// Track previous swing bias so we can classify a break as BOS (continuation
// or first-direction-establish) vs CHoCH (bias flip).
var int prevSwgBias = 0

bullBOSEvent   = barstate.isconfirmed and swgStruct.bullBreakNow and prevSwgBias != -1
bullCHoCHEvent = barstate.isconfirmed and swgStruct.bullBreakNow and prevSwgBias == -1
bearBOSEvent   = barstate.isconfirmed and swgStruct.bearBreakNow and prevSwgBias !=  1
bearCHoCHEvent = barstate.isconfirmed and swgStruct.bearBreakNow and prevSwgBias ==  1

alertcondition(bullBOSEvent and barstate.isconfirmed,   title="Synvoya: Bullish BOS",     message="Bullish BOS on {{ticker}} {{interval}}")
alertcondition(bearBOSEvent and barstate.isconfirmed,   title="Synvoya: Bearish BOS",     message="Bearish BOS on {{ticker}} {{interval}}")
alertcondition(bullCHoCHEvent and barstate.isconfirmed, title="Synvoya: Bullish CHoCH",   message="Bullish CHoCH on {{ticker}} {{interval}}")
alertcondition(bearCHoCHEvent and barstate.isconfirmed, title="Synvoya: Bearish CHoCH",   message="Bearish CHoCH on {{ticker}} {{interval}}")
alertcondition(fvgTouchEvent and barstate.isconfirmed,  title="Synvoya: FVG Touched",     message="FVG touched on {{ticker}} {{interval}}")
alertcondition(liqSweepEvent and barstate.isconfirmed,  title="Synvoya: Liquidity Sweep", message="Liquidity swept on {{ticker}} {{interval}}")
// CRT alert respects the same crtActive gate that controls rendering, so
// users with htfOnly enabled don't get 1m/5m noise alerts.
alertcondition(isCRT and crtActive and barstate.isconfirmed, title="Synvoya: CRT Detected", message="CRT candle on {{ticker}} {{interval}}")
alertcondition(smtDivEvent and barstate.isconfirmed,    title="Synvoya: SMT Divergence",  message="SMT divergence on {{ticker}} {{interval}}")

// Capture the post-update bias for the next bar's classification.
prevSwgBias := swgStruct.bias


// ============================================================
// End of indicator — all 13 modules implemented (sections 3–13B + alerts +
// candle coloring).
// ============================================================
````
