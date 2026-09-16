<!-- tradingview-pine-id: PUB;b62452a8f86847f88d99a55abb115685 -->
<!-- tradingview-pine-version: 4.0 -->
<!-- tradingviewscripts-format: 1 -->
# CapitalCompassCore

Source: https://www.tradingview.com/script/svDP1lBo-CapitalCompassCore/

## Description

Capital Compass Core

Capital Compass Core is the shared Pine Script framework for the Capital Compass ecosystem. It centralizes reusable calculations, state definitions, visual standards, market-context logic, risk logic, portfolio helpers, strategy utilities, panel functions, formatting tools, and alert infrastructure used across Capital Compass scripts.

The library is designed to keep Market Navigator, Tactical Navigator, Strategy Lab, Portfolio Compass, and future Capital Compass tools operating from the same definitions instead of maintaining duplicate implementations across multiple scripts.

Purpose

Capital Compass Core is infrastructure rather than a standalone trading indicator.

The library calculates and standardizes reusable logic. Consuming indicators and strategies remain responsible for user inputs, plots, fills, chart markers, alert conditions, strategy orders, and script-specific interpretation.

Core calculates and standardizes. The consuming script orchestrates and renders.

Core systems

Reusable functionality includes:

• EMA, SMA, RMA, WMA, VWMA, HMA, DEMA, TEMA, and VWAP
• Moving-average structure, compression, expansion, zones, crosses, and standardized MA hierarchy
• 20-SMA / 21-EMA Fast Trend Zone
• Ichimoku calculations
• Bollinger Bands
• ATR, relative volume, drawdown, price-shock, and volatility calculations
• SuperTrend and multi-SuperTrend agreement
• RSI/MFI/MACD momentum components and consolidated momentum states
• Market regime, risk, opportunity, and market-permission scoring
• Tactical market phases and transition states
• Market Navigator state aggregation
• Price structure, pivots, and regular divergence
• Asset-profile presets
• Portfolio allocation and deployment calculations
• Account-context helpers
• Position sizing, ATR stops, targets, trailing logic, reward/risk, R multiples, expectancy, and strategy-quality helpers
• Confirmed higher-timeframe data helpers
• Relative-strength calculations
• Alert-event routing and transition helpers
• JSON and text formatting
• Theme-aware panels, table cells, text, borders, fills, and semantic state backgrounds

State and color standard

Capital Compass uses a consistent semantic visual language:

• Green = bullish / favorable
• Red = bearish / unfavorable
• Orange = caution / transition / sideways / neutral / mixed
• Gray = inactive / unavailable / insufficient data
• Blue = informational / fast-trend reference
• Magenta = major structural reference

Moving-average identity colors are separate from directional state colors. This allows a moving average to retain a recognizable identity while optional Trend mode communicates bullish, bearish, or transitional conditions.

The standardized moving-average hierarchy includes:

8, 13, 20, 21, 34, 50, 55, 89, 100, and 200 periods.

Primary structural references:

• 20 / 21 = fast trend
• 50 / 55 = intermediate trend / caution zone
• 200 = major long-term structural reference

Capital Compass Core also provides theme-aware helpers derived from the active TradingView chart colors so consuming scripts can remain readable across light and dark chart themes.

Capital Compass ecosystem

Market Navigator
Long-term market condition, regime, risk, opportunity, portfolio context, and review.

Tactical Navigator
Tactical trend, momentum, transition, Fast Trend Zone, volatility, and market-phase analysis.

Strategy Lab
Research, hypothesis testing, backtesting support, position sizing, risk planning, and strategy evaluation.

Portfolio Compass
Portfolio allocation, deployment, account context, and long-term capital-management support.

Shared calculations should be imported from Capital Compass Core rather than independently duplicated inside each script.

Library usage

Import the library with:

import DrGetDown/CapitalCompassCore/1 as CC

Examples of shared functionality include:

CC.ma(...)
CC.maColor(...)
CC.fastTrendZone(...)
CC.marketNavigatorState(...)
CC.tacticalPhase(...)
CC.momentumScore(...)
CC.stateColor(...)
CC.panelPos(...)
CC.strategyPlan(...)

Published library versions are intentionally explicit. Consuming scripts should migrate only after a newer Core release has been compiled, tested, and validated.

Design principles

• Maintain one definition for shared calculations and state meanings.
• Separate market-state colors from moving-average identity colors.
• Keep reusable calculations in Core whenever technically practical.
• Keep script-specific interpretation and rendering in the consuming script.
• Avoid unnecessary duplicate or correlated calculations.
• Use confirmed higher-timeframe data where explicitly specified.
• Keep risk and position-sizing mathematics separate from actual strategy order placement.
• Preserve consistent panel placement, formatting, abbreviations, state meanings, and visual behavior across the ecosystem.
• Test significant shared changes before promoting them across dependent Capital Compass scripts.

Limitations

Capital Compass Core does not predict future prices and does not guarantee profitable trades or prevent losses.

Market regimes, momentum states, tactical phases, opportunity scores, risk scores, divergences, moving-average structures, and strategy statistics are analytical classifications based on supplied market data and configured assumptions. They should not be interpreted as guarantees of future performance.

Backtest statistics describe historical results and do not guarantee similar future results.

Portfolio, allocation, deployment, and position-sizing helpers provide mathematical and analytical context only. Actual decisions remain dependent on objectives, portfolio circumstances, risk tolerance, time horizon, liquidity needs, taxes, diversification, and independent research.

Version

Internal Core version: 1.0.0
TradingView library release: /1

Capital Compass
[ C.C. — C O R E ]

OBSERVE • DISCERN • PREPARE • ACT WISELY

Tuned to the signal. Anchored to the mission.

---

## Source Code

````pine
// [ C.C. — ⚙️ CORE ]
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © DrGetDown — Capital Compass Core.
//@version=6
library("CapitalCompassCore", overlay = true, dynamic_requests = true)
//╔════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
//║                                                                                                                    ║
//║          ░▒▓██████████████████████████████████████████████████████████████████████████████████████████▓▒░          ║
//║                                                                                                                    ║
//║               ██████╗ ██████╗      ██████╗ ███████╗████████╗    ██████╗  ██████╗ ██╗    ██╗███╗   ██╗              ║
//║               ██╔══██╗██╔══██╗    ██╔════╝ ██╔════╝╚══██╔══╝    ██╔══██╗██╔═══██╗██║    ██║████╗  ██║              ║
//║               ██║  ██║██████╔╝    ██║  ███╗█████╗     ██║       ██║  ██║██║   ██║██║ █╗ ██║██╔██╗ ██║              ║
//║               ██║  ██║██╔══██╗    ██║   ██║██╔══╝     ██║       ██║  ██║██║   ██║██║███╗██║██║╚██╗██║              ║
//║               ██████╔╝██║  ██║    ╚██████╔╝███████╗   ██║       ██████╔╝╚██████╔╝╚███╔███╔╝██║ ╚████║              ║
//║               ╚═════╝ ╚═╝  ╚═╝     ╚═════╝ ╚══════╝   ╚═╝       ╚═════╝  ╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═══╝              ║
//║                                                                                                                    ║
//║          ░▒▓██████████████████████████████████████████████████████████████████████████████████████████▓▒░          ║
//║                                                                                                                    ║
//╚════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{
//╔════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
//║                                                                                                                    ║
//║                                    ╔══════════════════════════════════════════╗                                    ║
//║                                    ║    T H E   S I G N A L                   ║                                    ║
//║                                    ║              W A T C H M A N             ║                                    ║
//║                                    ╚══════════════════════════════════════════╝                                    ║
//║                                                                                                                    ║
//║                                         CAPITAL • MARKET • MEDIA SENTINEL                                          ║
//║                                                                                                                    ║
//╠═══════════════════════════════════════════◢◤  SYSTEM INITIALIZATION  ◥◣════════════════════════════════════════════║
//║                                                                                                                    ║
//║                                                     N / 000°                                                       ║
//║                                                        ▲                                                           ║
//║                                                    ╲   │   ╱                                                       ║
//║                                                 NW  ╲  │  ╱  NE                                                    ║
//║                                              315° ───╲ │ ╱─── 045°                                                 ║
//║                                         W / 270° ◀━━━━━◉━━━━━▶ 090° / E                                            ║
//║                                              225° ───╱ │ ╲─── 135°                                                 ║
//║                                                 SW  ╱  │  ╲  SE                                                    ║
//║                                                    ╱   │   ╲                                                       ║
//║                                                        ▼                                                           ║
//║                                                     S / 180°                                                       ║
//║                                                                                                                    ║
//║                                                  CAPITAL  COMPASS                                                  ║
//║                                        DIRECTION • DISCERNMENT • PURPOSE                                           ║
//║                                                                                                                    ║
//╠════════════════════════════════════════════════◢◤  CORE BOOT  ◥◣═══════════════════════════════════════════════════║
//║                                                                                                                    ║
//║                                          C A P I T A L  C O M P A S S                                              ║
//║                                                C O R E   L I B R A R Y                                             ║
//║                                                                                                                    ║
//║                                                [ C.C. — ⚙️ CORE ]                                                  ║
//║                                                                                                                    ║
//╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
//║                                                                                                                    ║
//║  PURPOSE                                                                                                           ║
//║                                                                                                                    ║
//║  Shared Pine Script framework for the Capital Compass ecosystem.                                                   ║
//║  Centralizes reusable standards, calculations, colors, states, formatting,                                         ║
//║  risk logic, portfolio logic, market logic, panel helpers, and alert utilities.                                    ║
//║                                                                                                                    ║
//║  Designed to reduce duplicated code and keep all Capital Compass scripts                                           ║
//║  operating from the same definitions, calculations, and visual standards.                                          ║
//║                                                                                                                    ║
//╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
//║  ARCHITECTURE                                                                                                      ║
//║                                                                                                                    ║
//║  CORE LIBRARY                                                                                                      ║
//║  • Constants • Colors • Enums • Calculations • States • Formatting                                                 ║
//║  • Moving Averages • Momentum • Trend • Risk • Allocation • Strategy Math                                          ║
//║  • Panel Helpers • Alert Helpers • Higher-Timeframe / Relative-Strength Helpers                                    ║
//║                                                                                                                    ║
//║  CONSUMING SCRIPT                                                                                                  ║
//║  • indicator() / strategy()                                                                                        ║
//║  • input.*()                                                                                                       ║
//║  • plot() / fill() / plotshape() / bgcolor()                                                                       ║
//║  • alertcondition()                                                                                                ║
//║  • strategy.entry() / strategy.exit() / strategy.close()                                                           ║
//║                                                                                                                    ║
//║  Core calculates and standardizes. The consuming script orchestrates and renders.                                  ║
//║                                                                                                                    ║
//╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
//║  CORE SYSTEMS                                                                                                      ║
//║                                                                                                                    ║
//║  🎨 STYLE .......... Universal palette • Semantic colors • auto light/dark panels • text / panel sizing            ║
//║  🎢 MA ENGINE ...... EMA • SMA • RMA • WMA • VWMA • HMA • DEMA • TEMA • VWAP                                       ║
//║  📈 TREND .......... Ichimoku • Fast Trend Zone • SuperTrend • Bands • MA structure                                ║
//║  ⚡ MOMENTUM ........ MACD • RSI/MFI components • Unified momentum score • Momentum phases                          ║
//║  🌐 REGIME ......... Market Regime • Risk • Opportunity • Compass bearing                                          ║
//║  🛡 RISK ........... Drawdown • ATR • RVOL • Price shocks • Stress clusters                                        ║
//║  🧭 STRUCTURE ...... Pivots • HH/HL • LH/LL • Divergence                                                           ║
//║  🎯 ALLOCATION ..... Target allocation • Under/overweight • Deployment guidance                                    ║
//║  🧪 STRATEGY ....... Position sizing • Stops • Targets • Trailing logic • Direction controls                       ║
//║  🔔 EVENTS ......... Event priority • Alert groups • Event codes • Readable / JSON formatting                      ║
//║                                                                                                                    ║
//╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
//║  MOVING-AVERAGE STANDARD                                                                                           ║
//║                                                                                                                    ║
//║  Periods ......... 8 • 13 • 20 • 21 • 34 • 50 • 55 • 89 • 100 • 200                                                ║
//║                                                                                                                    ║
//║  Identity Colors . 8 Cyan • 13 Teal • 20 Blue • 21 Royal Blue • 34 Indigo                                          ║
//║                    50/55 Orange • 89 Violet • 100 Slate • 200 Magenta                                              ║
//║                                                                                                                    ║
//║  Color Modes ..... Period • Trend • Mono                                                                           ║
//║  Fill Modes ...... Period • EMA/SMA State • Trend • Mono                                                           ║
//║                                                                                                                    ║
//║  Period colors identify the MA. Trend colors communicate market state.                                             ║
//║                                                                                                                    ║
//╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
//║  CAPITAL COMPASS ECOSYSTEM                                                                                         ║
//║                                                                                                                    ║
//║  🧭 MARKET NAV .... Long-term market condition, portfolio context, and review                                      ║
//║  🎯 TACTICAL NAV .. Tactical trend, timing, momentum, and transition conditions                                    ║
//║  🧪 STRATEGY LAB .. Research, testing, validation, and strategy experimentation                                    ║
//║  🧭 PORTFOLIO ..... Long-term portfolio-monitoring and allocation context                                          ║
//║                                                                                                                    ║
//║  Each script should import Core rather than duplicate shared calculations.                                         ║
//║                                                                                                                    ║
//╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
//║  LIBRARY USE                                                                                                       ║
//║                                                                                                                    ║
//║  import DrGetDown/CapitalCompassCore/<VERSION> as CC                                                               ║
//║                                                                                                                    ║
//║  Examples:                                                                                                         ║
//║      CC.ma(...)                                                                                                    ║
//║      CC.maColor(...)                                                                                               ║
//║      CC.marketRegimeScore(...)                                                                                     ║
//║      CC.momentumScore(...)                                                                                         ║
//║      CC.stateColor(...)                                                                                            ║
//║      CC.panelPos(...)                                                                                              ║
//║                                                                                                                    ║
//║  Published library versions are intentionally explicit.                                                            ║
//║  Update consuming scripts only after a new Core version is tested.                                                 ║
//║                                                                                                                    ║
//╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
//║  DEVELOPMENT RULE                                                                                                  ║
//║                                                                                                                    ║
//║  • Reusable logic belongs in Core whenever technically practical.                                                  ║
//║  • Script-specific interpretation and rendering remain in the consuming script.                                    ║
//║  • Avoid duplicate calculations and conflicting definitions across scripts.                                        ║
//║  • Preserve universal colors, abbreviations, panel behavior, and state meanings.                                   ║
//║  • New shared features should be tested in Strategy Lab before broad promotion when appropriate.                   ║
//║                                                                                                                    ║
//╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
//║  VERSIONING                                                                                                        ║
//║                                                                                                                    ║
//║  Internal Core version .... CORE_VERSION = "1.3.0"                                                                 ║
//║  TradingView release ...... CapitalCompassCore/4                                                                   ║
//║                                                                                                                    ║
//║  Internal semantic versioning and TradingView publication versions are separate.                                   ║
//║                                                                                                                    ║
//╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
//║                                                                                                                    ║
//║             OBSERVE  →  DISCERN  →  PREPARE  →  ACT WISELY                                                         ║
//║                                                                                                                    ║
//║  Core is infrastructure — not a trading signal by itself.                                                          ║
//║  Decisions remain dependent on the consuming indicator, strategy, portfolio,                                       ║
//║  risk tolerance, time horizon, allocation, and investment thesis.                                                  ║
//║                                                                                                                    ║
//╠═══════════════════════════════════════════════◢◤  OPERATING CODE  ◥◣═══════════════════════════════════════════════╣
//║                                                                                                                    ║
//║                                   O B S E R V E   T H E   S I G N A L                                              ║
//║                                   D I S C E R N   T H E   D I R E C T I O N                                        ║
//║                                   M O V E   W I T H   P U R P O S E                                                ║
//║                                                                                                                    ║
//║                                “Tuned to the signal. Anchored to the mission.”                                     ║
//║                                                                                                                    ║
//╠════════════════════════════════════════════════◥◣  CODE BEGINS  ◢◤═════════════════════════════════════════════════╣
//║                                                                                                                    ║
//║          ░▒▓██████████████████████████████████████████████████████████████████████████████████████████▓▒░          ║
//║                                                                                                                    ║
//╚════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━}
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{

//══════════════════════════════════════════════════════════════════════════════
// 01. VERSION / SYSTEM CONSTANTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{

export const string CORE_NAME         = "Capital Compass Core"
export const string CORE_VERSION      = "1.3.0"
export const string CORE_RELEASE      = "TradingView /4"
export const string CC_BRAND          = "CAPITAL COMPASS"
export const string CC_CORE_TAG       = "[ C.C. — ⚙️ CORE ]"
export const string CC_NAV_TAG        = "[ C.C. — 🧭 NAV ]"
export const string CC_TAC_TAG        = "[ C.C. — 🎯 TAC ]"
export const string CC_LAB_TAG        = "[ C.C. — 🧪 LAB ]"
export const string CC_NAV_NAME       = "Market Navigator"
export const string CC_TAC_NAME       = "Tactical Navigator"
export const string CC_LAB_NAME       = "Strategy Lab"
export const string CC_SIGNATURE      = "Tuned to the signal. Anchored to the mission."
export const string CC_OPERATING_CODE = "OBSERVE • DISCERN • PREPARE • ACT WISELY"
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────}

