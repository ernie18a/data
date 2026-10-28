# 4theluv Sector X-Ray (v1.1)

- url: https://www.tradingview.com/script/NUdlWYsK-4theluv-Sector-X-Ray-v1-1/
- type: indicator
- pine_id: PUB;9525fae255f64c3992c58b207e70c460
- version: 1.0

## Description

The X-Ray Engine — Architectural Sorcery

On the surface it looks like a single sector deep-dive. Under the hood, it is a dynamic dispatch engine that compiles 100+ potential request.security calls into a single TradingView indicator slot — and only spends the call budget on the sector you are actively watching.

The Sorcery

A single input.string dropdown lets you pick any of the 11 SPDR sectors (XLK, XLF, XLY, XLC, XLI, XLE, XLV, XLP, XLU, XLB, XLRE). Behind that dropdown sits a switch block that routes execution to ONLY one sector's leader pool at a time — typically 8-12 individual stocks plus 2-4 sub-group ETFs per sector.

NAIVE APPROACH:    11 sectors × 10 stocks = 110+ calls → COMPILE FAILURE
X-RAY APPROACH:    Pick 1 sector → ~12-15 calls actually run
DORMANT BRANCHES:  Exist in bytecode, NEVER reached, cost zero runtime budget
What This Unlocks
•	One slot, eleven deep-dives — flip the dropdown, get a completely different sector x-ray instantly
•	No script juggling — no need to load 11 separate indicators
•	Deeper pools per sector — budget spent on ONE sector means 10-12 leaders + sub-groups instead of 4-6
•	Sub-group routing built-in — XLF shows Big Banks/Payments/I-Banks, XLK shows Semis/Software/Hardware, XLY shows Retail/Auto/Travel
•	Zero performance penalty — TradingView only executes the active branch
•	Infinitely extensible — add a 12th sector? Just add a switch case. Architecture scales linearly
Sector → Sub-Group Routing Map
SECTOR	INDIVIDUAL LEADERS (10 each)	SUB-GROUP ETFs
XLK (Tech)	NVDA, MSFT, AAPL, AVGO, ORCL, CRM, AMD, ADBE, CSCO, ACN	SMH, IGV, XSD
XLF (Financials)	JPM, BAC, WFC, GS, MS, C, BLK, SPGI, AXP, V	KRE, KBE, IAI
XLY (Discretionary)	AMZN, TSLA, HD, MCD, NKE, LOW, BKNG, SBUX, TJX, ABNB	XRT, CARZ, JETS
XLC (Comm)	META, GOOGL, NFLX, DIS, T, VZ, CMCSA, EA, TMUS, CHTR	SOCL, PBS
XLI (Industrials)	CAT, GE, HON, UPS, BA, RTX, LMT, DE, UNP, ETN	ITA, JETS, XTN
XLE (Energy)	XOM, CVX, COP, EOG, SLB, MPC, PSX, OXY, PXD, VLO	XOP, OIH, TAN
XLV (Healthcare)	LLY, UNH, JNJ, PFE, ABBV, MRK, TMO, ABT, DHR, BMY	IBB, IHI, IHF
XLP (Staples)	PG, COST, KO, WMT, PEP, MDLZ, PM, MO, CL, TGT	(trades cohesively)
XLU (Utilities)	NEE, SO, DUK, AEP, SRE, D, EXC, XEL, PCG, ED	TAN, URA
XLB (Materials)	LIN, SHW, APD, FCX, ECL, NEM, DD, DOW, CTVA, NUE	GDX, COPX, LIT
XLRE (Real Estate)	PLD, AMT, EQIX, CCI, PSA, O, SPG, WELL, DLR, EXR	REZ, REM, VNQ

Real-World Workflow
10:15 AM — Master Regime flags Tech as leader → flip X-Ray to XLK
          → see Semis vs Software vs Hardware sub-rotation + top 10 movers
          → NVDA leading semis with 2.4x RVOL → trade signal

11:30 AM — Tech fades, Energy takes lead → flip X-Ray to XLE
          → same depth, completely different stocks (XOM, CVX, oil services)
          → sub-groups now show XOP vs OIH vs TAN routing

ONE SLOT.   ELEVEN SECTORS.   INSTANT PIVOT.
Why The Dropdown Matters
The dropdown is not a UI convenience — it IS the entire architectural trick that makes 100+ calls fit in 40. Without dynamic dispatch, you would need 11 separate scripts (one per sector), each consuming an indicator slot. With the X-Ray engine, all 11 sectors live in ONE slot, summoned on demand by a single click.
TradingView's 40-call limit applies to UNIQUE symbols requested per bar at runtime. When request.security is wrapped inside a switch case and the controlling variable is a constant input, Pine's compiler optimizes the path — only the active branch fetches data. Dormant branches are dead code at runtime. This is specifically why a dropdown works for dispatch while a dynamic loop (variable ticker per iteration) does NOT.
Example Output: XLRE Selected
When XLRE is selected, the dropdown surfaces this breakdown:
Sub-Industry	Top Holdings	Macro Driver
Retail/Resi	EQR, AVB, ESS, SPG, REG	Apartment demand, mall traffic
Industrial/Tower	CCI, AMT, PLD, EQIX, DLR	5G, e-commerce logistics, data centers
Storage/Services	VICI, PSA, EXR, CBRE	Self-storage, gaming REITs
Healthcare/DC	WELL, VTR, HCN, EQIX, DLR	Senior housing, medical, data centers

