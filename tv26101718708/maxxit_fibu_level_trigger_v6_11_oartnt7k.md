# maXXit Fibu Level Trigger [V6 1.1]

- url: https://www.tradingview.com/script/OARtNt7K-maXXit-Fibu-Level-Trigger-V6-1-1/
- type: indicator
- pine_id: PUB;6076b1d9fb9b4b49b062f1e42f46eb11
- version: 1.0

## Description

# maXXit Level Trigger [V6] — Overview

**Platform:** TradingView Pine Script v6 · Overlay indicator

---

## What does the Level Trigger do?

The Level Trigger automates trade entries and exits based on a freely configurable price level. False breakouts are filtered by an **N-closes confirmation** — only after N consecutive candles close through the level is an action triggered. The trigger fires json alerts to an external webhook server connected to a broker api (IBKR, OANDA, IG-Markets).
If the signal generation is based on future contracts (highly recommended), the mirror instruments are mapped through configurable parameters inside the script to the preconfigured broker api. The trigger does not fire position entries or exits inside Tradingview directly. A simple textmessage can also be sent.
---

## Flow (State Machine)

```
1. ARMING    — Price touches the trigger level from the opposite side (intrabar)
2. ENTRY     — N closes back through the level → BUY / SELL alert
3. POSITION  — Stop and TP monitor the open position
4. EXIT      — SL or TP fires → closing order alert
```

---

## Features

| Feature | Description |
|---|---|
| **Long & Short** | Both directions configurable |
| **N-Closes (1–3)** | Number of confirming closes required for each step |
| **Trigger-level stop** | N closes back through the trigger level = automatic stop exit. Active only when no Absolute SL is set. |
| **Absolute stop loss** | A separate SL level — fires immediately on intrabar touch, no close confirmation. When set, the trigger-level stop is deactivated. |
| **Take Profit** | Two-step exit: TP reached → reversal confirmed with N closes |
| **TP Touch mode** | Alternative: exit fires directly on intrabar touch of the TP level |
| **Trailing stop** | Auto-stop locks at the old TP level when TP is raised mid-trade |
| **JSON alerts** | Direct broker integration (IBKR, OANDA, IG Markets) |
| **Symbol mapping** | Pre-defined instrument parameters for 15+ futures/CFDs |
| **Lock to Symbol** | Trigger stays bound to the selected instrument across chart changes |
| **Position Lock** | Preserves position state when parameters are changed mid-trade |

---

## Stop Loss Logic — Three-tier hierarchy

The indicator uses a priority-based stop system. Only one tier is active at a time:

| Priority | Condition | Stop mechanism | Trigger |
|---|---|---|---|
| **1 — Absolute SL** | SL Level > 0 | Fixed price level | Intrabar touch — immediate, no close needed |
| **2 — Auto-SL (TP lock)** | TP reached → auto_sl set | Old TP level becomes new stop | N consecutive closes through the level |
| **3 — Trigger-level stop** | No SL, no auto_sl | N closes back through trigger | N consecutive closes |

### How tiers interact

- When **Absolute SL is set**: tiers 2 and 3 are deactivated. Only the intrabar stop is active.
- When **TP is reached**: the TP level locks as a trailing stop (`auto_sl`). The Absolute SL can now be removed — `auto_sl` takes over with N-close confirmation, behaving exactly like the original trigger-level stop did.
- When **neither SL nor auto_sl is active**: the trigger level itself acts as the stop (N closes back through it).

### After a stop fires

The trigger does not re-arm automatically. To re-activate, set a new Trigger Level value (changing the level resets all state).

---

## Worked Example — LONG, N = 2 closes

**Setup:** Direction = LONG · Trigger = 5000 · TP = 5100 · Closes required = 2

### Phase 1 — Entry

| Event | What happens |
|---|---|
| Price drops below 5000 (intrabar) | Trigger **arms** — indicator starts watching |
| Price rises, 2 consecutive closes above 5000 | **Entry alert fired** → BUY order sent · stop activates at 5000 |
| Price drops back, 2 closes below 5000 (before TP) | **Stop exit** → SELL alert · trigger deactivates |

### Phase 2a — TP exit (price reverses after TP)

| Event | What happens |
|---|---|
| Price rises through 5100 | TP **step 1**: level reached — indicator waits for reversal |
| Price falls back, 2 consecutive closes below 5100 | **TP exit alert** → SELL order sent · position closed |

### Phase 2b — Trailing stop (price keeps running above TP)

| Event | What happens |
|---|---|
| Price rises through 5100 | TP step 1 fires — stop **locks at 5100** (yellow line) |
| Price continues above 5100 — no reversal | Position stays open · stop remains at 5100 |
| User raises TP to 5200 | `tp_armed` resets · stop stays locked at old 5100 level |
| Price reaches 5200 | Stop locks at 5200 — old 5100 stop replaced |
| Price falls, 2 closes below 5200 | **Stop exit alert** → SELL order sent · position closed |

> The locked stop (old TP level) works exactly like the trigger-level stop: N consecutive closes through the level fire the exit. The Absolute SL input can be cleared once the stop is locked — it is no longer needed.