//══════════════════════════════════════════════════════════════════════════════
// 02. UNIVERSAL INPUT GROUP TITLES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{
// Short names intentionally keep Settings compact.
//══════════════════════════════════════════════════════════════════════════════

export const string GP_GENERAL        = "⚙ General"
export const string GP_CONTEXT        = "🧭 Context"
export const string GP_TF             = "⏱ TF"
export const string GP_CALC           = "⚙ Calc"
export const string GP_ACCOUNT        = "🏦 Acct"
export const string GP_ALLOCATION     = "🎯 Alloc"
export const string GP_DEPLOYMENT     = "💵 Deploy"
export const string GP_PROFILE        = "🧬 Asset"
export const string GP_PROFILE_CUSTOM = "🛠 Custom"
export const string GP_CONFIRM        = "📅 Wk / Bench"
export const string GP_TREND          = "📈 Trend"
export const string GP_MA             = "🎢 MAs"
export const string GP_ICHIMOKU       = "☁ Ichi"
export const string GP_BANDS          = "🧵 Bands"
export const string GP_MOM            = "⚡ Mom"
export const string GP_MOMENTUM       = "⚡ Mom"
export const string GP_VOL            = "🌪 Vol / RVOL"
export const string GP_DRAWDOWN       = "⚠ Drawdown"
export const string GP_RISK           = "🛡 Risk"
export const string GP_REGIME         = "🌐 Regime"
export const string GP_STRUCTURE      = "🧭 Struct"
export const string GP_DIVERGENCE     = "〽 Div"
export const string GP_LEVELS         = "📏 Levels"
export const string GP_ALERTS         = "🔔 Alerts"
export const string GP_CHART          = "📊 Chart"
export const string GP_CHART_LINES    = "🎢 Lines"
export const string GP_CONSOLE        = "⚡ Console"
export const string GP_DASHBOARD      = "▣ Dash"
export const string GP_PANEL          = "▣ Panels"
export const string GP_STYLE          = "🎨 Style"
export const string GP_STRATEGY       = "🧪 Strategy"
export const string GP_STRAT          = "🧪 Strat"
export const string GP_PORT           = "💼 Port"
export const string GP_RISK_MGMT      = "🛡 Risk Mgmt"
export const string GP_BACKTEST       = "🧪 Backtest"
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────}

//══════════════════════════════════════════════════════════════════════════════
// 03. UNIVERSAL INPUT LABELS / ABBREVIATIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{

export const string IN_SHOW       = "👁"
export const string IN_POS        = "📍 Pos"
export const string IN_TEXT       = "🔤 Txt"
export const string IN_SIZE       = "📐 Sz"
export const string IN_COLOR      = "🎨 Clr"
export const string IN_MA_COLOR   = "🎨 MA Clr"
export const string IN_FILL       = "🌈 Fill"
export const string IN_FILL_MODE  = "🌈 Mode"
export const string IN_FILL_TRANS = "🌫 Fill %"
export const string IN_LEN        = "Len"
export const string IN_SRC        = "Src"
export const string IN_TF         = "TF"
export const string IN_FAST       = "Fast"
export const string IN_MID        = "Mid"
export const string IN_SLOW       = "Slow"
export const string IN_LONG       = "Long"
export const string IN_SIG        = "Sig"
export const string IN_HIST       = "Hist"
export const string IN_RECOV      = "↗ Recov"
export const string IN_ACCUM      = "🌱 Accum"
export const string IN_RISK       = "🛡 Risk"
export const string IN_PLATFORM   = "🏦 Plat"
export const string IN_ACCOUNT    = "💼 Acct"
export const string IN_PROFILE    = "🧬 Asset"
export const string IN_BENCH      = "📊 Bench"
export const string IN_RVOL       = "📦 RVOL"
export const string IN_ATR        = "🌪 ATR"
export const string IN_DD         = "📉 DD"
export const string IN_WIDTH      = "↔ W"
export const string IN_TRANS      = "🌫 %"
export const string IN_MODE       = "Mode"
export const string IN_DIR        = "↔ Dir"
export const string IN_RISK_PCT   = "🛡 Risk %"
export const string IN_MAX_POS    = "📦 Max %"
export const string IN_TRAIL      = "↗ Trail"
export const string IN_TP         = "🎯 TP"
export const string IN_SL         = "🛑 SL"
export const string IN_ALERT_FMT  = "📨 Fmt"
export const string IN_ALERT_SCOPE = "📡 Scope"
export const string IN_ALERT_UNIV  = "🌐 Univ"

export const string DIR_UP      = "↑"
export const string DIR_DOWN    = "↓"
export const string DIR_FLAT    = "→"

export const string GATE_ALLOWED = "ALLOWED"
export const string GATE_LIMITED = "LIMITED"
export const string GATE_BLOCKED = "BLOCKED"

export const string ZONE_RECLAIM = "RECLAIM"
export const string ZONE_ABOVE   = "ABOVE"
export const string ZONE_IN      = "IN ZONE"
export const string ZONE_REJECT  = "REJECT"
export const string ZONE_LOSS    = "LOSS"
export const string ZONE_BELOW   = "BELOW"
export const string ZONE_NA      = "N/A"

export const string MA_STRUCT_COMPRESSED  = "COMPRESSED"
export const string MA_STRUCT_CONTRACTING = "CONTRACTING"
export const string MA_STRUCT_BALANCED    = "BALANCED"
export const string MA_STRUCT_EXPANDING   = "EXPANDING"
export const string MA_STRUCT_TRENDING    = "TRENDING"
export const string MA_STRUCT_EXTENDED    = "EXTENDED"

export const string ST_3_BULL = "3/3 BULL"
export const string ST_2_BULL = "2/3 BULL"
export const string ST_2_BEAR = "2/3 BEAR"
export const string ST_3_BEAR = "3/3 BEAR"

export const string MOM_HOT           = "HOT"
export const string MOM_ADVANCING     = "ADVANCING"
export const string MOM_RECOVERING    = "RECOVERING"
export const string MOM_IMPROVING     = "IMPROVING"
export const string MOM_MIXED         = "MIXED"
export const string MOM_WEAKENING     = "WEAKENING"
export const string MOM_DETERIORATING = "DETERIORATING"

export const string VOL_CONTRACTING = "CONTRACTING"
export const string VOL_NORMAL      = "NORMAL"
export const string VOL_EXPANDING   = "EXPANDING"
export const string VOL_ELEVATED    = "ELEVATED"

export const string PHASE_BREAKDOWN      = "BREAKDOWN"
export const string PHASE_EXPANSION_DOWN = "EXPANSION ↓"
export const string PHASE_WEAKENING      = "WEAKENING"
export const string PHASE_BASE           = "BASE"
export const string PHASE_COMPRESSION    = "COMPRESSION"
export const string PHASE_PULLBACK       = "PULLBACK"
export const string PHASE_RECOVERY       = "RECOVERY"
export const string PHASE_ADVANCE        = "ADVANCE"
export const string PHASE_EXPANSION_UP   = "EXPANSION ↑"
export const string PHASE_EXTENDED       = "EXTENDED"

export const string REGIME_BULLISH      = "BULLISH"
export const string REGIME_CONSTRUCTIVE = "CONSTRUCTIVE"
export const string REGIME_MIXED        = "MIXED"
export const string REGIME_DEFENSIVE    = "DEFENSIVE"

export const string STRAT_LONG_OK  = "LONG OK"
export const string STRAT_SHORT_OK = "SHORT OK"
export const string STRAT_WAIT     = "WAIT"
export const string STRAT_BLOCKED  = "BLOCKED"
export const string STRAT_MANAGE   = "MANAGE"
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────}

//══════════════════════════════════════════════════════════════════════════════
// 04. UNIVERSAL SEMANTIC COLOR PALETTE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{
// Status colors answer: "What is happening?"
//══════════════════════════════════════════════════════════════════════════════

export const color C_GREEN    = #16A34A
export const color C_RED      = #DC2626
export const color C_AMBER    = #F97316
export const color C_ORANGE   = #F97316
export const color C_BLUE     = #2563EB
export const color C_INDIGO   = #4F46E5
export const color C_VIOLET   = #7C3AED
export const color C_MAGENTA  = #C026D3
export const color C_CYAN     = #0891B2
export const color C_TEAL     = #0D9488
export const color C_SLATE    = #64748B
export const color C_YELLOW   = #F97316
export const color C_PURPLE   = #7C3AED
export const color C_PINK     = #C026D3
export const color C_GRAY     = #94A3B8
export const color C_WHITE    = #F8FAFC
export const color C_BLACK    = #0F172A

export const color C_POS      = #16A34A
export const color C_BULL     = #16A34A
export const color C_NEG      = #DC2626
export const color C_BEAR     = #DC2626
export const color C_WARN     = #F97316
export const color C_CAUTION  = #F97316
export const color C_NEUTRAL  = #F97316
export const color C_SIDEWAYS = #F97316
export const color C_INFO     = #2563EB
export const color C_SPECIAL  = #C026D3
export const color C_INACTIVE = #94A3B8
export const color C_NA       = #94A3B8

export const color C_TEXT     = #E5E7EB
export const color C_MUTED    = #94A3B8
export const color C_DIM      = #475569
export const color C_BG       = #0F172A
export const color C_BG_ALT   = #1E293B
export const color C_BORDER   = #334155
export const color C_PNL_BG   = #0F172A
export const color C_PNL_ALT  = #1E293B
export const color C_PNL_TEXT = #E5E7EB
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────}

//══════════════════════════════════════════════════════════════════════════════
// 05. MOVING-AVERAGE PERIOD STANDARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{
// Period colors answer: "Which MA is this?"
// 50 and 55 intentionally share one identity color because they occupy the
// same intermediate-trend role in the Capital Compass ecosystem.
//══════════════════════════════════════════════════════════════════════════════

export const int MA_LEN_8   = 8
export const int MA_LEN_13  = 13
export const int MA_LEN_20  = 20
export const int MA_LEN_21  = 21
export const int MA_LEN_34  = 34
export const int MA_LEN_50  = 50
export const int MA_LEN_55  = 55
export const int MA_LEN_89  = 89
export const int MA_LEN_100 = 100
export const int MA_LEN_200 = 200

export const int MA_KEY_FAST = 21
export const int MA_KEY_MID  = 50
export const int MA_KEY_LONG = 200

export const color C_MA_8   = #0891B2
export const color C_MA_13  = #0D9488
export const color C_MA_20  = #3B82F6
export const color C_MA_21  = #2563EB
export const color C_MA_34  = #4F46E5
export const color C_MA_50  = #F97316
export const color C_MA_55  = #F97316
export const color C_MA_89  = #7C3AED
export const color C_MA_100 = #64748B
export const color C_MA_200 = #C026D3

export const color C_MA_FAST = #2563EB
export const color C_MA_MID  = #F97316
export const color C_MA_SLOW = #C026D3

export const int MA_WIDTH_THIN   = 1
export const int MA_WIDTH_NORMAL = 2
export const int MA_WIDTH_MAJOR  = 3
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────}

//══════════════════════════════════════════════════════════════════════════════
// 06. ENUMS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{

//@enum Universal 9-position panel placement.
export enum PanelPos
    topLeft      = "↖ Top Left"
    topCenter    = "⬆ Top Center"
    topRight     = "↗ Top Right"
    middleLeft   = "⬅ Mid Left"
    middleCenter = "⏺ Mid Center"
    middleRight  = "➡ Mid Right"
    bottomLeft   = "↙ Bot Left"
    bottomCenter = "⬇ Bot Center"
    bottomRight  = "↘ Bot Right"

//@enum Universal text sizes.
export enum TextSize
    tiny   = "Tiny"
    small  = "Small"
    normal = "Normal"
    large  = "Large"

//@enum Universal panel footprint choices.
export enum PanelSize
    compact = "Compact"
    tiny   = "Tiny"
    small  = "Small"
    normal = "Normal"
    wide   = "Wide"
    large  = "Large"

//@enum Moving-average calculation types.
export enum MAType
    ema  = "EMA"
    sma  = "SMA"
    rma  = "RMA"
    wma  = "WMA"
    vwma = "VWMA"
    hma  = "HMA"
    dema = "DEMA"
    tema = "TEMA"
    vwap = "VWAP"

//@enum Moving-average line color behavior.
export enum MAColorMode
    period = "Period"
    trend  = "Trend"
    mono   = "Mono"

//@enum EMA/SMA cloud/fill color behavior.
export enum MAFillMode
    period    = "Period"
    pairState = "EMA/SMA"
    trend     = "Trend"
    mono      = "Mono"

//@enum Universal directional/semantic state.
export enum TrendState
    bull     = "Bull"
    caution  = "Caution"
    bear     = "Bear"
    neutral  = "Neutral"
    inactive = "N/A"

//@enum Capital Compass asset profiles.
export enum AssetProfile
    etf         = "ETFs"
    stock       = "STOCKS"
    reit        = "REIT"
    bond        = "BONDS"
    commodity   = "COMMODITIES"
    crypto      = "CRYPTO"
    altcoin     = "ALTCOIN"
    custom      = "Custom"

//@enum Capital source / account context.
export enum AccountType
    roth        = "Roth IRA"
    sep         = "SEP-IRA"
    taxable     = "Taxable Brokerage"
    exchange    = "Crypto Exchange"
    cold        = "Cold Storage"
    opportunity = "Opportunity Cash"

//@enum Strategy direction control.
export enum DirectionMode
    longs       = "Longs Only"
    shorts      = "Shorts Only"
    longOnly    = "Long"
    shortOnly   = "Short"
    both        = "Both"

//@enum Market regime label.
export enum Regime
    bullish      = "Bullish"
    constructive = "Constructive"
    mixed        = "Mixed"
    defensive    = "Defensive"

//@enum Unified momentum phase.
export enum MomentumPhase
    overheated    = "OVERHEATED"
    oversold      = "OVERSOLD"
    bullish       = "BULLISH"
    bearish       = "BEARISH"
    recovering    = "RECOVERING"
    deteriorating = "DETERIORATING"
    neutral       = "NEUTRAL"
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────}

//══════════════════════════════════════════════════════════════════════════════
// 07. GENERIC MATH / SAFETY HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{

//@function Clamps a value to a floor and ceiling.
export clamp(float value, float floor, float ceiling) =>
    math.max(floor, math.min(ceiling, value))

