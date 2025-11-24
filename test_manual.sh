#!/bin/bash

BASE_URL="http://localhost:8080/biblioteca"
COOKIE_FILE="cookies.txt"

echo "--- 1. REINICIANDO (Limpar Cookies) ---"
rm -f ${COOKIE_FILE}

echo -e "\n--- 2. CADASTRAR USUÁRIO (ADMIN) ---"
curl -v -c ${COOKIE_FILE} -L -d "nome=Admin&email=admin@teste.com&matricula=ADM999&senha=admin&tipo=admin" "${BASE_URL}/cadastroUsuario"

echo -e "\n\n--- 3. LOGIN (Como Admin para cadastrar livro) ---"
curl -v -b ${COOKIE_FILE} -c ${COOKIE_FILE} -L -d "email=admin@teste.com&senha=admin" "${BASE_URL}/login"

echo -e "\n\n--- 4. CADASTRAR LIVRO ---"
# Usando formato de uma linha para garantir envio correto
curl -v -b ${COOKIE_FILE} -c ${COOKIE_FILE} -L -d "titulo=JavaWeb&autor=DevMaster&editora=Tech&isbn=12345&quantidade=5" "${BASE_URL}/livros"

echo -e "\n\n--- 5. CADASTRAR USUÁRIO COMUM (Para pegar emprestado) ---"
curl -v -b ${COOKIE_FILE} -c ${COOKIE_FILE} -L -d "nome=Aluno&email=aluno@teste.com&matricula=ALU001&senha=123&tipo=aluno" "${BASE_URL}/cadastroUsuario"

echo -e "\n\n--- 6. LOGIN (Como Aluno) ---"
# Sobrescreve o cookie com sessão do aluno
curl -v -c ${COOKIE_FILE} -L -d "email=aluno@teste.com&senha=123" "${BASE_URL}/login"

echo -e "\n\n--- 7. REALIZAR EMPRÉSTIMO (Livro ID 1) ---"
# Assumindo que o livro criado tem ID 1.
curl -v -b ${COOKIE_FILE} -c ${COOKIE_FILE} -L -d "livroId=1" "${BASE_URL}/emprestimos"

echo -e "\n\n--- 8. VERIFICAR HISTÓRICO ---"
curl -b ${COOKIE_FILE} "${BASE_URL}/emprestimos"

echo -e "\n\n--- 9. DEVOLVER LIVRO ---"
curl -v -b ${COOKIE_FILE} -c ${COOKIE_FILE} -L -d "emprestimoId=1&livroId=1" "${BASE_URL}/devolucao"

echo -e "\n\n--- FIM ---"