---

## Visual Display

- **Trigger line** — gray (idle) · orange (armed) · red (position open = active stop level)
- **SL line** — shows absolute stop level with synchronized state label
- **TP line** — green (active) · yellow (TP armed, waiting for reversal)
- **Labels** — current state: IDLE / ARMED ↑↓ / active ▲▼ / fired

## Source Code

````pine
//@version=6
indicator('maXXit LevelTRG [V6 1.1 MP]', overlay = true, max_bars_back = 500)

// ██████╗ ██╗   ██╗ █████╗ ███╗   ██╗████████╗██╗   ██╗███╗   ███╗     █████╗ ██╗
// ██╔═══██╗██║   ██║██╔══██╗████╗  ██║╚══██╔══╝██║   ██║████╗ ████║    ██╔══██╗██║
// ██║   ██║██║   ██║███████║██╔██╗ ██║   ██║   ██║   ██║██╔████╔██║    ███████║██║
// ██║▄▄ ██║██║   ██║██╔══██║██║╚██╗██║   ██║   ██║   ██║██║╚██╔╝██║    ██╔══██║██║
// ╚██████╔╝╚██████╔╝██║  ██║██║ ╚████║   ██║   ╚██████╔╝██║ ╚═╝ ██║    ██║  ██║██║
//  ╚══▀▀═╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝    ╚═╝  ╚═╝╚═╝
// LEVEL TRIGGER - arm on N closes through level, enter on N closes back, TP/SL same logic
// copyright maXXit consulting, 2026 - all rights reserved

// =====================================================
// INSTRUMENT MAPPING  (same as EMA V6)
// Rules:
//   FUT / STK  → always IBKR  (conid from map;  STK: conid = 0)
//   CFD        → OANDA or IG_MARKETS (conid always 0)
// =====================================================
currentInstrument = syminfo.ticker

var string fut_xChange    = syminfo.prefix   // FUT exchange (IBKR)
var string stk_symbol     = ''               // STK symbol   (IBKR)
var string stk_xChange    = syminfo.prefix   // STK exchange (IBKR)
var string stk_pxChange   = syminfo.prefix   // STK primary exchange (IBKR)
var string oa_symbol      = ''               // CFD symbol Oanda  (e.g. EU50_EUR)
var string ig_symbol      = ''               // CFD symbol IG Markets
var string INSTR_CURR     = 'USD'
var string base_secType   = 'FUT'            // overridden for CASH / CRYPTO
var int    fut_conid      = 0                // FUT conid (IBKR only)
var string matched_prefix = ''               // instrument prefix from mapping

if str.startswith(currentInstrument, "MNQ")
    fut_xChange    := "CME"
    fut_conid      := 770561201
    stk_symbol     := "QQQ"
    stk_xChange    := "NASDAQ"
    stk_pxChange   := "NASDAQ"
    oa_symbol      := "NAS100_USD"
    ig_symbol      := "NASDAQ"
    matched_prefix := "MNQ"

else if str.startswith(currentInstrument, "MYM")
    fut_xChange    := "CBOT"
    fut_conid      := 793356180
    stk_symbol     := "DIA"
    stk_xChange    := "AMEX"
    stk_pxChange   := "ARCA"
    oa_symbol      := "US30_USD"
    ig_symbol      := "DOW"
    matched_prefix := "MYM"

else if str.startswith(currentInstrument, "MES")
    fut_xChange    := "CME"
    fut_conid      := 770561194
    stk_symbol     := "SPY"
    stk_xChange    := "AMEX"
    stk_pxChange   := "ARCA"
    oa_symbol      := "SPX500_USD"
    ig_symbol      := "SPTRD"
    matched_prefix := "MES"

else if str.startswith(currentInstrument, "FXXP")
    fut_xChange    := "EUREX"
    fut_conid      := 638120498
    stk_symbol     := "IMEU"
    stk_xChange    := "EURONEXT"
    stk_pxChange   := "AEB"
    oa_symbol      := "EU50_EUR"
    ig_symbol      := ""
    INSTR_CURR     := 'EUR'
    matched_prefix := "FXXP"

else if str.startswith(currentInstrument, "FSXE")
    fut_xChange    := "EUREX"
    fut_conid      := 816545383
    stk_symbol     := "IMEU"
    stk_xChange    := "EURONEXT"
    stk_pxChange   := "AEB"
    oa_symbol      := "EU50_EUR"
    ig_symbol      := "STXE"
    INSTR_CURR     := 'EUR'
    matched_prefix := "FSXE"

else if str.startswith(currentInstrument, "CN1")
    fut_xChange    := "SGX"
    fut_conid      := 847071984
    oa_symbol      := "CN50_USD"
    matched_prefix := "CN1"

else if str.startswith(currentInstrument, "MGC")
    fut_xChange    := "COMEX"
    fut_conid      := 706903676
    stk_symbol     := "GLD"
    stk_xChange    := "AMEX"
    stk_pxChange   := "ARCA"
    oa_symbol      := "XAU_USD"
    ig_symbol      := "SPOTGOLD"
    matched_prefix := "MGC"

