<!-- tradingview-pine-id: PUB;4c48cec3377a4259a01727ed4286c920 -->
<!-- tradingviewscripts-format: 1 -->
# PropRules [Propfirms.net]

Source: https://www.tradingview.com/script/tzHJaSQl-PropRules-Propfirms-net/

## Description

PropRules [Propfirms.net]

All prop firm rules displayed on your chart for

Lucid
MFFU
Alpha Futures
Tradeify
TopOneFutures
FundedNext
Topstep
Apex

+ MORE

---

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  PROP FIRM RULES TABLE
//  On-chart reference table for futures prop firm rules.
//  Toggle firms on/off, pick plan + account size per firm, switch phase.
//
//  DATA SOURCED 31 JUL 2026 — firms change rules without notice.
//  Fields marked "Verify" were not published clearly in source docs.
//  To edit: find the row in the DATA BLOCK below and change the text.
//  Row format:  FIRM|PLAN|SIZE|PHASE|Target|MaxLoss|DLL|Consistency|Contracts|MinDays|Split|Payout
//  PHASE:  E = Evaluation/Challenge     F = Funded / Sim-Funded
// ═══════════════════════════════════════════════════════════════════════════
indicator("PropRules [Propfirms.net]", overlay = true)

// ─────────────────────────────────────────────────────────────────────────
//  DISPLAY SETTINGS
// ─────────────────────────────────────────────────────────────────────────
gD = "── Display ──"
posIn = input.string("Top Right", "Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = gD)
layoutIn = input.string("Vertical", "Layout", options = ["Vertical", "Horizontal"], group = gD, tooltip = "Vertical = rules down the side, one column per firm (narrow + tall). Horizontal = one row per firm (wide).")
szIn = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal", "Large"], group = gD)
showKey = input.bool(true, "Show plan + size under firm name", group = gD)
rowH = input.float(0, "Row height %", minval = 0, maxval = 15, step = 0.25, group = gD, tooltip = "0 = auto-fit to the text. Raise it to add vertical padding to every header and data row, which makes the table taller without changing the font.")
showFoot = input.bool(true, "Show footer disclaimer", group = gD)

gC = "── Colors ──"
cBg = input.color(#0d0f12, "Body bg", group = gC, inline = "c1")
cBgAlt = input.color(#14181d, "Alt row", group = gC, inline = "c1")
cHd = input.color(#8b1a1a, "Header bg", group = gC, inline = "c2")
cHdT = input.color(#ffffff, "Header txt", group = gC, inline = "c2")
cTx = input.color(#d6dae0, "Body text", group = gC, inline = "c3")
cAcc = input.color(#e0463c, "Firm accent", group = gC, inline = "c3")
cBd = input.color(#2a2f37, "Border", group = gC, inline = "c4")
bdW = input.int(1, "Border w", minval = 0, maxval = 4, group = gC, inline = "c4")

// Wordmark is fixed — not exposed as an input.
const string SITE = "PROPFIRMS.NET"
const string SUB = "PROP RULES"

gB = "── Branding ──"
tagLine = input.string("prop firm rules reference", "Tagline", group = gB)
markStyle = input.string("Candle", "Logo mark", options = ["Candle", "Block", "Bars", "None"], group = gB)
cLogo = input.color(#22b02e, "Candle", group = gB, inline = "b1")
cTtlBg = input.color(#000000, "Title bg", group = gB, inline = "b1")
cTtlTx = input.color(#ffffff, "Wordmark", group = gB, inline = "b2")
cSub = input.color(#22b02e, "Prop Rules", group = gB, inline = "b2")
cTag = input.color(#8a9099, "Tagline", group = gB, inline = "b2")

gK = "── Columns ──"
kTgt = input.bool(true, "Profit target / goal", group = gK)
kML = input.bool(true, "Max loss (drawdown)", group = gK)
kDLL = input.bool(true, "Daily loss limit", group = gK)
kCon = input.bool(true, "Consistency", group = gK)
kCt = input.bool(false, "Max contracts", group = gK)
kMD = input.bool(false, "Min days / payout cadence", group = gK)

// ─────────────────────────────────────────────────────────────────────────
//  FIRM SELECTORS
// ─────────────────────────────────────────────────────────────────────────
g1 = "1 · Alpha Futures"
on1 = input.bool(false, "Show", group = g1, inline = "x")
ph1 = input.string("Evaluation", "Phase", options = ["Evaluation", "Funded"], group = g1, inline = "x")
pl1 = input.string("Standard", "Plan", options = ["Standard", "Advanced", "Zero", "Direct"], group = g1, inline = "y")
sz1 = input.string("50K", "Size", options = ["25K", "50K", "100K", "150K"], group = g1, inline = "y")

g2 = "2 · Topstep"
on2 = input.bool(false, "Show", group = g2, inline = "x")
ph2 = input.string("Evaluation", "Phase", options = ["Evaluation", "Funded"], group = g2, inline = "x")
pl2 = input.string("Combine", "Plan", options = ["Combine", "Express (XFA)", "Live (LFA)"], group = g2, inline = "y")
sz2 = input.string("50K", "Size", options = ["50K", "100K", "150K"], group = g2, inline = "y")

g3 = "3 · Tradeify"
on3 = input.bool(false, "Show", group = g3, inline = "x")
ph3 = input.string("Evaluation", "Phase", options = ["Evaluation", "Funded"], group = g3, inline = "x")
pl3 = input.string("Select", "Plan", options = ["Growth", "Select", "Lightning"], group = g3, inline = "y")
sz3 = input.string("50K", "Size", options = ["25K", "50K", "100K", "150K"], group = g3, inline = "y")

g4 = "4 · Apex Trader Funding"
on4 = input.bool(false, "Show", group = g4, inline = "x")
ph4 = input.string("Evaluation", "Phase", options = ["Evaluation", "Funded"], group = g4, inline = "x")
pl4 = input.string("EOD Trailing", "Plan", options = ["EOD Trailing", "Intraday Trailing"], group = g4, inline = "y")
sz4 = input.string("50K", "Size", options = ["25K", "50K", "100K", "150K"], group = g4, inline = "y")

g5 = "5 · Lucid Trading"
on5 = input.bool(false, "Show", group = g5, inline = "x")
ph5 = input.string("Evaluation", "Phase", options = ["Evaluation", "Funded"], group = g5, inline = "x")
pl5 = input.string("Flex", "Plan", options = ["Flex", "Daily", "Pro", "Direct"], group = g5, inline = "y")
sz5 = input.string("50K", "Size", options = ["25K", "50K", "100K", "150K"], group = g5, inline = "y")

g6 = "6 · MyFundedFutures"
on6 = input.bool(false, "Show", group = g6, inline = "x")
ph6 = input.string("Evaluation", "Phase", options = ["Evaluation", "Funded"], group = g6, inline = "x")
pl6 = input.string("Rapid", "Plan", options = ["Rapid", "Flex", "Builder", "Pro"], group = g6, inline = "y")
sz6 = input.string("50K", "Size", options = ["25K", "50K", "100K", "150K"], group = g6, inline = "y")

g7 = "7 · Take Profit Trader"
on7 = input.bool(false, "Show", group = g7, inline = "x")
ph7 = input.string("Evaluation", "Phase", options = ["Evaluation", "Funded"], group = g7, inline = "x")
pl7 = input.string("PRO Track", "Plan", options = ["PRO Track", "PRO+ (invite)"], group = g7, inline = "y")
sz7 = input.string("50K", "Size", options = ["25K", "50K", "75K", "100K", "150K"], group = g7, inline = "y")

g8 = "8 · FuturesElite"
on8 = input.bool(false, "Show", group = g8, inline = "x")
ph8 = input.string("Evaluation", "Phase", options = ["Evaluation", "Funded"], group = g8, inline = "x")
pl8 = input.string("Elite", "Plan", options = ["Elite", "Prime", "Nitro", "Instant"], group = g8, inline = "y")
sz8 = input.string("50K", "Size", options = ["25K", "50K", "100K", "150K"], group = g8, inline = "y")

g9 = "9 · FundedSeat"
on9 = input.bool(false, "Show", group = g9, inline = "x")
ph9 = input.string("Evaluation", "Phase", options = ["Evaluation", "Funded"], group = g9, inline = "x")
pl9 = input.string("Daily", "Plan", options = ["Daily", "Daily Ultra", "Daily Pro", "Flex", "Sprint", "Direct", "Bolt"], group = g9, inline = "y")
sz9 = input.string("50K", "Size", options = ["25K", "50K", "100K", "150K"], group = g9, inline = "y")

g10 = "10 · FundedNext Futures"
on10 = input.bool(false, "Show", group = g10, inline = "x")
ph10 = input.string("Evaluation", "Phase", options = ["Evaluation", "Funded"], group = g10, inline = "x")
pl10 = input.string("Rapid Pro", "Plan", options = ["Rapid Pro", "Rapid Daily", "Flex", "Legacy"], group = g10, inline = "y")
sz10 = input.string("50K", "Size", options = ["25K", "50K", "100K", "150K"], group = g10, inline = "y")

// ═════════════════════════════════════════════════════════════════════════
//  DATA BLOCK  —  edit rules here
// ═════════════════════════════════════════════════════════════════════════

D_ALPHA = "ALPHA|Standard|50K|E|$3,000|$2,000 EOD|None|50%|5 minis|—|90%|—\n" +
  "ALPHA|Standard|100K|E|$6,000|$3,000 EOD|None|50%|10 minis|—|90%|—\n" +
  "ALPHA|Standard|150K|E|$9,000|$4,500 EOD|None|50%|15 minis|—|90%|—\n" +
  "ALPHA|Standard|50K|F|—|$2,000 EOD|$1,000|40%|5 minis · scaling|5d @ $200+|90%|$500–$3,000 · 50% · 4x/mo\n" +
  "ALPHA|Standard|100K|F|—|$3,000 EOD|$2,000|40%|10 minis · scaling|5d @ $200+|90%|$500–$4,000 · 50% · 4x/mo\n" +
  "ALPHA|Standard|150K|F|—|$4,500 EOD|$3,000|40%|15 minis · scaling|5d @ $200+|90%|$500–$5,000 · 50% · 4x/mo\n" +
  "ALPHA|Advanced|50K|E|$4,000|$1,750 EOD|None|40%|5 minis|—|90%|—\n" +
  "ALPHA|Advanced|100K|E|$8,000|$3,500 EOD|None|40%|10 minis|—|90%|—\n" +
  "ALPHA|Advanced|150K|E|$12,000|$5,250 EOD|None|40%|15 minis|—|90%|—\n" +
  "ALPHA|Advanced|50K|F|—|$1,750 EOD|None|None|5 minis · no scaling|5d @ $200+|90%|$1,000–$15,000 · 50% · 4x/mo\n" +
  "ALPHA|Advanced|100K|F|—|$3,500 EOD|None|None|10 minis · no scaling|5d @ $200+|90%|$1,000–$15,000 · 50% · 4x/mo\n" +
  "ALPHA|Advanced|150K|F|—|$5,250 EOD|None|None|15 minis · no scaling|5d @ $200+|90%|$1,000–$15,000 · 50% · 4x/mo\n" +
  "ALPHA|Zero|25K|E|$1,500|$1,000 EOD|$500|None|1 mini|1 day|90%|—\n" +
  "ALPHA|Zero|50K|E|$3,000|$2,000 EOD|$1,000|None|3 minis|1 day|90%|—\n" +
  "ALPHA|Zero|100K|E|$6,000|$3,000 EOD|$2,000|None|6 minis|1 day|90%|—\n" +
  "ALPHA|Zero|25K|F|—|$1,000 EOD|$500|40%|1 mini|5d @ $200+|90%|$200–$1,000\n" +
  "ALPHA|Zero|50K|F|—|$2,000 EOD|$1,000|40%|3 minis|5d @ $200+|90%|$200–$1,500\n" +
  "ALPHA|Zero|100K|F|—|$3,000 EOD|$2,000|40%|6 minis|5d @ $200+|90%|$200–$2,500\n" +
  "ALPHA|Direct|25K|F|Goal $1,500 → $1,000|$1,000 EOD|$500|20%|2 minis|—|90%|$500–$1,000 · goal resets\n" +
  "ALPHA|Direct|50K|F|Goal $3,000 → $2,000|$2,000 EOD|$1,000|20%|4 minis|—|90%|$500–$2,000 · goal resets\n" +
  "ALPHA|Direct|100K|F|Goal $6,000 → $4,000|$3,000 EOD|$2,000|20%|8 minis|—|90%|$500–$2,500 · goal resets\n" +
  "ALPHA|Direct|150K|F|Goal $9,000 → $6,000|$4,500 EOD|$3,000|20%|10 minis|—|90%|$500–$3,000 · goal resets\n"

D_TOPSTEP = "TOPSTEP|Combine|50K|E|$3,000|$2,000 EOD trail|Optional add-on|Best day < 50% of target|5 minis|2 days|90%|—\n" +
  "TOPSTEP|Combine|100K|E|$6,000|$3,000 EOD trail|Optional add-on|Best day < 50% of target|10 minis|2 days|90%|—\n" +
  "TOPSTEP|Combine|150K|E|$9,000|$4,500 EOD trail|Optional add-on|Best day < 50% of target|15 minis|2 days|90%|—\n" +
  "TOPSTEP|Express (XFA)|50K|F|—|$2,000 · RESETS TO $0 after each payout|Optional add-on|Std none · Cons path 40%|5 minis|Std 5d @ $150+ · Cons 3d|90%|Std $2,000 · Cons $3,000\n" +
  "TOPSTEP|Express (XFA)|100K|F|—|$3,000 · RESETS TO $0 after each payout|Optional add-on|Std none · Cons path 40%|10 minis|Std 5d @ $150+ · Cons 3d|90%|Std $3,000 · Cons $4,000\n" +
  "TOPSTEP|Express (XFA)|150K|F|—|$4,500 · RESETS TO $0 after each payout|Optional add-on|Std none · Cons path 40%|15 minis|Std 5d @ $150+ · Cons 3d|90%|Std $5,000 · Cons $6,000\n" +
  "TOPSTEP|Live (LFA)|50K|F|Reserve unlocks per $3,000|Trailing|$2,000 auto-tightens|None|5 minis|5d @ $150+|90%|50% of balance · NO CAP\n" +
  "TOPSTEP|Live (LFA)|100K|F|Reserve unlocks per $6,000|Trailing|$3,000 auto-tightens|None|10 minis|5d @ $150+|90%|50% of balance · NO CAP\n" +
  "TOPSTEP|Live (LFA)|150K|F|Reserve unlocks per $9,000|Trailing|$4,500 auto-tightens|None|15 minis|5d @ $150+|90%|50% of balance · NO CAP\n"

D_TRADEIFY = "TRADEIFY|Growth|25K|E|$1,500|$1,000 EOD|$600 soft|Disputed — none vs 35%|1 mini|1 day|90%|—\n" +
  "TRADEIFY|Growth|50K|E|$3,000|$2,000 EOD|$1,250 soft|Disputed — none vs 35%|4 minis|1 day|90%|—\n" +
  "TRADEIFY|Growth|100K|E|$6,000|$3,500 EOD|$2,500 soft|Disputed — none vs 35%|8 minis|1 day|90%|—\n" +
  "TRADEIFY|Growth|150K|E|$9,000|$5,000 EOD|$3,750 soft|Disputed — none vs 35%|12 minis|1 day|90%|—\n" +
  "TRADEIFY|Growth|25K|F|—|$1,000 EOD|$600 soft|Fixed policy|1 mini|—|90%|Not published — verify\n" +
  "TRADEIFY|Growth|50K|F|—|$2,000 EOD|$1,250 soft|Fixed policy|4 minis|—|90%|Not published — verify\n" +
  "TRADEIFY|Growth|100K|F|—|$3,500 EOD|$2,500 soft|Fixed policy|8 minis|—|90%|Not published — verify\n" +
  "TRADEIFY|Growth|150K|F|—|$5,000 EOD|$3,750 soft|Fixed policy|12 minis|—|90%|Not published — verify\n" +
  "TRADEIFY|Select|25K|E|$1,500|$1,000 EOD|None|40%|1 mini|3 days|90%|—\n" +
  "TRADEIFY|Select|50K|E|$3,000|$2,000 EOD|None|40%|4 minis|3 days|90%|—\n" +
  "TRADEIFY|Select|100K|E|$6,000|$3,000 EOD|None|40%|8 minis|3 days|90%|—\n" +
  "TRADEIFY|Select|150K|E|$9,000|$4,500 EOD|None|40%|12 minis|3 days|90%|—\n" +
  "TRADEIFY|Select|25K|F|—|$1,000 EOD · LOCKS at start+$100|Flex none · Daily $500|None|1 mini|Flex 5 win days · Daily 0|90%|Flex $1,250 · Daily $600\n" +
  "TRADEIFY|Select|50K|F|—|$2,000 EOD · LOCKS at start+$100|Flex none · Daily $1,000|None|4 minis|Flex 5 win days · Daily 0|90%|Flex $3,000 · Daily $1,000\n" +
  "TRADEIFY|Select|100K|F|—|$3,000 EOD · LOCKS at start+$100|Flex none · Daily $1,250|None|8 minis|Flex 5 win days · Daily 0|90%|Flex $4,000 · Daily $1,500\n" +
  "TRADEIFY|Select|150K|F|—|$4,500 EOD · LOCKS at start+$100|Flex none · Daily $1,750|None|12 minis|Flex 5 win days · Daily 0|90%|Flex $5,000 · Daily $2,500\n" +
  "TRADEIFY|Lightning|25K|F|Goal $1,500 → $1,000|$1,000 EOD|None|20% → 25% → 30%|1 mini|None|90%|$1,000 flat every time\n" +
  "TRADEIFY|Lightning|50K|F|Goal $3,000 → $2,000|$2,000 EOD|$1,250 soft|20% → 25% → 30%|4 minis|None|90%|$2,000 (p1-3) → $2,500 (p4+)\n" +
  "TRADEIFY|Lightning|100K|F|Goal $6,000 → $3,500|$4,000 EOD|$2,500 soft|20% → 25% → 30%|8 minis|None|90%|$2,500 (p1-3) → $3,000 (p4+)\n" +
  "TRADEIFY|Lightning|150K|F|Goal $9,000 → $4,500|$5,250 EOD|$3,000 soft|20% → 25% → 30%|12 minis|None|90%|$3,000 (p1-3) → $3,500 (p4+)\n"

D_APEX = "APEX|EOD Trailing|25K|E|$1,500|$1,000 EOD|$500 pause|None|4|1 day|100%|—\n" +
  "APEX|EOD Trailing|50K|E|$3,000|$2,000 EOD|$1,000 pause|None|6|1 day|100%|—\n" +
  "APEX|EOD Trailing|100K|E|$6,000|$3,000 EOD|$1,500 pause|None|8|1 day|100%|—\n" +
  "APEX|EOD Trailing|150K|E|$9,000|$4,000 EOD|$2,000 pause|None|12|1 day|100%|—\n" +
  "APEX|EOD Trailing|25K|F|—|$1,000 EOD · enforced intraday|Tier-based pause|50%|2|5d @ $100+|100%|$500–$1,000 · 6 PAYOUTS THEN CLOSED\n" +
  "APEX|EOD Trailing|50K|F|—|$2,000 EOD · enforced intraday|Tier-based pause|50%|4|5d @ $250+|100%|$1,500 → $3,000 · 6 PAYOUTS THEN CLOSED\n" +
  "APEX|EOD Trailing|100K|F|—|$3,000 EOD · enforced intraday|Tier-based pause|50%|6|5d @ $300+|100%|$2,000 → $4,000 · 6 PAYOUTS THEN CLOSED\n" +
  "APEX|EOD Trailing|150K|F|—|$4,000 EOD · enforced intraday|Tier-based pause|50%|10|5d @ $350+|100%|$2,500 → $5,000 · 6 PAYOUTS THEN CLOSED\n" +
  "APEX|Intraday Trailing|25K|E|$1,500|$1,000 intraday · incl. unrealised|NONE|None|4|1 day|100%|—\n" +
  "APEX|Intraday Trailing|50K|E|$3,000|$2,000 intraday · incl. unrealised|NONE|None|6|1 day|100%|—\n" +
  "APEX|Intraday Trailing|100K|E|$6,000|$3,000 intraday · incl. unrealised|NONE|None|8|1 day|100%|—\n" +
  "APEX|Intraday Trailing|150K|E|$9,000|$4,000 intraday · incl. unrealised|NONE|None|12|1 day|100%|—\n" +
  "APEX|Intraday Trailing|25K|F|—|$1,000 intraday|NONE|50%|2|5d @ $100+|100%|$500–$1,000 · 6 max · verify\n" +
  "APEX|Intraday Trailing|50K|F|—|$2,000 intraday|NONE|50%|4|5d @ $250+|100%|$1,500 → $3,000 · 6 max · verify\n" +
  "APEX|Intraday Trailing|100K|F|—|$3,000 intraday|NONE|50%|6|5d @ $300+|100%|$2,000 → $4,000 · 6 max · verify\n" +
  "APEX|Intraday Trailing|150K|F|—|$4,000 intraday|NONE|50%|10|5d @ $350+|100%|$2,500 → $5,000 · 6 max · verify\n"

D_LUCID = "LUCID|Flex|25K|E|$1,250|$1,000 EOD|None|50% · cushioned|2 minis|2 days|90%|—\n" +
  "LUCID|Flex|50K|E|$3,000|$2,000 EOD|None|50% · cushioned|4 minis|2 days|90%|—\n" +
  "LUCID|Flex|100K|E|$6,000|$3,000 EOD|None|50% · cushioned|6 minis|2 days|90%|—\n" +
  "LUCID|Flex|150K|E|$9,000|$4,500 EOD|None|50% · cushioned|10 minis|2 days|90%|—\n" +
  "LUCID|Flex|25K|F|—|$1,000 EOD|None|None|2 minis · scaling|5d @ $100+|90%|$1,000 · 5 PAYOUTS THEN LIVE\n" +
  "LUCID|Flex|50K|F|—|$2,000 EOD|None|None|4 minis · scaling|5d @ $150+|90%|$2,000 · 5 PAYOUTS THEN LIVE\n" +
  "LUCID|Flex|100K|F|—|$3,000 EOD|None|None|6 minis · scaling|5d @ $200+|90%|$2,500 · 5 PAYOUTS THEN LIVE\n" +
  "LUCID|Flex|150K|F|—|$4,500 EOD|None|None|10 minis · scaling|5d @ $250+|90%|$3,000 · 5 PAYOUTS THEN LIVE\n" +
  "LUCID|Daily|25K|E|$1,250|$1,000 · EOD or intraday (checkout)|None|50% · cushioned|Verify|2 days|90%|—\n" +
  "LUCID|Daily|50K|E|$3,000|$2,000 · EOD or intraday (checkout)|None|50% · cushioned|Verify|2 days|90%|—\n" +
  "LUCID|Daily|100K|E|$6,000|$3,000 · EOD or intraday (checkout)|None|50% · cushioned|Verify|2 days|90%|—\n" +
  "LUCID|Daily|150K|E|$9,000|$4,500 · EOD or intraday (checkout)|None|50% · cushioned|Verify|2 days|90%|—\n" +
  "LUCID|Daily|25K|F|—|$1,000 INTRADAY|None|None|Verify|Daily|90%|UNCAPPED above $26,100 buffer\n" +
  "LUCID|Daily|50K|F|—|$2,000 INTRADAY|None|None|Verify|Daily|90%|UNCAPPED above $52,100 buffer\n" +
  "LUCID|Daily|100K|F|—|$3,000 INTRADAY|None|None|Verify|Daily|90%|UNCAPPED above $103,100 buffer\n" +
  "LUCID|Daily|150K|F|—|$4,500 INTRADAY|None|None|Verify|Daily|90%|UNCAPPED above $154,600 buffer\n" +
  "LUCID|Pro|25K|E|$1,250|$1,000 EOD|None|None|Verify|1 day|90%|—\n" +
  "LUCID|Pro|50K|E|$3,000|$2,000 EOD|$1,200|None|Verify|1 day|90%|—\n" +
  "LUCID|Pro|100K|E|$6,000|$3,000 EOD|$1,800|None|Verify|1 day|90%|—\n" +
  "LUCID|Pro|150K|E|$9,000|$4,500 EOD|$2,700|None|Verify|1 day|90%|—\n" +
  "LUCID|Pro|25K|F|Goal $250/cycle|$1,000 EOD|None + 60% peak scaling DLL|40%|Full size|—|90%|$1,000 → $1,500 · buffer $26,100\n" +
  "LUCID|Pro|50K|F|Goal $500/cycle|$2,000 EOD|$1,200 + 60% peak scaling DLL|40%|Full size|—|90%|$2,000 → $2,500 · buffer $52,100\n" +
  "LUCID|Pro|100K|F|Goal $750/cycle|$3,000 EOD|$1,800 + 60% peak scaling DLL|40%|Full size|—|90%|$2,500 → $3,000 · buffer $103,100\n" +
  "LUCID|Pro|150K|F|Goal $1,000/cycle|$4,500 EOD|$2,700 + 60% peak scaling DLL|40%|Full size|—|90%|$3,000 → $3,500 · buffer $154,600\n" +
  "LUCID|Direct|25K|F|Goal $1,500 → $1,250|$1,000 EOD|None + 60% peak scaling DLL|20%|Full size|—|90%|$1,000 flat (p1-5)\n" +
  "LUCID|Direct|50K|F|Goal $3,000 → $2,500|$2,000 EOD|$1,200 + 60% peak scaling DLL|20%|Full size|—|90%|$2,000 (p1-3) → $2,500 (p4-5)\n" +
  "LUCID|Direct|100K|F|Goal $6,000 → $3,500|$3,500 EOD|$2,100 + 60% peak scaling DLL|20%|Full size|—|90%|$2,500 (p1-3) → $3,000 (p4-5)\n" +
  "LUCID|Direct|150K|F|Goal $9,000 → $4,500|$5,000 EOD|$3,000 + 60% peak scaling DLL|20%|Full size|—|90%|$3,000 (p1-3) → $3,500 (p4-5)\n"

D_MFFU = "MFFU|Rapid|25K|E|$1,500|$1,000 EOD|None|50%|3 minis|2 days|90%|—\n" +
  "MFFU|Rapid|50K|E|$3,000|$2,000 EOD|None|50%|5 minis|2 days|90%|—\n" +
  "MFFU|Rapid|100K|E|$6,000|$3,000 EOD|None|50%|10 minis|2 days|90%|—\n" +
  "MFFU|Rapid|150K|E|$9,000|$4,500 EOD|None|50%|15 minis|2 days|90%|—\n" +
  "MFFU|Rapid|25K|F|Starts at $0|$1,000 INTRADAY · locks at $100|None|None|3 minis|Daily · 24h after 1st trade|90%|$500 min · buffer $1,100 · no T1 news\n" +
  "MFFU|Rapid|50K|F|Starts at $0|$2,000 INTRADAY · locks at $100|None|None|5 minis|Daily · 24h after 1st trade|90%|$500 min · buffer $2,100 · no T1 news\n" +
  "MFFU|Rapid|100K|F|Starts at $0|$3,000 INTRADAY · locks at $100|None|None|10 minis|Daily · 24h after 1st trade|90%|$500 min · buffer $3,100 · no T1 news\n" +
  "MFFU|Rapid|150K|F|Starts at $0|$4,500 INTRADAY · locks at $100|None|None|15 minis|Daily · 24h after 1st trade|90%|$500 min · buffer $4,600 · no T1 news\n" +
  "MFFU|Flex|25K|E|$1,500|$1,000 EOD|Optional $1,000 soft|50%|2 minis|2 days|80%|—\n" +
  "MFFU|Flex|50K|E|$3,000|$2,000 EOD|Optional $1,000 soft|50%|3 minis|2 days|80%|—\n" +
  "MFFU|Flex|25K|F|Starts at $0|$1,000 EOD · fixes at $100 after payout 1|Optional $1,000|None|1 → 3 minis scaling|5d @ $150+ · $500 net|80%|$2,000 cap · 5 PAYOUTS THEN LIVE\n" +
  "MFFU|Flex|50K|F|Starts at $0|$2,000 EOD · fixes at $100 after payout 1|Optional $1,000|None|1 → 3 minis scaling|5d @ $150+ · $500 net|80%|$2,000 cap · 5 PAYOUTS THEN LIVE\n" +
  "MFFU|Builder|50K|E|$3,000|$2,000 or $1,500 EOD (checkout)|$1,000 soft|None|4 minis|1 day|80%|—\n" +
  "MFFU|Builder|50K|F|Starts at $0|$2,000 or $1,500 EOD · locks start+$100|$1,000 soft|50% per cycle|4 minis|2 days · 48h after 1st trade|80%|$500 min · $2,000 cap · 5 THEN LIVE · no overnight\n" +
  "MFFU|Pro|50K|E|$3,000|$2,000 EOD|None|50%|5 minis|2 days|80%|—\n" +
  "MFFU|Pro|100K|E|$6,000|$3,000 EOD|None|50%|10 minis|2 days|80%|—\n" +
  "MFFU|Pro|150K|E|$9,000|$4,500 EOD|None|50%|15 minis|2 days|80%|—\n" +
  "MFFU|Pro|50K|F|Starts at $0|$2,000 EOD · static at start+$100 after payout 1|None|None|5 minis|14 CALENDAR DAYS|80%|$1,000 min · buffer $2,100 · $100k lifetime cap\n" +
  "MFFU|Pro|100K|F|Starts at $0|$3,000 EOD · static at start+$100 after payout 1|None|None|10 minis|14 CALENDAR DAYS|80%|$1,000 min · buffer $3,100 · $100k lifetime cap\n" +
  "MFFU|Pro|150K|F|Starts at $0|$4,500 EOD · static at start+$100 after payout 1|None|None|15 minis|14 CALENDAR DAYS|80%|$1,000 min · buffer $4,600 · $100k lifetime cap\n"

D_TPT = "TPT|PRO Track|25K|E|$1,500|$1,500 EOD trail|None|50% · auto-adjusts target|3 minis|5 days|80%|—\n" +
  "TPT|PRO Track|50K|E|$3,000|$2,000 EOD trail|None|50% · auto-adjusts target|6 minis|5 days|80%|—\n" +
  "TPT|PRO Track|75K|E|$4,500|$2,500 EOD trail|None|50% · auto-adjusts target|9 minis|5 days|80%|—\n" +
  "TPT|PRO Track|100K|E|$6,000|$3,000 EOD trail|None|50% · auto-adjusts target|12 minis|5 days|80%|—\n" +
  "TPT|PRO Track|150K|E|$9,000|$4,500 EOD trail|None|50% · auto-adjusts target|15 minis|5 days|80%|—\n" +
  "TPT|PRO Track|25K|F|—|$1,500 INTRADAY · incl. unrealised|None|None|3 minis|1 traded day/week|80%|Above $26,500 buffer only · no bots\n" +
  "TPT|PRO Track|50K|F|—|$2,000 INTRADAY · incl. unrealised|None|None|6 minis|1 traded day/week|80%|Above $52,000 buffer only · no bots\n" +
  "TPT|PRO Track|75K|F|—|$2,500 INTRADAY · incl. unrealised|None|None|9 minis|1 traded day/week|80%|Above $77,500 buffer only · no bots\n" +
  "TPT|PRO Track|100K|F|—|$3,000 INTRADAY · incl. unrealised|None|None|12 minis|1 traded day/week|80%|Above $103,000 buffer only · no bots\n" +
  "TPT|PRO Track|150K|F|—|$4,500 INTRADAY · incl. unrealised|None|None|15 minis|1 traded day/week|80%|Above $154,500 buffer only · no bots\n" +
  "TPT|PRO+ (invite)|25K|F|—|$1,500 EOD|None|None|3 minis|1 traded day/week|90%|NO BUFFER · withdraw day one\n" +
  "TPT|PRO+ (invite)|50K|F|—|$2,000 EOD|None|None|6 minis|1 traded day/week|90%|NO BUFFER · withdraw day one\n" +
  "TPT|PRO+ (invite)|75K|F|—|$2,500 EOD|None|None|9 minis|1 traded day/week|90%|NO BUFFER · withdraw day one\n" +
  "TPT|PRO+ (invite)|100K|F|—|$3,000 EOD|None|None|12 minis|1 traded day/week|90%|NO BUFFER · withdraw day one\n" +
  "TPT|PRO+ (invite)|150K|F|—|$4,500 EOD|None|None|15 minis|1 traded day/week|90%|NO BUFFER · withdraw day one\n"

D_FELITE = "FELITE|Elite|50K|E|$3,000|$2,000 EOD|None|50%|4 minis|2 days|90%|—\n" +
  "FELITE|Elite|100K|E|$6,000|$3,000 EOD|None|50%|8 minis|2 days|90%|—\n" +
  "FELITE|Elite|150K|E|$9,000|$4,500 EOD|None|50%|12 minis|2 days|90%|—\n" +
  "FELITE|Elite|50K|F|No goal|$2,000 EOD|None|None|4 minis · scaling|5d @ $150+|90%|$500–$2,000 every payout\n" +
  "FELITE|Elite|100K|F|No goal|$3,000 EOD|None|None|8 minis · scaling|5d @ $250+|90%|$500–$2,500 every payout\n" +
  "FELITE|Elite|150K|F|No goal|$4,500 EOD|None|None|12 minis · scaling|5d @ $350+|90%|$500–$3,000 every payout\n" +
  "FELITE|Prime|50K|E|Verify|$2,000 EOD|$1,200|None|4 minis|1 day|Verify|—\n" +
  "FELITE|Prime|100K|E|Verify|$3,000 EOD|$1,800|None|6 minis|1 day|Verify|—\n" +
  "FELITE|Prime|150K|E|Verify|$4,500 EOD|$2,700|None|10 minis|1 day|Verify|—\n" +
  "FELITE|Prime|50K|F|—|$2,000 EOD|$1,200|40%|4 minis|None|Verify|$500 min · $2,000 → $2,800 · buffer $52,100\n" +
  "FELITE|Prime|100K|F|—|$3,000 EOD|$1,800|40%|6 minis|None|Verify|$900 min · $2,500 → $3,500 · buffer $103,100\n" +
  "FELITE|Prime|150K|F|—|$4,500 EOD|$2,700|40%|10 minis|None|Verify|$1,100 min · $3,000 → $3,800 · buffer $154,600\n" +
  "FELITE|Nitro|50K|E|Verify|EOD — verify|Verify|Verify|Verify|Verify|90%|—\n" +
  "FELITE|Nitro|100K|E|Verify|EOD — verify|Verify|Verify|Verify|Verify|90%|—\n" +
  "FELITE|Nitro|150K|E|Verify|EOD — verify|Verify|Verify|Verify|Verify|90%|—\n" +
  "FELITE|Nitro|50K|F|—|INTRADAY · locks at $50,100|Verify|None|Verify|Every 24h|90%|$500 min · buffer $2,100 · AUTO-LIVE at $6,000/day\n" +
  "FELITE|Nitro|100K|F|—|INTRADAY · locks at $100,100|Verify|None|Verify|Every 24h|90%|$500 min · buffer $3,100 · AUTO-LIVE at $8,000/day\n" +
  "FELITE|Nitro|150K|F|—|INTRADAY · locks at $150,100|Verify|None|Verify|Every 24h|90%|$500 min · buffer $4,600 · AUTO-LIVE at $10,000/day\n" +
  "FELITE|Instant|25K|F|Goal $2,000 → $1,500|Max DD only — verify|None|20% fixed|2 minis|10 trading days|Verify|$800 flat · scalp profit excluded\n" +
  "FELITE|Instant|50K|F|Goal $3,500 → $2,000|Max DD only — verify|None|20% → 25% → 30%|4 minis|10 trading days|Verify|$1,500 → $2,500 → $3,000 · scalp excluded\n" +
  "FELITE|Instant|100K|F|Goal $7,000 → $3,000|Max DD only — verify|None|20% → 25% → 30%|8 minis|10 trading days|Verify|$2,500 → $4,000 → $4,500 · scalp excluded\n" +
  "FELITE|Instant|150K|F|Goal $10,000 → $4,000|Max DD only — verify|None|20% → 25% → 30%|12 minis|10 trading days|Verify|$3,500 → $4,600 → $5,000 · scalp excluded\n"

D_FSEAT = "FSEAT|Daily|25K|E|$1,500 (6%)|$1,000 EOD|None|50% or 35% (checkout)|2 minis|2 days|90%|—\n" +
  "FSEAT|Daily|50K|E|$3,000 (6%)|$2,000 EOD|None|50% or 35% (checkout)|4 minis|2 days|90%|—\n" +
  "FSEAT|Daily|100K|E|$6,000 (6%)|$3,000 EOD|None|50% or 35% (checkout)|8 minis|2 days|90%|—\n" +
  "FSEAT|Daily|150K|E|$9,000 (6%)|$4,500 EOD|None|50% or 35% (checkout)|12 minis|2 days|90%|—\n" +
  "FSEAT|Daily|25K|F|—|$1,000 EOD · locks start+$100|$750 soft|None|1+ minis scaling|Daily from day one|90%|$250–$500 · buffer $1,100 · no swing\n" +
  "FSEAT|Daily|50K|F|—|$2,000 EOD · locks start+$100|$1,000 soft|None|2+ minis scaling|Daily from day one|90%|$500–$1,000 · buffer $2,100 · no swing\n" +
  "FSEAT|Daily|100K|F|—|$3,000 EOD · locks start+$100|$1,500 soft|None|3+ minis scaling|Daily from day one|90%|$1,000–$1,500 · buffer $3,100 · no swing\n" +
  "FSEAT|Daily|150K|F|—|$4,000 EOD · locks start+$100|$2,000 soft|None|4+ minis scaling|Daily from day one|90%|$1,500–$2,500 · buffer $4,100 · no swing\n" +
  "FSEAT|Daily Ultra|25K|E|$1,500 (6%)|$750 or $1,000 (checkout)|None|26% or 35% (checkout)|Verify|3–4 days|80%|—\n" +
  "FSEAT|Daily Ultra|50K|E|$3,000 (6%)|$1,500 or $2,000 (checkout)|None|26% or 35% (checkout)|Verify|3–4 days|80%|—\n" +
  "FSEAT|Daily Ultra|100K|E|$6,000 (6%)|$2,250 or $3,000 (checkout)|None|26% or 35% (checkout)|Verify|3–4 days|80%|—\n" +
  "FSEAT|Daily Ultra|25K|F|—|Chosen amt · locks after payout 1|None|None|Verify|Unlimited daily|80%|UNCAPPED · $250 min · MUST request before threshold\n" +
  "FSEAT|Daily Ultra|50K|F|—|Chosen amt · locks after payout 1|None|None|Verify|Unlimited daily|80%|UNCAPPED · $250 min · MUST request before $53,100\n" +
  "FSEAT|Daily Ultra|100K|F|—|Chosen amt · locks after payout 1|None|None|Verify|Unlimited daily|80%|UNCAPPED · $250 min · MUST request before threshold\n" +
  "FSEAT|Daily Pro|25K|E|$1,500 (6%)|$750 EOD|None|40%|Verify|Verify|90%|—\n" +
  "FSEAT|Daily Pro|50K|E|$3,000 (6%)|$1,500 EOD|None|40%|Verify|Verify|90%|—\n" +
  "FSEAT|Daily Pro|100K|E|$6,000 (6%)|$2,500 EOD|None|40%|Verify|Verify|90%|—\n" +
  "FSEAT|Daily Pro|25K|F|—|$750 EOD|Verify|None|Verify|Daily from day one|90%|$250–$500 · buffer $1,000\n" +
  "FSEAT|Daily Pro|50K|F|—|$1,500 EOD|Verify|None|Verify|Daily from day one|90%|$500–$1,000 · buffer $2,000\n" +
  "FSEAT|Daily Pro|100K|F|—|$2,500 EOD|Verify|None|Verify|Daily from day one|90%|$1,000–$1,500 · buffer $3,000\n" +
  "FSEAT|Flex|25K|E|$1,500 (6%)|$1,000 EOD|None|50% or 40% (checkout)|2 minis|2 days|90%|—\n" +
  "FSEAT|Flex|50K|E|$3,000 (6%)|$2,000 EOD|None|50% or 40% (checkout)|4 minis|2 days|90%|—\n" +
  "FSEAT|Flex|100K|E|$6,000 (6%)|$3,000 EOD|None|50% or 40% (checkout)|6 minis|2 days|90%|—\n" +
  "FSEAT|Flex|150K|E|$9,000 (6%)|$4,500 EOD|None|50% or 40% (checkout)|10 minis|2 days|90%|—\n" +
  "FSEAT|Flex|25K|F|Net $250/cycle|$1,000 EOD · locks after payout 1|None|None|2 minis|4d @ $125+|90%|50% of profit · $750 cap · $500 min\n" +
  "FSEAT|Flex|50K|F|Net $500/cycle|$2,000 EOD · locks after payout 1|None|None|4 minis|4d @ $250+|90%|50% of profit · $1,500 cap · $500 min\n" +
  "FSEAT|Flex|100K|F|Net $750/cycle|$3,000 EOD · locks after payout 1|None|None|6 minis|4d @ $300+|90%|50% of profit · $2,000 cap · $500 min\n" +
  "FSEAT|Flex|150K|F|Net $1,000/cycle|$4,500 EOD · locks after payout 1|None|None|10 minis|4d @ $350+|90%|50% of profit · $2,500 cap · $500 min\n" +
  "FSEAT|Sprint|25K|E|$1,500 (6%)|$1,000 EOD|None|NONE|Verify|None|90%|—\n" +
  "FSEAT|Sprint|50K|E|$3,000 (6%)|$2,000 EOD|$1,200 soft|NONE|Verify|None|90%|—\n" +
  "FSEAT|Sprint|100K|E|$6,000 (6%)|$3,000 EOD|$1,800 soft|NONE|Verify|None|90%|—\n" +
  "FSEAT|Sprint|150K|E|$9,000 (6%)|$4,500 EOD|$2,700 soft|NONE|Verify|None|90%|—\n" +
  "FSEAT|Sprint|25K|F|—|$1,000 EOD|$500 soft|25% on payout 1 only|Verify|Daily after payout 1|90%|$500 FIXED · buffer $1,100\n" +
  "FSEAT|Sprint|50K|F|—|$2,000 EOD|$1,000 soft|25% on payout 1 only|Verify|Daily after payout 1|90%|$1,000 FIXED · buffer $2,100\n" +
  "FSEAT|Sprint|100K|F|—|$3,000 EOD|$1,500 soft|25% on payout 1 only|Verify|Daily after payout 1|90%|$1,500 FIXED · buffer $3,100\n" +
  "FSEAT|Sprint|150K|F|—|$4,500 EOD|$2,000 soft|25% on payout 1 only|Verify|Daily after payout 1|90%|$2,500 FIXED · buffer $4,100\n" +
  "FSEAT|Direct|25K|F|$1,250 (5%) per cycle|$1,000 EOD|None|Max 15% of profit per TRADE|1 mini|Daily from day one|90%|$500 FIXED\n" +
  "FSEAT|Direct|50K|F|$2,500 (5%) per cycle|$2,000 EOD|$1,500 soft|Max 15% of profit per TRADE|4 minis|Daily from day one|90%|$1,000 FIXED\n" +
  "FSEAT|Direct|100K|F|$5,000 (5%) per cycle|$3,000 EOD|$2,500 soft|Max 15% of profit per TRADE|8 minis|Daily from day one|90%|$2,000 FIXED\n" +
  "FSEAT|Bolt|25K|F|$1,250 (5%) per cycle|$1,000 EOD|None|20% daily on payout 1 only|1 mini|Daily from payout 2|90%|$500 FIXED\n" +
  "FSEAT|Bolt|50K|F|$2,500 (5%) per cycle|$2,000 EOD|$1,500 soft|20% daily on payout 1 only|4 minis|Daily from payout 2|90%|$1,000 FIXED\n" +
  "FSEAT|Bolt|100K|F|$5,000 (5%) per cycle|$3,000 EOD|$2,500 soft|20% daily on payout 1 only|8 minis|Daily from payout 2|90%|$2,000 FIXED\n"

D_FNEXT = "FNEXT|Rapid Pro|25K|E|$1,500|$1,000 EOD|None|None in challenge|2 minis|1 day|90%|—\n" +
  "FNEXT|Rapid Pro|50K|E|$3,000|$2,000 EOD|None|None in challenge|4 minis|1 day|90%|—\n" +
  "FNEXT|Rapid Pro|100K|E|$5,000|$2,500 EOD|None|None in challenge|6 minis|1 day|90%|—\n" +
  "FNEXT|Rapid Pro|25K|F|$500 net/cycle|$1,000 EOD · locks start+$100|None (add-on CUTS price)|40%|2 minis|Every 3 days|90%|$800 cap · $250 min · 5 REWARDS THEN LIVE\n" +
  "FNEXT|Rapid Pro|50K|F|$500 net/cycle|$2,000 EOD · locks start+$100|None (add-on CUTS price)|40%|4 minis|Every 3 days|90%|$1,200 cap · $250 min · 5 REWARDS THEN LIVE\n" +
  "FNEXT|Rapid Pro|100K|F|$500 net/cycle|$2,500 EOD · locks start+$100|None (add-on CUTS price)|40%|6 minis|Every 3 days|90%|$2,500 cap · $250 min · 5 REWARDS THEN LIVE\n" +
  "FNEXT|Rapid Daily|25K|E|$1,500|$1,000 EOD|$500|None in challenge|2 minis|1 day|90%|—\n" +
  "FNEXT|Rapid Daily|50K|E|$3,000|$2,000 EOD|$1,000|None in challenge|4 minis|1 day|90%|—\n" +
  "FNEXT|Rapid Daily|100K|E|$5,000|$2,500 EOD|$1,250|None in challenge|6 minis|1 day|90%|—\n" +
  "FNEXT|Rapid Daily|25K|F|$500 net/cycle|$1,000 EOD · locks start+$100|$500|NONE ever|2 minis|Daily|90%|$800 cap · buffer start+MLL+$100 · 5 THEN LIVE\n" +
  "FNEXT|Rapid Daily|50K|F|$500 net/cycle|$2,000 EOD · locks start+$100|$1,000|NONE ever|4 minis|Daily|90%|$1,200 cap · buffer start+MLL+$100 · 5 THEN LIVE\n" +
  "FNEXT|Rapid Daily|100K|F|$500 net/cycle|$2,500 EOD · locks start+$100|$1,250|NONE ever|6 minis|Daily|90%|$2,500 cap · buffer start+MLL+$100 · 5 THEN LIVE\n" +
  "FNEXT|Flex|50K|E|$2,500|EOD · locks start+$100 — amt verify|None|40% · raises target, no fail|Verify|1 day|80% (90% add-on)|—\n" +
  "FNEXT|Flex|100K|E|$5,000|EOD · locks start+$100 — amt verify|None|40% · raises target, no fail|Verify|1 day|80% (90% add-on)|—\n" +
  "FNEXT|Flex|150K|E|$8,000|EOD · locks start+$100 — amt verify|None|40% · raises target, no fail|Verify|1 day|80% (90% add-on)|—\n" +
  "FNEXT|Flex|50K|F|$500 profit/cycle|Locks at $50,100 after 1st withdrawal|None|None|Verify|5 benchmark d @ $200+|80% (90% add-on)|50% of profit · $1,500 cap · 5 THEN LIVE\n" +
  "FNEXT|Flex|100K|F|$500 profit/cycle|Locks at $100,100 after 1st withdrawal|None|None|Verify|5 benchmark d @ $200+|80% (90% add-on)|50% of profit · $2,500 cap · 5 THEN LIVE\n" +
  "FNEXT|Flex|150K|F|$500 profit/cycle|Locks at $150,100 after 1st withdrawal|None|None|Verify|5 benchmark d @ $250+|80% (90% add-on)|50% of profit · $4,000 cap · 5 THEN LIVE\n" +
  "FNEXT|Legacy|25K|E|$1,500|Tighter — verify|None|40% in challenge|Verify|1 day|Verify|—\n" +
  "FNEXT|Legacy|50K|E|$3,000|$1,500 EOD|None|40% in challenge|Verify|1 day|Verify|—\n" +
  "FNEXT|Legacy|100K|E|$5,000|Tighter — verify|None|40% in challenge|Verify|1 day|Verify|—\n" +
  "FNEXT|Legacy|25K|F|—|Locks at start+$100|None|None|Verify|5 benchmark d @ $100+|Verify|5 REWARDS THEN LIVE\n" +
  "FNEXT|Legacy|50K|F|—|Locks at start+$100|None|None|Verify|5 benchmark d @ $200+|Verify|5 REWARDS THEN LIVE\n" +
  "FNEXT|Legacy|100K|F|—|Locks at start+$100|None|None|Verify|5 benchmark d @ $200+|Verify|5 REWARDS THEN LIVE\n"

// ═════════════════════════════════════════════════════════════════════════
//  BUILD LOOKUP
// ═════════════════════════════════════════════════════════════════════════
var map<string, string> DB = map.new<string, string>()

if barstate.isfirst
    string blob = D_ALPHA + D_TOPSTEP + D_TRADEIFY + D_APEX + D_LUCID + D_MFFU + D_TPT + D_FELITE + D_FSEAT + D_FNEXT
    array<string> lines = str.split(blob, "\n")
    for i = 0 to array.size(lines) - 1
        string ln = array.get(lines, i)
        if str.length(ln) > 10
            array<string> f = str.split(ln, "|")
            if array.size(f) >= 12
                map.put(DB, array.get(f, 0) + "|" + array.get(f, 1) + "|" + array.get(f, 2) + "|" + array.get(f, 3), ln)

// ═════════════════════════════════════════════════════════════════════════
//  RENDER
// ═════════════════════════════════════════════════════════════════════════
tblPos = switch posIn
    "Top Left" => position.top_left
    "Top Center" => position.top_center
    "Top Right" => position.top_right
    "Middle Left" => position.middle_left
    "Middle Right" => position.middle_right
    "Bottom Left" => position.bottom_left
    "Bottom Center" => position.bottom_center
    => position.bottom_right

tblSize = switch szIn
    "Tiny" => size.tiny
    "Small" => size.small
    "Normal" => size.normal
    => size.large

// title bar always renders larger than the table body
ttlSize = switch szIn
    "Tiny" => size.normal
    "Small" => size.large
    "Normal" => size.large
    => size.huge

var table tbl = na

if barstate.islast
    bool vert = layoutIn == "Vertical"

    // ── which rule fields are enabled ──
    fldIdx = array.new_int(0)
    fldNam = array.new_string(0)
    if kTgt
        array.push(fldIdx, 4)
        array.push(fldNam, "TARGET / GOAL")
    if kML
        array.push(fldIdx, 5)
        array.push(fldNam, "MAX LOSS")
    if kDLL
        array.push(fldIdx, 6)
        array.push(fldNam, "DAILY LOSS")
    if kCon
        array.push(fldIdx, 7)
        array.push(fldNam, "CONSISTENCY")
    if kCt
        array.push(fldIdx, 8)
        array.push(fldNam, "CONTRACTS")
    if kMD
        array.push(fldIdx, 9)
        array.push(fldNam, "DAYS / CADENCE")

    // ── which firms are enabled ──
    fKey = array.new_string(0)
    fLbl = array.new_string(0)
    fPln = array.new_string(0)
    fSzz = array.new_string(0)
    fPhs = array.new_string(0)

    if on1
        array.push(fKey, "ALPHA")
        array.push(fLbl, "ALPHA FUTURES")
        array.push(fPln, pl1)
        array.push(fSzz, sz1)
        array.push(fPhs, ph1)
    if on2
        array.push(fKey, "TOPSTEP")
        array.push(fLbl, "TOPSTEP")
        array.push(fPln, pl2)
        array.push(fSzz, sz2)
        array.push(fPhs, ph2)
    if on3
        array.push(fKey, "TRADEIFY")
        array.push(fLbl, "TRADEIFY")
        array.push(fPln, pl3)
        array.push(fSzz, sz3)
        array.push(fPhs, ph3)
    if on4
        array.push(fKey, "APEX")
        array.push(fLbl, "APEX")
        array.push(fPln, pl4)
        array.push(fSzz, sz4)
        array.push(fPhs, ph4)
    if on5
        array.push(fKey, "LUCID")
        array.push(fLbl, "LUCID")
        array.push(fPln, pl5)
        array.push(fSzz, sz5)
        array.push(fPhs, ph5)
    if on6
        array.push(fKey, "MFFU")
        array.push(fLbl, "MYFUNDEDFUTURES")
        array.push(fPln, pl6)
        array.push(fSzz, sz6)
        array.push(fPhs, ph6)
    if on7
        array.push(fKey, "TPT")
        array.push(fLbl, "TAKE PROFIT TRADER")
        array.push(fPln, pl7)
        array.push(fSzz, sz7)
        array.push(fPhs, ph7)
    if on8
        array.push(fKey, "FELITE")
        array.push(fLbl, "FUTURESELITE")
        array.push(fPln, pl8)
        array.push(fSzz, sz8)
        array.push(fPhs, ph8)
    if on9
        array.push(fKey, "FSEAT")
        array.push(fLbl, "FUNDEDSEAT")
        array.push(fPln, pl9)
        array.push(fSzz, sz9)
        array.push(fPhs, ph9)
    if on10
        array.push(fKey, "FNEXT")
        array.push(fLbl, "FUNDEDNEXT")
        array.push(fPln, pl10)
        array.push(fSzz, sz10)
        array.push(fPhs, ph10)

    int nFld = array.size(fldIdx)
    int nFirm = array.size(fKey)

    // ── resolve each firm's data row once ──
    fDat = array.new_string(0)
    fOk = array.new_bool(0)
    for r = 0 to nFirm - 1
        string phC = array.get(fPhs, r) == "Evaluation" ? "E" : "F"
        string k = array.get(fKey, r) + "|" + array.get(fPln, r) + "|" + array.get(fSzz, r) + "|" + phC
        bool hit = map.contains(DB, k)
        array.push(fOk, hit)
        array.push(fDat, hit ? map.get(DB, k) : "")

    int tR = 1
    int fR = showFoot ? 1 : 0
    int nCol = vert ? nFirm + 1 : nFld + 1
    int nRow = (vert ? nFld : nFirm) + 1 + tR + fR

    if not na(tbl)
        table.delete(tbl)

    if nFirm > 0 and nFld > 0
        tbl := table.new(tblPos, nCol, nRow, bgcolor = cBg, border_color = cBd, border_width = bdW, frame_color = cBd, frame_width = bdW)

        // ── title bar ──
        // ── title bar (fixed) ──
        string mark = markStyle == "Block" ? "█" : markStyle == "Bars" ? "▁▄█" : markStyle == "None" ? " " : "╻\n█\n╹"
        table.cell(tbl, 0, 0, mark, text_color = cLogo, bgcolor = cTtlBg, text_size = ttlSize, text_halign = text.align_center)

        // split the remaining width into two even halves, one title per half
        int mid = math.max(2, int(math.ceil(nCol / 2.0)))
        if nCol - 1 >= 2
            for c = 1 to mid - 1
                table.cell(tbl, c, 0, c == 1 ? SITE : "", text_color = cTtlTx, bgcolor = cTtlBg, text_size = ttlSize, text_halign = text.align_center)
            if mid - 1 > 1
                table.merge_cells(tbl, 1, 0, mid - 1, 0)

            for c = mid to nCol - 1
                table.cell(tbl, c, 0, c == mid ? SUB : "", text_color = cSub, bgcolor = cTtlBg, text_size = ttlSize, text_halign = text.align_center)
            if nCol - 1 > mid
                table.merge_cells(tbl, mid, 0, nCol - 1, 0)
        else
            // too narrow to split: both titles share one cell
            table.cell(tbl, 1, 0, SITE + "  ·  " + SUB, text_color = cSub, bgcolor = cTtlBg, text_size = ttlSize, text_halign = text.align_center)

        if vert
            // ── firms across the top, rules down the side ──
            table.cell(tbl, 0, tR, "RULE  ▾", text_color = cHdT, bgcolor = cHd, text_size = tblSize, text_halign = text.align_left, height = rowH)
            for c = 0 to nFirm - 1
                string hTxt = array.get(fLbl, c) + "\n" + (array.get(fPhs, c) == "Evaluation" ? "EVAL" : "FUNDED")
                if showKey
                    hTxt := hTxt + "\n" + array.get(fPln, c) + " · " + array.get(fSzz, c)
                table.cell(tbl, c + 1, tR, hTxt, text_color = cHdT, bgcolor = cHd, text_size = tblSize, text_halign = text.align_left, height = rowH)

            for r = 0 to nFld - 1
                color rowBg = r % 2 == 0 ? cBg : cBgAlt
                table.cell(tbl, 0, tR + 1 + r, array.get(fldNam, r), text_color = cAcc, bgcolor = rowBg, text_size = tblSize, text_halign = text.align_left, height = rowH)
                for c = 0 to nFirm - 1
                    string v = "n/a"
                    if array.get(fOk, c)
                        v := array.get(str.split(array.get(fDat, c), "|"), array.get(fldIdx, r))
                    table.cell(tbl, c + 1, tR + 1 + r, v, text_color = array.get(fOk, c) ? cTx : color.new(cTx, 55), bgcolor = rowBg, text_size = tblSize, text_halign = text.align_left, height = rowH)
        else
            // ── firms down the side, rules across the top ──
            table.cell(tbl, 0, tR, "FIRM  ▸", text_color = cHdT, bgcolor = cHd, text_size = tblSize, text_halign = text.align_left, height = rowH)
            for c = 0 to nFld - 1
                table.cell(tbl, c + 1, tR, array.get(fldNam, c), text_color = cHdT, bgcolor = cHd, text_size = tblSize, text_halign = text.align_left, height = rowH)

            for r = 0 to nFirm - 1
                color rowBg = r % 2 == 0 ? cBg : cBgAlt
                string firmTxt = array.get(fLbl, r) + "  [" + (array.get(fPhs, r) == "Evaluation" ? "EVAL" : "FUNDED") + "]"
                if showKey
                    firmTxt := firmTxt + "\n" + array.get(fPln, r) + " · " + array.get(fSzz, r)
                table.cell(tbl, 0, tR + 1 + r, firmTxt, text_color = cAcc, bgcolor = rowBg, text_size = tblSize, text_halign = text.align_left, height = rowH)
                for c = 0 to nFld - 1
                    string v = "n/a this phase"
                    if array.get(fOk, r)
                        v := array.get(str.split(array.get(fDat, r), "|"), array.get(fldIdx, c))
                    table.cell(tbl, c + 1, tR + 1 + r, v, text_color = array.get(fOk, r) ? cTx : color.new(cTx, 55), bgcolor = rowBg, text_size = tblSize, text_halign = text.align_left, height = rowH)

        // ── footer ──
        if showFoot
            table.cell(tbl, 0, nRow - 1, tagLine + "  ·  data 31 Jul 2026, verify before trading", text_color = cTag, bgcolor = cBg, text_size = size.tiny, text_halign = text.align_left)
            for c = 1 to nCol - 1
                table.cell(tbl, c, nRow - 1, "", bgcolor = cBg)
            if nCol > 2
                table.merge_cells(tbl, 0, nRow - 1, nCol - 1, nRow - 1)
````
