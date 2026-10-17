# maXXit LevelTRG [V6 2.0]

- url: https://www.tradingview.com/script/UBAwnPl6-maXXit-LevelTRG-V6-2-0/
- type: indicator
- pine_id: PUB;838b4d2701da42b28c7d02aa20c5302d
- version: 7.0

## Description

# maXXit Level Trigger [V6 2.0] — Overview

**Platform:** TradingView Pine Script v6 · Overlay indicator

---

## What does the Level Trigger do?

The Level Trigger automates trade entries and exits based on a freely configurable price level. False breakouts are filtered by an **N-closes confirmation** — only after N consecutive candles close through the level is an action triggered. The trigger fires JSON alerts to an external webhook server connected to a broker API (IBKR, OANDA, IG Markets).

If the signal generation is based on futures contracts (highly recommended), the mirror instruments are mapped through configurable parameters inside the script to the pre-configured broker API. The trigger does not fire position entries or exits inside TradingView directly. A plain-text message can be sent as an alternative.

All state machine logic runs **live only** — no historical replay arming.

---

## Flow (State Machine)

```
1. ARMED    — Price touches the trigger level from the opposite side (intrabar, live bar only)
2. ENTRY    — N consecutive closes back through the level → BUY / SELL alert
3. POSITION — Stop and TP monitor the open position
4. EXIT     — SL or TP fires → closing order alert
```

---

## Features

| Feature | Description |
|---|---|
| **Long & Short** | Both directions configurable |
| **N-Closes (1–3)** | Consecutive closes required for arming confirmation, entry and SL/TP (Close mode) |
| **Live arming only** | Trigger arms only on real-time bars — no historical replay |
| **Trigger-level stop** | N closes back through the trigger level = automatic stop exit. Active only when no Absolute SL is set |
| **Absolute Stop Loss** | A separate SL level — fires immediately on intrabar touch, no close confirmation. When set, the trigger-level stop is deactivated |
| **Take Profit — Close mode** | TP arms on intrabar touch (high/low crosses TP level), exits on N consecutive closes back through TP |
| **Take Profit — Touch mode** | Exit fires immediately on intrabar TP touch |
| **Trailing stop** | Auto-stop locks at the TP level when TP is first reached — acts as a floor stop while price runs |
| **JSON alerts** | Direct broker integration (IBKR, OANDA, IG Markets) via webhook |
| **Symbol mapping** | Pre-defined instrument parameters for 15+ futures/CFDs |
| **Lock to Symbol** | Trigger stays bound to the selected instrument ticker prefix across chart changes |
| **Position Lock** | Preserves position state (LONG/SHORT) when inputs are changed mid-trade |
| **Fractal Grid** | Optional overlay of highest-high / lowest-low grids (5 levels, 10–50 bars) |

---

## Stop Loss Logic — Three-tier hierarchy

Only one tier is active at a time:

| Priority | Condition | Stop mechanism | Trigger |
|---|---|---|---|
| **1 — Absolute SL** | SL Level > 0 | Fixed price level | Intrabar touch — immediate |
| **2 — Auto-SL (TP lock)** | TP reached → auto_sl set | Old TP level becomes new stop | N consecutive closes through the level |
| **3 — Trigger-level stop** | No SL, no auto_sl | Trigger level acts as stop | N consecutive closes |

### How tiers interact

- When **Absolute SL is set**: tiers 2 and 3 are deactivated. Only the intrabar stop fires.
- When **TP is reached** (intrabar touch in Close mode): the TP level locks as a trailing stop (`auto_sl`). The Absolute SL can now be removed — `auto_sl` takes over with N-close confirmation.
- When **neither SL nor auto_sl is active**: the trigger level itself acts as the stop (N closes back through it).

### After a stop fires

The trigger does not re-arm automatically. To re-activate, change the Trigger Level input — this resets all state.

---

## Worked Example — LONG, N = 2 closes

**Setup:** Direction = LONG · Trigger = 5000 · TP = 5100 · Closes required = 2

### Phase 1 — Entry

| Event | What happens |
|---|---|
| Price dips below 5000 (intrabar, live) | Trigger **arms** — indicator starts watching |
| Price rises, 2 consecutive closes above 5000 | **Entry alert fired** → BUY order sent · stop activates at 5000 |
| Price dips back, 2 closes below 5000 (before TP) | **Stop exit** → SELL alert · trigger deactivates |

### Phase 2a — TP exit (Close mode, price reverses after TP)

| Event | What happens |
|---|---|
| Price rises through 5100 (intrabar) | TP **arms** — stop locks at 5100, indicator waits for reversal |
| Price falls back, 2 consecutive closes below 5100 | **TP exit alert** → SELL order sent · position closed |

### Phase 2b — Trailing stop (price keeps running above TP)

| Event | What happens |
|---|---|
| Price rises through 5100 | TP arms — stop **locks at 5100** (yellow line) |
| Price continues above 5100 | Position stays open · stop remains at 5100 |
| User raises TP to 5200 | `tp_armed` resets · stop stays locked at old 5100 level (use Active Position to preserve state) |
| Price reaches 5200 | Stop locks at 5200 |
| Price falls, 2 closes below 5200 | **Stop exit alert** → SELL order sent |

> The locked stop (old TP level) works exactly like the trigger-level stop: N consecutive closes through the level fire the exit.

### Workflow — raising TP while stop is locked

Pine Script resets all computed state (`tp_armed`, `auto_sl`) on every input change. To preserve the locked stop when raising TP:

| Step | Action |
|---|---|
| 1 | Note the current locked stop level (yellow line, e.g. 5100) |
| 2 | Set **Active Position** = `LONG` (or `SHORT`) |
| 3 | Set **Trigger Level** = locked stop value (e.g. 5100) |
| 4 | Set **TP Level** = new target (e.g. 5200) |
| 5 | After recalc: position restored · Trigger Level acts as stop · new TP active |

> **Why Trigger Level:** it is a persistent input that survives recalculation. When in position with no Absolute SL and no `auto_sl`, the trigger level acts as the N-closes stop.

---

## Visual Display

### Trigger label (at trigger level)

| State | Label | Color |
|---|---|---|
| Armed, LONG direction | TOUCHED ↑ | Green |
| Armed, SHORT direction | TOUCHED ↓ | Red |
| Active LONG position | LONG ↑ | Green |
| Active SHORT position | SHORT ↓ | Red |
| SL/Trigger crossed while in position | CAUTION | Orange |
| TP armed (acting as SL) | IDLE | Gray |
| No trigger configured | IDLE | Gray |

### SL label (at SL level)

| State | Label | Color |
|---|---|---|
| In LONG position | ARMED ▼ | Dark orange |
| In SHORT position | ARMED ▲ | Dark orange |
| Armed, LONG direction | ARMED ▼ | Dark orange |
| Armed, SHORT direction | ARMED ▲ | Dark orange |
| Hidden when TP is armed (TP line acts as SL) | — | — |

### TP label (at TP level)

| State | Label | Color |
|---|---|---|
| Position open, TP not yet reached | TP ACTIVE | Green |
| TP reached, acting as trailing stop (LONG) | SL ACTIVE ↑ | Green |
| TP reached, acting as trailing stop (SHORT) | SL ACTIVE ↓ | Red |
| TP exit just fired | TP CLOSED | Gray |
| No position | IDLE | Gray |