else if str.startswith(currentInstrument, "MCL")
    fut_xChange    := "NYMEX"
    fut_conid      := 661016514
    stk_symbol     := "USO"
    stk_xChange    := "AMEX"
    stk_pxChange   := "ARCA"
    oa_symbol      := "WTICO_USD"
    ig_symbol      := "USOIL"
    matched_prefix := "MCL"

else if str.startswith(currentInstrument, "MNG")
    fut_xChange    := "NYMEX"
    fut_conid      := 699387166
    oa_symbol      := "NATGAS_USD"
    ig_symbol      := "NATURALGAS"
    matched_prefix := "MNG"

else if str.startswith(currentInstrument, "MHG")
    fut_xChange    := "COMEX"
    fut_conid      := 699387166
    oa_symbol      := "XCU_USD"
    ig_symbol      := "COPPER"
    matched_prefix := "MHG"

else if str.startswith(currentInstrument, "ZW")
    fut_xChange    := "CBOT"
    oa_symbol      := "WHEAT_USD"
    matched_prefix := "ZW"

else if str.startswith(currentInstrument, "ZN")
    fut_xChange    := "CBOT"
    fut_conid      := 792996527
    oa_symbol      := "USB10Y_USD"
    matched_prefix := "ZN"

else if str.startswith(currentInstrument, "10Y")
    fut_xChange    := "CBOT"
    fut_conid      := 835061422
    matched_prefix := "10Y"

else if str.startswith(currentInstrument, "EURUSD")
    fut_xChange    := "IDEALPRO"
    oa_symbol      := "EUR_USD"
    base_secType   := 'CASH'
    matched_prefix := "EURUSD"

else if currentInstrument == 'ETHUSD'
    base_secType   := 'CRYPTO'
    oa_symbol      := 'ETH_USD'
    ig_symbol      := 'ETHUSD'
    matched_prefix := 'ETHUSD'

else if currentInstrument == 'BTCUSD'
    base_secType   := 'CRYPTO'
    oa_symbol      := 'BTC_USD'
    ig_symbol      := 'BITCOIN'
    matched_prefix := 'BTCUSD'

// =====================================================
// IG MARKETS SYMBOL MAPPING  (short name → full API path)
// =====================================================
igApiSymbol(string sym) =>
    switch str.upper(sym)
        "STXE"       => "IX.D.STXE.IFM.IP"
        "DOW"        => "IX.D.DOW.IFM.IP"
        "SPTRD"      => "IX.D.SPTRD.IFM.IP"
        "NASDAQ"     => "IX.D.NASDAQ.IFM.IP"
        "SPOTGOLD"   => "CS.D.CFDGOLD.CFM.IP"
        "COPPER"     => "CS.D.COPPER.MINI.IP"
        "USOIL"      => "CC.D.CL.UNC.IP"
        "NATURALGAS" => "CC.D.NG.UNC.IP"
        "ETHUSD"     => "CS.D.ETHUSD.CFD.IP"
        "BITCOIN"    => "CS.D.BITCOIN.CFD.IP"
        => sym

// =====================================================
// ACCOUNT & BROKER
// =====================================================
group_acct = '🔑 Account & Broker'

SEND_JSON  = input.bool(true, '📡 Send JSON Alert', group = group_acct,
             tooltip = 'Disabled → plain-text alert instead of JSON')
TOKEN_ID   = input.string('', '🔐 Webhook Secret', group = group_acct)
CLIENT_ID  = input.string('', '😎 Account ID',     group = group_acct,
             options = ['','DUO940014','U3103575','OANDA','IG_MARKETS','None'])
INSTR_TYPE = input.string('FUT', '📦 Instrument Type', group = group_acct,
             options = ['FUT', 'STK', 'CFD'],
             tooltip = 'FUT / STK → IBKR\nCFD → OANDA or IG_MARKETS (set Account ID accordingly)\nIgnored in manual instrument mode.')

// hardcoded: ORDER_TYPE = MKT, TIF = IOC, outsideRth = true

// =====================================================
// INSTRUMENT CONFIG  (manual override when not in mapping)
// =====================================================
group_instr = '📋 Instrument'

USE_MAPPING  = input.bool(true, '📌 Use predefined mapping', group = group_instr,
               tooltip = 'ON: instrument params from built-in mapping table\nOFF: auto-read from chart — only conid and primary exchange need manual input')

// Manual mode — read directly from chart (no user input required)
string man_symbol   = syminfo.ticker
string man_currency = syminfo.currency
string man_exchange = syminfo.prefix
string man_sectype  = syminfo.type == 'futures' ? 'FUT' : syminfo.type == 'stock' ? 'STK' : syminfo.type == 'forex' ? 'CASH' : syminfo.type == 'crypto' ? 'CRYPTO' : 'FUT'

// Manual mode — only these two fields need manual input
MAN_CONID    = input.int(0,   '🆔 conid',            group = group_instr,
               tooltip = 'IB contract ID. Only needed for IBKR FUT. Set 0 to omit.')
