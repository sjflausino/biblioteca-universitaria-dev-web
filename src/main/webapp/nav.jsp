<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<nav class="navbar">
    <a href="dashboard.jsp">Início</a>
    <c:if test="${param.secao == 'usuario'}">
        <span class="nav-separador">|</span>
        <c:if test="${param.pagina != 'livros'}">
            <a href="livros">Acervo</a>
        </c:if>
        <c:if test="${param.pagina != 'historico'}">
            <a href="emprestimos">Meus Empréstimos</a>
        </c:if>
        <c:if test="${param.pagina != 'perfil'}">
            <a href="usuario?acao=perfil">Meu Perfil</a>
        </c:if>
    </c:if>
    <c:if test="${param.secao == 'admin' and sessionScope.usuarioLogado.tipo == 'admin'}">
        <span class="nav-separador">|</span>
        <c:if test="${param.pagina != 'emprestimos'}">
            <a href="emprestimos?acao=gerenciar">Gerenciar Empréstimos</a>
        </c:if>
        <c:if test="${param.pagina != 'usuarios'}">
            <a href="usuario?acao=gerenciar">Gerenciar Usuários</a>
        </c:if>
        <c:if test="${param.pagina != 'relatorios'}">
            <a href="relatorios">Relatórios</a>
        </c:if>
    </c:if>
</nav>