export clampInt(int value, int floor, int ceiling) =>
    math.max(floor, math.min(ceiling, value))

//@function Safe division with a caller-supplied fallback.
export safeDiv(float numerator, float denominator, float fallback) =>
    na(numerator) or na(denominator) or denominator == 0.0 ? fallback : numerator / denominator

//@function Percent change from prior value to current value.
export pctChange(float currentValue, float priorValue) =>
    if na(currentValue) or na(priorValue) or priorValue == 0.0
        na
    else
        (currentValue / priorValue - 1.0) * 100.0

//@function Truncates a number to a fixed number of decimal places without rounding.
// Use only when explicit truncation is required instead of normal rounding.
// Note: truncation moves negative values toward zero, not toward negative infinity.
export truncate(float value, int decimalPlaces) =>
    if na(value)
        na
    else
        int places = clampInt(decimalPlaces, 0, 8)
        float factor = math.pow(10.0, places)
        int(value * factor) / factor

export scoreToConsole(float score) =>
    clamp((score + 100.0) * 0.5, 0.0, 100.0)

//@function Returns sign as -1, 0, or +1.
export sign(float value) =>
    na(value) ? 0 : value > 0.0 ? 1 : value < 0.0 ? -1 : 0

//@function Human-friendly timeframe label shared by Capital Compass scripts.
// Examples: 15 -> 15m, 60 -> 1H, 240 -> 4H, D -> 1D.
export timeframeLabel(simple string tf) =>
    float tfSeconds = timeframe.in_seconds(tf)
    string label = switch tf
        "D" => "1D"
        "W" => "1W"
        "M" => "1M"
        => tf
    if not na(tfSeconds)
        if tfSeconds < 60
            label := str.tostring(int(tfSeconds)) + "s"
        else if tfSeconds < 3600 and tfSeconds % 60 == 0
            label := str.tostring(int(tfSeconds / 60)) + "m"
        else if tfSeconds < 86400 and tfSeconds % 3600 == 0
            label := str.tostring(int(tfSeconds / 3600)) + "H"
    label
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────}

//══════════════════════════════════════════════════════════════════════════════
// 08. PANEL / TABLE HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{

export panelPos(PanelPos pos) =>
    switch pos
        PanelPos.topLeft      => position.top_left
        PanelPos.topCenter    => position.top_center
        PanelPos.topRight     => position.top_right
        PanelPos.middleLeft   => position.middle_left
        PanelPos.middleCenter => position.middle_center
        PanelPos.middleRight  => position.middle_right
        PanelPos.bottomLeft   => position.bottom_left
        PanelPos.bottomCenter => position.bottom_center
        PanelPos.bottomRight  => position.bottom_right
        => position.top_right

export textSize(TextSize txtSize) =>
    switch txtSize
        TextSize.tiny   => size.tiny
        TextSize.small  => size.small
        TextSize.normal => size.normal
        TextSize.large  => size.large
        => size.small

export panelScale(PanelSize pnlSize) =>
    switch pnlSize
        PanelSize.tiny    => 0.75
        PanelSize.compact => 0.82
        PanelSize.small   => 0.90
        PanelSize.normal  => 1.00
        PanelSize.wide    => 1.10
        PanelSize.large   => 1.20
        => 1.00

export scalePanel(float baseValue, PanelSize pnlSize) =>
    baseValue * panelScale(pnlSize)

export isWidePanel(PanelSize pnlSize) =>
    pnlSize == PanelSize.wide or pnlSize == PanelSize.large

export isCompactPanel(PanelSize pnlSize) =>
    pnlSize == PanelSize.compact or pnlSize == PanelSize.tiny or pnlSize == PanelSize.small

export panelLabel(PanelSize pnlSize, string compactText, string normalText) =>
    isCompactPanel(pnlSize) ? compactText : normalText

//@function Three-density panel label for Compact / Normal / Wide panels.
export panelLabel3(PanelSize pnlSize, string compactText, string normalText, string wideText) =>
    isCompactPanel(pnlSize) ? compactText : isWidePanel(pnlSize) ? wideText : normalText

//@function Approximate luminance for a color.
export colorLuma(color valueColor) =>
    color.r(valueColor) * 0.299 + color.g(valueColor) * 0.587 + color.b(valueColor) * 0.114

//@function True when TradingView reports a light chart background.
export chartIsLight() =>
    colorLuma(chart.bg_color) >= 150.0

//@function Active chart background color.
export chartBg() =>
    chart.bg_color

//@function Active chart foreground color.
export chartFg() =>
    chart.fg_color

//@function Theme-aware chart text color.
export chartText() =>
    chart.fg_color

//@function Soft chart border color derived from the current chart theme.
export chartBorder() =>
    color.from_gradient(0.5, 0.0, 1.0, chart.bg_color, chart.fg_color)

//@function Theme-aware panel background.
export panelBg(int transparency) =>
    color.new(chart.bg_color, clampInt(transparency, 0, 100))

//@function Theme-aware alternate panel background.
export panelAltBg(int transparency) =>
    int bounded = clampInt(transparency, 0, 100)
    int adjusted = chartIsLight() ? clampInt(bounded - 4, 0, 100) : bounded
    color.from_gradient(0.18, 0.0, 1.0, color.new(chart.bg_color, adjusted), color.new(chart.fg_color, 92))

//@function Theme-aware label-cell background.
export panelLabelBg() =>
    chartIsLight() ? color.new(chart.fg_color, 92) : color.new(chart.fg_color, 88)

//@function Theme-aware panel border/frame color.
export panelBorder(int transparency) =>
    color.new(chartBorder(), clampInt(transparency, 0, 100))

//@function Theme-aware primary panel text color.
export panelText() =>
    chart.fg_color

//@function Theme-aware muted panel text color.
export panelMutedText() =>
    chartIsLight() ? color.new(chart.fg_color, 30) : color.new(chart.fg_color, 38)

//@function Chooses readable text for a saturated background.
export contrastText(color bgColor) =>
    colorLuma(bgColor) >= 150.0 ? C_BLACK : C_WHITE

//@function Theme-adjusted transparency for chart fills.
export chartFillTransp(int transparency) =>
    int bounded = clampInt(transparency, 0, 100)
    chartIsLight() ? clampInt(bounded + 7, 0, 100) : bounded

//@function Theme-adjusted transparency for semantic panel cells.
export panelStateTransp(int transparency) =>
    int bounded = clampInt(transparency, 0, 100)
    chartIsLight() ? clampInt(bounded + 4, 0, 100) : bounded

//@function Theme-adjusted semantic background from any Capital Compass color.
export semanticBg(color baseColor, int transparency) =>
    color.new(baseColor, panelStateTransp(transparency))

//@function Readable text for theme-adjusted semantic panel backgrounds.
export semanticText(color baseColor, int transparency) =>
    panelStateTransp(transparency) >= 70 ? panelText() : contrastText(baseColor)

//@function Writes a standardized table cell. Returns true so the helper can
// be called as a statement in consuming scripts.
export tableCell(
     table tbl,
     int column,
     int row,
     string cellText,
     color textColor,
     color bgColor,
     TextSize txtSize
) =>
    table.cell(
         tbl,
         column,
         row,
         cellText,
         text_color = textColor,
         bgcolor = bgColor,
         text_size = textSize(txtSize)
    )
    true

//@function Writes a standard Capital Compass panel header cell.
export tableHeader(
     table tbl,
     int column,
     int row,
     string cellText,
     TextSize txtSize
) =>
    tableCell(tbl, column, row, cellText, panelText(), panelAltBg(8), txtSize)

//@function Writes a state-colored table cell.
export tableStateCell(
     table tbl,
     int column,
     int row,
     string cellText,
     TrendState state,
     TextSize txtSize,
     int bgTransparency
) =>
    color baseColor = switch state
        TrendState.bull     => C_POS
        TrendState.caution  => C_WARN
        TrendState.bear     => C_NEG
        TrendState.neutral  => C_NEUTRAL
        TrendState.inactive => C_INACTIVE
        => C_INACTIVE

    color bgColor = color.new(baseColor, panelStateTransp(bgTransparency))
    color txtColor = bgTransparency >= 70 ? panelText() : contrastText(baseColor)

    tableCell(
         tbl,
         column,
         row,
         cellText,
         txtColor,
         bgColor,
         txtSize
    )
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────}

//══════════════════════════════════════════════════════════════════════════════
// 09. COLOR / STATE HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{

export withTransp(color baseColor, int transparency) =>
    color.new(baseColor, clampInt(transparency, 0, 100))

export stateColor(TrendState state) =>
    switch state
        TrendState.bull     => C_POS
        TrendState.caution  => C_WARN
        TrendState.bear     => C_NEG
        TrendState.neutral  => C_NEUTRAL
        TrendState.inactive => C_INACTIVE
        => C_INACTIVE

export stateColorFromCode(float code) =>
    if na(code)
        C_INACTIVE
    else if code > 0.0
        C_POS
    else if code < 0.0
        C_NEG
    else
        C_NEUTRAL

export stateBgColor(TrendState state, int transparency) =>
    color.new(stateColor(state), panelStateTransp(transparency))

export stateCellTextColor(TrendState state, int bgTransparency) =>
    bgTransparency >= 70 ? panelText() : contrastText(stateColor(state))

export severityColor(color baseColor, int severity) =>
    int tier = clampInt(severity, 0, 3)
    int transparency = switch tier
        0 => 92
        1 => 88
        2 => 78
        => 64
    color.new(baseColor, panelStateTransp(transparency))

export stateSeverityColor(TrendState state, int severity) =>
    severityColor(stateColor(state), severity)

export stateEmoji(TrendState state) =>
    switch state
        TrendState.bull     => "🟢"
        TrendState.caution  => "🟠"
        TrendState.bear     => "🔴"
        TrendState.neutral  => "🟠"
        TrendState.inactive => "⚪"
        => "⚪"

export stateText(TrendState state) =>
    switch state
        TrendState.bull     => "Bull"
        TrendState.caution  => "Caution"
        TrendState.bear     => "Bear"
        TrendState.neutral  => "Neutral"
        TrendState.inactive => "N/A"
        => "N/A"

export stateTextLabel(TrendState state) =>
    stateEmoji(state) + " " + stateText(state)

export valueState(float value, float positiveThreshold, float negativeThreshold) =>
    switch
        na(value)                  => TrendState.inactive
        value >= positiveThreshold => TrendState.bull
        value <= negativeThreshold => TrendState.bear
        => TrendState.caution
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────}

//══════════════════════════════════════════════════════════════════════════════
// 10. MOVING AVERAGE ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{

//@function Generic MA calculator used by every Capital Compass script.
export ma(float source, MAType maType, simple int length) =>
    int safeLength = math.max(length, 1)
    float ema1Value = ta.ema(source, safeLength)
    float ema2Value = ta.ema(ema1Value, safeLength)
    float ema3Value = ta.ema(ema2Value, safeLength)

    float smaValue  = ta.sma(source, safeLength)
    float rmaValue  = ta.rma(source, safeLength)
    float wmaValue  = ta.wma(source, safeLength)
    float vwmaValue = ta.vwma(source, safeLength)
    float hmaValue  = ta.hma(source, safeLength)
    float vwapValue = ta.vwap(source)

    float demaValue = 2.0 * ema1Value - ema2Value
    float temaValue = 3.0 * (ema1Value - ema2Value) + ema3Value

    switch maType
        MAType.ema  => ema1Value
        MAType.sma  => smaValue
        MAType.rma  => rmaValue
        MAType.wma  => wmaValue
        MAType.vwma => vwmaValue
        MAType.hma  => hmaValue
        MAType.dema => demaValue
        MAType.tema => temaValue
        MAType.vwap => vwapValue
        => ema1Value

//@function Exponential moving average wrapper.
export ema(float source, simple int length) =>
    ta.ema(source, math.max(length, 1))

//@function Simple moving average wrapper.
export sma(float source, simple int length) =>
    ta.sma(source, math.max(length, 1))

//@function Running moving average wrapper.
export rma(float source, simple int length) =>
    ta.rma(source, math.max(length, 1))

//@function Weighted moving average wrapper.
export wma(float source, simple int length) =>
    ta.wma(source, math.max(length, 1))

//@function Volume-weighted moving average wrapper.
export vwma(float source, simple int length) =>
    ta.vwma(source, math.max(length, 1))

//@function Hull moving average wrapper.
export hma(float source, simple int length) =>
    ta.hma(source, math.max(length, 1))

//@function Session VWAP wrapper.
export vwap(float source) =>
    ta.vwap(source)

//@function Standard identity color for Capital Compass MA periods.
export maPeriodColor(int length) =>
    switch length
        8   => C_MA_8
        13  => C_MA_13
        20  => C_MA_20
        21  => C_MA_21
        34  => C_MA_34
        50  => C_MA_50
        55  => C_MA_55
        89  => C_MA_89
        100 => C_MA_100
        200 => C_MA_200
        => C_INFO

//@function Standard line width for the Capital Compass MA hierarchy.
export maLineWidth(int length) =>
    switch length
        20  => MA_WIDTH_NORMAL
        21  => MA_WIDTH_NORMAL
        50  => MA_WIDTH_NORMAL
        55  => MA_WIDTH_NORMAL
        200 => MA_WIDTH_MAJOR
        => MA_WIDTH_THIN

//@function Standard companion-line transparency for EMA/SMA pairs.
export maCompanionTransparency(bool isSecondaryLine) =>
    isSecondaryLine ? 32 : 0

//@function Returns high, low, and midpoint for a two-line MA zone.
export maZone(float firstLine, float secondLine) =>
    float zoneHigh = math.max(firstLine, secondLine)
    float zoneLow = math.min(firstLine, secondLine)
    float zoneMid = math.avg(zoneHigh, zoneLow)
    [zoneHigh, zoneLow, zoneMid]

//@function Price + slope state.
// Bull: price above MA and MA rising.
// Bear: price below MA and MA falling.
// Caution: price/slope disagree.
export maState(float price, float maValue) =>
    bool ready = not na(price) and not na(maValue) and not na(maValue[1])
    bool bull = ready and price > maValue and maValue > maValue[1]
    bool bear = ready and price < maValue and maValue < maValue[1]

    switch
        not ready => TrendState.inactive
        bull      => TrendState.bull
        bear      => TrendState.bear
        => TrendState.caution

export maTrendColor(float price, float maValue) =>
    stateColor(maState(price, maValue))

export maColor(
     MAColorMode mode,
     int length,
     float price,
     float maValue,
     color monoColor
) =>
    color periodColor = maPeriodColor(length)
    color trendColor  = maTrendColor(price, maValue)

    switch mode
        MAColorMode.period => periodColor
        MAColorMode.trend  => trendColor
        MAColorMode.mono   => monoColor
        => monoColor

//@function State of an EMA/SMA or any two-line MA pair.
// Useful for a same-period EMA/SMA cloud.
export maPairState(float fastLine, float slowLine) =>
    switch
        na(fastLine) or na(slowLine) => TrendState.inactive
        fastLine > slowLine          => TrendState.bull
        fastLine < slowLine          => TrendState.bear
        => TrendState.caution

export maFillColor(
     MAFillMode mode,
     int length,
     float price,
     float firstLine,
     float secondLine,
     color monoColor,
     int transparency
) =>
    [zoneHigh, zoneLow, pairMid] = maZone(firstLine, secondLine)
    bool ready = not na(price) and not na(firstLine) and not na(secondLine)
    bool priceInsideZone = ready and price >= zoneLow and price <= zoneHigh

    color periodColor = maPeriodColor(length)
    color pairColor = C_INACTIVE
    if ready
        pairColor := priceInsideZone ? C_NEUTRAL : stateColor(maPairState(firstLine, secondLine))

    color trendColor = maTrendColor(price, pairMid)

    color baseColor = switch mode
        MAFillMode.period    => periodColor
        MAFillMode.pairState => pairColor
        MAFillMode.trend     => trendColor
        MAFillMode.mono      => monoColor
        => monoColor

    color.new(baseColor, chartFillTransp(transparency))

