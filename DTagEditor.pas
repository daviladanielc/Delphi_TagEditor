unit DTagEditor;

{
 TDTagEditor Component
 First Version (2014) by: Andreas Rejbrand. (https://specials.rejbrand.se/dev/controls/tageditor/)

 Modified and improved version (2021) by Daniel C. Dávila - daniel@cdavila.net
}

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, StdCtrls, Forms, Graphics,
  Types, Menus, Vcl.Themes, Dialogs, StrUtils;

type
  TClickInfo = cardinal;
  GetTagIndex = word;

const
  TAG_LOW = 0;

const
  TAG_HIGH = MAXWORD - 2;

const
  EDITOR = MAXWORD - 1;

const
  NOWHERE = MAXWORD;

const
  PART_BODY = $00000000;

const
  PART_REMOVE_BUTTON = $00010000;

function GetTagPart(ClickInfo: TClickInfo): cardinal;

type

  TTagItemConfig = record
    CanDeleteTag: Boolean;
    TagBgColor: TColor;
    TagBorderColor: TColor;
    TagValue: Variant;
    TextColor: TColor;
  end;

  TTagClickEvent = procedure(Sender: TObject; TagIndex: integer;
    const TagCaption: string) of object;
  TRemoveConfirmEvent = procedure(Sender: TObject; TagIndex: integer;
    const TagCaption: string; var CanRemove: Boolean) of object;
  TTagRemoved = procedure(Sender: TObject; TagIndex: integer) of object;
  TBeforeTagRemove = procedure(Sender: TObject; TagIndex: integer) of object;
  TTags = class;
  TDTagEditor = class;

  TTagItem = class(TCollectionItem)
  private
    FCanDeleteTag: Boolean;
    FTagBgColor: TColor;
    FTagBorderColor: TColor;
    FTagValue: Variant;
    FTextColor: TColor;
    FText: string;
    function GetTagEditor: TDTagEditor;
    procedure SetCanDeleteTag(const Value: Boolean);
    procedure SetTagBgColor(const Value: TColor);
    procedure SetTagBorderColor(const Value: TColor);
    procedure SetTextColor(const Value: TColor);
  published
    property CanDeleteTag: Boolean read FCanDeleteTag write SetCanDeleteTag;
    property TagBgColor: TColor read FTagBgColor write SetTagBgColor;
    property TagBorderColor: TColor read FTagBorderColor
      write SetTagBorderColor;
    property TagValue: Variant read FTagValue write FTagValue;
    property Text: String read FText write FText;
    property TextColor: TColor read FTextColor write SetTextColor;
  public
    procedure Assign(Source: TPersistent); override;
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
  end;

  TTagItemCLass = class of TTagItem;

{$HINTS OFF}

  TCollectionHack = class(TPersistent)
  private
    FItemClass: TCollectionItemClass;
    FItems: TList;
  end;
{$HINTS ON}

  TTags = class(TCollection)
  private
    FTagEditor: TDTagEditor;
    function GetTagItem(Index: integer): TTagItem;
    procedure SetTagItem(Index: integer; const Value: TTagItem);
  protected
    function GetOwner: TPersistent; override;
  public
    function IndexOf(AText: string): integer;
    function DelimitedText: String;
    function Add(AItemConfig: TTagItemConfig; AText: String = '')
      : TTagItem; overload;
    function Add(AText: String = ''): TTagItem; overload;
    procedure DeleteAll;
    procedure Move(CurIndex, NewIndex: integer);
    constructor Create(ATagEditor: TDTagEditor; ATagsItemClass: TTagItemCLass);
    property Items[Index: integer]: TTagItem read GetTagItem
      write SetTagItem; default;
    property TagEditor: TDTagEditor read FTagEditor;
  end;

  TDTagEditor = class(TCustomControl)
  private
    { Private declarations }
    FActualTagHeight: integer;
    FAllowDuplicates: Boolean;
    FAutoHeight: Boolean;
    FBeforeTagRemove: TBeforeTagRemove;
    FBgColor: TColor;
    FBorderColor: TColor;
    FCanDragTags: Boolean;
    FCaretVisible: Boolean;
    FLefts, FRights, FWidths, FTops, FBottoms: array of integer;
    FCloseBtnLefts, FCloseBtnTops: array of integer;
    FCloseBtnWidth: integer;
    FCommaAccepts: Boolean;
    FDeleteButtonIcon: TIcon;
    FDeleteTagButton: Boolean;
    FDesiredHeight: integer;
    FDragging: Boolean;
    FEdit: TEdit;
    FEditorColor: TColor;
    FEditPos: TPoint;
    FMaxHeight: integer;
    FMaxTags: integer;
    FMouseDownClickInfo: TClickInfo;
    FMultiLine: Boolean;
    FNoLeadingSpaceInput: Boolean;
    FTags: TTags;
    FNumRows: integer;
    FOnChange: TNotifyEvent;
    FOnDblClick: TNotifyEvent;
    FOnRemoveConfirm: TRemoveConfirmEvent;
    FPopupMenu: TPopupMenu;
    FPrevScrollPos: integer;
    FReadOnly: Boolean;
    FSavedReadOnly: Boolean;
    FScrollBarVisible: Boolean;
    FScrollInfo: TScrollInfo;
    FSemicolonAccepts: Boolean;
    FShrunk: Boolean;
    FSpaceAccepts: Boolean;
    FSpacing: integer;
    FTagAdded: TNotifyEvent;
    FTagBgColor: TColor;
    FTagBorderColor: TColor;
    FTagClickEvent: TTagClickEvent;
    FTagHeight: integer;
    FTagRemoved: TTagRemoved;
    FTagRoundBorder: integer;
    FTextColor: TColor;
    FTrimInput: Boolean;
    function Accept: Boolean;
    function GetClickInfoAt(X, Y: integer): TClickInfo;
    function GetReadOnly: Boolean;
    function GetSeparatorIndexAt(X, Y: integer): integer;
    function GetShrunkClientRect(const Amount: integer): TRect;
    function IsFirstOnRow(TagIndex: integer): Boolean; inline;
    function IsLastOnRow(TagIndex: integer): Boolean;
    procedure CreateCaret;
    procedure DestroyCaret;
    procedure DrawFocusRect;
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
    procedure FixPosAndScrollWindow;
    procedure HideEditor;
    procedure mnuDeleteItemClick(Sender: TObject);
    procedure SetAutoHeight(const Value: Boolean);
    procedure SetBgColor(const Value: TColor);
    procedure SetBorderColor(const Value: TColor);
    procedure SetButtonIcon(const Value: TIcon);
    procedure SetCanDragTags(const Value: Boolean);
    procedure SetCloseTagButton(const Value: Boolean);
    procedure SetMaxHeight(const Value: integer);
    procedure SetMultiLine(const Value: Boolean);
    procedure SetPasteText(AText: string);
    procedure SetTags(const Value: TTags);
    procedure SetReadOnly(const Value: Boolean);
    procedure SetSpacing(const Value: integer);
    procedure SetTagBgColor(const Value: TColor);
    procedure SetTagBorderColor(const Value: TColor);
    procedure SetTagHeight(const Value: integer);
    procedure SetTagRoundBorder(const Value: integer);
    procedure SetTextColor(const Value: TColor);
    procedure ShowEditor;
    procedure TagChange(Sender: TObject);
    procedure UpdateMetrics;
    procedure UpdateScrollBars;
  protected
    { Protected declarations }
    function CreateTags(ATagEditor: TDTagEditor): TTags; dynamic;
    function GetFontEdit: TFont;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DblClick;
    procedure KeyDown(var Key: word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X: integer;
      Y: integer); override;
    procedure MouseMove(Shift: TShiftState; X: integer; Y: integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X: integer;
      Y: integer); override;
    procedure Paint; override;
    procedure WndProc(var Message: TMessage); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property Align;
    property AllowDuplicates: Boolean read FAllowDuplicates
      write FAllowDuplicates default false;
    property Anchors;
    property AutoHeight: Boolean read FAutoHeight write SetAutoHeight;
    property BgColor: TColor read FBgColor write SetBgColor;
    property BorderColor: TColor read FBorderColor write SetBorderColor;
    property CanDragTags: Boolean read FCanDragTags write SetCanDragTags
      default True;
    property Color;
    property CommaAccepts: Boolean read FCommaAccepts write FCommaAccepts
      default True;
    property Cursor;
    property DeleteButtonIcon: TIcon read FDeleteButtonIcon write SetButtonIcon;
    property DeleteTagButton: Boolean read FDeleteTagButton
      write SetCloseTagButton default True;
    property EditorColor: TColor read FEditorColor write FEditorColor
      default clWindow;
    property MaxHeight: integer read FMaxHeight write SetMaxHeight default 512;
    property MaxTags: integer read FMaxTags write FMaxTags default 0;
    property MultiLine: Boolean read FMultiLine write SetMultiLine
      default false;
    property NoLeadingSpaceInput: Boolean read FNoLeadingSpaceInput
      write FNoLeadingSpaceInput default True;
    property Tags: TTags read FTags write SetTags;
    [Default (True)]
    property OnBeforeTagRemove: TBeforeTagRemove read FBeforeTagRemove
      write FBeforeTagRemove;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
    property OnRemoveConfirm: TRemoveConfirmEvent read FOnRemoveConfirm
      write FOnRemoveConfirm;
    property OnTagAdded: TNotifyEvent read FTagAdded write FTagAdded;
    property OnTagClick: TTagClickEvent read FTagClickEvent
      write FTagClickEvent;
    property OnTagRemoved: TTagRemoved read FTagRemoved write FTagRemoved;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default false;
    property SemicolonAccepts: Boolean read FSemicolonAccepts
      write FSemicolonAccepts default True;
    property SpaceAccepts: Boolean read FSpaceAccepts write FSpaceAccepts
      default True;
    property Spacing: integer read FSpacing write SetSpacing;
    property TabOrder;
    property TabStop;
    property Tag;
    property TagBgColor: TColor read FTagBgColor write SetTagBgColor;
    property TagBorderColor: TColor read FTagBorderColor
      write SetTagBorderColor;
    property TagHeight: integer read FTagHeight write SetTagHeight default 32;
    property TagRoundBorder: integer read FTagRoundBorder
      write SetTagRoundBorder;
    property TextColor: TColor read FTextColor write SetTextColor;
    property TrimInput: Boolean read FTrimInput write FTrimInput default True;

  end;

procedure Register;

implementation

uses Math, Clipbrd;

procedure Register;
begin
  RegisterComponents('TagEditor', [TDTagEditor]);
end;

function IsKeyDown(const VK: integer): Boolean;
begin
  IsKeyDown := GetKeyState(VK) and $8000 <> 0;
end;

function GetTagPart(ClickInfo: TClickInfo): cardinal;
begin
  result := ClickInfo and $FFFF0000;
end;

procedure SafeDrawFocusRect(hDC: hDC; const R: TRect);
var
  oldBkColor, oldTextColor: COLORREF;
begin
  oldBkColor := Windows.SetBkColor(hDC, clWhite);
  oldTextColor := Windows.SetTextColor(hDC, clBlack);
  Windows.DrawFocusRect(hDC, R);
  if oldBkColor <> CLR_INVALID then
    Windows.SetBkColor(hDC, oldBkColor);
  if oldTextColor <> CLR_INVALID then
    Windows.SetTextColor(hDC, oldTextColor);
end;

{ TTagEditor }

constructor TDTagEditor.Create(AOwner: TComponent);
var
  mnuItem: TMenuItem;
begin
  inherited;
  FEdit := TEdit.Create(Self);
  FEdit.Parent := Self;
  FEdit.BorderStyle := bsNone;
  FEdit.Visible := false;
  FEdit.OnKeyPress := EditKeyPress;
  FEdit.OnEnter := EditEnter;
  FEdit.OnExit := EditExit;
  FTags := CreateTags(Self);

  FBgColor := clWindow;
  FBorderColor := clWindowFrame;
  FTagBgColor := clSkyBlue;
  FTagBorderColor := clNavy;
  FSpacing := 8;
  FTextColor := clWhite;
  FSpaceAccepts := True;
  FCommaAccepts := True;
  FSemicolonAccepts := True;
  FTrimInput := True;
  FNoLeadingSpaceInput := True;
  FAllowDuplicates := false;
  FMultiLine := false;
  FTagHeight := 32;
  FShrunk := false;
  FEditorColor := clWindow;
  FMaxHeight := 512;
  FCaretVisible := false;
  FDragging := false;
  FPrevScrollPos := 0;
  FScrollInfo.cbSize := sizeof(FScrollInfo);
  FScrollBarVisible := false;
  FDeleteTagButton := True;
  FPopupMenu := TPopupMenu.Create(Self);
  mnuItem := TMenuItem.Create(PopupMenu);
  mnuItem.Caption := 'Deletar';
  mnuItem.OnClick := mnuDeleteItemClick;
  mnuItem.Hint := 'Deleta a tag selecionada.';
  FPopupMenu.Items.Add(mnuItem);
  FCanDragTags := True;
  TabStop := True;
  FDeleteButtonIcon := TIcon.Create;
end;

procedure TDTagEditor.EditEnter(Sender: TObject);
begin
  if FEditPos.Y + FEdit.Height > FScrollInfo.nPos + ClientHeight then
    FScrollInfo.nPos := FEditPos.Y + ClientHeight - FEdit.Height;
  FixPosAndScrollWindow;
end;

procedure TDTagEditor.EditExit(Sender: TObject);
begin
  if FEdit.Text <> '' then
    Accept
  else
    HideEditor;
end;

procedure TDTagEditor.mnuDeleteItemClick(Sender: TObject);
begin
  if Sender is TMenuItem then
  begin
    if Assigned(FBeforeTagRemove) then
      FBeforeTagRemove(Self, TMenuItem(Sender).Tag);
    FTags.Delete(TMenuItem(Sender).Tag);

    if Assigned(FTagRemoved) then
      FTagRemoved(Self, TMenuItem(Sender).Tag);
  end;
end;

procedure TDTagEditor.TagChange(Sender: TObject);
begin
  UpdateMetrics;
  Invalidate;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TDTagEditor.WndProc(var Message: TMessage);
begin
  inherited;
  case Message.Msg of
    WM_LBUTTONDBLCLK:
      begin
        if csCaptureMouse in ControlStyle then
          MouseCapture := True;
        if csClickEvents in ControlStyle then
          DblClick;
      end;
    WM_SETFOCUS:
      Invalidate;
    WM_KILLFOCUS:
      begin
        if FCaretVisible then
          DestroyCaret;
        FDragging := false;
        Invalidate;
      end;
    WM_COPY:
      Clipboard.AsText := FTags.DelimitedText;
    WM_CLEAR:
      FTags.Clear;
    WM_CUT:
      begin
        Clipboard.AsText := FTags.DelimitedText;
        FTags.DeleteAll;
      end;
    WM_PASTE:
      begin
        if Clipboard.HasFormat(CF_TEXT) then
          SetPasteText(Clipboard.AsText);
      end;
    WM_SIZE:
      begin
        UpdateMetrics;
        Invalidate;
        Message.result := 0;
      end;
    WM_VSCROLL:
      begin
        FScrollInfo.fMask := SIF_ALL;
        GetScrollInfo(Handle, SB_VERT, FScrollInfo);
        case Message.WParamLo of
          SB_TOP:
            FScrollInfo.nPos := FScrollInfo.nMin;
          SB_BOTTOM:
            FScrollInfo.nPos := FScrollInfo.nMax;
          SB_PAGEUP:
            Dec(FScrollInfo.nPos, FScrollInfo.nPage);
          SB_PAGEDOWN:
            Inc(FScrollInfo.nPos, FScrollInfo.nPage);
          SB_LINEUP:
            Dec(FScrollInfo.nPos, FTagHeight);
          SB_LINEDOWN:
            Inc(FScrollInfo.nPos, FTagHeight);
          SB_THUMBTRACK:
            FScrollInfo.nPos := FScrollInfo.nTrackPos;
        end;

        FixPosAndScrollWindow;
        Message.result := 0;

      end;
  end;
end;

procedure TDTagEditor.FixPosAndScrollWindow;
begin
  FScrollInfo.fMask := SIF_POS;
  SetScrollInfo(Handle, SB_VERT, FScrollInfo, True);
  GetScrollInfo(Handle, SB_VERT, FScrollInfo);

  if FScrollInfo.nPos <> FPrevScrollPos then
  begin
    ScrollWindowEx(Handle, 0, FPrevScrollPos - FScrollInfo.nPos,
      GetShrunkClientRect(3), GetShrunkClientRect(3), 0, nil, SW_INVALIDATE);
    FPrevScrollPos := FScrollInfo.nPos;
    Update;
  end;
end;

procedure TDTagEditor.UpdateScrollBars;
begin
  FScrollInfo.fMask := SIF_RANGE or SIF_PAGE;
  FScrollInfo.nMin := 0;
  FScrollInfo.nMax := FDesiredHeight - 1;
  FScrollInfo.nPage := ClientHeight;
  SetScrollInfo(Handle, SB_VERT, FScrollInfo, True);
  FixPosAndScrollWindow;
end;

function TDTagEditor.Accept: Boolean;
begin
  if (FTags.Count = FMaxTags) and (FMaxTags > 0) then
    Exit(false);
  Assert(FEdit.Visible);
  result := false;
  if FTrimInput then
    FEdit.Text := Trim(FEdit.Text);
  if (FEdit.Text = '') or ((not AllowDuplicates) and
    (FTags.IndexOf(FEdit.Text) <> -1)) then
  begin
    beep;
    Exit;
  end;
  FTags.Add(FEdit.Text);
  UpdateMetrics;
  result := True;
  HideEditor;
  if Assigned(FTagAdded) then
    FTagAdded(Self);
  Invalidate;
end;

procedure TDTagEditor.EditKeyPress(Sender: TObject; var Key: Char);
begin

  if (Key = chr(VK_SPACE)) and (FEdit.Text = '') and FNoLeadingSpaceInput then
  begin
    Key := #0;
    Exit;
  end;

  if ((Key = chr(VK_SPACE)) and FSpaceAccepts) or
    ((Key = ',') and FCommaAccepts) or ((Key = ';') and FSemicolonAccepts) then
    Key := chr(VK_RETURN);

  case ord(Key) of
    VK_RETURN:
      begin
        Accept;
        ShowEditor;
        Key := #0;
      end;
    VK_BACK:
      begin
        if (FEdit.Text = '') and (FTags.Count > 0) then
        begin
          if Assigned(FBeforeTagRemove) then
            FBeforeTagRemove(Sender, FTags.Count - 1);
          FTags.Delete(FTags.Count - 1);
          if Assigned(FTagRemoved) then
            FTagRemoved(Sender, FTags.Count - 1);
          UpdateMetrics;
          Paint;
        end;
      end;
    VK_ESCAPE:
      begin
        HideEditor;
        Self.SetFocus;
        Key := #0;
      end;
  end;

end;

procedure TDTagEditor.DblClick;
begin
  if Assigned(FOnDblClick) then
    FOnDblClick(Self);
end;

destructor TDTagEditor.Destroy;
begin
  FTags.Free;
  FTags := nil;
  FPopupMenu.Free;
  FEdit.Free;
  FDeleteButtonIcon.Free;
  inherited;
end;

procedure TDTagEditor.HideEditor;
begin
  FEdit.Text := '';
  FEdit.Hide;
  // SetFocus;
end;

procedure TDTagEditor.KeyDown(var Key: word; Shift: TShiftState);
begin
  inherited;
  case Key of
    VK_END:
      ShowEditor;
    VK_DELETE:
      Perform(WM_CLEAR, 0, 0);
    VK_INSERT:
      Perform(WM_PASTE, 0, 0);
  end;
end;

procedure TDTagEditor.KeyPress(var Key: Char);
begin
  inherited;

  case Key of
    ^C:
      begin
        Perform(WM_COPY, 0, 0);
        Key := #0;
        Exit;
      end;
    ^X:
      begin
        Perform(WM_CUT, 0, 0);
        Key := #0;
        Exit;
      end;
    ^V:
      begin
        Perform(WM_PASTE, 0, 0);
        Key := #0;
        Exit;
      end;
  end;

  ShowEditor;
  FEdit.Perform(WM_CHAR, ord(Key), 0);
end;

procedure TDTagEditor.Loaded;
begin
  inherited;
  UpdateMetrics;
end;

function TDTagEditor.GetClickInfoAt(X, Y: integer): TClickInfo;
var
  i: integer;
begin
  result := NOWHERE;
  if (X >= FEditPos.X) and (Y >= FEditPos.Y) then
    Exit(EDITOR);

  for i := 0 to FTags.Count - 1 do
    if InRange(X, FLefts[i], FRights[i]) and InRange(Y, FTops[i], FBottoms[i])
    then
    begin
      result := i;
      if InRange(X, FCloseBtnLefts[i], FCloseBtnLefts[i] + FCloseBtnWidth) and
        InRange(Y, FCloseBtnTops[i], FCloseBtnTops[i] + FActualTagHeight) and
        not FShrunk then
        result := result or PART_REMOVE_BUTTON;
      break;
    end;
end;

function TDTagEditor.GetFontEdit: TFont;
begin
  result := FEdit.Font;
end;

function TDTagEditor.GetReadOnly: Boolean;
begin
  result := FReadOnly;
end;

function TDTagEditor.IsFirstOnRow(TagIndex: integer): Boolean;
begin
  result := (TagIndex = 0) or (FTops[TagIndex] > FTops[TagIndex - 1]);
end;

function TDTagEditor.IsLastOnRow(TagIndex: integer): Boolean;
begin
  result := (TagIndex = FTags.Count - 1) or
    (FTops[TagIndex] < FTops[TagIndex + 1]);
end;

function TDTagEditor.GetSeparatorIndexAt(X, Y: integer): integer;
var
  i: integer;
begin
  result := FTags.Count;
  Y := Max(Y, FSpacing + 1);
  for i := FTags.Count - 1 downto 0 do
  begin
    if Y < FTops[i] then
      Continue;
    if (IsLastOnRow(i) and (X >= FRights[i])) or
      ((X < FRights[i]) and (IsFirstOnRow(i) or (FRights[i - 1] < X))) then
    begin
      result := i;
      if (IsLastOnRow(i) and (X >= FRights[i])) then
        Inc(result);
      Exit;
    end;
  end;
end;

procedure TDTagEditor.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: integer);
begin
  Inc(Y, FScrollInfo.nPos);
  FMouseDownClickInfo := GetClickInfoAt(X, Y);
  if GetTagIndex(FMouseDownClickInfo) <> EDITOR then
    SetFocus;
