param(
  [string]$OutPath = (Join-Path $PSScriptRoot '..\\social-preview.png')
)

$ErrorActionPreference = 'Stop'


Add-Type -AssemblyName System.Drawing

function New-RoundedRectPath {
  param(
    [int]$X,
    [int]$Y,
    [int]$Width,
    [int]$Height,
    [int]$Radius
  )
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $diameter = [Math]::Max(1, $Radius * 2)
  $arc = [System.Drawing.Rectangle]::new($X, $Y, $diameter, $diameter)

  $path.AddArc($arc, 180, 90)
  $arc.X = $X + $Width - $diameter
  $path.AddArc($arc, 270, 90)
  $arc.Y = $Y + $Height - $diameter
  $path.AddArc($arc, 0, 90)
  $arc.X = $X
  $path.AddArc($arc, 90, 90)
  $path.CloseFigure()
  return $path
}

function ColorFromHex {
  param([string]$Hex, [int]$Alpha = 255)
  $h = $Hex.TrimStart('#')
  $r = [Convert]::ToInt32($h.Substring(0, 2), 16)
  $g = [Convert]::ToInt32($h.Substring(2, 2), 16)
  $b = [Convert]::ToInt32($h.Substring(4, 2), 16)
  return [System.Drawing.Color]::FromArgb($Alpha, $r, $g, $b)
}