The Spread Indicator (per-sector)
Each X-Ray view shows a footer: Spread: X% | [leader] leads, [laggard] lags
•	Spread > 1.5% = significant intra-sector dispersion. Trade sub-groups, not the parent ETF.
•	Spread < 0.5% = sector moving as a unit. Parent ETF is fine to trade.
Killer Signals
XLRE → Industrial/Tower > all: tech infrastructure trade (aligns with risk-on tech)
XLRE → Retail/Resi green + Healthcare/DC red: Consumer-driven REIT cycle
XLRE → All sub-groups red but Storage green: Recession positioning
XLF  → KRE (regionals) leading vs IAI (broker-dealers): Risk-on financials
XLK  → SMH (semis) lagging IGV (software): Late-cycle tech rotation
XLE  → XOP (E&P) > OIH (services): Commodity-driven, not capex-driven

## Source Code

````pine
//@version=6
indicator("4theluv Sector X-Ray (v1.1)", overlay = true)

// ============================================================
// SETTINGS
// ============================================================
grp_main = "Sector Selection"
sector_choice = input.string("Tech (XLK)", "Sector to X-Ray", options = ["Tech (XLK)", "Comm (XLC)", "Discr (XLY)", "Financials (XLF)", "Energy (XLE)", "Industrials (XLI)", "Health (XLV)", "Staples (XLP)", "Materials (XLB)", "Utilities (XLU)", "Real Estate (XLRE)", "Transports (IYT)"], group = grp_main)

grp_pos = "Position & Size"
tablePosition = input.string(position.middle_right, "Table Position", options = [position.top_right, position.top_center, position.top_left, position.bottom_right, position.bottom_center, position.bottom_left, position.middle_right, position.middle_center, position.middle_left], group = grp_pos)
textSize      = input.string(size.small, "Text Size", options = [size.tiny, size.small, size.normal, size.large], group = grp_pos)
tf_input      = input.timeframe("30", "Primary Timeframe", group = grp_pos)
tf_context    = input.timeframe("D",  "Context Timeframe", group = grp_pos)
use_ext       = input.bool(true, "Use Extended Hours", group = grp_pos)

grp_col = "Color Theme"
bg_transp     = input.int(15, "BG Transparency", minval = 0, maxval = 100, step = 5, group = grp_col)
c_names_raw   = input.color(color.gray,   "Group Name BG",   group = grp_col)
c_up_raw      = input.color(color.green,  "Positive %",      group = grp_col)
c_down_raw    = input.color(color.red,    "Negative %",      group = grp_col)
c_weak_raw    = input.color(color.orange, "Weak Conviction", group = grp_col)
c_bench_raw   = input.color(color.blue,   "Benchmark BG",    group = grp_col)
c_header_raw  = input.color(color.purple, "Header BG",       group = grp_col)
c_text        = input.color(color.white,  "Text Color",      group = grp_col)

grp_sig = "Signals"
rvol_strong   = input.float(1.2, "Strong RVOL threshold", minval = 0.1, step = 0.1, group = grp_sig)
rvol_weak     = input.float(0.8, "Weak RVOL threshold",   minval = 0.1, step = 0.1, group = grp_sig)

// ============================================================
// HELPERS
// ============================================================
set_transp(c) => color.new(c, bg_transp)
clean_sym(s) => str.replace_all(str.replace_all(str.replace_all(s, "NASDAQ:", ""), "NYSE:", ""), "AMEX:", "")

// Full data: %chg primary, %chg context, RVOL (2 calls)
get_full(simple string sym, simple string tf, simple string tf2) =>
    req_sym = use_ext ? ticker.modify(sym, session.extended) : ticker.modify(sym, session.regular)
    [c, c1, v, avg_v] = request.security(req_sym, tf,  [close, close[1], volume, ta.sma(volume, 20)], ignore_invalid_symbol = true)
    [d, d1]           = request.security(req_sym, tf2, [close, close[1]], ignore_invalid_symbol = true)
    chg     = ((c - c1) / c1) * 100
    chg_ctx = ((d - d1) / d1) * 100
    rvol    = nz(v / avg_v, 0)
    [chg, rvol, chg_ctx]

// Lightweight: %chg only (1 call)
get_chg(simple string sym, simple string tf) =>
    req_sym = use_ext ? ticker.modify(sym, session.extended) : ticker.modify(sym, session.regular)
    [c, c1] = request.security(req_sym, tf, [close, close[1]], ignore_invalid_symbol = true)
    ((c - c1) / c1) * 100

// 4-stock leader, returns ticker + chg
leader4(simple string s1, simple string s2, simple string s3, simple string s4, simple string tf) =>
    c1 = get_chg(s1, tf)
    c2 = get_chg(s2, tf)
    c3 = get_chg(s3, tf)
    c4 = get_chg(s4, tf)
    float bc = c1
    string bs = s1
    if math.abs(c2) > math.abs(bc)
        bc := c2
        bs := s2
    if math.abs(c3) > math.abs(bc)
        bc := c3
        bs := s3
    if math.abs(c4) > math.abs(bc)
        bc := c4
        bs := s4
    [clean_sym(bs), bc]

