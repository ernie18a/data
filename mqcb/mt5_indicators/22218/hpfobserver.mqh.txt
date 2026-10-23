//+------------------------------------------------------------------+
//|                                                  HPFObserver.mqh |
//|                                  Copyright 2018, André S. Enger. |
//|                                          andre_enger@hotmail.com |
//|                                  Contribs                        |
//|                                         David Gadelha            |
//|                                               dgadelha@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"

//--- Header guard
#ifndef HPFOBSERVER_MQH
#define HPFOBSERVER_MQH

#include "HPFMatcher.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
interface CHPFObserver
  {
   void Reset();
   void NotifyTransientMatch(int patternIndex,PATTERN_MATCH &match);
   void NotifyPersistentMatch(int patternIndex,PATTERN_MATCH &match);
   void NotifyStandardProjection(int patternIndex,PATTERN_MATCH &match);
   void NotifyOneAheadProjection(int patternIndex,PATTERN_MATCH &match);
   void NotifyOvershot(int patternIndex,PATTERN_MATCH &match);
  };
//--- Header guard end
#endif
//+------------------------------------------------------------------+
