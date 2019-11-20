//Unit uzenvia
//Autor : Antonio Carlos Nunes Júnior (Toninho Nunes)
//Propósito : Enviar SMS usando a api REST da Zenvia
//Fiz para funcionar no Delphi 7, não testei em outras versões
//
//Bibliotecas de Terceiros
// - Component Indy 10 - http://indy.fulgan.com/ZIP/
//   Delphi 7
unit uzenvia;

interface

uses
  IdHTTP, IdCoderMIME, Classes, SysUtils, Forms, IdCTypes, IdSSLOpenSSL,
  IdSSLOpenSSLHeaders, uLkJSON;

type
  TSendSmsRequest = class
  private
    ffromSms : string;
    ftoSms : string;
    fschedule : TDateTime;
    fmsg : string;
    fcallBackOptions : string;
    fid : string;
    fagregateId : string;
    fflashSms : string;
  published
    property FromSMS : string read fFromSms write fFromSms;
    property ToSms : string read fToSms write fToSms;
    property Schedule : TDateTime read fschedule write fschedule;
    property Msg : string read fmsg write fmsg;
    property CallBackOptions : string read fcallBackOptions write fcallBackOptions;
    property Id : string read fid write fid;
    property AgregateId : string read fagregateId write fagregateId;
    property FlashSms : string read fflashSms write fflashSms;
  end;

  TSendSmsResponse = class
  private
    fStatusCode: string;
    fDetailDescription: string;
    fStatusDescription: string;
    fDetailCode: string;
    procedure GetStatus( sResponse : String );
  public
    constructor Create;
    destructor destroy; override;
  published
    property StatusCode : string read fStatusCode;
    property StatusDescription : string read fStatusDescription;
    property DetailCode : string read fDetailCode;
    property DetailDescription : string read fDetailDescription;
  end;

  TZenviaSMS = class
  private
    fIdHTTP : TIdHTTP;
    fssl : TIdSSLIOHandlerSocketOpenSSL;
    fContactSMS: TSendSmsRequest;
    fResponseSMS : TSendSmsResponse;
    furl : string;
    procedure OnStatusInfoEx(ASender: TObject; const AsslSocket: PSSL;
      const AWhere, Aret: TIdC_INT; const AType, AMsg: String);
  public
    constructor Create(sKey : string);
    destructor Destroy; override;
    function EncodeJSon : string;
  published
    property Contact  : TSendSmsRequest read fContactSMS write fContactSMS;
    property Response : TSendSmsResponse read fResponseSMS; 
    function SendSMS:Boolean;
  end;

implementation

uses IdTCPConnection, Variants;

{ TZenviaSMS }
constructor TZenviaSMS.Create(sKey : string);
begin
  inherited Create;
  if sKey = '' then
    raise Exception.Create('Não foi informado uma senha!');

  fIdHTTP := TIdHTTP.Create(Application);
  fResponseSMS := TSendSmsResponse.Create;
  fssl := TIdSSLIOHandlerSocketOpenSSL.Create(fIdHTTP);
  fssl.SSLOptions.Method := sslvTLSv1_2;
  fssl.SSLOptions.SSLVersions := [sslvTLSv1_2];
  fssl.OnStatusInfoEx := OnStatusInfoEx;
  fIdHTTP.IOHandler := fssl;

  with fIdHTTP do
  begin
    Request.Clear;
    Request.Method := 'POST';
    Request.CustomHeaders.AddValue('Authorization', 'Basic ' + sKey);
    Request.ContentType := 'application/json';
    Request.Accept := 'application/json';
    HTTPOptions := [];
  end;
  furl := 'https://api-rest.zenvia.com/services/send-sms';
  fContactSMS := TSendSmsRequest.Create;
end;

destructor TZenviaSMS.Destroy;
begin
  if Assigned(fContactSMS) then
    fContactSMS.Free;

  if Assigned(fssl) then
    fssl.Free;

  if Assigned(fIdHTTP) then
    fIdHTTP.Free;

  if Assigned(fResponseSMS) then
    fResponseSMS.Free;

  inherited;
end;

procedure TZenviaSMS.OnStatusInfoEx(ASender: TObject; const AsslSocket: PSSL;
  const AWhere, Aret: TIdC_INT; const AType, AMsg: String);
begin
  SSL_set_tlsext_host_name(AsslSocket, fIdHTTP.Request.Host);
end;

function TZenviaSMS.EncodeJSon: string;
var
  s : string;
begin
  s :=     '{';
  s := s + '  "sendSmsRequest": { ';
  s := s + '      "from":' + '"' + fContactSMS.fromSms + '",';
  s := s + '      "to":' + '"' + fContactSMS.toSms + '",';
  s := s + '      "schedule":' + '"' + FormatDateTime('yyyy-mm-dd''T''hh:mm:ss', fContactSMS.schedule) + '",';
  s := s + '      "msg":' +  '"' + fContactSMS.msg + '",';
  s := s + '      "callbackOption":' + '"NONE",';
  s := s + '      "id":' + '"' + fContactSMS.id + '",';
  s := s + '      "aggregateId":' + '"' + fContactSMS.agregateId + '",';
  s := s + '      "flashSms":' + '"' + fContactSMS.flashSms + '"';
  s := s + '   }';
  s := s + '}';
  Result := s;
end;

function TZenviaSMS.SendSMS : Boolean;
var
  RequestUTF8 : TStringStream;
begin
  Result := False;
  RequestUTF8 := TStringStream.Create( EncodeJSon );
  try
    fResponseSMS.GetStatus( fIdHTTP.Post(furl, RequestUTF8 ) );
    Result := fIdHTTP.ResponseCode = 200;
  finally
    RequestUTF8.Free;
  end;
end;

constructor TSendSmsResponse.Create;
begin
  inherited create;
end;

destructor TSendSmsResponse.destroy;
begin
  inherited destroy;
end;

procedure TSendSmsResponse.GetStatus(sResponse: String);
var
  js : TlkJSONbase;
  Items : TlkJSONbase;
  i : Integer;
begin
  js := TlkJSON.ParseText(sResponse);
  Items := js.Field['sendSmsResponse'];
  fStatusCode := VarToStr(Items.Field['statusCode'].Value);
  fStatusDescription := VarToStr(Items.Field['statusDescription'].Value);
  fDetailCode := VarToStr(Items.Field['detailCode'].Value);
  fDetailDescription := VarToStr(Items.Field['detailDescription'].Value);
end;

end.
