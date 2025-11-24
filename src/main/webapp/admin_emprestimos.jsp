<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%-- Segurança na View --%>
<c:if test="${empty sessionScope.usuarioLogado or sessionScope.usuarioLogado.tipo != 'admin'}">
    <c:redirect url="login.jsp"/>
</c:if>

<!DOCTYPE html>
<html>
<head>
    <title>Gerenciar Empréstimos - Admin</title>
</head>
<body>
    <a href="dashboard.jsp">Voltar ao Painel</a>
    <h1>Gerenciar Empréstimos Ativos</h1>

    <fieldset>
        <legend>Filtrar Empréstimos</legend>
        <form action="gerenciarEmprestimos" method="GET">
            Aluno: <input type="text" name="buscaNome" value="${param.buscaNome}">
            Matrícula: <input type="text" name="buscaMatricula" value="${param.buscaMatricula}">
            Livro: <input type="text" name="buscaLivro" value="${param.buscaLivro}">
            <input type="submit" value="Filtrar">
            <a href="gerenciarEmprestimos"><input type="button" value="Limpar"></a>
        </form>
    </fieldset>

    <br>

    <table border="1" width="100%">
        <thead>
            <tr>
                <th>Matrícula</th>
                <th>Aluno</th>
                <th>Livro</th>
                <th>Data Empréstimo</th>
                <th>Data Prevista</th>
                <th>Data Devolução</th>
                <th>Multa (R$)</th>
                <th>Ação</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="emp" items="${listaAtivos}">
                <c:set var="atrasado" value="${emp.multaEstimada > 0}" />
                
                <tr>
                    <td>${emp.matricula}</td>
                    <td>${emp.nome}</td>
                    <td>${emp.titulo}</td>
                    <td><fmt:formatDate value="${emp.dataEmp}" pattern="dd/MM/yyyy"/></td>
                    
                    <%-- Data Prevista (destaque se atrasado) --%>
                    <td style="${atrasado ? 'color:red; font-weight:bold;' : ''}">
                        <fmt:formatDate value="${emp.dataPrev}" pattern="dd/MM/yyyy"/>
                    </td>

                    <%-- Data Devolução (Sempre Pendente aqui) --%>
                    <td style="color: orange;">Pendente</td>

                    <%-- Multa Estimada --%>
                    <td>
                        <c:if test="${emp.multaEstimada > 0}">
                            <span style="color:red">R$ ${emp.multaEstimada}</span>
                        </c:if>
                        <c:if test="${emp.multaEstimada == 0}">-</c:if>
                    </td>

                    <td>
                        <form action="devolucao" method="POST" onsubmit="return confirm('Confirmar a devolução de ${emp.titulo} para ${emp.nome}?');">
                            <input type="hidden" name="emprestimoId" value="${emp.empId}">
                            <input type="hidden" name="livroId" value="${emp.livroId}">
                            <input type="submit" value="Atestar Devolução">
                        </form>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty listaAtivos}">
                <tr><td colspan="8" align="center">Nenhum empréstimo ativo encontrado.</td></tr>
            </c:if>
        </tbody>
    </table>

</body>
</html>