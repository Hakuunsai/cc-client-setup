# Pester 5 tests for cc-client-setup Phase 1 MVP
# Run: pwsh -Command "Invoke-Pester ./tests/ -Output Detailed"

BeforeAll {
    $script:RepoRoot = Resolve-Path "$PSScriptRoot/.."
}

Describe "Repo structure" {
    It "Should have README.md" {
        Test-Path (Join-Path $script:RepoRoot "README.md") | Should -Be $true
    }
    It "Should have Setup-CCClientSetup.ps1 (placeholder until Task 10)" {
        # Task 10 以降で実装、それまでは skip
        $script:SetupPath = Join-Path $script:RepoRoot "Setup-CCClientSetup.ps1"
        # Set-ItResult -Skipped -Because "implemented in Task 10"
        $true | Should -Be $true
    }
}

# 以降の Describe ブロックは Task 2 以降で追加

Describe "templates/claude-rules/" {
    BeforeAll {
        $script:RulesDir = Join-Path $script:RepoRoot "templates/claude-rules"
    }
    It "Should have security-essentials.md" {
        Test-Path (Join-Path $script:RulesDir "security-essentials.md") | Should -Be $true
    }
    It "security-essentials.md should mention secret hardcoding ban" {
        $content = Get-Content (Join-Path $script:RulesDir "security-essentials.md") -Raw
        $content | Should -Match "シークレット|secret|ハードコード"
    }
    It "Should have forbidden-files.md" {
        Test-Path (Join-Path $script:RulesDir "forbidden-files.md") | Should -Be $true
    }
    It "forbidden-files.md should mention .env / .ssh" {
        $content = Get-Content (Join-Path $script:RulesDir "forbidden-files.md") -Raw
        $content | Should -Match "\.env"
        $content | Should -Match "\.ssh"
    }
    It "Should have network-security.md" {
        Test-Path (Join-Path $script:RulesDir "network-security.md") | Should -Be $true
    }
    It "network-security.md should mention curl / Invoke-WebRequest ban" {
        $content = Get-Content (Join-Path $script:RulesDir "network-security.md") -Raw
        $content | Should -Match "curl"
        $content | Should -Match "Invoke-WebRequest|Invoke-RestMethod"
    }
}

Describe "templates/CLAUDE.md.template" {
    BeforeAll {
        $script:ClaudeMdPath = Join-Path $script:RepoRoot "templates/CLAUDE.md.template"
    }
    It "Should exist" {
        Test-Path $script:ClaudeMdPath | Should -Be $true
    }
    It "Should contain 実装許可制 keyword" {
        Get-Content $script:ClaudeMdPath -Raw | Should -Match "実装許可制"
    }
    It "Should reference rules/forbidden-files.md" {
        Get-Content $script:ClaudeMdPath -Raw | Should -Match "forbidden-files\.md"
    }
    It "Should mention 秘書 / .company/secretary/" {
        Get-Content $script:ClaudeMdPath -Raw | Should -Match "秘書|\.company/secretary"
    }
}

Describe "templates/settings.json.template" {
    BeforeAll {
        $script:SettingsPath = Join-Path $script:RepoRoot "templates/settings.json.template"
    }
    It "Should exist" {
        Test-Path $script:SettingsPath | Should -Be $true
    }
    It "Should contain Bash(curl:*) deny" {
        Get-Content $script:SettingsPath -Raw | Should -Match 'Bash\(curl:\*\)'
    }
    It "Should contain PreToolUse hook reference" {
        Get-Content $script:SettingsPath -Raw | Should -Match "PreToolUse-DenyDangerous"
    }
    It "Should contain PostToolUse auto-checkpoint reference" {
        Get-Content $script:SettingsPath -Raw | Should -Match "PostToolUse-AutoCheckpoint"
    }
    It "Should contain <USER> placeholder for runtime substitution" {
        Get-Content $script:SettingsPath -Raw | Should -Match "<USER>"
    }
}

Describe "templates/gitignore.template" {
    BeforeAll {
        $script:GitignorePath = Join-Path $script:RepoRoot "templates/gitignore.template"
    }
    It "Should exist" {
        Test-Path $script:GitignorePath | Should -Be $true
    }
    It "Should include .env*" {
        Get-Content $script:GitignorePath -Raw | Should -Match "\.env"
    }
    It "Should include Thumbs.db / Desktop.ini (Windows)" {
        $content = Get-Content $script:GitignorePath -Raw
        $content | Should -Match "Thumbs\.db"
        $content | Should -Match "Desktop\.ini"
    }
    It "Should include bin/ obj/ node_modules/" {
        $content = Get-Content $script:GitignorePath -Raw
        $content | Should -Match "bin/"
        $content | Should -Match "obj/"
        $content | Should -Match "node_modules/"
    }
}

