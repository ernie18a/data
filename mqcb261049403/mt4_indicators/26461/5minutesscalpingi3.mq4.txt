//======================================================================================================================================================//
#property copyright   "Copyright 2014-2019, Nikolaos Pantzos"
#property link        "https://www.mql5.com/en/users/pannik"
#property version     "1.1"
#property description "Use it indicator in M5 chart and EURUSD pair."
#property strict
//======================================================================================================================================================//
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 clrDodgerBlue
#property indicator_color2 clrRed
#property indicator_width1 3
#property indicator_width2 3
#property indicator_level1 0.2
#property indicator_level2 0.5
#property indicator_level3 1.0
#property indicator_level4 -0.2
#property indicator_level5 -0.5
#property indicator_level6 -1.0
//======================================================================================================================================================//
enum Prc {Price_High_Low, Price_Open, Price_Close, Price_High, Price_Low, Price_High_Low_Close, Price_Open_High_Low_Close, Price_Open_Close};
//======================================================================================================================================================//
input int  BarsCount=1000;
input int  PeriodCount=10;
input Prc  PriceCount=Price_High_Low;
input bool AlertMode=true;
input bool ControlChart_EURUSD_M5=true;
//======================================================================================================================================================//
double Buffer_0[];
double Buffer_1[];
double Value=0;
double Value1=0;
double Value2=0;
double CalcPrices=0;
double CalcPrices1=0;
double CalcPrices2=0;
string SymExt;
int AlertBuy=0;
int AlertSell=0;
string ObjName3="Label3";
int PositionX=5;
int PositionY=50;
//======================================================================================================================================================//
int OnInit(void)
  {
//--------------------------------------------------------------------------------
   if(StringLen(Symbol())>6)
      SymExt=StringSubstr(Symbol(),6);
   if(ObjectFind(ObjName3)==-1)
      Objects(ObjName3,"i3 Indicator: Flat Trend",PositionX,PositionY,clrYellow);
//---
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexBuffer(0,Buffer_0);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexBuffer(1,Buffer_1);
   IndicatorDigits((int)MarketInfo(Symbol(),MODE_DIGITS)+1);
   IndicatorShortName("i3("+IntegerToString(PeriodCount)+")");
   SetIndexLabel(0,"i3 UpTrend");
   SetIndexLabel(1,"i3 DownTrend");
   return(INIT_SUCCEEDED);
//--------------------------------------------------------------------------------
  }
//======================================================================================================================================================//
void OnDeinit(const int reason)
  {
//--------------------------------------------------------------------------------
   if(ObjectFind(ObjName3)>-1)
      ObjectDelete(ObjName3);
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
         Print("Indicator i3 set chart symbol: "+"EURUSD"+SymExt+" and Period: M5");
         ChartSetSymbolPeriod(0,"EURUSD"+SymExt,PERIOD_M5);
         return(0);
        }
     }
//--------------------------------------------------------------------------------
   int i;
   double PriceUse;
   double MinLow=0;
   double MaxHigh=0;
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
      MaxHigh=High[Highest(NULL,0,MODE_HIGH,PeriodCount,i)];
      MinLow=Low[Lowest(NULL,0,MODE_LOW,PeriodCount,i)];

      switch(PriceCount)
        {
         case 1:
            PriceUse=Open[i];
            break;
         case 2:
            PriceUse=Close[i];
            break;
         case 3:
            PriceUse=High[i];
            break;
         case 4:
            PriceUse=Low[i];
            break;
         case 5:
            PriceUse=(High[i]+Low[i]+Close[i])/3;
            break;
         case 6:
            PriceUse=(Open[i]+High[i]+Low[i]+Close[i])/4;
            break;
         case 7:
            PriceUse=(Open[i]+Close[i])/2;
            break;
         default:
            PriceUse=(High[i]+Low[i])/2;
            break;
        }
      //--------------------------------------------------------------------------------
      if(MaxHigh-MinLow!=0)
         Value=0.33*2*((PriceUse-MinLow)/(MaxHigh-MinLow)-0.5)+0.67*Value1;
      Value=MathMin(MathMax(Value,-0.999),0.999);
      CalcPrices=0.5*MathLog((1+Value)/(1-Value))-0.5*CalcPrices1-0.5*CalcPrices2;
      //---
      Buffer_0[i]= 0;
      Buffer_1[i]= 0;
      //---
      if(CalcPrices>=0)
        {
         Buffer_0[i]=CalcPrices;
         if(ObjectFind(ObjName3)>-1)
            ObjectDelete(ObjName3);
         if(ObjectFind(ObjName3)==-1)
            Objects(ObjName3,"i3 Indicator: UP Trend",PositionX,PositionY,clrDodgerBlue);
        }
      else
        {
         Buffer_1[i]=CalcPrices;
         if(ObjectFind(ObjName3)>-1)
            ObjectDelete(ObjName3);
         if(ObjectFind(ObjName3)==-1)
            Objects(ObjName3,"i3 Indicator: DN Trend",PositionX,PositionY,clrRed);
        }
      //---
      Value1=Value;
      CalcPrices2=CalcPrices1;
      CalcPrices1=CalcPrices;
      //---
     }
//--------------------------------------------------------------------------------
   if(AlertMode)
     {
      if((Buffer_0[1]>0) && (Buffer_0[2]==0) && (Buffer_0[0]>0) && (Volume[0]>1.0) && (AlertBuy==0))
        {
         Alert(WindowExpertName(),": Signal BUY @ ",Symbol()," ",Ask," || Time: ",TimeToStr(TimeCurrent()|TIME_MINUTES));
         AlertBuy=1;
         AlertSell=0;
        }
      if((Buffer_1[1]<0) && (Buffer_1[2]==0) && (Buffer_1[0]<0) && (Volume[0]>1.0) && (AlertSell==0))
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
