/*

*/
#include "Common.mqh"
#include "CCanvas.mqh"
//---------------------------------------------------------------------
// Класс для создания и управления полосой(шкалой) прогресса
//---------------------------------------------------------------------
class CProgressBar
{
  public:
          CProgressBar(CCanvas *c_);
         ~CProgressBar(void);
    bool  Init(CCanvas *c_);
    bool  IsInit(void) {return(init);}
    void  Deinit(void);
    void  Create(double num1_,double num2_,bool flag=true);
    void  Destroy(void);
    void  Current(double num_);

  public:
    string  signature;

  private:
    bool     init;
    bool     create;
    bool     way;
    int      l1;         //номер слоя
    int      x0;         //начало координат слоя по x
    int      y0;         //начало координат слоя по y
    int      x1;         //длина индикатора прогресса
    int      y1;         //высота индикатора прогресса
    int      scale_x0;   //левая нижняя точка шкалы без рамки (x)
    int      scale_y0;   //левая нижняя точка шкалы без рамки (y)
    int      scale_x1;   //правая верхняя точка шкалы без рамки (x)
    int      scale_y1;   //правая верхняя точка шкалы без рамки (y)
    int      scale_x;    //длина шкалы без рамки
    int      scale;      //длина заполненной части шкалы без рамки
    int      percent;
    double   num1;
    double   num2;
    double   num;
    CCanvas *c;

