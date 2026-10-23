//+------------------------------------------------------------------+
//|                                                HPFFilterList.mqh |
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
#ifndef HPFFILTERLIST_MQH
#define HPFFILTERLIST_MQH
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include "HPFFilter.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHPFFilterList : public CHPFFilter
  {
private:
   CHPFFilter       *m_filters[];
public:
                     CHPFFilterList(int size);
                    ~CHPFFilterList();
   void              Set(int index,CHPFFilter *filter) { m_filters[index]=filter; }
   bool              IsValidUndershot(int patternIndex,PATTERN_MATCH &match) override;
   bool              IsValidMatched(int patternIndex,PATTERN_MATCH &match) override;
   bool              IsValidOvershot(int patternIndex,PATTERN_MATCH &match) override;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHPFFilterList::CHPFFilterList(int size)
  {
   if(ArrayResize(m_filters,size)<size)
      printf("Error allocating array at "+__FUNCTION__+" code: "+IntegerToString(GetLastError()));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHPFFilterList::~CHPFFilterList()
  {
   ArrayFree(m_filters);
  }
//+------------------------------------------------------------------+

bool CHPFFilterList::IsValidUndershot(int patternIndex,PATTERN_MATCH &match)
  {
   for(int i=0; i<ArraySize(m_filters); i++)
      if(!m_filters[i].IsValidUndershot(patternIndex,match))
         return false;
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHPFFilterList::IsValidMatched(int patternIndex,PATTERN_MATCH &match)
  {
   for(int i=0; i<ArraySize(m_filters); i++)
      if(!m_filters[i].IsValidMatched(patternIndex,match))
         return false;
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHPFFilterList::IsValidOvershot(int patternIndex,PATTERN_MATCH &match)
  {
   for(int i=0; i<ArraySize(m_filters); i++)
      if(!m_filters[i].IsValidOvershot(patternIndex,match))
         return false;
   return true;
  }
//--- Header guard end
#endif
//+------------------------------------------------------------------+
