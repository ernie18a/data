# Lucky Risk Calculator

- url: https://www.tradingview.com/script/a4W5SyRl-Lucky-Risk-Calculator/
- type: indicator
- pine_id: PUB;4eb30f3a97df4d22aeefd56dc9e01eff
- version: 1.0

## Description

[b]Lucky Risk Calculator[/b]

Know your risk before you pull the trigger — every single time.

Lucky Risk Calculator is a clean, no-nonsense risk management tool built for futures traders. Whether you're trading MNQ, NQ, MES, ES, or any other futures contract, it automatically detects the point value of your instrument and gives you instant dollar risk and profit targets right on your chart — no spreadsheets, no mental math mid-trade.

---

[b]What It Does[/b]

Enter your stop distance and number of contracts, and the table instantly shows you:

- **Dollar risk** per contract and for your full position
- **Profit target distance** based on your R:R ratio
- **Dollar profit** at target per contract and full position
- **Auto point value detection** — works on any futures symbol without manual setup

---

[b]How To Use[/b]

1. Set your **Stop Distance** (in points) based on where your stop loss is placed
2. Set your **Contracts** — risk and profit scale automatically
3. Set your **R:R Target** — the calculator shows exactly what hitting that target is worth in dollars
4. Move the table to wherever it fits best on your chart

---

[b]Works With[/b]

MNQ · NQ · MES · ES · MYM · YM · M2K · RTY — and any other futures contract on TradingView. Point values are pulled automatically from the symbol, so you never have to touch a setting when switching instruments.

---

[b]Why I Built This[/b]

As a futures scalper, I needed to know my exact dollar risk the moment I defined my stop — not after the trade. This tool keeps risk front and center so you trade with discipline, not guesses.

*Trade smart. Manage risk. Stay lucky.*

— LuckyJo

## Source Code

````pine
//@version=6
indicator("Lucky Risk Calculator", overlay=true)

// ══════════════════════════════════════════════════════════════════════════════
//  INPUTS
// ══════════════════════════════════════════════════════════════════════════════
i_pts       = input.float(10.0, "Stop Distance (points)", minval=0.25, step=0.25,
              group="1  ·  Trade",
              tooltip="How many points between your entry and stop. Update this each trade.")
i_contracts = input.int(1, "Contracts", minval=1, maxval=50,
              group="1  ·  Trade",
              tooltip="Number of contracts. Risk and profit scale with this number.")
i_rr        = input.float(2.0, "R:R Target", minval=0.25, step=0.25,
              group="1  ·  Trade",
              tooltip="Your planned risk-to-reward ratio. Used to calculate profit target distance and dollar profit.")
i_tpos      = input.string("Top Right", "Table Position",
              options=["Top Right","Top Left","Bottom Right","Bottom Left"],
              group="2  ·  Display")


// ══════════════════════════════════════════════════════════════════════════════
//  CALCULATIONS  — auto point value from current symbol
//  MES = $5/pt  ·  MNQ = $2/pt  ·  ES = $50/pt  ·  NQ = $20/pt  · etc.
// ══════════════════════════════════════════════════════════════════════════════
pt_val     = syminfo.pointvalue

risk_1c    = i_pts * pt_val
risk_Nc    = risk_1c * i_contracts

tgt_pts    = i_pts * i_rr
profit_1c  = tgt_pts * pt_val
profit_Nc  = profit_1c * i_contracts


