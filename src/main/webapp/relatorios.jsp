<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:if test="${empty sessionScope.usuarioLogado or sessionScope.usuarioLogado.tipo != 'admin'}">
    <c:redirect url="login.jsp"/>
</c:if>

<!DOCTYPE html>
<html>
<head>
    <title>Relatórios - Biblioteca</title>
    <link rel="stylesheet" href="css/common.css">
    <link rel="stylesheet" href="css/admin.css">
</head>
<body>
    <div class="admin-container">
        <a href="dashboard.jsp" class="link-voltar">← Voltar ao Painel</a>
        <h1>Relatórios Administrativos</h1>
        <div class="relatorio-secao">
            <h3>Livros Mais Populares</h3>
            <c:choose>
                <c:when test="${empty topLivros}">
                    <p class="msg-vazia">Nenhum dado de empréstimo registrado ainda.</p>
                </c:when>
                <c:otherwise>
                    <table>
                        <thead>
                            <tr>
                                <th>Título do Livro</th>
                                <th>Autor</th>
                                <th>Total de Empréstimos</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="item" items="${topLivros}">
                                <tr>
                                    <td>${item.titulo}</td>
                                    <td>${item.autor}</td>
                                    <td style="text-align: center;">${item.total}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>
        <div class="relatorio-secao">
            <h3>Usuários Mais Ativos</h3>
            <c:choose>
                <c:when test="${empty topUsuarios}">
                    <p class="msg-vazia">Nenhum usuário realizou empréstimos ainda.</p>
                </c:when>
                <c:otherwise>
                    <table>
                        <thead>
                            <tr>
                                <th>Matrícula</th>
                                <th>Nome do Usuário</th>
                                <th>Total de Empréstimos</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="item" items="${topUsuarios}">
                                <tr>
                                    <td>${item.matricula}</td>
                                    <td>${item.nome}</td>
                                    <td style="text-align: center;">${item.total}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>
        <div class="relatorio-secao">
            <h3>Empréstimos em Atraso</h3>
            <c:choose>
                <c:when test="${empty listaAtrasos}">
                    <p class="msg-sucesso">Não há empréstimos atrasados no momento.</p>
                </c:when>
                <c:otherwise>
                    <table>
                        <thead>
                            <tr>
                                <th>Matrícula</th>
                                <th>Nome do Usuário</th>
                                <th>Livro Pendente</th>
                                <th>Data Prevista</th>
                                <th>Dias de Atraso</th>
                                <th>Multa Estimada</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="item" items="${listaAtrasos}">
                                <tr>
                                    <td>${item.matricula}</td>
                                    <td>${item.usuario}</td>
                                    <td>${item.livro}</td>
                                    <td class="texto-atraso">
                                        <fmt:formatDate value="${item.dataPrevista}" pattern="dd/MM/yyyy"/>
                                    </td>
                                    <td class="texto-atraso" style="text-align: center;">
                                        ${item.diasAtraso} dias
                                    </td>
                                    <td style="text-align: center;">
                                        R$ <fmt:formatNumber value="${item.multaEstimada}" minFractionDigits="2"/>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</body>
</html>