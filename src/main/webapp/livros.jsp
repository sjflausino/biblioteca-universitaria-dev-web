<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html>
<head>
    <title>Acervo - Biblioteca</title>
    <link rel="stylesheet" href="css/common.css">
    <link rel="stylesheet" href="css/livros.css">
</head>
<body>
    <jsp:include page="nav.jsp">
        <jsp:param name="secao" value="usuario"/>
        <jsp:param name="pagina" value="livros"/>
    </jsp:include>
    <div class="container">
        <h2>Acervo de Livros</h2>

        <c:choose>
            <c:when test="${param.msg == 'LivroExcluido'}">
                <div class="msg-sucesso">Livro excluído com sucesso!</div>
            </c:when>
            <c:when test="${param.msg == 'LivroEditado'}">
                <div class="msg-sucesso">Livro atualizado com sucesso!</div>
            </c:when>
            <c:when test="${param.msg == 'LivroCadastrado'}">
                <div class="msg-sucesso">Livro cadastrado com sucesso!</div>
            </c:when>
            <c:when test="${param.msg == 'EmprestimoSucesso'}">
                <div class="msg-sucesso">Empréstimo realizado com sucesso! Devolução em 7 dias.</div>
            </c:when>
        </c:choose>

        <c:choose>
            <c:when test="${not empty erro}">
                <div class="msg-erro">${erro}</div>
            </c:when>
            <c:when test="${param.erro == 'LivroComHistorico'}">
                <div class="msg-erro">Não é possível excluir este livro pois ele possui empréstimos ativos ou histórico!</div>
            </c:when>
            <c:when test="${param.erro == 'LivroJaComUsuario'}">
                <div class="msg-erro">Você já possui um exemplar deste livro pendente de devolução!</div>
            </c:when>
            <c:when test="${param.erro == 'Bloqueado'}">
                <div class="msg-erro">Empréstimo negado: Pendências financeiras ou livros em atraso.</div>
            </c:when>
            <c:when test="${param.erro == 'DadosInvalidos'}">
                <div class="msg-erro">Dados inválidos para a operação.</div>
            </c:when>
            <c:when test="${param.erro == 'LivroNaoInformado'}">
                <div class="msg-erro">Erro: Nenhum livro selecionado.</div>
            </c:when>
        </c:choose>

        <c:if test="${sessionScope.usuarioLogado.tipo == 'admin'}">
            <fieldset class="fieldset-cadastro">
                <legend>Cadastrar Novo Livro</legend>
                <form action="livros" method="POST">
                    Título: <input type="text" name="titulo" required>
                    Autor: <input type="text" name="autor" required>
                    Editora: <input type="text" name="editora">
                    ISBN: <input type="text" name="isbn">
                    Qtd: <input type="number" name="quantidade" value="1" min="1" style="width: 60px;">
                    <input type="submit" value="Cadastrar">
                </form>
            </fieldset>
        </c:if>

        <fieldset class="fieldset-pesquisa">
            <legend>Pesquisar no Acervo</legend>
            <form action="livros" method="GET">
                <input type="text" name="busca" placeholder="Digite sua busca..." value="${param.busca}" required style="width: 200px;">
                <select name="tipo">
                    <option value="titulo" ${param.tipo == 'titulo' ? 'selected' : ''}>Título</option>
                    <option value="autor" ${param.tipo == 'autor' ? 'selected' : ''}>Autor</option>
                    <option value="isbn" ${param.tipo == 'isbn' ? 'selected' : ''}>ISBN</option>
                </select>
                <input type="submit" value="Filtrar">
                <c:if test="${not empty param.busca}">
                    <a href="livros"><button type="button" class="btn-limpar">Limpar Filtros</button></a>
                </c:if>
            </form>
        </fieldset>

        <table>
            <thead>
                <tr>
                    <th>ISBN</th>
                    <th>Título</th>
                    <th>Autor</th>
                    <th>Editora</th>
                    <th>Disponível</th>
                    <th style="width: 180px;">Ações</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="livro" items="${listaLivros}">
                    <tr>
                        <td>${livro.isbn}</td>
                        <td>${livro.titulo}</td>
                        <td>${livro.autor}</td>
                        <td>${livro.editora}</td>
                        <td style="text-align: center;">${livro.quantidadeDisponivel}</td>
                        <td style="text-align: center;">
                            <%-- Ação de Empréstimo --%>
                            <c:if test="${livro.quantidadeDisponivel > 0}">
                                <form action="emprestimos" method="POST">
                                    <input type="hidden" name="acao" value="emprestar">
                                    <input type="hidden" name="livroId" value="${livro.id}">
                                    <input type="submit" value="Emprestar">
                                </form>
                            </c:if>
                            <c:if test="${livro.quantidadeDisponivel == 0}">
                                <span class="status-indisponivel">Indisponível</span>
                            </c:if>

                            <c:if test="${sessionScope.usuarioLogado.tipo == 'admin'}">
                                <div class="acoes-admin">
                                    <a href="editar_livro.jsp?id=${livro.id}&titulo=${livro.titulo}&autor=${livro.autor}&editora=${livro.editora}&isbn=${livro.isbn}&quantidade=${livro.quantidadeDisponivel}">
                                        <button type="button" class="btn-editar">Editar</button>
                                    </a>
                                    <form action="livros" method="POST" onsubmit="return confirm('Tem certeza que deseja excluir?');">
                                        <input type="hidden" name="acao" value="excluir">
                                        <input type="hidden" name="id" value="${livro.id}">
                                        <input type="submit" value="Excluir" class="btn-excluir">
                                    </form>
                                </div>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty listaLivros}">
                    <tr>
                        <td colspan="6" style="text-align: center; padding: 30px; color: #666;">
                            Nenhum livro encontrado.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
    <jsp:include page="footer.jsp"/>
</body>
</html>
