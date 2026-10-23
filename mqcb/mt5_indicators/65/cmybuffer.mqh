//+------------------------------------------------------------------+
//|                                                    CMyBuffer.mqh |
//|                             Copyright 2010, Loong@forum.mql4.com |
//|                                             Loong@forum.mql4.com |
//+------------------------------------------------------------------+
#property copyright "2010, Loong@forum.mql4.com"
#property link      "Loong@forum.mql4.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2005
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
class CMyBuffer
  {
public:
   color             mColor;
   int               mParam;
   int               mParam1;
   int               mParam2;
   int               mhandle;
   double            mbuffer[];
   //--- Constructor
                     CMyBuffer(){}// {Print("CMyBuffer::Constructor()");}//called when add indicator to chart
   //--- Destructor
                    ~CMyBuffer(){}// {Print("CMyBuffer::Destructor()");}//called when del indicator from chart
   void Init(){}//{Print("CMyBuffer::Init()");}//called after Constructor
   void Deinit()
     {
      ArrayFree(mbuffer);
      //Print("CMyBuffer::Deinit()");
     }//called before Destructor
   bool  mArraySetAsSeries(bool set)
     {return ArraySetAsSeries(mbuffer,set);}
   bool  mSetIndexBuffer(int index,ENUM_INDEXBUFFER_TYPE data_type=INDICATOR_DATA)
     {return SetIndexBuffer(index,mbuffer,data_type);}
   bool  mPlotIndexSetInteger(int plot_index,ENUM_PLOT_PROPERTY_INTEGER prop_id=PLOT_DRAW_TYPE,int prop_value=DRAW_LINE)
     {return PlotIndexSetInteger(plot_index,prop_id,prop_value);}
   bool  mPlotIndexSetDouble(int plot_index,ENUM_PLOT_PROPERTY_DOUBLE prop_id=PLOT_EMPTY_VALUE,double prop_value=0.0)
     {return PlotIndexSetDouble(plot_index,prop_id,prop_value);}
   bool  mPlotIndexSetString(int plot_index,ENUM_PLOT_PROPERTY_STRING prop_id=PLOT_LABEL,string prop_value="")
     {return PlotIndexSetString(plot_index,prop_id,prop_value);}
   int  mCopyBuffer(int prev_calculated, int total)
     {
//      return CopyBuffer(mhandle,0,0,total,mbuffer);
      return CopyBuffer(mhandle,0,0,total-prev_calculated+1,mbuffer);
     }
  };
//+------------------------------------------------------------------+
