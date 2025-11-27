<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:if test="${empty sessionScope.usuarioLogado or sessionScope.usuarioLogado.tipo != 'admin'}">
    <c:redirect url="login.jsp"/>
</c:if>

<!DOCTYPE html>
<html>
<head>
    <title>Gerenciar Empréstimos - Biblioteca</title>
    <link rel="stylesheet" href="css/common.css">
    <link rel="stylesheet" href="css/admin.css">
</head>
<body>
    <div class="admin-container">
        <a href="dashboard.jsp" class="link-voltar">← Voltar ao Painel</a>
        <h1>Gerenciar Empréstimos</h1>

        <c:if test="${param.msg == 'DevolucaoSucesso'}">
            <div class="msg-sucesso">Devolução registrada com sucesso!</div>
        </c:if>
        <c:if test="${param.msg == 'MultaPaga'}">
            <div class="msg-sucesso">Pagamento da multa registrado!</div>
        </c:if>

        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Usuário</th>
                    <th>Livro</th>
                    <th>Data Empréstimo</th>
                    <th>Data Prevista</th>
                    <th>Status</th>
                    <th>Multa</th>
                    <th>Ação</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="emp" items="${listaEmprestimos}">
                    <tr>
                        <td>${emp.id}</td>
                        <td>${emp.usuario.nome}</td>
                        <td>${emp.livro.titulo}</td>
                        <td><fmt:formatDate value="${emp.dataEmprestimo}" pattern="dd/MM/yyyy"/></td>
                        <td><fmt:formatDate value="${emp.dataPrevistaDevolucao}" pattern="dd/MM/yyyy"/></td>
                        <td>
                            <c:choose>
                                <c:when test="${empty emp.dataDevolucaoReal}">
                                    <span class="status-pendente">Pendente</span>
                                </c:when>
                                <c:otherwise>
                                    Devolvido em <fmt:formatDate value="${emp.dataDevolucaoReal}" pattern="dd/MM/yyyy"/>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <c:if test="${emp.multa > 0}">
                                <span class="multa-valor">R$ ${emp.multa}</span>
                            </c:if>
                            <c:if test="${emp.multa == 0}">-</c:if>
                        </td>
                        <td>
                            <c:if test="${empty emp.dataDevolucaoReal}">
                                <form action="emprestimos" method="POST">
                                    <input type="hidden" name="acao" value="devolver">
                                    <input type="hidden" name="emprestimoId" value="${emp.id}">
                                    <input type="hidden" name="livroId" value="${emp.livro.id}">
                                    <input type="hidden" name="origem" value="gerenciar">
                                    <input type="submit" value="Registrar Devolução">
                                </form>
                            </c:if>
                            <c:if test="${not empty emp.dataDevolucaoReal and emp.multa > 0}">
                                <form action="emprestimos" method="POST">
                                    <input type="hidden" name="acao" value="pagarMulta">
                                    <input type="hidden" name="emprestimoId" value="${emp.id}">
                                    <input type="hidden" name="origem" value="gerenciar">
                                    <input type="submit" value="Registrar Pagamento">
                                </form>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty listaEmprestimos}">
                    <tr>
                        <td colspan="8" style="text-align: center; padding: 30px;">
                            <span class="msg-vazia">Nenhum empréstimo registrado no sistema.</span>
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
    <jsp:include page="footer.jsp"/>
</body>
</html>