//======================================================================================================================================================//
#property copyright   "Copyright 2014-2019, Nikolaos Pantzos"
#property link        "https://www.mql5.com/en/users/pannik"
#property version     "1.1"
#property description "Use it indicator in M5 chart and EURUSD pair."
#property strict
//======================================================================================================================================================//
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_minimum 0.0
#property indicator_maximum 0.1
#property indicator_color1 clrDodgerBlue
#property indicator_color2 clrRed
#property indicator_width1 3
#property indicator_width2 3
//======================================================================================================================================================//
input int  BarsCount=1000;
input int  TrendPeriod=18;
input bool AlertMode=true;
input bool ControlChart_EURUSD_M5=true;
//======================================================================================================================================================//
double Trend[];
double TrendUP[];
double TrendDN[];
int AlertBuy=0;
int AlertSell=0;
string SymExt;
string ObjName5="Label5";
int PositionX=5;
int PositionY=80;
//======================================================================================================================================================//
int OnInit(void)
  {
//--------------------------------------------------------------------------------
   if(StringLen(Symbol())>6)
      SymExt=StringSubstr(Symbol(),6);
   if(ObjectFind(ObjName5)==-1)
      Objects(ObjName5,"i5 Indicator: Flat Trend",PositionX,PositionY,clrYellow);
//---
   IndicatorBuffers(3);
   IndicatorDigits((int)MarketInfo(Symbol(),MODE_DIGITS)+1);
   SetIndexBuffer(0,TrendUP);
   SetIndexBuffer(1,TrendDN);
   SetIndexBuffer(2,Trend);
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexStyle(2,DRAW_NONE);
   IndicatorShortName("i5("+IntegerToString(TrendPeriod)+")");
   SetIndexLabel(0,"i5 UpTrend");
   SetIndexLabel(1,"i5 DownTrend");
   return(INIT_SUCCEEDED);
//--------------------------------------------------------------------------------
  }
//======================================================================================================================================================//
void OnDeinit(const int reason)
  {
//--------------------------------------------------------------------------------
   if(ObjectFind(ObjName5)>-1)
      ObjectDelete(ObjName5);
//--------------------------------------------------------------------------------
  }
//======================================================================================================================================================//
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--------------------------------------------------------------------------------
   if(ControlChart_EURUSD_M5==true)
     {
      if((ChartSymbol()!="EURUSD"+SymExt) || (ChartPeriod()!=PERIOD_M5))
        {
         Print("Indicator i5 set chart symbol: "+"EURUSD"+SymExt+" and Period: M5");
         ChartSetSymbolPeriod(0,"EURUSD"+SymExt,PERIOD_M5);
         return(0);
        }
     }
//--------------------------------------------------------------------------------
   double TrendNext,TrendNow,TrendPrice;
   double Value=0,Value1=0,Fish1=0,MaxL=0,MaxH=0;
   int i;
   bool TrendChange=TRUE;
//--------------------------------------------------------------------------------
   int ExtCountedBars=BarsCount;//IndicatorCounted();
   if(ExtCountedBars>Bars-1)
      ExtCountedBars=Bars-1;
   if(ExtCountedBars<0)
      return(-1);
   if(ExtCountedBars>0)
      ExtCountedBars--;
   int Limit=ExtCountedBars;
//--------------------------------------------------------------------------------
   for(i=0; i<Limit; i++)
     {
      MaxH=High[iHighest(NULL,0,MODE_HIGH,TrendPeriod,i)];
      MaxL=Low[iLowest(NULL,0,MODE_LOW,TrendPeriod,i)];
      TrendPrice=(High[i]+Low[i])/2.0;
      if(MaxH-MaxL==0.0)
         Value=0.67*Value1+(-0.33);
      else
         Value=0.33*2*((TrendPrice-MaxL)/(MaxH-MaxL)-0.5)+0.67*Value1;
      Value=MathMin(MathMax(Value,-0.999),0.999);
      if(1-Value==0.0)
         Trend[i]=Fish1/2.0+0.5;
      else
         Trend[i]=MathLog((1+Value)/(1-Value))/2.0+Fish1/2.0;
      Value1=Value;
      Fish1=Trend[i];
     }
//--------------------------------------------------------------------------------
   for(i=Limit-2; i>=0; i--)
     {
      TrendNow=Trend[i];
      TrendNext=Trend[i+1];
      if((TrendNow<0.0&&TrendNext>0.0)||TrendNow<0.0)
         TrendChange=FALSE;
      if((TrendNow>0.0&&TrendNext<0.0)||TrendNow>0.0)
         TrendChange=TRUE;
      if(!TrendChange)
        {
         TrendDN[i]=1.0;
         TrendUP[i]=0.0;
         if(ObjectFind(ObjName5)>-1)
            ObjectDelete(ObjName5);
         if(ObjectFind(ObjName5)==-1)
            Objects(ObjName5,"i5 Indicator: DN Trend",PositionX,PositionY,clrRed);
        }
      else
        {
         TrendUP[i]=1.0;
         TrendDN[i]=0.0;
         if(ObjectFind(ObjName5)>-1)
            ObjectDelete(ObjName5);
         if(ObjectFind(ObjName5)==-1)
            Objects(ObjName5,"i5 Indicator: UP Trend",PositionX,PositionY,clrDodgerBlue);
        }
     }
//--------------------------------------------------------------------------------
   if(AlertMode)
     {
      if((TrendUP[0]>0) && (TrendUP[1]==0) && (TrendDN[1]>0) && (Volume[0]>1.0) && (AlertBuy==0))
        {
         Alert(WindowExpertName(),": Signal BUY @ ",Symbol()," ",Ask," || Time: ",TimeToStr(TimeCurrent()|TIME_MINUTES));
         AlertBuy=1;
         AlertSell=0;
        }
      if((TrendDN[0]>0) && (TrendDN[1]==0) && (TrendUP[1]>0) && (Volume[0]>1.0) && (AlertSell==0))
        {
         Alert(WindowExpertName(),": Signal SELL @ ",Symbol()," ",Ask," || Time: ",TimeToStr(TimeCurrent()|TIME_MINUTES));
         AlertBuy=0;
         AlertSell=1;
        }
     }
//-----------------------------------------------------------------------------------
   ChartRedraw();
//-----------------------------------------------------------------------------------
   return(rates_total);
//-----------------------------------------------------------------------------------
  }
//======================================================================================================================================================//
void Objects(string ObjName,string ObjText,int PosX,int PosY,color ObjColor)
  {
//--------------------------------------------------------------------------------
   if(ObjectCreate(ObjName,OBJ_LABEL,0,0,0))
     {
      ObjectSet(ObjName,OBJPROP_XDISTANCE,PosX);
      ObjectSet(ObjName,OBJPROP_YDISTANCE,PosY);
      ObjectSet(ObjName,OBJPROP_CORNER,1);
      ObjectSetText(ObjName,ObjText,10,"Arial Black",ObjColor);
     }
//--------------------------------------------------------------------------------
  }
//======================================================================================================================================================//
