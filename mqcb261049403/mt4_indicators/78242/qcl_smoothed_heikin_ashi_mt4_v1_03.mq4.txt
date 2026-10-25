//+------------------------------------------------------------------+
//| QCL Smoothed Heikin Ashi - MT4                                   |
//| Two-stage smoothed candles, rendered on the visible chart area.  |
//+------------------------------------------------------------------+
#property strict
#property copyright "Quant Chart Lab"
#property version "1.03"
#property indicator_chart_window
#property indicator_buffers 4

input int InpPricePeriod=14;                       // Primary Smoothing Period
input ENUM_MA_METHOD InpPriceMethod=MODE_EMA;      // Primary Moving Average Method
input int InpCandlePeriod=14;                      // Secondary Smoothing Period
input ENUM_MA_METHOD InpCandleMethod=MODE_EMA;     // Secondary Moving Average Method
input color InpBullishColor=clrMediumSeaGreen;    // Bullish Candle Color
input color InpBearishColor=clrTomato;             // Bearish Candle Color
input color InpNeutralColor=clrSilver;            // Neutral Candle Color

double OutO[],OutH[],OutL[],OutC[];
double BaseO[],BaseH[],BaseL[],BaseC[];
double HaO[],HaH[],HaL[],HaC[];
double SmoothO[],SmoothH[],SmoothL[],SmoothC[];
datetime BarTime[];
string Prefix;
int Total=0;
bool Ready=false;

double MovingAverage(const double &source[],const double &result[],
                     const int i,const int period,const ENUM_MA_METHOD method)
  {
   if(i==0 || period==1)
      return source[i];
   if(method==MODE_EMA)
      return result[i-1]+2.0/(period+1.0)*(source[i]-result[i-1]);
   int count=MathMin(i+1,period);
   if(method==MODE_SMMA && i>=period)
      return result[i-1]+(source[i]-result[i-1])/period;
   if(method==MODE_LWMA)
     {
      double sum=0.0;
      for(int k=0;k<count;k++)
         sum+=source[i-count+1+k]*(k+1.0);
      return sum/(count*(count+1.0)/2.0);
     }
   if(i<period)
      return (result[i-1]*i+source[i])/(i+1.0);
   return result[i-1]+(source[i]-source[i-period])/period;
  }

int OnInit()
  {
   if(InpPricePeriod<1 || InpPricePeriod>10000 ||
      InpCandlePeriod<1 || InpCandlePeriod>10000)
      return INIT_PARAMETERS_INCORRECT;
   Prefix="QCL_SHA_"+IntegerToString((int)GetTickCount())+"_";
   while(ObjectFind(0,Prefix+"owner")>=0) Prefix+="x";
   ObjectCreate(0,Prefix+"owner",OBJ_LABEL,0,0,0);
   ObjectSetString(0,Prefix+"owner",OBJPROP_TEXT,"");
   ObjectSetInteger(0,Prefix+"owner",OBJPROP_HIDDEN,true);
   IndicatorBuffers(4);
   SetIndexBuffer(0,OutO,INDICATOR_DATA);
   ArraySetAsSeries(OutO,false);
   SetIndexBuffer(1,OutH,INDICATOR_DATA);
   ArraySetAsSeries(OutH,false);
   SetIndexBuffer(2,OutL,INDICATOR_DATA);
   ArraySetAsSeries(OutL,false);
   SetIndexBuffer(3,OutC,INDICATOR_DATA);
   ArraySetAsSeries(OutC,false);
   ArraySetAsSeries(BaseO,false);
   ArraySetAsSeries(BaseH,false);
   ArraySetAsSeries(BaseL,false);
   ArraySetAsSeries(BaseC,false);
   ArraySetAsSeries(HaO,false);
   ArraySetAsSeries(HaH,false);
   ArraySetAsSeries(HaL,false);
   ArraySetAsSeries(HaC,false);
   ArraySetAsSeries(SmoothO,false);
   ArraySetAsSeries(SmoothH,false);
   ArraySetAsSeries(SmoothL,false);
   ArraySetAsSeries(SmoothC,false);
   string labels[4]={"Smoothed Open","Smoothed High","Smoothed Low","Smoothed Close"};
   // Only the four OHLC data buffers are registered with MT4.
   // Internal calculations use ordinary arrays, never chart plots.
   for(int k=0;k<4;k++)
     {
      SetIndexStyle(k,DRAW_NONE);
      SetIndexLabel(k,labels[k]);
      SetIndexDrawBegin(k,InpPricePeriod+InpCandlePeriod+2);
      SetIndexEmptyValue(k,EMPTY_VALUE);
     }
   IndicatorDigits(_Digits);
   IndicatorShortName(StringFormat("QCL Smoothed Heikin Ashi (%d,%d)",
                                  InpPricePeriod,InpCandlePeriod));
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   Ready=false;
   ObjectsDeleteAll(0,Prefix);
   ChartRedraw(0);
  }

void SetAppearance(const string name,const color candle_color)
  {
   ObjectSetInteger(0,name,OBJPROP_COLOR,candle_color);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
  }

