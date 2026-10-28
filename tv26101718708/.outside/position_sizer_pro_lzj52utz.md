# Position Sizer Pro

- url: https://www.tradingview.com/script/lZJ52Utz-Position-Sizer-Pro/
- type: indicator
- pine_id: PUB;06fcc846f1ab44e59992bb0fc3215b07
- version: 2.0

## Description

[b]Position Sizer Pro
[/b]

[b]Universal position size calculator for TradingView. One script, all asset classes — no guesswork, no spreadsheet.[/b]

Enter your account equity, risk percentage, entry price, and stop loss. Position Sizer Pro tells you exactly how many lots, contracts, shares, or units to trade — floored to your broker's minimum tradeable increment, with risk calculated in your account currency regardless of what you're trading.

[b]What it handles
[/b]
[list]
[*]Forex — all majors, crosses, and exotics. Configurable minimum lot size (micro/mini/standard)
[*]Futures — contracts sized from mintick × pointvalue
[*]Stocks, ETFs, ADRs, Funds — whole shares
[*]Crypto — respects syminfo.mincontract for each pair
[*]CFDs, Indices, Bonds, Commodities — spot metals, energy, index CFDs
[*]Contract size override — for non-standard commodity CFDs (XAUUSD=100, XAGUSD=5000, USOIL=1000, etc.)
[/list]

[b]How it's different
[/b][b]Account currency aware[/b]. Two-leg FX resolution (instrument → USD → account) with a waterfall across FX and FX_IDC feeds, direct and inverse. Trade GBPJPY on an AUD account? Your risk shows in AUD, sized correctly.

[b]Conversion transparency.[/b] Every row shows the data source used ("FX direct", "IDC inverse", "Same CCY"). If no rate is available, it says so — no silent fallbacks producing plausible-looking but wrong numbers.

[b]TP ladder with R-multiples[/b]. TP1 (1:1), TP2 (1:2), TP3 (1:3) with prices, P&L in account currency, and dotted rays on the chart. Each TP independently toggleable.

[b]Guardrails that catch real mistakes[/b]. Warnings fire when:
[list]
[*]Position size falls below the minimum tradeable increment (shows equity needed)
[*]Stop loss is on the wrong side of entry for your chosen direction
[*]Required margin exceeds account equity
[*]Account currency is invalid
[*]Asset type is unsupported
[/list]

[b]Informational leverage.[/b] Enter your leverage to see margin required — but leverage never changes your position size. Risk-first by design.

[b]Clean, configurable UI
[/b]17-row table with price/P&L/info columns. Four position options (corners), dynamic price formatting derived from syminfo.mintick, dark theme with color-coded direction (blue/red).

[b]Under the hood
[/b]Pine Script v6. Pure, testable functions. All request.security calls at global scope per v6 requirements. State only in table/line handles. No magic numbers — everything reads from syminfo.*.

Built for traders who size by risk, not by feel.

## Source Code

````pine
//@version=6
indicator("Position Sizer Pro", overlay=true)

// ═══════════════════════════════════════════════════════════════════
// POSITION SIZER PRO — Pine Script v6
// Supports: Forex, Futures, Stocks, Crypto, CFD, Index, Fund, DR, Bond, Commodity
// No hardcoded currencies. All asset classes via syminfo.*.
// Leverage is informational only — does not affect position size.
// ═══════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────
// SECTION 1: INPUTS
// ─────────────────────────────────────────────

var string G1 = "💰 Account & Risk"
accountCurrency      = input.string("USD",   "Account Currency",
     tooltip="3-letter code e.g. USD, AUD, GBP", group=G1)
equity               = input.float(10000.0,  "Equity",   minval=1,              group=G1)
riskPct              = input.float(1.0,      "Risk (%)", minval=0.01, step=0.1, group=G1)
leverage             = input.float(0.0,      "Leverage (0 = not set)",
     minval=0.0, step=1,
     tooltip="Optional. Only shows margin required. Does not change position size.",
     group=G1)

var string G2 = "📍 Trade"
entryInput = input.float(0.0, "Entry Price", minval=0, step=0.00001, group=G2)
slInput              = input.float(0.0,  "Stop Loss Price", minval=0, step=0.00001, group=G2)
tradeDir             = input.string("Buy","Direction", options=["Buy","Sell"],       group=G2)

var string G3 = "🎯 Take Profit"
showTP1              = input.bool(true,  "Show TP1 (1:1 R)",      group=G3)
showTP2              = input.bool(true,  "Show TP2 (1:2 R)",      group=G3)
showTP3              = input.bool(false, "Show TP3 (1:3 R)",      group=G3)
showRays             = input.bool(true,  "Show TP rays on chart", group=G3)

var string G4 = "⚙️ Advanced"
contractSizeOverride = input.float(0.0, "Contract Size Override",
     minval=0, step=1,
     tooltip="0 = auto. Override for commodity CFDs: XAUUSD=100, XAGUSD=5000, USOIL=1000",
     group=G4)
