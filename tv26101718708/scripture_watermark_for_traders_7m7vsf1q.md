# Scripture Watermark for Traders

- url: https://www.tradingview.com/script/7M7Vsf1q-Scripture-Watermark-for-Traders/
- type: indicator
- pine_id: PUB;5c92cade39d84fd2ac90d0cc8b2f4fc3
- version: 1.0

## Description

This script is a spiritual companion for your trading journey, designed to provide strength, conviction, and emotional grounding through the Word of God.

Trading often tests our discipline and patience. Instead of generic trading mantras, this indicator displays 59 hand-picked Bible verses focused on wisdom, steadfastness, and integrity. Whenever a bar closes, a new verse is cycled, providing a fresh perspective to help you stay centered during market volatility.

Key Features:

59 Bible Verses: Focused on themes like patience (Proverbs 21:5), courage (Joshua 1:9), and wisdom (James 1:5).

Flexible Display: Choose between a fixed Table (perfect for screenshots) or a Label that follows the price action.

Customizable Appearance: Fully adjustable colors, transparency, and sizes to fit your specific chart theme.

Interactive Tooltips: Simply hover over the watermark icon to read the full verse and its reference.

## Source Code

````pine
//@version=5
indicator("Scripture Watermark for Traders", overlay=true)

// Groups
grwm = "Watermark"
grt = "Table"
grl = "Label"

// Input
wmTypeIn = input.string("Table", "Type", options=["Label", "Table"], group=grwm, tooltip="Tables do not move. Labels are hard to crop out.")
position = input.string(position.top_right, "Location", [position.top_center, position.top_right, position.middle_right, position.bottom_right, position.bottom_center, position.bottom_left, position.middle_left, position.top_left], group=grt)
size = input.string(size.huge, "Size", [size.tiny, size.small, size.normal, size.large, size.huge], group=grwm)
watermark = input.string('✝️', "Watermark Icon", group=grwm)
transp = input.int(20, "Transparency", minval=0, maxval=100, group=grwm)
col = input.color(color.orange, "Text Color", group=grwm)

// List of Scriptures for Strength and Wisdom
q1  = "Be strong and courageous. Do not be afraid; do not be discouraged, for the Lord your God will be with you wherever you go. - Joshua 1:9"
q2  = "For God has not given us a spirit of fear, but of power and of love and of a sound mind. - 2 Timothy 1:7"
q3  = "Trust in the Lord with all your heart and lean not on your own understanding. - Proverbs 3:5"
q4  = "In all your ways acknowledge Him, and He shall direct your paths. - Proverbs 3:6"
q5  = "The plans of the diligent lead surely to abundance, but everyone who is hasty comes only to poverty. - Proverbs 21:5"
q6  = "But they who wait for the Lord shall renew their strength; they shall mount up with wings like eagles. - Isaiah 40:31"
q7  = "If any of you lacks wisdom, let him ask God, who gives generously to all without reproach. - James 1:5"
q8  = "I can do all things through Christ who strengthens me. - Philippians 4:13"
q9  = "Let your heart take courage, all you who hope in the Lord! - Psalm 31:24"
q10 = "Commit your work to the Lord, and your plans will be established. - Proverbs 16:3"
q11 = "The Lord is my strength and my shield; in Him my heart trusts, and I am helped. - Psalm 28:7"
q12 = "Steady plodding brings prosperity; hasty speculation brings poverty. - Proverbs 21:5"
q13 = "The heart of man plans his way, but the Lord establishes his steps. - Proverbs 16:9"
q14 = "He gives power to the faint, and to him who has no might he increases strength. - Isaiah 40:29"
q15 = "For I know the plans I have for you, declares the Lord, plans for welfare and not for evil. - Jeremiah 29:11"
q16 = "Be still, and know that I am God. - Psalm 46:10"
q17 = "An inheritance gained hastily in the beginning will not be blessed in the end. - Proverbs 20:21"
q18 = "The Lord will fight for you; you need only to be still. - Exodus 14:14"
q19 = "Whatever you do, work heartily, as for the Lord and not for men. - Colossians 3:23"
q20 = "Peace I leave with you; my peace I give to you. Let not your hearts be troubled. - John 14:27"
q21 = "For wisdom is better than jewels, and all that you may desire cannot compare with her. - Proverbs 8:11"
q22 = "Better is a little with righteousness than great revenues with injustice. - Proverbs 16:8"
q23 = "Wealth gained hastily will dwindle, but whoever gathers little by little will increase it. - Proverbs 13:11"
q24 = "A greedy man stirs up strife, but the one who trusts in the Lord will be enriched. - Proverbs 28:25"
q25 = "Let us not grow weary of doing good, for in due season we will reap, if we do not give up. - Galatians 6:9"
q26 = "The soul of the sluggard craves and gets nothing, while the soul of the diligent is richly supplied. - Proverbs 13:4"
q27 = "But seek first the kingdom of God and His righteousness, and all these things will be added to you. - Matthew 6:33"
q28 = "Keep your life free from love of money, and be content with what you have. - Hebrews 13:5"
q29 = "For where your treasure is, there your heart will be also. - Matthew 6:21"
q30 = "A double-minded man is unstable in all his ways. - James 1:8"
q31 = "He who is faithful in a very little is also faithful in much. - Luke 16:10"
q32 = "The fear of the Lord is the beginning of knowledge; fools despise wisdom and instruction. - Proverbs 1:7"
q33 = "Do not be anxious about anything, but in everything by prayer and supplication let your requests be made known to God. - Philippians 4:6"
q34 = "And the peace of God, which surpasses all understanding, will guard your hearts and your minds in Christ Jesus. - Philippians 4:7"
q35 = "A man without self-control is like a city broken into and left without walls. - Proverbs 25:28"
q36 = "Know this, my beloved brothers: let every person be quick to hear, slow to speak, slow to anger. - James 1:19"
q37 = "The Lord is my shepherd; I shall not want. - Psalm 23:1"
q38 = "Wait for the Lord; be strong, and let your heart take courage; wait for the Lord! - Psalm 27:14"
q39 = "Everything is possible for one who believes. - Mark 9:23"
q40 = "Call to me and I will answer you, and will tell you great and hidden things that you have not known. - Jeremiah 33:3"
q41 = "For the Lord gives wisdom; from His mouth come knowledge and understanding. - Proverbs 2:6"
q42 = "Blessed is the man who remains steadfast under trial. - James 1:12"
q43 = "Lead me in your truth and teach me, for you are the God of my salvation. - Psalm 25:5"
q44 = "God is our refuge and strength, a very present help in trouble. - Psalm 46:1"
q45 = "The righteous cry out, and the Lord hears them; He delivers them from all their troubles. - Psalm 34:17"
q46 = "Trust in Him at all times, O people; pour out your heart before Him; God is a refuge for us. - Psalm 62:8"
q47 = "Great is our Lord, and abundant in power; His understanding is beyond measure. - Psalm 147:5"
q48 = "Fear not, for I am with you; be not dismayed, for I am your God. - Isaiah 41:10"
q49 = "I will strengthen you, I will help you, I will uphold you with my righteous right hand. - Isaiah 41:10"
q50 = "Blessed are those who find wisdom, those who gain understanding. - Proverbs 3:13"
q51 = "By wisdom a house is built, and by understanding it is established. - Proverbs 24:3"
q52 = "Every word of God proves true; He is a shield to those who take refuge in Him. - Proverbs 30:5"
q53 = "But let him ask in faith, with no doubting. - James 1:6"
q54 = "For the Lord will be your confidence and will keep your foot from being caught. - Proverbs 3:26"
q55 = "Humble yourselves, therefore, under the mighty hand of God so that at the proper time He may exalt you. - 1 Peter 5:6"
q56 = "Casting all your anxieties on Him, because He cares for you. - 1 Peter 5:7"
q57 = "The Lord directs the steps of the godly. He delights in every detail of their lives. - Psalm 37:23"
q58 = "Walk by faith, not by sight. - 2 Corinthians 5:7"
q59 = "Let the favor of the Lord our God be upon us, and establish the work of our hands. - Psalm 90:17"

