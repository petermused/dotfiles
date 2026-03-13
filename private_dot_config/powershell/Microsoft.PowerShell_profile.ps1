# FIXME: Move to new location once PowerShell 7.7 is released: https://devblogs.microsoft.com/powershell/powershell-openssh-and-dsc-team-investments-for-2026/

New-Alias which Get-Command
New-Alias touch New-Item

if (Get-Command starship -ErrorAction SilentlyContinue) {
    # See https://wezfurlong.org/wezterm/shell-integration.html#osc-7-on-windows-with-powershell-with-starship
    $prompt = ""
    function Invoke-Starship-PreCommand {
        $current_location = $executionContext.SessionState.Path.CurrentLocation
        if ($current_location.Provider.Name -eq "FileSystem") {
            $ansi_escape = [char]27
            $provider_path = $current_location.ProviderPath -replace "\\", "/"
            $prompt = "$ansi_escape]7;file://${env:COMPUTERNAME}/${provider_path}$ansi_escape\"
        }
        $host.ui.Write($prompt)
    }

    Invoke-Expression (&starship init powershell)
}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Remove-Alias cd
    New-Alias cd z
    Invoke-Expression (& { (zoxide init powershell --hook prompt | Out-String) })
}

if (Get-Command eza -ErrorAction SilentlyContinue) {
    Remove-Alias ls

    <#
    FIXME: This situation is supposed to get better in PowerShell 7.7

    Unlike other shells, you cannot create PowerShell aliases for commands with
    multiple parameters:

    ```powershell
    New-Alias ls eza # Does work
    New-Alias la "eza -la" # Does not work
    ```

    'Aliases' in PowerShell are literally that: another name for a command or
    function. So, for each alias that runs a command with multiple parameters,
    we have to create a new function that runs the command we want.

    Each function uses the call operator (`&`) and the `$args` variable to
    ensure that any extra parameters (e.g. the directory, or flags) get passed
    through correctly.
    #>
    function Eza-Ls { & eza --icons $args }
    New-Alias ls Eza-Ls
    function Eza-La { & eza -la --git --icons $args }
    New-Alias la Eza-La
    function Eza-Ll { & eza -l --git --icons $args }
    New-Alias ll Eza-Ll
    function Eza-Lat { & eza -la --git --tree --icons $args }
    New-Alias lat Eza-Lat
    function Eza-Llt { & eza -l --git --tree --icons $args }
    New-Alias llt Eza-Llt
}

if (Get-Command lazygit -ErrorAction SilentlyContinue) {
    New-Alias lg lazygit
}

if (Get-Command jj -ErrorAction SilentlyContinue) {
    # https://docs.jj-vcs.dev/latest/install-and-setup/#powershell
    $env:COMPLETE = "powershell"
    jj | Out-String | Invoke-Expression
    Remove-Item Env:\COMPLETE
}