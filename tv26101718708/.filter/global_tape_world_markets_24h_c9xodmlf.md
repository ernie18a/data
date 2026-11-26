# Global Tape World Markets 24h

- url: https://www.tradingview.com/script/C9XOdmLF-Global-Tape-World-Markets-24h/
- type: indicator
- pine_id: PUB;35f98ed85f34466d977f1b3e029927be
- version: 2.0

## Description

Global Tape — World Markets on the 24-Hour Clock

Global Tape arranges the world's stock markets as a single horizontal strip, ordered by the time each market opens. Read left to right, the strip is a 24-hour clock: markets on the left traded earlier in the day, markets on the right trade later, and the cell in the middle — shown in brackets — is the market that is open right now. Because the trading day is a loop, the strip rotates through the session so the live market stays in the centre, with the close of one day meeting the open of the next at the edges.

The strip is built for an intraday chart. It shows today's session as it unfolds, so it is designed to be read on a timeframe of 60 minutes or lower. On a daily or higher chart it displays a notice instead of values.


WHAT EACH MARKET SHOWS

Every market occupies one column with three rows.

SETTLED is how that market's most recent full trading day finished, shown as its change for the day and held until the market trades again. The colour shows direction and strength: green shades for a market that finished up, red shades for one that finished down, and a neutral slate for little change. A deeper colour means the move was broad across the market's main stocks; a faded cell means one stock did most of the moving, so the colour represents the whole market less well.

FORWARD is the index future for that market — a price that trades before and around the cash session. It shows where the future is trading now, ahead of the market's open. Where a market has no widely-traded retail future, the cell is left blank rather than filled with a substitute.

PRE-MKT stays empty for most markets most of the time. A mark appears only in the short window before a market opens, and it shows how far that market's future has moved since the window began. Trading is usually thin in this window, so a value here reflects movement during a period of lighter activity. Hovering the cell also shows how the move compares with that market's normal range, so an ordinary move and an unusually large one can be told apart.

Beneath the three rows is a registration track that marks the position of the live market, so the strip reads as a continuous film of the trading day.


HEADER

The header names the strip and gives a plain count of how many markets are higher on the day. It is a fact to notice, not a conclusion.


HOW THE COLORS ARE BUILT

The SETTLED color combines three things. Direction and strength come from how many of a market's tracked stocks moved up versus down. A market with only one tracked index can show direction but not breadth, so its color is held to the softer shades — a single index cannot represent agreement across a market. Vividness reflects how evenly the move was spread: when one stock dominates, the cell is shown more faded, as a reminder that the colour represents fewer names.


DATA AND SETUP

The strip reads each market through its own data feed, so it does not require extended-hours trading to be enabled on your chart. It does require that your TradingView data plan includes the markets shown — international indices and futures (for example Tokyo, Frankfurt, Hong Kong, and the index futures). A market your plan does not cover will appear blank.

Several symbols are exposed as inputs so they can be adjusted to match your data feed. Index futures vary by subscription, and the US leader stocks shown in the tooltip can be changed as market leadership changes over time. The pre-open window length and the colour thresholds are also adjustable.


NOTES

This is a descriptive instrument. It shows what each market has done and where its future is trading; it does not generate signals or suggest actions. The session times adjust automatically for daylight saving in each region.

Built on Pine Script v6.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TrendMatrix_Labs (Visual Finesse Edition)
// ════════════════════════════════════════════════════════════════════════════
// GLOBAL TAPE — WORLD MARKETS ON THE 24-HOUR CLOCK
// ════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Global Tape — World Markets 24h (HUD)", shorttitle="GlobalTape", overlay=true)

// =============================================================================
// INPUTS — PREMIUM LAYOUT CONSTANTS
// =============================================================================
string t_pos = input.string("Top Center", "Dashboard Position",
     options=["Top Right","Top Center","Top Left","Bottom Right","Bottom Center","Bottom Left","Middle Right","Middle Left"], group="Layout Configuration")
string t_sz  = input.string("Normal", "HUD Typography Size", options=["Tiny","Small","Normal","Large"], group="Layout Configuration")

map_pos = switch t_pos
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right"  => position.bottom_right
    "Middle Left"   => position.middle_left
    "Middle Right"  => position.middle_right
    => position.top_right

