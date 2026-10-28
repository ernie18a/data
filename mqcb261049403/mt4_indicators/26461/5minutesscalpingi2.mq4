//======================================================================================================================================================//
#property copyright   "Copyright 2014-2019, Nikolaos Pantzos"
#property link        "https://www.mql5.com/en/users/pannik"
#property version     "1.1"
#property description "Use it indicator in M5 chart and EURUSD pair."
#property strict
//======================================================================================================================================================//
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 clrYellow
#property indicator_color2 clrDodgerBlue
#property indicator_color3 clrRed
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
//======================================================================================================================================================//
input int  BarsCount=1000;
input int  PeriodCount=50;
input int  PriceCount=0;
input bool AlertMode=true;
input bool ControlChart_EURUSD_M5=true;
//======================================================================================================================================================//
double Buffer_0[];
double Buffer_1[];
double Buffer_2[];
double Buffer_3[];
double Buffer_4[];
int BeginIndicator;
bool SignalBuy=FALSE;
bool SignalSell=FALSE;
string SymExt;
string ObjName2="Label2";
int PositionX=5;
int PositionY=35;
//======================================================================================================================================================//
int OnInit(void)
  {
//--------------------------------------------------------------------------------
   if(StringLen(Symbol())>6)
      SymExt=StringSubstr(Symbol(),6);
   if(ObjectFind(ObjName2)==-1)
      Objects(ObjName2,"i2 Indicator: Flat Trend",PositionX,PositionY,clrYellow);
//---
   IndicatorBuffers(5);
   SetIndexBuffer(0,Buffer_0);
   SetIndexBuffer(1,Buffer_1);
   SetIndexBuffer(2,Buffer_2);
   SetIndexBuffer(3,Buffer_3);
   SetIndexBuffer(4,Buffer_4);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(0,159);
   SetIndexArrow(1,159);
   SetIndexArrow(2,159);
   BeginIndicator=PeriodCount+(int)MathFloor(MathSqrt(PeriodCount));
   SetIndexDrawBegin(0,BeginIndicator);
   SetIndexDrawBegin(1,BeginIndicator);
   SetIndexDrawBegin(2,BeginIndicator);
   IndicatorDigits((int)MarketInfo(Symbol(),MODE_DIGITS)+1);
   IndicatorShortName("i2("+IntegerToString(PeriodCount)+")");
   SetIndexLabel(0,"i2");
   SetIndexLabel(1,"i2 UpTrend");
   SetIndexLabel(2,"i2 DownTrend");
   return(INIT_SUCCEEDED);
//--------------------------------------------------------------------------------
  }
//======================================================================================================================================================//
void OnDeinit(const int reason)
  {
//--------------------------------------------------------------------------------
   if(ObjectFind(ObjName2)>-1)
      ObjectDelete(ObjName2);
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
         Print("Indicator i2 set chart symbol: "+"EURUSD"+SymExt+" and Period: M5");
         ChartSetSymbolPeriod(0,"EURUSD"+SymExt,PERIOD_M5);
         return(0);
        }
     }
//--------------------------------------------------------------------------------
   double FastMA;
   double SlowMA;
   int i;
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
   if(ExtCountedBars<1)
     {
      for(i=1; i<=BeginIndicator; i++)
         Buffer_0[Bars-i]=0;
      for(i=1; i<=PeriodCount; i++)
         Buffer_3[Bars-i]=0;
     }
//--------------------------------------------------------------------------------
   for(i=0; i<Limit; i++)
     {
      FastMA=iMA(NULL,0,(int)MathFloor(PeriodCount/2),0,MODE_LWMA,PriceCount,i);
      SlowMA=iMA(NULL,0,PeriodCount,0,MODE_LWMA,PriceCount,i);
      Buffer_3[i]=2.0*FastMA-SlowMA;
     }
//--------------------------------------------------------------------------------
   for(i=Limit-2; i>=0; i--)
     {
      Buffer_0[i]=iMAOnArray(Buffer_3,0,(int)MathFloor(MathSqrt(PeriodCount)),0,MODE_LWMA,i);

      Buffer_4[i]=Buffer_4[i+1];
      if(Buffer_0[i]-(Buffer_0[i+1])>0)
         Buffer_4[i]=1;
      if(Buffer_0[i+1]-Buffer_0[i]>0)
         Buffer_4[i]=-1;
      //---
      if(Buffer_4[i]>0.0)
        {
         Buffer_1[i]=Buffer_0[i];
         if(Buffer_4[i]<0.0)
            Buffer_1[i]=Buffer_0[i];
         Buffer_2[i]=EMPTY_VALUE;
         if(ObjectFind(ObjName2)>-1)
            ObjectDelete(ObjName2);
         if(ObjectFind(ObjName2)==-1)
            Objects(ObjName2,"i2 Indicator: UP Trend",PositionX,PositionY,clrDodgerBlue);
         continue;
        }
      //---
      if(Buffer_4[i]<0.0)
        {
         Buffer_2[i]=Buffer_0[i];
         if(Buffer_4[i]>0.0)
            Buffer_2[i]=Buffer_0[i];
         Buffer_1[i]=EMPTY_VALUE;
         if(ObjectFind(ObjName2)>-1)
            ObjectDelete(ObjName2);
         if(ObjectFind(ObjName2)==-1)
            Objects(ObjName2,"i2 Indicator: DN Trend",PositionX,PositionY,clrRed);
        }
      //---
     }
//--------------------------------------------------------------------------------
   if((Buffer_4[2]<0.0) && (Buffer_4[1]>0.0) && (Buffer_4[0]>0.0) && (Volume[0]>1.0) && (!SignalBuy))
     {
      if(AlertMode)
         Alert(WindowExpertName(),": Signal BUY @ ",Symbol()," ",Ask," || Time: ",TimeToStr(TimeCurrent()|TIME_MINUTES));
      SignalBuy=TRUE;
      SignalSell=FALSE;
     }
   if((Buffer_4[2]>0.0) && (Buffer_4[1]<0.0) && (Buffer_4[0]<0.0) && (Volume[0]>1.0) && (!SignalSell))
     {
      if(AlertMode)
         Alert(WindowExpertName(),": Signal SELL @ ",Symbol()," ",Bid," || Time: ",TimeToStr(TimeCurrent()|TIME_MINUTES));
      SignalSell=TRUE;
      SignalBuy=FALSE;
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
