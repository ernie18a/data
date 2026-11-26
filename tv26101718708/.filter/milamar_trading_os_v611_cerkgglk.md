# Milamar Trading OS v6.11

- url: https://www.tradingview.com/script/CERKggLK-Milamar-Trading-OS-v6-11/
- type: indicator
- pine_id: PUB;141cc4ac60274bf09f3dc67f887824cf
- version: 1.0

## Description

// Changelog v6.11
// - Converts Replay build back to a pure indicator()
// - Removes all external order calls for fast Replay stepping
// - Simulates Paper Entry, TP1, TP2, SL, BE and HEALTH_EXIT internally
// - Keeps Trade Health v2.1 recommendations and Performance Modes
// - Keeps stable BACKTEST / Replay config anchor from v6.10.1 base
// - Routes A+ Entry-Zone alerts through the final setupState transition so alerts and Info Table share one status source
// - Gates A+ Entry-confirmed alerts to the actual active/fill event instead of the pre-fill confirmation state
//
// Changelog v6.10.1
// - Fixes BACKTEST / Replay config anchor so activeConfigStart never depends on last_bar_time
// - Adds optional Backtest Start Mode AUTO_08 / MANUAL
// - Keeps Performance Mode FULL / BACKTEST_FAST / ENGINE_ONLY unchanged
// - Adds DEBUG_COUNTERS-only Config Start Debug row
//
// Changelog v6.10
// - Adds Performance Mode: FULL / BACKTEST_FAST / ENGINE_ONLY
// - Replaces per-key config parsing with one-pass active-asset parser
// - Gates heavy visuals, event labels and cockpit updates by performance mode
// - Reduces heavy Paper Engine updates with entry-state keys
// - Adds v6.9.1 Health fixes: TOT priority, no same-bar Health BE, robust day type mapping
//
// Changelog v6.9
// - Adds context-aware Trade Health Engine v2.1
// - Adds Health phases PRE_TP1 / RUNNER_AFTER_TP1 / CLOSED
// - Uses dynamic age profiles for With-Day-Type, Balanced, Against-Day-Type and Neutral trades
// - Scores Progress, Efficiency, Momentum, Age, Price Position and Context from 0 to 100
// - Adds hard PRE_TP1 exit rules and BE protection rules
// - Disables Health hard exits after TP1; runner continues classically to TP2 or BE
// - Expands cockpit Health debug with phase, expected TP1 progress, MFE/MAE ratio and minutes since best MFE
//
// Changelog v6.8
// - Adds Trade Health Engine v1 for active trades
// - Adds Trade Health mode input: OFF / ANALYSE / AUTO PAPER
// - Calculates Health Score, status, recommendation and reason from trade age, MFE, MAE, TP1 progress and momentum
// - Decouples Trade Health recommendations from current open PnL
// - Evaluates setup delivery / trade structure instead of Dollar profit or loss
// - Supports exactly three recommendations: Halten, SL auf BE, Hart raus
// - Applies Trade Health recommendations automatically only in BACKTEST when mode is AUTO PAPER
// - Routes internal TP/SL State Engine through the active Paper SL after Trade Health moves SL to BE
// - Stores active Paper Stop hits at Entry as BE instead of classic SL
// - Makes Paper BE a terminal cockpit exit and stops Trade Health after Paper close
// - Uses fixed Paper quantities so Health BE before TP1 closes the full open position
// - Uses a single full-position BE stop before TP1 to prevent leftover Paper positions
// - Waits for the real configured Entry fill before starting Paper state
// - Shows Trade Health as Exit Grund for Health-managed exits and keeps Laufzeit in Review
// - Maps Health Status TOT directly to Hart raus / HEALTH_EXIT unless SL or TP2 is hit on the same bar
// - Freezes final Health Score, Status, Recommendation and Reason after Paper close
// - Places Paper Entries as pending internal triggers at the configured Entry price
// - Keeps STATE_CONFIRMED until the Entry trigger is filled by price
// - Keeps STATE_CONFIRMED until the configured Entry price is actually filled
// - Starts Trade Age, MFE, MAE, Acceptance and Trade Health only after the real Entry fill
// - LIVE mode shows recommendations without changing orders
// - Adds Health Managed Outcome and Original Outcome comparison
// - Adds Trade Health cockpit rows and Trade Health alerts
// - Tuning #1: makes Trade Health escalation more conservative and prefers SL auf BE before Hart raus
// - Aborts stale Confirmation when max bars expire or price moves too far against the touched Entry
//
// Changelog v6.7
// - Adds Master Alert mode using Any alert() function call
// - Adds alert mode input: LIVE / BACKTEST / AUS
// - Standardizes alert payloads with Asset, Quality, Direction, Config, Time and State
// - Adds Confirmation Close Rule: Entry can only confirm on barstate.isconfirmed
// - Allows intrabar confirmation preview without STATE_CONFIRMED / STATE_ACTIVE transition
// - Adds BACKTEST-only Paper Trading simulation; LIVE remains visual / alert-only
// - Uses automatic Paper quantity: MNQ = 2 contracts, MBT = 5 contracts
// - Simulates Entry, TP1 partial and runner internally
// - Closes 50% at TP1, activates Break-even, then manages the runner to TP2 / BE / SL
// - Tracks Paper Trade data: Qty, MFE, MAE, BE status and Outcome
// - Makes the Trading Cockpit state-aware: Setup, Trade and Review phases show only relevant rows
//
// Changelog v6.6
// - Improves Info Table status guidance for Setup, Touch, Confirmation and Trade phases
// - Shows Confirmation Score as current / required score
// - Updates displayed Confirmation Score live from SETUP AKTIV onward without changing entry logic
// - Adds Explain Preview text in the Grund row as first step toward the Explain Engine
// - Adds Akzeptanz Engine after Entry to observe first post-entry momentum without exits
// - Keeps State Machine, Freshness, Confirmation formula and TP/SL Engine unchanged
//
// Changelog v6.5.2
// - Uses the current chart bar as activation anchor for pasted configs in LIVE and BACKTEST
// - Hard-resets the full trade state machine on config changes
// - Blocks setup, touch, confirmation and TP/SL evaluation before the active config bar
// - Prevents old Entry / TP / SL values from surviving a pasted config change
//
// Changelog v6.5.1
// - Makes TP/SL execution deterministic and blocks same-bar exit checks after Entry
// - Adds Entry / Exit Bar, Price, Reason and Trigger debug fields
// - Treats provided paste configs as complete asset replacements with missing values set to 0
// - Scopes activeConfigKey to the active asset config only
// - Adds Config Status validation to the Info Table
//
// Changelog v6.5
// - Adds MNQ / MBT config paste inputs for daily config updates without Pine Editor changes
// - Parses pasted config text with hardcoded defaults as fallback
// - Includes pasted config text in activeConfigKey for clean state resets
// - Reframes SETUP INVALIDIERT as a protective state instead of a loss / error state
//
// Changelog v6.4
// - Simplifies trader-facing inputs into Betrieb, Confirmation and Reset / Debug groups
// - Removes manual Backtest date/time inputs and Backtest Config-ID
// - Anchors LIVE and BACKTEST automatically to the chart day at 08:00 Madrid
// - Stabilizes Trade Plan Box rendering for Replay
// - Separates Entry Touch from Confirmation conditions
// - Keeps CONFIG ID as reset trigger and preserves shared Trading Logic
//
// Changelog v6.3
// - Adds LIVE / BACKTEST operating mode
// - Introduces activeConfigStart as shared time source for all engines
// - Adds central alert gate for LIVE and BACKTEST
// - Keeps one shared Trading Logic for both modes
//
// Changelog v6.2
// - Adds score-based Confirmation Engine in STATE_TOUCHED
// - Keeps A+ levels, Entry, SL, TP1 and TP2 unchanged
// - Adds Confirmation mode, score, minimum score and timeout feedback
// - Renames previous A Watchlist trades to B Watchlist trades
// - Keeps trade start in the State Machine / Trade Engine
//
// Changelog v6.1 RC1
// - Adds single-source setup state machine
// - Moves setup availability before all dependent logic
// - Freshness starts only after structural setup activation
// - TP1/TP2 before Entry consumes setup only after ARMED and not on Entry-touch bar
// - Preserves daily config values, A+/B levels, SL, TP1 and TP2
//
// Changelog v6.0 RC1
// - Based on v5.1.2 MASTER
// - Adds Config-driven Setup Availability Engine
// - Fixes Freshness Anchor: tracking starts at CONFIG_START_TIME
// - Keeps Entry Touch / Confirmation phases and US Open Filter
//
// Changelog v5.1.2
// - Added US Open Filter 15:25-15:45 Madrid
// - Blocks Entry Confirmation during US Cash Open
// - Adds US Open status and alert
//
// Changelog v5.1.0
// - Added central runtime variable section
// - Added Freshness Engine v2
// - Tracks highest high / lowest low since CONFIG_ID
// - Blocks Entry if TP1 or TP2 was reached before Entry
// - Adds setup freshness to panel
// - Preserves v5.0 core behaviour
// =====================================================

## Source Code

````pine
//@version=6
// =====================================================
// MILAMAR TRADING OS
// Version : 6.11
// Build   : 2026-06-29
// Status  : v6.11 fast replay indicator
//
// Changelog v6.11
// - Converts Replay build back to a pure indicator()
// - Removes all external order calls for fast Replay stepping
// - Simulates Paper Entry, TP1, TP2, SL, BE and HEALTH_EXIT internally
// - Keeps Trade Health v2.1 recommendations and Performance Modes
// - Keeps stable BACKTEST / Replay config anchor from v6.10.1 base
// - Routes A+ Entry-Zone alerts through the final setupState transition so alerts and Info Table share one status source
//
// Changelog v6.10.1
// - Fixes BACKTEST / Replay config anchor so activeConfigStart never depends on last_bar_time
// - Adds optional Backtest Start Mode AUTO_08 / MANUAL
// - Keeps Performance Mode FULL / BACKTEST_FAST / ENGINE_ONLY unchanged
// - Adds DEBUG_COUNTERS-only Config Start Debug row
//
// Changelog v6.10
// - Adds Performance Mode: FULL / BACKTEST_FAST / ENGINE_ONLY
// - Replaces per-key config parsing with one-pass active-asset parser
// - Gates heavy visuals, event labels and cockpit updates by performance mode
// - Reduces heavy Paper Engine updates with entry-state keys
// - Adds v6.9.1 Health fixes: TOT priority, no same-bar Health BE, robust day type mapping
//
// Changelog v6.9
// - Adds context-aware Trade Health Engine v2.1
// - Adds Health phases PRE_TP1 / RUNNER_AFTER_TP1 / CLOSED
// - Uses dynamic age profiles for With-Day-Type, Balanced, Against-Day-Type and Neutral trades
// - Scores Progress, Efficiency, Momentum, Age, Price Position and Context from 0 to 100
// - Adds hard PRE_TP1 exit rules and BE protection rules
// - Disables Health hard exits after TP1; runner continues classically to TP2 or BE
// - Expands cockpit Health debug with phase, expected TP1 progress, MFE/MAE ratio and minutes since best MFE
//
// Changelog v6.8
// - Adds Trade Health Engine v1 for active trades
// - Adds Trade Health mode input: OFF / ANALYSE / AUTO PAPER
// - Calculates Health Score, status, recommendation and reason from trade age, MFE, MAE, TP1 progress and momentum
// - Decouples Trade Health recommendations from current open PnL
// - Evaluates setup delivery / trade structure instead of Dollar profit or loss
// - Supports exactly three recommendations: Halten, SL auf BE, Hart raus
// - Applies Trade Health recommendations automatically only in BACKTEST when mode is AUTO PAPER
// - Routes internal TP/SL State Engine through the active Paper SL after Trade Health moves SL to BE
// - Stores active Paper Stop hits at Entry as BE instead of classic SL
// - Makes Paper BE a terminal cockpit exit and stops Trade Health after Paper close
// - Uses fixed Paper quantities so Health BE before TP1 closes the full open position
// - Uses a single full-position BE stop before TP1 to prevent leftover Paper positions
// - Waits for the real configured Entry fill before starting Paper state
// - Shows Trade Health as Exit Grund for Health-managed exits and keeps Laufzeit in Review
// - Maps Health Status TOT directly to Hart raus / HEALTH_EXIT unless SL or TP2 is hit on the same bar
// - Freezes final Health Score, Status, Recommendation and Reason after Paper close
// - Places Paper Entries as pending internal triggers at the configured Entry price
// - Keeps STATE_CONFIRMED until the Entry trigger is filled by price
// - Keeps STATE_CONFIRMED until the configured Entry price is actually filled
// - Starts Trade Age, MFE, MAE, Acceptance and Trade Health only after the real Entry fill
// - LIVE mode shows recommendations without changing orders
// - Adds Health Managed Outcome and Original Outcome comparison
// - Adds Trade Health cockpit rows and Trade Health alerts
// - Tuning #1: makes Trade Health escalation more conservative and prefers SL auf BE before Hart raus
// - Aborts stale Confirmation when max bars expire or price moves too far against the touched Entry
//
// Changelog v6.7
// - Adds Master Alert mode using Any alert() function call
// - Adds alert mode input: LIVE / BACKTEST / AUS
// - Standardizes alert payloads with Asset, Quality, Direction, Config, Time and State
// - Adds Confirmation Close Rule: Entry can only confirm on barstate.isconfirmed
// - Allows intrabar confirmation preview without STATE_CONFIRMED / STATE_ACTIVE transition
// - Adds BACKTEST-only Paper Trading simulation; LIVE remains visual / alert-only
// - Uses automatic Paper quantity: MNQ = 2 contracts, MBT = 5 contracts
// - Simulates Entry, TP1 partial and runner internally
// - Closes 50% at TP1, activates Break-even, then manages the runner to TP2 / BE / SL
// - Tracks Paper Trade data: Qty, MFE, MAE, BE status and Outcome
// - Makes the Trading Cockpit state-aware: Setup, Trade and Review phases show only relevant rows
//
// Changelog v6.6
// - Improves Info Table status guidance for Setup, Touch, Confirmation and Trade phases
// - Shows Confirmation Score as current / required score
// - Updates displayed Confirmation Score live from SETUP AKTIV onward without changing entry logic
// - Adds Explain Preview text in the Grund row as first step toward the Explain Engine
// - Adds Akzeptanz Engine after Entry to observe first post-entry momentum without exits
// - Keeps State Machine, Freshness, Confirmation formula and TP/SL Engine unchanged
//
// Changelog v6.5.2
// - Uses the current chart bar as activation anchor for pasted configs in LIVE and BACKTEST
// - Hard-resets the full trade state machine on config changes
// - Blocks setup, touch, confirmation and TP/SL evaluation before the active config bar
// - Prevents old Entry / TP / SL values from surviving a pasted config change
//
// Changelog v6.5.1
// - Makes TP/SL execution deterministic and blocks same-bar exit checks after Entry
// - Adds Entry / Exit Bar, Price, Reason and Trigger debug fields
// - Treats provided paste configs as complete asset replacements with missing values set to 0
// - Scopes activeConfigKey to the active asset config only
// - Adds Config Status validation to the Info Table
//
// Changelog v6.5
// - Adds MNQ / MBT config paste inputs for daily config updates without Pine Editor changes
// - Parses pasted config text with hardcoded defaults as fallback
// - Includes pasted config text in activeConfigKey for clean state resets
// - Reframes SETUP INVALIDIERT as a protective state instead of a loss / error state
//
// Changelog v6.4
// - Simplifies trader-facing inputs into Betrieb, Confirmation and Reset / Debug groups
// - Removes manual Backtest date/time inputs and Backtest Config-ID
// - Anchors LIVE and BACKTEST automatically to the chart day at 08:00 Madrid
// - Stabilizes Trade Plan Box rendering for Replay
// - Separates Entry Touch from Confirmation conditions
// - Keeps CONFIG ID as reset trigger and preserves shared Trading Logic
//
// Changelog v6.3
// - Adds LIVE / BACKTEST operating mode
// - Introduces activeConfigStart as shared time source for all engines
// - Adds central alert gate for LIVE and BACKTEST
// - Keeps one shared Trading Logic for both modes
//
// Changelog v6.2
// - Adds score-based Confirmation Engine in STATE_TOUCHED
// - Keeps A+ levels, Entry, SL, TP1 and TP2 unchanged
// - Adds Confirmation mode, score, minimum score and timeout feedback
// - Renames previous A Watchlist trades to B Watchlist trades
// - Keeps trade start in the State Machine / Trade Engine
//
// Changelog v6.1 RC1
// - Adds single-source setup state machine
// - Moves setup availability before all dependent logic
// - Freshness starts only after structural setup activation
// - TP1/TP2 before Entry consumes setup only after ARMED and not on Entry-touch bar
// - Preserves daily config values, A+/B levels, SL, TP1 and TP2
//
// Changelog v6.0 RC1
// - Based on v5.1.2 MASTER
// - Adds Config-driven Setup Availability Engine
// - Fixes Freshness Anchor: tracking starts at CONFIG_START_TIME
// - Keeps Entry Touch / Confirmation phases and US Open Filter
//
// Changelog v5.1.2
// - Added US Open Filter 15:25-15:45 Madrid
// - Blocks Entry Confirmation during US Cash Open
// - Adds US Open status and alert
//
// Changelog v5.1.0
// - Added central runtime variable section
// - Added Freshness Engine v2
// - Tracks highest high / lowest low since CONFIG_ID
// - Blocks Entry if TP1 or TP2 was reached before Entry
// - Adds setup freshness to panel
// - Preserves v5.0 core behaviour
// =====================================================

indicator("Milamar Trading OS v6.11 Replay", overlay=true)

// =====================================================
// MARKET DETECTION & Last Update
// =====================================================
ticker = syminfo.ticker

MARKET =
     str.contains(ticker, "MNQ") ? "MNQ" :
     str.contains(ticker, "MBT") ? "MBT" :
     ""

isSupportedMarket = MARKET == "MNQ" or MARKET == "MBT"

DISPLAY_TZ = "Europe/Madrid"


// =====================================================
// INPUTS
// =====================================================

const string GROUP_OPERATION = "Betrieb"
const string GROUP_BACKTEST = "Backtest"
const string GROUP_PERFORMANCE = "Performance"
const string GROUP_CONFIRMATION = "Confirmation"
const string GROUP_ACCEPTANCE = "Akzeptanz"
const string GROUP_TRADE_HEALTH = "Trade Health"
const string GROUP_RESET_DEBUG = "Reset / Debug"
const string GROUP_CONFIG_PASTE = "CONFIG PASTE"

MODE = input.string("LIVE", "Betriebsmodus", options=["LIVE", "BACKTEST"], group=GROUP_OPERATION)
CONFIG_ID = input.string("AUTO", "CONFIG ID", group=GROUP_OPERATION)
ALERT_MODE = input.string("LIVE", "Alerts", options=["LIVE", "BACKTEST", "AUS"], group=GROUP_OPERATION)
PERFORMANCE_MODE = input.string("FULL", "Performance Mode", options=["FULL", "BACKTEST_FAST", "ENGINE_ONLY"], group=GROUP_PERFORMANCE)
MNQ_CONFIG_TEXT = input.text_area("", "MNQ CONFIG TEXT", group=GROUP_CONFIG_PASTE)
MBT_CONFIG_TEXT = input.text_area("", "MBT CONFIG TEXT", group=GROUP_CONFIG_PASTE)