//@function Fill color using a string mode: Period, EMA/SMA, Trend, or Mono.
export maFillColorFromString(
     string mode,
     int length,
     float price,
     float firstLine,
     float secondLine,
     color monoColor,
     int transparency
) =>
    [zoneHigh, zoneLow, pairMid] = maZone(firstLine, secondLine)
    bool ready = not na(price) and not na(firstLine) and not na(secondLine)
    bool priceInsideZone = ready and price >= zoneLow and price <= zoneHigh

    color periodColor = maPeriodColor(length)
    color pairColor = C_INACTIVE
    if ready
        pairColor := priceInsideZone ? C_NEUTRAL : stateColor(maPairState(firstLine, secondLine))

    color trendColor = maTrendColor(price, pairMid)

    color baseColor = switch mode
        "Period"  => periodColor
        "EMA/SMA" => pairColor
        "Pair"    => pairColor
        "Trend"   => trendColor
        "Mono"    => monoColor
        => trendColor

    color.new(baseColor, chartFillTransp(transparency))

export goldenCross(float fastLine, float slowLine) =>
    ta.crossover(fastLine, slowLine)

//@function Standard death-cross condition.
export deathCross(float fastLine, float slowLine) =>
    ta.crossunder(fastLine, slowLine)

//@function Relative percent spread between two MAs.
export maSpreadPct(float fastLine, float slowLine) =>
    if na(fastLine) or na(slowLine) or slowLine == 0.0
        na
    else
        (fastLine / slowLine - 1.0) * 100.0

export maRibbonSpreadPct(float highestMA, float lowestMA, float price) =>
    if na(highestMA) or na(lowestMA) or na(price) or price == 0.0
        na
    else
        math.abs(highestMA - lowestMA) / price * 100.0

export maCompressed(float ribbonSpreadPct, float maxSpreadPct) =>
    not na(ribbonSpreadPct) and ribbonSpreadPct <= maxSpreadPct

//@function Expansion test for an MA ribbon.
export maExpanded(float ribbonSpreadPct, float minSpreadPct) =>
    not na(ribbonSpreadPct) and ribbonSpreadPct >= minSpreadPct

export maSpreadNorm(float firstLine, float secondLine, float divisor) =>
    safeDiv(math.abs(firstLine - secondLine), divisor, 0.0)

export maRibbonSpreadNorm(float maFast, float maMid, float maSlow, float maLong, float divisor) =>
    float highValue = math.max(math.max(maFast, maMid), math.max(maSlow, maLong))
    float lowValue = math.min(math.min(maFast, maMid), math.min(maSlow, maLong))
    safeDiv(highValue - lowValue, divisor, 0.0)
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────}

//══════════════════════════════════════════════════════════════════════════════
// 11. FAST TREND ZONE / EMA-SMA CLOUD HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{

//@function Same-period EMA/SMA pair.
export emaSmaPair(float source, simple int length) =>
    int safeLength = math.max(length, 1)
    float emaValue = ta.ema(source, safeLength)
    float smaValue = ta.sma(source, safeLength)
    [emaValue, smaValue]

//@function 20-SMA / 21-EMA Fast Trend Zone.
export fastTrendZone(float source) =>
    float sma20 = ta.sma(source, MA_LEN_20)
    float ema21 = ta.ema(source, MA_LEN_21)
    [sma20, ema21]

//@function Fast Trend Zone directional state.
export fastTrendZoneState(float sma20, float ema21, float price) =>
    bool ready = not na(sma20) and not na(ema21) and not na(price)
    bool bull = ready and price > math.max(sma20, ema21) and ema21 >= sma20
    bool bear = ready and price < math.min(sma20, ema21) and ema21 <= sma20

    switch
        not ready => TrendState.inactive
        bull      => TrendState.bull
        bear      => TrendState.bear
        => TrendState.caution

export fastTrendZoneColor(float price, float sma20, float ema21) =>
    [zoneHigh, zoneLow, _] = maZone(sma20, ema21)
    switch
        na(price) or na(sma20) or na(ema21) => C_INACTIVE
        price > zoneHigh                    => C_POS
        price < zoneLow                     => C_NEG
        => C_WARN

export fastTrendZoneFillColor(float price, float sma20, float ema21, int transparency) =>
    color.new(fastTrendZoneColor(price, sma20, ema21), chartFillTransp(transparency))
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────}

//══════════════════════════════════════════════════════════════════════════════
// 12. ICHIMOKU / BANDS / VOLATILITY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{

export donchianMid(float highSource, float lowSource, simple int length) =>
    math.avg(
         ta.lowest(lowSource, length),
         ta.highest(highSource, length)
    )

//@function Standard Ichimoku 9/26/52-style raw lines.
// Caller controls displacement when plotting or evaluating projected spans.
export ichimoku(
     float highSource,
     float lowSource,
     simple int tenkanLength,
     simple int kijunLength,
     simple int spanBLength
) =>
    float tenkan = donchianMid(highSource, lowSource, tenkanLength)
    float kijun  = donchianMid(highSource, lowSource, kijunLength)
    float spanA  = math.avg(tenkan, kijun)
    float spanB  = donchianMid(highSource, lowSource, spanBLength)
    float cloudTop = math.max(spanA, spanB)
    float cloudBottom = math.min(spanA, spanB)
    [tenkan, kijun, spanA, spanB, cloudTop, cloudBottom]

export bollinger(
     float source,
     MAType basisType,
     simple int length,
     float multiplier
) =>
    float basis = ma(source, basisType, length)
    float dev = ta.stdev(source, length) * multiplier
    [basis, basis + dev, basis - dev]

export atr(simple int length) =>
    ta.atr(length)

export rvol(float volumeSeries, simple int length) =>
    float avgVolume = ta.sma(volumeSeries, length)
    if na(volumeSeries) or na(avgVolume) or avgVolume == 0.0
        na
    else
        volumeSeries / avgVolume

export atrExtension(float price, float reference, float atrValue) =>
    if na(price) or na(reference) or na(atrValue) or atrValue <= 0.0
        na
    else
        (price - reference) / atrValue

export drawdownPct(float price, simple int highLookback) =>
    float priorHigh = ta.highest(price, highLookback)
    if na(price) or na(priorHigh) or priorHigh == 0.0
        na
    else
        (price / priorHigh - 1.0) * 100.0

export priceShock(
     float dailyReturnPct,
     float moveThresholdPct,
     bool volumeAvailable,
     float relativeVolume,
     float rvolThreshold
) =>
    bool positive = (
         not na(dailyReturnPct) and
         dailyReturnPct >= moveThresholdPct and
         (not volumeAvailable or relativeVolume >= rvolThreshold)
    )

    bool negative = (
         not na(dailyReturnPct) and
         dailyReturnPct <= -moveThresholdPct and
         (not volumeAvailable or relativeVolume >= rvolThreshold)
    )

    [positive, negative]

export supertrend(float factor, simple int atrPeriod) =>
    ta.supertrend(factor, atrPeriod)
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────}

//══════════════════════════════════════════════════════════════════════════════
// 13. MOMENTUM ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{

export macd(
     float source,
     simple int fastLength,
     simple int slowLength,
     simple int signalLength
) =>
    float fastEMA = ta.ema(source, fastLength)
    float slowEMA = ta.ema(source, slowLength)
    float macdLine = fastEMA - slowEMA
    float signalLine = ta.ema(macdLine, signalLength)
    float histogram = macdLine - signalLine
    [macdLine, signalLine, histogram]

export oscillatorComponent(float oscillatorValue) =>
    clamp((oscillatorValue - 50.0) * 2.0, -100.0, 100.0)

export macdComponent(float macdHistogram, float atrValue) =>
    if atrValue > 0.0
        clamp(macdHistogram / atrValue * 100.0, -100.0, 100.0)
    else
        0.0

export relativeComponent(float relativeStrengthPct) =>
    clamp(relativeStrengthPct * 5.0, -100.0, 100.0)

//@function Current Capital Compass weighted momentum score.
// Unavailable components are ignored by setting the corresponding ready flag
// false. Components should already be normalized to -100..+100.
export momentumScore(
     float rsiComp,
     float mfiComp,
     float macdComp,
     float relativeComp,
     float weeklyComp,
     float rsiWeight,
     float mfiWeight,
     float macdWeight,
     float relativeWeight,
     float weeklyWeight,
     bool mfiReady,
     bool relativeReady,
     bool weeklyReady
) =>
    float effectiveWeight = (
         rsiWeight +
         (mfiReady ? mfiWeight : 0.0) +
         macdWeight +
         (relativeReady ? relativeWeight : 0.0) +
         (weeklyReady ? weeklyWeight : 0.0)
    )

    float weightedSum = (
         rsiComp * rsiWeight +
         (mfiReady ? mfiComp * mfiWeight : 0.0) +
         macdComp * macdWeight +
         (relativeReady ? relativeComp * relativeWeight : 0.0) +
         (weeklyReady ? weeklyComp * weeklyWeight : 0.0)
    )

    effectiveWeight > 0.0 ? weightedSum / effectiveWeight : 0.0

export momentumSignal(float score, simple int signalLength) =>
    ta.ema(score, signalLength)

export momentumImpulse(float score, float signal) =>
    score - signal

export bullishMomentumState(
     float score,
     float signal,
     float rsiValue,
     float macdLine,
     float macdSignal,
     bool requireWeekly,
     bool weeklyBull
) =>
    (
         score >= 20.0 and
         score > signal and
         rsiValue > 50.0 and
         macdLine > macdSignal and
         (not requireWeekly or weeklyBull)
    )

export bearishMomentumState(
     float score,
     float signal,
     float rsiValue,
     float macdLine,
     float macdSignal,
     bool requireWeekly,
     bool weeklyBear
) =>
    (
         score <= -20.0 and
         score < signal and
         rsiValue < 50.0 and
         macdLine < macdSignal and
         (not requireWeekly or weeklyBear)
    )

export recoveringMomentumState(
     bool bullishState,
     float score,
     float signal,
     float impulse,
     float priorImpulse,
     float rsiValue,
     float recoveryRsi
) =>
    (
         not bullishState and
         score > signal and
         impulse > priorImpulse and
         rsiValue >= recoveryRsi
    )

export deterioratingMomentumState(
     bool bearishState,
     float score,
     float signal,
     float impulse,
     float priorImpulse,
     float rsiValue
) =>
    (
         not bearishState and
         score < signal and
         impulse < priorImpulse and
         rsiValue < 50.0
    )

export momentumPhase(
     bool overheated,
     bool oversold,
     bool bullishState,
     bool bearishState,
     bool recoveringState,
     bool deterioratingState
) =>
    switch
        overheated       => MomentumPhase.overheated
        oversold         => MomentumPhase.oversold
        bullishState     => MomentumPhase.bullish
        bearishState     => MomentumPhase.bearish
        recoveringState  => MomentumPhase.recovering
        deterioratingState => MomentumPhase.deteriorating
        => MomentumPhase.neutral

export momentumPhaseText(MomentumPhase phase) =>
    switch phase
        MomentumPhase.overheated    => "OVERHEATED"
        MomentumPhase.oversold      => "OVERSOLD"
        MomentumPhase.bullish       => "BULLISH"
        MomentumPhase.bearish       => "BEARISH"
        MomentumPhase.recovering    => "RECOVERING"
        MomentumPhase.deteriorating => "DETERIORATING"
        MomentumPhase.neutral       => "NEUTRAL"
        => "NEUTRAL"

export momentumBearing(
     bool overheated,
     bool oversold,
     bool bullishState,
     bool bearishState,
     bool recoveringState,
     bool deterioratingState,
     bool weeklyBull,
     bool weeklyBear
) =>
    switch
        overheated                       => "⚠ NW"
        bullishState and weeklyBull      => "▲ N"
        recoveringState or weeklyBull    => "↗ NE"
        oversold                         => "⚠ SE"
        bearishState and weeklyBear      => "▼ S"
        deterioratingState or weeklyBear => "↙ SW"
        => "◆ E"
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────}

//══════════════════════════════════════════════════════════════════════════════
// 14. MARKET REGIME / RISK / OPPORTUNITY SCORING
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{

export marketRegimeScore(
     float closeValue,
     float intermediateMA,
     float longMA,
     float fastEMA,
     bool longMaRising,
     float cloudTop,
     float tenkan,
     float kijun,
     float rsiValue,
     float macdLine,
     float macdSignal,
     bool weeklyBull,
     bool relativeStrengthPositive
) =>
    int score = 0
    score += closeValue > longMA ? 1 : 0
    score += intermediateMA > longMA ? 1 : 0
    score += fastEMA > intermediateMA ? 1 : 0
    score += longMaRising ? 1 : 0
    score += not na(cloudTop) and closeValue > cloudTop ? 1 : 0
    score += tenkan > kijun ? 1 : 0
    score += rsiValue > 50.0 ? 1 : 0
    score += macdLine > macdSignal ? 1 : 0
    score += weeklyBull ? 1 : 0
    score += relativeStrengthPositive ? 1 : 0
    score

export marketRiskScore(
     float closeValue,
     float intermediateMA,
     float longMA,
     float cloudBottom,
     float tenkan,
     float kijun,
     float rsiValue,
     float macdHistogram,
     bool weeklyBear,
     float drawdownPct,
     float drawdownTier1,
     bool negativeShockOrStress,
     bool relativeStrengthNegative
) =>
    int score = 0
    score += closeValue < longMA ? 1 : 0
    score += intermediateMA < longMA ? 1 : 0
    score += not na(cloudBottom) and closeValue < cloudBottom ? 1 : 0
    score += tenkan < kijun ? 1 : 0
    score += rsiValue < 40.0 ? 1 : 0
    score += macdHistogram < 0.0 ? 1 : 0
    score += weeklyBear ? 1 : 0
    score += drawdownPct <= -drawdownTier1 ? 1 : 0
    score += negativeShockOrStress ? 1 : 0
    score += relativeStrengthNegative ? 1 : 0
    score

export marketOpportunityScore(
     bool allocationGateOpen,
     float drawdownPct,
     float drawdownTier1,
     float drawdownTier2,
     float rsiValue,
     bool mfiUsable,
     float mfiValue,
     bool weeklyBull,
     bool aboveLongMA,
     bool momentumImproving,
     bool relativeStrengthPositive,
     bool recoveryTrigger
) =>
    int score = 0
    score += allocationGateOpen ? 1 : 0
    score += drawdownPct <= -drawdownTier1 ? 1 : 0
    score += drawdownPct <= -drawdownTier2 ? 1 : 0
    score += rsiValue < 45.0 ? 1 : 0
    score += mfiUsable and mfiValue < 45.0 ? 1 : 0
    score += weeklyBull ? 1 : 0
    score += aboveLongMA ? 1 : 0
    score += momentumImproving ? 1 : 0
    score += relativeStrengthPositive ? 1 : 0
    score += recoveryTrigger ? 1 : 0
    score

export regime(int score) =>
    switch
        score >= 8 => Regime.bullish
        score >= 6 => Regime.constructive
        score >= 4 => Regime.mixed
        => Regime.defensive

export regimeText(Regime marketRegime) =>
    switch marketRegime
        Regime.bullish      => "Bullish"
        Regime.constructive => "Constructive"
        Regime.mixed        => "Mixed"
        Regime.defensive    => "Defensive"
        => "Mixed"

export marketBearing(int regimeScore, bool weeklyBull, bool weeklyBear) =>
    switch
        regimeScore >= 8 and weeklyBull => "▲ N"
        regimeScore >= 6 or weeklyBull  => "↗ NE"
        regimeScore <= 3 and weeklyBear => "▼ S"
        weeklyBear                      => "↙ SW"
        => "◆ E"

export stressCluster(
     float closeValue,
     float longMA,
     float rsiValue,
     float drawdownPct,
     float drawdownTier1,
     bool volumeAvailable,
     float relativeVolume
) =>
    (
         closeValue < longMA and
         rsiValue < 40.0 and
         drawdownPct <= -drawdownTier1 and
         (not volumeAvailable or relativeVolume >= 1.25)
    )
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────}

