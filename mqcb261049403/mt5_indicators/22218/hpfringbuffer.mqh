//+------------------------------------------------------------------+
//|                                                HPFRingbuffer.mqh |
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
#ifndef HPFRINGBUFFER_MQH
#define HPFRINGBUFFER_MQH

#include "HPFMatcher.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHPFRingbuffer
  {
private:
   PATTERN_MATCH     m_matches[];
   int               m_head;
   int               m_tail;
   int               m_capacity;
   int               m_duration;
public:
                     CHPFRingbuffer();
                    ~CHPFRingbuffer() { ArrayFree(m_matches); }
   int               GetHead()                  { return m_head; }
   int               GetTail()                  { return m_tail; }
   int               GetCapacity()              { return m_capacity; }
   PATTERN_MATCH     GetMatch(int i)            { return m_matches[i]; }
   void              SetDuration(int duration)  { m_duration=duration; }
   void              Reset()                    { m_tail=m_head=0; }
   void              Add(PATTERN_MATCH &match);
   void              SortNearD();
   void              SortDIndex();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHPFRingbuffer::CHPFRingbuffer()
  {
   m_capacity=2;
   m_duration=INT_MAX;
   Reset();
   if(ArrayResize(m_matches,m_capacity)<m_capacity)
      printf("Error allocating array at "+__FUNCTION__+" code: "+IntegerToString(GetLastError()));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHPFRingbuffer::Add(PATTERN_MATCH &match)
  {
   m_matches[m_head]=match;
   m_head=(m_head+1)%m_capacity;
   if(m_head==m_tail)
     {
      if(MathAbs(match.DIndex-m_matches[m_tail].DIndex)>m_duration)
         m_tail=(m_tail+1)%m_capacity;
      else
        {
         //TODO: more efficient (O(N)) buffer rotation
         for(int rounds=0; rounds<m_tail; rounds++)
           {
            PATTERN_MATCH tmp=m_matches[0];
            for(int i=0; i<m_capacity-1; i++)
              {
               m_matches[i]=m_matches[i+1];
              }
            m_matches[m_capacity-1]=tmp;
           }
         //end TODO
         m_tail=0;
         m_head=m_capacity;
         m_capacity*=2;
         if(ArrayResize(m_matches,m_capacity)<m_capacity)
            printf("Error allocating array at "+__FUNCTION__+" code: "+IntegerToString(GetLastError()));
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHPFRingbuffer::SortNearD()
  {
   for(int i=(m_tail+1)%m_capacity; i!=m_head; i=(i+1)%m_capacity)
     {
      int j=i;
      int jminus1=((j-1)%m_capacity+m_capacity)%m_capacity;
      while(j!=m_tail && m_matches[jminus1].nearD>m_matches[j].nearD)
        {
         PATTERN_MATCH tmp=m_matches[j];
         m_matches[j]=m_matches[jminus1];
         m_matches[jminus1]=tmp;
         j=jminus1;
         jminus1=((j-1)%m_capacity+m_capacity)%m_capacity;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHPFRingbuffer::SortDIndex()
  {
   for(int i=(m_tail+1)%m_capacity; i!=m_head; i=(i+1)%m_capacity)
     {
      int j=i;
      int jminus1=((j-1)%m_capacity+m_capacity)%m_capacity;
      while(j!=m_tail && m_matches[jminus1].DIndex>m_matches[j].DIndex)
        {
         PATTERN_MATCH tmp=m_matches[j];
         m_matches[j]=m_matches[jminus1];
         m_matches[jminus1]=tmp;
         j=jminus1;
         jminus1=((j-1)%m_capacity+m_capacity)%m_capacity;
        }
     }
  }

//--- End header guard
#endif
//+------------------------------------------------------------------+
