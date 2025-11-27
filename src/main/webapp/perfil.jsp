<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<c:if test="${empty sessionScope.usuarioLogado}">
    <c:redirect url="login.jsp"/>
</c:if>

<!DOCTYPE html>
<html>
<head>
    <title>Meu Perfil</title>
</head>
<body>
    <a href="dashboard.jsp">Voltar ao Painel</a>
    <h1>Editar Meus Dados</h1>

    <c:if test="${not empty msg}">
        <h3 style="color: green">${msg}</h3>
    </c:if>
    <c:if test="${not empty erro}">
        <h3 style="color: red">${erro}</h3>
    </c:if>

    <fieldset style="width: 300px;">
        <legend>Dados da Conta</legend>
        <form action="usuario" method="POST">
            <input type="hidden" name="acao" value="atualizar"> <label>Matrícula (Imutável):</label><br>
            <input type="text" value="${sessionScope.usuarioLogado.matricula}" disabled style="background-color: #eee;"><br><br>

            <label>Email (Imutável):</label><br>
            <input type="text" value="${sessionScope.usuarioLogado.email}" disabled style="background-color: #eee;"><br><br>

            <label>Nome Completo:</label><br>
            <input type="text" name="nome" value="${sessionScope.usuarioLogado.nome}" required><br><br>

            <label>Nova Senha:</label><br>
            <input type="password" name="senha" value="${sessionScope.usuarioLogado.senha}" required><br><br>

            <input type="submit" value="Salvar Alterações">
        </form>
    </fieldset>
    <jsp:include page="footer.jsp"/>
</body>
</html>