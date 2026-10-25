//+------------------------------------------------------------------+
//|                                   Regular Expressions Tester.mq4 |
//|                                        Copyright © 2018, Amr Ali |
//|                             https://www.mql5.com/en/users/amrali |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Amr Ali"
#property link      "https://www.mql5.com/en/users/amrali"
#property version   "1.000"
#property description "The tester covers most forms of the general usage for working with regular expressions"
#property description "For more advanced examples, please refer to \\MQL4\\Experts\\RegExpressions Demo\\Tests.mq4"
#property script_show_inputs

#include <RegularExpressions\Regex.mqh>

input string  InpPatt = "(?in)\\b(\\w+)\\b";                            // pattern
input string  InpText = "The quick brown fox jumps over the lazy dog";  // text
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {

   Print("pattern: ",InpPatt);
   Print("text: ",InpText);

// Create a new regex object
   CRegex *rgx=new CRegex(InpPatt);

   Print("----------------- CRegex.IsMatch() demo -----------------");
//--- IsMatch() method
   PrintFormat("pattern %s found.",rgx.IsMatch(InpText) ? "is" : "is not");

   Print("----------------- CRegex.Matches() demo -----------------");
//--- Matches() method
   CMatchCollection *matches=rgx.Matches(InpText);

   for(int i=0; i<matches.Count(); i++)
      PrintFormat("[%d] => %s",i,matches[i].Value());
   PrintFormat("%d matches were found.",matches.Count());

   Print("----------------- CRegex.Replace() demo -----------------");
//--- Replace() method
   string replacement="[$&]";
   string result=rgx.Replace(InpText,replacement);

   PrintFormat("Original String: %s",InpText);
   PrintFormat("Replacement String: %s",result);

   Print("----------------- CRegex.Split() demo -----------------");
// note, this is a different pattern for Split()
   CRegex *rgx2=new CRegex("the",RegexOptions::IgnoreCase);
   Print("pattern: ",rgx2.ToString());

//--- Split() method
   string parts[];
   rgx2.Split(parts,InpText);

   for(int i=0; i<ArraySize(parts); i++)
     {
      PrintFormat("[%d] => %s",i,parts[i]);
     }
   PrintFormat("%d pieces were found.",ArraySize(parts));

   delete matches;
   delete rgx;
   delete rgx2;

   CRegex::ClearCache();
  }
//+------------------------------------------------------------------+

// The script allows you to try regular expressions.

// Materials on regular expressions:

// The article "Regular expressions for traders"
// https://www.mql5.com/en/articles/2432

// The library RegularExpressions in MQL4 for working with regular expressions
// https://www.mql5.com/en/code/16566

// .NET Regular Expressions
// https://docs.microsoft.com/en-us/dotnet/standard/base-types/regular-expressions

// .NET Regex Class
// https://docs.microsoft.com/en-us/dotnet/api/system.text.regularexpressions.regex?view=netframework-4.7.1

// Using Regular Expressions with The Microsoft .NET Framework
// https://www.regular-expressions.info/dotnet.html

// As Regex object instance "constructor call"

// CRegex* rgx = new CRegex("regex");
// rgx.IsMatch("subject")                     Checks whether the regular expression finds a match in the input string.
// rgx.Matches("subject")                     Searches an input string for all occurrences of a regular expression and returns all the matches.
// rgx.Replace("subject", "replacement")      In a specified input string, replaces strings that match a regular expression pattern with a specified replacement string.
// rgx.Split(array, "Subject")                Splits the subject string along regex matches, returning an array of strings. The array contains the text between the regex matches (i.e, performs inverse match).

// As Static methods

// CRegex::IsMatch("subject", "regex")
// CRegex::Matches("subject", "regex")
// CRegex::Replace("subject", "regex", "replacement")
// CRegex::Split(array, "subject", "regex")