BACKTEST_START_MODE = input.string("AUTO_08", "Backtest Start Mode", options=["AUTO_08", "MANUAL"], group=GROUP_BACKTEST)
BACKTEST_MANUAL_START = input.time(timestamp("01 Jan 2025 08:00 +0100"), "Manual Backtest Start", group=GROUP_BACKTEST)

CONFIRMATION_MODE = input.string("NORMAL", "CONFIRMATION MODE", options=["AGGRESSIVE", "NORMAL", "CONSERVATIVE"], group=GROUP_CONFIRMATION)
MNQ_CONFIRMATION_MAX_BARS = input.int(3, "MNQ Confirmation max bars", minval=1, group=GROUP_CONFIRMATION)
MBT_CONFIRMATION_MAX_BARS = input.int(3, "MBT Confirmation max bars", minval=1, group=GROUP_CONFIRMATION)

ACCEPTANCE_MODE = input.string("AUTO_BY_DAY_TYPE", "Acceptance Mode", options=["AUTO_BY_DAY_TYPE", "MANUAL"], group=GROUP_ACCEPTANCE)
MANUAL_ACCEPTANCE_CANDLES = input.int(5, "Manual Acceptance Candles", minval=1, maxval=10, group=GROUP_ACCEPTANCE)

TRADE_HEALTH_MODE = input.string("AUTO PAPER", "Trade Health", options=["OFF", "ANALYSE", "AUTO PAPER"], group=GROUP_TRADE_HEALTH)

RESET_TRADE = input.bool(false, "RESET TRADE", group=GROUP_RESET_DEBUG)
INFO_TABLE_HOVERTEXT = input.bool(false, "INFO TABLE HOVERTEXT", group=GROUP_RESET_DEBUG)
DEBUG_COUNTERS = input.bool(false, "DEBUG COUNTER", group=GROUP_RESET_DEBUG)

autoSessionStart = timestamp(DISPLAY_TZ, year(time, DISPLAY_TZ), month(time, DISPLAY_TZ), dayofmonth(time, DISPLAY_TZ), 8, 0)
backtestConfigStart =
     BACKTEST_START_MODE == "MANUAL" ? BACKTEST_MANUAL_START :
     autoSessionStart
var int activeConfigStart = na
inputConfigId = str.trim(CONFIG_ID)
manualConfigId = inputConfigId == "" ? "AUTO" : inputConfigId
activeModeText = MODE
mnqConfigProvided = str.length(str.trim(MNQ_CONFIG_TEXT)) > 0
mbtConfigProvided = str.length(str.trim(MBT_CONFIG_TEXT)) > 0
activeAssetConfigText =
     MARKET == "MNQ" ? MNQ_CONFIG_TEXT :
     MARKET == "MBT" ? MBT_CONFIG_TEXT :
     ""
activeConfigContentKey = activeModeText + "|" + manualConfigId + "|" + MARKET + "|" + CONFIRMATION_MODE + "|" + str.tostring(autoSessionStart) + "|" + activeAssetConfigText
alertsEnabled =
     ALERT_MODE == "LIVE" ? isSupportedMarket and MODE == "LIVE" :
     ALERT_MODE == "BACKTEST" ? isSupportedMarket and MODE == "BACKTEST" :
     false
paperTradingEnabled = MODE == "BACKTEST" and isSupportedMarket
tradeHealthEnabled = TRADE_HEALTH_MODE != "OFF"
paperHealthAutoManageEnabled = paperTradingEnabled and TRADE_HEALTH_MODE == "AUTO PAPER"
isBacktestFast = MODE == "BACKTEST" and PERFORMANCE_MODE == "BACKTEST_FAST"
isEngineOnly = MODE == "BACKTEST" and PERFORMANCE_MODE == "ENGINE_ONLY"
showFullVisuals = PERFORMANCE_MODE == "FULL"
showLightVisuals = PERFORMANCE_MODE == "FULL" or PERFORMANCE_MODE == "BACKTEST_FAST"
showCockpit = PERFORMANCE_MODE == "FULL" or (PERFORMANCE_MODE == "BACKTEST_FAST" and barstate.islast)
showEngineOnly = PERFORMANCE_MODE == "ENGINE_ONLY"
drawTradePlan = PERFORMANCE_MODE == "FULL"
drawSetupLabels = PERFORMANCE_MODE == "FULL"
drawNoTradeZone = PERFORMANCE_MODE == "FULL"
drawEventLabels = PERFORMANCE_MODE != "ENGINE_ONLY"
drawEventMarkers = PERFORMANCE_MODE != "ENGINE_ONLY"

// =====================================================
// CONFIG PASTE PARSER
// =====================================================

stripConfigComment(line) =>
    slashPos = str.pos(line, "//")
    hashPos = str.pos(line, "#")
    cutPos =
         na(slashPos) ? hashPos :
         na(hashPos) ? slashPos :
         slashPos < hashPos ? slashPos : hashPos
    na(cutPos) ? line : str.substring(line, 0, cutPos)

getConfigValue(configText, key) =>
    string result = ""
    if str.length(str.trim(configText)) > 0
        lines = str.split(configText, "\n")
        for i = 0 to array.size(lines) - 1
            rawLine = array.get(lines, i)
            line = str.trim(stripConfigComment(rawLine))
            eqPos = str.pos(line, "=")
            if not na(eqPos)
                lhs = str.trim(str.substring(line, 0, eqPos))
                rhs = str.trim(str.substring(line, eqPos + 1, str.length(line)))
                if lhs == key
                    result := rhs
    result

getConfigFloat(configText, key, fallback) =>
    rawValue = getConfigValue(configText, key)
    parsedValue = str.tonumber(rawValue)
    str.length(rawValue) == 0 or na(parsedValue) ? fallback : parsedValue

getConfigString(configText, key, fallback) =>
    rawValue = getConfigValue(configText, key)
    cleanedValue = rawValue
    valueLength = str.length(cleanedValue)
    if valueLength >= 2 and str.substring(cleanedValue, 0, 1) == "\"" and str.substring(cleanedValue, valueLength - 1, valueLength) == "\""
        cleanedValue := str.substring(cleanedValue, 1, valueLength - 1)
    str.length(rawValue) == 0 ? fallback : cleanedValue

// =====================================================
// MNQ CONFIG 26.06 DEFAULTS
// =====================================================

MNQ_A_PLUS_LONG_LEVEL_DEFAULT = 0.0
MNQ_A_PLUS_LONG_ENTRY_DEFAULT = 0.0
MNQ_A_PLUS_LONG_SL_DEFAULT    = 0.0
MNQ_A_PLUS_LONG_TP1_DEFAULT   = 0.0
MNQ_A_PLUS_LONG_TP2_DEFAULT   = 0.0

MNQ_A_PLUS_SHORT_LEVEL_DEFAULT = 0.0
MNQ_A_PLUS_SHORT_ENTRY_DEFAULT = 0.0
MNQ_A_PLUS_SHORT_SL_DEFAULT    = 0.0
MNQ_A_PLUS_SHORT_TP1_DEFAULT   = 0.0
MNQ_A_PLUS_SHORT_TP2_DEFAULT   = 0.0

MNQ_B_LONG_LEVEL_DEFAULT = 0.0
MNQ_B_LONG_ENTRY_DEFAULT = 0.0
MNQ_B_LONG_SL_DEFAULT    = 0.0
MNQ_B_LONG_TP1_DEFAULT   = 0.0
MNQ_B_LONG_TP2_DEFAULT   = 0.0

MNQ_B_SHORT_LEVEL_DEFAULT = 0.0
MNQ_B_SHORT_ENTRY_DEFAULT = 0.0
MNQ_B_SHORT_SL_DEFAULT    = 0.0
MNQ_B_SHORT_TP1_DEFAULT   = 0.0
MNQ_B_SHORT_TP2_DEFAULT   = 0.0

MNQ_A_PLUS_PRIORITY_RANGE_DEFAULT = 0.0
MNQ_DAY_TYPE_DEFAULT = "Keine Config"

MNQ_BUY_SIDE_LIQUIDITY_DEFAULT  = 0.0
MNQ_SELL_SIDE_LIQUIDITY_DEFAULT = 0.0

MNQ_NO_TRADE_HIGH_DEFAULT = 0.0
MNQ_NO_TRADE_LOW_DEFAULT  = 0.0

// =====================================================
// MBT CONFIG 26.06 DEFAULTS
// =====================================================

MBT_A_PLUS_LONG_LEVEL_DEFAULT = 0.0
MBT_A_PLUS_LONG_ENTRY_DEFAULT = 0.0
MBT_A_PLUS_LONG_SL_DEFAULT    = 0.0
MBT_A_PLUS_LONG_TP1_DEFAULT   = 0.0
MBT_A_PLUS_LONG_TP2_DEFAULT   = 0.0

MBT_A_PLUS_SHORT_LEVEL_DEFAULT = 0.0
MBT_A_PLUS_SHORT_ENTRY_DEFAULT = 0.0
MBT_A_PLUS_SHORT_SL_DEFAULT    = 0.0
MBT_A_PLUS_SHORT_TP1_DEFAULT   = 0.0
MBT_A_PLUS_SHORT_TP2_DEFAULT   = 0.0

MBT_B_LONG_LEVEL_DEFAULT = 0.0
MBT_B_LONG_ENTRY_DEFAULT = 0.0
MBT_B_LONG_SL_DEFAULT    = 0.0
MBT_B_LONG_TP1_DEFAULT   = 0.0
MBT_B_LONG_TP2_DEFAULT   = 0.0

MBT_B_SHORT_LEVEL_DEFAULT = 0.0
MBT_B_SHORT_ENTRY_DEFAULT = 0.0
MBT_B_SHORT_SL_DEFAULT    = 0.0
MBT_B_SHORT_TP1_DEFAULT   = 0.0
MBT_B_SHORT_TP2_DEFAULT   = 0.0

MBT_A_PLUS_PRIORITY_RANGE_DEFAULT = 0.0
MBT_DAY_TYPE_DEFAULT = "Keine Config"

MBT_BUY_SIDE_LIQUIDITY_DEFAULT  = 0.0
MBT_SELL_SIDE_LIQUIDITY_DEFAULT = 0.0

MBT_NO_TRADE_HIGH_DEFAULT = 0.0
MBT_NO_TRADE_LOW_DEFAULT  = 0.0

// =====================================================
// PASTED / ACTIVE CONFIG VALUES — ONE-PASS ACTIVE ASSET PARSER
// =====================================================

activeAssetConfigProvided =
     MARKET == "MNQ" ? mnqConfigProvided :
     MARKET == "MBT" ? mbtConfigProvided :
     false

var string lastParsedConfigKey = ""
var int configParseCount = 0
var int tableUpdateCount = 0
var int visualUpdateCount = 0

var float parsedLongLevel = 0.0
var float parsedLongEntry = 0.0
var float parsedLongSL = 0.0
var float parsedLongTP1 = 0.0
var float parsedLongTP2 = 0.0

var float parsedShortLevel = 0.0
var float parsedShortEntry = 0.0
var float parsedShortSL = 0.0
var float parsedShortTP1 = 0.0
var float parsedShortTP2 = 0.0

var float parsedBLongLevel = 0.0
var float parsedBLongEntry = 0.0
var float parsedBLongSL = 0.0
var float parsedBLongTP1 = 0.0
var float parsedBLongTP2 = 0.0

var float parsedBShortLevel = 0.0
var float parsedBShortEntry = 0.0
var float parsedBShortSL = 0.0
var float parsedBShortTP1 = 0.0
var float parsedBShortTP2 = 0.0

var float parsedPriorityRange = 0.0
var string parsedDayType = "Keine Config"
var float parsedBuySideLiquidity = 0.0
var float parsedSellSideLiquidity = 0.0
var float parsedNoTradeHigh = 0.0
var float parsedNoTradeLow = 0.0

parseConfigKey = MARKET + "|" + activeAssetConfigText
parseNeeded = barstate.isfirst or parseConfigKey != lastParsedConfigKey

if parseNeeded
    parsedLongLevel := 0.0
    parsedLongEntry := 0.0
    parsedLongSL := 0.0
    parsedLongTP1 := 0.0
    parsedLongTP2 := 0.0
    parsedShortLevel := 0.0
    parsedShortEntry := 0.0
    parsedShortSL := 0.0
    parsedShortTP1 := 0.0
    parsedShortTP2 := 0.0
    parsedBLongLevel := 0.0
    parsedBLongEntry := 0.0
    parsedBLongSL := 0.0
    parsedBLongTP1 := 0.0
    parsedBLongTP2 := 0.0
    parsedBShortLevel := 0.0
    parsedBShortEntry := 0.0
    parsedBShortSL := 0.0
    parsedBShortTP1 := 0.0
    parsedBShortTP2 := 0.0
    parsedPriorityRange := 0.0
    parsedDayType := activeAssetConfigProvided ? "INVALID / MISSING" : "Keine Config"
    parsedBuySideLiquidity := 0.0
    parsedSellSideLiquidity := 0.0
    parsedNoTradeHigh := 0.0
    parsedNoTradeLow := 0.0
    if activeAssetConfigProvided
        lines = str.split(activeAssetConfigText, "\n")
        for i = 0 to array.size(lines) - 1
            rawLine = array.get(lines, i)
            line = str.trim(stripConfigComment(rawLine))
            eqPos = str.pos(line, "=")
            if not na(eqPos)
                lhs = str.trim(str.substring(line, 0, eqPos))
                rhsRaw = str.trim(str.substring(line, eqPos + 1, str.length(line)))
                rhs = rhsRaw
                rhsLength = str.length(rhs)
                if rhsLength >= 2 and str.substring(rhs, 0, 1) == "\"" and str.substring(rhs, rhsLength - 1, rhsLength) == "\""
                    rhs := str.substring(rhs, 1, rhsLength - 1)
                parsedFloat = str.tonumber(rhsRaw)
                if lhs == MARKET + "_A_PLUS_LONG_LEVEL" and not na(parsedFloat)
                    parsedLongLevel := parsedFloat
                else if lhs == MARKET + "_A_PLUS_LONG_ENTRY" and not na(parsedFloat)
                    parsedLongEntry := parsedFloat
                else if lhs == MARKET + "_A_PLUS_LONG_SL" and not na(parsedFloat)
                    parsedLongSL := parsedFloat
                else if lhs == MARKET + "_A_PLUS_LONG_TP1" and not na(parsedFloat)
                    parsedLongTP1 := parsedFloat
                else if lhs == MARKET + "_A_PLUS_LONG_TP2" and not na(parsedFloat)
                    parsedLongTP2 := parsedFloat
                else if lhs == MARKET + "_A_PLUS_SHORT_LEVEL" and not na(parsedFloat)
                    parsedShortLevel := parsedFloat
                else if lhs == MARKET + "_A_PLUS_SHORT_ENTRY" and not na(parsedFloat)
                    parsedShortEntry := parsedFloat
                else if lhs == MARKET + "_A_PLUS_SHORT_SL" and not na(parsedFloat)
                    parsedShortSL := parsedFloat
                else if lhs == MARKET + "_A_PLUS_SHORT_TP1" and not na(parsedFloat)
                    parsedShortTP1 := parsedFloat
                else if lhs == MARKET + "_A_PLUS_SHORT_TP2" and not na(parsedFloat)
                    parsedShortTP2 := parsedFloat
                else if lhs == MARKET + "_B_LONG_LEVEL" and not na(parsedFloat)
                    parsedBLongLevel := parsedFloat
                else if lhs == MARKET + "_B_LONG_ENTRY" and not na(parsedFloat)
                    parsedBLongEntry := parsedFloat
                else if lhs == MARKET + "_B_LONG_SL" and not na(parsedFloat)
                    parsedBLongSL := parsedFloat
                else if lhs == MARKET + "_B_LONG_TP1" and not na(parsedFloat)
                    parsedBLongTP1 := parsedFloat
                else if lhs == MARKET + "_B_LONG_TP2" and not na(parsedFloat)
                    parsedBLongTP2 := parsedFloat
                else if lhs == MARKET + "_B_SHORT_LEVEL" and not na(parsedFloat)
                    parsedBShortLevel := parsedFloat
                else if lhs == MARKET + "_B_SHORT_ENTRY" and not na(parsedFloat)
                    parsedBShortEntry := parsedFloat
                else if lhs == MARKET + "_B_SHORT_SL" and not na(parsedFloat)
                    parsedBShortSL := parsedFloat
                else if lhs == MARKET + "_B_SHORT_TP1" and not na(parsedFloat)
                    parsedBShortTP1 := parsedFloat
                else if lhs == MARKET + "_B_SHORT_TP2" and not na(parsedFloat)
                    parsedBShortTP2 := parsedFloat
                else if lhs == MARKET + "_A_PLUS_PRIORITY_RANGE" and not na(parsedFloat)
                    parsedPriorityRange := parsedFloat
                else if lhs == MARKET + "_DAY_TYPE"
                    parsedDayType := rhs
                else if lhs == MARKET + "_BUY_SIDE_LIQUIDITY" and not na(parsedFloat)
                    parsedBuySideLiquidity := parsedFloat
                else if lhs == MARKET + "_SELL_SIDE_LIQUIDITY" and not na(parsedFloat)
                    parsedSellSideLiquidity := parsedFloat
                else if lhs == MARKET + "_NO_TRADE_HIGH" and not na(parsedFloat)
                    parsedNoTradeHigh := parsedFloat
                else if lhs == MARKET + "_NO_TRADE_LOW" and not na(parsedFloat)
                    parsedNoTradeLow := parsedFloat
    lastParsedConfigKey := parseConfigKey
    configParseCount := configParseCount + 1

longLevel = parsedLongLevel
longEntry = parsedLongEntry
longSL = parsedLongSL
longTP1 = parsedLongTP1
longTP2 = parsedLongTP2

shortLevel = parsedShortLevel
shortEntry = parsedShortEntry
shortSL = parsedShortSL
shortTP1 = parsedShortTP1
shortTP2 = parsedShortTP2

bLongLevel = parsedBLongLevel
bLongEntry = parsedBLongEntry
bLongSL = parsedBLongSL
bLongTP1 = parsedBLongTP1
bLongTP2 = parsedBLongTP2

bShortLevel = parsedBShortLevel
bShortEntry = parsedBShortEntry
bShortSL = parsedBShortSL
bShortTP1 = parsedBShortTP1
bShortTP2 = parsedBShortTP2

aPlusPriorityRange = parsedPriorityRange
dayType = parsedDayType
liquidityLong = parsedBuySideLiquidity
liquidityShort = parsedSellSideLiquidity
noTradeHigh = parsedNoTradeHigh
noTradeLow = parsedNoTradeLow

// =====================================================
// SETUP AVAILABILITY ENGINE — CONFIG DRIVEN
// =====================================================
// Config is the source of truth:
// - Only Long values set  => Long only
// - Only Short values set => Short only
// - Both values set       => both are watched until one side arms or touches first

longConfigHasAny =
     longLevel > 0 or
     longEntry > 0 or
     longSL > 0 or
     longTP1 > 0 or
     longTP2 > 0

