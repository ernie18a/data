# maXXit SoC/TP [V1.0]

- url: https://www.tradingview.com/script/AHse78bL-maXXit-SoC-TP-V1-0/
- type: indicator
- pine_id: PUB;903a5f6b35e44614870d35c3eeb6c13b
- version: 6.0

## Description

maXXit SoC/TP [V1.0] — Stop on Close & Take Profit

Sends a JSON webhook alert as soon as N consecutive candles close through a configured Stop Loss or Take Profit level. No intrabar triggering — based exclusively on the bar's closing price.

─────────────────────────────────────
FEATURES
─────────────────────────────────────
• Stop Loss and Take Profit configurable independently (0 = disabled)
• Configurable number of closes required (1–3) before the alert fires
• JSON webhook format compatible with IBKR (FUT/STK) and CFD brokers (OANDA, IG Markets)
• Built-in instrument mapping: MNQ, MES, MYM, FXXP, FSXE, MGC, MCL, MNG, MHG, ZW, ZN, 10Y, EURUSD
• Lock to Symbol: indicator stays locked to the configured instrument across symbol changes
• Fires exactly once per level — re-arms automatically when the price is changed
• Red dashed line = Stop Loss | Green dashed line = Take Profit | Gray = triggered

─────────────────────────────────────
SETUP
─────────────────────────────────────
1. Add the indicator to your chart
2. Account & Broker: configure Webhook Secret, Account ID and Trade Type (FUT / STK / CFD)
3. Stop on Close: set Direction, Stop Price, TP Price, Quantity and Closes required
4. Lock to Symbol: enter the ticker prefix once (e.g. FXXP, MNQ)
   → A hint label on the chart shows the recommended value while this field is empty
5. Create a TradingView alert:
   → Condition: maXXit SoC/TP [V1.0]  →  Any alert() function call
   → Notifications: enter your Webhook URL
   → Click Create

The alert then runs entirely server-side — regardless of whether TradingView is open in the browser.

─────────────────────────────────────
NOTES
─────────────────────────────────────
Orders are sent as MKT with IOC (Immediate or Cancel) and outsideRth = true.
Webhook format and instrument parameters are compatible with the maXXit EMA V6 system.

## Source Code

````pine
//@version=6
indicator('maXXit LevelTRG [V6 2.0]',
        overlay = true,
        max_bars_back = 500,
        max_labels_count = 100,
        max_lines_count = 100)

// LEVEL TRIGGER - arm on price touch, enter on N closes through level, TP/SL same logic
// Mirror trade: JSON alerts via alert() on every signal
// copyright maXXit consulting, 2026 - all rights reserved

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
var string matched_prefix = ''

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
// OANDA SYMBOL MAPPING
// =====================================================
mapToOanda(string sym) =>
    [x_symbol, x_size, x_limit] = switch sym
        "NAS100_USD" => ["NAS100_USD", 2, 1]
        "US30_USD"   => ["US30_USD",   2, 1]
        "SPX500_USD" => ["SPX500_USD", 2, 1]
        "EU50_EUR"   => ["EU50_EUR",   1, 1]
        "CN50_USD"   => ["CN50_USD",   1, 1]
        "USB10Y_USD" => ["USB10Y_USD", 0, 3]
        "XAU_USD"    => ["XAU_USD",    1, 3]
        "XCU_USD"    => ["XCU_USD",    0, 4]
        "WTICO_USD"  => ["WTICO_USD",  0, 2]
        "NATGAS_USD" => ["NATGAS_USD", 0, 3]
        "WHEAT_USD"  => ["WHEAT_USD",  0, 3]
        "EUR_USD"    => ["EUR_USD",    0, 3]
        "ETH_USD"    => ["ETH_USD",    2, 0]
        "BTC_USD"    => ["BTC_USD",    3, 0]
        => [sym, 0, 0]
    [x_symbol, x_size, x_limit]

