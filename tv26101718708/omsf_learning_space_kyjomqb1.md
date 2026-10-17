# OMSF Learning Space

- url: https://www.tradingview.com/script/KYJoMqb1-OMSF-Learning-Space/
- type: indicator
- pine_id: PUB;57b330610ba34f16a0dc50a322cc8e16
- version: 6.0

## Description

Welcome to the Omsf Learning Space.

This is not a commercial "holy grail" indicator, nor is it a rigid, corporate course. This is my personal sandbox and educational archive where I dissect market structure, breakout mechanics, and reversal setups.

THE CORE PHILOSOPHY:
Everything in this space is built upon my Omsf (Objective Market Structure Framework). Whether you are a beginner trying to understand how charts breathe, or an advanced trader looking for mechanical rules – this space is designed to give you a clear, visual reality check.

WHAT TO EXPECT:
This script is dynamic and will change organically over time. As I publish new trading ideas, research notes, or structural concepts, this indicator will adapt. Old parts might get swapped out, new experiments will be added, or it might evolve into a v2.0 down the road. There is no fixed schedule. It updates when it updates.
CURRENT VERSION (Launch):
Right now, we are looking at the foundational mechanics: Classic, rigid Pivots alongside the dynamic volatility adjustment of the Omsf.
- Toggle "Exercise 1" to stress-test both engines in the configuration sandbox.
- Toggle "Outlook" to see how classic Pivots perform when taken literally as a trend filter.

Enjoy the sandbox, play with the parameters, and use the Bar Replay. See you in the ideas section!
— arni

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © arnipoer | Made in Germany 🇩🇪 ☺

//@version=6
indicator("OMSF LS update1_5", shorttitle = "OMSF LS", overlay=false, max_labels_count=500)


import arnipoer/PriceActionStructure/5 as omsf //@link https://www.tradingview.com/script/g1122Yj2/
import arnipoer/OMSF_Education_Lib/1 as ls

import arnipoer/VisualStructureTools/4 as vst //@link https://www.tradingview.com/script/RYljd98y/   
[bull_candle_color, bear_candle_color, deep_space_blue, midnight_charcoal, silk_pearl, omsf_color, omsf_bulls_color, omsf_bears_color, hyper_green_hex, laser_crimson_hex, 
     cream, mint_cyan, ice_blue, soft_coral, bears_dusk, bulls_fading, bulls_exhaustion, bulls_dawn] = vst.colorsuite()


