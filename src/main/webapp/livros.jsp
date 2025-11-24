<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html>
<head><title>Livros</title></head>
<body>
    <a href="dashboard.jsp">Voltar</a>
    <h2>Acervo</h2>

    <c:if test="${not empty erro}">
        <h3 style="color:red">${erro}</h3>
    </c:if>

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

    <table border="1" width="100%">
        <tr>
            <th>Título</th>
            <th>Autor</th>
            <th>Disponível</th>
            <th>Ação</th>
        </tr>
        <c:forEach var="livro" items="${listaLivros}">
            <tr>
                <td>${livro.titulo}</td>
                <td>${livro.autor}</td>
                <td>${livro.quantidadeDisponivel}</td>
                <td>
                    <c:if test="${livro.quantidadeDisponivel > 0}">
                        <form action="emprestimos" method="POST">
                            <input type="hidden" name="livroId" value="${livro.id}">
                            <input type="submit" value="Emprestar">
                        </form>
                    </c:if>
                    <c:if test="${livro.quantidadeDisponivel == 0}">
                        Indisponível
                    </c:if>
                </td>
            </tr>
        </c:forEach>
    </table>
</body>
</html>