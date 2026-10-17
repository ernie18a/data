# QuantAbundancia - AI Bubble Map

- url: https://www.tradingview.com/script/4x0qUN1g-QuantAbundancia-AI-Bubble-Map/
- type: indicator
- pine_id: PUB;d54a76473d514a7784ed6402b2f4efe0
- version: 1.0

## Description

Methodology
━━━━━━━━━━━
This indicator overlays QuantAbundancia's bubble framework on any TradingView chart. We classify ~80 AI-adjacent stocks into 12 thematic blocs and measure each bloc's 252-day residualized correlation — that is, the correlation of each constituent's returns AFTER stripping out [symbol="AMEX:SPY"]AMEX:SPY[/symbol] beta. What's left is the idiosyncratic component: how much of the price action is real thematic flow vs market beta in costume.

What it shows
━━━━━━━━━━━━━
For the chart's symbol, the indicator displays:
• Which bubble it belongs to (Quantum, Memory, Compute, etc.)
• That bubble's 252-day residualized correlation + verdict
• Editorial Fib key level (if we've marked one)

Verdict legend
━━━━━━━━━━━━━━
🟢 strongest / tightest / validated → real bloc, idiosyncratic flow
🟡 validating / moderate / speculative → emerging, monitor
🔴 FAILED → market beta in costume, NOT a real bloc

Bubbles covered
━━━━━━━━━━━━━━━
Quantum (0.76 strongest) · Semi Equipment (0.82 tightest) · Memory / HBM (0.71 validated) · Cooling / DC Infra (0.70 validated) · Compute / GPUs (0.65 moderate) · Networking / Optical (0.60 validating) · Space / Sat Comms (0.60 validating) · Datacenter Power (0.55 validating) · Nuclear / SMR (0.70 speculative) · AI Software (0.10 FAILED) · Hyperscalers (0.05 FAILED) · Robotics (0.20 FAILED)

Editorial Fib key levels
━━━━━━━━━━━━━━━━━━━━━━━━
48 tickers have user-curated Fib levels marked (NVDA $71, MU $341, ASML $1205, ASTS $63, RKLB $69, OKLO $69, etc.) — drawn as horizontal dashed lines.

Data source
━━━━━━━━━━━
Data is embedded as constants in this script. The live truth lives at quantabundancia.com — methodology article: quantabundancia.com/articles/residualized-correlation. Daily refreshed digest at quantabundancia.com/today.

This is observational data only — not buy/sell signals. We map flows; you bring the conviction.

## Source Code

````pine
// © QuantAbundancia · Released under MIT
//
// =====================================================================
// QuantAbundancia · AI Bubble Map
//
// Surfaces our 12-bubble taxonomy with 252-day residualized correlation
// (strip $SPY beta, keep idiosyncratic flow) and editorial Fib key levels
// directly on any TradingView chart.
//
// Methodology:  https://quantabundancia.com/articles/residualized-correlation
// Live data:    https://api.quantabundancia.com/bubbles
// Daily digest: https://quantabundancia.com/today
// Last sync:    2026-05-05
// =====================================================================
//@version=6
indicator("QuantAbundancia · AI Bubble Map", "QA Bubbles", overlay=true,
          max_labels_count=10, max_lines_count=10)

// ─── INPUTS ──────────────────────────────────────────────────────────
// Only two toggles exposed (kept short to avoid legend bloat). Position
// + color are hardcoded for brand consistency.
show_table = input.bool(true, "Show info table",   group="Display")
show_fib   = input.bool(true, "Show Fib key level", group="Display")

fib_color = color.new(#fbbf24, 0)  // QA gold

// ─── BUBBLE TAXONOMY ─────────────────────────────────────────────────
// 12 bubbles, residualized correlation, verdict.
// Updated weekly from /bubbles API. Verdict legend:
//   strongest / tightest / validated → real bloc, idiosyncratic flow
//   validating / moderate / speculative → emerging, monitor
//   FAILED → market beta in costume, NOT a real bloc
var compute_t       = array.from("NVDA","AMD","AVGO","TSM","INTC","MRVL","ARM","SMCI","SOXX","SMH","TXN","QCOM","ON","ADI","SWKS","QRVO","NXPI")
var memory_t        = array.from("MU","WDC","SNDK","MRAM")
var semi_eq_t       = array.from("ASML","AMAT","LRCX","KLAC","AEHR","ACLS","ICHR")
var quantum_t       = array.from("QBTS","RGTI","IONQ","ARQQ","QUBT","QTUM","HON")
var networking_t    = array.from("ANET","COHR","CIEN","LITE","AAOI","CRDO","ALAB")
var space_t         = array.from("RKLB","ASTS","LUNR","PL","BKSY","SPIR","IRDM","KTOS")
var dc_power_t      = array.from("VST","CEG","NRG","GEV","ETR","AEP","NEE","TLN","BE","NVTS")
var nuclear_t       = array.from("OKLO","NNE","SMR","NPWR","LEU","CCJ","BWXT","UUUU","UEC","UAMY")
var cooling_t       = array.from("VRT","JCI","TRN","EMR","GNRC","TT")
var ai_software_t   = array.from("PLTR","SNOW","DDOG","MDB","NET","CRM","CRWD","FSLY","DOCN","PATH","ZETA","NOW","TEAM")
var hyperscalers_t  = array.from("MSFT","GOOGL","GOOG","AMZN","META","ORCL","IBM","SAP")
var robotics_t      = array.from("TSLA","ABBN","FANUY","SYM","NDSN","ISRG")

ticker = syminfo.ticker

bubble  = ""
slug    = ""
corr    = 0.0
verdict = ""

if array.includes(quantum_t, ticker)
    bubble  := "Quantum"
    slug    := "quantum"
    corr    := 0.76
    verdict := "strongest"
else if array.includes(semi_eq_t, ticker)
    bubble  := "Semi Equipment"
    slug    := "semi-equipment"
    corr    := 0.82
    verdict := "tightest"
else if array.includes(memory_t, ticker)
    bubble  := "Memory / HBM"
    slug    := "memory"
    corr    := 0.71
    verdict := "validated"
else if array.includes(cooling_t, ticker)
    bubble  := "Cooling / DC Infra"
    slug    := "cooling-dc-infra"
    corr    := 0.70
    verdict := "validated"
else if array.includes(compute_t, ticker)
    bubble  := "Compute / GPUs"
    slug    := "compute"
    corr    := 0.65
    verdict := "moderate"
else if array.includes(networking_t, ticker)
    bubble  := "Networking / Optical"
    slug    := "networking-optical"
    corr    := 0.60
    verdict := "validating"
else if array.includes(space_t, ticker)
    bubble  := "Space / Sat Comms"
    slug    := "space"
    corr    := 0.60
    verdict := "validating"
else if array.includes(dc_power_t, ticker)
    bubble  := "Datacenter Power"
    slug    := "datacenter-power"
    corr    := 0.55
    verdict := "validating"
else if array.includes(nuclear_t, ticker)
    bubble  := "Nuclear / SMR"
    slug    := "nuclear-smr"
    corr    := 0.70
    verdict := "speculative"
else if array.includes(ai_software_t, ticker)
    bubble  := "AI Software"
    slug    := "ai-software"
    corr    := 0.10
    verdict := "FAILED"
else if array.includes(hyperscalers_t, ticker)
    bubble  := "Hyperscalers"
    slug    := "hyperscalers"
    corr    := 0.05
    verdict := "FAILED"
else if array.includes(robotics_t, ticker)
    bubble  := "Robotics"
    slug    := "robotics"
    corr    := 0.20
    verdict := "FAILED"

// ─── EDITORIAL FIB KEY LEVELS ────────────────────────────────────────
// User-supplied 2026-04-25. Treated as institutional-grade observations,
// not formulaic (computed by hand from longer-dated charts).
fib = switch ticker
    "RKLB"  => 69.0
    "ASTS"  => 63.0
    "PL"    => 27.0
    "BKSY"  => 29.0
    "AAOI"  => 112.0
    "LITE"  => 615.0
    "COHR"  => 249.0
    "AEHR"  => 66.0
    "ONDS"  => 10.0
    "UMAC"  => 12.0
    "AVAV"  => 170.0
    "KTOS"  => 50.0
    "OKLO"  => 69.0
    "UUUU"  => 20.0
    "GEV"   => 867.0
    "LEU"   => 183.0
    "AMD"   => 253.0
    "INTC"  => 60.0
    "ARM"   => 185.0
    "AMKR"  => 55.0
    "IREN"  => 43.0
    "NBIS"  => 113.0
    "CIFR"  => 17.0
    "CRWV"  => 96.0
    "VST"   => 140.0
    "BE"    => 118.0
    "NVTS"  => 257.0
    "VRT"   => 192.0
    "NVDA"  => 71.0
    "TSM"   => 314.0
    "ASML"  => 1205.0
    "MU"    => 341.0
    "PLTR"  => 138.0
    "SNOW"  => 134.0
    "CRWD"  => 433.0
    "ZETA"  => 17.0
    "AVGO"  => 336.0
    "ALAB"  => 186.0
    "CRDO"  => 148.0
    "MRVL"  => 126.0
    "NET"   => 205.0
    "DOCN"  => 71.0
    "FSLY"  => 17.0
    "PATH"  => 10.0
    "TSLA"  => 351.0
    "AMZN"  => 232.0
    "GOOGL" => 272.0
    "ISRG"  => 46.0
    => 0.0

// ─── COLOR HELPERS ───────────────────────────────────────────────────
verdict_color = verdict == "strongest" or verdict == "tightest" or verdict == "validated" ? color.new(#10b981, 0) : verdict == "validating" or verdict == "moderate" or verdict == "speculative" ? color.new(#fbbf24, 0) : verdict == "FAILED" ? color.new(#ef4444, 0) : color.new(color.gray, 50)

// ─── DRAW EDITORIAL FIB LINE + LABEL ─────────────────────────────────
if show_fib and fib > 0 and barstate.islast
    var line  fib_line  = na
    var label fib_label = na
    line.delete(fib_line)
    label.delete(fib_label)
    fib_line  := line.new(bar_index - 200, fib, bar_index + 30, fib, xloc=xloc.bar_index, color=fib_color, width=2, style=line.style_dashed, extend=extend.right)
    fib_label := label.new(bar_index + 30, fib, "QA Fib · $" + str.tostring(fib), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(fib_color, 80), textcolor=color.white, style=label.style_label_left, size=size.small)

// ─── DRAW INFO TABLE ─────────────────────────────────────────────────
var table info = table.new(position.top_right, 2, 5, frame_color=color.new(color.gray, 70), frame_width=1, border_color=color.new(color.gray, 90), border_width=1)

if show_table and barstate.islast
    bg = color.new(color.black, 30)
    label_color = color.new(color.gray, 30)

    if bubble != ""
        table.cell(info, 0, 0, "Bubble",            bgcolor=bg, text_color=label_color, text_size=size.small, text_halign=text.align_left)
        table.cell(info, 1, 0, bubble,              bgcolor=bg, text_color=color.white, text_size=size.small, text_halign=text.align_left)
        table.cell(info, 0, 1, "Bloc residualized", bgcolor=bg, text_color=label_color, text_size=size.small, text_halign=text.align_left)
        table.cell(info, 1, 1, str.tostring(corr, "#.##") + "  " + verdict, bgcolor=bg, text_color=verdict_color, text_size=size.small, text_halign=text.align_left)

        if fib > 0
            table.cell(info, 0, 2, "Editorial Fib",     bgcolor=bg, text_color=label_color, text_size=size.small, text_halign=text.align_left)
            table.cell(info, 1, 2, "$" + str.tostring(fib, "#.##"), bgcolor=bg, text_color=fib_color, text_size=size.small, text_halign=text.align_left)
        else
            table.cell(info, 0, 2, "", bgcolor=bg)
            table.cell(info, 1, 2, "", bgcolor=bg)

        table.cell(info, 0, 3, "Bubble page", bgcolor=bg, text_color=label_color, text_size=size.tiny, text_halign=text.align_left)
        table.cell(info, 1, 3, "/bubbles/" + slug,  bgcolor=bg, text_color=color.new(color.aqua, 0), text_size=size.tiny, text_halign=text.align_left)
        table.cell(info, 0, 4, "QuantAbundancia",   bgcolor=bg, text_color=color.new(#fbbf24, 0), text_size=size.tiny, text_halign=text.align_left)
        table.cell(info, 1, 4, "Abundance, Quantified.", bgcolor=bg, text_color=label_color, text_size=size.tiny, text_halign=text.align_left)
    else if fib > 0
        // No bubble match but we have an editorial Fib
        table.cell(info, 0, 0, "Bubble",        bgcolor=bg, text_color=label_color, text_size=size.small, text_halign=text.align_left)
        table.cell(info, 1, 0, "no match",      bgcolor=bg, text_color=color.new(color.gray, 0), text_size=size.small, text_halign=text.align_left)
        table.cell(info, 0, 1, "Editorial Fib", bgcolor=bg, text_color=label_color, text_size=size.small, text_halign=text.align_left)
        table.cell(info, 1, 1, "$" + str.tostring(fib, "#.##"), bgcolor=bg, text_color=fib_color, text_size=size.small, text_halign=text.align_left)
        table.cell(info, 0, 4, "QuantAbundancia",   bgcolor=bg, text_color=color.new(#fbbf24, 0), text_size=size.tiny, text_halign=text.align_left)
        table.cell(info, 1, 4, "Abundance, Quantified.", bgcolor=bg, text_color=label_color, text_size=size.tiny, text_halign=text.align_left)
    else
        table.cell(info, 0, 0, "QuantAbundancia", bgcolor=bg, text_color=color.new(#fbbf24, 0), text_size=size.tiny, text_halign=text.align_left)
        table.cell(info, 1, 0, "no bubble match", bgcolor=bg, text_color=color.new(color.gray, 0), text_size=size.tiny, text_halign=text.align_left)
````
