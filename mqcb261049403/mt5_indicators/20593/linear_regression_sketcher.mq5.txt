//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Linear regression"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrLimeGreen,clrOrange
#property indicator_width1  2
//
//--- input parameters
//
input int                inpLrPeriod           = 50;             // Linear regression period
input ENUM_APPLIED_PRICE inpPrice              = PRICE_CLOSE;    // Price
input int                inpLrcNo              = 250;            // Number of linear regressions drawn
input color              inpColorUp            = clrLimeGreen;   // Color when regression sloping up
input color              inpColorDown          = clrOrange;      // Color when regression sloping down
input int                inpLinesWidthWhenTrendChange = 2;       // Lines width when trend change
input ENUM_LINE_STYLE    inpChannelStyle       = STYLE_DOT;      // Lines style
input string             inpUniqueID           = "Lrs1";         // Indicator unique ID

//
//---
//
double  val[],valc[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Linear regression sketcher ("+(string)inpLrPeriod+")");
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
      ObjectsDeleteAll(0,inpUniqueID+":"); return; 
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
   if(Bars(_Symbol,_Period)<rates_total) return(-1);
   double _lrslope,_lrerror;
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      val[i]    = iLrValue(getPrice(inpPrice,open,close,high,low,i,rates_total),inpLrPeriod,_lrslope,_lrerror,i,rates_total);
      valc[i]   = (_lrslope > 0) ? 1 : (_lrslope<0) ? 2 : (i>0) ? valc[i-1] : 0;
      if (i>rates_total-inpLrcNo)
               if (valc[i]!=valc[i-1])
                     createLine("",val[i],val[i]-_lrslope*(inpLrPeriod-1),time,i,inpLinesWidthWhenTrendChange);
               else  createLine("",val[i],val[i]-_lrslope*(inpLrPeriod-1),time,i);
      }               
   return(i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double workLr[];
//
//---
//
double iLrValue(double value,int period,double &slope,double &error,int r,int bars)
  {
   if(ArraySize(workLr)!=bars) ArrayResize(workLr,bars); workLr[r]=value;
   if(r<period || period<2) return(value);

//
//---
//

   double sumx=0,sumxx=0,sumxy=0,sumy=0,sumyy=0;
   for(int k=0; k<period; k++)
     {
      double price=workLr[r-k];
      sumx  += k;
      sumxx += k*k;
      sumxy += k*price;
      sumy  +=   price;
      sumyy +=   price*price;
     }
   slope = (period*sumxy-sumx*sumy)/(sumx*sumx-period*sumxx);
   error = MathSqrt((period*sumyy-sumy*sumy-slope*slope*(period*sumxx-sumx*sumx))/(period*(period-2)));

//
//---
//

   return((sumy + slope*sumx)/period);
  }
  
//
//---
//
void createLine(string add, double lrs, double lre, const datetime& time[], int i, int lineWidth=0)
{
   string name = inpUniqueID+":"+add+(string)i;
   ObjectCreate(0,name,OBJ_TREND,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_TIME,0,time[i]);
      ObjectSetInteger(0,name,OBJPROP_TIME,1,time[i-inpLrPeriod+1]);
      ObjectSetDouble(0,name,OBJPROP_PRICE,0,lrs);
      ObjectSetDouble(0,name,OBJPROP_PRICE,1,lre);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_RAY,false);
      ObjectSetInteger(0,name,OBJPROP_BACK,true);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_WIDTH,lineWidth);
      ObjectSetInteger(0,name,OBJPROP_STYLE,inpChannelStyle);
            color  theColor = (lrs>lre) ? inpColorUp : inpColorDown;
               ObjectSetInteger(0,name,OBJPROP_COLOR,theColor);
}

  
//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
   switch(tprice)
     {
      case PRICE_CLOSE:     return(close[i]);
      case PRICE_OPEN:      return(open[i]);
      case PRICE_HIGH:      return(high[i]);
      case PRICE_LOW:       return(low[i]);
      case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
      case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
      case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
     }
   return(0);
  }
  //+------------------------------------------------------------------+
