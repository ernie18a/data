//+------------------------------------------------------------------+
//|                                          Tipu Signal Plotter.mq4 |
//|                                   Copyright 2016, Kaleem Haider. |
//|               https://www.mql5.com/en/users/kaleem.haider/seller |
//+------------------------------------------------------------------+
#property copyright   "Copyright © 2016, Kaleem Haider."
#property link        "https://www.mql5.com/en/users/kaleem.haider/seller"
#property version   "1.00"
#property description "Tipu Signal Plotter."
#property strict
#property indicator_chart_window

#include <stdlib.mqh>
#define PipsPoint Get_PipsPoint()
//+------------------------------------------------------------------+
//| Structure for History Load
//| Add more if you like more                                        
//+------------------------------------------------------------------+
struct STRUC_History
  {
   datetime          OpenTime,CloseTime;
   string            OrderType,Symbol,Comment;
   double            Lots,OpenPrice,SLPrice,SLPips,TPPrice,TPPips,ClosePrice,Commission,Swap,Profit;
  };
//+------------------------------------------------------------------+
//| used to convert points to pips and viceversa
//+------------------------------------------------------------------+
double Get_PipsPoint()
  {
   double PP=(_Digits==5 || _Digits==3)?_Point*10:_Point;
   return (PP);
  }

input string sFileName="history.csv"; //File Name
input string sFileDirectory="Tipu History"; //File Directory
input string sDisplay="Display Order------"; //Display Orders
input int iHOffset            = 6;     //Hour Offset
input bool bBuy               = true;  //Buy Orders?
input bool bBuyLimit          = false; //Buy Limit
input bool bBuyStop           = false; //Buy Stop
input bool bSell              = true;  //Sell
input bool bSellLimit         =false;  //Sell Limit
input bool bSellStop=false;  //Sell Stop
input string sColors="Display Order------"; //Colors Settings
input color cBuy=clrBlue;        //Buy Color
input color cBuyLimit=clrAquamarine;   //Buy Limit Color
input color cBuyStop          = clrPurple;   //Buy Limit Color
input color cSell             =clrRed;       //Sell Color
input color cSellLimit=clrOrange;  //Sell Limit Color
input color cSellStop=clrOrangeRed;  //Sell Limit Color
input color cSL = clrRed;           //SL Color
input color cTP = clrGreen;         //TP Color

STRUC_History tHistory[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   bool flag=false;
   int i=0,j=0;
   string stest[];

   ResetLastError();

   int file_handle= FileOpen(sFileDirectory+"//"+sFileName,FILE_READ|FILE_CSV,";");
   int ilasterror = GetLastError();
   if(ilasterror != 0)
     {
      Print("Failed Init: Unable to load history "+(string)ilasterror+" "+ErrorDescription(ilasterror));
      return(INIT_FAILED);
     }
//skip headers
   while(!FileIsLineEnding(file_handle))
     {
      ArrayResize(stest,i+1);
      stest[i]=FileReadString(file_handle);
      i++;
     }

//Load Data - save data   
   i=0;
   ArrayFree(stest);
   while(!FileIsEnding(file_handle))
     {
      ArrayResize(stest,i+1);
      stest[i]=FileReadString(file_handle);
      i++;
      if(FileIsLineEnding(file_handle))
        {
         ArrayResize(tHistory,j+1);
         tHistory[j].OpenTime=(datetime)stest[0]+iHOffset*60*60;
         tHistory[j].OrderType=stest[1];
         tHistory[j].Lots=(double)stest[2];
         tHistory[j].Symbol=stest[3];
         tHistory[j].OpenPrice=(double)stest[4];
         tHistory[j].SLPrice = (double)stest[5];
         tHistory[j].TPPrice = (double)stest[6];
         tHistory[j].CloseTime=(datetime)stest[7]+iHOffset*60*60;
         tHistory[j].ClosePrice = (double)stest[8];
         tHistory[j].Commission = (double)stest[9];
         tHistory[j].Swap=(double)stest[10];
         tHistory[j].Profit=(double)stest[11];
         tHistory[j].Comment=stest[12];
         j++;
         i=0;
         ArrayFree(stest);
        }
     }

//mark lines 
   for(i=0; i<ArraySize(tHistory)-1;i++)
     {
      if(tHistory[i].Symbol==_Symbol)
        {
         MarkOrders(0,"tHistory"+(string)tHistory[i].OpenTime,0,tHistory[i].OpenTime
                    ,tHistory[i].OpenPrice,tHistory[i].CloseTime,tHistory[i].ClosePrice
                    ,tHistory[i].SLPrice,tHistory[i].TPPrice,tHistory[i].OrderType
                    ,StringFormat("%.2f %+.2f, %+.2f pips",tHistory[i].Lots,tHistory[i].Profit,((tHistory[i].Profit)>0?1:-1)*MathAbs(tHistory[i].OpenPrice-tHistory[i].ClosePrice)/PipsPoint));
        }
     }

   FileClose(file_handle);

/*---------------------------------------------------------------------------
//check load
*/
//---------------------------------------------------------------------------
/*
   for(i=0; i<ArraySize(tHistory); i++)
     {
      Print("tHistory["+(string)i+"].OpenTime "+(string)tHistory[i].OpenTime);
      Print("tHistory["+(string)i+"].OrderType "+(string)tHistory[i].OrderType);
      Print("tHistory["+(string)i+"].Lots "+(string)tHistory[i].Lots);
      Print("tHistory["+(string)i+"].Symbol "+(string)tHistory[i].Symbol);
      Print("tHistory[" +(string)i + "].OpenPrice " +(string)tHistory[i].OpenPrice);
      Print("tHistory[" + (string)i + "].SLPrice " + (string)tHistory[i].SLPrice);
      Print("tHistory[" + (string)i + "].TPPrice " + (string)tHistory[i].TPPrice);
      Print("tHistory[" +(string)i + "].CloseTime " +(string)tHistory[i].CloseTime);
      Print("tHistory[" + (string)i + "].ClosePrice " + (string)tHistory[i].ClosePrice);
      Print("tHistory[" + (string)i + "].Commission " + (string)tHistory[i].Commission);
      Print("tHistory["+(string)i+"].Swap "+(string)tHistory[i].Swap);
      Print("tHistory["+(string)i+"].Profit "+(string)tHistory[i].Profit);
      Print("tHistory["+(string)i+"].Comment "+(string)tHistory[i].Comment);
     }
//*/
//-------------------------------------------------------------------------
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,"tHistory");
   return;
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
//---

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+ 
//| Create a trend line by the given coordinates                     | 
//+------------------------------------------------------------------+ 
bool MarkOrders(const long            chart_ID=0,// chart's ID 
                const string          name="TrendLine", // line name 
                const int             sub_window=0,     // subwindow index 
                datetime              opentime=0,       // open time
                double                openprice=0,      // open price
                datetime              closetime=0,      // close time
                double                closeprice=0,     // close price
                double                sl=0,             // stop loss
                double                tp=0,             // target profit
                string                type="Buy",       // order type
                string                tooltip="") // second point price 

  {
   color           clr=clrWhite;
   ENUM_LINE_STYLE style=STYLE_DOT; // line style 
   int             width=1;           // line width 
   bool            back=false;        // in the background 
   bool            selection=false;    // highlight to move 
   bool            ray_right=false;   // line's continuation to the right 
   bool            hidden=true;       // hidden in the object list 
   long            z_order=0;         // priority for mouse click 

   if(type=="Buy")
      if(bBuy) clr = cBuy; else return(false);
   if(type=="Sell")
      if(bSell) clr = cSell; else return(false);
   if(type=="Buy Limit")
      if(bBuyLimit) clr = cBuyLimit; else return(false);
   if(type=="Buy Stop")
      if(bBuyStop) clr = cBuyStop; else return(false);
   if(type=="Sell Limit")
      if(bSellLimit) clr = cSellLimit; else return(false);
   if(type=="Sell Stop")
      if(bSellStop) clr = cSellStop; else return(false);


//--- set anchor points' coordinates if they are not set 
   ChangeTrendEmptyPoints(opentime,openprice,closetime,closeprice);
//--- reset the error value 
   ResetLastError();
//--- create a trend line by the given coordinates 
   if(!ObjectCreate(chart_ID,name,OBJ_TREND,sub_window,opentime,openprice,closetime,closeprice))
     {
      Print(__FUNCTION__,
            ": failed to create a trend line! Error code = ",GetLastError());
      return(false);
     }

//trend line
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,tooltip);