// =====================================================
// IG MARKETS SYMBOL MAPPING
// =====================================================
mapToIG(string sym) =>
    upper_sym = str.upper(sym)
    [x_symbol, x_size, x_minsize, x_limit] = switch upper_sym
        "STXE"       => ["IX.D.STXE.IFM.IP",     1, 0.5,  1]
        "DOW"        => ["IX.D.DOW.IFM.IP",       1, 0.5,  1]
        "SPTRD"      => ["IX.D.SPTRD.IFM.IP",     2, 0.04, 2]
        "NASDAQ"     => ["IX.D.NASDAQ.IFM.IP",    1, 0.5,  1]
        "SPOTGOLD"   => ["CS.D.CFDGOLD.CFM.IP",   2, 0.1,  2]
        "COPPER"     => ["CS.D.COPPER.MINI.IP",    2, 0.25, 1]
        "SILVER"     => ["CS.D.CFDSILVER.CFM.IP",  2, 0.1,  3]
        "USOIL"      => ["CC.D.CL.UNC.IP",         2, 0.01, 1]
        "NATURALGAS" => ["CC.D.NG.UNC.IP",          2, 2.0,  0]
        "ETHUSD"     => ["CS.D.ETHUSD.CFD.IP",     1, 0.03, 1]
        "BITCOIN"    => ["CS.D.BITCOIN.CFD.IP",     1, 1.0,  1]
        => [sym, 1, 0.1, 0]
    [x_symbol, x_size, x_minsize, x_limit]

// =====================================================
// ACCOUNT & BROKER
// =====================================================
group_acct = '🔑 Account & Broker'

SEND_JSON  = input.bool(true, '📡 Send JSON Alert', group = group_acct,
             tooltip = 'Disabled → plain-text alert instead of JSON')
TOKEN_ID   = input.string('', '🔐 Webhook Secret', group = group_acct)
CLIENT_ID  = input.string('', '😎 Account ID',     group = group_acct,
             options = ['','DU','U','OANDA','IG_MARKETS','None'])

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
               tooltip = 'Leave blank to use Exchange (syminfo.prefix) as primary exchange.')

string man_pxchange = MAN_PXCHANGE == '' ? man_exchange : MAN_PXCHANGE

// =====================================================
// DERIVED BROKER FIELDS
// =====================================================
string eff_instr_type = MIRROR_TRD == 'YES' ? INSTR_TRD : 'FUT'

bool is_cfd   = eff_instr_type == 'CFD'
bool is_stk   = eff_instr_type == 'STK'
bool is_oanda = CLIENT_ID      == 'OANDA'

[_ig_api_sym, _ig_dot_s, _ig_min_s, _ig_dot_l] = mapToIG(ig_symbol)
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
// MIRROR INSTRUMENT PRICE FETCH
// =====================================================
string _m_sym = stk_symbol != '' ? stk_symbol : syminfo.ticker
string _m_xch = stk_xChange != '' ? stk_xChange : syminfo.prefix
float mirror_close = request.security(
     ticker.new(_m_xch, _m_sym, session.extended),
     timeframe.period, close,
     gaps      = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off)

// =====================================================
// LEVEL TRIGGER
// =====================================================
group_lt = '⚡ Level Trigger'

DIRECTION     = input.string('LONG', '📐 Direction', group = group_lt,
                options = ['LONG','SHORT'],
                tooltip = 'LONG:  arms on N closes below trigger → enters on N closes above → SL on N closes below\nSHORT: arms on N closes above trigger → enters on N closes below → SL on N closes above')
TRIGGER_LEVEL = input.float(0.0, '🎯 Trigger Level', group = group_lt, step = 0.02,
                tooltip = 'Set to 0 to disarm. Trigger-level stop applies after entry (N closes back through trigger).')
SL_LEVEL      = input.float(0.0, '🛑 Stop Loss Level', group = group_lt, step = 0.02,
                tooltip = 'Optional absolute stop. Fires intrabar on touch.\nLONG: place below Trigger. SHORT: place above Trigger.\nWhen set: replaces the trigger-level stop — only this absolute SL is active.\nWhen 0: trigger-level stop (N closes) is used instead.')
TP_LEVEL      = input.float(0.0, '✅ TP Level', group = group_lt, step = 0.02,
                tooltip = 'Set to 0 to disable TP. Position closes when price reverses back through TP with N closes.')
TP_MODE       = input.string('Close', '✅ TP Arm Mode', group = group_lt,
                options = ['Close','Touch'],
                tooltip = 'Touch: exits immediately on intrabar TP touch.\nClose: arms on N closes through TP, exits on N closes back.')