  private:
    void  Calculate(void);
    void  Frame(void);
    void  Percent(void);
    void  Scale(int size);
    void  Title(void);
    void  Background(void);
    void  Filled(int a,int b);
    void  Empty(int a,int b);
};
//---------------------------------------------------------------------
// Параметрический конструктор
//---------------------------------------------------------------------
void CProgressBar::CProgressBar(CCanvas *c_)
{
  if(!Init(c_)) {Deinit();}
}
//---------------------------------------------------------------------
// Деструктор
//---------------------------------------------------------------------
void CProgressBar::~CProgressBar(void)
{
  Deinit();
}
//---------------------------------------------------------------------
// Инициализация
//---------------------------------------------------------------------
bool CProgressBar::Init(CCanvas *c_)
{
  Deinit();
  if(c_==NULL) {return(false);}
  c=c_;
  c.ReserveLayer(l1);
  init=true;
  return(true);
}
//---------------------------------------------------------------------
// Деинициализация
//---------------------------------------------------------------------
void CProgressBar::Deinit(void)
{
  init=false;
  create=false;
  c=NULL;
}
//---------------------------------------------------------------------
// Создание индикатора прогресса
//---------------------------------------------------------------------
void CProgressBar::Create(double num1_,double num2_,bool flag=true)
{
  if(flag)
  {
    if(Compare(num1_,num2_)) {return;}
    if(num1_<num2_) {num1=num1_;num2=num2_;way=true;}
    else {num1=num2_;num2=num1_;way=false;}
    num=DBL_MAX;
    percent=0;
    scale=0;
    create=true;
  }
  else
  {
    if(!create) {return;}
    if(num==DBL_MAX) {scale=0;}
    else
    {
      if(way) {scale=int((num-num1)/(num2-num1)*scale_x);}
      else {scale=int(scale_x-((num-num1)/(num2-num1)*scale_x));}
    }
  }
  Calculate();
  c.GotoLayer(0);
  Background();
  c.Rendering();
  c.GotoLayer(l1);
  Frame();
  Percent();
  Scale(INT_MAX);
  if(signature!=NULL && signature!="") {Title();}
  c.Rendering();
  c.Update();
}
//---------------------------------------------------------------------
// Создание текущего уровня на шкале индикатора прогресса
//---------------------------------------------------------------------
void CProgressBar::Current(double num_)
{
  if(!create) {return;}
  if(num_<num1) {num_=num1;}
  if(num_>num2) {num_=num2;}
  num=num_;
  int curr_percent,curr_scale;
  bool update=false;
  if(way)
  {
    curr_percent=int((num-num1)/(num2-num1)*100);
    curr_scale=int((num-num1)/(num2-num1)*scale_x);
  }
  else
  {
    curr_percent=int(100-((num-num1)/(num2-num1)*100));
    curr_scale=int(scale_x-((num-num1)/(num2-num1)*scale_x));
  }
  c.GotoLayer(l1);
  if(curr_percent!=percent)
  {
    percent=curr_percent;
    Percent();
    update=true;
  }
  if(curr_scale!=scale)
  {
    Scale(curr_scale);
    scale=curr_scale;
    update=true;
  }
  if(update)
  {
    c.Rendering(false);
    c.Update();
  }
}
//---------------------------------------------------------------------
// Уничтожение индикатора прогресса
//---------------------------------------------------------------------
void CProgressBar::Destroy(void)
{
  if(!create) {return;}
  c.GotoLayer(l1);
  c.SetSize(0,0);
  c.Rendering();
  c.GotoLayer(0);
  c.Clean();
  c.Rendering();
  c.Update();
  create=false;
}
//---------------------------------------------------------------------
// Расчёт индикатора прогресса
//---------------------------------------------------------------------
void CProgressBar::Calculate(void)
{
  x0=20;
  y0=20;
  x1=446;
  int temp=c.X-x1-2*x0;
  if(temp<0) {x1+=temp;}
  y1=19;
  scale_x0=43;
  scale_y0=3;
  scale_x1=x1-4;
  scale_y1=15;
  scale_x=x1-46;
  c.GotoLayer(l1);
  c.SetSize(x1,49);
  c.SetOffset(x0,y0);
}
//---------------------------------------------------------------------
// Отрисовка рамки
//---------------------------------------------------------------------
void CProgressBar::Frame(void)
{
  c.Rectangle(0,0,x1-1,y1-1,rgb(255,255,255));
  c.Rectangle(1,1,x1-2,y1-2,rgb(240,240,240));
  c.Rectangle(42,2,x1-3,y1-3,rgb(115,115,115));
  c.Pixel(0,0,0);
  c.Pixel(x1-1,0,0);
  c.Pixel(x1-1,y1-1,0);
  c.Pixel(0,y1-1,0);
}
//---------------------------------------------------------------------
// Отрисовка процентов
//---------------------------------------------------------------------
void CProgressBar::Percent(void)
{
  c.Gradient(2,2,41,6,LINE_Y,rgb(240,240,240),rgb(220,220,220));
  c.Gradient(2,y1-3,41,y1-7,LINE_Y,rgb(220,220,220),rgb(240,240,240));
  c.Rectangle(2,7,41,y1-8,rgb(220,220,220),rgb(220,220,220));
  string str=(string)percent+"%";
  TextSetFont("Tahoma",16,FW_BOLD);
  if(percent<10) {c.Text(str,12,2,rgb(100,104,106));return;}
  if(percent==100) {c.Text(str,3,2,rgb(100,104,106));return;}
  c.Text(str,7,2,rgb(100,104,106));
}
//---------------------------------------------------------------------
// Отрисовка шкалы
//---------------------------------------------------------------------
void CProgressBar::Scale(int size)
{
  if(size==INT_MAX)
  {
    if(scale==0) {Empty(scale_x0,scale_x1);return;}
    if(scale==scale_x) {Filled(scale_x0,scale_x1);return;}
    Filled(scale_x0,scale_x0+scale-1);
    Empty(scale_x0+scale,scale_x1);
    return;
  }
  if(size>scale) {Filled(scale_x0+scale,scale_x0+size-1);}
  if(size<scale) {Empty(scale_x0+size,scale_x0+scale-1);}
}
//---------------------------------------------------------------------
// Отрисовка пустой части шкалы
//---------------------------------------------------------------------
void CProgressBar::Empty(int a,int b)
{
  c.Gradient(a,scale_y0,b,scale_y0+4,LINE_Y,rgb(58,60,61),rgb(82,83,84));
  c.Gradient(a,scale_y1,b,scale_y1-4,LINE_Y,rgb(82,83,84),rgb(58,60,61));
  c.Rectangle(a,scale_y0+5,b,scale_y1-5,rgb(82,83,84),rgb(82,83,84));
}
//---------------------------------------------------------------------
// Отрисовка заполненной части шкалы
//---------------------------------------------------------------------
void CProgressBar::Filled(int a,int b)
{
  c.Gradient(a,scale_y0,b,scale_y0+7,LINE_Y,rgb(50,232,240),rgb(30,114,222));
  c.Gradient(a,scale_y0+8,b,scale_y1,LINE_Y,rgb(103,162,226),rgb(197,236,247));
}
//---------------------------------------------------------------------
// Отрисовка надписи над шкалой
//---------------------------------------------------------------------
void CProgressBar::Title(void)
{
  TextSetFont("Arial",16,FW_NORMAL);
  c.Text(signature,8,y1+7,rgb(200,200,200));
}
//---------------------------------------------------------------------
// Отрисовка заднего фона
//---------------------------------------------------------------------
void CProgressBar::Background(void)
{
  c.Gradient(0,0,c.X-1,334,LINE_Y,argb(255,0,0,0),argb(0,0,0,0));
}
