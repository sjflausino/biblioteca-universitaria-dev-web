<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html>
<head>
    <title>Livros</title>
</head>
<body>
    <a href="dashboard.jsp">Voltar</a>
    <h2>Acervo</h2>

    <%-- Tratamento de erros vindos de Forward (request scope) --%>
    <c:if test="${not empty erro}">
        <h3 style="color:red">${erro}</h3>
    </c:if>

    <%-- Tratamento de erros vindos de Redirect (URL parameters) --%>
    <c:if test="${param.erro == 'LivroJaComUsuario'}">
        <h3 style="color:red">Você já possui um exemplar deste livro pendente de devolução!</h3>
    </c:if>
    <c:if test="${param.erro == 'Bloqueado'}">
        <h3 style="color:red">Empréstimo negado: Pendências financeiras ou livros em atraso.</h3>
    </c:if>
    <c:if test="${param.erro == 'DadosInvalidos'}">
        <h3 style="color:red">Dados inválidos para a operação.</h3>
    </c:if>
    <c:if test="${param.erro == 'LivroNaoInformado'}">
        <h3 style="color:red">Erro: Nenhum livro selecionado.</h3>
    </c:if>

    <%-- Área Administrativa: Cadastro de Livros --%>
    <c:if test="${sessionScope.usuarioLogado.tipo == 'admin'}">
        <fieldset>
            <legend>Cadastrar Novo Livro</legend>
            <form action="livros" method="POST">
                Titulo: <input type="text" name="titulo" required>
                Autor: <input type="text" name="autor" required>
                Editora: <input type="text" name="editora">
                ISBN: <input type="text" name="isbn">
                Qtd: <input type="number" name="quantidade" value="1" min="1">
                <input type="submit" value="Cadastrar">
            </form>
        </fieldset>
    </c:if>

    <hr>

    <%-- Listagem de Livros --%>
    <table border="1" width="100%">
        <tr>
            <th>Título</th>
            <th>Autor</th>
            <th>Editora</th>
            <th>Disponível</th>
            <th>Ação</th>
        </tr>
        <c:forEach var="livro" items="${listaLivros}">
            <tr>
                <td>${livro.titulo}</td>
                <td>${livro.autor}</td>
                <td>${livro.editora}</td>
                <td>${livro.quantidadeDisponivel}</td>
                <td>
                    <c:if test="${livro.quantidadeDisponivel > 0}">
                        <form action="emprestimos" method="POST">
                            <input type="hidden" name="livroId" value="${livro.id}">
                            <input type="submit" value="Emprestar">
                        </form>
                    </c:if>
                    <c:if test="${livro.quantidadeDisponivel == 0}">
                        <span style="color: gray;">Indisponível</span>
                    </c:if>
                </td>
            </tr>
        </c:forEach>
    </table>
</body>
</html>