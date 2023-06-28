# Função para gerar uma senha aleatória
function Generate-RandomPassword {
    param([int]$length)
    
    $characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    $password = ""
    
    for ($i = 0; $i -lt $length - 4; $i++) {
        $randomChar = Get-Random -Minimum 0 -Maximum $characters.Length
        $password += $characters[$randomChar]
    }

    # Adicionar 2 caracteres maiúsculos
    $uppercaseChars = ($characters.ToUpper().ToCharArray() | Get-Random -Count 2) -join ''
    $password += $uppercaseChars

    # Adicionar 2 caracteres minúsculos
    $lowercaseChars = ($characters.ToLower().ToCharArray() | Get-Random -Count 2) -join ''
    $password += $lowercaseChars
    
    return $password
}

# Função para exibir todas as contas cadastradas
function Show-LocalUsers {
    Clear-Host
    
    $localUsers = Get-LocalUser
    
    if ($localUsers) {
        Write-Host "======= CONTAS CADASTRADAS ======="
        Write-Host "-----------------------------------"
        foreach ($user in $localUsers) {
            $FullName = $user.FullName
            $cpf = $user.Name
            $password = $user.Description
	    $status = "Desabilitada"
	    
	     # Verificar se a conta está habilitada
            if ($user.Enabled) {
                $status = "Habilitada"
            }
            
            Write-Host "`nCPF: $cpf"
            Write-Host "Nome Completo: $FullName"
            Write-Host "Senha: $password"
            Write-Host "Status: $status`n"
            Write-Host "-----------------------------------"
        }
    } else {
        Write-Host "Não há contas cadastradas."
    }
    
    Read-Host -Prompt "`n`nPressione Enter para retornar"
}

# Função para exibir as informações de uma conta
function Show-AccountInfo {
    param([string]$cpf)
    
    $account = Get-LocalUser -Name $cpf -ErrorAction SilentlyContinue
    
    if ($account) {
        $FullName = $account.FullName
        $password = $account.Description
        $status = "Desabilitada"
        
        # Verificar se a conta está habilitada
        if ($account.Enabled) {
            $status = "Habilitada"
        }
        
        Write-Host "======= INFORMAÇÕES DA CONTA ======="
        Write-Host "`nCPF: $cpf"
        Write-Host "Nome Completo: $FullName"
        Write-Host "Senha: $password"
        Write-Host "Status: $status"
        Write-Host "`n===================================="
    } else {
	Write-Host "================================================="
        Write-Host "A conta com o CPF -- $cpf -- não existe."
	Write-Host "================================================="
    }
    
    Read-Host -Prompt "`nPressione Enter para retornar"
}

# Função para editar uma conta
function Edit-Account {
    param([string]$cpf)
    
    # Verificar se a conta local existe
    $account = Get-LocalUser -Name $cpf -ErrorAction SilentlyContinue
    
    if ($account) {
        # Solicitar informações atualizadas da conta
        $newFullName = Read-Host "`nDigite o novo Nome Completo"
        $newCpf = Read-Host "Digite o novo CPF"
        
        # Gerar uma nova senha aleatória
        $newPassword = Generate-RandomPassword -length 9
        $newPassword = $newCpf.Substring($newCpf.Length - 4) + "@" + $newPassword.Substring(5, 4)
        
        # Atualizar a conta local
        Rename-LocalUser -Name $cpf -NewName $newCpf
        Set-LocalUser -Name $newCpf -FullName $newFullName -Description $newPassword
        
        Write-Host "====================================================================================="
        Write-Host "`nA conta com o CPF: $cpf foi atualizada com sucesso."
        Write-Host "`nNovo CPF: $newCpf"
        Write-Host "Novo Nome Completo: $newFullName"
        Write-Host "Nova Senha: $newPassword"
        Write-Host "====================================================================================="
    } else {
        Write-Host "A conta com o CPF $cpf não existe."
    }
    
    Read-Host -Prompt "`nPressione Enter para retornar"
}

# Desabilitar todas as contas locais, exceto Administrador
function Disable-LocalAccounts {
    $accounts = Get-LocalUser | Where-Object { ($_.Name -notlike "Administra*") }
    
    foreach ($account in $accounts) {
        Disable-LocalUser -Name $account.Name
    }
    
    Clear-Host
    Write-Host "================================================================================="
    Write-Host "Todas as contas locais foram desabilitadas ! EXCETO A: -- Administrador --"
    Write-Host "================================================================================="
    Read-Host -Prompt "`nPressione Enter para retornar"
}