MAN_PXCHANGE = input.string("", '🏛️ Primary Exchange', group = group_instr,
               options = ["", "OANDA", "IG_MARKETS","EURONEXT", "EUREX", "CBOT", "COMEX", "NYMEX", "NASDAQ", "AMEX", "ARCA"],
               tooltip = 'Leave blank to use Exchange (syminfo.prefix) as primary exchange.')

// Resolve primary exchange: blank → fall back to exchange
string man_pxchange = MAN_PXCHANGE == '' ? man_exchange : MAN_PXCHANGE

// =====================================================
// DERIVED BROKER FIELDS
// =====================================================
bool is_cfd   = INSTR_TYPE == 'CFD'
bool is_stk   = INSTR_TYPE == 'STK'
bool is_oanda = CLIENT_ID  == 'OANDA'

// --- mapped values (USE_MAPPING = true) ---
string map_secType  = base_secType != 'FUT' ? base_secType : INSTR_TYPE
string map_symbol   = is_cfd ? (is_oanda ? oa_symbol : igApiSymbol(ig_symbol)) : is_stk ? stk_symbol : currentInstrument
string map_exchange = is_cfd ? (is_oanda ? 'OANDA' : 'IG_MARKETS') : is_stk ? stk_xChange : fut_xChange
string map_pxchange = is_cfd ? map_exchange : is_stk ? stk_pxChange : fut_xChange
int    map_conid    = (is_stk or is_cfd) ? 0 : fut_conid
string map_currency = INSTR_CURR

// --- effective values: mapping OR auto-read from chart ---
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
                options = ['LONG', 'SHORT'],
                tooltip = 'LONG:  arms on N closes below trigger → enters on N closes above → SL on N closes below\nSHORT: arms on N closes above trigger → enters on N closes below → SL on N closes above')
TRIGGER_LEVEL = input.float(0.0, '🎯 Trigger Level', group = group_lt, step = 0.02,
                tooltip = 'Set to 0 to disarm. Trigger-level stop still applies after entry (N closes back through trigger).')
SL_LEVEL      = input.float(0.0, '🛑 Stop Loss Level', group = group_lt, step = 0.02,
                tooltip = 'Optional absolute stop loss. Set to 0 to disable.\nFires immediately on intrabar touch (no close required).\nLONG: place below Trigger Level.\nSHORT: place above Trigger Level.\nWhen set, the trigger-level stop (N closes) is deactivated — only this absolute SL applies.')
TP_LEVEL      = input.float(0.0, '✅ TP Level', group = group_lt, step = 0.02,
                tooltip = 'Set to 0 to disable TP. Position closes when price reverses back through TP with N closes.')
TP_MODE       = input.string('Close', '✅ TP Arm Mode', group = group_lt,
                options = ['Close', 'Touch'],
                tooltip = 'How the TP level is first reached (step 1 of 2):\nClose: N closes above/below TP level\nTouch: intrabar price touch (high/low)\nStep 2 always requires N closes back through TP.')
QTY           = input.float(1.0, '📦 Quantity', group = group_lt, step = 0.01, minval = 0.01)
CLOSE_COUNT   = input.int(1, '🕯️ Closes required', group = group_lt,
                minval = 1, maxval = 3, step = 1,
                tooltip = 'Number of consecutive closes required for each step:\narming, entry confirmation, SL and TP exit (step 2).\n1 = single close\n2 = two consecutive closes\n3 = three consecutive closes')
LOCK_SYMBOL   = input.string('', '🔒 Lock to Symbol', group = group_lt,
                tooltip = 'Enter ticker prefix once (e.g. FXXP, MNQ).\nPersists across chart changes → trigger active on this instrument only.\nEmpty = active on any chart.\nNote: chart shows the recommended value while this field is empty.')
POS_LOCK      = input.string('Auto', '🔧 Active Position', group = group_lt,
                options = ['Auto', 'LONG', 'SHORT'],
                tooltip = 'Set to LONG or SHORT BEFORE changing TP/SL/Trigger mid-trade.\nPrevents state reset caused by Pine Script recalculation on input changes.\nReset to Auto after the trade closes.\nNote: tp_armed and auto_sl always reset — reach TP again to reactivate auto-stop.')

// =====================================================
// CORE LOGIC
// =====================================================

// Declared here so top-level conditions below can reference them.
// Updated inside the state machine on each realtime bar.
var bool  tp_armed       = false
var float tp_armed_level = 0.0  // TP_LEVEL at the time tp_armed was set (detects user-raised TP)
var float auto_sl        = 0.0

// input.string values persist across chart changes (TradingView behaviour).
// This makes LOCK_SYMBOL a permanent lock: once set to FXXP it stays active
// after switching to MNQ → chart_matches = false → trigger inactive.
bool chart_matches   = LOCK_SYMBOL == '' or str.startswith(currentInstrument, LOCK_SYMBOL)
bool trigger_active  = TRIGGER_LEVEL > 0.0 and chart_matches
bool sl_active       = SL_LEVEL > 0.0 and chart_matches
bool tp_active       = TP_LEVEL > 0.0 and chart_matches

