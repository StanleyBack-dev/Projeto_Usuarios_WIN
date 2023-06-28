# Projeto de Criação de Usuários do Windows automatizado com Menu de opções para: 

1 - Consultar Contas
2 - Criar Contas
3 - Editar Contas
4 - Desabilitar Contas
5 - Visualizar Contas Cadastradas
0 - Sair

# Existem funções dentro do código Power Shell sobre as regras de negócio que me foram solicitadas, como:

1 - A senha precisa ter 9 Caracteres
2 - Os 4 primeiros caracteres precisam ser os 4 últimos digitos do CPF do Usuário cadastrado
3 - O 5º caractere tem que ser um '@'
4 - Os 4 últimos caracteres tem que ser 2 caracteres alfabéticos maiuscúlos e 2 caracteres minuscúlos de A-Z 

# Os usuários são cadastrados com CPF e Nome Completo.
# Existe uma função dentro do código em que após a máquina ser desligada, todas os usuários locais, exceto o usuário administrador, seram desativadas.

### Nessa versão eu implementei algumas novas funções de consultar a conta cadastrada pelos 4 primeiros dígitos do CPF ( Conta do Usuário ). Um novo menu para exportar as informações de Usuários para um arquivo TXT em sua área de trabalho local (DeskTop), com a opção de exportar os dados de todas as contas Habilitadas ou exportar os dados de uma conta Habilitada específica pelo o CPF informado pelo o Usuário na hora da exportação. Alterei algumas novas funções de Design também, dentro do sistema inteiro. Pretendo implementar mais algumas novas funcionalidades para chegar até versão final que eu desejo.

### VERSÃO 1.0.2