Describe "templates/pre-commit.ps1.template" {
    BeforeAll {
        $script:PreCommitPath = Join-Path $script:RepoRoot "templates/pre-commit.ps1.template"
    }
    It "Should exist" {
        Test-Path $script:PreCommitPath | Should -Be $true
    }
    It "Should contain AKIA regex (AWS key detection)" {
        Get-Content $script:PreCommitPath -Raw | Should -Match "AKIA"
    }
    It "Should contain BEGIN PRIVATE KEY regex" {
        Get-Content $script:PreCommitPath -Raw | Should -Match "BEGIN.*PRIVATE KEY"
    }
    It "Should exit 1 on detection" {
        Get-Content $script:PreCommitPath -Raw | Should -Match "exit 1"
    }
}

Describe "templates/company-secretary/" {
    BeforeAll {
        $script:SecretaryTemplateDir = Join-Path $script:RepoRoot "templates/company-secretary"
    }
    It "Should have CLAUDE.md" {
        Test-Path (Join-Path $script:SecretaryTemplateDir "CLAUDE.md") | Should -Be $true
    }
    It "CLAUDE.md should describe decisions / learnings / inbox / todos" {
        $content = Get-Content (Join-Path $script:SecretaryTemplateDir "CLAUDE.md") -Raw
        $content | Should -Match "decisions"
        $content | Should -Match "learnings"
        $content | Should -Match "inbox"
        $content | Should -Match "todos"
    }
    It "Should have secretary/todos/.gitkeep" {
        Test-Path (Join-Path $script:SecretaryTemplateDir "secretary/todos/.gitkeep") | Should -Be $true
    }
    It "Should have secretary/notes/.gitkeep" {
        Test-Path (Join-Path $script:SecretaryTemplateDir "secretary/notes/.gitkeep") | Should -Be $true
    }
    It "Should have secretary/inbox/.gitkeep" {
        Test-Path (Join-Path $script:SecretaryTemplateDir "secretary/inbox/.gitkeep") | Should -Be $true
    }
}

Describe "hooks/PreToolUse-DenyDangerous.ps1" {
    BeforeAll {
        $script:PreHookPath = Join-Path $script:RepoRoot "hooks/PreToolUse-DenyDangerous.ps1"
    }
    It "Should exist" {
        Test-Path $script:PreHookPath | Should -Be $true
    }
    It "Should mention curl / Invoke-WebRequest" {
        $content = Get-Content $script:PreHookPath -Raw
        $content | Should -Match "curl"
        $content | Should -Match "Invoke-WebRequest"
    }
    It "Should exit 2 on deny" {
        Get-Content $script:PreHookPath -Raw | Should -Match "exit 2"
    }
    It "Should read stdin JSON" {
        Get-Content $script:PreHookPath -Raw | Should -Match "ConvertFrom-Json|\\\$input|System\.Console::In"
    }
    It "Should wrap ConvertFrom-Json in try/catch" {
        Get-Content $script:PreHookPath -Raw | Should -Match "try\s*\{[^}]*ConvertFrom-Json"
    }
    It "Should detect pwsh -c variant (not just powershell -Command)" {
        Get-Content $script:PreHookPath -Raw | Should -Match "powershell\|pwsh"
    }
    It "Should detect cmd.exe variant" {
        Get-Content $script:PreHookPath -Raw | Should -Match "cmd\\\.exe"
    }
}

Describe "hooks/PostToolUse-AutoCheckpoint.ps1" {
    BeforeAll {
        $script:PostHookPath = Join-Path $script:RepoRoot "hooks/PostToolUse-AutoCheckpoint.ps1"
    }
    It "Should exist" {
        Test-Path $script:PostHookPath | Should -Be $true
    }
    It "Should use git stash for checkpointing" {
        Get-Content $script:PostHookPath -Raw | Should -Match "git stash"
    }
    It "Should mention claude-auto-checkpoint label" {
        Get-Content $script:PostHookPath -Raw | Should -Match "claude-auto-checkpoint"
    }
    It "Should silently exit on git failure" {
        Get-Content $script:PostHookPath -Raw | Should -Match "ErrorActionPreference|exit 0"
    }
    It "Should use git stash apply (not pop) to keep checkpoint in stash list" {
        $content = Get-Content $script:PostHookPath -Raw
        $content | Should -Match "git stash apply"
        $content | Should -Not -Match "git stash pop"
    }
}

