//+------------------------------------------------------------------+
//|                                               cFigureBuilder.mqh |
//|                                          Copyright 2017, Progid. |
//|                            https://www.mql5.com/en/users/progid/ |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| define
//+------------------------------------------------------------------+
#ifndef    _Error_
   #define _Error_(info)  {Print("Error: ",info," line: "+(string)__LINE__+" file: "+__FILE__+" function: "+__FUNCTION__+"; GetLastError: "+(string)GetLastError());}
#endif

#ifndef    _ErrorDefault_
   #define _ErrorDefault_(info,r) {_Error_(info) r;}
#endif


//+------------------------------------------------------------------+
//| Dot structure
//+------------------------------------------------------------------+
struct sDot
{
   string   _ObjName;
   int      _Number;
   datetime _Time;
   double   _Price;
   
   void operator = (sDot & source)
   {
      _ObjName = source._ObjName;
      _Number = source._Number;
      _Time = source._Time;
      _Price = source._Price; 
   }
};

//+------------------------------------------------------------------+
//| FigureBuilder class
//+------------------------------------------------------------------+
class cFigureBuilder
{
   private: ulong _LastFigureID;
   private: int   _DotsMax;
   
   private: int  _LastDotsCount;
   private: sDot _ChronologyBuf[]; int _ChronologyBufRS;
   private: int  _ChronologySize;
   
   
//---
   public: bool Init(int dots_max);
   public: void OnEvent(const int id,
                        const long& lparam,
                        const double& dparam,
                        const string& sparam);
                        
//---   
   private: bool AddDot(int x,int y);
   private: bool FigureBuild();
   
   private: bool AddToChronology(sDot & dot);
   private: bool AddToChronology(string obj_name);
   private: bool DeleteLastDot();
   
   private: double GetPixelSize();
};