end;

procedure TDTagEditor.CreateCaret;
begin
  if not FCaretVisible then
    FCaretVisible := Windows.CreateCaret(Handle, 0, 0, FActualTagHeight);
end;

procedure TDTagEditor.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style or WS_VSCROLL;
end;

function TDTagEditor.CreateTags(ATagEditor: TDTagEditor): TTags;
begin
  result := TTags.Create(ATagEditor, TTagItem);
end;

procedure TDTagEditor.DestroyCaret;
begin
  if not FCaretVisible then
    Exit;
  Windows.DestroyCaret;
  FCaretVisible := false;
end;

procedure TDTagEditor.MouseMove(Shift: TShiftState; X, Y: integer);
var
  SepIndex: integer;
begin
  inherited;

  Inc(Y, FScrollInfo.nPos);

  if IsKeyDown(VK_LBUTTON) and InRange(GetTagIndex(FMouseDownClickInfo),
    TAG_LOW, TAG_HIGH) and (FCanDragTags) then
  begin
    FDragging := True;
    Screen.Cursor := crDrag;
    SepIndex := GetSeparatorIndexAt(X, Y);
    CreateCaret;
    if SepIndex = FTags.Count then
      SetCaretPos(FLefts[SepIndex - 1] + FWidths[SepIndex - 1] + FSpacing div 2,
        FTops[SepIndex - 1] - FScrollInfo.nPos)
    else
      SetCaretPos(FLefts[SepIndex] - FSpacing div 2,
        FTops[SepIndex] - FScrollInfo.nPos);
    ShowCaret(Handle);
    Exit;
  end;

  case GetTagIndex(GetClickInfoAt(X, Y)) of
    NOWHERE:
      Cursor := crArrow;
    EDITOR:
      Cursor := crIBeam;
    TAG_LOW .. TAG_HIGH:
      Cursor := crHandPoint;
  end;

