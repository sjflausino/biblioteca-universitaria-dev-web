<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

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
    <h1>Gerenciar Empréstimos</h1>

    <c:if test="${param.erro == 'AlunoNaoEncontrado'}"><h3 style="color:red">Erro: Matrícula não encontrada.</h3></c:if>
    <c:if test="${param.erro == 'AlunoBloqueado'}"><h3 style="color:red">Erro: Aluno possui pendências ou atrasos.</h3></c:if>
    <c:if test="${param.msg == 'Sucesso' or param.msg == 'EmprestimoSucesso'}"><h3 style="color:green">Empréstimo realizado com sucesso!</h3></c:if>
    <c:if test="${param.msg == 'DevolucaoSucesso'}"><h3 style="color:green">Devolução registrada com sucesso!</h3></c:if>

    <fieldset style="background-color: #f9f9f9;">
        <legend><strong>Novo Empréstimo (Exclusivo Admin)</strong></legend>
        <form action="emprestimos" method="POST">
            <input type="hidden" name="acao" value="adminEmprestar"> <label>Matrícula do Aluno:</label>
            <input type="text" name="matriculaAluno" required placeholder="Ex: 2025001">
            
            <label>ID do Livro:</label>
            <input type="number" name="livroId" required placeholder="ID do Livro">
            
            <input type="submit" value="Registrar Empréstimo">
        </form>
    </fieldset>
    <br>

    <fieldset>
        <legend>Filtrar Empréstimos</legend>
        <form action="emprestimos" method="GET">
            <input type="hidden" name="acao" value="gerenciar"> Aluno: <input type="text" name="buscaNome" value="${param.buscaNome}">
            Matrícula: <input type="text" name="buscaMatricula" value="${param.buscaMatricula}">
            Livro: <input type="text" name="buscaLivro" value="${param.buscaLivro}">
            <input type="submit" value="Filtrar">
            <a href="emprestimos?acao=gerenciar"><input type="button" value="Limpar"></a>
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
                <tr>
                    <td>${emp.matricula}</td>
                    <td>${emp.nome}</td>
                    <td>${emp.titulo}</td>
                    <td>${emp.dataEmp}</td>

                    <c:choose>
                        <c:when test="${emp.multaEstimadaNum > 0}">
                            <td style="color:red; font-weight:bold;">${emp.dataPrev}</td>
                        </c:when>
                        <c:otherwise>
                            <td>${emp.dataPrev}</td>
                        </c:otherwise>
                    </c:choose>

                    <td style="color: orange;">Pendente</td>

                    <td>
                        <c:if test="${emp.multaEstimadaNum > 0}">
                            <span style="color:red">R$ ${emp.multaEstimada}</span>
                        </c:if>
                        <c:if test="${emp.multaEstimadaNum == 0}">-</c:if>
                    </td>

                    <td>
                        <%-- Botão de Devolução do Admin --%>
                        <form action="emprestimos" method="POST" onsubmit="return confirm('Confirmar a devolução de ${emp.titulo} para ${emp.nome}?');">
                            <input type="hidden" name="acao" value="devolver"> <input type="hidden" name="emprestimoId" value="${emp.empId}">
                            <input type="hidden" name="livroId" value="${emp.livroId}">
                            <input type="hidden" name="origem" value="admin"> <input type="submit" value="Atestar Devolução">
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