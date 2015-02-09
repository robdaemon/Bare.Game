program game;

{$mode delphi}

uses
  Bare.System,
  Bare.Game,
  Bare.Geometry,
  Bare.Graphics,
  Bare.Example,
  Bare.Interop.OpenGL;

{ TDrawExample }

type
  TDrawExample = class(TWorldWindow)
	private
    FBackground: TBackgroudSprite;
    FSprite: TSprite;
    FDrawing: Boolean;
    FX, FY: Float;
    FPerspectiveView: Boolean;
    FPerspectiveTime: Float;
    FPerspectiveFactor: Float;
  protected
    procedure RenderInitialize; override;
    procedure RenderFinalize; override;
    procedure Logic(Stopwatch: TStopwatch); override;
    procedure Render(Stopwatch: TStopwatch); override;
  end;

procedure TDrawExample.RenderInitialize;
begin
  inherited RenderInitialize;
  { We're drawing our own cursor }
  Mouse.Visible := False;
  { Setup our pen }
  Pen.Color := clHotPink;
  Pen.Width := 10;
  { Make room for 2 images }
  Textures.Generate(2);
  Textures.Load('background.jpg', 0);
  Textures.Load('cursor.png', 1);
  { If you create it }
  FBackground := TBackgroudSprite.Create(World);
  FBackground.Texture := Textures[0];
  FBackground.Origin := Vec(0, 0);
  FSprite := TSprite.Create(World);
  FSprite.Texture := Textures[1];
  FSprite.Size := Vec(100, 148);
  FSprite.Origin := Vec(0.2, 0.1);
end;

procedure TDrawExample.RenderFinalize;
begin
  { You must destroy it }
  FSprite.Free;
  FBackground.Free;
  inherited RenderFinalize;
end;

procedure TDrawExample.Logic(Stopwatch: TStopwatch);
begin
  { Place your game logic code here }
  if (Keyboard.Key[VK_F2]) and (not FPerspectiveView) then
  begin
		FPerspectiveView := True;
    FPerspectiveTime := Stopwatch.Time;
  end;
  if (Keyboard.Key[VK_F3]) and FPerspectiveView then
  begin
		FPerspectiveView := False;
    FPerspectiveTime := Stopwatch.Time;
  end;
  if FPerspectiveView then
  begin
	  FPerspectiveFactor := (Stopwatch.Time - FPerspectiveTime) / 3;
  	if FPerspectiveFactor > 1 then
	  	FPerspectiveFactor := 1;
  end
  else if FPerspectiveFactor > 0 then
  begin
	  FPerspectiveFactor := (Stopwatch.Time - FPerspectiveTime) / 3;
  	if FPerspectiveFactor > 1 then
	  	FPerspectiveFactor := 1;
    FPerspectiveFactor := 1 - FPerspectiveFactor;
  end;
  { Draw when the left mouse button is down }
  if mbLeft in Mouse.Buttons then
	begin
    if not FDrawing then
    begin
			Canvas.Path.Clear;
	  	Canvas.Path.MoveTo(Mouse.X, Mouse.Y)
    end
    else if (Mouse.X <> FX) or (Mouse.Y <> FY) then
			Canvas.Path.LineTo(Mouse.X, Mouse.Y);
    FDrawing := True;
  end
  else
    FDrawing := False;
	FX := Mouse.X;
	FY := Mouse.Y;
end;

procedure TDrawExample.Render(Stopwatch: TStopwatch);
const
  Status = 'Time: %.2f'#13#10'FPS: %d';
  Help = 'Press ESC to terminate - F1 Fullscreen toggle'#13#10 +
  	'F2 Perspective view - F3 Orthographic view';
begin
  { Place your game render code here }
  World.Update;
  { You can mix in opengl code if you want }
 	glRotatef(20 * FPerspectiveFactor, 0, 1, 0);
  glRotatef(20 * FPerspectiveFactor, 1, 0, 0);
  glTranslatef(10 * FPerspectiveFactor, -8 * FPerspectiveFactor, -4 * FPerspectiveFactor);
  { Make our background fill the world }
  FBackground.Size.X := World.Width;
  FBackground.Size.Y := World.Height;
  FBackground.Draw;
  { Stroke the current path }
  Canvas.Stroke(Pen, False);
  { Move the cursor sprite around }
  FSprite.Position := Vec(FX, FY, 0);
  FSprite.Rotation.Z := Sin(Stopwatch.Time * 4) * 20;
  FSprite.Draw;
  { Write some text }
  Font.Write(Format(Status, [Stopwatch.Time, Stopwatch.Framerate]), 1, 1, 0);
  Font.Write(Help, 0.75, World.Width / 2, World.Height - 50, justifyCenter);
end;

begin
  Application.Run(TDrawExample);
end.

