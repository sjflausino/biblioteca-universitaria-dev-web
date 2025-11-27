<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Login - Biblioteca</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
        .erro { color: red; }
        .container { border: 1px solid #ccc; padding: 20px; display: inline-block; }
    </style>
</head>
<body>
    <div class="container">
        <h2>Acesso à Biblioteca</h2>
        <c:if test="${not empty erro}">
            <p class="erro">${erro}</p>
        </c:if>
        <c:if test="${param.msg == 'cadastrado'}">
            <p style="color: green;">Usuário cadastrado com sucesso!</p>
        </c:if>
        
        <form action="login" method="POST">
            <p>Email: <input type="email" name="email" required></p>
            <p>Senha: <input type="password" name="senha" required></p>
            <input type="submit" value="Entrar">
        </form>
        <br>
        <a href="cadastro.jsp">Criar nova conta</a>
    </div>
    <jsp:include page="footer.jsp"/>
</body>
</html>