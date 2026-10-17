# Trade Grader [Time & Price ICT)

- url: https://www.tradingview.com/script/2T3dsMTc-Trade-Grader-Time-Price-ICT/
- type: indicator
- pine_id: PUB;8c03dfe27dbd4960a4bc81bf10f18289
- version: 1.0

## Description

Trade Grader [Frank369]
A Protocol-Based Trade Scoring System for Disciplined ICT Traders

What Is This Indicator?
Trade Grader is a real-time trade scoring and checklist system built specifically for traders following the ICT methodology, as taught by Frank369 (The Matrix Unlocked). It sits directly on your TradingView chart and grades every potential trade setup from D (worst) to A++ (perfect) — so you never have to second-guess whether a trade is worth taking.
The indicator is divided into two sections that must be completed in order:
	•	📊 High Timeframe (HTF) Checklist — 1H: Confirms the big picture is aligned before you even think about entering.
	•	📈 Low Timeframe (LTF) Checklist — 5m/1m: Confirms precise entry conditions once the HTF is fully validated.

How It Works
Step 1 — Complete the HTF Checklist First
The LTF checklist is locked until all 3 HTF conditions are met:
	1.	✅ Orderflow Identified (1H) — Is the 1H trend clearly bullish or bearish?
	2.	✅ POI / POIs Identified (1H / 15m) — Have you marked your Points of Interest?
	3.	✅ DOL Identified — Do you know your Draw on Liquidity?
If any HTF item is missing → automatic Grade D → NO TRADE. No exceptions.
Step 2 — Complete the LTF Checklist
Once the HTF is 100% confirmed, the LTF section unlocks:
	1.	✅ Price now at POI — Is price actually at your identified level?
	2.	✅ SMT Identified (min. 10m SMT) — Is there Smart Money Tool divergence present?
	3.	✅ CISD on NQ & ES — Change In State of Delivery confirmed on both instruments?
	4.	✅ CISD on NQ, ES & YM (OVERRIDE) — All 3 instruments confirmed? This overrides item 3 and upgrades your grade.
Step 3 — Read Your Grade
The indicator scores your setup and displays the result instantly:

Why This Indicator Will Change How You Trade
🛡️ It Protects You From Yourself
The number one reason traders lose money is not a lack of knowledge — it’s a lack of discipline. You know the rules. But in the heat of the moment, emotions take over. Fear of missing out, impatience, boredom — these push you into trades that don’t meet your criteria. Trade Grader acts as your personal rule enforcer, right on your chart. If the grade isn’t A, A+, or A++, the indicator tells you loudly and clearly: NO TRADE.
🎯 It Eliminates Overtrading
Overtrading is one of the most common ways retail traders blow accounts. Every time you take a low-quality trade, you’re not just risking your capital — you’re risking your confidence and your consistency. Trade Grader forces you to slow down and only act when your full protocol is confirmed. No more “close enough” setups. No more “I think this might work.” Only structured, graded, high-probability setups.
📋 It Builds Trading Discipline Like a Checklist Pilot
Commercial pilots don’t take off without completing their pre-flight checklist — no matter how experienced they are. Trade Grader brings that same level of procedural discipline to your trading. Every item must be checked. Every box must be ticked. Only then does the system give you the green light to trade.
🧠 It Removes Emotional Decision-Making
When you’re staring at a chart and price is moving fast, your brain wants to act. Trade Grader slows you down and forces you to think systematically instead of emotionally. By the time you’ve gone through the checklist, you either have a valid setup — or you don’t. There’s no grey area.
📈 It Trains You to See Only High-Quality Setups
Over time, using this checklist consistently will rewire how you see the market. You’ll naturally start pre-screening setups in your head before even opening the indicator. Your eye for confluences, timing, and structure will sharpen — because you’ve been forced to look for them on every single trade.
Key Features
	•	🔒 HTF Lock System — LTF checklist is greyed out and locked until all HTF items are confirmed
	•	🎓 Live Grade Display — Updates in real time as you toggle items on/off in settings
	•	🟢 TRADE! / 🔴 NO TRADE — Clear, bold verdict so there’s no confusion
	•	🩶 Clean Silver/Grey Design — Minimal and professional, won’t distract from your chart
	•	📍 Repositionable — Place the table in any corner of your chart
	•	👁️ Toggle Checklist Visibility — Show or hide the full checklist, keeping only the grade and verdict if preferred