map_sz = t_sz == "Tiny" ? size.tiny : t_sz == "Small" ? size.small : t_sz == "Large" ? size.large : size.normal

// Pre-market tuning parameters
int   pm_atr_lookback = input.int(3,  "Pre-mkt Move Bars (60m)", minval=1, maxval=24, group="Engine Tuning", tooltip="How many 60-min bars back to measure recent moves.")
int   pm_atr_len      = input.int(14, "Pre-mkt ATR Baseline",      minval=2, maxval=50, group="Engine Tuning", tooltip="ATR baseline used for volatility normalisation.")
float pm_win_frac     = input.float(0.05, "Pre-mkt Window Fraction", minval=0.01, maxval=0.5, step=0.01, group="Engine Tuning", tooltip="Pre-market opening window threshold.")
float pm_deep_thresh  = input.float(0.25, "Pre-mkt Alert Threshold %", minval=0.05, maxval=2.0, step=0.05, group="Engine Tuning", tooltip="Target variance to trigger deep indicator state.")

// =============================================================================
// SYMBOL INPUTS 
// =============================================================================
string sym_fut_us = input.symbol("CME_MINI:ES1!",      "S&P 500 Future",    group="Global Futures Feeds")
string sym_fut_jp = input.symbol("OSE:NK2251!",        "Nikkei Future",     group="Global Futures Feeds")
string sym_fut_de = input.symbol("EUREX:FDAX1!",       "DAX Future",        group="Global Futures Feeds")
string sym_fut_uk = input.symbol("ICEEUR:Z1!",         "FTSE 100 Future",   group="Global Futures Feeds")
string sym_fut_eu = input.symbol("EUREX:FESX1!",       "Euro Stoxx Future", group="Global Futures Feeds")
string sym_fut_hk = input.symbol("HKEX:HSI1!",         "Hang Seng Future",  group="Global Futures Feeds")
string sym_fut_fr = input.symbol("EURONEXT:FCE1!",     "CAC 40 Future",     group="Global Futures Feeds")
string sym_fut_au = input.symbol("ASX24:AP1!",         "SPI 200 Future",    group="Global Futures Feeds")
string sym_fut_in = input.symbol("NSEIX:NIFTY1!",      "GIFT Nifty Feed",   group="Global Futures Feeds")

string sym_bw1 = input.symbol("NASDAQ:NVDA", "US Bellwether Alpha", group="US Tech Vector (Rotational)")
string sym_bw2 = input.symbol("NASDAQ:AVGO", "US Bellwether Beta",  group="US Tech Vector (Rotational)")
string sym_bw3 = input.symbol("NYSE:ORCL",   "US Bellwether Gamma", group="US Tech Vector (Rotational)")
string sym_bw4 = input.symbol("NASDAQ:PLTR", "US Bellwether Delta", group="US Tech Vector (Rotational)")