end;

procedure TDTagEditor.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: integer);
var
  pnt: TPoint;
  CanRemove: Boolean;
  ClickInfo: TClickInfo;
  i: word;
  p: cardinal;
  SepIndex: integer;
begin
  inherited;

  Inc(Y, FScrollInfo.nPos);

  if FDragging then
  begin
    DestroyCaret;
    FDragging := false;
    Screen.Cursor := crDefault;
    SepIndex := GetSeparatorIndexAt(X, Y);
    if not InRange(SepIndex, GetTagIndex(FMouseDownClickInfo),
      GetTagIndex(FMouseDownClickInfo) + 1) then
    begin
      FTags.Move(GetTagIndex(FMouseDownClickInfo),
        SepIndex - IfThen(SepIndex > GetTagIndex(FMouseDownClickInfo), 1, 0));
      UpdateMetrics;
      Paint;
    end;
    Exit;
  end;

  ClickInfo := GetClickInfoAt(X, Y);

  if ClickInfo <> FMouseDownClickInfo then
    Exit;

  i := GetTagIndex(ClickInfo);
  p := GetTagPart(ClickInfo);

  case i of
    EDITOR:
      ShowEditor;
    NOWHERE:
      ;
  else
    case Button of
      mbLeft:
        begin
          case p of
            PART_BODY:
              if Assigned(FTagClickEvent) then
                FTagClickEvent(Self, i, FTags.Items[i].Text);
            PART_REMOVE_BUTTON:
              begin
                if not FDeleteTagButton then
                  Exit;
                if Assigned(FOnRemoveConfirm) then
                begin
                  CanRemove := false;
                  FOnRemoveConfirm(Self, i, FTags.Items[i].Text, CanRemove);
                  if not CanRemove then
                    Exit;
                end;
                if Assigned(FBeforeTagRemove) then
                  FBeforeTagRemove(Self, i);
                FTags.Delete(i);
                if Assigned(FTagRemoved) then
                  FTagRemoved(Self, i);
                UpdateMetrics;
                Paint;
              end;
          end;
        end;
      mbRight:
        begin
          FPopupMenu.Items[0].Tag := i;
          pnt := ClientToScreen(Point(X, Y));
          FPopupMenu.Items[0].Caption := 'Delete tag "' + FTags.Items[i]
            .Text + '"';
          FPopupMenu.Popup(pnt.X, pnt.Y - FScrollInfo.nPos);
        end;
    end;
  end;

