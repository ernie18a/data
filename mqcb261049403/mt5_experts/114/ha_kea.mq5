//+------------------------------------------------------------------+
//|                                  Heiken_Ashi based EA simplified |
//|                                              Copyright 2010, kur |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, kurl"
#property link      "https://forge.mql5.io"
#property description "suitable pair and timeframe;"
#property description "-- EURAUD ,..."
#property description "-- H1"
#include <Trade\Trade.mqh>
//---parameters
input char P=3;//position
double Lots=0.1;
ulong MAGIC=300510020;
string Unq="expHA_";
ulong Slp=50,Spp=300;
//---global_variables
double ST,CP,SP;char Cnt,xP,V,D;
string TM;
//---ins
CTrade kEA;
//---handle
int h_HA;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Cnt=0;xP=P;SP=Spp*_Point;
   if(xP<=0 || xP>CHAR_MAX)xP=1;Print((string)xP);
   h_HA=iCustom(_Symbol,_Period,"Examples\\Heiken_Ashi");

   kEA.SetExpertMagicNumber(MAGIC);
   kEA.SetDeviationInPoints(Slp);

   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   return;
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---- new bar
   long v[1];
   if(CopyTickVolume(_Symbol,_Period,0,1,v)!=1)return;
   if(v[0]>xP)return;
   if(v[0]==1)Chk();
   V=(char)v[0];

//---- order
   if(D)Sb(D);

   return;
  }
//+------------------------------------------------------------------+
//| sub functions                                                    |
//+------------------------------------------------------------------+
void Sb(char d)
  {
   CP=SymbolInfoDouble(_Symbol,d>0?SYMBOL_ASK:SYMBOL_BID);
   TM=TimeToString(SymbolInfoInteger(_Symbol,SYMBOL_TIME));
   if(GetVol()*d<0)ClzPos();
   double r=CP-ST;
   string bs=d>0?"B":"S";
   if((r*d<0) || (MathAbs(r)<SP))return;
   double ml=AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
   if(ml>0 && ml<120.0)return;
   if(Cnt*d<xP)OpenPos(d,Unq+bs+(string)Cnt);
   return;
  }
//---
double GetVol()
  {
   if(!PositionSelect(_Symbol))
      return(0.0);

   double vol=PositionGetDouble(POSITION_VOLUME);
   if(PositionGetInteger(POSITION_TYPE)!=(long)POSITION_TYPE_BUY)vol=-vol;

   return(NormalizeDouble(vol,2));
  }
//---
void ClzPos()
  {
   if(kEA.PositionClose(_Symbol,Slp))Cnt=0;
   return;
  }
//----
void OpenPos(char d,string com)
  {
   if(kEA.PositionOpen(_Symbol, d>0? ORDER_TYPE_BUY:ORDER_TYPE_SELL,Lots, CP, ST, 0, com))Cnt+=d;
   return;
  }
//---
void Chk()
  {
   if(MathAbs(GetVol())<0.10)Cnt=0;

//---- indicator
   double haopen[4],haclose[3];
   if(CopyBuffer(h_HA,0,1,4,haopen)!=4)return;
   if(CopyBuffer(h_HA,3,1,3,haclose)!=3)return;
   double a=haopen[3],b=haopen[2],c=haopen[1],s=haopen[0];
   double e=haclose[2],f=haclose[1],g=haclose[0];
   double w=a-b,x=b-c,y=c-s;
   ST=s;

//----- tacs_
   D=0;
   if(e>a && f>b && g>c && 0<y && y<x && x<w)
     {D=1;}
   else if(e<a && f<b && g<c && 0>y && y>x && x>w)
     {D=-1;}
//
   return;
  }
//+------------------------------------------------------------------+