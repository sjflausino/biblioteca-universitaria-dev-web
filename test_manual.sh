#!/bin/bash

BASE_URL="http://localhost:8080/biblioteca"
COOKIE_FILE="cookies.txt"

# Função visual para separar etapas no log
separator() {
    echo -e "\n\n=================================================="
    echo "$1"
    echo "=================================================="
}

separator "1. REINICIANDO (Limpar Cookies Antigos)"
rm -f ${COOKIE_FILE}

separator "2. CADASTRAR USUÁRIO (ADMIN)"
# Cria o usuário admin para poder cadastrar livros e ver relatórios depois
curl -v -c ${COOKIE_FILE} -L -d "nome=Admin&email=admin@teste.com&matricula=ADM999&senha=admin&tipo=admin" "${BASE_URL}/cadastroUsuario"

separator "3. LOGIN (Como Admin para cadastrar livro)"
curl -v -b ${COOKIE_FILE} -c ${COOKIE_FILE} -L -d "email=admin@teste.com&senha=admin" "${BASE_URL}/login"

separator "4. CADASTRAR LIVRO (Apenas Admin)"
# Cadastra o livro que será emprestado. Assume-se que será o ID 1 se o banco estiver vazio.
curl -v -b ${COOKIE_FILE} -c ${COOKIE_FILE} -L -d "titulo=JavaWeb&autor=DevMaster&editora=Tech&isbn=12345&quantidade=5" "${BASE_URL}/livros"

separator "5. CADASTRAR USUÁRIO COMUM (Aluno)"
curl -v -b ${COOKIE_FILE} -c ${COOKIE_FILE} -L -d "nome=Aluno&email=aluno@teste.com&matricula=ALU001&senha=123&tipo=aluno" "${BASE_URL}/cadastroUsuario"

separator "6. LOGIN (Como Aluno - Troca de Sessão)"
# O curl sobrescreve o cookie, simulando o aluno logando em outro momento/navegador
curl -v -c ${COOKIE_FILE} -L -d "email=aluno@teste.com&senha=123" "${BASE_URL}/login"

separator "7. REALIZAR EMPRÉSTIMO (Aluno pega Livro ID 1)"
curl -v -b ${COOKIE_FILE} -c ${COOKIE_FILE} -L -d "livroId=1" "${BASE_URL}/emprestimos"

separator "8. LOGIN (Voltar como Admin)"
# Admin loga novamente para gerenciar a biblioteca
curl -v -c ${COOKIE_FILE} -L -d "email=admin@teste.com&senha=admin" "${BASE_URL}/login"

separator "9. TESTAR RELATÓRIOS (Apenas Admin)"
# Verifica se a página de relatórios carrega (deve conter dados do livro e do aluno acima)
curl -v -b ${COOKIE_FILE} "${BASE_URL}/relatorios"

separator "10. GERENCIAR EMPRÉSTIMOS (Filtro por Nome 'Aluno')"
# Testa a busca filtrada por nome do aluno
curl -v -b ${COOKIE_FILE} "${BASE_URL}/gerenciarEmprestimos?buscaNome=Aluno"

separator "11. ADMIN ATESTA DEVOLUÇÃO (Livro ID 1, Empréstimo ID 1)"
# O Admin realiza a devolução usando a permissão dele
curl -v -b ${COOKIE_FILE} -c ${COOKIE_FILE} -L -d "emprestimoId=1&livroId=1" "${BASE_URL}/devolucao"

separator "FIM DOS TESTES"