end;

procedure TDTagEditor.UpdateMetrics;
var
  i: integer;
  X, Y: integer;
  MeanWidth: integer;
  AdjustedFDesiredHeight: integer;
begin

  SetLength(FLefts, FTags.Count);
  SetLength(FRights, FTags.Count);
  SetLength(FTops, FTags.Count);
  SetLength(FBottoms, FTags.Count);
  SetLength(FWidths, FTags.Count);
  SetLength(FCloseBtnLefts, FTags.Count);
  SetLength(FCloseBtnTops, FTags.Count);
  FCloseBtnWidth := Canvas.TextWidth('×');
  FShrunk := false;

  FNumRows := 1;
  if FMultiLine then
  begin
    FActualTagHeight := FTagHeight;
    X := FSpacing;
    Y := FSpacing;
    for i := 0 to FTags.Count - 1 do
    begin
      FWidths[i] := Canvas.TextWidth(FTags.Items[i].Text +
        IfThen(DeleteTagButton, ' ×', '')) + 2 * FSpacing;
      FLefts[i] := X;
      FRights[i] := X + FWidths[i];
      FTops[i] := Y;
      FBottoms[i] := Y + FTagHeight;

      if X + FWidths[i] + FSpacing > ClientWidth then

      begin
        X := FSpacing;
        Inc(Y, FTagHeight + FSpacing);
        Inc(FNumRows);
        FLefts[i] := X;
        FRights[i] := X + FWidths[i];
        FTops[i] := Y;
        FBottoms[i] := Y + FTagHeight;
      end;

      FCloseBtnLefts[i] := X + FWidths[i] - FCloseBtnWidth - FSpacing;
      FCloseBtnTops[i] := Y;

      Inc(X, FWidths[i] + FSpacing);
    end;
  end
  else
  begin
    FActualTagHeight := ClientHeight - 2 * FSpacing;
    X := FSpacing;
    Y := FSpacing;
    for i := 0 to FTags.Count - 1 do
    begin
      FWidths[i] := Canvas.TextWidth(FTags.Items[i].Text +
        IfThen(DeleteTagButton, ' ×', '')) + 2 * FSpacing;
      FLefts[i] := X;
      FRights[i] := X + FWidths[i];
      FTops[i] := Y;
      FBottoms[i] := Y + FActualTagHeight;
      Inc(X, FWidths[i] + FSpacing);
      FCloseBtnLefts[i] := FRights[i] - FCloseBtnWidth - FSpacing;
      FCloseBtnTops[i] := Y;
    end;
    FShrunk := X + 64 { FEdit } > ClientWidth;
    if FShrunk then
    begin

      X := FSpacing;
      Y := FSpacing;
      for i := 0 to FTags.Count - 1 do
      begin
        FWidths[i] := Canvas.TextWidth(FTags.Items[i].Text) + 2 * FSpacing;
        FLefts[i] := X;
        FRights[i] := X + FWidths[i];
        FTops[i] := Y;
        FBottoms[i] := Y + FActualTagHeight;
        Inc(X, FWidths[i] + FSpacing);
        FCloseBtnLefts[i] := FRights[i] - FCloseBtnWidth - FSpacing;
        FCloseBtnTops[i] := Y;
      end;

      if X + 64 { FEdit } > ClientWidth then
      begin
        MeanWidth := (ClientWidth - 2 * FSpacing - 64 { FEdit } )
          div FTags.Count - FSpacing;
        X := FSpacing;
        for i := 0 to FTags.Count - 1 do
        begin
          FWidths[i] := Min(FWidths[i], MeanWidth);
          FLefts[i] := X;
          FRights[i] := X + FWidths[i];
          Inc(X, FWidths[i] + FSpacing);
        end;
      end;
    end;
  end;

  FEditPos := Point(FSpacing,
    FSpacing + (FActualTagHeight - FEdit.Height) div 2);
  if FTags.Count > 0 then
    FEditPos := Point(FRights[FTags.Count - 1] + FSpacing,
      FTops[FTags.Count - 1] + (FActualTagHeight - FEdit.Height) div 2);
  if FMultiLine and (FEditPos.X + 64 > ClientWidth) and (FTags.Count > 0) then
  begin
    FEditPos := Point(FSpacing, FTops[FTags.Count - 1] + FTagHeight + FSpacing +
      (FActualTagHeight - FEdit.Height) div 2);
    Inc(FNumRows);
  end;

  FDesiredHeight := FSpacing + FNumRows * (FTagHeight + FSpacing);
  AdjustedFDesiredHeight := Min(FDesiredHeight, FMaxHeight);
  if FMultiLine and FAutoHeight and (ClientHeight <> AdjustedFDesiredHeight)
  then
    ClientHeight := AdjustedFDesiredHeight;

  UpdateScrollBars;