shortConfigHasAny =
     shortLevel > 0 or
     shortEntry > 0 or
     shortSL > 0 or
     shortTP1 > 0 or
     shortTP2 > 0

bLongConfigHasAny =
     bLongLevel > 0 or
     bLongEntry > 0 or
     bLongSL > 0 or
     bLongTP1 > 0 or
     bLongTP2 > 0

bShortConfigHasAny =
     bShortLevel > 0 or
     bShortEntry > 0 or
     bShortSL > 0 or
     bShortTP1 > 0 or
     bShortTP2 > 0

longSetupAllowed =
     longLevel > 0 and
     longEntry > 0 and
     longSL > 0 and
     longTP1 > 0 and
     longTP2 > 0

shortSetupAllowed =
     shortLevel > 0 and
     shortEntry > 0 and
     shortSL > 0 and
     shortTP1 > 0 and
     shortTP2 > 0

bLongSetupAllowed =
     bLongLevel > 0 and
     bLongEntry > 0 and
     bLongSL > 0 and
     bLongTP1 > 0 and
     bLongTP2 > 0

bShortSetupAllowed =
     bShortLevel > 0 and
     bShortEntry > 0 and
     bShortSL > 0 and
     bShortTP1 > 0 and
     bShortTP2 > 0

longConfigIncomplete = longConfigHasAny and not longSetupAllowed
shortConfigIncomplete = shortConfigHasAny and not shortSetupAllowed
bLongConfigIncomplete = bLongConfigHasAny and not bLongSetupAllowed
bShortConfigIncomplete = bShortConfigHasAny and not bShortSetupAllowed
activeConfigValid = longSetupAllowed or shortSetupAllowed or bLongSetupAllowed or bShortSetupAllowed
activeConfigStringValid = not activeAssetConfigProvided or (dayType != "INVALID / MISSING" and dayType != "")

configStatusText =
     activeAssetConfigProvided and (longConfigIncomplete or shortConfigIncomplete or bLongConfigIncomplete or bShortConfigIncomplete or not activeConfigValid or not activeConfigStringValid) ? "PASTE INVALID" :
     activeAssetConfigProvided ? "Eingefügt" :
     "KEINE CONFIG"

configStatusColor =
     configStatusText == "PASTE INVALID" ? color.red :
     configStatusText == "Eingefügt" ? color.green :
     color.gray

// =====================================================
// SESSION ENGINE 08:00 MADRID
// =====================================================
sessionStart = activeConfigStart

newSession =
     not na(time[1]) and time[1] < sessionStart and time >= sessionStart

isTracking = time >= activeConfigStart

// =====================================================
// US OPEN FILTER
// =====================================================
// Blocks Entry Confirmation during US Cash Open volatility.
// Madrid time: 15:25–15:45

usOpenStart = timestamp(DISPLAY_TZ, year(time, DISPLAY_TZ), month(time, DISPLAY_TZ), dayofmonth(time, DISPLAY_TZ), 15, 25)
usOpenEnd   = timestamp(DISPLAY_TZ, year(time, DISPLAY_TZ), month(time, DISPLAY_TZ), dayofmonth(time, DISPLAY_TZ), 15, 45)

isUsOpenWindow = time >= usOpenStart and time <= usOpenEnd

// =====================================================
// TIME FORMAT
// =====================================================
timeToText(t) =>
    not na(t) ?
     str.tostring(hour(t, DISPLAY_TZ), "00") + ":" +
     str.tostring(minute(t, DISPLAY_TZ), "00") :
     "-"

// =====================================================
// VARIABLE DEFINITIONS — RUNTIME STATE
// =====================================================

// Setup state machine
const int STATE_WAITING = 0
const int STATE_ARMED = 1
const int STATE_TOUCHED = 2
const int STATE_CONFIRMED = 3
const int STATE_ACTIVE = 4
const int STATE_FINISHED = 5
const int STATE_CONSUMED = 6

const int QUALITY_A_PLUS = 1
const int QUALITY_B = 2

// Akzeptanz Engine
// Measures only the first bars after a confirmed Entry. It never exits a trade.
// The later Trade Energy Engine can reuse acceptanceScore as a clean input.

var int setupState = STATE_WAITING
var int setupQuality = QUALITY_A_PLUS
var string setupUsedReason = ""
var string confirmationStatusText = ""

// Trade event state
var bool tp1Hit = false
var bool tp2Hit = false
var bool slHit = false
var bool hadSlToday = false
var string tradeSide = ""

// Backtest paper-trade state
var bool tradeActive = false
var bool paperTradeClosed = false
var bool beActive = false
var float mfe = na
var float mae = na
var string tradeOutcome = ""
var float tradeQty = na
var float paperTp1Qty = na
var float paperRunnerQty = na
var float paperInitialSL = na
var float paperSL = na
var float paperTP1 = na
var float paperTP2 = na
var string paperEntryId = ""
var bool paperEntryPending = false
var string originalOutcome = ""
var string healthManagedOutcome = ""

// Trade Health state
var bool healthMovedSlToBE = false
var int healthBEBar = na
var bool healthExit = false
var string healthRecommendation = "Halten"
var float healthExitPrice = na
var int healthExitTime = na
var int bestMfeBar = na
var bool healthBEAlerted = false
var bool healthHardExitAlerted = false
var bool healthWarningAlerted = false
var string paperActionText = "-"
var float healthExitPnL = na
var float frozenHealthScore = na
var string frozenHealthStatus = "-"
var string frozenHealthRecommendation = "Halten"
var string frozenHealthReason = "-"

// Freshness anchor after structural setup activation
var float highestSinceArmed = na
var float lowestSinceArmed = na
var int setupArmedBar = na

var int entryTime = na
var int entryBar = na
var float entryPrice = na
var int entryTouchedTime = na
var int entryTouchedBar = na
var int entryConfirmedTime = na
var int entryConfirmedBar = na
var int tp1Time = na
var int tp1Bar = na
var int tp2Time = na
var int tp2Bar = na
var int slTime = na
var int slBar = na
var int exitTime = na
var int exitBar = na
var float exitPrice = na
var string exitReason = ""
var string exitTrigger = ""
var bool touchMarkerDrawn = false
var bool usOpenFilterAlerted = false
var bool timeframeAlerted = false

// Akzeptanz state
// acceptanceStartBar marks the confirmed Entry bar.
// acceptanceEndBar stores the latest bar that contributed to the score.
// acceptanceScore is kept after the configured window so later modules can read the final value.
var int acceptanceStartBar = na
var int acceptanceEndBar = na
var float acceptanceScore = na

// Config state
var string lastConfigId = ""
var int configPasteAppliedTime = na
var int configStartBar = na
var bool configTimeActivated = false

// Setup / Retest state
var bool longBroken = false
var bool shortBroken = false
var bool longRetestDone = false
var bool shortRetestDone = false

// Freshness state
var float highestSinceConfig = na
var float lowestSinceConfig = na

if newSession
    setupState := STATE_WAITING
    setupQuality := QUALITY_A_PLUS
    setupUsedReason := ""
    confirmationStatusText := ""
    tp1Hit := false
    tp2Hit := false
    slHit := false
    hadSlToday := false
    tradeSide := ""
    tradeActive := false
    paperTradeClosed := false
    beActive := false
    mfe := na
    mae := na
    tradeOutcome := ""
    tradeQty := na
    paperTp1Qty := na
    paperRunnerQty := na
    paperInitialSL := na
    paperSL := na
    paperTP1 := na
    paperTP2 := na
    paperEntryId := ""
    paperEntryPending := false
    originalOutcome := ""
    healthManagedOutcome := ""
    healthMovedSlToBE := false
    healthBEBar := na
    healthExit := false
    healthRecommendation := "Halten"
    healthExitPrice := na
    healthExitTime := na
    bestMfeBar := na
    healthBEAlerted := false
    healthHardExitAlerted := false
    healthWarningAlerted := false
    paperActionText := "-"
    healthExitPnL := na
    frozenHealthScore := na
    frozenHealthStatus := "-"
    frozenHealthRecommendation := "Halten"
    frozenHealthReason := "-"
    setupArmedBar := na
    highestSinceArmed := na
    lowestSinceArmed := na
    entryTime := na
    entryBar := na
    entryPrice := na
    entryTouchedTime := na
    entryTouchedBar := na
    entryConfirmedTime := na
    entryConfirmedBar := na
    touchMarkerDrawn := false
    tp1Time := na
    tp1Bar := na
    tp2Time := na
    tp2Bar := na
    slTime := na
    slBar := na
    exitTime := na
    exitBar := na
    exitPrice := na
    exitReason := ""
    exitTrigger := ""
    usOpenFilterAlerted := false
    timeframeAlerted := false
    acceptanceStartBar := na
    acceptanceEndBar := na
    acceptanceScore := na

    longBroken := false
    shortBroken := false
    longRetestDone := false
    shortRetestDone := false

    configTimeActivated := false
    activeConfigStart := na
    configStartBar := na
    highestSinceConfig := na
    lowestSinceConfig := na

// =====================================================
// SETUP ENGINE
// =====================================================
longInRange =
     time >= activeConfigStart and longLevel > 0 and math.abs(close - longLevel) <= aPlusPriorityRange

shortInRange =
     time >= activeConfigStart and shortLevel > 0 and math.abs(close - shortLevel) <= aPlusPriorityRange

aPlusInReach = longInRange or shortInRange

longBreakout =
     isTracking and time >= activeConfigStart and longLevel > 0 and close > longLevel and close[1] <= longLevel

shortBreakout =
     isTracking and time >= activeConfigStart and shortLevel > 0 and close < shortLevel and close[1] >= shortLevel

if newSession
    longBroken := false
    shortBroken := false
    longRetestDone := false
    shortRetestDone := false

if longBreakout
    longBroken := true
    longRetestDone := false

if shortBreakout
    shortBroken := true
    shortRetestDone := false

longRetest =
     isTracking and time >= activeConfigStart and longBroken and not longRetestDone and low <= longLevel and close > longLevel

shortRetest =
     isTracking and time >= activeConfigStart and shortBroken and not shortRetestDone and high >= shortLevel and close < shortLevel

if longRetest
    longRetestDone := true

if shortRetest
    shortRetestDone := true

// =====================================================
// CONFIG ID RESET ENGINE
// =====================================================

// BACKTEST / Replay must use a stable day anchor. last_bar_time moves with the replay cursor
// and would reset the state machine while stepping forward.
pendingActiveConfigStart =
     MODE == "BACKTEST" ? backtestConfigStart :
     activeAssetConfigProvided ? last_bar_time :
     autoSessionStart
activeConfigStart := na(activeConfigStart) ? pendingActiveConfigStart : activeConfigStart
configChanged = activeConfigContentKey != lastConfigId

if configChanged or RESET_TRADE
    if configChanged
        activeConfigStart := pendingActiveConfigStart
        configPasteAppliedTime := activeAssetConfigProvided ? (MODE == "LIVE" ? timenow : activeConfigStart) : na

    configStartBar := na
    configTimeActivated := false

    setupState := STATE_WAITING
    setupQuality := QUALITY_A_PLUS
    setupUsedReason := ""
    confirmationStatusText := ""
    setupArmedBar := na
    highestSinceArmed := na
    lowestSinceArmed := na

    tp1Hit := false
    tp2Hit := false
    slHit := false
    hadSlToday := false

    tradeSide := ""
    tradeActive := false
    paperTradeClosed := false
    beActive := false
    mfe := na
    mae := na
    tradeOutcome := ""
    tradeQty := na
    paperTp1Qty := na
    paperRunnerQty := na
    paperInitialSL := na
    paperSL := na
    paperTP1 := na
    paperTP2 := na
    paperEntryId := ""
    paperEntryPending := false
    originalOutcome := ""
    healthManagedOutcome := ""
    healthMovedSlToBE := false
    healthBEBar := na
    healthExit := false
    healthRecommendation := "Halten"
    healthExitPrice := na
    healthExitTime := na
    bestMfeBar := na
    healthBEAlerted := false
    healthHardExitAlerted := false
    healthWarningAlerted := false
    paperActionText := "-"
    healthExitPnL := na
    frozenHealthScore := na
    frozenHealthStatus := "-"
    frozenHealthRecommendation := "Halten"
    frozenHealthReason := "-"

    entryTime := na
    entryBar := na
    entryPrice := na
    entryTouchedTime := na
    entryTouchedBar := na
    entryConfirmedTime := na
    entryConfirmedBar := na
    touchMarkerDrawn := false
    tp1Time := na
    tp1Bar := na
    tp2Time := na
    tp2Bar := na
    slTime := na
    slBar := na
    exitTime := na
    exitBar := na
    exitPrice := na
    exitReason := ""
    exitTrigger := ""
    usOpenFilterAlerted := false
    timeframeAlerted := false
    acceptanceStartBar := na
    acceptanceEndBar := na
    acceptanceScore := na

    longBroken := false
    shortBroken := false
    longRetestDone := false
    shortRetestDone := false

    highestSinceConfig := na
    lowestSinceConfig := na

    lastConfigId := activeConfigContentKey

activeConfigKey = activeConfigContentKey + "|" + str.tostring(activeConfigStart)

// =====================================================
// STATE MACHINE — STRUCTURAL ARMING
// =====================================================
// setupState is the single source of truth for the visible and operative setup status.

configStartReached =
     isTracking and
     time >= activeConfigStart

if configStartReached and not configTimeActivated
    configTimeActivated := true
    configStartBar := bar_index
    highestSinceConfig := high
    lowestSinceConfig := low
    setupUsedReason := ""

configTracking =
     configTimeActivated and
     not na(configStartBar) and
     bar_index >= configStartBar

if configTracking
    highestSinceConfig := na(highestSinceConfig) ? high : math.max(highestSinceConfig, high)
    lowestSinceConfig  := na(lowestSinceConfig)  ? low  : math.min(lowestSinceConfig, low)

longSetupArmingNow =
     configTracking and
     setupState == STATE_WAITING and
     longSetupAllowed and
     (longInRange or longBreakout or longRetest)

shortSetupArmingNow =
     configTracking and
     setupState == STATE_WAITING and
     shortSetupAllowed and
     (shortInRange or shortBreakout or shortRetest)

if longSetupArmingNow and setupState == STATE_WAITING
    setupState := STATE_ARMED
    setupQuality := QUALITY_A_PLUS
    tradeSide := "LONG"
    setupArmedBar := bar_index
    highestSinceArmed := high
    lowestSinceArmed := low

if shortSetupArmingNow and setupState == STATE_WAITING
    setupState := STATE_ARMED
    setupQuality := QUALITY_A_PLUS
    tradeSide := "SHORT"
    setupArmedBar := bar_index
    highestSinceArmed := high
    lowestSinceArmed := low

// =====================================================
// FRESHNESS ENGINE v6.1 — READS STATE MACHINE
// =====================================================
// Freshness never owns setup status. It only raises a consume event while setupState is ARMED.

freshnessTracking =
     setupState == STATE_ARMED and
     not na(setupArmedBar) and
     bar_index > setupArmedBar

if freshnessTracking
    highestSinceArmed := na(highestSinceArmed) ? high : math.max(highestSinceArmed, high)
    lowestSinceArmed  := na(lowestSinceArmed)  ? low  : math.min(lowestSinceArmed, low)

// =====================================================
// ENTRY ENGINE — TOUCH / CONFIRMATION / ACTIVE
// =====================================================

entryBaseReady =
     isTracking and
     time >= activeConfigStart and
     configTimeActivated and
     not na(configStartBar) and
     bar_index >= configStartBar and
     setupState == STATE_ARMED

longEntryRiskDistance = longEntry > 0 and longSL > 0 ? math.abs(longEntry - longSL) : na
shortEntryRiskDistance = shortEntry > 0 and shortSL > 0 ? math.abs(shortEntry - shortSL) : na
longTouchStillNearEntry =
     na(longEntryRiskDistance) or
     longEntryRiskDistance <= 0 or
     close >= longEntry - longEntryRiskDistance * 0.50

shortTouchStillNearEntry =
     na(shortEntryRiskDistance) or
     shortEntryRiskDistance <= 0 or
     close <= shortEntry + shortEntryRiskDistance * 0.50

longEntryTouchedNow =
     entryBaseReady and
     barstate.isconfirmed and
     tradeSide == "LONG" and
     longSetupAllowed and
     low <= longEntry and
     longTouchStillNearEntry

shortEntryTouchedNow =
     entryBaseReady and
     barstate.isconfirmed and
     tradeSide == "SHORT" and
     shortSetupAllowed and
     high >= shortEntry and
     shortTouchStillNearEntry

longTP2UsedPreEntry =
     freshnessTracking and
     tradeSide == "LONG" and
     na(entryTouchedTime) and
     not longEntryTouchedNow and
     highestSinceArmed >= longTP2

longTP1UsedPreEntry =
     freshnessTracking and
     tradeSide == "LONG" and
     na(entryTouchedTime) and
     not longEntryTouchedNow and
     highestSinceArmed >= longTP1

shortTP2UsedPreEntry =
     freshnessTracking and
     tradeSide == "SHORT" and
     na(entryTouchedTime) and
     not shortEntryTouchedNow and
     lowestSinceArmed <= shortTP2

shortTP1UsedPreEntry =
     freshnessTracking and
     tradeSide == "SHORT" and
     na(entryTouchedTime) and
     not shortEntryTouchedNow and
     lowestSinceArmed <= shortTP1

if setupState == STATE_ARMED
    if longTP2UsedPreEntry
        setupState := STATE_CONSUMED
        setupUsedReason := "LONG TP2 vor Entry"
    else if longTP1UsedPreEntry
        setupState := STATE_CONSUMED
        setupUsedReason := "LONG TP1 vor Entry"
    else if shortTP2UsedPreEntry
        setupState := STATE_CONSUMED
        setupUsedReason := "SHORT TP2 vor Entry"
    else if shortTP1UsedPreEntry
        setupState := STATE_CONSUMED
        setupUsedReason := "SHORT TP1 vor Entry"

if longEntryTouchedNow and setupState == STATE_ARMED
    setupState := STATE_TOUCHED
    tradeSide := "LONG"
    entryTouchedTime := time
    entryTouchedBar := bar_index
    confirmationStatusText := "WARTET AUF BESTÄTIGUNG"

if shortEntryTouchedNow and setupState == STATE_ARMED
    setupState := STATE_TOUCHED
    tradeSide := "SHORT"
    entryTouchedTime := time
    entryTouchedBar := bar_index
    confirmationStatusText := "WARTET AUF BESTÄTIGUNG"

// =====================================================
// CONFIRMATION ENGINE v6.2 — SCORE BASED
// =====================================================
// The engine only works inside STATE_TOUCHED and can only trigger STATE_CONFIRMED.

confirmationModeText =
     CONFIRMATION_MODE == "AGGRESSIVE" ? "AGGRESSIV" :
     CONFIRMATION_MODE == "CONSERVATIVE" ? "KONSERVATIV" :
     "NORMAL"

confirmationMaxBars =
     MARKET == "MNQ" ? MNQ_CONFIRMATION_MAX_BARS :
     MARKET == "MBT" ? MBT_CONFIRMATION_MAX_BARS :
     3