### Lines

- **Trigger line** — dashed · color matches trigger label state
- **SL line** — solid · dark orange when armed or in position · hidden when TP is acting as SL
- **TP line** — dashed · green (active) · color matches TP label state
- **Auto-SL line** — solid yellow · shows locked stop level when TP has armed

---

## Design Decisions & Rationale

### Why live-only arming (`barstate.isrealtime`)

All state machine logic runs only on real-time bars. Trigger levels are set manually based on the current Elliott Wave analysis. A historical simulation of manually-set levels would be meaningless — the level is valid only in the context of the current wave structure. Live-only arming ensures clean state on each session start and prevents false fills from historical data replay.

### Why the trigger does not re-arm automatically after exit

After a trade closes, re-entry at the same level requires re-analysis and a conscious decision. Re-arming is triggered by changing the Trigger Level input, which reloads all state. This is intentional: the wave structure has either confirmed or invalidated at that level.

### Why position sizing is manual

Risk per trade depends on the SL distance, which varies with each wave setup. The analyst calculates `quantity = max_risk_USD / (entry_price - SL_level)` before setting inputs. Automating this inside the script would require the entry price to be known in advance, which conflicts with the trigger-based entry mechanism.

### Why TradingView webhooks (no direct broker connection)

TradingView provides the charting and signal generation layer. The broker API integration lives in a separate webhook server. This separation keeps the Pine Script simple and broker-agnostic — switching brokers requires only a server-side change, not a script rewrite.

### Why N-closes confirmation instead of intrabar triggers

Intrabar wicks frequently penetrate Elliott levels without confirming. N confirmed closes through a level provide meaningful structure confirmation — a wick is noise, a close is a statement. The cost is a few points of slippage on the entry; the benefit is fewer false signals.

### Why TP Close mode arms on intrabar touch (not N closes)

TP is a profit target, not a structural level. Waiting for N closes above the TP level before arming would delay the trailing stop activation unnecessarily — the first intrabar touch is sufficient evidence that the target was reached. The exit itself still requires N closes back through the TP level, preserving the confirmation logic on the way out.

---

## Settings Reference

| Input | Group | Description |
|---|---|---|
| Send JSON Alert | Account & Broker | ON = JSON webhook · OFF = plain-text alert |
| Webhook Secret | Account & Broker | Token included in JSON payload for server authentication |
| Account ID | Account & Broker | Broker account identifier (IBKR, OANDA, IG Markets, etc.) |
| Use predefined mapping | Instrument | Uses built-in symbol → broker mapping table |
| Mirror Trade | Instrument | NO = trade the chart future · YES = trade mirror instrument (STK/CFD) |
| Mirror Instrument | Instrument | STK (IBKR ETF) or CFD (OANDA / IG Markets) |
| Quantity | Instrument | Size of the order |
| Direction | Level Trigger | LONG or SHORT |
| Trigger Level | Level Trigger | Price level. 0 = disarmed |
| Stop Loss Level | Level Trigger | Absolute SL. 0 = use trigger-level stop instead |
| TP Level | Level Trigger | Take profit level. 0 = disabled |
| TP Arm Mode | Level Trigger | Touch = immediate intrabar exit · Close = N-close reversal confirmation |
| Closes required | Level Trigger | 1–3 consecutive closes needed for arming, entry and SL/TP |
| Lock to Symbol | Level Trigger | Ticker prefix to lock trigger to one instrument (e.g. MNQ, FXXP) |
| Active Position | Level Trigger | Auto / LONG / SHORT — preserves position state across input changes |
| Fractal Grid | Position Management | Shows highest-high / lowest-low grid overlay |

---

## Supported Instruments

| Prefix | Instrument | Exchange | Mirror (STK) | Mirror (CFD OANDA) | Mirror (CFD IG) |
|---|---|---|---|---|---|
| MNQ | Micro Nasdaq-100 | CME | QQQ | NAS100_USD | NASDAQ |
| MES | Micro S&P 500 | CME | SPY | SPX500_USD | SPTRD |
| MYM | Micro Dow Jones | CBOT | DIA | US30_USD | DOW |
| FXXP / FSXE | Euro Stoxx 50 | EUREX | IMEU | EU50_EUR | STXE |
| MGC | Micro Gold | COMEX | GLD | XAU_USD | SPOTGOLD |
| MCL | Micro Crude Oil | NYMEX | USO | WTICO_USD | USOIL |
| MNG | Micro Nat Gas | NYMEX | — | NATGAS_USD | NATURALGAS |
| MHG | Micro Copper | COMEX | — | XCU_USD | COPPER |
| ZW | Wheat | CBOT | — | WHEAT_USD | — |
| ZN | 10Y T-Note | CBOT | — | USB10Y_USD | — |
| CN1 | FTSE China A50 | SGX | — | CN50_USD | — |
| EURUSD | EUR/USD Spot | IDEALPRO | — | EUR_USD | — |
| BTCUSD | Bitcoin | — | — | BTC_USD | BITCOIN |
| ETHUSD | Ethereum | — | — | ETH_USD | ETHUSD |

---

## Later Enhancements Planned

| # | Enhancement | Rationale |
|---|---|---|
| **1** | **Multi-level trigger** — two simultaneous trigger levels with independent directions | Allows monitoring Wave 3 and Wave 5 levels simultaneously without two separate chart instances |
| **2** | **Partial exits / scale-out** — e.g. 50% at TP1, remainder with trailing stop | Elliott Wave extensions are common; closing the full position at the first TP level often leaves significant profit on the table |
| **3** | **Volatility-adaptive N-closes** — automatically tighten/loosen confirmation count based on ATR or session volatility | A single N-close setting behaves differently in a quiet overnight session vs. a high-impact news event |

## Source Code

````pine
//@version=6
indicator('maXXit LevelTRG[V6 2.2 ATR]',
        overlay = true,
        max_bars_back = 500,
        max_labels_count = 100,
        max_lines_count = 100)

// LEVEL TRIGGER - arm on price touch, enter on N closes through level, TP/SL same logic
// Mirror trade: JSON alerts via alert() on every signal
// copyright maXXit consulting, 2026 - all rights reserved

// =====================================================
// CONSTANTS
// =====================================================
string TIMEZONE          = 'Europe/Berlin'
int    MIN_PER_HOUR      = 60
int    LINE_LOOKBACK     = 499  // max_bars_back (indicator header) minus 1
string FMT_DEC           = '0.0#'
int    LABEL_BG_TRANSP   = 75
int    ATR_IDLE_TRANSP   = 60
int    FRACTAL_STEP      = 10
int    FRACTAL_LEVELS    = 5
int    FRACTAL_LINE_BACK = FRACTAL_STEP * FRACTAL_LEVELS
int    FRACTAL_LINE_FWD  = 10
int    EMA_FAST_LEN      = 55
int    EMA_SLOW_LEN      = 233

// =====================================================
// INSTRUMENT MAPPING  (same as EMA V6 / FibuTRG V6)
// Rules:
//   FUT / STK  → always IBKR  (conid from map;  STK: conid = 0)
//   CFD        → OANDA or IG_MARKETS (conid always 0)
// =====================================================
currentInstrument = syminfo.ticker

