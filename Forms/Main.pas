unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Imaging.jpeg, System.Types;

type
  TForm1 = class(TForm)
    Footer: TImage;
    Bar1: TImage;
    Edit1: TEdit;
    Edit2: TEdit;
    Button1: TButton;
    Label1: TLabel;
    Header: TImage;
    Background: TImage;
    Menu: TImage;
    Maximizar: TImage;
    Fechar: TImage;
    Minimizar: TImage;
    Version: TLabel;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure MaximizarClick(Sender: TObject);
    procedure FecharClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    procedure WMNCHitTest(var Msg: TWMNCHitTest);
      message WM_NCHITTEST;
    procedure WMGetMinmaxInfo(var Msg: TWMGetMinmaxInfo);
      message WM_GETMINMAXINFO;
  public
    { Public declarations }
    FAllowSize: Boolean;
    ID_User:Integer;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses Login, FormBG;


//== Função da Versão do Aplicativo ============================================
Function VersaoExe: String;
type
   PFFI = ^vs_FixedFileInfo;
var
   F       : PFFI;
   Handle  : Dword;
   Len     : Longint;
   Data    : Pchar;
   Buffer  : Pointer;
   Tamanho : Dword;
   Parquivo: Pchar;
   Arquivo : String;
begin
   Arquivo  := Application.ExeName;
   Parquivo := StrAlloc(Length(Arquivo) + 1);
   StrPcopy(Parquivo, Arquivo);
   Len := GetFileVersionInfoSize(Parquivo, Handle);
   Result := '';
   if Len > 0 then
   begin
      Data:=StrAlloc(Len+1);
      if GetFileVersionInfo(Parquivo,Handle,Len,Data) then
      begin
         VerQueryValue(Data, '',Buffer,Tamanho);
         F := PFFI(Buffer);
         Result := Format('%d.%d.%d.%d',
                          [HiWord(F^.dwFileVersionMs),
                           LoWord(F^.dwFileVersionMs),
                           HiWord(F^.dwFileVersionLs),
                           Loword(F^.dwFileVersionLs)]
                         );
      end;
      StrDispose(Data);
   end;
   StrDispose(Parquivo);
end;
//==============================================================================


//=== Correção do Maximizar ====================================================
procedure TForm1.WMGETMINMAXINFO(var Msg: TWMGetMinmaxInfo);
var
  R: TRect;
begin
  inherited;

  // Obtem o retangulo com a area livre do desktop
  SystemParametersInfo(SPI_GETWORKAREA, SizeOf(R), @R, 0);

  Msg.MinMaxInfo^.ptMaxPosition := R.TopLeft;
  OffsetRect(R, -R.Left, -R.Top);
  Msg.MinMaxInfo^.ptMaxSize := R.BottomRight;
end;

//=== Permitir alterar o tamanho do Form sem borda =============================
procedure TForm1.WMNCHitTest(var Msg: TWMNCHitTest);
var
  ScreenPt : TPoint;
  MoveArea : TRect;
  HANDLE_WIDTH: Integer;
  SIZEGRIP: Integer;
begin
HANDLE_WIDTH := 3;
Sizegrip := 19;
inherited;
  if not (csDesigning in ComponentState) then
    begin
      ScreenPt := ScreenToClient(Point(Msg.Xpos, Msg.Ypos));
      MoveArea := Rect(HANDLE_WIDTH,
      HANDLE_WIDTH,
      Width - HANDLE_WIDTH,
      Height - HANDLE_WIDTH);
  if FAllowSize then
    begin
      // left side
      if (ScreenPt.x < HANDLE_WIDTH) then Msg.Result := HTLEFT
      // top side
      else if (ScreenPt.y < HANDLE_WIDTH) then Msg.Result := HTTOP
      // right side
      else if (ScreenPt.x >= Width - HANDLE_WIDTH) then Msg.Result := HTRIGHT
      // bottom side
      else if (ScreenPt.y >= Height - HANDLE_WIDTH) then Msg.Result := HTBOTTOM
      // top left corner
      //else if (ScreenPt.x < Sizegrip) and (ScreenPt.y < Sizegrip) then
      //  Msg.Result := HTTOPLEFT
      // bottom left corner
      else if (ScreenPt.x < Sizegrip) and (ScreenPt.y >= Height - Sizegrip) then
        Msg.Result := HTBOTTOMLEFT
      // top right corner
      //else if (ScreenPt.x >= Width - Sizegrip) and (ScreenPt.y < Sizegrip) then
      //  Msg.Result := HTTOPRIGHT
      // bottom right corner
      else if (ScreenPt.x >= Width - Sizegrip) and (ScreenPt.y >= Height - Sizegrip) then
        Msg.Result := HTBOTTOMRIGHT
    end;
  end;
{
// IF you want to allow moving the form, add an FAllowMove variable and
// set it to true, then uncomment this code.
if FAllowMove then
begin
// no sides or corners, this will do the dragging
if PtInRect(MoveArea, ScreenPt) then
Msg.Result := HTCAPTION;
end;
}
end;
//=== Botão Fechar =============================================================
procedure TForm1.FecharClick(Sender: TObject);
begin
Application.Terminate;
end;
//=== Ativação do Form =========================================================
procedure TForm1.FormActivate(Sender: TObject);
begin
if Form2=nil then
  begin
    Form2:=TForm2.Create(Application);
    try
      if Form2.ShowModal = mrOK then
        begin
          ID_User:=Form2.ID_User;
          Label2.Caption:=IntToStr(ID_User);
        end
       else
        begin
          Application.Terminate;
        end;
    finally
      Form2.Free;
      Form2:=nil;
      end;
  end else Application.Terminate;
end;

//=== Criação do Form ==========================================================
procedure TForm1.FormCreate(Sender: TObject);
begin
//True Permite o reajuste do tamanho do Form sem borda
FAllowSize := True;
//Background ajustado com o tamanho do Form
Background.Top:=0;
Background.Left:=0;
Background.Width:=Form1.Width;
Background.Height:=Form1.Height;
//Menu Lateral ajustado com o tamanho do form
Menu.Height:=Form1.Height-129;
//Versão do Aplicativo
Version.Caption:='|  ['+VersaoExe+' ]';
end;
//=== Atualizar informações com a alteração do tamanho do Form =================
procedure TForm1.FormResize(Sender: TObject);
begin
//Background
Background.Width:=Form1.Width;
BackGround.Height:=Form1.Height;
//Menu Lateral
Menu.Height:=Form1.Height-129;
end;

//=== Maximizar ================================================================
procedure TForm1.MaximizarClick(Sender: TObject);
begin
if FAllowSize=True then //Maximixar e bloquear a alteração do tamanho do Form
  begin
    SendMessage(Handle, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
    FAllowSize := False;
  end
else if FAllowSize=False then//Restaurar e permitir a alteração do tamanho do Form
  begin
    SendMessage(Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
    FAllowSize := True;
  end;
end;

//==============================================================================
procedure TForm1.Button1Click(Sender: TObject);
var I,G,H:Integer;
    Z:Double;
begin
H:= -Form1.Height+138;

Z:=(StrToFloat(Edit1.Text))/(StrToFloat(Edit2.Text));
if Z<=0.05 then Z:=0.05;
Label1.Caption:=FloatToStr(z);
G:=Trunc(H*Z);

for I := 1 downto G do Bar1.Height:=I;
end;

end.
