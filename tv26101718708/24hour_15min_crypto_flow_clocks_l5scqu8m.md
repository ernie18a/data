# 24-Hour 15-Min Crypto Flow + Clocks 

- url: https://www.tradingview.com/script/l5sCqU8M-24-Hour-15-Min-Crypto-Flow-Clocks/
- type: indicator
- pine_id: PUB;af13fcfbad364ead88eee2957975cdac
- version: 2.0

## Description

Overview
The 24-Hour 15-Min Crypto Flow indicator is designed specifically for 24/7 crypto day traders who execute around key market session opens, derivative funding resets, and global liquidity shifts.

It pins a live Post-It Style Banner to the top of your chart that automatically updates every 15 minutes across a full 24-hour cycle. It provides real-time market context, volatility alerts, manipulation warnings, and high-probability execution windows—paired with a complete global clock dashboard.

Key Features
✏️ 100% Customizable / Fully Editable: Every single message, 15-minute slot note, color, alignment option, and timezone input can be fully customized or rewritten in the indicator settings to align with your personal trading rules, playbook, or checklist!

📌 96 Prefilled 15-Min Crypto Market Notes: Pre-loaded with essential market dynamics across the 24-hour cycle:

Daily UTC & Funding Resets (00:00, 08:00, 16:00 UTC)

Session Opens & Initial Range Sweeps (Asia/Tokyo, Frankfurt, London, NY Open)

Opening Manipulation Traps (Judas Swings, initial 15m stop hunts)

Prime Momentum Execution Windows & Overlap Phases (London/NY Overlap)

Low-Volume Dead Zones & Lunch Chop Alerts (Avoid overtrading)

🕒 4-Zone Live Clock Dashboard: Displays Local Time, Tokyo (Asia), London, and New York directly on your chart.

⏳ Real-Time Session Open Countdowns: Shows exact time remaining (Xh Ym) until the next Asia, London, or NY market open (displays 🟢 Open during active session hours and automatically accounts for weekend closes).

⏱️ Live 15-Minute Countdown Timer: Real-time MM:SS timer showing exactly when the next market flow note will trigger.

How to Use
Add the indicator to any crypto chart (works across all timeframes, though 1m to 15m charts are recommended for day trading and scalping).

Set your Local Timezone in the indicator settings menu.

Open the indicator settings to edit any of the 96 time-slot messages to match your custom strategy or leave the defaults active.

Keep an eye on the top banner for instant session context, upcoming funding resets, and countdowns to high-volatility opens.

## Source Code

````pine
//@version=6
indicator("24-Hour 15-Min Crypto Flow + Clocks v6", overlay=true)