chapter_intro(string chapter_text, color border_cl, color text_color) =>
    var table textPanel = table.new(position = position.middle_center, columns = 1, rows = 1, 
     bgcolor = color.new(#0b121f, 10), border_width = 2, border_color = border_cl)    
    table.cell(textPanel, 0, 0, chapter_text, text_color = text_color, text_size = size.normal, text_halign =  text.align_left, text_valign = text.align_top)
    
chapter_intro_overlay(string chapter_text, color border_cl) =>
    var table textPanel = table.new(position = position.middle_center, columns = 1, rows = 1, 
     bgcolor = color.new(#0b121f, 10), border_width = 2, border_color = border_cl, force_overlay = true)
    table.cell(textPanel, 0, 0, chapter_text, text_color = color.new(omsf_color, 20), text_size = size.normal, text_halign = text.align_left, text_valign = text.align_top)

chapter_intro_columns(string header, string chapter_text_1, string chapter_text_2, color border_cl, int colum) =>
    var table textPanel = table.new(position = position.middle_center, columns = colum, rows = 2, 
     bgcolor = color.new(#0b121f, 10), border_width = 0, border_color = color.new(border_cl,100))
    table.merge_cells(textPanel, 0, 0, 1, 0)
    table.cell(textPanel, 0, 0, header, height = 0, text_color = color.new(omsf_color, 20), text_size = size.normal, text_halign =  text.align_center, text_valign = text.align_bottom)
    table.cell(textPanel, 0, 1, chapter_text_1, width = 30, text_color = color.new(omsf_color, 20), text_size = size.normal, text_halign =  text.align_left, text_valign = text.align_top)
    table.cell(textPanel, 1, 1, chapter_text_2, width = 30, text_color = color.new(omsf_color, 20), text_size = size.normal, text_halign =  text.align_left, text_valign = text.align_top)
/// ==========================================
//       New Chapter Navigation
// ==========================================
gp_content = 'TABLE OF CONTENTS'
active_chapter = input.string("Chapter 5 - Max Forward- & Adverse Excursion", "Select Chapter:",
     options=['Introduction', 'Chapter 1 - What are Pivots?', 'Chapter 2 - The Omsf Structure', 'Exercise 1 - Genesis & Confirmation Dynamics', "Recapture Last Session", 
     "Chapter 3 - Introduce Kaufman Efficiency Ratio", 'Chapter 4a - Trendfilter Validation', 'Chapter 4b - OMSF Trendfilter Validation', 'Brief Conclusion / Exercise 2', 
     'Chapter 5 - Max Forward- & Adverse Excursion', 'Note on MFE/MAE visualization', 'Chapter 6 - OMSF-Break of Structure'], group = gp_content)


// ==========================================
// CHAPTER DEFINITIONS (The Matrix)
// ==========================================
intro   = (active_chapter == 'Introduction')
ch_1    = (active_chapter == 'Chapter 1 - What are Pivots?')
ch_2    = (active_chapter == 'Chapter 2 - The Omsf Structure')
exerc_1 = (active_chapter == 'Exercise 1 - Genesis & Confirmation Dynamics')
recap   = (active_chapter == "Recapture Last Session")
ch_3    = (active_chapter == "Chapter 3 - Introduce Kaufman Efficiency Ratio")
ch_4a    = (active_chapter == "Chapter 4a - Trendfilter Validation")
ch_4b    = (active_chapter == "Chapter 4b - OMSF Trendfilter Validation")
ch_4c = (active_chapter == 'Brief Conclusion / Exercise 2')
ch_5 = (active_chapter == 'Chapter 5 - Max Forward- & Adverse Excursion')
note_max_excursion = (active_chapter == 'Note on MFE/MAE visualization')
ch_6 = (active_chapter == 'Chapter 6 - OMSF-Break of Structure')

// GLOBAL OR GROUP SWITCHES
show_text  = input.bool(true, "Show Chapter Text on Chart", group=gp_content)
show_stats = input.bool(true, "Show Statistics Table", group=gp_content)
// ===============================================================================
//|             Introduction - How do you use Pivot Points?                       |
//|             Or - Are you ready to consider the OMSF?                          |
// ===============================================================================
string intro_text = "=== INTRO: HOW DO YOU USE PIVOTS? ===\n\n" +
     "Welcome to the OMSF Learning Space.\n\n" +
     "If you just loaded this chart via the idea section, you are looking at the TradingView standard:\n" +
     "----------------  Pivot Points High Low (10, 10)  ----------------\n\n" +
     "Note: If you loaded this script directly from the indicators list instead, I recommend\n" +
     "adding the built-in 'Pivot Points High Low' indicator to your chart as well for a direct comparison.\n\n" +
     "This is our baseline—where our journey begins. From here on, this script will act\n" +
     "as your interactive sandbox. \n\n" +
     "Open the settings menu to navigate through the tutorial step-by-step.\n" +
     "At the start of each chapter, a new interactive panel will guide you through the \n" +
     "concepts, showing you exactly what parameters to tweak and what to look for.\n\n" +
     "In Chapter 1, we will dissect the anatomy of standard Pivots versus OMSF Highs/Lows\n" +
     "by displaying their raw mechanics directly on the chart.\n\n" +
     "Let's see how deep the rabbit hole goes. Enjoy the ride!\n\n" +
     "— arni"
if barstate.islast and intro and show_text  
    chapter_intro(intro_text, omsf_color, color.new(omsf_color, 20))
// ===============================================================================
//|             CHAPTER 1 - WHAT ARE PIVOTS? (INTERACTIVE EDUCATION)             |
// ===============================================================================
string chapter_1_text = "=== CHAPTER 1: THE MECHANICS OF PIVOTS ===\n\n" +
 "Standard Pivot Points are built from two components based on time:\n\n" +
 "1. THE RUNNING LEVEL:\n" +
 "   The default setting for a Pivot is a length of 10. The script tracks the absolute\n" +
 "   highest high and lowest low of the trailing 10 bars.\n" +
 "   -> Check 'Show Running Pivots' in the menu to plot these dynamic boundaries.\n\n" +
 "2. THE CONFIRMATION WINDOW:\n" +
 "   A raw peak does not become an official Pivot immediately. It must survive without being\n" +
 "   broken for another 10 bars into the future before it is locked in.\n" +
 "   -> Check 'Show Confirmation Labels' to see the exact bar where this timer expires.\n\n" +
 "THE OBSERVATION:\n" +
 "Notice that the price labels are plotted retroactively on the historical peak. The validation\n" +
 "occurs 10 bars later. This represents a direct trade-off between stability and reactivity.\n\n" +
 "---------------------------------------------------------------------------------\n" +
 "NEXT STEP: Uncheck Chapter 1 and open Chapter 2 in the menu to look at the structural concept of the OMSF."
if barstate.islast and ch_1 and show_text 
    chapter_intro(chapter_1_text, omsf_color, color.new(omsf_color, 20))
///______________________________________________________________________________
//|                 Chapter 2 - The Omsf Structure                               |
//|______________________________________________________________________________|
string chapter_2_text = "=== CHAPTER 2: THE OMSF ENGINE ===\n" +
 "You are looking at OMSF structural Highs/Lows alongside standard Pivots. You will notice more OMSF levels. As you will see,\n" +
 " 'more' is not automatically better—it is just a different approach. So here is how OMSF Data Points are calculated:\n\n" +
 "1. THE MOVEMENTS & RUNNING PEAKS:\n" +
 " The OMSF defines the market as either an 'upMove' or 'downMove'. An upMove triggers when a bullish candle closes above the high of the previous candle (and vice versa for downMove).\n" +
 " Once an upMove starts, the highest point becomes the 'Running Peak'. It stays active until a subsequent candle exceeds it by BOTH its high AND its candle close.\n" +
 "   -> EXERCISE: Set standard Pivots to invisible and check 'OMSF Peaks' in the settings to watch this live.\n\n" +
 "2. THE TWO-COMPONENT LOCK-IN FILTER:\n" +
 " Turning a Running Peak into a validated structural point is multi-layered:\n" +
 "   - COMPONENT A (Volatility Distance): The price distance from peakHigh to the last validated structural Low must be at least 1.5 * ATR(14) by default.\n" +
 "   - COMPONENT B (Momentum Second Chance): If the distance is smaller, it gets a backup validation. If a single candle body is larger than 1 * ATR(14), the peak is locked in anyway.\n" +
 "   -> EXERCISE: Check 'Label OMSF Confirmation' to visualize the validation speed.\n" +
 "---------------------------------------------------------------------------------------------------\n" +
 "OBSERVATION & NEXT STEP:\n" +
 "This shows how large ranges are confirmed instantly upon reversal, while small structures are often delayed and registered via momentum (large bodies). I am sure you see it now.\n" +
 "Close Chapter 2 and open 'Exercise 1' in the settings for a deeper mathematical look (if you are still here... ;))."
if barstate.islast and ch_2 and show_text 
    chapter_intro(chapter_2_text, omsf_color, color.new(omsf_color, 20))
 
 
//_______________________________________________________________________________
//|                 Exercise 1 - Genesis & Confirmation Dynamics                |
//|______________________________________________________________________________|
string exercise_1_text = "=== EXERCISE 1: THE CONFIGURATION SANDBOX ===\n" +
 "The running peakHigh/peakLow and the time-based ta.highest(high)/lowest(low) lines have\n" +
 "been replaced by the actual confirmed OMSF structure and the last active Pivot plot.\n" +
 "All price labels are gone—only the true struct-onset is still marked. Time to play with the parameters.\n\n" +
 "RECOMMENDED EXPERIMENTS:\n" +
 "1. TEST THE OMSF MOMENTUM ENGINE:\n" +
 "   -> Set the 'Compression Threshold' to a high value like 4.0 ATR. The volatility filter\n" +
 "      now triggers on almost every change of direction (upMove/downMove).\n" +
 "   -> Adjust the 'Momentum Threshold' to 2.0 or 2.5 ATR to match this scale. As a result, the\n" +
 "      engine demands massive force to lock in a level, creating wide, dominant structural ranges.\n" +
 "   -> Toggle the 'Momentum Filter' completely OFF. Notice how the structure instantly fragments\n" +
 "      into tight, narrow ranges and total data points multiply. This happens because without the\n" +
 "      filter, every single change of direction immediately defines a new structure.\n\n" +
 "2. TEST CLASSIC PIVOT TIME-LAG:\n" +
 "   -> Increase the Right Length in steps of 10 or more. Notice how the ranges widen and hold\n" +
 "      their levels much longer, while the table shows a massive jump in the confirmation lag.\n" +
 "   -> Decrease both Left and Right lengths. The structure becomes highly reactive and granular,\n" +
 "      but it will constantly flip-flop on minor intraday noise.\n\n" +
 "-------------------------------------------------------------------------------------------------\n" +
 "Take your time using the Bar Replay. Clean up the view by toggling specific plots or hiding\n" +
 "the table if needed. Experienced quants will already see the endless strategic possibilities\n" +
 "opening up for rule-based systems. Once you have a feel for the mechanics, move to the recap."
if barstate.islast and exerc_1 and show_text
    chapter_intro(exercise_1_text, omsf_color, color.new(omsf_color, 20))
//   ____________________________________________________________________________
//  |                                RECAPTURE LAST SESSION                      |
//  |____________________________________________________________________________|
string recap_text = "=== RECAPTURE LAST SESSION ===\n\n" +
 "By now, you understand the mechanics behind Pivot Points High/Low and the OMSF structure.\n" +
 "In the exercise, you saw the last active Pivot plotted on the chart. To turn this into a functional\n" +
 "trend filter, I simply mapped the active states and painted the areas green and red.\n\n" +
 "MY FIRST IMPRESSIONS & YOUR SANDBOX:\n" +
 "Go ahead and use the new menu (I hope you like it! 😉) to shorten the right lengths.\n" +
 "You will notice a faster reaction. From my first impressions, this simple filter looks\n" +
 "surprisingly robust—considering how incredibly simple the concept behind it is.\n\n" +
 "YOUR TASK:\n" +
 "Take some time to get familiar with this Pivot Trend Filter before we dive into the promised KER chapter.\n" +
 "Vary the lengths, timeframes, and assets to see how it behaves.\n\n" +
 "I have shared my personal impressions in more detail on my profile under the Ideas tab\n" +
 "(\"Rethinking Market Structure — Part 2: Taking Pivots Literally\"). Check it out if you want to dive deeper.\n\n" +
 "See you in the KER lesson!\n" +
 "— arni"
if barstate.islast and recap and show_text
    chapter_intro(recap_text, omsf_color, color.new(omsf_color, 20))

// ===============================================================================
//|          Chapter 3 - KAUFMAN EFFICIENCY RATIO (KER)                          |
// ===============================================================================
string ch3_text = "=== CHAPTER 3: INTRODUCING THE KAUFMAN EFFICIENCY RATIO ===\n\n" +
 "KER is a well-known concept and is often used itself as a trend indicator.\n\n" +
 "THE MATHEMATICAL CONCEPT:\n" +
 "KER = (Close - Close[14]) / math.sum(math.abs(Close - Close[1]), 14)\n\n" +
 "The KER measures, on one hand, the direction of the price movement:\n" +
 "With a set length of 14, we calculate the difference between the last 14 closing prices.\n" +
 "The sign (+/-) instantly delivers the direction. The denominator sums up all absolute\n" +
 "movements from bar to bar. The final value is always between -1.0 and +1.0, where\n" +
 "values towards 1 indicate an efficient upward movement and values towards -1 indicate\n" +
 "an efficient downward movement. The oscillator in the panel below tracks the KER continuously.\n" +
 "NOTE: The EFFICIENCY means whether the price got from A to B without making big detours.\n" +
 "The formula completely ignores the absolute strength or steepness.\n\n" +
 "WHY CAN THE KER VALIDATE OUR PIVOT FILTER?\n" +
 "Because the KER captures essential characteristics of market structure: In an uptrend,\n" +
 "we expect the price to rise, and vice versa, to fall in a downtrend. In an uptrend, one\n" +
 "should also recognize more clear upward movements than in a downtrend – right?\n" +
 "If our pivot filter is also sensitive to the trend direction, both concepts should\n" +
 "harmonize in a certain way. And that this is actually the case, you will see immediately\n" +
 "when you turn off the text box in the settings...\n\n" +
 "If you vary the lengths for KER and Pivot High/Low in the settings, however, things get\n" +
 "more complicated. Try it out while I prepare Chapter 4 – where we back up our\n" +
 "impressions with simple numbers.\n\n" +
 "— arni"
if barstate.islast and ch_3 and show_text
    chapter_intro_overlay(ch3_text, omsf_color)

// ===============================================================================
//|                  CHAPTER 4a - TRENDFILTER VALIDATION                          |
// ===============================================================================
string ch4a_header = "=== CHAPTER 4a: VALIDATING PIVOTS WITH NUMBERS ===\n"

string ch4a_text_1 = 
 "Okay. Let's try to confirm our visual impression\n" +
 "with data... You should now see a table centered\n" + 
 "above the chart. If not, go to the indicator settings\n" + 
 "and click 'Reset settings' at the very bottom of the\n" + 
 "menu in the 'Default values' section.\n\n" +
 "The table shows the average KER, broken down by our\n" + 
 "pivot filter conditions: 'Uptrend' and 'Downtrend'.\n" +
 "I based my observations on the NASDAQ100 chart\n" +
 "using the 2-hour (H2) timeframe. It is best to open\n" +
 "this underlying asset in the H2 timeframe as well, with\n" + 
 "a pivot length of 10 and a KER period of 14.\n\n" +
 "For the 'Long' pivot condition, you should see an\n" +
 "average KER of around 0.2, and for the 'Short'\n" +
 "condition, around -0.1. In higher timeframes\n" +
 "(H1 and above), you will observe roughly the same pat-\n" +
 "tern with liquid stock indices such as the NASDAQ100,\n" +
 "US500, UK100, GER40, as well as the JP225 and even\n" + 
 "the EU50. Even though these values may not seem high,\n" + 
 "their stability indicates statistical significance.\n\n" +
 "Also of interest: If one looks instead at liquid Forex\n" +
 "markets (e.g., EURUSD, EURGBP, GBPCHF, USDCHF),"

string ch4a_text_2 = 
 "this asymmetry disappears, and one sees values of\n" + 
 "approximately 0.13 versus -0.13. While stock markets\n" + 
 "exhibit a structural upward tendency (long bias) and\n" + 
 "corrections tend to be more volatile and less linear\n" + 
 "than upward movements, our table here seems to\n" + 
 "reflect the Forex markets' tendency toward mean re-\n" + 
 "version.\n\n" +
 "Increase the KER period to 27 in the settings. KER now\n" + 
 "captures the overall trend and the table values decrease.\n" +
 "Now gradually increase the right-side lengths for\n" + 
 "Pivot High and Low equally. The average KER values in\n" + 
 "the table should now rise. For US100/H2, I found an\n" + 
 "optimum pivot confirmation length of 17. Meaning that\n" + 
 "beyond this point, the table values no longer 'improve'.\n\n" + 
 "Now gradually increase the pivot confirmation duration\n" + 
 "(right-side length) for Pivot High and decrease it for\n" + 
 "Pivot Low by 1 in each case. You will see that the asym-\n" + 
 "metry between the uptrend and downtrend conditions\n" + 
 "decreases.\n\n" + 
 "Can we observe something similar with the OMSF?\n" + 
 "... Proceed to Chapter 4b ..."

// --- Render Call ---
if barstate.islast and ch_4a and show_text
    chapter_intro_columns(ch4a_header, ch4a_text_1, ch4a_text_2, omsf_color, 2)
// ===============================================================================
//|                  CHAPTER 4b - OMSF TRENDFILTER VALIDATION                    |
// ===============================================================================
// --- Chapter 4b Strings for Two-Column Layout (47-50 chars/line) ---
string ch4b_header = "=== CHAPTER 4b: THE OMSF ENGINE COMPARISON ===\n"

string ch4b_text_1 = 
 "On the chart, you can see an OMSF equivalent of the\n" +
 "Pivot filter: I have never used the OMSF way before\n" + 
 "and wanted to establish a basis for comparison. The\n" +
 "OMSF filter also has two conditions: uptrend and\n" + 
 "downtrend (where the OMSF-Low triggers the long-\n" + 
 "condition and vice versa for the short condition).\n\n" +
 "I have supplemented the table with the avg. KER for\n" +
 "OMSF uptrend/downtrend. You can see that\n" +
 "distinguishing between the upward and downward\n" +
 "conditions using KER with a length of 14 works less\n" +
 "effectively—especially for the downward condition—\n" +
 "than with the Pivot-Trendfilter. Go to the settings\n" +
 "and set the KER length to 9. KER now distinguishes\n" +
 "better between the OMSF conditions, though overall\n" +
 "still less effectively than the Pivot-Trendfilter.\n\n" +
 "What really got me thinking: Deactivate the OMSF-\n" +
 "Momentumfilter in the settings. We get even stronger\n" + 
 "differentiation via KER BUT: If we switch off the \n" +
 "OMSF filter completely and shorten the KER, in my \n" +
 "opinion, we leave the realm of trend filtering and\n" +
 "move towards momentum/impulse-measurement."

string ch4b_text_2 =   
 "Why? At KER=9, we measure a tiny price swing.\n" +
 "Since OMSF triggers on price reversals, KER is\n" +
 "almost forced to show a high positive value.\n" +
 "It frequently hits 1.0 on this short distance,\n" +
 "failing to differentiate true market structure.\n\n" +
 "Furthermore, I found no OMSF setup that works\n" +
 "with a longer KER (above 10). A macro KER (27)\n" +
 "completely desynchronizes from the OMSF engine.\n\n" +
 "Despite the differences between Pivots and OMSF,\n" + 
 "with the OMSF we also see the asymmetry in stock\n" + 
 "indices between long and short conditions—unlike\n" + 
 "in mean-reversion markets such as forex pairs.\n" + 
 "This suggests that the OMSF captures the same\n" + 
 "objective market structure as the classic Pivot.\n" + 
 "It describes the real dynamics of the market,\n" + 
 "simply using a different coordinate system.\n" + 
 "I will try to outline my thoughts in the 'Ideas'\n" + 
 "section in the next part of *Rethinking Market\n" + 
 "Structure* in greater detail.\n\n" + 
 "... Proceed to Exercise 2 / Outlook ..."

// --- Render Call ---
if barstate.islast and ch_4b and show_text
    chapter_intro_columns(ch4b_header, ch4b_text_1, ch4b_text_2, omsf_color, 2)

// ===============================================================================
//|                  CHAPTER 4c - CONCLUSION AND EXERCISE                        |
// ===============================================================================
string ch4c_header = "=== CONCLUSION & EXERCISE: KER VALIDATION ===\n"

string ch4c_text_1 = 
 "Both methods deliver relevant structural levels,\n" +
 "but Pivots seem better suited to capture the\n" +
 "current trend direction than the OMSF. We\n" +
 "cannot simply say: the price has turned, so\n" +
 "we are in a new trend.\n\n" +
 "Additionally, a highest high/lowest low of 10\n" +
 "bars — once confirmed by time (left length) —\n" +
 "provides a highly robust method to identify\n" +
 "key price and structure levels. On the chart,\n" +
 "both basic trend filters are directly juxta-\n" +
 "posed. All options are enabled in the settings,\n" +
 "allowing you to experiment and compare them."

string ch4c_text_2 = 
 "Keep in mind that both methods rely on very\n" +
 "simple principles. Looking at the chart and the\n" +
 "KER plots sparks many ideas on how to combine\n" +
 "these mechanics (including KER) to build more\n" +
 "sophisticated filters. Anyone else inspired?\n\n" +
 "Up until now, this tutorial has been quite\n" +
 "theoretical. In the next section, we will ex-\n" +
 "amine MFE and MAE and their ratio, finally\n" +
 "tackling the question we all care about most:\n" +
 "What is the actual trading potential of this?\n\n" +
 "I hope you are still on board and look forward\n" +
 "to your ideas and questions.\n\n" +
 "Cheers, arni"

// --- Render Call ---
if barstate.islast and ch_4c and show_text
    chapter_intro_columns(ch4c_header, ch4c_text_1, ch4c_text_2, omsf_color, 2)

// ===============================================================================
//|                  CHAPTER 5 -  MAX FAVORABLE- & ADVERSE EXCURSION              |
// ===============================================================================

string ch5_header = "=== CHAPTER 5: MAX FAVORABLE- & ADVERSE EXCURSION ===\n"

string ch5_text_1 = 
 "MFE and MAE describe the maximum price gains and\n" +
 "losses relative to the price when a defined\n" +
 "filter condition sets in (Long/Short states).\n" +
 "Both values are normalized by ATR (divided by ATR\n" +
 "at the onset of the condition) to enable cross-\n" +
 "asset comparisons.\n\n" +
 "On the chart, MFE and MAE of the current and\n" +
 "previous market phases are visualized. You can\n" +
 "toggle between both filters in the settings.\n\n" +
 "The table displays the average MFE and MAE upon\n" +
 "directional shifts across the entire chart\n" +
 "history. The bottom row shows the 'Potential-\n" +
 "Ratio' (PR)—the average relationship between MFE\n" +
 "and MAE:\n\n" +
 "• Potential-Ratio = 1.0 => avg. MFE = avg. MAE\n" +
 "• Potential-Ratio > 1.0 => avg. MFE > avg. MAE\n" +
 "  (and vice versa for PR < 1.0)"

string ch5_text_2 = 
 "OBSERVATIONS ACROSS ASSETS AND TIMEFRAMES:\n\n" +
 "• Pivot Filter:  PR usually sits between 1.0–1.3\n" +
 "• OMSF Filter:   PR usually sits between 1.3–1.6\n\n" +
 "However, the average excursion size in Pivot\n" +
 "conditions is roughly twice as large as that of\n" +
 "the OMSF filter. As expected from Chapter 4,\n" +
 "the OMSF filter triggers earlier and captures\n" +
 "the momentum of a directional shift more\n" +
 "effectively.\n\n" +
 "On the flip side, OMSF's faster switching prevents\n" +
 "the price from moving far against us (resulting in\n" +
 "lower MAE), but also yields smaller overall\n" +
 "excursions compared to the Pivot filter.\n\n" +
 "Proceed in the chapter selector to 'Note' to\n" +
 "read details on how to interpret the\n" +
 "MFE/MAE visualization on the chart."

// --- Render Call ---
if barstate.islast and ch_5 and show_text
    chapter_intro_columns(ch5_header, ch5_text_1, ch5_text_2, omsf_color, 2)

// ===============================================================================
//|                 Note on MFE/MAE visualization                                 |
// ===============================================================================
string note_mfe_mae_text = 
 "                     === NOTE ON VISUALIZATION & POTENTIAL RATIO ⚠️ ===\n\n" +
 "Although the visual style resembles the classic Long/Short position drawing tool, this does NOT\n" +
 "represent a Risk/Reward Ratio (RRR) of an active trading setup.\n\n" +
 "Likewise, you cannot derive a direct trading strategy solely from the average Potential Ratio.\n" +
 "The arithmetic mean is a rough estimate, and extreme upside outliers often distort the average\n" +
 "artificially.\n\n" +
 "I will dive deeper into MFE/MAE distribution elsewhere to keep this tutorial focused on the\n" +
 "essential structural basics."

// --- Render Call ---
if barstate.islast and note_max_excursion and show_text  
    chapter_intro(note_mfe_mae_text, omsf_color, color.new(soft_coral, 0))
// ===============================================================================
//|                  CHAPTER 6 - OMSF BREAKOUT BIAS (BOS)                         |
// ===============================================================================
string ch6_header = "=== CHAPTER 6: OMSF BREAKOUT BIAS (BOS) ===\n"

string ch6_text_1 = 
 "In this chapter, we explore breakout dynamics using\n" +
 "Break of Structure (BOS) events.\n\n" +
 "On the chart, the OMSF structure is colored by\n" +
 "the direction of the event (green for long, red\n" +
 "for short).\n\n" +
 "As before, a breakout transitions the state\n" +
 "machine: 'breakout_long' activates the Long\n" +
 "State, and 'breakout_short' the Short State.\n\n" +
 "With a KER length of 14, stock indices (H1+) still\n" +
  "show the familiar asymmetry (avg. KER ~+0.20 Long /\n" +
  "-0.15 Short)."
string ch6_text_2 = 
 
 "For both long and short states, MFE floats around\n" +
 "4.0 ATR and MAE around 2.5 ATR, yielding an avg.\n" +
 "Potential Ratio of about 1.5 to 1.8.\n\n" +
 "Keep in mind these are rough visual estimates. Switch\n" +
 "between timeframes and assets to get a clearer picture.\n\n" +
 "Overall, these table values suggest that OMSF can\n" +
 "serve as a solid baseline for valid market structure\n" +
 "indicators, highlighting the core potential of\n" +
 "this approach.\n\n" +
 "In the upcoming article—Rethinking MS - Part 4—I\n" +
 "will recap the tutorial so far and share thoughts\n" +
 "on where to go next. Be sure to check the ideas\n" +
 "section soon!\n\n" +
 "Cheers, arni"

// --- Render Call ---
if barstate.islast and ch_6 and show_text
    chapter_intro_columns(ch6_header, ch6_text_1, ch6_text_2, omsf_color, 2)

//  ===============================================================================
//  |           Settings of Indicator Specific Parameters                         |
//  ===============================================================================
//  
gp_pivots = "Pivot Points High/Low"

leftLenH  = input.int(title="Pivot High Left",  defval=10, minval=1, inline="Pivot High", group=gp_pivots, active = (exerc_1 or recap or (ch_3 and not show_text) or ch_4a or ch_4c or ch_5))
rightLenH = input.int(title="Right Length",     defval=10, minval=1, inline="Pivot High", group=gp_pivots, active = (exerc_1 or recap or (ch_3 and not show_text) or ch_4a or ch_4c or ch_5),
 tooltip = "LEFT LENGTH: Smaller = Aggressively hunts for local peaks, making the baseline unstable.\nRIGHT LENGTH: Larger = Increases stability but introduces a rigid confirmation delay visible in the stats table.")

leftLenL  = input.int(title="Pivot Low Left",   defval=10, minval=1, inline="Pivot Low",  group=gp_pivots, active = (exerc_1 or recap or (ch_3 and not show_text) or ch_4a or ch_4c or ch_5))
rightLenL = input.int(title="Right Length",     defval=10, minval=1, inline="Pivot Low",  group=gp_pivots, active = (exerc_1 or recap or (ch_3 and not show_text) or ch_4a or ch_4c or ch_5), 
 tooltip = "LEFT LENGTH: Smaller = Flags minor local valleys prematurely, flipping the trend bias too fast.\nRIGHT LENGTH: Larger = Smooths out chart lines but freezes structural ranges very late after the fact.")

gp_omsf_struct_filter = 'Exercise 1 - OMSF Controls'

use_mom_filter = input.bool(true, "Momentum Filter Active", group = gp_omsf_struct_filter, inline ="Momentumfilter", active = (exerc_1 or ch_4b or ch_4c or ch_5 or ch_6), 
 tooltip = "MOMENTUM FILTER: Prevents the structure from snapping on random market noise during tight sideways consolidations.\nTHRESHOLD: Higher = Fewer data points, quieter structure. Lower = Structure reacts to almost every candle.")

mom_tresh = input.float(1.0, 'Momentum (ATR)', step = 0.05, minval = 0.0, group = gp_omsf_struct_filter, inline ="Momentumfilter", active = use_mom_filter and (exerc_1 or ch_4b or ch_4c or ch_5 or ch_6))

comp_tresh = input.float(1.5, 'Compression Threshold', step = 0.05, minval = 0.5, group = gp_omsf_struct_filter, inline = "Range Size Filter", active = use_mom_filter and (exerc_1 or ch_4b or ch_4c or ch_5 or ch_6), 
 tooltip = "HIGHER = Ignores minor moves (wider ranges). LOWER = Engine gets highly granular (narrower, tighter ranges).")

gp_ker = 'KAUFMAN EFFICIENCY RATIO (KER)'

kerLen   = input.int(title="KER Length", defval=14, minval=1,  group = gp_ker, inline ='Kaufman Efficency Ratio', 
     active = (ch_3 or ch_4a or ch_4b or ch_4c or ch_6))
show_ker_plot = input.bool(true, 'Plot KER', group = gp_ker, inline = 'Kaufman Efficency Ratio',
     tooltip = "The lookback period used to calculate the price direction and absolute volatility. Default is 14 bars.\n\n" +
     "Toggles the visibility of the KER oscillator panel on the chart.", active = (ch_3 or ch_4a or ch_4b or ch_4c or ch_6))

//  ===============================================================================
//  |            ---Settings Plots ---                                            |
//  ===============================================================================
gp_basic_plots = "Plots and Labels Basics"
show_running_pivots = input.bool(false, 'Show Running Pivots', group = gp_basic_plots, inline = '1', active = (ch_1), 
 tooltip = "Turn this on to visualize the highest high and lowest low of the trailing bars before any confirmation happens.")
show_confirm_pivot  = input.bool(false, 'Label Pivot Confirmation', group = gp_basic_plots, inline = '2', active = (ch_1 or exerc_1 or recap), 
 tooltip = "Turn this on to see a marker exactly on the bar where the future confirmation condition was met.")
show_active_pivot = input.bool(true, 'Show Active Pivot', group = gp_basic_plots, inline = '3', active = exerc_1,
 tooltip = "Tip: Hide the OMSF to study the time-locked mechanic of classic Pivots. Higher lengths equal slower, heavier lines.")

label_omsf_strHighLow = input.bool(true, 'OMSF Structure Highs & Lows', group = gp_basic_plots, inline = '4', active = (ch_2), 
 tooltip = "Plots the final, validated OMSF structural points on the main chart. Compare their placement and frequency directly against the standard time-based pivots.")
show_omsf_peaks = input.bool(false, 'OMSF Peaks', group = gp_basic_plots, inline = '5', active = (ch_2), 
 tooltip = "Plots the raw, unconfirmed trailing peak ceilings and floors on the main chart. Turn standard pivots off to see how these lines dynamically breathe with price action.")
show_omsf_confirm = input.bool(false, 'Label OMSF Confirmation', group = gp_basic_plots, inline = '6', active = (ch_2 or exerc_1), 
 tooltip = "Plots a visual marker at the exact candle where either the ATR distance requirement or the momentum candle trigger permanently locked in the level.")
show_omsf_structure = input.bool(true, 'Show OMSF Structure', group = gp_basic_plots, inline = '7', active = (exerc_1 or ch_6), 
 tooltip = "Tip: Hide Pivots to isolate the OMSF engine. Higher thresholds equal wider, more stable trading ranges.")

//  ===============================================================================
//  |                       --- LEARNING SPACE TRENDFILTER ---                    |
//  ===============================================================================
gp_trendfilter = "Visualization of Lerning Trendfilters"
visual_filter_validation = input.bool(true, 'Visual KER Validation', group = gp_trendfilter, inline ='1', active = (ch_4a or ch_4b),
 tooltip = "Highlights the chart when the structural trend matches the mathematical efficiency (KER).\n\n" +
 "• Validated Uptrend: Long State + Positive KER (> 0)\n" +
 "• Validated Downtrend: Short State + Negative KER (<= 0)\n\n" +
 "Helps you instantly spot where the active engine (Pivot/OMSF) is backed by real, linear momentum vs. where it runs into market noise.")

show_vis_excursion = input.bool(true, 'Visualize MFE/ MAE OF...', group = gp_trendfilter, active = ch_5 or ch_6, inline = "2")
vis_excursion = input.string("Pivot-Trendfilter", " ",
     options=['Pivot-Trendfilter', 'OMSF-Trendfilter'], group = gp_trendfilter, active = ch_5, inline = "2", display = display.none,
     tooltip = "Toggle visual projection boxes on chart to plot the Maximum Favorable & Adverse Excursion for the active and previous trend phases.\n\n" +
     "Switch excursion rendering between Pivot- and OMSF conditions.")
show_max_excurs_label = input.bool(true, 'Label MFE/ MAE', group = gp_trendfilter, active = ch_5 or ch_6, inline = "3", 
     tooltip = "Display price labels with exact ATR-normalized MFE/MAE values directly at the excursion box.")

show_pivot_filter = input.bool(true, 'Show Pivot Trendfilter', group = gp_trendfilter, inline = '4', active = recap or (ch_3 and not show_text) or ch_4a or ch_4c or ch_5 and vis_excursion == "Pivot-Trendfilter",
 tooltip = "Renders the Pivot High/Low trend filter on chart")
show_omsf_filter = input.bool(true, 'Show Omsf Trendfilter', group = gp_trendfilter, inline = '5', active = ch_4b or ch_4c or ch_5 and vis_excursion == 'OMSF-Trendfilter',
 tooltip = "Renders the OMSF filter on chart")

/// ===============================================================================
//  |            --- PIVOT POINTS HIGH/LOW CALCULATIONS ---                       |
//  ===============================================================================
[count_std_pivots, avg_std_delay, pivot_market_state, running_pivot_high, running_pivot_low, ph, pl, plot_ph, plot_pl] = ls.pivot_fun(leftLenH, rightLenH, leftLenL, rightLenL)

// RENDERING CONDITIONS
render_running_pivots      = show_running_pivots and ch_1 
render_pivot_confirmation  = show_confirm_pivot and (ch_1 or exerc_1 or recap) 
render_active_pivot        = exerc_1 and show_active_pivot
render_pivot_filter        = recap or ((ch_4a or (ch_3 and not show_text) or ch_4c or (ch_5 and vis_excursion == 'Pivot-Trendfilter') or (note_max_excursion and vis_excursion == 'Pivot-Trendfilter')) and show_pivot_filter)

//  ===============================================================================
//  |            --- OMSF CALCULATIONS ---                                        |
//  ===============================================================================
[omsf_strHigh, omsf_strHightime, omsf_strLow, omsf_strLowtime, peakHigh, peakLow, upMove, downMove, 
     omsfHigh, omsfHigh_time, omsfLow, omsfLow_time, compress, standardRange, hugeRange, expansLong, expansShort, longCorr, shortCorr] 
     = omsf.get_omsf_structure(use_mom_filter, mom_tresh, close , 14, 1.2, comp_tresh, 4.0)

[omsf_strHigh_conf, omsfHigh_conf_index, omsf_strLow_conf, omsfLow_conf_index, count_omsf_points, avg_omsf_delay, 
         omsf_ls_filter_state, last_omsf_structure, plot_omsf_h, plot_omsf_l, omsf_breakout_bias, omsf_breakout_long, omsf_breakout_short] =
     omsf.derive_for_ls(peakHigh, peakLow, upMove, downMove, omsf_strHigh, omsf_strHightime, omsf_strLow, omsf_strLowtime, expansLong, expansShort, longCorr, shortCorr)

// RENDERING CONDITIONS
render_label_omsf_struct = ch_2 and label_omsf_strHighLow
render_omsf_peaks        = show_omsf_peaks and ch_2
render_omsf_conf_high    = omsf_strHigh_conf and (ch_2 or exerc_1) and show_omsf_confirm 
render_omsf_conf_low     = omsf_strLow_conf and (ch_2 or exerc_1) and show_omsf_confirm
render_omsf_structure    = show_omsf_structure and (exerc_1 or ch_6)
render_omsf_filter        = (ch_4b or ch_4c or (ch_5 and vis_excursion == 'OMSF-Trendfilter') or (note_max_excursion and vis_excursion == 'OMSF-Trendfilter')) and show_omsf_filter

// ==============================================================================
// |                    --- Plots Chapter 1 & 2 ---                             |
// ==============================================================================
draw_pivot_label(_pivot, _style, _color, _textColor) =>
    if not na(_pivot)
        label.new(bar_index, _pivot, "Pivot\nLocked", style=_style, color=_color, textcolor=_textColor, size=size.small, force_overlay=true)

plot(render_running_pivots ? running_pivot_high : na, title = 'Running Pivot High', style = plot.style_linebr, color = color.new(color.white,20), linewidth = 1, force_overlay = true, display = display.pane)
plot(render_running_pivots ? running_pivot_low : na,  title = 'Running Pivot Low',  style = plot.style_linebr, color = color.new(color.white,20), linewidth = 1, force_overlay = true, display = display.pane)

if render_pivot_confirmation
    draw_pivot_label(ph, label.style_label_down, color.new(color.white,20), color.black)
    draw_pivot_label(pl, label.style_label_up,   color.new(color.white,20), color.black)

if render_label_omsf_struct
    label.new(omsf_strHightime, omsf_strHigh, "StrHigh", xloc = xloc.bar_time, style = label.style_label_down, color = omsf_color, textcolor = midnight_charcoal, size = size.small, force_overlay = true)
    label.new(omsf_strLowtime, omsf_strLow, "StrLow", xloc = xloc.bar_time, style = label.style_label_up, color = omsf_color, textcolor = midnight_charcoal, size = size.small, force_overlay = true)

// - - - - - - - - - - - - - - - - - - - - - - - - - - - -  - - - - - - - - - - - - - - - - - - - - -  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  

plot(render_omsf_peaks ? peakHigh : na, title = 'Running OMSF Peak High', style = plot.style_linebr, color = omsf_color, linewidth = 1, force_overlay = true, display = display.pane)
plot(render_omsf_peaks ? peakLow : na,  title = 'Running OMSF Peak Low',  style = plot.style_linebr, color = omsf_color, linewidth = 1, force_overlay = true, display = display.pane)

if render_omsf_conf_high
    label.new(omsfHigh_conf_index,  omsf_strHigh, "StrHigh\nLocked", style=label.style_label_down, color = omsf_color, textcolor = midnight_charcoal, size = size.small, force_overlay = true)

if render_omsf_conf_low
    label.new(omsfLow_conf_index,  omsf_strLow, "StrLow\nLocked", style=label.style_label_up, color = omsf_color, textcolor = midnight_charcoal, size = size.small, force_overlay = true)

plot_strHigh = plot(render_omsf_structure ? omsf_strHigh : na, title = 'Plot OMSF Structure High', style = plot.style_linebr, 
     color = (ch_6) and omsf_breakout_bias == 1 ? omsf_bulls_color :  (ch_6) and omsf_breakout_bias == -1 ? omsf_bears_color : omsf_color, linewidth = 2, force_overlay = true, display = display.pane)
plot_strLow = plot(render_omsf_structure ? omsf_strLow : na,  title = 'Plot OMSF Structure Low',  style = plot.style_linebr, 
    color = (ch_6) and omsf_breakout_bias == 1 ? omsf_bulls_color :  (ch_6) and omsf_breakout_bias == -1 ? omsf_bears_color : omsf_color, linewidth = 2, force_overlay = true, display = display.pane)

// ==============================================================================
// |      Comparison Onset Delay: Pivots vs. OMSF (Exercise 1)                  |
// ==============================================================================
if barstate.islast and exerc_1 and show_stats
    var table statsTable_1 = table.new(position = position.top_center, columns = 3, rows = 3, bgcolor = na, border_width = 1, border_color = omsf_color, force_overlay = true)
    // Header Row
    table.cell(statsTable_1, 0, 0, "by arnipoer 🇩🇪\nmade in germany", text_color=color.new(omsf_color,50), text_size=size.tiny)
    table.cell(statsTable_1, 1, 0, "OMSF", text_color=omsf_color, text_size=size.small)
    table.cell(statsTable_1, 2, 0, "Pivot H/L", text_color=color.white, text_size=size.small)
    // Row 1: Total number of confirmed structural points
    table.cell(statsTable_1, 0, 1, "Total Data Points", text_color=silk_pearl, text_size=size.small)
    table.cell(statsTable_1, 1, 1, str.tostring(count_omsf_points), text_color=omsf_color, text_size=size.small)
    table.cell(statsTable_1, 2, 1, str.tostring(count_std_pivots), text_color=color.white, text_size=size.small)
    // Row 2: Confirmation lag (distance in bars between peak and validation)
    table.cell(statsTable_1, 0, 2, "Avg Confirmation\nLag (Bars)", text_color=silk_pearl, text_size=size.small)
    table.cell(statsTable_1, 1, 2, str.tostring(avg_omsf_delay, "#.#"), text_color=omsf_color, text_size=size.small)
    table.cell(statsTable_1, 2, 2, str.tostring(avg_std_delay, "#.#"), text_color=color.white, text_size=size.small)

// ===============================================================================
// |              --- TRENDFILTER RENDERING (Recap / Chapter 4) ---              |
// ===============================================================================
// -------------------   Pivot Trendfilter  ----------------------------
bool is_render_uptrend   = (pivot_market_state == 1) and render_pivot_filter
bool is_render_downtrend = (pivot_market_state == -1) and render_pivot_filter

pivotHigh = plot(render_pivot_filter or render_active_pivot ? plot_ph : na, "Pivot High", style = plot.style_linebr, color = color.new(render_pivot_filter ? laser_crimson_hex : render_active_pivot ? color.white : na, 5), linewidth = 2, force_overlay = true, display = display.pane) 
pivotLow  = plot(render_pivot_filter or render_active_pivot ? plot_pl : na, "Pivot Low",  style = plot.style_linebr, color = color.new(render_pivot_filter ? hyper_green_hex : render_active_pivot ? color.white : na, 5), linewidth = 2, force_overlay = true, display = display.pane) 
pivot_upTrend   = plot(is_render_uptrend   ? low  : na, "Pivot UpTrend Boundary",   style = plot.style_linebr, color = color.new(color.green, 100), linewidth = 1, force_overlay = true, display = display.pane) 
pivot_downTrend = plot(is_render_downtrend ? high : na, "Pivot DownTrend Boundary", style = plot.style_linebr, color = color.new(color.red, 100),   linewidth = 1, force_overlay = true, display = display.pane) 
fill(pivot_upTrend,   pivotLow,  color = color.new(hyper_green_hex, 90), title = "Pivot UpTrend Fill") 
fill(pivot_downTrend, pivotHigh, color = color.new(laser_crimson_hex, 90),   title = "Pivot DownTrend Fill")
// -------------------   OMSF LS-FilterTrendfilter  ----------------------------
omsf_dt_plot = plot(render_omsf_filter ? plot_omsf_h : na, "omsf Downtrend", style = plot.style_linebr, color = color.new(omsf_bears_color, 5), linewidth = 2, force_overlay = true, display = display.pane) 
omsf_ut_plot  = plot(render_omsf_filter ? plot_omsf_l : na, "omsf Uptrend",  style = plot.style_linebr, color = color.new(omsf_bulls_color, 5), linewidth = 2, force_overlay = true, display = display.pane) 
omsf_upTrend   = plot(omsf_ls_filter_state == 1   ? low  : na, "omsf UpTrend Boundary",   style = plot.style_linebr, color = color.new(color.green, 100), linewidth = 1, force_overlay = true, display = display.pane) 
omsf_downTrend = plot(omsf_ls_filter_state == -1 ? high : na, "omsf DownTrend Boundary", style = plot.style_linebr, color = color.new(color.red, 100),   linewidth = 1, force_overlay = true, display = display.pane) 
fill(omsf_upTrend,   omsf_ut_plot,  color = color.new(omsf_bulls_color, 90), title = "omsf UpTrend Fill") 
fill(omsf_downTrend, omsf_dt_plot, color = color.new(omsf_bears_color, 90),   title = "omsf DownTrend Fill")

//===============================================================================
//|                      KAUFMAN EFFICIENCY RATIO (Chapter 3)                   |
//===============================================================================
[ker] = ls.dir_kaufman_eff_ratio(kerLen)

[ker_color] = switch
    ker > 0 => [color.new(bull_candle_color, (1-ker)*100)]
    ker <= 0 => [color.new(bear_candle_color, (1-(-1*ker))*100)]

render_ker_plot = show_ker_plot and (ch_3 or ch_4a or ch_4b or ch_4c or ch_6)

// -------------------  KER Plot ----------------------------
ker_max_up = hline(render_ker_plot ? 1 : na, "mark KER(1)", color = color.new(color.silver, 70))
ker_mid_up = hline(render_ker_plot ? 0.50 : na, "mark KER(0.5)", color = color.new(color.silver,  70))
ker_null = hline(render_ker_plot ? 0 : na, "mark KER(0)", color = color.new(color.silver,  70))
ker_mid_dn = hline(render_ker_plot ? -0.50 : na, "mark KER(-0.5)", color = color.new(color.silver,  70))
ker_max_down = hline(render_ker_plot ? -1: na , "mark KER(-1)", color = color.new(color.silver,  70))

plot_baseline = plot(render_ker_plot ? 0 : na, color = na)
ker_plot_bull = plot(render_ker_plot ? ker > 0 ? ker : na : na, title="bull kaufman efficency", color = na, linewidth = 1)
ker_plot_bear = plot(render_ker_plot ? ker <= 0 ? ker : na : na, title="bear kaufman efficency", color = na, linewidth = 1)
ker_plot = plot(render_ker_plot ? ker : na, title = "ker_plot", color = (ker_color), linewidth = 1)
fill(ker_plot_bull, plot_baseline, color = ker_color)
fill(ker_plot_bear, plot_baseline, color = ker_color)

// ===============================================================================
//           KAUFMAN EFFICIENCY RATIO: Trendfilter-Validation (Chapter 4)       
// ===============================================================================
[avg_ker_pivot_long, pivot_long_bars, avg_ker_pivot_short, pivot_short_bars] = ls.ker_marketstructure_validation(ker, pivot_market_state)
[avg_ker_omsf_long, omsf_long_bars, avg_ker_omsf_short, omsf_short_bars] = ls.ker_marketstructure_validation(ker, omsf_ls_filter_state)

vis_ker_validation(float ker) => 
    bool val_upTrend = ker > 0 and (ch_4a ? pivot_market_state == 1 : omsf_ls_filter_state == 1), bool val_downTrend = ker <= 0 and (ch_4a ? pivot_market_state == -1 : omsf_ls_filter_state == -1)

    [ker_color_candCol] = switch
        ker > 0 => [color.new(ch_4a ? hyper_green_hex : omsf_bulls_color,0)]
        ker <= 0 => [color.new(ch_4a ? laser_crimson_hex : omsf_bears_color,0)]

    [val_upTrend, val_downTrend, ker_color_candCol]

[val_upTrend, val_downTrend, ker_color_candCol] = vis_ker_validation(ker)

render_vis_filter_validation = (ch_4a or ch_4b) and visual_filter_validation

plot_val_cond_high = plot(render_vis_filter_validation and (val_upTrend or val_downTrend) ? high : na, title ="validated trend high", color = na, force_overlay = true)
plot_val_cond_low = plot(render_vis_filter_validation and (val_upTrend or val_downTrend) ? low : na, title ="plot validated trend low", color = na, force_overlay = true)
fill(plot_val_cond_high, plot_val_cond_low, color.new(ker_color_candCol,50))

if barstate.islast and (ch_4a or ch_4b or ch_4c) and show_stats
    var table compareTable = table.new(position = position.top_center, columns = 5, rows = 3, bgcolor = na, border_width = 1, border_color = omsf_color, force_overlay = true)
    // --- REIHE 0: HEADER ---
    table.cell(compareTable, 0, 0, "Structure /\n Efficiency", text_color=silk_pearl, text_size=size.small)
    table.cell(compareTable, 1, 0, "Pivot Long", text_color=color.green, text_size=size.small)
    table.cell(compareTable, 2, 0, "Pivot Short", text_color=color.red, text_size=size.small)
    if ch_4b or ch_4c
        table.cell(compareTable, 3, 0, "OMSF Long", text_color=omsf_bulls_color, text_size=size.small)
        table.cell(compareTable, 4, 0, "OMSF Short", text_color=omsf_bears_color, text_size=size.small)
    // --- REIHE 1: DAUER IN BARS ---
    table.cell(compareTable, 0, 1, "Duration in state", text_color=silk_pearl, text_size=size.small)
    table.cell(compareTable, 1, 1, str.tostring(pivot_long_bars) + " Bars", text_color=color.white, text_size=size.small)
    table.cell(compareTable, 2, 1, str.tostring(pivot_short_bars) + " Bars", text_color=color.white, text_size=size.small)
    if ch_4b or ch_4c
        table.cell(compareTable, 3, 1, str.tostring(omsf_long_bars) + " Bars", text_color=omsf_color, text_size=size.small)
        table.cell(compareTable, 4, 1, str.tostring(omsf_short_bars) + " Bars", text_color=omsf_color, text_size=size.small)
    // --- REIHE 2: EFFIZIENZ (KER) ---
    table.cell(compareTable, 0, 2, "Ø Efficiency (KER)", text_color=silk_pearl, text_size=size.small)
    table.cell(compareTable, 2, 2, str.tostring(avg_ker_pivot_short, "#.###"), text_color=color.red, text_size=size.small)
    table.cell(compareTable, 1, 2, str.tostring(avg_ker_pivot_long, "#.###"), text_color=color.green, text_size=size.small)
    if ch_4b or ch_4c
        table.cell(compareTable, 3, 2, str.tostring(avg_ker_omsf_long, "#.###"), text_color=omsf_bulls_color, text_size=size.small)
        table.cell(compareTable, 4, 2, str.tostring(avg_ker_omsf_short, "#.###"), text_color=omsf_bears_color, text_size=size.small)

// ===============================================================================
// |            --- MAX FORWARD- & ADVERSE EXCURSION (Chapter 5) ---             |
// ===============================================================================
[p_avg_mfe_up, p_avg_mae_up, p_avg_mfe_dn, p_avg_mae_dn, p_ratio_up, p_ratio_dn, p_curr_mfe, p_curr_mae, p_final_mfe, p_final_mae, _, _, _, _] = ls.max_excurs_ratio(pivot_market_state, na)
[o_avg_mfe_up, o_avg_mae_up, o_avg_mfe_dn, o_avg_mae_dn, o_ratio_up, o_ratio_dn, o_curr_mfe, o_curr_mae, o_final_mfe, o_final_mae, _, _, _, _] = ls.max_excurs_ratio(omsf_ls_filter_state, na)

if (ch_5 or note_max_excursion) and show_vis_excursion
    ls.vis_mfe_mae_ratio_long(vis_excursion == 'Pivot-Trendfilter' ? pivot_market_state : omsf_ls_filter_state, vis_excursion, vis_excursion == 'Pivot-Trendfilter' ? p_curr_mfe : o_curr_mfe , 
        vis_excursion == 'Pivot-Trendfilter' ? p_curr_mae : o_curr_mae, 
        vis_excursion == 'Pivot-Trendfilter' ? p_final_mfe : o_final_mfe , 
        vis_excursion == 'Pivot-Trendfilter' ? p_final_mae : o_final_mae,bull_candle_color, bear_candle_color, omsf_color, show_max_excurs_label)
    ls.vis_mfe_mae_ratio_short(vis_excursion == 'Pivot-Trendfilter' ? pivot_market_state : omsf_ls_filter_state, vis_excursion, vis_excursion == 'Pivot-Trendfilter' ? p_curr_mfe : o_curr_mfe , 
        vis_excursion == 'Pivot-Trendfilter' ? p_curr_mae : o_curr_mae, 
        vis_excursion == 'Pivot-Trendfilter' ? p_final_mfe : o_final_mfe , 
        vis_excursion == 'Pivot-Trendfilter' ? p_final_mae : o_final_mae, bull_candle_color, bear_candle_color, omsf_color, show_max_excurs_label)

if barstate.islast and (ch_5 or note_max_excursion) and show_stats
    var table excursionTable = table.new(position = position.top_center, columns = 5, rows = 3, bgcolor = color.new(midnight_charcoal, 20), border_width = 1, border_color = omsf_color, force_overlay = true)
    // --- REIHE 0: HEADER ---
    table.cell(excursionTable, 0, 0, "Excursion (ATR normiert)", text_color=silk_pearl, text_size=size.small)
    table.cell(excursionTable, 1, 0, "Pivot Long", text_color=color.green, text_size=size.small)
    table.cell(excursionTable, 2, 0, "Pivot Short", text_color=color.red, text_size=size.small)
    table.cell(excursionTable, 3, 0, "OMSF Long", text_color=omsf_bulls_color, text_size=size.small)
    table.cell(excursionTable, 4, 0, "OMSF Short", text_color=omsf_bears_color, text_size=size.small)
    // --- REIHE 1: DURCHSCHNITTLICHE EXTRENWERTE (MFE vs MAE) ---
    table.cell(excursionTable, 0, 1, "Ø Max Move (MFE / MAE)", text_color=silk_pearl, text_size=size.small)
    table.cell(excursionTable, 1, 1, "MFE: " + str.tostring(p_avg_mfe_up, "#.##") + "\nMAE: " + str.tostring(p_avg_mae_up, "#.##"), text_color=color.white, text_size=size.small)
    table.cell(excursionTable, 2, 1, "MFE: " + str.tostring(p_avg_mfe_dn, "#.##") + "\nMAE: " + str.tostring(p_avg_mae_dn, "#.##"), text_color=color.white, text_size=size.small)
    table.cell(excursionTable, 3, 1, "MFE: " + str.tostring(o_avg_mfe_up, "#.##") + "\nMAE: " + str.tostring(o_avg_mae_up, "#.##"), text_color=omsf_color, text_size=size.small)
    table.cell(excursionTable, 4, 1, "MFE: " + str.tostring(o_avg_mfe_dn, "#.##") + "\nMAE: " + str.tostring(o_avg_mae_dn, "#.##"), text_color=omsf_color, text_size=size.small)
    // --- REIHE 2: EFFEKTIVE RATIO (CRV POTENZIAL) ---
    table.cell(excursionTable, 0, 2, "Potenzial-Ratio (MFE/MAE)", text_color=silk_pearl, text_size=size.small)
    table.cell(excursionTable, 1, 2, str.tostring(p_ratio_up, "#.###"), text_color=color.green, text_size=size.small)
    table.cell(excursionTable, 2, 2, str.tostring(p_ratio_dn, "#.###"), text_color=color.red, text_size=size.small)
    table.cell(excursionTable, 3, 2, str.tostring(o_ratio_up, "#.###"), text_color=omsf_bulls_color, text_size=size.small)
    table.cell(excursionTable, 4, 2, str.tostring(o_ratio_dn, "#.###"), text_color=omsf_bears_color, text_size=size.small)


// ===============================================================================
// |            --- OMSF BREAKOUT BIAS (Chapter 6) ---                           |
// ===============================================================================
[ob_avg_mfe_up, ob_avg_mae_up, ob_avg_mfe_dn, ob_avg_mae_dn, ob_ratio_up, ob_ratio_dn, ob_curr_mfe, ob_curr_mae, ob_final_mfe, ob_final_mae, _, _, _, _] = ls.max_excurs_ratio(omsf_breakout_bias, na)

if ch_6 and show_vis_excursion
    ls.vis_mfe_mae_ratio_long(omsf_breakout_bias, 'OMSF Breakout Bias', ob_curr_mfe, ob_curr_mae, ob_final_mfe, ob_final_mae, bull_candle_color, bear_candle_color, omsf_color, show_max_excurs_label)
    ls.vis_mfe_mae_ratio_short(omsf_breakout_bias, 'OMSF Breakout Bias', ob_curr_mfe, ob_curr_mae, ob_final_mfe, ob_final_mae, bull_candle_color, bear_candle_color, omsf_color, show_max_excurs_label)

[avg_ker_ob_long, ob_long_bars, avg_ker_ob_short, ob_short_bars] = ls.ker_marketstructure_validation(ker,omsf_breakout_bias)

if barstate.islast and (ch_6) and show_stats
    var table excursionTable = table.new(position = position.top_center, columns = 5, rows = 4, bgcolor = color.new(midnight_charcoal, 20), border_width = 1, border_color = omsf_color, force_overlay = true)
    // --- REIHE 0: HEADER ---
    table.cell(excursionTable, 0, 0, "Excursion ATR normalized", text_color=silk_pearl, text_size=size.small)
    table.cell(excursionTable, 1, 0, "OMSF Bias Long", text_color=omsf_bulls_color, text_size=size.small)
    table.cell(excursionTable, 2, 0, "OMSF Bias Short", text_color=omsf_bears_color, text_size=size.small)
    // --- REIHE 1: DURCHSCHNITTLICHE EXTRENWERTE (MFE vs MAE) ---
    table.cell(excursionTable, 0, 1, "Ø Max Move (MFE / MAE)", text_color=silk_pearl, text_size=size.small)
    table.cell(excursionTable, 1, 1, "MFE: " + str.tostring(ob_avg_mfe_up, "#.##") + "\nMAE: " + str.tostring(ob_avg_mae_up, "#.##"), text_color=omsf_color, text_size=size.small)
    table.cell(excursionTable, 2, 1, "MFE: " + str.tostring(ob_avg_mfe_dn, "#.##") + "\nMAE: " + str.tostring(ob_avg_mae_dn, "#.##"), text_color=omsf_color, text_size=size.small)
    // --- REIHE 2: EFFEKTIVE RATIO (CRV POTENZIAL) ---
    table.cell(excursionTable, 0, 2, "Potenzial-Ratio (MFE/MAE)", text_color=silk_pearl, text_size=size.small)
    table.cell(excursionTable, 1, 2, str.tostring(ob_ratio_up, "#.###"), text_color=omsf_bulls_color, text_size=size.small)
    table.cell(excursionTable, 2, 2, str.tostring(ob_ratio_dn, "#.###"), text_color=omsf_bears_color, text_size=size.small)
    // --- REIHE 3: AVG KER ---
    table.cell(excursionTable, 0, 3, "Average KER", text_color=silk_pearl, text_size=size.small)
    table.cell(excursionTable, 1, 3, str.tostring(avg_ker_ob_long, "#.###"), text_color=omsf_bulls_color, text_size=size.small)
    table.cell(excursionTable, 2, 3, str.tostring(avg_ker_ob_short, "#.###"), text_color=omsf_bears_color, text_size=size.small)
````
