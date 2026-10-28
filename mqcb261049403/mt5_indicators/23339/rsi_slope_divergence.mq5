//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Rsi"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkGray
#property indicator_width1  2

//
//---
//

input int                inpPeriod               = 14;            // Period
input ENUM_APPLIED_PRICE inpPrice                = PRICE_CLOSE;   // Price
input int                inpLrPeriod             = 50;            // Linear regression period
input double             inpLrWidth              = 2.0;           // Linear regression channel width
input color              inpClrDiverging         = clrRed;        // Color of middle liones when there is divergence
input color              inpChartLineColor       = clrDarkGray;   // On chart channel color
input ENUM_LINE_STYLE    inpChartLineMiddleStyle = STYLE_DOT;     // On chart channel middle line style
input ENUM_LINE_STYLE    inpChartLineStyle       = STYLE_SOLID;   // On chart channel outer lines style
input color              inpRsiLineColor         = clrDarkGray;   // On rsi channel color
input ENUM_LINE_STYLE    inpRsiLineMiddleStyle   = STYLE_DOT;     // On rsi channel middle line style
input ENUM_LINE_STYLE    inpRsiLineStyle         = STYLE_SOLID;   // On rsi channel outer lines style
input string             inpUniqueID             = "RsiSlopeDiv1";// Unique ID for objects 

//
//---
//

double val[],prices[];
int  ª_rsiHandle,ª_rsiPeriod; 

//------------------------------------------------------------------ 
//  Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //---- indicator buffers mapping
   //
         SetIndexBuffer(0,val   ,INDICATOR_DATA);
         SetIndexBuffer(1,prices,INDICATOR_CALCULATIONS);
         
         ª_rsiPeriod   = (inpPeriod>1) ? inpPeriod : 1;
         ª_rsiHandle   = iRSI(_Symbol,0,ª_rsiPeriod,inpPrice); if (!_checkHandle(ª_rsiHandle,"RSI")) return(INIT_FAILED);
   //            
   //----
   //
   
   IndicatorSetString(INDICATOR_SHORTNAME,"Rsi slope divergence ("+(string)ª_rsiPeriod+","+(string)inpLrPeriod+")");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { ObjectsDeleteAll(0,inpUniqueID+":"); }

//------------------------------------------------------------------
//  Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

#define _setPrice(_priceType,_target,_index) \
   { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE:    _target = close[_index];                                              break; \
      case PRICE_OPEN:     _target = open[_index];                                               break; \
      case PRICE_HIGH:     _target = high[_index];                                               break; \
      case PRICE_LOW:      _target = low[_index];                                                break; \
      case PRICE_MEDIAN:   _target = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL:  _target = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED: _target = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _target = 0; \
   }}
   
//
//---
//

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
   int _copyCount = rates_total-prev_calculated+1; if (_copyCount>rates_total) _copyCount=rates_total;
         if (CopyBuffer(ª_rsiHandle,0,0,_copyCount,val)!=_copyCount) return(prev_calculated);

   //
   //---
   //
   
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++) _setPrice(inpPrice,prices[i],i);
      double rsiError; double rsiSlope; double lrRsi = iLrValue(val   ,inpLrPeriod,rsiSlope,rsiError,rates_total-1);
      double prcError; double prcSlope; double lrPrc = iLrValue(prices,inpLrPeriod,prcSlope,prcError,rates_total-1);
      bool _isThereDivergence = (rsiSlope*prcSlope<0);
         int window = ChartWindowFind();
            createChannel(window,lrRsi,lrRsi-(inpLrPeriod-1.0)*rsiSlope,"rsiLine",inpRsiLineColor  ,_isThereDivergence?inpClrDiverging:inpRsiLineColor,inpRsiLineStyle  ,inpRsiLineMiddleStyle  ,rsiError*inpLrWidth);
            createChannel(0     ,lrPrc,lrPrc-(inpLrPeriod-1.0)*prcSlope,"prcLine",inpChartLineColor,_isThereDivergence?inpClrDiverging:inpRsiLineColor,inpChartLineStyle,inpChartLineMiddleStyle,prcError*inpLrWidth);


   return(rates_total);
}

