
param(
  [string]$OutDir = (Join-Path $PSScriptRoot '..\\screens'),
  [int]$Width = 720,
  [int]$Height = 1440
)

$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

function ColorFromHex {
  param([string]$Hex, [int]$Alpha = 255)
  $h = $Hex.TrimStart('#')
  $r = [Convert]::ToInt32($h.Substring(0, 2), 16)
  $g = [Convert]::ToInt32($h.Substring(2, 2), 16)
  $b = [Convert]::ToInt32($h.Substring(4, 2), 16)
  return [System.Drawing.Color]::FromArgb($Alpha, $r, $g, $b)
}

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

function DrawScreen {
  param(
    [string]$FileName,
    [string]$TabLabel,
    [string]$Title,
    [string]$Subtitle,
    [string]$Emoji,
    [string]$AccentHex
  )

  $bitmap = New-Object System.Drawing.Bitmap($Width, $Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($bitmap)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

  try {
    $bgRect = [System.Drawing.Rectangle]::new(0, 0, $Width, $Height)
    $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
      $bgRect,
      (ColorFromHex '#F8FAFC'),
      (ColorFromHex '#EFF6FF'),
      90
    )
    $g.FillRectangle($bgBrush, $bgRect)

    $topH = 160
    $topRect = [System.Drawing.Rectangle]::new(0, 0, $Width, $topH)
    $topBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
      $topRect,
      (ColorFromHex $AccentHex 255),
      (ColorFromHex '#0EA5E9' 255),
      0
    )
    $g.FillRectangle($topBrush, $topRect)

    $fontFamily = 'Malgun Gothic'
    $fallbackFamily = 'Segoe UI'
    try { $h1 = New-Object System.Drawing.Font($fontFamily, 34, [System.Drawing.FontStyle]::Bold) }
    catch { $h1 = New-Object System.Drawing.Font($fallbackFamily, 34, [System.Drawing.FontStyle]::Bold) }
    try { $h2 = New-Object System.Drawing.Font($fontFamily, 18, [System.Drawing.FontStyle]::Regular) }
    catch { $h2 = New-Object System.Drawing.Font($fallbackFamily, 18, [System.Drawing.FontStyle]::Regular) }
    try { $tabFont = New-Object System.Drawing.Font($fontFamily, 16, [System.Drawing.FontStyle]::Bold) }
    catch { $tabFont = New-Object System.Drawing.Font($fallbackFamily, 16, [System.Drawing.FontStyle]::Bold) }
    try { $small = New-Object System.Drawing.Font($fontFamily, 14, [System.Drawing.FontStyle]::Regular) }
    catch { $small = New-Object System.Drawing.Font($fallbackFamily, 14, [System.Drawing.FontStyle]::Regular) }

    $white = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $white70 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(210, 255, 255, 255))
    $textDark = New-Object System.Drawing.SolidBrush((ColorFromHex '#0F172A'))
    $muted = New-Object System.Drawing.SolidBrush((ColorFromHex '#475569'))

    # Header text
    $g.DrawString('FinMVP', $tabFont, $white70, 28, 22)
    $g.DrawString($TabLabel, $tabFont, $white, ($Width - 28 - 60), 22)
    $g.DrawString($Title, $h1, $white, 28, 64)
    $g.DrawString($Subtitle, $h2, $white70, 28, 116)

    # Tabs
    $tabY = $topH + 26
    $tabs = @('홈', '영상', '퀴즈', '투자', '결과')
    $x = 24
    foreach ($t in $tabs) {
      $w = 92
      $rect = [System.Drawing.Rectangle]::new($x, $tabY, $w, 44)
      $path = New-RoundedRectPath -X $rect.X -Y $rect.Y -Width $rect.Width -Height $rect.Height -Radius 22
      if ($t -eq $TabLabel) {
        $pillBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 37, 99, 235))
        $g.FillPath($pillBrush, $path)
        $g.DrawString($t, $tabFont, $white, ($x + 24), ($tabY + 10))
        $pillBrush.Dispose()
      } else {
        $pillBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(235, 255, 255, 255))
        $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(40, 15, 23, 42), 1)
        $g.FillPath($pillBrush, $path)
        $g.DrawPath($borderPen, $path)
        $g.DrawString($t, $tabFont, $muted, ($x + 24), ($tabY + 10))
        $pillBrush.Dispose()
        $borderPen.Dispose()
      }
      $path.Dispose()
      $x += ($w + 10)
      if ($x + $w -gt $Width) { break }
    }

    # Main card
    $cardX = 24
    $cardY = $tabY + 70
    $cardW = $Width - 48
    $cardH = 720
    $cardRect = [System.Drawing.Rectangle]::new($cardX, $cardY, $cardW, $cardH)
    $cardPath = New-RoundedRectPath -X $cardRect.X -Y $cardRect.Y -Width $cardRect.Width -Height $cardRect.Height -Radius 28
    $shadowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(22, 2, 6, 23))
    $shadowPath = New-RoundedRectPath -X ($cardRect.X + 4) -Y ($cardRect.Y + 10) -Width $cardRect.Width -Height $cardRect.Height -Radius 30
    $g.FillPath($shadowBrush, $shadowPath)
    $shadowPath.Dispose()
    $shadowBrush.Dispose()

    $cardBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(245, 255, 255, 255))
    $g.FillPath($cardBrush, $cardPath)
    $cardBrush.Dispose()

    # Icon tile
    $tileRect = [System.Drawing.Rectangle]::new(($cardX + 34), ($cardY + 52), 140, 140)
    $tilePath = New-RoundedRectPath -X $tileRect.X -Y $tileRect.Y -Width $tileRect.Width -Height $tileRect.Height -Radius 34
    $tileBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 37, 99, 235))
    $g.FillPath($tileBrush, $tilePath)
    $tileBrush.Dispose()
    $tilePath.Dispose()

    try { $emojiFont = New-Object System.Drawing.Font($fontFamily, 56, [System.Drawing.FontStyle]::Regular) }
    catch { $emojiFont = New-Object System.Drawing.Font($fallbackFamily, 56, [System.Drawing.FontStyle]::Regular) }
    $g.DrawString($Emoji, $emojiFont, $textDark, ($tileRect.X + 36), ($tileRect.Y + 34))

    # Card text
    $g.DrawString($Title, (New-Object System.Drawing.Font($fontFamily, 28, [System.Drawing.FontStyle]::Bold)), $textDark, ($cardX + 34), ($cardY + 220))
    $g.DrawString($Subtitle, (New-Object System.Drawing.Font($fontFamily, 18, [System.Drawing.FontStyle]::Regular)), $muted, ($cardX + 34), ($cardY + 270))

    # Simple chips
    $chipY = $cardY + 332
    $chips = @(
      '핵심만 짧게',
      '즉시 확인',
      '경험으로 이해'
    )
    $chipX = $cardX + 34
    foreach ($c in $chips) {
      $tw = [Math]::Min(220, [int]($c.Length * 18) + 60)
      $r = [System.Drawing.Rectangle]::new($chipX, $chipY, $tw, 42)
      $p = New-RoundedRectPath -X $r.X -Y $r.Y -Width $r.Width -Height $r.Height -Radius 21
      $b = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(235, 239, 246, 255))
      $g.FillPath($b, $p)
      $g.DrawString($c, $small, $muted, ($chipX + 18), ($chipY + 11))
      $b.Dispose()
      $p.Dispose()
      $chipY += 52
    }

    # Footer line
    $g.DrawString('베타 화면 예시 · 실제 UI는 변경될 수 있어요', $small, $muted, 28, ($Height - 54))

    if (!(Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }
    $outPath = Join-Path $OutDir $FileName
    $bitmap.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Host "Wrote $outPath"
  }
  finally {
    $g.Dispose()
    $bitmap.Dispose()
  }
}

DrawScreen -FileName 'home.png' -TabLabel '홈' -Title '홈 화면' -Subtitle '오늘의 추천 학습과 진도를 한눈에' -Emoji '🏠' -AccentHex '#2563EB'
DrawScreen -FileName 'video.png' -TabLabel '영상' -Title '5분 금융 영상' -Subtitle '핵심만 빠르게 배우는 마이크로 러닝' -Emoji '🎬' -AccentHex '#2563EB'
DrawScreen -FileName 'quiz.png' -TabLabel '퀴즈' -Title '개념 확인 퀴즈' -Subtitle '바로 풀어보며 이해도를 체크' -Emoji '❓' -AccentHex '#0EA5E9'
DrawScreen -FileName 'invest.png' -TabLabel '투자' -Title '모의 투자' -Subtitle '가상의 자산으로 선택하고 결과를 경험' -Emoji '🪙' -AccentHex '#2563EB'
DrawScreen -FileName 'result.png' -TabLabel '결과' -Title '결과 분석' -Subtitle '왜 그런 결과가 나왔는지 쉽게 설명' -Emoji '📈' -AccentHex '#0EA5E9'

