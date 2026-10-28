//+------------------------------------------------------------------+
//|                                                   KeyFinder2.mq5 |
//|                                                   Trofimov Pavel |
//|                                               trofimovpp@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Trofimov Pavel"
#property link      "trofimovpp@mail.ru"
#property version   "2.00"
#property description "Warning! This algorithm uses loops for calculations!"
#property description "It is recommended so set not more than 1000 to process!"
#property script_show_inputs
//--- input parameters
input int      MinDimesion=5; //Minimum dimension of points
input int      MaxBars=300;   //The number of bars to process
#include       "KeyFinder.mqh"
#include       <ChartObjects\ChartObjectsTxtControls.mqh>
//+------------------------------------------------------------------+
//| Script variables                                                 |
//+------------------------------------------------------------------+
CKeyFinder           m_keyfinder;      //Declaring СKeyFinder class variable
CChartObjectButton   m_button_close;   //Declaring CChartObjectButton class variable
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//-Initializing variables
   MqlRates  rates_array[];
   string Com="\n\n\n";
   int iCod=CopyRates(Symbol(),Period(),0,MaxBars,rates_array);// The number of elements in MqlRates array that we were able to copy
   int sy=10;//Button position
   if(ChartGetInteger(0,CHART_SHOW_OHLC))
      sy+=16;
//-Setting the necessary parameters   
   m_keyfinder.SetMaxBars(MaxBars);
   m_keyfinder.SetMinDimension(MinDimesion);
   m_keyfinder.CleanChart();//Clearing the chart from objects in case of a second use 
   iCod=iCod-1;//An index of the maximum element in rates_array[]
   Com+="Working...Please, wait!";
//-Creating the button and setting its properties
   m_button_close.Create(0,"ButtonClose",0,10,sy,100,20);
   m_button_close.Description("Close Script");
   m_button_close.Color(Blue);
   m_button_close.FontSize(8);
   Comment(Com);
//-Processing the bars using the CKeyFinder class methods   
   if(iCod>0)
     {
      m_keyfinder.FindUpKeyPoints(iCod,rates_array);//Searching for upper key points
      Com+="\nUpper points have been processed.\n";
      Comment(Com);
      m_keyfinder.FindLowKeyPoints(iCod,rates_array);//Searching for lower key points
      Comment("\n\n\nProcessing is complete");
     }
   else Comment("\n\n\nNo bars to process!!!");
   m_button_close.State(false);
//-Looping the script until the button is pressed
   while(!(m_button_close.State()))
     {
      //--- redraw chart
      ChartRedraw();
      Sleep(250);
     };
//-Clearing the chart by a press of the button
   m_keyfinder.CleanChart();
   Comment("");
  }
//+------------------------------------------------------------------+
