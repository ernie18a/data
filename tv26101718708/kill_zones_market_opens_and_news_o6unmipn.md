# Kill Zones, Market Opens and News

- url: https://www.tradingview.com/script/o6unmIpN-Kill-Zones-Market-Opens-and-News/
- type: indicator
- pine_id: PUB;a458e987c70f4e709b9c79ac7cfd126d
- version: 3.0

## Description

Kill Zones, Market Opens and News
Version 1.0.0

Draws FX session kill zones, market opens and news event lines on intraday charts, with its own purpose built kill zones for DE40, the US indices and crude oil. First release, shared open source.

WHAT IT DRAWS
• Forex kill zones: London 07:00-10:00 UK and New York 12:00-15:00 UK, each with start and end boundary lines.
• Market open lines: 08:00 London/Frankfurt and 14:30 New York, each on its own toggle.
• News event lines, filtered to the relevant pair: GBP 07:00 / 09:30 / 12:00, USD 13:15 / 13:30 / 14:45 / 15:00 / 19:00 / 19:30, EUR 08:30 / 13:15. 13:30 USD is on by default, the rest off.
• DE40: London morning only, 08:00-10:00 Frankfurt. Own 08:00 open and 10:00 end line, no afternoon zone.
• US500 / USTEC / US30 (identical): AM orange pre-market 13:30-14:30 then green 14:30-17:00; PM green 18:00-20:00 then blue power hour 20:00-21:00.
• XTIUSD: two green zones, 08:00-10:00 and 13:00-19:00 UK, plus the 14:30 New York open and USD news.
• History range: the last 5 trading days, or the full loaded history.
• Colour, opacity, width and style adjustable on every element.

WHY THESE HOURS
• The windows come from an hour-of-day volatility study, the average bar range in each UK hour: five years of data to July 2026 for the forex majors, gold and index CFDs, and around two years for crude oil, cross-checked against real price action. The aim is to shade the hours that actually move and mark the opens and news that drive them.

HOW IT WORKS
• Each custom instrument shows only its own windows; the forex shading, session lines, opens and news are suppressed on DE40, US500, USTEC, US30 and XTIUSD.
• Forex windows track a US (New York) data feed. The custom instruments are UK clock anchored and render correctly on any exchange timezone.
• The "UK-US Time Difference" input (5 or 4) covers the roughly 4 weeks a year when UK and US daylight saving are out of step. Leave it at 5 the rest of the year.
• Boundary lines draw below 1H; kill zone shading and market opens draw at 1H and below.

WHAT IT RUNS ON
• Intraday, 1H and below.
• Forex majors and XAUUSD get the standard drawing; DE40, US500, USTEC, US30 and XTIUSD get their own custom zones.
• Custom zones match the exact symbols DE40, US500, USTEC, US30 and XTIUSD. Other broker names (for example GER40, SPX500, NAS100, WTIUSD) fall back to the standard forex drawing. The script is open source, so you can add your broker's names.
• Tested so far on forex majors, XAUUSD, DE40, US500, USTEC, US30 and XTIUSD.

HOW TO USE
• Add it to any intraday chart, 1H or below.
• On forex or gold: use the London and NY kill zones to see where the sessions sit, and turn on the opens and news you follow.
• On DE40, US500, USTEC, US30 or XTIUSD: it switches automatically to that instrument's own zones.
• In a DST gap week, set "UK-US Time Difference" to 4; otherwise leave it at 5.
• Use the History range control to keep the chart light (5 days) or show the full history.

IN THIS RELEASE (v1.0.0)
• First public release.
• Forex London and NY kill zones with adjustable boundary lines.
• 08:00 London/Frankfurt and 14:30 New York market opens.
• GBP / USD / EUR news lines, toggled individually and filtered per pair.
• Custom kill zones for DE40, US500 / USTEC / US30 and XTIUSD.
• UK clock anchored custom instruments, timezone independent, with the 5/4 DST toggle.
• History range, and full colour, opacity, width and style control.

FEEDBACK
Please let me know if you experience any issues, or have feedback for improvements or additions in the comments below. Thank you, Tom

## Source Code

````pine
//@version=6
// =============================================================================
// KILL ZONES, MARKET OPENS AND NEWS
// =============================================================================
// Author:       Tom Brown
// Description:  Draws FX session kill-zone backgrounds, market-open lines and news-event lines
//               on intraday charts (1H and below).
//
//               Kill-zone shading for the London and NY windows; open lines at 08:00
//               London/Frankfurt and 14:30 NY; news lines for GBP (GBPUSD), USD
//               (EURUSD/USDJPY/AUDUSD/GBPUSD/XAUUSD) and EUR (EUR-base pairs), each on those
//               pairs only. Also draws custom per-instrument kill zones for DE40, UK100, US500,
//               USTEC, US30 and XTI — each shows ONLY its own windows; the forex shading,
//               market opens and news are all suppressed on those six (via the `is_special`
//               gate).
//
//                 DE40   : London-morning only — background shading (08:00-10:00 UK,
//                          fixed) PLUS its own yellow 08:00 market open. DE40 is a morning
//                          mover; in the US session trade US equities (far more active),
//                          not DE40 — so no afternoon zone/open/news.
//                 UK100  : treated IDENTICALLY to DE40 — London-morning only: background
//                          shading (08:00-10:00 UK, fixed) PLUS its own yellow 08:00 market
//                          open, and no afternoon zone/open/news.
//                 US500, : treated IDENTICALLY (same US cash session) — US-anchored zones
//                 USTEC    that shift together on the 5/4 toggle. An AM session of two bands:
//                 & US30   a 13:30-14:30 UK pre-session hour (orange shade) and a 14:30-17:00
//                          UK green band (09:30-12:00 ET, green shade). Plus an 18:00-21:00 UK
//                          PM session (13:00-16:00 ET) split into a green 18:00-20:00 band and
//                          a blue 20:00-21:00 power hour. Shading only — no lines of any kind.
//                          Own shared styling inputs.
//                 XTI    : two green zones (UK-fixed) — morning 07:00-10:00 UK and afternoon
//                          13:00-19:00 UK — plus a 14:30 NY market open (US-anchored, no 08:00
//                          line) and the USD news lines. Own styling section.
// Version:      2.1.0
// Date:         2026-09-22
// =============================================================================