forexMinLot          = input.float(0.01, "Forex Min Lot Size",
     minval=0.001, step=0.01,
     tooltip="Minimum tradeable lot increment. 0.01=micro (default), 0.1=mini, 1.0=standard-only",
     group=G4)

var string G5 = "🖥 Display"
tablePos             = input.string("Top Right", "Table Position",
     options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=G5)

// Normalize account currency: uppercase and strip whitespace.
// Rescues "usd", "Usd", " USD " typos from silent rate-lookup failures.
string accountCcyN = str.replace_all(str.upper(accountCurrency), " ", "")

// ─────────────────────────────────────────────
// SECTION 2: GLOBAL RATE FETCHES
// request.security() must be at global scope in Pine v6.
// Functions receive pre-fetched rates as parameters.
// ─────────────────────────────────────────────

string _l1_fxD_sym  = "FX:USD"     + syminfo.currency
string _l1_fxI_sym  = "FX:"        + syminfo.currency + "USD"
string _l1_idcD_sym = "FX_IDC:USD" + syminfo.currency
string _l1_idcI_sym = "FX_IDC:"    + syminfo.currency + "USD"

float  _l1_fxD  = request.security(_l1_fxD_sym,  timeframe.period, close, ignore_invalid_symbol=true)
float  _l1_fxI  = request.security(_l1_fxI_sym,  timeframe.period, close, ignore_invalid_symbol=true)
float  _l1_idcD = request.security(_l1_idcD_sym, timeframe.period, close, ignore_invalid_symbol=true)
float  _l1_idcI = request.security(_l1_idcI_sym, timeframe.period, close, ignore_invalid_symbol=true)

string _l2_fxD_sym  = "FX:USD"     + accountCcyN
string _l2_fxI_sym  = "FX:"        + accountCcyN + "USD"
string _l2_idcD_sym = "FX_IDC:USD" + accountCcyN
string _l2_idcI_sym = "FX_IDC:"    + accountCcyN + "USD"

float  _l2_fxD_raw  = request.security(_l2_fxD_sym,  timeframe.period, close, ignore_invalid_symbol=true)
float  _l2_fxI_raw  = request.security(_l2_fxI_sym,  timeframe.period, close, ignore_invalid_symbol=true)
float  _l2_idcD_raw = request.security(_l2_idcD_sym, timeframe.period, close, ignore_invalid_symbol=true)
float  _l2_idcI_raw = request.security(_l2_idcI_sym, timeframe.period, close, ignore_invalid_symbol=true)

// ─────────────────────────────────────────────
// SECTION 3: FUNCTIONS
// All business logic in testable, stateless functions.
// ─────────────────────────────────────────────

// Classify syminfo.type into trading categories
// Returns [isForex, isFutures, isStock, isCrypto, isCFD, isUnsupported]
// Note: "commodity" is grouped with CFDs (spot metals/energy CFDs on some feeds).
f_assetClass() =>
    bool _forex  = syminfo.type == "forex"
    bool _fut    = syminfo.type == "future" or syminfo.type == "futures"
    bool _stock  = syminfo.type == "stock" or syminfo.type == "fund" or syminfo.type == "dr"
    bool _crypto = syminfo.type == "crypto"
    bool _cfd    = syminfo.type == "cfd" or syminfo.type == "index" or syminfo.type == "bond" or syminfo.type == "commodity"
    bool _unsup  = syminfo.type == "economic" or syminfo.type == "spread" or syminfo.type == "warrant" or syminfo.type == "structured" or syminfo.type == "right"
    [_forex, _fut, _stock, _crypto, _cfd, _unsup]

// Tick value in instrument currency per 1 tradeable unit
// Forex: explicit 100,000 (pointvalue=1 on TV, does not encode lot size)
// Others: mintick x pointvalue (TradingView canonical v6 formula)
// Override: user-supplied contract size takes precedence
f_tickValue(bool isForex, float override) =>
    float _tv = na
    if override > 0.0
        _tv := syminfo.mintick * override
    else if isForex
        _tv := syminfo.mintick * 100000.0
    else
        _tv := syminfo.mintick * syminfo.pointvalue
    _tv

// Leg 1: instrument currency to USD
// Waterfall: direct FX -> inverse FX -> IDC direct -> IDC inverse -> na (no silent fallback)
// Returns [rate, sourceLabel]
f_resolveInstToUSD(bool instIsUSD, bool usdIsBase, float entryPx,
     float fxD, float fxI, float idcD, float idcI) =>
    float  _rate = na
    string _src  = "—"
    if instIsUSD
        _rate := 1.0
        _src  := "USD quote"
    else if usdIsBase
        _rate := entryPx > 0.0 ? 1.0 / entryPx : na
        _src  := "USD base inv"
    else if not na(fxD) and fxD > 0.0
        _rate := 1.0 / fxD
        _src  := "FX direct inv"
    else if not na(fxI) and fxI > 0.0
        _rate := fxI
        _src  := "FX inverse"
    else if not na(idcD) and idcD > 0.0
        _rate := 1.0 / idcD
        _src  := "IDC direct inv"
    else if not na(idcI) and idcI > 0.0
        _rate := idcI
        _src  := "IDC inverse"
    else
        _rate := na
        _src  := "⚠ No rate"
    [_rate, _src]

