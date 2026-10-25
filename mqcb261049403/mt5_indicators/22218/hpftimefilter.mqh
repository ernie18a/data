//+------------------------------------------------------------------+
//|                                                HPFTimeFilter.mqh |
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
#ifndef HPFTIMEFILTER_MQH
#define HPFTIMEFILTER_MQH
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include "HPFFilter.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum HARMONIC_TIMELINESS
  {
   TOO_EARLY,
   TIMELY,
   TOO_LATE
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHPFTimeFilter : public CHPFFilter
  {
private:
   double            m_tooEarly;
   double            m_tooLate;
   bool              m_filterTooEarly;
   bool              m_filterTooLate;
   int               m_num4PointPatterns;
   double            m_low[];
   double            m_high[];
   int               m_bar;
public:
                     CHPFTimeFilter(int num4PointPatterns,double tooEarly,double tooLate);
                    ~CHPFTimeFilter();
   void              SetActivated(bool tooEarly,bool tooLate);
   //Yet another copied method
   bool              Is4PointPattern(int index) { return index<m_num4PointPatterns; }
   void              SetBar(int bar) { m_bar=bar; }
   bool              IsValidUndershot(int patternIndex,PATTERN_MATCH &match) override;
   bool              IsValidMatched(int patternIndex,PATTERN_MATCH &match) override;
   bool              IsValidOvershot(int patternIndex,PATTERN_MATCH &match) override;
   HARMONIC_TIMELINESS PatternTimeliness(int XIndex,int AIndex,int BIndex,int CIndex,int DIndex,bool is4P);
   int               PRZViolatingBar(bool bullish,int CIndex,int DIndex,double przEnd);
   void              SetPrices(const double &lowArr[],const double &highArr[]);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHPFTimeFilter::CHPFTimeFilter(int num4PointPatterns,double tooEarly,double tooLate)
  {
   m_tooEarly=tooEarly;
   m_tooLate=tooLate;
   m_num4PointPatterns=num4PointPatterns;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHPFTimeFilter::~CHPFTimeFilter()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHPFTimeFilter::SetActivated(bool tooEarly,bool tooLate)
  {
   m_filterTooEarly=tooEarly;
   m_filterTooLate=tooLate;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHPFTimeFilter::SetPrices(const double &lowArr[],const double &highArr[])
  {
   ArrayCopy(m_low,lowArr,0,0);
   ArrayCopy(m_high,highArr,0,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHPFTimeFilter::IsValidUndershot(int patternIndex,PATTERN_MATCH &match)
  {
   if(m_filterTooLate)
     {
      int XIndex=match.XIndex;
      int AIndex=match.AIndex;
      int BIndex=match.BIndex;
      int CIndex=match.CIndex;
      int DIndex=m_bar;
      HARMONIC_TIMELINESS timeliness=PatternTimeliness(XIndex,AIndex,BIndex,CIndex,DIndex,Is4PointPattern(patternIndex));
      return timeliness!=TOO_LATE;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHPFTimeFilter::IsValidMatched(int patternIndex,PATTERN_MATCH &match)
  {
   if(m_filterTooEarly || m_filterTooLate)
     {
      int XIndex=match.XIndex;
      int AIndex=match.AIndex;
      int BIndex=match.BIndex;
      int CIndex=match.CIndex;
      int DIndex=match.DIndex;
      HARMONIC_TIMELINESS timeliness=PatternTimeliness(XIndex,AIndex,BIndex,CIndex,DIndex,Is4PointPattern(patternIndex));
      if(m_filterTooEarly && timeliness==TOO_EARLY)
         return false;
      if(m_filterTooLate && timeliness==TOO_LATE)
         return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHPFTimeFilter::IsValidOvershot(int patternIndex,PATTERN_MATCH &match)
  {
   if(m_filterTooEarly || m_filterTooLate)
     {
      int XIndex=match.XIndex;
      int AIndex=match.AIndex;
      int BIndex=match.BIndex;
      int CIndex=match.CIndex;
      int DIndex=PRZViolatingBar(match.bullish,CIndex,match.DIndex,match.farD);
      HARMONIC_TIMELINESS timeliness=PatternTimeliness(XIndex,AIndex,BIndex,CIndex,DIndex,Is4PointPattern(patternIndex));
      if(m_filterTooEarly && timeliness==TOO_EARLY)
         return false;
      if(m_filterTooLate && timeliness==TOO_LATE)
         return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
HARMONIC_TIMELINESS CHPFTimeFilter::PatternTimeliness(int XIndex,int AIndex,int BIndex,int CIndex,int DIndex,bool is4P)
  {

   int baseBars;
   int fixBar;
   if(is4P)
     {
      baseBars=BIndex-AIndex;
      fixBar=CIndex;
     }
   else
     {
      baseBars=BIndex-XIndex;
      fixBar=BIndex;
     }
   if(DIndex<fixBar+MathFloor(m_tooEarly*baseBars))
      return TOO_EARLY;
   else if(DIndex<fixBar+MathCeil(m_tooLate*baseBars))
      return TIMELY;
   else
      return TOO_LATE;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CHPFTimeFilter::PRZViolatingBar(bool bullish,int CIndex,int DIndex,double przEnd)
  {
   for(int bar=CIndex; bar<=DIndex; bar++)
     {
      if(bullish && m_low[bar]<przEnd)
         return bar;
      if(!bullish && m_high[bar]>przEnd)
         return bar;
     }
   return -1;
  }
//+------------------------------------------------------------------+
//--- Header guard end
#endif
//+------------------------------------------------------------------+