//══════════════════════════════════════════════════════════════════════════════
// 14B. ECOSYSTEM STATE ENGINES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{

//@function Context gate code from a manual gate label.
export gateCodeFromString(string gate) =>
    switch gate
        "Allowed" => 1.0
        "ALLOWED" => 1.0
        "Limited" => 0.0
        "LIMITED" => 0.0
        "Blocked" => -1.0
        "BLOCKED" => -1.0
        => 0.0

//@function Context gate label from a numeric gate code.
export gateStateFromCode(float gateCode) =>
    if gateCode > 0.0
        GATE_ALLOWED
    else if gateCode < 0.0
        GATE_BLOCKED
    else
        GATE_LIMITED

//@function Fast Trend Zone state from current and previous confirmed zone values.
export fastZoneState(
     float price,
     float previousPrice,
     float highValue,
     float zoneHigh,
     float zoneLow,
     float previousZoneHigh,
     float previousZoneLow
) =>
    bool unavailable = na(price) or na(previousPrice) or na(highValue) or na(zoneHigh) or na(zoneLow) or na(previousZoneHigh) or na(previousZoneLow)
    bool aboveZone = price > zoneHigh
    bool belowZone = price < zoneLow
    bool previousAboveZone = previousPrice > previousZoneHigh
    bool previousBelowZone = previousPrice < previousZoneLow
    bool reclaimZone = aboveZone and not previousAboveZone
    bool loseZone = belowZone and not previousBelowZone
    bool rejectZone = belowZone and highValue >= zoneLow

    if unavailable
        ZONE_NA
    else if reclaimZone
        ZONE_RECLAIM
    else if rejectZone
        ZONE_REJECT
    else if loseZone
        ZONE_LOSS
    else if aboveZone
        ZONE_ABOVE
    else if belowZone
        ZONE_BELOW
    else
        ZONE_IN

//@function Fast Trend Zone code.
// Positive = constructive location; negative = adverse location.
// LOSS is more severe than persistent BELOW because it represents a fresh loss of the zone.
export fastZoneCode(string zoneStateValue) =>
    switch zoneStateValue
        ZONE_RECLAIM => 3.0
        ZONE_ABOVE   => 2.0
        ZONE_IN      => 1.0
        ZONE_REJECT  => -1.0
        ZONE_BELOW   => -2.0
        ZONE_LOSS    => -3.0
        => na

//@function Fast Trend Zone semantic state.
export fastZoneTrendState(string zoneStateValue) =>
    switch zoneStateValue
        ZONE_RECLAIM => TrendState.bull
        ZONE_ABOVE   => TrendState.bull
        ZONE_IN      => TrendState.caution
        ZONE_REJECT  => TrendState.bear
        ZONE_LOSS    => TrendState.bear
        ZONE_BELOW   => TrendState.bear
        => TrendState.inactive

//@function ATR distance from a two-line zone. Inside-zone distance is zero.
export zoneDistanceAtr(float price, float zoneHigh, float zoneLow, float atrValue) =>
    if na(price) or na(zoneHigh) or na(zoneLow) or na(atrValue)
        na
    else if price > zoneHigh
        safeDiv(price - zoneHigh, atrValue, 0.0)
    else if price < zoneLow
        safeDiv(price - zoneLow, atrValue, 0.0)
    else
        0.0

//@function Four-MA stack direction.
export maStackDirection(float maFast, float maMid, float maSlow, float maLong) =>
    bool bullStack = maFast > maMid and maMid > maSlow and maSlow > maLong
    bool bearStack = maFast < maMid and maMid < maSlow and maSlow < maLong
    bullStack ? DIR_UP : bearStack ? DIR_DOWN : DIR_FLAT

//@function MA structure label from spread rank, spread direction, and stack direction.
export maStructureState(
     float spreadRank,
     float compressionRank,
     float trendRank,
     float extendedRank,
     bool spreadRising,
     bool spreadFalling,
     string stackDirection
) =>
    float rankValue = nz(spreadRank, 50.0)
    bool directionalStack = stackDirection == DIR_UP or stackDirection == DIR_DOWN

    if rankValue <= compressionRank
        MA_STRUCT_COMPRESSED
    else if rankValue >= extendedRank
        MA_STRUCT_EXTENDED
    else if directionalStack and rankValue >= trendRank
        MA_STRUCT_TRENDING
    else if spreadRising
        MA_STRUCT_EXPANDING
    else if spreadFalling
        MA_STRUCT_CONTRACTING
    else
        MA_STRUCT_BALANCED

//@function MA structure code.
export maStructureCode(string structureStateValue) =>
    switch structureStateValue
        MA_STRUCT_COMPRESSED  => -2.0
        MA_STRUCT_CONTRACTING => -1.0
        MA_STRUCT_BALANCED    => 0.0
        MA_STRUCT_EXPANDING   => 1.0
        MA_STRUCT_TRENDING    => 2.0
        MA_STRUCT_EXTENDED    => 3.0
        => na

//@function MA structure semantic state.
export maStructureTrendState(string structureStateValue, string stackDirection) =>
    bool upStructure = stackDirection == DIR_UP
    bool downStructure = stackDirection == DIR_DOWN

    if (structureStateValue == MA_STRUCT_TRENDING or structureStateValue == MA_STRUCT_EXPANDING) and upStructure
        TrendState.bull
    else if (structureStateValue == MA_STRUCT_TRENDING or structureStateValue == MA_STRUCT_EXPANDING) and downStructure
        TrendState.bear
    else if structureStateValue == MA_STRUCT_COMPRESSED or structureStateValue == MA_STRUCT_EXTENDED
        TrendState.caution
    else if structureStateValue == MA_STRUCT_BALANCED or structureStateValue == MA_STRUCT_CONTRACTING
        TrendState.neutral
    else
        TrendState.inactive

//@function SuperTrend agreement state label from a bull count.
export supertrendAgreementState(int bullCount) =>
    if bullCount >= 3
        ST_3_BULL
    else if bullCount == 2
        ST_2_BULL
    else if bullCount == 1
        ST_2_BEAR
    else
        ST_3_BEAR

//@function SuperTrend agreement code from a bull count.
export supertrendAgreementCode(int bullCount) =>
    if bullCount >= 3
        3.0
    else if bullCount == 2
        2.0
    else if bullCount == 1
        -2.0
    else
        -3.0

//@function SuperTrend agreement tuple: bull count, bear count, state label, state code.
export supertrendAgreement(float price, float stFast, float stMedium, float stSlow) =>
    bool ready = not na(price) and not na(stFast) and not na(stMedium) and not na(stSlow)
    bool fastBull = ready and price >= stFast
    bool mediumBull = ready and price >= stMedium
    bool slowBull = ready and price >= stSlow
    int bullCount = (fastBull ? 1 : 0) + (mediumBull ? 1 : 0) + (slowBull ? 1 : 0)
    int bearCount = ready ? 3 - bullCount : 0
    [bullCount, bearCount, ready ? supertrendAgreementState(bullCount) : ZONE_NA, ready ? supertrendAgreementCode(bullCount) : na]

//@function Tactical momentum tuple: state label, state code, bull score, improving score, weakening score.
export tacticalMomentum(
     float rsiValue,
     float previousRsiValue,
     float mfiValue,
     float previousMfiValue,
     float macdLine,
     float macdSignal,
     float macdHist,
     float previousMacdHist,
     float hotRsi,
     float hotMfi
) =>
    bool rsiReady = not na(rsiValue) and not na(previousRsiValue)
    bool mfiReady = not na(mfiValue) and not na(previousMfiValue)
    bool macdReady = not na(macdLine) and not na(macdSignal) and not na(macdHist) and not na(previousMacdHist)
    bool rsiBull = rsiReady and rsiValue >= 55.0
    bool mfiBull = mfiReady and mfiValue >= 50.0
    bool macdBull = macdReady and macdHist > 0.0 and macdLine >= macdSignal
    bool rsiImproving = rsiReady and rsiValue > previousRsiValue
    bool mfiImproving = mfiReady and mfiValue > previousMfiValue
    bool macdImproving = macdReady and macdHist > previousMacdHist
    bool rsiWeakening = rsiReady and rsiValue < previousRsiValue and rsiValue < 55.0
    bool mfiWeakening = mfiReady and mfiValue < previousMfiValue and mfiValue < 50.0
    bool macdWeakening = macdReady and macdHist < previousMacdHist
    int bullScore = (rsiBull ? 1 : 0) + (mfiBull ? 1 : 0) + (macdBull ? 1 : 0)
    int improveScore = (rsiImproving ? 1 : 0) + (mfiImproving ? 1 : 0) + (macdImproving ? 1 : 0)
    int weakScore = (rsiWeakening ? 1 : 0) + (mfiWeakening ? 1 : 0) + (macdWeakening ? 1 : 0)
    bool hot = rsiReady and mfiReady and macdReady and rsiValue >= hotRsi and mfiValue >= hotMfi and macdBull

    string momentumStateValue = MOM_MIXED
    if hot
        momentumStateValue := MOM_HOT
    else if bullScore == 3 and macdImproving
        momentumStateValue := MOM_ADVANCING
    else if bullScore >= 2 and improveScore >= 2
        momentumStateValue := MOM_RECOVERING
    else if improveScore >= 2
        momentumStateValue := MOM_IMPROVING
    else if weakScore >= 2
        momentumStateValue := MOM_WEAKENING

    float codeValue = switch momentumStateValue
        MOM_HOT        => 3.0
        MOM_ADVANCING  => 2.0
        MOM_RECOVERING => 1.0
        MOM_IMPROVING  => 0.0
        MOM_MIXED      => -1.0
        MOM_WEAKENING  => -2.0
        => na

    [momentumStateValue, codeValue, bullScore, improveScore, weakScore]

//@function Tactical volatility tuple: state label, state code, ATR ratio.
export volatilityProfile(
     float atrValue,
     float previousAtrValue,
     float atrBase,
     float contractThreshold,
     float expandThreshold,
     float elevatedThreshold
) =>
    float atrRatio = safeDiv(atrValue, atrBase, 1.0)
    bool atrRising = not na(atrValue) and not na(previousAtrValue) and atrValue > previousAtrValue
    bool atrFalling = not na(atrValue) and not na(previousAtrValue) and atrValue < previousAtrValue
    string volatilityStateValue = VOL_NORMAL
    if na(atrValue) or na(atrBase)
        volatilityStateValue := ZONE_NA
    else if atrRatio >= elevatedThreshold
        volatilityStateValue := VOL_ELEVATED
    else if atrRatio >= expandThreshold or atrRising and atrRatio > 1.0
        volatilityStateValue := VOL_EXPANDING
    else if atrRatio <= contractThreshold and atrFalling
        volatilityStateValue := VOL_CONTRACTING

    float codeValue = switch volatilityStateValue
        VOL_CONTRACTING => -1.0
        VOL_NORMAL      => 0.0
        VOL_EXPANDING   => 1.0
        VOL_ELEVATED    => 2.0
        => na

    [volatilityStateValue, codeValue, atrRatio]

//@function Capital Compass Tactical phase from standardized domain states.
export tacticalPhase(
     string zoneStateValue,
     string maStructureStateValue,
     string maDirectionValue,
     int stBullCount,
     string momentumStateValue,
     string volatilityStateValue,
     float distanceAtr,
     float extendedAtr
) =>
    bool zoneReclaim = zoneStateValue == ZONE_RECLAIM
    bool zoneLoss = zoneStateValue == ZONE_LOSS
    bool zoneReject = zoneStateValue == ZONE_REJECT
    bool zoneAbove = zoneStateValue == ZONE_ABOVE or zoneReclaim
    bool zoneBelow = zoneStateValue == ZONE_BELOW or zoneLoss or zoneReject
    bool zoneInside = zoneStateValue == ZONE_IN

    bool momentumHot = momentumStateValue == MOM_HOT
    bool momentumAdvancing = momentumStateValue == MOM_ADVANCING
    bool momentumRecovering = momentumStateValue == MOM_RECOVERING
    bool momentumWeakening =
         momentumStateValue == MOM_WEAKENING or
         momentumStateValue == MOM_DETERIORATING

    bool structureCompressed = maStructureStateValue == MA_STRUCT_COMPRESSED
    bool structureExpanding = maStructureStateValue == MA_STRUCT_EXPANDING
    bool structureTrending = maStructureStateValue == MA_STRUCT_TRENDING
    bool structureExtended = maStructureStateValue == MA_STRUCT_EXTENDED

    bool volatilityExpanding =
         volatilityStateValue == VOL_EXPANDING or
         volatilityStateValue == VOL_ELEVATED

    bool zoneExtended =
         math.abs(nz(distanceAtr, 0.0)) >= extendedAtr

    if zoneBelow and stBullCount <= 1 and momentumWeakening
        PHASE_BREAKDOWN

    else if zoneAbove and structureExtended and (momentumHot or zoneExtended)
        PHASE_EXTENDED

    else if (zoneReclaim or momentumRecovering) and stBullCount >= 2
        PHASE_RECOVERY

    else if structureCompressed
        PHASE_COMPRESSION

    else if zoneAbove and stBullCount >= 2 and structureExpanding and
         (momentumAdvancing or momentumHot) and volatilityExpanding
        PHASE_EXPANSION_UP

    else if zoneBelow and stBullCount <= 1 and maDirectionValue == DIR_DOWN and
         (structureExpanding or structureTrending)
        PHASE_EXPANSION_DOWN

    else if zoneInside and maDirectionValue == DIR_UP and
         stBullCount >= 2 and not momentumWeakening
        PHASE_PULLBACK

    else if zoneAbove and stBullCount >= 2 and
         (momentumAdvancing or momentumHot or momentumRecovering)
        PHASE_ADVANCE

    else if momentumWeakening
        PHASE_WEAKENING

    else
        PHASE_BASE

//@function Tactical phase code.
// Positive = constructive phase; zero = neutral base;
// negative = caution / defensive deterioration.
export tacticalPhaseCode(string phaseValue) =>
    switch phaseValue
        PHASE_EXPANSION_UP   => 5.0
        PHASE_ADVANCE        => 4.0
        PHASE_RECOVERY       => 3.0
        PHASE_PULLBACK       => 2.0
        PHASE_COMPRESSION    => 1.0
        PHASE_BASE           => 0.0
        PHASE_EXTENDED       => -1.0
        PHASE_WEAKENING      => -2.0
        PHASE_EXPANSION_DOWN => -3.0
        PHASE_BREAKDOWN      => -4.0
        => na

//@function Tactical phase semantic state.
export tacticalPhaseState(string phaseValue) =>
    switch phaseValue
        PHASE_EXPANSION_UP   => TrendState.bull
        PHASE_ADVANCE        => TrendState.bull
        PHASE_RECOVERY       => TrendState.bull
        PHASE_PULLBACK       => TrendState.neutral
        PHASE_COMPRESSION    => TrendState.caution
        PHASE_BASE           => TrendState.neutral
        PHASE_EXTENDED       => TrendState.caution
        PHASE_WEAKENING      => TrendState.caution
        PHASE_EXPANSION_DOWN => TrendState.bear
        PHASE_BREAKDOWN      => TrendState.bear
        => TrendState.inactive

