<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<%-- Apenas Admin pode acessar --%>
<c:if test="${sessionScope.usuarioLogado.tipo != 'admin'}">
    <c:redirect url="livros"/>
</c:if>

<!DOCTYPE html>
<html>
<head>
    <title>Editar Livro</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; margin-top: 30px; }
        .form-container { display: inline-block; text-align: left; border: 1px solid #ccc; padding: 20px; border-radius: 5px; }
        input { width: 100%; padding: 5px; margin-bottom: 10px; }
        .btn-salvar { background-color: #4CAF50; color: white; border: none; padding: 10px; cursor: pointer; width: 100%; }
        .btn-cancelar { background-color: #f44336; color: white; text-decoration: none; padding: 10px; display: block; text-align: center; margin-top: 5px; }
    </style>
</head>
<body>
    <h2>Editar Livro</h2>
    
    <div class="form-container">
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
            <%-- Nota: O Servlet atual reseta a disponibilidade baseado neste valor --%>
            <input type="number" name="quantidade" value="${param.quantidade}" required min="1">
            
            <button type="submit" class="btn-salvar">Salvar Alterações</button>
            <a href="livros" class="btn-cancelar">Cancelar</a>
        </form>
    </div>
    <jsp:include page="footer.jsp"/>
</body>
</html>