CLOSE_COUNT   = input.int(1, '🕯️ Closes required', group = group_lt, minval = 1, maxval = 3,
                tooltip = 'Consecutive closes required for arming, entry, SL and TP (close mode).')
LOCK_SYMBOL   = input.string('', '🔒 Lock to Symbol', group = group_lt,
                tooltip = 'Enter ticker prefix once (e.g. FXXP, MNQ).\nPersists across chart changes → trigger active on this instrument only.\nEmpty = active on any chart.\nNote: chart shows the recommended value while this field is empty.')
POS_LOCK      = input.string('Auto', '🔧 Active Position', group = group_lt,
                options = ['Auto', 'LONG', 'SHORT'],
                tooltip = 'Set to LONG or SHORT BEFORE changing TP/SL/Trigger mid-trade.\nPrevents state reset caused by Pine Script recalculation on input changes.\nReset to Auto after the trade closes.\nNote: tp_armed and auto_sl always reset — reach TP again to reactivate auto-stop.')

group_pos = '✅ Position Management'
SHOW_FRACTAL_GRID = input.bool(false, '🔲 Fractal Grid', group = group_pos)


// =====================================================
// DOT SIZE / FORMAT
// =====================================================
int _dot_size = 0
if is_cfd and is_oanda
    [_oa_sym, _oa_ds, _oa_dl] = mapToOanda(oa_symbol)
    _dot_size := _oa_ds
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
// ALERT MESSAGE BUILDER
// =====================================================
buildAlertMsg(string action, string x_type) =>
    string x_conid   = eff_conid > 0 ? str.tostring(eff_conid) : '0'
    string x_tif     = is_stk ? 'DAY' : 'IOC'
    string dtim      = str.format_time(timenow, "yyyy-MM-dd HH:mm:ss", "Europe/Berlin")
    string mkt_price = str.tostring(close, '0.0#')
    string cmt       = 'LT-' + x_type + '-' + DIRECTION + ' ' + dtim + ' - ' + mkt_price
    SEND_JSON
     ? '{"secret":"' + TOKEN_ID + '","account":"' + CLIENT_ID + '","conid":' + x_conid + ',"secType":"' + eff_secType + '","symbol":"' + eff_symbol + '","currency":"' + eff_currency + '","side":"' + action + '","orderType":"MKT","quantity":' + str_json_size + ',"price":0,"tif":"' + x_tif + '","exchange":"' + eff_exchange + '","primaryExchange":"' + eff_pxchange + '","outsideRth":true,"comment":"' + cmt + '"}'
     : 'LT-' + x_type + ' ' + DIRECTION + ' | Qty:' + str_json_size + ' | ' + mkt_price

// =====================================================
// STATE VARIABLES
// =====================================================
var bool  in_pos          = false
var bool  is_long         = false
var bool  armed            = false
var int   armed_bar        = na
var bool  tp_armed         = false
var float auto_sl          = 0.0
var bool  sl_touched       = false
var bool  pos_lock_applied  = false  // true after first restore; resets on recalc (input change)

var bool ev_entry = false
var bool ev_sl    = false
var bool ev_tp    = false
ev_entry := false
ev_sl    := false
ev_tp    := false

// =====================================================
// POS_LOCK RESTORE — once per recalculation cycle
// =====================================================
if barstate.isrealtime and not in_pos and not pos_lock_applied
    if POS_LOCK == 'LONG'
        in_pos  := true
        is_long := true
    else if POS_LOCK == 'SHORT'
        in_pos  := true
        is_long := false
    pos_lock_applied := true  // block re-apply until next recalculation

// =====================================================
// STATE MACHINE — realtime bars only
// =====================================================
if barstate.isrealtime and DIRECTION == 'LONG'
    if not in_pos
        if trigger_active and not armed and low < TRIGGER_LEVEL and POS_LOCK == 'Auto'
            armed     := true
            armed_bar := bar_index
        if armed and bar_index > armed_bar and n_closes_above(TRIGGER_LEVEL)
            ev_entry   := true
            in_pos     := true
            is_long    := true
            armed      := false
            tp_armed   := false
            auto_sl    := 0.0
            sl_touched := false
    else  // long position open
        if low < TRIGGER_LEVEL
            sl_touched := true
        if sl_active and not ev_tp and low < SL_LEVEL
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
        if not sl_active and not tp_armed and not ev_tp and n_closes_below(TRIGGER_LEVEL)
            ev_sl    := true
            in_pos   := false
            tp_armed := false
            auto_sl  := 0.0
        if tp_armed and not ev_sl and n_closes_below(auto_sl)
            ev_tp    := true
            in_pos   := false
            tp_armed := false
            auto_sl  := 0.0
