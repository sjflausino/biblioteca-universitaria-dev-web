<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<c:if test="${empty sessionScope.usuarioLogado}">
    <c:redirect url="login.jsp"/>
</c:if>

<!DOCTYPE html>
<html>
<head>
    <title>Dashboard</title>
</head>
<body>
    <h1>Bem-vindo, ${sessionScope.usuarioLogado.nome}!</h1>
    
    <nav>
        <ul>
            <li><a href="livros">Acervo de Livros (Empréstimos)</a></li>
            <li><a href="emprestimos">Meus Empréstimos / Devoluções</a></li>
            <li><a href="usuario?acao=perfil">Meu Perfil</a></li>
            
<c:if test="${sessionScope.usuarioLogado.tipo == 'admin'}">
                <hr>
                <li><strong>Área Administrativa:</strong></li>
                <li><a href="emprestimos?acao=gerenciar">Gerenciar Empréstimos (Devoluções)</a></li>
                <li><a href="usuario?acao=gerenciar">Gerenciar Usuários</a></li>
                <li><a href="relatorios">Relatórios Administrativos</a></li>
                <hr>
            </c:if>
            
            <li><a href="login?acao=logout">Sair</a></li>
        </ul>
    </nav>
    <jsp:include page="footer.jsp"/>
</body>
</html>