<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html>
<head>
    <title>Meus Empréstimos</title>
    <link rel="stylesheet" href="css/common.css">
    <link rel="stylesheet" href="css/historico.css">
</head>
<body>
    <a href="dashboard.jsp">Voltar</a>
    <h2>Histórico de Empréstimos</h2>
    
    <c:if test="${param.msg == 'DevolucaoSucesso'}"><h3 class="msg-sucesso">Livro devolvido com sucesso!</h3></c:if>
    <c:if test="${param.msg == 'MultaPaga'}"><h3 class="msg-sucesso">Pagamento da multa registrado!</h3></c:if>

    <table border="1" width="100%">
        <tr>
            <th>Livro</th>
            <th>Data Empréstimo</th>
            <th>Data Prevista</th>
            <th>Data Devolução</th>
            <th>Multa (R$)</th>
            <th>Ação</th>
        </tr>
        <c:forEach var="emp" items="${meusEmprestimos}">
            <tr>
                <td>${emp.livro.titulo}</td>
                <td><fmt:formatDate value="${emp.dataEmprestimo}" pattern="dd/MM/yyyy"/></td>
                <td><fmt:formatDate value="${emp.dataPrevistaDevolucao}" pattern="dd/MM/yyyy"/></td>
                <td>
                    <c:choose>
                        <c:when test="${empty emp.dataDevolucaoReal}">
                            <span class="status-pendente">Pendente</span>
                        </c:when>
                        <c:otherwise>
                            <fmt:formatDate value="${emp.dataDevolucaoReal}" pattern="dd/MM/yyyy"/>
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
                    <%-- Formulário DEVOLVER --%>
                    <c:if test="${empty emp.dataDevolucaoReal}">
                        <form action="devolucao" method="POST" onsubmit="return confirm('Confirmar a devolução de ${emp.livro.titulo}?');">
                            <input type="hidden" name="emprestimoId" value="${emp.id}">
                            <input type="hidden" name="livroId" value="${emp.livro.id}">
                            <input type="submit" value="Devolver Livro">
                        </form>
                    </c:if>
                    
                    <%-- Formulário PAGAR MULTA --%>
                    <c:if test="${not empty emp.dataDevolucaoReal and emp.multa > 0}">
                        <form action="emprestimos" method="POST">
                            <input type="hidden" name="acao" value="pagarMulta"> <input type="hidden" name="emprestimoId" value="${emp.id}">
                            <input type="submit" value="Pagar Multa">
                        </form>
                    </c:if>
                </td>
            </tr>
        </c:forEach>
        <c:if test="${empty meusEmprestimos}">
            <tr>
                <td colspan="6" align="center" class="msg-lista-vazia">
                    Você ainda não possui empréstimos registrados.
                </td>
            </tr>
        </c:if>
    </table>
</body>
</html>