// ══════════════════════════════════════════════════════════════════════════════
//  TABLE
// ══════════════════════════════════════════════════════════════════════════════
if barstate.islast
    tbl_pos = switch i_tpos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        =>               position.bottom_left

    C_GOLD  = color.new(#D4AF37, 0)
    C_GREEN = color.new(#00C853, 0)
    C_RED   = color.new(#FF4545, 0)
    C_WARN  = color.new(#FFB300, 0)
    C_WHITE = color.white
    C_HEAD  = color.new(#0F0F0F, 0)
    C_CELL  = color.new(#14141E, 0)

    rr_col  = i_rr >= 2.5 ? C_GREEN : i_rr >= 1.5 ? C_WARN : C_RED

    cx      = str.tostring(i_contracts) + "x"
    sym_txt = syminfo.ticker + "   $" + str.tostring(pt_val, "#.##") + " / pt"

    tbl = table.new(tbl_pos, 2, 10, bgcolor=color.new(#0A0A12, 8), frame_color=color.new(#D4AF37, 40), frame_width=2, border_color=color.new(#1E1E2E, 0), border_width=1)

    // Row 0 — title
    table.cell(tbl, 0, 0, "LUCKY RISK CALCULATOR",
               bgcolor=C_HEAD, text_color=C_GOLD,
               text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(tbl, 0, 0, 1, 0)

    // Row 1 — symbol
    table.cell(tbl, 0, 1, "SYMBOL", bgcolor=C_HEAD, text_color=C_WHITE, text_size=size.small)
    table.cell(tbl, 1, 1, sym_txt,  bgcolor=C_CELL, text_color=C_WHITE, text_size=size.small)

    // Row 2 — stop distance
    table.cell(tbl, 0, 2, "STOP",
               bgcolor=C_HEAD, text_color=C_WHITE, text_size=size.small)
    table.cell(tbl, 1, 2, str.tostring(i_pts, "#.##") + " pts",
               bgcolor=C_CELL, text_color=C_RED, text_size=size.small)

    // Row 3 — divider risk
    table.cell(tbl, 0, 3, "── RISK ──",
               bgcolor=C_HEAD, text_color=color.new(#FF4545, 40),
               text_size=size.tiny, text_halign=text.align_center)
    table.merge_cells(tbl, 0, 3, 1, 3)

    // Row 4 — risk 1 contract
    table.cell(tbl, 0, 4, "RISK  1x",
               bgcolor=C_HEAD, text_color=C_WHITE, text_size=size.small)
    table.cell(tbl, 1, 4, "$" + str.tostring(risk_1c, "#.00"),
               bgcolor=C_CELL, text_color=C_RED, text_size=size.small)

    // Row 5 — risk N contracts
    table.cell(tbl, 0, 5, "RISK  " + cx,
               bgcolor=C_HEAD, text_color=C_WHITE, text_size=size.small)
    table.cell(tbl, 1, 5, "$" + str.tostring(risk_Nc, "#.00"),
               bgcolor=C_CELL, text_color=C_RED, text_size=size.normal)

    // Row 6 — divider profit
    table.cell(tbl, 0, 6, "── PROFIT  (" + str.tostring(i_rr, "#.#") + "R) ──",
               bgcolor=C_HEAD, text_color=color.new(#00C853, 40),
               text_size=size.tiny, text_halign=text.align_center)
    table.merge_cells(tbl, 0, 6, 1, 6)

    // Row 7 — target distance
    table.cell(tbl, 0, 7, "TARGET",
               bgcolor=C_HEAD, text_color=C_WHITE, text_size=size.small)
    table.cell(tbl, 1, 7, str.tostring(tgt_pts, "#.##") + " pts",
               bgcolor=C_CELL, text_color=C_GREEN, text_size=size.small)

    // Row 8 — profit 1 contract
    table.cell(tbl, 0, 8, "PROFIT  1x",
               bgcolor=C_HEAD, text_color=C_WHITE, text_size=size.small)
    table.cell(tbl, 1, 8, "$" + str.tostring(profit_1c, "#.00"),
               bgcolor=C_CELL, text_color=C_GREEN, text_size=size.small)

    // Row 9 — profit N contracts
    table.cell(tbl, 0, 9, "PROFIT  " + cx,
               bgcolor=C_HEAD, text_color=C_WHITE, text_size=size.small)
    table.cell(tbl, 1, 9, "$" + str.tostring(profit_Nc, "#.00"),
               bgcolor=C_CELL, text_color=C_GREEN, text_size=size.normal)
````
