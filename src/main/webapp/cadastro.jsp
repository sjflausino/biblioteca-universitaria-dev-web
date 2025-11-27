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

        <form action="usuario" method="POST">
            <input type="hidden" name="acao" value="cadastrar">

            <label>Nome Completo:</label>
            <input type="text" name="nome" value="${param.nome}" required>

            <label>Email:</label>
            <input type="email" name="email" value="${param.email}" required>

            <label>Matrícula:</label>
            <input type="text" name="matricula" value="${param.matricula}" required>

            <label>Senha:</label>
            <input type="password" name="senha" required>

            <c:choose>
                <c:when test="${not empty sessionScope.usuarioLogado and sessionScope.usuarioLogado.tipo == 'admin'}">
                    <label style="color: blue; font-weight: bold;">Tipo de Usuário (Modo Admin):</label>
                    <select name="tipo">
                        <option value="aluno" ${param.tipo == 'aluno' ? 'selected' : ''}>Aluno</option>
                        <option value="admin" ${param.tipo == 'admin' ? 'selected' : ''}>Administrador</option>
                    </select>
                </c:when>
                <c:otherwise>
                    <%-- Usuário comum nem vê a opção, vai oculto como aluno --%>
                    <input type="hidden" name="tipo" value="aluno">
                </c:otherwise>
            </c:choose>

            <input type="submit" value="Cadastrar">