//@function Default Tactical next-action text.
export tacticalNextAction(string phaseValue, float gateCode) =>
    string baseAction = switch phaseValue
        PHASE_EXPANSION_UP   => "CONFIRM BREAKOUT"
        PHASE_ADVANCE        => "RIDE TREND"
        PHASE_RECOVERY       => "WATCH RECLAIM"
        PHASE_PULLBACK       => "WATCH SUPPORT"
        PHASE_COMPRESSION    => "WAIT FOR BREAK"
        PHASE_BASE           => "OBSERVE"
        PHASE_EXTENDED       => "DO NOT CHASE"
        PHASE_WEAKENING      => "REDUCE RISK"
        PHASE_EXPANSION_DOWN => "DEFENSIVE"
        => "RISK OFF"

    gateCode < 0.0 ? "WATCH ONLY" : gateCode == 0.0 ? "LIMITED • " + baseAction : baseAction

//@function Consolidated Market Navigator tuple: regime score, risk score, opportunity score, regime label, regime state, risk state, opportunity state.
export marketNavigatorState(
     float price,
     float fastMa,
     float midMa,
     float longMa,
     float momentumScoreValue,
     float weeklyValue,
     float weeklyBaseline,
     float atrRatio,
     float drawdownPercent,
     float relativeStrength,
     float extensionAtr,
     float elevatedAtrThreshold,
     float drawdownRiskThreshold,
     float extensionThreshold
) =>
    bool priceAboveFast = price > fastMa
    bool priceAboveMid = price > midMa
    bool priceAboveLong = price > longMa
    bool fastAboveMid = fastMa > midMa
    bool midAboveLong = midMa > longMa
    bool fastRising = fastMa > fastMa[1]
    bool midRising = midMa > midMa[1]
    bool longRising = longMa > longMa[1]
    bool momentumPositive = momentumScoreValue > 0.0
    bool weeklyPositive = weeklyValue >= weeklyBaseline

    int regimeScoreValue = 0
    regimeScoreValue += priceAboveFast ? 1 : 0
    regimeScoreValue += priceAboveMid ? 1 : 0
    regimeScoreValue += priceAboveLong ? 1 : 0
    regimeScoreValue += fastAboveMid ? 1 : 0
    regimeScoreValue += midAboveLong ? 1 : 0
    regimeScoreValue += fastRising ? 1 : 0
    regimeScoreValue += midRising ? 1 : 0
    regimeScoreValue += longRising ? 1 : 0
    regimeScoreValue += momentumPositive ? 1 : 0
    regimeScoreValue += weeklyPositive ? 1 : 0

    bool belowFast = price < fastMa
    bool belowMid = price < midMa
    bool belowLong = price < longMa
    bool fastFalling = fastMa < fastMa[1]
    bool midFalling = midMa < midMa[1]
    bool longFalling = longMa < longMa[1]
    bool elevatedAtr = atrRatio >= elevatedAtrThreshold
    bool drawdownEvent = drawdownPercent <= -math.abs(drawdownRiskThreshold)
    bool normalizedMomentum = math.abs(nz(momentumScoreValue, 0.0)) <= 1.0
    bool weakMomentum = normalizedMomentum ? momentumScoreValue < -0.15 : momentumScoreValue < -15.0
    bool extensionEvent = math.abs(extensionAtr) >= math.abs(extensionThreshold)

    int riskScoreValue = 0
    riskScoreValue += belowFast ? 1 : 0
    riskScoreValue += belowMid ? 1 : 0
    riskScoreValue += belowLong ? 1 : 0
    riskScoreValue += fastFalling ? 1 : 0
    riskScoreValue += midFalling ? 1 : 0
    riskScoreValue += longFalling ? 1 : 0
    riskScoreValue += elevatedAtr ? 1 : 0
    riskScoreValue += extensionEvent ? 1 : 0
    riskScoreValue += drawdownEvent ? 1 : 0
    riskScoreValue += weakMomentum ? 1 : 0

    bool notExtended = not extensionEvent
    bool volatilityNormal = atrRatio < elevatedAtrThreshold
    bool momentumImproving = momentumScoreValue > momentumScoreValue[1]
    bool relativeStrengthPositive = relativeStrength > 0.0
    bool reclaimFast = price > fastMa and price[1] <= fastMa[1]
    bool pullbackHeld = price >= midMa and price <= fastMa
    bool riskAcceptable = riskScoreValue <= 4

    int opportunityScoreValue = 0
    opportunityScoreValue += priceAboveLong ? 1 : 0
    opportunityScoreValue += notExtended ? 1 : 0
    opportunityScoreValue += volatilityNormal ? 1 : 0
    opportunityScoreValue += momentumImproving ? 1 : 0
    opportunityScoreValue += relativeStrengthPositive ? 1 : 0
    opportunityScoreValue += weeklyPositive ? 1 : 0
    opportunityScoreValue += reclaimFast ? 1 : 0
    opportunityScoreValue += pullbackHeld ? 1 : 0
    opportunityScoreValue += momentumPositive ? 1 : 0
    opportunityScoreValue += riskAcceptable ? 1 : 0

    Regime regimeValue = regime(regimeScoreValue)
    TrendState regimeState = regimeScoreValue >= 8 ? TrendState.bull : regimeScoreValue >= 6 ? TrendState.caution : regimeScoreValue >= 4 ? TrendState.neutral : TrendState.bear
    TrendState riskStateValue = riskScoreValue >= 7 ? TrendState.bear : riskScoreValue >= 4 ? TrendState.caution : riskScoreValue >= 2 ? TrendState.neutral : TrendState.bull
    TrendState opportunityStateValue = opportunityScoreValue >= 7 ? TrendState.bull : opportunityScoreValue >= 5 ? TrendState.caution : opportunityScoreValue >= 3 ? TrendState.neutral : TrendState.inactive

    [regimeScoreValue, riskScoreValue, opportunityScoreValue, regimeText(regimeValue), regimeState, riskStateValue, opportunityStateValue]

//@function Market permission code used by Tactical Navigator and Strategy Lab: 1 allowed, 0 limited, -1 blocked.
export marketPermissionCode(int regimeScoreValue, int riskScoreValue, int opportunityScoreValue) =>
    if riskScoreValue >= 7 or regimeScoreValue <= 3
        -1.0
    else if regimeScoreValue >= 6 and riskScoreValue <= 4 and opportunityScoreValue >= 5
        1.0
    else
        0.0

//@function Market permission state label from regime, risk, and opportunity scores.
export marketPermissionState(int regimeScoreValue, int riskScoreValue, int opportunityScoreValue) =>
    gateStateFromCode(marketPermissionCode(regimeScoreValue, riskScoreValue, opportunityScoreValue))
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────}

//══════════════════════════════════════════════════════════════════════════════
// 15. RECOVERY / TRANSITION HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{

export bullishReversal(
     float openValue,
     float closeValue,
     float priorClose,
     float rsiValue,
     float priorRsi,
     float recoveryRsi
) =>
    (
         closeValue > openValue and
         closeValue > priorClose and
         rsiValue > priorRsi and
         priorRsi <= recoveryRsi
    )

export recoveryTrigger(
     bool fastEmaReclaim,
     bool rsiRecoveryCross,
     bool mfiRecoveryCross,
     bool macdBullCross,
     bool bullishReversal
) =>
    (
         fastEmaReclaim or
         rsiRecoveryCross or
         mfiRecoveryCross or
         macdBullCross or
         bullishReversal
    )

export recentlyOccurred(bool condition, simple int maxBars) =>
    int barsSince = ta.barssince(condition)
    not na(barsSince) and barsSince <= maxBars
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────}

//══════════════════════════════════════════════════════════════════════════════
// 16. STRUCTURE / PIVOTS / DIVERGENCE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{

export pivotHigh(float source, simple int leftBars, simple int rightBars) =>
    ta.pivothigh(source, leftBars, rightBars)

export pivotLow(float source, simple int leftBars, simple int rightBars) =>
    ta.pivotlow(source, leftBars, rightBars)

export structureState(
     float latestHigh,
     float priorHigh,
     float latestLow,
     float priorLow
) =>
    bool ready = (
         not na(latestHigh) and
         not na(priorHigh) and
         not na(latestLow) and
         not na(priorLow)
    )

    bool bull = ready and latestHigh > priorHigh and latestLow > priorLow
    bool bear = ready and latestHigh < priorHigh and latestLow < priorLow

    switch
        not ready => TrendState.inactive
        bull      => TrendState.bull
        bear      => TrendState.bear
        => TrendState.caution

export regularBullishDivergence(
     float latestPriceLow,
     float priorPriceLow,
     float latestOscLow,
     float priorOscLow
) =>
    (
         not na(latestPriceLow) and
         not na(priorPriceLow) and
         not na(latestOscLow) and
         not na(priorOscLow) and
         latestPriceLow < priorPriceLow and
         latestOscLow > priorOscLow
    )

export regularBearishDivergence(
     float latestPriceHigh,
     float priorPriceHigh,
     float latestOscHigh,
     float priorOscHigh
) =>
    (
         not na(latestPriceHigh) and
         not na(priorPriceHigh) and
         not na(latestOscHigh) and
         not na(priorOscHigh) and
         latestPriceHigh > priorPriceHigh and
         latestOscHigh < priorOscHigh
    )
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────}

//══════════════════════════════════════════════════════════════════════════════
// 17. ASSET PROFILE PRESETS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{
// Centralized from current Capital Compass profile logic.
//══════════════════════════════════════════════════════════════════════════════

export profileMovePct(AssetProfile profile, float customValue) =>
    switch profile
        AssetProfile.etf       => 2.5
        AssetProfile.stock     => 5.0
        AssetProfile.reit      => 4.0
        AssetProfile.bond      => 2.0
        AssetProfile.commodity => 4.0
        AssetProfile.crypto    => 7.5
        AssetProfile.altcoin   => 12.0
        AssetProfile.custom    => customValue
        => customValue

export profileRvol(AssetProfile profile, float customValue) =>
    switch profile
        AssetProfile.etf       => 1.75
        AssetProfile.stock     => 2.00
        AssetProfile.reit      => 1.80
        AssetProfile.bond      => 1.60
        AssetProfile.commodity => 1.80
        AssetProfile.crypto    => 1.80
        AssetProfile.altcoin   => 2.00
        AssetProfile.custom    => customValue
        => customValue

export profileExtensionAtr(AssetProfile profile, float customValue) =>
    switch profile
        AssetProfile.etf       => 4.0
        AssetProfile.stock     => 5.0
        AssetProfile.reit      => 4.0
        AssetProfile.bond      => 3.0
        AssetProfile.commodity => 5.0
        AssetProfile.crypto    => 6.0
        AssetProfile.altcoin   => 8.0
        AssetProfile.custom    => customValue
        => customValue

export profileDrawdown1(AssetProfile profile, float customValue) =>
    switch profile
        AssetProfile.etf       => 10.0
        AssetProfile.stock     => 15.0
        AssetProfile.reit      => 12.0
        AssetProfile.bond      => 5.0
        AssetProfile.commodity => 12.0
        AssetProfile.crypto    => 20.0
        AssetProfile.altcoin   => 30.0
        AssetProfile.custom    => customValue
        => customValue

export profileDrawdown2(AssetProfile profile, float customValue) =>
    switch profile
        AssetProfile.etf       => 20.0
        AssetProfile.stock     => 30.0
        AssetProfile.reit      => 25.0
        AssetProfile.bond      => 10.0
        AssetProfile.commodity => 25.0
        AssetProfile.crypto    => 40.0
        AssetProfile.altcoin   => 55.0
        AssetProfile.custom    => customValue
        => customValue

export profileDrawdown3(AssetProfile profile, float customValue) =>
    switch profile
        AssetProfile.etf       => 30.0
        AssetProfile.stock     => 50.0
        AssetProfile.reit      => 40.0
        AssetProfile.bond      => 20.0
        AssetProfile.commodity => 40.0
        AssetProfile.crypto    => 60.0
        AssetProfile.altcoin   => 75.0
        AssetProfile.custom    => customValue
        => customValue
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────}

//══════════════════════════════════════════════════════════════════════════════
// 18. ACCOUNT / ALLOCATION / DEPLOYMENT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{

export accountPolicy(AccountType account) =>
    switch account
        AccountType.roth =>
            "Tax-free growth: favor long holding periods and allocation discipline."
        AccountType.sep =>
            "Retirement capital: favor diversification, contributions, and low turnover."
        AccountType.taxable =>
            "Review gains, holding period, wash-sale exposure, and tax cost before selling."
        AccountType.exchange =>
            "Include exchange counterparty, custody, withdrawal, and tax-record risks."
        AccountType.cold =>
            "Verify backups, signing workflow, inheritance access, and transaction fees."
        AccountType.opportunity =>
            "Protect emergency, tax, and near-term reserves before deployment."
        => "Review account rules before acting."

export currentAllocationPct(float portfolioValue, float positionValue) =>
    if portfolioValue > 0.0
        positionValue / portfolioValue * 100.0
    else
        na

export targetPositionValue(float portfolioValue, float targetAllocationPct) =>
    if portfolioValue > 0.0 and targetAllocationPct > 0.0
        portfolioValue * targetAllocationPct / 100.0
    else
        na

export allocationGapCash(
     float portfolioValue,
     float currentPositionValue,
     float targetAllocationPct
) =>
    float targetValue = targetPositionValue(portfolioValue, targetAllocationPct)
    if na(targetValue)
        na
    else
        math.max(targetValue - currentPositionValue, 0.0)

export allocationGapPct(
     float portfolioValue,
     float currentPositionValue,
     float targetAllocationPct
) =>
    float currentPct = currentAllocationPct(portfolioValue, currentPositionValue)
    na(currentPct) ? na : targetAllocationPct - currentPct

export underweight(
     float currentAllocationPct,
     float targetAllocationPct,
     float tolerancePct
) =>
    (
         not na(currentAllocationPct) and
         currentAllocationPct < targetAllocationPct - tolerancePct
    )

export overweight(
     float currentAllocationPct,
     float targetAllocationPct,
     float tolerancePct
) =>
    (
         not na(currentAllocationPct) and
         currentAllocationPct > targetAllocationPct + tolerancePct
    )

export allocationGateOpen(
     bool useAllocationGate,
     bool planningEnabled,
     bool underweightState
) =>
    not useAllocationGate or not planningEnabled or underweightState

export deploymentPct(
     bool add1,
     bool add2,
     bool add3,
     float add1Pct,
     float add2Pct,
     float add3Pct
) =>
    add3 ? add3Pct : add2 ? add2Pct : add1 ? add1Pct : 0.0

export suggestedDeployment(
     bool planningEnabled,
     float deployableCash,
     float allocationGapCash,
     float signalDeployPct
) =>
    float cashBase = planningEnabled ? math.min(deployableCash, allocationGapCash) : deployableCash
    float maxAllowed = planningEnabled ? allocationGapCash : deployableCash

    if signalDeployPct > 0.0
        math.max(math.min(cashBase * signalDeployPct / 100.0, maxAllowed), 0.0)
    else
        0.0
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────}