end;

procedure TDTagEditor.Paint;
var
  i: integer;
  w: integer;
  X, Y: integer;
  R: TRect;
  S: string;
  clip: HRGN;
  Rgn: HRGN;
begin
  inherited;

  Canvas.Brush.Color := FBgColor;
  Canvas.Pen.Color := FBorderColor;
  Canvas.Rectangle(ClientRect);
  Canvas.Font.Assign(Self.Font);

  clip := CreateRectRgnIndirect(GetShrunkClientRect((3)));
  SelectClipRgn(Canvas.Handle, clip);
  DeleteObject(clip);
  for i := 0 to FTags.Count - 1 do
  begin
    X := FLefts[i];
    Y := FTops[i] - FScrollInfo.nPos;
    w := FWidths[i];
    R := Rect(X, Y, X + w, Y + FActualTagHeight);
    Canvas.Brush.Color := FTags.Items[i].FTagBgColor;
    Canvas.Pen.Color := FTags.Items[i].FTagBorderColor;
    Canvas.RoundRect(R, FTagRoundBorder, FTagRoundBorder);
    Canvas.Font.Color := FTags.Items[i].FTextColor;
    Canvas.Brush.Style := bsClear;
    R.Left := R.Left + FSpacing;
    S := FTags.Items[i].Text;
    if (not FShrunk) and (FDeleteTagButton) then
    begin
      if FDeleteButtonIcon.Empty then
        S := S + ' ×'
      else
        DrawIconEx(Canvas.Handle, FCloseBtnLefts[i], FCloseBtnTops[i] + 10,
          FDeleteButtonIcon.Handle, FDeleteButtonIcon.Width,
          FDeleteButtonIcon.Height, 0, DI_NORMAL, DI_NORMAL);
    end;

    DrawText(Canvas.Handle, PChar(S), -1, R, DT_SINGLELINE or DT_VCENTER or
      DT_LEFT or DT_END_ELLIPSIS or DT_NOPREFIX);
    Canvas.Brush.Style := bsSolid;
  end;

  if FEdit.Visible then
  begin
    FEdit.Left := FEditPos.X;
    FEdit.Top := FEditPos.Y - FScrollInfo.nPos;
    FEdit.Width := ClientWidth - FEdit.Left - FSpacing;
  end;

  SelectClipRgn(Canvas.Handle, 0);

  if Focused then
    DrawFocusRect;