var string fut_xChange    = syminfo.prefix
var string stk_symbol     = ''
var string stk_xChange    = syminfo.prefix
var string stk_pxChange   = syminfo.prefix
var string oa_symbol      = ''
var string ig_symbol      = ''
var string INSTR_CURR     = 'USD'
var string base_secType   = 'FUT'
var int    fut_conid      = 0

if str.startswith(currentInstrument, "MNQ") or currentInstrument == "NAS100USD"
    fut_xChange    := "CME"
    fut_conid      := 770561201
    stk_symbol     := "QQQ"
    stk_xChange    := "NASDAQ"
    stk_pxChange   := "NASDAQ"
    oa_symbol      := "NAS100_USD"
    ig_symbol      := "NASDAQ"

else if str.startswith(currentInstrument, "MYM") or currentInstrument == "US30USD"
    fut_xChange    := "CBOT"
    fut_conid      := 793356180
    stk_symbol     := "DIA"
    stk_xChange    := "AMEX"
    stk_pxChange   := "ARCA"
    oa_symbol      := "US30_USD"
    ig_symbol      := "DOW"

else if str.startswith(currentInstrument, "MES") or currentInstrument == "SPX500USD"
    fut_xChange    := "CME"
    fut_conid      := 770561194
    stk_symbol     := "SPY"
    stk_xChange    := "AMEX"
    stk_pxChange   := "ARCA"
    oa_symbol      := "SPX500_USD"
    ig_symbol      := "SPTRD"

else if str.startswith(currentInstrument, "FXXP")
    fut_xChange    := "EUREX"
    fut_conid      := 638120498
    stk_symbol     := "IMEU"
    stk_xChange    := "EURONEXT"
    stk_pxChange   := "AEB"
    oa_symbol      := "EU50_EUR"
    ig_symbol      := ""
    INSTR_CURR     := 'EUR'

else if str.startswith(currentInstrument, "FSXE") or currentInstrument == "EU50EUR"
    fut_xChange    := "EUREX"
    fut_conid      := 816545383
    stk_symbol     := "IMEU"
    stk_xChange    := "EURONEXT"
    stk_pxChange   := "AEB"
    oa_symbol      := "EU50_EUR"
    ig_symbol      := "STXE"
    INSTR_CURR     := 'EUR'

else if str.startswith(currentInstrument, "CN1")
    fut_xChange    := "SGX"
    fut_conid      := 847071984
    oa_symbol      := "CN50_USD"

else if str.startswith(currentInstrument, "MGC") or currentInstrument == "XAUUSD"
    fut_xChange    := "COMEX"
    fut_conid      := 706903676
    stk_symbol     := "GLD"
    stk_xChange    := "AMEX"
    stk_pxChange   := "ARCA"
    oa_symbol      := "XAU_USD"
    ig_symbol      := "SPOTGOLD"

else if str.startswith(currentInstrument, "MCL") or currentInstrument == "WTICOUSD"
    fut_xChange    := "NYMEX"
    fut_conid      := 661016514
    stk_symbol     := "USO"
    stk_xChange    := "AMEX"
    stk_pxChange   := "ARCA"
    oa_symbol      := "WTICO_USD"
    ig_symbol      := "USOIL"

else if str.startswith(currentInstrument, "MNG") or currentInstrument == "NATGASUSD"
    fut_xChange    := "NYMEX"
    fut_conid      := 699387166
    oa_symbol      := "NATGAS_USD"
    ig_symbol      := "NATURALGAS"

else if str.startswith(currentInstrument, "MHG")
    fut_xChange    := "COMEX"
    fut_conid      := 699387166
    oa_symbol      := "XCU_USD"
    ig_symbol      := "COPPER"

else if str.startswith(currentInstrument, "ZW") or currentInstrument == "WHEATUSD"
    fut_xChange    := "CBOT"
    oa_symbol      := "WHEAT_USD"

else if str.startswith(currentInstrument, "ZN")
    fut_xChange    := "CBOT"
    fut_conid      := 792996527
    oa_symbol      := "USB10Y_USD"

else if str.startswith(currentInstrument, "10Y")
    fut_xChange    := "CBOT"
    fut_conid      := 835061422

else if str.startswith(currentInstrument, "USB10Y")
    fut_xChange    := "CBOT"
    oa_symbol      := "USB10Y_USD"

else if str.startswith(currentInstrument, "EURUSD")
    fut_xChange    := "IDEALPRO"
    oa_symbol      := "EUR_USD"
    base_secType   := 'CASH'

else if currentInstrument == 'ETHUSD'
    base_secType   := 'CRYPTO'
    oa_symbol      := 'ETH_USD'
    ig_symbol      := 'ETHUSD'

else if currentInstrument == 'BTCUSD'
    base_secType   := 'CRYPTO'
    oa_symbol      := 'BTC_USD'
    ig_symbol      := 'BITCOIN'

// =====================================================
// OANDA / IG DOT SIZE MAPPING  (size decimals; default 0)
// =====================================================
oandaDotSize(string sym) =>
    switch sym
        "NAS100_USD" => 2
        "US30_USD"   => 2
        "SPX500_USD" => 2
        "EU50_EUR"   => 1
        "CN50_USD"   => 1
        "XAU_USD"    => 1
        "ETH_USD"    => 2
        "BTC_USD"    => 3
        "USB10Y_USD" => 3
        => 0

mapToIG(string sym) =>
    upper_sym = str.upper(sym)
    [x_symbol, x_size] = switch upper_sym
        "STXE"       => ["IX.D.STXE.IFM.IP",     1]
        "DOW"        => ["IX.D.DOW.IFM.IP",      1]
        "SPTRD"      => ["IX.D.SPTRD.IFM.IP",    2]
        "NASDAQ"     => ["IX.D.NASDAQ.IFM.IP",   1]
        "SPOTGOLD"   => ["CS.D.CFDGOLD.CFM.IP",  2]
        "COPPER"     => ["CS.D.COPPER.MINI.IP",  2]
        "SILVER"     => ["CS.D.CFDSILVER.CFM.IP", 2]
        "USOIL"      => ["CC.D.CL.UNC.IP",       2]
        "NATURALGAS" => ["CC.D.NG.UNC.IP",       2]
        "ETHUSD"     => ["CS.D.ETHUSD.CFD.IP",   1]
        "BITCOIN"    => ["CS.D.BITCOIN.CFD.IP",  1]
        => [sym, 1]
    [x_symbol, x_size]

// =====================================================
// ACCOUNT & BROKER
// =====================================================
group_acct = '🔑 Account & Broker'

SEND_JSON  = input.bool(true, '📡 Send JSON Alert', group = group_acct,
             tooltip = 'Disabled → plain-text alert instead of JSON')
TOKEN_ID   = input.string('', '🔐 Webhook Secret', group = group_acct)
CLIENT_ID  = input.string('', '😎 Account ID',     group = group_acct,
             options = ['','DUO940014','U3103575','OANDA_EUR','OANDA_USD','IG_MARKETS','None'])

// =====================================================
// INSTRUMENT CONFIG
// =====================================================
group_instr = '📋 Instrument'

USE_MAPPING  = input.bool(true, '📌 Use predefined mapping', group = group_instr,
               tooltip = 'ON: instrument params from built-in mapping table\nOFF: auto-read from chart — only conid and primary exchange need manual input')

