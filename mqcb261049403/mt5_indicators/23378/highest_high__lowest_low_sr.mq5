//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Highest high / lowest low SR"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 13
#property indicator_plots   6
#property indicator_label1  "fill 1"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'235,255,235',C'255,235,235'
#property indicator_label2  "fill 2"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  C'235,255,255',C'255,230,230'
#property indicator_label3  "hh1"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrNONE,clrGray
#property indicator_style3  STYLE_DOT
#property indicator_label4  "ll1"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrNONE,clrGray
#property indicator_style4  STYLE_DOT
#property indicator_label5  "hh2"
#property indicator_type5   DRAW_COLOR_LINE
#property indicator_color5  clrNONE,clrGray
#property indicator_style5  STYLE_DOT
#property indicator_label6  "ll2"
#property indicator_type6   DRAW_COLOR_LINE
#property indicator_color6  clrNONE,clrGray
#property indicator_style6  STYLE_DOT

input int  inpFastHlPeriod   = 8;  // Fast highest high/lowest low period
input int  inpSlowHlPeriod   = 21; // Slow highest high/lowest low period

//
//--- indicator buffers
//
double hh1[],hh1c[],hh2[],hh2c[],ll1[],ll1c[],ll2[],ll2c[],fh1[],fh2[],fl1[],fl2[],trend[];
int ª_rsfHandle,ª_rssHandle;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //---
   //
         SetIndexBuffer( 0,fh1  ,INDICATOR_DATA);
         SetIndexBuffer( 1,fl1  ,INDICATOR_DATA);
         SetIndexBuffer( 2,fh2  ,INDICATOR_DATA);
         SetIndexBuffer( 3,fl2  ,INDICATOR_DATA);
         SetIndexBuffer( 4,hh1  ,INDICATOR_DATA);
         SetIndexBuffer( 5,hh1c ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer( 6,ll1  ,INDICATOR_DATA);
         SetIndexBuffer( 7,ll1c ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer( 8,hh2  ,INDICATOR_DATA);
         SetIndexBuffer( 9,hh2c ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(10,ll2  ,INDICATOR_DATA);
         SetIndexBuffer(11,ll2c ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(12,trend,INDICATOR_CALCULATIONS);
         
   //
   //---
   //      
   IndicatorSetString(INDICATOR_SHORTNAME,"Highest high / lowest low SR ("+(string)inpFastHlPeriod+","+(string)inpSlowHlPeriod+")");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
// Custom iteration function
//------------------------------------------------------------------

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
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      iMinMaxFast.calculate(low[i],high[i],inpFastHlPeriod,ll2[i],hh2[i],i); fh2[i] = hh2[i]; fl2[i] = ll2[i]; 
      iMinMaxSlow.calculate(low[i],high[i],inpSlowHlPeriod,ll1[i],hh1[i],i);
      if (i>0)
      {
         trend[i] = (hh1[i]>hh1[i-1] || ll1[i]>ll1[i-1]) ? 1 : (hh1[i]<hh1[i-1] || ll1[i]<ll1[i-1]) ? -1 : trend[i-1];
         fh1[i]   = (trend[i]==1) ? hh1[i] : ll1[i];
         fl1[i]   = (trend[i]==1) ? ll1[i] : hh1[i];
         hh1c[i]  = (hh1[i]==hh1[i-1]) ? 1 : 0;
         hh2c[i]  = (hh2[i]==hh2[i-1]) ? 1 : 0;
         ll1c[i]  = (ll1[i]==ll1[i-1]) ? 1 : 0;
         ll2c[i]  = (ll2[i]==ll2[i-1]) ? 1 : 0;
      }      
      else { fh1[i] = hh1[i]; fl1[i] = ll1[i]; trend[i] = 0; }
   }
   return(i);
}

//------------------------------------------------------------------
// Custom function(s)
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

cMinMax iMinMaxFast,iMinMaxSlow;

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
//+------------------------------------------------------------------+