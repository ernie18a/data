//+------------------------------------------------------------------+
//|                                                 HPFIndicator.mqh |
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
#ifndef HPFINDICATOR_MQH
#define HPFINDICATOR_MQH

#include "HPFMatcher.mqh"
#include "HPFRingbuffer.mqh"
#include "HPFObserver.mqh"
#include "HPFFilter.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHPFIndicator : public CHPFMatchProcessor
  {
private:
   CHPFRingbuffer    m_undershot;
   CHPFRingbuffer    m_matched;
   CHPFRingbuffer    m_overshot;
   CHPFRingbuffer    m_matchedPersistent[];
   CHPFRingbuffer    m_matchedTransient[];
   CHPFRingbuffer    m_overshotPersistent[];
   int               m_maxOverlap;
   int               m_num4PointPatterns;
   int               m_patternIndex;
   CHPFObserver     *m_observer;
   CHPFFilter       *m_filter;
public:
                     CHPFIndicator(int numPatterns,int num4PointPatterns,int duration);
                    ~CHPFIndicator();
   void              SetMaxOverlap(int maxOverlap)          { m_maxOverlap=maxOverlap; }
   bool              Is4PointPattern(int index)             { return index<m_num4PointPatterns; }
   CHPFRingbuffer   *GetMatchedPersistent(int patternIndex) { return &m_matchedPersistent[patternIndex]; }
   CHPFRingbuffer   *GetMatchedTransient(int patternIndex)  { return &m_matchedTransient[patternIndex]; }
   void              SetObserver(CHPFObserver *observer)    { m_observer=observer; }
   void              SetFilter(CHPFFilter *filter)          { m_filter=filter; }
   void              ClearTransient();
   void              Reset();
   void              PreFind(int patternIndex) { m_patternIndex=patternIndex; }
   void              PostFind(int patternIndex,int lastPeak,int lastTrough,bool endsInTrough);
   bool              Overlaps(int patternIndex,PATTERN_MATCH &match);
   bool              OverlapsOvershot(int patternIndex,PATTERN_MATCH &match);
   void              PersistTransient();

   void              PatternUndershot(PATTERN_MATCH &match) override;
   void              PatternMatched(PATTERN_MATCH &match) override;
   void              PatternOvershot(PATTERN_MATCH &match) override;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHPFIndicator::CHPFIndicator(int numPatterns,int num4PointPatterns,int duration)
  {
   if(ArrayResize(m_matchedPersistent,numPatterns)<numPatterns)
      printf("Error allocating array at "+__FUNCTION__+" code: "+IntegerToString(GetLastError()));
   if(ArrayResize(m_matchedTransient,numPatterns)<numPatterns)
      printf("Error allocating array at "+__FUNCTION__+" code: "+IntegerToString(GetLastError()));
   if(ArrayResize(m_overshotPersistent,numPatterns)<numPatterns)
      printf("Error allocating array at "+__FUNCTION__+" code: "+IntegerToString(GetLastError()));
   for(int i=0; i<numPatterns; i++)
     {
      m_matchedPersistent[i].SetDuration(duration);
      m_overshotPersistent[i].SetDuration(duration);
     }
   m_maxOverlap=0;
   m_num4PointPatterns=num4PointPatterns;
   m_observer=NULL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHPFIndicator::~CHPFIndicator()
  {
   ArrayFree(m_matchedPersistent);
   ArrayFree(m_matchedTransient);
   ArrayFree(m_overshotPersistent);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHPFIndicator::Reset()
  {
   m_observer.Reset();
   ClearTransient();
   for(int i=0; i<ArraySize(m_matchedPersistent); i++)
     {
      m_matchedPersistent[i].Reset();
      m_overshotPersistent[i].Reset();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHPFIndicator::ClearTransient()
  {
   m_undershot.Reset();
   m_matched.Reset();
   m_overshot.Reset();
   for(int i=0; i<ArraySize(m_matchedTransient); i++)
      m_matchedTransient[i].Reset();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHPFIndicator::PersistTransient()
  {
   for(int k=0; k<ArraySize(m_matchedPersistent); k++)
     {
      int tail=m_matchedTransient[k].GetTail();
      int head=m_matchedTransient[k].GetHead();
      int capacity=m_matchedTransient[k].GetCapacity();
      for(int j=tail; j!=head; j=(j+1)%capacity)
        {
         PATTERN_MATCH match=m_matchedTransient[k].GetMatch(j);
         m_matchedPersistent[k].Add(match);
         m_observer.NotifyPersistentMatch(k,match);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHPFIndicator::PostFind(int patternIndex,int lastPeak,int lastTrough,bool endsInTrough)
  {
//--- Go trough matches
   m_matched.SortDIndex();
   int tail=m_matched.GetTail();
   int head=m_matched.GetHead();
   int capacity=m_matched.GetCapacity();
   for(int i=tail; i!=head; i=(i+1)%capacity)
     {
      PATTERN_MATCH match=m_matched.GetMatch(i);
      if(!Overlaps(patternIndex,match))
        {
         bool bullish=match.bullish;
         int DIndex=match.DIndex;
         bool activeSwing=endsInTrough && bullish && DIndex==lastTrough;
         activeSwing|=!endsInTrough && !bullish && DIndex==lastPeak;
         if(activeSwing)
           {
            m_matchedTransient[patternIndex].Add(match);
            m_observer.NotifyTransientMatch(patternIndex,match);
           }
         else
           {
            m_matchedPersistent[patternIndex].Add(match);
            m_observer.NotifyPersistentMatch(patternIndex,match);
           }
        }
     }
//--- Go trough projections
   m_undershot.SortNearD();
   tail=m_undershot.GetTail();
   head=m_undershot.GetHead();
   capacity=m_undershot.GetCapacity();
//--- Bearish projections
   for(int i=tail; i!=head; i=(i+1)%capacity)
     {
      PATTERN_MATCH match=m_undershot.GetMatch(i);
      bool bullish=match.bullish;
      int CIndex=match.CIndex;
      int DIndex=match.DIndex;
      match.DIndex=-1; //--- Don't compare DIndex for overlaps in projections
      if(!bullish && !Overlaps(patternIndex,match))
        {
         bool nonOverlapping=true;
         if(i!=tail)
           {
            int j=((i-1)%capacity+capacity)%capacity;
            while(true)
              {
               PATTERN_MATCH match2=m_undershot.GetMatch(j);
               match2.DIndex=-1;
               if(!match2.bullish && !Overlaps(patternIndex,match2))
                 {
                  int numMatches=0;
                  if(!Is4PointPattern(patternIndex) && match2.XIndex==match.XIndex) numMatches++;
                  if(match2.AIndex==match.AIndex) numMatches++;
                  if(match2.BIndex==match.BIndex) numMatches++;
                  if(match2.CIndex==match.CIndex) numMatches++;
                  if(numMatches>m_maxOverlap)
                    {
                     nonOverlapping=false;
                     break;
                    }
                 }
               if(j==tail)
                  break;
               j=((j-1)%capacity+capacity)%capacity;
              }
           }
         if(nonOverlapping)
           {
            match.DIndex=DIndex;
            bool imaginaryD=((bullish && CIndex==lastPeak && lastTrough<=lastPeak)
                             || (!bullish && CIndex==lastTrough && lastPeak<=lastTrough));
            if(imaginaryD && lastPeak==lastTrough)
               imaginaryD &=(bullish && !endsInTrough) || (!bullish && endsInTrough);
            if(imaginaryD)
               m_observer.NotifyOneAheadProjection(patternIndex,match);
            else
               m_observer.NotifyStandardProjection(patternIndex,match);
           }
        }
     }
//--- Bullish projections
   if(head!=tail)
     {
      int i=((head-1)%capacity+capacity)%capacity;
      while(true)
        {
         PATTERN_MATCH match=m_undershot.GetMatch(i);
         bool bullish=match.bullish;
         int CIndex=match.CIndex;
         int DIndex=match.DIndex;
         match.DIndex=-1;
         if(bullish && !Overlaps(patternIndex,match))
           {
            bool nonOverlapping=true;
            if(i!=((head-1)%capacity+capacity)%capacity)
              {
               for(int j=(i+1)%capacity; j!=head; j=(j+1)%capacity)
                 {
                  PATTERN_MATCH match2=m_undershot.GetMatch(j);
                  match2.DIndex=-1;
                  if(match2.bullish && !Overlaps(patternIndex,match2))
                    {
                     int numMatches=0;
                     if(!Is4PointPattern(patternIndex) && match2.XIndex==match.XIndex) numMatches++;
                     if(match2.AIndex==match.AIndex) numMatches++;
                     if(match2.BIndex==match.BIndex) numMatches++;
                     if(match2.CIndex==match.CIndex) numMatches++;
                     if(numMatches>m_maxOverlap)
                       {
                        nonOverlapping=false;
                        break;
                       }
                    }
                 }
              }
            if(nonOverlapping)
              {
               match.DIndex=DIndex;
               bool imaginaryD=((bullish && CIndex==lastPeak && lastTrough<=lastPeak)
                                || (!bullish && CIndex==lastTrough && lastPeak<=lastTrough));
               if(imaginaryD && lastPeak==lastTrough)
                  imaginaryD &=(bullish && !endsInTrough) || (!bullish && endsInTrough);
               if(imaginaryD)
                  m_observer.NotifyOneAheadProjection(patternIndex,match);
               else
                  m_observer.NotifyStandardProjection(patternIndex,match);
              }
           }
         if(i==tail)
            break;
         i=((i-1)%capacity+capacity)%capacity;
        }
     }

//--- Overshot patterns for fail-rate
   m_overshot.SortDIndex();
   tail=m_overshot.GetTail();
   head=m_overshot.GetHead();
   capacity=m_overshot.GetCapacity();
   for(int i=tail; i!=head; i=(i+1)%capacity)
     {
      PATTERN_MATCH match=m_overshot.GetMatch(i);
      if(!Overlaps(patternIndex,match) && !OverlapsOvershot(patternIndex,match))
        {
         m_overshotPersistent[patternIndex].Add(match);
         m_observer.NotifyOvershot(patternIndex,match);
        }
     }
//--- Reset heads/tails for next call
   m_undershot.Reset();
   m_matched.Reset();
   m_overshot.Reset();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHPFIndicator::OverlapsOvershot(int patternIndex,PATTERN_MATCH &match)
  {
   int tail = m_overshotPersistent[patternIndex].GetTail();
   int head = m_overshotPersistent[patternIndex].GetHead();
   int capacity=m_overshotPersistent[patternIndex].GetCapacity();
   for(int i=tail; i!=head; i=(i+1)%capacity)
     {
      int numMatches=0;
      PATTERN_MATCH stored=m_overshotPersistent[patternIndex].GetMatch(i);
      if(!Is4PointPattern(patternIndex) && stored.XIndex==match.XIndex) numMatches++;
      if(stored.AIndex==match.AIndex) numMatches++;
      if(stored.BIndex==match.BIndex) numMatches++;
      if(stored.CIndex==match.CIndex) numMatches++;
      //--- If (X), A, B, C are the same, this is same pattern
      if(numMatches>=3+(Is4PointPattern(patternIndex)?0:1))
         return true;
      //--- Check D index
      if(stored.DIndex==match.DIndex) numMatches++;
      if(numMatches>m_maxOverlap)
         return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHPFIndicator::Overlaps(int patternIndex,PATTERN_MATCH &match)
  {
   int tail = m_matchedPersistent[patternIndex].GetTail();
   int head = m_matchedPersistent[patternIndex].GetHead();
   int capacity=m_matchedPersistent[patternIndex].GetCapacity();
   for(int i=tail; i!=head; i=(i+1)%capacity)
     {
      int numMatches=0;
      PATTERN_MATCH stored=m_matchedPersistent[patternIndex].GetMatch(i);
      if(!Is4PointPattern(patternIndex) && stored.XIndex==match.XIndex) numMatches++;
      if(stored.AIndex==match.AIndex) numMatches++;
      if(stored.BIndex==match.BIndex) numMatches++;
      if(stored.CIndex==match.CIndex) numMatches++;
      //--- If (X), A, B, C are the same, this is same pattern
      if(numMatches>=3+(Is4PointPattern(patternIndex)?0:1))
         return true;
      //--- Check D index
      if(stored.DIndex==match.DIndex) numMatches++;
      if(numMatches>m_maxOverlap)
         return true;
     }
   tail = m_matchedTransient[patternIndex].GetTail();
   head = m_matchedTransient[patternIndex].GetHead();
   capacity=m_matchedTransient[patternIndex].GetCapacity();
   for(int i=tail; i!=head; i=(i+1)%capacity)
     {
      int numMatches=0;
      PATTERN_MATCH stored=m_matchedTransient[patternIndex].GetMatch(i);
      if(!Is4PointPattern(patternIndex) && stored.XIndex==match.XIndex) numMatches++;
      if(stored.AIndex==match.AIndex) numMatches++;
      if(stored.BIndex==match.BIndex) numMatches++;
      if(stored.CIndex==match.CIndex) numMatches++;
      //--- If (X), A, B, C are the same, this is same pattern
      if(numMatches>=3+(Is4PointPattern(patternIndex)?0:1))
         return true;
      //--- Check D index
      if(stored.DIndex==match.DIndex) numMatches++;
      if(numMatches>m_maxOverlap)
         return true;
     }
   return false;
  }
//+------------------------------------------------------------------+

void CHPFIndicator::PatternUndershot(PATTERN_MATCH &match)
  {
   if(m_filter.IsValidUndershot(m_patternIndex,match))
      m_undershot.Add(match);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHPFIndicator::PatternMatched(PATTERN_MATCH &match)
  {
   if(m_filter.IsValidMatched(m_patternIndex,match))
      m_matched.Add(match);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHPFIndicator::PatternOvershot(PATTERN_MATCH &match)
  {
   if(m_filter.IsValidOvershot(m_patternIndex,match))
      m_overshot.Add(match);
  }
//+------------------------------------------------------------------+
//--- Header guard end
#endif
//+------------------------------------------------------------------+