string man_symbol   = syminfo.ticker
string man_currency = syminfo.currency
string man_exchange = syminfo.prefix
string man_sectype  = syminfo.type == 'futures' ? 'FUT' : syminfo.type == 'stock' ? 'STK' : syminfo.type == 'forex' ? 'CASH' : syminfo.type == 'crypto' ? 'CRYPTO' : 'FUT'

MIRROR_TRD = input.string('NO',  '🔂 Mirror Trade',       group = group_instr,
             options = ['NO','YES'],
             tooltip = 'NO: alert targets the Future directly (IBKR FUT).\nYES: alert targets a mirror instrument (STK or CFD) instead.')
INSTR_TRD  = input.string('CFD', '🎸 Mirror Instrument',  group = group_instr,
             options = ['STK','CFD'],
             tooltip = 'Which instrument to trade when Mirror Trade = YES.\nSTK → IBKR stock/ETF\nCFD → OANDA or IG_MARKETS (set Account ID accordingly)')
QTY        = input.float(1.0, '📦 Quantity', group = group_instr, step = 0.01, minval = 0.01,
             tooltip = 'No Mirror Trade: quantity of the chart instrument.\nMirror Trade: quantity of the mirror instrument.')
MAN_CONID    = input.int(0,   '🆔 conid',            group = group_instr,
               tooltip = 'IB contract ID. Only needed for IBKR FUT. Set 0 to omit.')
MAN_PXCHANGE = input.string("", '🏛️ Primary Exchange', group = group_instr,
               options = ["", "OANDA", "IG_MARKETS","EURONEXT", "EUREX", "CBOT", "COMEX", "NYMEX", "NASDAQ", "AMEX", "ARCA"],
               tooltip = 'Leave blank to use Exchange (syminfo.prefix) as primary exchange.\nNeeded for STK trading with IBKR outside RTH (Overnight, Premarket).')

string man_pxchange = MAN_PXCHANGE == '' ? man_exchange : MAN_PXCHANGE

// =====================================================
// DERIVED BROKER FIELDS
// =====================================================
string eff_instr_type = MIRROR_TRD == 'YES' ? INSTR_TRD : 'FUT'

bool is_cfd   = eff_instr_type == 'CFD'
bool is_stk   = eff_instr_type == 'STK'
bool is_oanda = CLIENT_ID == 'OANDA_EUR' or CLIENT_ID == 'OANDA_USD'

[_ig_api_sym, _ig_dot_s] = mapToIG(ig_symbol)
string map_secType  = base_secType != 'FUT' ? base_secType : eff_instr_type
string map_symbol   = is_cfd ? (is_oanda ? oa_symbol : _ig_api_sym) : is_stk ? stk_symbol : currentInstrument
string map_exchange = is_cfd ? (is_oanda ? 'OANDA' : 'IG_MARKETS') : is_stk ? stk_xChange : fut_xChange
string map_pxchange = is_cfd ? map_exchange : is_stk ? stk_pxChange : fut_xChange
int    map_conid    = (is_stk or is_cfd) ? 0 : fut_conid
string map_currency = INSTR_CURR

string eff_secType  = USE_MAPPING ? map_secType  : man_sectype
string eff_symbol   = USE_MAPPING ? map_symbol   : man_symbol
string eff_exchange = USE_MAPPING ? map_exchange : man_exchange
string eff_pxchange = USE_MAPPING ? map_pxchange : man_pxchange
int    eff_conid    = USE_MAPPING ? map_conid    : MAN_CONID
string eff_currency = USE_MAPPING ? map_currency : man_currency

// =====================================================
// LEVEL TRIGGER
// =====================================================
group_lt = '⚡ Level Trigger'

DIRECTION     = input.string('LONG', '📐 Direction', group = group_lt,
                options = ['LONG','SHORT'],
                tooltip = 'LONG:  arms on price touch below trigger → enters on N closes above (plus ATR threshold) → SL on N closes below\nSHORT: arms on price touch above trigger → enters on N closes below (minus ATR threshold) → SL on N closes above')
DYNA_THRESHOLD = input.float(0.5, '📊 Dynamic ATR Threshold', group = group_lt,
                options = [0.0,0.3,0.5,0.8,1.3],
                tooltip = 'Minimum distance from trigger level as ATR multiple.\n0.0 = disabled.\nATR period is auto-selected by timeframe: 1m→13, ≤5m→8, ≤15m→5, >15m→3.')
TRIGGER_LEVEL = input.float(0.0, '🎯 Trigger Level', group = group_lt, step = 0.02,
                tooltip = 'Set to 0 to disarm. Trigger-level stop applies after entry (N closes back through trigger).')

SL_LEVEL      = input.float(0.0, '🛑 Stop Loss Level', group = group_lt, step = 0.02,
                tooltip = 'Optional absolute stop.\nLONG: place below Trigger. SHORT: place above Trigger.\nWhen set: replaces the trigger-level stop — only this absolute SL is active.\nWhen 0: trigger-level stop (N closes) is used instead.')
SL_MODE       = input.string('Touch', '🛑 SL Arm Mode', group = group_lt,
                options = ['Touch','ATR','Close'],
                tooltip = 'Touch: exits immediately on intrabar SL touch (default).\nATR: exits when price moves beyond SL Level by Threshold × ATR (uses Dynamics ATR settings).\nClose: waits for N closes beyond SL Level by Threshold × ATR.')
TP_LEVEL      = input.float(0.0, '✅ TP Level', group = group_lt, step = 0.02,
                tooltip = 'Set to 0 to disable TP. Position closes when price reverses back through TP with N closes.')
TP_MODE       = input.string('Close', '✅ TP Arm Mode', group = group_lt,
                options = ['Close','Touch'],
                tooltip = 'Touch: exits immediately on intrabar TP touch.\nClose: arms on first price touch of TP, exits on N closes back through TP.')
CLOSE_COUNT   = input.int(1, '🕯️ Closes required', group = group_lt, minval = 1, maxval = 3,
                tooltip = 'Consecutive closes required for arming, entry, SL and TP (close mode).')

group_pos = '✅ Position Management'

LOCK_SYMBOL   = input.string('', '🔒 Lock to Symbol', group = group_pos,
                tooltip = 'Enter ticker prefix once (e.g. FXXP, MNQ).\nPersists across chart changes → trigger active on this instrument only.\nEmpty = active on any chart.\nNote: chart shows the recommended value while this field is empty.')
POS_LOCK      = input.string('Auto', '🔧 Active Position', group = group_pos,
                options = ['Auto', 'LONG', 'SHORT'],
                tooltip = 'Set to LONG or SHORT BEFORE changing TP/SL/Trigger mid-trade.\nPrevents state reset caused by Pine Script recalculation on input changes.\nReset to Auto after the trade closes.\nNote: tp_armed and auto_sl always reset — reach TP again to reactivate auto-stop.')
TF1            = input.string('14:29-14:33', '⏰ Timelock 1',          group = group_pos, inline = 'tf1',
                 tooltip = 'Alert time filter — blocks Entry/SL/TP alerts during active windows.\nFormat: HH:MM-HH:MM (Europe/Berlin). State machine keeps running.\nTimelock 3 may span midnight (e.g. 22:00-08:30).')
