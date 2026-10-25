/*

*/
#include "Common.mqh"
//---------------------------------------------------------------------
// Класс для динамического создания и управления ресурсом на основе массива пикселей для объекта "Графическая метка"
//---------------------------------------------------------------------
class CCanvas
{
  public:
          CCanvas(void);
         ~CCanvas(void);
    bool  Init(void);
    bool  IsInit(void) {return(init);}
    void  Deinit(void);
    void  Force(void);
    void  Update(void);
    void  ReserveLayer(int& num);
    bool  GotoLayer(int num);
    int   GetLayer(void)           {return(layer);}                           //получение номера активного слоя
    void  SetSize(int x,int y)     {layers[layer].Size(x,y);}                 //изменение размеров слоя
    void  GetSize(int& x,int& y)   {x=layers[layer].x1;y=layers[layer].y1;}   //получение размеров слоя
    void  SetOffset(int x,int y)   {layers[layer].x0=x;layers[layer].y0=y;}   //изменение начала координат слоя
    void  GetOffset(int& x,int& y) {x=layers[layer].x0;y=layers[layer].y0;}   //получение начала координат слоя
    void  Clean(void)              {layers[layer].Clean();}                   //очистка слоя
    void  Rendering(bool flag=true);
    void  Pixel(int x,int y,uint clr);
    void  LineH(int x1,int y1,int x2,uint clr);
    void  LineV(int x1,int y1,int y2,uint clr);
    void  Rectangle(int x1,int y1,int x2,int y2,uint clr);
    void  Rectangle(int x1,int y1,int x2,int y2,uint clr1,uint clr2);
    void  Gradient(int x1,int y1,int x2,int y2,GRADIENT_TYPE type,uint clr1,uint clr2);
    void  Text(string text,int x,int y,uint clr);

  public:
    int  X;   //ширина графика
    int  Y;   //высота графика

  private:
    bool    init;
    int     layer;
    string  name;
    string  resurs;
    uint    data[];
    Image   layers[];