end;

function TDTagEditor.GetShrunkClientRect(const Amount: integer): TRect;
begin
  result := Rect(Amount, Amount, ClientWidth - Amount, ClientHeight - Amount);
end;

procedure TDTagEditor.DrawFocusRect;
var
  R: TRect;
begin
  R := GetShrunkClientRect(2);
  SafeDrawFocusRect(Canvas.Handle, R);
end;

procedure TDTagEditor.SetAutoHeight(const Value: Boolean);
begin
  if FAutoHeight <> Value then
  begin
    FAutoHeight := Value;
    UpdateMetrics;
    Invalidate;
  end;
end;

procedure TDTagEditor.SetBgColor(const Value: TColor);
begin
  if FBgColor <> Value then
  begin
    FBgColor := Value;
    Invalidate;
  end;
end;

procedure TDTagEditor.SetBorderColor(const Value: TColor);
begin
  if FBorderColor <> Value then
  begin
    FBorderColor := Value;

  end;
end;

procedure TDTagEditor.SetButtonIcon(const Value: TIcon);
begin
  if Value <> nil then
  begin
    if (not(InRange(Value.Height, 8, 10))) and (not(InRange(Value.Width, 8, 10)))
    then
      Raise Exception.Create('O tamanho do ícone precisa ser 8x8 ou 10x10');
    FDeleteButtonIcon.Assign(Value);
  end;
