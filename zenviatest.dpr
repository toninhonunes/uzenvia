program zenviatest;

uses
  ExceptionLog,
  Forms,
  uzenviatest in 'uzenviatest.pas' {Form1},
  uzenvia in 'uzenvia.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
