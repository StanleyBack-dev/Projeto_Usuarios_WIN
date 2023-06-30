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
 	Write-Host "`n====================================================================================="
        Write-Host "A conta com o CPF -- $cpf -- não existe."
	Write-Host "====================================================================================="
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

# Função para habilitar uma conta desabilitada
function Enable-Account {
    param([string]$cpf)

    # Verificar se a conta local existe
    $account = Get-LocalUser -Name $cpf -ErrorAction SilentlyContinue

    if ($account) {
        # Verificar se a conta já está habilitada
        if ($account.Enabled) {
            Write-Host "`nA conta com o CPF $cpf já está habilitada."
            Read-Host -Prompt "`nPressione Enter para retornar"
            return
        }

        # Habilitar a conta local
        Enable-LocalUser -Name $cpf

        Write-Host "========================================================================="
        Write-Host "`nA conta com o CPF $cpf foi habilitada com sucesso."
        Write-Host "========================================================================="
    } else {
        Write-Host "`n========================================================================="
        Write-Host "A conta com o CPF -- $cpf -- não existe."
        Write-Host "========================================================================="
    }

    Read-Host -Prompt "`nPressione Enter para retornar"
}

# Função para habilitar todas contas desabilitadas
function Enable-LocalAccounts {
    $accounts = Get-LocalUser | Where-Object { ($_.Name -notlike "Administra*") }
    
    foreach ($account in $accounts) {
        Enable-LocalUser -Name $account.Name
    }
    
    Clear-Host
    Write-Host "========================================================"
    Write-Host "Todas as contas locais foram habilitadas com sucesso!"
    Write-Host "========================================================"
}

# Função para exportar as informações da conta para um arquivo TXT
function Export-AccountInfoToTXT {
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
        
        # Criar o conteúdo a ser exportado
        $content = @"
======= INFORMAÇÕES DA CONTA =======

CPF: $cpf
Nome Completo: $FullName
Senha: $password
Status: $status

====================================
"@
        
        # Definir o nome do arquivo de acordo com o CPF
        $fileName = [Environment]::GetFolderPath("Desktop") + "\" + $cpf + ".txt"
        
        # Salvar o conteúdo no arquivo TXT
        $content | Out-File -FilePath $fileName
        Write-Host "`n========================================================================================================================"
        Write-Host "As informações da conta foram exportadas para o arquivo $fileName."
        Write-Host "========================================================================================================================"
    } else {
        Write-Host "A conta com o CPF $cpf não existe."
    }
    
    Read-Host -Prompt "`nPressione Enter para retornar"
}