barRange = high - low
closePositionInRange = barRange > 0 ? (close - low) / barRange : 0.5
vwapValue = ta.vwap(hlc3)
atrValue = ta.atr(14)
atrBase = ta.sma(atrValue, 50)
volatilityRatio = not na(atrBase) and atrBase > 0 ? atrValue / atrBase : 1.0
volatilePhase = volatilityRatio >= 1.25
extremeVolatilePhase = volatilityRatio >= 1.80

longConfirmationScore =
     (close > longEntry ? 25 : 0) +
     (close > longLevel ? 20 : 0) +
     (close > open ? 15 : 0) +
     (closePositionInRange > 0.33 ? 15 : 0) +
     (not na(vwapValue) and close > vwapValue ? 15 : 0) +
     (close > close[1] ? 10 : 0)

shortConfirmationScore =
     (close < shortEntry ? 25 : 0) +
     (close < shortLevel ? 20 : 0) +
     (close < open ? 15 : 0) +
     (closePositionInRange < 0.67 ? 15 : 0) +
     (not na(vwapValue) and close < vwapValue ? 15 : 0) +
     (close < close[1] ? 10 : 0)

confirmationDisplayTracking =
     setupState == STATE_ARMED or
     setupState == STATE_TOUCHED or
     setupState == STATE_CONFIRMED or
     setupState == STATE_ACTIVE

confirmationScore =
     confirmationDisplayTracking and tradeSide == "LONG" ? longConfirmationScore :
     confirmationDisplayTracking and tradeSide == "SHORT" ? shortConfirmationScore :
     0

confirmationBaseMinScore =
     CONFIRMATION_MODE == "CONSERVATIVE" ? 75 :
     CONFIRMATION_MODE == "AGGRESSIVE" ? 50 :
     60

confirmationMinScore =
     extremeVolatilePhase ? 85 :
     math.min(100, confirmationBaseMinScore + (volatilePhase ? 15 : 0) + (hadSlToday ? 15 : 0))

confirmationDetected =
     setupState == STATE_TOUCHED and
     not isUsOpenWindow and
     confirmationScore >= confirmationMinScore

confirmationPassed =
     confirmationDetected and
     barstate.isconfirmed

confirmationTimedOut =
     setupState == STATE_TOUCHED and
     barstate.isconfirmed and
     not na(entryTouchedBar) and
     bar_index - entryTouchedBar >= confirmationMaxBars and
     not confirmationPassed

confirmationMovedTooFarAgainst =
     setupState == STATE_TOUCHED and
     barstate.isconfirmed and
     not confirmationPassed and
     (
         (tradeSide == "LONG" and not na(longEntryRiskDistance) and close < longEntry - longEntryRiskDistance * 0.50) or
         (tradeSide == "SHORT" and not na(shortEntryRiskDistance) and close > shortEntry + shortEntryRiskDistance * 0.50)
     )

confirmationExpired = confirmationTimedOut or confirmationMovedTooFarAgainst

longEntryConfirmedNow =
     confirmationPassed and
     tradeSide == "LONG"

shortEntryConfirmedNow =
     confirmationPassed and
     tradeSide == "SHORT"

longEntryTriggered = longEntryConfirmedNow
shortEntryTriggered = shortEntryConfirmedNow
paperCanOpenTrade = paperTradingEnabled and not tradeActive and not paperTradeClosed

if confirmationExpired
    setupState := STATE_ARMED
    confirmationStatusText := confirmationMovedTooFarAgainst ? "CONFIRMATION ABGEBROCHEN" : "ENTRY NICHT BESTÄTIGT"
    entryTouchedTime := na
    entryTouchedBar := na
    touchMarkerDrawn := false

if longEntryTriggered
    setupState := STATE_CONFIRMED
    tradeSide := "LONG"
    entryPrice := longEntry
    entryTime := paperTradingEnabled ? na : time
    entryBar := paperTradingEnabled ? na : bar_index
    entryConfirmedTime := time
    entryConfirmedBar := bar_index
    acceptanceStartBar := paperTradingEnabled ? na : bar_index
    acceptanceEndBar := na
    acceptanceScore := na
    confirmationStatusText := "ENTRY BESTÄTIGT"
    paperTradeClosed := false
    beActive := false
    mfe := paperTradingEnabled ? na : 0.0
    mae := paperTradingEnabled ? na : 0.0
    tradeOutcome := ""
    tradeQty := MARKET == "MNQ" ? 2.0 : MARKET == "MBT" ? 5.0 : na
    paperTp1Qty := not na(tradeQty) ? tradeQty / 2.0 : na
    paperRunnerQty := paperTp1Qty
    tradeActive := not paperTradingEnabled
    paperEntryPending := paperCanOpenTrade and not na(tradeQty)
    paperInitialSL := longSL
    paperSL := longSL
    paperTP1 := longTP1
    paperTP2 := longTP2
    paperEntryId := "MTO_LONG"
    originalOutcome := ""
    healthManagedOutcome := ""
    healthMovedSlToBE := false
    healthBEBar := na
    healthExit := false
    healthRecommendation := "Halten"
    healthExitPrice := na
    healthExitTime := na
    bestMfeBar := paperTradingEnabled ? na : bar_index
    healthBEAlerted := false
    healthHardExitAlerted := false
    healthWarningAlerted := false
    paperActionText := paperEntryPending ? "Paper Entry wartet" : "-"
    healthExitPnL := na
    frozenHealthScore := na
    frozenHealthStatus := "-"
    frozenHealthRecommendation := "Halten"
    frozenHealthReason := "-"

if shortEntryTriggered
    setupState := STATE_CONFIRMED
    tradeSide := "SHORT"
    entryPrice := shortEntry
    entryTime := paperTradingEnabled ? na : time
    entryBar := paperTradingEnabled ? na : bar_index
    entryConfirmedTime := time
    entryConfirmedBar := bar_index
    acceptanceStartBar := paperTradingEnabled ? na : bar_index
    acceptanceEndBar := na
    acceptanceScore := na
    confirmationStatusText := "ENTRY BESTÄTIGT"
    paperTradeClosed := false
    beActive := false
    mfe := paperTradingEnabled ? na : 0.0
    mae := paperTradingEnabled ? na : 0.0
    tradeOutcome := ""
    tradeQty := MARKET == "MNQ" ? 2.0 : MARKET == "MBT" ? 5.0 : na
    paperTp1Qty := not na(tradeQty) ? tradeQty / 2.0 : na
    paperRunnerQty := paperTp1Qty
    tradeActive := not paperTradingEnabled
    paperEntryPending := paperCanOpenTrade and not na(tradeQty)
    paperInitialSL := shortSL
    paperSL := shortSL
    paperTP1 := shortTP1
    paperTP2 := shortTP2
    paperEntryId := "MTO_SHORT"
    originalOutcome := ""
    healthManagedOutcome := ""
    healthMovedSlToBE := false
    healthBEBar := na
    healthExit := false
    healthRecommendation := "Halten"
    healthExitPrice := na
    healthExitTime := na
    bestMfeBar := paperTradingEnabled ? na : bar_index
    healthBEAlerted := false
    healthHardExitAlerted := false
    healthWarningAlerted := false
    paperActionText := paperEntryPending ? "Paper Entry wartet" : "-"
    healthExitPnL := na
    frozenHealthScore := na
    frozenHealthStatus := "-"
    frozenHealthRecommendation := "Halten"
    frozenHealthReason := "-"

longPaperEntryPriceFilledNow =
     paperTradingEnabled and
     paperEntryPending and
     paperEntryId == "MTO_LONG" and
     not na(entryConfirmedBar) and
     bar_index > entryConfirmedBar and
     not na(entryPrice) and
     high >= entryPrice

shortPaperEntryPriceFilledNow =
     paperTradingEnabled and
     paperEntryPending and
     paperEntryId == "MTO_SHORT" and
     not na(entryConfirmedBar) and
     bar_index > entryConfirmedBar and
     not na(entryPrice) and
     low <= entryPrice

longPaperEntryFilledNow = longPaperEntryPriceFilledNow
shortPaperEntryFilledNow = shortPaperEntryPriceFilledNow
paperEntryFilledNow = longPaperEntryFilledNow or shortPaperEntryFilledNow

if paperEntryFilledNow
    paperEntryPending := false
    tradeActive := true
    entryTime := time
    entryBar := bar_index
    acceptanceStartBar := bar_index
    acceptanceEndBar := na
    acceptanceScore := na
    mfe := 0.0
    mae := 0.0
    bestMfeBar := bar_index
    paperActionText := "Entry gefüllt"

if setupState == STATE_CONFIRMED and (not paperTradingEnabled or paperEntryFilledNow)
    setupState := STATE_ACTIVE

// =====================================================
// INTERNAL BACKTEST PAPER ENGINE
// =====================================================
// Uses the same confirmed Entry, SL, TP1 and TP2 as the visual trade engine.
// Everything is simulated inside this indicator. LIVE mode remains visual/alert-only.

healthActive =
     tradeHealthEnabled and
     setupState == STATE_ACTIVE and
     (not paperTradingEnabled or tradeActive) and
     not na(entryPrice) and
     not na(entryBar) and
     bar_index > entryBar

if healthActive
    if tradeSide == "LONG"
        previousMfe = na(mfe) ? 0.0 : mfe
        currentMfe = math.max(high - entryPrice, 0.0)
        mfe := math.max(previousMfe, currentMfe)
        if mfe > previousMfe
            bestMfeBar := bar_index
        mae := na(mae) ? math.max(entryPrice - low, 0.0) : math.max(mae, entryPrice - low)
    if tradeSide == "SHORT"
        previousMfe = na(mfe) ? 0.0 : mfe
        currentMfe = math.max(entryPrice - low, 0.0)
        mfe := math.max(previousMfe, currentMfe)
        if mfe > previousMfe
            bestMfeBar := bar_index
        mae := na(mae) ? math.max(high - entryPrice, 0.0) : math.max(mae, high - entryPrice)

// =====================================================
// TRADE HEALTH ENGINE v2.1 — CONTEXT-AWARE
// =====================================================
// Health v2.1 has its own phase model:
// PRE_TP1 can recommend Halten / SL auf BE / Hart raus.
// RUNNER_AFTER_TP1 only observes and recommends Halten.
// CLOSED freezes the last health values and never recalculates.
// Paper Trading follows the recommendation only in BACKTEST + AUTO PAPER.

tradeAgeBars =
     healthActive ? bar_index - entryBar :
     0

healthTradeAgeMinutes =
     healthActive ? math.round((time - entryTime) / 60000) :
     0

activeTP1 =
     tradeSide == "LONG" ? longTP1 :
     tradeSide == "SHORT" ? shortTP1 :
     na

activeSL =
     tradeSide == "LONG" ? longSL :
     tradeSide == "SHORT" ? shortSL :
     na

tp1Distance =
     healthActive and not na(activeTP1) ? math.abs(activeTP1 - entryPrice) :
     na

riskDistance =
     healthActive and not na(activeSL) ? math.abs(entryPrice - activeSL) :
     na

currentPnL =
     healthActive and tradeSide == "LONG" ? close - entryPrice :
     healthActive and tradeSide == "SHORT" ? entryPrice - close :
     na

tradeDirection = tradeSide

// Trade Health is intentionally not based on current open PnL.
// TP1 progress measures the best achieved progress toward TP1 (MFE), not whether
// the trade is currently in profit or loss.
tp1ProgressPercent =
     healthActive and not na(tp1Distance) and tp1Distance > 0 ? math.min(100.0, math.max(0.0, (mfe / tp1Distance) * 100.0)) :
     0.0

riskUsedPercent =
     healthActive and not na(riskDistance) and riskDistance > 0 ? math.min(100.0, math.max(0.0, (mae / riskDistance) * 100.0)) :
     0.0

barsSinceBestMFE =
     healthActive and not na(bestMfeBar) ? bar_index - bestMfeBar :
     0

minutesSinceBestMFE =
     healthActive ? (timeframe.isminutes ? barsSinceBestMFE * timeframe.multiplier : math.round((time - entryTime) / 60000)) :
     0

isBackNearEntry =
     healthActive and not na(riskDistance) and riskDistance > 0 ? math.abs(close - entryPrice) <= riskDistance * 0.20 :
     false

isAgainstEntry =
     healthActive and (
         (tradeSide == "LONG" and close < entryPrice) or
         (tradeSide == "SHORT" and close > entryPrice)
     )

momentumInTradeDirection =
     healthActive and (
         (tradeSide == "LONG" and close > close[1]) or
         (tradeSide == "SHORT" and close < close[1])
     )

momentumWeak =
     healthActive and not momentumInTradeDirection

dayTypeLower = str.lower(dayType)

isBalancedDay =
     str.contains(dayTypeLower, "balanced") or
     str.contains(dayTypeLower, "range") or
     str.contains(dayTypeLower, "rotation")

isTrendUp =
     str.contains(dayTypeLower, "trend up")

isTrendDown =
     str.contains(dayTypeLower, "trend down")

isWithDayType =
     not isBalancedDay and (
         (isTrendUp and tradeDirection == "LONG") or
         (isTrendDown and tradeDirection == "SHORT")
     )

isAgainstDayType =
     not isBalancedDay and (
         (isTrendUp and tradeDirection == "SHORT") or
         (isTrendDown and tradeDirection == "LONG")
     )

maxHealthyAgeMinutes =
     isWithDayType ? 180 :
     isBalancedDay ? 90 :
     isAgainstDayType ? 45 :
     120

criticalAgeMinutes =
     isWithDayType ? 240 :
     isBalancedDay ? 150 :
     isAgainstDayType ? 90 :
     180

stallLimitMinutes =
     isWithDayType ? 75 :
     isBalancedDay ? 45 :
     isAgainstDayType ? 30 :
     60

expectedProgressPercent =
     not healthActive ? 0.0 :
     isWithDayType ?
         (healthTradeAgeMinutes >= 180 ? 60.0 : healthTradeAgeMinutes >= 120 ? 45.0 : healthTradeAgeMinutes >= 90 ? 35.0 : healthTradeAgeMinutes >= 60 ? 25.0 : healthTradeAgeMinutes >= 30 ? 15.0 : 0.0) :
     isBalancedDay ?
         (healthTradeAgeMinutes >= 150 ? 65.0 : healthTradeAgeMinutes >= 120 ? 55.0 : healthTradeAgeMinutes >= 90 ? 45.0 : healthTradeAgeMinutes >= 60 ? 35.0 : healthTradeAgeMinutes >= 30 ? 20.0 : 0.0) :
     isAgainstDayType ?
         (healthTradeAgeMinutes >= 90 ? 60.0 : healthTradeAgeMinutes >= 60 ? 45.0 : healthTradeAgeMinutes >= 30 ? 30.0 : healthTradeAgeMinutes >= 15 ? 15.0 : 0.0) :
     (healthTradeAgeMinutes >= 120 ? 50.0 : healthTradeAgeMinutes >= 90 ? 40.0 : healthTradeAgeMinutes >= 60 ? 30.0 : healthTradeAgeMinutes >= 30 ? 15.0 : 0.0)

progressRatio =
     healthActive ? tp1ProgressPercent / math.max(expectedProgressPercent, 1.0) :
     0.0

progressScore =
     progressRatio >= 1.50 ? 30.0 :
     progressRatio >= 1.00 ? 24.0 :
     progressRatio >= 0.75 ? 18.0 :
     progressRatio >= 0.50 ? 10.0 :
     3.0

mfeMaeRatio =
     healthActive ? mfe / math.max(mae, syminfo.mintick) :
     na

efficiencyScore =
     not healthActive or mfe <= 0 ? 0.0 :
     mfeMaeRatio >= 2.0 ? 20.0 :
     mfeMaeRatio >= 1.25 ? 15.0 :
     mfeMaeRatio >= 0.80 ? 8.0 :
     2.0

momentumScore =
     not healthActive ? 0.0 :
     minutesSinceBestMFE <= 15 ? 20.0 :
     minutesSinceBestMFE <= 30 ? 15.0 :
     minutesSinceBestMFE <= stallLimitMinutes ? 8.0 :
     2.0

ageScore =
     not healthActive ? 0.0 :
     healthTradeAgeMinutes <= maxHealthyAgeMinutes ? 15.0 :
     healthTradeAgeMinutes <= criticalAgeMinutes ? 7.0 :
     0.0

pricePositionScore =
     not healthActive ? 0.0 :
     currentPnL > 0 ? 10.0 :
     currentPnL >= 0 ? 5.0 :
     0.0

contextScore =
     not healthActive ? 0.0 :
     isWithDayType ? 5.0 :
     isBalancedDay ? 3.0 :
     isAgainstDayType ? 0.0 :
     2.0

healthScoreRaw =
     healthActive ? progressScore + efficiencyScore + momentumScore + ageScore + pricePositionScore + contextScore :
     na

tradeHealthScore =
     healthActive ? math.min(100.0, math.max(0.0, healthScoreRaw)) :
     na

tradeHealthStatus =
     not healthActive ? "-" :
     tradeHealthScore >= 75 ? "GESUND" :
     tradeHealthScore >= 55 ? "OK" :
     tradeHealthScore >= 35 ? "WARNUNG" :
     tradeHealthScore >= 25 ? "KRITISCH" :
     "TOT"

healthPendingStop =
     beActive and not na(entryPrice) ? entryPrice :
     paperSL

healthClassicStopHitPending =
     tradeActive and
     not na(entryBar) and
     bar_index > entryBar and
     not na(healthPendingStop) and
     (
         (tradeSide == "LONG" and low <= healthPendingStop) or
         (tradeSide == "SHORT" and high >= healthPendingStop)
     )

healthTp1HitPending =
     tradeActive and
     not na(entryBar) and
     bar_index > entryBar and
     not tp1Hit and
     (
         (tradeSide == "LONG" and longTP1 > 0 and high >= longTP1) or
         (tradeSide == "SHORT" and shortTP1 > 0 and low <= shortTP1)
     )

healthTp2HitPending =
     tradeActive and
     not na(entryBar) and
     bar_index > entryBar and
     (
         (tradeSide == "LONG" and longTP2 > 0 and high >= longTP2) or
         (tradeSide == "SHORT" and shortTP2 > 0 and low <= shortTP2)
     )

healthTerminalClassicExitPending = healthClassicStopHitPending or healthTp2HitPending

tradeHealthPhase =
     not healthActive ? "CLOSED" :
     tp1Hit or healthTp1HitPending ? "RUNNER_AFTER_TP1" :
     "PRE_TP1"

healthPreTP1 = tradeHealthPhase == "PRE_TP1"
healthRunnerAfterTP1 = tradeHealthPhase == "RUNNER_AFTER_TP1"

entryReturnZone =
     healthActive and not na(riskDistance) and riskDistance > 0 ? math.abs(close - entryPrice) <= riskDistance * 0.30 :
     false

hardRuleA =
     healthActive and
     healthPreTP1 and
     healthTradeAgeMinutes >= (isAgainstDayType ? 15 : 25) and
     tp1ProgressPercent < 10 and
     riskUsedPercent > 30

hardRuleB =
     healthActive and
     healthPreTP1 and
     healthTradeAgeMinutes >= 90 and
     tp1ProgressPercent < 30 and
     mfe <= mae

hardRuleC =
     healthActive and
     healthPreTP1 and
     isBalancedDay and
     healthTradeAgeMinutes >= 120 and
     tp1ProgressPercent < 50

