unit FormBG;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TForm3 = class(TForm)
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

uses Main;

procedure TForm3.FormShow(Sender: TObject);
begin
Form3.Top:=Form1.Top;
Form3.Left:=Form1.Left;
Form3.Height:=Form1.Height;
Form3.Width :=Form1.Width;
end;

end.
