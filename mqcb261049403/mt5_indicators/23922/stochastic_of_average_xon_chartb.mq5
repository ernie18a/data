//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "On-chart stochastic of average"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 11
#property indicator_plots   6
#property indicator_label1  "Upper filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'255,240,240'
#property indicator_label2  "Lower filling"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  C'240,255,240'
#property indicator_label3  "Upper level"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGray
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Middle level"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGray
#property indicator_style4  STYLE_DOT
#property indicator_label5  "Lower level"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrGray
#property indicator_style5  STYLE_DOT
#property indicator_label6  "Stochastic"
#property indicator_type6   DRAW_COLOR_LINE
#property indicator_color6  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width6  2

//
//
//

enum enColorChangeOn
{
   cchange_onSlope,  // Change color on slope change
   cchange_onLevels, // Change color on OB/OS level
   cchange_onZero    // Change color on level 50 cross
};
input int                inpStoPeriod   = 14;          // Stochastic period
input int                inpStoSlowing  =  3;          // Stochastic slowing
input int                inpAvgPeriod   = 14;          // Average period
input ENUM_MA_METHOD     inpAvgMethod   = MODE_EMA;    // Average method
input ENUM_APPLIED_PRICE inpAvgPrice    = PRICE_CLOSE; // Price 
input int                inpHlPeriod    = 25;          // Highest high/lowest low period
input double             inpHlLevelUp   = 70;          // OB level
input double             inpHlLevelDn   = 30;          // OS level
input enColorChangeOn    inpColorChange = cchange_onLevels; // Color changing mode

//
//---
//

double val[],valc[],filluu[],fillud[],filldd[],filldu[],levu[],levd[],levm[],sto[],avg[];
int  ª_maHandle,ª_maPeriod; string ª_maNames[] = {"SMA","EMA","SMMA","LWMA"};

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
         SetIndexBuffer( 0,filluu,INDICATOR_DATA);
         SetIndexBuffer( 1,fillud,INDICATOR_DATA);
         SetIndexBuffer( 2,filldu,INDICATOR_DATA);
         SetIndexBuffer( 3,filldd,INDICATOR_DATA);
         SetIndexBuffer( 4,levm  ,INDICATOR_DATA);
         SetIndexBuffer( 5,levu  ,INDICATOR_DATA);
         SetIndexBuffer( 6,levd  ,INDICATOR_DATA);
         SetIndexBuffer( 7,val   ,INDICATOR_DATA);
         SetIndexBuffer( 8,valc  ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer( 9,sto   ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(10,avg   ,INDICATOR_CALCULATIONS);
         
            ª_maPeriod = (inpAvgPeriod>1) ? inpAvgPeriod : 1;
            ª_maHandle = iMA(_Symbol,0,ª_maPeriod ,0,inpAvgMethod,inpAvgPrice); if (!_checkHandle(ª_maHandle,"Average")) return(INIT_FAILED);
            
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Stochastic of "+ª_maNames[inpAvgMethod]+" ("+(string)inpStoPeriod+","+(string)inpStoSlowing+","+(string)ª_maPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
//
//---
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
         if (CopyBuffer(ª_maHandle,0,0,_copyCount,avg)!=_copyCount) return(prev_calculated);

   //
   //---
   //

      static int    prev_i=-1;
      static double prev_max,prev_min;

   //
   //
   //
   
   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      if (avg[i]==EMPTY_VALUE) avg[i] = close[i];
         sto[i]  = iStoch.calculate(avg[i],avg[i],avg[i],inpStoPeriod,inpStoSlowing,i);
   
         //
         //---
         //
         
         if (prev_i!=i)
         {
            prev_i = i; 
            int start    = i-inpHlPeriod+1; if (start<0) start=0;
                prev_max = high[ArrayMaximum(high,start,inpHlPeriod-1)];
                prev_min = low [ArrayMinimum(low ,start,inpHlPeriod-1)];
         }
         double max = (high[i] > prev_max) ? high[i] : prev_max;
         double min = (low[i]  < prev_min) ? low[i]  : prev_min;
         double range = (max-min)/100.0;
            levu[i]   = min+inpHlLevelUp*range;
            levd[i]   = min+inpHlLevelDn*range;
            levm[i]   = min+          50*range;
            val[i]    = fillud[i] = filldu[i] = min+sto[i]*range;
            filluu[i] = max;
            filldd[i] = min;
         
         //
         //
         //
         
         switch (inpColorChange)
         {
            case cchange_onLevels : valc[i] = (val[i]>levu[i]) ? 1 :(val[i]<levd[i]) ? 2 : 0; break;
            case cchange_onSlope  : valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1] : 0; break;
            case cchange_onZero   : valc[i] = (val[i]>levm[i]) ? 1 :(val[i]<levm[i]) ? 2 : 0; break;
         }         
   }
   return(i);
}

//------------------------------------------------------------------
// Custom functions
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

//
//---
//

class cStochastic
{
   private :
      int      originalPeriod;
      int      period;
      int      slowing;
      int      slowingSize;
      double   diffh[];
      double   diffl[];
      double   sumh[];
      double   suml[];
      cMinMax* minMax;
         
    public :
      cStochastic() { minMax = new cMinMax; originalPeriod=-1; return; }
     ~cStochastic() { if (CheckPointer(minMax)==POINTER_DYNAMIC) delete(minMax); ArrayFree(diffh); ArrayFree(diffl); ArrayFree(sumh); ArrayFree(suml); return; }
     
     //
     //
     //
     
     double calculate(double price, double priceHigh, double priceLow, int forPeriod, int forSlowing, int i)
     {
         #define _ringSize 32
         if (originalPeriod!=forPeriod)
         {
            originalPeriod =  forPeriod;
            period         = (forPeriod>0) ? forPeriod : 1;
            slowing        = (forSlowing>0) ? forSlowing : 1;
            slowingSize    = slowing+_ringSize;
                  ArrayResize(diffh,slowingSize); ArrayInitialize(diffh,0);
                  ArrayResize(diffl,slowingSize); ArrayInitialize(diffl,0);
                  ArrayResize(sumh ,slowingSize); ArrayInitialize(sumh ,0);
                  ArrayResize(suml ,slowingSize); ArrayInitialize(suml ,0);
         }
         #undef _ringSize
      
         //
         //---
         //
      
         double min,max; minMax.calculate(priceLow,priceHigh,period,min,max,i);
         int _pos = (i) % slowingSize;
               diffh[_pos] = max  -min;
               diffl[_pos] = price-min;

               //
               //---
               //
                       
               if (i>slowing)
               {
                  int _posp = (i-1      ) % slowingSize;
                  int _posf = (i-slowing) % slowingSize;
                     sumh[_pos] = sumh[_posp]+diffh[_pos]-diffh[_posf];
                     suml[_pos] = suml[_posp]+diffl[_pos]-diffl[_posf];
               }
               else
               {
                  sumh[_pos] = diffh[_pos];
                  suml[_pos] = diffl[_pos];
                  for (int k=1, _posp=_pos-1; k<slowing; k++, _posp--)
                  {
                     if (_posp<0) _posp += slowingSize; 
                        sumh[_pos] += diffh[_posp];
                        suml[_pos] += diffl[_posp];
                  }
               }
         return((sumh[_pos]!=0.0)? 100.0*suml[_pos]/sumh[_pos]:0);
      }
};
cStochastic iStoch;

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