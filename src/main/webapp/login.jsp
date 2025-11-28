<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
    <title>Login - Biblioteca</title>
    <link rel="stylesheet" href="css/common.css">
    <link rel="stylesheet" href="css/auth.css">
</head>
<body>
    
    <div class="auth-container">
        <div class="auth-box">
            <h2>Acesso à Biblioteca</h2>
            
            <c:if test="${not empty erro}">
                <div class="msg-erro">Email ou Senha incorretos!</div>
            </c:if>
            <c:if test="${param.msg == 'cadastrado'}">
                <div class="msg-sucesso">Usuário cadastrado com sucesso!</div>
            </c:if>
            
            <form action="login" method="POST">
                <label>Email:</label>
                <input type="email" name="email" required>
                
                <label>Senha:</label>
                <input type="password" name="senha" required>
                
                <input type="submit" value="Entrar">
            </form>
            
            <div class="auth-links">
                <a href="cadastro.jsp">Criar nova conta</a>
            </div>
        </div>
    </div>
    <jsp:include page="footer.jsp"/>
</body>
</html>