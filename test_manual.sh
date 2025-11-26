#!/bin/bash

BASE_URL="http://localhost:8080/biblioteca"
COOKIE_FILE="cookies.txt"

# Função para formatação visual
separator() {
    echo -e "\n\n=================================================="
    echo -e "TESTE: $1"
    echo "=================================================="
}

# Limpeza inicial
rm -f ${COOKIE_FILE}
clear

echo "INICIANDO BATERIA DE TESTES COMPLETA..."
echo "Nota: Este script assume que o banco de dados foi reiniciado (IDs sequenciais a partir de 1)."

# ==============================================================================
# 1. GESTÃO DE USUÁRIOS E AUTENTICAÇÃO
# ==============================================================================

separator "1.1. Cadastrar Administrador"
curl -s -o /dev/null -w "%{http_code}" -c ${COOKIE_FILE} -L -d "acao=cadastrar&nome=Admin&email=admin@teste.com&matricula=ADM001&senha=admin&tipo=admin" "${BASE_URL}/usuario"

separator "1.2. Cadastrar Aluno 1 (Sandro)"
curl -s -o /dev/null -w "%{http_code}" -b ${COOKIE_FILE} -c ${COOKIE_FILE} -L -d "acao=cadastrar&nome=Sandro&email=sandro@teste.com&matricula=2025001&senha=123&tipo=aluno" "${BASE_URL}/usuario"

separator "1.3. Cadastrar Aluno 2 (Maria)"
curl -s -o /dev/null -w "%{http_code}" -b ${COOKIE_FILE} -c ${COOKIE_FILE} -L -d "acao=cadastrar&nome=Maria&email=maria@teste.com&matricula=2025002&senha=123&tipo=aluno" "${BASE_URL}/usuario"

separator "1.4. Login Falha (Senha Errada)"
curl -v -b ${COOKIE_FILE} -c ${COOKIE_FILE} -L -d "email=admin@teste.com&senha=errada" "${BASE_URL}/login" 2>&1 | grep "Usuário ou Senha incorretos"

separator "1.5. Login Sucesso (Admin)"
curl -s -o /dev/null -w "%{http_code}" -b ${COOKIE_FILE} -c ${COOKIE_FILE} -L -d "email=admin@teste.com&senha=admin" "${BASE_URL}/login"

# ==============================================================================
# 2. GESTÃO DE ACERVO (ADMIN)
# ==============================================================================

separator "2.1. Cadastrar Livro A (Estoque Alto: 10)"
# ID esperado: 1
curl -v -b ${COOKIE_FILE} -c ${COOKIE_FILE} -L -d "titulo=Java Como Programar&autor=Deitel&editora=Pearson&isbn=978-1&quantidade=10" "${BASE_URL}/livros"

separator "2.2. Cadastrar Livro B (Estoque Baixo: 1)"
# ID esperado: 2
curl -v -b ${COOKIE_FILE} -c ${COOKIE_FILE} -L -d "titulo=Engenharia de Software&autor=Pressman&editora=Bookman&isbn=978-2&quantidade=1" "${BASE_URL}/livros"

separator "2.3. Cadastrar Livro C (Para Exclusão)"
# ID esperado: 3
curl -v -b ${COOKIE_FILE} -c ${COOKIE_FILE} -L -d "titulo=Livro Ruim&autor=Ninguem&editora=Nenhuma&isbn=000-0&quantidade=5" "${BASE_URL}/livros"

separator "2.4. Editar Livro A (Alterar Título e Estoque)"
# A lógica do servlet ajusta a disponibilidade baseado na diferença do total
curl -v -b ${COOKIE_FILE} -c ${COOKIE_FILE} -L -d "acao=editar&id=1&titulo=Java: Como Programar (Edição Atualizada)&autor=Deitel&editora=Pearson&isbn=978-1&quantidade=12" "${BASE_URL}/livros"

separator "2.5. Excluir Livro C (Sem histórico)"
curl -v -b ${COOKIE_FILE} -c ${COOKIE_FILE} -L -d "acao=excluir&id=3" "${BASE_URL}/livros"

separator "2.6. Listar Livros (Filtro por Título 'Java')"
curl -v -b ${COOKIE_FILE} "${BASE_URL}/livros?busca=Java&tipo=titulo"

# ==============================================================================
# 3. FLUXO DE EMPRÉSTIMO (ALUNO)
# ==============================================================================