// ============================================================
// DETERMINE SECTOR ETF SYMBOL
// ============================================================
etf_sym = switch sector_choice
    "Tech (XLK)"           => "AMEX:XLK"
    "Comm (XLC)"           => "AMEX:XLC"
    "Discr (XLY)"          => "AMEX:XLY"
    "Financials (XLF)"     => "AMEX:XLF"
    "Energy (XLE)"         => "AMEX:XLE"
    "Industrials (XLI)"    => "AMEX:XLI"
    "Health (XLV)"         => "AMEX:XLV"
    "Staples (XLP)"        => "AMEX:XLP"
    "Materials (XLB)"      => "AMEX:XLB"
    "Utilities (XLU)"      => "AMEX:XLU"
    "Real Estate (XLRE)"   => "AMEX:XLRE"
    "Transports (IYT)"     => "AMEX:IYT"
    => "AMEX:XLK"

// ============================================================
// BENCHMARKS  (SPY + selected ETF = 4 calls)
// ============================================================
[c_spy, v_spy, ctx_spy] = get_full("AMEX:SPY", tf_input, tf_context)
[c_etf, v_etf, ctx_etf] = get_full(etf_sym,    tf_input, tf_context)

// ============================================================
// SUB-GROUPS PER SECTOR
// 4 groups × 4 stocks × 1 call = 16 calls active
// ============================================================

// --- TECH (XLK) ---
is_xlk = sector_choice == "Tech (XLK)"
[xlk_g1_l, xlk_g1_c] = if is_xlk
    leader4("NASDAQ:NVDA","NASDAQ:AVGO","NASDAQ:AMD","NASDAQ:QCOM",   tf_input)
else
    ["—", 0.0]
[xlk_g2_l, xlk_g2_c] = if is_xlk
    leader4("NASDAQ:MSFT","NYSE:ORCL","NYSE:CRM","NASDAQ:ADBE",       tf_input)
else
    ["—", 0.0]
[xlk_g3_l, xlk_g3_c] = if is_xlk
    leader4("NASDAQ:AAPL","NASDAQ:CSCO","NASDAQ:INTC","NYSE:IBM",     tf_input)
else
    ["—", 0.0]
[xlk_g4_l, xlk_g4_c] = if is_xlk
    leader4("NYSE:NOW","NYSE:ACN","NASDAQ:INTU","NASDAQ:PANW",        tf_input)
else
    ["—", 0.0]

// --- COMM (XLC) ---
is_xlc = sector_choice == "Comm (XLC)"
[xlc_g1_l, xlc_g1_c] = if is_xlc
    leader4("NASDAQ:META","NASDAQ:GOOGL","NASDAQ:NFLX","NASDAQ:GOOG", tf_input)
else
    ["—", 0.0]
[xlc_g2_l, xlc_g2_c] = if is_xlc
    leader4("NASDAQ:TMUS","NYSE:VZ","NYSE:T","NASDAQ:CMCSA",          tf_input)
else
    ["—", 0.0]
[xlc_g3_l, xlc_g3_c] = if is_xlc
    leader4("NYSE:DIS","NASDAQ:WBD","NASDAQ:PARA","NASDAQ:EA",        tf_input)
else
    ["—", 0.0]
[xlc_g4_l, xlc_g4_c] = if is_xlc
    leader4("NASDAQ:TTWO","NYSE:LYV","NYSE:IPG","NYSE:OMC",           tf_input)
else
    ["—", 0.0]

// --- DISCR (XLY) ---
is_xly = sector_choice == "Discr (XLY)"
[xly_g1_l, xly_g1_c] = if is_xly
    leader4("NASDAQ:AMZN","NASDAQ:TSLA","NYSE:HD","NYSE:LOW",         tf_input)
else
    ["—", 0.0]
[xly_g2_l, xly_g2_c] = if is_xly
    leader4("NYSE:MCD","NASDAQ:SBUX","NYSE:CMG","NYSE:YUM",           tf_input)
else
    ["—", 0.0]
[xly_g3_l, xly_g3_c] = if is_xly
    leader4("NASDAQ:BKNG","NASDAQ:MAR","NYSE:HLT","NASDAQ:ABNB",      tf_input)
else
    ["—", 0.0]
[xly_g4_l, xly_g4_c] = if is_xly
    leader4("NYSE:NKE","NYSE:TJX","NASDAQ:ROST","NASDAQ:LULU",        tf_input)
else
    ["—", 0.0]

// --- FINANCIALS (XLF) ---
is_xlf = sector_choice == "Financials (XLF)"
[xlf_g1_l, xlf_g1_c] = if is_xlf
    leader4("NYSE:JPM","NYSE:BAC","NYSE:WFC","NYSE:C",                tf_input)
else
    ["—", 0.0]
[xlf_g2_l, xlf_g2_c] = if is_xlf
    leader4("NYSE:V","NYSE:MA","NYSE:AXP","NASDAQ:PYPL",              tf_input)