// N consecutive closes below trigger level
bool n_below_trigger = trigger_active and barstate.isconfirmed and
                       close    < TRIGGER_LEVEL and
                       (CLOSE_COUNT < 2 or close[1] < TRIGGER_LEVEL) and
                       (CLOSE_COUNT < 3 or close[2] < TRIGGER_LEVEL)

// N consecutive closes above trigger level
bool n_above_trigger = trigger_active and barstate.isconfirmed and
                       close    > TRIGGER_LEVEL and
                       (CLOSE_COUNT < 2 or close[1] > TRIGGER_LEVEL) and
                       (CLOSE_COUNT < 3 or close[2] > TRIGGER_LEVEL)

// Explicit SL level: fires immediately on intrabar touch (no close required)
bool n_below_sl = sl_active and DIRECTION == 'LONG'  and low  <= SL_LEVEL
bool n_above_sl = sl_active and DIRECTION == 'SHORT' and high >= SL_LEVEL

// TP step 1: price reaches TP level (Touch or N closes — configurable)
bool tp1_long_touch  = tp_active and DIRECTION == 'LONG'  and high >= TP_LEVEL
bool tp1_long_close  = tp_active and DIRECTION == 'LONG'  and barstate.isconfirmed and
                       close    > TP_LEVEL and
                       (CLOSE_COUNT < 2 or close[1] > TP_LEVEL) and
                       (CLOSE_COUNT < 3 or close[2] > TP_LEVEL)
bool tp1_long  = TP_MODE == 'Touch' ? tp1_long_touch  : tp1_long_close

bool tp1_short_touch = tp_active and DIRECTION == 'SHORT' and low  <= TP_LEVEL
bool tp1_short_close = tp_active and DIRECTION == 'SHORT' and barstate.isconfirmed and
                       close    < TP_LEVEL and
                       (CLOSE_COUNT < 2 or close[1] < TP_LEVEL) and
                       (CLOSE_COUNT < 3 or close[2] < TP_LEVEL)
bool tp1_short = TP_MODE == 'Touch' ? tp1_short_touch : tp1_short_close

// Auto-locked trailing SL: fires only when tp_armed=false (user raised TP, auto_sl = old TP level).
// When tp_armed=true, auto_sl = TP_LEVEL — TP step 2 (n_below_tp) handles the exit instead.
bool n_auto_sl_long  = auto_sl > 0.0 and not tp_armed and barstate.isconfirmed and
                       close < auto_sl and
                       (CLOSE_COUNT < 2 or close[1] < auto_sl) and
                       (CLOSE_COUNT < 3 or close[2] < auto_sl)

bool n_auto_sl_short = auto_sl > 0.0 and not tp_armed and barstate.isconfirmed and
                       close > auto_sl and
                       (CLOSE_COUNT < 2 or close[1] > auto_sl) and
                       (CLOSE_COUNT < 3 or close[2] > auto_sl)

// TP step 2: Close mode only — N closes back through TP level
bool n_below_tp = tp_active and barstate.isconfirmed and
                  close    < TP_LEVEL and
                  (CLOSE_COUNT < 2 or close[1] < TP_LEVEL) and
                  (CLOSE_COUNT < 3 or close[2] < TP_LEVEL)
bool n_above_tp = tp_active and barstate.isconfirmed and
                  close    > TP_LEVEL and
                  (CLOSE_COUNT < 2 or close[1] > TP_LEVEL) and
                  (CLOSE_COUNT < 3 or close[2] > TP_LEVEL)

// =====================================================
// STATE MACHINE
// =====================================================

// Gate: only trigger on realtime bars — prevents historical data from pre-loading state.
bool monitoring_active = barstate.isrealtime

var bool  in_pos           = false  // currently in a position
var bool  is_long          = false  // position direction
var bool  armed            = false  // trigger level breached in arming direction
var int   armed_bar_index  = na     // bar_index when armed was set (prevents same-bar arm+entry)
var bool  pos_lock_applied = false  // true after first restore; resets on recalc (input change)
var bool  sl_touched       = false  // price wicked into any stop level intrabar
var bool  sl_fired         = false  // SL exit fired (persists until next entry)
var bool  trigger_spent    = false  // true after SL exit — blocks re-arming; resets when TRIGGER_LEVEL is changed (recalc)
var bool  tp_fired         = false  // Touch-mode TP exit fired (persists until next entry)
var bool  tp_close_fired   = false  // Close-mode TP exit fired (persists until next entry)
// tp_armed and auto_sl declared in CORE LOGIC section

// Event flags — reset each bar, set inside state machine
var bool ev_entry = false
var bool ev_sl    = false
var bool ev_tp    = false
ev_entry := false
ev_sl    := false
ev_tp    := false

