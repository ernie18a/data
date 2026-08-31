<!-- tradingview-pine-id: PUB;4a52977f636a4e39b55e0c4bf6be43dc -->
<!-- tradingviewscripts-format: 1 -->
# MarkdownLib

Source: https://www.tradingview.com/script/b6aw56xH-Markdown-The-Pine-Editor-s-Hidden-Gem/

## Description

💬 Markdown, a markup language
Markdown is a portable, lightweight markup language that can be used for everything whether you're building a website, documentation, or even presentations.

Platforms like Discord, Reddit, and GitHub support Markdown and is the widely go-to option for text formatting due to its simplicity. Pine Script is a language that also utilizes Markdown, specifically in the Pine Editor where it can really be used to some extent.

Since the release of libraries, user-defined types, and methods, Pine Script is entering an age where developers will be highly dependent on libraries due to the capabilities Pine has inherited recently. It would be no surprise if a few people got together and took their time to thoroughly develop an entire project/library centered around improving Pine Script's built-in functions and providing developers with easier ways of achieving things than they thought they could.

As you're all aware, hovering over functions (and more) in the editor pops up a prompt that specifies the parameters, types, and what the function returns. Pine Script uses Markdown for that, so I figured we could go ahead and push that feature to its limits and see what we can do.

Today we'll go over how we can utilize Markdown in Pine Script, and how you can make your library's built-in functions stand out more than they did previously.