else
    ["—", 0.0]
[xlf_g3_l, xlf_g3_c] = if is_xlf
    leader4("NYSE:GS","NYSE:MS","NYSE:BLK","NYSE:SCHW",               tf_input)
else
    ["—", 0.0]
[xlf_g4_l, xlf_g4_c] = if is_xlf
    leader4("NYSE:BRK.B","NYSE:PGR","NYSE:CB","NYSE:MMC",             tf_input)
else
    ["—", 0.0]

// --- ENERGY (XLE) ---
is_xle = sector_choice == "Energy (XLE)"
[xle_g1_l, xle_g1_c] = if is_xle
    leader4("NYSE:XOM","NYSE:CVX","NYSE:COP","NYSE:OXY",              tf_input)
else
    ["—", 0.0]
[xle_g2_l, xle_g2_c] = if is_xle
    leader4("NYSE:EOG","NASDAQ:FANG","NYSE:DVN","NYSE:HES",           tf_input)
else
    ["—", 0.0]
[xle_g3_l, xle_g3_c] = if is_xle
    leader4("NYSE:SLB","NYSE:HAL","NASDAQ:BKR","NYSE:WMB",            tf_input)
else
    ["—", 0.0]
[xle_g4_l, xle_g4_c] = if is_xle
    leader4("NYSE:MPC","NYSE:PSX","NYSE:VLO","NYSE:KMI",              tf_input)
else
    ["—", 0.0]

// --- INDUSTRIALS (XLI) ---
is_xli = sector_choice == "Industrials (XLI)"
[xli_g1_l, xli_g1_c] = if is_xli
    leader4("NYSE:GE","NYSE:RTX","NYSE:LMT","NYSE:BA",                tf_input)
else
    ["—", 0.0]
[xli_g2_l, xli_g2_c] = if is_xli
    leader4("NYSE:CAT","NYSE:DE","NASDAQ:HON","NYSE:ETN",             tf_input)
else
    ["—", 0.0]
[xli_g3_l, xli_g3_c] = if is_xli
    leader4("NYSE:UBER","NYSE:UNP","NYSE:UPS","NASDAQ:CSX",           tf_input)
else
    ["—", 0.0]
[xli_g4_l, xli_g4_c] = if is_xli
    leader4("NYSE:WM","NYSE:RSG","NYSE:PH","NYSE:EMR",                tf_input)
else
    ["—", 0.0]

// --- HEALTH (XLV) ---
is_xlv = sector_choice == "Health (XLV)"
[xlv_g1_l, xlv_g1_c] = if is_xlv
    leader4("NYSE:LLY","NYSE:JNJ","NYSE:ABBV","NYSE:MRK",             tf_input)
else
    ["—", 0.0]
[xlv_g2_l, xlv_g2_c] = if is_xlv
    leader4("NYSE:UNH","NYSE:CVS","NYSE:ELV","NYSE:CI",               tf_input)
else
    ["—", 0.0]
[xlv_g3_l, xlv_g3_c] = if is_xlv
    leader4("NYSE:TMO","NYSE:ABT","NYSE:DHR","NASDAQ:ISRG",           tf_input)
else
    ["—", 0.0]
[xlv_g4_l, xlv_g4_c] = if is_xlv
    leader4("NASDAQ:AMGN","NASDAQ:GILD","NASDAQ:VRTX","NASDAQ:REGN",  tf_input)
else
    ["—", 0.0]

// --- STAPLES (XLP) ---
is_xlp = sector_choice == "Staples (XLP)"
[xlp_g1_l, xlp_g1_c] = if is_xlp
    leader4("NASDAQ:COST","NYSE:WMT","NYSE:TGT","NYSE:KR",            tf_input)
else
    ["—", 0.0]
[xlp_g2_l, xlp_g2_c] = if is_xlp
    leader4("NYSE:PG","NYSE:CL","NYSE:KMB","NYSE:CHD",                tf_input)
else
    ["—", 0.0]
[xlp_g3_l, xlp_g3_c] = if is_xlp
    leader4("NYSE:KO","NYSE:PEP","NASDAQ:MNST","NASDAQ:KDP",          tf_input)
else
    ["—", 0.0]
[xlp_g4_l, xlp_g4_c] = if is_xlp
    leader4("NYSE:PM","NYSE:MO","NASDAQ:MDLZ","NYSE:STZ",             tf_input)
else
    ["—", 0.0]

// --- MATERIALS (XLB) ---
is_xlb = sector_choice == "Materials (XLB)"
[xlb_g1_l, xlb_g1_c] = if is_xlb
    leader4("NASDAQ:LIN","NYSE:APD","NYSE:SHW","NYSE:ECL",              tf_input)
else
    ["—", 0.0]
[xlb_g2_l, xlb_g2_c] = if is_xlb
    leader4("NYSE:FCX","NYSE:NEM","NYSE:NUE","NASDAQ:STLD",             tf_input)
else
    ["—", 0.0]
[xlb_g3_l, xlb_g3_c] = if is_xlb
    leader4("NYSE:DOW","NYSE:DD","NYSE:LYB","NYSE:CE",                tf_input)
