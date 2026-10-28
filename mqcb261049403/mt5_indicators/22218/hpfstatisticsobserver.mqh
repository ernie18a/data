//+------------------------------------------------------------------+
//|                                        HPFStatisticsObserver.mqh |
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
#ifndef HPFSTATISTICSOBSERVER_MQH
#define HPFSTATISTICSOBSERVER_MQH

#include "HPFObserver.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHPFStatisticsObserver : public CHPFObserver
  {
private:
   int               m_failures[];
   int               m_successes[];
public:
                     CHPFStatisticsObserver(int numPatterns);
                    ~CHPFStatisticsObserver();
   int               GetSuccesses(int patternIndex) { return m_successes[patternIndex]; }
   int               GetFailures(int patternIndex) { return m_failures[patternIndex]; }
   void              Reset() override;
   double            GetSuccessRate(int patternIndex);
   void              NotifyTransientMatch(int patternIndex,PATTERN_MATCH &match) override;
   void              NotifyPersistentMatch(int patternIndex,PATTERN_MATCH &match) override;
   void              NotifyStandardProjection(int patternIndex,PATTERN_MATCH &match) override;
   void              NotifyOneAheadProjection(int patternIndex,PATTERN_MATCH &match) override;
   void              NotifyOvershot(int patternIndex,PATTERN_MATCH &match) override;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHPFStatisticsObserver::CHPFStatisticsObserver(int numPatterns)
  {
   if(ArrayResize(m_successes,numPatterns)<numPatterns)
      printf("Error allocating array at "+__FUNCTION__+" code: "+IntegerToString(GetLastError()));
   if(ArrayResize(m_failures,numPatterns)<numPatterns)
      printf("Error allocating array at "+__FUNCTION__+" code: "+IntegerToString(GetLastError()));
   Reset();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHPFStatisticsObserver::~CHPFStatisticsObserver()
  {
   ArrayFree(m_successes);
   ArrayFree(m_failures);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHPFStatisticsObserver::Reset()
  {
   for(int i=0; i<ArraySize(m_successes); i++)
     {
      m_successes[i]=0;
      m_failures[i]=0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CHPFStatisticsObserver::GetSuccessRate(int patternIndex)
  {
   double success=m_successes[patternIndex];
   double total=success+m_failures[patternIndex];
   if(total!=0)
      return success/total;
   else
      return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHPFStatisticsObserver::NotifyPersistentMatch(int patternIndex,PATTERN_MATCH &match)
  {
   m_successes[patternIndex]=m_successes[patternIndex]+1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHPFStatisticsObserver::NotifyOvershot(int patternIndex,PATTERN_MATCH &match)
  {
   m_failures[patternIndex]=m_failures[patternIndex]+1;
  }
//--- UNUSED
void CHPFStatisticsObserver::NotifyStandardProjection(int patternIndex,PATTERN_MATCH &match) {}
void CHPFStatisticsObserver::NotifyOneAheadProjection(int patternIndex,PATTERN_MATCH &match) {}
void CHPFStatisticsObserver::NotifyTransientMatch(int patternIndex,PATTERN_MATCH &match) {}
//--- Header guard end
#endif
//+------------------------------------------------------------------+
