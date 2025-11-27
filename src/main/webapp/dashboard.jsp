<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<c:if test="${empty sessionScope.usuarioLogado}">
    <c:redirect url="login.jsp"/>
</c:if>

<!DOCTYPE html>
<html>
<head>
    <title>Painel - Biblioteca</title>
    <link rel="stylesheet" href="css/common.css">
    <link rel="stylesheet" href="css/dashboard.css">
</head>
<body>
    <div class="dashboard-container">
        <div class="dashboard-header">
            <h1>Bem-vindo, ${sessionScope.usuarioLogado.nome}!</h1>
        </div>
        
        <div class="menus-container">
            <div class="menu-section">
                <div class="menu-title">Minha Área</div>
                <ul class="menu-list">
                    <li><a href="livros">Acervo de Livros</a></li>
                    <li><a href="emprestimos">Meus Empréstimos</a></li>
                    <li><a href="usuario?acao=perfil">Meu Perfil</a></li>
                </ul>
            </div>
            
            <c:if test="${sessionScope.usuarioLogado.tipo == 'admin'}">
                <div class="menu-section menu-admin">
                    <div class="menu-title">Área Administrativa</div>
                    <ul class="menu-list">
                        <li><a href="emprestimos?acao=gerenciar">Gerenciar Empréstimos</a></li>
                        <li><a href="usuario?acao=gerenciar">Gerenciar Usuários</a></li>
                        <li><a href="relatorios">Relatórios</a></li>
                    </ul>
                </div>
            </c:if>
        </div>
        
        <div class="dashboard-footer">
            <a href="login?acao=logout" class="link-sair">Sair do Sistema</a>
        </div>
    </div>
    <img src="images/background_lib.png" alt="Biblioteca" class="imagem-biblioteca">
    <jsp:include page="footer.jsp"/>
</body>
</html>