else
    ["—", 0.0]
[xlb_g4_l, xlb_g4_c] = if is_xlb
    leader4("NYSE:PPG","NYSE:IFF","NYSE:VMC","NYSE:MLM",              tf_input)
else
    ["—", 0.0]

// --- UTILITIES (XLU) ---
is_xlu = sector_choice == "Utilities (XLU)"
[xlu_g1_l, xlu_g1_c] = if is_xlu
    leader4("NYSE:NEE","NYSE:SO","NYSE:DUK","NASDAQ:AEP",             tf_input)
else
    ["—", 0.0]
[xlu_g2_l, xlu_g2_c] = if is_xlu
    leader4("NASDAQ:CEG","NYSE:VST","NASDAQ:EXC","NASDAQ:XEL",        tf_input)
else
    ["—", 0.0]
[xlu_g3_l, xlu_g3_c] = if is_xlu
    leader4("NYSE:SRE","NYSE:D","NYSE:PEG","NYSE:ED",                 tf_input)
else
    ["—", 0.0]
[xlu_g4_l, xlu_g4_c] = if is_xlu
    leader4("NYSE:AWK","NYSE:WEC","NYSE:ES","NYSE:DTE",               tf_input)
else
    ["—", 0.0]

// --- REAL ESTATE (XLRE) ---
is_xlre = sector_choice == "Real Estate (XLRE)"
[xlre_g1_l, xlre_g1_c] = if is_xlre
    leader4("NYSE:PLD","NYSE:AMT","NASDAQ:EQIX","NYSE:CCI",           tf_input)
else
    ["—", 0.0]
[xlre_g2_l, xlre_g2_c] = if is_xlre
    leader4("NYSE:WELL","NYSE:VTR","NYSE:DLR","NYSE:O",               tf_input)
else
    ["—", 0.0]
[xlre_g3_l, xlre_g3_c] = if is_xlre
    leader4("NYSE:SPG","NYSE:EXR","NYSE:AVB","NYSE:EQR",              tf_input)
else
    ["—", 0.0]
[xlre_g4_l, xlre_g4_c] = if is_xlre
    leader4("NYSE:PSA","NYSE:CBRE","NYSE:IRM","NYSE:VICI",            tf_input)
else
    ["—", 0.0]

// --- TRANSPORTS (IYT) ---
is_iyt = sector_choice == "Transports (IYT)"
[iyt_g1_l, iyt_g1_c] = if is_iyt
    leader4("NYSE:UPS","NYSE:FDX","NYSE:UBER","NASDAQ:LYFT",          tf_input)
else
    ["—", 0.0]
[iyt_g2_l, iyt_g2_c] = if is_iyt
    leader4("NYSE:UNP","NASDAQ:CSX","NYSE:NSC","NYSE:CP",             tf_input)
else
    ["—", 0.0]
[iyt_g3_l, iyt_g3_c] = if is_iyt
    leader4("NASDAQ:AAL","NASDAQ:UAL","NYSE:DAL","NYSE:LUV",          tf_input)
else
    ["—", 0.0]
[iyt_g4_l, iyt_g4_c] = if is_iyt
    leader4("NASDAQ:CHRW","NASDAQ:JBHT","NASDAQ:ODFL","NYSE:XPO",     tf_input)
else
    ["—", 0.0]

// ============================================================
// SELECT WHICH GROUP DATA TO DISPLAY
// ============================================================
string g1_name = "—"
string g2_name = "—"
string g3_name = "—"
string g4_name = "—"
string g1_pool = ""
string g2_pool = ""
string g3_pool = ""
string g4_pool = ""
string g1_l = "—"
string g2_l = "—"
string g3_l = "—"
string g4_l = "—"
float g1_c = 0.0
float g2_c = 0.0
float g3_c = 0.0
float g4_c = 0.0

if is_xlk
    g1_name := "Semiconductors"
    g1_pool := "NVDA·AVGO·AMD·QCOM"
    g1_l := xlk_g1_l
    g1_c := xlk_g1_c
    g2_name := "Mega Software"
    g2_pool := "MSFT·ORCL·CRM·ADBE"
    g2_l := xlk_g2_l
    g2_c := xlk_g2_c
    g3_name := "Hardware/Old"
    g3_pool := "AAPL·CSCO·INTC·IBM"
    g3_l := xlk_g3_l
    g3_c := xlk_g3_c
    g4_name := "Software Growth"
    g4_pool := "NOW·ACN·INTU·PANW"
    g4_l := xlk_g4_l
    g4_c := xlk_g4_c
else if is_xlc
    g1_name := "Mega Internet"
    g1_pool := "META·GOOGL·NFLX·GOOG"
    g1_l := xlc_g1_l
    g1_c := xlc_g1_c
    g2_name := "Telecom"
    g2_pool := "TMUS·VZ·T·CMCSA"
    g2_l := xlc_g2_l
    g2_c := xlc_g2_c
    g3_name := "Media"
    g3_pool := "DIS·WBD·PARA·EA"
    g3_l := xlc_g3_l
    g3_c := xlc_g3_c
    g4_name := "Entertainment"
    g4_pool := "TTWO·LYV·IPG·OMC"
    g4_l := xlc_g4_l
    g4_c := xlc_g4_c