# Menu principal
do {
    Clear-Host
    
    Write-Host "======= MENU PRINCIPAL ==============================="
    Write-Host "`n1. Consultar Conta"
    Write-Host "2. Criar Conta"
    Write-Host "3. Editar Conta"
    Write-Host "4. Desabilitar Contas"
    Write-Host "5. Habilitar Contas"
    Write-Host "6. Visualizar Contas Cadastradas"
    Write-Host "7. Exportar informações de Contas para Arquivos TXT"
    Write-Host "`n======================================================"
    Write-Host "0. Sair"
    Write-Host "======================================================"
    $option = Read-Host "`nOpção"
    
    switch ($option) {
         1 {
            # Consultar conta
            do {
                Clear-Host
                
                # Solicitar nome da conta local
                $cpf = Read-Host "Digite os 4 primeiros dígitos do CPF da conta local que deseja consultar (ou '0' para retornar)"
                Clear-Host
                if ($cpf -eq "0") {
                    break
                }
                
                # Filtrar as contas pelo CPF
                $filteredAccounts = Get-LocalUser | Where-Object { $_.Name -like "$cpf*" }
                
                if ($filteredAccounts) {
                    foreach ($account in $filteredAccounts) {
                        Show-AccountInfo -cpf $account.Name
                    }
                } else {
                    Write-Host "Não foram encontradas contas com os 4 primeiros dígitos do CPF informado."
                }
                
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

        Write-Host "======= MENU DE DESABILITAR CONTAS ======="
        Write-Host "`n1. Desabilitar Conta Específica"
        Write-Host "2. Desabilitar Todas as Contas"
        Write-Host "`n=========================================="
        Write-Host "0. Retornar"
        Write-Host "=========================================="

        $disableOption = Read-Host "`nOpção"

        switch ($disableOption) {
            "1" {
    # Desabilitar conta específica
    Clear-Host

    # Solicitar CPF da conta a ser desabilitada
    $cpf = Read-Host "Digite o CPF da conta que deseja desabilitar (ou '0' para retornar)"

    if ($cpf -eq "0") {
        break
    }

    # Verificar se a conta existe
    $account = Get-LocalUser -Name $cpf -ErrorAction SilentlyContinue

    if ($account) {
        # Desabilitar a conta
        Disable-LocalUser -Name $cpf
        Write-Host "`n======================================================================================================="
        Write-Host "A conta com o CPF -- $cpf -- foi desabilitada com sucesso."
        Write-Host "======================================================================================================="
    } else {
        Write-Host "`n======================================================================================================="
        Write-Host "A conta com o CPF -- $cpf -- não existe."
        Write-Host "======================================================================================================="
    }

    Read-Host -Prompt "`nPressione Enter para retornar"
    break
}
            "2" {
                # Desabilitar todas as contas
                Clear-Host

                # Solicitar confirmação
                $confirmation = Read-Host "Tem certeza que deseja desabilitar todas as contas? (S/N)"

                if ($confirmation -eq "S" -or $confirmation -eq "s") {
                    # Desabilitar todas as contas
                    Disable-LocalAccounts

                } elseif ($confirmation -eq "N" -or $confirmation -eq "n") {
                    Write-Host "`nOperação de desabilitar contas cancelada."
                } else {
                    Write-Host "`nOpção inválida. Por favor, digite 'S' para confirmar ou 'N' para cancelar."
                }

              
            }
            "0" {
                # Retornar ao menu principal
                $returnToMain = $true
                break
            }
            default {
                # Opção inválida
                Clear-Host
                Write-Host "`nOpção inválida. Por favor, selecione uma opção válida."
                Read-Host -Prompt "Pressione Enter para continuar"
            }
        }
    } while (!$returnToMain)

    break
}

            5{
                 #Menu de habilitar contas
                 do {
                 Clear-Host

                 Write-Host "======= MENU DE HABILITAR CONTAS ========"
                 Write-Host "`n1. Habilitar conta específica"
                 Write-Host "2. Habilitar todas as contas"
                 Write-Host "`n========================================="
                 Write-Host "0. Retornar"
                 Write-Host "========================================="

                 $enableOption = Read-Host "`nOpção"

                 switch ($enableOption) {
                 "1" {
                 # Habilitar conta específica
                 Clear-Host

                 # Solicitar CPF da conta a ser habilitada
                 $cpf = Read-Host "Digite o CPF da conta que deseja habilitar (ou '0' para retornar)"
                

                 if ($cpf -eq "0") {
                break
                 }

                 # Verificar se a conta existe
                  $account = Get-LocalUser -Name $cpf -ErrorAction SilentlyContinue

            if ($account) {
                # Verificar se a conta já está habilitada
                if ($account.Enabled) {
                    Write-Host "`n=================================================================================="
                    Write-Host "A conta com o CPF -- $cpf -- já está habilitada."
                    Write-Host "=================================================================================="
                } else {
                    # Habilitar a conta
                    Enable-LocalUser -Name $cpf
                    Write-Host "`n=================================================================================="
                    Write-Host "A conta com o CPF -- $cpf -- foi habilitada com sucesso."
                    Write-Host "=================================================================================="
                }
            } else {
                Write-Host "`n=================================================================================="
                Write-Host "A conta com o CPF -- $cpf -- não existe."
                Write-Host "=================================================================================="
            }

            Read-Host -Prompt "`nPressione Enter para retornar"
            break
        }
        "2" {
            # Habilitar todas as contas
            Clear-Host

            # Solicitar confirmação
            $confirmation = Read-Host "Tem certeza que deseja habilitar todas as contas? (S/N)"

            if ($confirmation -eq "S" -or $confirmation -eq "s") {
                # Habilitar todas as contas
                Enable-LocalAccounts

            } elseif ($confirmation -eq "N" -or $confirmation -eq "n") {
                Write-Host "`nOperação de habilitar contas cancelada."
            } else {
                Write-Host "`nOpção inválida. Por favor, digite 'S' para confirmar ou 'N' para cancelar."
            }

            Read-Host -Prompt "`nPressione Enter para retornar"
            break
        }
        "0" {
            # Retornar ao menu principal
            $returnToMain = $true
            break
        }
        default {
            # Opção inválida
            Clear-Host
            Write-Host "====================================================================="
            Write-Host "Opção inválida. Por favor, selecione uma opção válida."
            Write-Host "====================================================================================="
            Read-Host -Prompt "`nPressione Enter para continuar"
            break
                }
        }
             } while (!$returnToMain)
       }  
        
        6 {
            # Visualizar contas cadastradas
            Show-LocalUsers
            break
        }

        7 {
    # Exportar dados para arquivo TXT
    do {
        Clear-Host

        Write-Host "======= MENU EXPORTAR DADOS ====================================="
        Write-Host "`n1. Exportar Todas as Contas Habilitadas"
        Write-Host "2. Exportar Todas as Contas Desabilitadas"
        Write-Host "3. Exportar Conta Específica"
        Write-Host "4. Exportar Todas as Contas (Habilitadas e Desabilitadas)"
        Write-Host "`n================================================================="
        Write-Host "0. Retornar"
        Write-Host "================================================================="
        $exportOption = Read-Host "`nOpção"

        switch ($exportOption) {
            1 {
                # Exportar todas as contas habilitadas
                $desktopPath = [Environment]::GetFolderPath("Desktop")
                $fileName = $desktopPath + "\ContasHabilitadas.txt"
                $accounts = Get-LocalUser | Where-Object { $_.Enabled -eq $true }

                if ($accounts) {
                    $output = ""
                    foreach ($account in $accounts) {
                        $output += "CPF: $($account.Name)`r`n"
                        $output += "Nome Completo: $($account.FullName)`r`n"
                        $output += "Senha: $($account.Description)`r`n"
                        $output += "Status: Habilitada`r`n"
                        $output += "-----------------------------------`r`n"
                    }

                    $output | Out-File -FilePath $fileName -Encoding UTF8
                    Clear-Host
                    Write-Host "`n============================================================================================================================================="
                    Write-Host "As informações das contas habilitadas foram exportadas para o arquivo: $fileName"
                    Write-Host "============================================================================================================================================="
                } else {
                    Write-Host "`nNão há contas habilitadas para exportar."
                }

                Read-Host -Prompt "`nPressione Enter para retornar"
                break
            }
            2 {
                # Exportar todas as contas desabilitadas
                $desktopPath = [Environment]::GetFolderPath("Desktop")
                $fileName = $desktopPath + "\ContasDesabilitadas.txt"
                $accounts = Get-LocalUser | Where-Object { $_.Enabled -eq $false }

                if ($accounts) {
                    $output = ""
                    foreach ($account in $accounts) {
                        $output += "CPF: $($account.Name)`r`n"
                        $output += "Nome Completo: $($account.FullName)`r`n"
                        $output += "Senha: $($account.Description)`r`n"
                        $output += "Status: Desabilitada`r`n"
                        $output += "-----------------------------------`r`n"
                    }

                    $output | Out-File -FilePath $fileName -Encoding UTF8
                    Clear-Host
                    Write-Host "`n============================================================================================================================================="
                    Write-Host "As informações das contas desabilitadas foram exportadas para o arquivo: $fileName"
                    Write-Host "============================================================================================================================================="
                } else {
                    Write-Host "`nNão há contas desabilitadas para exportar."
                }

                Read-Host -Prompt "`nPressione Enter para retornar"
                break
            }
            3 {
                # Exportar conta específica
                Clear-Host

                # Solicitar CPF da conta para exportar
                $cpfToExport = Read-Host "Digite o CPF da conta que deseja exportar (ou '0' para retornar)"
                if ($cpfToExport -eq "0") {
                    break
                }

                Export-AccountInfoToTXT -cpf $cpfToExport
                break
            }
            4 {
                # Exportar todas as contas (habilitadas e desabilitadas)
                $desktopPath = [Environment]::GetFolderPath("Desktop")
                $fileName = $desktopPath + "\TodasAsContas.txt"
                $accounts = Get-LocalUser

                if ($accounts) {
                    $output = ""
                    foreach ($account in $accounts) {
                        $output += "CPF: $($account.Name)`r`n"
                        $output += "Nome Completo: $($account.FullName)`r`n"
                        $output += "Senha: $($account.Description)`r`n"
                        if ($account.Enabled) {
                            $output += "Status: Habilitada`r`n"
                        } else {
                            $output += "Status: Desabilitada`r`n"
                        }
                        $output += "-----------------------------------`r`n"
                    }

                    $output | Out-File -FilePath $fileName -Encoding UTF8
                    Clear-Host
                    Write-Host "`n============================================================================================================================================="
                    Write-Host "As informações de todas as contas foram exportadas para o arquivo: $fileName"
                    Write-Host "============================================================================================================================================="
                } else {
                    Write-Host "`nNão há contas para exportar."
                }

                Read-Host -Prompt "`nPressione Enter para retornar"
                break
            }
            "0" {
                # Retornar ao menu principal
                break
            }
            default {
                # Opção inválida
                Write-Host "`nOpção inválida. Por favor, selecione uma opção válida."
                Read-Host -Prompt "`nPressione Enter para continuar"
                break
            }
        }
    } while ($exportOption -ne "0")
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