hardRuleD =
     healthActive and
     healthPreTP1 and
     isAgainstDayType and
     healthTradeAgeMinutes >= 60 and
     tp1ProgressPercent < 40

hardRuleE =
     healthActive and
     healthPreTP1 and
     healthTradeAgeMinutes >= 120 and
     minutesSinceBestMFE >= 60 and
     tp1ProgressPercent < 60

hardRuleFWarning =
     healthActive and
     healthPreTP1 and
     healthTradeAgeMinutes >= 75 and
     tp1ProgressPercent < 50 and
     currentPnL <= 0

hardRuleF =
     hardRuleFWarning and
     mfe <= mae

hardExitRuleActive = hardRuleA or hardRuleB or hardRuleC or hardRuleD or hardRuleE or hardRuleF

beRule1 =
     healthActive and
     healthPreTP1 and
     not healthMovedSlToBE and
     not healthExit and
     tp1ProgressPercent >= 50 and
     healthTradeAgeMinutes >= 60 and
     minutesSinceBestMFE >= 30 and
     currentPnL > 0 and
     entryReturnZone

beRule2 =
     healthActive and
     healthPreTP1 and
     not healthMovedSlToBE and
     not healthExit and
     not na(riskDistance) and
     riskDistance > 0 and
     mfe >= riskDistance and
     minutesSinceBestMFE >= 30 and
     currentPnL > 0

beRule3 =
     healthActive and
     healthPreTP1 and
     isAgainstDayType and
     not healthMovedSlToBE and
     not healthExit and
     tp1ProgressPercent >= 40 and
     healthTradeAgeMinutes >= 30 and
     minutesSinceBestMFE >= 20 and
     currentPnL > 0

beRuleActive = beRule1 or beRule2 or beRule3

healthStatusAdjusted =
     not healthActive ? "-" :
     healthRunnerAfterTP1 ? tradeHealthStatus :
     hardExitRuleActive ? "TOT" :
     tradeHealthStatus == "TOT" ? "TOT" :
     hardRuleFWarning ? "KRITISCH" :
     tradeHealthStatus

healthIsTot =
     healthActive and
     healthPreTP1 and
     healthStatusAdjusted == "TOT"

healthRecommendation :=
     not healthActive ? frozenHealthRecommendation :
     healthRunnerAfterTP1 ? "Halten" :
     hardExitRuleActive ? "Hart raus" :
     healthIsTot ? "Hart raus" :
     beRuleActive ? "SL auf BE" :
     "Halten"

healthReason =
     not healthActive ? frozenHealthReason :
     healthRunnerAfterTP1 ? "Runner nach TP1, Health beobachtet nur" :
     hardRuleA ? "Keine Akzeptanz nach Entry" :
     hardRuleB ? "Trade liefert nicht" :
     hardRuleC ? "Balanced Trade gealtert ohne Fortschritt" :
     hardRuleD ? "Contra-Trade liefert nicht schnell genug" :
     hardRuleE ? "Momentum tot" :
     hardRuleF ? "Zurück gegen Entry ohne ausreichenden Fortschritt" :
     beRule1 ? "Guter Fortschritt, Momentum lässt nach" :
     beRule2 ? "MFE >= 1R, Risiko rausnehmen" :
     beRule3 ? "Contra-Trade hat geliefert, Risiko rausnehmen" :
     healthIsTot ? "Health TOT: Setup liefert nicht mehr" :
     hardRuleFWarning ? "Zurück am Entry, Health kritisch" :
     "Trade gesund genug"

healthBEActionNow = false
healthHardExitNow = false
healthBERecommendationNow =
     healthActive and
     healthRecommendation == "SL auf BE" and
     not healthBEAlerted

healthHardExitRecommendationNow =
     healthActive and
     healthRecommendation == "Hart raus" and
     not healthHardExitAlerted

healthWarningNow =
     healthActive and
     not healthWarningAlerted and
     (healthStatusAdjusted == "WARNUNG" or healthStatusAdjusted == "KRITISCH")

if healthActive
    frozenHealthScore := tradeHealthScore
    frozenHealthStatus := healthStatusAdjusted
    frozenHealthRecommendation := healthRecommendation
    frozenHealthReason := healthReason

healthBERecommendationNow := healthBERecommendationNow and not healthTerminalClassicExitPending and not healthTp1HitPending
healthHardExitRecommendationNow := healthHardExitRecommendationNow and not healthTerminalClassicExitPending and not healthTp1HitPending

if paperHealthAutoManageEnabled and healthPreTP1 and not healthTerminalClassicExitPending and not healthTp1HitPending and healthRecommendation == "SL auf BE" and not healthMovedSlToBE and not healthExit and currentPnL > 0
    paperSL := entryPrice
    beActive := true
    healthMovedSlToBE := true
    healthBEBar := bar_index
    originalOutcome := "NICHT SIMULIERT"
    paperActionText := "SL auf BE"
    healthBEActionNow := true

if paperHealthAutoManageEnabled and healthPreTP1 and not healthTerminalClassicExitPending and not healthTp1HitPending and healthRecommendation == "Hart raus" and not healthExit and tradeActive and not paperTradeClosed and not tp2Hit and not slHit
    healthExit := true
    healthExitPrice := close
    healthExitTime := time
    healthExitPnL := tradeSide == "LONG" ? close - entryPrice : entryPrice - close
    originalOutcome := "NICHT SIMULIERT"
    healthManagedOutcome := "HEALTH_EXIT"
    tradeOutcome := "HEALTH_EXIT"
    exitReason := "Hart raus"
    exitTrigger := "Trade Health"
    exitPrice := close
    exitTime := time
    exitBar := bar_index
    paperActionText := "Hart raus"
    tradeActive := false
    paperTradeClosed := true
    setupState := STATE_FINISHED
    healthHardExitNow := true

healthBEStopCanTrigger =
     not healthMovedSlToBE or
     na(healthBEBar) or
     bar_index > healthBEBar

// =====================================================
// ENTRY ZONE VALIDITY ENGINE
// =====================================================
// STATE_TOUCHED remains stable until confirmation passes or confirmationExpired returns it to ARMED.

// =====================================================
// TP / SL ENGINE
// =====================================================
tradeExecutionActive = setupState == STATE_ACTIVE
canEvaluateTradeExit =
     tradeExecutionActive and
     not na(entryBar) and
     bar_index > entryBar

longTP1HitNow = canEvaluateTradeExit and tradeSide == "LONG" and not tp1Hit and longTP1 > 0 and high >= longTP1
longTP2HitNow = canEvaluateTradeExit and tradeSide == "LONG" and not tp2Hit and longTP2 > 0 and high >= longTP2

activePaperSL =
     paperTradingEnabled and beActive and not na(entryPrice) and healthBEStopCanTrigger ? entryPrice :
     paperTradingEnabled and not na(paperSL) and healthBEStopCanTrigger ? paperSL :
     tradeSide == "LONG" ? longSL :
     tradeSide == "SHORT" ? shortSL :
     na

activeStopIsBE =
     paperTradingEnabled and
     beActive and
     healthBEStopCanTrigger and
     not na(entryPrice) and
     not na(activePaperSL) and
     math.abs(activePaperSL - entryPrice) <= syminfo.mintick

longSLHitNow =
     canEvaluateTradeExit and
     tradeSide == "LONG" and
     not slHit and
     not na(activePaperSL) and
     activePaperSL > 0 and
     low <= activePaperSL

shortTP1HitNow = canEvaluateTradeExit and tradeSide == "SHORT" and not tp1Hit and shortTP1 > 0 and low <= shortTP1
shortTP2HitNow = canEvaluateTradeExit and tradeSide == "SHORT" and not tp2Hit and shortTP2 > 0 and low <= shortTP2
shortSLHitNow =
     canEvaluateTradeExit and
     tradeSide == "SHORT" and
     not slHit and
     not na(activePaperSL) and
     activePaperSL > 0 and
     high >= activePaperSL

activeSLHitNow = longSLHitNow or shortSLHitNow
activeBEHitNow = activeSLHitNow and activeStopIsBE
classicSLHitNow = activeSLHitNow and not activeStopIsBE

// =====================================================
// TP / SL EXECUTION ORDER
// =====================================================

if tradeExecutionActive and tradeSide == "LONG"
    if longTP1HitNow
        tp1Hit := true
        beActive := paperTradingEnabled ? true : beActive
        paperSL := paperTradingEnabled ? entryPrice : paperSL
        tp1Time := time
        tp1Bar := bar_index
    if longTP2HitNow
        tp2Hit := true
        tp2Time := time
        tp2Bar := bar_index
        exitTime := time
        exitBar := bar_index
        exitPrice := longTP2
        exitReason := "TP2"
        exitTrigger := "HIGH >= TP2"
        tradeOutcome := "TP2"
        originalOutcome := originalOutcome == "" ? "TP2" : originalOutcome
        healthManagedOutcome := healthManagedOutcome == "" ? "TP2" : healthManagedOutcome
        tradeActive := false
        paperTradeClosed := true
        setupState := STATE_FINISHED
    else if longSLHitNow
        slHit := not activeStopIsBE
        hadSlToday := activeStopIsBE ? hadSlToday : true
        slTime := activeStopIsBE ? slTime : time
        slBar := activeStopIsBE ? slBar : bar_index
        exitTime := time
        exitBar := bar_index
        exitPrice := activeStopIsBE ? entryPrice : activePaperSL
        exitReason := activeStopIsBE and healthMovedSlToBE ? "Trade Health" : activeStopIsBE ? "BE" : "SL"
        exitTrigger := "LOW <= ACTIVE SL"
        tradeOutcome := activeStopIsBE ? "BE" : "SL"
        originalOutcome := originalOutcome == "" ? (activeStopIsBE ? "BE" : "SL") : originalOutcome
        healthManagedOutcome := healthManagedOutcome == "" ? (activeStopIsBE ? "BE" : "SL") : healthManagedOutcome
        paperActionText := activeStopIsBE ? "BE erreicht" : paperActionText
        tradeActive := false
        paperTradeClosed := true
        setupState := STATE_FINISHED

if tradeExecutionActive and tradeSide == "SHORT"
    if shortTP1HitNow
        tp1Hit := true
        beActive := paperTradingEnabled ? true : beActive
        paperSL := paperTradingEnabled ? entryPrice : paperSL
        tp1Time := time
        tp1Bar := bar_index
    if shortTP2HitNow
        tp2Hit := true
        tp2Time := time
        tp2Bar := bar_index
        exitTime := time
        exitBar := bar_index
        exitPrice := shortTP2
        exitReason := "TP2"
        exitTrigger := "LOW <= TP2"
        tradeOutcome := "TP2"
        originalOutcome := originalOutcome == "" ? "TP2" : originalOutcome
        healthManagedOutcome := healthManagedOutcome == "" ? "TP2" : healthManagedOutcome
        tradeActive := false
        paperTradeClosed := true
        setupState := STATE_FINISHED
    else if shortSLHitNow
        slHit := not activeStopIsBE
        hadSlToday := activeStopIsBE ? hadSlToday : true
        slTime := activeStopIsBE ? slTime : time
        slBar := activeStopIsBE ? slBar : bar_index
        exitTime := time
        exitBar := bar_index
        exitPrice := activeStopIsBE ? entryPrice : activePaperSL
        exitReason := activeStopIsBE and healthMovedSlToBE ? "Trade Health" : activeStopIsBE ? "BE" : "SL"
        exitTrigger := "HIGH >= ACTIVE SL"
        tradeOutcome := activeStopIsBE ? "BE" : "SL"
        originalOutcome := originalOutcome == "" ? (activeStopIsBE ? "BE" : "SL") : originalOutcome
        healthManagedOutcome := healthManagedOutcome == "" ? (activeStopIsBE ? "BE" : "SL") : healthManagedOutcome
        paperActionText := activeStopIsBE ? "BE erreicht" : paperActionText
        tradeActive := false
        paperTradeClosed := true
        setupState := STATE_FINISHED

tradeExecutionActive := setupState == STATE_ACTIVE

// =====================================================
// AKZEPTANZ ENGINE v1 — POST-ENTRY OBSERVATION ONLY
// =====================================================
// Purpose:
// - Starts only after a confirmed Entry.
// - Observes only the first configured acceptance candles after the Entry bar.
// - Scores whether the market accepts the Entry with early momentum.
// - Does not close, weaken, block or otherwise manage the trade.
// - acceptanceScore is intentionally modular so a later Trade Energy Engine can reuse it.

dayTypeAcceptanceCandles =
     dayType == "Trend Up" ? 3 :
     dayType == "Trend Down" ? 3 :
     dayType == "Balanced" ? 5 :
     dayType == "Balanced / Reversal" ? 5 :
     dayType == "Reversal" ? 5 :
     dayType == "Compression" ? 5 :
     dayType == "Transition" ? 5 :
     MANUAL_ACCEPTANCE_CANDLES

acceptanceCandles =
     ACCEPTANCE_MODE == "AUTO_BY_DAY_TYPE" ? dayTypeAcceptanceCandles :
     MANUAL_ACCEPTANCE_CANDLES

acceptanceWindowActive =
     not na(acceptanceStartBar) and
     bar_index > acceptanceStartBar and
     bar_index <= acceptanceStartBar + acceptanceCandles and
     (setupState == STATE_ACTIVE or setupState == STATE_FINISHED)

acceptanceBarsObserved =
     not na(acceptanceStartBar) ? math.min(math.max(bar_index - acceptanceStartBar, 0), acceptanceCandles) : 0

currentBodySize = math.abs(close - open)
currentBodyRatio = barRange > 0 ? currentBodySize / barRange : 0.0
previousRange = high[1] - low[1]
previousBodySize = math.abs(close[1] - open[1])
previousBodyRatio = previousRange > 0 ? previousBodySize / previousRange : 0.0

smallCurrentBody = currentBodyRatio < 0.25
smallPreviousBody = previousBodyRatio < 0.25
multipleSmallBodies = smallCurrentBody and smallPreviousBody

longTp1ApproachDistance = longTP1 > 0 and not na(entryPrice) ? math.abs(longTP1 - entryPrice) * 0.25 : 0.0
shortTp1ApproachDistance = shortTP1 > 0 and not na(entryPrice) ? math.abs(entryPrice - shortTP1) * 0.25 : 0.0

longAcceptanceRawScore =
     50 +
     (not na(entryPrice) and close > entryPrice ? 15 : -20) +
     (high > high[1] ? 10 : -10) +
     (low > low[1] ? 10 : -10) +
     (not na(entryPrice) and longTp1ApproachDistance > 0 and high >= entryPrice + longTp1ApproachDistance ? 15 : 0) +
     (tp1Hit ? 20 : 0) +
     (multipleSmallBodies ? -10 : 0) +
     (close < longLevel ? -10 : 0)

shortAcceptanceRawScore =
     50 +
     (not na(entryPrice) and close < entryPrice ? 15 : -20) +
     (low < low[1] ? 10 : -10) +
     (high < high[1] ? 10 : -10) +
     (not na(entryPrice) and shortTp1ApproachDistance > 0 and low <= entryPrice - shortTp1ApproachDistance ? 15 : 0) +
     (tp1Hit ? 20 : 0) +
     (multipleSmallBodies ? -10 : 0) +
     (close > shortLevel ? -10 : 0)

acceptanceScoreNow =
     tradeSide == "LONG" ? longAcceptanceRawScore :
     tradeSide == "SHORT" ? shortAcceptanceRawScore :
     na

if acceptanceWindowActive and not na(acceptanceScoreNow)
    acceptanceScore := math.min(100.0, math.max(0.0, acceptanceScoreNow))
    acceptanceEndBar := bar_index



// plotshape(
 //    tp2DoneMarker,
 //    title="TP2 DONE",
 //    location=location.abovebar,
 //    style=shape.labelup,
 //    size=size.normal,
 //    color=color.green,
 //    text="TP2\nDONE")

// =====================================================
// VALIDITY ENGINE
// =====================================================

longWeak =
     tradeExecutionActive and tradeSide == "LONG" and
     close < longEntry and close > longSL

shortWeak =
     tradeExecutionActive and tradeSide == "SHORT" and
     close > shortEntry and close < shortSL

longInvalid =
     tradeExecutionActive and tradeSide == "LONG" and close < longSL

shortInvalid =
     tradeExecutionActive and tradeSide == "SHORT" and close > shortSL

tradeInvalid =
     longInvalid or shortInvalid

tradeWeak =
     not tradeInvalid and (longWeak or shortWeak)

validityText =
     tradeInvalid ? "Invalide" :
     tradeWeak ? "Schwächelnd" :
     tradeExecutionActive ? "Valide" :
     "-"

validityColor =
     tradeInvalid ? color.red :
     tradeWeak ? color.orange :
     tradeExecutionActive ? color.green :
     color.gray

// =====================================================
// TRADE SCORE ENGINE v3
// =====================================================

float tradeScore = na

if setupState == STATE_CONFIRMED or setupState == STATE_ACTIVE or setupState == STATE_FINISHED
    tradeScore := 95

    // Bonus für saubere Entwicklung
    if tp1Hit
        tradeScore := 100

    if tp2Hit
        tradeScore := 100

    // Harte Bestrafung bei SL
    if slHit
        tradeScore := 0

    // Aktiver Long wird schwächer
    if tradeExecutionActive and tradeSide == "LONG"
        if close < longEntry
            tradeScore := math.min(tradeScore, 80)
        if close < longLevel
            tradeScore := math.min(tradeScore, 65)
        if close <= longSL
            tradeScore := 0

    // Aktiver Short wird schwächer
    if tradeExecutionActive and tradeSide == "SHORT"
        if close > shortEntry
            tradeScore := math.min(tradeScore, 80)
        if close > shortLevel
            tradeScore := math.min(tradeScore, 65)
        if close >= shortSL
            tradeScore := 0

    // Nach abgeschlossenem Trade
    if tp2Hit
        tradeScore := 100

    if slHit
        tradeScore := 0

tradeScoreText =
     na(tradeScore) ? "-" :
     str.tostring(math.round(tradeScore))

tradeScoreColor =
     na(tradeScore) ? color.gray :
     tradeScore >= 90 ? color.green :
     tradeScore >= 75 ? color.new(color.green, 20) :
     tradeScore >= 60 ? color.yellow :
     tradeScore >= 40 ? color.orange :
     color.red

// =====================================================
// MARKUS A / MARKUS B ENGINE v2
// =====================================================

float markusA = na
float markusB = na

if not na(tradeScore)
    markusA := tradeScore
    markusB := 100 - tradeScore

markusAText =
     na(markusA) ? "-" :
     str.tostring(math.round(markusA))

markusBText =
     na(markusB) ? "-" :
     str.tostring(math.round(markusB))

markusState =
     na(markusA) ? "-" :
     markusA >= 90 ? "GEHIRNCHIRURG" :
     markusA >= 75 ? "DISCIPLINED" :
     markusA >= 60 ? "ACHTUNG" :
     markusA >= 40 ? "MARKUS B KOMMT" :
     "MARKUS B CONTROL"

markusColor =
     na(markusA) ? color.gray :
     markusA >= 90 ? color.green :
     markusA >= 75 ? color.new(color.green, 20) :
     markusA >= 60 ? color.yellow :
     markusA >= 40 ? color.orange :
     color.red