TF1_ON          = input.bool(true,            '',                     group = group_pos, inline = 'tf1')
TF2             = input.string('15:29-15:35', '⏰ Timelock 2',          group = group_pos, inline = 'tf2')
TF2_ON          = input.bool(true,            '',                     group = group_pos, inline = 'tf2')
TF3             = input.string('00:00-00:00', '⏰ Timelock 3',          group = group_pos, inline = 'tf3')
TF3_ON          = input.bool(false,           '',                     group = group_pos, inline = 'tf3')
SHOW_FRACTAL_GRID = input.bool(true,  '🔲 Fractal Grid',       group = group_pos)
SHOW_EMA          = input.bool(false, '📈 EMA Overlay',         group = group_pos)

bool dir_long = DIRECTION == 'LONG'
bool dyna_on  = DYNA_THRESHOLD > 0
bool dyna_off = not dyna_on

if POS_LOCK != 'Auto' and POS_LOCK != DIRECTION
    runtime.error('Active Position (' + POS_LOCK + ') does not match Direction (' + DIRECTION + '). Set Active Position to Auto or change Direction.')

// =====================================================
// DOT SIZE / FORMAT
// =====================================================
int _dot_size = 0
if is_cfd and is_oanda
    _dot_size := oandaDotSize(oa_symbol)
else if is_cfd
    _dot_size := _ig_dot_s

fmtSize(float sz, int decimals) =>
    fmt = switch decimals
        0 => '0'
        1 => '0.0'
        2 => '0.00'
        3 => '0.000'
        => '0.0000'
    str.tostring(sz, fmt)

string str_json_size = MIRROR_TRD == 'YES' ? fmtSize(QTY, _dot_size) : str.tostring(QTY, '0.##')
string pos_tag       = ' (' + str_json_size + ')'

// =====================================================
// PRICE CONDITIONS
// =====================================================
bool chart_matches  = LOCK_SYMBOL == '' or str.startswith(currentInstrument, LOCK_SYMBOL)
bool trigger_active = TRIGGER_LEVEL > 0.0 and chart_matches
bool sl_active      = SL_LEVEL      > 0.0 and chart_matches
bool tp_active      = TP_LEVEL      > 0.0 and chart_matches

n_closes_below(float lvl) =>
    bool c1 = CLOSE_COUNT < 2 or close[1] < lvl
    bool c2 = CLOSE_COUNT < 3 or close[2] < lvl
    barstate.isconfirmed and close < lvl and c1 and c2

n_closes_above(float lvl) =>
    bool c1 = CLOSE_COUNT < 2 or close[1] > lvl
    bool c2 = CLOSE_COUNT < 3 or close[2] > lvl
    barstate.isconfirmed and close > lvl and c1 and c2

// =====================================================
// DYNAMICS FILTER  (ATR distance from trigger)
// =====================================================
tf_atr_period = switch
    timeframe.isseconds or (timeframe.isminutes and timeframe.multiplier <= 1) => 13
    timeframe.isminutes and timeframe.multiplier <= 5                          => 8
    timeframe.isminutes and timeframe.multiplier <= 15                         => 5
    => 3

float dyna_atr = ta.atr(tf_atr_period)

bool dyna_ok_long  = dyna_off or (close - TRIGGER_LEVEL) >= DYNA_THRESHOLD * dyna_atr
bool dyna_ok_short = dyna_off or (TRIGGER_LEVEL - close) >= DYNA_THRESHOLD * dyna_atr

// =====================================================
// TIMELOCK
// =====================================================
toMinutes(string hhmm) =>
    parts = str.split(str.trim(hhmm), ':')
    int mins = na
    if array.size(parts) == 2
        mins := int(str.tonumber(str.trim(array.get(parts, 0)))) * MIN_PER_HOUR + int(str.tonumber(str.trim(array.get(parts, 1))))
    mins

parseTF(string s, bool on) =>
    p = str.split(s, '-')
    int tf_start = na
    int tf_end   = na
    if array.size(p) == 2
        tf_start := toMinutes(array.get(p, 0))
        tf_end   := toMinutes(array.get(p, 1))
    if on and (na(tf_start) or na(tf_end))
        runtime.error('Timelock "' + s + '": format must be HH:MM-HH:MM')
    [tf_start, tf_end]

int _now_hm       = hour(timenow, TIMEZONE) * MIN_PER_HOUR + minute(timenow, TIMEZONE)
[_tf1s, _tf1e]   = parseTF(TF1, TF1_ON)
[_tf2s, _tf2e]   = parseTF(TF2, TF2_ON)
[_tf3s, _tf3e]   = parseTF(TF3, TF3_ON)
bool alert_blocked = (TF1_ON and _now_hm >= _tf1s and _now_hm < _tf1e) or
                     (TF2_ON and _now_hm >= _tf2s and _now_hm < _tf2e) or
                     (TF3_ON and (_tf3s <= _tf3e ? (_now_hm >= _tf3s and _now_hm < _tf3e) : (_now_hm >= _tf3s or _now_hm < _tf3e)))

// =====================================================
// ALERT MESSAGE BUILDER
// =====================================================
buildAlertMsg(string action, string x_type) =>
    string x_conid   = eff_conid > 0 ? str.tostring(eff_conid) : '0'
    string x_tif     = is_stk ? 'DAY' : 'IOC'
    string dtim      = str.format_time(timenow, "yyyy-MM-dd HH:mm:ss", TIMEZONE)
    string mkt_price = str.tostring(close, FMT_DEC)
    string cmt       = 'LT-' + x_type + '-' + DIRECTION + ' ' + dtim + ' - ' + mkt_price
    SEND_JSON
     ? '{"secret":"' + TOKEN_ID + '","account":"' + CLIENT_ID + '","conid":' + x_conid + ',"secType":"' + eff_secType + '","symbol":"' + eff_symbol + '","currency":"' + eff_currency + '","side":"' + action + '","orderType":"MKT","quantity":' + str_json_size + ',"price":0,"tif":"' + x_tif + '","exchange":"' + eff_exchange + '","primaryExchange":"' + eff_pxchange + '","outsideRth":true,"comment":"' + cmt + '"}'
     : 'LT-' + x_type + ' ' + DIRECTION + ' | Qty:' + str_json_size + ' | ' + mkt_price

// =====================================================
// STATE VARIABLES
// =====================================================
var bool  in_pos           = false
var bool  is_long          = false
var bool  armed            = false
var int   armed_bar        = na
var bool  tp_armed         = false
var float auto_sl          = 0.0
var bool  sl_touched       = false
var bool  tp_fired         = false
var bool  sl_fired         = false
var bool  pos_lock_applied = false
var bool  n_closes_met     = false
var bool  sl_dyna_wait     = false
var bool  entry_sent       = false
var bool  entry_blocked    = false

bool ev_entry = false
bool ev_sl    = false
bool ev_tp    = false

// =====================================================
// POS_LOCK RESTORE — once per recalculation cycle
// =====================================================
if barstate.isrealtime and not in_pos and not pos_lock_applied
    if POS_LOCK == 'LONG'
        in_pos        := true
        is_long       := true
        entry_sent    := true
        entry_blocked := false
    else if POS_LOCK == 'SHORT'
        in_pos        := true
        is_long       := false
        entry_sent    := true
        entry_blocked := false
    pos_lock_applied := true