// Logic 
r = math.round(math.random(1, 59))
quoteout = 
  r == 1 ? q1 : r == 2 ? q2 : r == 3 ? q3 : r == 4 ? q4 : r == 5 ? q5 : r == 6 ? q6 : r == 7 ? q7 : r == 8 ? q8 : r == 9 ? q9 :
  r == 10 ? q10 : r == 11 ? q11 : r == 12 ? q12 : r == 13 ? q13 : r == 14 ? q14 : r == 15 ? q15 : r == 16 ? q16 : r == 17 ? q17 : r == 18 ? q18 : r == 19 ? q19 :
  r == 20 ? q20 : r == 21 ? q21 : r == 22 ? q22 : r == 23 ? q23 : r == 24 ? q24 : r == 25 ? q25 : r == 26 ? q26 : r == 27 ? q27 : r == 28 ? q28 : r == 29 ? q29 :
  r == 30 ? q30 : r == 31 ? q31 : r == 32 ? q32 : r == 33 ? q33 : r == 34 ? q34 : r == 35 ? q35 : r == 36 ? q36 : r == 37 ? q37 : r == 38 ? q38 : r == 39 ? q39 :
  r == 40 ? q40 : r == 41 ? q41 : r == 42 ? q42 : r == 43 ? q43 : r == 44 ? q44 : r == 45 ? q45 : r == 46 ? q46 : r == 47 ? q47 : r == 48 ? q48 : r == 49 ? q49 :
  r == 50 ? q50 : r == 51 ? q51 : r == 52 ? q52 : r == 53 ? q53 : r == 54 ? q54 : r == 55 ? q55 : r == 56 ? q56 : r == 57 ? q57 : r == 58 ? q58 : r == 59 ? q59 : 
  na

// Table Out
var table quote = table.new(position, 1, 1)
if barstate.isconfirmed and wmTypeIn=="Table"
    table.cell(quote, 0, 0, watermark, text_size = size, text_color = color.new(col, transp), tooltip=str.tostring(quoteout))
    
// Label Out
watermarklocation = input.string(yloc.abovebar, options=[yloc.belowbar, yloc.abovebar], title='Location', group=grl)
labelhoffset = input.int(0, "Horizontal Offset", maxval=1)
wmPrice = ta.valuewhen(bar_index, close, 0)
var label quote2 = na
if barstate.isconfirmed and wmTypeIn=="Label"
    quote2 := label.new(bar_index + labelhoffset, y=wmPrice, yloc=watermarklocation, size=size, text=watermark, style=label.style_none, textcolor=color.new(col,transp), tooltip=quoteout)
    label.delete(quote2[1])
````