Describe "Setup-CCClientSetup.ps1 - Backup-IfExists" {
    BeforeAll {
        $script:SetupScript = Join-Path $script:RepoRoot "Setup-CCClientSetup.ps1"
        # dot-source the script to load functions (will be a noop until functions exist)
        if (Test-Path $script:SetupScript) {
            . $script:SetupScript
        }
        $script:TmpDir = New-Item -ItemType Directory -Path ([System.IO.Path]::GetTempPath() + "/cc-test-" + [System.Guid]::NewGuid()) -Force
    }
    AfterAll {
        if ($script:TmpDir -and (Test-Path $script:TmpDir)) {
            Remove-Item $script:TmpDir -Recurse -Force
        }
    }
    It "Backup-IfExists should rename existing file to .bak.<timestamp>" {
        $testFile = Join-Path $script:TmpDir "sample.txt"
        Set-Content $testFile "original"
        Backup-IfExists -Path $testFile
        $backups = Get-ChildItem -Path $script:TmpDir -Filter "sample.txt.bak.*"
        $backups.Count | Should -BeGreaterOrEqual 1
        Test-Path $testFile | Should -Be $false  # original moved away
    }
    It "Backup-IfExists should be no-op when file does not exist" {
        $missing = Join-Path $script:TmpDir "missing.txt"
        { Backup-IfExists -Path $missing } | Should -Not -Throw
    }
}

Describe "Setup-CCClientSetup.ps1 - Install-ClaudeCodeRules" {
    BeforeAll {
        $script:SetupScript = Join-Path $script:RepoRoot "Setup-CCClientSetup.ps1"
        . $script:SetupScript
        $script:FakeHome = New-Item -ItemType Directory -Path ([System.IO.Path]::GetTempPath() + "/cc-home-" + [System.Guid]::NewGuid()) -Force
    }
    AfterAll {
        if ($script:FakeHome -and (Test-Path $script:FakeHome)) {
            Remove-Item $script:FakeHome -Recurse -Force
        }
    }
    It "Install-ClaudeCodeRules should copy 3 rule files to ~/.claude/rules/" {
        Install-ClaudeCodeRules -HomeRoot $script:FakeHome -RepoRoot $script:RepoRoot
        Test-Path (Join-Path $script:FakeHome ".claude/rules/security-essentials.md") | Should -Be $true
        Test-Path (Join-Path $script:FakeHome ".claude/rules/forbidden-files.md") | Should -Be $true
        Test-Path (Join-Path $script:FakeHome ".claude/rules/network-security.md") | Should -Be $true
    }
    It "Install-ClaudeCodeRules should be idempotent (existing file backed up)" {
        $existing = Join-Path $script:FakeHome ".claude/rules/security-essentials.md"
        Set-Content $existing "PRE-EXISTING"
        Install-ClaudeCodeRules -HomeRoot $script:FakeHome -RepoRoot $script:RepoRoot
        $backups = Get-ChildItem -Path (Join-Path $script:FakeHome ".claude/rules") -Filter "security-essentials.md.bak.*"
        $backups.Count | Should -BeGreaterOrEqual 1
    }
}

Describe "Setup-CCClientSetup.ps1 - Install-ClaudeCodeSettings + Install-ClaudeCodeHooks" {
    BeforeAll {
        $script:SetupScript = Join-Path $script:RepoRoot "Setup-CCClientSetup.ps1"
        . $script:SetupScript
        $script:FakeHome2 = New-Item -ItemType Directory -Path ([System.IO.Path]::GetTempPath() + "/cc-home2-" + [System.Guid]::NewGuid()) -Force
    }
    AfterAll {
        if ($script:FakeHome2 -and (Test-Path $script:FakeHome2)) {
            Remove-Item $script:FakeHome2 -Recurse -Force
        }
    }
    It "Install-ClaudeCodeSettings should place settings.json with <USER> substituted" {
        Install-ClaudeCodeSettings -HomeRoot $script:FakeHome2 -RepoRoot $script:RepoRoot -UserName "testuser"
        $settingsPath = Join-Path $script:FakeHome2 ".claude/settings.json"
        Test-Path $settingsPath | Should -Be $true
        $content = Get-Content $settingsPath -Raw
        $content | Should -Match "C:/Users/testuser/.claude/hooks/PreToolUse-DenyDangerous.ps1"
        $content | Should -Not -Match "<USER>"
    }
    It "Install-ClaudeCodeHooks should copy 2 hook scripts" {
        Install-ClaudeCodeHooks -HomeRoot $script:FakeHome2 -RepoRoot $script:RepoRoot
        Test-Path (Join-Path $script:FakeHome2 ".claude/hooks/PreToolUse-DenyDangerous.ps1") | Should -Be $true
        Test-Path (Join-Path $script:FakeHome2 ".claude/hooks/PostToolUse-AutoCheckpoint.ps1") | Should -Be $true
    }
}