void RenderCandle(const int i)
  {
   if(!Ready || i<InpPricePeriod+InpCandlePeriod+2 || i>=Total) return;
   color c=OutC[i]>OutO[i] ? InpBullishColor :
           (OutC[i]<OutO[i] ? InpBearishColor : InpNeutralColor);
   int seconds=PeriodSeconds();
   if(seconds<1) seconds=60;
   if(i+1<Total) seconds=(int)MathMin(seconds,BarTime[i+1]-BarTime[i]);
   int half_width=(int)MathMax(1,seconds*0.30);
   datetime left=BarTime[i]-half_width;
   datetime right=BarTime[i]+half_width;
   string wick=Prefix+"W_"+IntegerToString(i);
   string body=Prefix+"B_"+IntegerToString(i);
   if(ObjectFind(0,wick)<0)
      ObjectCreate(0,wick,OBJ_TREND,0,BarTime[i],OutL[i],BarTime[i],OutH[i]);
   ObjectMove(0,wick,0,BarTime[i],OutL[i]);
   ObjectMove(0,wick,1,BarTime[i],OutH[i]);
   ObjectSetInteger(0,wick,OBJPROP_RAY_RIGHT,false);
   SetAppearance(wick,c);
   ENUM_OBJECT kind=OutO[i]==OutC[i] ? OBJ_TREND : OBJ_RECTANGLE;
   if(ObjectFind(0,body)>=0 && ObjectGetInteger(0,body,OBJPROP_TYPE)!=kind)
      ObjectDelete(0,body);
   if(ObjectFind(0,body)<0)
      ObjectCreate(0,body,kind,0,left,OutO[i],right,OutC[i]);
   ObjectMove(0,body,0,left,OutO[i]);
   ObjectMove(0,body,1,right,OutC[i]);
   SetAppearance(body,c);
   if(kind==OBJ_RECTANGLE) ObjectSetInteger(0,body,OBJPROP_FILL,true);
   else ObjectSetInteger(0,body,OBJPROP_RAY_RIGHT,false);
  }

// Only visible candles need graphical objects; all history is calculated.
void RenderVisible()
  {
   if(!Ready || Total<1) return;
   ObjectsDeleteAll(0,Prefix+"W_");
   ObjectsDeleteAll(0,Prefix+"B_");
   int first=(int)ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR);
   int visible=(int)ChartGetInteger(0,CHART_VISIBLE_BARS);
   int oldest=MathMax(0,Total-1-first-2);
   int newest=MathMin(Total-1,Total-1-first+visible+2);
   for(int i=oldest;i<=newest && !IsStopped();i++) RenderCandle(i);
   ChartRedraw(0);
  }

void OnChartEvent(const int id,const long &lparam,
                  const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_CHART_CHANGE) RenderVisible();
  }

int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &time[],const double &open[],
                const double &high[],const double &low[],const double &close[],
                const long &tick_volume[],const long &volume[],const int &spread[])
  {
   if(rates_total<1) return 0;
   ArraySetAsSeries(time,false);
   ArraySetAsSeries(open,false); ArraySetAsSeries(high,false);
   ArraySetAsSeries(low,false); ArraySetAsSeries(close,false);
   bool rebuild=prev_calculated<=0 || prev_calculated>rates_total;
   bool new_bar=Total!=rates_total;
   int start=rebuild ? 0 : prev_calculated-1;
   ArrayResize(BarTime,rates_total);
   ArrayResize(BaseO,rates_total);
   ArrayResize(BaseH,rates_total);
   ArrayResize(BaseL,rates_total);
   ArrayResize(BaseC,rates_total);
   ArrayResize(HaO,rates_total);
   ArrayResize(HaH,rates_total);
   ArrayResize(HaL,rates_total);
   ArrayResize(HaC,rates_total);
   ArrayResize(SmoothO,rates_total);
   ArrayResize(SmoothH,rates_total);
   ArrayResize(SmoothL,rates_total);
   ArrayResize(SmoothC,rates_total);

   Total=rates_total;
   for(int i=start;i<rates_total && !IsStopped();i++)
     {
      BarTime[i]=time[i];
      BaseO[i]=MovingAverage(open,BaseO,i,InpPricePeriod,InpPriceMethod);
      BaseH[i]=MovingAverage(high,BaseH,i,InpPricePeriod,InpPriceMethod);
      BaseL[i]=MovingAverage(low,BaseL,i,InpPricePeriod,InpPriceMethod);
      BaseC[i]=MovingAverage(close,BaseC,i,InpPricePeriod,InpPriceMethod);
      // Preserve the source's initial price-candle seed interval.
      if(i<=InpPricePeriod+1)
        {
         HaO[i]=BaseO[i]; HaH[i]=BaseH[i];
         HaL[i]=BaseL[i]; HaC[i]=BaseC[i];
        }
      else
        {
         HaO[i]=(HaO[i-1]+HaC[i-1])/2.0;
         HaC[i]=(BaseO[i]+BaseH[i]+BaseL[i]+BaseC[i])/4.0;
         HaH[i]=MathMax(BaseH[i],MathMax(HaO[i],HaC[i]));
         HaL[i]=MathMin(BaseL[i],MathMin(HaO[i],HaC[i]));
        }
      SmoothO[i]=MovingAverage(HaO,SmoothO,i,InpCandlePeriod,InpCandleMethod);
      SmoothH[i]=MovingAverage(HaH,SmoothH,i,InpCandlePeriod,InpCandleMethod);
      SmoothL[i]=MovingAverage(HaL,SmoothL,i,InpCandlePeriod,InpCandleMethod);
      SmoothC[i]=MovingAverage(HaC,SmoothC,i,InpCandlePeriod,InpCandleMethod);
      OutO[i]=SmoothO[i]; OutC[i]=SmoothC[i];
      OutH[i]=MathMax(SmoothH[i],MathMax(OutO[i],OutC[i]));
      OutL[i]=MathMin(SmoothL[i],MathMin(OutO[i],OutC[i]));
     }
   if(IsStopped()) return 0;
   Ready=true;
   if(rebuild || new_bar) RenderVisible();
   else
     {
      int first=(int)ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR);
      int visible=(int)ChartGetInteger(0,CHART_VISIBLE_BARS);
      if(first<=visible+2) RenderCandle(Total-1);
     }
   return rates_total;
  }
