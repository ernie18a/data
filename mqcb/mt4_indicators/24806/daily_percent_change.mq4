/*------------------------------------------------------------------+
//| Daily Percent Change                                            |
//+-----------------------------------------------------------------+
*/

#property copyright "Copyright © 2019, Rob Rice"
#property indicator_chart_window
#property strict

//---- input parameters5

//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int init()
{

return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
{
Comment("");
return(0);
}

int start()
{
double O = iOpen(NULL,PERIOD_D1,0);
double C = iClose(NULL,0,0);
double Pchange = NormalizeDouble(((C - O) / O * 100),2);

Comment("Open = ",O," Current = ",C," Change Today = ",Pchange,"%");

return(0);
}
//+------------------------------------------------------------------+