// Leg 2: USD to account currency
// Same waterfall logic, inverted direction.
// sameCcy branch: returns 1/instToUSD so composition (instToUSD * usdToAcct) = 1.0
// Returns [rate, sourceLabel]
f_resolveUSDToAcct(bool acctIsUSD, bool acctCcyValid, bool sameCcy,
     float instToUSD, float fxD, float fxI, float idcD, float idcI) =>
    float  _rate = na
    string _src  = "—"
    if acctIsUSD or not acctCcyValid
        _rate := 1.0
        _src  := acctCcyValid ? "USD acct" : "⚠ Invalid CCY"
    else if sameCcy
        _rate := not na(instToUSD) and instToUSD > 0.0 ? 1.0 / instToUSD : na
        _src  := "Same CCY"
    else if not na(fxD) and fxD > 0.0
        _rate := fxD
        _src  := "FX direct"
    else if not na(fxI) and fxI > 0.0
        _rate := 1.0 / fxI
        _src  := "FX inverse inv"
    else if not na(idcD) and idcD > 0.0
        _rate := idcD
        _src  := "IDC direct"
    else if not na(idcI) and idcI > 0.0
        _rate := 1.0 / idcI
        _src  := "IDC inverse inv"
    else
        _rate := na
        _src  := "⚠ No rate"
    [_rate, _src]

// Net conversion rate: instCcy -> USD -> acctCcy = instToUSD x usdToAcct
// Returns [convRate, hasWarning]
f_convRate(float instToUSD, float usdToAcct) =>
    bool  _valid = not na(instToUSD) and not na(usdToAcct) and instToUSD > 0.0 and usdToAcct > 0.0
    float _rate  = _valid ? instToUSD * usdToAcct : na
    [_rate, na(_rate)]

// Universal position size: units = riskAmount / (ticksAtRisk x tickValue x convRate)
// Returns [rawUnits, riskPerUnit]
f_calcRawUnits(bool slValid, float slDist, float tickVal, float conv, float riskAmt) =>
    float _ticks   = slValid and syminfo.mintick > 0.0 ? slDist / syminfo.mintick : 0.0
    float _rpu     = _ticks * tickVal
    bool  _ok      = not na(conv) and conv > 0.0 and _rpu > 0.0
    float _rpuAcct = _ok ? _rpu * conv : na
    float _raw     = not na(_rpuAcct) and _rpuAcct > 0.0 ? riskAmt / _rpuAcct : na
    [_raw, _rpu]

// Floor raw units to tradeable size — always floor, never round
// Forex min lot is configurable via fxMinLot (0.01 default for micro lots)
// Returns na displayUnits for unsupported asset types so the warning is not
// accompanied by a plausible-looking size.
// Returns [displayUnits, unitLabel, unitSuffix]
f_floorUnits(bool isForex, bool isFutures, bool isStock, bool isCrypto, bool isUnsupported, float rawUnits, float fxMinLot) =>
    float  _du  = na
    string _lbl = "UNITS"
    string _sfx = ""
    if not na(rawUnits) and rawUnits > 0.0 and not isUnsupported
        if isForex
            float _inc = fxMinLot > 0.0 ? fxMinLot : 0.01
            _du  := math.floor(rawUnits / _inc) * _inc
            _lbl := "LOTS"
        else if isFutures
            _du  := math.floor(rawUnits)
            _lbl := "CONTRACTS"
        else if isStock
            _du  := math.floor(rawUnits)
            _lbl := "SHARES"
        else if isCrypto
            float _mc = syminfo.mincontract > 0.0 ? syminfo.mincontract : 0.00000001
            _du  := math.floor(rawUnits / _mc) * _mc
            _lbl := "UNITS"
            _sfx := " " + syminfo.basecurrency
        else
            _du  := math.floor(rawUnits * 100.0) / 100.0
            _lbl := "UNITS"
    [_du, _lbl, _sfx]

// TP1/2/3 prices and P&L in account currency
// Returns [tp1, tp2, tp3, pnl1, pnl2, pnl3]
f_tpLevels(bool slValid, bool isBuy, float entryPx, float slDist,
     float riskPerUnit, float conv, float displayUnits) =>
    float _tp1 = isBuy ? entryPx + slDist       : entryPx - slDist
    float _tp2 = isBuy ? entryPx + slDist * 2.0 : entryPx - slDist * 2.0
    float _tp3 = isBuy ? entryPx + slDist * 3.0 : entryPx - slDist * 3.0
    float _ppu = not na(conv) ? riskPerUnit * conv : na
    bool  _ok  = slValid and not na(_ppu) and not na(displayUnits)
    float _p1  = _ok ? math.abs(_ppu * displayUnits) : na
    float _p2  = not na(_p1) ? _p1 * 2.0 : na
    float _p3  = not na(_p1) ? _p1 * 3.0 : na
    [_tp1, _tp2, _tp3, _p1, _p2, _p3]

