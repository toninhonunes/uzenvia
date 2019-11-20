unit uzenviatest;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  uzenvia;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  Zenvia : TZenviaSMS;
begin
  Zenvia := TZenviaSMS.Create('suasenha-zenvia');
  with Zenvia do
  try
    Contact.fromSms    := 'TESTE';
    Contact.toSms      := '5567999999';
    Contact.schedule   := Now;
    Contact.msg        := Trim(Memo1.Lines.Text);
    Contact.callBackOptions := 'NONE';
    Contact.id         := '001';
    Contact.agregateId := '0';
    SendSMS;
  finally
    Free;
  end;
end;

end.
