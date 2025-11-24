<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:if test="${empty sessionScope.usuarioLogado or sessionScope.usuarioLogado.tipo != 'admin'}">
    <c:redirect url="login.jsp"/>
</c:if>

<!DOCTYPE html>
<html>
<head>
    <title>Relatórios Administrativos</title>
</head>
<body>
    <a href="dashboard.jsp">Voltar</a>
    
    <h1>Relatórios Administrativos</h1>

    <h3>Livros Mais Populares</h3>
    <c:choose>
        <c:when test="${empty topLivros}">
            <p>Nenhum dado de empréstimo registrado ainda.</p>
        </c:when>
        <c:otherwise>
            <table border="1" width="100%">
                <tr>
                    <th>Título do Livro</th>
                    <th>Autor</th>
                    <th>Total de Empréstimos</th>
                </tr>
                <c:forEach var="item" items="${topLivros}">
                    <tr>
                        <td>${item.titulo}</td>
                        <td>${item.autor}</td>
                        <td>${item.total}</td>
                    </tr>
                </c:forEach>
            </table>
        </c:otherwise>
    </c:choose>

    <hr>

    <h3>Usuários Mais Ativos (Mais Empréstimos)</h3>
    <c:choose>
        <c:when test="${empty topUsuarios}">
            <p>Nenhum usuário realizou empréstimos ainda.</p>
        </c:when>
        <c:otherwise>
            <table border="1" width="100%">
                <tr>
                    <th>Matrícula</th>
                    <th>Nome do Usuário</th>
                    <th>Total de Empréstimos</th>
                </tr>
                <c:forEach var="item" items="${topUsuarios}">
                    <tr>
                        <td>${item.matricula}</td>
                        <td>${item.nome}</td>
                        <td>${item.total}</td>
                    </tr>
                </c:forEach>
            </table>
        </c:otherwise>
    </c:choose>

    <hr>

    <h3>Empréstimos em Atraso</h3>
    <c:choose>
        <c:when test="${empty listaAtrasos}">
            <p style="color: green;">Não há empréstimos atrasados no momento.</p>
        </c:when>
        <c:otherwise>
            <table border="1" width="100%">
                <tr>
                    <th>Matrícula</th>
                    <th>Nome do Usuário</th>
                    <th>Livro Pendente</th>
                    <th>Data Prevista</th>
                    <th>Dias de Atraso</th>
                    <th>Multa Estimada (R$)</th>
                </tr>
                <c:forEach var="item" items="${listaAtrasos}">
                    <tr>
                        <td>${item.matricula}</td>
                        <td>${item.usuario}</td>
                        <td>${item.livro}</td>
                        <td style="color: red;">
                            <fmt:formatDate value="${item.dataPrevista}" pattern="dd/MM/yyyy"/>
                        </td>
                        <td style="font-weight: bold; color: red;">
                            ${item.diasAtraso} dias
                        </td>
                        <td>
                            R$ <fmt:formatNumber value="${item.multaEstimada}" minFractionDigits="2"/>
                        </td>
                    </tr>
                </c:forEach>
            </table>
        </c:otherwise>
    </c:choose>

</body>
</html>