separator "3.1. Login Aluno 1 (Sandro)"
curl -s -o /dev/null -w "%{http_code}" -c ${COOKIE_FILE} -L -d "email=sandro@teste.com&senha=123" "${BASE_URL}/login"

separator "3.2. Sandro pega Livro A (ID 1) - SUCESSO"
curl -v -b ${COOKIE_FILE} -c ${COOKIE_FILE} -L -d "acao=emprestar&livroId=1" "${BASE_URL}/emprestimos"

separator "3.3. Sandro tenta pegar Livro A novamente (ID 1) - FALHA (Duplicidade)"
# Deve redirecionar com erro=LivroJaComUsuario
curl -v -b ${COOKIE_FILE} -c ${COOKIE_FILE} -L -d "acao=emprestar&livroId=1" "${BASE_URL}/emprestimos" 2>&1 | grep "LivroJaComUsuario"

separator "3.4. Sandro pega Livro B (ID 2) - SUCESSO (Zera estoque)"
curl -v -b ${COOKIE_FILE} -c ${COOKIE_FILE} -L -d "acao=emprestar&livroId=2" "${BASE_URL}/emprestimos"

separator "3.5. Ver Meus Empréstimos"
curl -v -b ${COOKIE_FILE} "${BASE_URL}/emprestimos"

separator "3.6. Atualizar Perfil (Mudar senha)"
curl -v -b ${COOKIE_FILE} -c ${COOKIE_FILE} -L -d "acao=atualizar&nome=Sandro Atualizado&senha=12345" "${BASE_URL}/usuario"

# ==============================================================================
# 4. REGRAS DE ESTOQUE E ADMINISTRAÇÃO
# ==============================================================================

separator "4.1. Login Aluno 2 (Maria)"
curl -s -o /dev/null -w "%{http_code}" -c ${COOKIE_FILE} -L -d "email=maria@teste.com&senha=123" "${BASE_URL}/login"

separator "4.2. Maria tenta pegar Livro B (ID 2) - FALHA (Indisponível)"
# O botão nem apareceria na view, mas forçamos o POST. Deve cair na exception ou validação.
curl -v -b ${COOKIE_FILE} -c ${COOKIE_FILE} -L -d "acao=emprestar&livroId=2" "${BASE_URL}/emprestimos"

separator "4.3. Login Admin"
curl -s -o /dev/null -w "%{http_code}" -c ${COOKIE_FILE} -L -d "email=admin@teste.com&senha=admin" "${BASE_URL}/login"

separator "4.4. Admin tenta excluir Livro A (ID 1) - FALHA (Tem histórico)"
# Deve redirecionar com erro=LivroComHistorico
curl -v -b ${COOKIE_FILE} -c ${COOKIE_FILE} -L -d "acao=excluir&id=1" "${BASE_URL}/livros" 2>&1 | grep "LivroComHistorico"

separator "4.5. Admin realiza empréstimo para Maria (Livro A - ID 1)"
curl -v -b ${COOKIE_FILE} -c ${COOKIE_FILE} -L -d "acao=adminEmprestar&matriculaAluno=2025002&livroId=1" "${BASE_URL}/emprestimos"

separator "4.6. Gerenciar Empréstimos (Filtrar por Sandro)"
curl -v -b ${COOKIE_FILE} "${BASE_URL}/emprestimos?acao=gerenciar&buscaNome=Sandro"

separator "4.7. Relatórios Administrativos"
curl -v -b ${COOKIE_FILE} "${BASE_URL}/relatorios"

# ==============================================================================
# 5. DEVOLUÇÃO
# ==============================================================================

separator "5.1. Admin Devolve Livro A de Sandro"
# Assumindo que o ID do empréstimo seja 1 (primeiro feito)
curl -v -b ${COOKIE_FILE} -c ${COOKIE_FILE} -L -d "acao=devolver&origem=admin&emprestimoId=1&livroId=1" "${BASE_URL}/emprestimos"

separator "5.2. Verificar aumento de estoque no Livro A"
curl -v -b ${COOKIE_FILE} "${BASE_URL}/livros?busca=Java&tipo=titulo"

echo -e "\n\n=================================================="
echo "FIM DA BATERIA DE TESTES"
echo "Verifique as saídas acima para códigos HTTP 200/302 e mensagens de erro esperadas."
echo "=================================================="