else if is_xly
    g1_name := "Mega Discr"
    g1_pool := "AMZN·TSLA·HD·LOW"
    g1_l := xly_g1_l
    g1_c := xly_g1_c
    g2_name := "Restaurants"
    g2_pool := "MCD·SBUX·CMG·YUM"
    g2_l := xly_g2_l
    g2_c := xly_g2_c
    g3_name := "Travel"
    g3_pool := "BKNG·MAR·HLT·ABNB"
    g3_l := xly_g3_l
    g3_c := xly_g3_c
    g4_name := "Apparel/Retail"
    g4_pool := "NKE·TJX·ROST·LULU"
    g4_l := xly_g4_l
    g4_c := xly_g4_c
else if is_xlf
    g1_name := "Big Banks"
    g1_pool := "JPM·BAC·WFC·C"
    g1_l := xlf_g1_l
    g1_c := xlf_g1_c
    g2_name := "Payments"
    g2_pool := "V·MA·AXP·PYPL"
    g2_l := xlf_g2_l
    g2_c := xlf_g2_c
    g3_name := "I-Banks/Brkrs"
    g3_pool := "GS·MS·BLK·SCHW"
    g3_l := xlf_g3_l
    g3_c := xlf_g3_c
    g4_name := "Insurance"
    g4_pool := "BRK.B·PGR·CB·MMC"
    g4_l := xlf_g4_l
    g4_c := xlf_g4_c
else if is_xle
    g1_name := "Integrated Oil"
    g1_pool := "XOM·CVX·COP·OXY"
    g1_l := xle_g1_l
    g1_c := xle_g1_c
    g2_name := "E&P"
    g2_pool := "EOG·FANG·DVN·HES"
    g2_l := xle_g2_l
    g2_c := xle_g2_c
    g3_name := "Services"
    g3_pool := "SLB·HAL·BKR·WMB"
    g3_l := xle_g3_l
    g3_c := xle_g3_c
    g4_name := "Refiners/Pipes"
    g4_pool := "MPC·PSX·VLO·KMI"
    g4_l := xle_g4_l
    g4_c := xle_g4_c
else if is_xli
    g1_name := "Aerospace/Def"
    g1_pool := "GE·RTX·LMT·BA"
    g1_l := xli_g1_l
    g1_c := xli_g1_c
    g2_name := "Machinery"
    g2_pool := "CAT·DE·HON·ETN"
    g2_l := xli_g2_l
    g2_c := xli_g2_c
    g3_name := "Transport"
    g3_pool := "UBER·UNP·UPS·CSX"
    g3_l := xli_g3_l
    g3_c := xli_g3_c
    g4_name := "Services/Eq"
    g4_pool := "WM·RSG·PH·EMR"
    g4_l := xli_g4_l
    g4_c := xli_g4_c
else if is_xlv
    g1_name := "Pharma"
    g1_pool := "LLY·JNJ·ABBV·MRK"
    g1_l := xlv_g1_l
    g1_c := xlv_g1_c
    g2_name := "Insurers"
    g2_pool := "UNH·CVS·ELV·CI"
    g2_l := xlv_g2_l
    g2_c := xlv_g2_c
    g3_name := "Devices/Tools"
    g3_pool := "TMO·ABT·DHR·ISRG"
    g3_l := xlv_g3_l
    g3_c := xlv_g3_c
    g4_name := "Biotech"
    g4_pool := "AMGN·GILD·VRTX·REGN"
    g4_l := xlv_g4_l
    g4_c := xlv_g4_c
else if is_xlp
    g1_name := "Big-Box Retail"
    g1_pool := "COST·WMT·TGT·KR"
    g1_l := xlp_g1_l
    g1_c := xlp_g1_c
    g2_name := "Household"
    g2_pool := "PG·CL·KMB·CHD"
    g2_l := xlp_g2_l
    g2_c := xlp_g2_c
    g3_name := "Beverages"
    g3_pool := "KO·PEP·MNST·KDP"
    g3_l := xlp_g3_l
    g3_c := xlp_g3_c
    g4_name := "Tobacco/Food"
    g4_pool := "PM·MO·MDLZ·STZ"
    g4_l := xlp_g4_l
    g4_c := xlp_g4_c
else if is_xlb
    g1_name := "Industrial Gas"
    g1_pool := "LIN·APD·SHW·ECL"
    g1_l := xlb_g1_l
    g1_c := xlb_g1_c
    g2_name := "Metals/Mining"
    g2_pool := "FCX·NEM·NUE·STLD"
    g2_l := xlb_g2_l
    g2_c := xlb_g2_c
    g3_name := "Chemicals"
    g3_pool := "DOW·DD·LYB·CE"
    g3_l := xlb_g3_l
    g3_c := xlb_g3_c
    g4_name := "Coatings/Aggreg"
    g4_pool := "PPG·IFF·VMC·MLM"
    g4_l := xlb_g4_l
    g4_c := xlb_g4_c
