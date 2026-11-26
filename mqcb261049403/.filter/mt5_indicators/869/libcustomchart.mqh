//+-----------------------------------------------------------------------------+
//|                                                          LibCustomChart.mqh |
//|                                                       Copyright 2012, Lizar |
//|                                         https://www.mql5.com/ru/users/lizar |
//|                                                        Revision 12 Apr 2012 |
//+-----------------------------------------------------------------------------+
#property copyright "Copyright 2012, Lizar"
#property link      "https://www.mql5.com/en/users/lizar"
//+-----------------------------------------------------------------------------+
//| Description of the functions for the indicator automatic attachment to      |
//| iCustomChart and establishing access to its data.                           |
//+-----------------------------------------------------------------------------+
#import "LibCustomChart.ex5"
   //--- Basic Functions:
   bool CustomChartInit(void);
   bool CustomChartRefresh(void);
   //--- the function of the indicator buffer synchronization with iCustomChart:
   bool CustomChartSync(double &buffer[]);
   //--- the function of the access to iCustomChart time series data by the element position:
   MqlRates CopyRates(int position);
   datetime CopyTime(int position);
   double   CopyOpen(int position);
   double   CopyClose(int position);
   double   CopyHigh(int position);
   double   CopyLow(int position);
   double   CopyZeroBuffer(int position);
   double   CopyAppliedPrice(ENUM_APPLIED_PRICE _applied_price, int position);
   long     CopyRealVolume(int position);
   long     CopyTickVolume(int position);
   long     CopySpread(int position);
   int      CopyColor(int position);
   //--- the function of the access to iCustomChart time series data by the initial position and the number of elements:
   int      CopyTime(int start_pos,int count,datetime &array[]);
   int      CopyOpen(int start_pos,int count,double &array[]);
   int      CopyClose(int start_pos,int count,double &array[]);
   int      CopyHigh(int start_pos,int count,double &array[]);
   int      CopyLow(int start_pos,int count,double &array[]);
   int      CopyRealVolume(int start_pos,int count,long &array[]);
   int      CopyTickVolume(int start_pos,int count,long &array[]);
   int      CopySpread(int start_pos,int count,int &array[]);
   int      CopyZeroBuffer(int start_pos,int count,double &array[]);
   int      CopyRates(int start_pos, int count, MqlRates &array[]);
   int      CopyAppliedPrice(ENUM_APPLIED_PRICE _applied_price, int start_pos, int count, double &array[]);
   int      CopyColor(int start_pos,int count,int &array[]);
   //--- the function of the access to iCustomChart properties:   
   int      CustomChartBars(void);
   int      CustomChartBegin(void);
   int      CustomChartNewBar(void);
   bool     CustomChartIsAttach(void);
   int      CustomChartHandle(void);
   string   CustomChartHstFile(void);
   string   CustomChartFile(void);
   string   CustomChartName(void);
#import
//+------------------------------------------------------------------+
  
  