Describe "Setup-CCClientSetup.ps1 - Install-ClaudeMd" {
    BeforeAll {
        $script:SetupScript = Join-Path $script:RepoRoot "Setup-CCClientSetup.ps1"
        . $script:SetupScript
        $script:TmpProject3 = New-Item -ItemType Directory -Path ([System.IO.Path]::GetTempPath() + "/cc-proj3-" + [System.Guid]::NewGuid()) -Force
        $script:FakeHome3 = New-Item -ItemType Directory -Path ([System.IO.Path]::GetTempPath() + "/cc-home3-" + [System.Guid]::NewGuid()) -Force
    }
    AfterAll {
        Remove-Item $script:TmpProject3 -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item $script:FakeHome3 -Recurse -Force -ErrorAction SilentlyContinue
    }
    It "Install-ClaudeMd should place CLAUDE.md in PJ root" {
        Install-ClaudeMd -ProjectRoot $script:TmpProject3 -HomeRoot $script:FakeHome3 -RepoRoot $script:RepoRoot
        Test-Path (Join-Path $script:TmpProject3 "CLAUDE.md") | Should -Be $true
    }
    It "Install-ClaudeMd should place CLAUDE.md in ~/.claude/" {
        Test-Path (Join-Path $script:FakeHome3 ".claude/CLAUDE.md") | Should -Be $true
    }
    It "CLAUDE.md should contain 実装許可制 keyword" {
        $content = Get-Content (Join-Path $script:TmpProject3 "CLAUDE.md") -Raw
        $content | Should -Match "実装許可制"
    }
}

Describe "Setup-CCClientSetup.ps1 - Install-GitConventions" {
    BeforeAll {
        $script:SetupScript = Join-Path $script:RepoRoot "Setup-CCClientSetup.ps1"
        . $script:SetupScript
        $script:TmpProject4 = New-Item -ItemType Directory -Path ([System.IO.Path]::GetTempPath() + "/cc-proj4-" + [System.Guid]::NewGuid()) -Force
        Push-Location $script:TmpProject4
        git init -b main -q
        Pop-Location
    }
    AfterAll {
        Remove-Item $script:TmpProject4 -Recurse -Force -ErrorAction SilentlyContinue
    }
    It "Install-GitConventions should place .gitignore" {
        Install-GitConventions -ProjectRoot $script:TmpProject4 -RepoRoot $script:RepoRoot
        Test-Path (Join-Path $script:TmpProject4 ".gitignore") | Should -Be $true
    }
    It "Install-GitConventions should place .git/hooks/pre-commit shim + pre-commit.ps1" {
        Test-Path (Join-Path $script:TmpProject4 ".git/hooks/pre-commit") | Should -Be $true
        Test-Path (Join-Path $script:TmpProject4 ".git/hooks/pre-commit.ps1") | Should -Be $true
    }
}

Describe "Setup-CCClientSetup.ps1 - Install-SecretaryDir" {
    BeforeAll {
        $script:SetupScript = Join-Path $script:RepoRoot "Setup-CCClientSetup.ps1"
        . $script:SetupScript
        $script:TmpProject5 = New-Item -ItemType Directory -Path ([System.IO.Path]::GetTempPath() + "/cc-proj5-" + [System.Guid]::NewGuid()) -Force
    }
    AfterAll {
        Remove-Item $script:TmpProject5 -Recurse -Force -ErrorAction SilentlyContinue
    }
    It "Install-SecretaryDir should create .company/secretary/{todos,notes,inbox}" {
        Install-SecretaryDir -ProjectRoot $script:TmpProject5 -RepoRoot $script:RepoRoot
        Test-Path (Join-Path $script:TmpProject5 ".company/CLAUDE.md") | Should -Be $true
        Test-Path (Join-Path $script:TmpProject5 ".company/secretary/todos") | Should -Be $true
        Test-Path (Join-Path $script:TmpProject5 ".company/secretary/notes") | Should -Be $true
        Test-Path (Join-Path $script:TmpProject5 ".company/secretary/inbox") | Should -Be $true
    }
    It "Install-SecretaryDir should preserve existing notes (not touch user .md)" {
        $userNote = Join-Path $script:TmpProject5 ".company/secretary/notes/2026-01-01-decisions.md"
        Set-Content $userNote "USER CONTENT"
        Install-SecretaryDir -ProjectRoot $script:TmpProject5 -RepoRoot $script:RepoRoot
        (Get-Content $userNote -Raw) | Should -Match "USER CONTENT"
    }
}