// =====================================================
// B WATCHLIST ENGINE
// =====================================================
bLevelsActive = not aPlusInReach and not tradeExecutionActive

bLongBreakout =
     isTracking and time >= activeConfigStart and bLevelsActive and bLongSetupAllowed and close > bLongLevel and close[1] <= bLongLevel

bShortBreakout =
     isTracking and time >= activeConfigStart and bLevelsActive and bShortSetupAllowed and close < bShortLevel and close[1] >= bShortLevel

// =====================================================
// STATUS ENGINE
// =====================================================
entryText = timeToText(entryTime)
entryTouchedText = timeToText(entryTouchedTime)
entryConfirmedText = timeToText(entryConfirmedTime)
tp1Text = timeToText(tp1Time)
tp2Text = timeToText(tp2Time)
slText = timeToText(slTime)
exitText = timeToText(exitTime)
exitReasonText = exitReason == "" ? "-" : exitReason
exitTriggerText = exitTrigger == "" ? "-" : exitTrigger
configPasteAppliedText = activeAssetConfigProvided and not na(configPasteAppliedTime) ? timeToText(configPasteAppliedTime) : "-"
configStatusDisplayText =
     configStatusText == "Eingefügt" ? "Eingefügt (" + configPasteAppliedText + ")" :
     configStatusText == "KEINE CONFIG" ? "Keine Config" :
     configStatusText

entryConfirmedDisplay =
     setupState == STATE_ACTIVE and
     not na(entryConfirmedBar) and
     entryConfirmedBar == bar_index

setupStateText =
     setupState == STATE_WAITING ? "WARTEN" :
     setupState == STATE_ARMED ? "SETUP AKTIV" :
     setupState == STATE_TOUCHED ? "CONFIRMATION LÄUFT" :
     setupState == STATE_CONFIRMED ? "ENTRY BESTÄTIGT" :
     entryConfirmedDisplay ? "ENTRY BESTÄTIGT" :
     setupState == STATE_ACTIVE ? "TRADE AKTIV" :
     setupState == STATE_FINISHED ? "TRADE BEENDET" :
     setupState == STATE_CONSUMED ? "SETUP INVALIDIERT" :
     "WARTEN"

statusDetail =
     setupState == STATE_ARMED and tradeSide != "" ? " | " + tradeSide :
     setupState == STATE_TOUCHED ? " | " + tradeSide + " (" + entryTouchedText + ")" :
     setupState == STATE_CONFIRMED and paperEntryPending ? " | " + tradeSide + " | ENTRY WARTET" :
     setupState == STATE_CONFIRMED ? " | " + tradeSide + " (" + entryConfirmedText + ")" :
     entryConfirmedDisplay ? " | " + tradeSide + " (" + entryConfirmedText + ")" :
     setupState == STATE_ACTIVE and tp1Hit ? " | " + tradeSide + " | TP1 HIT (" + tp1Text + ")" :
     setupState == STATE_ACTIVE ? " | " + tradeSide + " (" + entryText + ")" :
     setupState == STATE_FINISHED and tradeOutcome == "HEALTH_EXIT" ? " | HEALTH EXIT (" + exitText + ")" :
     setupState == STATE_FINISHED and tp2Hit ? " | TP2 HIT (" + tp2Text + ")" :
     setupState == STATE_FINISHED and tradeOutcome == "BE" ? " | BE HIT (" + exitText + ")" :
     setupState == STATE_FINISHED and slHit ? " | SL HIT (" + slText + ")" :
     ""

aPlusStatus = setupStateText + statusDetail

explainPreviewText =
     setupState == STATE_WAITING ? "-" :
     setupState == STATE_ARMED and tradeSide == "LONG" ? "A+ Long Setup aktiv\nwartet auf Entry-Zone" :
     setupState == STATE_ARMED and tradeSide == "SHORT" ? "A+ Short Setup aktiv\nwartet auf Entry-Zone" :
     setupState == STATE_TOUCHED and tradeSide == "LONG" ? "Touch A+ Long erkannt\nwartet auf Confirmation" :
     setupState == STATE_TOUCHED and tradeSide == "SHORT" ? "Touch A+ Short erkannt\nwartet auf Confirmation" :
     setupState == STATE_CONFIRMED and paperEntryPending ? "Entry bestätigt\nPaper Entry wartet\nwartet auf Fill" :
     setupState == STATE_CONFIRMED ? "Entry bestätigt\nTrade wird aktiviert" :
     entryConfirmedDisplay ? "Entry bestätigt\nTrade wird aktiviert" :
     setupState == STATE_ACTIVE and tp1Hit ? "Trade aktiv\nTP1 erreicht, Rest läuft" :
     setupState == STATE_ACTIVE ? "Trade aktiv\nwartet auf TP1 / TP2 / SL" :
     setupState == STATE_FINISHED and tradeOutcome == "HEALTH_EXIT" ? "Hart raus\nTrade Health" :
     setupState == STATE_FINISHED and tp2Hit ? "Tagesplan erfüllt\nTP2 erreicht" :
     setupState == STATE_FINISHED and tradeOutcome == "BE" ? "BE HIT\nTrade beendet" :
     setupState == STATE_FINISHED and slHit ? "SL HIT\nFinger weg" :
     setupState == STATE_CONSUMED and setupUsedReason != "" ? setupUsedReason + "\nSetup schützt vor Hinterherlaufen" :
     setupState == STATE_CONSUMED ? "Setup invalidiert\nFinger weg" :
     "-"

setupQualityText =
     setupQuality == QUALITY_A_PLUS ? "A+" :
     setupQuality == QUALITY_B ? "B" :
     "-"

confirmationDisplayStatus =
     confirmationDetected and not barstate.isconfirmed ? "CONFIRMATION ERKANNT\nWARTET AUF KERZENSCHLUSS" :
     setupState == STATE_TOUCHED ? "WARTET AUF BESTÄTIGUNG" :
     confirmationStatusText != "" ? confirmationStatusText :
     "-"

confirmationScoreRawText = str.tostring(confirmationScore)
confirmationScoreText = confirmationScoreRawText + " / " + str.tostring(confirmationMinScore)
confirmationMinScoreText = str.tostring(confirmationMinScore)

entryProfileText =
     CONFIRMATION_MODE == "AGGRESSIVE" ? "AGGRESSIVE" :
     CONFIRMATION_MODE == "CONSERVATIVE" ? "SELECTIVE" :
     "BALANCED"

confirmationRuntimeModeText =
     extremeVolatilePhase ? "SURGE" :
     volatilePhase or hadSlToday ? "STRICT" :
     "NORMAL"

setupDecisionVisible =
     setupState == STATE_ARMED or
     setupState == STATE_TOUCHED or
     setupState == STATE_CONFIRMED

entryThresholdText =
     setupDecisionVisible ? str.tostring(confirmationMinScore) :
     "-"

entryTradeScoreText =
     setupDecisionVisible ? confirmationScoreRawText :
     "-"

cockpitConfirmationScoreText =
     setupDecisionVisible ? confirmationScoreText :
     "-"

entryReleased =
     setupDecisionVisible and confirmationScore >= confirmationMinScore

entryReleaseText =
     setupDecisionVisible ? (entryReleased ? "ENTRY FREIGEGEBEN" : "WARTET AUF BESTÄTIGUNG") :
     "-"

entryTradeScoreColor =
     not setupDecisionVisible ? color.gray :
     confirmationScore >= confirmationMinScore ? color.green :
     confirmationScore >= confirmationMinScore - 5 ? color.yellow :
     color.red

entryReleaseColor =
     not setupDecisionVisible ? color.gray :
     entryReleased ? color.green :
     color.red

acceptanceStateText =
     na(acceptanceScore) ? "-" :
     acceptanceScore >= 80 ? "🟢 Stark (" + str.tostring(math.round(acceptanceScore)) + ")" :
     acceptanceScore >= 60 ? "🟡 Neutral (" + str.tostring(math.round(acceptanceScore)) + ")" :
     "🔴 Schwach (" + str.tostring(math.round(acceptanceScore)) + ")"

acceptanceBarsText =
     acceptanceBarsObserved > 0 ? str.tostring(acceptanceBarsObserved) + "/" + str.tostring(acceptanceCandles) + " Kerzen" :
     "-"

acceptanceColor =
     na(acceptanceScore) ? color.black :
     acceptanceScore >= 80 ? color.green :
     acceptanceScore >= 60 ? color.orange :
     color.red

paperTrackingVisible =
     MODE == "BACKTEST" and (paperEntryPending or tradeActive or setupState == STATE_ACTIVE or setupState == STATE_FINISHED)

paperQtyText =
     paperTrackingVisible and not na(tradeQty) ? str.tostring(math.round(tradeQty)) :
     "-"

paperMfeText =
     paperTrackingVisible and not na(mfe) ? str.tostring(math.round(mfe)) :
     "-"

paperMaeText =
     paperTrackingVisible and not na(mae) ? str.tostring(math.round(mae)) :
     "-"

paperBeText =
     paperTrackingVisible ? (beActive ? "JA" : "NEIN") :
     "-"

paperOutcomeText =
     paperTrackingVisible and tradeOutcome != "" ? tradeOutcome :
     "-"

displayHealthScore =
     healthActive ? tradeHealthScore :
     setupState == STATE_FINISHED ? frozenHealthScore :
     na

displayHealthStatus =
     healthRunnerAfterTP1 ? "RUNNER" :
     healthActive ? healthStatusAdjusted :
     setupState == STATE_FINISHED ? frozenHealthStatus :
     "-"

displayHealthRecommendation =
     healthActive ? healthRecommendation :
     setupState == STATE_FINISHED ? frozenHealthRecommendation :
     "Halten"

displayHealthReason =
     healthRunnerAfterTP1 ? "TP1 erreicht, Rest läuft klassisch bis TP2 oder BE" :
     healthActive ? healthReason :
     setupState == STATE_FINISHED ? frozenHealthReason :
     "-"

tradeHealthScoreText =
     not na(displayHealthScore) ? str.tostring(math.round(displayHealthScore)) :
     "-"

tradeHealthColor =
     na(displayHealthScore) ? color.gray :
     displayHealthScore >= 75 ? color.green :
     displayHealthScore >= 55 ? color.new(color.green, 20) :
     displayHealthScore >= 35 ? color.orange :
     displayHealthScore >= 25 ? color.red :
     color.maroon

tp1ProgressText =
     healthActive ? str.tostring(math.round(tp1ProgressPercent)) + "%" :
     "-"

riskUsedText =
     healthActive ? str.tostring(math.round(riskUsedPercent)) + "%" :
     "-"

expectedProgressText =
     healthActive ? str.tostring(math.round(expectedProgressPercent)) + "%" :
     "-"

mfeMaeRatioText =
     healthActive and not na(mfeMaeRatio) ? str.tostring(math.round(mfeMaeRatio * 100.0) / 100.0) :
     "-"

minutesSinceBestMFEText =
     healthActive ? str.tostring(minutesSinceBestMFE) + " Min" :
     "-"

healthPhaseDisplayText =
     healthActive ? tradeHealthPhase :
     setupState == STATE_FINISHED ? "CLOSED" :
     "-"

healthMfeMaeText =
     healthActive or setupState == STATE_FINISHED ? "MFE " + paperMfeText + " | MAE " + paperMaeText :
     "-"

paperActionDisplayText =
     paperEntryPending ? "Paper Entry wartet" :
     paperActionText != "-" ? paperActionText :
     TRADE_HEALTH_MODE == "OFF" ? "-" :
     healthActive and MODE == "BACKTEST" and TRADE_HEALTH_MODE == "ANALYSE" ? "Beobachten" :
     healthActive and MODE == "BACKTEST" and TRADE_HEALTH_MODE == "AUTO PAPER" ? "Keine Aktion" :
     healthActive ? "Live: manuell entscheiden" :
     "-"

originalOutcomeText =
     originalOutcome == "" ? "-" :
     originalOutcome

healthManagedOutcomeText =
     healthManagedOutcome == "" ? "-" :
     healthManagedOutcome

cockpitSetupPhase =
     setupState == STATE_WAITING or
     setupState == STATE_ARMED or
     setupState == STATE_TOUCHED or
     setupState == STATE_CONFIRMED

cockpitTradePhase =
     setupState == STATE_ACTIVE

cockpitReviewPhase =
     setupState == STATE_FINISHED or
     setupState == STATE_CONSUMED

tradeAgeEndTime =
     setupState == STATE_FINISHED and not na(exitTime) ? exitTime :
     time

tradeAgeMinutes =
     not na(entryTime) ? math.round((tradeAgeEndTime - entryTime) / 60000) :
     na

tradeAgeText =
     not na(tradeAgeMinutes) ? str.tostring(tradeAgeMinutes) + " Minuten" :
     "-"

activeTradeManagementText =
     tp2Hit ? "TP2 erreicht" :
     slHit ? "SL erreicht" :
     tp1Hit ? "TP1 erreicht | Restposition läuft" :
     "Wartet auf TP1 / TP2 / SL"

newEntryLockText =
     cockpitTradePhase ? "NICHT MÖGLICH | Trade läuft bereits" :
     cockpitReviewPhase ? "NICHT MÖGLICH | Trade abgeschlossen" :
     "-"

reviewOutcomeText =
     setupState == STATE_CONSUMED ? "SETUP INVALIDIERT" :
     tradeOutcome == "HEALTH_EXIT" ? "Hart raus" :
     tradeOutcome != "" ? tradeOutcome :
     exitReason != "" ? exitReason :
     tp2Hit ? "TP2" :
     slHit ? "SL" :
     "-"

reviewReasonText =
     setupState == STATE_CONSUMED and setupUsedReason != "" ? setupUsedReason :
     exitReasonText

// =====================================================
// VISUAL ENGINE — LEVELS
// =====================================================
plot(showLightVisuals and longLevel > 0 ? longLevel : na, color=color.green, linewidth=2, title="A+ LONG Level")
plot(showLightVisuals and shortLevel > 0 ? shortLevel : na, color=color.red, linewidth=2, title="A+ SHORT Level")

plot(showLightVisuals and bLevelsActive and bLongLevel > 0 ? bLongLevel : na, color=color.new(color.blue, 45), linewidth=1, style=plot.style_circles, title="B-LONG Alarm")
plot(showLightVisuals and bLevelsActive and bShortLevel > 0 ? bShortLevel : na, color=color.new(color.blue, 45), linewidth=1, style=plot.style_circles, title="B-SHORT Alarm")

plot(showLightVisuals and liquidityLong > 0 ? liquidityLong : na, color=color.blue, linewidth=1, style=plot.style_circles, title="Buy Side Liquidity")
plot(showLightVisuals and liquidityShort > 0 ? liquidityShort : na, color=color.orange, linewidth=1, style=plot.style_circles, title="Sell Side Liquidity")

// =====================================================
// TRADE PLAN BOX
// =====================================================
tradePlanWidth = 80

var box profitBox = na
var box riskBox = na
var label entryLabel = na
var label slLabel = na
var label tp1Label = na
var label tp2Label = na

showLongPlan =
     drawTradePlan and
     not RESET_TRADE and
     longSetupAllowed and
     setupState != STATE_CONSUMED and
     setupState != STATE_FINISHED and
     (
         tradeSide == "LONG" or
         (configTracking and tradeSide == "" and not shortSetupAllowed)
     )

showShortPlan =
     drawTradePlan and
     not RESET_TRADE and
     shortSetupAllowed and
     setupState != STATE_CONSUMED and
     setupState != STATE_FINISHED and
     (
         tradeSide == "SHORT" or
         (configTracking and tradeSide == "" and not longSetupAllowed)
     )

deleteTradePlan =
     not drawTradePlan or
     configChanged or
     RESET_TRADE or
     setupState == STATE_FINISHED or
     setupState == STATE_CONSUMED or
     (not showLongPlan and not showShortPlan)

if deleteTradePlan
    if not na(profitBox)
        box.delete(profitBox)
        profitBox := na
    if not na(riskBox)
        box.delete(riskBox)
        riskBox := na
    if not na(entryLabel)
        label.delete(entryLabel)
        entryLabel := na
    if not na(slLabel)
        label.delete(slLabel)
        slLabel := na
    if not na(tp1Label)
        label.delete(tp1Label)
        tp1Label := na
    if not na(tp2Label)
        label.delete(tp2Label)
        tp2Label := na

if showLongPlan
    visualUpdateCount := visualUpdateCount + 1
    if na(profitBox)
        profitBox := box.new(bar_index, longTP2, bar_index + tradePlanWidth, longEntry, bgcolor=color.new(color.green, 88), border_color=color.new(color.green, 40))
    else
        box.set_left(profitBox, bar_index)
        box.set_right(profitBox, bar_index + tradePlanWidth)
        box.set_top(profitBox, longTP2)
        box.set_bottom(profitBox, longEntry)
        box.set_bgcolor(profitBox, color.new(color.green, 88))
        box.set_border_color(profitBox, color.new(color.green, 40))

    if na(riskBox)
        riskBox := box.new(bar_index, longEntry, bar_index + tradePlanWidth, longSL, bgcolor=color.new(color.red, 88), border_color=color.new(color.red, 40))
    else
        box.set_left(riskBox, bar_index)
        box.set_right(riskBox, bar_index + tradePlanWidth)
        box.set_top(riskBox, longEntry)
        box.set_bottom(riskBox, longSL)
        box.set_bgcolor(riskBox, color.new(color.red, 88))
        box.set_border_color(riskBox, color.new(color.red, 40))

    if na(entryLabel)
        entryLabel := label.new(bar_index + tradePlanWidth, longEntry, "ENTRY " + str.tostring(longEntry), style=label.style_label_left, color=color.green, textcolor=color.white)
    else
        label.set_x(entryLabel, bar_index + tradePlanWidth)
        label.set_y(entryLabel, longEntry)
        label.set_text(entryLabel, "ENTRY " + str.tostring(longEntry))
        label.set_color(entryLabel, color.green)
        label.set_textcolor(entryLabel, color.white)

    if na(slLabel)
        slLabel := label.new(bar_index + tradePlanWidth, longSL, "SL " + str.tostring(longSL), style=label.style_label_left, color=color.red, textcolor=color.white)
    else
        label.set_x(slLabel, bar_index + tradePlanWidth)
        label.set_y(slLabel, longSL)
        label.set_text(slLabel, "SL " + str.tostring(longSL))
        label.set_color(slLabel, color.red)
        label.set_textcolor(slLabel, color.white)

    if na(tp1Label)
        tp1Label := label.new(bar_index + tradePlanWidth, longTP1, "TP1 " + str.tostring(longTP1), style=label.style_label_left, color=color.blue, textcolor=color.white)
    else
        label.set_x(tp1Label, bar_index + tradePlanWidth)
        label.set_y(tp1Label, longTP1)
        label.set_text(tp1Label, "TP1 " + str.tostring(longTP1))
        label.set_color(tp1Label, color.blue)
        label.set_textcolor(tp1Label, color.white)

    if na(tp2Label)
        tp2Label := label.new(bar_index + tradePlanWidth, longTP2, "TP2 " + str.tostring(longTP2), style=label.style_label_left, color=color.blue, textcolor=color.white)
    else
        label.set_x(tp2Label, bar_index + tradePlanWidth)
        label.set_y(tp2Label, longTP2)
        label.set_text(tp2Label, "TP2 " + str.tostring(longTP2))
        label.set_color(tp2Label, color.blue)
        label.set_textcolor(tp2Label, color.white)