end;

procedure TDTagEditor.SetCanDragTags(const Value: Boolean);
begin
  FCanDragTags := Value;
end;

procedure TDTagEditor.SetCloseTagButton(const Value: Boolean);
begin
  FDeleteTagButton := Value;
end;

procedure TDTagEditor.SetMaxHeight(const Value: integer);
begin
  if FMaxHeight <> Value then
  begin
    FMaxHeight := Value;
    UpdateMetrics;
    Invalidate;
  end;
end;

procedure TDTagEditor.SetMultiLine(const Value: Boolean);
begin
  if FMultiLine <> Value then
  begin
    FMultiLine := Value;
    UpdateMetrics;
    Invalidate;
  end;
end;

procedure TDTagEditor.SetPasteText(AText: string);
var
  LStrList: TStringList;
  i: integer;
  LTagConf: TTagItemConfig;
begin
  if AText = '' then
    Exit;
  LStrList := TStringList.Create;
  LTagConf.CanDeleteTag := FDeleteTagButton;
  LTagConf.TagBgColor := FTagBgColor;
  LTagConf.TagBorderColor := FTagBorderColor;
  LTagConf.TextColor := FTextColor;
  try
    LStrList.DelimitedText := AText;
    for i := 0 to LStrList.Count - 1 do
    begin
      FTags.Add(LTagConf, LStrList[i]);
    end;
  finally
    LStrList.Free;
    UpdateMetrics;
    Paint;
  end;
end;

procedure TDTagEditor.SetTags(const Value: TTags);
begin
  Tags.Assign(Value);
end;

procedure TDTagEditor.SetReadOnly(const Value: Boolean);
begin
  if FReadOnly <> Value then
  begin
    FReadOnly := Value;
    FEdit.ReadOnly := Value;
  end;
  FSavedReadOnly := FReadOnly;
end;

procedure TDTagEditor.SetTagBgColor(const Value: TColor);
begin
  if FTagBgColor <> Value then
  begin
    FTagBgColor := Value;
    Invalidate;
  end;
