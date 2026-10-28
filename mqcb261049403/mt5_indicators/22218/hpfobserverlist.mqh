//+------------------------------------------------------------------+
//|                                              HPFObserverList.mqh |
//|                                  Copyright 2018, André S. Enger. |
//|                                          andre_enger@hotmail.com |
//|                                  Contribs                        |
//|                                         David Gadelha            |
//|                                               dgadelha@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"

#include "HPFObserver.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHPFObserverList : public CHPFObserver
  {
private:
   CHPFObserver     *m_observers[];
public:
                     CHPFObserverList(int size);
                    ~CHPFObserverList();
   void              Set(int index,CHPFObserver *observer) { m_observers[index]=observer; }
   void              Reset() override;
   void              NotifyTransientMatch(int patternIndex,PATTERN_MATCH &match) override;
   void              NotifyPersistentMatch(int patternIndex,PATTERN_MATCH &match) override;
   void              NotifyStandardProjection(int patternIndex,PATTERN_MATCH &match) override;
   void              NotifyOneAheadProjection(int patternIndex,PATTERN_MATCH &match) override;
   void              NotifyOvershot(int patternIndex,PATTERN_MATCH &match) override;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHPFObserverList::CHPFObserverList(int size)
  {
   if(ArrayResize(m_observers,size)<size)
      printf("Error allocating array at "+__FUNCTION__+" code: "+IntegerToString(GetLastError()));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHPFObserverList::~CHPFObserverList()
  {
   ArrayFree(m_observers);
  }
//+------------------------------------------------------------------+
void CHPFObserverList::Reset()
  {
   for(int i=0; i<ArraySize(m_observers); i++)
      m_observers[i].Reset();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHPFObserverList::NotifyPersistentMatch(int patternIndex,PATTERN_MATCH &match)
  {
   for(int i=0; i<ArraySize(m_observers); i++)
      m_observers[i].NotifyPersistentMatch(patternIndex,match);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHPFObserverList::NotifyOvershot(int patternIndex,PATTERN_MATCH &match)
  {
   for(int i=0; i<ArraySize(m_observers); i++)
      m_observers[i].NotifyOvershot(patternIndex,match);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHPFObserverList::NotifyStandardProjection(int patternIndex,PATTERN_MATCH &match)
  {
   for(int i=0; i<ArraySize(m_observers); i++)
      m_observers[i].NotifyStandardProjection(patternIndex,match);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHPFObserverList::NotifyOneAheadProjection(int patternIndex,PATTERN_MATCH &match)
  {
   for(int i=0; i<ArraySize(m_observers); i++)
      m_observers[i].NotifyOneAheadProjection(patternIndex,match);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHPFObserverList::NotifyTransientMatch(int patternIndex,PATTERN_MATCH &match)
  {
   for(int i=0; i<ArraySize(m_observers); i++)
      m_observers[i].NotifyTransientMatch(patternIndex,match);
  }
//+------------------------------------------------------------------+
