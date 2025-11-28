<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:if test="${not empty sessionScope.usuarioLogado}">
    <nav class="navbar">
        <div style="display: flex; align-items: center;">
            <a href="dashboard.jsp" class="brand">Biblioteca UFF</a>
            
            <div class="nav-links">
                <a href="dashboard.jsp">Início</a>
                <a href="livros">Acervo</a>
                <a href="emprestimos">Meus Empréstimos</a>
                <a href="usuario?acao=perfil">Meu Perfil</a>

                <c:if test="${sessionScope.usuarioLogado.tipo == 'admin'}">
                    <span style="color: #555; margin: 0 5px;">|</span>
                    <a href="emprestimos?acao=gerenciar" class="admin-link">Gerenciar Emp.</a>
                    <a href="usuario?acao=gerenciar" class="admin-link">Usuários</a>
                    <a href="relatorios" class="admin-link">Relatórios</a>
                </c:if>
            </div>
        </div>

        <div class="user-info">
            <span>Olá, <strong>${sessionScope.usuarioLogado.nome}</strong></span>
            <a href="login?acao=logout" class="btn-sair">Sair</a>
        </div>
    </nav>
</c:if>