else if barstate.isrealtime  // SHORT
    if not in_pos
        if trigger_active and not armed and high > TRIGGER_LEVEL and POS_LOCK == 'Auto'
            armed     := true
            armed_bar := bar_index
        if armed and bar_index > armed_bar and n_closes_below(TRIGGER_LEVEL)
            ev_entry   := true
            in_pos     := true
            is_long    := false
            armed      := false
            tp_armed   := false
            auto_sl    := 0.0
            sl_touched := false
    else  // short position open
        if high > TRIGGER_LEVEL
            sl_touched := true
        if sl_active and not ev_tp and high > SL_LEVEL
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
        if not sl_active and not tp_armed and not ev_tp and n_closes_above(TRIGGER_LEVEL)
            ev_sl    := true
            in_pos   := false
            tp_armed := false
            auto_sl  := 0.0
        if tp_armed and not ev_sl and n_closes_above(auto_sl)
            ev_tp    := true
            in_pos   := false
            tp_armed := false
            auto_sl  := 0.0

if ev_sl or ev_tp
    sl_touched := false

// =====================================================
// ALERTS
// alert() supports series strings (alertcondition does not)
// TradingView → Create Alert → Condition: "Any alert() function call"
// =====================================================
string msg_entry = buildAlertMsg(is_long ? 'BUY'  : 'SELL', 'ENTRY')
string msg_sl    = buildAlertMsg(is_long ? 'SELL' : 'BUY',  'SL')
string msg_tp    = buildAlertMsg(is_long ? 'SELL' : 'BUY',  'TP')

if ev_entry
    alert(msg_entry, alert.freq_once_per_bar)
if ev_sl
    alert(msg_sl, alert.freq_once_per_bar)
if ev_tp
    alert(msg_tp, TP_MODE == 'Touch' ? alert.freq_once_per_bar : alert.freq_once_per_bar_close)


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