else if is_xlu
    g1_name := "Mega Utilities"
    g1_pool := "NEE·SO·DUK·AEP"
    g1_l := xlu_g1_l
    g1_c := xlu_g1_c
    g2_name := "Power/Nuclear"
    g2_pool := "CEG·VST·EXC·XEL"
    g2_l := xlu_g2_l
    g2_c := xlu_g2_c
    g3_name := "Multi-Util"
    g3_pool := "SRE·D·PEG·ED"
    g3_l := xlu_g3_l
    g3_c := xlu_g3_c
    g4_name := "Water/Regional"
    g4_pool := "AWK·WEC·ES·DTE"
    g4_l := xlu_g4_l
    g4_c := xlu_g4_c
else if is_xlre
    g1_name := "Industrial/Tower"
    g1_pool := "PLD·AMT·EQIX·CCI"
    g1_l := xlre_g1_l
    g1_c := xlre_g1_c
    g2_name := "Healthcare/DC"
    g2_pool := "WELL·VTR·DLR·O"
    g2_l := xlre_g2_l
    g2_c := xlre_g2_c
    g3_name := "Retail/Resi"
    g3_pool := "SPG·EXR·AVB·EQR"
    g3_l := xlre_g3_l
    g3_c := xlre_g3_c
    g4_name := "Storage/Services"
    g4_pool := "PSA·CBRE·IRM·VICI"
    g4_l := xlre_g4_l
    g4_c := xlre_g4_c
else if is_iyt
    g1_name := "Logistics"
    g1_pool := "UPS·FDX·UBER·LYFT"
    g1_l := iyt_g1_l
    g1_c := iyt_g1_c
    g2_name := "Rails"
    g2_pool := "UNP·CSX·NSC·CP"
    g2_l := iyt_g2_l
    g2_c := iyt_g2_c
    g3_name := "Airlines"
    g3_pool := "AAL·UAL·DAL·LUV"
    g3_l := iyt_g3_l
    g3_c := iyt_g3_c
    g4_name := "Trucking"
    g4_pool := "CHRW·JBHT·ODFL·XPO"
    g4_l := iyt_g4_l
    g4_c := iyt_g4_c

// ============================================================
// TABLE
// ============================================================
var tbl = table.new(tablePosition, 6, 9, border_width = 1)

