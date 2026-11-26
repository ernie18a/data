# Nested FVG Pro

- url: https://www.tradingview.com/script/pYR28OeS-Nested-FVG-Pro/
- type: indicator
- pine_id: PUB;03e40489804a4fed9ea1a3dd6ec60102
- version: 1.0

## Description

Nested FVG Pro identifies a specific ICT confluence — a 1-minute Fair Value Gap forming inside an active 5-minute Fair Value Gap — and manages a complete multi-contract trade plan around each signal, with journalling that models how automated orders actually fill rather than assuming ideal prices.

HOW IT WORKS

5-minute context. The script aggregates 1-minute bars into rolling 5-minute candles and scans each completed triplet for a displacement gap: a bullish FVG (BISI) exists where the current candle's low sits above the high from two candles back; bearish (SIBI) is the mirror. Gaps must exceed a minimum size in points — set against your stop distance, so an imbalance smaller than meaningful displacement never becomes context. Qualifying zones are drawn and tracked.

Zone lifecycle. A zone is invalidated when price closes through its far side. Invalidated zones are not deleted immediately: they stop extending, dim, and remain on the chart for a configurable number of bars so past signals can be audited, and they are never removed while a trade is open. An active-zone cap per direction prevents stacking — in a sustained trend, zones pointing with the trend are never closed through, so without a cap they accumulate all session and progressively bias signal generation toward chasing the move.

Inversion mode (IFVG). A gap that price has closed through has failed. ICT treats the violated gap as flipped: a bullish FVG closed below becomes resistance, a bearish FVG closed above becomes support. In IFVG mode the invalidation event flips the zone's direction instead of retiring it, and signals are then taken as price returns into the zone from the other side. Inverted zones are colour-coded distinctly, expire on a configurable age, and retire permanently if closed through a second time. Signal Source selects virgin gaps, inverted gaps, or both.

1-minute trigger. On each confirmed 1-minute bar the script tests for a fresh 1-minute FVG using the same three-candle definition and its own minimum size. A signal fires only where that gap sits inside an eligible 5-minute zone of matching direction, within a proximity tolerance in points around the zone boundaries. The premise: a small-timeframe imbalance printing inside a larger unmitigated imbalance marks continuation pressure in the direction of the higher-timeframe displacement.

Signal gating. Cooldown between signals; a hardcoded one-trade-at-a-time block; an exchange-session filter; six independently configurable time windows with editable start and end times in a selectable timezone; and a daily loss limit in dollars that blocks new signals once reached. The daily reset and zone purge are driven by a change of CME trade date rather than a session-transition test, so they behave correctly regardless of whether bars print during the session gap.

Trade management. Each signal is managed as a ladder measured in points from the entry: a stop, a partial exit that optionally moves the stop to break-even, a main target, an extended target, and an optional fourth-contract runner target. All distances and per-level contract counts are inputs. A per-trade dollar maximum-loss exit closes the position on a confirmed bar if unrealised loss breaches the limit.

Optional entry laddering. Position size can be split across up to three legs — the signal bar's close, consequent encroachment (the 50% level of the 1-minute gap), and the gap's far edge — all sharing one structural stop, so each deeper leg risks fewer points than the one before. Fills are position-weighted and exit quantities are capped to what actually filled, so a trade that displaces immediately never sends exits for contracts it never bought. The trade-off is explicit: setups that run straight to target fill the smallest size while setups that retrace fill the largest.

Execution-modelled journalling — what makes this different. Most signal trackers book trades at exact level prices. In live automation, alerts fire once per bar close and fill as market orders, so real fills land at the trigger bar's close rather than at the level touched intrabar. This script separates plan levels, which drive the triggers, from booked fills, which drive the accounting: with fill booking enabled, every entry and exit in the Trade Tracker, Hourly and Weekly tables is recorded at the trigger bar's close plus a configurable per-fill slippage, and round-turn commissions are netted from every result. Levels can be anchored to the entry fill rather than the gap boundary, so a 20-point stop is 20 points from the price paid. Break-even moves to the position's weighted average fill, matching what a broker-side breakeven order does. The result is a journal that reconciles with a broker statement instead of an idealised one.

A/B variant lab. A read-only shadow journal replays every signal a second time under a different partial distance and break-even rule, reporting both policies side by side with the difference between them. It places no orders and never touches the live journal — it answers whether an exit-policy change would have helped on your own history rather than a hypothetical one.

MODES

Runner off: 3-contract exit ladder, flat at the extended target. Runner on: a 4th contract rides to the runner target.
Entry ladder off: one full-size entry. On: up to three scale-in legs sharing one stop.
Signal Source: FVG, IFVG, or Both.
A/B lab off by default.

AUTOMATION (OPTIONAL)

The script emits complete JSON webhook payloads for every event — entry with quantity, order type and an optional attached stop so a real protective order rests at the broker; partial with an optional broker-side breakeven action; break-even scratch; each target; stop; and emergency exit — with quantities computed from the position-sizing inputs. One alert with the condition "Any alert() function call" drives all of it. Manual traders can ignore this entirely and trade the on-chart levels.

HOW TO USE

Apply to a 1-minute chart — the script builds its own 5-minute context, and other chart timeframes will not behave correctly. Set your ladder distances and dollar-per-point for the instrument, choose your windows and timezone, set the minimum gap sizes and proximity in points relative to your stop, and set the daily and per-trade loss limits. Signals print as triangles with the full R/R ladder drawn to the right; the Trade Tracker logs every signal's outcome net of modelled costs.

LIMITATIONS & NOTES

Outcome detection is evaluated on confirmed bars; live automated fills are bar-close market orders, which is precisely what the execution-modelled tables account for.
The analytics model execution. A broker statement remains the ground truth.
All distances are in points and are calibrated per instrument. Moving between instruments of different volatility requires rescaling every point input.
Entry laddering requires add-to-position support in your webhook platform.
This is a technical analysis and automation tool, not financial advice. Past behaviour of any configuration does not guarantee future results. Test on simulated accounts before risking capital.

The source is open — read it, fork it, adapt it. If you change the detection or the accounting, the tables will tell you what the change did.

## Source Code

````pine
// Nested FVG Pro
// ICT nested Fair Value Gap detector with optional inversion (IFVG) mode,
// configurable session windows, and execution-modelled trade journalling.
//
// Run on a 1-MINUTE chart. The script aggregates its own 5-minute context;
// other chart timeframes will not behave correctly.
//
// All distances are in POINTS and are calibrated per instrument. Moving to an
// instrument of different volatility requires rescaling every point input.

