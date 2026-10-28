//+------------------------------------------------------------------+
//|                                      tradehistoryexporttocsv.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property strict
//---
#include <ChartObjects\ChartObjectPanel.mqh>
//---
#property indicator_chart_window
//--- input parameters
input string  InputFileName="OrdersHistory.csv";      // File name
input string  InputDirectoryName="Data";     // Folder name
//---
const datetime  MinDateTime=D'1970.01.01 00:00:00';
input datetime      InputHistoryStartDateTime=D'1970.01.01 00:00:00';// History Start Date Time
input datetime      InputHistoryEndDateTime=D'1970.01.01 00:00:00'; // History End Date Time
datetime HistoryStartDateTime=D'1970.01.01 00:00:00';
datetime HistoryEndDateTime=StringToTime(TimeToStr(TimeCurrent(),TIME_DATE))+1*24*60*60 -1;
//---
input bool     OpBuy=true; //Analysis Trade Type Buy
input bool     OpSell=true;//Analysis Trade Type Sell
//---
input bool     OpBuyLimit=true;//Analysis Trade Type Buy Limit
input bool     OpBuyStop=true;//Analysis Trade Type Buy Stop
//---
input bool     OpSellLimit=true;//Analysis Trade Type Sell Limit
input bool     OpSellStop=true;//Analysis Trade Type Sell Stop
//---
string  symbolString=NULL;
//---
CChartObjectButton CSVButton;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   HistoryStartDateTime=StringToTime(TimeToStr(InputHistoryStartDateTime,TIME_DATE));
   if(InputHistoryEndDateTime==MinDateTime)
     {
      HistoryEndDateTime=StringToTime(TimeToStr(TimeCurrent(),TIME_DATE))+1*24*60*60 -1;
     }
   else
     {
      HistoryEndDateTime=StringToTime(TimeToStr(InputHistoryEndDateTime,TIME_DATE))+1*24*60*60 -1;
     }
   symbolString=Symbol();
   CreateCSVButton(0);
   return(INIT_SUCCEEDED);
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
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(sparam=="CSVButton")
        {
         if(CSVButton.State()==true)
           {
            //---
            ResetLastError();
            //---
            int file_handle=FileOpen(InputDirectoryName+"//"+InputFileName,FILE_READ|FILE_WRITE|FILE_CSV);
            if(file_handle!=INVALID_HANDLE)
              {
               PrintFormat("%s file is available for writing",InputFileName);
               PrintFormat("File path: %s\\Files\\",TerminalInfoString(TERMINAL_DATA_PATH));
               //--- Call Step 4  
               WriteCSVObjects(file_handle);
               //--- close the file
               FileClose(file_handle);
               //---
               PrintFormat("Data is written, %s file is closed",InputFileName);
              }
            else
              {
               PrintFormat("Failed to open %s file, Error code = %d",InputFileName,GetLastError());
              }
           }
         //---
         ChartRedraw();
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CreateCSVButton(const long chart_ID=0)
  {
//--- reset the error value
   ResetLastError();
//--- set property values
   if(!CSVButton.Create(chart_ID,"CSVButton",0,10,25,75,15))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }
//---
   CSVButton.Description("Export CSV");
//---
   CSVButton.FontSize(10);
   CSVButton.Corner(CORNER_LEFT_LOWER);
   CSVButton.Anchor(ANCHOR_CENTER);
//---
   CSVButton.State(false);
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteCSVObjects(int file_hand)
  {
   string csvTitle=symbolString+" History "
                   +TimeToString(HistoryStartDateTime,TIME_DATE)
                   +" ~ "+TimeToString(HistoryEndDateTime,TIME_DATE);
   FileWrite(file_hand,csvTitle);
   string columnTitle="Type,Size,Commission,Swap,Profit";
   FileWrite(file_hand,columnTitle);
   string text="";
   if(OpBuy)
     {
      ENUM_ORDER_TYPE orderType=OP_BUY;
      SymbolExportOrdersHistoryCalculator(symbolString,orderType,1);
      text="BUY"+","+DoubleToStr(OrderLotsTotal,2)
           +","+DoubleToStr(OrderCommissionTotal,2)
           +","+DoubleToStr(OrderSwapTotal,2)
           +","+DoubleToStr(OrderProfitTotal,2);
      FileWrite(file_hand,text);
      SymbolExportOrdersHistoryCalculator(symbolString,orderType,0);
      text="BUY"+","+DoubleToStr(OrderLotsTotal,2)
           +","+DoubleToStr(OrderCommissionTotal,2)
           +","+DoubleToStr(OrderSwapTotal,2)
           +","+DoubleToStr(OrderProfitTotal,2);
      FileWrite(file_hand,text);
      SymbolExportOrdersHistoryCalculator(symbolString,orderType,-1);
      text="BUY"+","+DoubleToStr(OrderLotsTotal,2)
           +","+DoubleToStr(OrderCommissionTotal,2)
           +","+DoubleToStr(OrderSwapTotal,2)
           +","+DoubleToStr(OrderProfitTotal,2);
      FileWrite(file_hand,text);
     }
   if(OpSell)
     {
      ENUM_ORDER_TYPE orderType=OP_SELL;
      SymbolExportOrdersHistoryCalculator(symbolString,orderType,1);
      text="SELL"+","+DoubleToStr(OrderLotsTotal,2)
           +","+DoubleToStr(OrderCommissionTotal,2)
           +","+DoubleToStr(OrderSwapTotal,2)
           +","+DoubleToStr(OrderProfitTotal,2);
      FileWrite(file_hand,text);
      SymbolExportOrdersHistoryCalculator(symbolString,orderType,0);
      text="SELL"+","+DoubleToStr(OrderLotsTotal,2)
           +","+DoubleToStr(OrderCommissionTotal,2)
           +","+DoubleToStr(OrderSwapTotal,2)
           +","+DoubleToStr(OrderProfitTotal,2);
      FileWrite(file_hand,text);
      SymbolExportOrdersHistoryCalculator(symbolString,orderType,-1);
      text="SELL"+","+DoubleToStr(OrderLotsTotal,2)
           +","+DoubleToStr(OrderCommissionTotal,2)
           +","+DoubleToStr(OrderSwapTotal,2)
           +","+DoubleToStr(OrderProfitTotal,2);
      FileWrite(file_hand,text);
     }
   if(OpBuyLimit)
     {
      ENUM_ORDER_TYPE orderType=OP_BUYLIMIT;
      SymbolExportOrdersHistoryCalculator(symbolString,orderType,1);
      text="Buy Limit"+","+DoubleToStr(OrderLotsTotal,2)
           +","+DoubleToStr(OrderCommissionTotal,2)
           +","+DoubleToStr(OrderSwapTotal,2)
           +","+DoubleToStr(OrderProfitTotal,2);
      FileWrite(file_hand,text);
      SymbolExportOrdersHistoryCalculator(symbolString,orderType,0);
      text="Buy Limit"+","+DoubleToStr(OrderLotsTotal,2)
           +","+DoubleToStr(OrderCommissionTotal,2)
           +","+DoubleToStr(OrderSwapTotal,2)
           +","+DoubleToStr(OrderProfitTotal,2);
      FileWrite(file_hand,text);
      SymbolExportOrdersHistoryCalculator(symbolString,orderType,-1);
      text="Buy Limit"+","+DoubleToStr(OrderLotsTotal,2)
           +","+DoubleToStr(OrderCommissionTotal,2)
           +","+DoubleToStr(OrderSwapTotal,2)
           +","+DoubleToStr(OrderProfitTotal,2);
      FileWrite(file_hand,text);
     }
   if(OpSellLimit)
     {
      ENUM_ORDER_TYPE orderType=OP_SELLLIMIT;
      SymbolExportOrdersHistoryCalculator(symbolString,orderType,1);
      text="Sell Limit"+","+DoubleToStr(OrderLotsTotal,2)
           +","+DoubleToStr(OrderCommissionTotal,2)
           +","+DoubleToStr(OrderSwapTotal,2)
           +","+DoubleToStr(OrderProfitTotal,2);
      FileWrite(file_hand,text);
      SymbolExportOrdersHistoryCalculator(symbolString,orderType,0);
      text="Sell Limit"+","+DoubleToStr(OrderLotsTotal,2)
           +","+DoubleToStr(OrderCommissionTotal,2)
           +","+DoubleToStr(OrderSwapTotal,2)
           +","+DoubleToStr(OrderProfitTotal,2);
      FileWrite(file_hand,text);
      SymbolExportOrdersHistoryCalculator(symbolString,orderType,-1);
      text="Sell Limit"+","+DoubleToStr(OrderLotsTotal,2)
           +","+DoubleToStr(OrderCommissionTotal,2)
           +","+DoubleToStr(OrderSwapTotal,2)
           +","+DoubleToStr(OrderProfitTotal,2);
      FileWrite(file_hand,text);
     }
   if(OpBuyStop)
     {
      ENUM_ORDER_TYPE orderType=OP_BUYSTOP;
      SymbolExportOrdersHistoryCalculator(symbolString,orderType,1);
      text="Buy Stop"+","+DoubleToStr(OrderLotsTotal,2)
           +","+DoubleToStr(OrderSwapTotal,2)
           +","+DoubleToStr(OrderProfitTotal,2);
      FileWrite(file_hand,text);
      SymbolExportOrdersHistoryCalculator(symbolString,orderType,0);
      text="Buy Stop"+","+DoubleToStr(OrderLotsTotal,2)
           +","+DoubleToStr(OrderCommissionTotal,2)
           +","+DoubleToStr(OrderSwapTotal,2)
           +","+DoubleToStr(OrderProfitTotal,2);
      FileWrite(file_hand,text);
      SymbolExportOrdersHistoryCalculator(symbolString,orderType,-1);
      text="Buy Stop"+","+DoubleToStr(OrderLotsTotal,2)
           +","+DoubleToStr(OrderCommissionTotal,2)
           +","+DoubleToStr(OrderSwapTotal,2)
           +","+DoubleToStr(OrderProfitTotal,2);
      FileWrite(file_hand,text);
     }
   if(OpSellStop)
     {
      ENUM_ORDER_TYPE orderType=OP_SELLSTOP;
      SymbolExportOrdersHistoryCalculator(symbolString,orderType,1);
      text="Sell Stop"+","+DoubleToStr(OrderLotsTotal,2)
           +","+DoubleToStr(OrderCommissionTotal,2)
           +","+DoubleToStr(OrderSwapTotal,2)
           +","+DoubleToStr(OrderProfitTotal,2);
      FileWrite(file_hand,text);
      SymbolExportOrdersHistoryCalculator(symbolString,orderType,0);
      text="Sell Stop"+","+DoubleToStr(OrderLotsTotal,2)
           +","+DoubleToStr(OrderCommissionTotal,2)
           +","+DoubleToStr(OrderSwapTotal,2)
           +","+DoubleToStr(OrderProfitTotal,2);
      FileWrite(file_hand,text);
      SymbolExportOrdersHistoryCalculator(symbolString,orderType,-1);
      text="Sell Stop"+","+DoubleToStr(OrderLotsTotal,2)
           +","+DoubleToStr(OrderCommissionTotal,2)
           +","+DoubleToStr(OrderSwapTotal,2)
           +","+DoubleToStr(OrderProfitTotal,2);
      FileWrite(file_hand,text);
     }
  }
//+------------------------------------------------------------------+
double OrderLotsTotal=0.00;
double OrderCommissionTotal=0.00;
double OrderSwapTotal=0.00;
double OrderProfitTotal=0.00;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SymbolExportOrdersHistoryCalculator(string orderSymbol,ENUM_ORDER_TYPE orderType,int profitModel)
  {
   OrderLotsTotal=0.00;
   OrderProfitTotal=0.00;
   long ordersHistoryTotal=OrdersHistoryTotal();
   if(ordersHistoryTotal>0)
     {
      for(int OrderHistoryIndex=0;OrderHistoryIndex<=ordersHistoryTotal-1;OrderHistoryIndex++)
        {
         if(OrderSelect(OrderHistoryIndex,SELECT_BY_POS,MODE_HISTORY))
           {
            string historyOrderSymbol=OrderSymbol();
            int historyOrderType=OrderType();
            if(historyOrderSymbol==orderSymbol && historyOrderType==orderType)
              {
               datetime historyOrderOpenTime=OrderOpenTime();
               if(historyOrderOpenTime>=HistoryStartDateTime && historyOrderOpenTime<=HistoryEndDateTime)
                 {
                  double historyOrderLots=OrderLots();
                  double historyOrderStopLoss=OrderStopLoss();
                  double historyOrderTakeProfit=OrderTakeProfit();
                  double historyOrderCommission=OrderCommission();
                  double historyOrderSwap=OrderSwap();
                  double historyOrderProfit=OrderProfit();
                  if(profitModel==1)
                    {
                     if(historyOrderProfit<=0)
                       {
                        continue;
                       }
                    }
                  if(profitModel==0)
                    {
                     if(historyOrderProfit!=0)
                       {
                        continue;
                       }
                    }
                  if(profitModel==-1)
                    {
                     if(historyOrderProfit>=0)
                       {
                        continue;
                       }
                    }
                  OrderLotsTotal+=historyOrderLots;
                  OrderCommissionTotal+=historyOrderCommission;
                  OrderSwapTotal+=historyOrderSwap;
                  OrderProfitTotal+=historyOrderProfit;
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