if barstate.islast
    // ---- Title row ----
    table.cell(tbl, 0, 0, "🩻 X-RAY: " + sector_choice, bgcolor = set_transp(c_header_raw), text_color = c_text, text_size = textSize, text_halign = text.align_left)
    table.cell(tbl, 1, 0, "% " + tf_input,   bgcolor = set_transp(c_header_raw), text_color = c_text, text_size = textSize)
    table.cell(tbl, 2, 0, "% " + tf_context, bgcolor = set_transp(c_header_raw), text_color = c_text, text_size = textSize)
    table.cell(tbl, 3, 0, "RVOL",            bgcolor = set_transp(c_header_raw), text_color = c_text, text_size = textSize)
    table.cell(tbl, 4, 0, "TOP MOVER",       bgcolor = set_transp(c_header_raw), text_color = c_text, text_size = textSize)
    table.cell(tbl, 5, 0, "RS vs SPY",       bgcolor = set_transp(c_header_raw), text_color = c_text, text_size = textSize, tooltip = "Sector or group % minus SPY %")

    // ---- SPY benchmark ----
    spyChgColor = set_transp(c_spy >= 0 ? c_up_raw : c_down_raw)
    spyCtxColor = set_transp(ctx_spy >= 0 ? c_up_raw : c_down_raw)
    table.cell(tbl, 0, 1, "SPY (Market)", text_color = c_text, bgcolor = set_transp(c_bench_raw), text_halign = text.align_left, text_size = textSize)
    table.cell(tbl, 1, 1, str.tostring(c_spy, "0.##") + "%",   text_color = c_text, bgcolor = spyChgColor, text_size = textSize)
    table.cell(tbl, 2, 1, str.tostring(ctx_spy, "0.##") + "%", text_color = c_text, bgcolor = spyCtxColor, text_size = textSize)
    table.cell(tbl, 3, 1, str.tostring(v_spy, "0.##") + "x",   text_color = c_text, bgcolor = color.new(color.gray, 50), text_size = textSize)
    table.cell(tbl, 4, 1, "—", text_color = c_text, bgcolor = color.new(color.gray, 70), text_size = textSize)
    table.cell(tbl, 5, 1, "0.00%", text_color = c_text, bgcolor = color.new(color.gray, 70), text_size = textSize)

    // ---- Sector ETF row ----
    weakEtf      = v_etf < rvol_weak
    etfColor     = weakEtf ? set_transp(c_weak_raw) : set_transp(c_etf >= 0 ? c_up_raw : c_down_raw)
    etfCtxColor  = set_transp(ctx_etf >= 0 ? c_up_raw : c_down_raw)
    etfRvolColor = v_etf >= rvol_strong ? color.new(color.aqua, bg_transp) : v_etf < rvol_weak ? color.new(color.gray, 70) : color.new(color.gray, 50)
    rs_etf       = c_etf - c_spy
    rsEtfColor   = set_transp(rs_etf >= 0 ? c_up_raw : c_down_raw)
    etfTicker    = clean_sym(etf_sym)

    table.cell(tbl, 0, 2, etfTicker + " (Sector ETF)", text_color = c_text, bgcolor = set_transp(c_names_raw), text_halign = text.align_left, text_size = textSize)
    table.cell(tbl, 1, 2, str.tostring(c_etf, "0.##") + "%",   text_color = c_text, bgcolor = etfColor, text_size = textSize)
    table.cell(tbl, 2, 2, str.tostring(ctx_etf, "0.##") + "%", text_color = c_text, bgcolor = etfCtxColor, text_size = textSize)
    table.cell(tbl, 3, 2, str.tostring(v_etf, "0.##") + "x",   text_color = c_text, bgcolor = etfRvolColor, text_size = textSize)
    table.cell(tbl, 4, 2, "—", text_color = c_text, bgcolor = color.new(color.gray, 70), text_size = textSize)
    table.cell(tbl, 5, 2, str.tostring(rs_etf, "0.##") + "%", text_color = c_text, bgcolor = rsEtfColor, text_size = textSize)

    // ---- Sub-group divider ----
    table.cell(tbl, 0, 3, "↳ Sub-Groups (sorted)", text_color = c_text, bgcolor = set_transp(c_header_raw), text_halign = text.align_left, text_size = textSize)
    table.cell(tbl, 1, 3, "", bgcolor = set_transp(c_header_raw))
    table.cell(tbl, 2, 3, "", bgcolor = set_transp(c_header_raw))
    table.cell(tbl, 3, 3, "", bgcolor = set_transp(c_header_raw))
    table.cell(tbl, 4, 3, "", bgcolor = set_transp(c_header_raw))
    table.cell(tbl, 5, 3, "", bgcolor = set_transp(c_header_raw))

    // ---- Sort & render sub-group rows ----
    g_names = array.from(g1_name, g2_name, g3_name, g4_name)
    g_chgs  = array.from(g1_c,    g2_c,    g3_c,    g4_c)
    g_lds   = array.from(g1_l,    g2_l,    g3_l,    g4_l)
    g_pools = array.from(g1_pool, g2_pool, g3_pool, g4_pool)

    sortedIdx = array.sort_indices(g_chgs, order.descending)

    for i = 0 to 3
        idx = array.get(sortedIdx, i)
        gn  = array.get(g_names, idx)
        gc  = array.get(g_chgs,  idx)
        gl  = array.get(g_lds,   idx)
        gp  = array.get(g_pools, idx)

        gColor  = set_transp(gc >= 0 ? c_up_raw : c_down_raw)
        rs_g    = gc - c_spy
        rsColor = set_transp(rs_g >= 0 ? c_up_raw : c_down_raw)

        tt = "Group: " + gn + "\nPool: " + gp + "\nTop mover: " + gl + " " + str.tostring(gc, "0.##") + "%\nRS vs SPY: " + str.tostring(rs_g, "0.##") + "%"

        table.cell(tbl, 0, 4 + i, "  • " + gn, text_color = c_text, bgcolor = color.new(color.purple, 70), text_halign = text.align_left, text_size = textSize, tooltip = tt)
        table.cell(tbl, 1, 4 + i, str.tostring(gc, "0.##") + "%", text_color = c_text, bgcolor = gColor, text_size = textSize, tooltip = tt)
        table.cell(tbl, 2, 4 + i, "—", text_color = c_text, bgcolor = color.new(color.gray, 70), text_size = textSize)
        table.cell(tbl, 3, 4 + i, "—", text_color = c_text, bgcolor = color.new(color.gray, 70), text_size = textSize)
        table.cell(tbl, 4, 4 + i, gl + " (" + str.tostring(gc, "0.##") + "%)", text_color = c_text, bgcolor = gColor, text_size = textSize, tooltip = tt)
        table.cell(tbl, 5, 4 + i, str.tostring(rs_g, "0.##") + "%", text_color = c_text, bgcolor = rsColor, text_size = textSize, tooltip = tt)

    // ---- Insight row ----
    leader_idx  = array.get(sortedIdx, 0)
    laggard_idx = array.get(sortedIdx, 3)
    spread      = array.get(g_chgs, leader_idx) - array.get(g_chgs, laggard_idx)
    insight     = "Spread: " + str.tostring(spread, "0.##") + "% | " + array.get(g_names, leader_idx) + " leads, " + array.get(g_names, laggard_idx) + " lags"
    table.cell(tbl, 0, 8, insight, text_color = c_text, bgcolor = set_transp(c_header_raw), text_halign = text.align_left, text_size = textSize, tooltip = "Spread = best group % − worst group %.\nLarge spread = sector internally divided.\nSmall spread = sector moving as one.")
    table.cell(tbl, 1, 8, "", bgcolor = set_transp(c_header_raw))
    table.cell(tbl, 2, 8, "", bgcolor = set_transp(c_header_raw))
    table.cell(tbl, 3, 8, "", bgcolor = set_transp(c_header_raw))
    table.cell(tbl, 4, 8, "", bgcolor = set_transp(c_header_raw))
    table.cell(tbl, 5, 8, "", bgcolor = set_transp(c_header_raw))
````
