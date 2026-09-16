<!-- tradingview-pine-id: PUB;93e6a0bffaf14806811af7a2148e6214 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Macro Supersector Matrix & Stock Alignment Dashboard

Source: https://www.tradingview.com/script/nIR9N4st-Macro-Supersector-Matrix-Stock-Alignment-Dashboard/

## Description

** Overview:

The "Macro Supersector Matrix & Stock Alignment Dashboard" is an intermarket analysis tool designed for swing traders and portfolio managers looking to track institutional capital flows across major US market sectors.

Instead of monitoring 11 individual ETF charts, this dashboard groups the S&P 500 sectors into "3 Core Supersectors" and dynamically tracks whether your current charted asset is aligned with broader market health.

** Core Mechanics & Supersector Architecture:

1. Growth / Risk-On Supersector:
   - Aggregates **XLK** (Technology), **XLY** (Consumer Discretionary), and **XLC** (Communications).
2. Economic Cyclicals Supersector:
   - Aggregates **XLF** (Financials), **XLI** (Industrials), **XLB** (Materials), and **XLE** (Energy).
3. Defensive / Safe-Haven Supersector:
   - Aggregates **XLV** (Healthcare), **XLP** (Consumer Staples), **XLU** (Utilities), and **XLRE** (Real Estate).

** Key Features:

- Institutional Volume Filter (🔥 Symbol): Highlights when sector movement is supported by above-average daily volume (SMA 20), indicating institutional participation rather than low-volume drift.

- Dynamic Stock Mapper: Automatically identifies the sector for mega-cap stocks (e.g., AAPL, NVDA, TSLA, JPM, LLY) and compares their intraday performance against macro sector flows.

- Macro Health Bias (0-100%): Weighted quantitative score determining whether current market broad-breadth conditions favor long or short swing trades.

- Pine Script v6 Codebase: Fully optimized with consolidated multi-timeframe requests to ensure fast loading times and zero repainting.

---

## Source Code

````pine
//@version=6
indicator("Macro Supersector Matrix & Stock Alignment Dashboard", 
     overlay=true, 
     shorttitle="Macro Mapper")

// ==========================================
// 1. INPUTS
// ==========================================
vol_length = input.int(20, title="Período SMA Volumen", minval=5, maxval=100)

// ==========================================
// 2. FUNCIONES DE CAPTURA DE DATOS
// ==========================================
f_get_data(string ticker) =>
    request.security(ticker, "D", [close[1], close, volume, ta.sma(volume, vol_length)], ignore_invalid_symbol=true)

f_pct(float c_now, float c_prev) =>
    not na(c_prev) and c_prev != 0 ? ((c_now - c_prev) / c_prev) * 100 : 0.0

// Captura Consolidada de Datos
[spy_p, spy_c, spy_v, spy_v_sma] = f_get_data("AMEX:SPY")
[xlk_p, xlk_c, xlk_v, xlk_v_sma] = f_get_data("AMEX:XLK")
[xly_p, xly_c, xly_v, xly_v_sma] = f_get_data("AMEX:XLY")
[xlc_p, xlc_c, xlc_v, xlc_v_sma] = f_get_data("AMEX:XLC")

[xlf_p, xlf_c, xlf_v, xlf_v_sma] = f_get_data("AMEX:XLF")
[xli_p, xli_c, xli_v, xli_v_sma] = f_get_data("AMEX:XLI")
[xlb_p, xlb_c, xlb_v, xlb_v_sma] = f_get_data("AMEX:XLB")
[xle_p, xle_c, xle_v, xle_v_sma] = f_get_data("AMEX:XLE")

[xlv_p, xlv_c, xlv_v, xlv_v_sma] = f_get_data("AMEX:XLV")
[xlp_p, xlp_c, xlp_v, xlp_v_sma] = f_get_data("AMEX:XLP")
[xlu_p, xlu_c, xlu_v, xlu_v_sma] = f_get_data("AMEX:XLU")
[xlre_p, xlre_c, xlre_v, xlre_v_sma] = f_get_data("AMEX:XLRE")

// ==========================================
// 3. CÁLCULO DE RENDIMIENTO Y VOLUMEN
// ==========================================
spy_chg = f_pct(spy_c, spy_p)

// Growth
growth_chg = (f_pct(xlk_c, xlk_p) + f_pct(xly_c, xly_p) + f_pct(xlc_c, xlc_p)) / 3.0
growth_v   = (xlk_v > xlk_v_sma) or (xly_v > xly_v_sma) or (xlc_v > xlc_v_sma)

// Cyclicals
cycl_chg   = (f_pct(xlf_c, xlf_p) + f_pct(xli_c, xli_p) + f_pct(xlb_c, xlb_p) + f_pct(xle_c, xle_p)) / 4.0
cycl_v     = (xlf_v > xlf_v_sma) or (xli_v > xli_v_sma) or (xlb_v > xlb_v_sma) or (xle_v > xle_v_sma)

// Defensives
def_chg    = (f_pct(xlv_c, xlv_p) + f_pct(xlp_c, xlp_p) + f_pct(xlu_c, xlu_p) + f_pct(xlre_c, xlre_p)) / 4.0
def_v      = (xlv_v > xlv_v_sma) or (xlp_v > xlp_v_sma) or (xlu_v > xlu_v_sma) or (xlre_v > xlre_v_sma)

