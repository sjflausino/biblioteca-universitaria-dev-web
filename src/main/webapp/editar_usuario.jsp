<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<c:if test="${empty sessionScope.usuarioLogado or sessionScope.usuarioLogado.tipo != 'admin'}">
    <c:redirect url="login.jsp"/>
</c:if>

<!DOCTYPE html>
<html>
<head>
    <title>Editar Usuário - Biblioteca</title>
    <link rel="stylesheet" href="css/common.css">
    <link rel="stylesheet" href="css/admin.css">
</head>
<body>
    <div class="admin-container">
        <a href="usuario?acao=gerenciar" class="link-voltar">← Voltar para Lista</a>
        <h1>Editar Usuário</h1>

        <div class="form-edicao">
            <form action="usuario" method="POST">
                <input type="hidden" name="acao" value="editarAdmin">
                <input type="hidden" name="id" value="${param.id}">

                <label>Nome Completo:</label>
                <input type="text" name="nome" value="${param.nome}" required>

                <label>Email:</label>
                <input type="email" name="email" value="${param.email}" required>

                <label>Matrícula:</label>
                <input type="text" name="matricula" value="${param.matricula}" required>

                <label>Tipo de Conta:</label>
                <select name="tipo">
                    <option value="aluno" ${param.tipo == 'aluno' ? 'selected' : ''}>Aluno</option>
                    <option value="admin" ${param.tipo == 'admin' ? 'selected' : ''}>Administrador</option>
                </select>

                <label>Nova Senha:</label>
                <input type="password" name="senha" placeholder="Deixe em branco para manter a atual">
                <span class="aviso">Preencha apenas se desejar redefinir a senha.</span>

                <button type="submit" class="btn-salvar">Salvar Alterações</button>
                <a href="usuario?acao=gerenciar" class="btn-cancelar">Cancelar</a>
            </form>
        </div>
    </div>
    <jsp:include page="footer.jsp"/>
</body>
</html>
