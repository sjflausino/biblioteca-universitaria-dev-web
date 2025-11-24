<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Cadastro - Biblioteca</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
        .container { border: 1px solid #ccc; padding: 20px; display: inline-block; width: 300px; text-align: left; }
        .erro { color: red; margin-bottom: 10px; }
        input, select { width: 100%; margin-bottom: 10px; padding: 5px; box-sizing: border-box; }
        input[type="submit"] { background-color: #f0f0f0; cursor: pointer; }
        input[type="submit"]:hover { background-color: #ddd; }
        .links { text-align: center; margin-top: 10px; }
    </style>
</head>
<body>
    <div class="container">
        <h2 style="text-align: center">Nova Conta</h2>
        
        <c:if test="${not empty erro}">
            <div class="erro">${erro}</div>
        </c:if>

        <form action="cadastroUsuario" method="POST">
            <label>Nome Completo:</label>
            <input type="text" name="nome" required>

            <label>Email:</label>
            <input type="email" name="email" required>

            <label>Matrícula:</label>
            <input type="text" name="matricula" required>

            <label>Senha:</label>
            <input type="password" name="senha" required>

            <label>Tipo de Usuário:</label>
            <select name="tipo">
                <option value="aluno">Aluno</option>
                <option value="admin">Administrador</option>
            </select>

            <input type="submit" value="Cadastrar">
        </form>

        <div class="links">
            <a href="login.jsp">Voltar para Login</a>
        </div>
    </div>
</body>
</html>