if showShortPlan
    visualUpdateCount := visualUpdateCount + 1
    if na(profitBox)
        profitBox := box.new(bar_index, shortEntry, bar_index + tradePlanWidth, shortTP2, bgcolor=color.new(color.green, 88), border_color=color.new(color.green, 40))
    else
        box.set_left(profitBox, bar_index)
        box.set_right(profitBox, bar_index + tradePlanWidth)
        box.set_top(profitBox, shortEntry)
        box.set_bottom(profitBox, shortTP2)
        box.set_bgcolor(profitBox, color.new(color.green, 88))
        box.set_border_color(profitBox, color.new(color.green, 40))

    if na(riskBox)
        riskBox := box.new(bar_index, shortSL, bar_index + tradePlanWidth, shortEntry, bgcolor=color.new(color.red, 88), border_color=color.new(color.red, 40))
    else
        box.set_left(riskBox, bar_index)
        box.set_right(riskBox, bar_index + tradePlanWidth)
        box.set_top(riskBox, shortSL)
        box.set_bottom(riskBox, shortEntry)
        box.set_bgcolor(riskBox, color.new(color.red, 88))
        box.set_border_color(riskBox, color.new(color.red, 40))

    if na(entryLabel)
        entryLabel := label.new(bar_index + tradePlanWidth, shortEntry, "ENTRY " + str.tostring(shortEntry), style=label.style_label_left, color=color.red, textcolor=color.white)
    else
        label.set_x(entryLabel, bar_index + tradePlanWidth)
        label.set_y(entryLabel, shortEntry)
        label.set_text(entryLabel, "ENTRY " + str.tostring(shortEntry))
        label.set_color(entryLabel, color.red)
        label.set_textcolor(entryLabel, color.white)

    if na(slLabel)
        slLabel := label.new(bar_index + tradePlanWidth, shortSL, "SL " + str.tostring(shortSL), style=label.style_label_left, color=color.green, textcolor=color.white)
    else
        label.set_x(slLabel, bar_index + tradePlanWidth)
        label.set_y(slLabel, shortSL)
        label.set_text(slLabel, "SL " + str.tostring(shortSL))
        label.set_color(slLabel, color.green)
        label.set_textcolor(slLabel, color.white)

    if na(tp1Label)
        tp1Label := label.new(bar_index + tradePlanWidth, shortTP1, "TP1 " + str.tostring(shortTP1), style=label.style_label_left, color=color.blue, textcolor=color.white)
    else
        label.set_x(tp1Label, bar_index + tradePlanWidth)
        label.set_y(tp1Label, shortTP1)
        label.set_text(tp1Label, "TP1 " + str.tostring(shortTP1))
        label.set_color(tp1Label, color.blue)
        label.set_textcolor(tp1Label, color.white)

    if na(tp2Label)
        tp2Label := label.new(bar_index + tradePlanWidth, shortTP2, "TP2 " + str.tostring(shortTP2), style=label.style_label_left, color=color.blue, textcolor=color.white)
    else
        label.set_x(tp2Label, bar_index + tradePlanWidth)
        label.set_y(tp2Label, shortTP2)
        label.set_text(tp2Label, "TP2 " + str.tostring(shortTP2))
        label.set_color(tp2Label, color.blue)
        label.set_textcolor(tp2Label, color.white)

// =====================================================
// SETUP LABELS
// =====================================================
var label longSetupLabel = na
var label shortSetupLabel = na

showLongSetupLabel =
     drawSetupLabels and
     longLevel > 0 and
     (showLongPlan or not showShortPlan)

showShortSetupLabel =
     drawSetupLabels and
     shortLevel > 0 and
     (showShortPlan or not showLongPlan)

if not showLongSetupLabel and not na(longSetupLabel)
    label.delete(longSetupLabel)
    longSetupLabel := na

if not showShortSetupLabel and not na(shortSetupLabel)
    label.delete(shortSetupLabel)
    shortSetupLabel := na

if showLongSetupLabel
    visualUpdateCount := visualUpdateCount + 1
    longSetupText = "🚀 A+ 95 | LONG " + str.tostring(longLevel)
    if na(longSetupLabel)
        longSetupLabel := label.new(bar_index + 3, longLevel, longSetupText, style=label.style_label_left, color=color.green, textcolor=color.white)
    else
        label.set_x(longSetupLabel, bar_index + 3)
        label.set_y(longSetupLabel, longLevel)
        label.set_text(longSetupLabel, longSetupText)
        label.set_color(longSetupLabel, color.green)
        label.set_textcolor(longSetupLabel, color.white)

if showShortSetupLabel
    visualUpdateCount := visualUpdateCount + 1
    shortSetupText = "🔻 A+ 95 | SHORT " + str.tostring(shortLevel)
    if na(shortSetupLabel)
        shortSetupLabel := label.new(bar_index + 3, shortLevel, shortSetupText, style=label.style_label_left, color=color.red, textcolor=color.white)
    else
        label.set_x(shortSetupLabel, bar_index + 3)
        label.set_y(shortSetupLabel, shortLevel)
        label.set_text(shortSetupLabel, shortSetupText)
        label.set_color(shortSetupLabel, color.red)
        label.set_textcolor(shortSetupLabel, color.white)

// =====================================================
// NO TRADE ZONE
// =====================================================
noTradeWidth = 150

var box noTradeBox = na
var label noTradeLabel = na

if (not drawNoTradeZone or noTradeHigh <= 0 or noTradeLow <= 0) and not na(noTradeBox)
    box.delete(noTradeBox)
    noTradeBox := na

if (not drawNoTradeZone or noTradeHigh <= 0 or noTradeLow <= 0) and not na(noTradeLabel)
    label.delete(noTradeLabel)
    noTradeLabel := na

noTradeMiddle = (noTradeHigh + noTradeLow) / 2

if drawNoTradeZone and noTradeHigh > 0 and noTradeLow > 0
    visualUpdateCount := visualUpdateCount + 1
    if na(noTradeBox)
        noTradeBox := box.new(bar_index, noTradeHigh, bar_index + noTradeWidth, noTradeLow, bgcolor=color.new(color.orange, 92), border_color=color.orange)
    else
        box.set_left(noTradeBox, bar_index)
        box.set_right(noTradeBox, bar_index + noTradeWidth)
        box.set_top(noTradeBox, noTradeHigh)
        box.set_bottom(noTradeBox, noTradeLow)
        box.set_bgcolor(noTradeBox, color.new(color.orange, 92))
        box.set_border_color(noTradeBox, color.orange)
    if na(noTradeLabel)
        noTradeLabel := label.new(bar_index + int(noTradeWidth / 2), noTradeMiddle, "⛔ NO TRADE ZONE", style=label.style_none, textcolor=color.orange, size=size.normal)
    else
        label.set_x(noTradeLabel, bar_index + int(noTradeWidth / 2))
        label.set_y(noTradeLabel, noTradeMiddle)
        label.set_text(noTradeLabel, "⛔ NO TRADE ZONE")
        label.set_textcolor(noTradeLabel, color.orange)

// =====================================================
// EVENT MARKERS
// =====================================================

showLongEntryMarker =
     ((not paperTradingEnabled and longEntryTriggered) or longPaperEntryFilledNow) and time >= sessionStart

showShortEntryMarker =
     ((not paperTradingEnabled and shortEntryTriggered) or shortPaperEntryFilledNow) and time >= sessionStart

firstLongTouch =
     longEntryTouchedNow and not touchMarkerDrawn

firstShortTouch =
     shortEntryTouchedNow and not touchMarkerDrawn

if firstLongTouch or firstShortTouch
    touchMarkerDrawn := true

plotshape(
     drawEventMarkers and firstLongTouch,
     title="A+ Long Entry Touch",
     location=location.belowbar,
     style=shape.circle,
     size=size.tiny,
     color=color.orange,
     text="T")

plotshape(
     drawEventMarkers and firstShortTouch,
     title="A+ Short Entry Touch",
     location=location.abovebar,
     style=shape.circle,
     size=size.tiny,
     color=color.orange,
     text="T")

plotshape(
     drawEventMarkers and showLongEntryMarker and tradeSide == "LONG" and entryTime == time,
     title="A+ Long Entry",
     location=location.belowbar,
     style=shape.triangleup,
     size=size.normal,
     color=color.green,
     text="ENTRY")

plotshape(
     drawEventMarkers and showShortEntryMarker and tradeSide == "SHORT" and entryTime == time,
     title="A+ Short Entry",
     location=location.abovebar,
     style=shape.triangledown,
     size=size.normal,
     color=color.red,
     text="ENTRY")

plotshape(drawEventMarkers and (longTP1HitNow or shortTP1HitNow), title="TP1", location=location.absolute, style=shape.circle, size=size.small, color=color.blue, text="TP1")
plotshape(drawEventMarkers and (longTP2HitNow or shortTP2HitNow), title="TP2", location=location.absolute, style=shape.circle, size=size.small, color=color.green, text="TP2")
plotshape(drawEventMarkers and classicSLHitNow, title="SL", location=location.absolute, style=shape.xcross, size=size.small, color=color.red, text="SL")
plotshape(drawEventMarkers and activeBEHitNow, title="BE", location=location.absolute, style=shape.circle, size=size.small, color=color.gray, text="BE")

// =====================================================
// LAST UPDATE
// =====================================================
minutesSinceUpdate = math.round((timenow - time) / 60000)

updateText =
     str.tostring(dayofmonth(time, DISPLAY_TZ), "00") + "." +
     str.tostring(month(time, DISPLAY_TZ), "00") + "." +
     str.tostring(year(time, DISPLAY_TZ)) + " " +
     str.tostring(hour(time, DISPLAY_TZ), "00") + ":" +
     str.tostring(minute(time, DISPLAY_TZ), "00") +
     " (" + str.tostring(minutesSinceUpdate) + "m)"

activeConfigDateText =
     str.tostring(dayofmonth(activeConfigStart, DISPLAY_TZ), "00") + "." +
     str.tostring(month(activeConfigStart, DISPLAY_TZ), "00") + "." +
     str.tostring(year(activeConfigStart, DISPLAY_TZ))

activeConfigTimeText =
     str.tostring(hour(activeConfigStart, DISPLAY_TZ), "00") + ":" +
     str.tostring(minute(activeConfigStart, DISPLAY_TZ), "00")

autoConfigId =
     activeConfigDateText + " " + activeConfigTimeText

activeConfigId =
     manualConfigId == "AUTO" ? autoConfigId : manualConfigId

backtestInfoText =
     MODE == "BACKTEST" ? activeConfigDateText + " | " + activeConfigTimeText :
     "-"

configStartDebugText =
     "pending " + timeToText(pendingActiveConfigStart) +
     " | active " + timeToText(activeConfigStart) +
     " | auto " + timeToText(autoSessionStart) +
     " | last " + timeToText(last_bar_time)

// =====================================================
// INFO TABLE
// =====================================================
showBacktestRow = MODE == "BACKTEST"
showPaperTrackingRow = MODE == "BACKTEST"
infoTableRows = 32
infoTableOffset = showBacktestRow ? 1 : 0
paperTableOffset = showPaperTrackingRow ? 1 : 0
var table infoTable = table.new(position.top_right, 1, infoTableRows)

statusColor =
     setupState == STATE_WAITING ? color.gray :
     setupState == STATE_ARMED ? color.blue :
     setupState == STATE_TOUCHED ? color.orange :
     setupState == STATE_CONFIRMED ? color.green :
     setupState == STATE_ACTIVE ? color.green :
     setupState == STATE_FINISHED and slHit ? color.red :
     setupState == STATE_FINISHED and tradeOutcome == "BE" ? color.gray :
     setupState == STATE_FINISHED ? color.green :
     setupState == STATE_CONSUMED ? color.orange :
     color.gray

statusIcon =
     setupState == STATE_ARMED ? "🔵 " :
     setupState == STATE_TOUCHED ? "🟡 " :
     setupState == STATE_CONFIRMED ? "✅ " :
     entryConfirmedDisplay ? "✅ " :
     setupState == STATE_ACTIVE and tradeSide == "LONG" ? "🟢 " :
     setupState == STATE_ACTIVE and tradeSide == "SHORT" ? "🟢 " :
     setupState == STATE_FINISHED and tp2Hit ? "🏁 " :
     setupState == STATE_FINISHED and slHit ? "❌ " :
     setupState == STATE_FINISHED and tradeOutcome == "BE" ? "⚪ " :
     setupState == STATE_CONSUMED ? "🟠 " :
     "⚪ "

reasonColor =
     setupState == STATE_CONSUMED ? color.orange :
     setupState == STATE_TOUCHED ? color.new(color.orange, 15) :
     setupState == STATE_ARMED ? color.new(color.blue, 20) :
     color.black

infoTip(tipText) =>
    INFO_TABLE_HOVERTEXT ? tipText : ""

setupConsumedNow = setupState == STATE_CONSUMED and setupState[1] != STATE_CONSUMED
entryZoneStateEnteredNow =
     setupState == STATE_TOUCHED and
     setupState[1] != STATE_TOUCHED and
     entryTouchedBar == bar_index

longEntryZoneAlertNow =
     entryZoneStateEnteredNow and
     tradeSide == "LONG"

shortEntryZoneAlertNow =
     entryZoneStateEnteredNow and
     tradeSide == "SHORT"

stateChanged =
     barstate.isfirst or
     setupState != setupState[1]

importantEvent =
     configChanged or
     RESET_TRADE or
     entryZoneStateEnteredNow or
     longEntryTriggered or
     shortEntryTriggered or
     paperEntryFilledNow or
     longTP1HitNow or
     shortTP1HitNow or
     longTP2HitNow or
     shortTP2HitNow or
     activeSLHitNow or
     setupConsumedNow or
     healthBEActionNow or
     healthHardExitNow

updateInfoTable =
     PERFORMANCE_MODE == "FULL" or
     (PERFORMANCE_MODE == "BACKTEST_FAST" and (barstate.islast or stateChanged or importantEvent)) or
     (PERFORMANCE_MODE == "ENGINE_ONLY" and barstate.islast)

if updateInfoTable
    tableUpdateCount := tableUpdateCount + 1
    table.clear(infoTable, 0, 0, 0, infoTableRows - 1)

if updateInfoTable and isSupportedMarket and isEngineOnly
    engineOnlyText = "MILAMAR TRADING OS v6.11 | " + MARKET + " | " + activeModeText + " | " + setupStateText + (DEBUG_COUNTERS ? " | P " + str.tostring(configParseCount) + " | T " + str.tostring(tableUpdateCount) + " | V " + str.tostring(visualUpdateCount) : "")
    table.cell(infoTable, 0, 0, engineOnlyText, bgcolor=color.black, text_color=color.white, tooltip=infoTip("ENGINE_ONLY zeigt nur eine minimale Statuszeile am letzten Bar."))
    if DEBUG_COUNTERS
        table.cell(infoTable, 0, 1, "Config Start Debug: " + configStartDebugText, bgcolor=color.black, text_color=color.white, tooltip=infoTip("Debug für Replay: active und auto müssen im Backtest innerhalb desselben Chart-Tages stabil bleiben."))

