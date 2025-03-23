unit Forms.Main;

{$mode objfpc}{$H+}

interface

uses
  Classes
, SysUtils
, Forms
, Controls
, Graphics
, Dialogs
, StdCtrls, ActnList, StdActns, ExtCtrls
, RegExpr
;

type

{ TfrmMain }
  TfrmMain = class(TForm)
    actRegExRun: TAction;
    alMain: TActionList;
    btnRegExRun: TButton;
    btnFileExit: TButton;
    cgModifiers: TCheckGroup;
    edtRegEx: TEdit;
    actFileExit: TFileExit;
    gbRegEx: TGroupBox;
    gbText: TGroupBox;
    gbLog: TGroupBox;
    memText: TMemo;
    memLog: TMemo;
    procedure alMainUpdate(AAction: TBasicAction; var Handled: Boolean);
    procedure actRegExRunExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    FRegEx: TRegExpr;

    procedure InitShortcuts;
    procedure InitModifiers;
  public

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

uses
  LCLType
;

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FRegEx:= TRegExpr.Create;
  InitShortcuts;
  InitModifiers;
end;

procedure TfrmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  FRegEx.Free;
end;

procedure TfrmMain.InitShortcuts;
begin
{$IFDEF UNIX}
  actFileExit.ShortCut := KeyToShortCut(VK_Q, [ssCtrl]);
{$ENDIF}
{$IFDEF WINDOWS}
  actFileExit.ShortCut := KeyToShortCut(VK_X, [ssAlt]);
{$ENDIF}
end;

procedure TfrmMain.InitModifiers;
begin
  cgModifiers.Checked[0]:= FRegEx.ModifierI;
  cgModifiers.Checked[1]:= FRegEx.ModifierR;
  cgModifiers.Checked[2]:= FRegEx.ModifierS;
  cgModifiers.Checked[3]:= FRegEx.ModifierG;
  cgModifiers.Checked[4]:= FRegEx.ModifierM;
  cgModifiers.Checked[5]:= FRegEx.ModifierX;
end;

procedure TfrmMain.alMainUpdate(AAction: TBasicAction; var Handled: Boolean);
begin
  FRegEx.ModifierI:= cgModifiers.Checked[0];
  FRegEx.ModifierR:= cgModifiers.Checked[1];
  FRegEx.ModifierS:= cgModifiers.Checked[2];
  FRegEx.ModifierG:= cgModifiers.Checked[3];
  FRegEx.ModifierM:= cgModifiers.Checked[4];
  FRegEx.ModifierX:= cgModifiers.Checked[5];
  Handled:= True;
end;

procedure TfrmMain.actRegExRunExecute(Sender: TObject);
var
  index, exec: Integer;
begin
  if (Trim(edtRegEx.Text) = EmptyStr) or (memText.Lines.Count = 0) then
    exit;
  try
    if memLog.Lines.Count <> 0 then
      memLog.Clear;
    FRegEx.Expression:= edtRegEx.Text;
    if FRegEx.Exec(memText.Text) then
    begin
      memLog.Append('Execute returned True');
      memLog.Append(Format('Last Error: %d', [FRegEx.LastError]));
      memLog.Append(Format('Modifiers: %s', [FRegEx.ModifierStr]));
      exec:= 1;
      repeat
        memLog.Append(Format('Exec: %d', [exec]));
        if FRegEx.SubExprMatchCount > 0 then
          memLog.Append(Format('  SubExpr Match Count: %d', [FRegEx.SubExprMatchCount]));
        index:= 0;
        repeat
          memLog.Append(Format('  Match[%d]: "%s"', [index, FRegEx.Match[index]]));
          memLog.Append(Format('  Match Position: %d', [FRegEx.MatchPos[index]]));
          memLog.Append(Format('  Match Length: %d', [FRegEx.MatchLen[index]]));
          Inc(index);
        until FRegEx.Match[index] = EmptyStr;
        Inc(exec);
      until not FRegEx.ExecNext;
    end
    else
    begin
      memLog.Append('Execute returned False');
      memLog.Append(Format('Last Error: %d', [FRegEx.LastError]));
    end;
  except
    on E: Exception do
    begin
      memLog.Append('Exception: ' + E.Message);
    end;
  end;
end;

end.

