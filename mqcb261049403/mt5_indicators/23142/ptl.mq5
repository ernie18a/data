//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Perfect trend line"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   4
#property indicator_label1  "PTL slow line up"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_width1  2
#property indicator_label2  "PTL slow line down"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrCrimson
#property indicator_width2  2
#property indicator_label3  "PTL fast line"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDodgerBlue,clrCrimson
#property indicator_style3  STYLE_DOT
#property indicator_label4  "PTL trend start"
#property indicator_type4   DRAW_COLOR_ARROW
#property indicator_color4  clrDodgerBlue,clrCrimson
#property indicator_width4  2

//
//--- input parameters
//

input int inpFastLength = 3; // Fast length
input int inpSlowLength = 7; // Slow length

//
//--- indicator buffers
//

double slowlu[],slowld[],slowln[],fastln[],fastcl[],arrowcl[],arrowar[],trend[];

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //---
   //
         SetIndexBuffer(0,slowlu ,INDICATOR_DATA);
         SetIndexBuffer(1,slowld ,INDICATOR_DATA);
         SetIndexBuffer(2,fastln ,INDICATOR_DATA);
         SetIndexBuffer(3,fastcl ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(4,arrowar,INDICATOR_DATA); 
         SetIndexBuffer(5,arrowcl,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(6,trend  ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(7,slowln ,INDICATOR_CALCULATIONS);
   //
   //---
   //      
         PlotIndexSetInteger(3,PLOT_ARROW,159);
         
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
// Custom iteration function
//------------------------------------------------------------------
//
//---
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{                
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      int _startf = i-inpFastLength+1; if (_startf<0) _startf = 0;
      int _starts = i-inpSlowLength+1; if (_starts<0) _starts = 0;
         double thighs = high[ArrayMaximum(high,_starts,inpSlowLength)];
         double tlows  = low [ArrayMinimum(low ,_starts,inpSlowLength)];
         double thighf = high[ArrayMaximum(high,_startf,inpFastLength)];
         double tlowf  = low [ArrayMinimum(low ,_startf,inpFastLength)];
         if (i>0)
         {
            slowln[i] = (close[i]>slowln[i-1]) ? tlows : thighs;
            fastln[i] = (close[i]>fastln[i-1]) ? tlowf : thighf;
            trend[i]  =  trend[i-1];
               if (close[i]<slowln[i] && close[i]<fastln[i]) trend[i] = 1;
               if (close[i]>slowln[i] && close[i]>fastln[i]) trend[i] = 0;
               arrowar[i] = (trend[i]!=trend[i-1]) ? slowln[i] : EMPTY_VALUE;
               slowlu[i]  = (trend[i]==0) ? slowln[i] : EMPTY_VALUE;
               slowld[i]  = (trend[i]==1) ? slowln[i] : EMPTY_VALUE;
         }
         else { arrowar[i] = slowlu[i] = slowld[i] = EMPTY_VALUE; trend[i] = fastcl[i] = arrowcl[i] = 0; fastln[i] = slowln[i] = close[i]; }
         fastcl[i] = arrowcl[i] = trend[i];
   }          
   return(rates_total);
}