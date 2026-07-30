[CmdletBinding()]
param(
  [Parameter(Position = 0)]
  [string]$Message = '',

  [switch]$OpenActions
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

function Invoke-Git {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$Arguments
  )

  & git @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "Git 命令执行失败：git $($Arguments -join ' ')"
  }
}

try {
  Set-Location -LiteralPath $repoRoot

  if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw '未检测到 Git，请先安装 Git 并将其加入 PATH。'
  }

  & git rev-parse --is-inside-work-tree *> $null
  if ($LASTEXITCODE -ne 0) {
    throw "当前目录不是 Git 仓库：$repoRoot"
  }

  $branch = (& git branch --show-current).Trim()
  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($branch)) {
    throw '读取当前 Git 分支失败。'
  }

  Write-Host ''
  Write-Host '========================================' -ForegroundColor Cyan
  Write-Host ' Alexander Blog 一键更新' -ForegroundColor Cyan
  Write-Host '========================================' -ForegroundColor Cyan
  Write-Host "仓库：$repoRoot"
  Write-Host "分支：$branch"
  Write-Host ''

  Write-Host '[1/5] 查看本地修改...' -ForegroundColor Yellow
  & git status --short

  Write-Host ''
  Write-Host '[2/5] 同步 GitHub 最新代码...' -ForegroundColor Yellow
  Invoke-Git -Arguments @('pull', '--rebase', '--autostash', 'origin', $branch)

  $changes = @(& git status --porcelain)
  if ($LASTEXITCODE -ne 0) {
    throw '读取文件修改状态失败。'
  }

  if ($changes.Count -eq 0) {
    Write-Host ''
    Write-Host '[3/5] 没有需要提交的文件。' -ForegroundColor Green
    Write-Host '[4/5] 检查是否存在尚未推送的提交...' -ForegroundColor Yellow
    Invoke-Git -Arguments @('push', 'origin', $branch)
    Write-Host '[5/5] 已与 GitHub 保持同步。' -ForegroundColor Green
  }
  else {
    Write-Host ''
    Write-Host '[3/5] 添加全部修改...' -ForegroundColor Yellow
    Invoke-Git -Arguments @('add', '-A')

    if ([string]::IsNullOrWhiteSpace($Message)) {
      $Message = '更新博客 ' + (Get-Date -Format 'yyyy-MM-dd HH:mm')
    }

    Write-Host "[4/5] 创建提交：$Message" -ForegroundColor Yellow
    Invoke-Git -Arguments @('commit', '-m', $Message)

    Write-Host '[5/5] 推送到 GitHub...' -ForegroundColor Yellow
    Invoke-Git -Arguments @('push', 'origin', $branch)
  }

  $commit = (& git rev-parse --short HEAD).Trim()
  Write-Host ''
  Write-Host '更新完成！GitHub Pages 将自动部署。' -ForegroundColor Green
  Write-Host "提交：$commit"
  Write-Host '部署进度：https://github.com/Alexander17-yang/alexander/actions'
  Write-Host "网站：https://alexander17-yang.github.io/alexander/?v=$commit"

  if ($OpenActions) {
    Start-Process 'https://github.com/Alexander17-yang/alexander/actions'
  }

  exit 0
}
catch {
  Write-Host ''
  Write-Host "更新失败：$($_.Exception.Message)" -ForegroundColor Red
  Write-Host '请检查上方信息，处理冲突或网络问题后重新运行。' -ForegroundColor Red
  exit 1
}