For more information, visit [https://www.markdownguide.org/](https://www.markdownguide.org/)

📕 General Notes

[*] Markdown syntax only works on functions and methods.
[*] Using arrays as parameters as of 2/21/2023 breaks the Markdown system.
[*] The prompt window holds a max of 166 characters on one line before overflowing.
[*] There is no limit on how long the prompt window can be.

🔽 Getting Started 🔽 

▶️ Headings

[*] If you have experience in HTML, Markdown, or even Microsoft Word then you already have a grasp of how headings work and look.
[*] To simplify it, headings make the given text either massive or tiny depending on how many number symbols are provided.
[*] When defining headings, you must have a space between the number (#) symbol, and the text. This is typical syntax throughout the language.
[*] Pine Script uses bold text by applying (**) for their titles on their built-ins (e.g. @returns) but you could also use heading level 4 (####) and have it look the same.

[image]https://www.tradingview.com/x/grRJyEuF/[/image]

▶️ Paragraphs & Line Breaks

[*] You may want to provide extensive details and examples relating to one function, in this case, you could create line breaks. Creating line breaks skips to the next line so you can keep things organized as a result.
[*] To achieve a valid line break and create a new paragraph, you must end the line with two or more spaces.
[*] If you want to have an empty line in between, apply a backslash (\).
[*] Backslashes (\) are generally not recommended for every line break. In this case, I only recommend using them for empty lines.

[image]https://www.tradingview.com/x/UKNC6HBR/[/image]

▶️ Text Formatting

[*] Markdown provides text formatting such as bold, italics, and strikethrough.
[*] For bolding text, you can apply open and close (**) or (__).
[*] For italicizing text, you can apply open and close (*) or (_).
[*] For bolding and italicizing text, you can apply open and close (***) or (___).
[*] For s̶t̶r̶i̶k̶e̶t̶h̶r̶o̶u̶g̶h̶, you need to apply open and close (~~).
[*] This was mentioned in the Headers section, but Pine Script's main titles (e.g. @returns or @syntax) use bold (**) by default.

[image]https://www.tradingview.com/x/YZj8tPue/[/image]

▶️ Blockquotes

[*] Blockquotes in Pine Script can be visualized as a built-in indentation system.
[*] They are declared using greater than (>) and everything will be auto-aligned and indented until closed.
[*] By convention you generally want to include the greater than (>) on every line that's included in the block quote. Even when not needed.
[*] If you would like to indent even more (nested blockquotes), you can apply multiple greater than symbols (>). For example, (>>)
[*] Blockquotes can be closed by ending the next line with only one greater than (>) symbol, or by using a horizontal rule.
[image]https://www.tradingview.com/x/7lTgFTtn/[/image]

▶️ Horizontal Rules

[*] Horizontal rules in Pine Script are what you see at the very top of the prompt in built-ins.
[*] When hovering, you can see the top of the prompt provides a line, and we can actually reproduce these lines.
[*] These are extremely useful for separating information into their own parts and are accessed by applying 3 underscores (___), or 3 asterisks (***).
[*] Horizontal rules were mentioned above, when we were discussing block quotes. These can also be used to close blockquotes as well.
[*] Horizontal rules require a minimum of 3 underscores (___) or 3 asterisks (***).

[image]https://www.tradingview.com/x/RAl43vJA/[/image]

▶️ Lists

[*] Lists give us a way to structure data in a somewhat neat way. There are multiple ways to start a list, such as
[*] 1. First Item (number followed by a period)
[*] - First Item (dash)
[*] + First Item (plus sign)
[*] * First Item (asterisk)
[*] Using number-based lists provide an ordered list, whereas using (-), (+), or (*) will provide an unordered list (bullet points).
[*] If you want to begin an unordered list with a number that ends with a period, you must use an escape sequence (\) after the number.
[*] Standard indentation (tab-width) list detection isn't supported, so to nest lists you have to use blockquotes (>) which may not look as appealing.

[image]https://www.tradingview.com/x/WJgru3Pa/[/image]

▶️ Code Blocks

[*] Using code blocks allows you to write actual Pine Script code inside the prompt.
[*] It's a game changer that can potentially help people understand how to execute functions quickly.
[*] To use code blocks, apply three 3 open and close backquotes (```). Built-in's use (```pine) but there's no difference when we apply it.
[*] Considering that tab-width indentation isn't detected properly, we can make use of the blockquotes mentioned above.

[image]https://www.tradingview.com/x/FRUdKyl8/[/image]

▶️ Denotation

[*] Denoting can also be seen as highlighting a background layer behind text. They're basically code blocks, but without the "block".
[*] Similar to how code blocks work, we apply one backquote open and close (`).
[*] Make sure to only use this on important keywords. There really isn't a conventional way of applying this.
[*] It's up to you to decide what people should have their eyes tracked onto when they hover over your functions.
[*] If needed, look at how Pine Script's built-in variables and functions utilize this.

[image]https://www.tradingview.com/x/1oHJCxH7/[/image]

▶️ Tables

[*] Tables are possible in Markdown, although they may look a bit different in the Pine Editor.
[*] They are made by separating text with vertical bars (|).
[*] The headers are detected when there is a minimum of one hyphen (-) below them.
[*] You can align text by using a colon as I do in the photo. Hyphens must be connected to the colon in order to display correctly.
[*] Tables aren't ideal to use in the editor but are there if anyone wants to give it a go.

[image]https://www.tradingview.com/x/RL2Uwyzq/[/image]

▶️ Links & Images

[*] Markdown supports images and hyperlinks, which means we can also do that here in the Pine Editor. Cool right?
[*] If you want to create a hyperlink, surround the displayed text in open and close brackets [].
[*] If you want to load a photo into your prompt, it's the same syntax as the hyperlink, except it uses a (!)
[*] See syntax list below.

[image]https://www.tradingview.com/x/cZ2ggWo1/[/image]

Here are realistic usage examples. (Snippets from code below)
These follow the same syntax as the built-ins.
I'm not using horizontal rules here, but it's entirely up to you.
[image]https://www.tradingview.com/x/LA5PcwO8/[/image]

▶️ Syntax List
[pine]
Headings
Level 1: #
Level 2: ##
Level 3: ###
Level 4: ####
Level 5: #####
Level 6: ######

Line Breaks
Text  (two spaces)
Text\ (backslash)

Text Formatting
Bold  (**)
Italic (**)
Strikethrough (~~)

Blockquotes
Indent (>)
Double Indent (>>)
Triple Indent (>>>) and so on.

Horizontal Rules
(___) or (***)

Lists
Ordered List (1.)
Unordered List (-) or (+) or (*)

Code Blocks
(```) or (```pine)

Denotation
(`)

Tables
(|) and (-) and (:)

Hyperlinks
[Display Text](URL)

Images
![Display Text](URL)
[/pine]

Hope this helps. 👍

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © nsadeghi

//@version=5
library("MarkdownLib", overlay = true)

//----------------------------------------------------------------------------------------------------------------------------------------------------
//
//  Markdown is a portable, lightweight markup language that can be used for everything
//  whether you're building a website, documentation, or even presentations.
//
//  Platforms like Discord, Reddit and GitHub support Markdown, and is the widely go to
//  option for text formatting due to its simplicity. Pine Script is a language that also
//  utilizes Markdown, specifically in the Pine Editor is where it can really be used to some extent.
//
//  Since the release of libraries, user-defined types, and methods, Pine Script is entering an
//  age where developers will be highly dependent on libraries due to the capabilities 
//  Pine has inherited recently. It would be no surprise if a few people got together and took
//  their time to thoroughly develop an entire library centered around improving Pine Script's
//  built-in functions and providing developers easier ways of achieving things than they thought
//  they could.
//
//  As you're all aware, hovering over functions (and more) in the editor pops up a prompt that specifies
//  the parameters, types, and what the function returns. Pine Script uses Markdown for that, so I figured
//  let's go ahead and push that feature to its limits and see what we can do.
//
//  Today we'll go over how we can utilize Markdown in Pine Script, and how you can make your library's
//  built-in functions stand out more than they did previously.
//
//  For more information, visit https://www.markdownguide.org/
//
//----------------------------------------------------------------------------------------------------------------------------------------------------


// ＧＥＮＥＲＡＬ ＮＯＴＥＳ
// -----------------------
// Markdown syntax only works on functions and methods.
// Using arrays as parameters as of 2/21/2023 breaks the Markdown system.
// The prompt window holds a max of 166 characters on one line before overflowing.
// -----------------------


// ＨＥＡＤＩＮＧＳ  
// ---------------
// If you have experience in HTML, Markdown, or even Microsoft Word you already have a grasp of how Headings work and look.
// To simplify it, headings make the given text either massive, or tiny depending on how many number symbols are provided.
// When defining headings, you must have a space between the number (#) symbol, and the text. This is typical syntax throughout the language.
// Pine Script's built-ins use Heading Level 4 (####) as their main headers.
// ---------------

// @function # A confirmation function  
// # Heading Level 1
// ## Heading Level 2
// ### Heading Level 3
// #### Heading Level 4
// ##### Heading Level 5
// ###### Heading Level 6
//
// # Works.
// #Won't Work.
// @returns Confirmation
confirmFunction() => barstate.isconfirmed


// ＰＡＲＡＧＲＡＰＨＳ ＆ ＬＩＮＥ ＢＲＥＡＫＳ
// -----------------------------------------
// You may want to provide extensive details and examples relating to one function, in this case
// you could create line breaks. Creating line breaks skips to the next line so you can keep things organized as a result.
// To achieve a valid line break and create a new paragraph, you must end the line with two or more spaces.
// If you want to have an empty line in between, apply a back slash (\).
// Back slashes (\) are generally not recommended for every line break. In this case, I only recommend using them for empty lines.
// ------------------------------------------

// @function A confirmation function   
// \
// First Paragraph with two spaces at the end.   
// Second Paragraph with two spaces at the end.  
// Third Paragraph with a backslash at the end.\
// Random Text.
// @returns Confirmation
confirmFunction2() => barstate.isconfirmed


// ＴＥＸＴ ＦＯＲＭＡＴＴＩＮＧ 
// --------------------------
// Markdown provides text formatting such as bold, italics, and strikethrough.
// For bolding text, you can do (**) or (__) as an open and closer.
// For italicizing text, you can do (*) or (_) as an open and closer.
// For bolding and italicizing text, you can do (***) or (___) as an open and closer.
// For strikethrough you need to use (~~) as an open and closer.
// See examples below.
// --------------------------

// @function **A confirmation function**   
// *Italic Text*  
// _Italic_ Text  
// **Bold Text**  
// __Bold__ Text  
// ~~Strikethrough~~ Text  
// ~~***All***~~
// @returns Confirmation
confirmFunction3() => barstate.isconfirmed


// ＢＬＯＣＫＱＵＯＴＥＳ
// --------------------------------------------------------
// Blockquotes in Pine Script can be visualized as a built-in indentation system.
// They are declared using greater than (>) and everything will be auto-aligned and indented until closed.
// By convention you generally want to include the greater than (>) on every line that's included in the block quote. Even when not needed.
// If you would like to indent even more (nested blockquotes), you can apply multiple greater than symbols (>). For example, (>>)
// Blockquotes can be closed by ending the next line with only one greater than (>) symbol, or by using a horizontal rule.
// ---------------------------------------------------------

// @function A confirmation function    
// \
// Random Text
// > #### Blockquote as a Header
// > 
// >> ##### Information inside block quote.  
// >
// End Blockquote
// @returns Confirmation
confirmFunction4() => barstate.isconfirmed


// ＨＯＲＩＺＯＮＴＡＬ ＲＵＬＥＳ
// ---------------------------------------------
// Horizontal rules in Pine Script are what you see at the very top of the prompt.
// When hovering, you can see the top of the prompt provides a line, and we can actually reproduce these lines.
// These are extremely useful for separating information into their own parts, and are accessed by applying
// three underscores (___), or three asterisks (***).
// Horizontal rules were mentioned above, when we were discussing block quotes. These can also be used to close blockquotes as well.
// Horizontal rules require minimum 3 underscores (___).

// @function A confirmation function  
// ___
// Text in-between two lines.
// ___
// @returns Confirmation
confirmFunction5() => barstate.isconfirmed


// ＬＩＳＴＳ
// ---------
// Lists give us a way to structure data in a neat fashion. There are multiple ways to start a list, such as
// 1. First Item (number followed by a period)
// - First Item (dash)
// + First Item (plus sign)
// * First Item (asterisk)
// Using number-based lists provide an ordered list, whereas using (-), (+), or (*) will provide an unordered list (bullet points).
// If you want to begin an unordered list with a number that ends with a period, you must use an escape sequence (\) after the number.
// Standard indentation (tab-width) list detection isn't supported, so to nest lists you have to use block quotes. (>)
// ---------

// @function A confirmation function  
// - First List
// > - First item
// > - Second item  
// 1. First List
// 2. Second Item
// 3. Third Item
// ___
// - 2000. Won't Work.
// ___
// - 2000\. Will Work
// @returns Confirmation
confirmFunction6() => barstate.isconfirmed


// ＣＯＤＥ ＢＬＯＣＫＳ
// -------------------
// Using code blocks allows you to write actual Pine Script code inside the prompt.
// It's a game changer that can potentially help people understand how to execute functions quickly.
// To use code blocks, apply three backquotes (```) as an opener, and a closer.
// Considering that indentation isn't detected properly, use (-) and three spaces as an indentation reference.
// -------------------

// @function The `drawLabel` function draws a label based on a condition.
// #### Usage
// ___
// ```
// if barstate.isconfirmed
// -   drawLabel(bar_index, high) 
// ```
// ___
// @returns A Label
drawLabel(int x, float y) => label.new(x, y)


// ＤＥＮＯＴＡＴＩＯＮ
// --------------
// Denoting can also be seen as highlighting a background layer behind text. They're basically code blocks, but without the "block".
// Similar to how code blocks work, we apply one backquote (`) as an opener and closer.
// Make sure to only use this on important keywords. There isn't really a conventional way of applying this.
// It's up to you to decide what people should have their eyes tracked onto when they hover over your functions.
// If needed, look at how Pine Script's built-in variables and functions utilize this.
// --------------

// @function A confirmation function  
// \
// `Denote` a phrase/word.
// @returns Confirmation
confirmFunction7() => barstate.isconfirmed


// ＴＡＢＬＥＳ
// -----------
// Tables are possible in Markdown, although it may look a bit different in the Pine Editor.
// They are made by separating text with vertical bars (|).
// The headers are detected when there is a minimum of one dash (-) below them.
// Tables aren't ideal to use in the editor, but is there if anyone wants to give it a go.

// @function A confirmation function
// | Left Columns    │ | │ Right Columns  |
// | ----------------: | :--------------- |
// | left val        │ | │ right val      |
// | left val2       │ | │ right val2     |
// ___
// @returns Confirmation
confirmFunction8() => barstate.isconfirmed


// ＬＩＮＫＳ ＆ ＩＭＡＧＥＳ
// ------------------------
// Markdown supports images and hyperlinks, which means we can also do that here in the Pine Editor. Cool right?
// If you want to create a hyper link, surround the displayed text in open and close brackets [].
// The syntax should look like this [Display Text](URL)
// If you want to load a photo into your prompt, it's the same syntax as the hyperlink, except it uses a (!)
// Image syntax should look like this ![Logo Name](URL.png)

// @function A confirmation function
// ___
// [A Fancy Youtube Link](https://www.youtube.com/watch?v=dQw4w9WgXcQ)
// ___
// ![Pine Script Logo](https://i.postimg.cc/qvsJqNT6/Pine-Script-logo-text-1.png)
confirmFunction9() => barstate.isconfirmed


// ＵＳＡＧＥ ＥＸＡＭＰＬＥＳ
// ------------------------
// @function Gets the total decimal count of the current symbol.
//
// #### Usage
// ___
// ```
// table = table.new(position.middle_right, 20, 20)
// table.cell(table, 0, 0, str.tostring(getDecimals()))
// ```
// ___
// @returns The `amount` of existing numbers `after` the decimal point of the current symbol.
export getDecimals() =>
	mintickToArray = str.split(str.tostring(syminfo.mintick), '')
	result = array.new<string>()
	for i in mintickToArray
		switch i
			'0' => array.push(result, '0')
			'.' => array.push(result, '.')
	if array.size(result) > 1
		for i = 0 to array.size(result) - 1
			array.remove(mintickToArray, 0)
		joinTick = array.join(mintickToArray, '')
		getDecimals = math.log10(str.tonumber(joinTick)/syminfo.mintick)
		thenConvert = math.round(getDecimals)


// @function Creates bollinger bands out of any specified moving average
//
// #### Usage
// ___
// ```
// input_len = input.int(defval = 50, title = 'Moving Average Length')
// SMA = ta.sma(close, input_len)
// [bb_up, bb_mid, bb_dn] = bb(close, SMA, input_len, 4)
// ‎
// plot(bb_up)
// plot(bb_mid)
// plot(bb_dn)
// ```
// ___
// @param src				The source of the standard deviation. The default is `close` `Optional` 
// @param movingAverage 	A pre-defined moving average `Required`  
// @param maLength			The `length` of the moving average. `Required` 
// @param mult				The multiplier of both `up` and `dn` moving average offsets. `Required` 
// @returns `Bollinger bands` of the specified moving average.
export bb(series float src, series float movingAverage, series int maLength, series float mult) =>
    dev = mult * ta.stdev(src, maLength)
    [movingAverage, movingAverage + dev, movingAverage - dev]


// @function Parses `time` into a `date` string with optional time parameters.
//
// #### Usage
// ___
// ```
// table = table.new(position.middle_right, 20, 20)
// table.cell(table, 0, 0, str.tostring(getCurrentDate(true, 'America/Chicago')))
// ```
// *Visit https://en.wikipedia.org/wiki/List_of_tz_database_time_zones for zones*
// ___
// @param includeTime		Specifies Timestamp `Optional` 
// @param time_zone 		The specified time zone. The default is `syminfo.timezone` `Optional`
// @returns A `timestamp` of the current date.
export getCurrentDate(simple bool includeTime = true, string time_zone = syminfo.timezone) =>
	includeTime ? str.format_time(time, "MM-dd-yyyy HH:mm:ss", time_zone) : not includeTime ? str.format_time(time, "MM-dd-yyyy", time_zone) : na
````