// =============================================================================
// GRAPHICS DESIGN SYSTEM — ULTRA-DARK GLOW THEME
// =============================================================================
color C_BG      = input.color(#05070F, "Canvas Background", group="Aesthetics Theme") 
color C_CELL_BG = input.color(#0D111F, "Chip Background",   group="Aesthetics Theme") 
color C_HEAD    = input.color(#090C16, "Header Base",       group="Aesthetics Theme") 
color C_TXT     = input.color(#F1F5F9, "Primary Text",      group="Aesthetics Theme") 
color C_DIM     = input.color(#54647a, "Muted Details",     group="Aesthetics Theme") 
color C_SIG     = input.color(#00F0FF, "Signature Glow",    group="Aesthetics Theme") 
color C_ACT     = input.color(#FFB800, "Numeric Matrix",    group="Aesthetics Theme") 

color STEP_DD = input.color(#FF2A6D, "Heavy Momentum Down", group="HUD Heat Matrix Steps") 
color STEP_D  = input.color(#FF5E7E, "Moderate Down",        group="HUD Heat Matrix Steps") 
color STEP_M  = input.color(#395685, "Neutral Axis",         group="HUD Heat Matrix Steps") 
color STEP_U  = input.color(#00F5D4, "Moderate Up",          group="HUD Heat Matrix Steps") 
color STEP_UU = input.color(#05B993, "Heavy Momentum Up",   group="HUD Heat Matrix Steps") 

// =============================================================================
// CORE MATH & SECURITY RESOLUTION ENGINE
// =============================================================================
f_chg(string sym) =>
    [c, p] = request.security(sym, "1D", [close, close[1]], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
    (not na(c) and not na(p) and p != 0) ? (c - p) / p * 100.0 : 0.0

f_atr_mult(string sym) =>
    float m = request.security(sym, "60", (close - close[pm_atr_lookback]) / nz(ta.atr(pm_atr_len), 1.0), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
    nz(m, 0.0)

// Regional Data Channels
chg_nikkei = f_chg("INDEX:NKY")
chg_nkfut  = f_chg(sym_fut_jp)
chg_hsi    = f_chg("INDEX:HSI")
chg_asx    = f_chg("ASX:XJO")
chg_kospi  = f_chg("KRX:KOSPI")
chg_hynix  = f_chg("KRX:000660")
chg_sams   = f_chg("KRX:005930")
chg_sumco  = f_chg("TSE:3436")
chg_nifty  = f_chg("NSE:NIFTY")
chg_tadawul= f_chg("TADAWUL:TASI")
chg_sx5e   = f_chg("INDEX:SX5E")
chg_dax    = f_chg("XETR:DAX")
chg_cac    = f_chg("EURONEXT:PX1")
chg_ftse   = f_chg("FTSE:UKX")
chg_bist   = f_chg("BIST:XU100")
chg_es     = f_chg(sym_fut_us)
chg_nq     = f_chg("CME_MINI:NQ1!")
chg_vix    = f_chg("CBOE:VIX")
chg_nvda   = f_chg(sym_bw1)
chg_avgo   = f_chg(sym_bw2)
chg_orcl   = f_chg(sym_bw3)
chg_pltr   = f_chg(sym_bw4)

// Forward Multi-structures
fut_us = chg_es
fut_jp = chg_nkfut
fut_de = f_chg(sym_fut_de)
fut_uk = f_chg(sym_fut_uk)
fut_eu = f_chg(sym_fut_eu)
fut_hk = f_chg(sym_fut_hk)
fut_fr = f_chg(sym_fut_fr)
fut_au = f_chg(sym_fut_au)
fut_in = f_chg(sym_fut_in)

// Real-Time Volatility Vectors
amlt_us = f_atr_mult(sym_fut_us)
amlt_jp = f_atr_mult(sym_fut_jp)
amlt_de = f_atr_mult(sym_fut_de)
amlt_uk = f_atr_mult(sym_fut_uk)
amlt_eu = f_atr_mult(sym_fut_eu)
amlt_hk = f_atr_mult(sym_fut_hk)
amlt_fr = f_atr_mult(sym_fut_fr)
amlt_au = f_atr_mult(sym_fut_au)
amlt_in = f_atr_mult(sym_fut_in)

// =============================================================================
// CONTINENTAL GEOMETRY DATA MODEL
// =============================================================================
int NC = 12

f_label(int i) =>
    switch i
        0  => "JP"
        1  => "KR"
        2  => "HK"
        3  => "AU"
        4  => "IN"
        5  => "SA"
        6  => "TR"
        7  => "DE"
        8  => "FR"
        9  => "UK"
        10 => "EU"
        11 => "US"
        => "??"

// =============================================================================
// ROBUST TIMEZONE & MARKET OPEN ENGINE
// =============================================================================
f_tz(int i) =>
    switch i
        0  => "Asia/Tokyo"        // JP
        1  => "Asia/Seoul"        // KR
        2  => "Asia/Hong_Kong"    // HK
        3  => "Australia/Sydney"  // AU
        4  => "Asia/Kolkata"      // IN
        5  => "Asia/Riyadh"       // SA
        6  => "Europe/Istanbul"   // TR
        7  => "Europe/Berlin"     // DE
        8  => "Europe/Paris"      // FR
        9  => "Europe/London"     // UK
        10 => "Europe/Berlin"     // EU (Stoxx)
        11 => "America/New_York"  // US
        => "UTC"

// More complete opening times (many markets have exceptions)
f_open_hh(int i) =>
    switch i
        3  => 10  // AU Sydney
        4  => 9   // IN (GIFT/Nifty ~9:15, adjusted)
        5  => 10  // SA
        6  => 10  // TR
        9  => 8   // UK
        11 => 9   // US (9:30)
        => 9      // Default 09:00

f_open_mm(int i) =>
    switch i
        2  => 30  // HK
        4  => 15  // IN
        11 => 30  // US
        => 0

// More robust fractional open position (UTC day fraction)
f_cpos(int i) =>
    string tz   = f_tz(i)
    int    hh   = f_open_hh(i)
    int    mm   = f_open_mm(i)
    
    // Use current date in the *market's* timezone to handle DST correctly
    int y  = year(timenow, tz)
    int m  = month(timenow, tz)
    int d  = dayofmonth(timenow, tz)
    
    // Build timestamp for today's open in market tz
    int open_ts = timestamp(tz, y, m, d, hh, mm, 0)
    
    // Convert to UTC components for fractional day
    float utc_h = hour(open_ts, "UTC")
    float utc_m = minute(open_ts, "UTC")
    float frac  = (utc_h * 3600.0 + utc_m * 60.0) / 86400.0
    
    // Wrap-around normalization
    float r = frac + (i == 3 ? -0.0005 : i == 5 ? -0.0020 : i == 6 ? -0.0010 : 
                       i == 7 ? 0.0005 : i == 8 ? 0.0010 : i == 10 ? 0.0015 : 0.0)
    
    r < 0 ? r + 1.0 : (r > 1.0 ? r - 1.0 : r)

f_breadth(int i) =>
    array<float> v = array.new<float>()
    if i == 0
        array.push(v, chg_nikkei)
        array.push(v, chg_nkfut)
    else if i == 1
        array.push(v, chg_kospi)
        array.push(v, chg_hynix)
        array.push(v, chg_sams)
        array.push(v, chg_sumco)
    else if i == 2
        array.push(v, chg_hsi)
    else if i == 3
        array.push(v, chg_asx)
    else if i == 4
        array.push(v, chg_nifty)
    else if i == 5
        array.push(v, chg_tadawul)
    else if i == 6
        array.push(v, chg_bist)
    else if i == 7
        array.push(v, chg_dax)
    else if i == 8
        array.push(v, chg_cac)
    else if i == 9
        array.push(v, chg_ftse)
    else if i == 10
        array.push(v, chg_sx5e)
    else if i == 11
        array.push(v, chg_es)
        array.push(v, chg_nq)
        array.push(v, chg_nvda)
        array.push(v, chg_avgo)
        array.push(v, chg_orcl)
        array.push(v, chg_pltr)
        
    int up = 0
    int dn = 0
    float sa = 0.0
    float mx = 0.0
    int sz = array.size(v)
    if sz > 0
        for k = 0 to sz - 1
            float x = array.get(v, k)
            if x > 0.05
                up += 1
            else if x < -0.05
                dn += 1
            float ax = math.abs(x)
            sa += ax
            mx := math.max(mx, ax)
            
    float ratio = sz > 0 ? float(up - dn) / sz : 0.0
    float magn  = sz > 0 ? sa / sz : 0.0
    float conf = sz <= 1 ? 0.5 : (sa > 0 ? 1.0 - (mx / sa) : 0.5)
    float even_ceiling = sz > 1 ? 1.0 - 1.0 / sz : 1.0
    float conf_n = even_ceiling > 0 ? math.min(1.0, conf / even_ceiling) : 0.5
    [ratio, magn, sz, conf_n]

f_tip(int i) =>
    if i == 0
        "JAPAN TELEMETRY\nNikkei 225 Spot: " + str.tostring(chg_nikkei,"0.02") + "%\nNikkei Derivatives: " + str.tostring(chg_nkfut,"0.02") + "%"
    else if i == 1
        "KOREA TELEMETRY\nKOSPI Composite: " + str.tostring(chg_kospi,"0.02") + "%\nSK Hynix Vector: " + str.tostring(chg_hynix,"0.02") + "%\nSamsung Electronics: " + str.tostring(chg_sams,"0.02") + "%\nSumco Corp: " + str.tostring(chg_sumco,"0.02") + "%"
    else if i == 2
        "HONG KONG TELEMETRY\nHang Seng Index: " + str.tostring(chg_hsi,"0.02") + "%"
    else if i == 3
        "AUSTRALIA TELEMETRY\nASX 200 Index: " + str.tostring(chg_asx,"0.02") + "%"
    else if i == 4
        "INDIA TELEMETRY\nNIFTY 50 Index: " + str.tostring(chg_nifty,"0.02") + "%"
    else if i == 5
        "SAUDI ARABIA TELEMETRY\nTadawul Index: " + str.tostring(chg_tadawul,"0.02") + "%"
    else if i == 6
        "TURKEY TELEMETRY\nBIST 100 Index: " + str.tostring(chg_bist,"0.02") + "%"
    else if i == 7
        "GERMANY TELEMETRY\nDAX Performance Index: " + str.tostring(chg_dax,"0.02") + "%"
    else if i == 8
        "FRANCE TELEMETRY\nCAC 40 Index: " + str.tostring(chg_cac,"0.02") + "%"
    else if i == 9
        "UNITED KINGDOM TELEMETRY\nFTSE 100 Index: " + str.tostring(chg_ftse,"0.02") + "%"
    else if i == 10
        "EUROZONE TELEMETRY\nEuro Stoxx 50 Benchmark: " + str.tostring(chg_sx5e,"0.02") + "%"
    else
        "UNITED STATES VECTOR ENGINE:\n S&P500 ES: " + str.tostring(chg_es,"0.02") + "%\n Nasdaq NQ: " + str.tostring(chg_nq,"0.02") + "%\n\n Volatility VIX: " + str.tostring(chg_vix,"0.02") + "%\n\n " + sym_bw1 + ": " + str.tostring(chg_nvda,"0.02") + "\n " + sym_bw2 + ": " + str.tostring(chg_avgo,"0.02") + "\n " + sym_bw3 + ": " + str.tostring(chg_orcl,"0.02") + "\n " + sym_bw4 + ": " + str.tostring(chg_pltr,"0.02")

f_tone(float ratio, float magn, int ncomp) =>
    color out = STEP_M
    if ncomp >= 3
        out := ratio <= -0.6 ? STEP_DD : ratio <= -0.2 ? STEP_D  : ratio <   0.2 ? STEP_M  : ratio <   0.6 ? STEP_U  : STEP_UU
    else
        float signed_mag = ratio >= 0 ? magn : -magn
        out := signed_mag <= -0.5 ? STEP_D : signed_mag <   0.2 ? STEP_M : STEP_U
    out

f_vivid(color base, float conf) =>
    int transp = int(math.round((1.0 - conf) * 75.0))
    color.new(base, transp)

f_forward(int i) =>
    switch i
        0  => fut_jp
        2  => fut_hk
        3  => fut_au
        4  => fut_in
        7  => fut_de
        8  => fut_fr
        9  => fut_uk
        10 => fut_eu
        11 => fut_us
        => na

// Current UTC fractional position (more precise with seconds)
f_nowpos() =>
    int secs = hour(timenow, "UTC") * 3600 + minute(timenow, "UTC") * 60 + second(timenow, "UTC")
    float(secs) / 86400.0

f_premult(int i) =>
    switch i
        0  => amlt_jp
        2  => amlt_hk
        3  => amlt_au
        4  => amlt_in
        7  => amlt_de
        8  => amlt_fr
        9  => amlt_uk
        10 => amlt_eu
        11 => amlt_us
        => na

f_us_bellwethers() =>
    "\n\nSystem Core Movers: \n " + sym_bw1 + ": " + str.tostring(chg_nvda,"0.1") + "%\n " + sym_bw2 + ": " + str.tostring(chg_avgo,"0.1") +
     "%\n " + sym_bw3 + ": " + str.tostring(chg_orcl,"0.1") + "%\n " + sym_bw4 + ": " + str.tostring(chg_pltr,"0.1") + "%"

f_futname(int i) =>
    switch i
        0  => "Nikkei 225 Futures Network (OSE)"
        2  => "Hang Seng Derivatives Exchange (HKEX)"
        3  => "SPI 200 Index Link (ASX)"
        4  => "GIFT Nifty Offshore Liquidity"
        7  => "DAX Performance Stream (EUREX)"
        8  => "CAC 40 Vector Stream (EURONEXT)"
        9  => "FTSE 100 Index Gateway (ICE)"
        10 => "Euro Stoxx 50 Blue-Chip Link (EUREX)"
        11 => "S&P 500 E-Mini Core (CME)"
        => ": No widely-traded retail Futures"

f_premarket(int i) =>
    float np = f_nowpos()
    float fwd = f_cpos(i) - np
    fwd := fwd < 0 ? fwd + 1.0 : fwd
    fwd > 0.0 and fwd <= pm_win_frac

f_order() =>
    array<int>   idx = array.new<int>()
    array<float> pos = array.new<float>()
    for i = 0 to NC - 1
        array.push(idx, i)
        array.push(pos, f_cpos(i))
    for a = 0 to NC - 2
        int mn = a
        for b = a + 1 to NC - 1
            if array.get(pos, b) < array.get(pos, mn)
                mn := b
        if mn != a
            float tmp_p = array.get(pos, a)
            array.set(pos, a, array.get(pos, mn))
            array.set(pos, mn, tmp_p)
            int ti = array.get(idx, a)
            array.set(idx, a, array.get(idx, mn))
            array.set(idx, mn, ti)

    float np = f_nowpos()
    int gate_slot = 0
    float best = 2.0
    for s = 0 to NC - 1
        float bd = np - f_cpos(array.get(idx, s))
        bd := bd < 0 ? bd + 1.0 : bd
        if bd < best
            best := bd
            gate_slot := s

    int centre = NC / 2
    int shift  = gate_slot - centre
    array<int> rot = array.new<int>()
    for p = 0 to NC - 1
        int src = (p + shift) % NC
        src := src < 0 ? src + NC : src
        array.push(rot, array.get(idx, src))
    rot

f_gate(array<int> ordered) => NC / 2

// =============================================================================
// PRESENTATION LAYER — DESIGN ENGINE IMPLEMENTATION
// =============================================================================
// Core Canvas Instantiation: border_color matches C_BG to completely separate the grid into modular chips.
var table tb = table.new(map_pos, NC + 1, 5, bgcolor=C_BG, border_color=C_BG, border_width=4)

var array<float> pm_anchor = array.new<float>(NC, na)
var array<bool>  pm_armed  = array.new<bool>(NC, false)
var array<bool>  pm_clean  = array.new<bool>(NC, false)
var array<bool>  pm_waspre = array.new<bool>(NC, false)

f_fwd_tone(float fv) =>
    na(fv) ? na : fv <= -0.5 ? STEP_D : fv < 0.2 ? STEP_M : STEP_U

if barstate.islast and not timeframe.isintraday
    table.clear(tb, 0, 0, NC, 4)
    table.cell(tb, 0, 0, "Global Tape HUD requires intraday data streams (≤ 60min). Adjust active chart interval.",
         bgcolor=C_HEAD, text_color=C_TXT, text_size=size.normal, text_halign=text.align_left)
    table.merge_cells(tb, 0, 0, NC, 0)

if barstate.islast and timeframe.isintraday
    array<int> ordered = f_order()
    int gate_pos = f_gate(ordered)

    int n_up = 0
    for q = 0 to NC - 1
        [rq, mq, nq, cq] = f_breadth(q)
        if rq > 0.05
            n_up += 1

    // HUD Header Ribbon
    string ovw = "THE 24-HOUR MACRO METRIC TAPE\nVisualizes the international sequence of financial markets mapped relative to time. Reading Left to Right steps forward across the global session line.\n\nROW TELEMETRY CHANNELS\nSETTLED ➔ Daily closing baseline vectors.\nFORWARD ➔ Live-updating index derivatives value.\nPRE-MKT ➔ Active capture tracking immediately preceding localized market launch.\n\nThe tracking metrics serve strictly descriptive analytics, not algorithmic execution guidance."
    string head = "\n ✦  GLOBAL TAPE TELEMETRY NETWORK  ·  " + str.tostring(n_up) + " / " + str.tostring(NC) + " OVERWEIGHT BREADTH  ✦ "
    table.cell(tb, 0, 0, head, bgcolor=C_HEAD, text_color=C_SIG, text_size=size.normal, text_halign=text.align_center, tooltip=ovw)
    table.merge_cells(tb, 0, 0, NC, 0)

    // HUD Category Tracks (Column 0 labels)
    table.cell(tb, 0, 1, "SETTLED", bgcolor=C_HEAD, text_color=C_DIM, text_size=size.small, text_halign=text.align_right, tooltip="Historical session close state.")
    table.cell(tb, 0, 2, "FORWARD", bgcolor=C_HEAD, text_color=C_DIM, text_size=size.small, text_halign=text.align_right, tooltip="Active derivatives data feed indexing session expectations.")
    table.cell(tb, 0, 3, "PRE-MKT", bgcolor=C_HEAD, text_color=C_DIM, text_size=size.small, text_halign=text.align_right, tooltip="Captures volatility momentum changes inside the immediate launch envelope.")
    table.cell(tb, 0, 4, "", bgcolor=C_BG, text_size=size.small)

    for p = 0 to NC - 1
        int ci = array.get(ordered, p)
        int col = p + 1
        [ratio, magn, ncomp, conf] = f_breadth(ci)
        color tone_raw = f_tone(ratio, magn, ncomp)
        bool is_gate = (p == gate_pos)

        // --- Row 1: SETTLED CHIPS ---
        string lbl = f_label(ci)
        // Active Gate gets an solid electric badge treatment, others get high-end glassmorphic translucent colors.
        color cell_bg = is_gate ? C_SIG : color.new(tone_raw, 88)
        color text_bg = is_gate ? C_BG : tone_raw
        table.cell(tb, col, 1, lbl, bgcolor=cell_bg, text_color=text_bg, text_size=(is_gate ? size.large : map_sz), tooltip=f_tip(ci))

        // --- Row 2: FORWARD MATRIX CHIPS ---
        float fv = f_forward(ci)
        color fwd_color = na(fv) ? C_DIM : f_fwd_tone(fv)
        string fwd_lbl = na(fv) ? "—" : (fv >= 0 ? "+" : "") + str.tostring(fv, "0.0")
        table.cell(tb, col, 2, fwd_lbl, bgcolor=C_CELL_BG, text_color=fwd_color, text_size=map_sz, 
             tooltip=f_label(ci) + " Derivatives Feed: " + str.tostring(fv,"0.0") + "%\n" + f_futname(ci))

        // --- Row 3: PRE-MARKET MOMENTUM HUD ---
        bool pre = f_premarket(ci)
        float mult = f_premult(ci)
        bool was_pre = array.get(pm_waspre, ci)
        if pre and not na(fv) and not array.get(pm_armed, ci)
            array.set(pm_anchor, ci, fv)
            array.set(pm_armed,  ci, true)
            array.set(pm_clean,  ci, not was_pre)
            
        if not pre and array.get(pm_armed, ci)
            array.set(pm_armed,  ci, false)
            array.set(pm_anchor, ci, na)
            array.set(pm_clean,  ci, false)
            
        array.set(pm_waspre, ci, pre)
        
        float anch = array.get(pm_anchor, ci)
        bool clean = array.get(pm_clean, ci)
        float diff = (pre and not na(fv) and not na(anch)) ? fv - anch : na

        if pre and not na(diff)
            string arrow = diff >= 0 ? "↑" : "↓"
            string prov = clean ? "" : " ◦"
            string pm_lbl = arrow + " " + str.tostring(math.abs(diff), "0.0") + prov
            color pm_base_color = diff >= 0 ? STEP_U : STEP_D
            color pm_cell_glow = color.new(pm_base_color, 92) // Sleek glowing text halo
            string mult_txt = na(mult) ? "" : "\nVelocity Scale: " + str.tostring(math.abs(mult),"0.1") + "x local expected historical standard deviation."
            string bell_txt = ci == 11 ? f_us_bellwethers() : ""
            table.cell(tb, col, 3, pm_lbl, bgcolor=pm_cell_glow, text_color=pm_base_color, text_size=map_sz,
                 tooltip="Active Launch Pipeline:\n " + f_label(ci)+ " " + f_futname(ci) + "\n\nDelta since window initialization: " + str.tostring(diff,"0.02") + "%" + mult_txt + bell_txt)
        else
            table.cell(tb, col, 3, "—", bgcolor=C_CELL_BG, text_color=color.new(C_DIM, 60), text_size=map_sz)

        // --- Row 4: CHRONO REGISTRATION DOTS ---
        string hole = is_gate ? "●" : "◦"
        color holecol = is_gate ? C_SIG : color.new(C_DIM, 50)
        table.cell(tb, col, 4, hole, bgcolor=C_HEAD, text_color=holecol, text_size=size.small)
````
