//------------------------------------------------------------------
#property copyright   "© mladen, 2021"
#property link        "mladenfx@gmail.com"
#property description "Moving Average Bands"
#property description "Based on work published by Vitali Apirine"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers  9
#property indicator_plots    5
#property indicator_label1   "Candles"
#property indicator_type1    DRAW_COLOR_CANDLES
#property indicator_color1   clrDarkGray,clrMediumSeaGreen,clrCoral
#property indicator_label2   "MidLine - long term ema"
#property indicator_type2    DRAW_LINE
#property indicator_color2   clrDarkGray
#property indicator_label3   "Short term ema"
#property indicator_type3    DRAW_LINE
#property indicator_color3   clrRed
#property indicator_style3   STYLE_DASHDOTDOT
#property indicator_label4   "Upper band"
#property indicator_type4    DRAW_LINE
#property indicator_color4   clrMediumSeaGreen
#property indicator_label5   "Lower band"
#property indicator_type5    DRAW_LINE
#property indicator_color5   clrCoral

//
//
//

input double             inpPeriodSlow      = 50;          // Slow period
input double             inpPeriodFast      = 10;          // Fast period
input double             inpBandMultiplier  = 1.0;         // Bands multiplier
input ENUM_APPLIED_PRICE inpPrice           = PRICE_CLOSE; // Price

//
//
//

double emaSlow[],emaFast[],bandup[],banddn[],candleO[],candleH[],candleL[],candleC[],candlec[];
struct sGlobalStruct
{
   int    periodSum;
   double periodDiv;
   double alphaFast;
   double alphaSlow;
};
sGlobalStruct global;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,candleO,INDICATOR_DATA);
   SetIndexBuffer(1,candleH,INDICATOR_DATA);
   SetIndexBuffer(2,candleL,INDICATOR_DATA);
   SetIndexBuffer(3,candleC,INDICATOR_DATA);
   SetIndexBuffer(4,candlec,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,emaSlow,INDICATOR_DATA);
   SetIndexBuffer(6,emaFast,INDICATOR_DATA);
   SetIndexBuffer(7,bandup ,INDICATOR_DATA);
   SetIndexBuffer(8,banddn ,INDICATOR_DATA);
   
      //
      //
      //
      
      double _fast = MathMin(inpPeriodFast,inpPeriodSlow);
      double _slow = MathMax(inpPeriodFast,inpPeriodSlow);
               global.alphaFast = 2.0 / (1.0 + MathMax(_fast,1));
               global.alphaSlow = 2.0 / (1.0 + MathMax(_slow,1));
               global.periodSum = (int)MathMax(_fast,1);
               global.periodDiv =      MathMax(_fast,1);

      //
      //
      //
            
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int &spread[])
{
   int _limit = (prev_calculated>0) ? prev_calculated-1 : 0;

   //
   //
   //

      struct sWorkStruct
            {
               double emaFast;
               double emaSlow;
               double emaDiff;
               double sumDiff;
               int    state;
            };   
      static sWorkStruct m_work[];
      static int         m_workSize = -1;
                     if (m_workSize<rates_total) m_workSize = ArrayResize(m_work,rates_total+500,2000);

      //
      //
      //

      for (int i=_limit; i<rates_total; i++)
         {
            double _price = iGetPrice(inpPrice,open,high,low,close,i);
               m_work[i].emaFast = (i>0) ? m_work[i-1].emaFast + global.alphaFast*(_price-m_work[i-1].emaFast) : _price;
               m_work[i].emaSlow = (i>0) ? m_work[i-1].emaSlow + global.alphaSlow*(_price-m_work[i-1].emaSlow) : _price;
               m_work[i].emaDiff = (m_work[i].emaFast-m_work[i].emaSlow)*(m_work[i].emaFast-m_work[i].emaSlow);
               if (i>global.periodSum)
                     { m_work[i].sumDiff = m_work[i-1].sumDiff + m_work[i].emaDiff - m_work[i-global.periodSum].emaDiff; }
               else  { m_work[i].sumDiff = m_work[i].emaDiff; for (int k=1; k<global.periodSum && i>=k; k++) m_work[i].sumDiff += m_work[i-k].emaDiff; }

            //
            //
            //

            double _dv         = m_work[i].sumDiff/global.periodDiv;
            double _deviation  = (_dv) ? MathSqrt(_dv) * inpBandMultiplier : 0;
               emaSlow[i] = m_work[i].emaSlow;
               emaFast[i] = m_work[i].emaFast;
               bandup[i]  = m_work[i].emaSlow + _deviation;
               banddn[i]  = m_work[i].emaSlow - _deviation;
               
               m_work[i].state = (emaFast[i]>bandup[i]) ? 1 : (emaFast[i]<banddn[i]) ? -1 : 0;
               
                  if (m_work[i].state!=0)
                     {
                        candleO[i] = open[i];
                        candleH[i] = high[i];
                        candleL[i] = low[i];
                        candleC[i] = close[i];
                        candlec[i] = m_work[i].state == 1 ?  1 : 2;
                     }
                  else 
                     {                        
                        candleO[i] =
                        candleH[i] =
                        candleL[i] =
                        candleC[i] = EMPTY_VALUE;
                        candlec[i] = 0;
                     }                        
         }

   //
   //
   //

   return(rates_total);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//

double iGetPrice(ENUM_APPLIED_PRICE price,const double& open[], const double& high[], const double& low[], const double& close[], int i)
{
   switch (price)
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