//@version=6
indicator("Nested FVG Pro", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// ─────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────
grp1 = "5-Minute FVG Settings"
fvg5_show      = input.bool(true,  "Show 5-min FVGs",                      group=grp1)
fvg5_bull_col  = input.color(color.new(#00bcd4, 70), "5-min Bullish Color", group=grp1)
fvg5_bear_col  = input.color(color.new(#ff5252, 70), "5-min Bearish Color", group=grp1)
fvg5_mitigated = input.bool(true,  "Remove 5-min FVG When Mitigated",       group=grp1)
fvg5_mit_mode  = input.string("Close through far side", "Zone Invalidation", group=grp1, options=["Close through far side","Touch (any entry into gap)","50% (consequent encroachment)"], tooltip="WARNING — this strategy requires price to trade back INTO the 5-min zone so a 1-min FVG can form inside it. Touch and 50% modes mark the zone mitigated at or before that moment, so they will suppress most or all signals. Close through far side is the default for exactly that reason; the other two are for experimentation only.")
fvg5_hold_bars = input.int(15, "Keep Invalidated Zones Visible (bars)",   group=grp1, minval=0, maxval=500, tooltip="After a zone is invalidated it stops extending and dims, then is deleted this many bars later. 0 = delete immediately. Zones are never deleted while a trade is open, so the zone behind a live signal always stays on the chart.")
fvg5_max_zones = input.int(6,  "Max Active Zones per Direction",          group=grp1, minval=1, maxval=50, tooltip="Caps zone stacking. When active zones in one direction exceed this, the oldest is retired. Without a cap, a trending session accumulates unmitigated zones in the trend direction all day and progressively biases signals toward chasing the move.")
fvg5_max_age   = input.int(0,  "Max Zone Age (bars, 0 = no limit)",       group=grp1, minval=0, maxval=2000, tooltip="Optional: retire a zone this many 1-minute bars after it forms regardless of price action.")
fvg5_min_pts   = input.float(6.0,  "5-min FVG Min Size (points)",           group=grp1, minval=0, step=0.25, tooltip="Minimum size of the 5-minute displacement gap, in points. A 5-min FVG smaller than this is ignored and cannot host a nested signal. Judge it against your stop: with a 20-point stop, a gap under ~5 points is not meaningful displacement. Set to 0 to accept every gap. The old 0.15 basis-point default worked out to ~0.45 points, i.e. effectively no filter.")
fvg5_prev_bp   = input.bool(false, "   (legacy) treat value above as basis points", group=grp1, tooltip="Compatibility switch: ON treats the value above as basis points of price instead of points.")

grpS = "Signal Source"
sig_mode    = input.string("FVG", "Signal Source", group=grpS, options=["FVG","IFVG","Both"], tooltip="FVG: trade virgin gaps (original behavior). IFVG: trade only gaps price has already closed through, in the flipped direction, as price returns to them. Both: either qualifies.")
inv_max_age = input.int(240, "Inverted Zone Max Age (bars, 0 = none)", group=grpS, minval=0, maxval=2000, tooltip="How long a flipped zone stays tradeable after inversion. 240 = four hours on a 1-minute chart.")

grp2 = "1-Minute FVG Settings"
fvg1_show      = input.bool(true,  "Show 1-min Nested FVGs",               group=grp2)
fvg1_bull_col  = input.color(color.new(#69f0ae, 40), "1-min Bullish Color", group=grp2)
fvg1_bear_col  = input.color(color.new(#ff8a80, 40), "1-min Bearish Color", group=grp2)
fvg1_min_pts   = input.float(2.0,  "1-min FVG Min Size (points)",           group=grp2, minval=0, step=0.25, tooltip="Minimum size of the 1-minute entry gap, in points. Filters out micro-gaps that are really just spread. The old 0.15 basis-point default worked out to ~0.45 points.")
fvg1_entry     = input.string("Immediate", "1-min FVG Entry Spot",         group=grp2, options=["Immediate","Near Edge","Middle","Far Edge"], tooltip="Where the entry sits within the 1-min FVG. Immediate = enter at market close the moment the FVG forms; Near Edge = shallowest pullback fill; Middle = 50% level; Far Edge = deepest fill (original behavior). Stop and all targets shift with the entry.")

grp3 = "Signal Settings"
sig_bull_col   = input.color(color.new(#00e676, 0), "Bullish Label Color",  group=grp3)
sig_bear_col   = input.color(color.new(#ff1744, 0), "Bearish Label Color",  group=grp3)
alert_on_nest  = input.bool(true, "Alert on Nested FVG",                    group=grp3)
alert_partial  = input.bool(true, "Alert on Partial/BE Hit",                group=grp3)
alert_stop     = input.bool(true, "Alert on Stop Hit",                      group=grp3)
alert_target   = input.bool(true, "Alert on Target Hit",                    group=grp3)
cooldown_bars  = input.int(30, "Cooldown Between Signals (bars/mins)",       group=grp3, minval=1, maxval=120)
// Open Trade Handling — hardcoded to Block mode for safety
// New signals are ignored while a trade is open
string trade_mode = "Block new trades until open trade closes"
invalidate_partial = input.bool(true, "Invalidate If Partial Hit Before Entry", group=grp3, tooltip="For pullback entries (Near/Middle/Far Edge): if price reaches the partial target before the entry fills, cancel the pending setup as invalid. Does not apply to Immediate entries.")

grpA = "Level Anchor"
anchor_mode = input.string("Entry Fill", "Anchor Levels To", group=grpA, options=["Entry Fill","FVG Edge"], tooltip="Entry Fill (recommended): in Immediate mode the stop and targets are measured from the signal bar's close, which is what a market order actually pays, so a 20-point stop really is 20 points. FVG Edge measures from the gap boundary instead. Pullback entry modes are unaffected — their entry level already is the fill.")

grp6 = "R/R Tool"
rr_show        = input.bool(true,  "Show R/R Levels",                       group=grp6)
rr_label_size  = input.string("tiny", "R/R Label Size",                     group=grp6, options=["tiny","small","normal","large","huge"])
rr_stop_pts    = input.float(20.0, "Stop Loss (points)",                    group=grp6, minval=1, step=0.25)
rr_target_pts  = input.float(45.0, "Main Target (points)",                  group=grp6, minval=1, step=0.25)
rr_partial_pts = input.float(20.0, "Partial / BE Target (points)",          group=grp6, minval=1, step=0.25)
rr_ext_pts     = input.float(60.0, "Extended Target T2 (points)",           group=grp6, minval=1, step=0.25)
rr_t3_pts      = input.float(100.0, "Runner Target T3 (points)",            group=grp6, minval=1, step=0.25, tooltip="Hard exit for the runner (contract 4). Rides with BE stop after partial, exits here automatically.")
rr_stop_col    = input.color(color.new(#ff1744, 0), "Stop Color",           group=grp6)
rr_entry_col   = input.color(color.new(#ffeb3b, 0), "Entry Color",          group=grp6)
rr_target_col  = input.color(color.new(#00e676, 0), "Target Color",         group=grp6)
rr_partial_col = input.color(color.new(#2196f3, 0), "Partial Color",        group=grp6)
rr_ext_col     = input.color(color.new(#ffeb3b, 0), "Extended Target Color", group=grp6)
rr_t3_col      = input.color(color.new(#e040fb, 0), "Runner T3 Color",      group=grp6)

grp8 = "Position Sizing"
use_t3_runner     = input.bool(false, "Enable T3 Runner (4-contract mode)", group=grp8, tooltip="OFF = 3-contract ladder that goes flat at T2. ON = a 4th contract rides behind the break-even stop to the Runner Target T3. Set Contracts per Trade to match: 3 with runner off, 4 with runner on. With the runner OFF, Contracts per Trade should equal Partial + T1 + T2 contracts.")
pos_qty           = input.int(3,   "Contracts per Trade",              group=grp8, minval=1, tooltip="3 for the standard ladder, 4 when the T3 runner is enabled.")
pos_qty_part      = input.int(1,   "Contracts Closed at Partial",      group=grp8, minval=0)
pos_qty_tgt       = input.int(1,   "Contracts Closed at Target",       group=grp8, minval=0)
pos_qty_ext       = input.int(1,   "Contracts Closed at T2 (Ext)",     group=grp8, minval=0, tooltip="Contracts exited at Extended Target T2 (60pts). The remaining contracts after Partial + Target + T2 automatically become the T3 runner (100pts hard exit).")
pos_qty_t3_info   = input.string("= Total minus Partial/T1/T2", "Contracts Closed at T3 Runner (auto)", group=grp8, options=["= Total minus Partial/T1/T2"], tooltip="Auto-calculated: Contracts per Trade minus Partial minus T1 minus T2. With default settings (4-1-1-1) = 1 contract exits at T3 (100pts). This field is display only — no changes needed.")
pos_be_at_partial = input.bool(true, "Move Stop to Break-Even at Partial", group=grp8)
per_trade_dll     = input.float(120.0, "Max Loss Per Trade ($)",           group=grp8, minval=0, step=10, tooltip="Emergency exit if unrealized loss on the current trade exceeds this dollar amount on a confirmed bar close. At $2/pt MNQ: 3 contracts x 20pts = $120; 4 contracts x 20pts = $160.")
per_trade_dll_en  = input.bool(true,  "Enable Max Loss Per Trade",         group=grp8)

grp9 = "Execution Modeling (TradersPost)"
exec_book_close = input.bool(true,  "Book Fills at Bar Close",            group=grp9, tooltip="Models live TradersPost behavior: alerts fire once per bar close and fill as market orders ~1s later, so real fills land at the trigger bar's CLOSE, not at the exact level. ON = journal books entries/exits at trigger-bar close (accurate vs broker). OFF = original theoretical level-fill accounting.")
exec_slip_pts   = input.float(0.25, "Slippage per Fill (points)",         group=grp9, minval=0, step=0.25, tooltip="Adverse slippage applied to every booked fill (entry and exits). 0.25–0.50 is typical for MNQ market orders.")
tp_send_stop    = input.bool(true,  "Attach Catastrophic Stop to Entry Webhook", group=grp9, tooltip="Adds an absolute stopLoss to the entry alert() JSON so a REAL stop-market order rests at the broker at the plan stop level. Protects against TradingView/webhook/internet failure. Requires the 'Any alert() function call' alert. Recommended: also enable 'Cancel existing open orders before placing new orders' in your TradersPost strategy so stale stops are cleaned up.")
tp_send_be      = input.bool(true,  "Send TradersPost breakeven Action at Partial", group=grp9, tooltip="When the partial fills, also sends {\"action\":\"breakeven\",\"orderType\":\"stop\"} so a real stop rests at the broker's average entry price (plus your Exit breakeven offset in TradersPost). The bar-close BE scratch exit still fires as a fallback; an exit signal on a flat position is ignored by TradersPost.")

grpL = "Entry Laddering (Scale-In)"
lad_en    = input.bool(false, "Enable Entry Ladder",                     group=grpL, tooltip="OFF = single full-size entry at the signal bar close (original behavior). ON = size is split across up to 3 legs: leg 1 at the signal bar close, leg 2 at consequent encroachment (50% of the 1-min FVG), leg 3 at the far edge. ALL legs share the same structural stop, so deeper legs risk fewer points. Legs 2 and 3 only fill if price retraces into the gap before the partial is hit. TRADE-OFF: trades that run immediately fill only leg 1 (smaller size on your best trades), while trades that retrace fill everything. Exit quantities are automatically capped to what actually filled. REQUIRES: Allow add to position enabled in your webhook platform strategy.")
lad_qty1  = input.int(1, "Leg 1 Contracts — signal bar close",           group=grpL, minval=1)
lad_qty2  = input.int(1, "Leg 2 Contracts — consequent encroachment",    group=grpL, minval=0)
lad_qty3  = input.int(1, "Leg 3 Contracts — far edge",                   group=grpL, minval=0, tooltip="Set to 0 for a 2-leg ladder.")
lad_stop_every = input.bool(true, "Attach Stop to Every Leg",            group=grpL, tooltip="ON = each leg entry webhook carries the shared stop price. OFF = only leg 1 carries it. If your platform cancels existing orders before placing new ones, ON keeps a stop attached to the most recent order; verify behavior on one account before scaling.")

grpAB = "A/B Variant Lab (read-only)"
ab_en          = input.bool(false, "Enable A/B Variant Tracking",        group=grpAB, tooltip="Runs a second, hypothetical journal over the same signals using the variant settings below. It never sends orders and never touches the live tables — it only answers: what would a different exit policy have done on this exact history? The variant always assumes a single full-size entry at leg 1 fill, so it stays comparable when laddering is on.")
ab_partial_pts = input.float(30.0, "Variant: Partial / BE Target (pts)", group=grpAB, minval=1, step=0.25)
ab_be          = input.bool(false, "Variant: Move Stop to BE at Partial", group=grpAB)
ab_tbl_pos     = input.string("Middle Right", "Variant Table Position",  group=grpAB, options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right","Middle Left"])

grp7 = "Trade Tracker"
tbl_show       = input.bool(true,  "Show Trade Tracker Table",              group=grp7)
tbl_pos        = input.string("Bottom Right", "Table Position",             group=grp7, options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right","Middle Left"])
tbl_size       = input.string("small", "Table Text Size",                   group=grp7, options=["tiny","small","normal"])
tbl_max_rows   = input.int(10, "Max Rows to Display",                       group=grp7, minval=3, maxval=20)
tbl_tz_opt     = input.string("America/New_York", "Tracker Time Zone",  group=grp7, options=["Auto (Chart/Exchange)","America/New_York","America/Chicago","America/Denver","America/Los_Angeles","America/Sao_Paulo","Europe/London","Europe/Berlin","Asia/Tokyo","Asia/Shanghai","Asia/Kolkata","Australia/Sydney","UTC"], tooltip="Time zone for Date/Time columns and Today Only filter. Auto uses the symbol exchange timezone.")
tbl_today_only = input.bool(true,  "Today Only",                            group=grp7)
tbl_show_usd   = input.bool(true,  "Show $ P&L Column",                     group=grp7)
tbl_usd_per_pt = input.float(2.0,  "$ per Point",                           group=grp7, minval=0.0, step=0.5)
tbl_show_shown = input.bool(true,  "Show Shown Trades Summary Row",         group=grp7)
tbl_hourly     = input.bool(true,  "Show Hourly Performance Table",         group=grp7)
tbl_hourly_pos = input.string("Bottom Left", "Hourly Table Position",       group=grp7, options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right","Middle Left"])
tbl_theme      = input.string("Dark", "Table Theme",                           group=grp7, options=["Dark","Light"])
tbl_weekly     = input.bool(true,  "Show Weekly Summary Table",            group=grp7)
tbl_weekly_pos = input.string("Top Left", "Weekly Table Position",         group=grp7, options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right","Middle Left"])

grpC = "Costs (Commissions)"
comm_en = input.bool(true,  "Model Commissions",                        group=grpC, tooltip="Subtract round-turn trading costs from all P&L tables. Turn OFF to see gross points.")
comm_rt = input.float(1.34, "Round-Turn Cost per Contract ($)",         group=grpC, minval=0, step=0.01, tooltip="All-in cost to open AND close one contract: broker commission plus exchange, clearing, NFA and platform fees. VERIFY THIS AGAINST YOUR OWN STATEMENT — rates differ by prop firm, plan and platform, and micro rates change. Look at a filled round turn in your broker statement and use the actual total. The cost is charged when a contract is filled, so it appears immediately rather than at exit.")

grp5 = "Proximity Filter"
proximity_pts  = input.float(3.0, "Proximity Tolerance (points)",           group=grp5, minval=0, step=0.25, tooltip="How far outside the 5-minute zone boundaries a 1-minute FVG may sit and still count as nested. This is the loosest part of the signal definition: at the old 5 basis-point default this was ~15 points at MNQ, meaning a 1-min gap could sit most of a stop distance outside the zone and still qualify. Tighter values (1-4 pts) enforce genuine nesting.")

grp4 = "Time Filter"
sess_string    = input.session("1900-1600:1234567", "Session (Exchange Time)", group=grp4)
stop_hour_ct   = input.int(16,    "Stop Trading At Hour (inactive)",           group=grp4, minval=0, maxval=23, tooltip="INACTIVE — this input is not wired to the signal logic and has never been. Session (Exchange Time) above and the Trading Windows group below control when signals are allowed. Kept only so existing saved settings do not shift; changing it has no effect.")
dll_enabled    = input.bool(true, "Enable Daily Loss Limit",                   group=grp4)
dll_usd        = input.float(400.0, "Daily Loss Limit ($)",                    group=grp4, minval=0, step=50, tooltip="No new signals once daily losses reach this dollar amount.")

grpH = "Trading Windows"
use_windows    = input.bool(true,  "Use Trading Windows",                       group=grpH, tooltip="Master switch. When off, signals are allowed at any time inside the Session.")
win_tz         = input.string("America/New_York", "Window Timezone",            group=grpH, options=["America/Chicago","America/New_York"], tooltip="Applies to all six windows below. Exchange facts are unaffected: the Session input and the 17:00 CT trade-date roll stay on exchange time. Note a window only fires if the Session also covers it — the default Session 1700-1600 covers everything except 16:00-17:00 CT.")
// Named sessions. Times are read in the Window Timezone above (default ET).
w1_en = input.bool(false, "Globex Open",    group=grpH, inline="w1")
w1_s  = input.session("1800-1930", "",      group=grpH, inline="w1", tooltip="CME futures reopen. 18:00 ET = 17:00 CT.")
w2_en = input.bool(false, "Asia Open",      group=grpH, inline="w2")
w2_s  = input.session("1930-2030", "",      group=grpH, inline="w2", tooltip="Around the Tokyo cash open. Because Japan does not observe DST, this drifts by an hour against ET twice a year.")
w3_en = input.bool(false, "London Open",    group=grpH, inline="w3")
w3_s  = input.session("0300-0400", "",      group=grpH, inline="w3", tooltip="08:00 London. UK and US daylight-saving changes are three weeks apart, so for those weeks the London open lands at 04:00 ET instead of 03:00.")
w4_en = input.bool(true,  "NY Pre-market",  group=grpH, inline="w4")
w4_s  = input.session("0730-0900", "",      group=grpH, inline="w4", tooltip="Ends before the 09:30 ET equity open.")
w5_en = input.bool(true,  "NY Session",     group=grpH, inline="w5")
w5_s  = input.session("1000-1400", "",      group=grpH, inline="w5", tooltip="Starts after the opening 30 minutes have settled.")
w6_en = input.bool(false, "Custom",         group=grpH, inline="w6")
w6_s  = input.session("1200-1300", "",      group=grpH, inline="w6", tooltip="Spare slot for anything not covered above.")

// ─────────────────────────────────────────────────────────
//  CONVERSIONS
// ─────────────────────────────────────────────────────────
rr_sz = switch rr_label_size
    "tiny"   => size.tiny
    "small"  => size.small
    "normal" => size.normal
    "large"  => size.large
    => size.huge

tbl_pos_conv = switch tbl_pos
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    "Middle Right" => position.middle_right
    => position.middle_left

tbl_sz_conv = switch tbl_size
    "tiny"  => size.tiny
    "small" => size.small
    => size.normal

// ─────────────────────────────────────────────────────────
//  THEME COLORS
// ─────────────────────────────────────────────────────────
bool isDark      = tbl_theme == "Dark"
color th_hbg     = isDark ? color.new(#1a1a2e, 0)   : color.new(#e8eaf6, 0)
color th_row_bg  = isDark ? color.new(#2a2a3e, 20)  : color.new(#ffffff, 10)
color th_sum_bg  = isDark ? color.new(#1a1a2e, 0)   : color.new(#c5cae9, 0)
color th_text    = isDark ? color.white               : color.new(#1a237e, 0)
color th_muted   = isDark ? color.new(color.gray, 0) : color.new(#5c6bc0, 0)
color th_hourly  = isDark ? color.new(color.gray, 80): color.new(#e8eaf6, 20)

// Resolve tracker timezone
string tbl_tz = tbl_tz_opt == "Auto (Chart/Exchange)" ? syminfo.timezone : tbl_tz_opt

// ─────────────────────────────────────────────────────────
//  SESSION
// ─────────────────────────────────────────────────────────
inSession         = not na(time(timeframe.period, sess_string, "America/Chicago"))
// CME trade date rolls at 17:00 CT. Shifting the clock forward 7 hours puts that
// roll on midnight, so a plain date change detects it — and unlike an inSession
// transition it does not depend on bars existing during the session gap.
int  _trade_day   = dayofmonth(time + 7 * 60 * 60 * 1000, "America/Chicago")
bool newTradeDay  = not na(_trade_day[1]) and _trade_day != _trade_day[1]

// Trading windows
f_inwin(bool _en, string _sess) =>
    _en and not na(time(timeframe.period, _sess, win_tz))

bool hourOk = true
if use_windows
    hourOk := f_inwin(w1_en, w1_s) or f_inwin(w2_en, w2_s) or f_inwin(w3_en, w3_s) or
              f_inwin(w4_en, w4_s) or f_inwin(w5_en, w5_s) or f_inwin(w6_en, w6_s)

// ─────────────────────────────────────────────────────────
//  5-MIN FVG STORAGE
// ─────────────────────────────────────────────────────────
var float[] fvg5_top    = array.new_float(0)
var float[] fvg5_bot    = array.new_float(0)
var int[]   fvg5_dir    = array.new_int(0)
var box[]   fvg5_box    = array.new_box(0)
var label[] fvg5_llabel = array.new_label(0)
var label[] fvg5_rlabel = array.new_label(0)
var box[]   fvg1_boxes  = array.new_box(0)
var bool[]  fvg5_active = array.new_bool(0)   // eligible to host a nested signal
var int[]   fvg5_mitbar = array.new_int(0)    // bar_index when invalidated (-1 while active)
var int[]   fvg5_birth  = array.new_int(0)    // bar_index when created
var bool[]  fvg5_inv    = array.new_bool(0)   // violated and flipped?
var int[]   fvg5_invbar = array.new_int(0)    // bar_index at inversion

// ─────────────────────────────────────────────────────────
//  TRADE LOG ARRAYS
// ─────────────────────────────────────────────────────────
var int[]    tlog_num    = array.new_int(0)
var string[] tlog_date   = array.new_string(0)
var int[]    tlog_ts     = array.new_int(0)
var string[] tlog_time   = array.new_string(0)
var string[] tlog_dir    = array.new_string(0)
var float[]  tlog_entry  = array.new_float(0)
var float[]  tlog_stop   = array.new_float(0)
var float[]  tlog_part   = array.new_float(0)
var float[]  tlog_target = array.new_float(0)
var float[]  tlog_ext    = array.new_float(0)
var string[] tlog_result = array.new_string(0)
var float[]  tlog_pnl    = array.new_float(0)

// Hourly arrays
var int[] active_hours = array.new_int(0)
var int[]   hr_count   = array.new_int(24, 0)
var int[]   hr_wins    = array.new_int(24, 0)
var int[]   hr_losses  = array.new_int(24, 0)
var int[]   hr_partial = array.new_int(24, 0)
var float[] hr_pnl     = array.new_float(24, 0.0)

// Trade UDT
// `entry` is the PLAN level that drives triggers; `fill` is the
// BOOKED entry price (bar close ± slippage when Execution Modeling is on).
// All P&L legs are computed from `fill`.
type Trade
    int    dir
    float  entry
    float  fill
    float  fill_notional
    int    qty_filled
    int    qty_rem
    float  lad_px2
    float  lad_px3
    int    lad_q2
    int    lad_q3
    bool   lad_hit2
    bool   lad_hit3
    float  pnl
    int    be_bar
    float  stop
    float  target
    float  part
    float  ext
    float  t3
    int    idx
    bool   partial_hit
    bool   target_hit
    bool   ext_hit
    int    qty
    int    qty_part
    int    qty_tgt
    int    qty_ext
    int    qty_run
    int    hr
    int    num

var array<Trade> abTrades      = array.new<Trade>()
var int   ab_trades   = 0
var int   ab_wins     = 0
var int   ab_losses   = 0
var int   ab_partials = 0
var float ab_pnl      = 0.0

var array<Trade> pendingTrades = array.new<Trade>()
var array<Trade> openTrades    = array.new<Trade>()

// Stats
var int   stat_total     = 0
var int   stat_wins      = 0
var int   stat_losses    = 0
var int   stat_partials  = 0
var float stat_total_pnl = 0.0
var float stat_daily_pnl = 0.0
var int   stat_streak    = 0
var int   sig_count      = 0

// Cooldown
var int last_bull_bar   = -999
var int last_bear_bar   = -999
var int last_signal_bar = -999

// Plan stop of the most recent signal, used by the entry webhook stopLoss
var float last_sig_stop = na

// ─────────────────────────────────────────────────────────
//  TRADING GATES
// ─────────────────────────────────────────────────────────
float daily_loss_usd = stat_daily_pnl * tbl_usd_per_pt
bool  dll_ok         = not dll_enabled or daily_loss_usd > -math.abs(dll_usd)
bool  tradingAllowed = inSession and dll_ok and hourOk

// ─────────────────────────────────────────────────────────
//  FILL BOOKING HELPERS
//  Alerts fire once-per-bar-close and TradersPost fills them as market
//  orders, so the realistic booked price is the trigger bar's CLOSE with
//  adverse slippage — not the exact level. Trigger detection still uses
//  the plan levels, so live behavior is unchanged.
// ─────────────────────────────────────────────────────────
// Round-turn cost of q contracts, expressed in POINTS so it can be netted
// directly against the point-denominated journal.
// Retire a zone: no longer eligible for nesting, stops extending, dims on chart.
f_retire(int _i) =>
    if array.get(fvg5_active, _i)
        array.set(fvg5_active, _i, false)
        array.set(fvg5_mitbar, _i, bar_index)
        if fvg5_show
            color _c = array.get(fvg5_dir, _i) == 1 ? fvg5_bull_col : fvg5_bear_col
            box.set_bgcolor(array.get(fvg5_box, _i), color.new(_c, 95))
            box.set_border_color(array.get(fvg5_box, _i), color.new(_c, 65))
    0

f_comm(int _q) =>
    comm_en and tbl_usd_per_pt > 0 ? _q * comm_rt / tbl_usd_per_pt : 0.0

f_fill_entry(int _dir, float _lvl) =>
    float _px = exec_book_close ? close : _lvl
    _dir == 1 ? _px + exec_slip_pts : _px - exec_slip_pts

f_fill_exit(int _dir, float _lvl) =>
    float _px = exec_book_close ? close : _lvl
    _dir == 1 ? _px - exec_slip_pts : _px + exec_slip_pts

// ─────────────────────────────────────────────────────────
//  PURGE ON SESSION OPEN
// ─────────────────────────────────────────────────────────
if newTradeDay
    if array.size(fvg5_box) > 0
        for i = 0 to array.size(fvg5_box) - 1
            box.delete(array.get(fvg5_box, i))
    if array.size(fvg5_llabel) > 0
        for i = 0 to array.size(fvg5_llabel) - 1
            label.delete(array.get(fvg5_llabel, i))
    if array.size(fvg5_rlabel) > 0
        for i = 0 to array.size(fvg5_rlabel) - 1
            label.delete(array.get(fvg5_rlabel, i))
    if array.size(fvg1_boxes) > 0
        for i = 0 to array.size(fvg1_boxes) - 1
            box.delete(array.get(fvg1_boxes, i))
    array.clear(fvg5_top)
    array.clear(fvg5_bot)
    array.clear(fvg5_dir)
    array.clear(fvg5_box)
    array.clear(fvg5_llabel)
    array.clear(fvg5_rlabel)
    array.clear(fvg1_boxes)
    array.clear(fvg5_active)
    array.clear(fvg5_mitbar)
    array.clear(fvg5_birth)
    array.clear(fvg5_inv)
    array.clear(fvg5_invbar)
    array.clear(openTrades)
    last_bull_bar   := -999
    last_bear_bar   := -999
    last_signal_bar := -999
    stat_daily_pnl  := 0.0

bool _shared_ok       = (bar_index - last_signal_bar) >= cooldown_bars
bool bull_cooldown_ok = _shared_ok and (bar_index - last_bull_bar) >= cooldown_bars
bool bear_cooldown_ok = _shared_ok and (bar_index - last_bear_bar) >= cooldown_bars

// ─────────────────────────────────────────────────────────
//  FORCE CLOSE HELPER
//  Legs are computed from tr.fill with adverse slippage on the close-out
// ─────────────────────────────────────────────────────────
forceCloseAll(float px) =>
    float pnlD = 0.0
    int   wD = 0, lD = 0, pD = 0
    int   stk = stat_streak
    if array.size(openTrades) > 0
        for i = 0 to array.size(openTrades) - 1
            Trade tr = array.get(openTrades, i)
            int   remn = tr.qty_rem
            tr.qty_rem := 0
            float xpx  = tr.dir == 1 ? px - exec_slip_pts : px + exec_slip_pts
            float leg  = tr.dir == 1 ? remn * (xpx - tr.fill) : remn * (tr.fill - xpx)
            array.set(tlog_pnl, tr.idx, array.get(tlog_pnl, tr.idx) + leg)
            array.set(hr_pnl,   tr.hr,  array.get(hr_pnl,   tr.hr)  + leg)
            pnlD += leg
            float net = array.get(tlog_pnl, tr.idx)
            if tr.target_hit or tr.ext_hit
                array.set(tlog_result, tr.idx, "✅ Win")
                wD  += 1
                stk  := stk < 0 ? 1 : stk + 1
                array.set(hr_wins, tr.hr, array.get(hr_wins, tr.hr) + 1)
            else if net >= 0
                array.set(tlog_result, tr.idx, "🔵 Partial")
                pD  += 1
                stk  := stk < 0 ? 1 : stk + 1
                array.set(hr_partial, tr.hr, array.get(hr_partial, tr.hr) + 1)
            else
                array.set(tlog_result, tr.idx, "❌ Loss")
                lD  += 1
                stk  := stk > 0 ? -1 : stk - 1
                array.set(hr_losses, tr.hr, array.get(hr_losses, tr.hr) + 1)
        array.clear(openTrades)
    [pnlD, wD, lD, pD, stk]

// ─────────────────────────────────────────────────────────
//  OUTCOME DETECTION
// ─────────────────────────────────────────────────────────
bool outcome_entry       = false  // a pending order just filled
bool outcome_emergency   = false  // per-trade max loss breached
bool outcome_partial     = false
bool outcome_target      = false  // main target T1 hit
bool outcome_ext_target  = false  // extended target T2 (contract 3) hit
bool outcome_t3          = false  // runner T3 (contract 4) hit — hard exit, fully closed
bool outcome_partial_win = false
bool outcome_add         = false  // a ladder leg just filled — send an add-to-position entry

// Actual contract counts for this bar exits (ladder-aware; equal to the planned
// input quantities when laddering is off)
int q_partial = 0
int q_target  = 0
int q_ext     = 0
int q_t3      = 0
int q_stop    = 0
int q_be      = 0
int q_emerg   = 0
int       q_add           = 0
var int   last_add_dir    = 0
var float last_add_stop   = na
var int   last_entry_qty  = 0
var int   last_entry_dir  = 0
var float last_entry_stop = na
bool outcome_be          = false
bool outcome_loss        = false

// ── Per-trade max loss emergency check ──────────────────
// open_qty is stage-aware; unrealized
// P&L is measured from the booked fill, and the emergency leg is ADDED to the
// trade's logged P&L instead of overwriting it (the old overwrite re-added the
// banked partial to Day/All stats — a double count).
if barstate.isconfirmed and per_trade_dll_en and per_trade_dll > 0 and array.size(openTrades) > 0
    for i = 0 to array.size(openTrades) - 1
        Trade tr = array.get(openTrades, i)
        int   open_qty   = tr.qty_rem
        float unreal_pts = tr.dir == 1 ? (close - tr.fill) : (tr.fill - close)
        float unreal_usd = unreal_pts * open_qty * tbl_usd_per_pt
        if unreal_usd < -math.abs(per_trade_dll)
            float xpx = f_fill_exit(tr.dir, close)
            float leg = tr.dir == 1 ? float(open_qty) * (xpx - tr.fill) : float(open_qty) * (tr.fill - xpx)
            array.set(tlog_result, tr.idx, "❌ Loss")
            array.set(tlog_pnl,    tr.idx, array.get(tlog_pnl, tr.idx) + leg)
            stat_total_pnl += leg
            stat_daily_pnl += leg
            stat_losses    += 1
            stat_streak     := stat_streak > 0 ? -1 : stat_streak - 1
            array.set(hr_losses, tr.hr, array.get(hr_losses, tr.hr) + 1)
            array.set(hr_pnl,    tr.hr, array.get(hr_pnl,    tr.hr) + leg)
            tr.qty_rem := 0
            q_emerg    := open_qty
            outcome_emergency := true
        if outcome_emergency
            array.clear(openTrades)
            break

// ── Pending-order fills ─────────────────────────────────────────────────────
// A pullback fill is a limit-style touch, so the fill is booked at the
// plan level (no bar-close remap).
if barstate.isconfirmed
    int pi = 0
    while pi < array.size(pendingTrades)
        Trade pt = array.get(pendingTrades, pi)
        bool fill = pt.dir == 1 ? low <= pt.entry : high >= pt.entry
        if fill
            if trade_mode == "Force close trade on new signal" and array.size(openTrades) > 0
                [fpd, fwd, fld, fpp, fstk] = forceCloseAll(close)
                stat_total_pnl += fpd
                stat_daily_pnl += fpd
                stat_wins      += fwd
                stat_losses    += fld
                stat_partials  += fpp
                stat_streak     := fstk
            pt.hr            := hour(time, tbl_tz)
            pt.fill          := pt.entry
            pt.fill_notional := pt.qty * pt.entry
            pt.qty_filled    := pt.qty
            pt.qty_rem       := pt.qty
            last_entry_qty   := pt.qty
            last_entry_dir   := pt.dir
            last_entry_stop  := pt.stop
            array.push(tlog_num,    pt.num)
            array.push(tlog_date,   str.format_time(time, "MM/dd", tbl_tz))
            array.push(tlog_ts,     time)
            array.push(tlog_time,   str.format_time(time, "HH:mm", tbl_tz))
            array.push(tlog_dir,    pt.dir == 1 ? "▲ Bull" : "▼ Bear")
            array.push(tlog_entry,  pt.fill)
            array.push(tlog_stop,   pt.stop)
            array.push(tlog_part,   pt.part)
            array.push(tlog_target, pt.target)
            array.push(tlog_ext,    pt.ext)
            array.push(tlog_result, "⏳ Open")
            array.push(tlog_pnl,    0.0)
            pt.idx := array.size(tlog_time) - 1
            stat_total += 1
            outcome_entry := true
            array.set(hr_count, pt.hr, array.get(hr_count, pt.hr) + 1)
            float _pcomm = f_comm(pt.qty)
            if _pcomm > 0
                array.set(tlog_pnl, pt.idx, array.get(tlog_pnl, pt.idx) - _pcomm)
                array.set(hr_pnl,   pt.hr,  array.get(hr_pnl, pt.hr) - _pcomm)
                stat_total_pnl -= _pcomm
                stat_daily_pnl -= _pcomm
            array.push(openTrades, pt)
            array.remove(pendingTrades, pi)
        else if invalidate_partial and (pt.dir == 1 ? high >= pt.part : low <= pt.part)
            array.remove(pendingTrades, pi)
        else
            pi += 1

int oti = 0
while barstate.isconfirmed and oti < array.size(openTrades)
    Trade tr = array.get(openTrades, oti)
    bool closed = false
    // ── Entry ladder: fill deeper legs while the trade is still pre-partial ──
    if lad_en and not tr.partial_hit and tr.qty_rem > 0
        if tr.dir == 1
            if not tr.lad_hit2 and tr.lad_q2 > 0 and low <= tr.lad_px2
                float apx = f_fill_entry(1, tr.lad_px2)
                tr.lad_hit2      := true
                tr.fill_notional := tr.fill_notional + tr.lad_q2 * apx
                tr.qty_filled    := tr.qty_filled + tr.lad_q2
                tr.qty_rem       := tr.qty_rem + tr.lad_q2
                tr.fill          := tr.fill_notional / tr.qty_filled
                q_add            := q_add + tr.lad_q2
                float acomm = f_comm(tr.lad_q2)
                if acomm > 0
                    array.set(tlog_pnl, tr.idx, array.get(tlog_pnl, tr.idx) - acomm)
                    array.set(hr_pnl,   tr.hr,  array.get(hr_pnl, tr.hr) - acomm)
                    stat_total_pnl -= acomm
                    stat_daily_pnl -= acomm
                last_add_dir     := 1
                last_add_stop    := tr.stop
                outcome_add      := true
            if not tr.lad_hit3 and tr.lad_q3 > 0 and low <= tr.lad_px3
                float apx = f_fill_entry(1, tr.lad_px3)
                tr.lad_hit3      := true
                tr.fill_notional := tr.fill_notional + tr.lad_q3 * apx
                tr.qty_filled    := tr.qty_filled + tr.lad_q3
                tr.qty_rem       := tr.qty_rem + tr.lad_q3
                tr.fill          := tr.fill_notional / tr.qty_filled
                q_add            := q_add + tr.lad_q3
                float acomm = f_comm(tr.lad_q3)
                if acomm > 0
                    array.set(tlog_pnl, tr.idx, array.get(tlog_pnl, tr.idx) - acomm)
                    array.set(hr_pnl,   tr.hr,  array.get(hr_pnl, tr.hr) - acomm)
                    stat_total_pnl -= acomm
                    stat_daily_pnl -= acomm
                last_add_dir     := 1
                last_add_stop    := tr.stop
                outcome_add      := true
        else if tr.dir == -1
            if not tr.lad_hit2 and tr.lad_q2 > 0 and high >= tr.lad_px2
                float apx = f_fill_entry(-1, tr.lad_px2)
                tr.lad_hit2      := true
                tr.fill_notional := tr.fill_notional + tr.lad_q2 * apx
                tr.qty_filled    := tr.qty_filled + tr.lad_q2
                tr.qty_rem       := tr.qty_rem + tr.lad_q2
                tr.fill          := tr.fill_notional / tr.qty_filled
                q_add            := q_add + tr.lad_q2
                float acomm = f_comm(tr.lad_q2)
                if acomm > 0
                    array.set(tlog_pnl, tr.idx, array.get(tlog_pnl, tr.idx) - acomm)
                    array.set(hr_pnl,   tr.hr,  array.get(hr_pnl, tr.hr) - acomm)
                    stat_total_pnl -= acomm
                    stat_daily_pnl -= acomm
                last_add_dir     := -1
                last_add_stop    := tr.stop
                outcome_add      := true
            if not tr.lad_hit3 and tr.lad_q3 > 0 and high >= tr.lad_px3
                float apx = f_fill_entry(-1, tr.lad_px3)
                tr.lad_hit3      := true
                tr.fill_notional := tr.fill_notional + tr.lad_q3 * apx
                tr.qty_filled    := tr.qty_filled + tr.lad_q3
                tr.qty_rem       := tr.qty_rem + tr.lad_q3
                tr.fill          := tr.fill_notional / tr.qty_filled
                q_add            := q_add + tr.lad_q3
                float acomm = f_comm(tr.lad_q3)
                if acomm > 0
                    array.set(tlog_pnl, tr.idx, array.get(tlog_pnl, tr.idx) - acomm)
                    array.set(hr_pnl,   tr.hr,  array.get(hr_pnl, tr.hr) - acomm)
                    stat_total_pnl -= acomm
                    stat_daily_pnl -= acomm
                last_add_dir     := -1
                last_add_stop    := tr.stop
                outcome_add      := true
    if tr.dir == 1
        if not tr.partial_hit
            if low <= tr.stop
                int   qsl  = tr.qty_rem
                float lleg = qsl * (f_fill_exit(1, tr.stop) - tr.fill)
                tr.qty_rem := 0
                q_stop     := qsl
                array.set(tlog_result, tr.idx, "❌ Loss")
                array.set(tlog_pnl,    tr.idx, lleg)
                stat_total_pnl += lleg
                stat_daily_pnl += lleg
                stat_losses    += 1
                stat_streak     := stat_streak > 0 ? -1 : stat_streak - 1
                closed          := true
                outcome_loss    := true
                array.set(hr_losses, tr.hr, array.get(hr_losses, tr.hr) + 1)
                array.set(hr_pnl,    tr.hr, array.get(hr_pnl,    tr.hr) + lleg)
            else if high >= tr.part
                int   qp   = math.min(tr.qty_part, tr.qty_rem)
                float pleg = qp * (f_fill_exit(1, tr.part) - tr.fill)
                tr.qty_rem := tr.qty_rem - qp
                q_partial  := qp
                tr.partial_hit := true
                if pos_be_at_partial
                    tr.stop   := tr.fill
                    tr.be_bar := bar_index
                array.set(tlog_pnl, tr.idx, array.get(tlog_pnl, tr.idx) + pleg)
                stat_total_pnl += pleg
                stat_daily_pnl += pleg
                array.set(hr_pnl, tr.hr, array.get(hr_pnl, tr.hr) + pleg)
                if tr.qty_rem == 0
                    array.set(tlog_result, tr.idx, "🔵 Partial")
                    stat_partials       += 1
                    stat_streak          := stat_streak < 0 ? 1 : stat_streak + 1
                    closed               := true
                    outcome_partial_win  := true
                    array.set(hr_partial, tr.hr, array.get(hr_partial, tr.hr) + 1)
                else
                    array.set(tlog_result, tr.idx, "⏳ Partial")
                    outcome_partial := true
            else if high >= tr.target
                int   qw   = tr.qty_rem
                float wleg = qw * (f_fill_exit(1, tr.target) - tr.fill)
                tr.qty_rem := 0
                q_target   := qw
                array.set(tlog_result, tr.idx, "✅ Win")
                array.set(tlog_pnl,    tr.idx, wleg)
                stat_total_pnl += wleg
                stat_daily_pnl += wleg
                stat_wins      += 1
                stat_streak     := stat_streak < 0 ? 1 : stat_streak + 1
                closed          := true
                outcome_target  := true
                array.set(hr_wins, tr.hr, array.get(hr_wins, tr.hr) + 1)
                array.set(hr_pnl,  tr.hr, array.get(hr_pnl,  tr.hr) + wleg)
        // ── Level 2: partial hit, waiting for main target ──
        if not closed and tr.partial_hit and not tr.target_hit
            if high >= tr.target
                int   qt   = math.min(tr.qty_tgt, tr.qty_rem)
                float tleg = qt * (f_fill_exit(1, tr.target) - tr.fill)
                tr.qty_rem := tr.qty_rem - qt
                q_target   := qt
                tr.target_hit := true
                array.set(tlog_pnl, tr.idx, array.get(tlog_pnl, tr.idx) + tleg)
                stat_total_pnl += tleg
                stat_daily_pnl += tleg
                array.set(hr_pnl, tr.hr, array.get(hr_pnl, tr.hr) + tleg)
                if tr.qty_rem == 0
                    array.set(tlog_result, tr.idx, "✅ Win")
                    stat_wins      += 1
                    stat_streak     := stat_streak < 0 ? 1 : stat_streak + 1
                    closed          := true
                    outcome_target  := true
                    array.set(hr_wins, tr.hr, array.get(hr_wins, tr.hr) + 1)
                else
                    array.set(tlog_result, tr.idx, "⏳ Win")
                    outcome_target  := true
            else if bar_index > tr.be_bar and low <= tr.stop
                int   rem  = tr.qty_rem
                float sleg = rem * (f_fill_exit(1, tr.stop) - tr.fill)
                tr.qty_rem := 0
                q_be       := rem
                q_stop     := rem
                array.set(tlog_pnl, tr.idx, array.get(tlog_pnl, tr.idx) + sleg)
                stat_total_pnl += sleg
                stat_daily_pnl += sleg
                array.set(hr_pnl, tr.hr, array.get(hr_pnl, tr.hr) + sleg)
                closed := true
                if array.get(tlog_pnl, tr.idx) >= 0
                    array.set(tlog_result, tr.idx, "🔵 Partial")
                    stat_partials  += 1
                    stat_streak     := stat_streak < 0 ? 1 : stat_streak + 1
                    outcome_be      := true
                    array.set(hr_partial, tr.hr, array.get(hr_partial, tr.hr) + 1)
                else
                    array.set(tlog_result, tr.idx, "❌ Loss")
                    stat_losses    += 1
                    stat_streak     := stat_streak > 0 ? -1 : stat_streak - 1
                    outcome_loss    := true
                    array.set(hr_losses, tr.hr, array.get(hr_losses, tr.hr) + 1)
        // ── Level 3: target hit, waiting for extended target T2 ──
        if not closed and tr.target_hit and not tr.ext_hit
            if high >= tr.ext
                int   qx   = math.min(tr.qty_ext, tr.qty_rem)
                float xleg = qx * (f_fill_exit(1, tr.ext) - tr.fill)
                tr.qty_rem := tr.qty_rem - qx
                q_ext      := qx
                tr.ext_hit := true
                array.set(tlog_pnl, tr.idx, array.get(tlog_pnl, tr.idx) + xleg)
                stat_total_pnl += xleg
                stat_daily_pnl += xleg
                array.set(hr_pnl, tr.hr, array.get(hr_pnl, tr.hr) + xleg)
                if tr.qty_rem == 0
                    array.set(tlog_result, tr.idx, "✅ Win")
                    stat_wins      += 1
                    stat_streak     := stat_streak < 0 ? 1 : stat_streak + 1
                    closed          := true
                    outcome_ext_target := true
                    array.set(hr_wins, tr.hr, array.get(hr_wins, tr.hr) + 1)
                else
                    array.set(tlog_result, tr.idx, "⏳ Win")
                    outcome_ext_target := true
            else if bar_index > tr.be_bar and low <= tr.stop
                int   rem  = tr.qty_rem
                float sleg = rem * (f_fill_exit(1, tr.stop) - tr.fill)
                tr.qty_rem := 0
                q_ext      := rem
                array.set(tlog_pnl, tr.idx, array.get(tlog_pnl, tr.idx) + sleg)
                stat_total_pnl += sleg
                stat_daily_pnl += sleg
                array.set(hr_pnl, tr.hr, array.get(hr_pnl, tr.hr) + sleg)
                closed := true
                array.set(tlog_result, tr.idx, "✅ Win")
                stat_wins      += 1
                stat_streak     := stat_streak < 0 ? 1 : stat_streak + 1
                outcome_ext_target := true
                array.set(hr_wins, tr.hr, array.get(hr_wins, tr.hr) + 1)
        // ── Level 4: ext hit, runner riding to T3 (rr_t3_pts) ──
        if not closed and tr.ext_hit
            if high >= tr.t3
                int   q3   = math.min(tr.qty_run, tr.qty_rem)
                float t3leg = q3 * (f_fill_exit(1, tr.t3) - tr.fill)
                tr.qty_rem := tr.qty_rem - q3
                q_t3       := q3
                array.set(tlog_result, tr.idx, "✅ Win")
                array.set(tlog_pnl,    tr.idx, array.get(tlog_pnl, tr.idx) + t3leg)
                stat_total_pnl += t3leg
                stat_daily_pnl += t3leg
                stat_wins      += 1
                stat_streak     := stat_streak < 0 ? 1 : stat_streak + 1
                closed          := true
                outcome_t3      := true
                array.set(hr_wins, tr.hr, array.get(hr_wins, tr.hr) + 1)
                array.set(hr_pnl,  tr.hr, array.get(hr_pnl,  tr.hr) + t3leg)
            else if bar_index > tr.be_bar and low <= tr.stop
                int   q3s  = tr.qty_rem
                float t3leg = q3s * (f_fill_exit(1, tr.stop) - tr.fill)
                tr.qty_rem := 0
                q_t3       := q3s
                array.set(tlog_pnl, tr.idx, array.get(tlog_pnl, tr.idx) + t3leg)
                stat_total_pnl += t3leg
                stat_daily_pnl += t3leg
                array.set(hr_pnl, tr.hr, array.get(hr_pnl, tr.hr) + t3leg)
                array.set(tlog_result, tr.idx, "✅ Win")
                stat_wins      += 1
                stat_streak     := stat_streak < 0 ? 1 : stat_streak + 1
                closed          := true
                outcome_t3      := true
                array.set(hr_wins, tr.hr, array.get(hr_wins, tr.hr) + 1)
    else if tr.dir == -1
        if not tr.partial_hit
            if high >= tr.stop
                int   qsl  = tr.qty_rem
                float lleg = qsl * (tr.fill - f_fill_exit(-1, tr.stop))
                tr.qty_rem := 0
                q_stop     := qsl
                array.set(tlog_result, tr.idx, "❌ Loss")
                array.set(tlog_pnl,    tr.idx, lleg)
                stat_total_pnl += lleg
                stat_daily_pnl += lleg
                stat_losses    += 1
                stat_streak     := stat_streak > 0 ? -1 : stat_streak - 1
                closed          := true
                outcome_loss    := true
                array.set(hr_losses, tr.hr, array.get(hr_losses, tr.hr) + 1)
                array.set(hr_pnl,    tr.hr, array.get(hr_pnl,    tr.hr) + lleg)
            else if low <= tr.part
                int   qp   = math.min(tr.qty_part, tr.qty_rem)
                float pleg = qp * (tr.fill - f_fill_exit(-1, tr.part))
                tr.qty_rem := tr.qty_rem - qp
                q_partial  := qp
                tr.partial_hit := true
                if pos_be_at_partial
                    tr.stop   := tr.fill
                    tr.be_bar := bar_index
                array.set(tlog_pnl, tr.idx, array.get(tlog_pnl, tr.idx) + pleg)
                stat_total_pnl += pleg
                stat_daily_pnl += pleg
                array.set(hr_pnl, tr.hr, array.get(hr_pnl, tr.hr) + pleg)
                if tr.qty_rem == 0
                    array.set(tlog_result, tr.idx, "🔵 Partial")
                    stat_partials       += 1
                    stat_streak          := stat_streak < 0 ? 1 : stat_streak + 1
                    closed               := true
                    outcome_partial_win  := true
                    array.set(hr_partial, tr.hr, array.get(hr_partial, tr.hr) + 1)
                else
                    array.set(tlog_result, tr.idx, "⏳ Partial")
                    outcome_partial := true
            else if low <= tr.target
                int   qw   = tr.qty_rem
                float wleg = qw * (tr.fill - f_fill_exit(-1, tr.target))
                tr.qty_rem := 0
                q_target   := qw
                array.set(tlog_result, tr.idx, "✅ Win")
                array.set(tlog_pnl,    tr.idx, wleg)
                stat_total_pnl += wleg
                stat_daily_pnl += wleg
                stat_wins      += 1
                stat_streak     := stat_streak < 0 ? 1 : stat_streak + 1
                closed          := true
                outcome_target  := true
                array.set(hr_wins, tr.hr, array.get(hr_wins, tr.hr) + 1)
                array.set(hr_pnl,  tr.hr, array.get(hr_pnl,  tr.hr) + wleg)
        // ── Level 2: partial hit, waiting for main target ──
        if not closed and tr.partial_hit and not tr.target_hit
            if low <= tr.target
                int   qt   = math.min(tr.qty_tgt, tr.qty_rem)
                float tleg = qt * (tr.fill - f_fill_exit(-1, tr.target))
                tr.qty_rem := tr.qty_rem - qt
                q_target   := qt
                tr.target_hit := true
                array.set(tlog_pnl, tr.idx, array.get(tlog_pnl, tr.idx) + tleg)
                stat_total_pnl += tleg
                stat_daily_pnl += tleg
                array.set(hr_pnl, tr.hr, array.get(hr_pnl, tr.hr) + tleg)
                if tr.qty_rem == 0
                    array.set(tlog_result, tr.idx, "✅ Win")
                    stat_wins      += 1
                    stat_streak     := stat_streak < 0 ? 1 : stat_streak + 1
                    closed          := true
                    outcome_target  := true
                    array.set(hr_wins, tr.hr, array.get(hr_wins, tr.hr) + 1)
                else
                    array.set(tlog_result, tr.idx, "⏳ Win")
                    outcome_target  := true
            else if bar_index > tr.be_bar and high >= tr.stop
                int   rem  = tr.qty_rem
                float sleg = rem * (tr.fill - f_fill_exit(-1, tr.stop))
                tr.qty_rem := 0
                q_be       := rem
                q_stop     := rem
                array.set(tlog_pnl, tr.idx, array.get(tlog_pnl, tr.idx) + sleg)
                stat_total_pnl += sleg
                stat_daily_pnl += sleg
                array.set(hr_pnl, tr.hr, array.get(hr_pnl, tr.hr) + sleg)
                closed := true
                if array.get(tlog_pnl, tr.idx) >= 0
                    array.set(tlog_result, tr.idx, "🔵 Partial")
                    stat_partials  += 1
                    stat_streak     := stat_streak < 0 ? 1 : stat_streak + 1
                    outcome_be      := true
                    array.set(hr_partial, tr.hr, array.get(hr_partial, tr.hr) + 1)
                else
                    array.set(tlog_result, tr.idx, "❌ Loss")
                    stat_losses    += 1
                    stat_streak     := stat_streak > 0 ? -1 : stat_streak - 1
                    outcome_loss    := true
                    array.set(hr_losses, tr.hr, array.get(hr_losses, tr.hr) + 1)
        // ── Level 3: target hit, waiting for extended target T2 ──
        if not closed and tr.target_hit and not tr.ext_hit
            if low <= tr.ext
                int   qx   = math.min(tr.qty_ext, tr.qty_rem)
                float xleg = qx * (tr.fill - f_fill_exit(-1, tr.ext))
                tr.qty_rem := tr.qty_rem - qx
                q_ext      := qx
                tr.ext_hit := true
                array.set(tlog_pnl, tr.idx, array.get(tlog_pnl, tr.idx) + xleg)
                stat_total_pnl += xleg
                stat_daily_pnl += xleg
                array.set(hr_pnl, tr.hr, array.get(hr_pnl, tr.hr) + xleg)
                if tr.qty_rem == 0
                    array.set(tlog_result, tr.idx, "✅ Win")
                    stat_wins      += 1
                    stat_streak     := stat_streak < 0 ? 1 : stat_streak + 1
                    closed          := true
                    outcome_ext_target := true
                    array.set(hr_wins, tr.hr, array.get(hr_wins, tr.hr) + 1)
                else
                    array.set(tlog_result, tr.idx, "⏳ Win")
                    outcome_ext_target := true
            else if bar_index > tr.be_bar and high >= tr.stop
                int   rem  = tr.qty_rem
                float sleg = rem * (tr.fill - f_fill_exit(-1, tr.stop))
                tr.qty_rem := 0
                q_ext      := rem
                array.set(tlog_pnl, tr.idx, array.get(tlog_pnl, tr.idx) + sleg)
                stat_total_pnl += sleg
                stat_daily_pnl += sleg
                array.set(hr_pnl, tr.hr, array.get(hr_pnl, tr.hr) + sleg)
                closed := true
                array.set(tlog_result, tr.idx, "✅ Win")
                stat_wins      += 1
                stat_streak     := stat_streak < 0 ? 1 : stat_streak + 1
                outcome_ext_target := true
                array.set(hr_wins, tr.hr, array.get(hr_wins, tr.hr) + 1)
        // ── Level 4: ext hit, runner riding to T3 (rr_t3_pts) ──
        if not closed and tr.ext_hit
            if low <= tr.t3
                int   q3   = math.min(tr.qty_run, tr.qty_rem)
                float t3leg = q3 * (tr.fill - f_fill_exit(-1, tr.t3))
                tr.qty_rem := tr.qty_rem - q3
                q_t3       := q3
                array.set(tlog_result, tr.idx, "✅ Win")
                array.set(tlog_pnl,    tr.idx, array.get(tlog_pnl, tr.idx) + t3leg)
                stat_total_pnl += t3leg
                stat_daily_pnl += t3leg
                stat_wins      += 1
                stat_streak     := stat_streak < 0 ? 1 : stat_streak + 1
                closed          := true
                outcome_t3      := true
                array.set(hr_wins, tr.hr, array.get(hr_wins, tr.hr) + 1)
                array.set(hr_pnl,  tr.hr, array.get(hr_pnl,  tr.hr) + t3leg)
            else if bar_index > tr.be_bar and high >= tr.stop
                int   q3s  = tr.qty_rem
                float t3leg = q3s * (tr.fill - f_fill_exit(-1, tr.stop))
                tr.qty_rem := 0
                q_t3       := q3s
                array.set(tlog_pnl, tr.idx, array.get(tlog_pnl, tr.idx) + t3leg)
                stat_total_pnl += t3leg
                stat_daily_pnl += t3leg
                array.set(hr_pnl, tr.hr, array.get(hr_pnl, tr.hr) + t3leg)
                array.set(tlog_result, tr.idx, "✅ Win")
                stat_wins      += 1
                stat_streak     := stat_streak < 0 ? 1 : stat_streak + 1
                closed          := true
                outcome_t3      := true
                array.set(hr_wins, tr.hr, array.get(hr_wins, tr.hr) + 1)
    if closed
        array.remove(openTrades, oti)
    else
        oti += 1

// ─────────────────────────────────────────────────────────
//  A/B VARIANT LAB — shadow journal
//  Replays the same signals with a different partial distance and break-even
//  rule. Full size at leg 1 fill, no laddering, no alerts, no live-table writes.
// ─────────────────────────────────────────────────────────
int vi = 0
while ab_en and barstate.isconfirmed and vi < array.size(abTrades)
    Trade v = array.get(abTrades, vi)
    bool vclosed = false
    if v.dir == 1
        if not v.partial_hit
            if low <= v.stop
                float leg = v.qty_rem * (f_fill_exit(1, v.stop) - v.fill)
                v.pnl += leg
                v.qty_rem := 0
                ab_losses += 1
                vclosed := true
            else if high >= v.part
                int   q   = math.min(v.qty_part, v.qty_rem)
                float leg = q * (f_fill_exit(1, v.part) - v.fill)
                v.pnl += leg
                v.qty_rem := v.qty_rem - q
                v.partial_hit := true
                if ab_be
                    v.stop   := v.fill
                    v.be_bar := bar_index
                if v.qty_rem == 0
                    ab_partials += 1
                    vclosed := true
            else if high >= v.target
                float leg = v.qty_rem * (f_fill_exit(1, v.target) - v.fill)
                v.pnl += leg
                v.qty_rem := 0
                ab_wins += 1
                vclosed := true
        if not vclosed and v.partial_hit and not v.target_hit
            if high >= v.target
                int   q   = math.min(v.qty_tgt, v.qty_rem)
                float leg = q * (f_fill_exit(1, v.target) - v.fill)
                v.pnl += leg
                v.qty_rem := v.qty_rem - q
                v.target_hit := true
                if v.qty_rem == 0
                    ab_wins += 1
                    vclosed := true
            else if bar_index > v.be_bar and low <= v.stop
                float leg = v.qty_rem * (f_fill_exit(1, v.stop) - v.fill)
                v.pnl += leg
                v.qty_rem := 0
                vclosed := true
                if v.pnl >= 0
                    ab_partials += 1
                else
                    ab_losses += 1
        if not vclosed and v.target_hit and not v.ext_hit
            if high >= v.ext
                int   q   = math.min(v.qty_ext, v.qty_rem)
                float leg = q * (f_fill_exit(1, v.ext) - v.fill)
                v.pnl += leg
                v.qty_rem := v.qty_rem - q
                v.ext_hit := true
                if v.qty_rem == 0
                    ab_wins += 1
                    vclosed := true
            else if bar_index > v.be_bar and low <= v.stop
                float leg = v.qty_rem * (f_fill_exit(1, v.stop) - v.fill)
                v.pnl += leg
                v.qty_rem := 0
                ab_wins += 1
                vclosed := true
        if not vclosed and v.ext_hit
            if high >= v.t3
                float leg = v.qty_rem * (f_fill_exit(1, v.t3) - v.fill)
                v.pnl += leg
                v.qty_rem := 0
                ab_wins += 1
                vclosed := true
            else if bar_index > v.be_bar and low <= v.stop
                float leg = v.qty_rem * (f_fill_exit(1, v.stop) - v.fill)
                v.pnl += leg
                v.qty_rem := 0
                ab_wins += 1
                vclosed := true
    else if v.dir == -1
        if not v.partial_hit
            if high >= v.stop
                float leg = v.qty_rem * (v.fill - f_fill_exit(-1, v.stop))
                v.pnl += leg
                v.qty_rem := 0
                ab_losses += 1
                vclosed := true
            else if low <= v.part
                int   q   = math.min(v.qty_part, v.qty_rem)
                float leg = q * (v.fill - f_fill_exit(-1, v.part))
                v.pnl += leg
                v.qty_rem := v.qty_rem - q
                v.partial_hit := true
                if ab_be
                    v.stop   := v.fill
                    v.be_bar := bar_index
                if v.qty_rem == 0
                    ab_partials += 1
                    vclosed := true
            else if low <= v.target
                float leg = v.qty_rem * (v.fill - f_fill_exit(-1, v.target))
                v.pnl += leg
                v.qty_rem := 0
                ab_wins += 1
                vclosed := true
        if not vclosed and v.partial_hit and not v.target_hit
            if low <= v.target
                int   q   = math.min(v.qty_tgt, v.qty_rem)
                float leg = q * (v.fill - f_fill_exit(-1, v.target))
                v.pnl += leg
                v.qty_rem := v.qty_rem - q
                v.target_hit := true
                if v.qty_rem == 0
                    ab_wins += 1
                    vclosed := true
            else if bar_index > v.be_bar and high >= v.stop
                float leg = v.qty_rem * (v.fill - f_fill_exit(-1, v.stop))
                v.pnl += leg
                v.qty_rem := 0
                vclosed := true
                if v.pnl >= 0
                    ab_partials += 1
                else
                    ab_losses += 1
        if not vclosed and v.target_hit and not v.ext_hit
            if low <= v.ext
                int   q   = math.min(v.qty_ext, v.qty_rem)
                float leg = q * (v.fill - f_fill_exit(-1, v.ext))
                v.pnl += leg
                v.qty_rem := v.qty_rem - q
                v.ext_hit := true
                if v.qty_rem == 0
                    ab_wins += 1
                    vclosed := true
            else if bar_index > v.be_bar and high >= v.stop
                float leg = v.qty_rem * (v.fill - f_fill_exit(-1, v.stop))
                v.pnl += leg
                v.qty_rem := 0
                ab_wins += 1
                vclosed := true
        if not vclosed and v.ext_hit
            if low <= v.t3
                float leg = v.qty_rem * (v.fill - f_fill_exit(-1, v.t3))
                v.pnl += leg
                v.qty_rem := 0
                ab_wins += 1
                vclosed := true
            else if bar_index > v.be_bar and high >= v.stop
                float leg = v.qty_rem * (v.fill - f_fill_exit(-1, v.stop))
                v.pnl += leg
                v.qty_rem := 0
                ab_wins += 1
                vclosed := true
    if vclosed
        ab_pnl += v.pnl
        array.remove(abTrades, vi)
    else
        vi += 1

// ─────────────────────────────────────────────────────────
//  5-MIN BOUNDARY DETECTION
// ─────────────────────────────────────────────────────────
is_new_5m = timeframe.change("5")

var float running5High = na
var float running5Low  = na
var float h5_c0 = na,  var float l5_c0 = na
var float h5_c1 = na,  var float l5_c1 = na
var float h5_c2 = na,  var float l5_c2 = na

if is_new_5m
    h5_c2 := h5_c1
    l5_c2 := l5_c1
    h5_c1 := h5_c0
    l5_c1 := l5_c0
    h5_c0 := running5High
    l5_c0 := running5Low
    running5High := high
    running5Low  := low
else
    running5High := na(running5High) ? high : math.max(running5High, high)
    running5Low  := na(running5Low)  ? low  : math.min(running5Low,  low)

// ─────────────────────────────────────────────────────────
//  ADD 5-MIN FVG ZONE
//  FIX: bgcolor uses the input color directly (no color.new wrapper)
//  so the user's opacity setting in the color picker is respected.
// ─────────────────────────────────────────────────────────
f_add5(float ztop, float zbot, int zdir, string lbl, color bcol) =>
    array.push(fvg5_top, ztop)
    array.push(fvg5_bot, zbot)
    array.push(fvg5_dir, zdir)
    array.push(fvg5_active, true)
    array.push(fvg5_mitbar, -1)
    array.push(fvg5_birth, bar_index)
    array.push(fvg5_inv, false)
    array.push(fvg5_invbar, -1)
    float mid = (ztop + zbot) / 2
    if fvg5_show
        b = box.new(bar_index - 15, ztop, bar_index, zbot,
             border_color=color.new(bcol, 0),
             bgcolor=bcol,
             extend=extend.none, border_width=2,
             border_style=line.style_solid)
        array.push(fvg5_box, b)
        ll = label.new(bar_index - 15, mid, lbl,
             color=color.new(color.black, 100),
             textcolor=color.white,
             style=label.style_none,
             size=size.small,
             textalign=text.align_left)
        array.push(fvg5_llabel, ll)
        rl = label.new(bar_index, mid, lbl,
             color=color.new(color.black, 100),
             textcolor=color.white,
             style=label.style_none,
             size=size.small,
             textalign=text.align_right)
        array.push(fvg5_rlabel, rl)
    else
        array.push(fvg5_box,    box.new(0, 0, 1, 0))
        array.push(fvg5_llabel, label.new(0, 0, ""))
        array.push(fvg5_rlabel, label.new(0, 0, ""))

// ─────────────────────────────────────────────────────────
//  DETECT 5-MIN FVGS
// ─────────────────────────────────────────────────────────
if is_new_5m and inSession and not na(h5_c2)
    float gap5_bull = l5_c0 - h5_c2
    float min5_bull = fvg5_prev_bp ? h5_c2 * (fvg5_min_pts / 10000.0) : fvg5_min_pts
    if l5_c0 > h5_c2 and gap5_bull >= min5_bull
        f_add5(l5_c0, h5_c2, 1, "BISI", fvg5_bull_col)

    float gap5_bear = l5_c2 - h5_c0
    float min5_bear = fvg5_prev_bp ? h5_c0 * (fvg5_min_pts / 10000.0) : fvg5_min_pts
    if h5_c0 < l5_c2 and gap5_bear >= min5_bear
        f_add5(l5_c2, h5_c0, -1, "SIBI", fvg5_bear_col)

// Stretch boxes + update right labels
if inSession and fvg5_show and array.size(fvg5_box) > 0
    for i = 0 to array.size(fvg5_box) - 1
        if array.get(fvg5_active, i)
            box.set_right(array.get(fvg5_box, i), bar_index)
            label.set_x(array.get(fvg5_rlabel, i), bar_index)

// ─────────────────────────────────────────────────────────
//  MITIGATION
// ─────────────────────────────────────────────────────────
// ── Zone lifecycle: invalidate -> dim -> (hold) -> delete ─────────────────
if array.size(fvg5_top) > 0
    // 1. Invalidation and ageing
    for i = 0 to array.size(fvg5_top) - 1
        if array.get(fvg5_active, i)
            int   zd  = array.get(fvg5_dir, i)
            float zt  = array.get(fvg5_top, i)
            float zb  = array.get(fvg5_bot, i)
            float zce = (zt + zb) / 2
            bool  mit = false
            if fvg5_mitigated
                if fvg5_mit_mode == "Touch (any entry into gap)"
                    mit := zd == 1 ? low <= zt : high >= zb
                else if fvg5_mit_mode == "50% (consequent encroachment)"
                    mit := zd == 1 ? low <= zce : high >= zce
                else
                    mit := zd == 1 ? close < zb : close > zt
            bool aged = fvg5_max_age > 0 and (bar_index - array.get(fvg5_birth, i)) > fvg5_max_age
            bool inv_expired = array.get(fvg5_inv, i) and inv_max_age > 0 and (bar_index - array.get(fvg5_invbar, i)) > inv_max_age
            if mit and sig_mode != "FVG" and not array.get(fvg5_inv, i) and not aged
                // First violation: flip the zone and keep it alive as an IFVG
                array.set(fvg5_dir, i, -zd)
                array.set(fvg5_inv, i, true)
                array.set(fvg5_invbar, i, bar_index)
                if fvg5_show
                    color ic = -zd == 1 ? color.new(#7c4dff, 70) : color.new(#ff6d00, 70)
                    box.set_bgcolor(array.get(fvg5_box, i), ic)
                    box.set_border_color(array.get(fvg5_box, i), color.new(ic, 0))
            else if mit or aged or inv_expired
                f_retire(i)

    // 2. Cap active zones per direction, newest kept
    if fvg5_max_zones > 0
        int nb = 0
        int ns = 0
        for i = array.size(fvg5_top) - 1 to 0
            if array.get(fvg5_active, i)
                if array.get(fvg5_dir, i) == 1
                    nb += 1
                    if nb > fvg5_max_zones
                        f_retire(i)
                else
                    ns += 1
                    if ns > fvg5_max_zones
                        f_retire(i)

    // 3. Delete retired zones once the hold expires — never while a trade is open
    int di = 0
    while di < array.size(fvg5_top)
        bool gone = false
        if not array.get(fvg5_active, di) and array.size(openTrades) == 0
            if bar_index - array.get(fvg5_mitbar, di) >= fvg5_hold_bars
                array.remove(fvg5_top, di)
                array.remove(fvg5_bot, di)
                array.remove(fvg5_dir, di)
                array.remove(fvg5_active, di)
                array.remove(fvg5_mitbar, di)
                array.remove(fvg5_birth, di)
                array.remove(fvg5_inv, di)
                array.remove(fvg5_invbar, di)
                box.delete(array.remove(fvg5_box, di))
                label.delete(array.remove(fvg5_llabel, di))
                label.delete(array.remove(fvg5_rlabel, di))
                gone := true
        if not gone
            di += 1

// ─────────────────────────────────────────────────────────
//  1-MIN FVG + NESTED CHECK
// ─────────────────────────────────────────────────────────
bool bullNested = false
bool bearNested = false

if barstate.isconfirmed and tradingAllowed
    // ── Bullish ──────────────────────────────────────────
    float gap1_bull = low - high[2]
    float min1_bull = fvg1_min_pts
    if low > high[2] and gap1_bull >= min1_bull
        float top1 = low
        float bot1 = high[2]
        bool nested = false
        if array.size(fvg5_top) > 0
            for i = 0 to array.size(fvg5_top) - 1
                bool ok_src = sig_mode == "Both" or (sig_mode == "IFVG" ? array.get(fvg5_inv, i) : not array.get(fvg5_inv, i))
                if array.get(fvg5_dir, i) == 1 and array.get(fvg5_active, i) and ok_src
                    float prox = proximity_pts
                    if bot1 >= (array.get(fvg5_bot, i) - prox) and top1 <= (array.get(fvg5_top, i) + prox)
                        nested := true
                        break
        bool bull_blocked = trade_mode == "Block new trades until open trade closes" and (array.size(openTrades) + array.size(pendingTrades) > 0)
        if nested and bull_cooldown_ok and not bull_blocked
            if trade_mode == "Force close trade on new signal" and array.size(openTrades) > 0
                [fpd, fwd, fld, fpp, fstk] = forceCloseAll(close)
                stat_total_pnl += fpd
                stat_daily_pnl += fpd
                stat_wins      += fwd
                stat_losses    += fld
                stat_partials  += fpp
                stat_streak     := fstk
            sig_count        += 1
            bullNested        := true
            last_bull_bar     := bar_index
            last_signal_bar   := bar_index
            stat_total        += 1
            int   _bhr = hour(time, tbl_tz)
            float _be  = (anchor_mode == "Entry Fill" and fvg1_entry == "Immediate") ? close : bot1
            float _bs  = _be - rr_stop_pts
            float _bp  = _be + rr_partial_pts
            float _bt  = _be + rr_target_pts
            float _bx  = _be + rr_ext_pts
            float _b3  = use_t3_runner ? _be + rr_t3_pts : _bx
            // Booked fill for Immediate mode: market order at the signal bar close
            float _bfill = f_fill_entry(1, _be)
            last_sig_stop := _bs
            array.push(tlog_num,    sig_count)
            array.push(tlog_date,   str.format_time(time, "MM/dd", tbl_tz))
            array.push(tlog_ts,     time)
            array.push(tlog_time,   str.format_time(time, "HH:mm", tbl_tz))
            array.push(tlog_dir,    "▲ Bull")
            array.push(tlog_entry,  fvg1_entry == "Immediate" ? _bfill : _be)
            array.push(tlog_stop,   _bs)
            array.push(tlog_part,   _bp)
            array.push(tlog_target, _bt)
            array.push(tlog_ext,    _bx)
            array.push(tlog_result, "⏳ Open")
            array.push(tlog_pnl,    0.0)
            int _bqp = math.min(pos_qty_part, pos_qty)
            int _bqt = math.min(pos_qty_tgt,  pos_qty - _bqp)
            int _bqx = math.min(pos_qty_ext,  pos_qty - _bqp - _bqt)
            int _bqr = use_t3_runner ? math.max(pos_qty - _bqp - _bqt - _bqx, 0) : 0
            float _bce = (top1 + bot1) / 2
            int   _bq1 = lad_en ? math.min(lad_qty1, pos_qty) : pos_qty
            if ab_en
                array.push(abTrades, Trade.new(dir=1, entry=_be, fill=_bfill, fill_notional=pos_qty*_bfill, qty_filled=pos_qty, qty_rem=pos_qty, lad_px2=na, lad_px3=na, lad_q2=0, lad_q3=0, lad_hit2=false, lad_hit3=false, pnl=-f_comm(pos_qty), be_bar=-1, stop=_bs, target=_bt, part=_be + ab_partial_pts, ext=_bx, t3=_b3, idx=-1, partial_hit=false, target_hit=false, ext_hit=false, qty=pos_qty, qty_part=_bqp, qty_tgt=_bqt, qty_ext=_bqx, qty_run=_bqr, hr=_bhr, num=sig_count))
                ab_trades += 1
            if fvg1_entry == "Immediate"
                array.push(openTrades, Trade.new(dir=1, entry=_be, fill=_bfill, fill_notional=_bq1*_bfill, qty_filled=_bq1, qty_rem=_bq1, lad_px2=_bce, lad_px3=bot1, lad_q2=lad_en ? lad_qty2 : 0, lad_q3=lad_en ? lad_qty3 : 0, lad_hit2=false, lad_hit3=false, pnl=0.0, be_bar=-1, stop=_bs, target=_bt, part=_bp, ext=_bx, t3=_b3, idx=array.size(tlog_time)-1, partial_hit=false, target_hit=false, ext_hit=false, qty=pos_qty, qty_part=_bqp, qty_tgt=_bqt, qty_ext=_bqx, qty_run=_bqr, hr=_bhr, num=sig_count))
                array.set(hr_count, _bhr, array.get(hr_count, _bhr) + 1)
                float _bcomm = f_comm(_bq1)
                if _bcomm > 0
                    array.set(tlog_pnl, array.size(tlog_pnl) - 1, array.get(tlog_pnl, array.size(tlog_pnl) - 1) - _bcomm)
                    array.set(hr_pnl,   _bhr, array.get(hr_pnl, _bhr) - _bcomm)
                    stat_total_pnl -= _bcomm
                    stat_daily_pnl -= _bcomm
            else
                array.push(pendingTrades, Trade.new(dir=1, entry=_be, fill=_be, fill_notional=pos_qty*_be, qty_filled=pos_qty, qty_rem=pos_qty, lad_px2=na, lad_px3=na, lad_q2=0, lad_q3=0, lad_hit2=false, lad_hit3=false, pnl=0.0, be_bar=-1, stop=_bs, target=_bt, part=_bp, ext=_bx, t3=_b3, idx=-1, partial_hit=false, target_hit=false, ext_hit=false, qty=pos_qty, qty_part=_bqp, qty_tgt=_bqt, qty_ext=_bqx, qty_run=_bqr, hr=0, num=sig_count))
            if fvg1_show
                b1 = box.new(bar_index - 2, top1, bar_index + 15, bot1,
                     border_color=color.new(#00ff00, 0), bgcolor=fvg1_bull_col,
                     extend=extend.none, border_width=3, border_style=line.style_dashed)
                array.push(fvg1_boxes, b1)
            if rr_show
                int rs = bar_index + 1
                int re = bar_index + 16
                line.new(rs, _be, re, _be, color=rr_entry_col,   width=1, style=line.style_dashed)
                line.new(rs, _bs, re, _bs, color=rr_stop_col,    width=1, style=line.style_dashed)
                line.new(rs, _bp, re, _bp, color=rr_partial_col, width=1, style=line.style_dashed)
                line.new(rs, _bt, re, _bt, color=rr_target_col,  width=2, style=line.style_solid)
                line.new(rs, _bx, re, _bx, color=rr_ext_col,     width=2, style=line.style_solid)
                if use_t3_runner
                    line.new(rs, _b3, re, _b3, color=rr_t3_col, width=2, style=line.style_solid)
                box.new(rs, _be, re, _bs, border_color=color.new(#ff1744,70), bgcolor=color.new(#ff1744,88), border_width=1)
                box.new(rs, _bt, re, _be, border_color=color.new(#00e676,70), bgcolor=color.new(#00e676,88), border_width=1)
                box.new(rs, _bx, re, _bt, border_color=color.new(#ffeb3b,70), bgcolor=color.new(#ffeb3b,88), border_width=1)
                if use_t3_runner
                    box.new(rs, _b3, re, _bx, border_color=color.new(#e040fb,70), bgcolor=color.new(#e040fb,92), border_width=1)
                    label.new(re, _b3, "T3 +" + str.tostring(rr_t3_pts) + "pts @ " + str.tostring(math.round(_b3,2)), color=color.new(#e040fb,10), textcolor=color.white, style=label.style_label_left, size=rr_sz)
                label.new(re, _bx, "T2 +" + str.tostring(rr_ext_pts) + "pts @ " + str.tostring(math.round(_bx,2)), color=color.new(#ffeb3b,10), textcolor=color.black, style=label.style_label_left, size=rr_sz)
                label.new(re, _bt, "T1 +" + str.tostring(rr_target_pts) + "pts @ " + str.tostring(math.round(_bt,2)), color=color.new(#00e676,10), textcolor=color.white, style=label.style_label_left, size=rr_sz)
                label.new(re, _bp, "Partial / BE +" + str.tostring(rr_partial_pts) + "pts @ " + str.tostring(math.round(_bp,2)), color=color.new(#2196f3,10), textcolor=color.white, style=label.style_label_left, size=rr_sz)
                label.new(re, _bs, "S  -" + str.tostring(rr_stop_pts) + "pts @ " + str.tostring(math.round(_bs,2)), color=color.new(#ff1744,10), textcolor=color.white, style=label.style_label_left, size=rr_sz)
                label.new(re, _be, "#" + str.tostring(sig_count) + " E @ " + str.tostring(math.round(_be,2)), color=color.new(#ffeb3b,10), textcolor=color.black, style=label.style_label_left, size=rr_sz)

    // ── Bearish ──────────────────────────────────────────
    float gap1_bear = low[2] - high
    float min1_bear = fvg1_min_pts
    if high < low[2] and gap1_bear >= min1_bear
        float top1 = low[2]
        float bot1 = high
        bool nested = false
        if array.size(fvg5_top) > 0
            for i = 0 to array.size(fvg5_top) - 1
                bool ok_src = sig_mode == "Both" or (sig_mode == "IFVG" ? array.get(fvg5_inv, i) : not array.get(fvg5_inv, i))
                if array.get(fvg5_dir, i) == -1 and array.get(fvg5_active, i) and ok_src
                    float prox = proximity_pts
                    if bot1 >= (array.get(fvg5_bot, i) - prox) and top1 <= (array.get(fvg5_top, i) + prox)
                        nested := true
                        break
        bool bear_blocked = trade_mode == "Block new trades until open trade closes" and (array.size(openTrades) + array.size(pendingTrades) > 0)
        if nested and bear_cooldown_ok and not bear_blocked
            if trade_mode == "Force close trade on new signal" and array.size(openTrades) > 0
                [fpd, fwd, fld, fpp, fstk] = forceCloseAll(close)
                stat_total_pnl += fpd
                stat_daily_pnl += fpd
                stat_wins      += fwd
                stat_losses    += fld
                stat_partials  += fpp
                stat_streak     := fstk
            sig_count        += 1
            bearNested        := true
            last_bear_bar     := bar_index
            last_signal_bar   := bar_index
            stat_total        += 1
            int   _thr = hour(time, tbl_tz)
            float _te  = (anchor_mode == "Entry Fill" and fvg1_entry == "Immediate") ? close : top1
            float _ts  = _te + rr_stop_pts
            float _tp  = _te - rr_partial_pts
            float _tt  = _te - rr_target_pts
            float _tx  = _te - rr_ext_pts
            float _t3  = use_t3_runner ? _te - rr_t3_pts : _tx
            // Booked fill for Immediate mode: market order at the signal bar close
            float _tfill = f_fill_entry(-1, _te)
            last_sig_stop := _ts
            array.push(tlog_num,    sig_count)
            array.push(tlog_date,   str.format_time(time, "MM/dd", tbl_tz))
            array.push(tlog_ts,     time)
            array.push(tlog_time,   str.format_time(time, "HH:mm", tbl_tz))
            array.push(tlog_dir,    "▼ Bear")
            array.push(tlog_entry,  fvg1_entry == "Immediate" ? _tfill : _te)
            array.push(tlog_stop,   _ts)
            array.push(tlog_part,   _tp)
            array.push(tlog_target, _tt)
            array.push(tlog_ext,    _tx)
            array.push(tlog_result, "⏳ Open")
            array.push(tlog_pnl,    0.0)
            int _tqp = math.min(pos_qty_part, pos_qty)
            int _tqt = math.min(pos_qty_tgt,  pos_qty - _tqp)
            int _tqx = math.min(pos_qty_ext,  pos_qty - _tqp - _tqt)
            int _tqr = use_t3_runner ? math.max(pos_qty - _tqp - _tqt - _tqx, 0) : 0
            float _tce = (top1 + bot1) / 2
            int   _tq1 = lad_en ? math.min(lad_qty1, pos_qty) : pos_qty
            if ab_en
                array.push(abTrades, Trade.new(dir=-1, entry=_te, fill=_tfill, fill_notional=pos_qty*_tfill, qty_filled=pos_qty, qty_rem=pos_qty, lad_px2=na, lad_px3=na, lad_q2=0, lad_q3=0, lad_hit2=false, lad_hit3=false, pnl=-f_comm(pos_qty), be_bar=-1, stop=_ts, target=_tt, part=_te - ab_partial_pts, ext=_tx, t3=_t3, idx=-1, partial_hit=false, target_hit=false, ext_hit=false, qty=pos_qty, qty_part=_tqp, qty_tgt=_tqt, qty_ext=_tqx, qty_run=_tqr, hr=_thr, num=sig_count))
                ab_trades += 1
            if fvg1_entry == "Immediate"
                array.push(openTrades, Trade.new(dir=-1, entry=_te, fill=_tfill, fill_notional=_tq1*_tfill, qty_filled=_tq1, qty_rem=_tq1, lad_px2=_tce, lad_px3=top1, lad_q2=lad_en ? lad_qty2 : 0, lad_q3=lad_en ? lad_qty3 : 0, lad_hit2=false, lad_hit3=false, pnl=0.0, be_bar=-1, stop=_ts, target=_tt, part=_tp, ext=_tx, t3=_t3, idx=array.size(tlog_time)-1, partial_hit=false, target_hit=false, ext_hit=false, qty=pos_qty, qty_part=_tqp, qty_tgt=_tqt, qty_ext=_tqx, qty_run=_tqr, hr=_thr, num=sig_count))
                array.set(hr_count, _thr, array.get(hr_count, _thr) + 1)
                float _tcomm = f_comm(_tq1)
                if _tcomm > 0
                    array.set(tlog_pnl, array.size(tlog_pnl) - 1, array.get(tlog_pnl, array.size(tlog_pnl) - 1) - _tcomm)
                    array.set(hr_pnl,   _thr, array.get(hr_pnl, _thr) - _tcomm)
                    stat_total_pnl -= _tcomm
                    stat_daily_pnl -= _tcomm
            else
                array.push(pendingTrades, Trade.new(dir=-1, entry=_te, fill=_te, fill_notional=pos_qty*_te, qty_filled=pos_qty, qty_rem=pos_qty, lad_px2=na, lad_px3=na, lad_q2=0, lad_q3=0, lad_hit2=false, lad_hit3=false, pnl=0.0, be_bar=-1, stop=_ts, target=_tt, part=_tp, ext=_tx, t3=_t3, idx=-1, partial_hit=false, target_hit=false, ext_hit=false, qty=pos_qty, qty_part=_tqp, qty_tgt=_tqt, qty_ext=_tqx, qty_run=_tqr, hr=0, num=sig_count))
            if fvg1_show
                b1 = box.new(bar_index - 2, top1, bar_index + 15, bot1,
                     border_color=color.new(#ff0000, 0), bgcolor=fvg1_bear_col,
                     extend=extend.none, border_width=3, border_style=line.style_dashed)
                array.push(fvg1_boxes, b1)
            if rr_show
                int rs = bar_index + 1
                int re = bar_index + 16
                line.new(rs, _te, re, _te, color=rr_entry_col,   width=1, style=line.style_dashed)
                line.new(rs, _ts, re, _ts, color=rr_stop_col,    width=1, style=line.style_dashed)
                line.new(rs, _tp, re, _tp, color=rr_partial_col, width=1, style=line.style_dashed)
                line.new(rs, _tt, re, _tt, color=rr_target_col,  width=2, style=line.style_solid)
                line.new(rs, _tx, re, _tx, color=rr_ext_col,     width=2, style=line.style_solid)
                if use_t3_runner
                    line.new(rs, _t3, re, _t3, color=rr_t3_col, width=2, style=line.style_solid)
                box.new(rs, _ts, re, _te, border_color=color.new(#ff1744,70), bgcolor=color.new(#ff1744,88), border_width=1)
                box.new(rs, _te, re, _tt, border_color=color.new(#00e676,70), bgcolor=color.new(#00e676,88), border_width=1)
                box.new(rs, _tt, re, _tx, border_color=color.new(#ffeb3b,70), bgcolor=color.new(#ffeb3b,88), border_width=1)
                if use_t3_runner
                    box.new(rs, _tx, re, _t3, border_color=color.new(#e040fb,70), bgcolor=color.new(#e040fb,92), border_width=1)
                    label.new(re, _t3, "T3 -" + str.tostring(rr_t3_pts) + "pts @ " + str.tostring(math.round(_t3,2)), color=color.new(#e040fb,10), textcolor=color.white, style=label.style_label_left, size=rr_sz)
                label.new(re, _tx, "T2 -" + str.tostring(rr_ext_pts) + "pts @ " + str.tostring(math.round(_tx,2)), color=color.new(#ffeb3b,10), textcolor=color.black, style=label.style_label_left, size=rr_sz)
                label.new(re, _tt, "T1 -" + str.tostring(rr_target_pts) + "pts @ " + str.tostring(math.round(_tt,2)), color=color.new(#00e676,10), textcolor=color.white, style=label.style_label_left, size=rr_sz)
                label.new(re, _tp, "Partial / BE -" + str.tostring(rr_partial_pts) + "pts @ " + str.tostring(math.round(_tp,2)), color=color.new(#2196f3,10), textcolor=color.white, style=label.style_label_left, size=rr_sz)
                label.new(re, _ts, "S  +" + str.tostring(rr_stop_pts) + "pts @ " + str.tostring(math.round(_ts,2)), color=color.new(#ff1744,10), textcolor=color.white, style=label.style_label_left, size=rr_sz)
                label.new(re, _te, "#" + str.tostring(sig_count) + " E @ " + str.tostring(math.round(_te,2)), color=color.new(#ffeb3b,10), textcolor=color.black, style=label.style_label_left, size=rr_sz)

// ─────────────────────────────────────────────────────────
//  RENDER TRADE TRACKER TABLE
// ─────────────────────────────────────────────────────────
if tbl_show and barstate.islast
    int  all_rows  = array.size(tlog_time)
    string today_str = str.format_time(time, "MM/dd", tbl_tz)

    var int[] filtered = array.new_int(0)
    array.clear(filtered)
    if all_rows > 0
        for i = 0 to all_rows - 1
            if not tbl_today_only or array.get(tlog_date, i) == today_str
                array.push(filtered, i)

    int frows = array.size(filtered)
    if frows > 0
        int start = math.max(0, frows - tbl_max_rows)
        int disp  = frows - start

        int   f_full = 0, f_losses = 0, f_partials = 0
        float f_pnl  = 0.0
        int   f_streak = 0
        for k = 0 to frows - 1
            int    ki = array.get(filtered, k)
            string kr = array.get(tlog_result, ki)
            float  kp = array.get(tlog_pnl,    ki)
            if kr == "✅ Win"
                f_full   += 1
                f_pnl    += kp
                f_streak  := f_streak < 0 ? 1 : f_streak + 1
            else if kr == "🔵 Partial"
                f_partials += 1
                f_pnl      += kp
                f_streak    := f_streak < 0 ? 1 : f_streak + 1
            else if kr == "❌ Loss"
                f_losses += 1
                f_pnl    += kp
                f_streak  := f_streak > 0 ? -1 : f_streak - 1
            else if kr == "⏳ Partial" or kr == "⏳ Win"
                f_pnl    += kp

        int   f_wins    = f_full + f_partials

        // Best Day calculation
        var map<string, float> day_pnl_map = map.new<string, float>()
        var map<string, int>   day_win_map = map.new<string, int>()
        var map<string, int>   day_tot_map = map.new<string, int>()
        map.clear(day_pnl_map)
        map.clear(day_win_map)
        map.clear(day_tot_map)
        if all_rows > 0
            for k = 0 to all_rows - 1
                string kd = array.get(tlog_date,   k)
                string kr = array.get(tlog_result, k)
                float  kp = array.get(tlog_pnl,    k)
                float  cur_pnl = map.contains(day_pnl_map, kd) ? map.get(day_pnl_map, kd) : 0.0
                int    cur_win = map.contains(day_win_map, kd) ? map.get(day_win_map, kd) : 0
                int    cur_tot = map.contains(day_tot_map, kd) ? map.get(day_tot_map, kd) : 0
                map.put(day_pnl_map, kd, cur_pnl + kp)
                map.put(day_tot_map, kd, cur_tot + 1)
                if kr == "✅ Win" or kr == "🔵 Partial"
                    map.put(day_win_map, kd, cur_win + 1)
        string best_day_date = "N/A"
        float  best_day_pnl  = -999999.0
        string[] day_keys = map.keys(day_pnl_map)
        if array.size(day_keys) > 0
            for k = 0 to array.size(day_keys) - 1
                string dk = array.get(day_keys, k)
                float  dp = map.get(day_pnl_map, dk)
                if dp > best_day_pnl
                    best_day_pnl  := dp
                    best_day_date := dk
        int   best_day_wins = map.contains(day_win_map, best_day_date) ? map.get(day_win_map, best_day_date) : 0
        int   best_day_tot  = map.contains(day_tot_map, best_day_date) ? map.get(day_tot_map, best_day_date) : 0
        string best_day_str = best_day_date + " +" + str.tostring(math.round(best_day_pnl,1)) + "pts (" + str.tostring(best_day_wins) + "/" + str.tostring(best_day_tot) + "W)"
        int   f_settled = f_wins + f_losses
        float f_wr      = f_settled > 0 ? (f_wins / f_settled) * 100 : 0.0
        string streak_str = f_streak > 0 ? "🔥 " + str.tostring(f_streak) + "W" : f_streak < 0 ? "🧊 " + str.tostring(math.abs(f_streak)) + "L" : "-"

        color hbg    = th_hbg
        color row_bg = th_row_bg
        color sum_bg = th_sum_bg

        int s_full = 0, s_losses = 0, s_partials = 0
        float s_pnl = 0.0
        int s_streak = 0
        for k = start to frows - 1
            int    ki = array.get(filtered, k)
            string kr = array.get(tlog_result, ki)
            float  kp = array.get(tlog_pnl,    ki)
            if kr == "✅ Win"
                s_full   += 1
                s_pnl    += kp
                s_streak  := s_streak < 0 ? 1 : s_streak + 1
            else if kr == "🔵 Partial"
                s_partials += 1
                s_pnl      += kp
                s_streak    := s_streak < 0 ? 1 : s_streak + 1
            else if kr == "❌ Loss"
                s_losses += 1
                s_pnl    += kp
                s_streak  := s_streak > 0 ? -1 : s_streak - 1
            else if kr == "⏳ Partial" or kr == "⏳ Win"
                s_pnl    += kp
        int   s_wins    = s_full + s_partials
        int   s_settled = s_wins + s_losses
        float s_wr      = s_settled > 0 ? (s_wins / s_settled) * 100 : 0.0
        string s_streak_str = s_streak > 0 ? "🔥 " + str.tostring(s_streak) + "W" : s_streak < 0 ? "🧊 " + str.tostring(math.abs(s_streak)) + "L" : "-"

        int c_usd = 8
        int c_num = tbl_show_usd ? 9 : 8
        int ncols = tbl_show_usd ? 10 : 9

        table t = table.new(tbl_pos_conv, ncols, tbl_max_rows + 5,
             border_color=isDark ? color.new(color.gray, 50) : color.new(#9fa8da, 20),
             border_width=1,
             frame_color=isDark ? color.new(color.gray, 30) : color.new(#3949ab, 20),
             frame_width=1)

        table.cell(t, 0, 0, "Date",    text_color=th_text, bgcolor=hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 1, 0, "Time",    text_color=th_text, bgcolor=hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 2, 0, "Dir",     text_color=th_text, bgcolor=hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 3, 0, "Entry",   text_color=th_text, bgcolor=hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 4, 0, "Stop",    text_color=th_text, bgcolor=hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 5, 0, "Target",  text_color=th_text, bgcolor=hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 6, 0, "Result",  text_color=th_text, bgcolor=hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 7, 0, "P&L pts", text_color=th_text, bgcolor=hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
        if tbl_show_usd
            table.cell(t, c_usd, 0, "P&L $", text_color=th_text, bgcolor=hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, c_num, 0, "#",   text_color=th_text, bgcolor=hbg, text_size=tbl_sz_conv, text_halign=text.align_center)

        for i = 0 to disp - 1
            int    idx = array.get(filtered, start + i)
            int    row = i + 1
            string res = array.get(tlog_result, idx)
            float  pnl = array.get(tlog_pnl,    idx)
            string dir = array.get(tlog_dir,     idx)
            color  rc  = res == "✅ Win"     ? color.new(color.green, 20) : res == "❌ Loss" ? color.new(color.red, 20) : res == "🔵 Partial" ? color.new(color.blue, 20) : res == "⏳ Win" ? color.new(color.green, 55) : res == "⏳ Partial" ? color.new(color.blue, 55) : color.new(color.gray, 60)
            color  pc  = pnl > 0 ? color.new(color.green, 60) : pnl < 0 ? color.new(color.red, 60) : color.new(color.gray, 60)
            color  dc  = str.contains(dir, "Bull") ? color.new(color.teal, 20) : color.new(color.red, 20)
            table.cell(t, 0, row, array.get(tlog_date, idx),                                text_color=th_muted,  bgcolor=row_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(t, 1, row, array.get(tlog_time, idx),                                text_color=th_text,   bgcolor=row_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(t, 2, row, dir,                                                       text_color=color.white,  bgcolor=dc,     text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(t, 3, row, str.tostring(math.round(array.get(tlog_entry,  idx),2)),  text_color=isDark ? color.yellow : color.new(#e65100, 0), bgcolor=row_bg, text_size=tbl_sz_conv, text_halign=text.align_right)
            table.cell(t, 4, row, str.tostring(math.round(array.get(tlog_stop,   idx),2)),  text_color=color.red,    bgcolor=row_bg, text_size=tbl_sz_conv, text_halign=text.align_right)
            table.cell(t, 5, row, str.tostring(math.round(array.get(tlog_target, idx),2)),  text_color=color.green,  bgcolor=row_bg, text_size=tbl_sz_conv, text_halign=text.align_right)
            table.cell(t, 6, row, res,                                                       text_color=color.white,  bgcolor=rc,     text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(t, 7, row, (pnl >= 0 ? "+" : "") + str.tostring(math.round(pnl,1)), text_color=pnl >= 0 ? color.green : color.red, bgcolor=pc, text_size=tbl_sz_conv, text_halign=text.align_right)
            if tbl_show_usd
                float usd = pnl * tbl_usd_per_pt
                table.cell(t, c_usd, row, (usd >= 0 ? "+$" : "-$") + str.tostring(math.round(math.abs(usd))), text_color=usd >= 0 ? color.green : color.red, bgcolor=pc, text_size=tbl_sz_conv, text_halign=text.align_right)
            table.cell(t, c_num, row, str.tostring(array.get(tlog_num, idx)),               text_color=color.gray,   bgcolor=row_bg, text_size=tbl_sz_conv, text_halign=text.align_center)

        int   srow   = disp + 1
        color pnl_bg = f_pnl >= 0 ? color.new(#1b5e20, 0) : color.new(#b71c1c, 0)
        color day_bg = stat_daily_pnl >= 0 ? color.new(#1b5e20, 30) : color.new(#b71c1c, 30)
        string mode_lbl = tbl_today_only ? "TODAY" : "ALL"
        table.cell(t, 0, srow, mode_lbl,                                                                                   text_color=th_text, bgcolor=sum_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 1, srow, str.tostring(frows) + " trades",                                                            text_color=th_text, bgcolor=sum_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 2, srow, str.tostring(f_full) + "W " + str.tostring(f_losses) + "L " + str.tostring(f_partials) + "P", text_color=th_text, bgcolor=sum_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 3, srow, "WR: " + str.tostring(math.round(f_wr,1)) + "%",                                           text_color=th_text, bgcolor=sum_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 4, srow, "Streak: " + streak_str,                                                                    text_color=th_text, bgcolor=sum_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 5, srow, "Day: " + (stat_daily_pnl >= 0 ? "+" : "") + str.tostring(math.round(stat_daily_pnl,1)) + "pts", text_color=color.white, bgcolor=day_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 6, srow, "All: " + (stat_total_pnl >= 0 ? "+" : "") + str.tostring(math.round(stat_total_pnl,1)) + "pts", text_color=th_text, bgcolor=sum_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 7, srow, (f_pnl >= 0 ? "+" : "") + str.tostring(math.round(f_pnl,1)) + "pts",                      text_color=color.white, bgcolor=pnl_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
        if tbl_show_usd
            float f_usd = f_pnl * tbl_usd_per_pt
            table.cell(t, c_usd, srow, (f_usd >= 0 ? "+$" : "-$") + str.tostring(math.round(math.abs(f_usd))), text_color=color.white, bgcolor=pnl_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, c_num, srow, str.tostring(stat_total) + " total",                                                    text_color=th_muted, bgcolor=sum_bg, text_size=tbl_sz_conv, text_halign=text.align_center)

        if tbl_show_shown
            int   srow2    = disp + 2
            color s_pnl_bg = s_pnl >= 0 ? color.new(#1b5e20, 0) : color.new(#b71c1c, 0)
            color shown_bg = isDark ? color.new(#16213e, 0) : color.new(#dde1f8, 0)
            table.cell(t, 0, srow2, "SHOWN",                                                                               text_color=th_text, bgcolor=shown_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(t, 1, srow2, str.tostring(disp) + " trades",                                                        text_color=th_text, bgcolor=shown_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(t, 2, srow2, str.tostring(s_full) + "W " + str.tostring(s_losses) + "L " + str.tostring(s_partials) + "P", text_color=th_text, bgcolor=shown_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(t, 3, srow2, "WR: " + str.tostring(math.round(s_wr,1)) + "%",                                      text_color=th_text, bgcolor=shown_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(t, 4, srow2, "Streak: " + s_streak_str,                                                             text_color=th_text, bgcolor=shown_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(t, 5, srow2, "",                                                                                     text_color=th_text, bgcolor=shown_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(t, 6, srow2, "",                                                                                     text_color=th_text, bgcolor=shown_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(t, 7, srow2, (s_pnl >= 0 ? "+" : "") + str.tostring(math.round(s_pnl,1)) + "pts",                  text_color=color.white, bgcolor=s_pnl_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
            if tbl_show_usd
                float s_usd = s_pnl * tbl_usd_per_pt
                table.cell(t, c_usd, srow2, (s_usd >= 0 ? "+$" : "-$") + str.tostring(math.round(math.abs(s_usd))), text_color=color.white, bgcolor=s_pnl_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(t, c_num, srow2, str.tostring(disp) + " shown",                                                     text_color=th_muted, bgcolor=shown_bg, text_size=tbl_sz_conv, text_halign=text.align_center)

        // Best Day row
        int   brow   = tbl_show_shown ? disp + 3 : disp + 2
        color best_bg = color.new(#1b5e20, 0)  // always green regardless of theme
        table.cell(t, 0, brow, "BEST DAY",   text_color=color.white, bgcolor=best_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 1, brow, best_day_str, text_color=color.white, bgcolor=best_bg, text_size=tbl_sz_conv, text_halign=text.align_left)
        table.cell(t, 2, brow, "",           text_color=color.white, bgcolor=best_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 3, brow, "",           text_color=color.white, bgcolor=best_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 4, brow, "",           text_color=color.white, bgcolor=best_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 5, brow, "",           text_color=color.white, bgcolor=best_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(t, 6, brow, "",           text_color=color.white, bgcolor=best_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
        if tbl_show_usd
            float best_usd = best_day_pnl * tbl_usd_per_pt
            table.cell(t, c_usd, brow, "+$" + str.tostring(math.round(best_usd)), text_color=color.white, bgcolor=best_bg, text_size=tbl_sz_conv, text_halign=text.align_right)
        table.cell(t, c_num, brow, "", text_color=color.white, bgcolor=best_bg, text_size=tbl_sz_conv, text_halign=text.align_center)

// ─────────────────────────────────────────────────────────
//  RENDER HOURLY PERFORMANCE TABLE
// ─────────────────────────────────────────────────────────
if tbl_hourly and barstate.islast
    tbl_hourly_pos_conv = switch tbl_hourly_pos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.middle_left

    array.clear(active_hours)
    for h = 0 to 23
        if array.get(hr_count, h) > 0
            array.push(active_hours, h)

    int ah = array.size(active_hours)
    if ah > 0
        table ht = table.new(tbl_hourly_pos_conv, 7, ah + 2,
             border_color=isDark ? color.new(color.gray, 50) : color.new(#9fa8da, 20),
             border_width=1,
             frame_color=isDark ? color.new(color.gray, 30) : color.new(#3949ab, 20),
             frame_width=1)

        color hhbg = th_hbg
        string _tzlbl = str.contains(tbl_tz, "New_York") ? "ET" : str.contains(tbl_tz, "Chicago") ? "CT" : str.contains(tbl_tz, "Denver") ? "MT" : str.contains(tbl_tz, "Los_Angeles") ? "PT" : str.contains(tbl_tz, "London") ? "UK" : tbl_tz == "UTC" ? "UTC" : "local"
        table.cell(ht, 0, 0, "Hour (" + _tzlbl + ")",  text_color=th_text, bgcolor=hhbg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(ht, 1, 0, "Signals",    text_color=th_text, bgcolor=hhbg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(ht, 2, 0, "Wins",       text_color=th_text, bgcolor=hhbg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(ht, 3, 0, "Losses",     text_color=th_text, bgcolor=hhbg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(ht, 4, 0, "Win %",      text_color=th_text, bgcolor=hhbg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(ht, 5, 0, "P&L pts",    text_color=th_text, bgcolor=hhbg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(ht, 6, 0, "Rating",     text_color=th_text, bgcolor=hhbg, text_size=tbl_sz_conv, text_halign=text.align_center)

        for i = 0 to ah - 1
            int   h    = array.get(active_hours, i)
            int   row  = i + 1
            int   ht_  = array.get(hr_count,   h)
            int   hw   = array.get(hr_wins,    h) + array.get(hr_partial, h)
            int   hl   = array.get(hr_losses,  h)
            float hpnl = array.get(hr_pnl,    h)
            int   settled = hw + hl
            float wr   = settled > 0 ? (hw / settled) * 100 : 0.0
            bool is_power     = (h >= 8  and h <= 9)
            bool is_afternoon = (h >= 13 and h <= 14)
            bool is_evening   = (h >= 21 and h <= 22)
            bool is_recommended = (is_power or is_afternoon or is_evening) and hpnl > 0
            bool is_strong    = hpnl >= 300 and wr >= 30
            bool is_weak      = wr < 15 or (hpnl > 0 and hpnl < 150 and ht_ >= 10)
            string rating = is_strong and is_recommended ? "** USE **" : is_recommended ? "* Use *" : is_strong ? "* Use *" : is_weak ? "X Cut X" : "! Caution"
            color  rbg = rating == "** USE **" ? color.new(#1b5e20, 0) : rating == "* Use *" ? color.new(#1b5e20, 30) : rating == "X Cut X" ? color.new(#b71c1c, 20) : color.new(color.orange, 30)
            color  pbg = hpnl > 0 ? color.new(color.green, 60) : color.new(color.red, 60)
            int    h12  = h == 0 ? 12 : h > 12 ? h - 12 : h
            string ampm = h < 12 ? "AM" : "PM"
            string hlbl = str.tostring(h12) + ":00 " + ampm
            color  hbg2 = th_hourly
            table.cell(ht, 0, row, hlbl,                                                               text_color=th_text,  bgcolor=hbg2, text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(ht, 1, row, str.tostring(ht_),                                                 text_color=th_text,  bgcolor=hbg2, text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(ht, 2, row, str.tostring(hw),                                                  text_color=color.green,  bgcolor=hbg2, text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(ht, 3, row, str.tostring(hl),                                                  text_color=color.red,    bgcolor=hbg2, text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(ht, 4, row, str.tostring(math.round(wr, 1)) + "%",                             text_color=wr >= 50 ? color.green : color.red, bgcolor=hbg2, text_size=tbl_sz_conv, text_halign=text.align_center)
            table.cell(ht, 5, row, (hpnl >= 0 ? "+" : "") + str.tostring(math.round(hpnl, 1)),       text_color=hpnl >= 0 ? color.green : color.red, bgcolor=pbg, text_size=tbl_sz_conv, text_halign=text.align_right)
            table.cell(ht, 6, row, rating,                                                             text_color=th_text,  bgcolor=rbg,  text_size=tbl_sz_conv, text_halign=text.align_center)

// ─────────────────────────────────────────────────────────
//  RENDER WEEKLY SUMMARY TABLE — per-day breakdown
// ─────────────────────────────────────────────────────────
if tbl_weekly and barstate.islast
    tbl_weekly_pos_conv = switch tbl_weekly_pos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.middle_left

    int cur_dow   = dayofweek(time, "America/Chicago")
    int cur_hour  = hour(time, "America/Chicago")
    int cur_min   = minute(time, "America/Chicago")
    int days_since_sun = cur_dow == 1 ? 0 : cur_dow - 1
    bool before_open = cur_dow == 1 and (cur_hour < 17)
    if before_open
        days_since_sun := 7
    int week_open_ts = time - days_since_sun * 86400000 - (cur_hour * 3600000) - (cur_min * 60000) + 17 * 3600000

    var int[]   day_wins   = array.new_int(6, 0)
    var int[]   day_losses = array.new_int(6, 0)
    var int[]   day_parts  = array.new_int(6, 0)
    var float[] day_pnl    = array.new_float(6, 0.0)
    var int[]   day_tot    = array.new_int(6, 0)
    for d = 0 to 5
        array.set(day_wins,   d, 0)
        array.set(day_losses, d, 0)
        array.set(day_parts,  d, 0)
        array.set(day_pnl,    d, 0.0)
        array.set(day_tot,    d, 0)

    int   wk_wins = 0, wk_losses = 0, wk_partials = 0, wk_total = 0
    float wk_pnl  = 0.0
    int   all_rows2 = array.size(tlog_ts)
    if all_rows2 > 0
        for k = 0 to all_rows2 - 1
            int    kts = array.get(tlog_ts,     k)
            string kr  = array.get(tlog_result, k)
            float  kp  = array.get(tlog_pnl,    k)
            if kts >= week_open_ts
                int trade_dow = dayofweek(kts, "America/Chicago")
                int d = trade_dow == 1 ? 0 : trade_dow - 1
                if d >= 0 and d <= 5
                    array.set(day_tot,  d, array.get(day_tot, d) + 1)
                    array.set(day_pnl,  d, array.get(day_pnl, d) + kp)
                    if kr == "✅ Win" or str.contains(kr, "✅")
                        array.set(day_wins,   d, array.get(day_wins,   d) + 1)
                        wk_wins += 1
                    else if kr == "❌ Loss"
                        array.set(day_losses, d, array.get(day_losses, d) + 1)
                        wk_losses += 1
                    else if kr == "🔵 Partial"
                        array.set(day_parts,  d, array.get(day_parts,  d) + 1)
                        wk_partials += 1
                    wk_total += 1
                    wk_pnl   += kp
                else if kp != 0
                    wk_pnl += kp

    int   wk_settled = wk_wins + wk_losses + wk_partials
    float wk_wr      = wk_settled > 0 ? (wk_wins / wk_settled) * 100 : 0.0
    float wk_usd     = wk_pnl * tbl_usd_per_pt
    color wbg        = wk_pnl >= 0 ? color.new(#1b5e20, 0) : color.new(#b71c1c, 0)

    string gate_txt = not dll_ok ? "⛔ DLL -$" + str.tostring(math.round(math.abs(daily_loss_usd))) : "DLL: -$" + str.tostring(math.round(math.abs(daily_loss_usd))) + "/$" + str.tostring(math.round(dll_usd))
    color gate_col  = not dll_ok ? color.white : th_muted
    color gate_bg   = not dll_ok ? color.new(#b71c1c, 0) : th_hbg

    table wt = table.new(tbl_weekly_pos_conv, 6, 10,
         border_color=color.new(color.gray, 50), border_width=1,
         frame_color=color.new(color.gray, 30),  frame_width=1)

    table.cell(wt, 0, 0, "THIS WEEK", text_color=th_text, bgcolor=th_hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(wt, 1, 0, "Trades",    text_color=th_text, bgcolor=th_hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(wt, 2, 0, "W/L/P",     text_color=th_text, bgcolor=th_hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(wt, 3, 0, "Win %",     text_color=th_text, bgcolor=th_hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(wt, 4, 0, "P&L pts",   text_color=th_text, bgcolor=th_hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(wt, 5, 0, "P&L $",     text_color=th_text, bgcolor=th_hbg, text_size=tbl_sz_conv, text_halign=text.align_center)

    string[] day_names = array.from("Sun","Mon","Tue","Wed","Thu","Fri")
    for d = 0 to 5
        int   dw   = array.get(day_wins,   d)
        int   dl   = array.get(day_losses, d)
        int   dp_  = array.get(day_parts,  d)
        int   dt   = array.get(day_tot,    d)
        float dpnl = array.get(day_pnl,    d)
        float dusd = dpnl * tbl_usd_per_pt
        int   ds   = dw + dl + dp_
        float dwr  = ds > 0 ? (dw / ds) * 100 : 0.0
        int   row  = d + 1
        bool  is_today = (cur_dow == 1 ? 0 : cur_dow - 1) == d
        color day_bg   = is_today ? (isDark ? color.new(#1a237e, 40) : color.new(#c5cae9, 20)) : th_row_bg
        color day_name_col = is_today ? color.new(#90caf9, 0) : th_muted
        color pnl_bg2  = dpnl > 0 ? color.new(color.green, 70) : dpnl < 0 ? color.new(color.red, 70) : day_bg
        color pnl_col  = dpnl > 0 ? color.green : dpnl < 0 ? color.red : th_muted
        table.cell(wt, 0, row, array.get(day_names, d),                                                                        text_color=day_name_col, bgcolor=day_bg,   text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(wt, 1, row, dt > 0 ? str.tostring(dt) : "-",                                                                text_color=th_text,      bgcolor=day_bg,   text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(wt, 2, row, dt > 0 ? str.tostring(dw) + "W " + str.tostring(dl) + "L " + str.tostring(dp_) + "P" : "-",   text_color=th_text,      bgcolor=day_bg,   text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(wt, 3, row, dt > 0 ? str.tostring(math.round(dwr,0)) + "%" : "-",                                          text_color=dt>0 ? (dwr>=50 ? color.green : color.red) : th_muted, bgcolor=day_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
        table.cell(wt, 4, row, dt > 0 ? (dpnl>=0 ? "+" : "") + str.tostring(math.round(dpnl,1)) : "-",                        text_color=pnl_col,      bgcolor=pnl_bg2,  text_size=tbl_sz_conv, text_halign=text.align_right)
        table.cell(wt, 5, row, dt > 0 ? (dusd>=0 ? "+$" : "-$") + str.tostring(math.round(math.abs(dusd))) : "-",             text_color=pnl_col,      bgcolor=pnl_bg2,  text_size=tbl_sz_conv, text_halign=text.align_right)

    table.cell(wt, 0, 7, "TOTAL",                                                                                              text_color=color.white, bgcolor=th_sum_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(wt, 1, 7, str.tostring(wk_total) + " trades",                                                                   text_color=color.white, bgcolor=th_sum_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(wt, 2, 7, str.tostring(wk_wins) + "W " + str.tostring(wk_losses) + "L " + str.tostring(wk_partials) + "P",    text_color=color.white, bgcolor=th_sum_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(wt, 3, 7, str.tostring(math.round(wk_wr,1)) + "%",                                                              text_color=wk_wr>=50 ? color.green : color.red, bgcolor=th_sum_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(wt, 4, 7, (wk_pnl>=0 ? "+" : "") + str.tostring(math.round(wk_pnl,1)) + " pts",                                text_color=color.white, bgcolor=wbg,       text_size=tbl_sz_conv, text_halign=text.align_right)
    table.cell(wt, 5, 7, (wk_usd>=0 ? "+$" : "-$") + str.tostring(math.round(math.abs(wk_usd))),                              text_color=color.white, bgcolor=wbg,       text_size=tbl_sz_conv, text_halign=text.align_right)

    string instr = tbl_usd_per_pt == 2.0 ? "MNQ @ $2/pt" : tbl_usd_per_pt == 20.0 ? "NQ @ $20/pt" : tbl_usd_per_pt == 5.0 ? "MES @ $5/pt" : tbl_usd_per_pt == 50.0 ? "ES @ $50/pt" : "$" + str.tostring(tbl_usd_per_pt) + "/pt"
    string exec_lbl = (exec_book_close ? "Exec: close+" + str.tostring(exec_slip_pts) + "slip" : "Exec: level fills") + (lad_en ? " | Ladder" : "") + " | " + sig_mode
    string filt_lbl = "F5:" + str.tostring(fvg5_min_pts) + (fvg5_prev_bp ? "bp" : "pt") + " F1:" + str.tostring(fvg1_min_pts) + "pt Px:" + str.tostring(proximity_pts) + "pt"
    float  wk_comm  = comm_en ? wk_total * pos_qty * comm_rt : 0.0
    string comm_lbl = comm_en ? "Fees: -$" + str.tostring(math.round(wk_comm)) + " @$" + str.tostring(comm_rt) + "/RT" : "Fees: OFF (gross)"
    color  comm_col = comm_en ? th_muted : color.new(color.orange, 0)
    table.cell(wt, 0, 8, "Sun 5PM CT (" + str.tostring(days_since_sun) + "d ago)", text_color=th_muted, bgcolor=th_hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(wt, 1, 8, instr,           text_color=th_muted, bgcolor=th_hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(wt, 2, 8, exec_lbl,        text_color=th_muted, bgcolor=th_hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(wt, 3, 8, filt_lbl,        text_color=th_muted, bgcolor=th_hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(wt, 4, 8, comm_lbl,        text_color=comm_col, bgcolor=th_hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(wt, 5, 8, gate_txt,        text_color=gate_col, bgcolor=gate_bg, text_size=tbl_sz_conv, text_halign=text.align_center)

// ─────────────────────────────────────────────────────────
//  RENDER A/B VARIANT COMPARISON TABLE
// ─────────────────────────────────────────────────────────
if ab_en and barstate.islast
    ab_pos_conv = switch ab_tbl_pos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.middle_left

    int   live_settled = stat_wins + stat_losses + stat_partials
    float live_wr      = live_settled > 0 ? ((stat_wins + stat_partials) / live_settled) * 100 : 0.0
    int   ab_settled   = ab_wins + ab_losses + ab_partials
    float ab_wr        = ab_settled > 0 ? ((ab_wins + ab_partials) / ab_settled) * 100 : 0.0
    float diff_pts     = ab_pnl - stat_total_pnl

    table at = table.new(ab_pos_conv, 6, 5,
         border_color=color.new(color.gray, 50), border_width=1,
         frame_color=color.new(color.gray, 30),  frame_width=1)

    table.cell(at, 0, 0, "A/B LAB",  text_color=th_text, bgcolor=th_hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(at, 1, 0, "Partial",  text_color=th_text, bgcolor=th_hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(at, 2, 0, "BE?",      text_color=th_text, bgcolor=th_hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(at, 3, 0, "W/L/P",    text_color=th_text, bgcolor=th_hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(at, 4, 0, "Win %",    text_color=th_text, bgcolor=th_hbg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(at, 5, 0, "P&L pts",  text_color=th_text, bgcolor=th_hbg, text_size=tbl_sz_conv, text_halign=text.align_center)

    color live_bg = stat_total_pnl >= 0 ? color.new(#1b5e20, 30) : color.new(#b71c1c, 30)
    table.cell(at, 0, 1, "LIVE",                                                                                            text_color=th_text, bgcolor=th_row_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(at, 1, 1, str.tostring(rr_partial_pts) + "pt",                                                               text_color=th_text, bgcolor=th_row_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(at, 2, 1, pos_be_at_partial ? "Yes" : "No",                                                                  text_color=th_text, bgcolor=th_row_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(at, 3, 1, str.tostring(stat_wins) + "W " + str.tostring(stat_losses) + "L " + str.tostring(stat_partials) + "P", text_color=th_text, bgcolor=th_row_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(at, 4, 1, str.tostring(math.round(live_wr,1)) + "%",                                                         text_color=th_text, bgcolor=th_row_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(at, 5, 1, (stat_total_pnl>=0 ? "+" : "") + str.tostring(math.round(stat_total_pnl,1)),                        text_color=color.white, bgcolor=live_bg, text_size=tbl_sz_conv, text_halign=text.align_right)

    color ab_bg = ab_pnl >= 0 ? color.new(#1b5e20, 30) : color.new(#b71c1c, 30)
    table.cell(at, 0, 2, "VARIANT",                                                                                         text_color=color.new(#90caf9,0), bgcolor=th_row_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(at, 1, 2, str.tostring(ab_partial_pts) + "pt",                                                               text_color=th_text, bgcolor=th_row_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(at, 2, 2, ab_be ? "Yes" : "No",                                                                              text_color=th_text, bgcolor=th_row_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(at, 3, 2, str.tostring(ab_wins) + "W " + str.tostring(ab_losses) + "L " + str.tostring(ab_partials) + "P",  text_color=th_text, bgcolor=th_row_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(at, 4, 2, str.tostring(math.round(ab_wr,1)) + "%",                                                           text_color=th_text, bgcolor=th_row_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(at, 5, 2, (ab_pnl>=0 ? "+" : "") + str.tostring(math.round(ab_pnl,1)),                                       text_color=color.white, bgcolor=ab_bg, text_size=tbl_sz_conv, text_halign=text.align_right)

    color d_bg = diff_pts >= 0 ? color.new(#1b5e20, 0) : color.new(#b71c1c, 0)
    table.cell(at, 0, 3, "DIFF",                                                                                            text_color=color.white, bgcolor=d_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(at, 1, 3, "variant − live",                                                                                  text_color=color.white, bgcolor=d_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(at, 2, 3, "",                                                                                                text_color=color.white, bgcolor=d_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(at, 3, 3, str.tostring(ab_trades) + " sig",                                                                  text_color=color.white, bgcolor=d_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(at, 4, 3, (diff_pts>=0 ? "+$" : "-$") + str.tostring(math.round(math.abs(diff_pts * tbl_usd_per_pt))),        text_color=color.white, bgcolor=d_bg, text_size=tbl_sz_conv, text_halign=text.align_center)
    table.cell(at, 5, 3, (diff_pts>=0 ? "+" : "") + str.tostring(math.round(diff_pts,1)),                                   text_color=color.white, bgcolor=d_bg, text_size=tbl_sz_conv, text_halign=text.align_right)

    table.cell(at, 0, 4, "Variant = full size, no ladder",                                                                  text_color=th_muted, bgcolor=th_hbg, text_size=size.tiny, text_halign=text.align_center)
    table.cell(at, 1, 4, "read-only",                                                                                        text_color=th_muted, bgcolor=th_hbg, text_size=size.tiny, text_halign=text.align_center)
    table.cell(at, 2, 4, "",                                                                                                 text_color=th_muted, bgcolor=th_hbg, text_size=size.tiny, text_halign=text.align_center)
    table.cell(at, 3, 4, "",                                                                                                 text_color=th_muted, bgcolor=th_hbg, text_size=size.tiny, text_halign=text.align_center)
    table.cell(at, 4, 4, "",                                                                                                 text_color=th_muted, bgcolor=th_hbg, text_size=size.tiny, text_halign=text.align_center)
    table.cell(at, 5, 4, "",                                                                                                 text_color=th_muted, bgcolor=th_hbg, text_size=size.tiny, text_halign=text.align_center)

// ─────────────────────────────────────────────────────────
//  ALERTS
//  These alert() payloads carry real quantities and prices. To use them,
//  create ONE TradingView alert on this indicator with the condition
//  "Any alert() function call" — then delete the old per-event alerts.
// ─────────────────────────────────────────────────────────
string _tk = syminfo.ticker
string _px_json = str.tostring(math.round(close, 2))

if alert_on_nest and bullNested
    string _slj = tp_send_stop and not na(last_sig_stop) ? ',"stopLoss":{"type":"stop","stopPrice":' + str.tostring(math.round(last_sig_stop, 2)) + '}' : ''
    alert('{"ticker":"' + _tk + '","action":"buy","signal":"' + str.tostring(sig_count) + '","price":' + _px_json + ',"quantity":' + str.tostring(lad_en ? lad_qty1 : pos_qty) + ',"orderType":"market"' + _slj + '}', alert.freq_once_per_bar_close)
if alert_on_nest and bearNested
    string _slj = tp_send_stop and not na(last_sig_stop) ? ',"stopLoss":{"type":"stop","stopPrice":' + str.tostring(math.round(last_sig_stop, 2)) + '}' : ''
    alert('{"ticker":"' + _tk + '","action":"sell","signal":"' + str.tostring(sig_count) + '","price":' + _px_json + ',"quantity":' + str.tostring(lad_en ? lad_qty1 : pos_qty) + ',"orderType":"market"' + _slj + '}', alert.freq_once_per_bar_close)
// Ladder leg fill — add to the existing position
if alert_on_nest and outcome_add and q_add > 0
    string _als = lad_stop_every and not na(last_add_stop) ? ',"stopLoss":{"type":"stop","stopPrice":' + str.tostring(math.round(last_add_stop, 2)) + '}' : ''
    alert('{"ticker":"' + _tk + '","action":"' + (last_add_dir == 1 ? "buy" : "sell") + '","price":' + _px_json + ',"quantity":' + str.tostring(q_add) + ',"orderType":"market"' + _als + '}', alert.freq_once_per_bar_close)
// Pullback (Near/Middle/Far Edge) entry fill — previously logged but never sent
if alert_on_nest and outcome_entry and last_entry_qty > 0
    string _pls = tp_send_stop and not na(last_entry_stop) ? ',"stopLoss":{"type":"stop","stopPrice":' + str.tostring(math.round(last_entry_stop, 2)) + '}' : ''
    alert('{"ticker":"' + _tk + '","action":"' + (last_entry_dir == 1 ? "buy" : "sell") + '","price":' + _px_json + ',"quantity":' + str.tostring(last_entry_qty) + ',"orderType":"market"' + _pls + '}', alert.freq_once_per_bar_close)
if alert_partial and outcome_partial
    alert('{"ticker":"' + _tk + '","action":"exit","price":' + _px_json + ',"quantity":' + str.tostring(q_partial) + '}', alert.freq_once_per_bar_close)
    if tp_send_be
        alert('{"ticker":"' + _tk + '","action":"breakeven","orderType":"stop"}', alert.freq_once_per_bar_close)
if alert_partial and outcome_partial_win
    alert('{"ticker":"' + _tk + '","action":"exit","price":' + _px_json + ',"quantity":' + str.tostring(q_partial) + '}', alert.freq_once_per_bar_close)
if alert_partial and outcome_be
    alert('{"ticker":"' + _tk + '","action":"exit","price":' + _px_json + ',"quantity":' + str.tostring(q_be) + '}', alert.freq_once_per_bar_close)
if alert_stop and outcome_loss
    alert('{"ticker":"' + _tk + '","action":"exit","price":' + _px_json + ',"quantity":' + str.tostring(q_stop) + '}', alert.freq_once_per_bar_close)
if alert_target and outcome_target
    alert('{"ticker":"' + _tk + '","action":"exit","price":' + _px_json + ',"quantity":' + str.tostring(q_target) + '}', alert.freq_once_per_bar_close)
if alert_target and outcome_ext_target
    alert('{"ticker":"' + _tk + '","action":"exit","price":' + _px_json + ',"quantity":' + str.tostring(q_ext) + '}', alert.freq_once_per_bar_close)
if alert_target and outcome_t3
    alert('{"ticker":"' + _tk + '","action":"exit","price":' + _px_json + ',"quantity":' + str.tostring(q_t3) + '}', alert.freq_once_per_bar_close)

if outcome_emergency
    alert('{"ticker":"' + _tk + '","action":"exit","price":' + _px_json + ',"quantity":' + str.tostring(q_emerg) + '}', alert.freq_once_per_bar_close)

// Legacy alertcondition() hooks — DEPRECATED. Static payloads cannot carry the
// computed stop or mode-aware quantities; entry/stop/BE/emergency payloads omit
// "quantity" so the webhook platform's fixed size (entries) or a full-position
// exit (stops) applies in either 3- or 4-contract mode. Prefer the single
// "Any alert() function call" alert above.
alertcondition(outcome_entry,       title="Trade Entered",              message="Trade Entered — price reached entry — {{ticker}} {{interval}} @ {{close}}")
alertcondition(bullNested,          title="Nested Bull (Buy)",          message='{"ticker":"{{ticker}}","action":"buy","price":{{close}},"orderType":"market"}')
alertcondition(bearNested,          title="Nested Bear (Sell)",         message='{"ticker":"{{ticker}}","action":"sell","price":{{close}},"orderType":"market"}')
alertcondition(outcome_partial,     title="Partial Filled",             message='{"ticker":"{{ticker}}","action":"exit","price":{{close}},"quantity":1}')
alertcondition(outcome_partial_win, title="Partial Win",                message='{"ticker":"{{ticker}}","action":"exit","price":{{close}},"quantity":1}')
alertcondition(outcome_be,          title="Break-Even Scratch",         message='{"ticker":"{{ticker}}","action":"exit","price":{{close}}}')
alertcondition(outcome_loss,        title="Stop Hit",                   message='{"ticker":"{{ticker}}","action":"exit","price":{{close}}}')
alertcondition(outcome_target,      title="Target Hit T1",              message='{"ticker":"{{ticker}}","action":"exit","price":{{close}},"quantity":1}')
alertcondition(outcome_ext_target,  title="Extended Target T2",         message='{"ticker":"{{ticker}}","action":"exit","price":{{close}},"quantity":1}')
alertcondition(outcome_t3,          title="Runner T3 Exit",             message='{"ticker":"{{ticker}}","action":"exit","price":{{close}},"quantity":1}')
alertcondition(outcome_emergency,   title="Emergency Exit",             message='{"ticker":"{{ticker}}","action":"exit","price":{{close}}}')

// ─────────────────────────────────────────────────────────
//  PLOT MARKERS
// ─────────────────────────────────────────────────────────
plotshape(bullNested, "Nested Bull", shape.triangleup,   location.belowbar, sig_bull_col, size=size.small)
plotshape(bearNested, "Nested Bear", shape.triangledown, location.abovebar, sig_bear_col, size=size.small)
````
