//======================================================================================================================================================//
#property copyright   "Copyright 2014-2019, Nikolaos Pantzos"
#property link        "https://www.mql5.com/en/users/pannik"
#property version     "1.0"
#property description "Use it indicator in M5 chart and EURUSD pair."
#property strict
//======================================================================================================================================================//
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrAquamarine
#property indicator_color2 clrKhaki
#property indicator_width1 2
#property indicator_width2 2
//======================================================================================================================================================//
input int  BarsCount=100;
input int  ATRperiod=14;
input bool AlertMode=true;
input bool ControlChart_EURUSD_M5=true;
//======================================================================================================================================================//
double Buffer_0[];
double Buffer_1[];
string SymExt;
int LastSignalBuy=0;
int LastSignalSell=0;
string ObjName4="Label4";
int PositionX=5;
int PositionY=65;
//======================================================================================================================================================//
int OnInit(void)
  {
//--------------------------------------------------------------------------------
   if(StringLen(Symbol())>6)
      SymExt=StringSubstr(Symbol(),6);
   if(ObjectFind(ObjName4)==-1)
      Objects(ObjName4,"i4 Indicator: No Signal",PositionX,PositionY,clrYellow);
//---
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,SYMBOL_ARROWUP);
   SetIndexArrow(0,233);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,SYMBOL_ARROWDOWN);
   SetIndexArrow(1,234);
   SetIndexBuffer(0,Buffer_0);
   SetIndexBuffer(1,Buffer_1);
   IndicatorDigits((int)MarketInfo(Symbol(),MODE_DIGITS)+1);
   IndicatorShortName("i4("+IntegerToString(ATRperiod)+")");
   SetIndexLabel(0,"i4 Uptrend");
   SetIndexLabel(1,"i4 Dntrend");
   return(INIT_SUCCEEDED);
//--------------------------------------------------------------------------------
  }
//======================================================================================================================================================//
void OnDeinit(const int reason)
  {
//--------------------------------------------------------------------------------
   if(ObjectFind(ObjName4)>-1)
      ObjectDelete(ObjName4);
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
         Print("Indicator i4 set chart symbol: "+"EURUSD"+SymExt+" and Period: M5");
         ChartSetSymbolPeriod(0,"EURUSD"+SymExt,PERIOD_M5);
         return(0);
        }
     }
//--------------------------------------------------------------------------------
   double DistanceArrow=10.0*Point;
   double ATRcount;
   int i;
   double CurrATR=iATR(NULL,0,ATRperiod,1);
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
   for(i=Limit-1; i>=0; i--)
     {
      ATRcount=iATR(NULL,0,ATRperiod,i+1);
      //---Buy arrow
      if((High[i]>High[i+1]+ATRcount) && (High[i]>High[i+2]+ATRcount) && (Open[i]<Close[i+1]+ATRcount) && (Open[i]<Close[i+2]+ATRcount))
        {
         Buffer_0[i]=Low[i]-DistanceArrow;
        }
      //---Sell arrow
      if((Low[i]<Low[i+1]-ATRcount) && (Low[i]<Low[i+2]-ATRcount) && (Open[i]>Close[i+1]-ATRcount) && (Open[i]>Close[i+2]-ATRcount))
        {
         Buffer_1[i]=High[i]+DistanceArrow;
        }
     }
//--------------------------------------------------------------------------------
//--Buy alert
   if((High[0]>High[0+1]+CurrATR) && (High[0]>High[0+2]+CurrATR) && (Open[0]<Close[0+1]+CurrATR) && (Open[0]<Close[0+2]+CurrATR))
     {
      if(AlertMode && (iBars(NULL,0)!=LastSignalBuy) && (Volume[0]>1.0))
        {
         if(IsVisualMode())
            Buffer_0[0]=Low[0]-DistanceArrow;
         Alert(WindowExpertName(),": Signal BUY @ ",Symbol()," ",Ask," || Time: ",TimeToStr(TimeCurrent()|TIME_MINUTES));
         LastSignalBuy=iBars(NULL,0);
        }
      if(ObjectFind(ObjName4)>-1)
         ObjectDelete(ObjName4);
      if(ObjectFind(ObjName4)==-1)
         Objects(ObjName4,"i4 Indicator: UP Trend",PositionX,PositionY,clrDodgerBlue);
     }
   else
      //--Sell alert
      if((Low[0]<Low[0+1]-CurrATR) && (Low[0]<Low[0+2]-CurrATR) && (Open[0]>Close[0+1]-CurrATR) && (Open[0]>Close[0+2]-CurrATR))
        {
         if(AlertMode && (iBars(NULL,0)!=LastSignalSell) && (Volume[0]>1.0))
           {
            if(IsVisualMode())
               Buffer_1[0]=High[0]+DistanceArrow;
            Alert(WindowExpertName(),": Signal SELL @ ",Symbol()," ",Bid," || Time: ",TimeToStr(TimeCurrent()|TIME_MINUTES));
            LastSignalSell=iBars(NULL,0);
           }
         if(ObjectFind(ObjName4)>-1)
            ObjectDelete(ObjName4);
         if(ObjectFind(ObjName4)==-1)
            Objects(ObjName4,"i4 Indicator: DN Trend",PositionX,PositionY,clrRed);
        }
      else
        {
         if(ObjectFind(ObjName4)>-1)
            ObjectDelete(ObjName4);
         if(ObjectFind(ObjName4)==-1)
            Objects(ObjName4,"i4 Indicator: No Signal",PositionX,PositionY,clrYellow);
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