// Restore in_pos once per recalculation cycle only (pos_lock_applied resets on recalc/input change)
if barstate.isrealtime and not in_pos and not pos_lock_applied
    if POS_LOCK == 'LONG'
        in_pos  := true
        is_long := true
    else if POS_LOCK == 'SHORT'
        in_pos  := true
        is_long := false
    pos_lock_applied := true  // block re-apply until next recalculation

if monitoring_active
    if DIRECTION == 'LONG'
        if not in_pos
            if trigger_active and low <= TRIGGER_LEVEL and not armed and POS_LOCK == 'Auto' and not trigger_spent
                armed           := true
                armed_bar_index := bar_index
            if armed and n_above_trigger and bar_index > armed_bar_index
                ev_entry        := true
                in_pos          := true
                is_long         := true
                armed           := false
                tp_armed        := false
                tp_armed_level  := 0.0
                auto_sl         := 0.0
        else  // in long position
            // Step 1: TP level reached
            if not tp_armed and tp_active and tp1_long
                if TP_MODE == 'Touch'
                    if not ev_sl
                        ev_tp          := true
                        in_pos         := false
                        tp_armed       := false
                        tp_armed_level := 0.0
                        auto_sl        := 0.0
                else
                    tp_armed       := true
                    tp_armed_level := TP_LEVEL
                    auto_sl        := TP_LEVEL
            // Auto-reset tp_armed only when user raises TP_LEVEL above the arm level (auto_sl stays)
            if tp_armed and tp_active and TP_LEVEL > tp_armed_level
                tp_armed       := false
                tp_armed_level := 0.0
            // SL: trigger-level N closes, explicit SL intrabar, auto-SL N closes
            if not ev_tp and ((not sl_active and auto_sl == 0.0 and n_below_trigger) or (sl_active and n_below_sl) or n_auto_sl_long)
                ev_sl          := true
                in_pos         := false
                tp_armed       := false
                tp_armed_level := 0.0
                auto_sl        := 0.0
                armed          := false
                trigger_spent  := true
            // TP step 2: N closes back below TP level → TP exit
            if not ev_sl and tp_armed and n_below_tp
                ev_tp          := true
                in_pos         := false
                tp_armed       := false
                tp_armed_level := 0.0
                auto_sl        := 0.0

    else  // SHORT
        if not in_pos
            if trigger_active and high >= TRIGGER_LEVEL and not armed and POS_LOCK == 'Auto' and not trigger_spent
                armed           := true
                armed_bar_index := bar_index
            if armed and n_below_trigger and bar_index > armed_bar_index
                ev_entry        := true
                in_pos          := true
                is_long         := false
                armed           := false
                tp_armed        := false
                tp_armed_level  := 0.0
                auto_sl         := 0.0
        else  // in short position
            // Step 1: TP level reached
            if not tp_armed and tp_active and tp1_short
                if TP_MODE == 'Touch'
                    if not ev_sl
                        ev_tp          := true
                        in_pos         := false
                        tp_armed       := false
                        tp_armed_level := 0.0
                        auto_sl        := 0.0
                else
                    tp_armed       := true
                    tp_armed_level := TP_LEVEL
                    auto_sl        := TP_LEVEL
            // Auto-reset tp_armed only when user lowers TP_LEVEL below the arm level (auto_sl stays)
            if tp_armed and tp_active and TP_LEVEL < tp_armed_level
                tp_armed       := false
                tp_armed_level := 0.0
            // SL: trigger-level N closes, explicit SL intrabar, auto-SL N closes
            if not ev_tp and ((not sl_active and auto_sl == 0.0 and n_above_trigger) or (sl_active and n_above_sl) or n_auto_sl_short)
                ev_sl          := true
                in_pos         := false
                tp_armed       := false
                tp_armed_level := 0.0
                auto_sl        := 0.0
                armed          := false
                trigger_spent  := true
            // TP step 2: N closes back above TP level → TP exit
            if not ev_sl and tp_armed and n_above_tp
                ev_tp          := true
                in_pos         := false
                tp_armed       := false
                tp_armed_level := 0.0
                auto_sl        := 0.0

// Track intrabar stop touch and SL fire events
if monitoring_active
    if in_pos and is_long     and low  <= TRIGGER_LEVEL
        sl_touched := true
    if in_pos and not is_long and high >= TRIGGER_LEVEL
        sl_touched := true
    if ev_sl
        sl_fired   := true
        sl_touched := false
    if ev_tp and TP_MODE == 'Touch'
        tp_fired       := true
    if ev_tp and TP_MODE == 'Close'
        tp_close_fired := true
    if ev_entry
        sl_fired       := false
        sl_touched     := false
        tp_fired       := false
        tp_close_fired := false
    if ev_tp
        sl_fired   := false
        sl_touched := false

// =====================================================
// ALERT MESSAGES
// =====================================================
string entry_side = DIRECTION == 'LONG' ? 'BUY'  : 'SELL'
string exit_side  = DIRECTION == 'LONG' ? 'SELL' : 'BUY'
string str_qty    = str.tostring(QTY, '#.##')
string str_conid  = eff_conid > 0 ? str.tostring(eff_conid) : '0'
string mkt_close  = str.tostring(close, '#.##')
string dtim       = str.format_time(timenow, "yyyy-MM-dd HH:mm:ss", "Europe/Berlin")

