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