  private:
    void    Rendering(const Image& image,char flag);
    void    Gradient(uint& array[],uint clr1,uint clr2);
    uint    Overlay(const uint& top,const uint& low);
};
//---------------------------------------------------------------------
// Конструктор по умолчанию
//---------------------------------------------------------------------
void CCanvas::CCanvas(void)
{
  if(!Init()) {Deinit();}
}
//---------------------------------------------------------------------
// Деструктор
//---------------------------------------------------------------------
void CCanvas::~CCanvas(void)
{
  Deinit();
}
//---------------------------------------------------------------------
// Инициализация
//---------------------------------------------------------------------
bool CCanvas::Init(void)
{
  Deinit();
  X=ChartXSize();
  Y=ChartYSize();
  name="canvas";
  resurs="::"+"img_"+(string)GetTickCount()+"_"+(string)MathRand();
  ArrayResize(data,X*Y);
  ArrayInitialize(data,0);
  ArrayResize(layers,1);
  layers[0].Size(X,Y);
  if(!ResourceCreate(resurs,data,X,Y,0,0,0,COLOR_FORMAT_ARGB_NORMALIZE)) {return(false);}
  if(!ObjectCreate(0,name,OBJ_BITMAP_LABEL,0,0,0)) {return(false);}
  if(!ObjectSetInteger(0,name,OBJPROP_COLOR,clrNONE)) {return(false);}
  if(!ObjectSetString(0,name,OBJPROP_BMPFILE,resurs)) {return(false);}
  init=true;
  return(true);
}
//---------------------------------------------------------------------
// Деинициализация
//---------------------------------------------------------------------
void CCanvas::Deinit(void)
{
  init=false;
  ArrayFree(data);
  ArrayFree(layers);
  ResourceFree(resurs);
  if(ObjectFind(0,name)>=0) {ObjectDelete(0,name);}
  ChartRedraw();
}
//---------------------------------------------------------------------
// Принудительное изменение размеров ресурса
//---------------------------------------------------------------------
void CCanvas::Force(void)
{
  X=ChartXSize();
  Y=ChartYSize();
  ArrayResize(data,X*Y);
  ArrayInitialize(data,0);
  layers[0].Size(X,Y);
}
//---------------------------------------------------------------------
// Отображение изменений на экране
//---------------------------------------------------------------------
void CCanvas::Update(void)
{
  ResourceCreate(resurs,data,X,Y,0,0,0,COLOR_FORMAT_ARGB_NORMALIZE);
  ChartRedraw();
}
//---------------------------------------------------------------------
// Резервирование слоя
//---------------------------------------------------------------------
void CCanvas::ReserveLayer(int& num)
{
  int size=ArraySize(layers);
  ArrayResize(layers,size+1);
  num=size;
}
//---------------------------------------------------------------------
// Переход к слою
//---------------------------------------------------------------------
bool CCanvas::GotoLayer(int num)
{
  if(ArraySize(layers)<num+1) {return(false);}
  layer=num;
  return(true);
}
//---------------------------------------------------------------------
// Рендеринг ресурса
//---------------------------------------------------------------------
void CCanvas::Rendering(bool flag=true)
{
  if(layer==0)
  {
    ArrayInitialize(data,0);
    Rendering(layers[0],0);
    layers[0].Refresh();
    return;
  }
  if(flag) {Rendering(layers[layer],-1);}
  Rendering(layers[layer],1);
  layers[layer].Refresh();
}
//---------------------------------------------------------------------
// Рендеринг
//---------------------------------------------------------------------
void CCanvas::Rendering(const Image& image,char flag)
{
  int a,b,x0,y0,x1,y1,xx=0;
  if(flag==-1)
  {
    x0=MathAbs(image.x0_off);
    y0=MathAbs(image.y0_off);
    x1=MathAbs(image.x1_off);
    y1=MathAbs(image.y1_off);
    if(x1>X-x0) {xx=x1-(X-x0);x1=X-x0;}
    if(y1>Y-y0) {y1=Y-y0;}
    for(int y=0;y<y1;y++)
    {
      for(int x=0;x<x1;x++)
      {
        b=MathAbs(X*(Y-(y+y0)-1)+(x+x0));
        a=X*(y+y0)+(x+x0);
        data[b]=layers[0].data[a];
      }
    }
  }
  if(flag==0)
  {
    for(int y=0;y<Y;y++)
    {
      for(int x=0;x<X;x++)
      {
        b=X*(Y-y-1)+x;
        a=X*y+x;
        data[b]=image.data[a];
      }
    }
  }
  if(flag==1)
  {
    x0=MathAbs(image.x0);
    y0=MathAbs(image.y0);
    x1=MathAbs(image.x1);
    y1=MathAbs(image.y1);
    if(x1>X-x0) {xx=x1-(X-x0);x1=X-x0;}
    if(y1>Y-y0) {y1=Y-y0;}
    for(int y=0;y<y1;y++)
    {
      for(int x=0;x<x1;x++)
      {
        b=MathAbs(X*(Y-(y+y0)-1)+(x+x0));
        a=x1*y+xx*y+x;
        data[b]=Overlay(image.data[a],data[b]);
      }
    }
  }
  if(flag==2)
  {
    x0=MathAbs(image.x0);
    y0=MathAbs(image.y0);
    x1=MathAbs(image.x1);
    y1=MathAbs(image.y1);
    if(x1>layers[layer].x1-x0) {xx=x1-(layers[layer].x1-x0);x1=layers[layer].x1-x0;}
    if(y1>layers[layer].y1-y0) {y1=layers[layer].y1-y0;}
    for(int y=0;y<y1;y++)
    {
      for(int x=0;x<x1;x++)
      {
        b=layers[layer].x1*(y+y0)+(x+x0);
        a=x1*y+xx*y+x;
        layers[layer].data[b]=Overlay(image.data[a],layers[layer].data[b]);
      }
    }
  }
}
//---------------------------------------------------------------------
// Наложение цветов
//---------------------------------------------------------------------
uint CCanvas::Overlay(const uint& top_,const uint& low_)
{
  ARGB c(top_,low_);
  return(c.GetNumber());
}
//---------------------------------------------------------------------
// Отрисовка точки
//---------------------------------------------------------------------
void CCanvas::Pixel(int x,int y,uint clr)
{
  if(x>=0 && x<layers[layer].x1 && y>=0 && y<layers[layer].y1)
  {
    layers[layer].data[layers[layer].x1*y+x]=clr;
  }
}
//---------------------------------------------------------------------
// Отрисовка горизонтального отрезка
//---------------------------------------------------------------------
void CCanvas::LineH(int x1,int y1,int x2,uint clr)
{
  if(x1>x2) {int tmp=x1;x1=x2;x2=tmp;}
  if(x2<0 || x1>=layers[layer].x1 || y1<0 || y1>=layers[layer].y1) {return;}
  if(x1<0) {x1=0;}
  if(x2>=layers[layer].x1) {x2=layers[layer].x1-1;}
  ArrayFill(layers[layer].data,layers[layer].x1*y1+x1,x2-x1+1,clr);
}
//---------------------------------------------------------------------
// Отрисовка вертикального отрезка
//---------------------------------------------------------------------
void CCanvas::LineV(int x1,int y1,int y2,uint clr)
{
  if(y1>y2) {int tmp=y1;y1=y2;y2=tmp;}
  if(y2<0 || y1>=layers[layer].y1 || x1<0 || x1>=layers[layer].x1) {return;}
  if(y1<0) {y1=0;}
  if(y2>=layers[layer].y1) {y2=layers[layer].y1-1;}
  int index=layers[layer].x1*y1+x1;
  for(int i=y1;i<=y2;i++,index+=layers[layer].x1) {layers[layer].data[index]=clr;}
}
//---------------------------------------------------------------------
// Отрисовка прямоугольника (пустого)
//---------------------------------------------------------------------
void CCanvas::Rectangle(int x1,int y1,int x2,int y2,uint clr)
{
  LineH(x1,y1,x2,clr);
  LineV(x2,y1,y2,clr);
  LineH(x2,y2,x1,clr);
  LineV(x1,y2,y1,clr);
}
//---------------------------------------------------------------------
// Отрисовка прямоугольника (закрашенного)
//---------------------------------------------------------------------
void CCanvas::Rectangle(int x1,int y1,int x2,int y2,uint clr1,uint clr2)
{
  Rectangle(x1,y1,x2,y2,clr1);
  if(x1>x2) {int tmp=x1;x1=x2;x2=tmp;}
  if(y1>y2) {int tmp=y1;y1=y2;y2=tmp;}
  if(x2-x1<2 || y2-y1<2) {return;}
  x1++;y1++;x2--;y2--;
  for(int i=y1;i<=y2;i++) {LineH(x1,i,x2,clr2);}
}
//---------------------------------------------------------------------
// Отрисовка прямоугольной области с заливкой двухцветным градиентом
//---------------------------------------------------------------------
void CCanvas::Gradient(int x1,int y1,int x2,int y2,GRADIENT_TYPE type,uint clr1,uint clr2)
{
  if(x1>x2) {int tmp=x1;x1=x2;x2=tmp;}
  if(y1>y2) {int tmp=y1;y1=y2;y2=tmp;}
  if((x2-x1<1 && type==LINE_X) || (y2-y1<1 && type==LINE_Y)) {return;}
  uint clr[];
  if(type==LINE_X)
  {
    int size=x2-x1+1;
    ArrayResize(clr,size);
    Gradient(clr,clr1,clr2);
    for(int i=x1;i<=x2;i++) {LineV(i,y1,y2,clr[i-x1]);}
  }
  if(type==LINE_Y)
  {
    int size=y2-y1+1;
    ArrayResize(clr,size);
    Gradient(clr,clr1,clr2);
    for(int i=y1;i<=y2;i++) {LineH(x1,i,x2,clr[i-y1]);}
  }
}
//---------------------------------------------------------------------
// Отрисовка текста
//---------------------------------------------------------------------
void CCanvas::Text(string text,int x,int y,uint clr)
{
  uint x1=0,y1=0;
  TextGetSize(text,x1,y1);
  Image image(x,y,x1,y1,0);
  TextOut(text,0,0,TA_LEFT|TA_TOP,image.data,x1,y1,clr,COLOR_FORMAT_ARGB_NORMALIZE);
  image.Invert();
  Rendering(image,2);
}
//---------------------------------------------------------------------
// Двойной градиент данных uint (ARGB-представления цвета)
//---------------------------------------------------------------------
void CCanvas::Gradient(uint& array[],uint clr1,uint clr2)
{
  int size=ArraySize(array);
  if(size<2) {return;}
  ARGB c1(clr1),c2(clr2);
  array[0]=clr1;
  array[size-1]=clr2;
  if(size<=2) {return;}
  size-=2;
  double step_a=double(c2.alpha-c1.alpha)/(size+1);
  double step_r=double(c2.red-c1.red)/(size+1);
  double step_g=double(c2.green-c1.green)/(size+1);
  double step_b=double(c2.blue-c1.blue)/(size+1);
  for(int i=1;i<=size;i++)
  {
    ARGB c3((uchar)(c1.alpha+i*step_a),(uchar)(c1.red+i*step_r),(uchar)(c1.green+i*step_g),(uchar)(c1.blue+i*step_b));
    array[i]=c3.GetNumber();
  }
}