// =====================================================
// STATE MACHINE — realtime bars only
// =====================================================
if barstate.isrealtime and dir_long
    if not in_pos
        sl_dyna_wait := false
        if trigger_active and not armed and low < TRIGGER_LEVEL and POS_LOCK == 'Auto'
            armed     := true
            armed_bar := bar_index
            tp_fired  := false
            sl_fired  := false
        if armed and bar_index >= armed_bar + CLOSE_COUNT - 1 and n_closes_above(TRIGGER_LEVEL + DYNA_THRESHOLD * dyna_atr)
            ev_entry   := true
            in_pos     := true
            is_long    := true
            armed      := false
            tp_armed   := false
            auto_sl    := 0.0
            sl_touched := false
        if not armed
            n_closes_met := false
        else if barstate.isconfirmed
            if bar_index >= armed_bar + CLOSE_COUNT - 1 and n_closes_above(TRIGGER_LEVEL)
                n_closes_met := not dyna_ok_long
            else
                n_closes_met := false
    else  // long position open
        if low < TRIGGER_LEVEL
            sl_touched := true
        if sl_touched and not ev_sl and not ev_tp and n_closes_above(TRIGGER_LEVEL)
            sl_touched := false
        if sl_active and not ev_tp and (SL_MODE == 'Touch' ? low < SL_LEVEL : SL_MODE == 'ATR' ? low < SL_LEVEL - DYNA_THRESHOLD * dyna_atr : n_closes_below(SL_LEVEL - DYNA_THRESHOLD * dyna_atr))
            ev_sl    := true
            in_pos   := false
            tp_armed := false
            auto_sl  := 0.0
        if tp_active and TP_MODE == 'Touch' and not ev_sl and not tp_armed and high > TP_LEVEL
            ev_tp    := true
            in_pos   := false
            tp_armed := false
            auto_sl  := 0.0
        if tp_active and TP_MODE == 'Close' and not ev_sl and not ev_tp and not tp_armed and high > TP_LEVEL
            tp_armed := true
            auto_sl  := TP_LEVEL
        if not sl_active and not tp_armed and not ev_tp
            bool _sl_n_close = n_closes_below(TRIGGER_LEVEL)
            bool _sl_dyna_ok = dyna_off or (TRIGGER_LEVEL - close) >= DYNA_THRESHOLD * dyna_atr
            if _sl_n_close and _sl_dyna_ok
                ev_sl        := true
                in_pos       := false
                tp_armed     := false
                auto_sl      := 0.0
                sl_dyna_wait := false
            else
                sl_dyna_wait := _sl_n_close and not _sl_dyna_ok
        if tp_armed and not ev_sl and n_closes_below(auto_sl)
            ev_tp    := true
            in_pos   := false
            tp_armed := false
            auto_sl  := 0.0
else if barstate.isrealtime  // SHORT
    if not in_pos
        sl_dyna_wait := false
        if trigger_active and not armed and high > TRIGGER_LEVEL and POS_LOCK == 'Auto'
            armed     := true
            armed_bar := bar_index
            tp_fired  := false
            sl_fired  := false
        if armed and bar_index >= armed_bar + CLOSE_COUNT - 1 and n_closes_below(TRIGGER_LEVEL - DYNA_THRESHOLD * dyna_atr)
            ev_entry   := true
            in_pos     := true
            is_long    := false
            armed      := false
            tp_armed   := false
            auto_sl    := 0.0
            sl_touched := false
        if not armed
            n_closes_met := false
        else if barstate.isconfirmed
            if bar_index >= armed_bar + CLOSE_COUNT - 1 and n_closes_below(TRIGGER_LEVEL)
                n_closes_met := not dyna_ok_short
            else
                n_closes_met := false
    else  // short position open
        if high > TRIGGER_LEVEL
            sl_touched := true
        if sl_touched and not ev_sl and not ev_tp and n_closes_below(TRIGGER_LEVEL)
            sl_touched := false
        if sl_active and not ev_tp and (SL_MODE == 'Touch' ? high > SL_LEVEL : SL_MODE == 'ATR' ? high > SL_LEVEL + DYNA_THRESHOLD * dyna_atr : n_closes_above(SL_LEVEL + DYNA_THRESHOLD * dyna_atr))
            ev_sl    := true
            in_pos   := false
            tp_armed := false
            auto_sl  := 0.0
        if tp_active and TP_MODE == 'Touch' and not ev_sl and not tp_armed and low < TP_LEVEL
            ev_tp    := true
            in_pos   := false
            tp_armed := false
            auto_sl  := 0.0
        if tp_active and TP_MODE == 'Close' and not ev_sl and not ev_tp and not tp_armed and low < TP_LEVEL
            tp_armed := true
            auto_sl  := TP_LEVEL
        if not sl_active and not tp_armed and not ev_tp
            bool _sl_n_close = n_closes_above(TRIGGER_LEVEL)
            bool _sl_dyna_ok = dyna_off or (close - TRIGGER_LEVEL) >= DYNA_THRESHOLD * dyna_atr
            if _sl_n_close and _sl_dyna_ok
                ev_sl        := true
                in_pos       := false
                tp_armed     := false
                auto_sl      := 0.0
                sl_dyna_wait := false
            else
                sl_dyna_wait := _sl_n_close and not _sl_dyna_ok
        if tp_armed and not ev_sl and n_closes_above(auto_sl)
            ev_tp    := true
            in_pos   := false
            tp_armed := false
            auto_sl  := 0.0

if ev_sl or ev_tp
    sl_touched   := false
    sl_dyna_wait := false
if ev_tp
    tp_fired := true
if ev_sl
    sl_fired := true

// =====================================================
// ALERTS
// alert() supports series strings (alertcondition does not)
// TradingView → Create Alert → Condition: "Any alert() function call"
// =====================================================
string msg_entry = buildAlertMsg(is_long ? 'BUY'  : 'SELL', 'ENTRY')
string msg_sl    = buildAlertMsg(is_long ? 'SELL' : 'BUY',  'SL')
string msg_tp    = buildAlertMsg(is_long ? 'SELL' : 'BUY',  'TP')

if ev_entry and not entry_sent
    if not alert_blocked
        alert(msg_entry, alert.freq_once_per_bar_close)
        entry_sent    := true
        entry_blocked := false
    else
        entry_sent    := false
        entry_blocked := true

if ev_sl
    if entry_sent
        alert(msg_sl, alert.freq_once_per_bar)
    entry_sent    := false
    entry_blocked := false

if ev_tp
    if entry_sent
        alert(msg_tp, TP_MODE == 'Touch' ? alert.freq_once_per_bar : alert.freq_once_per_bar_close)
    entry_sent    := false
    entry_blocked := false


// =====================================================
// VISUALS
// =====================================================
var line  trig_line    = na
var line  sl_line      = na
var line  atr_sl_line  = na
var line  atr_thr_line = na
var line  auto_sl_line = na
var line  tp_line      = na
var label state_lbl    = na
var label sl_lbl       = na
var label tp_lbl       = na