// Dynamic price format string derived from syminfo.mintick
f_priceFmt() =>
    int _dp = switch
        syminfo.mintick >= 1.0      => 0
        syminfo.mintick >= 0.1      => 1
        syminfo.mintick >= 0.01     => 2
        syminfo.mintick >= 0.001    => 3
        syminfo.mintick >= 0.0001   => 4
        syminfo.mintick >= 0.00001  => 5
        syminfo.mintick >= 0.000001 => 6
        => 8
    string _fmt = switch _dp
        0 => "#"
        1 => "#.#"
        2 => "#.##"
        3 => "#.###"
        4 => "#.####"
        5 => "#.#####"
        6 => "#.######"
        7 => "#.#######"
        => "#.########"
    _fmt

// Margin required at given leverage — informational only, does not affect sizing
// Respects contractSizeOverride (e.g. XAUUSD=100, XAGUSD=5000) for CFDs with
// non-standard contract sizes where syminfo.pointvalue is misleading.
f_marginCalc(bool isForex, float lev, float units, float entryPx, float conv, float override) =>
    float _m = na
    if lev > 0.0 and not na(units) and units > 0.0 and not na(conv)
        float _mult = override > 0.0 ? override : syminfo.pointvalue
        float _n    = isForex ? units * 100000.0 * entryPx : units * entryPx * _mult
        _m := (_n * conv) / lev
    _m

// Minimum equity needed for 1 min-lot/contract/share (all asset classes)
// Else branch covers CFDs and any other asset that uses the 0.01-unit floor.
f_minEquityNeeded(bool tooSmall, bool isForex, bool isFutures, bool isStock, bool isCrypto,
     float rpuAcct, float rPct, float fxMinLot) =>
    float _min = na
    if tooSmall and not na(rpuAcct) and rpuAcct > 0.0 and rPct > 0.0
        float _minUnits = na
        if isForex
            _minUnits := fxMinLot > 0.0 ? fxMinLot : 0.01
        else if isFutures or isStock
            _minUnits := 1.0
        else if isCrypto
            _minUnits := syminfo.mincontract > 0.0 ? syminfo.mincontract : 0.00000001
        else
            _minUnits := 0.01
        if not na(_minUnits)
            _min := (_minUnits * rpuAcct) / (rPct / 100.0)
    _min

// Notional order value in account currency — respects contractSizeOverride
f_orderValue(bool isForex, float units, float entryPx, float conv, float override) =>
    float _v = na
    if not na(units) and units > 0.0 and not na(conv)
        float _mult  = override > 0.0 ? override : syminfo.pointvalue
        float _fx    = units * 100000.0 * entryPx * conv
        float _other = units * entryPx * _mult * conv
        _v := isForex ? _fx : _other
    _v

// ── FORMAT HELPERS ────────────────────────────

fmtDollar(float v, string fb) =>
    not na(v) ? "$" + str.tostring(math.round(v, 2), "#,###.##") : fb

fmtPnl(float v, string fb) =>
    not na(v) ? "+$" + str.tostring(math.round(v, 2), "#,###.##") : fb

rowBg(int r) =>
    r % 2 == 0 ? color.rgb(17, 17, 17) : color.rgb(0, 0, 0)

// ─────────────────────────────────────────────
// SECTION 4: MAIN CALCULATION
// Wire all functions with live syminfo/price data.
// ─────────────────────────────────────────────

[isForex, isFutures, isStock, isCrypto, isCFD, isUnsupported] = f_assetClass()

float entryPrice     = entryInput
float slPrice        = slInput
bool  slValid        = entryPrice > 0.0 and slPrice > 0.0 and slPrice != entryPrice
bool  isBuy          = tradeDir == "Buy"
float riskAmount     = equity * (riskPct / 100.0)
float slDist         = slValid ? math.abs(entryPrice - slPrice) : 0.0

// Direction / SL consistency: Buy → SL < entry, Sell → SL > entry. Warn but still calc.
bool  dirInconsistent = slValid and ((isBuy and slPrice > entryPrice) or (not isBuy and slPrice < entryPrice))

float tickValue   = f_tickValue(isForex, contractSizeOverride)

bool acctCcyValid = str.length(accountCcyN) == 3
bool instIsUSD    = syminfo.currency == "USD"
bool usdIsBase    = isForex and syminfo.basecurrency == "USD"

[instToUSD, l1_src] = f_resolveInstToUSD(
     instIsUSD, usdIsBase, entryPrice,
     _l1_fxD, _l1_fxI, _l1_idcD, _l1_idcI)

