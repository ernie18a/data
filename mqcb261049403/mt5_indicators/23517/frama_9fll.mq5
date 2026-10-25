//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Frama (Ehlers) with floating levels"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   4
#property indicator_label1  "Upper level"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGray
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Middle level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Lower level"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGray
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Frama"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width4  2

//
//--- input parameters
//

enum enUseHighLow
{
   hl_useHighLow, // Use high/lows for extremes
   hl_usePrices   // Use selected price for extremes
};
enum enColorChangeOn
{
   cchange_onSlope,  // Change color on slope change
   cchange_onLevels, // Change color on levels crossing
   cchange_onZero    // Change color on middle level crossing
};

input int                inpFdiPeriod   =  30;              // Frama period
input ENUM_APPLIED_PRICE inpPrice       = PRICE_CLOSE;      // Price 
input enUseHighLow       inpHlMode      = hl_useHighLow;    // High/low mode
input int                inpFlPeriod    = 25;               // Floating levels period
input double             inpFlLevelUp   = 90;               // Floating levels up %
input double             inpFlLevelDn   = 10;               // Floating levels down %
input enColorChangeOn    inpColorChange = cchange_onLevels; // Color changing method

//
//--- buffers declarations
//

double val[],valc[],levu[],levd[],levm[],prices[];
int _fullSize,_halfSize,_halfSizem;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,levu  ,INDICATOR_DATA);
         SetIndexBuffer(1,levm  ,INDICATOR_DATA);
         SetIndexBuffer(2,levd  ,INDICATOR_DATA);
         SetIndexBuffer(3,val   ,INDICATOR_DATA);
         SetIndexBuffer(4,valc  ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(5,prices,INDICATOR_CALCULATIONS);
               _fullSize  = MathMax(inpFdiPeriod,2);
               _halfSize  = MathMax(_fullSize/2,1);
               _halfSizem = (_halfSize>1) ? _halfSize-1 : 1;
   //         
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Frama (Ehlers) fl ("+(string)_fullSize+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------

//
//---
//

#define _setPrice(_priceType,_where,_index) { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE:    _where = close[_index];                                              break; \
      case PRICE_OPEN:     _where = open[_index];                                               break; \
      case PRICE_HIGH:     _where = high[_index];                                               break; \
      case PRICE_LOW:      _where = low[_index];                                                break; \
      case PRICE_MEDIAN:   _where = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL:  _where = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED: _where = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _where = 0; \
   }}

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
   static int prev_i=-1;
   static double hh_prev,ll_prev,hh_curr,ll_curr,save_n1,save_n2,save_n3,n1,n2,n3,alpha;

   //
   //---
   //

   int i= prev_calculated-1; if (i<0) i = 0; for(; i<rates_total && !_StopFlag; i++)
   {
      _setPrice(inpPrice,prices[i],i);

      //
      //---
      //

         if (prev_i!=i)
         {
            prev_i = i; int start;

               if (inpHlMode==hl_useHighLow)
               {
                  start = i-_fullSize+1; if (start<0) start=0;
                     hh_prev = high[ArrayMaximum(high,start,_halfSize)];
                     ll_prev = low[ArrayMinimum(low,start,_halfSize)];
                  start = i-_halfSize+1; if (start<0) start=0;
                     hh_curr = high[ArrayMaximum(high,start,_halfSizem)];
                     ll_curr = low[ArrayMinimum(low,start,_halfSizem)];
               }                  
               else
               {
                  start = i-_fullSize+1; if (start<0) start=0;
                     hh_prev = prices[ArrayMaximum(prices,start,_halfSize)];
                     ll_prev = prices[ArrayMinimum(prices,start,_halfSize)];
                  start = i-_halfSize+1; if (start<0) start=0;
                     hh_curr = prices[ArrayMaximum(prices,start,_halfSizem)];
                     ll_curr = prices[ArrayMinimum(prices,start,_halfSizem)];
               }

               n1 = (hh_prev-ll_prev)/(double)_halfSize;
         }

         //
         //---
         //

         double hh = MathMax((inpHlMode==hl_useHighLow)?high[i]:prices[i],hh_curr);
         double ll = MathMin((inpHlMode==hl_useHighLow)?low[i] :prices[i],ll_curr);
                n2 = (hh-ll)/(double)_halfSize;

                if (hh_prev>hh) hh = hh_prev;
                if (ll_prev<ll) ll = ll_prev;

                n3 = (hh-ll)/(double)_fullSize;

                if (save_n1!=n1 || save_n2!=n2 || save_n3!=n3)
                {
                     save_n1 = n1;
                     save_n2 = n2;
                     save_n3 = n3;

                     double dimen = (MathLog(n1+n2)-MathLog(n3))/M_LN2;
                            alpha = MathMin(MathMax(MathExp(-4.6*(dimen-1.0)),DBL_MIN),1.000);
                 }

      //
      //---
      //

      val[i]  = (i>0) ? alpha*prices[i]+(1.0-alpha)*val[i-1] : prices[i];
         double _min,_max; _framaMinMax.calculate(val[i],val[i],inpFlPeriod,_min,_max,i);
         double range = (_max-_min)/100.0;
         levu[i] = _min+inpFlLevelUp*range;
         levd[i] = _min+inpFlLevelDn*range;
         levm[i] = (levu[i]+levd[i])/2;
   
         switch (inpColorChange)
         {
            case cchange_onLevels : valc[i] = (val[i]>levu[i]) ? 1 :(val[i]<levd[i]) ? 2 : 0; break;
            case cchange_onSlope  : valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1] : 0; break;
            case cchange_onZero   : valc[i] = (val[i]>levm[i]) ? 1 :(val[i]<levm[i]) ? 2 : 0; break;
         }         
   }   
   return (i);
}
//------------------------------------------------------------------
//    Custom function(s)
//------------------------------------------------------------------
//
//---
//

class cMinMax
{
   private :
      int    originalPeriod;
      int    period;
      int    prevbar;
      double currmin;
      double currmax;
      double prevmax;
      double prevmin;
      double minArray[];
      double maxArray[];
         
   public :
      cMinMax() { originalPeriod = prevbar = INT_MIN;       return; }
     ~cMinMax() { ArrayFree(minArray); ArrayFree(maxArray); return; }
     
      //
      //
      //
     
      void calculate(double valueMin, double valueMax, int forPeriod, double& min, double& max, int i)
      {
         if (prevbar!=i)
         {
            prevbar = i;
               if (originalPeriod!=forPeriod)
               {
                     originalPeriod =  forPeriod;
                     period         = (forPeriod>0) ? forPeriod : 1;
                     prevmin        = valueMin;
                     prevmax        = valueMax;
                     currmin        = valueMin;
                     currmax        = valueMax;
                           ArrayResize(minArray,period-1); ArrayInitialize(minArray,valueMin);
                           ArrayResize(maxArray,period-1); ArrayInitialize(maxArray,valueMax);
               }
               if (period>1)
               {
                  int _pos = (i) % (period-1);
                     minArray[_pos] = currmin;
                     maxArray[_pos] = currmax;
                     prevmin        = minArray[ArrayMinimum(minArray)];
                     prevmax        = maxArray[ArrayMaximum(maxArray)];
               }
               else  { prevmin = valueMin; prevmax = valueMax; }
         }

         //
         //
         //
            
         currmin = valueMin;
         currmax = valueMax;
            max = (prevmax>valueMax) ? prevmax : valueMax;
            min = (prevmin<valueMin) ? prevmin : valueMin;
         return;
     }
};
cMinMax _framaMinMax;
//------------------------------------------------------------------
