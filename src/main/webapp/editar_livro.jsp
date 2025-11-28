<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:if test="${sessionScope.usuarioLogado.tipo != 'admin'}">
    <c:redirect url="livros"/>
</c:if>

<!DOCTYPE html>
<html>
<head>
    <title>Editar Livro - Biblioteca</title>
    <link rel="stylesheet" href="css/common.css">
    <link rel="stylesheet" href="css/admin.css">
</head>
<body>
    <jsp:include page="nav.jsp" />
    <div class="admin-container">
        <a href="livros" class="link-voltar">← Voltar ao Acervo</a>
        <h1>Editar Livro</h1>
        
        <div class="form-edicao">
            <form action="livros" method="POST">
                <input type="hidden" name="acao" value="editar">
                <input type="hidden" name="id" value="${param.id}">
                
                <label>Título:</label>
                <input type="text" name="titulo" value="${param.titulo}" required>
                
                <label>Autor:</label>
                <input type="text" name="autor" value="${param.autor}" required>
                
                <label>Editora:</label>
                <input type="text" name="editora" value="${param.editora}">
                
                <label>ISBN:</label>
                <input type="text" name="isbn" value="${param.isbn}">
                
                <label>Quantidade Total:</label>
                <input type="number" name="quantidade" value="${param.quantidade}" required min="1">
                
                <button type="submit" class="btn-salvar">Salvar Alterações</button>
                <a href="livros" class="btn-cancelar">Cancelar</a>
            </form>
        </div>
    </div>
    <jsp:include page="footer.jsp"/>
</body>
</html>