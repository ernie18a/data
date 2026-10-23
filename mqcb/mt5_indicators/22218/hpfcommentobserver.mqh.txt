//+------------------------------------------------------------------+
//|                                           HPFCommentObserver.mqh |
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
#ifndef HPFCOMMENTOBSERVER_MQH
#define HPFCOMMENTOBSERVER_MQH

#include "HPFGlobals.mqh"
#include "HPFObserver.mqh"
#include "HPFIndicator.mqh"
#include "HPFStatisticsObserver.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHPFCommentObserver : public CHPFObserver
  {
private:
   CHPFRingbuffer    m_buffer[];
   CHPFStatisticsObserver *m_statistics;
   string            m_com1,m_com2,m_com3,m_com4,m_com5,m_com6,m_com7,m_com8,m_com9;
   bool              m_comment;
public:
                     CHPFCommentObserver(int numPatterns,int duration,bool showComment);
                    ~CHPFCommentObserver();
   void              SetStatistics(CHPFStatisticsObserver *observer) { m_statistics=observer; }
   //---
   void              ShowComment(string sComment);
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
CHPFCommentObserver::CHPFCommentObserver(int numPatterns,int duration,bool showComment)
  {
   if(ArrayResize(m_buffer,numPatterns)<numPatterns)
      printf("Error allocating array at "+__FUNCTION__+" code: "+IntegerToString(GetLastError()));
   for(int i=0; i<numPatterns; i++)
      m_buffer[i].SetDuration(duration);
   m_comment=showComment;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHPFCommentObserver::~CHPFCommentObserver()
  {
   ArrayFree(m_buffer);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHPFCommentObserver::ShowComment(string sComment)
  {
   if(m_comment)
     {
      if(sComment!=m_com1)
        {
         m_com9=m_com8; //--- discards last comment line
         m_com8=m_com7; //--- and shifts
         m_com7=m_com6;
         m_com6=m_com5;
         m_com5=m_com4;
         m_com4=m_com3;
         m_com3=m_com2;
         m_com2=m_com1;
         m_com1=sComment;
        }
      Comment("HarmonicPatternFinderV3 © 2018","\n","\n",m_com1,"\n",m_com2,"\n",m_com3,"\n",m_com4,"\n",m_com5,"\n",m_com6,"\n",m_com7,"\n",m_com8,"\n",m_com9,"\n");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHPFCommentObserver::Reset()
  {
   for(int i=0; i<ArraySize(m_buffer); i++)
      m_buffer[i].Reset();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHPFCommentObserver::NotifyTransientMatch(int patternIndex,PATTERN_MATCH &match)
  {
   bool bullish=match.bullish;
   int DIndex=match.DIndex;
   datetime DDateTime=_time[DIndex];
//--- check if already printed
   int tail=m_buffer[patternIndex].GetTail();
   int head=m_buffer[patternIndex].GetHead();
   int capacity=m_buffer[patternIndex].GetCapacity();
   for(int i=tail; i!=head; i=(i+1)%capacity)
     {
      int numMatches=0;
      PATTERN_MATCH stored=m_buffer[patternIndex].GetMatch(i);
      if(!Is4PointPattern(patternIndex) && stored.XIndex==match.XIndex) numMatches++;
      if(stored.AIndex==match.AIndex) numMatches++;
      if(stored.BIndex==match.BIndex) numMatches++;
      if(stored.CIndex==match.CIndex) numMatches++;
      //if(stored.DIndex==match.DIndex) numMatches++;
      //--- If (X), A, B, C are the same, this is same pattern
      if(numMatches>=3+(Is4PointPattern(patternIndex)?0:1))
         return;
     }
   m_buffer[patternIndex].Add(match);
//----
   string comment=bullish? "T. Bull. " : "T. Bear. ";
   comment+=_patternNames[patternIndex];
   comment+=" @ "+TimeToString(DDateTime);
   comment+=" Prob. "+DoubleToString(m_statistics.GetSuccessRate(patternIndex)*100,2);
   ShowComment(comment);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHPFCommentObserver::NotifyPersistentMatch(int patternIndex,PATTERN_MATCH &match)
  {
   bool bullish=match.bullish;
   int DIndex=match.DIndex;
   datetime DDateTime=_time[DIndex];
   string comment=bullish? "P. Bull. " : "P. Bear. ";
   comment+=_patternNames[patternIndex];
   comment+=" @ "+TimeToString(DDateTime);
   comment+=" Prob. "+DoubleToString(m_statistics.GetSuccessRate(patternIndex)*100,2);
   ShowComment(comment);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHPFCommentObserver::NotifyOvershot(int patternIndex,PATTERN_MATCH &match)
  {
   bool bullish=match.bullish;
   int DIndex=match.DIndex;
   datetime DDateTime=_time[DIndex];
   string comment=bullish? "O. Bull. " : "O. Bear. ";
   comment+=_patternNames[patternIndex];
   comment+=" @ "+TimeToString(DDateTime);
   comment+=" Prob. "+DoubleToString(m_statistics.GetSuccessRate(patternIndex)*100,2);
//comment+="X="+match.XIndex+", A="+match.AIndex+", B="+match.BIndex+", C="+match.CIndex;
   ShowComment(comment);
  }
void CHPFCommentObserver::NotifyStandardProjection(int patternIndex,PATTERN_MATCH &match) {}
void CHPFCommentObserver::NotifyOneAheadProjection(int patternIndex,PATTERN_MATCH &match) {}
//+------------------------------------------------------------------+
//--- Header guard end
#endif
//+------------------------------------------------------------------+
