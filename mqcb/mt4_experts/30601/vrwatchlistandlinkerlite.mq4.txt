//************************************************************************************************/
//*                               VR Watch List and Linker Lite                                  */
//*                            Copyright 2019, Trading-go Project.                               */
//*                           Author: Voldemar, Version: 10.01.2019.                             */
//*                   Site   https://trading-go.ru   https://trading-go.net                      */
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
//* Full version MetaTrader 4  https://www.mql5.com/ru/market/product/10341                      */
//* Lite version MetaTrader 4  https://www.mql5.com/ru/code/24049                                */
//* Full version MetaTrader 5  https://www.mql5.com/ru/market/product/10714                      */
//* Lite version MetaTrader 5  https://www.mql5.com/ru/code/24050                                */
//* Blog entry RU              https://www.mql5.com/ru/blogs/post/723833                         */
//* Blog entry EN              https://www.mql5.com/en/blogs/post/723834                         */
//************************************************************************************************/
//* All products of the Author https://www.mql5.com/ru/users/voldemar/seller
//************************************************************************************************/
#property copyright   "Copyright 2019, Trading-go Project."
#property link        "https://trading-go.ru"
#property version     "19.010"
#property description "The Expert Advisor changes the financial instrument by dragging the tool (Drag-and-drop) from the \"Market Watch\" window. The user simply dragging the financial instrument into the chart window where the adviser is installed. "
#property strict
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
struct CHART
  {
   long              id;
   string            sy;
   ENUM_TIMEFRAMES   tf;
  };
CHART             window[];
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
int OnInit()
  {
   Comment("");

   GetAllCharts(window);

   string aSymbol=Symbol();
   int k=ArraySize(window);
   for(int i=0;i<k;i++)
      if(ChartSetSymbolPeriod(window[i].id,aSymbol,ChartPeriod(window[i].id)))
         ChartRedraw(window[i].id);

   return(INIT_SUCCEEDED);
  }
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
void OnTimer()
  {

  }
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
void OnDeinit(const int reason)
  {

  }
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
int GetAllCharts(CHART  &chart[])
  {
   int i=0;
   long prevChart=ChartFirst();
   ArrayResize(chart,i+1,1000);
   chart[i].id=prevChart;
   chart[i].sy=ChartSymbol(prevChart);
   chart[i].tf=ChartPeriod(prevChart);
   while(i<30)
     {
      i++;
      if((prevChart=ChartNext(prevChart))<0)
        {
         ResetLastError();
         return i;
        }
      ArrayResize(chart,i+1,1000);
      chart[i].id=prevChart;
      chart[i].sy=ChartSymbol(prevChart);
      chart[i].tf=ChartPeriod(prevChart);
     }
   return i;
  }
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