string json_entry = '{"secret":"'+TOKEN_ID+'", "account":"'+CLIENT_ID+'", "conid":'+str_conid+', "secType":"'+eff_secType+'", "symbol":"'+eff_symbol+'", "currency":"'+eff_currency+'", "side":"'+entry_side+'","orderType":"MKT", "quantity":'+str_qty+',"price":0,"tif":"IOC", "exchange":"'+eff_exchange+'","primaryExchange":"'+eff_pxchange+'","outsideRth":true, "comment":"LT-ENTRY-'+DIRECTION+' '+dtim+' - '+mkt_close+'"}'
string json_sl    = '{"secret":"'+TOKEN_ID+'", "account":"'+CLIENT_ID+'", "conid":'+str_conid+', "secType":"'+eff_secType+'", "symbol":"'+eff_symbol+'", "currency":"'+eff_currency+'", "side":"'+exit_side+'","orderType":"MKT", "quantity":'+str_qty+',"price":0,"tif":"IOC", "exchange":"'+eff_exchange+'","primaryExchange":"'+eff_pxchange+'","outsideRth":true, "comment":"LT-SL-'+DIRECTION+' '+dtim+' - '+mkt_close+'"}'
string json_tp    = '{"secret":"'+TOKEN_ID+'", "account":"'+CLIENT_ID+'", "conid":'+str_conid+', "secType":"'+eff_secType+'", "symbol":"'+eff_symbol+'", "currency":"'+eff_currency+'", "side":"'+exit_side+'","orderType":"MKT", "quantity":'+str_qty+',"price":0,"tif":"IOC", "exchange":"'+eff_exchange+'","primaryExchange":"'+eff_pxchange+'","outsideRth":true, "comment":"LT-TP-'+DIRECTION+' '+dtim+' - '+mkt_close+'"}'

string plain_entry = 'LT Entry: '+DIRECTION+' | Level: '+str.tostring(TRIGGER_LEVEL)+' | Close: '+mkt_close
string plain_sl    = 'LT Stop:  '+DIRECTION+' | Level: '+str.tostring(TRIGGER_LEVEL)+' | Close: '+mkt_close
string plain_tp    = 'LT TP:    '+DIRECTION+' | TP: '+str.tostring(TP_LEVEL)+' | Close: '+mkt_close

// =====================================================
// VISUALS
// =====================================================
var line  trig_line    = na
var line  sl_line      = na
var line  auto_sl_line = na
var line  tp_line      = na
var label state_lbl    = na
var label sl_lbl       = na
var label tp_lbl       = na
var label lock_hint    = na