end;

procedure TDTagEditor.SetTagBorderColor(const Value: TColor);
begin
  if FTagBorderColor <> Value then
  begin
    FTagBorderColor := Value;
    Invalidate;
  end;
end;

procedure TDTagEditor.SetTagHeight(const Value: integer);
begin
  if FTagHeight <> Value then
  begin
    FTagHeight := Value;
    UpdateMetrics;
    Invalidate;
  end;
end;

procedure TDTagEditor.SetTagRoundBorder(const Value: integer);
begin
  if Value > 10 then
    FTagRoundBorder := 10
  else if Value < 0 then
    FTagRoundBorder := 0
  else
    FTagRoundBorder := Value;
end;

procedure TDTagEditor.SetTextColor(const Value: TColor);
begin
  if FTextColor <> Value then
  begin
    FTextColor := Value;
    Invalidate;
  end;
end;

procedure TDTagEditor.ShowEditor;
begin
  FEdit.Left := FEditPos.X;
  FEdit.Top := FEditPos.Y;
  FEdit.Width := ClientWidth - FEdit.Left - FSpacing;
  FEdit.Color := FEditorColor;
  FEdit.Text := '';
  FEdit.Show;
  FEdit.SetFocus;
end;

procedure TDTagEditor.SetSpacing(const Value: integer);
begin
  if FSpacing <> Value then
  begin
    FSpacing := Value;
    UpdateMetrics;
    Invalidate;
  end;
end;

{ TTags }

{ TTags }

function TTags.Add(AItemConfig: TTagItemConfig; AText: String = ''): TTagItem;
begin
  result := TTagItem(inherited Add);
  result.FText := AText;
  result.FCanDeleteTag := AItemConfig.CanDeleteTag;
  result.FTagBgColor := AItemConfig.TagBgColor;
  result.FTagBorderColor := AItemConfig.TagBorderColor;
  result.FTextColor := AItemConfig.TextColor;
  REsult.FTagValue:= AItemConfig.TagValue;
  FTagEditor.UpdateMetrics;
end;

function TTags.Add(AText: String): TTagItem;
begin
  result := TTagItem(inherited Add);
  result.FText := AText;
  result.FCanDeleteTag := FTagEditor.FDeleteTagButton;
  result.FTagBgColor := FTagEditor.FTagBgColor;
  result.FTagBorderColor := FTagEditor.FTagBorderColor;
  result.FTextColor := FTagEditor.FTextColor;
  FTagEditor.UpdateMetrics;
end;

constructor TTags.Create(ATagEditor: TDTagEditor;
  ATagsItemClass: TTagItemCLass);
begin
  inherited Create(ATagsItemClass);
  FTagEditor := ATagEditor;
end;

procedure TTags.DeleteAll;
var
  i: integer;
begin
  while Self.Count > 0 do
    Self.Delete(0);
  FTagEditor.UpdateMetrics;
  FTagEditor.Repaint;
end;

function TTags.DelimitedText: String;
var
  i: integer;
begin
  result := '';
  for i := 0 to Self.Count - 1 do
  begin
    result := result + IfThen(result <> '', ',') + Self.Items[i].Text;
  end;
end;

function TTags.GetOwner: TPersistent;
begin
  result := FTagEditor;
end;

function TTags.GetTagItem(Index: integer): TTagItem;
begin
  result := TTagItem(inherited Items[Index]);
end;

function TTags.IndexOf(AText: string): integer;
var
  Index: integer;
begin
  result := -1;
  for index := 0 to Self.Count - 1 do
  begin
    if Self.Items[index].Text = AText then
    begin
      result := index;
      break;
    end;
  end;
end;

procedure TTags.Move(CurIndex, NewIndex: integer);
var
  TempList: TList;
begin
  TempList := TCollectionHack(Self).FItems;
  TempList.Exchange(CurIndex, NewIndex);
end;

procedure TTags.SetTagItem(Index: integer; const Value: TTagItem);
begin
  Items[Index].Assign(Value);
end;

{ TTagItem }

procedure TTagItem.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
end;

constructor TTagItem.Create(Collection: TCollection);
var
  LTagEditor: TDTagEditor;
begin
  inherited Create(Collection);
  LTagEditor := GetTagEditor;
  FCanDeleteTag := GetTagEditor.DeleteTagButton;
  FTagBgColor := GetTagEditor.FTagBgColor;
  FTextColor := GetTagEditor.FTextColor;
end;

destructor TTagItem.Destroy;
begin
  inherited;
end;

function TTagItem.GetTagEditor: TDTagEditor;
begin
  if Assigned(Collection) and (Collection is TTags) then
    result := TTags(Collection).FTagEditor
  else
    result := nil;
end;

procedure TTagItem.SetCanDeleteTag(const Value: Boolean);
begin
  FCanDeleteTag := Value;
end;

procedure TTagItem.SetTagBgColor(const Value: TColor);
begin
  if FTagBgColor <> Value then
  begin
    FTagBgColor := Value;
  end;
end;

procedure TTagItem.SetTagBorderColor(const Value: TColor);
begin
  if FTagBorderColor <> Value then
  begin
    FTagBorderColor := Value;

  end;
end;

procedure TTagItem.SetTextColor(const Value: TColor);
begin
  if FTextColor <> Value then
  begin
    FTextColor := Value;

  end;
end;

initialization

Screen.Cursors[crHandPoint] := LoadCursor(0, IDC_HAND);

end.