// --- STYLE SETTINGS ---
bannerPos = input.string("Top Center", "Banner Alignment", options=["Top Center", "Top Right", "Top Left"], group="Appearance")
noteColor = input.color(#FFF176, "Post-It Note Color", group="Appearance") // Post-It Yellow
textColor = input.color(#212121, "Text Color", group="Appearance")

// --- TIMEZONE INPUTS ---
userTz = input.string("Asia/Bangkok", "Your Local Timezone", options=["Asia/Bangkok", "UTC", "America/New_York", "Europe/London", "Asia/Tokyo", "Australia/Sydney"], group="Timezone Settings")

// --- 24-HOUR / 15-MIN CRYPTO INPUTS (LOCAL TIME BASED) ---
m00_00 = input.string("00:00 | ⚡ Midnight Local — Night session transition / quiet hours", "00:00 - 00:15", group="00:00 - 04:00")
m00_15 = input.string("00:15 | 🌙 Late Night Low Volume — Mean reversion chop", "00:15 - 00:30", group="00:00 - 04:00")
m00_30 = input.string("00:30 | 🌙 Late Night Drift — Low activity zone", "00:30 - 00:45", group="00:00 - 04:00")
m00_45 = input.string("00:45 | 🌙 Pre-Dawn Quiet — Low liquidity", "00:45 - 01:00", group="00:00 - 04:00")

m01_00 = input.string("01:00 | 🌙 Early Morning Rest — Quiet crypto market hours", "01:00 - 01:15", group="00:00 - 04:00")
m01_15 = input.string("01:15 | 🌙 Quiet Zone — Low volatility drift", "01:15 - 01:30", group="00:00 - 04:00")
m01_30 = input.string("01:30 | 🌙 Low Liquidity — Range-bound movement", "01:30 - 01:45", group="00:00 - 04:00")
m01_45 = input.string("01:45 | 🌙 Pre-Sydney Prep — Market resting", "01:45 - 02:00", group="00:00 - 04:00")

m02_00 = input.string("02:00 | 🌙 Early Sydney / Asia Open — Initial liquidity returning", "02:00 - 02:15", group="00:00 - 04:00")
m02_15 = input.string("02:15 | 🌙 Sydney Open Flow — Early Asian session movement", "02:15 - 02:30", group="00:00 - 04:00")
m02_30 = input.string("02:30 | 🌙 Early Asia Building — Checking minor range bounds", "02:30 - 02:45", group="00:00 - 04:00")
m02_45 = input.string("02:45 | 🌏 Pre-Tokyo Positioning — Desks coming online", "02:45 - 03:00", group="00:00 - 04:00")

m03_00 = input.string("03:00 | 🌏 Tokyo Pre-Market Active — Volume accelerating on Asian exchanges", "03:00 - 03:15", group="00:00 - 04:00")
m03_15 = input.string("03:15 | 🌏 Early Asia Trend Setup — Check VWAP & EMA alignment", "03:15 - 03:30", group="00:00 - 04:00")
m03_30 = input.string("03:30 | 🌏 Asia Volume Ramp — Retail & institutional flows building", "03:30 - 03:45", group="00:00 - 04:00")
m03_45 = input.string("03:45 | 🌏 15m to Tokyo Open — Finalize Asian session game plan", "03:45 - 04:00", group="00:00 - 04:00")

m04_00 = input.string("04:00 | 🌏 Tokyo Active Session — Prime Asian trading volume online", "04:00 - 04:15", group="04:00 - 08:00")
m04_15 = input.string("04:15 | 🌏 Tokyo Momentum — Sweep of previous session high/low common here", "04:15 - 04:30", group="04:00 - 08:00")
m04_30 = input.string("04:30 | 🌏 Tokyo Mid-Morning — Clean trend setups if volume holds", "04:30 - 04:45", group="04:00 - 08:00")
m04_45 = input.string("04:45 | 🌏 Asia Steady Flow — Keep position sizes disciplined", "04:45 - 05:00", group="04:00 - 08:00")

m05_00 = input.string("05:00 | 🌏 Asian Late Session — Volume begins settling into range", "05:00 - 05:15", group="04:00 - 08:00")
m05_15 = input.string("05:15 | ⚠️ Asia Range Consolidation — Avoid buying tops / selling bottoms", "05:15 - 05:30", group="04:00 - 08:00")
m05_30 = input.string("05:30 | ⚠️ Low Volatility Zone — Respect key horizontal support/resistance", "05:30 - 05:45", group="04:00 - 08:00")
m05_45 = input.string("05:45 | ⚠️ Pre-European Wind Down — Preparing for Frankfurt/London", "05:45 - 06:00", group="04:00 - 08:00")

m06_00 = input.string("06:00 | ⚡ Pre-Frankfurt Prep — Spreads and positioning adjusting", "06:00 - 06:15", group="04:00 - 08:00")
m06_15 = input.string("06:15 | 🕯️ Europe Pre-Market — European crypto desks coming online", "06:15 - 06:30", group="04:00 - 08:00")
m06_30 = input.string("06:30 | 🕯️ Pre-Europe Consolidation — Identify key Asian liquidity pools", "06:30 - 06:45", group="04:00 - 08:00")
m06_45 = input.string("06:45 | 🕯️ 15m to Frankfurt Open — Stand by for European volatility surge", "06:45 - 07:00", group="04:00 - 08:00")

m07_00 = input.string("07:00 | 🏛️ Frankfurt Open — Early European volume, watch out for Judas Swings", "07:00 - 07:15", group="04:00 - 08:00")
m07_15 = input.string("07:15 | 🏛️ Frankfurt Initial Drive — Testing key liquidity above/below range", "07:15 - 07:30", group="04:00 - 08:00")
m07_30 = input.string("07:30 | 🏛️ Pre-London Reversal Window — Watch for fake break resets", "07:30 - 07:45", group="04:00 - 08:00")
m07_45 = input.string("07:45 | 🚨 15m to London Start — Clear bad orders, prep for high volatility", "07:45 - 08:00", group="04:00 - 08:00")

m08_00 = input.string("08:00 | 🚀 LONDON SESSION START — High Volume Surge! Judas Swing / Sweep phase", "08:00 - 08:15", group="08:00 - 12:00")
m08_15 = input.string("08:15 | 🚨 London First 15m Manipulation — Beware immediate breakout traps", "08:15 - 08:30", group="08:00 - 12:00")
m08_30 = input.string("08:30 | ✅ Resume Normal Trading — True London trend direction establishing", "08:30 - 08:45", group="08:00 - 12:00")
m08_45 = input.string("08:45 | 🔥 London Trend Execution — High-probability trend continuation window", "08:45 - 09:00", group="08:00 - 12:00")

m09_00 = input.string("09:00 | 🔥 Prime London Window — Solid volume & clear trend expansion", "09:00 - 09:15", group="08:00 - 12:00")
m09_15 = input.string("09:15 | 🔥 London Trend Continuation — Look for 15m pullback setups to VWAP", "09:15 - 09:30", group="08:00 - 12:00")
m09_30 = input.string("09:30 | 🔥 London Momentum Phase — Trail stops tightly, target key daily levels", "09:30 - 09:45", group="08:00 - 12:00")
m09_45 = input.string("09:45 | ⚡ Funding Rate Window — Prep for funding rate reset & spikes", "09:45 - 10:00", group="08:00 - 12:00")

m10_00 = input.string("10:00 | ⚡ Funding Reset — Perpetual funding rate settlement & rebalancing", "10:00 - 10:15", group="08:00 - 12:00")
m10_15 = input.string("10:15 | 🥪 London Lunch Starting — Volume beginning to drop, expect range chop", "10:15 - 10:30", group="08:00 - 12:00")
m10_30 = input.string("10:30 | 🥪 London Lunch Chop — Low liquidity, avoid overtrading middle of range", "10:30 - 10:45", group="08:00 - 12:00")
m10_45 = input.string("10:45 | 🥪 London Returning — Pre-US positioning starting to build", "10:45 - 11:00", group="08:00 - 12:00")

m11_00 = input.string("11:00 | 🔔 US Pre-Market Open — Macro news & US data releases often drop here", "11:00 - 11:15", group="08:00 - 12:00")
m11_15 = input.string("11:15 | 🔔 NY Pre-Market Volatility — London/NY Overlap volume building", "11:15 - 11:30", group="08:00 - 12:00")
m11_30 = input.string("11:30 | ⚠️ US TradFi Equities Pre-Open — Spreads expanding on perpetual swaps", "11:30 - 11:45", group="08:00 - 12:00")
m11_45 = input.string("11:45 | ⚠️ 15m to Wall Street Open — Mark London High / Low targets", "11:45 - 12:00", group="08:00 - 12:00")

m12_00 = input.string("12:00 | ⚡ US TRADFI / NY OPEN — Maximum Global Liquidity! Volatility spike", "12:00 - 12:15", group="12:00 - 16:00")
m12_15 = input.string("12:15 | 🚨 NY First 15m Manipulation — Aggressive leverage & stop sweeps", "12:15 - 12:30", group="12:00 - 16:00")
m12_30 = input.string("12:30 | ✅ Resume Normal Trading — NY direction settling after opening chaos", "12:30 - 12:45", group="12:00 - 16:00")
m12_45 = input.string("12:45 | 🔥 NY Prime Overlap Window — Highest volume & cleanest moves of the day", "12:45 - 13:00", group="12:00 - 16:00")

m13_00 = input.string("13:00 | 🔥 Peak London/NY Overlap — Strong momentum across BTC/SOL/ETH", "13:00 - 13:15", group="12:00 - 16:00")
m13_15 = input.string("13:15 | 🔥 Overlap Trend Expansion — Stick to high-TF bias & VWAP trend", "13:15 - 13:30", group="12:00 - 16:00")
m13_30 = input.string("13:30 | 🎯 Crypto Silver Bullet Window — Reversal / Liquidity grab opportunity", "13:30 - 13:45", group="12:00 - 16:00")
m13_45 = input.string("13:45 | 🔒 Overlap Peak Ending — Take partial profits ahead of London close", "13:45 - 14:00", group="12:00 - 16:00")

m14_00 = input.string("14:00 | 🏛️ London Session Close — European institutional rebalancing & profit taking", "14:00 - 14:15", group="12:00 - 16:00")
m14_15 = input.string("14:15 | 🏛️ Post-London Fix — European volume exits, price stabilizes", "14:15 - 14:30", group="12:00 - 16:00")
m14_30 = input.string("14:30 | 🥪 NY Lunch Break Starting — Drop in volume, tendency for range chop", "14:30 - 14:45", group="12:00 - 16:00")
m14_45 = input.string("14:45 | 🥪 NY Lunch Dead Zone — Low volume, beware fake breakout attempts", "14:45 - 15:00", group="12:00 - 16:00")

m15_00 = input.string("15:00 | 🥪 NY Mid-Lunch Chop — Stand on hands, avoid overtrading noise", "15:00 - 15:15", group="12:00 - 16:00")
m15_15 = input.string("15:15 | 🥪 Late NY Lunch — Low liquidity zone, wait for afternoon volume", "15:15 - 15:30", group="12:00 - 16:00")
m15_30 = input.string("15:30 | ☀️ NY Traders Returning — Order book liquidity building back up", "15:30 - 15:45", group="12:00 - 16:00")
m15_45 = input.string("15:45 | ☀️ Pre-NY Afternoon Session — Prepare for secondary daily leg", "15:45 - 16:00", group="12:00 - 16:00")

m16_00 = input.string("16:00 | ☀️ NY Afternoon Expansion — Clean trend moves if daily direction is clear", "16:00 - 16:15", group="16:00 - 20:00")
m16_15 = input.string("16:15 | ☀️ NY Afternoon Momentum — Watch 15m 9/20 EMA retests for entries", "16:15 - 16:30", group="16:00 - 20:00")
m16_30 = input.string("16:30 | ☀️ NY Late Drive — Final institutional pushes before US stock close", "16:30 - 16:45", group="16:00 - 20:00")
m16_45 = input.string("16:45 | 🎯 NY Power Hour — High volatility in crypto as TradFi closes", "16:45 - 17:00", group="16:00 - 20:00")

m17_00 = input.string("17:00 | ⌛ Hour Before Stock Close — Rebalancing flows, trail stops closely", "17:00 - 17:15", group="16:00 - 20:00")
m17_15 = input.string("17:15 | ⌛ NY Late Wind Down — Avoid entering fresh swing positions here", "17:15 - 17:30", group="16:00 - 20:00")
m17_30 = input.string("17:30 | ⚠️ US Equity Market Close — Market on Close imbalances & volatility", "17:30 - 17:45", group="16:00 - 20:00")
m17_45 = input.string("17:45 | 🔒 NY Close Complete — Take profit on day scalps", "17:45 - 18:00", group="16:00 - 20:00")

m18_00 = input.string("18:00 | ⚡ 18:00 Funding Reset — Perpetual funding rate settlement & rebalancing", "18:00 - 18:15", group="16:00 - 20:00")
m18_15 = input.string("18:15 | 🌆 US Evening Session — Crypto liquidity drops into low gear", "18:15 - 18:30", group="16:00 - 20:00")
m18_30 = input.string("18:30 | 😴 Evening Slow Zone — Low volume drift across major pairs", "18:30 - 18:45", group="16:00 - 20:00")
m18_45 = input.string("18:45 | 😴 Dead Zone — Choppy price action, clean setups rare", "18:45 - 19:00", group="16:00 - 20:00")

m19_00 = input.string("19:00 | 😴 US Evening Chop — Stand by, low volume mean-reversion", "19:00 - 19:15", group="16:00 - 20:00")
m19_15 = input.string("19:15 | 😴 Dead Zone — Avoid overtrading chop, review trading journal", "19:15 - 19:30", group="16:00 - 20:00")
m19_30 = input.string("19:30 | 😴 Slow Volume — Range-bound movement dominant", "19:30 - 19:45", group="16:00 - 20:00")
m19_45 = input.string("19:45 | 😴 Pre-Evening Drift — Market transitioning", "19:45 - 20:00", group="16:00 - 20:00")

m20_00 = input.string("20:00 | ⚡ NYSE MARKET OPEN / EVENING FLOW — Prime local evening trading window", "20:00 - 20:15", group="20:00 - 24:00")
m20_15 = input.string("20:15 | ⚡ NY Open Volatility — Active momentum on major crypto pairs", "20:15 - 20:30", group="20:00 - 24:00")
m20_30 = input.string("20:30 | ⚡ NY Open Initial Drive — Testing key breakout levels", "20:30 - 20:45", group="20:00 - 24:00")
m20_45 = input.string("20:45 | ⚡ Post-Open Settling — Watch for continuation or fade", "20:45 - 21:00", group="20:00 - 24:00")

m21_00 = input.string("21:00 | 🔥 Active Evening Window — High-probability trend execution", "21:00 - 21:15", group="20:00 - 24:00")
m21_15 = input.string("21:15 | 🔥 Evening Trend Momentum — Look for 15m pullback setups to VWAP", "21:15 - 21:30", group="20:00 - 24:00")
m21_30 = input.string("21:30 | 🔥 Prime Volatility Phase — Trail stops tightly", "21:30 - 21:45", group="20:00 - 24:00")
m21_45 = input.string("21:45 | 🌙 Late Evening Transition — Volume stabilizing", "21:45 - 22:00", group="20:00 - 24:00")

m22_00 = input.string("22:00 | 🌙 Night Session Start — Steady flow, managing open positions", "22:00 - 22:15", group="20:00 - 24:00")
m22_15 = input.string("22:15 | 🌙 Night Drift — Range-bound movement dominant", "22:15 - 22:30", group="20:00 - 24:00")
m22_30 = input.string("22:30 | 🌙 Late Night Slow Zone — Low volatility drift", "22:30 - 22:45", group="20:00 - 24:00")
m22_45 = input.string("22:45 | 🌙 Pre-Midnight Wind Down — Lock in day profits", "22:45 - 23:00", group="20:00 - 24:00")

m23_00 = input.string("23:00 | ⚡ Daily UTC Close Approaching — Spreads may widen, review daily candle", "23:00 - 23:15", group="20:00 - 24:00")
m23_15 = input.string("23:15 | 🏁 Late Night Prep — Managing leverage ahead of midnight", "23:15 - 23:30", group="20:00 - 24:00")
m23_30 = input.string("23:30 | 🏁 Midnight Close — High-TF daily candle closing volatility", "23:30 - 23:45", group="20:00 - 24:00")
m23_45 = input.string("23:45 | 🚨 Midnight Reset — Daily candle rollover & funding check", "23:45 - 00:00", group="20:00 - 24:00")

// --- TIME CALCULATIONS (LOCAL TIME MAPPING) ---
locH = hour(timenow, userTz)
locM = minute(timenow, userTz)
locStr = str.format("{0,number,00}:{1,number,00}", locH, locM)

// Maps local time directly to array index slots so 20:28 points to m20_15
slotIndex = (locH * 4) + math.floor(locM / 15)

tokH = hour(timenow, "Asia/Tokyo")
tokM = minute(timenow, "Asia/Tokyo")
tokDOW = dayofweek(timenow, "Asia/Tokyo")
tokStr = str.format("{0,number,00}:{1,number,00}", tokH, tokM)

lonH = hour(timenow, "Europe/London")
lonM = minute(timenow, "Europe/London")
lonDOW = dayofweek(timenow, "Europe/London")
lonStr = str.format("{0,number,00}:{1,number,00}", lonH, lonM)

nyH = hour(timenow, "America/New_York")
nyM = minute(timenow, "America/New_York")
nyDOW = dayofweek(timenow, "America/New_York")
nyStr = str.format("{0,number,00}:{1,number,00}", nyH, nyM)

// --- ARRAY OF 96 PREFILLED NOTES ---
var string[] notes = array.new_string(96)

if barstate.isfirst
    array.set(notes, 0, m00_00), array.set(notes, 1, m00_15), array.set(notes, 2, m00_30), array.set(notes, 3, m00_45)
    array.set(notes, 4, m01_00), array.set(notes, 5, m01_15), array.set(notes, 6, m01_30), array.set(notes, 7, m01_45)
    array.set(notes, 8, m02_00), array.set(notes, 9, m02_15), array.set(notes, 10, m02_30), array.set(notes, 11, m02_45)
    array.set(notes, 12, m03_00), array.set(notes, 13, m03_15), array.set(notes, 14, m03_30), array.set(notes, 15, m03_45)
    array.set(notes, 16, m04_00), array.set(notes, 17, m04_15), array.set(notes, 18, m04_30), array.set(notes, 19, m04_45)
    array.set(notes, 20, m05_00), array.set(notes, 21, m05_15), array.set(notes, 22, m05_30), array.set(notes, 23, m05_45)
    array.set(notes, 24, m06_00), array.set(notes, 25, m06_15), array.set(notes, 26, m06_30), array.set(notes, 27, m06_45)
    array.set(notes, 28, m07_00), array.set(notes, 29, m07_15), array.set(notes, 30, m07_30), array.set(notes, 31, m07_45)
    array.set(notes, 32, m08_00), array.set(notes, 33, m08_15), array.set(notes, 34, m08_30), array.set(notes, 35, m08_45)
    array.set(notes, 36, m09_00), array.set(notes, 37, m09_15), array.set(notes, 38, m09_30), array.set(notes, 39, m09_45)
    array.set(notes, 40, m10_00), array.set(notes, 41, m10_15), array.set(notes, 42, m10_30), array.set(notes, 43, m10_45)
    array.set(notes, 44, m11_00), array.set(notes, 45, m11_15), array.set(notes, 46, m11_30), array.set(notes, 47, m11_45)
    array.set(notes, 48, m12_00), array.set(notes, 49, m12_15), array.set(notes, 50, m12_30), array.set(notes, 51, m12_45)
    array.set(notes, 52, m13_00), array.set(notes, 53, m13_15), array.set(notes, 54, m13_30), array.set(notes, 55, m13_45)
    array.set(notes, 56, m14_00), array.set(notes, 57, m14_15), array.set(notes, 58, m14_30), array.set(notes, 59, m14_45)
    array.set(notes, 60, m15_00), array.set(notes, 61, m15_15), array.set(notes, 62, m15_30), array.set(notes, 63, m15_45)
    array.set(notes, 64, m16_00), array.set(notes, 65, m16_15), array.set(notes, 66, m16_30), array.set(notes, 67, m16_45)
    array.set(notes, 68, m17_00), array.set(notes, 69, m17_15), array.set(notes, 70, m17_30), array.set(notes, 71, m17_45)
    array.set(notes, 72, m18_00), array.set(notes, 73, m18_15), array.set(notes, 74, m18_30), array.set(notes, 75, m18_45)
    array.set(notes, 76, m19_00), array.set(notes, 77, m19_15), array.set(notes, 78, m19_30), array.set(notes, 79, m19_45)
    array.set(notes, 80, m20_00), array.set(notes, 81, m20_15), array.set(notes, 82, m20_30), array.set(notes, 83, m20_45)
    array.set(notes, 84, m21_00), array.set(notes, 85, m21_15), array.set(notes, 86, m21_30), array.set(notes, 87, m21_45)
    array.set(notes, 88, m22_00), array.set(notes, 89, m22_15), array.set(notes, 90, m22_30), array.set(notes, 91, m22_45)
    array.set(notes, 92, m23_00), array.set(notes, 93, m23_15), array.set(notes, 94, m23_30), array.set(notes, 95, m23_45)

currentNote = array.get(notes, slotIndex)

// --- COUNTDOWN HELPER FUNCTION ---
f_getCountdown(int currentH, int currentM, int openH, int openM, int closeH, int closeM, int dow) =>
    isWknd = (dow == dayofweek.saturday or dow == dayofweek.sunday)
    string res = ""
    if isWknd
        res := "Closed (Wknd)"
    else
        currMin = currentH * 60 + currentM
        opMin   = openH * 60 + openM
        clMin   = closeH * 60 + closeM
        if currMin >= opMin and currMin < clMin
            res := "🟢 Open"
        else
            diff = currMin < opMin ? opMin - currMin : (24 * 60 - currMin) + opMin
            hDiff = math.floor(diff / 60)
            mDiff = diff % 60
            res := str.format("Open in {0}h {1}m", hDiff, mDiff)
    res

// --- SESSION COUNTDOWNS ---
asiaCd = f_getCountdown(tokH, tokM, 9, 0, 15, 0, tokDOW)
londonCd = f_getCountdown(lonH, lonM, 8, 0, 16, 30, lonDOW)
nyCd = f_getCountdown(nyH, nyM, 9, 30, 16, 0, nyDOW)

// --- 15-MINUTE NOTE COUNTDOWN (MM:SS) ---
timeMs = timenow
fifteenMinMs = 15 * 60 * 1000
msRemaining = fifteenMinMs - (timeMs % fifteenMinMs)
minsLeft = math.floor(msRemaining / (60 * 1000))
secsLeft = math.floor((msRemaining % (60 * 1000)) / 1000)
cdNoteStr = str.format("{0,number,00}:{1,number,00}", minsLeft, secsLeft)

// --- DASHBOARD TEXT LINES ---
line1_Clocks = str.format("🕒 Local: {0} | 🌏 Tokyo: {1} | 🏛️ London: {2} | ⚡ NY: {3}", locStr, tokStr, lonStr, nyStr)
line2_Opens  = str.format("⏳ Asia: {0} | London: {1} | NY: {2} | 📌 Next Note: {3}", asiaCd, londonCd, nyCd, cdNoteStr)

// Position Alignment
alignPos = bannerPos == "Top Center" ? position.top_center :
           bannerPos == "Top Right" ? position.top_right : position.top_left

// --- DISPLAY TABLE ---
var table postIt = table.new(position.top_center, 1, 3)

if barstate.islast
    postIt := table.new(alignPos, 1, 3)
    table.cell(postIt, 0, 0, "📌 " + currentNote, bgcolor=noteColor, text_color=textColor, text_size=size.large)
    table.cell(postIt, 0, 1, line1_Clocks, bgcolor=color.new(#111111, 20), text_color=color.white, text_size=size.normal)
    table.cell(postIt, 0, 2, line2_Opens, bgcolor=color.new(#111111, 20), text_color=color.white, text_size=size.normal)
````