if barstate.islast
    line.delete(trig_line)
    line.delete(sl_line)
    line.delete(atr_sl_line)
    line.delete(atr_thr_line)
    line.delete(auto_sl_line)
    line.delete(tp_line)
    label.delete(state_lbl)
    label.delete(sl_lbl)
    label.delete(tp_lbl)
    trig_line    := na
    sl_line      := na
    atr_sl_line  := na
    atr_thr_line := na
    auto_sl_line := na
    tp_line      := na
    state_lbl    := na
    sl_lbl       := na
    tp_lbl       := na

    color purple = color.rgb(160, 32, 240)

    // ---- Trigger label
    string dyna_tag = dyna_on and dyna_atr > 0 and trigger_active
         ? '\nTRH [' + str.tostring(DYNA_THRESHOLD, FMT_DEC) + '/' + str.tostring(tf_atr_period) + ']: ' + str.tostring(DYNA_THRESHOLD * dyna_atr, '0.00') + (alert_blocked ? ' ⏰TL' : '')
         : (alert_blocked ? '\n⏰TL' : '')
    string n_tag      = ' [C' + str.tostring(CLOSE_COUNT) + ']'
    string trig_text = (sl_fired and not sl_active      ? 'SL FIRED' :
                        sl_fired                        ? 'IDLE' :
                        tp_fired                        ? 'IDLE' :
                        tp_armed                        ? 'IDLE' :
                        in_pos and entry_blocked and alert_blocked and sl_touched ? 'CAUTION ⚠ ALERT BLOCKED' + n_tag :
                        in_pos and entry_blocked and alert_blocked and is_long    ? 'LONG' + pos_tag + ' ▲ ⚠ ALERT BLOCKED' + n_tag :
                        in_pos and entry_blocked and alert_blocked                ? 'SHORT' + pos_tag + ' ▼ ⚠ ALERT BLOCKED' + n_tag :
                        in_pos and entry_blocked and sl_touched  ? 'CAUTION [⚠]' + n_tag :
                        in_pos and entry_blocked and is_long     ? 'LONG' + pos_tag + ' ▲ [⚠]' + n_tag :
                        in_pos and entry_blocked                 ? 'SHORT' + pos_tag + ' ▼ [⚠]' + n_tag :
                        in_pos and sl_dyna_wait and is_long ? 'WAIT ↓' + n_tag :
                        in_pos and sl_dyna_wait             ? 'WAIT ↑' + n_tag :
                        in_pos and sl_touched           ? 'CAUTION'   + n_tag :
                        in_pos and is_long              ? 'LONG' + pos_tag + ' ▲' + n_tag :
                        in_pos                          ? 'SHORT' + pos_tag + ' ▼' + n_tag :
                        armed and n_closes_met and dir_long   ? 'WAIT ▲' + n_tag :
                        armed and n_closes_met          ? 'WAIT ▼' + n_tag :
                        armed and dir_long   ? 'TOUCHED ▲' + n_tag :
                        armed                           ? 'TOUCHED ▼' + n_tag : (dir_long ? 'IDLE ▲' : 'IDLE ▼') + n_tag) + dyna_tag
    color trig_color = (sl_fired and not sl_active      ? purple :
                        sl_fired                        ? color.gray :
                        tp_fired                        ? color.gray :
                        tp_armed                        ? color.gray :
                        in_pos and entry_blocked        ? color.orange :
                        in_pos and sl_touched           ? color.orange :
                        in_pos and is_long              ? color.green :
                        in_pos                          ? color.red :
                        armed and n_closes_met and dir_long ? color.green :
                        armed and n_closes_met          ? color.red :
                        armed and dir_long   ? color.green :
                        armed                           ? color.red : color.gray)

    // ---- SL label
    string sl_mode_short = SL_MODE == 'Touch' ? ' [T]' : SL_MODE == 'ATR' ? ' [A]' : ' [C' + str.tostring(CLOSE_COUNT) + ']'
    string _blk_tag  = alert_blocked ? ' ⏰TL' : ''
    string sl_text   = (sl_fired                       ? 'SL FIRED' :
                        in_pos and is_long              ? 'ARMED ▼' + sl_mode_short + _blk_tag :
                        in_pos                          ? 'ARMED ▲' + sl_mode_short + _blk_tag : 'IDLE' + sl_mode_short)
    color sl_color   = (sl_fired   ? purple :
                        in_pos     ? color.rgb(180, 90, 0) : color.gray)

    // ---- TP label
    string tp_mode_tag = tp_active ? (TP_MODE == 'Touch' ? ' [T]' : ' [C' + str.tostring(CLOSE_COUNT) + ']') : ''
    string tp_text   = (tp_fired                       ? 'TP FIRED' :
                        tp_armed and is_long            ? 'SL ACTIVE ↑' + n_tag :
                        tp_armed                        ? 'SL ACTIVE ↓' + n_tag :
                        in_pos                          ? 'TP ACTIVE' + tp_mode_tag + _blk_tag : 'IDLE')
    color tp_color   = (tp_fired                       ? purple :
                        tp_armed and is_long            ? color.green :
                        tp_armed                        ? color.red :
                        in_pos and entry_blocked and alert_blocked ? color.orange :
                        in_pos                          ? color.green : color.gray)

    if trigger_active
        trig_line := line.new(
             x1 = math.max(0, bar_index - LINE_LOOKBACK), y1 = TRIGGER_LEVEL,
             x2 = bar_index,                              y2 = TRIGGER_LEVEL,
             extend = extend.right, color = trig_color, width = 1, style = line.style_dashed)
        state_lbl := label.new(
             x         = bar_index + 3,
             y         = TRIGGER_LEVEL,
             text      = trig_text,
             xloc      = xloc.bar_index,
             yloc      = yloc.price,
             color     = color.new(trig_color, LABEL_BG_TRANSP),
             textcolor = trig_color,
             style     = dir_long ? label.style_label_upper_left : label.style_label_lower_left,
             size      = size.normal)

    if sl_active and not (in_pos and tp_armed)
        sl_line := line.new(
             x1 = math.max(0, bar_index - LINE_LOOKBACK), y1 = SL_LEVEL,
             x2 = bar_index,                              y2 = SL_LEVEL,
             extend = extend.right, color = sl_color, width = 1, style = line.style_solid)
        sl_lbl := label.new(
             x         = bar_index + 2,
             y         = SL_LEVEL,
             text      = sl_text,
             xloc      = xloc.bar_index,
             yloc      = yloc.price,
             color     = color.new(sl_color, LABEL_BG_TRANSP),
             textcolor = sl_color,
             style     = dir_long ? label.style_label_upper_left : label.style_label_lower_left,
             size      = size.small)

    if sl_active and (SL_MODE == 'ATR' or SL_MODE == 'Close') and dyna_on and in_pos and not tp_armed
        float atr_sl_level = is_long ? SL_LEVEL - DYNA_THRESHOLD * dyna_atr : SL_LEVEL + DYNA_THRESHOLD * dyna_atr
        atr_sl_line := line.new(
             x1 = math.max(0, bar_index - LINE_LOOKBACK), y1 = atr_sl_level,
             x2 = bar_index,                              y2 = atr_sl_level,
             extend = extend.right, color = color.red, width = 1, style = line.style_dashed)
    else if not sl_active and in_pos and not tp_armed and dyna_on and trigger_active
        float atr_sl_level = is_long ? TRIGGER_LEVEL - DYNA_THRESHOLD * dyna_atr : TRIGGER_LEVEL + DYNA_THRESHOLD * dyna_atr
        atr_sl_line := line.new(
             x1 = math.max(0, bar_index - LINE_LOOKBACK), y1 = atr_sl_level,
             x2 = bar_index,                              y2 = atr_sl_level,
             extend = extend.right, color = color.red, width = 1, style = line.style_dashed)

    if not in_pos and trigger_active and dyna_on
        float atr_thr_level = dir_long ? TRIGGER_LEVEL + DYNA_THRESHOLD * dyna_atr : TRIGGER_LEVEL - DYNA_THRESHOLD * dyna_atr
        atr_thr_line := line.new(
             x1 = math.max(0, bar_index - LINE_LOOKBACK), y1 = atr_thr_level,
             x2 = bar_index,                              y2 = atr_thr_level,
             extend = extend.right, color = armed ? color.green : color.new(color.green, ATR_IDLE_TRANSP), width = 1, style = line.style_dotted)

    if auto_sl > 0.0
        auto_sl_line := line.new(
             x1 = math.max(0, bar_index - LINE_LOOKBACK), y1 = auto_sl,
             x2 = bar_index,                              y2 = auto_sl,
             extend = extend.right, color = color.yellow, width = 2, style = line.style_solid)

    if tp_active
        tp_line := line.new(
             x1 = math.max(0, bar_index - LINE_LOOKBACK), y1 = TP_LEVEL,
             x2 = bar_index,                              y2 = TP_LEVEL,
             extend = extend.right, color = tp_color, width = 1, style = line.style_dashed)
        tp_lbl := label.new(
             x         = bar_index + 2,
             y         = TP_LEVEL,
             text      = tp_text,
             xloc      = xloc.bar_index,
             yloc      = yloc.price,
             color     = color.new(tp_color, LABEL_BG_TRANSP),
             textcolor = tp_color,
             style     = dir_long ? label.style_label_lower_left : label.style_label_upper_left,
             size      = size.small)