// Scoring Macro Generalizado
score(float chg, bool v) => chg > 0 ? (v ? 25.0 : 12.5) : 0.0
macro_bias = score(growth_chg, growth_v) + score(cycl_chg, cycl_v) + score(def_chg, def_v) + (spy_chg > 0 ? 25.0 : 0.0)

// ==========================================
// 4. MAPEO DINÁMICO DEL TICKER ACTUAL
// ==========================================
string sym = syminfo.ticker
string sector_pertenencia = "Activo Indep."

if sym == "AAPL" or sym == "MSFT" or sym == "NVDA" or sym == "AVGO" or sym == "AMD"
    sector_pertenencia := "Crecimiento - XLK"
else if sym == "TSLA" or sym == "AMZN" or sym == "HD" or sym == "NKE"
    sector_pertenencia := "Crecimiento - XLY"
else if sym == "META" or sym == "GOOGL" or sym == "GOOG" or sym == "NFLX"
    sector_pertenencia := "Crecimiento - XLC"
else if sym == "JPM" or sym == "BAC" or sym == "WFC" or sym == "MS" or sym == "GS"
    sector_pertenencia := "Cíclico - XLF"
else if sym == "CAT" or sym == "GE" or sym == "UNP" or sym == "HON"
    sector_pertenencia := "Cíclico - XLI"
else if sym == "XOM" or sym == "CVX" or sym == "SLB"
    sector_pertenencia := "Cíclico - XLE"
else if sym == "LIN" or sym == "APD" or sym == "FCX"
    sector_pertenencia := "Cíclico - XLB"
else if sym == "LLY" or sym == "UNH" or sym == "JNJ" or sym == "MRK" or sym == "ABBV"
    sector_pertenencia := "Defensivo - XLV"
else if sym == "PG" or sym == "COST" or sym == "WMT" or sym == "KO" or sym == "PEP"
    sector_pertenencia := "Defensivo - XLP"
else if sym == "NEE" or sym == "SO" or sym == "DUK"
    sector_pertenencia := "Defensivo - XLU"
else if sym == "PLD" or sym == "AMT" or sym == "CCI"
    sector_pertenencia := "Defensivo - XLRE"

current_chg = f_pct(close, close[1])
current_v_ok = volume > ta.sma(volume, vol_length)

// ==========================================
// 5. DISEÑO VISUAL
// ==========================================
var table macro_panel = table.new(position.bottom_right, 3, 7, bgcolor=color.new(color.black, 15), border_color=color.gray, border_width=1)

draw_row(table_id, row, name, chg, v_active) =>
    color c_bg = chg > 0 ? color.new(color.green, 50) : color.new(color.red, 50)
    table.cell(table_id, 0, row, name, text_color=color.white, text_size=size.normal)
    table.cell(table_id, 1, row, str.tostring(chg, "#.##") + "%", text_color=color.white, text_size=size.normal, bgcolor=c_bg)
    table.cell(table_id, 2, row, v_active ? "🔥" : " ", text_color=color.white, text_size=size.normal)

if barstate.islast
    table.cell(macro_panel, 0, 0, "Bloque Macro", text_color=color.white, text_size=size.large, bgcolor=color.navy)
    table.cell(macro_panel, 1, 0, "Media %", text_color=color.white, text_size=size.large, bgcolor=color.navy)
    table.cell(macro_panel, 2, 0, "Inst.", text_color=color.white, text_size=size.large, bgcolor=color.navy)
    
    draw_row(macro_panel, 1, "Crecimiento / Riesgo (XLK, XLY, XLC)", growth_chg, growth_v)
    draw_row(macro_panel, 2, "Ciclo Económico (XLF, XLI, XLB, XLE)", cycl_chg, cycl_v)
    draw_row(macro_panel, 3, "Defensivos / Refugio (XLV, XLP, XLU, XLRE)", def_chg, def_v)
    
    table.cell(macro_panel, 0, 4, "SPY (S&P 500 ETF)", text_color=color.yellow, text_size=size.normal)
    table.cell(macro_panel, 1, 4, str.tostring(spy_chg, "#.##") + "%", text_color=color.yellow, text_size=size.normal, bgcolor=spy_chg > 0 ? color.new(color.green, 60) : color.new(color.red, 60))
    table.cell(macro_panel, 2, 4, "---", text_color=color.gray, text_size=size.normal)
    
    string row_name = "Activo: " + syminfo.ticker + " (" + sector_pertenencia + ")"
    draw_row(macro_panel, 5, row_name, current_chg, current_v_ok)
    
    color color_bias = macro_bias >= 75 ? color.green : (macro_bias <= 25 ? color.red : color.orange)
    table.cell(macro_panel, 0, 6, "Salud Estructural Swing:", text_color=color.white, text_size=size.large, bgcolor=color.new(color_bias, 30))
    table.cell(macro_panel, 1, 6, str.tostring(math.round(macro_bias)) + "%", text_color=color.white, text_size=size.large, bgcolor=color.new(color_bias, 30))
    table.cell(macro_panel, 2, 6, macro_bias > 50 ? "🐂" : "🐻", text_color=color.white, text_size=size.large, bgcolor=color.new(color_bias, 30))
````
