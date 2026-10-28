//+------------------------------------------------------------------+
//|                                                     CGCanvas.mqh |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Project Stocks"
#include "CGraphBase.mqh"
//+------------------------------------------------------------------+
//| Class CGCanvas can be used in tester                             |
//| created with EDIT-OBJECT                                         |
//+------------------------------------------------------------------+
class CGCanvas
  {
protected:
   string         m_name;                                                  // object name
   long           m_id;                                                    // chart ID
   int            m_subwin;                                                // subwindow index
   bool           m_created;                                               // true if the object is created
   //
   int            m_xdist;                                                 // x-distance from the corner
   int            m_ydist;                                                 // y-distance from the corner
   int            m_xsize;                                                 // edit width
   int            m_ysize;                                                 // edit hight
   color          m_color_bg;                                              // backgroung color
   color          m_color_bd;                                              // border color
   ENUM_BASE_CORNER m_corner;                                              // corner point
   string         m_fontname;                                              // font name
   int            m_fontsize;                                              // font size
   bool           m_selected;                                              // to select the object
   bool           m_selectable;                                            // to be selectable
   bool           m_back;                                                  // fore/background
   bool           m_readonly;                                              // read only property
   long           m_zorder;                                                // click priority
   bool           m_hidden;                                                // not to show in the object list
   // pointer to the used class
   CGraphBase     *m_graph_base;                                           // pointer to CGraphBase
public:
   CGCanvas(string aName="Canvas_",long aID=0,int aSubWin=0);
   ~CGCanvas(void);
   // settings and movings
   void           SetXDist(int aDist=10);                                  // x-distance from the corner
   void           SetYDist(int aDist=15);                                  // y-distance from the corner
   void           SetXSize(int aWidth=100);                                // Width
   void           SetYSize(int aHeight=100);                               // Hight
   void           SetColorBG(color aColor=clrDarkSlateGray);               // background canvas color
   void           SetColorBorder(color aColor=clrSnow);                    // border color
   void           SetCorner(ENUM_BASE_CORNER aCorner=CORNER_LEFT_UPPER);   // anchor point
   void           SetFontName(string aFont="Calibri");                     // font name
   void           SetFontSize(int aSize=8);                                // font size
   void           SetSelected(bool aValue=false);                          // possibility to select
   void           SetSelectable(bool aValue=false);                        // to be selectable
   void           SetReadOnly(bool aValue=true);                           // read only
   void           SetBack(bool aBack=false);                               // fore/background
   void           SetZOrder(long aOrder=0);                                // click priority
   void           SetHidden(bool aHidden=true);                            // not to show in the object list
   //
   bool           MoveXY(int aPosX=0,int aPosY=0);                         // moving the object 
   bool           MoveX(int aPosX=0);                                      // moving the object 
   bool           MoveY(int aPosY=0);                                      // moving the object 
   // special methods
   CGraphBase     *PtrGraphBase(void) {return(m_graph_base);}              // getting pointer to CGraphBase from outside the class
   void           Init(void) {}                                            // not used for a while
   void           Deinit(void);                                            // the class deinit function
   void           ReDraw(void) {m_graph_base.Redraw();}                    // redraw graph
   // getting
   string         Name(void)       {return(m_graph_base.Name());}          // name of the object
   long           Chart_ID(void)   {return(m_graph_base.Chart_ID());}      // chart ID
   int            SubWindow(void)  {return(m_graph_base.SubWindow());}     // subwindows index
   bool           Created(void)        {return(m_created);}                // checking creating of the object
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CGCanvas::CGCanvas(string aName="Canvas_",long aID=0,int aSubWin=0)
  {
   m_name=aName;
   m_id=aID;
   m_subwin=aSubWin;
   m_created=false;
   m_graph_base=new CGraphBase(m_name,m_id,m_subwin);
   if(m_graph_base.CreateEdit())
      m_created=true;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CGCanvas::~CGCanvas(void)
  {   
   Deinit();
  }
//+------------------------------------------------------------------+
//| Deinit the CGCanvas                                              |
//+------------------------------------------------------------------+
void CGCanvas::Deinit(void)
  {   
   m_graph_base.Delete();
   delete(m_graph_base);
  }
//+------------------------------------------------------------------+
//|   Setting property OBJPROP_XDISTANCE                             |
//+------------------------------------------------------------------+
void CGCanvas::SetXDist(int aDist=10)
  {
   if(m_created)
     {
      m_xdist=aDist;
      m_graph_base.SetXDistance(m_xdist);
     }
  }
//+------------------------------------------------------------------+
//|   Setting property OBJPROP_YDISTANCE                             |
//+------------------------------------------------------------------+
void CGCanvas::SetYDist(int aDist=15)
  {
   if(m_created)
     {
      m_ydist=aDist;
      m_graph_base.SetYDistance(m_ydist);
     }
  }
//+------------------------------------------------------------------+
//|   Setting property OBJPROP_XSIZE                                 |
//+------------------------------------------------------------------+
void CGCanvas::SetXSize(int aWidth=100)
  {
   if(m_created)
     {
      m_xsize=aWidth;
      m_graph_base.SetXSize(m_xsize);
     }
  }
//+------------------------------------------------------------------+
//|   Setting property OBJPROP_YSIZE                                 |
//+------------------------------------------------------------------+
void CGCanvas::SetYSize(int aHeight=100)
  {
   if(m_created)
     {
      m_ysize=aHeight;
      m_graph_base.SetYSize(m_ysize);
     }
  }
//+------------------------------------------------------------------+
//|   Setting property OBJPROP_BGCOLOR                               |
//+------------------------------------------------------------------+
void CGCanvas::SetColorBG(color aColor=5197615)
  {
   if(m_created)
     {
      m_color_bg=aColor;
      m_graph_base.SetBgColor(m_color_bg);
     }
  }
//+------------------------------------------------------------------+
//|   Setting property OBJPROP_BORDER_COLOR                          |
//+------------------------------------------------------------------+
void CGCanvas::SetColorBorder(color aColor=16448255)
  {
   if(m_created)
     {
      m_color_bd=aColor;
      m_graph_base.SetBorderColor(m_color_bd);
     }
  }
//+------------------------------------------------------------------+
//|   Setting property OBJPROP_CORNER                                |
//+------------------------------------------------------------------+
void CGCanvas::SetCorner(ENUM_BASE_CORNER aCorner=0)
  {
   if(m_created)
     {
      m_corner=aCorner;
      m_graph_base.SetCorner(m_corner);
     }
  }
//+------------------------------------------------------------------+
//|   Setting property OBJPROP_FONT                                  |
//+------------------------------------------------------------------+
void CGCanvas::SetFontName(string aFont="Calibri")
  {
   if(m_created)
     {
      m_fontname=aFont;
      m_graph_base.SetFont(m_fontname);
     }
  }
//+------------------------------------------------------------------+
//|   Setting property OBJPROP_FONTSIZE                              |
//+------------------------------------------------------------------+
void CGCanvas::SetFontSize(int aSize=8)
  {
   if(m_created)
     {
      m_fontsize=aSize;
      m_graph_base.SetFontSize(m_fontsize);
     }
  }
//+------------------------------------------------------------------+
//|   Setting property OBJPROP_SELECTED                              |
//+------------------------------------------------------------------+
void CGCanvas::SetSelected(bool aValue=false)
  {
   if(m_created)
     {
      m_selected=aValue;
      m_graph_base.SetSelected(m_selected);
     }
  }
//+------------------------------------------------------------------+
//|   Setting property OBJPROP_SELECTABLE                            |
//+------------------------------------------------------------------+
void CGCanvas::SetSelectable(bool aValue=false)
  {
   if(m_created)
     {
      m_selectable=aValue;
      m_graph_base.SetSelectable(m_selectable);
     }
  }
//+------------------------------------------------------------------+
//|   Setting property OBJPROP_BACK                                  |
//+------------------------------------------------------------------+
void CGCanvas::SetBack(bool aBack=false)
  {
   if(m_created)
     {
      m_back=aBack;
      m_graph_base.SetBack(m_back);
     }
  }
//+------------------------------------------------------------------+
//|   Setting property OBJPROP_READONLY                              |
//+------------------------------------------------------------------+
void CGCanvas::SetReadOnly(bool aValue=true)
  {
   if(m_created)
     {
      m_readonly=aValue;
      m_graph_base.SetReadOnly(m_readonly);
     }
  }
//+------------------------------------------------------------------+
//| Setting  OBJPROP_ZORDER                                          |
//+------------------------------------------------------------------+
void CGCanvas::SetZOrder(long aOrder=0)
  {
   if(m_created)
     {
      m_zorder=aOrder;
      m_graph_base.SetZOrder(m_zorder);
     }
  }
//+------------------------------------------------------------------+
//| Setting  OBJPROP_HIDDEN                                          |
//+------------------------------------------------------------------+
void CGCanvas::SetHidden(bool aHidden=true)
  {   
   if(m_created)
     {
      m_hidden=aHidden;
      m_graph_base.SetHidden(m_hidden);
     }
  }
//+------------------------------------------------------------------+
//| Moving the Object to the new X Y position                        |
//+------------------------------------------------------------------+
bool CGCanvas::MoveXY(int aPosX=0,int aPosY=0)
  {
   ResetLastError();
   if(!m_graph_base.SetXDistance(aPosX))
     {
      Print(__FUNCTION__,": Cannot move to X! Error code:",GetLastError());
      return(false);
     }
   if(!m_graph_base.SetYDistance(aPosY))
     {
      Print(__FUNCTION__,": Cannot move to Y! Error code:",GetLastError());
      return(false);
     }
   m_xdist=aPosX;
   m_ydist=aPosY;
   return(true);
  }
//+------------------------------------------------------------------+
//| Moving the Object to the new X position                          |
//+------------------------------------------------------------------+
bool CGCanvas::MoveX(int aPosX=0)
  {
   ResetLastError();
   if(!m_graph_base.SetXDistance(aPosX))
     {
      Print(__FUNCTION__,": Cannot move to X! Error code:",GetLastError());
      return(false);
     }
   m_xdist=aPosX;
   return(true);
  }
//+------------------------------------------------------------------+
//| Moving the Object to the new Y position                          |
//+------------------------------------------------------------------+
bool CGCanvas::MoveY(int aPosY=0)
  {
   ResetLastError();
   if(!m_graph_base.SetYDistance(aPosY))
     {
      Print(__FUNCTION__,": Cannot move to Y! Error code:",GetLastError());
      return(false);
     }
   m_ydist=aPosY;
   return(true);
  }
//+------------------------------------------------------------------+



