<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<c:if test="${empty sessionScope.usuarioLogado or sessionScope.usuarioLogado.tipo != 'admin'}">
    <c:redirect url="login.jsp"/>
</c:if>

<!DOCTYPE html>
<html>
<head>
    <title>Editar Usuário</title>
    <link rel="stylesheet" href="css/common.css">
    <style>
        .form-container { max-width: 400px; padding: 20px; border: 1px solid #ccc; background: white; border-radius: 5px; }
        input, select { width: 100%; margin-bottom: 10px; padding: 5px; }
        .aviso-senha { font-size: 0.8em; color: gray; margin-bottom: 10px; display: block;}
    </style>
</head>
<body>
    <a href="usuario?acao=gerenciar">Voltar para Lista</a>
    <h1>Editar Usuário</h1>

    <div class="form-container">
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
            <span class="aviso-senha">Preencha apenas se desejar redefinir a senha deste usuário.</span>

            <input type="submit" value="Salvar Alterações">
        </form>
    </div>
    <jsp:include page="footer.jsp"/>
</body>
</html>