//+------------------------------------------------------------------+
//| To initialize the class
//+------------------------------------------------------------------+
bool cFigureBuilder::Init(int dots_max)
{
   _LastFigureID = GetTickCount();
   _DotsMax      = fmax(dots_max, 2);
   
   _LastDotsCount   = 0;
   _ChronologySize  = 0;
   _ChronologyBufRS = 1;
   
   if (ArrayResize(_ChronologyBuf, _ChronologySize, _ChronologyBufRS) != 0) _ErrorDefault_("", return false)
   
   return true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cFigureBuilder::OnEvent(const int id,
                             const long& lparam,
                             const double& dparam,
                             const string& sparam)
{
   if (id == CHARTEVENT_CLICK)
   { 
      int CtrlKeyState = TerminalInfoInteger(TERMINAL_KEYSTATE_CONTROL);
       
      // + ctrl 
      if (CtrlKeyState == -128 || CtrlKeyState == -127)
      {
         int X = (int)lparam;
         int Y = (int)dparam;
         
         AddDot(X, Y);            
      }
   }
   else
   if (id == CHARTEVENT_KEYDOWN)
   {     
//---Backspace
      if (lparam == 8)
      {
         int CtrlKeyState = TerminalInfoInteger(TERMINAL_KEYSTATE_CONTROL);

         // + ctrl
         if (CtrlKeyState == -128 || CtrlKeyState == -127)
         {
            if (!DeleteLastDot()) _Error_("")
            
            ChartRedraw();
         }
      }
      else
//---Delete
      if (lparam == 46)
      {
         int CtrlKeyState = TerminalInfoInteger(TERMINAL_KEYSTATE_CONTROL);
         
         // + ctrl
         if (CtrlKeyState == -128 || CtrlKeyState == -127)
         {
            ObjectsDeleteAll(0, _Prefix, 0);
            
            ChartRedraw();
         }
      }      
   }
}                             
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cFigureBuilder::AddDot(int x,int y)
{
   int      AxtSubW = 0;
   datetime ActTime = 0;
   double   ActPrice = 0;
  
   if (!ChartXYToTimePrice(0, x, y, AxtSubW, ActTime, ActPrice)) _ErrorDefault_("x:"+(string)x+" y:"+(string)y, return false)
   
   if (AxtSubW != 0) return false;
  
  
//---time calibrate   
   ActTime = datetime((long)ActTime + PeriodSeconds(_Period)/2);
   
//---open time determine  
   datetime TimeBuf[];
   
   if (CopyTime(_Symbol, _Period, ActTime, 1, TimeBuf) != 1) _ErrorDefault_("CopyTime", return false)
   
   ActTime = TimeBuf[0];
   
//---check for similar bar
   for (int c=0; c<_LastDotsCount; ++c)
   {
      if (_ChronologySize-c-1 < 0) break;
      
      if (_ChronologyBuf[_ChronologySize-c-1]._Time == ActTime)
      {
         Print("Warning: this bar has a dot!");
         return false;
      }
   }
   
//---add new dot   
   string ObjName = _Prefix + "fig[" + string(_LastFigureID+1) + "]:dot[" + (string)_LastDotsCount + "]";
   
   sDot NewDot;
   
   NewDot._ObjName = ObjName;
   NewDot._Number  = _LastDotsCount;
   NewDot._Time    = ActTime;
   NewDot._Price   = ActPrice;
   
   if (!AddToChronology(NewDot)) _ErrorDefault_("", return false)
   
   ObjectDelete(0, ObjName);
   
   double PixelSize = GetPixelSize();
   
   if (!ObjectCreate(0, ObjName, OBJ_ARROW, 0, ActTime, ActPrice+4*PixelSize + DotEmptySize_*3*PixelSize)) _ErrorDefault_("", return false)
   
   if (!ObjectSetInteger(0, ObjName, OBJPROP_ARROWCODE, DotEmptyArowCode_)) _Error_("")
   if (!ObjectSetInteger(0, ObjName, OBJPROP_WIDTH, DotEmptySize_)) _Error_("")
    
   ChartRedraw();
   
   ++_LastDotsCount;
   ++_LastFigureID;
   
   
//---All dots are ready
   if (_LastDotsCount >= (int)_DotsMax)
   { 
      if (!FigureBuild()) _ErrorDefault_("", return false)
   }

//---
   return true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cFigureBuilder::FigureBuild()
{
   double PixelSize = GetPixelSize();
   
   string LinesNames[]; ArrayResize(LinesNames, _LastDotsCount-1);
   
   for (int c=0; c<_LastDotsCount-1; ++c)
   {
      sDot Dot1 = _ChronologyBuf[_ChronologySize-_LastDotsCount+c];
      sDot Dot2 = _ChronologyBuf[_ChronologySize-_LastDotsCount+c+1];
      
//---line   
      string ObjName = _Prefix + "fig[" + string(_LastFigureID) + "]:line[" + string(c-1) + "]";
      
      LinesNames[c] = ObjName;
      
      if (!ObjectCreate(0, ObjName, OBJ_TREND, 0, Dot1._Time, Dot1._Price, Dot2._Time, Dot2._Price))
      {
         _ErrorDefault_("", _LastDotsCount = 0; return false)
      }
       
      if (!ObjectSetInteger(0, ObjName, OBJPROP_RAY_LEFT, c == 0 ? LineLeftRay_ : false)) _Error_("")
      if (!ObjectSetInteger(0, ObjName, OBJPROP_RAY_RIGHT, c == _LastDotsCount-2 ? LineRightRay_ : false)) _Error_("")
      if (!ObjectSetInteger(0, ObjName, OBJPROP_COLOR, LineColor_)) _Error_("")
      if (!ObjectSetInteger(0, ObjName, OBJPROP_STYLE, LineStyle_)) _Error_("")
      if (!ObjectSetInteger(0, ObjName, OBJPROP_WIDTH, LineWidth_)) _Error_("")
       
//---fill dots
      if (!ObjectSetInteger(0, Dot1._ObjName, OBJPROP_ARROWCODE, DotFillArowCode_)) _Error_("")
      if (!ObjectSetInteger(0, Dot1._ObjName, OBJPROP_WIDTH, DotFillSize_)) _Error_("")      
      if (!ObjectSetDouble(0, Dot1._ObjName, OBJPROP_PRICE, Dot1._Price+4*PixelSize+DotFillSize_*3*PixelSize)) _Error_("")
      
      if (!ObjectSetInteger(0, Dot2._ObjName, OBJPROP_ARROWCODE, DotFillArowCode_)) _Error_("")
      if (!ObjectSetInteger(0, Dot2._ObjName, OBJPROP_WIDTH, DotFillSize_)) _Error_("") 
      if (!ObjectSetDouble(0, Dot2._ObjName, OBJPROP_PRICE, Dot2._Price+4*PixelSize+DotFillSize_*3*PixelSize)) _Error_("")
      
//---      
      ChartRedraw();
   }
   
   
//---Chronology
   for (int c=0; c<_LastDotsCount-1; ++c)
   {
      if (!AddToChronology(LinesNames[c])) _Error_("")
   }
   
   
//---   
   _LastDotsCount = 0;
   
   return true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cFigureBuilder::AddToChronology(sDot & dot)
{ 
   if (_ChronologyBufRS <= _ChronologySize+1) _ChronologyBufRS = (int)ceil((_ChronologySize + 1)*1.3);
   
   if (ArrayResize(_ChronologyBuf, _ChronologySize+1, _ChronologyBufRS) != _ChronologySize+1) _ErrorDefault_("", return false)
   
   _ChronologyBuf[_ChronologySize] = dot;
   
   ++_ChronologySize;
   
   return true; 
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cFigureBuilder::AddToChronology(string obj_name)
{
   if (_ChronologyBufRS <= _ChronologySize+1) _ChronologyBufRS = (int)ceil((_ChronologySize + 1)*1.3);
      
   if (ArrayResize(_ChronologyBuf, _ChronologySize+1, _ChronologyBufRS) != _ChronologySize+1) _ErrorDefault_("", return false)
   
   _ChronologyBuf[_ChronologySize]._ObjName = obj_name;
   _ChronologyBuf[_ChronologySize]._Number  = 0;
   _ChronologyBuf[_ChronologySize]._Time    = 0;
   _ChronologyBuf[_ChronologySize]._Price   = 0;

   ++_ChronologySize;
   
   return true; 
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cFigureBuilder::DeleteLastDot()
{
   double PixelSize = GetPixelSize();
   
   for (int i=_ChronologySize-1; i>=0; --i)
   {
      bool IsLine    = false;
      int  DotNumber = -1;
      
      if (_ChronologySize > 0)
      {
         IsLine    = _ChronologyBuf[_ChronologySize-1]._Time == 0;
         DotNumber = _ChronologyBuf[_ChronologySize-1]._Number;
         
         string ObjName = _ChronologyBuf[_ChronologySize-1]._ObjName;
         
         if (ObjectDelete(0, ObjName))
         {
            ChartRedraw();
            
            --_ChronologySize;
   
            if (ArrayResize(_ChronologyBuf, _ChronologySize, _ChronologyBufRS) != _ChronologySize) _ErrorDefault_("ArrayResize", return false)
         }
         else _ErrorDefault_("!ObjectDelete("+ObjName+")", return false)
      }
      
      if (!IsLine)
      {
         if (_LastDotsCount > 0) --_LastDotsCount;
         else
         if (_ChronologySize > 0)
         { 
            _LastDotsCount = _DotsMax - 1;
            
            for (int i1=_ChronologySize-1,c=0; i1>=0 && c<_LastDotsCount; --i1, ++c)
            {
               if (_ChronologyBuf[_ChronologySize-1]._Time == 0)
               {
                  _ErrorDefault_("", return false)
                  break;
               }
               
               if (!ObjectSetInteger(0, _ChronologyBuf[i1]._ObjName, OBJPROP_ARROWCODE, DotEmptyArowCode_)) _Error_("")
               if (!ObjectSetInteger(0, _ChronologyBuf[i1]._ObjName, OBJPROP_WIDTH, DotEmptySize_)) _Error_("")      
               if (!ObjectSetDouble(0, _ChronologyBuf[i1]._ObjName, OBJPROP_PRICE, _ChronologyBuf[i1]._Price+4*PixelSize+DotEmptySize_*3*PixelSize)) _Error_("")
            }
         }

         break;
      }
   }
   
   return true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double cFigureBuilder::GetPixelSize()
{
   int    ActChartHeightPx = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   double ActChartHeightPr = ChartGetDouble(0, CHART_PRICE_MAX) - ChartGetDouble(0, CHART_PRICE_MIN);
   
   return ActChartHeightPr / fmax(ActChartHeightPx, 1);
}