//+------------------------------------------------------------------+
//|                                                   SymbolsLib.mqh |
//|                                          Copyright © 2009, Ilnur |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+

// Header file describing SymbolsLib.ex4 library functions

#property copyright "Copyright © 2009, Ilnur"
#property link      "https://www.metaquotes.net"

#import "SymbolsLib.ex4"
   int SymbolsList(string &Symbols[], bool Selected);
/* 
   The function returns the list of financial instruments
   (enumerated in the Market Watch or all).
   
   Inputs:
      SymbolsList - string array of read instruments.
      Selected    - request mode. May be set to true or false.
                    true  - return the list of symbols enumerated in the Market Watch window. 
                    false - get the full list of symbols provided by a dealing center.

   Return value:
      [SymbolsNumber] - number of read instruments.
*/

   string SymbolDescription(string SymbolName);
/* 
   Get the decrypted name of the specified 
   financial instrument.
   
   Inputs:
      SymbolName - text string with the name of the financial instrument.
*/

   string SymbolType(string SymbolName);
/* 
   Get the type of the financial instrument.
   
   Inputs:
      SymbolName - text string with the name of the financial instrument.
*/

#import