if barstate.islast
    line.delete(trig_line)
    line.delete(sl_line)
    line.delete(auto_sl_line)
    line.delete(tp_line)
    label.delete(state_lbl)
    label.delete(sl_lbl)
    label.delete(tp_lbl)
    trig_line    := na
    sl_line      := na
    auto_sl_line := na
    tp_line      := na
    state_lbl    := na
    sl_lbl       := na
    tp_lbl       := na

    // ---- Trigger label
    string trig_text = (tp_armed                       ? 'IDLE' :
                        in_pos and sl_touched           ? 'CAUTION' :
                        in_pos and is_long              ? 'LONG ↑' :
                        in_pos                          ? 'SHORT ↓' :
                        armed and DIRECTION == 'LONG'   ? 'TOUCHED ↑' :
                        armed                           ? 'TOUCHED ↓' : 'IDLE')
    color trig_color = (tp_armed                       ? color.gray :
                        in_pos and sl_touched           ? color.orange :
                        in_pos and is_long              ? color.green :
                        in_pos                          ? color.red :
                        armed and DIRECTION == 'LONG'   ? color.green :
                        armed                           ? color.red : color.gray)

    // ---- SL label
    string sl_text   = (in_pos and is_long             ? 'ARMED ▼' :
                        in_pos                          ? 'ARMED ▲' :
                        armed and DIRECTION == 'LONG'   ? 'ARMED ▼' :
                        armed                           ? 'ARMED ▲' : 'IDLE')
    color sl_color   = (in_pos or armed) ? color.rgb(180, 90, 0) : color.gray

    // ---- TP label
    string tp_text   = (ev_tp                          ? 'TP CLOSED' :
                        tp_armed and is_long            ? 'SL ACTIVE ↑' :
                        tp_armed                        ? 'SL ACTIVE ↓' :
                        in_pos                          ? 'TP ACTIVE' : 'IDLE')
    color tp_color   = (ev_tp                          ? color.gray :
                        tp_armed and is_long            ? color.green :
                        tp_armed                        ? color.red :
                        in_pos                          ? color.green : color.gray)

    if trigger_active
        trig_line := line.new(
             x1 = math.max(0, bar_index - 499), y1 = TRIGGER_LEVEL,
             x2 = bar_index,                    y2 = TRIGGER_LEVEL,
             extend = extend.right, color = trig_color, width = 1, style = line.style_dashed)
        state_lbl := label.new(
             x         = bar_index,
             y         = TRIGGER_LEVEL,
             text      = trig_text,
             xloc      = xloc.bar_index,
             yloc      = yloc.price,
             color     = color.new(trig_color, 75),
             textcolor = trig_color,
             style     = label.style_label_left,
             size      = size.small)

    if sl_active and not (in_pos and tp_armed)
        sl_line := line.new(
             x1 = math.max(0, bar_index - 499), y1 = SL_LEVEL,
             x2 = bar_index,                    y2 = SL_LEVEL,
             extend = extend.right, color = sl_color, width = 1, style = line.style_solid)
        sl_lbl := label.new(
             x         = bar_index,
             y         = SL_LEVEL,
             text      = sl_text,
             xloc      = xloc.bar_index,
             yloc      = yloc.price,
             color     = color.new(sl_color, 75),
             textcolor = sl_color,
             style     = label.style_label_left,
             size      = size.small)

    if auto_sl > 0.0
        auto_sl_line := line.new(
             x1 = math.max(0, bar_index - 499), y1 = auto_sl,
             x2 = bar_index,                    y2 = auto_sl,
             extend = extend.right, color = color.yellow, width = 2, style = line.style_solid)

    if tp_active
        tp_line := line.new(
             x1 = math.max(0, bar_index - 499), y1 = TP_LEVEL,
             x2 = bar_index,                    y2 = TP_LEVEL,
             extend = extend.right, color = tp_color, width = 1, style = line.style_dashed)
        tp_lbl := label.new(
             x         = bar_index,
             y         = TP_LEVEL,
             text      = tp_text,
             xloc      = xloc.bar_index,
             yloc      = yloc.price,
             color     = color.new(tp_color, 75),
             textcolor = tp_color,
             style     = label.style_label_left,
             size      = size.small)


// =====================================================
// FRACTAL GRID
// =====================================================
fractalHigh1 = ta.highest(high, 10)
fractalHigh2 = ta.highest(high, 20)
fractalHigh3 = ta.highest(high, 30)
fractalHigh4 = ta.highest(high, 40)
fractalHigh5 = ta.highest(high, 50)

fractalLow1 = ta.lowest(low, 10)
fractalLow2 = ta.lowest(low, 20)
fractalLow3 = ta.lowest(low, 30)
fractalLow4 = ta.lowest(low, 40)
fractalLow5 = ta.lowest(low, 50)

var array<line> fractalHighLines     = array.new<line>()
var array<line> fractalLowLines      = array.new<line>()
var array<line> fractalHighGlowLines = array.new<line>()
var array<line> fractalLowGlowLines  = array.new<line>()

if SHOW_FRACTAL_GRID
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

    for i = 0 to 4 by 1
        localFractalAlpha = 60 + i * 8
        localGlowAlpha    = 85 + i * 5
        recentFractalHigh = array.get(fractalHighs, i)
        if not na(recentFractalHigh)
            array.push(fractalHighGlowLines, line.new(bar_index - 50, recentFractalHigh, bar_index + 10, recentFractalHigh, color = color.new(color.red,   localGlowAlpha),    width = 3, style = line.style_solid))
            array.push(fractalHighLines,     line.new(bar_index - 50, recentFractalHigh, bar_index + 10, recentFractalHigh, color = color.new(color.red,   localFractalAlpha), width = 1, style = line.style_dashed))
        recentFractalLow = array.get(fractalLows, i)
        if not na(recentFractalLow)
            array.push(fractalLowGlowLines, line.new(bar_index - 50, recentFractalLow,  bar_index + 10, recentFractalLow,  color = color.new(color.green, localGlowAlpha),    width = 3, style = line.style_solid))
            array.push(fractalLowLines,     line.new(bar_index - 50, recentFractalLow,  bar_index + 10, recentFractalLow,  color = color.new(color.green, localFractalAlpha), width = 1, style = line.style_dashed))
````