Who Is This For?
This indicator is built for traders who:
	•	Follow the ICT / Zeussy / Frank369 methodology
	•	Trade NQ, ES, YM (Nasdaq, S&P 500, Dow Jones futures)
	•	Struggle with overtrading or taking setups that don’t fully meet their criteria
	•	Want a systematic, rule-based approach to trade execution
	•	Are committed to improving their trading psychology and discipline

Final Note
Knowing when NOT to trade is just as important as knowing when to trade.
Most traders focus all their energy on finding entries. But the best traders know that patience and selectivity are what separate consistent profitability from blown accounts. Trade Grader is your accountability partner — sitting on your chart every session, reminding you of your rules, and making sure you only pull the trigger when everything lines up.
Grade A and above only. Everything else is noise.

## Source Code

````pine
//@version=6
indicator("Trade Grader [Zeussy/Frank369]", shorttitle="TrdGrader", overlay=true)

// ============================================================
// HTF CHECKLIST (1H)
// ============================================================
htf_group = "HTF Checklist (1H) ‚Äî Must Complete ALL"
htf1 = input.bool(false, "Orderflow Identified (1H)",         group=htf_group)
htf2 = input.bool(false, "POI / POIs Identified (1H / 15m)",  group=htf_group)
htf3 = input.bool(false, "DOL Identified",                     group=htf_group)

// ============================================================
// LTF CHECKLIST (5m / 1m)
// ============================================================
ltf_group = "LTF Checklist (5m / 1m) ‚Äî Unlocks after HTF"
ltf1 = input.bool(false, "Price now at POI",                   group=ltf_group)
ltf2 = input.bool(false, "SMT Identified (min. 10m SMT)",      group=ltf_group)
ltf3 = input.bool(false, "CISD on NQ and ES",                  group=ltf_group)
ltf4 = input.bool(false, "CISD on NQ, ES and YM (OVERRIDE)",  group=ltf_group)

