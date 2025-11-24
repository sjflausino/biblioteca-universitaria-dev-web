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
            
            <%-- Apenas admin vê relatórios --%>
            <c:if test="${sessionScope.usuarioLogado.tipo == 'admin'}">
                <li><a href="relatorios">Relatórios Administrativos</a></li>
            </c:if>
            
            <li><a href="login?acao=logout">Sair</a></li>
        </ul>
    </nav>
</body>
</html>