bool  acctIsUSD  = accountCcyN == "USD"
bool  _skipLeg2  = acctIsUSD or not acctCcyValid
bool  sameCcy    = syminfo.currency == accountCcyN
float l2_fxD     = _skipLeg2 ? na : _l2_fxD_raw
float l2_fxI     = _skipLeg2 ? na : _l2_fxI_raw
float l2_idcD    = _skipLeg2 ? na : _l2_idcD_raw
float l2_idcI    = _skipLeg2 ? na : _l2_idcI_raw

[usdToAcct, l2_src] = f_resolveUSDToAcct(
     acctIsUSD, acctCcyValid, sameCcy,
     instToUSD, l2_fxD, l2_fxI, l2_idcD, l2_idcI)

[convRate, convWarning] = f_convRate(instToUSD, usdToAcct)

// sameCcy robustness: when instrument and account currency match, convRate is
// trivially 1.0 regardless of whether USD cross-rate feeds are available.
// Rescues sizing on exotic-ccy instruments when TradingView lacks the USD cross.
if sameCcy and acctCcyValid
    convRate    := 1.0
    convWarning := false
    l1_src      := "Same CCY"
    l2_src      := "(skip)"

[rawUnits, riskPerUnit] = f_calcRawUnits(slValid, slDist, tickValue, convRate, riskAmount)

[displayUnits, unitLabel, unitSuffix] = f_floorUnits(isForex, isFutures, isStock, isCrypto, isUnsupported, rawUnits, forexMinLot)

bool  tooSmall        = not na(rawUnits) and rawUnits > 0.0 and not na(displayUnits) and displayUnits <= 0.0
bool  _rpuOk          = not na(convRate) and convRate > 0.0 and riskPerUnit > 0.0
float riskPerUnitAcct = _rpuOk ? riskPerUnit * convRate : na
float minEquityNeeded = f_minEquityNeeded(tooSmall, isForex, isFutures, isStock, isCrypto,
     riskPerUnitAcct, riskPct, forexMinLot)

[tp1Price, tp2Price, tp3Price, pnlTP1, pnlTP2, pnlTP3] = f_tpLevels(
     slValid, isBuy, entryPrice, slDist,
     riskPerUnit, convRate, displayUnits)

string priceFmt       = f_priceFmt()
float  marginRequired = f_marginCalc(isForex, leverage, displayUnits, entryPrice, convRate, contractSizeOverride)
float  orderValue     = f_orderValue(isForex, displayUnits, entryPrice, convRate, contractSizeOverride)

// Margin-vs-equity sanity check (informational, leverage must be > 0)
bool marginExceedsEquity = leverage > 0.0 and not na(marginRequired) and marginRequired > equity

// ─────────────────────────────────────────────
// SECTION 5: COLORS
// ─────────────────────────────────────────────

color colBuy    = color.rgb(30,  136, 229)
color colSell   = color.rgb(229, 57,  53)
color dirColor  = isBuy ? colBuy : colSell
color dirBg     = isBuy ? colBuy : colSell
color colBg     = color.rgb(0,   0,   0)
color colBgHdr  = color.rgb(10,  10,  10)
color colNavy   = color.rgb(13,  33,  55)
color colWhite  = color.rgb(255, 255, 255)
color colGray   = color.rgb(170, 170, 170)
color colGreen  = color.rgb(38,  166, 154)
color colTeal   = color.rgb(0,   188, 212)
color colPurple = color.rgb(171, 71,  188)
color colOrange = color.rgb(255, 152, 0)
color colLime   = color.rgb(105, 240, 174)
color colYellow = color.rgb(255, 214, 0)
color colWarn   = color.rgb(255, 82,  82)
color colDim    = color.rgb(85,  85,  85)
color colDivide = color.rgb(34,  34,  34)

// ─────────────────────────────────────────────
// SECTION 6: TABLE
// ─────────────────────────────────────────────

tPos = switch tablePos
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    =>                position.bottom_left

int _w1      = tooSmall             ? 1 : 0
int _w2      = convWarning          ? 1 : 0
int _w3      = isUnsupported        ? 1 : 0
int _w4      = not acctCcyValid     ? 1 : 0
int _w5      = dirInconsistent      ? 1 : 0
int _w6      = marginExceedsEquity  ? 1 : 0
int _wRows   = _w1 + _w2 + _w3 + _w4 + _w5 + _w6
int _mRow    = leverage > 0.0       ? 1 : 0
int _nRows   = 17 + _wRows + _mRow

var table tbl = na