//arrow for stop loss
   if(sl>0)
     {
      ObjectCreate(0,name+"sl",OBJ_ARROW_BUY,0,opentime,sl);
      ObjectSetInteger(chart_ID,name+"sl",OBJPROP_COLOR,cSL);
      ObjectSet(name+"sl",OBJPROP_ARROWCODE,4);
      ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,tooltip);
     }

//arry for target profit
   if(tp>0)
     {
      ObjectCreate(0,name+"tp",OBJ_ARROW_BUY,0,opentime,tp);
      ObjectSetInteger(chart_ID,name+"tp",OBJPROP_COLOR,cTP);
      ObjectSet(name+"tp",OBJPROP_ARROWCODE,4);
      ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,tooltip);
     }

//arrow for open
   ObjectCreate(0,name+"ao",OBJ_ARROW_BUY,0,opentime,openprice);
   ObjectSet(name+"ao",OBJPROP_ARROWCODE,2);
   ObjectSetInteger(chart_ID,name+"ao",OBJPROP_COLOR,clr);
   ObjectSetString(chart_ID,name+"ao",OBJPROP_TOOLTIP,tooltip);

//arrow for close
   ObjectCreate(0,name+"ac",OBJ_ARROW_BUY,0,closetime,closeprice);
   ObjectSet(name+"ac",OBJPROP_ARROWCODE,3);
   ObjectSetInteger(chart_ID,name+"ac",OBJPROP_COLOR,clr);
   ObjectSetString(chart_ID,name+"ac",OBJPROP_TOOLTIP,tooltip);

//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Move trend line anchor point                                     | 
//+------------------------------------------------------------------+ 
bool TrendPointChange(const long   chart_ID=0,       // chart's ID 
                      const string name="TrendLine", // line name 
                      const int    point_index=0,    // anchor point index 
                      datetime     time=0,           // anchor point time coordinate 
                      double       price=0)          // anchor point price coordinate 
  {
//--- if point position is not set, move it to the current bar having Bid price 
   if(!time)
      time=TimeCurrent();
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);

   ResetLastError();

   if(!ObjectMove(chart_ID,name,point_index,time,price))
     {
      Print(__FUNCTION__,
            ": failed to move the anchor point! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Check the values of trend line's anchor points and set default   | 
//| values for empty ones                                            | 
//+------------------------------------------------------------------+ 
void ChangeTrendEmptyPoints(datetime &opentime,double &openprice,
                            datetime &closetime,double &closeprice)
  {

   if(!opentime)
      opentime=TimeCurrent();
   if(!openprice)
      openprice=SymbolInfoDouble(Symbol(),SYMBOL_BID);

   if(!closetime)
     {

      datetime temp[10];
      CopyTime(Symbol(),Period(),opentime,10,temp);
      closetime=temp[0];
     }

   if(!closeprice)
      closeprice=openprice;
  }
//+------------------------------------------------------------------+
