<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<c:if test="${empty sessionScope.usuarioLogado}">
    <c:redirect url="login.jsp"/>
</c:if>

<!DOCTYPE html>
<html>
<head>
    <title>Meu Perfil - Biblioteca</title>
    <link rel="stylesheet" href="css/common.css">
</head>
<body>
    <div class="container">
        <a href="dashboard.jsp" class="link-voltar">← Voltar ao Painel</a>
        <h1>Editar Meus Dados</h1>

        <c:if test="${not empty msg}">
            <div class="msg-sucesso">${msg}</div>
        </c:if>
        <c:if test="${not empty erro}">
            <div class="msg-erro">${erro}</div>
        </c:if>

        <fieldset style="max-width: 350px;">
            <legend>Dados da Conta</legend>
            <form action="usuario" method="POST">
                <input type="hidden" name="acao" value="atualizar">
                
                <label>Matrícula:</label>
                <input type="text" value="${sessionScope.usuarioLogado.matricula}" disabled style="background-color: #eee; width: 100%; margin-bottom: 15px;">

                <label>Email:</label>
                <input type="text" value="${sessionScope.usuarioLogado.email}" disabled style="background-color: #eee; width: 100%; margin-bottom: 15px;">

                <label>Nome Completo:</label>
                <input type="text" name="nome" value="${sessionScope.usuarioLogado.nome}" required style="width: 100%; margin-bottom: 15px;">

                <label>Nova Senha:</label>
                <input type="password" name="senha" value="${sessionScope.usuarioLogado.senha}" required style="width: 100%; margin-bottom: 15px;">

                <input type="submit" value="Salvar Alterações" class="btn-principal">
            </form>
        </fieldset>
    </div>
    <jsp:include page="footer.jsp"/>
</body>
</html>