indicator("Kill Zones, Market Opens and News", overlay = true, max_lines_count = 500, max_bars_back = 5000)

// --- input group headers ------------------------------------------------------
// Two-tier panel: heavy ════ banners are the parent sections; the flat groups below
// are declared contiguously in panel-reading order (a split group renders its header
// twice, so all inputs of a group sit together).
grp_time_zone    = "════ TIME ZONE ADJUSTMENT ════"
grp_history      = "════ HISTORY RANGE ════"
grp_gbp_news     = "════ GBP NEWS ════"
grp_usd_news     = "════ USD NEWS ════"
grp_eur_news     = "════ EUR NEWS ════"
grp_news_styling = "════ NEWS STYLING ════"
grp_market_opens = "════ MARKET OPEN MARKERS ════"
grp_fx_sessions  = "════ FOREX SESSION KILL ZONES ════"
grp_de40         = "════ DE40 ════"
grp_uk100        = "════ UK100 ════"
grp_usidx        = "════ US30/USTEC/US500 — US AM SESSION ════"
grp_power        = "════ US30/USTEC/US500 — US PM SESSION (INC. POWER HOUR) ════"
grp_xti          = "════ XTI ════"

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ════ TIME ZONE ADJUSTMENT ════
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
lon_ukus_time_difference = input.int(5, "UK-US Time Difference", options = [5, 4], group = grp_time_zone, tooltip = 'Hours between UK and US clocks: 5 normally, 4\nduring the spring/autumn DST-gap weeks.')

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ════ HISTORY RANGE ════
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
show_history = input.bool(true, "Show History", group = grp_history, tooltip = "Draw prior days' lines, not just today's.")
history_range = input.string("5 Days", "History range", options = ["5 Days", "Max History"], group = grp_history, tooltip = 'Limit the historical shading and lines to the\nlast 5 days (lighter / faster on scroll), or\ndraw the full loaded history.')

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ════ GBP / USD / EUR NEWS ════
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GBP (GBPUSD only), USD (EURUSD/USDJPY/AUDUSD/GBPUSD/XAUUSD), EUR (EUR-base pairs) —
// three separate groups, plus the shared news-line styling.
show_0700_gbp = input.bool(false, "Show 07:00 News", group = grp_gbp_news, tooltip = "07:00 UK GBP news line (GBPUSD only).")
show_0930_gbp = input.bool(false, "Show 09:30 News", group = grp_gbp_news, tooltip = "09:30 UK GBP news line (GBPUSD only).")
show_1200_gbp = input.bool(false, "Show 12:00 News", group = grp_gbp_news, tooltip = "12:00 UK GBP news line (GBPUSD only).")
show_1315_us  = input.bool(false, "Show 13:15 News", group = grp_usd_news, tooltip = '13:15 UK USD news line\n(EURUSD/USDJPY/AUDUSD/GBPUSD/XAUUSD and\nXTIUSD).')
show_1330_us  = input.bool(false, "Show 13:30 News", group = grp_usd_news, tooltip = '13:30 UK USD news line\n(EURUSD/USDJPY/AUDUSD/GBPUSD/XAUUSD and\nXTIUSD).')
show_1445_us  = input.bool(false, "Show 14:45 News", group = grp_usd_news, tooltip = '14:45 UK USD news line\n(EURUSD/USDJPY/AUDUSD/GBPUSD/XAUUSD and\nXTIUSD).')
show_1500_us  = input.bool(false, "Show 15:00 News", group = grp_usd_news, tooltip = '15:00 UK USD news line\n(EURUSD/USDJPY/AUDUSD/GBPUSD/XAUUSD and\nXTIUSD).')
show_1900_us  = input.bool(false, "Show 19:00 News", group = grp_usd_news, tooltip = '19:00 UK USD news line\n(EURUSD/USDJPY/AUDUSD/GBPUSD/XAUUSD and\nXTIUSD).')
show_1930_us  = input.bool(false, "Show 19:30 News", group = grp_usd_news, tooltip = '19:30 UK USD news line\n(EURUSD/USDJPY/AUDUSD/GBPUSD/XAUUSD and\nXTIUSD).')
show_0830_eur = input.bool(false, "Show 08:30 News", group = grp_eur_news, tooltip = "08:30 UK EUR news line (EUR-base pairs).")
show_1315_eur = input.bool(false, "Show 13:15 News", group = grp_eur_news, tooltip = "13:15 UK EUR news line (EUR-base pairs).")
news_color     = input.color(color.red, "News Line Colour",  group = grp_news_styling, tooltip = "Colour of the news-event lines.")
news_thickness = input.int(1,           "News Line Width",   minval = 1, group = grp_news_styling, tooltip = "Width of the news-event lines.")
news_opacity   = input.int(25,          "News Line Opacity", minval = 0, maxval = 100, group = grp_news_styling, tooltip = "0 = invisible, 100 = solid. Higher = more solid.")
final_news_color = color.new(news_color, 100 - news_opacity)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ════ MARKET OPEN MARKERS ════
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
show_0800_open = input.bool(true, "Show 08:00 London/Frankfurt Open", group = grp_market_opens, tooltip = "Line at the 08:00 UK London/Frankfurt open.")
show_1430_open = input.bool(true, "Show 14:30 NY Equities Open",      group = grp_market_opens, tooltip = "Line at the 14:30 UK NY equities open.")
open_color     = input.color(color.yellow,      "Open Line Colour",  group = grp_market_opens, tooltip = "Colour of the market-open lines.")
open_thickness = input.int(1,                   "Open Line Width",   minval = 1, group = grp_market_opens, tooltip = "Width of the market-open lines.")
open_opacity   = input.int(50,                  "Open Line Opacity", minval = 0, maxval = 100, group = grp_market_opens, tooltip = "0 = invisible, 100 = solid. Higher = more solid.")
open_style_sel = input.string("Solid", "Open Line Style", options = ["Solid", "Dotted", "Dashed"], group = grp_market_opens, tooltip = "Style of the market-open lines.")
open_style     = open_style_sel == "Solid" ? line.style_solid : open_style_sel == "Dotted" ? line.style_dotted : line.style_dashed
final_open_color = color.new(open_color, 100 - open_opacity)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ════ FOREX SESSION KILL ZONES ════
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// London and NY start/end times are hardcoded (Tom, 2026-09-22) — they do not change,
// matching how the other instrument-specific zones already carry no time input.
lon_start_hour   = 7
lon_start_minute = 0
lon_end_hour     = 10
lon_end_minute   = 0
ny_start_hour    = 12
ny_start_minute  = 0
ny_end_hour      = 15
ny_end_minute    = 0
show_lon_zone    = input.bool(true, "Show London Kill Zone", group = grp_fx_sessions, tooltip = "Shade the London kill-zone window.")
show_ny_zone     = input.bool(true, "Show NY Kill Zone",     group = grp_fx_sessions, tooltip = "Shade the NY kill-zone window.")
bg_color         = input.color(color.green, "Kill Zone Colour", group = grp_fx_sessions, tooltip = "Kill-zone shading colour.")
bg_transparency  = input.int(97,            "Kill Zone Transparency", minval = 0, maxval = 100, group = grp_fx_sessions, tooltip = '0 = solid, 100 = invisible.\n\nLower = more solid (kept high for subtle\nshading).')
final_bg         = color.new(bg_color, bg_transparency)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ════ DE40 ════
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DE40 draws its OWN kill zone and market open (the forex furniture is suppressed on it
// via is_special). Defaults reproduce the shared styling DE40 previously borrowed exactly.
// DE40 = London-morning only. DE40 is a morning mover; in the US session trade US equities
// (far more active), not DE40 — so no afternoon zone/open/news.
show_de40_zone      = input.bool(true,                     "Show London Open Kill Zone", group = grp_de40, tooltip = 'Shade the DE40 kill-zone window (08:00-10:00\nUK morning).')
de40_bg_color       = input.color(color.green,             "Kill Zone Colour",        group = grp_de40, tooltip = "DE40 kill-zone shading colour.")
de40_bg_transparency = input.int(97,                       "Kill Zone Transparency",  minval = 0, maxval = 100, group = grp_de40, tooltip = '0 = solid, 100 = invisible.\n\nLower = more solid (kept high for subtle\nshading).')
de40_open_color     = input.color(color.yellow,           "Open Line Colour",        group = grp_de40, tooltip = "Colour of the DE40 08:00 market-open line.")
de40_open_thickness = input.int(1,                         "Open Line Width",         minval = 1, group = grp_de40, tooltip = "Width of the DE40 08:00 market-open line.")
de40_open_opacity   = input.int(50,                        "Open Line Opacity",       minval = 0, maxval = 100, group = grp_de40, tooltip = "0 = invisible, 100 = solid. Higher = more solid.")
de40_open_style_sel = input.string("Solid", "Open Line Style", options = ["Solid", "Dotted", "Dashed"], group = grp_de40, tooltip = "Style of the DE40 08:00 market-open line.")
de40_open_style     = de40_open_style_sel == "Solid" ? line.style_solid : de40_open_style_sel == "Dotted" ? line.style_dotted : line.style_dashed

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ════ UK100 ════
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UK100 draws its OWN kill zone and market open (the forex furniture is suppressed on it
// via is_special). Treated exactly as DE40, with the same defaults: London-morning only —
// the 08:00-10:00 UK window (UK-anchored, fixed) and its own yellow 08:00 market open.
// No afternoon zone/open/news.
show_uk100_zone      = input.bool(true,                     "Show London Open Kill Zone", group = grp_uk100, tooltip = 'Shade the UK100 kill-zone window (08:00-10:00\nUK morning).')
uk100_bg_color       = input.color(color.green,             "Kill Zone Colour",        group = grp_uk100, tooltip = "UK100 kill-zone shading colour.")
uk100_bg_transparency = input.int(97,                       "Kill Zone Transparency",  minval = 0, maxval = 100, group = grp_uk100, tooltip = '0 = solid, 100 = invisible.\n\nLower = more solid (kept high for subtle\nshading).')
uk100_open_color     = input.color(color.yellow,            "Open Line Colour",        group = grp_uk100, tooltip = "Colour of the UK100 08:00 market-open line.")
uk100_open_thickness = input.int(1,                         "Open Line Width",         minval = 1, group = grp_uk100, tooltip = "Width of the UK100 08:00 market-open line.")
uk100_open_opacity   = input.int(50,                        "Open Line Opacity",       minval = 0, maxval = 100, group = grp_uk100, tooltip = "0 = invisible, 100 = solid. Higher = more solid.")
uk100_open_style_sel = input.string("Solid", "Open Line Style", options = ["Solid", "Dotted", "Dashed"], group = grp_uk100, tooltip = "Style of the UK100 08:00 market-open line.")
uk100_open_style     = uk100_open_style_sel == "Solid" ? line.style_solid : uk100_open_style_sel == "Dotted" ? line.style_dotted : line.style_dashed

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ════ US30/USTEC/US500 — US AM SESSION ════
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// US500, USTEC and US30 only, treated identically. Two shaded bands, all US-anchored (shift on
// the 5/4 toggle): a 13:30-14:30 UK pre-session hour (orange, own inputs below) and a
// 14:30-17:00 UK green band (09:30-12:00 ET). The green band uses the am_* styling set; the
// orange pre-session keeps its own (pre_*). US30 rides the same shared inputs.
pre_bg_color     = input.color(color.orange,       "Pre-Session Zone Colour",           group = grp_usidx, tooltip = 'Shading colour of the 13:30-14:30 UK\npre-session band (light orange).')
pre_bg_transparency = input.int(94,                "Pre-Session Zone Transparency",     minval = 0, maxval = 100, group = grp_usidx, tooltip = '0 = solid, 100 = invisible.\n\nTransparency of the pre-session shading.')
show_am_zone      = input.bool(true,                "Show AM Session",                  group = grp_usidx, tooltip = 'Shade the AM session: the 13:30-14:30 UK\norange pre-market hour (08:30-09:30 ET) and\nthe 14:30-17:00 UK green band (09:30-12:00\nET).\n\nUS500 / USTEC / US30 only.')
am_green_color    = input.color(color.green,        "Session Zone Colour",              group = grp_usidx, tooltip = 'Shading colour of the 14:30-17:00 UK AM\nsession band (09:30-12:00 ET).\n\nUS500 / USTEC / US30 only.')
am_bg_transparency = input.int(97,                  "Session Zone Transparency",        minval = 0, maxval = 100, group = grp_usidx, tooltip = '0 = solid, 100 = invisible.\n\nTransparency of the AM session shading (kept\nhigh for a subtle shade).')

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ════ US30/USTEC/US500 — US PM SESSION (INC. POWER HOUR) ════
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// US500, USTEC and US30 only. The US 13:00-16:00 ET PM session = 18:00-21:00 UK; both edges
// are US-anchored and shift on the 5/4 toggle, exactly like the US-open kill zone above. Split
// into two shaded bands: a GREEN 18:00-20:00 UK band (13:00-15:00 ET) and a BLUE 20:00-21:00 UK
// power hour (15:00-16:00 ET). One shared zone toggle drives both bands. Shading only.
show_pm_zone      = input.bool(true,                "Show PM Session",                      group = grp_power, tooltip = 'Shade the 18:00-21:00 UK PM session\n(13:00-16:00 ET), split into a green\n18:00-20:00 band and a blue 20:00-21:00 power\nhour.\n\nUS500 / USTEC / US30 only.')
pm_green_color    = input.color(color.green,        "PM Session Zone Colour",               group = grp_power, tooltip = 'Shading colour of the 18:00-20:00 UK PM\nsession band (13:00-15:00 ET).\n\nUS500 / USTEC / US30 only.')
pm_blue_color     = input.color(color.blue,         "Power Hour Zone Colour",               group = grp_power, tooltip = 'Shading colour of the 20:00-21:00 UK\npower-hour band (15:00-16:00 ET).\n\nUS500 / USTEC / US30 only.')
pm_bg_transparency = input.int(97,                  "Kill Zone Transparency",               minval = 0, maxval = 100, group = grp_power, tooltip = '0 = solid, 100 = invisible.\n\nLower = more solid (kept high for a subtle\nshade). Shared by both bands.')

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ════ XTI ════
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// XTIUSD only. Draws its OWN kill zones (the forex furniture is suppressed on it via
// is_special). Two UK-clock green kill zones — morning 07:00-10:00 UK and afternoon
// 13:00-19:00 UK (both UK-anchored, fixed). Plus the 14:30 NY equities open (US-anchored,
// via the shared MARKET OPEN styling) and the six USD news lines (via the shared NEWS
// STYLING), each gated by its existing USD-news toggle.
show_xti_morn_zone = input.bool(true, "Show London AM Kill Zone", group = grp_xti, tooltip = "Shade the XTI morning kill zone (07:00-10:00 UK).\n\nXTIUSD only.")
show_xti_aft_zone  = input.bool(true, "Show NY Session Kill Zone", group = grp_xti, tooltip = "Shade the XTI afternoon kill zone (13:00-19:00 UK).\n\nXTIUSD only.")
xti_green_color = input.color(color.green, "Kill Zone Colour", group = grp_xti, tooltip = "XTI kill-zone shading colour (standard green).")
xti_bg_transparency = input.int(97, "Kill Zone Transparency", minval = 0, maxval = 100, group = grp_xti, tooltip = '0 = solid, 100 = invisible.\n\nTransparency of the XTI kill-zone shading (kept\nhigh for a subtle shade).')

// --- resolved DE40 colours ----------------------------------------------------
final_de40_bg   = color.new(de40_bg_color,   de40_bg_transparency)
final_de40_open = color.new(de40_open_color, 100 - de40_open_opacity)

// --- resolved UK100 colours ---------------------------------------------------
final_uk100_bg   = color.new(uk100_bg_color,   uk100_bg_transparency)
final_uk100_open = color.new(uk100_open_color, 100 - uk100_open_opacity)

// --- resolved US500/USTEC/US30 colours ----------------------------------------
final_pre_bg   = color.new(pre_bg_color, pre_bg_transparency)
final_am_green_bg   = color.new(am_green_color, am_bg_transparency)
final_pm_green_bg   = color.new(pm_green_color, pm_bg_transparency)
final_pm_blue_bg    = color.new(pm_blue_color, pm_bg_transparency)

// --- resolved XTI colours -----------------------------------------------------
final_xti_bg   = color.new(xti_green_color, xti_bg_transparency)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SHARED STATE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Anchor "now" to the LAST BAR's time, not wall-clock timenow. timenow always
// returns the real execution time — even in Bar Replay, where the replayed bars
// are treated as realtime but timenow never follows the replay cursor. Keying
// today/yesterday and the history window off last_bar_time makes all of this track
// the replay position (and, live, last_bar_time is the current forming bar → same
// result). This is what makes the tool work under Bar Replay.
ref_now       = last_bar_time
is_today      = dayofmonth(time) == dayofmonth(ref_now) and month(time) == month(ref_now) and year(time) == year(ref_now)
is_yesterday  = dayofmonth(time) == dayofmonth(ref_now - 86400000) and month(time) == month(ref_now - 86400000) and year(time) == year(ref_now - 86400000)
// Seconds charts are excluded deliberately: timeframe.multiplier is expressed in SECONDS there,
// so 1S-30S would satisfy `<= 60` and every bar-count projection below (lon_bars_in_1_hour,
// lon_offset_bars) would be 60x out, painting every window ~4 hours early. The tool is for
// minute charts up to 1H; on a seconds chart it now draws nothing at all.
is_1h_or_below = timeframe.isintraday and not timeframe.isseconds and timeframe.multiplier <= 60
show_tf       = timeframe.isintraday and not timeframe.isseconds and timeframe.multiplier <= 60

lon_current_hhmm  = hour(time) * 100 + minute(time)
lon_bars_in_1_hour = 60 / timeframe.multiplier
lon_offset_bars   = math.round(lon_bars_in_1_hour * 4)
day_eligible      = show_history or is_today
show_on_this_bar  = show_tf and day_eligible
// History range gate — "5 Days" = the last 5 TRADING days (weekends do NOT count),
// applied to BOTH the shading and the historical lines. The calendar-days needed to
// span 5 weekdays depends on today's weekday (a mid-week window straddles a weekend);
// floor to that day's midnight so the whole earliest trading day is included.
// "Max History" draws the full loaded range.
cal_days_back = dayofweek(ref_now) == dayofweek.friday ? 4 : dayofweek(ref_now) == dayofweek.saturday ? 5 : 6
range_cut_ms  = ref_now - cal_days_back * 86400000
range_cutoff  = timestamp("UTC", year(range_cut_ms), month(range_cut_ms), dayofmonth(range_cut_ms), 0, 0)
hist_within_range = history_range == "Max History" or time >= range_cutoff

is_gbp_pair = syminfo.ticker == "GBPUSD"
is_usd_pair = syminfo.ticker == "EURUSD" or syminfo.ticker == "USDJPY" or syminfo.ticker == "AUDUSD" or syminfo.ticker == "GBPUSD" or syminfo.ticker == "XAUUSD"
is_eur_pair = syminfo.basecurrency == "EUR"

// Per-instrument flags for the custom (non-forex) kill zones. These symbols show
// ONLY their own windows; the forex London/NY shading, market opens and news are all
// suppressed on them (via the `not is_special` gate on lon_in_window /
// ny_in_window and the today/historical blocks below). Each carries its own zone code
// further down — being in is_special means "custom instrument, forex furniture off".
is_de40    = syminfo.ticker == "DE40"
is_uk100   = syminfo.ticker == "UK100"
is_us500   = syminfo.ticker == "US500"
is_ustec   = syminfo.ticker == "USTEC"
is_us30    = syminfo.ticker == "US30"
is_xti     = syminfo.ticker == "XTIUSD"
// US500, USTEC and US30 are treated IDENTICALLY (same US cash session) — grouped for the
// shared pre-session / US-open / power-hour zone draws below.
is_us_index = is_us500 or is_ustec or is_us30
is_special = is_de40 or is_uk100 or is_us500 or is_ustec or is_us30 or is_xti

// Membership test for a custom kill-zone window declared in UK time. Detects in
// explicit UK time (hour(time,"Europe/London")) so it is correct on ANY exchange
// timezone — unlike the forex London/NY blocks, which read the bar in the symbol's
// own (New York) exchange tz.
//   - The -4 pre-compensates the +4h projection applied by the bgcolor offset
//     (lon_offset_bars), exactly as the forex windows do, so all shading aligns.
//   - us_start / us_end: when true, that bound is anchored to the US clock and shifts
//     with the 5/4 toggle (us_gap = 1 in the DST-mismatch weeks → the bound lands one
//     hour earlier in UK time). When false, the bound is UK/EU-anchored and fixed.
in_uk_window(uk_s_hr, uk_s_min, uk_e_hr, uk_e_min, us_start, us_end) =>
    us_gap   = 5 - lon_ukus_time_difference
    s_hr     = (uk_s_hr - (us_start ? us_gap : 0) - 4 + 24) % 24
    e_hr     = (uk_e_hr - (us_end   ? us_gap : 0) - 4 + 24) % 24
    s_hhmm   = s_hr * 100 + uk_s_min
    e_hhmm   = e_hr * 100 + uk_e_min
    cur_hhmm = hour(time, "Europe/London") * 100 + minute(time, "Europe/London")
    regular  = cur_hhmm >= s_hhmm and cur_hhmm < e_hhmm
    wrap     = s_hhmm > e_hhmm and (cur_hhmm >= s_hhmm or cur_hhmm < e_hhmm)
    regular or wrap

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BGCOLOR KILL ZONES
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// London detection window (pre-compensated for the 4-hour projection offset)
lon_shifted_start_hour = (lon_start_hour - lon_ukus_time_difference - 4 + 24) % 24
lon_shifted_end_hour   = (lon_end_hour   - lon_ukus_time_difference - 4 + 24) % 24
lon_shifted_start_hhmm = lon_shifted_start_hour * 100 + lon_start_minute
lon_shifted_end_hhmm   = lon_shifted_end_hour   * 100 + lon_end_minute

lon_regular_win        = lon_current_hhmm >= lon_shifted_start_hhmm and lon_current_hhmm < lon_shifted_end_hhmm
lon_wrap_win           = lon_shifted_start_hhmm > lon_shifted_end_hhmm and (lon_current_hhmm >= lon_shifted_start_hhmm or lon_current_hhmm < lon_shifted_end_hhmm)
yesterday_wrap_allowed = is_yesterday and lon_wrap_win and lon_current_hhmm >= lon_shifted_start_hhmm
lon_in_window          = show_lon_zone and show_tf and (lon_regular_win or lon_wrap_win) and (day_eligible or yesterday_wrap_allowed) and not is_special

// NY detection window (NY always uses hardcoded 5)
ny_shifted_start_hour = (ny_start_hour - 5 - 4 + 24) % 24
ny_shifted_end_hour   = (ny_end_hour   - 5 - 4 + 24) % 24
ny_shifted_start_hhmm = ny_shifted_start_hour * 100 + ny_start_minute
ny_shifted_end_hhmm   = ny_shifted_end_hour   * 100 + ny_end_minute

ny_regular_win = lon_current_hhmm >= ny_shifted_start_hhmm and lon_current_hhmm < ny_shifted_end_hhmm
ny_wrap_win    = ny_shifted_start_hhmm > ny_shifted_end_hhmm and (lon_current_hhmm >= ny_shifted_start_hhmm or lon_current_hhmm < ny_shifted_end_hhmm)
ny_in_window   = show_ny_zone and (ny_regular_win or ny_wrap_win) and show_on_this_bar and not is_special

bgcolor(lon_in_window and hist_within_range ? final_bg : na, offset = lon_offset_bars)
bgcolor(ny_in_window  and hist_within_range ? final_bg : na, offset = lon_offset_bars)

// Custom per-instrument kill zones. Each instrument carries its own zone colours (DE40
// green shade; UK100 green shade; US500/USTEC/US30 orange/green; XTI green). Times in UK time, hard-coded;
// US-anchored bounds shift with the 5/4 toggle. Each instrument shows ONLY its own windows.
//   DE40  : 08:00–10:00 UK (London morning — UK-anchored, fixed). London-morning only —
//           DE40 is a morning mover; in the US session trade US equities (far more active),
//           not DE40, so there is no afternoon zone/open/news.
//   UK100 : 08:00–10:00 UK (London morning — UK-anchored, fixed). Treated exactly as DE40:
//           London-morning only, so there is no afternoon zone/open/news.
//   US500,: US-anchored zones (all shift on the 5/4 toggle), drawn exactly as the standalone
//   USTEC   US500+USTEC tool: an AM session of two bands — pre-session 13:30–14:30 UK (orange)
//   & US30  + green band 14:30–17:00 UK (09:30–12:00 ET) — plus a two-band PM session 18:00–21:00
//           UK (13:00–16:00 ET): green 18:00–20:00 + blue 20:00–21:00 power hour. USTEC and US30
//           are treated IDENTICALLY to US500.
//   XTI   : two green zones (UK-fixed) — morning 07:00–10:00 UK and afternoon 13:00–19:00 UK —
//           plus a 14:30 NY market open (US-anchored) and the USD news lines.
de40_w1   = in_uk_window(8,  0,  10, 0,  false, false)   // DE40 London morning  (08:00-10:00 UK, fixed)
uk100_w1  = in_uk_window(8,  0,  10, 0,  false, false)   // UK100 London morning (08:00-10:00 UK, fixed)
pre_kz      = in_uk_window(13, 30, 14, 30, true,  true)   // pre-market hour       (08:30-09:30 ET)
am_green_kz = in_uk_window(14, 30, 17, 0,  true,  true)   // AM green band         (09:30-12:00 ET)
pm_green_kz = in_uk_window(18, 0,  20, 0,  true,  true)   // PM session green band (13:00-15:00 ET)
pm_blue_kz  = in_uk_window(20, 0,  21, 0,  true,  true)   // power hour, blue band (15:00-16:00 ET)
xti_morn_kz = in_uk_window(7,  0,  10, 0,  false, false)  // XTI morning zone     (07:00-10:00 UK, fixed)
xti_aft_kz  = in_uk_window(13, 0,  19, 0,  false, false)  // XTI afternoon zone   (13:00-19:00 UK, fixed)

de40_in     = show_de40_zone and is_de40  and de40_w1 and show_on_this_bar and hist_within_range
uk100_in    = show_uk100_zone and is_uk100 and uk100_w1 and show_on_this_bar and hist_within_range
pre_in      = show_am_zone and is_us_index and pre_kz and show_on_this_bar and hist_within_range
am_green_in = show_am_zone  and is_us_index and am_green_kz and show_on_this_bar and hist_within_range
pm_green_in = show_pm_zone  and is_us_index and pm_green_kz and show_on_this_bar and hist_within_range
pm_blue_in  = show_pm_zone  and is_us_index and pm_blue_kz  and show_on_this_bar and hist_within_range
xti_morn_in = show_xti_morn_zone and is_xti and xti_morn_kz and show_on_this_bar and hist_within_range
xti_aft_in  = show_xti_aft_zone  and is_xti and xti_aft_kz  and show_on_this_bar and hist_within_range

bgcolor(de40_in ? final_de40_bg : na, offset = lon_offset_bars)
bgcolor(uk100_in ? final_uk100_bg : na, offset = lon_offset_bars)
bgcolor(pre_in ? final_pre_bg : na, offset = lon_offset_bars)
bgcolor(am_green_in ? final_am_green_bg : na, offset = lon_offset_bars)
bgcolor(pm_green_in ? final_pm_green_bg : na, offset = lon_offset_bars)
bgcolor(pm_blue_in  ? final_pm_blue_bg  : na, offset = lon_offset_bars)
bgcolor(xti_morn_in ? final_xti_bg : na, offset = lon_offset_bars)
bgcolor(xti_aft_in  ? final_xti_bg : na, offset = lon_offset_bars)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FUNCTIONS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Timestamp for today at (h, m), built from yesterday + one day (so it aligns with
// the is_yesterday drawing pass).
today_ts(h, m) =>
    timestamp(year(ref_now - 86400000), month(ref_now - 86400000), dayofmonth(ref_now - 86400000), h, m) + 86400000

// On the 60m chart, snap a :15/:30/:45 event onto the hour grid.
adjust_for_tf(h, m) =>
    adj_h = h
    adj_m = m
    if timeframe.period == "60"
        if m == 15 or m == 30
            adj_m := 0
        else if m == 45
            adj_h := h + 1
            adj_m := 0
    [adj_h, adj_m]

draw_news_line(h, m, sub) =>
    [adj_h, adj_m] = adjust_for_tf(h, m)
    t = today_ts(adj_h - sub, adj_m)
    line.new(t, high, t, low, xloc = xloc.bar_time, extend = extend.both, color = final_news_color, width = news_thickness, style = line.style_solid)

draw_open_line(h, m, sub) =>
    [adj_h, adj_m] = adjust_for_tf(h, m)
    t = today_ts(adj_h - sub, adj_m)
    line.new(t, high, t, low, xloc = xloc.bar_time, extend = extend.both, color = final_open_color, width = open_thickness, style = open_style)

// Market-open line at a UK time, for the custom instruments (DE40, UK100, XTI). UK-anchored
// via timestamp("Europe/London", …) so it lands correctly on ANY exchange tz, drawn in the
// MARKET OPENS style. draw_open_line cannot be reused here: it subtracts a NY offset
// from the bar's own exchange clock, which only holds for NY-based symbols — on DE40
// (Berlin) it lands ~6h out, which is why the opens are gated off the custom
// instruments via `not is_special`.
// us_anchored → the bound shifts one hour earlier in the DST-mismatch weeks (us_gap).
// adjust_for_tf IS applied, matching draw_open_line: on a 60m chart a :30 event snaps
// onto the hour grid.
draw_uk_open_line(uk_h, uk_m, us_anchored, ln_color, ln_width, ln_style) =>
    us_gap = 5 - lon_ukus_time_difference
    [adj_h, adj_m] = adjust_for_tf(uk_h, uk_m)
    h      = adj_h - (us_anchored ? us_gap : 0)
    t      = timestamp("Europe/London", year(ref_now, "Europe/London"), month(ref_now, "Europe/London"), dayofmonth(ref_now, "Europe/London"), h, adj_m)
    line.new(t, high, t, low, xloc = xloc.bar_time, extend = extend.both, color = ln_color, width = ln_width, style = ln_style)

// News-event line at a UK time, for the custom instruments (XTI is the only caller). Same
// UK-anchored approach as draw_uk_open_line, in NEWS STYLING. draw_news_line cannot be reused
// for the same reason draw_open_line could not: it subtracts a NY offset from the bar's own
// exchange clock, which is only valid on NY-based symbols and lands hours out on any other tz.
// TODAY ONLY — there is deliberately no historical counterpart, matching how every
// forex news line already behaves (see the "today only" blocks below).
draw_uk_news_line(uk_h, uk_m, us_anchored, ln_color, ln_width) =>
    us_gap = 5 - lon_ukus_time_difference
    [adj_h, adj_m] = adjust_for_tf(uk_h, uk_m)
    h      = adj_h - (us_anchored ? us_gap : 0)
    t      = timestamp("Europe/London", year(ref_now, "Europe/London"), month(ref_now, "Europe/London"), dayofmonth(ref_now, "Europe/London"), h, adj_m)
    line.new(t, high, t, low, xloc = xloc.bar_time, extend = extend.both, color = ln_color, width = ln_width, style = line.style_solid)

// Historical counterpart of draw_uk_open_line — matches the bar in UK time.
draw_uk_open_hist(uk_h, uk_m, us_anchored, ln_color, ln_width, ln_style) =>
    us_gap = 5 - lon_ukus_time_difference
    [adj_h, adj_m] = adjust_for_tf(uk_h, uk_m)
    h      = adj_h - (us_anchored ? us_gap : 0)
    if hour(time, "Europe/London") == h and minute(time, "Europe/London") == adj_m
        line.new(bar_index, high, bar_index, low, extend = extend.both, color = ln_color, width = ln_width, style = ln_style)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TODAY'S LINES (drawn once, on the yesterday->today roll)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NOT A BUG — do not re-flag (confirmed 2026-08-01). This block fires on the previous-day
// -> today roll, so it needs a bar dated the CALENDAR day before today to trigger. On a
// Monday that calendar day is SUNDAY. The index feeds that draw here (DE40/UK100/XTI on
// IC Markets) INCLUDE Sunday-evening bars, so a Sunday-dated bar exists, the roll fires and
// Monday's lines draw normally. An audit will keep "spotting" that a Fri->Mon gap would
// skip Monday's lines — that gap does not exist on these feeds. Leave as-is.
var bool today_drawn = false

if is_yesterday and is_1h_or_below and not today_drawn
    today_drawn := true

    // Market opens draw on the standard (non-special) symbols only.
    if show_0800_open and not is_special
        draw_open_line(8, 0, lon_ukus_time_difference)
    if show_1430_open and not is_special
        draw_open_line(14, 30, 5)

    // DE40 market open — 08:00 UK ONLY (the European open, fixed), drawn through the
    // UK-anchored path so it lands correctly on the Berlin exchange clock. London-morning
    // only: no 14:30 US-cash open on DE40 (trade US equities in the US session instead).
    if is_de40 and show_0800_open
        draw_uk_open_line(8, 0, false, final_de40_open, de40_open_thickness, de40_open_style)

    // UK100 market open — 08:00 London ONLY (European, fixed), drawn through the same
    // UK-anchored path DE40 uses so it lands correctly on the feed's own exchange clock.
    // London-morning only: no 14:30 US-cash open on UK100.
    if is_uk100 and show_0800_open
        draw_uk_open_line(8, 0, false, final_uk100_open, uk100_open_thickness, uk100_open_style)

    // XTI market open — 14:30 NY equities open ONLY (no 08:00 line), US-anchored (shifts on
    // the 5/4 toggle). Drawn through the same UK-anchored path DE40 uses, in the shared
    // MARKET OPEN styling. Gated by the existing show_1430_open toggle.
    if is_xti and show_1430_open
        draw_uk_open_line(14, 30, true, final_open_color, open_thickness, open_style)

    // GBP news — today only, GBPUSD only
    if is_gbp_pair and not is_special
        if show_0700_gbp
            draw_news_line(7, 0, lon_ukus_time_difference)
        if show_0930_gbp
            draw_news_line(9, 30, lon_ukus_time_difference)
        if show_1200_gbp
            draw_news_line(12, 0, lon_ukus_time_difference)

    // EUR news — today only, EUR-base pairs
    if is_eur_pair and not is_special
        if show_0830_eur
            draw_news_line(8, 30, lon_ukus_time_difference)
        if show_1315_eur
            draw_news_line(13, 15, lon_ukus_time_difference)

    // XTI USD news — today only. is_special suppresses the forex USD-news block below, so the
    // USD lines are drawn explicitly here through the UK-anchored path (correct on any exchange
    // tz), all US-anchored, in the shared NEWS STYLING. Each gated by its existing USD toggle.
    // GBP/EUR news stay off XTI.
    if is_xti
        if show_1315_us
            draw_uk_news_line(13, 15, true, final_news_color, news_thickness)
        if show_1330_us
            draw_uk_news_line(13, 30, true, final_news_color, news_thickness)
        if show_1445_us
            draw_uk_news_line(14, 45, true, final_news_color, news_thickness)
        if show_1500_us
            draw_uk_news_line(15, 0, true, final_news_color, news_thickness)
        if show_1900_us
            draw_uk_news_line(19, 0, true, final_news_color, news_thickness)
        if show_1930_us
            draw_uk_news_line(19, 30, true, final_news_color, news_thickness)

    // USD news — today only, EURUSD, USDJPY, AUDUSD, GBPUSD, XAUUSD
    if is_usd_pair and not is_special
        if show_1315_us
            draw_news_line(13, 15, lon_ukus_time_difference)
        if show_1330_us
            draw_news_line(13, 30, lon_ukus_time_difference)
        if show_1445_us
            draw_news_line(14, 45, lon_ukus_time_difference)
        if show_1500_us
            draw_news_line(15, 0, lon_ukus_time_difference)
        if show_1900_us
            draw_news_line(19, 0, lon_ukus_time_difference)
        if show_1930_us
            draw_news_line(19, 30, lon_ukus_time_difference)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HISTORICAL LINES (prior days, drawn on the matching bar)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if show_history and is_1h_or_below and not is_today and hist_within_range

    h_0800_hr   = 8  - lon_ukus_time_difference
    h_1430_hr   = 14 - 5
    h_1430_min  = 30

    if timeframe.period == "60" and h_1430_min == 30
        h_1430_min := 0

    cur_h = hour(time)
    cur_m = minute(time)

    if show_0800_open and not is_special and cur_h == h_0800_hr and cur_m == 0
        line.new(bar_index, high, bar_index, low, extend = extend.both, color = final_open_color, width = open_thickness, style = open_style)
    if show_1430_open and not is_special and cur_h == h_1430_hr and cur_m == h_1430_min
        line.new(bar_index, high, bar_index, low, extend = extend.both, color = final_open_color, width = open_thickness, style = open_style)

    // DE40 market open (historical) — 08:00 ONLY, UK-anchored counterpart of the block above.
    if is_de40 and show_0800_open
        draw_uk_open_hist(8, 0, false, final_de40_open, de40_open_thickness, de40_open_style)

    // UK100 market open (historical) — 08:00 ONLY, UK-anchored counterpart of the block above.
    if is_uk100 and show_0800_open
        draw_uk_open_hist(8, 0, false, final_uk100_open, uk100_open_thickness, uk100_open_style)

    // XTI market open (historical) — 14:30 NY open only, US-anchored, shared MARKET OPEN styling.
    if is_xti and show_1430_open
        draw_uk_open_hist(14, 30, true, final_open_color, open_thickness, open_style)
````