if barstate.islast
    line.delete(trig_line)
    line.delete(sl_line)
    line.delete(auto_sl_line)
    line.delete(tp_line)
    label.delete(state_lbl)
    label.delete(sl_lbl)
    label.delete(tp_lbl)
    label.delete(lock_hint)
    trig_line    := na
    sl_line      := na
    auto_sl_line := na
    tp_line      := na
    state_lbl    := na
    sl_lbl       := na
    tp_lbl       := na
    lock_hint    := na

    // shared state text and color (used by trigger label and SL label)
    string pos_arrow  = in_pos and is_long ? ' ▲' : in_pos and not is_long ? ' ▼' : ''
    string state_text = (in_pos and sl_touched and tp_armed    ? 'TOUCHED' + pos_arrow + ' — Stop locked' :
                         in_pos and sl_touched and auto_sl > 0 ? 'TOUCHED' + pos_arrow + ' — Stop locked' :
                         in_pos and sl_touched                 ? 'TOUCHED' + pos_arrow :
                         in_pos and tp_armed                   ? 'active' + pos_arrow + ' — Stop locked' :
                         in_pos and auto_sl > 0               ? 'active' + pos_arrow + ' — Stop locked' :
                         in_pos                               ? 'active' + pos_arrow :
                         armed and DIRECTION == 'LONG'        ? 'ARMED ↑' :
                         armed                                ? 'ARMED ↓' :
                         sl_fired                             ? 'fired' : 'IDLE')
    color state_color = (sl_fired   ? color.purple :
                         sl_touched ? color.red :
                         in_pos     ? color.orange :
                         armed      ? color.orange : color.gray)
    if trigger_active
        // trigger line: orange = armed, red = SL in long, green = SL in short, gray = idle
        color trig_color = armed ? color.orange : in_pos ? color.red : color.gray
        trig_line := line.new(
             x1 = math.max(0, bar_index - 499), y1 = TRIGGER_LEVEL,
             x2 = bar_index,                    y2 = TRIGGER_LEVEL,
             extend = extend.right, color = trig_color, width = 1, style = line.style_dashed)
        state_lbl := label.new(
             x = bar_index, y = TRIGGER_LEVEL,
             text      = state_text,
             xloc      = xloc.bar_index,
             yloc      = yloc.price,
             color     = color.new(state_color, 75),
             textcolor = state_color,
             style     = label.style_label_left,
             size      = size.small)
        if LOCK_SYMBOL == ''
            string hint_prefix = matched_prefix != '' ? matched_prefix : syminfo.ticker
            lock_hint := label.new(
                 x         = bar_index,
                 y         = TRIGGER_LEVEL,
                 text      = '🔒 ' + hint_prefix,
                 xloc      = xloc.bar_index,
                 yloc      = yloc.price,
                 color     = color.new(color.gray, 70),
                 textcolor = color.black,
                 style     = label.style_label_lower_left,
                 size      = size.small)

    if sl_active
        color sl_line_color = sl_fired   ? color.purple :
                             sl_touched ? color.red :
                             (in_pos or armed) ? color.orange : color.red
        sl_line := line.new(
             x1 = math.max(0, bar_index - 499), y1 = SL_LEVEL,
             x2 = bar_index,                    y2 = SL_LEVEL,
             extend = extend.right, color = sl_line_color, width = 1, style = line.style_solid)
        sl_lbl := label.new(
             x         = bar_index,
             y         = SL_LEVEL,
             text      = state_text,
             xloc      = xloc.bar_index,
             yloc      = yloc.price,
             color     = color.new(state_color, 75),
             textcolor = state_color,
             style     = label.style_label_left,
             size      = size.small)

    if auto_sl > 0.0
        auto_sl_line := line.new(
             x1 = math.max(0, bar_index - 499), y1 = auto_sl,
             x2 = bar_index,                    y2 = auto_sl,
             extend = extend.right, color = color.yellow, width = 2, style = line.style_solid)

    if tp_active
        color tp_color = tp_armed ? color.yellow : color.green
        tp_line := line.new(
             x1 = math.max(0, bar_index - 499), y1 = TP_LEVEL,
             x2 = bar_index,                    y2 = TP_LEVEL,
             extend = extend.right, color = tp_color, width = 1, style = line.style_dashed)
        bool tp_reached_visual = in_pos and tp_active and (DIRECTION == 'LONG' ? high >= TP_LEVEL : low <= TP_LEVEL)
        if in_pos and tp_armed
            tp_lbl := label.new(
                 x         = bar_index,
                 y         = TP_LEVEL,
                 text      = 'Stop locked',
                 xloc      = xloc.bar_index,
                 yloc      = yloc.price,
                 color     = color.new(color.yellow, 50),
                 textcolor = color.black,
                 style     = label.style_label_left,
                 size      = size.small)
        else if in_pos and tp_reached_visual
            tp_lbl := label.new(
                 x         = bar_index,
                 y         = TP_LEVEL,
                 text      = 'reached',
                 xloc      = xloc.bar_index,
                 yloc      = yloc.price,
                 color     = color.new(color.rgb(0, 140, 0), 75),
                 textcolor = color.rgb(0, 140, 0),
                 style     = label.style_label_left,
                 size      = size.small)
        else if in_pos and tp_active
            tp_lbl := label.new(
                 x         = bar_index,
                 y         = TP_LEVEL,
                 text      = 'active',
                 xloc      = xloc.bar_index,
                 yloc      = yloc.price,
                 color     = color.new(color.green, 75),
                 textcolor = color.green,
                 style     = label.style_label_left,
                 size      = size.small)
        else if tp_fired
            tp_lbl := label.new(
                 x         = bar_index,
                 y         = TP_LEVEL,
                 text      = 'triggered',
                 xloc      = xloc.bar_index,
                 yloc      = yloc.price,
                 color     = color.new(color.purple, 75),
                 textcolor = color.purple,
                 style     = label.style_label_left,
                 size      = size.small)
        else if tp_close_fired
            tp_lbl := label.new(
                 x         = bar_index,
                 y         = TP_LEVEL,
                 text      = 'reached',
                 xloc      = xloc.bar_index,
                 yloc      = yloc.price,
                 color     = color.new(color.rgb(0, 140, 0), 75),
                 textcolor = color.rgb(0, 140, 0),
                 style     = label.style_label_left,
                 size      = size.small)
        else
            tp_lbl := label.new(
                 x         = bar_index,
                 y         = TP_LEVEL,
                 text      = 'IDLE',
                 xloc      = xloc.bar_index,
                 yloc      = yloc.price,
                 color     = color.new(color.gray, 75),
                 textcolor = color.gray,
                 style     = label.style_label_left,
                 size      = size.small)

// =====================================================
// ALERTS
// alert() supports series strings (alertcondition does not)
// TradingView → Create Alert → Condition: "Any alert() function call"
// =====================================================
if ev_entry
    alert(SEND_JSON ? json_entry : plain_entry, alert.freq_once_per_bar_close)
if ev_sl
    alert(SEND_JSON ? json_sl : plain_sl, alert.freq_once_per_bar)
if ev_tp
    alert(SEND_JSON ? json_tp : plain_tp, TP_MODE == 'Touch' ? alert.freq_once_per_bar : alert.freq_once_per_bar_close)
````