# Menu principal
do {
    Clear-Host
    
    Write-Host "======= MENU PRINCIPAL ======="
    Write-Host "`n1. Consultar conta"
    Write-Host "2. Criar conta"
    Write-Host "3. Editar conta"
    Write-Host "4. Desabilitar contas"
    Write-Host "5. Visualizar contas cadastradas"
    Write-Host "0. Sair"
    Write-Host "`n=============================="
    $option = Read-Host "`nOpção"
    
    switch ($option) {
        1 {
            # Consultar conta
            do {
                Clear-Host
                
                # Solicitar nome da conta local
                $accountName = Read-Host "Digite o CPF da conta local que deseja consultar (ou '0' para retornar)"
                
                if ($accountName -eq "0") {
                    break
                }
                
                # Exibir informações da conta
	        Clear-Host
                Show-AccountInfo -cpf $accountName
                
            } while ($true)
            
            break
        }
        2 {
            # Criar conta
            do {
                Clear-Host
                
                # Solicitar CPF para verificação de cadastro
                $cpfToCheck = Read-Host "Digite o CPF que deseja cadastrar para verificar se ele já está cadastrado no sistema (ou '0' para retornar)"
                
                Write-Host "`n========================================================================================================================="
                
                if ($cpfToCheck -eq "0") {
                    break
                }
                
                # Verificar se a conta local já existe
                $accountExists = Get-LocalUser -Name $cpfToCheck -ErrorAction SilentlyContinue
                if ($accountExists) {
                    # Conta já cadastrada, exibir CPF e Nome Completo
                    $fullName = $accountExists.FullName
                    $password = $accountExists.Description
                    
                    Write-Host "`nO CPF: | $cpfToCheck | já está cadastrado"
                    Write-Host "Nome Completo: $fullName"
                    Write-Host "Senha: $password"
                    Write-Host "`n========================================================================================================================="
                    Read-Host -Prompt "`nPressione Enter para retornar"
                    continue
                }
                
                # Solicitar informações da nova conta
                Write-Host "`nUsuário não cadastrado! Cadastre agora!"
                Write-Host "`n========================================================================================================================="
                $cpf = Read-Host "`nDigite o CPF"
		$fullName = Read-Host "Digite o Nome"   
                
                # Gerar uma senha aleatória
                $password = Generate-RandomPassword -length 9
                $password = $cpf.Substring($cpf.Length - 4) + "@" + $password.Substring(5, 4)
                
                # Criar a conta local
                New-LocalUser -Name $cpf -FullName $fullName -Description $password -Password (ConvertTo-SecureString -String $password -AsPlainText -Force) -PasswordNeverExpires -AccountNeverExpires
                
                Write-Host "`n=========================================================================================================================="
                Write-Host "`nA conta || $cpf || foi criada com sucesso."
                Write-Host "`nNome Completo: $fullName"
                Write-Host "Senha: $password"
                Write-Host "`n=========================================================================================================================="
                Read-Host -Prompt "Pressione Enter para retornar"
            } while ($true)
            
            break
        }3 {
            # Editar conta
            do {
                Clear-Host
                
                # Solicitar nome da conta local
                $cpf = Read-Host "Digite o CPF da conta local que deseja editar (ou '0' para retornar)"
                Write-Host "====================================================================================="
                
                if ($cpf -eq "0") {
                    break
                }
                
                # Editar a conta local
                Edit-Account -cpf $cpf
                
           	 } while ($true)
            
           	 break
       	  }
        4 {
   		 # Desabilitar contas
   		 do {
       		 Clear-Host
        
       		 # Solicitar confirmação
      		  $confirmation = Read-Host "Tem certeza que deseja desabilitar todas as contas? (S/N)"
        Write-Host "====================================================================================="
        if ($confirmation -eq "S" -or $confirmation -eq "s") {
            Disable-LocalAccounts
           
        } elseif ($confirmation -eq "N" -or $confirmation -eq "n") {
            Write-Host "`nOperação de desabilitar contas cancelada."
	    Write-Host "`n====================================================================================="
        } else {
            Write-Host "`nOpção inválida. Por favor, digite 'S' para confirmar ou 'N' para cancelar."
            Continue
        }
        
        break
    } while ($true)
    
    
}
        
        5 {
            # Visualizar contas cadastradas
            Show-LocalUsers
            break
        }
       
        "0" {
            # Sair do programa
	    Clear-Host
	    Write-Host "========================================================="
            $confirm = Read-Host "Tem certeza que deseja sair? (S/N)"
 	    Write-Host "========================================================="
            if ($confirm -eq "S" -or $confirm -eq "s") {
                Write-Host "`nEncerrando o programa..."
                Start-Sleep -Seconds 3
                return
            }
            
            break
        }
       default {
            # Opção inválida
	    Clear-Host
	    Write-Host "====================================================================================="
            Write-Host "`nOpção inválida. Por favor, selecione uma opção válida."
	    Write-Host "`n====================================================================================="
            Read-Host -Prompt "Pressione Enter para continuar"
        }
    }
} while ($true)