# Função para gerar uma senha aleatória
function Generate-RandomPassword {
    param([int]$length)
    
    $characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    $password = ""
    
    for ($i = 0; $i -lt $length; $i++) {
        $randomChar = Get-Random -Minimum 0 -Maximum $characters.Length
        $password += $characters[$randomChar]
    }
    
    return $password
}

# Função para exibir todas as contas cadastradas
function Show-LocalUsers {
    Clear-Host
    
    $localUsers = Get-LocalUser
    
    if ($localUsers) {
        Write-Host "======= CONTAS CADASTRADAS ======="
        foreach ($user in $localUsers) {
            $accountName = $user.Name
            $fullName = $user.Description
            
            Write-Host "CPF: $accountName"
            Write-Host "Nome Completo: $fullName"
            Write-Host "-----------------------------------"
        }
    } else {
        Write-Host "Não há contas cadastradas."
    }
    
    Read-Host -Prompt "Pressione Enter para continuar..."
}

# Desabilitar todas as contas locais, exceto Administrador
function Disable-LocalAccounts {
    $accounts = Get-LocalUser | Where-Object { $_.Name -ne 'Administrator' }
    
    foreach ($account in $accounts) {
        Disable-LocalUser -Name $account.Name
    }
    
    Write-Host "Todas as contas locais foram desabilitadas, exceto 'Administrator'."
    Read-Host -Prompt "Pressione Enter para continuar..."
}

# Menu principal
do {
    Clear-Host
    
    Write-Host "======= MENU PRINCIPAL ======="
    Write-Host "1. Consultar conta"
    Write-Host "2. Criar conta"
    Write-Host "3. Editar conta"
    Write-Host "4. Desabilitar contas"
    Write-Host "5. Visualizar contas cadastradas"
    Write-Host "0. Sair"
    
    $option = Read-Host "Opção:"
    
    switch ($option) {
        1 {
            # Consultar conta
            do {
                Clear-Host
                
                # Solicitar nome da conta local
                $accountName = Read-Host "Digite o CPF da conta local (ou '0' para retornar):"
                
                if ($accountName -eq "0") {
                    break
                }
                
                # Verificar se a conta local existe
                $account = Get-LocalUser -Name $accountName -ErrorAction SilentlyContinue
                if ($account) {
                    # Conta local existe, exibir informações
                    $cpf = $account.Description
                    
                    Write-Host "CPF: $accountName"
                    Write-Host "Nome Completo: $fullName"
                } else {
                    Write-Host "O CPF: $accountName não está cadastrado."
                }
                
                Read-Host -Prompt "Pressione Enter para continuar..."
            } while ($true)
            
            break
        }
        2 {
            # Criar conta
            do {
                Clear-Host
                
                # Solicitar nome da conta local
                $accountName = Read-Host "Digite o CPF que deseja cadastrar para verificar se ele já está cadastrado no sistema (ou '0' para retornar):"
                
                if ($accountName -eq "0") {
                    break
                }
                
                # Verificar se a conta local já existe
                $accountExists = Get-LocalUser -Name $accountName -ErrorAction SilentlyContinue
                if ($accountExists) {
                    Write-Host "O CPF: $accountName já está cadastrado."
                    Read-Host -Prompt "Pressione Enter para retornar..."
                    continue
                }
                
                # Solicitar informações da nova conta
                Write-Host "Usuário não cadastrado ! Cadastre agora !"
                $fullName = Read-Host "Digite o Nome Completo:"
                $cpf = Read-Host "Digite o CPF:"
                
                # Gerar uma senha aleatória
                $password = Generate-RandomPassword -length 9
                $password = $cpf.Substring($cpf.Length - 4) + "@" + $password.Substring(5, 4)
                
                # Criar a conta local
                New-LocalUser -Name $cpf -FullName $fullName -Description $fullName -Password (ConvertTo-SecureString -String $password -AsPlainText -Force) -PasswordNeverExpires -AccountNeverExpires
                
                Write-Host "A conta $cpf foi criada com sucesso."
                Write-Host "Nome Completo: $fullName"
                Write-Host "Senha: $password"
                
                Read-Host -Prompt "Pressione Enter para retornar..."
            } while ($true)
            
            break
        }
        3 {
            # Editar conta
            do {
                Clear-Host
                
                # Solicitar nome da conta local
                $accountName = Read-Host "Digite o CPF que deseja Editar: (ou '0' para retornar):"
                
                if ($accountName -eq "0") {
                    break
                }
                
                # Verificar se a conta local existe
                $account = Get-LocalUser -Name $accountName -ErrorAction SilentlyContinue
                if ($account) {
                    # Conta local existe, solicitar informações atualizadas da conta
                    $newFullName = Read-Host "Digite o novo nome completo:"
                    $newDescription = Read-Host "Digite o novo CPF:"
                    
                    # Atualizar informações da conta
                    Set-LocalUser -Name $accountName -FullName $newDescription -Description $newFullName
                    
                    Write-Host "A conta $accountName foi atualizada com sucesso."
                } else {
                    Write-Host "O CPF $accountName não existe."
                }
                
                Read-Host -Prompt "Pressione Enter para continuar..."
            } while ($true)
            
            break
        }
        4 {
            # Desabilitar contas
            Disable-LocalAccounts
            break
        }
        5 {
            # Visualizar contas cadastradas
            Show-LocalUsers
            
            break
        }
        "0" {
            # Sair do programa
            Write-Host "Encerrando o programa..."
            return
            break
        }
        default {
            Write-Host "Opção inválida."
        }
    }
} while ($true)
