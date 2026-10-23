#property version "1.00"
#property indicator_chart_window
#property indicator_plots 0

enum ENUM_BMP_SIZE_MODE
  {
   BMP_NATIVE=0,
   BMP_CUSTOM=1,
   BMP_FILL=2,
   BMP_FIT=3
  };

input string FileName="b.bmp";
input ENUM_BMP_SIZE_MODE SizeMode=BMP_FILL;
input int Width=1920;
input int Height=1080;

struct BmpConfig
  {
   string file;
   string object;
   string resource;
  };

class CBackgroundBmp
  {
private:
   BmpConfig m_config;
   uint m_pixels[];
   int m_width;
   int m_height;
   int m_render_width;
   int m_render_height;

   uint Read(const uchar &data[],const int offset,const int count)
     {
      uint value=0;
      for(int i=0;i<count;i++)
         value|=((uint)data[offset+i])<<(8*i);
      return value;
     }

public:
   CBackgroundBmp(void)
     {
      m_config.file="";
      m_config.object="FilesBmpBackground";
      m_config.resource="FilesBmpBackgroundResource";
      m_width=0;
      m_height=0;
      m_render_width=0;
      m_render_height=0;
     }

   bool Create(const string file)
     {
      m_config.file=file;
      uchar data[];
      if(FileLoad(m_config.file,data)<54 || data[0]!='B' || data[1]!='M')
         return false;
      const int offset=(int)Read(data,10,4);
      const int width=(int)Read(data,18,4);
      const int signed_height=(int)Read(data,22,4);
      const int height=MathAbs(signed_height);
      const int bits=(int)Read(data,28,2);
      if(width<1 || height<1 || (bits!=24 && bits!=32) || Read(data,30,4)!=0)
         return false;
      const int stride=((width*bits+31)/32)*4;
      if(offset+stride*height>ArraySize(data))
         return false;
      if(ArrayResize(m_pixels,width*height)!=width*height)
         return false;
      m_width=width;
      m_height=height;
      const int bytes=bits/8;
      for(int y=0;y<height;y++)
        {
         const int source_y=signed_height>0 ? height-1-y : y;
         for(int x=0;x<width;x++)
           {
            const int p=offset+source_y*stride+x*bytes;
            m_pixels[y*width+x]=((uint)data[p+2]<<16)|((uint)data[p+1]<<8)|data[p];
           }
        }
      ObjectDelete(0,m_config.object);
      if(!ObjectCreate(0,m_config.object,OBJ_BITMAP_LABEL,0,0,0))
         return false;
      ObjectSetInteger(0,m_config.object,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,m_config.object,OBJPROP_XDISTANCE,0);
      ObjectSetInteger(0,m_config.object,OBJPROP_YDISTANCE,0);
      ObjectSetInteger(0,m_config.object,OBJPROP_BACK,true);
      ObjectSetInteger(0,m_config.object,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,m_config.object,OBJPROP_HIDDEN,true);
      if(!Resize(SizeMode,Width,Height))
         return false;
      ChartRedraw();
      return true;
     }

   bool Resize(const ENUM_BMP_SIZE_MODE mode,const int custom_width,const int custom_height)
     {
      long chart_width=0;
      long chart_height=0;
      int target_width=m_width;
      int target_height=m_height;
      if(mode==BMP_CUSTOM)
        {
         target_width=custom_width>0 ? custom_width : m_width;
         target_height=custom_height>0 ? custom_height : m_height;
        }
      else if(mode==BMP_FILL || mode==BMP_FIT)
        {
         if(!ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0,chart_width) ||
            !ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0,chart_height) ||
            chart_width<1 || chart_height<1)
            return false;
         if(mode==BMP_FILL)
           {
            target_width=(int)chart_width;
            target_height=(int)chart_height;
           }
         else
           {
            const double scale=MathMin((double)chart_width/m_width,(double)chart_height/m_height);
            target_width=(int)(m_width*scale);
            target_height=(int)(m_height*scale);
           }
        }
      if(target_width<1 || target_height<1)
         return false;
      if(target_width!=m_render_width || target_height!=m_render_height)
        {
         uint resized[];
         if(ArrayResize(resized,target_width*target_height)!=target_width*target_height)
            return false;
         for(int y=0;y<target_height;y++)
           {
            const int source_y=(int)((long)y*m_height/target_height);
            for(int x=0;x<target_width;x++)
              {
               const int source_x=(int)((long)x*m_width/target_width);
               resized[y*target_width+x]=m_pixels[source_y*m_width+source_x];
              }
           }
         ResourceFree(m_config.resource);
         if(!ResourceCreate(m_config.resource,resized,target_width,target_height,0,0,target_width,COLOR_FORMAT_XRGB_NOALPHA))
            return false;
         ObjectSetString(0,m_config.object,OBJPROP_BMPFILE,"::"+m_config.resource);
         m_render_width=target_width;
         m_render_height=target_height;
        }
      ObjectSetInteger(0,m_config.object,OBJPROP_XSIZE,target_width);
      ObjectSetInteger(0,m_config.object,OBJPROP_YSIZE,target_height);
      return true;
     }

   void Remove(void)
     {
      ObjectDelete(0,m_config.object);
      ResourceFree(m_config.resource);
     }
  };

CBackgroundBmp Background;

int OnInit(void)
  {
   Background.Create(FileName);
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   Background.Remove();
  }

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],const double &open[],const double &high[],const double &low[],const double &close[],const long &tick_volume[],const long &volume[],const int &spread[])
  {
   return rates_total;
  }

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_CHART_CHANGE)
      Background.Resize(SizeMode,Width,Height);
  }