//══════════════════════════════════════════════════════════════════════════════
// 19. STRATEGY LAB / TACTICAL RISK & POSITION SIZING
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{
// Pure math only. Order-placement remains in the strategy script.
//══════════════════════════════════════════════════════════════════════════════

export safePointValue(float pointValue) =>
    na(pointValue) or pointValue <= 0.0 ? 1.0 : pointValue

export safeMinQty(float minContract) =>
    na(minContract) or minContract <= 0.0 ? 1.0 : minContract

export stopDistance(float atrValue, float atrMultiplier) =>
    atrValue * atrMultiplier

export riskCash(float equity, float riskPercent) =>
    equity * riskPercent / 100.0

export riskPerUnit(
     float stopDistance,
     float pointValue
) =>
    stopDistance * safePointValue(pointValue)

export qtyByRisk(
     float equity,
     float riskPercent,
     float stopDistance,
     float pointValue
) =>
    float riskBudget = riskCash(equity, riskPercent)
    float unitRisk = riskPerUnit(stopDistance, pointValue)
    unitRisk > 0.0 ? riskBudget / unitRisk : 0.0

export qtyByAllocation(
     float equity,
     float maxPositionPercent,
     float price,
     float pointValue
) =>
    float allocationCash = equity * maxPositionPercent / 100.0
    float unitValue = price * safePointValue(pointValue)
    unitValue > 0.0 ? allocationCash / unitValue : 0.0

//@function Final Capital Compass risk-based trade quantity.
// Returns [tradeQty, qtyRisk, qtyAllocation, minimumQty].
export tradeQuantity(
     float equity,
     float riskPercent,
     float maxPositionPercent,
     float price,
     float stopDistance,
     float pointValue,
     float minContract
) =>
    float riskQty = qtyByRisk(
         equity,
         riskPercent,
         stopDistance,
         pointValue
    )

    float allocationQty = qtyByAllocation(
         equity,
         maxPositionPercent,
         price,
         pointValue
    )

    float rawQty = math.min(riskQty, allocationQty)
    float minimumQty = safeMinQty(minContract)
    float tradeQty = math.floor(rawQty / minimumQty) * minimumQty

    [tradeQty, riskQty, allocationQty, minimumQty]

export validTradeQty(float quantity, float minimumQty) =>
    (
         not na(quantity) and
         quantity >= minimumQty and
         quantity > 0.0
    )

export entryReference(
     float positionSize,
     float averageEntryPrice,
     float currentPrice
) =>
    positionSize != 0.0 ? averageEntryPrice : currentPrice

export longStop(float entryPrice, float stopDistance) =>
    entryPrice - stopDistance

export shortStop(float entryPrice, float stopDistance) =>
    entryPrice + stopDistance

export longTarget(float entryPrice, float stopDistance, float rewardMultiple) =>
    entryPrice + stopDistance * rewardMultiple

export shortTarget(float entryPrice, float stopDistance, float rewardMultiple) =>
    entryPrice - stopDistance * rewardMultiple

export longTrail(
     float price,
     float atrValue,
     float atrMultiplier,
     float priorTrail
) =>
    float candidate = price - atrValue * atrMultiplier
    na(priorTrail) ? candidate : math.max(priorTrail, candidate)

export shortTrail(
     float price,
     float atrValue,
     float atrMultiplier,
     float priorTrail
) =>
    float candidate = price + atrValue * atrMultiplier
    na(priorTrail) ? candidate : math.min(priorTrail, candidate)

export allowLong(DirectionMode direction) =>
    direction == DirectionMode.longs or direction == DirectionMode.longOnly or direction == DirectionMode.both

export allowShort(DirectionMode direction) =>
    direction == DirectionMode.shorts or direction == DirectionMode.shortOnly or direction == DirectionMode.both

//@function Strategy bias tuple: allow long, allow short, bias label, bias state.
export strategyBias(TrendState marketStateValue, string tacticalPhaseValue, int riskScoreValue, DirectionMode directionMode) =>
    bool phaseLong = tacticalPhaseValue == PHASE_EXPANSION_UP or tacticalPhaseValue == PHASE_ADVANCE or tacticalPhaseValue == PHASE_RECOVERY or tacticalPhaseValue == PHASE_PULLBACK
    bool phaseShort = tacticalPhaseValue == PHASE_EXPANSION_DOWN or tacticalPhaseValue == PHASE_BREAKDOWN
    bool marketLong = marketStateValue == TrendState.bull or marketStateValue == TrendState.caution
    bool marketShort = marketStateValue == TrendState.bear
    bool riskOk = riskScoreValue <= 4
    bool severeRisk = riskScoreValue >= 7
    bool longAllowed = allowLong(directionMode) and marketLong and phaseLong and riskOk
    bool shortAllowed = allowShort(directionMode) and marketShort and phaseShort and not severeRisk

    string biasLabel = STRAT_WAIT
    TrendState biasState = TrendState.neutral
    if severeRisk
        biasLabel := STRAT_BLOCKED
        biasState := TrendState.bear
    else if longAllowed
        biasLabel := STRAT_LONG_OK
        biasState := TrendState.bull
    else if shortAllowed
        biasLabel := STRAT_SHORT_OK
        biasState := TrendState.bear
    else if tacticalPhaseValue == PHASE_EXTENDED
        biasLabel := STRAT_MANAGE
        biasState := TrendState.caution

    [longAllowed, shortAllowed, biasLabel, biasState]

//@function ATR-based strategy plan with explicit point value: stop, target, quantity, risk cash, stop distance.
export strategyPlanWithPointValue(
     float equity,
     float riskPercent,
     float maxPositionPercent,
     float entryPrice,
     float atrValue,
     float atrMultiplier,
     float rewardMultiple,
     bool isLong,
     float pointValue,
     float minContract
) =>
    float distance = stopDistance(atrValue, atrMultiplier)
    float stopPrice = isLong ? longStop(entryPrice, distance) : shortStop(entryPrice, distance)
    float targetPrice = isLong ? longTarget(entryPrice, distance, rewardMultiple) : shortTarget(entryPrice, distance, rewardMultiple)
    [tradeQty, _, _, _] = tradeQuantity(equity, riskPercent, maxPositionPercent, entryPrice, distance, pointValue, minContract)
    float riskAmount = riskCash(equity, riskPercent)
    [stopPrice, targetPrice, tradeQty, riskAmount, distance]

//@function ATR-based strategy plan assuming point value 1: stop, target, quantity, risk cash, stop distance.
export strategyPlan(
     float equity,
     float riskPercent,
     float maxPositionPercent,
     float entryPrice,
     float atrValue,
     float atrMultiplier,
     float rewardMultiple,
     bool isLong,
     float minContract
) =>
    strategyPlanWithPointValue(equity, riskPercent, maxPositionPercent, entryPrice, atrValue, atrMultiplier, rewardMultiple, isLong, 1.0, minContract)

//@function Realized R multiple from entry, stop, exit, and direction.
export rMultiple(float entryPrice, float stopPrice, float exitPrice, bool isLong) =>
    float riskUnit = math.abs(entryPrice - stopPrice)
    float reward = isLong ? exitPrice - entryPrice : entryPrice - exitPrice
    safeDiv(reward, riskUnit, 0.0)

//@function Planned reward/risk ratio from entry, stop, target, and direction.
export rewardRisk(float entryPrice, float stopPrice, float targetPrice, bool isLong) =>
    float riskUnit = math.abs(entryPrice - stopPrice)
    float reward = isLong ? targetPrice - entryPrice : entryPrice - targetPrice
    safeDiv(reward, riskUnit, 0.0)

//@function Strategy expectancy in R units.
export expectancyR(float winRatePct, float averageWinR, float averageLossR) =>
    float winRate = clamp(winRatePct, 0.0, 100.0) * 0.01
    winRate * averageWinR - (1.0 - winRate) * math.abs(averageLossR)

//@function Profit factor from gross profit and gross loss.
export profitFactor(float grossProfit, float grossLoss) =>
    safeDiv(grossProfit, math.abs(grossLoss), na)

//@function Strategy Lab quality label from expectancy, profit factor, and sample size.
export strategyQuality(float expectancyValue, float profitFactorValue, int trades, int minTrades) =>
    if trades < minTrades
        "INSUFFICIENT"
    else if expectancyValue > 0.25 and profitFactorValue >= 1.5
        "STRONG"
    else if expectancyValue > 0.0 and profitFactorValue >= 1.1
        "VIABLE"
    else
        "WEAK"
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────}

//══════════════════════════════════════════════════════════════════════════════
// 20. VALIDATION HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{
// Consuming scripts decide whether to runtime.error().
//══════════════════════════════════════════════════════════════════════════════

export isDaily() =>
    timeframe.isdaily and timeframe.multiplier == 1

export supportedChart() =>
    chart.is_standard or chart.is_heikinashi

export validDrawdownTiers(float tier1, float tier2, float tier3) =>
    tier1 < tier2 and tier2 < tier3

export validDeploymentTiers(float corePct, float opportunityPct, float deepPct) =>
    corePct <= opportunityPct and opportunityPct <= deepPct

export validMaOrder(int fastLength, int intermediateLength, int longLength) =>
    fastLength < intermediateLength and intermediateLength < longLength

export validIchimokuOrder(int tenkanLength, int kijunLength, int spanBLength) =>
    tenkanLength < kijunLength and kijunLength < spanBLength

export validMomentumWeights(
     float rsiWeight,
     float mfiWeight,
     float macdWeight,
     float relativeWeight,
     float weeklyWeight
) =>
    rsiWeight + mfiWeight + macdWeight + relativeWeight + weeklyWeight > 0.0
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────}

//══════════════════════════════════════════════════════════════════════════════
// 21. CONFIRMED HIGHER-TIMEFRAME / STANDARD-PRICE HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{
// Expressions are intentionally parameter-independent so they can be used from
// exported library request.*() functions.
//══════════════════════════════════════════════════════════════════════════════

//@function Last confirmed OHLC from a requested timeframe.
export confirmedOHLC(simple string tickerID, simple string requestedTimeframe) =>
    request.security(
         tickerID,
         requestedTimeframe,
         [open[1], high[1], low[1], close[1]],
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_on
    )

//@function Current standard OHLC for a supplied standard ticker ID.
// Useful when the chart itself is Heikin Ashi.
export standardOHLC(simple string standardTickerID) =>
    request.security(
         standardTickerID,
         timeframe.period,
         [open, high, low, close],
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off
    )

//@function Last completed weekly close.
export confirmedWeeklyClose(simple string tickerID) =>
    request.security(
         tickerID,
         "1W",
         close[1],
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_on
    )

//@function Last completed weekly 40-week SMA.
export confirmedWeekly40Sma(simple string tickerID) =>
    request.security(
         tickerID,
         "1W",
         ta.sma(close, 40)[1],
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_on
    )

//@function Last completed weekly RSI(14).
export confirmedWeeklyRsi14(simple string tickerID) =>
    request.security(
         tickerID,
         "1W",
         ta.rsi(close, 14)[1],
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_on
    )
//──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

//@function Completed-week payload used by Market Navigator weekly context.
// Intended to execute inside a weekly request.security() call.
export completedWeeklyMomentumPayload(
     simple int oscillatorLen,
     simple int macdFastLen,
     simple int macdSlowLen,
     simple int macdSigLen
) =>
    float weeklyMacdLine = ta.ema(close, macdFastLen) - ta.ema(close, macdSlowLen)
    float weeklyMacdSignal = ta.ema(weeklyMacdLine, macdSigLen)
    [close[1], ta.sma(close, 40)[1], ta.rsi(close, oscillatorLen)[1], ta.mfi(hlc3, oscillatorLen)[1], weeklyMacdLine[1], weeklyMacdSignal[1]]
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────}

//══════════════════════════════════════════════════════════════════════════════
// 22. RELATIVE STRENGTH HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{

export relativeReturnPct(
     float assetPrice,
     float benchmarkPrice,
     simple int lookback
) =>
    float assetReturn = not na(assetPrice[lookback]) and assetPrice[lookback] != 0.0 ? (assetPrice / assetPrice[lookback] - 1.0) * 100.0 : na
    float benchmarkReturn = not na(benchmarkPrice[lookback]) and benchmarkPrice[lookback] != 0.0 ? (benchmarkPrice / benchmarkPrice[lookback] - 1.0) * 100.0 : na

    if na(assetReturn) or na(benchmarkReturn)
        na
    else
        assetReturn - benchmarkReturn
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────}

//══════════════════════════════════════════════════════════════════════════════
// 23. ACTION PRIORITY / EVENT HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{

//@function Current Capital Compass action priority.
// Highest-priority conditions are tested first.
export actionPriority(
     bool thesisFloor,
     bool structuralRisk,
     bool stressCluster,
     bool trimReview,
     bool upperReview,
     bool add3,
     bool add2,
     bool add1,
     bool watch,
     bool bearishMomentum,
     bool momentumDeterioration,
     bool overheated,
     bool bullishMomentum,
     bool momentumRecovery,
     bool oversold,
     bool macdBearCross,
     bool macdBullCross,
     bool negativeShock,
     bool positiveShock,
     bool drawdown3,
     bool drawdown2,
     bool drawdown1,
     bool deathCross,
     bool goldenCross,
     bool trendBreak,
     bool trendRecovery,
     bool weeklyBreak,
     bool weeklyRecovery,
     bool bearishStructure,
     bool bullishStructure,
     bool bearishDivergence,
     bool bullishDivergence
) =>
    switch
        thesisFloor           => "THESIS FLOOR"
        structuralRisk        => "RISK REVIEW"
        stressCluster         => "STRESS CLUSTER"
        trimReview            => "TRIM REVIEW"
        upperReview           => "UPPER REVIEW"
        add3                  => "DEEP RECOVERY REVIEW"
        add2                  => "OPPORTUNITY REVIEW"
        add1                  => "CORE ACCUMULATION REVIEW"
        watch                 => "WATCH"
        bearishMomentum       => "BEARISH MOMENTUM"
        momentumDeterioration => "MOMENTUM DETERIORATION"
        overheated            => "OVERHEATED REVIEW"
        bullishMomentum       => "BULLISH MOMENTUM"
        momentumRecovery      => "MOMENTUM RECOVERY"
        oversold              => "OVERSOLD WATCH"
        macdBearCross         => "MACD BEAR CROSS"
        macdBullCross         => "MACD BULL CROSS"
        negativeShock         => "DOWNSIDE SHOCK"
        positiveShock         => "UPSIDE SHOCK"
        drawdown3             => "DRAWDOWN TIER 3"
        drawdown2             => "DRAWDOWN TIER 2"
        drawdown1             => "DRAWDOWN TIER 1"
        deathCross            => "DEATH CROSS"
        goldenCross           => "GOLDEN CROSS"
        trendBreak            => "LONG-TREND BREAK"
        trendRecovery         => "LONG-TREND RECOVERY"
        weeklyBreak           => "WEEKLY BREAK"
        weeklyRecovery        => "WEEKLY RECOVERY"
        bearishStructure      => "BEARISH STRUCTURE"
        bullishStructure      => "BULLISH STRUCTURE"
        bearishDivergence     => "BEARISH DIVERGENCE"
        bullishDivergence     => "BULLISH DIVERGENCE"
        => "MONITOR"

//@function Shared semantic color for Market Navigator review/event actions.
export actionColor(string action) =>
    switch action
        "THESIS FLOOR"             => C_NEG
        "RISK REVIEW"              => C_NEG
        "STRESS CLUSTER"           => C_NEG
        "BEARISH MOMENTUM"         => C_NEG
        "DOWNSIDE SHOCK"           => C_NEG
        "DRAWDOWN TIER 3"          => C_NEG
        "DEATH CROSS"              => C_NEG
        "LONG-TREND BREAK"         => C_NEG
        "WEEKLY BREAK"             => C_NEG
        "BEARISH STRUCTURE"        => C_NEG
        "BEARISH DIVERGENCE"       => C_NEG
        "TRIM REVIEW"              => C_WARN
        "OVERHEATED REVIEW"        => C_WARN
        "MOMENTUM DETERIORATION"   => C_WARN
        "MACD BEAR CROSS"          => C_WARN
        "DRAWDOWN TIER 1"          => C_WARN
        "DRAWDOWN TIER 2"          => C_WARN
        "UPSIDE SHOCK"             => C_WARN
        "UPPER REVIEW"             => C_PURPLE
        "CORE ACCUMULATION REVIEW" => C_POS
        "OPPORTUNITY REVIEW"       => C_TEAL
        "DEEP RECOVERY REVIEW"     => C_INFO
        "BULLISH MOMENTUM"         => C_POS
        "GOLDEN CROSS"             => C_POS
        "LONG-TREND RECOVERY"      => C_POS
        "WEEKLY RECOVERY"          => C_POS
        "BULLISH STRUCTURE"        => C_POS
        "BULLISH DIVERGENCE"       => C_POS
        "WATCH"                    => C_CYAN
        "OVERSOLD WATCH"           => C_CYAN
        "MOMENTUM RECOVERY"        => C_TEAL
        "MACD BULL CROSS"          => C_TEAL
        => C_DIM