// ============================================================
// DISPLAY SETTINGS
// ============================================================
disp_group = "Display Settings"
table_pos  = input.string("Top Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=disp_group)
show_items = input.bool(true, "Show Checklist Items on Chart", group=disp_group)

// ============================================================
// GRADING LOGIC
// ============================================================
htf_complete = htf1 and htf2 and htf3
htf_count    = (htf1 ? 1 : 0) + (htf2 ? 1 : 0) + (htf3 ? 1 : 0)
ltf3_eff     = ltf3 or ltf4
ltf_count    = (ltf1 ? 1 : 0) + (ltf2 ? 1 : 0) + (ltf3_eff ? 1 : 0) + (ltf4 ? 1 : 0)

var string grade   = "D"
var string verdict = "NO TRADE"

if not htf_complete
    grade   := "D"
    verdict := "NO TRADE"
else if ltf1 and ltf2 and ltf4 and ltf_count == 4
    grade   := "A++"
    verdict := "TRADE!"
else if ltf1 and ltf2 and ltf4
    grade   := "A+"
    verdict := "TRADE!"
else if ltf1 and ltf2 and ltf3_eff
    grade   := "A"
    verdict := "TRADE!"
else if ltf_count == 2
    grade   := "B"
    verdict := "NO TRADE"
else if ltf_count == 1
    grade   := "C"
    verdict := "NO TRADE"
else
    grade   := "D"
    verdict := "NO TRADE"

// ============================================================
// COLORS ‚Äî Silver/Grey theme
// ============================================================
col_check    = color.new(#1a6e3c, 0)
col_uncheck  = color.new(#cc2222, 0)
col_neutral  = color.new(#444444, 0)
col_bg       = color.new(#C0C0C0, 0)
col_border   = color.new(#999999, 0)
col_htf_bg   = color.new(#B0B8C0, 0)
col_ltf_bg   = color.new(#B8B8B0, 0)
col_header   = color.new(#A8A8A8, 0)
col_grade_bg = color.new(#D0D0D0, 0)

var color col_grade = color.new(#cc2222, 0)
if grade == "A++"
    col_grade := color.new(#006633, 0)
else if grade == "A+"
    col_grade := color.new(#007a3d, 0)
else if grade == "A"
    col_grade := color.new(#008844, 0)
else if grade == "B"
    col_grade := color.new(#cc8800, 0)
else if grade == "C"
    col_grade := color.new(#cc5500, 0)
else
    col_grade := color.new(#cc2222, 0)

var color col_verdict = color.new(#cc2222, 0)
if verdict == "TRADE!"
    col_verdict := color.new(#006633, 0)
else
    col_verdict := color.new(#cc2222, 0)

// ============================================================
// TABLE POSITION
// ============================================================
var string tbl_pos = position.top_right
if table_pos == "Top Right"
    tbl_pos := position.top_right
else if table_pos == "Top Left"
    tbl_pos := position.top_left
else if table_pos == "Bottom Right"
    tbl_pos := position.bottom_right
else
    tbl_pos := position.bottom_left

// ============================================================
// GRADE DESCRIPTION
// ============================================================
var string grade_desc = "Incomplete"
if grade == "A++"
    grade_desc := "Perfect Setup"
else if grade == "A+"
    grade_desc := "Strong Setup"
else if grade == "A"
    grade_desc := "Valid Setup"
else if grade == "B"
    grade_desc := "Weak Setup"
else if grade == "C"
    grade_desc := "Poor Setup"
else
    grade_desc := "Incomplete"

// ============================================================
// BUILD TABLE ‚Äî 2 columns only
// ============================================================
var table tbl = na

if barstate.islast
    int rows = show_items ? 14 : 5
    tbl := table.new(tbl_pos, 2, rows,
                     bgcolor=col_bg,
                     border_color=col_border,
                     border_width=1,
                     frame_color=col_border,
                     frame_width=1)

    int row = 0

    // ---- HEADER ----
    table.cell(tbl, 0, row, "TRADE GRADER",
               text_color=color.new(#111111, 0), text_size=size.normal,
               bgcolor=col_header, text_halign=text.align_center)
    table.cell(tbl, 1, row, "",
               bgcolor=col_header)
    row += 1

    table.cell(tbl, 0, row, "Zeussy / Frank369",
               text_color=col_neutral, text_size=size.tiny,
               bgcolor=col_header, text_halign=text.align_center)
    table.cell(tbl, 1, row, "",
               bgcolor=col_header)
    row += 1

    if show_items
        // ---- HTF HEADER ----
        string htf_status_txt = htf_complete ? "COMPLETE" : str.tostring(htf_count) + "/3"
        color  htf_status_col = htf_complete ? col_check : col_uncheck

        table.cell(tbl, 0, row, "HTF - 1H",
                   text_color=color.new(#003366, 0), text_size=size.small,
                   bgcolor=col_htf_bg, text_halign=text.align_left)
        table.cell(tbl, 1, row, htf_status_txt,
                   text_color=htf_status_col, text_size=size.small,
                   bgcolor=col_htf_bg, text_halign=text.align_right)
        row += 1

        // HTF Item 1
        table.cell(tbl, 0, row, htf1 ? "YES" : "NO",
                   text_color=htf1 ? col_check : col_uncheck,
                   text_size=size.small, bgcolor=col_htf_bg, text_halign=text.align_center)
        table.cell(tbl, 1, row, "Orderflow Identified",
                   text_color=color.new(#111111, 0),
                   text_size=size.small, bgcolor=col_htf_bg, text_halign=text.align_left)
        row += 1

        // HTF Item 2
        table.cell(tbl, 0, row, htf2 ? "YES" : "NO",
                   text_color=htf2 ? col_check : col_uncheck,
                   text_size=size.small, bgcolor=col_htf_bg, text_halign=text.align_center)
        table.cell(tbl, 1, row, "POI / POIs Identified",
                   text_color=color.new(#111111, 0),
                   text_size=size.small, bgcolor=col_htf_bg, text_halign=text.align_left)
        row += 1

        // HTF Item 3
        table.cell(tbl, 0, row, htf3 ? "YES" : "NO",
                   text_color=htf3 ? col_check : col_uncheck,
                   text_size=size.small, bgcolor=col_htf_bg, text_halign=text.align_center)
        table.cell(tbl, 1, row, "DOL Identified",
                   text_color=color.new(#111111, 0),
                   text_size=size.small, bgcolor=col_htf_bg, text_halign=text.align_left)
        row += 1

        // ---- LTF HEADER ----
        bool ltf_locked = not htf_complete
        string ltf_status_txt = ltf_locked ? "LOCKED" : str.tostring(ltf_count) + "/4"
        color  ltf_header_col = ltf_locked ? col_neutral : color.new(#664400, 0)
        color  ltf_status_col = ltf_locked ? col_neutral : (ltf_count == 4 ? col_check : col_neutral)

        table.cell(tbl, 0, row, "LTF - 5m/1m",
                   text_color=ltf_header_col, text_size=size.small,
                   bgcolor=col_ltf_bg, text_halign=text.align_left)
        table.cell(tbl, 1, row, ltf_status_txt,
                   text_color=ltf_status_col, text_size=size.small,
                   bgcolor=col_ltf_bg, text_halign=text.align_right)
        row += 1

        // LTF Item 1
        table.cell(tbl, 0, row, ltf_locked ? "---" : (ltf1 ? "YES" : "NO"),
                   text_color=ltf_locked ? col_neutral : (ltf1 ? col_check : col_uncheck),
                   text_size=size.small, bgcolor=col_ltf_bg, text_halign=text.align_center)
        table.cell(tbl, 1, row, "Price now at POI",
                   text_color=color.new(#111111, 0),
                   text_size=size.small, bgcolor=col_ltf_bg, text_halign=text.align_left)
        row += 1

        // LTF Item 2
        table.cell(tbl, 0, row, ltf_locked ? "---" : (ltf2 ? "YES" : "NO"),
                   text_color=ltf_locked ? col_neutral : (ltf2 ? col_check : col_uncheck),
                   text_size=size.small, bgcolor=col_ltf_bg, text_halign=text.align_center)
        table.cell(tbl, 1, row, "SMT Identified",
                   text_color=color.new(#111111, 0),
                   text_size=size.small, bgcolor=col_ltf_bg, text_halign=text.align_left)
        row += 1

        // LTF Item 3
        table.cell(tbl, 0, row, ltf_locked ? "---" : (ltf3_eff ? "YES" : "NO"),
                   text_color=ltf_locked ? col_neutral : (ltf3_eff ? col_check : col_uncheck),
                   text_size=size.small, bgcolor=col_ltf_bg, text_halign=text.align_center)
        table.cell(tbl, 1, row, "CISD on NQ and ES",
                   text_color=color.new(#111111, 0),
                   text_size=size.small, bgcolor=col_ltf_bg, text_halign=text.align_left)
        row += 1

        // LTF Item 4
        table.cell(tbl, 0, row, ltf_locked ? "---" : (ltf4 ? "YES" : "NO"),
                   text_color=ltf_locked ? col_neutral : (ltf4 ? col_check : col_uncheck),
                   text_size=size.small, bgcolor=col_ltf_bg, text_halign=text.align_center)
        table.cell(tbl, 1, row, "CISD NQ, ES and YM",
                   text_color=color.new(#111111, 0),
                   text_size=size.small, bgcolor=col_ltf_bg, text_halign=text.align_left)
        row += 1

    // ---- GRADE ROW ----
    table.cell(tbl, 0, row, "GRADE  " + grade,
               text_color=col_grade, text_size=size.normal,
               bgcolor=col_grade_bg, text_halign=text.align_center)
    table.cell(tbl, 1, row, grade_desc,
               text_color=col_grade, text_size=size.small,
               bgcolor=col_grade_bg, text_halign=text.align_center)
    row += 1

    // ---- VERDICT ROW ----
    color verdict_bg = verdict == "TRADE!" ? color.new(#cceecc, 0) : color.new(#eecccc, 0)
    table.cell(tbl, 0, row, verdict,
               text_color=col_verdict, text_size=size.large,
               bgcolor=verdict_bg, text_halign=text.align_center)
    table.cell(tbl, 1, row, verdict,
               text_color=col_verdict, text_size=size.large,
               bgcolor=verdict_bg, text_halign=text.align_center)
````
