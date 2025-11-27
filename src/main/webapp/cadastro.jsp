<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Cadastro - Biblioteca</title>
    <link rel="stylesheet" href="css/common.css">
    <link rel="stylesheet" href="css/auth.css">
</head>
<body>
    <div class="auth-container">
        <div class="auth-box">
            <h2>Nova Conta</h2>
            
            <c:if test="${not empty erro}">
                <div class="msg-erro">${erro}</div>
            </c:if>

            <form action="usuario" method="POST">
                <input type="hidden" name="acao" value="cadastrar">

                <label>Nome Completo:</label>
                <input type="text" name="nome" value="${param.nome}" required>

                <label>Email:</label>
                <input type="email" name="email" value="${param.email}" required>

                <label>Matrícula:</label>
                <input type="text" name="matricula" value="${param.matricula}" required>

                <label>Senha:</label>
                <input type="password" name="senha" required>

                <label>Tipo de Usuário:</label>
                <select name="tipo">
                    <option value="aluno" ${param.tipo == 'aluno' ? 'selected' : ''}>Aluno</option>
                    <option value="admin" ${param.tipo == 'admin' ? 'selected' : ''}>Administrador</option>
                </select>

                <input type="submit" value="Cadastrar">
            </form>

            <div class="auth-links">
                <a href="login.jsp">Voltar para Login</a>
            </div>
        </div>
    </div>
</body>
</html>
