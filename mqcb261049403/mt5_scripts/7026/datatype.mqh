/*
  Пользовательские типы данных
*/
//---------------------------------------------------------------------
// Структура для хранения цвета в виде ARGB составляющих
//---------------------------------------------------------------------
struct ARGB
{
  uchar blue;
  uchar green;
  uchar red;
  uchar alpha;
        ARGB(void):alpha(0),red(0),green(0),blue(0){};
        ARGB(uchar a,uchar r,uchar g,uchar b):alpha(a),red(r),green(g),blue(b){};
        ARGB(uint num)
        {
          struct N{uint n;N(uint n_):n(n_){};}n(num);
          ARGB c=(ARGB)n;
          alpha=c.alpha;
          red=c.red;
          green=c.green;
          blue=c.blue;
        }
        ARGB(uint top_,uint low_)
        {
          ARGB top(top_),low(low_);
          if(top.alpha==0)
          {
            alpha=low.alpha;
            red=low.red;
            green=low.green;
            blue=low.blue;
          }
          else
          {
            alpha=top.alpha;
            red=top.red;
            green=top.green;
            blue=top.blue;
          }
        }
  uint GetNumber(void)
  {
    ARGB c(alpha,red,green,blue);
    struct N{uint n;}n;
    n=(N)c;
    return(n.n);
  }
  color GetColor(void)
  {
    ARGB n(alpha,red,green,blue);
    struct C{color c;}c;
    c=(C)n;
    return(c.c);
  }
  void SetColor(uint num)
  {
    ARGB c(num);
    alpha=c.alpha;
    red=c.red;
    green=c.green;
    blue=c.blue;
  }
};
//---------------------------------------------------------------------
// Структура для хранения изображения в виде растра
//---------------------------------------------------------------------
struct Image
{
  int  x0;   //начало координат по x
  int  y0;   //начало координат по y
  int  x1;   //размер по x
  int  y1;   //размер по y
  int  x0_off;
  int  y0_off;
  int  x1_off;
  int  y1_off;
  uint data[];
       Image(void):x0(0),y0(0),x1(0),y1(0),x0_off(0),y0_off(0),x1_off(0),y1_off(0){};
       Image(int x0_,int y0_,int x1_,int y1_,uint fill):
       x0(x0_),y0(y0_),x1(x1_),y1(y1_),x0_off(x0_),y0_off(y0_),x1_off(x1_),y1_off(y1_)
       {
         ArrayResize(data,x1*y1);
         ArrayInitialize(data,fill);
       }
  void Zero(void){x0=0;y0=0;x1=0;y1=0;ArrayFree(data);}
  void Refresh(void){x0_off=x0;y0_off=y0;x1_off=x1;y1_off=y1;}
  void Size(int x,int y)
  {
    if(x==0 || y==0) {Zero();return;}
    x1=x;y1=y;
    ArrayResize(data,x1*y1);
    ArrayInitialize(data,0);
  }
  void Invert(void)
  {
    uint temp[];
    ArrayResize(temp,x1*y1);
    ArrayCopy(temp,data);
    for(int y=0;y<y1;y++)
    {
      for(int x=0;x<x1;x++) {data[x1*y+x]=temp[x1*(y1-y-1)+x];}
    }
  }
  void Clean(void)
  {
    ArrayInitialize(data,0);
  }
};
//---------------------------------------------------------------------
// Перечислимый тип: тип градиента
//---------------------------------------------------------------------
enum GRADIENT_TYPE
{
  LINE_X,   //горизонтальная градация
  LINE_Y    //вертикальная градация
};
