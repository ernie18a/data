//+------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "Asymmetric bands oscillator"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 10
#property indicator_plots   5
#property indicator_label1  "Bear fill"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'255,235,235';
#property indicator_label2  "Bull fill"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  C'235,255,235';
#property indicator_label3  "Band up"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrMediumSeaGreen
#property indicator_label4  "Average"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrDarkGray
#property indicator_label5  "Band down"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrOrangeRed
//
//--- input parameters
//
input int                inpBandPeriod     = 14;          // Bands period
input ENUM_APPLIED_PRICE inpBandPrice      = PRICE_CLOSE; // Price
input ENUM_MA_METHOD     inpBandMethod     = MODE_SMA;    // Bands average method
input double             inpBandDeviations = 2;           // Bands deviation
//
//--- buffers declarations
//
double valu[],vald[],vala[],wu[],wd[],avg[],filluu[],fillud[],filldu[],filldd[];
//--- indicator handles
int _maHandle;
//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,filluu,INDICATOR_DATA);
         SetIndexBuffer(1,fillud,INDICATOR_DATA);
         SetIndexBuffer(2,filldu,INDICATOR_DATA);
         SetIndexBuffer(3,filldd,INDICATOR_DATA);
         SetIndexBuffer(4,valu,INDICATOR_DATA);
         SetIndexBuffer(5,vala,INDICATOR_DATA);
         SetIndexBuffer(6,vald,INDICATOR_DATA);
         SetIndexBuffer(7,wu  ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(8,wd  ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(9,avg ,INDICATOR_CALCULATIONS);
            _maHandle=iMA(_Symbol,0,inpBandPeriod,0,inpBandMethod,inpBandPrice); if(_maHandle==INVALID_HANDLE) { return(INIT_FAILED); }
   //            
   //---
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Asymmetric "+StringSubstr(EnumToString(inpBandMethod),5)+" bands ("+(string)inpBandPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int _copyCount = rates_total-prev_calculated+1; if (_copyCount>rates_total) _copyCount=rates_total;
         if (CopyBuffer(_maHandle,0,0,_copyCount,avg)!=_copyCount) return(prev_calculated);
   
   //
   //---
   //
  

   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      double price=getPrice(inpBandPrice,open,close,high,low,i);
      if (avg[i]==EMPTY_VALUE) avg[i] = price;
      
      //
      //---
      //
      
      double diff=price-avg[i];
         if (i<1) wu[i] = wd[i] = 0; 
         else
            if(diff>0)
            {
               wu[i] = (wu[i-1]*(inpBandPeriod-1)+diff*diff)/inpBandPeriod;
               wd[i] =  wd[i-1]*(inpBandPeriod-1)/inpBandPeriod;
            }
            else
            {
               wd[i] = (wd[i-1]*(inpBandPeriod-1)+diff*diff)/inpBandPeriod;
               wu[i] =  wu[i-1]*(inpBandPeriod-1)/inpBandPeriod;
            }

         double range = inpBandDeviations*(wu[i]+wd[i]);
         
         vala[i] = fillud[i] = filldu[i] = (range!=0) ? 1.0-2.0*(inpBandDeviations*wd[i])/range : 0;
         valu[i] = filluu[i] = 1;
         vald[i] = filldd[i] = -1;
     }
   return (i);
  }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i)
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
//------------------------------------------------------------------
