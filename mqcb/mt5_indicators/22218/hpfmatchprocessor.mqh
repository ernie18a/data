//+------------------------------------------------------------------+
//|                                            HPFMatchProcessor.mqh |
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
#ifndef HPFMATCHPROCESSOR_MQH
#define HPFMATCHPROCESSOR_MQH
//--- Communicates pattern matches
struct PATTERN_MATCH
  {
   bool              bullish;
   int               XIndex;
   int               AIndex;
   int               BIndex;
   int               CIndex;
   int               DIndex;
   double            X;
   double            A;
   double            B;
   double            C;
   double            nearD;
   double            farD;
                     PATTERN_MATCH() {}
                     PATTERN_MATCH(const PATTERN_MATCH &other)
     {
      bullish=other.bullish;
      XIndex=other.XIndex;
      AIndex=other.AIndex;
      BIndex=other.BIndex;
      CIndex=other.CIndex;
      DIndex=other.DIndex;
      X=other.X;
      A=other.A;
      B=other.B;
      C=other.C;
      nearD=other.nearD;
      farD=other.farD;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
interface CHPFMatchProcessor
  {
   void PatternUndershot(PATTERN_MATCH &match);
   void PatternMatched(PATTERN_MATCH &match);
   void PatternOvershot(PATTERN_MATCH &match);
  };
//--- Header guard end
#endif
//+------------------------------------------------------------------+