// =====================================================
// FRACTAL GRID
// =====================================================
fractalHigh1 = ta.highest(high, FRACTAL_STEP * 1)
fractalHigh2 = ta.highest(high, FRACTAL_STEP * 2)
fractalHigh3 = ta.highest(high, FRACTAL_STEP * 3)
fractalHigh4 = ta.highest(high, FRACTAL_STEP * 4)
fractalHigh5 = ta.highest(high, FRACTAL_STEP * 5)

fractalLow1 = ta.lowest(low, FRACTAL_STEP * 1)
fractalLow2 = ta.lowest(low, FRACTAL_STEP * 2)
fractalLow3 = ta.lowest(low, FRACTAL_STEP * 3)
fractalLow4 = ta.lowest(low, FRACTAL_STEP * 4)
fractalLow5 = ta.lowest(low, FRACTAL_STEP * 5)

var array<line> fractalHighLines     = array.new<line>()
var array<line> fractalLowLines      = array.new<line>()
var array<line> fractalHighGlowLines = array.new<line>()
var array<line> fractalLowGlowLines  = array.new<line>()

if SHOW_FRACTAL_GRID and barstate.islast
    for l in fractalHighLines
        line.delete(l)
    for l in fractalLowLines
        line.delete(l)
    for l in fractalHighGlowLines
        line.delete(l)
    for l in fractalLowGlowLines
        line.delete(l)

    array.clear(fractalHighLines)
    array.clear(fractalLowLines)
    array.clear(fractalHighGlowLines)
    array.clear(fractalLowGlowLines)

    fractalHighs = array.from(fractalHigh1, fractalHigh2, fractalHigh3, fractalHigh4, fractalHigh5)
    fractalLows  = array.from(fractalLow1,  fractalLow2,  fractalLow3,  fractalLow4,  fractalLow5)

    for i = 0 to FRACTAL_LEVELS - 1 by 1
        localFractalAlpha = 60 + i * 8
        localGlowAlpha    = 85 + i * 5
        recentFractalHigh = array.get(fractalHighs, i)
        if not na(recentFractalHigh)
            array.push(fractalHighGlowLines, line.new(bar_index - FRACTAL_LINE_BACK, recentFractalHigh, bar_index + FRACTAL_LINE_FWD, recentFractalHigh, color = color.new(color.red,   localGlowAlpha),    width = 3, style = line.style_solid))
            array.push(fractalHighLines,     line.new(bar_index - FRACTAL_LINE_BACK, recentFractalHigh, bar_index + FRACTAL_LINE_FWD, recentFractalHigh, color = color.new(color.red,   localFractalAlpha), width = 1, style = line.style_dashed))
        recentFractalLow = array.get(fractalLows, i)
        if not na(recentFractalLow)
            array.push(fractalLowGlowLines, line.new(bar_index - FRACTAL_LINE_BACK, recentFractalLow,  bar_index + FRACTAL_LINE_FWD, recentFractalLow,  color = color.new(color.green, localGlowAlpha),    width = 3, style = line.style_solid))
            array.push(fractalLowLines,     line.new(bar_index - FRACTAL_LINE_BACK, recentFractalLow,  bar_index + FRACTAL_LINE_FWD, recentFractalLow,  color = color.new(color.green, localFractalAlpha), width = 1, style = line.style_dashed))

// =====================================================
// EMA OVERLAY  (optional)
// =====================================================
float ema_fast = ta.ema(close, EMA_FAST_LEN)
float ema_slow = ta.ema(close, EMA_SLOW_LEN)

color _ema_green = color.rgb(14, 126, 72)
color _ema_red   = color.rgb(230, 30, 30)

color ema_fast_color = ema_fast > ema_fast[1] ? _ema_green : ema_fast < ema_fast[1] ? _ema_red : color.blue
color ema_slow_color = ema_slow > ema_slow[1] ? _ema_green : ema_slow < ema_slow[1] ? _ema_red : color.blue
color ema_fill_color = ema_slow > ema_slow[1] ? color.rgb(252, 255, 253) : ema_slow < ema_slow[1] ? color.rgb(250, 245, 245) : color.rgb(244, 244, 247)

EMA1 = plot(SHOW_EMA ? ema_fast : na, title = 'EMA fast', style = plot.style_linebr, linewidth = 2, color = ema_fast_color)
EMA2 = plot(SHOW_EMA ? ema_slow : na, title = 'EMA slow', style = plot.style_linebr, linewidth = 2, color = ema_slow_color)
fill(EMA1, EMA2, color = SHOW_EMA ? ema_fill_color : na)

bool _ema_cross      = ta.cross(ema_fast, ema_slow)
bool _ema_up_start   = ema_fast > ema_slow and ema_fast[1] <= ema_slow[1]
bool _ema_down_start = ema_fast < ema_slow and ema_fast[1] >= ema_slow[1]

plotshape(SHOW_EMA and _ema_cross, style = shape.cross,     size = size.tiny,  location = location.abovebar, color = color.black)
plotshape(SHOW_EMA and _ema_up_start,                style = shape.labelup,   size = size.small, location = location.bottom,   color = color.green)
plotshape(SHOW_EMA and _ema_down_start,              style = shape.labeldown, size = size.small, location = location.top,      color = color.red)
````
