unit Login;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Imaging.pngimage,
  Vcl.ExtCtrls, Vcl.Buttons, INIFiles;

type
  TForm2 = class(TForm)
    Background: TImage;
    Header: TImage;
    Footer: TImage;
    Close: TImage;
    BR: TImage;
    Version: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Logo: TImage;
    Login: TEdit;
    Senha: TEdit;
    Remember: TCheckBox;
    BTN_Login: TButton;
    BTN_Cancel: TButton;
    LoginError: TLabel;
    procedure CloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure BTN_LoginClick(Sender: TObject);
    procedure LoginKeyPress(Sender: TObject; var Key: Char);
    procedure SenhaKeyPress(Sender: TObject; var Key: Char);
    procedure BTN_CancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure MudancaDeFoco(Sender: TObject);
  public
    { Public declarations }
    ID_User:Integer;
  end;

var
  Form2: TForm2;
  LoginAtempt:integer;

implementation

{$R *.dfm}

uses Main, FormBG;


//=== Mudar a Cor do EditBox ===================================================
{ Esta rotina será chamada através do evento OnExit (perda do foco)
  de todos os componentes do tipo TEdit que existirem no form. }
procedure TForm2.MudancaDeFoco(Sender: TObject);
var
  I: integer;
  Ed: TEdit;
begin
  { Percorre a matriz de componentes do form }
  for I := 0 to ComponentCount - 1 do
    { Se o componente é do tipo TEdit... }
    if Components[I] is TEdit then
    begin
      { Faz um type-casting para o tipo TEdit }
      Ed := Components[I] as TEdit;

      { Se o Edit está com o foco... }
      if Ed.Focused then
        Ed.Color := $0062E8FF { Amarelo }
      else
        Ed.Color := clWhite; { Branco }
    end;
end;

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
//=== Cancel Buttom ============================================================
procedure TForm2.BTN_CancelClick(Sender: TObject);
begin
Application.Terminate;
end;
//=== Login Buttom =============================================================
procedure TForm2.BTN_LoginClick(Sender: TObject);
var Ini:TIniFile;
begin
if (Login.Text='admin') and (Senha.Text='admin') then
  begin
    if Remember.Checked=True then
      begin
        //salvar o login
        Ini := TIniFile.Create(ExtractFileDir(ParamStr(0))+'\config.ini');
        Ini.WriteString('Login','User',Login.Text);
        Ini.Free;
      end
    else
      begin
        //deletar as informações do config.ini
        Ini := TIniFile.Create(ExtractFileDir(ParamStr(0))+'\config.ini');
        Ini.EraseSection('Login');
        Ini.Free;
      end;
    //Liberar o acesso
    ID_User:=1;
    ModalResult:=mrOK;
  end
else
  begin
    //errar senha ou login
    LoginAtempt:=LoginAtempt+1;
    LoginError.Caption:='Erro de Login: '+IntToStr(LoginAtempt);
  end;
//Em caso de Erro 3 vezes
if LoginAtempt=3 then
  begin
    Login.Enabled:=False;
    Senha.Enabled:=False;
    BTN_Login.Enabled:=False;
    Remember.Enabled:=False;
    LoginError.Caption:='';
    ShowMessage('Erro ao Digitar Login ou Senha 3 vezes');
  end;
end;
//=== Close Buttom =============================================================
procedure TForm2.CloseClick(Sender: TObject);
begin
BTN_Cancel.Click;
end;
//=== Ativação do Form =========================================================
procedure TForm2.FormActivate(Sender: TObject);
begin
//Função de Mudar a cor do EditBox
MudancaDeFoco(nil);
//Restaurar user e rememberbox
if Login.Text<>'' then begin Senha.SetFocus; Remember.Checked:=True; end;
//Background
Background.Height:=Form2.Height;
Background.Width :=Form2.Width;
Background.Top:=0;
Background.Left:=0;


end;
//=== Criação do Form ==========================================================
procedure TForm2.FormCreate(Sender: TObject);
var Ini: TIniFile;
    I: integer;
begin
  { Percorre a lista de componentes do form (matriz de componentes)
    e verifica cada componente para saber se é um TEdit. Se for,
    associa o evento OnExit do componente com a procedure
    "MudancaDeFoco". }
  for I := 0 to ComponentCount - 1 do
    if Components[I] is TEdit then
      (Components[I] as TEdit).OnExit := MudancaDeFoco;

//Versão do Sistema
Version.Caption:='|  ['+VersaoExe+' ]';
//Variavel de Login
LoginAtempt:=0;

//Carregar Ini
Ini:=TIniFile.Create(ExtractFileDir(ParamStr(0))+'\config.ini');
Login.Text:=Ini.ReadString('Login','User','');
Ini.Free;

end;
procedure TForm2.FormShow(Sender: TObject);
begin
Form3.show;
end;

//=== Uso do Enter para Login ==================================================
procedure TForm2.LoginKeyPress(Sender: TObject; var Key: Char);
begin if Key=#13 then BTN_Login.Click; end;
procedure TForm2.SenhaKeyPress(Sender: TObject; var Key: Char);
begin if Key=#13 then BTN_Login.Click; end;

end.