//------------------------------------------------------------------
// Custom function(s)
//------------------------------------------------------------------
//
//---
//

void createChannel(int window, double price1, double price2, string addName, color theColor,color middleColor, int theStyle, int theMiddleStyle, double error)
{
   string name = inpUniqueID+":"+addName;
      if (ObjectFind(0,name)==-1)
           ObjectCreate(0,name,OBJ_TREND,window,0,0,0,0);
              ObjectSetDouble(0,name,OBJPROP_PRICE,0,price1);
              ObjectSetDouble(0,name,OBJPROP_PRICE,1,price2);
              ObjectSetInteger(0,name,OBJPROP_TIME,0,iTime(NULL,_Period,0));
              ObjectSetInteger(0,name,OBJPROP_TIME,1,iTime(NULL,_Period,inpLrPeriod-1));
              ObjectSetInteger(0,name,OBJPROP_RAY,false);
              ObjectSetInteger(0,name,OBJPROP_COLOR,middleColor);
              ObjectSetInteger(0,name,OBJPROP_STYLE,theMiddleStyle);
                  if (error<=0) return;
      name = inpUniqueID+":"+addName+"up";
      if (ObjectFind(0,name)==-1)
           ObjectCreate(0,name,OBJ_TREND,window,0,0,0,0);
              ObjectSetDouble(0,name,OBJPROP_PRICE,0,price1+error);
              ObjectSetDouble(0,name,OBJPROP_PRICE,1,price2+error);
              ObjectSetInteger(0,name,OBJPROP_TIME,0,iTime(NULL,_Period,0));
              ObjectSetInteger(0,name,OBJPROP_TIME,1,iTime(NULL,_Period,inpLrPeriod-1));
              ObjectSetInteger(0,name,OBJPROP_RAY,false);
              ObjectSetInteger(0,name,OBJPROP_COLOR,theColor);
              ObjectSetInteger(0,name,OBJPROP_STYLE,theStyle);
      name = inpUniqueID+":"+addName+"down";
      if (ObjectFind(0,name)==-1)
           ObjectCreate(0,name,OBJ_TREND,window,0,0,0,0);
              ObjectSetDouble(0,name,OBJPROP_PRICE,0,price1-error);
              ObjectSetDouble(0,name,OBJPROP_PRICE,1,price2-error);
              ObjectSetInteger(0,name,OBJPROP_TIME,0,iTime(NULL,_Period,0));
              ObjectSetInteger(0,name,OBJPROP_TIME,1,iTime(NULL,_Period,inpLrPeriod-1));
              ObjectSetInteger(0,name,OBJPROP_RAY,false);
              ObjectSetInteger(0,name,OBJPROP_COLOR,theColor);
              ObjectSetInteger(0,name,OBJPROP_STYLE,theStyle);
}

//
//---
//

template <typename T> 
double iLrValue(T& values[], int period, double& slope, double& error, int i)
{
   double sumx=0, sumxx=0, sumxy=0, sumy=0, sumyy=0;
   for (int k=0; k<period && i>=k; k++)
   {
         double price = values[i-k];
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

bool _checkHandle(int _handle, string _description)
{
   static int  _chandles[];
          int  _size   = ArraySize(_chandles);
          bool _answer = (_handle!=INVALID_HANDLE);
          if  (_answer)
               { ArrayResize(_chandles,_size+1); _chandles[_size]=_handle; }
          else { for (int i=_size-1; i>=0; i--) IndicatorRelease(_chandles[i]); ArrayResize(_chandles,0); Alert(_description+" initialization failed"); }
   return(_answer);
}  
//------------------------------------------------------------------