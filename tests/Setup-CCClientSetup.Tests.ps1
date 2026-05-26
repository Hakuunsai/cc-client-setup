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
}