$width = 1200
$height = 630
$bitmap = New-Object System.Drawing.Bitmap($width, $height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

try {
  $bgRect = [System.Drawing.Rectangle]::new(0, 0, $width, $height)
  $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $bgRect,
    (ColorFromHex '#EFF6FF'),
    (ColorFromHex '#DBEAFE'),
    45
  )
  $graphics.FillRectangle($bgBrush, $bgRect)

  $circle1Brush = New-Object System.Drawing.SolidBrush((ColorFromHex '#DBEAFE' 150))
  $graphics.FillEllipse($circle1Brush, 30, -20, 240, 240)
  $circle2Brush = New-Object System.Drawing.SolidBrush((ColorFromHex '#BAE6FD' 120))
  $graphics.FillEllipse($circle2Brush, 940, 420, 280, 280)

  $cardX = 120
  $cardY = 110
  $cardW = 960
  $cardH = 410
  $cardR = 32

  for ($i = 0; $i -lt 10; $i++) {
    $alpha = 18 - ($i * 1)
    if ($alpha -lt 0) { $alpha = 0 }
    $shadowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb($alpha, 30, 41, 59))
    $shadowPath = New-RoundedRectPath -X ($cardX + 4) -Y ($cardY + 18) -Width $cardW -Height $cardH -Radius ($cardR + $i)
    $graphics.FillPath($shadowBrush, $shadowPath)
    $shadowPath.Dispose()
    $shadowBrush.Dispose()
  }

  $cardBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
  $cardPath = New-RoundedRectPath -X $cardX -Y $cardY -Width $cardW -Height $cardH -Radius $cardR
  $graphics.FillPath($cardBrush, $cardPath)

  $fontFamily = 'Malgun Gothic'
  $fallbackFamily = 'Segoe UI'

  try { $logoFont = New-Object System.Drawing.Font($fontFamily, 20, [System.Drawing.FontStyle]::Bold) }
  catch { $logoFont = New-Object System.Drawing.Font($fallbackFamily, 20, [System.Drawing.FontStyle]::Bold) }

  try { $kickerFont = New-Object System.Drawing.Font($fontFamily, 14, [System.Drawing.FontStyle]::Regular) }
  catch { $kickerFont = New-Object System.Drawing.Font($fallbackFamily, 14, [System.Drawing.FontStyle]::Regular) }

  try { $titleFont = New-Object System.Drawing.Font($fontFamily, 40, [System.Drawing.FontStyle]::Bold) }
  catch { $titleFont = New-Object System.Drawing.Font($fallbackFamily, 40, [System.Drawing.FontStyle]::Bold) }

  try { $subTitleFont = New-Object System.Drawing.Font($fontFamily, 28, [System.Drawing.FontStyle]::Bold) }
  catch { $subTitleFont = New-Object System.Drawing.Font($fallbackFamily, 28, [System.Drawing.FontStyle]::Bold) }

  try { $descFont = New-Object System.Drawing.Font($fontFamily, 18, [System.Drawing.FontStyle]::Regular) }
  catch { $descFont = New-Object System.Drawing.Font($fallbackFamily, 18, [System.Drawing.FontStyle]::Regular) }

  try { $chipFont = New-Object System.Drawing.Font($fontFamily, 14, [System.Drawing.FontStyle]::Regular) }
  catch { $chipFont = New-Object System.Drawing.Font($fallbackFamily, 14, [System.Drawing.FontStyle]::Regular) }

  try { $ctaFont = New-Object System.Drawing.Font($fontFamily, 18, [System.Drawing.FontStyle]::Bold) }
  catch { $ctaFont = New-Object System.Drawing.Font($fallbackFamily, 18, [System.Drawing.FontStyle]::Bold) }

  $textX = 170
  $textY = 120

  $pillRect = [System.Drawing.Rectangle]::new($textX, ($textY + 40), 250, 34)
  $pillPath = New-RoundedRectPath -X $pillRect.X -Y $pillRect.Y -Width $pillRect.Width -Height $pillRect.Height -Radius 17
  $pillBrush = New-Object System.Drawing.SolidBrush((ColorFromHex '#F3F4F6' 230))
  $graphics.FillPath($pillBrush, $pillPath)
  $pillDotBrush = New-Object System.Drawing.SolidBrush((ColorFromHex '#2563EB'))
  $graphics.FillEllipse($pillDotBrush, $pillRect.X + 14, $pillRect.Y + 12, 10, 10)
  $pillTextBrush = New-Object System.Drawing.SolidBrush((ColorFromHex '#0F172A' 210))
  $graphics.DrawString('중학생을 위한 금융 학습', $kickerFont, $pillTextBrush, ($pillRect.X + 34), ($pillRect.Y + 8))

  $logoSquareRect = [System.Drawing.Rectangle]::new($textX, $textY, 34, 34)
  $logoGrad = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $logoSquareRect,
    (ColorFromHex '#2563EB'),
    (ColorFromHex '#0EA5E9'),
    0
  )
  $logoSquarePath = New-RoundedRectPath -X $logoSquareRect.X -Y $logoSquareRect.Y -Width $logoSquareRect.Width -Height $logoSquareRect.Height -Radius 10
  $graphics.FillPath($logoGrad, $logoSquarePath)
  $logoTextBrush = New-Object System.Drawing.SolidBrush((ColorFromHex '#0F172A'))
  $graphics.DrawString('FinMVP', $logoFont, $logoTextBrush, ($textX + 46), ($textY + 3))

  $titleBrush = New-Object System.Drawing.SolidBrush((ColorFromHex '#0F172A'))
  $graphics.DrawString('중학생 금융 학습 플랫폼', $titleFont, $titleBrush, $textX, ($textY + 110))
  $graphics.DrawString('5분 금융 학습 + 투자 시뮬레이션', $subTitleFont, $titleBrush, $textX, ($textY + 165))

  $descBrush = New-Object System.Drawing.SolidBrush((ColorFromHex '#475569'))
  $graphics.DrawString('외우는 금융이 아니라, 경험하는 금융', $descFont, $descBrush, $textX, ($textY + 220))

  $chip1Rect = [System.Drawing.Rectangle]::new($textX, ($textY + 270), 360, 36)
  $chip1Path = New-RoundedRectPath -X $chip1Rect.X -Y $chip1Rect.Y -Width $chip1Rect.Width -Height $chip1Rect.Height -Radius 18
  $chip1Brush = New-Object System.Drawing.SolidBrush((ColorFromHex '#EFF6FF'))
  $graphics.FillPath($chip1Brush, $chip1Path)
  $chip1DotBrush = New-Object System.Drawing.SolidBrush((ColorFromHex '#2563EB'))
  $graphics.FillEllipse($chip1DotBrush, ($chip1Rect.X + 12), ($chip1Rect.Y + 11), 14, 14)
  $checkPen = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 2)
  $graphics.DrawLines($checkPen, @(
    ([System.Drawing.Point]::new(($chip1Rect.X + 16), ($chip1Rect.Y + 18))),
    ([System.Drawing.Point]::new(($chip1Rect.X + 19), ($chip1Rect.Y + 21))),
    ([System.Drawing.Point]::new(($chip1Rect.X + 25), ($chip1Rect.Y + 15)))
  ))
  $chipTextBrush = New-Object System.Drawing.SolidBrush((ColorFromHex '#1F2937'))
  $graphics.DrawString('5~10분 짧은 학습 콘텐츠', $chipFont, $chipTextBrush, ($chip1Rect.X + 36), ($chip1Rect.Y + 10))

  $chip2Rect = [System.Drawing.Rectangle]::new($textX, ($textY + 316), 320, 36)
  $chip2Path = New-RoundedRectPath -X $chip2Rect.X -Y $chip2Rect.Y -Width $chip2Rect.Width -Height $chip2Rect.Height -Radius 18
  $chip2Brush = New-Object System.Drawing.SolidBrush((ColorFromHex '#ECFEFF'))
  $graphics.FillPath($chip2Brush, $chip2Path)
  $chip2DotBrush = New-Object System.Drawing.SolidBrush((ColorFromHex '#0EA5E9'))
  $graphics.FillEllipse($chip2DotBrush, ($chip2Rect.X + 12), ($chip2Rect.Y + 11), 14, 14)
  $graphics.DrawLines($checkPen, @(
    ([System.Drawing.Point]::new(($chip2Rect.X + 16), ($chip2Rect.Y + 18))),
    ([System.Drawing.Point]::new(($chip2Rect.X + 19), ($chip2Rect.Y + 21))),
    ([System.Drawing.Point]::new(($chip2Rect.X + 25), ($chip2Rect.Y + 15)))
  ))
  $graphics.DrawString('투자 시뮬레이션 미니게임', $chipFont, $chipTextBrush, ($chip2Rect.X + 36), ($chip2Rect.Y + 10))

  $ctaRect = [System.Drawing.Rectangle]::new($textX, ($textY + 380), 300, 50)
  $ctaPath = New-RoundedRectPath -X $ctaRect.X -Y $ctaRect.Y -Width $ctaRect.Width -Height $ctaRect.Height -Radius 25
  $ctaGrad = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $ctaRect,
    (ColorFromHex '#2563EB'),
    (ColorFromHex '#0EA5E9'),
    0
  )
  $graphics.FillPath($ctaGrad, $ctaPath)
  $ctaTextBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
  $graphics.DrawString('베타 테스트 신청하기', $ctaFont, $ctaTextBrush, ($ctaRect.X + 28), ($ctaRect.Y + 14))

  $bitmap.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Png)
  Write-Host "Wrote $OutPath"
}
finally {
  $graphics.Dispose()
  $bitmap.Dispose()
}



