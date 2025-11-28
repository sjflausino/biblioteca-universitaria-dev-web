<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
    <jsp:include page="nav.jsp" />
    <div class="admin-container">
        <a href="dashboard.jsp" class="link-voltar">← Voltar ao Painel</a>
        <h1>Gerenciar Empréstimos Ativos</h1>

        <c:if test="${param.msg == 'DevolucaoSucesso'}"><div class="msg-sucesso">Devolução realizada com sucesso!</div></c:if>
        <c:if test="${param.msg == 'EmprestimoSucesso'}"><div class="msg-sucesso">Empréstimo realizado!</div></c:if>
        <c:if test="${param.erro == 'DadosIncompletos'}"><div class="msg-erro">Preencha todos os dados.</div></c:if>
        <c:if test="${param.erro == 'AlunoNaoEncontrado'}"><div class="msg-erro">Aluno não encontrado.</div></c:if>

        <fieldset class="fieldset-novo-emprestimo" style="background: #fff; padding: 15px; margin-bottom: 20px; border: 1px solid #ddd;">
            <legend>Novo Empréstimo Presencial</legend>
            <form action="emprestimos" method="POST">
                <input type="hidden" name="acao" value="adminEmprestar">
                <input type="text" name="matriculaAluno" required placeholder="Matrícula do Aluno" style="margin-right: 10px;">
                <input type="number" name="livroId" required placeholder="ID do Livro" style="width: 100px; margin-right: 10px;">
                <button type="submit" class="btn-adicionar">Emprestar</button>
            </form>
        </fieldset>

        <form action="emprestimos" method="GET" style="margin-bottom: 20px;">
            <input type="hidden" name="acao" value="gerenciar">
            <strong>Filtrar:</strong>
            <input type="text" name="buscaNome" placeholder="Nome do Aluno" value="${param.buscaNome}">
            <input type="text" name="buscaLivro" placeholder="Título do Livro" value="${param.buscaLivro}">
            <button type="submit">Buscar</button>
            <a href="emprestimos?acao=gerenciar"><button type="button">Limpar</button></a>
        </form>

        <table border="1">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Livro</th>
                    <th>Aluno</th>
                    <th>Data Emp.</th>
                    <th>Prev. Devolução</th>
                    <th>Situação</th>
                    <th>Ações</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="item" items="${listaAtivos}">
                    <tr>
                        <td>${item.empId}</td>
                        <td>
                            ${item.titulo} <br>
                            <small style="color:gray;">(ID: ${item.livroId})</small>
                        </td>
                        <td>
                            ${item.nome} <br>
                            <small style="color:gray;">(Mat: ${item.matricula})</small>
                        </td>
                        <td><fmt:formatDate value="${item.dataEmp}" pattern="dd/MM/yyyy"/></td>
                        <td>
                            <fmt:formatDate value="${item.dataPrev}" pattern="dd/MM/yyyy"/>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${item.multaEstimada > 0}">
                                    <span style="color: red; font-weight: bold;">ATRASADO</span><br>
                                    <small>Multa est.: R$ <fmt:formatNumber value="${item.multaEstimada}" minFractionDigits="2"/></small>
                                </c:when>
                                <c:otherwise>
                                    <span style="color: green;">No Prazo</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td style="text-align: center;">
                            <form action="emprestimos" method="POST" onsubmit="return confirm('Confirmar devolução do livro ${item.titulo}?');">
                                <input type="hidden" name="acao" value="devolver">
                                <input type="hidden" name="emprestimoId" value="${item.empId}">
                                <input type="hidden" name="livroId" value="${item.livroId}">
                                <input type="hidden" name="origem" value="admin">
                                <button type="submit" class="btn-editar" style="background-color: #28a745; border-color: #28a745; color: white;">Devolver / Baixar</button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
                
                <c:if test="${empty listaAtivos}">
                    <tr>
                        <td colspan="7" align="center" style="padding: 20px; color: #666;">
                            Nenhum empréstimo ativo encontrado no momento.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
    <jsp:include page="footer.jsp"/>
</body>
</html>