//@function Mobile-first abbreviation for shared Capital Compass actions.
export shortAction(string action) =>
    switch action
        "CORE ACCUMULATION REVIEW" => "CORE"
        "OPPORTUNITY REVIEW"       => "OPP"
        "DEEP RECOVERY REVIEW"     => "DEEP"
        "WATCH"                    => "WATCH"
        "TRIM REVIEW"              => "TRIM"
        "THESIS FLOOR"             => "FLOOR"
        "RISK REVIEW"              => "RISK"
        "STRESS CLUSTER"           => "STRESS"
        "UPPER REVIEW"             => "UPPER"
        "MOMENTUM DETERIORATION"   => "MOM WEAK"
        "MOMENTUM RECOVERY"        => "MOM REC"
        "BEARISH MOMENTUM"         => "BEAR MOM"
        "BULLISH MOMENTUM"         => "BULL MOM"
        "OVERHEATED REVIEW"        => "HOT"
        "OVERSOLD WATCH"           => "OVERSOLD"
        "MACD BEAR CROSS"          => "MACD ↓"
        "MACD BULL CROSS"          => "MACD ↑"
        "DRAWDOWN TIER 3"          => "DD3"
        "DRAWDOWN TIER 2"          => "DD2"
        "DRAWDOWN TIER 1"          => "DD1"
        "LONG-TREND BREAK"         => "LT BREAK"
        "LONG-TREND RECOVERY"      => "LT REC"
        "WEEKLY BREAK"             => "W BREAK"
        "WEEKLY RECOVERY"          => "W REC"
        "DEATH CROSS"              => "DEATH CROSS"
        "GOLDEN CROSS"             => "GOLDEN CROSS"
        "DOWNSIDE SHOCK"           => "SHOCK ↓"
        "UPSIDE SHOCK"             => "SHOCK ↑"
        "BEARISH STRUCTURE"        => "BEAR STRUCT"
        "BULLISH STRUCTURE"        => "BULL STRUCT"
        "BEARISH DIVERGENCE"       => "BEAR DIV"
        "BULLISH DIVERGENCE"       => "BULL DIV"
        => action

//@function Stable machine event code for shared Capital Compass actions.
export eventCode(string action) =>
    switch action
        "CORE ACCUMULATION REVIEW" => "CORE"
        "OPPORTUNITY REVIEW"       => "OPP"
        "DEEP RECOVERY REVIEW"     => "DEEP"
        "WATCH"                    => "WATCH"
        "TRIM REVIEW"              => "TRIM_REVIEW"
        "THESIS FLOOR"             => "THESIS_FLOOR"
        "RISK REVIEW"              => "STRUCTURAL_RISK"
        "STRESS CLUSTER"           => "STRESS_CLUSTER"
        "UPPER REVIEW"             => "UPPER_REVIEW"
        "MOMENTUM DETERIORATION"   => "MOMENTUM_DETERIORATION"
        "MOMENTUM RECOVERY"        => "MOMENTUM_RECOVERY"
        "BEARISH MOMENTUM"         => "BEARISH_MOMENTUM"
        "BULLISH MOMENTUM"         => "BULLISH_MOMENTUM"
        "OVERHEATED REVIEW"        => "OVERHEATED"
        "OVERSOLD WATCH"           => "OVERSOLD"
        "MACD BEAR CROSS"          => "MACD_BEAR_CROSS"
        "MACD BULL CROSS"          => "MACD_BULL_CROSS"
        "DRAWDOWN TIER 3"          => "DRAWDOWN_3"
        "DRAWDOWN TIER 2"          => "DRAWDOWN_2"
        "DRAWDOWN TIER 1"          => "DRAWDOWN_1"
        "LONG-TREND BREAK"         => "LONG_SMA_BREAK"
        "LONG-TREND RECOVERY"      => "LONG_SMA_RECOVERY"
        "WEEKLY BREAK"             => "WEEKLY_BREAK"
        "WEEKLY RECOVERY"          => "WEEKLY_RECOVERY"
        "DEATH CROSS"              => "DEATH_CROSS"
        "GOLDEN CROSS"             => "GOLDEN_CROSS"
        "DOWNSIDE SHOCK"           => "NEGATIVE_SHOCK"
        "UPSIDE SHOCK"             => "POSITIVE_SHOCK"
        "BEARISH STRUCTURE"        => "BEARISH_STRUCTURE"
        "BULLISH STRUCTURE"        => "BULLISH_STRUCTURE"
        "BEARISH DIVERGENCE"       => "BEARISH_DIVERGENCE"
        "BULLISH DIVERGENCE"       => "BULLISH_DIVERGENCE"
        => "EVENT"

//@function Compact momentum phase shared by notifications/panels.
export shortMomentumPhase(string phase) =>
    switch phase
        "BULLISH"       => "BULL"
        "RECOVERING"    => "REC"
        "OVERHEATED"    => "HOT"
        "BEARISH"       => "BEAR"
        "DETERIORATING" => "WEAK"
        "OVERSOLD"      => "OS"
        => "NEUT"

//@function Semantic structure color shared by chart/panel consumers.
export structureColor(bool bull, bool bear, bool expanding, bool contracting, color neutralColor) =>
    switch
        bull        => C_POS
        bear        => C_NEG
        expanding   => C_WARN
        contracting => C_INFO
        => neutralColor

export appendEventCode(string eventCodes, bool condition, string eventCode) =>
    condition ? eventCodes + eventCode + "," : eventCodes

export cleanEventCodes(string eventCodes) =>
    if str.length(eventCodes) > 0
        str.substring(eventCodes, 0, str.length(eventCodes) - 1)
    else
        ""
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────}

//══════════════════════════════════════════════════════════════════════════════
// 23B. EVENT TRANSITIONS / ALERT ROUTING HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{

//@function Bar-close-confirmed crossover.
export confirmedCrossUp(bool confirmed, float firstValue, float secondValue) =>
    bool crossedUp = ta.crossover(firstValue, secondValue)
    confirmed and crossedUp

//@function Bar-close-confirmed crossunder.
export confirmedCrossDown(bool confirmed, float firstValue, float secondValue) =>
    bool crossedDown = ta.crossunder(firstValue, secondValue)
    confirmed and crossedDown

//@function Fires only when a condition becomes true.
export firstTrue(bool confirmed, bool condition) =>
    confirmed and condition and not condition[1]

//@function Drawdown tier transition events. If a single bar crosses multiple
// tiers, only the most severe tier is returned.
export drawdownTierEvents(
     bool confirmed,
     float drawdownPct,
     float tier1,
     float tier2,
     float tier3
) =>
    bool cross1 = ta.crossunder(drawdownPct, -tier1)
    bool cross2 = ta.crossunder(drawdownPct, -tier2)
    bool cross3 = ta.crossunder(drawdownPct, -tier3)

    bool event3 = confirmed and cross3
    bool event2 = confirmed and cross2 and not event3
    bool event1 = confirmed and cross1 and not event2 and not event3

    [event1, event2, event3]

//@function Manual upper/lower review-level transitions.
export reviewLevelEvents(
     bool confirmed,
     float price,
     float upperLevel,
     float lowerLevel
) =>
    bool crossedUpper = ta.crossover(price, upperLevel)
    bool crossedLower = ta.crossunder(price, lowerLevel)

    bool upperEvent = confirmed and upperLevel > 0.0 and crossedUpper
    bool lowerEvent = confirmed and lowerLevel > 0.0 and crossedLower

    [upperEvent, lowerEvent]

export alertGroups(
     bool enableAccumulation,
     bool enableRisk,
     bool enableContext,
     bool enableMomentum,
     bool enableStructure,
     bool add1,
     bool add2,
     bool add3,
     bool watch,
     bool trim,
     bool structuralRisk,
     bool floorEvent,
     bool upperEvent,
     bool trendRecovery,
     bool trendBreak,
     bool goldenCross,
     bool deathCross,
     bool weeklyRecovery,
     bool weeklyBreak,
     bool drawdown1,
     bool drawdown2,
     bool drawdown3,
     bool negativeShock,
     bool positiveShock,
     bool stressCluster,
     bool momentumRecovery,
     bool momentumDeterioration,
     bool bullishMomentum,
     bool bearishMomentum,
     bool oversold,
     bool overheated,
     bool macdBullCross,
     bool macdBearCross,
     bool bullishStructure,
     bool bearishStructure,
     bool bullishDivergence,
     bool bearishDivergence
) =>
    bool accumulationGroup = (
         enableAccumulation and
         (add1 or add2 or add3 or watch)
    )

    bool riskGroup = (
         enableRisk and
         (trim or structuralRisk or floorEvent or upperEvent)
    )

    bool contextGroup = (
         enableContext and
         (
              trendRecovery or trendBreak or goldenCross or deathCross or
              weeklyRecovery or weeklyBreak or drawdown1 or drawdown2 or
              drawdown3 or negativeShock or positiveShock or stressCluster
         )
    )

    bool momentumGroup = (
         enableMomentum and
         (
              momentumRecovery or momentumDeterioration or bullishMomentum or
              bearishMomentum or oversold or overheated or
              macdBullCross or macdBearCross
         )
    )

    bool structureGroup = (
         enableStructure and
         (
              bullishStructure or bearishStructure or
              bullishDivergence or bearishDivergence
         )
    )

    bool anyEvent = (
         accumulationGroup or
         riskGroup or
         contextGroup or
         momentumGroup or
         structureGroup
    )

    [accumulationGroup, riskGroup, contextGroup, momentumGroup, structureGroup, anyEvent]

export appendEventLine(
     string eventLines,
     bool condition,
     string lineText
) =>
    condition ? eventLines + "• " + lineText + "\n" : eventLines
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────}

//══════════════════════════════════════════════════════════════════════════════
// 24. ALERT / JSON FORMAT HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{
// alertcondition() remains in the consuming script.
// alert() may use strings built by these helpers.
//══════════════════════════════════════════════════════════════════════════════

export jsonFloat(float value) =>
    na(value) ? "null" : str.tostring(value)

export jsonInt(int value) =>
    str.tostring(value)

export jsonBool(bool value) =>
    value ? "true" : "false"

//@function Selects a Capital Compass human-readable or JSON alert payload.
export alertMessage(string alertFormat, string readableMessage, string jsonMessage) =>
    alertFormat == "JSON" ? jsonMessage : readableMessage

// Escapes human-readable text for safe embedding inside JSON strings.
export jsonEscape(string value) =>
    string result = str.replace_all(value, "\\", "\\\\")
    result := str.replace_all(result, "\"", "\\\"")
    result := str.replace_all(result, "\n", "\\n")
    result := str.replace_all(result, "\r", "\\r")
    result := str.replace_all(result, "\t", "\\t")
    result

export fmtPrice(float value) =>
    na(value) ? "—" : str.tostring(value, format.mintick)

export fmtPct(float value) =>
    na(value) ? "—" : str.tostring(value, "#.##") + "%"

export fmtDecimalPct(float decimalValue) =>
    na(decimalValue) ? "—" : str.tostring(decimalValue * 100.0, "#.##") + "%"

export fmtNum(float value) =>
    na(value) ? "—" : str.tostring(value, "#.00")

export fmt1(float value) =>
    na(value) ? "—" : str.tostring(value, "#.0")

export fmt2(float value) =>
    na(value) ? "—" : str.tostring(value, "#.00")

export fmtInt(int value) =>
    str.tostring(value)

export fmtSignedNum(float value) =>
    na(value) ? "—" : (value > 0 ? "+" : "") + str.tostring(value, "#.##")

export fmtSignedPct(float value) =>
    na(value) ? "—" : (value > 0 ? "+" : "") + str.tostring(value, "#.##") + "%"

//@function Delta color where caller defines whether higher values are better.
export deltaColor(float delta, bool higherIsBetter) =>
    (na(delta) or delta == 0.0) ? C_INACTIVE : higherIsBetter ? (delta > 0 ? C_POS : C_NEG) : (delta < 0 ? C_POS : C_NEG)

export fmtMoney(float value) =>
    na(value) ? "—" : "$" + str.tostring(value, "#.00")

export fmtRatio(float value) =>
    na(value) ? "N/A" : str.tostring(value, "#.00") + "×"

export fmtScore(float value, float maximum) =>
    na(value) ? "—" : str.tostring(value, "#.0") + "/" + str.tostring(maximum, "#.0")
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────}

//══════════════════════════════════════════════════════════════════════════════
// 25. STANDARD PANEL TEXT HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{

export allocationText(
     bool planningEnabled,
     float currentAllocationPct,
     float targetAllocationPct
) =>
    if planningEnabled
        str.tostring(currentAllocationPct, "#.0") + "% / " + str.tostring(targetAllocationPct, "#.0") + "%"
    else
        "Not Configured"

export deploymentText(
     float signalDeployPct,
     float suggestedDeployment
) =>
    if signalDeployPct > 0.0
        str.tostring(signalDeployPct, "#.0") + "% | ≤ " + fmtMoney(suggestedDeployment)
    else
        "No Active Tranche"

export weeklyTrendText(bool weeklyBull, bool weeklyBear) =>
    switch
        weeklyBull => "Above 40W SMA"
        weeklyBear => "Below 40W SMA"
        => "Insufficient Data"

export weeklyMomentumText(
     bool weeklyBull,
     bool weeklyBear,
     bool weeklyReady
) =>
    switch
        weeklyBull  => "Bullish"
        weeklyBear  => "Bearish"
        weeklyReady => "Mixed"
        => "Insufficient Data"

export relativeText(
     bool useBenchmark,
     bool benchmarkReady,
     float relativeStrengthPct
) =>
    switch
        not useBenchmark  => "Disabled"
        not benchmarkReady => "N/A"
        => str.tostring(relativeStrengthPct, "#.##") + "%"
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────}

//══════════════════════════════════════════════════════════════════════════════
// 26. END — CAPITAL COMPASS CORE
//══════════════════════════════════════════════════════════════════════════════
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━}
//╔════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
//║                                                                                                                    ║
//║    ◢███◣     ◢███◣     ◢███◣          ╔════════════════════════════════════╗          ◢███◣     ◢███◣     ◢███◣    ║
//║    █╲ ╱█─────█╲ ╱█─────█╲ ╱█──────────║          C O D E   E N D S         ║──────────█╲ ╱█─────█╲ ╱█─────█╲ ╱█    ║
//║    ◥███◤     ◥███◤     ◥███◤          ╚════════════════════════════════════╝          ◥███◤     ◥███◤     ◥███◤    ║
//║                                                                                                                    ║
//║═══════════════════════════════════════◢◤  C A P I T A L    C O M P A S S  ◥◣═══════════════════════════════════════║
//║                                                                                                                    ║
//║                                                 [ C.C. — ⚙️ CORE ]                                                 ║
//║                                              C O R E   L I B R A R Y                                               ║
//║                                         CAPITAL • SYSTEM • INFRASTRUCTURE                                          ║
//║                                                                                                                    ║
//║                                       T H E   S I G N A L   W A T C H M A N                                        ║
//║                                                                                                                    ║
//║                           STYLE [ READY ]   •   LOGIC [ READY ]   •   SYSTEM [ ONLINE ]                            ║
//║                                                                                                                    ║
//║                     O B S E R V E  •  D I S C E R N  •  P R E P A R E  •  A C T   W I S E L Y                      ║
//║                                                                                                                    ║
//║                                  “Tuned to the signal. Anchored to the mission.”                                   ║
//║                                                                                                                    ║
//╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
//║                                                                                                                    ║
//║  • Capital Compass supports observation, research, risk awareness, and disciplined decision-making.                ║
//║  • Signals, states, models, scores, experiments, alerts, and backtests are analytical tools — not guarantees.      ║
//║  • Use independent research, diversification, disciplined risk management, and sound judgment.                     ║
//║                                                                                                                    ║
//╚════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
````