if updateInfoTable and isSupportedMarket and not isEngineOnly
    table.cell(infoTable, 0, 0, "MILAMAR TRADING OS v6.11 | " + MARKET, bgcolor=color.black, text_color=color.white, tooltip=infoTip("Welche Version gerade läuft und welches Symbol erkannt wurde."))
    table.cell(infoTable, 0, 1, "Modus: " + activeModeText, bgcolor=color.black, text_color=color.white, tooltip=infoTip("LIVE ist für den echten Handelstag. BACKTEST ist für Replay und historische Tage. Die Handelslogik bleibt gleich."))
    table.cell(infoTable, 0, 2, "Alerts: " + ALERT_MODE, bgcolor=color.black, text_color=color.white, tooltip=infoTip("Steuert den einen TradingView-Master-Alert. LIVE sendet nur im Live-Modus, BACKTEST nur im Backtest-Modus, AUS sendet nichts."))
    if showBacktestRow
        table.cell(infoTable, 0, 3, "Backtest: " + backtestInfoText, bgcolor=color.black, text_color=color.white, tooltip=infoTip("Im Backtest steht hier der Tag und die Uhrzeit, ab der diese Config bewertet wird."))
    table.cell(infoTable, 0, 3 + infoTableOffset, "Start 08:00 Madrid: " + activeConfigDateText + " | " + activeConfigTimeText + " | " + (configTimeActivated ? "aktiv" : "wartet"), bgcolor=color.black, text_color=color.white, tooltip=infoTip("Ab diesem Zeitpunkt schaut das System auf Setups. Bei eingefügter Config startet es erst ab dem Einfügezeitpunkt."))
    table.cell(infoTable, 0, 4 + infoTableOffset, "Config Status: " + configStatusDisplayText, bgcolor=configStatusColor, text_color=color.white, tooltip=infoTip("Zeigt, ob die Config sauber geladen wurde. Wenn hier rot steht, fehlen wichtige Werte und es wird kein Setup gestartet."))
    table.cell(infoTable, 0, 5 + infoTableOffset, "Tagestyp: " + dayType, bgcolor=color.gray, text_color=color.white, tooltip=infoTip("Kurze Beschreibung des Markttages aus der Config, zum Beispiel Trendtag oder Reversal-Tag."))
    table.cell(infoTable, 0, 6 + infoTableOffset, "Status: " + statusIcon + aPlusStatus, bgcolor=statusColor, text_color=color.white, tooltip=infoTip("Der wichtigste Blick: Hier steht, ob wir warten, das Setup nur beobachtet wird, die Confirmation läuft oder ein Trade aktiv ist."))
    table.cell(infoTable, 0, 7 + infoTableOffset, "Grund: " + explainPreviewText, bgcolor=reasonColor, text_color=color.white, tooltip=infoTip("Hier erklärt das Trading OS kurz, warum noch kein Entry da ist oder warum ein Trade läuft. Später wird diese Zeile zur Explain Engine mit einzelnen Haken und Warnungen."))

    if cockpitSetupPhase
        table.cell(infoTable, 0, 8 + infoTableOffset, "Setup: " + setupQualityText + " | " + (tradeSide == "" ? "-" : tradeSide), bgcolor=color.black, text_color=color.white, tooltip=infoTip("Setup-Phase: Hier zählen Qualität, Richtung und ob der Markt die Entry-Zone erreicht."))
        table.cell(infoTable, 0, 9 + infoTableOffset, "Entry Profile: " + entryProfileText, bgcolor=color.black, text_color=color.white, tooltip=infoTip("Das ist dein eingestelltes Einstiegsprofil. AGGRESSIVE erlaubt früher, BALANCED ist normal, SELECTIVE wartet auf klarere Bestätigung."))
        table.cell(infoTable, 0, 10 + infoTableOffset, "Confirmation Mode: " + confirmationRuntimeModeText + " | " + confirmationDisplayStatus, bgcolor=color.black, text_color=color.white, tooltip=infoTip("Vor dem Entry zeigt diese Zeile, ob die Bestätigung läuft, erkannt wurde oder noch fehlt."))
        table.cell(infoTable, 0, 11 + infoTableOffset, "Confirmation Score: " + cockpitConfirmationScoreText, bgcolor=entryTradeScoreColor, text_color=color.white, tooltip=infoTip("Links steht der aktuelle Score, rechts der benötigte Entry Threshold."))
        table.cell(infoTable, 0, 12 + infoTableOffset, "Entry Threshold: " + entryThresholdText, bgcolor=color.black, text_color=color.white, tooltip=infoTip("Das ist die Punktzahl, die der Entry mindestens erreichen muss."))
        table.cell(infoTable, 0, 13 + infoTableOffset, "Freigabe: " + entryReleaseText, bgcolor=entryReleaseColor, text_color=color.white, tooltip=infoTip("Vor dem Trade zeigt diese Zeile, ob der Entry freigegeben ist oder noch Bestätigung fehlt."))
        table.cell(infoTable, 0, 14 + infoTableOffset, "Akzeptanz: - | -", bgcolor=color.black, text_color=color.white, tooltip=infoTip("Akzeptanz startet erst nach bestätigtem Entry. Vorher bleibt diese Zeile bewusst leer."))
        table.cell(infoTable, 0, 15 + infoTableOffset, "Einstieg: " + (tradeSide == "SHORT" ? str.tostring(shortEntry) : tradeSide == "LONG" ? str.tostring(longEntry) : "-") + " | TP1: " + (tradeSide == "SHORT" ? str.tostring(shortTP1) : tradeSide == "LONG" ? str.tostring(longTP1) : "-") + " | TP2: " + (tradeSide == "SHORT" ? str.tostring(shortTP2) : tradeSide == "LONG" ? str.tostring(longTP2) : "-") + " | SL: " + (tradeSide == "SHORT" ? str.tostring(shortSL) : tradeSide == "LONG" ? str.tostring(longSL) : "-"), bgcolor=color.black, text_color=color.white, tooltip=infoTip("Der konkrete Trade-Plan aus der aktiven Config."))
        table.cell(infoTable, 0, 16 + infoTableOffset, "Trigger: " + (entryTouchedText == "-" ? "-" : "Entry-Zone " + entryTouchedText), bgcolor=color.black, text_color=color.white, tooltip=infoTip("Zeigt, ob und wann die Entry-Zone berührt wurde."))

    if cockpitTradePhase
        table.cell(infoTable, 0, 8 + infoTableOffset, "Laufzeit: " + tradeAgeText, bgcolor=color.green, text_color=color.white, tooltip=infoTip("Die Laufzeit startet erst, wenn der Entry wirklich gefüllt wurde. Confirmation allein zählt noch nicht als Trade."))
        table.cell(infoTable, 0, 9 + infoTableOffset, "Trade: " + tradeSide + " | Qualität: " + setupQualityText, bgcolor=color.black, text_color=color.white, tooltip=infoTip("Aktiver Trade: Confirmation ist abgeschlossen, jetzt zählt Trade Management."))
        table.cell(infoTable, 0, 10 + infoTableOffset, "Entry: " + str.tostring(entryPrice) + " | TP1: " + (tradeSide == "SHORT" ? str.tostring(shortTP1) : str.tostring(longTP1)), bgcolor=color.black, text_color=color.white, tooltip=infoTip("Entry und erstes Ziel des laufenden Trades."))
        table.cell(infoTable, 0, 11 + infoTableOffset, "TP2: " + (tradeSide == "SHORT" ? str.tostring(shortTP2) : str.tostring(longTP2)) + " | SL: " + (not na(activePaperSL) ? str.tostring(activePaperSL) : "-"), bgcolor=color.black, text_color=color.white, tooltip=infoTip("Finales Ziel und aktuell gültiger Stop des laufenden Trades. Wenn Paper Health den Stop auf BE zieht, steht hier der Entry."))
        table.cell(infoTable, 0, 12 + infoTableOffset, "Trade Management: " + activeTradeManagementText, bgcolor=statusColor, text_color=color.white, tooltip=infoTip("Zeigt nur noch Management-Informationen zum aktiven Trade. Confirmation wird hier bewusst ausgeblendet."))
        table.cell(infoTable, 0, 13 + infoTableOffset, "Health: " + TRADE_HEALTH_MODE + " | " + tradeHealthScoreText + " | " + displayHealthStatus, bgcolor=tradeHealthColor, text_color=color.white, tooltip=infoTip("Trade Health v2.1 bewertet den aktiven Trade abhängig von Phase, Tagestyp, Alter, Fortschritt und Effizienz."))
        table.cell(infoTable, 0, 14 + infoTableOffset, "Phase: " + healthPhaseDisplayText, bgcolor=color.black, text_color=color.white, tooltip=infoTip("PRE_TP1 darf handeln, RUNNER_AFTER_TP1 beobachtet nur, CLOSED friert den letzten Zustand ein."))
        table.cell(infoTable, 0, 15 + infoTableOffset, "Empfehlung: " + (TRADE_HEALTH_MODE == "OFF" ? "-" : displayHealthRecommendation), bgcolor=tradeHealthColor, text_color=color.white, tooltip=infoTip("Es gibt nur drei Empfehlungen: Halten, SL auf BE oder Hart raus."))
        table.cell(infoTable, 0, 16 + infoTableOffset, "Paper Aktion: " + paperActionDisplayText, bgcolor=color.black, text_color=color.white, tooltip=infoTip("Zeigt, ob Paper Trading nur beobachtet oder eine Health-Empfehlung automatisch umgesetzt hat."))
        table.cell(infoTable, 0, 17 + infoTableOffset, "Health-Grund: " + (TRADE_HEALTH_MODE == "OFF" ? "-" : displayHealthReason), bgcolor=color.black, text_color=color.white, tooltip=infoTip("Kurzbegründung der aktuellen Trade-Health-Einschätzung."))
        table.cell(infoTable, 0, 18 + infoTableOffset, "TP1-Fortschritt: " + tp1ProgressText + " | Erwartet: " + expectedProgressText, bgcolor=color.black, text_color=color.white, tooltip=infoTip("Vergleicht den bisher besten Lauf Richtung TP1 mit dem erwarteten Mindestfortschritt für Alter und Kontext."))
        table.cell(infoTable, 0, 19 + infoTableOffset, "Risk Used: " + riskUsedText + " | MFE/MAE: " + mfeMaeRatioText, bgcolor=color.black, text_color=color.white, tooltip=infoTip("Risk Used zeigt die bisherige Gegenbewegung. MFE/MAE zeigt, ob der Trade effizient für uns gearbeitet hat."))
        table.cell(infoTable, 0, 20 + infoTableOffset, healthMfeMaeText + " | Best MFE vor " + minutesSinceBestMFEText, bgcolor=color.black, text_color=color.white, tooltip=infoTip("MFE ist die beste Bewegung für uns, MAE die schlechteste Bewegung gegen uns. Die Zeit seit bestem MFE zeigt Momentum-Stall."))
        table.cell(infoTable, 0, 21 + infoTableOffset, "TP1: " + (tp1Hit ? "JA (" + tp1Text + ")" : "NEIN") + " | TP2: " + (tp2Hit ? "JA (" + tp2Text + ")" : "NEIN") + " | SL: " + (slHit ? "JA (" + slText + ")" : "NEIN"), bgcolor=color.black, text_color=color.white, tooltip=infoTip("Welche Trade-Ereignisse bereits passiert sind."))
        table.cell(infoTable, 0, 22 + infoTableOffset, "Neuer Einstieg: " + newEntryLockText, bgcolor=color.orange, text_color=color.white, tooltip=infoTip("Solange ein Trade läuft, ist ein neuer Einstieg bewusst gesperrt."))
        if showPaperTrackingRow
            table.cell(infoTable, 0, 24 + infoTableOffset, "Paper: Qty " + paperQtyText + " | BE " + paperBeText + " | Outcome " + paperOutcomeText, bgcolor=color.black, text_color=color.white, tooltip=infoTip("Nur im Backtest: Positionsgröße, Break-even-Status und Paper-Ergebnis."))

    if cockpitReviewPhase
        table.cell(infoTable, 0, 8 + infoTableOffset, "Review: " + reviewOutcomeText + " | Laufzeit: " + tradeAgeText, bgcolor=statusColor, text_color=color.white, tooltip=infoTip("Nach Trade-Ende steht hier das Ergebnis und direkt daneben die Laufzeit."))
        table.cell(infoTable, 0, 9 + infoTableOffset, "Trade: " + (tradeSide == "" ? "-" : tradeSide) + " | Qualität: " + setupQualityText, bgcolor=color.black, text_color=color.white, tooltip=infoTip("Zeigt, ob der beendete Trade ein Long oder Short war und welche Qualitätsklasse gehandelt wurde."))
        table.cell(infoTable, 0, 10 + infoTableOffset, "Exit Grund: " + reviewReasonText, bgcolor=color.black, text_color=color.white, tooltip=infoTip("Warum der Trade oder das Setup beendet wurde."))
        table.cell(infoTable, 0, 11 + infoTableOffset, "Trigger: " + exitTriggerText, bgcolor=color.black, text_color=color.white, tooltip=infoTip("Die konkrete Preisbedingung des Exits, falls es einen Trade gab."))
        table.cell(infoTable, 0, 12 + infoTableOffset, "Trade Score: " + tradeScoreText, bgcolor=tradeScoreColor, text_color=color.white, tooltip=infoTip("Review-Score nach abgeschlossenem Trade."))
        table.cell(infoTable, 0, 13 + infoTableOffset, "Markus A: " + markusAText + " | Markus B: " + markusBText, bgcolor=markusColor, text_color=color.black, tooltip=infoTip("Review-Blick auf Disziplin und Trade-Qualität."))
        table.cell(infoTable, 0, 14 + infoTableOffset, "Original Outcome: " + originalOutcomeText, bgcolor=color.black, text_color=color.white, tooltip=infoTip("Klassisches Ergebnis nach ursprünglicher TP/SL-Logik."))
        table.cell(infoTable, 0, 15 + infoTableOffset, "Health Outcome: " + healthManagedOutcomeText, bgcolor=color.black, text_color=color.white, tooltip=infoTip("Ergebnis nach Trade-Health-Management. Damit vergleichen wir Health gegen die klassische Logik."))
        table.cell(infoTable, 0, 16 + infoTableOffset, "Health: " + TRADE_HEALTH_MODE + " | " + tradeHealthScoreText + " | " + displayHealthStatus, bgcolor=tradeHealthColor, text_color=color.white, tooltip=infoTip("Letzter Trade-Health-Zustand dieses Trades."))
        table.cell(infoTable, 0, 17 + infoTableOffset, "Phase: " + healthPhaseDisplayText + " | Grund: " + displayHealthReason, bgcolor=color.black, text_color=color.white, tooltip=infoTip("Zeigt die finale Health-Phase und den Grund für die letzte Empfehlung oder Aktion."))
        if showPaperTrackingRow
            table.cell(infoTable, 0, 18 + infoTableOffset, "Paper: Qty " + paperQtyText + " | BE " + paperBeText + " | Outcome " + paperOutcomeText, bgcolor=color.black, text_color=color.white, tooltip=infoTip("Nur im Backtest: Positionsgröße, Break-even-Status und Paper-Ergebnis."))
    if DEBUG_COUNTERS
        table.cell(infoTable, 0, infoTableRows - 1, "Config Start Debug: " + configStartDebugText, bgcolor=color.black, text_color=color.white, tooltip=infoTip("Debug für Replay: active und auto müssen im Backtest innerhalb desselben Chart-Tages stabil bleiben."))
else if updateInfoTable and not isSupportedMarket
    table.clear(infoTable, 0, 0, 0, infoTableRows - 1)

// =====================================================
// ALERT ENGINE
// =====================================================

alertDateTimeText =
     str.tostring(dayofmonth(time, DISPLAY_TZ), "00") + "." +
     str.tostring(month(time, DISPLAY_TZ), "00") + "." +
     str.tostring(year(time, DISPLAY_TZ)) + " " +
     timeToText(time)

alertText(alertType, quality, direction, details) =>
    alertType +
     " | Asset: " + MARKET +
     " | Qualität: " + quality +
     " | Richtung: " + direction +
     " | Config: " + activeConfigId +
     " | Zeit: " + alertDateTimeText +
     " | State: " + setupStateText +
     (details != "" ? " | " + details : "")

wrongTimeframe =
     not timeframe.isminutes or
     timeframe.multiplier != 5

if alertsEnabled and wrongTimeframe and not timeframeAlerted
    alert(alertText("TIMEFRAME FALSCH", "-", "-", "Bitte 5-Minuten-Chart verwenden"), alert.freq_once_per_bar)
    timeframeAlerted := true

if alertsEnabled and longEntryZoneAlertNow
    alert(alertText("A+ ENTRY-ZONE ERREICHT", "A+", "LONG", "Entry: " + str.tostring(longEntry) + " | wartet auf Bestätigung"), alert.freq_once_per_bar_close)

if alertsEnabled and shortEntryZoneAlertNow
    alert(alertText("A+ ENTRY-ZONE ERREICHT", "A+", "SHORT", "Entry: " + str.tostring(shortEntry) + " | wartet auf Bestätigung"), alert.freq_once_per_bar_close)

usOpenFilterNow =
     isUsOpenWindow and
     setupState == STATE_TOUCHED and
     not usOpenFilterAlerted

if alertsEnabled and usOpenFilterNow
    alert(alertText("US OPEN FILTER AKTIV", "A+", tradeSide == "" ? "-" : tradeSide, "Entry Zone erreicht, aber keine Confirmation bis nach 15:45 Madrid"), alert.freq_once_per_bar)
    usOpenFilterAlerted := true

if alertsEnabled and longEntryTriggered
    alert(alertText("A+ ENTRY BESTÄTIGT", "A+", "LONG", "Score: " + confirmationScoreRawText + " / Mindestscore: " + confirmationMinScoreText + " | Entry: " + str.tostring(longEntry) + " | SL: " + str.tostring(longSL) + " | TP1: " + str.tostring(longTP1) + " | TP2: " + str.tostring(longTP2)), alert.freq_once_per_bar_close)

if alertsEnabled and shortEntryTriggered
    alert(alertText("A+ ENTRY BESTÄTIGT", "A+", "SHORT", "Score: " + confirmationScoreRawText + " / Mindestscore: " + confirmationMinScoreText + " | Entry: " + str.tostring(shortEntry) + " | SL: " + str.tostring(shortSL) + " | TP1: " + str.tostring(shortTP1) + " | TP2: " + str.tostring(shortTP2)), alert.freq_once_per_bar_close)

if alertsEnabled and confirmationExpired
    alert(alertText("ENTRY NICHT BESTÄTIGT", setupQualityText, tradeSide == "" ? "-" : tradeSide, confirmationMovedTooFarAgainst ? "Confirmation abgebrochen | Markt zu weit gegen Entry" : "Kein Trade"), alert.freq_once_per_bar_close)

if alertsEnabled and healthBERecommendationNow
    alert(alertText("TRADE_HEALTH_BE", setupQualityText, tradeSide == "" ? "-" : tradeSide, "Trade Health: SL auf BE"), alert.freq_once_per_bar)
    healthBEAlerted := true

if alertsEnabled and healthHardExitRecommendationNow
    alert(alertText("TRADE_HEALTH_HARD_EXIT", setupQualityText, tradeSide == "" ? "-" : tradeSide, "Trade Health: Hart raus"), alert.freq_once_per_bar)
    healthHardExitAlerted := true

if alertsEnabled and healthWarningNow
    alert(alertText("TRADE_HEALTH_WARNING", setupQualityText, tradeSide == "" ? "-" : tradeSide, "Trade Health: Warnung"), alert.freq_once_per_bar)
    healthWarningAlerted := true

if alertsEnabled and (longTP1HitNow or shortTP1HitNow)
    alert(alertText("TP1 ERREICHT", setupQualityText, tradeSide == "" ? "-" : tradeSide, "TP1: " + str.tostring(tradeSide == "LONG" ? longTP1 : shortTP1)), alert.freq_once_per_bar)

if alertsEnabled and (longTP2HitNow or shortTP2HitNow)
    alert(alertText("TP2 ERREICHT", setupQualityText, tradeSide == "" ? "-" : tradeSide, "TP2: " + str.tostring(tradeSide == "LONG" ? longTP2 : shortTP2)), alert.freq_once_per_bar)

if alertsEnabled and classicSLHitNow
    alert(alertText("SL ERREICHT", setupQualityText, tradeSide == "" ? "-" : tradeSide, "SL: " + str.tostring(activePaperSL)), alert.freq_once_per_bar)

if alertsEnabled and activeBEHitNow
    alert(alertText("BE ERREICHT", setupQualityText, tradeSide == "" ? "-" : tradeSide, "Aktiver Stop: " + str.tostring(activePaperSL)), alert.freq_once_per_bar)

if alertsEnabled and setupConsumedNow
    alert(alertText("SETUP INVALIDIERT", setupQualityText, tradeSide == "" ? "-" : tradeSide, setupUsedReason == "" ? "Setup verbraucht" : setupUsedReason), alert.freq_once_per_bar)

fingerWegNow =
     (longTP2HitNow or shortTP2HitNow) or
     setupConsumedNow or
     classicSLHitNow or
     activeBEHitNow

if drawEventLabels and fingerWegNow
    markerOffset = not na(atrValue) and atrValue > 0 ? atrValue * 1.4 : math.max((high - low) * 1.8, syminfo.mintick * 40)
    if longTP2HitNow or shortTP2HitNow
        label.new(
             bar_index,
             high + markerOffset,
             "🏁\nTAGESPLAN\nERFÜLLT",
             style=label.style_label_down,
             yloc=yloc.price,
             color=color.green,
             textcolor=color.white,
             size=size.small)
    else if setupConsumedNow
        label.new(
             bar_index,
             high + markerOffset,
             "🟠 SETUP\nINVALIDIERT",
             style=label.style_label_down,
             yloc=yloc.price,
             color=color.orange,
             textcolor=color.white,
             size=size.normal)
    else if classicSLHitNow
        label.new(
             bar_index,
             low - markerOffset,
             "❌\nSL HIT",
             style=label.style_label_up,
             yloc=yloc.price,
             color=color.red,
             textcolor=color.white,
             size=size.small)
    else if activeBEHitNow
        label.new(
             bar_index,
             low - markerOffset,
             "⚪\nBE HIT",
             style=label.style_label_up,
             yloc=yloc.price,
             color=color.gray,
             textcolor=color.white,
             size=size.small)

if alertsEnabled and bLongBreakout
    alert(alertText("B ENTRY-ZONE ERREICHT", "B", "LONG", "Entry: " + str.tostring(bLongEntry) + " | SL: " + str.tostring(bLongSL) + " | TP1: " + str.tostring(bLongTP1) + " | TP2: " + str.tostring(bLongTP2)), alert.freq_once_per_bar_close)

if alertsEnabled and bShortBreakout
    alert(alertText("B ENTRY-ZONE ERREICHT", "B", "SHORT", "Entry: " + str.tostring(bShortEntry) + " | SL: " + str.tostring(bShortSL) + " | TP1: " + str.tostring(bShortTP1) + " | TP2: " + str.tostring(bShortTP2)), alert.freq_once_per_bar_close)
````