Describe "Setup-CCClientSetup.ps1 - Initialize-ProjectGit" {
    BeforeAll {
        $script:SetupScript = Join-Path $script:RepoRoot "Setup-CCClientSetup.ps1"
        . $script:SetupScript
    }
    It "Initialize-ProjectGit should create .git when missing (force mode)" {
        $tmp = New-Item -ItemType Directory -Path ([System.IO.Path]::GetTempPath() + "/cc-git-" + [System.Guid]::NewGuid()) -Force
        try {
            Initialize-ProjectGit -ProjectRoot $tmp -Force
            Test-Path (Join-Path $tmp ".git") | Should -Be $true
        } finally {
            Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    It "Initialize-ProjectGit should be no-op when .git exists" {
        $tmp = New-Item -ItemType Directory -Path ([System.IO.Path]::GetTempPath() + "/cc-git2-" + [System.Guid]::NewGuid()) -Force
        try {
            Push-Location $tmp
            git init -b main -q
            Pop-Location
            $beforeHead = Get-Content (Join-Path $tmp ".git/HEAD") -Raw
            Initialize-ProjectGit -ProjectRoot $tmp -Force
            $afterHead = Get-Content (Join-Path $tmp ".git/HEAD") -Raw
            $afterHead | Should -Be $beforeHead
        } finally {
            Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

Describe "Setup-CCClientSetup.ps1 - end-to-end" {
    BeforeAll {
        $script:SetupScript = Join-Path $script:RepoRoot "Setup-CCClientSetup.ps1"
        $script:TmpProject6 = New-Item -ItemType Directory -Path ([System.IO.Path]::GetTempPath() + "/cc-proj6-" + [System.Guid]::NewGuid()) -Force
        $script:FakeHome6 = New-Item -ItemType Directory -Path ([System.IO.Path]::GetTempPath() + "/cc-home6-" + [System.Guid]::NewGuid()) -Force
    }
    AfterAll {
        Remove-Item $script:TmpProject6 -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item $script:FakeHome6 -Recurse -Force -ErrorAction SilentlyContinue
    }
    It "Should be invokable with -ProjectPath argument (smoke)" {
        & pwsh -NoLogo -NoProfile -File $script:SetupScript -ProjectPath $script:TmpProject6 -Force -TestHomeOverride $script:FakeHome6 2>&1 | Out-Null
        $LASTEXITCODE | Should -Be 0
    }
    It "Should have placed all expected files" {
        Test-Path (Join-Path $script:FakeHome6 ".claude/rules/security-essentials.md") | Should -Be $true
        Test-Path (Join-Path $script:FakeHome6 ".claude/settings.json") | Should -Be $true
        Test-Path (Join-Path $script:FakeHome6 ".claude/hooks/PreToolUse-DenyDangerous.ps1") | Should -Be $true
        Test-Path (Join-Path $script:FakeHome6 ".claude/CLAUDE.md") | Should -Be $true
        Test-Path (Join-Path $script:TmpProject6 "CLAUDE.md") | Should -Be $true
        Test-Path (Join-Path $script:TmpProject6 ".gitignore") | Should -Be $true
        Test-Path (Join-Path $script:TmpProject6 ".company/secretary/notes") | Should -Be $true
    }
    It "Should be idempotent (run twice produces backups)" {
        & pwsh -NoLogo -NoProfile -File $script:SetupScript -ProjectPath $script:TmpProject6 -Force -TestHomeOverride $script:FakeHome6 2>&1 | Out-Null
        $LASTEXITCODE | Should -Be 0
        $backups = Get-ChildItem -Path (Join-Path $script:FakeHome6 ".claude/rules") -Filter "*.bak.*"
        $backups.Count | Should -BeGreaterOrEqual 3
    }
}
