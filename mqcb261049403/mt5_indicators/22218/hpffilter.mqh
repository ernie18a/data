//+------------------------------------------------------------------+
//|                                                    HPFFilter.mqh |
//|                                  Copyright 2018, André S. Enger. |
//|                                          andre_enger@hotmail.com |
//|                                  Contribs                        |
//|                                         David Gadelha            |
//|                                               dgadelha@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--- Header guard
#ifndef HPFFILTER_MQH
#define HPFFILTER_MQH

#include "HPFMatcher.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
interface CHPFFilter
  {
   bool IsValidUndershot(int patternIndex,PATTERN_MATCH &match);
   bool IsValidMatched(int patternIndex,PATTERN_MATCH &match);
   bool IsValidOvershot(int patternIndex,PATTERN_MATCH &match);
  };
//--- Header guard end
#endif
//+------------------------------------------------------------------+