if barstate.islast
    table.delete(tbl)
    tbl := table.new(tPos, 3, _nRows,
         bgcolor=colBg,
         border_color=color.rgb(51, 51, 51), border_width=1,
         frame_color=color.rgb(68, 68, 68),  frame_width=1)

    int r = 0

    table.cell(tbl, 0, r, "POSITION SIZER PRO",
         text_color=colWhite,  text_size=size.normal, bgcolor=colBgHdr, text_halign=text.align_left)
    table.cell(tbl, 1, r, syminfo.ticker,
         text_color=colYellow, text_size=size.normal, bgcolor=colBgHdr, text_halign=text.align_center)
    table.cell(tbl, 2, r, tradeDir,
         text_color=colWhite,  text_size=size.normal, bgcolor=dirBg,    text_halign=text.align_center)
    r += 1

    table.cell(tbl, 0, r, "Field",    text_color=colGray, text_size=size.small, bgcolor=colBgHdr, text_halign=text.align_left)
    table.cell(tbl, 1, r, "Value",    text_color=colGray, text_size=size.small, bgcolor=colBgHdr, text_halign=text.align_right)
    table.cell(tbl, 2, r, "P&L/Info", text_color=colGray, text_size=size.small, bgcolor=colBgHdr, text_halign=text.align_right)
    r += 1

    table.cell(tbl, 0, r, "Equity",
         text_color=colGray,  text_size=size.normal, bgcolor=rowBg(r), text_halign=text.align_left)
    table.cell(tbl, 1, r, fmtDollar(equity, "—") + " " + accountCcyN,
         text_color=colWhite, text_size=size.normal, bgcolor=rowBg(r), text_halign=text.align_right)
    table.cell(tbl, 2, r, "", bgcolor=rowBg(r))
    r += 1

    table.cell(tbl, 0, r, "Risk %",
         text_color=colGray,   text_size=size.normal, bgcolor=rowBg(r), text_halign=text.align_left)
    table.cell(tbl, 1, r, str.tostring(riskPct, "#.##") + "%",
         text_color=colOrange, text_size=size.normal, bgcolor=rowBg(r), text_halign=text.align_right)
    table.cell(tbl, 2, r, "= " + fmtDollar(riskAmount, "—") + " " + accountCcyN,
         text_color=colOrange, text_size=size.normal, bgcolor=rowBg(r), text_halign=text.align_right)
    r += 1

    table.cell(tbl, 0, r, "Asset Type",
         text_color=colGray, text_size=size.normal, bgcolor=rowBg(r), text_halign=text.align_left)
    table.cell(tbl, 1, r, str.upper(syminfo.type),
         text_color=colTeal, text_size=size.normal, bgcolor=rowBg(r), text_halign=text.align_right)
    table.cell(tbl, 2, r, syminfo.currency,
         text_color=colGray, text_size=size.small,  bgcolor=rowBg(r), text_halign=text.align_right)
    r += 1

    table.cell(tbl, 0, r, "Entry",
         text_color=colGray,  text_size=size.normal, bgcolor=rowBg(r), text_halign=text.align_left)
    table.cell(tbl, 1, r, str.tostring(entryPrice, priceFmt),
         text_color=dirColor, text_size=size.normal, bgcolor=rowBg(r), text_halign=text.align_right)
    table.cell(tbl, 2, r, "", bgcolor=rowBg(r))
    r += 1

    string _fxPips = str.tostring(math.round(slDist / (syminfo.mintick * 10), 1), "#.#") + " pips"
    string _tkStr  = str.tostring(math.round(slDist / syminfo.mintick, 0), "#") + " ticks"
    string _slDist = isForex and slValid ? _fxPips : slValid ? _tkStr : "—"
    table.cell(tbl, 0, r, "Stop Loss",
         text_color=colGray, text_size=size.normal, bgcolor=rowBg(r), text_halign=text.align_left)
    table.cell(tbl, 1, r, slValid ? str.tostring(slPrice, priceFmt) : "⚠ Enter SL",
         text_color=colSell, text_size=size.normal, bgcolor=rowBg(r), text_halign=text.align_right)
    table.cell(tbl, 2, r, _slDist,
         text_color=colGray, text_size=size.small,  bgcolor=rowBg(r), text_halign=text.align_right)
    r += 1

    string _tvFmt = str.tostring(math.round(tickValue, 6), "#.######") + " " + syminfo.currency
    string _tvStr = not na(tickValue) ? _tvFmt : "—"
    string _csOvr = "override: " + str.tostring(contractSizeOverride, "#,###")
    string _csPv  = "pv=" + str.tostring(syminfo.pointvalue, "#,###")
    string _csStr = contractSizeOverride > 0.0 ? _csOvr : isForex ? "lot=100,000" : _csPv
    table.cell(tbl, 0, r, "Tick Value",
         text_color=colGray,  text_size=size.normal, bgcolor=rowBg(r), text_halign=text.align_left)
    table.cell(tbl, 1, r, _tvStr,
         text_color=colWhite, text_size=size.normal, bgcolor=rowBg(r), text_halign=text.align_right)
    table.cell(tbl, 2, r, _csStr,
         text_color=colDim,   text_size=size.small,  bgcolor=rowBg(r), text_halign=text.align_right)
    r += 1

    string _crFmt = str.tostring(math.round(convRate, 6), "#.######")
    string _crStr = not na(convRate) ? _crFmt : "⚠ N/A"
    table.cell(tbl, 0, r, "Conv Rate",
         text_color=colGray, text_size=size.small, bgcolor=rowBg(r), text_halign=text.align_left)
    table.cell(tbl, 1, r, _crStr,
         text_color=convWarning ? colWarn : colDim, text_size=size.small, bgcolor=rowBg(r), text_halign=text.align_right)
    table.cell(tbl, 2, r, l1_src + " | " + l2_src,
         text_color=colDim, text_size=size.small, bgcolor=rowBg(r), text_halign=text.align_right)
    r += 1

    table.cell(tbl, 0, r, "", bgcolor=colDivide)
    table.cell(tbl, 1, r, "", bgcolor=colDivide)
    table.cell(tbl, 2, r, "", bgcolor=colDivide)
    r += 1

    string _hFmt = str.tostring(displayUnits, "#.########") + unitSuffix
    string _hVal = not na(displayUnits) and displayUnits > 0.0 ? _hFmt : "—"
    table.cell(tbl, 0, r, "  " + unitLabel,
         text_color=colWhite,  text_size=size.large,  bgcolor=colNavy, text_halign=text.align_left)
    table.cell(tbl, 1, r, _hVal,
         text_color=colLime,   text_size=size.large,  bgcolor=colNavy, text_halign=text.align_right)
    table.cell(tbl, 2, r, slValid ? "Risk " + fmtDollar(riskAmount, "—") : "—",
         text_color=colOrange, text_size=size.normal, bgcolor=colNavy, text_halign=text.align_right)
    r += 1

    table.cell(tbl, 0, r, "Order Value",
         text_color=colGray,   text_size=size.normal, bgcolor=rowBg(r), text_halign=text.align_left)
    table.cell(tbl, 1, r, fmtDollar(orderValue, "—"),
         text_color=colYellow, text_size=size.normal, bgcolor=rowBg(r), text_halign=text.align_right)
    table.cell(tbl, 2, r, accountCcyN,
         text_color=colDim,    text_size=size.small,  bgcolor=rowBg(r), text_halign=text.align_right)
    r += 1

    if leverage > 0.0
        table.cell(tbl, 0, r, "Margin @ " + str.tostring(leverage, "#.#") + ":1",
             text_color=colGray,   text_size=size.normal, bgcolor=rowBg(r), text_halign=text.align_left)
        table.cell(tbl, 1, r, fmtDollar(marginRequired, "—"),
             text_color=colYellow, text_size=size.normal, bgcolor=rowBg(r), text_halign=text.align_right)
        table.cell(tbl, 2, r, "info only",
             text_color=colDim,    text_size=size.small,  bgcolor=rowBg(r), text_halign=text.align_right)
        r += 1

    table.cell(tbl, 0, r, "", bgcolor=colDivide)
    table.cell(tbl, 1, r, "", bgcolor=colDivide)
    table.cell(tbl, 2, r, "", bgcolor=colDivide)
    r += 1

    table.cell(tbl, 0, r, "TP1  1:1",
         text_color=colGray,  text_size=size.normal, bgcolor=rowBg(r), text_halign=text.align_left)
    table.cell(tbl, 1, r, slValid and showTP1 ? str.tostring(tp1Price, priceFmt) : "—",
         text_color=colGreen, text_size=size.normal, bgcolor=rowBg(r), text_halign=text.align_right)
    table.cell(tbl, 2, r, slValid and showTP1 ? fmtPnl(pnlTP1, "—") : "—",
         text_color=colGreen, text_size=size.normal, bgcolor=rowBg(r), text_halign=text.align_right)
    r += 1

    table.cell(tbl, 0, r, "TP2  1:2",
         text_color=colGray, text_size=size.normal, bgcolor=rowBg(r), text_halign=text.align_left)
    table.cell(tbl, 1, r, slValid and showTP2 ? str.tostring(tp2Price, priceFmt) : "—",
         text_color=colTeal, text_size=size.normal, bgcolor=rowBg(r), text_halign=text.align_right)
    table.cell(tbl, 2, r, slValid and showTP2 ? fmtPnl(pnlTP2, "—") : "—",
         text_color=colTeal, text_size=size.normal, bgcolor=rowBg(r), text_halign=text.align_right)
    r += 1

    table.cell(tbl, 0, r, "TP3  1:3",
         text_color=colGray,   text_size=size.normal, bgcolor=rowBg(r), text_halign=text.align_left)
    table.cell(tbl, 1, r, slValid and showTP3 ? str.tostring(tp3Price, priceFmt) : "—",
         text_color=colPurple, text_size=size.normal, bgcolor=rowBg(r), text_halign=text.align_right)
    table.cell(tbl, 2, r, slValid and showTP3 ? fmtPnl(pnlTP3, "—") : "—",
         text_color=colPurple, text_size=size.normal, bgcolor=rowBg(r), text_halign=text.align_right)
    r += 1

    string _fml = switch
        isForex   => "Lots = Risk / (pips x pip value/lot)"
        isFutures => "Contracts = Risk / (ticks x tick value)"
        isStock   => "Shares = Risk / (price distance)"
        isCrypto  => "Units = Risk / (price distance x conv)"
        => "Units = Risk / (ticks x tick value x conv)"
    table.cell(tbl, 0, r, _fml,
         text_color=colDim, text_size=size.small, bgcolor=colBgHdr, text_halign=text.align_left)
    table.cell(tbl, 1, r, "", bgcolor=colBgHdr)
    table.cell(tbl, 2, r, "", bgcolor=colBgHdr)
    r += 1

    if not acctCcyValid
        table.cell(tbl, 0, r, "⚠ Account currency '" + accountCurrency + "' invalid — use 3-letter code",
             text_color=colWarn, text_size=size.small, bgcolor=color.rgb(40, 10, 10), text_halign=text.align_left)
        table.cell(tbl, 1, r, "", bgcolor=color.rgb(40, 10, 10))
        table.cell(tbl, 2, r, "", bgcolor=color.rgb(40, 10, 10))
        r += 1

    if convWarning
        table.cell(tbl, 0, r, "⚠ Conversion rate unavailable — check account currency",
             text_color=colWarn, text_size=size.small, bgcolor=color.rgb(40, 10, 10), text_halign=text.align_left)
        table.cell(tbl, 1, r, "", bgcolor=color.rgb(40, 10, 10))
        table.cell(tbl, 2, r, "", bgcolor=color.rgb(40, 10, 10))
        r += 1

    if dirInconsistent
        string _dirMsg = isBuy ? "⚠ Buy direction but SL is above entry — check SL" : "⚠ Sell direction but SL is below entry — check SL"
        table.cell(tbl, 0, r, _dirMsg,
             text_color=colWarn, text_size=size.small, bgcolor=color.rgb(40, 10, 10), text_halign=text.align_left)
        table.cell(tbl, 1, r, "", bgcolor=color.rgb(40, 10, 10))
        table.cell(tbl, 2, r, "", bgcolor=color.rgb(40, 10, 10))
        r += 1

    if tooSmall
        string _mFmt = " Need ~" + fmtDollar(minEquityNeeded, "?") + " equity"
        string _mStr = not na(minEquityNeeded) ? _mFmt : ""
        string _minLabel = isForex ? str.tostring(forexMinLot, "#.###") + " lots" : isFutures or isStock ? "1 unit" : isCrypto ? "min contract" : "min"
        table.cell(tbl, 0, r, "⚠ Position < " + _minLabel + "." + _mStr,
             text_color=colWarn, text_size=size.small, bgcolor=color.rgb(40, 10, 10), text_halign=text.align_left)
        table.cell(tbl, 1, r, "", bgcolor=color.rgb(40, 10, 10))
        table.cell(tbl, 2, r, "", bgcolor=color.rgb(40, 10, 10))
        r += 1

    if marginExceedsEquity
        table.cell(tbl, 0, r, "⚠ Margin required (" + fmtDollar(marginRequired, "—") + ") exceeds equity",
             text_color=colWarn, text_size=size.small, bgcolor=color.rgb(40, 10, 10), text_halign=text.align_left)
        table.cell(tbl, 1, r, "", bgcolor=color.rgb(40, 10, 10))
        table.cell(tbl, 2, r, "", bgcolor=color.rgb(40, 10, 10))
        r += 1

    if isUnsupported
        table.cell(tbl, 0, r, "⚠ Asset type '" + syminfo.type + "' not supported for sizing",
             text_color=colWarn, text_size=size.small, bgcolor=color.rgb(40, 10, 10), text_halign=text.align_left)
        table.cell(tbl, 1, r, "", bgcolor=color.rgb(40, 10, 10))
        table.cell(tbl, 2, r, "", bgcolor=color.rgb(40, 10, 10))

// ─────────────────────────────────────────────
// SECTION 7: TP RAYS
// TP1/2/3 horizontal rays only.
// Entry and SL rays removed — not selectable in Pine anyway.
// Rays redraw on barstate.islast to reflect current inputs.
// ─────────────────────────────────────────────

var line rayTP1 = na
var line rayTP2 = na
var line rayTP3 = na

if barstate.islast
    line.delete(rayTP1)
    line.delete(rayTP2)
    line.delete(rayTP3)

    if slValid and showRays
        if showTP1
            rayTP1 := line.new(bar_index, tp1Price, bar_index + 1, tp1Price,
                 extend=extend.right, style=line.style_dotted, color=colGreen, width=2)
        if showTP2
            rayTP2 := line.new(bar_index, tp2Price, bar_index + 1, tp2Price,
                 extend=extend.right, style=line.style_dotted, color=colTeal, width=2)
        if showTP3
            rayTP3 := line.new(bar_index, tp3Price, bar_index + 1, tp3Price,
                 extend=extend.right, style=line.style_dotted, color=colPurple, width=2)
````
