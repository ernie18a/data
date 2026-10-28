//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property link        "https://forge.mql5.io"
#property description "Hull trend"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 14
#property indicator_plots   3
#property indicator_label1  "Hull trend bars"
#property indicator_type1   DRAW_COLOR_BARS
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrSandyBrown
#property indicator_label2  "Hull trend candles"
#property indicator_type2   DRAW_COLOR_CANDLES
#property indicator_color2  clrDarkGray,clrDeepSkyBlue,clrSandyBrown
#property indicator_label3  "Hull trend line"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrDeepSkyBlue,clrSandyBrown
#property indicator_width3  2
//
//--- input parameters
//
enum enDisplayStyle
  {
   dis_automatic, // Automatic display style
   dis_line,      // Display line
   dis_bars,      // Display bars
   dis_candles    // Display candles
  };
input int                inpPeriod       = 20;            // Hull period
input ENUM_APPLIED_PRICE inpPrice        = PRICE_CLOSE;   // Price 
input enDisplayStyle     inpDisplayStyle = dis_automatic; // Display style

                                                          //
//--- buffers and global variables declarations
//
double canh[],canl[],cano[],canc[],cancl[],baro[],barh[],barl[],barc[],barcl[],line[],linecl[],hull[],hullcl[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,baro,INDICATOR_DATA);
   SetIndexBuffer(1,barh,INDICATOR_DATA);
   SetIndexBuffer(2,barl,INDICATOR_DATA);
   SetIndexBuffer(3,barc,INDICATOR_DATA);
   SetIndexBuffer(4,barcl,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,cano,INDICATOR_DATA);
   SetIndexBuffer(6,canh,INDICATOR_DATA);
   SetIndexBuffer(7,canl,INDICATOR_DATA);
   SetIndexBuffer(8,canc,INDICATOR_DATA);
   SetIndexBuffer(9,cancl,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(10,line,INDICATOR_DATA);
   SetIndexBuffer(11,linecl,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(12,hull,INDICATOR_CALCULATIONS);
   SetIndexBuffer(13,hullcl,INDICATOR_CALCULATIONS);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Hull trend ("+(string)inpPeriod+")");
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
#define displayLine   0
#define displayBars   1
#define displayCandle 2
//+------------------------------------------------------------------+
//|                                                                  |
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
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   int limit=prev_calculated-1;
   static int prevDisplayType = -1;
   int currDisplayType = -1;
   switch(inpDisplayStyle)
     {
      case dis_line :      currDisplayType = CHART_LINE;    break;
      case dis_bars :      currDisplayType = CHART_BARS;    break;
      case dis_candles :   currDisplayType = CHART_CANDLES; break;
      case dis_automatic : currDisplayType = (int)ChartGetInteger(0,CHART_MODE);
     }
   if(currDisplayType!=prevDisplayType)
     {
      limit=0; prevDisplayType=currDisplayType;
     }
   int i=(int)MathMax(limit,0); for(; i<rates_total && !_StopFlag; i++)
     {
      hull[i]   = iHull(getPrice(inpPrice,open,close,high,low,i,rates_total),inpPeriod,i,rates_total);
      hullcl[i] = (i>0) ? (hull[i]>hull[i-1]) ? 1 : (hull[i]<hull[i-1]) ? 2 : hullcl[i-1] : 0;
      baro[i] = barh[i] = barl[i] = barc[i] = EMPTY_VALUE;
      cano[i] = canh[i] = canl[i] = canc[i] = EMPTY_VALUE;
      line[i] = EMPTY_VALUE;
      switch(currDisplayType)
        {
         case CHART_BARS :
            barh[i]  = high[i];
            barl[i]  = low[i];
            barc[i]  = close[i];
            baro[i]  = open[i];
            barcl[i] = hullcl[i];
            break;
         case CHART_CANDLES :
            canh[i]  = high[i];
            canl[i]  = low[i];
            canc[i]  = close[i];
            cano[i]  = open[i];
            cancl[i] = hullcl[i];
            break;
         case CHART_LINE :
            line[i]=hull[i];
            linecl[i]=hullcl[i];
        }
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| custom functions                                                 |
//+------------------------------------------------------------------+
double workHull[][2];
//
//---
//
double iHull(double price,double period,int r,int bars,int instanceNo=0)
  {
   if(ArrayRange(workHull,0)!=bars) ArrayResize(workHull,bars);
   instanceNo*=2; workHull[r][instanceNo]=price;
   if(period<=1) return(price);
//
//---
//
   int HmaPeriod  = (int)MathMax(period,2);
   int HalfPeriod = (int)MathFloor(HmaPeriod/2);
   int HullPeriod = (int)MathFloor(MathSqrt(HmaPeriod));
   double hma,hmw,weight;
   hmw=HalfPeriod; hma=hmw*price;
   for(int k=1; k<HalfPeriod && (r-k)>=0; k++)
     {
      weight = HalfPeriod-k;
      hmw   += weight;
      hma   += weight*workHull[r-k][instanceNo];
     }
   workHull[r][instanceNo+1]=2.0*hma/hmw;
   hmw=HmaPeriod; hma=hmw*price;
   for(int k=1; k<period && (r-k)>=0; k++)
     {
      weight = HmaPeriod-k;
      hmw   += weight;
      hma   += weight*workHull[r-k][instanceNo];
     }
   workHull[r][instanceNo+1]-=hma/hmw;
   hmw=HullPeriod; hma=hmw*workHull[r][instanceNo+1];
   for(int k=1; k<HullPeriod && (r-k)>=0; k++)
     {
      weight = HullPeriod-k;
      hmw   += weight;
      hma   += weight*workHull[r-k][1+instanceNo];
     }
   return(hma/hmw);
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
