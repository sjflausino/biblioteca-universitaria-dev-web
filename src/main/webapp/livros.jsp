<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html>
<head>
    <title>Livros</title>
    <style>
        fieldset { margin-bottom: 15px; padding: 10px; border: 1px solid #ccc; }
        legend { font-weight: bold; }
        .btn-limpar { background-color: #f0f0f0; border: 1px solid #999; cursor: pointer; padding: 2px 6px; text-decoration: none; color: black; font-size: 13px;}
    </style>
</head>
<body>
    <a href="dashboard.jsp">Voltar</a>
    <h2>Acervo</h2>

    <%-- Tratamento de erros --%>
    <c:if test="${not empty erro}">
        <h3 style="color:red">${erro}</h3>
    </c:if>
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

    <c:if test="${sessionScope.usuarioLogado.tipo == 'admin'}">
        <fieldset style="background-color: #fff8dc;"> <legend>Cadastrar Novo Livro</legend>
            <form action="livros" method="POST">
                Titulo: <input type="text" name="titulo" required>
                Autor: <input type="text" name="autor" required>
                Editora: <input type="text" name="editora">
                ISBN: <input type="text" name="isbn">
                Qtd: <input type="number" name="quantidade" value="1" min="1" style="width: 50px;">
                <input type="submit" value="Cadastrar">
            </form>
        </fieldset>
    </c:if>

    <fieldset style="background-color: #f0f8ff;"> <legend>Pesquisar no Acervo</legend>
        <form action="livros" method="GET">
            <input type="text" name="busca" placeholder="Digite sua busca..." value="${param.busca}" required style="width: 250px;">
            
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

    <hr>

    <%-- 3. Listagem de Livros --%>
    <table border="1" width="100%">
        <thead>
            <tr>
                <th>ISBN</th>
                <th>Título</th>
                <th>Autor</th>
                <th>Editora</th>
                <th>Disponível</th>
                <th>Ação</th>
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
                        <c:if test="${livro.quantidadeDisponivel > 0}">
                            <form action="emprestimos" method="POST">
                                <input type="hidden" name="livroId" value="${livro.id}">
                                <input type="submit" value="Emprestar">
                            </form>
                        </c:if>
                        <c:if test="${livro.quantidadeDisponivel == 0}">
                            <span style="color: gray; font-style: italic;">Indisponível</span>
                        </c:if>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty listaLivros}">
                <tr>
                    <td colspan="6" align="center" style="padding: 20px;">Nenhum livro encontrado com os critérios informados.</td>
                </tr>
            </c:if>
        </tbody>
    </table>
</body>
</html>